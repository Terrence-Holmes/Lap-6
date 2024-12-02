extends Line2D
class_name RC_Tiremark

const _maxPoints : int = 200

#Timers
const _lifeDuration : float = 10
var _creationTime : float = 0
const _fadeDuration : float = 5
var _fadeTimer : float = _fadeDuration

func _ready():
	RC_Pause.onUnpaused.append(_on_unpause)

func _process(delta):
	if (not RC_Pause.isPaused):
		_timer()
		_set_alpha()

func _timer():
	if (Math.timeout(_lifeDuration, _creationTime)):
		_fadeTimer -= get_process_delta_time()
		if (_fadeTimer <= 0):
			queue_free()


func _set_alpha():
	if (_fadeTimer < _fadeDuration):
		var alpha : float = clampf(_fadeTimer / _fadeDuration, 0, 1)
		modulate = Color(1, 1, 1, alpha)


func create_point(pointPosition : Vector2, pointIndex : int = -1):
	add_point(pointPosition, pointIndex)
	_creationTime = Time.get_ticks_msec()
	
	if (points.size() > _maxPoints):
		remove_point(0)



func _on_unpause():
	_creationTime += Time.get_ticks_msec() - RC_Pause.lastPauseTime
