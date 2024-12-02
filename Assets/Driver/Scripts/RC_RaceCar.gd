extends CharacterBody2D
class_name RC_RaceCar

@export_category("Race car")
@export var headingAtStart : int = 0
@export var player : int = 0
@export_group("Visual")
@export var hitPulseCurveX : Curve
@export var hitPulseCurveY : Curve

#References
@onready var _rotator : Node2D = get_node("Rotator")
@onready var _sprite : Sprite2D = _rotator.get_node("Sprite")
@onready var _crown : Sprite2D = get_node("Crown")
@onready var _spriteColor : Sprite2D = _sprite.get_node("Color")
@onready var _leftTiremarkPos : Node2D = _rotator.get_node("LeftTiremarkPos")
@onready var _rightTiremarkPos : Node2D = _rotator.get_node("RightTiremarkPos")
@onready var _wallCheck : ShapeCast2D = _rotator.get_node("WallCheck")
@onready var _smokeParticleEmitter : RC_ParticleEmitter = _rotator.get_node("SmokeParticleEmitter")
@onready var _boostParticleEmitter : RC_ParticleEmitter = _rotator.get_node("BoostParticleEmitter")
@onready var _boostCheck : ShapeCast2D = get_node("BoostCheck")
@onready var _grassCheck : ShapeCast2D = get_node("GrassCheck")
@onready var _lapTimeLabel : Label = get_node("LapTime")
@onready var _lapTimeAnimation : AnimationPlayer = get_node("LapTimeAnimation")
@onready var _cpuInput : RC_RaceCarAI = get_node("CPUInput")

##Vehicle stats
#Forward movement
const _acceleration : float = 180
const _maxSpeed : float = 200
#Turning
const _turnStrength : Vector2 = Vector2(0.4, 0.8) #x = regular turn strength, y = drifting turn strength
const _lowTurnStrength : float = 0.4 #The percentage of the _turnStrength that the car gets when going at the lowest turn speed
const _turnSpeed : Vector2 = Vector2(0.2, 0.9) #The percentage of max speed that the car will have the least turn strength, and the most turn strength
const _turnAcceleration : float = 0.1
const _turnDecceleration : float = 0.05
#Braking
const _driftBrakeStrength : float = 0.004 #The break applied while the gas pedal is also being held
const _brakeStrength : float = 0.02 #The break applied while the gas pedal is not being held
#Drag
const _drag : float = 0.002 #The regular drag that's always applied
const _turnDrag : float = 0.007 #Additional drag applied while turning
#Traction
const _tractionRange : Vector2 = Vector2(0.1, 0.5) #x = drift traction, y = regular traction
const _controlRegain : float = 0.1 #How fast you regain traction control when you stop drifting
#Collision
const _wallHitSlowdown : float = 0.2 #0.1 = less slowdown, 0.9 = more slowdown
#Boost
const _boostPower : float = 120
const _boostCooldown : float = 2.5


#Movement
var _headingAngle : float = PI * 1.5
var _forwardVelocity : float = 0
var _boostVelocity : float = 0
var _turningVelocity : float = 0
var _targetVelocity : Vector2 = Vector2.ZERO
var _traction : float = _tractionRange.y
var drifting = false

#Fishtail
const _fishtailStrength : float = 0.01
const _fishtailStrengthVariation : float = 0.2
var _fishtailAmount : float = 0
var _fishtailDirection : float = 1 #-1 = left, 1 = right
const _fishtailDirectionChangeSpeed : float = 10

#Grass
const _grassDrag : float = 0.02


#Visuals
var _spriteRotation : float = 0
var boostParticleSpeed : float = 3.6 #How fast the car has to be going to get the boost particles
#Tiremark
var _tiremarkMinVelocity : float = 80 #The minimum velocity needed to get tiremarks
var _leftTiremark : RC_Tiremark = null
var _rightTiremark : RC_Tiremark = null


#Input
var accelerateInput : bool = false
var turnInput : float = 0
var brakeInput : bool = false


#Checkpoint
var checkpointIndex : int = 0
var _lastCheckpointDot : float = 0

#Laps
var _fastestLap : float = 1000000000
var lapStartTime : float = 0
var lapsComplete : int = 0
var raceComplete : bool = false

#Pausing
var _lapTimeAnimationPaused : bool = false

#AI
var startPosFromCenter : Vector2 = Vector2.ZERO

#Sprite scaling
const _hitPulseDuration : float = 0.3
const _hitPulseScale : float = 0.8
var _hitPulseTimer : float = 0



##GETTERS
var checkpoints : Array[Node]:
	get:
		if (RC_GameManager.currentLevel != null and RC_GameManager.currentLevel.get_node_or_null("Checkpoints") != null):
			return RC_GameManager.currentLevel.get_node("Checkpoints").get_children()
		return []

var lapsRemaining : int:
	get:
		return RC_GameManager.lapsToWin - lapsComplete

var checkpointsRemaining : int:
	get:
		return checkpoints.size() - checkpointIndex

var _lastPosition : Vector2 = Vector2.ZERO
var carVelocity : Vector2:
	get:
		return global_position - _lastPosition


func _ready():
	#Assign to delegates
	RC_Pause.onPaused.append(_on_pause)
	RC_Pause.onUnpaused.append(_on_unpause)
	
	await get_tree().create_timer(0.01).timeout
	_lastPosition = global_position
	if (player > 0):
		_cpuInput.queue_free()
		_cpuInput = null
	else:
		get_node("PlayerInput").queue_free()
	
	#Add self to the lap dictionary
	RC_GameManager.lapDictionary[self] = []


func _process(delta):
	if (not RC_Pause.isPaused):
		if (player > 0):
			_apply_acceleration()
			_apply_turn()
			_apply_drag()
			_apply_brakes()
			_set_traction()
			_detect_wall_hit()
			_detect_grass()
			_apply_hit_pulse()
		_boost_check()
		_update_sprite_rotation()
		_set_smoke_particles()
		_set_boost_particles()
		_create_tiremarks()
		_check_checkpoint()


var highestSpeed : float = 0

func _physics_process(delta):
	if (not RC_Pause.isPaused and player > 0):
		_targetVelocity = Vector2(_forwardVelocity + _boostVelocity, 0).rotated(_headingAngle)
		velocity = lerp(velocity, _targetVelocity, _traction)
		
		_lastPosition = global_position
		move_and_slide()


func _apply_acceleration():
	if (accelerateInput):
		_forwardVelocity += _acceleration * get_process_delta_time()
		_forwardVelocity = min(_forwardVelocity, _maxSpeed)


func _apply_turn():
	if (turnInput != 0):
		var maxTurn : float = _turnStrength.x if (not brakeInput) else _turnStrength.y
		var turnPercent : float = clampf((_forwardVelocity - (_maxSpeed * _turnSpeed.x)) / ((_maxSpeed * _turnSpeed.y) - (_maxSpeed * _turnSpeed.x)), 0, 1)
		var turn = lerpf(maxTurn * _lowTurnStrength, maxTurn, turnPercent)
		
		var targetTurnVelocity : float = turn * turnInput * get_process_delta_time() * 5
		var turnVelT : float = _turnDecceleration if ( Math.pos_or_neg(_turningVelocity) == Math.pos_or_neg(targetTurnVelocity) and abs(targetTurnVelocity) < abs(_turningVelocity) ) else _turnAcceleration
		_turningVelocity = lerpf(_turningVelocity, targetTurnVelocity, _turnAcceleration * get_process_delta_time() * 60)
		
	else:
		_turningVelocity = lerpf(_turningVelocity, 0, _turnDecceleration * get_process_delta_time() * 60)
	
	_apply_fishtail()
	
	#TODO: Ensure _headingAngle remains between 0 and TAU
	_headingAngle += _turningVelocity

func _apply_drag():
	_forwardVelocity *= 1 - _drag
	if (turnInput != 0):
		_forwardVelocity *= 1 - _turnDrag

func _apply_brakes():
	if (brakeInput):
		var brake : float = _driftBrakeStrength if (accelerateInput) else _brakeStrength
		_forwardVelocity *= 1 - brake
		#Come to a stop
		if (not accelerateInput and _forwardVelocity <= 20):
			_forwardVelocity -= get_process_delta_time() * 10
			_forwardVelocity = max(_forwardVelocity, 0)


func _apply_fishtail():
	if (brakeInput and turnInput == 0):
		_fishtailAmount += _fishtailDirectionChangeSpeed * _fishtailDirection * get_process_delta_time()
		if ((_fishtailDirection == 1 and _fishtailAmount >= 1)
		or (_fishtailDirection == -1 and _fishtailAmount <= -1)):
			_fishtailDirection *= -1
		
		var fishtail : float = _fishtailStrength * (1 - randf_range(0, _fishtailStrengthVariation))
		var turnPercent : float = clampf((_forwardVelocity - (_maxSpeed * _turnSpeed.x)) / ((_maxSpeed * _turnSpeed.y) - (_maxSpeed * _turnSpeed.x)), 0, 1)
		fishtail *= turnPercent
		_turningVelocity += _fishtailAmount * fishtail #Do not multiply by delta time


func _set_traction():
	if (brakeInput):
		_traction = _tractionRange.x
	else:
		_traction = lerpf(_traction, _tractionRange.y, _controlRegain * get_process_delta_time() * 60)


var lastPosOrNegCorrection : float = 1
var turnCorrectInverseCount : int = 0
func _detect_wall_hit():
	if (_wallCheck.is_colliding()):
		#Steer away from wall
		var collisionNormal : Vector2 = _wallCheck.get_collision_normal(0)
		var carNormal : Vector2 = Vector2.UP.rotated(_headingAngle)
		var angleDifference : float = collisionNormal.angle_to(carNormal)
		var correctionAmount : float = -((PI - angleDifference) + 0.2) if (angleDifference >= PI / 2) else angleDifference + 0.2
		
		#Use this to detect if player is stuck
		if (Math.pos_or_neg(correctionAmount) != lastPosOrNegCorrection):
			turnCorrectInverseCount += 1
		else:
			turnCorrectInverseCount = 0
		lastPosOrNegCorrection = Math.pos_or_neg(correctionAmount)
		#Reverse player's heading if stuck
		if (turnCorrectInverseCount > 8):
			_headingAngle -= PI
		
		else:
			_headingAngle = lerpf(_headingAngle, _headingAngle - correctionAmount, 0.2 * get_process_delta_time() * 60)
		
		#Play hit pulse
		if (_hitPulseTimer <= 0 and _forwardVelocity > 100 and abs(correctionAmount) >= 1.2):
			_hitPulseTimer = _hitPulseDuration
			RC_SoundManager.play("Crash", true)
		
		
		#Decrease velocity
		_forwardVelocity *= 1 - _wallHitSlowdown
		

func _detect_grass():
	#On grass
	if (_grassCheck.is_colliding()):
		_forwardVelocity *= (1 - _grassDrag)


func _boost_check():
	#Boost cooldown
	if (_boostVelocity > 0):
		#_boostVelocity = lerpf(_boostVelocity, 0, _boostCooldown * get_process_delta_time() * 60)
		_boostVelocity -= _boostCooldown * get_process_delta_time() * 60
		if (_boostVelocity <= 0.01):
			_boostVelocity = 0
	
	#Apply boost
	if (_boostVelocity < (_boostPower * 0.5) and _boostCheck.is_colliding()):
		_boostVelocity = _boostPower
		#Play boost sound
		var pitch = randi_range(0.7, 1.3)
		RC_SoundManager.play("Boost", true, pitch)


func _create_tiremarks():
	if (player > 0):
		drifting = brakeInput and _forwardVelocity > _tiremarkMinVelocity
	#Begin tiremark streak
	if (drifting):
		#Create tiremarks
		if (_leftTiremark == null or _rightTiremark == null):
			_leftTiremark = RC_Data.tiremarkPrefab.instantiate()
			_rightTiremark = RC_Data.tiremarkPrefab.instantiate()
			get_parent().get_parent().vfxContainer.add_child(_leftTiremark)
			get_parent().get_parent().vfxContainer.add_child(_rightTiremark)
			_leftTiremark.global_position = Vector2.ZERO
			_rightTiremark.global_position = Vector2.ZERO
		
		#Add points
		_leftTiremark.create_point(_leftTiremarkPos.global_position)
		_rightTiremark.create_point(_rightTiremarkPos.global_position)
	#Break tiremark streak
	else:
		_leftTiremark = null
		_rightTiremark = null



func _check_checkpoint():
	if (checkpoints.size() > 0):
		var checkpoint : Node = checkpoints[checkpointIndex]
		if (not checkpoint is RC_Checkpoint):
			printerr("RC_RaceCar._check_checkpoint() :: A child in the level's 'Checkpoints' node is not of type 'RC_Checkpoint'.")
			return
		
		#Get the nearest point to the player on the checkpoint line
		var pointOnLine : Vector2 = Math.get_nearest_point_on_line(global_position, checkpoint.pointA, checkpoint.pointB)
		#Get the player's dot product to the checkpoint
		var checkpointDot : float = checkpoint.passThroughDirection.dot(checkpoint.global_position.direction_to(global_position))
		if ((abs(global_position.direction_to(pointOnLine).dot(checkpoint.passThroughDirection)) + 0.01) >= 1):
			#Compare with the dot product of the last frame
			if (_lastCheckpointDot <= 0 and checkpointDot > 0):
				#Pass checkpoint
				_checkpoint_passed()
			
		#Cache dot product for the check in the next frame
		_lastCheckpointDot = checkpointDot
		



func _update_sprite_rotation():
	_rotator.rotation = _headingAngle


func _set_smoke_particles():
	if (drifting):
		_smokeParticleEmitter.start_emitting()
	else:
		_smokeParticleEmitter.stop_emitting()

func _set_boost_particles():
	if (carVelocity.length() > boostParticleSpeed):
		_boostParticleEmitter.start_emitting()
	else:
		_boostParticleEmitter.stop_emitting()


func _apply_hit_pulse():
	if (_hitPulseTimer > 0):
		#Set sprite scale
		var newScaleT : float = lerpf(1, 0, clampf(_hitPulseTimer / _hitPulseDuration, 0, 1)  )
		_sprite.scale = Vector2(
			1 + (hitPulseCurveY.sample(newScaleT) * _hitPulseScale),
			1 + (hitPulseCurveX.sample(newScaleT) * _hitPulseScale))
		
		#Tick down timer
		_hitPulseTimer -= get_process_delta_time()
		#Timeout
		if (_hitPulseTimer <= 0):
			_hitPulseTimer = 0



func _checkpoint_passed():
	#Checkpoint crossed
	if (checkpointIndex + 1 < checkpoints.size()):
		checkpointIndex += 1
	#Lap crossed
	else:
		#Reset checkpoint index
		checkpointIndex = 0
		
		#Increment laps completed
		lapsComplete += 1
		
		#Display lap time
		var lapTime : float = (Time.get_ticks_msec() - lapStartTime) * 0.001
		if (player != 0):
			var lapTimeString : String = str( min(999.99, lapTime)).pad_decimals(2)
			_lapTimeLabel.text = lapTimeString
			_lapTimeAnimation.play("DisplayLapTime")
		
		#Add lap time to the lap dictionary
		RC_GameManager.lapDictionary[self].append(lapTime)
		
		#Update fastest lap
		if (lapTime < _fastestLap):
			_fastestLap = lapTime
		
		
		#End game if final lap
		if (lapsComplete >= RC_GameManager.lapsToWin):
			raceComplete = true
			RC_GameManager.start_end_countdown()
			
			#Check if this is the first vehicle to cross the finish line
			var firstVehicleOver : bool = true
			for racecar in RC_GameManager.lapDictionary:
				if (racecar != self and racecar.raceComplete):
					firstVehicleOver = false
			
			#Activate win juice
			if (firstVehicleOver):
				RC_SoundManager.stop_all_with_bus("Music")
				RC_SoundManager.play("RaceComplete")
				_crown.visible = true
				
		
		
		#Update timer
		lapStartTime = Time.get_ticks_msec()
		
		if (player != 0):
			#Update UI
			RC_GameManager.updateLapCountUI.call()
			#Play jingle
			RC_SoundManager.play("LapComplete", true)


func set_color(color : Color):
	_spriteColor.self_modulate = color


func set_difficulty(levelIndex : int, difficulty : int):
	if (_cpuInput != null):
		_cpuInput.set_difficulty(levelIndex, difficulty)


##PAUSING

func _on_pause():
	if (_lapTimeAnimation.is_playing()):
		_lapTimeAnimation.pause()
		_lapTimeAnimationPaused = true

func _on_unpause():
	if (_lapTimeAnimationPaused):
		_lapTimeAnimation.play()
		_lapTimeAnimationPaused = false
