extends Area2D

@export var lumiere_group = "Lumiere"

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group(lumiere_group):
		get_tree().call_group("Lumiere", "on_enter_checkpoint")
