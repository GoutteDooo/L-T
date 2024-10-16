extends Node2D

@export var SPEED = 60
@export var is_magic_light_on = false
@export var is_black_light_on = true
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
		
