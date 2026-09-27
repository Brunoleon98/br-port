// A TINTA DE CANETA (`docs/decisoes/067`, terceira passagem): o tom da letra à
// mão varia ao longo do traço, como a esferográfica que carrega mais num
// sítio e falha noutro. Só MULTIPLICA a cor do rótulo, que continua a vir do
// tema (`TextoCaderno`).
//
// ⚠️ A VARIAÇÃO É LIMITADA DE PROPÓSITO: entre 0,85 e 1,12 da cor. Para o lado
// claro, a tinta a 9,98:1 no creme desce no pior pixel a ~8,8:1 — longe do AA.
shader_type canvas_item;
#include "res://ui/shaders/ruido.gdshaderinc"

void fragment() {
	vec4 t = texture(TEXTURE, UV) * COLOR;
	float n = fbm(FRAGCOORD.xy / 14.0);
	t.rgb *= mix(0.85, 1.12, n);
	COLOR = t;
}
