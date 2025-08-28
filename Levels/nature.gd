extends Node3D

@onready var timer_value = $Container/VBoxContainer/TimerValue
@onready var state_value = $Container/VBoxContainer/StateValue
@onready var navigating_npc = $NavigatingNPC

func _process(_delta: float) -> void:
	timer_value.text = str(navigating_npc.state_timer.wait_time)
	state_value.text = navigating_npc.States.keys()[navigating_npc.state]
