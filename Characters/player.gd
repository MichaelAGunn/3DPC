extends CharacterBody3D
class_name Player

var paused: bool = false
var movement_input := Vector2.ZERO
var _mouse_input_dir := Vector2.ZERO
var _last_movement_dir := Vector3.BACK
var mouse_sensitivity: float = 0.15

# Camera vars
@export_range(-90.0, 0.0, 0.1, "radians_as_degrees") var min_limit_x: float = -PI/2
@export_range(-90.0, 0.0, 0.1, "radians_as_degrees") var min_limit_y: float = PI/3
@export var mouse_acc: float = 0.005
@export var lerp_power: float = 1.0
@onready var camera_control = $CameraControl
@onready var spring_arm_3d = $CameraControl/SpringArm3D
@onready var camera_3d = $CameraControl/SpringArm3D/Camera3D

# Movement vars
@export var walk_speed: float = 4.0
@export var run_speed: float = 12.0
@onready var body = $MeshInstance3D
@onready var rubber_man = $rubber_man
#@onready var armature = rubber_man.rubber_skeleton.skeleton_3d

# Jumping vars
@export var jump_height: float = 1.0
@export var jump_time_to_peak: float = 0.4
@export var jump_time_to_descent: float = 0.3
@onready var jump_velocity: float = ((2.0 * jump_height) / jump_time_to_peak)
@onready var jump_gravity: float = ((-2.0 * jump_height) / (jump_time_to_peak ** 2))
@onready var fall_gravity: float = ((-2.0 * jump_height) / (jump_time_to_descent ** 2))

# ==== WORK ON THIS SOON!!!!! https://www.youtube.com/watch?v=qIf5YQ8qJng =====
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	# Essential Buttons
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	if event.is_action_pressed("pause"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			# Enter Live Play
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			paused = true
		elif Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			# Enter Pause Menu
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			paused = false

func _unhandled_input(event: InputEvent) -> void:
	# Rotate Camera
	var is_mouse_motion := (
		event is InputEventMouseMotion and
		Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)
	if is_mouse_motion:
		_mouse_input_dir = event.screen_relative * mouse_sensitivity
	# Zoom Camera
	if event.is_action_pressed("zoomin"):
		spring_arm_3d.spring_length -= 1
		spring_arm_3d.spring_length = clamp(spring_arm_3d.spring_length, 2.0, 12.0)
	elif event.is_action_pressed("zoomout"):
		spring_arm_3d.spring_length += 1
		spring_arm_3d.spring_length = clamp(spring_arm_3d.spring_length, 2.0, 12.0)
	
func _physics_process(delta: float) -> void:
	# Camera by Mouse
	camera_control.rotation.x -= _mouse_input_dir.y * delta
	camera_control.rotation.x = clamp(camera_control.rotation.x, -PI/2.0, PI/8.0)
	camera_control.rotation.y -= _mouse_input_dir.x * delta
	_mouse_input_dir = Vector2.ZERO
	#Move the PC
	jumping(delta)
	moving(delta)
	move_and_slide()

func moving(delta: float) -> void:
	#var direction := Vector3(velocity.x, 0.0, velocity.y).normalized()
	#direction = direction.rotated(Vector3.UP, camera.global_rotation.y)
	movement_input = Input.get_vector("leftward", "rightward", "forward", "backward") \
		.rotated(-camera_control.global_rotation.y)
	var vel_2d = Vector2(velocity.x, velocity.z)
	var is_running: bool = Input.is_action_pressed("run") # Replace with state machine logic!
	var speed = run_speed if is_running else walk_speed
	if movement_input != Vector2.ZERO:
		vel_2d += movement_input * speed * delta
		vel_2d = vel_2d.limit_length(speed)
	else:
		vel_2d = vel_2d.move_toward(Vector2.ZERO, (speed ** 2) * delta)
	velocity.x = vel_2d.x
	velocity.z = vel_2d.y
	if movement_input.length() > 0.2:
		_last_movement_dir = velocity
	var target_angle := Vector3.BACK.signed_angle_to(_last_movement_dir, Vector3.UP)
	body.global_rotation.y = target_angle

func jumping(delta: float) -> void:
	var gravity = jump_gravity if velocity.y > 0.0 else fall_gravity
	velocity.y += gravity * delta
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity.y += jump_velocity
