extends Node2D
class_name RC_SoundManager



static var instance : RC_SoundManager:
	get:
		return Engine.get_main_loop().current_scene.get_node_or_null("SoundManager")


const maxVolume : int = 5
static var musicVolume : int = maxVolume
static var sfxVolume : int = maxVolume


static var _musicPosition : Dictionary = {}


func _process(delta):
	_handle_car_audio()


#Car audio is handled here so that it doesn't double up
func _handle_car_audio():
	if (not RC_Pause.get_pause(RC_Pause.PauseState.PLAYER_PAUSED) and RC_GameManager.playerArray.size() > 0):
		#Check car stats
		var carIsDrifting : bool = false
		var carIsFast : bool = false
		var fastestCar : float = 0
		for car in RC_GameManager.playerArray:
			#Get drift
			if (car.drifting):
				carIsDrifting = true
			#Get flame activation
			if (car.carVelocity.length() > car.boostParticleSpeed):
				carIsFast = true
			#Get fastest car
			if (car.carVelocity.length() > fastestCar):
				fastestCar = car.carVelocity.length()
		
		#Drifting
		if (carIsDrifting):
			RC_SoundManager.play("Drift")
		else:
			RC_SoundManager.pause("Drift")
		
		#Boosting
		if (carIsFast):
			RC_SoundManager.play("Flames")
		else:
			RC_SoundManager.pause("Flames")
		
		#Engine
		var peakEngineSpeed : float = 4 #How fast the car has to be going to get the highest pitch engine
		var pitchRange : Vector2 = Vector2(0.4, 2)
		if (fastestCar > 0.08 and instance.get_node_or_null("Engine") != null):
			var pitch : float = lerpf(pitchRange.x, pitchRange.y, clampf(fastestCar / peakEngineSpeed, 0, 1))
			RC_SoundManager.play("Engine", false, pitch)
		else:
			pass
			#RC_SoundManager.stop("Engine")
	#Game is paused; pause sound
	elif (RC_Pause.get_pause(RC_Pause.PauseState.PLAYER_PAUSED)):
		RC_SoundManager.pause("Drift")
		RC_SoundManager.pause("Flames")
		RC_SoundManager.stop("Engine")









static func get_sound_node(soundName : String) -> AudioStreamPlayer:
	if (instance):
		var soundNode : Node = instance.get_node_or_null(soundName)
		if (soundNode and soundNode is AudioStreamPlayer):
			return soundNode
		#Sound node doesn't exist
		else:
			printerr("RC_SoundManager.play() :: No AudioStreamPlayer node with the given name '" + soundName + "' exists as a child of self.")
	#Instance does not exist in the scene
	else:
		printerr("RC_SoundManager.play() :: No instance of RC_SoundManager exists in the scene. Check the node path of RC_SoundManager.instance")
	
	return null

#Returns true if the audio with the given soundName is playing.
static func is_playing(soundName : String):
	var soundNode : AudioStreamPlayer = get_sound_node(soundName)
	return (soundNode and soundNode.playing)

static func play(soundName : String, startFromBeginning : bool = false, pitchShift : float = 1):
	var soundNode : AudioStreamPlayer = get_sound_node(soundName)
	if (soundNode):
		#Set pitch shift
		soundNode.pitch_scale = pitchShift
		#Stop prior music if this sound is music
		if (soundNode.bus == "Music"):
			stop_all_with_bus("Music")
		#Play sound
		if (not startFromBeginning and _musicPosition.has(soundName)):
			soundNode.play()
			soundNode.seek(_musicPosition[soundName])
			_musicPosition.erase(soundName)
		elif (startFromBeginning or not soundNode.playing):
			_musicPosition.erase(soundName)
			soundNode.play()

static func pause(soundName : String):
	var soundNode : AudioStreamPlayer = get_sound_node(soundName)
	if (soundNode and not soundNode.stream_paused):
		_musicPosition[soundName] = soundNode.get_playback_position()
		soundNode.stop()


static func stop(soundName : String, fade : bool = false):
	var soundNode : AudioStreamPlayer = get_sound_node(soundName)
	if (soundNode):
		_musicPosition.erase(soundName)
		soundNode.stop()

#Stops all audio with the given audio bus
static func stop_all_with_bus(busName : String):
	if (instance):
		for child in instance.get_children():
			if (child is AudioStreamPlayer and child.bus == busName):
				child.stop()



static func set_bus_volume(bus : String, volume : int):
	var busIndex : int = 1 if (bus == "SFX") else 2
	var db : float = -80
	if (volume > 0):
		db = lerpf(-32, 0, float(volume) / float(maxVolume))
	AudioServer.set_bus_volume_db(busIndex, db)
