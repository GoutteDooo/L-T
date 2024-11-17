extends Node2D

@export var SPEED = 60
@export var is_magic_light_on = false
@export var is_black_light_on = false
@onready var temp_switch_light = !is_magic_light_on
@onready var butterfly: AnimatedSprite2D = $AnimatedSprite2D

#--- A LIRE ---
#Par défaut, les butterflys resteront sur place. S'ils sont placés avec leur raycast en collision avec
#un objet up ou down, ils passent d'une direction haut-bas et annulent leur déplacement droite-gauche

var directionX = 0
var directionY = 0

@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var ray_cast_up: RayCast2D = $RayCastUp
@onready var ray_cast_down: RayCast2D = $RayCastDown
@onready var magic_light: Area2D = $Magic_light
@onready var black_light: Area2D = $Black_Light
@onready var can_light_off = false
@onready var can_magic_light = false

func _ready() -> void:
	if is_magic_light_on:
		magic_light.monitoring = true
		magic_light.visible = true
		black_light.monitoring = false
		black_light.visible = false
	if is_black_light_on:
		magic_light.monitoring = false
		magic_light.visible = false
		black_light.monitoring = true
		black_light.visible = true
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if ray_cast_left.is_colliding():
		directionX = 1
	if ray_cast_right.is_colliding():
		directionX = -1
	if ray_cast_up.is_colliding():
		directionX = 0
		directionY = 1
	if ray_cast_down.is_colliding():
		directionX = 0
		directionY = -1
	
	position.x += directionX * SPEED * delta
	position.y += directionY * SPEED * delta
	
	#flip sprite
	if directionX > 0:
		butterfly.flip_h = false
	if directionX < 0:
		butterfly.flip_h = true
		
	#Handle light
	if is_magic_light_on == temp_switch_light:
		temp_switch_light = !temp_switch_light
		handle_light(temp_switch_light)
	
	
func handle_light(levier:bool) -> void:
	if !levier:
		%AnimationPlayer.play("ML_on")
		is_magic_light_on = true
		is_black_light_on = false
	else:
		%AnimationPlayer.play("ML_off")
		is_magic_light_on = false
		is_black_light_on = false

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
		if !is_magic_light_on and Global.counter_click_lumiere > 0 and can_magic_light:
			#DEBUG
			#print("1er")
			Global.counter_click_lumiere -= 1
			is_magic_light_on = true
		else:
			print("pas dans la range !")
			Global.no_magic_yet_sound.play()
			
	# --- OBSCUR ---
	
	#Si la light que le joueur veut éteindre est sur le mushroom
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed and Global.player_control_O:
		if is_magic_light_on and Global.counter_click_obscurite > 0 and can_light_off:
			#DEBUG
			is_magic_light_on = false
			Global.counter_click_obscurite -= 1
		else:
			Global.no_magic_yet_sound.play()
		
