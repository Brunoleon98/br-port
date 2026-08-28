extends PanelContainer

# Trabalhador arrastável. Usa o sistema nativo de drag-and-drop de Control
# do Godot — funciona com touch e mouse.
#
# Como a doca: árvore em Worker.tscn, estilo no tema (TrabLivre,
# TrabAlocado, TrabOcupado). No Bloco 4 o retângulo vira sprite trocando a
# cena, sem mexer aqui.

var worker_id: int = -1

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
	add_theme_stylebox_override("panel", get_theme_stylebox("panel", nome_no_tema))


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
	else:
		_aplicar_estilo("TrabLivre")
		_estado.text = "Livre\narraste →"


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
