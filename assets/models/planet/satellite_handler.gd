extends Node

# Satellite Handler
# Manages the creation and setup of moons and rings for planets

const SYSTEM_SCALE_FACTOR = 0.1  # For scaling in system view

var rings_scene = preload("res://assets/models/asteroidbelt/asteroid_belt_model.tscn")
var planet_scene = preload("res://assets/models/planet/planet_model.tscn")

func setup_satellites(parent_planet: Node, planet_data: Dictionary, view_type):
	if "Satellites" not in planet_data or planet_data["Satellites"].is_empty():
		return
	
	var orbital_bodies = parent_planet.get_node_or_null("OrbitalBodies")
	if not orbital_bodies:
		orbital_bodies = Node3D.new()
		orbital_bodies.name = "OrbitalBodies"
		parent_planet.add_child(orbital_bodies)
	
	for satellite in planet_data["Satellites"]:
		if satellite.get("Type") == "Rings":
			setup_rings(parent_planet, satellite, view_type)
		elif "NestedList" in satellite and not satellite["NestedList"].is_empty():
			for moon_data in satellite["NestedList"]:
				setup_moon(orbital_bodies, moon_data, view_type)

func setup_moon(orbital_bodies: Node, moon_data: Dictionary, view_type):
	var moon_container = Node3D.new()
	moon_container.name = "MoonOrbitContainer_" + str(moon_data.get("id", "unknown"))
	orbital_bodies.add_child(moon_container)
	
	var moon = planet_scene.instantiate()
	moon_container.add_child(moon)
	
	# Initialize moon before setting its position
	moon.initialize(moon_data, true, view_type)
	
	# Set the moon's position relative to its orbit container
	# This might need adjustment based on your orbit system
	moon.position = Vector3(moon_data["Orbit"], 0, 0)
	
	return moon_container

func setup_rings(parent_planet: Node, ring_data: Dictionary, view_type):
	var ring = rings_scene.instantiate()
	parent_planet.add_child(ring)
	
	var scale_factor = SYSTEM_SCALE_FACTOR if view_type == parent_planet.ViewType.SYSTEM else 1.0
	
	# Set ring properties relative to planet size
	if ring_data["RingType"] == "Simple":
		ring.inner_radius = ring_data.get("Orbit", 0.0) * scale_factor * 0.975
		ring.outer_radius = ring_data.get("Orbit", 0.0) * scale_factor * 1.025
	else:
		ring.inner_radius = ring_data.get("InnerOrbit", 0.0) * scale_factor
		ring.outer_radius = ring_data.get("OuterOrbit", 0.0) * scale_factor
	
	ring.asteroid_count = 1000  # Adjust based on view type if needed

func clean_up_satellites(parent_planet: Node):
	var orbital_bodies = parent_planet.get_node_or_null("OrbitalBodies")
	if orbital_bodies:
		orbital_bodies.queue_free()
