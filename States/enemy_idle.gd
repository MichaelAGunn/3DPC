extends State
class_name EnemyIdle

@export var enemy: CharacterBody3D
@export var move_speed: float = 2.0

var move_direction: Vector2
var wander_time: float

func randomize_wander():
	move_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	wander_time = randf_range(1, 3)

func enter():
	randomize_wander()

func update(delta: float):
	if wander_time > 0:
		wander_time -= delta
	else:
		randomize_wander()

func physics_update(delta: float) -> void:
	if enemy:
		enemy.velocity = Vector3(move_direction.x, 0, move_direction.y) * move_speed
