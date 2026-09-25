extends PainelNarrativo

# ============================================================
# BR Port VS — o Boletim Financeiro da Dona Cida
#
# Abre no fecho de cada semana. É a terceira das telas do A4 e a única em que
# a Dona Cida tem voz de personagem sobre um número — o resto do jogo mostra
# dinheiro sem ninguém a comentá-lo.
#
# CARTA VISUAL, NÃO PAINEL DE GRÁFICOS. O GDD é explícito nisso, e a razão é
# de tom: um gráfico diz "desempenho", uma carta diz "alguém olhou as suas
# contas". A Dona Cida é contabilista, não dashboard.
#
# O TOM SAI DA MÉDIA, A COMPARAÇÃO SAI DA SEMANA ANTERIOR. São dois números
# diferentes do mesmo histórico, e é de propósito: comparar contra a semana
# passada é o que o jogador quer ver, mas escolher o tom por ela faria a Dona
# Cida comemorar qualquer repique depois de uma semana ruim.
#
# NÃO MEXE EM NADA. Este painel só lê o resumo que o `GameState` fecha. A
# conta vive lá (`resumo_da_semana`) para o teste poder fazê-la sem abrir cena
# — duas versões da mesma conta divergem, como já divergiram os números do GDD
# e os das constantes.
# ============================================================

const LARGURA := 440
const ALTURA := 0    # ajusta ao conteúdo: a linha da parcela só existe na semana 4

var _resumo: Dictionary = {}


func setup(resumo: Dictionary) -> void:
	_resumo = resumo
	montar(LARGURA, ALTURA, ESCURO_DECISAO)
	titulo_encorpado(Icones.CAIXA, "Boletim Financeiro")
	paragrafo("Semana %d de %d" % [int(_resumo["semana"]), GameState.WEEKS_TOTAL])

	# LINHA COM ZERO NÃO ENTRA. O armazém só rende depois de consertado e a
	# parcela só vence numa semana das quatro; mostrá-las a R$0 nas outras é
	# ruído que o olho tem de descartar toda semana para chegar ao que mudou.
	_bloco("Entrou", [
		["Docagens", int(_resumo["docagens"])],
		["Armazém", int(_resumo["armazem"])],
		["Pátio de contêineres", int(_resumo["patio"])],
		["Aluguel de píer", int(_resumo["pier"])],
	], int(_resumo["receita"]))

	_bloco("Saiu", [
		["Salários", int(_resumo["salarios"])],
		["Manutenção", int(_resumo["manutencao"])],
		["Parcela", int(_resumo["parcela"])],
	], int(_resumo["despesa"]))

	_resultado()

	# O TOM SAI UMA VEZ e serve as duas coisas: a fala e a cara. Pedir o tom
	# duas vezes — uma para o texto, outra para a expressão — seria a mesma
	# decisão tomada em dois sítios, que é como dois números do mesmo jogo
	# divergem.
	var tom: String = Narrativa.tom_do_boletim(_resumo)
	fala(Narrativa.boletim(tom), Narrativa.retrato("cida", tom))

	botao_fechar("Fechar o boletim")


# O TOTAL SOBE PARA A LINHA DO BLOCO, e as parcelas descem de tom (25/09,
# quarta passagem). Era «ENTROU» em cinza pequeno, quatro linhas, um fio e uma
# linha «Total» com o mesmo peso de cada parcela — e outro tanto para o SAIU:
# duas linhas «Total» num cartão só, e o olho a descer a lista inteira para
# achar os dois números que a Dona Cida comenta. É o desenho das finanças do
# *Two Point Hospital* e do fim de dia do *Papers, Please*: de onde entrou e
# para onde saiu, cada bloco encabeçado pelo seu total, com o detalhe por
# baixo (`docs/design/BR_Port_Referencias_Interface_Gestao.md`).
#
# ⚠️ SEM SINAL E SEM COR. A palavra do bloco já diz de que lado está o
# dinheiro — «Saiu −R$49.000» dizia-o duas vezes, que é a dupla negação que o
# `lucro_ou_prejuizo()` já recusa —, e verde contra vermelho não se lê sem
# distinguir as duas cores, nem o tema tem esse par medido sobre o branco.
func _bloco(nome: String, linhas: Array, soma: int) -> void:
	var cabeca := GridContainer.new()
	cabeca.columns = 2
	cabeca.add_theme_constant_override("h_separation", 16)
	_vbox.add_child(cabeca)
	var titulo_bloco := Label.new()
	titulo_bloco.text = nome
	titulo_bloco.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cabeca.add_child(titulo_bloco)
	var total_bloco := Label.new()
	total_bloco.text = GameState.moeda(soma)
	total_bloco.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	cabeca.add_child(total_bloco)

	# As parcelas recuadas e no tom de apoio: detalhe do total de cima.
	var recuo := MarginContainer.new()
	recuo.add_theme_constant_override("margin_left", 14)
	_vbox.add_child(recuo)
	var grade := GridContainer.new()
	grade.columns = 2
	grade.add_theme_constant_override("h_separation", 16)
	grade.add_theme_constant_override("v_separation", 2)
	recuo.add_child(grade)
	for linha in linhas:
		if int(linha[1]) == 0:
			continue
		_linha(grade, String(linha[0]), int(linha[1]))


# Rótulo à esquerda, valor à direita. O valor alinha à direita porque é assim
# que se comparam números empilhados — alinhados à esquerda, R$1.200 e R$980
# parecem do mesmo tamanho.
func _linha(grade: GridContainer, rotulo: String, valor: int) -> void:
	var esquerda := Label.new()
	esquerda.theme_type_variation = "RotuloApoio"
	esquerda.text = rotulo
	esquerda.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grade.add_child(esquerda)

	var direita := Label.new()
	direita.theme_type_variation = "RotuloApoio"
	direita.text = GameState.moeda(valor)
	direita.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	grade.add_child(direita)


# A COMPARAÇÃO VIVE DENTRO DA TARJA DO RESULTADO, como linha de apoio (25/09,
# terceira passagem). Era um parágrafo solto por baixo dela, com o mesmo peso
# do «Semana 1 de 4» do topo, e lia-se como mais uma linha da contabilidade;
# é o contexto do número destacado, e fica encostada a ele.
func _resultado() -> void:
	var resultado := int(_resumo["resultado"])
	fio()
	tarja(Narrativa.lucro_ou_prejuizo(resultado, GameState.moeda, true),
		_comparacao(resultado),
		&"bom" if resultado > 0 else (&"ruim" if resultado < 0 else &"neutro"))


func _comparacao(resultado: int) -> String:
	if not bool(_resumo["tem_historico"]):
		return ""
	var anterior := int(_resumo["anterior"])
	var seta := "↑" if resultado > anterior else ("↓" if resultado < anterior else "=")
	# Variação percentual precisa de uma base que não seja zero, e uma semana
	# de resultado exatamente zero é possível. Sem a guarda isto é uma divisão
	# por zero que o Godot devolve como INF e a tela mostra como "inf%".
	var variacao := ""
	if anterior != 0:
		variacao = "  (%s %d%%)" % [seta,
			int(round(abs(float(resultado - anterior) / float(anterior)) * 100.0))]
	else:
		variacao = "  (%s)" % seta
	return "Semana anterior: %s%s" % [
		Narrativa.lucro_ou_prejuizo(anterior, GameState.moeda), variacao]
