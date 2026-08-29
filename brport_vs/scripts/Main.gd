extends Control

# ============================================================
# BR Port VS — Main
#
# A tela mora em Main.tscn e o estilo em ui/tema_brport.tres. Este script
# só escuta os signals do GameState e alimenta os nós — não constrói e não
# pinta nada.
#
# Desde o Bloco 4 as docas não são mais uma fileira de cartões: são três
# VAGAS FIXAS no mapa do porto, já posicionadas em Main.tscn sobre os
# píeres. Quantas estão construídas vem de GameState.docks, então "Ampliar
# píer" acende a terceira vaga em vez de só somar um cartão.
# ============================================================

const WorkerScene := preload("res://scenes/worker/Worker.tscn")
const CounterOfferScene := preload("res://scenes/panels/CounterOfferPanel.tscn")
const DebtPaymentScene := preload("res://scenes/panels/DebtPaymentPanel.tscn")
const UpgradePanelScene := preload("res://scenes/panels/UpgradePanel.tscn")
const PauseMenuScene := preload("res://scenes/panels/PauseMenu.tscn")
const EndGameScene := preload("res://scenes/EndGame.tscn")

# Vagas desenhadas no mapa. O upgrade do píer nunca pode passar disto sem
# o mapa ganhar uma quarta posição desenhada.
const VAGAS_NO_MAPA := 3

const COR_BOA := Color(0.102, 0.478, 0.251)
const COR_AVISO := Color(0.851, 0.467, 0.024)
const COR_RUIM := Color(0.761, 0.188, 0.188)
const COR_NEUTRA := Color(0.11, 0.204, 0.329)

@onready var _overlay_layer: CanvasLayer = $Overlay
@onready var _cash_label: Label = $HudBar/CaixaPilula/Linha/Caixa
@onready var _day_label: Label = $HudBar/DiaPilula/Linha/Dia
@onready var _rep_label: Label = $HudBar/RepPilula/Linha/RepTexto
@onready var _docks_label: Label = $HudBar/DocasPilula/Linha/DocasTexto
@onready var _pause_button: Button = $HudBar/Pausar
@onready var _message_label: Label = $MensagemCartao/Mensagem
@onready var _advance_button: Button = $Avancar
@onready var _upgrade_button: Button = $Upgrade
@onready var _docks_container: Control = $MapaWrap/Docas
@onready var _workers_container: HBoxContainer = $Trabalhadores
@onready var _meta_bar: ProgressBar = $MetaCartao/MetaColuna/MetaBarra
@onready var _meta_label: Label = $MetaCartao/MetaColuna/MetaTexto
@onready var _meta_titulo: Label = $MetaCartao/MetaColuna/MetaTituloLinha/MetaTitulo
@onready var _meta_icone: TextureRect = $MetaCartao/MetaColuna/MetaTituloLinha/Icone


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
	_cash_label.text = "R$%d" % int(GameState.cash)
	var shown_day: int = min(GameState.turn, GameState.TURNS_TOTAL)
	_day_label.text = "Dia %d/%d" % [shown_day, GameState.TURNS_TOTAL]
	_rep_label.text = "%d %s" % [int(GameState.reputation), GameState.reputation_label()]
	_docks_label.text = "%d/%d" % [GameState.docks.size(), VAGAS_NO_MAPA]
	_upgrade_button.disabled = GameState.upgrade_purchased or GameState.phase != "playing"
	if GameState.upgrade_purchased:
		_upgrade_button.text = "Píer ampliado"
		Icones.no_botao(_upgrade_button, Icones.FEITO, 26)
	else:
		_upgrade_button.text = "Ampliar píer (R$%d)" % GameState.UPGRADE_COST
		Icones.no_botao(_upgrade_button, Icones.AMPLIAR_PIER, 26)
	_advance_button.disabled = GameState.phase != "playing"
	_refresh_meta()


# O playtest perdeu uma partida por R$1 sem nunca ver o quanto faltava. Esta é
# a informação que estava faltando na tela: quanto já tem, quanto falta e
# quantos dias restam até o Sr. Ribeiro bater na porta.
func _refresh_meta() -> void:
	var alvo := GameState.PARCELA_AMOUNT
	if GameState.parcela_paid:
		# Pago: o banco dá lugar ao visto verde, que é o estado, não o credor.
		_meta_icone.texture = Icones.FEITO
		_meta_titulo.text = "Parcela do Sr. Ribeiro"
		_meta_bar.value = 100.0
		_meta_label.text = "Paga — porto salvo"
		return

	_meta_icone.texture = Icones.PARCELA
	var dias_restantes: int = max(GameState.PARCELA_DUE_TURN - GameState.turn + 1, 0)
	_meta_titulo.text = "Parcela do Sr. Ribeiro — %d dia(s) restante(s)" % dias_restantes
	_meta_bar.value = clamp(100.0 * float(GameState.cash) / float(alvo), 0.0, 100.0)
	var falta: int = alvo - int(GameState.cash)
	if falta > 0:
		_meta_label.text = "R$%d de R$%d — faltam R$%d" % [int(GameState.cash), alvo, falta]
	else:
		_meta_label.text = "R$%d de R$%d — já dá para pagar" % [int(GameState.cash), alvo]


# As vagas já existem na cena, uma por píer desenhado no mapa. Aqui só se diz
# a cada uma qual índice ela representa — quem não tem doca correspondente se
# desenha como vaga por construir.
func _refresh_docks() -> void:
	var vagas := _docks_container.get_children()
	for i in range(vagas.size()):
		vagas[i].setup(i)


func _clear(container: Node) -> void:
	# queue_free() sozinho é adiado até o fim do frame — sem o remove_child o
	# container fica com os nós velhos e os novos ao mesmo tempo por um frame.
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()


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
