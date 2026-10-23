class_name AcomodacaoDoPorto
extends RefCounted

# A composição de três colunas aprovada na bancada. Os nós continuam vivos:
# mudar a preferência não atraca barcos, não recria cartões e não avança o dia.
const BLOCOS := ["BarraDocas", "FilaTitulo", "Fila", "MensagemCartao", "MetaCartao"]
const GEOMETRIA := ["anchor_left", "anchor_top", "anchor_right", "anchor_bottom",
	"offset_left", "offset_top", "offset_right", "offset_bottom", "custom_minimum_size",
	"size_flags_horizontal", "size_flags_vertical"]
var _tela: Control
var _nos := {}
var _originais := {}
var _valores: Array[Label] = []
var _rolo: RolagemDaOperacao
var _indicacao: Label
var _maior := false
var _separacao_hud := 0


func _init(tela: Control) -> void:
	_tela = tela
	_separacao_hud = tela.get_node("HudBar").get_theme_constant("separation")
	for nome in BLOCOS + ["HudBar", "LinhaConstruir", "AcoesTurno"]:
		var no: Control = tela.get_node(nome)
		_nos[nome] = no
		_guardar(no)
	for nome in ["BarraDocas", "Fila"]:
		for cartao in _nos[nome].get_children():
			_guardar(cartao)
			var valor: Label = cartao.get_node("Coluna/Cabecalho/Valor")
			_valores.append(valor)
			_guardar(valor)
			for no in TextoDaInterface.descendentes(cartao):
				if no is Label:
					_guardar(no)
			valor.minimum_size_changed.connect(_atualizar_valores)


func _guardar(no: Control) -> void:
	if _originais.has(no):
		return
	var valores := {"pai": no.get_parent(), "indice": no.get_index()}
	for propriedade in GEOMETRIA:
		valores[propriedade] = no.get(propriedade)
	if no is Label:
		for propriedade in ["autowrap_mode", "horizontal_alignment", "visible"]:
			valores[propriedade] = no.get(propriedade)
	_originais[no] = valores


func aplicar(maior: bool) -> void:
	if maior == _maior:
		return
	_maior = maior
	if not maior:
		_restaurar()
		return
	_rolo = RolagemDaOperacao.new()
	_rolo.name = "OperacaoRolavel"
	_tela.add_child(_rolo)
	_rolo.position = Vector2(14, 762)
	_rolo.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_rolo.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_ALWAYS
	var coluna := VBoxContainer.new()
	coluna.name = "Conteudo"
	coluna.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	coluna.add_theme_constant_override("separation", 8)
	_rolo.add_child(coluna)
	_indicacao = Label.new()
	_indicacao.name = "IndicacaoDeRolagem"
	_indicacao.text = "Docas, fila e cobrança — deslize para ver mais"
	_indicacao.theme_type_variation = &"TextoDocaProgresso"
	# O tema padrão desta variação herda 15; a proposta aprovada usou base 13.
	_indicacao.add_theme_font_size_override("font_size", 13)
	_tela.add_child(_indicacao)
	_indicacao.position = Vector2(14, 728)
	_indicacao.size = Vector2(692, 28)
	for nome in BLOCOS:
		var no: Control = _nos[nome]
		no.reparent(coluna, false)
		no.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
		no.custom_minimum_size = Vector2.ZERO
		no.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		no.size_flags_vertical = Control.SIZE_FILL
	for nome in ["BarraDocas", "Fila"]:
		for cartao in _nos[nome].get_children():
			cartao.custom_minimum_size = Vector2(0, 44)
			for no in TextoDaInterface.descendentes(cartao):
				if no is Label:
					no.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
					no.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			var valor: Label = cartao.get_node("Coluna/Cabecalho/Valor")
			var conteudo: VBoxContainer = cartao.get_node("Coluna")
			valor.reparent(conteudo, false)
			conteudo.move_child(valor, 1 if nome == "BarraDocas" else 2)
			valor.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_atualizar_valores()
	var hud: HBoxContainer = _nos["HudBar"]
	hud.add_theme_constant_override("separation", 4)
	for pilula in hud.get_children():
		if pilula is PanelContainer:
			var estilo: StyleBox = pilula.get_theme_stylebox("panel").duplicate()
			estilo.content_margin_left = 4
			estilo.content_margin_right = 4
			pilula.add_theme_stylebox_override("panel", estilo)
	var construir: Control = _nos["LinhaConstruir"]
	var turno: Control = _nos["AcoesTurno"]
	var altura_turno := maxf(58, turno.get_child(0).get_combined_minimum_size().y + 4)
	var altura_construir := maxf(46, construir.get_combined_minimum_size().y + 4)
	turno.position = Vector2(14, 1265 - altura_turno)
	turno.size = Vector2(692, altura_turno)
	construir.position = Vector2(14, turno.position.y - 6 - altura_construir)
	construir.size = Vector2(692, altura_construir)
	_rolo.size = Vector2(692, construir.position.y - 8 - _rolo.position.y)


func _atualizar_valores() -> void:
	if _maior:
		for valor in _valores:
			valor.visible = not valor.text.is_empty()


func _restaurar() -> void:
	# Primeiro os pais: um cartão não deve ser restaurado dentro de um rolo
	# que vai embora. A ordem do dicionário é a ordem em que foram guardados.
	for no in _originais:
		var original: Dictionary = _originais[no]
		if no.get_parent() != original.pai:
			no.reparent(original.pai, false)
			original.pai.move_child(no, original.indice)
		for propriedade in original:
			if propriedade not in ["pai", "indice"]:
				no.set(propriedade, original[propriedade])
	var hud: HBoxContainer = _nos["HudBar"]
	hud.remove_theme_constant_override("separation")
	for pilula in hud.get_children():
		if pilula is PanelContainer:
			pilula.remove_theme_stylebox_override("panel")
	# A separação original é um override da cena, não a do tema.
	hud.add_theme_constant_override("separation", _separacao_hud)
	_rolo.queue_free()
	_indicacao.queue_free()
	_rolo = null
	_indicacao = null
