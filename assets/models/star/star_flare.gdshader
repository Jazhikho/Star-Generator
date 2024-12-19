shader_type spatial;

uniform vec3 star_color : source_color;
uniform float intensity = 2.0;

void fragment() {
    // Flare effect
    ALBEDO = star_color;
    EMISSION = star_color * intensity;
}