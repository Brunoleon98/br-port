extends PainelNarrativo

# ============================================================
# BR Port VS — a tela de abertura: os dois nomes
#
# A PRIMEIRA coisa que o jogador vê. Ele batiza o cais (que substitui
# "Cais Mirim" em toda a interface e em todo diálogo) e diz o próprio nome
# (que os NPCs usam). O GDD 7 é explícito em que a escolha é IRREVOGÁVEL —
# não há tela de opções para a desfazer, e é de propósito: o nome do porto é
# o nome do legado.
#
# POR QUE ISTO É UM OVERLAY E NÃO UMA FASE DO JOGO.
#
# A tentação era criar uma fase `"nomes"` no GameState que bloqueasse o turno
# até os campos estarem preenchidos. Seria errado, e de um jeito que não daria
# erro nenhum: o `advance_turn()` retorna CALADO fora da fase `"playing"`
# (GameState.gd), e o laço do `simular_balanceamento.gd` só sabe resolver
# `rival_offer` e `debt_payment`. Uma fase nova faria o simulador girar até
# bater no limite de segurança de 300 voltas e contar a partida como travada —
# e o CI passaria assim mesmo, porque só procura a linha `=== Leitura ===`.
#
# Como overlay, a fase continua `"playing"` o tempo todo. O jogador não avança
# o dia porque o painel está por cima do botão, não porque o estado o proíbe.
# O simulador nunca abre cena nenhuma, então não vê esta tela e joga com os
# nomes-padrão: **o balanceamento medido fica intocado por construção, e não
# por cuidado de quem escreveu.**
#
# É também o padrão que todos os outros painéis já usam (`_abrir_painel` no
# Main.gd) — UpgradePanel, CounterOffer, DebtPayment e EndGame.
# ============================================================

# ── A FOLHA DE ROSTO DO DIÁRIO (`docs/decisoes/067`) ──
#
# Era um cartão branco com dois campos, e o pedido do Bruno foi «melhore isso,
# sendo que é a tela que vira logo depois de iniciar nova partida». A escolha
# dele (26/09): a folha de rosto do mesmo caderno que o diário é — a foto do
# porto colada, os dois nomes escritos à mão nas linhas impressas — e, ao
# abrir o porto, a folha VIRA para a primeira entrada.
#
# ⚠️ A VIRADA TEM O QUE REVELAR PORQUE HÁ DUAS PÁGINAS. A de baixo nasce em
# branco e pautada; ao abrir o porto, os nomes gravam-se, a entrada escreve-se
# nela (a mesma função do `PainelDiario`) e a de cima encolhe para a lombada.
# Quando ela some, o `fechou` sai e o `Main` abre o diário no MESMO retângulo,
# com a mesma página — é assim que duas telas leem como uma folha a virar.
#
# ⚠️ O TEXTO DA LEGENDA É O DE SEMPRE («O cais é seu» e a frase do Seu
# Maneco), fora da folha: é a voz de quem conta, e não a de quem escreve no
# diário. Os rótulos impressos mudaram (os dois do pedido que ele escolheu), e
# por isso passam pela leitura em voz alta do A4 como todo texto novo.

# A foto do porto de antigamente. PROVISÓRIA: céu e mar em sépia, sem porto
# nenhum, até a de verdade chegar do `art_lab/diario/` — é esta linha que
# muda.
const FOTO := preload("res://art/diario/foto_provisoria.svg")
const PainelDiarioScript := preload("res://scripts/PainelDiario.gd")
const FOTO_LARGURA := 500
const FOTO_ALTURA := 354
const FOTO_GIRO := -2.5

var _campo_porto: LineEdit
var _campo_jogador: LineEdit
var _legenda: Control
var _virando := false
# A página de baixo, guardada para a entrada se escrever nela na virada.
var _caixa_de_baixo: VBoxContainer
var _folha_de_baixo: Control
var _rosto: PanelContainer
var _folha_do_rosto: Control


func _ready() -> void:
	super()
	# Fechar esta tela BATIZA o cais, e o nome não muda depois. O Voltar do
	# Android é o único jeito de a dispensar sem se ler o que ela pede, então
	# é o único jeito de alguém ficar com um porto que não escolheu.
	fecha_com_voltar = false
	montar_caderno(ESCURO_LEITURA)
	# A página de BAIXO primeiro: a primeira entrada do diário, ainda em
	# branco. É ela que traz a fita, que é do livro e não da folha.
	_caixa_de_baixo = pagina_do_caderno(true, true, FolhaDoCaderno.Orelha.BAIXO)
	_folha_de_baixo = _folha
	pagina_atual().name = "PaginaSeguinte"

	var pagina := pagina_do_caderno(false, false, FolhaDoCaderno.Orelha.CIMA)
	_rosto = pagina_atual()
	_rosto.name = "FolhaDeRosto"
	_folha_do_rosto = _folha
	_legenda = legenda_acima_do_caderno("O cais é seu",
		"O Seu Maneco deixou o porto para você. Antes de abrir os portões, duas coisas.")

	foto_colada(FOTO, FOTO_LARGURA, FOTO_ALTURA, FOTO_GIRO)
	# A ETIQUETA ao meio do que sobra da folha. Na primeira passagem os campos
	# iam colados à foto e a nota no pé, com 200 px de papel vazio entre eles
	# («vazio na folha de rosto»); dentro do quadro impresso, com a nota, o
	# formulário passa a ser uma peça, e o vão divide-se por cima e por baixo.
	pagina.add_child(_vao_elastico())
	etiqueta_da_folha()

	impresso("Nome do cais")
	# O limite vem do GameState e não daqui: quem corta o nome ao gravar é o
	# `definir_nomes()`, e dois limites diferentes seriam duas regras.
	_campo_porto = _campo(GameState.NOME_PORTO_PADRAO)
	impresso("Este diário pertence a")
	# O campo do jogador é o único opcional dos dois, e a sugestão diz isso em
	# vez de deixar o jogador adivinhar: sem nome, as falas com vocativo têm
	# variante — ninguém fica sem forma de tratamento (ver Narrativa.gd).
	_campo_jogador = _campo("(pode deixar em branco)")

	# O aviso fecha a etiqueta, como a nota impressa de um formulário.
	impresso("O nome do cais não muda depois.")
	pagina.add_child(_vao_elastico())

	botao_abaixo_do_caderno("Abrir o porto")
	_campo_porto.grab_focus()


func _vao_elastico() -> Control:
	var vao := Control.new()
	vao.size_flags_vertical = Control.SIZE_EXPAND_FILL
	return vao


func _campo(sugestao: String) -> LineEdit:
	var entrada := campo_a_mao(sugestao)
	entrada.max_length = GameState.NOME_MAX_CARACTERES
	# Enter em qualquer um dos dois campos abre o porto: obrigar a acertar no
	# botão depois de digitar é atrito sem motivo, e no telefone o teclado
	# ainda estaria por cima dele.
	entrada.text_submitted.connect(func(_t: String) -> void: _fechar())
	return entrada


# Sobrepõe o fecho da base para GRAVAR ANTES DE SAIR. A base emite `fechou` e
# liberta o nó; se os nomes fossem gravados por um `pressed` ligado à parte, a
# ordem entre os dois passaria a depender da ordem de ligação dos sinais — e o
# diário que abre a seguir leria o nome do porto ainda vazio.
#
# ⚠️ E GRAVA ANTES DE VIRAR, não depois: a entrada que a virada revela usa o
# nome do cais. O `fechou` só sai no fim da virada — quem encadeia o diário
# nele abre-o no instante em que a folha de rosto desaparece.
func _fechar() -> void:
	if _virando:
		return
	_virando = true
	GameState.definir_nomes(_campo_porto.text, _campo_jogador.text)
	# O botão NÃO se desliga: o estilo desligado é um azul pálido que piscava
	# por meio segundo. Um segundo toque já não faz nada, pelo `_virando`.
	_campo_porto.editable = false
	_campo_jogador.editable = false
	# A sugestão impressa esconde-se ao escrever (`text_changed`), mas texto
	# posto por código não emite esse sinal: na virada ela ficava por baixo do
	# nome, lida através dele. O que o jogador vê a virar é o que escreveu.
	for campo in [_campo_porto, _campo_jogador]:
		(campo as LineEdit).get_node("Sugestao").visible = (campo as LineEdit).text == ""

	_vbox = _caixa_de_baixo
	_folha = _folha_de_baixo
	PainelDiarioScript.escrever(self)

	# A FOLHA CURVA, e o `fechou` sai no fim da virada. A virada vive no
	# andaime desde a `082`, porque o fim de fase vira a mesma folha.
	var t := virar_folha(_rosto, _folha_do_rosto, _folha_de_baixo, _legenda)
	t.tween_callback(_depois_de_virar)


func _depois_de_virar() -> void:
	super._fechar()
