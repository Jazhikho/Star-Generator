extends Node

var planet_scene = preload("res://assets/models/planet/planet_model.tscn")
var asteroid_belt_scene = preload("res://assets/models/asteroidbelt/asteroid_belt_model.tscn")

# Called by system_model after star orbits are set up
func generate_planetary_system(star_system: Node, star_data: Array) -> void:
	for star in star_data:
		if "CelestialBodies" in star:
			setup_celestial_bodies(star_system, star)

func setup_celestial_bodies(star_system: Node, star_data: Dictionary) -> void:
	var celestial_bodies = star_data["CelestialBodies"]
	var star_separation = get_star_separation(star_system)
	
	for body_data in celestial_bodies:
		var body_type = body_data.get("Type", "Unknown")
		var orbit_radius = body_data.get("Orbit", 0.0)
		
		# Determine if this should be a circumstellar or circumbinary orbit
		var is_circumbinary = star_separation > 0 and orbit_radius > star_separation
		
		match body_type:
			"Planet":
				create_planet(star_system, body_data, is_circumbinary)
			"Asteroid Belt":
				create_asteroid_belt(star_system, body_data, is_circumbinary)

func create_planet(star_system: Node, planet_data: Dictionary, is_circumbinary: bool) -> void:
	var planet = planet_scene.instantiate()
	planet.add_to_group("planets")
	
	# Initialize planet with system view settings
	planet.initialize(planet_data, false, planet.ViewType.SYSTEM)
	
	# Add to appropriate parent in the star system
	var parent_node = get_appropriate_parent(star_system, is_circumbinary)
	parent_node.add_child(planet)
	
	# Set up orbit using OrbitSetup
	var orbit_target = get_orbit_target(star_system, is_circumbinary)
	OrbitSetup.setup_orbit(
		planet,
		orbit_target,
		planet_data["Orbit"],
		planet_data.get("Eccentricity", 0.0)
	)

func create_asteroid_belt(star_system: Node, belt_data: Dictionary, is_circumbinary: bool) -> void:
	var belt = asteroid_belt_scene.instantiate()
	
	# Add to appropriate parent in the star system
	var parent_node = get_appropriate_parent(star_system, is_circumbinary)
	parent_node.add_child(belt)
	
	# Set up belt properties
	belt.inner_radius = belt_data.get("InnerOrbit", belt_data.get("Orbit", 0.0) * 0.9)
	belt.outer_radius = belt_data.get("OuterOrbit", belt_data.get("Orbit", 0.0) * 1.1)
	belt.asteroid_count = belt_data.get("AsteroidCount", 10000)
	
	# Set up orbit if needed (might not be necessary for belts)
	if belt_data.has("Orbit"):
		var orbit_target = get_orbit_target(star_system, is_circumbinary)
		OrbitSetup.setup_orbit(
			belt,
			orbit_target,
			belt_data["Orbit"],
			belt_data.get("Eccentricity", 0.0)
		)

# Utility functions
func get_star_separation(star_system: Node) -> float:
	if star_system.secondary_subsystem.get_child_count() > 0:
		return star_system.hierarchical_separation
	return 0.0

func get_appropriate_parent(star_system: Node, is_circumbinary: bool) -> Node:
	if is_circumbinary:
		return star_system  # Orbits both stars
	else:
		return star_system.primary_subsystem  # Orbits primary star

func get_orbit_target(star_system: Node, is_circumbinary: bool) -> Node:
	if is_circumbinary:
		return star_system.primary_subsystem  # Use primary subsystem as reference for circumbinary orbit
	else:
		return star_system.primary_subsystem.get_child(0)  # Primary star for circumstellar orbit
