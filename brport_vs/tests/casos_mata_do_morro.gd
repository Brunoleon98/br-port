extends RefCounted

# ============================================================
# D47 — a mata do morro e a restinga das pontas (`docs/decisoes/126`)
#
# Atrás da vila o chão sobe num morro, e a mata dele são props do Blender por
# cima do mapa, a balançar como os coqueiros — escolha do Bruno em 17/10. Um
# prop por cima do mapa pinta-se por cima de TUDO o que o mapa desenhou, a
# vila incluída: uma árvore mal posta sai com a copa em cima de um telhado, e
# nenhuma guarda anterior perguntava, porque toda a maquinaria de cerco deste
# projeto mede pegada contra faixa e a árvore não tem pegada.
#
# AS PERGUNTAS, e de onde vem o esperado de cada uma:
#
#   §1 a CÓPIA: o `MataNoMapa.ARVORES` que o jogo leva é a lista `mata` da
#      tabela de âncoras, árvore a árvore — o JSON não vai no pacote, e uma
#      cópia que ninguém confere apodrece (a `ObraNoMapa`, D45);
#   §2 os NÓS: o `Cenario` tem uma árvore por entrada, com a textura dela e o
#      pé no sítio da tabela;
#   §3 o CONTORNO: nenhum pixel de árvore do MORRO — sombra incluída — desce
#      abaixo do contorno da vila na coluna dele. Lê o PNG que o jogo
#      carrega, e não o perfil com que o gerador as pôs: o defeito que só
#      esta pergunta vê é a árvore re-renderizada MAIOR com as posições
#      intactas;
#   §3b a RESTINGA: o tronco de cada planta das pontas — o desenho opaco nas
#      colunas do pé — acaba acima da crista que tem à frente (`cristas`, da
#      tabela). Só o tronco: a folha do guriri que se estende pela areia está
#      por cima de chão que lhe fica À FRENTE e mais BAIXO, e isso está certo
#      (o porquê está no gerador, ao lado de `RESTINGA_ESPECIES`);
#   §4 o contorno VÊ A VILA: em cada lote com casa, a coluna do meio do lote
#      tem o contorno acima do telhado — confere o contorno do gerador contra
#      os LOTES, que é outra fonte. Um contorno cego a uma casa deixaria as
#      §3 e o gerador a concordarem num erro;
#   §5 nenhum bicho da fauna — que se desenha DEPOIS do `Cenario` — cai em
#      cima de uma árvore;
#   §6 o BALANÇO: cada árvore tem a sua rajada, gira, e gira em volta do PÉ;
#   §7 nenhuma árvore tapa o desenho OPACO de um prop parado do `Cenario` —
#      a profundidade decidiria quem fica à frente, e decidiria bem, mas uma
#      moita em cima da empilhadeira ou do tronco do coqueiro esconde o que o
#      jogador procura. Os camiões andam e ficam de fora; a sombra também, que
#      é chão.
#
# A ordem de profundidade não está aqui: as árvores são irmãs dos outros
# props, e quem a pergunta é o D3, para todos.
#
# Bloco num arquivo próprio pela regra do `AGENTS.md` §2, como o D45 e o D46.
# ============================================================

const MEIO_QUADRO := 256.0
## Alfa a partir do qual um pixel de árvore conta como desenho. A sombra de
## contato entra (sai a ~0,4), o véu do denoiser fica de fora.
const ALFA_MIN := 0.06
## Mínimo que uma casa sobe acima do chão do MEIO do lote, em px de TELA.
## Medido (`126`), nas 23 casas do quadro: a mais baixa (uma meia-água) sobe
## 26,7; um lote SEM casa sobe 16,8 — a quina de trás a 12,8 acima do meio,
## o muro de 3,3 e o px de folga do contorno. O corte fica a meio.
const CASA_MIN := 21.7
## Quanto uma árvore tem de girar, no máximo da rajada, para contar como
## balanço: metade da amplitude.
const GIRO_MIN := 0.011
## Colunas de PNG com desenho, no mínimo, por árvore. Medido (`126`): a peça
## mais estreita da mata é a moita b, com 32 colunas acima de `ALFA_MIN` (a
## copa pequena tem 53). O corte fica a três quartos dela — abaixo disto a
## guarda não olhou para a árvore.
const COLUNAS_MIN := 24
## Alfa a partir do qual um pixel é DESENHO e não sombra de contato: a
## sombra sai a 0,40–0,45 em todos os props, medido em 17/10 (`126`), e o
## corpo acima de 0,6 — a régua de TAMANHO do `arte.md` corta no mesmo 0,5.
const ALFA_OPACO := 0.5
## Meia largura, em px de TELA, das colunas do tronco que o §3b lê.
const TRONCO := 2.0

var falhas := 0
var completo := false


func conferir(nome: String, ok: bool, detalhe: String = "") -> void:
	if ok:
		print("  PASS  D47: %s" % nome)
	else:
		print("  FALHA D47: %s%s" % [nome, ("  — " + detalhe) if detalhe != "" else ""])
		falhas += 1


## `main` é a cena do jogo montada pelo `teste_design`.
func rodar(main: Node, ancoras: Dictionary) -> void:
	var mata: Array = ancoras.get("mata", [])
	var topo: Array = ancoras.get("horizonte_da_vila", [])
	var cristas: Array = ancoras.get("cristas", [])
	conferir("a tabela publica a mata", not mata.is_empty())
	conferir("a tabela publica o contorno da vila", not topo.is_empty())
	conferir("a tabela publica a crista das duas pontas", cristas.size() == 2,
		"%d cristas" % cristas.size())
	if mata.is_empty() or topo.is_empty() or cristas.size() != 2:
		return
	var lado := int(ancoras["mapa"]["largura"])
	conferir("o contorno tem uma linha por coluna do mapa", topo.size() == lado,
		"%d linhas para %d colunas" % [topo.size(), lado])

	# §1 — a cópia.
	var Mata: Script = load("res://scripts/MataNoMapa.gd")
	var copia: Array = Mata.ARVORES
	conferir("a cópia da mata tem as árvores da tabela", copia.size() == mata.size(),
		"%d na cópia, %d na tabela" % [copia.size(), mata.size()])
	var diverge := ""
	for i in mini(copia.size(), mata.size()):
		var a: Array = copia[i]
		var t: Dictionary = mata[i]
		var pe: Array = t["pe"]
		if String(a[0]) != String(t["arvore"]) \
				or absf(float(a[1]) - float(pe[0])) > 0.05 \
				or absf(float(a[2]) - float(pe[1])) > 0.05:
			diverge = "árvore %d: %s em (%.1f, %.1f) na cópia, %s em (%.1f, %.1f) na tabela" \
				% [i, a[0], float(a[1]), float(a[2]), t["arvore"], float(pe[0]), float(pe[1])]
			break
	conferir("a cópia da mata confere com a tabela", diverge == "", diverge)

	# §2 — os nós.
	var plantio = main.mata
	var nos: Array = plantio.nos()
	conferir("o Cenario tem uma árvore por entrada da cópia", nos.size() == copia.size(),
		"%d nós para %d entradas" % [nos.size(), copia.size()])
	var cenario := main.get_node("MapaWrap/Cenario")
	var fora := ""
	for i in mini(nos.size(), copia.size()):
		var no: TextureRect = nos[i]
		var a: Array = copia[i]
		var esperado := Vector2(float(a[1]), float(a[2]))
		if no.get_parent() != cenario:
			fora = "%s não está no Cenario" % no.name
		elif no.texture != Mata.TEXTURAS[a[0]]:
			fora = "%s não mostra %s" % [no.name, a[0]]
		elif (no.position + Vector2(MEIO_QUADRO, MEIO_QUADRO)).distance_to(esperado) > 0.01:
			fora = "%s tem o pé em %s e a cópia diz %s" \
				% [no.name, no.position + Vector2(MEIO_QUADRO, MEIO_QUADRO), esperado]
		if fora != "":
			break
	conferir("cada árvore é um nó do Cenario, com a sua textura e o pé no sítio", fora == "", fora)

	# §3 — nenhum pixel abaixo do contorno da vila. Por coluna do PNG, o pixel
	# MAIS BAIXO com desenho: é o único que pode atravessar a linha.
	var pior := ""
	var magra := ""
	var do_morro := 0
	var da_restinga := 0
	for i in mini(nos.size(), mata.size()):
		var no: TextureRect = nos[i]
		if String(mata[i].get("chao", "")) != "morro":
			continue
		do_morro += 1
		var tex: Texture2D = (no as TextureRect).texture
		var img := PropIso.imagem(tex)
		var k := PropIso.escala(tex)
		var usado := img.get_used_rect()
		var conferidos := 0
		for px in range(usado.position.x, usado.end.x):
			for py in range(usado.end.y - 1, usado.position.y - 1, -1):
				if img.get_pixel(px, py).a < ALFA_MIN:
					continue
				conferidos += 1
				# A borda de BAIXO do pixel, e as duas colunas do mapa que ele toca.
				var x0: float = (no as Control).position.x + float(px) * k
				var y: float = (no as Control).position.y + float(py + 1) * k
				for c in [floori(x0), floori(x0 + k)]:
					if c >= 0 and c < lado and y > float(topo[c]) and pior == "":
						pior = "%s desce a y=%.1f na coluna %d, e a vila começa em %.1f" \
							% [no.name, y, c, float(topo[c])]
				break
		if conferidos < COLUNAS_MIN and magra == "":
			magra = "%s: %d colunas com desenho" % [no.name, conferidos]
	conferir("a guarda leu as colunas de cada árvore", magra == "", magra)
	conferir("nenhuma árvore pinta por cima da vila", pior == "", pior)

	# §3b — o tronco de cada planta da restinga acima da crista à frente.
	var na_areia := ""
	var sem_tronco := ""
	for i in mini(nos.size(), mata.size()):
		var t: Dictionary = mata[i]
		var chao := String(t.get("chao", ""))
		if chao == "morro":
			continue
		if chao != "restinga":
			na_areia = "%s tem o chão «%s»" % [nos[i].name, chao]
			break
		da_restinga += 1
		var no: TextureRect = nos[i]
		var img := PropIso.imagem(no.texture)
		var k := PropIso.escala(no.texture)
		var pe := no.position + Vector2(MEIO_QUADRO, MEIO_QUADRO)
		# A crista da ponta é a que tem o pé no intervalo de `x` dela: as duas
		# não partilham coluna nenhuma (a norte vai de ~343 a 633, a sul acaba
		# antes de 200).
		var crista: Array = []
		for c in cristas:
			var xs: Array = (c as Array).map(func(q): return float(q[0]))
			if pe.x >= xs.min() and pe.x <= xs.max():
				crista = c
		var lidas := 0
		for px in range(floori((MEIO_QUADRO - TRONCO) / k), ceili((MEIO_QUADRO + TRONCO) / k)):
			for py in range(img.get_height() - 1, -1, -1):
				if img.get_pixel(px, py).a < ALFA_OPACO:
					continue
				lidas += 1
				var x := no.position.x + (float(px) + 0.5) * k
				var y := no.position.y + float(py + 1) * k
				var frente = _crista_a_frente(crista, x, pe.y)
				if (frente == null or y > float(frente)) and na_areia == "":
					na_areia = "%s desce a y=%.1f na coluna %.1f, e a crista à frente está em %s" \
						% [no.name, y, x, frente]
				break
		if lidas == 0 and sem_tronco == "":
			sem_tronco = "%s não tem desenho opaco nas colunas do pé" % no.name
	conferir("a guarda achou árvores nos dois chãos", do_morro >= 10 and da_restinga >= 10,
		"%d no morro, %d na restinga" % [do_morro, da_restinga])
	conferir("cada planta da restinga tem tronco no pé", sem_tronco == "", sem_tronco)
	conferir("nenhuma planta da restinga desce à areia", na_areia == "", na_areia)

	# §4 — o contorno vê cada casa, pela tabela dos LOTES.
	var proj: Dictionary = ancoras["projecao"]
	var ml := float(proj["meia_larg"])
	var ma := float(proj["meia_alt"])
	var cega := ""
	var casas := 0
	for l in ancoras["lotes"]:
		if String(l["casa"]) == "":
			continue
		var canto: Array = l["canto"]
		var dmx := float(l["dmx"])
		var dmy := float(l["dmy"])
		var cx := float(canto[0]) + (dmx - dmy) * 0.5 * ml
		var chao := float(canto[1]) + (dmx + dmy) * 0.5 * ma
		var c := floori(cx)
		if c < 0 or c >= lado or chao < 0.0 or chao > float(lado):
			continue
		casas += 1
		if float(topo[c]) > chao - CASA_MIN and cega == "":
			cega = "o lote em my=%.2f tem o chão do meio em y=%.1f e o contorno em %.1f" \
				% [float(l["my"]), chao, float(topo[c])]
	conferir("a guarda achou casas no quadro", casas >= 10, "%d casas" % casas)
	conferir("o contorno sobe acima de cada casa", cega == "", cega)

	# §5 — a fauna desenha-se depois do Cenario: nenhum bicho em cima de uma copa.
	var bicho_em_cima := ""
	for bicho in main.get_node("MapaWrap/Fauna").get_children():
		var sprite: Sprite2D = null
		for f in bicho.get_children():
			if f is Sprite2D:
				sprite = f
		if sprite == null or sprite.texture == null:
			continue
		# O DESENHO do bicho, e não o quadro: o sprite é centrado num PNG
		# quase todo transparente, e a caixa do quadro tocava meia mata.
		# ⚠️ E PELO `PropIso.imagem()`: o sprite é um `AtlasTexture`, e o
		# `get_image()` dele devolve a REGIÃO com o canto em (0, 0) (`049`).
		# A primeira versão media a caixa 256 px acima e à esquerda do bicho e
		# nunca reprovou nada — quem o disse foi o mutante, que sobreviveu.
		var tam := Vector2(sprite.texture.get_size())
		var usado := Rect2(PropIso.imagem(sprite.texture).get_used_rect())
		var caixa := Rect2((bicho as Node2D).position + sprite.position
				+ (usado.position - tam / 2.0) * sprite.scale,
			usado.size * sprite.scale)
		for no in nos:
			var d := PropIso.desenho((no as TextureRect).texture)
			var r := Rect2((no as Control).position + d.position + Vector2(MEIO_QUADRO, MEIO_QUADRO),
				d.size)
			if r.intersects(caixa) and bicho_em_cima == "":
				bicho_em_cima = "%s (%s) toca %s (%s)" % [bicho.name, caixa, no.name, r]
	conferir("nenhum bicho da fauna cai em cima de uma árvore", bicho_em_cima == "",
		bicho_em_cima)

	# §6 — o balanço: anda-se a rajada de cada árvore e lê-se o NÓ.
	var rajadas: Array = plantio.rajadas()
	conferir("cada árvore tem a sua rajada", rajadas.size() == nos.size(),
		"%d rajadas para %d árvores" % [rajadas.size(), nos.size()])
	var parada := ""
	var desliza := ""
	for i in mini(rajadas.size(), nos.size()):
		var no: Control = nos[i]
		var pe := no.position + Vector2(MEIO_QUADRO, MEIO_QUADRO)
		var maior := 0.0
		var tw: Tween = rajadas[i]
		for _p in 120:
			tw.custom_step(0.05)
			maior = maxf(maior, absf(no.rotation))
			var agora: Vector2 = no.get_transform() * Vector2(MEIO_QUADRO, MEIO_QUADRO)
			if agora.distance_to(pe) > 0.05 and desliza == "":
				desliza = "%s com %.3f rad tem o pé em %s, e não em %s" \
					% [no.name, no.rotation, agora, pe]
		if maior < GIRO_MIN and parada == "":
			parada = "%s girou no máximo %.4f rad em 6 s" % [no.name, maior]
	conferir("a mata balança", parada == "", parada)
	conferir("cada árvore gira em volta do pé", desliza == "", desliza)

	# §7 — nenhuma árvore em cima do desenho opaco de um prop parado.
	var opacos := {}
	var parados := 0
	var tapa := ""
	for outro in cenario.get_children():
		if not (outro is TextureRect) or nos.has(outro) \
				or String(outro.name).begins_with("Caminhao"):
			continue
		parados += 1
		var r_outro := _opaco(outro.texture, opacos)
		if r_outro.size == Vector2.ZERO:
			continue
		r_outro.position += (outro as Control).position
		for no in nos:
			var r_no := _opaco((no as TextureRect).texture, opacos)
			r_no.position += (no as Control).position
			if r_no.intersects(r_outro) and tapa == "":
				tapa = "%s (%s) tapa %s (%s)" % [no.name, r_no, outro.name, r_outro]
	conferir("a guarda achou os props parados", parados >= 20, "%d props" % parados)
	conferir("nenhuma árvore tapa um prop parado", tapa == "", tapa)

	completo = true


## O `y` onde a crista corta a coluna `x` ABAIXO do pé, ou `null` — a mesma
## conta do `crista_a_frente()` do gerador, sobre a polilinha da tabela.
func _crista_a_frente(crista: Array, x: float, y_pe: float):
	var melhor = null
	for i in crista.size() - 1:
		var a: Array = crista[i]
		var b: Array = crista[i + 1]
		var x0 := float(a[0])
		var y0 := float(a[1])
		var x1 := float(b[0])
		var y1 := float(b[1])
		if x1 < x0:
			var tx := x0
			var ty := y0
			x0 = x1
			y0 = y1
			x1 = tx
			y1 = ty
		if x < x0 or x > x1 or x1 == x0:
			continue
		var y := y0 + (y1 - y0) * (x - x0) / (x1 - x0)
		if y >= y_pe - 3.0 and (melhor == null or y < float(melhor)):
			melhor = y
	return melhor


## O retângulo do desenho OPACO de uma textura, em px de TELA a partir do
## canto do nó — sem a sombra de contato. Lido dentro do `get_used_rect()`.
func _opaco(tex: Texture2D, cache: Dictionary) -> Rect2:
	if tex == null:
		return Rect2()
	if cache.has(tex):
		return cache[tex]
	var img := PropIso.imagem(tex)
	var k := PropIso.escala(tex)
	var u := img.get_used_rect()
	var x0 := u.end.x
	var y0 := u.end.y
	var x1 := u.position.x - 1
	var y1 := u.position.y - 1
	for py in range(u.position.y, u.end.y):
		for px in range(u.position.x, u.end.x):
			if img.get_pixel(px, py).a >= ALFA_OPACO:
				x0 = mini(x0, px)
				y0 = mini(y0, py)
				x1 = maxi(x1, px)
				y1 = maxi(y1, py)
	var r := Rect2()
	if x1 >= x0:
		r = Rect2(Vector2(x0, y0) * k, Vector2(x1 - x0 + 1, y1 - y0 + 1) * k)
	cache[tex] = r
	return r
