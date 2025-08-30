extends Node3D

@onready var timer_value = $Container/VBoxContainer/TimerValue
@onready var state_value = $Container/VBoxContainer/StateValue
#@onready var navigating_npc = $NavigatingNPC
@onready var npcs = $NPCs

func _process(_delta: float) -> void:
	for npc in npcs.get_children():
		timer_value.text = str(npc.state_timer.wait_time)
		state_value.text = npc.States.keys()[npc.state]
