@tool
extends Line2D

@onready var _root : RC_Checkpoint = get_parent()
@onready var _spawnLine : Line2D = get_node("SpawnLine")

var _prevLength : float = 0
var _prevSpawnLength : float = 0
var _prevSpawnOffset : float = 0



func _ready():
	if (not Engine.is_editor_hint()):
		queue_free()



func _process(delta):
	if (_root):
		_detect_length_change()
		_detect_spawn_change()


func _detect_length_change():
	if (_prevLength != _root.length):
		_prevLength = _root.length
		points = [Vector2(-_root.length / 2, 0), Vector2(_root.length / 2, 0)]


func _detect_spawn_change():
	#Spawn length change
	if (_prevSpawnLength != _root.spawnLength):
		_prevSpawnLength = _root.spawnLength
		_spawnLine.points = [Vector2(-_root.spawnLength, 0), Vector2(_root.spawnLength, 0)]
		_spawnLine.position.x = ((_root.length / 2) - _root.spawnLength) * _root.spawnOffset
	
	#Spawn offset change
	if (_prevSpawnOffset != _root.spawnOffset):
		_prevSpawnOffset = _root.spawnOffset
		_spawnLine.position.x = ((_root.length / 2) - _root.spawnLength) * _root.spawnOffset
