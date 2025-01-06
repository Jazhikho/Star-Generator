extends Node3D

# Signals
signal celestial_body_selected(body_data: Dictionary)
signal transition_to_object_view(body_data: Dictionary)

# Preloaded resources
var system_model_scene = preload("res://assets/models/system/system_model.tscn")

# System data
var system_data: Array
var main_system: Node3D

func initialize_from_global_data():
	if GlobalData.is_data_loaded():
		initialize_system(GlobalData.galaxy_data)
	else:
		print("No data loaded in GlobalData")

func initialize_system(data):
	system_data = data.data
	clear_system()
	
	main_system = system_model_scene.instantiate()
	add_child(main_system)
	main_system.initialize_system(system_data)
	
	# Ensure all stars are visible after initialization
	call_deferred("_ensure_star_visibility")
	
func _ensure_star_visibility():
	var stars = []
	_find_all_stars(main_system, stars)
	
	for star in stars:
		star.setup_visuals()  # Refresh star visuals

func _find_all_stars(node: Node, stars: Array):
	for child in node.get_children():
		if child.has_method("setup_visuals"):  # This is a star
			stars.append(child)
		_find_all_stars(child, stars)

func get_system_bounds() -> Dictionary:
	if !main_system:
		return {"center": Vector3.ZERO, "radius": 1.0}
	
	var system_center = main_system.get_system_center()
	var system_radius = main_system.get_system_radius()
	
	return {
		"center": system_center,
		"radius": system_radius
	}

func clear_system():
	# Remove all children
	for child in get_children():
		child.queue_free()
	main_system = null  # Clear the reference when system is cleared

func _process(_delta):
	update_level_of_detail()

func update_level_of_detail():
	# Only proceed if we have a valid camera and system
	var camera = get_viewport().get_camera_3d()
	if not camera or not main_system:
		return
	
	# Recursively update LOD for all celestial bodies
	#update_lod_recursive(main_system, camera)

func update_lod_recursive(node: Node, camera: Camera3D):
	# Guard against null nodes
	if not is_instance_valid(node):
		return
		
	# Update this node's LOD if applicable
	if node.has_method("update_level_of_detail"):
		var distance = camera.global_position.distance_to(node.global_position)
		node.update_level_of_detail(distance)
	
	# Recurse through children
	for child in node.get_children():
		update_lod_recursive(child, camera)

# Signal handlers
func _on_celestial_body_clicked(body_data: Dictionary):
	emit_signal("celestial_body_selected", body_data)

func _on_celestial_body_double_clicked(body_data: Dictionary):
	emit_signal("transition_to_object_view", body_data)
