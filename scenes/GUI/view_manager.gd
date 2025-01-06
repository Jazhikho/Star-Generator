extends Node3D

@onready var galaxy_environment = $WorldEnvironment
@onready var camera: Camera3D = $Camera3D
@onready var galaxy_view: Node3D = $GalaxyView
@onready var system_view: Node3D = $SystemView
@onready var object_view: Node3D = $ObjectView

enum ViewType {
	TITLE,
	GALAXY,
	SYSTEM,
	OBJECT
}

var current_view: ViewType = ViewType.TITLE
var system_data: Dictionary
var main_menu_button

signal view_changed(view_type: ViewType)
signal star_selected(star_data: Dictionary)
signal planet_selected(planet_data: Dictionary)

func _ready():
	main_menu_button = $"../../../../VBoxContainer/TopBar/MainMenuButton"
	setup_views()
	connect_signals()

func connect_signals():
	var input_manager = $"../../../../InputManager"
	input_manager.mouse_clicked.connect(_on_mouse_clicked)
	input_manager.escape_pressed.connect(handle_escape)
	
	system_view.celestial_body_selected.connect(_on_celestial_body_selected)
	system_view.transition_to_object_view.connect(_on_transition_to_object_view)
	if main_menu_button:
		main_menu_button.pressed.connect(_on_main_menu_button_pressed)

func _on_main_menu_button_pressed():
	print("Main menu button pressed")

func clear_all_views():
	galaxy_view.clear_collision_spheres()
	system_view.clear_system()
	#object_view.clear()

func initialize_from_loaded_data(galaxy_data: Dictionary, systems_data: Dictionary):
	$TitleScreen.queue_free()
	clear_all_views()
	GlobalData.set_data(galaxy_data, systems_data)
	galaxy_view.setup_galaxy_view()
	camera.setup_for_galaxy_view()
	current_view = ViewType.GALAXY
	set_view_visibility(ViewType.GALAXY)
	emit_signal("view_changed", ViewType.GALAXY)

func setup_views():
	set_view_visibility(ViewType.TITLE)

func set_view_visibility(view: ViewType):
	galaxy_view.visible = view == ViewType.GALAXY
	system_view.visible = view == ViewType.SYSTEM
	object_view.visible = view == ViewType.OBJECT

func transition_to_system_view(system_data):
	clear_all_views()
	current_view = ViewType.SYSTEM
	system_view.initialize_system(system_data)
	camera.setup_for_system_view()
	set_view_visibility(ViewType.SYSTEM)
	emit_signal("view_changed", ViewType.SYSTEM)

func transition_to_object_view(object_data: Dictionary):
	clear_all_views()
	current_view = ViewType.OBJECT
	object_view.initialize(object_data)
	# TODO: Implement camera setup for object view
	set_view_visibility(ViewType.OBJECT)
	emit_signal("view_changed", ViewType.OBJECT)

func return_to_galaxy_view():
	clear_all_views()
	current_view = ViewType.GALAXY
	galaxy_view.setup_galaxy_view()
	camera.setup_for_galaxy_view()
	set_view_visibility(ViewType.GALAXY)
	emit_signal("view_changed", ViewType.GALAXY)

func _on_celestial_body_selected(body_data: Dictionary):
	emit_signal("planet_selected", body_data)

func _on_transition_to_object_view(body_data: Dictionary):
	transition_to_object_view(body_data)

func _on_mouse_clicked(event_position: Vector2, is_double_click: bool):
	match current_view:
		ViewType.GALAXY:
			handle_galaxy_click(event_position, is_double_click)
		ViewType.SYSTEM:
			handle_system_click(event_position, is_double_click)
		ViewType.OBJECT:
			handle_object_click(event_position, is_double_click)
		_:
			pass

func handle_galaxy_click(event_position: Vector2, is_double_click: bool):
	var result = perform_raycast(event_position)
	
	if result and result.collider is Area3D and result.collider.has_meta("star_data"):
		var star_data = result.collider.get_meta("star_data")
		system_data = GlobalData.systems_data[star_data.id]
		
		if is_double_click:
			transition_to_system_view(system_data)
		else:
			camera.pan_to_point(result.collider.position)
			emit_signal("star_selected", system_data)

func handle_system_click(event_position: Vector2, is_double_click: bool):
	var result = perform_raycast(event_position)
	
	if result and result.collider is Area3D:
		var data = null
		if result.collider.get_parent().has_meta("planet_data"):
			data = result.collider.get_parent().get_meta("planet_data")
		elif result.collider.has_meta("star_data"):
			data = result.collider.get_meta("star_data")
		
		if data:
			if is_double_click:
				transition_to_object_view(data)
			else:
				camera.pan_to_point(result.collider.global_position)
				if "PlanetClass" in data:
					emit_signal("planet_selected", data)
				else:
					emit_signal("star_selected", data)

func handle_object_click(_event_position: Vector2, _is_double_click: bool):
	# Implement if needed
	pass

func perform_raycast(event_position: Vector2):
	var viewport = get_viewport()
	if !viewport:
		return null
		
	var viewport_rect = viewport.get_visible_rect()
	if !viewport_rect.has_point(event_position):
		return null
		
	var from = camera.project_ray_origin(event_position)
	var to = from + camera.project_ray_normal(event_position) * 10000
	
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = true
	query.collision_mask = 1
	
	return get_world_3d().direct_space_state.intersect_ray(query)

func handle_escape():
	match current_view:
		ViewType.SYSTEM:
			print("Returning to galaxy view")  # Debug output
			return_to_galaxy_view()
		ViewType.OBJECT:
			print("Returning to system view")  # Debug output
			transition_to_system_view(system_data)
