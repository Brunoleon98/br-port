extends "res://tools/medir_fase_2.gd"

# Herda o percurso e a leitura da `108`. Só _atracar acrescenta escolhas na
# Fase 2; sem cancelamento, nenhum sorteio ou passo a mais muda o jogo.
# Uso: -- 600 20260825 saida.json 365 taxa 5 0.10 [--com-save]
var politica := "nenhuma"
var rng_cancelamento := RandomNumberGenerator.new()
var dias_com_opcao := 0
var pares_elegiveis := 0
var receita_entrada := 0
var servidos_entrada := 0
var perdidos_entrada := 0
var capturou_entrada := false


func _rodar() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() < 7:
		push_error("medir_cancelamento: faltam n, semente, saída, janela, política, reputação e multa")
		quit(1)
		return
	var n := int(args[0])
	var semente := int(args[1])
	var janela := int(args[3])
	politica = args[4]
	if n <= 0 or janela <= 0 or not politica in ["nenhuma", "taxa", "valor", "impulsivo", "uma"]:
		push_error("medir_cancelamento: parâmetros inválidos")
		quit(1)
		return
	GS = load("res://tools/estado_cancelamento_producao.gd" if args.has("--producao") else "res://tools/estado_cancelamento_experimental.gd").new()
	if args.has("--producao") and (float(args[5]) != 5.0 or float(args[6]) != 0.10):
		push_error("paridade de produção exige os custos aprovados")
		quit(1)
		return
	GS.gravar_autosave = args.has("--com-save")
	GS.save_path = ArmazemLocal.caminho("cancelamento_experimental.json")
	GS.perda_reputacao = float(args[5])
	GS.multa_fracao = float(args[6])
	GS.fase_concluida.connect(_concluiu_fase)
	GS.contrato_fechado.connect(_serviu_cargueiro)
	var grupos := []
	var leitura = load("res://tools/leitura_fase_2.gd")
	_avisar_se_amostra_curta(n)
	for perfil in PERFIS:
		var linhas := []
		for partida in range(n):
			linhas.append(_jogar_fase_2(perfil, semente, partida, janela))
		grupos.append({"perfil": perfil["nome"], "resumo": leitura.resumir(linhas), "partidas": linhas})
		print("CANCELAMENTO PERFIL: %s · %d partidas · %s" % [perfil["nome"], n, politica])
	var dados := {"n": n, "semente": semente, "janela": janela, "politica": politica,
		"perda_reputacao": GS.perda_reputacao, "multa_fracao": GS.multa_fracao,
		"resultados": grupos}
	var texto := JSON.stringify(dados)
	var arquivo := FileAccess.open(args[2], FileAccess.WRITE)
	if arquivo == null:
		push_error("medir_cancelamento: saída não abriu")
		quit(1)
		return
	arquivo.store_string(texto)
	arquivo.close()
	GS.free()
	print("CANCELAMENTO MEDIDO: %d por perfil · %s" % [n, politica])
	quit(0)


func _jogar_fase_2(perfil: Dictionary, semente: int, partida: int, janela: int) -> Dictionary:
	dias_com_opcao = 0
	pares_elegiveis = 0
	capturou_entrada = false
	rng_cancelamento.seed = semente + partida * 15485863
	var linha: Dictionary = super._jogar_fase_2(perfil, semente, partida, janela)
	linha["cancelamentos"] = GS.cancelamentos.duplicate(true)
	linha["dias_com_opcao"] = dias_com_opcao
	linha["pares_elegiveis"] = pares_elegiveis
	linha["multas"] = 0
	linha["receita_abandonada"] = 0
	for e in GS.cancelamentos:
		linha["multas"] += int(e["multa"])
		linha["receita_abandonada"] += int(e["receita_abandonada"])
		linha["menor_caixa"] = mini(linha["menor_caixa"], int(e["caixa_depois"]))
	linha["receita_fase_2"] = GS.metrics["revenue"] - receita_entrada if capturou_entrada else null
	linha["servidos_fase_2"] = GS.metrics["boats_served"] - servidos_entrada if capturou_entrada else null
	linha["perdidos_fase_2"] = GS.metrics["boats_lost"] - perdidos_entrada if capturou_entrada else null
	return linha


func _atracar(perfil: Dictionary, rng: RandomNumberGenerator, atracados: Array) -> void:
	if GS.numero_da_fase == 2 and not capturou_entrada:
		capturou_entrada = true
		receita_entrada = GS.metrics["revenue"]
		servidos_entrada = GS.metrics["boats_served"]
		perdidos_entrada = GS.metrics["boats_lost"]
	super._atracar(perfil, rng, atracados)
	if GS.numero_da_fase != 2 or GS.bercos_livres() > 0:
		return
	# Primeiro ocupa as vagas livres. Cancelar quando existe vaga não traz
	# capacidade adicional; a política não desperdiça contratos assim.
	var opcoes := []
	for d in range(GS.docks.size()):
		var antigo = GS.docks[d]["boat"]
		if antigo == null or int(antigo["progress"]) <= 0:
			continue
		var restante := int(antigo["op_turns"]) - int(antigo["progress"])
		for i in range(GS.fila.size()):
			if not GS.barco_pronto(i):
				continue
			var novo: Dictionary = GS.fila[i]
			var bruto := int(novo["matched_value"]) if novo.get("matched", false) else int(novo["value"])
			var receita: int = GS._lancar_receita(GS.DIA_ZERADO.duplicate(), bruto, String(novo["motivo"]))
			var dias: int = GS._turnos_de_operacao(String(novo["classe"]), String(novo["motivo"]))
			var liquido: int = receita - GS.multa_do_experimento(d)
			var nota := float(liquido) / dias - float(GS.receita_da_doca(d)) / restante
			if politica == "valor":
				nota = float(liquido - GS.receita_da_doca(d))
			opcoes.append({"doca": d, "fila": i, "uid": antigo["id"], "nota": nota,
				"receita_nova": receita, "dias_novos": dias, "restantes": restante})
	if opcoes.is_empty():
		return
	dias_com_opcao += 1
	pares_elegiveis += opcoes.size()
	if politica == "nenhuma":
		return
	var melhor: Dictionary = opcoes[0]
	for opcao in opcoes:
		if float(opcao["nota"]) > float(melhor["nota"]):
			melhor = opcao
	if politica in ["taxa", "valor"] and float(melhor["nota"]) <= 0:
		return
	if politica == "impulsivo" and rng_cancelamento.randf() >= 0.25:
		return
	if politica == "uma" and not GS.cancelamentos.is_empty():
		return
	# No máximo uma troca por dia. Mesmo o impulsivo escolhe o melhor par;
	# só ignora se a comparação seria favorável. Não conhece chegadas futuras.
	if not GS.cancelar_no_experimento(int(melhor["doca"]), int(melhor["uid"])):
		push_error("medir_cancelamento: cancelamento escolhido foi recusado")
		return
	var ultimo: Dictionary = GS.cancelamentos[-1]
	ultimo["alternativa"] = melhor.duplicate()
	# Reutiliza o verbo real, sem spawn ou avanço adicional.
	if not GS.atracar(int(melhor["fila"]), false):
		push_error("medir_cancelamento: trabalhador não ficou disponível para substituir")
