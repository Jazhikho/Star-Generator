extends Node3D

# Node references
@onready var primary_subsystem = $PrimarySubSystem        # Primary subsystem - can contain stars or another system
@onready var secondary_subsystem = $SecondarySubSystem    # Secondary subsystem - can contain stars or another system

# Preloaded scenes
var star_scene = preload("res://assets/models/star/star_model.tscn")
var system_scene = preload("res://assets/models/system/system_model.tscn")

# Preloaded scripts
var PlanetGenerator = preload("res://assets/models/system/orbital_bodies_setup.gd")

# System properties
var total_mass: float = 0.0                  # Combined mass of all bodies in this system
var hierarchical_level: int = 0              # Depth in the system hierarchy
var hierarchical_separation: float
var hierarchical_eccentricity: float

func initialize_system(system_data: Array, parent_level: int = -1):
	hierarchical_level = parent_level + 1    # Sets levels of hierarchy, highest level contains stars
	
	# Handle different system configurations based on number of stars
	match system_data.size():
		1: setup_single_star(system_data[0])    # Single star system
		2: setup_binary_system(system_data)     # Binary star system
		_: setup_complex_system(system_data)    # Complex system requiring recursion
	
	calculate_total_system_mass()    # Calculate total system mass after setup
	
	if hierarchical_level == 0:  # Only the top-level system initiates orbit setup
		setup_all_orbits()
		generate_planetary_systems(system_data)

func setup_single_star(star_data: Dictionary):
	# Create and add single star to primary subsystem
	var star = create_star(star_data)
	primary_subsystem.add_child(star)

func setup_binary_system(system_data: Array):
	# Create primary and secondary stars
	var primary_star = create_star(system_data[0])
	var secondary_star = create_star(system_data[1])
	
	# Add stars to their respective subsystems
	primary_subsystem.add_child(primary_star)
	secondary_subsystem.add_child(secondary_star)
	
	var max_seperation = system_data[1]["HierarchicalMaxSeparation"]
	var min_seperation = system_data[1]["HierarchicalMinSeparation"]
	hierarchical_separation = (max_seperation + min_seperation) / 2
	hierarchical_eccentricity = system_data[1]["HierarchicalEccentricity"]

func setup_complex_system(system_data: Array):
	var mid_point = determine_split_point(system_data.size())
	
	# Create and setup primary and secondary subsystems
	var primary_group = system_data.slice(0, mid_point)
	var secondary_group = system_data.slice(mid_point)
	var max_seperation = secondary_group[0]["HierarchicalMaxSeparation"]
	var min_seperation = secondary_group[0]["HierarchicalMinSeparation"]
	hierarchical_separation = (max_seperation + min_seperation) / 2
	hierarchical_eccentricity = secondary_group[0]["HierarchicalEccentricity"]
	
	setup_subsystem(primary_group, primary_subsystem)
	setup_subsystem(secondary_group, secondary_subsystem)

func determine_split_point(size: int) -> int:
	match size:
		3, 4: return 2                    # For 3-4 stars, split 2|1-2
		5, 6, 7, 8: return 4              # For 5-8 stars, split 4|1-4
		_: return 8                       # For 9+ stars, split 8|1-2

func setup_subsystem(star_data: Array, parent_node: Node):
	if star_data.size() > 2:
		# Create new system for complex subsystem
		var subsystem = system_scene.instantiate()
		parent_node.add_child(subsystem)
		subsystem.initialize_system(star_data, hierarchical_level)
	else:
		# Create individual stars
		for star_info in star_data:
			var star = create_star(star_info)
			parent_node.add_child(star)
			
func setup_all_orbits():
	# First, setup orbit between primary and secondary subsystems if both exist
	if secondary_subsystem.get_child_count() > 0:
		setup_subsystem_orbit()
	
	# Then recursively setup orbits for all child systems
	setup_child_orbits(primary_subsystem)
	setup_child_orbits(secondary_subsystem)
	
	# Finally, setup star orbits at the lowest level
	setup_star_orbits(primary_subsystem)
	setup_star_orbits(secondary_subsystem)

func setup_subsystem_orbit():
	OrbitSetup.setup_orbit(
		secondary_subsystem,
		primary_subsystem,
		hierarchical_separation,
		hierarchical_eccentricity
	)

func setup_child_orbits(subsystem: Node):
	for child in subsystem.get_children():
		if child.has_method("setup_subsystem_orbit"):
			child.setup_subsystem_orbit()
			child.setup_child_orbits(child.primary_subsystem)
			child.setup_child_orbits(child.secondary_subsystem)

func setup_star_orbits(subsystem: Node):
	var stars = subsystem.get_children()
	
	if stars.size() == 1 and stars[0].has_method("setup_subsystem_orbit"):
		# This is another system, recurse into it
		stars[0].setup_star_orbits(stars[0].primary_subsystem)
		stars[0].setup_star_orbits(stars[0].secondary_subsystem)
	elif stars.size() == 2:
		# These are actual stars, set up their orbits around their barycenter
		var star1 = stars[0]
		var star2 = stars[1]
		
		# Both stars need to orbit
		star1.setup_orbit(star2)
		star2.setup_orbit(star1)

func create_star(star_data: Dictionary) -> Node:
	# Instantiate and initialize a new star
	var star_instance = star_scene.instantiate()
	star_instance.initialize(star_data)
	return star_instance

func calculate_total_system_mass():
	# Reset total mass
	total_mass = 0.0
	
	# Calculate mass from primary subsystem
	var primary_mass = get_subsystem_mass(primary_subsystem)
	total_mass += primary_mass
	
	# Add mass from secondary subsystem if it exists
	var secondary_mass = 0.0
	if secondary_subsystem.get_child_count() > 0:
		secondary_mass = get_subsystem_mass(secondary_subsystem)
		total_mass += secondary_mass

func get_subsystem_mass(subsystem: Node) -> float:
	var mass = 0.0
	
	for child in subsystem.get_children():
		var child_mass = 0.0
		if child.has_method("get_mass"):           # Star
			child_mass = child.get_mass()
		elif child.has_method("get_total_mass"):   # Nested system
			child_mass = child.get_total_mass()
		mass += child_mass
	
	return mass

func get_total_mass() -> float:
	if total_mass <= 0:
		calculate_total_system_mass()  # Recalculate if not set
	return total_mass

func generate_planetary_systems(system_data: Array):
	var generator = PlanetGenerator.new()
	add_child(generator)  # Add as child to ensure it's in the scene tree
	generator.generate_planetary_system(self, system_data)
	generator.queue_free()  # Clean up after generation is complete

func get_system_center() -> Vector3:
	var total_weighted_position = Vector3.ZERO
	var total_mass = 0.0
	
	# Function to recursively gather positions and masses
	var collect_masses_and_positions = func(node: Node):
		var node_mass = 0.0
		var node_position = Vector3.ZERO
		
		if node.has_method("get_mass"):  # Individual star
			node_mass = node.get_mass()
			node_position = node.global_position
		elif node.has_method("get_total_mass"):  # Nested system
			node_mass = node.get_total_mass()
			node_position = node.get_system_center()
		
		return {"mass": node_mass, "weighted_position": node_position * node_mass}
	
	# Check primary subsystem
	for child in primary_subsystem.get_children():
		var child_data = collect_masses_and_positions.call(child)
		total_mass += child_data.mass
		total_weighted_position += child_data.weighted_position
	
	# Check secondary subsystem
	for child in secondary_subsystem.get_children():
		var child_data = collect_masses_and_positions.call(child)
		total_mass += child_data.mass
		total_weighted_position += child_data.weighted_position
	
	# Return the center of mass position
	if total_mass > 0:
		return total_weighted_position / total_mass
	else:
		return Vector3.ZERO  # Default if no mass found

func get_system_radius() -> float:
	var center = get_system_center()
	var max_distance = 0.0
	
	# Function to recursively check distances
	var check_max_distance = func(node: Node):
		if node.has_method("global_position"):
			var distance = center.distance_to(node.global_position)
			return distance
		elif node.has_method("get_system_radius"):
			var sub_center = node.get_system_center()
			var distance = center.distance_to(sub_center) + node.get_system_radius()
			return distance
		return 0.0
	
	# Check primary subsystem
	for child in primary_subsystem.get_children():
		max_distance = max(max_distance, check_max_distance.call(child))
	
	# Check secondary subsystem
	for child in secondary_subsystem.get_children():
		max_distance = max(max_distance, check_max_distance.call(child))
	
	# Check for planets if they exist
	for child in get_children():
		if child.is_in_group("planets"):  # Assuming planets are in a "planets" group
			var distance = center.distance_to(child.global_position)
			max_distance = max(max_distance, distance)
	
	return max_distance
