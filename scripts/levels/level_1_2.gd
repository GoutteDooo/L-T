extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#déclarer lulu et hades en global
	Global.lulu = %Lumiere
	Global.hades = %Obscurite
	Global.player_control_O = false
	Global.player_control_L = true
	Global.handle_views(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
