extends Node3D

var horizontal_speed

# Star color classes with approximate real distribution weights
const STAR_COLORS = {
	"O": { "color": Color(0.6, 0.8, 1.0), "weight": 0.001 },    # Blue
	"B": { "color": Color(0.75, 0.85, 1.0), "weight": 0.13 },   # Blue-white
	"A": { "color": Color(1.0, 1.0, 1.0), "weight": 0.6 },      # White
	"F": { "color": Color(1.0, 1.0, 0.8), "weight": 3.0 },      # Yellow-white
	"G": { "color": Color(1.0, 1.0, 0.0), "weight": 7.6 },      # Yellow
	"K": { "color": Color(1.0, 0.6, 0.0), "weight": 12.1 },     # Orange
	"M": { "color": Color(1.0, 0.2, 0.0), "weight": 76.45 }     # Red
}

func _ready():
	# If init wasn't called, set some default values
	if horizontal_speed == null:
		horizontal_speed = randf_range(2.0, 5.0)
		apply_random_color()

func init(x: float, y: float, z: float, size: float) -> void:
	position = Vector3(x, y, z)
	scale = Vector3(size, size, size)
	horizontal_speed = randf_range(2.0, 5.0)
	apply_random_color()

func apply_random_color() -> void:
	var mesh_instance = get_node_or_null("MeshInstance3D")
	if mesh_instance:
		var material = StandardMaterial3D.new()
		material.emission_enabled = true
		material.emission = get_random_star_color()
		material.emission_energy = 2.0
		mesh_instance.material_override = material

func get_random_star_color() -> Color:
	var total_weight = 0.0
	for star_class in STAR_COLORS.values():
		total_weight += star_class.weight
	
	var random_value = randf() * total_weight
	var current_weight = 0.0
	
	for star_class in STAR_COLORS.values():
		current_weight += star_class.weight
		if random_value <= current_weight:
			return star_class.color
	
	return STAR_COLORS["G"].color  # Default to G class (yellow) if something goes wrong

func _process(delta: float) -> void:
	position.x -= horizontal_speed * delta
	
	# Remove if off screen
	if position.x < -20:  # Adjust based on boundary
		queue_free()
