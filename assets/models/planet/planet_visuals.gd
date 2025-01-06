extends Node

# Planet Visuals Handler
# Manages all visual aspects of a planet
var data_handler = preload("res://assets/models/planet/planet_data.gd").new()

# Planet components
var planet_mesh: MeshInstance3D
var planet_data: Dictionary

func initialize(mesh_instance: MeshInstance3D, data: Dictionary, scale_factor: float = 1.0):
	planet_mesh = mesh_instance
	planet_data = data
	
	add_child(data_handler)
	
	setup_mesh(scale_factor)
	setup_appearance()
	#if planet_data.get("Atmosphere", 0) > 0:
		#setup_atmosphere()

func setup_mesh(scale_factor: float):
	var radius = planet_data["Diameter"] / 2 * scale_factor
	if planet_mesh.mesh is SphereMesh:
		planet_mesh.mesh.radius = radius
		planet_mesh.mesh.height = radius * 2
		setup_level_of_detail(1.0)  # Start with full detail

func setup_appearance():
	var material = StandardMaterial3D.new()
	var planet_class = planet_data.get("PlanetClass", "Rockball")
	
	var texture = data_handler.get_texture(planet_class)
	if texture:
		material.albedo_texture = texture
	else:
		material.albedo_color = data_handler.get_fallback_color(planet_class)
	
	#apply_hydrology(material)
	material.emission_enabled = true
	material.emission = Color.WHITE
	planet_mesh.material_override = material

func setup_atmosphere():
	var atmosphere = MeshInstance3D.new()
	atmosphere.name = "Atmosphere"
	atmosphere.mesh = SphereMesh.new()
	
	var atmosphere_density = planet_data["Atmosphere"]
	var atmo_scale = get_atmosphere_scale(atmosphere_density)
	
	atmosphere.mesh.radius = planet_mesh.mesh.radius * atmo_scale
	atmosphere.mesh.height = planet_mesh.mesh.height * atmo_scale
	
	var atmo_material = StandardMaterial3D.new()
	var alpha = clampf(float(atmosphere_density) / 16.0, 0.1, 0.8)
	atmo_material.albedo_color = Color(0.3, 0.7, 1.0, alpha)
	atmo_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	
	atmosphere.material_override = atmo_material
	planet_mesh.add_child(atmosphere)

func get_atmosphere_scale(density: int) -> float:
	match density:
		0: return 1.0
		1: return 1.02
		2, 3: return 1.05
		4, 5: return 1.08
		6, 7: return 1.1
		8, 9: return 1.15
		_: return 1.2

func apply_hydrology(material: StandardMaterial3D):
	var hydrology = planet_data.get("Hydrology", 0)
	if hydrology > 0:
		# Future implementation for water effects
		pass

func update_level_of_detail(distance_factor: float):
	var detail_level = clampf(distance_factor, 0.0, 1.0)
	
	# Adjust mesh detail
	if planet_mesh.mesh is SphereMesh:
		if detail_level < 0.5:
			planet_mesh.mesh.radial_segments = 16
			planet_mesh.mesh.rings = 8
		else:
			planet_mesh.mesh.radial_segments = 64
			planet_mesh.mesh.rings = 32
	
	# Adjust atmosphere visibility
	var atmosphere = planet_mesh.get_node_or_null("Atmosphere")
	if atmosphere:
		atmosphere.visible = detail_level > 0.3

func setup_level_of_detail(factor: float):
	update_level_of_detail(factor)

# Utility function for direct manipulation of visual properties
func adjust_scale(scale_factor: float):
	if planet_mesh:
		planet_mesh.scale = Vector3.ONE * scale_factor
		update_level_of_detail(1.0 / scale_factor)

func get_radius() -> float:
	return planet_mesh.mesh.radius if planet_mesh and planet_mesh.mesh is SphereMesh else 0.0

func _exit_tree():
	if data_handler:
		data_handler.queue_free()
