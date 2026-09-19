extends SceneTree

# ============================================================
# BR Port VS — A RÉGUA DA FAIXA DE MENSAGEM (R5 da §7.1, fase F2)
#
# A pergunta: **de tudo o que o jogo escreve na faixa, quanto o jogador chega
# a ver?** O R4 mediu isso para as falas da Dona Cida e consertou a ORDEM —
# hoje a fala entra no fim do frame e fica por cima. O preço foi o inverso: a
# mensagem do sistema passou a ser a tapada. Esta régua mede as DUAS fontes.
#
# ⚠️ ELA NÃO REPLICA NENHUMA ESCOLHA DE TEXTO. A sonda herda o `Main` e
# intercepta o `_on_message`, que é o funil único das duas fontes desde 18/09;
# o que ela conta é o que o Label recebeu, na ordem em que recebeu.
#
# ⚠️ E CONTA POR AÇÃO DO JOGADOR, não por frame nem por turno. Uma ação é o
# que um toque faz: "Avançar dia", "Alocar todos", comprar uma estrutura,
# responder ao Arlindo, pagar a parcela. É a unidade em que a fila do R5 vai
# viver, porque é entre duas ações que ela tem tempo para drenar.
#
# ⚠️ E ESPERA DOIS FRAMES DEPOIS DE CADA AÇÃO. A fala entra por
# `call_deferred`, e `await process_frame` retoma no INÍCIO do frame seguinte,
# antes de a fila adiada daquele frame correr. Com um só, a régua devolve zero
# falas — e zero lê-se como "não acontece nada" (`CLAUDE.md`).
#
# Rodar:
#   Godot --headless --path brport_vs --script res://tools/medir_fila_mensagens.gd
# ============================================================

const SONDA := "res://tools/sonda_mensagens.gd"
const CAMINHO_LABEL := "MensagemCartao/Mensagem"
const CAMINHO_OVERLAY := "Overlay"

# As mesmas cinco do R4, para o antes e o depois se poderem comparar.
const SEMENTES := [20260902, 20260903, 20260904, 20260905, 20260906]

# DUAS FORMAS DE JOGAR, e elas emparedam a carga: quem aloca e constrói gera
# mensagem de sistema por barco servido e por obra; quem só avança gera o
# mínimo que o jogo diz sozinho. O balanceamento não entra aqui — nada nesta
# régua toca em constante nenhuma.
# ⚠️ O TERCEIRO MODO EXISTE POR CAUSA DE UMA FALA SÓ. A variante da semana nova
# com a parcela JÁ PAGA precisa de um jogador que quite adiantado, e nem o
# ativo nem o passivo o fazem: sem ele a régua diria "zero" e zero, aqui,
# lê-se como "esta fala nunca acontece" em vez de "ninguém a foi buscar".
const MODOS := ["ativo", "passivo", "quitador"]

var GS: Node
var _feito := false

# Uma entrada por AÇÃO: {"modo", "semente", "turno", "acao", "escritas": [...],
# "modal": bool}
var _acoes: Array[Dictionary] = []
var _sonda: Node = null
var _label: Label = null
var _overlay: Node = null


func _process(_delta: float) -> bool:
	if _feito:
		return false
	_feito = true
	_rodar()
	return false


func _rodar() -> void:
	GS = root.get_node("GameState")
	for modo in MODOS:
		for semente in SEMENTES:
			await _uma_partida(String(modo), int(semente))
	_relatorio()
	quit(0)


# ── a partida ───────────────────────────────────────────────────────────────

func _abrir(semente: int) -> bool:
	# DERIVA O ESTADO, nunca o herda: o autoload tenta `load_game()` antes de
	# `new_game()`, e sem isto a partida seguinte herdava o autosave da anterior.
	GS.clear_save()
	GS._rng.seed = semente
	GS.new_game()
	GS.definir_nomes(GS.NOME_PORTO_PADRAO, "")
	var cena := load("res://scenes/Main.tscn") as PackedScene
	if cena == null:
		push_error("Main.tscn não carrega")
		return false
	var script_sonda := load(SONDA)
	_sonda = cena.instantiate()
	_sonda.set_script(script_sonda)
	root.add_child(_sonda)
	_label = _sonda.get_node_or_null(CAMINHO_LABEL) as Label
	_overlay = _sonda.get_node_or_null(CAMINHO_OVERLAY)
	return true


func _fechar() -> void:
	if _sonda != null:
		_sonda.free()
		_sonda = null
	_label = null
	_overlay = null


func _esperar() -> void:
	await process_frame
	await process_frame


# O CORAÇÃO DA RÉGUA: faz UMA ação e guarda tudo o que ela escreveu.
func _acao(modo: String, semente: int, nome: String, alvo: Callable) -> void:
	var antes: int = _sonda.registo.size()
	alvo.call()
	await _esperar()
	var escritas: Array[Dictionary] = []
	var reg: Array = _sonda.registo
	for i in range(antes, reg.size()):
		escritas.append(reg[i])
	_acoes.append({
		"modo": modo,
		"semente": semente,
		"turno": int(GS.turn),
		"acao": nome,
		"escritas": escritas,
		"modal": _modais() > 0,
	})


func _modais() -> int:
	return 0 if _overlay == null else _overlay.get_child_count()


# Fecha o que estiver aberto, como o jogador fecha antes de voltar ao jogo.
# ⚠️ E ISTO É PARTE DA MEDIÇÃO, não arrumação: um painel aberto é uma PAUSA
# forçada, e é nela que uma fila teria tempo de drenar sem o jogador esperar.
func _fechar_modais() -> void:
	if _overlay == null:
		return
	for filho in _overlay.get_children():
		if filho.has_method("_fechar"):
			filho.call("_fechar")
		else:
			filho.queue_free()
	await _esperar()


func _uma_partida(modo: String, semente: int) -> void:
	if not _abrir(semente):
		return
	var voltas := 0
	while GS.phase != "game_over" and voltas < 400:
		voltas += 1
		if GS.phase == "rival_offer":
			await _acao(modo, semente, "responder_arlindo",
				func(): GS.resolve_rival_offer(modo == "ativo"))
			continue
		if GS.phase == "debt_payment":
			var da: bool = GS.cash >= GS.valor_da_parcela_hoje()
			await _acao(modo, semente, "parcela", _pagar_ou_falhar.bind(da))
			continue
		if GS.phase != "playing":
			break
		# O QUITADOR NÃO CONSTRÓI, e é de propósito: ele guarda para quitar a
		# parcela cedo, e é depois disso que o estado que a fala nova lê
		# existe — cais parado, dinheiro curto e o Sr. Ribeiro já pago.
		if modo != "passivo":
			await _acao(modo, semente, "alocar_todos",
				func(): GS.assign_all_free_workers())
		if modo == "quitador" and not GS.parcela_paid and GS.pode_pagar_parcela_adiantado():
			await _acao(modo, semente, "quitar_adiantado",
				func(): GS.pagar_parcela_adiantado())
		if modo == "ativo":
			var compra := _proxima_compra()
			if compra != "":
				await _acao(modo, semente, "comprar",
					func(): GS.comprar_estrutura(compra))
		await _acao(modo, semente, "avancar_dia",
			func(): _sonda._on_advance_pressed())
		await _fechar_modais()
	_fechar()


# A primeira estrutura que o caixa alcança e a cadeia `requer` permite. Não é
# política de perfil nenhuma — é só o que faz o jogo emitir "pronto".
func _proxima_compra() -> String:
	for id in GS.ESTRUTURAS.keys():
		var e: Dictionary = GS.ESTRUTURAS[id]
		# `estruturas` é um ARRAY de ids construídos, e não um dicionário de
		# booleanos — `.get(id, false)` daria sempre falso, sem erro nenhum.
		if GS.estruturas.has(id):
			continue
		var requer: String = String(e.get("requer", ""))
		if requer != "" and not GS.estruturas.has(requer):
			continue
		if GS.cash >= int(e["custo"]):
			return String(id)
	return ""


func _pagar_ou_falhar(da: bool) -> void:
	if da:
		GS.pay_debt()
	else:
		GS.fail_debt()


# ── o relatório ─────────────────────────────────────────────────────────────

func _fonte(escrita: Dictionary) -> String:
	# ⚠️ A FONTE VEM MARCADA DA SONDA, e não do `kind`. O `kind` vazio parece
	# a assinatura da Dona Cida — é assim que o `_cida_agora` escreve —, mas o
	# `GameState` tem uma mensagem de sistema com kind vazio ("Trabalhador #N
	# liberado"), e a primeira versão desta régua contava-a como fala dela.
	return String(escrita["fonte"])


func _relatorio() -> void:
	var total := 0
	var vistas := 0
	var por_fonte := {"sistema": 0, "cida": 0}
	var tapadas_por_fonte := {"sistema": 0, "cida": 0}
	var histograma := {}
	var maior := 0
	var acoes_com_escrita := 0
	var acoes_com_modal := 0
	var por_acao := {}
	var textos := {}

	for a in _acoes:
		var escritas: Array = a["escritas"]
		var n: int = escritas.size()
		histograma[n] = int(histograma.get(n, 0)) + 1
		maior = maxi(maior, n)
		if n == 0:
			continue
		acoes_com_escrita += 1
		if bool(a["modal"]):
			acoes_com_modal += 1
		total += n
		vistas += 1
		var nome: String = String(a["acao"])
		var d: Dictionary = por_acao.get(nome, {"acoes": 0, "escritas": 0, "max": 0})
		d["acoes"] = int(d["acoes"]) + 1
		d["escritas"] = int(d["escritas"]) + n
		d["max"] = maxi(int(d["max"]), n)
		por_acao[nome] = d
		for i in range(n):
			var f: String = _fonte(escritas[i])
			por_fonte[f] = int(por_fonte[f]) + 1
			# A ÚLTIMA É A QUE FICA. Todas as outras foram escritas e apagadas
			# no mesmo frame, sem o jogador ter como as ler.
			if i < n - 1:
				tapadas_por_fonte[f] = int(tapadas_por_fonte[f]) + 1
			textos[String(escritas[i]["texto"])] = true

	print("=== ANTES — a faixa de mensagem como está hoje ===")
	print("%d partidas (%d sementes x %d modos), %d ações do jogador"
		% [SEMENTES.size() * MODOS.size(), SEMENTES.size(), MODOS.size(), _acoes.size()])
	print("")
	print("escritas na faixa: %d   (sistema %d · Dona Cida %d)"
		% [total, por_fonte["sistema"], por_fonte["cida"]])
	print("VISTAS (a última de cada ação): %d" % vistas)
	var tapadas: int = total - vistas
	var pct: float = 0.0 if total == 0 else 100.0 * float(tapadas) / float(total)
	print("TAPADAS: %d  (%.1f%% de tudo o que o jogo diz)" % [tapadas, pct])
	print("   sendo sistema %d e Dona Cida %d"
		% [tapadas_por_fonte["sistema"], tapadas_por_fonte["cida"]])
	print("")
	print("escritas por ação — histograma:")
	var chaves: Array = histograma.keys()
	chaves.sort()
	for k in chaves:
		print("   %d escrita(s): %d ação(ões)" % [int(k), int(histograma[k])])
	print("   maior rajada numa ação: %d" % maior)
	print("")
	print("por tipo de ação:")
	for nome in por_acao.keys():
		var d: Dictionary = por_acao[nome]
		var media: float = float(d["escritas"]) / float(d["acoes"])
		print("   %-18s %4d ações · %4d escritas · média %.2f · máx %d"
			% [nome, int(d["acoes"]), int(d["escritas"]), media, int(d["max"])])
	print("")
	print("ações que acabaram com painel aberto (pausa forçada): %d de %d"
		% [acoes_com_modal, acoes_com_escrita])
	_por_fala()
	_medir_textos(textos.keys())
	print("")
	print("=== FILA MEDIDA ===")


# CADA FALA DA DONA CIDA: quantas vezes foi ESCRITA e quantas SOBROU no Label.
# ⚠️ É a pergunta do `barco_medio` com a roupa da narrativa, e ela tem de ser
# feita a toda fala NOVA: uma variante cuja condição o jogo nunca monta é uma
# linha escrita, validada, disparada por nada — e as guardas todas passam.
func _por_fala() -> void:
	var escrita := {}
	var vista := {}
	for a in _acoes:
		var lista: Array = a["escritas"]
		for i in range(lista.size()):
			var e: Dictionary = lista[i]
			if String(e["fonte"]) != "cida":
				continue
			var id: String = String(e["id"])
			escrita[id] = int(escrita.get(id, 0)) + 1
			if i == lista.size() - 1:
				vista[id] = int(vista.get(id, 0)) + 1
	print("")
	print("cada fala da Dona Cida — escrita x vista:")
	var ids: Array = escrita.keys()
	ids.sort()
	for id in ids:
		var v: int = int(vista.get(id, 0))
		print("   %-34s escrita %3d · vista %3d%s"
			% [id, int(escrita[id]), v, "   <<< NUNCA VISTA" if v == 0 else ""])
	# A OUTRA METADE DA PERGUNTA: uma fala que nem sequer foi escrita não
	# aparece na tabela acima, e é essa a que se perde em silêncio.
	for id in Narrativa.CIDA_LINHAS.keys():
		if not escrita.has(id):
			print("   %-34s NUNCA ESCRITA — nenhuma partida montou a condição" % id)


# A LARGURA É A DA FAIXA, e não um número suposto: o cartão mede 692 px
# (14..706 no `Main.tscn`) e o Label desconta o padding do tema.
func _medir_textos(lista: Array) -> void:
	print("")
	print("comprimento do texto (%d textos distintos):" % lista.size())
	var maior_txt := ""
	var soma := 0
	for t in lista:
		soma += String(t).length()
		if String(t).length() > maior_txt.length():
			maior_txt = String(t)
	if lista.is_empty():
		return
	print("   média %d caracteres · o mais longo %d" % [soma / lista.size(), maior_txt.length()])
	print("   o mais longo: \"%s\"" % maior_txt)
