shader_type spatial;
render_mode blend_add, depth_draw_never, cull_back, unshaded;

uniform sampler2D texture_emission : hint_default_black;
uniform float emission_energy = 500000.0; //star bightness
uniform float size_multiplier = 1.0; //size of star
uniform float luminosity_cap = 1e30;
uniform float color_gamma : hint_range(0.0, 10.0) = 3.0; // color intensity
uniform float min_size_ratio : hint_range(0, 1.0) = 0.003;
uniform float max_luminosity = 1e6; //max lum
uniform float scaling_gamma : hint_range(0.0, 2.0) = 0.5; //Size scaling w/ luminosity

varying vec3 STAR_COLOR;

void vertex() {
    // Get star properties
    float luminosity = min(INSTANCE_CUSTOM.r * emission_energy, luminosity_cap);
    STAR_COLOR = pow(COLOR.rgb, vec3(color_gamma)) * luminosity;

    // Calculate star size
    float scale_ratio = clamp(luminosity / max_luminosity, 0.0, 1.0);
    scale_ratio = pow(scale_ratio, scaling_gamma);
    scale_ratio = mix(min_size_ratio, 1.0, scale_ratio);
    float size = scale_ratio * size_multiplier;

    // Apply size to UV for PSF cropping
    UV = (UV - vec2(0.5)) * scale_ratio + vec2(0.5);

    // Billboard setup
    MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
    MODELVIEW_MATRIX = MODELVIEW_MATRIX * mat4(vec4(size, 0.0, 0.0, 0.0), vec4(0.0, size, 0.0, 0.0), vec4(0.0, 0.0, size, 0.0), vec4(0.0, 0.0, 0.0, 1.0));
}

void fragment() {
    vec3 emission_tex = texture(texture_emission, UV).rgb;
    vec3 color = STAR_COLOR * emission_tex;
    
    // Discard very dim pixels
    if (length(color) < 0.001)
        discard;

    ALBEDO = color;
}