// A CARA NUM CÍRCULO (`docs/decisoes/067`): o avatar da conversa. A máscara é
// feita aqui, na coordenada local do nó, e não por `clip_children`: com o
// recorte pelos filhos, a primeira versão saiu com a cara POR BAIXO do disco,
// a espreitar só fora dele.
shader_type canvas_item;

uniform vec2 tamanho = vec2(34.0, 34.0);
varying vec2 local;

void vertex() {
	local = VERTEX;
}

void fragment() {
	vec4 c = texture(TEXTURE, UV) * COLOR;
	float raio = min(tamanho.x, tamanho.y) * 0.5;
	float d = length(local - tamanho * 0.5);
	c.a *= clamp(raio - d + 0.5, 0.0, 1.0);
	COLOR = c;
}
