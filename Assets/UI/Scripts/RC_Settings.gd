extends VBoxContainer
class_name RC_Settings

#References
@onready var _fullScreenButton : Button = get_node("FullScreenButton")
@onready var _musicButton : Button = get_node("BusContainer/MusicButton")
@onready var _SFXButton : Button = get_node("BusContainer/SFXButton")
@onready var _volumeAdjust : Panel = get_node("VolumeAdjust")
@onready var _adjustmentContainer : HBoxContainer = get_node("VolumeAdjust/AdjustmentContainer")
var _adjustment_colorRect : Array[ColorRect]:
	get:
		var returnArray : Array[ColorRect] = []
		for child in _adjustmentContainer.get_children():
			if (child is ColorRect):
				returnArray.append(child)
		return returnArray
var _adjustment_button : Array[Button]:
	get:
		var returnArray : Array[Button] = []
		for rect in _adjustment_colorRect:
			if (rect.get_node_or_null("Button") != null):
				returnArray.append(rect.get_node("Button"))
		return returnArray



var _activatedButton : Button = null


# Called when the node enters the scene tree for the first time.
func _ready():
	#Connect buttons
	_musicButton.connect("pressed", _music_pressed)
	_SFXButton.connect("pressed", _sfx_pressed)
	_fullScreenButton.connect("pressed", _full_screen_pressed)
	for i in range(_adjustment_button.size()):
		_adjustment_button[i].connect("pressed", _volume_button_pressed.bind(i))
	
		#Attach button sounds
	var allButtons : Array = [
		_fullScreenButton,
		_musicButton,
		_SFXButton]
	for adjustmentButton in _adjustment_button:
		allButtons.append(adjustmentButton)
	#Connect buttons
	for button in allButtons:
		button.connect("mouse_entered", RC_GameManager._button_hovered)
		button.connect("pressed", RC_GameManager._button_pressed)
	
	#Subscribe to delegates
	RC_GameManager.onGotoScreen.append(_deactivate_volumeAdjust)
	RC_GameManager.onGotoScreen.append(_update_icons)


func _input(event):
	if (event is InputEventMouseButton
	and not Math.is_in_area(get_global_mouse_position(), Rect2(_volumeAdjust.global_position.x, _volumeAdjust.global_position.y, _volumeAdjust.size.x, _volumeAdjust.size.y)) ):
		_deactivate_volumeAdjust()



func _full_screen_pressed():
	if (DisplayServer.window_get_mode(0) == DisplayServer.WINDOW_MODE_FULLSCREEN):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)



func _music_pressed():
	#Activate
	if (_activatedButton != _musicButton):
		_activatedButton = _musicButton
		_set_volume_buttons(RC_SoundManager.musicVolume)
		_volumeAdjust.visible = true
		_musicButton.get_node("Highlight").visible = true
		_SFXButton.get_node("Highlight").visible = false
	#Deactivate
	else:
		_deactivate_volumeAdjust()


func _sfx_pressed():
	#Activate
	if (_activatedButton != _SFXButton):
		_activatedButton = _SFXButton
		_set_volume_buttons(RC_SoundManager.sfxVolume)
		_volumeAdjust.visible = true
		_musicButton.get_node("Highlight").visible = false
		_SFXButton.get_node("Highlight").visible = true
	#Deactivate
	else:
		_deactivate_volumeAdjust()



func _volume_button_pressed(index : int):
	#Music
	if (_activatedButton == _musicButton):
		RC_SoundManager.musicVolume = index
		_set_volume_buttons(RC_SoundManager.musicVolume)
		RC_SoundManager.set_bus_volume("Music", RC_SoundManager.musicVolume)
	#SFX
	elif (_activatedButton == _SFXButton):
		RC_SoundManager.sfxVolume = index
		_set_volume_buttons(RC_SoundManager.sfxVolume)
		RC_SoundManager.set_bus_volume("SFX", RC_SoundManager.sfxVolume)
	else:
		_deactivate_volumeAdjust()
	_update_icons()


func _set_volume_buttons(volume : int):
	for i in range(_adjustment_colorRect.size()):
		#Highlight volume node
		if (volume >= i):
			_adjustment_colorRect[i].color = Color8(252, 244, 0)
		#Unhighlight volume node
		else:
			_adjustment_colorRect[i].color = Color8(0, 0, 0)


func _deactivate_volumeAdjust():
	_musicButton.get_node("Highlight").visible = false
	_SFXButton.get_node("Highlight").visible = false
	_volumeAdjust.visible = false
	_activatedButton = null


func _update_icons():
	_musicButton.icon = RC_Data.musicIcons[0] if (RC_SoundManager.musicVolume > 0) else RC_Data.musicIcons[1]
	_SFXButton.icon = RC_Data.sfxIcons[0] if (RC_SoundManager.sfxVolume > 0) else RC_Data.sfxIcons[1]
