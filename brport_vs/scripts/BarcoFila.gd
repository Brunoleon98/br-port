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

# O tracejado do lugar livre: um StyleBox não tem traço interrompido, então o
# cartão desenha-o, com a cor `borda` da variação `CartaoFilaVazia` do tema. O
# raio é o dos cartões da doca, para o lugar vazio ter a forma do cheio.
const TRACO := 7.0
const VAO_TRACO := 5.0
const RAIO := 12.0
const LARGURA_TRACO := 2.0

# Os portes do pesqueiro, do menor para o maior — a mesma ordem das folhas de
# `Dock.CASCOS`, e é por isso que o nome sai do MESMO `porte_do_barco()` que
# escolhe o casco: o cartão nunca diz «Bote» por cima de um arrasteiro.
const PORTES_DE_PESCA := ["Bote", "Traineira", "Arrasteiro"]
# As classes de carga têm um porte só; «Navio de longo curso» não cabe ao lado
# do valor a 19 px nos 200 px do cartão, e o nome curto é o que o cais diz.
const NOME_CURTO := {"medio": "Cargueiro", "grande": "Longo curso"}

const DockScript := preload("res://scripts/Dock.gd")

@onready var _casco_caixa: Control = $Coluna/Casco
@onready var _casco: TextureRect = $Coluna/Casco/Desenho
@onready var _cabecalho: Control = $Coluna/Cabecalho
@onready var _espera_linha: Control = $Coluna/EsperaLinha
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
	# Só o lugar livre se desenha à mão (o tracejado); o cheio é o StyleBox.
	queue_redraw()
	# O LUGAR LIVRE É ESPAÇO VAZIO (terceira passagem): sem fundo, borda
	# tracejada e o texto apagado ao centro. Na segunda vestia o cartão de obra
	# e pesava tanto como um barco. As outras linhas escondem-se para a coluna,
	# que alinha ao centro, o pôr a meio do cartão.
	var vazio: bool = b == null
	_casco_caixa.visible = not vazio
	_cabecalho.visible = not vazio
	_espera_linha.visible = not vazio
	_carga.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER if vazio \
		else HORIZONTAL_ALIGNMENT_LEFT
	if vazio:
		theme_type_variation = &"CartaoFilaVazia"
		_casco.texture = null
		_nome.text = ""
		_valor.text = ""
		_carga.text = "vaga no fundeadouro"
		_carga.theme_type_variation = &"TextoBarra"
		_espera.text = ""
		return

	var classe := String(b["classe"])
	var motivo := String(b["motivo"])
	var valor: int = int(b["matched_value"]) if b.get("matched", false) else int(b["value"])
	var recorte := PropIso.recorte(DockScript.arte_do_barco(classe, motivo, int(b["value"])))
	_casco.texture = recorte
	_casco.custom_minimum_size = recorte.get_size() * escala_dos_cascos()
	_nome.text = nome_do_barco(b).to_upper()
	_valor.text = GameState.moeda(valor)
	# Os dias que ele PRENDE O BERÇO, contados no porto de hoje: o barco pode
	# ter chegado antes do pórtico, e quem atraca agora descarrega com ele.
	var dias: int = GameState._turnos_de_operacao(classe, motivo)
	_carga.text = texto_da_carga(GameState.MOTIVOS[motivo]["nome"], dias)
	_carga.theme_type_variation = &"TextoDocaProgresso"

	if not GameState.barco_pronto(indice):
		theme_type_variation = &"CartaoDocaRival"
		_espera_icone.visible = true
		_espera.text = "Arlindo quer este cliente"
		_espera.theme_type_variation = &"TextoDocaProgressoRival"
		return

	var paciencia := int(b["paciencia"])
	_espera.text = texto_da_espera(paciencia, b.get("matched", false))
	# «Vai embora hoje» é a última chance, e a única linha em âmbar: é a que
	# muda a escolha — o barco mais barato que se vai contra o caro que fica.
	if paciencia <= 1:
		_espera.theme_type_variation = &"TextoDocaTrabalhador"
	else:
		_espera.theme_type_variation = &"TextoDocaProgresso"

	# HÁ BERÇO LIVRE? Então este barco é uma escolha à espera, e é o que a
	# barra precisa de mostrar — o que a doca à espera de trabalhador fazia
	# até à `083`.
	var atracavel: bool = GameState.atracagem_pendente() != Vector2i.ZERO
	theme_type_variation = &"CartaoDocaEspera" if atracavel else &"CartaoDoca"
	_pulsar(atracavel)


# OS TEXTOS DO CARTÃO SÃO FUNÇÕES pela razão do `DocaCartao`: o D18 mede o
# pior caso de cada um a partir DAQUI, e não de uma cópia.
#
# Quanto tempo o barco PRENDE O BERÇO: «Pescado · fica 1 dia». Era «1 dia no
# berço» (quarta passagem, «o texto parece bem simples»): o mesmo número, dito
# como se diz de quem chega — e 33 px mais curto no pior caso, «Armazenagem ·
# fica 3 dias» (164 de 200).
static func texto_da_carga(nome_do_motivo: String, dias: int) -> String:
	return "%s · fica %s" % [nome_do_motivo, Narrativa.concordar(dias, "dia", "dias")]


# Quanto tempo ele ainda ESPERA AO LARGO. A paciência conta o dia de hoje: com
# 1 ele vai-se na virada do dia, se ninguém o chamar; com 2 ainda cá está
# amanhã. Era «sai amanhã» e «espera 2 dias», que contavam o dia por outra
# régua: o de paciência 1 já não está cá amanhã, e «sai amanhã» deixava
# entender que estava. O complemento fica FORA do
# `concordar()`: o F9 exige que a forma plural esteja toda no plural.
# O acordo cola-se com UM espaço de cada lado: «aguarda mais 1 dia · acordo»
# mede 195 de 200 px, e com dois passaria (202).
static func texto_da_espera(paciencia: int, acordo: bool) -> String:
	var texto := "vai embora hoje" if paciencia <= 1 \
		else "aguarda mais %s" % Narrativa.concordar(paciencia - 1, "dia", "dias")
	if acordo:
		texto += " · acordo"
	return texto


# OS CASCOS NUMA ESCALA SÓ: a do maior recorte da tabela a encher os 70 px da
# caixa. Medido nos PNG: o longo curso tem 130 px de altura e o bote 61, logo
# o bote sai com 33 e lê-se como bote. Derivada da tabela `Dock.CASCOS`, e não
# escrita: um casco maior que entre na frota encolhe os outros em vez de sair
# do cartão. Calcula-se uma vez.
static var _escala := 0.0

static func escala_dos_cascos() -> float:
	if _escala > 0.0:
		return _escala
	var maior := 0.0
	for classe in DockScript.CASCOS:
		for motivo in DockScript.CASCOS[classe]:
			for tex in DockScript.CASCOS[classe][motivo]:
				maior = maxf(maior, PropIso.recorte(tex).get_size().y)
	_escala = ALTURA_DOS_CASCOS / maior
	return _escala

const ALTURA_DOS_CASCOS := 70.0


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


func _draw() -> void:
	if barco() != null:
		return
	var cor := get_theme_color(&"borda", &"CartaoFilaVazia")
	var meia := LARGURA_TRACO / 2.0
	var pontos := _contorno(Rect2(Vector2(meia, meia), size - Vector2.ONE * LARGURA_TRACO),
		RAIO - meia)
	# Anda pelo contorno e liga/desliga a caneta a cada TRACO/VAO_TRACO px: o
	# tracejado dobra as quinas redondas em vez de parar nelas.
	var ligado := true
	var falta := TRACO
	var traco: PackedVector2Array = [pontos[0]]
	for i in range(1, pontos.size()):
		var a: Vector2 = pontos[i - 1]
		var z: Vector2 = pontos[i]
		var resto := a.distance_to(z)
		while resto > 0.0:
			var passo := minf(falta, resto)
			a = a.move_toward(z, passo)
			resto -= passo
			falta -= passo
			if ligado:
				traco.append(a)
			if falta <= 0.0:
				if ligado and traco.size() > 1:
					draw_polyline(traco, cor, LARGURA_TRACO, true)
				ligado = not ligado
				falta = TRACO if ligado else VAO_TRACO
				traco = [a]
	if ligado and traco.size() > 1:
		draw_polyline(traco, cor, LARGURA_TRACO, true)


# O contorno de um retângulo de quinas redondas, fechado, com oito pontos por
# quina.
static func _contorno(r: Rect2, raio: float) -> PackedVector2Array:
	var p: PackedVector2Array = []
	var centros := [
		Vector2(r.end.x - raio, r.position.y + raio),
		Vector2(r.end.x - raio, r.end.y - raio),
		Vector2(r.position.x + raio, r.end.y - raio),
		Vector2(r.position.x + raio, r.position.y + raio)]
	for q in 4:
		for k in 9:
			var ang := -PI / 2.0 + (q + k / 8.0) * PI / 2.0
			p.append(centros[q] + Vector2(cos(ang), sin(ang)) * raio)
	p.append(p[0])
	return p


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
