extends Control

signal new_game_requested
signal load_game_requested(slot_id: int)
signal save_game_requested(slot_id: int, save_name: String)
signal settings_changed(new_settings: Dictionary)
signal hide_main_menu_requested
signal generation_completed

@onready var settings_panel = $SettingsPanel
@onready var save_load_panel = $SaveLoadPanel
@onready var progress_window = $ProgressWindow
@onready var cs_bridge = $CSBridge

var galaxy_generator: Node
var generation_timer: Timer

func _ready():
	connect_signals()
	setup_generation_timer()

func connect_signals():
	$BackgroundPanel/MenuButtons/NewButton.pressed.connect(_on_new_button_pressed)
	$BackgroundPanel/MenuButtons/LoadButton.pressed.connect(_on_load_button_pressed)
	$BackgroundPanel/MenuButtons/SaveButton.pressed.connect(_on_save_button_pressed)
	$BackgroundPanel/MenuButtons/SettingsButton.pressed.connect(_on_settings_button_pressed)
	$BackgroundPanel/MenuButtons/CloseButton.pressed.connect(_on_close_button_pressed)
	settings_panel.settings_confirmed.connect(_on_settings_confirmed)
	save_load_panel.save_requested.connect(_on_save_requested)
	save_load_panel.load_requested.connect(_on_load_requested)
	progress_window.save_requested.connect(_on_progress_save_requested)
	progress_window.load_requested.connect(_on_progress_load_requested)
	SaveManager.save_completed.connect(_on_save_completed)
	SaveManager.load_completed.connect(_on_load_completed)
	SaveManager.save_failed.connect(_on_save_failed)
	SaveManager.load_failed.connect(_on_load_failed)
	SaveManager.connect("load_completed", _on_load_completed)

func setup_generation_timer():
	generation_timer = Timer.new()
	generation_timer.connect("timeout", Callable(self, "_check_generation_progress"))
	add_child(generation_timer)

func _on_new_button_pressed():
	if galaxy_generator:
		galaxy_generator.queue_free()
	
	galaxy_generator = cs_bridge
	
	progress_window.start_progress()
	progress_window.show()
	
	generate_galaxy()
	generation_timer.start(0.1)

func generate_galaxy():
	if is_instance_valid(galaxy_generator):
		galaxy_generator.CancelGeneration()
	
	var settings = GlobalSettings.get_all_settings()
	galaxy_generator.GenerateGalaxy(
		settings.x_sector,
		settings.y_sector,
		settings.z_sector,
		settings.parsecs,
		settings.system_chance,
		settings.anomaly_chance
	)

func _check_generation_progress():
	if is_instance_valid(galaxy_generator):
		if galaxy_generator.IsGenerating():
			var progress = galaxy_generator.GetCurrentProgress()
			var status = galaxy_generator.GetCurrentStatus()
			progress_window.update_progress(progress, status)
		elif galaxy_generator.IsCompleted():
			generation_timer.stop()
			_on_generation_completed()

func _on_generation_completed():
	progress_window.complete_progress()
	
	GlobalData.galaxy_data = galaxy_generator.GetGalaxyDataForSaving()
	GlobalData.systems_data = galaxy_generator.GetSystemsDataForSaving()
	
	emit_signal("generation_completed")

func _on_load_button_pressed():
	save_load_panel.show_panel(false) # false for load mode

func _on_save_button_pressed():
	save_load_panel.show_panel(true) # true for save mode

func _on_settings_button_pressed():
	settings_panel.show()

func _on_close_button_pressed():
	emit_signal("hide_main_menu_requested")

func _on_settings_confirmed(new_settings: Dictionary):
	GlobalSettings.set_galaxy_settings(new_settings)
	emit_signal("settings_changed", new_settings)

func _on_load_slot_selected(slot: int):
	SaveManager.load_game(slot)

func _on_progress_save_requested():
	save_load_panel.show_panel(true)

func _on_progress_load_requested():
	progress_window.hide()
	emit_signal("generation_completed")

func _on_save_requested(slot_id: int, save_name: String):
	print("Save requested for slot: ", slot_id)  # Debug print
	SaveManager.save_game(slot_id, save_name)

func _on_load_requested(slot_id: int):
	print("Load requested for slot: ", slot_id)  # Debug print
	SaveManager.load_game(slot_id)

# Handler functions for SaveManager signals
func _on_save_completed(slot: int):
	print("Save completed for slot: ", slot)
	# Handle successful save (e.g., show notification)

func _on_load_completed(slot: int, galaxy_data: Dictionary, systems_data: Dictionary):
	# Get the ViewManager from the scene tree
	var view_manager = get_node("/root/Main/VBoxContainer/SceneView/SubViewport/ViewManager")
	if view_manager:
		view_manager.initialize_from_loaded_data(galaxy_data, systems_data)
		hide() # Hide the main menu
	else:
		print("ViewManager not found")
	
	# Clean up the signal connection
	SaveManager.load_completed.disconnect(_on_load_completed)
	emit_signal("hide_main_menu_requested")

func _on_save_failed(error: String):
	print("Save failed: ", error)
	# Handle save failure (e.g., show error message)

func _on_load_failed(error: String):
	print("Load failed: ", error)
	# Handle load failure (e.g., show error message)

func _exit_tree():
	if is_instance_valid(galaxy_generator):
		galaxy_generator.CancelGeneration()
	if generation_timer:
		generation_timer.stop()
