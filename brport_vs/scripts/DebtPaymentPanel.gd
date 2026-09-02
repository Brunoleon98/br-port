extends PainelNarrativo

# ============================================================
# BR Port VS — a cena da parcela, com o Sr. Ribeiro
#
# Era um placeholder: uma frase encurtada e dois botões. Item A4 do plano —
# esta é uma das seis telas que carregam a Fase 1 como história, e a única em
# que um NPC aparece num momento de PRESSÃO REAL. O texto vem inteiro do
# `Narrativa.gd`; aqui só se decide quando cada pedaço aparece.
#
# CENA TENSA, SEM PENALIDADE MECÂNICA — é o que o arquivo de escrita pede, e
# tem consequência de código: este painel não muda número nenhum. Quem cobra,
# perdoa ou falha é o `GameState.pay_debt()` / `fail_debt()`, exatamente como
# antes. Se a cena mexesse na economia, mexeria no que o simulador mede.
#
# O DIÁLOGO É EM DOIS TEMPOS. Entrada e dívida antes da decisão; a reação e a
# despedida DEPOIS dela, no mesmo painel. Abrir um segundo painel para a
# resposta seria dois cliques onde o momento pede um — e a despedida ("não
# deixa chegar no desespero pra me ligar") é o que planta a Parcela seguinte.
# ============================================================

const LARGURA := 420
# Ajusta ao conteúdo: a fala muda de tamanho entre a entrada e a resposta, e a
# botoneira perde um botão quando há dinheiro em caixa. Nenhuma altura fixa
# serve às duas versões sem sobrar branco numa delas.
const ALTURA := 0

var amount: int = 0
var _corpo: Label
var _botoes: VBoxContainer


func setup(due_amount: int) -> void:
	amount = due_amount
	_montar()


func _montar() -> void:
	montar(LARGURA, ALTURA, ESCURO_DECISAO)
	# PARCELA é navy cheio e só sobrevive em fundo CLARO — que é o deste
	# cartão. É o caso em que o Icones.gd manda usá-lo.
	titulo(Icones.PARCELA, "Sr. Ribeiro — Banco Porto Mirim")

	_corpo = Label.new()
	_corpo.autowrap_mode = TextServer.AUTOWRAP_WORD
	_corpo.text = "%s\n\n%s" % [
		Narrativa.ribeiro_entrada(), Narrativa.ribeiro_a_divida(amount)]
	_vbox.add_child(_corpo)

	_botoes = VBoxContainer.new()
	_botoes.add_theme_constant_override("separation", 8)
	_vbox.add_child(_botoes)
	_montar_decisao()


func _montar_decisao() -> void:
	var pode_pagar: bool = GameState.cash >= amount

	var caixa := Label.new()
	caixa.text = "Caixa: %s" % GameState.moeda(int(GameState.cash))
	_botoes.add_child(caixa)

	var pagar := Button.new()
	pagar.text = "Pagar %s" % GameState.moeda(amount)
	pagar.custom_minimum_size = Vector2(0, TOQUE_MIN)
	pagar.disabled = not pode_pagar
	pagar.pressed.connect(_on_pagar)
	_botoes.add_child(pagar)

	if not pode_pagar:
		var falhar := Button.new()
		falhar.text = "Não consigo pagar"
		falhar.custom_minimum_size = Vector2(0, TOQUE_MIN)
		falhar.pressed.connect(_on_falhar)
		_botoes.add_child(falhar)


func _on_pagar() -> void:
	GameState.pay_debt()
	_mostrar_resposta(Narrativa.RIBEIRO_PAGOU)


func _on_falhar() -> void:
	GameState.fail_debt()
	_mostrar_resposta(Narrativa.RIBEIRO_NAO_PAGOU)


# A decisão já foi tomada e o dinheiro já mudou de mãos: os botões saem para
# não haver como pagar duas vezes, e entra a resposta dele. A despedida é a
# mesma nos dois casos — é dela que sai a promessa que a Parcela seguinte vem
# cobrar.
func _mostrar_resposta(reacao: String) -> void:
	_corpo.text = "%s\n\n%s" % [GameState.texto(reacao),
		GameState.texto(Narrativa.RIBEIRO_DESPEDIDA)]
	for filho in _botoes.get_children():
		filho.queue_free()
	var sair := Button.new()
	sair.text = "Até a próxima, Sr. Ribeiro"
	sair.custom_minimum_size = Vector2(0, TOQUE_MIN)
	sair.pressed.connect(_fechar)
	_botoes.add_child(sair)
