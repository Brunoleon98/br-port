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

# Destipado de propósito — é o autoload, resolvido em runtime. A consequência
# morde ao editar este arquivo: `var x := GS.cash` NÃO compila, porque o Godot
# não consegue inferir o tipo de um membro de um Node destipado. Escreva o tipo
# à mão (`var x: int = GS.cash`). O erro sai como "Cannot infer the type of ...
# because the value doesn't have a set type", e o Godot ainda assim encerra com
# código 0 — por isso o CI e o /fechar-sessao exigem a LINHA de sucesso.
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
	_imprimir_regime(resultados)
	_imprimir_reputacao(resultados)
	_imprimir_motivos(resultados)
	_imprimir_diagnostico(resultados)

	# O despejo em JSON existe para o projetor das Parcelas 2 e 3
	# (tools/projetar_parcelas.py) ter contra o que se calibrar. Sem ele o
	# projetor seria um segundo modelo da economia, sem nada que o obrigasse a
	# concordar com o jogo — que é exatamente como o modelo do GDD chegou a
	# acumular R$1.480 contra uma parcela de R$8.000.
	for a in args:
		if a.ends_with(".json"):
			_despejar_json(a, resultados, partidas, semente)
			break
	# De novo no fim: log de CI se lê de baixo para cima, e o aviso do
	# cabeçalho fica a centenas de linhas de distância da conclusão.
	_avisar_se_amostra_curta(partidas)
	quit(0)


# A economia semana a semana. A média das 4 semanas esconde o que interessa:
# a semana 1 é obra (o caixa SAI), e a última é o porto em regime. Projetar as
# Fases 2 e 3 a partir da média das quatro seria projetar a partir de um porto
# que só existe durante a Fase 1.
# A reputação está a DISCRIMINAR? Pendurar uma mecânica nela só faz sentido se
# ela variar entre jogadores e ao longo da partida. Se estiver no teto quando a
# decisão acontece, o efeito é um bónus fixo para toda a gente — que é o mesmo
# que não existir, com mais código.
# A MISTURA DE MOTIVOS que o jogo sorteou de verdade, contra a que os pesos
# prometem. Existe porque o peso de um motivo e a frequência dele não são a
# mesma coisa: o `BOAT_LARGE_CHANCE` decide primeiro o TAMANHO, e o cais
# reforçado multiplica essa chance — o porto que compra o cais vê mais
# contêiner e mais granel sem nenhum peso ter mudado. Sem esta tabela, um peso
# escrito errado e uma mistura deslocada pela mistura de barcos leem-se igual.
func _imprimir_motivos(resultados: Array) -> void:
	print("=== Mistura de motivos (barcos que chegaram) ===")
	var ids: Array = GS.MOTIVOS.keys()
	var cabecalho := "%-12s │ %8s" % ["Perfil", "barcos"]
	for id in ids:
		cabecalho += " │ %11s" % String(GS.MOTIVOS[id]["nome"])
	print(cabecalho)
	for r in resultados:
		var m: Dictionary = r["motivos"]
		var total := 0
		for id in ids:
			total += int(m.get(id, 0))
		var linha := "%-12s │ %8d" % [r["perfil"]["nome"], total]
		for id in ids:
			linha += " │ %10.1f%%" % (100.0 * float(int(m.get(id, 0))) / maxf(1.0, float(total)))
		print(linha)
	print("")
	print("  Os pesos de `MOTIVOS` são por TAMANHO de barco; a percentagem")
	print("  acima é sobre o total, e move-se com a mistura de tamanhos.")
	print("")


func _imprimir_reputacao(resultados: Array) -> void:
	print("=== Reputação NO MOMENTO da contra-oferta ===")
	print("%-12s │ %8s │ %8s │ %8s │ %8s │ %13s │ %8s │ %8s" % [
		"Perfil", "ofertas", "mediana", "mín", "máx", "no teto (100)",
		"apostas", "ganhas %"])
	for r in resultados:
		var v: Array = r["reputacao_nas_ofertas"]
		if v.is_empty():
			continue
		var ord := v.duplicate()
		ord.sort()
		var no_teto := 0
		for x in v:
			if float(x) >= 99.999:
				no_teto += 1
		print("%-12s │ %8d │ %8.1f │ %8.1f │ %8.1f │ %12.1f%% │ %8d │ %7.1f%%" % [
			r["perfil"]["nome"], v.size(), float(ord[int(ord.size() / 2)]),
			float(ord[0]), float(ord[ord.size() - 1]),
			100.0 * float(no_teto) / float(v.size()),
			int(r["apostas_feitas"]),
			100.0 * float(r["apostas_ganhas"]) / maxf(1.0, float(r["apostas_feitas"]))])
	print("")


func _imprimir_regime(resultados: Array) -> void:
	print("=== Economia semana a semana (delta de caixa médio) ===")
	var cabecalho := "%-12s │" % "Perfil"
	for w in range(GS.WEEKS_TOTAL):
		cabecalho += " %10s │" % ("Semana %d" % (w + 1))
	print(cabecalho)
	for r in resultados:
		var linha := "%-12s │" % r["perfil"]["nome"]
		for w in range(GS.WEEKS_TOTAL):
			var m: Array = r["margem_por_semana"]
			linha += " %10s │" % ("—" if w >= m.size() else "R$%d" % int(round(float(m[w]))))
		print(linha)
	print("")
	for r in resultados:
		var m: Array = r["margem_por_semana"]
		var b: Array = r["atendidos_por_semana"]
		if m.is_empty():
			continue
		print("· %s — em REGIME (semana %d): R$%d de margem OPERACIONAL, %.1f barcos" % [
			r["perfil"]["nome"], m.size(),
			int(round(_operacional(r, m.size() - 1))), float(b[b.size() - 1])])
	print("")
	print("  Margem operacional = delta de caixa MENOS o que foi gasto em obra na")
	print("  mesma semana. O perfil que compra tarde tem a compra dentro da semana")
	print("  que se quer medir, e sem separar as duas coisas ele parece render")
	print("  metade do que rende.")
	print("")


func _operacional(r: Dictionary, semana: int) -> float:
	var m: Array = r["margem_por_semana"]
	var o: Array = r["obra_por_semana"]
	if semana < 0 or semana >= m.size():
		return 0.0
	return float(m[semana]) + (float(o[semana]) if semana < o.size() else 0.0)


func _despejar_json(caminho: String, resultados: Array, partidas: int, semente: int) -> void:
	var perfis := {}
	for r in resultados:
		var m: Array = r["margem_por_semana"]
		var b: Array = r["atendidos_por_semana"]
		perfis[String(r["perfil"]["nome"])] = {
			"vitorias": r["vitorias"],
			"taxa": 100.0 * float(r["vitorias"]) / float(partidas),
			"caixa_vencimento_mediana": r["caixa_vencimento_mediana"],
			"margem_por_semana": m,
			"atendidos_por_semana": b,
			"margem_em_regime": _operacional(r, m.size() - 1),
			"margem_bruta_em_regime": 0.0 if m.is_empty() else m[m.size() - 1],
			"obra_por_semana": r["obra_por_semana"],
			"atendidos_em_regime": 0.0 if b.is_empty() else b[b.size() - 1],
			"estruturas": r["estruturas"],
			"docas_medias": r["docas_medias"],
			"trabalhadores_medios": r["trabalhadores_medios"],
		}
	var f := FileAccess.open(caminho, FileAccess.WRITE)
	if f == null:
		push_error("Não consegui escrever a medição em %s" % caminho)
		return
	f.store_string(JSON.stringify({
		"partidas": partidas,
		"semente": semente,
		"parcela": GS.PARCELA_AMOUNT,
		"semanas": GS.WEEKS_TOTAL,
		"turnos_por_semana": GS.TURNS_PER_WEEK,
		"caixa_inicial": GS.START_CASH,
		"perfis": perfis,
	}, "  ", true) + "\n")
	f.close()
	print("Medição despejada em %s" % caminho)
	print("")


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
	print("    CLAUDE.md (100% / 79,5% / 31,0%, medidas em 600 partidas): a diferença")
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
	var reputacoes_de_oferta := []   # reputação em cada contra-oferta, de todas as partidas
	var apostas_feitas := 0          # "metade"/"manter" tentadas
	var apostas_ganhas := 0          # ... e aceitas pelo cliente
	var margem_por_semana := []      # soma do delta de caixa, semana a semana
	var obra_por_semana := []        # e quanto desse delta foi obra, não operação
	var atendidos_por_semana := []
	var amostras_por_semana := []
	# Em quantas partidas cada estrutura acabou de pé, e com quantas
	# docas/trabalhadores. Sem isto não dá para projetar as fases seguintes: o
	# perfil Descuidado quase nunca compra nada, e um modelo que suponha o
	# porto inteiro construído erra a margem dele em 98% — foi assim que este
	# campo passou a existir.
	var estruturas_de_pe := {}
	var docas_totais := 0
	var trabalhadores_totais := 0
	var motivos_vistos := {}

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

		# Fotografia no fim de cada semana. Serve para separar a semana 1 —
		# em que o porto ainda está em ruínas e o caixa é gasto em obra — da
		# semana em REGIME, com tudo construído. É essa a semana que interessa
		# para projetar as Fases 2 e 3: a Parcela 1 é paga por um porto que
		# ainda está a levantar-se, e as outras duas não seriam.
		var caixa_semana := []
		var obra_semana := []
		var atendidos_semana := []
		# A MISTURA DE MOTIVOS, contada por barco NASCIDO e não por barco
		# servido: é a mistura que a tabela dos números publica em `MOTIVOS`, e
		# é contra ela que se confere se os pesos que se escreveram são os que
		# o jogo sorteia. Contada por `id` porque o mesmo barco aparece em
		# muitos turnos seguidos — contar por varredura somaria cada um tantas
		# vezes quantos turnos ele levar a descarregar, e o granel (que leva
		# mais) sairia inflado exatamente pela razão que o distingue.
		var ids_vistos := {}
		var caixa_anterior: int = GS.cash
		var atendidos_anterior := 0
		var obra_na_semana := 0
		var reputacao_nas_ofertas := []
		var apostas := [0, 0]        # [feitas, ganhas]

		while GS.phase != "game_over" and seguranca < 300:
			seguranca += 1
			_contar_motivos(motivos_vistos, ids_vistos)

			if GS.phase == "rival_offer":
				# A reputação NO MOMENTO da oferta é o número que interessa ao
				# A3: é sobre ela que a negociação vai pendurar-se, e uma
				# reputação que já esteja no teto quando a oferta chega não
				# discrimina jogador nenhum.
				reputacao_nas_ofertas.append(GS.reputation)
				_negociar(perfil, rng, apostas)
				continue

			if GS.phase == "debt_payment":
				caixa_no_vencimento = GS.cash
				if GS.cash >= GS.PARCELA_AMOUNT:
					GS.pay_debt()
				else:
					GS.fail_debt()
				continue

			obra_na_semana += _construir(perfil)

			_alocar(perfil, rng)
			var semana_antes: int = GS.current_week()
			GS.advance_turn()
			# O fecho de semana acontece DENTRO do advance_turn, então a leitura
			# tem de ser depois dele — e só quando a semana virou de verdade.
			if GS.current_week() != semana_antes:
				caixa_semana.append(GS.cash - caixa_anterior)
				obra_semana.append(obra_na_semana)
				atendidos_semana.append(int(GS.metrics["boats_served"]) - atendidos_anterior)
				caixa_anterior = GS.cash
				atendidos_anterior = int(GS.metrics["boats_served"])
				obra_na_semana = 0

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
		reputacoes_de_oferta.append_array(reputacao_nas_ofertas)
		apostas_feitas += int(apostas[0])
		apostas_ganhas += int(apostas[1])
		for id in GS.ESTRUTURAS:
			if GS.tem_estrutura(id):
				estruturas_de_pe[id] = int(estruturas_de_pe.get(id, 0)) + 1
		docas_totais += GS.docks.size()
		trabalhadores_totais += GS.workers.size()
		for w in range(caixa_semana.size()):
			while margem_por_semana.size() <= w:
				margem_por_semana.append(0)
				obra_por_semana.append(0)
				atendidos_por_semana.append(0)
				amostras_por_semana.append(0)
			margem_por_semana[w] += int(caixa_semana[w])
			obra_por_semana[w] += int(obra_semana[w])
			atendidos_por_semana[w] += int(atendidos_semana[w])
			amostras_por_semana[w] += 1

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
		"margem_por_semana": _media_por_semana(margem_por_semana, amostras_por_semana),
		"obra_por_semana": _media_por_semana(obra_por_semana, amostras_por_semana),
		"atendidos_por_semana": _media_por_semana(atendidos_por_semana, amostras_por_semana),
		"estruturas": _fracao_de_pe(estruturas_de_pe, partidas),
		"reputacao_nas_ofertas": reputacoes_de_oferta,
		"apostas_feitas": apostas_feitas,
		"apostas_ganhas": apostas_ganhas,
		"docas_medias": float(docas_totais) / float(partidas),
		"trabalhadores_medios": float(trabalhadores_totais) / float(partidas),
		"motivos": motivos_vistos,
	}


# Anota o motivo de cada barco NOVO que está em doca. `ids_vistos` é por
# partida: o `_uid` do GameState recomeça a cada `new_game()`, então guardar os
# ids entre partidas juntaria barcos diferentes com o mesmo número.
func _contar_motivos(acumulado: Dictionary, ids_vistos: Dictionary) -> void:
	for i in range(GS.docks.size()):
		var barco = GS.docks[i]["boat"]
		if barco == null:
			continue
		var id: int = int(barco["id"])
		if ids_vistos.has(id):
			continue
		ids_vistos[id] = true
		var motivo: String = String(barco["motivo"])
		acumulado[motivo] = int(acumulado.get(motivo, 0)) + 1


# Em que fração das partidas cada estrutura acabou construída.
func _fracao_de_pe(contagem: Dictionary, partidas: int) -> Dictionary:
	var out := {}
	for id in GS.ESTRUTURAS:
		out[id] = float(int(contagem.get(id, 0))) / float(partidas)
	return out


# Uma partida que acaba cedo (caixa negativo) não tem as 4 semanas, então a
# média de cada semana divide pelo número de partidas que CHEGARAM a ela — e
# não pelo total, que diluiria a semana 4 com partidas que nunca a jogaram.
func _media_por_semana(somas: Array, amostras: Array) -> Array:
	var out := []
	for i in range(somas.size()):
		var n: int = int(amostras[i])
		out.append(0.0 if n == 0 else float(somas[i]) / float(n))
	return out


# Joga a contra-oferta inteira até ela fechar de um jeito ou de outro.
# "insistiu" devolve o controle com o cliente ainda na mesa, então é preciso
# escolher de novo — daí o laço. A paciência é 2, então ele sempre termina.
# `contador` recebe [apostas feitas, apostas ganhas]. Só "metade" e "manter"
# contam: "igualar" fecha SEMPRE, e por isso um contador de ofertas fechadas
# não mede nada — foi o primeiro que se escreveu aqui, e ele dava o mesmo
# número com a reputação ligada e desligada, que é como se descobriu o erro.
func _negociar(perfil: Dictionary, rng: RandomNumberGenerator, contador: Array) -> void:
	var guarda := 0
	while GS.phase == "rival_offer" and guarda < 5:
		guarda += 1
		var acao := _escolher_acao(perfil, rng)
		var aposta := acao != "igualar"
		var res: String = GS.negotiate_rival(acao)
		if aposta:
			contador[0] += 1
			if res == "fechado":
				contador[1] += 1


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
# ⚠️ ESTA LISTA É CRAVADA, E ESQUECÊ-LA É UMA MEDIÇÃO QUE MENTE SEM AVISAR.
# Ela não percorre `ESTRUTURAS`: uma estrutura nova que não entre aqui nunca é
# comprada por perfil nenhum, e as 600 partidas saem IDÊNTICAS às de antes —
# o que se lê como "o upgrade não mexeu no balanceamento" quando o que
# aconteceu foi ninguém o ter comprado. Os dois upgrades vão no fim porque são
# os últimos da cadeia de `requer`.
const ORDEM_DE_COMPRA := ["pier_2", "patio", "armazem", "pier_3", "escritorio",
	"guindaste", "cais"]


# Devolve o que gastou. O valor importa: o delta de caixa de uma semana em que
# se comprou o armazém não é a margem daquela semana, e tratá-lo como se fosse
# fazia o perfil Descuidado parecer render metade do que rende — ele compra
# tarde, e a compra caía dentro da semana que se queria medir em regime.
func _construir(perfil: Dictionary) -> int:
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
		var custo := int(GS.ESTRUTURAS[id]["custo"])
		GS.comprar_estrutura(id)
		return custo if GS.tem_estrutura(id) else 0   # uma por turno
	return 0


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
