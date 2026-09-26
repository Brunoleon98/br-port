// A FIBRA DO PAPEL VELHO (`docs/decisoes/067`, terceira passagem): fibras
// curtas, um grão fino e manchas largas amareladas, POR CIMA do creme da
// `CadernoPagina`. É transparente onde não há nada: o papel continua a ser o
// `StyleBoxFlat` do tema, contra o qual o D33 mede a tinta.
//
// ⚠️ O ALFA MÁXIMO É O CONTRATO COM A RÉGUA DO CONTRASTE: o pior pixel
// escurece o creme em `forca` (0,07 por omissão), e a tinta passa de 9,98:1
// a ~9,2:1 lá. Quem subir a força mede outra vez.
shader_type canvas_item;
#include "res://ui/shaders/ruido.gdshaderinc"

uniform vec4 fibra : source_color;
uniform vec4 mancha : source_color;
uniform vec2 tamanho = vec2(600.0, 850.0);
uniform float semente = 1.0;
uniform float forca = 0.07;

void fragment() {
	vec2 px = UV * tamanho + semente * 131.0;
	// Fibras: ruído esticado na horizontal, que o papel tem sentido de fabrico.
	float f = ruido(vec2(px.x / 9.0, px.y / 1.6));
	float fibras = smoothstep(0.78, 0.95, f) * 0.6;
	float grao = step(0.985, hash21(floor(px))) * 0.5;
	float manchas = smoothstep(0.55, 0.85, fbm(px / 160.0));
	vec4 c = mix(fibra, mancha, manchas);
	float a = clamp((fibras + grao) * 0.6 + manchas * 0.8, 0.0, 1.0) * forca;
	COLOR = vec4(c.rgb, a);
}
