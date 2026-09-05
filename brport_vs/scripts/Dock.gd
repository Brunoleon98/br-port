extends Control

# Vaga de doca no mapa do porto — a metade de CENÁRIO de uma doca.
#
# Desde o Bloco 4 a doca não é mais um cartão numa fileira: é uma POSIÇÃO no
# mapa visto de cima. O mapa desenha 3 vagas fixas; quantas estão construídas
# vem de GameState.docks. A vaga além do que existe mostra o píer por
# construir — é o que faz "Reconstruir o píer" ter consequência visível no
# mapa em vez de só somar um cartão.
#
# O TEXTO NÃO MORA MAIS AQUI. Ele desceu para DocaCartao.tscn, na barra sob o
# mapa: a chip escura pousada no tabuado tapava justamente o barco, o
# guindaste e o trabalhador que explicam o turno. O que ficou foi o alvo de
# arrasto e um realce que acende quando esta doca aceita quem está selecionado.
#
# A árvore de nós mora em Dock.tscn e o estilo no tema. Este script não
# constrói nem pinta nada: só escolhe qual textura e qual animação valem agora.

# Props ISOMÉTRICOS, gerados por tools/gerar_props_iso.py. São quadros de 512
# cujo centro é a origem do mundo — a cena os ancora por aí, então trocar de
# textura nunca desloca o píer.
const ArtePierVazio := preload("res://art/props/pier_vazio.png")

# O PÍER E A LANÇA TÊM TRÊS NÍVEIS, e quem escolhe é `GameState.nivel_porto()`
# — uma leitura do que já está construído, não uma mecânica nova. O GDD 7
# decidiu os três níveis; a arte existe desde já, como a vila, que cresce por
# `--nivel-vila=N` sem o jogo precisar saber disso.
#
# ⚠️ AS TRÊS LANÇAS GIRAM NO MESMO PONTO. O `pivot_offset` do nó `Lanca` é UM,
# e as três foram construídas a partir do mesmo topo de torre para caberem
# nele. O bloco D17 do teste de design tranca isso.
const ArtePier := [
	preload("res://art/props/pier_n1.png"),
	preload("res://art/props/pier_n2.png"),
	preload("res://art/props/pier_n3.png"),
]
const ArteLanca := [
	preload("res://art/props/lanca_n1.png"),
	preload("res://art/props/lanca_n2.png"),
	preload("res://art/props/lanca_n3.png"),
]

# OS TRÊS CASCOS, escolhidos pelo VALOR do contrato. Não são sprites ilustrados
# em 3/4: aqueles têm a perspectiva assada dentro da imagem e ficam atravessados
# em cima de um píer isométrico, que é o erro que já custou duas levas de arte.
#
# ⚠️ O `barco_medio` EXISTIA E NUNCA ENTRAVA EM DOCA. Ele era gerado, validado
# pelo `asset_validator` e usado só como enfeite na Zona de Espera: o jogo
# escolhia entre dois cascos por um booleano. O valor do contrato já vai de
# R$8.000 a R$70.000 e não custava nada dizê-lo com o casco — é a mesma
# informação que o cartão dá em número, dita pela silhueta.
const ArtePequeno := preload("res://art/props/barco_pequeno.png")
const ArteMedio := preload("res://art/props/barco_medio.png")
const ArteGrande := preload("res://art/props/barco_grande.png")


## O casco que um contrato deste valor merece. O corte fica no meio da faixa
## dos grandes, que é onde o `_make_boat()` já separa as duas gerações — assim
## a silhueta acompanha o número em vez de inventar uma escala própria.
static func arte_do_barco(valor: int, grande: bool) -> Texture2D:
	if not grande:
		return ArtePequeno
	var meio: int = (GameState.BOAT_VALUE_LARGE_MIN
		+ GameState.BOAT_VALUE_LARGE_MAX) / 2
	return ArteGrande if valor >= meio else ArteMedio

var dock_index: int = -1

# Quem está selecionado na fileira de trabalhadores, ou -1. O Main mantém isto
# em dia; a doca só precisa saber para onde mandar o toque.
var trabalhador_selecionado: int = -1

# ── ANIMAÇÃO ──
# Nada aqui precisa de arte nova: é Tween sobre os sprites que já existem.
# O balanço dá vida ao barco parado; a chegada explica de onde ele veio; e o
# realce aponta a doca que pode receber o trabalhador escolhido.
const BALANCO_PX := 5.0
const BALANCO_SEG := 1.7
const CHEGADA_SEG := 0.5
const PULSO_SEG := 0.9
const REALCE := Color(1.45, 1.22, 0.72)

var _barco_base := Vector2.ZERO
var _trabalhador_base := Vector2.ZERO
var _barco_id_anterior: int = -1
var _tw_balanco: Tween
var _tw_chegada: Tween
var _tw_realce: Tween
var _tw_trabalho: Tween
var _tw_lanca: Tween

@onready var _pier: TextureRect = $Pier
@onready var _barco: TextureRect = $Barco
@onready var _trabalhador_prop: TextureRect = $Trabalhador
@onready var _lanca: TextureRect = $Lanca


func setup(index: int) -> void:
	dock_index = index
	# setup() pode ser chamado antes de a cena entrar na árvore, quando os
	# @onready ainda são null. Nesse caso o refresh acontece no _ready().
	if is_node_ready():
		refresh()


func _ready() -> void:
	# Guardar a posição de repouso é obrigatório: num Control o `position` É o
	# offset, então zerá-lo não "volta ao lugar" — atira o nó para o canto do
	# pai e apaga a ancoragem da cena.
	_barco_base = _barco.position
	_trabalhador_base = _trabalhador_prop.position
	if dock_index >= 0:
		refresh()


func esta_construida() -> bool:
	return dock_index >= 0 and dock_index < GameState.docks.size()


func refresh() -> void:
	if dock_index < 0:
		return

	_trabalhador_prop.visible = false
	# O realce só faz sentido se há alguém escolhido esperando um destino.
	_acender_realce(trabalhador_selecionado >= 0
		and GameState.doca_aceita_trabalhador(dock_index))

	# A lança só existe onde há píer: numa vaga por construir há só estacas.
	_mostrar_lanca(esta_construida())

	var nivel: int = int(GameState.nivel_porto())
	_lanca.texture = ArteLanca[nivel - 1]
	if not esta_construida():
		_pier.texture = ArtePierVazio
		_parar_barco()
		_barco.texture = null
		return

	_pier.texture = ArtePier[nivel - 1]
	var dock: Dictionary = GameState.docks[dock_index]
	var boat = dock["boat"]

	if boat == null:
		_parar_barco()
		_barco.texture = null
		return

	_barco.texture = arte_do_barco(int(boat["value"]), boat.get("large", false))
	_animar_barco(int(boat["id"]))

	if boat.get("rival", false) and not boat.get("matched", false):
		return

	if dock["worker_id"] != null:
		# A figura no tabuado é o que faz "doca ocupada" ler sem texto.
		_trabalhador_prop.visible = true
		_animar_trabalho(int(boat["progress"]) > 0)


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


# ── as animações ──
func _parar_barco() -> void:
	_barco_id_anterior = -1
	for tw in [_tw_balanco, _tw_chegada]:
		if tw != null and tw.is_valid():
			tw.kill()
	_barco.position = _barco_base


func _animar_barco(barco_id: int) -> void:
	if barco_id == _barco_id_anterior:
		return                      # mesmo barco: já está balançando
	var era_outro := _barco_id_anterior != -1
	_barco_id_anterior = barco_id

	if _tw_chegada != null and _tw_chegada.is_valid():
		_tw_chegada.kill()
	if _tw_balanco != null and _tw_balanco.is_valid():
		_tw_balanco.kill()

	# Barco novo entra deslizando do lado da zona de espera; o que já estava
	# aqui (ao recarregar um save) simplesmente aparece.
	if not era_outro:
		_barco.position = _barco_base
		_iniciar_balanco()
		return

	_barco.position = _barco_base + Vector2(90, -45)
	_barco.modulate.a = 0.0
	_tw_chegada = create_tween().set_parallel(true)
	_tw_chegada.tween_property(_barco, "position", _barco_base, CHEGADA_SEG) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tw_chegada.tween_property(_barco, "modulate:a", 1.0, CHEGADA_SEG * 0.6)
	_tw_chegada.chain().tween_callback(_iniciar_balanco)


func _iniciar_balanco() -> void:
	_barco.modulate.a = 1.0
	if _tw_balanco != null and _tw_balanco.is_valid():
		_tw_balanco.kill()
	_tw_balanco = create_tween().set_loops()
	_tw_balanco.tween_property(_barco, "position:y",
		_barco_base.y - BALANCO_PX, BALANCO_SEG).set_trans(Tween.TRANS_SINE)
	_tw_balanco.tween_property(_barco, "position:y",
		_barco_base.y, BALANCO_SEG).set_trans(Tween.TRANS_SINE)


# "Solte aqui": o PRÓPRIO PÍER acende, em vez de uma moldura por cima dele.
# A primeira versão era um retângulo âmbar arredondado sobre a vaga, e num
# cenário isométrico um retângulo alinhado à tela não pertence a nada — lia
# como recorte de interface pousado no mapa. Iluminar o sprite segue a forma
# real do píer e não introduz geometria nova.
#
# Pisca devagar: com três vagas acesas ao mesmo tempo, brilho fixo vira
# decoração e deixa de apontar.
func _acender_realce(ligado: bool) -> void:
	if _tw_realce != null and _tw_realce.is_valid():
		_tw_realce.kill()
	if not ligado:
		_pier.modulate = Color.WHITE
		return
	_tw_realce = create_tween().set_loops()
	_tw_realce.tween_property(_pier, "modulate", REALCE, PULSO_SEG) \
		.set_trans(Tween.TRANS_SINE)
	_tw_realce.tween_property(_pier, "modulate", Color.WHITE, PULSO_SEG) \
		.set_trans(Tween.TRANS_SINE)


# Enquanto a operação corre, o trabalhador se mexe. Parado, fica de pé.
func _animar_trabalho(operando: bool) -> void:
	if _tw_trabalho != null and _tw_trabalho.is_valid():
		_tw_trabalho.kill()
	_trabalhador_prop.position = _trabalhador_base
	if not operando:
		return
	_tw_trabalho = create_tween().set_loops()
	_tw_trabalho.tween_property(_trabalhador_prop, "position:y",
		_trabalhador_base.y - 3.0, 0.42).set_trans(Tween.TRANS_SINE)
	_tw_trabalho.tween_property(_trabalhador_prop, "position:y",
		_trabalhador_base.y, 0.42).set_trans(Tween.TRANS_SINE)


# A lança do guindaste varre devagar. É o único movimento do porto que não
# depende de haver barco — dá sinal de vida a uma doca vazia.
func _mostrar_lanca(ligado: bool) -> void:
	_lanca.visible = ligado
	if _tw_lanca != null and _tw_lanca.is_valid():
		_tw_lanca.kill()
	if not ligado:
		return
	# Fase por doca, senão as três varrem como um só mecanismo.
	var fase := 0.9 * float(max(dock_index, 0))
	_tw_lanca = create_tween().set_loops()
	if fase > 0.0:
		_tw_lanca.tween_interval(fase)
	_tw_lanca.tween_property(_lanca, "rotation", 0.13, 3.4).set_trans(Tween.TRANS_SINE)
	_tw_lanca.tween_property(_lanca, "rotation", -0.05, 3.4).set_trans(Tween.TRANS_SINE)
