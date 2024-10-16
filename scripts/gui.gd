extends CanvasLayer

const heart_size = 32

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	%BarLumiere.value = Global.counter_click_lumiere
	%BarShadow.value = Global.counter_click_obscurite
	$Control/Lives.size.x = Global.lives * heart_size
	if Global.lives <= 0:
		$Control/Lives.visible = false
