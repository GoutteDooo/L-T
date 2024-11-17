extends Node2D
const Main = preload("res://scripts/main.gd")

## Le LVL 1 est un TUTO pour que le joueur comprenne la mécanique principale
## qui est d'allumer les lights et de les éteindre.

#Variables tuto
var first_click_ok = false
var second_click_ok = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#déclarer lulu et hades en global
	Global.lulu = %Lumiere
	Global.hades = %Obscurite
	Global.handle_views(false)

	Dialogic.signal_event.connect(_on_dialogic_signal)
	if Global.cutscene_intro:
		#Cinématique d'intro
		Global.player_control_L = false #enleve les controles
		Global.player_control_O = false #enleve les controles
		Dialogic.start("timeline")
	else :
		%Cinematique.play("no_intro")
		%MushroomCutSCene.get_node("%AnimationPlayer").play("on_ready")
		%Lumiere.position = Vector2(174,209)
		Global.lumiere_control(true)
		Global.obscur_control(false)
	

func _on_dialogic_signal(argument: String):
	if argument == "goIntro":
		%Cinematique.play("intro")
		
	if argument == "finIntro":
		%Cinematique.play("finIntro")
		Global.cutscene_intro = false #ne rejouera pas la cinématique en cas d'échec
		
	if argument == "bad_light_signal":
		print("signal bad light récupéré")
		Global.player_control_L = true
		Global.restart_game()
		
	if argument == "first_light_ok":
		Global.player_control_L = true
		print("fin 1st click dialogue")
		
	if argument == "second_light_ok":
		Global.player_control_L = true
		print("fin 2nd click dialogue")
		
	if argument == "end_pickup_cristal":
		Global.player_control_L = true
		%Lumiere.set_physics_process(true)
		print("fin pickup dialogue")
		
	if argument == "end_intro_Obs":
		Global.obscur_control(true)
		print("obscur fin dialogue")
		print("Hades position : ", %Obscurite.position)
		%Cinematique.play("fin_Obs_dialogue")
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


#Une fois l'animation d'intro fin
func _on_cinematique_animation_finished(anim_name: StringName) -> void:
	if anim_name == "intro":
		Dialogic.start("intro")
	if anim_name == "finIntro":
		Global.player_control_L = true
	if anim_name == "Obscur_appear":
		Dialogic.start("intro_Obscur")
		

#Checker si Joueur clique n'importe où,
#dans ce cas on lui apprend qu'il ne doit pas faire n'imp
#Et on le récompense avec des bons dialogues s'il fait les bonnes actions
func _on_clicker_ici_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and Global.player_control_L:
		if %ClickerIci.mushroom_light_on:
			#Oui ! Il a cliqué sur le bon mushroom !
			first_click_ok = true
			Dialogic.start("first_light_ok")
			Global.player_control_L = false
			%Lumiere._play_idle_animation()

func _on_faux_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and Global.player_control_L:
		if !first_click_ok || (!second_click_ok && !%CristalRouge):
			if %Faux.mushroom_light_on:
				Global.player_control_L = false
				%Lumiere._play_idle_animation()
				print("mauvais mushroom cliqué")
				#Faire dire à Lumiere : "Ce n'est pas la bonne light à allumer"
				Dialogic.start("bad_light")
				#Après le talk, un signal "bad_light_signal" est lancé pour redémarrer la game

func _on_faux_2_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and Global.player_control_L:
		if !first_click_ok || (!second_click_ok && !%CristalRouge):
			if %Faux2.mushroom_light_on:
				print(%CristalRouge)
				Global.player_control_L = false
				%Lumiere._play_idle_animation()
				print("mauvais mushroom cliqué")
				#Faire dire à Lumiere : "Ce n'est pas la bonne light à allumer"
				Dialogic.start("bad_light")
				#Après le talk, un signal "bad_light_signal" est lancé pour redémarrer la game


func _on_clicker_ici_2_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and Global.player_control_L:
		if !first_click_ok:
			if %ClickerIci2.mushroom_light_on:
				Global.player_control_L = false
				%Lumiere._play_idle_animation()
				print("mauvais mushroom cliqué")
				#Faire dire à Lumiere : "Ce n'est pas la bonne light à allumer"
				Dialogic.start("bad_light")
				#Après le talk, un signal "bad_light_signal" est lancé pour redémarrer la game
		else:
			if %ClickerIci2.mushroom_light_on:
				second_click_ok = true
				Dialogic.start("second_light_ok")
				Global.player_control_L = false
				%Lumiere._play_idle_animation()


func _on_cristal_rouge_body_entered(body: Node2D) -> void:
	Dialogic.start("pickup_cristal")
	Global.player_control_L = false
	%Lumiere.set_physics_process(false)
	%Lumiere._play_idle_animation()

#Une fois Lumiere entrée dans son x., Obscur apparaît
func _on_checkpoint_lumiere_body_entered(body: Node2D) -> void:
	%Cinematique.play("Obscur_appear")
