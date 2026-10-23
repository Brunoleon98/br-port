extends "res://tools/bancada_texto.gd"

# Propostas de acomodação do RB5, apenas por --script. Reorganiza as
# instâncias reais sem editar Main.tscn, cartões, fontes-base ou preferências.
# O mapa e os callbacks do jogo ficam com seus nós e medidas originais.
var _rolagem_proposta: ScrollContainer
var _blocos: Dictionary = {}
var _proposta := "colunas"
var _apoio_estado: RefCounted
var _estado_antes: Dictionary
var _mapa_antes: Rect2


func _montar() -> void:
	await super._montar()
	if _cenario not in ["hud", "doca"]:
		return
	_apoio_estado = load("res://tests/casos_meu_porto.gd").new()
	_apoio_estado.gs = _gs
	_apoio_estado.arvore = self
	_estado_antes = _apoio_estado.fotografia()
	_mapa_antes = _tela.get_node("MapaWrap").get_global_rect()
	var args := OS.get_cmdline_user_args()
	if args.size() > 4:
		_proposta = args[4]
	if _proposta not in ["colunas", "lista"]:
		push_error("proposta desconhecida na bancada de acomodação")
		quit(1)
		return
	for nome in ["HudBar", "MapaWrap", "BarraDocas", "FilaTitulo", "Fila", "MensagemCartao", "MetaCartao", "LinhaConstruir", "AcoesTurno"]:
		_blocos[nome] = _tela.get_node(nome)
	# As quatro pílulas mantêm ícones, cores e texto. Menos margem interna
	# conserva também o botão Pausar no quadro com a letra de +50%.
	var hud: HBoxContainer = _blocos["HudBar"]
	hud.add_theme_constant_override("separation", 4)
	for pilula in hud.get_children():
		if pilula is PanelContainer:
			var estilo: StyleBox = pilula.get_theme_stylebox("panel").duplicate()
			estilo.content_margin_left = 4
			estilo.content_margin_right = 4
			pilula.add_theme_stylebox_override("panel", estilo)
	for no in hud.get_children():
		_blocos["HudBar/" + String(no.name)] = no
	for no in _blocos["LinhaConstruir"].get_children():
		_blocos["LinhaConstruir/" + String(no.name)] = no
	_blocos["AcoesTurno/Avancar"] = _tela.get_node("AcoesTurno/Avancar")
	_rolagem_proposta = ScrollContainer.new()
	_rolagem_proposta.name = "OperacaoRolavel"
	_rolagem_proposta.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_rolagem_proposta.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_ALWAYS
	_tela.add_child(_rolagem_proposta)
	_rolagem_proposta.position = Vector2(14, 762)
	_rolagem_proposta.size = Vector2(692, 344)
	var coluna := VBoxContainer.new()
	coluna.name = "Conteudo"
	coluna.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	coluna.add_theme_constant_override("separation", 8)
	_rolagem_proposta.add_child(coluna)
	var indicacao := Label.new()
	indicacao.name = "IndicacaoDeRolagem"
	indicacao.text = "Docas, fila e cobrança — deslize para ver mais"
	indicacao.theme_type_variation = &"TextoDocaProgresso"
	indicacao.add_theme_font_size_override("font_size", 13)
	_tela.add_child(indicacao)
	indicacao.position = Vector2(14, 728)
	indicacao.size = Vector2(692, 28)
	for nome in ["BarraDocas", "FilaTitulo", "Fila", "MensagemCartao", "MetaCartao"]:
		var no: Control = _blocos[nome]
		no.reparent(coluna, false)
		no.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
		no.custom_minimum_size = Vector2.ZERO
		no.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		no.size_flags_vertical = Control.SIZE_FILL
	for nome in ["BarraDocas", "Fila"]:
		var faixa: HBoxContainer = _blocos[nome]
		var cartoes := faixa.get_children()
		var destino: Container = faixa
		if _proposta == "lista":
			var lista := VBoxContainer.new()
			lista.name = "Lista"
			lista.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			lista.add_theme_constant_override("separation", 8)
			faixa.add_child(lista)
			destino = lista
		for cartao in cartoes:
			if destino != faixa:
				cartao.reparent(destino, false)
			cartao.custom_minimum_size = Vector2(0, 44)
			cartao.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			if _proposta == "colunas":
				# O valor ganha linha própria: deixa de disputar largura com
				# o retrato/nome. Todos os textos e a arte continuam presentes.
				var valor: Label = cartao.get_node("Coluna/Cabecalho/Valor")
				var conteudo: VBoxContainer = cartao.get_node("Coluna")
				# Um valor vazio fica no cabeçalho, como no jogo: deslocá-lo
				# criava uma linha em branco do tamanho da letra ampliada.
				if not valor.text.is_empty():
					valor.reparent(conteudo, false)
					conteudo.move_child(valor, 1 if nome == "BarraDocas" else 2)
					valor.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
			for no in _descendentes(cartao):
				if no is Label:
					no.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
					no.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	# As ações ficam fora da rolagem. A altura deriva da fonte e do estilo
	# efetivos do botão; folga fixa excessiva só tirava espaço da leitura.
	var construir: Control = _blocos["LinhaConstruir"]
	var turno: Control = _blocos["AcoesTurno"]
	var altura_turno := maxf(58, _altura_botao(turno.get_child(0)) + 4)
	var altura_construir := 46.0
	for botao in construir.get_children():
		altura_construir = maxf(altura_construir, _altura_botao(botao) + 4)
	turno.position = Vector2(14, 1265 - altura_turno)
	turno.size = Vector2(692, altura_turno)
	construir.position = Vector2(14, turno.position.y - 6 - altura_construir)
	construir.size = Vector2(692, altura_construir)
	_rolagem_proposta.size.y = construir.position.y - 8 - _rolagem_proposta.position.y
	await _esperar(8)


func _altura_botao(botao: Button) -> float:
	var letra := 0.0
	if not botao.text.is_empty():
		var fonte := botao.get_theme_font("font")
		var tamanho := roundi(botao.get_theme_font_size("font_size") * _fator)
		letra = ceilf(fonte.get_height(tamanho))
	var icone := 24.0 if botao.icon != null else 0.0
	return maxf(letra, icone) + botao.get_theme_stylebox("normal").get_minimum_size().y


func _areas() -> Array:
	if _blocos.is_empty():
		return super._areas()
	var areas: Array = []
	for nome in _blocos:
		var no: Control = _blocos[nome]
		areas.append({"no": nome, "posicao": [no.global_position.x, no.global_position.y],
			"tamanho": [no.size.x, no.size.y],
			"minimo": [no.get_combined_minimum_size().x, no.get_combined_minimum_size().y]})
	var barra := _rolagem_proposta.get_v_scroll_bar()
	areas.append({"no": "OperacaoRolavel", "proposta": _proposta,
		"posicao": [14, 762], "tamanho": [692, _rolagem_proposta.size.y],
		"conteudo": barra.max_value, "pagina": barra.page,
		"curso": maxf(0, barra.max_value - barra.page),
		"estado_igual_antes_de_acomodar": _estado_antes == _apoio_estado.fotografia(),
		"mapa_mesmo_retangulo": _mapa_antes == (_blocos["MapaWrap"] as Control).get_global_rect()})
	return areas


func _salvar(caminho: String) -> void:
	await super._salvar(caminho)
	if _rolagem_proposta == null:
		return
	_rolagem_proposta.scroll_vertical = int(_rolagem_proposta.get_v_scroll_bar().max_value)
	await _esperar(8)
	await super._salvar(caminho.trim_suffix(".png") + "_fim.png")
	_rolagem_proposta.scroll_vertical = 0
	await _esperar(8)
