extends Node

@onready var info_panel = $InfoPanel
@onready var info_title = $InfoPanel/InfoContent/InfoTitle
@onready var info_text = $InfoPanel/InfoContent/InfoText

@onready var menu_panel = $MenuPanel
@onready var view_manager = $VBoxContainer/SceneView/SubViewport/ViewManager
@onready var sub_viewport = $VBoxContainer/SceneView/SubViewport

var main_menu_scene = preload("res://scenes/GUI/MainMenu/MainMenu.tscn")
var current_menu_instance = null

@onready var input_manager = $InputManager
@onready var ui_manager = $UIManager
@onready var data_processor = $DataProcessor
@onready var camera = $VBoxContainer/SceneView/SubViewport/ViewManager/Camera3D

func _ready():
	ui_manager.initialize($MenuPanel, $InfoPanel) 	# Initialize UI manager
	connect_all_signals()							# Connect all the UI signals
	get_viewport().size_changed.connect(_on_viewport_size_changed)	# Connect viewport size change signal

# Centralized function to connect all signals
func connect_all_signals():
	# Input manager signals
	input_manager.connect("mouse_clicked", Callable(view_manager, "handle_click"))
	camera.connect("zoom_in_requested", Callable(camera, "zoom_in"))
	camera.connect("zoom_out_requested", Callable(camera, "zoom_out"))
	camera.connect("rotate_left_requested", Callable(camera, "rotate_left"))
	camera.connect("rotate_right_requested", Callable(camera, "rotate_right"))

	# UI manager signals
	ui_manager.connect("main_menu_toggled", Callable(self, "_on_main_menu_toggled"))
	ui_manager.connect("generate_jump_routes_pressed", Callable(self, "_on_generate_jump_routes_pressed"))
	ui_manager.connect("anomaly_toggled", Callable(self, "_on_anomaly_toggle"))
	ui_manager.connect("jump_route_toggled", Callable(self, "_on_jump_route_toggle"))
	ui_manager.connect("populated_toggled", Callable(self, "_on_populated_toggle"))

	# View manager signals
	view_manager.connect("star_selected", Callable(self, "_on_star_selected"))
	view_manager.connect("planet_selected", Callable(self, "_on_planet_selected"))
	view_manager.connect("view_changed", Callable(self, "_on_view_changed"))

func _on_viewport_size_changed():
	if sub_viewport:
		sub_viewport.size = get_viewport().size

func _on_mouse_clicked(position: Vector2, is_double_click: bool):
	view_manager.handle_click(position, is_double_click)

func _on_escape_pressed():
	if menu_panel.visible:
		ui_manager.hide_main_menu()
	else:
		ui_manager.show_main_menu()

func _on_zoom_in():
	view_manager.zoom_in()

func _on_zoom_out():
	view_manager.zoom_out()

func _on_rotate_left():
	view_manager.rotate_left()

func _on_rotate_right():
	view_manager.rotate_right()

func _on_main_menu_toggled(is_visible: bool):
	if is_visible:
		if !current_menu_instance:
			current_menu_instance = main_menu_scene.instantiate()
			$MenuPanel.add_child(current_menu_instance)
			current_menu_instance.mouse_filter = Control.MOUSE_FILTER_STOP
			
			var buttons_container = current_menu_instance.find_child("MenuButtons", true, false)
			if buttons_container:
				for button in buttons_container.get_children():
					if button is Button:
						button.mouse_filter = Control.MOUSE_FILTER_STOP

func _on_generate_jump_routes_pressed():
	print("Generate jump routes pressed")
	# TODO: Implement jump route generation

func _on_anomaly_toggle(button_pressed: bool):
	print("Anomalies visible: ", button_pressed)
	# TODO: Implement anomaly visibility toggle

func _on_jump_route_toggle(button_pressed: bool):
	print("Jump routes visible: ", button_pressed)
	# TODO: Implement jump route visibility toggle

func _on_populated_toggle(button_pressed: bool):
	print("Only populated stars: ", button_pressed)
	# TODO: Implement star population filter

func _on_star_selected(star_data: Dictionary):
	var formatted_data = data_processor.format_star_info(star_data)
	ui_manager.show_info(star_data.get("ID", "System Undefined"), formatted_data)

func _on_planet_selected(planet_data: Dictionary):
	var formatted_data = data_processor.format_planet_info(planet_data)
	ui_manager.show_info(planet_data.get("name", "Unknown Planet"), formatted_data)

func _on_view_changed(view_type: int):
	ui_manager.update_view_controls(view_type == view_manager.ViewType.GALAXY)
