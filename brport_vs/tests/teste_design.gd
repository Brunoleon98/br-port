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
#   2. quem tem pegada declarada em `porto_mapa_ancoras.json` responde pelos
#      QUATRO cantos dela, e em cada degrau que a pegada toca (um prédio pode
#      atravessar o salto da costa, onde a rua anda 4 unidades de uma vez);
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
