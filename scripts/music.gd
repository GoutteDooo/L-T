extends Node2D

@onready var general_music: AudioStreamPlayer2D = $GeneralMusic
#musiques de niveaux
@export var g_music_lv1: AudioStream
@export var g_music_lv2: AudioStream
@export var g_music_lv3: AudioStream
@export var g_music_lv4: AudioStream

#Musiques de contexte
@export var hades_meet_lulu: AudioStream

#Créer un array pour accéder aux musiques plus facilement
var music_levels = []
var level_en_cours = 1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	#remplir la liste avec les musiques des niveaux :
	music_levels = [g_music_lv1,g_music_lv2,g_music_lv3,g_music_lv4]
	
	#Lancer la 1ere musique
	load_gen_music(music_levels[0])

#Handle la musique durant le jeu
func _process(delta: float) -> void:
	#Change la musique lors du changement de niveau
	if level_en_cours < Global.counter_level and Global.counter_level < music_levels.size():
		load_gen_music(music_levels[Global.counter_level - 1])
		level_en_cours += Global.counter_level

func stop_general_music() -> void:
	general_music.stop()

func load_gen_music(music_to_load) -> void:
	if general_music.stream != music_to_load:
		general_music.stop()
		general_music.stream = music_to_load
		general_music.play()

func music_hades_meet_lulu() -> void:
		load_gen_music(hades_meet_lulu)
