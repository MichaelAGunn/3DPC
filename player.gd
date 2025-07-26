extends CharacterBody3D

var movement_input := Vector2.ZERO
@export var walk_speed : float = 4.0
@export var run_speed : float = 12.0

@export var jump_height : float = 2.25
@export var jump_time_to_peak : float = 0.4
@export var jump_time_to_descent : float = 0.3

@onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak)
@onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak ** 2))
@onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent ** 2))

@onready var camera = $CameraController/SpringArm3D/Camera3D

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	jumping(delta)
	if is_on_floor():
		moving(delta)
	move_and_slide()

func moving(delta: float) -> void:
	movement_input = Input.get_vector("leftward", "rightward", "forward", "backward") \
		.rotated(-camera.global_rotation.y)
	var vel_2d = Vector2(velocity.x, velocity.z)
	var is_running: bool = Input.is_action_pressed("run")
	var speed = run_speed if is_running else walk_speed
	if movement_input != Vector2.ZERO:
		vel_2d += movement_input * speed * delta
		vel_2d = vel_2d.limit_length(speed)
	else:
		vel_2d = vel_2d.move_toward(Vector2.ZERO, (speed ** 3) * delta)
	velocity.x = vel_2d.x
	velocity.z = vel_2d.y

func jumping(delta: float) -> void:
	var gravity = jump_gravity if velocity.y > 0.0 else fall_gravity
	velocity.y += gravity * delta
	if Input.is_action_just_pressed("jump"):
		velocity.y += jump_velocity
