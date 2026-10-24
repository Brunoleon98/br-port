shader_type canvas_item;

// O MOBILIÁRIO ATRÁS DA VILA (`140`, quinta passagem): *«veja as sombras dos
// postes, pois parecem estar sobrepondo edifícios, como a igreja»*. A vila é
// o MAPA, um fundo chapado, e um poste — com a sombra de contacto que o PNG
// traz — pinta-se por cima de todo ele, mesmo do lote que lhe fica À FRENTE.
// Este shader apaga o que da peça cai abaixo do topo desse lote, coluna a
// coluna de tela: o `teto` sai do contorno de cada lote (`pecas_da_vila`,
// `130`), pela conta do `gerar_mapa_iso.mascara_da_vila()`, e o
// `ObraNoMapa.gd` copia-o. É a regra da fiação (`_tapume()`), no PNG.

// A primeira coluna de tela do `teto`, e o canto do nó no espaço do mapa:
// o `VERTEX` é local, e o contorno é do mapa.
uniform float x0 = 0.0;
uniform vec2 origem = vec2(0.0);
// O `y` de tela de cima do que fica à frente, por coluna; 720 (o fundo do
// mapa) onde nada fica. São `2·MASCARA_LADO + 1` colunas.
uniform float teto[81];

varying vec2 mapa;

void vertex() {
	mapa = VERTEX + origem;
}

void fragment() {
	vec4 cor = texture(TEXTURE, UV) * COLOR;
	int c = int(floor(mapa.x - x0));
	if (c >= 0 && c < 81 && mapa.y >= teto[c]) {
		cor.a = 0.0;
	}
	COLOR = cor;
}
