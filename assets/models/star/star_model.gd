extends Node3D

const LUMINOSITY_MULTI := 382
const SIZE_MULTI := 27

# Star properties
@export var star_radius := 1.0
@export var temperature := 5778.0
@export var luminosity := 1.0
@export var spectral_type : String = "G2"
@export var luminosity_class : int = 5
@export var mass := 1.0
@export var flare_star := false

# Orbit properties
@export var orbit_radius := 0.0
@export var orbit_eccentricity := 0.0
@export var orbit_speed := 0.0

@onready var core_mesh = $star
@onready var orbit_path = $OrbitPath
@onready var orbit_follow = $OrbitPath/PathFollow3D
@onready var star_light = $OmniLight3D

func get_appropriate_shader(temp: float, spec_type: String, lum_class: int) -> String:
	print("getting shader...")
	if spec_type.begins_with("L"):
		return "res://assets/models/star/browndwarf.gdshader"
	if lum_class == 7:
		return "res://assets/models/star/whitedwarf.gdshader"
	
	var shader_temps = [3000, 4000, 5400, 6100, 7400, 9800, 33000]
	var closest_temp = shader_temps[0]
	
	for t in shader_temps:
		if abs(temp - t) < abs(temp - closest_temp):
			closest_temp = t
	
	print("Using shader for %s" % [closest_temp])
	return "res://assets/models/star/%dK.gdshader" % closest_temp

func initialize(data: Dictionary):
	star_radius = data.get("Radius", 1.0) * SIZE_MULTI
	temperature = data.get("Temperature", 5778.0)
	luminosity = data.get("Luminosity", 1.0) * LUMINOSITY_MULTI
	spectral_type = data.get("SpectralType", "G2")
	luminosity_class = data.get("LuminosityClass", 5)
	mass = data.get("Mass", 1.0)
	orbit_radius = data.get("Orbit", 0.0)
	orbit_eccentricity = data.get("Eccentricity", 0.0)
	flare_star = data.get("IsFlareStar", false)
	
	setup_visuals()
	setup_orbit()

func setup_visuals():
	var shader_path = get_appropriate_shader(temperature, spectral_type, luminosity_class)
	var star_shader = load(shader_path)
	
	# Set up material
	var material = ShaderMaterial.new()
	material.shader = star_shader
	
	# Set star size
	core_mesh.scale = Vector3.ONE * star_radius
	
	# Adjust light intensity based on luminosity
	star_light.light_energy = luminosity / 1000
	star_light.omni_range = star_radius * 10  # Adjust range based on star size
	
	# Apply material
	core_mesh.material_override = material

func setup_orbit():
	if orbit_radius == 0:
		if is_instance_valid(orbit_path) and orbit_path != null:
			orbit_path.queue_free()
			orbit_path = null
		if is_instance_valid(orbit_follow) and orbit_follow != null:
			orbit_follow.queue_free()
			orbit_follow = null
		return

	if !orbit_path:
		orbit_path = Path3D.new()
		orbit_path.name = "OrbitPath"
		add_child(orbit_path)
	if !orbit_follow:
		orbit_follow = PathFollow3D.new()
		orbit_path.add_child(orbit_follow)
	
	var curve = Curve3D.new()
	for i in range(128):
		var angle = i * (2*PI / 128)
		var x = orbit_radius * cos(angle)
		var z = orbit_radius * (1 - orbit_eccentricity) * sin(angle)
		curve.add_point(Vector3(x, 0, z))
	orbit_path.curve = curve

func update_orbit(delta: float):
	if orbit_radius > 0 and orbit_follow:
		orbit_follow.progress_ratio = fmod(
			orbit_follow.progress_ratio + (orbit_speed * delta),
			1.0
		)

func _process(delta):
	update_orbit(delta)
	if core_mesh.material_override:
		var current_time = Time.get_ticks_msec() / 1000.0
		core_mesh.material_override.set_shader_parameter("star_time", current_time)
