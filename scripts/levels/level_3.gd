extends Node2D

var lulu_fall_animation = false
var hades_fall_animation = false

#phantom cameras
@onready var pcam_room_top_right: PhantomCamera2D = $RoomTopRightPCam2D
@onready var pcam_room_all_left: PhantomCamera2D = $RoomAllLeftPCam2D
@onready var actual_pcam = pcam_room_top_right

@onready var room_top_right: Area2D = $RoomTopRight
@onready var room_all_left: Area2D = $RoomAllLeft

#mushrooms right room
@onready var mushroom_right_1: Area2D = $Mushroom
@onready var mushroom_right_2: Area2D = $Mushroom3
@onready var mushroom_right_3: Area2D = $Mushroom7
@onready var mushroom_right_4: Area2D = $Mushroom6
@onready var mushroom_right_5: Area2D = $Mushroom5
@onready var mushroom_right_6: Area2D = $Mushroom4
@onready var mushroom_right_7: Area2D = $Mushroom8
@onready var mushroom_right_8: Area2D = $Mushroom2
var mushrooms_room_right = []


#mushrooms left room
@onready var mushroom_left_1: Area2D = $Mushroom14
@onready var mushroom_left_2: Area2D = $Mushroom15
@onready var mushroom_left_3: Area2D = $Mushroom16
@onready var mushroom_left_4: Area2D = $Mushroom18
@onready var mushroom_left_5: Area2D = $Mushroom11
@onready var mushroom_left_6: Area2D = $Mushroom12
@onready var fragment: Area2D = $Fragment
@onready var mushroom_left_7: Area2D = $Mushroom13
@onready var mushroom_left_8: Area2D = $Mushroom9
var mushrooms_room_left = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#déclarer lulu et hades en global
	Global.lulu = %Lumiere
	Global.hades = %Obscurite
	#déclarer les controles des persos
	Global.lumiere_control(true)
	Global.obscur_control(false)
	#déclarer où la caméra se situe en 1er
	#Global.body_cam = %Lumiere
	
	pcam_room_top_right.set_follow_offset(Vector2(-80, 0))
	room_top_right.body_entered.connect(_on_body_entered.bind(pcam_room_top_right))
	room_all_left.body_entered.connect(_on_body_entered.bind(pcam_room_all_left))
	
	mushrooms_room_left = [mushroom_left_1,mushroom_left_2,mushroom_left_3,mushroom_left_4,mushroom_left_5,mushroom_left_6,mushroom_left_7,mushroom_left_8]
	mushrooms_room_right = [mushroom_right_1,mushroom_right_2,mushroom_right_3,mushroom_right_4,mushroom_right_5,mushroom_right_6,mushroom_right_7,mushroom_right_8]
	

func _on_body_entered(body: Node2D, pcam: PhantomCamera2D) -> void:
	if body == %Lumiere or body == %Obscurite:
		pcam.set_follow_target(Global.body_cam)
		pcam.set_priority(20)
		print(pcam, " priorité après set : ", pcam.priority)
		pcam.priority = 20
		print(pcam, " priorité après priority : ", pcam.priority)
		print(body, " entered new area")
		#Jouer avec la visibilité des lights pour ne pas surcharger le rendu
		if pcam == pcam_room_top_right:
			print(body, " entered room right")
			for i in range(0, mushrooms_room_left.size()):
				mushrooms_room_left[i].visible = false
		elif pcam == pcam_room_all_left:
			actual_pcam = pcam_room_all_left
			pcam_room_top_right.set_priority(0)
			pcam_room_top_right.set_follow_target(null)
			print(body, " entered room left")
			$ButterflyFinalAnimation.play("Butterfly_final")
			
			for i in range(0, mushrooms_room_left.size()):
				mushrooms_room_left[i].visible = true
			for i in range(0, mushrooms_room_right.size()):
				mushrooms_room_right[i].visible = false


func _on_body_exited(body: Node2D, pcam: PhantomCamera2D) -> void:
		pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("switch_cam"):
		if Global.body_cam == %Lumiere:
			Global.body_cam = %Obscurite
			actual_pcam.set_follow_target(Global.body_cam)
			print("body cam : ", Global.body_cam)
		else:
			Global.body_cam = %Lumiere
			actual_pcam.set_follow_target(Global.body_cam)
			print("body cam : ", Global.body_cam)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "lulu_fall_on_it":
		$AnimationPlayer.play("platform_path_before_hades")
	if anim_name == "hades_fall_on_it":
		$AnimationPlayer.play("final_path")


func _on_event_zone_body_entered(body: Node2D) -> void:
	if body == %Lumiere and !lulu_fall_animation:
		$AnimationPlayer.play("lulu_fall_on_it")
		lulu_fall_animation = true


func _on_event_zone_2_body_entered(body: Node2D) -> void:
	if body == %Obscurite and !hades_fall_animation and lulu_fall_animation:
		$AnimationPlayer.play("hades_fall_on_it")
		hades_fall_animation = true
