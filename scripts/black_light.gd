extends Area2D


func _on_body_entered(body: Node2D) -> void:
	print("Oui")
	if body.is_in_group("Lumiere"):
		get_tree().call_group("Lumiere", "on_enter_black_light")
		Global.light_array.push_front(self)
	if body.is_in_group("Obscurite"):
		get_tree().call_group("Obscurite", "on_enter_black_light", self)


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Lumiere") and !Global.game_over:
		get_tree().call_group("Lumiere", "on_exit_black_light",self)
		Global.last_light_in = self #Garde en mémoire la dernière light quittée
		#Gérer le tableau des lights de Lulu
		print("EXIT : ", self)
		for i in range(0,Global.light_array.size()):
			print("array size : ", Global.light_array.size())
			print("i : ", i)
			#Vérifie que la light quittée est bien dans le tableau
			if (Global.light_array[i] == self or Global.light_array[i] == null):
				Global.light_array.remove_at(i)
				print("Removed at index : ",i)
				print("BREAK")
				break
			print("light array : ",Global.light_array)
		#Enfin, on vérifie si son tableau est vide, et si tel est le cas, cela veut dire que Lulu n'est plus dans aucune light
		if Global.light_array.size() == 0:
			#On check si la last_light existe encore
			#Si c'est le cas, alors on renvoie Lulu à son origine
			#Sinon, on recommence la partie (Hades a du l'éteindre)
			print("last light in :",Global.last_light_in)
			#await get_tree().create_timer(0.01).timeout #car l'animation "OFF" du mushroom dure 0.2s
			if Global.last_light_in.monitoring:
				print("Lulu est retransférée à la position : ", Global.last_light_in.global_position)
				Global.lulu.position = Global.last_light_in.global_position
				print("Position de lulu : ", Global.lulu.position)
			else:
				print("dernière light quittée inexistante, fin de la partie : ", Global.last_light_in)
				Global.restart_game()
			print("Tableau vide !")
	if body.is_in_group("Obscurite") and !Global.game_over:
		get_tree().call_group("Obscurite", "on_exit_black_light")
