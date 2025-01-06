extends Node

const EARTH_MASS_TO_SOLAR = 3.0034896e-6  # Conversion factor from Earth masses to Solar masses

# Sets up an orbit between two bodies
func setup_orbit(orbiting_body: Node, primary_body: Node, separation: float, eccentricity: float) -> void:
	# Calculate mass properties
	var mass_data = calculate_mass_properties(primary_body, orbiting_body)
	var orbital_period = calculate_orbital_period(separation, mass_data.total_mass)
	
	# Register orbit with controller
	OrbitController.register_orbit(
		orbiting_body.get_instance_id(),
		primary_body,
		separation,
		eccentricity,
		orbital_period,
		mass_data.mass_ratio
	)

# Calculates combined mass and mass ratio for the orbiting bodies
func get_body_mass(body: Node) -> Dictionary:
	var mass = 0.0
	var is_planet = false
	
	if body is Node3D:
		if body.is_in_group("planets"):
			is_planet = true
			if body.has_method("get_mass"):
				mass = body.get_mass() * EARTH_MASS_TO_SOLAR  # Convert Earth masses to Solar masses
		elif body.has_method("get_total_mass"):
			mass = body.get_total_mass()
		elif body.has_method("get_mass"):
			mass = body.get_mass()
		
		# If it's a subsystem, sum up the masses of its children
		if body.name.ends_with("SubSystem"):
			mass = 0.0  # Reset mass for subsystem
			for child in body.get_children():
				var child_mass = get_body_mass(child)
				mass += child_mass.mass
	
	return {
		"mass": mass,
		"is_planet": is_planet
	}

func calculate_mass_properties(primary_body: Node, orbiting_body: Node) -> Dictionary:
	var primary_data = get_body_mass(primary_body)
	var orbiting_data = get_body_mass(orbiting_body)
	
	var primary_mass = primary_data.mass
	var orbiting_mass = orbiting_data.mass
	var total_mass = primary_mass + orbiting_mass
	
	var mass_ratio = 0.0
	if total_mass > 0:
		mass_ratio = orbiting_mass / total_mass
	else:
		push_error("Total mass is zero for orbital setup")
	
	return {
		"total_mass": total_mass,
		"mass_ratio": mass_ratio
	}

# Calculates orbital period using Kepler's Third Law
func calculate_orbital_period(separation: float, total_mass: float) -> float:
	if total_mass <= 0 or separation <= 0:
		push_error("Invalid orbital parameters: separation=%f, mass=%f" % [separation, total_mass])
		return 0.0
	return TAU * sqrt(pow(separation, 3) / total_mass)
