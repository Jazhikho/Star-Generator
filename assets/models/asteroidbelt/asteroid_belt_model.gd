extends Node3D

@export var inner_radius := 10.0:
	set(value):
		inner_radius = value
		_regenerate_belt()

@export var outer_radius := 15.0:
	set(value):
		outer_radius = value
		_regenerate_belt()

@export var asteroid_count := 10000:
	set(value):
		asteroid_count = value
		_regenerate_belt()

@export var asteroid_scale_min := 0.01
@export var asteroid_scale_max := 0.1
@export var texture_variations := 5

var asteroid_mesh_library = []
var multimesh_instance: MultiMeshInstance3D

func _ready():
	print("Asteroid belt ready")
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
	print("Generating belt with ", asteroid_count, " asteroids")
	var multimesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.use_colors = true
	multimesh.instance_count = asteroid_count
	
	if asteroid_mesh_library.size() > 0:
		multimesh.mesh = asteroid_mesh_library[randi() % asteroid_mesh_library.size()]
	else:
		# Fallback: create a simple rock mesh
		var mesh = BoxMesh.new()
		mesh.size = Vector3(1, 1, 1)
		multimesh.mesh = mesh
	
	multimesh_instance = MultiMeshInstance3D.new()
	multimesh_instance.multimesh = multimesh
	add_child(multimesh_instance)
	
	for i in range(asteroid_count):
		var angle = randf() * 2 * PI
		var radius = randf_range(inner_radius, outer_radius)
		var x = radius * cos(angle)
		var z = radius * sin(angle)
		var y = randf_range(-1, 1)  # Add some vertical spread
		
		var pos = Vector3(x, y, z)
		var scale = Vector3.ONE * randf_range(asteroid_scale_min, asteroid_scale_max)
		var basis = Basis().rotated(Vector3.UP, randf() * 2 * PI)
		
		var transform = Transform3D(basis, pos)
		transform = transform.scaled(scale)
		
		multimesh.set_instance_transform(i, transform)
		multimesh.set_instance_color(i, get_asteroid_color())

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
	
	var visible_percentage = clamp(1.0 - (distance / 1000.0), 0.1, 1.0)
	var new_count = int(asteroid_count * visible_percentage)
	new_count = max(new_count, 100)  # Ensure at least 100 asteroids are always visible
	
	if multimesh_instance.multimesh.instance_count != new_count:
		multimesh_instance.multimesh.instance_count = new_count

func _regenerate_belt():
	# Only regenerate if we're in the scene tree
	if is_inside_tree():
		# Clear existing multimesh instance if it exists
		if multimesh_instance:
			multimesh_instance.queue_free()
		generate_belt()
