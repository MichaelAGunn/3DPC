extends CanvasLayer

@export_file("*.tscn") var next_scene_path: String # Which scene to load
@export var parameters: Dictionary

func _ready() -> void:
	ResourceLoader.load_threaded_request(next_scene_path) # Begin loading

func _process(delta: float) -> void:
	if ResourceLoader.load_threaded_get_status(next_scene_path) == ResourceLoader.THREAD_LOAD_LOADED:
		set_process(false)
		await get_tree().create_timer(1).timeout # Artificial delay for testing only
		var new_scene: PackedScene = ResourceLoader.load_threaded_get(next_scene_path)
		#get_tree().change_scene_to_packed(new_scene) # Cannot pass parameters to the next scene.
		var new_node := new_scene.instantiate()
		new_node.parameters = parameters
		# Change out scenes in the Scene Tree.
		var current_scene = get_tree().current_scene
		get_tree().get_root().add_child(new_node)
		get_tree().current_scene = new_node
		current_scene.queue_free()
