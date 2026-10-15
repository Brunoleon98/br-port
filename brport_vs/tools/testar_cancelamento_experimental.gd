extends SceneTree

var gs
var falhas := 0
var rodou := false


func _process(_delta: float) -> bool:
	if rodou:
		return false
	rodou = true
	gs = load("res://tools/estado_cancelamento_experimental.gd").new()
	_montar()
	_confere("id antigo recusa sem cobrança", not gs.cancelar_no_experimento(0, 999) and gs.cash == 10000)
	_confere("doca inválida recusa", not gs.cancelar_no_experimento(-1, 101))
	gs.phase = gs.ESTADO_OFERTA
	_confere("fora de jogando recusa", not gs.cancelar_no_experimento(0, 101))
	gs.phase = gs.ESTADO_JOGANDO
	gs.docks[0]["boat"]["progress"] = 0
	_confere("antes de operar não cancela", not gs.cancelar_no_experimento(0, 101))
	gs.fila = []
	_confere("devolução gratuita preservada", gs.desatracar(0) and gs.cash == 10000 and gs.reputation == 65)
	_montar()
	gs.fila = [_barco(201, 4000, 0, 1), _barco(202, 4000, 0, 1), _barco(203, 4000, 0, 1)]
	_confere("cancela com fila cheia", gs.cancelar_no_experimento(0, 101) and gs.fila.size() == 3)
	_confere("multa e reputação uma vez", gs.cash == 9000 and gs.reputation == 60 and gs.cancelamentos.size() == 1)
	_confere("sem atendimento, receita ou missão", gs.metrics["boats_served"] == 0 and gs.metrics["revenue"] == 0 and not gs.primeiro_cargueiro)
	_confere("conta perdido uma vez", gs.metrics["boats_lost"] == 1 and gs.dia_atual["perdidos"] == 1)
	_confere("libera trabalhador ocupado", gs.workers[0]["busy_turns"] == 0 and gs.docks[0]["worker_id"] == null)
	_confere("confirmação repetida é inócua", not gs.cancelar_no_experimento(0, 101) and gs.cash == 9000)
	_confere("troca usa trabalhador no mesmo dia", gs.atracar(0, false) and gs.docks[0]["worker_id"] == 1)
	_confere("não avança dia", gs.turn == 86)
	_montar()
	gs.docks[0]["boat"]["motivo"] = "granel"
	gs.docks[0]["boat"]["op_turns"] = 3
	gs.workers[0]["busy_turns"] = 2
	gs.docks[1]["boat"] = _barco(102, 7000, 1, 2)
	gs.docks[1]["worker_id"] = 2
	gs.workers[1]["busy_turns"] = 1
	_confere("granel a meio cancela", gs.cancelar_no_experimento(0, 101))
	_confere("outra doca e equipe intactas", gs.docks[1]["boat"]["id"] == 102 and gs.workers[1]["busy_turns"] == 1)
	_montar()
	gs.docks[0]["boat"]["matched"] = true
	gs.docks[0]["boat"]["matched_value"] = 8501
	_confere("arredonda preço acordado para cima", gs.multa_do_experimento(0) == 851)
	gs.reputation = 2.0
	gs.primeiro_cargueiro = true
	gs.meta_concluida = true
	gs.cancelar_no_experimento(0, 101)
	_confere("clamp e marcos preservados", gs.reputation == 0 and gs.primeiro_cargueiro and gs.meta_concluida)
	_montar()
	gs.cash = 500
	gs.fila = [_barco(201, 4000, 0, 1)]
	_confere("saldo insuficiente não bloqueia", gs.cancelar_no_experimento(0, 101) and gs.cash == -500 and gs.phase == gs.ESTADO_JOGANDO)
	gs.atracar(0, false)
	gs.advance_turn()
	_confere("receita nova recupera antes do fecho", gs.cash == 3500 and gs.phase != gs.ESTADO_FIM)
	_montar()
	gs.cash = 500
	gs.fila = []
	gs.cancelar_no_experimento(0, 101)
	gs.advance_turn()
	_confere("sem recuperar quebra no fecho real", gs.cash == -500 and gs.phase == gs.ESTADO_FIM)
	gs.free()
	if falhas == 0:
		print("BANCADA CANCELAMENTO OK")
	quit(1 if falhas else 0)
	return false


func _barco(id: int, valor: int, progresso: int, dias: int) -> Dictionary:
	return {"id": id, "value": valor, "classe": "pesqueiro" if dias == 1 else "medio",
		"motivo": "pescado" if dias == 1 else "conteiner", "op_turns": dias,
		"progress": progresso, "rival": false, "matched": false, "matched_value": 0, "paciencia": 2}


func _montar() -> void:
	gs._rng.seed = 420
	gs.new_game()
	gs.numero_da_fase = 2
	gs.phase = gs.ESTADO_JOGANDO
	gs.turn = 86
	gs.cash = 10000
	gs.reputation = 65.0
	gs.estruturas = ["pier_2", "trelica", "patio"]
	gs.workers.append(gs.novo_trabalhador())
	gs.workers[0]["busy_turns"] = 1
	gs.docks = [{"boat": _barco(101, 10000, 1, 2), "worker_id": 1}, {"boat": null, "worker_id": null}]
	gs.fila = []
	gs.pending_rival = -1


func _confere(nome: String, condicao: bool) -> void:
	print("PASS " if condicao else "FALHOU ", nome)
	if not condicao:
		falhas += 1
