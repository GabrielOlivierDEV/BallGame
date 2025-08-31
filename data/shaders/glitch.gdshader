/*
	Glitch Effect Shader by Yui Kinomoto @arlez80
	MIT License
*/

shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// Intensidade do deslocamento (AUMENTADO)
uniform float shake_power = 0.08;
// Frequência do glitch (AUMENTADO)
uniform float shake_rate : hint_range(0.0, 1.0) = 0.5;
// Velocidade do efeito (AUMENTADO)
uniform float shake_speed = 2.0;
// Tamanho do bloco do glitch
uniform float shake_block_size = 15.0;
// Separação de cores (AUMENTADO)
uniform float shake_color_rate : hint_range(0.0, 1.0) = 0.03;

float random(float seed) {
	return fract(543.2543 * sin(dot(vec2(seed, seed), vec2(3525.46, -54.3415))));
}

void fragment() {
	// Aumento da intensidade do efeito de glitch
	float enable_shift = float(random(TIME * shake_speed) < shake_rate);

	vec2 fixed_uv = SCREEN_UV;
	fixed_uv.x += (
		random(SCREEN_UV.y * shake_block_size + TIME) - 0.5
	) * shake_power * enable_shift;

	vec4 pixel_color = textureLod(SCREEN_TEXTURE, fixed_uv, 0.0);
	pixel_color.r = mix(
		pixel_color.r,
		textureLod(SCREEN_TEXTURE, fixed_uv + vec2(shake_color_rate, 0.0), 0.0).r,
		enable_shift
	);
	pixel_color.b = mix(
		pixel_color.b,
		textureLod(SCREEN_TEXTURE, fixed_uv + vec2(-shake_color_rate, 0.0), 0.0).b,
		enable_shift
	);
	COLOR = pixel_color;
}
