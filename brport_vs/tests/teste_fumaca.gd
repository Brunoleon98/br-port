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
	_f4_toda_fala_chega_ao_jogo()

	print("=== F5: o projeto continua exportável para o telefone ===")
	_f5_exportavel_para_android()

	print("=== F6: a abertura não deixa o turno preso numa fase que bloqueia ===")
	_f6_abertura_nao_prende_o_turno()

	print("=== F7: toda fala tem cara, toda cara tem arquivo, e toda cara é usada ===")
	_f7_retratos()
	_f7_despedida_do_arlindo_acontece()

	if _falhas == 0:
		print("\n=== FUMACA OK — as cenas abrem, os ícones existem, o save não migra, o texto resolve, o export vale ===")
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

	# ⚠️ AQUI DIZIA `registrados.size() == 20`, E ERA UM NÚMERO CRAVADO NUMA
	# ASSERÇÃO — a mesma armadilha que o `CLAUDE.md` regista para o turno
	# amostrado e para o offset do letreiro. Ele reprovava o ícone número 21
	# sem nada estar errado, que é o vermelho que ensina a subir o número em
	# vez de olhar; e o que ele queria perguntar — "o registro encolheu sem
	# ninguém dizer?" — as duas varreduras abaixo já respondem melhor, uma em
	# cada direção: toda constante tem arquivo, e todo arquivo tem constante.
	#
	# ⚠️ E A PRIMEIRA TENTATIVA DE CONSERTO FOI ESCREVER A SEGUNDA DELAS OUTRA
	# VEZ, dez linhas acima de onde ela já estava. É a guarda que outra já
	# implica, do `CLAUDE.md`: antes de acrescentar asserção sobre uma coisa
	# que já tem duas, o que se procura é o estado que a violaria sem violar
	# as outras — e aqui não havia nenhum.

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
	# Do START_CASH, e não cravado: 3250 era o caixa inicial antes da reescala
	# de 02/09 e passaria a ler como um número mágico qualquer.
	GS.cash = GS.START_CASH
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
const TOKENS_CONHECIDOS := ["portName", "playerName", "caixaInicial",
	"vocativo", "valor", "semana", "dia"]


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

	# ── Dinheiro em prosa, e são DUAS perguntas que nada fazia ──
	#
	# Esta pergunta pela FORMA: nenhuma fala escreve um valor à mão. A regra já
	# existia no CLAUDE.md e já custou uma vez — a narração de fim de fase dizia
	# "Doze semanas / Três parcelas", que é a Fase 1 do GDD e não o VS —, e nada
	# a trancava. Vale a FORMA e não o valor de propósito: um valor escrito à mão
	# COINCIDE com a constante no dia em que é escrito, e só divergiria na
	# sessão seguinte, quando ninguém está a olhar. O `START_CASH` já foi
	# varrido em sete pontos uma vez (`docs/decisoes/018`).
	var re_dinheiro := RegEx.new()
	re_dinheiro.compile("R\\$\\s*\\d")
	var com_dinheiro: Array = []
	for nome in constantes:
		for pedaco in _strings_de(constantes[nome]):
			if re_dinheiro.search(pedaco) != null:
				com_dinheiro.append(nome)
	_confere("nenhuma fala escreve valor à mão (achadas: %d)" % com_dinheiro.size(),
		com_dinheiro.is_empty(),
		"use um token resolvido por GameState.texto(): " + ", ".join(com_dinheiro))

	# E esta pela FONTE: o número que chega à tela é o da constante, e não outra
	# qualquer. A guarda acima não a implica — o texto bruto passa com o token no
	# lugar, mesmo que o resolvedor o troque por `PARCELA_AMOUNT` num
	# copiar-colar. E o `_sem_token_cru` abaixo também não: ele prova que o token
	# foi resolvido, nunca por quê.
	#
	# ⚠️ E SÃO DUAS, NÃO TRÊS. Havia aqui uma terceira — que o diário CONTÉM
	# `{caixaInicial}` —, e ela nunca falharia sozinha: apagar a frase derruba
	# esta também (o valor deixa de aparecer), e escrever o valor à mão derruba a
	# de cima. Asserção que nenhuma mudança viola em exclusivo é confiança de
	# graça, e o CLAUDE.md manda procurar esse estado antes de a escrever.
	_confere("o diário conta o caixa inicial, e com o valor do START_CASH (%s)"
		% GS.moeda(GS.START_CASH),
		GS.texto(Narrativa.DIARIO_PRIMEIRA_PAGINA).contains(GS.moeda(GS.START_CASH)))

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
# ⚠️ TODA FALA ESCRITA CHEGA AO JOGO? É a pergunta INVERSA, e nada a fazia.
#
# O bloco ao lado confere que todo id da tabela tem texto — e lê a tabela dos
# DOIS lados, logo não pode reprovar uma fala que ninguém dispara: apagar o
# gatilho deixa-a contente. Medido em 12/09: `perdeu_para_arlindo` e
# `bom_contrato` estavam escritas desde 01/09 e MUDAS, um quarto da voz da Dona
# Cida em jogo. É o `barco_medio` outra vez (renderizado, validado, e nunca
# posto em doca nenhuma), e a terceira vez que este projeto o apanha.
#
# A SEGUNDA FONTE é o `Main.gd`: a tabela vive na Narrativa e o gatilho no
# Main, então comparar os dois não é um espelho. Lê-se o ARQUIVO e não o nó,
# porque abrir a cena para isto custaria a árvore inteira.
#
# E as linhas de COMENTÁRIO saem antes da busca: este mesmo bloco nomeia as
# duas falas na prosa acima, e sem o corte elas contar-se-iam a si próprias —
# que é a regra do `contains()` do CLAUDE.md a morder de novo.
func _f4_toda_fala_chega_ao_jogo() -> void:
	var fonte := FileAccess.get_file_as_string("res://scripts/Main.gd")
	_confere("o Main.gd foi lido", fonte != "")
	var disparados := {}
	for linha in fonte.split("\n"):
		var limpa := linha.strip_edges()
		if limpa.begins_with("#"):
			continue
		if not limpa.contains("_cida("):
			continue
		# TODAS as strings da linha, e não a primeira a seguir ao parêntesis:
		# o `reputacao_caiu` vive dentro de um ternário na própria chamada
		# (`_cida("subiu" if ... else "caiu")`), e uma busca que parasse na
		# primeira dava-o por mudo. Apanhado por esta asserção na estreia dela.
		var partes := limpa.split("\"")
		var k := 1
		while k < partes.size():
			disparados[String(partes[k])] = true
			k += 2
	var mudas := []
	for id in Narrativa.CIDA_LINHAS:
		if not disparados.has(String(id)):
			mudas.append(String(id))
	_confere("as %d falas da Dona Cida chegam todas ao jogo" % Narrativa.CIDA_LINHAS.size(),
		mudas.is_empty(), "mudas: " + ", ".join(mudas))


# ⚠️ E ELA PROCURA O NÚMERO POR EXTENSO, não o dígito. A primeira versão
# comparava `"%d semanas"` com a constante — o que provava a ligação, e de
# caminho TRANCAVA A PROSA no formato de planilha: em 12/09 a narração passou a
# dizer "Quatro semanas." e esta guarda reprovou um texto que estava certo.
# Dígito no meio de uma peça literária lê como leitura de instrumento, e a
# guarda tinha virado a razão de ele continuar lá. A ligação à constante
# continua provada, porque o esperado sai de `por_extenso(GS.WEEKS_TOTAL)` —
# mexer na constante move os dois lados, mas mexer no TEXTO à mão reprova.
func _f4_numeros_do_fim() -> void:
	var texto: String = Narrativa.fim_de_fase()
	var semanas: String = Narrativa.por_extenso(GS.WEEKS_TOTAL)
	_confere("o fim de fase diz as %s semanas que o jogo tem" % semanas,
		texto.to_lower().begins_with("%s semanas" % semanas),
		"começa com: " + texto.left(30))
	# E O ARCO: a Fase 1 do GDD tem três parcelas e o VS paga a primeira. O
	# esperado sai da CONSTANTE, então mexer nela move os dois lados — e mexer
	# no TEXTO à mão reprova, que é o ponto.
	var total: String = Narrativa.por_extenso(GS.PARCELAS_NA_FASE)
	var restantes: String = Narrativa.por_extenso(GS.PARCELAS_NA_FASE - 1)
	_confere("e que esta é a primeira de %s parcelas" % total,
		texto.to_lower().contains("primeira de %s parcelas" % total),
		"não achou em: " + texto.left(60))
	_confere("e quantas faltam (%s)" % restantes,
		texto.to_lower().contains("faltam %s" % restantes),
		"não achou em: " + texto.left(80))
	# E NENHUM DÍGITO na narração inteira, que é a metade que faltava: sem
	# isto, alguém volta a escrever "32 dias" e as duas asserções acima
	# continuam contentes, porque elas só perguntam o que ESTÁ lá.
	var tem_digito := false
	for c in texto:
		if c >= "0" and c <= "9":
			tem_digito = true
	_confere("e não escreve número nenhum em dígito",
		not tem_digito, "saiu: " + texto.left(60))


# ── F5 ──────────────────────────────────────────────────────────────────
# O EXPORT ANDROID FALHA EM SILÊNCIO, e isto existe para o silêncio acabar.
#
# `has_valid_export_configuration()` do Android faz uns vinte testes e, de
# todos, há UM que reprova sem acrescentar mensagem nenhuma: o do ETC2/ASTC
# (platform/android/export/export_plugin.cpp:3071, na 4.6.3). O que o CI
# imprimiu foi exatamente isto:
#
#     ERROR: Cannot export project with preset "Android" due to
#     configuration errors:
#     <nada>
#
# Uma lista de erros vazia, e nenhum caminho para o próximo passo. Custou ler
# o código-fonte do motor para saber qual dos vinte tinha reprovado.
#
# E é pior do que parecer só chato: SEM A OPÇÃO LIGADA o Godot importa ETC2/
# ASTC apenas quando o sistema operativo onde se exporta prefere esse formato.
# Isso é verdade num Mac e falso em Linux — o mesmo projeto, o mesmo commit,
# exporta numa máquina e não noutra. Um teste aqui é a diferença entre saber
# disto num segundo e voltar a passar pela mesma corrida de CI.
#
# Não substitui o export de verdade, que só corre no CI: prova o pré-requisito
# que o export não sabe nomear, na suíte que corre em toda parte.
func _f5_exportavel_para_android() -> void:
	# RETRATO, e conferido como INTEIRO. O projeto trazia a string "portrait"
	# — valor do Godot 3 — e o export do Android faz `int()` dela, que dá 0,
	# que é LANDSCAPE. O APK de 02/09 abriu deitado num telefone real. O tipo
	# faz parte da asserção porque era o tipo que estava errado: uma string
	# aqui não dá erro nenhum, dá um jogo virado.
	var giro = ProjectSettings.get_setting("display/window/handheld/orientation")
	_confere("a orientação é um INTEIRO, não a string do Godot 3",
		typeof(giro) == TYPE_INT, "veio %s" % type_string(typeof(giro)))
	_confere("e é retrato travado (SCREEN_PORTRAIT)",
		int(giro) == DisplayServer.SCREEN_PORTRAIT,
		"veio %d, e LANDSCAPE é %d" % [int(giro), DisplayServer.SCREEN_LANDSCAPE])

	_confere("o ETC2/ASTC está ligado no project.godot",
		bool(ProjectSettings.get_setting(
			"rendering/textures/vram_compression/import_etc2_astc", false)),
		"sem isto o export do APK reprova com a lista de erros VAZIA")

	# O preset é lido como TEXTO, e de propósito: um `ConfigFile` engasga-se
	# com `PackedStringArray(...)` nos valores, e o que interessa aqui não é
	# o valor de cada campo — é que o arquivo exista, tenha os dois presets, e
	# continue SEM CHAVE NENHUMA dentro. É esta última parte que um dia alguém
	# quebra sem reparar, ao gerar o preset clicando no editor.
	var caminho := "res://export_presets.cfg"
	if not FileAccess.file_exists(caminho):
		_confere("o export_presets.cfg está versionado", false,
			"não achei " + caminho)
		return
	_confere("o export_presets.cfg está versionado", true)

	var texto := FileAccess.get_file_as_string(caminho)
	for nome in ["Android", "Web"]:
		_confere("o preset \"%s\" está lá" % nome,
			texto.contains('name="%s"' % nome))

	# Só as LINHAS DE VALOR interessam, e é uma correção que custou uma
	# injeção falhada: procurar no arquivo inteiro faz o teste passar por
	# causa dos próprios comentários que explicam a regra.
	var valores: Array[String] = []
	for linha in texto.split("\n"):
		var limpa := linha.strip_edges()
		if not limpa.begins_with(";") and limpa.contains("="):
			valores.append(limpa)

	for campo in ["keystore/release", "keystore/release_user",
			"keystore/debug", "keystore/debug_user"]:
		var achado := ""
		for linha in valores:
			if linha.begins_with(campo + "="):
				achado = linha
		_confere("%s continua sem chave" % campo,
			achado == "" or achado.ends_with('=""'),
			"chave versionada é chave comprometida — achei: " + achado)

	# As pastas que NÃO entram no pacote. A primeira versão do preset levou as
	# cinco suítes, o simulador e as capturas para dentro do .pck — peso que o
	# jogador baixa para nunca usar. Uma pasta nova de ferramentas entra aqui.
	#
	# CADA PASTA É CONFERIDA COMO ITEM DA LISTA, não como pedaço de texto. Com
	# `contains("tests/*")` o teste passava com o `tests/*` REMOVIDO do filtro,
	# porque `scenes/tests/*` — que continua lá — o contém. Injetei o defeito,
	# vi-o passar, e foi assim que se descobriu. Um `contains()` num arquivo de
	# configuração quase nunca é a pergunta que se quer fazer.
	var filtros: Array[String] = []
	for linha in valores:
		if linha.begins_with("exclude_filter="):
			var lista := linha.split("=", true, 1)[1].strip_edges().trim_prefix('"').trim_suffix('"')
			var desta: Array[String] = []
			for item in lista.split(","):
				desta.append(item.strip_edges())
			filtros.append(",".join(desta))

	_confere("os dois presets têm filtro de exclusão", filtros.size() == 2,
		"achei %d" % filtros.size())
	for pasta in ["tests/*", "tools/*", "scripts/validation/*",
			"scenes/proto/*", "scenes/tests/*"]:
		var em_todos := filtros.size() > 0
		for f in filtros:
			if not ("," + f + ",").contains("," + pasta + ","):
				em_todos = false
		_confere("%s fica fora dos dois pacotes" % pasta, em_todos)


# ── F6 ──────────────────────────────────────────────────────────────────
# O BUG QUE O PRIMEIRO PLAYTEST NO TELEFONE ENCONTROU (Análise 1, 02/09):
# "a oferta do rival no primeiro dia travou o turno mesmo com o navio ocupando
# o píer". Trinta por cento das instalações novas.
#
# O mecanismo, e ele não dá erro nenhum:
#   1. `GameState._ready()` chama `new_game()` → `_spawn_boats()`, que tem 30%
#      de pôr a fase em `rival_offer` e emitir `rival_offer_triggered`;
#   2. isso corre no AUTOLOAD, antes de o `Main` existir para escutar;
#   3. `Main._ready()` via `precisa_dos_nomes()` e fazia `return`, saltando o
#      bloco que reabre o painel da fase;
#   4. fechada a abertura, a fase continuava `rival_offer` sem painel — e o
#      `advance_turn()` retorna CALADO fora de "playing".
#
# É a irmã de cena da regra "tela nova é overlay, nunca fase do GameState": as
# duas produzem um jogo preso sem uma linha de erro. Este bloco monta a
# situação exata e percorre a abertura até ao fim.
func _f6_abertura_nao_prende_o_turno() -> void:
	var cena := load("res://scenes/Main.tscn") as PackedScene
	if cena == null:
		_confere("Main.tscn carrega", false)
		return

	# A situação: partida nova (os dois nomes por escolher) E a contra-oferta
	# já aberta pelo sorteio do `new_game()`.
	GS.new_game()
	GS.nome_porto = ""
	GS.nome_jogador = ""
	if GS.docks[0]["boat"] == null:
		GS.docks[0]["boat"] = GS._make_boat()
	GS.pending_rival_dock = 0
	GS.rival_attempts_left = GS.RIVAL_PATIENCE
	GS._set_phase("rival_offer")
	_confere("a montagem deixou o jogo em rival_offer com barco no píer",
		GS.phase == "rival_offer" and GS.docks[0]["boat"] != null)

	var main: Node = cena.instantiate()
	root.add_child(main)          # `_ready()` corre já aqui, sem esperar frame

	var overlay: Node = main.get_node_or_null("Overlay")
	if overlay == null:
		_confere("o Main tem a camada Overlay", false)
		main.free()
		return

	# Percorre a abertura: nomes → diário → mapa. O `fechou` é o que encadeia.
	var nomes: Node = _primeiro_com_script(overlay, "TelaNomes.gd")
	_confere("a partida nova abre a tela de nomes", nomes != null)
	if nomes != null:
		GS.definir_nomes("Cais de Teste", "")
		nomes.fechou.emit()

	var diario: Node = _primeiro_com_script(overlay, "PainelDiario.gd")
	_confere("e o diário a seguir", diario != null)
	if diario != null:
		diario.fechou.emit()

	# A ASSERÇÃO QUE IMPORTA: fechada a abertura, a contra-oferta tem de estar
	# na tela. Sem ela o jogador fica com um botão que não faz nada.
	var oferta: Node = _primeiro_com_script(overlay, "CounterOfferPanel.gd")
	_confere("fechada a abertura, o painel da contra-oferta está aberto",
		oferta != null,
		"a fase é %s e não há painel para a resolver — o turno fica preso" % GS.phase)

	main.free()


func _primeiro_com_script(raiz: Node, nome_do_script: String) -> Node:
	for n in raiz.get_children():
		var s = n.get_script()
		if s != null and String(s.resource_path).ends_with(nome_do_script):
			return n
		var fundo := _primeiro_com_script(n, nome_do_script)
		if fundo != null:
			return fundo
	return null


# ── F7 ──────────────────────────────────────────────────────────────────
# OS RETRATOS DE FALA, e são QUATRO perguntas diferentes, cada uma contra uma
# fonte diferente. Escrevê-las como uma só seria um espelho: a tabela das caras
# e a das falas vivem as duas na `Narrativa.gd`, e uma asserção que montasse o
# esperado a partir da mesma tabela onde o defeito vai morar passaria contente.
#
#   1. toda fala tem cara      — `EXPRESSOES` contra as TABELAS DE TEXTO
#   2. toda cara tem arquivo   — `EXPRESSOES` contra o `Retratos.gd` e o DISCO
#   3. toda cara é usada       — `Retratos.gd` contra `EXPRESSOES`
#   4. toda fala chega ao jogo — as tabelas contra os PAINÉIS, que é outro
#                                arquivo e por isso não é espelho nenhum
#
# ⚠️ A 3 É A PERGUNTA DO `barco_medio`, do lado da arte: nove PNG renderizados,
# validados pelo `asset_validator` e nenhuma linha do jogo a pedi-los seria
# exatamente o defeito que este projeto já apanhou três vezes. E a 4 é a que
# faltava: até 13/09 ela existia só para a Dona Cida, e por isso `ARLINDO_VENCEU`
# e `ARLINDO_PERDEU` viveram MUDAS desde 01/09 — escritas, com token conferido,
# e nunca disparadas por linha nenhuma.
func _f7_retratos() -> void:
	var Nar: GDScript = load("res://scripts/Narrativa.gd")
	var Ret: GDScript = load("res://scripts/Retratos.gd")
	var nar: Dictionary = Nar.get_script_constant_map()
	var ret: Dictionary = Ret.get_script_constant_map()
	var expressoes: Dictionary = nar["EXPRESSOES"]
	var desenhadas: Dictionary = ret["POR_EXPRESSAO"]

	# As falas de cada personagem, montadas das tabelas de TEXTO. É esta a
	# segunda fonte da pergunta 1: acrescentar uma fala sem lhe dar cara
	# reprova aqui, porque as duas tabelas são independentes.
	var falas := {
		"cida": _chaves(nar["CIDA_BOLETIM"]) + _chaves(nar["CIDA_LINHAS"]),
		"arlindo": _chaves(nar["ARLINDO_FALAS"]) + _chaves(nar["ARLINDO_REACOES"]),
		"ribeiro": _chaves(nar["RIBEIRO_FALAS"]),
	}
	# Uma varredura que não acha nada passa sem conferir coisa nenhuma.
	_confere("achou as falas dos três personagens (%d)" % (
		falas["cida"].size() + falas["arlindo"].size() + falas["ribeiro"].size()),
		falas["cida"].size() >= 12 and falas["arlindo"].size() >= 7
		and falas["ribeiro"].size() >= 5)

	for personagem in falas:
		var caras: Dictionary = expressoes.get(personagem, {})
		var sem_cara: Array[String] = []
		for id in falas[personagem]:
			if not caras.has(id):
				sem_cara.append(String(id))
		_confere("%s: as %d falas todas têm expressão" % [
			personagem, falas[personagem].size()],
			sem_cara.is_empty(), "sem cara: " + ", ".join(sem_cara))

		# E o contrário: uma expressão presa a um id que já não é fala nenhuma
		# é uma linha morta na tabela, e ela envelheceria calada.
		var orfas: Array[String] = []
		for id in caras:
			if not falas[personagem].has(String(id)):
				orfas.append(String(id))
		_confere("%s: nenhuma expressão presa a fala que já não existe" % personagem,
			orfas.is_empty(), "órfãs: " + ", ".join(orfas))

	# 2 — toda expressão nomeada tem PNG. O `Retratos.de()` devolve `null` para
	# um par desconhecido; um `null` na tela é um balão sem cara e nada o diz.
	# E o arquivo confere-se no DISCO e não pelo `preload`, pela mesma razão que
	# o F2 lê o `Icones.gd` como texto: um PNG que suma derruba a compilação do
	# `Retratos.gd`, e o teste morreria junto em vez de nomear o que falta.
	var pedidas := 0
	for personagem in expressoes:
		var caras: Dictionary = expressoes[personagem]
		for id in caras:
			var expressao := String(caras[id])
			var arquivo := "res://art/props/retrato_%s_%s.png" % [personagem, expressao]
			_confere("%s/%s: a cara `%s` tem PNG" % [personagem, id, expressao],
				ResourceLoader.exists(arquivo), "não existe " + arquivo)
			pedidas += 1
	_confere("conferiu as caras de todas as falas (%d)" % pedidas, pedidas >= 24)

	# 3 — e nenhuma cara desenhada fica sem quem a peça.
	for personagem in desenhadas:
		var caras: Dictionary = desenhadas[personagem]
		var usadas := {}
		for id in expressoes.get(personagem, {}):
			usadas[String(expressoes[personagem][id])] = true
		var mudas: Array[String] = []
		for expressao in caras:
			if not usadas.has(String(expressao)):
				mudas.append(String(expressao))
		_confere("%s: as %d caras desenhadas são todas usadas" % [
			personagem, caras.size()],
			mudas.is_empty(), "nenhuma fala pede: " + ", ".join(mudas))

	# 4 — e toda fala chega mesmo ao jogo. A segunda fonte são os PAINÉIS.
	#
	# O id conta como disparado quando aparece ENTRE ASPAS no painel, ou quando
	# o painel nomeia a constante/resolvedor que o serve (`ribeiro_entrada()`,
	# `ARLINDO_ULTIMA_TENTATIVA`) — que é uma regra derivada do nome, e não uma
	# lista de exceções a envelhecer. As linhas de COMENTÁRIO saem antes da
	# busca: este bloco nomeia falas na prosa acima, e sem o corte elas
	# contar-se-iam a si próprias.
	var fonte := _sem_comentarios(
		FileAccess.get_file_as_string("res://scripts/CounterOfferPanel.gd")
		+ FileAccess.get_file_as_string("res://scripts/DebtPaymentPanel.gd")).to_lower()
	_confere("os dois painéis foram lidos", fonte.length() > 1000)
	for personagem in ["arlindo", "ribeiro"]:
		var mudas: Array[String] = []
		for id in falas[personagem]:
			var citada := fonte.contains('"%s"' % String(id))
			var nomeada := fonte.contains("%s_%s" % [personagem, String(id)])
			if not (citada or nomeada):
				mudas.append(String(id))
		_confere("%s: as %d falas chegam todas ao jogo" % [
			personagem, falas[personagem].size()],
			mudas.is_empty(), "mudas: " + ", ".join(mudas))


# ⚠️ E A QUARTA PERGUNTA AINDA É SOBRE TEXTO, NÃO SOBRE COMPORTAMENTO. Ela
# confere que o id aparece no painel; não que o painel CHEGA lá. Um `if` errado
# na resolução deixava a despedida escrita no código e nunca executada — que é
# a mesma família de defeito com outra roupa. Por isso o bloco acaba a JOGAR a
# negociação: "igualar" fecha sempre o negócio (não depende de sorteio nenhum),
# o cliente fica, e quem perde é o Arlindo — a tela tem de continuar aberta com
# a despedida dele.
func _f7_despedida_do_arlindo_acontece() -> void:
	var cena := load("res://scenes/panels/CounterOfferPanel.tscn") as PackedScene
	if cena == null:
		_confere("CounterOfferPanel.tscn carrega", false)
		return

	GS.new_game()
	if GS.docks[0]["boat"] == null:
		GS.docks[0]["boat"] = GS._make_boat()
	GS.pending_rival_dock = 0
	GS.rival_attempts_left = GS.RIVAL_PATIENCE
	GS._set_phase("rival_offer")

	var painel: Node = cena.instantiate()
	root.add_child(painel)
	painel.setup(0)
	_confere("a contra-oferta abre com a fala de abertura",
		painel._fala_arlindo.text != "")

	# O botão, e não a função por baixo dele: é o caminho que o jogador faz.
	painel._btn_igualar.pressed.emit()

	# ⚠️ `is_inside_tree()` NÃO SERVE AQUI, e passou a primeira vez que se
	# injetou o defeito: `queue_free()` marca o nó e só o tira da árvore no fim
	# do frame, de modo que um painel já condenado ainda responde "estou cá". A
	# pergunta que distingue é a da FILA — e sem ela esta linha era confiança de
	# graça, com a asserção do texto ao lado a fazer o trabalho todo.
	_confere("resolvida a negociação, a tela NÃO fecha calada",
		not painel.is_queued_for_deletion(),
		"o painel foi mandado embora — a despedida dele voltou a ser muda")
	_confere("e o Arlindo diz a fala de quem perdeu",
		painel._fala_arlindo.text == GS.texto(Narrativa.ARLINDO_PERDEU),
		"saiu: " + painel._fala_arlindo.text.left(60))
	root.remove_child(painel)
	painel.free()


func _chaves(tabela: Dictionary) -> Array[String]:
	var saida: Array[String] = []
	for chave in tabela:
		saida.append(String(chave))
	return saida


func _sem_comentarios(fonte: String) -> String:
	var saida := ""
	for linha in fonte.split("\n"):
		if linha.strip_edges().begins_with("#"):
			continue
		saida += linha + "\n"
	return saida
