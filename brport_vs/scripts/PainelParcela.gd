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
# O VALOR DE HOJE É MENOR DO QUE O DO VENCIMENTO desde 12/09 (item 24,
# `docs/decisoes/019`), e é AQUI que essa mecânica existe: o desconto encolhe
# um pouco a cada dia, e um número que só aparecesse depois de pago não seria
# uma escolha — seria uma surpresa. O painel mostra os três números (o cheio, o
# abatimento de hoje e o que sai do caixa) e diz que o abatimento míngua.
# ============================================================

const LARGURA := 420
const ALTURA := 0


func setup(_sem_argumentos: Variant = null) -> void:
	montar(LARGURA, ALTURA, ESCURO_DECISAO)
	titulo(Icones.PARCELA, "Parcela do Sr. Ribeiro")

	var cheio: int = GameState.PARCELA_AMOUNT
	var valor: int = GameState.valor_da_parcela_hoje()
	var abatimento: int = cheio - valor
	if GameState.parcela_paid:
		total("Paga — porto salvo")
		paragrafo("A dívida com o Banco Porto Mirim está quitada.")
		botao_fechar("Fechar")
		return

	var dias: int = maxi(GameState.PARCELA_DUE_TURN - GameState.turn + 1, 0)
	# O TOTAL é o que sai do caixa hoje — a linha única que o olho procura
	# primeiro (`RotuloTotal`). O cheio e o abatimento ficam na prosa abaixo:
	# dois números em destaque seriam nenhum em destaque.
	total(GameState.moeda(valor))
	paragrafo("Vence no dia %d — %d dia(s) daqui." % [GameState.PARCELA_DUE_TURN, dias])
	if abatimento > 0:
		paragrafo(("Cheia são %s. Antecipar abate %s pelos juros que o banco " +
			"deixa de correr — e esse abatimento encolhe a cada dia.")
			% [GameState.moeda(cheio), GameState.moeda(abatimento)])

	fio()
	var falta: int = valor - int(GameState.cash)
	if falta > 0:
		paragrafo("No caixa: %s. Faltam %s."
			% [GameState.moeda(int(GameState.cash)), GameState.moeda(falta)])
		botao_fechar("Fechar")
		return

	paragrafo("No caixa: %s — já dá para quitar agora."
		% GameState.moeda(int(GameState.cash)))
	# A TROCA FICA ESCRITA, porque ela é a decisão. O abatimento não paga o
	# custo de oportunidade: o que sai daqui é dinheiro que compraria estrutura,
	# e é isso que faz disto uma escolha em vez de um botão óbvio.
	paragrafo(("O mesmo caixa também constrói: %s são %s.")
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
