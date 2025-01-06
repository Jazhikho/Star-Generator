extends Node

signal main_menu_toggled(is_visible: bool)
signal generate_jump_routes_pressed
signal anomaly_toggled(is_visible: bool)
signal jump_route_toggled(is_visible: bool)
signal populated_toggled(is_visible: bool)

var menu_panel: Control
var info_panel: PanelContainer
var info_title: Label
var info_text: RichTextLabel

# References to controls in the main scene
var main_menu_button: Button
var anomaly_toggle: CheckButton
var jump_route_toggle: CheckButton
var populated_toggle: CheckButton
var gen_jump_routes: Button
var view_controls: Control

func initialize(menu: Control, info: PanelContainer):
	menu_panel = menu
	info_panel = info
	info_title = info_panel.get_node("InfoContent/InfoTitle")
	info_text = info_panel.get_node("InfoContent/InfoText")
	
	# Get references to the controls from the main scene
	var main_scene = get_tree().get_root().get_node("Main")
	main_menu_button = main_scene.get_node("VBoxContainer/TopBar/MainMenuButton")
	anomaly_toggle = main_scene.get_node("VBoxContainer/TopBar/ViewControls/AnomalyToggle")
	jump_route_toggle = main_scene.get_node("VBoxContainer/TopBar/ViewControls/JumpRouteToggle")
	populated_toggle = main_scene.get_node("VBoxContainer/TopBar/ViewControls/PopulatedToggle")
	gen_jump_routes = main_scene.get_node("VBoxContainer/TopBar/ViewControls/GenerateJumpRoutesButton")
	view_controls = main_scene.get_node("VBoxContainer/TopBar/ViewControls")
	
	# Connect the close button if it exists
	var close_button = menu_panel.get_node("CloseButton")
	if close_button:
		close_button.pressed.connect(hide_main_menu)
	
	connect_signals()

func connect_signals():
	# Connect main menu button
	if main_menu_button:
		main_menu_button.pressed.connect(_on_main_menu_button_pressed)
	
	# Connect other controls
	if anomaly_toggle:
		anomaly_toggle.toggled.connect(_on_anomaly_toggle)
	if jump_route_toggle:
		jump_route_toggle.toggled.connect(_on_jump_route_toggle)
	if populated_toggle:
		populated_toggle.toggled.connect(_on_populated_toggle)
	if gen_jump_routes:
		gen_jump_routes.pressed.connect(_on_generate_jump_routes_pressed)

func _on_main_menu_button_pressed():
	if menu_panel.visible:
		hide_main_menu()
	else:
		show_main_menu()

func show_main_menu():
	menu_panel.visible = true
	emit_signal("main_menu_toggled", true)

func hide_main_menu():
	menu_panel.visible = false
	emit_signal("main_menu_toggled", false)

func show_info(title: String, content: String):
	info_title.text = title
	info_text.text = content
	info_panel.visible = true

func hide_info():
	info_panel.visible = false

func update_view_controls(is_galaxy_view: bool):
	if view_controls:
		view_controls.visible = is_galaxy_view

func _on_anomaly_toggle(button_pressed: bool):
	emit_signal("anomaly_toggled", button_pressed)

func _on_jump_route_toggle(button_pressed: bool):
	emit_signal("jump_route_toggled", button_pressed)

func _on_populated_toggle(button_pressed: bool):
	emit_signal("populated_toggled", button_pressed)

func _on_generate_jump_routes_pressed():
	emit_signal("generate_jump_routes_pressed")
