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
	bloco_de_contas("Entrou", [
		["Docagens", int(_resumo["docagens"])],
		["Armazém", int(_resumo["armazem"])],
		["Pátio de contêineres", int(_resumo["patio"])],
		["Aluguel de píer", int(_resumo["pier"])],
	], int(_resumo["receita"]))

	bloco_de_contas("Saiu", [
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
	var texto_da_fala := Narrativa.boletim(tom)
	var cara := Narrativa.retrato("cida", tom)
	fala(texto_da_fala, cara)
	falou.emit("cida", texto_da_fala, cara)

	botao_fechar("Fechar o boletim")


# O bloco de contas — o total na linha do bloco e as parcelas por baixo, no
# tom de apoio — vive no andaime desde 26/09 (`bloco_de_contas()`), porque o
# painel do dinheiro do dia passou a usá-lo também.


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
