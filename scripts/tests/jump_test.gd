extends CharacterBody2D

@export var coyote_time = 0.1
@onready var coyote_timer: Timer = $"../Coyote_Timer"

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var jump_available = true



func _physics_process(delta: float) -> void:
	
	
	# Add the gravity.
	if not is_on_floor():
		if jump_available:
			if coyote_timer.is_stopped():
				coyote_timer.start(coyote_time)
			#get_tree().create_timer(coyote_time).timeout.connect(Coyote_timeout)
			
		velocity += get_gravity() * delta
	else:
		jump_available = true
		coyote_timer.stop()

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and jump_available:
		velocity.y = JUMP_VELOCITY
		jump_available = false

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func Coyote_timeout() -> void:
	jump_available = false
