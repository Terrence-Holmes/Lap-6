extends Node
class_name RC_RaceCarInput
@onready var racecar : RC_RaceCar = get_parent()

var _upInput : String:
	get:
		return "Up" if (RC_GameManager.player1 == racecar) else "P2_Up"
var _downInput : String:
	get:
		return "Down" if (RC_GameManager.player1 == racecar) else "P2_Down"
var _leftInput : String:
	get:
		return "Left" if (RC_GameManager.player1 == racecar) else "P2_Left"
var _rightInput : String:
	get:
		return "Right" if (RC_GameManager.player1 == racecar) else "P2_Right"
var _primaryInput : String:
	get:
		#Player 1
		if (RC_GameManager.player1 == racecar):
			#Single player
			if (RC_GameManager.player2 == null):
				return "Primary"
			#Multi player
			else:
				return "P1_Primary"
		#Player 2
		else:
			return "P2_Primary"
var _secondaryInput : String:
	get:
		#Player 1
		if (RC_GameManager.player1 == racecar):
			#Single player
			if (RC_GameManager.player2 == null):
				return "Secondary"
			#Multi player
			else:
				return "P1_Secondary"
		#Player 2
		else:
			return "P2_Secondary"



func _process(delta):
	if (not RC_Pause.isPaused):
		if (not racecar.raceComplete):
			_accelerate_input()
			_turn_input()
			_brake_input()
		else:
			racecar.accelerateInput = false
			racecar.turnInput = 0
			racecar.brakeInput = true
		
		#FOR AI BUILDING
		_record_race_data()



func _accelerate_input():
	racecar.accelerateInput = Input.is_action_pressed(_primaryInput)


func _turn_input():
	racecar.turnInput = Input.get_axis(_leftInput, _rightInput)


func _brake_input():
	racecar.brakeInput = Input.is_action_pressed(_secondaryInput)



#This function records and saves player data, which can be plugged into an AI unit
#Used for building AI and will not be in the final game
var recordedData : Array = []
var inputDataSaved : bool = false
func _record_race_data():
	if (RC_GameManager.currentLevel != null):
		if (not racecar.raceComplete or racecar.velocity.length() > 1):
			##Record data
			recordedData.append([
				Time.get_ticks_msec() - RC_GameManager.raceStartTime, #Time of recording
				racecar.position, #Position
				racecar._headingAngle, #Rotation
				racecar.brakeInput and racecar._forwardVelocity > racecar._tiremarkMinVelocity #Is drifting (bool)
				])
		elif (not inputDataSaved):
			inputDataSaved = true
			
			#Get total race time
			var totalTime : float = 0
			for i in range(RC_GameManager.lapsToWin):
				#If lap i was completed, add the lap time
				if (RC_GameManager.lapDictionary[racecar].size() > i):
					totalTime += RC_GameManager.lapDictionary[racecar][i]
				#If this racecar did not finish lap i, add 100,000 to the total time to indicate a failed lap
				else:
					totalTime += 100000
			
			var fileName : String = RC_GameManager.currentLevel.name + "_" + str(totalTime).pad_decimals(2)
			RC_InputRecorder.save_data(recordedData, fileName)






