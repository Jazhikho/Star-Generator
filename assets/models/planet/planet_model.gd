extends Node3D

enum ViewType {OBJECT, SYSTEM}

@export var planet_radius := 1.0
@export var orbit_radius := 5.0
@export var orbit_eccentricity := 0.0
@export var rotation_speed := 1.0
@export var orbit_speed := 1.0
@export var is_moon := false
@export var speed_scale := 8760

var ring_node: Node3D
@onready var rings = preload("res://assets/models/asteroidbelt/asteroid_belt_model.tscn")

@export var surface_color : Color = Color.WHITE
@export var atmosphere_color : Color = Color(0.3, 0.7, 1.0, 0.5)
@export var has_atmosphere := false

@onready var planet_mesh = $MeshInstance3D
@onready var orbit_path = $OrbitPath
@onready var orbit_follow = $OrbitPath/PathFollow3D


@export var planet_class : String = "Rockball"

const PLANET_SCALE_FACTOR = 1 

var planet_data
var texture_variation : int = 1
var parent_body = null

var texture_paths = {
	"Acheronian": "res://assets/textures/planets/acheronian/",
	"Arean": "res://assets/textures/planets/arean/",
	"Arid": "res://assets/textures/planets/arid/",
	"Asphodelian": "res://assets/textures/planets/asphodelian/",
	"Chthonian": "res://assets/textures/planets/chthonian/",
	"Hebean": "res://assets/textures/planets/hebean/",
	"Helian": "res://assets/textures/planets/helian/",
	"JaniLithic": "res://assets/textures/planets/janilithic/",
	"Jovian": "res://assets/textures/planets/jovian/",
	"Hephaestian": "res://assets/textures/planets/hephaestian/",
	"Oceanic": "res://assets/textures/planets/oceanic/",
	"Panthalassic": "res://assets/textures/planets/panthalassic/",
	"Promethean": "res://assets/textures/planets/promethean/",
	"Rockball": "res://assets/textures/planets/rockball/",
	"Snowball": "res://assets/textures/planets/snowball/",
	"Stygian": "res://assets/textures/planets/stygian/",
	"Tectonic": "res://assets/textures/planets/tectonic/",
	"Telluric": "res://assets/textures/planets/telluric/",
	"Vesperian": "res://assets/textures/planets/vesperian/"
}

func initialize(data: Dictionary, _moon: bool = false, view_type: ViewType = ViewType.OBJECT):
	planet_data = data
	planet_radius = data["Diameter"] / 2
	orbit_radius = data["Orbit"]
	orbit_eccentricity = data.get("Eccentricity", 0)
	rotation_speed = 2 * PI / abs(data["RotationalPeriod"] * speed_scale)
	orbit_speed = 2 * PI / (data["OrbitalPeriod"] * speed_scale)
	planet_class = data["PlanetClass"]
	has_atmosphere = data["Atmosphere"] > 0
	self.is_moon = _moon
	
	call_deferred("deferred_setup", view_type, data)

func deferred_setup(view_type: ViewType, data: Dictionary):
	match view_type:
		ViewType.SYSTEM:
			scale *= 0.1
	
	setup_planet()
	setup_orbit()
	
	if "Satellites" in data and !data["Satellites"].is_empty():
		# Check if the first satellite is a ring system
		var first_satellite = data["Satellites"][0]
		if first_satellite.get("Type") == "Rings":
			setup_rings(first_satellite)
		
		# Handle other satellites (moons)
		setup_moons(data["Satellites"])
		
func setup_planet():
	var scaled_radius = (planet_radius * PLANET_SCALE_FACTOR)
	planet_mesh.mesh.radius = scaled_radius
	planet_mesh.mesh.height = scaled_radius * 2

	#setup_atmosphere()
	setup_appearance()

func setup_atmosphere():
	if has_atmosphere:
		var atmosphere = MeshInstance3D.new()
		atmosphere.name = "Atmosphere"
		atmosphere.mesh = SphereMesh.new()
		
		# Scale atmosphere size based on atmosphere density
		var atmo_scale = 1.0
		var atmosphere_value = planet_data["Atmosphere"]
		match atmosphere_value:
			0: return  # No atmosphere
			1: atmo_scale = 1.02  # Trace
			2, 3: atmo_scale = 1.05  # Very Thin
			4, 5: atmo_scale = 1.08  # Thin
			6, 7: atmo_scale = 1.01   # Standard
			8, 9: atmo_scale = 1.15  # Dense
			_: atmo_scale = 1.2      # Super Dense

		atmosphere.mesh.radius = planet_mesh.mesh.radius * atmo_scale
		atmosphere.mesh.height = planet_mesh.mesh.height * atmo_scale
		
		var atmo_material = StandardMaterial3D.new()
		
		# Adjust atmosphere color and opacity based on density
		var alpha = clampf(float(atmosphere_value) / 16.0, 0.1, 0.8)
		atmo_material.albedo_color = atmosphere_color
		atmo_material.albedo_color.a = alpha
		atmo_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		
		atmosphere.material_override = atmo_material
		planet_mesh.add_child(atmosphere)
		
func setup_appearance():
	var material = StandardMaterial3D.new()
	
	var texture = load_random_texture(planet_class)
	if texture:
		material.albedo_texture = texture
	else:
		material.albedo_color = get_fallback_color(planet_class)
	
	# Adjust appearance based on hydrology
	if planet_data["Hydrology"] > 0:
		# Add water overlay or adjust appearance based on water coverage
		#var water_overlay = load("res://path/to/water_overlay.png")  # You'll need to create this
		#if water_overlay:
			#material.detail_enabled = true
			#material.detail_mask = water_overlay
			#material.detail_blend_mode = BaseMaterial3D.BLEND_MODE_MIX
			#material.detail_uv_layer = 1
		pass
	
	planet_mesh.material_override = material
		
func setup_moons(satellites: Array):
	for satellite in satellites:
		if "NestedList" in satellite:
			if satellite["NestedList"].is_empty():
				print("Empty NestedList found")
			else:
				for moon_data in satellite["NestedList"]:
					create_moon(moon_data)

func create_moon(moon_data: Dictionary):
	var moon = load("res://assets/models/planet/planet_model.tscn").instantiate()
	if not moon:
		print("Failed to instantiate moon scene")
		return

	var moon_orbit_container = Node3D.new()
	$OrbitalBodies.add_child(moon_orbit_container)
	
	moon_orbit_container.add_child(moon)
	
	# Initialize the moon
	moon.initialize(moon_data, true)
	
	# Setup the moon's position relative to its orbit container
	moon.position = Vector3(moon.orbit_radius, 0, 0)
	
	return moon_orbit_container
	
func setup_rings(ring_data: Dictionary):
	var ring = rings.instantiate()
	
	# Set ring properties relative to planet size
	if ring_data["RingType"] == "Simple":
		ring.inner_radius = ring_data.get("Orbit") * scale.x * 0.975
		ring.outer_radius = ring_data.get("Orbit") * scale.x * 1.025
	else:
		ring.inner_radius = ring_data.get("InnerOrbit") * scale.x
		ring.outer_radius = ring_data.get("OuterOrbit") * scale.x
	
	ring.asteroid_count = 1000  # Lower count for planet rings
	
	add_child(ring)

func load_random_texture(p_class: String) -> Texture:
	var base_path = texture_paths.get(p_class, "")
	if base_path == "":
		return null
	
	var dir = DirAccess.open(base_path)
	if not dir:
		return null
	
	var files = []
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".png"):
			files.append(file_name)
		file_name = dir.get_next()
	dir.list_dir_end()
	
	if files.size() == 0:
		return null
	
	texture_variation = randi() % files.size()
	return load(base_path + files[texture_variation])

func get_fallback_color(p_class: String) -> Color:
	print("Texture failed, Going to default color")
	match p_class:
		"Acheronian":
			return Color(0.5, 0.4, 0.3)  # Scorched brown
		"Arean":
			return Color(0.8, 0.4, 0.2)  # Mars-like red-orange
		"Arid":
			return Color(0.9, 0.8, 0.6)  # Sandy yellow
		"Asphodelian":
			return Color(0.3, 0.3, 0.3)  # Dark gray
		"Chthonian":
			return Color(0.2, 0.2, 0.3)  # Deep blue-gray
		"Hebean":
			return Color(0.6, 0.5, 0.4)  # Light brown
		"Helian":
			return Color(0.7, 0.8, 0.9)  # Pale blue
		"JaniLithic":
			return Color(0.4, 0.4, 0.4)  # Medium gray
		"Jovian":
			return Color(0.8, 0.7, 0.6)  # Light tan (Jupiter-like)
		"Hephaestian":
			return Color(0.8, 0.2, 0.1)  # Bright red/orange
		"Oceanic":
			return Color(0.2, 0.3, 0.8)  # Deep blue
		"Panthalassic":
			return Color(0.1, 0.4, 0.9)  # Bright blue
		"Promethean":
			return Color(0.7, 0.7, 0.8)  # Light gray
		"Rockball":
			return Color(0.5, 0.5, 0.5)  # Medium gray
		"Snowball":
			return Color(0.9, 0.9, 1.0)  # Near white
		"Stygian":
			return Color(0.2, 0.2, 0.2)  # Very dark gray
		"Tectonic":
			return Color(0.3, 0.5, 0.7)  # Earth-like blue
		"Telluric":
			return Color(0.6, 0.7, 0.5)  # Pale green
		"Vesperian":
			return Color(0.4, 0.6, 0.8)  # Sky blue
	return Color(0.5, 0.5, 0.5)  # Default gray

func setup_orbit():
	if is_moon:
		# If this is a moon, we don't need the orbit path
		# as the moon will rotate around its parent container
		if orbit_path:
			orbit_path.queue_free()
		if orbit_follow:
			orbit_follow.queue_free()
		return
	
	if !orbit_path:
		orbit_path = $OrbitPath
	if !orbit_follow:
		orbit_follow = $OrbitPath/PathFollow3D
	
	var curve = Curve3D.new()
	for i in range(128):
		var angle = i * (2*PI / 128)
		var x = orbit_radius * cos(angle)
		var z = orbit_radius * (1 - orbit_eccentricity) * sin(angle)
		curve.add_point(Vector3(x, 0, z))
	orbit_path.curve = curve

func reparent_to_planet():
	if parent_body and parent_body.orbit_follow:
		# Remove from current parent
		var current_parent = orbit_path.get_parent()
		if current_parent:
			current_parent.remove_child(orbit_path)
		# Add to planet's PathFollow3D
		parent_body.orbit_follow.add_child(orbit_path)

func update_level_of_detail(camera_distance: float):
	var detail_level = clamp(1.0 - (camera_distance / 1000.0), 0.0, 1.0)
	
	# Adjust visibility of features based on distance
	if has_node("Atmosphere"):
		$Atmosphere.visible = detail_level > 0.3
	
	# Maybe simplify the mesh for distant objects
	if detail_level < 0.5:
		planet_mesh.mesh.radial_segments = 16
		planet_mesh.mesh.rings = 8
	else:
		planet_mesh.mesh.radial_segments = 64
		planet_mesh.mesh.rings = 32
		
func update_orbit(delta: float):
	if is_moon:
		var parent_container = get_parent()
		if parent_container:
			parent_container.rotate_y(orbit_speed * delta)
	else:
		if orbit_follow:
			orbit_follow.progress_ratio = fmod(
				orbit_follow.progress_ratio + (orbit_speed * delta),
				1.0
			)

func _process(delta):
	planet_mesh.rotate_y(rotation_speed * delta)
	
	update_orbit(delta)
			
	#if Engine.get_physics_frames() % 60 == 0:  # Print every 60 frames
		#debug_print_moon_positions()

func debug_print_moon_positions():
	if has_node("OrbitalBodies"):
		for orbit_container in $OrbitalBodies.get_children():
			for moon in orbit_container.get_children():
				if moon.is_moon:
					print("Moon position: ", moon.global_position)
