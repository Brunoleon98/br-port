extends PainelNarrativo

# ============================================================
# BR Port VS — a parcela do Sr. Ribeiro, ao toque no cartão da meta
#
# Item do primeiro playtest que a triagem tinha PERDIDO: "pode haver a opção
# de pagar a dívida antes do tempo". Ele estava na transcrição e não entrou em
# gaveta nenhuma — só apareceu ao reler o texto original palavra por palavra.
#
# POR QUE UM PAINEL, E NÃO UM BOTÃO NO CARTÃO. O rodapé tem sete faixas
# empilhadas e 29px de folga até a borda de baixo; um botão de 44px (o piso de
# toque do projeto) não cabe lá sem tirar outra coisa que já é usada. Tocar no
# cartão é a mesma língua que os quatro chips do HUD já falam desde 03/09.
#
# O VALOR É O MESMO do vencimento, e o painel diz isso em voz alta: desconto
# por antecipação mexeria na economia medida, e isso passa pelo `/balancear`.
# Sem essa linha, o jogador que abrisse aqui esperaria um abatimento.
# ============================================================

const LARGURA := 420
const ALTURA := 0


func setup(_sem_argumentos: Variant = null) -> void:
	montar(LARGURA, ALTURA, ESCURO_DECISAO)
	titulo(Icones.PARCELA, "Parcela do Sr. Ribeiro")

	var valor: int = GameState.PARCELA_AMOUNT
	if GameState.parcela_paid:
		total("Paga — porto salvo")
		paragrafo("A dívida com o Banco Porto Mirim está quitada.")
		botao_fechar("Fechar")
		return

	var dias: int = maxi(GameState.PARCELA_DUE_TURN - GameState.turn + 1, 0)
	total(GameState.moeda(valor))
	paragrafo("Vence no dia %d — %d dia(s) daqui." % [GameState.PARCELA_DUE_TURN, dias])

	fio()
	var falta: int = valor - int(GameState.cash)
	if falta > 0:
		paragrafo("No caixa: %s. Faltam %s."
			% [GameState.moeda(int(GameState.cash)), GameState.moeda(falta)])
		botao_fechar("Fechar")
		return

	paragrafo("No caixa: %s — já dá para quitar agora."
		% GameState.moeda(int(GameState.cash)))
	# A TROCA FICA ESCRITA, porque ela é a decisão. Quitar não desconta nada;
	# o que sai daqui é o mesmo dinheiro que compraria estrutura, e é isso que
	# faz disto uma escolha em vez de um botão óbvio.
	paragrafo(("Antecipar não muda o valor — o que muda é deixar de carregar a " +
		"dívida. O mesmo caixa também constrói: %s são %s.")
		% [GameState.moeda(valor), _o_que_isso_compra(valor)])

	var quitar := Button.new()
	quitar.text = "Quitar agora — %s" % GameState.moeda(valor)
	quitar.custom_minimum_size = Vector2(0, TOQUE_MIN)
	quitar.theme_type_variation = &"BotaoPrimario"
	quitar.pressed.connect(func() -> void:
		GameState.pagar_parcela_adiantado()
		_fechar()
	)
	_vbox.add_child(quitar)

	botao_fechar("Depois")


# "R$550.000 são duas estruturas e sobra" — o custo de oportunidade em coisas
# do jogo, não em abstrato. Sai da própria tabela de estruturas, então uma
# mudança de preço nunca deixa esta frase a mentir.
func _o_que_isso_compra(valor: int) -> String:
	var precos: Array = []
	for id in GameState.ESTRUTURAS:
		if not GameState.tem_estrutura(String(id)):
			precos.append(int(GameState.ESTRUTURAS[id]["custo"]))
	precos.sort()
	var quantas := 0
	var soma := 0
	for preco in precos:
		if soma + int(preco) > valor:
			break
		soma += int(preco)
		quantas += 1
	if quantas == 0:
		return "menos de uma das estruturas que faltam"
	var sobra := valor - soma
	var texto := "%d das estruturas que faltam" % quantas if quantas > 1 \
		else "uma das estruturas que faltam"
	return texto + (" e sobra" if sobra > 0 else "")
