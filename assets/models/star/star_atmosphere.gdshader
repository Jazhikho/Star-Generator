shader_type spatial;
render_mode blend_add, unshaded;

uniform vec3 star_color : source_color;
uniform float time;

void fragment() {
    float edge = 1.0 - smoothstep(0.4, 0.5, length(UV * 2.0 - 1.0));
    ALBEDO = star_color;
    ALPHA = edge * 0.5 * (sin(time + UV.x * 10.0) * 0.5 + 0.5);
}