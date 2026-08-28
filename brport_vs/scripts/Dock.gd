extends PanelContainer

# Slot de doca — alvo de drop dos trabalhadores. Mostra o barco (se houver),
# valor, progresso e se está sob oferta do rival.
#
# A árvore de nós mora em Dock.tscn e o estilo mora no tema (DocaVazia,
# DocaBarco, DocaGrande, DocaRival). Este script não constrói nem pinta
# nada: só decide qual estilo vale agora e o que cada label diz. É isso que
# permite trocar o visual no Bloco 4 sem tocar em lógica.

# A arte do barco entra por textura, não por cor pintada em script — mesma
# regra dos estilos: o script escolhe QUAL recurso vale, nunca desenha.
const ArteGrande := preload("res://art/sprites/cargueiro.png")
const ArtePequeno := preload("res://art/sprites/barco_pesca.png")

var dock_index: int = -1

@onready var _titulo: Label = $Conteudo/Titulo
@onready var _barco: TextureRect = $Conteudo/Barco
@onready var _tipo: Label = $Conteudo/Tipo
@onready var _valor: Label = $Conteudo/Valor
@onready var _progresso: Label = $Conteudo/Progresso
@onready var _trabalhador: Label = $Conteudo/Trabalhador


func setup(index: int) -> void:
	dock_index = index
	# setup() pode ser chamado antes de a cena entrar na árvore, quando os
	# @onready ainda são null. Nesse caso o refresh acontece no _ready().
	if is_node_ready():
		refresh()


func _ready() -> void:
	if dock_index >= 0:
		refresh()


func _aplicar_estilo(nome_no_tema: String) -> void:
	add_theme_stylebox_override("panel", get_theme_stylebox("panel", nome_no_tema))


func refresh() -> void:
	if dock_index < 0 or dock_index >= GameState.docks.size():
		return
	var dock: Dictionary = GameState.docks[dock_index]
	var boat = dock["boat"]

	_titulo.text = "Doca %d" % (dock_index + 1)

	if boat == null:
		_aplicar_estilo("DocaVazia")
		_barco.texture = null
		_tipo.text = "Vazia"
		_valor.text = ""
		_progresso.text = ""
		_trabalhador.text = ""
		return

	var grande: bool = boat.get("large", false)
	var sob_oferta: bool = boat.get("rival", false) and not boat.get("matched", false)
	var valor: int = int(boat["matched_value"]) if boat.get("matched", false) else int(boat["value"])

	# O sprite já diz que barco é: o emoji que ficava aqui virou redundante.
	_barco.texture = ArteGrande if grande else ArtePequeno
	_tipo.text = "Grande" if grande else "Pequeno"
	_valor.text = "R$%d%s" % [valor, " (acordo)" if boat.get("matched", false) else ""]

	if sob_oferta:
		_aplicar_estilo("DocaRival")
		_progresso.text = "⚔️ OFERTA DO RIVAL"
		_trabalhador.text = ""
		return

	_aplicar_estilo("DocaGrande" if grande else "DocaBarco")
	_progresso.text = "%d/%d turnos" % [int(boat["progress"]), int(boat["op_turns"])]

	if dock["worker_id"] == null:
		_trabalhador.text = ""
	else:
		var texto := "👷 #%d" % int(dock["worker_id"])
		# Enquanto a operação não começou dá para desfazer um arrasto errado.
		if int(boat["progress"]) == 0:
			texto += " (toque p/ liberar)"
		_trabalhador.text = texto


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


func _gui_input(event: InputEvent) -> void:
	# Tocar/clicar numa doca com trabalhador alocado o devolve para a lista,
	# desde que a operação ainda não tenha começado.
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if GameState.docks[dock_index]["worker_id"] != null:
			GameState.release_worker(dock_index)
			accept_event()
