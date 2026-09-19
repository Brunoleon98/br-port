extends PainelNarrativo

# ============================================================
# BR Port VS — O QUE JÁ FOI DITO (R5 da §7.1)
#
# A faixa de mensagem cabe uma frase de cada vez, e o jogo diz mais do que
# isso: medido em 19/09, uma só pressão de "Avançar dia" escreve nela até
# QUATRO vezes, e comprar uma estrutura escreve 2,29 em média
# (`tools/medir_fila_mensagens.gd`). A fila resolve o atropelo — mostra uma de
# cada vez, por ordem — e abre a pergunta seguinte: e o que passou enquanto eu
# olhava para o mapa?
#
# ⚠️ É OVERLAY, e nunca fase do `GameState`. Uma fase a mais fez 24 de 30
# partidas não terminarem e o CI passar na mesma; como overlay, o balanceamento
# medido fica intocado POR CONSTRUÇÃO e não por cuidado de quem escreveu.
#
# ⚠️ E O HISTÓRICO É DA SESSÃO, não do save. A §7.1 pede "recuperação em
# memória da sessão, sem migrar save", e é o que mantém o `SAVE_VERSION`
# intocado: fechar o jogo esquece o que foi dito, como esquece o que estava na
# faixa.
#
# ⚠️ E ELE NÃO DIZ QUEM FALOU. As duas fontes estão na mesma lista sem rótulo
# de orador, porque um rótulo seria texto NOVO — e texto novo neste jogo passa
# pela leitura em voz alta do Bruno (gate A4), não pela mão de quem escreve o
# painel. A voz da Dona Cida distingue-se sozinha; se não bastar, o rótulo é
# uma linha e volta.
# ============================================================

const LARGURA := 460
# O que o tema gasta de margem lateral dentro do cartão, medido no render —
# o mesmo número que o `EndGame` usa.
const MARGEM_CARTAO := 36
# O TETO da lista. 60 mensagens de 54 caracteres pediriam ~1.600 px, e a tela
# tem 1.280: o que passar daqui rola, e o que não couber no histórico nunca
# chegou a entrar (`FilaDeMensagens.HISTORICO_MAX`).
const ALTURA_LISTA_MAX := 620


func setup(historico: Variant = null) -> void:
	montar(LARGURA, 0, ESCURO_LEITURA)
	titulo(Icones.DIARIO, "O que já foi dito")

	var lista: Array = historico if historico is Array else []
	if lista.is_empty():
		paragrafo("Ainda não aconteceu nada por aqui.")
		botao_fechar("Fechar")
		return

	# Da mais recente para a mais antiga: quem abre isto abre por ter perdido
	# a última, não a primeira.
	var linhas := PackedStringArray()
	for entrada in lista:
		linhas.append(String((entrada as Dictionary)["texto"]))
	var texto := "\n\n".join(linhas)

	# A ALTURA SAI DO TEXTO, nunca de um número escrito à mão. Área rolável não
	# corta — esconde —, e uma altura fixa aqui cresceria calada a cada
	# mensagem nova, que é o defeito que o `altura_do_texto()` existe para
	# acabar (ver o cabeçalho dele).
	var pedido := altura_do_texto(texto, LARGURA - MARGEM_CARTAO)
	paragrafo_rolavel(texto, mini(pedido, ALTURA_LISTA_MAX))
	botao_fechar("Fechar")
