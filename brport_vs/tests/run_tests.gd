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


# O motivo é o ÚLTIMO argumento e nasce em "pescado" de propósito: é o único
# que não tem estrutura por trás, então um barco de teste feito por aqui paga
# exatamente o que diz e nenhum bloco antigo passou a ganhar bónus escondido
# quando o motivo entrou (06/09). A classe segue o mesmo princípio: "pesqueiro"
# é a de nível 1, a única que chega a um porto em ruínas.
func _fake_boat(value: int, op_turns: int, rival: bool,
		motivo: String = "pescado", classe: String = "pesqueiro") -> Dictionary:
	return {
		"id": 999, "value": value, "motivo": motivo, "classe": classe,
		"op_turns": op_turns,
		"progress": 0, "rival": rival, "matched": false, "matched_value": 0,
	}


var _done := false
var _t5g_completo := false
var _t5h_completo := false
var _t5i_completo := false
var _t5j_completo := false
var _t5k_completo := false
var _t5l_completo := false


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
	# ⚠️ SÃO DOIS BARCOS, E TÊM DE SER. Desde 06/09 o armazém não paga em tudo:
	# paga no barco que vem DEIXAR CARGA e em mais nenhum. Com um barco só, um
	# defeito que devolvesse o bónus global passaria — é a mesma armadilha de
	# "contagem só se testa acima de um", com um motivo no lugar da contagem.
	var esperado := int(round(200 * (1.0 + GS.ARMAZEM_BONUS)))
	_garantir(1, 1)
	GS.docks[0]["boat"] = _fake_boat(200, 1, false, "armazenagem")
	GS.docks[0]["worker_id"] = null
	GS.metrics["revenue"] = 0
	_check("trabalhador alocado para o teste do armazem",
		GS.assign_worker(1, 0) == true)
	GS.advance_turn()
	_check("armazem soma %d%% ao barco de armazenagem (200 -> %d)" % [
		int(GS.ARMAZEM_BONUS * 100), esperado],
		int(GS.metrics["revenue"]) == esperado)

	GS.docks[0]["boat"] = _fake_boat(200, 1, false, "pescado")
	GS.docks[0]["worker_id"] = null
	GS.metrics["revenue"] = 0
	_check("trabalhador alocado para o teste do pescado",
		GS.assign_worker(1, 0) == true)
	GS.advance_turn()
	_check("e nao soma nada ao pescado (200 -> %d)" % int(GS.metrics["revenue"]),
		int(GS.metrics["revenue"]) == 200)

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

	print("=== T5g: o Voltar do Android fecha o painel, nao o jogo ===")
	_t5g_botao_voltar()
	# UM ERRO DE EXECUÇÃO ABORTA A FUNÇÃO E A SUÍTE PASSA NA MESMA — aconteceu
	# ao escrever este bloco: uma chamada com o número errado de argumentos
	# matou o T5g inteiro e a suíte imprimiu "TODOS OS TESTES PASSARAM" com as
	# sete asserções por correr. A bandeira é posta na ÚLTIMA linha do bloco,
	# então só fica verdadeira se ele chegou ao fim.
	_check("o bloco T5g correu até ao fim", _t5g_completo)

	print("=== T5h: trabalho parado — os dois numeros saem da mesma varredura ===")
	_t5h_trabalho_parado()
	_check("o bloco T5h correu até ao fim", _t5h_completo)

	print("=== T5i: resumo do dia — o que ja aconteceu e o que a projecao promete ===")
	_t5i_resumo_do_dia()
	_check("o bloco T5i correu até ao fim", _t5i_completo)

	print("=== T5j: calendario — so os tres eventos que se sabem de antemao ===")
	_t5j_calendario()
	_check("o bloco T5j correu até ao fim", _t5j_completo)

	print("=== T5k: quitar a parcela antes do prazo ===")
	_t5k_parcela_adiantada()
	_check("o bloco T5k correu até ao fim", _t5k_completo)

	print("=== T5l: o motivo da escala ===")
	_t5l_motivo_da_escala()
	_check("o bloco T5l correu até ao fim", _t5l_completo)

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


# ── T5g ──────────────────────────────────────────────────────────────────
# O BOTÃO VOLTAR SÓ EXISTE NO TELEFONE, e por isso viveu cinco blocos sem
# ninguém lhe tocar: por omissão o Godot fecha a APLICAÇÃO nele. Com o boletim
# da semana aberto, um toque em Voltar matava o jogo.
#
# Testa-se por notificação e não por evento de entrada de propósito: é assim
# que o Godot entrega o Voltar (NOTIFICATION_WM_GO_BACK_REQUEST), e um teste
# que simulasse um toque estaria a testar outra coisa.
func _t5g_botao_voltar() -> void:
	_fresh_playing()
	var main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)
	var camada: CanvasLayer = main.get_node("Overlay")

	# 1. Painel dispensável, em "playing": fecha.
	var boletim = load("res://scenes/panels/PainelBoletim.tscn").instantiate()
	camada.add_child(boletim)
	boletim.setup(GS.resumo_da_semana(1))
	main.notification(main.NOTIFICATION_WM_GO_BACK_REQUEST)
	# O `_fechar()` chama `queue_free()`, que só age no fim do frame — quem
	# pergunta antes disso vê o nó ainda lá. `is_queued_for_deletion()` é a
	# pergunta certa, e é a diferença entre este teste medir alguma coisa e
	# passar sempre.
	_check("Voltar fecha o boletim", boletim.is_queued_for_deletion())

	# 2. A tela dos nomes RECUSA: fechá-la batiza o cais, e isso não se faz
	#    por engano. É o caso que justifica a bandeira existir.
	var nomes = load("res://scenes/panels/TelaNomes.tscn").instantiate()
	camada.add_child(nomes)
	main.notification(main.NOTIFICATION_WM_GO_BACK_REQUEST)
	_check("Voltar NAO fecha a tela dos nomes", not nomes.is_queued_for_deletion())
	camada.remove_child(nomes)
	nomes.free()

	# 3. Decisão pendente: o painel fica. Fechá-lo deixaria a fase de pé sem
	#    nada na tela para a resolver — travamento silencioso.
	GS.docks[0]["boat"] = _fake_boat(1000, 1, true)
	GS.pending_rival_dock = 0
	GS.rival_attempts_left = GS.RIVAL_PATIENCE
	GS._set_phase("rival_offer")
	var oferta = load("res://scenes/panels/CounterOfferPanel.tscn").instantiate()
	camada.add_child(oferta)
	oferta.setup(0)
	main.notification(main.NOTIFICATION_WM_GO_BACK_REQUEST)
	_check("Voltar NAO fecha a oferta do rival", not oferta.is_queued_for_deletion())
	_check("e nao muda a fase", GS.phase == "rival_offer")
	GS.resolve_rival_offer(true)

	# 4. Sem painel nenhum: abre a pausa, em vez de fechar o jogo.
	for filho in camada.get_children():
		camada.remove_child(filho)
		filho.free()
	main.notification(main.NOTIFICATION_WM_GO_BACK_REQUEST)
	_check("Voltar sem painel abre a pausa (e nao fecha o jogo)",
		camada.get_child_count() == 1)

	root.remove_child(main)
	main.free()

	# E a definição que faz tudo isto valer: com `quit_on_go_back` ligado, o
	# Godot fecha a aplicação ANTES de o `_notification` acima correr, e os
	# quatro casos de cima passariam a testar código morto.
	_check("quit_on_go_back esta desligado",
		ProjectSettings.get_setting("application/config/quit_on_go_back") == false)

	_t5g_completo = true


# ── T5h ──────────────────────────────────────────────────────────────────
#
# `trabalho_parado()` é o que a interface inteira lê para decidir se avisa: o
# rótulo conta, o cartão do trabalhador muda de cor e o botão de alocar acende.
# Três leituras do mesmo estado, uma varredura só — e é isto que testa que ela
# conta certo, inclusive nos dois casos em que NÃO há nada a avisar.
#
# A semente é fixada porque este bloco JOGA: o `new_game()` chama
# `_spawn_boats()`, que tem 30% de abrir contra-oferta, e nessa fase
# `trabalho_parado()` devolve zero por construção.
func _t5h_trabalho_parado() -> void:
	GS._rng.seed = 20260903
	GS.clear_save()
	GS.new_game()
	if GS.phase == "rival_offer":
		GS.resolve_rival_offer(true)

	# Um porto com barco na doca e ninguém alocado: é o estado exato que o
	# playtest fotografou.
	#
	# ⚠️ TRÊS TRABALHADORES E DUAS DOCAS, e não os que o porto abre. O porto
	# começa com UM trabalhador e uma doca, e com esses números um contador
	# que parasse no primeiro livre daria a mesma resposta que um que contasse
	# todos — foi assim que a primeira versão deste bloco passou com o defeito
	# injetado dentro. Contagem só se testa acima de um.
	while GS.workers.size() < 3:
		GS.workers.append({"id": GS.workers.size() + 1, "busy_turns": 0})
	while GS.docks.size() < 2:
		GS.docks.append({"boat": null, "worker_id": null, "turns_done": 0})
	for i in range(GS.docks.size()):
		GS.docks[i]["worker_id"] = null
		GS.docks[i]["boat"] = GS._make_boat()
		GS.docks[i]["boat"]["rival"] = false
	for w in GS.workers:
		w["busy_turns"] = 0

	var esperando := 0
	for i in range(GS.docks.size()):
		if GS.doca_aceita_trabalhador(i):
			esperando += 1
	var parado: Vector2i = GS.trabalho_parado()
	_check("conta todos os trabalhadores parados, e nao só o primeiro",
		parado.x == GS.workers.size() and parado.x >= 3)
	_check("conta todas as docas à espera", parado.y == esperando and parado.y >= 2)
	_check("has_pending_assignment concorda com a contagem",
		GS.has_pending_assignment() == (parado != Vector2i.ZERO))

	# Doca à espera mas ninguém livre: não há nada que o jogador possa fazer,
	# e avisar seria pedir uma ação que não existe.
	for w in GS.workers:
		w["busy_turns"] = 2
	_check("trabalhador nenhum livre => nao ha trabalho parado",
		GS.trabalho_parado() == Vector2i.ZERO)

	# E o simétrico: gente livre, doca nenhuma à espera.
	for w in GS.workers:
		w["busy_turns"] = 0
	for i in range(GS.docks.size()):
		GS.docks[i]["boat"] = null
	_check("doca nenhuma à espera => nao ha trabalho parado",
		GS.trabalho_parado() == Vector2i.ZERO)

	# Fora de "playing" o turno está bloqueado por um painel; o aviso ali seria
	# ruído por cima de uma decisão que o jogador ainda não tomou.
	GS.docks[0]["boat"] = GS._make_boat()
	GS.docks[0]["boat"]["rival"] = false
	GS._set_phase("debt_payment")
	_check("fora de playing nao ha trabalho parado",
		GS.trabalho_parado() == Vector2i.ZERO)
	GS._set_phase("playing")

	_t5h_completo = true


# ── T5i ──────────────────────────────────────────────────────────────────
#
# `resumo_do_dia()` é o que o toque no dinheiro do HUD lê (item do primeiro
# playtest: "ontem e o projetado para hoje"). Duas contas, duas naturezas —
# "ontem" é histórico (`dia_anterior`, só se lê), "hoje" é uma SIMULAÇÃO de
# `advance_turn()` que não pode mexer em nada. Este bloco confere as duas.
func _t5i_resumo_do_dia() -> void:
	GS._rng.seed = 20260903
	GS.clear_save()
	GS.new_game()
	if GS.phase == "rival_offer":
		GS.resolve_rival_offer(true)

	# Antes de qualquer dia fechar, "ontem" não tem turno nenhum — é o
	# sentinela que o painel lê para dizer "o primeiro dia ainda não fechou"
	# em vez de uma fileira de zeros que pareceria um dia real sem receita.
	_check("antes do primeiro dia, 'ontem' nao tem turno",
		int(GS.dia_anterior["turno"]) == 0)

	# Um barco que completa NESTE turno tem de aparecer na projeção de hoje
	# ANTES de avançar, e em "ontem" DEPOIS — a mesma soma, só que movida.
	if GS.docks[0]["boat"] == null:
		GS.docks[0]["boat"] = GS._make_boat()
	var barco: Dictionary = GS.docks[0]["boat"]
	barco["rival"] = false
	barco["matched"] = false
	barco["op_turns"] = 1
	barco["progress"] = 0
	barco["value"] = 10000
	GS.docks[0]["worker_id"] = int(GS.workers[0]["id"])
	GS.workers[0]["busy_turns"] = 0

	var bruto := 10000
	# `_lancar_receita()` escreve num dicionário de contabilidade e devolve o
	# total. Passar-lhe uma CÓPIA de `DIA_ZERADO` é como se pergunta quanto um
	# barco pagaria sem mexer em nada do jogo.
	var esperado: int = GS._lancar_receita(
		GS.DIA_ZERADO.duplicate(), bruto, String(barco["motivo"]))
	var proj: Dictionary = GS.projecao_do_dia()
	_check("a projecao ve o barco que completaria hoje (servidos=%d receita=%d esperado=%d)"
			% [int(proj["servidos"]), int(proj["docagens"]) + int(proj["armazem"]) + int(proj["patio"]), esperado],
		int(proj["servidos"]) == 1 and int(proj["docagens"]) + int(proj["armazem"]) + int(proj["patio"]) == esperado)
	# E NÃO MEXEU EM NADA — a doca continua com o barco, e o caixa não mudou.
	var caixa_antes: int = GS.cash
	_check("a projecao nao mexeu na doca", GS.docks[0]["boat"] != null)
	_check("a projecao nao mexeu no caixa", GS.cash == caixa_antes)

	GS.advance_turn()
	var resumo: Dictionary = GS.resumo_do_dia()
	var ontem: Dictionary = resumo["ontem"]
	_check("depois de avançar, 'ontem' tem o que a projecao prometeu (servidos=%d receita=%d)"
			% [int(ontem["servidos"]), int(ontem["docagens"]) + int(ontem["armazem"]) + int(ontem["patio"])],
		int(ontem["servidos"]) == 1 and int(ontem["docagens"]) + int(ontem["armazem"]) + int(ontem["patio"]) == esperado)
	# E o TURNO tem de ser o dia que fechou, e não o sentinela zero — sem isto
	# o painel leria "o primeiro dia ainda não fechou" para sempre, mesmo com
	# receita e barcos servidos dentro do dicionário.
	_check("e 'ontem' leva o numero do dia que fechou (turno=%d)" % int(ontem["turno"]),
		int(ontem["turno"]) == 1)
	_check("e 'hoje' zerou — o dia novo ainda não jogou nada",
		int(GS.dia_atual["servidos"]) == 0 and int(GS.dia_atual["docagens"]) == 0)

	# Barco sem trabalhador conta como PERDIDO na projeção, e não como servido.
	# ⚠️ O porto abre com UMA doca só — a mesma armadilha do T5h. Sem esta
	# doca extra, `GS.docks[1]` estoura o array.
	if GS.docks.size() < 2:
		GS.docks.append({"boat": null, "worker_id": null, "turns_done": 0})
	GS.docks[1]["boat"] = GS._make_boat()
	GS.docks[1]["boat"]["rival"] = false
	GS.docks[1]["worker_id"] = null
	var proj2: Dictionary = GS.projecao_do_dia()
	_check("barco sem trabalhador conta como perdido na projecao",
		int(proj2["perdidos"]) >= 1)
	GS.docks[1]["boat"] = null

	# No dia que fecha semana, a projeção tem de mostrar píer/salários/
	# manutenção — e com o MESMO número que `_custos_da_semana()` daria ao
	# fechar de verdade. As duas leituras vêm da mesma função de propósito
	# (ver o comentário dela); este teste é o que prova que continuam iguais.
	#
	# ⚠️ COM O PÁTIO E O ESCRITÓRIO CONSTRUÍDOS, e não num porto em ruínas —
	# sem os dois bónus, uma cópia da fórmula que esquecesse o bónus do pátio
	# ou o desconto do escritório bateria com a certa por acidente, porque as
	# duas dariam o valor-base. É a mesma lição do T5h sobre contar acima de
	# um: só um modificador ATIVO expõe a fórmula duplicada.
	if not GS.tem_estrutura("patio"):
		GS.estruturas.append("patio")
	if not GS.tem_estrutura("escritorio"):
		GS.estruturas.append("escritorio")
	GS.turn = GS.TURNS_PER_WEEK
	var custos: Dictionary = GS._custos_da_semana()
	var proj3: Dictionary = GS.projecao_do_dia()
	_check("dia de fechar semana projeta pier/salarios/manutencao",
		int(proj3["pier"]) == int(custos["pier"])
			and int(proj3["salarios"]) == int(custos["salarios"])
			and int(proj3["manutencao"]) == int(custos["manutencao"]))

	# E no dia em que a parcela vence, e só nesse dia.
	GS.turn = GS.PARCELA_DUE_TURN
	GS.parcela_paid = false
	var proj4: Dictionary = GS.projecao_do_dia()
	_check("dia da parcela projeta o valor dela",
		int(proj4["parcela"]) == int(GS.PARCELA_AMOUNT))
	GS.parcela_paid = true
	var proj5: Dictionary = GS.projecao_do_dia()
	_check("parcela ja paga nao projeta de novo", int(proj5["parcela"]) == 0)

	_t5i_completo = true


# ── T5j ──────────────────────────────────────────────────────────────────
#
# `calendario()` é o que o painel do mesmo nome desenha (toque no chip "Dia").
# Confere as três contas que ele tem de acertar: quantos dias (nem um a mais
# nem a menos que TURNS_TOTAL), qual é hoje, e em que dias caem os dois
# eventos que o jogo já sabe de antemão — fecho de semana e vencimento da
# parcela. Oferta do rival não entra: é sorteada por barco, não por dia.
func _t5j_calendario() -> void:
	_fresh_playing()
	GS.turn = 10

	var dias: Array = GS.calendario()
	_check("um dia por turno da partida, nem mais nem menos",
		dias.size() == GS.TURNS_TOTAL)

	var vistos_hoje := 0
	var fecham_semana := 0
	var vencem_parcela := 0
	for dia in dias:
		if bool(dia["hoje"]):
			vistos_hoje += 1
			_check("o dia de hoje é o turno atual (%d)" % int(dia["turno"]),
				int(dia["turno"]) == GS.turn)
		_check("'passado' concorda com o turno atual (dia %d)" % int(dia["turno"]),
			bool(dia["passado"]) == (int(dia["turno"]) < GS.turn))
		if bool(dia["fecha_semana"]):
			fecham_semana += 1
			_check("todo dia de fechar semana é multiplo de TURNS_PER_WEEK (dia %d)"
					% int(dia["turno"]),
				int(dia["turno"]) % GS.TURNS_PER_WEEK == 0)
		if bool(dia["parcela_vence"]):
			vencem_parcela += 1
			_check("a parcela vence no dia certo (dia %d, esperado %d)"
					% [int(dia["turno"]), GS.PARCELA_DUE_TURN],
				int(dia["turno"]) == GS.PARCELA_DUE_TURN)

	_check("exatamente um dia é 'hoje'", vistos_hoje == 1)
	_check("um fecho de semana por semana (%d, esperado %d)"
			% [fecham_semana, GS.WEEKS_TOTAL],
		fecham_semana == GS.TURNS_TOTAL / GS.TURNS_PER_WEEK)
	_check("a parcela vence uma vez só", vencem_parcela == 1)

	_t5j_completo = true


# ── T5k ──────────────────────────────────────────────────────────────────
#
# A segunda porta da dívida: pagar antes do vencimento, item do playtest que
# a triagem tinha perdido. As duas portas baixam a MESMA parcela pela mesma
# função (`_baixar_parcela`), e é isso que este bloco tranca — mais as três
# recusas que a porta nova tem de fazer.
func _t5k_parcela_adiantada() -> void:
	_fresh_playing()

	# 1. Sem caixa, a porta está fechada — e não tira dinheiro nenhum.
	GS.cash = GS.PARCELA_AMOUNT - 1
	_check("sem caixa para a parcela, nao da para quitar",
		not GS.pode_pagar_parcela_adiantado())
	var caixa_antes: int = GS.cash
	_check("e a tentativa recusada nao mexe no caixa",
		not GS.pagar_parcela_adiantado() and GS.cash == caixa_antes)

	# 2. Com caixa, quita — e o dinheiro sai exatamente uma vez.
	GS.cash = GS.PARCELA_AMOUNT + 1000
	_check("com caixa, a porta abre", GS.pode_pagar_parcela_adiantado())
	var antes: int = GS.cash
	_check("quitar devolve verdadeiro", GS.pagar_parcela_adiantado())
	_check("saiu exatamente a parcela do caixa (%d, esperado %d)"
			% [antes - int(GS.cash), GS.PARCELA_AMOUNT],
		antes - int(GS.cash) == GS.PARCELA_AMOUNT)
	_check("a parcela ficou marcada como paga", bool(GS.parcela_paid))

	# 3. Já paga, a porta fecha — quitar duas vezes cobraria duas vezes.
	#
	# ⚠️ COM CAIXA DE SOBRA, e não com o que ficou. Quitar deixa o caixa
	# abaixo da parcela, e aí a porta fecharia pela guarda do DINHEIRO — um
	# defeito injetado na guarda do "já paga" passava incólume, satisfeito
	# pela guarda vizinha. Só com caixa suficiente a asserção mede o que diz
	# medir. É a irmã de "contagem só se testa acima de um".
	GS.cash = GS.PARCELA_AMOUNT * 2
	var depois: int = GS.cash
	_check("parcela ja paga fecha a porta", not GS.pode_pagar_parcela_adiantado())
	_check("e a segunda tentativa nao cobra de novo",
		not GS.pagar_parcela_adiantado() and GS.cash == depois)

	# 4. O resumo do dia mostra a parcela no dia EM CURSO (o inverso do
	#    `pay_debt()`, que a lança no dia que acabou de fechar).
	_check("a parcela adiantada entra no dia em curso",
		int(GS.dia_atual["parcela"]) == GS.PARCELA_AMOUNT)
	_check("e no boletim da semana em curso",
		int(GS.semana_atual["parcela"]) == GS.PARCELA_AMOUNT)

	# 5. Fora de "playing" a porta fecha: o turno está parado à espera de uma
	#    decisão, e pagar por baixo dela seria decidir por cima do jogador.
	_fresh_playing()
	GS.cash = GS.PARCELA_AMOUNT + 1000
	GS._set_phase("debt_payment")
	_check("fora de playing a porta fecha",
		not GS.pode_pagar_parcela_adiantado())
	GS._set_phase("playing")

	# 6. E quem paga adiantado GANHA a partida no fim do prazo — a vitória
	#    olha `parcela_paid`, não a fase em que ela foi paga.
	_check("quitar adiantado satisfaz a vitoria", GS.pagar_parcela_adiantado())
	GS.turn = GS.TURNS_TOTAL + 1
	GS._check_end()
	_check("no fim do prazo, com a parcela paga, o porto e salvo",
		GS.phase == "game_over" and bool(GS.won))

	_t5k_completo = true


# ── T5l ──────────────────────────────────────────────────────────────────
#
# O MOTIVO DA ESCALA (06/09). Um barco passou a nascer com um motivo, e o
# efeito dele é o da ESTRUTURA a que está preso — não do motivo sozinho.
# Este bloco tranca as quatro coisas que podem envelhecer caladas.
func _t5l_motivo_da_escala() -> void:
	GS._rng.seed = 20260906
	GS.clear_save()
	GS.new_game()

	# (1) O CONTRATO DA CONTABILIDADE. `_lancar_receita()` roteia o bónus por
	# `destino[estrutura]`, e o Dictionary do GDScript CRIA a chave em vez de
	# reclamar: um motivo novo preso a uma estrutura sem linha própria somaria
	# dinheiro numa chave que a receita não lê, e ele sumia sem erro nenhum.
	var sem_linha := ""
	for id in GS.MOTIVOS:
		var m: Dictionary = GS.MOTIVOS[id]
		if float(m["bonus"]) > 0.0 and not GS.DIA_ZERADO.has(String(m["estrutura"])):
			sem_linha = id
	_check("todo motivo que paga tem linha na contabilidade (%s)"
			% ("nenhum de fora" if sem_linha == "" else sem_linha),
		sem_linha == "")

	# (2) OS PESOS DE MOTIVO SOMAM 100 EM CADA CLASSE. É o que a tabela dos
	# números publica, e é assim que se lê a mistura sem fazer conta nenhuma.
	for classe in GS.CLASSES_DE_NAVIO:
		var pesos: Dictionary = GS.CLASSES_DE_NAVIO[classe]["motivos"]
		var soma := 0
		for id in pesos:
			soma += int(pesos[id])
		_check("os motivos do %s somam 100 (%d)" % [classe, soma], soma == 100)

	# (3) O SORTEIO RESPEITA A CLASSE, e TODO MOTIVO DA TABELA CHEGA AO JOGO.
	#
	# ⚠️ SÃO DUAS PERGUNTAS E A PRIMEIRA VERSÃO SÓ FAZIA UMA. Ela montava o
	# conjunto esperado A PARTIR DOS PESOS e comparava com o sorteado — o que
	# lê a mesma fonte do defeito: com o peso do granel a zero, ele deixava de
	# ser esperado E de ser sorteado, e a asserção passava contente. Injetado
	# em 06/09, não reprovou nada. Quem tem de reprovar isso é uma pergunta que
	# NÃO sai dos pesos: um motivo escrito na tabela e que nunca aparece é a
	# irmã do `barco_medio` que era renderizado, validado e nunca entrava em
	# doca nenhuma.
	var vistos_no_total := {}
	for classe in GS.CLASSES_DE_NAVIO:
		var pesos: Dictionary = GS.CLASSES_DE_NAVIO[classe]["motivos"]
		var vistos := {}
		for i in range(400):
			# Tipo à mão: o `GS` é o autoload pego por `get_node()`, e o Godot
			# recusa-se a inferir a partir de um Node destipado.
			var sorteado: String = GS._sortear_motivo(String(classe))
			vistos[sorteado] = true
			vistos_no_total[sorteado] = true
		var sobra := ""
		for id in vistos:
			if not pesos.has(id) or int(pesos[id]) == 0:
				sobra = id
		_check("o %s nunca traz motivo fora da tabela dele (%s)"
				% [classe, sobra if sobra != "" else "nenhum"],
			sobra == "")
	var nunca_aparece := ""
	for id in GS.MOTIVOS:
		if not vistos_no_total.has(id):
			nunca_aparece = id
	_check("todo motivo da tabela chega ao jogo (%s)"
			% ("todos" if nunca_aparece == "" else nunca_aparece),
		nunca_aparece == "")

	# (3b) AS TRÊS CLASSES, E A TRAVA DO NÍVEL. Esta é a pergunta nova de
	# 06/09: o porto em ruínas não pode receber navio grande, e o porto
	# completo tem de receber os três — senão a classe de cima seria arte
	# gerada que nunca chega à tela, que é o defeito que o D17 existe para
	# pegar do outro lado.
	GS.clear_save()
	GS.new_game()
	if GS.phase == "rival_offer":
		GS.resolve_rival_offer(true)
	_check("porto em ruínas é nível 1 (%d)" % int(GS.nivel_do_porto()),
		int(GS.nivel_do_porto()) == 1)
	var so_pesqueiro := {}
	for i in range(300):
		so_pesqueiro[String(GS._make_boat()["classe"])] = true
	_check("e recebe SÓ o pesqueiro (%s)" % [so_pesqueiro.keys()],
		so_pesqueiro.size() == 1 and so_pesqueiro.has("pesqueiro"))

	GS.cash = 10000000
	GS.comprar_estrutura("pier_2")
	GS.comprar_estrutura("patio")
	_check("com duas estruturas o porto sobe a nível 2 (%d)" % int(GS.nivel_do_porto()),
		int(GS.nivel_do_porto()) == 2)
	var ate_medio := {}
	for i in range(300):
		ate_medio[String(GS._make_boat()["classe"])] = true
	_check("e recebe pesqueiro e cargueiro, mas ainda não o grande (%s)"
			% [ate_medio.keys()],
		ate_medio.size() == 2 and ate_medio.has("medio")
			and not ate_medio.has("grande"))

	# ⚠️ O NÍVEL É O MENOR DOS DOIS, E SÓ AQUI ISSO SE PROVA. Nos outros
	# estados o píer e o guindaste andam ao mesmo nível, e trocar o `mini` por
	# um `maxi` no `nivel_do_porto()` passava em tudo — foi injetado em 06/09 e
	# não reprovou nada. O estado que APERTA é este: pórtico comprado, cais
	# ainda não, ou seja guindaste no nível 3 e píer no 2. Com o `maxi`, o
	# navio de longo curso atracaria num cais que não o aguenta.
	GS.cash = 10000000
	GS.comprar_estrutura("guindaste")
	_check("com pórtico e sem cais o porto FICA no nível 2 (píer %d, guindaste %d, porto %d)"
			% [int(GS.nivel_pier()), int(GS.nivel_guindaste()), int(GS.nivel_do_porto())],
		int(GS.nivel_guindaste()) == 3 and int(GS.nivel_pier()) == 2
			and int(GS.nivel_do_porto()) == 2)
	var sem_cais := {}
	for i in range(300):
		sem_cais[String(GS._make_boat()["classe"])] = true
	_check("e o longo curso continua sem atracar (%s)" % [sem_cais.keys()],
		not sem_cais.has("grande"))

	GS.cash = 10000000
	GS.comprar_estrutura("cais")
	_check("com pórtico e cais o porto chega a nível 3 (%d)" % int(GS.nivel_do_porto()),
		int(GS.nivel_do_porto()) == 3)
	var todas := {}
	for i in range(300):
		todas[String(GS._make_boat()["classe"])] = true
	_check("e aí sim recebe as três classes (%s)" % [todas.keys()],
		todas.size() == GS.CLASSES_DE_NAVIO.size())

	# E o valor de cada barco tem de estar DENTRO da faixa da classe dele: uma
	# faixa que não fosse lida daria um pesqueiro de R$70.000, que passaria em
	# tudo o resto porque nada mais pergunta de onde o número veio.
	var fora_da_faixa := ""
	for i in range(300):
		var b: Dictionary = GS._make_boat()
		var d: Dictionary = GS.CLASSES_DE_NAVIO[String(b["classe"])]
		if int(b["value"]) < int(d["valor_min"]) or int(b["value"]) > int(d["valor_max"]):
			fora_da_faixa = "%s a %d" % [b["classe"], int(b["value"])]
	_check("o valor cai na faixa da classe (%s)"
			% ("todos" if fora_da_faixa == "" else fora_da_faixa),
		fora_da_faixa == "")

	# (4) O PÁTIO PAGA NO CONTÊINER E EM MAIS NADA. É o par simétrico do teste
	# do armazém no T5b: com um barco só, um bónus que voltasse a ser global
	# passaria nos dois.
	GS.clear_save()
	GS.new_game()
	if GS.phase == "rival_offer":
		GS.resolve_rival_offer(true)
	GS.cash = 10000000
	_check("o pátio foi comprado para o teste", GS.comprar_estrutura("patio") == true)
	var esperado_conteiner := int(round(1000 * (1.0 + GS.PATIO_BONUS_CARGA)))
	var recibo: Dictionary = GS.DIA_ZERADO.duplicate()
	var pago_conteiner: int = GS._lancar_receita(recibo, 1000, "conteiner")
	_check("o pátio soma %d%% ao contêiner (1000 -> %d)"
			% [int(GS.PATIO_BONUS_CARGA * 100), pago_conteiner],
		pago_conteiner == esperado_conteiner
			and int(recibo["patio"]) == esperado_conteiner - 1000)
	var pago_pescado: int = GS._lancar_receita(GS.DIA_ZERADO.duplicate(), 1000, "pescado")
	_check("e nao soma nada ao pescado (1000 -> %d)" % pago_pescado,
		pago_pescado == 1000)

	# (5) O TURNO DO GRANEL, E O QUE O PÓRTICO FAZ COM ELE. As três leituras
	# de uma vez, porque é entre elas que a conta pode escorregar: sem pórtico
	# o granel ocupa o berço um turno a mais que o outro navio grande; COM
	# pórtico o grande comum volta a 1, que é o número que o balanceamento de
	# 05/09 mediu, e o granel fica em 2 em vez de descer ao mesmo lugar.
	GS.clear_save()
	GS.new_game()
	# ⚠️ RESOLVER A OFERTA ANTES DE COMPRAR. `new_game()` chama `_spawn_boats()`,
	# que tem 30% de abrir contra-oferta, e fora de "playing" o
	# `comprar_estrutura()` recusa calado. Este bloco passou a reprovar quando
	# o bloco de cima ganhou sorteios novos e empurrou o RNG — a semente está
	# fixa no topo do T5l, mas o ESTADO dela anda com quem a usa.
	if GS.phase == "rival_offer":
		GS.resolve_rival_offer(true)
	_check("sem pórtico, o cargueiro leva 2 turnos (%d)"
			% GS._turnos_de_operacao("medio", "conteiner"),
		GS._turnos_de_operacao("medio", "conteiner") == 2)
	_check("sem pórtico, o cargueiro de granel leva 3 (%d)"
			% GS._turnos_de_operacao("medio", "granel"),
		GS._turnos_de_operacao("medio", "granel") == 3)
	_check("e o pesqueiro leva 1 (%d)" % GS._turnos_de_operacao("pesqueiro", "pescado"),
		GS._turnos_de_operacao("pesqueiro", "pescado") == 1)
	GS.cash = 10000000
	GS.comprar_estrutura("pier_2")
	_check("o pórtico foi comprado para o teste",
		GS.comprar_estrutura("guindaste") == true)
	_check("com pórtico, o cargueiro volta a 1 turno (%d)"
			% GS._turnos_de_operacao("medio", "conteiner"),
		GS._turnos_de_operacao("medio", "conteiner") == 1)
	_check("com pórtico, o granel dele desce a 2 e nao a 1 (%d)"
			% GS._turnos_de_operacao("medio", "granel"),
		GS._turnos_de_operacao("medio", "granel") == 2)
	_check("e o pesqueiro nunca desce abaixo de 1 (%d)"
			% GS._turnos_de_operacao("pesqueiro", "pescado"),
		GS._turnos_de_operacao("pesqueiro", "pescado") == 1)
	# O navio de longo curso leva 3 e SÓ EXISTE com pórtico: os 3 turnos dele
	# nunca chegam a jogar-se, e é essa a diferença entre ler a tabela e ler o
	# jogo. Com pórtico ele fica em 2, que é o dobro do cargueiro.
	_check("o longo curso com pórtico leva 2 turnos (%d)"
			% GS._turnos_de_operacao("grande", "conteiner"),
		GS._turnos_de_operacao("grande", "conteiner") == 2)

	# (6) E O BARCO NASCE COM ELE. Um motivo que não chegasse ao dicionário do
	# barco só rebentaria na primeira docagem, num `MOTIVOS[motivo]` com chave
	# vazia — e o `_make_boat()` é o único sítio que o põe lá.
	GS.clear_save()
	GS.new_game()
	if GS.phase == "rival_offer":
		GS.resolve_rival_offer(true)
	var fora := ""
	for i in range(50):
		var b: Dictionary = GS._make_boat()
		if not b.has("motivo") or not GS.MOTIVOS.has(String(b["motivo"])):
			fora = "barco %d" % i
		elif int(b["op_turns"]) != GS._turnos_de_operacao(String(b["classe"]), String(b["motivo"])):
			fora = "turnos do barco %d" % i
	_check("todo barco nasce com motivo conhecido e turnos coerentes (%s)"
			% ("todos" if fora == "" else fora),
		fora == "")

	_t5l_completo = true

