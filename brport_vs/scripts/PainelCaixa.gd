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
# MESMO ANDAIME DO BOLETIM (26/09, `065`): o total de cada bloco na linha
# dele e as parcelas por baixo, no tom de apoio (`bloco_de_contas()`). O dia
# que JÁ ACONTECEU fecha numa tarja com o tom do resultado, como a semana do
# boletim; o dia projetado fecha numa linha de total sem tarja — é previsão, e
# duas tarjas num cartão seriam dois destaques, que é nenhum.
#
# E OS RECORDES DA PARTIDA, pedido do Bruno no gate do A5: melhor dia, mais
# barcos num dia, maior negócio e melhor semana, em quadros como os números do
# balanço. Saem de `GameState.recordes()`, e zeram com a partida.
# ============================================================

const LARGURA := 440
const ALTURA := 0    # ajusta ao conteúdo: cada bloco tem um número diferente de linhas

var _resumo: Dictionary = {}


func setup(resumo: Dictionary) -> void:
	_resumo = resumo
	montar(LARGURA, ALTURA, ESCURO_DECISAO)
	titulo_encorpado(Icones.CAIXA, "Dinheiro do dia")

	var ontem: Dictionary = _resumo["ontem"]
	if int(ontem["turno"]) <= 0:
		secao("ONTEM")
		paragrafo("O primeiro dia ainda não fechou.")
	else:
		secao("ONTEM — DIA %d" % int(ontem["turno"]))
		_contas(ontem)
		var resultado: int = GameState.resultado_do_dia(ontem)
		tarja(Narrativa.lucro_ou_prejuizo(resultado, GameState.moeda, true),
			_barcos(ontem),
			&"bom" if resultado > 0 else (&"ruim" if resultado < 0 else &"neutro"))

	var hoje: Dictionary = _resumo["hoje"]
	secao("SE AVANÇAR AGORA — DIA %d" % int(hoje["turno"]))
	_contas(hoje)
	total(Narrativa.lucro_ou_prejuizo(GameState.resultado_do_dia(hoje), GameState.moeda, true))
	var barcos_hoje := _barcos(hoje)
	if barcos_hoje != "":
		var apoio := paragrafo(barcos_hoje)
		apoio.theme_type_variation = "RotuloApoio"

	_recordes()

	botao_fechar("Fechar")


# O que entrou e o que saiu, cada bloco encabeçado pelo seu total. Bloco a
# zero não entra — é a regra da linha a zero, um andar acima: um dia comum não
# tem saída nenhuma, e «Saiu R$0» seria ruído em quase toda abertura.
func _contas(dia: Dictionary) -> void:
	var receita: int = int(dia["docagens"]) + int(dia["armazem"]) \
		+ int(dia["patio"]) + int(dia["pier"])
	var despesa: int = int(dia["salarios"]) + int(dia["manutencao"]) + int(dia["parcela"])
	if receita != 0:
		bloco_de_contas("Entrou", [
			["Docagens", int(dia["docagens"])],
			["Armazém", int(dia["armazem"])],
			["Pátio de contêineres", int(dia["patio"])],
			["Aluguel de píer", int(dia["pier"])],
		], receita)
	if despesa != 0:
		bloco_de_contas("Saiu", [
			["Salários", int(dia["salarios"])],
			["Manutenção", int(dia["manutencao"])],
			["Parcela", int(dia["parcela"])],
		], despesa)
	if receita == 0 and despesa == 0:
		var nada := paragrafo("Nada entra nem sai.")
		nada.theme_type_variation = "RotuloApoio"


# ⚠️ ERAM TRÊS TERNÁRIOS `"" if n == 1 else "s"` À MÃO, e o de cima escrevia
# a MESMA condição duas vezes na mesma expressão — uma para o substantivo e
# outra para o particípio. A saída estava certa; o que estava errado é a
# regra do plural viver em cinco sítios.
func _barcos(dia: Dictionary) -> String:
	var partes := PackedStringArray()
	if int(dia["servidos"]) > 0:
		partes.append(Narrativa.concordar(
			int(dia["servidos"]), "barco atendido", "barcos atendidos"))
	if int(dia["perdidos"]) > 0:
		partes.append(Narrativa.concordar(
			int(dia["perdidos"]), "perdido", "perdidos"))
	return " e ".join(partes)


# OS QUATRO RECORDES, sempre os quatro e na mesma ordem: um quadro que
# aparecesse só depois do primeiro dia mudaria o cartão de tamanho entre duas
# aberturas, e o jogador perderia o sítio de cada um. O que ainda não houve
# mostra «—» e diz porquê.
#
# ⚠️ O DIA DO RECORDE PODE SER O DE ONTEM, e é o caso mais comum no começo:
# `GameState.recordes()` soma o `dia_anterior` vivo, então o recorde e a tarja
# de cima leem o MESMO dia — e dizem o mesmo número.
func _recordes() -> void:
	var r: Dictionary = GameState.recordes()
	secao("RECORDES DA PARTIDA")
	var quadros := grade_de_quadros()

	var dia: Dictionary = r["melhor_dia"]
	if int(dia["turno"]) > 0:
		quadro(quadros, "Melhor dia", GameState.moeda(int(dia["valor"])),
			"dia %d" % int(dia["turno"]))
	else:
		quadro(quadros, "Melhor dia", "—", "nenhum dia fechou")

	var barcos: Dictionary = r["mais_barcos"]
	if int(barcos["turno"]) > 0:
		quadro(quadros, "Mais barcos num dia", str(int(barcos["n"])),
			"dia %d" % int(barcos["turno"]))
	else:
		quadro(quadros, "Mais barcos num dia", "—", "nenhum atendido")

	var negocio: Dictionary = r["maior_negocio"]
	if int(negocio["turno"]) > 0:
		quadro(quadros, "Maior negócio", GameState.moeda(int(negocio["valor"])),
			"%s · dia %d" % [String(GameState.MOTIVOS[String(negocio["motivo"])]["nome"]),
				int(negocio["turno"])])
	else:
		quadro(quadros, "Maior negócio", "—", "nenhum barco pago")

	var semana: Dictionary = r["melhor_semana"]
	if int(semana["semana"]) > 0:
		quadro(quadros, "Melhor semana", GameState.moeda(int(semana["valor"])),
			"semana %d" % int(semana["semana"]))
	else:
		quadro(quadros, "Melhor semana", "—",
			"a primeira fecha no dia %d" % GameState.TURNS_PER_WEEK)
