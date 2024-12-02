extends Node2D
class_name RC_Level

#References
@onready var _checkpointContainer : Node2D = get_node("Checkpoints")
@onready var _racecarContainer : Node2D = get_node("Racecars")
@onready var vfxContainer : Node2D = get_node("VFX")

var _musicPaused : bool = false

var checkpoints : Array[Node]:
	get:
		if (get_node_or_null("Checkpoints") != null):
			return get_node("Checkpoints").get_children()
		return []

var placing : Array[RC_RaceCar]:
	get:
		##There are no racers; return empty
		if (_racecarContainer.get_child_count() == 0):
			return []
		
		##There is only 1 racer; return
		if (_racecarContainer.get_child_count() == 1):
			return [_racecarContainer.get_child(0)]
		
		##There are multiple racers; find their order
		var returnArray : Array[RC_RaceCar] = []
		var racerScore : Array[float] = [] #The score of each racer in index order
		for i in range(_racecarContainer.get_child_count()):
			var racecar : RC_RaceCar = _racecarContainer.get_child(i)
			racerScore.append(0)
			#Add lap advantages
			racerScore[i] += racecar.lapsRemaining * 10000
			#Add checkpoint avantages
			racerScore[i] += racecar.checkpointsRemaining * 1000
			#Get the distance from the nearest point on the checkpoint's line
			if (checkpoints.size() > 0):
				var nextCheckpointIndex : int = racecar.checkpointIndex
				var pointOnLine : Vector2 = Math.get_nearest_point_on_line(racecar.global_position, checkpoints[nextCheckpointIndex].pointA, checkpoints[nextCheckpointIndex].pointB)
				var distToCheckpoint = _racecarContainer.get_child(i).global_position.distance_to(pointOnLine)
				var prevScore = racerScore[i]
				racerScore[i] += distToCheckpoint
		
		##Calculate placing based on scores
		var highestScores : Array[int] #The score of all the players in order from highest to lowest
		var placings : Array[int] = [] #Each racer's placing (0 = 1st place)
		for i in range(racerScore.size()):
			placings.append(0)
			for j in range(racerScore.size()):
				#Skip if comparing against self
				if (i == j):
					continue
				
				#Get bumped down if another racer has a higher score
				if (racerScore[i] > racerScore[j]):
					placings[i] += 1
		for i in range(placings.size()):
			returnArray.append(_racecarContainer.get_child(placings.find(i)))
		
		
		return returnArray



static var AIDataChosen : Array[String] = [] #Keeps track of which AIData files were used for CPU racers, to avoid 2 racers using the same data
func activate(players : Array[int], cpus : Array[int]):
	#Get the spawn checkpoint
	var spawnCheckpoint : RC_Checkpoint = _checkpointContainer.get_child(_checkpointContainer.get_child_count() - 1)
	if (spawnCheckpoint.spawnLength <= 0):
		printerr("RC_Level.activate() :: The FINAL checkpoint child node in the 'Checkpoints' Node2D has a spawnLength of 0. A spawnLength must be set on this checkpoint to spawn the racers. ")
		return
	
	#Setup level
	position = Vector2.ZERO
	var playerCount = players.size()
	var CPUCount = cpus.size()
	var racerCount : int = playerCount + CPUCount
	
	#Spawn racers
	var spawnLengthSegment : float = (spawnCheckpoint.spawnLength * 2) / (racerCount + 1) #This is how far apart the racers spawn from each other
	var currentRacerIndex : int = 1
	AIDataChosen = []
	for i in range(racerCount):
		#Create new racer
		var newCar : RC_RaceCar = RC_Data.racecarPrefab.instantiate()
		_racecarContainer.add_child(newCar)
		
		#Set car position
		var distFromSpawn : Vector2 = -(Math.vec3_to_vec2(Math.get_left(spawnCheckpoint.transform)) \
		* (-spawnCheckpoint.spawnLength + (spawnLengthSegment * currentRacerIndex))) + spawnCheckpoint.offset
		newCar.global_position = spawnCheckpoint.global_position + distFromSpawn
		newCar.startPosFromCenter = distFromSpawn - spawnCheckpoint.offset
		
		#Set as player
		if (currentRacerIndex <= playerCount):
			newCar.player = currentRacerIndex
			newCar.set_color(RC_Data.colorOptions[players[i]])
			#Assign to GameManager references
			if (i == 0):
				RC_GameManager.player1 = newCar
			elif (i == 1):
				RC_GameManager.player2 = newCar
		else:
			var level : int = int(name.right(1)) - 1
			var difficulty : int = cpus[i - playerCount]
			newCar.set_difficulty(level, difficulty)
		
		#Increment index
		currentRacerIndex += 1




func _ready():
	RC_Pause.onPlayerPaused.append(_on_paused)
	RC_Pause.onPlayerUnpaused.append(_on_unpaused)





func _on_paused():
	if (RC_SoundManager.is_playing("RaceMusic")):
		RC_SoundManager.pause("RaceMusic")
		_musicPaused = true


func _on_unpaused():
	if (_musicPaused):
		RC_SoundManager.play("RaceMusic")
		_musicPaused = false



#func deactivate():
	#visible = false
	#global_position = Vector2(-10000, -10000)
	#for child in (_racecarContainer.get_children()):
		#child.queue_free()
	#for child in (vfxContainer.get_children()):
		#child.queue_free()
