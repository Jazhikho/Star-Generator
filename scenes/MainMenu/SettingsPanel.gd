extends Control

@onready var x_sector_input = $MarginContainer/VBoxContainer/SectorsContainer/SectorInputs/XSectorsInput
@onready var y_sector_input = $MarginContainer/VBoxContainer/SectorsContainer/SectorInputs/YSectorsInput
@onready var z_sector_input = $MarginContainer/VBoxContainer/SectorsContainer/SectorInputs/ZSectorsInput
@onready var parsecs_input = $MarginContainer/VBoxContainer/ParsecsContainer/ParsecInputs/ParsecsInput
@onready var system_chance_input = $MarginContainer/VBoxContainer/SystemChanceContainer/SystemChanceInputs/SystemChanceInput
@onready var anomaly_chance_input = $MarginContainer/VBoxContainer/AnomalyChanceContainer/AnomalyChanceInputs/AnomalyChanceInput
@onready var confirm_button = $MarginContainer/VBoxContainer/ConfirmButton

func _ready():
	#confirm_button.connect("pressed", Callable(self, "_on_confirm_button_pressed"))
	pass

func _on_confirm_button_pressed():
	var settings = {
		"x_sector": x_sector_input.value,
		"y_sector": y_sector_input.value,
		"z_sector": z_sector_input.value,
		"parsecs": parsecs_input.value,
		"system_chance": system_chance_input.value,
		"anomaly_chance": anomaly_chance_input.value
	}
	visible = false
	GlobalSettings.set_galaxy_settings(settings)
