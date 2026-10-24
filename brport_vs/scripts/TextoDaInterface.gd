class_name TextoDaInterface
extends RefCounted

# Uma instância pertence à tela que a montou, sem autoload e sem remontar a
# partida. O tema conserva fontes/cores; overrides de cena têm base própria.
const TEMA := preload("res://ui/tema_brport.tres")
const CHAVE := &"apresentacao_do_texto"
static var _tema_maior: Theme
var raiz: Control
var acomodacao: AcomodacaoDoPorto
var _leitura := AcomodacaoDeLeitura.new()
var _arvore: SceneTree
var _pedido := false
var _aplicando := false
var _revisao := 0
var _assentando := false
var _refazer := false
var _leitura_pendente := false
var _marcas: Array = []


static func tema_atual(base: Theme = TEMA) -> Theme:
	if PreferenciasDeApresentacao.atual().tamanho_do_texto == PreferenciasDeApresentacao.PADRAO:
		return base
	if base != TEMA:
		return base
	if _tema_maior == null:
		_tema_maior = TEMA.duplicate()
		_tema_maior.default_font_size = roundi(TEMA.default_font_size * PreferenciasDeApresentacao.FATOR_MAIOR)
		for tipo in TEMA.get_font_size_type_list():
			# Marca desenhada, não texto de uso. O mapa não recebe escala.
			if tipo == "LogoInicial":
				continue
			for item in TEMA.get_font_size_list(tipo):
				_tema_maior.set_font_size(item, tipo,
					roundi(TEMA.get_font_size(item, tipo) * PreferenciasDeApresentacao.FATOR_MAIOR))
	return _tema_maior


static func acompanhar(tela: Control) -> TextoDaInterface:
	if tela.theme == TEMA:
		tela.theme = tema_atual()
	var pai: Node = tela
	while pai != null:
		if pai.has_meta(CHAVE):
			return pai.get_meta(CHAVE)
		pai = pai.get_parent()
	var instancia := TextoDaInterface.new()
	instancia.raiz = tela
	instancia._arvore = tela.get_tree()
	tela.set_meta(CHAVE, instancia)
	tela.tree_exiting.connect(instancia._desligar)
	instancia._arvore.node_added.connect(instancia._novo_no)
	PreferenciasDeApresentacao.atual().texto_mudou.connect(instancia._mudou)
	instancia.pedir()
	return instancia


func _desligar() -> void:
	if _arvore.node_added.is_connected(_novo_no):
		_arvore.node_added.disconnect(_novo_no)
	PreferenciasDeApresentacao.atual().texto_mudou.disconnect(_mudou)
	_revisao += 1


func _novo_no(no: Node) -> void:
	if no is Control and raiz.is_ancestor_of(no):
		pedir()


func _mudou(_modo: String) -> void:
	_leitura_pendente = true
	pedir()


func pedir() -> void:
	if not is_instance_valid(raiz) or not raiz.is_inside_tree():
		return
	if _pedido:
		_refazer = _refazer or _assentando
		return
	_pedido = true
	_aplicar.call_deferred()


func _aplicar() -> void:
	if not is_instance_valid(raiz) or not raiz.is_inside_tree() or raiz.is_queued_for_deletion():
		return
	_assentando = true
	_revisao += 1
	var revisao := _revisao
	# Só a escolha de tamanho preserva a posição existente. Ao abrir um app,
	# sua posição inicial pertence a ele (a conversa abre na última mensagem).
	if _leitura_pendente:
		_marcas = _guardar_leitura()
		_leitura_pendente = false
	var foco := raiz.get_viewport().gui_get_focus_owner()
	var campo := {}
	if foco is LineEdit:
		var selecionado: bool = foco.has_selection()
		campo = {"texto": foco.text, "cursor": foco.caret_column,
			"selecao": selecionado,
			"de": foco.get_selection_from_column() if selecionado else 0,
			"ate": foco.get_selection_to_column() if selecionado else 0}
	_aplicando = true
	var fator := PreferenciasDeApresentacao.atual().fator_do_texto()
	for no in descendentes(raiz):
		if no is Control:
			_vestir(no, fator)
	if acomodacao != null:
		acomodacao.aplicar(fator > 1.0)
	_leitura.aplicar(raiz, fator > 1.0)
	if fator == 1.0:
		_leitura.restaurar_grelhas(raiz)
	_aplicando = false
	# Dois frames: a fila adiada e os contentores precisam da largura nova
	# antes de devolver a leitura ao mesmo caractere, não ao mesmo pixel.
	await _arvore.process_frame
	await _arvore.process_frame
	if revisao != _revisao or not is_instance_valid(raiz) or not raiz.is_inside_tree():
		return
	_restaurar_leitura(_marcas)
	var foco_atual := raiz.get_viewport().gui_get_focus_owner()
	if is_instance_valid(foco) and foco.is_inside_tree() and raiz.is_ancestor_of(foco) \
			and (foco_atual == null or foco_atual == foco):
		if not foco.has_focus():
			foco.grab_focus()
		if foco is LineEdit and not campo.is_empty() and foco.text == campo.texto:
			foco.caret_column = campo.cursor
			if campo.selecao:
				foco.select(campo.de, campo.ate)
			else:
				foco.deselect()
		var pai := foco.get_parent()
		while pai != raiz and pai != null:
			if pai is ScrollContainer:
				pai.ensure_control_visible(foco)
			pai = pai.get_parent()
	_assentando = false
	_pedido = false
	if _refazer:
		_refazer = false
		pedir()
	else:
		_marcas.clear()


func _vestir(no: Control, fator: float) -> void:
	if no.theme == TEMA or no.theme == _tema_maior and _tema_maior != null:
		no.theme = tema_atual()
	if not no.theme_changed.is_connected(_tema_mudou.bind(no)):
		no.theme_changed.connect(_tema_mudou.bind(no))
	if not no.minimum_size_changed.is_connected(_tema_mudou.bind(no)):
		no.minimum_size_changed.connect(_tema_mudou.bind(no))
	# Só se multiplicam overrides explícitos. A letra herdada já vem do tema
	# ampliado; multiplicá-la também aqui daria 56% em vez dos 25% escolhidos.
	var bases: Dictionary = no.get_meta(&"fontes_base_rb5", {})
	var itens := ["font_size"]
	if no is RichTextLabel:
		itens = ["normal_font_size", "bold_font_size", "italics_font_size", "bold_italics_font_size", "mono_font_size"]
	for item in itens:
		if no.has_theme_font_size_override(item):
			var atual: int = no.get("theme_override_font_sizes/" + item)
			if not bases.has(item) or atual != int(bases[item]["aplicado"]):
				bases[item] = {"base": atual, "aplicado": atual}
			var tamanho := roundi(int(bases[item]["base"]) * fator)
			bases[item]["aplicado"] = tamanho
			if atual != tamanho:
				no.add_theme_font_size_override(item, tamanho)
	no.set_meta(&"fontes_base_rb5", bases)
	if no is Button:
		if not no.has_meta(&"quebra_base_rb5"):
			no.set_meta(&"quebra_base_rb5", no.autowrap_mode)
		# Numa linha horizontal, quebrar o botão elimina seu mínimo de largura:
		# a coluna expansível ao lado toma o espaço e a ação vira uma tira alta.
		var quebra := fator > 1.0 and not no.get_parent() is HBoxContainer
		no.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART if quebra else no.get_meta(&"quebra_base_rb5")
	elif no is Label:
		if not no.has_meta(&"quebra_base_rb5"):
			no.set_meta(&"quebra_base_rb5", no.autowrap_mode)
		# Palavras com 24 letras aceitas nos nomes também devem quebrar.
		# Os rótulos sem quebra ficam a cargo do seu layout (pílulas/cartões).
		if no.get_meta(&"quebra_base_rb5") == TextServer.AUTOWRAP_WORD:
			no.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART if fator > 1.0 else TextServer.AUTOWRAP_WORD


func _tema_mudou(_no: Control) -> void:
	if not _aplicando:
		pedir()


func _guardar_leitura() -> Array:
	var marcas: Array = []
	for no in descendentes(raiz):
		if not no is ScrollContainer or not no.is_visible_in_tree():
			continue
		marcas.append({"rolo": no, "marca": MemoriaDeLeitura.marcar(no)})
	return marcas


func _restaurar_leitura(marcas: Array) -> void:
	for marca in marcas:
		if is_instance_valid(marca.rolo):
			MemoriaDeLeitura.restaurar(marca.rolo, marca.marca)


static func descendentes(no: Node) -> Array[Node]:
	var todos: Array[Node] = [no]
	for filho in no.get_children():
		todos.append_array(descendentes(filho))
	return todos
