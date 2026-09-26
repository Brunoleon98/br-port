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
#
# ⚠️ OS TRÊS EIXOS (26/09, `065`). O GDD tem três reputações que não somam —
# Comercial, Comunitária e Imprensa — e o jogo de hoje tem UMA, que faz o
# trabalho da Comercial: mexe com os clientes e com a negociação do Arlindo.
# Pedido do Bruno no gate do A5, «reputação organizada para os componentes que
# virão», e escolha dele: a de hoje chama-se Comercial aqui, e as outras duas
# aparecem trancadas, «abre na Fase 2», como os quadrados do menu-celular. O
# chip do HUD não muda — ele só tem lugar para uma, e é esta.
# ============================================================

const LARGURA := 440
const ALTURA := 0
# A coluna dos nomes na escada, para as cinco barras começarem na mesma
# vertical: «▸ 21 · Questionável», o mais comprido, pede ~150 px a 15.
const LARG_DEGRAU := 170

# Espelha `reputation_label()`, na mesma ordem — é a régua que o painel desenha.
# Repetido aqui pela mesma razão do `COR_AVISO` em `teste_design.gd`: o jogo
# roda por dentro de uma cena, e escrever os limiares à mão é o preço de os
# MOSTRAR, e não só de os aplicar.
const PATAMARES := [
	[81.0, "Referência"], [61.0, "Respeitado"], [41.0, "Confiável"],
	[21.0, "Questionável"], [0.0, "Desconhecido"],
]

# Os eixos que o GDD promete e o jogo ainda não tem, com o que cada um vai
# decidir — a frase do GDD, encurtada. Trancados não mostram número: um número
# que nada mexe seria decoração.
#
# ⚠️ A FRASE VAI INTEIRA, e não o complemento: a primeira versão montava
# «Vai pesar em %s» e saiu «pesar em a cidade» — a contração «na» não se
# monta com `%s`.
const EIXOS_TRANCADOS := [
	["Comunitária", "Vai pesar na cidade, na câmara e nos finais."],
	["Imprensa", "Vai pesar no que a Bela publica sobre o porto."],
]


func setup(_sem_argumentos: Variant = null) -> void:
	montar(LARGURA, ALTURA, ESCURO_DECISAO)
	titulo_encorpado(Icones.REPUTACAO, "Reputação")

	var rep: float = GameState.reputation
	secao("OS TRÊS EIXOS")
	_eixo_comercial(rep)
	for eixo in EIXOS_TRANCADOS:
		_eixo_trancado(String(eixo[0]), String(eixo[1]))

	# A ESCADA DE BARRAS (segunda passagem, `065`): cada degrau com a barra
	# do HUD cheia até onde a reputação chegou dentro dele — os de baixo
	# cheios, o de agora a meio, os de cima vazios. Substitui a barra única de
	# 0 a 100 que o quadro da Comercial tinha: a escada já é o medidor, e com
	# os degraus à vista.
	secao("A ESCADA DA COMERCIAL")
	var escada := VBoxContainer.new()
	escada.add_theme_constant_override("separation", 2)
	_vbox.add_child(escada)
	var teto := 100.0
	for par in PATAMARES:
		var piso: float = par[0]
		var nome: String = par[1]
		var aqui := rep >= piso and nome == GameState.reputation_label()
		var degrau := HBoxContainer.new()
		degrau.name = "Degrau%d" % int(piso)
		degrau.add_theme_constant_override("separation", 10)
		escada.add_child(degrau)
		var rotulo := Label.new()
		rotulo.text = "%s%d · %s" % ["▸ " if aqui else "    ", int(piso), nome]
		rotulo.custom_minimum_size = Vector2(LARG_DEGRAU, 0)
		degrau.add_child(rotulo)
		if aqui:
			# A faixa em que se está, pelo tema. O âmbar de marca escrito à mão
			# media 2,39:1 neste cartão branco; a variação mede 5,06:1
			# (`docs/decisoes/035`). O "▸" continua a marcar a linha, e a
			# separação contra o navy das outras faixas passou a ser de MATIZ.
			rotulo.theme_type_variation = "RotuloAlerta"
		var barra := barra_do_hud(rep, teto, piso)
		barra.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		barra.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		degrau.add_child(barra)
		teto = piso

	# O QUE MEXE NELA, em coluna: o evento à esquerda e o tamanho à direita,
	# alinhado como o dinheiro, para o +0,8 e o −8,0 se compararem de cima a
	# baixo — é o ponto do *Reigns* (`063`), o TAMANHO da mudança à vista.
	secao("O QUE MEXE NA COMERCIAL")
	var grade := GridContainer.new()
	grade.columns = 2
	grade.add_theme_constant_override("h_separation", 16)
	grade.add_theme_constant_override("v_separation", 2)
	_vbox.add_child(grade)
	linha_de_apoio(grade, "Atender um barco", _pontos(GameState.REPUTATION_GAIN_SERVED))
	linha_de_apoio(grade, "Perder um barco sem trabalhador", _pontos(-GameState.REPUTATION_LOSS_LOST))
	linha_de_apoio(grade, "Fechar um acordo com o rival", _pontos(GameState.REPUTATION_GAIN_RIVAL_MATCHED))
	linha_de_apoio(grade, "Recusar ou perder para o rival", _pontos(-GameState.REPUTATION_LOSS_RIVAL_REFUSED))

	fio()
	# O EFEITO É MECÂNICO, não só estético — e é por isso que vale a pena
	# escrever: reputação que só mudasse o texto do chip seria decoração.
	paragrafo(("Acima do início (%d), melhora a chance de \"manter o preço\" e " +
		"\"cortar pela metade\" nas negociações com o rival. Abaixo, piora.")
		% int(GameState.REPUTATION_START))

	botao_fechar("Fechar")


# A COMERCIAL NUM QUADRO: o nome, o número e o patamar na linha de cima, e
# quanto falta para o degrau seguinte por baixo. A barra dela é a escada, logo
# abaixo.
func _eixo_comercial(rep: float) -> void:
	var bloco := PanelContainer.new()
	bloco.name = "Comercial"
	bloco.theme_type_variation = "BlocoNumero"
	_vbox.add_child(bloco)
	var coluna := VBoxContainer.new()
	coluna.add_theme_constant_override("separation", 4)
	bloco.add_child(coluna)
	var topo := HBoxContainer.new()
	coluna.add_child(topo)
	var nome := Label.new()
	nome.text = "Comercial"
	nome.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	topo.add_child(nome)
	var valor := Label.new()
	valor.name = "Valor"
	valor.text = "%s — %s" % [_pontos_sem_sinal(rep), GameState.reputation_label()]
	valor.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	topo.add_child(valor)

	var apoio := Label.new()
	apoio.name = "Proximo"
	apoio.theme_type_variation = "RotuloApoio"
	apoio.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	apoio.text = _proximo_degrau(rep)
	coluna.add_child(apoio)


# Quanto falta para subir, e para que nome. No topo não há degrau acima, e a
# frase diz isso em vez de prometer um que não existe.
func _proximo_degrau(rep: float) -> String:
	var acima: Array = []
	for par in PATAMARES:
		if float(par[0]) > rep:
			acima = par
	if acima.is_empty():
		return "O topo da escada."
	return "Faltam %s para %s." % [_pontos_sem_sinal(float(acima[0]) - rep), String(acima[1])]


func _eixo_trancado(nome: String, decide: String) -> void:
	var bloco := PanelContainer.new()
	bloco.name = nome
	bloco.theme_type_variation = "BlocoNumero"
	_vbox.add_child(bloco)
	var linha := HBoxContainer.new()
	linha.add_theme_constant_override("separation", 8)
	bloco.add_child(linha)
	linha.add_child(Icones.imagem(Icones.BLOQUEADO))
	var coluna := VBoxContainer.new()
	coluna.add_theme_constant_override("separation", 0)
	coluna.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	linha.add_child(coluna)
	var rotulo := Label.new()
	rotulo.theme_type_variation = "RotuloApoio"
	rotulo.text = "%s — abre na Fase 2" % nome
	coluna.add_child(rotulo)
	var apoio := Label.new()
	apoio.theme_type_variation = "RotuloApoio"
	apoio.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	apoio.text = decide
	coluna.add_child(apoio)


# "+0,8" / "-2,5" — vírgula em vez de ponto (é assim que o jogo já escreve os
# outros números fracionários), e o sinal sempre escrito, mesmo no positivo:
# numa lista de "o que sobe e o que desce", omitir o "+" faria a leitura
# hesitar sobre qual linha é qual.
func _pontos(v: float) -> String:
	return "%s%s" % ["+" if v >= 0 else "-", _pontos_sem_sinal(absf(v))]


func _pontos_sem_sinal(v: float) -> String:
	return ("%.1f" % v).replace(".", ",")
