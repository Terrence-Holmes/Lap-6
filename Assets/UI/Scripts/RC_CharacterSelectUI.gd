extends Control
class_name RC_CharacterSelectUI

##References
#Characters
@onready var characterContainer : HBoxContainer = get_node("CharacterContainer")
func get_character_container(characterIndex : int) -> Control:
	return characterContainer.get_child(characterIndex - 1).get_node("Container")
func get_add_character_button(characterIndex : int) -> Button:
	return characterContainer.get_child(characterIndex - 1).get_node("AddCharacter")
func get_character_name_label(characterIndex : int) -> Label:
	return get_character_container(characterIndex).get_node("RacerName")
func get_character_peview(characterIndex : int) -> TextureRect:
	return get_character_container(characterIndex).get_node("RacerPreviewContainer/RacerPreview")
func get_character_peview_color(characterIndex : int) -> TextureRect:
	return get_character_peview(characterIndex).get_node("RacerPreviewColor")
@onready var _p2ControlLabel = get_character_container(2).get_node("ControllerContainer/ControllerLabel")
@onready var _p2ControlButton = get_character_container(2).get_node("ControllerContainer/ControllerButton")
func get_controller_button(characterIndex : int) -> Label:
	return get_character_container(characterIndex).get_node("ControllerContainer/ControllerButton")
func get_difficulty_container(characterIndex : int) -> Label:
	return get_character_container(characterIndex).get_node("DifficultyContainer")
func get_difficulty_label(characterIndex : int) -> Label:
	return get_difficulty_container(characterIndex).get_node("DifficultyLabel")
func get_difficulty_button(characterIndex : int) -> Label:
	return get_difficulty_container(characterIndex).get_node("DifficultyButton")
func get_color_container(characterIndex : int) -> Label:
	return get_character_container(characterIndex).get_node("ColorContainer")
func get_color_preview(characterIndex : int) -> Label:
	return get_color_container(characterIndex).get_node("ColorPreview")
func get_color_button(characterIndex : int) -> Label:
	return get_color_container(characterIndex).get_node("ColorButton")
func get_remove_character_button(characterIndex : int) -> Button:
	return get_character_container(characterIndex).get_node("RemoveButton")
#Map selection
@onready var mapContainer : HBoxContainer = get_node("MapContainer")
@onready var mainMenuButton : Button = mapContainer.get_node("MainMenuContainer/MainMenuButton")
@onready var mapPreview : TextureRect = mapContainer.get_node("MapPreview")
@onready var changeMapButton : Button = mapContainer.get_node("MapSelectContainer/ChangeMapContainer/ChangeMapButton")
@onready var mapNameLabel : Label = mapContainer.get_node("MapSelectContainer/ChangeMapContainer/MapNameLabel")
@onready var playButton : Button = mapContainer.get_node("MapSelectContainer/PlayButton")



func _ready():
	##ATTACH SIGNALS
	
	##Add character
	get_add_character_button(2).connect("pressed", _add_character_pressed.bind(2))
	get_add_character_button(3).connect("pressed", _add_character_pressed.bind(3))
	get_add_character_button(4).connect("pressed", _add_character_pressed.bind(4))
	##Change character controller
	_p2ControlButton.connect("pressed", _p2_control_pressed)
	##Change player color
	get_color_button(1).connect("pressed", _change_color_pressed.bind(1))
	get_color_button(2).connect("pressed", _change_color_pressed.bind(2))
	#default colors
	_set_color(1, 0)
	_set_color(2, 1)
	##Change CPU difficulty
	get_difficulty_button(2).connect("pressed", _change_difficulty_pressed.bind(2))
	get_difficulty_button(3).connect("pressed", _change_difficulty_pressed.bind(3))
	get_difficulty_button(4).connect("pressed", _change_difficulty_pressed.bind(4))
	##Remove character
	get_remove_character_button(2).connect("pressed", _remove_character_pressed.bind(2))
	get_remove_character_button(3).connect("pressed", _remove_character_pressed.bind(3))
	get_remove_character_button(4).connect("pressed", _remove_character_pressed.bind(4))
	##Select track
	changeMapButton.connect("pressed", _select_track_pressed)
	##Main menu
	mainMenuButton.connect("pressed", _main_menu_pressed)
	##Play
	playButton.connect("pressed", _play_pressed)
	
	#Attach button sounds
	var allButtons : Array = [
		get_add_character_button(2),
		get_add_character_button(3),
		get_add_character_button(4),
		_p2ControlButton,
		get_color_button(1),
		get_color_button(2),
		get_difficulty_button(2),
		get_difficulty_button(3),
		get_difficulty_button(4),
		get_remove_character_button(2),
		get_remove_character_button(3),
		get_remove_character_button(4),
		changeMapButton,
		mainMenuButton,
		playButton ]
	#Connect buttons
	for button in allButtons:
		button.connect("mouse_entered", RC_GameManager._button_hovered)
		button.connect("pressed", RC_GameManager._button_pressed)




func _add_character_pressed(characterIndex : int):
	#Set add button visibility
	get_add_character_button(characterIndex).visible = false
	if (characterIndex < 4):
		_activate_add_button(characterIndex + 1)
	#Set character visibility
	get_character_container(characterIndex).visible = true


func _set_p2_control(setToPlayer : bool):
	_p2ControlLabel.text = "PLAYER" if (setToPlayer) else "CPU"
	get_difficulty_container(2).visible = (_p2ControlLabel.text == "CPU")
	#Set color
	get_color_container(2).visible = (_p2ControlLabel.text == "PLAYER")
	var newColorIndex = _colorIndex[1] + 1 if (_colorIndex[0] == _colorIndex[1]) else _colorIndex[1]
	_set_color(2, newColorIndex)

func _p2_control_pressed():
	_set_p2_control(_p2ControlLabel.text == "CPU")




var _colorIndex : Array[int] = [-1, -1]
func _set_color(characterIndex : int, colorIndex : int):
	_colorIndex[characterIndex - 1] = colorIndex
	get_color_preview(characterIndex).self_modulate = RC_Data.colorOptions[_colorIndex[characterIndex - 1]]
	var carColor : Color = Color.WHITE if (characterIndex == 2 and _p2ControlLabel.text == "CPU") else RC_Data.colorOptions[_colorIndex[characterIndex - 1]]
	get_character_peview_color(characterIndex).self_modulate = carColor

func _change_color_pressed(characterIndex : int):
	#Increment color index
	var newColorIndex : int = _colorIndex[characterIndex - 1] + 1 if (_colorIndex[characterIndex - 1] < RC_Data.colorOptions.size() - 1) else 0
	#Increment again if it matches the other player car's color index
	if (characterIndex == 1 and _p2ControlLabel.text == "PLAYER" and newColorIndex == _colorIndex[1]) \
	or (characterIndex == 2 and newColorIndex == _colorIndex[0]):
		newColorIndex = newColorIndex + 1 if (newColorIndex < RC_Data.colorOptions.size() - 1) else 0
	
	_set_color(characterIndex, newColorIndex)


var _difficulty : Array[int] = [1, 1, 1]
const _difficultyText : Array[String] = ["EASY", "MEDIUM", "HARD"]
func _set_difficulty(characterIndex : int, difficulty : int):
	_difficulty[characterIndex - 2] = difficulty
	get_difficulty_label(characterIndex).text = _difficultyText[difficulty]

func _change_difficulty_pressed(characterIndex : int):
	var newDifficulty = _difficulty[characterIndex - 2] + 1 if (_difficulty[characterIndex - 2] < _difficulty.size() - 1) else 0
	_set_difficulty(characterIndex, newDifficulty)


func _remove_character_pressed(characterIndex : int):
	#Shift characters down
	#Copy from character 1 over
	if (characterIndex < 4 and get_character_container(characterIndex + 1).visible):
		_set_difficulty(characterIndex, _difficulty[characterIndex - 2 + 1])
		#Copy from character 2 over
		if (characterIndex < 3 and get_character_container(characterIndex + 2).visible):
			_set_difficulty(characterIndex + 1, _difficulty[characterIndex - 2 + 2])
	
	#Set p2 to CPU
	if (characterIndex == 2):
		_set_p2_control(false)
	
	#Remove the end character
	var characterToRemove : int = 2
	if (get_character_container(4).visible):
		characterToRemove = 4
	elif (get_character_container(3).visible):
		characterToRemove = 3
	
	_set_difficulty(characterToRemove, 1)
	get_character_container(characterToRemove).visible = false
	_activate_add_button(characterToRemove)


var _trackSelection : int = 0
const _trackTexture : Array[Texture2D] = \
[preload("res://Assets/Levels/Sprites/RC_Level1_Background.png"),
preload("res://Assets/Levels/Sprites/RC_Level2_Background.png"),
preload("res://Assets/Levels/Sprites/RC_Level3_Background.png")]
func _set_track(selection : int):
	_trackSelection = selection
	mapPreview.texture = _trackTexture[selection]
	mapNameLabel.text = "TRACK " + str(selection + 1)
func _select_track_pressed():
	var newSelection : int = _trackSelection + 1 if (_trackSelection < _trackTexture.size() - 1) else 0
	_set_track(newSelection)


func _main_menu_pressed():
	RC_GameManager.goto_screen("MAIN_MENU")

func _play_pressed():
	#Get players
	var players : Array[int] = [_colorIndex[0]]
	if (get_character_container(2).visible and _p2ControlLabel.text == "PLAYER"):
		players.append(_colorIndex[1])
	#Get CPUS
	var cpus : Array[int] = []
	if (get_character_container(2).visible and _p2ControlLabel.text == "CPU"):
		cpus.append(_difficulty[0])
	if (get_character_container(3).visible):
		cpus.append(_difficulty[1])
	if (get_character_container(4).visible):
		cpus.append(_difficulty[2])
	
	RC_SoundManager.stop_all_with_bus("Music")
	RC_GameManager.start_level(_trackSelection, players, cpus)


func _activate_add_button(index : int):
	get_add_character_button(2).visible = index == 2
	get_add_character_button(3).visible = index == 3
	get_add_character_button(4).visible = index == 4
