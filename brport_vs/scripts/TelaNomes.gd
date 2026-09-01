extends Control

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

const LARGURA := 340
const ALTURA := 300

# Alvo de toque mínimo das diretrizes de iOS e Android, o mesmo que o
# `teste_design.gd` exige do resto da interface. Um campo de texto é alvo de
# toque como qualquer botão.
const ALTURA_CAMPO := 44

var _campo_porto: LineEdit
var _campo_jogador: LineEdit


func _ready() -> void:
	anchor_right = 1.0
	anchor_bottom = 1.0
	_construir()


func _construir() -> void:
	var fundo := ColorRect.new()
	fundo.color = Color(0, 0, 0, 0.85)
	fundo.anchor_right = 1.0
	fundo.anchor_bottom = 1.0
	add_child(fundo)

	var caixa := PanelContainer.new()
	caixa.anchor_left = 0.5
	caixa.anchor_top = 0.5
	caixa.anchor_right = 0.5
	caixa.anchor_bottom = 0.5
	caixa.offset_left = -LARGURA / 2.0
	caixa.offset_top = -ALTURA / 2.0
	caixa.offset_right = LARGURA / 2.0
	caixa.offset_bottom = ALTURA / 2.0
	add_child(caixa)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	caixa.add_child(vbox)

	# ACORDO e não DOCA, e o Icones.gd avisa por escrito porquê: `doca` é traço
	# creme e só sobrevive em fundo ESCURO — neste painel branco ele sai como um
	# fantasma pálido, o que a primeira captura mostrou. `acordo` é navy com
	# âmbar, aguenta os dois fundos, e ainda diz a coisa certa: o porto está a
	# passar de mão.
	vbox.add_child(Icones.rotulo(Icones.ACORDO, "O cais é seu"))

	var intro := Label.new()
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD
	intro.text = "O Seu Maneco deixou o porto para você. Antes de abrir os portões, duas coisas."
	vbox.add_child(intro)

	_campo_porto = _campo(vbox, "Como o cais vai se chamar",
		GameState.NOME_PORTO_PADRAO)
	# O campo do jogador é o único opcional dos dois, e o rótulo diz isso em vez
	# de deixar o jogador adivinhar: sem nome, as falas com vocativo têm
	# variante — ninguém fica sem forma de tratamento (ver Narrativa.gd).
	_campo_jogador = _campo(vbox, "E o seu nome (pode deixar em branco)", "")

	var comecar := Button.new()
	comecar.text = "Abrir o porto"
	comecar.custom_minimum_size = Vector2(0, ALTURA_CAMPO)
	comecar.pressed.connect(_on_comecar)
	vbox.add_child(comecar)

	var aviso := Label.new()
	aviso.autowrap_mode = TextServer.AUTOWRAP_WORD
	aviso.text = "O nome do cais não muda depois."
	vbox.add_child(aviso)

	_campo_porto.grab_focus()


func _campo(pai: VBoxContainer, rotulo: String, sugestao: String) -> LineEdit:
	var texto := Label.new()
	texto.text = rotulo
	pai.add_child(texto)

	var entrada := LineEdit.new()
	entrada.placeholder_text = sugestao
	# O limite vem do GameState e não daqui: quem corta o nome ao gravar é o
	# `definir_nomes()`, e dois limites diferentes seriam duas regras.
	entrada.max_length = GameState.NOME_MAX_CARACTERES
	entrada.custom_minimum_size = Vector2(0, ALTURA_CAMPO)
	# Enter em qualquer um dos dois campos abre o porto: obrigar a acertar no
	# botão depois de digitar é atrito sem motivo, e no telefone o teclado
	# ainda estaria por cima dele.
	entrada.text_submitted.connect(func(_t: String) -> void: _on_comecar())
	pai.add_child(entrada)
	return entrada


func _on_comecar() -> void:
	GameState.definir_nomes(_campo_porto.text, _campo_jogador.text)
	queue_free()
