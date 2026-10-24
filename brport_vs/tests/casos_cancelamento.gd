extends RefCounted

var gs
var arvore: SceneTree
var falhas := 0
var completo := false


func conferir(nome: String, condicao: bool) -> void:
	print("PASS T24: " if condicao else "FAIL T24: ", nome)
	if not condicao:
		falhas += 1


func barco(id: int, dias: int = 2, progresso: int = 1) -> Dictionary:
	return {"id": id, "value": 10000, "classe": "medio" if dias > 1 else "pesqueiro",
		"motivo": "conteiner" if dias > 1 else "pescado", "op_turns": dias,
		"progress": progresso, "rival": false, "matched": false, "matched_value": 0, "paciencia": 2}


func montar() -> void:
	gs._rng.seed = 420
	gs.new_game()
	gs.numero_da_fase = 2
	gs.phase = gs.ESTADO_JOGANDO
	gs.turn = 86
	gs.cash = 10000
	gs.reputation = 65.0
	gs.nome_porto = "Cais do teste"
	gs.estruturas = ["pier_2", "trelica", "patio"]
	gs.workers.append(gs.novo_trabalhador())
	gs.workers[0]["busy_turns"] = 1
	gs.docks = [{"boat": barco(101), "worker_id": 1}, {"boat": null, "worker_id": null}]
	gs.fila = []
	gs.pending_rival = -1


func cancelar() -> bool:
	return gs.cancelar_servico(0, 101, gs.custos_do_cancelamento(0, 101))


func rodar(estado, tree: SceneTree) -> void:
	gs = estado
	arvore = tree
	montar()
	conferir("doca e identidade inválidas recusadas", gs.custos_do_cancelamento(-1, 101).is_empty()
		and not gs.cancelar_servico(0, 999, {}))
	for fase in [gs.ESTADO_OFERTA, gs.ESTADO_COBRANCA, gs.ESTADO_FIM]:
		gs.phase = fase
		conferir("recusa fora de jogando: " + fase, not cancelar() and gs.cash == 10000)
	gs.phase = gs.ESTADO_JOGANDO
	gs.docks[0]["boat"]["progress"] = 0
	gs.fila = [barco(201, 1, 0), barco(202, 1, 0), barco(203, 1, 0)]
	conferir("devolução sem espaço recusa gratuitamente", not gs.desatracar(0) and not cancelar() and gs.cash == 10000)
	gs.fila.clear()
	gs.workers[0]["busy_turns"] = 0
	gs.tocar_doca(0)
	conferir("toque antes de operar devolve gratuitamente", gs.docks[0]["boat"] == null and gs.fila.size() == 1 and gs.reputation == 65)
	montar()
	gs.docks[0]["boat"]["progress"] = 2
	conferir("concluído não cancela", not cancelar())
	montar()
	gs.fila = [barco(201, 1, 0), barco(202, 1, 0), barco(203, 1, 0)]
	var evento: Dictionary = gs.custos_do_cancelamento(0, 101)
	conferir("previsão separa bônus da base", evento["multa"] == 1000 and evento["receita_abandonada"] > 10000)
	conferir("fila cheia permite saída definitiva", gs.cancelar_servico(0, 101, evento) and gs.fila.size() == 3 and gs.docks[0]["boat"] == null)
	conferir("multa e reputação únicas, sem pagar serviço", gs.cash == 9000 and gs.reputation == 60
		and gs.metrics["boats_lost"] == 1 and gs.metrics["servicos_cancelados"] == 1 and gs.metrics["multas_cancelamento"] == 1000
		and gs.metrics["boats_served"] == 0 and gs.metrics["revenue"] == 0 and not gs.primeiro_cargueiro)
	conferir("repetição não cobra", not gs.cancelar_servico(0, 101, evento) and gs.cash == 9000)
	conferir("equipe reutilizada no mesmo dia", gs.workers[0]["busy_turns"] == 0 and gs.atracar(0, false) and gs.turn == 86)
	conferir("multa lançada nas contas", gs.dia_atual["cancelamento"] == 1000 and gs.semana_atual["cancelamento"] == 1000
		and gs.resumo_da_semana(13)["despesa"] == 1000 and gs.projecao_do_dia()["cancelamento"] == 1000)
	montar()
	gs.docks[0]["boat"]["motivo"] = "granel"
	gs.docks[0]["boat"]["op_turns"] = 3
	gs.workers[0]["busy_turns"] = 2
	gs.docks[0]["boat"]["matched"] = true
	gs.docks[0]["boat"]["matched_value"] = 8501
	gs.docks[1] = {"boat": barco(102), "worker_id": 2}
	gs.workers[1]["busy_turns"] = 1
	gs.reputation = 2
	conferir("granel, acordo e arredondamento", cancelar() and gs.cash == 9149 and gs.reputation == 0)
	conferir("outra doca intacta", gs.docks[1]["boat"]["id"] == 102 and gs.workers[1]["busy_turns"] == 1)
	montar()
	gs.cash = 500
	conferir("negativo permitido até ao fecho", cancelar() and gs.cash == -500 and gs.phase == gs.ESTADO_JOGANDO)
	gs.save_game()
	conferir("negativo e despesas sobrevivem à retomada", gs.load_game() and gs.cash == -500
		and gs.dia_atual["cancelamento"] == 1000 and gs.semana_atual["cancelamento"] == 1000
		and gs.metrics["servicos_cancelados"] == 1 and gs.docks[0]["boat"] == null)
	gs.fila = [barco(201, 1, 0)]
	gs.fila[0]["value"] = 4000
	gs.atracar(0, false)
	gs.advance_turn()
	conferir("recupera sem nova multa no fecho", gs.cash == 3500 and gs.phase != gs.ESTADO_FIM
		and gs.dia_anterior["cancelamento"] == 1000 and gs.resultado_do_dia(gs.dia_anterior) == 3000)
	montar()
	gs.cash = 500
	cancelar()
	gs.advance_turn()
	conferir("sem recuperação perde no fecho", gs.cash == -500 and gs.phase == gs.ESTADO_FIM)
	montar()
	gs.turn = 91
	var semanas := []
	var ouvir := func(resumo: Dictionary): semanas.append(resumo)
	gs.semana_fechada.connect(ouvir)
	cancelar()
	var projetado: int = gs.resultado_do_dia(gs.projecao_do_dia())
	gs.advance_turn()
	gs.semana_fechada.disconnect(ouvir)
	conferir("fecho semanal e projeção contam multa exatamente uma vez", semanas.size() == 1
		and semanas[0]["cancelamento"] == 1000 and gs.cash == 10000 + int(semanas[0]["resultado"])
		and gs.resultado_do_dia(gs.dia_anterior) == projetado and gs.semana_atual["cancelamento"] == 0)
	conferir("recorde do dia desconta a multa", gs.recordes()["melhor_dia"]["valor"] == projetado)
	var boletim = load("res://scenes/panels/PainelBoletim.tscn").instantiate()
	boletim.theme = load("res://ui/tema_brport.tres")
	arvore.root.add_child(boletim)
	boletim.setup(semanas[0])
	var texto_boletim := ""
	for rotulo in boletim.find_children("*", "Label", true, false):
		texto_boletim += rotulo.text + "\n"
	conferir("boletim identifica a despesa", texto_boletim.contains("Cancelamento de serviço")
		and texto_boletim.contains(gs.moeda(1000)))
	boletim.free()
	montar()
	gs.meta_concluida = true
	gs.primeiro_cargueiro = true
	cancelar()
	conferir("marcos já conquistados permanecem", gs.meta_concluida and gs.primeiro_cargueiro)
	montar()
	gs.reputation = 83
	gs.dias_de_reputacao = 2
	cancelar()
	conferir("a sequência é avaliada só no fecho", gs.dias_de_reputacao == 2 and gs.reputation == 78)
	gs.advance_turn()
	conferir("fecho abaixo da meta interrompe a sequência", gs.dias_de_reputacao == 0)
	montar()
	var anterior: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/saves/v17.json"))
	var migrado: Dictionary = gs._save_aceite(JSON.stringify(anterior))
	conferir("17→18 preserva toda a partida", not migrado.is_empty() and migrado["versao"] == 18
		and migrado["cash"] == anterior["cash"] and migrado["docks"] == anterior["docks"]
		and migrado["workers"] == anterior["workers"] and migrado["obra_em_andamento"] == anterior["obra_em_andamento"]
		and migrado["meta_concluida"] == anterior["meta_concluida"] and migrado["metrics"]["servicos_cancelados"] == 0)
	conferir("migração não inventa multa passada", migrado["metrics"]["multas_cancelamento"] == 0
		and migrado["dia_atual"]["cancelamento"] == 0 and migrado["dia_anterior"]["cancelamento"] == 0
		and migrado["semana_atual"]["cancelamento"] == 0)
	for grupo in ["dia_atual", "dia_anterior", "semana_atual", "metrics"]:
		var ruim := migrado.duplicate(true)
		ruim[grupo].erase("servicos_cancelados" if grupo == "metrics" else "cancelamento")
		conferir("18 truncada recusada: " + grupo, gs._save_aceite(JSON.stringify(ruim)).is_empty())
	await interface_e_registro()
	completo = true


func interface_e_registro() -> void:
	montar()
	var main = load("res://scenes/Main.tscn").instantiate()
	arvore.root.add_child(main)
	var overlay: Node = main.get_node("Overlay")
	var antes: int = gs.turn
	var toque := InputEventMouseButton.new()
	toque.button_index = MOUSE_BUTTON_LEFT
	toque.pressed = true
	# Porta do cartão real, e depois porta do cenário real.
	var cartao = load("res://scenes/dock/DocaCartao.tscn").instantiate()
	arvore.root.add_child(cartao)
	cartao.setup(0)
	cartao._gui_input(toque)
	conferir("press iniciado não abre confirmação", overlay.get_child_count() == 0)
	toque.pressed = false
	cartao._gui_input(toque)
	conferir("cartão abre a confirmação", overlay.get_child_count() == 1 and overlay.get_child(0).orcamento["multa"] == 1000)
	var painel = overlay.get_child(0)
	var texto_painel := ""
	for rotulo in painel.find_children("*", "Label", true, false):
		texto_painel += rotulo.text + "\n"
	conferir("confirmação mostra multa, percentual e saldo resultante", texto_painel.contains("Multa: R$1.000 (10%")
		and texto_painel.contains("Após a multa: R$9.000") and texto_painel.contains("Reputação: 65 → 60"))
	conferir("continuar é o foco inicial", painel.find_child("ContinuarServico", true, false).has_focus())
	main._on_advance_pressed()
	conferir("confirmação bloqueia avanço", gs.turn == antes and gs.phase == gs.ESTADO_JOGANDO)
	painel.find_child("ContinuarServico", true, false).pressed.emit()
	painel.confirmar()
	conferir("abandonar não cancela", gs.cash == 10000 and gs.docks[0]["boat"] != null)
	await arvore.process_frame
	await arvore.process_frame
	var cenario = load("res://scenes/dock/Dock.tscn").instantiate()
	arvore.root.add_child(cenario)
	cenario.setup(0)
	toque.pressed = true
	cenario._gui_input(toque)
	conferir("press no cenário também espera soltar", overlay.get_child_count() == 0)
	toque.pressed = false
	cenario._gui_input(toque)
	conferir("cenário abre o mesmo painel", overlay.get_child_count() == 1 and overlay.get_child(0).scene_file_path.ends_with("PainelCancelarServico.tscn"))
	painel = overlay.get_child(0)
	gs.docks[0]["boat"]["id"] = 102
	painel.confirmar()
	conferir("confirmação velha não cobra outro barco", gs.cash == 10000 and gs.docks[0]["boat"] != null)
	repor_barco_apos_defeito()
	painel.queue_free()
	await arvore.process_frame
	await arvore.process_frame
	gs.docks[0]["boat"]["id"] = 101
	gs.tocar_doca(0)
	painel = overlay.get_child(0)
	gs.cash = 10001
	painel.confirmar()
	conferir("orçamento alterado exige nova confirmação", gs.cash == 10001 and gs.docks[0]["boat"] != null)
	# ⚠️ E A RECUSA NÃO SE DESFAZ QUANDO O NÚMERO VOLTA (`138`). O painel pede
	# para fechar e abrir de novo, e quem o promete é a bandeira `_respondido`:
	# sem ela, o caixa de volta ao que o orçamento leu e uma segunda
	# confirmação cancelavam com a conta que o jogador foi mandado reler. Pela
	# tela o botão já fica desligado; a bandeira segura quem chama a ação por
	# fora — a captura da Fase 2, e esta suíte.
	gs.cash = 10000
	painel.confirmar()
	conferir("recusa pede reabrir: confirmar outra vez não cancela", gs.cash == 10000 and gs.docks[0]["boat"] != null)
	repor_barco_apos_defeito()
	painel.queue_free()
	await arvore.process_frame
	await arvore.process_frame


	gs.cash = 10000
	gs.tocar_doca(0)
	painel = overlay.get_child(0)
	overlay.remove_child(painel)
	painel.confirmar()
	conferir("painel removido não pode confirmar", gs.cash == 10000 and gs.docks[0]["boat"] != null)
	painel.free()
	gs.tocar_doca(0)
	painel = overlay.get_child(0)
	# ⚠️ PELO BOTÃO, E NÃO PELA FUNÇÃO (`138`): até aqui o bloco inteiro
	# chamava `confirmar()` direto, e o botão que o jogador prime podia sair
	# da árvore com tudo verde. O que se prime é o que diz «Cancelar serviço».
	var botao_cancelar: Button = null
	for botao in painel.find_children("*", "Button", true, false):
		if botao.text == "Cancelar serviço" and botao.is_visible_in_tree():
			botao_cancelar = botao
	conferir("a confirmação mostra o botão Cancelar serviço", botao_cancelar != null)
	if botao_cancelar != null:
		botao_cancelar.pressed.emit()
		botao_cancelar.pressed.emit()
	else:
		painel.confirmar()
		painel.confirmar()
	conferir("confirmação real cobra uma vez", gs.cash == 9000 and gs.metrics["servicos_cancelados"] == 1)
	var registro = arvore.root.get_node("Registro")
	var linhas := String(registro.texto_para_exportar()).split("\n", false)
	var eventos := []
	for linha in linhas:
		var ev = JSON.parse_string(linha)
		if ev["e"] == "cancelamento":
			eventos.append(ev)
	conferir("registro 5 observa uma vez, sem identidade pessoal", JSON.parse_string(linhas[0])["versao"] == 5
		and eventos.size() == 1 and eventos[0]["uid"] == 101
		and eventos[0]["multa"] == 1000 and eventos[0]["valor_acordado"] == 10000
		and eventos[0]["receita_abandonada"] > 10000 and not eventos[0].has("nome_jogador"))
	registro.desarmar()
	cartao.queue_free()
	cenario.queue_free()
	main.queue_free()
	await arvore.process_frame
	await arvore.process_frame


# Um mutante que cancela o barco errado precisa falhar na asserção acima,
# não abortar a prova seguinte ao escrever num barco que já virou null.
func repor_barco_apos_defeito() -> void:
	if gs.docks[0]["boat"] == null:
		gs.docks[0] = {"boat": barco(101), "worker_id": 1}
		gs.workers[0]["busy_turns"] = 1
