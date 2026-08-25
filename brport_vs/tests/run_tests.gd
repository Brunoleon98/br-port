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
