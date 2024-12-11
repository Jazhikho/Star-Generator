extends Control

@onready var file_dialog = $FileDialog
@onready var new_button = $MenuButtons/NewButton
@onready var settings_buttion = $MenuButtons/SettingsButton
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

var thread: Thread
var galaxy_generator


func _ready():
    settings_panel.visible = false
    
func _on_load_button_pressed():
    file_dialog.mode = FileDialog.FILE_MODE_OPEN_FILE
    file_dialog.access = FileDialog.ACCESS_USERDATA
    file_dialog.popup_centered()
    file_dialog.title = "Load Universe Data"
    file_dialog.filters = ["*.save", "*.json", "*.txt"]

func _on_new_button_pressed():
    if thread and thread.is_started():
        thread.wait_to_finish()
    
    # Create progress window
    progress_window = progress_window_scene.instantiate()
    add_child(progress_window)
    progress_window.start_progress()
    
    # Create galaxy generator
    galaxy_generator = preload("res://assets/generators/CSBridge.cs").new()
    galaxy_generator.connect("generation_progress", Callable(self, "update_progress_window"))
    galaxy_generator.connect("generation_completed", Callable(self, "_on_generation_completed"))
    add_child(galaxy_generator)
    
    generate_galaxy()

func generate_galaxy():
    var settings = GlobalSettings.galaxy_settings
    var x = settings.get("x_sector", 3)
    var y = settings.get("y_sector", 3)
    var z = settings.get("z_sector", 3)
    var parsecs = settings.get("parsecs", 10)
    var system_chance = settings.get("system_chance", 15.0)
    var anomaly_chance = settings.get("anomaly_chance", 1.0)
    galaxy_generator.GenerateGalaxy(x, y, z, parsecs, system_chance, anomaly_chance)
    
func update_progress_window(progress: float, status: String):
    if progress_window:
        progress_window.update_progress(progress, status)

func _on_generation_completed():
    if progress_window:
        progress_window.complete_progress()

func _on_progress_save_requested():
    file_dialog.mode = FileDialog.FILE_MODE_SAVE_FILE
    file_dialog.access = FileDialog.ACCESS_USERDATA
    file_dialog.popup_centered()
    file_dialog.title = "Save Universe Data"
    file_dialog.filters = ["*.save", "*.json", "*.txt"]

func _on_progress_load_requested():
    if progress_window:
        progress_window.queue_free()
    var galaxy_view_scene = load("res://GalaxyView/galaxy_view.tscn")
    if galaxy_view_scene:
        var result = get_tree().change_scene_to_packed(galaxy_view_scene)
        if result != OK:
            print("Failed to change scene: ", result)
    else:
        print("Failed to load galaxy view scene")

func _on_settings_button_pressed():
    open_settings_panel()
        
func _on_edit_button_pressed():
    # TODO: Implement edit functionality
    pass

#func _on_save_button_pressed():
    #file_dialog.mode = FileDialog.FILE_MODE_SAVE_FILE
    #file_dialog.access = FileDialog.ACCESS_USERDATA
    #file_dialog.popup_centered()
    #file_dialog.title = "Save Universe Data"
    #file_dialog.filters = ["*.save", "*.json", "*.txt"]
    #var data_to_save = GlobalData.galaxy_data
#
#func _on_file_selected(path: String):
    #if file_dialog.mode == FileDialog.FILE_MODE_OPEN_FILE:
        #var loaded_data = load_universe_data(path)
        #if loaded_data:
            #GlobalData.galaxy_data = loaded_data
            #print("Universe loaded successfully")
            ## TODO: Update UI to reflect loaded data
        #else:
            #print("Failed to load universe data")
            ## TODO: Show error message in UI
    #elif file_dialog.mode == FileDialog.FILE_MODE_SAVE_FILE:
        #var data_to_save = GlobalData.galaxy_data
        #if save_universe_data(path, data_to_save):
            #print("Universe saved successfully")
            #progress_window.visible = false
            ## TODO: Show success message in UI
        #else:
            #print("Failed to save universe data")
            ## TODO: Show error message in UI
            
func load_universe_data(path: String):
    var file = FileAccess.open(path, FileAccess.READ)
    if file:
        var json = JSON.new()
        var error = json.parse(file.get_as_text())
        if error == OK:
            return json.data
    return null

func save_universe_data(path: String, data) -> bool:
    var file = FileAccess.open(path, FileAccess.WRITE)
    if file:
        var json_string = JSON.stringify(data)
        file.store_string(json_string)
        file.close()
        return true
    return false

func open_settings_panel():
    settings_panel.visible = true

func close_settings_panel():
    settings_panel.visible = false

func save_settings():
    if validate_inputs():
        GlobalSettings.set("x_sector", int(x_sector_input.value))
        GlobalSettings.set("y_sector", int(y_sector_input.value))
        GlobalSettings.set("z_sector", int(z_sector_input.value))
        GlobalSettings.set("parsecs", int(parsecs_input.value))
        GlobalSettings.set("system_chance", float(system_chance_input.value))
        GlobalSettings.set("anomaly_chance", float(anomaly_chance_input.value))
        return true
    return false

func validate_inputs():
    # TODO: Implement input validation
    return true
