extends Node

# Constants for different planet types
const NOISE_OCTAVES = 4
const PERSISTENCE = 0.5

# Base colors for different planet types
const BASE_COLORS = {
	"Acheronian": [Color(0.5, 0.2, 0.1), Color(0.7, 0.3, 0.1)],
	"Arean": [Color(0.8, 0.4, 0.2), Color(0.6, 0.3, 0.1)],  
	"Rockball": [Color(0.6, 0.6, 0.6), Color(0.4, 0.4, 0.4)],
	"Hephaestian": [Color(0.9, 0.4, 0.1), Color(0.7, 0.2, 0.05), Color(1.0, 0.8, 0.0)],
	"Jovian": [Color(0.8, 0.7, 0.5), Color(0.6, 0.5, 0.4), Color(0.4, 0.3, 0.2), Color(0.9, 0.8, 0.6)]
}

# Noise settings for different planet types
const NOISE_SETTINGS = {
	"Acheronian": {"frequency": 4.0, "roughness": 0.7},
	"Arean": {"frequency": 3.0, "roughness": 0.5},
	"Rockball": {"frequency": 5.0, "roughness": 0.6},
	"Hephaestian": {"frequency": 6.0, "roughness": 0.8, "volcanoes": {
			"density": 0.02,    # Higher = more volcanoes
			"size": 0.1,        # Size of volcanic features
			"glow": 0.7         # Intensity of volcanic glow
			}
		},
	"Jovian": {
		"frequency": 2.0,
		"roughness": 0.3,
		"bands": {
			"count": 8,         # Number of bands
			"turbulence": 0.4,  # How wavy the bands are
			"contrast": 0.6     # Contrast between bands
		}
	}
}

func get_or_generate_texture(planet_class: String, seed_value: int) -> ImageTexture:
	var cache_path = "user://planet_textures/"
	var file_name = "%s_%d.res" % [planet_class, seed_value]
	var full_path = cache_path + file_name
	
	if FileAccess.file_exists(full_path):
		return load(full_path) as ImageTexture
	
	var texture = generate_texture(planet_class, seed_value)
	
	# Ensure directory exists
	if not DirAccess.dir_exists_absolute(cache_path):
		DirAccess.make_dir_absolute(cache_path)
	
	# Save texture
	ResourceSaver.save(texture, full_path)
	
	return texture

func generate_texture(planet_class: String, seed_value: int) -> ImageTexture:
	var noise = FastNoiseLite.new()
	noise.seed = seed_value
	
	var settings = NOISE_SETTINGS.get(planet_class, {"frequency": 4.0, "roughness": 0.5})
	noise.frequency = settings["frequency"]
	
	var image = Image.create(256, 256, false, Image.FORMAT_RGBA8)
	var colors = BASE_COLORS.get(planet_class, [Color(0.5, 0.5, 0.5), Color(0.3, 0.3, 0.3)])
	
	for x in range(256):
		for y in range(256):
			var noise_val = generate_combined_noise(noise, x, y)
			var color = colors[0].lerp(colors[1], noise_val)
			
			# Add features based on planet type
			match planet_class:
				"Acheronian":
					color = add_heat_distortion(color, noise_val)
				"Arean":
					color = add_dust_storms(color, noise, x, y)
				"Rockball":
					color = add_craters(color, noise, x, y)
				"Hephaestian":
					generate_hephaestian_texture(seed_value)
				"Jovian":
					generate_jovian_texture(seed_value)
				# ... add more planet-specific features
			
			image.set_pixel(x, y, color)
	
	return ImageTexture.create_from_image(image)

func generate_combined_noise(noise: FastNoiseLite, x: float, y: float) -> float:
	var value = 0.0
	var amplitude = 1.0
	var frequency = 1.0
	var max_value = 0.0
	
	for _i in range(NOISE_OCTAVES):
		value += amplitude * (noise.get_noise_2d(x * frequency, y * frequency) + 1) / 2.0
		max_value += amplitude
		amplitude *= PERSISTENCE
		frequency *= 2.0
	
	return value / max_value

func add_heat_distortion(color: Color, noise_val: float) -> Color:
	var heat = pow(noise_val, 2)
	return color.lerp(Color(1, 0.3, 0), heat * 0.3)

func add_dust_storms(color: Color, noise: FastNoiseLite, x: float, y: float) -> Color:
	var storm = noise.get_noise_2d(x * 8, y * 8)
	return color.lerp(Color(0.8, 0.6, 0.4), abs(storm) * 0.4)

func add_craters(color: Color, noise: FastNoiseLite, x: float, y: float) -> Color:
	var crater = noise.get_noise_2d(x * 12, y * 12)
	if crater > 0.7:
		return color.darkened(0.3)
	return color

func generate_hephaestian_texture(seed_value: int) -> ImageTexture:
	var noise = FastNoiseLite.new()
	noise.seed = seed_value
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	
	var settings = NOISE_SETTINGS["Hephaestian"]
	noise.frequency = settings["frequency"]
	
	var volcanic_noise = FastNoiseLite.new()
	volcanic_noise.seed = seed_value + 1000
	volcanic_noise.frequency = 8.0
	
	var image = Image.create(512, 256, false, Image.FORMAT_RGBA8)
	var colors = BASE_COLORS["Hephaestian"]
	
	for x in range(512):
		for y in range(256):
			var lat = (float(y) / 256.0) * PI - PI/2
			var lon = (float(x) / 512.0) * 2 * PI - PI
			
			var noise_val = generate_combined_noise(noise, x, y)
			var volcanic_activity = volcanic_noise.get_noise_2d(x, y)
			
			var base_color = colors[0].lerp(colors[1], noise_val)
			
			# Add volcanic features
			if volcanic_activity > 0.7:
				base_color = colors[2].lerp(Color(1, 0.5, 0), (volcanic_activity - 0.7) / 0.3)
				base_color = base_color.lightened((sin(Time.get_ticks_msec() * 0.005) + 1) * 0.1)  # Glow effect
			elif noise_val > 0.6:
				base_color = base_color.lerp(colors[3], (noise_val - 0.6) / 0.4)
			
			image.set_pixel(x, y, base_color)
	
	return ImageTexture.create_from_image(image)

func generate_jovian_texture(seed_value: int) -> ImageTexture:
	var noise = FastNoiseLite.new()
	noise.seed = seed_value
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	
	var settings = NOISE_SETTINGS["Jovian"]
	noise.frequency = settings["frequency"]
	
	var storm_noise = FastNoiseLite.new()
	storm_noise.seed = seed_value + 2000
	storm_noise.frequency = 3.0
	storm_noise.noise_type = FastNoiseLite.TYPE_CELLULAR
	
	var image = Image.create(512, 256, false, Image.FORMAT_RGBA8)
	var colors = BASE_COLORS["Jovian"]
	
	for x in range(512):
		for y in range(256):
			var lat = (float(y) / 256.0) * PI - PI/2
			var lon = (float(x) / 512.0) * 2 * PI - PI
			
			# Create bands
			var band_noise = sin(lat * 8) * 0.5 + 0.5
			var color_index = wrapi(int(band_noise * colors.size()), 0, colors.size())
			var base_color = colors[color_index]
			
			# Add turbulence
			var turbulence = noise.get_noise_2d(x, y) * 0.5 + 0.5
			base_color = base_color.lerp(colors[(color_index + 1) % colors.size()], turbulence * 0.3)
			
			# Add storms
			var storm_intensity = storm_noise.get_noise_2d(x, y)
			if storm_intensity > 0.8:
				var storm_color = Color(0.8, 0.3, 0.2)  # Great Red Spot color
				base_color = base_color.lerp(storm_color, (storm_intensity - 0.8) / 0.2)
			
			image.set_pixel(x, y, base_color)
	
	return ImageTexture.create_from_image(image)
