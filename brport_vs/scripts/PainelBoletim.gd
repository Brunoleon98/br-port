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
	titulo(Icones.CAIXA, "Boletim Financeiro")
	paragrafo("Semana %d de %d" % [int(_resumo["semana"]), GameState.WEEKS_TOTAL])

	# LINHA COM ZERO NÃO ENTRA. O armazém só rende depois de consertado e a
	# parcela só vence numa semana das quatro; mostrá-las a R$0 nas outras é
	# ruído que o olho tem de descartar toda semana para chegar ao que mudou.
	_bloco("RECEITAS", [
		["Docagens", int(_resumo["docagens"])],
		["Armazém", int(_resumo["armazem"])],
		["Aluguel de píer", int(_resumo["pier"])],
	], int(_resumo["receita"]))

	_bloco("DESPESAS", [
		["Salários", int(_resumo["salarios"])],
		["Manutenção", int(_resumo["manutencao"])],
		["Parcela", int(_resumo["parcela"])],
	], int(_resumo["despesa"]))

	_resultado()

	fala(GameState.texto(Narrativa.tom_do_boletim(
		int(_resumo["resultado"]),
		float(_resumo["media_anterior"]),
		bool(_resumo["tem_historico"]))))

	botao_fechar("Fechar o boletim")


func _bloco(nome: String, linhas: Array, soma: int) -> void:
	secao(nome)
	var grade := GridContainer.new()
	grade.columns = 2
	grade.add_theme_constant_override("h_separation", 16)
	_vbox.add_child(grade)
	for linha in linhas:
		if int(linha[1]) == 0:
			continue
		_linha(grade, String(linha[0]), int(linha[1]))
	fio()
	var grade_total := GridContainer.new()
	grade_total.columns = 2
	grade_total.add_theme_constant_override("h_separation", 16)
	_vbox.add_child(grade_total)
	_linha(grade_total, "Total", soma)


# Rótulo à esquerda, valor à direita. O valor alinha à direita porque é assim
# que se comparam números empilhados — alinhados à esquerda, R$1.200 e R$980
# parecem do mesmo tamanho.
func _linha(grade: GridContainer, rotulo: String, valor: int) -> void:
	var esquerda := Label.new()
	esquerda.text = rotulo
	esquerda.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grade.add_child(esquerda)

	var direita := Label.new()
	direita.text = GameState.moeda(valor)
	direita.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	grade.add_child(direita)


func _resultado() -> void:
	var resultado := int(_resumo["resultado"])
	fio()
	total("Resultado líquido: %s" % GameState.moeda(resultado))
	if not bool(_resumo["tem_historico"]):
		return
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
	paragrafo("Semana anterior: %s%s" % [GameState.moeda(anterior), variacao])
