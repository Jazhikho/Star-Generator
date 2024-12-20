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
var current_scene_camera: Camera3D
var current_scene = null
var scene_history = []

signal galaxy_view_requested

func _ready():
	$VBoxContainer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$VBoxContainer/SceneView.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sub_viewport.handle_input_locally = true
	sub_viewport.gui_disable_input = false
	connect("galaxy_view_requested", Callable(self, "load_galaxy_view"))
	sub_viewport.size = get_viewport().size
	$VBoxContainer/SceneView.gui_input.connect(_on_scene_view_gui_input)
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	
	print("Checking SubViewport setup...")
	if sub_viewport:
		print("SubViewport exists")
		if sub_viewport.world_3d:
			print("SubViewport world_3d exists")
		else:
			print("SubViewport world_3d is null")
			
		# Try to ensure the world is created
		sub_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	else:
		print("SubViewport is null")
	
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
	print("load_system_view called with data: ", system_data)
	var system_view_instance = system_view_scene.instantiate()
	system_view_instance.system_data = system_data
	transition_to_scene(system_view_instance)

func load_object_view(object_data: Dictionary):
	var object_view_instance = object_view_scene.instantiate()
	object_view_instance.object_data = object_data
	transition_to_scene(object_view_instance)

func transition_to_scene(scene):
	if scene is PackedScene:
		scene = scene.instantiate()
	
	var tween = create_tween()
	tween.tween_property(current_view, "color:a", 1.0, 0.5)
	
	await tween.finished
	
	if current_scene:
		scene_history.append(current_scene)
		current_view.remove_child(current_scene)
	
	current_view.add_child(scene)
	current_scene = scene
	
	# Ensure SubViewport is updated
	sub_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	
	# Wait a frame to ensure the world is created
	await get_tree().process_frame
	
	print("World3D after transition:", current_scene.get_world_3d() != null)
	
	update_camera_reference()
	
	tween = create_tween()
	tween.tween_property(current_view, "color:a", 0.0, 0.5)

func update_camera_reference():
	print("Updating camera reference...")
	if current_scene:
		print("Current scene:", current_scene.name)
		var camera = current_scene.find_child("Camera3D", true, false)
		if camera:
			current_scene_camera = camera
			print("Found camera:", camera)
			$VBoxContainer/CameraControls.visible = true
		else:
			current_scene_camera = null
			print("No camera found in scene")
			$VBoxContainer/CameraControls.visible = false
	else:
		print("No current scene")

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
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Left mouse button pressed")
		
		if not current_scene:
			print("No current scene!")
			return
		
		print("Current scene:", current_scene.name)
		print("Current scene children:", current_scene.get_children())
		
		var camera = current_scene.find_child("Camera3D", true, false)
		if not camera:
			print("No Camera3D found in current scene!")
			return
		
		var viewport_container = $VBoxContainer/SceneView
		var local_mouse_pos = viewport_container.get_local_mouse_position()
		
		print("Local mouse position:", local_mouse_pos)
		print("Viewport container rect:", viewport_container.get_rect())
		
		if not viewport_container.get_rect().has_point(local_mouse_pos):
			print("Click is outside viewport container")
			return
		
		print("Click is within viewport container")
		
		var from = camera.project_ray_origin(local_mouse_pos)
		var to = from + camera.project_ray_normal(local_mouse_pos) * 1000
		
		print("Ray from:", from, " to:", to)
		
		# Use the current scene's World3D directly
		var world_3d = current_scene.get_world_3d()
		if not world_3d:
			print("No World3D found in current scene!")
			return
		
		var space_state = world_3d.direct_space_state
		var query = PhysicsRayQueryParameters3D.create(from, to)
		var result = space_state.intersect_ray(query)
		
		if result.is_empty():
			print("Ray didn't hit anything")
		else:
			print("Ray hit:", result)
			if result.collider is Area3D:
				print("Hit an Area3D")
				if result.collider.has_meta("star_data"):
					var star_data = result.collider.get_meta("star_data")
					print("Star clicked: ", star_data.id)
					if current_scene.has_method("_on_star_clicked"):
						current_scene._on_star_clicked(star_data)
					else:
						print("Current scene doesn't have _on_star_clicked method")
				else:
					print("Area3D doesn't have star_data")
			else:
				print("Hit object is not an Area3D:", result.collider)

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

func _on_scene_view_gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if current_scene and "Camera3D" in current_scene:
			var camera = current_scene.get_node("Camera3D")
			var viewport_container = $VBoxContainer/SceneView
			var local_mouse_pos = viewport_container.get_local_mouse_position()
			
			var from = camera.project_ray_origin(local_mouse_pos)
			var to = from + camera.project_ray_normal(local_mouse_pos) * 1000
			
			var space_state = sub_viewport.world_3d.direct_space_state
			var query = PhysicsRayQueryParameters3D.create(from, to)
			var result = space_state.intersect_ray(query)
			
			if result and result.collider is Area3D and result.collider.has_meta("star_data"):
				var star_data = result.collider.get_meta("star_data")
				print("Star clicked: ", star_data.id)
				if current_scene.has_method("_on_star_clicked"):
					current_scene._on_star_clicked(star_data)

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if current_scene and current_scene is Node3D: # Assuming GalaxyView is a Node3D
			var viewport = $VBoxContainer/SceneView/SubViewport
			var mouse_pos = get_viewport().get_mouse_position()
			
			# Convert mouse position to SubViewport coordinates
			var viewport_container = $VBoxContainer/SceneView
			var local_mouse_pos = viewport_container.get_local_mouse_position()
			
			# Get the camera from the current scene
			var camera = current_scene.get_node("Camera3D")
			if camera:
				var from = camera.project_ray_origin(local_mouse_pos)
				var to = from + camera.project_ray_normal(local_mouse_pos) * 1000
				
				var space_state = viewport.world_3d.direct_space_state
				var query = PhysicsRayQueryParameters3D.create(from, to)
				var result = space_state.intersect_ray(query)
				
				if result and result.collider is Area3D and result.collider.has_meta("star_data"):
					var star_data = result.collider.get_meta("star_data")
					print("Star clicked: ", star_data.id)
					if current_scene.has_method("_on_star_clicked"):
						current_scene._on_star_clicked(star_data)
