extends RefCounted

# ============================================================
# D49 — as estradas: o que a obra do pátio troca, as juntas e a borda norte
# (`docs/decisoes/136`)
#
# O mapa do porto em ruínas leva a rua GASTA e o do pátio pronto a RECAPEADA,
# e a obra do pátio troca uma pela outra um trecho por dia (`ObraNoMapa.gd`).
# O Bruno escreveu, ao escolher o escopo: *«as sinalizações aparecem do nada
# depois de atualizar o pátio»*. Medido na `main` de 18/10, 26.901 px mudavam
# entre os dois mapas FORA do recorte da obra — a linha central e as zebras,
# que só o pavimentado tinha, e a viela e os quintais da vila, que trocavam de
# cor —, e trocavam todos de uma vez no dia em que a obra acabava.
#
# AS PERGUNTAS, e de onde vem o esperado de cada uma:
#
#   §1 tudo o que muda entre os dois mapas, lidos pela textura do jogo, cai
#      dentro do que a obra recorta: o pátio inteiro e todos os trechos da
#      rua, pelas funções do `ObraNoMapa.gd` — que é o que o jogo mostra —, e
#      não pela tabela de âncoras, que o D45 confere contra elas;
#   §2 a junta de cada cotovelo com a reta seguinte não tem FIO CLARO: as
#      duas peças só se encostavam, e a calçada de baixo vazava num fio de
#      +25 a +30 de luminância atravessado na pista, nos dois mapas — a
#      «linha fina diagonal junto do coqueiro sul» da `130`;
#   §3 a borda norte do pátio não deixa ver a ÁGUA: o chão da praia acabava
#      onde o porto começa, e fechava inclinado pela crista, e o fundo do
#      mapa via-se num fio azul de um pixel — anotado também na `130`. E a
#      QUINA dela (`142`): o percurso da borda acaba 0,4 antes do cais, e a
#      fresta de 2 px entre a crista, a rampa e a laje, onde o pátio, o
#      relvado e o cais se encontram, viveu ali até à `142` — o «fio
#      diagonal da ponta norte» que a `124` deixou por olhar.
#
# §2 e §3 são defeitos CORRIGIDOS, e os dois estão no catálogo de mutantes
# com a linha de antes da correção. Bloco num arquivo próprio pela regra do
# `AGENTS.md` §2, como o D45.
# ============================================================

## Diferença mínima, num canal de 0 a 255, para um pixel contar como mudado.
const DIFERENCA := 8
## Folga, em px de TELA, em volta de cada recorte: o antisserrilhado da borda
## do pátio e a faixa do avental, que é traço de 2,5 px de desenho.
const FOLGA := 1.4
## Medido (`136`): 5 px fora no mapa certo, 26.901 na `main` de 18/10, e a
## viela sozinha (o mutante) dá 12.280. Uma dúzia de pixels de borda pode
## sobrar sem querer dizer nada; cinquenta já é um traço inteiro.
const FORA_MAX := 50
## E a régua tem de ter visto mudança: com os mapas iguais ela passaria a
## contar zero fora de graça. O pátio sozinho são dezenas de milhares.
const MUDADOS_MIN := 20000
## Medido (`136`), na textura do jogo: o pior fio na junta é +30 sem a costura
## (+30,8 com o mutante) e 0 a +3,8 com ela. O corte fica a meio.
const FIO_MAX := 16.0
## Medido (`136`): o azul da borda norte (B − média de R e G) é +90,5 com o
## fio, e sem ele −22,5 na terra e +17,5 no pavimentado — o cinzento-azulado
## do pátio. O corte fica a meio dos dois últimos com o primeiro.
const AZUL_MAX := 54.0

var falhas := 0
var completo := false


func conferir(nome: String, ok: bool, detalhe: String = "") -> void:
	if ok:
		print("  PASS  D49: %s" % nome)
	else:
		print("  FALHA D49: %s%s" % [nome, ("  — " + detalhe) if detalhe != "" else ""])
		falhas += 1


func rodar(terra, patio, ancoras: Dictionary, obra: Script) -> void:
	if terra == null or patio == null:
		conferir("os dois mapas abrem", false)
		return
	_tudo_dentro_da_obra(terra, patio, obra)
	for par in [["terra", terra], ["pavimentado", patio]]:
		_juntas_sem_fio(String(par[0]), par[1], ancoras)
		_borda_norte(String(par[0]), par[1], ancoras)
		_quina_norte(String(par[0]), par[1], ancoras)
	completo = true


# ── §1 ─────────────────────────────────────────────────────────────────────
func _tudo_dentro_da_obra(terra, patio, obra: Script) -> void:
	var a: Image = terra.img
	var b: Image = patio.img
	conferir("os dois mapas têm o mesmo tamanho", a.get_size() == b.get_size())
	if a.get_size() != b.get_size():
		return
	if a.get_format() != Image.FORMAT_RGBA8:
		a = a.duplicate()
		a.convert(Image.FORMAT_RGBA8)
	if b.get_format() != Image.FORMAT_RGBA8:
		b = b.duplicate()
		b.convert(Image.FORMAT_RGBA8)
	# Os recortes da obra INTEIRA, como o jogo os desenha: o pátio todo e a rua
	# toda, na tela, levados à régua da imagem.
	var dias := int((obra.get_script_constant_map()["CANTEIRO"] as Array).size())
	var recortes: Array = []
	for pol in obra.poligonos_do_asfalto(1.0):
		recortes.append(pol)
	for pol in obra.poligonos_da_rua(dias, true):
		recortes.append(pol)
	conferir("a obra recorta o pátio e a rua (%d recortes)" % recortes.size(),
		recortes.size() > 3)
	var escala: float = terra.escala
	var caixas: Array = []
	var na_imagem: Array = []
	for pol in recortes:
		var pts := PackedVector2Array()
		for v in pol:
			pts.append((v as Vector2) * escala)
		na_imagem.append(pts)
		var caixa := Rect2(pts[0], Vector2.ZERO)
		for v in pts:
			caixa = caixa.expand(v)
		caixas.append(caixa.grow(FOLGA * escala + 1.0))
	var da := a.get_data()
	var db := b.get_data()
	var w := a.get_width()
	var mudados := 0
	var fora := 0
	var primeiro := ""
	for i in range(0, da.size(), 4):
		if absi(da[i] - db[i]) <= DIFERENCA and absi(da[i + 1] - db[i + 1]) <= DIFERENCA \
				and absi(da[i + 2] - db[i + 2]) <= DIFERENCA:
			continue
		mudados += 1
		var k := i / 4
		var p := Vector2(k % w + 0.5, k / w + 0.5)
		if _no_recorte(p, na_imagem, caixas, FOLGA * escala):
			continue
		fora += 1
		if primeiro == "":
			primeiro = "o pixel (%d, %d) — tela (%.0f, %.0f) — muda e não é da obra" \
				% [int(p.x), int(p.y), p.x / escala, p.y / escala]
	conferir("os dois mapas diferem (%d px mudados): a régua viu a obra" % mudados,
		mudados >= MUDADOS_MIN)
	conferir("nada muda entre os dois mapas fora da obra (%d px fora, o máximo é %d)"
		% [fora, FORA_MAX], fora <= FORA_MAX, primeiro)


func _no_recorte(p: Vector2, pols: Array, caixas: Array, folga: float) -> bool:
	for j in range(pols.size()):
		if not (caixas[j] as Rect2).has_point(p):
			continue
		var pol: PackedVector2Array = pols[j]
		if Geometry2D.is_point_in_polygon(p, pol):
			return true
		for k in range(pol.size()):
			var q := Geometry2D.get_closest_point_to_segment(p, pol[k], pol[(k + 1) % pol.size()])
			if q.distance_to(p) <= folga:
				return true
	return false


# ── §2 ─────────────────────────────────────────────────────────────────────
## Atravessa a junta de cada cotovelo com a reta de baixo, nas duas faixas de
## rodagem (fora do eixo, que a linha central cruza, e longe do meio-fio), e
## compara a linha da junta com o asfalto dos dois lados dela.
func _juntas_sem_fio(nome: String, mapa, ancoras: Dictionary) -> void:
	var pr: Dictionary = ancoras["projecao"]
	var pior := -INF
	var onde := ""
	var lidas := 0
	for c in ancoras["cotovelos"]:
		var mx1 := float(c["asfalto_mx"][1])
		var myb := float(c["asfalto_my"][1])
		for o in [0.3, 0.45, 0.6, 1.2, 1.35, 1.5]:
			var mx := mx1 - float(ancoras["faixas"][0]["asfalto"][1]) \
				+ float(ancoras["faixas"][0]["asfalto"][0]) + float(o)
			var centro: Vector2i = mapa.pxv(_tela(pr, mx, myb))
			if not mapa.dentro(centro):
				continue
			lidas += 1
			var linha := -INF
			for d in [-0.03, -0.015, 0.0, 0.015, 0.03]:
				linha = maxf(linha, _lum(mapa, _tela(pr, mx, myb + float(d))))
			var lados := -INF
			for d in [-0.2, -0.15, -0.1, 0.1, 0.15, 0.2]:
				lados = maxf(lados, _lum(mapa, _tela(pr, mx, myb + float(d))))
			if linha - lados > pior:
				pior = linha - lados
				onde = "na junta em my %.1f, mx %.2f" % [myb, mx]
	conferir("%s: as juntas dos cotovelos à vista foram lidas (%d)" % [nome, lidas], lidas >= 12)
	conferir("%s: nenhuma junta de cotovelo tem fio claro (pior %+.1f, o máximo é %+.1f)"
		% [nome, pior, FIO_MAX], pior <= FIO_MAX, onde)


# ── §3 ─────────────────────────────────────────────────────────────────────
## Percorre a borda norte do primeiro trecho do pátio, da calçada até antes da
## crista da praia, numa faixa de ±0,1 em `my`, e mede quanto azul aparece.
func _borda_norte(nome: String, mapa, ancoras: Dictionary) -> void:
	var pr: Dictionary = ancoras["projecao"]
	var patio: Dictionary = ancoras["patio"][0]
	var my0 := float(patio["my"][0])
	var pior := -INF
	var onde := ""
	var lidas := 0
	var mx := float(patio["mx"][0]) + 0.1
	while mx < float(patio["mx"][1]) - 0.4:
		for k in range(-25, 26):
			var q: Vector2i = mapa.pxv(_tela(pr, mx, my0 + k * 0.004))
			if not mapa.dentro(q):
				continue
			lidas += 1
			var c: Color = mapa.img.get_pixelv(q)
			var azul := (c.b - (c.r + c.g) / 2.0) * 255.0
			if azul > pior:
				pior = azul
				onde = "em mx %.1f, my %.3f, %s" % [mx, my0 + k * 0.004, c.to_html(false)]
		mx += 0.1
	conferir("%s: a borda norte do pátio foi lida (%d amostras)" % [nome, lidas], lidas >= 500)
	conferir("%s: a água não aparece na borda norte do pátio (azul %+.1f, o máximo é %+.1f)"
		% [nome, pior, AZUL_MAX], pior <= AZUL_MAX, onde)


## A quina nordeste do pátio, à altura do cais: uma janela de `QUINA_RAIO` px
## de tela à volta dela. Medido (`142`): +84,5 com a fresta, +10,5 na terra e
## +17,0 no pavimentado sem ela; o corte é o mesmo da borda.
const QUINA_RAIO := 6.0


func _quina_norte(nome: String, mapa, ancoras: Dictionary) -> void:
	var pr: Dictionary = ancoras["projecao"]
	var patio: Dictionary = ancoras["patio"][0]
	var q := _tela(pr, float(patio["mx"][1]), float(patio["my"][0]))
	var a: Vector2i = mapa.pxv(q - Vector2(QUINA_RAIO, QUINA_RAIO))
	var b: Vector2i = mapa.pxv(q + Vector2(QUINA_RAIO, QUINA_RAIO))
	var pior := -INF
	var onde := ""
	var lidas := 0
	for y in range(a.y, b.y + 1):
		for x in range(a.x, b.x + 1):
			var v := Vector2i(x, y)
			if not mapa.dentro(v):
				continue
			lidas += 1
			var c: Color = mapa.img.get_pixelv(v)
			var azul := (c.b - (c.r + c.g) / 2.0) * 255.0
			if azul > pior:
				pior = azul
				onde = "no pixel %s, %s" % [v, c.to_html(false)]
	conferir("%s: a quina norte do pátio foi lida (%d px)" % [nome, lidas],
		lidas >= int(mapa.area(QUINA_RAIO * QUINA_RAIO * 3.0)))
	conferir("%s: a água não aparece na quina norte do pátio (azul %+.1f, o máximo é %+.1f)"
		% [nome, pior, AZUL_MAX], pior <= AZUL_MAX, onde)


func _lum(mapa, p: Vector2) -> float:
	var c: Color = mapa.img.get_pixelv(mapa.pxv(p))
	return (0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b) * 255.0


func _tela(pr: Dictionary, mx: float, my: float) -> Vector2:
	return Vector2(float(pr["cx"]) + (mx - my) * float(pr["meia_larg"]),
		float(pr["cy"]) + (mx + my) * float(pr["meia_alt"]) - float(pr["alt_cais"]))
