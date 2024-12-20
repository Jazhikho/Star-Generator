extends Node

var galaxy_data: Dictionary = {}
var systems_data: Dictionary = {}

func set_data(new_galaxy_data: Dictionary, new_systems_data: Dictionary):
	galaxy_data = new_galaxy_data.duplicate(true)
	systems_data = new_systems_data.duplicate(true)
	print("GlobalData updated - Galaxy data size: ", galaxy_data.size())
	
func clear_data():
	galaxy_data.clear()
	systems_data.clear()

func is_data_loaded() -> bool:
	return !galaxy_data.is_empty() and !systems_data.is_empty()

func get_system_count() -> int:
	return galaxy_data.size()
