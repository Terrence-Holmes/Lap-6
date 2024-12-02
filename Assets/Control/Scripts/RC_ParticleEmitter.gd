extends Node2D
class_name RC_ParticleEmitter

@onready var particles : Array[GPUParticles2D]


func _ready():
	for child in get_children():
		if (child is GPUParticles2D):
			particles.append(child)
	
	#Subscribe to pause delegates
	RC_Pause.onPlayerPaused.append(pause)
	RC_Pause.onPlayerUnpaused.append(unpause)



func start_emitting():
	for part in particles:
		part.emitting = true

func stop_emitting():
	for part in particles:
		part.emitting = false


func pause():
	for part in particles:
		part.process_mode = Node.PROCESS_MODE_DISABLED


func unpause():
	for part in particles:
		part.process_mode = Node.PROCESS_MODE_INHERIT
