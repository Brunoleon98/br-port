extends PainelNarrativo

# ============================================================
# BR Port VS — Diário do Porto, primeira página
#
# Abre UMA vez, logo depois da tela de nomes, antes do primeiro turno. É a
# primeira coisa que o jogador lê depois de batizar o cais, e o texto usa o
# nome que ele acabou de escolher — que é o ponto: o diário é do avô, e a
# primeira página em branco passa a ser dele.
#
# NÃO PRECISA DE CAMPO NO SAVE para saber que já foi lido, e é de propósito.
# Ele encadeia-se à tela de nomes (Main.gd liga o sinal `fechou` de uma à
# abertura da outra), e a tela de nomes só aparece quando `precisa_dos_nomes()`
# dá true. Recarregar no turno 1 não o traz de volta, porque os nomes já estão
# gravados. Um booleano `diario_lido` no save seria um campo a mais para o
# `new_game()` ter de lembrar-se de zerar — e é assim que o estado impossível
# atravessa de uma partida para a seguinte.
# ============================================================

# O CADERNO (`docs/decisoes/067`). Era um cartão branco de 440 px com o texto
# na letra do jogo e uma área que rolava; desde a família das telas de texto é
# a primeira página de um caderno de capa dura, pautada, na letra à mão — o
# pedido do Bruno foi «cara de diário», e este mesmo painel é o que o app
# Diário do celular abre.
#
# ⚠️ A PÁGINA NÃO ROLA, e é o que o D36 tranca: a letra à mão é mais larga do
# que a do jogo, e o texto com o nome mais comprido que a tela de nomes aceita
# tem de caber na folha sem a fazer crescer. A primeira medida da rolagem
# (11/09) já mostrava o preço de não caber: a frase que FECHA o diário
# («Talvez.») ficava por baixo da dobra, com o botão a convidar a sair.
#
# ⚠️ E O RETÂNGULO É O MESMO DA TELA DE NOMES — as medidas vivem no
# `PainelNarrativo` —, porque a folha de rosto vira para esta página.


func _ready() -> void:
	super()
	montar_caderno(ESCURO_LEITURA)
	# A orelha no canto de baixo, como a página que a folha de rosto revela.
	pagina_do_caderno(true, true, FolhaDoCaderno.Orelha.BAIXO)
	escrever(self)
	# "primeira semana" e não "semana 1" — o rótulo do botão é a MESMA frase que
	# a leitura em voz alta de 13/09 mandou trocar no diário, e escapou à
	# primeira varredura por não viver no `Narrativa.gd`. Fala do jogo também é
	# texto, mesmo quando está num botão.
	botao_abaixo_do_caderno("Começar a primeira semana")


# A entrada, num sítio só: a tela de nomes escreve-a na página de BAIXO antes
# de virar a folha de rosto, e tem de sair igual à que este painel mostra a
# seguir — senão a virada revelava uma página e o painel trocava-a por outra.
static func escrever(painel: PainelNarrativo) -> Label:
	# DIA: entrada de diário é datada. A data é a do cabeçalho de sempre, agora
	# escrita à mão no canto da página, como se data uma entrada.
	return painel.entrada_do_diario(Narrativa.DIARIO_CABECALHO, Narrativa.diario())
