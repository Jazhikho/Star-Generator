extends Camera3D

var rotation_speed = 0.005
var zoom_speed = 0.1
var min_distance = 2
var max_distance = 50

var focus_object: Node3D

func _ready():
	pass

func _input(event):
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		var rotation_offset = Vector3(-event.relative.y * rotation_speed, -event.relative.x * rotation_speed, 0)
		global_rotate(Vector3.UP, rotation_offset.y)
		rotate(transform.basis.x, rotation_offset.x)
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom(-zoom_speed)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom(zoom_speed)

func zoom(factor):
	var new_distance = clamp(global_transform.origin.distance_to(focus_object.global_transform.origin) * (1 + factor), min_distance, max_distance)
	global_transform.origin = focus_object.global_transform.origin + global_transform.origin.direction_to(focus_object.global_transform.origin) * -new_distance
