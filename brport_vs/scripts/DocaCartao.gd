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
# ⚠️ E DESDE A `083` ELE NÃO RECEBE TRABALHADOR NENHUM. O arrasto e o toque
# depois de escolher alguém na fileira morreram com a fileira: o trabalhador
# vai junto com o barco que se atraca a partir da linha «Ao largo». O toque
# aqui DEVOLVE o barco ao largo enquanto a operação não começou — é o
# «toque p/ liberar» de sempre, com o barco a voltar em vez de ficar sem
# ninguém.
# ============================================================

# ⚠️ AS DUAS CORES DESTE CARTÃO SAÍRAM DAQUI em 22/09, para o tema
# (`docs/decisoes/043`). O que era `COR_CALMA` é a variação
# `TextoDocaProgresso` e o que era `COR_ESPERANDO` é a `TextoDocaProgressoRival`
# — e os nomes ficam LITERAIS em cada ramo, nunca num dicionário nem por
# `StringName(var)`: o `conferir_escopo_ui.py` procura o nome depois do `=`, e
# um nome que ele não veja é um erro de digitação a cair no `Label` base sem
# uma palavra. Foi o mutante X6 da `042`, e este arquivo tinha-o vivo.

var dock_index: int = -1

const PULSO_SEG := 0.9
var _tw_pulso: Tween

@onready var _placa: Control = $Coluna/Cabecalho/Placa
@onready var _retrato: TextureRect = $Coluna/Cabecalho/Placa/Retrato
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
	_pintar_retrato()

	if not esta_construida():
		theme_type_variation = &"CartaoDocaObra"
		# SEM VALOR, SEM TRAÇO (`081`). O «—» ocupava o canto do número em
		# toda doca sem barco, e o olho parava nele a cada turno para ler
		# «nada» — a regra da linha com valor zero, num cartão. A linha de
		# baixo já diz porquê não há número.
		_valor.text = ""
		# «em ruínas» e não «por construir» (quarta passagem, «melhore o
		# texto»): é o que o mapa mostra por cima — as estacas do píer velho —,
		# e diz porquê sem pedir que se leia o painel Construir.
		_progresso.text = "píer em ruínas"
		_progresso.theme_type_variation = &"TextoDocaProgresso"
		_trabalhador.text = ""
		return

	var dock: Dictionary = GameState.docks[dock_index]
	var boat = dock["boat"]

	if boat == null:
		theme_type_variation = &"CartaoDoca"
		_valor.text = ""
		_progresso.text = texto_do_berco_livre(
			GameState.atracagem_pendente() != Vector2i.ZERO, GameState.fila.is_empty())
		_progresso.theme_type_variation = &"TextoDocaProgresso"
		_trabalhador.text = ""
		return

	var valor: int = int(boat["matched_value"]) if boat.get("matched", false) else int(boat["value"])
	_valor.text = GameState.moeda(valor)

	# O MOTIVO abre a linha do progresso, e não o cabeçalho. Medido a 06/09: o
	# interior do cartão dá 200px, e "DOCA 1 · Armazenagem" ao lado do valor a
	# 19px pede 233 — o nome mais longo estouraria o cartão sem erro nenhum,
	# só com o texto cortado. Na linha do progresso, a 13px, o pior caso cabe.
	var motivo: String = GameState.MOTIVOS[String(boat["motivo"])]["nome"]

	# ⚠️ A OFERTA DO RIVAL JÁ NÃO CHEGA AQUI (`083`): o Arlindo disputa o barco
	# AO LARGO, e um barco só atraca com a oferta resolvida. O ramo
	# `CartaoDocaRival` mudou-se para o `BarcoFila`.

	_progresso.text = texto_do_progresso(motivo, int(boat["progress"]),
		int(boat["op_turns"]))
	_progresso.theme_type_variation = &"TextoDocaProgresso"

	# Barco atracado SEM ninguém só acontece num estado que o jogo não monta
	# (atracar leva sempre o trabalhador); se acontecer, é o que tem de piscar.
	var esperando: bool = dock["worker_id"] == null and int(boat["progress"]) == 0
	if esperando:
		theme_type_variation = &"CartaoDocaEspera"
	else:
		theme_type_variation = &"CartaoDoca"
	_pulsar(esperando)

	if dock["worker_id"] == null:
		# A COR DESTE RÓTULO VEM DA CENA e não daqui. Até 21/09 os dois ramos
		# repintavam-no com o MESMO `COR_ESPERANDO` que o `DocaCartao.tscn` já
		# lhe dá (hoje a variação `TextoDocaTrabalhador`) — dois overrides que
		# não mudavam um pixel, e que calavam a
		# cena: mexer na cor lá não teria efeito nenhum, sem erro nenhum.
		_trabalhador.text = "sem trabalhador"
	else:
		_trabalhador_icone.visible = true
		_trabalhador.text = texto_do_trabalhador(int(dock["worker_id"]),
			boat.get("matched", false), int(boat["progress"]))


# OS TEXTOS DO CARTÃO SÃO FUNÇÕES, e não literais no `refresh()`, porque o
# D18 mede o pior caso de cada um: com literais dos dois lados, o teste media a
# CÓPIA, e um formato mudado aqui passaria verde lá.
#
# A linha do barco diz QUANDO O BERÇO VOLTA A ABRIR (quarta passagem, «o texto
# parece bem simples»): «parte amanhã», «parte em 2 dias». Era «1/2 dias», o
# progresso — certo e mudo; o que o jogador decide com ele é quando pode
# chamar o barco seguinte, e é isso que passou a estar escrito. «Parte» e não
# «sai»: na fila, o barco que se vai sem atracar «vai embora». O pior caso,
# «Armazenagem · parte em 3 dias», mede 198 de 200 px com um espaço de cada
# lado do ponto (205 com dois) — o D18 mede-o.
static func texto_do_progresso(motivo: String, feitos: int, total: int) -> String:
	var faltam := total - feitos
	if faltam <= 1:
		return "%s · parte amanhã" % motivo
	return "%s · parte em %s" % [motivo, Narrativa.concordar(faltam, "dia", "dias")]


# O berço livre diz o que fazer com ele: chamar um barco, se houver um pronto
# ao largo; senão, que não há quem chamar. Fora disso (o Arlindo a negociar o
# único barco, ou fora do jogo) fica só «livre», que é verdade sempre.
static func texto_do_berco_livre(ha_barco_pronto: bool, fila_vazia: bool) -> String:
	if ha_barco_pronto:
		return "livre — chame um barco"
	if fila_vazia:
		return "livre — ninguém ao largo"
	return "livre"


# Enquanto a operação não começou dá para desfazer a escolha: o barco volta ao
# largo com a paciência que tinha (`desatracar()`); depois, o trabalhador está
# a descarregar. Com acordo, o número do trabalhador sai — o retrato no
# cabeçalho já diz quem é —, e é o que deixa «acordo · toque p/ devolver»
# caber: 187 de 200 px, contra 213 com o «#3» à frente (medido; o D18 mede-o a
# cada corrida).
static func texto_do_trabalhador(wid: int, acordo: bool, feitos: int) -> String:
	if feitos == 0:
		if acordo:
			return "acordo · toque p/ devolver"
		return "#%d · toque p/ devolver" % wid
	if acordo:
		return "descarregando · acordo"
	return "#%d · descarregando" % wid



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


# A cara de quem trabalha neste píer: o alocado, se houver; senão a EQUIPE DO
# PÍER, o trabalhador nº N, à espera de barco. A cheio nos dois casos: a
# primeira passagem esbatia o da espera, e a 30 px ele lia-se como uma mancha
# cinzenta (pedido do Bruno). Píer por construir não tem equipe, e a placa sai.
func _pintar_retrato() -> void:
	var quem := -1
	if esta_construida():
		var wid = GameState.docks[dock_index]["worker_id"]
		if wid != null:
			quem = int(wid)
		elif dock_index < GameState.workers.size():
			quem = int(GameState.workers[dock_index]["id"])
	var w = GameState._find_worker(quem) if quem >= 0 else null
	_placa.visible = w != null
	if w == null:
		return
	var rosto := Retratos.do_trabalhador(int(w["rosto"]))
	if _retrato.texture != rosto:
		_retrato.texture = rosto


func _gui_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton and event.pressed
			and event.button_index == MOUSE_BUTTON_LEFT):
		return
	if not esta_construida():
		return
	if GameState.docks[dock_index]["boat"] != null:
		GameState.desatracar(dock_index)
		accept_event()
