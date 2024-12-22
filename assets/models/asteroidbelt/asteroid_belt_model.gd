extends Node3D

@export var inner_radius := 10.0
@export var outer_radius := 15.0
@export var asteroid_count := 10000
@export var asteroid_scale_min := 0.01
@export var asteroid_scale_max := 0.1
@export var texture_variations := 5

var asteroid_mesh_library = []
var multimesh_instance: MultiMeshInstance3D
var base_asteroid_count: int

func _ready():
	base_asteroid_count = asteroid_count
	load_asteroid_meshes()
	generate_belt()

func load_asteroid_meshes():
	var path = "res://assets/models/asteroids/"
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".obj") or file_name.ends_with(".gltf"):
				asteroid_mesh_library.append(load(path + file_name))
			file_name = dir.get_next()
		dir.list_dir_end()

func generate_belt():
	var multimesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.use_colors = true
	multimesh.instance_count = asteroid_count
	
	if asteroid_mesh_library.size() > 0:
		multimesh.mesh = asteroid_mesh_library[randi() % asteroid_mesh_library.size()]
	else:
		# Fallback: create a simple rock mesh
		var mesh = SphereMesh.new()
		mesh.radius = 1
		mesh.height = 2
		multimesh.mesh = mesh
	
	var multimesh_instance = MultiMeshInstance3D.new()
	multimesh_instance.multimesh = multimesh
	
	for i in range(asteroid_count):
		var angle = randf() * 2 * PI
		var radius = randf_range(inner_radius, outer_radius)
		var x = radius * cos(angle)
		var z = radius * sin(angle)
		var y = randf() * 0.5 - 0.25  # Small variation in Y
		
		var pos = Vector3(x, y, z)
		var scale = Vector3.ONE * randf_range(asteroid_scale_min, asteroid_scale_max)
		var basis = Basis().rotated(Vector3.RIGHT, randf() * PI).rotated(Vector3.UP, randf() * PI)
		
		var transform = Transform3D(basis, pos)
		transform = transform.scaled(scale)
		
		multimesh.set_instance_transform(i, transform)
		multimesh.set_instance_color(i, get_asteroid_color())
	
	add_child(multimesh_instance)

func get_asteroid_color() -> Color:
	var variation = randi() % texture_variations
	match variation:
		0: return Color(0.5, 0.5, 0.5)  # Gray
		1: return Color(0.4, 0.3, 0.2)  # Brown
		2: return Color(0.6, 0.6, 0.5)  # Light gray
		3: return Color(0.3, 0.2, 0.2)  # Dark brown
		_: return Color(0.7, 0.7, 0.6)  # Pale

func update_level_of_detail(distance: float):
	if !multimesh_instance or !multimesh_instance.multimesh:
		return
		
	# Define distance thresholds
	const CLOSE_DISTANCE = 50.0
	const MID_DISTANCE = 150.0
	const FAR_DISTANCE = 300.0
	
	var visible_percentage: float
	if distance < CLOSE_DISTANCE:
		visible_percentage = 1.0  # 100% visible
	elif distance < MID_DISTANCE:
		visible_percentage = lerp(1.0, 0.5, (distance - CLOSE_DISTANCE) / (MID_DISTANCE - CLOSE_DISTANCE))
	elif distance < FAR_DISTANCE:
		visible_percentage = lerp(0.5, 0.1, (distance - MID_DISTANCE) / (FAR_DISTANCE - MID_DISTANCE))
	else:
		visible_percentage = 0.1  # Minimum 10% visible
	
	var new_count = int(base_asteroid_count * visible_percentage)
	new_count = max(new_count, 100)  # Ensure at least 100 asteroids are always visible
	
	if multimesh_instance.multimesh.instance_count != new_count:
		multimesh_instance.multimesh.instance_count = new_count
