extends CharacterBody2D

#variable de test
var levier_test = false
const light_pushing = 50 #en px

#constantes
const SPEED = 170.0
const JUMP_VELOCITY = -400.0
const GRAVITY = 1000
const FALL_GRAVITY = 1200
#states
enum anim_States {PLAYING, IDLE2, STUCK, RUNNING}
var animation_state: anim_States = anim_States.PLAYING
enum MecaStates {ON, OFF}
var meca_state: MecaStates = MecaStates.ON


#sprite
@onready var animated_sprite = $AnimatedSprite2D

#variables mecaniques
var isPlayingMagic = false
var compteur_lights_Lumiere = 0 #compteur pour savoir si Lumiere n'est plus dans aucune collisionShape de lights
var hasFinished = false #pour placer le perso immobile qd il a atteint le xpoint
var l_click_position = Vector2()
var direction = 0
var fragment_is_put = false
	#variables importantes pour que lului reste dans les lights
const pas_when_darkness = 10 #le nombre de pas a calculer pour l'animation quand lulu touche les ténèbres
var pas = Vector2() #le pas pour revenir au centre de la light
var lulu_entered_darkness = false #levier permettant de jouer le process
var counter_pas = 0 #compteur permettant de réaliser le bon nombre de pas
var exiting_light_pos = Vector2()

#coyote jump
@export var coyote_time = 0.2
@onready var coyote_timer: Timer = $Coyote_Timer
var jump_available = true

#sons
@export var sfx_L_footsteps : AudioStream
@export var sfx_L_jump : AudioStream
@export var sfx_L_magic_charge : AudioStream

#variables sons
var footstep_frames : Array = [0,4]

#preloads
var light = preload("res://scenes/objects/magic_light.tscn")


func _ready() -> void:
	pass
	
func _get_gravity(velocity: Vector2):
	if velocity.y < 0:
		return GRAVITY
	return FALL_GRAVITY
	

func _physics_process(delta: float) -> void:
	#si la partie est terminée, aucun déplacement possible
	if Global.game_over:
		#tant qu'on est game over
		%AnimationPlayer.play("lose");
		#plus de controle du personnage, il tombe au sol
		velocity.x = 0
		velocity.y = GRAVITY
	else:
		#Si le joueur n'a pas le contrôle, on stoppe le process
		if !Global.player_control_L:
			velocity = Vector2(0,300)
			#désactiver la range si elle était activée pendant l'arrêt du contrôle player
			if %Range.monitoring == true:
				%Range.monitoring = false
				%Range.visible = false
				isPlayingMagic = false
			
		else:
			
			Handle_jump(delta)
			
			#input direction : -1, 0, 1
			direction = Input.get_axis("move_lumiere_left", "move_lumiere_right")
			
			# Handle magic.
			Handle_magic()
			
			#flip the sprite
			if direction > 0:
				animated_sprite.flip_h = false
			elif direction < 0:
				animated_sprite.flip_h = true
				
			#animations
			if is_on_floor():
				if isPlayingMagic:
					#stopper le déplacement pendant le sort
					direction = 0
					#jouer le son magic charge
					if Global.magic_loop_sound.playing:
						pass
					else:
						Global.magic_loop_sound.play()
					#print("isPlayingMagic, process : ", isPlayingMagic)
				else:
					#print("isPlayingMagic, process : ", isPlayingMagic)
					if direction == 0 and animation_state == anim_States.PLAYING:
						animated_sprite.play("idle")
					elif animation_state == anim_States.RUNNING:
						animated_sprite.play("run")
				
			else:
				#ne joue l'animation jump qu'une seule fois
				if not animated_sprite.is_playing() or animated_sprite.animation != "jump":
					animated_sprite.play("jump")
			
			if direction and !hasFinished:
				velocity.x = direction * SPEED
				animation_state = anim_States.RUNNING
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)
				if animation_state == anim_States.RUNNING:
					animation_state = anim_States.PLAYING
			
			
			create_light()
			
			
		
	##POUR LA BULLE DE BLACK LIGHT :
	##PERMET DE JOUER L'ANIMATION DE CLIGNOTEMENT PEU IMPORTE LE TEMPS DEFINI
	if $Fragment_Timer.time_left <= 10 and fragment_is_put:
		fragment_is_put = false
		play_BL_clignote()
		
	##Lorsque Lulu entre dans les ténèbres via sa collisionShape
	#if lulu_entered_darkness:
		#Global.player_control_L = false
		#print("pas : ", pas)
		#position -= pas
		#counter_pas +=1
		#print("counter pas : ", counter_pas)
		#if counter_pas >= pas_when_darkness:
			#Global.player_control_L = true
			#counter_pas = 0
			#lulu_entered_darkness = false 
			##Si Lulu est encore dans les ténèbres
			#if compteur_lights_Lumiere <= 0:
				#await get_tree().create_timer(0.5).timeout
				#if compteur_lights_Lumiere <= 0: #si après le timer, Lulu est toujours dans les ténèbres (évite de trop spam Lulu au centre)
					#position = exiting_light_pos
	#Je dois réactiver la shape une fois le process relancé car sinon Lulu ne se déplacera pas car cela agira comme si que la shape n'avait pas changé d'état
	#Calculer si Lulu est stuck dans un tileset
	if %DetectStuckDown.is_colliding():
		animation_state = anim_States.STUCK
		print("Lulu STUCK DOWN ! State : ",animation_state)
		position.y -= 1
		#print_debug("colliding down ! position y : ", position.y)
		print_debug("état de la shape:  ", $CollisionShape.disabled)
	elif %DetectStuckUp.is_colliding():
		position.y += 1
		animation_state = anim_States.STUCK
		print("Lulu STUCK UP ! State : ",animation_state)
		#print("colliding up ! go DOWN")
	
	is_in_shadow()
	
	##TEST BOUNCING IN LIGHT
	#if !%DetectDarknessDown.is_colliding():
		#position.y += light_pushing
	#if !%DetectDarknessLeft.is_colliding():
		#position.x -= light_pushing
	#if !%DetectDarknessUp.is_colliding():
		#position.y -= light_pushing
	#if !%DetectDarknessRight.is_colliding():
		#position.x += light_pushing
	
	#vérifie constamment que Lulu est bien dans une light, sinon la kill
	#if Global.light_array.size() <= 0:
		#print("TABLEAU LIGHT VIDE !")
		#await get_tree().create_timer(0.1).timeout #le compteur agit comme une sécurité au début des lvls
		#if compteur_lights_Lumiere <= 0:#ca veut dire que Lulu est dans le noir
			#Global.restart_game()
	
	
	#Que le joueur ait les controles ou pas, on joue le move_and_slide()
	if meca_state == MecaStates.ON and animation_state == anim_States.PLAYING or animation_state == anim_States.IDLE2 or animation_state == anim_States.RUNNING:
		move_and_slide()
	elif animation_state == anim_States.STUCK:
		print("! Lulu est stuck !")
		pass
	elif meca_state == MecaStates.OFF:
		#print("Lulu est off !")
		animated_sprite.play("idle")

func Coyote_timeout() -> void:
	jump_available = false
	

func Handle_jump(delta : float) -> void:
			# Add the gravity.
			if not is_on_floor():
				if jump_available:
					if coyote_timer.is_stopped():
						coyote_timer.start(coyote_time)
				velocity.y += _get_gravity(velocity) * delta
			else:
				jump_available = true
				coyote_timer.stop()
				
			if Input.is_action_just_released("jump_lumiere") and velocity.y < 0:
				#si joueur relache la touche, le saut s'arrête
				velocity.y = JUMP_VELOCITY / 4

			# Handle jump.
			if Input.is_action_just_pressed("jump_lumiere") and jump_available and !isPlayingMagic and !hasFinished:
				#jouer le son du jump
				load_sfx(sfx_L_jump)
				%sfx_player.play()
				
				#gére la vélocité du jump
				velocity.y = JUMP_VELOCITY
				jump_available = false


func Handle_magic() -> void:
			if Input.is_action_just_pressed("magic_lumiere") and is_on_floor():
				#levier contrôlant l'animation
				isPlayingMagic = true
				#on déclenche l'animation magic
				animated_sprite.play("magic_start")
				#Range est on
				%Range.monitoring = true
				%Range.visible = true
				
				
			if Input.is_action_just_released("magic_lumiere"):
				#Si joueur a relaché la touche 'E', on termine l'animation magic
				#A la fin de l'anim, on relance idle dans la fonction end_anim
				animated_sprite.play("magic_end")
				#Range est off
				%Range.monitoring = false
				%Range.visible = false
	


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "jump":
		animated_sprite.stop()
		
	if animated_sprite.animation == "magic_start":
		animated_sprite.play("magic_loop")
		
	if animated_sprite.animation == "magic_end":
		isPlayingMagic = false
		#DEBUG
		#print("isPlayingMagic, fin anim : ", isPlayingMagic)
	#Lorsque clignement des yeux finis, on retourne à idle original
	if animated_sprite.animation == "idle_2":
		#print("fin idle2!")
		animated_sprite.animation = "idle"
		animation_state = anim_States.PLAYING


#Lorsque Lumiere enter une light, son compteur s'incrémente
func on_enter_light() -> void:
	compteur_lights_Lumiere += 1
	#print("compteur Lumiere (enter): ", compteur_lights_Lumiere)
	
	
#Lorsque Lumiere enter une light, son compteur s'incrémente
func on_enter_black_light() -> void:
	on_enter_light()
	animated_sprite.light_mask = 2
	#Pour la BL, problèmes de bugs
	#désactive la ML si elle est déjà activée
	if %ML.monitoring == true && %BL.visible == true:
		%ML.monitoring = false
		%ML.visible = false
		print("monitoring ML off")
	

#Lorsque Lumiere quitte la black_light, son light_mask se remet à sa valeur par défaut
func on_exit_black_light(black_light:Area2D) -> void:
	on_exit_light(black_light)
	animated_sprite.light_mask = 7
	print("light mask :", animated_sprite.light_mask)


#Lorsque Lumiere quitte une light & qu'elle n'est pas dans une autre light, c'est game over.
func on_exit_light(light: Area2D) -> void:
	compteur_lights_Lumiere -= 1
	print("compteur Lumiere (exit) : ", compteur_lights_Lumiere)
	if compteur_lights_Lumiere <= 0:
		#DEBUG
		print("Lumiere is in darknesses")
		#TEST
		#déclenche l'animation dans process
		#lulu_entered_darkness = true
		##définir le pas pour l'animation de rebondissement
		#exiting_light_pos = light.global_position        
		#pas = (position - light.global_position) / pas_when_darkness
		#
		##vérifie la position de Lulu dans l'espace par rapport au centre de la light
		#var rebond = (position - exiting_light_pos) * 0.33
		#position = position - rebond
		
		
		
		#Global.restart_game()
		
#Lorsque Lumiere atteint son Checkpoint
func on_enter_checkpoint() -> void:
	#DEBUG
	print("Lumiere a atteint le Xpoint ! Le counter_level est à : ", Global.counter_level)
	compteur_lights_Lumiere += 1
	Global.detectVictory +=1
	hasFinished = true
	Global.lumiere_control(false)
	
	# Accéder à la forme de collision du checkpoint
	var checkpoint_lumiere = %Checkpoint_Lumiere.get_node("CollisionShape2D")
	if checkpoint_lumiere:
		var shape = checkpoint_lumiere.shape  # Récupère la forme du CollisionShape2D
		# Calculer le centre du checkpoint en fonction de la taille de la forme
		var shape_size = shape.extents * 2  # Récupère la taille de la forme
		position.x = %Checkpoint_Lumiere.position.x + shape_size.x / 2
		position.y = %Checkpoint_Lumiere.position.y + shape_size.y
			
		
	#detecter la victoire
	if Global.detectVictory == 2:
		Global.victory()
	else:
		#play sound checkpoint
		Global.checkpoint_sound.play()

func load_sfx(sfx_to_load):
	if %sfx_player.stream != sfx_to_load:
		%sfx_player.stop()
		%sfx_player.stream = sfx_to_load


func _play_run_animation() -> void:
	animated_sprite.animation = "run"
	
func _play_idle_animation() -> void:
	animated_sprite.animation = "idle"
	
func _flip_sprite() -> void:
	animated_sprite.flip_h = !animated_sprite.flip_h

func _on_animated_sprite_2d_frame_changed() -> void:
	#Animation clignement yeux aléatoire
	if animated_sprite.animation == "idle" and animated_sprite.frame == 2:
		var rng = randf()
		if rng > 0.8:
			#print("lancement idle2 ! Ancien animation_state : ", animation_state)
			animation_state = anim_States.IDLE2
			#print("state actuel : ",animation_state)
			animated_sprite.animation = "idle_2"
	if animated_sprite.animation == "jump": return
	if animated_sprite.animation == "magic_end": return
	if animated_sprite.animation == "magic_loop": return
	if animated_sprite.animation == "magic_start": return
	if animated_sprite.animation == "lose": return
	if animated_sprite.animation == "run":
		load_sfx(sfx_L_footsteps)
		if animated_sprite.frame in footstep_frames: %sfx_player.play()
	


func create_light() -> void:
	# --- LUMIERE ---
	
	#Fait apparaître une light avec clic gauche
	if Input.is_action_just_pressed("left_click"):
		if Global.counter_click_lumiere > 0:
			return
			print("ALERT : lumiere left click played !!!")
			#Global.counter_click_lumiere -= 1
			#print("click restants lumière : ", Global.counter_click_lumiere)
			#l_click_position = get_global_mouse_position()
			#
			##crée l'instance de la light
			#var light_instance = light.instantiate()
			#light_instance.scale = Vector2(0.5,0.5)
			#
			## Obtenir le nœud principal de la scène actuelle (Main Node)
			#var main_node = get_tree().current_scene
			#
			#
			##--- Vérifier si on a pas cliqué sur un mushroom ou une instance particulière ---
			#var query = PhysicsPointQueryParameters2D.new()
			#query.position = l_click_position
			#
			## Activer la détection des Area2D car false par défaut dans la doc
			#query.collide_with_areas = true
			#
			#var space_state = get_world_2d().direct_space_state
			#
			#var result = space_state.intersect_point(query, 4)
			#
			##Avant de vérifier si on a cliqué sur une instance particulière, on add la light au main node
			##important pour avoir de bons résultats de positions
			## Ajouter l'instance au nœud Main
			#main_node.add_child(light_instance)
			#
			## Positionner l'instance à la position du clic
			#light_instance.global_position = l_click_position
			#
			##Vérifier si on a cliqué sur un lighter, et, le cas échéant, modifier la scale et la color
			#for hit in result:
				#if hit.collider.is_in_group("lighters"):
					##DEBUG
					##print("scale du mush:", hit.collider.scale)
					#var collision_shape = hit.collider.get_node("%AllumerMush")
					#if collision_shape:
						#light_instance.scale = hit.collider.scale * 0.4
						##DEBUG
						##print("scale de la light : ", light_instance.scale)
						#light_instance.modulate = Color(1, 1, 0)  # Jaune
						#
						## Positionner l'instance à la position du lighter
						#light_instance.global_position = collision_shape.global_position
						##DEBUG
						##print("lighters trouvé")
			#
			##jouer le son magie
			#Global.magic_lumiere_sound.play()
			
			#DEBUG
			#print("light placée. Compteur de Lumiere : ", Global.counter_click_lumiere)
		else:
			return
			print("ALERT : lumiere left click played !!!")
			Global.no_magic_yet_sound.play()
			#DEBUG
			#print("plus de magie pour Lumiere")

func on_put_cristal() -> void:
	$Cristal_Timer.start()
	%ML.monitoring = true
	%ML.visible = true
	
	if %AnimationPlayer.is_playing():
		%AnimationPlayer.stop()
		
	%AnimationPlayer.play("ML_clignote")

func _on_cristal_timer_timeout() -> void:
	%ML.monitoring = false
	%ML.visible = false

func on_put_fragment(time: int = 10) -> void:
	print("onputfragment called with timer of : ", time)
	fragment_is_put = true
	%AnimationPlayer.play("put_on_BL")
	$Fragment_Timer.wait_time = time
	$Fragment_Timer.start()
	%BL.monitoring = true
	%BL.visible = true
	
	
func play_BL_clignote() -> void:
	%AnimationPlayer.play("BL_Clignote")

func _on_fragment_timer_timeout() -> void:
	%BL.monitoring = false
	%BL.visible = false
	
#Dés qu'on détecte un lighters entrant dans la range, on lui turn sa variable can_magic_light to true, il sera allumable
#Dés que cette instance quitte la range, on turn sa variable to false. Il ne sera plus allumable.
func _on_range_area_entered(area: Area2D) -> void:
	if area.is_in_group("lighters"):
		print(area, " entré.")
		area.can_magic_light = true

func _on_range_area_exited(area: Area2D) -> void:
	if area.is_in_group("lighters"):
		print(area, " sorti.")
		area.can_magic_light = false

func is_in_shadow() -> void:
	##Check a chaque instant avec process si Lulu est dans les ténèbres
	##dans ce cas, restart la partie ou go centre ancienne light
	pass
	
