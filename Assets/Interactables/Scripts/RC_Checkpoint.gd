extends Node2D
class_name RC_Checkpoint

@export_category("Checkpoint")
@export var length : float = 256
@export var spawnLength : float = 0
@export_range(-1, 1, 0.01) var spawnOffset : float = 0

var offset : Vector2:
	get:
		return Vector2(((length / 2) - spawnLength) * spawnOffset, 0).rotated(rotation)

var pointA : Vector2:
	get:
		return global_position + (Math.vec3_to_vec2(Math.get_left(transform)) * (length / 2))
var pointB : Vector2:
	get:
		return global_position + (Math.vec3_to_vec2(Math.get_right(transform)) * (length / 2))

var passThroughDirection : Vector2:
	get:
		return Math.vec3_to_vec2(Math.get_down(transform))
