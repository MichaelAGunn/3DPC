extends CharacterBody3D

enum States {IDLE, WANDER, GRAZE, VOCALIZE}
var state: int = 0
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
		'duration': 1.0
	}
}

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var state_timer: Timer = $StateTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	state = States.IDLE
	state_timer.start(data[state]['duration'])

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
	print("IDLING")

func find_movement_target() -> void:
	var direction := Vector3.ZERO
	direction.x += randf_range(-5.0, 5.0)
	direction.z += randf_range(-5.0, 5.0)
	navigation_agent_3d.set_target_position(direction)

func wander() -> void:
	print("WANDERING")
	var destination = navigation_agent_3d.get_next_path_position()
	var local_destination = destination - global_position
	var direction = local_destination.normalized()
	velocity = direction

func graze() -> void:
	print("GRAZING")
	animation_player.play('graze')

func vocalize() -> void:
	print("VOCALIZING")
	animation_player.play('vocalize')

func change_state(next_state) -> void:
	'''State Transition Logic'''
	print("Changing from " + str(state) + " to " + str(next_state) + ".")
	if next_state == States.WANDER:
		find_movement_target()
	#elif next_state in [States.IDLE, States.GRAZE, States.VOCALIZE]:
		#velocity = Vector3.ZERO
	if state == States.WANDER:
		velocity = Vector3.ZERO
	var prev_state = state
	state = next_state
	state_timer.start(data[state]['duration'])

func _on_state_timer_timeout():
	'''Invoke State Transition Upon Timeout'''
	print("TIMEOUT!!!")
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
