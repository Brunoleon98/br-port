extends SceneTree

# ============================================================
# BR Port VS — TESTE DO REGISTRO DE PARTIDA (item B7)
#
# O que este arquivo protege, por ordem de gravidade:
#
# 1. **QUE O GRAVADOR NÃO GRAVE ONDE NÃO DEVE.** É o bloco R1 e é o mais
#    importante daqui. Um autoload carrega também em `--script`, então o
#    `Registro` está de pé durante as 600 partidas × 3 perfis do simulador de
#    balanceamento. Se ele gravasse por omissão, medir o balanceamento
#    escreveria 1.800 arquivos e o custo de os escrever entraria na medida —
#    exatamente a família de defeito que já custou 24 de 30 partidas travadas
#    quando alguém pôs uma tela nova como FASE em vez de overlay. O
#    balanceamento medido (100% / 79,5% / 31,0%) tem de continuar a ser o
#    mesmo com este item dentro, e é este bloco que o tranca.
#
# 2. **QUE ESCREVER NÃO APAGUE.** `FileAccess.WRITE` TRUNCA. Não há modo
#    "append" no Godot 4, e a versão ingénua deste gravador dá um arquivo de
#    uma linha só — a última —, que passa em qualquer teste que só verifique
#    "o arquivo existe e é JSON válido".
#
# 3. **QUE O NOME DO JOGADOR NÃO SAIA NO ARQUIVO.** O A7 manda entregar o
#    jogo "a duas pessoas sem explicar nada" e o registro sai do telefone pela
#    área de transferência, colado numa conversa. O que se grava é a forma da
#    escolha, não a pessoa.
#
# ⚠️ TODO BLOCO PÕE UMA BANDEIRA NA ÚLTIMA LINHA e quem o chama confere que
# ela ficou verdadeira. Sem isso, um erro de execução a meio do bloco aborta a
# função, o contador de falhas fica em zero e a suíte imprime que passou com
# metade das asserções por correr — já aconteceu neste projeto, no bloco T5g.
#
# Rodar:
#   Godot --headless --path brport_vs --script res://tests/teste_registro.gd
# ============================================================

var _falhas := 0
var _feito := false

# O identificador global de um autoload NÃO existe num script de `--script`.
# Ver a regra no CLAUDE.md — os nomes curtos evitam sombrear os autoloads.
var R: Node
var GS: Node

var _b1 := false
var _b1b := false
var _b2 := false
var _b3 := false
var _b4 := false
var _b5 := false
var _b6 := false


func _confere(rotulo: String, ok: bool, detalhe: String = "") -> void:
	if ok:
		print("  PASS  %s" % rotulo)
	else:
		print("  FALHA %s%s" % [rotulo, ("  — " + detalhe) if detalhe != "" else ""])
		_falhas += 1


func _process(_delta: float) -> bool:
	if _feito:
		return true
	_feito = true
	_rodar()
	return true


func _rodar() -> void:
	R = root.get_node_or_null("Registro")
	GS = root.get_node_or_null("GameState")
	if R == null or GS == null:
		print("FALHA: Registro ou GameState não estão registrados em project.godot.")
		quit(1)
		return

	# SEMENTE FIXA, e não é zelo. O `new_game()` chama `_spawn_boats()`, que
	# tem 30% de abrir contra-oferta do Arlindo — e nessa fase o
	# `advance_turn()` retorna CALADO. Com a semente por sortear, o bloco R6
	# reprovava em cerca de 3 de cada 10 corridas por uma razão que nada tinha
	# a ver com o gravador: um teste intermitente no CI é pior do que teste
	# nenhum, porque ensina a ignorar vermelho.
	GS._rng.seed = 20260902

	print("=== R1: DESARMADO por omissão — o simulador não pode gravar ===")
	_r1_desarmado()
	print("=== R1b: armar() outra vez abre partida nova, não continua a velha ===")
	_r1b_partida_nova()
	print("=== R2: armado, uma partida inteira vira JSONL bem formado ===")
	_r2_partida()
	print("=== R3: acrescentar não trunca (FileAccess.WRITE apaga) ===")
	_r3_acrescenta()
	print("=== R4: os tetos seguram — linhas por arquivo, arquivos na pasta ===")
	_r4_tetos()
	print("=== R5: o nome do jogador NÃO entra no arquivo ===")
	_r5_anonimo()
	print("=== R6: o relógio de deliberação é monotónico e não negativo ===")
	_r6_relogio()

	# A bandeira de cada bloco. Ver o aviso do cabeçalho: sem isto, "passou"
	# quer dizer "não reprovou", que não é a mesma coisa que "correu".
	_confere("os sete blocos correram até ao fim",
		_b1 and _b1b and _b2 and _b3 and _b4 and _b5 and _b6,
		"R1=%s R1b=%s R2=%s R3=%s R4=%s R5=%s R6=%s" % [_b1, _b1b, _b2, _b3, _b4, _b5, _b6])

	_limpar()

	print("")
	if _falhas == 0:
		print("REGISTRO OK")
		quit(0)
	else:
		print("REGISTRO COM %d FALHA(S)" % _falhas)
		quit(1)


func _limpar() -> void:
	var d := DirAccess.open(R.PASTA)
	if d == null:
		return
	for n in d.get_files():
		DirAccess.remove_absolute("%s/%s" % [R.PASTA, n])


func _arquivos() -> Array:
	var d := DirAccess.open(R.PASTA)
	if d == null:
		return []
	var fora: Array = []
	for n in d.get_files():
		if n.ends_with(".jsonl"):
			fora.append(n)
	return fora


# ── R1 ──
#
# O bloco que protege o balanceamento medido. Roda um punhado de turnos com o
# gravador como ele nasce — desarmado — e exige que a pasta continue vazia.
func _r1_desarmado() -> void:
	_limpar()
	_confere("nasce desarmado", not R.armado())

	GS.new_game()
	for i in range(6):
		GS.advance_turn()
		if GS.phase == "rival_offer":
			GS.negotiate_rival("igualar")
		elif GS.phase == "debt_payment":
			GS.fail_debt()
			break

	_confere("seis turnos desarmado não escrevem arquivo nenhum",
		_arquivos().size() == 0, "%d arquivo(s) na pasta" % _arquivos().size())
	_confere("e não contam linha", R.linhas_gravadas() == 0,
		"contou %d" % R.linhas_gravadas())
	# O sinal novo tem de existir e ser emitido mesmo com o gravador desarmado:
	# é o GameState que o emite, e ele não sabe que existe gravador.
	_confere("o sinal negociacao_resolvida existe no GameState",
		GS.has_signal("negociacao_resolvida"))
	_b1 = true


# ── R1b ──
#
# "Novo jogo (apaga progresso)" faz `reload_current_scene()` e o
# `Main._ready()` corre outra vez. Se `armar()` saísse cedo por já estar
# armado, a partida NOVA continuaria a escrever no arquivo da anterior sem
# linha de abertura entre as duas — e o leitor, que parte as partidas
# justamente pela abertura, juntaria as duas numa só com o dobro dos turnos.
# Não dá erro nenhum: dá um relatório plausível e errado.
func _r1b_partida_nova() -> void:
	_limpar()
	R.armar()
	var primeiro: String = R._caminho
	R._gravar({"e": "marco", "n": 1})
	R.armar()
	_confere("armar() outra vez abre arquivo NOVO", R._caminho != primeiro,
		"continuou em %s" % primeiro)
	_confere("e ficam dois arquivos na pasta", _arquivos().size() == 2,
		"%d arquivo(s)" % _arquivos().size())
	var todas: String = R.texto_para_exportar(true)
	var aberturas := 0
	for l in todas.split("\n", false):
		var v = JSON.parse_string(l)
		if typeof(v) == TYPE_DICTIONARY and v.get("e") == "abriu":
			aberturas += 1
	_confere("duas aberturas — é por elas que o leitor parte as partidas",
		aberturas == 2, "%d aberturas" % aberturas)
	_b1b = true


# ── R2 ──
func _r2_partida() -> void:
	_limpar()
	# `new_game()` ANTES de armar, que é a ordem do jogo: quem arma é o
	# `Main._ready()`, e quando ele corre o `GameState._ready()` já abriu a
	# partida. Armar antes deixava o gravador com a contagem de barcos da
	# partida anterior como ponto de partida.
	GS.new_game()
	R.armar()
	_confere("armar() arma", R.armado())

	var nomes := _arquivos()
	_confere("armar() abre exatamente um arquivo", nomes.size() == 1,
		"%d arquivo(s)" % nomes.size())
	if nomes.size() != 1:
		_b2 = true
		return

	GS.definir_nomes("Cais de Teste", "Fulano")
	var voltas := 0
	while GS.phase != "game_over" and voltas < 200:
		voltas += 1
		if GS.phase == "rival_offer":
			GS.negotiate_rival("igualar")
			continue
		if GS.phase == "debt_payment":
			if GS.cash >= GS.PARCELA_AMOUNT:
				GS.pay_debt()
			else:
				GS.fail_debt()
			continue
		GS.assign_all_free_workers()
		GS.advance_turn()

	_confere("a partida chegou ao fim", GS.phase == "game_over",
		"parou em %s após %d voltas" % [GS.phase, voltas])

	var texto: String = R.texto_para_exportar()
	var linhas := texto.split("\n", false)
	_confere("o arquivo tem linhas", linhas.size() > 0)

	var tipos := {}
	var todas_json := true
	for l in linhas:
		var v = JSON.parse_string(l)
		if typeof(v) != TYPE_DICTIONARY:
			todas_json = false
			continue
		tipos[v.get("e", "?")] = int(tipos.get(v.get("e", "?"), 0)) + 1
	_confere("TODA linha é um objeto JSON", todas_json)
	_confere("a primeira linha é a abertura", linhas.size() > 0
		and JSON.parse_string(linhas[0]).get("e") == "abriu")
	_confere("a última é o fim", linhas.size() > 0
		and JSON.parse_string(linhas[linhas.size() - 1]).get("e") == "fim")
	_confere("gravou um evento de turno por turno jogado",
		int(tipos.get("turno", 0)) >= GS.TURNS_TOTAL - 1,
		"%d turnos para %d jogados" % [tipos.get("turno", 0), GS.TURNS_TOTAL])
	_confere("gravou o fecho das quatro semanas", int(tipos.get("semana", 0)) == 4,
		"%d semanas" % tipos.get("semana", 0))

	# ZERO É O PIOR VALOR DE OMISSÃO QUE HÁ: lê-se como medida. A primeira
	# versão zerava um contador a cada turno e nunca o incrementava — não
	# existe sinal para "barco atendido" —, e o relatório dizia "0 barcos
	# servidos" num porto que atendeu dezenas. A soma dos turnos tem de bater
	# com o `metrics` que o jogo mostra ao jogador no fim.
	var soma_servidos := 0
	var soma_perdidos := 0
	for l in linhas:
		var v = JSON.parse_string(l)
		if typeof(v) == TYPE_DICTIONARY and v.get("e") == "turno":
			soma_servidos += int(v.get("servidos", 0))
			soma_perdidos += int(v.get("perdidos", 0))
	_confere("os barcos servidos por turno somam o total da partida",
		soma_servidos == int(GS.metrics["boats_served"]),
		"somou %d, o jogo conta %d" % [soma_servidos, GS.metrics["boats_served"]])
	_confere("e os perdidos também",
		soma_perdidos == int(GS.metrics["boats_lost"]),
		"somou %d, o jogo conta %d" % [soma_perdidos, GS.metrics["boats_lost"]])
	_confere("e não são zero (senão a asserção acima passa por acaso)",
		soma_servidos > 0, "a partida não atendeu barco nenhum")
	_confere("linhas_gravadas() bate com o arquivo",
		R.linhas_gravadas() == linhas.size(),
		"contou %d, o arquivo tem %d" % [R.linhas_gravadas(), linhas.size()])

	# O cabeçalho tem de carregar o que o jogo assume, senão um registro de
	# hoje lido depois de uma reescala mede-se contra os números errados.
	var cab: Dictionary = JSON.parse_string(linhas[0])
	_confere("o cabeçalho traz a versão do registro", int(cab.get("versao", 0)) == R.VERSAO)
	_confere("e a parcela e o caixa inicial em vigor",
		int(cab.get("parcela", 0)) == GS.PARCELA_AMOUNT
		and int(cab.get("caixa_inicial", 0)) == GS.START_CASH)

	# O custo da obra tem de ser o custo DA OBRA. A primeira versão lia a
	# chave `preco`, que não existe em `ESTRUTURAS` — o `.get()` com omissão
	# devolvia zero e o relatório dizia que o jogador construía de graça. Um
	# teste que só verifica "o campo existe" não pega isto.
	_limpar()
	R._armado = false
	R.armar()
	GS.new_game()
	GS.cash = 999999
	GS.comprar_estrutura("patio")
	var obra: Dictionary = {}
	for l in R.texto_para_exportar().split("\n", false):
		var v = JSON.parse_string(l)
		if typeof(v) == TYPE_DICTIONARY and v.get("e") == "obra":
			obra = v
	_confere("a obra grava o custo de verdade, não um zero de omissão",
		int(obra.get("custo", -1)) == int(GS.ESTRUTURAS["patio"]["custo"]),
		"gravou %s, a estrutura custa %d" % [obra.get("custo"), GS.ESTRUTURAS["patio"]["custo"]])
	_b2 = true


# ── R3 ──
#
# O defeito que este bloco existe para pegar não dá erro nenhum: com
# `FileAccess.WRITE` a cada linha, o arquivo fica com a ÚLTIMA e todos os
# outros testes continuam a passar, porque uma linha ainda é JSON válido.
func _r3_acrescenta() -> void:
	_limpar()
	R.armar()
	# `armar()` abre um arquivo NOVO a cada chamada — ver o comentário dela. O
	# ponto de partida é o que ela acabou de escrever, não o contador de antes.
	var antes: int = R.linhas_gravadas()
	_confere("armar() outra vez recomeça a contagem", antes == 1,
		"a abertura contou %d linhas" % antes)
	R._gravar({"e": "marco", "n": 1})
	R._gravar({"e": "marco", "n": 2})
	R._gravar({"e": "marco", "n": 3})
	var linhas: PackedStringArray = R.texto_para_exportar().split("\n", false)
	_confere("três linhas depois da abertura ficam as três",
		linhas.size() == antes + 3, "%d linhas, esperadas %d" % [linhas.size(), antes + 3])

	var ns: Array = []
	for l in linhas:
		var v = JSON.parse_string(l)
		if typeof(v) == TYPE_DICTIONARY and v.get("e") == "marco":
			ns.append(int(v["n"]))
	_confere("e na ordem em que foram escritas", ns == [1, 2, 3], str(ns))

	# Fechar a cada linha é o que garante que uma partida morta a meio (o
	# Android mata a aplicação sem aviso) fica no disco. Prova-se lendo o
	# arquivo por FORA do gravador, sem lhe pedir para fechar nada.
	var direto: String = FileAccess.get_file_as_string(R._caminho)
	_confere("o que está no disco é o que o gravador diz ter",
		direto.split("\n", false).size() == linhas.size())
	_b3 = true


# ── R4 ──
func _r4_tetos() -> void:
	_limpar()
	R.armar()
	# O teto de linhas, forçado por baixo para não escrever 5.000 linhas num
	# teste. Mexe-se na constante? Não — mexe-se no contador, que é o que a
	# guarda lê.
	R._linhas = R.TETO_LINHAS
	R._gravar({"e": "marco", "n": 99})
	var texto: String = R.texto_para_exportar()
	_confere("passado o teto, grava a linha que explica e cala",
		texto.contains("\"calou\""), "não escreveu a linha de calou")
	var antes: int = texto.length()
	R._gravar({"e": "marco", "n": 100})
	R._gravar({"e": "marco", "n": 101})
	_confere("e depois de calar não escreve mais nada",
		R.texto_para_exportar().length() == antes)

	# O teto de arquivos: um telefone emprestado para testar não pode encher.
	_limpar()
	for i in range(R.TETO_ARQUIVOS + 4):
		var f := FileAccess.open("%s/partida_velha_%03d.jsonl" % [R.PASTA, i], FileAccess.WRITE)
		f.store_line("{\"e\":\"abriu\"}")
		f.close()
	R._armado = false
	R.armar()
	_confere("a pasta não passa do teto de arquivos",
		_arquivos().size() <= R.TETO_ARQUIVOS,
		"%d arquivos, teto %d" % [_arquivos().size(), R.TETO_ARQUIVOS])
	_b4 = true


# ── R5 ──
func _r5_anonimo() -> void:
	_limpar()
	R.armar()
	GS.new_game()
	GS.definir_nomes("Cais Mirim", "Bruno Leon")
	GS._end_game(false, "fim de teste")

	var texto: String = R.texto_para_exportar()
	_confere("o nome do jogador NÃO aparece no arquivo",
		not texto.contains("Bruno Leon"), "o nome vazou para o registro")
	_confere("mas o nome do porto sim (é escolha de jogo)",
		texto.contains("Cais Mirim"))

	var fim: Dictionary = {}
	for l in texto.split("\n", false):
		var v = JSON.parse_string(l)
		if typeof(v) == TYPE_DICTIONARY and v.get("e") == "fim":
			fim = v
	_confere("grava se o campo ficou em branco", fim.has("jogador_anonimo"))
	_confere("e quantas letras tinha, sem as letras",
		int(fim.get("jogador_letras", -1)) == 10,
		"gravou %s" % fim.get("jogador_letras"))
	_confere("com o nome preenchido, anonimo é falso",
		fim.get("jogador_anonimo") == false)

	# E o caminho oposto: campo em branco tem de dizer que ficou em branco.
	_limpar()
	R._armado = false
	R.armar()
	GS.new_game()
	GS.definir_nomes("Cais Mirim", "")
	GS._end_game(false, "fim de teste")
	var fim2: Dictionary = {}
	for l in R.texto_para_exportar().split("\n", false):
		var v = JSON.parse_string(l)
		if typeof(v) == TYPE_DICTIONARY and v.get("e") == "fim":
			fim2 = v
	_confere("campo em branco grava anonimo verdadeiro",
		fim2.get("jogador_anonimo") == true)
	_b5 = true


# ── R6 ──
#
# O tempo de deliberação sai de `Time.get_ticks_msec()`, que é monotónico. Com
# a hora do sistema, acertar o relógio do telefone a meio de uma partida daria
# um turno negativo — e um turno negativo entra na mediana do leitor sem
# reprovar nada.
func _r6_relogio() -> void:
	_limpar()
	R.armar()
	GS.new_game()
	# A oferta do Arlindo pode já estar aberta à saída do `new_game()`, e nessa
	# fase o `advance_turn()` retorna sem emitir nada. Resolver antes é o que
	# faz este bloco medir o relógio em vez de medir o sorteio.
	if GS.phase == "rival_offer":
		GS.negotiate_rival("igualar")
	GS.assign_all_free_workers()
	GS.advance_turn()

	var negativos := 0
	var vistos := 0
	for l in R.texto_para_exportar().split("\n", false):
		var v = JSON.parse_string(l)
		if typeof(v) == TYPE_DICTIONARY and v.has("ms"):
			vistos += 1
			if int(v["ms"]) < 0:
				negativos += 1
	_confere("todo turno traz um tempo", vistos > 0)
	_confere("e nenhum é negativo", negativos == 0, "%d negativos" % negativos)

	# A negociação tem relógio próprio: o tempo entre a oferta abrir e o
	# jogador escolher, que é outra pergunta que o tempo de turno não responde.
	_limpar()
	R._armado = false
	R.armar()
	GS.new_game()
	var achou_negociacao := false
	for i in range(60):
		if GS.phase == "rival_offer":
			GS.negotiate_rival("metade")
			achou_negociacao = true
			continue
		if GS.phase == "debt_payment":
			GS.fail_debt()
			break
		if GS.phase == "game_over":
			break
		GS.assign_all_free_workers()
		GS.advance_turn()
	if achou_negociacao:
		var tem := false
		for l in R.texto_para_exportar().split("\n", false):
			var v = JSON.parse_string(l)
			if typeof(v) == TYPE_DICTIONARY and v.get("e") == "negociou":
				tem = true
				_confere("a negociação grava ação, resultado e tempo",
					v.has("acao") and v.has("resultado") and v.has("ms") and int(v["ms"]) >= 0)
				break
		_confere("houve contra-oferta e ela foi gravada", tem)
	else:
		print("  (nenhuma contra-oferta neste sorteio — bloco de negociação não corrido)")
	_b6 = true
