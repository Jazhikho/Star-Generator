extends Node3D

var system_data : Array

@onready var primary_star = $PrimaryStar
@onready var other_stars = $PrimaryStar/OtherStars
@onready var planet_model_scene = preload("res://assets/models/planet/planet_model.tscn")
@onready var star_model_scene = preload("res://assets/models/star/star_model.tscn")
@onready var asteroid_belt_scene = preload("res://assets/models/asteroidbelt/asteroid_belt_model.tscn")

func _ready():
	if !primary_star:
		push_error("Primary star node not found!")
		return
	#create_system()

func create_system():
	if system_data.is_empty():
		push_error("No system data available")
		return
		
	for child in primary_star.get_node("OrbitalBodies").get_children():
		child.queue_free()
	for child in primary_star.get_node("OtherStars").get_children():
		child.queue_free()

	var primary_star_data = system_data[0]
	setup_star(primary_star, primary_star_data)
	
	# Create celestial bodies for the primary star
	create_celestial_bodies(primary_star_data, primary_star)
	
	# If there are other stars, create them (uncommon in most systems)
	for i in range(1, system_data.size()):
		var star_data = system_data[i]
		var star_node = create_star(star_data)
		
		# Calculate orbit properties for the star
		star_node.orbit_radius = calculate_binary_separation(primary_star_data, star_data)
		star_node.orbit_speed = calculate_orbit_speed(primary_star_data, star_data)
		
		primary_star.get_node("OtherStars").add_child(star_node)
		
		# Create celestial bodies for this star
		create_celestial_bodies(star_data, star_node)

func create_celestial_bodies(star_data: Dictionary, parent_star: Node3D):
	if "CelestialBodies" in star_data:
		for body in star_data["CelestialBodies"]:
			match body["Type"]:
				"Planet":
					var planet_node = create_planet(body)
					parent_star.get_node("OrbitalBodies").add_child(planet_node)
					
				"AsteroidBelt":
					var belt_node = create_asteroid_belt(body, star_data)
					parent_star.get_node("OrbitalBodies").add_child(belt_node)

func setup_star(star_node: Node3D, star_data: Dictionary):
	star_node.initialize(star_data)

func create_star(star_data: Dictionary) -> Node3D:
	var star = star_model_scene.instantiate()
	setup_star(star, star_data)
	return star

func calculate_binary_separation(primary: Dictionary, secondary: Dictionary) -> float:
	# This is a placeholder. 
	return 5.0  # Default separation

func calculate_orbit_speed(primary: Dictionary, secondary: Dictionary) -> float:
	# Simple calculation based on masses
	var total_mass = primary["Mass"] + secondary["Mass"]
	var orbital_period = 2 * PI * sqrt(pow(calculate_binary_separation(primary, secondary), 3) / total_mass)
	return 2 * PI / orbital_period

func create_planet(planet_data: Dictionary) -> Node3D:
	var planet = planet_model_scene.instantiate()
	planet.initialize(planet_data, false, planet.ViewType.SYSTEM)
	return planet

func create_asteroid_belt(belt_data: Dictionary, star_data: Dictionary) -> Node3D:
	var belt = asteroid_belt_scene.instantiate()
	
	# Set belt properties
	belt.inner_radius = belt_data.get("Orbit") * 0.95
	belt.outer_radius = belt_data.get("Orbit") * 1.05
	belt.asteroid_count = belt_data.get("AsteroidCount", 10000)
	
	return belt

func _input(event):
	if event.is_action_pressed("return"): 
		get_parent().to_galaxy_view()
		
func get_all_planets() -> Array:
	var planets = []
	
	# Get planets from primary star
	if primary_star and primary_star.has_node("OrbitalBodies"):
		for body in primary_star.get_node("OrbitalBodies").get_children():
			planets.append(body)
	
	# Get planets from other stars
	if primary_star and primary_star.has_node("OtherStars"):
		for star in primary_star.get_node("OtherStars").get_children():
			if star.has_node("OrbitalBodies"):
				for body in star.get_node("OrbitalBodies").get_children():
					planets.append(body)
	
	return planets

func adjust_for_system_view(celestial_body: Node3D):
	# Adjust scale if needed
	const SYSTEM_SCALE_FACTOR = 0.1  # Adjust this value as needed
	celestial_body.scale *= SYSTEM_SCALE_FACTOR
	
func update_orbits(body: Node3D, delta: float):
	if body.has_method("update_orbit"):
		body.update_orbit(delta)
	
	# Update orbits of children (planets or moons)
	if body.has_node("OrbitalBodies"):
		for child in body.get_node("OrbitalBodies").get_children():
			update_orbits(child, delta)
	
	# For stars, also check other stars
	if body == primary_star and body.has_node("OtherStars"):
		for other_star in body.get_node("OtherStars").get_children():
			update_orbits(other_star, delta)
	
	if body.has_node("OrbitPath") and body.get_node("OrbitPath").has_node("PathFollow3D"):
		var orbit_path = body.get_node("OrbitPath")
		var path_follow = orbit_path.get_node("PathFollow3D")


func _process(delta):
	var camera = $Camera3D  # Adjust path as needed
	
	for planet in get_all_planets():
		var distance = camera.global_position.distance_to(planet.global_position)
		planet.update_level_of_detail(distance)
	update_orbits(primary_star, delta)
