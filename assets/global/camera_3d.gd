extends Camera3D

@export var movement_speed: float = 50.0
@export var pan_speed: float = 0.003
@export var zoom_speed: float = 0.1  #scales instead of movement
@export var orbit_speed: float = 0.01
@export var min_zoom: float = 0.1
@export var max_zoom: float = 5.0

var is_panning: bool = false
var is_orbiting: bool = false
var orbit_target: Vector3 = Vector3.ZERO
var last_mouse_position: Vector2 = Vector2.ZERO
var current_zoom: float = 1.0
#
signal zoom_changed(zoom_factor: float)

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _unhandled_input(event):
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_RIGHT:  # Right mouse button for panning
				is_panning = event.pressed
			MOUSE_BUTTON_MIDDLE:  # Middle mouse button for orbiting
				is_orbiting = event.pressed
				if is_orbiting:
					last_mouse_position = event.position
			MOUSE_BUTTON_WHEEL_UP:  # Mouse wheel for zooming in
				adjust_zoom(-zoom_speed)
			MOUSE_BUTTON_WHEEL_DOWN:  # Mouse wheel for zooming out
				adjust_zoom(zoom_speed)
	
	elif event is InputEventMouseMotion:
		if is_panning:
			# Pan the camera based on mouse movement
			var delta = last_mouse_position
			var camera_rotation = rotation
			rotation.z -= -delta.x + pan_speed
			rotation.x -= -delta.y + pan_speed
			last_mouse_position = event.position
		
		elif is_orbiting and orbit_target != Vector3.ZERO:
			# Orbit around the target
			var delta = event.position - last_mouse_position
			var camera_pos = global_position
			
			# Rotate around vertical axis
			var rotation_y = Basis(Vector3.UP, -delta.x * orbit_speed)
			camera_pos = rotation_y * (camera_pos - orbit_target) + orbit_target
			
			# Rotate around horizontal axis
			var right = transform.basis.x
			var rotation_x = Basis(right, -delta.y * orbit_speed)
			camera_pos = rotation_x * (camera_pos - orbit_target) + orbit_target
			
			global_position = camera_pos
			look_at(orbit_target)
			
			last_mouse_position = event.position

func adjust_zoom(zoom_delta: float):
	var new_zoom = clamp(current_zoom + zoom_delta, min_zoom, max_zoom)
	if new_zoom != current_zoom:
		current_zoom = new_zoom
		emit_signal("zoom_changed", current_zoom)

func _process(delta):
	var input_dir = Vector3.ZERO
	var camera_basis = global_transform.basis
	
	# Forward/Backward
	if Input.is_action_pressed("move_forward"):
		input_dir -= camera_basis.z
	if Input.is_action_pressed("move_back"):
		input_dir += camera_basis.z
	
	# Left/Right
	if Input.is_action_pressed("move_left"):
		input_dir -= camera_basis.x
	if Input.is_action_pressed("move_right"):
		input_dir += camera_basis.x
	
	# Up/Down
	if Input.is_action_pressed("move_up"):
		input_dir += camera_basis.y
	if Input.is_action_pressed("move_down"):
		input_dir -= camera_basis.y
	
	# Normalize the input direction and apply movement
	if input_dir.length_squared() > 0:
		input_dir = input_dir.normalized()
		global_position += input_dir * movement_speed * delta

func set_orbit_target(target_position: Vector3):
	orbit_target = target_position
