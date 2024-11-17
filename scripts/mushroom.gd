extends Area2D

@export var mushroom_light_on = false
@onready var temp_switch_light = !mushroom_light_on
@onready var can_magic_light = false
@onready var can_light_off = false


func _ready() -> void:
	if mushroom_light_on:
		%AnimationPlayer.play("on_ready")
		

func _process(delta: float) -> void:
	#Handle la light du mushroom
	if mushroom_light_on == temp_switch_light:
		temp_switch_light = !temp_switch_light
		handle_mushroom_light(temp_switch_light)
		#print("switch")

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	
	#ANNULE L'ACTION SI ACTIVE
	#Utile pendant les tutos notamment
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and Global.player_control_L:
		if Global.annulerAction:
			Global.no_magic_yet_sound.play()
			Global.annulerAction = false
			print("annuler on")
			return
	
	#--- LULU ---
	#Si la light que le joueur veut créer est sur le mushroom
	#Il faut que le mushroom soit dans la range de Lulu (can_magic_light soit true) et que "E" soit pressé
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and Global.player_control_L:
		if !mushroom_light_on and Global.counter_click_lumiere > 0 and can_magic_light:
			#DEBUG
			#print("1er")
			Global.counter_click_lumiere -= 1
			mushroom_light_on = true
		else:
			print("pas dans la range !")
			Global.no_magic_yet_sound.play()
			
	# --- OBSCUR ---
	
	#Si la light que le joueur veut éteindre est sur le mushroom
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed and Global.player_control_O:
		if mushroom_light_on and Global.counter_click_obscurite > 0 and can_light_off:
			#DEBUG
			mushroom_light_on = false
			Global.counter_click_obscurite -= 1
		else:
			Global.no_magic_yet_sound.play()
		


func _on_mouse_entered() -> void:
	if !mushroom_light_on and Global.player_control_L:
		$CircleWhenHover.visible = true
	

func _on_mouse_exited() -> void:
	$CircleWhenHover.visible = false

func handle_mushroom_light(levier:bool) -> void:
	if !levier:
		%AnimationPlayer.play("light_on")
		mushroom_light_on = true
	else:
		%AnimationPlayer.play("light_off")
		mushroom_light_on = false
