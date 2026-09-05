extends PanelContainer

# ============================================================
# BR Port VS — cartão de uma doca (barra abaixo do mapa)
#
# Este nó é a METADE DE INTERFACE de uma doca: o texto e o alvo de toque.
# A outra metade — píer, barco, guindaste, trabalhador — vive em Dock.tscn,
# em cima do mapa. As duas leem o mesmo `GameState.docks[i]` e não conversam
# entre si; quem manda as duas se redesenharem é o Main.
#
# Por que separar. Enquanto o texto morava numa chip pousada no tabuado, ele
# tapava o barco e o guindaste, que é a arte que explica o turno. E como a
# chip acompanhava o píer, os três alvos de toque ficavam em diagonal pela
# tela: pior de acertar com o polegar do que uma fileira alinhada.
#
# O cartão continua aceitando ARRASTO, então quem já jogava arrastando o
# trabalhador para o píer não perde nada — o píer também continua sendo alvo.
# ============================================================

const COR_ESPERANDO := Color(0.961, 0.725, 0.227)
const COR_CALMA := Color(0.639, 0.792, 0.855)

var dock_index: int = -1

# Quem está selecionado na fileira de trabalhadores, ou -1. O Main mantém em
# dia; o cartão só precisa saber para onde mandar o toque.
var trabalhador_selecionado: int = -1

const PULSO_SEG := 0.9
var _tw_pulso: Tween

@onready var _nome: Label = $Coluna/Cabecalho/Nome
@onready var _valor: Label = $Coluna/Cabecalho/Valor
@onready var _progresso: Label = $Coluna/ProgressoLinha/Progresso
@onready var _progresso_icone: TextureRect = $Coluna/ProgressoLinha/Icone
@onready var _trabalhador: Label = $Coluna/TrabalhadorLinha/Trabalhador
@onready var _trabalhador_icone: TextureRect = $Coluna/TrabalhadorLinha/Icone


func setup(index: int) -> void:
	dock_index = index
	if is_node_ready():
		refresh()


func _ready() -> void:
	if dock_index >= 0:
		refresh()


func esta_construida() -> bool:
	return dock_index >= 0 and dock_index < GameState.docks.size()


func refresh() -> void:
	if dock_index < 0:
		return

	_nome.text = "DOCA %d" % (dock_index + 1)
	_progresso_icone.visible = false
	_trabalhador_icone.visible = false
	_pulsar(false)

	if not esta_construida():
		_estilo("CartaoDocaObra")
		_valor.text = "—"
		_progresso.text = "píer por construir"
		_progresso.add_theme_color_override("font_color", COR_CALMA)
		_trabalhador.text = ""
		return

	var dock: Dictionary = GameState.docks[dock_index]
	var boat = dock["boat"]

	if boat == null:
		_estilo("CartaoDoca")
		_valor.text = "—"
		_progresso.text = "aguardando barco"
		_progresso.add_theme_color_override("font_color", COR_CALMA)
		_trabalhador.text = ""
		return

	var sob_oferta: bool = boat.get("rival", false) and not boat.get("matched", false)
	var valor: int = int(boat["matched_value"]) if boat.get("matched", false) else int(boat["value"])
	_valor.text = GameState.moeda(valor)

	# O MOTIVO abre a linha do progresso, e não o cabeçalho. Medido a 06/09: o
	# interior do cartão dá 200px, e "DOCA 1 · Armazenagem" ao lado do valor a
	# 19px pede 233 — o nome mais longo estouraria o cartão sem erro nenhum,
	# só com o texto cortado. Na linha do progresso, a 13px, o pior caso cabe.
	var motivo: String = GameState.MOTIVOS[String(boat["motivo"])]["nome"]

	if sob_oferta:
		_estilo("CartaoDocaRival")
		_progresso_icone.visible = true
		# Aqui o motivo sai da frente: quem está a decidir o preço não precisa
		# de saber o que o navio traz, e as duas coisas juntas com o ícone do
		# rival não cabem na linha.
		_progresso.text = "oferta do rival"
		_progresso.add_theme_color_override("font_color", COR_ESPERANDO)
		_trabalhador.text = ""
		return

	# Com acordo fechado a palavra "turnos" sai: o pior caso dos três pedaços
	# mede 189px dos 200 disponíveis, e escrevê-la passaria de 200.
	if boat.get("matched", false):
		_progresso.text = "%s  ·  %d/%d  ·  acordo" % [
			motivo, int(boat["progress"]), int(boat["op_turns"])]
	else:
		_progresso.text = "%s  ·  %d/%d turnos" % [
			motivo, int(boat["progress"]), int(boat["op_turns"])]
	_progresso.add_theme_color_override("font_color", COR_CALMA)

	# Barco parado esperando gente é o que o jogador precisa notar — e é a
	# única coisa nesta barra que pisca.
	var esperando: bool = dock["worker_id"] == null and int(boat["progress"]) == 0
	_estilo("CartaoDocaEspera" if esperando else "CartaoDoca")
	_pulsar(esperando)

	if dock["worker_id"] == null:
		_trabalhador.text = "sem trabalhador"
		_trabalhador.add_theme_color_override("font_color", COR_ESPERANDO)
	else:
		_trabalhador_icone.visible = true
		var texto := "#%d" % int(dock["worker_id"])
		# Enquanto a operação não começou dá para desfazer um arrasto errado.
		if int(boat["progress"]) == 0:
			texto += "  ·  toque p/ liberar"
		_trabalhador.text = texto
		_trabalhador.add_theme_color_override("font_color", COR_ESPERANDO)


func _estilo(variacao: String) -> void:
	theme_type_variation = StringName(variacao)


func _pulsar(ligado: bool) -> void:
	if _tw_pulso != null and _tw_pulso.is_valid():
		_tw_pulso.kill()
	if not ligado:
		modulate = Color.WHITE
		return
	_tw_pulso = create_tween().set_loops()
	_tw_pulso.tween_property(self, "modulate", Color(1.3, 1.18, 0.8), PULSO_SEG) \
		.set_trans(Tween.TRANS_SINE)
	_tw_pulso.tween_property(self, "modulate", Color.WHITE, PULSO_SEG) \
		.set_trans(Tween.TRANS_SINE)


func _can_drop_data(_at_position: Vector2, data) -> bool:
	if typeof(data) != TYPE_DICTIONARY or not data.has("worker_id"):
		return false
	return GameState.doca_aceita_trabalhador(dock_index)


func _drop_data(_at_position: Vector2, data) -> void:
	GameState.assign_worker(int(data["worker_id"]), dock_index)


func _gui_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton and event.pressed
			and event.button_index == MOUSE_BUTTON_LEFT):
		return
	if not esta_construida():
		return

	# Com alguém selecionado na fileira, o toque ALOCA — é o outro lado do
	# toque-para-alocar. Sem seleção, o toque devolve quem está aqui para a
	# fileira, que é como se desfaz um arrasto errado.
	if trabalhador_selecionado >= 0 and GameState.docks[dock_index]["worker_id"] == null:
		GameState.assign_worker(trabalhador_selecionado, dock_index)
		accept_event()
		return

	if GameState.docks[dock_index]["worker_id"] != null:
		GameState.release_worker(dock_index)
		accept_event()
