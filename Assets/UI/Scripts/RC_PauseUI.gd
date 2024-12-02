extends Control
class_name RC_PauseUI

#References
@onready var _mainContainer : VBoxContainer = get_node("MainContainer")
@onready var _continueButton : Button = _mainContainer.get_node("ContinueButton")
@onready var _mainMenuButton : Button = _mainContainer.get_node("MainMenuButton")
@onready var _quitButton : Button = _mainContainer.get_node("QuitButton")



func _ready():
	visible = false
	
	#Connect buttons
	_continueButton.connect("pressed", _continue_pressed)
	_mainMenuButton.connect("pressed", _main_menu_pressed)
	_quitButton.connect("pressed", _quit_pressed)
	
	#Attach button sounds
	var allButtons : Array = [
		_continueButton,
		_mainMenuButton, ]
	#Connect buttons
	for button in allButtons:
		button.connect("mouse_entered", RC_GameManager._button_hovered)
	_mainMenuButton.connect("pressed", RC_GameManager._button_pressed)
	
	#Subscribe to delegates
	RC_Pause.onPlayerPaused.append(_on_paused)
	RC_Pause.onPlayerUnpaused.append(_on_unpaused)
	RC_GameManager.onGotoScreen.append(_on_goto_screen)





func _on_paused():
	visible = true
	RC_SoundManager.play("Pause", true)


func _on_unpaused():
	visible = false
	RC_SoundManager.play("Unpause", true)




func _continue_pressed():
	RC_Pause.set_pause(RC_Pause.PauseState.PLAYER_PAUSED, false)

func _main_menu_pressed():
	RC_GameManager.goto_screen("MAIN_MENU")
	RC_SoundManager.stop_all_with_bus("SFX")
	RC_SoundManager.play("MenuMusic")

func _quit_pressed():
	get_tree().quit()


func _on_goto_screen():
	RC_Pause.set_pause(RC_Pause.PauseState.PLAYER_PAUSED, false)
