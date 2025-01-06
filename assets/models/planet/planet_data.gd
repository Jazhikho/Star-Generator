extends Node

# Planet Data Handler
# Manages planet data, textures, and visual properties

# Texture paths for different planet classes
const TEXTURE_PATHS = {
	"Acheronian": "res://assets/textures/planets/acheronian/",
	"Arean": "res://assets/textures/planets/arean/",
	"Arid": "res://assets/textures/planets/arid/",
	"Asphodelian": "res://assets/textures/planets/asphodelian/",
	"Chthonian": "res://assets/textures/planets/chthonian/",
	"Hebean": "res://assets/textures/planets/hebean/",
	"Helian": "res://assets/textures/planets/helian/",
	"JaniLithic": "res://assets/textures/planets/janilithic/",
	"Jovian": "res://assets/textures/planets/jovian/",
	"Hephaestian": "res://assets/textures/planets/hephaestian/",
	"Oceanic": "res://assets/textures/planets/oceanic/",
	"Panthalassic": "res://assets/textures/planets/panthalassic/",
	"Promethean": "res://assets/textures/planets/promethean/",
	"Rockball": "res://assets/textures/planets/rockball/",
	"Snowball": "res://assets/textures/planets/snowball/",
	"Stygian": "res://assets/textures/planets/stygian/",
	"Tectonic": "res://assets/textures/planets/tectonic/",
	"Telluric": "res://assets/textures/planets/telluric/",
	"Vesperian": "res://assets/textures/planets/vesperian/"
}

# Fallback colors for when textures aren't available
const FALLBACK_COLORS = {
	"Acheronian": Color(0.5, 0.4, 0.3),    # Scorched brown
	"Arean": Color(0.8, 0.4, 0.2),         # Mars-like red-orange
	"Arid": Color(0.9, 0.8, 0.6),          # Sandy yellow
	"Asphodelian": Color(0.3, 0.3, 0.3),   # Dark gray
	"Chthonian": Color(0.2, 0.2, 0.3),     # Deep blue-gray
	"Hebean": Color(0.6, 0.5, 0.4),        # Light brown
	"Helian": Color(0.7, 0.8, 0.9),        # Pale blue
	"JaniLithic": Color(0.4, 0.4, 0.4),    # Medium gray
	"Jovian": Color(0.8, 0.7, 0.6),        # Light tan (Jupiter-like)
	"Hephaestian": Color(0.8, 0.2, 0.1),   # Bright red/orange
	"Oceanic": Color(0.2, 0.3, 0.8),       # Deep blue
	"Panthalassic": Color(0.1, 0.4, 0.9),  # Bright blue
	"Promethean": Color(0.7, 0.7, 0.8),    # Light gray
	"Rockball": Color(0.5, 0.5, 0.5),      # Medium gray
	"Snowball": Color(0.9, 0.9, 1.0),      # Near white
	"Stygian": Color(0.2, 0.2, 0.2),       # Very dark gray
	"Tectonic": Color(0.3, 0.5, 0.7),      # Earth-like blue
	"Telluric": Color(0.6, 0.7, 0.5),      # Pale green
	"Vesperian": Color(0.4, 0.6, 0.8)      # Sky blue
}

# Cached textures
var texture_cache := {}

func get_texture(planet_class: String) -> Texture:
	# Check cache first
	if texture_cache.has(planet_class):
		return texture_cache[planet_class]
	
	# Try to load a texture
	var texture = load_random_texture(planet_class)
	if texture:
		texture_cache[planet_class] = texture
	return texture

func load_random_texture(planet_class: String) -> Texture:
	var base_path = TEXTURE_PATHS.get(planet_class, "")
	if base_path.is_empty():
		return null
	
	var dir = DirAccess.open(base_path)
	if not dir:
		return null
	
	var texture_files = []
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while not file_name.is_empty():
		if not dir.current_is_dir() and file_name.ends_with(".png"):
			texture_files.append(file_name)
		file_name = dir.get_next()
	
	if texture_files.is_empty():
		return null
	
	var random_texture = texture_files[randi() % texture_files.size()]
	return load(base_path + random_texture)

func get_fallback_color(planet_class: String) -> Color:
	return FALLBACK_COLORS.get(planet_class, Color(0.5, 0.5, 0.5))

# Data processing functions
func calculate_day_length(data: Dictionary) -> float:
	return data.get("DayLength", data.get("RotationalPeriod", 24.0))

func get_atmosphere_density(data: Dictionary) -> int:
	return data.get("Atmosphere", 0)
