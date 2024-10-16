extends Area2D


@export var lumiere_group = "Lumiere"
@export var obscurite_group = "Obscurite"


func _process(delta: float) -> void:
		if !Global.player_control_L && !Global.player_control_O:
			set_process_input(false)
		else:
			set_process_input(true)


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	
	#--- OBSCURITE ---
	
	#éteindre une light avec clic droit
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		return
		print("magic light off s'est joué !!")
		if Global.counter_click_obscurite > 0:
			Global.counter_click_obscurite -= 1
			#fait disparaître la light
			queue_free()
			print("magic light : désactivé")
			#jouer le son magie
			
			#DEBUG
			#print("light éteinte, compteur d'Obs : ", Global.counter_click_obscurite)
		else:
			#plus de magie, on joue juste le son
			Global.no_magic_yet_sound.play()
		#A résoudre ! Lorsque clic droit sur 2 lights, les 2 s'éteignent ! Je n'en veux qu'une seule ! 
		# (Mais elles s'allumeront via les instances, donc peut-être que finalement je n'aurais pas besoin)
	


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group(lumiere_group):
		get_tree().call_group("Lumiere", "on_enter_light")
		
	if body.is_in_group(obscurite_group):
		get_tree().call_group("Obscurite", "on_enter_light")


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group(lumiere_group) and !Global.game_over:
		get_tree().call_group("Lumiere", "on_exit_light")
