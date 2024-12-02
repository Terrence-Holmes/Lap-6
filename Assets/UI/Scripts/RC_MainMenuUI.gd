extends Control
class_name RC_MainMenuUI


@onready var mainContainer : VBoxContainer = get_node("MenuContainer")
@onready var playButton : Button = mainContainer.get_node("PlayButton")
@onready var controlsButton : Button = mainContainer.get_node("ControlsButton")
@onready var quitButton : Button = mainContainer.get_node("QuitButton")
#@onready var fullScreenButton : Button = get_node("FullScreenButton")
@onready var settings : Control = get_node("Settings")
@onready var controlScreen : Control = get_node("ControlScreen")
@onready var controlBackButton : Button = controlScreen.get_node("BackButton")
@onready var startupAnimation : AnimationPlayer = get_node("StartupAnimation/AnimationPlayer")
@onready var title : Control = get_node("StartupAnimation/Title")

func _ready():
	playButton.connect("pressed", _play_pressed)
	controlsButton.connect("pressed", _controls_pressed)
	quitButton.connect("pressed", _quit_pressed)
	#fullScreenButton.connect("pressed", _full_screen_pressed)
	controlBackButton.connect("pressed", _control_back_pressed)
	
	#Attach button sounds
	var allButtons : Array = [
		playButton,
		controlsButton,
		quitButton,
		#fullScreenButton,
		controlBackButton ]
	#Connect buttons
	for button in allButtons:
		button.connect("mouse_entered", RC_GameManager._button_hovered)
		button.connect("pressed", RC_GameManager._button_pressed)
	
	#Play startup animation
	startupAnimation.play("Startup")


func _play_pressed():
	RC_GameManager.goto_screen("CHARACTER_SELECT")

func _controls_pressed():
	mainContainer.visible = false
	settings.visible = false
	title.visible = false
	controlScreen.visible = true

func _control_back_pressed():
	controlScreen.visible = false
	mainContainer.visible = true
	settings.visible = true
	title.visible = true

func _quit_pressed():
	get_tree().quit()




func _play_startup_sound():
	RC_SoundManager.play("Startup", true)


func _start_menu_music():
	if (RC_GameManager.currentLevel == null):
		RC_SoundManager.play("MenuMusic", true)
