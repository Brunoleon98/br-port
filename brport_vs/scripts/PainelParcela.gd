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

const LARGURA := 440
const ALTURA := 0


## Quando vence, em palavra de calendário. `faltam` é a DISTÂNCIA até ao dia do
## vencimento, e não os dias que ainda se jogam: a parcela cai no FIM do dia 32.
##
## ⚠️ A CONTA ANTIGA ESTAVA UM DIA ADIANTADA EM TODOS OS DIAS. Ela usava
## `PARCELA_DUE_TURN - turn + 1`, que é quantos dias AINDA SE JOGAM contando o
## de hoje — o número certo para o "N dias restantes" do HUD, e o errado para
## "daqui": no próprio dia 32 o painel dizia "1 dia daqui", no mesmo dia em que o
## Sr. Ribeiro chega a dizer "a parcela vence hoje". E o "0 dias daqui" que o gate
## A4 listava nunca chegou à tela — a conta só dá zero depois do dia 32. Troca
## pedida pelo Bruno em 23/09: hoje, amanhã, e daí para trás "daqui a N dias".
func _quando_vence(faltam: int) -> String:
	var dia: int = GameState.PARCELA_DUE_TURN
	if faltam <= 0:
		return "Vence hoje, dia %d." % dia
	if faltam == 1:
		return "Vence amanhã, dia %d." % dia
	return "Vence no dia %d — daqui a %s." % [dia, Narrativa.concordar(faltam, "dia", "dias")]


func setup(_sem_argumentos: Variant = null) -> void:
	montar(LARGURA, ALTURA, ESCURO_DECISAO)
	titulo_encorpado(Icones.PARCELA, "Parcela do Sr. Ribeiro")

	var cheio: int = GameState.PARCELA_AMOUNT
	var valor: int = GameState.valor_da_parcela_hoje()
	var abatimento: int = cheio - valor
	if GameState.parcela_paid:
		tarja("Parcela quitada", "A dívida com o Banco Porto Mirim está quitada.", &"bom")
		botao_fechar("Fechar")
		return

	# A TARJA É O QUE SAI DO DINHEIRO HOJE — a linha única que o olho procura
	# primeiro —, e a linha de apoio é a conta de onde ela sai: o cheio menos o
	# abatimento (26/09, `065`). Até aqui o cheio e o abatimento viviam numa
	# frase de três linhas por baixo, que é a subtração espalhada que a `062`
	# tirou da cobrança. Tom neutro: é um preço, não um resultado.
	var apoio := ""
	if abatimento > 0:
		apoio = "Cheia são %s — antecipar abate %s" % [
			GameState.moeda(cheio), GameState.moeda(abatimento)]
	tarja("Quitar hoje: %s" % GameState.moeda(valor), apoio)
	paragrafo(_quando_vence(GameState.PARCELA_DUE_TURN - GameState.turn))
	if abatimento > 0:
		var juro := paragrafo("O abatimento são os juros que o banco deixa de correr, " +
			"e encolhe a cada dia.")
		juro.theme_type_variation = "RotuloApoio"

	fio()
	# A BARRA DO HUD, a mesma da cobrança (`063`): o jogador passa a partida a
	# olhar para ela no rodapé, e aqui ela mede o dinheiro contra o que sai
	# HOJE — é esse o número que o botão cobra.
	var dinheiro := int(GameState.cash)
	_vbox.add_child(barra_do_hud(dinheiro, valor))
	var legenda := paragrafo("Você tem %s de %s" % [
		GameState.moeda(dinheiro), GameState.moeda(valor)])
	legenda.theme_type_variation = "RotuloApoio"

	var falta: int = valor - dinheiro
	if falta > 0:
		paragrafo("Faltam %s para quitar hoje." % GameState.moeda(falta))
		botao_fechar("Fechar")
		return

	# A TROCA FICA ESCRITA, porque ela é a decisão. O abatimento não paga o
	# custo de oportunidade: o que sai daqui é dinheiro que compraria estrutura,
	# e é isso que faz disto uma escolha em vez de um botão óbvio.
	paragrafo(("O mesmo dinheiro também constrói: %s são %s.")
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
