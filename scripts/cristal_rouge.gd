extends Area2D
const floater = 0.1 #à combien de pixel le cristal va flotter par frame
const floating_limit = 5 #Où le cristal va s'arrêter de flotter
var floating_position = 0
var shifter = false #direction du cristal
var shifter_opacity = -1
var opacity:float = 0.6
var shifter_light = -1
var dynamic_energy = 4
var shifter_scale = 1
var dynamic_scale = 0.8

func _on_body_entered(body: Node2D) -> void:
	%AnimationPlayer.play("collected")
	Global.counter_click_lumiere += 1
	print(Global.counter_click_lumiere)

func _process(delta: float) -> void:
	#flottement cristal
	if shifter:
		if floating_position < floating_limit:
			global_position += Vector2(0,floater)
			floating_position += floater
		else:
			shifter = !shifter
	else:
		if floating_position > -(floating_limit):
			global_position -= Vector2(0,floater)
			floating_position -= floater
		else:
			shifter = !shifter
	#opacity cristal
	if opacity < 0.3:
		shifter_opacity = 1
	elif opacity > 0.6:
		shifter_opacity = -1
	opacity += shifter_opacity * 0.005
	self.modulate = Color(1,1,1,opacity)
	#energy light
	if dynamic_energy > 10:
		shifter_light = -1
	elif dynamic_energy < 4:
		shifter_light = 1
	dynamic_energy += shifter_light * 0.05
	$Lumiere_Cristal.energy = dynamic_energy + (shifter_light * 0.1)
	#scale de la light
	if dynamic_scale < 0.4:
		shifter_scale = 1
	elif dynamic_scale > 0.6:
		shifter_scale = -1
	dynamic_scale += shifter_scale * 0.002
	$Lumiere_Cristal.texture_scale = dynamic_scale
