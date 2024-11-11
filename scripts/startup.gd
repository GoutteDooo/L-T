extends Node2D

#mécanique de jeu
var game_over = false #évite de relancer le timer à chaque fois (fix slow bug)
var detectVictory = 0 #Quand ça atteint 2 -> victoire
var counter_level = 1 #Compteur de niveau
var annulerAction = false #Permettra de faire des annulations d'actions (pendant les cutscenes, tutos et autres...)
var cam_H = null #Sert de switch au joueur pour la caméra
var cam_L = null #Sert de switch au joueur pour la caméra

#Player
const number_click_obscurite = [100, 4, 5, 4, 0,0] #chaque number en fonction du niveau
const number_click_lumiere = [100, 1, 2, 3, 0,0] #chaque number en fonction du niveau
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
	if Input.is_action_just_pressed("switch_cam"):
		lumiere_control(!player_control_L)
		obscur_control(!player_control_O)
		lulu.animated_sprite.play("idle")
		hades.animated_sprite.play("idle")
		handleLuluView(!player_control_L)
		handleHadesView(!player_control_O)
	#PROBLEME !
	#Parfois, un <Freed Object> se plante dans le tableau lorsque Lulu kill Hadès
	#Avec cette fonction qui vérifie en permanence s'il y'a un freed object, ça permet de les remove s'il y'en a.
	#Pas trouvé mieux pour l'instant, mais peut-être à opti
	if light_array.size() > 1:
		var rng = randf() #permettra de randomiser pour éviter de lancer la fonction 10000x/sec
		if rng > 0.9:
			for i in range(0, light_array.size()):
				print("Array : ", light_array)
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
		#print("game over over!")
		counter_level = 1
		get_tree().change_scene_to_file.call_deferred("res://scenes/levels/level_1.tscn")
		get_tree().reload_current_scene()
		lives = 3
		game_over = false

func lumiere_control(levier:bool) -> void:
	Global.player_control_L = levier
	#print("Lulu control : ", levier)
	
func obscur_control(levier:bool) -> void:
	Global.player_control_O = levier
	#print("Hades control : ", levier)

func handleLuluView(levier:bool) -> void:
	if levier:
		lulu.animated_sprite.light_mask = 12
		#print_debug("lulu light mask :", lulu.light_mask)
	else:
		lulu.animated_sprite.light_mask = 15
		cam_L.enabled = true
		cam_H.enabled = false
		#print_debug("cam lulu activée & H désactivée")
	
func handleHadesView(levier: bool) -> void:
	if levier:
		hades.visible = false
	else:
		hades.visible = true
		cam_L.enabled = false
		cam_H.enabled = true
		#print_debug("cam H activée & L désactivée")
		
func lulu_exit_light() -> void:
	#Gérer le tableau des lights de Lulu
	for i in range(0,light_array.size()):
		#print("array size : ", Global.light_array.size())
		#print("i : ", i)
		#Vérifie que la light quittée est bien dans le tableau
		if (light_array[i] == last_light_in or light_array[i] == null):
			light_array.remove_at(i)
			#print("Removed at index : ",i)
			#print("BREAK")
			break
		#print("light array : ",Global.light_array)
	#Enfin, on vérifie si son tableau est vide, et si tel est le cas, cela veut dire que Lulu n'est plus dans aucune light
	if light_array.size() == 0 and last_light_in.monitoring:
		#On check si la last_light existe encore
		#Si c'est le cas, alors on renvoie Lulu à son origine
		#Sinon, on recommence la partie (Hades a du l'éteindre)
		#print("last light in :",Global.last_light_in)
		print("Lulu est retransférée à la position : ", Global.last_light_in.global_position)
		lulu.position = last_light_in.global_position + Vector2(0, -10)
		#print("Position de lulu : ", Global.lulu.position)
	elif light_array.size() == 0:
		print("dernière light quittée inexistante, fin de la partie : ", Global.last_light_in)
		restart_game()
	#print("Tableau vide !")
