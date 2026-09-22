extends SceneTree

# ============================================================
# BR Port VS — TESTE DE DESIGN
#
# A suíte de `run_tests.gd` pergunta "o jogo funciona?". Esta pergunta outra
# coisa: **está tudo no lugar certo?** São dois tipos de erro que nunca
# quebram teste de lógica nenhum e que já custaram três rodadas de trabalho
# neste projeto:
#
# 1. ENCAIXE NO MUNDO. O mapa é gerado a partir de coordenadas de mundo; os
#    props são postos no Main.tscn por offset de TELA. Nada obrigava os dois a
#    concordarem, e quando discordam o píer renderizado pousa ao lado do píer
#    desenhado. O gerador agora exporta `porto_mapa_ancoras.json` e aqui se
#    confere prop por prop contra ele.
#
# 2. LAYOUT DA INTERFACE. Nó que estoura a viewport, dois painéis do rodapé
#    que se sobrepõem, alvo de toque menor que o dedo. Tudo isto é invisível
#    para quem lê o código e óbvio para quem olha a tela — e olhar a tela é
#    justamente o que não acontece a cada commit.
#
# Rodar:
#   Godot --headless --path brport_vs --script res://tests/teste_design.gd
# ============================================================

const ANCORAS := "res://art/porto_mapa_ancoras.json"
const CENA := "res://scenes/Main.tscn"

# O quadro de todo prop isométrico tem 512 COORDENADAS e o centro dele é a
# origem do mundo (ver `para_pixel` em tools/gerar_props_iso.py).
#
# ⚠️ E ELE JÁ NÃO É METADE DA TEXTURA. Este número serve a `no.position +
# MEIO_QUADRO`, que é a âncora do prop no MAPA — coordenada de nó, e é isso que
# ele continua a ser. Desde a alavanca B a textura tem 768 px (`029`), logo
# metade DELA é 384, e o `_desenho_dos_caminhoes()` aqui abaixo usava este
# mesmo 256 para o outro lado da conta. Eram dois números iguais medidos de
# sítios diferentes, que é a armadilha que o `vaos_da_vila()` já registou.
# Quem traduz um no outro é o `PropIso`, num lugar só.
const MEIO_QUADRO := PropIso.MEIO

# Meia célula do chão. Mais que isto e o prop já se lê deslocado do desenho.
const TOLERANCIA_PX := 2.0

# Onde um caminhão é DESENHADO dentro do quadro de 512, relativo ao ponto de
# ancoragem. O quadro inteiro tem 512px e o desenho ocupa ~70x64 no meio dele:
# perguntar se o QUADRO saiu do mapa daria "ainda dentro" com o caminhão já
# invisível havia muito.
#
# ⚠️ ELE DEIXOU DE SER UMA CONSTANTE EM 07/09, e a razão está escrita na que
# ele substitui: "constante medida num sprite é constante que envelhece quando
# o sprite é regerado". Era `Rect2(-26,-31,67,58)`, o alfa dos DOIS PNGs unido,
# e já tinha envelhecido uma vez com a câmera de 05/09. Com quatro cargas em
# duas orientações seriam oito PNGs de tamanhos diferentes a caber numa
# medida só — e a boa é a maior, que ninguém saberia qual é.
#
# Agora ela mede-se: `_desenho_dos_caminhoes()` une o `get_used_rect()` dos
# oito. É a mesma regra que o D7 aprendeu do outro lado — encaixe mede-se
# contra `get_used_rect()`, nunca contra o quadro, que é igual em todos os
# props e não sabe nada sobre nenhum.
func _desenho_dos_caminhoes(tela: Control) -> Rect2:
	var consts: Dictionary = tela.get_script().get_script_constant_map()
	var uniao := Rect2()
	var primeiro := true
	for motivo in (consts["CAMINHOES"] as Dictionary).values():
		for tex in (motivo as Dictionary).values():
			var caixa := PropIso.desenho(tex as Texture2D)
			uniao = caixa if primeiro else uniao.merge(caixa)
			primeiro = false
	return uniao

# Alvo de toque mínimo. 44 é o piso das diretrizes de iOS e Android; abaixo
# disso o polegar erra e o jogador acha que o jogo não respondeu.
const TOQUE_MIN := 44.0

# A cor de aviso do `Main.gd`. Repetida aqui porque o teste roda o jogo POR
# FORA e não alcança a constante da cena — se ela mudar lá, este número tem de
# mudar junto, e é a asserção do D9 que o denuncia.
const COR_AVISO := Color(0.851, 0.467, 0.024)

var _falhas := 0
var _feito := false
var _ancoras: Dictionary
var _main: Control
var _d9_completo := false
var _d10_completo := false
var _d11_completo := false
var _d12_completo := false
var _d13_completo := false
var _d15_completo := false
var _d16_completo := false
var _d17_completo := false
var _d18_completo := false
var _d19_completo := false
var _d20_completo := false
var _d21_completo := false
var _d22_completo := false
var _d23_completo := false
var _d24_completo := false
var _d25_completo := false
var _d26_completo := false
var _d27_completo := false
var _d28_completo := false


func _confere(rotulo: String, ok: bool, detalhe: String = "") -> void:
	if ok:
		print("  PASS  %s" % rotulo)
	else:
		print("  FALHA %s%s" % [rotulo, ("  — " + detalhe) if detalhe != "" else ""])
		_falhas += 1


func _process(_delta: float) -> bool:
	if _feito:
		return true
	_feito = true
	_rodar()
	return true


func _rodar() -> void:
	var f := FileAccess.open(ANCORAS, FileAccess.READ)
	if f == null:
		print("FALHA: %s nao existe. Rode tools/gerar_mapa_iso.py." % ANCORAS)
		quit(1)
		return
	var lido = JSON.parse_string(f.get_as_text())
	f.close()
	if typeof(lido) != TYPE_DICTIONARY:
		print("FALHA: %s nao e um JSON de objeto." % ANCORAS)
		quit(1)
		return
	_ancoras = lido

	_main = load(CENA).instantiate()
	root.add_child(_main)

	print("=== D1: props ancorados onde o mapa os desenha ===")
	_d1_encaixe_das_docas()
	print("=== D2: cenário em terra, e não em cima da rua ===")
	_d2_cenario_em_terra()
	print("=== D3: ordem dos nós = profundidade isométrica ===")
	_d3_profundidade()
	print("=== D4: nada estoura a viewport ===")
	_d4_dentro_da_tela()
	print("=== D5: o rodapé não se sobrepõe ===")
	_d5_sem_sobreposicao()
	print("=== D6: alvo de toque cabe no dedo ===")
	_d6_alvos_de_toque()
	print("=== D8: o pipeline BRP concorda com a projeção do mapa ===")
	_d8_contrato_brp()
	print("=== D9: trabalho parado avisa onde se resolve ===")
	_d9_aviso_de_trabalho_parado()
	_confere("o bloco D9 correu até ao fim", _d9_completo)

	print("=== D10: tocar no dinheiro abre o resumo do dia ===")
	_d10_toque_no_caixa()
	_confere("o bloco D10 correu até ao fim", _d10_completo)

	print("=== D11: os outros tres chips do HUD tambem abrem o deles ===")
	_d11_toque_nos_outros_chips()
	_confere("o bloco D11 correu até ao fim", _d11_completo)

	print("=== D12: o cartao da parcela convida e abre ===")
	_d12_toque_na_parcela()
	_confere("o bloco D12 correu até ao fim", _d12_completo)

	print("=== D13: o caminhao atravessa o mapa, de fora a fora, no asfalto ===")
	_d13_travessia_do_caminhao()
	_confere("o bloco D13 correu até ao fim", _d13_completo)

	print("=== D14: a vila cabe no lote dela, e sai de baixo dos prédios ===")
	_d14_vila()
	_confere("o bloco D14 correu até ao fim", _d14_completo)

	print("=== D15: as duas pontas de areia, e quem pode pisá-las ===")
	_d15_praias()
	_confere("o bloco D15 correu até ao fim", _d15_completo)

	print("=== D16: o mundo transborda o quadro pelos quatro lados ===")
	_d16_bordas_do_mundo()
	_confere("o bloco D16 correu até ao fim", _d16_completo)

	print("=== D17: os três níveis do píer e da lança ===")
	_d17_niveis_do_porto()
	_confere("o bloco D17 correu até ao fim", _d17_completo)

	print("=== D18: o texto do cartão de doca cabe no cartão ===")
	_d18_texto_do_cartao()
	_confere("o bloco D18 correu até ao fim", _d18_completo)

	print("=== D19: o texto do painel Construir passa a WCAG no branco ===")
	_d19_contraste_do_painel()
	_confere("o bloco D19 correu até ao fim", _d19_completo)

	print("=== D20: a pista é pista no desenho, do começo ao fim da rota ===")
	_d20_a_rua_no_desenho()
	_confere("o bloco D20 correu até ao fim", _d20_completo)

	print("=== D21: quem espera fundeia AO LARGO, quem atraca fica na costeira ===")
	_d21_a_zona_de_espera()
	_confere("o bloco D21 correu até ao fim", _d21_completo)

	print("=== D22: a narração de fim de fase cabe sem rolar ===")
	_d22_narracao_cabe()
	_confere("o bloco D22 correu até ao fim", _d22_completo)

	print("=== D24: a igreja, a praça e a obra chegaram ao DESENHO da vila ===")
	_d24_a_vila_cresce()
	_confere("o bloco D24 correu até ao fim", _d24_completo)

	print("=== D25: a fauna cabe na régua do próprio jogo ===")
	_d25_escala_da_fauna()
	_confere("o bloco D25 correu até ao fim", _d25_completo)

	print("=== D26: a fauna aparece, vive e sai do mundo ===")
	_d26_ciclo_da_fauna()
	_confere("o bloco D26 correu até ao fim", _d26_completo)

	print("=== D27: cada animal nasce no habitat que lhe pertence ===")
	_d27_habitats_da_fauna()
	_confere("o bloco D27 correu até ao fim", _d27_completo)

	print("=== D28: as duas pontas são costa desenhada, e o cais é reto ===")
	_d28_contorno_das_pontas()
	_confere("o bloco D28 correu até ao fim", _d28_completo)

	print("=== D29: o casco de um navio não tem bordo reto ===")
	_d29_linha_de_fundo_do_casco()
	_confere("o bloco D29 correu até ao fim", _d29_completo)

	print("=== D30: peça co-ancorada encaixa na que está por cima ===")
	_d30_pecas_co_ancoradas()
	_confere("o bloco D30 correu até ao fim", _d30_completo)

	print("=== D31: quem mostra um prop reconcilia os pixels com as coordenadas ===")
	_d31_quadro_de_quem_mostra()
	_confere("o bloco D31 correu até ao fim", _d31_completo)

	print("=== D23: o menu-celular — o que ele custou ao rodapé e o que se lê dentro ===")
	_d23_menu_celular()
	_confere("o bloco D23 correu até ao fim", _d23_completo)

	print("=== D32: a faixa de mensagem com fila — contador legível e faixa tocável ===")
	_d32_faixa_de_mensagem()
	_confere("o bloco D32 correu até ao fim", _d32_completo)

	root.remove_child(_main)
	_main.free()

	# ⚠️ DEPOIS DE O `_main` SAIR, e de propósito: este bloco monta o `Main`
	# ele próprio, em dois estados, e dois `Main` na mesma árvore disputam o
	# `GameState` — o segundo herdaria o porto do primeiro.
	print("=== D33: o contraste EFETIVO de toda a interface, painel a painel ===")
	_d33_contraste_efetivo()
	_confere("o bloco D33 correu até ao fim", _d33_completo)

	print("")
	if _falhas == 0:
		print("=== DESIGN OK — tudo no lugar ===")
		quit(0)
	else:
		print("=== %d PROBLEMA(S) DE DESIGN ===" % _falhas)
		quit(1)


# ── D15 ── as duas pontas de areia
#
# ⚠️ ESTE BLOCO NASCEU COM UM DEFEITO JÁ COMETIDO. Assim que as praias
# existiram, a empilhadeira e um contêiner do pátio ficaram em cima da
# restinga da ponta sul — equipamento de porto pousado na praia — e as catorze
# asserções do D2 disseram todas PASS, porque para elas aquilo continuava a
# ser "terra fora do asfalto". É a mesma forma do buraco de 02/09: uma faixa
# nova no mapa que nenhum teste lê.
#
# São três perguntas:
#
#   1. NINGUÉM pisa a AREIA. Nem o coqueiro: a rampa desce até a água, e um
#      prop plantado nela fica com o pé no ar;
#   2. só quem é da praia fica no `my` de uma praia. Coqueiro pode (a
#      referência pede "pedras e coqueiros"); empilhadeira, palete, pilha de
#      caixotes e contêiner, não;
#   3. cada ponta tem costa VISÍVEL que chegue. É a lição da mata de 04/09
#      posta como asserção: `PONTA_SUL = 24` (o degrau seguinte, que parecia o
#      corte natural) derruba a costa visível de 233 para 49 px, porque é ali
#      que ela sai do quadro — e nada, sem isto, o diria.
const PRAIA_SO_PARA := ["Coqueiro"]

# Medido em 04/09: a ponta norte tem 139 px de costa dentro do quadro e a sul
# 233. O piso é generoso de propósito — ele existe para pegar uma praia que
# saiu do ecrã, não para congelar os números de hoje.
const COSTA_MINIMA_PX := 100.0


func _d15_praias() -> void:
	var praias: Array = _ancoras.get("praias", [])
	_confere("a tabela de âncoras publica as praias", not praias.is_empty(),
		"sem praias não há o que conferir — o gerador deixou de as publicar?")
	if praias.is_empty():
		return

	var alt := float(_ancoras["projecao"]["alt_cais"])
	var pegadas: Dictionary = _ancoras.get("pegadas", {})
	for no in _main.get_node("MapaWrap/Cenario").get_children():
		if not (no is TextureRect):
			continue
		var nome := String(no.name)
		if _comeca_com_algum(nome, VIVEM_NA_AGUA):
			continue
		var m := _mundo(_origem(no as Control), alt)
		var pegada: Array = pegadas.get(_id_do_prop((no as TextureRect).texture), [])
		var meia_x: float = (float(pegada[0]) / 2.0) if not pegada.is_empty() else 0.0
		var meia_y: float = (float(pegada[1]) / 2.0) if not pegada.is_empty() else 0.0
		for praia in praias:
			var lim: Array = praia["my"]
			# INTERSEÇÃO DE INTERVALOS, como no D2: a pegada de um prop pode
			# atravessar a fronteira da praia sem ter a âncora lá dentro.
			if m.y + meia_y <= float(lim[0]) or m.y - meia_y >= float(lim[1]):
				continue
			var borda := float(_faixa_de(m.y)["borda"])
			var areia0: float = borda - float(praia["recuo"])
			var na_areia: bool = m.x + meia_x > areia0 and m.x - meia_x < borda
			_confere("%s fora da areia" % nome, not na_areia,
				"a pegada ocupa mx %.2f..%.2f e a areia %.2f..%.2f"
				% [m.x - meia_x, m.x + meia_x, areia0, borda])
			_confere("%s pode ficar na ponta de praia" % nome,
				_comeca_com_algum(nome, PRAIA_SO_PARA),
				"está em my=%.2f, dentro da praia %.1f..%.1f — equipamento de "
				% [m.y, float(lim[0]), float(lim[1])]
				+ "porto não fica onde o porto acabou")

	# (3) a praia aparece? Anda-se a linha de água do trecho e mede-se quanto
	# dela cai dentro da janela que o jogador vê — que é o `MapaWrap`, e não o
	# PNG: o mapa tem 720 de altura e a janela corta em 660.
	var janela := (_main.get_node("MapaWrap") as Control).size
	for praia in praias:
		var lim: Array = praia["my"]
		var visivel := 0.0
		var ant := Vector2.INF
		var my: float = float(lim[0])
		while my <= float(lim[1]):
			var faixa := _faixa_de(my)
			var ponto := _tela(float(faixa["borda"]), my, 0.0)
			var dentro: bool = (ponto.x >= 0.0 and ponto.x <= janela.x
				and ponto.y >= 0.0 and ponto.y <= janela.y)
			if dentro and ant != Vector2.INF:
				visivel += ponto.distance_to(ant)
			ant = ponto if dentro else Vector2.INF
			my += 0.05
		_confere("a praia %.1f..%.1f aparece na tela" % [float(lim[0]), float(lim[1])],
			visivel >= COSTA_MINIMA_PX,
			"só %.0f px de costa dentro da janela, e o piso é %.0f"
			% [visivel, COSTA_MINIMA_PX])
	_d15_completo = true


# ── D16 ── o mundo transborda o quadro
#
# O cabeçalho de `gerar_mapa_iso.py` promete isto com todas as letras — "a
# saída é gerar o mundo MAIOR que o ecrã e cortar: o mapa transborda dos
# quatro lados e o jogador vê uma janela para dentro dele" — e até 05/09 nada
# o verificava. Ficou caro: com a câmera afastada para os 20 escolhidos em
# 03/09, o mundo passou a acabar DENTRO do quadro por três lados diferentes,
# 626 px de fronteira à vista, e a única maneira de o saber era gerar o mapa e
# olhar. A terceira dessas fronteiras — a ponta NORTE — nem sequer estava na
# lista de trabalho, porque a medição à mão de 03/09 só contava o canto
# superior esquerdo.
#
# São as três que existem, e cada uma sai por um canto:
#
#   fundo   `mx = FUNDO_TERRA`, onde a terra acaba — canto superior esquerdo;
#   norte   `my` do primeiro degrau, onde a costa começa — superior direito;
#   sul     `my` do último, onde ela acaba — inferior esquerdo.
#
# O canto inferior DIREITO é mar aberto de propósito e não se confere: ali o
# vazio é o oceano, e a leitura das referências pede-o ("a água ocupa perto de
# metade do quadro, e a maior parte dela é água aberta sem nada").
#
# ⚠️ A JANELA É O `MapaWrap`, e não o PNG. São 660 de altura contra 720 — os
# 60 de baixo nunca aparecem, e conferir contra eles deixaria passar uma
# fronteira visível.
func _d16_bordas_do_mundo() -> void:
	var pr: Dictionary = _ancoras["projecao"]
	_confere("a tabela de âncoras publica o fundo da terra",
		pr.has("fundo_terra"),
		"sem ele não há como saber onde o mundo acaba para trás")
	if not pr.has("fundo_terra"):
		return

	var faixas: Array = _ancoras["faixas"]
	var fundo := float(pr["fundo_terra"])
	var alt := float(pr["alt_cais"])
	var janela := (_main.get_node("MapaWrap") as Control).size
	var primeira: Dictionary = faixas[0]
	var ultima: Dictionary = faixas[faixas.size() - 1]
	var my_n := float((primeira["my"] as Array)[0])
	var my_s := float((ultima["my"] as Array)[1])

	for caso in [
		["o fundo da terra (mx=%.0f)" % fundo,
			Vector2(fundo, my_n), Vector2(fundo, my_s)],
		["o começo da costa (my=%.0f)" % my_n,
			Vector2(fundo, my_n), Vector2(float(primeira["borda"]), my_n)],
		["o fim da costa (my=%.0f)" % my_s,
			Vector2(fundo, my_s), Vector2(float(ultima["borda"]), my_s)],
	]:
		var visivel := _linha_no_quadro(caso[1], caso[2], alt, janela)
		_confere("%s fica fora do quadro" % caso[0], visivel < 1.0,
			"%.0f px dela caem dentro da janela — o jogador vê o mapa ACABAR"
			% visivel)
	_d16_completo = true


# Quantos pixels do segmento de mundo (a -> b), à altura `alt`, caem dentro da
# janela. Mesmo método do D15, que mede a costa visível de cada praia.
func _linha_no_quadro(a: Vector2, b: Vector2, alt: float,
		janela: Vector2) -> float:
	var visivel := 0.0
	var ant := Vector2.INF
	var passos := 1200
	for i in range(passos + 1):
		var m := a.lerp(b, float(i) / passos)
		var ponto := _tela(m.x, m.y, alt)
		var dentro: bool = (ponto.x >= 0.0 and ponto.x <= janela.x
			and ponto.y >= 0.0 and ponto.y <= janela.y)
		if dentro and ant != Vector2.INF:
			visivel += ponto.distance_to(ant)
		ant = ponto if dentro else Vector2.INF
	return visivel


# ── D17 ── os três níveis do píer e da lança
#
# O GDD 7 pede três níveis para grua e cais, e a arte deles existe antes da
# mecânica — como a vila, que cresce por `--nivel-vila=N`. Isso cria uma
# armadilha que não existia enquanto havia uma lança só:
#
# **O `pivot_offset` do nó `Lanca` é UM para as três.** Ele nomeia o topo da
# torre, e a torre vive dentro do PÍER; uma lança construída a partir de outro
# topo desprende-se dela ao girar, e o defeito só aparece a meio de uma varrida
# — nunca numa captura parada. Aqui exige-se que o pivô caia dentro do desenho
# de cada uma das três: uma lança que não cubra o próprio centro de rotação
# gira em torno de um ponto fora dela.
#
# E exige-se também que os três níveis EXISTAM e sejam distintos: dois arquivos
# iguais passariam em tudo o resto e o jogador nunca veria o porto evoluir.
const NIVEIS := 3

# O raio e o piso da pergunta "há desenho no centro de rotação?" — ver o
# comentário na asserção que os usa.
const RAIO_PIVO := 2
const PISO_PIVO := 0.35

# ⚠️ E O PIVÔ VEM DO NÓ, A IMAGEM É A TEXTURA. O `pivot_offset` está em
# coordenadas do `Lanca` (512 de lado); desde a alavanca B a textura tem 768,
# e sondá-la no pixel 293 seria sondar um ponto a dois terços do caminho para
# o topo da torre. A janela escala com o fator pela mesma razão — ela pergunta
# quanto desenho há à volta de uma ÁREA do desenho, e o `_densidade_no_pivo`
# devolve uma FRAÇÃO, que já normaliza a área: escala-se o raio e o piso fica.
func _pivo_na_textura(tex: Texture2D, pivo: Vector2) -> Vector2i:
	return Vector2i((pivo / PropIso.escala(tex)).round())


func _raio_na_textura(tex: Texture2D) -> int:
	return int(round(float(RAIO_PIVO) / PropIso.escala(tex)))


func _densidade_no_pivo(img: Image, pivo: Vector2i, raio: int) -> float:
	var opacos := 0
	var total := 0
	for dy in range(-raio, raio + 1):
		for dx in range(-raio, raio + 1):
			if dx * dx + dy * dy > raio * raio:
				continue
			total += 1
			var p := pivo + Vector2i(dx, dy)
			if p.x < 0 or p.y < 0 or p.x >= img.get_width() or p.y >= img.get_height():
				continue
			if img.get_pixelv(p).a > 0.5:
				opacos += 1
	return float(opacos) / float(total)


func _d17_niveis_do_porto() -> void:
	var doca := _main.get_node_or_null("MapaWrap/Docas/Doca0")
	if doca == null:
		_confere("há uma doca para conferir os níveis", false)
		return
	var lanca := doca.get_node_or_null("Lanca") as Control
	if lanca == null:
		_confere("a doca tem nó Lanca", false)
		return
	var pivo := lanca.pivot_offset

	var consts: Dictionary = doca.get_script().get_script_constant_map()
	for chave in ["ArtePier", "ArteLanca"]:
		var lista: Array = consts[chave]
		_confere("%s declara os %d níveis" % [chave, NIVEIS],
			lista.size() == NIVEIS, "declara %d" % lista.size())
	var lancas: Array = consts["ArteLanca"]
	var vistos: Array = []
	for i in range(lancas.size()):
		var img := (lancas[i] as Texture2D).get_image()
		var usado := img.get_used_rect()
		var pivo_tex := _pivo_na_textura(lancas[i] as Texture2D, pivo)
		var raio_tex := _raio_na_textura(lancas[i] as Texture2D)
		# O pivô é o topo da torre, e a torre está no PÍER. A lança tem de o
		# cobrir, senão gira em torno de um ponto que não lhe pertence.
		_confere("a lança do nível %d cobre o pivô %s" % [i + 1, pivo],
			usado.has_point(pivo_tex),
			"o desenho dela ocupa %s" % usado)
		# ⚠️ E A CAIXA NÃO É O DESENHO — a asserção acima prometia por escrito
		# "que o pivô caia dentro do DESENHO" e media `used_rect`, que é a
		# moldura. Numa lança isso quase não custa nada: o amantilho e o cabo
		# de carga são linhas finas que ESTICAM a caixa muito além da peça, e
		# uma lança inteira construída a partir de outro topo de torre continua
		# a ter o pivô dentro da moldura enquanto uma corda qualquer passar por
		# cima dele. É a mesma forma do D7 ("conferir o QUADRO de um prop não é
		# conferir o PROP") e da regra dos quatro cantos.
		#
		# A pergunta certa é quanto DESENHO há à volta do centro de rotação.
		# Medido em 08/09: n1 100%, n2 62%, n3 54% num raio de 2 px — as duas
		# treliças ficam abaixo de 100% porque o pixel exato do pivô calha num
		# vazado, que é legítimo. O piso é generoso de propósito: ele existe
		# para pegar uma lança desenhada FORA do próprio eixo, não para
		# congelar os números de hoje.
		_confere("a lança do nível %d tem desenho À VOLTA do pivô" % [i + 1],
			_densidade_no_pivo(img, pivo_tex, raio_tex) >= PISO_PIVO,
			"só %.0f%% dos pixels num raio de %d px de tela estão desenhados"
				% [100.0 * _densidade_no_pivo(img, pivo_tex, raio_tex),
				   RAIO_PIVO])
		# Níveis iguais não são níveis. Compara-se a caixa desenhada, que é o
		# que o jogador vê mudar — não os bytes, que mudam por ruído.
		_confere("o nível %d da lança é distinto dos anteriores" % [i + 1],
			not vistos.has(usado), "tem o mesmo desenho %s de outro nível" % usado)
		vistos.append(usado)

	# ⚠️ E O LADO DA TORRE, QUE ESTE BLOCO NÃO CONFERIA. As três asserções
	# acima olham para a LANÇA e exigem que ela cubra o pivô; nenhuma perguntava
	# se a TORRE — que vive no píer — chega lá. Enquanto os três píeres
	# partilhavam a mesma torre isso não podia falhar, e por isso não se notou
	# a falta. Assim que cada nível ganhou torre própria, passou a haver três
	# maneiras de a lança girar em torno do vazio, e nenhuma delas dava erro:
	# a captura mostra o guindaste parado, e parado ele parece inteiro.
	#
	# É a mesma forma do buraco que o `barco_medio` abriu logo abaixo — uma
	# metade do par verificada e a outra não.
	var pieres: Array = consts["ArtePier"]
	var caixas_pier: Array = []
	for i in range(pieres.size()):
		var img_p := (pieres[i] as Texture2D).get_image()
		var usado_p := img_p.get_used_rect()
		var pivo_p := _pivo_na_textura(pieres[i] as Texture2D, pivo)
		_confere("a torre do píer nível %d alcança o pivô %s" % [i + 1, pivo],
			usado_p.has_point(pivo_p)
				and img_p.get_pixelv(pivo_p).a > 0.5,
			"o desenho ocupa %s e o alfa no pivô é %.2f"
				% [usado_p, img_p.get_pixelv(pivo_p).a])
		_confere("o nível %d do píer é distinto dos anteriores" % [i + 1],
			not caixas_pier.has(usado_p),
			"tem o mesmo desenho %s de outro nível" % usado_p)
		caixas_pier.append(usado_p)

	# ── e os CASCOS, um por CLASSE de navio.
	#
	# ⚠️ O `barco_medio` ESTEVE GERADO E SEM USO em doca nenhuma até 05/09: o
	# jogo escolhia entre dois cascos por um booleano, e o terceiro só aparecia
	# como enfeite na Zona de Espera. Passou pelo `asset_validator`, pelo
	# manifest e por cinco suítes sem que nada notasse — porque nenhuma delas
	# perguntava se o que se GERA chega à tela. Esta asserção pergunta.
	#
	# ⚠️ E ELA PERCORRE A TABELA, nunca uma lista escrita à mão: uma classe de
	# navio nova sem casco tem de reprovar aqui, e uma lista cravada seria a
	# `ORDEM_DE_COMPRA` do simulador outra vez — a estrutura entra, ninguém a
	# percorre, e a suíte diz que está tudo bem.
	# ⚠️ E DESDE 07/09 A PERGUNTA É PELO PAR (CLASSE, MOTIVO). O casco passou a
	# dizer o que o navio TRAZ, e o par que o jogo consegue sortear é a tabela
	# de motivos DENTRO de cada classe — percorrê-la é o que faz um motivo novo
	# numa classe reprovar aqui em vez de rebentar em jogo, quando
	# `arte_do_barco()` for indexado com uma chave que não existe.
	# ⚠️ E DESDE 08/09 HÁ UM TERCEIRO EIXO: o PORTE. A frota de pesca deixou de
	# ser um barco só, e cada folha da tabela passou a ser uma LISTA ordenada
	# do menor para o maior — quem escolhe entre eles é o VALOR do contrato
	# (`docs/decisoes/014`). Percorrer só o par (classe, motivo) deixaria dois
	# dos três barcos de pesca por conferir, que é o buraco do `barco_medio`
	# num eixo novo.
	var GS: Node = root.get_node("GameState")
	var por_arquivo := {}          # caminho -> caixa desenhada
	var classes_do_arquivo := {}   # caminho -> quantas classes o usam
	for classe in GS.CLASSES_DE_NAVIO:
		var da_classe := {}
		var dados: Dictionary = GS.CLASSES_DE_NAVIO[classe]
		for motivo in dados["motivos"]:
			var portes = doca.get_script().get_script_constant_map()["CASCOS"] \
				[classe][motivo]
			_confere("a classe %s com motivo %s tem uma folha de cascos"
					% [classe, motivo],
				portes is Array and not (portes as Array).is_empty())
			if not (portes is Array) or (portes as Array).is_empty():
				continue

			# A folha inteira é a chave da partilha: o que a afirmação do
			# pesqueiro diz é que os dois motivos dele levam OS MESMOS TRÊS
			# barcos, não que levam um barco igual cada.
			var folha := ""
			var caminhos := {}
			for tex in portes:
				var caminho: String = (tex as Texture2D).resource_path
				folha += caminho + "|"
				caminhos[caminho] = true
				por_arquivo[caminho] = tex as Texture2D
				if not classes_do_arquivo.has(caminho):
					classes_do_arquivo[caminho] = {}
				classes_do_arquivo[caminho][classe] = true
			da_classe[folha] = true

			# ⚠️ E DOIS PORTES DA MESMA FOLHA NÃO PODEM SER O MESMO ARQUIVO.
			# Ali em cima, dois MOTIVOS a partilharem um casco é uma afirmação
			# sobre o destino da carga; aqui dentro, dois PORTES a partilharem
			# um desenho não afirma nada — é uma faixa de valor que existe na
			# tabela e não existe na tela. E é também o que faz o `find()` do
			# bloco seguinte poder responder.
			_confere("a folha de %s/%s não repete arquivo (%d porte(s))"
					% [classe, motivo, (portes as Array).size()],
				caminhos.size() == (portes as Array).size(),
				"%d arquivos para %d portes"
					% [caminhos.size(), (portes as Array).size()])

			# ⚠️ TODO PORTE TEM DE SER ALCANÇÁVEL PELA FAIXA DE VALOR DA
			# CLASSE, e a pergunta faz-se pela PORTA QUE O JOGO USA — o
			# `arte_do_barco()` com um valor, e não a conta da faixa sozinha.
			# Um porte que nenhum contrato alcance é o `barco_medio` outra vez:
			# desenhado, validado, e em doca nenhuma. Aqui isso não daria nem
			# erro — daria uma linha a mais numa lista.
			#
			# ⚠️ E A ORDEM É PARTE DA AFIRMAÇÃO. A folha vai do menor para o
			# maior porque a leitura é "o contrato maior traz o barco maior";
			# uma conta que devolvesse os portes fora de ordem cumpriria a
			# alcançabilidade e inverteria o sentido, sem uma asserção acima a
			# reparar. São duas perguntas, e nenhuma implica a outra.
			var vmin: int = int(dados["valor_min"])
			var vmax: int = int(dados["valor_max"])
			var portes_vistos := {}
			var anterior := -1
			var desordem := ""
			for valor in range(vmin, vmax + 1):
				var tex = doca.call("arte_do_barco", String(classe),
					String(motivo), valor)
				var idx: int = (portes as Array).find(tex)
				portes_vistos[idx] = true
				if idx < anterior and desordem == "":
					desordem = "em R$%d o porte cai de %d para %d" \
						% [valor, anterior + 1, idx + 1]
				anterior = idx
			_confere("os %d porte(s) de %s/%s saem todos na faixa R$%d–%d"
					% [(portes as Array).size(), classe, motivo, vmin, vmax],
				portes_vistos.size() == (portes as Array).size(),
				"só %d deles chegam a sair" % portes_vistos.size())
			_confere("o porte de %s/%s cresce com o valor do contrato"
					% [classe, motivo],
				desordem == "", desordem)

		# ⚠️ PARTILHA TOTAL OU NENHUMA, e é esta a asserção que distingue a
		# decisão do descuido. O pesqueiro usa a MESMA folha nos dois motivos
		# dele de propósito: pescado e armazenagem são o mesmo peixe indo para
		# o mercado ou para a câmara, e o barco não muda com o destino da
		# carga. Um cargueiro que apontasse dois serviços para o mesmo PNG
		# seria copiar-colar — e as duas coisas leem-se igual numa tabela.
		# Exigir 1 ou N separa-as: partilhar é uma afirmação sobre a CLASSE
		# inteira, nunca sobre um par de motivos.
		var motivos: Dictionary = dados["motivos"]
		_confere("a classe %s tem uma folha por motivo, ou uma só para todos"
				% classe,
			da_classe.size() == 1 or da_classe.size() == motivos.size(),
			"tem %d folhas para %d motivos — dois motivos a partilhar um "
				% [da_classe.size(), motivos.size()]
				+ "desenho e outros não é copiar-colar, não é decisão")

	# Nenhum casco atravessa classes: o porte tem de se ler antes do serviço.
	for caminho in classes_do_arquivo:
		_confere("%s é de uma classe só" % String(caminho).get_file(),
			(classes_do_arquivo[caminho] as Dictionary).size() == 1,
			"é usado por %s" % [(classes_do_arquivo[caminho] as Dictionary).keys()])

	# E dois ARQUIVOS diferentes não podem ter o mesmo desenho: seria o
	# `barco_medio` outra vez — arte gerada, validada, e sem nada a dizer.
	var repetido := _repetido_entre(por_arquivo.values())
	_confere("os %d cascos declarados têm desenhos distintos" % por_arquivo.size(),
		repetido == "", repetido)
	_d17_completo = true


# ── DOIS PROPS SÃO O MESMO DESENHO? ─────────────────────────────────────
#
# ⚠️ A CAIXA DESENHADA NÃO É O DESENHO, e esta asserção nasceu a acreditar que
# fosse. Até 06/09 ela comparava `get_used_rect()`, e funcionava por acidente:
# os três cascos eram de portes diferentes, então caixas diferentes. Assim que
# os cascos passaram a partilhar o costado e a mudar só o CONVÉS, o
# porta-contêineres e o graneleiro médios deram exatamente a mesma caixa — 97
# x 83 no mesmo sítio — e o teste reprovou dois desenhos que são bem
# distintos. É a irmã da lição do D7: conferir o quadro de um prop não é
# conferir o prop, e a caixa dele também não.
#
# ⚠️ E TAMBÉM NÃO SE COMPARAM OS BYTES. O `CLAUDE.md` mede-o: o denoiser do
# Cycles varia ±2/255 em algumas dezenas de pixels entre corridas, e os props
# que não levam sombra composta ainda trazem um carimbo de data do Blender —
# `cmp` num prop responde "mudou" sempre.
#
# O que sobra é reduzir os dois a 16x16 e comparar. Cada célula é a média de
# ~1.000 pixels, o que apaga o ruído do denoiser por construção, e um convés
# trocado move várias células muito acima do piso.
const ASSINATURA := 16
const ASSINATURA_MIN := 0.02      # 5/255 — bem acima dos ±2/255 do denoiser


func _assinatura(tex: Texture2D) -> PackedFloat32Array:
	var img := (tex.get_image() as Image).duplicate() as Image
	img.resize(ASSINATURA, ASSINATURA, Image.INTERPOLATE_BILINEAR)
	var v := PackedFloat32Array()
	for y in range(ASSINATURA):
		for x in range(ASSINATURA):
			var c := img.get_pixel(x, y)
			v.append(c.r)
			v.append(c.g)
			v.append(c.b)
			v.append(c.a)
	return v


## O primeiro par de texturas que desenha a mesma coisa, ou "" se não houver.
func _repetido_entre(texturas: Array) -> String:
	var assinaturas := []
	for tex in texturas:
		assinaturas.append(_assinatura(tex as Texture2D))
	for i in range(texturas.size()):
		for j in range(i + 1, texturas.size()):
			var a: PackedFloat32Array = assinaturas[i]
			var b: PackedFloat32Array = assinaturas[j]
			var pior := 0.0
			for k in range(a.size()):
				pior = maxf(pior, absf(a[k] - b[k]))
			if pior < ASSINATURA_MIN:
				return "%s e %s desenham a mesma coisa (diferença máxima %.4f)" \
					% [(texturas[i] as Texture2D).resource_path.get_file(),
						(texturas[j] as Texture2D).resource_path.get_file(), pior]
	return ""


# O inverso de `_mundo`: do mundo para o pixel do mapa.
func _tela(mx: float, my: float, altura: float) -> Vector2:
	var pr: Dictionary = _ancoras["projecao"]
	return Vector2(
		float(pr["cx"]) + (mx - my) * float(pr["meia_larg"]),
		float(pr["cy"]) + (mx + my) * float(pr["meia_alt"]) - altura)


# ── projeção, para saber em que faixa do porto um pixel caiu ──
# ── D14 ── a vila: cada casa no seu lote, e nenhuma debaixo de um prédio
#
# ⚠️ ESTE BLOCO NÃO EXISTIA, e a coisa que ele guarda já tinha apodrecido uma
# vez. A tabela de âncoras publica os `lotes` desde sempre e NENHUM teste os
# lia — enquanto isso, o gerador do mapa carregava dois intervalos escritos à
# mão (`VILA_VAZIOS`) que diziam onde o escritório e o armazém tapam a fileira,
# com um comentário de vinte linhas a avisar que eles envelhecem calados:
# "quem mexer só num dos lados deixa o vão no sítio antigo — e um vão no sítio
# errado não dá erro: dá uma casa fatiada por um telhado e um buraco na
# fileira a seis unidades dali". Em 03/09 os dois termos da conta mudaram e
# alguém teve de reparar à mão.
#
# Agora o gerador DERIVA os vãos e este bloco confere o resultado. São três
# perguntas, e cada uma pega um defeito diferente:
#
#   1. nenhuma casa se sobrepõe a outra da MESMA fileira — o gerador de
#      quarteirões anda em `my` por passos que dependem de `dmy`, e um passo
#      menor que a casa põe duas paredes no mesmo sítio sem dar erro;
#   2. nenhuma casa cai debaixo da silhueta de um prédio do pátio — é o vão
#      derivado a ser conferido contra o `Main.tscn`, que é a única fonte que
#      sabe onde os props estão de verdade;
#   3. a fileira de trás fica a mais de um telhado de distância da da frente —
#      medido em 04/09: com a travessa de 0,55 a separação era de 57px contra
#      ~78px de telhado, e as duas fileiras liam como um borrão de telha.
#
# A pegada de uma casa em `my` é `dmy` mais o beiral de 0,12 de cada lado, que
# é o que a `casa()` desenha — conferir só `my..my+dmy` deixaria passar
# exatamente a sobreposição de telhado que se quer evitar.
const BEIRAL_DA_CASA := 0.12
# A largura de um telhado desta vila, EM UNIDADES DE MUNDO: a profundidade do
# lote mais os dois beirais mais a folga de uma unidade.
#
# ⚠️ ERA 78,0 EM PIXEL, e isso não sobreviveu a mexer na câmera: o número saía
# de `(VILA_PROF + 0.24 + 1.0) * 30`, a separação com que ele é comparado sai
# das âncoras — que passaram a publicar 20 —, e o teste reprovou seis degraus
# que não tinham mudado nada. Régua e medida têm de vir da mesma escala. O
# `VILA_PROF` sai da própria tabela (`faixa["vila"]`), que é quem o sabe.
const TELHADO_FOLGA := 0.24 + 1.0

var _d14_completo := false


func _d14_vila() -> void:
	var lotes: Array = _ancoras.get("lotes", [])
	_confere("a tabela de âncoras publica os lotes da vila", not lotes.is_empty(),
		"sem lotes não há o que conferir — o gerador deixou de os publicar?")
	if lotes.is_empty():
		return

	# (1) duas casas da mesma fileira não ocupam o mesmo `my`.
	#
	# ⚠️ E A CONTAGEM SÓ SE TESTA ACIMA DE UM: com uma casa por fileira este
	# laço não compara nada e passa sempre. Por isso a asserção de que há mais
	# de uma casa em cada fileira vem ANTES, e não como detalhe.
	for fundo in [false, true]:
		var fila: Array = []
		for l in lotes:
			if bool(l.get("fundo", false)) == fundo:
				fila.append(l)
		var nome := "de trás" if fundo else "da frente"
		_confere("a fileira %s tem mais de uma casa" % nome, fila.size() > 1,
			"tem %d — com uma só, o teste de sobreposição não compara nada"
			% fila.size())
		fila.sort_custom(func(a, b): return float(a["my"]) < float(b["my"]))
		for i in range(fila.size() - 1):
			var a: Dictionary = fila[i]
			var b: Dictionary = fila[i + 1]
			var fim_a := float(a["my"]) + float(a["dmy"]) + BEIRAL_DA_CASA
			var ini_b := float(b["my"]) - BEIRAL_DA_CASA
			# Geminada encosta de propósito: a parede é partilhada e os dois
			# beirais também. O que não pode é uma casa entrar na outra.
			_confere("as casas da fileira %s em my=%.2f e %.2f não se comem"
				% [nome, float(a["my"]), float(b["my"])],
				ini_b >= fim_a - 2.0 * BEIRAL_DA_CASA - 0.02,
				"a de trás acaba em %.2f e a da frente começa em %.2f"
				% [fim_a, ini_b])

	# (2) nenhuma casa debaixo da silhueta de um prédio do pátio.
	var cenario := _main.get_node("MapaWrap/Cenario")
	var alt := float(_ancoras["projecao"]["alt_cais"])
	var meia_larg := float(_ancoras["projecao"]["meia_larg"])
	var conferidos := 0
	for no in cenario.get_children():
		if not (no is TextureRect):
			continue
		var tex: Texture2D = (no as TextureRect).texture
		if tex == null:
			continue
		# EM COORDENADA, não em pixel da textura: o `meia_larg` do outro lado
		# da conta sai da tabela de âncoras, que publica TELA.
		var usado := PropIso.desenho(tex)
		if usado.size.x < SILHUETA_QUE_EXIGE_PEGADA_MUNDO * meia_larg:
			continue                       # coqueiro, caminhão: não tapam vila
		conferidos += 1
		var base := _origem(no as Control)
		for l in lotes:
			var canto: Array = l["canto"]
			var centro := Vector2(float(canto[0])
					+ float(l["dmy"]) * 0.5 * -meia_larg
					+ float(l["dmx"]) * 0.5 * meia_larg,
				float(canto[1]))
			var dx: float = absf(centro.x - base.x)
			var dy: float = base.y - centro.y
			# O prédio tapa para CIMA e só até à altura do sprite dele — a
			# mesma conta que `vaos_da_vila()` faz no gerador. Conferir só a
			# coluna da tela reprovaria casas que estão 273px abaixo.
			var tapa := dx < float(usado.size.x) * 0.30 \
				and dy >= 0.0 and dy <= float(usado.size.y)
			_confere("%s não tapa a casa em my=%.2f" % [no.name, float(l["my"])],
				not tapa,
				"a casa cai a %.0fpx da coluna do prédio e %.0fpx acima da base "
				% [dx, dy] + "dele, num sprite de %dx%d" % [usado.size.x, usado.size.y])
	_confere("houve prédio grande para conferir contra a vila", conferidos > 0,
		"nenhum prop passou de %.0fpx — o filtro comeu tudo"
		% (SILHUETA_QUE_EXIGE_PEGADA_MUNDO * meia_larg))

	# (3) as duas fileiras separam-se por mais de um telhado.
	#
	# ⚠️ E A COMPARAÇÃO É DENTRO DO MESMO DEGRAU. A primeira versão tirou o
	# `mx` mínimo da fileira da frente e o máximo da de trás sobre TODOS os
	# lotes — e o cais avança 4 unidades por degrau, então isso comparava a
	# vila do degrau 0 com a do degrau 3 e dava -274px. As duas faixas saem do
	# gerador, uma por degrau, exatamente para não ter de as reconstruir aqui.
	for faixa in _ancoras.get("faixas", []):
		var vila: Array = faixa["vila"]
		var fundo_: Array = faixa["vila_fundo"]
		var separacao: float = (float(vila[0]) - float(fundo_[0])) * meia_larg
		var telhado: float = (float(vila[1]) - float(vila[0])
			+ TELHADO_FOLGA) * meia_larg
		_confere("no degrau my=%s a fileira de trás sai de trás da da frente"
			% [faixa["my"]],
			separacao > telhado,
			"%.0fpx de separação para um telhado de %.0fpx — as duas fileiras "
			% [separacao, telhado] + "leem como um borrão de telha")

	_d14_completo = true


func _mundo(pos: Vector2, altura: float) -> Vector2:
	var pr: Dictionary = _ancoras["projecao"]
	var dx: float = (pos.x - float(pr["cx"])) / float(pr["meia_larg"])
	var soma: float = (pos.y - float(pr["cy"]) + altura) / float(pr["meia_alt"])
	return Vector2((soma + dx) / 2.0, (soma - dx) / 2.0)   # (mx, my)


func _faixa_de(my: float) -> Dictionary:
	for faixa in _ancoras["faixas"]:
		var lim: Array = faixa["my"]
		if float(lim[0]) <= my and my < float(lim[1]):
			return faixa
	return _ancoras["faixas"][_ancoras["faixas"].size() - 1]


# Canto superior esquerdo de um TextureRect -> pixel do mundo que ele ancora.
func _origem(no: Control) -> Vector2:
	return no.position + Vector2(MEIO_QUADRO, MEIO_QUADRO)


# Posição de um nó relativa ao MapaWrap, somando os pais pelo caminho.
func _no_mapa(no: Control) -> Vector2:
	var pos := no.position
	var pai := no.get_parent()
	while pai != null and pai.name != "MapaWrap":
		if pai is Control:
			pos += (pai as Control).position
		pai = pai.get_parent()
	return pos


# ── D8 ── a projeção agora tem QUATRO participantes, não três
#
# Era um contrato entre `gerar_mapa_iso.py`, `gerar_props_iso.py` e as cenas.
# O pipeline do pacote de arte (`blender/`) é o quarto, e escreve a projeção que
# usou dentro do manifest, no momento em que renderiza. Se alguém regerar um
# lote com outra câmera, os PNGs saem certos aos olhos e errados no mapa — foi
# exatamente assim que o lote externo de 31/08 veio com o guindaste a 34,6°.
#
# Este caso não abre PNG nenhum: compara o que o manifest DIZ com o que o mapa
# publica. É barato e roda em todo push.
const MANIFEST_BRP := "res://data/assets/BRP_EXPORT_MANIFEST.json"


func _d8_contrato_brp() -> void:
	if not FileAccess.file_exists(MANIFEST_BRP):
		# Sem pipeline BRP no repositório não há o que conferir, e isso não é
		# falha: o jogo funciona sem ele.
		print("  (sem manifest BRP — nada a conferir)")
		return
	var f := FileAccess.open(MANIFEST_BRP, FileAccess.READ)
	var lido: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	if typeof(lido) != TYPE_DICTIONARY or not lido.has("contrato"):
		_confere("manifest BRP tem bloco `contrato`", false, "JSON inválido")
		return

	var c: Dictionary = lido["contrato"]
	var pr: Dictionary = _ancoras["projecao"]
	_confere("meia_larg do pipeline BRP == a do mapa",
		float(c["meia_larg"]) == float(pr["meia_larg"]),
		"BRP %s, mapa %s" % [c["meia_larg"], pr["meia_larg"]])
	_confere("meia_alt do pipeline BRP == a do mapa",
		float(c["meia_alt"]) == float(pr["meia_alt"]),
		"BRP %s, mapa %s" % [c["meia_alt"], pr["meia_alt"]])
	_confere("câmera do pipeline BRP a 60/45",
		abs(float(c["rot_x"]) - 60.0) < 0.001
			and abs(float(c["rot_z"]) - 45.0) < 0.001,
		"BRP usa %s/%s — o 54,736 do isométrico verdadeiro daria 1,732:1"
			% [c["rot_x"], c["rot_z"]])


# ── D1 ── cada píer e cada barco em cima do que o gerador desenhou
func _d1_encaixe_das_docas() -> void:
	var vagas := _main.get_node("MapaWrap/Docas").get_children()
	var esperado: Array = _ancoras["pieres"]
	_confere("o mapa desenha %d berços e a cena tem %d vagas"
		% [esperado.size(), vagas.size()], vagas.size() == esperado.size())
	if vagas.size() != esperado.size():
		return

	for i in range(vagas.size()):
		var vaga: Control = vagas[i]
		var alvo: Dictionary = esperado[i]
		for peca in [["Pier", "centro"], ["Lanca", "centro"], ["Barco", "barco"]]:
			var no := vaga.get_node_or_null(String(peca[0])) as Control
			if no == null:
				_confere("Doca %d tem %s" % [i + 1, peca[0]], false)
				continue
			var alvo_px := Vector2(float(alvo[peca[1]][0]), float(alvo[peca[1]][1]))
			var real := _no_mapa(no) + Vector2(MEIO_QUADRO, MEIO_QUADRO)
			var erro := real.distance_to(alvo_px)
			_confere("Doca %d · %s no lugar" % [i + 1, peca[0]], erro <= TOLERANCIA_PX,
				"o mapa diz %s, a cena põe em %s (%.1f px de erro)"
				% [alvo_px, real, erro])

		# O trabalhador é o único deslocado de propósito — mas tem de continuar
		# EM CIMA DO TABUADO, senão a figura fica de pé sobre a água.
		var trab := vaga.get_node_or_null("Trabalhador") as Control
		if trab != null:
			var centro := Vector2(float(alvo["centro"][0]), float(alvo["centro"][1]))
			var d := (_no_mapa(trab) + Vector2(MEIO_QUADRO, MEIO_QUADRO)).distance_to(centro)
			_confere("Doca %d · trabalhador no convés" % [i + 1], d <= 80.0,
				"%.0f px do centro do píer — o tabuado tem ~70 de meia-diagonal" % d)


# ── D2 ── nada do cenário fixo pode nascer no asfalto da rua
#
# ⚠️ ESTE BLOCO JÁ OLHOU UM PROP SÓ, E UM PONTO SÓ. Até 03/09 ele filtrava
# `Coqueiro*Tronco` e conferia a ÂNCORA — e foi por isso que passou por cima do
# defeito que a primeira jogada num telefone encontrou: a âncora dos dois
# prédios caía no pátio, certinha, e a PEGADA deles não cabia lá. O armazém
# ocupa 3,76 em `mx` e o pátio tinha 1,68, então 0,70 dele ficavam no asfalto e
# 0,08 pendurados sobre a água. Ponto nenhum pega isso.
#
# Agora são três perguntas, e a terceira é o que fecha o cerco:
#
#   1. todo prop do cenário — não só o coqueiro — cai fora do asfalto e em
#      terra, pela âncora;
#   2. quem tem pegada declarada em `porto_mapa_ancoras.json` responde pela
#      pegada inteira, em cada degrau que ela toca (um prédio pode atravessar
#      o salto da costa, onde a rua anda 4 unidades de uma vez) E em cada
#      COTOVELO — a rua vira entre um degrau e o seguinte, e o cotovelo é
#      asfalto que faixa reta nenhuma declara;
#   3. prop do cenário com silhueta grande e SEM pegada declarada reprova —
#      senão o cerco só vale para os prédios que já existem hoje.
#
# As exceções são nomeadas e explicadas: um caminhão na rua é um caminhão na
# rua, e barco em terra seria o defeito oposto.
# ⚠️ O CONE SAIU DESTA LISTA EM 07/09, E A ISENÇÃO ERA O DEFEITO. A segunda
# jogada no telefone circulou-o a vermelho — "o cone no meio da estrada não faz
# sentido" — e a medida deu-lhe razão: ele estava em `mx=7,80` com o asfalto
# daquele degrau a ocupar 6,98..8,52, ou seja no MEIO da faixa. Nenhuma
# asserção o pegava porque ele tinha sido escrito aqui como exceção.
#
# Um cone sinaliza obra ou passagem fechada; no meio de uma rua aberta ele lê
# como um objeto esquecido. Hoje ele está no pátio, a 14 px da barreira, que é
# a peça com que ele forma sentido. **Só o caminhão pisa a rua** — e esse
# ANDA nela, que é outra coisa.
#
# ⚠️ E O SÍTIO SAIU DA FOTO, NÃO DA ASSERÇÃO. A primeira mudança pôs o cone em
# `mx=9,00`, que passa nesta regra com 0,48 unidades de folga — e na captura
# ele ficava colado ao meio-fio, sozinho, com a barreira a 35 px. O comentário
# dizia "ao lado da barreira" e a imagem dizia outra coisa. A régua responde se
# ele PISA a rua; se ele se LÊ como parte do mesmo canteiro, só a foto responde.
const PODEM_PISAR_A_RUA := ["Caminhao"]
const VIVEM_NA_AGUA := ["BarcoEspera", "Ancoragem", "Bote"]

# Acima disto a âncora deixa de responder pelo prop e a pegada passa a ser
# obrigatória. É uma medida de MUNDO — "mais largo do que 4,33 unidades de
# chão" —, e não de pixel: medido depois do enquadramento de 05/09, o
# escritório tem 103px de silhueta e o armazém 124; o maior prop sem pegada é
# a copa do coqueiro, com 79.
#
# ⚠️ EM PIXEL ELA MORRIA CALADA. Eram 130px, afinados quando os mesmos props
# mediam 154 e 185; ao afastar a câmera todos passariam a caber por baixo do
# corte, e a asserção que existe para exigir pegada deixaria de exigir
# qualquer uma sem reprovar nada. Guarda que nunca reprova não é guarda.
const SILHUETA_QUE_EXIGE_PEGADA_MUNDO := 4.33


func _d2_cenario_em_terra() -> void:
	var cenario := _main.get_node("MapaWrap/Cenario")
	var pegadas: Dictionary = _ancoras.get("pegadas", {})
	var alt := float(_ancoras["projecao"]["alt_cais"])
	var meia_larg := float(_ancoras["projecao"]["meia_larg"])
	for no in cenario.get_children():
		if not (no is TextureRect):
			continue
		var nome := String(no.name)
		if _comeca_com_algum(nome, VIVEM_NA_AGUA):
			continue
		var tex: Texture2D = (no as TextureRect).texture
		var pegada: Array = pegadas.get(_id_do_prop(tex), [])
		var m := _mundo(_origem(no as Control), alt)

		# (3) silhueta grande sem pegada declarada — o buraco por onde o
		# defeito de 02/09 entrou, agora fechado.
		if pegada.is_empty() and tex != null:
			var larg := PropIso.desenho(tex).size.x
			_confere("%s tem pegada declarada" % nome,
				larg < SILHUETA_QUE_EXIGE_PEGADA_MUNDO * meia_larg,
				"a silhueta tem %.0fpx e só a âncora é conferida — declare a "
				% larg + "pegada em PEGADAS, no gerar_mapa_iso.py")

		# ⚠️ INTERSEÇÃO DE INTERVALOS, E NÃO OS QUATRO CANTOS. A primeira
		# versão deste bloco conferia canto a canto e deixou passar o defeito
		# que ele foi escrito para pegar: com o escritório de volta ao sítio
		# antigo, os cantos caíam a 2,82 e a 5,58 e a rua ocupava 2,98..4,52 —
		# nenhum canto DENTRO do asfalto, e a pegada atravessando-o inteiro.
		# Um retângulo maior que a faixa passa por cima dela sem tocar nela
		# com ponto nenhum.
		var meia_x: float = (float(pegada[0]) / 2.0) if not pegada.is_empty() else 0.0
		var meia_y: float = (float(pegada[1]) / 2.0) if not pegada.is_empty() else 0.0
		var mx0 := m.x - meia_x
		var mx1 := m.x + meia_x
		var pisa_rua := false
		var na_agua := false
		var pior := ""
		# E em TODO degrau que a pegada toca, não só no da âncora: a costa é
		# uma escada e a rua salta 4 unidades a cada degrau, então um prédio
		# que atravessa o salto responde perante duas ruas diferentes.
		for faixa in _ancoras["faixas"]:
			var lim: Array = faixa["my"]
			if m.y + meia_y <= float(lim[0]) or m.y - meia_y >= float(lim[1]):
				continue
			var rua: Array = faixa["rua"]
			if mx0 <= float(rua[1]) and mx1 >= float(rua[0]):
				pisa_rua = true
				pior = "a pegada ocupa mx %.2f..%.2f e o asfalto %.2f..%.2f" \
					% [mx0, mx1, float(rua[0]), float(rua[1])]
			if mx1 > float(faixa["borda"]) + 0.1:
				na_agua = true
				pior = "a pegada chega a mx=%.2f e a beira do cais é %.2f" \
					% [mx1, float(faixa["borda"])]

		# ⚠️ E OS COTOVELOS, que são rua tanto quanto as faixas retas.
		#
		# Isto custou um bloco inteiro. Depois de encolher os dois prédios,
		# este teste passava e o jogador continuava a ver o armazém em cima do
		# asfalto — porque entre um degrau e o seguinte a rua VIRA, e o
		# cotovelo em que ela vira corre em `mx` por cinco unidades e meia,
		# atravessando o pátio de lado a lado. As faixas retas não o cobrem, e
		# nenhuma delas mentia: a rua reta estava mesmo livre. Meia unidade de
		# cada prédio estava dentro do cotovelo.
		#
		# É a mesma lição da interseção de intervalos, um andar acima: conferir
		# o retângulo contra PARTE da rua não é conferi-lo contra a rua.
		for cotovelo in _ancoras.get("cotovelos", []):
			var cmx: Array = cotovelo["mx"]
			var cmy: Array = cotovelo["my"]
			if mx0 > float(cmx[1]) or mx1 < float(cmx[0]):
				continue
			if m.y + meia_y < float(cmy[0]) or m.y - meia_y > float(cmy[1]):
				continue
			pisa_rua = true
			pior = "a pegada entra no cotovelo da rua (mx %.2f..%.2f, my %.2f..%.2f)" \
				% [float(cmx[0]), float(cmx[1]), float(cmy[0]), float(cmy[1])]

		if not _comeca_com_algum(nome, PODEM_PISAR_A_RUA):
			_confere("%s fora do asfalto" % nome, not pisa_rua, pior)
		_confere("%s em terra" % nome, not na_agua, pior)


func _comeca_com_algum(nome: String, lista: Array) -> bool:
	for prefixo in lista:
		if nome.begins_with(prefixo):
			return true
	return false


# "res://art/props/galpao_velho.png" -> "galpao_velho", que é a chave de PEGADAS.
func _id_do_prop(tex: Texture2D) -> String:
	if tex == null:
		return ""
	return tex.resource_path.get_file().get_basename()


# ── D3 ── num plano isométrico, ordem de irmão É profundidade
func _d3_profundidade() -> void:
	var alt := float(_ancoras["projecao"]["alt_cais"])
	for caminho in ["MapaWrap/Cenario", "MapaWrap/Docas"]:
		var pai := _main.get_node(caminho)
		var anterior := -INF
		var nome_anterior := ""
		for no in pai.get_children():
			if not (no is Control):
				continue
			var ref: Control = no
			# Numa vaga de doca, a profundidade é a do píer que ela ancora.
			if ref.has_method("esta_construida"):
				var pier := ref.get_node_or_null("Pier") as Control
				if pier != null:
					ref = pier
			var m := _mundo(_no_mapa(ref) + Vector2(MEIO_QUADRO, MEIO_QUADRO), alt)
			var profundidade := m.x + m.y
			_confere("%s/%s vem depois de quem está atrás" % [pai.name, no.name],
				profundidade >= anterior - 0.75,
				"profundidade %.1f, mas %s vem antes dele e está em %.1f"
				% [profundidade, nome_anterior, anterior])
			if profundidade > anterior:
				anterior = profundidade
				nome_anterior = String(no.name)


# ── D4 ── tudo dentro da viewport, com margem
func _d4_dentro_da_tela() -> void:
	var tela := Vector2(
		ProjectSettings.get_setting("display/window/size/viewport_width"),
		ProjectSettings.get_setting("display/window/size/viewport_height"))
	for no in _main.get_children():
		if not (no is Control) or String(no.name) == "Fundo":
			continue
		var c: Control = no
		var r := Rect2(c.position, c.size)
		_confere("%s dentro da tela" % no.name,
			r.position.x >= -0.5 and r.position.y >= -0.5
			and r.end.x <= tela.x + 0.5 and r.end.y <= tela.y + 0.5,
			"ocupa %s numa tela de %s" % [r, tela])


# ── D5 ── a pilha do rodapé não pode se atropelar
func _d5_sem_sobreposicao() -> void:
	# ⚠️ "Upgrade" ERA UM FILHO DIRETO E PASSOU A VIVER EM "LinhaConstruir".
	# A pilha percorre-se por NOME, então um nó que se mova de sítio some
	# desta conta sem erro nenhum: quem o apanhou foi a asserção "%s existe",
	# que está aqui por baixo exactamente para isso.
	var pilha := ["MapaWrap", "BarraDocas", "TrabalhadoresTitulo", "Trabalhadores",
		"MensagemCartao", "MetaCartao", "LinhaConstruir", "AcoesTurno"]
	var anterior: Control = null
	for nome in pilha:
		var c := _main.get_node_or_null(nome) as Control
		if c == null:
			_confere("%s existe" % nome, false)
			continue
		if anterior != null:
			var fim: float = anterior.position.y + anterior.size.y
			_confere("%s começa depois de %s" % [nome, anterior.name],
				c.position.y >= fim,
				"%s termina em %.0f e %s começa em %.0f"
				% [anterior.name, fim, nome, c.position.y])
		anterior = c

	# A barra de docas tem de preencher a largura exata, sem sobra nem estouro.
	var barra := _main.get_node("BarraDocas") as HBoxContainer
	var cartoes := barra.get_children()
	var separacao := barra.get_theme_constant("separation")
	var soma := float(separacao * (cartoes.size() - 1))
	for c in cartoes:
		soma += (c as Control).size.x
	_confere("os cartões preenchem a barra de docas",
		abs(soma - barra.size.x) <= 1.0,
		"somam %.0f numa barra de %.0f" % [soma, barra.size.x])


# ── D6 ── nada clicável menor que o dedo
func _d6_alvos_de_toque() -> void:
	var alvos: Array[Control] = []
	alvos.append(_main.get_node("AcoesTurno/Alocar"))
	alvos.append(_main.get_node("AcoesTurno/Avancar"))
	alvos.append(_main.get_node("LinhaConstruir/Upgrade"))
	alvos.append(_main.get_node("LinhaConstruir/Menu"))
	alvos.append(_main.get_node("HudBar/Pausar"))
	for c in _main.get_node("BarraDocas").get_children():
		alvos.append(c)
	for c in alvos:
		_confere("%s cabe no dedo (%.0fx%.0f)" % [c.name, c.size.x, c.size.y],
			c.size.y >= TOQUE_MIN and c.size.x >= TOQUE_MIN,
			"mínimo é %.0f em cada lado" % TOQUE_MIN)


# ── D9 ── o aviso de trabalho parado tem de aparecer ONDE ele se resolve
#
# O primeiro playtest num telefone avançou o dia com dois operários livres e
# duas docas sem trabalhador. A doca já avisava — borda âmbar, "sem
# trabalhador" —, mas o lado que RESOLVE o problema não avisava nada: o cartão
# dizia "Livre" em cinzento e a linha acima dele repetia a instrução genérica.
#
# Este bloco monta esse estado e exige os três sinais. Eles são três porque o
# olho pode estar em qualquer um dos três sítios; são a MESMA contagem porque
# saem todos do `trabalho_parado()`.
func _d9_aviso_de_trabalho_parado() -> void:
	var GS: Node = root.get_node("GameState")
	GS.clear_save()
	GS._rng.seed = 20260903
	GS.new_game()
	if GS.phase == "rival_offer":
		GS.resolve_rival_offer(true)
	for i in range(GS.docks.size()):
		GS.docks[i]["worker_id"] = null
		GS.docks[i]["boat"] = GS._make_boat()
		GS.docks[i]["boat"]["rival"] = false
	for w in GS.workers:
		w["busy_turns"] = 0

	var tela: Control = load(CENA).instantiate()
	root.add_child(tela)
	var parado: Vector2i = GS.trabalho_parado()
	_confere("o estado de teste tem mesmo trabalho parado", parado != Vector2i.ZERO,
		"trabalho_parado() devolveu %s e o bloco não testa nada" % parado)

	var titulo: Label = tela.get_node("TrabalhadoresTitulo")
	_confere("o rótulo conta os trabalhadores parados",
		titulo.text.contains(str(parado.x)), "diz \"%s\"" % titulo.text)
	_confere("o rótulo conta as docas à espera",
		titulo.text.contains(str(parado.y)), "diz \"%s\"" % titulo.text)
	_confere("e está na cor de aviso, não na neutra",
		titulo.get_theme_color("font_color").is_equal_approx(COR_AVISO),
		"está em %s" % titulo.get_theme_color("font_color"))

	# O cartão: o sinal é o FUNDO, porque o âmbar sobre ele dá 2,98:1 e
	# reprovaria a WCAG como texto (ver `trab_parado` no tema).
	var tema: Theme = load("res://ui/tema_brport.tres")
	var esperado: StyleBox = tema.get_stylebox("panel", "TrabParado")
	var parados := 0
	for cartao in tela.get_node("Trabalhadores").get_children():
		if (cartao as Control).get_theme_stylebox("panel") == esperado:
			parados += 1
	_confere("todo trabalhador parado tem o cartão de aviso",
		parados == parado.x, "%d cartões marcados para %d parados" % [parados, parado.x])

	var alocar: Button = tela.get_node("AcoesTurno/Alocar")
	_confere("e o botão que resolve está aceso", not alocar.disabled)

	root.remove_child(tela)
	tela.free()
	_d9_completo = true


# ── D10 ── o toque na pílula do caixa tem de abrir o painel de verdade
#
# Item do primeiro playtest: "tocar no dinheiro do HUD abre um resumo do
# ganho de ontem e o projetado para hoje". A conta certa (T5i, em
# `run_tests.gd`) não prova que o TOQUE chega lá — só que a função devolve o
# número certo quando chamada direto. Este bloco emite o mesmo `gui_input`
# que um dedo real dispara e confere que o painel abriu, e com o texto certo.
func _d10_toque_no_caixa() -> void:
	var GS: Node = root.get_node("GameState")
	GS.clear_save()
	GS._rng.seed = 20260903
	GS.new_game()
	if GS.phase == "rival_offer":
		GS.resolve_rival_offer(true)

	var tela: Control = load(CENA).instantiate()
	root.add_child(tela)

	var pilula: Control = tela.get_node("HudBar/CaixaPilula")
	var overlay: Node = tela.get_node("Overlay")
	var antes := overlay.get_child_count()

	# O RELEASE é o que o handler escuta — press sozinho não deve abrir nada,
	# a mesma regra do `Worker.gd` (reagir no toque que solta).
	var ev := InputEventMouseButton.new()
	ev.button_index = MOUSE_BUTTON_LEFT
	ev.pressed = true
	pilula.gui_input.emit(ev)
	_confere("o press sozinho nao abre nada", overlay.get_child_count() == antes)

	ev = InputEventMouseButton.new()
	ev.button_index = MOUSE_BUTTON_LEFT
	ev.pressed = false
	pilula.gui_input.emit(ev)
	_confere("o release abriu um painel a mais", overlay.get_child_count() == antes + 1)

	var painel: Node = overlay.get_child(overlay.get_child_count() - 1)
	var script: Script = painel.get_script()
	_confere("e o painel aberto e o PainelCaixa",
		script != null and String(script.resource_path).ends_with("PainelCaixa.gd"),
		"script aberto: %s" % (script.resource_path if script != null else "nenhum"))

	# "Ontem" ainda não tem turno num porto que acabou de nascer — o painel
	# tem de dizer isso em vez de mostrar uma fileira de zeros.
	var texto_inteiro := "\n".join(_juntar_textos(painel))
	_confere("mostra que o primeiro dia ainda nao fechou",
		texto_inteiro.contains("ainda não fechou"), "painel diz: %s" % texto_inteiro)
	_confere("e mostra a secao do que hoje projeta",
		texto_inteiro.contains("PROJETADO PARA HOJE"), "painel diz: %s" % texto_inteiro)

	root.remove_child(tela)
	tela.free()
	_d10_completo = true


# Recolhe o texto de todo Label debaixo de `no`, em ordem — para conferir o
# CONTEÚDO de um painel sem depender do caminho exato de cada rótulo dentro
# dele, que o `PainelNarrativo` monta dinamicamente.
#
# DEVOLVE em vez de RECEBER e mutar um `PackedStringArray` por parâmetro: COW
# de array passado a uma função recursiva é o tipo de coisa que parece
# funcionar e às vezes não propaga — devolver e concatenar com
# `append_array()` não deixa essa dúvida no ar.
func _juntar_textos(no: Node) -> PackedStringArray:
	var saida := PackedStringArray()
	if no is Label:
		saida.append((no as Label).text)
	for filho in no.get_children():
		saida.append_array(_juntar_textos(filho))
	return saida


# ── D11 ── o chip do dia, o da reputação e o das docas também respondem
#
# Mesma prova do D10, para os três chips que faltavam: o toque de verdade
# (gui_input, não uma chamada direta a `setup()`) tem de abrir o painel
# CERTO, com conteúdo dentro — e não um retângulo vazio ou o painel de outro
# chip por engano de que scene ficou ligada a qual sinal.
func _d11_toque_nos_outros_chips() -> void:
	var GS: Node = root.get_node("GameState")
	GS.clear_save()
	GS._rng.seed = 20260903
	GS.new_game()
	if GS.phase == "rival_offer":
		GS.resolve_rival_offer(true)

	var tela: Control = load(CENA).instantiate()
	root.add_child(tela)
	var overlay: Node = tela.get_node("Overlay")

	_confere_chip_abre(tela, overlay, "HudBar/DiaPilula", "PainelCalendario.gd",
		["Calendário", "SEMANA 1"])
	_confere_chip_abre(tela, overlay, "HudBar/RepPilula", "PainelReputacao.gd",
		["Reputação", GS.reputation_label()])
	_confere_chip_abre(tela, overlay, "HudBar/DocasPilula", "PainelDocas.gd",
		["Docas", "de %d berços" % int(GS.BERCOS_NO_MAPA)])

	root.remove_child(tela)
	tela.free()
	_d11_completo = true


# Toca (release) no caminho `no_pilula` dentro de `tela`, confere que o
# painel que abriu no `overlay` é o `script_esperado` e contém CADA um dos
# `deve_conter`, e fecha o painel antes de devolver — para o próximo chip
# testado não herdar o painel do anterior no topo da pilha.
func _confere_chip_abre(tela: Control, overlay: Node, no_pilula: String,
		script_esperado: String, deve_conter: Array) -> void:
	var pilula: Control = tela.get_node(no_pilula)
	var antes := overlay.get_child_count()

	var ev := InputEventMouseButton.new()
	ev.button_index = MOUSE_BUTTON_LEFT
	ev.pressed = false
	pilula.gui_input.emit(ev)

	_confere("%s abriu um painel" % no_pilula, overlay.get_child_count() == antes + 1)
	var painel: Node = overlay.get_child(overlay.get_child_count() - 1)
	var script: Script = painel.get_script()
	_confere("%s abriu o painel certo" % no_pilula,
		script != null and String(script.resource_path).ends_with(script_esperado),
		"abriu: %s" % (script.resource_path if script != null else "nenhum"))

	var texto_inteiro := "\n".join(_juntar_textos(painel))
	for trecho in deve_conter:
		_confere("%s mostra \"%s\"" % [no_pilula, trecho],
			texto_inteiro.contains(String(trecho)), "painel diz: %s" % texto_inteiro)

	overlay.remove_child(painel)
	painel.free()


# ── D12 ── o cartão da parcela: o convite e a porta
#
# Pagar adiantado é item do playtest, e o botão não vive no cartão (o rodapé
# não tem 44px de folga) — vive num painel que o TOQUE abre. Duas coisas
# podem falhar em silêncio aqui: o toque não estar ligado, e o cartão não
# CONVIDAR. Cartão tocável que não se anuncia é cartão que ninguém toca, e
# nenhum teste de layout pega isso — este pega.
func _d12_toque_na_parcela() -> void:
	var GS: Node = root.get_node("GameState")
	GS.clear_save()
	GS._rng.seed = 20260903
	GS.new_game()
	if GS.phase == "rival_offer":
		GS.resolve_rival_offer(true)
	# Caixa que cobre a parcela: é o único estado em que o convite aparece.
	GS.cash = int(GS.PARCELA_AMOUNT) + 1000

	var tela: Control = load(CENA).instantiate()
	root.add_child(tela)
	var overlay: Node = tela.get_node("Overlay")

	var rotulo: Label = tela.get_node("MetaCartao/MetaColuna/MetaTexto")
	_confere("com caixa de sobra, o cartão convida ao toque",
		rotulo.text.contains("toque"), "diz \"%s\"" % rotulo.text)
	# ⚠️ ESTA ASSERÇÃO PERGUNTAVA PELO `COR_AVISO` ATÉ 20/09, e apanhou a
	# mudança que o tirou — que é o que ela existe para fazer. O rótulo já não
	# pinta cor à mão: pede `RotuloAlerta` ao tema, porque o âmbar de marca
	# media 3,18:1 neste cartão branco contra um corte de 4,5 e este é o
	# convite a quitar a parcela (`docs/decisoes/035`). A pergunta continua a
	# ser a MESMA — "o convite destaca-se?" — e agora ela é feita à cor FINAL,
	# que é o que o jogador vê, em vez de ao mecanismo que a põe lá.
	var cor_convite: Color = rotulo.get_theme_color("font_color")
	_confere("e o convite sai na cor de alerta do tema",
		cor_convite.is_equal_approx(
			(load("res://ui/tema_brport.tres") as Theme)
				.get_color("font_color", "RotuloAlerta")),
		"saiu %s" % cor_convite)
	_confere("e essa cor passa o AA sobre o cartão branco do HUD",
		_contraste(cor_convite, Color(1, 1, 1)) >= 4.5,
		"mede %.2f:1" % _contraste(cor_convite, Color(1, 1, 1)))

	_confere_chip_abre(tela, overlay, "MetaCartao", "PainelParcela.gd",
		["Parcela do Sr. Ribeiro", "quitar"])

	# Sem caixa, o convite SOME — senão ele prometeria uma ação que a porta
	# do outro lado recusa.
	GS.cash = int(GS.PARCELA_AMOUNT) - 1
	tela.call("_refresh_hud")
	_confere("sem caixa, o convite desaparece",
		not rotulo.text.contains("toque"), "diz \"%s\"" % rotulo.text)

	root.remove_child(tela)
	tela.free()
	_d12_completo = true


# ── D13 ── a travessia do caminhão: do lado de fora ao lado de fora
#
# Pedido do playtest, terceira volta: "ele deveria vir de fora do mapa, e
# depois sair do mapa". A rota tem oito pontos e três cotovelos, e nenhum dos
# quatro modos de falhar dá erro:
#
#   1. um ponto no `mx` ERRADO — a estrada salta 4 unidades a cada degrau, e
#      um trecho no `mx` do degrau vizinho põe o caminhão sobre o pátio ou
#      sobre a vila, com o trajeto a continuar a parecer uma linha reta;
#   2. as pontas DENTRO do quadro — aí ele aparece e some do nada, que é
#      exatamente o que o pedido quis corrigir;
#   3. a silhueta errada no trecho: só as faces `+x` e `-y` são visíveis, e um
#      caminhão a percorrer um cotovelo com o sprite do outro eixo desliza de
#      lado sem nada reprovar;
#   4. não se reordenar, e passar por cima de quem devia tapá-lo.
#
# O asfalto NÃO é repetido aqui: sai das faixas que o gerador do mapa publica,
# a mesma fonte que o D2 usa. Nem os pontos da rota — saem do `Main.gd`.
func _d13_travessia_do_caminhao() -> void:
	var tela: Control = _main
	var cenario: Node = tela.get_node("MapaWrap/Cenario")
	var pr: Dictionary = _ancoras["projecao"]
	var alt := float(pr["alt_cais"])
	var consts: Dictionary = tela.get_script().get_script_constant_map()
	var rota: Array = consts["ROTA_ESTRADA"]
	var origens: Array = consts["CAMINHAO_ORIGENS"]
	var caminhoes: Dictionary = consts["CAMINHOES"]
	var desenho := _desenho_dos_caminhoes(tela)

	# Zero: a projeção que o `Main.gd` usa para andar é a MESMA do mapa. Ele
	# repete `MEIA_LARG`/`MEIA_ALT` porque roda dentro do jogo e não lê o JSON;
	# repetição sem esta asserção é o contrato a divergir calado.
	_confere("o caminhão anda na projeção do mapa (%.0f x %.0f)"
			% [float(consts["MEIA_LARG"]), float(consts["MEIA_ALT"])],
		is_equal_approx(float(consts["MEIA_LARG"]), float(pr["meia_larg"]))
			and is_equal_approx(float(consts["MEIA_ALT"]), float(pr["meia_alt"])))

	# A escada tem duas pontas e um cotovelo entre cada par de degraus, e cada
	# cotovelo é DOIS pontos (entra num `mx`, sai no seguinte): são 2 x degraus.
	#
	# ⚠️ ERA O NÚMERO 8 CRAVADO, e ele durou até a costa ganhar um degrau em
	# cada ponta (05/09). Contagem cravada num teste é a mesma armadilha que
	# uma altura cravada em pixel: passa a reprovar o certo assim que o mundo
	# que ela descreve muda de tamanho.
	var pontos_da_escada: int = 2 * _ancoras["faixas"].size()
	_confere("a rota tem os %d pontos da escada" % pontos_da_escada,
		rota.size() == pontos_da_escada, "tem %d" % rota.size())

	# ── 1 ── todo ponto da rota, e todo ponto ENTRE eles, cai em asfalto.
	#
	# Amostrar só os vértices deixaria passar um trecho que atravessasse a
	# quadra pelo meio — é a mesma lição dos quatro cantos do D2. As regiões
	# são duas: a faixa reta de cada degrau, e o cotovelo que liga um ao
	# seguinte, que o `vias()` desenha com a largura da rua.
	var regioes: Array = []
	var faixas: Array = _ancoras["faixas"]
	for i in range(faixas.size()):
		var f: Dictionary = faixas[i]
		var rua: Array = f["rua"]
		var my: Array = f["my"]
		regioes.append([float(rua[0]), float(rua[1]), float(my[0]), float(my[1])])
		if i + 1 < faixas.size():
			var prox: Array = faixas[i + 1]["rua"]
			var largura := float(rua[1]) - float(rua[0])
			regioes.append([float(rua[0]), float(prox[1]),
				float(my[1]) - largura, float(my[1])])

	var fora := ""
	for i in range(rota.size() - 1):
		var de: Vector2 = rota[i]
		var para: Vector2 = rota[i + 1]
		for k in range(21):
			var m: Vector2 = de.lerp(para, float(k) / 20.0)
			var dentro := false
			for r in regioes:
				if m.x >= r[0] - 0.01 and m.x <= r[1] + 0.01 \
						and m.y >= r[2] - 0.01 and m.y <= r[3] + 0.01:
					dentro = true
					break
			if not dentro and fora == "":
				fora = "no trecho %d, a %d%%, está em (%.2f, %.2f) e ali não há asfalto" \
					% [i, k * 5, m.x, m.y]
	_confere("a rota inteira anda sobre asfalto, cotovelos incluídos",
		fora == "", fora)

	# ── 2 ── OS TRÊS CAMIÕES, e cada um no seu ponto de partida.
	#
	# ⚠️ ERA UM SÓ, e a lição de os passar a percorrer é a mesma que o D17 já
	# tinha aprendido com o `barco_medio`: um par verificado e o resto não. Com
	# três nós na cena e três origens numa constante, conferir só o primeiro
	# deixaria dois camiões livres para nascer em cima da vila.
	var janela := (tela.get_node("MapaWrap") as Control).size
	var visivel := Rect2(Vector2.ZERO, janela)
	_confere("há um nó Caminhao por origem declarada (%d)" % origens.size(),
		cenario.get_node_or_null("Caminhao%d" % origens.size()) == null
			and cenario.get_node_or_null("Caminhao0") != null,
		"a cena e o `CAMINHAO_ORIGENS` do Main.gd não contam o mesmo")

	for i in range(origens.size()):
		var caminhao := cenario.get_node_or_null("Caminhao%d" % i) as Control
		_confere("a cena tem o nó Caminhao%d" % i, caminhao != null)
		if caminhao == null:
			continue
		var origem_rota: Vector2 = origens[i]
		# A cena tem de o pôr num ponto DA rota, não ao lado dela.
		var m_cena := _mundo(_origem(caminhao), alt)
		_confere("a cena põe o Caminhao%d no ponto de partida dele" % i,
			m_cena.distance_to(origem_rota) < 0.02,
			"está em (%.2f, %.2f) e devia estar em (%.2f, %.2f)"
				% [m_cena.x, m_cena.y, origem_rota.x, origem_rota.y])

		# E aí ele tem de estar INTEIRO dentro do quadro, senão as
		# capturas do CI apanham-no cortado ao meio. A medida é a união dos
		# oito PNGs: o nó não sabe qual carga vai levar quando a cena abre.
		var na_cena := Rect2(caminhao.position + Vector2(MEIO_QUADRO, MEIO_QUADRO)
			+ desenho.position, desenho.size)
		_confere("e o Caminhao%d está inteiro dentro do mapa" % i,
			visivel.encloses(na_cena),
			"o desenho fica em %s e o mapa é %s" % [na_cena, visivel])

		# ⚠️ E COMEÇA NUM TRECHO RETO. Parado num cotovelo ele precisaria da
		# silhueta de `mx` no primeiro frame, e o que a captura apanharia é um
		# caminhão atravessado na estrada. É uma pergunta sobre a ORIGEM, não
		# sobre a rota: a rota tem cotovelos de propósito.
		var num_reto := false
		for k in range(rota.size() - 1):
			var a: Vector2 = rota[k]
			var b: Vector2 = rota[k + 1]
			if abs(b.x - a.x) > 0.01:
				continue                    # cotovelo: anda em mx
			if not is_equal_approx(a.x, origem_rota.x):
				continue
			if origem_rota.y >= min(a.y, b.y) - 0.01 \
					and origem_rota.y <= max(a.y, b.y) + 0.01:
				num_reto = true
		_confere("o Caminhao%d parte de um trecho reto" % i, num_reto,
			"(%.2f, %.2f) cai num cotovelo, e ali a silhueta é a de mx"
				% [origem_rota.x, origem_rota.y])

	# ── 3 ── as duas pontas da ROTA ficam FORA do quadro visível.
	#
	# Fora não é "o ponto de ancoragem fora": é o desenho todo fora. Mede-se
	# a partir do Caminhao0, que é o nó cuja `base` a rota usa.
	var no0 := cenario.get_node("Caminhao0") as Control
	var origem0: Vector2 = origens[0]
	for ponta in [[0, "a entrada"], [rota.size() - 1, "a saída"]]:
		var idx: int = ponta[0]
		var pos: Vector2 = no0.position + _tela_da_rota(rota[idx], origem0, pr) \
			+ Vector2(MEIO_QUADRO, MEIO_QUADRO)
		var caixa := Rect2(pos + desenho.position, desenho.size)
		_confere("%s da rota está fora do quadro" % ponta[1],
			not visivel.intersects(caixa),
			"o desenho fica em %s e o mapa é %s" % [caixa, visivel])

	# ── 4 ── a silhueta certa por trecho, E POR CARGA.
	#
	# Trecho que anda em `mx` usa o sprite de `mx`; trecho que anda em `my`, o
	# de `my`. Um só sprite para os dois eixos foi a primeira versão, e o
	# caminhão virava de lado nos cotovelos.
	#
	# E a pergunta é feita a QUEM DECIDE — `silhueta_do_trecho()` —, não
	# recalculada aqui. A primeira versão deste bloco recalculava, e por isso
	# não reprovou quando se pôs a mesma silhueta nos oito trechos: o teste
	# estava a concordar consigo próprio.
	#
	# ⚠️ E ELA PERCORRE `GameState.MOTIVOS`, não a tabela do `Main.gd`. É a
	# mesma diferença do D17: perguntar à tabela da arte se ela está completa é
	# ela a concordar consigo própria; quem manda é o que o JOGO consegue
	# sortear. Um motivo novo sem camião reprova aqui.
	var GS: Node = root.get_node("GameState")
	var errado := ""
	var vistas := {}
	for motivo in GS.MOTIVOS:
		var id := String(motivo)
		_confere("o motivo %s tem camião" % id, caminhoes.has(id),
			"`CAMINHOES` do Main.gd conhece %s" % [caminhoes.keys()])
		if not caminhoes.has(id):
			continue
		for i in range(rota.size() - 1):
			var de: Vector2 = rota[i]
			var para: Vector2 = rota[i + 1]
			var anda_em_mx: bool = abs(para.x - de.x) > 0.01
			var usada: Texture2D = tela.call("silhueta_do_trecho", de, para, id)
			var caminho: String = usada.resource_path
			vistas[caminho] = true
			if anda_em_mx != caminho.ends_with("_mx.png") and errado == "":
				errado = "o trecho %d de %s anda em %s e usa %s" \
					% [i, id, "mx" if anda_em_mx else "my", caminho.get_file()]
			if not caminho.get_file().begins_with("caminhao_%s" % id) and errado == "":
				errado = "o trecho %d de %s usa %s, que é de outra carga" \
					% [i, id, caminho.get_file()]
	_confere("cada trecho usa a silhueta do eixo e da carga", errado == "", errado)
	_confere("e as %d silhuetas entram em campo" % (GS.MOTIVOS.size() * 2),
		vistas.size() == GS.MOTIVOS.size() * 2,
		"só se viu %s" % str(vistas.keys()))

	# E os oito são oito DESENHOS, não oito nomes. É a mesma pergunta que o D17
	# faz aos cascos, e pela mesma razão: quatro carroçarias iguais pintadas de
	# quatro cores seriam quatro etiquetas, e a suíte não saberia a diferença.
	var texturas: Array = []
	for motivo in caminhoes.values():
		for tex in (motivo as Dictionary).values():
			texturas.append(tex)
	var iguais := _repetido_entre(texturas)
	_confere("os %d camiões têm desenhos distintos" % texturas.size(),
		iguais == "", iguais)

	# ── 5 ── a reordenação. Ordem de irmão É profundidade neste plano, e a
	# travessia atravessa a profundidade de meia cena: índice fixo estaria
	# certo num sítio e errado no outro.
	var pos_antes := no0.position
	var indice_antes := no0.get_index()
	no0.position = no0.position + _tela_da_rota(rota[rota.size() - 1], origem0, pr)
	tela.call("_ordenar_por_profundidade", no0)
	var indice_depois := no0.get_index()
	_confere("no fim da travessia ele já mudou de ordem entre os irmãos",
		indice_depois > indice_antes,
		"ficou no índice %d, e começou no %d" % [indice_depois, indice_antes])
	var erro_ordem := ""
	for i in range(cenario.get_child_count()):
		var outro := cenario.get_child(i) as Control
		if outro == null or outro == no0:
			continue
		if outro.position.y < no0.position.y and i > indice_depois and erro_ordem == "":
			erro_ordem = "%s está acima na tela mas depois na ordem" % outro.name
	_confere("e no lugar certo da fila de profundidade", erro_ordem == "", erro_ordem)

	no0.position = pos_antes
	tela.call("_ordenar_por_profundidade", no0)

	# ── 6 ── O DESVIO PARA O BERÇO (07/09).
	#
	# O camião deixou de passar reto: quando a doca do mesmo índice tem barco E
	# trabalhador, ele sai da rua pelo acesso que o `vias()` desenha, encosta no
	# fundo dele e fica até o barco sair. Estas asserções seguram as três coisas
	# que podem apodrecer calado — os números repetidos do gerador, o desvio
	# fora do asfalto, e a condição da visita.
	var acessos_mapa: Array = _ancoras.get("acessos", [])
	var acessos_jogo: Array = consts["ACESSOS_DOCA"]
	var recuo := float(consts["BERCO_RECUO"])

	# ⚠️ UM ACESSO POR VAGA DE DOCA, e a contagem sai da CENA — não de
	# `GameState.docks`, que é quantas o jogador comprou até agora e vale 1 num
	# porto em ruínas. As vagas são as que o mapa desenha píer para, e uma vaga
	# nova sem acesso deixaria um camião sem sítio para onde ir.
	var vagas: int = (tela.get_node("MapaWrap/Docas") as Node).get_child_count()
	_confere("há um acesso publicado por vaga de doca (%d)" % vagas,
		acessos_mapa.size() == vagas,
		"o mapa publica %d" % acessos_mapa.size())
	_confere("e o Main.gd conhece os mesmos %d" % acessos_mapa.size(),
		acessos_jogo.size() == acessos_mapa.size(),
		"o Main.gd tem %d" % acessos_jogo.size())

	var erro_acesso := ""
	for i in range(mini(acessos_jogo.size(), acessos_mapa.size())):
		var do_mapa: Dictionary = acessos_mapa[i]
		var do_jogo: Dictionary = acessos_jogo[i]
		var mx: Array = do_mapa["mx"]
		var entrada: Vector2 = do_jogo["entrada"]
		var paragem: Vector2 = do_jogo["paragem"]
		var pub: Array = do_mapa["entrada"]

		# a) A entrada é a MESMA que o gerador publica. Ela é o meio do asfalto
		#    do degrau na altura do berço — quem mexer no `RUA_RECUO` move-a, e
		#    sem isto a cópia do `Main.gd` ficava no sítio antigo.
		if entrada.distance_to(Vector2(float(pub[0]), float(pub[1]))) > 0.01 \
				and erro_acesso == "":
			erro_acesso = "a entrada da doca %d está em (%.2f, %.2f) e o mapa publica (%.2f, %.2f)" \
				% [i + 1, entrada.x, entrada.y, float(pub[0]), float(pub[1])]

		# b) A paragem é o fundo do acesso menos o recuo — derivada, não escrita.
		var esperada := float(mx[1]) - recuo
		if not is_equal_approx(paragem.x, esperada) and erro_acesso == "":
			erro_acesso = "a paragem da doca %d está em mx %.2f e o acesso acaba em %.2f (recuo %.2f)" \
				% [i + 1, paragem.x, float(mx[1]), recuo]
		if not is_equal_approx(paragem.y, entrada.y) and erro_acesso == "":
			erro_acesso = "a doca %d entra em my %.2f e para em my %.2f — o acesso é reto" \
				% [i + 1, entrada.y, paragem.y]

		# c) A ENTRADA É UM PONTO POR ONDE A ROTA PASSA — num trecho RETO, e
		#    dentro do `my` desse trecho.
		#
		#    ⚠️ AQUI ESTEVE UMA GUARDA QUE NÃO CONSEGUIA REPROVAR, e ela durou
		#    o tempo de se tentar injetar-lhe um defeito. Era um varrimento do
		#    desvio contra o retângulo do acesso — e o desvio é uma reta em `my`
		#    constante entre dois pontos que as alíneas (a) e (b) já prendem aos
		#    números publicados: com aquelas duas de pé, esta não tinha como
		#    falhar. Guarda que nunca reprova é pior do que guarda nenhuma,
		#    porque dá confiança.
		#
		#    A pergunta que SOBRA é outra, e essa é violável: o camião entra no
		#    acesso a partir da rota, e se a entrada não cair num trecho reto
		#    dela o `_pontos_entre()` devolve um percurso com um salto. Mover um
		#    píer em `my` faz exatamente isso.
		var na_rota := false
		for k in range(rota.size() - 1):
			var a2: Vector2 = rota[k]
			var b2: Vector2 = rota[k + 1]
			if abs(b2.x - a2.x) > 0.01:
				continue                     # cotovelo: anda em mx
			if not is_equal_approx(a2.x, entrada.x):
				continue
			if entrada.y >= min(a2.y, b2.y) - 0.01 \
					and entrada.y <= max(a2.y, b2.y) + 0.01:
				na_rota = true
		if not na_rota and erro_acesso == "":
			erro_acesso = "a entrada da doca %d, em (%.2f, %.2f), não cai em trecho reto nenhum da rota" \
				% [i + 1, entrada.x, entrada.y]
		# E o acesso tem de começar DEPOIS da beira de fora da rua, senão o
		# desvio não é desvio nenhum — ele já estaria lá.
		if float(mx[0]) <= entrada.x + 0.01 and erro_acesso == "":
			erro_acesso = "o acesso da doca %d começa em mx %.2f, atrás da entrada (%.2f)" \
				% [i + 1, float(mx[0]), entrada.x]
	_confere("cada desvio bate com o acesso que o mapa desenha", erro_acesso == "",
		erro_acesso)

	# d) E O CAMIÃO ENCOSTADO CABE NO QUADRO. Ele para mais perto da água do que
	#    qualquer ponto da rota, e o terceiro berço é o mais baixo de todos: se
	#    algum sai do mapa, é ali.
	var fora_parado := ""
	for i in range(acessos_jogo.size()):
		var caminhao := cenario.get_node_or_null("Caminhao%d" % i) as Control
		if caminhao == null:
			continue
		var paragem2: Vector2 = acessos_jogo[i]["paragem"]
		var pos := caminhao.position + _tela_da_rota(paragem2, origens[i], pr) \
			+ Vector2(MEIO_QUADRO, MEIO_QUADRO)
		var caixa := Rect2(pos + desenho.position, desenho.size)
		if not visivel.encloses(caixa) and fora_parado == "":
			fora_parado = "o Caminhao%d encostado fica em %s e o mapa é %s" \
				% [i, caixa, visivel]
	_confere("e o camião encostado no berço está inteiro dentro do mapa",
		fora_parado == "", fora_parado)

	# ── 7 ── A CONDIÇÃO DA VISITA, perguntada a quem decide.
	#
	# ⚠️ NÃO SE RECALCULA A REGRA AQUI. A primeira versão do bloco 4 recalculava
	# a silhueta e por isso concordava consigo própria; esta pergunta ao
	# `_visita_da_doca()`, que é quem o jogo usa. E monta os três estados que
	# ela separa — sem barco, com barco e sem trabalhador, com os dois —,
	# porque a regra tem DUAS guardas e um estado só nunca diz qual apertou.
	if GS.phase == "rival_offer":
		GS.resolve_rival_offer(true)
	var doca0: Dictionary = GS.docks[0]
	var barco_antes = doca0["boat"]
	var trab_antes = doca0["worker_id"]

	doca0["boat"] = null
	doca0["worker_id"] = null
	_confere("doca vazia não chama camião nenhum",
		int(tela.call("_visita_da_doca", 0)) == -1)

	doca0["boat"] = {"id": 4242, "motivo": "pescado", "classe": "pesqueiro"}
	_confere("barco sem trabalhador também não",
		int(tela.call("_visita_da_doca", 0)) == -1,
		"o pedido é «ao ALOCAR um navio», e sem operário o porto não está a operar")

	doca0["worker_id"] = 1
	_confere("barco COM trabalhador chama o camião, pelo id do barco",
		int(tela.call("_visita_da_doca", 0)) == 4242,
		"devolveu %d" % int(tela.call("_visita_da_doca", 0)))

	# E o id tem de ser o do BARCO: é ele que distingue um navio que sai de
	# outro que chega no mesmo avanço de dia.
	doca0["boat"] = {"id": 4243, "motivo": "granel", "classe": "cargueiro"}
	_confere("e troca de barco na mesma doca é uma visita nova",
		int(tela.call("_visita_da_doca", 0)) == 4243,
		"devolveu %d" % int(tela.call("_visita_da_doca", 0)))

	doca0["boat"] = barco_antes
	doca0["worker_id"] = trab_antes

	# ── 8 ── NENHUM LOTE RESERVADO EM CIMA DE UM ACESSO.
	#
	# ⚠️ ESTA ASSERÇÃO EXISTE PORQUE OS DOIS PRIMEIROS ESTAVAM ASSIM. Eles foram
	# postos a olho em 07/09, e o `my` de cada um calhava ser exatamente onde
	# começa o acesso ao berço — invisível enquanto o camião passava reto pela
	# rua, e evidente no primeiro frame em que ele entrou na doca e foi encostar
	# em cima da demarcação. Nada perguntava se dois desenhos do MAPA se
	# sobrepõem: o D2 mede pegada de PROP contra faixa, e um lote não é prop.
	var reservados: Array = _ancoras.get("lotes_reservados", [])
	_confere("o mapa publica os lotes reservados", not reservados.is_empty())
	var choque := ""
	for lote in reservados:
		var lmx: Array = lote["mx"]
		var lmy: Array = lote["my"]
		for acesso2 in acessos_mapa:
			var amx: Array = acesso2["mx"]
			var amy: Array = acesso2["my"]
			# Interseção de intervalos nos dois eixos — conferir cantos contra
			# faixa não é conferir o retângulo, e isso já custou um bloco.
			if float(lmx[0]) < float(amx[1]) and float(lmx[1]) > float(amx[0]) \
					and float(lmy[0]) < float(amy[1]) and float(lmy[1]) > float(amy[0]) \
					and choque == "":
				choque = "o lote mx %.2f..%.2f my %.2f..%.2f cai no acesso da doca %d" \
					% [float(lmx[0]), float(lmx[1]), float(lmy[0]), float(lmy[1]),
						int(acesso2["doca"])]
	_confere("nenhum lote reservado pisa um acesso ao berço", choque == "", choque)

	# E nenhum deles transborda para o avental, que é o outro lado do mesmo
	# descuido: 1,7 de largura a partir de um recuo de 2,45 acabava lá dentro.
	var no_avental := ""
	for lote in reservados:
		var lmy: Array = lote["my"]
		var faixa := _faixa_de((float(lmy[0]) + float(lmy[1])) / 2.0)
		var avental: Array = faixa["avental"]
		if float(lote["mx"][1]) > float(avental[0]) + 0.01 and no_avental == "":
			no_avental = "um lote acaba em mx %.2f e o avental começa em %.2f" \
				% [float(lote["mx"][1]), float(avental[0])]
	_confere("e nenhum deles transborda para o avental", no_avental == "", no_avental)
	_d13_completo = true


# O mesmo `tela_da_rota()` do `Main.gd`, mas com a projeção vinda das ÂNCORAS.
# Escrito à mão de propósito: chamar o do jogo faria o teste medir a rota com a
# mesma conta que quer conferir, e uma projeção errada passaria dos dois lados.
func _tela_da_rota(ponto: Vector2, origem: Vector2, pr: Dictionary) -> Vector2:
	var d := ponto - origem
	return Vector2((d.x - d.y) * float(pr["meia_larg"]),
		(d.x + d.y) * float(pr["meia_alt"]))


# ── D18 ── o texto do cartão de doca cabe no cartão
#
# O motivo da escala (06/09) entrou na linha do progresso, e nome de motivo é
# texto que CRESCE: "Armazenagem" tem quase o dobro de "Granel". Texto que não
# cabe num Label do Godot não dá erro nenhum — sai cortado, e a captura do CI
# mostra "Armazenage" sem ninguém reparar.
#
# ⚠️ MEDE-SE O PIOR CASO, MONTADO À MÃO. Ler o que os três cartões mostram
# agora não serve: o cartão de uma doca vazia diz "aguardando barco" e passaria
# sempre. O pior caso é o motivo de nome mais longo com acordo fechado e o
# valor mais alto que o jogo paga ao lado — e é ele que tem de caber.
func _d18_texto_do_cartao() -> void:
	# O autoload vem da árvore e não pelo nome: dentro de um script rodado por
	# `--script` o `GameState` não resolve como identificador.
	var GS: Node = root.get_node("GameState")
	var cartao := _main.get_node("BarraDocas").get_child(0) as Control
	var sb := cartao.get_theme_stylebox("panel", "CartaoDoca")
	var interior: float = cartao.size.x
	if sb != null:
		interior -= sb.content_margin_left + sb.content_margin_right
	_confere("o cartão tem interior medível (%.0f px)" % interior, interior > 0.0)

	var maior := ""
	for id in GS.MOTIVOS:
		var nome: String = GS.MOTIVOS[id]["nome"]
		if nome.length() > maior.length():
			maior = nome

	var cabecalho := cartao.get_node("Coluna/Cabecalho") as HBoxContainer
	var linha := cartao.get_node("Coluna/ProgressoLinha") as HBoxContainer
	var rotulo_nome := cartao.get_node("Coluna/Cabecalho/Nome") as Label
	var rotulo_valor := cartao.get_node("Coluna/Cabecalho/Valor") as Label
	var rotulo_prog := cartao.get_node("Coluna/ProgressoLinha/Progresso") as Label
	var rotulo_trab := cartao.get_node("Coluna/TrabalhadorLinha/Trabalhador") as Label
	var linha_trab := cartao.get_node("Coluna/TrabalhadorLinha") as HBoxContainer

	rotulo_nome.text = "DOCA %d" % GS.BERCOS_NO_MAPA
	# O valor mais alto que o jogo paga sai da tabela das classes, não de uma
	# constante: com três classes, o teto é o da última.
	var teto := 0
	for classe in GS.CLASSES_DE_NAVIO:
		teto = maxi(teto, int(GS.CLASSES_DE_NAVIO[classe]["valor_max"]))
	rotulo_valor.text = GS.moeda(teto)
	_confere("o cabeçalho cabe (%.0f de %.0f px)"
			% [cabecalho.get_combined_minimum_size().x, interior],
		cabecalho.get_combined_minimum_size().x <= interior,
		"[%s | %s]" % [rotulo_nome.text, rotulo_valor.text])

	# Os dois formatos que o cartão escreve, com o nome mais longo nos dois.
	for texto in [
			"%s  ·  %d/%d turnos" % [maior, 0, 3],
			"%s  ·  %d/%d  ·  acordo" % [maior, 0, 3]]:
		rotulo_prog.text = texto
		_confere("a linha do progresso cabe (%.0f de %.0f px)"
				% [linha.get_combined_minimum_size().x, interior],
			linha.get_combined_minimum_size().x <= interior, "[%s]" % texto)

	rotulo_trab.text = "#%d  ·  toque p/ liberar" % GS.BERCOS_NO_MAPA
	_confere("a linha do trabalhador cabe (%.0f de %.0f px)"
			% [linha_trab.get_combined_minimum_size().x, interior],
		linha_trab.get_combined_minimum_size().x <= interior,
		"[%s]" % rotulo_trab.text)

	_d18_completo = true


# ── D19 ── o texto do painel Construir passa a WCAG sobre o branco
#
# ⚠️ COR CALIBRADA PARA UM FUNDO NÃO ATRAVESSA PARA OUTRO. O cinzento-azulado
# neutro do jogo é para a barra ESCURA; sobre o cartão branco deste painel ele
# mede 2,93:1 e reprova até o corte de texto grande. Isso foi apanhado no
# calendário em 03/09 e ficou escrito no `CLAUDE.md` — e o painel Construir
# continuou com ele na descrição de cada estrutura até 06/09, quando a linha do
# nível do porto entrou e o repetiu. Nenhuma suíte perguntava.
#
# O corte é o AA: 4,5:1 para texto abaixo de 18px, 3,0:1 daí para cima.
func _d19_contraste_do_painel() -> void:
	var cena: PackedScene = load("res://scenes/panels/UpgradePanel.tscn")
	var painel: Control = cena.instantiate()
	painel.theme = load("res://ui/tema_brport.tres")
	_main.add_child(painel)

	var fundo := _fundo_do_cartao(painel)
	_confere("achei o fundo do cartão (%s)" % fundo, fundo.a > 0.0)

	var reprovados := 0
	var pior := 99.0
	var pior_texto := ""
	for no in _todos_os_labels(painel):
		var cor: Color = no.get_theme_color("font_color")
		var tamanho: int = no.get_theme_font_size("font_size")
		var corte: float = 3.0 if tamanho >= 18 else 4.5
		var razao := _contraste(cor, fundo)
		if razao < pior:
			pior = razao
			pior_texto = "%s a %dpx" % [no.text.substr(0, 28), tamanho]
		if razao < corte:
			reprovados += 1
	_confere("nenhum rótulo reprova a WCAG (pior: %.2f:1 em %s)"
			% [pior, pior_texto], reprovados == 0,
		"%d rótulo(s) abaixo do corte" % reprovados)

	_main.remove_child(painel)
	painel.queue_free()
	_d19_completo = true


# O fundo em que os rótulos deste painel caem: o `bg_color` do StyleBox do
# PanelContainer do cartão. Ler o tema em vez de escrever a cor à mão é o que
# faz este teste continuar a valer quando o tema mudar.
func _fundo_do_cartao(painel: Control) -> Color:
	for filho in painel.get_children():
		if filho is PanelContainer:
			var sb := (filho as PanelContainer).get_theme_stylebox("panel")
			if sb is StyleBoxFlat:
				return (sb as StyleBoxFlat).bg_color
	return Color(0, 0, 0, 0)


func _todos_os_labels(no: Node) -> Array:
	var out: Array = []
	if no is Label and not (no as Label).text.is_empty():
		out.append(no)
	for filho in no.get_children():
		out.append_array(_todos_os_labels(filho))
	return out


func _luminancia(c: Color) -> float:
	var canais := [c.r, c.g, c.b]
	var lin: Array = []
	for v in canais:
		lin.append(v / 12.92 if v <= 0.04045 else pow((v + 0.055) / 1.055, 2.4))
	return 0.2126 * float(lin[0]) + 0.7152 * float(lin[1]) + 0.0722 * float(lin[2])


func _contraste(a: Color, b: Color) -> float:
	var la := _luminancia(a)
	var lb := _luminancia(b)
	return (maxf(la, lb) + 0.05) / (minf(la, lb) + 0.05)


# ── D20 ── a pista é PISTA no desenho, e não só nas coordenadas
#
# ⚠️ ESTE É O PRIMEIRO BLOCO QUE OLHA PARA A COR DO MAPA, e nasceu de um
# defeito que viveu uma sessão inteira sem que nada o pudesse ver.
#
# Toda a maquinaria de cerco deste projeto pergunta POSIÇÃO: o D2 mede pegada
# de prop contra faixa publicada, o D13 §8 mede lote reservado contra acesso, o
# D14 mede casa contra vão da vila. Nenhuma delas pergunta COM QUE COR o mapa
# pinta um ponto — e foi por aí que passou, desde 07/09, uma FITA DE PASSEIO
# ATRAVESSADA NA PISTA, da largura da rua inteira, na entrada de cada um dos
# cinco cotovelos. A geometria estava certa: todos os retângulos no sítio. Era
# ORDEM DE DESENHO — a calçada do cotovelo saía DEPOIS do asfalto da faixa
# reta, e é 0,22 mais funda do que ele nos quatro lados. Medida no render, em
# (139,260): #aeb8bf, que é a calçada, onde tinha de estar o #49535b da pista.
#
# O QUE ELE LÊ é o SVG do disco, rasterizado pelo ThorVG — o mesmo importador
# do jogo. É a escolha que o `medir_enquadramento` já tinha feito, e pela mesma
# razão: medir o que o jogador vê, e não o que um segundo rasterizador acharia
# que ele vê.
#
# ⚠️ E LÊ-SE O ARQUIVO, NÃO O `load()` DA TEXTURA, que foi a primeira versão e
# durou uma corrida. `load("res://art/porto_mapa_iso.svg")` devolve o `.ctex`
# de `.godot/imported/`, e essa cópia é de quando o projeto foi importado: com
# o mapa regerado nesta sessão, o bloco reprovou a apontar para a fita de
# passeio que já tinha sido CORRIGIDA — o defeito era verdadeiro e a corrida
# era velha. Num teste que lê arte gerada, o arquivo é a fonte e o cache do
# importador é uma resposta de ontem.
#
# POR ONDE ELE ANDA é a `ROTA_ESTRADA`, e isso não é preguiça: ela é uma
# constante ESCRITA À MÃO no `Main.gd` e o mapa sai do gerador, logo as duas
# pontas da asserção têm fontes independentes. O D13 já percorre esta rota
# contra os RETÂNGULOS publicados; aqui ela é percorrida contra o DESENHO, que
# é a pergunta que os retângulos não sabem responder.
#
# ⚠️ E A PERGUNTA É «NÃO É CALÇADA», não «é asfalto». A rodagem leva pintura —
# linha central, passadeira —, e exigir o cinzento do asfalto reprovaria uma
# zebra bem desenhada. O que nunca pode aparecer no meio da pista é o PASSEIO.
#
# ⚠️ E A PRAIA ERA A IRMÃ NÃO VARRIDA. O capim saiu da camada tardia da
# areia quando apareceu por cima de casas e passeio; a areia continuou nela e
# apagava o asfalto no degrau 0. A rota já atravessava o defeito, mas perguntar
# apenas por calçada deixava-o passar. Por isso a mesma amostra veta também os
# quatro tons publicados da areia — outra pergunta, outra asserção.
# A vila é a mesma nos dois mapas; a prova lê o do jogo.
const MAPA_DA_VILA := "res://art/porto_mapa_iso.svg"


# ⚠️ A TEXTURA DO MAPA JÁ NÃO TEM O TAMANHO DA TABELA, E ISSO É DE PROPÓSITO.
# Os quatro SVG de mapa declaram `width="720"` sobre um `viewBox` de 1080; até
# 14/09 o importador entregava 720 e estes blocos amostravam pixel a pixel
# contra as âncoras, que publicam TELA. Com `svg/scale=1.5` (`docs/decisoes/025`)
# a textura passou a sair a 1080 e cada uma daquelas leituras passou a cair
# 1,5x fora do sítio.
#
# A guarda que apanhou isso era a do D20 e a do D24 — "o PNG tem de ter o
# tamanho que a tabela publica" —, e ela estava CERTA: ler no sítio errado é
# pior do que não ler, porque o relvado também não é calçada e tudo passaria.
# O que estava errado era o número 720 estar cravado nela: é a mesma família do
# "número em pixel escrito à mão envelhece calado quando o que ele descreve
# muda de tamanho" que este projeto já registou cinco vezes.
#
# Então a guarda deixa de comparar com 720 e passa a exigir o que ela sempre
# quis dizer: que a imagem seja um múltiplo INTEIRO e IGUAL nos dois eixos do
# que a tabela publica. Uma imagem de outra proporção, mais pequena, ou
# esticada num eixo só continua a reprovar; uma reimportada a 1,5x, a 2x ou de
# volta a 1x passa a ler no sítio certo sem ninguém tocar no teste.
#
# ⚠️ E O FATOR NÃO SE ESCREVE AQUI. Ele sai da imagem contra a tabela, que são
# duas fontes: o `.import` decide uma e o gerador do SVG decide a outra. Um
# fator escrito nesta constante seria o espelho de que o CLAUDE.md avisa —
# montaria o esperado da mesma fonte de qualquer defeito.
class MapaLido:
	var img: Image
	var escala: float = 1.0

	# Tela -> pixel da imagem. Todo bloco que amostre o mapa passa por aqui.
	func px(x: float, y: float) -> Vector2i:
		return Vector2i(int(floor(x * escala)), int(floor(y * escala)))

	func pxv(p: Vector2) -> Vector2i:
		return px(p.x, p.y)

	# Uma distância de TELA na régua da imagem — raios de janela, travessias.
	func dist(d: float) -> float:
		return d * escala

	# Uma ÁREA de tela: a janela de uma prova cresce com o quadrado do fator,
	# então o mínimo de pixels que se exige dela tem de crescer igual. Sem isto
	# o D24 pediria 40 px numa janela 2,25x maior e passaria de graça.
	func area(n: float) -> float:
		return n * escala * escala

	func dentro(p: Vector2i) -> bool:
		return p.x >= 0 and p.y >= 0 \
			and p.x < img.get_width() and p.y < img.get_height()


# Abre um mapa e devolve-o com o fator de escala já conferido, ou `null`.
#
# ⚠️ LÊ O `load()` DA TEXTURA, e não o arquivo, e isso é medição e não descuido:
# rasterizar 1,2 MB de SVG outra vez com `load_svg_from_string()` cai no ThorVG
# nativo do Godot 4.6.3 no Windows. O projeto é importado antes da suíte, então
# esta é a MESMA textura que o jogo recebe — o que a regra do CLAUDE.md sobre o
# cache do importador exige é que ela esteja em dia, e o `--import` faz isso.
func _mapa_lido(caminho: String) -> MapaLido:
	var arq := FileAccess.open(caminho, FileAccess.READ)
	_confere("%s existe" % caminho.get_file(), arq != null)
	if arq == null:
		return null
	arq.close()
	var textura := load(caminho) as Texture2D
	var img := textura.get_image() if textura != null else null
	_confere("%s rasteriza" % caminho.get_file(), img != null)
	if img == null:
		return null
	var lt := int(_ancoras["mapa"]["largura"])
	var at := int(_ancoras["mapa"]["altura"])
	var fx := float(img.get_width()) / float(lt)
	var fy := float(img.get_height()) / float(at)
	var coerente := is_equal_approx(fx, fy) and fx >= 1.0 \
		and is_equal_approx(fx, round(fx * 2.0) / 2.0)
	_confere("%s é um múltiplo coerente dos %dx%d da tabela"
			% [caminho.get_file(), lt, at], coerente,
		"a imagem tem %dx%d, o que dá %.4f x %.4f"
			% [img.get_width(), img.get_height(), fx, fy])
	if not coerente:
		return null
	var m := MapaLido.new()
	m.img = img
	m.escala = fx
	return m
# ⚠️ A JANELA COBRE A PEÇA, e o número saiu de uma medição. A 6 px de raio a
# prova da praça dava ZERO: o piso dela aparece em manchas entre as copas e o
# coreto — 142 pixels de calçada espalhados por um lote de 51x47 —, e um raio
# pequeno cai inteiro dentro de uma copa. A 12 px a janela tem 625 pixels e
# exigem-se 10, que é 1,6%: baixo o suficiente para uma peça entrecortada
# contar, e alto o suficiente para um defeito real dar zero — medido, trocar a
# calçada pelo `solo_claro` que some contra o quintal dá 0.
# O raio e o mínimo vêm agora de CADA prova (ver `pontos_de_prova` no gerador):
# uma peça de 18 px e uma laje de 50 não se medem com a mesma janela. O que
# fica aqui é só a tolerância da prova negativa — alguns pixels de telha na
# janela de uma obra são o beiral da casa vizinha a entrar pela borda, e não um
# telhado em cima dela.
const D24_INTRUSOS := 12

const MAPAS_DA_RUA := ["res://art/porto_mapa_iso.svg",
	"res://art/porto_mapa_iso_patio.svg"]

# Quantas amostras por trecho da rota. 40 põe uma amostra a cada ~0,2 unidades
# no trecho mais longo, que é menos de metade da fita de 0,22 que o bloco
# existe para apanhar — amostrar mais grosso do que o defeito é não amostrar.
const D20_AMOSTRAS := 40

# ⚠️ E A PROVA É UMA JANELA, NÃO UM PIXEL — este foi o último bloco raster do
# projeto a provar por pixel único, e ele reprovou o mapa CERTO em 14/09.
#
# A rota atravessa a fronteira entre o pavimento do pátio (`#ced4d7`) e o
# asfalto (`#49535b`), e o pixel de antisserrilhado dessa fronteira sai a
# `#b1b8bc` — que fica a **3/255** da calçada (`#aeb8bf`), dentro da folga de 4
# que o `_mesma_cor` dá ao próprio antisserrilhado. O ponto está no asfalto: no
# mapa SEM pátio a mesma coordenada é `#49535b` puro em toda a vizinhança.
#
# É a regra do CLAUDE.md *"casar hexadecimal exato só serve em tinta chapada"*
# com a roupa trocada: a rua É chapada, mas a FRONTEIRA entre duas tintas
# chapadas não é, e o valor por que ela passa pode calhar na banda de uma
# TERCEIRA cor da paleta. E é a mesma lição do D17 e do D24 — pergunte quanto
# DESENHO há à volta do ponto, nunca de que cor é o ponto.
#
# O QUE SEPARA AS DUAS FAMÍLIAS É A MASSA, e ela foi medida. A fita de calçada
# que este bloco existe para apanhar (`docs/decisoes/013`) tem a largura da rua
# e 0,22 unidades de profundidade — enche a janela. Um pixel de fronteira tem
# um vizinho de cada lado. Medido na injeção, um cotovelo mal ordenado dá a
# janela CHEIA (49 de 49) e o mapa certo dá no máximo 6.
#
# Os dois números são de TELA e escalam com a imagem: o raio com o fator, o
# mínimo com o quadrado dele.
var _sonda_calcada := 0
var _sonda_areia := 0
const D20_RAIO := 3       # 7x7 = 49 px de tela
const D20_MINIMO := 9     # 18% da janela


func _d20_a_rua_no_desenho() -> void:
	var pr: Dictionary = _ancoras["projecao"]
	var alt := float(pr["alt_cais"])
	var cores: Dictionary = _ancoras.get("cores_da_rua", {})
	_confere("o mapa publica as cores da rua", cores.has("calcada"))
	if not cores.has("calcada"):
		return
	var calcada := Color(str(cores["calcada"]))
	var cores_areia: Dictionary = _ancoras.get("cores_da_areia", {})
	var nomes_areia := ["areia", "areia_seca", "areia_face", "areia_funda"]
	var publica_areia := nomes_areia.all(func(nome): return cores_areia.has(nome))
	_confere("o mapa publica os quatro tons da areia", publica_areia)
	if not publica_areia:
		return
	var areias: Array[Color] = []
	for nome in nomes_areia:
		areias.append(Color(str(cores_areia[nome])))

	var consts: Dictionary = (_main.get_script() as GDScript).get_script_constant_map()
	var rota: Array = consts["ROTA_ESTRADA"]

	for caminho in MAPAS_DA_RUA:
		# O `_mapa_lido` carrega a textura e confere a escala dela contra a
		# tabela. Ler no sítio errado é pior do que não ler — o relvado também
		# não é calçada, e todas as amostras passariam contentes.
		var mapa := _mapa_lido(caminho)
		if mapa == null:
			continue
		var img := mapa.img

		# A janela da prova, na régua desta imagem. Ver `D20_RAIO`/`D20_MINIMO`.
		var raio: int = int(round(mapa.dist(float(D20_RAIO))))
		var minimo: int = int(round(mapa.area(float(D20_MINIMO))))

		_sonda_calcada = 0
		_sonda_areia = 0
		var lidas := 0
		var pior_calcada := ""
		var pior_areia := ""
		for i in range(rota.size() - 1):
			var de: Vector2 = rota[i]
			var para: Vector2 = rota[i + 1]
			for k in range(D20_AMOSTRAS + 1):
				var m: Vector2 = de.lerp(para, float(k) / float(D20_AMOSTRAS))
				var px := _tela(m.x, m.y, alt)
				var q := mapa.px(px.x, px.y)
				var ix := q.x
				var iy := q.y
				if not mapa.dentro(q):
					continue        # a rota entra e sai do quadro de propósito
				lidas += 1
				var cor := img.get_pixel(ix, iy)
				var n_calcada := _contar_cor(img, ix, iy, raio, calcada)
				_sonda_calcada = maxi(_sonda_calcada, n_calcada)
				if n_calcada >= minimo and pior_calcada == "":
					pior_calcada = ("em (%.2f, %.2f) — pixel (%d, %d) — %d px de "
						+ "calçada em %dx%d, e o mínimo é %d; o centro pinta %s") \
						% [m.x, m.y, ix, iy, n_calcada, raio * 2 + 1, raio * 2 + 1,
						   minimo, cor.to_html(false)]
				if pior_areia == "":
					for areia in areias:
						var n_areia := _contar_cor(img, ix, iy, raio, areia)
						_sonda_areia = maxi(_sonda_areia, n_areia)
						if n_areia >= minimo:
							pior_areia = ("em (%.2f, %.2f) — pixel (%d, %d) — %d px de "
								+ "areia em %dx%d, e o mínimo é %d; o centro pinta %s") \
								% [m.x, m.y, ix, iy, n_areia, raio * 2 + 1,
								   raio * 2 + 1, minimo, cor.to_html(false)]
							break
		# ⚠️ E CONFERE-SE QUANTAS FORAM LIDAS. Um recorte mal posto, ou uma rota
		# que saísse inteira do quadro, daria zero amostras e um PASS contente:
		# é o mesmo defeito que o CLAUDE.md descreve como "o defeito injetado
		# não chegou a quem o havia de ver", só que do lado do teste.
		_confere("%s: a rota dá pelo menos 200 amostras dentro do quadro (%d)"
			% [caminho.get_file(), lidas], lidas >= 200)
		_confere("%s: nenhum ponto da rota cai em calçada" % caminho.get_file(),
			pior_calcada == "", pior_calcada)
		_confere("%s: nenhum ponto da rota cai em areia" % caminho.get_file(),
			pior_areia == "", pior_areia)
		print("SONDA %s: janela %dx%d, mínimo %d — máx calçada %d, máx areia %d"
			% [caminho.get_file(), raio*2+1, raio*2+1, minimo, _sonda_calcada, _sonda_areia])
	_d20_completo = true


# ── D25 ── a fauna respeita a régua do mundo, e o toque continua tocável
#
# Uma pessoa mede 15 px na própria arte. A ave e os bichos pequenos não passam
# dela; a capivara pode ser um pouco mais larga, mas continua bem abaixo do
# barco de 44 px que serve de teto para os grandes elementos móveis.
#
# O alvo de toque é irmão do Sprite2D e não encolhe com ele. Fica no piso de
# 44 px: menor faria o polegar errar; maior faria o animal reagir a um toque
# ainda mais longe do corpo minúsculo.
const FAUNA_CENAS := {
	"gaivota": "res://scenes/fauna/Gaivota.tscn",
	"tartaruga_verde": "res://scenes/fauna/TartarugaVerde.tscn",
	"maria_farinha": "res://scenes/fauna/MariaFarinha.tscn",
	"cachorro_caramelo": "res://scenes/fauna/CachorroCaramelo.tscn",
	"quero_quero": "res://scenes/fauna/QueroQuero.tscn",
	"capivara": "res://scenes/fauna/Capivara.tscn",
}
const FAUNA_LARGURAS := {
	"gaivota": 15,
	"tartaruga_verde": 14,
	"maria_farinha": 12,
	"cachorro_caramelo": 15,
	"quero_quero": 13,
	"capivara": 17,
}
const FAUNA_ATE_UMA_PESSOA := [
	"gaivota", "tartaruga_verde", "maria_farinha", "cachorro_caramelo",
	"quero_quero",
]
const LARGURA_BARCO := 44

# ⚠️ E A PESSOA ENCOLHEU UM PIXEL SEM O DESENHO MUDAR — é a FRANJA, e vale a
# pena saber porquê antes de acreditar em qualquer largura deste projeto.
#
# `get_used_rect()` conta todo pixel com alfa acima de ZERO, logo conta o
# antisserrilhado. A franja mede cerca de um TEXEL de cada lado, em qualquer
# resolução: a 512 isso eram ~2 px do quadro de 512, a 768 são ~2 px do quadro
# de 768 — dois terços em coordenada. Medido nos sete desenhos, sem nenhum
# deles ter mudado uma linha:
#
#   trabalhador  15 -> 21 px (14,00)   gaivota    15 -> 22 (14,67)
#   tartaruga    14 -> 21 px (14,00)   cachorro   15 -> 22 (14,67)
#   maria-far.   12 -> 18 px (12,00)   quero-q.   13 -> 19 (12,67)
#   capivara     17 -> 25 px (16,67)
#
# Seis dos sete arredondam para o MESMO número de antes. O sétimo é a pessoa,
# que passou a 14 — e com isso a gaivota (14,67) e o cachorro (14,67) deixaram
# de caber nela. **Elas nunca cabiam:** a 512 as três mediam 15 por EMPATE de
# arredondamento, e a régua mais fina só mostrou os 0,67 px que já lá estavam.
#
# ⚠️ E NÃO HÁ RÉGUA QUE DÊ O MESMO NÚMERO NAS DUAS RESOLUÇÕES — procurei uma.
# A caixa de alfa>0 conta a franja; a de alfa>0,5 salta 43% na maria-farinha,
# cujas patas só chegam a meio alfa a 768; e a largura SUAVE (a soma da
# cobertura máxima por coluna) sobe de +1,4% a +11%, tanto mais quanto mais
# fina for a peça. Não é ruído das réguas: é DESENHO que não cabia num pixel e
# passou a caber. Uma peça com detalhe subpixel não tem largura única.
#
# Então a folga é de UM pixel, e está escrito o que fica de fora: esta guarda
# nasceu medida contra um defeito de DOBRAR a gaivota (30 px contra 14), e um
# pixel não lhe tira nada disso. O que ela deixou de apanhar é um bicho 7%
# maior do que a pessoa — que é onde a gaivota e o cachorro já estavam.
const FAUNA_FOLGA_DA_PESSOA := 1


# ⚠️ OS 15 PX SÃO DE TELA, E A TEXTURA JÁ NÃO OS TEM. Desde a alavanca B o
# `trabalhador.png` desenha a pessoa em 22 px de textura para os mesmos 15 de
# coordenada (`029`) — ler o `get_used_rect()` cru faria esta régua, que é a
# régua de toda a fauna, crescer 50% sem ninguém decidir. E o bicho entra na
# ÁRVORE de propósito: o fator do `Sprite2D` é escrito pelo `_ready()`, e uma
# cena instanciada e não adicionada ainda traz o 1,0 do `.tscn`. Medir o nó que
# nunca correu seria medir o que o jogador não vê.
func _d25_escala_da_fauna() -> void:
	var trabalhador: Texture2D = load("res://art/props/trabalhador.png")
	var largura_pessoa := int(round(PropIso.desenho(trabalhador).size.x))
	_confere("a régua continua sendo uma pessoa de 14 px", largura_pessoa == 14,
		"o trabalhador mede %d px" % largura_pessoa)

	var larguras := {}
	for especie in FAUNA_CENAS:
		var bicho: Node2D = load(FAUNA_CENAS[especie]).instantiate()
		bicho.atraso_inicial = 99.0
		root.add_child(bicho)
		bicho.set_process(false)
		var sprite: Sprite2D = bicho.get_node("Sprite")
		var usado := sprite.texture.get_image().get_used_rect()
		var largura := int(round(float(usado.size.x) * absf(sprite.scale.x)))
		larguras[especie] = largura
		_confere("%s mede os %d px escolhidos" % [especie, FAUNA_LARGURAS[especie]],
			largura == FAUNA_LARGURAS[especie], "mede %d px" % largura)
		if especie in FAUNA_ATE_UMA_PESSOA:
			_confere("%s não passa de uma pessoa por mais de %d px"
					% [especie, FAUNA_FOLGA_DA_PESSOA],
				largura <= largura_pessoa + FAUNA_FOLGA_DA_PESSOA,
				"%d px contra %d" % [largura, largura_pessoa])
		else:
			_confere("a capivara fica entre a pessoa e o barco",
				largura > largura_pessoa and largura < LARGURA_BARCO,
				"%d px; pessoa %d; barco %d" % [largura, largura_pessoa, LARGURA_BARCO])

		var forma: CircleShape2D = bicho.get_node("Toque/Forma").shape
		var diametro := forma.radius * 2.0
		_confere("%s conserva o alvo mínimo de 44 px" % especie,
			is_equal_approx(diametro, TOQUE_MIN), "o alvo mede %.0f px" % diametro)
		root.remove_child(bicho)
		bicho.free()

	_confere("a escala lê gaivota > tartaruga > maria-farinha",
		larguras["gaivota"] > larguras["tartaruga_verde"]
			and larguras["tartaruga_verde"] > larguras["maria_farinha"],
		"%s / %s / %s px" % [larguras["gaivota"], larguras["tartaruga_verde"],
			larguras["maria_farinha"]])
	_confere("a fauna terrestre lê capivara > cachorro > quero-quero",
		larguras["capivara"] > larguras["cachorro_caramelo"]
			and larguras["cachorro_caramelo"] > larguras["quero_quero"],
		"%s / %s / %s px" % [larguras["capivara"], larguras["cachorro_caramelo"],
			larguras["quero_quero"]])
	_d25_completo = true


# ── D26 ── avistamento tem começo, comportamento e fim
#
# Um animal invisível mas ainda clicável não saiu do mundo; um sprite que só
# muda `visible` sem se mover não prova a animação; e uma gaivota que nasce no
# meio do mar continua sendo decoração. Por isso a prova percorre a API real de
# cada cena: espera sem toque, entrada, movimento próprio e saída sem toque.
func _d26_ciclo_da_fauna() -> void:
	for especie in FAUNA_CENAS:
		var bicho: Node2D = load(FAUNA_CENAS[especie]).instantiate()
		bicho.atraso_inicial = 99.0
		root.add_child(bicho)
		bicho.set_process(false)
		var sprite: Sprite2D = bicho.get_node("Sprite")
		var toque: Area2D = bicho.get_node("Toque")

		_confere("%s espera fora do mundo" % especie,
			bicho.estado_atual() == &"esperando" and not sprite.visible)
		_confere("%s escondido não rouba toque" % especie,
			not toque.input_pickable)

		bicho.aparecer_agora()
		var entrada := bicho.position
		_confere("%s entra visível e tocável" % especie,
			bicho.esta_presente() and sprite.visible and toque.input_pickable)
		if especie == "gaivota":
			_confere("a gaivota nasce além de uma borda do mapa",
				entrada.x < 0.0 or entrada.x > 720.0
					or entrada.y < 0.0 or entrada.y > 720.0,
				"nasceu em %s" % entrada)
			bicho._process(1.0)
		elif especie == "maria_farinha":
			bicho._process(0.63) # termina de emergir
			entrada = bicho.position
			bicho._process(0.50) # primeira corrida lateral
		elif especie == "tartaruga_verde":
			bicho._process(0.91) # termina de subir à tona
			entrada = bicho.position
			bicho._process(1.00) # primeira braçada
		elif especie == "cachorro_caramelo":
			bicho._process(0.66) # termina de chegar pelo caminho curto
			entrada = bicho.position
			bicho._process(1.00) # trote antes da primeira farejada
		elif especie == "quero_quero":
			bicho._process(0.49) # pouso curto
			entrada = bicho.position
			bicho._process(0.80) # caminhada pelo gramado
		elif especie == "capivara":
			bicho._process(0.91) # sai da borda da mata
			entrada = bicho.position
			bicho._process(1.50) # caminhada lenta ao pasto
		_confere("%s não fica parado enquanto está presente" % especie,
			bicho.position.distance_to(entrada) > 1.0,
			"moveu %.2f px" % bicho.position.distance_to(entrada))

		bicho.sumir_agora()
		_confere("%s começa uma saída própria" % especie,
			bicho.estado_atual() == &"saindo")
		bicho._process(3.0)
		_confere("%s termina fora do mundo e sem toque" % especie,
			bicho.estado_atual() == &"esperando"
				and not sprite.visible and not toque.input_pickable)
		bicho.free()
	_d26_completo = true


# ── D27 ── quantidade e habitat são parte do desenho, não acaso de cena
#
# Há nove avistamentos, mas só seis espécies: os três bichos costeiros reaparecem
# em outro ponto coerente. Os novos terrestres ficam sobre verde; o segundo
# caranguejo, sobre areia; a segunda tartaruga, sobre água. Assim uma edição de
# coordenada que ponha capivara na rua ou tartaruga em terra falha sem depender
# de uma captura a olho.
func _d27_habitats_da_fauna() -> void:
	var grupo: Node2D = _main.get_node("MapaWrap/Fauna")
	# A posição de cada bicho é TELA (é filho do `MapaWrap`); a textura pode
	# estar noutra escala — ver o cabeçalho do `_mapa_lido`.
	var lido := _mapa_lido("res://art/porto_mapa_iso.svg")
	if lido == null:
		return
	var mapa := lido.img
	var quantidades := {}
	var avistamentos := 0
	for bicho in grupo.get_children():
		if not bicho.has_method("estado_atual"):
			continue
		var especie: String = bicho.especie
		quantidades[especie] = int(quantidades.get(especie, 0)) + 1
		avistamentos += 1

	_confere("o mapa oferece nove avistamentos", avistamentos == 9,
		"encontrados %d" % avistamentos)
	for especie in FAUNA_CENAS:
		var esperado := 2 if especie in ["gaivota", "maria_farinha", "tartaruga_verde"] else 1
		_confere("%s tem %d ponto(s) de aparição" % [especie, esperado],
			int(quantidades.get(especie, 0)) == esperado,
			"encontrados %d" % int(quantidades.get(especie, 0)))

	for nome in ["CachorroCaramelo", "QueroQuero", "Capivara"]:
		var bicho: Node2D = grupo.get_node(nome)
		var cor := mapa.get_pixelv(lido.pxv(bicho.position))
		_confere("%s aparece sobre terra verde" % nome,
			cor.g > cor.r and cor.g > cor.b,
			"posição %s, cor #%s" % [bicho.position, cor.to_html(false)])

	var caranguejo: Node2D = grupo.get_node("MariaFarinhaSul")
	var cor_areia := mapa.get_pixelv(lido.pxv(caranguejo.position))
	_confere("o novo caranguejo aparece na praia sul",
		cor_areia.r > cor_areia.b and cor_areia.g > cor_areia.b,
		"posição %s, cor #%s" % [caranguejo.position, cor_areia.to_html(false)])

	var tartaruga: Node2D = grupo.get_node("TartarugaVerdeNorte")
	var cor_agua := mapa.get_pixelv(lido.pxv(tartaruga.position))
	_confere("a nova tartaruga aparece no baixio norte",
		cor_agua.b > cor_agua.r and cor_agua.g > cor_agua.r,
		"posição %s, cor #%s" % [tartaruga.position, cor_agua.to_html(false)])
	_d27_completo = true


# ── D21 ── quem ESPERA fundeia ao largo; quem ATRACA fica na costeira
#
# Irmão do D20, e pela mesma porta: ali perguntava-se com que cor o mapa pinta a
# PISTA, aqui com que cor ele pinta a ÁGUA debaixo de cada prop. Toda a
# maquinaria de cerco deste projeto mede posição contra faixa publicada, e a
# Zona de Espera não tem faixa nenhuma — ela é um punhado de props postos no
# `Cenario` a olho, e nada perguntava se estavam no sítio certo.
#
# ⚠️ E ELA ESTAVA NO SÍTIO ERRADO DESDE QUE EXISTE. Medido em 11/09, antes de
# a mexer: dos cinco props, TRÊS caíam em `agua_media` — a banda do meio, que
# acompanha a costa — e só dois no largo. As duas boias que MARCAM o fundeadouro
# estavam à profundidade de um berço. A queixa do playtest era *"a área de
# espera pode ficar mais afastada do porto"*, e a razão pela qual ela lia como
# "mais barcos atracados" é esta: estava na água dos atracados.
#
# A pergunta NÃO é "está a N unidades do porto". Distância em unidades não
# sobrevive a um degrau da costa — a mesma conta dá 6,85 para um prop que o mapa
# pinta de `agua_media`, porque perto do degrau a costa mais próxima não é a
# borda da própria banda. Quem sabe onde acaba a água costeira é o mapa.
#
# ⚠️ E AQUI NÃO SE CASA O HEXADECIMAL, ao contrário do D20, porque a ÁGUA LEVA
# COISA POR CIMA. A rua é tinta chapada e compara-se exata; a água leva manchas
# de corrente em gradiente e duas camadas de espuma, todas semitransparentes, e
# o pixel do berço da doca 3 sai a `#3aacc7` onde a paleta diz `#3fb6cf` — fora
# da folga de 4/255 que o `_mesma_cor` dá ao antisserrilhado. A primeira versão
# deste bloco reprovou esse berço, e estava errada ela e não o porto.
#
# O que separa as duas famílias com folga é a LUMINÂNCIA, e o limiar sai
# DERIVADO das cores que o mapa publica — a meio caminho entre a costeira mais
# escura (108,7) e o largo mais claro (76,6), o que dá 92,6 com 16 pontos de
# folga de cada lado. Mancha nenhuma atravessa isso: o berço manchado mede
# 149,7 e o fundeadouro mede 70,6.
#
# São DUAS perguntas e não uma, e nenhuma implica a outra: alguém que alargue a
# banda média até engolir o fundeadouro reprova a primeira e não a segunda;
# alguém que encolha as costeiras até sumirem reprova a segunda e não a primeira
# (o berço passaria a estar em mar aberto, que é tão errado como o contrário).
const ZONA_DE_ESPERA := ["BarcoEspera", "Ancoragem"]


func _luz(c: Color) -> float:
	return (0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b) * 255.0


func _d21_a_zona_de_espera() -> void:
	var cores: Dictionary = _ancoras.get("cores_da_agua", {})
	_confere("a tabela de âncoras publica as faixas de água",
		cores.has("costeiras") and cores.has("largo"))
	if not cores.has("costeiras") or not cores.has("largo"):
		return

	# O limiar DERIVADO. Escrito à mão ele envelheceria calado na primeira vez
	# que alguém mexesse na rampa da água — que é exatamente o que já aconteceu
	# com a paleta em 02/09.
	var escura_costeira := INF
	for hexa in cores["costeiras"]:
		escura_costeira = minf(escura_costeira, _luz(Color(str(hexa))))
	var clara_largo := -INF
	for hexa in cores["largo"]:
		clara_largo = maxf(clara_largo, _luz(Color(str(hexa))))
	_confere("as duas famílias de água separam-se em luminância",
		escura_costeira > clara_largo + 8.0,
		"costeira mais escura %.1f contra largo mais claro %.1f"
			% [escura_costeira, clara_largo])
	if escura_costeira <= clara_largo + 8.0:
		return
	var limiar := (escura_costeira + clara_largo) / 2.0

	# As âncoras dos props e os berços publicados são TELA; a textura pode estar
	# noutra escala — ver o cabeçalho do `_mapa_lido`.
	var lido := _mapa_lido("res://art/porto_mapa_iso.svg")
	if lido == null:
		return
	var img := lido.img

	# Os props saem por VARREDURA do cenário e não de uma lista escrita aqui —
	# um sexto prop no fundeadouro entra sozinho, que é a regra do `teste_fumaca`
	# ("achadas por varredura, não por lista") aplicada a este bloco.
	var cenario := _main.get_node_or_null("MapaWrap/Cenario") as Control
	_confere("há um Cenario para varrer", cenario != null)
	if cenario == null:
		return
	var achados: Array = []
	for no in cenario.get_children():
		if not (no is Control):
			continue
		for prefixo in ZONA_DE_ESPERA:
			if String(no.name).begins_with(prefixo):
				achados.append(no)
				break
	# Lista vazia passaria em tudo o que vem a seguir sem ter olhado para nada.
	_confere("a varredura achou a Zona de Espera", achados.size() >= 2,
		"achou %d prop(s) com prefixo %s" % [achados.size(), ZONA_DE_ESPERA])

	for no in achados:
		var p := _no_mapa(no as Control) + Vector2(MEIO_QUADRO, MEIO_QUADRO)
		var px := lido.pxv(p)
		var dentro := lido.dentro(px)
		_confere("%s cai dentro do mapa" % no.name, dentro, "âncora em %s" % px)
		if not dentro:
			continue
		var luz := _luz(img.get_pixelv(px))
		_confere("%s fundeia AO LARGO, fora das faixas da costa" % no.name,
			luz < limiar,
			"o mapa pinta ali uma água de luminância %.1f, e o largo acaba em %.1f"
				% [luz, limiar])

	# A outra metade do par: um barco ATRACADO está em água costeira. Sem isto,
	# encolher as costeiras até sumirem faria a asserção de cima passar com o
	# fundeadouro exactamente onde está o berço.
	for pier in _ancoras["pieres"]:
		var b: Array = pier["barco"]
		var luz := _luz(img.get_pixelv(lido.px(float(b[0]), float(b[1]))))
		_confere("o berço da doca %d está em água COSTEIRA" % int(pier["doca"]),
			luz > limiar,
			"o mapa pinta ali uma água de luminância %.1f, abaixo do limiar %.1f"
				% [luz, limiar])

	_d21_completo = true


# ── D22 ── o remate da Fase 1 está NA TELA, não debaixo da dobra
#
# ⚠️ ÁREA ROLÁVEL NÃO CORTA — ESCONDE, e ninguém perguntava por este painel.
# O `paragrafo_rolavel` recebia 430 px escritos à mão e a narração pede 847:
# METADE da peça viveu debaixo da dobra desde 01/09, com o botão "Ver o
# balanço" logo abaixo a convidar a sair antes do remate — *"Em quem tá
# olhando."*, que é a linha para onde tudo aquilo anda. As cinco suítes
# passavam; quem apanhou foi a fotografia, e só porque o texto foi crescido.
#
# O diário levou a MESMA mordida em 11/09 e foi remedido; este painel é o irmão
# e ninguém o voltou a abrir. É a regra "ao corrigir um, varra os irmãos" a
# cobrar a fatura.
#
# ⚠️ O QUE ESTA GUARDA PROVA, E O QUE NÃO PROVA. Ela mede com o
# `altura_do_texto()` — a MESMA função com que o painel se dimensiona —, logo
# não apanha um erro DENTRO dessa função: apanha o que de facto se repete, que
# é o TEXTO a crescer para além do que o painel mostra. Que a função bate com o
# motor foi medido à parte e está escrito no comentário dela (847 = 748 + 33x3,
# ao pixel). Não se instancia o painel montado de propósito: o `Label` só sabe
# medir depois de um passe de layout, e nenhuma das suítes deste projeto passa
# frames.
func _d22_narracao_cabe() -> void:
	var GS: Node = root.get_node("GameState")
	GS.clear_save()
	GS.new_game()
	GS.nome_porto = "Cais Mirim"

	var tela: Control = load("res://scenes/EndGame.tscn").instantiate()
	tela.theme = load("res://ui/tema_brport.tres")
	root.add_child(tela)

	var Nar = load("res://scripts/Narrativa.gd")
	var texto: String = Nar.fim_de_fase()
	var pede: int = tela.altura_do_texto(texto, int(tela.LARGURA) - int(tela.MARGEM_CARTAO))
	var teto: int = int(tela.ALTURA_NARRACAO_MAX)
	_confere("a narração inteira cabe sem rolar (pede %d, teto %d)" % [pede, teto],
		pede > 0 and pede <= teto)

	# E ACABA NO REMATE — sem isto, um texto truncado antes de chegar ao painel
	# passaria na asserção acima justamente por ser curto.
	_confere("e a peça acaba no remate dela",
		texto.strip_edges().ends_with("Em quem tá olhando."),
		"acaba em: " + texto.strip_edges().right(30))

	# E O TETO NÃO EMPURRA O CARTÃO PARA FORA DOS 1280 DO RETRATO. O que o
	# painel gasta à volta do texto sai das constantes que o balanço já usa
	# (cartão menos área de texto), em vez de um número novo escrito aqui.
	var moldura: int = int(tela.ALTURA) - int(tela.ALTURA_TEXTO)
	_confere("e o cartão cheio cabe na tela (%d + %d de moldura)" % [teto, moldura],
		teto + moldura <= 1280)

	tela.queue_free()
	_d22_completo = true


# Duas cores chapadas são iguais ou não são; a folga é só para o
# antisserrilhado, que num ponto no meio da faixa de rodagem não chega a
# acontecer.
func _mesma_cor(a: Color, b: Color) -> bool:
	return absf(a.r - b.r) <= 4.0 / 255.0 and absf(a.g - b.g) <= 4.0 / 255.0 \
		and absf(a.b - b.b) <= 4.0 / 255.0


# ── D28 ── as duas pontas são COSTA DESENHADA, e o cais continua reto
#
# Item 8 do segundo playtest, primeira fatia. Medida a costa antes de mexer
# nela, a queixa *"o mapa é quadrado"* tinha endereço: a linha de água das duas
# pontas eram três e cinco traços perfeitamente retos, o maior de 224 px, com
# quinas de 126,9 graus entre eles. A crista da duna já serpenteava desde
# 02/09 — quem era régua era a água.
#
# ⚠️ E NADA NESTE PROJETO PERGUNTAVA A FORMA DE UMA LINHA. O D15 pergunta se a
# praia aparece e quem a pisa, o D20 e o D21 perguntam de que COR o mapa pinta
# um ponto, o D27 pergunta que terreno há debaixo de cada bicho — e uma costa
# que voltasse a ser uma escada passaria em todos eles, contente. É o buraco
# que este bloco tapa, e ele tem de ser tapado dos DOIS lados: uma guarda que
# só exigisse curva seria satisfeita por alguém que curvasse o CAIS, que é
# concreto e tem de ser reto.
#
# São quatro perguntas, e cada uma tem um estado que a viola sem violar as
# outras:
#
#   1. a linha publicada é contínua e cobre o mundo de ponta a ponta;
#   2. nas PRAIAS não há reta longa nem quina dura;
#   3. no CAIS há reta longa, e é a mesma de sempre;
#   4. o mapa pinta ÁGUA de um lado dela e TERRA do outro — que é o que prova
#      que a linha publicada é a linha desenhada, e não uma tabela que
#      envelheceu ao lado do desenho.
#
# A quarta mede a DIFERENÇA de azul entre os dois lados em vez de casar um
# hexadecimal: junto à linha de água a espuma cobre o baixio até 55%, e sobre a
# rampa há pedras cinzentas avulsas — casar tom exato ali reprovaria uma costa
# bem desenhada, que é a armadilha que o D21 já traz escrita.
const D28_CORRIDA_PRAIA := 60.0    # px: a maior reta que uma ponta pode ter
const D28_CORRIDA_CAIS := 150.0    # px: a menor reta que o cais tem de ter
# ⚠️ O LIMIAR DA QUINA É 90 GRAUS DE TELA, e o número não é de gosto: numa
# projeção 2:1 um ângulo reto do MUNDO lê-se como 126,9 graus, e é ele que se
# está a proibir. Medido em cima do desenho, com a janela de 5 px: a costa
# curva das duas pontas mede 62,9 (a volta do fileto, que a projeção comprime),
# e a escada de volta mede 126,9. O limiar fica a meio, com 27 graus de folga
# de um lado e 37 do outro.
const D28_QUINA_PRAIA := 90.0      # graus de TELA entre dois trechos de 5 px
const D28_PASSO_MAX := 18.0        # px: o maior salto entre pontos publicados
# ⚠️ E A LEITURA DE COR É A ÚNICA PERGUNTA QUE NÃO É UM ESPELHO. As três
# primeiras leem a linha que a tabela publica, e a tabela sai da mesma função
# que desenha — o que elas provam é uma PROPRIEDADE dessa linha (é curva; o
# cais não é), que é coisa diferente de a comparar consigo mesma. Esta pergunta
# ao PNG: de que cor o mapa pinta os dois lados dela. Medido com a costa de
# volta à escada, dez das 123 leituras passam a ter areia dos dois lados — é a
# quina da enseada, onde uma perpendicular sai da praia e volta a ela.
#
# (Uma tabela publicada 12 px fora do desenho, pelo contrário, reprova na
# COBERTURA das praias e não aqui: a 10 px de afastamento a leitura de cor
# ainda cai do lado certo. São perguntas diferentes, e é bom que sejam.)
#
# ⚠️ E CHEGOU A HAVER UMA QUINTA, que media a que distância a borda desenhada
# cai da publicada, e foi RETIRADA por reprovar o mapa certo por 7 a 10 px: a
# rampa acaba em pé molhado (escuro, e uma conta de azulidade dá-o por água),
# sobre ela pousam pedras cinzento-azuladas, e na emenda com o cais não há
# areia nenhuma. O defeito que ela existia para apanhar — a tabela deslocada 12
# px — reprova na mesma, aqui e na cobertura das praias.
const D28_ATRAVESSA := 10.0        # px para cada lado da linha, ao ler a cor
const D28_MARGEM_AZUL := 0.10      # o quanto a água tem de ser mais azul


# ⚠️ A RETA MEDE-SE POR CORDA, E NÃO JUNTANDO SEGMENTOS COLINEARES. A primeira
# versão deste bloco juntava segmentos cujo ângulo batesse a menos de meio
# grau, e o defeito injetado — a costa de volta à escada — NÃO REPROVOU a
# asserção da reta: a tabela publica pixel com uma casa decimal, e num
# segmento de 6,7 px meio pixel de arredondamento vale 0,43 grau. O que se
# estava a medir era o ruído do arredondamento, não a forma da linha. Aqui a
# pergunta é a de uma régua pousada em cima do desenho: até onde ela vai sem
# que a linha se afaste mais do que um pixel dela.
const D28_TOLERANCIA := 1.0        # px que a linha pode fugir da régua


func _d28_maior_reta(pontos: Array) -> float:
	var maior := 0.0
	for i in range(pontos.size() - 1):
		for j in range(i + 1, pontos.size()):
			var corda: Vector2 = pontos[j] - pontos[i]
			var comp := corda.length()
			if comp <= maior:
				continue
			var reto := true
			for k in range(i + 1, j):
				var q: Vector2 = pontos[k] - pontos[i]
				if absf(q.cross(corda) / comp) > D28_TOLERANCIA:
					reto = false
					break
			if reto:
				maior = comp
			else:
				break
	return maior


func _d28_maior_quina(pontos: Array) -> float:
	"""A maior curva entre dois trechos de 5 px, que é o que o olho lê como quina."""
	var maior := 0.0
	for i in range(pontos.size()):
		var antes := _d28_direcao(pontos, i, -1)
		var depois := _d28_direcao(pontos, i, 1)
		if antes == Vector2.ZERO or depois == Vector2.ZERO:
			continue
		maior = maxf(maior, absf(rad_to_deg(antes.angle_to(depois))))
	return maior


func _d28_direcao(pontos: Array, i: int, sentido: int) -> Vector2:
	var andado := 0.0
	var j := i
	while andado < 5.0:
		var k := j + sentido
		if k < 0 or k >= pontos.size():
			return Vector2.ZERO
		andado += pontos[k].distance_to(pontos[j])
		j = k
	return (pontos[j] - pontos[i]) * float(sentido)


func _d28_contorno_das_pontas() -> void:
	var contorno: Array = _ancoras.get("contorno", [])
	_confere("a tabela publica o contorno desenhado", contorno.size() >= 100,
		"são %d pontos, e uma costa de seis degraus não cabe em menos" % contorno.size())
	if contorno.size() < 100:
		return
	var praias: Array = _ancoras.get("praias", [])
	if praias.is_empty():
		return

	var pontos: Array = []
	for q in contorno:
		pontos.append(Vector2(float(q[0]), float(q[1])))

	# (1) contínua, e cobrindo cada ponta de uma ponta à outra
	#
	# ⚠️ E O SALTO SÓ SE MEDE NA PRAIA. No CAIS a linha é reta e publica-se com
	# os vértices de sempre — dois pontos a 179 px um do outro, que é o cais
	# inteiro de um degrau e não um buraco. Medir o salto lá reprovaria a única
	# parte do desenho que não mudou.
	var maior_salto := 0.0
	var cobertura := {}
	for i in range(pontos.size()):
		var my := _mundo(pontos[i], 0.0).y
		for j in range(praias.size()):
			var praia: Dictionary = praias[j]
			if my < float(praia["my"][0]) or my > float(praia["my"][1]):
				continue
			if not cobertura.has(j):
				cobertura[j] = [my, my]
			cobertura[j][0] = minf(cobertura[j][0], my)
			cobertura[j][1] = maxf(cobertura[j][1], my)
			if i > 0 and _dentro_de_praia(_mundo(pontos[i - 1], 0.0).y, praias):
				maior_salto = maxf(maior_salto,
					pontos[i].distance_to(pontos[i - 1]))
	_confere("o contorno das pontas não tem buraco nenhum",
		maior_salto <= D28_PASSO_MAX,
		"o maior salto entre dois pontos publicados de praia é de %.1f px"
			% maior_salto)
	for j in range(praias.size()):
		var praia: Dictionary = praias[j]
		var pede: float = float(praia["my"][1]) - float(praia["my"][0])
		var tem: float = (cobertura[j][1] - cobertura[j][0]) if cobertura.has(j) else 0.0
		_confere("o contorno atravessa a praia %.1f..%.1f inteira"
			% [float(praia["my"][0]), float(praia["my"][1])],
			tem >= pede - 0.25,
			"a linha cobre %.2f das %.2f unidades dela" % [tem, pede])

	# (2) e (3): a forma, praia a praia e no cais
	var de_praia: Array = []
	var do_cais: Array = []
	var atual: Array = []
	var na_praia_antes := false
	for i in range(pontos.size()):
		var my := _mundo(pontos[i], 0.0).y
		var e_praia := false
		for praia in praias:
			if my >= float(praia["my"][0]) and my <= float(praia["my"][1]):
				e_praia = true
		if i > 0 and e_praia != na_praia_antes:
			(de_praia if na_praia_antes else do_cais).append(atual.duplicate())
			atual = [pontos[i - 1]]
		atual.append(pontos[i])
		na_praia_antes = e_praia
	(de_praia if na_praia_antes else do_cais).append(atual)

	var pior_reta := 0.0
	var pior_quina := 0.0
	for trecho in de_praia:
		pior_reta = maxf(pior_reta, _d28_maior_reta(trecho))
		pior_quina = maxf(pior_quina, _d28_maior_quina(trecho))
	_confere("nenhuma ponta tem reta maior do que %.0f px" % D28_CORRIDA_PRAIA,
		pior_reta <= D28_CORRIDA_PRAIA,
		"a maior reta de praia mede %.1f px" % pior_reta)
	_confere("nenhuma ponta tem quina de ângulo reto (mais de %.0f graus de tela)"
		% D28_QUINA_PRAIA, pior_quina <= D28_QUINA_PRAIA,
		"a maior quina de praia mede %.1f graus, e um ângulo reto do mundo dá 126,9"
			% pior_quina)

	var melhor_cais := 0.0
	for trecho in do_cais:
		melhor_cais = maxf(melhor_cais, _d28_maior_reta(trecho))
	_confere("o cais continua reto — a maior reta dele passa de %.0f px"
		% D28_CORRIDA_CAIS, melhor_cais >= D28_CORRIDA_CAIS,
		"a maior reta de cais mede %.1f px, e cais é concreto" % melhor_cais)

	# (4) o mapa pinta água de um lado e terra do outro
	#
	# A linha publicada é TELA; a textura pode estar noutra escala — ver o
	# cabeçalho do `_mapa_lido`.
	var lido := _mapa_lido("res://art/porto_mapa_iso.svg")
	if lido == null:
		return
	var img := lido.img
	var lidas := 0
	var trocados := 0
	var pior := ""
	for trecho in de_praia:
		for i in range(trecho.size() - 1):
			var t: Vector2 = (trecho[i + 1] - trecho[i]).normalized()
			var n := Vector2(t.y, -t.x)         # o lado da água
			var meio: Vector2 = (trecho[i] + trecho[i + 1]) * 0.5
			var a := meio + n * D28_ATRAVESSA
			var b := meio - n * D28_ATRAVESSA
			if not (lido.dentro(lido.pxv(a)) and lido.dentro(lido.pxv(b))):
				continue
			# ⚠️ A EMENDA COM O CAIS NÃO ENTRA, e não é para esconder falha: ali
			# a areia ainda não começou e o que está dos dois lados da linha é
			# CONCRETO — o muro de um lado e o enrocamento do outro, os dois
			# cinzentos. Medido, eram as duas únicas leituras que não separavam
			# em 139. O que impede alguém de alargar esta janela até a asserção
			# passar é o piso de leituras, logo abaixo.
			if _perto_do_cais(_mundo(meio, 0.0).y, praias):
				continue
			var agua := img.get_pixelv(lido.pxv(a))
			var terra := img.get_pixelv(lido.pxv(b))
			var azul_agua := agua.b - agua.r
			var azul_terra := terra.b - terra.r
			if azul_agua - azul_terra < D28_MARGEM_AZUL:
				trocados += 1
				if pior == "":
					pior = "no pixel (%d, %d): a %.0f px de um lado o mapa pinta #%s e do outro #%s" \
						% [int(meio.x), int(meio.y), D28_ATRAVESSA,
						   agua.to_html(false), terra.to_html(false)]
				continue
			lidas += 1
	_confere("a linha publicada dá pelo menos 120 leituras dentro do quadro (%d)"
		% lidas, lidas >= 120)
	_confere("de um lado da linha o mapa pinta água e do outro pinta terra",
		trocados == 0, "%d de %d leituras não separam — %s" % [trocados, lidas, pior])


	# (5) e a areia continua longe da rua — o CERCO, antes de o raster o ver
	#
	# O D20 já percorre a rota da estrada a vetar os quatro tons de areia, e é
	# ele quem responde pelo desenho. Esta é a outra metade, e chega primeiro:
	# o recuo publicado é medido na crista DESENHADA, então alguém que suba a
	# amplitude da ondulação até a duna encostar no passeio reprova aqui com o
	# número na mão, em vez de esperar que uma amostra da rota calhe na areia.
	for praia in praias:
		var faixa: Dictionary = _faixa_de(float(praia["my"][0]) + 0.1)
		var borda := float(faixa["borda"])
		var areia0: float = borda - float(praia["recuo"])
		_confere("a areia da praia %.1f..%.1f para antes do passeio"
			% [float(praia["my"][0]), float(praia["my"][1])],
			areia0 > float(faixa["rua"][1]),
			"a areia começa em mx %.2f e o passeio acaba em %.2f"
				% [areia0, float(faixa["rua"][1])])
	_d28_completo = true


func _dentro_de_praia(my: float, praias: Array) -> bool:
	for praia in praias:
		if my >= float(praia["my"][0]) and my <= float(praia["my"][1]):
			return true
	return false


func _perto_do_cais(my: float, praias: Array) -> bool:
	"""A meia unidade da emenda entre a praia e o cais, dos dois lados."""
	for praia in praias:
		if absf(my - float(praia["my"][0])) < 0.6 \
				or absf(my - float(praia["my"][1])) < 0.6:
			return true
	return false


# ── D23 ── o menu-celular: o que ele custou ao rodapé, e o que se lê dentro
#
# Item 17 do segundo playtest. O menu é a primeira tela deste projeto cujo
# fundo é ESCURO, e a primeira peça de rodapé a dividir uma linha com outra —
# duas coisas que nenhuma guarda perguntava. São quatro perguntas, e cada uma
# tem um estado que a viola sem violar as outras (que é o teste de uma
# asserção que não é confiança de graça):
#
#   1. o botão Construir cabe o PIOR texto depois de ceder largura ao menu;
#   2. o toque no botão de menu abre mesmo o painel;
#   3. os rótulos de dentro do celular passam a WCAG sobre a tela ESCURA;
#   4. a grelha de apps cabe na tela do aparelho.
func _d23_menu_celular() -> void:
	var GS: Node = root.get_node("GameState")
	GS.clear_save()
	GS._rng.seed = 20260913
	GS.new_game()
	# Todo bloco que joga resolve a oferta pendente antes de contar com o
	# estado: o `new_game()` tem 30% de abrir contra-oferta, e nessa fase o
	# `advance_turn()` e o `comprar_estrutura()` retornam calados.
	if GS.phase == "rival_offer":
		GS.resolve_rival_offer(true)

	var tela: Control = load(CENA).instantiate()
	root.add_child(tela)

	# ── 1. O PIOR TEXTO DO BOTÃO CONSTRUIR ──
	#
	# ⚠️ O PIOR CASO É O TEXTO QUE O JOGO ESCREVE, NUM ESTADO ESCOLHIDO — e não
	# um texto inventado aqui. A primeira versão deste bloco montava
	# "Construir · 7 estruturas" à mão, e o jogo escreve "Construir · 7
	# disponíveis": a palavra real é MAIS LONGA do que a suposta, então a
	# asserção media um caso mais fácil do que o que o jogador vê. Quem o
	# apanhou foi a captura, não o teste.
	#
	# O botão tem três estados, e o pior é o de mais estruturas por construir:
	# "Porto completo" é curto, e o plural muda entre 1 e vários. O porto que
	# este bloco acabou de montar é novo, logo faltam TODAS — e a asserção
	# abaixo prova que é mesmo esse o estado, senão o pior caso passaria a ser
	# outro sem ninguém dar por isso.
	var construir: Button = tela.get_node("LinhaConstruir/Upgrade")
	var quantas: int = GS.ESTRUTURAS.size()
	_confere("o porto do teste tem as %d estruturas por construir (pior caso do rótulo)"
			% quantas, construir.text.contains(str(quantas)),
		"o botão diz '%s'" % construir.text)
	var pior := construir.text
	var fonte: Font = construir.get_theme_font("font")
	var tam: int = construir.get_theme_font_size("font_size")
	var estilo: StyleBox = construir.get_theme_stylebox("normal")
	var margens: float = estilo.get_margin(SIDE_LEFT) + estilo.get_margin(SIDE_RIGHT)
	var icone: float = float(construir.get_theme_constant("icon_max_width"))
	var separacao: float = float(construir.get_theme_constant("h_separation"))
	var pede: float = fonte.get_string_size(
		pior, HORIZONTAL_ALIGNMENT_LEFT, -1, tam).x + margens + icone + separacao
	# ⚠️ A LARGURA CONTRA A QUAL SE COMPARA É DERIVADA DA LINHA, e não o
	# `size` do botão. A primeira versão deste bloco perguntava
	# `pede <= construir.size.x` e PASSAVA com 5 px de folga — porque um painel
	# que ainda não passou por um frame de layout devolve o tamanho MÍNIMO, que
	# num `Button` é o do próprio texto mais as margens. Ou seja: o esperado e
	# o medido saíam da mesma fonte, e alargar o botão de menu não reprovava
	# nada. É a armadilha do espelho que o `CLAUDE.md` regista a propósito do
	# sorteio de motivos, aqui em forma de pixel.
	#
	# A conta certa é a que a cena documenta: a linha tem uma largura, o menu
	# leva um pedaço fixo dela, e o Construir fica com o resto.
	var linha: HBoxContainer = tela.get_node("LinhaConstruir")
	var largura_linha: float = linha.offset_right - linha.offset_left
	var separa: float = float(linha.get_theme_constant("separation"))
	# ⚠️ `get_combined_minimum_size()`, E NÃO `custom_minimum_size`. O botão
	# declara 46 e ocupa 54: o ícone de 26 mais as margens de 14+14 do tema
	# pedem mais do que o mínimo escrito, e um `custom_minimum_size` menor do
	# que o conteúdo é simplesmente ignorado. Medir o número declarado daria
	# 8 px de folga a mais do que existe.
	var menu_largura: float = (tela.get_node("LinhaConstruir/Menu") as Control) \
		.get_combined_minimum_size().x
	var sobra: float = largura_linha - menu_largura - separa
	_confere("o Construir cabe o pior texto (%s pede %.0f e sobram %.0f de %.0f)"
			% [pior, pede, sobra, largura_linha], pede <= sobra,
		"o botão de menu ficou com largura a mais e este texto sairia cortado")

	# ── 2. O TOQUE NO MENU ABRE O PAINEL ──
	#
	# Mesma prova do D10: o sinal `pressed` de verdade, e não uma chamada
	# direta a `_on_menu_pressed`. Um botão desligado do handler passa em todo
	# o resto deste bloco.
	var botao_menu: Button = tela.get_node("LinhaConstruir/Menu")
	var overlay: Node = tela.get_node("Overlay")
	var antes := overlay.get_child_count()
	botao_menu.pressed.emit()
	_confere("o toque no menu abriu um painel a mais",
		overlay.get_child_count() == antes + 1)
	if overlay.get_child_count() != antes + 1:
		root.remove_child(tela)
		tela.free()
		return

	var menu: Node = overlay.get_child(overlay.get_child_count() - 1)
	var script: Script = menu.get_script()
	_confere("e o painel aberto é o PainelMenu",
		script != null and String(script.resource_path).ends_with("PainelMenu.gd"),
		"script aberto: %s" % (script.resource_path if script != null else "nenhum"))

	# ── 3. O TEXTO DENTRO DO CELULAR, SOBRE A TELA ESCURA ──
	#
	# ⚠️ IRMÃ DO D19, DO OUTRO LADO DA MESMA ARMADILHA. Lá a cor neutra do
	# jogo (feita para fundo escuro) caía sobre o cartão BRANCO e media
	# 2,93:1; aqui a cor de texto PADRÃO do tema é navy, feita para o cartão
	# branco, e cairia sobre a tela navy do aparelho. Um rótulo deste painel
	# que esqueça a variação sai invisível sem erro nenhum.
	#
	# E o fundo lido é o da TELA e não o do CORPO: são dois `PanelContainer`
	# encaixados, e é dentro da tela que os rótulos caem.
	var fundo := _fundo_da_tela_do_celular(menu)
	_confere("achei a tela do celular (%s)" % fundo, fundo.a > 0.0)

	var reprovados := 0
	var pior_razao := 99.0
	var pior_rotulo := ""
	for no in _todos_os_labels(menu):
		var cor: Color = no.get_theme_color("font_color")
		var tamanho: int = no.get_theme_font_size("font_size")
		var corte: float = 3.0 if tamanho >= 18 else 4.5
		var razao := _contraste(cor, fundo)
		if razao < pior_razao:
			pior_razao = razao
			pior_rotulo = "%s a %dpx" % [no.text.substr(0, 28), tamanho]
		if razao < corte:
			reprovados += 1
	_confere("nenhum rótulo do celular reprova a WCAG (pior: %.2f:1 em %s)"
			% [pior_razao, pior_rotulo], reprovados == 0,
		"%d rótulo(s) abaixo do corte sobre a tela do aparelho" % reprovados)

	# ── 4. A GRELHA DE APPS CABE NA TELA ──
	#
	# A grelha cresce sozinha — um app novo, um nome mais comprido — e num
	# `GridContainer` isso alarga a COLUNA em silêncio: o celular tem largura
	# fixa, então o que transborda desenha por fora do aparelho. É a conta que
	# a folha de contato aprendeu a fazer, aplicada a uma tela em vez de a um
	# PNG. A largura útil sai das margens do TEMA, não de um número escrito
	# aqui.
	var grade: GridContainer = _achar_grelha(menu)
	_confere("achei a grelha de apps", grade != null)
	if grade != null:
		# ⚠️ A LARGURA ÚTIL SAI DO TEMA, NÃO DO `size` DOS NÓS. Um painel
		# acabado de instanciar ainda não passou por um frame de layout, e
		# perguntar o tamanho dele devolve ZERO — a asserção passaria a
		# comparar contra nada e nunca reprovaria. Derivada, ela também não
		# envelhece quando as margens do aparelho mudarem.
		var corpo: StyleBox = menu.get_theme_stylebox("panel", "Celular")
		var visor: StyleBox = menu.get_theme_stylebox("panel", "CelularTela")
		var largura: float = float(menu.LARGURA)
		var util: float = largura \
			- corpo.get_margin(SIDE_LEFT) - corpo.get_margin(SIDE_RIGHT) \
			- visor.get_margin(SIDE_LEFT) - visor.get_margin(SIDE_RIGHT)
		var pedem: float = grade.get_combined_minimum_size().x
		_confere("a grelha de apps cabe na tela (pede %.0f, tem %.0f)"
				% [pedem, util], pedem <= util,
			"um app ou um nome a mais e a grelha desenha por fora do aparelho")

	# ── 5. O APP QUE ACENDE ABRE MESMO ──
	#
	# ⚠️ ESTAR NA TABELA NÃO É CHEGAR À TELA. É a pergunta do `barco_medio`
	# (renderizado, validado, e nunca posto em doca nenhuma) e a da fala escrita
	# que nada disparava, aqui numa grelha de apps: o tile do diário podia ser
	# um quadrado bonito cujo `cena` aponta para um caminho errado, e as quatro
	# asserções acima passariam todas.
	#
	# E o menu tem de SAIR ao abrir o app, senão ficam dois painéis empilhados.
	# A pergunta é a da FILA e não `is_inside_tree()`: o `queue_free()` marca o
	# nó e só o tira da árvore no fim do frame, então um painel já condenado
	# responde "estou cá" a quem perguntar assim.
	var tile: Button = _achar_tile_aceso(menu)
	_confere("achei um app aceso na grelha", tile != null)
	if tile != null:
		var antes_app := overlay.get_child_count()
		tile.pressed.emit()
		_confere("o toque no app abriu um painel a mais",
			overlay.get_child_count() == antes_app + 1)
		_confere("e o menu saiu de cena em vez de ficar por baixo",
			menu.is_queued_for_deletion())
		var app: Node = overlay.get_child(overlay.get_child_count() - 1)
		var script_app: Script = app.get_script()
		_confere("e o que abriu é o PainelDiario",
			script_app != null and String(script_app.resource_path).ends_with("PainelDiario.gd"),
			"abriu: %s" % (script_app.resource_path if script_app != null else "nada"))

	root.remove_child(tela)
	tela.free()
	_d23_completo = true


# O primeiro tile que é BOTÃO — os apagados são `PanelContainer` de propósito,
# e procurar por nome cravaria aqui qual app está aceso hoje.
func _achar_tile_aceso(no: Node) -> Button:
	if no is Button and String(no.name).begins_with("Tile_"):
		return no as Button
	for filho in no.get_children():
		var achado := _achar_tile_aceso(filho)
		if achado != null:
			return achado
	return null


# O fundo em que os rótulos do menu caem: a TELA do aparelho, que é o
# `PanelContainer` de variação "CelularTela". Procurado pela variação e não
# pela posição na árvore — o corpo do celular é outro `PanelContainer`, e
# apanhar o primeiro que aparecesse mediria o contraste contra a moldura.
func _fundo_da_tela_do_celular(no: Node) -> Color:
	if no is PanelContainer and String((no as PanelContainer).theme_type_variation) == "CelularTela":
		var sb := (no as PanelContainer).get_theme_stylebox("panel")
		if sb is StyleBoxFlat:
			return (sb as StyleBoxFlat).bg_color
	for filho in no.get_children():
		var achado := _fundo_da_tela_do_celular(filho)
		if achado.a > 0.0:
			return achado
	return Color(0, 0, 0, 0)


func _achar_grelha(no: Node) -> GridContainer:
	if no is GridContainer:
		return no as GridContainer
	for filho in no.get_children():
		var achado := _achar_grelha(filho)
		if achado != null:
			return achado
	return null


# ── D24 ── a igreja, a praça e a obra chegaram ao DESENHO da vila
#
# Item 12 do segundo playtest (`docs/decisoes/022`). A vila ganhou três lotes
# que não são casa, e nenhuma guarda deste projeto perguntava por eles: o
# `asset_validator` mede props, e a vila é ASSADA no SVG — não é prop nenhum.
#
# ⚠️ E A PERGUNTA É AO RASTER, NÃO À TABELA. Recalcular aqui onde a torre
# devia estar seria reconstruir a decisão que se quer conferir — a armadilha
# do espelho, que este projeto já pagou no sorteio de motivos. Em vez disso o
# gerador PUBLICA um ponto de prova por lote especial ("no pixel (x, y) tem de
# estar o remate da igreja") e este bloco pergunta ao PNG o que lá ficou
# pintado. Se o desenho sair na ordem errada, se uma peça tapar a outra, ou se
# alguém trocar a cor por uma que some no fundo, os dois deixam de bater.
#
# É a terceira vez que este projeto lê a COR do mapa: o D20 pergunta-a à rua e
# o D21 à água. Aqui a tinta é chapada, como a da rua, então compara-se exato
# com a folga do antisserrilhado — e não por luminância, que é o que a água
# obrigou a fazer.
func _d24_a_vila_cresce() -> void:
	var provas: Array = _ancoras.get("provas_da_vila", [])
	var cores: Dictionary = _ancoras.get("cores_da_vila", {})
	_confere("o mapa publica as provas da vila", not provas.is_empty())
	_confere("o mapa publica as cores da vila", not cores.is_empty())
	if provas.is_empty() or cores.is_empty():
		return

	# ⚠️ OS TRÊS TIPOS TÊM DE EXISTIR. Sem isto, um `lotes_especiais` que
	# devolvesse só obras passaria o resto do bloco inteiro — cada prova que
	# existisse bateria, e as que faltassem não seriam procuradas por ninguém.
	# É a mesma pergunta do "todo motivo escrito na tabela chega ao jogo?".
	var vistos := {}
	for prova in provas:
		vistos[String(prova["tipo"])] = true
	for tipo in ["igreja", "praca", "obra"]:
		_confere("a vila tem %s" % tipo, vistos.has(tipo),
			"tipos publicados: %s" % str(vistos.keys()))

	# O mesmo cuidado do D20: ler no sítio errado é pior do que não ler, e um
	# PNG noutra escala poria cada prova num pixel qualquer — todas falhariam
	# ou todas passariam, e nenhuma das duas respostas diria alguma coisa. Quem
	# confere a escala é o `_mapa_lido`; as provas publicam TELA.
	var lido := _mapa_lido(MAPA_DA_VILA)
	if lido == null:
		return
	var img := lido.img

	for prova in provas:
		var tipo := String(prova["tipo"])
		var nome_cor := String(prova["cor"])
		var ponto: Array = prova["px"]
		var q := lido.px(float(ponto[0]), float(ponto[1]))
		var ix := q.x
		var iy := q.y
		if not lido.dentro(q):
			_confere("a prova do %s (lote %d) cai no quadro"
				% [tipo, int(prova["lote"])], false,
				"pixel (%d, %d) fora de %dx%d — a peça foi desenhada onde ninguém a vê"
				% [ix, iy, img.get_width(), img.get_height()])
			continue
		# ⚠️ CONTA-SE O DESENHO NUMA JANELA, e não se lê UM pixel. A primeira
		# versão comparava o pixel exato e reprovou três vezes seguidas peças
		# que estavam lá: uma vez por mirar a face lateral de um volume em vez
		# do topo, outra por cair debaixo do telhado do coreto — que em
		# isométrico se projeta para cima e para TRÁS —, e outra num pixel de
		# antisserrilhado entre duas peças. É a lição do D17, onde perguntar
		# "o ponto cai na caixa?" deixava passar uma lança inteira fora do
		# eixo: a pergunta é quanto DESENHO há à volta do ponto.
		#
		# 13x13 são 169 pixels e exigem-se 8 — 4,7%. Baixo o suficiente para
		# uma peça de 5 px de largura contar, e alto o suficiente para não ser
		# satisfeito por uma orla de antisserrilhado, que dá um ou dois.
		# ⚠️ A JANELA E O MÍNIMO ESCALAM JUNTOS, E POR EXPOENTES DIFERENTES.
		# O raio é uma DISTÂNCIA de tela e cresce com o fator; o mínimo é uma
		# CONTAGEM de pixels dentro dela e cresce com o quadrado. Escalar só o
		# raio pediria os mesmos 40 px numa janela 2,25x maior, e a prova
		# passaria de graça — que é a versão em área do "não se aperta o teto de
		# uma guarda até ela apanhar um segundo defeito", com o sinal trocado.
		var raio: int = int(round(lido.dist(float(prova["raio"]))))
		var minimo: int = int(round(lido.area(float(prova["minimo"]))))
		var esperada := Color(String(cores[nome_cor]))
		var achados := _contar_cor(img, ix, iy, raio, esperada)
		_confere("o %s (lote %d) pinta %s à volta de (%d, %d) — %d px em %dx%d"
				% [tipo, int(prova["lote"]), nome_cor, ix, iy, achados,
				   raio * 2 + 1, raio * 2 + 1],
			achados >= minimo,
			"achou %d e o mínimo é %d; o mapa pinta %s no centro"
				% [achados, minimo, img.get_pixel(ix, iy).to_html(false)])

		# ⚠️ A PROVA NEGATIVA, quando a peça se define por uma AUSÊNCIA. A obra
		# é creme como as casas: a contagem acima passa com ela ou sem ela,
		# porque à volta há creme de sobra. O que a faz ser obra é o topo não
		# ter telhado, e dar-lhe um telhado foi um defeito injetado que a guarda
		# positiva deixou passar inteiro.
		for nome_proibida in prova.get("proibidas", []):
			var proibida := Color(String(cores[String(nome_proibida)]))
			var intrusos := _contar_cor(img, ix, iy, raio, proibida)
			_confere("e o %s (lote %d) não tem %s no topo — %d px"
					% [tipo, int(prova["lote"]), String(nome_proibida), intrusos],
				float(intrusos) <= lido.area(float(D24_INTRUSOS)),
				"achou %d pixels de telhado onde devia haver laje" % intrusos)

	_d24_completo = true


func _contar_cor(img: Image, ix: int, iy: int, raio: int, alvo: Color) -> int:
	var n := 0
	for dy in range(-raio, raio + 1):
		for dx in range(-raio, raio + 1):
			var jx := ix + dx
			var jy := iy + dy
			if jx < 0 or jy < 0 or jx >= img.get_width() or jy >= img.get_height():
				continue
			if _mesma_cor(img.get_pixel(jx, jy), alvo):
				n += 1
	return n


# ── D29 ── o casco de um navio não tem bordo reto
#
# Nada neste projeto perguntava a FORMA DE UM PROP. O D28 pergunta a forma de
# uma linha PUBLICADA (o contorno da costa, que sai do gerador numa tabela); o
# D17 pergunta quanto desenho há à volta de um ponto; o D7 pergunta encaixe; a
# guarda dos cascos distintos pergunta se dois props desenham a mesma coisa.
# Um casco que voltasse a ser um polígono de sete pontos passaria em todos
# eles, contente — e foi assim que ele viveu como a peça mais quadrada do kit
# até 14/09 (`docs/decisoes/024`).
#
# A PERGUNTA É A LINHA DE FUNDO, e é ela por uma razão: nada num barco fica
# abaixo do casco. Nem mastro, nem contêiner, nem guindaste, nem chaminé. Logo
# o pixel mais baixo de cada coluna é do CASCO e de mais nada, e dá para medir
# a forma dele sem separar peça nenhuma de um PNG já composto. O bordo de cima
# não serviria: ali passam a superestrutura e a carga.
#
# ⚠️ E A POSIÇÃO SAI COM PRECISÃO SUBPIXEL, senão o que se mede é a escada do
# pixel e não a linha. É a lição do D28 outra vez, do outro lado: lá a métrica
# media o arredondamento da tabela publicada, aqui mediria o degrau da
# rasterização. A borda sai da rampa de alfa, entre o último pixel opaco e o
# primeiro transparente.
#
# A régua é a mesma do D28 — uma corda pousada em cima da linha, que se estende
# enquanto a linha não se afastar mais de um pixel dela.
const D29_TOL := 1.0            # px — o quanto a linha pode fugir da corda
const D29_RETA_MAX := 0.62      # fração do comprimento do casco
# ⚠️ E O CORTE DE TAMANHO É MEDIDO, NÃO ESCOLHIDO — e não é uma lista de nomes.
# O bote tem 42 px e a meia-boca da linha de fundo dele 2,4: a curva INTEIRA
# cabe dentro do pixel de tolerância desta régua, e por isso ele mede 0,60 com
# casco curvo e 0,57 com casco de sete pontos — para o lado errado, por ruído.
# Dar-lhe fundo chato levou-o a 0,62 e, a 6x de ampliação, as três versões são
# a mesma imagem. Abaixo deste comprimento a pergunta não tem resposta, e a
# guarda diz isso em vez de inventar uma. O primeiro casco em que a curva
# sobrevive à tolerância é a traineira, com 65.
const D29_LARG_MIN := 60

# ⚠️ E OS TRÊS NÚMEROS ACIMA SÃO DE TELA, medidos quando a textura e a
# coordenada eram o mesmo pixel. Desde a alavanca B o casco ocupa 1,5x mais
# pixels do PNG (`029`), e deixá-los assim mudaria a guarda duas vezes sem
# ninguém decidir: o bote passaria os 60 px (63) e entraria numa pergunta que
# a medição de 15/09 diz que ele não pode responder, e o `D29_TOL` de 1 px
# passaria a valer 0,67 px de tela, apertando o teto por baixo. Então a linha
# de fundo sai daqui em COORDENADA, e os três números ficam a descrever o que
# foram medidos a descrever. Que a régua ALCANCE agora o bote é verdade e é
# uma linha da tabela do detalhe destravado — outra sessão, com a sua medição.
var _d29_completo := false


## A linha de fundo de um sprite: o pixel mais baixo de cada coluna, subpixel.
func _linha_de_fundo(img: Image) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for x in range(img.get_width()):
		var y1 := -1
		for y in range(img.get_height() - 1, -1, -1):
			if img.get_pixel(x, y).a >= 0.5:
				y1 = y
				break
		if y1 < 0:
			continue
		var y_borda := float(y1)
		if y1 + 1 < img.get_height():
			var a1 := img.get_pixel(x, y1).a
			var a2 := img.get_pixel(x, y1 + 1).a
			if a1 - a2 > 1e-6:
				y_borda = float(y1) + (a1 - 0.5) / (a1 - a2)
		pts.append(Vector2(float(x), y_borda))
	return pts


## A maior corrida da linha que não se afasta `tol` da corda que a fecha.
func _maior_reta(pts: PackedVector2Array, tol: float) -> float:
	var n := pts.size()
	var melhor := 0.0
	var i := 0
	while i < n:
		var j := i + 1
		var ultimo := i
		while j < n:
			var v := pts[j] - pts[i]
			var comp := v.length()
			if comp < 1e-9:
				j += 1
				continue
			var pior := 0.0
			for k in range(i, j + 1):
				var rel := pts[k] - pts[i]
				pior = maxf(pior, absf(rel.x * v.y - rel.y * v.x) / comp)
			if pior > tol:
				break
			ultimo = j
			melhor = maxf(melhor, comp)
			j += 1
		i = maxi(ultimo, i + 1)
	return melhor


func _d29_linha_de_fundo_do_casco() -> void:
	# A lista sai da tabela da arte, como no bloco dos cascos distintos: uma
	# lista cravada aqui seria o `barco_medio` mais uma vez, e um casco novo
	# entraria sem ninguém lhe perguntar a forma.
	var doca := load("res://scripts/Dock.gd") as GDScript
	var cascos := {}
	for classe in doca.get_script_constant_map()["CASCOS"].values():
		for portes in (classe as Dictionary).values():
			for tex in portes:
				cascos[(tex as Texture2D).resource_path] = tex as Texture2D
	_confere("a tabela da arte declara cascos", cascos.size() > 0)

	var medidos := 0
	for caminho in cascos:
		var tex := cascos[caminho] as Texture2D
		var img := (tex.get_image() as Image).duplicate() as Image
		var pts := _linha_de_fundo(img)
		var k := PropIso.escala(tex)
		for i in range(pts.size()):
			pts[i] = pts[i] * k
		if float(pts.size()) * k < float(D29_LARG_MIN):
			# Pequeno demais para a pergunta — ver D29_LARG_MIN.
			print("    (%s tem %d px de tela e fica de fora: a curva cabe na "
				% [String(caminho).get_file(), int(round(float(pts.size()) * k))]
				+ "tolerância da régua)")
			continue
		medidos += 1
		var larg := float(pts.size()) * k
		var reta := _maior_reta(pts, D29_TOL) / larg
		_confere("a linha de fundo de %s não é uma reta (%.0f%% do casco, "
				% [String(caminho).get_file(), reta * 100.0]
				+ "teto %.0f%%)" % (D29_RETA_MAX * 100.0),
			reta <= D29_RETA_MAX,
			"a maior corrida reta cobre %.0f%% do comprimento — um casco de "
				% (reta * 100.0)
				+ "bordo reto é uma cunha, não um navio")
	_confere("D29 mediu algum casco", medidos >= 3,
		"mediu %d — se todos ficarem abaixo de %d px a guarda não guarda nada"
			% [medidos, D29_LARG_MIN])
	_d29_completo = true


# ── D30 ── a metade de cima de um prop pousa na PONTA da de baixo
#
# Alguns props do cenário são DOIS quadros no MESMO `offset`: o coqueiro é copa
# e tronco separados, para a copa balançar sem o tronco andar, e o poste é
# mastro-com-braço mais a luminária. As metades são PNGs independentes, e nada
# perguntava se elas se encontram — uma copa a pairar ao lado de um tronco não
# dá erro nenhum, não reprova o `asset_validator` (que valida cada asset
# sozinho) nem o D2 (que mede pegada contra a rua). É a gola que saiu a
# FLUTUAR dez pixels abaixo do pescoço em 13/09, à escala do mapa.
#
# ⚠️ ELA FICOU FRÁGIL NO DIA EM QUE O TRONCO ARQUEOU (`docs/decisoes/028`).
# Enquanto o tronco era reto o topo dele estava sempre no mesmo sítio; hoje
# DERIVA da curvatura, e a copa anda com ele. Derivado não é provado: quem
# mexer numa das metades sem a outra abre exactamente este buraco.
#
# ⚠️ O PAR SAI DA CENA, não de uma lista escrita aqui — são os nós do cenário
# que partilham a mesma posição. Foi a derivação que achou o SEGUNDO par, que
# eu não sabia que existia; uma lista teria guardado só o coqueiro.
#
# ⚠️ E A PRIMEIRA MÉTRICA REPROVOU O QUE ESTAVA CERTO. Ela pedia que a peça de
# cima COBRISSE o topo da de baixo (a fração de desenho numa janela, a régua do
# D17), e o poste deu 0,11: a luminária não cobre a ponta do braço, ela
# CONTINUA a partir dela. Duas metades de um prop não se sobrepõem — encaixam.
# O que vale para as duas é onde está a MASSA da peça de cima: em cima da ponta
# da de baixo, e não a meio dela nem ao lado.
#
# A distância normaliza-se pela ALTURA DESENHADA da peça de baixo, e isso é de
# propósito: um corte em pixel envelheceria no dia em que o `ZOOM` mudasse, e
# as duas medidas encolhem juntas. Banda medida dos dois lados, POR ESTE
# código e não por uma régua ao lado — encaixado dá 0,075 (o poste) e 0,110 (o
# coqueiro); a copa que NÃO seguiu o tronco curvo, injetada, dá 0,400. O corte
# vai ao meio: 2,4x de folga de um lado e 1,5x do outro.
#
# ⚠️ E ELA DEFENDE O QUE DEFENDE: o defeito medido é uma copa parada enquanto o
# tronco arqueia 30°. Um descolamento de um ou dois pixels passa por baixo
# disto, e está escrito em vez de o teto ser apertado até caber.
const D30_DESCOLAMENTO := 0.26

var _d30_completo := false


func _d30_pecas_co_ancoradas() -> void:
	var cenario := _main.get_node_or_null("MapaWrap/Cenario") as Control
	_confere("a cena tem o Cenario", cenario != null)
	if cenario == null:
		return

	# Agrupa por POSIÇÃO: duas metades do mesmo prop partilham o `offset`.
	var por_ponto := {}
	for filho in cenario.get_children():
		var tr := filho as TextureRect
		if tr == null or tr.texture == null:
			continue
		var chave := "%.2f,%.2f" % [_no_mapa(tr).x, _no_mapa(tr).y]
		if not por_ponto.has(chave):
			por_ponto[chave] = []
		(por_ponto[chave] as Array).append(tr)

	var pares := 0
	var vistos := {}
	for chave in por_ponto:
		var pecas: Array = por_ponto[chave]
		if pecas.size() < 2:
			continue
		# Quem está por CIMA é quem tem o desenho mais alto no quadro.
		var ordenadas: Array = []
		for tr in pecas:
			var t := (tr as TextureRect).texture
			var img := (t.get_image() as Image)
			ordenadas.append([img.get_used_rect().position.y, img,
				String(t.resource_path.get_file())])
		ordenadas.sort_custom(func(a, b): return a[0] < b[0])
		var cima: Image = ordenadas[0][1]
		var centro := _centro_opaco(cima)
		for i in range(1, ordenadas.size()):
			var baixo: Image = ordenadas[i][1]
			var topo := _topo_opaco(baixo)
			# ⚠️ A ALTURA MEDE-SE COM A MESMA RÉGUA DOS PONTOS. O
			# `get_used_rect()` conta a SOMBRA de contacto, que é outra peça e
			# se estende para fora do prop: com ela no denominador, mexer na
			# sombra mexia neste número sem ninguém tocar no encaixe — e a
			# banda medida deixaria de descrever o que o código mede.
			var alt := _altura_opaca(baixo)
			if topo.x < 0 or alt <= 0.0 or centro.x < 0:
				continue
			# Os três coqueiros são o mesmo par de PNGs em três sítios: medir
			# uma vez chega, e repetir a mesma asserção três vezes não é três
			# guardas, é uma a imprimir-se três vezes.
			var id := "%s+%s" % [String(ordenadas[i][2]), String(ordenadas[0][2])]
			if vistos.has(id):
				continue
			vistos[id] = true
			pares += 1
			var d := Vector2(centro).distance_to(Vector2(topo)) / alt
			_confere("a '%s' pousa na ponta da '%s' (%.3f da altura dela, "
					% [String(ordenadas[0][2]), String(ordenadas[i][2]), d]
					+ "teto %.2f)" % D30_DESCOLAMENTO,
				d <= D30_DESCOLAMENTO,
				"as duas metades partilham a âncora e a de cima ficou a "
					+ "pairar longe da ponta da de baixo")
	_confere("D30 achou algum par co-ancorado", pares >= 1,
		"achou %d — sem par nenhum esta guarda não guarda nada" % pares)
	_d30_completo = true


## O ponto mais ALTO do desenho de uma peça (x mediano dessa linha).
func _topo_opaco(img: Image) -> Vector2i:
	var r := img.get_used_rect()
	if r.size.x <= 0:
		return Vector2i(-1, -1)
	for y in range(r.position.y, r.position.y + r.size.y):
		var xs: Array = []
		for x in range(r.position.x, r.position.x + r.size.x):
			if img.get_pixel(x, y).a > 0.5:
				xs.append(x)
		if not xs.is_empty():
			return Vector2i(int(xs[xs.size() / 2]), y)
	return Vector2i(-1, -1)


## A altura do DESENHO de uma peça, pela mesma régua de alfa dos pontos.
func _altura_opaca(img: Image) -> float:
	var r := img.get_used_rect()
	var y0 := -1
	var y1 := -1
	for y in range(r.position.y, r.position.y + r.size.y):
		for x in range(r.position.x, r.position.x + r.size.x):
			if img.get_pixel(x, y).a > 0.5:
				if y0 < 0:
					y0 = y
				y1 = y
				break
	return 0.0 if y0 < 0 else float(y1 - y0 + 1)


## O centro de massa do desenho de uma peça.
func _centro_opaco(img: Image) -> Vector2i:
	var r := img.get_used_rect()
	var sx := 0
	var sy := 0
	var n := 0
	for y in range(r.position.y, r.position.y + r.size.y):
		for x in range(r.position.x, r.position.x + r.size.x):
			if img.get_pixel(x, y).a > 0.5:
				sx += x
				sy += y
				n += 1
	return Vector2i(-1, -1) if n == 0 else Vector2i(sx / n, sy / n)


# ── D31 ── quem MOSTRA um prop reconcilia pixel de textura com coordenada
#
# A pergunta que nada fazia, e que só passou a existir no dia em que as duas
# medidas se separaram. Até 16/09 o PNG tinha 512 px e o nó 512 de lado: não
# havia reconciliação nenhuma a conferir, porque ela era a identidade. Com os
# props a 768 (`docs/decisoes/029`) passou a haver, e ela é invisível:
#
#   · num `TextureRect`, quem a faz é o `expand_mode = 1`. Sem ele o
#     `EXPAND_KEEP_SIZE` põe o mínimo do nó no tamanho da TEXTURA, o rect de
#     512 cresce para 768 e o prop sai 1,5x maior — e nenhuma guarda deste
#     projeto o via. As de ÂNCORA leem `no.position`, que não se mexe; as de
#     pegada e de silhueta leem a textura, que está certa. Só a captura.
#
#   · num `Sprite2D` — a fauna — não há `expand_mode`, e quem a faz é a
#     `scale` que o `Fauna.gd` escreve a partir da própria textura.
#
# ⚠️ E ELA NÃO É A DO D25. O D25 pergunta se a gaivota MEDE os 15 px
# escolhidos, contra uma tabela escrita à mão, espécie a espécie; esta
# pergunta se o nó honra o quadro, seja qual for o tamanho do bicho, e cobre
# os 31 `TextureRect` que o D25 nunca olha. As duas reprovam o mesmo defeito
# na fauna, e isso está escrito de propósito: a que importa aqui é a que
# apanha um prop de mapa, onde não há segunda guarda nenhuma.
const D31_MULTIPLO_MIN := 1.0

var _d31_completo := false


func _d31_quadro_de_quem_mostra() -> void:
	# ⚠️ A VARREDURA É DO `MapaWrap`, E NÃO DA CENA INTEIRA. A primeira versão
	# percorria tudo e reprovou o `Retrato` do cartão do trabalhador: ele mostra
	# um PNG de `art/props/`, é verdade, mas é ARTE DE INTERFACE — mede-se no
	# tamanho do widget (0 x 70 num `TextureRect` de cartão) e não no quadro do
	# mapa, que é a regra escrita no `Retratos.gd` e no CLAUDE.md. Um prop de
	# mapa é o que vive NO mapa; o resto do jogo tem outro contrato, e cobrar
	# este ali seria a "validador que reprova o que está certo".
	var mapa := _main.get_node_or_null("MapaWrap") as Control
	_confere("a cena tem o MapaWrap", mapa != null)
	if mapa == null:
		_d31_completo = true
		return
	var vistos := 0
	for no in _todos_os_nos(mapa):
		var tr := no as TextureRect
		if tr != null and tr.texture != null and _e_prop(tr.texture):
			vistos += 1
			# ⚠️ O `size` DE UM CONTROL É O QUE ELE OCUPA DEPOIS DO MÍNIMO, e
			# é por isso que a pergunta é esta e não "declara expand_mode": um
			# nó com a linha certa e os offsets errados também sai do sítio.
			_confere("%s mantém o quadro de %d coordenadas"
					% [String(tr.name), int(PropIso.QUADRO)],
				is_equal_approx(tr.size.x, PropIso.QUADRO)
					and is_equal_approx(tr.size.y, PropIso.QUADRO),
				"o nó ocupa %.0fx%.0f para uma textura de %dx%d — falta o "
					% [tr.size.x, tr.size.y, tr.texture.get_width(),
					   tr.texture.get_height()]
					+ "`expand_mode = 1`?")
			_confere("%s mostra uma textura múltipla do quadro" % String(tr.name),
				_multiplo_coerente(tr.texture),
				"a textura tem %d px para %d de coordenada"
					% [tr.texture.get_width(), int(PropIso.QUADRO)])
		var sp := no as Sprite2D
		if sp != null and sp.texture != null and _e_prop(sp.texture):
			vistos += 1
			var lado := float(sp.texture.get_width()) * absf(sp.scale.x)
			_confere("%s desenha a textura no quadro de %d"
					% [String(sp.name), int(PropIso.QUADRO)],
				is_equal_approx(lado, PropIso.QUADRO),
				"%d px vezes %.4f dão %.1f de coordenada"
					% [sp.texture.get_width(), sp.scale.x, lado])
	_confere("D31 achou nós que mostram props", vistos >= 30,
		"achou %d — com tão poucos esta guarda não guarda nada" % vistos)
	_d31_completo = true


## Uma textura vinda de `art/props/`, que é o que este bloco julga.
func _e_prop(tex: Texture2D) -> bool:
	return String(tex.resource_path).begins_with("res://art/props/")


## A textura carrega um número inteiro de meios-passos do quadro (1,0; 1,5;
## 2,0...). É a mesma pergunta que o `_mapa_lido` faz ao mapa, e pela mesma
## razão: um tamanho que não seja múltiplo do quadro não é uma alavanca de
## resolução, é um prop gerado com a câmera errada.
func _multiplo_coerente(tex: Texture2D) -> bool:
	if tex.get_width() != tex.get_height():
		return false
	var f := float(tex.get_width()) / PropIso.QUADRO
	return f >= D31_MULTIPLO_MIN and is_equal_approx(f, round(f * 2.0) / 2.0)


## Toda a árvore abaixo de um nó, ele incluído.
func _todos_os_nos(raiz: Node) -> Array:
	var fila: Array = [raiz]
	var saida: Array = []
	while not fila.is_empty():
		var n: Node = fila.pop_back()
		saida.append(n)
		for f in n.get_children():
			fila.append(f)
	return saida


# ── D32 ── a faixa de mensagem com fila (R5 da §7.1)
#
# A faixa ganhou duas coisas em 19/09: um contador "+N" do que espera a vez, e
# o toque que abre o histórico. As duas são o GATE do R5 — "texto recuperável,
# legível e toque mínimo de 44 px na convenção do projeto" — e nenhuma suíte
# as podia ver.
#
# ⚠️ E A COR DO CONTADOR É A QUARTA VEZ QUE ESTE PROJETO TROPEÇA NA MESMA.
# O neutro do jogo (0,51/0,6/0,706) mede **2,82:1** sobre o creme da faixa —
# abaixo até do corte de texto GRANDE —, e é a cor que um rótulo novo herda
# sem ninguém pensar. O que está lá mede 5,27:1. O `CLAUDE.md` regista as
# outras três, no calendário, no painel Construir e no menu-celular.
var _d32_completo := false

const D32_AA_PEQUENO := 4.5


func _d32_faixa_de_mensagem() -> void:
	var cartao := _main.get_node_or_null("MensagemCartao") as PanelContainer
	_confere("D32: a faixa existe", cartao != null)
	if cartao == null:
		return

	# ── o alvo de toque. Ele é o cartão INTEIRO e não um ícone ao lado, e é
	# por isso que passa com folga — mas quem o medir tem de o medir mesmo.
	_confere("D32: a faixa é um alvo de toque legal",
		cartao.size.y >= TOQUE_MIN,
		"mede %.0f px de altura, o mínimo é %.0f" % [cartao.size.y, TOQUE_MIN])

	# ── o contraste do contador contra o FUNDO REAL, que é o creme do
	# StyleBox da faixa e não o branco do cartão de painel.
	var pendentes := _main.get_node_or_null("MensagemCartao/Linha/Pendentes") as Label
	_confere("D32: o contador do que espera existe", pendentes != null)
	if pendentes == null:
		return
	var caixa := cartao.get_theme_stylebox("panel") as StyleBoxFlat
	_confere("D32: e a faixa tem fundo próprio para medir contra", caixa != null)
	if caixa == null:
		return
	var cor: Color = pendentes.get_theme_color("font_color")
	var razao := _contraste(cor, caixa.bg_color)
	_confere("D32: o contador passa o AA de texto pequeno sobre o creme da faixa",
		razao >= D32_AA_PEQUENO, "mede %.2f:1, o corte é %.1f" % [razao, D32_AA_PEQUENO])

	# ── E A PROVA DE QUE A MEDIÇÃO SABE REPROVAR. Sem isto, um `_contraste`
	# avariado daria verde com qualquer cor — é a régua com o defeito injetado
	# embutido, como o `CLAUDE.md` exige de toda régua nova.
	var neutro_do_jogo := Color(0.51, 0.6, 0.706)
	_confere("D32: e a régua reprova o neutro do jogo, que aqui não serve",
		_contraste(neutro_do_jogo, caixa.bg_color) < D32_AA_PEQUENO,
		"o neutro mediu %.2f:1 — se passou, a conta está avariada"
			% _contraste(neutro_do_jogo, caixa.bg_color))

	_d32_completo = true


# ── D33 ── o contraste EFETIVO de toda a interface (R6 da §7.1)
#
# ⚠️ AS TRÊS GUARDAS DE CONTRASTE QUE HAVIA PERGUNTAVAM POR UM PAINEL CADA, e
# foi por aí que o neutro do jogo passou pela QUARTA vez. O D19 percorre o
# painel Construir, o D23 o menu-celular, o D32 o contador da faixa — e o
# `RotuloSecao`, que é uma linha do TEMA, vive em NOVE painéis onde nenhuma das
# três olha: Nomes, Calendário, Docas, Reputação, Caixa, Boletim,
# contra-oferta, Sr. Ribeiro e todo `secao()` do andaime narrativo. Medido em
# 20/09, antes de se mexer: 22 textos abaixo do AA em 19 estados.
#
# Os três não saem. Eles medem coisas que este não mede — o D19 confere que
# ACHA o fundo do cartão, o D23 mede a LARGURA que o menu custou ao rodapé, o
# D32 o alvo de toque da faixa. Antes de dar um teste por redundante, pergunte
# que defeito ele vê que o outro não vê.
#
# O que este bloco acrescenta, e que nenhum outro fazia:
#
#   1. TODO o percurso, e derivado. As cenas de painel saem do DISCO: um painel
#      novo que ninguém acrescente ao percurso reprova aqui, em vez de ficar
#      por medir. Uma lista escrita à mão fecharia esse buraco em silêncio.
#   2. O FUNDO REAL, composto alfa sobre alfa. "O painel é branco" não é uma
#      resposta: a mesma variação mede 5,46:1 no cartão, 5,03:1 no balão da
#      fala e 5,27:1 no creme da faixa.
#   3. COMPOSIÇÃO NÃO RESOLVIDA É PENDÊNCIA, nunca verde. Onde o que está por
#      trás é desconhecido — o cartão da doca tem alfa 0,96 sobre o MAPA — a
#      medição dá as DUAS pontas, e se elas discordarem sobre passar, reprova.
#   4. O MOTIVO DO BLOQUEIO. A WCAG isenta o texto de um componente inativo, e
#      o painel Construir escrevia a explicação DENTRO do botão desligado: a
#      isenção engolia-a, a 2,16:1, com a régua a dá-la por isenta com razão.
#      Aqui, um painel com componente inativo tem de ter texto legível ao lado.
var _d33_completo := false

# Os estados que o percurso já entregou. Sobe quando ele crescer; nunca desce
# sem que alguém escreva por quê.
#
# 22 desde 22/09: os dois estados da faixa de mensagem que faltavam — o aviso
# e o ruim. O terceiro, o BOM, já estava lá e mostrava a cor errada, porque a
# régua não drenava a fila (`docs/decisoes/042`).
#
# 23 desde a 3ª leva de cor: a doca SOB OFERTA DO RIVAL, que é o quarto e
# último fundo do cartão da doca. Ele não era alcançado porque o percurso
# escrevia uma chave morta, e o número ficou a 20 enquanto o comentário já
# dizia 22 — o piso frouxo é o que deixa um estado sumir sem queixa
# (`docs/decisoes/043`).
const D33_ESTADOS_MIN := 23


func _d33_contraste_efetivo() -> void:
	# `load()` e não `preload()`: num `--script`, um `preload` de script que
	# alcance o autoload compila antes de ele existir e devolve um GDScript
	# VAZIO, que só se denuncia como "Nonexistent function" ao ser usado.
	var motor: RefCounted = load("res://scripts/validation/contraste_ui.gd").new()

	# ── O CONTROLE POSITIVO E O NEGATIVO, ANTES DA AUDITORIA. Sem eles, um
	# `contraste()` avariado daria um número plausível em cada uma das 214
	# linhas e o bloco inteiro ficaria verde de graça — a régua muda que dá um
	# NÚMERO, que é pior do que o validador mudo que dá um verde.
	var ruim: PackedStringArray = motor.calibrar()
	_confere("D33: a régua mede e sabe reprovar (5 controles)", ruim.is_empty(),
		", ".join(ruim))
	if not ruim.is_empty():
		return

	# ── O PERCURSO COBRE O DISCO. Derivado, não escrito à mão.
	var no_percurso := {}
	for caso in motor.percurso():
		no_percurso[String(caso["cena"])] = true
	var de_fora := PackedStringArray()
	for cena in motor.paineis_em_disco():
		if not no_percurso.has(cena):
			de_fora.append(String(cena).get_file())
	_confere("D33: o percurso cobre todo painel em scenes/panels/",
		de_fora.is_empty(),
		"fora do percurso: %s" % ", ".join(de_fora))

	var GS: Node = root.get_node("GameState")
	var tema: Theme = load("res://ui/tema_brport.tres")
	var reprovados := PackedStringArray()
	var pendentes := PackedStringArray()
	var sem_motivo := PackedStringArray()
	# As formas de rótulo que aparecem VIVAS em algum estado, e os inativos a
	# confrontar com elas no fim — o percurso inteiro tem de estar medido
	# antes de a pergunta poder ser feita.
	var vivos := {}
	var inativos: Array = []
	var medidos := 0

	for caso in motor.percurso():
		var no: Node = motor.montar_caso(root, GS, caso, tema)
		if no == null:
			continue
		var linhas: Array = motor.medir(no)
		# ⚠️ ZERO TEXTOS NÃO É "ESTE PAINEL PASSOU". Um `setup()` que rebentou
		# deixa a cena montada e VAZIA, e a medição conta zero — a amostra
		# vazia a dar um verde de graça. Mordeu em dois casos ao construir isto.
		_confere("D33: %s produziu texto para medir" % caso["nome"],
			not linhas.is_empty())
		medidos += linhas.size()

		for l in linhas:
			match String(l["estado"]):
				"reprova":
					reprovados.append("%s · %.2f:1 a %dpx (corte %.1f, %s) %s"
						% [caso["nome"], l["razao"], l["px"], l["corte"],
							l["fonte"], l["texto"]])
				"pendente":
					pendentes.append("%s · %s | %s"
						% [caso["nome"], l["nota"], l["texto"]])
				"isento":
					inativos.append([String(caso["nome"]), String(l["texto"])])
				"passa":
					if l["fonte"] != "inativo":
						vivos[_d33_forma(String(l["texto"]))] = true

		root.remove_child(no)
		no.queue_free()

	_confere("D33: nenhum texto abaixo do AA em %d medidos" % medidos,
		reprovados.is_empty(),
		"\n      ".join(reprovados))
	# ⚠️ PENDÊNCIA NÃO É VERDE AUTOMÁTICO. Onde a composição não fecha, a
	# resposta honesta não é escolher a ponta do intervalo que convém.
	_confere("D33: nenhuma composição por resolver", pendentes.is_empty(),
		"\n      ".join(pendentes))
	# ── O MOTIVO DO BLOQUEIO, e a pergunta certa custou duas tentativas.
	#
	# A WCAG isenta o texto de um componente INATIVO, e a isenção é legítima —
	# o problema é quando ela engole a única frase que explica o bloqueio. A
	# primeira versão desta guarda perguntava "o painel tem algum texto
	# legível?", e isso é confiança de graça: todo painel tem um título. Ela
	# teria passado com o defeito posto.
	#
	# A pergunta que SEPARA os dois casos reais é a da FORMA, e ela deriva do
	# próprio percurso em vez de uma lista à mão:
	#
	#   "Pagar R$530.000"  no Sr. Ribeiro sem dinheiro — a MESMA frase existe
	#      viva no estado em que ele pode pagar, logo o rótulo descreve a AÇÃO
	#      e o motivo está noutro sítio ("Caixa: R$1.000", que hoje se lê).
	#   "Precisa antes de: Reconstruir o Píer 2." — esta forma NUNCA aparece
	#      viva em estado nenhum, porque ela só existe por estar bloqueada: o
	#      rótulo é a EXPLICAÇÃO, e a isenção estava a escondê-la a 2,16:1.
	#
	# Os números saem da forma (R$530.000 e R$150.000 são o mesmo rótulo), que
	# é o que faz a comparação ser entre FRASES e não entre estados de caixa.
	for par in inativos:
		if not vivos.has(_d33_forma(par[1])):
			sem_motivo.append("%s · \"%s\"" % [par[0], par[1]])
	_confere("D33: rótulo inativo descreve a AÇÃO, e nunca o motivo do bloqueio",
		sem_motivo.is_empty(),
		"esta forma só existe bloqueada, logo a isenção esconde-a: %s"
			% ", ".join(sem_motivo))
	# ⚠️ E O PERCURSO DECLARA QUANTOS ESTADOS TEM. É a regra da folha de
	# contato — "quem chama diz quantas páginas espera" — com um estado no
	# lugar da página: sem esta linha, apagar o segundo Sr. Ribeiro ou o
	# segundo estado do HUD deixaria o bloco VERDE com menos cobertura, que é
	# exactamente o mutante "estado excluído do percurso". A derivação do disco
	# acima apanha o painel que sai; esta apanha o ESTADO. Contar os TEXTOS não
	# serviria: uma frase a mais num painel esconderia um estado a menos.
	_confere("D33: o percurso não encolheu (%d estados)" % motor.percurso().size(),
		motor.percurso().size() >= D33_ESTADOS_MIN,
		"são %d, e já foram %d — um estado caiu fora"
			% [motor.percurso().size(), D33_ESTADOS_MIN])

	# ⚠️ E O MOTOR NÃO SE QUEIXA POR EXCEÇÃO. O que ele não conseguiu montar
	# fica em `falhas`; sem esta linha, um `setup()` com o argumento errado
	# passaria por "medido" com a cena meia montada.
	var falhas_motor: PackedStringArray = motor.falhas
	_confere("D33: o motor montou todos os estados", falhas_motor.is_empty(),
		", ".join(falhas_motor))

	_d33_completo = true


# A FORMA de um rótulo: sem dígitos, sem moeda e sem pontuação, em minúsculas.
# "Pagar R$530.000" e "Pagar R$150.000" são a mesma frase dita sobre caixas
# diferentes, e é a frase que se está a comparar.
func _d33_forma(texto: String) -> String:
	var fora := ""
	for c in texto.to_lower():
		if c.is_valid_int() or c in ".,:;!?$-—·\"":
			continue
		fora += c
	return " ".join(fora.split(" ", false)).replace("r ", " ").strip_edges()
