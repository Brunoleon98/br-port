extends RefCounted

# Só lê a partida já carregada. Prazo, receita e metas pertencem às consultas
# do jogo: simular um avanço aqui sortearia chegadas e gravaria a partida.
static func resumir(gs: Node) -> Dictionary:
	var encerrada: bool = gs.phase == gs.ESTADO_FIM
	# Na cobrança o contador já aponta ao dia seguinte, mas esse dia espera
	# a decisão. Mostrar o dia fechado também mantém a semana coerente.
	var turno_visivel: int = gs.vencimento_da_parcela() if gs.phase == gs.ESTADO_COBRANCA else gs.turn
	var dia: String = gs.rotulo_do_dia(turno_visivel)
	if gs.fase_tem_prazo():
		dia = "Fase %d · %s" % [gs.numero_da_fase, dia]
	if gs.phase == gs.ESTADO_COBRANCA:
		dia += " encerrado"
	var resumo := {"porto": String(gs.nome_porto), "dia": dia,
		"semana": "Semana %d" % gs.week_of(turno_visivel), "caixa": gs.moeda(gs.cash),
		"obra": "Nenhuma obra em andamento.", "servicos": [],
		"cobranca": _cobranca(gs), "meta": _meta(gs), "situacao": "", "encerrada": encerrada}
	if gs.phase == gs.ESTADO_FIM:
		resumo["situacao"] = "Partida encerrada. %s" % gs.end_reason
	elif gs.phase == gs.ESTADO_OFERTA:
		resumo["situacao"] = "Uma negociação com o Arlindo aguarda sua decisão ao entrar no porto."
	elif gs.phase == gs.ESTADO_COBRANCA:
		resumo["situacao"] = "A cobrança do dia %d aguarda sua decisão; o próximo dia ainda não começou." % gs.vencimento_da_parcela()
	if not gs.obra_em_andamento.is_empty():
		var obra: Dictionary = gs.obra_em_andamento
		if encerrada:
			resumo["obra"] = "%s · obra interrompida com o encerramento da partida." % gs.ESTRUTURAS[obra["id"]]["nome"]
		else:
			resumo["obra"] = "%s · %s. Conclusão em %s." % [
				gs.ESTRUTURAS[obra["id"]]["nome"], gs.prazo_da_obra(int(obra["conclusao"])),
				Narrativa.concordar(gs.dias_restantes_da_obra(), "dia", "dias")]
	for i in range(gs.docks.size()):
		var doca: Dictionary = gs.docks[i]
		if doca["boat"] == null:
			continue
		var barco: Dictionary = doca["boat"]
		var linha := "Doca %d · %s · %s\nProgresso: %d de %s de trabalho." % [
			i + 1, gs.CLASSES_DE_NAVIO[barco["classe"]]["nome"],
			gs.MOTIVOS[barco["motivo"]]["nome"], int(barco["progress"]), Narrativa.concordar(int(barco["op_turns"]), "dia", "dias")]
		if encerrada:
			linha += " Atendimento interrompido; sem novo recebimento nesta partida."
		elif doca["worker_id"] == null:
			linha += " Sem trabalhador: sai ao avançar o dia; sem recebimento previsto."
		else:
			var faltam: int = int(barco["op_turns"]) - int(barco["progress"])
			linha += " Recebimento previsto: %s, ao avançar %s." % [gs.moeda(gs.receita_da_doca(i)),
				Narrativa.concordar(faltam, "dia", "dias")]
		resumo["servicos"].append(linha)
	return resumo


static func _cobranca(gs: Node) -> String:
	if not gs.tem_cobranca():
		return "Sem cobranças nesta fase."
	if gs.phase == gs.ESTADO_FIM:
		return "A partida está encerrada; não há próxima cobrança a jogar."
	var indice: int = gs.parcela_indice
	if gs.parcela_paid:
		var recibo := "Parcela %d quitada. O recibo permanece até o fecho do período." % (indice + 1)
		var seguinte := indice + 1
		if seguinte < gs.parcelas_na_fase():
			return recibo + "\nPróxima cobrança: parcela %d, %s no dia %d. Ainda não aberta para pagamento." % [
				seguinte + 1, gs.moeda(gs.valor_da_parcela(seguinte)), gs.dia_da_parcela(seguinte)]
		return recibo + "\nTodas as parcelas desta fase estão quitadas."
	return "%s: parcela %d · %s · vencimento no dia %d." % [
		"Cobrança pendente" if gs.phase == gs.ESTADO_COBRANCA else "Próxima cobrança",
		indice + 1, gs.moeda(gs.principal_da_parcela()), gs.vencimento_da_parcela()]


static func _meta(gs: Node) -> String:
	if gs.numero_da_fase == 1:
		var progresso := "%d de %s" % [gs.parcelas_quitadas,
			Narrativa.concordar(gs.parcelas_na_fase(), "parcela quitada", "parcelas quitadas")]
		if gs.phase == gs.ESTADO_FIM:
			return progresso + " no encerramento."
		return "Quitar as parcelas e manter o porto no azul até o fim da fase.\n%d de %s · fecho da fase ao fim do dia %d." % [
			gs.parcelas_quitadas, Narrativa.concordar(gs.parcelas_na_fase(), "parcela quitada", "parcelas quitadas"), gs.ultimo_dia_da_fase()]
	var meta: Dictionary = gs.progresso_da_meta()
	if meta["concluida"]:
		if gs.phase == gs.ESTADO_FIM:
			return "Meta da Fase 2 concluída antes do encerramento da partida."
		return "Meta da Fase 2 concluída — jogo livre. Sem prazo para encerrar."
	var estruturas := PackedStringArray()
	for id in gs.dados_da_fase()["meta"]["infra"]:
		estruturas.append(gs.ESTRUTURAS[id]["nome"])
	var situacao := "Critérios no encerramento." if gs.phase == gs.ESTADO_FIM else "Fase 2 · sem prazo para concluir."
	return "%s\nReputação: %d de %s com pelo menos %s.\nInfraestrutura: %d de %s (%s).\nMissão: %d de 1 — atender o primeiro cargueiro; atracar não basta." % [
		situacao, meta["dias"], Narrativa.concordar(int(meta["dias_alvo"]), "dia consecutivo fechado", "dias consecutivos fechados"),
		Narrativa.concordar(int(meta["reputacao_alvo"]), "ponto", "pontos"), meta["infra"],
		Narrativa.concordar(int(meta["infra_alvo"]), "estrutura concluída", "estruturas concluídas"),
		", ".join(estruturas), meta["missao"]]
