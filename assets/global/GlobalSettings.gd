extends Node

var galaxy_settings = {
	"x_sector": 3,
	"y_sector": 3,
	"z_sector": 3,
	"parsecs": 10,
	"system_chance": 15.0,
	"anomaly_chance": 1.0
}

func get_settings(key, default_value = null):
	return galaxy_settings.get(key, default_value)

func get_all_settings():
	return galaxy_settings

func set_value(key, value):
	galaxy_settings[key] = value

func set_galaxy_settings(new_settings):
	galaxy_settings = new_settings

# Debug function
func debug_print_settings():
	print("Galaxy Settings:")
	for key in galaxy_settings:
		print(key + ": " + str(galaxy_settings[key]))
