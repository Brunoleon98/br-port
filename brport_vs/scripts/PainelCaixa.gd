extends PainelNarrativo

# ============================================================
# BR Port VS — o resumo do caixa, ao toque no dinheiro do HUD
#
# Quarto item da primeira análise de playtest (02/09): "tocar no dinheiro do
# HUD abre um resumo do ganho de ontem e o projetado para hoje". O Boletim já
# existe e fecha a SEMANA; isto responde a uma pergunta menor e mais frequente
# — "o que aconteceu no último dia, e o que vai acontecer se eu avançar agora"
# — sem esperar pelo fim da semana para saber.
#
# DUAS CONTAS, DUAS NATUREZAS. "Ontem" é HISTÓRICO: `dia_anterior` já
# aconteceu, e este painel só o lê. "Hoje" é PROJEÇÃO: o dia em curso ainda não
# foi jogado, então `GameState.projecao_do_dia()` SIMULA o que `advance_turn()`
# faria sem mexer em nada — nem no caixa, nem numa doca. Se a simulação e o
# turno real alguma vez divergirem, é ali que se conserta, não aqui.
#
# MESMO ANDAIME DO BOLETIM: duas grades (receita/despesa), zero não entra na
# lista, resultado em destaque. É a mesma pergunta ("quanto entrou, quanto
# saiu"), numa janela mais curta.
# ============================================================

const LARGURA := 440
const ALTURA := 0    # ajusta ao conteúdo: cada bloco tem um número diferente de linhas

var _resumo: Dictionary = {}


func setup(resumo: Dictionary) -> void:
	_resumo = resumo
	montar(LARGURA, ALTURA, ESCURO_DECISAO)
	titulo(Icones.CAIXA, "Resumo do Caixa")

	_bloco_do_dia("ONTEM", _resumo["ontem"] as Dictionary)
	fio()
	_bloco_do_dia("PROJETADO PARA HOJE, SE AVANÇAR AGORA", _resumo["hoje"] as Dictionary)

	botao_fechar("Fechar")


func _bloco_do_dia(rotulo_secao: String, dia: Dictionary) -> void:
	var turno := int(dia["turno"])
	if turno <= 0:
		secao(rotulo_secao)
		paragrafo("O primeiro dia ainda não fechou.")
		return
	secao("%s — DIA %d" % [rotulo_secao, turno])

	var receita: int = int(dia["docagens"]) + int(dia["armazem"]) \
		+ int(dia["patio"]) + int(dia["pier"])
	var despesa: int = int(dia["salarios"]) + int(dia["manutencao"]) + int(dia["parcela"])

	# LINHA COM ZERO NÃO ENTRA — a mesma regra do Boletim. Um dia comum não tem
	# nem aluguel de píer nem parcela; escrevê-los a R$0 seria ruído repetido a
	# cada abertura deste painel.
	var grade := GridContainer.new()
	grade.columns = 2
	grade.add_theme_constant_override("h_separation", 16)
	_vbox.add_child(grade)
	for linha in [["Docagens", int(dia["docagens"])],
			["Armazém", int(dia["armazem"])],
			["Pátio de contêineres", int(dia["patio"])],
			["Aluguel de píer", int(dia["pier"])],
			["Salários", -int(dia["salarios"])],
			["Manutenção", -int(dia["manutencao"])],
			["Parcela", -int(dia["parcela"])]]:
		if int(linha[1]) == 0:
			continue
		_linha(grade, String(linha[0]), int(linha[1]))

	var resultado := receita - despesa
	fio()
	total("Resultado: %s" % GameState.moeda(resultado))

	var partes := PackedStringArray()
	if int(dia["servidos"]) > 0:
		partes.append("%d barco%s atendido%s" % [int(dia["servidos"]),
			"" if int(dia["servidos"]) == 1 else "s",
			"" if int(dia["servidos"]) == 1 else "s"])
	if int(dia["perdidos"]) > 0:
		partes.append("%d perdido%s" % [int(dia["perdidos"]),
			"" if int(dia["perdidos"]) == 1 else "s"])
	if not partes.is_empty():
		paragrafo(" e ".join(partes))


# Valor pode ser negativo (despesa) — `moeda()` já escreve o sinal sozinha
# (é a mesma função que o resto do jogo usa para dinheiro). Alinhado à direita
# pela mesma razão do Boletim: números empilhados só se comparam alinhados por
# um lado.
func _linha(grade: GridContainer, rotulo: String, valor: int) -> void:
	var esquerda := Label.new()
	esquerda.text = rotulo
	esquerda.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grade.add_child(esquerda)

	var direita := Label.new()
	direita.text = GameState.moeda(valor)
	direita.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	grade.add_child(direita)
