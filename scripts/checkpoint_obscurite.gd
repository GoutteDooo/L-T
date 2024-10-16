extends Area2D

@export var obscurite_group = "Obscurite"

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group(obscurite_group):
		get_tree().call_group("Obscurite", "on_enter_checkpoint")
