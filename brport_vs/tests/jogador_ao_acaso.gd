extends RefCounted

# T26 — O JOGADOR AO ACASO (`docs/decisoes/118`).
#
# AS OUTRAS GUARDAS PERGUNTAM O QUE ALGUÉM PENSOU EM PERGUNTAR. Cada bloco do
# `run_tests` monta um estado e confere uma resposta; o que nenhum bloco monta
# não se confere. Este joga partidas inteiras escolhendo AO ACASO entre as
# ações que o jogador tem — atracar, devolver, cancelar, construir, pagar,
# negociar, gravar e carregar —, e também as que o jogo deve recusar, e
# confere a cada passo propriedades que valem SEMPRE, seja qual for o
# caminho. É a prática que a pesquisa de 16/10 achou nos jogos: um robô com
# semente que joga o que é legal, invariantes a cada passo, e a falha reduzida
# à trilha mínima que a reproduz.
#
# ⚠️ OS INVARIANTES NÃO SE ESCREVEM A PARTIR DO CÓDIGO QUE CONFEREM. A lista
# do que a ida e volta do save tem de preservar (`retrato()`) está escrita
# AQUI, e não lida do `save_game()`: um campo que o save deixasse de gravar
# sumiria dos dois lados ao mesmo tempo, e o teste seria um espelho
# (`testes-e-guardas.md`, «a asserção que monta o esperado da mesma fonte»).
#
# ⚠️ E O ACASO É SEMEADO DOS DOIS LADOS. O jogo sorteia pelo `_rng` dele, que
# se semeia antes do `new_game()`; o robô escolhe pelo seu, separado — e a
# trilha grava as AÇÕES, não as escolhas, de modo que repeti-la não precisa do
# robô. Uma falha imprime a semente e a trilha reduzida: é um caso de teste
# pronto, e o defeito vai para o `tools/mutantes.toml`.

const PARTIDAS := 24
const PASSOS := 700
# Passa o dia 85 com folga: o cancelamento só existe com barco de vários dias,
# e na Fase 1 todo serviço dura um (medido: em 24 partidas até ao dia 110, a
# ação nunca ficou disponível).
const TETO_DIA := 140
const TETO_REPLAYS := 120

var gs
var falhas := 0
var completo := false
var feitas := {}        # ação → quantas vezes o jogo a ACEITOU
var _escolha := RandomNumberGenerator.new()
var _dia_visto := 0
var _perfil := ""
var _na_fase_2 := 0
var _dia_maximo := 0


func conferir(nome: String, ok: bool, detalhe: String = "") -> void:
	if ok:
		print("  PASS  T26: %s" % nome)
	else:
		print("  FAIL  T26: %s%s" % [nome, ("  — " + detalhe) if detalhe != "" else ""])
		falhas += 1


func rodar(estado, _arvore) -> void:
	gs = estado
	var falha_vista := ""
	for semente in range(1, PARTIDAS + 1):
		var r := _jogar(semente, [])
		if r["falha"] != "":
			var minima: Array = _reduzir(semente, r["trilha"], r["falha"])
			falha_vista = r["falha"]
			conferir("partida %d ao acaso: %s" % [semente, r["falha"]], false,
				"semente %d, %d ação(ões): %s" % [semente, minima.size(), _ler(minima)])
			break
	conferir("%d partidas ao acaso guardam os invariantes" % PARTIDAS, falha_vista == "")
	print("  -> fase 2 em %d de %d partidas; dia mais longe %d; aceitas %s"
		% [_na_fase_2, PARTIDAS, _dia_maximo, str(feitas)])
	# Quem joga conta o que jogou (`testes-e-guardas.md`): um robô que não
	# chegasse a cancelar, a carregar ou a negociar passaria verde sem ter
	# perguntado nada sobre isso.
	var faltam := PackedStringArray()
	for tipo in ["atracar", "devolver", "cancelar", "construir", "adiantar",
			"pagar", "chance", "negociar", "carregar", "avancar"]:
		if int(feitas.get(tipo, 0)) == 0:
			faltam.append(tipo)
	conferir("o robô exerceu cada ação que o jogo aceitou", faltam.is_empty(),
		"nunca aceitas: %s" % ", ".join(faltam))
	completo = true


# Uma partida: com `trilha` vazia o robô escolhe; com ela, repete-a.
func _jogar(semente: int, trilha: Array) -> Dictionary:
	gs._rng.seed = semente
	gs.new_game()
	_escolha.seed = semente * 7919
	# TRÊS PERFIS, pelo resto da semente. As três inclinações abaixo levaram
	# 17 de 24 partidas à Fase 2 e 179 cancelamentos — e o robô passou a pagar
	# sempre adiantado, e o vencimento e a segunda chance sumiram. Medido
	# também com dois perfis: o ao acaso puro nunca tem o boleto no dia, e o
	# «pagar» continuou a zero. O poupador só atraca o urgente e nunca adianta.
	_perfil = ["prudente", "poupador", "ao acaso"][semente % 3]
	_dia_visto = gs.turn
	var feita: Array = []
	var n := PASSOS if trilha.is_empty() else trilha.size()
	for i in range(n):
		if gs.phase == gs.ESTADO_FIM or gs.turn > TETO_DIA:
			break
		var acao: Array = _escolher() if trilha.is_empty() else trilha[i]
		feita.append(acao)
		var falha := _aplicar(acao, trilha.is_empty())
		if falha == "":
			falha = _violado()
		if falha != "":
			return {"falha": falha, "trilha": feita}
	if trilha.is_empty():
		_dia_maximo = maxi(_dia_maximo, gs.turn)
		_na_fase_2 += 1 if gs.numero_da_fase >= 2 else 0
	return {"falha": "", "trilha": feita}


# ── O QUE O ROBÔ PODE FAZER ──────────────────────────────────────────────
# Inclui o que o jogo tem de RECUSAR (índice fora, estrutura que não existe,
# orçamento de outro barco): a recusa também é uma resposta, e confere-se.
func _escolher() -> Array:
	if gs.phase == gs.ESTADO_OFERTA:
		return _sorteio([[30, ["negociar", "igualar"]], [25, ["negociar", "metade"]],
			[25, ["negociar", "manter"]], [10, ["recusar_oferta"]], [10, ["carregar"]]])
	if gs.phase == gs.ESTADO_COBRANCA:
		return _sorteio([[70, ["pagar"]], [20, ["chance"]], [5, ["carregar"]],
			[5, ["recusar_cobranca"]]])
	# DUAS INCLINAÇÕES, medidas. Ao acaso puro, «pagar» foi aceite UMA vez em
	# 24 partidas e nenhuma chegou à Fase 2, que é onde vivem a treliça, o
	# cargueiro e o cancelamento. Pagar adiantado metade das vezes levou quatro
	# lá, e nenhuma comprou a treliça: o «construir» ao acaso escolhia quase
	# sempre o que estava bloqueado. Com 35% e um quarto das vezes a construir
	# o que se PODE, as ações todas ficam exercidas (o controle abaixo).
	if _perfil == "prudente" and gs.pode_pagar_parcela_adiantado() and _escolha.randf() < 0.35:
		return ["adiantar"]
	var ids: Array = gs.ESTRUTURAS.keys()
	var possiveis: Array = ids.filter(func(id): return gs.impedimento_estrutura(id) == "")
	if _perfil == "prudente" and not possiveis.is_empty() and _escolha.randf() < 0.25:
		return ["construir", possiveis[_escolha.randi_range(0, possiveis.size() - 1)]]
	# A MÁSCARA DE AÇÕES LEGAIS, que a pesquisa achou nos robôs de jogo: o
	# cancelamento só existe com um barco de vários dias A MEIO, e sorteando a
	# doca e o momento às cegas ele nunca acertou (zero em 24 partidas com nove
	# na Fase 2). Quando há o que cancelar, o robô vê-o.
	var canceláveis: Array = []
	for d in range(gs.docks.size()):
		var b = gs.docks[d]["boat"]
		if b != null and not gs.custos_do_cancelamento(d, int(b["id"])).is_empty():
			canceláveis.append(d)
	if not canceláveis.is_empty() and _escolha.randf() < 0.15:
		return ["cancelar", canceláveis[_escolha.randi_range(0, canceláveis.size() - 1)]]
	# E A TERCEIRA: atracar primeiro quem está para ir embora, seis vezes em
	# dez. Medido com as duas de cima: as nove partidas que chegaram à Fase 2
	# compraram a treliça e mesmo assim não viram cargueiro — o robô deixava os
	# barcos desistir, a reputação ficava abaixo do piso de 40 e o jogo
	# suspendia-os (`106`), que é a regra a funcionar, não um defeito.
	if _perfil != "ao acaso" and gs.berco_livre() >= 0 and not gs.fila.is_empty() \
			and _escolha.randf() < 0.6:
		var urgente := 0
		for i in range(gs.fila.size()):
			if int(gs.fila[i]["paciencia"]) < int(gs.fila[urgente]["paciencia"]):
				urgente = i
		return ["atracar", urgente]
	var docas: int = gs.docks.size()
	return _sorteio([
		[30, ["avancar"]],
		[24, ["atracar", _escolha.randi_range(0, maxi(gs.fila.size() - 1, 0))]],
		[5, ["devolver", _escolha.randi_range(0, docas - 1)]],
		[5, ["tocar", _escolha.randi_range(0, docas - 1)]],
		[7, ["cancelar", _escolha.randi_range(0, docas - 1)]],
		[10, ["construir", ids[_escolha.randi_range(0, ids.size() - 1)]]],
		[0 if _perfil == "poupador" else 4, ["adiantar"]],
		[6, ["carregar"]],
		[3, ["atracar", 99]],
		[2, ["devolver", -1]],
		[2, ["construir", "inexistente"]],
		[2, ["cancelar_errado", _escolha.randi_range(0, docas - 1)]],
	])


func _sorteio(opcoes: Array) -> Array:
	var total := 0
	for o in opcoes:
		total += int(o[0])
	var s := _escolha.randi_range(1, total)
	for o in opcoes:
		s -= int(o[0])
		if s <= 0:
			return o[1]
	return opcoes[0][1]


# Devolve o nome do invariante que a AÇÃO quebrou, ou "". `contar` só na
# partida original: as repetições da redução não inflam a contagem.
func _aplicar(acao: Array, contar: bool) -> String:
	var antes := _retrato()
	var aceita := false
	var com_resposta := true   # a ação diz se aceitou (bool)
	match String(acao[0]):
		"avancar":
			gs.advance_turn()
			aceita = gs.turn > int(antes["turn"])
			com_resposta = false
		"atracar":
			aceita = gs.atracar(int(acao[1]), false)
		"devolver":
			aceita = gs.desatracar(int(acao[1]))
		"tocar":
			gs.tocar_doca(int(acao[1]))
			com_resposta = false
		"cancelar":
			var d := int(acao[1])
			var barco = gs.docks[d]["boat"] if d < gs.docks.size() else null
			var id := int(barco["id"]) if barco != null else -1
			aceita = gs.cancelar_servico(d, id, gs.custos_do_cancelamento(d, id))
		"cancelar_errado":
			# O orçamento de OUTRO valor: a confirmação tem de recusar.
			var d2 := int(acao[1])
			var barco2 = gs.docks[d2]["boat"] if d2 < gs.docks.size() else null
			var id2 := int(barco2["id"]) if barco2 != null else -1
			var lido: Dictionary = gs.custos_do_cancelamento(d2, id2)
			if not lido.is_empty():
				lido["multa"] = int(lido["multa"]) - 1
			aceita = gs.cancelar_servico(d2, id2, lido)
			if aceita:
				return "a confirmação aceitou um orçamento que não era o lido"
		"construir":
			aceita = gs.comprar_estrutura(String(acao[1]))
		"adiantar":
			aceita = gs.pagar_parcela_adiantado()
		"pagar":
			gs.pay_debt()
			aceita = gs.phase != gs.ESTADO_COBRANCA
			com_resposta = false
		"chance":
			aceita = gs.aceitar_segunda_chance()
		"recusar_cobranca":
			gs.fail_debt()
			com_resposta = false
		"negociar":
			aceita = gs.negotiate_rival(String(acao[1])) != "invalido"
			com_resposta = false
		"recusar_oferta":
			gs.resolve_rival_offer(false)
			com_resposta = false
		"carregar":
			gs.save_game()
			if not gs.load_game():
				return "o jogo recusou o save que ele próprio gravou"
			if _retrato() != antes:
				return "o save que o jogo grava não volta igual (%s)" % _diferenca(antes, _retrato())
			aceita = true
	if com_resposta and not aceita and _retrato() != antes:
		return "a recusa de «%s» mexeu no estado (%s)" % [acao[0], _diferenca(antes, _retrato())]
	if contar and aceita:
		var tipo := "devolver" if acao[0] == "tocar" else String(acao[0])
		feitas[tipo] = int(feitas.get(tipo, 0)) + 1
	return ""


# ── O QUE VALE SEMPRE ────────────────────────────────────────────────────
func _violado() -> String:
	if not gs.ESTADOS_DO_TURNO.has(gs.phase):
		return "o estado do turno é um dos quatro"
	var oferta: bool = gs.phase == gs.ESTADO_OFERTA
	if oferta != (gs.pending_rival >= 0) or gs.pending_rival >= gs.fila.size() \
			or (oferta and not bool(gs.fila[gs.pending_rival].get("rival", false))):
		return "a oferta aberta aponta para um barco da fila, e só na fase dela"
	if gs.fila.size() > gs.FILA_LUGARES:
		return "a fila cabe no fundeadouro"
	for b in gs.fila:
		if int(b["progress"]) != 0 or int(b["paciencia"]) < 1:
			return "na fila nenhum barco começou a operar nem esgotou a paciência"
	var ids := {}
	for w in gs.workers:
		ids[int(w["id"])] = true
	var alocados := {}
	for d in gs.docks:
		if (d["boat"] == null) != (d["worker_id"] == null):
			return "barco e trabalhador entram e saem da doca juntos"
		if d["worker_id"] != null:
			var wid := int(d["worker_id"])
			if not ids.has(wid) or alocados.has(wid):
				return "cada trabalhador numa doca só, e só os que existem"
			alocados[wid] = true
	if gs.docks.size() != gs.docas_esperadas() or gs.workers.size() != gs.trabalhadores_esperados() \
			or gs.docks.size() > gs.bercos_no_mapa():
		return "o porto tem as docas e a equipe que as obras dizem"
	var rostos := {}
	for w in gs.workers:
		var k := int(w["rosto"])
		if k < 0 or k >= gs.rostos() or rostos.has(k):
			return "cada trabalhador com o seu rosto"
		rostos[k] = true
	if gs.reputation < 0.0 or gs.reputation > 100.0:
		return "a reputação fica entre 0 e 100"
	var vistas := {}
	for e in gs.estruturas:
		if vistas.has(e):
			return "nenhuma obra pronta repetida"
		vistas[e] = true
	if not gs.obra_em_andamento.is_empty() and (vistas.has(gs.obra_em_andamento["id"])
			or int(gs.obra_em_andamento["conclusao"]) <= gs.turn):
		return "a obra em curso não está pronta nem atrasada"
	if gs.tem_cobranca():
		if gs.parcelas_quitadas != gs.parcela_indice + (1 if gs.parcela_paid else 0):
			return "o recibo das cobranças bate com o índice"
	elif gs.parcela_indice != 0 or gs.parcelas_quitadas != 0 or gs.parcela_paid:
		return "sem cobrança, o recibo está a zero"
	if typeof(gs.cash) != TYPE_INT:
		return "o caixa é inteiro"
	if gs.turn < _dia_visto or (gs.fase_tem_prazo() and gs.turn > gs.ultimo_dia_da_fase() + 1):
		return "o dia não volta atrás nem passa do fim da fase"
	_dia_visto = gs.turn
	gs.save_game()
	if gs._save_aceite(FileAccess.get_file_as_string(gs.save_path)).is_empty():
		return "o save que o jogo grava, o próprio jogo aceita"
	return ""


# A lista é DESTE teste, e não a do `save_game()` — ver o cabeçalho.
func _retrato() -> Dictionary:
	return _normal({
		"turn": gs.turn, "cash": gs.cash, "reputation": snappedf(gs.reputation, 0.0001),
		"phase": gs.phase, "fase": gs.numero_da_fase, "dias_rep": gs.dias_de_reputacao,
		"cargueiro": gs.primeiro_cargueiro, "meta": gs.meta_concluida,
		"docks": gs.docks, "workers": gs.workers, "estruturas": gs.estruturas,
		"obra": gs.obra_em_andamento, "paga": gs.parcela_paid, "indice": gs.parcela_indice,
		"quitadas": gs.parcelas_quitadas, "pago": gs.total_pago_parcelas,
		"devido": gs.emprestimo_devido, "chance": gs.segunda_chance_usada,
		"fila": gs.fila, "oferta": gs.pending_rival, "paciencia_rival": gs.rival_attempts_left,
		"fim": gs.end_reason, "ganhou": gs.won, "metrics": gs.metrics,
		"semana": gs.semana_atual, "dia": gs.dia_atual, "ontem": gs.dia_anterior,
		"historico": gs.historico_semanas,
	})


# O JSON devolve todo número como float; a comparação é do VALOR. Sem isto,
# `3` e `3.0` diferem para o `==` de um Dictionary, e a ida e volta acusaria
# o tipo em vez do conteúdo.
func _normal(v):
	match typeof(v):
		TYPE_DICTIONARY:
			var d := {}
			for k in v:
				d[String(k)] = _normal(v[k])
			return d
		TYPE_ARRAY:
			var a: Array = []
			for x in v:
				a.append(_normal(x))
			return a
		TYPE_FLOAT:
			if v == floorf(v):
				return int(v)
			return snappedf(v, 0.0001)
		_:
			return v


func _diferenca(a: Dictionary, b: Dictionary) -> String:
	for k in a:
		if not b.has(k) or a[k] != b[k]:
			return "%s: %s → %s" % [k, str(a[k]).left(60), str(b.get(k)).left(60)]
	return "?"


# ── A REDUÇÃO ────────────────────────────────────────────────────────────
# Tira uma ação de cada vez, do fim para o princípio, e fica sem ela se a
# MESMA falha continuar a aparecer. O nome da falha é a assinatura: uma
# redução que trocasse de defeito pelo caminho entregaria um caso que falha
# pela razão errada.
func _reduzir(semente: int, trilha: Array, falha: String) -> Array:
	var atual := trilha.duplicate()
	var tentativas := 0
	var i := atual.size() - 2
	while i >= 0 and tentativas < TETO_REPLAYS:
		var sem := atual.duplicate()
		sem.remove_at(i)
		tentativas += 1
		if String(_jogar(semente, sem)["falha"]) == falha:
			atual = sem
		i -= 1
	return atual


func _ler(trilha: Array) -> String:
	var partes := PackedStringArray()
	for a in trilha:
		var termos := PackedStringArray()
		for x in a:
			termos.append(str(x))
		partes.append(" ".join(termos))
	return ", ".join(partes)
