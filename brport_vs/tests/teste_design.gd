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
	for tex in _texturas_dos_caminhoes(consts):
		var caixa := PropIso.desenho(tex as Texture2D)
		uniao = caixa if primeiro else uniao.merge(caixa)
		primeiro = false
	return uniao


## Todas as texturas de camião da tabela do `Main.gd`: motivo × empresa ×
## silhueta. Um lugar só desde que a tabela ganhou a EMPRESA (27/09): quatro
## sítios deste arquivo a percorrerem-na à mão eram quatro chances de um deles
## ficar a olhar só para a empresa 0.
func _texturas_dos_caminhoes(consts: Dictionary) -> Array:
	var out: Array = []
	for motivo in (consts["CAMINHOES"] as Dictionary).values():
		for empresa in (motivo as Array):
			for tex in (empresa as Dictionary).values():
				out.append(tex)
	return out

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

	# O ESTADO DERIVA-SE AQUI, E NÃO SE HERDA DO DISCO (`081`). O autoload faz
	# `load_game()` antes de `new_game()`, e o `user://ferramentas/` é o mesmo
	# para toda ferramenta: sem estas linhas o `_main` nascia do save que a
	# corrida ANTERIOR deixou. Medido em 09/10, com o código igual: 1114
	# asserções e 68 casas no D14 com o disco limpo ou em ruínas, 1148 e 102
	# com um porto de sete estruturas no disco — e verde nas três. O D14 passou
	# a montar ele próprio os dois estados (ver lá), e estas linhas seguram o
	# resto: tiradas, com o porto completo no disco, a contagem fica igual mas
	# o D6 mede OUTRO HUD — o botão do Construir a 171 px em vez de 233, os
	# cartões a 104 px de altura em vez de 84. Com elas, os três discos dão as
	# mesmas linhas, uma a uma — conferido em 09/10 e de novo em 10/10, depois
	# do #110 (1223 asserções; a versão sem a derivação dava 1119 ou 1153).
	var GS: Node = root.get_node("GameState")
	GS.clear_save()
	GS._rng.seed = 20260903
	GS.new_game()
	if GS.phase == "rival_offer":
		GS.resolve_rival_offer(true)

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
	print("=== D9: a escolha à espera avisa onde se resolve ===")
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

	print("=== D35: o trânsito — ninguém passa por cima de ninguém ===")
	_d35_transito()
	_confere("o bloco D35 correu até ao fim", _d35_completo)

	print("=== D36: o calendário mostra na grelha o que a legenda promete ===")
	_d36_legenda_do_calendario()
	_confere("o bloco D36 correu até ao fim", _d36_completo)

	print("=== D37: o diário cabe na página do caderno, na pauta ===")
	_d37_diario_na_pagina()
	_confere("o bloco D37 correu até ao fim", _d37_completo)

	print("=== D38: a conversa — cada voz com o seu balão, num telefone que cabe ===")
	_d38_vozes_da_conversa()
	_confere("o bloco D38 correu até ao fim", _d38_completo)

	print("=== D39: o pau-de-carga que descarrega — o casco, a pilha e o guincho ===")
	_d39_trabalhador_que_anda()
	_confere("o bloco D39 correu até ao fim", _d39_completo)

	print("=== D40: o guindaste do nível 2 — a carga de cada serviço, a pilha e quem desengata ===")
	_d40_guindaste_n2()
	_confere("o bloco D40 correu até ao fim", _d40_completo)

	print("=== D41: a virada do dia na tela — o barco parte, o dinheiro conta, o ganho sobe ===")
	_d41_virada_do_dia()
	_confere("o bloco D41 correu até ao fim", _d41_completo)

	print("=== D42: o pórtico do nível 3 e a empilhadeira — o pallet, a pilha e o camião ===")
	_d42_portico_n3()
	_confere("o bloco D42 correu até ao fim", _d42_completo)

	print("=== D43: o rodapé escuro — as colunas dos trabalhadores e o que recua ===")
	_d43_rodape_escuro()
	_confere("o bloco D43 correu até ao fim", _d43_completo)

	print("=== D44: as conversas dos cartões — o balão, a placa e a letra de quem fala ===")
	_d44_conversas_dos_cartoes()
	_confere("o bloco D44 correu até ao fim", _d44_completo)

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
		var img := PropIso.imagem(lancas[i] as Texture2D)
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
		var img_p := PropIso.imagem(pieres[i] as Texture2D)
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
#
# ⚠️ E ESSA MÉDIA SÓ EXISTIA NO COMENTÁRIO até 23/09. A redução era
# `Image.resize(16, 16, INTERPOLATE_BILINEAR)`, e numa redução de 48x (768 ->
# 16) ela não faz a média dos 2.304 pixels de cada célula. Enquanto os props
# eram grandes e de silhuetas diferentes, isso calhava de os separar; com os
# camiões do retorno ela reprovou o frigorífico de ida contra o de retorno com
# 0,0039 — dois desenhos com 1.106 pixels diferentes, a cabine numa ponta e na
# outra, que pela média de verdade (medida em Python) diferem 0,062.
# ⚠️ E `INTERPOLATE_TRILINEAR` DEU O MESMO 0,0039, medido — trocar o modo não
# chegava. A média faz-se à mão: `shrink_x2()`, que é a média exata 2x2,
# enquanto couber, e o resto por blocos.
const ASSINATURA := 16
# ⚠️ E O CORTE DESCEU DE 0,02 PARA 0,01 COM A MÉDIA. Os 0,02 (5/255) eram
# para uma redução que não fazia média e deixava passar o ±2/255 do denoiser.
# Com a média de 2.304 pixels por célula, algumas dezenas de pixels a ±2/255
# valem ~0,0002; e o par DISTINTO mais perto entre os 25 desenhos (camiões e
# cascos, medido em 23/09) é o frigorífico de ida contra o de retorno em `mx`,
# a 0,0327. A 0,02 sobrava 1,6x desse lado; a 0,01 sobram 50x do ruído e 3,3x
# do par mais perto — o corte vai para o MEIO da banda, não para a ponta.
const ASSINATURA_MIN := 0.01


func _assinatura(tex: Texture2D) -> PackedFloat32Array:
	var img := PropIso.imagem(tex).duplicate() as Image
	var v := PackedFloat32Array()
	# Quadro que não se divide em 16 células iguais não tem média por célula:
	# recusar é melhor do que devolver uma assinatura que parece medida.
	if img.get_width() % ASSINATURA != 0 or img.get_height() != img.get_width():
		push_error("assinatura: %s tem %s, que não se divide em %d células"
			% [tex.resource_path, img.get_size(), ASSINATURA])
		return v
	while img.get_width() % (2 * ASSINATURA) == 0:
		img.shrink_x2()
	var k := img.get_width() / ASSINATURA
	for y in range(ASSINATURA):
		for x in range(ASSINATURA):
			var soma := Color(0, 0, 0, 0)
			for dy in range(k):
				for dx in range(k):
					soma += img.get_pixel(x * k + dx, y * k + dy)
			var c := soma / float(k * k)
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

	# (2) nenhuma casa debaixo da silhueta de um prédio do pátio — nos DOIS
	# estados em que o prédio existe. O mesmo nó troca de textura (ruína e
	# pronto), e o vão da vila tem de servir aos dois: a ruína é MENOS prédio,
	# o pronto é o que mais tapa. Até 09/10 o bloco via só o estado que o disco
	# trazia (`081`); hoje monta os dois, e devolve o estado da partida no fim.
	var GS: Node = root.get_node("GameState")
	var estruturas_antes: Array = GS.estruturas.duplicate()
	GS.estruturas = []
	_main.call("_refresh_estruturas")
	var em_ruina := _d14_predios_sobre_a_vila(lotes, "em ruína")
	GS.estruturas = GS.ESTRUTURAS.keys()
	_main.call("_refresh_estruturas")
	var completo := _d14_predios_sobre_a_vila(lotes, "porto completo")
	GS.estruturas = estruturas_antes
	_main.call("_refresh_estruturas")
	# O caso que declara um estado prova que o obteve (`043`): com o porto
	# completo, pelo menos um prédio a mais passa o corte de silhueta. Se a
	# montagem não chegasse aos nós, as duas contagens sairiam iguais e o
	# «porto completo» seria a ruína com outro nome.
	_confere("D14: o porto completo põe mais prédio grande sobre a vila do que a ruína",
		completo > em_ruina,
		"%d prédios em ruína e %d com o porto completo — a troca de textura "
		% [em_ruina, completo] + "não chegou ao cenário")

	# (3) as duas fileiras separam-se por mais de um telhado.
	var meia_larg := float(_ancoras["projecao"]["meia_larg"])
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


# A pergunta (2) do D14 sobre o cenário COMO ESTÁ: devolve quantos prédios
# passaram o corte de silhueta, para quem chama provar que montou o estado.
func _d14_predios_sobre_a_vila(lotes: Array, estado: String) -> int:
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
			_confere("%s (%s) não tapa a casa em my=%.2f"
				% [no.name, estado, float(l["my"])],
				not tapa,
				"a casa cai a %.0fpx da coluna do prédio e %.0fpx acima da base "
				% [dx, dy] + "dele, num sprite de %dx%d" % [usado.size.x, usado.size.y])
	_confere("houve prédio grande para conferir contra a vila (%s)" % estado,
		conferidos > 0,
		"nenhum prop passou de %.0fpx — o filtro comeu tudo"
		% (SILHUETA_QUE_EXIGE_PEGADA_MUNDO * meia_larg))
	return conferidos


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
	var pilha := ["MapaWrap", "BarraDocas", "FilaTitulo", "Fila",
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
	alvos.append(_main.get_node("AcoesTurno/Avancar"))
	alvos.append(_main.get_node("LinhaConstruir/Upgrade"))
	alvos.append(_main.get_node("LinhaConstruir/Menu"))
	alvos.append(_main.get_node("HudBar/Pausar"))
	for c in _main.get_node("BarraDocas").get_children():
		alvos.append(c)
	# Os cartões da fila são o toque que atraca (`083`): o gesto mais repetido
	# do jogo, todos os dias.
	for c in _main.get_node("Fila").get_children():
		alvos.append(c)
	for c in alvos:
		_confere("%s cabe no dedo (%.0fx%.0f)" % [c.name, c.size.x, c.size.y],
			c.size.y >= TOQUE_MIN and c.size.x >= TOQUE_MIN,
			"mínimo é %.0f em cada lado" % TOQUE_MIN)


# ── D9 ── o aviso de escolha à espera tem de aparecer ONDE ela se resolve
#
# O primeiro playtest num telefone avançou o dia com dois operários livres e
# duas docas sem trabalhador, e o lado que RESOLVIA o problema não avisava
# nada. Desde a `083` o problema é outro — berço livre com barcos ao largo —,
# e a regra é a mesma: o aviso aparece onde se toca para o resolver.
#
# Este bloco monta esse estado e exige os três sinais: o rótulo «Ao largo» em
# âmbar a contar os berços livres, os cartões da fila acesos, e o píer livre a
# piscar no mapa. São a MESMA contagem porque saem todos da
# `atracagem_pendente()`.
func _d9_aviso_de_trabalho_parado() -> void:
	var GS: Node = root.get_node("GameState")
	GS.clear_save()
	GS._rng.seed = 20260903
	GS.new_game()
	if GS.phase == "rival_offer":
		GS.resolve_rival_offer(true)
	for i in range(GS.docks.size()):
		GS.docks[i]["worker_id"] = null
		GS.docks[i]["boat"] = null
	GS.fila = []
	for i in range(GS.FILA_LUGARES):
		var b: Dictionary = GS._make_boat()
		b["rival"] = false
		GS.fila.append(b)

	var tela: Control = load(CENA).instantiate()
	root.add_child(tela)
	var pendente: Vector2i = GS.atracagem_pendente()
	_confere("o estado de teste tem mesmo escolha à espera", pendente != Vector2i.ZERO,
		"atracagem_pendente() devolveu %s e o bloco não testa nada" % pendente)

	var titulo: Label = tela.get_node("FilaTitulo")
	_confere("o rótulo nomeia a doca livre",
		titulo.text.begins_with("Doca %d livre" % (GS.berco_livre() + 1)),
		"diz \"%s\"" % titulo.text)
	# E com DUAS livres e a do meio ocupada, nomeia as duas e não a do meio: o
	# porto abre com uma doca só, e com uma «nomeia» e «conta» dão o mesmo
	# texto (a regra da contagem acima de um). O estado escreve-se nas docas
	# do `GameState` e devolve-se logo a seguir; o título lê só o `boat`.
	var docas_antes: Array = GS.docks.duplicate(true)
	GS.docks = [{"boat": null, "worker_id": null},
		{"boat": GS._make_boat(), "worker_id": 2},
		{"boat": null, "worker_id": null}]
	tela._refresh_titulo_fila()
	_confere("com as docas 1 e 3 livres, o rótulo nomeia as duas",
		titulo.text.begins_with("Docas 1 e 3 livres"), "diz \"%s\"" % titulo.text)
	GS.docks = docas_antes
	tela._refresh_titulo_fila()
	_confere("e está na cor de aviso, não na neutra",
		titulo.get_theme_color("font_color").is_equal_approx(COR_AVISO),
		"está em %s" % titulo.get_theme_color("font_color"))

	# O cartão: o sinal é o FUNDO (`CartaoDocaEspera`, a borda âmbar), como na
	# doca que esperava trabalhador até à `083`.
	var tema: Theme = load("res://ui/tema_brport.tres")
	var esperado: StyleBox = tema.get_stylebox("panel", "CartaoDocaEspera")
	var acesos := 0
	for cartao in tela.get_node("Fila").get_children():
		if (cartao as Control).get_theme_stylebox("panel") == esperado:
			acesos += 1
	_confere("todo barco pronto ao largo tem o cartão aceso",
		acesos == pendente.y, "%d cartões acesos para %d barcos" % [acesos, pendente.y])

	# E o píer que o próximo toque enche pisca no mapa.
	var livre: int = GS.berco_livre()
	var doca: Node = tela.get_node("MapaWrap/Docas").get_child(livre)
	_confere("e o berço que o toque enche está realçado no mapa",
		doca._tw_realce != null and doca._tw_realce.is_valid())

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
	# a mesma regra do `BarcoFila.gd` (reagir no toque que solta).
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
		texto_inteiro.contains("SE AVANÇAR AGORA"), "painel diz: %s" % texto_inteiro)

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
		["Docas", "DE %d BERÇOS" % int(GS.BERCOS_NO_MAPA)])

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
	# ⚠️ ESTA ASSERÇÃO PERGUNTOU PELO `COR_AVISO` ATÉ 20/09 E PELO
	# `RotuloAlerta` ATÉ 04/10, e apanhou as duas mudanças — que é o que ela
	# existe para fazer. O cartão passou de branco a escuro (`081`), e o âmbar
	# escurecido que servia ao branco mediria 2,93:1 ali; o convite veste o
	# âmbar CLARO da pílula. A pergunta continua a ser a MESMA — "o convite
	# destaca-se?" —, feita à cor FINAL e contra o fundo que o cartão
	# DESENHA, composto sobre o fundo da tela, e não contra um branco suposto.
	var cor_convite: Color = rotulo.get_theme_color("font_color")
	_confere("e o convite sai no âmbar claro do tema",
		cor_convite.is_equal_approx(
			(load("res://ui/tema_brport.tres") as Theme)
				.get_color("font_color", "TextoPilulaDestaque")),
		"saiu %s" % cor_convite)
	var caixa_meta := (tela.get_node("MetaCartao") as PanelContainer).get_theme_stylebox(
		"panel") as StyleBoxFlat
	var fundo_tela: Color = (tela.get_node("Fundo") as ColorRect).color
	var fundo_meta: Color = fundo_tela.lerp(caixa_meta.bg_color, caixa_meta.bg_color.a) \
		if caixa_meta != null else Color(1, 1, 1)
	fundo_meta.a = 1.0
	_confere("e essa cor passa o AA sobre o cartão da parcela, como ele se desenha",
		caixa_meta != null and _contraste(cor_convite, fundo_meta) >= 4.5,
		"mede %.2f:1 sobre %s" % [_contraste(cor_convite, fundo_meta), fundo_meta])
	# ⚠️ E O NÚMERO DO CONVITE É O DA PORTA (`081`). Até 04/10 a linha dizia
	# «R$1.045.000 de R$530.000», que se lia como 197%; hoje diz o valor de
	# HOJE, que é o que a tarja do painel mostra e o botão de lá tira — e o
	# F15 do fumaça prova a tarja contra o botão. Aqui prova-se o elo que
	# faltava: o cartão contra o jogo.
	var hoje: int = GS.valor_da_parcela_hoje()
	_confere("e o convite diz o valor de hoje, que é o que a porta cobra",
		rotulo.text.contains(GS.moeda(hoje)),
		"diz \"%s\", o valor de hoje é %s" % [rotulo.text, GS.moeda(hoje)])

	_confere_chip_abre(tela, overlay, "MetaCartao", "PainelParcela.gd",
		["Parcela do Sr. Ribeiro", "Quitar hoje"])

	# Sem caixa, o convite SOME — senão ele prometeria uma ação que a porta
	# do outro lado recusa.
	#
	# ⚠️ E O LIMIAR É O DA PORTA, NOS DOIS LADOS (`081`). Até 04/10 o
	# cartão comparava com a parcela CHEIA e a porta com o valor de HOJE: entre
	# os dois a porta já abria e o cartão dizia «faltam». Um real abaixo do
	# valor de hoje fecha os dois; o valor exato abre os dois — e é a segunda
	# metade que apanha o limiar de volta à parcela cheia, que a primeira
	# deixava passar (o cheio também está acima de `hoje - 1`).
	GS.cash = hoje - 1
	tela.call("_refresh_hud")
	_confere("sem caixa, o convite desaparece",
		not rotulo.text.contains("toque") and not GS.pode_pagar_parcela_adiantado(),
		"diz \"%s\"" % rotulo.text)
	GS.cash = hoje
	tela.call("_refresh_hud")
	_confere("com o valor de hoje exato, o convite aparece e a porta abre",
		rotulo.text.contains("toque") and GS.pode_pagar_parcela_adiantado(),
		"diz \"%s\"" % rotulo.text)

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
	#
	# ⚠️ E POR EMPRESA (27/09, `070`): cada serviço tem duas transportadoras, e
	# a silhueta tem de sair da linha da empresa pedida — nunca da outra, que
	# desenharia o camião certo com a cabine da vizinha.
	var GS: Node = root.get_node("GameState")
	var errado := ""
	var vistas := {}
	var pedidas := 0
	for motivo in GS.MOTIVOS:
		var id := String(motivo)
		_confere("o motivo %s tem camião" % id, caminhoes.has(id),
			"`CAMINHOES` do Main.gd conhece %s" % [caminhoes.keys()])
		if not caminhoes.has(id):
			continue
		var empresas: Array = caminhoes[id]
		for e in range(empresas.size()):
			pedidas += 2
			for i in range(rota.size() - 1):
				var de: Vector2 = rota[i]
				var para: Vector2 = rota[i + 1]
				var anda_em_mx: bool = abs(para.x - de.x) > 0.01
				var usada: Texture2D = tela.call("silhueta_do_trecho", de, para, id, e)
				var caminho: String = usada.resource_path
				vistas[caminho] = true
				if anda_em_mx != caminho.ends_with("_mx.png") and errado == "":
					errado = "o trecho %d de %s anda em %s e usa %s" \
						% [i, id, "mx" if anda_em_mx else "my", caminho.get_file()]
				# A ida anda de FRENTE: a silhueta do retorno aqui seria o camião a
				# descer de costas. O teste do eixo não o via, porque os dois
				# `_mx` acabam igual.
				if caminho.contains("_retorno") and errado == "":
					errado = "o trecho %d de %s desce a rua e usa %s, que é do retorno" \
						% [i, id, caminho.get_file()]
				if not caminho.get_file().begins_with("caminhao_%s" % id) and errado == "":
					errado = "o trecho %d de %s usa %s, que é de outra carga" \
						% [i, id, caminho.get_file()]
				if not (empresas[e] as Dictionary).values().has(usada) and errado == "":
					errado = "o trecho %d de %s pede a empresa %d e usa %s, que é de outra" \
						% [i, id, e, caminho.get_file()]
	_confere("cada trecho usa a silhueta do eixo, da carga e da empresa", errado == "", errado)
	_confere("e as %d silhuetas entram em campo" % pedidas,
		vistas.size() == pedidas, "só se viu %s" % str(vistas.keys()))

	# E os oito são oito DESENHOS, não oito nomes. É a mesma pergunta que o D17
	# faz aos cascos, e pela mesma razão: quatro carroçarias iguais pintadas de
	# quatro cores seriam quatro etiquetas, e a suíte não saberia a diferença.
	var texturas: Array = _texturas_dos_caminhoes(consts)
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
		#
		#    ⚠️ E DESDE A MÃO DIREITA (23/09) SÃO DUAS ROTAS E DOIS PONTOS. A
		#    `entrada` publicada é a boca na faixa do lado da água, que agora é
		#    a do RETORNO; a IDA vira na `virada`, à mesma altura, na faixa do
		#    lado da vila. Cada um tem de cair num trecho reto da SUA rota.
		var virada: Vector2 = do_jogo["virada"]
		var ret_rota: Array = consts["ROTA_RETORNO"]
		for par in [[entrada, ret_rota, "a entrada", "retorno"], [virada, rota, "a virada", "ida"]]:
			var ponto: Vector2 = par[0]
			var pontos: Array = par[1]
			var na_rota := false
			for k in range(pontos.size() - 1):
				var a2: Vector2 = pontos[k]
				var b2: Vector2 = pontos[k + 1]
				if abs(b2.x - a2.x) > 0.01:
					continue                     # cotovelo: anda em mx
				if not is_equal_approx(a2.x, ponto.x):
					continue
				if ponto.y >= min(a2.y, b2.y) - 0.01 \
						and ponto.y <= max(a2.y, b2.y) + 0.01:
					na_rota = true
			if not na_rota and erro_acesso == "":
				erro_acesso = "%s da doca %d, em (%.2f, %.2f), não cai em trecho reto nenhum do %s" \
					% [par[2], i + 1, ponto.x, ponto.y, par[3]]
		if not is_equal_approx(virada.y, entrada.y) and erro_acesso == "":
			erro_acesso = "a doca %d vira em my %.2f na ida e %.2f no retorno — o acesso é um só" \
				% [i + 1, virada.y, entrada.y]
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

	_d13_retorno(tela, cenario, consts, rota, regioes, desenho, visivel, pr)
	_d13_saida_de_re(tela, cenario, consts)
	_d13_completo = true


# ── D13 §7j ── a carroçaria cabe no asfalto da curva aberta
#
# A curva aberta corta a quina saliente por uma diagonal, e o camião percorre-a
# com a silhueta do eixo a que cada metade pertence — um RETÂNGULO alinhado ao
# eixo, a andar a 45°. A quina dele que aponta para a ponta chanfrada fica
# `(comprimento + largura) / 2` para dentro da linha da diagonal, somadas as
# duas distâncias às bordas, e é isso que o chanfro tem de deixar de asfalto.
# Até 23/09 o chanfro era meia rua (0,9) e o porta-contêiner saía 0,207 dele,
# por cima do meio-fio e do passeio: a `052` registou-o e deixou-o por decidir.
#
# ⚠️ TRÊS FONTES, e nenhuma é espelho de outra. O caminho sai do `Main.gd`
# (`trechos_de()`), o chanfro da tabela de âncoras (o gerador), e o tamanho de
# cada camião do `D35_CHASSI`, que o copia do kit do Blender. O gerador tem a
# sua própria cópia do maior camião para DERIVAR o chanfro; se ela ficar menor
# do que o camião de verdade, é aqui que reprova.
#
# Mede-se a pegada do chassi, como o D35: o que o olho lê numa curva é outra
# pergunta, e é do A5.
const D13_AMOSTRAS_DIAGONAL := 8

func _d13_curva_aberta_no_asfalto(tela: Control, rotas: Array, cotovelos: Array) -> void:
	# As DUAS quinas salientes de cada cotovelo, com o sentido em que o asfalto
	# fica: a de `(mx máx, my mín)` tem o asfalto a `-mx` e a `+my`, e a de
	# `(mx mín, my máx)` ao contrário. É o polígono do `cotovelo_pontos()`.
	var quinas: Array = []
	for c in cotovelos:
		var amx: Array = c["asfalto_mx"]
		var amy: Array = c["asfalto_my"]
		var ch := float(c["chanfro"])
		quinas.append([Vector2(float(amx[1]), float(amy[0])), -1.0, 1.0, ch])
		quinas.append([Vector2(float(amx[0]), float(amy[1])), 1.0, -1.0, ch])
	var diagonais := 0
	var pior := -INF
	var onde := ""
	for rota in rotas:
		for tr in tela.call("trechos_de", rota):
			var a: Vector2 = tr[0]
			var b: Vector2 = tr[1]
			if absf(b.x - a.x) < 0.01 or absf(b.y - a.y) < 0.01:
				continue
			diagonais += 1
			var k: int = tr[2]
			var em_mx: bool = absf((rota[k + 1] as Vector2).x - (rota[k] as Vector2).x) > 0.01
			var meio := (a + b) / 2.0
			var q: Array = quinas[0]
			for cand in quinas:
				if meio.distance_to(cand[0]) < meio.distance_to(q[0]):
					q = cand
			var quina: Vector2 = q[0]
			for motivo in D35_CHASSI:
				for e in range((D35_CHASSI[motivo] as Array).size()):
					var ext := Vector2(float(D35_CHASSI[motivo][e]), D35_LARG) / 2.0
					if not em_mx:
						ext = Vector2(ext.y, ext.x)
					for i in range(D13_AMOSTRAS_DIAGONAL + 1):
						var p := a.lerp(b, float(i) / float(D13_AMOSTRAS_DIAGONAL))
						for canto in [p + ext, p - ext, p + Vector2(ext.x, -ext.y), p + Vector2(-ext.x, ext.y)]:
							var dx: float = float(q[1]) * ((canto as Vector2).x - quina.x)
							var dy: float = float(q[2]) * ((canto as Vector2).y - quina.y)
							# Quanto sai: além de cada borda reta, ou além do chanfro,
							# medido na perpendicular dele.
							var sai := maxf(maxf(-dx, -dy), (float(q[3]) - dx - dy) / sqrt(2.0))
							if sai > pior:
								pior = sai
								onde = "%s (empresa %d) na diagonal %s -> %s, quina %s" \
									% [motivo, e, a, b, quina]
	# ⚠️ ZERO DIAGONAIS NÃO É "NADA SAI": é uma medida que não mediu. São duas
	# metades por curva aberta, uma curva aberta por cotovelo e por rota.
	_confere("há curvas abertas a medir (%d meias diagonais)" % diagonais, diagonais >= 4)
	_confere("nenhuma carroçaria sai do asfalto nas curvas abertas (a que mais se aproxima: %.3f)"
		% pior, diagonais > 0 and pior <= 0.0, onde)


# ── D13 §7 ── O RETORNO: a mão dupla de verdade (23/09)
#
# Os camiões que SOBEM a rua pela faixa de dentro. Os modos de falhar são os da
# ida, mais três que só existem com duas faixas, e nenhum dá erro:
#
#   1. a faixa ERRADA — o retorno na faixa da ida é um camião a subir em cima
#      de quem desce, e continua sobre asfalto, logo o §1 não o vê;
#   2. o sentido ERRADO — a lista escrita ao contrário é a ida outra vez;
#   3. a silhueta do outro sentido — um camião a subir de frente para baixo,
#      que é deslizar de costas.
#
# ⚠️ A FAIXA SAI DO ASFALTO PUBLICADO, não da `faixa_do_caminhao()` do gerador:
# a pergunta é "cada rota ocupa a SUA metade da pista", e a metade é uma
# propriedade do asfalto (`asfalto` de cada degrau, `asfalto_my` de cada
# cotovelo). Conferir o retorno contra um número derivado da ida seria o teste
# a concordar consigo próprio. Por isso a ida é conferida aqui também: a
# relação é entre as DUAS.
func _d13_retorno(tela: Control, cenario: Node, consts: Dictionary, rota: Array,
		regioes: Array, desenho: Rect2, visivel: Rect2, pr: Dictionary) -> void:
	var retorno: Array = consts["ROTA_RETORNO"]
	var origens: Array = consts["CAMINHAO_RETORNO_ORIGENS"]
	var caminhoes: Dictionary = consts["CAMINHOES"]
	var alt := float(pr["alt_cais"])

	_confere("o retorno tem os %d pontos da escada" % rota.size(),
		retorno.size() == rota.size(), "tem %d" % retorno.size())

	# ── a ── cada rota na SUA metade da pista, em todo trecho.
	#
	# O meio de cada faixa fica a um quarto da pista, a contar da borda de
	# `mx` (ou `my`) mais BAIXO. Nos retos a largura mede-se em `mx`; nos
	# cotovelos, em `my`. Desde a mão direita (23/09) a ida anda a 0,25 nos
	# retos e a 0,75 nos cotovelos, e o retorno ao contrário — e quem diz que
	# isso é a DIREITA não é esta tabela: é o §g, que o pergunta à projeção.
	var cotovelos: Array = _ancoras.get("cotovelos", [])
	var fora_da_faixa := ""
	for par in [[rota, 0.25, 0.75, "a ida"], [retorno, 0.75, 0.25, "o retorno"]]:
		var pontos: Array = par[0]
		for i in range(pontos.size() - 1):
			var de: Vector2 = pontos[i]
			var para: Vector2 = pontos[i + 1]
			var esperado := INF
			var medido := 0.0
			if abs(para.x - de.x) < 0.01:           # reto: anda em my
				var faixa := _faixa_de((de.y + para.y) / 2.0)
				var asf: Array = faixa["asfalto"]
				esperado = float(asf[0]) + (float(asf[1]) - float(asf[0])) * float(par[1])
				medido = de.x
			else:                                    # cotovelo: anda em mx
				for c in cotovelos:
					var amy: Array = c["asfalto_my"]
					if de.y >= float(amy[0]) - 0.01 and de.y <= float(amy[1]) + 0.01:
						esperado = float(amy[0]) + (float(amy[1]) - float(amy[0])) \
							* float(par[2])
				medido = de.y
			if absf(medido - esperado) > 0.01 and fora_da_faixa == "":
				fora_da_faixa = "%s, no trecho %d (%s -> %s), anda a %.2f e o meio da faixa dela é %.2f" \
					% [par[2], i, de, para, medido, esperado]
	_confere("cada rota anda no meio da sua faixa, em cada trecho",
		fora_da_faixa == "", fora_da_faixa)

	# ── g ── A MÃO É A DIREITA, e pergunta-se à PROJEÇÃO.
	#
	# ⚠️ De 07/09 a 23/09 a ida andou pela ESQUERDA nas retas e pela direita
	# nos cotovelos, com comentários a dizer que "quem segue em `+my` tem a
	# água à direita". Com `mx` e `my` lidos como `x` e `y` de um caderno, tem;
	# mas a projeção ESPELHA o chão, e na tela a água fica à esquerda. O §a
	# não o podia ver — confere frações, e as frações erradas estavam escritas
	# dos dois lados. A pergunta faz-se então com a conta e não com a regra: o
	# desvio do meio da pista até ao meio da faixa, projetado, contra a direita
	# do sentido projetado. Na tela o `y` cresce para baixo, logo a direita de
	# (hx, hy) é (-hy, hx).
	var mao := ""
	for par in [[rota, "a ida"], [retorno, "o retorno"]]:
		var pontos: Array = par[0]
		for i in range(pontos.size() - 1):
			var de: Vector2 = pontos[i]
			var para: Vector2 = pontos[i + 1]
			var meio_pista := de
			if abs(para.x - de.x) < 0.01:
				var asf: Array = _faixa_de((de.y + para.y) / 2.0)["asfalto"]
				meio_pista.x = (float(asf[0]) + float(asf[1])) / 2.0
			else:
				for c in cotovelos:
					var amy: Array = c["asfalto_my"]
					if de.y >= float(amy[0]) - 0.01 and de.y <= float(amy[1]) + 0.01:
						meio_pista.y = (float(amy[0]) + float(amy[1])) / 2.0
			var h := _tela_da_rota((para - de).normalized(), Vector2.ZERO, pr)
			var o := _tela_da_rota(de - meio_pista, Vector2.ZERO, pr)
			if o.dot(Vector2(-h.y, h.x)) <= 0.0 and mao == "":
				mao = "%s, no trecho %d (%s -> %s), anda à ESQUERDA na tela" \
					% [par[1], i, de, para]
	_confere("as duas rotas andam pela DIREITA na tela, como no Brasil", mao == "", mao)

	# ── h ── E AS DUAS NÃO SE CRUZAM, em ponto nenhum do caminho desenhado.
	#
	# Era a afirmação da `047` ("nunca se cruzam, nem na reta nem na curva"), e
	# era falsa: com a mão trocada nos cotovelos, cruzavam-se em DEZ pontos, e
	# os camiões passavam uns por cima dos outros a cada volta. Nada o
	# perguntava. Pergunta-se ao caminho que o camião percorre, com as
	# diagonais das curvas abertas.
	var cruza := ""
	for a in tela.call("trechos_de", rota):
		for b in tela.call("trechos_de", retorno):
			if _segmentos_cruzam(a[0], a[1], b[0], b[1]) and cruza == "":
				cruza = "a ida em %s -> %s cruza o retorno em %s -> %s" % [a[0], a[1], b[0], b[1]]
	_confere("a ida e o retorno não se cruzam em ponto nenhum", cruza == "", cruza)

	# ── i ── a rua que o `Main.gd` repete é a do mapa, e a diagonal da curva
	# aberta é a de que o gerador derivou o chanfro. Até 23/09 era o chanfro
	# que o `Main.gd` repetia, para derivar dele a diagonal; a ordem inverteu-se
	# (`docs/decisoes/053`), e o que se confere é o que atravessa a fronteira.
	var asf0: Array = _faixa_de(0.0)["asfalto"]
	_confere("a largura da rua no Main.gd é a do mapa (%.2f)" % float(consts["RUA_LARG"]),
		absf(float(consts["RUA_LARG"]) - (float(asf0[1]) - float(asf0[0]))) < 0.01)
	var corte: float = tela.call("corte_da_curva")
	var cortes_do_mapa: Array = []
	for c in cotovelos:
		cortes_do_mapa.append(c.get("corte_da_curva", "(nada)"))
	var corte_bate := not cotovelos.is_empty()
	for c_mapa in cortes_do_mapa:
		if typeof(c_mapa) != TYPE_FLOAT or absf(corte - float(c_mapa)) >= 0.0001:
			corte_bate = false
	_confere("e a diagonal das curvas abertas também (%.4f)" % corte, corte_bate,
		"o mapa diz %s" % str(cortes_do_mapa))

	# ── j ── E NENHUMA CARROÇARIA SAI DO ASFALTO NA CURVA ABERTA.
	_d13_curva_aberta_no_asfalto(tela, [rota, retorno], cotovelos)

	# ── b ── o retorno SOBE: `my` a descer nos retos, `mx` a descer nos
	# cotovelos, do primeiro ponto ao último.
	var contra := ""
	for i in range(retorno.size() - 1):
		var de: Vector2 = retorno[i]
		var para: Vector2 = retorno[i + 1]
		var sobe: bool = para.y < de.y - 0.01 or (absf(para.y - de.y) < 0.01 and para.x < de.x - 0.01)
		if not sobe and contra == "":
			contra = "o trecho %d vai de %s para %s" % [i, de, para]
	_confere("o retorno sobe a rua do princípio ao fim", contra == "", contra)

	# ── c ── sobre asfalto, pelos mesmos cortes do §1.
	var fora := ""
	for i in range(retorno.size() - 1):
		var de: Vector2 = retorno[i]
		var para: Vector2 = retorno[i + 1]
		for k in range(21):
			var m: Vector2 = de.lerp(para, float(k) / 20.0)
			var dentro := false
			for r in regioes:
				if m.x >= r[0] - 0.01 and m.x <= r[1] + 0.01 \
						and m.y >= r[2] - 0.01 and m.y <= r[3] + 0.01:
					dentro = true
					break
			if not dentro and fora == "":
				fora = "no trecho %d, a %d%%, está em (%.2f, %.2f)" % [i, k * 5, m.x, m.y]
	_confere("o retorno anda sobre asfalto, cotovelos incluídos", fora == "", fora)

	# ── d ── os nós, cada um na sua origem, inteiro à vista e num reto.
	_confere("há um nó CaminhaoRetorno por origem declarada (%d)" % origens.size(),
		cenario.get_node_or_null("CaminhaoRetorno%d" % origens.size()) == null
			and cenario.get_node_or_null("CaminhaoRetorno0") != null,
		"a cena e o `CAMINHAO_RETORNO_ORIGENS` do Main.gd não contam o mesmo")
	for j in range(origens.size()):
		var no := cenario.get_node_or_null("CaminhaoRetorno%d" % j) as Control
		if no == null:
			_confere("a cena tem o nó CaminhaoRetorno%d" % j, false)
			continue
		var origem: Vector2 = origens[j]
		var m_cena := _mundo(_origem(no), alt)
		_confere("a cena põe o CaminhaoRetorno%d no ponto de partida dele" % j,
			m_cena.distance_to(origem) < 0.02,
			"está em (%.2f, %.2f) e devia estar em (%.2f, %.2f)"
				% [m_cena.x, m_cena.y, origem.x, origem.y])
		var na_cena := Rect2(no.position + Vector2(MEIO_QUADRO, MEIO_QUADRO)
			+ desenho.position, desenho.size)
		_confere("e o CaminhaoRetorno%d está inteiro dentro do mapa" % j,
			visivel.encloses(na_cena),
			"o desenho fica em %s e o mapa é %s" % [na_cena, visivel])
		var num_reto := false
		for k in range(retorno.size() - 1):
			var a: Vector2 = retorno[k]
			var b: Vector2 = retorno[k + 1]
			if abs(b.x - a.x) < 0.01 and is_equal_approx(a.x, origem.x) \
					and origem.y >= min(a.y, b.y) - 0.01 and origem.y <= max(a.y, b.y) + 0.01:
				num_reto = true
		_confere("o CaminhaoRetorno%d parte de um trecho reto do retorno" % j, num_reto,
			"(%.2f, %.2f) não cai em nenhum" % [origem.x, origem.y])

	# ── e ── as duas pontas fora do quadro, pelo desenho inteiro.
	var no0 := cenario.get_node_or_null("CaminhaoRetorno0") as Control
	if no0 != null:
		var origem0: Vector2 = origens[0]
		for ponta in [[0, "a entrada"], [retorno.size() - 1, "a saída"]]:
			var pos: Vector2 = no0.position + _tela_da_rota(retorno[ponta[0]], origem0, pr) \
				+ Vector2(MEIO_QUADRO, MEIO_QUADRO)
			var caixa := Rect2(pos + desenho.position, desenho.size)
			_confere("%s do retorno está fora do quadro" % ponta[1],
				not visivel.intersects(caixa),
				"o desenho fica em %s e o mapa é %s" % [caixa, visivel])

	# ── f ── a silhueta do retorno, perguntada a QUEM DECIDE.
	# O NOME pedido sai do padrão do gerador (`caminhao_<motivo><marca><silhueta>`),
	# e a empresa da linha da tabela: a `MARCA_DA_EMPRESA` do `brp_porto.py` é
	# a outra fonte, e é o `_b` que separa as duas.
	var GS: Node = root.get_node("GameState")
	var errado := ""
	var vistas := {}
	var pedidas := 0
	for motivo in GS.MOTIVOS:
		var id := String(motivo)
		if not caminhoes.has(id):
			continue                # o §4 já reprova o motivo sem camião
		var empresas: Array = caminhoes[id]
		for e in range(empresas.size()):
			pedidas += 2
			for i in range(retorno.size() - 1):
				var de: Vector2 = retorno[i]
				var para: Vector2 = retorno[i + 1]
				var em_mx: bool = abs(para.x - de.x) > 0.01
				var usada: Texture2D = tela.call("silhueta_do_trecho", de, para, id, e)
				var arquivo := usada.resource_path.get_file()
				vistas[arquivo] = true
				var pede := "caminhao_%s%s_retorno%s.png" \
					% [id, "_b" if e == 1 else "", "_mx" if em_mx else ""]
				if arquivo != pede and errado == "":
					errado = "o trecho %d de %s (empresa %d) sobe em %s e usa %s, e pede %s" \
						% [i, id, e, "mx" if em_mx else "my", arquivo, pede]
	_confere("cada trecho do retorno usa a silhueta de costas, do eixo, da carga e da empresa",
		errado == "", errado)
	_confere("e as %d silhuetas do retorno entram em campo" % pedidas,
		vistas.size() == pedidas, "só se viu %s" % str(vistas.keys()))


# ── D13 · A MANOBRA DO BERÇO: ENTRA DE RÉ, SAI DE FRENTE (23/09, `077`)
#
# Até 03/10 o camião encostava de frente e largava o berço de marcha-atrás.
# Desde a ida ao camião do nível 2 (`077`) é o contrário, escolha do Bruno: ele
# ENTRA de ré, com as portas de trás viradas para o píer — é por elas que o
# trabalhador carrega —, e SAI de frente. Quem o pede é o `true` que a entrada
# passa ao `re_no_primeiro`, e o perigo que este bloco guarda é o mesmo de
# antes: tirá-lo, ou pô-lo no sítio errado, põe o camião a virar 180° de um
# frame para o outro no fundo da baía, e o §4 e o §f passavam na mesma, porque
# perguntam a `silhueta_do_trecho()` trecho a trecho e nenhum ANIMA a manobra.
#
# ⚠️ POR ISSO ESTE BLOCO ANDA O TWEEN, e à mão. O teste é síncrono — um `await`
# aqui nunca voltaria, porque o `_process` devolve `true` —, então o tween que o
# jogo cria é apanhado pela diferença de `get_processed_tweens()` e avançado com
# `custom_step()`, lendo a textura do NÓ a cada passo. O que se confere é o que
# o jogador veria, e não o que a função diria.
#
# ⚠️ E A RÉ COMPARA-SE COM O ESTADO QUE ELA SUBSTITUI (`045`): o camião
# ENCOSTADO, que chega lá pelo caminho do jogo (`_no_acesso()`) e sai pelo do
# jogo (`_docas_mudaram()`, com o barco a ir embora) — nunca uma silhueta
# suposta. As três docas, e não só a que o porto em ruínas tem: as outras duas
# entram como fixture e saem no fim.
func _d13_saida_de_re(tela: Control, cenario: Node, consts: Dictionary) -> void:
	var GS: Node = root.get_node("GameState")
	if GS.phase == "rival_offer":
		GS.resolve_rival_offer(true)
	var caminhoes: Dictionary = consts["CAMINHOES"]
	var n: int = (consts["ACESSOS_DOCA"] as Array).size()
	var tweens_antes := get_processed_tweens()
	var docas_antes: int = GS.docks.size()
	var barco_antes = GS.docks[0]["boat"]
	var trab_antes = GS.docks[0]["worker_id"]
	while GS.docks.size() < n:
		GS.docks.append({"boat": null, "worker_id": null})
	# ⚠️ OS OUTROS CAMIÕES SAEM DA RUA durante o bloco. Desde a cedência
	# (23/09) ninguém entra num berço nem sai dele com um camião ao pé da boca,
	# e a cena abre com três nas origens, dois deles a menos de duas unidades de
	# uma boca: o camião sob teste ficaria à espera para sempre, porque aqui
	# nenhum tween anda sozinho. Vão para o FIM da rota de cada um, fora do
	# quadro, e voltam no fim.
	var fora := _tirar_da_rua(tela, cenario, consts)

	var sem_estado := ""
	var nao_encosta := ""
	var vira := ""
	var nao_retoma := ""
	var de_costas := ""
	var marca := ""
	for i in range(n):
		var no := cenario.get_node_or_null("Caminhao%d" % i) as TextureRect
		if no == null:
			continue
		var pos := no.position
		var tex := no.texture
		var indice := no.get_index()
		var carga := String((tela.get("_carga_na_estrada") as Array)[i])
		var empresa := int((tela.get("_empresa_na_estrada") as Array)[i])
		var par: Dictionary = caminhoes[carga][empresa]
		var doca: Dictionary = GS.docks[i]
		var id := 4300 + i
		doca["boat"] = {"id": id, "motivo": carga, "classe": "pesqueiro"}
		doca["worker_id"] = 1

		var chegada := _andar_o_tween(no, func() -> void:
			tela.call("_no_acesso", i, 5.0))
		var visita := int((tela.get("_visita_do_berco") as Array)[i])
		# O ESTADO TEM DE TER SIDO ALCANÇADO, e prova-se pela consequência: é o
		# fim do tween da chegada que marca a visita (`043`, `044`).
		if (int(chegada["tweens"]) != 1 or not chegada["acabou"] or visita != id) \
				and sem_estado == "":
			sem_estado = "doca %d: %d tween(s) na chegada, acabou=%s, visita %d (pede %d)" \
				% [i + 1, int(chegada["tweens"]), str(chegada["acabou"]), visita, id]
		var encostado := no.texture
		# Encostado DE RÉ: a frente para terra e as portas para o píer, que é a
		# silhueta `mx_retorno`. Sem o `de_re` da entrada ele encostava de
		# frente — e o trabalhador ia carregar pela cabine.
		if encostado != par["mx_retorno"] and nao_encosta == "":
			nao_encosta = "doca %d encosta com %s, e a %s de ré pede %s" \
				% [i + 1, _arquivo(encostado), carga, _arquivo(par["mx_retorno"])]

		doca["boat"] = null
		# A ré e a estrada retomada são DOIS tweens desde a trava (23/09): a trava
		# do berço abre-se no fim da ré, quando o camião volta à faixa.
		# ⚠️ E A RÉ MARCA-SE COMO SAÍDA, que é o que a previsão das curvas lê
		# para contar com quem ainda está fora da rua mas volta daqui a nada. A
		# varredura do D35 escreve a marca ELA PRÓPRIA para pôr o retorno a meio
		# da ré — prova que a previsão a lê, e não que o jogo a escreve. Esta é
		# a outra ponta: medido, tirar a linha que a escreve passava tudo.
		var marcada := [false]
		var saida := _andar_o_tween(no, func() -> void:
			tela.call("_docas_mudaram")
			marcada[0] = bool((tela.get("_saindo_do_berco") as Array)[i]), 2)
		var ainda: bool = bool((tela.get("_saindo_do_berco") as Array)[i])
		if (not marcada[0] or ainda) and marca == "":
			marca = "doca %d: marcada ao sair=%s, ainda marcada depois de voltar à faixa=%s" \
				% [i + 1, str(marcada[0]), str(ainda)]
		var vistas: Array = saida["vistas"]
		if int(saida["tweens"]) != 1 or not saida["acabou"] or vistas.size() < 2:
			if nao_retoma == "":
				nao_retoma = "doca %d: %d tween(s) na saída, acabou=%s, viu %s" \
					% [i + 1, int(saida["tweens"]), str(saida["acabou"]),
						_arquivos(vistas)]
		else:
			if vistas[0] != encostado and vira == "":
				vira = "doca %d: encostado com %s, e sai com %s" \
					% [i + 1, _arquivo(encostado), _arquivo(vistas[0])]
			if vistas[1] != par["my"] and nao_retoma == "":
				nao_retoma = "doca %d: depois do acesso mostra %s, e a estrada em my pede %s" \
					% [i + 1, _arquivo(vistas[1]), _arquivo(par["my"])]
		# Saído do acesso, a ida segue a rota DELA, de frente: nenhuma silhueta
		# de retorno depois do primeiro trecho, que é o do berço.
		for t in vistas.slice(1):
			if (t == par["mx_retorno"] or t == par["my_retorno"]) and de_costas == "":
				de_costas = "doca %d: a estrada passou por %s — %s" \
					% [i + 1, _arquivo(t), _arquivos(vistas)]

		no.position = pos
		no.texture = tex
		cenario.move_child(no, indice)
		doca["boat"] = null
		doca["worker_id"] = null

	# ── E O RETORNO, que desde a mão direita (23/09) também encosta — e sai por
	# OUTRO ramo do `_largar_berco()`, que volta à SUA faixa e retoma a subida.
	# Medido: sem isto, apagar a linha que lhe desmarca a saída passava a suíte
	# inteira. Encosta de ré, como a ida (`mx_retorno`: as portas para o píer);
	# a saída guarda a silhueta; e depois sobe DE COSTAS, que é a dele.
	var r_sem := ""
	var r_ne := ""
	var no_r := cenario.get_node_or_null("CaminhaoRetorno0") as TextureRect
	for d in range(n):
		if no_r == null:
			break
		var pos_r := no_r.position
		var tex_r := no_r.texture
		var indice_r := no_r.get_index()
		var carga_r := String((tela.get("_carga_do_retorno") as Array)[0])
		var empresa_r := int((tela.get("_empresa_do_retorno") as Array)[0])
		var par_r: Dictionary = caminhoes[carga_r][empresa_r]
		var doca_r: Dictionary = GS.docks[d]
		var id_r := 4400 + d
		doca_r["boat"] = {"id": id_r, "motivo": carga_r, "classe": "pesqueiro"}
		doca_r["worker_id"] = 1
		var chegou := _andar_o_tween(no_r, func() -> void:
			tela.call("_retorno_na_boca", 0, d, 5.0))
		if (int(chegou["tweens"]) != 1 or not chegou["acabou"]
				or int((tela.get("_visita_do_berco") as Array)[d]) != id_r) and r_sem == "":
			r_sem = "berço %d: %d tween(s), acabou=%s" \
				% [d + 1, int(chegou["tweens"]), str(chegou["acabou"])]
		var encostado_r := no_r.texture
		doca_r["boat"] = null
		var marcada_r := [false]
		var saiu := _andar_o_tween(no_r, func() -> void:
			tela.call("_docas_mudaram")
			marcada_r[0] = bool((tela.get("_saindo_do_berco") as Array)[d]), 2)
		var vistas_r: Array = saiu["vistas"]
		var ainda_r: bool = bool((tela.get("_saindo_do_berco") as Array)[d])
		if r_ne == "":
			if encostado_r != par_r["mx_retorno"]:
				r_ne = "berço %d: encosta com %s" % [d + 1, _arquivo(encostado_r)]
			elif vistas_r.size() < 2 or vistas_r[0] != encostado_r \
					or vistas_r[1] != par_r["my_retorno"]:
				r_ne = "berço %d: a saída mostrou %s" % [d + 1, _arquivos(vistas_r)]
			elif not marcada_r[0] or ainda_r:
				r_ne = "berço %d: marcada ao sair=%s, ainda marcada na faixa=%s" \
					% [d + 1, str(marcada_r[0]), str(ainda_r)]
		no_r.position = pos_r
		no_r.texture = tex_r
		cenario.move_child(no_r, indice_r)
		doca_r["worker_id"] = null
	_confere("o retorno também encosta pelo caminho do jogo", r_sem == "", r_sem)
	_confere("e sai de frente com a silhueta de encostado, marcado, e sobe de costas",
		r_ne == "", r_ne)

	for tw in get_processed_tweens():
		if not tweens_antes.has(tw):
			tw.kill()
	for par in fora:
		(par[0] as Control).position = par[1]
		(par[0] as TextureRect).texture = par[2]
	GS.docks.resize(docas_antes)
	GS.docks[0]["boat"] = barco_antes
	GS.docks[0]["worker_id"] = trab_antes

	_confere("cada camião chega ao berço pelo caminho do jogo, e a visita fica marcada",
		sem_estado == "", sem_estado)
	_confere("encostado de ré, as portas para o píer (a silhueta mx_retorno da carga dele)",
		nao_encosta == "", nao_encosta)
	_confere("e sai do berço com a MESMA silhueta com que estava encostado",
		vira == "", vira)
	_confere("depois do acesso, retoma a estrada de frente", nao_retoma == "", nao_retoma)
	_confere("e na estrada não passa por silhueta de retorno",
		de_costas == "", de_costas)
	_confere("a saída do berço marca o camião como a sair, e desmarca-o na faixa",
		marca == "", marca)


## Corre `acao` e anda até ao fim o tween que ela criou, a passos de 0,25 s,
## guardando as texturas que o nó MOSTROU, pela ordem e sem repetir a seguida.
## `tweens` diz quantos a ação criou: se não for um, não há o que andar, e quem
## chama reprova — uma lista vazia passaria por "nenhuma silhueta errada".
##
## O passo é menor do que o trecho mais curto da rota (a ré, ~2,6 s), senão um
## trecho inteiro caberia num passo e a textura dele nunca seria lida.
##
## ⚠️ `encadeados` SEGUE OS TWEENS QUE O PRIMEIRO ARMA NO FIM, até esse número.
## A saída do berço passou a ser dois (a ré, e a estrada depois de a trava
## abrir), e parar no primeiro deixava a estrada por ler. Não segue MAIS do que
## isso de propósito: o fim de uma volta arma a pausa, e a pausa arma a volta
## seguinte — uma cadeia sem fim, que andaria o camião para sempre.
func _andar_o_tween(no: TextureRect, acao: Callable, encadeados := 1) -> Dictionary:
	var antes := get_processed_tweens()
	acao.call()
	var novos: Array = []
	for tw in get_processed_tweens():
		if not antes.has(tw):
			novos.append(tw)
	var vistas: Array = []
	if novos.size() != 1:
		return {"tweens": novos.size(), "acabou": false, "vistas": vistas}
	var seguidos: Array = []
	var tw: Tween = novos[0]
	var passos := 0
	while true:
		seguidos.append(tw)
		while tw.is_running() and passos < 2000:
			tw.custom_step(0.25)
			passos += 1
			if vistas.is_empty() or vistas[-1] != no.texture:
				vistas.append(no.texture)
		if tw.is_running() or seguidos.size() >= encadeados:
			break
		var seguinte: Array = []
		for t2 in get_processed_tweens():
			if not antes.has(t2) and not seguidos.has(t2):
				seguinte.append(t2)
		if seguinte.size() != 1:
			break
		tw = seguinte[0]
	return {"tweens": 1, "vistas": vistas,
		"acabou": not tw.is_running() and seguidos.size() == encadeados}


## Põe os cinco camiões no FIM das suas rotas, fora do quadro, e devolve o que
## é preciso para os repor: `[nó, posição, textura]`.
func _tirar_da_rua(tela: Control, cenario: Node, consts: Dictionary) -> Array:
	var guardado: Array = []
	var pr: Dictionary = _ancoras["projecao"]
	for par in [["Caminhao%d", consts["CAMINHAO_ORIGENS"], consts["ROTA_ESTRADA"]],
			["CaminhaoRetorno%d", consts["CAMINHAO_RETORNO_ORIGENS"], consts["ROTA_RETORNO"]]]:
		var origens: Array = par[1]
		var rota: Array = par[2]
		for k in range(origens.size()):
			var no := cenario.get_node_or_null(String(par[0]) % k) as TextureRect
			if no == null:
				continue
			guardado.append([no, no.position, no.texture])
			no.position += _tela_da_rota(rota[rota.size() - 1], origens[k], pr)
	return guardado


## Dois segmentos têm algum ponto em comum? Orientação dos quatro trios, com
## o caso colinear incluído: dois trechos sobrepostos na mesma reta também é
## cruzar, e é o pior dos casos.
func _segmentos_cruzam(p1: Vector2, p2: Vector2, p3: Vector2, p4: Vector2) -> bool:
	var o := func(a: Vector2, b: Vector2, c: Vector2) -> float:
		var v := (b - a).cross(c - a)
		return 0.0 if absf(v) < 1e-6 else signf(v)
	var em := func(a: Vector2, b: Vector2, c: Vector2) -> bool:
		return c.x >= minf(a.x, b.x) - 1e-6 and c.x <= maxf(a.x, b.x) + 1e-6 \
			and c.y >= minf(a.y, b.y) - 1e-6 and c.y <= maxf(a.y, b.y) + 1e-6
	var d1: float = o.call(p3, p4, p1)
	var d2: float = o.call(p3, p4, p2)
	var d3: float = o.call(p1, p2, p3)
	var d4: float = o.call(p1, p2, p4)
	if d1 * d2 < 0.0 and d3 * d4 < 0.0:
		return true
	return (d1 == 0.0 and em.call(p3, p4, p1)) or (d2 == 0.0 and em.call(p3, p4, p2)) \
		or (d3 == 0.0 and em.call(p1, p2, p3)) or (d4 == 0.0 and em.call(p1, p2, p4))


func _arquivo(tex: Texture2D) -> String:
	return tex.resource_path.get_file() if tex != null else "(nada)"


func _arquivos(texs: Array) -> String:
	var nomes: Array = []
	for t in texs:
		nomes.append(_arquivo(t))
	return ", ".join(nomes)


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

	# OS FORMATOS SAEM DO PRÓPRIO CARTÃO (`texto_do_progresso()` e
	# `texto_do_trabalhador()`), e não de literais copiados para aqui: até à
	# segunda passagem da `083` este bloco escrevia os formatos à mão, e o
	# acordo a mudar de linha no cartão teria passado verde com a cópia velha.
	# O pior caso é o nome mais longo com o maior número de dias de berço.
	var doca_script: Script = cartao.get_script()
	var maior_op := 0
	for classe in GS.CLASSES_DE_NAVIO:
		for motivo in GS.MOTIVOS:
			maior_op = maxi(maior_op, int(GS._turnos_de_operacao(classe, motivo)))
	rotulo_prog.text = doca_script.texto_do_progresso(maior, 0, maior_op)
	_confere("a linha do progresso cabe (%.0f de %.0f px)"
			% [linha.get_combined_minimum_size().x, interior],
		linha.get_combined_minimum_size().x <= interior, "[%s]" % rotulo_prog.text)

	# O berço livre, nas três formas.
	for pronto in [true, false]:
		for vazia in [true, false]:
			rotulo_prog.text = doca_script.texto_do_berco_livre(pronto, vazia)
			_confere("o berço livre cabe (%.0f de %.0f px)"
					% [linha.get_combined_minimum_size().x, interior],
				linha.get_combined_minimum_size().x <= interior, "[%s]" % rotulo_prog.text)

	# Os quatro estados da linha do trabalhador, com o ícone ao lado como o
	# `refresh()` o põe.
	(cartao.get_node("Coluna/TrabalhadorLinha/Icone") as Control).visible = true
	for acordo in [false, true]:
		for feitos in [0, 1]:
			rotulo_trab.text = doca_script.texto_do_trabalhador(
				GS.BERCOS_NO_MAPA, acordo, feitos)
			_confere("a linha do trabalhador cabe (%.0f de %.0f px)"
					% [linha_trab.get_combined_minimum_size().x, interior],
				linha_trab.get_combined_minimum_size().x <= interior,
				"[%s]" % rotulo_trab.text)

	# ⚠️ E O CARTÃO DA FILA (`083`), pela mesma regra: o nome do porte mais
	# longo com o valor mais alto, a carga mais longa com os dias de berço no
	# plural, e a espera com o acordo. Os nomes saem das tabelas do próprio
	# cartão — o pior caso não se inventa (a regra do D23).
	var lugar := _main.get_node("Fila").get_child(0) as Control
	var sb_f := lugar.get_theme_stylebox("panel", "CartaoDoca")
	var interior_f: float = lugar.size.x
	if sb_f != null:
		interior_f -= sb_f.content_margin_left + sb_f.content_margin_right
	var script_f: Script = lugar.get_script()
	var nomes: Array = (script_f.get_script_constant_map()["PORTES_DE_PESCA"] as Array).duplicate()
	nomes.append_array((script_f.get_script_constant_map()["NOME_CURTO"] as Dictionary).values())
	var nome_maior := ""
	for n in nomes:
		if String(n).length() > nome_maior.length():
			nome_maior = String(n)
	(lugar.get_node("Coluna/Cabecalho/Nome") as Label).text = nome_maior.to_upper()
	(lugar.get_node("Coluna/Cabecalho/Valor") as Label).text = GS.moeda(teto)
	var cab_f := lugar.get_node("Coluna/Cabecalho") as HBoxContainer
	_confere("o cabeçalho do barco ao largo cabe (%.0f de %.0f px)"
			% [cab_f.get_combined_minimum_size().x, interior_f],
		cab_f.get_combined_minimum_size().x <= interior_f, "[%s]" % nome_maior)
	# `load()` e não o nome da classe: a regra do `class_name` alcançado por um
	# `--script` (`CLAUDE.md`, Estilo de código), como o D22 já faz.
	# A carga e a espera saem das funções do cartão, como as da doca: o pior
	# caso é o motivo mais longo com os dias de berço mais longos, e a espera
	# mais longa que o jogo escreve — a paciência cheia, com acordo (a oferta
	# do Arlindo cai no barco que acabou de chegar, logo é aí que o acordo
	# aparece), e a última, também com acordo. O ícone fica aceso, como no
	# ramo do rival.
	var fila_script: Script = lugar.get_script()
	var carga := lugar.get_node("Coluna/Carga") as Label
	carga.text = fila_script.texto_da_carga(maior, maior_op)
	_confere("a carga do barco ao largo cabe (%.0f de %.0f px)"
			% [carga.get_combined_minimum_size().x, interior_f],
		carga.get_combined_minimum_size().x <= interior_f, "[%s]" % carga.text)
	var espera := lugar.get_node("Coluna/EsperaLinha") as HBoxContainer
	(lugar.get_node("Coluna/EsperaLinha/Icone") as Control).visible = true
	for paciencia in [GS.PACIENCIA_FILA, 1]:
		(lugar.get_node("Coluna/EsperaLinha/Espera") as Label).text = \
			fila_script.texto_da_espera(paciencia, true)
		_confere("a espera do barco ao largo cabe (%.0f de %.0f px)"
				% [espera.get_combined_minimum_size().x, interior_f],
			espera.get_combined_minimum_size().x <= interior_f,
			"[%s]" % (lugar.get_node("Coluna/EsperaLinha/Espera") as Label).text)
	lugar.refresh()
	cartao.refresh()

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

	# ⚠️ CADA RÓTULO CONTRA O FUNDO QUE ELE TEM, e não contra o do cartão. Até
	# 04/10 isto media tudo contra o branco do cartão — que era verdade
	# enquanto o painel era um cartão branco e mais nada. Com o cabeçalho navy
	# e a tarja das famílias (`081`), o título branco sobre o navy reprovaria
	# contra um branco que não está atrás dele. Quem sabe o fundo de cada
	# rótulo é a régua do D33, e é ela que se usa.
	var motor: RefCounted = load("res://scripts/validation/contraste_ui.gd").new()
	var reprovados := 0
	var pendentes := 0
	var pior := 99.0
	var pior_texto := ""
	var medidos := 0
	for linha in motor.medir(painel):
		if linha["estado"] == "isento":
			continue
		medidos += 1
		if linha["estado"] == "pendente":
			pendentes += 1
			continue
		if float(linha["razao"]) < pior:
			pior = float(linha["razao"])
			pior_texto = "%s a %dpx" % [linha["texto"], int(linha["px"])]
		if linha["estado"] == "reprova":
			reprovados += 1
	_confere("o painel tem texto para medir (%d)" % medidos, medidos >= 10)
	_confere("nenhum rótulo reprova a WCAG (pior: %.2f:1 em %s)"
			% [pior, pior_texto], reprovados == 0 and pendentes == 0,
		"%d rótulo(s) abaixo do corte, %d sem fundo resolvido" % [reprovados, pendentes])

	# E A RÉGUA SABE REPROVAR AQUI: o neutro do jogo, pousado no cartão branco,
	# é o defeito que este bloco nasceu para apanhar (2,93:1, `CLAUDE.md`).
	var intruso := Label.new()
	intruso.text = "neutro do jogo no cartão branco"
	intruso.theme_type_variation = &"TextoBarra"
	var caixa_painel: Node = null
	for filho in painel.get_children():
		if filho is PanelContainer:
			caixa_painel = filho
	if caixa_painel != null:
		caixa_painel.get_child(0).add_child(intruso)
		var achou := false
		for linha in motor.medir(painel):
			if String(linha["texto"]) == intruso.text:
				achou = linha["estado"] == "reprova"
		_confere("e a régua reprova o neutro do jogo pousado no cartão", achou)
		intruso.get_parent().remove_child(intruso)
	intruso.free()

	# ── E NENHUM TEXTO DE UMA LINHA É MAIS LARGO DO QUE O SÍTIO DELE (`081`).
	# Com o preço e o botão à direita de cada linha, um rótulo com quebra
	# automática ao lado da coluna que expande fica com largura quase zero, e
	# uma palavra só — «Construída» — desenha-se por cima da borda do cartão,
	# sem erro nenhum. Passou na primeira captura da passagem. Mede-se com o
	# porto de duas estruturas compradas, que é onde o «Construída» existe.
	var GS: Node = root.get_node("GameState")
	var caixa_antes: int = int(GS.cash)
	var estruturas_antes: Array = GS.estruturas.duplicate()
	GS.cash = 900000
	GS.estruturas = ["pier_2", "armazem"]
	var com_obra: Control = (load("res://scenes/panels/UpgradePanel.tscn") as PackedScene).instantiate()
	com_obra.theme = load("res://ui/tema_brport.tres")
	_main.add_child(com_obra)
	_d19_arrumar(com_obra)
	var largos: Array = []
	var feitos := 0
	for no in _todos_os_labels(com_obra):
		var r := no as Label
		if r.text == "Construída":
			feitos += 1
		if r.text.contains("\n") or r.get_line_count() > 1:
			continue
		var fonte: Font = r.get_theme_font("font")
		var pede: float = fonte.get_string_size(r.text, HORIZONTAL_ALIGNMENT_LEFT, -1,
			r.get_theme_font_size("font_size")).x
		if pede > r.size.x + 1.0:
			largos.append("«%s» pede %.0f px e tem %.0f" % [r.text, pede, r.size.x])
	_confere("D19: o painel com obra mostra os dois «Construída» (%d)" % feitos, feitos == 2)
	_confere("D19: nenhum texto de uma linha desenha mais largo do que o sítio dele",
		largos.is_empty(), "; ".join(largos))
	_main.remove_child(com_obra)
	com_obra.free()
	GS.cash = caixa_antes
	GS.estruturas = estruturas_antes

	_main.remove_child(painel)
	painel.queue_free()
	_d19_completo = true


# O fundo em que os rótulos deste painel caem: o `bg_color` do StyleBox do
# PanelContainer do cartão. Ler o tema em vez de escrever a cor à mão é o que
# faz este teste continuar a valer quando o tema mudar.
# Os contentores arrumam-se no frame seguinte, e esta suíte não deixa passar
# nenhum: a ordem é dada à mão, de cima para baixo, porque é o pai que dá o
# tamanho ao filho antes de o filho arrumar os dele.
func _d19_arrumar(no: Node) -> void:
	if no is Container:
		no.notification(Container.NOTIFICATION_SORT_CHILDREN)
	for filho in no.get_children():
		_d19_arrumar(filho)


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
	# As DUAS rotas, desde a mão dupla (23/09): a faixa de dentro passa mais
	# perto da calçada da vila, e é ela que mais tem a perder com uma cor
	# errada no mapa.
	#
	# ⚠️ E PERGUNTA-SE PELO CAMINHO DESENHADO, não pela escada das constantes.
	# Com a mão direita (23/09) cada rota faz uma curva ABERTA por cotovelo, e
	# o vértice dela cai em cima da linha do chanfro: foi este bloco que o
	# apanhou, com 33 px de calçada na janela. O camião corta essa quina por
	# uma diagonal (`trechos_de()` no `Main.gd`), e é ela que se amostra —
	# amostrar a escada conferia um caminho que ninguém percorre.
	var trechos: Array = []
	for rota in [consts["ROTA_ESTRADA"], consts["ROTA_RETORNO"]]:
		for tr in _main.call("trechos_de", rota):
			trechos.append([tr[0], tr[1]])

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
		for trecho in trechos:
			var de: Vector2 = trecho[0]
			var para: Vector2 = trecho[1]
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
# Uma pessoa mede 7 px na própria arte, e nenhum bicho fica abaixo dela nem
# chega ao barco de 44 px que serve de teto para os grandes elementos móveis.
#
# ⚠️ ATÉ 27/09 A REGRA ERA A CONTRÁRIA — «nenhum bicho passa da pessoa» —, com
# a pessoa a medir 14. Ela encolheu para a régua de 1,5x o real (`069`,
# `REGUA_DA_PESSOA`), e a fauna NÃO a acompanhou, por escolha do Bruno com as
# duas na prancha: encolhida, ficava com 6 a 8 px, e a gaivota, a tartaruga e
# o cachorro do mesmo tamanho (medido: 7 / 7 / 7, e as duas asserções de
# ordem abaixo reprovavam). A fauna ficou legível, e a pessoa passou a ser o
# que de mais pequeno vive no mapa — que é o real: a envergadura de uma
# gaivota é ~3x os ombros de alguém.
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
const LARGURA_DA_PESSOA := 7
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
# Por isso as larguras são pregadas uma a uma (`FAUNA_LARGURAS`), e a relação
# com a pessoa é um PISO sem folga: a pessoa mede 7,33 e o bicho mais estreito,
# a maria-farinha, 12,0. O piso nasceu da escolha de 27/09 e diz o que ela
# defende — a fauna não encolhe com a pessoa. Medido com a fauna encolhida pelo
# mesmo 0,48: 7 / 7 / 6 / 7 / 7 / 8 contra uma pessoa de 7, e o piso só
# reprova a maria-farinha; quem apanha os outros cinco são as larguras
# pregadas. Um bicho DOBRADO (a gaivota a 30) cai nas larguras e no teto.


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
	_confere("a régua continua sendo uma pessoa de %d px" % LARGURA_DA_PESSOA,
		largura_pessoa == LARGURA_DA_PESSOA,
		"o trabalhador mede %d px" % largura_pessoa)

	var larguras := {}
	for especie in FAUNA_CENAS:
		var bicho: Node2D = load(FAUNA_CENAS[especie]).instantiate()
		bicho.atraso_inicial = 99.0
		root.add_child(bicho)
		bicho.set_process(false)
		var sprite: Sprite2D = bicho.get_node("Sprite")
		var usado := PropIso.imagem(sprite.texture).get_used_rect()
		var largura := int(round(float(usado.size.x) * absf(sprite.scale.x)))
		larguras[especie] = largura
		_confere("%s mede os %d px escolhidos" % [especie, FAUNA_LARGURAS[especie]],
			largura == FAUNA_LARGURAS[especie], "mede %d px" % largura)
		_confere("%s não fica abaixo da pessoa nem chega ao barco" % especie,
			largura >= largura_pessoa and largura < LARGURA_BARCO,
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
# ⚠️ E DESDE A `082` A NARRAÇÃO SÃO DUAS PÁGINAS DO CADERNO, que não rola: a
# pergunta deixou de ser a altura do cartão e passou a ser a do D37 — cada
# página cabe na folha, com o nome de cais mais comprido. E mais duas, que a
# divisão abriu:
#
#  1. AS DUAS PÁGINAS SÃO A PEÇA INTEIRA: juntas pela virada, dão o texto do
#     `fim_de_fase()` letra a letra, e a segunda acaba no remate. Partir no
#     sítio errado — ou num traço que deixasse de existir — perdia metade da
#     peça sem erro nenhum, porque o caderno mostra o que recebe.
#  2. A DATA DA ENTRADA ESCREVE-SE POR EXTENSO: o ordinal sai do
#     `WEEKS_TOTAL`, e fora do intervalo que conhece devolve o número — que é
#     a regra «nenhum dígito na narração» do F4, aqui no cabeçalho.
#  3. A SEGUNDA PÁGINA, COM O RECIBO COLADO, CABE NA FOLHA (terceira
#     passagem). O recibo não está na pauta e mede-se montado: a coluna da
#     página pede a altura do texto, dos vãos e do recibo, e tem de caber no
#     que a folha dá — senão a página cresce, a capa cresce com ela e desce
#     por cima do botão, sem erro nenhum (a primeira armadilha do D37).
func _d22_narracao_cabe() -> void:
	var GS: Node = root.get_node("GameState")
	GS.clear_save()
	GS.new_game()
	var Nar = load("res://scripts/Narrativa.gd")
	var tema: Theme = load("res://ui/tema_brport.tres")
	var PN: Dictionary = (load("res://scripts/PainelNarrativo.gd") as GDScript).get_script_constant_map()

	# 1. as duas páginas são a peça inteira
	GS.nome_porto = "Cais Mirim"
	var texto: String = Nar.fim_de_fase()
	var paginas: PackedStringArray = Nar.fim_de_fase_paginas()
	_confere("D22: a narração sai em duas páginas (%d)" % paginas.size(), paginas.size() == 2)
	_confere("D22: e as duas, juntas pela virada, são a peça inteira",
		Nar.FIM_DE_FASE_VIRADA.join(paginas) == texto)
	_confere("D22: e a segunda acaba no remate",
		paginas.size() == 2 and paginas[1].strip_edges().ends_with("Em quem tá olhando."),
		"a segunda acaba em: " + (paginas[1].strip_edges().right(30) if paginas.size() > 1 else "(não há)"))

	# 2. a data por extenso
	var data: String = Nar.fim_de_fase_cabecalho()
	var digito := RegEx.new()
	digito.compile("[0-9]")
	_confere("D22: a data da entrada escreve a semana por extenso («%s»)" % data,
		digito.search(data) == null and data.begins_with("Porto Mirim, "))

	# 3. cada página cabe na folha, com o nome mais comprido (a conta do D37)
	var capa: StyleBox = tema.get_stylebox("panel", "CadernoCapa")
	var fonte: Font = tema.get_font("font", "TextoCaderno")
	var tam: int = tema.get_font_size("font_size", "TextoCaderno")
	var espaco: int = tema.get_constant("line_spacing", "TextoCaderno")
	var largura: float = float(PN["CADERNO_LARGURA"]) - capa.get_margin(SIDE_LEFT) \
		- capa.get_margin(SIDE_RIGHT) - float(PN["PAGINA_MARGEM_PAUTADA"]) \
		- float(PN["PAGINA_MARGEM_DIR"])
	var altura: float = float(PN["CADERNO_ALTURA"]) - capa.get_margin(SIDE_TOP) \
		- capa.get_margin(SIDE_BOTTOM) - float(PN["PAGINA_MARGEM_TOPO"]) \
		- float(PN["PAGINA_MARGEM_PE"])
	GS.nome_porto = "W".repeat(int(GS.NOME_MAX_CARACTERES))
	var longas: PackedStringArray = Nar.fim_de_fase_paginas()
	GS.nome_porto = "Cais Mirim"
	var linha: float = fonte.get_height(tam)
	for i in longas.size():
		var corpo: float = fonte.get_multiline_string_size(longas[i],
			HORIZONTAL_ALIGNMENT_LEFT, largura, tam).y
		var linhas: int = int(round(corpo / linha))
		# A primeira leva a data: ela e a linha em branco por baixo.
		var data_linhas := 2 if i == 0 else 0
		var n := linhas + data_linhas
		var pede: float = n * linha + (n - 1) * espaco
		_confere("D22: a página %d, com o nome mais comprido, cabe na folha (%d linhas, pede %d, cabe %d)"
			% [i + 1, n, int(ceil(pede)), int(altura)], linhas > 5 and pede <= altura)

	# 4. a segunda página, com o recibo, montada com o tema e o nome mais comprido
	var tela: Control = load("res://scenes/EndGame.tscn").instantiate()
	tela.theme = tema
	root.add_child(tela)
	GS.nome_porto = "W".repeat(int(GS.NOME_MAX_CARACTERES))
	tela.call("setup", true, "parcela_paga")
	GS.nome_porto = "Cais Mirim"
	var paginas_montadas: Array = []
	var caderno: Node = tela.get_node_or_null("Caderno")
	if caderno != null:
		for filho in caderno.get_children():
			if filho is PanelContainer and String(filho.name).begins_with("Pagina") \
					or String(filho.name) == "PrimeiraPagina":
				paginas_montadas.append(filho)
	var recibo: Node = caderno.find_child("Recibo", true, false) if caderno != null else null
	_confere("D22: o caderno montou as duas páginas e o recibo (%d páginas)" % paginas_montadas.size(),
		paginas_montadas.size() == 2 and recibo != null)
	if recibo != null:
		# ⚠️ A COLUNA NÃO SE MEDE INTEIRA: o texto à mão quebra sozinho, e um
		# rótulo com quebra só sabe a altura depois de um passe de layout — que
		# esta suíte não dá (pedia 5.136 px). O texto mede-se pela conta da
		# pauta, acima; o recibo, que não quebra, pelo tamanho mínimo dele; e o
		# que os separa é a separação da coluna, uma vez por vão entre filhos.
		var pagina: Node = recibo
		while pagina != null and not (pagina is MarginContainer):
			pagina = pagina.get_parent()
		var coluna := (pagina as MarginContainer).get_child(0) as VBoxContainer
		var segunda_txt: float = fonte.get_multiline_string_size(longas[1],
			HORIZONTAL_ALIGNMENT_LEFT, largura, tam).y
		var n2: int = int(round(segunda_txt / linha))
		var pede_coluna: float = n2 * linha + (n2 - 1) * espaco \
			+ (recibo as Control).get_combined_minimum_size().y \
			+ (coluna.get_child_count() - 1) * coluna.get_theme_constant("separation")
		_confere("D22: a segunda página, com o recibo e o nome mais comprido, cabe na folha (pede %d, cabe %d)"
			% [int(ceil(pede_coluna)), int(altura)], pede_coluna > 300.0 and pede_coluna <= altura)
	root.remove_child(tela)
	tela.free()
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
	# A 085 conta só reparos liberados: no início há um, não o catálogo inteiro.
	# Depois de reparar o píer 2 ainda não abre o armazém; o rótulo mais longo
	# oferece ver as etapas. Medimos esse texto vindo do jogo, sem o inventar.
	var construir: Button = tela.get_node("LinhaConstruir/Upgrade")
	_confere("D23: o início só anuncia o píer 2 disponível",
		construir.text == "Construir  ·  1 disponível",
		"o botão diz '%s'" % construir.text)
	GS.comprar_estrutura("pier_2")
	tela._refresh_hud()
	_confere("D23: durante a obra, o catálogo abre e anuncia o andamento",
		construir.text == "Construir  ·  obra em andamento" and not construir.disabled,
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

	# ── 3. O TEXTO DENTRO DO CELULAR, CONTRA O FUNDO QUE ELE TEM MESMO ──
	#
	# ⚠️ IRMÃ DO D19, DO OUTRO LADO DA MESMA ARMADILHA. Lá a cor neutra do
	# jogo (feita para fundo escuro) caía sobre o cartão BRANCO e media
	# 2,93:1; aqui a cor de texto PADRÃO do tema é navy, feita para o cartão
	# branco, e cairia sobre o aparelho escuro. Um rótulo deste painel que
	# esqueça a variação sai invisível sem erro nenhum.
	#
	# ⚠️ E DESDE 26/09 O FUNDO NÃO É UM SÓ (`066`). Até lá todo rótulo caía na
	# TELA, e este bloco media-os contra ela; com o papel de parede, cada texto
	# vive numa peça opaca própria — a barra de status, o widget, a pílula do
	# nome — e medir contra a tela passou a medir contra um fundo que o texto
	# não tem, sempre a passar. Quem acha o fundo de cada texto é o MOTOR do
	# D33, que sobe pelos antepassados até ao primeiro opaco; e um texto
	# posto direto sobre o papel de parede sai PENDENTE, que aqui reprova —
	# a régua não sabe ler uma imagem, e o texto não pode depender dela.
	# A exceção é a HORA, que desde a quarta passagem pousa na imagem com um
	# CONTORNO opaco: a régua mede-a contra ele (`CONTORNO_MIN`), e sem
	# contorno ela volta aqui como pendente.
	var motor: RefCounted = load("res://scripts/validation/contraste_ui.gd").new()
	var linhas: Array = motor.medir(menu)
	_confere("o celular tem texto para medir (%d)" % linhas.size(), linhas.size() >= 8)
	var maus: Array = []
	var pior_razao := 99.0
	var pior_rotulo := ""
	for l in linhas:
		if String(l["estado"]) != "passa":
			maus.append("%s · %s %s" % [l["estado"], l["texto"], l["nota"]])
		elif float(l["razao"]) < pior_razao:
			pior_razao = float(l["razao"])
			pior_rotulo = "%s a %dpx" % [String(l["texto"]).substr(0, 28), int(l["px"])]
	_confere("nenhum texto do celular reprova nem fica sem fundo conhecido (pior: %.2f:1 em %s)"
			% [pior_razao, pior_rotulo], maus.is_empty(), "\n      ".join(maus))

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
		# ⚠️ E A MARGEM DO MIOLO, que é onde a grelha vive desde a `066`: a
		# tela passou a zero para a barra de status ir de borda a borda, e sem
		# esta linha a conta dava 28 px de folga que não existem.
		var miolo: Control = menu.find_child("Miolo", true, false)
		var util: float = largura \
			- corpo.get_margin(SIDE_LEFT) - corpo.get_margin(SIDE_RIGHT) \
			- visor.get_margin(SIDE_LEFT) - visor.get_margin(SIDE_RIGHT) \
			- float(miolo.get_theme_constant("margin_left")) \
			- float(miolo.get_theme_constant("margin_right"))
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
		var img := PropIso.imagem(tex).duplicate() as Image
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
			var img := PropIso.imagem(t)
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
# O neutro do jogo (0,51/0,6/0,706) media **2,82:1** sobre o creme da faixa —
# abaixo até do corte de texto GRANDE —, e é a cor que um rótulo novo herda
# sem ninguém pensar. O `CLAUDE.md` regista as outras três, no calendário, no
# painel Construir e no menu-celular.
#
# ⚠️ E EM 04/10 A FAIXA PASSOU A ESCURA (`081`), e a conta virou ao
# contrário: o neutro passou a ser a cor CERTA (5,05:1, o fundo para o qual
# foi feito) e o `RotuloApoio`, que o contador vestia sobre o creme, mede
# 2,71 no azul. É ele o defeito que a régua tem de reprovar agora.
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

	# ── o contraste do contador contra o FUNDO REAL, que é o do StyleBox da
	# faixa e não o branco do cartão de painel.
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
	_confere("D32: o contador passa o AA de texto pequeno sobre o fundo da faixa",
		razao >= D32_AA_PEQUENO, "mede %.2f:1, o corte é %.1f" % [razao, D32_AA_PEQUENO])

	# ── E A PROVA DE QUE A MEDIÇÃO SABE REPROVAR. Sem isto, um `_contraste`
	# avariado daria verde com qualquer cor — é a régua com o defeito injetado
	# embutido, como o `CLAUDE.md` exige de toda régua nova. O defeito é a
	# variação que o contador vestia até 04/10, lida do TEMA (`081`).
	var de_antes: Color = (load("res://ui/tema_brport.tres") as Theme).get_color(
		"font_color", "RotuloApoio")
	_confere("D32: e a régua reprova a cor de antes, que aqui não serve",
		_contraste(de_antes, caixa.bg_color) < D32_AA_PEQUENO,
		"o `RotuloApoio` mediu %.2f:1 — se passou, a conta está avariada"
			% _contraste(de_antes, caixa.bg_color))

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
#
# 24 desde a 4ª leva: o painel Construir COM ESTRUTURA DE PÉ, que é o verde
# do `UpgradePanel` — a mesma ordem outra vez, o percurso primeiro
# (`docs/decisoes/044`).
#
# 25 desde a `050`: o TRABALHADOR ESCOLHIDO, onde vive o único rótulo do jogo
# com fundo próprio — o selo. A seleção é um toque, e nenhum dos 24 tocava.
const D33_ESTADOS_MIN := 25


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
	var contorno := _d33_contorno(motor)
	_confere("D33: o contorno só é fundo quando é opaco e largo (5 controles)",
		contorno.is_empty(), ", ".join(contorno))

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
# ── OS CONTROLES DA REGRA DO CONTORNO (`066`, quarta passagem) ──
#
# A hora do celular e o nome da tela inicial pousam numa IMAGEM, e passam só
# porque a régua lê o contorno como o fundo da letra. Essa regra tem dois
# limiares — a largura mínima e a opacidade — e o jogo só monta o lado que
# PASSA deles: sem estes controles, apagar qualquer um dos dois limiares
# deixava tudo verde. Cada caso monta a mesma letra sobre a mesma imagem e
# muda UMA coisa no contorno.
func _d33_contorno(motor: RefCounted) -> PackedStringArray:
	var mau := PackedStringArray()
	var minimo: int = motor.CONTORNO_MIN
	var navy := Color(0.051, 0.102, 0.149, 1)
	var casos := [
		["sem contorno", 0, navy, "pendente"],
		["contorno opaco no mínimo", minimo, navy, "passa"],
		["contorno um px abaixo do mínimo", minimo - 1, navy, "pendente"],
		["contorno translúcido", minimo, Color(navy, 0.5), "pendente"],
		["contorno da cor da letra", minimo, Color(1, 1, 1, 1), "reprova"],
	]
	var imagem := Image.create(4, 4, false, Image.FORMAT_RGBA8)
	imagem.fill(Color(0.5, 0.5, 0.5))
	for c in casos:
		var raiz := Control.new()
		var fundo := TextureRect.new()
		fundo.texture = ImageTexture.create_from_image(imagem)
		fundo.anchor_right = 1.0
		fundo.anchor_bottom = 1.0
		raiz.add_child(fundo)
		var letra := Label.new()
		letra.text = "09:41"
		letra.add_theme_color_override("font_color", Color(1, 1, 1, 1))
		letra.add_theme_font_size_override("font_size", 14)
		letra.add_theme_constant_override("outline_size", int(c[1]))
		letra.add_theme_color_override("font_outline_color", c[2])
		raiz.add_child(letra)
		root.add_child(raiz)
		var linhas: Array = motor.medir(raiz)
		var estado := "nenhuma linha" if linhas.size() != 1 else String(linhas[0]["estado"])
		if estado != String(c[3]):
			mau.append("%s deu %s, esperado %s" % [c[0], estado, c[3]])
		root.remove_child(raiz)
		raiz.free()
	return mau


func _d33_forma(texto: String) -> String:
	var fora := ""
	for c in texto.to_lower():
		if c.is_valid_int() or c in ".,:;!?$-—·\"":
			continue
		fora += c
	return " ".join(fora.split(" ", false)).replace("r ", " ").strip_edges()


# ============================================================
# D34 — saiu com a fileira dos trabalhadores (`083`). Perguntava de onde vinha
# a borda do cartão do trabalhador ESCOLHIDO (`045`, `050`); desde a fila não
# há cartão de trabalhador nem seleção, e o retrato mora no cabeçalho da doca.
# O número fica vago de propósito: os outros blocos citam-se pelo número.
# ============================================================


# ── D35 ── O TRÂNSITO: ninguém passa por cima de ninguém (23/09)
#
# Os §1–§8 do D13 conferem cada rota contra o mapa, e nenhum pergunta o que só
# existe com CINCO camiões ao mesmo tempo. Medido em 23/09, antes da mão
# direita: 27 a 72 sobreposições à vista por meia hora de jogo, nos dez pontos
# em que as duas rotas se cruzavam, mais a ré a largar o berço por cima de quem
# passava. As regras que as acabaram (`_boca_livre()`, `_curvas_livres()`,
# `_arranque_livre()`, a trava do berço) são quatro, e cada uma defende um
# sítio; a pergunta que as junta é esta: anda-se a cena, e em nenhum instante
# duas PEGADAS se tocam à vista.
#
# ⚠️ A PEGADA MEDE-SE DO NÓ, pela projeção das âncoras (`_mundo()`), e não pelo
# `mundo_do_no()` do jogo: é o mesmo princípio da `_tela_da_rota()` deste
# arquivo — perguntar ao jogo onde está o camião seria o teste a medir com a
# conta que quer conferir. E o eixo sai da TEXTURA que o nó mostra.
#
# ⚠️ E ZERO SOBREPOSIÇÕES DE GRAÇA É O PRIMEIRO DEFEITO A TEMER: camiões presos
# não se tocam. Por isso o bloco exige também que cada um CHEGUE ao fim da sua
# rota várias vezes, e que os dois sentidos ENCOSTEM — com a carga do navio.
#
# Anda-se uma cena NOVA, e só os tweens dela: os da cena do resto da suíte não
# se mexem, e os blocos que vêm depois leem-na como estava.
var _d35_completo := false

## O chassi de cada camião, por EMPRESA, em unidades de mundo: `CAMINHOES` de
## `blender/brp_porto.py` vezes o `ESCALA_CAMINHAO` (0,72). E a largura, que é
## a mesma para todos (`LARG`, 0,62, vezes 0,72). A pegada é o retângulo do
## chassi, centrado no ponto da rota: é onde o construtor o põe.
##
## ⚠️ O BICUDO É MAIS COMPRIDO (27/09, `070`): o capô (`CAPO`, 0,40) cresce À
## FRENTE do camião de sempre, e o chassi cresce com ele, centrado na âncora.
## A empresa 1 é bicuda nos três médios (`EMPRESAS`); o baú bicudo fica com os
## 1,96 da carreta, que continua a ser o mais comprido do jogo.
const D35_CAPO := 0.40
const D35_CHASSI := {
	"pescado": [1.10 * 0.72, (1.10 + D35_CAPO) * 0.72],
	"granel": [1.48 * 0.72, (1.48 + D35_CAPO) * 0.72],
	"armazenagem": [1.56 * 0.72, (1.56 + D35_CAPO) * 0.72],
	"conteiner": [1.96 * 0.72, 1.96 * 0.72]}
const D35_LARG := 0.62 * 0.72
const D35_SEGUNDOS := 3600.0
# ⚠️ E ANTES DAS VISITAS, UMA MEIA HORA DE PASSAGEM (27/09, `070`): as docas
# vazias, e cada camião a levar o que a RODA lhe dá. É onde a roda da carga
# manda sozinha, e onde a vez das transportadoras pode casar com ela; a agenda
# de visitas esconde-o, porque troca a carga de quem encosta. Medido: com a vez
# do retorno a `(j + voltas) % 2`, só a pergunta da passagem reprovou.
const D35_PASSAGEM := 1800.0
const D35_PASSO := 0.2
const D35_SEMENTE := 20260923
const D35_TURNO := Vector2(3.0, 12.0)

func _d35_transito() -> void:
	var GS: Node = root.get_node("GameState")
	if GS.phase == "rival_offer":
		GS.resolve_rival_offer(true)
	var docas_antes: int = GS.docks.size()
	var guardadas: Array = []
	for d in GS.docks:
		guardadas.append([d["boat"], d["worker_id"]])
	# ⚠️ UM DICIONÁRIO, E NÃO A LISTA. A suíte nunca deixa passar um frame, e
	# por isso nenhum tween acabado ou morto sai da lista do motor: aqui ela já
	# traz perto de MIL, e perguntar `Array.has()` a cada um, a cada passo,
	# fazia este bloco custar 62 s (medido: 983 tweens, 99% do tempo no laço).
	var tweens_antes := {}
	for tw in get_processed_tweens():
		tweens_antes[tw] = true
	var tela: Control = load(CENA).instantiate()
	root.add_child(tela)
	var consts: Dictionary = tela.get_script().get_script_constant_map()
	var acessos: Array = consts["ACESSOS_DOCA"]
	while GS.docks.size() < acessos.size():
		GS.docks.append({"boat": null, "worker_id": null})
	for d in GS.docks:
		d["boat"] = null
		d["worker_id"] = null
	# ⚠️ SÓ OS CAMIÕES ANDAM. A cena nova arma também a espuma, os coqueiros,
	# as boias e as luzes, e andá-los 12.000 vezes fazia este bloco custar 60 s
	# a uma suíte de 3 (medido em 23/09). Mata-se tudo o que ela armou e
	# rearmam-se os camiões pelas MESMAS duas funções do `_ready()` — os nós
	# ainda estão nas origens, porque nada andou.
	for tw in get_processed_tweens():
		if not tweens_antes.has(tw):
			tw.kill()
	tela.call("_animar_caminhoes")
	tela.call("_animar_retorno")

	var cenario := tela.get_node("MapaWrap/Cenario")
	var visivel := Rect2(Vector2.ZERO, (tela.get_node("MapaWrap") as Control).size)
	var desenho := _desenho_dos_caminhoes(tela)
	var alt := float(_ancoras["projecao"]["alt_cais"])
	var qual: Dictionary = {}                 # textura -> [motivo, eixo, empresa]
	for motivo in (consts["CAMINHOES"] as Dictionary):
		var empresas: Array = consts["CAMINHOES"][motivo]
		for e in range(empresas.size()):
			var par: Dictionary = empresas[e]
			for chave in par:
				qual[par[chave]] = [motivo, String(chave).substr(0, 2), e]
	var nos: Array = []
	for k in range((consts["CAMINHAO_ORIGENS"] as Array).size()):
		nos.append([cenario.get_node("Caminhao%d" % k), "ida"])
	for k in range((consts["CAMINHAO_RETORNO_ORIGENS"] as Array).size()):
		nos.append([cenario.get_node("CaminhaoRetorno%d" % k), "retorno"])
	var fim := {"ida": (consts["ROTA_ESTRADA"] as Array)[-1],
		"retorno": (consts["ROTA_RETORNO"] as Array)[-1]}

	# A agenda das docas: um sorteio PRÓPRIO, semeado — o do jogo é o que o
	# simulador de balanceamento mede, e não se lhe toca.
	#
	# ⚠️ E OS NAVIOS DELA TRAZEM TODOS OS MOTIVOS DO JOGO desde 27/09 (`070`),
	# e não só os que o porto da suíte recebe. Com os do porto em ruínas a rua
	# só levava pescado e armazenagem: a carreta e o basculante — o camião mais
	# comprido e o bicudo de 1,88 — nunca tinham passado por esta pergunta, e
	# as dezasseis silhuetas deles não podiam ser vistas a chegar à rua. Um
	# porto de nível 3 recebe os quatro; a roda continua a ser a do porto.
	var rng := RandomNumberGenerator.new()
	rng.seed = D35_SEMENTE
	var motivos: Array = GS.MOTIVOS.keys()
	var id_barco := 91000
	var prox_turno := 0.0

	var sobre := ""
	var eventos := 0
	var ultimo_evento := -1.0e9           # o relógio começa negativo, na passagem
	var cargas := ""
	var encostos := {"ida": 0, "retorno": 0}
	var chegadas: Array = []
	chegadas.resize(nos.size())
	chegadas.fill(0)
	var no_fim: Array = []
	no_fim.resize(nos.size())
	no_fim.fill(true)
	var no_berco: Array = []
	no_berco.resize(nos.size())
	no_berco.fill(-1)
	# O que a rua MOSTROU: a textura de cada nó a cada passo (as 32 têm de
	# aparecer), e — só na passagem — que empresas cada serviço levou em cada
	# sentido, que é onde a vez pode casar com a roda.
	var mostradas := {}
	var na_roda := {}                      # "ida|pescado" -> {empresa: true}
	var t := -D35_PASSAGEM
	prox_turno = 0.0
	while t < D35_SEGUNDOS:
		if t >= prox_turno:
			for d in GS.docks:
				if d["boat"] != null and rng.randf() < 0.35:
					d["boat"] = null
					d["worker_id"] = null
				elif d["boat"] == null and rng.randf() < 0.5:
					id_barco += 1
					d["boat"] = {"id": id_barco, "classe": "pesqueiro",
						"motivo": motivos[rng.randi() % motivos.size()]}
					d["worker_id"] = 1
			tela.call("_docas_mudaram")
			prox_turno = t + rng.randf_range(D35_TURNO.x, D35_TURNO.y)
		for tw in get_processed_tweens():
			if tw.is_running() and not tweens_antes.has(tw):
				tw.custom_step(D35_PASSO)
		t += D35_PASSO

		var pegadas: Array = []
		for k in range(nos.size()):
			var no := nos[k][0] as TextureRect
			var p := _mundo(_origem(no), alt)
			var q: Array = qual.get(no.texture, ["conteiner", "my", 0])
			var comp: float = D35_CHASSI[q[0]][q[2]]
			mostradas[no.texture] = true
			if t < 0.0 and qual.has(no.texture):
				var chave_roda := "%s|%s" % [nos[k][1], q[0]]
				if not na_roda.has(chave_roda):
					na_roda[chave_roda] = {}
				na_roda[chave_roda][q[2]] = true
			var meia := Vector2(D35_LARG, comp) / 2.0 if q[1] == "my" \
				else Vector2(comp, D35_LARG) / 2.0
			var caixa := Rect2(no.position + Vector2(MEIO_QUADRO, MEIO_QUADRO)
				+ desenho.position, desenho.size)
			pegadas.append([p, meia, visivel.intersects(caixa)])
			# Chegou ao fim da rota: conta uma volta.
			var no_ponta: bool = p.distance_to(fim[nos[k][1]]) < 0.05
			if no_ponta and not no_fim[k]:
				chegadas[k] += 1
			no_fim[k] = no_ponta
			# Encostou num berço: conta, e confere a carga contra o navio.
			var berco := -1
			for d in range(acessos.size()):
				if p.distance_to(acessos[d]["paragem"]) < 0.05:
					berco = d
			if berco >= 0 and no_berco[k] < 0 \
					and int((tela.get("_visita_do_berco") as Array)[berco]) >= 0:
				encostos[nos[k][1]] += 1
				var navio: String = GS.docks[berco]["boat"]["motivo"]
				if q[0] != navio and cargas == "":
					cargas = "t=%.1f: %s encostou no berço %d com %s, e o navio é de %s" \
						% [t, no.name, berco + 1, q[0], navio]
			no_berco[k] = berco
		for a in range(pegadas.size()):
			for b in range(a + 1, pegadas.size()):
				if not (pegadas[a][2] or pegadas[b][2]):
					continue             # os dois fora do quadro: a pausa, empilhados
				var dist: Vector2 = ((pegadas[a][0] as Vector2) - pegadas[b][0]).abs() \
					- pegadas[a][1] - pegadas[b][1]
				if maxf(dist.x, dist.y) < 0.0 and t - ultimo_evento > 3.0:
					eventos += 1
					ultimo_evento = t
				if maxf(dist.x, dist.y) < 0.0 and sobre == "":
					sobre = "t=%.1f: %s em %s e %s em %s sobrepõem-se %.2f" \
						% [t, nos[a][0].name, pegadas[a][0], nos[b][0].name,
							pegadas[b][0], -maxf(dist.x, dist.y)]

	for tw in get_processed_tweens():
		if not tweens_antes.has(tw):
			tw.kill()
	root.remove_child(tela)
	tela.free()
	GS.docks.resize(docas_antes)
	for k in range(docas_antes):
		GS.docks[k]["boat"] = guardadas[k][0]
		GS.docks[k]["worker_id"] = guardadas[k][1]

	_confere("em %.0f s de jogo, nenhum camião passa por cima de outro à vista"
		% (D35_PASSAGEM + D35_SEGUNDOS),
		sobre == "", "%d vez(es); a primeira: %s" % [eventos, sobre])

	# ── AS 32 CHEGAM À RUA (27/09, `070`) ──
	#
	# A lição da `059`: a chave que escolhe a arte só alcança tantas peças
	# quantos valores ela toma, e 27 retratos quase ficaram gerados, validados e
	# sem ninguém os ver. As dezasseis da segunda transportadora estariam no
	# mesmo sítio com a vez partida — `_empresa_da_vez()` a devolver sempre 0, ou
	# um caminho do percurso a esquecer a empresa —, e o §4 e o §f passariam,
	# porque perguntam à função e não à rua. Esta pergunta lê o NÓ, a cada
	# passo, como o jogador o vê.
	var faltam: Array = []
	var total := 0
	for tex in _texturas_dos_caminhoes(consts):
		total += 1
		if not mostradas.has(tex):
			faltam.append(_arquivo(tex))
	_confere("as %d silhuetas de camião aparecem na rua (serviço × empresa × silhueta)" % total,
		faltam.is_empty(), "nunca apareceram: %s" % str(faltam))
	# E NA PASSAGEM, cada serviço que a roda pôs na rua levou as DUAS empresas,
	# nos dois sentidos. É a pergunta que a agenda de visitas não faz: com a vez
	# do retorno a `(j + voltas) % 2`, a mesma conta com que a roda lhe escolhe a
	# carga, o pescado do retorno saiu sempre da empresa 0 — e a pergunta de
	# cima passou, porque quem encosta leva a carga do navio e desfaz o par.
	var so_uma := ""
	var sentidos := {}
	var empresas_por_servico := 0
	for motivo in (consts["CAMINHOES"] as Dictionary):
		empresas_por_servico = maxi(empresas_por_servico,
			(consts["CAMINHOES"][motivo] as Array).size())
	for chave_roda in na_roda:
		sentidos[String(chave_roda).get_slice("|", 0)] = true
		if (na_roda[chave_roda] as Dictionary).size() < empresas_por_servico and so_uma == "":
			so_uma = "%s só levou a(s) empresa(s) %s" \
				% [chave_roda, str((na_roda[chave_roda] as Dictionary).keys())]
	_confere("na passagem, cada serviço da roda leva as %d empresas, nos dois sentidos (%d casos)"
		% [empresas_por_servico, na_roda.size()],
		so_uma == "" and sentidos.has("ida") and sentidos.has("retorno"),
		so_uma if so_uma != "" else "os sentidos vistos: %s" % str(sentidos.keys()))
	var parado := ""
	for k in range(nos.size()):
		if chegadas[k] < 5 and parado == "":
			parado = "%s só chegou %d vez(es) ao fim da rota" % [nos[k][0].name, chegadas[k]]
	_confere("e todos andam: cada um chega ao fim da rota pelo menos 5 vezes",
		parado == "", parado)
	_confere("a ida encosta nos berços (%d vezes)" % encostos["ida"], encostos["ida"] > 0)
	_confere("e o retorno também (%d vezes)" % encostos["retorno"], encostos["retorno"] > 0)
	_confere("e quem encosta leva a carga do navio", cargas == "", cargas)
	# ⚠️ A BANDEIRA DO SUB-BLOCO CONFERE-SE AQUI. Um erro de execução lá dentro
	# aborta SÓ aquela função, e este bloco seguia até ao `_d35_completo` como
	# se ela tivesse corrido — mordeu na primeira versão, com `SCRIPT ERROR` e
	# o bloco a PASSAR.
	_d35_previsao_das_curvas()
	_confere("a previsão das curvas correu até ao fim", _d35_previsao_completa)
	_d35_completo = true


# ── D35 · A PREVISÃO DAS CURVAS, posta à prova em todas as posições
#
# O andar da cena acima só apanha a falta da previsão se a agenda calhar pôr
# uma ida e um retorno na mesma curva ao mesmo tempo — e isso é sorteio: medido
# em 23/09, sem a previsão, a hora de jogo dava de ZERO a quatro colisões
# conforme a semente e o ritmo dos turnos. Escolher a semente que apanha o
# mutante seria afinar o teste ao defeito.
#
# Esta pergunta não depende de sorteio: põe um retorno em CADA ponto da rota
# dele, de 0,1 em 0,1 unidade, e pergunta à regra se uma ida pode arrancar
# agora. A VERDADE sai de outra conta, feita aqui: andar os dois caminhos à
# mesma velocidade e ver se as pegadas se tocam. A regra pode ser mais
# cautelosa do que a verdade (esperar sem precisar custa segundos fora do
# quadro); o que não pode é deixar entrar quem vai bater.
var _d35_previsao_completa := false

func _d35_previsao_das_curvas() -> void:
	# Uma cena NOVA, parada: o `_main` do resto da suíte já foi trocado por
	# blocos anteriores, e nenhum tween desta anda.
	var tweens_antes := {}
	for tw in get_processed_tweens():
		tweens_antes[tw] = true
	var tela: Control = load(CENA).instantiate()
	root.add_child(tela)
	for tw in get_processed_tweens():
		if not tweens_antes.has(tw):
			tw.kill()
	var consts: Dictionary = tela.get_script().get_script_constant_map()
	var cenario := tela.get_node("MapaWrap/Cenario")
	var pr: Dictionary = _ancoras["projecao"]
	var b_base: Vector2 = (cenario.get_node("CaminhaoRetorno0") as Control).position
	var fora := _tirar_da_rua(tela, cenario, consts)
	var ida: Array = _d35_no_tempo(tela, consts["ROTA_ESTRADA"], pr)
	var ret: Array = _d35_no_tempo(tela, consts["ROTA_RETORNO"], pr)
	var a_ida := cenario.get_node("Caminhao0") as TextureRect
	var b_ret := cenario.get_node("CaminhaoRetorno0") as TextureRect
	var b_origem: Vector2 = (consts["CAMINHAO_RETORNO_ORIGENS"] as Array)[0]
	var comp: float = D35_CHASSI["conteiner"][0]
	var deixou := ""
	var livres := 0
	var presos := 0
	# As posições do retorno: cada ponto da rua, e — o caso que a posição sozinha
	# não diz — cada ponto da ré de cada berço, a SAIR (`_saindo_do_berco`). Ali
	# ele está fora da rua, mas volta a ela daqui a nada; esquecê-lo deixava a
	# ida arrancar para uma curva onde ele ia estar. Cada caso traz o FUTURO dele
	# no tempo, que é contra o que a verdade se mede.
	var casos: Array = []
	for k in range(ret.size()):
		casos.append([ret[k][0], ret.slice(k), -1])
	var acessos: Array = consts["ACESSOS_DOCA"]
	for d in range(acessos.size()):
		var entrada: Vector2 = acessos[d]["entrada"]
		var paragem: Vector2 = acessos[d]["paragem"]
		var k_boca := 0
		for k in range(ret.size()):
			if (ret[k][0] as Vector2).distance_to(entrada) \
					< (ret[k_boca][0] as Vector2).distance_to(entrada):
				k_boca = k
		var x := paragem.x
		while x > entrada.x:
			var futuro: Array = []
			var u := x
			while u > entrada.x:
				futuro.append([Vector2(u, entrada.y), "mx"])
				u -= 0.1
			casos.append([Vector2(x, entrada.y), futuro + ret.slice(k_boca), d])
			x -= 0.2
	var ocupante: Array = tela.get("_ocupante_do_berco")
	var saindo: Array = tela.get("_saindo_do_berco")
	# E QUEM PERGUNTA também tem dois momentos: o arranque, no topo, e a saída
	# de um berço, que é a pergunta que o jogo faz com o `s` da virada menos a
	# ré. Só com os dois lados a sair é que um retorno a meio da ré encontra a
	# ida numa curva — a ida que arranca do topo nunca o alcança a tempo.
	var perguntas: Array = [[0.0, ida, -1]]
	for d in range(acessos.size()):
		var virada: Vector2 = acessos[d]["virada"]
		var paragem: Vector2 = acessos[d]["paragem"]
		var k_virada := _d35_indice(ida, virada)
		var re: Array = []
		var u := paragem.x
		while u > virada.x:
			re.append([Vector2(u, virada.y), "mx"])
			u -= 0.1
		var s_virada: float = tela.call("s_na_rota", virada, consts["ROTA_ESTRADA"])
		perguntas.append([s_virada - (paragem.x - virada.x), re + ida.slice(k_virada), d])
	for pergunta in perguntas:
		for caso in casos:
			var d: int = caso[2]
			if d >= 0 and d == int(pergunta[2]):
				continue            # os dois no mesmo berço: a trava não o deixa
			b_ret.position = b_base + _tela_da_rota(caso[0], b_origem, pr)
			if d >= 0:
				ocupante[d] = b_ret
				saindo[d] = true
			# A MESMA pergunta que o jogo faz: `_pode_arrancar()` no topo e
			# `_pode_sair()` no berço — boca e curvas juntas, como lá.
			var livre: bool = tela.call("_pode_arrancar", a_ida, true) if int(pergunta[2]) < 0 \
				else tela.call("_pode_sair", int(pergunta[2]), a_ida, true)
			if d >= 0:
				ocupante[d] = null
				saindo[d] = false
			if livre:
				livres += 1
			else:
				presos += 1
			if not livre or deixou != "":
				continue
			var futuro: Array = caso[1]
			var meu: Array = pergunta[1]
			for n in range(mini(meu.size(), futuro.size())):
				var pa: Vector2 = meu[n][0]
				var pb: Vector2 = futuro[n][0]
				if pa.distance_to(pb) > 3.0:
					continue
				var ma := Vector2(D35_LARG, comp) / 2.0 if meu[n][1] == "my" \
					else Vector2(comp, D35_LARG) / 2.0
				var mb := Vector2(D35_LARG, comp) / 2.0 if futuro[n][1] == "my" \
					else Vector2(comp, D35_LARG) / 2.0
				var dd := (pa - pb).abs() - ma - mb
				if maxf(dd.x, dd.y) < 0.0:
					deixou = "com a ida em s=%.1f e o retorno em %s%s, a regra deixa entrar e aos %.1f os dois tocam-se em %s / %s" \
						% [float(pergunta[0]), caso[0],
							" (a sair do berço %d)" % (d + 1) if d >= 0 else "",
							float(n) * 0.1, pa, pb]
					break

	# ── E AS PRIMEIRAS PASSAGENS NÃO SE TOCAM. Elas começam nas origens da cena
	# e não passam pelo arranque, logo nenhuma regra as separa: a escolha das
	# origens é que tem de o fazer, e medido em 23/09 a segunda origem do
	# retorno virava junto com o `Caminhao1` aos cinco segundos. O andar acima
	# não o garante — com a agenda dele o `Caminhao1` entrava no berço antes da
	# curva. Aqui anda-se cada par sem berço nenhum, que é o caso que aperta.
	var primeira := ""
	for i in range((consts["CAMINHAO_ORIGENS"] as Array).size()):
		var oi: Vector2 = (consts["CAMINHAO_ORIGENS"] as Array)[i]
		for j in range((consts["CAMINHAO_RETORNO_ORIGENS"] as Array).size()):
			var oj: Vector2 = (consts["CAMINHAO_RETORNO_ORIGENS"] as Array)[j]
			var ki := _d35_indice(ida, oi)
			var kj := _d35_indice(ret, oj)
			for n in range(mini(ida.size() - ki, ret.size() - kj)):
				var pa: Vector2 = ida[ki + n][0]
				var pb: Vector2 = ret[kj + n][0]
				if pa.distance_to(pb) > 3.0:
					continue
				var ma := Vector2(D35_LARG, comp) / 2.0 if ida[ki + n][1] == "my" \
					else Vector2(comp, D35_LARG) / 2.0
				var mb := Vector2(D35_LARG, comp) / 2.0 if ret[kj + n][1] == "my" \
					else Vector2(comp, D35_LARG) / 2.0
				var dd := (pa - pb).abs() - ma - mb
				if maxf(dd.x, dd.y) < 0.0 and primeira == "":
					primeira = "o Caminhao%d e o CaminhaoRetorno%d tocam-se aos %.1f, em %s / %s" \
						% [i, j, float(n) * 0.1, pa, pb]
					break

	# ── E DOIS ARRANQUES NO MESMO INSTANTE NÃO SAEM JUNTOS. O arranque é uma
	# pergunta ("a ponta está livre?") e uma ação (ir para lá), e a ação era do
	# tween, no passo SEGUINTE: dois camiões que perguntassem no mesmo passo
	# viam os dois a ponta livre e faziam a volta inteira um em cima do outro.
	# Nenhuma agenda do andar acima o provocava; um mutante de OUTRA regra, que
	# só mexia no tempo, é que o expôs. Aqui monta-se o instante de propósito:
	# todos no fim da rota, e dois a arrancar, um logo a seguir ao outro.
	var juntos := ""
	for par in [["Caminhao%d", "_entrar_no_mapa", consts["ROTA_ESTRADA"],
				consts["CAMINHAO_ORIGENS"]],
			["CaminhaoRetorno%d", "_subir", consts["ROTA_RETORNO"],
				consts["CAMINHAO_RETORNO_ORIGENS"]]]:
		var rota: Array = par[2]
		var ponta: Vector2 = rota[0]
		# Todos de volta ao fim da rota: o par anterior deixou um camião na
		# ponta dele, e a previsão das curvas faria, com razão, esperar este.
		for guardado in fora:
			(guardado[0] as Control).position = guardado[1]
		fora = _tirar_da_rua(tela, cenario, consts)
		tela.call(par[1], 0, ponta, 5.0)
		tela.call(par[1], 1, ponta, 5.0)
		var alt := float(_ancoras["projecao"]["alt_cais"])
		var n_na_ponta := 0
		for k in range(2):
			var no := cenario.get_node(String(par[0]) % k) as Control
			if _mundo(_origem(no), alt).distance_to(ponta) < 0.05:
				n_na_ponta += 1
		if n_na_ponta != 1 and juntos == "":
			juntos = "%d camiões %s na ponta %s depois de dois arranques seguidos" \
				% [n_na_ponta, par[1], ponta]
	root.remove_child(tela)
	tela.free()
	_confere("dois arranques seguidos: um sai, o outro espera", juntos == "", juntos)
	_confere("as primeiras passagens, que nenhuma regra separa, não se tocam",
		primeira == "", primeira)
	_confere("quem entra na rua — no arranque ou a sair do berço — nunca vai bater (%d x %d posições)" % [perguntas.size(), casos.size()],
		deixou == "", deixou)
	# E ela tem de responder das duas maneiras, senão é de graça: sempre "não"
	# também nunca deixaria bater ninguém.
	_confere("e responde das duas maneiras (%d livres, %d à espera)" % [livres, presos],
		livres > presos and presos > 0)
	_d35_previsao_completa = true


## A amostra de `amostras` mais perto de `p`.
func _d35_indice(amostras: Array, p: Vector2) -> int:
	var melhor := 0
	for k in range(amostras.size()):
		if (amostras[k][0] as Vector2).distance_to(p) < (amostras[melhor][0] as Vector2).distance_to(p):
			melhor = k
	return melhor


## O caminho desenhado de `rota`, amostrado no TEMPO, de 0,1 em 0,1 unidade de
## eixo: `[ponto, eixo da silhueta]`. O caminho pergunta-se ao jogo (é o que o
## camião anda); o tempo mede-se aqui, pela projeção das âncoras.
func _d35_no_tempo(tela: Control, rota: Array, pr: Dictionary) -> Array:
	var unidade := Vector2(float(pr["meia_larg"]), float(pr["meia_alt"])).length()
	var out: Array = []
	var resto := 0.0
	for tr in tela.call("trechos_de", rota):
		var a: Vector2 = tr[0]
		var b: Vector2 = tr[1]
		var k: int = tr[2]
		var eixo := "mx" if absf((rota[k + 1] as Vector2).x - (rota[k] as Vector2).x) > 0.01 else "my"
		var dur := _tela_da_rota(b, a, pr).length() / unidade
		var u := resto
		while u < dur:
			out.append([a.lerp(b, u / dur), eixo])
			u += 0.1
		resto = u - dur
	return out


# ── D36 ── o calendário mostra na grelha o que a legenda promete
#
# Veredito do Bruno no gate do A5 (23/09): «os itens da legenda não aparecem
# no calendário». Não apareciam: a grelha marcava o dia com "•" e "!" no TEXTO
# e a legenda traduzia os dois num ÍCONE, e nenhuma suíte perguntava se as
# duas pontas mostravam o mesmo desenho. São três perguntas, e cada uma
# apanha um defeito que as outras deixam passar:
#
# (1) CADA DIA TEM OS ÍCONES DO SEU EVENTO. O esperado sai de
#     `GameState.calendario()` e do par campo → ícone ESCRITO AQUI, nunca da
#     `MARCAS` do painel: lida de lá, trocar os dois ícones na tabela mudava
#     a grelha e a legenda juntas e a asserção passava contente — o espelho.
#     O último dia tem DUAS marcas, e é o único estado em que "a primeira que
#     vale" e "todas as que valem" divergem.
# (2) A LEGENDA E A GRELHA MOSTRAM O MESMO CONJUNTO, dos dois lados: ícone na
#     legenda que a grelha não usa é o defeito de 23/09; ícone na grelha sem
#     linha na legenda é o mesmo com o sinal trocado.
# (3) A GRELHA NÃO ALARGA O CARTÃO. A semana tem OITO colunas, e com o ícone
#     ao lado do número a primeira versão desta mudança pedia 508 px num
#     interior de 456: o `PanelContainer` crescia para a direita e saía
#     descentrado, sem erro nenhum. Mede-se o mínimo do CARTÃO contra a
#     largura que o painel declara, que é a promessa que ele faz.
#
# Abre-se pela PORTA DO JOGADOR — o toque no chip do dia —, porque é o
# `_abrir_painel()` do `Main` que aplica o tema, e sem tema as margens e a
# fonte não são as do jogo.
var _d36_completo := false


func _d36_legenda_do_calendario() -> void:
	var GS: Node = root.get_node("GameState")
	GS.clear_save()
	GS._rng.seed = 20260903
	GS.new_game()
	if GS.phase == "rival_offer":
		GS.resolve_rival_offer(true)

	var tela: Control = load(CENA).instantiate()
	root.add_child(tela)
	var overlay: Node = tela.get_node("Overlay")
	var antes := overlay.get_child_count()
	var ev := InputEventMouseButton.new()
	ev.button_index = MOUSE_BUTTON_LEFT
	ev.pressed = false
	tela.get_node("HudBar/DiaPilula").gui_input.emit(ev)
	_confere("D36: o toque no dia abriu um painel", overlay.get_child_count() == antes + 1)
	var painel: Node = overlay.get_child(overlay.get_child_count() - 1)
	var vbox: VBoxContainer = painel._vbox

	# O par campo → ícone, escrito AQUI de propósito (ver o cabeçalho).
	var esperado_por_campo := {
		"fecha_semana": Icones.CAIXA.resource_path,
		"parcela_vence": Icones.PARCELA.resource_path,
	}

	# (1) dia a dia
	var na_grelha := {}
	var dias_errados: Array = []
	var com_duas := 0
	for dia in GS.calendario():
		var celula: Node = vbox.find_child("Dia%d" % int(dia["turno"]), true, false)
		if celula == null:
			dias_errados.append("%d sem célula" % int(dia["turno"]))
			continue
		var visto: Array = []
		for img in celula.find_children("*", "TextureRect", true, false):
			visto.append((img as TextureRect).texture.resource_path)
			na_grelha[(img as TextureRect).texture.resource_path] = true
		var quer: Array = []
		for campo in esperado_por_campo:
			if bool(dia[campo]):
				quer.append(esperado_por_campo[campo])
		visto.sort()
		quer.sort()
		if visto != quer:
			dias_errados.append("%d mostra %s, devia %s" % [int(dia["turno"]), visto, quer])
		if quer.size() > 1:
			com_duas += 1
	_confere("D36: cada dia do calendário mostra o ícone do seu evento",
		dias_errados.is_empty(), "; ".join(dias_errados))
	# Sem um dia de duas marcas, "a primeira" e "todas" dão o mesmo (ver acima).
	_confere("D36: há um dia com as duas marcas, e foi conferido", com_duas >= 1,
		"nenhum dia do calendário tem as duas — a pergunta ficou sem o caso que a aperta")

	# (2) a legenda: as linhas de ícone que vêm DEPOIS do rótulo "LEGENDA" —
	# o título também é uma linha de ícone e fica de fora.
	var na_legenda := {}
	var depois := false
	for filho in vbox.get_children():
		if filho is Label and (filho as Label).text == "LEGENDA":
			depois = true
		elif depois and filho is HBoxContainer:
			for img in filho.find_children("*", "TextureRect", true, false):
				na_legenda[(img as TextureRect).texture.resource_path] = true
	var so_na_legenda: Array = []
	for k in na_legenda:
		if not na_grelha.has(k):
			so_na_legenda.append(k)
	var so_na_grelha: Array = []
	for k in na_grelha:
		if not na_legenda.has(k):
			so_na_grelha.append(k)
	_confere("D36: a legenda tem ícones", not na_legenda.is_empty(),
		"nenhuma linha de ícone depois de LEGENDA")
	_confere("D36: todo ícone da legenda aparece na grelha", so_na_legenda.is_empty(),
		"só na legenda: %s" % [so_na_legenda])
	_confere("D36: todo ícone da grelha tem linha na legenda", so_na_grelha.is_empty(),
		"só na grelha: %s" % [so_na_grelha])

	# (3) o cartão
	var largura: int = painel.get_script().get_script_constant_map()["LARGURA"]
	var cartao: Control = vbox.get_parent()
	var pede: float = cartao.get_combined_minimum_size().x
	_confere("D36: a grelha cabe no cartão sem o alargar (pede %d de %d)" % [pede, largura],
		pede <= largura)

	overlay.remove_child(painel)
	painel.free()
	root.remove_child(tela)
	tela.free()
	_d36_completo = true


# ── D37 ── o diário cabe na página do caderno, e a letra cai na pauta
#
# O diário virou a primeira página de um caderno (`docs/decisoes/067`): uma
# página de tamanho FIXO — é o mesmo retângulo da folha de rosto, que vira
# para ela —, SEM rolagem, e com a letra à mão, que é mais larga do que a do
# jogo. Duas coisas podiam partir-se sem erro nenhum:
#
#  1. O TEXTO NÃO CABER: o `VBoxContainer` da página cresce com o rótulo, a
#     capa cresce com ela e desce por cima do botão — o F10 não o via, porque
#     o texto continua DENTRO do cartão. Mede-se com o nome de cais mais
#     comprido que a tela de nomes aceita, pelo tema e pelas medidas do
#     caderno, que vivem no `PainelNarrativo` — o mesmo sítio que o monta.
#     Na primeira medida (letra a 24 px, passo de 38) o texto pedia ~900 px de
#     uma página de 812, e a captura mostrou-o antes desta guarda existir.
#  2. A LETRA SAIR DA PAUTA: a data e o texto são dois rótulos, e só caem em
#     linhas seguidas se o vão entre eles (`CadernoLinhas`) for o
#     `line_spacing` da letra (`TextoCaderno`). São dois números no tema, e
#     nada mais os prende um ao outro.
var _d37_completo := false


func _d37_diario_na_pagina() -> void:
	var GS: Node = root.get_node("GameState")
	var tema: Theme = load("res://ui/tema_brport.tres")
	var PN: Dictionary = (load("res://scripts/PainelNarrativo.gd") as GDScript).get_script_constant_map()
	var capa: StyleBox = tema.get_stylebox("panel", "CadernoCapa")
	var fonte: Font = tema.get_font("font", "TextoCaderno")
	var tam: int = tema.get_font_size("font_size", "TextoCaderno")
	var espaco: int = tema.get_constant("line_spacing", "TextoCaderno")

	_confere("D37: o vão entre a data e o texto é o espaço entre linhas da letra",
		tema.get_constant("separation", "CadernoLinhas") == espaco,
		"CadernoLinhas separa %d, TextoCaderno espaça %d" % [
			tema.get_constant("separation", "CadernoLinhas"), espaco])

	var largura: float = float(PN["CADERNO_LARGURA"]) - capa.get_margin(SIDE_LEFT) \
		- capa.get_margin(SIDE_RIGHT) - float(PN["PAGINA_MARGEM_PAUTADA"]) \
		- float(PN["PAGINA_MARGEM_DIR"])
	var altura: float = float(PN["CADERNO_ALTURA"]) - capa.get_margin(SIDE_TOP) \
		- capa.get_margin(SIDE_BOTTOM) - float(PN["PAGINA_MARGEM_TOPO"]) \
		- float(PN["PAGINA_MARGEM_PE"])

	var antes: String = GS.nome_porto
	GS.nome_porto = "W".repeat(int(GS.NOME_MAX_CARACTERES))
	var texto: String = load("res://scripts/Narrativa.gd").diario()
	GS.nome_porto = antes
	var linha: float = fonte.get_height(tam)
	var corpo: float = fonte.get_multiline_string_size(texto, HORIZONTAL_ALIGNMENT_LEFT,
		largura, tam).y
	var linhas: int = int(round(corpo / linha))
	# A data ocupa duas linhas da pauta: ela e a linha em branco por baixo.
	var pede: float = (linhas + 2) * linha + (linhas + 1) * espaco
	_confere("D37: a primeira página, com o nome mais comprido, cabe na folha (pede %d, cabe %d)"
		% [int(ceil(pede)), int(altura)], linhas > 10 and pede <= altura)
	_d37_completo = true


# ── D38 ── a conversa: cada voz com o seu balão, num telefone que cabe
#
# A quarta passagem das mensagens (`067`) deu a cada pessoa o SEU balão e à
# conversa um telefone maior do que o do menu. Nada perguntava nenhuma das
# duas coisas:
#
#  1. O TOM DE CADA BALÃO SAI DA ROUPA DO RETRATO de quem fala, e o esperado
#     vem do PNG do retrato — não do tema nem do código que escolhe a
#     variação, que são onde o defeito moraria. Trocar dois ramos do
#     `_vestir_balao()` deixa os três tons distintos e todos legíveis (o D33
#     passa), e só esta pergunta reprova: o balão da Dona Cida teria o matiz
#     do fato do Sr. Ribeiro. A roupa é a mediana POR LUMINÂNCIA do tronco,
#     fora da gola e da gravata — um pixel de verdade, e não uma média que
#     inventasse um tom (`CLAUDE.md`, «reduzir uma janela a uma cor»).
#  2. OS TRÊS DISTINGUEM-SE, em ΔE (CIELAB). O corte está no meio da banda
#     entre o defeito (dois balões iguais, 0) e o mais perto dos três de hoje
#     (19,9, Ribeiro e Arlindo). O primeiro candidato — a roupa clareada com
#     branco, a 78%, 82% e 86% — dava 2,4 a 8,5, e ficava do lado que
#     reprova.
#  3. CADA VOZ TEM O MESMO TOM NOS DOIS BALÕES, e só o primeiro tem o bico: a
#     fala seguida é da mesma pessoa. E a amostra tem de trazer as duas
#     formas de cada voz, senão o D33 não mede metade das variações.
#  4. O TELEFONE MAIOR CABE NA TELA: o corpo, os botões de lado e o «Guardar o
#     telefone», que fica POR BAIXO do aparelho e é o primeiro a sair dos
#     1280 se a altura crescer. Lido dos `offset` dos nós contra o centro da
#     tela, e a tela do `project.godot`.
var _d38_completo := false
const D38_DELTA_E_MIN := 10.0


func _d38_vozes_da_conversa() -> void:
	var tema: Theme = load("res://ui/tema_brport.tres")
	var historico: Array = load("res://scripts/validation/contraste_ui.gd").new().amostra("historico")
	var cena: PackedScene = load("res://scenes/panels/PainelMensagens.tscn")
	if cena == null:
		_confere("D38: a cena da conversa carrega", false)
		return
	var painel: Control = cena.instantiate()
	painel.theme = tema
	root.add_child(painel)
	painel.call("setup", historico)
	var Msg: Dictionary = painel.get_script().get_script_constant_map()
	var omissao: Dictionary = Msg["CARA_DE_OMISSAO"]
	# `load()`, e não o nome da classe: a `Narrativa` fala do `GameState`, e
	# um `--script` compila antes de os autoloads existirem.
	var Nar = load("res://scripts/Narrativa.gd")

	# Os balões de cada voz, pelo TEXTO que a amostra lhe dá.
	var por_voz := {}
	for entrada in historico:
		var fonte: String = String(entrada["fonte"])
		if fonte == "sistema":
			continue
		var rotulo: Label = _d38_rotulo_com(painel, String(entrada["texto"]))
		if not por_voz.has(fonte):
			por_voz[fonte] = []
		if rotulo != null:
			por_voz[fonte].append(rotulo.get_parent())
	_confere("D38: a amostra fala pelas três vozes (%s)" % [por_voz.keys()],
		por_voz.size() == omissao.size())

	var cor_da_voz := {}
	var roupa := {}
	for fonte in por_voz:
		var baloes: Array = por_voz[fonte]
		var com_bico := 0
		var cores := {}
		for balao in baloes:
			var estilo := (balao as Control).get_theme_stylebox("panel") as StyleBoxFlat
			if estilo == null:
				continue
			cores[estilo.bg_color.to_html(false)] = estilo.bg_color
			if estilo.corner_radius_top_left < estilo.corner_radius_top_right:
				com_bico += 1
		_confere("D38: %s tem os dois balões — o primeiro, com bico, e o seguido (%d, %d com bico)"
			% [fonte, baloes.size(), com_bico], baloes.size() >= 2 and com_bico == 1)
		_confere("D38: os balões de %s têm um tom só" % fonte, cores.size() == 1,
			"%s" % [cores.keys()])
		if cores.size() >= 1:
			cor_da_voz[fonte] = cores.values()[0]
		roupa[fonte] = _d38_roupa(Nar.retrato(fonte, String(omissao[fonte])))

	# 1. cada balão tem o matiz da roupa de QUEM FALA, e não o de outro.
	for fonte in cor_da_voz:
		var h: float = (cor_da_voz[fonte] as Color).h
		var mais_perto := ""
		var menor := 999.0
		for outro in roupa:
			var d: float = _d38_distancia_de_matiz(h, (roupa[outro] as Color).h)
			if d < menor:
				menor = d
				mais_perto = outro
		_confere("D38: o balão de %s tem o matiz da roupa de quem fala (%.0f°, roupa %.0f°)"
			% [fonte, h * 360.0, (roupa[fonte] as Color).h * 360.0], mais_perto == fonte,
			"o matiz mais perto é o da roupa de %s" % mais_perto)

	# 2. os três distinguem-se.
	var vozes: Array = cor_da_voz.keys()
	for i in vozes.size():
		for j in range(i + 1, vozes.size()):
			var de: float = _d38_delta_e(cor_da_voz[vozes[i]], cor_da_voz[vozes[j]])
			_confere("D38: o balão de %s e o de %s distinguem-se (ΔE %.1f, mínimo %.0f)"
				% [vozes[i], vozes[j], de, D38_DELTA_E_MIN], de >= D38_DELTA_E_MIN)

	# 4. o telefone da conversa cabe na tela, com o «Guardar» por baixo.
	var tela := Vector2(float(ProjectSettings.get_setting("display/window/size/viewport_width")),
		float(ProjectSettings.get_setting("display/window/size/viewport_height")))
	var fora := []
	var medidos := []
	for filho in painel.get_children():
		if not (filho is Control) or filho is ColorRect:
			continue
		var c := filho as Control
		if c.anchor_left != 0.5 or c.anchor_top != 0.5:
			continue
		medidos.append(String(c.name))
		if c.offset_left < -tela.x / 2.0 or c.offset_right > tela.x / 2.0 \
				or c.offset_top < -tela.y / 2.0 or c.offset_bottom > tela.y / 2.0:
			fora.append("%s (%d..%d × %d..%d)" % [c.name, c.offset_left, c.offset_right,
				c.offset_top, c.offset_bottom])
	# Uma conta que não mediu nada passaria calada: o corpo e o «Guardar» têm
	# de estar entre os medidos.
	_confere("D38: mediu o corpo e o «Guardar» do telefone (%d peças)" % medidos.size(),
		medidos.has("Guardar") and medidos.size() >= 2, "%s" % [medidos])
	_confere("D38: o telefone da conversa e o «Guardar» cabem na tela de %d × %d"
		% [tela.x, tela.y], fora.is_empty(), "fora: %s" % [fora])

	root.remove_child(painel)
	painel.free()
	_d38_completo = true


func _d38_rotulo_com(no: Node, texto: String) -> Label:
	if no is Label and (no as Label).text == texto:
		return no
	for filho in no.get_children():
		var achado := _d38_rotulo_com(filho, texto)
		if achado != null:
			return achado
	return null


# A cor da roupa: a mediana por luminância do tronco — o quinto de baixo do
# retrato, nas duas faixas de fora (10–35% e 65–90% da largura), longe da gola,
# da camisa e da gravata ao centro. Um pixel em cada três, em cada eixo.
func _d38_roupa(retrato: Texture2D) -> Color:
	var img: Image = retrato.get_image()
	if img.is_compressed():
		img.decompress()
	var w := img.get_width()
	var h := img.get_height()
	var px: Array = []
	for y in range(int(h * 0.8), h, 3):
		for faixa in [[0.10, 0.35], [0.65, 0.90]]:
			for x in range(int(w * faixa[0]), int(w * faixa[1]), 3):
				var c := img.get_pixel(x, y)
				if c.a > 0.98:
					px.append(c)
	if px.is_empty():
		return Color(0, 0, 0, 0)
	px.sort_custom(func(a: Color, b: Color) -> bool: return a.get_luminance() < b.get_luminance())
	return px[px.size() / 2]


func _d38_distancia_de_matiz(a: float, b: float) -> float:
	var d := absf(a - b)
	return minf(d, 1.0 - d)


func _d38_delta_e(a: Color, b: Color) -> float:
	return _d38_lab(a).distance_to(_d38_lab(b))


func _d38_lab(c: Color) -> Vector3:
	var l := c.srgb_to_linear()
	var x := (0.4124 * l.r + 0.3576 * l.g + 0.1805 * l.b) / 0.95047
	var y := 0.2126 * l.r + 0.7152 * l.g + 0.0722 * l.b
	var z := (0.0193 * l.r + 0.1192 * l.g + 0.9505 * l.b) / 1.08883
	var f := func(t: float) -> float:
		return pow(t, 1.0 / 3.0) if t > 0.008856 else 7.787 * t + 16.0 / 116.0
	var fx: float = f.call(x)
	var fy: float = f.call(y)
	var fz: float = f.call(z)
	return Vector3(116.0 * fy - 16.0, 500.0 * (fx - fy), 200.0 * (fy - fz))


# ── D39 ── o pau-de-carga que descarrega (02/10, `docs/decisoes/075`, `076`)
#
# No porto de nível 1 quem descarrega é o pau-de-carga — do porão do pesqueiro
# a uma pilha no tabuado —, e o trabalhador opera o guincho ao pé do mastro.
# Cinco perguntas, e cada uma nomeia o defeito que caça:
#
#   1. TODA classe que o nível 1 recebe tem a sua pilha. A lista do que é
#      preciso sai das CLASSES do `GameState`, nunca da própria tabela.
#   2. OS DOIS SEXOS CHEGAM ao guincho, com figuras distintas, e a alavanca
#      mexe (os dois quadros diferem). Um `sexo_do_rosto()` que devolvesse
#      sempre "h" deixaria os quadros dela gerados e por ver.
#   3. O CICLO não salta: o pau só passa a um ângulo vizinho, o gancho só
#      desce nas duas pontas, a carga só se engata em baixo no barco e só se
#      larga em baixo na pilha, e todo quadro da tabela passa.
#   4. A CARGA DESCE DENTRO DE CADA CASCO que o nível 1 recebe e POUSA EM
#      CIMA DA PILHA, e o operador pisa o tabuado. É o render lido contra os
#      nós da cena: o pau mora num PNG, o casco noutro, e o deslocamento entre
#      os dois no `Dock.tscn` — três fontes, e nenhum número copiado.
#   5. NA DOCA MONTADA: trabalha com `progress` zero (o pesqueiro parte no
#      avanço em que o `progress` chega a 1; medido, 449 instantes de alocado
#      com barco no nível 1 e nenhum com `progress > 0`), um `refresh()` a
#      meio não recomeça o ciclo nem repõe o pau em repouso, a imagem do pau
#      não gira por cima dos quadros, no nível 3 a lança volta a varrer e a
#      pilha sai, e liberado a pilha sai. (O nível 2 tem guindaste próprio
#      desde a `077`, e pergunta-o o D40.)
var _d39_completo := false


func _d39_trabalhador_que_anda() -> void:
	var GS: Node = root.get_node("GameState")
	var DockS: Script = load("res://scripts/Dock.gd")
	var Ret: Script = load("res://scripts/Retratos.gd")
	var k: Dictionary = DockS.get_script_constant_map()
	var pilhas: Dictionary = k["PILHAS_N1"]
	var quadros: Dictionary = k["QUADROS_TRABALHADOR"]
	var lanca: Dictionary = k["LANCA_N1"]

	# 1 ── a tabela contra as classes que o nível 1 recebe
	var exigidas := 0
	for classe in GS.CLASSES_DE_NAVIO:
		var dados: Dictionary = GS.CLASSES_DE_NAVIO[classe]
		if int(dados["nivel"]) > 1:
			continue
		for motivo in dados["motivos"]:
			if int(dados["motivos"][motivo]) <= 0:
				continue
			exigidas += 1
			_confere("D39: %s · %s tem pilha no nível 1" % [classe, motivo],
				pilhas.has(classe) and (pilhas[classe] as Dictionary).has(motivo)
					and pilhas[classe][motivo] is Texture2D,
				"o guindaste rebentaria no `refresh()` ao receber este barco")
	_confere("D39: o nível 1 recebe alguma classe (%d pares)" % exigidas, exigidas > 0)

	# 2 ── os dois sexos chegam ao guincho, e a alavanca mexe
	var por_sexo := {"h": 0, "m": 0}
	for i in range((Ret.get_script_constant_map()["TRABALHADORES"] as Array).size()):
		var s: String = Ret.sexo_do_rosto(i)
		if por_sexo.has(s):
			por_sexo[s] += 1
	_confere("D39: há rostos de homem e de mulher (%s)" % [por_sexo],
		por_sexo["h"] > 0 and por_sexo["m"] > 0 \
			and por_sexo["h"] + por_sexo["m"] \
				== (Ret.get_script_constant_map()["TRABALHADORES"] as Array).size())
	for q in range(2):
		_confere("D39: guincho %d — a figura dela não é a dele" % q,
			PropIso.imagem(quadros["h"]["guincho"][q]).get_data() \
				!= PropIso.imagem(quadros["m"]["guincho"][q]).get_data())
	for sexo in ["h", "m"]:
		_confere("D39: %s — a alavanca mexe entre os dois quadros" % sexo,
			PropIso.imagem(quadros[sexo]["guincho"][0]).get_data() \
				!= PropIso.imagem(quadros[sexo]["guincho"][1]).get_data())
	_confere("D39: o parado dela não é o dele",
		PropIso.imagem(quadros["h"]["parado"]).get_data() \
			!= PropIso.imagem(quadros["m"]["parado"]).get_data())

	# 3 ── o ciclo, como aritmética
	var dt := 1.0 / 60.0
	var anterior: Dictionary = _d39_passo(String(DockS.pose_do_guindaste(0.0)["lanca"]))
	var saltos := 0
	var desce_fora := 0
	var carga_fora := 0
	var vistos := {}
	var t := 0.0
	while t < 2.0 * float(DockS.duracao_do_ciclo()):
		t += dt
		var chave: String = String(DockS.pose_do_guindaste(t)["lanca"])
		vistos[chave] = true
		var p := _d39_passo(chave)
		if absi(int(p["giro"]) - int(anterior["giro"])) > 1:
			saltos += 1
		if bool(p["baixo"]) != bool(anterior["baixo"]) \
				and (p["giro"] != anterior["giro"] or p["carga"] != anterior["carga"]
					or not (int(p["giro"]) in [0, 6])):
			desce_fora += 1
		if bool(p["carga"]) != bool(anterior["carga"]):
			var engata := bool(p["carga"]) and bool(p["baixo"]) and bool(anterior["baixo"]) \
				and int(p["giro"]) == 0
			var larga := not bool(p["carga"]) and bool(p["baixo"]) and bool(anterior["baixo"]) \
				and int(p["giro"]) == 6
			if not (engata or larga):
				carga_fora += 1
		anterior = p
	_confere("D39: o pau só passa a um ângulo vizinho (%d saltos)" % saltos, saltos == 0)
	_confere("D39: o gancho só desce nas pontas (%d fora)" % desce_fora, desce_fora == 0)
	_confere("D39: a carga engata no barco e larga na pilha (%d fora)" % carga_fora,
		carga_fora == 0)
	var faltam: Array = []
	for chave in lanca:
		if not vistos.has(chave):
			faltam.append(chave)
	_confere("D39: todo quadro do pau passa no ciclo", faltam.is_empty(),
		"nunca aparecem: %s" % [faltam])

	# 4 ── no render: a carga desce no casco e pousa na pilha; ele pisa o tabuado
	var doca: Control = load("res://scenes/dock/Dock.tscn").instantiate()
	var no_pier := (doca.get_node("Pier") as Control).position
	var no_lanca := (doca.get_node("Lanca") as Control).position
	var no_barco := (doca.get_node("Barco") as Control).position
	var no_trab := (doca.get_node("Trabalhador") as Control).position
	var no_pilha := (doca.get_node("Pilha") as Control).position
	doca.free()
	var no_barco_v: Rect2 = _d39_carga(lanca["barco_c"], lanca["barco"])
	_confere("D39: a lingada aparece no quadro do barco", no_barco_v.has_area())
	var cascos: Dictionary = k["CASCOS"]
	var cascos_vistos := 0
	for classe in GS.CLASSES_DE_NAVIO:
		if int(GS.CLASSES_DE_NAVIO[classe]["nivel"]) > 1:
			continue
		for motivo in GS.CLASSES_DE_NAVIO[classe]["motivos"]:
			for casco in cascos[classe][motivo]:
				cascos_vistos += 1
				# O centro da carga, do quadro da lança para o do barco.
				var ponto: Vector2 = no_barco_v.get_center() + no_lanca - no_barco
				var cheio := _d39_desenho_a_volta(casco, ponto, 3)
				_confere("D39: a carga desce dentro do %s (%s, %.0f%% de casco à volta)"
						% [String(casco.resource_path).get_file().get_basename(), motivo,
						   cheio * 100.0],
					cheio >= D39_CASCO_MIN,
					"a lingada desce na água ao lado dele")
	_confere("D39: percorreu os cascos do nível 1 (%d)" % cascos_vistos, cascos_vistos > 0)

	var na_pilha: Rect2 = _d39_carga(lanca["pilha_c"], lanca["pilha"])
	for classe in pilhas:
		for motivo in pilhas[classe]:
			var pilha: Rect2 = PropIso.desenho(pilhas[classe][motivo])
			pilha.position += no_pilha - no_lanca
			var dy := na_pilha.end.y - pilha.position.y
			var dx := na_pilha.get_center().x - pilha.get_center().x
			_confere("D39: %s · %s — a carga pousa em cima da pilha (dx %.1f, dy %.1f)"
					% [classe, motivo, dx, dy],
				absf(dx) <= D39_PILHA_DX and dy >= D39_PILHA_DY_MIN and dy <= D39_PILHA_DY_MAX,
				"o fundo da carga tem de cair no topo da pilha")

	var pier_n1: Texture2D = (k["ArtePier"] as Array)[0]
	for sexo in ["h", "m"]:
		var r: Rect2 = PropIso.desenho(quadros[sexo]["guincho"][0])
		var pes := Vector2(r.get_center().x, r.end.y - 1.0) + no_trab - no_pier
		var chao := _d39_desenho_a_volta(pier_n1, pes, 2)
		_confere("D39: %s no guincho pisa o tabuado (%.0f%% de píer sob os pés)"
				% [sexo, chao * 100.0], chao >= D39_CASCO_MIN)

	# 5 ── a doca montada
	_d39_na_doca(GS, DockS, Ret, k)
	_d39_completo = true


# Fração mínima de desenho à volta de um ponto para dizer que ele CAI em cima
# de um prop — a régua do D17, e não a caixa, que um cabo estica de graça.
const D39_CASCO_MIN := 0.6
# A carga pousa na pilha: o fundo dela contra o topo da pilha, em coordenada.
# Medido no render a 02/10, com a pilha regerada como defeito: a certa dá
# dy 6,0; com um andar a menos (a carga a pairar) 4,0; com um a mais (a carga
# enterrada) 7,33. Cada pixel do PNG vale 0,67, e o corte fica no meio dos
# dois lados — um pixel de folga para o ruído de uma nova leva, e o defeito
# um pixel fora. O `dx` apanha a pilha fora do sítio do giro (com a pilha no
# quadro do trabalhador, como na `075`, dá 24); um andar só ele não vê.
const D39_PILHA_DX := 4.0
const D39_PILHA_DY_MIN := 5.0
const D39_PILHA_DY_MAX := 7.0


## O que um quadro do pau diz de si: o ângulo (0..6), se a carga vai
## pendurada e se o gancho está em baixo. Lido do NOME do quadro na tabela,
## que é a mesma chave que o ciclo usa.
func _d39_passo(chave: String) -> Dictionary:
	var baixo := chave.begins_with("barco") or chave.begins_with("pilha")
	var giro := 0
	if chave.begins_with("pilha"):
		giro = 6
	elif chave.begins_with("g"):
		giro = int(chave.substr(1, 1))
	return {"giro": giro, "baixo": baixo, "carga": chave.ends_with("c")}


## O desenho da LINGADA num quadro do pau: o que o quadro com carga tem de
## opaco e o mesmo quadro sem carga não tem. Em coordenada de nó, relativo ao
## centro do quadro, como o `PropIso.desenho()`.
func _d39_carga(com: Texture2D, sem: Texture2D) -> Rect2:
	var a := PropIso.imagem(com)
	var b := PropIso.imagem(sem)
	var minimo := Vector2i(a.get_width(), a.get_height())
	var maximo := Vector2i(-1, -1)
	for y in range(a.get_height()):
		for x in range(a.get_width()):
			if a.get_pixel(x, y).a > 0.5 and b.get_pixel(x, y).a < 0.1:
				minimo = Vector2i(mini(minimo.x, x), mini(minimo.y, y))
				maximo = Vector2i(maxi(maximo.x, x), maxi(maximo.y, y))
	if maximo.x < 0:
		return Rect2()
	var e := PropIso.escala(com)
	return Rect2(Vector2(minimo) * e - Vector2(PropIso.MEIO, PropIso.MEIO),
		Vector2(maximo - minimo + Vector2i.ONE) * e)


## A fração de pixels opacos num quadrado de `raio` px de PNG em volta de um
## ponto dado em coordenada de nó.
func _d39_desenho_a_volta(tex: Texture2D, ponto: Vector2, raio: int) -> float:
	var img := PropIso.imagem(tex)
	var e := PropIso.escala(tex)
	var c := Vector2i(((ponto + Vector2(PropIso.MEIO, PropIso.MEIO)) / e).round())
	var cheios := 0
	var todos := 0
	for dy in range(-raio, raio + 1):
		for dx in range(-raio, raio + 1):
			var q := c + Vector2i(dx, dy)
			todos += 1
			if q.x >= 0 and q.y >= 0 and q.x < img.get_width() and q.y < img.get_height() \
					and img.get_pixelv(q).a > 0.5:
				cheios += 1
	return float(cheios) / float(todos)


func _d39_na_doca(GS: Node, DockS: Script, Ret: Script, k: Dictionary) -> void:
	GS.clear_save()
	GS._rng.seed = 20261002
	GS.new_game()
	if GS.phase == "rival_offer":
		GS.resolve_rival_offer(true)
	_confere("D39: a partida nova é de nível 1", int(GS.nivel_guindaste()) == 1)
	# Uma MULHER, porque o rosto 0 de omissão é homem e a pergunta 2 diz que
	# os dois chegam — aqui prova-se que o nó veste o sexo que o rosto diz.
	var mulher := -1
	for i in range((Ret.get_script_constant_map()["TRABALHADORES"] as Array).size()):
		if Ret.sexo_do_rosto(i) == "m":
			mulher = i
			break
	var w: Dictionary = GS.workers[0]
	w["rosto"] = mulher
	GS.docks[0]["worker_id"] = null
	GS.docks[0]["boat"] = GS._make_boat()
	GS.docks[0]["boat"]["rival"] = false

	var doca: Control = load("res://scenes/dock/Dock.tscn").instantiate()
	doca.setup(0)
	root.add_child(doca)
	var trab := doca.get_node("Trabalhador") as TextureRect
	var pilha := doca.get_node("Pilha") as TextureRect
	var no_lanca := doca.get_node("Lanca") as TextureRect
	var quadros: Dictionary = k["QUADROS_TRABALHADOR"]
	var lanca: Dictionary = k["LANCA_N1"]
	var arte_lanca: Array = k["ArteLanca"]
	# Arte das três estruturas prontas; o avanço real e seus prazos estão
	# em T14/T15. Montar aqui preserva o barco do ensaio de animação.
	GS.cash = GS.START_CASH * 25
	load("res://tools/estado_da_bancada.gd").instalar(GS, "pier_2")
	_confere("D39: segundo píer montado", GS.tem_estrutura("pier_2"))
	GS.turn = 8
	load("res://tools/estado_da_bancada.gd").instalar(GS, "armazem")
	_confere("D39: armazém montado", GS.tem_estrutura("armazem"))
	GS.turn = 29
	GS.parcela_indice = 1
	GS.parcelas_quitadas = 1
	load("res://tools/estado_da_bancada.gd").instalar(GS, "patio")
	_confere("D39: pátio montado", GS.tem_estrutura("patio"))
	doca.refresh()
	_confere("D39: reparos mantêm a lança e sua base de madeira, com dois píeres",
		GS.nivel_guindaste() == 1 and GS.docks.size() == 2
			and doca.get_node("Pier").texture == (k["ArtePier"] as Array)[0]
			and no_lanca.texture == arte_lanca[0])
	var do_pau := {}
	for chave in lanca:
		do_pau[lanca[chave]] = chave
	var dela := {}
	for tex in quadros["m"]["guincho"]:
		dela[tex] = true

	# A alocação pela porta do jogo. O tween lê-se no NÓ (`_tw_trabalho`):
	# o `refresh()` rearma também outros, e a alocação faz o `Main` refrescar
	# as docas dele.
	GS.assign_worker(int(w["id"]), 0, false)
	doca.refresh()
	var tw0 = doca.get("_tw_trabalho")
	var tem_tween: bool = tw0 is Tween and (tw0 as Tween).is_valid()
	var barco: Dictionary = GS.docks[0]["boat"]
	_confere("D39: alocada com o barco no berço, o pau trabalha já com progress %d"
			% int(barco["progress"]),
		int(barco["progress"]) == 0 and tem_tween and pilha.visible,
		"tween %s, pilha %s" % [tem_tween, pilha.visible])
	_confere("D39: a pilha é a do barco",
		pilha.texture == k["PILHAS_N1"][String(barco["classe"])][String(barco["motivo"])])
	var varre = doca.get("_tw_lanca")
	_confere("D39: a imagem do pau não gira por cima dos quadros",
		no_lanca.rotation == 0.0 and not (varre is Tween and (varre as Tween).is_valid()))

	# Anda o ciclo inteiro pelo tween, lendo o NÓ a cada passo.
	var pau_visto := {}
	var operador_visto := {}
	var fora_dela := 0
	var rodou := 0
	if tem_tween:
		var tw: Tween = tw0
		var passos := int(ceil(float(DockS.duracao_do_ciclo()) * 30.0)) + 2
		for i in range(passos):
			tw.custom_step(1.0 / 30.0)
			if do_pau.has(no_lanca.texture):
				pau_visto[do_pau[no_lanca.texture]] = true
			if not dela.has(trab.texture):
				fora_dela += 1
			operador_visto[trab.texture] = true
			if no_lanca.rotation != 0.0:
				rodou += 1
			# A meio do giro: o `refresh()` do turno seguinte não o recomeça.
			if i == 30:
				var antes := no_lanca.texture
				doca.refresh()
				_confere("D39: um refresh a meio não recomeça o ciclo nem repõe o pau",
					doca.get("_tw_trabalho") == tw0 and no_lanca.texture == antes
						and antes != arte_lanca[0],
					"o pau estava em %s e ficou em %s"
						% [do_pau.get(antes, "?"), do_pau.get(no_lanca.texture, "?")])
	_confere("D39: os %d quadros do pau passam pelo nó (%d)" % [lanca.size(), pau_visto.size()],
		pau_visto.size() == lanca.size())
	_confere("D39: todo quadro do operador é dela (%d fora)" % fora_dela, fora_dela == 0)
	# A alavanca MEXE no nó: a parte 2 prova que os dois quadros diferem, e
	# só esta prova que o ciclo passa pelos dois — com o operador preso a um
	# quadro, todas as outras desta doca passavam (medido, 02/10).
	_confere("D39: a alavanca dela mexe na doca (%d quadros)" % operador_visto.size(),
		operador_visto.size() == 2)
	_confere("D39: o pau não gira enquanto trabalha (%d passos girados)" % rodou, rodou == 0)

	# Nível 3: o pórtico descarrega e ela vai na EMPILHADEIRA (`079`) — quem
	# o pergunta todo é o D42. Aqui só que o pau do n1 não fica a trabalhar
	# por cima, que o nó dela sai do tabuado e que é ela quem conduz.
	var estruturas_antes: Array = GS.estruturas.duplicate()
	GS.estruturas = ["armazem", "patio", "guindaste"]
	doca.refresh()
	varre = doca.get("_tw_lanca")
	var emp := doca.get_node("Empilhadeira") as TextureRect
	var dela_ao_volante: Array = (k["QUADROS_EMPILHADEIRA"]["m"] as Dictionary).values()
	_confere("D39: no nível %d ela vai na empilhadeira, e o pau do n1 sai" % int(GS.nivel_guindaste()),
		int(GS.nivel_guindaste()) == 3 and not (k["LANCA_N1"] as Dictionary).values().has(no_lanca.texture)
			and not (varre is Tween and (varre as Tween).is_valid())
			and not trab.visible and emp.visible and dela_ao_volante.has(emp.texture))
	GS.estruturas = estruturas_antes

	# Sem trabalhador: a pilha sai, e o pau volta ao repouso a varrer. Desde a
	# `083` a porta do jogador é DEVOLVER o barco ao largo, e o trabalhador
	# sai com ele.
	doca.refresh()
	GS.fila = []
	GS.desatracar(0)
	doca.refresh()
	varre = doca.get("_tw_lanca")
	_confere("D39: devolvido o barco, a pilha sai e o pau volta a varrer em repouso",
		not trab.visible and not pilha.visible and no_lanca.texture == arte_lanca[0]
			and varre is Tween and (varre as Tween).is_valid())
	doca.queue_free()


# ── D40 ── o guindaste do nível 2 que descarrega (02/10, `docs/decisoes/077`)
#
# No porto de nível 2 o guindaste tira a lingada do barco e pousa-a numa
# pilha no tabuado, e o trabalhador desengata-a; só no PRIMEIRO turno do
# serviço — depois o guindaste pára. A carga pendurada é um PNG à parte, um
# por tipo e por passo. Quatro perguntas:
#
#   1. TODO PAR (classe, motivo) que o nível 2 recebe tem tipo de carga, e o
#      tipo tem lança nas duas pontas, as nove lingadas e a pilha. A lista sai
#      das CLASSES do `GameState`; e nenhum tipo das tabelas fica sem par —
#      arte gerada e por ver é a forma do `barco_medio`.
#   2. O CICLO: a carga só existe onde a lança está (nunca pendurada noutro
#      ângulo), ele solta o gancho só na pilha, e todo quadro passa.
#   3. NO RENDER: a lingada desce dentro de cada casco do seu tipo e pousa em
#      cima da pilha do seu tipo; ele pisa o tabuado e não tapa a pilha.
#   4. NA DOCA MONTADA, com uma MULHER e um cargueiro de granel: com
#      `progress` 0 o guindaste trabalha e todo quadro passa pelo nó, ela
#      fica por cima da carga na ordem dos nós, um `refresh()` não recomeça
#      o ciclo; com `progress` 1 o guindaste varre em repouso, a pilha fica e
#      ela espera; liberada, a pilha sai e a ordem da cena volta.
#   5. A IDA AO CAMIÃO, na cena inteira: o camião encostado pelo próprio
#      `Main` avisa a doca, e ela leva a carga ao ombro só na ida, anda no
#      eixo em que os quadros olham, e os pés dela acabam ENCOSTADOS às
#      portas de trás do camião, que encosta de ré — junto ao desenho dele, e
#      não dentro.
#   6. NENHUM PROP DO CENÁRIO QUE LHE FIQUE À FRENTE é tapado por ele, ao
#      longo do caminho, nas três docas e com os prédios em ruína e prontos.
#      As docas desenham-se DEPOIS do cenário: o que lá está à frente dele
#      não o pode tapar, e se o caminho passa por trás de um prédio ele sai
#      pintado por cima do prédio. Foi o que o Bruno viu na doca 2, com o
#      corredor entre o camião e o armazém (03/10).
var _d40_completo := false

# A lingada pousa na pilha: o fundo dela contra o topo da pilha, por tipo,
# em coordenada. Medido nos PNGs a 03/10 (o centro), e cada faixa é o centro
# ± meio andar do tipo: a lingada deslocada um andar — o que ela faz se a
# conta do gancho e a da pilha divergirem — cai fora. Medido com a
# translação de um andar, que numa câmara ortográfica é o mesmo render: peixe
# 4,95 / 8,38, papelão 4,21 / 7,79, saco 5,32 / 8,01, contêiner 3,18 / 20,82.
# O saco é o mais justo (um pixel de PNG de folga de cada lado), porque o
# andar dele tem 1,34.
const D40_PILHA_DY := {
	"peixe": [5.8, 7.5], "caixa": [5.1, 6.9], "saco": [6.0, 7.3],
	"conteiner": [7.6, 16.4],
}
const D40_PILHA_DX := 4.0
# Quanto da pilha ele pode tapar, em fração dos pixels dela. Medido a 03/10:
# à frente dela, como na primeira versão, tapava 43% a 49% das de caixas — e a
# de papelão desaparecia atrás dele na captura; ao lado, como está, tapa 4% a
# 10% delas e 13% a 14% do contêiner. O corte fica entre as duas.
const D40_TAPA_MAX := 0.25


func _d40_guindaste_n2() -> void:
	var GS: Node = root.get_node("GameState")
	var DockS: Script = load("res://scripts/Dock.gd")
	var Ret: Script = load("res://scripts/Retratos.gd")
	var k: Dictionary = DockS.get_script_constant_map()
	var servico: Dictionary = k["CARGA_DO_SERVICO"]
	var lanca: Dictionary = k["LANCA_N2"]
	var pontas: Dictionary = k["PONTAS_N2"]
	var lingadas: Dictionary = k["LINGADAS_N2"]
	var pilhas: Dictionary = k["PILHAS_N2"]
	var quadros: Dictionary = k["QUADROS_TRABALHADOR"]
	var lugares := ["barco", "g0", "g1", "g2", "g3", "g4", "g5", "g6", "pilha"]

	# 1 ── a tabela contra as classes que o nível 2 recebe
	var exigidas := 0
	var tipos_usados := {}
	for classe in GS.CLASSES_DE_NAVIO:
		var dados: Dictionary = GS.CLASSES_DE_NAVIO[classe]
		if int(dados["nivel"]) > 2:
			continue
		for motivo in dados["motivos"]:
			if int(dados["motivos"][motivo]) <= 0:
				continue
			exigidas += 1
			var tem: bool = servico.has(classe) \
				and (servico[classe] as Dictionary).has(motivo)
			_confere("D40: %s · %s tem tipo de carga no nível 2" % [classe, motivo],
				tem, "o guindaste rebentaria no `refresh()` ao receber este barco")
			if not tem:
				continue
			var tipo: String = servico[classe][motivo]
			tipos_usados[tipo] = true
			var completo: bool = pontas.has(tipo) and pilhas.has(tipo) \
				and pilhas[tipo] is Texture2D and lingadas.has(tipo)
			if completo:
				for ponta in ["barco", "pilha"]:
					completo = completo and pontas[tipo].has(ponta) \
						and pontas[tipo][ponta] is Texture2D
				for lugar in lugares:
					completo = completo and lingadas[tipo].has(lugar) \
						and lingadas[tipo][lugar] is Texture2D
			_confere("D40: o tipo «%s» tem as pontas, as nove lingadas e a pilha" % tipo,
				completo)
	_confere("D40: o nível 2 recebe pares (%d)" % exigidas, exigidas > 0)
	var tabelas := {"PONTAS_N2": pontas, "LINGADAS_N2": lingadas, "PILHAS_N2": pilhas}
	for nome in tabelas:
		var sobra: Array = []
		for tipo in tabelas[nome]:
			if not tipos_usados.has(tipo):
				sobra.append(tipo)
		_confere("D40: nenhum tipo da %s fica sem serviço (%s)" % [nome, sobra],
			sobra.is_empty())

	# 2 ── o ciclo, como aritmética
	var dt := 1.0 / 60.0
	var lancas_vistas := {}
	var cargas_vistas := {}
	var trab_visto := {}
	var carga_fora := 0
	var solta_fora := 0
	var t := 0.0
	while t < 2.0 * float(DockS.duracao_do_ciclo()):
		t += dt
		var p: Dictionary = DockS.pose_n2(t)
		lancas_vistas[p["lanca"]] = true
		trab_visto[int(p["trabalhador"])] = true
		if String(p["carga"]) != "":
			cargas_vistas[p["carga"]] = true
			if p["carga"] != p["lanca"]:
				carga_fora += 1
		if (int(p["trabalhador"]) == 1) != (p["lanca"] == "pilha"):
			solta_fora += 1
	_confere("D40: a carga só pende onde a lança está (%d fora)" % carga_fora,
		carga_fora == 0)
	_confere("D40: ele solta o gancho só na pilha (%d fora)" % solta_fora,
		solta_fora == 0)
	var faltam: Array = []
	for chave in lanca:
		if not lancas_vistas.has(chave):
			faltam.append(chave)
	for lugar in lugares:
		if not cargas_vistas.has(lugar):
			faltam.append("carga " + lugar)
		if lugar in ["barco", "pilha"] and not lancas_vistas.has(lugar):
			faltam.append("lança " + lugar)
	_confere("D40: todo quadro da lança e da carga passa no ciclo", faltam.is_empty(),
		"nunca aparecem: %s" % [faltam])
	_confere("D40: ele espera e solta (%s)" % [trab_visto.keys()], trab_visto.size() == 2)

	# 3 ── no render
	var doca: Control = load("res://scenes/dock/Dock.tscn").instantiate()
	var no_pier := (doca.get_node("Pier") as Control).position
	var no_barco := (doca.get_node("Barco") as Control).position
	var no_trab := (doca.get_node("Trabalhador") as Control).position
	var no_pilha := (doca.get_node("Pilha") as Control).position
	var no_carga := (doca.get_node("Carga") as Control).position
	doca.free()
	var cascos: Dictionary = k["CASCOS"]
	var cascos_vistos := 0
	for classe in servico:
		for motivo in servico[classe]:
			var tipo: String = servico[classe][motivo]
			# ⚠️ PELO FUNDO DA LINGADA, onde ela toca o convés, e não pelo
			# centro da caixa: as cintas sobem até ao gancho e puxam o centro
			# para o ar — medido a 03/10, o centro dava 41% de casco à volta no
			# de carga geral e 53% no bote, com a carga bem pousada; o fundo dá
			# 100% nos seis.
			var carga: Rect2 = PropIso.desenho(lingadas[tipo]["barco"])
			var ponto: Vector2 = Vector2(carga.get_center().x, carga.end.y - 1.5) \
				+ no_carga - no_barco
			for casco in cascos[classe][motivo]:
				cascos_vistos += 1
				var cheio := _d39_desenho_a_volta(casco, ponto, 3)
				_confere("D40: a lingada de %s desce dentro do %s (%s, %.0f%% de casco à volta)"
						% [tipo, String(casco.resource_path).get_file().get_basename(),
						   motivo, cheio * 100.0],
					cheio >= D39_CASCO_MIN, "ela desce na água ao lado dele")
	_confere("D40: percorreu os cascos do nível 2 (%d)" % cascos_vistos, cascos_vistos > 0)

	for tipo in pilhas:
		var na_pilha: Rect2 = PropIso.desenho(lingadas[tipo]["pilha"])
		na_pilha.position += no_carga - no_pilha
		var pilha: Rect2 = PropIso.desenho(pilhas[tipo])
		var dy := na_pilha.end.y - pilha.position.y
		var dx := na_pilha.get_center().x - pilha.get_center().x
		var faixa: Array = D40_PILHA_DY[tipo]
		_confere("D40: %s — a lingada pousa em cima da pilha (dx %.1f, dy %.2f, faixa %s)"
				% [tipo, dx, dy, faixa],
			absf(dx) <= D40_PILHA_DX and dy >= float(faixa[0]) and dy <= float(faixa[1]),
			"o fundo da carga tem de cair no topo da pilha do mesmo tipo")

	var pier_n2: Texture2D = (k["ArtePier"] as Array)[1]
	for sexo in ["h", "m"]:
		_confere("D40: %s — os braços mexem entre esperar e soltar" % sexo,
			PropIso.imagem(quadros[sexo]["pilha"][0]).get_data() \
				!= PropIso.imagem(quadros[sexo]["pilha"][1]).get_data())
		for q in range(2):
			var tex: Texture2D = quadros[sexo]["pilha"][q]
			var r: Rect2 = PropIso.desenho(tex)
			var pes := Vector2(r.get_center().x, r.end.y - 1.0) + no_trab - no_pier
			var chao := _d39_desenho_a_volta(pier_n2, pes, 2)
			_confere("D40: %s ao pé da pilha (%d) pisa o tabuado (%.0f%% de píer sob os pés)"
					% [sexo, q, chao * 100.0], chao >= D39_CASCO_MIN)
			for tipo in pilhas:
				var tapa := _d40_tapa(tex, no_trab, pilhas[tipo], no_pilha)
				_confere("D40: %s (%d) não tapa a pilha de %s (%.0f%%)"
						% [sexo, q, tipo, tapa * 100.0], tapa <= D40_TAPA_MAX)
	_confere("D40: a figura dela ao pé da pilha não é a dele",
		PropIso.imagem(quadros["h"]["pilha"][1]).get_data() \
			!= PropIso.imagem(quadros["m"]["pilha"][1]).get_data())

	# 4 ── a doca montada
	_d40_na_doca(GS, DockS, Ret, k)
	_d40_ida_ao_camiao(GS, DockS, k)
	_d40_ninguem_a_frente(GS, DockS, k)
	_d40_completo = true


## A fração dos pixels opacos da pilha que a figura tapa, com cada uma no
## sítio do seu nó.
func _d40_tapa(figura: Texture2D, no_fig: Vector2, pilha: Texture2D,
		no_pil: Vector2) -> float:
	var a := PropIso.imagem(figura)
	var b := PropIso.imagem(pilha)
	var e := PropIso.escala(pilha)
	var desloc := Vector2i(((no_fig - no_pil) / e).round())
	var total := 0
	var tapados := 0
	var r := b.get_used_rect()
	for y in range(r.position.y, r.end.y):
		for x in range(r.position.x, r.end.x):
			if b.get_pixel(x, y).a < 0.5:
				continue
			total += 1
			var q := Vector2i(x, y) - desloc
			if q.x >= 0 and q.y >= 0 and q.x < a.get_width() and q.y < a.get_height() \
					and a.get_pixelv(q).a > 0.5:
				tapados += 1
	return float(tapados) / float(maxi(total, 1))


func _d40_na_doca(GS: Node, DockS: Script, Ret: Script, k: Dictionary) -> void:
	GS.clear_save()
	GS._rng.seed = 20261003
	GS.new_game()
	if GS.phase == "rival_offer":
		GS.resolve_rival_offer(true)
	var estruturas_antes: Array = GS.estruturas.duplicate()
	GS.estruturas = ["armazem", "patio"]
	load("res://tools/estado_da_bancada.gd").guindaste_intermediario(GS)
	_confere("D40: a bancada monta o guindaste intermediário da Fase 2",
		int(GS.nivel_guindaste()) == 2)
	var mulher := -1
	for i in range((Ret.get_script_constant_map()["TRABALHADORES"] as Array).size()):
		if Ret.sexo_do_rosto(i) == "m":
			mulher = i
			break
	var w: Dictionary = GS.workers[0]
	w["rosto"] = mulher
	GS.docks[0]["worker_id"] = null
	var barco: Dictionary = GS._make_boat()
	barco["classe"] = "medio"
	barco["motivo"] = "granel"
	barco["rival"] = false
	barco["progress"] = 0
	GS.docks[0]["boat"] = barco

	var doca: Control = load("res://scenes/dock/Dock.tscn").instantiate()
	doca.setup(0)
	root.add_child(doca)
	var trab := doca.get_node("Trabalhador") as TextureRect
	var pilha := doca.get_node("Pilha") as TextureRect
	var carga := doca.get_node("Carga") as TextureRect
	var no_lanca := doca.get_node("Lanca") as TextureRect
	var quadros: Dictionary = k["QUADROS_TRABALHADOR"]
	var arte_lanca: Array = k["ArteLanca"]
	var tipo: String = k["CARGA_DO_SERVICO"]["medio"]["granel"]
	var da_lanca := {}
	for chave in k["LANCA_N2"]:
		da_lanca[k["LANCA_N2"][chave]] = chave
	for ponta in k["PONTAS_N2"][tipo]:
		da_lanca[k["PONTAS_N2"][tipo][ponta]] = ponta
	var da_carga := {}
	for lugar in k["LINGADAS_N2"][tipo]:
		da_carga[k["LINGADAS_N2"][tipo][lugar]] = lugar
	var dela := {}
	for tex in quadros["m"]["pilha"]:
		dela[tex] = true

	GS.assign_worker(int(w["id"]), 0, false)
	doca.refresh()
	var tw0 = doca.get("_tw_trabalho")
	var tem_tween: bool = tw0 is Tween and (tw0 as Tween).is_valid()
	_confere("D40: alocada no primeiro turno do serviço, o guindaste trabalha",
		int(barco["progress"]) == 0 and tem_tween and pilha.visible)
	_confere("D40: a pilha é a do tipo do barco (%s)" % tipo,
		pilha.texture == k["PILHAS_N2"][tipo])
	_confere("D40: ela fica por cima da carga na ordem dos nós",
		trab.get_index() > carga.get_index() and trab.get_index() < no_lanca.get_index())
	var varre = doca.get("_tw_lanca")
	_confere("D40: a imagem da lança não gira por cima dos quadros",
		no_lanca.rotation == 0.0 and not (varre is Tween and (varre as Tween).is_valid()))

	var lanca_vista := {}
	var carga_vista := {}
	var trab_visto := {}
	var fora_dela := 0
	var carga_sem_lanca := 0
	if tem_tween:
		var tw: Tween = tw0
		var passos := int(ceil(float(DockS.duracao_do_ciclo()) * 30.0)) + 2
		for i in range(passos):
			tw.custom_step(1.0 / 30.0)
			if da_lanca.has(no_lanca.texture):
				lanca_vista[da_lanca[no_lanca.texture]] = true
			if carga.visible:
				var lugar: String = da_carga.get(carga.texture, "?")
				carga_vista[lugar] = true
				if da_lanca.get(no_lanca.texture, "") != lugar:
					carga_sem_lanca += 1
			if not dela.has(trab.texture):
				fora_dela += 1
			trab_visto[trab.texture] = true
			if i == 30:
				var antes := no_lanca.texture
				doca.refresh()
				_confere("D40: um refresh a meio não recomeça o ciclo nem repõe a lança",
					doca.get("_tw_trabalho") == tw0 and no_lanca.texture == antes
						and antes != arte_lanca[1],
					"a lança estava em %s e ficou em %s"
						% [da_lanca.get(antes, "?"), da_lanca.get(no_lanca.texture, "?")])
	var n_lanca: int = (k["LANCA_N2"] as Dictionary).size() + 2
	_confere("D40: os %d quadros da lança passam pelo nó (%d)" % [n_lanca, lanca_vista.size()],
		lanca_vista.size() == n_lanca)
	_confere("D40: as nove lingadas passam pelo nó Carga (%d)" % carga_vista.size(),
		carga_vista.size() == 9 and not carga_vista.has("?"))
	_confere("D40: a carga pende sempre da lança do mesmo passo (%d fora)" % carga_sem_lanca,
		carga_sem_lanca == 0)
	_confere("D40: todo quadro de quem desengata é dela (%d fora)" % fora_dela, fora_dela == 0)
	_confere("D40: ela espera e solta na doca (%d quadros)" % trab_visto.size(),
		trab_visto.size() == 2)

	# O segundo turno do serviço: o guindaste pára e a pilha fica. Sem camião
	# no berço ela espera à frente da pilha, de frente — o sítio de onde parte
	# a ida, porque o saco vai ao ombro.
	barco["progress"] = 1
	doca.refresh()
	varre = doca.get("_tw_lanca")
	var tw1 = doca.get("_tw_trabalho")
	_confere("D40: no segundo turno a lança varre em repouso, a pilha fica e ela espera",
		no_lanca.texture == arte_lanca[1] and varre is Tween and (varre as Tween).is_valid()
			and not (tw1 is Tween and (tw1 as Tween).is_valid())
			and pilha.visible and not carga.visible and trab.visible
			and trab.texture == quadros["m"]["volta"][1])

	# O serviço acaba: o barco parte e ela fica livre — a meio dele o jogo
	# recusa libertá-la (`desatracar` com `progress` > 0), e a pilha tem de
	# sair pelo caminho por onde ela sai de verdade.
	GS.docks[0]["worker_id"] = null
	GS.docks[0]["boat"] = null
	doca.refresh()
	_confere("D40: acabado o serviço, a pilha e a carga saem e a ordem da cena volta",
		not trab.visible and not pilha.visible and not carga.visible
			and trab.get_index() == pilha.get_index() + 1,
		"trabalhador %s, pilha %s, carga %s, índices %d/%d"
			% [trab.visible, pilha.visible, carga.visible, trab.get_index(),
			   pilha.get_index()])
	doca.queue_free()
	GS.estruturas = estruturas_antes


# A ida ao camião: os pés no fim do caminho contra o desenho do camião
# encostado, pela fração de desenho dele num quadrado de `D40_ENTREGA_RAIO`
# px de PNG à volta dos pés. Medido a 03/10, às portas de trás: 9% (7% com
# as portas no eixo); e a entrega no flanco, varrida ao longo dele, dava 9% a
# 5% encostada e ZERO a uma pessoa de distância. O corte fica abaixo do pior
# dos bons.
const D40_ENTREGA_RAIO := 6
const D40_ENTREGA_MIN := 0.03
# O caminho anda no eixo em que os quadros olham (`−mx`), com esta folga.
const D40_EIXO_MAX_GRAUS := 15.0


func _d40_ida_ao_camiao(GS: Node, DockS: Script, k: Dictionary) -> void:
	if GS.phase == "rival_offer":
		GS.resolve_rival_offer(true)
	var tweens_antes := {}
	for tw in get_processed_tweens():
		tweens_antes[tw] = true
	var estruturas_antes: Array = GS.estruturas.duplicate()
	GS.estruturas = ["armazem", "patio"]
	load("res://tools/estado_da_bancada.gd").guindaste_intermediario(GS)
	var tela: Control = load(CENA).instantiate()
	root.add_child(tela)
	var consts: Dictionary = tela.get_script().get_script_constant_map()
	var acessos: Array = consts["ACESSOS_DOCA"]
	while GS.docks.size() < acessos.size():
		GS.docks.append({"boat": null, "worker_id": null})
	for d in GS.docks:
		d["boat"] = null
		d["worker_id"] = null
	# Um cargueiro de carga geral no segundo turno do serviço, na doca 0.
	var barco: Dictionary = GS._make_boat()
	barco["classe"] = "medio"
	barco["motivo"] = "armazenagem"
	barco["rival"] = false
	barco["progress"] = 1
	GS.docks[0]["boat"] = barco
	GS.docks[0]["worker_id"] = int(GS.workers[0]["id"])
	tela.call("_refresh_all")
	for tw in get_processed_tweens():
		if not tweens_antes.has(tw):
			tw.kill()
	var doca: Control = tela.get_node("MapaWrap/Docas/Doca0")
	var trab := doca.get_node("Trabalhador") as TextureRect
	var ombro := doca.get_node("Trabalhador/Ombro") as TextureRect
	_confere("D40: sem camião no berço ela espera, sem carga",
		doca.get("_camiao") == null and trab.visible and not ombro.visible
			and not (doca.get("_tw_trabalho") is Tween
				and (doca.get("_tw_trabalho") as Tween).is_valid()))

	# O camião encosta pelo `Main`: posto onde o `_percorrer_de()` o pousa no
	# fim do acesso — a base e a origem do nó, pela `tela_da_rota()` dele — e
	# avisado pelo `_encostou()`, como no fim de uma manobra.
	var cenario := tela.get_node("MapaWrap/Cenario")
	var caminhao := cenario.get_node("Caminhao0") as TextureRect
	var base: Vector2 = (tela.get("_base_do_caminhao") as Array)[0]
	var origem: Vector2 = (consts["CAMINHAO_ORIGENS"] as Array)[0]
	var paragem: Vector2 = acessos[0]["paragem"]
	caminhao.position = base + tela.tela_da_rota(paragem, origem)
	caminhao.texture = consts["CAMINHOES"]["armazenagem"][0]["mx_retorno"]
	(tela.get("_ocupante_do_berco") as Array)[0] = caminhao
	tela.call("_encostou", 0, int(barco["id"]))
	var tw0 = doca.get("_tw_trabalho")
	var anda: bool = tw0 is Tween and (tw0 as Tween).is_valid()
	_confere("D40: com o camião encostado a doca sabe dele e ela anda",
		doca.get("_camiao") != null and anda)

	var caminho: Vector2 = doca.get("_caminho_ida")
	var eixo := Vector2(-2.0, -1.0).normalized()   # `−mx` na tela
	# O EIXO PERGUNTA-SE A CADA CAMIÃO QUE LEVA CARGA AO OMBRO: as portas de
	# trás saem do desenho dele, e a traseira vai de 0,60 a 0,76 da âncora
	# conforme o serviço e a empresa — o caminho muda de ângulo com ela.
	var pior_graus := 0.0
	var qual_graus := ""
	for motivo in ["armazenagem", "granel"]:
		for e in range((consts["CAMINHOES"][motivo] as Array).size()):
			caminhao.texture = consts["CAMINHOES"][motivo][e]["mx_retorno"]
			doca.camiao_no_berco(tela.portas_do_camiao(caminhao) - doca.global_position)
			var c: Vector2 = doca.get("_caminho_ida")
			var g := rad_to_deg(absf(c.normalized().angle_to(eixo)))
			if g > pior_graus:
				pior_graus = g
				qual_graus = "%s, empresa %d, %.0f px" % [motivo, e, c.length()]
	caminhao.texture = consts["CAMINHOES"]["armazenagem"][0]["mx_retorno"]
	doca.camiao_no_berco(tela.portas_do_camiao(caminhao) - doca.global_position)
	tw0 = doca.get("_tw_trabalho")
	anda = tw0 is Tween and (tw0 as Tween).is_valid()
	caminho = doca.get("_caminho_ida")
	_confere("D40: o caminho anda no eixo dos quadros com os quatro camiões (pior %.1f° de −mx: %s)"
			% [pior_graus, qual_graus],
		pior_graus <= D40_EIXO_MAX_GRAUS and caminho.length() > 20.0)

	# Os pés no fim do caminho, contra o desenho do camião.
	var quadros: Dictionary = k["QUADROS_TRABALHADOR"]
	var sexo: String = DockS.sexo_do_trabalhador(int(GS.workers[0]["id"]))
	var r := PropIso.desenho(quadros[sexo]["leva"][1])
	var pes: Vector2 = trab.position + Vector2(PropIso.MEIO, PropIso.MEIO) \
		+ Vector2(r.get_center().x, r.end.y) + caminho
	var pes_no_mapa := pes + doca.position
	var centro_cam := caminhao.position + caminhao.size / 2.0
	var junto := _d39_desenho_a_volta(caminhao.texture, pes_no_mapa - centro_cam,
		D40_ENTREGA_RAIO)
	var dentro := _d39_desenho_a_volta(caminhao.texture, pes_no_mapa - centro_cam, 0)
	_confere("D40: os pés acabam encostados ao camião (%.0f%% de camião à volta, %.0f%% sob eles)"
			% [junto * 100.0, dentro * 100.0],
		junto >= D40_ENTREGA_MIN and dentro == 0.0,
		"o ponto de entrega tem de cair ao lado da carroçaria")

	# Anda o ciclo pelo tween, lendo o NÓ: a carga só vai na ida, e o quadro
	# olha para o lado para onde ele anda.
	var carga_fora := 0
	var sentido_fora := 0
	var vistos := {}
	if anda:
		var tw: Tween = tw0
		var antes := trab.position
		var levava := true
		var leva := {}
		for tex in quadros[sexo]["leva"]:
			leva[tex] = true
		var passos := int(ceil(float(DockS.duracao_da_ida(doca.get("_trecho_ida"))) * 30.0)) + 2
		for i in range(passos):
			tw.custom_step(1.0 / 30.0)
			var a_levar: bool = leva.has(trab.texture)
			vistos[trab.texture] = true
			if ombro.visible != a_levar:
				carga_fora += 1
			# O passo que atravessa a troca de sentido anda num e mostra o
			# outro (a volta acaba e a ida seguinte começa no mesmo passo de
			# 1/30 s): esse não diz nada sobre o quadro.
			var passo := trab.position - antes
			if passo.length() > 0.01 and a_levar == levava \
					and (passo.dot(caminho) > 0.0) != a_levar:
				sentido_fora += 1
			antes = trab.position
			levava = a_levar
	_confere("D40: a carga vai ao ombro só na ida (%d fora)" % carga_fora, carga_fora == 0)
	_confere("D40: o quadro olha para onde ele anda (%d fora)" % sentido_fora,
		sentido_fora == 0)
	_confere("D40: os seis quadros da ida passam pelo nó (%d)" % vistos.size(),
		vistos.size() == 6)

	# O camião larga: a doca sabe, e ela volta a esperar à frente da pilha.
	GS.docks[0]["boat"] = null
	GS.docks[0]["worker_id"] = null
	tela.call("_refresh_all")
	_confere("D40: o camião largou, e a doca deixou de o ter",
		doca.get("_camiao") == null)
	tela.queue_free()
	GS.estruturas = estruturas_antes


# Quantos pixels dele (em PNG de prop) podem cair por cima do desenho de um
# prop que lhe está à frente. Zero, e é um defeito que só vive numa doca: a
# entrega a meio da carroçaria pintava 117 px do armazém na doca 2 e nenhum
# nas outras duas (medido a 03/10, com os prédios em ruína e prontos).
const D40_A_FRENTE_MAX := 0


func _d40_ninguem_a_frente(GS: Node, DockS: Script, k: Dictionary) -> void:
	if GS.phase == "rival_offer":
		GS.resolve_rival_offer(true)
	var tweens_antes := {}
	for tw in get_processed_tweens():
		tweens_antes[tw] = true
	var estruturas_antes: Array = GS.estruturas.duplicate()
	var tela: Control = load(CENA).instantiate()
	root.add_child(tela)
	var consts: Dictionary = tela.get_script().get_script_constant_map()
	var acessos: Array = consts["ACESSOS_DOCA"]
	var cenario := tela.get_node("MapaWrap/Cenario")
	var quadros: Dictionary = k["QUADROS_TRABALHADOR"]
	var estados := [["armazem", "patio"], ["escritorio", "patio"]]
	var pior := 0
	var onde := ""
	var docas_vistas := 0
	for estado in estados:
		GS.estruturas = estado
		while GS.docks.size() < acessos.size():
			GS.docks.append({"boat": null, "worker_id": null})
		for d in range(acessos.size()):
			for dd in GS.docks:
				dd["boat"] = null
				dd["worker_id"] = null
			var barco: Dictionary = GS._make_boat()
			barco["classe"] = "medio"
			barco["motivo"] = "armazenagem"
			barco["rival"] = false
			barco["progress"] = 1
			GS.docks[d]["boat"] = barco
			GS.docks[d]["worker_id"] = int(GS.workers[0]["id"])
			tela.call("_refresh_all")
			for tw in get_processed_tweens():
				if not tweens_antes.has(tw):
					tw.kill()
			var caminhao := cenario.get_node("Caminhao0") as TextureRect
			var base: Vector2 = (tela.get("_base_do_caminhao") as Array)[0]
			var origem: Vector2 = (consts["CAMINHAO_ORIGENS"] as Array)[0]
			caminhao.position = base + tela.tela_da_rota(acessos[d]["paragem"], origem)
			caminhao.texture = consts["CAMINHOES"]["armazenagem"][0]["mx_retorno"]
			(tela.get("_ocupante_do_berco") as Array)[d] = caminhao
			tela.call("_encostou", d, int(barco["id"]))
			var doca: Control = tela.get_node("MapaWrap/Docas/Doca%d" % d)
			if doca.get("_camiao") == null:
				continue
			docas_vistas += 1
			var caminho: Vector2 = doca.get("_caminho_ida")
			var trab := doca.get_node("Trabalhador") as TextureRect
			var sexo: String = DockS.sexo_do_trabalhador(int(GS.workers[0]["id"]))
			var figura: Array = [quadros[sexo]["leva"][1], k["CARGAS_AO_OMBRO"]["caixa"]]
			for i in range(21):
				var canto: Vector2 = doca.position + trab.position + caminho * (float(i) / 20.0)
				var n := _d40_tapados(figura, canto, cenario, caminhao)
				if int(n[0]) > pior:
					pior = int(n[0])
					onde = "doca %d, %s, %d/20 do caminho: %s" % [d, estado[0], i, n[1]]
			(tela.get("_ocupante_do_berco") as Array)[d] = null
			(tela.get("_visita_do_berco") as Array)[d] = -1
	_confere("D40: percorreu as três docas nos dois estados (%d)" % docas_vistas,
		docas_vistas == 2 * acessos.size())
	_confere("D40: ele não se pinta por cima de prop do cenário que lhe está à frente (%d px; %s)"
			% [pior, onde if onde != "" else "nenhum"],
		pior <= D40_A_FRENTE_MAX,
		"as docas desenham-se por cima do cenário: ali ele aparece à frente do que o tapa")
	tela.queue_free()
	GS.estruturas = estruturas_antes
	for dd in GS.docks:
		dd["boat"] = null
		dd["worker_id"] = null


## Os pixels da figura (as texturas de `figura`, todas no mesmo quadro, com o
## canto em `canto` no mapa) que caem por cima do desenho de um prop do
## cenário que lhe está À FRENTE — a âncora dele mais abaixo na tela do que os
## pés dela. Devolve [pixels, o pior prop].
func _d40_tapados(figura: Array, canto: Vector2, cenario: Node, fora: Control) -> Array:
	var img0 := PropIso.imagem(figura[0])
	var e := PropIso.escala(figura[0])
	var usado := img0.get_used_rect()
	var pes_y := canto.y + float(usado.end.y) * e
	var imgs: Array = []
	for t in figura:
		imgs.append(PropIso.imagem(t))
	var pior := 0
	var qual := ""
	for no in cenario.get_children():
		if not (no is TextureRect) or no == fora or (no as TextureRect).texture == null:
			continue
		var tr := no as TextureRect
		if String(tr.name).begins_with("Caminhao"):
			continue
		var ancora_y := tr.position.y + tr.size.y / 2.0
		if ancora_y <= pes_y:
			continue
		var img := PropIso.imagem(tr.texture)
		var ep := PropIso.escala(tr.texture)
		var n := 0
		for y in range(usado.position.y, usado.end.y):
			for x in range(usado.position.x, usado.end.x):
				var meu := false
				for im in imgs:
					if (im as Image).get_pixel(x, y).a > 0.5:
						meu = true
						break
				if not meu:
					continue
				var p := canto + Vector2(x, y) * e - tr.position
				var q := Vector2i((p / ep).floor())
				if q.x >= 0 and q.y >= 0 and q.x < img.get_width() and q.y < img.get_height() \
						and img.get_pixelv(q).a > 0.5:
					n += 1
		if n > pior:
			pior = n
			qual = String(tr.name)
	return [pior, qual]


# ── D41 ── a virada do dia na tela (03/10, `docs/decisoes/078`)
#
# O `GameState` vira o dia de uma vez; a TELA alcança o estado novo devagar:
# o barco servido parte, o seguinte chega, o dinheiro conta e o que cada doca
# rendeu sobe do barco como «+R$». Escolha do Bruno, vista em dois GIFs. Seis
# perguntas, cada uma à procura de um defeito que as outras não veem:
#
#   1. O RUMO do barco é o do píer para o mar — conferido contra a PROJEÇÃO
#      publicada, e não contra a constante: o rumo da primeira versão
#      atravessava o tabuado, e uma pergunta à própria constante passaria.
#   2. A FILA: o barco velho sai do berço antes de o novo aparecer, e o novo
#      entra pelo mar e encosta; nenhum quadro volta atrás.
#   3. OPACO A MAIOR PARTE DO CAMINHO — «barco parece fantasma» foi o
#      primeiro veredito: só a ponta de fora esmaece.
#   4. A SOMA DOS «+R$» é a receita que o `GameState` lançou no dia — duas
#      fontes: o `Main` lê `receita_da_doca()` ANTES da virada, o jogo
#      escreve `dia_anterior` DURANTE ela. Com bónus de estrutura no meio,
#      para o valor bruto não passar por ela.
#   5. A PRIMEIRA VISTA NÃO ANIMA: o porto que se abre mostra os barcos onde
#      estão.
#   6. O TOQUE SEGUINTE ACABA A VIRADA antes de virar outro dia, e só o botão
#      arma a contagem: o dinheiro que muda por outra porta salta.
var _d41_completo := false

const D41_SEMENTE := 20261003
const D41_PASSO := 1.0 / 60.0
# A fração da partida em que o barco tem de estar OPACO. Medido no código
# aceite: 0,70 (só os últimos 30% esmaecem). O primeiro GIF esmaecia o caminho
# inteiro numa curva cúbica, e dava ~0,1. O corte fica no meio.
const D41_OPACO_MIN := 0.4


func _d41_virada_do_dia() -> void:
	var GS: Node = root.get_node("GameState")
	var DockS: Script = load("res://scripts/Dock.gd")
	var k: Dictionary = DockS.get_script_constant_map()
	GS.clear_save()
	GS._rng.seed = D41_SEMENTE
	GS.new_game()
	GS.definir_nomes(GS.NOME_PORTO_PADRAO, "")
	if GS.phase == "rival_offer":
		GS.resolve_rival_offer(true)
	# O porto completo, com o caixa da tabela de preços — como a captura.
	var custo: int = 0
	for e in GS.ESTRUTURAS:
		custo += int(GS.ESTRUTURAS[e]["custo"])
	GS.cash += custo
	var ids: Array = GS.ESTRUTURAS.keys()
	var tabela: Dictionary = GS.ESTRUTURAS
	ids.sort_custom(func(a, b): return int(tabela[a]["ordem"]) < int(tabela[b]["ordem"]))
	for e in ids:
		load("res://tools/estado_da_bancada.gd").instalar(GS, e)
	_confere("D41: o porto completo tem três docas e três trabalhadores",
		GS.docks.size() == 3 and GS.workers.size() >= 3,
		"%d docas, %d trabalhadores" % [GS.docks.size(), GS.workers.size()])
	if GS.docks.size() != 3 or GS.workers.size() < 3:
		return
	# Um barco em cada doca, no ÚLTIMO turno do serviço, com trabalhador:
	# a virada paga os três. Armazenagem, que tem o bónus do armazém.
	for i in range(3):
		GS.docks[i]["boat"] = _d41_barco(GS)
		GS.docks[i]["worker_id"] = null

	var tela: Control = load(CENA).instantiate()
	root.add_child(tela)
	var docas: Array = tela.get_node("MapaWrap/Docas").get_children()
	var ganhos: Control = tela.get_node("MapaWrap/Ganhos")

	# 5 ── a primeira vista não anima. ⚠️ COM OS BARCOS SEM TRABALHADOR: quem
	# aloca a meio da chegada encosta o barco já (`concluir_troca()`), e com
	# os trabalhadores alocados antes de abrir era ESSA guarda que segurava a
	# asserção — o mutante que animava a primeira vista passou verde.
	var em_troca_ao_abrir := 0
	for d in docas:
		if d.em_troca() or (d.get_node("Barco") as TextureRect).texture == null:
			em_troca_ao_abrir += 1
	_confere("D41: ao abrir, os barcos estão no berço e nenhuma doca troca (%d)"
		% em_troca_ao_abrir, em_troca_ao_abrir == 0)
	for i in range(3):
		GS.assign_worker(int(GS.workers[i]["id"]), i)

	# 1 ── o rumo é o do píer para o mar, pela projeção publicada
	var rumo: Vector2 = k["RUMO_DO_MAR"]
	var mar: Vector2 = _tela(1.0, 0.0, 0.0) - _tela(0.0, 0.0, 0.0)
	_confere("D41: o barco sai e entra na direção do píer para o mar (+mx)",
		absf(rumo.normalized().dot(mar.normalized()) - 1.0) < 0.001,
		"rumo %s, +mx na tela %s" % [rumo, mar])

	# Cada sub-bloco leva a SUA bandeira: um erro de execução lá dentro aborta
	# só ele, e a deste bloco ficava verde. Mordeu na primeira corrida do D41,
	# com uma chave inexistente no registo do dia (`CLAUDE.md`, «Estilo»).
	_confere("D41: a virada correu até ao fim",
		_d41_a_virada(GS, DockS, tela, docas, ganhos) == true)
	_confere("D41: o toque seguinte correu até ao fim",
		_d41_o_toque_seguinte(GS, DockS, tela, docas, ganhos) == true)

	root.remove_child(tela)
	tela.free()
	GS.clear_save()
	_d41_completo = true


func _d41_barco(GS: Node) -> Dictionary:
	var barco: Dictionary = GS._make_boat()
	barco["classe"] = "medio"
	barco["motivo"] = "armazenagem"
	barco["rival"] = false
	barco["matched"] = false
	barco["progress"] = int(barco["op_turns"]) - 1
	return barco


## Um barco que o nível 3 recebe, com arte diferente de `velha`, à espera
## de trabalhador. A classe e o motivo saem da tabela do jogo.
func _d41_barco_outro(GS: Node, DockS: Script, velha: Texture2D) -> Dictionary:
	for classe in GS.CLASSES_DE_NAVIO:
		var dados: Dictionary = GS.CLASSES_DE_NAVIO[classe]
		for motivo in dados["motivos"]:
			var valor: int = int(dados["valor_min"])
			if DockS.arte_do_barco(String(classe), String(motivo), valor) == velha:
				continue
			var barco: Dictionary = GS._make_boat()
			barco["classe"] = classe
			barco["motivo"] = motivo
			barco["value"] = valor
			barco["rival"] = false
			barco["matched"] = false
			barco["progress"] = 0
			return barco
	return {}


func _d41_novos_tweens(antes: Dictionary) -> Array:
	var novos: Array = []
	for tw in get_processed_tweens():
		if not antes.has(tw):
			novos.append(tw)
	return novos


func _d41_dinheiro(texto: String) -> int:
	var so: String = ""
	for c in texto:
		if c >= "0" and c <= "9":
			so += c
	return int(so) if so != "" else -1


func _d41_vivos(ganhos: Control) -> Array:
	var vivos: Array = []
	for r in ganhos.get_children():
		if (r as Control).visible and not r.is_queued_for_deletion():
			vivos.append(r)
	return vivos


# 2, 3, 4 e a contagem
func _d41_a_virada(GS: Node, DockS: Script, tela: Control, docas: Array,
		ganhos: Control) -> bool:
	var pilula := tela.get_node("HudBar/CaixaPilula/Linha/Caixa") as Label
	var meta := tela.get_node("MetaCartao/MetaColuna/MetaTexto") as Label
	var antes_tw := {}
	for tw in get_processed_tweens():
		antes_tw[tw] = true
	var velhos: Array = []
	var bases: Array = []
	for d in docas:
		velhos.append((d.get_node("Barco") as TextureRect).texture)
		bases.append(d.get("_barco_base"))
	var caixa_antes: int = int(GS.cash)
	var turno_antes: int = int(GS.turn)
	tela.call("_on_advance_pressed")
	_confere("D41: a virada não fecha semana (o caixa só muda pela receita)",
		turno_antes % int(GS.TURNS_PER_WEEK) != 0 and GS.phase in ["playing", "rival_offer"],
		"turno %d, fase %s" % [turno_antes, GS.phase])
	if GS.phase == "rival_offer":
		GS.resolve_rival_offer(true)
	# Cada doca recebe um barco novo de ARTE DIFERENTE da do que sai, como o
	# `boats_spawned` lho daria no mesmo quadro: a fila só se prova com as
	# duas pontas, e com a mesma textura dos dois lados não se distingue quem
	# sai de quem entra (a primeira corrida deu três cargueiros iguais).
	for i in range(3):
		GS.docks[i]["boat"] = _d41_barco_outro(GS, DockS, velhos[i])
	tela.call("_refresh_docks")

	# 4 ── a soma dos «+R$» é a receita lançada no dia
	# As linhas de receita: as docagens e o bónus de cada estrutura que PAGA
	# bónus — o «granel» aponta para o guindaste com bónus zero, e essa linha
	# não existe no registo do dia.
	var chaves: Array = ["docagens"]
	for m in GS.MOTIVOS:
		var est: String = String(GS.MOTIVOS[m]["estrutura"])
		if est != "" and float(GS.MOTIVOS[m]["bonus"]) > 0.0 and not chaves.has(est):
			chaves.append(est)
	var receita: int = 0
	for c in chaves:
		receita += int(GS.dia_anterior[c])
	var bruto: int = int(GS.dia_anterior["docagens"])
	var soma := 0
	var vivos: Array = _d41_vivos(ganhos)
	for r in vivos:
		soma += _d41_dinheiro((r as Label).text)
	_confere("D41: sobe um «+R$» por doca que pagou (%d de 3)" % vivos.size(),
		vivos.size() == 3)
	_confere("D41: a soma dos «+R$» é a receita que o jogo lançou no dia",
		soma == receita and receita == int(GS.cash) - caixa_antes,
		"soma %d, receita do dia %d, caixa +%d" % [soma, receita, int(GS.cash) - caixa_antes])
	_confere("D41: e a receita traz bónus, para o valor bruto não passar por ela",
		receita > bruto, "receita %d, bruto %d" % [receita, bruto])
	_confere("D41: no toque o dinheiro ainda mostra o valor de antes",
		_d41_dinheiro(pilula.text) == caixa_antes, "mostra %s" % pilula.text)

	# 2, 3 ── anda os tweens e lê o NÓ a cada passo
	var novos: Array = _d41_novos_tweens(antes_tw)
	var partida := [0, 0, 0]
	var opaco := [0, 0, 0]
	var trocou := [false, false, false]
	var volta := 0
	var entra_fora := 0
	var recua := 0
	var ultimo := [-1.0, -1.0, -1.0]
	var saiu_ate := [-1.0, -1.0, -1.0]
	var contou_no_meio := false
	var desce := 0
	var discorda := 0
	var mostrado_antes := caixa_antes
	var rumo: Vector2 = (DockS.get_script_constant_map()["RUMO_DO_MAR"] as Vector2).normalized()
	for passo in range(int(3.0 / D41_PASSO)):
		for tw in novos:
			if (tw as Tween).is_valid():
				(tw as Tween).custom_step(D41_PASSO)
		var mostrado := _d41_dinheiro(pilula.text)
		if mostrado > caixa_antes and mostrado < int(GS.cash):
			contou_no_meio = true
		if mostrado < mostrado_antes:
			desce += 1
		mostrado_antes = mostrado
		# ⚠️ OU O MESMO DINHEIRO, OU O CONVITE — e o convite pelo dinheiro
		# MOSTRADO (`081`). Desde 04/10 a linha com sobra diz o valor de hoje
		# e não o caixa; esta partida atravessa o limiar a meio da contagem,
		# e o cartão tem de virar no mesmo passo em que a pílula o passa.
		var hoje_d41: int = GS.valor_da_parcela_hoje()
		if mostrado < hoje_d41:
			if not meta.text.contains(pilula.text):
				discorda += 1
		elif not meta.text.contains("quitar hoje por " + GS.moeda(hoje_d41)):
			discorda += 1
		for i in range(3):
			var b := docas[i].get_node("Barco") as TextureRect
			var base: Vector2 = bases[i]
			var andou: float = (b.position - base).dot(rumo)
			if b.texture == velhos[i] and not trocou[i]:
				partida[i] += 1
				if b.modulate.a >= 0.999:
					opaco[i] += 1
				if andou < ultimo[i] - 0.01:
					recua += 1
				ultimo[i] = andou
				saiu_ate[i] = andou
			elif b.texture == velhos[i]:
				volta += 1
			elif not trocou[i]:
				trocou[i] = true
				ultimo[i] = andou
				# O novo nasce no MAR, já fora do berço, e não no berço.
				if andou < (DockS.get_script_constant_map()["RUMO_DO_MAR"] as Vector2).length() * 0.9:
					entra_fora += 1
			else:
				if andou > ultimo[i] + 0.01:
					recua += 1
				ultimo[i] = andou
	_confere("D41: em cada doca o barco velho sai e o novo entra (%s)" % [trocou],
		trocou == [true, true, true])
	_confere("D41: o barco velho não volta depois de o novo aparecer (%d)" % volta, volta == 0)
	_confere("D41: o novo aparece no mar, e não no berço (%d fora)" % entra_fora, entra_fora == 0)
	_confere("D41: o velho só se afasta e o novo só se aproxima (%d recuos)" % recua, recua == 0)
	# O VELHO CHEGA AO MAR ANTES DE O NOVO APARECER. Sem esta, uma chegada
	# que saltasse a partida teria zero passos de partida, e a fração opaca
	# ficaria no valor por omissão — lido no código, e por isso a fração vazia
	# passou a valer zero. O mutante reprova nas duas.
	var comprimento: float = (DockS.get_script_constant_map()["RUMO_DO_MAR"] as Vector2).length()
	var ficaram := 0
	for i in range(3):
		if saiu_ate[i] < comprimento * 0.9:
			ficaram += 1
	_confere("D41: o barco velho chega ao mar antes de o novo aparecer (%d no berço)"
		% ficaram, ficaram == 0, "foram até %s de %.0f px" % [saiu_ate, comprimento])
	var pior := 1.0
	for i in range(3):
		pior = minf(pior, float(opaco[i]) / float(partida[i]) if partida[i] > 0 else 0.0)
	_confere("D41: o barco que sai fica opaco a maior parte do caminho (%.2f)" % pior,
		pior >= D41_OPACO_MIN, "o corte é %.2f" % D41_OPACO_MIN)
	_confere("D41: o dinheiro passa por valores do meio — conta, não salta",
		contou_no_meio)
	_confere("D41: e nunca desce a contar (%d)" % desce, desce == 0)
	_confere("D41: o cartão da parcela mostra o mesmo dinheiro que a pílula (%d)" % discorda,
		discorda == 0)
	var parados := 0
	for i in range(3):
		var b := docas[i].get_node("Barco") as TextureRect
		var barco: Dictionary = GS.docks[i]["boat"]
		var arte: Texture2D = DockS.arte_do_barco(String(barco["classe"]),
			String(barco["motivo"]), int(barco["value"]))
		if b.texture == arte and b.position.is_equal_approx(bases[i]) \
				and b.modulate.a >= 0.999 and not docas[i].em_troca():
			parados += 1
	_confere("D41: no fim, o barco novo de cada doca está no berço (%d de 3)" % parados,
		parados == 3)
	_confere("D41: no fim, o dinheiro é o do jogo e nenhum «+R$» está no ar",
		pilula.text == GS.moeda(int(GS.cash)) and _d41_vivos(ganhos).is_empty()
			and not tela.virada_em_curso(),
		"mostra %s, %d no ar" % [pilula.text, _d41_vivos(ganhos).size()])

	# 6b ── fora do botão, o dinheiro salta
	GS.cash += 777
	tela.call("_refresh_hud")
	_confere("D41: dinheiro mudado fora da virada aparece já, sem contar",
		pilula.text == GS.moeda(int(GS.cash)) and not tela.virada_em_curso(),
		"mostra %s, o jogo tem %s" % [pilula.text, GS.moeda(int(GS.cash))])
	return true


# 6 ── o toque seguinte acaba a virada em curso
func _d41_o_toque_seguinte(GS: Node, DockS: Script, tela: Control, docas: Array,
		ganhos: Control) -> bool:
	if GS.phase == "rival_offer":
		GS.resolve_rival_offer(true)
	var pilula := tela.get_node("HudBar/CaixaPilula/Linha/Caixa") as Label
	for i in range(3):
		GS.docks[i]["boat"] = _d41_barco(GS)
		GS.docks[i]["worker_id"] = null
	tela.call("_refresh_docks")
	tela.call("_concluir_virada")
	for i in range(3):
		GS.assign_worker(int(GS.workers[i]["id"]), i)
	var antes_tw := {}
	for tw in get_processed_tweens():
		antes_tw[tw] = true
	tela.call("_on_advance_pressed")
	if GS.phase == "rival_offer":
		GS.resolve_rival_offer(true)
	for i in range(3):
		if GS.docks[i]["boat"] == null:
			GS.docks[i]["boat"] = _d41_barco(GS)
			GS.docks[i]["boat"]["progress"] = 0
	tela.call("_refresh_docks")
	var do_primeiro: Array = _d41_vivos(ganhos)
	var caixa_primeiro: int = int(GS.cash)
	# A meio da virada: a partida acabou, a chegada está a meio.
	var novos: Array = _d41_novos_tweens(antes_tw)
	for passo in range(int(1.0 / D41_PASSO)):
		for tw in novos:
			if (tw as Tween).is_valid():
				(tw as Tween).custom_step(D41_PASSO)
	_confere("D41: a meio, a virada está em curso", tela.virada_em_curso())
	# O segundo toque, sem ninguém a pagar: os barcos novos não têm
	# trabalhador e saem perdidos.
	if GS.phase == "rival_offer":
		GS.resolve_rival_offer(true)
	tela.call("_on_advance_pressed")
	var sobram := 0
	for r in do_primeiro:
		if (r as Control).visible and not r.is_queued_for_deletion():
			sobram += 1
	_confere("D41: o toque seguinte tira do ar os «+R$» da virada anterior (%d sobram)"
		% sobram, sobram == 0)
	_confere("D41: e põe o dinheiro no valor que a virada anterior prometia",
		_d41_dinheiro(pilula.text) == caixa_primeiro,
		"mostra %s, a virada anterior acabava em %s" % [pilula.text, GS.moeda(caixa_primeiro)])
	var encostados := 0
	for d in docas:
		var b := d.get_node("Barco") as TextureRect
		if b.position.is_equal_approx(d.get("_barco_base")) and b.modulate.a >= 0.999:
			encostados += 1
	_confere("D41: e cada barco a meio da chegada encosta no berço antes de sair (%d de 3)"
		% encostados, encostados == 3)
	return true


# ── D42 ── o pórtico do nível 3 e a empilhadeira (03/10, `docs/decisoes/079`)
#
# No porto de nível 3 o pórtico tira a carga do barco e pousa-a num pallet a
# meio do cais, e o trabalhador alocado leva o pallet de EMPILHADEIRA à pilha
# da raiz — ou às portas do camião encostado. Os dois trabalham o serviço
# inteiro. O contêiner pousa no cais, como no n2, e ela espera ao volante.
# Seis perguntas:
#
#   1. TODO PAR (classe, motivo) que o nível 3 recebe tem tipo de carga, e o
#      tipo tem as pontas, as nove lingadas e a pilha — e os de pallet, a
#      carga no garfo em baixo e levantada. Nenhum tipo das tabelas sem par.
#   2. O CICLO, como aritmética: a carga do pórtico só pende onde ele está;
#      o pallet espera no chão só depois de largado; ELA ESTÁ À ESPERA sempre
#      que o pallet seguinte desce (senão ele pousava-lhe no garfo); ela não
#      salta no caminho; todo trecho e os dois garfos passam.
#   3. NO RENDER: a carga desce dentro de cada casco que o nível 3 recebe; o
#      pallet que o spreader larga e o que ela apanha caem no MESMO sítio; o
#      que ela larga coincide com o da frente da pilha; o caminho anda em
#      `−mx`; ela pisa o tabuado nas três posições, nos píeres 2 e 3; ela à
#      espera não toca o pallet que desce; e a empilhadeira, do cais e do
#      pátio, está na régua da pessoa — a do pátio media 3,2x a pessoa.
#   4. NA DOCA MONTADA, com uma MULHER: o nó do trabalhador sai e ela vai
#      ao volante; todo quadro passa pelos nós; o pallet no garfo anda com a
#      empilhadeira; um `refresh()` não recomeça; no segundo turno continua; o
#      contêiner deixa-a à espera; acabado o serviço, ela fica parada sem
#      ninguém, e no nível 2 sai.
#   5. O CAMIÃO, pela cena inteira: encostado pelo `Main`, o caminho vai às
#      portas de trás dele, no eixo, e o pallet acaba junto ao desenho dele —
#      e o caminho mais comprido ainda cabe no ciclo do pórtico.
#   6. NENHUM PROP DO CENÁRIO QUE LHE FIQUE À FRENTE é tapado por ela, até à
#      pilha e até ao camião, nas três docas, com os prédios em ruína e prontos.
var _d42_completo := false

# A régua: a altura OPACA desenhada da empilhadeira (sem a sombra de contacto,
# que é semitransparente) contra a do camião da carga geral, e contra a pessoa.
# Escolha do Bruno, 1,5x o real como a pessoa (`079`). Medido a 03/10: a do
# pátio de antes media 30,7 px, a MESMA altura do camião (1,00); as de agora,
# 20,7 no cais (0,67) e 24,0 no pátio (0,78, de garfo para a câmara). O corte
# fica no meio entre a pior boa e a má. Por baixo, ela tem de ser mais alta do
# que a pessoa de pé (11,3 px): quem vai sentado cabe debaixo da cobertura.
# ⚠️ A CAIXA COM SOMBRA MENTIA: a primeira versão desta guarda lia o
# `PropIso.desenho()`, que conta a sombra do pátio e o chão projetado, e deu
# 2,6x a pessoa a uma empilhadeira que está na régua.
const D42_CAMIAO_MAX := 0.89
const D42_PESSOA_MIN := 1.2
# O caminho até à pilha anda em `−mx`; o do camião, na folga do D40.
const D42_EIXO_PILHA_GRAUS := 3.0
# O pallet que o spreader larga e o que ela apanha: o fundo dos dois, em px de
# tela. São o mesmo ponto do mundo; o meio pixel é do antisserrilhado.
const D42_POUSO_PX := 1.5
# O pallet que ela larga contra o da frente da pilha: a fração dos pixels dele
# que caem em cima de desenho da pilha. Coincidem por construção (o caminho
# sai dos dois desenhos); um pallet de distância dá ~0,5.
const D42_PILHA_MIN := 0.9


func _d42_portico_n3() -> void:
	var GS: Node = root.get_node("GameState")
	var DockS: Script = load("res://scripts/Dock.gd")
	var Ret: Script = load("res://scripts/Retratos.gd")
	var k: Dictionary = DockS.get_script_constant_map()
	var servico: Dictionary = k["CARGA_DO_SERVICO"]
	var pontas: Dictionary = k["PONTAS_N3"]
	var lingadas: Dictionary = k["LINGADAS_N3"]
	var pilhas: Dictionary = k["PILHAS_N3"]
	var garfo: Dictionary = k["GARFO_N3"]
	var emp: Dictionary = k["QUADROS_EMPILHADEIRA"]
	var lugares := ["barco", "g0", "g1", "g2", "g3", "g4", "g5", "g6", "pilha"]

	# 1 ── a tabela contra as classes que o nível 3 recebe
	var exigidas := 0
	var tipos_usados := {}
	for classe in GS.CLASSES_DE_NAVIO:
		var dados: Dictionary = GS.CLASSES_DE_NAVIO[classe]
		if int(dados["nivel"]) > 3:
			continue
		for motivo in dados["motivos"]:
			if int(dados["motivos"][motivo]) <= 0:
				continue
			exigidas += 1
			var tem: bool = servico.has(classe) \
				and (servico[classe] as Dictionary).has(motivo)
			_confere("D42: %s · %s tem tipo de carga no nível 3" % [classe, motivo],
				tem, "o pórtico rebentaria no `refresh()` ao receber este barco")
			if not tem:
				continue
			var tipo: String = servico[classe][motivo]
			tipos_usados[tipo] = true
			var completo: bool = pontas.has(tipo) and pilhas.has(tipo) \
				and pilhas[tipo] is Texture2D and lingadas.has(tipo)
			if completo:
				for ponta in ["barco", "pilha"]:
					completo = completo and pontas[tipo].has(ponta) \
						and pontas[tipo][ponta] is Texture2D
				for lugar in lugares:
					completo = completo and lingadas[tipo].has(lugar) \
						and lingadas[tipo][lugar] is Texture2D
			if tipo != "conteiner":
				completo = completo and garfo.has(tipo) \
					and garfo[tipo].get("baixo") is Texture2D \
					and garfo[tipo].get("alto") is Texture2D
			_confere("D42: o tipo «%s» tem as pontas, as nove lingadas e a pilha%s"
					% [tipo, "" if tipo == "conteiner" else ", e o garfo"], completo)
	_confere("D42: o nível 3 recebe pares (%d)" % exigidas, exigidas > 0)
	var tabelas := {"PONTAS_N3": pontas, "LINGADAS_N3": lingadas,
		"PILHAS_N3": pilhas, "GARFO_N3": garfo}
	for nome in tabelas:
		var sobra: Array = []
		for tipo in tabelas[nome]:
			if not tipos_usados.has(tipo):
				sobra.append(tipo)
		_confere("D42: nenhum tipo da %s fica sem serviço (%s)" % [nome, sobra],
			sobra.is_empty())

	# 2 ── o ciclo, como aritmética, com o caminho até à pilha do papelão
	var destino: Vector2 = PropIso.desenho(pilhas["caixa"]).end \
		- PropIso.desenho(garfo["caixa"]["baixo"]).end
	var espera: Vector2 = k["ESPERA_N3"]
	var v: float = k["EMPILHADEIRA_PX_POR_SEG"]
	var leva := destino.length() / v
	var volta := (destino - espera).length() / v
	_confere("D42: ida e volta até à pilha cabem no ciclo (%.2f + %.2f s de %.2f)"
			% [leva, volta, float(DockS.janela_n3())],
		leva + volta <= float(DockS.janela_n3()))
	var dt := 1.0 / 60.0
	var trechos := {}
	var garfos := {}
	var lancas_vistas := {}
	var carga_fora := 0
	var chao_com_carga := 0
	var desce_sem_espera := 0
	var salto_max := 0.0
	var antes = null
	var t := 0.0
	while t < 2.0 * float(DockS.duracao_do_ciclo()):
		t += dt
		var p: Dictionary = DockS.pose_n3(t, leva, volta)
		lancas_vistas[p["lanca"]] = true
		trechos[p["trecho"]] = true
		garfos[p["garfo"]] = true
		if String(p["carga"]) != "" and p["carga"] != p["lanca"]:
			carga_fora += 1
		if bool(p["chao"]) and String(p["carga"]) != "":
			chao_com_carga += 1
		# O pallet seguinte a descer no pouso: ela tem de estar à espera.
		if String(p["carga"]) == "pilha" and String(p["trecho"]) != "espera":
			desce_sem_espera += 1
		var onde := _d42_onde(p, destino, espera)
		if antes != null:
			salto_max = maxf(salto_max, (onde - (antes as Vector2)).length())
		antes = onde
	_confere("D42: a carga do pórtico só pende onde ele está (%d fora)" % carga_fora,
		carga_fora == 0)
	_confere("D42: o pallet só espera no chão depois de largado (%d com carga no spreader)"
			% chao_com_carga, chao_com_carga == 0)
	_confere("D42: ela está à espera sempre que o pallet seguinte desce (%d fora)"
			% desce_sem_espera, desce_sem_espera == 0,
		"senão o spreader pousava-o em cima do garfo dela")
	# O passo mais comprido: a ida inteira em `leva` segundos, a 60 por segundo.
	var passo_max := maxf(destino.length() / leva, (destino - espera).length() / volta) \
		* dt * 1.5
	_confere("D42: ela não salta no caminho (%.2f px num passo, até %.2f)"
			% [salto_max, passo_max], salto_max <= passo_max)
	_confere("D42: os seis trechos dela passam (%s)" % [trechos.keys()],
		trechos.size() == 6)
	_confere("D42: o garfo sobe e desce (%s)" % [garfos.keys()], garfos.size() == 2)
	var faltam: Array = []
	for chave in k["LANCA_N3"]:
		if not lancas_vistas.has(chave):
			faltam.append(chave)
	for lugar in ["barco", "pilha"]:
		if not lancas_vistas.has(lugar):
			faltam.append(lugar)
	_confere("D42: todo passo do pórtico passa no ciclo", faltam.is_empty(),
		"nunca aparecem: %s" % [faltam])

	# 3 ── no render
	var doca: Control = load("res://scenes/dock/Dock.tscn").instantiate()
	var no_pier := (doca.get_node("Pier") as Control).position
	var no_barco := (doca.get_node("Barco") as Control).position
	var no_carga := (doca.get_node("Carga") as Control).position
	var no_garfo := (doca.get_node("Garfo") as Control).position
	var no_emp := (doca.get_node("Empilhadeira") as Control).position
	var no_pilha := (doca.get_node("Pilha") as Control).position
	doca.free()
	var cascos: Dictionary = k["CASCOS"]
	var cascos_vistos := 0
	for classe in servico:
		if int(GS.CLASSES_DE_NAVIO[classe]["nivel"]) > 3:
			continue
		for motivo in servico[classe]:
			var tipo: String = servico[classe][motivo]
			# Pelo FUNDO da carga, onde ela toca o convés (o D40 mediu porquê).
			var c: Rect2 = PropIso.desenho(lingadas[tipo]["barco"])
			var ponto: Vector2 = Vector2(c.get_center().x, c.end.y - 1.5) + no_carga - no_barco
			for casco in cascos[classe][motivo]:
				cascos_vistos += 1
				var cheio := _d39_desenho_a_volta(casco, ponto, 3)
				_confere("D42: a carga de %s desce dentro do %s (%s, %.0f%% de casco à volta)"
						% [tipo, String(casco.resource_path).get_file().get_basename(),
						   motivo, cheio * 100.0],
					cheio >= D39_CASCO_MIN, "ela desce na água ao lado dele")
	_confere("D42: percorreu os cascos do nível 3 (%d)" % cascos_vistos, cascos_vistos > 0)

	for tipo in garfo:
		# O pallet que o spreader larga e o que ela apanha: o mesmo sítio.
		var largado: Rect2 = PropIso.desenho(lingadas[tipo]["pilha"])
		var apanhado: Rect2 = PropIso.desenho(garfo[tipo]["baixo"])
		largado.position += no_carga - no_garfo
		var dx := largado.get_center().x - apanhado.get_center().x
		var dy := largado.end.y - apanhado.end.y
		_confere("D42: %s — o pallet que o spreader larga é o que ela apanha (dx %.1f, dy %.1f)"
				% [tipo, dx, dy],
			absf(dx) <= D42_POUSO_PX and absf(dy) <= D42_POUSO_PX)
		# O que ela larga contra o da frente da pilha.
		var d: Vector2 = PropIso.desenho(pilhas[tipo]).end - apanhado.end
		var graus := rad_to_deg(absf(d.normalized().angle_to(Vector2(-2.0, -1.0).normalized())))
		_confere("D42: %s — o caminho até à pilha anda em −mx (%.1f°, %.0f px)"
				% [tipo, graus, d.length()],
			graus <= D42_EIXO_PILHA_GRAUS and d.length() > 15.0)
		var sobre := _d42_sobre(garfo[tipo]["baixo"], no_garfo + d, pilhas[tipo], no_pilha)
		_confere("D42: %s — o pallet que ela larga é o da frente da pilha (%.0f%% em cima dela)"
				% [tipo, sobre * 100.0], sobre >= D42_PILHA_MIN)

	# Ela pisa o tabuado: o fundo do desenho dela, à espera, no pouso e na
	# pilha, nos píeres 2 e 3 — o pórtico vem com o guindaste, e o cais de
	# concreto com outra compra.
	var arte_pier: Array = k["ArtePier"]
	var parada: Texture2D = k["EMPILHADEIRA_N3"]
	var r_emp: Rect2 = PropIso.desenho(parada)
	var d_pilha: Vector2 = PropIso.desenho(pilhas["caixa"]).end \
		- PropIso.desenho(garfo["caixa"]["baixo"]).end
	for nivel in [1, 2]:
		for lugar in [["à espera", espera], ["no pouso", Vector2.ZERO], ["na pilha", d_pilha]]:
			for canto in [Vector2(r_emp.position.x + 2.0, r_emp.end.y - 3.0),
					Vector2(r_emp.end.x - 2.0, r_emp.end.y - 2.0)]:
				var ponto: Vector2 = canto + (lugar[1] as Vector2) + no_emp - no_pier
				var chao := _d39_desenho_a_volta(arte_pier[nivel], ponto, 2)
				_confere("D42: no píer %d ela pisa o tabuado %s (%.0f%% de píer)"
						% [nivel + 1, lugar[0], chao * 100.0], chao >= D39_CASCO_MIN)

	# À espera, não toca o pallet que desce no pouso.
	for tipo in garfo:
		var toca := _d40_tapa(parada, no_emp + espera, lingadas[tipo]["pilha"], no_carga)
		_confere("D42: %s — à espera, ela não toca o pallet que desce (%.0f%%)"
				% [tipo, toca * 100.0], toca == 0.0)

	# Quem conduz: os dois sexos, distintos, e o garfo mexe.
	_confere("D42: ele e ela ao volante são figuras distintas",
		PropIso.imagem(emp["h"]["baixo"]).get_data() != PropIso.imagem(emp["m"]["baixo"]).get_data())
	_confere("D42: parada, ninguém a conduz",
		PropIso.imagem(parada).get_data() != PropIso.imagem(emp["h"]["baixo"]).get_data())
	for sexo in ["h", "m"]:
		_confere("D42: %s — o garfo sobe" % sexo,
			PropIso.imagem(emp[sexo]["baixo"]).get_data() != PropIso.imagem(emp[sexo]["alto"]).get_data())

	# A régua, na do cais e na do pátio.
	var pessoa := _d42_altura_opaca(k["QUADROS_TRABALHADOR"]["h"]["parado"])
	var camiao := _d42_altura_opaca(load("res://art/props/caminhao_armazenagem.png"))
	var do_patio: Texture2D = load("res://art/props/empilhadeira.png")
	for par in [["do cais", parada], ["do pátio", do_patio]]:
		var h := _d42_altura_opaca(par[1])
		_confere("D42: a empilhadeira %s está na régua (%.2fx o camião, %.2fx a pessoa)"
				% [par[0], h / camiao, h / pessoa],
			h / camiao <= D42_CAMIAO_MAX and h / pessoa >= D42_PESSOA_MIN)

	# 4 ── a doca montada
	_d42_na_doca(GS, DockS, Ret, k)
	_d42_camiao(GS, DockS, k)
	_d42_ninguem_a_frente(GS, DockS, k)
	_d42_completo = true


## A altura, em px de tela, das linhas do PNG com algum pixel opaco (alfa
## acima de 0,5): a sombra de contacto do pátio é semitransparente e fica de
## fora.
func _d42_altura_opaca(tex: Texture2D) -> float:
	var img := PropIso.imagem(tex)
	var r := img.get_used_rect()
	var topo := -1
	var fundo := -1
	for y in range(r.position.y, r.end.y):
		for x in range(r.position.x, r.end.x):
			if img.get_pixel(x, y).a > 0.5:
				if topo < 0:
					topo = y
				fundo = y
				break
	return float(fundo - topo + 1) * PropIso.escala(tex)


## Onde ela está, contra o pouso, no passo `p` — a mesma conta do `Dock.gd`.
func _d42_onde(p: Dictionary, destino: Vector2, espera: Vector2) -> Vector2:
	var f: float = p["fracao"]
	match String(p["trecho"]):
		"espera":
			return espera
		"encosta":
			return espera.lerp(Vector2.ZERO, f)
		"leva", "pousa":
			return destino * f
		"volta":
			return destino.lerp(espera, f)
	return Vector2.ZERO


## A fração dos pixels opacos de `a` (no nó em `no_a`) que caem em cima de
## desenho de `b` (no nó em `no_b`).
func _d42_sobre(a: Texture2D, no_a: Vector2, b: Texture2D, no_b: Vector2) -> float:
	var ia := PropIso.imagem(a)
	var ib := PropIso.imagem(b)
	var e := PropIso.escala(a)
	var desloc := Vector2i(((no_a - no_b) / e).round())
	var r := ia.get_used_rect()
	var total := 0
	var sobre := 0
	for y in range(r.position.y, r.end.y):
		for x in range(r.position.x, r.end.x):
			if ia.get_pixel(x, y).a <= 0.5:
				continue
			total += 1
			var q := Vector2i(x, y) + desloc
			if q.x >= 0 and q.y >= 0 and q.x < ib.get_width() and q.y < ib.get_height() \
					and ib.get_pixelv(q).a > 0.5:
				sobre += 1
	return float(sobre) / float(maxi(total, 1))


func _d42_na_doca(GS: Node, DockS: Script, Ret: Script, k: Dictionary) -> void:
	GS.clear_save()
	GS._rng.seed = 20261004
	GS.new_game()
	if GS.phase == "rival_offer":
		GS.resolve_rival_offer(true)
	var estruturas_antes: Array = GS.estruturas.duplicate()
	GS.estruturas = ["armazem", "patio", "guindaste", "cais"]
	_confere("D42: com o guindaste e o cais o porto é de nível 3",
		int(GS.nivel_guindaste()) == 3 and int(GS.nivel_do_porto()) == 3)
	var mulher := -1
	for i in range((Ret.get_script_constant_map()["TRABALHADORES"] as Array).size()):
		if Ret.sexo_do_rosto(i) == "m":
			mulher = i
			break
	var w: Dictionary = GS.workers[0]
	w["rosto"] = mulher
	GS.docks[0]["worker_id"] = null
	var barco: Dictionary = GS._make_boat()
	barco["classe"] = "grande"
	barco["motivo"] = "armazenagem"
	barco["rival"] = false
	barco["progress"] = 0
	GS.docks[0]["boat"] = barco

	var doca: Control = load("res://scenes/dock/Dock.tscn").instantiate()
	doca.setup(0)
	root.add_child(doca)
	var trab := doca.get_node("Trabalhador") as TextureRect
	var pilha := doca.get_node("Pilha") as TextureRect
	var carga := doca.get_node("Carga") as TextureRect
	var garfo_no := doca.get_node("Garfo") as TextureRect
	var emp_no := doca.get_node("Empilhadeira") as TextureRect
	var barco_no := doca.get_node("Barco") as TextureRect
	var no_lanca := doca.get_node("Lanca") as TextureRect
	var tipo: String = k["CARGA_DO_SERVICO"]["grande"]["armazenagem"]
	var dela := {}
	for alt in k["QUADROS_EMPILHADEIRA"]["m"]:
		dela[k["QUADROS_EMPILHADEIRA"]["m"][alt]] = alt
	var da_lanca := {}
	for chave in k["LANCA_N3"]:
		da_lanca[k["LANCA_N3"][chave]] = chave
	for ponta in k["PONTAS_N3"][tipo]:
		da_lanca[k["PONTAS_N3"][tipo][ponta]] = ponta
	var da_carga := {}
	for lugar in k["LINGADAS_N3"][tipo]:
		da_carga[k["LINGADAS_N3"][tipo][lugar]] = lugar
	var do_garfo := {}
	for alt in k["GARFO_N3"][tipo]:
		do_garfo[k["GARFO_N3"][tipo][alt]] = alt

	_confere("D42: parada, sem ninguém, a empilhadeira espera no cais",
		emp_no.visible and emp_no.texture == k["EMPILHADEIRA_N3"] and not garfo_no.visible)
	GS.assign_worker(int(w["id"]), 0, false)
	doca.refresh()
	var tw0 = doca.get("_tw_trabalho")
	var tem_tween: bool = tw0 is Tween and (tw0 as Tween).is_valid()
	_confere("D42: alocada, o nó do trabalhador sai e ela vai ao volante",
		tem_tween and not trab.visible and emp_no.visible and dela.has(emp_no.texture))
	_confere("D42: a pilha é a dos pallets do tipo do barco (%s)" % tipo,
		pilha.visible and pilha.texture == k["PILHAS_N3"][tipo])
	_confere("D42: na ordem dos nós a pilha, o pallet, ela e o barco",
		pilha.get_index() < garfo_no.get_index() and garfo_no.get_index() < emp_no.get_index()
			and emp_no.get_index() < barco_no.get_index()
			and barco_no.get_index() < carga.get_index())
	var varre = doca.get("_tw_lanca")
	_confere("D42: o pórtico não gira a imagem por cima dos quadros",
		no_lanca.rotation == 0.0 and not (varre is Tween and (varre as Tween).is_valid()))

	var lanca_vista := {}
	var carga_vista := {}
	var garfo_visto := {}
	var fora_dela := 0
	var garfo_solto := 0
	var com_ela := 0
	var duas_cargas := 0
	var sumiu := 0
	var posicoes := {}
	var salto_no := 0.0
	var emp_antes = null
	if tem_tween:
		var tw: Tween = tw0
		var passos := int(ceil(float(DockS.duracao_do_ciclo()) * 30.0)) + 2
		for i in range(passos):
			tw.custom_step(1.0 / 30.0)
			if da_lanca.has(no_lanca.texture):
				lanca_vista[da_lanca[no_lanca.texture]] = true
			if carga.visible:
				carga_vista[da_carga.get(carga.texture, "?")] = true
			if not dela.has(emp_no.texture):
				fora_dela += 1
			posicoes[Vector2i(emp_no.position.round())] = true
			if emp_antes != null:
				salto_no = maxf(salto_no, emp_no.position.distance_to(emp_antes as Vector2))
			emp_antes = emp_no.position
			# Com o spreader em baixo no pouso o pallet está nele ou no chão:
			# largado, e antes de ela o apanhar, é o nó `Garfo` que o mostra.
			if da_lanca.get(no_lanca.texture, "") == "pilha" and not carga.visible \
					and not garfo_no.visible:
				sumiu += 1
			if garfo_no.visible:
				garfo_visto[do_garfo.get(garfo_no.texture, "?")] = true
				# Com ela já a caminho do destino, o pallet que se vê é o do
				# garfo, e anda com ela. ⚠️ A PRIMEIRA VERSÃO ISENTAVA O PALLET
				# «NO POUSO» — e o defeito de o deixar lá enquanto ela anda cabia
				# todo nessa isenção (medido: passou verde). O que separa o
				# pallet no chão do pallet no garfo é ONDE ELA ESTÁ.
				var na_ida: bool = (emp_no.position - Vector2(doca.get("_emp_base"))) \
					.dot(Vector2(doca.get("_destino_n3"))) > 1.0
				if na_ida:
					com_ela += 1
					if garfo_no.position != emp_no.position:
						garfo_solto += 1
				if carga.visible:
					duas_cargas += 1
			if i == 30:
				var antes := no_lanca.texture
				var pos_antes := emp_no.position
				doca.refresh()
				_confere("D42: um refresh a meio não recomeça o ciclo",
					doca.get("_tw_trabalho") == tw0 and no_lanca.texture == antes
						and emp_no.position == pos_antes)
	var n_lanca: int = (k["LANCA_N3"] as Dictionary).size() + 2
	_confere("D42: os %d passos do pórtico passam pelo nó (%d)" % [n_lanca, lanca_vista.size()],
		lanca_vista.size() == n_lanca)
	_confere("D42: as nove lingadas passam pelo nó Carga (%d)" % carga_vista.size(),
		carga_vista.size() == 9 and not carga_vista.has("?"))
	_confere("D42: o pallet no garfo, em baixo e levantado, passa pelo nó (%s)"
			% [garfo_visto.keys()],
		garfo_visto.size() == 2 and not garfo_visto.has("?"))
	_confere("D42: todo quadro da empilhadeira é dela (%d fora)" % fora_dela, fora_dela == 0)
	_confere("D42: o pallet no garfo anda com ela (%d fora em %d passos a caminho)"
			% [garfo_solto, com_ela], garfo_solto == 0 and com_ela > 10)
	_confere("D42: o pallet nunca está no spreader e no garfo ao mesmo tempo (%d)"
			% duas_cargas, duas_cargas == 0)
	_confere("D42: o pallet largado não some antes de ela o apanhar (%d passos)" % sumiu,
		sumiu == 0)
	_confere("D42: ela anda (%d posições)" % posicoes.size(), posicoes.size() > 20)
	# A MESMA PERGUNTA DO CICLO, NO NÓ: a de cima refaz a conta do `Dock.gd`, e
	# um erro no `_aplicar_n3()` passava-lhe ao lado. A 1/30 s ela anda menos
	# de 1 px; o corte de 2 px apanha qualquer teletransporte.
	_confere("D42: no nó ela não salta (%.2f px num passo de 1/30 s)" % salto_no,
		salto_no <= 2.0)

	# O segundo turno do serviço: no n3 os dois continuam.
	barco["progress"] = 1
	doca.refresh()
	_confere("D42: no segundo turno o ciclo continua", doca.get("_tw_trabalho") == tw0
		and (tw0 as Tween).is_valid())

	# O contêiner: o pórtico pousa-o no cais, e ela espera ao volante.
	barco["motivo"] = "conteiner"
	doca.refresh()
	var tw1 = doca.get("_tw_trabalho")
	var espera: Vector2 = k["ESPERA_N3"]
	_confere("D42: com contêiner o pórtico trabalha e ela espera ao volante, sem pallet",
		tw1 is Tween and (tw1 as Tween).is_valid() and pilha.texture == k["PILHAS_N3"]["conteiner"]
			and k["QUADROS_EMPILHADEIRA"]["m"]["baixo"] == emp_no.texture
			and emp_no.position == Vector2(doca.get("_emp_base")) + espera
			and not garfo_no.visible)

	# Acabado o serviço: parada, sem ninguém, à espera; e no nível 2 sai.
	GS.docks[0]["worker_id"] = null
	GS.docks[0]["boat"] = null
	doca.refresh()
	_confere("D42: acabado o serviço, ela fica parada sem ninguém e o pallet sai",
		emp_no.visible and emp_no.texture == k["EMPILHADEIRA_N3"] and not garfo_no.visible
			and not pilha.visible and not carga.visible
			and emp_no.position == Vector2(doca.get("_emp_base")) + espera)
	GS.estruturas = ["armazem", "patio"]
	load("res://tools/estado_da_bancada.gd").guindaste_intermediario(GS)
	doca.refresh()
	_confere("D42: no nível 2 a empilhadeira sai do cais", not emp_no.visible)
	doca.queue_free()
	GS.estruturas = estruturas_antes


# O pallet no fim do caminho, contra o desenho do camião encostado: a fração
# de camião num quadrado à volta do CENTRO do pallet (a meio pallet das
# portas, porque é o centro que pára lá). Medido a 03/10.
const D42_ENTREGA_RAIO := 8
const D42_ENTREGA_MIN := 0.03


func _d42_camiao(GS: Node, DockS: Script, k: Dictionary) -> void:
	if GS.phase == "rival_offer":
		GS.resolve_rival_offer(true)
	var tweens_antes := {}
	for tw in get_processed_tweens():
		tweens_antes[tw] = true
	var estruturas_antes: Array = GS.estruturas.duplicate()
	GS.estruturas = ["armazem", "patio", "guindaste", "cais"]
	var tela: Control = load(CENA).instantiate()
	root.add_child(tela)
	var consts: Dictionary = tela.get_script().get_script_constant_map()
	var acessos: Array = consts["ACESSOS_DOCA"]
	while GS.docks.size() < acessos.size():
		GS.docks.append({"boat": null, "worker_id": null})
	for d in GS.docks:
		d["boat"] = null
		d["worker_id"] = null
	var barco: Dictionary = GS._make_boat()
	barco["classe"] = "grande"
	barco["motivo"] = "armazenagem"
	barco["rival"] = false
	barco["progress"] = 0
	GS.docks[0]["boat"] = barco
	GS.docks[0]["worker_id"] = int(GS.workers[0]["id"])
	tela.call("_refresh_all")
	for tw in get_processed_tweens():
		if not tweens_antes.has(tw):
			tw.kill()
	var doca: Control = tela.get_node("MapaWrap/Docas/Doca0")
	var pilha_tex: Texture2D = k["PILHAS_N3"]["caixa"]
	var sem_camiao: Vector2 = doca.get("_destino_n3")
	_confere("D42: sem camião ela leva à pilha",
		doca.get("_camiao") == null and sem_camiao.is_equal_approx(
			PropIso.desenho(pilha_tex).end - PropIso.desenho(k["GARFO_N3"]["caixa"]["baixo"]).end))

	var cenario := tela.get_node("MapaWrap/Cenario")
	var caminhao := cenario.get_node("Caminhao0") as TextureRect
	var base: Vector2 = (tela.get("_base_do_caminhao") as Array)[0]
	var origem: Vector2 = (consts["CAMINHAO_ORIGENS"] as Array)[0]
	caminhao.position = base + tela.tela_da_rota(acessos[0]["paragem"], origem)
	caminhao.texture = consts["CAMINHOES"]["armazenagem"][0]["mx_retorno"]
	(tela.get("_ocupante_do_berco") as Array)[0] = caminhao
	tela.call("_encostou", 0, int(barco["id"]))
	var tw0 = doca.get("_tw_trabalho")
	_confere("D42: com o camião encostado a doca sabe dele e o caminho muda",
		doca.get("_camiao") != null and tw0 is Tween and (tw0 as Tween).is_valid()
			and not (doca.get("_destino_n3") as Vector2).is_equal_approx(sem_camiao))
	# No camião o garfo NÃO desce: a carga entra pelas portas à altura a que
	# vinha. Anda o ciclo pelo tween e lê o nó no fim do caminho.
	var emp_no := doca.get_node("Empilhadeira") as TextureRect
	var sexo0: String = DockS.sexo_do_trabalhador(int(GS.workers[0]["id"]))
	var no_fim := 0
	var desceu := 0
	if tw0 is Tween and (tw0 as Tween).is_valid():
		var alvo: Vector2 = Vector2(doca.get("_emp_base")) + Vector2(doca.get("_destino_n3"))
		var passos := int(ceil(float(DockS.duracao_do_ciclo()) * float(doca.get("_escala_n3")) * 30.0)) + 2
		for i in range(passos):
			(tw0 as Tween).custom_step(1.0 / 30.0)
			if emp_no.position.distance_to(alvo) < 0.01:
				no_fim += 1
				if emp_no.texture == k["QUADROS_EMPILHADEIRA"][sexo0]["baixo"]:
					desceu += 1
	_confere("D42: nas portas do camião o garfo não desce (%d de %d passos lá em baixo)"
			% [desceu, no_fim], no_fim > 0 and desceu == 0)

	# O eixo e o fim, em cada camião que leva PALLET: o pescado, a carga geral
	# e o granel, das duas empresas.
	var eixo := Vector2(-2.0, -1.0).normalized()
	var pior_graus := 0.0
	var qual := ""
	var mais_longe := 0.0
	var pior_junto := 1.0
	var dentro_max := 0.0
	var garfo_tex: Texture2D = k["GARFO_N3"]["caixa"]["baixo"]
	var r := PropIso.desenho(garfo_tex)
	var emp_base: Vector2 = doca.get("_emp_base")
	for motivo in ["pescado", "armazenagem", "granel"]:
		for e in range((consts["CAMINHOES"][motivo] as Array).size()):
			caminhao.texture = consts["CAMINHOES"][motivo][e]["mx_retorno"]
			doca.camiao_no_berco(tela.portas_do_camiao(caminhao) - doca.global_position)
			var c: Vector2 = doca.get("_destino_n3")
			var g := rad_to_deg(absf(c.normalized().angle_to(eixo)))
			if g > pior_graus:
				pior_graus = g
				qual = "%s, empresa %d, %.0f px" % [motivo, e, c.length()]
			mais_longe = maxf(mais_longe, c.length())
			var centro: Vector2 = emp_base + Vector2(PropIso.MEIO, PropIso.MEIO) \
				+ r.get_center() + c + doca.position
			var centro_cam := caminhao.position + caminhao.size / 2.0
			pior_junto = minf(pior_junto, _d39_desenho_a_volta(caminhao.texture,
				centro - centro_cam, D42_ENTREGA_RAIO))
	_confere("D42: até ao camião o caminho anda em −mx (pior %.1f°: %s)" % [pior_graus, qual],
		pior_graus <= D40_EIXO_MAX_GRAUS)
	_confere("D42: o pallet acaba junto às portas de trás (pior %.0f%% de camião à volta)"
			% [pior_junto * 100.0], pior_junto >= D42_ENTREGA_MIN)
	# O ÚLTIMO camião posto é o do caminho mais comprido? Não necessariamente
	# — então põe-se o mais comprido outra vez e lê-se a doca com ele.
	var mais_longe_tex: Texture2D = null
	for motivo in ["pescado", "armazenagem", "granel"]:
		for e in range((consts["CAMINHOES"][motivo] as Array).size()):
			caminhao.texture = consts["CAMINHOES"][motivo][e]["mx_retorno"]
			doca.camiao_no_berco(tela.portas_do_camiao(caminhao) - doca.global_position)
			if is_equal_approx((doca.get("_destino_n3") as Vector2).length(), mais_longe):
				mais_longe_tex = caminhao.texture
	var leva: float = doca.get("_leva_n3")
	var volta: float = doca.get("_volta_n3")
	var esc: float = doca.get("_escala_n3")
	var ida_px: float = (doca.get("_destino_n3") as Vector2).length()
	var vel := ida_px / (leva * esc)
	_confere("D42: o caminho mais comprido (%.0f px) cabe no ciclo (%.2f + %.2f s de %.2f) sem ela passar do teto (%.0f px/s, ciclo x%.2f)"
			% [mais_longe, leva, volta, float(DockS.janela_n3()), vel, esc],
		mais_longe_tex != null and leva + volta <= float(DockS.janela_n3()) + 0.001
			and vel <= float(k["EMPILHADEIRA_PX_POR_SEG_MAX"]) + 0.01)
	# O tween dura o ciclo esticado: é ele que abranda o pórtico com ela. Um
	# segundo de relógio anda 1/escala de ciclo — com o tween a durar o ciclo
	# de sempre, andaria um segundo inteiro, e ela voltava a voar.
	var tw_c = doca.get("_tw_trabalho")
	var anda_ciclo := -1.0
	if tw_c is Tween and (tw_c as Tween).is_valid():
		var t_antes: float = doca.get("_t_n3")
		(tw_c as Tween).custom_step(1.0)
		anda_ciclo = fposmod(float(doca.get("_t_n3")) - t_antes, float(DockS.duracao_do_ciclo()))
	_confere("D42: com o caminho comprido o ciclo inteiro abranda (x%.2f: 1 s anda %.2f s de ciclo)"
			% [esc, anda_ciclo],
		esc > 1.0 and absf(anda_ciclo - 1.0 / esc) < 0.02)

	GS.docks[0]["boat"] = null
	GS.docks[0]["worker_id"] = null
	tela.call("_refresh_all")
	_confere("D42: o camião largou, e a doca deixou de o ter", doca.get("_camiao") == null)
	tela.queue_free()
	GS.estruturas = estruturas_antes


func _d42_ninguem_a_frente(GS: Node, DockS: Script, k: Dictionary) -> void:
	if GS.phase == "rival_offer":
		GS.resolve_rival_offer(true)
	var tweens_antes := {}
	for tw in get_processed_tweens():
		tweens_antes[tw] = true
	var estruturas_antes: Array = GS.estruturas.duplicate()
	var tela: Control = load(CENA).instantiate()
	root.add_child(tela)
	var consts: Dictionary = tela.get_script().get_script_constant_map()
	var acessos: Array = consts["ACESSOS_DOCA"]
	var cenario := tela.get_node("MapaWrap/Cenario")
	var estados := [["patio", "guindaste", "cais"],
		["armazem", "escritorio", "patio", "guindaste", "cais"]]
	var figura: Array = [k["QUADROS_EMPILHADEIRA"]["h"]["alto"], k["GARFO_N3"]["caixa"]["alto"]]
	var pior := 0
	var onde := ""
	var vistos := 0
	for estado in estados:
		GS.estruturas = estado
		while GS.docks.size() < acessos.size():
			GS.docks.append({"boat": null, "worker_id": null})
		for d in range(acessos.size()):
			for dd in GS.docks:
				dd["boat"] = null
				dd["worker_id"] = null
			var barco: Dictionary = GS._make_boat()
			barco["classe"] = "grande"
			barco["motivo"] = "armazenagem"
			barco["rival"] = false
			barco["progress"] = 0
			GS.docks[d]["boat"] = barco
			GS.docks[d]["worker_id"] = int(GS.workers[0]["id"])
			tela.call("_refresh_all")
			for tw in get_processed_tweens():
				if not tweens_antes.has(tw):
					tw.kill()
			var doca: Control = tela.get_node("MapaWrap/Docas/Doca%d" % d)
			var emp_base: Vector2 = doca.get("_emp_base")
			var espera: Vector2 = k["ESPERA_N3"]
			var caminhos := [["pilha", doca.get("_destino_n3")]]
			var caminhao := cenario.get_node("Caminhao0") as TextureRect
			var base: Vector2 = (tela.get("_base_do_caminhao") as Array)[0]
			var origem: Vector2 = (consts["CAMINHAO_ORIGENS"] as Array)[0]
			caminhao.position = base + tela.tela_da_rota(acessos[d]["paragem"], origem)
			caminhao.texture = consts["CAMINHOES"]["armazenagem"][0]["mx_retorno"]
			(tela.get("_ocupante_do_berco") as Array)[d] = caminhao
			tela.call("_encostou", d, int(barco["id"]))
			if doca.get("_camiao") != null:
				caminhos.append(["camião", doca.get("_destino_n3")])
			for c in caminhos:
				vistos += 1
				for i in range(21):
					var f := float(i) / 20.0
					var desloc: Vector2 = espera.lerp(Vector2.ZERO, minf(f * 3.0, 1.0)) \
						if f < 1.0 / 3.0 else (c[1] as Vector2) * ((f - 1.0 / 3.0) * 1.5)
					var canto: Vector2 = doca.position + emp_base + desloc
					var n := _d40_tapados(figura, canto, cenario, caminhao)
					if int(n[0]) > pior:
						pior = int(n[0])
						onde = "doca %d, %s, até %s, %d/20: %s" % [d, estado[0], c[0], i, n[1]]
			(tela.get("_ocupante_do_berco") as Array)[d] = null
			(tela.get("_visita_do_berco") as Array)[d] = -1
	_confere("D42: percorreu os caminhos das três docas nos dois estados (%d)" % vistos,
		vistos == 2 * 2 * acessos.size())
	_confere("D42: ela não se pinta por cima de prop do cenário que lhe está à frente (%d px; %s)"
			% [pior, onde if onde != "" else "nenhum"],
		pior <= D40_A_FRENTE_MAX,
		"as docas desenham-se por cima do cenário: ali ela aparece à frente do que a tapa")
	tela.queue_free()
	GS.estruturas = estruturas_antes
	for dd in GS.docks:
		dd["boat"] = null
		dd["worker_id"] = null


# ── D43 ── o rodapé escuro (`docs/decisoes/081`)
#
# A primeira passagem da melhoria de design do HUD, escolhida pelo Bruno em
# 04/10, mexeu em duas coisas que nenhuma guarda perguntava:
#
#  1. A LINHA DE BAIXO NAS COLUNAS DAS DOCAS. Eram os trabalhadores, e desde
#     a `083` são os três lugares da fila no fundeadouro: cada cartão ocupa a
#     coluna da doca de cima. Pergunta-se em ruínas e com o porto completo,
#     porque a barra das docas muda de cartões construídos para por construir
#     e a fila não pode mudar com ela.
#
#  2. O QUE SÓ INFORMA RECUA. No pixel da captura, o botão desligado media
#     12,99:1 contra o fundo do HUD, a faixa de mensagem 16,98 e o cartão da
#     parcela 17,60 — e o «AVANÇAR DIA», o único destaque da tela, 7,38. A
#     pergunta é de HIERARQUIA: cada uma destas superfícies, como se desenha
#     sobre o fundo, fica abaixo do primário.
#
# Os cartões dos TRABALHADORES entraram na segunda passagem (16,50:1 o livre,
# 13,43 o parado), e o Bruno pediu-os escuros; desde a `083` a linha é a fila,
# que veste os quatro cartões da doca, e são esses que se medem. A PLACA atrás
# do retrato fica de fora de propósito — é do tamanho do retrato.
#
# ⚠️ A guarda não diz que o primário se lê bem — diz que nada do que não é a
# ação principal lhe rouba o olho.
var _d43_completo := false


func _d43_rodape_escuro() -> void:
	var GS: Node = root.get_node("GameState")
	# 1 ── as colunas, com um trabalhador e com três
	for porto_completo in [false, true]:
		GS.clear_save()
		GS._rng.seed = 20261004
		GS.new_game()
		if GS.phase == "rival_offer":
			GS.resolve_rival_offer(true)
		if porto_completo:
			var tabela: Dictionary = GS.ESTRUTURAS
			for e in tabela:
				GS.cash += int(tabela[e]["custo"])
			var ids: Array = tabela.keys()
			ids.sort_custom(func(a, b): return int(tabela[a]["ordem"]) < int(tabela[b]["ordem"]))
			for e in ids:
				load("res://tools/estado_da_bancada.gd").instalar(GS, e)
		var tela: Control = load(CENA).instantiate()
		root.add_child(tela)
		var barra := tela.get_node("BarraDocas") as HBoxContainer
		# ⚠️ DESDE A `083` A LINHA DE BAIXO É A FILA, e não os trabalhadores: os
		# três lugares do fundeadouro, um por coluna, em ruínas ou completo.
		var linha := tela.get_node("Fila") as HBoxContainer
		# Os contentores arrumam-se no frame seguinte, e esta suíte não deixa
		# passar nenhum: a ordem de arrumar é dada aqui, à mão.
		barra.notification(Container.NOTIFICATION_SORT_CHILDREN)
		linha.notification(Container.NOTIFICATION_SORT_CHILDREN)
		var docas: Array = barra.get_children()
		var cartoes: Array = linha.get_children()
		var n: int = cartoes.size()
		_confere("D43: a fila tem os %d lugares do fundeadouro" % int(GS.FILA_LUGARES),
			n == int(GS.FILA_LUGARES), "%d cartões" % n)
		var fora: Array = []
		for i in range(mini(cartoes.size(), docas.size())):
			var c := cartoes[i] as Control
			var d := docas[i] as Control
			if absf(c.global_position.x - d.global_position.x) > 0.5 \
					or absf(c.size.x - d.size.x) > 0.5:
				fora.append("#%d em x=%.0f larg %.0f, doca em x=%.0f larg %.0f" % [
					i + 1, c.global_position.x, c.size.x, d.global_position.x, d.size.x])
		_confere("D43: %s, cada lugar da fila ocupa a coluna da doca de cima"
			% ("porto completo" if porto_completo else "em ruínas"),
			fora.is_empty() and not cartoes.is_empty(), "; ".join(fora))
		if porto_completo:
			_d43_o_que_recua(tela)
		root.remove_child(tela)
		tela.free()
	_d43_completo = true


# A cor que uma superfície DESENHA sobre o fundo da tela: o stylebox chapado
# composto pelo alfa dele. Um stylebox vazio não desenha nada, e é o fundo.
func _d43_desenhada(caixa: StyleBox, fundo: Color) -> Color:
	var chapada := caixa as StyleBoxFlat
	if chapada == null:
		return fundo
	var cor: Color = fundo.lerp(chapada.bg_color, chapada.bg_color.a)
	cor.a = 1.0
	return cor


# 2 ── o que só informa fica abaixo do primário
func _d43_o_que_recua(tela: Control) -> void:
	var fundo: Color = (tela.get_node("Fundo") as ColorRect).color
	var avancar := tela.get_node("AcoesTurno/Avancar") as Button
	var teto := _contraste(_d43_desenhada(avancar.get_theme_stylebox("normal"), fundo), fundo)
	_confere("D43: o primário destaca-se do fundo (%.2f:1)" % teto, teto >= 3.0)
	var medidas: Array = []
	for caminho in ["LinhaConstruir/Upgrade", "LinhaConstruir/Menu",
			"AcoesTurno/Avancar"]:
		var b := tela.get_node(caminho) as Button
		medidas.append(["%s desligado" % caminho.get_file(),
			_d43_desenhada(b.get_theme_stylebox("disabled"), fundo)])
	for caminho in ["MensagemCartao", "MetaCartao"]:
		var p := tela.get_node(caminho) as PanelContainer
		medidas.append([caminho, _d43_desenhada(p.get_theme_stylebox("panel"), fundo)])
	# Os quatro estados do cartão da fila pelo TEMA, e não pelos cartões
	# montados: o porto desta medição só mostra um estado de cada vez. Três são
	# os da doca, que o `BarcoFila` veste (`083`); o lugar livre é o vazio, sem
	# fundo, que recua por construção.
	var tema: Theme = load("res://ui/tema_brport.tres")
	for variacao in ["CartaoDoca", "CartaoDocaEspera", "CartaoDocaRival",
			"CartaoFilaVazia"]:
		medidas.append(["o cartão %s" % variacao,
			_d43_desenhada(tema.get_stylebox("panel", variacao), fundo)])
	for m in medidas:
		var razao := _contraste(m[1] as Color, fundo)
		_confere("D43: %s recua — %.2f:1 contra o fundo, abaixo dos %.2f do «AVANÇAR DIA»"
			% [m[0], razao, teto], razao < teto)


# ── D44 ── as conversas dos cartões (`docs/decisoes/082`)
#
# A segunda parte da melhoria de design, escolhida pelo Bruno em 04/10, pôs os
# três cartões de conversa — o Sr. Ribeiro na parcela, o Arlindo na disputa, a
# Dona Cida no boletim — a falar como no celular: o balão de quem fala, o
# retrato numa placa do mesmo matiz, a fala em letra regular e a fala longa
# partida em balões. Nada perguntava nenhuma destas coisas:
#
#  1. O BALÃO E A PLACA TÊM O MATIZ DA ROUPA DE QUEM FALA, com o esperado lido
#     do PNG do retrato pela régua do D38 — não do código que escolhe a
#     variação, que é onde o defeito moraria. O D38 pergunta-o ao celular, e
#     o andaime partilha com ele o `_vestir_balao()`; o que só este bloco vê é
#     o PAINEL a passar a pessoa errada e a PLACA trocada, que o celular não
#     tem.
#  2. A FALA É MAIS LEVE DO QUE O TÍTULO do mesmo cartão, pelo peso da letra
#     que cada rótulo resolve. Sem a fonte na variação a fala cai no
#     seminegrito padrão, e os dois pesam 600.
#  3. A FALA LONGA SAI EM BALÕES: na cobrança do Sr. Ribeiro, que tem dois
#     parágrafos, dois balões — o primeiro com o bico, o seguido sem ele — e
#     nenhum vazio. Com a fala inteira num balão só os textos continuam certos
#     (o F17 compara-os e passa), e é por isso que a pergunta é pela FORMA.
var _d44_completo := false


func _d44_conversas_dos_cartoes() -> void:
	var GS: Node = root.get_node("GameState")
	var motor = load("res://scripts/validation/contraste_ui.gd").new()
	var tema: Theme = load("res://ui/tema_brport.tres")
	var Nar = load("res://scripts/Narrativa.gd")
	var omissao: Dictionary = load("res://scripts/PainelMensagens.gd") \
		.get_script_constant_map()["CARA_DE_OMISSAO"]
	var roupa := {}
	for quem in omissao:
		roupa[quem] = _d38_roupa(Nar.retrato(quem, String(omissao[quem])))
	# Os casos do D33, pelo nome: o mesmo estado que a régua do contraste
	# monta, e não um segundo jeito de montar a mesma cena.
	var casos := {"Ribeiro (NÃO pode pagar)": ["ribeiro", 2],
		"Contra-oferta": ["arlindo", 1], "Boletim": ["cida", 1]}
	var vistos := 0
	for caso in motor.percurso():
		if not casos.has(String(caso["nome"])):
			continue
		var quem: String = casos[caso["nome"]][0]
		var paragrafos: int = casos[caso["nome"]][1]
		var no: Node = motor.montar_caso(root, GS, caso, tema)
		_confere("D44: %s montou" % caso["nome"], no != null, "; ".join(motor.falhas))
		if no == null:
			continue
		vistos += 1
		_d44_um_cartao(no, quem, paragrafos, roupa)
		no.get_parent().remove_child(no)
		no.free()
	_confere("D44: mediu os três cartões de conversa (%d)" % vistos, vistos == casos.size())
	_d44_completo = true


func _d44_um_cartao(no: Node, quem: String, paragrafos: int, roupa: Dictionary) -> void:
	var retrato: TextureRect = null
	for img in no.find_children("*", "TextureRect", true, false):
		var t: Texture2D = (img as TextureRect).texture
		if t != null and t.resource_path.get_file().begins_with("retrato_%s" % quem):
			retrato = img
	_confere("D44 %s: o cartão mostra o retrato de quem fala" % quem, retrato != null)
	if retrato == null:
		return
	var placa := retrato.get_parent() as PanelContainer
	var linha := placa.get_parent() if placa != null else null
	_confere("D44 %s: o retrato senta numa placa" % quem, placa != null and linha != null)
	if placa == null or linha == null:
		return
	var baloes: Array = []
	for p in linha.find_children("*", "PanelContainer", true, false):
		if p != placa and p.get_child_count() > 0 and p.get_child(0) is Label \
				and (p as Control).is_visible_in_tree():
			baloes.append(p)

	# 1. o balão e a placa, contra a roupa do retrato
	var pecas: Array = [["a placa", placa]]
	for b in baloes:
		pecas.append(["o balão «%s»" % ((b as Node).get_child(0) as Label).text.left(24), b])
	for par in pecas:
		var estilo := (par[1] as Control).get_theme_stylebox("panel") as StyleBoxFlat
		if estilo == null:
			_confere("D44 %s: %s tem fundo" % [quem, par[0]], false)
			continue
		var h: float = estilo.bg_color.h
		var mais_perto := ""
		var menor := 999.0
		for outro in roupa:
			var d: float = _d38_distancia_de_matiz(h, (roupa[outro] as Color).h)
			if d < menor:
				menor = d
				mais_perto = outro
		_confere("D44 %s: %s tem o matiz da roupa de quem fala (%.0f°, roupa %.0f°)"
			% [quem, par[0], h * 360.0, (roupa[quem] as Color).h * 360.0],
			mais_perto == quem, "o matiz mais perto é o da roupa de %s" % mais_perto)

	# 2. a fala mais leve do que o título
	var titulo: Label = null
	for r in no.find_children("*", "Label", true, false):
		if (r as Label).theme_type_variation == &"TituloNarrativo":
			titulo = r
	_confere("D44 %s: o cartão tem título" % quem, titulo != null)
	if titulo != null and not baloes.is_empty():
		var peso_titulo: int = titulo.get_theme_font("font").get_font_weight()
		for b in baloes:
			var fala := (b as Node).get_child(0) as Label
			var peso: int = fala.get_theme_font("font").get_font_weight()
			_confere("D44 %s: a fala pesa %d, menos do que os %d do título"
				% [quem, peso, peso_titulo], peso < peso_titulo)

	# 3. um balão por parágrafo, o primeiro com bico, nenhum vazio
	var com_bico := 0
	var vazios := 0
	for b in baloes:
		var estilo := (b as Control).get_theme_stylebox("panel") as StyleBoxFlat
		if estilo != null and estilo.corner_radius_top_left < estilo.corner_radius_top_right:
			com_bico += 1
		if ((b as Node).get_child(0) as Label).text.strip_edges() == "":
			vazios += 1
	_confere("D44 %s: %d balão(ões) para %d parágrafo(s), só o primeiro com bico, nenhum vazio"
		% [quem, baloes.size(), paragrafos],
		baloes.size() == paragrafos and com_bico == 1 and vazios == 0,
		"%d com bico, %d vazios" % [com_bico, vazios])
