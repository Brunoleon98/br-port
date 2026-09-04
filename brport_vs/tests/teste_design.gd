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

# O quadro de todo prop isométrico tem 512 e o centro dele é a origem do
# mundo (ver `para_pixel` em tools/gerar_props_iso.py).
const MEIO_QUADRO := 256.0

# Meia célula do chão. Mais que isto e o prop já se lê deslocado do desenho.
const TOLERANCIA_PX := 2.0

# Onde o caminhão é DESENHADO dentro do quadro de 512, relativo ao ponto de
# ancoragem — medido no alfa dos dois PNGs e unido, que é o pior caso de cada
# lado. O quadro inteiro tem 512px e o desenho ocupa ~94x86 no meio dele:
# perguntar se o QUADRO saiu do mapa daria "ainda dentro" com o caminhão já
# invisível havia muito.
const DESENHO_CAMINHAO := Rect2(-38, -46, 100, 86)

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
	print("=== D7: os letreiros pousam no que nomeiam ===")
	_d7_letreiros()
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

	root.remove_child(_main)
	_main.free()

	print("")
	if _falhas == 0:
		print("=== DESIGN OK — tudo no lugar ===")
		quit(0)
	else:
		print("=== %d PROBLEMA(S) DE DESIGN ===" % _falhas)
		quit(1)


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
const LARGURA_DE_TELHADO := 78.0     # px, medido: (VILA_PROF + 0.24 + 1.0) * 30

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
		var usado := tex.get_image().get_used_rect()
		if float(usado.size.x) < SILHUETA_QUE_EXIGE_PEGADA:
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
		"nenhum prop passou de %.0fpx — o filtro comeu tudo" % SILHUETA_QUE_EXIGE_PEGADA)

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
		_confere("no degrau my=%s a fileira de trás sai de trás da da frente"
			% [faixa["my"]],
			separacao > LARGURA_DE_TELHADO,
			"%.0fpx de separação para um telhado de %.0fpx — as duas fileiras "
			% [separacao, LARGURA_DE_TELHADO] + "leem como um borrão de telha")

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
const PODEM_PISAR_A_RUA := ["Caminhao", "ConeTransito"]
const VIVEM_NA_AGUA := ["BarcoEspera", "Ancoragem", "Bote"]

# Acima disto a âncora deixa de responder pelo prop e a pegada passa a ser
# obrigatória. Medido: o escritório tem 213px de silhueta e o armazém 258; o
# maior prop sem pegada é a copa do coqueiro, com 118.
const SILHUETA_QUE_EXIGE_PEGADA := 130.0


func _d2_cenario_em_terra() -> void:
	var cenario := _main.get_node("MapaWrap/Cenario")
	var pegadas: Dictionary = _ancoras.get("pegadas", {})
	var alt := float(_ancoras["projecao"]["alt_cais"])
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
			var larg := float(tex.get_image().get_used_rect().size.x)
			_confere("%s tem pegada declarada" % nome,
				larg < SILHUETA_QUE_EXIGE_PEGADA,
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
	var pilha := ["MapaWrap", "BarraDocas", "TrabalhadoresTitulo", "Trabalhadores",
		"MensagemCartao", "MetaCartao", "Upgrade", "AcoesTurno"]
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
	alvos.append(_main.get_node("Upgrade"))
	alvos.append(_main.get_node("HudBar/Pausar"))
	for c in _main.get_node("BarraDocas").get_children():
		alvos.append(c)
	for c in alvos:
		_confere("%s cabe no dedo (%.0fx%.0f)" % [c.name, c.size.x, c.size.y],
			c.size.y >= TOQUE_MIN and c.size.x >= TOQUE_MIN,
			"mínimo é %.0f em cada lado" % TOQUE_MIN)


# ── D7 ── placa que nomeia um prédio tem de tocar o prédio
func _d7_letreiros() -> void:
	var pares := {"LetreiroArmazem": "Armazem", "LetreiroEscritorio": "Escritorio"}
	var cenario := _main.get_node("MapaWrap/Cenario")
	for letreiro in pares:
		var l := _main.get_node_or_null("MapaWrap/Letreiros/%s" % letreiro) as Control
		var predio := cenario.get_node_or_null(String(pares[letreiro])) as TextureRect
		if l == null or predio == null:
			_confere("%s e %s existem" % [letreiro, pares[letreiro]], false)
			continue
		var mastro := l.get_node_or_null("Mastro") as Control
		if mastro == null:
			_confere("%s tem mastro" % letreiro, false)
			continue
		# O pé do mastro tem de cair dentro do quadro do prédio nos DOIS
		# estados (ruína e pronto), senão a placa flutua quando o jogador
		# conserta. O quadro é o mesmo nos dois — é a regra do projeto.
		var pe := _no_mapa(l) + mastro.position + Vector2(mastro.size.x / 2.0, mastro.size.y)
		var quadro := Rect2(_no_mapa(predio), predio.size)
		_confere("%s apoiado em %s" % [letreiro, pares[letreiro]],
			quadro.has_point(pe), "pé em %s, quadro do prédio %s" % [pe, quadro])


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
	_confere("e o convite está na cor de aviso",
		rotulo.get_theme_color("font_color").is_equal_approx(COR_AVISO))

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
	var caminhao: Control = cenario.get_node("Caminhao")
	var pr: Dictionary = _ancoras["projecao"]
	var alt := float(pr["alt_cais"])
	var consts: Dictionary = tela.get_script().get_script_constant_map()
	var rota: Array = consts["ROTA_ESTRADA"]
	var origem_rota: Vector2 = consts["CAMINHAO_ORIGEM"]

	# Zero: a projeção que o `Main.gd` usa para andar é a MESMA do mapa. Ele
	# repete `MEIA_LARG`/`MEIA_ALT` porque roda dentro do jogo e não lê o JSON;
	# repetição sem esta asserção é o contrato a divergir calado.
	_confere("o caminhão anda na projeção do mapa (%.0f x %.0f)"
			% [float(consts["MEIA_LARG"]), float(consts["MEIA_ALT"])],
		is_equal_approx(float(consts["MEIA_LARG"]), float(pr["meia_larg"]))
			and is_equal_approx(float(consts["MEIA_ALT"]), float(pr["meia_alt"])))

	_confere("a rota tem os oito pontos da escada", rota.size() == 8,
		"tem %d" % rota.size())

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

	# ── 2 ── as duas pontas ficam FORA do quadro visível.
	#
	# Fora não é "o ponto de ancoragem fora": é o desenho todo fora. O quadro
	# do prop tem 512px e o caminhão ocupa um retângulo pequeno lá dentro, e é
	# esse que se mede — pelo ponto de ancoragem o caminhão sairia meio dentro.
	var janela := (tela.get_node("MapaWrap") as Control).size
	var base := caminhao.position - _tela_da_rota(origem_rota, origem_rota, pr)
	for ponta in [[0, "a entrada"], [rota.size() - 1, "a saída"]]:
		var idx: int = ponta[0]
		var pos: Vector2 = base + _tela_da_rota(rota[idx], origem_rota, pr) \
			+ Vector2(MEIO_QUADRO, MEIO_QUADRO)
		var caixa := Rect2(pos + DESENHO_CAMINHAO.position, DESENHO_CAMINHAO.size)
		var visivel := Rect2(Vector2.ZERO, janela)
		_confere("%s do caminhão está fora do quadro" % ponta[1],
			not visivel.intersects(caixa),
			"o desenho fica em %s e o mapa é %s" % [caixa, visivel])

	# E o contrário para onde a CENA o põe: aí ele tem de estar inteiro
	# dentro, senão as cinco capturas do CI apanham-no cortado ao meio.
	var na_cena := Rect2(caminhao.position + Vector2(MEIO_QUADRO, MEIO_QUADRO)
		+ DESENHO_CAMINHAO.position, DESENHO_CAMINHAO.size)
	_confere("e onde a cena o põe ele está inteiro dentro",
		Rect2(Vector2.ZERO, janela).encloses(na_cena),
		"o desenho fica em %s" % na_cena)

	# E a cena tem de o pôr num ponto DA rota, não ao lado dela.
	var m_cena := _mundo(_origem(caminhao), alt)
	_confere("a cena põe-no no ponto de partida da rota",
		m_cena.distance_to(origem_rota) < 0.02,
		"está em (%.2f, %.2f) e devia estar em (%.2f, %.2f)"
			% [m_cena.x, m_cena.y, origem_rota.x, origem_rota.y])

	# ── 3 ── a silhueta certa por trecho. Trecho que anda em `mx` usa o sprite
	# de `mx`; trecho que anda em `my`, o de `my`. Um só sprite para os dois
	# eixos foi a primeira versão, e o caminhão virava de lado nos cotovelos.
	#
	# E a pergunta é feita a QUEM DECIDE — `silhueta_do_trecho()` —, não
	# recalculada aqui. A primeira versão deste bloco recalculava, e por isso
	# não reprovou quando se pôs a mesma silhueta nos oito trechos: o teste
	# estava a concordar consigo próprio.
	var errado := ""
	var vistas := {}
	for i in range(rota.size() - 1):
		var de: Vector2 = rota[i]
		var para: Vector2 = rota[i + 1]
		var anda_em_mx: bool = abs(para.x - de.x) > 0.01
		var usada: Texture2D = tela.call("silhueta_do_trecho", de, para)
		var caminho: String = usada.resource_path
		vistas[caminho] = true
		if anda_em_mx != caminho.ends_with("caminhao_mx.png") and errado == "":
			errado = "o trecho %d anda em %s e usa %s" \
				% [i, "mx" if anda_em_mx else "my", caminho.get_file()]
	_confere("cada trecho usa a silhueta do eixo em que anda", errado == "", errado)
	_confere("e as duas silhuetas entram em campo", vistas.size() == 2,
		"só se viu %s" % str(vistas.keys()))

	# ── 4 ── a reordenação. Ordem de irmão É profundidade neste plano, e a
	# travessia atravessa a profundidade de meia cena: índice fixo estaria
	# certo num sítio e errado no outro.
	var pos_antes := caminhao.position
	var indice_antes := caminhao.get_index()
	caminhao.position = base + _tela_da_rota(rota[rota.size() - 1], origem_rota, pr)
	tela.call("_ordenar_por_profundidade", caminhao)
	var indice_depois := caminhao.get_index()
	_confere("no fim da travessia ele já mudou de ordem entre os irmãos",
		indice_depois > indice_antes,
		"ficou no índice %d, e começou no %d" % [indice_depois, indice_antes])
	var erro_ordem := ""
	for i in range(cenario.get_child_count()):
		var outro := cenario.get_child(i) as Control
		if outro == null or outro == caminhao:
			continue
		if outro.position.y < caminhao.position.y and i > indice_depois and erro_ordem == "":
			erro_ordem = "%s está acima na tela mas depois na ordem" % outro.name
	_confere("e no lugar certo da fila de profundidade", erro_ordem == "", erro_ordem)

	caminhao.position = pos_antes
	tela.call("_ordenar_por_profundidade", caminhao)
	_d13_completo = true


# O mesmo `tela_da_rota()` do `Main.gd`, mas com a projeção vinda das ÂNCORAS.
# Escrito à mão de propósito: chamar o do jogo faria o teste medir a rota com a
# mesma conta que quer conferir, e uma projeção errada passaria dos dois lados.
func _tela_da_rota(ponto: Vector2, origem: Vector2, pr: Dictionary) -> Vector2:
	var d := ponto - origem
	return Vector2((d.x - d.y) * float(pr["meia_larg"]),
		(d.x + d.y) * float(pr["meia_alt"]))
