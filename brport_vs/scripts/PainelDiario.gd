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

# Cartão de LEITURA, e por isso maior que os painéis de decisão: quanto mais
# largo, menos linhas quebram, e quanto mais alto, menos se rola. A primeira
# medida (360x480 com 330 de texto) rolava a meio da terceira frase e ainda
# deixava 70px vazios debaixo do botão — a caixa era maior do que o conteúdo
# num sítio e menor noutro ao mesmo tempo.
const LARGURA := 440
const ALTURA := 660
const ALTURA_TEXTO := 520


func _ready() -> void:
	super()
	montar(LARGURA, ALTURA)
	# DIA: entrada de diário é datada, e o cabeçalho diz a semana. Dos vinte
	# ícones é o único com essa leitura, e tem navy no traço — sobrevive ao
	# fundo claro do cartão, ao contrário de `doca` (Icones.gd avisa).
	titulo(Icones.DIA, Narrativa.DIARIO_CABECALHO)
	paragrafo_rolavel(Narrativa.diario(), ALTURA_TEXTO)
	botao_fechar("Começar a semana 1")
