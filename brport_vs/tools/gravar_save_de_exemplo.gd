extends SceneTree

# ============================================================
# BR Port VS — O SAVE DE EXEMPLO DA VERSÃO CORRENTE (`docs/decisoes/098`)
#
# A migração do save é encadeada: cada versão nova traz o degrau que lê a
# anterior. Quem prova os degraus é um save de EXEMPLO por versão, gravado
# pelo jogo dessa versão e guardado em `tests/saves/vNN.json`, e o F21 do
# `teste_fumaca` exige que todos carreguem. Esta ferramenta grava o da versão
# corrente — e só ele: o de uma versão antiga é o que o jogo dessa versão
# escreveu, e não se refaz com o código de outra.
#
# POR QUE JOGAR, E NÃO ESCREVER O JSON À MÃO. O exemplo responde «o que é que
# esta versão grava?», e um dicionário escrito à mão responde o que quem o
# escreveu supôs. É a pergunta do F21: um campo que o `save_game()` grave e o
# `load_game()` não reponha só aparece na ida e volta de um save DE VERDADE.
#
# POR QUE ESTE DIA. A partida pára no primeiro dia em que o save tem tudo o
# que o `load_game()` trata à parte — obra em andamento, barco ao largo e
# atracado, parcela quitada, reparo pronto, semana fechada, recorde e os dois
# nomes. Um exemplo do dia 1 tem esses campos VAZIOS, e a ida e volta de um
# campo vazio passa com o `load_game()` a ignorá-lo: o F21 confere a mesma
# lista, para o exemplo de uma versão futura não sair pobre.
#
# ⚠️ E DESDE A 15 O PRIMEIRO MÊS É JOGADO MAL, de propósito (`102`). A 15
# grava a segunda chance do Sr. Ribeiro — a dívida dela e se foi usada —, e um
# exemplo que nunca a pediu grava-as a zero, que é o campo vazio de cima. A
# partida conserta o que pode e não atraca ninguém até ao primeiro
# vencimento, chega lá sem o boleto, aceita o empréstimo e joga bem dali em
# diante; pára antes da cobrança seguinte, com a dívida ainda por pagar.
#
# ⚠️ E DESDE A 16 ELE PASSA À FASE 2 (`104`). O campo novo é o número da fase,
# e um exemplo da Fase 1 gravava-o a 1 — o valor que o degrau escreve e que a
# partida nova traz, o campo vazio de cima outra vez. A partida joga BEM desde
# o primeiro dia, paga as três e pára no primeiro dia da Fase 2 com tudo: o
# primeiro mês mal jogado da 15 não chegava à segunda cobrança (medido: sem
# caixa no dia 57), e a dívida que ele trazia a passagem zera na mesma.
# Ali a parcela quitada e a dívida da segunda chance são ZERO por regra — a
# passagem recomeça-as —, e por isso saíram da lista: a ida e volta delas é do
# T14 e do T18. No lugar entra o que a Fase 2 guarda delas: o recibo da 1 no
# `total_pago_parcelas`.
#
# Rodar (o exemplo existente só se substitui de propósito, antes de a versão
# chegar à main — depois disso ele é o registo do que ela gravava):
#   $G --headless --path brport_vs --script res://tools/gravar_save_de_exemplo.gd
#   $G --headless --path brport_vs --script res://tools/gravar_save_de_exemplo.gd -- --refazer
#
# ⚠️ Não corra em paralelo com as suítes: o jogo grava em `user://ferramentas/`,
# que é partilhada (`CLAUDE.md`, «Como rodar»).
# ============================================================

const PASTA := "res://tests/saves"
const SEMENTE := 20260825
const NOME_PORTO := "Cais do Exemplo"
const NOME_JOGADOR := "Quem Testa"
const TETO_DE_DIAS := 200

var _feito := false


func _process(_delta: float) -> bool:
	if _feito:
		return true
	_feito = true
	_rodar()
	return true


func _rodar() -> void:
	var GS: Node = root.get_node_or_null("GameState")
	if GS == null:
		print("FALHA: o GameState não está registrado.")
		quit(1)
		return
	var versao: int = GS.SAVE_VERSION
	var destino := ProjectSettings.globalize_path("%s/v%d.json" % [PASTA, versao])
	if FileAccess.file_exists(destino) and not OS.get_cmdline_user_args().has("--refazer"):
		print("FALHA: o exemplo da versão %d já existe (%s). Ele é o registo do que a %d grava; só se refaz com --refazer, e só enquanto ela não estiver na main." % [versao, destino, versao])
		quit(1)
		return

	GS._rng.seed = SEMENTE
	GS.new_game()
	GS.definir_nomes(NOME_PORTO, NOME_JOGADOR)
	# Teto em dias e não o prazo da fase: a Fase 2 não tem prazo, e pedi-lo
	# rebenta (`104`). Duzentos é mais do dobro de onde o exemplo pára.
	while true:
		if GS.phase == "game_over" or GS.turn > TETO_DE_DIAS:
			print("FALHA: a partida acabou no dia %d sem chegar a um save com tudo: %s" % [GS.turn, faltas(GS)])
			quit(1)
			return
		if GS.phase == "rival_offer":
			GS.negotiate_rival("igualar")
			continue
		if GS.phase == "debt_payment":
			if GS.pode_pedir_segunda_chance():
				GS.aceitar_segunda_chance()
			else:
				GS.pay_debt()
			if GS.phase == "debt_payment":
				print("FALHA: a partida não teve caixa para a parcela do dia %d." % GS.turn)
				quit(1)
				return
			continue
		for id in GS.ESTRUTURAS.keys():
			# A última obra fica para depois da conquista: o exemplo 17 traz
			# a conquista, a missão e os dias cheios junto de uma obra viva.
			if id == "escritorio" and GS.numero_da_fase == 2:
				continue
			if GS.impedimento_estrutura(id) == "":
				GS.comprar_estrutura(id)
		for _b in range(GS.bercos_livres()):
			if GS.atracagem_pendente() == Vector2i.ZERO or not GS.atracar(0, false):
				break
		if faltas(GS) == ["uma obra em andamento"]:
			GS.comprar_estrutura("escritorio")
		if faltas(GS).is_empty():
			break
		GS.advance_turn()

	GS.save_game()
	var texto := FileAccess.get_file_as_string(GS.save_path)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(PASTA))
	var f := FileAccess.open(destino, FileAccess.WRITE)
	if f == null:
		print("FALHA: não consegui escrever %s" % destino)
		quit(1)
		return
	f.store_string(texto)
	f.close()
	GS.clear_save()
	print("EXEMPLO GRAVADO — versão %d, dia %d, em %s" % [versao, GS.turn, destino])
	quit(0)


# O que falta ao save de agora para servir de exemplo; vazio quando tem tudo.
# É a MESMA lista que o F21 do `teste_fumaca` confere no exemplo da versão
# corrente — lá, lida do arquivo; aqui, do estado vivo, para saber onde parar.
static func faltas(GS: Node) -> Array[String]:
	var falta: Array[String] = []
	if GS.phase != "playing":
		falta.append("a partida a correr")
	if int(GS.numero_da_fase) < 2:
		falta.append("a Fase 2")
	if not GS.meta_concluida or not GS.primeiro_cargueiro or GS.dias_de_reputacao == 0:
		falta.append("a meta conquistada, a missão e os dias de reputação")
	if GS.obra_em_andamento.is_empty():
		falta.append("uma obra em andamento")
	if GS.fila.is_empty():
		falta.append("um barco ao largo")
	if not GS.docks.any(func(d): return d["boat"] != null):
		falta.append("um barco atracado")
	if int(GS.total_pago_parcelas) <= 0:
		falta.append("o recibo da Fase 1")
	if GS.estruturas.is_empty():
		falta.append("um reparo pronto")
	if GS.historico_semanas.is_empty():
		falta.append("uma semana fechada")
	# Medido na primeira corrida: sem esta linha a partida parava no dia 29,
	# que abre a semana 5, e a semana corrente ia toda a zero para o exemplo.
	if not GS.semana_atual.values().any(func(v): return int(v) != 0):
		falta.append("uma semana a meio")
	if int(GS._recordes["melhor_dia"]["turno"]) == 0:
		falta.append("um recorde")
	if String(GS.nome_porto) == "" or String(GS.nome_jogador) == "":
		falta.append("os dois nomes")
	return falta
