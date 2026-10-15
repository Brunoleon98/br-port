extends "res://tools/simular_balanceamento.gd"

# Etapa 4 da `103`: chega pelo dia 1 e conserva as escolhas dos quatro perfis.
# A janela limita a OBSERVAÇÃO, nunca a fase do jogo. Quem não alcança a meta
# nela é censurado, não derrotado. O jogo livre continua depois da conquista.
# Uso: --script res://tools/medir_fase_2.gd -- 600 20260825 saida.json 365 --sem-save
const ORDEM_FASE_2 := ["pier_2", "patio", "armazem", "trelica", "pier_3", "escritorio"]
const JANELA_PADRAO := 365
var _fechos := 0
var _meta_no_dia = null
var _fechos_cargueiro = null
var _sinais_meta := 0


func _avisar_se_amostra_curta(partidas: int) -> void:
	if partidas < PARTIDAS_PARA_MEDIR:
		print("⚠️ TESTE DE FUMAÇA, NÃO MEDIÇÃO — %d partidas por perfil." % partidas)
		print("Para medir a Fase 2: --script res://tools/medir_fase_2.gd -- 600 20260825 saida.json 365 --sem-save")


func _rodar() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() < 3 or not args[0].is_valid_int() or not args[1].is_valid_int():
		push_error("medir_fase_2: informe partidas, semente, saída.json e janela opcional")
		quit(1)
		return
	var n := int(args[0])
	var semente := int(args[1])
	var janela := int(args[3]) if args.size() > 3 and args[3].is_valid_int() else JANELA_PADRAO
	if n <= 0 or janela <= 0:
		push_error("medir_fase_2: partidas e janela precisam ser positivas")
		quit(1)
		return
	var sem_save := args.has("--sem-save")
	GS = load("res://tools/estado_simulado.gd").new() if sem_save else root.get_node("GameState")
	GS.fase_concluida.connect(_concluiu_fase)
	GS.contrato_fechado.connect(_serviu_cargueiro)
	var grupos := []
	var leitura = load("res://tools/leitura_fase_2.gd")
	print("=== BR Port — medição da Fase 2 ===")
	_avisar_se_amostra_curta(n)
	for perfil in PERFIS:
		var linhas := []
		for partida in range(n):
			linhas.append(_jogar_fase_2(perfil, semente, partida, janela))
		var resumo: Dictionary = leitura.resumir(linhas)
		grupos.append({"perfil": perfil["nome"], "resumo": resumo, "partidas": linhas})
		print("%s: entraram %d/%d · meta %d · quebras antes %d · censuradas %d · dias até a meta %s" % [
			perfil["nome"], resumo["entraram"], n, resumo["metas"],
			resumo["quebras_antes_meta"], resumo["censuradas"], resumo["dias_ate_meta"]])
	var dados := {"partidas_por_perfil": n, "semente": semente, "janela_dias": janela,
		"ordem_de_compra": ORDEM_FASE_2, "fase_2": GS.dados_da_fase(2).duplicate(true),
		"custos": {}, "resultados": grupos}
	for id in ORDEM_FASE_2:
		dados["custos"][id] = GS.ESTRUTURAS[id]["custo"]
	# Materializa antes de abrir o arquivo: falhar no resumo não trunca evidência.
	var texto := JSON.stringify(dados, "\t")
	var arquivo := FileAccess.open(args[2], FileAccess.WRITE)
	if arquivo == null:
		push_error("medir_fase_2: não abriu a saída")
		quit(1)
		return
	arquivo.store_string(texto)
	arquivo.close()
	if sem_save:
		GS.free()
	print("FASE 2 MEDIDA: %d partidas por perfil; %d fechos observados; sem prazo de jogo" % [n, janela])
	quit(0)


func _concluiu_fase(numero: int, _motivo: String) -> void:
	# O sinal da Fase 1 sai antes de trocar a fase; o da 2 não troca nem encerra.
	if numero == 2:
		_meta_no_dia = GS.turn
		_sinais_meta += 1


func _serviu_cargueiro(_valor: int, classe: String) -> void:
	if GS.numero_da_fase == 2 and classe == "medio" and _fechos_cargueiro == null:
		# O contrato fecha antes de incrementar turn, mas já é o fecho em curso.
		_fechos_cargueiro = _fechos + 1


func _jogar_fase_2(perfil: Dictionary, semente: int, partida: int, janela: int) -> Dictionary:
	GS.clear_save()
	GS._rng.seed = semente + partida * 7919
	var rng := RandomNumberGenerator.new()
	rng.seed = semente + partida * 104729
	GS.new_game()
	_fechos = 0
	_meta_no_dia = null
	_fechos_cargueiro = null
	_sinais_meta = 0
	var entrada = null
	var caixa_entrada = null
	var menor_caixa = null
	var caixa_meta = null
	var dias_meta = null
	var investimento := 0
	var dias_abaixo_piso := 0
	var suspensoes := 0
	var recuperacoes := 0
	var interrupcoes := 0
	var abaixo := false
	var obras := {}
	var prontas := {}
	var gasto := 0
	var voltas := 0
	# Cada dia tem no máximo uma oferta e uma cobrança: 6x deixa folga e recusa
	# travamento por estado desconhecido, sem chamar horizonte de prazo.
	var teto: int = (GS.turnos_da_fase(1) + janela + 1) * 6
	while GS.phase != GS.ESTADO_FIM and _fechos < janela and voltas < teto:
		voltas += 1
		if GS.numero_da_fase == 2 and entrada == null:
			entrada = GS.turn
			caixa_entrada = GS.cash
			menor_caixa = GS.cash
			abaixo = GS.reputation < GS.dados_da_fase(2)["piso_cargueiro"]
			for id in ORDEM_FASE_2:
				if GS.tem_estrutura(id):
					prontas[id] = 0
		if GS.phase == GS.ESTADO_OFERTA:
			_negociar(perfil, rng, [0, 0])
			continue
		if GS.phase == GS.ESTADO_COBRANCA:
			if GS.cash >= GS.principal_da_parcela():
				GS.pay_debt()
			elif GS.pode_pedir_segunda_chance():
				GS.aceitar_segunda_chance()
			else:
				GS.fail_debt()
			continue
		if GS.phase != GS.ESTADO_JOGANDO:
			push_error("medir_fase_2: estado sem política de decisão")
			break
		if GS.numero_da_fase == 1:
			_construir(perfil)
			if perfil["quita_adiantado"] and GS.pode_pagar_parcela_adiantado():
				GS.pagar_parcela_adiantado()
		else:
			gasto = _construir_na_fase_2(perfil)
			investimento += gasto
			menor_caixa = mini(menor_caixa, int(GS.cash))
			if gasto > 0:
				obras[GS.obra_em_andamento["id"]] = _fechos
		_atracar(perfil, rng, [0.0, 0])
		var fase_antes: int = GS.numero_da_fase
		var sequencia_antes: int = GS.dias_de_reputacao
		GS.advance_turn()
		if fase_antes == 2:
			_fechos += 1
			menor_caixa = mini(menor_caixa, int(GS.cash))
			if dias_meta == null and GS.meta_concluida:
				dias_meta = _fechos
				caixa_meta = GS.cash
			if sequencia_antes > 0 and GS.dias_de_reputacao == 0:
				interrupcoes += 1
			var novo_abaixo: bool = GS.reputation < GS.dados_da_fase(2)["piso_cargueiro"]
			if novo_abaixo:
				dias_abaixo_piso += 1
			if novo_abaixo != abaixo:
				if novo_abaixo:
					suspensoes += 1
				else:
					recuperacoes += 1
			abaixo = novo_abaixo
			for id in ORDEM_FASE_2:
				if not prontas.has(id) and GS.tem_estrutura(id):
					prontas[id] = _fechos
	var quebrou: bool = GS.phase == GS.ESTADO_FIM
	var travou := voltas >= teto or (not quebrou and _fechos < janela)
	if travou or _sinais_meta != int(GS.meta_concluida):
		push_error("medir_fase_2: travamento ou sinal de conquista incoerente")
	return {"partida": partida, "entrada": entrada, "caixa_entrada": caixa_entrada,
		"dias_ate_meta": dias_meta, "dia_meta": _meta_no_dia, "caixa_meta": caixa_meta,
		"fechos_ate_cargueiro": _fechos_cargueiro, "fechos_observados": _fechos,
		"quebrou": quebrou, "travou": travou, "dia_final": GS.turn,
		"caixa_final": GS.cash, "menor_caixa": menor_caixa, "investimento": investimento,
		"margem_operacional": GS.cash - caixa_entrada + investimento if entrada != null else null,
		"dias_abaixo_piso": dias_abaixo_piso, "suspensoes": suspensoes,
		"recuperacoes": recuperacoes, "interrupcoes_da_sequencia": interrupcoes,
		"inicios_de_obras": obras, "conclusoes_de_obras": prontas,
		"reputacao_final": GS.reputation, "dias_de_reputacao": GS.dias_de_reputacao,
		"primeiro_cargueiro": GS.primeiro_cargueiro, "estruturas_finais": GS.estruturas.duplicate()}


func _construir_na_fase_2(perfil: Dictionary) -> int:
	for id in ORDEM_FASE_2:
		if GS.impedimento_estrutura(id) != "":
			continue
		var custo: int = GS.ESTRUTURAS[id]["custo"]
		if GS.cash >= int(custo * float(perfil["folga_para_upgrade"])):
			return custo if GS.comprar_estrutura(id) else 0
	return 0
