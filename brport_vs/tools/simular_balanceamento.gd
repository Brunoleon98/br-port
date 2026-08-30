extends SceneTree

# ============================================================
# BR Port VS — Simulador de balanceamento
# Ferramenta de apoio ao Bloco 3. NÃO faz parte do jogo.
#
# Roda muitas partidas headless com perfis de jogador diferentes e
# imprime a taxa de vitória de cada um. Serve para responder com
# número, e não com achismo, a pergunta que trava o Bloco 3:
# "o jogo está fácil demais?".
#
# Por que perfis: a suíte de testes joga PERFEITO — aloca todo
# trabalhador em todo barco e sempre iguala o rival. Humano não joga
# assim. Medir a dificuldade só pelo jogo perfeito diz pouco sobre a
# dificuldade real, e é justamente o erro que o Bloco 3 tem que evitar
# antes de gastar semanas de arte em cima de um loop mal calibrado.
#
# Uso:
#   Godot --headless --path brport_vs \
#     --script res://tools/simular_balanceamento.gd -- [partidas] [semente]
#
#   ... -- 1000        1000 partidas por perfil
#   ... -- 1000 42     mesma coisa, com semente fixa 42
#
# As partidas são determinísticas pela semente: rodar de novo com a
# mesma semente dá exatamente o mesmo resultado. É isso que permite
# comparar duas configurações de `# TUNING:` sem o ruído do sorteio —
# muda a constante, roda com a MESMA semente, compara.
# ============================================================

const PARTIDAS_PADRAO := 500
const SEMENTE_PADRAO := 20260825

# Abaixo de quantas partidas o resultado deixa de ser uma MEDIDA e passa a ser
# só um teste de fumaça — a ferramenta ainda roda, mas o número que ela imprime
# não dá para comparar com nada.
#
# Não é zelo teórico: o CI roda 30 partidas (só para provar que o simulador
# não quebrou junto com o GameState) e imprimiu 36,7% para o jogador mediano,
# contra os 47% medidos e registrados no CLAUDE.md. Leu-se como regressão de
# balanceamento e custou uma investigação inteira. Com 30 partidas a margem é
# de ±18 pontos: 36,7% e 47,3% são a MESMA medida, e o log não dizia isso.
#
# O corte sai da margem: em 100 partidas o pior caso é ±10 pontos, que é o
# menor deslocamento que ainda interessa a alguém que mexe num `# TUNING:`.
const PARTIDAS_PARA_MEDIR := 100
const MARGEM_UTIL := 10.0

# Perfis de jogador. Os números são o modelo de "como alguém erra":
#   chance_esquecer_doca — por doca, por turno: deixou o barco sem
#     trabalhador (distração, não entendeu o drag-and-drop, achou que
#     já tinha alocado).
#   estilo_negociacao — como o jogador joga a contra-oferta do Arlindo:
#     "otimo"  tenta o meio-termo (−7%) e, se falhar, iguala para não perder;
#     "medio"  na maioria das vezes iguala de cara, às vezes arrisca segurar
#              o preço, e recua para igualar se o cliente reclamar;
#     "ruim"   segura o preço por teimosia e insiste até o cliente ir embora.
#   chance_igualar_rival — para "medio"/"ruim": com que frequência ele já
#     iguala de cara em vez de arriscar.
#   folga_para_upgrade — múltiplo do custo do upgrade que o jogador
#     exige ter em caixa antes de comprar. 1.0 = compra assim que dá;
#     4.0 = só compra com muita folga (na prática, quase nunca compra).
const PERFIS := [
	{
		"nome": "Ótimo",
		"descricao": "aloca tudo, negocia o meio-termo e recua a tempo, compra o upgrade assim que dá",
		"chance_esquecer_doca": 0.0,
		"estilo_negociacao": "otimo",
		"chance_igualar_rival": 1.0,
		"folga_para_upgrade": 1.0,
	},
	{
		"nome": "Mediano",
		"descricao": "deixa uma doca passar de vez em quando, arrisca na negociação às vezes",
		"chance_esquecer_doca": 0.15,
		"estilo_negociacao": "medio",
		"chance_igualar_rival": 0.70,
		"folga_para_upgrade": 2.0,
	},
	{
		"nome": "Descuidado",
		"descricao": "perde barco com frequência, teima em segurar o preço até perder o cliente",
		"chance_esquecer_doca": 0.35,
		"estilo_negociacao": "ruim",
		"chance_igualar_rival": 0.40,
		"folga_para_upgrade": 4.0,
	},
]

var GS
var _done := false


# Mesmo motivo da suíte de testes: dentro de _initialize() a árvore
# ainda não está ativa. Rodar no primeiro frame evita surpresa.
func _process(_delta: float) -> bool:
	if _done:
		return true
	_done = true
	_rodar()
	return true


func _rodar() -> void:
	GS = root.get_node("GameState")
	GS.clear_save()

	var args := OS.get_cmdline_user_args()
	var partidas := PARTIDAS_PADRAO
	var semente := SEMENTE_PADRAO
	if args.size() >= 1 and args[0].is_valid_int():
		partidas = int(args[0])
	if args.size() >= 2 and args[1].is_valid_int():
		semente = int(args[1])

	print("=== BR Port VS — simulação de balanceamento ===")
	print("%d partidas por perfil · semente %d" % [partidas, semente])
	print("Parcela a vencer: R$%d na semana %d (turno %d)" % [
		GS.PARCELA_AMOUNT, GS.WEEKS_TOTAL, GS.PARCELA_DUE_TURN])
	print("")
	_avisar_se_amostra_curta(partidas)

	var resultados := []
	for perfil in PERFIS:
		resultados.append(_simular_perfil(perfil, partidas, semente))

	_imprimir_tabela(resultados, partidas)
	_imprimir_diagnostico(resultados)
	# De novo no fim: log de CI se lê de baixo para cima, e o aviso do
	# cabeçalho fica a centenas de linhas de distância da conclusão.
	_avisar_se_amostra_curta(partidas)
	quit(0)


# Diz, em voz alta, quando a rodada não tem partidas que cheguem para medir.
# O silêncio aqui é o que faz um número de teste de fumaça passar por medida.
func _avisar_se_amostra_curta(partidas: int) -> void:
	if partidas >= PARTIDAS_PARA_MEDIR:
		return
	# O pior caso da margem é em p = 0,5, e não depende do resultado: dá para
	# afirmar a imprecisão ANTES de olhar para a taxa.
	var pior := _margem_de_erro(0.5, partidas)
	print("")
	print("⚠️  TESTE DE FUMAÇA, NÃO MEDIÇÃO — %d partidas por perfil." % partidas)
	print("    A margem chega a ±%.0f pontos. NÃO compare estas taxas com as do" % pior)
	print("    CLAUDE.md (100% / 47% / 0%, medidas em 600 partidas): a diferença")
	print("    que você vê provavelmente é sorteio.")
	print("    Para medir de verdade: ... --script res://tools/simular_balanceamento.gd -- 600")
	print("")


func _simular_perfil(perfil: Dictionary, partidas: int, semente: int) -> Dictionary:
	var rng := RandomNumberGenerator.new()

	var vitorias := 0
	var quebrou_antes := 0        # caixa negativo antes de chegar ao vencimento
	var chegou_sem_dinheiro := 0  # chegou ao vencimento sem os R$8.000
	var caixas_no_vencimento := []
	var caixas_finais := []
	var atendidos := 0
	var perdidos := 0
	var reputacoes := 0.0
	var travadas := 0

	for run in range(partidas):
		# Duas sementes independentes: uma para o mundo (chegada de barco,
		# valor, oferta do rival) e outra para os erros do jogador. Assim dá
		# para trocar de perfil e continuar caindo nos MESMOS barcos.
		#
		# A SEMENTE VEM ANTES DE `new_game()`. Ela vinha depois, e como
		# `new_game()` já chama `_spawn_boats()`, a mão inicial de toda partida
		# saía do gerador não semeado (`_rng.randomize()` no `_ready`). O
		# resultado é que duas rodadas seguidas do simulador, sem tocar em
		# nada, davam medianas diferentes — e comparar antes/depois de uma
		# afinação é justamente para o que esta ferramenta serve.
		GS.clear_save()
		GS._rng.seed = semente + run * 7919
		rng.seed = semente + run * 104729
		GS.new_game()

		var caixa_no_vencimento := -1
		var seguranca := 0

		while GS.phase != "game_over" and seguranca < 300:
			seguranca += 1

			if GS.phase == "rival_offer":
				_negociar(perfil, rng)
				continue

			if GS.phase == "debt_payment":
				caixa_no_vencimento = GS.cash
				if GS.cash >= GS.PARCELA_AMOUNT:
					GS.pay_debt()
				else:
					GS.fail_debt()
				continue

			_construir(perfil)

			_alocar(perfil, rng)
			GS.advance_turn()

		if seguranca >= 300:
			travadas += 1

		if GS.won:
			vitorias += 1
		elif caixa_no_vencimento < 0:
			quebrou_antes += 1
		else:
			chegou_sem_dinheiro += 1

		if caixa_no_vencimento >= 0:
			caixas_no_vencimento.append(caixa_no_vencimento)
		caixas_finais.append(GS.cash)
		atendidos += int(GS.metrics["boats_served"])
		perdidos += int(GS.metrics["boats_lost"])
		reputacoes += GS.reputation

	return {
		"perfil": perfil,
		"vitorias": vitorias,
		"quebrou_antes": quebrou_antes,
		"chegou_sem_dinheiro": chegou_sem_dinheiro,
		"caixa_vencimento_mediana": _mediana(caixas_no_vencimento),
		"caixa_final_mediana": _mediana(caixas_finais),
		"atendidos_medio": float(atendidos) / float(partidas),
		"perdidos_medio": float(perdidos) / float(partidas),
		"reputacao_media": reputacoes / float(partidas),
		"travadas": travadas,
	}


# Joga a contra-oferta inteira até ela fechar de um jeito ou de outro.
# "insistiu" devolve o controle com o cliente ainda na mesa, então é preciso
# escolher de novo — daí o laço. A paciência é 2, então ele sempre termina.
func _negociar(perfil: Dictionary, rng: RandomNumberGenerator) -> void:
	var guarda := 0
	while GS.phase == "rival_offer" and guarda < 5:
		guarda += 1
		GS.negotiate_rival(_escolher_acao(perfil, rng))


func _escolher_acao(perfil: Dictionary, rng: RandomNumberGenerator) -> String:
	var ja_insistiu: bool = GS.rival_attempts_left < GS.RIVAL_PATIENCE
	match String(perfil["estilo_negociacao"]):
		"otimo":
			# Meio-termo primeiro (é o de melhor retorno esperado); se o cliente
			# recusar, iguala em vez de arriscar perder o barco.
			return "igualar" if ja_insistiu else "metade"
		"ruim":
			# Teima: segura o preço de novo mesmo com o cliente de saída.
			if ja_insistiu:
				return "manter"
			return "igualar" if rng.randf() < float(perfil["chance_igualar_rival"]) else "manter"
		_:
			# "medio": arrisca uma vez, mas recua quando o cliente reclama.
			if ja_insistiu:
				return "igualar"
			return "igualar" if rng.randf() < float(perfil["chance_igualar_rival"]) else "manter"


# Aloca trabalhadores livres nas docas com barco, respeitando o modelo de
# erro do perfil. Espelha o que um jogador faz na tela, não um atalho de
# lógica — inclusive passando por assign_worker(), que é quem valida.
# Ordem de compra do porto. Não é arbitrária: doca é vazão, e vazão multiplica
# tudo o que vem depois — comprar o armazém antes do segundo píer é somar 15%
# a uma receita que ainda é metade do que podia ser.
#
# `folga_para_upgrade` continua sendo o que separa os perfis: o jogador atento
# compra assim que dá, o descuidado só quando sobra muito.
const ORDEM_DE_COMPRA := ["pier_2", "patio", "armazem", "pier_3", "escritorio"]


func _construir(perfil: Dictionary) -> void:
	var folga: float = float(perfil["folga_para_upgrade"])
	for id in ORDEM_DE_COMPRA:
		if GS.tem_estrutura(id):
			continue
		if GS.impedimento_estrutura(id) != "":
			continue
		# Guardar uma folga: gastar até o último real deixa o porto sem
		# salário na virada da semana.
		if GS.cash < int(int(GS.ESTRUTURAS[id]["custo"]) * folga):
			continue
		GS.comprar_estrutura(id)
		return                      # uma por turno, para não esvaziar o caixa


func _alocar(perfil: Dictionary, rng: RandomNumberGenerator) -> void:
	for i in range(GS.docks.size()):
		var doca: Dictionary = GS.docks[i]
		if doca["boat"] == null or doca["worker_id"] != null:
			continue
		var barco: Dictionary = doca["boat"]
		if barco.get("rival", false) and not barco.get("matched", false):
			continue
		if rng.randf() < float(perfil["chance_esquecer_doca"]):
			continue
		var livre := _trabalhador_livre()
		if livre < 0:
			return
		GS.assign_worker(livre, i)


func _trabalhador_livre() -> int:
	for w in GS.workers:
		var id := int(w["id"])
		if int(w["busy_turns"]) > 0:
			continue
		if GS.worker_dock_index(id) >= 0:
			continue
		return id
	return -1


func _mediana(valores: Array) -> int:
	if valores.is_empty():
		return 0
	var ordenado := valores.duplicate()
	ordenado.sort()
	return int(ordenado[int(ordenado.size() / 2)])


func _imprimir_tabela(resultados: Array, partidas: int) -> void:
	print("%-12s │ %8s │ %7s │ %12s │ %12s │ %9s │ %8s" % [
		"Perfil", "Vitórias", "Taxa", "Quebrou antes", "Chegou curto", "Atendidos", "Perdidos"])
	print("─────────────┼──────────┼─────────┼──────────────┼──────────────┼───────────┼─────────")
	for r in resultados:
		var taxa := 100.0 * float(r["vitorias"]) / float(partidas)
		print("%-12s │ %8d │ %6.1f%% │ %12d │ %12d │ %9.1f │ %8.1f" % [
			r["perfil"]["nome"], r["vitorias"], taxa,
			r["quebrou_antes"], r["chegou_sem_dinheiro"],
			r["atendidos_medio"], r["perdidos_medio"]])
	print("")
	print("  Quebrou antes = caixa ficou negativo antes do vencimento.")
	print("  Chegou curto  = chegou no Sr. Ribeiro sem os R$%d." % GS.PARCELA_AMOUNT)
	print("")

	for r in resultados:
		var margem := _margem_de_erro(float(r["vitorias"]) / float(partidas), partidas)
		print("· %s — %s" % [r["perfil"]["nome"], r["perfil"]["descricao"]])
		print("    taxa de vitória %.1f%% ± %.1f  ·  caixa no vencimento (mediana) R$%d  ·  reputação final média %.0f" % [
			100.0 * float(r["vitorias"]) / float(partidas), margem,
			int(r["caixa_vencimento_mediana"]), float(r["reputacao_media"])])
		if int(r["travadas"]) > 0:
			print("    ⚠️  %d partida(s) não terminaram — possível travamento." % int(r["travadas"]))
	print("")


# Intervalo de confiança de 95% para a proporção. É o número que diz se a
# diferença entre duas rodadas é real ou só sorteio: 40 partidas dão ±15
# pontos, o que torna "63%" e "47%" a mesma medida.
func _margem_de_erro(p: float, n: int) -> float:
	if n <= 0:
		return 0.0
	return 100.0 * 1.96 * sqrt(max(p * (1.0 - p), 0.0) / float(n))


func _imprimir_diagnostico(resultados: Array) -> void:
	print("=== Leitura ===")
	var otimo: Dictionary = resultados[0]
	var descuidado: Dictionary = resultados[resultados.size() - 1]
	var n := int(otimo["vitorias"]) + int(otimo["quebrou_antes"]) + int(otimo["chegou_sem_dinheiro"])
	var taxa_otimo := 100.0 * float(otimo["vitorias"]) / float(n)
	var taxa_descuidado := 100.0 * float(descuidado["vitorias"]) / float(n)

	if taxa_otimo < 60.0:
		print("· Jogo perfeito ganha só %.0f%% — está DIFÍCIL demais no teto: nem jogando" % taxa_otimo)
		print("  certo dá para confiar na vitória, e isso lê como injustiça, não desafio.")
	elif taxa_otimo > 90.0:
		print("· Jogo perfeito ganha %.0f%% — o teto está garantido, o que é bom." % taxa_otimo)
	else:
		print("· Jogo perfeito ganha %.0f%% — teto ainda com sorte demais no meio." % taxa_otimo)

	if taxa_descuidado > 50.0:
		print("· Jogar mal ganha %.0f%% — o ERRO NÃO CUSTA. É este o sintoma de 'fácil demais'." % taxa_descuidado)
	elif taxa_descuidado < 15.0:
		print("· Jogar mal ganha %.0f%% — errar custa caro, a pressão da parcela existe." % taxa_descuidado)
	else:
		print("· Jogar mal ganha %.0f%% — errar custa, sem virar punição seca." % taxa_descuidado)

	var vao := taxa_otimo - taxa_descuidado
	print("· Vão entre jogar bem e jogar mal: %.0f pontos." % vao)
	if vao < 25.0:
		print("  Vão estreito = a decisão do jogador pesa pouco no resultado. Antes de mexer")
		print("  em valor de barco ou de parcela, vale perguntar o que o jogador decide aqui.")
	print("")
	print("Para testar uma mudança: edite uma constante `# TUNING:` em")
	print("autoload/GameState.gd e rode de novo com a MESMA semente.")
