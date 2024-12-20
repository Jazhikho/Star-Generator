extends Node3D

@onready var system_view_scene = preload("res://scenes/SystemView/system_view.tscn")
var current_view : Node3D
var galaxy_view : Node3D
var system_view : Node3D

@export var min_scale: float = 0.1
@export var max_scale: float = 5.0
@export var zoom_speed: float = 0.1

@onready var camera: Camera3D = $Camera3D
@onready var stars = $StarManager
var star_data_map = {}
const DOUBLE_CLICK_TIME = 0.3
var last_click_time = 0.0
var double_click_timer
var last_clicked_star
var ray_length = 1000
var space_state: PhysicsDirectSpaceState3D

var current_scale: float = 1.0

func _ready():
	current_view = galaxy_view
	space_state = get_world_3d().direct_space_state
	
	print("Galaxy data keys: ", GlobalData.galaxy_data.keys())
	print("Systems data keys: ", GlobalData.systems_data.keys())
	
	var pars = GlobalSettings.galaxy_settings.parsecs
	var cam_x = GlobalSettings.galaxy_settings.x_sector * pars / 2
	var cam_y = GlobalSettings.galaxy_settings.y_sector * pars / 2
	var cam_z = GlobalSettings.galaxy_settings.z_sector * pars / 2
	camera.position = Vector3(0, cam_y, cam_z)
	camera.look_at(Vector3(cam_x, cam_y, cam_z))
	camera.zoom_changed.connect(_on_camera_zoom_changed)
	for coords in star_data_map:
		star_data_map[coords]["original_position"] = coords
	
	double_click_timer = Timer.new()
	double_click_timer.one_shot = true
	double_click_timer.wait_time = 0.3
	add_child(double_click_timer)

	setup_stars()
	setup_collision_system()
			
func setup_stars():
	print("Setting up stars...")
	var star_list = []
	
	# Use GlobalData instead of CSBridge
	if GlobalData.galaxy_data.is_empty():
		print("No galaxy data found in GlobalData")
		return
		
	for star_id in GlobalData.galaxy_data:
		var star_info = GlobalData.galaxy_data[star_id]
		var coords = star_info["coordinates"]
		var luminosity = star_info["luminosity"]
		var temperature = star_info["temperature"]
		
		var star = stars.GalaxyStar.new(coords, luminosity, temperature)
		star_list.append(star)
		star_data_map[coords] = star_info
		star_data_map[coords]["original_position"] = coords
	
	print("Total stars to render: ", star_list.size())
	stars.set_star_list(star_list)

func setup_collision_system():
	for child in get_children():
		if child is Area3D:
			child.queue_free()
	
	for coords in star_data_map:
		var collision_sphere = Area3D.new()
		var collision_shape = CollisionShape3D.new()
		var sphere_shape = SphereShape3D.new()
		
		sphere_shape.radius = 1.0
		collision_shape.shape = sphere_shape
		
		collision_sphere.add_child(collision_shape)
		collision_sphere.position = coords
		collision_sphere.collision_layer = 1
		collision_sphere.collision_mask = 1
		
		collision_sphere.set_meta("star_data", star_data_map[coords])
		collision_sphere.input_event.connect(_on_star_input_event.bind(collision_sphere))
		
		add_child(collision_sphere)

func _on_star_input_event(_camera, event, click_position, click_normal, shape_idx, area: Area3D):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if area.has_meta("star_data"):
			var star_data = area.get_meta("star_data")
			print("Star clicked through input_event: ", star_data.id)  # Debug print
			_on_star_clicked(star_data)

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:  # Button down
			var mouse_pos = get_viewport().get_mouse_position()
			var from = camera.project_ray_origin(mouse_pos)
			var to = from + camera.project_ray_normal(mouse_pos) * ray_length
			
			var query = PhysicsRayQueryParameters3D.create(from, to)
			var result = space_state.intersect_ray(query)
			
			if result and result.collider is Area3D and result.collider.has_meta("star_data"):
				var star_data = result.collider.get_meta("star_data")
				var current_time = Time.get_ticks_msec() / 1000.0
				
				if last_clicked_star != null and last_clicked_star.id == star_data.id:
					if current_time - last_click_time < DOUBLE_CLICK_TIME:
						_on_star_double_clicked(star_data)
						last_clicked_star = null  # Reset after double click
						return
				
				last_clicked_star = star_data
				last_click_time = current_time
				_on_star_clicked(star_data)
				
func _on_star_double_clicked(star_data: Dictionary):
	print("Double-clicked star: ", star_data.id)
	
	if GlobalData.systems_data.has(star_data.id):
		var system_info = GlobalData.systems_data[star_data.id]
		get_node("/root/Main").load_system_view(system_info.data)
		
func transition_to_system_view(system_data: Array):
	galaxy_view.visible = false
	
	# Create and add system view
	system_view = system_view_scene.instantiate()
	add_child(system_view)
	current_view = system_view
	
	# Set system data and create the system
	system_view.system_data = system_data
	system_view.create_system()
	
	# Tween camera
	var camera = $Camera3D
	var tween = create_tween()
	tween.tween_property(camera, "position", Vector3(0, 50, 100), 1.0).set_trans(Tween.TRANS_CUBIC)
	tween.parallel().tween_property(camera, "rotation", Vector3(-PI/6, 0, 0), 1.0).set_trans(Tween.TRANS_CUBIC)

func transition_to_galaxy_view():
	# Remove system view
	if system_view:
		remove_child(system_view)
		system_view.queue_free()
		system_view = null
	
	# Show galaxy view
	galaxy_view.visible = true
	current_view = galaxy_view
	
	# Tween camera back
	var camera = $Camera3D
	var tween = create_tween()
	tween.tween_property(camera, "position", Vector3(0, 0, 100), 1.0).set_trans(Tween.TRANS_CUBIC)
	tween.parallel().tween_property(camera, "rotation", Vector3.ZERO, 1.0).set_trans(Tween.TRANS_CUBIC)

func _on_star_mouse_entered(star_area: Area3D):
	var star_data = star_area.get_meta("star_data")
	# Handle hover effect (e.g., show tooltip)
	print("Hovering over star: ", star_data.id)

func _on_star_mouse_exited(star_area: Area3D):
	# Handle hover exit
	pass

func _on_star_clicked(star_data: Dictionary):
	print("Clicked star: ", star_data.id)  # Debug print
	camera.set_orbit_target(star_data.coordinates)
	if double_click_timer.is_stopped():
		double_click_timer.start()
		last_clicked_star = star_data
	else:
		double_click_timer.stop()
		if last_clicked_star == star_data:
			_on_star_double_clicked(star_data)
		else:
			last_clicked_star = star_data
			double_click_timer.start()

# Optional camera controls
func _process(delta):
	var speed = 50.0 * delta
	
	if Input.is_key_pressed(KEY_W):
		camera.position.z -= speed
	if Input.is_key_pressed(KEY_S):
		camera.position.z += speed
	if Input.is_key_pressed(KEY_A):
		camera.position.x -= speed
	if Input.is_key_pressed(KEY_D):
		camera.position.x += speed
		
		# Debug: Show what's under the mouse
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * ray_length
	
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)
	
	if result:
		if result.collider is Area3D and result.collider.has_meta("star_data"):
			var star_data = result.collider.get_meta("star_data")
			print("Mouse is over star: ", star_data.id)  # Debug print

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = get_viewport().get_mouse_position()
		var ray_origin = camera.project_ray_origin(mouse_pos)
		var ray_end = ray_origin + camera.project_ray_normal(mouse_pos) * 1000
		var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
		var result = get_world_3d().direct_space_state.intersect_ray(query)
		
		if result:
			print("Ray hit: ", result.collider)  # Debug print
			if result.collider is Area3D and result.collider.has_meta("star_data"):
				var star_data = result.collider.get_meta("star_data")
				print("Star data found: ", star_data)  # Debug print
				_on_star_clicked(star_data)
			else:
				print("Hit object is not a star")
		else:
			print("Ray hit nothing")
			
func raycast_from_mouse(mouse_pos):
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * ray_length
	var query = PhysicsRayQueryParameters3D.create(from, to)
	return space_state.intersect_ray(query)

func _on_camera_zoom_changed(zoom_factor: float):
	# Update collision spheres
	for child in get_children():
		if child is Area3D and child.has_meta("star_data"):
			var original_position = child.get_meta("star_data")["original_position"]
			child.position = original_position * zoom_factor
	
	# Update visual stars
	var updated_star_list = []
	for star_id in star_data_map:
		var star_info = star_data_map[star_id]
		var scaled_coords = star_info["original_position"] * zoom_factor
		var luminosity = star_info["luminosity"]
		var temperature = star_info["temperature"]
		
		var star = stars.GalaxyStar.new(scaled_coords, luminosity, temperature)
		updated_star_list.append(star)
	
	stars.set_star_list(updated_star_list)

func to_main_menu():
	get_node("/root/Main/UI").to_main_menu()
