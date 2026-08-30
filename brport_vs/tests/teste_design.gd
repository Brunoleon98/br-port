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

var _falhas := 0
var _feito := false
var _ancoras: Dictionary
var _main: Control


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
func _d2_cenario_em_terra() -> void:
	var cenario := _main.get_node("MapaWrap/Cenario")
	for no in cenario.get_children():
		var nome := String(no.name)
		if not (nome.begins_with("Coqueiro") and nome.ends_with("Tronco")):
			continue
		var base := _origem(no as Control)
		var m := _mundo(base, float(_ancoras["projecao"]["alt_cais"]))
		var faixa := _faixa_de(m.y)
		var rua: Array = faixa["rua"]
		var na_rua: bool = float(rua[0]) <= m.x and m.x <= float(rua[1])
		_confere("%s fora do asfalto" % nome, not na_rua,
			"base em mx=%.2f, e a rua ocupa %.2f..%.2f neste degrau"
			% [m.x, float(rua[0]), float(rua[1])])
		var borda := float(faixa["borda"])
		_confere("%s em terra" % nome, m.x <= borda + 0.1,
			"mx=%.2f passa da beira do cais (%.2f)" % [m.x, borda])


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
