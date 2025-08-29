extends CharacterBody3D

enum States {IDLE, WANDER, GRAZE, VOCALIZE}
var state: int = 0
var target_location: Vector3
var data: Dictionary = {
	States.IDLE: {
		'duration': 0.5
	},
	States.WANDER: {
		'duration': 3.0
	},
	States.GRAZE: {
		'duration': 2.0
	},
	States.VOCALIZE: {
		'duration': 1.0,
	}
}

@export var speed: float = 1.0

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var state_timer: Timer = $StateTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var vocalizer = $Vocalizer

func _ready() -> void:
	state = States.IDLE
	state_timer.start(data[state]['duration'])
	navigation_agent_3d.target_position = target_location

func _physics_process(_delta: float) -> void:
	match state:
		States.IDLE:
			idle()
		States.WANDER:
			wander()
		States.GRAZE:
			graze()
		States.VOCALIZE:
			vocalize()
	move_and_slide()

func idle() -> void:
	navigation_agent_3d.set_target_position(Vector3.ZERO)

func find_wander_target() -> void:
	var direction := Vector3.ZERO
	direction.x += randf_range(-5.0, 5.0)
	direction.z += randf_range(-5.0, 5.0)
	navigation_agent_3d.set_target_position(direction)

func wander() -> void:
	animation_player.play('wander')
	var current_location = global_transform.origin
	var next_location = navigation_agent_3d.get_next_path_position()
	var new_velocity = (next_location - current_location).normalized() * speed
	velocity = velocity.move_toward(new_velocity, 0.25)

func graze() -> void:
	animation_player.play('graze')

func vocalize() -> void:
	animation_player.play('vocalize')
	vocalizer.play()

func change_state(next_state) -> void:
	'''State Transition Logic'''
	print("Changing from " + str(state) + " to " + str(next_state) + ".")
	if next_state == States.WANDER:
		find_wander_target()
	match state:
		States.WANDER:
			navigation_agent_3d.set_target_position(Vector3.ZERO)
			velocity = Vector3.ZERO
		States.GRAZE or States.VOCALIZE:
			animation_player.stop()
	#var prev_state = state
	state = next_state
	state_timer.start(data[state]['duration'])

func _on_state_timer_timeout():
	'''Invoke State Transition Upon Timeout'''
	match state:
		States.IDLE:
			var random_state = randi_range(1, 3)
			change_state(random_state)
		States.WANDER:
			change_state(States.IDLE)
		States.GRAZE:
			change_state(States.IDLE)
		States.VOCALIZE:
			change_state(States.IDLE)

func _on_navigation_agent_3d_target_reached():
	'''Transition from Wandering'''
	change_state(States.IDLE)
