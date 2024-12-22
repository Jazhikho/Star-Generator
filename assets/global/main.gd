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
@onready var view_manager = $VBoxContainer/SceneView/SubViewport/ViewManager
@onready var sub_viewport = $VBoxContainer/SceneView/SubViewport

var main_menu_scene = preload("res://scenes/MainMenu/MainMenu.tscn")
var current_menu_instance = null

func _ready():
	if !InputMap.has_action("return"):
		InputMap.add_action("return")
		var event = InputEventKey.new()
		event.keycode = KEY_R
		InputMap.action_add_event("return", event)
	
	main_menu_button.pressed.connect(toggle_main_menu)
	gen_jump_routes.pressed.connect(_on_generate_jump_routes_pressed)
	
	anomaly_toggle.toggled.connect(_on_anomaly_toggle)
	jump_route_toggle.toggled.connect(_on_jump_route_toggle)
	populated_toggle.toggled.connect(_on_populated_toggle)
	
	zoom_in_button.pressed.connect(_on_zoom_in)
	zoom_out_button.pressed.connect(_on_zoom_out)
	rotate_left_button.pressed.connect(_on_rotate_left)
	rotate_right_button.pressed.connect(_on_rotate_right)
	
	menu_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	$MenuPanel/CloseButton.pressed.connect(hide_main_menu)
	$VBoxContainer/SceneView.gui_input.connect(_on_scene_view_gui_input)
	
	# Hide info panel by default
	info_panel.visible = false
	
	# Connect to ViewManager signals
	view_manager.star_selected.connect(_on_star_selected)
	view_manager.planet_selected.connect(_on_planet_selected)
	view_manager.view_changed.connect(_on_view_changed)
	
	get_viewport().size_changed.connect(_on_viewport_size_changed)

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

func _on_star_selected(star_data: Dictionary):
	show_info(star_data.get("name", "Unknown Star"), 
			  "Temperature: %s\nLuminosity: %s" % [
				  star_data.get("temperature", "Unknown"),
				  star_data.get("luminosity", "Unknown")
			  ])

func _on_planet_selected(planet_data: Dictionary):
	show_info(planet_data.get("name", "Unknown Planet"),
			  "Type: %s\nMass: %s" % [
				  planet_data.get("type", "Unknown"),
				  planet_data.get("mass", "Unknown")
			  ])

func _on_view_changed(view_type: int):
	match view_type:
		view_manager.ViewType.GALAXY:
			$VBoxContainer/TopBar/ViewControls.visible = true
		view_manager.ViewType.SYSTEM:
			$VBoxContainer/TopBar/ViewControls.visible = false
		view_manager.ViewType.OBJECT:
			$VBoxContainer/TopBar/ViewControls.visible = false

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
	view_manager.zoom_in()

func _on_zoom_out():
	view_manager.zoom_out()

func _on_rotate_left():
	view_manager.rotate_left()

func _on_rotate_right():
	view_manager.rotate_right()

func _on_scene_view_gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Mouse click detected in main.gd")
		var viewport_container = $VBoxContainer/SceneView
		var local_mouse_pos = viewport_container.get_local_mouse_position()
		
		print("Local mouse position:", local_mouse_pos)
		print("Viewport container rect:", viewport_container.get_rect())
		
		if viewport_container.get_rect().has_point(local_mouse_pos):
			print("Click is within viewport bounds")
			view_manager.handle_click(local_mouse_pos)
		else:
			print("Click is outside viewport bounds")

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			if menu_panel.visible:
				hide_main_menu()
			else:
				show_main_menu()
