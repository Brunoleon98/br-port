class_name PainelNarrativo
extends Control

# ============================================================
# BR Port VS — o andaime comum das telas narrativas
#
# Cinco das sete telas do A4 têm a mesma forma: escurece o fundo, abre um
# cartão no meio, põe título, texto e um botão. Os painéis que já existiam
# (Upgrade, CounterOffer, DebtPayment, EndGame) repetem esse andaime cada um
# por si — o que era aceitável com quatro e deixa de ser com nove.
#
# Não é refatoração dos antigos: eles ficam como estão, porque mexer neles sem
# necessidade é arriscar o que já foi jogado. Isto é o chão dos novos.
#
# O QUE ELE NÃO FAZ: pintar cor. Toda a aparência vem de `ui/tema_brport.tres`
# — cartão, botão, fonte —, que é o ponto único de estilo do projeto. O único
# valor de cor aqui é a opacidade do escurecimento, que não é cor de marca: é
# quanto do jogo se continua a ver por trás da tela.
# ============================================================

# Quanto o fundo escurece. As telas de leitura escurecem MAIS do que os painéis
# de decisão: numa tela de decisão o jogador quer ver o porto para decidir; num
# diário ou numa despedida, o porto atrás é distração.
const ESCURO_LEITURA := 0.88
const ESCURO_DECISAO := 0.7

# Alvo de toque mínimo (iOS/Android), o mesmo piso que o `teste_design.gd`
# exige do resto da interface.
const TOQUE_MIN := 44

# Emitido quando o painel se fecha. É o que permite encadear a abertura do
# jogo — os nomes, e a seguir o diário — sem cada painel saber quem vem depois.
signal fechou

var _vbox: VBoxContainer


func _ready() -> void:
	anchor_right = 1.0
	anchor_bottom = 1.0


# Monta o andaime e devolve a caixa onde o conteúdo entra.
#
# ALTURA 0 QUER DIZER "AJUSTA AO CONTEÚDO", e é o que quase todos querem. Com
# altura fixa o cartão fica maior do que o texto e sobra uma faixa branca
# debaixo do botão — apareceu em três painéis de uma vez na primeira captura.
# Pior: o mesmo painel muda de tamanho conforme o caso (o boletim ganha a linha
# da parcela na semana 4, o Sr. Ribeiro perde um botão quando há dinheiro), de
# modo que NENHUMA altura fixa serve às duas versões.
#
# Altura fixa continua a existir para quem tem área de rolagem: aí o tamanho é
# uma decisão de leitura, não uma consequência do texto.
func montar(largura: int, altura: int, escuro: float = ESCURO_LEITURA) -> VBoxContainer:
	var fundo := ColorRect.new()
	fundo.color = Color(0, 0, 0, escuro)
	fundo.anchor_right = 1.0
	fundo.anchor_bottom = 1.0
	add_child(fundo)

	var caixa := PanelContainer.new()
	caixa.anchor_left = 0.5
	caixa.anchor_top = 0.5
	caixa.anchor_right = 0.5
	caixa.anchor_bottom = 0.5
	caixa.offset_left = -largura / 2.0
	caixa.offset_right = largura / 2.0
	if altura > 0:
		caixa.offset_top = -altura / 2.0
		caixa.offset_bottom = altura / 2.0
	else:
		# Sem offsets verticais a caixa tem altura zero; `GROW_DIRECTION_BOTH`
		# manda-a crescer para cima e para baixo a partir do centro, à medida
		# do tamanho mínimo que os filhos pedem.
		caixa.grow_vertical = Control.GROW_DIRECTION_BOTH
	add_child(caixa)

	_vbox = VBoxContainer.new()
	_vbox.add_theme_constant_override("separation", 10)
	caixa.add_child(_vbox)
	return _vbox


# Um bloco de texto que quebra sozinho. Praticamente todo o conteúdo narrativo
# é isto, e esquecer o autowrap é o que faz a fala sair numa linha só, cortada
# na borda do cartão.
func paragrafo(texto: String) -> Label:
	var rotulo := Label.new()
	rotulo.autowrap_mode = TextServer.AUTOWRAP_WORD
	rotulo.text = texto
	_vbox.add_child(rotulo)
	return rotulo


# Texto comprido dentro de uma área que rola. A página do diário e a narração
# de fim de fase não cabem nos 1280px de altura do retrato com o resto da
# interface à volta, e um Label que estoure o cartão desenha POR FORA dele.
func paragrafo_rolavel(texto: String, altura: int) -> ScrollContainer:
	var rolo := ScrollContainer.new()
	rolo.custom_minimum_size = Vector2(0, altura)
	rolo.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_vbox.add_child(rolo)

	var rotulo := Label.new()
	rotulo.autowrap_mode = TextServer.AUTOWRAP_WORD
	rotulo.text = texto
	# Sem isto o Label toma a largura que quiser e o rolo cresce na horizontal,
	# que é justamente o que o modo desligado acima não consegue impedir
	# sozinho.
	rotulo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rolo.add_child(rotulo)
	return rolo


func titulo(icone: Texture2D, texto: String) -> void:
	_vbox.add_child(Icones.rotulo(icone, texto, Icones.TAM_TITULO, true))


# O botão que fecha. Devolvê-lo permite ao painel concreto ligar mais alguma
# coisa ao mesmo clique, sem precisar de um segundo botão.
func botao_fechar(texto: String) -> Button:
	var botao := Button.new()
	botao.text = texto
	botao.custom_minimum_size = Vector2(0, TOQUE_MIN)
	botao.pressed.connect(_fechar)
	_vbox.add_child(botao)
	return botao


func _fechar() -> void:
	fechou.emit()
	queue_free()
