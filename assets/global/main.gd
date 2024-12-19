extends Node

@onready var ui = $UI
@onready var view_container = $ViewContainer
@onready var current_view = $ViewContainer/SubViewport/CurrentView

var main_menu_scene = preload("res://scenes/MainMenu/MainMenu.tscn")
var galaxy_view_scene = preload("res://scenes/GalaxyView/galaxy_view.tscn")

func _ready():
	load_main_menu()
	ui.connect("main_menu_requested", Callable(self, "load_main_menu"))
	ui.connect("galaxy_view_requested", Callable(self, "load_galaxy_view"))

func load_main_menu():
	transition_to_scene(main_menu_scene)

func load_galaxy_view():
	transition_to_scene(galaxy_view_scene)

func transition_to_scene(scene):
	var new_scene = scene.instantiate()
	
	# Set up tween for fade out
	var tween = create_tween()
	tween.tween_property(current_view, "color:a", 1.0, 0.5)
	
	# Wait for fade out to complete
	await tween.finished
	
	# Remove old scene and add new one
	for child in current_view.get_children():
		child.queue_free()
	current_view.add_child(new_scene)
	
	# Set up tween for fade in
	tween = create_tween()
	tween.tween_property(current_view, "color:a", 0.0, 0.5)
