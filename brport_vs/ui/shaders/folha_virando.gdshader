// A FOLHA QUE CURVA (`docs/decisoes/067`, terceira passagem). A folha de rosto
// é fotografada no instante do toque e dobrada aqui por um CILINDRO que corre
// da borda direita para a lombada: o que já passou pelo cilindro enrola e
// volta por cima, a mostrar o VERSO. Pedido do Bruno: «virada ainda plana»,
// e a escolha foi a folha que curva.
//
// Para cada pixel da tela procura-se o ponto da folha que lá cai, da camada
// mais alta para a mais baixa: o verso deitado por cima (altura 2R), a meia
// volta de trás do cilindro, a meia volta da frente, e a folha ainda deitada.
// Onde nenhum cai, é transparente — e vê-se a página de baixo, com a sombra
// que a dobra lhe deita.
shader_type canvas_item;

uniform vec2 tamanho = vec2(600.0, 850.0);
// A posição do eixo do cilindro, ao longo da direção da dobra (em px).
uniform float dobra = 700.0;
uniform float raio = 40.0;
// A inclinação da linha da dobra: a mão levanta pelo canto de baixo.
uniform float inclinacao = 0.18;
uniform vec4 verso : source_color;
uniform vec4 sombra : source_color;


void fragment() {
	vec2 n = normalize(vec2(1.0, inclinacao));
	vec2 p = UV * tamanho;
	float x = dot(p, n);
	float W = dot(tamanho, n);   // o canto mais longe ao longo da dobra
	vec4 cor = vec4(0.0);
	bool feito = false;

	// 1. O verso deitado por cima, já depois da meia volta.
	if (x <= dobra) {
		float u = dobra + PI * raio + (dobra - x);
		vec2 src = p + (u - x) * n;
		if (u <= W && src.x >= 0.0 && src.x <= tamanho.x && src.y >= 0.0 && src.y <= tamanho.y) {
			cor = vec4(verso.rgb * 0.97, 1.0);
			feito = true;
		}
	}
	// 2. Em cima do cilindro: primeiro a meia volta de trás (mais alta).
	if (!feito && x >= dobra && x <= dobra + raio) {
		float s = clamp((x - dobra) / raio, 0.0, 1.0);
		float a1 = asin(s);
		float a2 = PI - a1;
		float u2 = dobra + raio * a2;
		vec2 src2 = p + (u2 - x) * n;
		if (u2 <= W && src2.x >= 0.0 && src2.x <= tamanho.x && src2.y >= 0.0 && src2.y <= tamanho.y) {
			// O verso a curvar: escurece para o fundo da volta.
			cor = vec4(verso.rgb * mix(0.72, 1.0, sin(a2)), 1.0);
			feito = true;
		} else {
			float u1 = dobra + raio * a1;
			vec2 src1 = p + (u1 - x) * n;
			if (u1 <= W && src1.x >= 0.0 && src1.x <= tamanho.x && src1.y >= 0.0 && src1.y <= tamanho.y) {
				vec4 t = texture(TEXTURE, src1 / tamanho);
				// A frente a curvar-se para longe da luz.
				cor = vec4(t.rgb * mix(1.0, 0.62, s), t.a);
				feito = true;
			}
		}
	}
	// 3. A folha ainda deitada.
	if (!feito && x < dobra) {
		cor = texture(TEXTURE, UV);
		// E a sombra que o verso deitado lhe faz ao lado da volta.
		feito = true;
	}
	// 4. Nada: a página de baixo, com a sombra que a dobra lhe deita.
	if (!feito) {
		float dist = x - (dobra + raio);
		cor = vec4(sombra.rgb, sombra.a * exp(-max(dist, 0.0) / 22.0));
	}
	COLOR = cor;
}
