extends CanvasLayer

@onready var info_panel = $MainContainer/VBoxContainer/InfoPanel
@onready var info_title = $MainContainer/VBoxContainer/InfoPanel/InfoContent/InfoTitle
@onready var info_text = $MainContainer/VBoxContainer/InfoPanel/InfoContent/InfoText

@onready var anomaly_toggle = $MainContainer/VBoxContainer/TopBar/ViewControls/AnomalyToggle
@onready var jump_route_toggle = $MainContainer/VBoxContainer/TopBar/ViewControls/JumpRouteToggle
@onready var populated_toggle = $MainContainer/VBoxContainer/TopBar/ViewControls/PopulatedToggle

@onready var main_menu_button = $MainContainer/VBoxContainer/TopBar/MainMenuButton
@onready var gen_jump_routes = $MainContainer/VBoxContainer/TopBar/ViewControls/GenerateJumpRoutesButton

@onready var zoom_in_button = $MainContainer/CameraControls/HBoxContainer/ZoomIn
@onready var zoom_out_button = $MainContainer/CameraControls/HBoxContainer/ZoomOut
@onready var rotate_left_button = $MainContainer/CameraControls/HBoxContainer/RotateLeft
@onready var rotate_right_button = $MainContainer/CameraControls/HBoxContainer/RotateRight

var camera : Camera3D

signal main_menu_requested
signal galaxy_view_requested

var current_menu_instance = null

func _ready():
	# Connect signals
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	gen_jump_routes.pressed.connect(_on_generate_jump_routes_pressed)
	
	anomaly_toggle.toggled.connect(_on_anomaly_toggle)
	jump_route_toggle.toggled.connect(_on_jump_route_toggle)
	populated_toggle.toggled.connect(_on_populated_toggle)
	
	zoom_in_button.pressed.connect(_on_zoom_in)
	zoom_out_button.pressed.connect(_on_zoom_out)
	rotate_left_button.pressed.connect(_on_rotate_left)
	rotate_right_button.pressed.connect(_on_rotate_right)
	
	# Hide info panel by default
	info_panel.visible = false
	
	# Show the main container by default
	$MainContainer.visible = true
	$MainContainer.mouse_filter = Control.MOUSE_FILTER_STOP
	$MainContainer/VBoxContainer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$MainContainer/VBoxContainer/TopBar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Make sure buttons can receive input
	for button in $MainContainer/VBoxContainer/TopBar.get_children():
		if button is Button:
			button.mouse_filter = Control.MOUSE_FILTER_STOP

func set_camera(cam: Camera3D):
	camera = cam
	if cam:
		$MainContainer/CameraControls.visible = true
	else:
		$MainContainer/CameraControls.visible = false

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
	if camera:
		camera.position.z = max(camera.position.z - 5, 10)  # Adjust as needed

func _on_zoom_out():
	if camera:
		camera.position.z = min(camera.position.z + 5, 1000)  # Adjust as needed

func _on_rotate_left():
	if camera:
		camera.rotation.y += 0.1  # Adjust rotation speed as needed

func _on_rotate_right():
	if camera:
		camera.rotation.y -= 0.1  # Adjust rotation speed as needed

func show_galaxy_view_ui():
	$MainContainer.visible = true

func hide_galaxy_view_ui():
	$MainContainer.visible = false

func _on_main_menu_pressed():
	get_node("/root/Main").toggle_main_menu()

func to_main_menu():
	emit_signal("main_menu_requested")

func to_galaxy_view():
	emit_signal("galaxy_view_requested")

func show_main_menu(menu_scene):
	# Clear any existing menu
	if current_menu_instance:
		current_menu_instance.queue_free()
	
	# Instantiate new menu
	current_menu_instance = menu_scene.instantiate()
	
	# Add it to the info panel
	info_panel.visible = true
	info_text.visible = false  # Hide the default info text
	info_title.visible = false  # Hide the default info title
	
	info_panel.add_child(current_menu_instance)

func hide_main_menu():
	if current_menu_instance:
		current_menu_instance.queue_free()
		current_menu_instance = null
	
	info_panel.visible = false
	info_text.visible = true
	info_title.visible = true

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			var mouse_pos = get_viewport().get_mouse_position()
			print("Mouse clicked at: ", mouse_pos)
			# Check if any buttons should handle this
			for button in $MainContainer/VBoxContainer/TopBar.get_children():
				if button is Button:
					var rect = button.get_global_rect()
					if rect.has_point(mouse_pos):
						print("Should click button: ", button.name)
						button.pressed.emit()
