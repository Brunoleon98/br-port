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


# ⚠️ DEVOLVE `false`, e quem encerra é o `quit()` do `_rodar()`. Devolver
# `true` mata a árvore no fim deste frame — e o bloco F8 precisa de ESPERAR um
# frame, porque a fala da Dona Cida entra por `call_deferred`. Com `true` a
# corrida acabava antes de o `await` voltar, e as asserções do F8 nunca
# corriam: verde sem ter testado nada.
func _process(_delta: float) -> bool:
	if _feito:
		return false
	_feito = true
	_rodar()
	return false


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

	print("=== F8: a fala da Dona Cida é VISTA, e afirma só o que a condição garante ===")
	await _f8_a_fala_e_vista()
	# A BANDEIRA DA ÚLTIMA LINHA. Um erro de execução a meio de um bloco aborta
	# a função e o contador de falhas fica em zero — a suíte imprimiria o
	# marcador com as asserções por correr. Aqui isso é mais fácil de acontecer
	# do que nos outros, porque este bloco é uma corrotina.
	_confere("o bloco F8 correu até ao fim", _f8_terminou)

	print("=== F9: nenhuma contagem escreve o plural à mão ===")
	_f9_concordancia_a_mao()

	print("=== F10: cada tempo dos painéis de mais de uma tela cabe no cartão ===")
	await _f10_cada_tempo_cabe()
	_confere("o bloco F10 correu até ao fim", _f10_terminou)

	print("=== F11: no fim da partida as telas abrem uma de cada vez, e pela ordem ===")
	await _f11_a_vez_do_fim()
	_confere("o bloco F11 correu até ao fim", _f11_terminou)

	print("=== F12: cada trabalhador nasce com o seu rosto, e o sorteio da partida não se mexe ===")
	_f12_o_rosto_do_trabalhador()
	_confere("o bloco F12 correu até ao fim", _f12_terminou)

	print("=== F13: ferramenta e suíte nunca escrevem onde o jogador guarda ===")
	_f13_o_armazem_do_jogador()
	_confere("o bloco F13 correu até ao fim", _f13_terminou)

	print("=== F14: o que a cobrança e a contra-oferta prometem antes da escolha é o que o jogo faz depois ===")
	await _f14_promessa_e_resultado()
	_confere("o bloco F14 correu até ao fim", _f14_terminou)

	print("=== F15: o que os painéis do HUD prometem é o que o jogo faz ===")
	await _f15_promessa_do_hud()
	_confere("o bloco F15 correu até ao fim", _f15_terminou)

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

	# ⚠️ E TODO RECURSO `.tres` CARREGA — a pergunta que a lista de dependências
	# não faz. Ela confere que o ARQUIVO existe; em 25/09 um comentário de
	# várias linhas no tema, com o `;` só na primeira, partiu o parse do
	# `tema_brport.tres` inteiro. O arquivo existia, as cenas abriam sem tema
	# (o Godot troca o recurso por null e segue), e esta suíte passou verde;
	# quem reprovou foram o teste de design, pelos alvos de toque, e a bateria,
	# pelo erro impresso. Aqui a pergunta é direta.
	var recursos: Array[String] = []
	_varrer_cenas("res://", recursos, ".tres")
	_confere("a varredura achou recursos .tres (%d)" % recursos.size(), recursos.size() >= 2,
		"achou %d — a varredura quebrou?" % recursos.size())
	for caminho in recursos:
		_confere("%s: carrega" % caminho.trim_prefix("res://"), load(caminho) != null)


func _varrer_cenas(pasta: String, achadas: Array[String], extensao: String = ".tscn") -> void:
	var dir := DirAccess.open(pasta)
	if dir == null:
		return
	dir.list_dir_begin()
	var nome := dir.get_next()
	while nome != "":
		var completo := pasta.path_join(nome)
		if dir.current_is_dir():
			if not nome.begins_with(".") and not PASTAS_IGNORADAS.has(nome):
				_varrer_cenas(completo, achadas, extensao)
		elif nome.ends_with(extensao):
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
		not FileAccess.file_exists(GS.save_path),
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
		"workers": [{"id": 1, "busy_turns": 0, "rosto": 0}],
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
	var f := FileAccess.open(GS.save_path, FileAccess.WRITE)
	f.store_string(texto)
	f.close()


# Escreve o save, tenta carregar e devolve true só se as duas metades da regra
# valerem: recusou E apagou. Um save recusado que fica no disco é tentado outra
# vez a cada arranque, e o jogador não tem como o remover.
func _recusa_e_apaga(dados: Dictionary) -> bool:
	_novo_jogo()
	_escrever(dados)
	var carregou: bool = GS.load_game()
	return carregou == false and not FileAccess.file_exists(GS.save_path)


func _recusa_texto(texto: String) -> bool:
	_novo_jogo()
	_recusa_texto_escrever(texto)
	var carregou: bool = GS.load_game()
	return carregou == false and not FileAccess.file_exists(GS.save_path)


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
	# ⚠️ O NÚMERO CRAVADO SAIU, e não foi para ficar verde. Dizia
	# `linhas.size() == 8`, e a tabela cresceu para 13 ao ganhar as variantes
	# que o R4 condicionou — uma contagem à mão numa lista que cresce é um
	# número a envelhecer, e este INSTRUI (reprova), logo confere-se em vez de
	# se manter. O que ele protegia — alguém apagar uma fala — continua
	# protegido, e por duas fontes em vez de por um literal: o bloco F6 exige
	# que toda fala tenha expressão E que toda expressão tenha fala, então
	# apagar uma linha deixa a expressão órfã e reprova lá.
	var linhas: Dictionary = constantes.get("CIDA_LINHAS", {})
	_confere("a tabela de falas da Dona Cida não está vazia", linhas.size() > 0)
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
		# ⚠️ `_cida` E `_cida_agora`. A busca era por `_cida(` e as quatro
		# variantes da semana nova saem por `_cida_agora(`, que existe para não
		# adiar duas vezes — elas ficariam mudas para esta guarda, que é
		# exatamente o verde de graça que ela existe para não dar.
		if not limpa.contains("_cida"):
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


# ── F8 ──────────────────────────────────────────────────────────────────
# A FALA FOI VISTA?
#
# O bloco F4 pergunta *"toda fala DISPARA?"* — e ela dispara. Esta é a pergunta
# do OUTRO lado do frame: o que sobrou no Label depois de todos os emits
# daquele evento. É a quarta cara do `barco_medio`, depois de "gerado e nunca
# em cena", "escrito e nunca disparado" e "arte que o sorteio nunca escolhe".
#
# Medido em 18/09, cinco sementes, partidas inteiras, ANTES da correção:
# `upgrade_pronto` foi escrita 35 vezes e vista ZERO; `caixa_baixo` 11 e zero;
# `reputacao_caiu` 12 e zero. O `GameState` emite o sinal narrativo uma linha
# ANTES do `message.emit` da mesma chamada, e os dois escrevem no mesmo Label.
#
# ⚠️ ESTE BLOCO TEM DE ESPERAR UM FRAME. A fala entra por `call_deferred`; uma
# versão que lesse o Label logo a seguir à chamada dá VAZIO em tudo — e vazio
# lê-se como "não há fala", que é o verde de graça com outra roupa. Foi
# exactamente o que aconteceu à régua de medição na primeira corrida.
#
# ⚠️ E O QUE ESTE BLOCO NÃO DEFENDE: que a fala seja VERDADEIRA. Ele prova que
# a condição escolhe a variante certa e que a linha chega à tela; se a frase
# descreve mesmo este mundo é o gate A4 — uma pessoa a ler em voz alta. Foi
# assim que se apanhou *"porto que fecha no azul abre segunda-feira"*, que
# nenhuma asserção podia ver.
const F8_CAMINHO_LABEL := "MensagemCartao/Linha/Mensagem"

var _f8_terminou := false
var _f9_terminou := false
var _f8_main: Node = null
var _f8_sistema: Array[String] = []
var _f8_apresentadas: Array[String] = []


func _f8_abrir() -> bool:
	# DERIVA O ESTADO, nunca o herda: o autoload tenta `load_game()` antes de
	# `new_game()`, e sem isto o bloco leria o autosave do bloco anterior.
	GS.clear_save()
	GS._rng.seed = 20260902
	GS.new_game()
	GS.definir_nomes(GS.NOME_PORTO_PADRAO, "")
	# Oferta pendente resolve-se antes de contar com o estado: em "rival_offer"
	# toda compra é recusada calada.
	if GS.phase == "rival_offer":
		GS.resolve_rival_offer(true)
	var cena := load("res://scenes/Main.tscn") as PackedScene
	if cena == null:
		_confere("F8: Main.tscn carrega", false)
		return false
	_f8_main = cena.instantiate()
	root.add_child(_f8_main)
	_f8_sistema.clear()
	_f8_apresentadas.clear()
	# ⚠️ A PERGUNTA MUDOU DE LADO COM A FILA (R5). Até 19/09 "vista" queria
	# dizer "sobrou no Label depois de todos os emits", porque a última escrita
	# apagava as outras. Com a fila nada é apagado: cada mensagem tem a sua vez,
	# e a pergunta certa passou a ser **foi APRESENTADA?**. Ler o Label agora
	# responderia pela última da fila e chamaria "não vista" a uma frase que
	# esteve na tela os seus dois segundos.
	_f8_main._fila.apresentou.connect(_f8_recolher_apresentada)
	GS.message.connect(_f8_recolher)
	return true


func _f8_recolher(texto: String, _kind: String) -> void:
	_f8_sistema.append(texto)


func _f8_recolher_apresentada(texto: String, _kind: String) -> void:
	_f8_apresentadas.append(texto)


# CORRE O RELÓGIO DA FILA ATÉ ELA ESVAZIAR, e devolve a última frase mostrada.
# O teto existe pela mesma razão do teto de voltas do `capturar_tela.gd`: uma
# fila que não drenasse penduraria a suíte em vez de reprovar.
func _f8_drenar() -> String:
	var voltas := 0
	while _f8_main._fila.avancar(99.0) and voltas < 200:
		voltas += 1
	return "" if _f8_apresentadas.is_empty() else _f8_apresentadas[-1]


func _f8_foi_apresentada(texto: String) -> bool:
	return _f8_apresentadas.has(texto)


func _f8_fechar() -> void:
	if GS.message.is_connected(_f8_recolher):
		GS.message.disconnect(_f8_recolher)
	if _f8_main != null:
		_f8_main.free()
		_f8_main = null


# ⚠️ DOIS FRAMES, E FOI MEDIDO. `await process_frame` retoma no INÍCIO do frame
# seguinte, e a fila de `call_deferred` daquele frame ainda não correu: com um
# só, o Label devolvia a mensagem do SISTEMA e as asserções reprovavam o código
# certo. Com dois, a fala já lá está.
func _f8_esperar() -> void:
	await process_frame
	await process_frame


func _f8_label() -> String:
	if _f8_main == null:
		return ""
	var l = _f8_main.get_node_or_null(F8_CAMINHO_LABEL)
	return "" if l == null else String(l.text)


func _f8_avancar_ate(alvo: int) -> void:
	var voltas := 0
	while GS.turn < alvo and voltas < 60:
		voltas += 1
		if GS.phase == "rival_offer":
			GS.resolve_rival_offer(true)
			continue
		GS.advance_turn()


# Põe (ou tira) um barco à espera na doca 0, para montar à mão o estado que a
# fala da semana nova lê. O esperado deste bloco é escrito à mão a partir daqui
# — nunca recalculado dos mesmos predicados que a fala usa, que seria o espelho.
func _f8_por_barco_a_espera(sim: bool) -> void:
	for d in GS.docks:
		d["boat"] = null
		d["worker_id"] = null
	if sim:
		var barco: Dictionary = GS._make_boat()
		barco["rival"] = false
		GS.docks[0]["boat"] = barco


func _f8_a_fala_e_vista() -> void:
	# ── F8a. A compra: `estrutura_comprada` e o "pronto" do sistema.
	if not _f8_abrir():
		return
	GS.comprar_estrutura("pier_2")
	await _f8_esperar()
	_f8_drenar()
	# A GUARDA SÓ VALE SE O PERIGO ESTIVER MONTADO. Sem a mensagem do sistema
	# nesta chamada não há par nenhum a testar, e as asserções seguintes
	# passariam por um caminho que não é o que elas existem para defender.
	_confere("F8a: a compra emite mesmo uma mensagem do sistema no mesmo frame",
		_f8_sistema.size() > 0, "nenhuma — o par que este bloco testa não está montado")
	_confere("F8a: a fala do upgrade é apresentada",
		_f8_foi_apresentada(Narrativa.cida("upgrade_pronto")),
		"apresentadas: " + ", ".join(_f8_apresentadas))
	# ⚠️ E ESTA É A ASSERÇÃO DO R5, o mutante "perder a segunda entrada": as
	# DUAS mensagens da mesma compra chegam à tela. Até 19/09 uma tapava a
	# outra no mesmo frame, e qual delas sobrevivia era só uma questão de quem
	# escrevia por último — o R4 trocou o vencedor e não o jogo.
	_confere("F8a: e a mensagem do sistema da mesma compra também",
		_f8_foi_apresentada(_f8_sistema[-1] if _f8_sistema.size() > 0 else ""),
		"apresentadas: " + ", ".join(_f8_apresentadas))
	_f8_fechar()

	# ── F8b. A obra é INSTANTÂNEA, logo a fala dela não pode falar de tempo.
	# Guarda estreita de propósito: defende o regresso da frase medida falsa
	# ("Demorou o dobro do previsto"), não a verdade das falas em geral.
	var upgrade: String = Narrativa.cida("upgrade_pronto").to_lower()
	var tempo := ["demor", "atras", "levou", "semana", "dia", "mês", "mes ", "hora"]
	var achadas: Array[String] = []
	for palavra in tempo:
		if upgrade.contains(palavra):
			achadas.append(palavra)
	_confere("F8b: a fala da obra instantânea não afirma duração",
		achadas.is_empty(), "diz: " + ", ".join(achadas))

	# ── F8c. A semana nova escolhe pela CONDIÇÃO.
	# Chama `_semana_nova()` direto: o estado é montado à mão e o esperado é
	# escrito à mão a partir dele, nunca recalculado dos mesmos predicados que
	# a fala usa — isso seria o espelho, e um peso posto a zero desapareceria
	# dos dois lados ao mesmo tempo.
	if not _f8_abrir():
		return
	_f8_por_barco_a_espera(true)
	GS.cash = GS.PARCELA_AMOUNT / 2 - 1
	_f8_main._semana_nova()
	_confere("F8c: com barco à espera e caixa curto, sai a variante das duas",
		_f8_drenar() == Narrativa.cida("semana_nova_fila_curto"),
		"ficou: " + _f8_drenar())
	_f8_por_barco_a_espera(false)
	GS.cash = GS.PARCELA_AMOUNT
	_f8_main._semana_nova()
	_confere("F8c: sem barco e com caixa folgado, sai a variante de nenhuma das duas",
		_f8_drenar() == Narrativa.cida("semana_nova_parado_folgado"),
		"ficou: " + _f8_drenar())
	_f8_fechar()

	# ── F8c2. E O PREDICADO É LIDO ONDE A LINHA É ESCRITA, não onde o sinal
	# dispara. É o que separa uma fala verdadeira de uma que descreve um
	# instante que o jogador nunca vê: `turn_advanced` sai ANTES do sorteio do
	# dia, e medido em 18/09 `docas_esperando()` deu ZERO em 315 viradas ali,
	# contra barco à espera em 74 de 155 um instante depois.
	#
	# A prova monta o estado A, dispara, TROCA para o estado B e exige que a
	# variante seja a de B. Se o predicado fosse lido no sinal, sairia a de A.
	if not _f8_abrir():
		return
	_f8_main._cida_semana(8, 1)          # regista a semana anterior, sem falar
	_f8_por_barco_a_espera(false)        # estado A: cais parado
	GS.cash = GS.PARCELA_AMOUNT
	_f8_main._cida_semana(9, 2)          # dispara — a escolha fica para depois
	_f8_por_barco_a_espera(true)         # estado B: barco à espera
	GS.cash = GS.PARCELA_AMOUNT / 2 - 1
	await _f8_esperar()
	_confere("F8c2: a variante é a do estado em que a linha é ESCRITA, não a do sinal",
		_f8_drenar() == Narrativa.cida("semana_nova_fila_curto"),
		"ficou: " + _f8_drenar() + " (a do sinal seria: "
			+ Narrativa.cida("semana_nova_parado_folgado") + ")")
	_f8_fechar()

	# ── F8d. A PRIMEIRA SEMANA NÃO COMPARA COM UMA ANTERIOR que não existe.
	if not _f8_abrir():
		return
	_f8_avancar_ate(2)
	await _f8_esperar()
	_f8_drenar()
	# ⚠️ E AGORA A PERGUNTA É SOBRE TUDO O QUE FOI APRESENTADO, não sobre o que
	# sobrou: com a fila, uma fala da semana 1 não seria apagada pela seguinte
	# — apareceria na sua vez, e ler só a última deixaria de a ver.
	var e_semana_nova := false
	for id in Narrativa.CIDA_LINHAS:
		if String(id).begins_with("semana_nova") and _f8_foi_apresentada(Narrativa.cida(String(id))):
			e_semana_nova = true
	_confere("F8d: a semana 1 não diz 'semana nova' — não há anterior com que comparar",
		not e_semana_nova, "apresentadas: " + ", ".join(_f8_apresentadas))
	_f8_fechar()

	# ── F8e. "A parcela não vai esperar" só sai enquanto ela não foi paga.
	# `pagar_parcela_adiantado()` quita a qualquer momento, e sem esta escolha
	# a frase ficava falsa desse turno até ao fim da partida.
	if not _f8_abrir():
		return
	# ⚠️ O CAIXA SAI DO VALOR DO DIA, e não do `PARCELA_AMOUNT`. A parcela
	# adiantada tem desconto (`valor_da_parcela_hoje()`), e montar pelo valor
	# cheio deixava o caixa em R$306.074 depois de pagar — acima do limiar, sem
	# travessia nenhuma, e a asserção reprovava por não haver o que ver.
	GS.cash = int(GS.valor_da_parcela_hoje()) + 1000
	var quitou: bool = GS.pagar_parcela_adiantado()
	await _f8_esperar()
	_f8_drenar()
	_confere("F8e: a montagem quitou mesmo a parcela adiantada", quitou,
		"sem isto a asserção seguinte testa o outro ramo")
	_confere("F8e: com a parcela paga, a fala do caixa curto é a que não a cobra",
		_f8_foi_apresentada(Narrativa.cida("caixa_baixo_quitado")),
		"apresentadas: " + ", ".join(_f8_apresentadas))
	_f8_fechar()

	# ── F8f. E A SEMANA NOVA SÓ COBRA A PARCELA SE ELA ESTIVER PENDENTE.
	# É o par do F8e uma dobra acima, e faltava: o `caixa_curto()` é meia
	# parcela e não diz nada sobre ela estar paga, de modo que quem quitasse
	# cedo ouviria "a parcela correndo" em toda semana até ao fim da partida.
	# ⚠️ E A SEGUNDA ASSERÇÃO NÃO É A PRIMEIRA COM OUTRO NOME: uma pergunta
	# QUAL variante sai, a outra pergunta o que a variante AFIRMA. Trocar os
	# dois textos um pelo outro passaria a primeira e reprovaria a segunda.
	if not _f8_abrir():
		return
	_f8_por_barco_a_espera(false)
	GS.cash = GS.PARCELA_AMOUNT / 2 - 1
	GS.parcela_paid = false
	_f8_main._semana_nova()
	_confere("F8f: com a parcela por pagar, é ela que a fala nomeia",
		_f8_drenar() == Narrativa.cida("semana_nova_parado_curto"),
		"ficou: " + _f8_drenar())
	GS.parcela_paid = true
	_f8_main._semana_nova()
	_confere("F8f: com a parcela paga, sai a outra variante",
		_f8_drenar() == Narrativa.cida("semana_nova_parado_curto_quitado"),
		"ficou: " + _f8_drenar())
	_confere("F8f: e essa outra não fala de parcela nenhuma",
		not Narrativa.cida("semana_nova_parado_curto_quitado").to_lower().contains("parcela"),
		"diz: " + Narrativa.cida("semana_nova_parado_curto_quitado"))
	_f8_fechar()

	# ── F8g. A OBRA MUDA DE REAÇÃO A PARTIR DA TERCEIRA.
	# "Olha que eu duvidei" é reação de primeira vez, e as estruturas são
	# SETE. A contagem sai de `estruturas`, que é onde o jogo a guarda — as
	# compras aqui são de verdade, e não uma lista montada à mão, para que a
	# asserção responda pelo que o jogador faz.
	if not _f8_abrir():
		return
	GS.cash = 10000000
	GS.comprar_estrutura("pier_2")
	await _f8_esperar()
	_f8_drenar()
	_confere("F8g: a primeira obra tem a reação de primeira vez",
		_f8_foi_apresentada(Narrativa.cida("upgrade_pronto")),
		"apresentadas: " + ", ".join(_f8_apresentadas))
	# ⚠️ A SEGUNDA COMPRA NO MESMO FÔLEGO É A DUPLICATA SEMÂNTICA, e é aqui
	# que ela se prova: a fala é a MESMA string, logo funde-se; as duas
	# mensagens do sistema são DIFERENTES e não se fundem. É o caso que a nota
	# do Bruno levantou — "mais de uma compra pode ser feita por turno".
	var antes_da_segunda := _f8_apresentadas.size()
	GS.comprar_estrutura("armazem")
	await _f8_esperar()
	_f8_drenar()
	var novas: Array[String] = []
	for i in range(antes_da_segunda, _f8_apresentadas.size()):
		novas.append(_f8_apresentadas[i])
	_confere("F8g: a segunda obra não repete a fala igual — funde-se",
		not novas.has(Narrativa.cida("upgrade_pronto")),
		"repetiu: " + ", ".join(novas))
	_confere("F8g: mas a mensagem do sistema dela aparece — texto diferente não funde",
		novas.has(_f8_sistema[-1] if _f8_sistema.size() > 0 else ""),
		"novas: " + ", ".join(novas))
	# ⚠️ E O ESTADO QUE APERTA O LIMIAR É A TERCEIRA, e só ela: à segunda a
	# conta certa e a errada dão respostas diferentes — se o corte fosse 2, a
	# linha da rotina teria saído já ali, e ela é um texto NOVO, logo não se
	# funde e apareceria.
	_confere("F8g: e à segunda a fala da rotina ainda não saiu",
		not _f8_foi_apresentada(Narrativa.cida("upgrade_pronto_rotina")),
		"apresentadas: " + ", ".join(_f8_apresentadas))
	GS.comprar_estrutura("patio")
	await _f8_esperar()
	_f8_drenar()
	_confere("F8g: da terceira em diante ela concede",
		_f8_foi_apresentada(Narrativa.cida("upgrade_pronto_rotina")),
		"apresentadas: " + ", ".join(_f8_apresentadas))
	_f8_fechar()

	_f8_terminou = true


# ── F9 ──────────────────────────────────────────────────────────────────
# A superfície do plural, varrida em vez de listada.
#
# ⚠️ A REVISÃO NOMEOU TRÊS SÍTIOS, A BUSCA POR `(s)` ACHOU CINCO, E A BUSCA
# PELA FORMA ACHOU OITO. Os três primeiros eram os que o jogador LIA errado
# ("dia(s) restante(s)"); os outros dois estavam no `GameState`, que ninguém
# tinha aberto; e os últimos três escreviam a concordância com um ternário à
# mão (`"" if n == 1 else "s"`) — saída certa, regra duplicada em cinco sítios,
# e num deles duas vezes na MESMA expressão. É a regra do `CLAUDE.md`: fecha-se
# pelo `grep` da FORMA que causou o defeito, nunca pela peça onde ele apareceu.
#
# ⚠️ E ELA CORTA OS COMENTÁRIOS ANTES DE VARRER. Os comentários deste bloco e
# os do `Narrativa.concordar` CITAM as duas formas proibidas, palavra por
# palavra — sem o corte, o comentário que explica a armadilha satisfaz a busca
# que a caça, que é o que já mordeu na varredura das falas.
#
# ⚠️ O ESCOPO É `scripts/` + `autoload/`, que é onde vive o texto que o jogador
# LÊ. `tools/` e `tests/` ficam de fora de propósito: não vão no APK e falam
# com quem desenvolve — a própria suíte imprime "%d TESTE(S) FALHARAM", que é
# uma forma legítima ali e seria um defeito num rótulo do jogo.
func _f9_concordancia_a_mao() -> void:
	var arquivos := _f9_scripts_do_jogo()
	_confere("F9: a varredura achou os scripts do jogo", arquivos.size() > 20,
		"achou %d" % arquivos.size())

	# ⚠️ O PAR LÊ-SE NO ARQUIVO INTEIRO E NÃO LINHA A LINHA, e esta guarda
	# reprovou na estreia por causa disso: a prosa deste repositório quebra aos
	# ~79 caracteres, e cinco das onze chamadas têm o `concordar(` numa linha e
	# as duas formas na seguinte. Uma varredura de linha achou SEIS — e as
	# outras cinco não reprovavam, escapavam caladas, que é o verde de graça.
	# É a armadilha que o `CLAUDE.md` já regista para o `grep` de facto, e ela
	# mordeu dentro da guarda escrita para a caçar.
	var re := RegEx.new()
	# ⚠️ E O PRIMEIRO ARGUMENTO PODE TER PARÊNTESES *E* ASPAS lá dentro — o
	# PainelCaixa passa `int(dia["servidos"])`. Uma expressão que casasse a
	# primeira string a seguir ao parêntesis leria `"servidos"` como a forma
	# singular; uma que proibisse parênteses no argumento saltava as duas
	# chamadas desse painel. Por isso o que se casa são as DUAS ÚLTIMAS strings
	# antes do fecho, com um nível de parênteses permitido pelo meio.
	re.compile("concordar\\s*\\((?:[^()]|\\([^()]*\\))*?\"([^\"]*)\"\\s*,\\s*\"([^\"]*)\"\\s*\\)")
	var crus := []
	var ternarios := []
	var pares := []
	var chamadas := 0
	for caminho in arquivos:
		var fonte := FileAccess.get_file_as_string(caminho)
		var uteis := PackedStringArray()
		for linha in fonte.split("\n"):
			var limpa := linha.strip_edges()
			if limpa.begins_with("#"):
				continue
			uteis.append(limpa)
			if limpa.contains("(s)") or limpa.contains("(es)") or limpa.contains("(as)"):
				crus.append("%s: %s" % [caminho.get_file(), limpa])
			if limpa.contains("else \"s\"") or limpa.contains("else \"es\""):
				ternarios.append("%s: %s" % [caminho.get_file(), limpa])
		var texto := "\n".join(uteis)
		# A DECLARAÇÃO não é chamada: o `Narrativa.gd` traz o `func concordar(`
		# e ele contaria como uma décima segunda chamada que ninguém faz.
		chamadas += texto.count("concordar(") - texto.count("func concordar(")
		for m in re.search_all(texto):
			pares.append([caminho.get_file(), m.get_string(1), m.get_string(2)])

	_confere("F9: nenhum rótulo do jogo escreve \"(s)\" ao jogador",
		crus.is_empty(), "\n    " + "\n    ".join(crus))
	_confere("F9: nenhuma contagem concorda com um ternário à mão",
		ternarios.is_empty(), "\n    " + "\n    ".join(ternarios))

	# ⚠️ E OS PARES DERIVAM DO CÓDIGO, que é o que apanha o defeito na CHAMADA
	# em vez de no helper. O T9 prova a aritmética com um par escrito no teste;
	# um `concordar(n, "dia restante", "dias restante")` — o adjetivo por
	# concordar na forma plural — passaria ali inteiro, porque o T9 nunca vê
	# aquela chamada. Aqui vê-se.
	# ⚠️ E A CONTA DERIVA-SE DUAS VEZES, por caminhos diferentes: quantas vezes
	# a palavra aparece, e quantos pares a expressão conseguiu ler. Uma régua
	# que responde à mesma pergunta por dois caminhos denuncia-se sozinha — foi
	# a discordância entre elas que apanhou a quebra de linha acima, e é ela
	# que impede uma chamada de forma nova de ser ignorada em silêncio.
	_confere("F9: a expressão leu TODAS as chamadas a concordar() que existem",
		pares.size() == chamadas,
		"a palavra aparece %d vezes, a expressão leu %d pares" % [chamadas, pares.size()])
	_confere("F9: e há chamadas para ler", pares.size() >= 8,
		"achou %d" % pares.size())
	var maus := []
	for par in pares:
		var um: String = par[1]
		var varios: String = par[2]
		if um == varios:
			maus.append("%s: as duas formas são iguais (%s)" % [par[0], um])
			continue
		var pu := um.split(" ")
		var pv := varios.split(" ")
		if pu.size() != pv.size():
			maus.append("%s: \"%s\" e \"%s\" não têm o mesmo número de palavras"
				% [par[0], um, varios])
			continue
		for i in pv.size():
			var palavra := String(pv[i])
			if not palavra.ends_with("s") and not _F9_INVARIAVEIS.has(palavra):
				maus.append("%s: \"%s\" não está no plural em \"%s\"" % [par[0], palavra, varios])
	_confere("F9: em toda chamada, a forma plural está mesmo no plural",
		maus.is_empty(), "\n    " + "\n    ".join(maus))

	_f9_terminou = true
	_confere("o bloco F9 correu até ao fim", _f9_terminou)


# As palavras que NÃO concordam, e a razão de cada uma. A lista é curta de
# propósito: ela é a porta por onde um adjetivo por concordar entraria sem a
# asserção acima o ver, então cada entrada paga o seu lugar.
#   esperando — gerúndio, invariável ("1 doca esperando" / "2 docas esperando")
const _F9_INVARIAVEIS := ["esperando"]


func _f9_scripts_do_jogo() -> PackedStringArray:
	var achados := PackedStringArray()
	for raiz in ["res://scripts", "res://autoload"]:
		_f9_juntar(raiz, achados)
	achados.sort()
	return achados


func _f9_juntar(dir_path: String, achados: PackedStringArray) -> void:
	var d := DirAccess.open(dir_path)
	if d == null:
		return
	d.list_dir_begin()
	var nome := d.get_next()
	while nome != "":
		var completo := dir_path.path_join(nome)
		if d.current_is_dir():
			if not nome.begins_with("."):
				_f9_juntar(completo, achados)
		elif nome.ends_with(".gd"):
			achados.append(completo)
		nome = d.get_next()
	d.list_dir_end()



# ── F10 ─────────────────────────────────────────────────────────────────
# CADA TEMPO DOS PAINÉIS DE MAIS DE UMA TELA CABE NO CARTÃO — o texto dentro
# do cartão, e o cartão dentro da tela.
#
# O T13 guarda o TEXTO da resposta do Sr. Ribeiro; nada perguntava se ele
# cabia, e o segundo tempo de três painéis só tinha sido visto à mão
# (`docs/decisoes/051`). Mede-se com o NOME MAIS LARGO que a tela de nomes
# aceita — `NOME_MAX_CARACTERES` letras "W", sem espaço —, que é o pior caso
# que o jogo escreve. Medido em 23/09: com ele o texto saía do balão e passava
# POR FORA do cartão nos dois painéis com fala, porque `AUTOWRAP_WORD` só
# quebra em fronteira de palavra.
#
# ⚠️ A MEDIDA É O QUE O RÓTULO DESENHA, e não o tamanho dele. Uma palavra que
# transborda deixa o `size` do rótulo intacto — o retângulo cabia, o texto
# não. `get_character_bounds()` diz onde cada caractere cai.
#
# ⚠️ E CADA TEMPO ALCANÇA-SE PELA PORTA DO JOGADOR — o botão —, com o estado
# montado como o jogo o monta: o vencimento pelo `advance_turn()`, a oferta do
# rival pelo sorteio dele, e as frases do fim pelo `game_over` que o próprio
# jogo emite ao pagar e ao não pagar. Cada caso prova que chegou onde diz.
#
# ⚠️ E O NOME NÃO VIVE SÓ NOS PAINÉIS DE MAIS DE UMA TELA. O diário leva o do
# porto DUAS vezes, numa área rolável de altura escrita à mão — e área rolável
# não corta, esconde: um nome que acrescentasse linhas punha o «Talvez.» que
# fecha a página debaixo da dobra. Medido em 23/09 com 397 nomes (letras
# largas e estreitas, de 1 a 24, partidos por um e dois espaços): nenhum pede
# mais do que os 24 "W", 597 px dos 620 da área — 23 px de folga, menos de uma
# linha. Quem diz QUE textos levam o nome não é esta lista de casos: é o
# `_f10_todo_nome_e_medido()`, que o lê da `Narrativa.gd`.
const F10_TEMA := "res://ui/tema_brport.tres"
const F10_RIBEIRO := "res://scenes/panels/DebtPaymentPanel.tscn"
const F10_ARLINDO := "res://scenes/panels/CounterOfferPanel.tscn"
const F10_FIM := "res://scenes/EndGame.tscn"
const F10_DIARIO := "res://scenes/panels/PainelDiario.tscn"
const F10_NARRATIVA := "res://scripts/Narrativa.gd"
const F10_SEMENTE := 20260923
# O antisserrilhado pinta meio pixel além da caixa de um caractere.
const F10_FOLGA := 1.0
var _f10_terminou := false
var _f10_motivos := {}
# O texto de todo rótulo que o `_f10_medir()` percorreu — é contra ele que o
# catálogo dos textos com nome se confere.
var _f10_vistos: Array[String] = []


func _f10_cada_tempo_cabe() -> void:
	GS.game_over.connect(_f10_recolher_fim)
	var nome: String = "W".repeat(int(GS.NOME_MAX_CARACTERES))

	# ── O Sr. Ribeiro. Sem dinheiro para a parcela a entrada tem os DOIS
	# botões, que é o cartão mais alto dela.
	if not _f10_ate_ao_vencimento(nome):
		return
	var p: Node = await _f10_abrir(F10_RIBEIRO, [GS.PARCELA_AMOUNT])
	_f10_medir(p, "Ribeiro, entrada", &"entrada")
	if not await _f10_tocar(p, "Não consigo"):
		return
	_confere("F10: «Não consigo pagar» encerrou a partida",
		GS.phase == "game_over" and _f10_motivos.has(false))
	_f10_medir(p, "Ribeiro, não pagou", &"nao_pagou")
	_f10_fechar(p)

	if not _f10_ate_ao_vencimento(nome):
		return
	GS.cash = GS.PARCELA_AMOUNT
	p = await _f10_abrir(F10_RIBEIRO, [GS.PARCELA_AMOUNT])
	if not await _f10_tocar(p, "Pagar"):
		return
	_confere("F10: «Pagar» quitou mesmo a parcela",
		bool(GS.parcela_paid) and _f10_motivos.has(true))
	_f10_medir(p, "Ribeiro, pagou", &"pagou")
	_f10_fechar(p)

	# ── O Arlindo. A rodada abre; cada aposta que o cliente recusa acrescenta
	# a reação e, na última tentativa, a pressão — é a rodada mais comprida.
	for acao in ["Cortar metade", "Manter"]:
		if not _f10_ate_a_oferta(nome):
			return
		p = await _f10_abrir(F10_ARLINDO, [GS.pending_rival_dock])
		if acao == "Manter":
			_f10_medir(p, "Arlindo, rodada", &"rodada")
		GS._rng.seed = _f10_semente_que_recusa(acao)
		if not await _f10_tocar(p, acao):
			return
		_confere("F10: «%s» recusado deixa o cliente na mesa" % acao,
			GS.phase == "rival_offer"
				and int(GS.rival_attempts_left) == int(GS.RIVAL_PATIENCE) - 1)
		_f10_medir(p, "Arlindo, última tentativa depois de «%s»" % acao, &"rodada")
		if acao == "Manter":
			GS._rng.seed = _f10_semente_que_recusa(acao)
			if not await _f10_tocar(p, acao):
				return
			_confere("F10: a segunda recusa leva o cliente para o Arlindo",
				p._fala_arlindo.text == GS.texto(Narrativa.ARLINDO_VENCEU))
			_f10_medir(p, "Arlindo, despedida de quem venceu", &"despedida")
			_f10_sem_negociacao(p, "venceu")
		_f10_fechar(p)

	if not _f10_ate_a_oferta(nome):
		return
	p = await _f10_abrir(F10_ARLINDO, [GS.pending_rival_dock])
	if not await _f10_tocar(p, "Igualar"):
		return
	_confere("F10: «Igualar» fecha e o Arlindo perde",
		p._fala_arlindo.text == GS.texto(Narrativa.ARLINDO_PERDEU))
	_f10_medir(p, "Arlindo, despedida de quem perdeu", &"despedida")
	_f10_sem_negociacao(p, "perdeu")
	_f10_fechar(p)

	# ── O fim da Fase 1, com as duas frases que o jogo acabou de escrever.
	for venceu in [true, false]:
		if not _f10_motivos.has(venceu):
			_confere("F10: o jogo emitiu o fim de quem %s" % ("pagou" if venceu else "não pagou"), false)
			return
		p = await _f10_abrir(F10_FIM, [venceu, String(_f10_motivos[venceu])])
		if venceu:
			_f10_medir(p, "Fim, narração", &"narracao")
			if not await _f10_tocar(p, "Ver o balanço"):
				return
		_f10_medir(p, "Fim, balanço de quem %s" % ("venceu" if venceu else "perdeu"), &"balanco")
		_f10_fechar(p)

	# ── O diário, que o jogo abre logo a seguir à tela de nomes e sem `setup()`:
	# o texto sai dos nomes que já estão gravados.
	_f10_partida_nova(nome)
	p = await _f10_abrir(F10_DIARIO, [])
	_f10_medir(p, "Diário", &"")
	_f10_fechar(p)

	GS.game_over.disconnect(_f10_recolher_fim)
	_f10_todo_nome_e_medido(nome)
	GS.clear_save()
	_f10_terminou = true


func _f10_recolher_fim(venceu: bool, motivo: String) -> void:
	_f10_motivos[venceu] = motivo


# TODA FRASE QUE LEVA O NOME FOI MEDIDA COM ELE — o catálogo sai da
# `Narrativa.gd` e a prova sai do que o `_f10_medir()` percorreu. São duas
# fontes, e não um espelho: a primeira é o texto escrito, a segunda o que um
# painel montado pôs num rótulo visível.
#
# Existe porque a lista de casos acima é escrita à mão. Em 23/09 ela cobria
# três painéis e o diário, e o nome não chegava a mais nenhum — o HUD, o
# boletim e as falas da Dona Cida não levam token de nome. No dia em que uma
# linha da Cida passar a dizer o nome do porto, é aqui que reprova, e a saída
# é medir a tela onde ela aparece.
#
# ⚠️ LÊ-SE O ARQUIVO, e não o `get_script_constant_map()` do F4: a narração do
# fim de fase é um texto LOCAL do `fim_de_fase()`, e o mapa das constantes não
# o vê. A leitura por linha é segura aqui por uma razão que não vale para
# chamadas partidas: um token não se parte, e o pedaço de uma linha é sempre um
# pedaço do texto que o rótulo mostra. Linha de comentário não conta — a do
# cabeçalho da `Narrativa.gd` nomeia os tokens para os explicar.
#
# O QUE FICA DE FORA: um pedaço que é SÓ o token satisfaz-se com qualquer
# rótulo medido que traga o nome. É o caso do código que o manipula (o
# `replace("{vocativo}", …)` do `ribeiro_entrada()`), e seria o de um título
# que mostrasse só o nome do porto — esse passaria sem a tela dele ter sido
# medida. E quem lê o nome direto do `GameState`, sem token, não é visto.
func _f10_todo_nome_e_medido(nome: String) -> void:
	var re_token := RegEx.create_from_string("\\{(portName|playerName|vocativo)\\}")
	# Onde o pedaço acaba: aspas, outro token, formato `%` e `\n` escrito.
	var re_corte := RegEx.create_from_string(
		"\"|\\{(?!(?:portName|playerName|vocativo)\\})[A-Za-z_]+\\}|%[-+0-9.]*[a-z]|\\\\n")
	var tokens := 0
	var por_medir: Array[String] = []
	var linhas := FileAccess.get_file_as_string(F10_NARRATIVA).split("\n")
	for i in linhas.size():
		var linha: String = linhas[i]
		if linha.strip_edges().begins_with("#") or re_token.search(linha) == null:
			continue
		var inicio := 0
		var cortes: Array = re_corte.search_all(linha)
		cortes.append(null)
		for corte in cortes:
			var fim: int = linha.length() if corte == null else (corte as RegExMatch).get_start()
			var pedaco := linha.substr(inicio, fim - inicio)
			if corte != null:
				inicio = (corte as RegExMatch).get_end()
			var aqui := re_token.search_all(pedaco).size()
			if aqui == 0:
				continue
			tokens += aqui
			var resolvido := pedaco.replace("{vocativo}", ", " + nome) \
				.replace("{portName}", nome).replace("{playerName}", nome).strip_edges()
			var visto := false
			for texto in _f10_vistos:
				if texto.contains(resolvido):
					visto = true
					break
			if not visto:
				por_medir.append("linha %d «%s»" % [i + 1, pedaco.strip_edges().left(40)])
	# ⚠️ ZERO TOKENS NÃO É "TUDO MEDIDO": é um catálogo que não leu nada.
	_confere("F10: toda frase com o nome foi medida com ele (%d tokens, %d rótulos vistos)"
		% [tokens, _f10_vistos.size()],
		tokens > 0 and por_medir.is_empty(),
		"sem medida: " + "; ".join(por_medir))


func _f10_partida_nova(nome: String) -> void:
	GS.clear_save()
	GS._rng.seed = F10_SEMENTE
	GS.new_game()
	GS.definir_nomes(nome, nome)


# O VENCIMENTO ALCANÇA-SE PELO `advance_turn()`, como a jogar: é ele que põe a
# fase em "debt_payment", e fora dela o `pay_debt()` sai calado — o botão
# "Pagar" mostraria a resposta de quem pagou sem o dinheiro ter mudado de mãos.
func _f10_ate_ao_vencimento(nome: String) -> bool:
	_f10_partida_nova(nome)
	var voltas := 0
	while GS.phase != "debt_payment" and GS.phase != "game_over" and voltas < 200:
		if GS.phase == "rival_offer":
			GS.resolve_rival_offer(true)
		GS.advance_turn()
		voltas += 1
	_confere("F10: a partida chega ao vencimento da parcela (turno %d)" % int(GS.turn),
		GS.phase == "debt_payment", "parou na fase «%s»" % GS.phase)
	return GS.phase == "debt_payment"


func _f10_ate_a_oferta(nome: String) -> bool:
	_f10_partida_nova(nome)
	var voltas := 0
	while GS.phase == "playing" and voltas < 200:
		GS.advance_turn()
		voltas += 1
	_confere("F10: o sorteio abre uma oferta do rival (turno %d)" % int(GS.turn),
		GS.phase == "rival_offer", "parou na fase «%s»" % GS.phase)
	return GS.phase == "rival_offer"


# A SEMENTE QUE FAZ O CLIENTE RECUSAR, derivada da chance que o jogo aplica
# naquele instante — e não um número achado à mão, que deixaria de recusar no
# dia em que a chance ou a reputação mudassem. O `_negociar()` gasta um só
# sorteio, e é o primeiro depois da semente.
func _f10_semente_que_recusa(acao: String) -> int:
	var base: float = GS.RIVAL_HALF_CHANCE if acao.begins_with("Cortar") else GS.RIVAL_KEEP_CHANCE
	var chance: float = GS._chance_com_reputacao(base)
	for semente in range(1, 1000):
		var r := RandomNumberGenerator.new()
		r.seed = semente
		if r.randf() >= chance:
			return semente
	return 0


func _f10_abrir(caminho: String, argumentos: Array) -> Node:
	var cena := load(caminho) as PackedScene
	var painel: Node = cena.instantiate()
	# O TEMA À MÃO, como no `capturar_cena.gd`: no jogo quem o põe é o
	# `_abrir_painel()`, e sem ele as fontes e as margens são outras.
	(painel as Control).theme = load(F10_TEMA)
	root.add_child(painel)
	# O `setup()` corre sempre que o painel o tem — pular o dele por falta de
	# argumentos é o buraco que o `capturar_cena.gd` já cavou uma vez. Painel
	# sem `setup()` com argumentos seria um caso a medir outra coisa.
	if painel.has_method("setup"):
		painel.callv("setup", argumentos)
	else:
		_confere("F10: %s não tem setup(), e o caso não lhe passa argumentos" % caminho,
			argumentos.is_empty())
	await _f8_esperar()
	return painel


func _f10_fechar(painel: Node) -> void:
	root.remove_child(painel)
	painel.free()


# O BOTÃO VERDADEIRO, e um só: dois seria escolher por posição, e um desligado
# seria um toque que o jogador não consegue dar.
func _f10_tocar(painel: Node, prefixo: String, bloco: String = "F10") -> bool:
	var achados: Array = []
	_f10_botoes(painel, prefixo, achados)
	var ok: bool = achados.size() == 1 and not (achados[0] as Button).disabled
	_confere("%s: há um botão «%s…» ligado para tocar" % [bloco, prefixo], ok,
		"achou %d%s" % [achados.size(), " (desligado)" if achados.size() == 1 else ""])
	if not ok:
		return false
	(achados[0] as Button).pressed.emit()
	await _f8_esperar()
	return true


func _f10_botoes(no: Node, prefixo: String, achados: Array) -> void:
	if no is Button and (no as Button).is_visible_in_tree() \
			and not no.is_queued_for_deletion() and (no as Button).text.begins_with(prefixo):
		achados.append(no)
	for filho in no.get_children():
		_f10_botoes(filho, prefixo, achados)


# `tempo` vazio é o painel de uma tela só — e aí ele não pode declarar tempos,
# senão os outros estariam por medir.
func _f10_medir(painel: Node, caso: String, tempo: StringName) -> void:
	if tempo == &"":
		_confere("F10 %s: o painel é de uma tela só" % caso,
			painel.get("tempo") == null, "declara o tempo «%s»" % str(painel.get("tempo")))
	else:
		_confere("F10 %s: o painel está no tempo «%s»" % [caso, tempo],
			painel.tempo == tempo, "está em «%s»" % painel.tempo)
	var cartao := _f10_cartao(painel)
	if cartao == null:
		_confere("F10 %s: o painel tem cartão" % caso, false)
		return
	var tela: Rect2 = root.get_visible_rect()
	var rc := cartao.get_global_rect()
	_confere("F10 %s: o cartão cabe na tela" % caso,
		tela.grow(F10_FOLGA).encloses(rc), "cartão em %s" % rc)
	var fora: Array[String] = []
	var medidos: Array[int] = [0]
	_f10_percorrer(cartao, rc, fora, medidos)
	# ⚠️ ZERO RÓTULOS NÃO É "NADA FORA": é uma medida que não mediu.
	_confere("F10 %s: todo o texto cai dentro do cartão (%d peças)" % [caso, medidos[0]],
		fora.is_empty() and medidos[0] > 0, "; ".join(fora))


func _f10_cartao(painel: Node) -> Control:
	var fila: Array = [painel]
	while not fila.is_empty():
		var no: Node = fila.pop_front()
		if no is PanelContainer and (no as Control).is_visible_in_tree():
			return no
		fila.append_array(no.get_children())
	return null


# Desce pelo cartão com o recorte de quem recorta: uma área rolável ESCONDE o
# que não cabe nela, e o que está escondido não está no cartão.
func _f10_percorrer(no: Node, recorte: Rect2, fora: Array[String], medidos: Array[int]) -> void:
	if not (no is Control) or not (no as Control).is_visible_in_tree() \
			or no.is_queued_for_deletion():
		return
	var ctrl := no as Control
	if no is ScrollContainer:
		recorte = recorte.intersection(ctrl.get_global_rect())
	var limite := recorte.grow(F10_FOLGA)
	if no is Label and (no as Label).text != "":
		var rotulo := no as Label
		medidos[0] += 1
		_f10_vistos.append(rotulo.text)
		if rotulo.get_visible_line_count() < rotulo.get_line_count():
			fora.append("«%s…» mostra %d de %d linhas" % [rotulo.text.left(24),
				rotulo.get_visible_line_count(), rotulo.get_line_count()])
		for i in rotulo.text.length():
			var caixa: Rect2 = rotulo.get_character_bounds(i)
			if caixa.size == Vector2.ZERO:
				continue
			caixa.position += rotulo.global_position
			if not limite.encloses(caixa):
				fora.append("«%s…» desenha o caractere %d em %s" % [
					rotulo.text.left(24), i, caixa])
				break
	elif no is Button:
		medidos[0] += 1
		if not limite.encloses(ctrl.get_global_rect()):
			fora.append("o botão «%s» sai para %s" % [(no as Button).text, ctrl.get_global_rect()])
	for filho in no.get_children():
		_f10_percorrer(filho, recorte, fora, medidos)


# A NEGOCIAÇÃO ACABOU, e o painel não pode continuar a dizer que o cliente
# está a ouvir. A linha do humor dizia "Cliente ouvindo a proposta. (2
# tentativas)" por baixo das duas despedidas, e só a foto do segundo tempo o
# mostrou.
func _f10_sem_negociacao(painel: Node, caso: String) -> void:
	var textos: Array[String] = []
	_f10_textos_visiveis(_f10_cartao(painel), textos)
	var achou := ""
	for t in textos:
		if t.contains("tentativa") or t.begins_with("Cliente"):
			achou = t
	_confere("F10 Arlindo, despedida de quem %s: nada diz que a negociação continua" % caso,
		achou == "" and textos.size() > 0, "ainda diz: " + achou)


func _f10_textos_visiveis(no: Node, textos: Array[String]) -> void:
	if no == null or (no is Control and not (no as Control).is_visible_in_tree()) \
			or no.is_queued_for_deletion():
		return
	if no is Label:
		textos.append((no as Label).text)
	for filho in no.get_children():
		_f10_textos_visiveis(filho, textos)


# ══ F11 — A VEZ DAS TELAS DO FIM ════════════════════════════════════════════
#
# O «Pagar» fecha a semana 4 e acaba a partida na mesma chamada, e até 23/09 o
# boletim e o fim de fase abriam POR CIMA da resposta do Sr. Ribeiro: quem
# tocava «Jogar de novo» nunca a lia, nem o último boletim. O `Main` põe as
# três telas em fila (`_na_vez()`, `docs/decisoes/054`), e este bloco percorre
# a fila pelos botões do jogador nos três caminhos que acabam a partida com a
# semana a fechar — pagou, não pagou, e quitou antes do prazo.
#
# ⚠️ CADA PASSO PERGUNTA «SOZINHO», e não só «por cima». Sem a fila, a resposta
# do Sr. Ribeiro continua a existir depois do «Pagar» — está lá, por baixo de
# duas telas —, e uma guarda que perguntasse se ela existe passaria.
#
# ⚠️ E A ORDEM PERGUNTA-SE PASSO A PASSO. «Todas aparecem» não implica «pela
# ordem certa»: uma fila que servisse primeiro o último a chegar mostraria as
# três telas, uma de cada vez, com o fim de fase antes do boletim.
#
# O terceiro caminho é o único em que o boletim tem a vez SEM o Sr. Ribeiro à
# frente, e o único que passa pela ordem dos sinais do `advance_turn()` — os
# outros dois passam pela do `pay_debt()` e do `fail_debt()`. Medido: com a
# última semana a fechar DEPOIS do fim da partida só no `advance_turn()`, só ele
# reprova; e com a fila a servir o último a chegar, só ele passa, porque nele a
# fila nunca tem dois à espera.
#
# ⚠️ O QUE ESTE BLOCO NÃO VÊ: a fila ligada ao `fechou` em vez do
# `tree_exited`. A jogar, toda tela que tem a vez sai pelo `_fechar()`, e o
# bloco passa. Quem o apanha é o tiro `balanco` da captura, cujo laço dispensa
# boletins por `remove_child()` — ver o comentário do `_na_vez()`.
const F11_RIBEIRO := "res://scenes/panels/DebtPaymentPanel.tscn"
const F11_BOLETIM := "res://scenes/panels/PainelBoletim.tscn"
var _f11_terminou := false


# ⚠️ OS TRÊS CAMINHOS CORREM SEMPRE, e cada um leva a sua bandeira. Um caminho
# que reprova sai cedo e deixa os outros correr — senão o primeiro vermelho
# esconderia o que os outros dois veem. E a bandeira é o `true` com que cada um
# sai, em TODA saída: só um erro de execução, que aborta a função, devolve outra
# coisa — e sem ela esse erro passaria calado, porque a função do bloco segue.
func _f11_a_vez_do_fim() -> void:
	var pagou = await _f11_pagou()
	var nao_pagou = await _f11_nao_pagou()
	var quitou = await _f11_quitou_antes()
	_f11_terminou = pagou == true and nao_pagou == true and quitou == true
	GS.clear_save()


# O dinheiro é dado, com folga para os custos da semana 4: o que se testa é a
# ordem das telas, e o «Pagar» só está ligado com dinheiro.
func _f11_pagou() -> bool:
	if not _f11_ate_ao_ultimo_dia():
		return true
	GS.cash = GS.PARCELA_AMOUNT * 2
	var main: Node = await _f11_main_e_virar_o_dia()
	var p: Node = _f11_sozinho(main, F11_RIBEIRO, "entrada", "pagou, no vencimento")
	if p == null or not await _f10_tocar(p, "Pagar", "F11"):
		main.free()
		return true
	_confere("F11: pagou — o «Pagar» acabou a partida ganha",
		GS.phase == "game_over" and bool(GS.won),
		"fase «%s», won=%s" % [GS.phase, str(GS.won)])
	await _f11_ate_ao_fim(main, _f11_sozinho(main, F11_RIBEIRO, "pagou",
		"pagou, depois do «Pagar»"), "Até a próxima", "narracao", "pagou")
	return true


# Sem dinheiro dado: a partida desta semente chega ao vencimento sem ele, e é
# isso que põe o «Não consigo pagar» na tela. Quem perde vai direto ao
# balanço — o `EndGame` não lhe lê a narração.
func _f11_nao_pagou() -> bool:
	if not _f11_ate_ao_ultimo_dia():
		return true
	var main: Node = await _f11_main_e_virar_o_dia()
	var p: Node = _f11_sozinho(main, F11_RIBEIRO, "entrada", "não pagou, no vencimento")
	if p == null or not await _f10_tocar(p, "Não consigo", "F11"):
		main.free()
		return true
	await _f11_ate_ao_fim(main, _f11_sozinho(main, F11_RIBEIRO, "nao_pagou",
		"não pagou, depois do «Não consigo»"), "Adeus", "balanco", "não pagou")
	return true


# Sem Sr. Ribeiro: é o «Avançar dia» do último dia que fecha a semana e acaba a
# partida, e o boletim abre primeiro.
func _f11_quitou_antes() -> bool:
	if not _f11_ate_ao_ultimo_dia():
		return true
	GS.cash = GS.PARCELA_AMOUNT * 2
	_confere("F11: quitou antes — a parcela pagou-se no último dia a jogar",
		GS.pagar_parcela_adiantado())
	var main: Node = await _f11_main_e_virar_o_dia()
	_confere("F11: quitou antes — virar o último dia acabou a partida ganha",
		GS.phase == "game_over" and bool(GS.won),
		"fase «%s», won=%s" % [GS.phase, str(GS.won)])
	await _f11_ate_ao_fim(main, null, "", "narracao", "quitou antes")
	return true


# Joga pelo `advance_turn()`, SEM Main, e pára no último dia ainda por jogar:
# é a virada dele que abre o Sr. Ribeiro ou fecha a semana, e ela tem de
# acontecer com o Main a ouvir — pelo botão dele.
func _f11_ate_ao_ultimo_dia() -> bool:
	GS.clear_save()
	GS._rng.seed = F10_SEMENTE
	GS.new_game()
	GS.definir_nomes(GS.NOME_PORTO_PADRAO, "")
	var voltas := 0
	while int(GS.turn) < int(GS.PARCELA_DUE_TURN) and voltas < 200:
		if GS.phase == "rival_offer":
			GS.resolve_rival_offer(true)
		GS.advance_turn()
		voltas += 1
	if GS.phase == "rival_offer":
		GS.resolve_rival_offer(true)
	var ok: bool = GS.phase == "playing" and int(GS.turn) == int(GS.PARCELA_DUE_TURN)
	_confere("F11: a partida chega ao último dia a jogar (turno %d)" % int(GS.turn),
		ok, "fase «%s»" % GS.phase)
	return ok


func _f11_main_e_virar_o_dia() -> Node:
	var main: Node = (load("res://scenes/Main.tscn") as PackedScene).instantiate()
	root.add_child(main)
	await _f8_esperar()
	_confere("F11: o Main abre sem painel nenhum no último dia",
		main.get_node("Overlay").get_child_count() == 0)
	main.call("_on_advance_pressed")
	await _f8_esperar()
	return main


# O RESTO DA FILA, a partir da tela que tem a vez: ela fecha pelo botão dela,
# depois o boletim da última semana, sozinho, e depois o fim de fase, sozinho,
# no tempo que a partida pede. `primeiro` nulo quer dizer que a fila já abre
# no boletim.
func _f11_ate_ao_fim(main: Node, primeiro: Node, botao: String, tempo_fim: String,
		caso: String) -> void:
	if botao == "" or (primeiro != null and await _f10_tocar(primeiro, botao, "F11")):
		var boletim := _f11_sozinho(main, F11_BOLETIM, "", "%s, o boletim" % caso)
		if boletim != null:
			var semana: int = int((boletim.get("_resumo") as Dictionary)["semana"])
			_confere("F11: %s — o boletim é o da última semana" % caso,
				semana == int(GS.WEEKS_TOTAL), "é o da semana %d" % semana)
			if await _f10_tocar(boletim, "Fechar o boletim", "F11"):
				_f11_sozinho(main, F10_FIM, tempo_fim, "%s, fechado o boletim" % caso)
	main.free()


func _f11_sozinho(main: Node, cena: String, tempo: String, caso: String) -> Node:
	var overlay: Node = main.get_node("Overlay")
	var vistos := PackedStringArray()
	for painel in overlay.get_children():
		vistos.append("%s«%s»" % [painel.scene_file_path.get_file(),
			String(painel.get("tempo")) if "tempo" in painel else ""])
	var n: int = overlay.get_child_count()
	var topo: Node = null if n == 0 else overlay.get_child(n - 1)
	var tempo_visto: String = "" if topo == null or not "tempo" in topo \
		else String(topo.get("tempo"))
	var ok: bool = n == 1 and topo.scene_file_path == cena and tempo_visto == tempo
	_confere("F11: %s — só %s%s na tela" % [caso, cena.get_file(),
		"" if tempo == "" else " «%s»" % tempo], ok,
		"na tela, de baixo para cima: %s" % (", ".join(vistos) if n > 0 else "nada"))
	return topo if ok else null


# ── F12 ─────────────────────────────────────────────────────────────────
# Os trinta retratos do cartão (`docs/decisoes/059`). O rosto é um campo do
# trabalhador, escolhido ao nascer por um gerador PRÓPRIO, e cada pergunta
# abaixo tem o seu defeito — injetado e visto a reprovar ao escrever o bloco:
#
# - o registo contra o DISCO, nos dois sentidos: um PNG gerado e não
#   registado é o `barco_medio` (o mutante: tirar uma linha do registo);
# - TRINTA trabalhadores, e não três: com três, um sorteio que não excluísse
#   os usados repetiria só uma vez em dez (o mutante: `livres` sem o filtro);
# - o `_rng.state` antes e depois: o rosto não gasta o sorteio que o
#   simulador mede (o mutante: `_rng.randi_range` no lugar do gerador);
# - toda cara ALCANÇÁVEL de uma partida nova, e a mesma semente a dar a mesma
#   cara (os mutantes: a semente constante, e o `randomize()`);
# - o save recusa sem ter tocado em nada: sem rosto, fora da tabela,
#   repetido e escrito como texto (os mutantes: cada conferência retirada);
# - o cartão mostra o ARQUIVO do rosto (o mutante: o `Worker.gd` sem a linha).
var _f12_terminou := false


func _f12_o_rosto_do_trabalhador() -> void:
	var Ret: GDScript = load("res://scripts/Retratos.gd")
	var caminhos: Array = Ret.get_script_constant_map()["TRABALHADORES"]
	_confere("F12: o registo tem os trinta rostos (%d)" % caminhos.size(),
		caminhos.size() == 30)
	_confere("F12: o jogo conta os rostos pelo registo", GS.rostos() == caminhos.size())

	# 1 — o registo contra o disco, nos dois sentidos.
	var registados := {}
	for c in caminhos:
		registados[String(c).get_file()] = true
		_confere("F12: %s existe" % String(c).get_file(), ResourceLoader.exists(String(c)))
	var no_disco := 0
	for f in DirAccess.get_files_at("res://art/props"):
		if f.begins_with("trabalhador_") and f.ends_with(".png"):
			no_disco += 1
			_confere("F12: %s está no registo" % f, registados.has(f),
				"gerado e sem quem o mostre")
	_confere("F12: a varredura do disco achou os trinta (%d)" % no_disco, no_disco == 30)
	var cena := load("res://scenes/worker/Worker.tscn") as PackedScene
	var tex_cena: Texture2D = (cena.instantiate().get_node("Conteudo/Retrato") as TextureRect).texture
	_confere("F12: o rosto 0 é o retrato que a cena traz",
		tex_cena != null and tex_cena.resource_path == String(caminhos[0]))

	# 2 e 3 — trinta trabalhadores, trinta rostos, e o `_rng` parado.
	GS._rng.seed = 12012
	GS.new_game()
	var estado_antes: int = GS._rng.state
	while GS.workers.size() < caminhos.size():
		GS.workers.append(GS.novo_trabalhador())
	var vistos := {}
	var fora := 0
	for w in GS.workers:
		var k := int(w["rosto"])
		if k < 0 or k >= caminhos.size():
			fora += 1
		vistos[k] = true
	_confere("F12: trinta trabalhadores, trinta rostos diferentes (%d)" % vistos.size(),
		vistos.size() == caminhos.size() and fora == 0)
	_confere("F12: escolher o rosto não mexe no sorteio da partida",
		GS._rng.state == estado_antes)

	# 4 — toda cara sai de ALGUMA partida nova, e a mesma semente dá a mesma.
	var primeiros := {}
	for semente in range(1, 401):
		GS._rng.seed = semente
		GS.new_game()
		primeiros[int(GS.workers[0]["rosto"])] = true
	_confere("F12: as trinta caras saem de partidas novas (%d de 30, 400 sementes)"
		% primeiros.size(), primeiros.size() == caminhos.size())
	GS._rng.seed = 777
	GS.new_game()
	var a := int(GS.workers[0]["rosto"])
	GS._rng.seed = 777
	GS.new_game()
	_confere("F12: a mesma semente dá a mesma cara (as fotos comparam-se)",
		int(GS.workers[0]["rosto"]) == a)

	# 5 — o save guarda o rosto, e recusa o que não é rosto sem tocar em nada.
	# ⚠️ COM OS TRÊS PÍERES, e não os três trabalhadores soltos: o
	# `_reconciliar_roster()` do carregamento corta o elenco ao que o porto
	# construído aguenta, e a primeira versão deste bloco salvou três num porto
	# de uma doca — voltava um, e reprovava o jogo certo.
	GS.estruturas = ["pier_2", "pier_3"]
	while GS.docks.size() < GS.BERCOS_NO_MAPA:
		GS.docks.append({"boat": null, "worker_id": null})
	while GS.workers.size() < GS.BERCOS_NO_MAPA:
		GS.workers.append(GS.novo_trabalhador())
	var rostos_vivos: Array = GS.workers.map(func(w): return int(w["rosto"]))
	GS.save_game()
	GS.workers = []
	_confere("F12: o save carrega", GS.load_game())
	_confere("F12: e os rostos voltam iguais",
		GS.workers.map(func(w): return int(w["rosto"])) == rostos_vivos,
		"eram %s, voltaram %s" % [rostos_vivos, GS.workers.map(func(w): return w.get("rosto"))])
	var maus := {
		"sem rosto": [{"id": 1, "busy_turns": 0}],
		"rosto fora da tabela": [{"id": 1, "busy_turns": 0, "rosto": caminhos.size()}],
		"rosto negativo": [{"id": 1, "busy_turns": 0, "rosto": -1}],
		"rosto repetido": [{"id": 1, "busy_turns": 0, "rosto": 4},
			{"id": 2, "busy_turns": 0, "rosto": 4}],
		"rosto em texto": [{"id": 1, "busy_turns": 0, "rosto": "3"}],
		"rosto partido": [{"id": 1, "busy_turns": 0, "rosto": 2.5}],
	}
	for caso in maus:
		var dados := _save_valido(GS.SAVE_VERSION)
		dados["workers"] = maus[caso]
		dados["docks"] = [{"boat": null, "worker_id": null}, {"boat": null, "worker_id": null}]
		_escrever(dados)
		GS.turn = 4321
		var carregou: bool = GS.load_game()
		_confere("F12: save com %s é recusado, e sem ter tocado em nada" % caso,
			not carregou and GS.turn == 4321, "carregou=%s turn=%d" % [carregou, GS.turn])
	# E o válido, com o rosto certo, entra — senão os seis acima passariam por
	# um `load_game()` que recusa tudo.
	var bom := _save_valido(GS.SAVE_VERSION)
	bom["workers"] = [{"id": 1, "busy_turns": 0, "rosto": caminhos.size() - 1}]
	_escrever(bom)
	_confere("F12: o save com um rosto válido entra", GS.load_game())

	# 6 — o cartão mostra o arquivo do rosto, pela porta do jogo.
	GS._rng.seed = 12012
	GS.new_game()
	GS.workers[0]["rosto"] = caminhos.size() - 1
	var cartao: Node = cena.instantiate()
	root.add_child(cartao)
	cartao.setup(int(GS.workers[0]["id"]))
	var tex: Texture2D = (cartao.get_node("Conteudo/Retrato") as TextureRect).texture
	_confere("F12: o cartão mostra o retrato do rosto dele",
		tex != null and tex.resource_path == String(caminhos[caminhos.size() - 1]),
		"mostra %s" % (tex.resource_path if tex != null else "nada"))
	cartao.free()
	GS.clear_save()
	GS.new_game()
	_f12_terminou = true


# ── F13 ─────────────────────────────────────────────────────────────────
# ONDE ESTA CORRIDA ESCREVE? (`docs/decisoes/061`)
#
# Em 25/09 uma captura apagou a partida real do Bruno no desktop, e a varredura
# achou mais dois caminhos com a mesma raiz: as suítes que limpam a pasta de
# registros e o `teste_audio` que grava o volume a zero. Hoje os três saem do
# `ArmazemLocal`, que manda todo processo com `--script` para
# `user://ferramentas/`.
#
# ⚠️ O QUE ESTE BLOCO NÃO PROVA: que o arquivo do jogador ficou intacto. Ler
# esse arquivo numa suíte que corre no desktop seria tocá-lo, e escrever-lhe
# uma sentinela seria APAGAR a partida que se quer proteger. Quem prova o
# arquivo é o CI, que planta a sentinela num contêiner onde não há jogador
# nenhum e a exige intacta no fim (`tools/sentinela_do_jogador.py`). Aqui
# prova-se a CAUSA: de onde vem cada caminho, e que ninguém escreve por fora.
var _f13_terminou := false


func _f13_o_armazem_do_jogador() -> void:
	var raiz: String = ArmazemLocal.RAIZ_DAS_FERRAMENTAS
	_confere("F13: esta suíte corre como ferramenta", ArmazemLocal.sob_ferramenta(),
		"args %s" % [OS.get_cmdline_args()])
	# Os dois lados da pergunta, com a linha de comando escrita à mão: sem o
	# lado do JOGO, um `sob_ferramenta()` que respondesse sempre `true` passava
	# — e o jogo passaria a gravar numa pasta que nenhuma partida relê.
	var jogo := PackedStringArray(["--path", "brport_vs"])
	_confere("F13: o jogo aberto normalmente grava no lugar do jogador",
		ArmazemLocal.caminho("savegame.json", jogo) == "user://savegame.json",
		ArmazemLocal.caminho("savegame.json", jogo))
	for forma in ["--script", "-s"]:
		var args := PackedStringArray([forma, "res://tests/teste_fumaca.gd"])
		_confere("F13: `%s` conta como ferramenta" % forma,
			ArmazemLocal.caminho("savegame.json", args) == raiz + "savegame.json")

	# Os três que já apagaram ou podiam apagar o que era do jogador.
	var registro: Node = root.get_node("Registro")
	var audio: Node = root.get_node("Audio")
	var caminhos := {
		"o save": String(GS.save_path),
		"a pasta de registros": String(registro.pasta),
		"o volume": String(audio.config),
	}
	for qual in caminhos:
		_confere("F13: %s desta corrida vive em %s" % [qual, raiz],
			String(caminhos[qual]).begins_with(raiz), String(caminhos[qual]))

	# E O ARQUIVO CHEGA MESMO AO DISCO. O `FileAccess.open(..., WRITE)` não
	# cria pasta: sem ela o save sairia calado e sem arquivo, e toda suíte que
	# lê o save de volta passaria a testar o `load_game()` de um disco vazio.
	# ⚠️ A SONDA VAI NUMA SUBPASTA QUE NINGUÉM MAIS CRIA. Com o save, a prova
	# passava com a criação da pasta retirada: o F1 já tinha instanciado o
	# `Main`, e o `Registro` armado cria `ferramentas/registros` — com a mãe.
	var sonda_pasta := raiz + "f13_sonda"
	if FileAccess.file_exists(sonda_pasta + "/sonda.txt"):
		DirAccess.remove_absolute(sonda_pasta + "/sonda.txt")
	DirAccess.remove_absolute(sonda_pasta)
	var sonda := ArmazemLocal.caminho("f13_sonda/sonda.txt")
	var escrita := FileAccess.open(sonda, FileAccess.WRITE)
	if escrita != null:
		escrita.store_string("F13")
		escrita.close()
	_confere("F13: o caminho que o ArmazemLocal dá já tem pasta para gravar",
		FileAccess.file_exists(sonda), sonda)
	DirAccess.remove_absolute(sonda)
	DirAccess.remove_absolute(sonda_pasta)
	# E o autosave do jogo passa por ele, e não só a sonda.
	GS.clear_save()
	GS.save_game()
	_confere("F13: o autosave desta corrida chega ao arquivo isolado",
		FileAccess.file_exists(GS.save_path), GS.save_path)
	GS.clear_save()

	# NINGUÉM ESCREVE `user://` POR FORA. Um quarto arquivo de estado que
	# nascesse com o caminho literal voltaria a ser partilhado com o jogador, e
	# os três testes acima passariam contentes. A varredura é do código do JOGO
	# — as ferramentas escrevem lá as fotos que produzem, que não são de
	# ninguém — e corta as linhas de comentário, que citam `user://` a explicar
	# isto mesmo.
	var por_fora: Array[String] = []
	for arquivo in _f9_scripts_do_jogo():
		if arquivo.get_file() == "ArmazemLocal.gd":
			continue
		var fonte := _sem_comentarios(FileAccess.get_file_as_string(arquivo))
		if fonte.contains("user://"):
			por_fora.append(arquivo)
	_confere("F13: só o ArmazemLocal escreve `user://` no código do jogo",
		por_fora.is_empty(), ", ".join(por_fora))
	_f13_terminou = true


# ── F14 ─────────────────────────────────────────────────────────────────
# A PROMESSA DO PAINEL CONTRA O QUE O JOGO FAZ (`docs/decisoes/062`).
#
# A frente 3 do A5 pôs número de decisão ao lado de cada escolha — a falta ou
# o que sobra na cobrança, o preço e a chance em cada botão do Arlindo, e
# desde 25/09 o que acontece se ele recusar. Cada um desses números é uma
# PREVISÃO que o painel calcula, e o jogo faz a conta noutro sítio: o
# `pay_debt()`, o `_fechar_negocio()`, o sorteio do `_negociar()`. Nada
# perguntava se as duas concordam — a passagem anterior deu a chance por
# certa «pelo uso da mesma função», e isso prova que a chamada é a mesma, não
# que o sorteio a aplica.
#
# ⚠️ POR ISSO CADA PERGUNTA LÊ O TEXTO NA TELA E O RESULTADO NO JOGO, e nunca
# a mesma conta dos dois lados: o esperado vem de onde o defeito NÃO mora. A
# chance mede-se pela frequência do próprio sorteio, 4.000 apostas por opção
# em duas reputações — ±4 pontos de folga, ~5 desvios-padrão no pior caso
# (p = 0,5), contra 20 a 45 pontos de diferença se o painel voltar a mostrar
# a constante de base.
# ⚠️ A PRIMEIRA VERSÃO USAVA 800 E ±7, e passou com 4,4 pontos de desvio: a
# sequência da semente calhava alta. Com 20.000 apostas as quatro chances
# bateram a ±0,2 ponto — o painel estava certo e o corte colado à ponta da
# banda. E cada caso leva a SUA semente: com uma só, as duas reputações
# sorteavam a mesma sequência e o acaso de uma era o da outra.
#
# ⚠️ E CADA CAMINHO LEVA A SUA BANDEIRA: o primeiro vermelho de um caminho
# encadeado esconderia os outros (`054`).
const F14_AMOSTRA := 4000
const F14_FOLGA := 4.0
const F14_SEMENTE := 20260925

var _f14_terminou := false
var _f14_cobranca_ok := false
var _f14_precos_ok := false
var _f14_recusa_ok := false
var _f14_chance_ok := false
var _f14_boletim_ok := false
var _f14_balanco_ok := false


func _f14_promessa_e_resultado() -> void:
	await _f14_cobranca()
	_confere("F14: o caminho da cobrança correu até ao fim", _f14_cobranca_ok)
	await _f14_precos()
	_confere("F14: o caminho dos preços correu até ao fim", _f14_precos_ok)
	await _f14_recusa()
	_confere("F14: o caminho da recusa correu até ao fim", _f14_recusa_ok)
	await _f14_chance()
	_confere("F14: o caminho da chance correu até ao fim", _f14_chance_ok)
	await _f14_boletim()
	_confere("F14: o caminho do boletim correu até ao fim", _f14_boletim_ok)
	await _f14_balanco()
	_confere("F14: o caminho do balanço correu até ao fim", _f14_balanco_ok)
	GS.clear_save()
	GS._rng.seed = F10_SEMENTE
	GS.new_game()
	_f14_terminou = true


# Os valores em reais de um texto, pela ordem — `R$1.234.567` vira 1234567.
func _f14_reais(texto: String) -> Array:
	var re := RegEx.new()
	re.compile("R\\$(\\d{1,3}(?:\\.\\d{3})*)")
	var fora: Array = []
	for m in re.search_all(texto):
		fora.append(int(m.get_string(1).replace(".", "")))
	return fora


# O texto VISÍVEL que começa por `prefixo`, e um só: dois seriam escolher por
# posição, e nenhum é a pergunta a reprovar por quem chama.
func _f14_texto(painel: Node, prefixo: String) -> String:
	var textos: Array[String] = []
	_f10_textos_visiveis(painel, textos)
	var achados: Array[String] = []
	for t in textos:
		if t.begins_with(prefixo):
			achados.append(t)
	return achados[0] if achados.size() == 1 else ""


func _f14_botao(painel: Node, prefixo: String) -> String:
	var achados: Array = []
	_f10_botoes(painel, prefixo, achados)
	return (achados[0] as Button).text if achados.size() == 1 else ""


# A irmã do `_f10_semente_que_recusa()`: o primeiro sorteio depois dela cai
# DENTRO da chance que o jogo aplica agora.
func _f14_semente_que_aceita(prefixo: String) -> int:
	var base: float = GS.RIVAL_HALF_CHANCE if prefixo == "Cortar" else GS.RIVAL_KEEP_CHANCE
	var chance: float = GS._chance_com_reputacao(base)
	for semente in range(1, 1000):
		var r := RandomNumberGenerator.new()
		r.seed = semente
		if r.randf() < chance:
			return semente
	return 0


# A COBRANÇA. O «Depois de pagar» é calculado pelo painel ANTES do toque; o
# dinheiro que fica sai do `pay_debt()` DEPOIS dele. A sobra não é redonda nem
# zero de propósito: a bateria paga com o dinheiro exacto da parcela, e R$0 é
# também o que uma subtracção esquecida dá.
func _f14_cobranca() -> void:
	var parcela: int = int(GS.PARCELA_AMOUNT)
	if not _f10_ate_ao_vencimento("F14"):
		return
	GS.cash = parcela + 123457
	var painel: Node = await _f10_abrir(F10_RIBEIRO, [parcela])
	var previsto := _f14_reais(_f14_texto(painel, "Depois de pagar"))
	var partes := _f14_reais(_f14_texto(painel, "Você tem"))
	_confere("F14: a cobrança mostra, ao lado do saldo, o dinheiro e a parcela",
		partes.size() == 2 and int(partes[0]) == int(GS.cash) and int(partes[1]) == parcela,
		str(partes))
	_f14_barra_da_parcela(painel, int(GS.cash), parcela)
	_f14_tom_confere(painel, "cobrança com dinheiro")
	if not await _f10_tocar(painel, "Pagar", "F14"):
		_f10_fechar(painel)
		return
	_confere("F14: «Depois de pagar» é o dinheiro que o pagamento deixa",
		previsto.size() == 1 and int(previsto[0]) == int(GS.cash),
		"previa %s, o jogo deixou %d" % [str(previsto), int(GS.cash)])
	var ficou := _f14_reais(_f14_texto(painel, "Você fica com"))
	_confere("F14: a resposta de quem pagou diz o dinheiro que ficou",
		ficou.size() == 1 and int(ficou[0]) == int(GS.cash), str(ficou))
	_f14_tom_confere(painel, "resposta de quem pagou")
	_f10_fechar(painel)

	if not _f10_ate_ao_vencimento("F14"):
		return
	GS.cash = parcela - 76543
	painel = await _f10_abrir(F10_RIBEIRO, [parcela])
	var falta := _f14_reais(_f14_texto(painel, "Faltam"))
	_confere("F14: «Faltam» é a parcela menos o dinheiro",
		falta.size() == 1 and int(falta[0]) == parcela - int(GS.cash), str(falta))
	_f14_barra_da_parcela(painel, int(GS.cash), parcela)
	_f14_tom_confere(painel, "cobrança sem dinheiro")
	if not await _f10_tocar(painel, "Não consigo", "F14"):
		_f10_fechar(painel)
		return
	var faltaram := _f14_reais(_f14_texto(painel, "Faltaram"))
	_confere("F14: a resposta de quem não pagou repete a falta",
		faltaram.size() == 1 and falta.size() == 1 and int(faltaram[0]) == int(falta[0]),
		str(faltaram))
	_f14_tom_confere(painel, "resposta de quem não pagou")
	_f10_fechar(painel)
	_f14_cobranca_ok = true


# OS PREÇOS DOS TRÊS BOTÕES, contra o `matched_value` que o
# `_fechar_negocio()` escreve — que é o que o jogo paga. As apostas ganham pela
# semente, e a despedida tem de repetir o mesmo número.
func _f14_precos() -> void:
	for prefixo in ["Igualar", "Cortar", "Manter"]:
		if not _f10_ate_a_oferta("F14"):
			return
		var doca := int(GS.pending_rival_dock)
		var barco: Dictionary = GS.docks[doca]["boat"]
		var painel: Node = await _f10_abrir(F10_ARLINDO, [doca])
		var mostrado := _f14_reais(_f14_botao(painel, prefixo))
		_f14_tom_confere(painel, "negociação aberta")
		if prefixo != "Igualar":
			GS._rng.seed = _f14_semente_que_aceita(prefixo)
		if not await _f10_tocar(painel, prefixo, "F14"):
			_f10_fechar(painel)
			return
		var cobrado: int = int(barco.get("matched_value", -1))
		_confere("F14: «%s» mostra o preço por que o jogo fecha" % prefixo,
			mostrado.size() == 1 and int(mostrado[0]) == cobrado,
			"mostrava %s, fechou por %d" % [str(mostrado), cobrado])
		var fechado := _f14_reais(_f14_texto(painel, "Fechado por"))
		_confere("F14: depois de «%s», a despedida diz o preço fechado" % prefixo,
			fechado.size() == 1 and int(fechado[0]) == cobrado, str(fechado))
		_f14_tom_confere(painel, "negócio fechado por «%s»" % prefixo)
		_f10_fechar(painel)
	_f14_precos_ok = true


# A RECUSA. A linha do cliente promete, antes da aposta, o que sobra e quanto
# passa a custar igualar; na última rodada, que o barco vai para o rival. Duas
# partidas: recusa-recusa (o barco sai) e recusa-igualar (o preço novo é o
# que o jogo cobra).
func _f14_recusa() -> void:
	var tentativas := RegEx.new()
	tentativas.compile("fica com (\\d+) tentativa")
	var desconto := RegEx.new()
	desconto.compile("igualar passa a −(\\d+)%")
	for depois_igualar in [false, true]:
		if not _f10_ate_a_oferta("F14"):
			return
		var doca := int(GS.pending_rival_dock)
		var barco: Dictionary = GS.docks[doca]["boat"]
		var painel: Node = await _f10_abrir(F10_ARLINDO, [doca])
		var promessa := _f14_texto(painel, "Cliente")
		var sobra := tentativas.search(promessa)
		var novo := desconto.search(promessa)
		_confere("F14: antes da aposta, o cliente diz o que sobra e o novo desconto",
			sobra != null and novo != null, promessa)
		if sobra == null or novo == null:
			_f10_fechar(painel)
			return
		GS._rng.seed = _f10_semente_que_recusa("Manter")
		if not await _f10_tocar(painel, "Manter", "F14"):
			_f10_fechar(painel)
			return
		_confere("F14: recusada a aposta, sobram as tentativas prometidas (%s)" % sobra.get_string(1),
			GS.phase == "rival_offer" and int(GS.rival_attempts_left) == int(sobra.get_string(1)),
			"fase %s, sobram %d" % [GS.phase, int(GS.rival_attempts_left)])
		var igualar := _f14_botao(painel, "Igualar")
		_confere("F14: e igualar passou ao desconto prometido (−%s%%)" % novo.get_string(1),
			igualar.contains("(−%s%%)" % novo.get_string(1)), igualar)
		if depois_igualar:
			var mostrado := _f14_reais(igualar)
			if not await _f10_tocar(painel, "Igualar", "F14"):
				_f10_fechar(painel)
				return
			_confere("F14: o igualar mais caro fecha pelo preço mostrado",
				mostrado.size() == 1 and int(mostrado[0]) == int(barco.get("matched_value", -1)),
				"mostrava %s, fechou por %s" % [str(mostrado), str(barco.get("matched_value"))])
		else:
			var ultima := _f14_texto(painel, "Cliente")
			_confere("F14: na última rodada, o cliente promete ir para o Porto Farol",
				ultima.contains("Porto Farol"), ultima)
			var perdidas := int(GS.metrics["rival_refused"])
			GS._rng.seed = _f10_semente_que_recusa("Manter")
			if not await _f10_tocar(painel, "Manter", "F14"):
				_f10_fechar(painel)
				return
			_f14_tom_confere(painel, "negócio perdido")
			_confere("F14: recusada a última, o barco foi mesmo para o rival",
				GS.docks[doca]["boat"] == null and int(GS.metrics["rival_refused"]) == perdidas + 1,
				"barco %s, perdidas %d" % [str(GS.docks[doca]["boat"] != null), int(GS.metrics["rival_refused"])])
		_f10_fechar(painel)
	_f14_recusa_ok = true


# A CHANCE, medida pelo sorteio do jogo. O painel imprime a percentagem; o
# `_negociar()` sorteia com o `_rng` da partida. Cada volta repõe a oferta
# inteira — o barco, a paciência, a fase e a reputação, que o fecho sobe —
# para que as apostas sejam todas a MESMA aposta.
func _f14_chance() -> void:
	var chance := RegEx.new()
	chance.compile("(\\d+)% de chance")
	for reputacao in [100.0, 20.0]:
		if not _f10_ate_a_oferta("F14"):
			return
		GS.reputation = reputacao
		var doca := int(GS.pending_rival_dock)
		var molde: Dictionary = (GS.docks[doca]["boat"] as Dictionary).duplicate(true)
		var painel: Node = await _f10_abrir(F10_ARLINDO, [doca])
		var promessas := {}
		var barras := {}
		for prefixo in ["Cortar", "Manter"]:
			var m := chance.search(_f14_botao(painel, prefixo))
			promessas[prefixo] = int(m.get_string(1)) if m != null else -1
			barras[prefixo] = _f14_barra_do_botao(painel, prefixo)
		_confere("F14: reputação %d, a barra do igualar está cheia — ele fecha sempre" % int(reputacao),
			_f14_barra_do_botao(painel, "Igualar") == 100.0,
			str(_f14_barra_do_botao(painel, "Igualar")))
		_f10_fechar(painel)
		for prefixo in ["Cortar", "Manter"]:
			var acao := "metade" if prefixo == "Cortar" else "manter"
			GS._rng.seed = hash([F14_SEMENTE, reputacao, prefixo])
			var aceitou := 0
			for i in F14_AMOSTRA:
				GS.docks[doca]["boat"] = molde.duplicate(true)
				GS.pending_rival_dock = doca
				GS.rival_attempts_left = GS.RIVAL_PATIENCE
				GS.phase = "rival_offer"
				GS.reputation = reputacao
				if GS._negociar(acao) == "fechado":
					aceitou += 1
			var medida := 100.0 * aceitou / F14_AMOSTRA
			_confere("F14: reputação %d, «%s» promete %d%% e o cliente aceitou %.1f%% de %d" % [
				int(reputacao), prefixo, int(promessas[prefixo]), medida, F14_AMOSTRA],
				int(promessas[prefixo]) >= 0 and absf(medida - float(promessas[prefixo])) <= F14_FOLGA)
			# A BARRA É OUTRA PROMESSA, e confere-se contra o mesmo sorteio: o
			# texto certo com a barra na constante de base passaria calado.
			_confere("F14: reputação %d, a barra de «%s» mostra %.1f%% contra %.1f%% medidos" % [
				int(reputacao), prefixo, float(barras[prefixo]), medida],
				float(barras[prefixo]) >= 0.0 and absf(medida - float(barras[prefixo])) <= F14_FOLGA)
	_f14_chance_ok = true


# A barra de chance DENTRO do botão cujo texto começa por `prefixo`, em
# percentagem; −1 se não houver uma, e uma só.
func _f14_barra_do_botao(painel: Node, prefixo: String) -> float:
	var achados: Array = []
	_f10_botoes(painel, prefixo, achados)
	if achados.size() != 1:
		return -1.0
	var barras: Array = []
	for filho in (achados[0] as Button).get_children():
		if filho is ProgressBar and (filho as ProgressBar).is_visible_in_tree():
			barras.append(filho)
	if barras.size() != 1:
		return -1.0
	var barra := barras[0] as ProgressBar
	return 100.0 * barra.value / barra.max_value


# A BARRA DA COBRANÇA é a do HUD: o dinheiro contra a parcela, cheia quando dá
# para pagar. Uma barra que mostrasse a FALTA encheria ao contrário, e o texto
# ao lado continuaria certo.
func _f14_barra_da_parcela(painel: Node, dinheiro: int, parcela: int) -> void:
	var barras: Array = []
	_f14_juntar_barras(painel, barras)
	var ok := barras.size() == 1
	var fracao := -1.0
	if ok:
		var barra := barras[0] as ProgressBar
		fracao = barra.value / barra.max_value
	var esperada := minf(float(dinheiro) / float(parcela), 1.0)
	_confere("F14: a barra da cobrança mostra o dinheiro contra a parcela (%.3f)" % esperada,
		ok and absf(fracao - esperada) < 0.001, "%d barra(s), mostra %.3f" % [barras.size(), fracao])


func _f14_juntar_barras(no: Node, barras: Array) -> void:
	if no is ProgressBar and (no as ProgressBar).is_visible_in_tree():
		barras.append(no)
	for filho in no.get_children():
		_f14_juntar_barras(filho, barras)


# O BOLETIM FECHA AS CONTAS QUE MOSTRA. O total de cada bloco vem do
# `resumo_da_semana()`, que soma as fontes do `GameState`; as linhas por baixo
# vêm da lista que o PAINEL escreve à mão. Uma fonte nova que o jogo somasse e
# o painel não listasse daria um «Entrou» maior do que as suas linhas, sem erro
# nenhum — e o lucro da tarja a não bater com os dois totais.
#
# ⚠️ A SEMANA É MONTADA COM TODAS AS CHAVES DO `SEMANA_ZERADA` DIFERENTES DE
# ZERO, e as chaves saem da tabela do jogo, não de uma lista aqui: numa semana
# jogada a parcela e o pátio costumam ser zero, e linha com zero não entra —
# o painel que esquecesse uma delas passaria nesse estado.
func _f14_boletim() -> void:
	GS.clear_save()
	GS._rng.seed = F10_SEMENTE
	GS.new_game()
	var i := 0
	for chave in GS.SEMANA_ZERADA:
		GS.semana_atual[chave] = 1000 * (i + 3) + 7 * i
		i += 1
	var resumo: Dictionary = GS.resumo_da_semana(1)
	var painel: Node = await _f10_abrir(F11_BOLETIM, [resumo])
	var textos: Array[String] = []
	_f10_textos_visiveis(painel, textos)
	var entrou := textos.find("Entrou")
	var saiu := textos.find("Saiu")
	_confere("F14: o boletim tem os blocos «Entrou» e «Saiu»", entrou >= 0 and saiu > entrou,
		str(textos))
	if entrou < 0 or saiu <= entrou:
		_f10_fechar(painel)
		return
	var total_entrou := _f14_um_valor(textos[entrou + 1])
	var total_saiu := _f14_um_valor(textos[saiu + 1])
	var linhas_entrou := _f14_somar_linhas(textos, entrou + 2, saiu)
	var linhas_saiu := _f14_somar_linhas(textos, saiu + 2, textos.size())
	_confere("F14: «Entrou» (%d) é a soma das %d linhas por baixo" % [total_entrou, linhas_entrou[1]],
		total_entrou == int(linhas_entrou[0]) and total_entrou == int(resumo["receita"]),
		"linhas somam %d, o jogo %d" % [int(linhas_entrou[0]), int(resumo["receita"])])
	_confere("F14: «Saiu» (%d) é a soma das %d linhas por baixo" % [total_saiu, linhas_saiu[1]],
		total_saiu == int(linhas_saiu[0]) and total_saiu == int(resumo["despesa"]),
		"linhas somam %d, o jogo %d" % [int(linhas_saiu[0]), int(resumo["despesa"])])
	var tarja := _f14_reais(textos[linhas_saiu[2]] if linhas_saiu[2] < textos.size() else "")
	_f14_tom_confere(painel, "boletim de prejuízo")
	_confere("F14: a tarja do boletim é «Entrou» menos «Saiu»",
		tarja.size() == 1 and absi(int(tarja[0])) == absi(total_entrou - total_saiu),
		str(tarja))
	_f10_fechar(painel)
	GS.clear_save()
	GS._rng.seed = F10_SEMENTE
	GS.new_game()
	_f14_boletim_ok = true


func _f14_um_valor(texto: String) -> int:
	var v := _f14_reais(texto)
	return int(v[0]) if v.size() == 1 else -1


# Soma os pares «rótulo, R$…» a partir de `de`, até `ate` ou até ao primeiro
# texto que não é um par — o próximo bloco, ou a tarja, que traz o seu R$ no
# meio da frase. Devolve [soma, linhas, onde parou].
func _f14_somar_linhas(textos: Array[String], de: int, ate: int) -> Array:
	var so_valor := RegEx.new()
	so_valor.compile("^R\\$[0-9.]+$")
	var soma := 0
	var linhas := 0
	var k := de
	while k + 1 < ate and not textos[k].contains("R$") and so_valor.search(textos[k + 1]) != null:
		soma += _f14_um_valor(textos[k + 1])
		linhas += 1
		k += 2
	return [soma, linhas, k]


# O TOM DA TARJA CONTRA A PALAVRA DELA (quinta passagem, `063`). O tom sai
# do código do painel; a palavra, da `Narrativa` e dos textos que o painel
# monta — duas escritas, e um tom invertido passaria calado por toda régua de
# contraste, porque verde e vermelho medem os dois acima de 5:1 no creme.
# A tabela é do que o JOGADOR lê, e uma tarja com uma frase que ela não
# conhece reprova: tarja nova escolhe o seu tom aqui também.
const F14_TOM_DA_PALAVRA := {
	"Lucro": &"TarjaNarrativaBoa",
	"Depois de pagar": &"TarjaNarrativaBoa",
	"Parcela quitada": &"TarjaNarrativaBoa",
	"Negócio fechado": &"TarjaNarrativaBoa",
	"Prejuízo": &"TarjaNarrativaRuim",
	"Faltam": &"TarjaNarrativaRuim",
	"Parcela não paga": &"TarjaNarrativaRuim",
	"Negócio perdido": &"TarjaNarrativaRuim",
	"Valor original": &"TarjaNarrativa",
	# Os painéis do HUD (`065`): previsões e estados, nunca resultados.
	"A receber": &"TarjaNarrativa",
	"Nenhuma doca": &"TarjaNarrativa",
	"Nenhum barco": &"TarjaNarrativa",
	"Quitar hoje": &"TarjaNarrativa",
	"Dia ": &"TarjaNarrativa",
	# Os motivos do fim, escritos pelo `GameState._check_end()` e pelo
	# `fail_debt()` — o balanço abre com o que o jogo escreveu, não com isto.
	"Você quitou": &"TarjaNarrativaBoa",
	"O dinheiro acabou": &"TarjaNarrativaRuim",
	"Prazo encerrado": &"TarjaNarrativaRuim",
	"Não foi possível pagar": &"TarjaNarrativaRuim",
}
const F14_ROTULO_DO_TOM := {
	&"TarjaNarrativaBoa": &"RotuloTotalBom",
	&"TarjaNarrativaRuim": &"RotuloTotalRuim",
	&"TarjaNarrativa": &"RotuloTotal",
}


func _f14_tom_confere(painel: Node, caso: String) -> void:
	var tarjas: Array = []
	_f14_juntar_tarjas(painel, tarjas)
	_confere("F14: %s — há uma tarja" % caso, tarjas.size() == 1, "%d tarjas" % tarjas.size())
	if tarjas.size() != 1:
		return
	var tarja := tarjas[0] as PanelContainer
	var principal := tarja.get_node("Linhas/Principal") as Label
	var esperado: StringName = &""
	for palavra in F14_TOM_DA_PALAVRA:
		if principal.text.begins_with(palavra):
			esperado = F14_TOM_DA_PALAVRA[palavra]
	_confere("F14: %s — a tarja veste o tom da palavra («%s»)" % [caso, principal.text],
		esperado != &"" and tarja.theme_type_variation == esperado
			and principal.theme_type_variation == F14_ROTULO_DO_TOM[esperado],
		"veste %s / %s, esperado %s" % [tarja.theme_type_variation,
			principal.theme_type_variation, esperado])


func _f14_juntar_tarjas(no: Node, tarjas: Array) -> void:
	if no is PanelContainer and String((no as PanelContainer).theme_type_variation).begins_with("TarjaNarrativa") \
			and (no as Control).is_visible_in_tree() and not no.is_queued_for_deletion():
		tarjas.append(no)
	for filho in no.get_children():
		_f14_juntar_tarjas(filho, tarjas)


# O BALANÇO, pelos dois lados do fim. O motivo sai do `_check_end()` do jogo
# — dinheiro abaixo de zero, e o prazo acabado com a parcela paga —, e o
# painel abre com o `won` e o `end_reason` que ele deixou. Quem venceu passa
# pela narração e chega ao balanço pelo botão dela, como a jogar.
func _f14_balanco() -> void:
	for venceu in [false, true]:
		_f10_partida_nova("F14")
		if venceu:
			GS.parcela_paid = true
			GS.turn = int(GS.TURNS_TOTAL) + 1
		else:
			GS.cash = -1
		GS._check_end()
		_confere("F14: o jogo acabou %s" % ("vencido" if venceu else "perdido"),
			GS.phase == "game_over" and bool(GS.won) == venceu, "fase %s" % GS.phase)
		var painel: Node = await _f10_abrir(F10_FIM, [bool(GS.won), String(GS.end_reason)])
		if venceu and not await _f10_tocar(painel, "Ver o balanço", "F14"):
			_f10_fechar(painel)
			return
		_f14_tom_confere(painel, "balanço de quem %s" % ("venceu" if venceu else "perdeu"))
		_f10_fechar(painel)
	GS.clear_save()
	GS._rng.seed = F10_SEMENTE
	GS.new_game()
	_f14_balanco_ok = true


# ══ F15 — O QUE OS PAINÉIS DO HUD PROMETEM É O QUE O JOGO FAZ (`065`) ══════
#
# A irmã do F14 para a segunda família da frente 3 — dinheiro do dia, docas,
# reputação, parcela e calendário. Cada número que um destes painéis mostra lê-se
# na TELA e confere-se contra uma segunda fonte que o painel não usa:
#
#   - DOCAS: o que cada doca «vai pagar» contra o dinheiro que entra quando o
#     barco acaba, com o armazém e o pátio construídos — sem eles o bónus é
#     zero e a conta certa e a que o esquece dão o mesmo número (a regra do
#     modificador ativo, `CLAUDE.md`). E a perda prometida da doca sem
#     trabalhador contra o que o MESMO barco paga quando tem gente.
#   - RECORDES: contra um OBSERVADOR que joga a partida e mede cada dia pela
#     variação do dinheiro, cada dia de barcos pela das `metrics`, e cada semana
#     pela soma dos seus dias — nenhuma das três passa pelo `_recordes`.
#   - O DIA 32: o único dia que muda DEPOIS de virar (o `pay_debt()` escreve a
#     parcela no `dia_anterior`), e por isso o que separa gravar o recorde na
#     virada de gravá-lo uma virada depois. Um barco grande nesse dia põe-no
#     como o melhor da partida com a parcela e sem ela, e só o valor distingue.
#   - REPUTAÇÃO: o «faltam X para Y» contra o `reputation_label()` a X de
#     distância.
#   - PARCELA: o «Quitar hoje» contra o que o botão tira do dinheiro, e a
#     linha de apoio contra a constante da parcela cheia.
#
# ⚠️ E CADA CAMINHO LEVA A SUA BANDEIRA (`054`).
const F15_DOCAS := "res://scenes/panels/PainelDocas.tscn"
const F15_CAIXA := "res://scenes/panels/PainelCaixa.tscn"
const F15_REPUTACAO := "res://scenes/panels/PainelReputacao.tscn"
const F15_CALENDARIO := "res://scenes/panels/PainelCalendario.tscn"
const F15_PARCELA := "res://scenes/panels/PainelParcela.tscn"
# Quantos dias o observador joga: três semanas fechadas, para a melhor semana
# ter por onde escolher.
const F15_DIAS := 25

var _f15_terminou := false
var _f15_docas_ok := false
var _f15_recordes_ok := false
var _f15_dia32_ok := false
var _f15_reputacao_ok := false
var _f15_parcela_ok := false
var _f15_calendario_ok := false


func _f15_promessa_do_hud() -> void:
	await _f15_docas()
	_confere("F15: o caminho das docas correu até ao fim", _f15_docas_ok)
	await _f15_recordes()
	_confere("F15: o caminho dos recordes correu até ao fim", _f15_recordes_ok)
	await _f15_dia32()
	_confere("F15: o caminho do dia 32 correu até ao fim", _f15_dia32_ok)
	await _f15_reputacao()
	_confere("F15: o caminho da reputação correu até ao fim", _f15_reputacao_ok)
	await _f15_parcela()
	_confere("F15: o caminho da parcela correu até ao fim", _f15_parcela_ok)
	await _f15_calendario()
	_confere("F15: o caminho do calendário correu até ao fim", _f15_calendario_ok)
	GS.clear_save()
	GS._rng.seed = F10_SEMENTE
	GS.new_game()
	_f15_terminou = true


# O porto inteiro, comprado pela porta do jogo: várias voltas, porque há
# estruturas que pedem outras antes. Devolve se o armazém e o pátio — os dois
# que pagam bónus — ficaram de pé.
func _f15_porto_completo() -> bool:
	_f10_partida_nova("F15")
	if GS.phase == "rival_offer":
		GS.resolve_rival_offer(true)
	GS.cash = 50000000
	for _volta in range(GS.ESTRUTURAS.size()):
		for id in GS.ESTRUTURAS:
			if not GS.tem_estrutura(String(id)):
				GS.comprar_estrutura(String(id))
	var ok: bool = GS.tem_estrutura("armazem") and GS.tem_estrutura("patio") \
		and GS.docks.size() == int(GS.BERCOS_NO_MAPA)
	_confere("F15: o porto completo tem armazém, pátio e as %d docas" % int(GS.BERCOS_NO_MAPA),
		ok, "estruturas %s, %d docas" % [str(GS.estruturas), GS.docks.size()])
	return ok


func _f15_barco(motivo: String, valor: int, fechado: int = 0) -> Dictionary:
	return {"id": 9000 + valor % 997, "value": valor, "classe": "medio",
		"motivo": motivo, "op_turns": 1, "progress": 0, "rival": false,
		"matched": fechado > 0, "matched_value": fechado}


# O quadro de uma doca pelo NOME do nó (`Doca<n>`), e o valor dele.
func _f15_valor_da_doca(painel: Node, n: int) -> int:
	var bloco := painel.find_child("Doca%d" % n, true, false)
	if bloco == null:
		return -1
	var valor := bloco.find_child("Valor", true, false) as Label
	return _f14_um_valor(valor.text) if valor != null else -1


# UM BARCO DE CADA VEZ, com as outras docas vazias: assim o dinheiro que entra
# na virada é o dele e de mais ninguém. O dia 2 não fecha semana nem vence
# parcela, e é por isso que se escreve.
func _f15_docas() -> void:
	if not _f15_porto_completo():
		return
	var casos := [
		["armazenagem com o armazém", _f15_barco("armazenagem", 77777), true],
		["contêiner com o pátio", _f15_barco("conteiner", 66667), true],
		["pescado, sem bónus", _f15_barco("pescado", 12345), true],
		["preço fechado com o rival", _f15_barco("armazenagem", 90000, 55555), true],
		["sem trabalhador", _f15_barco("armazenagem", 77777), false],
	]
	var pago_com_gente := -1
	for caso in casos:
		var nome: String = caso[0]
		GS.turn = 2
		GS._set_phase("playing")
		for doca in GS.docks:
			doca["boat"] = null
			doca["worker_id"] = null
		for w in GS.workers:
			w["busy_turns"] = 0
		GS.docks[1]["boat"] = (caso[1] as Dictionary).duplicate()
		var com_gente: bool = caso[2]
		if com_gente and not GS.assign_worker(int(GS.workers[0]["id"]), 1, false):
			_confere("F15 docas, %s: o trabalhador entra na doca" % nome, false)
			return
		var painel: Node = await _f10_abrir(F15_DOCAS, [])
		var prometido := _f15_valor_da_doca(painel, 2)
		var principal := _f14_texto(painel, "A receber" if com_gente else "Nenhuma doca")
		var perda := _f14_texto(painel, "Perde")
		_f14_tom_confere(painel, "docas, %s" % nome)
		_f10_fechar(painel)
		var antes: int = GS.cash
		var perdidos: int = int(GS.metrics["boats_lost"])
		var id_barco: int = int(GS.docks[1]["boat"]["id"])
		GS.advance_turn()
		var pago: int = GS.cash - antes
		# A doca pode já ter barco NOVO: o `_spawn_boats()` corre na virada.
		var saiu: bool = GS.docks[1]["boat"] == null or int(GS.docks[1]["boat"]["id"]) != id_barco
		if com_gente:
			_confere("F15 docas, %s: o quadro promete %s e o jogo paga %s" % [nome,
				GS.moeda(prometido), GS.moeda(pago)], prometido == pago and pago > 0)
			_confere("F15 docas, %s: a tarja soma o mesmo" % nome,
				_f14_um_valor(principal) == pago, principal)
			if nome.begins_with("armazenagem"):
				pago_com_gente = pago
		else:
			_confere("F15 docas, %s: o barco sai perdido sem pagar nada" % nome,
				pago == 0 and saiu and int(GS.metrics["boats_lost"]) == perdidos + 1,
				"pagou %d, saiu %s" % [pago, str(saiu)])
			_confere("F15 docas, %s: a perda prometida (%s) é o que o MESMO barco paga com gente (%s)"
				% [nome, perda, GS.moeda(pago_com_gente)],
				_f14_reais(perda).size() == 1 and int(_f14_reais(perda)[0]) == pago_com_gente)

	# ⚠️ UMA COM GENTE E OUTRA SEM, ao mesmo tempo. É o único estado em que
	# somar a doca parada ao «a receber» diverge de não a somar: com um barco
	# só, ou ele tem gente e não há perda, ou não tem e a tarja é outra.
	GS.turn = 2
	GS._set_phase("playing")
	for doca in GS.docks:
		doca["boat"] = null
		doca["worker_id"] = null
	for w in GS.workers:
		w["busy_turns"] = 0
	GS.docks[0]["boat"] = _f15_barco("armazenagem", 77777)
	GS.docks[2]["boat"] = _f15_barco("pescado", 23456)
	GS.assign_worker(int(GS.workers[0]["id"]), 0, false)
	var misto: Node = await _f10_abrir(F15_DOCAS, [])
	var recebe := _f14_um_valor(_f14_texto(misto, "A receber"))
	var perde := _f14_reais(_f14_texto(misto, "Perde"))
	_f10_fechar(misto)
	var antes_misto: int = GS.cash
	GS.advance_turn()
	_confere("F15 docas, uma com gente e outra sem: a tarja (%s) é só o que entra (%s)"
		% [GS.moeda(recebe), GS.moeda(GS.cash - antes_misto)], recebe == GS.cash - antes_misto)
	_confere("F15 docas, uma com gente e outra sem: a perda é a da parada (%s)" % str(perde),
		perde.size() == 1 and int(perde[0]) == 23456)
	_f15_docas_ok = true


# O quadro de um recorde pelo rótulo dele: devolve [número, detalhe].
func _f15_quadro(painel: Node, rotulo: String) -> Array:
	var achados: Array = []
	_f15_juntar_quadros(painel, rotulo, achados)
	if achados.size() != 1:
		return ["", ""]
	var coluna: Node = (achados[0] as Node).get_child(0)
	var numero: String = (coluna.get_child(1) as Label).text
	var detalhe: String = (coluna.get_child(2) as Label).text if coluna.get_child_count() > 2 else ""
	return [numero, detalhe]


func _f15_juntar_quadros(no: Node, rotulo: String, achados: Array) -> void:
	if no is PanelContainer and (no as PanelContainer).theme_type_variation == &"BlocoNumero" \
			and no.get_child_count() > 0 and no.get_child(0).get_child_count() > 1 \
			and no.get_child(0).get_child(0) is Label \
			and (no.get_child(0).get_child(0) as Label).text == rotulo:
		achados.append(no)
	for filho in no.get_children():
		_f15_juntar_quadros(filho, rotulo, achados)


# O OBSERVADOR joga como os perfis do simulador — resolve a oferta, aloca quem
# está livre, avança — e mede cada dia pela variação do DINHEIRO. Nada é
# comprado durante o laço, então a variação é o resultado do dia inteiro.
func _f15_recordes() -> void:
	if not _f15_porto_completo():
		return
	var vazio: Node = await _f10_abrir(F15_CAIXA, [GS.resumo_do_dia()])
	for r in ["Melhor dia", "Mais barcos num dia", "Maior negócio", "Melhor semana"]:
		_confere("F15 recordes: na partida nova «%s» mostra «—»" % r,
			String(_f15_quadro(vazio, r)[0]) == "—", str(_f15_quadro(vazio, r)))
	_f10_fechar(vazio)

	var melhor_dia := [0, 0]
	var mais_barcos := [0, 0]
	var maior := [0, 0, ""]
	var semanas: Array = []
	for _i in range(F15_DIAS):
		if GS.phase == "rival_offer":
			GS.resolve_rival_offer(true)
		if GS.phase != "playing":
			break
		GS.assign_all_free_workers()
		var dia: int = GS.turn
		for i in range(GS.docks.size()):
			var doca: Dictionary = GS.docks[i]
			if doca["boat"] == null or doca["worker_id"] == null:
				continue
			if int(doca["boat"]["progress"]) + 1 < int(doca["boat"]["op_turns"]):
				continue
			var paga: int = GS.receita_da_doca(i)
			if int(maior[1]) == 0 or paga > int(maior[0]):
				maior = [paga, dia, String(doca["boat"]["motivo"])]
		var antes: int = GS.cash
		var servidos: int = int(GS.metrics["boats_served"])
		GS.advance_turn()
		var resultado: int = GS.cash - antes
		var n: int = int(GS.metrics["boats_served"]) - servidos
		if int(melhor_dia[1]) == 0 or resultado > int(melhor_dia[0]):
			melhor_dia = [resultado, dia]
		if n > int(mais_barcos[0]):
			mais_barcos = [n, dia]
		var semana: int = (dia - 1) / int(GS.TURNS_PER_WEEK)
		while semanas.size() <= semana:
			semanas.append(0)
		semanas[semana] += resultado
	if GS.phase == "rival_offer":
		GS.resolve_rival_offer(true)
	var fechadas := (int(GS.turn) - 1) / int(GS.TURNS_PER_WEEK)
	var melhor_semana := [0, 0]
	for s in range(fechadas):
		if int(melhor_semana[1]) == 0 or int(semanas[s]) > int(melhor_semana[0]):
			melhor_semana = [int(semanas[s]), s + 1]
	_confere("F15 recordes: o observador jogou %d dias e fechou %d semanas" % [
		int(GS.turn) - 1, fechadas], fechadas >= 2 and int(maior[1]) > 0,
		"turno %d, fase %s" % [int(GS.turn), GS.phase])

	var painel: Node = await _f10_abrir(F15_CAIXA, [GS.resumo_do_dia()])
	var esperado := {
		"Melhor dia": [GS.moeda(int(melhor_dia[0])), "dia %d" % int(melhor_dia[1])],
		"Mais barcos num dia": [str(int(mais_barcos[0])), "dia %d" % int(mais_barcos[1])],
		"Maior negócio": [GS.moeda(int(maior[0])), "%s · dia %d" % [
			String(GS.MOTIVOS[String(maior[2])]["nome"]), int(maior[1])]],
		"Melhor semana": [GS.moeda(int(melhor_semana[0])), "semana %d" % int(melhor_semana[1])],
	}
	for r in esperado:
		var visto := _f15_quadro(painel, r)
		_confere("F15 recordes: «%s» mostra %s, e o observador mediu %s" % [r, str(visto), str(esperado[r])],
			String(visto[0]) == String(esperado[r][0]) and String(visto[1]) == String(esperado[r][1]))
	_f10_fechar(painel)

	# E OS RECORDES ATRAVESSAM O SAVE: são estado da partida, e o painel
	# depois de reabrir o jogo tem de dizer o mesmo.
	var antes_do_save := str(GS.recordes())
	GS.save_game()
	var carregou: bool = GS.load_game()
	_confere("F15 recordes: o save guarda-os e devolve-os iguais", carregou
		and str(GS.recordes()) == antes_do_save, "%s → %s" % [antes_do_save, str(GS.recordes())])
	_f15_recordes_ok = true


# O DIA 32 COM UM BARCO GRANDE: o melhor dia da partida com a parcela ou sem
# ela, e só o VALOR separa as duas leituras.
func _f15_dia32() -> void:
	_f10_partida_nova("F15")
	var voltas := 0
	while int(GS.turn) < int(GS.PARCELA_DUE_TURN) and voltas < 200:
		if GS.phase == "rival_offer":
			GS.resolve_rival_offer(true)
		GS.assign_all_free_workers()
		GS.advance_turn()
		voltas += 1
	if GS.phase == "rival_offer":
		GS.resolve_rival_offer(true)
	_confere("F15 dia 32: a partida chega ao dia do vencimento a jogar",
		int(GS.turn) == int(GS.PARCELA_DUE_TURN) and GS.phase == "playing",
		"turno %d, fase %s" % [int(GS.turn), GS.phase])
	if GS.phase != "playing":
		return
	GS.docks[0]["boat"] = _f15_barco("pescado", 4000000)
	GS.docks[0]["worker_id"] = null
	for w in GS.workers:
		w["busy_turns"] = 0
	GS.assign_worker(int(GS.workers[0]["id"]), 0, false)
	var antes: int = GS.cash
	GS.advance_turn()
	_confere("F15 dia 32: o dia vira para a cobrança", GS.phase == "debt_payment", GS.phase)
	GS.pay_debt()
	var resultado: int = GS.cash - antes
	var r: Dictionary = GS.recordes()
	_confere("F15 dia 32: o melhor dia é o 32, com a parcela dentro (%s), e o recorde diz %s do dia %d"
		% [GS.moeda(resultado), GS.moeda(int(r["melhor_dia"]["valor"])), int(r["melhor_dia"]["turno"])],
		int(r["melhor_dia"]["turno"]) == int(GS.PARCELA_DUE_TURN)
			and int(r["melhor_dia"]["valor"]) == resultado)
	_f15_dia32_ok = true


func _f15_reputacao() -> void:
	_f10_partida_nova("F15")
	for rep in [76.6, 20.95, 64.3, 81.0, 100.0]:
		GS.reputation = rep
		var painel: Node = await _f10_abrir(F15_REPUTACAO, [])
		var bloco := painel.find_child("Comercial", true, false)
		var valor := (bloco.find_child("Valor", true, false) as Label).text if bloco else ""
		var barra := bloco.find_child("Barra", true, false) as ProgressBar if bloco else null
		var proximo := (bloco.find_child("Proximo", true, false) as Label).text if bloco else ""
		_confere("F15 reputação %.2f: o quadro diz o patamar do jogo («%s»)" % [rep, valor],
			valor.ends_with("— " + String(GS.reputation_label())))
		_confere("F15 reputação %.2f: a barra está no número do jogo" % rep,
			barra != null and is_equal_approx(barra.value, rep) and is_equal_approx(barra.max_value, 100.0))
		var re := RegEx.new()
		re.compile("^Faltam (\\d+,\\d) para (.+)\\.$")
		var m := re.search(proximo)
		if String(GS.reputation_label()) == "Referência":
			_confere("F15 reputação %.2f: no topo não promete degrau («%s»)" % [rep, proximo],
				m == null and proximo == "O topo da escada.")
		else:
			var falta := float(m.get_string(1).replace(",", ".")) if m else -1.0
			var nome := m.get_string(2) if m else ""
			var aqui: String = GS.reputation_label()
			GS.reputation = rep + falta + 0.05
			var la: String = GS.reputation_label()
			GS.reputation = rep + falta - 0.051
			var quase: String = GS.reputation_label()
			GS.reputation = rep
			_confere("F15 reputação %.2f: «%s» — a %s chega-se a %s, e um pouco antes ainda não"
				% [rep, proximo, str(falta), la], m != null and la == nome and quase == aqui)
		_f10_fechar(painel)
	_f15_reputacao_ok = true


func _f15_parcela() -> void:
	_f10_partida_nova("F15")
	if GS.phase == "rival_offer":
		GS.resolve_rival_offer(true)
	GS.turn = 8
	GS.cash = 900001
	var painel: Node = await _f10_abrir(F15_PARCELA, [])
	var tarja := _f14_texto(painel, "Quitar hoje")
	var apoio := _f14_reais(_f14_texto(painel, "Cheia são"))
	var hoje := _f14_um_valor(tarja)
	_f14_tom_confere(painel, "parcela por quitar")
	_confere("F15 parcela: a linha de apoio é a cheia menos o abatimento (%s)" % str(apoio),
		apoio.size() == 2 and int(apoio[0]) == int(GS.PARCELA_AMOUNT)
			and int(apoio[0]) - int(apoio[1]) == hoje)
	var barra := painel.find_child("Barra", true, false) as ProgressBar
	_confere("F15 parcela: a barra mede o dinheiro contra o valor de hoje",
		barra != null and int(barra.max_value) == hoje and int(barra.value) == mini(int(GS.cash), hoje))
	var antes: int = GS.cash
	if not await _f10_tocar(painel, "Quitar agora", "F15"):
		_f10_fechar(painel)
		return
	_confere("F15 parcela: a tarja promete %s e o botão tira %s" % [GS.moeda(hoje), GS.moeda(antes - GS.cash)],
		hoje > 0 and antes - int(GS.cash) == hoje and GS.parcela_paid)
	if is_instance_valid(painel) and painel.is_inside_tree():
		_f10_fechar(painel)
	var paga: Node = await _f10_abrir(F15_PARCELA, [])
	_f14_tom_confere(paga, "parcela quitada")
	_f10_fechar(paga)
	_f15_parcela_ok = true


func _f15_calendario() -> void:
	_f10_partida_nova("F15")
	GS.turn = 10
	var painel: Node = await _f10_abrir(F15_CALENDARIO, [])
	var tarja := _f14_texto(painel, "Dia ")
	var apoio := _f14_texto(painel, "Semana ")
	_f14_tom_confere(painel, "calendário")
	_confere("F15 calendário: «%s» / «%s» são o dia e a semana do jogo" % [tarja, apoio],
		tarja == "Dia %d de %d" % [int(GS.turn), int(GS.TURNS_TOTAL)]
			and apoio.begins_with("Semana %d de %d" % [GS.current_week(), int(GS.WEEKS_TOTAL)]))
	_f10_fechar(painel)
	_f15_calendario_ok = true
