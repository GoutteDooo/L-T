extends Node2D
const Main = preload("res://scripts/main.gd")

var event_obscurite_appeared = false
var event_obscurite_meet_lulu = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#déclarer lulu et hades en global
	Global.lulu = %Lumiere
	Global.hades = %Obscurite
	Global.obscur_control(false)
	Global.lumiere_control(true)
	Global.cam_state = Global.States.SWITCH_DISABLED
	Global.cine_state = Global.cine_States.ON
	
	Dialogic.signal_event.connect(_on_dialogic_signal)
	Dialogic.start("level_2/intro")
	

func _on_dialogic_signal(argument: String):
	if argument == "fin_intro":
		pass
	if argument == "end_meeting":
		%Obscurite.set_physics_process(true)
		Global.obscur_control(true)
		Global.lumiere_control(false)
		Global.cam_state = Global.States.SWITCH_ON
		print("Lulu meca_state :", %Lumiere.meca_state)
		%Lumiere.meca_state = %Lumiere.MecaStates.ON

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


#Lorsque Lumiere récup le fragment, c'est au tour d'Obscur d'entrer en scène.
#Aussi, la black light aura une durée infinie pour laisser le temps au joueur de terminer le niveau et aller
#jusqu'à la cutscene
func _on_fragment_body_entered(body: Node2D) -> void:
	%Lumiere.on_put_fragment(9999)
	if body == %Lumiere:
		%Cinematique.play("manage_camera")
		#Modifier la position de Lumiere pour la poser sur le sol car le
		#controle la clou dans les airs
		await get_tree().create_timer(0.2).timeout
		print("meca_state de Lulu avant chgt: ",%Lumiere.meca_state)
		%Lumiere.meca_state = %Lumiere.MecaStates.OFF
		print("meca_state de Lulu après : ",%Lumiere.meca_state)
		Global.lumiere_control(false)
		
#Fonction qui servait à play la CS d'Obscur mais je ne me sert plus du xP
func _on_checkpoint_lumiere_body_entered(body: Node2D) -> void:
	pass
	

# Obscur éteint la light du trou, puis l'autre dans sa cutscene
func deactive_light_hole() -> void:
	%Magic_light.monitoring = false
	%Magic_light.visible = false
	Global.magic_obscurite_sound.play()

#lorsque Obscur apparaît, donner le contrôle au joueur
func _on_cinematique_animation_finished(anim_name: StringName) -> void:
	if anim_name == "manage_camera":
		%Cinematique.play("Obscurite_appear")
	if anim_name == "Obscurite_appear":
		Global.obscur_control(true)
		%Cinematique.play("end_Obscur_appeared")
		
	if anim_name == "Obs_meet_Lu":
		pass

#Obscur rencontre Lumière
func _on_entering_obscur_body_entered(body: Node2D) -> void:
	if body == %Obscurite and Global.cine_state == Global.cine_States.ON:
		Global.cine_state = Global.cine_States.OFF
		event_obscurite_meet_lulu = true
		Global.obscur_control(false)
		%Obscurite.set_physics_process(false)
		Music.music_hades_meet_lulu()
		%Obscurite.animated_sprite.play("idle")
		%Cinematique.play("Obs_meet_Lu")
		Dialogic.start("Obs_meet_Lu")
	
