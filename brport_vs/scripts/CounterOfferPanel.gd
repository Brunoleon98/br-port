extends Control

# Contra-oferta do Arlindo: 3 presets em botões + mood face do
# cliente em 3 estados (2/1/0 tentativas restantes) — GDD 7,
# "VS — Sistemas IN".

var dock_index: int = -1
var attempts_left: int = 2

var _mood_label: Label


func setup(index: int) -> void:
	dock_index = index
	attempts_left = 2
	_build_ui()
	_refresh_mood()


func _build_ui() -> void:
	anchor_right = 1.0
	anchor_bottom = 1.0

	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.6)
	dim.anchor_right = 1.0
	dim.anchor_bottom = 1.0
	add_child(dim)

	var box := PanelContainer.new()
	box.anchor_left = 0.5
	box.anchor_top = 0.5
	box.anchor_right = 0.5
	box.anchor_bottom = 0.5
	box.offset_left = -190
	box.offset_top = -140
	box.offset_right = 190
	box.offset_bottom = 140
	add_child(box)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	box.add_child(vbox)

	var title := Label.new()
	title.text = "⚔️ Arlindo (Porto Farol) fez uma oferta"
	title.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(title)

	var boat = GameState.docks[dock_index]["boat"]
	var value: int = int(boat["value"]) if boat != null else 0

	var info_label := Label.new()
	info_label.text = "Cliente considerando ir para o Porto Farol.\nValor original: R$%d" % value
	info_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(info_label)

	_mood_label = Label.new()
	vbox.add_child(_mood_label)

	var btn_row := HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 8)
	vbox.add_child(btn_row)

	var discounted := int(round(value * (1.0 - GameState.RIVAL_DISCOUNT)))

	var btn_match := Button.new()
	btn_match.text = "Igualar\nR$%d" % discounted
	btn_match.pressed.connect(func(): _resolve(true))
	btn_row.add_child(btn_match)

	var btn_keep := Button.new()
	btn_keep.text = "Manter preço\n(gasta tentativa)"
	btn_keep.pressed.connect(_on_keep_price)
	btn_row.add_child(btn_keep)

	var btn_refuse := Button.new()
	btn_refuse.text = "Recusar\n(perde barco)"
	btn_refuse.pressed.connect(func(): _resolve(false))
	btn_row.add_child(btn_refuse)


func _on_keep_price() -> void:
	attempts_left -= 1
	if attempts_left <= 0:
		_resolve(false)
		return
	_refresh_mood()


func _refresh_mood() -> void:
	var face := "🙂"
	var desc := "Cliente neutro."
	if attempts_left == 1:
		face = "😟"
		desc = "Cliente impaciente — última tentativa."
	elif attempts_left <= 0:
		face = "🚶"
		desc = "Cliente saindo."
	_mood_label.text = "%s %s (%d tentativa(s) restante(s))" % [face, desc, attempts_left]


func _resolve(accept_match: bool) -> void:
	GameState.resolve_rival_offer(accept_match)
	queue_free()
