extends PanelContainer

signal settings_confirmed(new_settings: Dictionary)

@onready var x_sector_input = $VBoxContainer/GridContainer/XSectorInput
@onready var y_sector_input = $VBoxContainer/GridContainer/YSectorInput
@onready var z_sector_input = $VBoxContainer/GridContainer/ZSectorInput
@onready var parsecs_input = $VBoxContainer/GridContainer/ParsecsInput
@onready var system_chance_input = $VBoxContainer/GridContainer/SystemChanceInput
@onready var anomaly_chance_input = $VBoxContainer/GridContainer/AnomalyChanceInput

func _ready():
	load_current_settings()

func load_current_settings():
	var settings = GlobalSettings.get_all_settings()
	x_sector_input.value = settings.x_sector
	y_sector_input.value = settings.y_sector
	z_sector_input.value = settings.z_sector
	parsecs_input.value = settings.parsecs
	system_chance_input.value = settings.system_chance
	anomaly_chance_input.value = settings.anomaly_chance

func _on_confirm_button_pressed():
	var new_settings = {
		"x_sector": x_sector_input.value,
		"y_sector": y_sector_input.value,
		"z_sector": z_sector_input.value,
		"parsecs": parsecs_input.value,
		"system_chance": system_chance_input.value,
		"anomaly_chance": anomaly_chance_input.value
	}
	emit_signal("settings_confirmed", new_settings)
	hide()
