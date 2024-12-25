shader_type spatial;

render_mode unshaded, blend_mix;

uniform vec3 uv1_scale = vec3(1.0, 1.0, 1.0);
uniform vec3 uv1_offset = vec3(0.0, 0.0, 0.0);
uniform float variation = 0.0;
varying float elapsed_time;
void vertex() {
	elapsed_time = TIME;
	UV = UV*uv1_scale.xy+uv1_offset.xy;
}
float rand(vec2 x) {
    return fract(cos(mod(dot(x, vec2(13.9898, 8.141)), 3.14)) * 43758.5453);
}
vec2 rand2(vec2 x) {
    return fract(cos(mod(vec2(dot(x, vec2(13.9898, 8.141)),
						      dot(x, vec2(3.4562, 17.398))), vec2(3.14))) * 43758.5453);
}
vec3 rand3(vec2 x) {
    return fract(cos(mod(vec3(dot(x, vec2(13.9898, 8.141)),
							  dot(x, vec2(3.4562, 17.398)),
                              dot(x, vec2(13.254, 5.867))), vec3(3.14))) * 43758.5453);
}
float param_rnd(float minimum, float maximum, float seed) {
	return minimum+(maximum-minimum)*rand(vec2(seed));
}
vec3 rgb2hsv(vec3 c) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = c.g < c.b ? vec4(c.bg, K.wz) : vec4(c.gb, K.xy);
	vec4 q = c.r < p.x ? vec4(p.xyw, c.r) : vec4(c.r, p.yzx);
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}
vec3 hsv2rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
float value_noise_2d(vec2 coord, vec2 size, float offset, float seed) {
	vec2 o = floor(coord)+rand2(vec2(seed, 1.0-seed))+size;
	vec2 f = fract(coord);
	float p00 = rand(mod(o, size));
	float p01 = rand(mod(o + vec2(0.0, 1.0), size));
	float p10 = rand(mod(o + vec2(1.0, 0.0), size));
	float p11 = rand(mod(o + vec2(1.0, 1.0), size));
	p00 = sin(p00 * 6.28318530718 + offset * 6.28318530718) / 2.0 + 0.5;
	p01 = sin(p01 * 6.28318530718 + offset * 6.28318530718) / 2.0 + 0.5;
	p10 = sin(p10 * 6.28318530718 + offset * 6.28318530718) / 2.0 + 0.5;
	p11 = sin(p11 * 6.28318530718 + offset * 6.28318530718) / 2.0 + 0.5;
	vec2 t =  f * f * f * (f * (f * 6.0 - 15.0) + 10.0);
	return mix(mix(p00, p10, t.x), mix(p01, p11, t.x), t.y);
}
float fbm_2d_value(vec2 coord, vec2 size, int folds, int octaves, float persistence, float offset, float seed) {
	float normalize_factor = 0.0;
	float value = 0.0;
	float scale = 1.0;
	for (int i = 0; i < octaves; i++) {
		float noise = value_noise_2d(coord*size, size, offset, seed);
		for (int f = 0; f < folds; ++f) {
			noise = abs(2.0*noise-1.0);
		}
		value += noise * scale;
		normalize_factor += scale;
		size *= 2.0;
		scale *= persistence;
	}
	return value / normalize_factor;
}
float perlin_noise_2d(vec2 coord, vec2 size, float offset, float seed) {
	vec2 o = floor(coord)+rand2(vec2(seed, 1.0-seed))+size;
	vec2 f = fract(coord);
	float a00 = rand(mod(o, size)) * 6.28318530718 + offset * 6.28318530718;
	float a01 = rand(mod(o + vec2(0.0, 1.0), size)) * 6.28318530718 + offset * 6.28318530718;
	float a10 = rand(mod(o + vec2(1.0, 0.0), size)) * 6.28318530718 + offset * 6.28318530718;
	float a11 = rand(mod(o + vec2(1.0, 1.0), size)) * 6.28318530718 + offset * 6.28318530718;
	vec2 v00 = vec2(cos(a00), sin(a00));
	vec2 v01 = vec2(cos(a01), sin(a01));
	vec2 v10 = vec2(cos(a10), sin(a10));
	vec2 v11 = vec2(cos(a11), sin(a11));
	float p00 = dot(v00, f);
	float p01 = dot(v01, f - vec2(0.0, 1.0));
	float p10 = dot(v10, f - vec2(1.0, 0.0));
	float p11 = dot(v11, f - vec2(1.0, 1.0));
	vec2 t =  f * f * f * (f * (f * 6.0 - 15.0) + 10.0);
	return 0.5 + mix(mix(p00, p10, t.x), mix(p01, p11, t.x), t.y);
}
float fbm_2d_perlin(vec2 coord, vec2 size, int folds, int octaves, float persistence, float offset, float seed) {
	float normalize_factor = 0.0;
	float value = 0.0;
	float scale = 1.0;
	for (int i = 0; i < octaves; i++) {
		float noise = perlin_noise_2d(coord*size, size, offset, seed);
		for (int f = 0; f < folds; ++f) {
			noise = abs(2.0*noise-1.0);
		}
		value += noise * scale;
		normalize_factor += scale;
		size *= 2.0;
		scale *= persistence;
	}
	return value / normalize_factor;
}
float perlinabs_noise_2d(vec2 coord, vec2 size, float offset, float seed) {
	return abs(2.0*perlin_noise_2d(coord, size, offset, seed)-1.0);
}
float fbm_2d_perlinabs(vec2 coord, vec2 size, int folds, int octaves, float persistence, float offset, float seed) {
	float normalize_factor = 0.0;
	float value = 0.0;
	float scale = 1.0;
	for (int i = 0; i < octaves; i++) {
		float noise = perlinabs_noise_2d(coord*size, size, offset, seed);
		for (int f = 0; f < folds; ++f) {
			noise = abs(2.0*noise-1.0);
		}
		value += noise * scale;
		normalize_factor += scale;
		size *= 2.0;
		scale *= persistence;
	}
	return value / normalize_factor;
}
float fbm_2d_mod289(float x) {
	return x - floor(x * (1.0 / 289.0)) * 289.0;
}
float fbm_2d_permute(float x) {
	return fbm_2d_mod289(((x * 34.0) + 1.0) * x);
}
vec2 fbm_2d_rgrad2(vec2 p, float rot, float seed) {
	float u = fbm_2d_permute(fbm_2d_permute(p.x) + p.y) * 0.0243902439 + rot; // Rotate by shift
	u = fract(u) * 6.28318530718; // 2*pi
	return vec2(cos(u), sin(u));
}
float simplex_noise_2d(vec2 coord, vec2 size, float offset, float seed) {
	coord *= 2.0; // needed for it to tile
	coord += rand2(vec2(seed, 1.0-seed)) + size;
	size *= 2.0; // needed for it to tile
	coord.y += 0.001;
	vec2 uv = vec2(coord.x + coord.y*0.5, coord.y);
	vec2 i0 = floor(uv);
	vec2 f0 = fract(uv);
	vec2 i1 = (f0.x > f0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
	vec2 p0 = vec2(i0.x - i0.y * 0.5, i0.y);
	vec2 p1 = vec2(p0.x + i1.x - i1.y * 0.5, p0.y + i1.y);
	vec2 p2 = vec2(p0.x + 0.5, p0.y + 1.0);
	i1 = i0 + i1;
	vec2 i2 = i0 + vec2(1.0, 1.0);
	vec2 d0 = coord - p0;
	vec2 d1 = coord - p1;
	vec2 d2 = coord - p2;
	vec3 xw = mod(vec3(p0.x, p1.x, p2.x), size.x);
	vec3 yw = mod(vec3(p0.y, p1.y, p2.y), size.y);
	vec3 iuw = xw + 0.5 * yw;
	vec3 ivw = yw;
	vec2 g0 = fbm_2d_rgrad2(vec2(iuw.x, ivw.x), offset, seed);
	vec2 g1 = fbm_2d_rgrad2(vec2(iuw.y, ivw.y), offset, seed);
	vec2 g2 = fbm_2d_rgrad2(vec2(iuw.z, ivw.z), offset, seed);
	vec3 w = vec3(dot(g0, d0), dot(g1, d1), dot(g2, d2));
	vec3 t = 0.8 - vec3(dot(d0, d0), dot(d1, d1), dot(d2, d2));
	t = max(t, vec3(0.0));
	vec3 t2 = t * t;
	vec3 t4 = t2 * t2;
	float n = dot(t4, w);
	return 0.5 + 5.5 * n;
}
float fbm_2d_simplex(vec2 coord, vec2 size, int folds, int octaves, float persistence, float offset, float seed) {
	float normalize_factor = 0.0;
	float value = 0.0;
	float scale = 1.0;
	for (int i = 0; i < octaves; i++) {
		float noise = simplex_noise_2d(coord*size, size, offset, seed);
		for (int f = 0; f < folds; ++f) {
			noise = abs(2.0*noise-1.0);
		}
		value += noise * scale;
		normalize_factor += scale;
		size *= 2.0;
		scale *= persistence;
	}
	return value / normalize_factor;
}
float cellular_noise_2d(vec2 coord, vec2 size, float offset, float seed) {
	vec2 o = floor(coord)+rand2(vec2(seed, 1.0-seed))+size;
	vec2 f = fract(coord);
	float min_dist = 2.0;
	for(float x = -1.0; x <= 1.0; x++) {
		for(float y = -1.0; y <= 1.0; y++) {
			vec2 neighbor = vec2(float(x),float(y));
			vec2 node = rand2(mod(o + vec2(x, y), size)) + vec2(x, y);
			node =  0.5 + 0.25 * sin(offset * 6.28318530718 + 6.28318530718 * node);
			vec2 diff = neighbor + node - f;
			float dist = length(diff);
			min_dist = min(min_dist, dist);
		}
	}
	return min_dist;
}
float fbm_2d_cellular(vec2 coord, vec2 size, int folds, int octaves, float persistence, float offset, float seed) {
	float normalize_factor = 0.0;
	float value = 0.0;
	float scale = 1.0;
	for (int i = 0; i < octaves; i++) {
		float noise = cellular_noise_2d(coord*size, size, offset, seed);
		for (int f = 0; f < folds; ++f) {
			noise = abs(2.0*noise-1.0);
		}
		value += noise * scale;
		normalize_factor += scale;
		size *= 2.0;
		scale *= persistence;
	}
	return value / normalize_factor;
}
float cellular2_noise_2d(vec2 coord, vec2 size, float offset, float seed) {
	vec2 o = floor(coord)+rand2(vec2(seed, 1.0-seed))+size;
	vec2 f = fract(coord);
	float min_dist1 = 2.0;
	float min_dist2 = 2.0;
	for(float x = -1.0; x <= 1.0; x++) {
		for(float y = -1.0; y <= 1.0; y++) {
			vec2 neighbor = vec2(float(x),float(y));
			vec2 node = rand2(mod(o + vec2(x, y), size)) + vec2(x, y);
			node = 0.5 + 0.25 * sin(offset * 6.28318530718 + 6.28318530718*node);
			vec2 diff = neighbor + node - f;
			float dist = length(diff);
			if (min_dist1 > dist) {
				min_dist2 = min_dist1;
				min_dist1 = dist;
			} else if (min_dist2 > dist) {
				min_dist2 = dist;
			}
		}
	}
	return min_dist2-min_dist1;
}
float fbm_2d_cellular2(vec2 coord, vec2 size, int folds, int octaves, float persistence, float offset, float seed) {
	float normalize_factor = 0.0;
	float value = 0.0;
	float scale = 1.0;
	for (int i = 0; i < octaves; i++) {
		float noise = cellular2_noise_2d(coord*size, size, offset, seed);
		for (int f = 0; f < folds; ++f) {
			noise = abs(2.0*noise-1.0);
		}
		value += noise * scale;
		normalize_factor += scale;
		size *= 2.0;
		scale *= persistence;
	}
	return value / normalize_factor;
}
float cellular3_noise_2d(vec2 coord, vec2 size, float offset, float seed) {
	vec2 o = floor(coord)+rand2(vec2(seed, 1.0-seed))+size;
	vec2 f = fract(coord);
	float min_dist = 2.0;
	for(float x = -1.0; x <= 1.0; x++) {
		for(float y = -1.0; y <= 1.0; y++) {
			vec2 neighbor = vec2(float(x),float(y));
			vec2 node = rand2(mod(o + vec2(x, y), size)) + vec2(x, y);
			node = 0.5 + 0.25 * sin(offset * 6.28318530718 + 6.28318530718*node);
			vec2 diff = neighbor + node - f;
			float dist = abs((diff).x) + abs((diff).y);
			min_dist = min(min_dist, dist);
		}
	}
	return min_dist;
}
float fbm_2d_cellular3(vec2 coord, vec2 size, int folds, int octaves, float persistence, float offset, float seed) {
	float normalize_factor = 0.0;
	float value = 0.0;
	float scale = 1.0;
	for (int i = 0; i < octaves; i++) {
		float noise = cellular3_noise_2d(coord*size, size, offset, seed);
		for (int f = 0; f < folds; ++f) {
			noise = abs(2.0*noise-1.0);
		}
		value += noise * scale;
		normalize_factor += scale;
		size *= 2.0;
		scale *= persistence;
	}
	return value / normalize_factor;
}
float cellular4_noise_2d(vec2 coord, vec2 size, float offset, float seed) {
	vec2 o = floor(coord)+rand2(vec2(seed, 1.0-seed))+size;
	vec2 f = fract(coord);
	float min_dist1 = 2.0;
	float min_dist2 = 2.0;
	for(float x = -1.0; x <= 1.0; x++) {
		for(float y = -1.0; y <= 1.0; y++) {
			vec2 neighbor = vec2(float(x),float(y));
			vec2 node = rand2(mod(o + vec2(x, y), size)) + vec2(x, y);
			node = 0.5 + 0.25 * sin(offset * 6.28318530718 + 6.28318530718*node);
			vec2 diff = neighbor + node - f;
			float dist = abs((diff).x) + abs((diff).y);
			if (min_dist1 > dist) {
				min_dist2 = min_dist1;
				min_dist1 = dist;
			} else if (min_dist2 > dist) {
				min_dist2 = dist;
			}
		}
	}
	return min_dist2-min_dist1;
}
float fbm_2d_cellular4(vec2 coord, vec2 size, int folds, int octaves, float persistence, float offset, float seed) {
	float normalize_factor = 0.0;
	float value = 0.0;
	float scale = 1.0;
	for (int i = 0; i < octaves; i++) {
		float noise = cellular4_noise_2d(coord*size, size, offset, seed);
		for (int f = 0; f < folds; ++f) {
			noise = abs(2.0*noise-1.0);
		}
		value += noise * scale;
		normalize_factor += scale;
		size *= 2.0;
		scale *= persistence;
	}
	return value / normalize_factor;
}
float cellular5_noise_2d(vec2 coord, vec2 size, float offset, float seed) {
	vec2 o = floor(coord)+rand2(vec2(seed, 1.0-seed))+size;
	vec2 f = fract(coord);
	float min_dist = 2.0;
	for(float x = -1.0; x <= 1.0; x++) {
		for(float y = -1.0; y <= 1.0; y++) {
			vec2 neighbor = vec2(float(x),float(y));
			vec2 node = rand2(mod(o + vec2(x, y), size)) + vec2(x, y);
			node = 0.5 + 0.5 * sin(offset * 6.28318530718 + 6.28318530718*node);
			vec2 diff = neighbor + node - f;
			float dist = max(abs((diff).x), abs((diff).y));
			min_dist = min(min_dist, dist);
		}
	}
	return min_dist;
}
float fbm_2d_cellular5(vec2 coord, vec2 size, int folds, int octaves, float persistence, float offset, float seed) {
	float normalize_factor = 0.0;
	float value = 0.0;
	float scale = 1.0;
	for (int i = 0; i < octaves; i++) {
		float noise = cellular5_noise_2d(coord*size, size, offset, seed);
		for (int f = 0; f < folds; ++f) {
			noise = abs(2.0*noise-1.0);
		}
		value += noise * scale;
		normalize_factor += scale;
		size *= 2.0;
		scale *= persistence;
	}
	return value / normalize_factor;
}
float cellular6_noise_2d(vec2 coord, vec2 size, float offset, float seed) {
	vec2 o = floor(coord)+rand2(vec2(seed, 1.0-seed))+size;
	vec2 f = fract(coord);
	float min_dist1 = 2.0;
	float min_dist2 = 2.0;
	for(float x = -1.0; x <= 1.0; x++) {
		for(float y = -1.0; y <= 1.0; y++) {
			vec2 neighbor = vec2(float(x),float(y));
			vec2 node = rand2(mod(o + vec2(x, y), size)) + vec2(x, y);
			node = 0.5 + 0.25 * sin(offset * 6.28318530718 + 6.28318530718*node);
			vec2 diff = neighbor + node - f;
			float dist = max(abs((diff).x), abs((diff).y));
			if (min_dist1 > dist) {
				min_dist2 = min_dist1;
				min_dist1 = dist;
			} else if (min_dist2 > dist) {
				min_dist2 = dist;
			}
		}
	}
	return min_dist2-min_dist1;
}
float fbm_2d_cellular6(vec2 coord, vec2 size, int folds, int octaves, float persistence, float offset, float seed) {
	float normalize_factor = 0.0;
	float value = 0.0;
	float scale = 1.0;
	for (int i = 0; i < octaves; i++) {
		float noise = cellular6_noise_2d(coord*size, size, offset, seed);
		for (int f = 0; f < folds; ++f) {
			noise = abs(2.0*noise-1.0);
		}
		value += noise * scale;
		normalize_factor += scale;
		size *= 2.0;
		scale *= persistence;
	}
	return value / normalize_factor;
}
// MIT License Inigo Quilez - https://www.shadertoy.com/view/Xd23Dh
float voronoise_noise_2d( vec2 coord, vec2 size, float offset, float seed) {
	vec2 i = floor(coord) + rand2(vec2(seed, 1.0-seed)) + size;
	vec2 f = fract(coord);
	
	vec2 a = vec2(0.0);
	
	for( int y=-2; y<=2; y++ ) {
		for( int x=-2; x<=2; x++ ) {
			vec2  g = vec2( float(x), float(y) );
			vec3  o = rand3( mod(i + g, size) + vec2(seed) );
			o.xy += 0.25 * sin(offset * 6.28318530718 + 6.28318530718*o.xy);
			vec2  d = g - f + o.xy;
			float w = pow( 1.0-smoothstep(0.0, 1.414, length(d)), 1.0 );
			a += vec2(o.z*w,w);
		}
	}
	
	return a.x/a.y;
}
float fbm_2d_voronoise(vec2 coord, vec2 size, int folds, int octaves, float persistence, float offset, float seed) {
	float normalize_factor = 0.0;
	float value = 0.0;
	float scale = 1.0;
	for (int i = 0; i < octaves; i++) {
		float noise = voronoise_noise_2d(coord*size, size, offset, seed);
		for (int f = 0; f < folds; ++f) {
			noise = abs(2.0*noise-1.0);
		}
		value += noise * scale;
		normalize_factor += scale;
		size *= 2.0;
		scale *= persistence;
	}
	return value / normalize_factor;
}
vec2 transform2_clamp(vec2 uv) {
	return clamp(uv, vec2(0.0), vec2(1.0));
}
vec2 transform2(vec2 uv, vec2 translate, float rotate, vec2 scale) {
 	vec2 rv;
	uv -= translate;
	uv -= vec2(0.5);
	rv.x = cos(rotate)*uv.x + sin(rotate)*uv.y;
	rv.y = -sin(rotate)*uv.x + cos(rotate)*uv.y;
	rv /= scale;
	rv += vec2(0.5);
	return rv;	
}
vec3 blend_normal(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*c1 + (1.0-opacity)*c2;
}
vec3 blend_dissolve(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	if (rand(uv) < opacity) {
		return c1;
	} else {
		return c2;
	}
}
vec3 blend_multiply(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*c1*c2 + (1.0-opacity)*c2;
}
vec3 blend_screen(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*(1.0-(1.0-c1)*(1.0-c2)) + (1.0-opacity)*c2;
}
float blend_overlay_f(float c1, float c2) {
	return (c1 < 0.5) ? (2.0*c1*c2) : (1.0-2.0*(1.0-c1)*(1.0-c2));
}
vec3 blend_overlay(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_overlay_f(c1.x, c2.x), blend_overlay_f(c1.y, c2.y), blend_overlay_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
vec3 blend_hard_light(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*0.5*(c1*c2+blend_overlay(uv, c1, c2, 1.0)) + (1.0-opacity)*c2;
}
float blend_soft_light_f(float c1, float c2) {
	return (c2 < 0.5) ? (2.0*c1*c2+c1*c1*(1.0-2.0*c2)) : 2.0*c1*(1.0-c2)+sqrt(c1)*(2.0*c2-1.0);
}
vec3 blend_soft_light(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_soft_light_f(c1.x, c2.x), blend_soft_light_f(c1.y, c2.y), blend_soft_light_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_burn_f(float c1, float c2) {
	return (c1==0.0)?c1:max((1.0-((1.0-c2)/c1)),0.0);
}
vec3 blend_burn(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_burn_f(c1.x, c2.x), blend_burn_f(c1.y, c2.y), blend_burn_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_dodge_f(float c1, float c2) {
	return (c1==1.0)?c1:min(c2/(1.0-c1),1.0);
}
vec3 blend_dodge(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_dodge_f(c1.x, c2.x), blend_dodge_f(c1.y, c2.y), blend_dodge_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
vec3 blend_lighten(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*max(c1, c2) + (1.0-opacity)*c2;
}
vec3 blend_darken(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*min(c1, c2) + (1.0-opacity)*c2;
}
vec3 blend_linear(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return c1 + opacity * (2.0 *(c2 - vec3(0.5)));
}
vec3 blend_difference(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*clamp(c2-c1, vec3(0.0), vec3(1.0)) + (1.0-opacity)*c2;
}
vec3 blend_additive(vec2 uv, vec3 c1, vec3 c2, float oppacity) {
	return c2 + c1 * oppacity;
}
vec3 blend_addsub(vec2 uv, vec3 c1, vec3 c2, float oppacity) {
	return c2 + (c1 - .5) * 2.0 * oppacity;
}
const float p_o26672_gradient_0_pos = 0.000000000;
const vec4 p_o26672_gradient_0_col = vec4(0.000000000, 0.000000000, 0.000000000, 1.000000000);
const float p_o26672_gradient_1_pos = 0.077428506;
const vec4 p_o26672_gradient_1_col = vec4(0.589843750, 0.006912231, 0.011484174, 1.000000000);
const float p_o26672_gradient_2_pos = 0.141064037;
const vec4 p_o26672_gradient_2_col = vec4(1.000000000, 0.349019617, 0.015686275, 1.000000000);
const float p_o26672_gradient_3_pos = 0.368337180;
const vec4 p_o26672_gradient_3_col = vec4(1.000000000, 1.000000000, 0.000000000, 0.996078432);
const float p_o26672_gradient_4_pos = 0.850155362;
const vec4 p_o26672_gradient_4_col = vec4(1.000000000, 1.000000000, 0.854901969, 0.996078432);
const float p_o26672_gradient_5_pos = 0.959246549;
const vec4 p_o26672_gradient_5_col = vec4(0.000000000, 0.000000000, 1.000000000, 0.996078432);
const float p_o26672_gradient_6_pos = 1.000000000;
const vec4 p_o26672_gradient_6_col = vec4(0.026400566, 0.006958008, 0.074218750, 0.996078432);
vec4 o26672_gradient_gradient_fct(float x) {
  if (x < p_o26672_gradient_0_pos) {
    return p_o26672_gradient_0_col;
  } else if (x < p_o26672_gradient_1_pos) {
    return mix(mix(p_o26672_gradient_1_col, p_o26672_gradient_2_col, (x-p_o26672_gradient_1_pos)/(p_o26672_gradient_2_pos-p_o26672_gradient_1_pos)), mix(p_o26672_gradient_0_col, p_o26672_gradient_1_col, (x-p_o26672_gradient_0_pos)/(p_o26672_gradient_1_pos-p_o26672_gradient_0_pos)), 1.0-0.5*(x-p_o26672_gradient_0_pos)/(p_o26672_gradient_1_pos-p_o26672_gradient_0_pos));
  } else if (x < p_o26672_gradient_2_pos) {
    return 0.5*(mix(p_o26672_gradient_1_col, p_o26672_gradient_2_col, (x-p_o26672_gradient_1_pos)/(p_o26672_gradient_2_pos-p_o26672_gradient_1_pos)) + mix(mix(p_o26672_gradient_0_col, p_o26672_gradient_1_col, (x-p_o26672_gradient_0_pos)/(p_o26672_gradient_1_pos-p_o26672_gradient_0_pos)), mix(p_o26672_gradient_2_col, p_o26672_gradient_3_col, (x-p_o26672_gradient_2_pos)/(p_o26672_gradient_3_pos-p_o26672_gradient_2_pos)), 0.5-0.5*cos(3.14159265359*(x-p_o26672_gradient_1_pos)/(p_o26672_gradient_2_pos-p_o26672_gradient_1_pos))));
  } else if (x < p_o26672_gradient_3_pos) {
    return 0.5*(mix(p_o26672_gradient_2_col, p_o26672_gradient_3_col, (x-p_o26672_gradient_2_pos)/(p_o26672_gradient_3_pos-p_o26672_gradient_2_pos)) + mix(mix(p_o26672_gradient_1_col, p_o26672_gradient_2_col, (x-p_o26672_gradient_1_pos)/(p_o26672_gradient_2_pos-p_o26672_gradient_1_pos)), mix(p_o26672_gradient_3_col, p_o26672_gradient_4_col, (x-p_o26672_gradient_3_pos)/(p_o26672_gradient_4_pos-p_o26672_gradient_3_pos)), 0.5-0.5*cos(3.14159265359*(x-p_o26672_gradient_2_pos)/(p_o26672_gradient_3_pos-p_o26672_gradient_2_pos))));
  } else if (x < p_o26672_gradient_4_pos) {
    return 0.5*(mix(p_o26672_gradient_3_col, p_o26672_gradient_4_col, (x-p_o26672_gradient_3_pos)/(p_o26672_gradient_4_pos-p_o26672_gradient_3_pos)) + mix(mix(p_o26672_gradient_2_col, p_o26672_gradient_3_col, (x-p_o26672_gradient_2_pos)/(p_o26672_gradient_3_pos-p_o26672_gradient_2_pos)), mix(p_o26672_gradient_4_col, p_o26672_gradient_5_col, (x-p_o26672_gradient_4_pos)/(p_o26672_gradient_5_pos-p_o26672_gradient_4_pos)), 0.5-0.5*cos(3.14159265359*(x-p_o26672_gradient_3_pos)/(p_o26672_gradient_4_pos-p_o26672_gradient_3_pos))));
  } else if (x < p_o26672_gradient_5_pos) {
    return 0.5*(mix(p_o26672_gradient_4_col, p_o26672_gradient_5_col, (x-p_o26672_gradient_4_pos)/(p_o26672_gradient_5_pos-p_o26672_gradient_4_pos)) + mix(mix(p_o26672_gradient_3_col, p_o26672_gradient_4_col, (x-p_o26672_gradient_3_pos)/(p_o26672_gradient_4_pos-p_o26672_gradient_3_pos)), mix(p_o26672_gradient_5_col, p_o26672_gradient_6_col, (x-p_o26672_gradient_5_pos)/(p_o26672_gradient_6_pos-p_o26672_gradient_5_pos)), 0.5-0.5*cos(3.14159265359*(x-p_o26672_gradient_4_pos)/(p_o26672_gradient_5_pos-p_o26672_gradient_4_pos))));
  } else if (x < p_o26672_gradient_6_pos) {
    return mix(mix(p_o26672_gradient_4_col, p_o26672_gradient_5_col, (x-p_o26672_gradient_4_pos)/(p_o26672_gradient_5_pos-p_o26672_gradient_4_pos)), mix(p_o26672_gradient_5_col, p_o26672_gradient_6_col, (x-p_o26672_gradient_5_pos)/(p_o26672_gradient_6_pos-p_o26672_gradient_5_pos)), 0.5+0.5*(x-p_o26672_gradient_5_pos)/(p_o26672_gradient_6_pos-p_o26672_gradient_5_pos));
  }
  return p_o26672_gradient_6_col;
}
const float p_o26653_amount = 0.880000000;
const float p_o26687_gradient_0_pos = 0.116645000;
const vec4 p_o26687_gradient_0_col = vec4(1.000000000, 1.000000000, 1.000000000, 1.000000000);
const float p_o26687_gradient_1_pos = 0.639488000;
const vec4 p_o26687_gradient_1_col = vec4(0.000000000, 0.000000000, 0.000000000, 1.000000000);
vec4 o26687_gradient_gradient_fct(float x) {
  if (x < p_o26687_gradient_0_pos) {
    return p_o26687_gradient_0_col;
  } else if (x < p_o26687_gradient_1_pos) {
    return mix(p_o26687_gradient_0_col, p_o26687_gradient_1_col, (x-p_o26687_gradient_0_pos)/(p_o26687_gradient_1_pos-p_o26687_gradient_0_pos));
  }
  return p_o26687_gradient_1_col;
}
const float seed_o26652 = 0.000000000;
const float p_o26652_rotate = 0.000000000;
const float p_o26652_scale_x = 1.000000000;
const float p_o26652_scale_y = 1.000000000;
const float p_o26648_amount = 0.175000000;
const float p_o26648_eps = 0.325000000;
const float seed_o26647 = 0.000000000;
const float p_o26647_scale_x = 7.000000000;
const float p_o26647_scale_y = 7.000000000;
const float p_o26647_folds = 0.000000000;
const float p_o26647_iterations = 10.000000000;
const float p_o26647_persistence = 0.750000000;
float o26648_input_d(vec2 uv, float _seed_variation_) {
float o26647_0_1_f = fbm_2d_simplex((uv), vec2(p_o26647_scale_x, p_o26647_scale_y), int(p_o26647_folds), int(p_o26647_iterations), p_o26647_persistence, (elapsed_time*0.1), (seed_o26647+fract(_seed_variation_)));
return o26647_0_1_f;
}
vec2 o26648_slope(vec2 uv, float epsilon, float _seed_variation_) {
	return vec2(o26648_input_d(fract(uv+vec2(epsilon, 0.0)), _seed_variation_)-o26648_input_d(fract(uv-vec2(epsilon, 0.0)), _seed_variation_), o26648_input_d(fract(uv+vec2(0.0, epsilon)), _seed_variation_)-o26648_input_d(fract(uv-vec2(0.0, epsilon)), _seed_variation_));
}const float p_o26671_translate_x = 0.000000000;
const float p_o26671_translate_y = 0.000000000;
const float p_o26671_rotate = 0.000000000;
const float p_o26671_scale_x = 27.460000000;
const float p_o26671_scale_y = 6.950000000;
const float p_o368913_curve_0_x = 0.000000000;
const float p_o368913_curve_0_y = 0.000000000;
const float p_o368913_curve_0_ls = 0.000000000;
const float p_o368913_curve_0_rs = -0.161685219;
const float p_o368913_curve_1_x = 1.000000000;
const float p_o368913_curve_1_y = 1.000000000;
const float p_o368913_curve_1_ls = -0.404213017;
const float p_o368913_curve_1_rs = 0.000000000;
float o368913_curve_curve_fct(float x) {
{
float dx = x - p_o368913_curve_0_x;
float d = p_o368913_curve_1_x - p_o368913_curve_0_x;
float t = dx/d;
float omt = (1.0 - t);
float omt2 = omt * omt;
float omt3 = omt2 * omt;
float t2 = t * t;
float t3 = t2 * t;
d /= 3.0;
float y1 = p_o368913_curve_0_y;
float yac = p_o368913_curve_0_y + d*p_o368913_curve_0_rs;
float ybc = p_o368913_curve_1_y - d*p_o368913_curve_1_ls;
float y2 = p_o368913_curve_1_y;
return y1*omt3 + yac*omt2*t*3.0 + ybc*omt*t2*3.0 + y2*t3;
}
}
void fragment() {
	float _seed_variation_ = variation;
	vec2 uv = fract(UV);
vec2 o26648_0_slope = o26648_slope((transform2((uv), vec2((param_rnd(0,0.01, (seed_o26652+fract(_seed_variation_))+0.841471)*elapsed_time)*(2.0*1.0-1.0), (param_rnd(0,0.01, (seed_o26652+fract(_seed_variation_))+17.841471)*elapsed_time*-.3)*(2.0*1.0-1.0)), p_o26652_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o26652_scale_x*(2.0*1.0-1.0), p_o26652_scale_y*(2.0*1.0-1.0)))), p_o26648_eps, _seed_variation_);
vec2 o26648_0_warp = o26648_0_slope;float o26647_0_1_f = fbm_2d_simplex(((transform2((uv), vec2((param_rnd(0,0.01, (seed_o26652+fract(_seed_variation_))+0.841471)*elapsed_time)*(2.0*1.0-1.0), (param_rnd(0,0.01, (seed_o26652+fract(_seed_variation_))+17.841471)*elapsed_time*-.3)*(2.0*1.0-1.0)), p_o26652_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o26652_scale_x*(2.0*1.0-1.0), p_o26652_scale_y*(2.0*1.0-1.0))))+p_o26648_amount*o26648_0_warp), vec2(p_o26647_scale_x, p_o26647_scale_y), int(p_o26647_folds), int(p_o26647_iterations), p_o26647_persistence, (elapsed_time*0.1), (seed_o26647+fract(_seed_variation_)));
vec4 o26648_0_1_rgba = vec4(vec3(o26647_0_1_f), 1.0);
vec4 o26652_0_1_rgba = o26648_0_1_rgba;
vec4 o26687_0_1_rgba = o26687_gradient_gradient_fct((dot((o26652_0_1_rgba).rgb, vec3(1.0))/3.0));
float o368913_0_1_f = o368913_curve_curve_fct(((transform2((uv), vec2(p_o26671_translate_x*(2.0*1.0-1.0), p_o26671_translate_y*(2.0*1.0-1.0)), p_o26671_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o26671_scale_x*(2.0*1.0-1.0), p_o26671_scale_y*(2.0*1.0-1.0))))).x);
vec4 o26671_0_1_rgba = vec4(vec3(o368913_0_1_f), 1.0);
vec4 o26653_0_s1 = o26687_0_1_rgba;
vec4 o26653_0_s2 = o26671_0_1_rgba;
float o26653_0_a = p_o26653_amount*1.0;
vec4 o26653_0_2_rgba = vec4(blend_normal((uv), o26653_0_s1.rgb, o26653_0_s2.rgb, o26653_0_a*o26653_0_s1.a), min(1.0, o26653_0_s2.a+o26653_0_a*o26653_0_s1.a));
vec4 o26672_0_1_rgba = o26672_gradient_gradient_fct((dot((o26653_0_2_rgba).rgb, vec3(1.0))/3.0));

	vec4 color_tex = o26672_0_1_rgba;
	color_tex = mix(pow((color_tex + vec4(0.055)) * (1.0 / (1.0 + 0.055)),vec4(2.4)),color_tex * (1.0 / 12.92),lessThan(color_tex,vec4(0.04045)));
	ALBEDO = color_tex.rgb;
	ALPHA = color_tex.a;

}



