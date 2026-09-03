extends PanelContainer

# Trabalhador arrastável. Usa o sistema nativo de drag-and-drop de Control
# do Godot — funciona com touch e mouse.
#
# Como a doca: árvore em Worker.tscn, estilo no tema (TrabLivre,
# TrabAlocado, TrabOcupado). No Bloco 4 o retângulo vira sprite trocando a
# cena, sem mexer aqui.

# Tocar num trabalhador o SELECIONA; tocar depois numa doca o manda para lá.
# É a alternativa ao arrasto — que continua funcionando, mas exigia precisão
# e repetição a cada turno.
signal selecionado(worker_id: int)

var worker_id: int = -1
var _selecionado := false

@onready var _retrato: TextureRect = $Conteudo/Retrato
@onready var _nome: Label = $Conteudo/Nome
@onready var _estado: Label = $Conteudo/Estado


func setup(id: int) -> void:
	worker_id = id
	if is_node_ready():
		refresh()


func _ready() -> void:
	if worker_id >= 0:
		refresh()


func _aplicar_estilo(nome_no_tema: String) -> void:
	var estilo := get_theme_stylebox("panel", nome_no_tema)
	if _selecionado and estilo is StyleBoxFlat:
		# Duplicar: mexer no stylebox do tema mudaria TODOS os trabalhadores.
		var realce: StyleBoxFlat = estilo.duplicate()
		realce.border_color = Color(0.878, 0.604, 0.063)
		realce.set_border_width_all(4)
		estilo = realce
	add_theme_stylebox_override("panel", estilo)


func marcar_selecionado(valor: bool) -> void:
	if _selecionado == valor:
		return
	_selecionado = valor
	if is_node_ready():
		refresh()


func _gui_input(event: InputEvent) -> void:
	# No RELEASE, não no press: soltar um arrasto acontece sobre a doca, então
	# tratar aqui não rouba o clique de quem prefere arrastar.
	if event is InputEventMouseButton and not event.pressed \
			and event.button_index == MOUSE_BUTTON_LEFT:
		if esta_livre():
			selecionado.emit(worker_id)
			accept_event()


func refresh() -> void:
	var w = _find_self()
	if w == null:
		return
	_nome.text = "#%d" % worker_id

	var busy: int = int(w["busy_turns"])
	# `busy_turns` só conta operações que já começaram; quem foi alocado neste
	# turno ainda está com 0 e precisa ser detectado pela doca, senão aparece
	# como "Livre" e dá para arrastar o mesmo trabalhador para outra doca.
	var dock_index := GameState.worker_dock_index(worker_id)

	if busy > 0:
		_aplicar_estilo("TrabOcupado")
		_estado.text = "Ocupado (%dt)" % busy
	elif dock_index >= 0:
		_aplicar_estilo("TrabAlocado")
		_estado.text = "Na Doca %d" % (dock_index + 1)
	elif _selecionado:
		_aplicar_estilo("TrabLivre")
		_estado.text = "Escolhido"
	elif GameState.has_pending_assignment():
		# LIVRE E CUSTANDO DINHEIRO não é o mesmo estado que livre. O primeiro
		# playtest num telefone avançou o dia com dois operários livres e duas
		# docas sem trabalhador: a doca já avisava com a borda âmbar, e quem
		# resolve o problema — este cartão — dizia "Livre" em cinzento, como
		# quem não tem nada a fazer.
		#
		# A pergunta é global, e é por isso que sai do `has_pending_assignment()`
		# e não de olhar só este trabalhador: um operário livre num porto sem
		# doca à espera está livre e pronto, e pintá-lo de âmbar seria pedir
		# uma ação que não existe.
		_aplicar_estilo("TrabParado")
		_estado.text = "Parado"
	else:
		_aplicar_estilo("TrabLivre")
		_estado.text = "Livre"


func _find_self() -> Variant:
	for w in GameState.workers:
		if int(w["id"]) == worker_id:
			return w
	return null


func esta_livre() -> bool:
	var w = _find_self()
	if w == null or int(w["busy_turns"]) > 0 or GameState.phase != "playing":
		return false
	return GameState.worker_dock_index(worker_id) < 0


func _get_drag_data(_at_position: Vector2) -> Variant:
	if not esta_livre():
		return null
	# O arrasto carrega o próprio trabalhador, não um rótulo: fica claro o que
	# está sendo levado para a doca.
	var preview := TextureRect.new()
	preview.texture = _retrato.texture
	preview.custom_minimum_size = Vector2(48, 96)
	preview.size = Vector2(48, 96)
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	set_drag_preview(preview)
	return {"worker_id": worker_id}
