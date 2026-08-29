extends SceneTree

# Harness de QA temporário — NÃO faz parte do jogo. Apagado antes do commit.
# Diferente das rodadas anteriores, este instancia a CENA REAL e inspeciona o
# botão "AVANÇAR DIA", que é onde o bug reportado se manifestava.

var _fails := 0
var GS


func _check(label: String, ok: bool) -> void:
	if ok:
		print("  PASS  %s" % label)
	else:
		print("  FAIL  %s" % label)
		_fails += 1


# new_game() já sorteia barcos e pode abrir uma oferta do rival (30%); nesse
# estado assign_worker/buy_upgrade recusam de propósito. Os testes que não são
# sobre o rival precisam começar de uma partida em "playing".
func _fresh_playing() -> void:
	GS.new_game()
	if GS.phase == "rival_offer":
		GS.resolve_rival_offer(true)


func _fake_boat(value: int, op_turns: int, rival: bool) -> Dictionary:
	return {
		"id": 999, "value": value, "op_turns": op_turns, "large": op_turns > 1,
		"progress": 0, "rival": rival, "matched": false, "matched_value": 0,
	}


var _done := false


# Os testes rodam no primeiro frame, não em _initialize(): dentro de
# _initialize() a árvore ainda não está ativa e o _ready() das cenas
# instanciadas não dispara (o botão sai como null).
func _process(_delta: float) -> bool:
	if _done:
		return true
	_done = true
	_run()
	return true


func _run() -> void:
	GS = root.get_node("GameState")
	GS.clear_save()

	print("=== T1/T2: travamento depois da oferta do rival (cena real) ===")
	for accept in [true, false]:
		GS.new_game()
		var main = load("res://scenes/Main.tscn").instantiate()
		root.add_child(main)

		# Monta uma oferta de rival na doca 0.
		GS.docks[0]["boat"] = _fake_boat(300, 1, true)
		GS.docks[0]["worker_id"] = null
		GS.pending_rival_dock = 0
		GS._set_phase("rival_offer")

		var btn = main._advance_button
		_check("[%s] botao desabilitado durante a oferta" % ("igualar" if accept else "recusar"), btn.disabled == true)

		GS.resolve_rival_offer(accept)

		_check("[%s] fase voltou para playing" % ("igualar" if accept else "recusar"), GS.phase == "playing")
		_check("[%s] botao AVANCAR DIA reabilitado  <-- o bug reportado" % ("igualar" if accept else "recusar"), btn.disabled == false)

		root.remove_child(main)
		main.free()

	print("=== T3: mesmo trabalhador em duas docas ===")
	_fresh_playing()
	GS.docks[0]["boat"] = _fake_boat(200, 1, false)
	GS.docks[1]["boat"] = _fake_boat(200, 1, false)
	GS.docks[0]["worker_id"] = null
	GS.docks[1]["worker_id"] = null
	var first = GS.assign_worker(1, 0)
	var second = GS.assign_worker(1, 1)
	_check("primeira alocacao aceita", first == true)
	_check("segunda alocacao do MESMO trabalhador recusada", second == false)
	_check("doca 1 continua sem trabalhador", GS.docks[1]["worker_id"] == null)
	_check("worker_dock_index aponta a doca 0", GS.worker_dock_index(1) == 0)

	print("=== T4: liberar trabalhador ===")
	var released = GS.release_worker(0)
	_check("release_worker devolveu o trabalhador", released == true and GS.docks[0]["worker_id"] == null)
	_check("da para realocar depois de liberar", GS.assign_worker(1, 1) == true)
	# Com a operacao em andamento nao pode liberar.
	GS.docks[1]["boat"]["progress"] = 1
	_check("recusa liberar com operacao em andamento", GS.release_worker(1) == false)

	print("=== T4b: contra-oferta com os 3 presets do GDD ===")
	# Igualar fecha na hora, sem gastar paciência.
	_fresh_playing()
	GS.docks[0]["boat"] = _fake_boat(1000, 1, true)
	GS.pending_rival_dock = 0
	GS.rival_attempts_left = GS.RIVAL_PATIENCE
	GS._set_phase("rival_offer")
	_check("igualar devolve 'fechado'", GS.negotiate_rival("igualar") == "fechado")
	_check("igualar cobra os 15% do GDD", int(GS.docks[0]["boat"]["matched_value"]) == 850)
	_check("fase voltou para playing", GS.phase == "playing")

	# Manter preço: com o sorteio forçado a favor, fecha pelo valor CHEIO.
	# É exatamente o que não existia antes — o botão era perda garantida.
	_fresh_playing()
	GS.docks[0]["boat"] = _fake_boat(1000, 1, true)
	GS.pending_rival_dock = 0
	GS.rival_attempts_left = GS.RIVAL_PATIENCE
	GS._set_phase("rival_offer")
	GS._rng.seed = 1
	var sucesso := false
	for tentativa in range(400):
		GS.rival_attempts_left = GS.RIVAL_PATIENCE
		GS.docks[0]["boat"] = _fake_boat(1000, 1, true)
		GS.pending_rival_dock = 0
		GS._set_phase("rival_offer")
		if GS.negotiate_rival("manter") == "fechado":
			sucesso = true
			break
	_check("manter preco PODE dar certo  <-- era impossivel antes", sucesso)
	_check("quando da certo, paga o valor cheio", not sucesso or int(GS.docks[0]["boat"]["matched_value"]) == 1000)

	# Paciência: duas insistências seguidas perdem o cliente.
	_fresh_playing()
	GS.docks[0]["boat"] = _fake_boat(1000, 1, true)
	GS.pending_rival_dock = 0
	GS.rival_attempts_left = 1
	GS._set_phase("rival_offer")
	GS._rng.seed = 7
	var perdeu := false
	for tentativa2 in range(400):
		GS.rival_attempts_left = 1
		GS.docks[0]["boat"] = _fake_boat(1000, 1, true)
		GS.pending_rival_dock = 0
		GS._set_phase("rival_offer")
		if GS.negotiate_rival("manter") == "perdido":
			perdeu = true
			break
	_check("sem paciencia o cliente vai embora", perdeu)
	_check("doca fica vazia quando o cliente vai", GS.docks[0]["boat"] == null)
	_check("fase volta para playing mesmo perdendo", GS.phase == "playing")

	# Insistir e falhar encarece o igualar — é o que impede a aposta grátis.
	_fresh_playing()
	GS.docks[0]["boat"] = _fake_boat(1000, 1, true)
	GS.pending_rival_dock = 0
	GS.rival_attempts_left = GS.RIVAL_PATIENCE - 1   # já insistiu uma vez
	GS._set_phase("rival_offer")
	GS.negotiate_rival("igualar")
	_check("igualar depois de insistir custa mais (28 por cento)", int(GS.docks[0]["boat"]["matched_value"]) == 720)

	print("=== T4c: painel da contra-oferta (cena real) ===")
	# A lição do playtest anterior: testar só a lógica não pega bug de tela.
	# Aqui o painel é instanciado de verdade e os botões são inspecionados.
	_fresh_playing()
	var main2 = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main2)
	GS.docks[0]["boat"] = _fake_boat(1000, 1, true)
	GS.pending_rival_dock = 0
	GS.rival_attempts_left = GS.RIVAL_PATIENCE
	GS._set_phase("rival_offer")

	var painel = load("res://scenes/panels/CounterOfferPanel.tscn").instantiate()
	root.add_child(painel)
	painel.setup(0)
	_check("painel tem os 3 presets do GDD", painel._btn_igualar != null and painel._btn_metade != null and painel._btn_manter != null)
	_check("botao de igualar mostra o preco", painel._btn_igualar.text.contains("850"))
	_check("botao de cortar metade mostra a chance", painel._btn_metade.text.contains("70"))
	_check("botao de manter mostra o valor cheio", painel._btn_manter.text.contains("1000"))

	painel._negociar("igualar")
	_check("negociar pelo painel devolve o jogo para playing", GS.phase == "playing")
	_check("botao AVANCAR DIA reabilitado depois do painel", main2._advance_button.disabled == false)

	root.remove_child(main2)
	main2.free()

	print("=== T4d: alocar em lote e por toque ===")
	_fresh_playing()
	# Cenário controlado: 3 docas com barco, e menos trabalhador que doca —
	# é onde a ORDEM importa. Se o lote não servir o mais caro primeiro, o
	# botão estaria jogando pior do que um humano atento.
	while GS.docks.size() < 3:
		GS.docks.append({"boat": null, "worker_id": null})
	while GS.workers.size() > 2:
		GS.workers.pop_back()
	for i in range(3):
		GS.docks[i]["boat"] = _fake_boat(100 + i * 100, 1, false)
		GS.docks[i]["worker_id"] = null
	for w in GS.workers:
		w["busy_turns"] = 0

	_check("ha alocacao pendente antes", GS.has_pending_assignment() == true)
	var postos: int = GS.assign_all_free_workers()
	_check("alocou os 2 trabalhadores livres", postos == 2)
	_check("serviu primeiro a doca de R$300", GS.docks[2]["worker_id"] != null)
	_check("serviu depois a doca de R$200", GS.docks[1]["worker_id"] != null)
	_check("deixou de fora a doca mais barata", GS.docks[0]["worker_id"] == null)
	_check("nao ha mais alocacao pendente", GS.has_pending_assignment() == false)
	_check("rodar de novo nao aloca nada", GS.assign_all_free_workers() == 0)

	# Uma doca sob oferta do rival nao pode ser preenchida pelo lote.
	_fresh_playing()
	for i in range(GS.docks.size()):
		GS.docks[i]["boat"] = null
		GS.docks[i]["worker_id"] = null
	for w in GS.workers:
		w["busy_turns"] = 0
	GS.docks[0]["boat"] = _fake_boat(300, 1, true)
	_check("doca sob oferta do rival nao conta como pendente",
		GS.has_pending_assignment() == false)
	_check("lote nao aloca em doca sob oferta", GS.assign_all_free_workers() == 0)

	print("=== T5: upgrade avisa a UI ===")
	_fresh_playing()
	var roster_fired := [false]
	GS.roster_changed.connect(func(): roster_fired[0] = true)
	GS.cash = GS.UPGRADE_COST + 100
	var bought = GS.buy_upgrade()
	_check("upgrade comprado", bought == true)
	_check("roster_changed disparou", roster_fired[0] == true)
	_check("docas subiram para 3", GS.docks.size() == 3)
	_check("trabalhadores subiram para 3", GS.workers.size() == 3)

	print("=== T6: regressao — partidas completas ===")
	var wins := 0
	var losses := 0
	for run in range(40):
		GS.clear_save()
		GS.new_game()
		var bought_up := false
		var safety := 0
		while GS.phase != "game_over" and safety < 300:
			safety += 1
			if GS.phase == "rival_offer":
				GS.resolve_rival_offer(true)
				continue
			if GS.phase == "debt_payment":
				if GS.cash >= GS.PARCELA_AMOUNT:
					GS.pay_debt()
				else:
					GS.fail_debt()
				continue
			if GS.phase == "playing":
				if not bought_up and GS.cash >= GS.UPGRADE_COST:
					GS.buy_upgrade()
					bought_up = true
				for w in GS.workers:
					if int(w["busy_turns"]) > 0 or GS.worker_dock_index(int(w["id"])) >= 0:
						continue
					for i in range(GS.docks.size()):
						var d = GS.docks[i]
						if d["boat"] != null and d["worker_id"] == null:
							var b = d["boat"]
							if b.get("rival", false) and not b.get("matched", false):
								continue
							if GS.assign_worker(int(w["id"]), i):
								break
				GS.advance_turn()
		if safety >= 300:
			_check("partida %d terminou (sem loop infinito)" % run, false)
		if GS.won:
			wins += 1
		else:
			losses += 1
	_check("40 partidas completadas sem travar", wins + losses == 40)
	print("  -> vitorias=%d derrotas=%d" % [wins, losses])

	print("")
	if _fails == 0:
		print("=== TODOS OS TESTES PASSARAM ===")
	else:
		print("=== %d TESTE(S) FALHARAM ===" % _fails)
	quit(_fails)
