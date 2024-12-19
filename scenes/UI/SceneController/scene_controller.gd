extends Node

@onready var ui_layer = preload("res://scenes/UI/UIController.tscn").instantiate()
var current_scene : Node

func _ready():
	# Add UI layer
	add_child(ui_layer)
	
	# Load main menu
	load_scene("res://scenes/MainMenu/MainMenu.tscn")

func load_scene(scene_path: String):
	# Remove current scene if it exists
	if current_scene:
		remove_child(current_scene)
		current_scene.queue_free()
	
	# Load new scene
	var new_scene = load(scene_path).instantiate()
	add_child(new_scene)
	current_scene = new_scene
	
	# If the scene has a camera, set it as the UI camera
	if current_scene.has_node("Camera3D"):
		ui_layer.set_camera(current_scene.get_node("Camera3D"))

# Example transition functions
func to_main_menu():
	load_scene("res://scenes/MainMenu/MainMenu.tscn")

func to_galaxy_view():
	load_scene("res://path/to/galaxy_view.tscn")

func to_system_view(system_data: Array):
	load_scene("res://path/to/system_view.tscn")
	# Assuming system_view script has a method to set system data
	current_scene.set_system_data(system_data)
