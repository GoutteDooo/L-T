extends Area2D

func _on_body_entered(body: Node2D) -> void:
	%AnimationPlayer.play("collected")
	Global.counter_click_lumiere += 1
	print(Global.counter_click_lumiere)
