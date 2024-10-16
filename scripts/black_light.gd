extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Lumiere"):
		get_tree().call_group("Lumiere", "on_enter_black_light")
	if body.is_in_group("Obscurite"):
		get_tree().call_group("Obscurite", "on_enter_black_light")


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Lumiere") and !Global.game_over:
		get_tree().call_group("Lumiere", "on_exit_black_light")
	if body.is_in_group("Obscurite") and !Global.game_over:
		get_tree().call_group("Obscurite", "on_exit_black_light")
