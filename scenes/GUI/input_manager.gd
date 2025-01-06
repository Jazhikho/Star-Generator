extends Node

signal mouse_clicked(position: Vector2, is_double_click: bool)
signal escape_pressed

# Double click detection
var double_click_timer: Timer
const DOUBLE_CLICK_TIME = 0.3
var is_waiting_for_double_click = false
var last_clicked_position: Vector2

func _ready():
	setup_double_click_timer()

func setup_double_click_timer():
	double_click_timer = Timer.new()
	double_click_timer.wait_time = DOUBLE_CLICK_TIME
	double_click_timer.one_shot = true
	add_child(double_click_timer)
	double_click_timer.timeout.connect(_on_double_click_timer_timeout)

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Mouse clicked at: ", event.position)  # Debug output
		handle_mouse_click(event.position)
	elif Input.is_action_just_pressed("return"):
		print("Escape pressed")  # Debug output
		emit_signal("escape_pressed")

func handle_mouse_click(position: Vector2):
	if is_waiting_for_double_click and position.distance_to(last_clicked_position) < 10:
		print("Double click detected")  # Debug output
		is_waiting_for_double_click = false
		double_click_timer.stop()
		emit_signal("mouse_clicked", position, true)
	else:
		print("Single click detected")  # Debug output
		is_waiting_for_double_click = true
		last_clicked_position = position
		double_click_timer.start()
		emit_signal("mouse_clicked", position, false)

func _on_double_click_timer_timeout():
	is_waiting_for_double_click = false
