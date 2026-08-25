extends Control

# Slot de doca — alvo de drop dos trabalhadores. Mostra o barco
# (se houver), valor, progresso e se está sob oferta do rival.

var dock_index: int = -1

var _bg: ColorRect
var _label: Label


func setup(index: int) -> void:
	dock_index = index
	custom_minimum_size = Vector2(150, 170)

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
	var dock: Dictionary = GameState.docks[dock_index]
	var boat = dock["boat"]

	if boat == null:
		_bg.color = Color(0.18, 0.22, 0.3)
		_label.text = "Doca %d\n\nVazia" % (dock_index + 1)
		return

	var boat_type := "🚢 Grande" if boat.get("large", false) else "⛵ Pequeno"
	var value := int(boat["matched_value"]) if boat.get("matched", false) else int(boat["value"])
	var progress_txt := "%d/%d turnos" % [int(boat["progress"]), int(boat["op_turns"])]
	var worker_txt := ""
	if dock["worker_id"] != null:
		worker_txt = "\n👷 #%d" % int(dock["worker_id"])

	if boat.get("rival", false) and not boat.get("matched", false):
		_bg.color = Color(0.55, 0.16, 0.16)
		_label.text = "Doca %d\n%s\nOFERTA DO RIVAL\nR$%d" % [dock_index + 1, boat_type, value]
	else:
		_bg.color = Color(0.16, 0.4, 0.55) if boat.get("large", false) else Color(0.18, 0.45, 0.5)
		var matched_txt := " (igualado)" if boat.get("matched", false) else ""
		_label.text = "Doca %d\n%s\nR$%d%s\n%s%s" % [dock_index + 1, boat_type, value, matched_txt, progress_txt, worker_txt]


func _can_drop_data(_at_position: Vector2, data) -> bool:
	if typeof(data) != TYPE_DICTIONARY or not data.has("worker_id"):
		return false
	var dock: Dictionary = GameState.docks[dock_index]
	if dock["boat"] == null or dock["worker_id"] != null:
		return false
	var boat = dock["boat"]
	if boat.get("rival", false) and not boat.get("matched", false):
		return false
	return true


func _drop_data(_at_position: Vector2, data) -> void:
	GameState.assign_worker(int(data["worker_id"]), dock_index)
