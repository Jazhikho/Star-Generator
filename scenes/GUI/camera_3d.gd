extends Camera3D

# Export variables for tweaking in editor
@export var movement_speed: float = 50.0
@export var pan_speed: float = 0.5
@export var orbit_speed: float = 1.0
@export var zoom_speed: float = 0.1
@export var min_zoom: float = 1.0
@export var max_zoom: float = 5000.0

# Camera properties
var focus_point: Vector3 = Vector3.ZERO
var current_zoom: float = 20.0

# Smoothing variables
var target_focus: Vector3
var target_position: Vector3
var smoothing_speed: float = 5.0

# Reference to ViewManager for access to view scripts
@onready var view_manager: Node3D = $".."

func _ready():
	setup_initial_position()

func setup_initial_position():
	var title_screen : Node3D = $"../TitleScreen"
	position = Vector3(0, 0, 50)
	look_at(Vector3(0,0,0))

func calculate_starfield_bounds(starfield):
	# This function would need to be implemented based on how your starfield is structured
	# It should return a dictionary with 'center' (Vector3) and 'size' (Vector3)
	pass

func _process(delta):
	handle_movement(delta)
	handle_smooth_movement(delta)

func handle_movement(delta):
	var movement = Vector3.ZERO
	var pan = Vector3.ZERO
	var orbit = Vector3.ZERO
	
	# Movement handling
	if Input.is_action_pressed("move_forward"): movement.z -= 1
	if Input.is_action_pressed("move_back"): movement.z += 1
	if Input.is_action_pressed("move_left"): movement.x -= 1
	if Input.is_action_pressed("move_right"): movement.x += 1
	if Input.is_action_pressed("move_up"): movement.y += 1
	if Input.is_action_pressed("move_down"): movement.y -= 1
	
	# Zoom handling
	if Input.is_action_pressed("zoom_in"):
		adjust_zoom(-zoom_speed * delta)
	if Input.is_action_pressed("zoom_out"):
		adjust_zoom(zoom_speed * delta)
	
	# Apply movements
	if movement != Vector3.ZERO:
		move_camera(movement.normalized() * movement_speed * delta)
	
	# Orbit handling
	if Input.is_action_pressed("orbit_left"): orbit.y += 1
	if Input.is_action_pressed("orbit_right"): orbit.y -= 1
	if Input.is_action_pressed("orbit_up"): orbit.x -= 1
	if Input.is_action_pressed("orbit_down"): orbit.x += 1
	
	if orbit != Vector3.ZERO:
		orbit_camera(orbit.normalized() * orbit_speed * delta)

func handle_smooth_movement(delta):
	focus_point = focus_point.lerp(target_focus, smoothing_speed * delta)
	position = position.lerp(target_position, smoothing_speed * delta)
	look_at(focus_point)

func move_camera(movement: Vector3):
	var camera_basis = global_transform.basis
	var adjusted_movement = camera_basis * movement
	target_focus += adjusted_movement
	target_position += adjusted_movement

func pan_camera(pan: Vector3):
	var camera_basis = global_transform.basis
	var adjusted_pan = camera_basis * pan
	target_focus += adjusted_pan

func orbit_camera(orbit: Vector3):
	var right = global_transform.basis.x
	var up = Vector3.UP
	
	var horizontal_transform = Transform3D().rotated(up, orbit.y)
	var vertical_transform = Transform3D().rotated(right, orbit.x)
	
	var relative_pos = position - focus_point
	relative_pos = horizontal_transform * vertical_transform * relative_pos
	
	target_position = focus_point + relative_pos

func adjust_zoom(zoom_delta: float):
	print("Zooming: ", zoom_delta)  # Debug output
	var new_zoom = clamp(current_zoom * (1.0 + zoom_delta), min_zoom, max_zoom)
	if new_zoom != current_zoom:
		current_zoom = new_zoom
		var direction = (position - focus_point).normalized()
		var current_distance = position.distance_to(focus_point)
		target_position = focus_point + direction * current_distance * (1.0 - zoom_delta)

func pan_to_point(point: Vector3):
	target_focus = point

func setup_for_galaxy_view():
	var bounds = view_manager.galaxy_view.get_galaxy_bounds()
	target_focus = bounds.center
	var z_offset = bounds.size.z * 0.75
	target_position = Vector3(bounds.center.x, bounds.center.y, bounds.center.z + z_offset)
	current_zoom = 1.0

func setup_for_system_view():
	var bounds = view_manager.system_view.get_system_bounds()
	target_focus = bounds.center
	
	# Increase the view distance for better visibility
	var view_distance = max(bounds.radius * 3, 5.0)
	target_position = bounds.center + Vector3(0, view_distance/2, view_distance)
	
	# Reset zoom for system view
	current_zoom = 1.0
	min_zoom = 0.1
	max_zoom = 10.0  # Allow more zoom out in system view
	zoom_speed = view_distance * 0.1  # Scale zoom speed to system size
	
	# Adjust movement speeds for system scale
	movement_speed = view_distance * 0.5
	pan_speed = view_distance * 0.1
	orbit_speed = 0.5
