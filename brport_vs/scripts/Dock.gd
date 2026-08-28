extends Control

# Vaga de doca no mapa do porto — alvo de drop dos trabalhadores.
#
# Desde o Bloco 4 a doca não é mais um cartão numa fileira: é uma POSIÇÃO no
# mapa visto de cima. O mapa desenha 3 vagas fixas; quantas estão construídas
# vem de GameState.docks. A vaga além do que existe mostra o píer por
# construir — é o que faz "Ampliar píer" ter consequência visível no mapa em
# vez de só somar um cartão.
#
# A árvore de nós mora em Dock.tscn e o estilo no tema. Este script não
# constrói nem pinta nada: só escolhe qual textura e qual texto valem agora.

const ArtePierPronto := preload("res://art/pier_construido.svg")
const ArtePierVazio := preload("res://art/pier_vazio.svg")

# Barcos em vetor CHAPADO, vistos de cima — não os PNGs ilustrados em 3/4.
# Sobre um mapa topo-down, sprite em 3/4 não é escolha de estilo, é erro de
# perspectiva: o barco fica boiando por cima do mapa em vez de dentro dele.
# Os PNGs ilustrados continuam no repositório, para painéis e retratos.
const ArteGrande := preload("res://art/barco_grande.svg")
const ArtePequeno := preload("res://art/barco_pequeno.svg")

var dock_index: int = -1

@onready var _pier: TextureRect = $Pier
@onready var _barco: TextureRect = $Barco
@onready var _chip: PanelContainer = $Chip
@onready var _valor: Label = $Chip/Coluna/Valor
@onready var _progresso: Label = $Chip/Coluna/Progresso
@onready var _trabalhador: Label = $Chip/Coluna/Trabalhador


func setup(index: int) -> void:
	dock_index = index
	# setup() pode ser chamado antes de a cena entrar na árvore, quando os
	# @onready ainda são null. Nesse caso o refresh acontece no _ready().
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

	# Vaga ainda não construída: estacas velhas, sem barco.
	if not esta_construida():
		_pier.texture = ArtePierVazio
		_barco.texture = null
		_valor.text = "Vaga livre"
		_progresso.text = "Ampliar píer"
		_trabalhador.text = ""
		return

	_pier.texture = ArtePierPronto
	var dock: Dictionary = GameState.docks[dock_index]
	var boat = dock["boat"]

	if boat == null:
		_barco.texture = null
		_valor.text = "Doca vazia"
		_progresso.text = "aguardando barco"
		_trabalhador.text = ""
		return

	var grande: bool = boat.get("large", false)
	var sob_oferta: bool = boat.get("rival", false) and not boat.get("matched", false)
	var valor: int = int(boat["matched_value"]) if boat.get("matched", false) else int(boat["value"])

	_barco.texture = ArteGrande if grande else ArtePequeno
	_valor.text = "R$%d%s" % [valor, " (acordo)" if boat.get("matched", false) else ""]

	if sob_oferta:
		_progresso.text = "⚔️ OFERTA DO RIVAL"
		_trabalhador.text = ""
		return

	_progresso.text = "%d/%d turnos" % [int(boat["progress"]), int(boat["op_turns"])]

	if dock["worker_id"] == null:
		_trabalhador.text = "sem trabalhador"
	else:
		var texto := "👷 #%d" % int(dock["worker_id"])
		# Enquanto a operação não começou dá para desfazer um arrasto errado.
		if int(boat["progress"]) == 0:
			texto += " · toque p/ liberar"
		_trabalhador.text = texto


func _can_drop_data(_at_position: Vector2, data) -> bool:
	if typeof(data) != TYPE_DICTIONARY or not data.has("worker_id"):
		return false
	if not esta_construida():
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


func _gui_input(event: InputEvent) -> void:
	# Tocar/clicar numa doca com trabalhador alocado o devolve para a lista,
	# desde que a operação ainda não tenha começado.
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not esta_construida():
			return
		if GameState.docks[dock_index]["worker_id"] != null:
			GameState.release_worker(dock_index)
			accept_event()
