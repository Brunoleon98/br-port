extends RefCounted

# ============================================================
# D46 — a água escurece até ao largo (`docs/decisoes/124`)
#
# A queixa do Bruno em 17/10: o mar, «em vez de escurecer ao largo, tem áreas
# ao fundo mais claras, como se fosse mais raso». Medido no mapa, a mediana da
# água descia até ~12 unidades da costa (73) e voltava a subir até 86: o
# degradê do largo ia de um tom para outro MAIS CLARO, e manchas na cor do
# baixio caíam no mar aberto. Nenhuma guarda perguntava pela FORMA da rampa —
# o D21 separa a água costeira do largo num ponto de cada lado, e o mapa
# velho passava nele.
#
# AS PERGUNTAS, e de onde vem o esperado de cada uma:
#
#   §1 nove raios em +mx — do berço de cada doca e de dois vizinhos ao longo
#      do cais —, que começam onde a água costeira acaba (`alcance_costeiro`,
#      publicado pelo gerador, e não escrito aqui); cada um com amostras
#      bastantes para a conta valer, senão os dois parágrafos seguintes
#      passariam sem ter olhado para nada;
#   §2 a inclinação MÉDIA dos raios, nos dois terços de fora, fica abaixo de
#      `INCLINACAO_MAX`: a água escurece para o largo;
#   §3 nenhum raio vê a água clarear mais de `SUBIDA_MAX` acima da mais
#      escura que já atravessou: é a mancha clara solta no mar aberto.
#
# São duas perguntas porque são dois defeitos, e um não apanha o outro — os
# dois estão no catálogo de mutantes. As marolas e as manchas fundas, que são
# o que um raio atravessa de legítimo, cabem nos cortes porque cada amostra é
# a MEDIANA de uma janela, e não um pixel.
#
# Bloco num arquivo próprio pela regra do `AGENTS.md` §2, como o D45.
# ============================================================

## Unidades entre duas amostras de um raio.
const PASSO := 0.5
## Meia janela da amostra, em px de TELA (o `MapaLido` escala).
const JANELA := 4.0
## Medido (`124`), na textura do jogo: o mapa certo dá −0,92 de média nos nove
## raios; o mesmo mapa com o degradê do largo invertido, −0,17; o de antes da
## `124`, +0,76. O corte fica a meio do primeiro par, com 0,37 de folga de cada
## lado — e o par é o que importa, porque com as correntes do largo a descer
## o mapa todo, o degradê invertido já não chega a subir em média.
const INCLINACAO_MAX := -0.55
## Medido (`124`): o pior raio do mapa certo sobe 7,3 — as correntes e as
## manchas fundas que atravessa e de que sai; uma mancha rasa a 18 unidades da
## costa dá 16,4, e o mapa de antes da `124` 26,6. O corte fica a meio do
## primeiro par. O degradê invertido sobe 13,7, e reprova aqui também.
const SUBIDA_MAX := 12.0
## Com menos do que isto, um terço do raio são três amostras e a reta não diz
## nada; o raio mais curto do mapa certo tem 18.
const AMOSTRAS_MIN := 12

var falhas := 0
var completo := false


func conferir(nome: String, ok: bool, detalhe: String = "") -> void:
	if ok:
		print("  PASS  D46: %s" % nome)
	else:
		print("  FALHA D46: %s%s" % [nome, ("  — " + detalhe) if detalhe != "" else ""])
		falhas += 1


func _luz(c: Color) -> float:
	return (0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b) * 255.0


func _mediana(img: Image, centro: Vector2i, r: int) -> float:
	var valores := PackedFloat64Array()
	for dy in range(-r, r + 1):
		for dx in range(-r, r + 1):
			valores.append(_luz(img.get_pixel(centro.x + dx, centro.y + dy)))
	valores.sort()
	return valores[valores.size() / 2]


# A reta dos mínimos quadrados de `ys` contra `xs`, do índice `de` ao fim.
func _inclinacao(xs: PackedFloat64Array, ys: PackedFloat64Array, de: int) -> float:
	var n := float(xs.size() - de)
	var sx := 0.0
	var sy := 0.0
	var sxx := 0.0
	var sxy := 0.0
	for i in range(de, xs.size()):
		sx += xs[i]
		sy += ys[i]
		sxx += xs[i] * xs[i]
		sxy += xs[i] * ys[i]
	return (n * sxy - sx * sy) / (n * sxx - sx * sx)


## `lido` é o `MapaLido` do `teste_design` — a textura que o jogo recebe.
func rodar(lido, ancoras: Dictionary) -> void:
	conferir("o mapa do porto foi lido", lido != null)
	if lido == null:
		return
	var agua: Dictionary = ancoras.get("cores_da_agua", {})
	conferir("a tabela publica onde acaba a água costeira",
		agua.has("alcance_costeiro"))
	if not agua.has("alcance_costeiro"):
		return
	var alcance := float(agua["alcance_costeiro"])
	var proj: Dictionary = ancoras["projecao"]
	var para_o_largo := Vector2(float(proj["meia_larg"]), float(proj["meia_alt"]))
	var ao_longo := Vector2(-float(proj["meia_larg"]), float(proj["meia_alt"]))
	var r := int(lido.dist(JANELA))

	var inclinacoes: Array = []
	var pior_subida := 0.0
	var onde_subiu := ""
	for pier in ancoras["pieres"]:
		for dmy in [-2.0, 0.0, 2.0]:
			var b: Array = pier["barco"]
			var origem: Vector2 = Vector2(float(b[0]), float(b[1])) + ao_longo * float(dmy)
			var ks := PackedFloat64Array()
			var perfil := PackedFloat64Array()
			var k := alcance
			while true:
				var q: Vector2i = lido.pxv(origem + para_o_largo * k)
				if not (lido.dentro(q - Vector2i(r, r)) and lido.dentro(q + Vector2i(r, r))):
					break
				ks.append(k)
				perfil.append(_mediana(lido.img, q, r))
				k += PASSO
			var raio := "doca %d%+.0f" % [int(pier["doca"]), dmy]
			conferir("o raio %s tem amostras para a conta" % raio,
				ks.size() >= AMOSTRAS_MIN, "%d amostras" % ks.size())
			if ks.size() < AMOSTRAS_MIN:
				continue
			inclinacoes.append(_inclinacao(ks, perfil, ks.size() / 3))
			var minimo := INF
			for i in perfil.size():
				minimo = minf(minimo, perfil[i])
				if perfil[i] - minimo > pior_subida:
					pior_subida = perfil[i] - minimo
					onde_subiu = "%s, a %.1f u do berço" % [raio, ks[i]]

	conferir("os nove raios correram", inclinacoes.size() == 9,
		"%d de 9" % inclinacoes.size())
	if inclinacoes.is_empty():
		return
	var media := 0.0
	for v in inclinacoes:
		media += float(v)
	media /= float(inclinacoes.size())
	conferir("a água escurece para o largo", media < INCLINACAO_MAX,
		"a luminância anda %+.2f por unidade, em média, e tem de descer mais de %.2f"
			% [media, -INCLINACAO_MAX])
	conferir("nenhuma mancha clara no mar aberto", pior_subida < SUBIDA_MAX,
		"a água clareia %.1f acima da mais escura já atravessada (%s)"
			% [pior_subida, onde_subiu])
	print("  D46: inclinação média %+.2f, pior subida %.1f (%s)"
		% [media, pior_subida, onde_subiu])
	completo = true
