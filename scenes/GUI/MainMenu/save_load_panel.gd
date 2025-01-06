extends PanelContainer

signal save_requested(slot_id: int, save_name: String)
signal load_requested(slot_id: int)

@onready var slot_list = $VBoxContainer/SlotList
@onready var save_button = $VBoxContainer/HBoxContainer/SaveButton
@onready var load_button = $VBoxContainer/HBoxContainer/LoadButton

var is_save_mode: bool = true

func _ready():
	update_slot_list()

func show_panel(save_mode: bool):
	is_save_mode = save_mode
	save_button.visible = save_mode
	load_button.visible = !save_mode
	update_slot_list()
	show()

func update_slot_list():
	slot_list.clear()
	var saves = SaveManager.get_save_slots()  # Changed from get_save_list to get_save_slots
	for slot_id in saves.keys():
		var save = saves[slot_id]
		var text = "Slot %s: %s" % [slot_id, save.name]
		if save.date != "":
			text += " (%s)" % save.date
		slot_list.add_item(text)

func _on_save_button_pressed():
	var selected_items = slot_list.get_selected_items()
	if selected_items.size() > 0:
		var slot_id = selected_items[0]
		var save_name = "Save " + str(slot_id + 1)
		emit_signal("save_requested", slot_id, save_name)
		print("Emitting save_requested for slot: ", slot_id)  # Debug print
	hide()

func _on_load_button_pressed():
	var selected_items = slot_list.get_selected_items()
	if selected_items.size() > 0:
		var slot_id = selected_items[0]
		emit_signal("load_requested", slot_id)
		print("Emitting load_requested for slot: ", slot_id)  # Debug print
	hide()

func _on_cancel_button_pressed():
	hide()
