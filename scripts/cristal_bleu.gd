extends Area2D



func _on_body_entered(body: Node2D) -> void:
	%AnimationPlayer.play("collected")
	Global.counter_click_lumiere += 1
	print(Global.counter_click_lumiere)
	
	#Appeler la fonction "put_ML_on" pendant une certaine durée
	if body.is_in_group("Lumiere"):
		get_tree().call_group("Lumiere", "on_put_cristal")
