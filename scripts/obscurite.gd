extends CharacterBody2D

#constantes
const SPEED = 170.0
const JUMP_VELOCITY = -400.0
const GRAVITY = 1000
const FALL_GRAVITY = 1200

#sprite animation
@onready var animated_sprite = $AnimatedSprite2D

#variables mecaniques
var isPlayingMagic = false
var isInDarkness = true
var hasFinished = false
	#coyote jump
@export var coyote_time = 0.1
@onready var coyote_timer: Timer = $Coyote_Timer
var jump_available = true
	#collision avec light
var collides_with_light = false #levier permettant de lever/actionner le process
var diff_x = 0 #permettra de connaître dans quelle direction Hades rebondira
var counter_in_light = 0 #compteur permettant de savoir si Hades collides dynamiquement avec une light

#sons
@export var sfx_O_footsteps : AudioStream
@export var sfx_O_jump : AudioStream
@export var sfx_O_magic_loop : AudioStream

#variables sons
var footstep_frames : Array = [0,4]

func _get_gravity(velocity: Vector2):
	if velocity.y < 0:
		return GRAVITY
	return FALL_GRAVITY
	
func _process(delta: float) -> void:
	#juste pour récupérer le contrôle car pas possible via physics process sinon
	if Global.player_control_O:
		set_physics_process(true)
		
func _physics_process(delta: float) -> void:
	#si la partie est terminée, aucun déplacement possible
	if Global.game_over:
		#tant qu'on est game over
		#animated_sprite.play("lose")
		%AnimationPlayer.play("lose")
		velocity.y  = -JUMP_VELOCITY
		velocity.x = 0
		
	else:
		#Si le joueur n'a pas le contrôle, on stoppe le process
		if !Global.player_control_O:
			velocity = Vector2(0,300)
			
			#désactiver la range si elle était activée pendant l'arrêt du contrôle player
			if %Range.monitoring == true:
				%Range.monitoring = false
				%Range.visible = false
				isPlayingMagic = false
			
		#else:
		# Add the gravity.
		if not is_on_floor():
			if jump_available:
				if coyote_timer.is_stopped():
					coyote_timer.start(coyote_time)
			velocity.y += _get_gravity(velocity) * delta
		else:
			jump_available = true
			coyote_timer.stop()
			
		if Input.is_action_just_released("jump_obscurite") and velocity.y < 0 and Global.player_control_O:
			velocity.y = JUMP_VELOCITY / 4
			print("hades jump")

		# Handle jump.
		if Input.is_action_just_pressed("jump_obscurite") and jump_available and !hasFinished and !isPlayingMagic and Global.player_control_O:
			#jouer le son du jump
			load_sfx(sfx_O_jump)
			%sfx_player.play()
			
			#gére la vélocité du jump
			velocity.y = JUMP_VELOCITY
			jump_available = false

		if Global.player_control_O:
			#input direction : -1, 0, 1
			var direction := Input.get_axis("move_obscurite_left", "move_obscurite_right")
			
			# Handle magic.
			if Input.is_action_just_pressed("magic_obscurite") and is_on_floor():
				isPlayingMagic = true
				animated_sprite.play("magic_loop")
				
				#Ouvrir la range
				%Range.monitoring = true
				%Range.visible = true
			
			if Input.is_action_just_released("magic_obscurite"):
				#Fermer la range
				%Range.monitoring = false
				%Range.visible = false
				animated_sprite.play("magic_end")
				
				
				
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
					if Global.magic_loop_hades_sound.playing:
						pass
					else:
						Global.magic_loop_hades_sound.play()
					
				else:
					if direction == 0:
						animated_sprite.play("idle")
					else:
						animated_sprite.play("run")
				
			else:
				#ne joue l'animation jump qu'une seule fois
				if not animated_sprite.is_playing() or animated_sprite.animation != "jump":
					animated_sprite.play("jump")
			
			if direction and !hasFinished:
				velocity.x = direction * SPEED
				
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)
				
			
		move_and_slide()
		
	#si Hades collides avec une light, alors on va calculer sa position x à ce moment-là.
	#cela déterminera sa direction à prendre pour rebondir.
	if collides_with_light:
		if counter_in_light > 0:
			position.x += sign(diff_x) * 10
			

func Coyote_timeout() -> void:
	jump_available = false


##ANIMATIONS

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "jump":
		animated_sprite.stop()
	if animated_sprite.animation == "magic_end":
		await get_tree().create_timer(0.3).timeout
		isPlayingMagic = false
		
func _play_idle_animation() -> void:
	animated_sprite.play("idle")
		
func _play_run_animation() -> void:
	animated_sprite.play("run")
	
func _flip_sprite() -> void:
	animated_sprite.flip_h = !animated_sprite.flip_h
	

##  END ANIMATIONS

#lorsque Hades touche une light, il rebondit.
#plusieurs options : 
# - soit je calcule sa position toutes les x secondes, et lorsqu'il touche une light, il retourne à sa position calculée
# pbs : s'il vient de tomber, il retournera en hauteur et il y aura boucle infinie
# - Du coup j'ai pensé à le faire rebondir en arrière par rapport à l'orientation de son sprite.
# pbs : Si le joueur fait exprès de sauter dans la light et de retourner le sprite au dernier moment,
# hadès rebondira dans la light et se retrouvera de l'autre côté de celle-ci, il l'aura traversée.
# Comment faire alors ?
## 	- Je peux calculer sa position x au moment de la collision avec la position x de la light.
# si la différence est positive, alors il est à droite, et la on le fait rebondir un cran à droite
#pas de pbs de sprite dans ce cas-là.
#s'il vient du haut, alors il rebondira du côté où il est.
#sinon je peux simplement mettre un physics layer sur la light sur son layer à lui, comme ça il ne pourra jamais entrer dans la light ever

func on_enter_light(light:Area2D) -> void:
	counter_in_light += 1
	collides_with_light = true
	diff_x = position.x - light.global_position.x
	print("enter, compteur light Hades : ", counter_in_light)
	
	#ancien
	#Global.restart_game()

#fonction qui servira surtout à checker si Hades est encore en train de collide avec une light ou non
# lorsqu'il est en train de rebondir. Dans ce cas, il rebondira encore jusqu'à ce qu'il soit sorti.
func on_exit_light() -> void:
	counter_in_light -= 1
	print("exit, compteur light Hades : ", counter_in_light)
	
#Lorsque Obscurité atteint son Checkpoint
func on_enter_checkpoint() -> void:
	#DEBUG
	print("Obscurité a atteint son Xpoint ! Le counter_level est à : ", Global.counter_level)
	Global.detectVictory +=1
	hasFinished = true
	Global.obscur_control(false)
	
	# Accéder à la forme de collision du checkpoint
	var checkpoint_obscurite = %Checkpoint_Obscurite.get_node("CollisionShape2D")  # Remplace "CollisionShape2D" par le nom exact de ton nœud
	if checkpoint_obscurite:
		var shape = checkpoint_obscurite.shape  # Récupère la forme du CollisionShape2D
		# Calculer le centre du checkpoint en fonction de la taille de la forme
		var shape_size = shape.extents * 2  # Récupère la taille de la forme
		position.x = %Checkpoint_Obscurite.position.x + shape_size.x / 2
		position.y = %Checkpoint_Obscurite.position.y + shape_size.y
			
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


func _on_animated_sprite_2d_frame_changed() -> void:
	if %AnimatedSprite2D.animation == "idle": return
	if %AnimatedSprite2D.animation == "jump": return
	if %AnimatedSprite2D.animation == "magic_loop": return
	if %AnimatedSprite2D.animation == "magic_end": return
	if %AnimatedSprite2D.animation == "lose": return
	load_sfx(sfx_O_footsteps)
	if %AnimatedSprite2D.frame in footstep_frames: %sfx_player.play()
	
#Lorsque Obscurite enter une black light, son Item cull Mask de LumierePerso passe a 2 et 4
func on_enter_black_light() -> void:
	%LumierePerso.range_item_cull_mask = 10
	print("O enter BL")

#Lorsque Obscurite exit une black light, son Item cull Mask de LumierePerso repasse à sa valeur par défaut
func on_exit_black_light() -> void:
	%LumierePerso.range_item_cull_mask = 11
	print("O exit BL")


#lorsque l'area de sa range est active, toutes les lights à proximité ont leur variable can_light_off activée
#permettant au joueur d'éteindre à sa guise
func _on_range_area_entered(area: Area2D) -> void:
	if area.is_in_group("lighters"):
		area.can_light_off = true


func _on_range_area_exited(area: Area2D) -> void:
	if area.is_in_group("lighters"):
		area.can_light_off = false
