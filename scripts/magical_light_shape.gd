extends Node2D

@onready var magicLoopSound = Global.magic_loop_sound


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	#When Player press 'E', shape of magical light appears
	if Input.is_action_pressed("magic_lumiere") and Global.cam_L.enabled:
		global_position = get_global_mouse_position()
		if magicLoopSound.playing:
			pass
		else:
			magicLoopSound.play()
		
	else:
		#print("fin shape")
		global_position = Vector2(-250,-250)
		#magicLoopSound.stop()
