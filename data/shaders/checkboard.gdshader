shader_type canvas_item;

uniform float speed : hint_range(0.0, 10.0) = 1.0;
uniform float size : hint_range(1.0, 200.0) = 50.0;
uniform float skew_amount : hint_range(0.0, 1.0) = 0.3;
uniform float visibility : hint_range(0.0, 1.0) = 1.0; // NOVO: controle de visibilidade
uniform vec4 color1 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 color2 : source_color = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
	// Posição da UV (0-1), convertida para espaço local
	vec2 uv = UV * size;

	// Aplica inclinação nas células (skew horizontal)
	uv.x += uv.y * skew_amount;

	// Move horizontalmente com base no tempo e na velocidade
	uv.x += TIME * speed;

	// Converte para padrão quadriculado (mod 2)
	int x = int(floor(uv.x));
	int y = int(floor(uv.y));
	int check = (x + y) % 2;

	vec4 pattern_color = (check == 0) ? color1 : color2;

	// Mistura com a transparência via visibilidade
	COLOR = mix(vec4(0.0), pattern_color, visibility);
}
