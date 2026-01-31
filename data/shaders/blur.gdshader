shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float blur_strength : hint_range(0.0, 10.0) = 4.0;
uniform int samples = 8;

void fragment() {
    vec2 uv = SCREEN_UV;
    vec4 color = vec4(0.0);

    float offset = blur_strength / float(samples) / 100.0;

    for (int x = -samples; x <= samples; x++) {
        for (int y = -samples; y <= samples; y++) {
            vec2 shift = vec2(float(x), float(y)) * offset;
            color += texture(SCREEN_TEXTURE, uv + shift);
        }
    }

    float total = float((samples * 2 + 1) * (samples * 2 + 1));
    COLOR = color / total;
}