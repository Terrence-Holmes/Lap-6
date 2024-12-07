extends Control

class_name RC_Scoreboard


#References
@onready var mainMenuButton : Button = get_node("MainMenuButton")
@onready var scrollContainer : ScrollContainer = get_node("ScrollContainer")
@onready var statsContainer : VBoxContainer = scrollContainer.get_node("StatsRoot/StatsContainer")
@onready var statsTemplate : Panel = statsContainer.get_child(0)
@onready var highScoreContainer : VBoxContainer = get_node("HighScoreContainer")
@onready var highScoreLabel : RichTextLabel = highScoreContainer.get_node("HighScoreLabel")
@onready var winningRacerLabel : Label = highScoreLabel.get_node("WinningRacer")
@onready var highScoreTimeLabel : Label = highScoreLabel.get_node("HighScoreTime")
@onready var nameEntryLabel : RichTextLabel = highScoreContainer.get_node("NameEntry/NameEntryLabel")
@onready var instructions : Label = highScoreContainer.get_node("NameEntry/Instructions")


#High score
var highScoreName : String = "null"
var displayName : String = ""
var letterIndex : int = 1
const maxNameSize : int = 3
var highScoreTime : float = 0




func _ready():
	mainMenuButton.connect("pressed", _main_menu_pressed)
	
	#Attach button sounds
	mainMenuButton.connect("mouse_entered", RC_GameManager._button_hovered)
	mainMenuButton.connect("pressed", RC_GameManager._button_pressed)
	
	#Subscribe to delegates
	RC_GameManager.onGotoScreen.append(_deactivate_highscore_input)
	

func _process(delta):
	_get_high_score_input()


func _get_high_score_input():
	if (highScoreContainer.visible and highScoreName != "null"):
		#Get letter index change
		if (Input.is_action_just_pressed("Up") or Input.is_action_just_pressed("P2_Up")):
			letterIndex += 1
			RC_SoundManager.play("LetterChange", true)
		if (Input.is_action_just_pressed("Down") or Input.is_action_just_pressed("P2_Down")):
			RC_SoundManager.play("LetterChange", true)
			letterIndex -= 1
		#Keep letter index within range
		if (letterIndex > RC_Data.nameEntryLetters.size() - 1):
			letterIndex -= RC_Data.nameEntryLetters.size()
		elif (letterIndex < 0 or (highScoreName == "" and letterIndex < 1)):
			letterIndex = RC_Data.nameEntryLetters.size() - 1
		#Don't allow the first letter to be a space
		if (highScoreName == "" and letterIndex == 0):
			letterIndex = 1
		
		#Letter submit
		if (Input.is_action_just_pressed("Primary") or Input.is_action_just_pressed("P1_Primary") or Input.is_action_just_pressed("P2_Primary")):
			var letterToAdd : String = RC_Data.nameEntryLetters[letterIndex] if (RC_Data.nameEntryLetters[letterIndex] != "_") else " "
			highScoreName += letterToAdd
			letterIndex = 1
			if (highScoreName.length() >= maxNameSize):
				RC_SoundManager.play("LapComplete", true)
			else:
				RC_SoundManager.play("MouseClick", true)
		
		#Letter undo
		if ((Input.is_action_just_pressed("Secondary") or Input.is_action_just_pressed("P1_Secondary") or Input.is_action_just_pressed("P2_Secondary"))
		and highScoreName.length() > 0):
			RC_SoundManager.play("MouseHover", true)
			highScoreName = highScoreName.left(-1)
			letterIndex = 1
		
		
		#Set display name
		displayName = highScoreName
		
		#Final letter
		if (highScoreName.length() >= maxNameSize):
			_submit_high_score_input()
		#Add next letter to the display name
		else:
			displayName += "[font_size=48][wave amp=10][color=yellow]" + RC_Data.nameEntryLetters[letterIndex]
		
		#Set UI text
		nameEntryLabel.text = ("Enter name: " + displayName) if (highScoreName != "null") else "[center]" + displayName + "[/center]"


func _submit_high_score_input():
	if (RC_GameManager.lastLevelIndex != -1):
		highScoreName = "null"
		instructions.visible = false
		#nameEntryLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		#Save to disk
		RC_SaveSystem.save_data("HIGHSCORE_" + str(RC_GameManager.lastLevelIndex + 1) + "_NAME", displayName)
		RC_SaveSystem.save_data("HIGHSCORE_" + str(RC_GameManager.lastLevelIndex + 1), highScoreTime)
		RC_GameManager.instance.gameUI.set_display("HIGHSCORE")

func activate():
	#Get total race times
	var carArray : Array[RC_RaceCar] = [] #An array of the cars in order of their player index
	var totalRaceTime : Dictionary = {}
	for racecar in RC_GameManager.lapDictionary:
		carArray.append(racecar)
		var totalTime : float = 0
		for i in range(RC_GameManager.lapsToWin):
			#If lap i was completed by this racecar, add the lap time
			if (RC_GameManager.lapDictionary[racecar].size() > i):
				totalTime += RC_GameManager.lapDictionary[racecar][i]
			#If this racecar did not finish lap i, add 100,000 to the total time to indicate a failed lap
			else:
				totalTime += 100000
		totalRaceTime[racecar] = totalTime
	
	#Get car order (from first place to last)
	var carOrder : Array[RC_RaceCar] = [] #An array of the cars in order of their place in the race
	while (carOrder.size() < totalRaceTime.size()):
		var shortestTime : float = 9999999
		var fastestCar : RC_RaceCar = null
		for racecar in totalRaceTime:
			if (not carOrder.has(racecar) and totalRaceTime[racecar] < shortestTime):
				shortestTime = totalRaceTime[racecar]
				fastestCar = racecar
		if (fastestCar != null):
			carOrder.append(fastestCar)
	
	##Create scores
	var placing : int = 1
	for i in range(carOrder.size()):
		var newScore : Control = statsTemplate.duplicate()
		statsContainer.add_child(newScore)
		var container : HBoxContainer = newScore.get_node("StatsContainer")
		##Set up score labels
		#Set place
		if (i > 0 and totalRaceTime[carOrder[i]] > totalRaceTime[carOrder[i - 1]]):
			placing += 1
		var placeText : String = ""
		match placing:
			1:
				placeText = "1st"
			2:
				placeText = "2nd"
			3:
				placeText = "3rd"
			4:
				placeText = "4th"
		container.get_node("PlaceLabel").text = placeText
		#Set player name
		container.get_node("PlayerLabel").text = "Racer " + str(Math.get_index_from_array(carOrder[i], carArray) + 1)
		#Set total time
		if (totalRaceTime[carOrder[i]] < 100000):
			var displayTime : float = totalRaceTime[carOrder[i]]
			container.get_node("TotalTime").text = str(displayTime).pad_decimals(2)
		else:
			container.get_node("TotalTime").text = "N/A"
		#Set lap times
		for j in range(RC_GameManager.lapDictionary[carOrder[0]].size()):
			var nodeName : String = "Lap" + str(j + 1) + "Time"
			if (RC_GameManager.lapDictionary[carOrder[i]].size() > j):
				container.get_node(nodeName).text = str(RC_GameManager.lapDictionary[carOrder[i]][j]).pad_decimals(2)
			else:
				container.get_node(nodeName).text = "N/A"
				
	
	#Set scroll container size
	#scrollContainer.size.y = (48 * (carOrder.size() + 1)) + 8
	
	
	#Setup high score entry
	var highScoreRacer : RC_RaceCar = RC_GameManager.player1 if (RC_GameManager.player2 == null or totalRaceTime[RC_GameManager.player1] <= totalRaceTime[RC_GameManager.player2]) else RC_GameManager.player2
	RC_SaveSystem.update_data()
	var currentHighScore : float = RC_SaveSystem.data["HIGHSCORE_" + str(RC_GameManager.lastLevelIndex + 1)]
	#Get high score
	if ((currentHighScore == 0.0 or totalRaceTime[highScoreRacer] < currentHighScore)
	and totalRaceTime[highScoreRacer] < 1000):
		highScoreName = ""
		letterIndex = 1
		highScoreContainer.visible = true
		instructions.visible = true
		#Set winning racer label
		winningRacerLabel.visible = (RC_GameManager.player2 != null)
		winningRacerLabel.text = "Racer 1" if (highScoreRacer == RC_GameManager.player1) else "Racer 2" 
		#Set new high score text
		highScoreTimeLabel.text = str(totalRaceTime[highScoreRacer]).pad_decimals(2)
		#Cache score to save to disk
		highScoreTime = totalRaceTime[highScoreRacer]
	#Hide high score entry
	else:
		highScoreContainer.visible = false
	
	#Save high score
	#if (totalRaceTime[carOrder[0]] < RC_SaveSystem.get_data("HIGHSCORE_1")):
		#RC_SaveSystem.save_data("HIGHSCORE_1_NAME", "TEMP NAME")
		#RC_SaveSystem.save_data("HIGHSCORE_1", totalRaceTime[carOrder[0]])
	
	visible = true
	
	#Start menu music
	RC_SoundManager.play("MenuMusic")


func deactivate():
	#Delete scores
	for i in range(statsContainer.get_child_count()):
		if (i != 0):
			statsContainer.get_child(i).queue_free()
	
	visible = false


func _deactivate_highscore_input():
	if (RC_GameManager.currentScreen != self):
		highScoreName = "null"
		instructions.visible = false


func _main_menu_pressed():
	RC_GameManager.goto_screen("MAIN_MENU")
