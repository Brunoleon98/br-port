extends Control

# ============================================================
# BR Port VS — Main
#
# A tela mora em Main.tscn e o estilo em ui/tema_brport.tres. Este script
# só escuta os signals do GameState e alimenta os nós — não constrói e não
# pinta nada. Antes ele montava a interface inteira por código, o que
# obrigaria a reescrevê-lo para encaixar a arte final; agora o Bloco 4
# troca cena e tema sem tocar aqui.
# ============================================================

const WorkerScene := preload("res://scenes/worker/Worker.tscn")
const DockScene := preload("res://scenes/dock/Dock.tscn")
const CounterOfferScene := preload("res://scenes/panels/CounterOfferPanel.tscn")
const DebtPaymentScene := preload("res://scenes/panels/DebtPaymentPanel.tscn")
const UpgradePanelScene := preload("res://scenes/panels/UpgradePanel.tscn")
const PauseMenuScene := preload("res://scenes/panels/PauseMenu.tscn")
const EndGameScene := preload("res://scenes/EndGame.tscn")

const COR_BOA := Color(0.102, 0.478, 0.251)
const COR_AVISO := Color(0.851, 0.467, 0.024)
const COR_RUIM := Color(0.761, 0.188, 0.188)
const COR_NEUTRA := Color(0.11, 0.204, 0.329)

@onready var _overlay_layer: CanvasLayer = $Overlay
@onready var _cash_label: Label = $Margem/Coluna/Cabecalho/CabecalhoColuna/HudLinha/Caixa
@onready var _day_label: Label = $Margem/Coluna/Cabecalho/CabecalhoColuna/HudLinha/Dia
@onready var _rep_bar: ProgressBar = $Margem/Coluna/ReputacaoCartao/RepLinha/RepBarra
@onready var _rep_label: Label = $Margem/Coluna/ReputacaoCartao/RepLinha/RepTexto
@onready var _message_label: Label = $Margem/Coluna/MensagemCartao/Mensagem
@onready var _advance_button: Button = $Margem/Coluna/Avancar
@onready var _upgrade_button: Button = $Margem/Coluna/BotoesLinha/Upgrade
@onready var _pause_button: Button = $Margem/Coluna/BotoesLinha/Pausar
@onready var _docks_container: HBoxContainer = $Margem/Coluna/MapaPainel/MapaLinha/Docas
@onready var _workers_container: HBoxContainer = $Margem/Coluna/Trabalhadores
@onready var _meta_bar: ProgressBar = $Margem/Coluna/MetaCartao/MetaColuna/MetaBarra
@onready var _meta_label: Label = $Margem/Coluna/MetaCartao/MetaColuna/MetaTexto
@onready var _meta_titulo: Label = $Margem/Coluna/MetaCartao/MetaColuna/MetaTitulo


func _ready() -> void:
	_advance_button.pressed.connect(_on_advance_pressed)
	_upgrade_button.pressed.connect(_on_upgrade_pressed)
	_pause_button.pressed.connect(_on_pause_pressed)

	_connect_game_state()
	_refresh_all()

	# Se o jogo carregou de um save já em rival_offer/debt_payment, reabre o painel certo.
	if GameState.phase == "rival_offer" and GameState.pending_rival_dock >= 0:
		_on_rival_offer_triggered(GameState.pending_rival_dock)
	elif GameState.phase == "debt_payment":
		_on_debt_due(GameState.PARCELA_AMOUNT)
	elif GameState.phase == "game_over":
		_on_game_over(GameState.won, GameState.end_reason)


func _connect_game_state() -> void:
	GameState.cash_changed.connect(func(_v): _refresh_hud())
	GameState.reputation_changed.connect(func(_v): _refresh_hud())
	GameState.phase_changed.connect(func(_p): _refresh_hud())
	GameState.turn_advanced.connect(func(_t, _w): _refresh_all())
	GameState.boats_spawned.connect(func(): _refresh_docks())
	GameState.roster_changed.connect(_refresh_all)
	GameState.message.connect(_on_message)
	GameState.rival_offer_triggered.connect(_on_rival_offer_triggered)
	GameState.debt_due.connect(_on_debt_due)
	GameState.game_over.connect(_on_game_over)


func _refresh_all() -> void:
	_refresh_hud()
	_refresh_docks()
	_refresh_workers()


func _refresh_hud() -> void:
	_cash_label.text = "💰 R$%d" % int(GameState.cash)
	var shown_day: int = min(GameState.turn, GameState.TURNS_TOTAL)
	var shown_week: int = min(GameState.current_week(), GameState.WEEKS_TOTAL)
	_day_label.text = "📅 Dia %d/%d · Semana %d" % [shown_day, GameState.TURNS_TOTAL, shown_week]
	_rep_bar.value = GameState.reputation
	_rep_label.text = "%d — %s" % [int(GameState.reputation), GameState.reputation_label()]
	_upgrade_button.disabled = GameState.upgrade_purchased or GameState.phase != "playing"
	_upgrade_button.text = "✓ Píer ampliado" if GameState.upgrade_purchased else "🏗️ Ampliar píer (R$%d)" % GameState.UPGRADE_COST
	_advance_button.disabled = GameState.phase != "playing"
	_refresh_meta()


# O playtest perdeu uma partida por R$1 sem nunca ver o quanto faltava. Esta é
# a informação que estava faltando na tela: quanto já tem, quanto falta e
# quantos dias restam até o Sr. Ribeiro bater na porta.
func _refresh_meta() -> void:
	var alvo := GameState.PARCELA_AMOUNT
	if GameState.parcela_paid:
		_meta_titulo.text = "🏦 Parcela do Sr. Ribeiro"
		_meta_bar.value = 100.0
		_meta_label.text = "✅ Paga — porto salvo"
		return

	var dias_restantes: int = max(GameState.PARCELA_DUE_TURN - GameState.turn + 1, 0)
	_meta_titulo.text = "🏦 Parcela do Sr. Ribeiro — %d dia(s) restante(s)" % dias_restantes
	_meta_bar.value = clamp(100.0 * float(GameState.cash) / float(alvo), 0.0, 100.0)
	var falta: int = alvo - int(GameState.cash)
	if falta > 0:
		_meta_label.text = "R$%d de R$%d — faltam R$%d" % [int(GameState.cash), alvo, falta]
	else:
		_meta_label.text = "R$%d de R$%d — já dá para pagar" % [int(GameState.cash), alvo]


func _clear(container: Node) -> void:
	# queue_free() sozinho é adiado até o fim do frame — sem o remove_child o
	# container fica com os nós velhos e os novos ao mesmo tempo por um frame.
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()


func _refresh_docks() -> void:
	_clear(_docks_container)
	for i in range(GameState.docks.size()):
		var dock_node = DockScene.instantiate()
		_docks_container.add_child(dock_node)
		dock_node.setup(i)


func _refresh_workers() -> void:
	_clear(_workers_container)
	for w in GameState.workers:
		var worker_node = WorkerScene.instantiate()
		_workers_container.add_child(worker_node)
		worker_node.setup(int(w["id"]))


func _on_message(text: String, kind: String) -> void:
	_message_label.text = text
	match kind:
		"good":
			_message_label.add_theme_color_override("font_color", COR_BOA)
		"warn":
			_message_label.add_theme_color_override("font_color", COR_AVISO)
		"bad":
			_message_label.add_theme_color_override("font_color", COR_RUIM)
		_:
			_message_label.add_theme_color_override("font_color", COR_NEUTRA)


func _on_advance_pressed() -> void:
	GameState.advance_turn()


# Os painéis pendurados no CanvasLayer NÃO herdam o tema: tema só se propaga
# por uma árvore de Control, e CanvasLayer não é Control. Sem repassar na mão,
# todo painel sai com o visual padrão do Godot em cima do jogo temático.
func _abrir_painel(cena: PackedScene) -> Control:
	var painel: Control = cena.instantiate()
	painel.theme = theme
	_overlay_layer.add_child(painel)
	return painel


func _on_upgrade_pressed() -> void:
	_abrir_painel(UpgradePanelScene)


func _on_pause_pressed() -> void:
	_abrir_painel(PauseMenuScene)


func _on_rival_offer_triggered(dock_index: int) -> void:
	_refresh_docks()
	_abrir_painel(CounterOfferScene).setup(dock_index)


func _on_debt_due(amount: int) -> void:
	_abrir_painel(DebtPaymentScene).setup(amount)


func _on_game_over(did_win: bool, reason: String) -> void:
	_abrir_painel(EndGameScene).setup(did_win, reason)
