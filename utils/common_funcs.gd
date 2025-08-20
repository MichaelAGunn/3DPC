extends Node

const loading_screen_path : String = "res://Menus/loading_screen.tscn"
var parameters: Dictionary

func load_screen_to_scene(target: String, parameters: Dictionary) -> void:
	var loading_screen = preload(loading_screen_path).instantiate()
	loading_screen.next_scene_path = target
	loading_screen.parameters = parameters
	get_tree().current_scene.add_child(loading_screen)
