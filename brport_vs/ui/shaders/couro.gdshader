// O COURO DA CAPA (`docs/decisoes/067`, terceira passagem). O Bruno pediu
// «capa ainda chapada» e escolheu textura procedural: o grão em pedrinhas do
// couro, manchas largas de uso e a lombada com volume, por cima da cor da
// `CadernoCapa`. As cores entram por `uniform`, lidas do TEMA pelo
// `FolhaDoCaderno` — o shader não traz paleta nenhuma.
shader_type canvas_item;
#include "res://ui/shaders/ruido.gdshaderinc"

uniform vec4 base : source_color;
uniform vec2 tamanho = vec2(640.0, 880.0);
uniform float raio = 12.0;
// A largura da lombada, à esquerda, onde as nervuras levantam o couro.
uniform float lombada = 12.0;

void fragment() {
	vec2 px = UV * tamanho;
	float d = caixa_redonda(px - tamanho * 0.5, tamanho * 0.5, raio);
	float dentro = clamp(0.5 - d, 0.0, 1.0);

	// O grão: pedrinhas de ~5 px, com o miolo mais claro e o sulco escuro.
	float grao = smoothstep(0.05, 0.6, celulas(px / 4.5));
	// O uso: manchas largas, onde o couro gastou e clareou.
	float uso = fbm(px / 90.0);
	float luz = 0.86 + 0.3 * (1.0 - grao) + 0.26 * (uso - 0.5);
	// A lombada é um cilindro: clara a meio da faixa, escura nas bordas, e
	// cortada por quatro nervuras, os relevos das costuras do livro.
	if (px.x < lombada) {
		float t = px.x / lombada;
		luz *= 0.82 + 0.3 * sin(t * 3.14159);
		float fy = fract(px.y / (tamanho.y / 5.0));
		float perto = min(fy, 1.0 - fy);
		luz *= 1.0 + 0.28 * (1.0 - smoothstep(0.0, 0.022, perto));
	}
	// E a borda escurece, onde a capa dobra sobre o cartão.
	luz *= mix(0.78, 1.0, smoothstep(0.0, 6.0, -d));
	COLOR = vec4(base.rgb * luz, base.a * dentro);
}
