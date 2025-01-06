extends Node3D

# Node references
var core_mesh
var click_area
var star_light
var data

# Preloaded resources and constants
const LUMINOSITY_MULTI := 382                   # Most stars will have a luminosity below 1, this brightens them
const SIZE_MULTI := 0.00466                     # For conversion to AU
const SHADER_TEMPERATURE_RANGES = {             # Constants for shader selection
	3000: "res://assets/models/star/3000K.gdshader",  # M-type
	4000: "res://assets/models/star/4000K.gdshader",  # K-type
	5400: "res://assets/models/star/5400K.gdshader",  # G-type
	6100: "res://assets/models/star/6100K.gdshader",  # F-type
	7400: "res://assets/models/star/7400K.gdshader",  # A-type
	9800: "res://assets/models/star/9800K.gdshader",  # B-type
	33000: "res://assets/models/star/33000K.gdshader" # O-type
}

# Star properties
var star_radius: float
var temperature: float
var luminosity: float
var spectral_type: String
var luminosity_class: int
var mass: float
var flare_star: bool
var star_data: Dictionary

func initialize(_data: Dictionary):
	star_data = _data
	core_mesh = $star
	click_area = $star/StarBody/CollisionShape3D.shape.radius
	star_light = $OmniLight3D
	data = $StarData
	# Adjust all factors based on incoming data
	star_radius = star_data.get("Diameter", 1.0) / 2 * SIZE_MULTI 
	temperature = star_data.get("Temperature", 5778.0)
	luminosity = star_data.get("Luminosity", 1.0) * LUMINOSITY_MULTI
	spectral_type = star_data.get("SpectralType", "G2")
	luminosity_class = star_data.get("LuminosityClass", 5)
	mass = star_data.get("Mass", 1.0)
	flare_star = star_data.get("IsFlareStar", false)
	
	setup_visuals()    # Prepare the visual representation
	
	# Additional setup for flare stars
	if flare_star:
		setup_flare_system()

func setup_visuals():
	# Get and set appropriate shader based on temperature and spectral type
	var shader_path = get_appropriate_shader(temperature, spectral_type, luminosity_class)
	var star_shader = load(shader_path)
	
	var material = ShaderMaterial.new()
	material.shader = star_shader
	core_mesh.material_override = material
	
	# Increase visibility of stars
	core_mesh.mesh.radius = star_radius
	core_mesh.mesh.height = star_radius * 2
	click_area = star_radius
	
	# Enhance star light
	star_light.light_energy = luminosity * 10  # Increased from 5
	star_light.omni_range = star_radius * sqrt(luminosity) * 300  # Increased from 150
	star_light.omni_attenuation = 0.5  # Adjust this for better light falloff

func get_appropriate_shader(temp: float, spec_type: String, lum_class: int) -> String:
	# Handle special cases
	if spec_type.begins_with("L"):    # Brown dwarfs
		return "res://assets/models/star/browndwarf.gdshader"
	if lum_class == 7:                # White dwarfs
		return "res://assets/models/star/whitedwarf.gdshader"
	
	# Find closest temperature match for main sequence stars
	var closest_temp = SHADER_TEMPERATURE_RANGES.keys()[0]
	for shader_temp in SHADER_TEMPERATURE_RANGES.keys():
		if abs(temp - shader_temp) < abs(temp - closest_temp):
			closest_temp = shader_temp
	
	return SHADER_TEMPERATURE_RANGES[closest_temp]

# Set up orbit around another star
func setup_orbit(other_star: Node):
	# Use OrbitSetup to create the orbit
	OrbitSetup.setup_orbit(
		self,
		other_star,
		star_data.get("HierarchicalSeparation", 1.0),
		star_data.get("HierarchicalEccentricity", 0.0)
	)

func setup_flare_system():
	# Placeholder for flare star behavior
	# This could involve particle systems, light fluctuations, etc.
	pass

# Mass getter for orbital calculations
func get_mass() -> float:
	print("Star ", name, " returning mass: ", mass)  # Debug output
	return mass
