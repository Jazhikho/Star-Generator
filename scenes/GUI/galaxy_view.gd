extends Node3D

@onready var star_manager = $StarManager

var star_data_map = {}

func _ready():
	pass

func setup_galaxy_view():
	var star_list = []
	for star_id in GlobalData.galaxy_data:
		var star_info = GlobalData.galaxy_data[star_id]
		var coords = star_info["coordinates"]
		var luminosity = star_info["luminosity"]
		var temperature = star_info["temperature"]
		
		star_list.append({
			"coords": coords,
			"luminosity": luminosity,
			"temperature": temperature
		})
		star_data_map[coords] = star_info
	
	setup_collision_system()
	star_manager.set_star_list(star_list)

func setup_collision_system():
	for coords in star_data_map:
		var collision_sphere = Area3D.new()
		var collision_shape = CollisionShape3D.new()
		var sphere_shape = SphereShape3D.new()
		
		sphere_shape.radius = 2.0
		collision_shape.shape = sphere_shape
		collision_sphere.add_child(collision_shape)
		collision_sphere.position = coords
		collision_sphere.collision_layer = 1
		collision_sphere.collision_mask = 1
		collision_sphere.set_meta("star_data", star_data_map[coords])
		
		collision_sphere.input_ray_pickable = false
		collision_sphere.input_capture_on_drag = false
		
		add_child(collision_sphere)
		
func get_galaxy_bounds() -> Dictionary:
	var min_coords = Vector3.ZERO
	var max_coords = Vector3.ZERO
	var first = true
	
	for coords in star_data_map.keys():
		if first:
			min_coords = coords
			max_coords = coords
			first = false
		else:
			min_coords.x = min(min_coords.x, coords.x)
			min_coords.y = min(min_coords.y, coords.y)
			min_coords.z = min(min_coords.z, coords.z)
			max_coords.x = max(max_coords.x, coords.x)
			max_coords.y = max(max_coords.y, coords.y)
			max_coords.z = max(max_coords.z, coords.z)
	
	var size = max_coords - min_coords
	var center = min_coords + (size / 2)
	
	return {
		"center": center,
		"size": size
	}

func clear_collision_spheres():
	for child in get_children():
		if child is Area3D:
			child.queue_free()
