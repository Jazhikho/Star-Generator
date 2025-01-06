extends Node

# Autoload singleton for processing orbital motions in the system
# Handles the calculation and updating of orbital positions for all bodies

# Constants
const PREDICTION_STEPS := 10                 # Number of positions to predict ahead
const MAX_THREADS := 4                       # Maximum number of concurrent calculation threads

# Thread pool management
var thread_pool: Array[Thread] = []          # Pool of calculation threads
var orbital_queue: Array[int] = []           # Queue of orbits waiting for calculation
var active_calculations: Dictionary = {}     # Tracks which orbits are being calculated

# Orbital data storage and timing
var orbital_data: Dictionary = {}            # Stores parameters for each orbit
var system_time: float = 0.0                 # Master time tracker for synchronization
var time_scale: float = 1.0                  # Time multiplier for simulation speed

func _ready():
	process_mode = Node.PROCESS_MODE_PAUSABLE
	
	# Initialize thread pool
	for i in range(MAX_THREADS):
		thread_pool.append(Thread.new())

func _process(delta: float) -> void:
	system_time += delta * time_scale        # Update global system time
	
	# Update all active orbits
	for orbit_id in orbital_data.keys():
		update_orbit(orbit_id)

func update_orbit(orbit_id: int) -> void:
	var data = orbital_data[orbit_id]
	if data.predicted_positions.is_empty():
		return
	
	# Validate orbiting body still exists
	var orbiting_body = instance_from_id(orbit_id)
	if !is_instance_valid(orbiting_body):
		cleanup_orbit(orbit_id)
		return
	
	# Calculate orbit progress based on system time
	var elapsed_time = system_time - data.last_update_time
	var orbit_progress = fmod(elapsed_time, data.orbital_period) / data.orbital_period
	
	# Get current position in orbit
	var angle = data.start_angle + (orbit_progress * TAU)
	var position = calculate_position(data, angle)
	
	# Update body positions
	update_body_positions(orbit_id, position)
	
	# Queue new predictions if needed
	if elapsed_time > data.orbital_period:
		data.last_update_time += data.orbital_period
		if !active_calculations.has(orbit_id) and orbit_id not in orbital_queue:
			orbital_queue.push_back(orbit_id)
			process_calculation_queue()

func calculate_position(data: Dictionary, angle: float) -> Vector3:
	var denominator = (1 + data.eccentricity * cos(angle))
	if abs(denominator) < 0.000001:  # Prevent division by near-zero
		push_error("Near-zero denominator in orbit calculation")
		return Vector3.ZERO
		
	var orbit_radius = data.separation * (1 - data.eccentricity * data.eccentricity) / denominator
	if !is_finite(orbit_radius):
		push_error("Non-finite orbit radius calculated")
		return Vector3.ZERO
		
	return Vector3(orbit_radius * cos(angle), 0, orbit_radius * sin(angle))

func update_body_positions(orbit_id: int, relative_position: Vector3) -> void:
	var data = orbital_data[orbit_id]
	var orbiting_body = instance_from_id(orbit_id)
	
	if !is_instance_valid(orbiting_body) or !is_instance_valid(data.primary_body):
		cleanup_orbit(orbit_id)
		return
		
	# Update positions relative to barycenter
	var barycenter = data.primary_body.get_parent().global_position
	
	var primary_offset = relative_position * data.mass_ratio
	var secondary_offset = relative_position * (1.0 - data.mass_ratio)
	
	if !primary_offset.is_finite() or !secondary_offset.is_finite():
		push_error("Non-finite offset calculated")
		return
		
	data.primary_body.global_position = barycenter - primary_offset
	orbiting_body.global_position = barycenter + secondary_offset

func process_calculation_queue() -> void:
	while !orbital_queue.is_empty():
		var available_thread = get_available_thread()
		if available_thread == -1:
			break  # No threads available
		
		var orbit_id = orbital_queue.pop_front()
		active_calculations[orbit_id] = available_thread
		thread_pool[available_thread].start(Callable(self, "_thread_calculate_positions").bind(orbit_id, available_thread))

func get_available_thread() -> int:
	for i in range(MAX_THREADS):
		if !thread_pool[i].is_started():
			return i
	return -1

func _thread_calculate_positions(orbit_id: int, thread_index: int) -> void:
	if !orbital_data.has(orbit_id):
		return
	
	var data = orbital_data[orbit_id]
	var new_predictions: Array[Vector3] = []
	var next_angle = data.current_angle
	
	for i in range(PREDICTION_STEPS):
		var position = calculate_position(data, next_angle)
		new_predictions.append(position)
		next_angle += TAU / PREDICTION_STEPS
	
	call_deferred("_update_predictions", orbit_id, new_predictions, next_angle, thread_index)

func _update_predictions(orbit_id: int, new_predictions: Array[Vector3], new_angle: float, thread_index: int) -> void:
	if !orbital_data.has(orbit_id):
		return
	
	orbital_data[orbit_id].predicted_positions = new_predictions
	orbital_data[orbit_id].current_angle = new_angle
	active_calculations.erase(orbit_id)
	
	process_calculation_queue()  # Check if more calculations can be started

func cleanup_orbit(orbit_id: int) -> void:
	if active_calculations.has(orbit_id):
		var thread_index = active_calculations[orbit_id]
		if thread_pool[thread_index].is_started():
			thread_pool[thread_index].wait_to_finish()
		active_calculations.erase(orbit_id)
	
	orbital_queue.erase(orbit_id)
	orbital_data.erase(orbit_id)

func _exit_tree():
	for thread in thread_pool:
		if thread.is_started():
			thread.wait_to_finish()

# Public interface for the OrbitSetup script
func register_orbit(orbit_id: int, primary_body: Node, separation: float, eccentricity: float, 
		orbital_period: float, mass_ratio: float) -> void:
	# Validate parameters
	if !is_instance_valid(primary_body) or !is_finite(separation) or \
	   !is_finite(eccentricity) or !is_finite(orbital_period) or \
	   !is_finite(mass_ratio):
		push_error("Invalid orbital parameters")
		return
		
	orbital_data[orbit_id] = {
		"primary_body": primary_body,
		"separation": separation,
		"eccentricity": eccentricity,
		"predicted_positions": [],
		"start_angle": 0.0,
		"current_angle": 0.0,
		"orbital_period": orbital_period,
		"mass_ratio": mass_ratio,
		"last_update_time": system_time
	}
	
	print("Registered orbit: ", orbital_data[orbit_id])  # Debug output
	
	orbital_queue.push_back(orbit_id)
	process_calculation_queue()

func is_finite(value: float) -> bool:
	return !is_inf(value) and !is_nan(value)
