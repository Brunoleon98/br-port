extends Control

# Retângulo colorido arrastável (placeholder). Usa o sistema nativo
# de drag-and-drop de Control do Godot — funciona com touch e mouse.

var worker_id: int = -1

var _bg: ColorRect
var _label: Label


func setup(id: int) -> void:
	worker_id = id
	custom_minimum_size = Vector2(96, 96)

	_bg = ColorRect.new()
	_bg.anchor_right = 1.0
	_bg.anchor_bottom = 1.0
	_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_bg)

	_label = Label.new()
	_label.anchor_right = 1.0
	_label.anchor_bottom = 1.0
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_label)

	refresh()


func refresh() -> void:
	var w = _find_self()
	if w == null:
		return
	var busy: int = int(w["busy_turns"])
	# `busy_turns` só conta operações que já começaram; quem foi alocado neste
	# turno ainda está com 0 e precisa ser detectado pela doca, senão aparece
	# como "Livre" e dá para arrastar o mesmo trabalhador para outra doca.
	var dock_index := GameState.worker_dock_index(worker_id)
	if busy > 0:
		_bg.color = Color(0.3, 0.3, 0.35)
		_label.text = "👷 #%d\nOcupado (%dt)" % [worker_id, busy]
	elif dock_index >= 0:
		_bg.color = Color(0.35, 0.4, 0.5)
		_label.text = "👷 #%d\nNa Doca %d" % [worker_id, dock_index + 1]
	else:
		_bg.color = Color(0.25, 0.65, 0.35)
		_label.text = "👷 #%d\nLivre\narraste →" % worker_id


func _find_self() -> Variant:
	for w in GameState.workers:
		if int(w["id"]) == worker_id:
			return w
	return null


func _get_drag_data(_at_position: Vector2) -> Variant:
	var w = _find_self()
	if w == null or int(w["busy_turns"]) > 0 or GameState.phase != "playing":
		return null
	if GameState.worker_dock_index(worker_id) >= 0:
		return null
	var preview := ColorRect.new()
	preview.color = Color(0.25, 0.65, 0.35, 0.85)
	preview.custom_minimum_size = Vector2(90, 90)
	set_drag_preview(preview)
	return {"worker_id": worker_id}
