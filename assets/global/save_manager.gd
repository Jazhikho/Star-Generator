extends Node

signal save_completed(slot)
signal load_completed(slot)
signal save_failed(error)
signal load_failed(error)

const SAVE_FILE = "user://game_saves.cfg"
const BACKUP_SAVE_FILE = "user://game_saves_backup.cfg"
const MAX_SLOTS = 10

var save_data: ConfigFile = ConfigFile.new()

func _ready():
	# Attempt to load existing saves
	var err = load_save_file()
	if err != OK:
		push_warning("Failed to load save file, attempting to load backup")
		err = load_save_file(BACKUP_SAVE_FILE)
		if err != OK:
			push_error("Failed to load both main and backup save files")

func load_save_file(file_path: String = SAVE_FILE) -> int:
	var err = save_data.load(file_path)
	if err == ERR_FILE_NOT_FOUND:
		# If the file doesn't exist, it's not an error, just create a new one
		return OK
	return err

func get_save_slots() -> Dictionary:
	var slots = {}
	for i in range(MAX_SLOTS):
		var slot_data = save_data.get_value("slots", str(i), {})
		slots[str(i)] = {
			"name": slot_data.get("name", "Empty Slot"),
			"date": slot_data.get("date", ""),
			"summary": slot_data.get("summary", "")
		}
	return slots

func save_game(slot: int, save_name: String) -> void:
	# Try to find the bridge in different possible locations
	var bridge = get_tree().get_root().find_child("CSBridge", true, false)
	if not bridge:
		emit_signal("save_failed", "Bridge not found")
		return
	
	# Get game data
	var galaxy_data = bridge.GetGalaxyDataForSaving()
	var systems_data = bridge.GetSystemsDataForSaving()
	
	print("galaxy_data size: ", galaxy_data.size())
	print("systems_data size: ", systems_data.size())
	
	# Store in GlobalData
	GlobalData.set_data(galaxy_data, systems_data)
	
	# Prepare metadata and save to file
	var metadata = {
		"name": save_name,
		"date": Time.get_datetime_string_from_system(),
		"summary": _generate_save_summary(bridge)
	}
	
	save_data.set_value("slots", str(slot), metadata)
	save_data.set_value("galaxy_data", str(slot), var_to_str(galaxy_data))
	save_data.set_value("systems_data", str(slot), var_to_str(systems_data))
	
	# Save to main file
	var err = save_data.save(SAVE_FILE)
	if err != OK:
		emit_signal("save_failed", "Failed to write main save file")
		return
	
	# Create backup
	err = save_data.save(BACKUP_SAVE_FILE)
	if err != OK:
		push_warning("Failed to create backup save file")
	
	emit_signal("save_completed", slot)

func load_game(slot: int) -> void:
	var loaded_data = {}
	
	GlobalData.clear_data()
	GlobalData.galaxy_data = loaded_data.get("galaxy_data", {})
	GlobalData.systems_data = loaded_data.get("systems_data", {})

	var galaxy_data_str = save_data.get_value("galaxy_data", str(slot), null)
	var systems_data_str = save_data.get_value("systems_data", str(slot), null)
	
	if galaxy_data_str == null or systems_data_str == null:
		emit_signal("load_failed", "Save data not found")
		return
	
	var galaxy_data = str_to_var(galaxy_data_str)
	var systems_data = str_to_var(systems_data_str)
	
	# Store in GlobalData
	GlobalData.set_data(galaxy_data, systems_data)
	
	print("Loaded galaxy data size: ", GlobalData.galaxy_data.size())
	print("Loaded systems data size: ", GlobalData.systems_data.size())
	
	emit_signal("load_completed", slot)

func _generate_save_summary(bridge) -> String:
	var system_count = bridge.GetSystemCount()
	return "Systems: %d" % system_count

func delete_save(slot: int) -> void:
	save_data.set_value("slots", str(slot), null)
	save_data.set_value("galaxy_data", str(slot), null)
	save_data.set_value("systems_data", str(slot), null)
	var err = save_data.save(SAVE_FILE)
	if err != OK:
		push_error("Failed to save after deleting slot")
	err = save_data.save(BACKUP_SAVE_FILE)
	if err != OK:
		push_warning("Failed to update backup after deleting slot")
