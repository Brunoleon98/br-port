extends PanelContainer

# ============================================================
# BR Port VS — um barco ao largo (a linha «Ao largo» do HUD, `083`)
#
# É o cartão de um lugar da FILA no fundeadouro: o casco em miniatura, o nome
# do porte, o valor, a carga com os dias que prende o berço, e quanto tempo
# ele ainda espera. Tocar atraca-o no primeiro berço livre, com o trabalhador
# do píer — a escolha que o jogo passou a pedir em 04/10, no lugar do
# «Alocar todos» que acertava sempre.
#
# Veste as variações da DOCA (`CartaoDoca*`, `TextoDoca*`) e não variações
# próprias: são o mesmo cartão escuro sobre o mesmo fundo, já medidas pelo
# D33 nos quatro estados, e uma cópia com outro nome seria a mesma cor escrita
# duas vezes. Os nomes ficam LITERAIS em cada ramo, pela regra do
# `DocaCartao` (`043`): o `conferir_escopo_ui.py` procura-os depois do `=`.
# ============================================================

# O lugar da fila que este cartão mostra (0, 1, 2), e não um barco: a fila
# anda, e o cartão do lugar 0 mostra sempre quem chegou primeiro.
var indice: int = -1

const PULSO_SEG := 0.9
var _tw_pulso: Tween

# Os portes do pesqueiro, do menor para o maior — a mesma ordem das folhas de
# `Dock.CASCOS`, e é por isso que o nome sai do MESMO `porte_do_barco()` que
# escolhe o casco: o cartão nunca diz «Bote» por cima de um arrasteiro.
const PORTES_DE_PESCA := ["Bote", "Traineira", "Arrasteiro"]
# As classes de carga têm um porte só; «Navio de longo curso» não cabe ao lado
# do valor a 19 px nos 200 px do cartão, e o nome curto é o que o cais diz.
const NOME_CURTO := {"medio": "Cargueiro", "grande": "Longo curso"}

const DockScript := preload("res://scripts/Dock.gd")

@onready var _casco: TextureRect = $Coluna/Casco
@onready var _nome: Label = $Coluna/Cabecalho/Nome
@onready var _valor: Label = $Coluna/Cabecalho/Valor
@onready var _carga: Label = $Coluna/Carga
@onready var _espera: Label = $Coluna/EsperaLinha/Espera
@onready var _espera_icone: TextureRect = $Coluna/EsperaLinha/Icone


func setup(i: int) -> void:
	indice = i
	if is_node_ready():
		refresh()


func _ready() -> void:
	if indice >= 0:
		refresh()


## O barco deste lugar, ou null se o lugar está vazio.
func barco() -> Variant:
	if indice < 0 or indice >= GameState.fila.size():
		return null
	return GameState.fila[indice]


## O nome que o cartão escreve: o porte, no pesqueiro; a classe, no resto.
static func nome_do_barco(b: Dictionary) -> String:
	var classe := String(b["classe"])
	if classe == "pesqueiro":
		var portes: int = PORTES_DE_PESCA.size()
		return PORTES_DE_PESCA[DockScript.porte_do_barco(classe, int(b["value"]), portes)]
	return String(NOME_CURTO[classe])


func refresh() -> void:
	# Chamado de fora antes de o nó estar pronto, como o cartão do trabalhador
	# era: os `@onready` ainda são null e o erro não reprova suíte nenhuma.
	if not is_node_ready() or indice < 0:
		return
	_espera_icone.visible = false
	_pulsar(false)

	var b = barco()
	if b == null:
		theme_type_variation = &"CartaoDocaObra"
		_casco.texture = null
		_nome.text = ""
		_valor.text = ""
		_carga.text = "lugar livre"
		_carga.theme_type_variation = &"TextoDocaProgresso"
		_espera.text = ""
		return

	var classe := String(b["classe"])
	var motivo := String(b["motivo"])
	var valor: int = int(b["matched_value"]) if b.get("matched", false) else int(b["value"])
	_casco.texture = PropIso.recorte(DockScript.arte_do_barco(classe, motivo, int(b["value"])))
	_nome.text = nome_do_barco(b).to_upper()
	_valor.text = GameState.moeda(valor)
	# Os dias que ele PRENDE O BERÇO, contados no porto de hoje: o barco pode
	# ter chegado antes do pórtico, e quem atraca agora descarrega com ele.
	var dias: int = GameState._turnos_de_operacao(classe, motivo)
	# O complemento fica FORA do `concordar()`: o F9 exige que toda palavra da
	# forma plural esteja no plural, e «no berço» é o mesmo nas duas.
	# ⚠️ UM ESPAÇO de cada lado do ponto, e não os dois do cartão da doca: o
	# pior caso, «Armazenagem · 3 dias no berço», pedia 203 px nos 200 do
	# cartão com os dois (o D18 apanhou-o no dia em que foi escrito).
	_carga.text = "%s · %s no berço" % [GameState.MOTIVOS[motivo]["nome"],
		Narrativa.concordar(dias, "dia", "dias")]
	_carga.theme_type_variation = &"TextoDocaProgresso"

	if not GameState.barco_pronto(indice):
		theme_type_variation = &"CartaoDocaRival"
		_espera_icone.visible = true
		_espera.text = "oferta do rival"
		_espera.theme_type_variation = &"TextoDocaProgressoRival"
		return

	var paciencia := int(b["paciencia"])
	# «Sai amanhã» é a última chance, e a única linha em âmbar: é a que muda a
	# escolha — o barco mais barato que vai embora contra o caro que fica.
	if paciencia <= 1:
		_espera.text = "sai amanhã"
		_espera.theme_type_variation = &"TextoDocaTrabalhador"
	else:
		_espera.text = "espera %s" % Narrativa.concordar(paciencia, "dia", "dias")
		_espera.theme_type_variation = &"TextoDocaProgresso"
	if b.get("matched", false):
		_espera.text += "  ·  acordo"

	# HÁ BERÇO LIVRE? Então este barco é uma escolha à espera, e é o que a
	# barra precisa de mostrar — o que a doca à espera de trabalhador fazia
	# até à `083`.
	var atracavel: bool = GameState.atracagem_pendente() != Vector2i.ZERO
	theme_type_variation = &"CartaoDocaEspera" if atracavel else &"CartaoDoca"
	_pulsar(atracavel)


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


func _gui_input(event: InputEvent) -> void:
	# No RELEASE, como o cartão do trabalhador fazia: um dedo que arrasta pela
	# barra não atraca nada por ter passado por cima.
	if not (event is InputEventMouseButton and not event.pressed
			and event.button_index == MOUSE_BUTTON_LEFT):
		return
	if barco() == null:
		return
	GameState.atracar(indice)
	accept_event()
