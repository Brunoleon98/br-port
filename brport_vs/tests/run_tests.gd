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


# O porto agora ABRE com 1 doca e 1 trabalhador. Testes que precisam de mais
# passaram a pedir explicitamente, em vez de assumir a base — assim mexer em
# DOCKS_BASE não volta a partir a suíte inteira.
func _garantir(docas: int, trabalhadores: int) -> void:
	while GS.docks.size() < docas:
		GS.docks.append({"boat": null, "worker_id": null})
	while GS.workers.size() < trabalhadores:
		GS.workers.append({"id": GS.workers.size() + 1, "busy_turns": 0})
	for w in GS.workers:
		w["busy_turns"] = 0


# Caixa que compra TUDO, seja qual for a escala da economia. Substituiu o
# `GS.cash = 99999` cravado, que comprava as cinco estruturas enquanto elas
# custavam centenas de reais e deixou de comprar UMA quando a economia foi
# reescalada para valores realistas em 02/09. O teste reprovava por ter
# envelhecido, não por o jogo ter quebrado — que é o pior tipo de vermelho,
# porque ensina a suíte a ser ignorada.
func _caixa_para_tudo() -> int:
	var total: int = 0
	for eid in GS.ESTRUTURAS:
		total += int(GS.ESTRUTURAS[eid]["custo"])
	return total


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
	_garantir(2, 2)
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
	# Os valores saem por GameState.moeda(), então o esperado vem de lá também —
	# fixar "1000" aqui quebraria de novo no dia em que o formato mudasse.
	_check("botao de igualar mostra o preco",
		painel._btn_igualar.text.contains(GS.moeda(850)))
	_check("botao de cortar metade mostra a chance", painel._btn_metade.text.contains("70"))
	_check("botao de manter mostra o valor cheio",
		painel._btn_manter.text.contains(GS.moeda(1000)))

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
	_garantir(3, 2)
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
	GS.cash = int(GS.ESTRUTURAS["pier_2"]["custo"]) \
		+ int(GS.ESTRUTURAS["pier_3"]["custo"]) + 100
	var bought = GS.comprar_estrutura("pier_2")
	_check("pier 2 comprado", bought == true)
	_check("roster_changed disparou", roster_fired[0] == true)
	_check("docas subiram para 2", GS.docks.size() == 2)
	_check("trabalhadores subiram para 2", GS.workers.size() == 2)
	_check("pier 3 exige o pier 2 antes", GS.impedimento_estrutura("pier_3") == "")
	_check("pier 3 comprado", GS.comprar_estrutura("pier_3") == true)
	_check("docas subiram para 3", GS.docks.size() == 3)
	_check("trabalhadores subiram para 3", GS.workers.size() == 3)

	print("=== T5b: estruturas — pre-requisito, caixa e efeito ===")
	_fresh_playing()
	GS.cash = 0
	_check("sem caixa, o pier 2 diz quanto falta",
		GS.impedimento_estrutura("pier_2").begins_with("Faltam R$"))
	_check("e recusa a compra", GS.comprar_estrutura("pier_2") == false)
	GS.cash = _caixa_para_tudo()
	_check("pier 3 bloqueado sem o pier 2",
		GS.impedimento_estrutura("pier_3").begins_with("Precisa antes de"))
	_check("comprar duas vezes nao acontece",
		GS.comprar_estrutura("armazem") == true and GS.comprar_estrutura("armazem") == false)
	_check("estrutura ja construida diz isso",
		GS.impedimento_estrutura("armazem") == "Já construída.")
	var esperado := int(round(200 * (1.0 + GS.ARMAZEM_BONUS)))
	_garantir(1, 1)
	GS.docks[0]["boat"] = _fake_boat(200, 1, false)
	GS.docks[0]["worker_id"] = null
	GS.metrics["revenue"] = 0
	_check("trabalhador alocado para o teste do armazem",
		GS.assign_worker(1, 0) == true)
	GS.advance_turn()
	_check("armazem soma %d%% ao barco (200 -> %d)" % [
		int(GS.ARMAZEM_BONUS * 100), esperado],
		int(GS.metrics["revenue"]) == esperado)

	print("=== T5c: save de outra versao nao entra ===")
	# O bug que este teste tranca: quando o porto passou a abrir com 1 doca em
	# vez de 2, um jogo salvo antes continuou a ser carregado. O jogador ficava
	# com duas docas de graça, `estruturas` vinha vazia (a chave nem existia
	# naquela versão), o painel continuava a oferecer os píeres 2 e 3, e
	# comprá-los levava o porto a 4 docas num mapa que só desenha 3.
	GS.clear_save()
	var antigo := {
		"turn": 5, "cash": 1234, "reputation": 70.0,
		"docks": [{"boat": null, "worker_id": null}, {"boat": null, "worker_id": null}],
		"workers": [{"id": 1, "busy_turns": 0}, {"id": 2, "busy_turns": 0}],
		"upgrade_purchased": false, "parcela_paid": false, "phase": "playing",
		"pending_rival_dock": -1, "uid": 9,
	}
	var f := FileAccess.open(GS.SAVE_PATH, FileAccess.WRITE)
	f.store_string(JSON.stringify(antigo))
	f.close()
	_check("save sem versao e recusado  <-- o bug do pier duplicado",
		GS.load_game() == false)
	_check("e apagado, para nao ser tentado de novo",
		not FileAccess.file_exists(GS.SAVE_PATH))

	# O save da versao corrente volta inteiro.
	_fresh_playing()
	GS.cash = 4321
	GS.save_game()
	GS.cash = 0
	_check("save da versao corrente carrega", GS.load_game() == true)
	_check("e traz o caixa de volta", GS.cash == 4321)

	print("=== T5d: docas nunca passam do que o mapa desenha ===")
	_fresh_playing()
	# O CAIXA SAI DO PREÇO, e não de um número cravado. Este teste dizia
	# `GS.cash = 99999`, que cobria os dois píeres enquanto eles custavam R$900
	# e R$1.600; quando a economia foi reescalada em 02/09 para valores
	# realistas, 99.999 deixou de comprar o primeiro — e o teste reprovou por
	# ter envelhecido, não por o jogo ter quebrado. Somar os custos reais faz a
	# asserção sobreviver a qualquer escala futura.
	GS.cash = _caixa_para_tudo()
	GS.comprar_estrutura("pier_2")
	GS.comprar_estrutura("pier_3")
	_check("os dois pieres dao exatamente %d docas" % GS.BERCOS_NO_MAPA,
		GS.docks.size() == GS.BERCOS_NO_MAPA)
	# Trabalhador sem doca é o "#4 fantasma" do playtest: um cartão na fileira
	# que não tem onde trabalhar. O teto do mapa tem de segurar os dois juntos.
	_check("e nunca mais trabalhador do que doca",
		GS.workers.size() == GS.docks.size())
	# Forca o estado impossivel e confere que carregar o conserta.
	GS.docks.append({"boat": null, "worker_id": null})
	GS.workers.append({"id": 99, "busy_turns": 0})
	GS.docks[GS.docks.size() - 1]["worker_id"] = 99
	GS.save_game()
	_check("save com doca a mais carrega", GS.load_game() == true)
	_check("e a doca invisivel foi cortada", GS.docks.size() == GS.BERCOS_NO_MAPA)
	_check("junto com o trabalhador que so ela tinha",
		GS.workers.size() == GS.trabalhadores_esperados())

	print("=== T5e: dinheiro sai com separador de milhar ===")
	_check("R$8.000", GS.moeda(8000) == "R$8.000")
	_check("R$54 sem ponto nenhum", GS.moeda(54) == "R$54")
	_check("R$1.234.567", GS.moeda(1234567) == "R$1.234.567")
	_check("negativo mantem o sinal na frente", GS.moeda(-2500) == "-R$2.500")

	print("=== T5f: a reputacao MEXE na contra-oferta (A3) ===")
	# A reputacao foi rotulo na HUD ate 01/09. Agora ela decide, e por isso
	# passa a ter teste: uma constante mexida sem querer voltaria a torna-la
	# cosmetica em silencio, que e exatamente o estado de que se acabou de sair.
	_fresh_playing()
	var base_chance: float = GS.RIVAL_KEEP_CHANCE
	GS.reputation = GS.REPUTATION_START
	var neutra: float = GS._chance_com_reputacao(base_chance)
	_check("na reputacao inicial o efeito e NEUTRO", is_equal_approx(neutra, base_chance))

	GS.reputation = 100.0
	var alta: float = GS._chance_com_reputacao(base_chance)
	GS.reputation = 0.0
	var baixa: float = GS._chance_com_reputacao(base_chance)
	_check("reputacao alta ajuda", alta > base_chance)
	_check("reputacao baixa atrapalha", baixa < base_chance)
	_check("a ordem e monotona", baixa < neutra and neutra < alta)

	# Segurar o preco nunca pode virar jogada automatica: com reputacao maxima
	# a aposta fica boa, nao fica garantida. Sem este teto, uma constante de
	# efeito generosa transformaria "manter" na unica escolha racional e
	# mataria a decisao que a contra-oferta existe para criar.
	GS.reputation = 100.0
	_check("com reputacao maxima a aposta nao vira certeza",
		GS._chance_com_reputacao(0.95) <= 0.95)
	_check("nunca passa de 1", GS._chance_com_reputacao(1.0) <= 1.0)

	# Igualar fecha SEMPRE, com reputacao no chao — e o recuo de emergencia do
	# jogador, e a reputacao nao pode tirar-lho.
	_fresh_playing()
	_garantir(1, 1)
	GS.docks[0]["boat"] = _fake_boat(200, 1, true)
	GS.pending_rival_dock = 0
	GS.rival_attempts_left = GS.RIVAL_PATIENCE
	GS._set_phase("rival_offer")
	GS.reputation = 0.0
	_check("igualar fecha mesmo com reputacao zero",
		GS.negotiate_rival("igualar") == "fechado")

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
				if not bought_up and GS.cash >= int(GS.ESTRUTURAS["pier_2"]["custo"]):
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
