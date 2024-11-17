extends Node2D

#mécanique de jeu
var game_over = false #évite de relancer le timer à chaque fois (fix slow bug)
var detectVictory = 0 #Quand ça atteint 2 -> victoire
var counter_level = 1 #Compteur de niveau
var annulerAction = false #Permettra de faire des annulations d'actions (pendant les cutscenes, tutos et autres...)
var cam_H = null #Sert de switch au joueur pour la caméra
var cam_L = null #Sert de switch au joueur pour la caméra
var level_en_cours: PackedScene #A déclarer à chaque début de lvl

#State 
enum States {SWITCH_ON, SWITCH_DISABLED}
var cam_state: States = States.SWITCH_ON
enum cine_States {ON,OFF}
var cine_state: cine_States = cine_States.OFF


#Player
const number_click_obscurite = [100, 104, 105, 104, 100,100] #chaque number en fonction du niveau
const number_click_lumiere = [100, 101, 102, 103, 100,100] #chaque number en fonction du niveau
var counter_click_obscurite = number_click_obscurite[counter_level] #nbs de lights que Obscurite peut éteindre
var counter_click_lumiere = number_click_lumiere[counter_level] #nbs de lights que Lumiere peut créer par scene
var lulu = null
var hades = null
var light_array: Array[Object] = [] #Array de lights dynamique représentant les lights dans lesquelles Lulu se trouve
var last_light_in = null #Check constamment la dernière light que Lulu a quittée


#GUI
@onready var lives = 3 #nombre de lives du joueur avant la game over
var player_control_L = true #variable levier qui donnera le controle ou non de Lumiere
var player_control_O = true #variable levier qui donnera le controle ou non de Lumiere

#LEVEL 1 
var cutscene_intro = true

@onready var magic_loop_hades_sound: AudioStreamPlayer2D = $MagicLoopHadesSound
@onready var magic_loop_sound: AudioStreamPlayer2D = $MagicLoopSound
@onready var checkpoint_sound: AudioStreamPlayer2D = $CheckpointSound
@onready var victory_sound: AudioStreamPlayer2D = $VictorySound
@onready var magic_lumiere_sound: AudioStreamPlayer2D = $MagicLumiereSound
@onready var magic_obscurite_sound: AudioStreamPlayer2D = $MagicObscuriteSound
@onready var no_magic_yet_sound: AudioStreamPlayer2D = $NoMagicYetSound
@onready var dying_sound: AudioStreamPlayer2D = $DyingSound
@onready var timer: Timer = $Timer



func _ready() -> void:
	#DEBUG
	#print("start : ", number_click_lumiere[counter_level])
	
	#Pour le test :
	counter_click_lumiere = number_click_lumiere[0]
	counter_click_obscurite = number_click_obscurite[0]
	
	pass
		
		
func _process(delta: float) -> void:
	if Input.is_action_pressed("quit_game"):
		get_tree().quit()
	#lorsque le joueur appuie sur 'espace'
	if Input.is_action_just_pressed("switch_cam") and (cam_state == States.SWITCH_ON):
			lumiere_control(!player_control_L)
			obscur_control(!player_control_O)
			lulu.animated_sprite.play("idle")
			hades.animated_sprite.play("idle")
			handle_views(!player_control_L)
	#PROBLEME !
	#Parfois, un <Freed Object> se plante dans le tableau lorsque Lulu kill Hadès
	#Avec cette fonction qui vérifie en permanence s'il y'a un freed object, ça permet de les remove s'il y'en a.
	#Pas trouvé mieux pour l'instant, mais peut-être à opti
	if light_array.size() > 1:
		var rng = randf() #permettra de randomiser pour éviter de lancer la fonction 10000x/sec
		if rng > 0.9:
			for i in range(0, light_array.size()):
				#print("Array : ", light_array)
				if light_array[i] == null:
					#print("Tentative de removing freed object...")
					light_array.remove_at(i)
					#print("Réussite ! Array : ", light_array)
				else:
					#print("Pas de freed object !")
					pass
		
func restart_game() -> void:
	#DEBUG
	#print("DetectVictory : ", detectVictory)
	if !game_over:
		game_over = true
		#Engine.time_scale = 0.5
		dying_sound.play()
		timer.start()
		light_array = [] #Remettre l'array de Lulu vide pour éviter tout bug de freed object

func victory() -> void:
	#DEBUG
	#print("Victoire !")
	victory_sound.play()
	
	#passer au level suivant
	counter_level += 1
	get_tree().change_scene_to_file.call_deferred("res://scenes/levels/level_" + str(counter_level) + ".tscn")
	#DEBUG
	#print("NEXT LEVEL : ", counter_level)
	
	#redonner un compteur a Obscurite et Lumiere au passage du level suivant
	counter_click_obscurite = number_click_obscurite[counter_level]
	counter_click_lumiere = number_click_lumiere[counter_level]
	#réinitialiser le compteur de checkpoint
	detectVictory = 0
	


func _on_timer_timeout() -> void:
	Engine.time_scale = 1
	#remettre à 0 le compteur de checkpoint une fois que le timer est terminé
	detectVictory = 0
	
	# --- REINITIALISER LA MAGIE D'OBSCURITE ---
	counter_click_obscurite = number_click_obscurite[counter_level]
	# --- REINITIALISER LA MAGIE DE LUMIERE ---
	counter_click_lumiere = number_click_lumiere[counter_level]
	if lives > 0: #si tjr de la vie
		get_tree().reload_current_scene()
		lives -= 1
		#game_over vient après pour ne pas créer une boucle infinie de Lumiere qui quitte sa light, et se remet dedans...
		game_over = false
	else:
		#si game over over
		print("game over over!")
		counter_level = 1
		get_tree().change_scene_to_file.call_deferred("res://scenes/levels/level_1.tscn")
		get_tree().reload_current_scene()
		lives = 3
		game_over = false

func lumiere_control(levier:bool) -> void:
	Global.player_control_L = levier
	print("Lulu control : ", levier)
	
func obscur_control(levier:bool) -> void:
	Global.player_control_O = levier
	print("Hades control : ", levier)

func handle_views(levier:bool) -> void:
	if levier:
		#Hades
		lulu.animated_sprite.modulate = Color(0,0,0,1)
		#print_debug("lulu light mask :", lulu.light_mask)
		hades.visible = true
		cam_L.enabled = false
		cam_H.enabled = true
		
	else:
		#Lulu
		lulu.animated_sprite.modulate = Color(1,1,1,1)
		cam_L.enabled = true
		cam_H.enabled = false
		#print_debug("cam lulu activée & H désactivée")
		hades.visible = false
		
	switchLightView(levier)

func handleHadesView(levier: bool) -> void:
	#if levier:
		#hades.visible = false
	#else:
		#hades.visible = true
		#cam_L.enabled = false
		#cam_H.enabled = true
		#print_debug("cam H activée & L désactivée")
	pass

## Gère les couleurs des lights lors du "Switch Characters"
func switchLightView(hadesView:bool) -> void:
	var level_en_cours = get_node("/root/Level" + str(counter_level) + "_2")
	##----- Change les couleurs des lighters -----
	for lighters in level_en_cours.get_children():
		if lighters.is_in_group("lighters"):
			var calque = lighters.get_node("Magic_light/Calque")
			var full_circle = lighters.get_node("Magic_light/fullCircle")
			#----- HADES -----
			if hadesView: 
				#print("enfant de la scene : ",lighters)
				lighters.modulate = Color(1,1,1,1)
				#Gère le calque de la light pour une light toute noire
				if calque && full_circle:
					#print("full circle : ", full_circle)
					calque.modulate = Color(1,0,0,1)
					full_circle.visible = false
			#----- LULU -----
			else:
				lighters.modulate = Color(1,1,1,1)
				if calque && full_circle:
					calque.modulate = Color(1,1,1,0.0666)
					full_circle.visible = true
	##----- Change les couleurs des characters -----
	#----- HADES -----
	if hadesView:
		#On vérifie si Lulu est dans la même BL qu'Hadès
		#Et alors, on la rend visible aux yeux de ce bg
		if hades.isInBlackLight:
			for i in range(0, light_array.size()):
				if light_array[i] == hades.blackLightIn:
					lulu.animated_sprite.modulate = Color(1,1,1,1)
					print("Lulu modulate : ", lulu.modulate)
					break
		#Si Hades n'est pas dans une BL, alors il voit une ombre
		else:
			lulu.animated_sprite.modulate = Color(0,0,0,1)
			
		#----- LULU -----
	else:
		if hades.isInBlackLight: 
			hades.visible = true
		
