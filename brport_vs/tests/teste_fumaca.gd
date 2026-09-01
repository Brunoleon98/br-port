extends SceneTree

# ============================================================
# BR Port VS — TESTE DE FUMAÇA
#
# Item B4 do plano v3: **testes onde hoje só existe olho.** As três suítes que
# já havia perguntam "o jogo funciona?" (`run_tests.gd`), "está tudo no lugar?"
# (`teste_design.gd`) e "o som está ligado?" (`teste_audio.gd`). Nenhuma delas
# pergunta a coisa mais básica de todas: **a cena abre?**
#
# As três dores concretas que este arquivo cobre:
#
# 1. CENA QUE NÃO INSTANCIA. `scenes/proto/` tem duas cenas que nada no jogo
#    carrega. Elas podem apodrecer há semanas — apontar para um script apagado,
#    para uma textura renomeada — e nenhuma corrida reprova. O `--import` de um
#    clone novo cospe `referenced non-existent resource` e segue em frente.
#
# 2. ÍCONE REGISTRADO SEM ARQUIVO. `Icones.gd` é o único lugar que sabe qual
#    arquivo é qual ícone, e são vinte. Apagar ou renomear um SVG rebenta lá
#    dentro, num `preload`, e o erro que sai é sobre o script — não sobre o
#    ícone.
#
# 3. SAVE ADAPTADO A MEIO. É o bug que já custou **um porto com 4 docas num
#    mapa que desenha 3**. A regra escrita no `CLAUDE.md` é absoluta: save de
#    outra versão é DESCARTADO, nunca adaptado. Um save recusado que já mexeu
#    no estado vivo é adaptação a meio com outro nome.
#
# POR QUE LER O `Icones.gd` COMO TEXTO, E NÃO CARREGAR A CLASSE. Se um ícone
# sumir do disco, o `preload` derruba a compilação do próprio `Icones.gd` — e
# um teste que dependesse da classe morreria junto, devolvendo um erro sobre
# GDScript em vez de dizer qual ícone falta. Lendo o arquivo-fonte, o teste
# sobrevive ao defeito que ele existe para nomear.
#
# Rodar:
#   Godot --headless --path brport_vs --script res://tests/teste_fumaca.gd
# ============================================================

const FONTE_ICONES := "res://scripts/Icones.gd"
const PASTA_ICONES := "res://art/icones"

# Pastas que a varredura não desce. `.godot` é cache de import — o que vive lá
# é cópia gerada, e conferi-la é conferir o mesmo arquivo duas vezes.
const PASTAS_IGNORADAS := [".godot", ".import"]

var _falhas := 0
var _feito := false

# O identificador global de um autoload NÃO existe num script de `--script`:
# é preciso buscar pela raiz. E `GS` sai daí destipado, então toda variável que
# receba algo dele leva o tipo escrito à mão (ver "Estilo de código" no
# CLAUDE.md — isto já custou três corridas num dia).
var GS: Node


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
	GS = root.get_node("GameState")

	print("=== F1: toda cena do projeto abre ===")
	_f1_fumaca_de_cena()

	print("=== F2: todo ícone registrado tem arquivo ===")
	_f2_icones()

	print("=== F3: save de outra versão é descartado, nunca adaptado ===")
	_f3_migracao_de_save()

	print("=== F4: o texto narrativo não chega ao jogador com token cru ===")
	_f4_narrativa()
	_f4_numeros_do_fim()

	if _falhas == 0:
		print("\n=== FUMACA OK — as cenas abrem, os ícones existem, o save não migra, o texto resolve ===")
		quit(0)
	else:
		print("\n=== FUMACA FALHOU — %d problema(s) ===" % _falhas)
		quit(1)


# ── F1 ──────────────────────────────────────────────────────────────────
# Instancia TODAS as `.tscn` do projeto, achadas por varredura e não por lista:
# uma lista escrita à mão envelhece calada, e a cena nova — justamente a que
# ninguém testou ainda — seria a que ficaria de fora.
func _f1_fumaca_de_cena() -> void:
	var cenas: Array[String] = []
	_varrer_cenas("res://", cenas)
	cenas.sort()

	# Uma varredura que não acha nada "passa" sem conferir coisa nenhuma. Já
	# aconteceu neste projeto com outro validador: o passo anterior falhou
	# calado e o seguinte deu OK sobre um conjunto vazio.
	_confere("a varredura achou cenas para conferir (%d)" % cenas.size(),
		cenas.size() >= 8, "achou %d — a varredura quebrou?" % cenas.size())

	for caminho in cenas:
		var nome := caminho.trim_prefix("res://")

		# Dependência que sumiu não impede o `load()` de devolver a cena: o
		# Godot troca o recurso perdido por null e segue. Por isso se confere
		# o cabeçalho da `.tscn` ANTES de instanciar — é lá que está a lista
		# de tudo o que a cena precisa que exista.
		var faltando := _dependencias_faltando(caminho)
		_confere("%s: as dependências existem" % nome, faltando.is_empty(),
			"não existe(m): " + ", ".join(faltando))

		var empacotada := load(caminho)
		if empacotada == null or not (empacotada is PackedScene):
			_confere("%s: carrega" % nome, false, "load() devolveu null")
			continue

		var no: Node = (empacotada as PackedScene).instantiate()
		if no == null:
			_confere("%s: instancia" % nome, false, "instantiate() devolveu null")
			continue

		# Entrar na árvore é o que dispara `_ready()`. Uma cena que carrega e
		# instancia mas rebenta ao entrar continuaria verde sem este passo.
		root.add_child(no)
		_confere("%s: abre (%d nós)" % [nome, _contar_nos(no)],
			no.is_inside_tree())

		# O script que a `.tscn` declara pode não ter compilado — nesse caso o
		# nó nasce SEM script e o jogo roda mudo. O sintoma é a cena que abre
		# e não faz nada, que é pior do que a cena que não abre.
		var sem_script := _nos_sem_o_script_declarado(no, caminho)
		_confere("%s: os scripts declarados compilaram" % nome,
			sem_script.is_empty(), "sem script: " + ", ".join(sem_script))

		root.remove_child(no)
		no.queue_free()


func _varrer_cenas(pasta: String, achadas: Array[String]) -> void:
	var dir := DirAccess.open(pasta)
	if dir == null:
		return
	dir.list_dir_begin()
	var nome := dir.get_next()
	while nome != "":
		var completo := pasta.path_join(nome)
		if dir.current_is_dir():
			if not nome.begins_with(".") and not PASTAS_IGNORADAS.has(nome):
				_varrer_cenas(completo, achadas)
		elif nome.ends_with(".tscn"):
			achadas.append(completo)
		nome = dir.get_next()
	dir.list_dir_end()


# Lê os `[ext_resource ... path="res://..."]` do cabeçalho da cena e devolve os
# que não existem no disco. É o texto da `.tscn` de propósito: perguntar ao
# recurso já carregado é perguntar depois de o Godot ter engolido a falta.
func _dependencias_faltando(caminho_cena: String) -> Array[String]:
	var faltando: Array[String] = []
	var f := FileAccess.open(caminho_cena, FileAccess.READ)
	if f == null:
		return faltando
	var texto := f.get_as_text()
	f.close()

	var re := RegEx.new()
	re.compile('\\[ext_resource[^\\]]*path="(res://[^"]+)"')
	for casamento in re.search_all(texto):
		var alvo := casamento.get_string(1)
		if not ResourceLoader.exists(alvo) and not FileAccess.file_exists(alvo):
			faltando.append(alvo)
	return faltando


# Junta os nós que a `.tscn` declara com script e confere se o nó vivo tem um.
# A ligação entre os dois é o `[node name=...]` seguido de `script = ...` no
# mesmo bloco — que é como o formato de cena do Godot 4 escreve isto.
func _nos_sem_o_script_declarado(raiz: Node, caminho_cena: String) -> Array[String]:
	var sem: Array[String] = []
	var f := FileAccess.open(caminho_cena, FileAccess.READ)
	if f == null:
		return sem
	var linhas := f.get_as_text().split("\n")
	f.close()

	var atual := ""
	var caminho_no := ""
	for linha in linhas:
		var limpa := linha.strip_edges()
		if limpa.begins_with("[node "):
			atual = _atributo(limpa, "name")
			var pai := _atributo(limpa, "parent")
			if pai == "" or pai == ".":
				caminho_no = atual
			else:
				caminho_no = pai + "/" + atual
		elif limpa.begins_with("script = ") and atual != "":
			var no: Node = raiz if caminho_no == atual and raiz.name == atual \
				else raiz.get_node_or_null(NodePath(_relativo(caminho_no, raiz)))
			if no != null and no.get_script() == null:
				sem.append(caminho_no)
			atual = ""
	return sem


# O primeiro segmento do caminho na `.tscn` é o nome da própria raiz quando o
# nó é filho dela; o `get_node` da raiz não o quer de volta.
func _relativo(caminho_no: String, raiz: Node) -> String:
	if caminho_no == String(raiz.name):
		return "."
	return caminho_no


func _atributo(linha: String, chave: String) -> String:
	var re := RegEx.new()
	re.compile('%s="([^"]*)"' % chave)
	var achou := re.search(linha)
	return achou.get_string(1) if achou != null else ""


func _contar_nos(no: Node) -> int:
	var n := 1
	for filho in no.get_children():
		n += _contar_nos(filho)
	return n


# ── F2 ──────────────────────────────────────────────────────────────────
func _f2_icones() -> void:
	var f := FileAccess.open(FONTE_ICONES, FileAccess.READ)
	if f == null:
		_confere("%s existe" % FONTE_ICONES, false)
		return
	var fonte := f.get_as_text()
	f.close()

	var re := RegEx.new()
	re.compile('const\\s+([A-Z0-9_]+)\\s*:=\\s*preload\\("(res://art/icones/[^"]+)"\\)')
	var registrados := {}
	for casamento in re.search_all(fonte):
		registrados[casamento.get_string(1)] = casamento.get_string(2)

	# Vinte é o número que o CLAUDE.md afirma e que a folha de contato conferiu.
	# Se o registro encolher sem ninguém dizer, isto pergunta porquê.
	_confere("Icones.gd registra os 20 ícones (achou %d)" % registrados.size(),
		registrados.size() == 20)

	for id in registrados:
		var caminho: String = registrados[id]
		var existe := FileAccess.file_exists(caminho)
		_confere("%s -> %s" % [id, caminho.get_file()], existe,
			"registrado em Icones.gd e não existe no disco")
		if not existe:
			continue

		# O `.import` é o que o Godot lê para saber rasterizar o SVG. Ele entra
		# no Git de propósito (ver .gitignore) — um SVG versionado sem o seu
		# `.import` carrega aqui, onde o `--import` acabou de o regerar, e
		# falha na máquina de quem clonar.
		_confere("%s tem o .import versionado" % caminho.get_file(),
			FileAccess.file_exists(caminho + ".import"))

		var textura := load(caminho)
		_confere("%s carrega como textura" % caminho.get_file(),
			textura != null and textura is Texture2D)

	# O caminho contrário: SVG na pasta que ninguém registrou. É arte morta —
	# ou, pior, um ícone que alguém desenhou e a interface nunca usou porque o
	# registro ficou por fazer.
	var no_disco := _svgs_na_pasta()
	var orfaos: Array[String] = []
	var caminhos_registrados := registrados.values()
	for caminho in no_disco:
		if not caminhos_registrados.has(caminho):
			orfaos.append(caminho.get_file())
	_confere("nenhum SVG solto em %s" % PASTA_ICONES, orfaos.is_empty(),
		"no disco e fora do Icones.gd: " + ", ".join(orfaos))


func _svgs_na_pasta() -> Array[String]:
	var achados: Array[String] = []
	var dir := DirAccess.open(PASTA_ICONES)
	if dir == null:
		return achados
	dir.list_dir_begin()
	var nome := dir.get_next()
	while nome != "":
		if not dir.current_is_dir() and nome.ends_with(".svg"):
			achados.append(PASTA_ICONES.path_join(nome))
		nome = dir.get_next()
	dir.list_dir_end()
	return achados


# ── F3 ──────────────────────────────────────────────────────────────────
# A suíte de lógica já cobre o caso conhecido (save SEM campo de versão, que
# foi o do porto de 4 docas). O que falta é a regra inteira, e sobretudo o seu
# lado incômodo: **recusar é recusar sem ter tocado em nada.**
func _f3_migracao_de_save() -> void:
	var versao: int = GS.SAVE_VERSION

	_confere("um save recusado não deixa arquivo para trás (versão %d)" % (versao - 1),
		_recusa_e_apaga(_save_valido(versao - 1)))
	_confere("save de versão FUTURA também é recusado (versão %d)" % (versao + 1),
		_recusa_e_apaga(_save_valido(versao + 1)))
	_confere("save sem campo de versão nenhum é recusado",
		_recusa_e_apaga(_sem_a_chave(_save_valido(versao), "versao")))
	# Lixo com a extensão certa segue a mesma regra: não é save de versão
	# nenhuma, então sai do disco. Deixá-lo lá é o jogador a arrancar todos os
	# dias contra o mesmo arquivo, sem lugar nenhum onde o possa apagar.
	_confere("arquivo que não é JSON de objeto é recusado e apagado",
		_recusa_texto("isto não é um save"))

	# O CORAÇÃO DESTE BLOCO. Um save da versão CORRENTE mas impossível — roster
	# vazio — tem de ser recusado sem deixar rasto no estado vivo. Enquanto o
	# `load_game()` escrevia campo a campo antes de decidir, o jogo ficava com
	# `turn` e `cash` do arquivo recusado e zero docas; sobrevivia só porque o
	# `new_game()` que vem logo a seguir por acaso reescreve tudo. Bastava um
	# campo novo no save que o `new_game()` não zerasse para o estado impossível
	# passar para a partida seguinte — que é, letra por letra, o bug das 4 docas.
	_novo_jogo()
	GS.cash = 3250
	GS.turn = 1
	var caixa_antes: int = GS.cash
	var turno_antes: int = GS.turn
	var docas_antes: int = GS.docks.size()

	var impossivel := _save_valido(versao)
	impossivel["turn"] = 42
	impossivel["cash"] = 777
	impossivel["docks"] = []
	impossivel["workers"] = []
	_escrever(impossivel)

	var carregou: bool = GS.load_game()
	_confere("save da versão corrente com roster vazio é recusado", carregou == false)
	_confere("e o caixa vivo não foi tocado (%d)" % caixa_antes, GS.cash == caixa_antes,
		"ficou %d — o estado foi adaptado a meio" % GS.cash)
	_confere("nem o turno (%d)" % turno_antes, GS.turn == turno_antes,
		"ficou %d — o estado foi adaptado a meio" % GS.turn)
	_confere("nem as docas (%d)" % docas_antes, GS.docks.size() == docas_antes,
		"ficaram %d — o estado foi adaptado a meio" % GS.docks.size())
	_confere("e o arquivo impossível foi apagado",
		not FileAccess.file_exists(GS.SAVE_PATH),
		"sobrou no disco para ser tentado outra vez no próximo arranque")

	# E o contrário, que é o que impede este bloco de virar "recusa tudo": o
	# save da versão certa continua a voltar inteiro.
	_novo_jogo()
	GS.cash = 4321
	GS.turn = 7
	GS.save_game()
	GS.cash = 0
	GS.turn = 1
	_confere("o save da versão corrente carrega", GS.load_game() == true)
	_confere("e traz caixa e turno de volta", GS.cash == 4321 and GS.turn == 7)
	GS.clear_save()


func _novo_jogo() -> void:
	GS.new_game()
	if GS.phase == "rival_offer":
		GS.resolve_rival_offer(true)


# Um save com a forma toda certa, parametrizado só pela versão. Serve de base
# para cada defeito ser injetado um de cada vez.
func _save_valido(versao: int) -> Dictionary:
	return {
		"versao": versao, "turn": 5, "cash": 1234, "reputation": 70.0,
		"docks": [{"boat": null, "worker_id": null}],
		"workers": [{"id": 1, "busy_turns": 0}],
		"upgrade_purchased": false, "estruturas": [], "parcela_paid": false,
		"phase": "playing", "pending_rival_dock": -1, "rival_attempts_left": 2,
		"end_reason": "", "won": false, "metrics": {}, "uid": 9,
	}


func _sem_a_chave(dados: Dictionary, chave: String) -> Dictionary:
	dados.erase(chave)
	return dados


func _escrever(dados: Dictionary) -> void:
	_recusa_texto_escrever(JSON.stringify(dados))


func _recusa_texto_escrever(texto: String) -> void:
	var f := FileAccess.open(GS.SAVE_PATH, FileAccess.WRITE)
	f.store_string(texto)
	f.close()


# Escreve o save, tenta carregar e devolve true só se as duas metades da regra
# valerem: recusou E apagou. Um save recusado que fica no disco é tentado outra
# vez a cada arranque, e o jogador não tem como o remover.
func _recusa_e_apaga(dados: Dictionary) -> bool:
	_novo_jogo()
	_escrever(dados)
	var carregou: bool = GS.load_game()
	return carregou == false and not FileAccess.file_exists(GS.SAVE_PATH)


func _recusa_texto(texto: String) -> bool:
	_novo_jogo()
	_recusa_texto_escrever(texto)
	var carregou: bool = GS.load_game()
	return carregou == false and not FileAccess.file_exists(GS.SAVE_PATH)


# ── F4 ──────────────────────────────────────────────────────────────────
# O texto narrativo é escrito com tokens — `{portName}`, `{playerName}` — que
# `GameState.texto()` resolve. Um token com erro de digitação não dá erro
# nenhum: ele atravessa a substituição intacto e aparece na tela, cru, no meio
# de uma fala. É o defeito que só o olho pega, numa tela que talvez só apareça
# na semana 4 de uma partida.
#
# Os tokens permitidos são estes e mais nenhum. Os três últimos não são de
# nome: têm resolvedor próprio (o vocativo do Sr. Ribeiro, o valor da parcela,
# a semana e o dia do boletim) e por isso podem aparecer no texto BRUTO — mas
# não podem sobreviver ao resolvedor, que é o que a segunda metade confere.
const TOKENS_CONHECIDOS := ["portName", "playerName", "vocativo", "valor",
	"semana", "dia"]


func _f4_narrativa() -> void:
	# As constantes são lidas do próprio script, e não de uma lista escrita à
	# mão: a lista envelheceria, e o texto novo — o que ninguém reviu ainda —
	# seria justamente o que ficaria de fora.
	var script: GDScript = load("res://scripts/Narrativa.gd")
	var constantes: Dictionary = script.get_script_constant_map()
	_confere("Narrativa.gd expõe as constantes de texto (%d)" % constantes.size(),
		constantes.size() >= 12)

	var re := RegEx.new()
	re.compile("\\{([A-Za-z_]+)\\}")

	var textos := 0
	for nome in constantes:
		for pedaco in _strings_de(constantes[nome]):
			textos += 1
			for casamento in re.search_all(pedaco):
				var token := casamento.get_string(1)
				_confere("%s: token {%s} é conhecido" % [nome, token],
					TOKENS_CONHECIDOS.has(token),
					"tokens válidos: " + ", ".join(TOKENS_CONHECIDOS))
	_confere("achou texto para conferir (%d pedaços)" % textos, textos >= 20)

	# E agora o outro lado: o que sai dos resolvedores não pode ter token
	# nenhum. Com nome de jogador e sem, porque o vocativo é o caso que muda.
	GS.new_game()
	GS.definir_nomes("Cais do Norte", "Bruno")
	_sem_token_cru("com nome de jogador")
	GS.new_game()
	GS.definir_nomes("", "")
	_sem_token_cru("sem nome de jogador (e porto no padrão)")

	# O porto em branco tem de virar o padrão do GDD, e não ficar vazio: se
	# ficasse, `precisa_dos_nomes()` daria true outra vez no arranque seguinte e
	# a tela reapareceria — contra a regra de a escolha ser irrevogável.
	_confere("porto em branco vira %s" % GS.NOME_PORTO_PADRAO,
		GS.nome_porto == GS.NOME_PORTO_PADRAO)
	_confere("e a tela de nomes não volta a pedir", not GS.precisa_dos_nomes())

	# O nome do jogador NÃO ganha padrão — inventar um seria pôr palavra na
	# boca de quem não a escolheu.
	_confere("o nome do jogador em branco continua em branco", GS.nome_jogador == "")

	GS.new_game()
	_confere("partida nova volta a pedir os nomes", GS.precisa_dos_nomes())

	# O corte no tamanho vive no GameState e não na tela: dois limites seriam
	# duas regras, e a que a tela não aplicasse chegaria ao save.
	GS.definir_nomes("x".repeat(GS.NOME_MAX_CARACTERES + 20), "  Bruno  ")
	_confere("nome do porto é cortado em %d" % GS.NOME_MAX_CARACTERES,
		GS.nome_porto.length() == GS.NOME_MAX_CARACTERES)
	_confere("e o do jogador perde o espaço das pontas", GS.nome_jogador == "Bruno")

	# Os dois nomes entram no save. É por eles que o SAVE_VERSION subiu para 3,
	# e o bloco F3 acima é que garante que um save da versão 2 é descartado em
	# vez de carregar sem nome nenhum.
	GS.new_game()
	GS.definir_nomes("Cais do Sul", "Bruno")
	GS.nome_porto = "sujo"
	GS.nome_jogador = "sujo"
	_confere("o save traz os dois nomes de volta", GS.load_game() == true)
	_confere("o do porto", GS.nome_porto == "Cais do Sul")
	_confere("e o do jogador", GS.nome_jogador == "Bruno")
	GS.clear_save()

	# Toda linha registrada da Dona Cida tem de devolver texto. Uma chave com
	# erro de digitação devolve vazio, e vazio na tela é um balão de fala mudo.
	var linhas: Dictionary = constantes.get("CIDA_LINHAS", {})
	_confere("as 8 linhas de loop da Dona Cida estão lá", linhas.size() == 8)
	for id in linhas:
		_confere("Cida: %s tem fala" % id, Narrativa.cida(String(id)) != "")


# Devolve todos os pedaços de texto de uma constante — a própria, se for
# String, ou os valores, se for o dicionário de falas.
func _strings_de(valor) -> Array[String]:
	var saida: Array[String] = []
	if typeof(valor) == TYPE_STRING:
		saida.append(String(valor))
	elif typeof(valor) == TYPE_DICTIONARY:
		for chave in valor:
			if typeof(valor[chave]) == TYPE_STRING:
				saida.append(String(valor[chave]))
	return saida


# O que os resolvedores devolvem não pode ter chaveta nenhuma.
func _sem_token_cru(caso: String) -> void:
	var saidas := {
		"diário": Narrativa.diario(),
		"Sr. Ribeiro (entrada)": Narrativa.ribeiro_entrada(),
		"Sr. Ribeiro (a dívida)": Narrativa.ribeiro_a_divida(GS.PARCELA_AMOUNT),
		"fim de fase": Narrativa.fim_de_fase(),
		"Arlindo (abertura)": GS.texto(Narrativa.ARLINDO_ABERTURA),
		"Arlindo (venceu)": GS.texto(Narrativa.ARLINDO_VENCEU),
	}
	for nome in saidas:
		var texto: String = saidas[nome]
		_confere("%s — %s sem token cru" % [caso, nome],
			not texto.contains("{"), "saiu: " + texto.left(60))


# A narração de fim de fase conta o jogo que EXISTE. O rascunho de escrita
# falava de doze semanas e três parcelas, que é a Fase 1 do GDD e não o VS —
# e um número escrito à mão no texto é um número a mais para envelhecer.
func _f4_numeros_do_fim() -> void:
	var texto: String = Narrativa.fim_de_fase()
	var semanas: int = GS.WEEKS_TOTAL
	_confere("o fim de fase diz as %d semanas que o jogo tem" % semanas,
		texto.begins_with("%d semanas" % semanas),
		"começa com: " + texto.left(30))
	_confere("e os %d turnos que elas dão" % GS.TURNS_TOTAL,
		texto.contains("%d turnos" % GS.TURNS_TOTAL))
