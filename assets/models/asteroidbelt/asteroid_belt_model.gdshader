shader_type spatial;
render_mode unshaded, blend_mix;

uniform int texture_variation = 3;
uniform sampler2D texture_0;
uniform sampler2D texture_1;
uniform sampler2D texture_2;
// Add more if needed

void vertex() {
    // Billboard effect
    MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
}

void fragment() {
    int index = int(float(texture_variation) * fract(sin(dot(vec2(0.0), vec2(12.9898, 78.233))) * 43758.5453));
    
    vec4 color;
    switch(index) {
        case 0: 
            color = texture(texture_0, UV); 
            break;
        case 1: 
            color = texture(texture_1, UV); 
            break;
        case 2: 
            color = texture(texture_2, UV); 
            break;
        // Add more cases if needed
    }
    
    ALBEDO = color.rgb;
    ALPHA = color.a;
}