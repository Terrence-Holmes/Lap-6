extends Control

@onready var countdownLabel : Label = get_node("CountdownLabel")
@onready var gameEndLabel : Label = get_node("GameEndLabel")
@onready var animationPlayer : AnimationPlayer = get_node("AnimationPlayer")


var _paused_animation : String = ""



func _ready():
	#Make sure label is hidden
	countdownLabel.visible = false
	gameEndLabel.visible = false
	#Assign to callables
	RC_GameManager.beginCountdownUI = _begin_countdown_timer
	
	
	#Assign to delegates
	RC_Pause.onPlayerPaused.append(_on_paused)
	RC_Pause.onPlayerUnpaused.append(_on_unpaused)
	RC_GameManager.onGotoScreen.append(_on_goto_screen)


func _process(delta):
	_update_end_timer()

func _update_end_timer():
	if (RC_GameManager.raceEndTimer >= 0 and RC_GameManager.lapDictionary.size() > 1):
		gameEndLabel.visible = true
		gameEndLabel.text = "RACE ENDS IN: " + str(floori( RC_GameManager.raceEndTimerDuration - RC_GameManager.raceEndTimer ))
	else:
		gameEndLabel.visible = false



func _begin_countdown_timer():
	animationPlayer.play("BeginCountdown")


func _play_sound(soundName : String):
	RC_SoundManager.play(soundName, true)


func _on_paused():
	if (animationPlayer.is_playing()):
		_paused_animation = animationPlayer.current_animation
		animationPlayer.pause()

func _on_unpaused():
	if (_paused_animation != ""):
		animationPlayer.play(_paused_animation)
		_paused_animation = ""


func _on_goto_screen():
	_paused_animation = ""
	animationPlayer.stop()
