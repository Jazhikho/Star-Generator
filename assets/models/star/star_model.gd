extends Node3D

const LUMINOSITY_MULTI := 382
const SIZE_MULTI := 27

# Star properties
@export var star_radius := 1.0
@export var temperature := 5778.0  # Sun's temperature in Kelvin
@export var luminosity := 1.0  # Relative to Sun
@export var spectral_type : String = "G2"  # Sun's spectral type
@export var luminosity_class : int = 5  # Main sequence
@export var mass := 1.0  # Solar masses

# Orbit properties (for multi-star systems)
@export var orbit_radius := 0.0
@export var orbit_eccentricity := 0.0
@export var orbit_speed := 0.0

@onready var core_mesh = $CoreMesh
@onready var atmosphere_mesh = $AtmosphereMesh
@onready var corona_particles = $CoronaParticles
@onready var prominence_particles = $ProminenceParticles
@onready var flare_mesh = $FlareMesh
@onready var orbit_path = $OrbitPath
@onready var orbit_follow = $OrbitPath/PathFollow3D

var core_shader = preload("res://assets/models/star/star_core.gdshader")
var atmosphere_shader = preload("res://assets/models/star/star_atmosphere.gdshader")
var corona_shader = preload("res://assets/models/star/star_corona.gdshader")
var flare_shader = preload("res://assets/models/star/star_flare.gdshader")

func initialize(data: Dictionary):
	star_radius = data.get("Radius", 1.0) * SIZE_MULTI
	temperature = data.get("Temperature", 5778.0)
	luminosity = data.get("Luminosity", 1.0) * LUMINOSITY_MULTI
	spectral_type = data.get("SpectralType", "G2")
	luminosity_class = data.get("LuminosityClass", 5)
	mass = data.get("Mass", 1.0)
	orbit_radius = data.get("Orbit", 0.0)
	orbit_eccentricity = data.get("Eccentricity", 0.0) / 100
	
	setup_visuals()
	setup_orbit()

func setup_visuals():
	var star_color = get_star_color()
	
	# Core setup
	core_mesh.mesh.radius = star_radius
	core_mesh.mesh.height = star_radius * 2
	var core_material = core_mesh.material_override

# If there's no material assigned, create a new one
	if not core_material:
		core_material = ShaderMaterial.new()
		core_material.shader = core_shader
		core_mesh.material_override = core_material

	core_material.set_shader_parameter("star_color", star_color)
	core_material.set_shader_parameter("temperature", temperature)
	core_mesh.material_override = core_material
	
	# Atmosphere setup
	atmosphere_mesh.mesh.radius = star_radius * 1.05
	atmosphere_mesh.mesh.height = star_radius * 2.1
	var atmosphere_material = atmosphere_mesh.material_override
	if not atmosphere_material:
		atmosphere_material = ShaderMaterial.new()
		atmosphere_material.shader = atmosphere_shader
		atmosphere_mesh.material_override = atmosphere_material
	atmosphere_material.set_shader_parameter("star_color", star_color)

	# Flare setup
	flare_mesh.mesh.radius = star_radius * 1.5
	flare_mesh.mesh.height = star_radius * 3
	var flare_material = flare_mesh.material_override
	if not flare_material:
		flare_material = ShaderMaterial.new()
		flare_material.shader = flare_shader
		flare_mesh.material_override = flare_material
	flare_material.set_shader_parameter("star_color", star_color)
	flare_material.set_shader_parameter("intensity", luminosity)
	
	# Corona particles setup
	var corona_process_material = corona_particles.process_material as ParticleProcessMaterial
	if not corona_process_material:
		corona_process_material = ParticleProcessMaterial.new()
		corona_particles.process_material = corona_process_material
	
	# Update process material properties
	corona_process_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	corona_process_material.emission_sphere_radius = star_radius * 1.1
	corona_process_material.particle_flag_disable_z = true
	corona_process_material.gravity = Vector3.ZERO
	corona_process_material.initial_velocity_min = 0.1
	corona_process_material.initial_velocity_max = 0.5
	corona_process_material.scale_min = star_radius * 0.1
	corona_process_material.scale_max = star_radius * 0.3
	corona_process_material.color = star_color
	corona_process_material.color.a = 0.1

	# Get or create the draw pass material
	var draw_pass_1 = corona_particles.draw_pass_1 as QuadMesh
	if not draw_pass_1:
		draw_pass_1 = QuadMesh.new()
		corona_particles.draw_pass_1 = draw_pass_1
	
	var corona_material = draw_pass_1.surface_get_material(0) as StandardMaterial3D
	if not corona_material:
		corona_material = StandardMaterial3D.new()
		draw_pass_1.surface_set_material(0, corona_material)
	
	# Set material properties
	corona_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	corona_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	corona_material.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	corona_material.vertex_color_use_as_albedo = true
	
	# Prominence particles setup
	var prominence_process_material = prominence_particles.process_material as ParticleProcessMaterial
	if prominence_process_material:
		prominence_process_material.emission_sphere_radius = star_radius
		prominence_process_material.scale_min = star_radius * 0.05
		prominence_process_material.scale_max = star_radius * 0.15
		prominence_process_material.color = star_color

	# Adjust the quad mesh for prominence particles
	var prominence_quad_mesh = prominence_particles.draw_pass_1 as QuadMesh
	if prominence_quad_mesh:
		prominence_quad_mesh.size = Vector2(1, 1)  # Adjust as needed

	# Modify the material of the prominence quad mesh
	var prominence_material = prominence_quad_mesh.surface_get_material(0) as StandardMaterial3D
	if prominence_material:
		prominence_material.albedo_color = star_color
		prominence_material.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
		prominence_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		prominence_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		prominence_material.vertex_color_use_as_albedo = true

func get_star_color() -> Color:
	# More accurate color representation based on temperature
	var x = temperature / 1000.0
	var r: float
	var g: float
	var b: float
	
	if temperature <= 6600:
		r = 1
		g = 0.39 * log(x) - 0.65
		b = 0.4 + 0.6 * log(x - 0.5)
	else:
		r = 1.2929 * pow(x - 0.5, -0.2662)
		g = 1.1298 * pow(x - 0.5, -0.1153)
		b = 1
	
	return Color(
		clamp(r, 0, 1),
		clamp(g, 0, 1),
		clamp(b, 0, 1)
	)

func setup_orbit():
	if orbit_radius == 0:
		if orbit_path:
			orbit_path.queue_free()
		if orbit_follow:
			orbit_follow.queue_free()
		return  # Central star doesn't orbit
	
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
		var time = Time.get_ticks_msec() / 1000.0
		core_mesh.material_override.set_shader_parameter("time", time)
