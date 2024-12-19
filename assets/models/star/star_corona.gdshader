shader_type particles;

uniform vec3 star_color : source_color;

void process() {
    // Corona particle shader
    COLOR = vec4(star_color, 0.1);
}