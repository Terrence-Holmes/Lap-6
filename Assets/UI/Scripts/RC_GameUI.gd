extends Control
class_name RC_GameUI

#References
@onready var gameContainer : VBoxContainer = get_node("GameContainer")
@onready var highscoreContainer : VBoxContainer = get_node("HighscoreContainer")
@onready var highscoreLabels : Array[Label] = \
	[highscoreContainer.get_node("Map1Score"),
	highscoreContainer.get_node("Map2Score"),
	highscoreContainer.get_node("Map3Score")]
@onready var racer2Cover : ColorRect = get_node("Racer2Cover")
@onready var highscoreLabel2 : Label = highscoreContainer.get_node("Map2Score")
@onready var highscoreLabel3 : Label = highscoreContainer.get_node("Map3Score")
@onready var placeLabel : Label = gameContainer.get_node("PlaceLabel")
@onready var lapLabel : Label = gameContainer.get_node("LapLabel")
@onready var playerLabel2 : Label = gameContainer.get_node("PlayerLabel2")
@onready var placeLabel2 : Label = gameContainer.get_node("PlaceLabel2")
@onready var lapLabel2 : Label = gameContainer.get_node("LapLabel2")
@onready var timerLabel : Label = gameContainer.get_node("Timer/TimerContainer/TimerLabel")



func _ready():
	RC_GameManager.updateTimerUI = _update_timer_label
	RC_GameManager.updateLapCountUI = _update_lap_label



func _process(delta):
	_update_placing()


func _update_placing():
	if (RC_GameManager.currentLevel != null and RC_GameManager.player1 != null):
		var placing : Array = RC_GameManager.currentLevel.placing
		#Update player 1's placing
		match (placing.find(RC_GameManager.player1)):
			0:
				placeLabel.text = "1st"
			1:
				placeLabel.text = "2nd"
			2:
				placeLabel.text = "3rd"
			3:
				placeLabel.text = "4th"
		#Update player 2's placing
		if (RC_GameManager.player2 != null):
			match (placing.find(RC_GameManager.player2)):
				0:
					placeLabel2.text = "1st"
				1:
					placeLabel2.text = "2nd"
				2:
					placeLabel2.text = "3rd"
				3:
					placeLabel2.text = "4th"



func _update_timer_label():
	var newText : String = str( min(999.99,  (Time.get_ticks_msec() - RC_GameManager.raceStartTime) * 0.001)  ).pad_zeros(2).pad_decimals(2)
	newText = newText.replace(".", ":")
	timerLabel.text = newText


func _update_lap_label():
	lapLabel.text = "LAP  " + str(clampi(RC_GameManager.currentPlayerLap + 1, 1, RC_GameManager.lapsToWin)) + "/" + str(RC_GameManager.lapsToWin)


func set_display(displayName : String):
	if (displayName == "GAMEPLAY"):
		#Make the correct data visible
		highscoreContainer.visible = false
		gameContainer.visible = true
		#Hide/show the race 2 stats
		playerLabel2.visible = (RC_GameManager.player2 != null)
		placeLabel2.visible = (RC_GameManager.player2 != null)
		lapLabel2.visible = (RC_GameManager.player2 != null)
		gameContainer.alignment = BoxContainer.ALIGNMENT_BEGIN if (RC_GameManager.player2 == null) else BoxContainer.ALIGNMENT_CENTER
	elif (displayName == "HIGHSCORE"):
		#Update the highscore board
		RC_SaveSystem.update_data()
		for i in range(3):
			#No highscore set yet; just display 0.00
			if (RC_SaveSystem.data["HIGHSCORE_" + str(snapped(i + 1, 0.01))] == 0.0):
				highscoreLabels[i].text = "0.00"
			#Display highscore
			else:
				highscoreLabels[i].text = \
				RC_SaveSystem.data["HIGHSCORE_" + str(i + 1) + "_NAME"] + " - " + str(RC_SaveSystem.data["HIGHSCORE_" + str(snapped(i + 1, 0.01))]).pad_decimals(2)
		
		#Make the correct data visible
		gameContainer.visible = false
		highscoreContainer.visible = true
