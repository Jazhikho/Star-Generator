extends Node3D

@onready var celestial_body_scene = preload("res://Resources/Objects/celestial_body.tscn")

func _ready():
	setup_system(Global.current_system_data)
	generate_solar_system()

func setup_system(system_data):
	for body_name in system_data:
		var body_data = system_data[body_name]

func generate_solar_system():
	var suns = {}
	
	# First, create all the suns
	for body_name in Global.solar_system_data.keys():
		var body_data = Global.solar_system_data[body_name]
		
		if not body_data.has("orbital_radius"):
			# This is a sun
			var sun = create_celestial_body(body_name, body_data)
			suns[body_name] = sun
	
	# Then create all the planets
	for body_name in Global.solar_system_data.keys():
		var body_data = Global.solar_system_data[body_name]
		
		if body_data.has("orbital_radius"):
			# This is a planet
			create_celestial_body(body_name, body_data, suns["Sun"])

func create_celestial_body(body_name: String, body_data: Dictionary, parent_body: Node3D = null) -> Node3D:
	var body = celestial_body_scene.instantiate()
	add_child(body)
	
	body.name = body_name
	
	# Set the mesh scale based on radius
	var mesh_instance = body.get_child(0) as MeshInstance3D
	mesh_instance.scale = Vector3.ONE * body_data.radius
	
	if parent_body:
		body.orbital_center = parent_body
		body.orbital_radius = body_data.orbital_radius
		body.orbital_speed = body_data.orbital_speed
	else:
		# This is a sun, position it based on orbital_radius if specified
		if body_data.has("orbital_radius"):
			body.position = Vector3(body_data.orbital_radius, 0, 0)
	
	return body

func _input(event):
	if event.is_action_pressed("ui_cancel"):  # ESC key
		transition_to_star_map()

func transition_to_star_map():
	# Create a ColorRect for transition effect
	var transition_rect = ColorRect.new()
	transition_rect.color = Color(0, 0, 0, 0)  # Start fully transparent
	transition_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(transition_rect)
	
	# Fade to black
	var tween = create_tween()
	tween.tween_property(transition_rect, "color", Color(0, 0, 0, 1), 1.0)
	await tween.finished
	
	# Change back to the star map scene
	get_tree().change_scene_to_file("res://galaxy_view.tscn")
