extends Node3D

@export var max_spawns: int = 5
@export var spawn_width: float = 5.0
@onready var npc := preload('res://characters/navigating_npc.tscn')
@onready var npc_debug := preload('res://menus/npc_debug.tscn')
@onready var spawn_timer: Timer = $SpawnNPCs/SpawnTimer
@onready var spawn_npcs: Node3D = $SpawnNPCs
@onready var debug_npcs: HBoxContainer = $Container/DebugNPCs
var npc_list: Array = []

func _ready() -> void:
	spawn_timer.start()

func _process(_delta: float) -> void:
	var vboxes = debug_npcs.get_children()
	if len(vboxes) > 0:
		for idx in range(len(vboxes)):
			print("LENGTHS o NPCS: " + str(len(npc_list)) + " & VBOX: " + str(len(vboxes)))
			vboxes[idx].get_child(0).text = 'NPC' + str(idx + 1)
			var time: String = str(npc_list[idx].get_child(3).wait_time)
			vboxes[idx].get_child(2).text = time
			var st: String = npc_list[idx].States.keys()[npc_list[idx].state]
			vboxes[idx].get_child(4).text = st

func get_random_spawn_position() -> Vector2:
	var off_origin := Vector2.ZERO
	off_origin.x += randf_range(-spawn_width, spawn_width)
	off_origin.y += randf_range(-spawn_width, spawn_width)
	return off_origin

func _on_spawn_timer_timeout():
	if len(npc_list) >= max_spawns:
		return
	else:
		var new_npc = npc.instantiate()
		var near_origin = get_random_spawn_position()
		var spawn_position := Vector3.ZERO
		spawn_position.x += near_origin.x
		spawn_position.z += near_origin.y
		new_npc.global_transform.origin = spawn_position
		spawn_npcs.add_child(new_npc)
		npc_list.append(new_npc)
		var new_debug_npc = npc_debug.instantiate()
		debug_npcs.add_child(new_debug_npc)
