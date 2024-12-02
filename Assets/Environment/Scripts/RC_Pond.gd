extends StaticBody2D

@export_category("Pond")
@export var edgeThicknessCurve : Curve = null

@onready var polygon : Polygon2D = get_node("Polygon")
@onready var edge : Line2D = get_node("Edge")
@onready var collisionShape : CollisionPolygon2D = get_node("CollisionShape")

var edgeThicknessRange : Vector2 = Vector2(1, 3)
var edgeThicknessT : float = 0
var edgeThicknessChangeSpeed : float = 1

var shaderTime : float = 0

func _ready():
	collisionShape.polygon = polygon.polygon
	edge.points = polygon.polygon

var test : float = 0
func _process(delta):
	_set_edge_thickness()
	_set_shader_time()
	


func _set_edge_thickness():
	if (not RC_Pause.get_pause(RC_Pause.PauseState.PLAYER_PAUSED)):
		edgeThicknessT += get_process_delta_time()
		edge.width = lerpf(edgeThicknessRange.x, edgeThicknessRange.y, Math.sine_wave(edgeThicknessT, edgeThicknessChangeSpeed))


func _set_shader_time():
	if (not RC_Pause.get_pause(RC_Pause.PauseState.PLAYER_PAUSED)):
		shaderTime += get_process_delta_time()
		polygon.material.set_shader_parameter("time", shaderTime)
