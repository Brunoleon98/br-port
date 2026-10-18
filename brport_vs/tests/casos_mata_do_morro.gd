extends RefCounted

# ============================================================
# D47 — a mata do morro e a restinga das pontas (`docs/decisoes/127`)
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
#      abaixo do contorno do que lhe fica À FRENTE na coluna dele: as vias e
#      os lotes da vila cujo terreno não fica para trás dela (`130`: por
#      coluna, o contorno da vila inteira era o mínimo, e uma casa lá atrás
#      proibia uma árvore à frente). Lê o PNG que o jogo carrega, e não o
#      perfil com que o gerador as pôs: o defeito que só esta pergunta vê é a
#      árvore re-renderizada MAIOR com as posições intactas;
#   §3b a RESTINGA: o tronco de cada planta das pontas — o desenho opaco nas
#      colunas do pé — acaba acima da crista que tem à frente (`cristas`, da
#      tabela). Só o tronco: a folha do guriri que se estende pela areia está
#      por cima de chão que lhe fica À FRENTE e mais BAIXO, e isso está certo
#      (o porquê está no gerador, ao lado de `RESTINGA_ESPECIES`);
#   §4 o contorno VÊ A VILA: em cada lote com casa, a peça do terreno dele
#      tem, na coluna do meio do lote, o contorno acima do telhado — confere
#      o contorno do gerador contra os LOTES, que é outra fonte. Um contorno
#      cego a uma casa deixaria as §3 e o gerador a concordarem num erro;
#   §5 nenhum bicho da fauna — que se desenha DEPOIS do `Cenario` — cai em
#      cima de uma árvore;
#   §6 o BALANÇO: cada árvore tem a sua rajada, gira, e gira em volta do PÉ;
#   §7 nenhuma árvore tapa o desenho OPACO de um prop parado do `Cenario` —
#      a profundidade decidiria quem fica à frente, e decidiria bem, mas uma
#      moita em cima da empilhadeira ou do tronco do coqueiro esconde o que o
#      jogador procura. Os camiões andam e ficam de fora; a sombra também, que
#      é chão;
#   §3c nenhuma árvore do morro pinta por cima de uma árvore EMBUTIDA do
#      quintal de trás que lhe fica à frente (`130`): o contorno da vila já
#      não conta a orla — por coluna ele é o mínimo, e uma moita ATRÁS
#      proibia uma árvore À FRENTE —, e a orla pergunta-se pela profundidade;
#   §8 nenhuma árvore do morro pinta por cima do GRANITO de uma clareira que
#      lhe fica à frente (`130`): a pedra é desenho do mapa, e a árvore de
#      trás, prop, cairia por cima dela — o contorno da vila não a conhece;
#   §9 nenhuma copa EMBUTIDA pousa no telhado de uma casa (`130`, «árvore no
#      telhado»): no ponto de cima do telhado de cada casa — que a tabela
#      publica do CONTORNO da casa, e não das árvores —, o mapa rasterizado
#      não é verde de copa;
#   §10 cada IPÊ embutido mostra a cor dele (`130`, «ipê escondido»): os pixels
#      de flor no mapa, na janela da copa, são pelo menos metade dos do PNG
#      à escala dele — atrás de uma casa, o ipê inteiro ou nenhum;
#   §11 a copa de cada DESTAQUE que balança — ipê, juçara, embaúba — está À
#      VISTA (`130`, «poucas juçaras e embaúbas»): o `MapaWrap` recorta o que
#      sobe acima do topo do mapa, que fica debaixo da barra do HUD, e metade
#      das juçaras e embaúbas tinha lá a copa inteira. Lê o recorte na CENA e
#      o desenho no PNG, e não o perfil do gerador;
#   §12 nenhuma árvore desenhada DEPOIS de um destaque lhe tapa a copa (`130`):
#      as juçaras jovens nasceram no relvado e as arvoretas plantadas à volta
#      taparam-nas pela frente. Conta, pixel a pixel, quanto do terço de cima
#      do desenho do destaque fica debaixo do desenho de outra árvore.
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
## Medido (`127`), nas 23 casas do quadro: a mais baixa (uma meia-água) sobe
## 26,7; um lote SEM casa sobe 16,8 — a quina de trás a 12,8 acima do meio,
## o muro de 3,3 e o px de folga do contorno. O corte fica a meio.
const CASA_MIN := 21.7
## Quanto uma árvore tem de girar, no máximo da rajada, para contar como
## balanço: metade da amplitude.
const GIRO_MIN := 0.011
## Colunas de PNG com desenho, no mínimo, por árvore. Medido (`127`): a peça
## mais estreita da mata é a moita b, com 32 colunas acima de `ALFA_MIN` (a
## copa pequena tem 53). O corte fica a três quartos dela — abaixo disto a
## guarda não olhou para a árvore.
const COLUNAS_MIN := 24
## Alfa a partir do qual um pixel é DESENHO e não sombra de contato: a
## sombra sai a 0,40–0,45 em todos os props, medido em 17/10 (`127`), e o
## corpo acima de 0,6 — a régua de TAMANHO do `arte.md` corta no mesmo 0,5.
const ALFA_OPACO := 0.5
## Meia largura, em px de TELA, das colunas do tronco que o §3b lê.
const TRONCO := 2.0
## Meia janela, em px de TELA, à volta do ponto do telhado que o §9 lê.
const TELHADO_JANELA := 2.0
## Quanto o verde passa do vermelho e do azul num pixel de COPA. As copas da
## vila e da mata medem 50 a 60 (`copa_esc` #2a6430: 52); o telhado de barro,
## o fibrocimento e a caixa-d'água ficam abaixo de zero.
const VERDE_MIN := 25
## As espécies que são DESTAQUE na mata (§11, §12): o nome da variante sem a
## letra do porte.
const DESTAQUES := ["arvore_ipe_amarelo", "arvore_ipe_rosa", "arvore_jucara", "arvore_embauba"]
## Quanto o desenho de um destaque pode subir acima do recorte do mapa, em px
## de TELA (§11): a ponta de uma folha, e não a copa.
const COPA_SOB_A_BARRA := 12.0
## A parte de cima do desenho de um destaque que conta como copa (§12).
const COPA_DO_DESTAQUE := 0.40
## A fração da copa de um destaque que outra árvore pode tapar (§12). Medido
## (`130`): no mapa certo a pior é o ipê amarelo da borda, a 63% — atrás da
## embaúba —, e o defeito que a pergunta nasceu a caçar, a embaúba atrás do
## ipê, dava 90%. O corte vai a meio. ⚠️ A guarda defende «a copa não some
## quase toda»; os 63% do ipê ficam registados, e não são verdes por ela.
const COPA_TAPADA_MAX := 0.76

var falhas := 0
var completo := false


func conferir(nome: String, ok: bool, detalhe: String = "") -> void:
	if ok:
		print("  PASS  D47: %s" % nome)
	else:
		print("  FALHA D47: %s%s" % [nome, ("  — " + detalhe) if detalhe != "" else ""])
		falhas += 1


## `main` é a cena do jogo montada pelo `teste_design`; `lido` é o mapa do
## porto rasterizado (o `MapaLido` dele), para as perguntas ao DESENHO.
func rodar(main: Node, ancoras: Dictionary, lido = null) -> void:
	var mata: Array = ancoras.get("mata", [])
	var vias: Array = ancoras.get("horizonte_das_vias", [])
	var pecas: Array = ancoras.get("pecas_da_vila", [])
	var cristas: Array = ancoras.get("cristas", [])
	conferir("a tabela publica a mata", not mata.is_empty())
	conferir("a tabela publica o contorno das vias e o de cada lote",
		not vias.is_empty() and pecas.size() >= 10, "%d lotes" % pecas.size())
	conferir("a tabela publica a crista das duas pontas", cristas.size() == 2,
		"%d cristas" % cristas.size())
	if mata.is_empty() or vias.is_empty() or pecas.is_empty() or cristas.size() != 2:
		return
	var lado := int(ancoras["mapa"]["largura"])
	conferir("o contorno tem uma linha por coluna do mapa", vias.size() == lado,
		"%d linhas para %d colunas" % [vias.size(), lado])

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
		var topo := _a_frente(vias, pecas, float(mata[i]["mx"]), float(mata[i]["my"]))
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
						pior = "%s desce a y=%.1f na coluna %d, e a vila à frente dela começa em %.1f" \
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
		# A peça do terreno que contém o meio do lote.
		var mmx := float(l["mx"]) + dmx * 0.5
		var mmy := float(l["my"]) + dmy * 0.5
		var linha := INF
		for pc in pecas:
			var cx_: Array = pc["caixa"]
			if mmx < float(cx_[0]) or mmx > float(cx_[1]) or mmy < float(cx_[2]) or mmy > float(cx_[3]):
				continue
			var j := c - int(pc["x0"])
			if j >= 0 and j < (pc["topo"] as Array).size():
				linha = minf(linha, float(pc["topo"][j]))
		if linha > chao - CASA_MIN and cega == "":
			cega = "o lote em my=%.2f tem o chão do meio em y=%.1f e o contorno do terreno em %.1f" \
				% [float(l["my"]), chao, linha]
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

	# §8 — o granito à frente. Por coluna do PNG, do pixel mais alto ao mais
	# baixo com desenho: a árvore cai sobre a pedra se essa faixa a cruza.
	var pedras: Array = ancoras.get("pedras_do_morro", [])
	conferir("a tabela publica as pedras do morro", not pedras.is_empty())
	var sobre_pedra := ""
	for i in mini(nos.size(), mata.size()):
		var t: Dictionary = mata[i]
		if String(t.get("chao", "")) != "morro" or sobre_pedra != "":
			continue
		var prof := float(t["mx"]) + float(t["my"])
		var no: TextureRect = nos[i]
		var img := PropIso.imagem(no.texture)
		var k := PropIso.escala(no.texture)
		var usado := img.get_used_rect()
		for pd in pedras:
			if float(pd["prof"]) <= prof or sobre_pedra != "":
				continue
			for px in range(usado.position.x, usado.end.x):
				var x0: float = no.position.x + float(px) * k
				if x0 + k < float(pd["x0"]) or x0 > float(pd["x1"]):
					continue
				var cima := INF
				var baixo := -INF
				for py in range(usado.position.y, usado.end.y):
					if img.get_pixel(px, py).a >= ALFA_MIN:
						cima = minf(cima, no.position.y + float(py) * k)
						baixo = maxf(baixo, no.position.y + float(py + 1) * k)
				if baixo > float(pd["y0"]) and cima < float(pd["y1"]):
					sobre_pedra = "%s (prof. %.2f) desce a y=%.1f na coluna %.1f, sobre a pedra de prof. %.2f que começa em y=%.1f" \
						% [no.name, prof, baixo, x0, float(pd["prof"]), float(pd["y0"])]
					break
	conferir("nenhuma árvore pinta por cima de uma pedra à frente", sobre_pedra == "",
		sobre_pedra)

	# §3c — a orla embutida à frente. As colunas de cada embutida do quintal,
	# lidas no PNG dela à escala do `<use>`, e as de cada árvore do morro.
	var orla: Array = []
	for e in ancoras.get("arvores_embutidas", []):
		if String(e.get("chao", "")) != "quintal":
			continue
		var tex_e: Texture2D = load("res://art/props/%s.png" % String(e["arvore"]))
		orla.append([_colunas(tex_e, Vector2(float(e["pe"][0]), float(e["pe"][1])),
			float(e["escala"])), float(e["prof"])])
	conferir("a tabela publica a orla embutida, com a profundidade", not orla.is_empty())
	var sobre_orla := ""
	for i in mini(nos.size(), mata.size()):
		var t: Dictionary = mata[i]
		if String(t.get("chao", "")) != "morro" or sobre_orla != "":
			continue
		var prof := float(t["mx"]) + float(t["my"])
		var no: TextureRect = nos[i]
		var minhas := _colunas(no.texture, no.position + Vector2(MEIO_QUADRO, MEIO_QUADRO), 1.0)
		for o in orla:
			if float(o[1]) <= prof or sobre_orla != "":
				continue
			var delas: Dictionary = o[0]
			for c in minhas:
				if not delas.has(c):
					continue
				var a: Vector2 = minhas[c]
				var b: Vector2 = delas[c]
				if a.y > b.x and a.x < b.y:
					sobre_orla = "%s (prof. %.2f) desce a y=%.1f na coluna %d, sobre a embutida de prof. %.2f que começa em y=%.1f" \
						% [no.name, prof, a.y, c, float(o[1]), b.x]
					break
	conferir("nenhuma árvore pinta por cima de uma embutida à frente", sobre_orla == "",
		sobre_orla)

	if lido == null:
		conferir("o D47 recebeu o mapa rasterizado", false)
		return

	# §9 — nenhuma copa embutida em cima de um telhado: a janela à volta do
	# ponto de cima do telhado de cada casa não é, na maior parte, verde.
	var no_telhado := ""
	var telhados := 0
	var r9 := int(ceil(lido.dist(TELHADO_JANELA)))
	for l in ancoras["lotes"]:
		if String(l["casa"]) == "" or String(l["tipo"]) != "" or not l.has("telhado"):
			continue
		var q: Vector2i = lido.px(float(l["telhado"][0]), float(l["telhado"][1]))
		if not (lido.dentro(q - Vector2i(r9, r9)) and lido.dentro(q + Vector2i(r9, r9))):
			continue
		telhados += 1
		var verdes := 0
		var todos := 0
		for dy in range(-r9, r9 + 1):
			for dx in range(-r9, r9 + 1):
				var c: Color = lido.img.get_pixelv(q + Vector2i(dx, dy))
				todos += 1
				if c.g8 - maxi(c.r8, c.b8) > VERDE_MIN:
					verdes += 1
		if float(verdes) > 0.5 * float(todos) and no_telhado == "":
			no_telhado = "a casa do lote em my=%.2f tem %d de %d pixels verdes no telhado" \
				% [float(l["my"]), verdes, todos]
	conferir("a guarda achou telhados no quadro", telhados >= 10, "%d telhados" % telhados)
	conferir("nenhuma copa embutida pousa num telhado", no_telhado == "", no_telhado)

	# §10 — o ipê embutido vê-se: a flor dele no mapa contra a do PNG.
	var escondido := ""
	var ipes := 0
	for e in ancoras.get("arvores_embutidas", []):
		var nome := String(e["arvore"])
		if not nome.begins_with("arvore_ipe"):
			continue
		var pe := Vector2(float(e["pe"][0]), float(e["pe"][1]))
		var esc := float(e["escala"])
		var tex: Texture2D = load("res://art/props/%s.png" % nome)
		var img := PropIso.imagem(tex)
		var k := PropIso.escala(tex)
		var usado := img.get_used_rect()
		var no_png := 0
		for py in range(usado.position.y, usado.end.y):
			for px in range(usado.position.x, usado.end.x):
				var c: Color = img.get_pixel(px, py)
				if c.a >= ALFA_OPACO and _flor(c, nome):
					no_png += 1
		# Do PNG para o mapa: um px do PNG vale `k · esc` de TELA, e a
		# imagem do mapa tem `lido.escala` px por px de TELA.
		var passo: float = float(k) * esc * float(lido.escala)
		var esperado: float = float(no_png) * passo * passo
		var a: Vector2i = lido.pxv(pe + (Vector2(usado.position) * k - Vector2(MEIO_QUADRO, MEIO_QUADRO)) * esc)
		var b: Vector2i = lido.pxv(pe + (Vector2(usado.end) * k - Vector2(MEIO_QUADRO, MEIO_QUADRO)) * esc)
		if not (lido.dentro(a) and lido.dentro(b)):
			continue
		ipes += 1
		var no_mapa := 0
		for y in range(a.y, b.y + 1):
			for x in range(a.x, b.x + 1):
				if _flor(lido.img.get_pixel(x, y), nome):
					no_mapa += 1
		if float(no_mapa) < 0.5 * esperado and escondido == "":
			escondido = "%s em %s mostra %d pixels de flor, de %.0f à escala %.2f" \
				% [nome, pe, no_mapa, esperado, esc]
	conferir("a guarda achou ipês embutidos", ipes >= 1, "%d ipês" % ipes)
	conferir("nenhum ipê embutido fica escondido", escondido == "", escondido)

	# §11 — a copa de cada destaque abaixo do recorte do mapa.
	var mapa_wrap: Control = main.get_node("MapaWrap")
	conferir("o mapa recorta o que sobe acima dele", mapa_wrap.clip_contents)
	var destaques: Array[int] = []
	for i in mini(nos.size(), copia.size()):
		var v := String(copia[i][0])
		if v.left(v.length() - 2) in DESTAQUES or v in DESTAQUES:
			destaques.append(i)
	conferir("a guarda achou destaques na mata", destaques.size() >= 6,
		"%d destaques" % destaques.size())
	var cache_opaco := {}
	var sob_a_barra := ""
	for i in destaques:
		var no: TextureRect = nos[i]
		var r := _opaco(no.texture, cache_opaco)
		var topo := no.position.y + r.position.y
		if topo < -COPA_SOB_A_BARRA and sob_a_barra == "":
			sob_a_barra = "%s (%s) tem o desenho a começar em y=%.1f, acima do recorte do mapa" \
				% [no.name, copia[i][0], topo]
	conferir("a copa de cada destaque fica à vista", sob_a_barra == "", sob_a_barra)

	# §12 — nenhuma árvore desenhada depois tapa a copa de um destaque.
	var pior_tapa := 0.0
	var tapada := ""
	for i in destaques:
		var no: TextureRect = nos[i]
		var copa := _celulas(no, 0.0, COPA_DO_DESTAQUE)
		if copa.is_empty():
			continue
		var caixa := _opaco(no.texture, cache_opaco)
		caixa.position += no.position
		var tapadas := {}
		for j in nos.size():
			var outro: TextureRect = nos[j]
			if outro == no or outro.get_index() < no.get_index():
				continue
			var r := _opaco(outro.texture, cache_opaco)
			r.position += outro.position
			if not r.intersects(caixa):
				continue
			for c in _celulas(outro, 0.0, 1.0):
				if copa.has(c):
					tapadas[c] = true
		var fracao := float(tapadas.size()) / float(copa.size())
		if fracao > pior_tapa:
			pior_tapa = fracao
			tapada = "%s (%s): %.0f%% da copa debaixo de outra árvore" \
				% [no.name, copia[i][0], 100.0 * fracao]
	conferir("nenhuma árvore tapa a copa de um destaque", pior_tapa <= COPA_TAPADA_MAX, tapada)

	completo = true


## O contorno do que fica À FRENTE do ponto (mx, my) do chão: as vias, e os
## lotes de que o ponto não passa do fim em `mx` nem em `my` — a regra do eixo
## que separa, a mesma do `lote_a_frente()` do gerador.
func _a_frente(vias: Array, pecas: Array, mx: float, my: float) -> Array:
	var topo := vias.duplicate()
	for pc in pecas:
		var cx_: Array = pc["caixa"]
		if mx >= float(cx_[1]) or my >= float(cx_[3]):
			continue
		var x0 := int(pc["x0"])
		var linha: Array = pc["topo"]
		for j in linha.size():
			if float(linha[j]) < float(topo[x0 + j]):
				topo[x0 + j] = linha[j]
	return topo


## {coluna de TELA: Vector2(cima, baixo)} do desenho de uma árvore com o pé
## em `pe` e na escala `esc` (1 num prop; a do `<use>` numa embutida).
func _colunas(tex: Texture2D, pe: Vector2, esc: float) -> Dictionary:
	var img := PropIso.imagem(tex)
	var k := PropIso.escala(tex) * esc
	var usado := img.get_used_rect()
	var cols := {}
	for px in range(usado.position.x, usado.end.x):
		var cima := INF
		var baixo := -INF
		for py in range(usado.position.y, usado.end.y):
			if img.get_pixel(px, py).a >= ALFA_MIN:
				cima = minf(cima, pe.y + (float(py) - MEIO_QUADRO / PropIso.escala(tex)) * k)
				baixo = maxf(baixo, pe.y + (float(py + 1) - MEIO_QUADRO / PropIso.escala(tex)) * k)
		if cima == INF:
			continue
		var x0 := pe.x + (float(px) - MEIO_QUADRO / PropIso.escala(tex)) * k
		for c in range(floori(x0), floori(x0 + k) + 1):
			if cols.has(c):
				var v: Vector2 = cols[c]
				cols[c] = Vector2(minf(v.x, cima), maxf(v.y, baixo))
			else:
				cols[c] = Vector2(cima, baixo)
	return cols


## Pixel de FLOR de ipê: o amarelo (vermelho e verde altos, azul baixo) ou o
## rosa (vermelho alto, azul acima do verde). A copa verde, o telhado de
## barro e o relvado não passam em nenhum dos dois.
func _flor(c: Color, nome: String) -> bool:
	if nome.ends_with("amarelo"):
		return c.r8 > 170 and c.g8 > 120 and c.b8 < 110 and c.r8 - c.b8 > 90
	return c.r8 > 170 and c.b8 > 110 and c.b8 > c.g8 + 10


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


## As células de TELA (px inteiros do mapa) do desenho OPACO de uma árvore,
## na faixa de alturas [de, ate] do desenho — 0 é o topo dele, 1 o pé.
func _celulas(no: TextureRect, de: float, ate: float) -> Dictionary:
	var img := PropIso.imagem(no.texture)
	var k := PropIso.escala(no.texture)
	var u := img.get_used_rect()
	var y0 := u.end.y
	var y1 := u.position.y - 1
	for py in range(u.position.y, u.end.y):
		for px in range(u.position.x, u.end.x):
			if img.get_pixel(px, py).a >= ALFA_OPACO:
				y0 = mini(y0, py)
				y1 = maxi(y1, py)
				break
	var cel := {}
	if y1 < y0:
		return cel
	var lo := float(y0) + de * float(y1 - y0 + 1)
	var hi := float(y0) + ate * float(y1 - y0 + 1)
	for py in range(y0, y1 + 1):
		if float(py) < lo or float(py) >= hi:
			continue
		for px in range(u.position.x, u.end.x):
			if img.get_pixel(px, py).a >= ALFA_OPACO:
				cel[Vector2i(floori(no.position.x + float(px) * k),
					floori(no.position.y + float(py) * k))] = true
	return cel


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
