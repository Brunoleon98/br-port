extends "res://tools/simular_balanceamento.gd"

# Régua do recorte 2 da `103`, sem antecipar a meta da etapa 3. Joga desde
# o dia 1: não inventa dinheiro nem porto à entrada da Fase 2. As escolhas
# e as folgas são as do simulador; a treliça vem antes do terceiro píer,
# pois é ela que abre o serviço de dois dias que esta régua quer alcançar.
# Uso: --script res://tools/medir_trelica.gd -- 600 20260825 saida.json
const ORDEM_DA_FASE_2 := ["pier_2", "patio", "armazem", "trelica", "pier_3", "escritorio"]
const DIAS_OBSERVADOS := 56
var _primeiro_cargueiro := -1


func _rodar() -> void:
	GS = load("res://tools/estado_simulado.gd").new()
	GS.contrato_fechado.connect(_serviu)
	var args := OS.get_cmdline_user_args()
	var n := int(args[0]) if args.size() > 0 else 600
	var semente := int(args[1]) if args.size() > 1 else 20260825
	var saida := String(args[2]) if args.size() > 2 else ""
	var resultados := []
	for perfil in PERFIS:
		var linhas := []
		for partida in range(n):
			linhas.append(_jogar(perfil, semente, partida))
		resultados.append({"perfil": perfil["nome"], "partidas": linhas})
	var dados := {"n": n, "semente": semente, "dias_observados": DIAS_OBSERVADOS,
		"preco": GS.ESTRUTURAS["trelica"]["custo"], "dias_de_obra": GS.dias_da_obra("trelica", 2),
		"ordem_da_fase_2": ORDEM_DA_FASE_2, "resultados": resultados}
	var arquivo := FileAccess.open(saida, FileAccess.WRITE)
	if arquivo == null:
		push_error("medir_trelica: não abriu a saída")
		quit(1)
		return
	arquivo.store_string(JSON.stringify(dados, "\t"))
	arquivo.close()
	GS.free()
	print("TRELICA MEDIDA: %d partidas por perfil, %d dias na Fase 2" % [n, DIAS_OBSERVADOS])
	quit(0)


func _serviu(_valor: int, classe: String) -> void:
	if GS.numero_da_fase == 2 and classe == "medio" and _primeiro_cargueiro < 0:
		_primeiro_cargueiro = GS.turn


func _jogar(perfil: Dictionary, semente: int, partida: int) -> Dictionary:
	GS._rng.seed = semente + partida * 7919
	var rng := RandomNumberGenerator.new()
	rng.seed = semente + partida * 104729
	GS.new_game()
	_primeiro_cargueiro = -1
	var entrada := -1
	var compra := -1
	var pronta := -1
	var caixa_na_compra := -1
	var menor_caixa := 2147483647
	var caixa_no_inicio := -1
	var margem := 0
	var servidos := 0
	var voltas := 0
	while GS.phase != GS.ESTADO_FIM and voltas < 600:
		voltas += 1
		if GS.numero_da_fase == 2 and entrada < 0:
			entrada = GS.turn
			caixa_no_inicio = GS.cash
			menor_caixa = GS.cash
		if entrada > 0 and GS.turn >= entrada + DIAS_OBSERVADOS:
			break
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
		if GS.numero_da_fase == 1:
			super._construir(perfil)
			if perfil["quita_adiantado"] and GS.pode_pagar_parcela_adiantado():
				GS.pagar_parcela_adiantado()
		else:
			_construir_fase_2(perfil)
			menor_caixa = mini(menor_caixa, int(GS.cash))
			if compra < 0 and GS.obra_em_andamento.get("id", "") == "trelica":
				compra = GS.turn
				caixa_na_compra = GS.cash
			if pronta < 0 and GS.tem_estrutura("trelica"):
				pronta = GS.turn
		_atracar(perfil, rng, [0.0, 0])
		var caixa_antes: int = GS.cash
		var atendidos: int = GS.metrics["boats_served"]
		var fase_antes: int = GS.numero_da_fase
		GS.advance_turn()
		if fase_antes == 2:
			margem += GS.cash - caixa_antes
			servidos += int(GS.metrics["boats_served"]) - atendidos
			menor_caixa = mini(menor_caixa, int(GS.cash))
	return {"entrada": entrada, "caixa_no_inicio": caixa_no_inicio,
		"compra": compra, "pronta": pronta, "caixa_na_compra": caixa_na_compra,
		"primeiro_cargueiro": _primeiro_cargueiro, "menor_caixa": menor_caixa,
		"caixa_final": GS.cash, "margem_operacional": margem, "servidos": servidos,
		"quebrou": GS.phase == GS.ESTADO_FIM, "dia_final": GS.turn, "voltas": voltas}


func _construir_fase_2(perfil: Dictionary) -> void:
	for id in ORDEM_DA_FASE_2:
		if GS.impedimento_estrutura(id) != "":
			continue
		if GS.cash < int(GS.ESTRUTURAS[id]["custo"] * float(perfil["folga_para_upgrade"])):
			continue
		GS.comprar_estrutura(id)
		return
