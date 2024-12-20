extends Node

@onready var info_panel = $InfoPanel
@onready var info_title = $InfoPanel/InfoContent/InfoTitle
@onready var info_text = $InfoPanel/InfoContent/InfoText

@onready var anomaly_toggle = $VBoxContainer/TopBar/ViewControls/AnomalyToggle
@onready var jump_route_toggle = $VBoxContainer/TopBar/ViewControls/JumpRouteToggle
@onready var populated_toggle = $VBoxContainer/TopBar/ViewControls/PopulatedToggle

@onready var main_menu_button = $VBoxContainer/TopBar/MainMenuButton
@onready var gen_jump_routes = $VBoxContainer/TopBar/ViewControls/GenerateJumpRoutesButton

@onready var zoom_in_button = $VBoxContainer/CameraControls/ZoomIn
@onready var zoom_out_button = $VBoxContainer/CameraControls/ZoomOut
@onready var rotate_left_button = $VBoxContainer/CameraControls/RotateLeft
@onready var rotate_right_button = $VBoxContainer/CameraControls/RotateRight

@onready var menu_panel = $MenuPanel
@onready var current_view = $VBoxContainer/SceneView/SubViewport/CurrentView
@onready var sub_viewport = $VBoxContainer/SceneView/SubViewport

var title_screen_scene = preload("res://scenes/TitleScreen/TitleScreen.tscn")
var main_menu_scene = preload("res://scenes/MainMenu/MainMenu.tscn")
var galaxy_view_scene = preload("res://scenes/GalaxyView/galaxy_view.tscn")
var system_view_scene = preload("res://scenes/SystemView/system_view.tscn")
var object_view_scene = preload("res://scenes/ObjectView/object_view.tscn")

var current_menu_instance = null
var current_scene_camera : Camera3D
var current_scene = null
var scene_history = []

signal galaxy_view_requested

func _ready():
	connect("galaxy_view_requested", Callable(self, "load_galaxy_view"))
	sub_viewport.size = get_viewport().size
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	
	# Connect signals
	main_menu_button.pressed.connect(toggle_main_menu)
	gen_jump_routes.pressed.connect(_on_generate_jump_routes_pressed)
	
	anomaly_toggle.toggled.connect(_on_anomaly_toggle)
	jump_route_toggle.toggled.connect(_on_jump_route_toggle)
	populated_toggle.toggled.connect(_on_populated_toggle)
	
	zoom_in_button.pressed.connect(_on_zoom_in)
	zoom_out_button.pressed.connect(_on_zoom_out)
	rotate_left_button.pressed.connect(_on_rotate_left)
	rotate_right_button.pressed.connect(_on_rotate_right)
	
	load_title_screen()
	
	menu_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	$MenuPanel/CloseButton.pressed.connect(hide_main_menu)
	
	# Hide info panel by default
	info_panel.visible = false

func load_title_screen():
	transition_to_scene(title_screen_scene)

func toggle_main_menu():
	if menu_panel.visible:
		hide_main_menu()
	else:
		show_main_menu()

func show_main_menu():
	if !current_menu_instance:
		current_menu_instance = main_menu_scene.instantiate()
		$MenuPanel/MenuContainer.add_child(current_menu_instance)
		
		# Make sure the menu can receive input
		current_menu_instance.mouse_filter = Control.MOUSE_FILTER_STOP
		
		# Connect all buttons
		for button in current_menu_instance.get_node("MenuButtons").get_children():
			if button is Button:
				button.mouse_filter = Control.MOUSE_FILTER_STOP
	
	menu_panel.visible = true

func hide_main_menu():
	menu_panel.visible = false

func _on_viewport_size_changed():
	if sub_viewport:
		sub_viewport.size = get_viewport().size

func load_galaxy_view():
	hide_main_menu()
	transition_to_scene(galaxy_view_scene)
	
func load_system_view(system_data: Array):
	var system_view_instance = system_view_scene.instantiate()
	system_view_instance.system_data = system_data
	transition_to_scene(system_view_instance)

func load_object_view(object_data: Dictionary):
	var object_view_instance = object_view_scene.instantiate()
	object_view_instance.object_data = object_data
	transition_to_scene(object_view_instance)

func transition_to_scene(scene):
	var new_scene = scene.instantiate()
	
	# Set up tween for fade out
	var tween = create_tween()
	tween.tween_property(current_view, "color:a", 1.0, 0.5)
	
	# Wait for fade out to complete
	await tween.finished
	
	# Remove old scene and add new one
	if current_scene:
		scene_history.append(current_scene)
		current_view.remove_child(current_scene)
	
	# Add new scene
	current_view.add_child(new_scene)
	current_scene = new_scene
	
	# Update camera reference
	update_camera_reference()
	
	# Set up tween for fade in
	tween = create_tween()
	tween.tween_property(current_view, "color:a", 0.0, 0.5)

func update_camera_reference():
	var current_scene = current_view.get_child(0) if current_view.get_child_count() > 0 else null
	if current_scene:
		var potential_camera = current_scene.find_child("Camera3D", true, false)
		if potential_camera is Camera3D:
			current_scene_camera = potential_camera
			$VBoxContainer/CameraControls.visible = true
		else:
			current_scene_camera = null
			$VBoxContainer/CameraControls.visible = false
			print("Warning: No Camera3D found in the current scene")
	else:
		current_scene_camera = null
		$VBoxContainer/CameraControls.visible = false
		print("Warning: No scene loaded in current_view")

# UI Functionality
func show_info(title: String, content: String):
	info_title.text = title
	info_text.text = content
	info_panel.visible = true

func hide_info():
	info_panel.visible = false

# Button callbacks
func _on_generate_jump_routes_pressed():
	print("Generate jump routes pressed")
	# TODO: Implement jump route generation

# Toggle callbacks
func _on_anomaly_toggle(button_pressed: bool):
	print("Anomalies visible: ", button_pressed)
	# TODO: Toggle anomaly visibility

func _on_jump_route_toggle(button_pressed: bool):
	print("Jump routes visible: ", button_pressed)
	# TODO: Toggle jump route visibility

func _on_populated_toggle(button_pressed: bool):
	print("Only populated stars: ", button_pressed)
	# TODO: Filter stars based on population

# Camera control callbacks
func _on_zoom_in():
	if current_scene_camera:
		current_scene_camera.position.z = max(current_scene_camera.position.z - 5, 10)

func _on_zoom_out():
	if current_scene_camera:
		current_scene_camera.position.z = min(current_scene_camera.position.z + 5, 1000)

func _on_rotate_left():
	if current_scene_camera:
		current_scene_camera.rotation.y += 0.1

func _on_rotate_right():
	if current_scene_camera:
		current_scene_camera.rotation.y -= 0.1

func _input(event):
	if event.is_action_pressed("return"):
		return_to_previous_scene()

func return_to_previous_scene():
	if scene_history.size() > 0:
		var previous_scene = scene_history.pop_back()
		
		# Set up tween for fade out
		var tween = create_tween()
		tween.tween_property(current_view, "color:a", 1.0, 0.5)
		
		# Wait for fade out to complete
		await tween.finished
		
		# Remove current scene
		if current_scene:
			current_view.remove_child(current_scene)
			current_scene.queue_free()
		
		# Add previous scene
		current_view.add_child(previous_scene)
		current_scene = previous_scene
		
		# Set up tween for fade in
		tween = create_tween()
		tween.tween_property(current_view, "color:a", 0.0, 0.5)
