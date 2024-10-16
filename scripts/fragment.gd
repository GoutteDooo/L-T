extends Area2D


func _on_body_entered(body: Node2D, timer:int = 10) -> void:
	$AnimationPlayer.play("collected")
	Global.counter_click_lumiere += 2
	if body.is_in_group("Lumiere"):
		get_tree().call_group("Lumiere", "on_put_fragment",timer)
