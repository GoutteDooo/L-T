extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if get_parent().is_in_group("Lumiere"):
		Global.cam_L = self
		print_debug("caméra détectée pour Lulu")
	if get_parent().is_in_group("Obscurite"):
		Global.cam_H = self
		print_debug("caméra détectée pour Hades")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
