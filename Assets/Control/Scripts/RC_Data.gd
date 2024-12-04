class_name RC_Data

##Racecar
const racecarPrefab : PackedScene = preload("res://Assets/Driver/Scenes/rc_race_car.tscn")
const tiremarkPrefab : PackedScene = preload("res://Assets/Driver/Scenes/rc_tiremark.tscn")
##Racecar colors
const colorOptions : Array[Color] = [
	Color8(255, 100, 0),
	Color8(0, 173, 233),
	Color8(252, 244, 0),
	Color8(240, 2, 133)]

##Levels
const levelScript = preload("res://Assets/Levels/Scripts/RC_Level.gd")
const levelPaths : Array[String] = [
	"res://Assets/Levels/Scenes/rc_level1.tscn",
	"res://Assets/Levels/Scenes/rc_level2.tscn",
	"res://Assets/Levels/Scenes/rc_level3.tscn"]
static var levelPrefabs : Array[PackedScene] = []

##UI
const characterSelectPrefab : PackedScene = preload("res://Assets/UI/Scenes/rc_character_select_ui.tscn")
const musicIcons : Array[Texture2D] = [
	preload("res://Assets/UI/Sprites/RC_Music-On.png"),
	preload("res://Assets/UI/Sprites/RC_Music-Off.png")]
const sfxIcons : Array[Texture2D] = [
	preload("res://Assets/UI/Sprites/RC_SFX-On.png"),
	preload("res://Assets/UI/Sprites/RC_SFX-Off.png")]

##AI Data
const AIDataFilepath : String = "res://Assets/Driver/AIData/"
#The maximum amount of time (in seconds) to complete the race before the AI is set in a higher bracket.
# x = Easy's maximum time, y = Medium's maximum time
const difficultyMaxTime : Array[Vector2] = [
	Vector2(40.0, 45.0),
	Vector2(50.0, 55.0),
	Vector2(70.0, 75.0)]


##High score name entry
const nameEntryLetters : Array[String] = [ "_",
	"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
	"N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
