extends Control

signal save_requested(slot_index, slot_name)
signal load_requested(slot_index)

@onready var title_label = $DialogeWindow/VBoxContainer/Title
@onready var slot_container = $DialogeWindow/VBoxContainer/ScrollContainer/SlotContainer
@onready var name_input = $DialogeWindow/VBoxContainer/VBoxContainer/InputContainer/NameInput
@onready var save_button = $DialogeWindow/VBoxContainer/VBoxContainer/InputContainer/SaveButton
@onready var load_button = $DialogeWindow/VBoxContainer/VBoxContainer/HBoxContainer/LoadButton
@onready var input_container = $DialogeWindow/VBoxContainer/VBoxContainer/HBoxContainer/CancelButton

var mode = "save"
var selected_slot = -1

func _ready():
	hide()

func show_panel(save_mode: bool):
	mode = "save" if save_mode else "load"
	title_label.text = "Save Game" if mode == "save" else "Load Game"
	name_input.get_parent().visible = mode == "save"
	save_button.visible = mode == "save"
	load_button.visible = mode == "load"
	save_button.disabled = true
	load_button.disabled = true
	selected_slot = -1
	update_slots()
	show()

func update_slots():
	for child in slot_container.get_children():
		child.queue_free()
	
	var slots = SaveManager.get_save_slots()
	for i in range(SaveManager.MAX_SLOTS):
		var slot_data = slots.get(str(i), {})
		var button = Button.new()
		
		var slot_text = "Slot %d: " % (i + 1)
		if slot_data.get("name", "").is_empty():
			slot_text += "Empty"
		else:
			slot_text += slot_data["name"]
			if slot_data.has("date"):
				slot_text += " (%s)" % slot_data["date"]
		
		button.text = slot_text
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.connect("pressed", Callable(self, "_on_slot_pressed").bind(i))
		slot_container.add_child(button)

func _on_slot_pressed(slot_index):
	selected_slot = slot_index
	var slots = SaveManager.get_save_slots()
	var slot_data = slots.get(str(slot_index), {})
	
	if mode == "save":
		name_input.text = slot_data.get("name", "Save %d" % (slot_index + 1))
		save_button.disabled = false
	else:
		load_button.disabled = slot_data.get("name", "").is_empty()

func _on_save_button_pressed():
	if selected_slot != -1:
		emit_signal("save_requested", selected_slot, name_input.text)
		hide()

func _on_load_button_pressed():
	if selected_slot != -1:
		emit_signal("load_requested", selected_slot)
		#hide()

func _on_cancel_button_pressed():
	hide()

func _on_name_input_text_changed(new_text):
	save_button.disabled = new_text.strip_edges().is_empty()
