extends Node3D

@onready var camera: Camera3D = $Camera3D
@onready var stars = $Stars  # Reference to the Stars scene instance
var star_data_map = {}  # Maps position to star data
const DOUBLE_CLICK_TIME = 0.3
var last_click_time = 0.0
var double_click_timer
var last_clicked_star
var ray_length = 1000
var space_state: PhysicsDirectSpaceState3D

func _ready():
	space_state = get_world_3d().direct_space_state
	
	var pars = GlobalSettings.galaxy_settings.parsecs
	var cam_x = GlobalSettings.galaxy_settings.x_sector * pars / 2
	var cam_y = GlobalSettings.galaxy_settings.y_sector * pars / 2
	var cam_z = GlobalSettings.galaxy_settings.z_sector * pars / 2
	# Set up camera
	camera.position = Vector3(0, cam_y, cam_z)
	camera.look_at(Vector3(cam_x, cam_y, cam_z))
	
	double_click_timer = Timer.new()
	double_click_timer.one_shot = true
	double_click_timer.wait_time = 0.3
	add_child(double_click_timer)

	# Debug camera settings
	for child in get_children():
		print("Child node: ", child.name, " of type: ", child.get_class())

	setup_stars()
	setup_collision_system()
			
func setup_stars():
	print("Setting up stars...")
	var star_list = []
	
	for star_data in GlobalData.galaxy_data:
		if not star_data.has("coordinates") or not star_data.has("luminosity") or not star_data.has("temperature"):
			print("Missing required star data fields")
			continue
		
		var coords = Vector3(star_data["coordinates"][0], star_data["coordinates"][1], star_data["coordinates"][2])
		var luminosity = star_data["luminosity"]  # Scale up luminosity
		var temperature = star_data["temperature"]
		
		#print(f"Creating star at {coords} with luminosity {luminosity} and temperature {temperature}")
		
		var star = stars.Star.new(coords, luminosity, temperature)
		star_list.append(star)
		star_data_map[coords] = star_data
	
	print("Total stars to render: ", star_list.size())
	stars.set_star_list(star_list)

func setup_collision_system():
	# Create collision spheres for each star
	for star_position in star_data_map:
		var collision_sphere = Area3D.new()
		var collision_shape = CollisionShape3D.new()
		var sphere_shape = SphereShape3D.new()
		
		sphere_shape.radius = 1.0
		collision_shape.shape = sphere_shape
		
		collision_sphere.add_child(collision_shape)
		collision_sphere.position = star_position
		collision_sphere.collision_layer = 1
		collision_sphere.collision_mask = 1
		
		collision_sphere.set_meta("star_data", star_data_map[star_position])
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
	if star_data.data.has("system_data") and not star_data.data.system_data.is_empty():
		transition_to_system_view(star_data)
	
func transition_to_system_view(star_data: Dictionary):
	# Create a ColorRect for transition effect
	var transition_rect = ColorRect.new()
	transition_rect.color = Color(0, 0, 0, 0)  # Start fully transparent
	transition_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(transition_rect)
	
	# Fade to black
	var tween = create_tween()
	tween.tween_property(transition_rect, "color", Color(0, 0, 0, 1), 1.0)
	await tween.finished
	
	# Set up the system data for the next scene
	Global.current_system_data = star_data.data.system_data
	
	# Change to the system_view scene
	get_tree().change_scene_to_file("res://scenes/system_view.tscn")

func _on_star_mouse_entered(star_area: Area3D):
	var star_data = star_area.get_meta("star_data")
	# Handle hover effect (e.g., show tooltip)
	print("Hovering over star: ", star_data.id)

func _on_star_mouse_exited(star_area: Area3D):
	# Handle hover exit
	pass

func _on_star_clicked(star_data: Dictionary):
	print("Clicked star: ", star_data.id)  # Debug print
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
		print("Mouse clicked at: ", event.position)  # Debug print
		var result = raycast_from_mouse(event.position)
		if result:
			var collider = result.collider
			if collider is Area3D and collider.has_meta("star_data"):
				var star_data = collider.get_meta("star_data")
				print("Star clicked: ", star_data.id)  # Debug print
				_on_star_clicked(star_data)
			else:
				print("Clicked object is not a star")  # Debug print
		else:
			print("No object clicked")  # Debug print
			
func raycast_from_mouse(mouse_pos):
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * ray_length
	var query = PhysicsRayQueryParameters3D.create(from, to)
	return space_state.intersect_ray(query)
