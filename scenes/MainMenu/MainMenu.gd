extends Control

@onready var file_dialog = $FileDialog
@onready var new_button = $MenuButtons/NewButton
@onready var settings_button = $MenuButtons/SettingsButton
@onready var load_button = $MenuButtons/LoadButton
@onready var edit_button = $MenuButtons/EditButton
@onready var save_button = $MenuButtons/SaveButton

@onready var progress_window_scene = preload("res://scenes/MainMenu/progress_window.tscn")
var progress_window: Window

@onready var x_sector_input = $SettingsPanel/MarginContainer/VBoxContainer/SectorsContainer/SectorInputs/XSectorsInput
@onready var y_sector_input = $SettingsPanel/MarginContainer/VBoxContainer/SectorsContainer/SectorInputs/YSectorsInput
@onready var z_sector_input = $SettingsPanel/MarginContainer/VBoxContainer/SectorsContainer/SectorInputs/ZSectorsInput
@onready var parsecs_input = $SettingsPanel/MarginContainer/VBoxContainer/ParsecsContainer/ParsecInputs/ParsecsInput
@onready var system_chance_input = $SettingsPanel/MarginContainer/VBoxContainer/SystemChanceContainer/SystemChanceInputs/SystemChanceInput
@onready var anomaly_chance_input = $SettingsPanel/MarginContainer/VBoxContainer/AnomalyChanceContainer/AnomalyChanceInputs/AnomalyChanceInput
@onready var settings_panel = $SettingsPanel
@onready var save_load_panel = $SaveLoadPanel

var galaxy_generator: Node
var generation_timer: Timer
var bridge: Node
var view_manager: Node3D

func _ready():
	settings_panel.visible = false
	save_load_panel.visible = false
	save_load_panel.connect("save_requested", Callable(self, "_on_save_slot_selected"))
	save_load_panel.connect("load_requested", Callable(self, "_on_load_slot_selected"))
	SaveManager.connect("save_completed", _on_save_completed)
	SaveManager.connect("load_completed", _on_load_completed)
	SaveManager.connect("save_failed", _on_save_failed)
	SaveManager.connect("load_failed", _on_load_failed)
	
	generation_timer = Timer.new()
	generation_timer.connect("timeout", Callable(self, "_check_generation_progress"))
	add_child(generation_timer)
	
	bridge = preload("res://assets/generators/CSBridge.cs").new()
	bridge.name = "CSBridge"
	add_child(bridge)
	
	mouse_filter = Control.MOUSE_FILTER_STOP
	$MenuButtons.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Make sure all buttons can receive input
	for button in $MenuButtons.get_children():
		if button is Button:
			button.mouse_filter = Control.MOUSE_FILTER_STOP
			
	# Get reference to ViewManager
	view_manager = get_node("/root/Main/VBoxContainer/SceneView/SubViewport/ViewManager")
	if !view_manager:
		push_error("ViewManager not found!")

func _on_save_completed(slot):
	print("Save completed in slot ", slot)
	hide_main_menu()

func _on_load_completed(slot):
	print("Load completed from slot ", slot)
	hide_main_menu()
	if view_manager:
		view_manager.setup_galaxy_view()
	else:
		push_error("ViewManager not found when trying to setup galaxy view!")

func _on_save_failed(error):
	print("Save failed: ", error)

func _on_load_failed(error):
	print("Load failed: ", error)

func _on_new_button_pressed():
	if galaxy_generator:
		galaxy_generator.queue_free()
	
	galaxy_generator = bridge
	
	# Create progress window
	progress_window = progress_window_scene.instantiate()
	add_child(progress_window)
	progress_window.connect("save_requested", _on_progress_save_requested)
	progress_window.connect("load_requested", _on_progress_load_requested)
	progress_window.start_progress()
	
	generate_galaxy()
	generation_timer.start(0.1)

func generate_galaxy():
	if is_instance_valid(galaxy_generator):
		galaxy_generator.CancelGeneration()
		galaxy_generator = null
	
	galaxy_generator = $CSBridge
	if not galaxy_generator:
		galaxy_generator = find_child("CSBridge", true, false)
	
	if not galaxy_generator:
		push_error("Error: CSBridge not found")
		return
	
	var settings = GlobalSettings.galaxy_settings
	var x = settings.get("x_sector", 3)
	var y = settings.get("y_sector", 3)
	var z = settings.get("z_sector", 3)
	var parsecs = settings.get("parsecs", 10)
	var system_chance = settings.get("system_chance", 15.0)
	var anomaly_chance = settings.get("anomaly_chance", 1.0)
	galaxy_generator.GenerateGalaxy(x, y, z, parsecs, system_chance, anomaly_chance)

func _check_generation_progress():
	if is_instance_valid(galaxy_generator):
		if galaxy_generator.IsGenerating():
			var progress = galaxy_generator.GetCurrentProgress()
			var status = galaxy_generator.GetCurrentStatus()
			update_progress_window(progress, status)
		elif galaxy_generator.IsCompleted():
			generation_timer.stop()
			_on_generation_completed()

func update_progress_window(progress: float, status: String):
	if is_instance_valid(progress_window):
		progress_window.update_progress(progress, status)

func _on_generation_completed():
	if is_instance_valid(progress_window):
		progress_window.complete_progress()
	
	GlobalData.galaxy_data = galaxy_generator.GetGalaxyDataForSaving()
	GlobalData.systems_data = galaxy_generator.GetSystemsDataForSaving()
	
	if view_manager:
		view_manager.setup_galaxy_view()
	else:
		push_error("ViewManager not found when trying to setup galaxy view!")

func _on_progress_save_requested():
	open_save_slot_panel()

func _on_progress_load_requested():
	if progress_window:
		progress_window.queue_free()
	hide_main_menu()
	if view_manager:
		view_manager.setup_galaxy_view()

func _on_settings_button_pressed():
	open_settings_panel()

func _on_edit_button_pressed():
	# TODO: Implement edit functionality
	pass

func _on_save_button_pressed():
	open_save_slot_panel()

func _on_load_button_pressed():
	open_load_slot_panel()

func hide_main_menu():
	var main = get_node("/root/Main")
	if main:
		main.hide_main_menu()

func open_settings_panel():
	settings_panel.visible = true

func close_settings_panel():
	settings_panel.visible = false

func save_settings():
	GlobalSettings.set("x_sector", int(x_sector_input.value))
	GlobalSettings.set("y_sector", int(y_sector_input.value))
	GlobalSettings.set("z_sector", int(z_sector_input.value))
	GlobalSettings.set("parsecs", int(parsecs_input.value))
	GlobalSettings.set("system_chance", float(system_chance_input.value))
	GlobalSettings.set("anomaly_chance", float(anomaly_chance_input.value))
	return true

func open_save_slot_panel():
	save_load_panel.show_panel(true)

func open_load_slot_panel():
	save_load_panel.show_panel(false)

func _on_save_slot_selected(slot: int, name: String):
	if bridge and bridge.GetSystemCount() > 0:
		SaveManager.save_game(slot, name)
	else:
		print("No data to save!")

func _on_load_slot_selected(slot: int):
	SaveManager.load_game(slot)

func _exit_tree():
	if is_instance_valid(galaxy_generator):
		galaxy_generator.CancelGeneration()
		galaxy_generator = null
	if generation_timer:
		generation_timer.stop()
		generation_timer = null
