extends PainelNarrativo

# ============================================================
# BR Port VS — o detalhe da reputação, ao toque no chip do HUD
#
# Quarto item do primeiro playtest: tocar num chip do HUD tem de abrir algo.
# O chip só mostra um número e um rótulo ("65 Respeitado"); o jogador não vê
# NEM a escada de patamares NEM o que empurra o número para cima ou para
# baixo. Este painel é essa segunda metade — sem inventar histórico nenhum
# que o `GameState` não guarda: é leitura pura das constantes que já regem a
# reputação, para o número aqui nunca poder discordar do número que o jogo usa.
# ============================================================

const LARGURA := 400
const ALTURA := 0

# Espelha `reputation_label()`, na mesma ordem — é a régua que o painel desenha.
# Repetido aqui pela mesma razão do `COR_AVISO` em `teste_design.gd`: o jogo
# roda por dentro de uma cena, e escrever os limiares à mão é o preço de os
# MOSTRAR, e não só de os aplicar.
const PATAMARES := [
	[81.0, "Referência"], [61.0, "Respeitado"], [41.0, "Confiável"],
	[21.0, "Questionável"], [0.0, "Desconhecido"],
]


func setup(_sem_argumentos: Variant = null) -> void:
	montar(LARGURA, ALTURA, ESCURO_DECISAO)
	titulo(Icones.REPUTACAO, "Reputação")

	var rep: float = GameState.reputation
	paragrafo("%s — %s" % [_pontos_sem_sinal(rep), GameState.reputation_label()])

	secao("A ESCADA")
	for par in PATAMARES:
		var piso: float = par[0]
		var nome: String = par[1]
		var aqui := rep >= piso and nome == GameState.reputation_label()
		var linha := "%s%d ou mais — %s" % ["▸ " if aqui else "    ", int(piso), nome]
		var rotulo := paragrafo(linha)
		if aqui:
			rotulo.add_theme_color_override("font_color", Color(0.878, 0.604, 0.063))

	fio()
	secao("O QUE MUDA")
	paragrafo("%s ao atender um barco" % _pontos(GameState.REPUTATION_GAIN_SERVED))
	paragrafo("%s ao perder um barco sem trabalhador" % _pontos(-GameState.REPUTATION_LOSS_LOST))
	paragrafo("%s ao fechar um acordo com o rival" % _pontos(GameState.REPUTATION_GAIN_RIVAL_MATCHED))
	paragrafo("%s ao recusar ou perder para o rival" % _pontos(-GameState.REPUTATION_LOSS_RIVAL_REFUSED))

	fio()
	# O EFEITO É MECÂNICO, não só estético — e é por isso que vale a pena
	# escrever: reputação que só mudasse o texto do chip seria decoração.
	paragrafo(("Acima do início (%d), melhora a chance de \"manter o preço\" e " +
		"\"cortar pela metade\" nas negociações com o rival. Abaixo, piora.")
		% int(GameState.REPUTATION_START))

	botao_fechar("Fechar")


# "+0,8" / "-2,5" — vírgula em vez de ponto (é assim que o jogo já escreve os
# outros números fracionários), e o sinal sempre escrito, mesmo no positivo:
# numa lista de "o que sobe e o que desce", omitir o "+" faria a leitura
# hesitar sobre qual linha é qual.
func _pontos(v: float) -> String:
	return "%s%s" % ["+" if v >= 0 else "-", _pontos_sem_sinal(absf(v))]


func _pontos_sem_sinal(v: float) -> String:
	return ("%.1f" % v).replace(".", ",")
