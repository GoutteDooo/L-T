extends Node2D

#mécanique de jeu
var game_over = false #évite de relancer le timer à chaque fois (fix slow bug)
var detectVictory = 0 #Quand ça atteint 2 -> victoire
var counter_level = 1 #Compteur de niveau
var annulerAction = false #Permettra de faire des annulations d'actions (pendant les cutscenes, tutos et autres...)
var body_cam = null #Sert de switch au joueur pour la caméra

#Player
const number_click_obscurite = [100, 4, 5, 4, 0,0] #chaque number en fonction du niveau
const number_click_lumiere = [100, 1, 2, 3, 0,0] #chaque number en fonction du niveau
var counter_click_obscurite = number_click_obscurite[counter_level] #nbs de lights que Obscurite peut éteindre
var counter_click_lumiere = number_click_lumiere[counter_level] #nbs de lights que Lumiere peut créer par scene
var lulu = null
var hades = null


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
		
func restart_game() -> void:
	#DEBUG
	#print("DetectVictory : ", detectVictory)
	if !game_over:
		game_over = true
		#Engine.time_scale = 0.5
		dying_sound.play()
		timer.start()

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

func handleLuluView(levier:bool) -> void:
	pass
	
func handleHadesView(levier: bool) -> void:
	pass
