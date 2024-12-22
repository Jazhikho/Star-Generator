extends Node3D

@onready var galaxy_environment = $WorldEnvironment
@export var system_data: Array 
var camera: Camera3D
var galaxy_view: Node3D
var system_view: Node3D
var object_view: Node3D

enum ViewType {
	GALAXY,
	SYSTEM,
	OBJECT
}

var current_view: ViewType = ViewType.GALAXY
var star_data_map = {}
var space_state: PhysicsDirectSpaceState3D
var double_click_timer: Timer
const DOUBLE_CLICK_TIME = 0.3
var processing_click = false
var last_process_time = 0.0
const PROCESS_COOLDOWN = 0.1  # 100ms cooldown
var is_waiting_for_double_click = false
var last_clicked_star
var ray_length = 10000

signal view_changed(view_type: ViewType)
signal star_selected(star_data: Dictionary)
signal planet_selected(planet_data: Dictionary)

func _ready():
	print("ViewManager initializing...")
	print("Current path:", get_path())
	print("Parent:", get_parent())
	print("Children:", get_children())
	
	# Wait a frame to ensure all nodes are ready
	await get_tree().process_frame
	
	# Initialize node references
	camera = $Camera3D
	galaxy_view = $GalaxyView
	system_view = $SystemView
	object_view = $ObjectView
	
	if !camera || !galaxy_view || !system_view || !object_view:
		push_error("Required nodes not found in ViewManager")
		return
		
	print("Found nodes:")
	print("Camera:", camera)
	print("Galaxy View:", galaxy_view)
	print("System View:", system_view)
	print("Object View:", object_view)
	
	# Continue with your initialization
	space_state = get_world_3d().direct_space_state
	
	# Initialize views
	if system_view:
		system_view.visible = false
	if object_view:
		object_view.visible = false
	
	# Setup galaxy view
	setup_galaxy_view()
	
	# Initial camera position
	var pars = GlobalSettings.galaxy_settings.parsecs
	var cam_x = GlobalSettings.galaxy_settings.x_sector * pars / 2
	var cam_y = GlobalSettings.galaxy_settings.y_sector * pars / 2
	var cam_z = GlobalSettings.galaxy_settings.z_sector * pars / 2
	camera.position = Vector3(0, cam_y, cam_z)
	camera.look_at(Vector3(cam_x, cam_y, cam_z))
	
	double_click_timer = Timer.new()
	double_click_timer.wait_time = DOUBLE_CLICK_TIME
	double_click_timer.one_shot = true
	add_child(double_click_timer)
	double_click_timer.timeout.connect(_on_double_click_timer_timeout)

func setup_galaxy_view():
	var star_list = []
	for star_id in GlobalData.galaxy_data:
		var star_info = GlobalData.galaxy_data[star_id]
		var coords = star_info["coordinates"]
		var luminosity = star_info["luminosity"]
		var temperature = star_info["temperature"]
		
		star_list.append({
			"coords": coords,
			"luminosity": luminosity,
			"temperature": temperature
		})
		star_data_map[coords] = star_info
	
	setup_collision_system()
	galaxy_view.get_node("StarManager").set_star_list(star_list)

func setup_collision_system():
	for coords in star_data_map:
		var collision_sphere = Area3D.new()
		var collision_shape = CollisionShape3D.new()
		var sphere_shape = SphereShape3D.new()
		
		sphere_shape.radius = 2.0
		collision_shape.shape = sphere_shape
		collision_sphere.add_child(collision_shape)
		collision_sphere.position = coords
		collision_sphere.collision_layer = 1
		collision_sphere.collision_mask = 1
		collision_sphere.set_meta("star_data", star_data_map[coords])
		
		collision_sphere.input_ray_pickable = false
		collision_sphere.input_capture_on_drag = false
		
		galaxy_view.add_child(collision_sphere)
		
func clear_collision_spheres():
	for child in galaxy_view.get_children():
		if child is Area3D:
			child.queue_free()
		
func transition_to_system_view(system_data: Array):
	print("Transitioning to system view")
	current_view = ViewType.SYSTEM
	
	if system_view:
		clear_collision_spheres()  # Clear galaxy view collision spheres
		system_view.set_system_data(system_data)
		system_view.create_system()
		
		var tween = create_tween()
		tween.tween_property(camera, "position", Vector3(0, 50, 100), 1.0)
		tween.parallel().tween_property(camera, "rotation", Vector3(-PI/6, 0, 0), 1.0)
		
		await tween.finished
		
		galaxy_view.visible = false
		system_view.visible = true
		
		emit_signal("view_changed", ViewType.SYSTEM)
	else:
		push_error("System view not found!")

func transition_to_object_view(object_data: Dictionary):
	current_view = ViewType.OBJECT
	
	var tween = create_tween()
	tween.tween_property(camera, "position", Vector3(0, 10, 30), 1.0)
	
	await tween.finished
	
	system_view.visible = false
	object_view.visible = true
	object_view.initialize(object_data)
	
	emit_signal("view_changed", ViewType.OBJECT)

func return_to_galaxy_view():
	current_view = ViewType.GALAXY
	
	system_view.clear_system()  # Add this call
	setup_collision_system()  # Recreate galaxy collision spheres
	
	var tween = create_tween()
	tween.tween_property(camera, "position", Vector3(0, 0, 100), 1.0)
	tween.parallel().tween_property(camera, "rotation", Vector3.ZERO, 1.0)
	
	await tween.finished
	
	system_view.visible = false
	object_view.visible = false
	galaxy_view.visible = true
	
	emit_signal("view_changed", ViewType.GALAXY)

func handle_click(event_position: Vector2):
	# Add time-based cooldown check
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - last_process_time < PROCESS_COOLDOWN:
		return
	
	if processing_click:
		return
		
	processing_click = true
	last_process_time = current_time
	
	print("ViewManager handling click at:", event_position)
	
	if !camera or !space_state:
		print("No camera reference or space state!")
		processing_click = false
		return
	
	var from = camera.project_ray_origin(event_position)
	var to = from + camera.project_ray_normal(event_position) * ray_length
	
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = true
	query.collision_mask = 1
	
	var result = space_state.intersect_ray(query)
	
	if result and result.collider is Area3D and result.collider.has_meta("star_data"):
		var star_data = result.collider.get_meta("star_data")
		print("Star clicked:", star_data)
		
		if is_waiting_for_double_click and last_clicked_star == star_data:
			print("Detected as double click")
			handle_double_click(star_data)
			is_waiting_for_double_click = false
			double_click_timer.stop()
		else:
			print("Detected as single click")
			handle_single_click(star_data)
			is_waiting_for_double_click = true
			last_clicked_star = star_data
			double_click_timer.start()
	
	# Reset the processing flag at the end
	processing_click = false

func handle_single_click(star_data: Dictionary):
	print("Processing single click")
	emit_signal("star_selected", star_data)

func handle_double_click(star_data: Dictionary):
	print("Processing double click")
	if GlobalData.systems_data.has(star_data.id):
		print("Transitioning to system view")
		transition_to_system_view(GlobalData.systems_data[star_data.id].data)

func _on_double_click_timer_timeout():
	is_waiting_for_double_click = false

# Camera control methods
func zoom_in():
	if camera:
		camera.position.z = max(camera.position.z - 5, 10)
		print("Camera zoomed in: ", camera.position.z)

func zoom_out():
	if camera:
		camera.position.z = min(camera.position.z + 5, 1000)
		print("Camera zoomed out: ", camera.position.z)

func rotate_left():
	if camera:
		camera.rotation.y += 0.1
		print("Camera rotated left: ", camera.rotation.y)

func rotate_right():
	if camera:
		camera.rotation.y -= 0.1
		print("Camera rotated right: ", camera.rotation.y)

func _input(event):
	if event.is_echo():
		return
		
	if event is InputEventKey:
		match event.keycode:
			KEY_ESCAPE:
				match current_view:
					ViewType.SYSTEM:
						return_to_galaxy_view()
					ViewType.OBJECT:
						transition_to_system_view(system_view.system_data)
	
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Direct click detected in ViewManager")
		get_viewport().set_input_as_handled()  # Move this before handle_click
		var mouse_pos = get_viewport().get_mouse_position()
		handle_click(mouse_pos)

func _process(_delta):
	if Input.is_action_pressed("ui_cancel"):
		match current_view:
			ViewType.SYSTEM:
				return_to_galaxy_view()
			ViewType.OBJECT:
				transition_to_system_view(system_view.system_data)
