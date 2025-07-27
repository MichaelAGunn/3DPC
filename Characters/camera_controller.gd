extends Node3D

@export_range(-90.0, 0.0, 0.1, "radians_as_degrees") var min_limit_x: float = -PI/2
@export_range(-90.0, 0.0, 0.1, "radians_as_degrees") var min_limit_y: float = PI/4
@export var mouse_acc: float = 0.005
@export var lerp_power: float = 1.0
@onready var spring_arm = $SpringArm3D
@onready var camera = $SpringArm3D/Camera3D
@onready var spring_end = $SpringArm3D/SpringEnd

# TO DO: optimize _process() and _input() and _physics_process()
#        to enable joystick functionality
# This is a good reference: https://www.youtube.com/watch?v=ZCb12AHKMfE

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			rotation.y -= event.relative.x * mouse_acc
			rotation.y = wrapf(rotation.y, -PI, PI)
			rotation.x -= event.relative.y * mouse_acc
			rotation.x = clamp(rotation.x, min_limit_x, min_limit_y)
	#if event.is_action_pressed("wheel_up"): # Zoom in and out
		#spring_arm.spring_length -= 1
	#if event.is_action_pressed("wheel_down"):
		#spring_arm.spring_length += 1
	if event.is_action_pressed("toggle_mouse_capture"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

#func _process(delta: float) -> void: # Not sure how to lerp the camera properly
	#camera.position = lerp(position, spring_end.position, delta * lerp_power)

#func _input(event: InputEvent) -> void:
	#if event is InputEventMouseMotion:
		#rotate_from_vector(event.relative * mouse_acc)

#func rotate_from_vector(v: Vector2) -> void:
	#if v.length() == 0: return
	#rotation.y -= v.x
	#rotation.x -= v.y
	#rotation.x = clamp(rotation.x, min_limit_x, min_limit_y)
