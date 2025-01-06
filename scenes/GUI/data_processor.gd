extends Node

func format_star_info(star_data: Dictionary) -> String:
	var _data = star_data.data
	var content = "Number of stars: %s\n" % [_data.size()]
	for star in _data:
		content += format_single_star(star)
	return content

func format_single_star(star: Dictionary) -> String:
	return "  StarID: %s\n    Type: %s\n    Temperature: %s K\n    Luminosity: %s L⊙\n    Mass: %s M⊙\n    Radius: %s R⊙\n    Planets: %s\n" % [
		str(star.get("StarId")),
		str(star.get("SpectralType") + to_roman(star.get("LuminosityClass")) + "f" if star.get("IsFlareStar") else ""),
		str(star.get("Temperature")),
		str(star.get("Luminosity")),
		str(star.get("Mass")),
		str(star.get("Radius")),
		str(star.get("CelestialBodies").size())
	]

func format_planet_info(planet_data: Dictionary) -> String:
	return "Type: %s\nMass: %s" % [
		planet_data.get("type", "Unknown"),
		planet_data.get("mass", "Unknown")
	]

func to_roman(number: int) -> String:
	var roman_numerals = {
		1: "I", 2: "II", 3: "III", 4: "IV", 5: "V",
		6: "VI", 7: "VII", 8: "VIII", 9: "IX", 10: "X"
	}
	return roman_numerals.get(number, str(number))
