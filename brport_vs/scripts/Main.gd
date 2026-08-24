extends Control

# ============================================================
# BR Port VS — Main
# Constrói a tela toda via código (HUD, docas, trabalhadores) e
# escuta os signals do GameState para se manter em sincronia.
# Arte é 100% placeholder (ColorRect) — Bloco 4 troca por final.
# ============================================================

const WorkerScene := preload("res://scenes/worker/Worker.tscn")
const DockScene := preload("res://scenes/dock/Dock.tscn")
const CounterOfferScene := preload("res://scenes/panels/CounterOfferPanel.tscn")
const DebtPaymentScene := preload("res://scenes/panels/DebtPaymentPanel.tscn")
const UpgradePanelScene := preload("res://scenes/panels/UpgradePanel.tscn")
const PauseMenuScene := preload("res://scenes/panels/PauseMenu.tscn")
const EndGameScene := preload("res://scenes/EndGame.tscn")

var _overlay_layer: CanvasLayer

var _cash_label: Label
var _day_label: Label
var _rep_bar: ProgressBar
var _rep_label: Label
var _message_label: Label
var _advance_button: Button
var _upgrade_button: Button
var _docks_container: HBoxContainer
var _workers_container: HBoxContainer


func _ready() -> void:
	anchor_right = 1.0
	anchor_bottom = 1.0
	_build_ui()
	_connect_game_state()
	_refresh_all()

	# Se o jogo carregou de um save já em rival_offer/debt_payment, reabre o painel certo.
	if GameState.phase == "rival_offer" and GameState.pending_rival_dock >= 0:
		_on_rival_offer_triggered(GameState.pending_rival_dock)
	elif GameState.phase == "debt_payment":
		_on_debt_due(GameState.PARCELA_AMOUNT)
	elif GameState.phase == "game_over":
		_on_game_over(GameState.won, GameState.end_reason)


func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.11, 0.16, 0.24)
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var root_vbox := VBoxContainer.new()
	root_vbox.anchor_right = 1.0
	root_vbox.anchor_bottom = 1.0
	root_vbox.offset_left = 16
	root_vbox.offset_top = 16
	root_vbox.offset_right = -16
	root_vbox.offset_bottom = -16
	root_vbox.add_theme_constant_override("separation", 10)
	add_child(root_vbox)

	var title := Label.new()
	title.text = "⚓ BR PORT — Vertical Slice (loop core)"
	title.add_theme_font_size_override("font_size", 20)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root_vbox.add_child(title)

	var hud_row := HBoxContainer.new()
	hud_row.add_theme_constant_override("separation", 24)
	root_vbox.add_child(hud_row)

	_cash_label = Label.new()
	hud_row.add_child(_cash_label)

	_day_label = Label.new()
	hud_row.add_child(_day_label)

	var rep_row := HBoxContainer.new()
	rep_row.add_theme_constant_override("separation", 8)
	root_vbox.add_child(rep_row)

	var rep_icon := Label.new()
	rep_icon.text = "⭐ Reputação Comercial (Dona Cida):"
	rep_row.add_child(rep_icon)

	_rep_bar = ProgressBar.new()
	_rep_bar.custom_minimum_size = Vector2(200, 20)
	_rep_bar.max_value = 100
	rep_row.add_child(_rep_bar)

	_rep_label = Label.new()
	rep_row.add_child(_rep_label)

	var docks_title := Label.new()
	docks_title.text = "Docas"
	root_vbox.add_child(docks_title)

	_docks_container = HBoxContainer.new()
	_docks_container.add_theme_constant_override("separation", 12)
	root_vbox.add_child(_docks_container)

	var workers_title := Label.new()
	workers_title.text = "Trabalhadores — arraste para uma doca"
	root_vbox.add_child(workers_title)

	_workers_container = HBoxContainer.new()
	_workers_container.add_theme_constant_override("separation", 12)
	root_vbox.add_child(_workers_container)

	_message_label = Label.new()
	_message_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	_message_label.custom_minimum_size = Vector2(0, 40)
	root_vbox.add_child(_message_label)

	var btn_row := HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 12)
	root_vbox.add_child(btn_row)

	_upgrade_button = Button.new()
	_upgrade_button.pressed.connect(_on_upgrade_pressed)
	btn_row.add_child(_upgrade_button)

	var pause_button := Button.new()
	pause_button.text = "⏸ Pausar"
	pause_button.pressed.connect(_on_pause_pressed)
	btn_row.add_child(pause_button)

	_advance_button = Button.new()
	_advance_button.text = "▶ AVANÇAR DIA"
	_advance_button.custom_minimum_size = Vector2(220, 48)
	_advance_button.pressed.connect(_on_advance_pressed)
	root_vbox.add_child(_advance_button)

	_overlay_layer = CanvasLayer.new()
	_overlay_layer.layer = 10
	add_child(_overlay_layer)


func _connect_game_state() -> void:
	GameState.cash_changed.connect(func(_v): _refresh_hud())
	GameState.reputation_changed.connect(func(_v): _refresh_hud())
	GameState.turn_advanced.connect(func(_t, _w): _refresh_all())
	GameState.boats_spawned.connect(func(): _refresh_docks())
	GameState.worker_assigned.connect(func(): _refresh_docks(); _refresh_workers())
	GameState.message.connect(_on_message)
	GameState.rival_offer_triggered.connect(_on_rival_offer_triggered)
	GameState.debt_due.connect(_on_debt_due)
	GameState.game_over.connect(_on_game_over)


func _refresh_all() -> void:
	_refresh_hud()
	_refresh_docks()
	_refresh_workers()


func _refresh_hud() -> void:
	_cash_label.text = "💰 Caixa: R$%d" % int(GameState.cash)
	_day_label.text = "📅 Dia %d/%d — Semana %d" % [GameState.turn, GameState.TURNS_TOTAL, GameState.current_week()]
	_rep_bar.value = GameState.reputation
	_rep_label.text = "%d — %s" % [int(GameState.reputation), GameState.reputation_label()]
	_upgrade_button.disabled = GameState.upgrade_purchased or GameState.phase != "playing"
	_upgrade_button.text = "✓ Píer ampliado" if GameState.upgrade_purchased else "🏗️ Ampliar píer (R$%d)" % GameState.UPGRADE_COST
	_advance_button.disabled = GameState.phase != "playing"


func _refresh_docks() -> void:
	for child in _docks_container.get_children():
		child.queue_free()
	for i in range(GameState.docks.size()):
		var dock_node = DockScene.instantiate()
		_docks_container.add_child(dock_node)
		dock_node.setup(i)


func _refresh_workers() -> void:
	for child in _workers_container.get_children():
		child.queue_free()
	for w in GameState.workers:
		var worker_node = WorkerScene.instantiate()
		_workers_container.add_child(worker_node)
		worker_node.setup(int(w["id"]))


func _on_message(text: String, kind: String) -> void:
	_message_label.text = text
	match kind:
		"good":
			_message_label.add_theme_color_override("font_color", Color(0.4, 0.9, 0.5))
		"warn":
			_message_label.add_theme_color_override("font_color", Color(0.95, 0.75, 0.2))
		"bad":
			_message_label.add_theme_color_override("font_color", Color(0.95, 0.4, 0.4))
		_:
			_message_label.add_theme_color_override("font_color", Color(1, 1, 1))


func _on_advance_pressed() -> void:
	GameState.advance_turn()


func _on_upgrade_pressed() -> void:
	var panel = UpgradePanelScene.instantiate()
	_overlay_layer.add_child(panel)


func _on_pause_pressed() -> void:
	var panel = PauseMenuScene.instantiate()
	_overlay_layer.add_child(panel)


func _on_rival_offer_triggered(dock_index: int) -> void:
	_refresh_docks()
	var panel = CounterOfferScene.instantiate()
	_overlay_layer.add_child(panel)
	panel.setup(dock_index)


func _on_debt_due(amount: int) -> void:
	var panel = DebtPaymentScene.instantiate()
	_overlay_layer.add_child(panel)
	panel.setup(amount)


func _on_game_over(did_win: bool, reason: String) -> void:
	var panel = EndGameScene.instantiate()
	_overlay_layer.add_child(panel)
	panel.setup(did_win, reason)
