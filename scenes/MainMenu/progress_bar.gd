extends Window

signal save_requested
signal load_requested

@onready var progress_bar = $ProgressBar
@onready var status_label = $StatusLabel
@onready var save_button = $ButtonContainer/SaveButton
@onready var load_button = $ButtonContainer/LoadButton

func _ready():
	save_button.disabled = true
	load_button.disabled = true
	close_requested.connect(_on_close_requested)
	
func _on_generation_progress(progress: float, status: String):
	# Force process the progress update
	progress_bar.value = progress
	status_label.text = status
	# Force a redraw
	progress_bar.queue_redraw()
	status_label.queue_redraw()
	# Allow the UI to update
	await get_tree().process_frame
	
func _on_generation_completed():
	status_label.text = "Generation completed!"
	save_button.disabled = false
	load_button.disabled = false

func start_progress():
	visible = true
	progress_bar.value = 0
	status_label.text = "Starting generation..."
	save_button.disabled = true
	load_button.disabled = true
	await get_tree().process_frame

func update_progress(progress: float, status: String):
	progress_bar.value = progress
	status_label.text = status
	# Force a redraw
	progress_bar.queue_redraw()
	status_label.queue_redraw()
	await get_tree().process_frame

func complete_progress():
	status_label.text = "Generation completed!"
	save_button.disabled = false
	load_button.disabled = false

func _on_save_button_pressed():
	emit_signal("save_requested")

func _on_load_button_pressed():
	emit_signal("load_requested")

func _on_close_requested():
	var bridge = get_tree().get_root().get_node_or_null("MainMenu/CSBridge")
	if is_instance_valid(bridge):
		bridge.CancelGeneration()
	# Notify parent that window is closing
	get_parent().progress_window = null
	queue_free()
