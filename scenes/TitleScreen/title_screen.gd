extends Node3D

var small_star_scene = preload("res://scenes/TitleScreen/star.tscn")
@onready var title_label = $TitleLabel

var boundary = {
	"left": -20,
	"right": 20,
	"top": 20,
	"bottom": -20
}
var boundary_margin = 1

func _ready():
	# Initial star population
	for i in range(100):  # Adjust number as needed
		spawn_star($Stars, false)
	
	# Start timer for continuous star spawning
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 0.5  # Adjust as needed
	timer.connect("timeout", Callable(self, "_on_spawn_timer"))
	timer.start()

func _on_spawn_timer():
	spawn_star($Stars, true)

func spawn_star(root_node, from_right):
	var star = small_star_scene.instantiate()
	star.init(
		boundary.right + boundary_margin if from_right else randf_range(boundary.left, boundary.right),
		randf_range(-10, 10),  # Y position
		randf_range(-5, -15),  # Z position (depth)
		randf_range(0.02, 0.2)  # Size
	)
	root_node.add_child(star)
