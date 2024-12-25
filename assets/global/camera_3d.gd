extends Camera3D

@export var movement_speed: float = 50.0
@export var pan_speed: float = 0.1
@export var orbit_speed: float = 0.1
@export var zoom_speed: float = 0.01
@export var min_zoom: float = 0.001
@export var max_zoom: float = 5.0

var focus_point: Vector3 = Vector3.ZERO
var current_zoom: float # = 10.0  # Start at 10x zoom
var view_type: int = 0  # 0 for galaxy, 1 for system, 2 for object

var is_transitioning: bool = false
var transition_duration: float = 1.0  # Adjust this to control transition speed
var transition_timer: float = 0.0
var start_position: Vector3
var start_focus: Vector3
var target_position: Vector3
var target_focus: Vector3

signal zoom_changed(zoom_factor: float)

func _ready():
	setup_initial_position()

func setup_initial_position():
	# Get galaxy bounds from GlobalSettings
	var pars = GlobalSettings.galaxy_settings.parsecs
	var max_x = GlobalSettings.galaxy_settings.x_sector * pars
	var max_y = GlobalSettings.galaxy_settings.y_sector * pars
	var max_z = GlobalSettings.galaxy_settings.z_sector * pars
	
	# Set focus to center of galaxy
	focus_point = Vector3(max_x/2, max_y/2, max_z/2)
	
	# Position camera
	position = Vector3(max_x/2, max_y/2, max_z * 0.8)
	look_at(focus_point)

func process_galaxy_movement(delta):
	if is_transitioning:
		return  # Don't process movement while transitioning
	
	var movement = Vector3.ZERO
	var camera_basis = global_transform.basis
	
	if Input.is_action_pressed("move_forward"):
		movement -= camera_basis.z
	if Input.is_action_pressed("move_back"):
		movement += camera_basis.z
	
	if Input.is_action_pressed("move_left"):
		movement -= camera_basis.x
		focus_point -= camera_basis.x * movement_speed * delta
	if Input.is_action_pressed("move_right"):
		movement += camera_basis.x
		focus_point += camera_basis.x * movement_speed * delta
	
	if Input.is_action_pressed("move_up"):
		movement += camera_basis.y
		focus_point += camera_basis.y * movement_speed * delta
	if Input.is_action_pressed("move_down"):
		movement -= camera_basis.y
		focus_point -= camera_basis.y * movement_speed * delta
	
	if Input.is_action_pressed("pan_left"):
		rotate_y(pan_speed * delta)
	if Input.is_action_pressed("pan_right"):
		rotate_y(-pan_speed * delta)
	
	if Input.is_action_pressed("orbit_up"):
		orbit_vertical(orbit_speed * delta)
	if Input.is_action_pressed("orbit_down"):
		orbit_vertical(-orbit_speed * delta)
	
	if Input.is_action_pressed("orbit_left"):
		orbit_horizontal(orbit_speed * delta)
	if Input.is_action_pressed("orbit_right"):
		orbit_horizontal(-orbit_speed * delta)
	
	if Input.is_action_pressed("zoom_in"):
		adjust_zoom(-zoom_speed)
	if Input.is_action_pressed("zoom_out"):
		adjust_zoom(zoom_speed)
	
	if movement.length_squared() > 0:
		movement = movement.normalized() * movement_speed * delta
		global_position += movement
	
	look_at(focus_point)

func process_system_movement(delta):
	if Input.is_action_pressed("move_up"):
		orbit_vertical(orbit_speed * delta)
	if Input.is_action_pressed("move_down"):
		orbit_vertical(-orbit_speed * delta)
	
	if Input.is_action_pressed("move_left"):
		orbit_horizontal(orbit_speed * delta)
	if Input.is_action_pressed("move_right"):
		orbit_horizontal(-orbit_speed * delta)
	
	if Input.is_action_pressed("zoom_in"):
		adjust_zoom(-zoom_speed)
	if Input.is_action_pressed("zoom_out"):
		adjust_zoom(zoom_speed)

func orbit_horizontal(angle: float):
	var orbital_transform = Transform3D().rotated(Vector3.UP, angle)
	global_position = orbital_transform * (global_position - focus_point) + focus_point
	look_at(focus_point)

func orbit_vertical(angle: float):
	var right = global_transform.basis.x
	var orbital_transform = Transform3D().rotated(right, angle)
	global_position = orbital_transform * (global_position - focus_point) + focus_point
	look_at(focus_point)

func adjust_zoom(zoom_delta: float):
	var new_zoom = clamp(current_zoom + zoom_delta, min_zoom, max_zoom)
	if new_zoom != current_zoom:
		current_zoom = new_zoom
		emit_signal("zoom_changed", current_zoom)
		# Adjust actual camera position based on zoom
		var direction = (global_position - focus_point).normalized()
		global_position = focus_point + direction * (100 * current_zoom)

func set_focus(new_focus: Vector3):
	if is_transitioning:
		# If already transitioning, immediately end current transition
		_end_transition()
	
	start_focus = focus_point
	target_focus = new_focus
	
	# We no longer change the camera position
	is_transitioning = true
	transition_timer = 0.0

func set_view_type(type: int):
	view_type = type

func _process(delta):
	if is_transitioning:
		transition_timer += delta
		var t = transition_timer / transition_duration
		
		if t >= 1.0:
			_end_transition()
		else:
			# Use smoothstep for easing
			t = smoothstep(0.0, 1.0, t)
			focus_point = start_focus.lerp(target_focus, t)
			look_at(focus_point)
	else:
		match view_type:
			0:  # Galaxy view
				process_galaxy_movement(delta)
			1, 2:  # System or Object view
				process_system_movement(delta)

# Add this helper function
func _end_transition():
	is_transitioning = false
	look_at(focus_point)

# Helper function for smooth interpolation
func smoothstep(edge0: float, edge1: float, x: float) -> float:
	var t = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0)
	return t * t * (3.0 - 2.0 * t)
