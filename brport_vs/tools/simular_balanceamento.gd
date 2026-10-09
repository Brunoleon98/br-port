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
#   chance_esquecer_doca — por berço livre, por turno: deixou o berço vazio
#     com barco ao largo (distração, achou que já tinha atracado). Até à
#     `083` era "deixou o barco atracado sem trabalhador".
#   escolha — QUE barco da fila ele chama primeiro (`083`), e é aqui que
#     jogar bem passou a ser escolher e não só lembrar:
#     "rende_por_dia" o maior valor por dia de berço — um navio de 88.000 que
#              prende o berço três dias rende menos por dia do que um
#              pesqueiro de 28.000 que sai no mesmo;
#     "maior_valor"   o maior valor, sem olhar quanto tempo prende o berço;
#     "ordem"         o primeiro que chegou.
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
#   quita_adiantado — tenta `pagar_parcela_adiantado()` a cada turno em que o
#     caixa dê. Só o quarto perfil o faz; ver o bloco abaixo.
#
# ⚠️ O QUARTO PERFIL EXISTE PORQUE O INSTRUMENTO ERA CEGO, e não por gosto.
# O item 24 do playtest pede desconto por quitar a dívida antes do prazo, e
# medi-lo era impossível: os três perfis acima só resolvem a fase
# "debt_payment", ou seja **nenhum deles quita adiantado nunca**. Varrer um
# desconto daria LINHA RETA — e linha reta aqui não é "não importa", é a mesma
# família do defeito injetado numa regra que o teste não exercita.
#
# E ele é um QUARTO em vez de uma mudança nos três porque mexer nos três
# re-baseia as taxas medidas (as do `CLAUDE.md`) mesmo com desconto ZERO: um perfil que
# gasta a parcela antes do prazo deixa de ter esse dinheiro para construir, e
# a medição em vigor deixaria de descrever o que descreve. Acrescentar é
# seguro por construção — as sementes saem de `semente + run * K`, derivadas
# do índice da PARTIDA e não do estado acumulado, e é por isso que o
# comentário do laço promete "trocar de perfil e continuar caindo nos MESMOS
# barcos".
const PERFIS := [
	{
		"nome": "Ótimo",
		"descricao": "enche todo berço com o barco que mais rende por dia, negocia o meio-termo e recua a tempo, compra o upgrade assim que dá",
		"chance_esquecer_doca": 0.0,
		"escolha": "rende_por_dia",
		"estilo_negociacao": "otimo",
		"chance_igualar_rival": 1.0,
		"folga_para_upgrade": 1.0,
		"quita_adiantado": false,
	},
	{
		"nome": "Mediano",
		"descricao": "deixa um berço vazio de vez em quando, chama o barco mais caro, arrisca na negociação às vezes",
		"chance_esquecer_doca": 0.15,
		"escolha": "maior_valor",
		"estilo_negociacao": "medio",
		"chance_igualar_rival": 0.70,
		"folga_para_upgrade": 2.0,
		"quita_adiantado": false,
	},
	{
		"nome": "Descuidado",
		"descricao": "deixa berço vazio com frequência, chama quem chegou primeiro, teima em segurar o preço até perder o cliente",
		"chance_esquecer_doca": 0.35,
		"escolha": "ordem",
		"estilo_negociacao": "ruim",
		"chance_igualar_rival": 0.40,
		"folga_para_upgrade": 4.0,
		"quita_adiantado": false,
	},
	# ⚠️ CLONE EXATO DO MEDIANO, e a única diferença é a antecipação. É o que
	# torna a leitura atribuível: qualquer vão entre os dois é da dívida paga
	# antes, e de mais nada.
	#
	# Na escolha original (`019`), o Mediano era o único dos três com espaço para o
	# desconto mover algo. O Ótimo satura em 100% e não discrimina (a mesma
	# armadilha da barra de reputação que já estava no teto quando se foi
	# afiná-la); o Descuidado fecha com mediana de R$503.039 contra uma parcela
	# de R$530.000 — abaixo dela —, logo quase nunca teria como antecipar, e
	# mediria a ausência de oportunidade em vez do efeito do desconto.
	# Com a primeira parcela acessível (`084`), todos podem antecipar. O clone
	# continua útil: mede quitar cedo e sacrificar caixa de reconstrução,
	# comparado ao mesmo jogador que espera até ao vencimento.
	{
		"nome": "Antecipado",
		"descricao": "o Mediano que quita a parcela assim que o caixa dá, em vez de esperar o vencimento",
		"chance_esquecer_doca": 0.15,
		"escolha": "maior_valor",
		"estilo_negociacao": "medio",
		"chance_igualar_rival": 0.70,
		"folga_para_upgrade": 2.0,
		"quita_adiantado": true,
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
	# Uma opção explícita mantém a medição tradicional. O par de JSONs,
	# com as mesmas sementes, prova que retirar I/O não mudou a simulação.
	var sem_save := args.has("--sem-save")
	if sem_save:
		GS = load("res://tools/estado_simulado.gd").new()
	var partidas := PARTIDAS_PADRAO
	var semente := SEMENTE_PADRAO
	if args.size() >= 1 and args[0].is_valid_int():
		partidas = int(args[0])
	if args.size() >= 2 and args[1].is_valid_int():
		semente = int(args[1])

	print("=== BR Port VS — simulação de balanceamento ===")
	print("%d partidas por perfil · semente %d" % [partidas, semente])
	print("Fase 1: %d semanas, cobranças nos dias %d/%d/%d" % [
		GS.WEEKS_TOTAL, GS.PARCELA_DUE_TURN, GS.PARCELA_DUE_TURN * 2, GS.PARCELA_DUE_TURN * 3])
	print("")
	_avisar_se_amostra_curta(partidas)

	var resultados := []
	for perfil in PERFIS:
		resultados.append(_simular_perfil(perfil, partidas, semente))
		print("Perfil %s medido." % perfil["nome"])

	_imprimir_tabela(resultados, partidas)
	_imprimir_cobrancas(resultados, partidas)
	_imprimir_regime(resultados)
	_imprimir_fila(resultados)
	_imprimir_reputacao(resultados)
	_imprimir_motivos(resultados)
	var leitura_ok := _imprimir_diagnostico(resultados)

	# O despejo em JSON existe para o projetor das Parcelas 2 e 3
	# (tools/projetar_parcelas.py) ter contra o que se calibrar. Sem ele o
	# projetor seria um segundo modelo da economia, sem nada que o obrigasse a
	# concordar com o jogo — que é exatamente como o modelo do GDD chegou a
	# acumular R$1.480 contra uma parcela de R$8.000.
	var despejo_ok := true
	for a in args:
		if a.ends_with(".json"):
			despejo_ok = _despejar_json(a, resultados, partidas, semente)
			break
	# De novo no fim: log de CI se lê de baixo para cima, e o aviso do
	# cabeçalho fica a centenas de linhas de distância da conclusão.
	_avisar_se_amostra_curta(partidas)
	# O despejo e os avisos vêm ANTES de encerrar mal, de propósito: quem tem de
	# diagnosticar uma recusa precisa da medição que a produziu.
	if sem_save:
		GS.free()
	quit(0 if leitura_ok and despejo_ok else 1)


# A economia semana a semana. A média das 4 semanas esconde o que interessa:
# a semana 1 é obra (o caixa SAI), e a última é o porto em regime. Projetar as
# Fases 2 e 3 a partir da média das quatro seria projetar a partir de um porto
# que só existe durante a Fase 1.
# A reputação está a DISCRIMINAR? Pendurar uma mecânica nela só faz sentido se
# ela variar entre jogadores e ao longo da partida. Se estiver no teto quando a
# decisão acontece, o efeito é um bónus fixo para toda a gente — que é o mesmo
# que não existir, com mais código.
# A MISTURA DE CLASSES E DE MOTIVOS que o jogo sorteou de verdade, contra a que
# os pesos prometem. Existe porque o peso e a frequência não são a mesma coisa:
# desde 06/09 a CLASSE do navio está travada pelo nível do porto, então quem
# não levanta o porto nunca vê as classes de cima — e vê, em troca, mais
# pesqueiro do que o peso dele diz. Sem esta tabela, um peso escrito errado e
# uma mistura deslocada pela TRAVA leem-se igual.
func _imprimir_motivos(resultados: Array) -> void:
	print("=== Mistura de classes (navios que chegaram) ===")
	var classes: Array = GS.CLASSES_DE_NAVIO.keys()
	var cab := "%-12s │ %8s" % ["Perfil", "navios"]
	for id in classes:
		cab += " │ %19s" % String(GS.CLASSES_DE_NAVIO[id]["nome"])
	print(cab)
	for r in resultados:
		var c: Dictionary = r["classes"]
		var total := 0
		for id in classes:
			total += int(c.get(id, 0))
		var linha := "%-12s │ %8d" % [r["perfil"]["nome"], total]
		for id in classes:
			linha += " │ %18.1f%%" % (100.0 * float(int(c.get(id, 0))) / maxf(1.0, float(total)))
		print(linha)
	print("")

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


# A FILA ESTÁ A PEDIR ESCOLHA? (`083`) Um dia "com escolha" tem mais barcos
# prontos ao largo do que berços livres: alguém fica de fora, e o jogador
# decide quem. "Berço à espera" é o contrário — havia berço e não havia barco.
# Se a primeira coluna cair para perto de zero, a fila voltou a ser o jogo de
# antes: atraca-se tudo o que chega, e o toque é tarefa outra vez.
func _imprimir_fila(resultados: Array) -> void:
	print("=== A fila no fundeadouro (dias com berço livre) ===")
	print("%-12s │ %12s │ %15s │ %11s │ %9s" % ["Perfil", "Com escolha", "Berço à espera",
		"Desistiram", "Prêmio"])
	for r in resultados:
		print("%-12s │ %11.1f%% │ %14.1f%% │ %11.1f │ %8.3fx" % [
			r["perfil"]["nome"], 100.0 * float(r["dias_com_escolha"]),
			100.0 * float(r["dias_sem_barco"]), float(r["desistencias_medio"]),
			float(r["premio_da_escolha"])])
	print("  Prêmio = valor médio do barco ATRACADO sobre o do barco que CHEGA.")
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
	print("  Margem operacional = delta de caixa + gastos em obras e parcelas da")
	print("  mesma semana. O perfil que compra tarde tem a compra dentro da semana")
	print("  que se quer medir, e sem separar as duas coisas ele parece render")
	print("  metade do que rende.")
	print("")


func _operacional(r: Dictionary, semana: int) -> float:
	var m: Array = r["margem_por_semana"]
	var o: Array = r["obra_por_semana"]
	if semana < 0 or semana >= m.size():
		return 0.0
	var p: Array = r["parcela_por_semana"]
	return float(m[semana]) + float(o[semana]) + float(p[semana])


func _despejar_json(caminho: String, resultados: Array, partidas: int, semente: int) -> bool:
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
			"parcela_por_semana": r["parcela_por_semana"],
			"cobrancas": r["cobrancas"],
			"caixa_final_mediana": r["caixa_final_mediana"],
			"caixa_final_distribuicao": r["caixa_final_distribuicao"],
			"travadas": r["travadas"],
			"atendidos_em_regime": 0.0 if b.is_empty() else b[b.size() - 1],
			"estruturas": r["estruturas"],
			"estado_em_regime": r["estado_em_regime"],
			"niveis": r["niveis"],
			"docas_medias": r["docas_medias"],
			"trabalhadores_medios": r["trabalhadores_medios"],
			"antecipou_fracao": r["antecipou_fracao"],
			"turno_de_antecipacao_mediana": r["turno_de_antecipacao_mediana"],
			"premio_da_escolha": r["premio_da_escolha"],
			"premio_em_regime": r["premio_em_regime"],
		}
	var f := FileAccess.open(caminho, FileAccess.WRITE)
	if f == null:
		push_error("Não consegui escrever a medição em %s" % caminho)
		return false
	f.store_string(JSON.stringify({
		"partidas": partidas,
		"semente": semente,
		"parcela": GS.PARCELA_AMOUNT,
		"parcelas": [GS.PARCELA_AMOUNT, GS.PARCELA_2_AMOUNT, GS.PARCELA_3_AMOUNT],
		"vencimentos": [GS.PARCELA_DUE_TURN, GS.PARCELA_DUE_TURN * 2, GS.PARCELA_DUE_TURN * 3],
		"semanas": GS.WEEKS_TOTAL,
		"turnos_por_semana": GS.TURNS_PER_WEEK,
		"caixa_inicial": GS.START_CASH,
		"perfis": perfis,
	}, "  ", true) + "\n")
	f.close()
	print("Medição despejada em %s" % caminho)
	print("")
	return true


# Cada vencimento tem sua própria amostra: quem perde na segunda não pode
# aparecer como zero reais na terceira. Pagamento antecipado é contado na
# decisão efetiva, e a chegada ao vencimento é uma observação separada.
func _imprimir_cobrancas(resultados: Array, partidas: int) -> void:
	print("=== As três cobranças dentro da Fase 1 ===")
	print("Perfil | parcela | dia | chegaram / total | pagaram / total | anteciparam | caixa na decisão | saldo após pagar")
	for r in resultados:
		for c in r["cobrancas"]:
			print("%s | %d | %d | %d/%d | %d/%d | %d | R$%d | R$%d" % [
				r["perfil"]["nome"], c["numero"], c["dia"], c["chegaram"], partidas,
				c["pagaram"], partidas, c["anteciparam"], c["caixa_na_decisao_mediana"],
				c["saldo_apos_pagar_mediana"]])
	print("  Caixa e saldo são medianas das decisões observadas; antecipação ocorre antes do vencimento.")
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
	print("    CLAUDE.md (medidas em 600 partidas, e é lá que elas vivem): a diferença")
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
	var parcela_por_semana := []
	var cobrancas := []
	for i in range(GS.PARCELAS_NA_FASE):
		cobrancas.append({"chegaram": 0, "pagaram": 0, "anteciparam": 0,
			"caixas_na_decisao": [], "saldos_apos_pagar": []})
	var atendidos_por_semana := []
	var amostras_por_semana := []
	# Em quantas partidas cada estrutura acabou de pé, e com quantas
	# docas/trabalhadores. Sem isto não dá para projetar as fases seguintes: o
	# perfil Descuidado quase nunca compra nada, e um modelo que suponha o
	# porto inteiro construído erra a margem dele em 98% — foi assim que este
	# campo passou a existir.
	var estruturas_de_pe := {}
	var estruturas_regime := {}
	var niveis_regime := {}
	var amostras_regime := 0
	var docas_regime := 0
	var trabalhadores_regime := 0
	var docas_totais := 0
	var trabalhadores_totais := 0
	var motivos_vistos := {}
	var classes_vistas := {}
	var niveis_atingidos := {}
	# ⚠️ SEM ESTES DOIS, A MEDIÇÃO DO ITEM 24 FICA CEGA OUTRA VEZ. Se a taxa do
	# Antecipado não se mexer, há duas explicações incompatíveis — o desconto não
	# importa, ou ele nunca conseguiu antecipar — e sem contar as antecipações
	# não há como escolher entre elas. É o mesmo erro que o perfil existe para
	# corrigir, um andar acima.
	var antecipou := 0
	var turnos_de_antecipacao := []
	var dias_decisao := 0
	var dias_escolha := 0
	var dias_sem_barco := 0
	var desistencias := 0
	# O PRÊMIO DA ESCOLHA (`083`): o valor médio do barco que o perfil ATRACA
	# sobre o do barco que CHEGA, em valor bruto (antes do Arlindo, que o
	# projetor desconta à parte). Com a fila quem escolhe o mais caro recebe
	# mais por barco do que a média da faixa, e o projetor, que contava a média,
	# reprovou o Mediano por 5,5% — um efeito que deixou de ser global. [soma, n]
	var atracados := [0.0, 0]
	var chegados := [0.0, 0]
	var atracados_em_regime := [0.0, 0]
	var chegados_em_regime := [0.0, 0]

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
		var parcela_semana := []
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
		var pago_anterior := 0
		var antecipou_na_partida := false
		var atracados_no_inicio: Array = atracados.duplicate()
		var chegados_no_inicio: Array = chegados.duplicate()
		var atendidos_anterior := 0
		var obra_na_semana := 0
		var reputacao_nas_ofertas := []
		var apostas := [0, 0]        # [feitas, ganhas]
		# [dias de decisão, dias com mais barcos prontos do que berços livres,
		#  dias com berço livre e fila vazia]. É a pergunta da `083`: em quantos
		# dias o jogador ESCOLHE. Sem ela, a fila podia passar no balanceamento
		# a atracar tudo o que chega, que é o jogo de antes com outra roupa.
		var dias_de_escolha := [0, 0, 0]

		while GS.phase != "game_over" and seguranca < 300:
			seguranca += 1
			_contar_motivos(motivos_vistos, classes_vistas, ids_vistos, chegados)

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
				var cobranca: Dictionary = cobrancas[GS.parcela_indice]
				cobranca["caixas_na_decisao"].append(GS.cash)
				var valor: int = GS.principal_da_parcela()
				if GS.cash >= valor:
					GS.pay_debt()
					cobranca["pagaram"] += 1
					cobranca["saldos_apos_pagar"].append(GS.cash)
					# A semana só fecha depois da escolha. O pagamento pertence
					# à semana vencida, nunca à seguinte nem ao regime operacional.
					caixa_semana[-1] -= valor
					parcela_semana[-1] += valor
					caixa_anterior -= valor
					pago_anterior += valor
				else:
					GS.fail_debt()
				continue

			obra_na_semana += _construir(perfil)

			# ⚠️ DEPOIS DA OBRA, e a ordem é desenho e não acaso. Quitar antes de
			# construir faria o Antecipado diferir do Mediano em DUAS coisas — a
			# antecipação e a prioridade de obra —, e a leitura não saberia de
			# qual delas é o vão. O comentário do `pagar_parcela_adiantado()` já
			# nomeia essa tensão: o mesmo caixa também compra estrutura. Aqui ele
			# constrói como o Mediano e quita com o que sobra.
			if perfil["quita_adiantado"] and GS.pode_pagar_parcela_adiantado():
				var cobranca: Dictionary = cobrancas[GS.parcela_indice]
				var dinheiro: int = GS.cash
				if GS.pagar_parcela_adiantado():
					if not antecipou_na_partida:
						antecipou += 1
					antecipou_na_partida = true
					cobranca["pagaram"] += 1
					cobranca["anteciparam"] += 1
					cobranca["caixas_na_decisao"].append(dinheiro)
					cobranca["saldos_apos_pagar"].append(GS.cash)
					turnos_de_antecipacao.append(GS.turn)

			_medir_escolha(dias_de_escolha)
			_atracar(perfil, rng, atracados)
			var semana_antes: int = GS.current_week()
			var indice_antes: int = GS.parcela_indice
			var vence_hoje: bool = GS.turn == GS.vencimento_da_parcela()
			GS.advance_turn()
			if vence_hoje:
				cobrancas[indice_antes]["chegaram"] += 1
			# O fecho de semana acontece DENTRO do advance_turn, então a leitura
			# tem de ser depois dele — e só quando a semana virou de verdade.
			if GS.current_week() != semana_antes:
				if semana_antes == GS.WEEKS_TOTAL:
					# A margem é de quem completou esta semana, não de quem perdeu
					# meses antes. Misturar as duas populações distorce a calibração.
					amostras_regime += 1
					docas_regime += GS.docks.size()
					trabalhadores_regime += GS.workers.size()
					var nivel: int = GS.nivel_do_porto()
					niveis_regime[nivel] = int(niveis_regime.get(nivel, 0)) + 1
					for id in GS.ESTRUTURAS:
						if GS.tem_estrutura(id):
							estruturas_regime[id] = int(estruturas_regime.get(id, 0)) + 1
					for j in range(2):
						atracados_em_regime[j] += atracados[j] - atracados_no_inicio[j]
						chegados_em_regime[j] += chegados[j] - chegados_no_inicio[j]
				atracados_no_inicio = atracados.duplicate()
				chegados_no_inicio = chegados.duplicate()
				caixa_semana.append(GS.cash - caixa_anterior)
				obra_semana.append(obra_na_semana)
				parcela_semana.append(GS.total_pago_parcelas - pago_anterior)
				pago_anterior = GS.total_pago_parcelas
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
		dias_decisao += int(dias_de_escolha[0])
		dias_escolha += int(dias_de_escolha[1])
		dias_sem_barco += int(dias_de_escolha[2])
		desistencias += int(GS.metrics["fila_desistiu"])
		for id in GS.ESTRUTURAS:
			if GS.tem_estrutura(id):
				estruturas_de_pe[id] = int(estruturas_de_pe.get(id, 0)) + 1
		# A que NÍVEL o porto chegou. Não se deduz das frações de estrutura:
		# o nível 2 é "duas estruturas quaisquer", e somar frações de coisas
		# diferentes não diz em quantas partidas houve DUAS ao mesmo tempo.
		# O projetor precisa deste número desde 06/09, porque é ele que diz
		# quais classes de navio o porto chegou a receber.
		var nv := int(GS.nivel_do_porto())
		niveis_atingidos[nv] = int(niveis_atingidos.get(nv, 0)) + 1
		docas_totais += GS.docks.size()
		trabalhadores_totais += GS.workers.size()
		for w in range(caixa_semana.size()):
			while margem_por_semana.size() <= w:
				margem_por_semana.append(0)
				obra_por_semana.append(0)
				parcela_por_semana.append(0)
				atendidos_por_semana.append(0)
				amostras_por_semana.append(0)
			margem_por_semana[w] += int(caixa_semana[w])
			obra_por_semana[w] += int(obra_semana[w])
			parcela_por_semana[w] += int(parcela_semana[w])
			atendidos_por_semana[w] += int(atendidos_semana[w])
			amostras_por_semana[w] += 1

	for i in range(cobrancas.size()):
		var c: Dictionary = cobrancas[i]
		c["numero"] = i + 1
		c["dia"] = GS.PARCELA_DUE_TURN * (i + 1)
		c["caixa_na_decisao_mediana"] = _mediana(c["caixas_na_decisao"])
		c["saldo_apos_pagar_mediana"] = _mediana(c["saldos_apos_pagar"])
		c["caixa_na_decisao_distribuicao"] = _distribuicao_caixa(c["caixas_na_decisao"])
		c["saldo_apos_pagar_distribuicao"] = _distribuicao_caixa(c["saldos_apos_pagar"])
		c.erase("caixas_na_decisao")
		c.erase("saldos_apos_pagar")
	return {
		"perfil": perfil,
		"vitorias": vitorias,
		"quebrou_antes": quebrou_antes,
		"chegou_sem_dinheiro": chegou_sem_dinheiro,
		"caixa_vencimento_mediana": _mediana(caixas_no_vencimento),
		"caixa_final_mediana": _mediana(caixas_finais),
		"caixa_final_distribuicao": _distribuicao_caixa(caixas_finais),
		"atendidos_medio": float(atendidos) / float(partidas),
		"perdidos_medio": float(perdidos) / float(partidas),
		"reputacao_media": reputacoes / float(partidas),
		"travadas": travadas,
		"margem_por_semana": _media_por_semana(margem_por_semana, amostras_por_semana),
		"obra_por_semana": _media_por_semana(obra_por_semana, amostras_por_semana),
		"parcela_por_semana": _media_por_semana(parcela_por_semana, amostras_por_semana),
		"cobrancas": cobrancas,
		"atendidos_por_semana": _media_por_semana(atendidos_por_semana, amostras_por_semana),
		"estruturas": _fracao_de_pe(estruturas_de_pe, partidas),
		"estado_em_regime": {"n": amostras_regime,
			"estruturas": _fracao_de_pe(estruturas_regime, maxi(1, amostras_regime)),
			"niveis": _fracao_dos_niveis(niveis_regime, maxi(1, amostras_regime)),
			"docas_medias": float(docas_regime) / maxi(1, amostras_regime),
			"trabalhadores_medios": float(trabalhadores_regime) / maxi(1, amostras_regime)},
		"niveis": _fracao_dos_niveis(niveis_atingidos, partidas),
		"reputacao_nas_ofertas": reputacoes_de_oferta,
		"apostas_feitas": apostas_feitas,
		"apostas_ganhas": apostas_ganhas,
		"docas_medias": float(docas_totais) / float(partidas),
		"trabalhadores_medios": float(trabalhadores_totais) / float(partidas),
		"motivos": motivos_vistos,
		"classes": classes_vistas,
		"antecipou": antecipou,
		"antecipou_fracao": float(antecipou) / float(partidas),
		"turno_de_antecipacao_mediana": _mediana(turnos_de_antecipacao),
		"dias_com_escolha": float(dias_escolha) / maxf(1.0, float(dias_decisao)),
		"dias_sem_barco": float(dias_sem_barco) / maxf(1.0, float(dias_decisao)),
		"desistencias_medio": float(desistencias) / float(partidas),
		"premio_da_escolha": (float(atracados[0]) / maxf(1.0, float(atracados[1]))) \
			/ maxf(1.0, float(chegados[0]) / maxf(1.0, float(chegados[1]))),
		# A margem é da última semana. Usar a seleção da partida inteira
		# misturava o porto em ruínas com o reconstruído e errava o Antecipado.
		"premio_em_regime": (float(atracados_em_regime[0]) / maxf(1.0, float(atracados_em_regime[1]))) \
			/ maxf(1.0, float(chegados_em_regime[0]) / maxf(1.0, float(chegados_em_regime[1]))),
	}


# Anota a classe e o motivo de cada barco NOVO que está em doca. `ids_vistos` é
# por partida: o `_uid` do GameState recomeça a cada `new_game()`, então guardar
# os ids entre partidas juntaria barcos diferentes com o mesmo número.
func _contar_motivos(acumulado: Dictionary, classes: Dictionary,
		ids_vistos: Dictionary, valores: Array) -> void:
	# Desde a `083` o barco NASCE ao largo, e quem desiste lá nunca chega a
	# doca nenhuma: contar só as docas tiraria da mistura exatamente os que o
	# jogador deixou ir, e a mistura publicada é a de quem CHEGA.
	var barcos: Array = GS.fila.duplicate()
	for i in range(GS.docks.size()):
		barcos.append(GS.docks[i]["boat"])
	for barco in barcos:
		if barco == null:
			continue
		var id: int = int(barco["id"])
		if ids_vistos.has(id):
			continue
		ids_vistos[id] = true
		var motivo: String = String(barco["motivo"])
		acumulado[motivo] = int(acumulado.get(motivo, 0)) + 1
		var classe: String = String(barco["classe"])
		classes[classe] = int(classes.get(classe, 0)) + 1
		valores[0] += float(barco["value"])
		valores[1] += 1


# Em que fração das partidas o porto acabou em cada nível. A chave é texto
# porque o JSON não tem chave inteira, e o projetor lê-a do outro lado.
func _fracao_dos_niveis(contagem: Dictionary, partidas: int) -> Dictionary:
	var out := {}
	for nivel in [1, 2, 3]:
		out[str(nivel)] = float(int(contagem.get(nivel, 0))) / float(partidas)
	return out


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


# Enche os berços livres com barcos da fila, pela ordem de escolha do perfil.
# Espelha o toque do jogador — passa por `atracar()`, que é quem valida.
func _atracar(perfil: Dictionary, rng: RandomNumberGenerator, atracados: Array) -> void:
	var livres: int = GS.bercos_livres()
	for _b in range(livres):
		if rng.randf() < float(perfil["chance_esquecer_doca"]):
			continue
		var escolhido := _escolher_barco(String(perfil["escolha"]))
		if escolhido < 0:
			return
		var valor := float(GS.fila[escolhido]["value"])
		if GS.atracar(escolhido, false):
			atracados[0] += valor
			atracados[1] += 1


func _escolher_barco(estilo: String) -> int:
	var melhor := -1
	var melhor_nota := -INF
	for i in range(GS.fila.size()):
		if not GS.barco_pronto(i):
			continue
		var b: Dictionary = GS.fila[i]
		var valor := float(b["matched_value"]) if b.get("matched", false) else float(b["value"])
		var nota := 0.0
		match estilo:
			"rende_por_dia":
				var dias: int = GS._turnos_de_operacao(String(b["classe"]), String(b["motivo"]))
				# Empate desfaz-se pelo que sai amanhã: a paciência pesa menos
				# do que um real por dia, e só decide entre iguais.
				nota = valor / float(dias) - float(b["paciencia"]) * 0.001
			"maior_valor":
				nota = valor
			_:
				# "ordem": o primeiro que chegou é o primeiro da lista.
				return i
		if nota > melhor_nota:
			melhor_nota = nota
			melhor = i
	return melhor


# Antes de atracar: há mais barcos prontos do que berços livres? É o dia em que
# o jogador escolhe. Berço livre e fila vazia é o outro lado — o porto à espera
# de barco, onde a escolha não existe.
func _medir_escolha(contador: Array) -> void:
	var livres: int = GS.bercos_livres()
	if livres <= 0:
		return
	var prontos := 0
	for i in range(GS.fila.size()):
		if GS.barco_pronto(i):
			prontos += 1
	contador[0] += 1
	if prontos > livres:
		contador[1] += 1
	elif prontos == 0:
		contador[2] += 1


# Quantis empíricos por índice floor(n*p), a mesma mediana superior já usada.
# A amostra acompanha o número: saldo de quem pagou não representa quem perdeu
# antes, e vazio é ausência de observação, nunca caixa zero (`085`).
func _distribuicao_caixa(valores: Array) -> Dictionary:
	if valores.is_empty():
		return {"n": 0, "p10": null, "p50": null, "p90": null}
	var ordenado := valores.duplicate()
	ordenado.sort()
	var n := ordenado.size()
	return {"n": n, "p10": int(ordenado[mini(n - 1, int(n * 0.1))]),
		"p50": int(ordenado[int(n / 2)]), "p90": int(ordenado[mini(n - 1, int(n * 0.9))])}


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
	print("  Chegou curto  = chegou ao Sr. Ribeiro sem dinheiro para a cobrança ativa.")
	print("")

	for r in resultados:
		var margem := _margem_de_erro(float(r["vitorias"]) / float(partidas), partidas)
		print("· %s — %s" % [r["perfil"]["nome"], r["perfil"]["descricao"]])
		print("    taxa de vitória %.1f%% ± %.1f  ·  caixa no último vencimento alcançado (mediana) R$%d  ·  reputação final média %.0f" % [
			100.0 * float(r["vitorias"]) / float(partidas), margem,
			int(r["caixa_vencimento_mediana"]), float(r["reputacao_media"])])
		# Só para quem tenta antecipar, e a linha é o que impede a leitura de
		# confundir "o desconto não importa" com "ele nunca antecipou".
		if bool(r["perfil"]["quita_adiantado"]):
			print("    ANTECIPOU em %.1f%% das partidas (%d de %d), no dia %d (mediana das antecipações em %d dias)" % [
				100.0 * float(r["antecipou_fracao"]), int(r["antecipou"]), partidas,
				int(r["turno_de_antecipacao_mediana"]), GS.TURNS_TOTAL])
			# ⚠️ E A MEDIANA DO VENCIMENTO ACIMA NÃO SE COMPARA COM A DOS OUTROS
			# PERFIS. Quem antecipa não entra na fase "debt_payment" (o
			# `_set_phase` dela exige `not parcela_paid`), então aquele número é
			# lido SÓ nas partidas em que ele não conseguiu antecipar — que são
			# justamente as mais pobres, onde nunca juntou a parcela. É uma
			# sub-amostra enviesada pelo próprio tratamento, e ler 509.403
			# contra os 716.179 do Mediano como "antecipar custa 207.000" seria
			# falso. Quem se compara é o caixa FINAL, contado em toda partida.
			print("    (a mediana do vencimento acima é só das %d partidas SEM antecipação"
				% [partidas - int(r["antecipou"])])
			print("     — o número comparável entre perfis é o caixa FINAL: R$%d)"
				% [int(r["caixa_final_mediana"])])
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


# A conclusão vive em `leitura_do_simulador.gd` para poder ser provada sem se
# rodarem 4 perfis × 600 partidas. Aqui só se imprime o que ela devolveu, e o
# `false` dela encerra o simulador com código 1 — ver o comentário de lá.
#
# `load()` e não `preload`: num `--script` um `preload` de script compila antes
# de a árvore estar de pé, e o que sai não é erro de compilação, é um GDScript
# vazio que só se denuncia na chamada. Aquele arquivo não fala do autoload, mas
# a receita barata é a mesma dos outros.
func _imprimir_diagnostico(resultados: Array) -> bool:
	var Leitura := load("res://tools/leitura_do_simulador.gd")
	var leitura: Dictionary = Leitura.ler(resultados)
	for linha in leitura["linhas"]:
		print(linha)
	return bool(leitura["ok"])
