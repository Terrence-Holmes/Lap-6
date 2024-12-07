extends Node
class_name RC_RaceCarAI

@onready var racecar : RC_RaceCar = get_parent()


var _movementData : Array = []
var _positionIndex : int = 0


#func _ready():
	#await get_tree().create_timer(0.5).timeout
	#_movementData = RC_InputRecorder.load_data("AIData_Level3_121.01.json", 3, "NEED_TO_BE_REVIEWED/")

func _process(delta):
	if (RC_GameManager.lapsToWin == 6 or not racecar.raceComplete): #This is just so that the race stops when testing with less than 6 laps
		_apply_movement()


func _apply_movement():
	if (not RC_Pause.isPaused and _movementData.size() > 0 and _positionIndex < _movementData.size()):
		var currentRaceTime : int = Time.get_ticks_msec() - RC_GameManager.raceStartTime
		while (_positionIndex < _movementData.size() and currentRaceTime >= _movementData[_positionIndex][0]):
			var _posFromCenter = Vector2.ZERO
			const correctionTime : float = 180
			if (_positionIndex < correctionTime):
				_posFromCenter = lerp(racecar.startPosFromCenter, Vector2.ZERO, float(_positionIndex) / correctionTime)
			
			racecar._lastPosition = racecar.global_position
			racecar.position = _movementData[_positionIndex][1] + _posFromCenter
			racecar._headingAngle = _movementData[_positionIndex][2]
			racecar.drifting = _movementData[_positionIndex][3]
			_positionIndex += 1


func set_difficulty(levelIndex : int, difficulty : int):
	_movementData.clear()
	#Get the possible AIData options with the given level and difficulty
	var options : Array = RC_InputRecorder.AIData[levelIndex][difficulty]
	if (options.size() > 0):
		#Select a random AIData from the options
		var selectedOption : String = ""
		while (selectedOption == "" or RC_Level.AIDataChosen.has(selectedOption)):
			selectedOption = options[randi_range(0, options.size() - 1)]
		RC_Level.AIDataChosen.append(selectedOption)
		#Set the movement data to the selected AIData
		_movementData = RC_InputRecorder.load_data(selectedOption, levelIndex)
	else:
		printerr("RC_RaceCarAI.set_difficulty() :: The 'options' array returned a size of zero. Did not load an AIData to the racer.")
