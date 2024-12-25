@tool
extends Node3D

@export var shader: Shader

class GalaxyStar:
	var star_position: Vector3
	var luminosity: float
	var temperature: float

	func _init(_position: Vector3, _luminosity: float, _temperature: float):
		self.star_position = _position
		self.luminosity = _luminosity
		self.temperature = _temperature

static func blackbody_to_rgb(kelvin):
	var temperature = kelvin / 100.0
	var red
	var green
	var blue

	if temperature < 66.0:
		red = 255
	else:
		red = temperature - 55.0
		red = 351.97690566805693 + 0.114206453784165 * red - 40.25366309332127 * log(red)
		red = clamp(red, 0, 255)

	if temperature < 66.0:
		green = temperature - 2
		green = -155.25485562709179 - 0.44596950469579133 * green + 104.49216199393888 * log(green)
		green = clamp(green, 0, 255)
	else:
		green = temperature - 50.0
		green = 325.4494125711974 + 0.07943456536662342 * green - 28.0852963507957 * log(green)
		green = clamp(green, 0, 255)

	if temperature >= 66.0:
		blue = 255
	elif temperature <= 20.0:
		blue = 0
	else:
		blue = temperature - 10
		blue = -254.76935184120902 + 0.8274096064007395 * blue + 115.67994401066147 * log(blue)
		blue = clamp(blue, 0, 255)

	return Color(red / 255.0, green / 255.0, blue / 255.0)

var material: ShaderMaterial
var mesh: MultiMesh
var internal_shader_params = {
	'camera_vertical_fov': true
}

func _get_property_list():
	var props = []
	var shader_params := RenderingServer.get_shader_parameter_list(shader.get_rid())
	for p in shader_params:
		if internal_shader_params.has(p.name):
			continue
		var cp = {}
		for k in p:
			cp[k] = p[k]
		cp.name = str("shader_params/", p.name)
		props.append(cp)
	return props

func _get(p_key: StringName):
	var key = String(p_key)
	if key.begins_with("shader_params/"):
		var param_name = key.substr(len("shader_params/"))
		var value = material.get_shader_parameter(param_name)
		if value == null:
			value = RenderingServer.shader_get_parameter_default(material.shader, param_name)
		return value

func _set(p_key: StringName, value):
	var key = String(p_key)
	if key.begins_with("shader_params/"):
		var param_name := key.substr(len("shader_params/"))
		material.set_shader_parameter(param_name, value)

func _init():
	material = ShaderMaterial.new()
	material.shader = shader

	var quad = QuadMesh.new()
	quad.orientation = PlaneMesh.FACE_Z
	quad.size = Vector2(1, 1)
	quad.material = material

	mesh = MultiMesh.new()
	mesh.transform_format = MultiMesh.TRANSFORM_3D
	mesh.use_colors = true
	mesh.use_custom_data = true
	mesh.mesh = quad

	var inst = MultiMeshInstance3D.new()
	inst.multimesh = mesh

	add_child(inst)

func set_star_list(star_list: Array):
	mesh.instance_count = 0
	mesh.instance_count = star_list.size()

	for i in range(star_list.size()):
		var star = star_list[i]
		var star_transform = Transform3D().translated(star.coords)
		mesh.set_instance_transform(i, star_transform)
		mesh.set_instance_color(i, blackbody_to_rgb(star.temperature))
		mesh.set_instance_custom_data(i, Color(star.luminosity, 0, 0, 0))

func _process(_delta):
	var camera = get_viewport().get_camera_3d()
	var fov = 70
	if camera:
		fov = camera.fov

	material.shader = shader
	material.set_shader_parameter('camera_vertical_fov', fov)
