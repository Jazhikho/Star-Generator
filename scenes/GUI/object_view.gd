extends Node3D

var object_data: Dictionary

@onready var planet_model = $PlanetModel

func initialize(planet_dict: Dictionary):
	object_data = planet_dict
	setup_planet()

func setup_planet():
	if object_data.is_empty():
		push_error("No object data provided")
		return
	
	# Clear any existing orbital bodies
	for child in planet_model.get_node("OrbitalBodies").get_children():
		child.queue_free()
	
	planet_model.initialize(object_data, false, planet_model.ViewType.OBJECT)
