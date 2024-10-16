extends Node2D


#inputs
var r_click_position = Vector2()
var l_click_position = Vector2()

#preloads
var light = preload("res://scenes/objects/magic_light.tscn")
var shape_light = preload("res://scenes/objects/magical_light_shape.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#print("nbs de clicks possible Lumiere : ", Global.counter_click_lumiere)
	#print("nbs de clicks possible Obscurite : ", Global.counter_click_obscurite)
	#print("DetectVictory : ", Global.detectVictory)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
		
		
func restart_game() -> void:
	pass
