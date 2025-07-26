extends Node3D

@export var min_limit_x: float = -1.0
@export var min_limit_y: float = 0.0
@export var hor_acc: float = 2.0
@export var ver_acc: float = 1.0
@export var mouse_acc: float = 0.005

# TO DO: optimize _process() and _input() and _physics_process()
#func _process(delta: float) -> void:
	#var r_joy_dir = Input.get_vector("pan_left", "pan_right", "pan_up", "pan_down")
	#rotate_from_vector(r_joy_dir * delta * Vector2(hor_acc, ver_acc))

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_from_vector(event.relative * mouse_acc)

func rotate_from_vector(v: Vector2) -> void:
	if v.length() == 0: return
	rotation.y -= v.x
	rotation.x -= v.y
	rotation.x = clamp(rotation.x, min_limit_x, min_limit_y)
