// O ruído partilhado dos shaders do caderno (`docs/decisoes/067`). Sem
// textura nenhuma: tudo sai de um hash, para não somar arquivo ao pacote.
float hash21(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

float ruido(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash21(i), hash21(i + vec2(1.0, 0.0)), u.x),
		mix(hash21(i + vec2(0.0, 1.0)), hash21(i + vec2(1.0, 1.0)), u.x), u.y);
}

float fbm(vec2 p) {
	float v = 0.0;
	float a = 0.5;
	for (int i = 0; i < 4; i++) {
		v += a * ruido(p);
		p *= 2.03;
		a *= 0.5;
	}
	return v;
}

// A distância à semente mais perto (Voronoi F1): o grão em pedrinhas do couro.
float celulas(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	float d = 8.0;
	for (int y = -1; y <= 1; y++) {
		for (int x = -1; x <= 1; x++) {
			vec2 g = vec2(float(x), float(y));
			vec2 o = vec2(hash21(i + g), hash21(i + g + 17.0));
			d = min(d, length(g + o - f));
		}
	}
	return d;
}

// Distância com sinal a um retângulo de cantos redondos centrado na origem.
float caixa_redonda(vec2 p, vec2 meio, float raio) {
	vec2 q = abs(p) - meio + raio;
	return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - raio;
}
