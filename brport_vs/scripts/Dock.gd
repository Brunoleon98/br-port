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
# COORDENADAS cujo centro é a origem do mundo — a cena os ancora por aí, então
# trocar de textura nunca desloca o píer.
#
# ⚠️ E O PIXEL JÁ NÃO É A COORDENADA: desde a alavanca B o PNG tem 768 px
# dentro do mesmo quadro (`docs/decisoes/029`). Quem desfaz a diferença é o
# `expand_mode = 1` dos nós em `Dock.tscn`, e quem a traduz para uma régua é o
# `PropIso`. Este arquivo só troca texturas, então não tem conta nenhuma a
# fazer — mas o `pivot_offset` do nó `Lanca` é de COORDENADA, e o gerador
# imprime as duas linhas para não haver dúvida sobre qual copiar.
const ArtePierVazio := preload("res://art/props/pier_vazio.png")

# O PÍER E A LANÇA TÊM TRÊS NÍVEIS, e desde os upgrades quem escolhe são DUAS
# leituras — `nivel_pier()` e `nivel_guindaste()`, cada uma presa ao seu
# upgrade comprável. Eram uma só enquanto o nível era derivado da contagem de
# estruturas; separar foi o que impediu que comprar o guindaste engrossasse a
# laje do píer, que é o jogador ver mudar o que não comprou.
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

# OS CASCOS, por CLASSE e por MOTIVO da escala. Não são sprites ilustrados em
# 3/4: aqueles têm a perspectiva assada dentro da imagem e ficam atravessados
# em cima de um píer isométrico, que é o erro que já custou duas levas de arte.
#
# ⚠️ O `barco_medio` EXISTIA E NUNCA ENTRAVA EM DOCA até 05/09 — era gerado,
# validado e usado só como enfeite na Zona de Espera, porque o jogo escolhia
# entre dois cascos por um booleano. Depois disso passou a ser escolhido pelo
# VALOR do contrato; desde 06/09 é a CLASSE que o escolhe, que é a mesma
# informação sem o intermediário: a classe já traz a faixa de valor consigo.
#
# ⚠️ E DESDE 07/09 A CLASSE NÃO CHEGA. Os motivos da escala
# (`docs/decisoes/008`) deram ao jogo a informação de que carga cada navio
# traz, e os dois cargueiros continuavam a levar as mesmas caixinhas
# coloridas: a mecânica existia e o desenho não a dizia. Agora o casco sai do
# par (classe, motivo) — a classe dá o PORTE e o motivo dá o CONVÉS.
#
# ⚠️ O PESQUEIRO CONTINUA A NÃO MUDAR COM O MOTIVO, E ISSO É AFIRMAÇÃO. Ele
# chega com `pescado` ou com `armazenagem`, que é o mesmo peixe a ir para o
# mercado ou para a câmara do armazém — o DESTINO da carga muda, o barco não.
# Escrever a mesma lista duas vezes é o que faz esta tabela ser percorrível
# pelo D17 sem uma exceção escrita em código.
#
# ⚠️ E DESDE 08/09 CADA FOLHA É UMA LISTA, ordenada do menor porte para o
# maior. O eixo novo é o PORTE, e ele NÃO é o motivo: a trava de
# `docs/decisoes/009` prende o pesqueiro ao nível 1, então o porto em ruínas
# recebia o mesmo barco em todas as docas, em todos os turnos, a partida
# inteira. Quem escolhe entre os portes é o VALOR do contrato — um bote de
# linha não traz uma escala de R$28.000 —, e é por isso que a variedade não
# custou um sorteio: o valor já nasce com o barco (`docs/decisoes/014`).
#
# ⚠️ A LISTA DE UM ELEMENTO NÃO É UM CASO ESPECIAL, é a mesma tabela. As
# classes de carga separam-se pelo CONVÉS e não pelo porte, e escrevê-las com
# uma folha de um elemento é o que evita a forma variável — dicionário aqui e
# lista ali — que faria esta tabela deixar de se percorrer.
const CASCOS := {
	"pesqueiro": {
		"pescado": [
			preload("res://art/props/barco_pesca_bote.png"),
			preload("res://art/props/barco_pesca_traineira.png"),
			preload("res://art/props/barco_pesca_arrasteiro.png"),
		],
		"armazenagem": [
			preload("res://art/props/barco_pesca_bote.png"),
			preload("res://art/props/barco_pesca_traineira.png"),
			preload("res://art/props/barco_pesca_arrasteiro.png"),
		],
	},
	"medio": {
		"armazenagem": [preload("res://art/props/barco_medio_geral.png")],
		"conteiner": [preload("res://art/props/barco_medio_conteiner.png")],
		"granel": [preload("res://art/props/barco_medio_granel.png")],
	},
	"grande": {
		"armazenagem": [preload("res://art/props/barco_grande_geral.png")],
		"conteiner": [preload("res://art/props/barco_grande_conteiner.png")],
		"granel": [preload("res://art/props/barco_grande_granel.png")],
	},
}


# ── O TRABALHADOR QUE ANDA (02/10, `docs/decisoes/075`) ──
#
# Escolhas do Bruno: a animação sobe por DEGRAU do porto. No nível 1, que é
# o pau-de-carga, o trabalhador atravessa o tabuado — vai ao barco de frente
# e volta de costas com a carga ao ombro até uma pilha no meio do píer. No 2 o
# guindaste tira a carga do barco e ele desengata; no 3 vêm os pallets e a
# empilhadeira. Os dois de cima ainda não existem, e até lá a figura fica de
# pé, com o balanço de sempre.
#
# O quadro sai do SEXO de quem está alocado (lido do rosto dele, no
# `Retratos`) e do sentido: `vai` é o caminho para o barco, `volta` o caminho
# com a carga. Os três quadros de cada um são o passo — direita à frente, pés
# juntos, esquerda à frente —, e o do meio de `vai` é também o PARADO: é a
# mesma pose, e é isso que impede um salto quando ele pára.
const QUADROS_TRABALHADOR := {
	"h": {
		"vai": [
			preload("res://art/props/trab_h_vai_0.png"),
			preload("res://art/props/trabalhador.png"),
			preload("res://art/props/trab_h_vai_2.png"),
		],
		"volta": [
			preload("res://art/props/trab_h_volta_0.png"),
			preload("res://art/props/trab_h_volta_1.png"),
			preload("res://art/props/trab_h_volta_2.png"),
		],
	},
	"m": {
		"vai": [
			preload("res://art/props/trab_m_vai_0.png"),
			preload("res://art/props/trab_m_vai_1.png"),
			preload("res://art/props/trab_m_vai_2.png"),
		],
		"volta": [
			preload("res://art/props/trab_m_volta_0.png"),
			preload("res://art/props/trab_m_volta_1.png"),
			preload("res://art/props/trab_m_volta_2.png"),
		],
	},
}

# A CARGA E A PILHA, pelo par (classe, motivo) — a mesma chave do casco. O
# pesqueiro leva peixe nos DOIS motivos, pela razão que o `CASCOS` já escreve:
# a armazenagem dele é o mesmo peixe a ir para a câmara do armazém.
#
# ⚠️ SÓ O PESQUEIRO ESTÁ AQUI, e não é esquecimento: com o guindaste de nível
# 1 o porto só recebe o pesqueiro (`docs/decisoes/009`), e é só nesse nível
# que o trabalhador anda. O papelão e o saco foram desenhados e aprovados na
# mesma prancha e esperam o nível 2 no gerador (`PROXIMO_NIVEL`); pô-los aqui
# seria arte gerada que nenhum estado do jogo mostra. Quem tranca que toda
# classe alcançável no nível 1 tem a sua linha é o D37.
const CARGAS := {
	"pesqueiro": {
		"pescado": {
			"carga": preload("res://art/props/carga_peixe.png"),
			"pilha": preload("res://art/props/pilha_peixe.png"),
		},
		"armazenagem": {
			"carga": preload("res://art/props/carga_peixe.png"),
			"pilha": preload("res://art/props/pilha_peixe.png"),
		},
	},
}

# O CAMINHO, na tela: o gerador anda `CAMINHO_TRAB` (2,2) × a régua da pessoa
# (0,48) = 1,056 unidades no sentido `−my`, e uma unidade de `−my` vale
# (+20, −10) px de tela (`MEIA_LARG`, `MEIA_ALT` do `Main`). A pilha está
# desenhada no PNG um passo além disso. É o mesmo número em dois arquivos, e
# quem os amarra é o D37 a ler a pilha no render — nunca uma cópia.
const CAMINHO_TELA := Vector2(21.12, -10.56)

# O PASSO: o ciclo de poses 0-1-2-1 a 8 por segundo (meio segundo por ciclo,
# dois passos), e o trecho leva o tempo que o passo pede para os pés não
# deslizarem — medido no render, cada ciclo avança ~5,3 px de tela, e os
# 23,6 px do caminho dão 4,45 ciclos.
const POSES_DO_PASSO := [0, 1, 2, 1]
const PASSO_FPS := 8.0
const ANDAR_SEG := 2.2
const PAUSA_SEG := 0.35       # pegar no barco, largar na pilha


## A pose do trabalhador no instante `t` do ciclo de trabalho. É aritmética
## pura, e de propósito: o teste pergunta-lhe o ciclo inteiro sem esperar um
## frame, e o tween só a aplica.
##
## O ciclo começa no BARCO, a pegar a carga: pausa, volta com ela até à pilha,
## pausa a largá-la, e vai vazio ao barco outra vez.
static func pose_no_ciclo(t: float) -> Dictionary:
	t = fposmod(t, duracao_do_ciclo())
	if t < PAUSA_SEG:
		return {"fracao": 0.0, "sentido": "volta", "quadro": 1, "carga": true}
	t -= PAUSA_SEG
	if t < ANDAR_SEG:
		return {"fracao": t / ANDAR_SEG, "sentido": "volta",
			"quadro": _quadro_do_passo(t), "carga": true}
	t -= ANDAR_SEG
	if t < PAUSA_SEG:
		return {"fracao": 1.0, "sentido": "vai", "quadro": 1, "carga": false}
	t -= PAUSA_SEG
	return {"fracao": 1.0 - t / ANDAR_SEG, "sentido": "vai",
		"quadro": _quadro_do_passo(t), "carga": false}


static func duracao_do_ciclo() -> float:
	return 2.0 * (ANDAR_SEG + PAUSA_SEG)


static func _quadro_do_passo(t: float) -> int:
	return POSES_DO_PASSO[int(t * PASSO_FPS) % POSES_DO_PASSO.size()]


## O sexo de quem está alocado, pelo rosto dele: "h" ou "m".
static func sexo_do_trabalhador(worker_id: int) -> String:
	var w = GameState._find_worker(worker_id)
	return Retratos.sexo_do_rosto(int(w["rosto"]))


## Em que PORTE cai um contrato de `valor` nesta classe, entre `portes` faixas.
##
## ⚠️ A FAIXA INTEIRA DA CLASSE DIVIDIDA EM PARTES IGUAIS, e o `+ 1` não é
## enfeite: `randi_range` é fechado nas duas pontas, então entre `valor_min` e
## `valor_max` há `max - min + 1` inteiros. Sem ele o valor máximo cairia
## sozinho numa faixa a mais, que ficaria alcançável por UM valor em dezasseis
## mil — um porte gerado, validado e praticamente sem uso, que é a forma exata
## do buraco do `barco_medio`. O bloco D17 percorre a faixa e exige que todos
## os portes sejam alcançáveis.
static func porte_do_barco(classe: String, valor: int, portes: int) -> int:
	if portes <= 1:
		return 0
	var dados: Dictionary = GameState.CLASSES_DE_NAVIO[classe]
	var vmin: int = int(dados["valor_min"])
	var vmax: int = int(dados["valor_max"])
	@warning_ignore("integer_division")
	var faixa: int = ((valor - vmin) * portes) / (vmax - vmin + 1)
	return clampi(faixa, 0, portes - 1)


## O casco deste navio. Acesso DIRETO nos dois primeiros níveis: uma classe sem
## casco, ou um motivo que a classe possa sortear e para o qual não haja convés
## desenhado, têm de rebentar aqui e não desenhar o barco errado calados.
static func arte_do_barco(classe: String, motivo: String, valor: int) -> Texture2D:
	var portes: Array = CASCOS[classe][motivo]
	return portes[porte_do_barco(classe, valor, portes.size())]

var dock_index: int = -1

# Quem está selecionado na fileira de trabalhadores, ou -1. O Main mantém isto
# em dia; a doca só precisa saber para onde mandar o toque.
var trabalhador_selecionado: int = -1

# ── ANIMAÇÃO ──
# O barco, a lança e o realce são Tween sobre os sprites que já existem: o
# balanço dá vida ao barco parado, a chegada explica de onde ele veio, e o
# realce aponta a doca que pode receber o trabalhador escolhido. O trabalhador
# do nível 1 é o único que anda por QUADROS (`QUADROS_TRABALHADOR`, `075`).
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
# O que o trabalhador está a fazer, numa string. O `refresh()` corre a cada
# turno, compra e alocação, e recomeçar o tween a cada uma teletransportava-o
# de volta ao barco a meio do caminho; com a mesma assinatura, ele continua.
var _assinatura_trabalho := ""
var _quadros: Dictionary = {}

@onready var _pier: TextureRect = $Pier
@onready var _barco: TextureRect = $Barco
@onready var _trabalhador_prop: TextureRect = $Trabalhador
@onready var _carga: TextureRect = $Trabalhador/Carga
@onready var _pilha: TextureRect = $Pilha
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
	_refresh_cena()
	# Toda saída do `_refresh_cena()` que não mostra o trabalhador para-o
	# aqui, num sítio só: são quatro `return` antes dele, e a pilha esquecida
	# num deles ficaria no tabuado de uma doca vazia.
	if not _trabalhador_prop.visible:
		_parar_trabalho()


func _refresh_cena() -> void:
	_trabalhador_prop.visible = false
	# O realce só faz sentido se há alguém escolhido esperando um destino.
	_acender_realce(trabalhador_selecionado >= 0
		and GameState.doca_aceita_trabalhador(dock_index))

	# A lança só existe onde há píer: numa vaga por construir há só estacas.
	_mostrar_lanca(esta_construida())

	# Dois níveis independentes: o guindaste é do `guindaste`, a laje é do
	# `cais`. Uma leitura só faria o jogador ver mudar o que não comprou.
	var nivel_lanca: int = int(GameState.nivel_guindaste())
	var nivel_pier: int = int(GameState.nivel_pier())
	_lanca.texture = ArteLanca[nivel_lanca - 1]
	if not esta_construida():
		_pier.texture = ArtePierVazio
		_parar_barco()
		_barco.texture = null
		return

	_pier.texture = ArtePier[nivel_pier - 1]
	var dock: Dictionary = GameState.docks[dock_index]
	var boat = dock["boat"]

	if boat == null:
		_parar_barco()
		_barco.texture = null
		return

	_barco.texture = arte_do_barco(String(boat["classe"]), String(boat["motivo"]),
		int(boat["value"]))
	_animar_barco(int(boat["id"]))

	if boat.get("rival", false) and not boat.get("matched", false):
		return

	if dock["worker_id"] != null:
		# A figura no tabuado é o que faz "doca ocupada" ler sem texto.
		_trabalhador_prop.visible = true
		var carga: Dictionary = {}
		# Acesso DIRETO à tabela no nível 1, como no casco: uma classe que o
		# nível 1 receba sem carga desenhada tem de rebentar aqui, e não
		# deixar o trabalhador parado calado.
		if int(GameState.nivel_guindaste()) == 1:
			carga = CARGAS[String(boat["classe"])][String(boat["motivo"])]
		_animar_trabalho(int(boat["progress"]) > 0,
			sexo_do_trabalhador(int(dock["worker_id"])), carga)


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
#
# No nível 1 (`carga` preenchida) ele ANDA: o ciclo do `pose_no_ciclo()`, a
# carga ao ombro na volta e a pilha no tabuado. Nos níveis de cima, até terem
# a animação deles, fica o balanço de 3 px de sempre, já com a figura do sexo
# dele.
#
# ⚠️ NO NÍVEL 1 ELE ANDA ASSIM QUE É ALOCADO, e não com `progress > 0`, que
# é o «operando» do balanço. O pesqueiro serve num turno só: o `progress` chega
# a 1 no mesmo avanço em que o barco parte, e com ele atracado nunca passa de
# zero. Medido em 20 partidas, 449 instantes de trabalhador alocado a um barco
# no nível 1 e ZERO com `progress > 0` — a animação estaria escrita, ligada,
# validada e nunca tocaria, e o balanço antigo nunca tinha tocado ali. Para o
# jogador, alocado com o barco no berço é a trabalhar.
func _animar_trabalho(operando: bool, sexo: String, carga: Dictionary) -> void:
	var anda := not carga.is_empty()
	operando = operando or anda
	var assinatura := "%s|%s|%s|%s" % [operando, sexo, anda,
		carga["pilha"].resource_path if anda else ""]
	if assinatura == _assinatura_trabalho and _tw_trabalho != null \
			and _tw_trabalho.is_valid():
		return
	_parar_trabalho()
	_assinatura_trabalho = assinatura
	_quadros = QUADROS_TRABALHADOR[sexo]
	_trabalhador_prop.texture = _quadros["vai"][1]
	if not operando:
		return
	_tw_trabalho = create_tween().set_loops()
	if anda:
		_carga.texture = carga["carga"]
		_pilha.texture = carga["pilha"]
		_pilha.visible = true
		_aplicar_pose(0.0)
		_tw_trabalho.tween_method(_aplicar_pose, 0.0, duracao_do_ciclo(),
			duracao_do_ciclo())
		return
	_tw_trabalho.tween_property(_trabalhador_prop, "position:y",
		_trabalhador_base.y - 3.0, 0.42).set_trans(Tween.TRANS_SINE)
	_tw_trabalho.tween_property(_trabalhador_prop, "position:y",
		_trabalhador_base.y, 0.42).set_trans(Tween.TRANS_SINE)


func _aplicar_pose(t: float) -> void:
	var p := pose_no_ciclo(t)
	_trabalhador_prop.texture = _quadros[p["sentido"]][p["quadro"]]
	_trabalhador_prop.position = _trabalhador_base + CAMINHO_TELA * float(p["fracao"])
	_carga.visible = bool(p["carga"])


func _parar_trabalho() -> void:
	if _tw_trabalho != null and _tw_trabalho.is_valid():
		_tw_trabalho.kill()
	_assinatura_trabalho = ""
	_trabalhador_prop.position = _trabalhador_base
	_carga.visible = false
	_pilha.visible = false


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
