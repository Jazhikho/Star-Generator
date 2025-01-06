extends Node3D

# Enums and Constants
enum ViewType {OBJECT, SYSTEM}
const SPEED_SCALE = 1  # For converting rotation and orbit periods

# External script handlers
var visuals_handler = preload("res://assets/models/planet/planet_visuals.gd").new()
var satellite_handler = preload("res://assets/models/planet/satellite_handler.gd").new()

# Planet properties
var planet_data: Dictionary
var planet_class: String = "Rockball"
var is_moon := false

# Orbital properties (now only for data storage)
var orbit_radius := 5.0
var orbit_eccentricity := 0.0
var rotation_speed := 1.0
var orbit_speed := 1.0

# Node references
var planet_mesh
var orbital_bodies

func initialize(data: Dictionary, _moon: bool = false, view_type: ViewType = ViewType.OBJECT):
	planet_data = data
	is_moon = _moon
	planet_mesh = $MeshInstance3D
	orbital_bodies = $OrbitalBodies
	
	# Set basic properties
	planet_class = data["PlanetClass"]
	orbit_radius = data["Orbit"]
	orbit_eccentricity = data.get("Eccentricity", 0)
	rotation_speed = 2 * PI / abs(data["RotationalPeriod"] * SPEED_SCALE)
	orbit_speed = 2 * PI / (data["OrbitalPeriod"] * SPEED_SCALE)
	
	# Setup visuals
	add_child(visuals_handler)
	var scale_factor = 0.001 if view_type == ViewType.SYSTEM else 1.0
	visuals_handler.initialize(planet_mesh, data, scale_factor)
	
	# Handle view-specific setup
	if view_type == ViewType.OBJECT:
		setup_for_object_view(data)

func setup_for_object_view(data: Dictionary):
	# Setup satellites (moons and rings)
	add_child(satellite_handler)
	satellite_handler.setup_satellites(self, data, ViewType.OBJECT)

func _process(delta):
	if planet_mesh:
		planet_mesh.rotate_y(rotation_speed * delta)
	
	# Update orbital bodies
	if has_node("OrbitalBodies"):
		for container in $OrbitalBodies.get_children():
			for body in container.get_children():
				if body.has_method("update_orbit"):
					body.update_orbit(delta)

# LOD update now delegates to visuals handler
func update_level_of_detail(camera_distance: float):
	var distance_factor = clamp(1.0 - (camera_distance / 1000.0), 0.0, 1.0)
	visuals_handler.update_level_of_detail(distance_factor)

# Debug function
func debug_print_moon_positions():
	if has_node("OrbitalBodies"):
		for container in $OrbitalBodies.get_children():
			for moon in container.get_children():
				if moon.is_moon:
					print("Moon position: ", moon.global_position)

# Cleanup
func _exit_tree():
	if visuals_handler:
		visuals_handler.queue_free()
	if satellite_handler:
		satellite_handler.queue_free()

func get_mass() -> float:
	var planet_mass = planet_data.get("Mass", 0.0)
	print("Planet ", name, " returning mass: ", planet_mass)  # Debug output
	return planet_mass
