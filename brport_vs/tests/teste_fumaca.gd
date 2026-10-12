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
#    mapa que desenha 3**. A regra escrita no `CLAUDE.md` era absoluta: save de
#    outra versão é DESCARTADO, nunca adaptado. Um save recusado que já mexeu
#    no estado vivo é adaptação a meio com outro nome. Desde a `098` o save de
#    uma versão antiga sobe por uma cadeia de degraus escritos por quem mudou a
#    forma (F21); o que nenhum degrau lê continua descartado (F3).
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

	print("=== F3: save que a cadeia de migração não lê é descartado, sem ter tocado em nada ===")
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

	print("=== F2b: o ícone de cada cabeçalho lê-se no selo ===")
	_f2b_icones_no_selo()
	_confere("o bloco F2b correu até ao fim", _f2b_terminou)

	print("=== F13: ferramenta e suíte nunca escrevem onde o jogador guarda ===")
	_f13_o_armazem_do_jogador()
	_confere("o bloco F13 correu até ao fim", _f13_terminou)

	print("=== F14: o que a cobrança e a contra-oferta prometem antes da escolha é o que o jogo faz depois ===")
	await _f14_promessa_e_resultado()
	_confere("o bloco F14 correu até ao fim", _f14_terminou)

	print("=== F15: o que os painéis do HUD prometem é o que o jogo faz ===")
	await _f15_promessa_do_hud()
	_confere("o bloco F15 correu até ao fim", _f15_terminou)

	print("=== F16: três espaços de save, e só se apaga um porto com dois toques ===")
	_f16_os_espacos_de_save()
	_confere("o bloco F16 correu até ao fim", _f16_terminou)

	print("=== F17: a conversa do celular — cada aviso com o seu ícone, cada fala com a sua cara ===")
	_f17_a_conversa()
	_confere("o bloco F17 correu até ao fim", _f17_terminou)

	print("=== F18: o prazo que o Construir e a mensagem prometem é o que a obra cumpre ===")
	await _f18_a_obra_prometida()
	_confere("o bloco F18 correu até ao fim", _f18_terminou)

	print("=== F19: todo nome que as suítes e as ferramentas leem por string existe no alvo ===")
	_f19_nomes_lidos_por_string()
	_confere("o bloco F19 correu até ao fim", _f19_terminou)

	print("=== F20: a tabela das fases tem os campos todos, e o que ela afirma é o que o jogo faz ===")
	_f20_a_tabela_das_fases()
	_confere("o bloco F20 correu até ao fim", _f20_terminou)

	print("=== F21: um save de exemplo por versão, e a cadeia de migração leva cada um à corrente ===")
	_f21_a_migracao()
	_confere("o bloco F21 correu até ao fim", _f21_terminou)

	print("=== F22: o tutorial do Toninho fala quando o recorte diz, e mais nenhuma vez ===")
	await _f22_o_tutorial()
	_confere("o bloco F22 correu até ao fim", _f22_terminou)

	print("=== F23: a Fase 2 abre na tela, e os estados do turno são constantes (M9) ===")
	await _f23_a_fase_2()
	_confere("o bloco F23 correu até ao fim", _f23_terminou)

	if _falhas == 0:
		print("\n=== FUMACA OK — as cenas abrem, os ícones existem, o save migra só o que sabe ler, o texto resolve, o export vale ===")
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
	# Abaixo do PISO, e não «a anterior»: desde a `098` a anterior à corrente
	# sobe pela cadeia, e o que nenhum degrau lê começa no piso − 1.
	var abaixo: int = GS.SAVE_VERSAO_MINIMA - 1

	_confere("um save recusado não deixa arquivo para trás (versão %d, abaixo do piso)" % abaixo,
		_recusa_e_apaga(_save_valido(abaixo)))
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

	# A FILA (`083`) é forma nova do estado, e o `_save_aceite` recusa-a por
	# cinco portas — nenhuma das quais o resto do bloco abria: todos os saves
	# acima têm a fila VAZIA e a oferta a -1. Uma por caso, como os rostos do
	# F12, e cada uma sem ter tocado no turno vivo.
	var barco := {"classe": "pesqueiro", "motivo": "pescado", "value": 9000,
		"paciencia": 2}
	var filas_mas := {
		"sem a fila": [null, -1],
		"fila que não é lista": [{"0": barco}, -1],
		"mais barcos do que lugares": [[barco, barco, barco, barco], -1],
		"barco sem paciência": [[{"classe": "pesqueiro", "value": 9000}], -1],
		"paciência em texto": [[{"classe": "pesqueiro", "paciencia": "2"}], -1],
		"oferta fora da fila": [[barco], 1],
		"oferta abaixo de -1": [[barco], -2],
	}
	for caso in filas_mas:
		var dados := _save_valido(versao)
		if filas_mas[caso][0] == null:
			dados.erase("fila")
		else:
			dados["fila"] = filas_mas[caso][0]
		dados["pending_rival"] = filas_mas[caso][1]
		_escrever(dados)
		GS.turn = 4321
		var carregou_fila: bool = GS.load_game()
		_confere("save com %s é recusado, e sem ter tocado em nada" % caso,
			not carregou_fila and GS.turn == 4321,
			"carregou=%s turn=%d" % [carregou_fila, GS.turn])
	# E os dois que têm de entrar — sem eles os sete acima passariam por um
	# `load_game()` que recusa toda fila com barco.
	for oferta in [-1, 0]:
		var boa := _save_valido(versao)
		boa["fila"] = [barco.duplicate(), barco.duplicate()]
		boa["pending_rival"] = oferta
		_escrever(boa)
		_confere("o save com dois barcos ao largo e oferta %d entra" % oferta,
			GS.load_game() and GS.fila.size() == 2 and GS.pending_rival == oferta)

	# A SEGUNDA CHANCE (`102`) é forma nova do estado, e entra pelas mesmas
	# portas: tipo antes de valor, e a dívida só onde o jogo a deixa — depois
	# de usada, a partir da segunda cobrança e com o boleto por pagar.
	var chances_mas := {
		"sem a dívida da segunda chance": {"emprestimo_devido": null},
		"sem a chance": {"segunda_chance_usada": null},
		"dívida em texto": {"emprestimo_devido": "1000"},
		"dívida negativa": {"emprestimo_devido": -1},
		"dívida fracionária": {"emprestimo_devido": 10.5},
		"chance em texto": {"segunda_chance_usada": "false"},
		"dívida sem a chance usada": {"emprestimo_devido": 1000, "parcela_indice": 1,
			"parcelas_quitadas": 1},
		"dívida na primeira cobrança": {"emprestimo_devido": 1000,
			"segunda_chance_usada": true},
		"dívida com o boleto já pago": {"emprestimo_devido": 1000,
			"segunda_chance_usada": true, "parcela_indice": 1, "parcelas_quitadas": 2,
			"parcela_paid": true},
	}
	for caso in chances_mas:
		var dados := _save_valido(versao)
		for chave in chances_mas[caso]:
			if chances_mas[caso][chave] == null:
				dados.erase(chave)
			else:
				dados[chave] = chances_mas[caso][chave]
		_escrever(dados)
		GS.turn = 4321
		var carregou_chance: bool = GS.load_game()
		_confere("save com %s é recusado, e sem ter tocado em nada" % caso,
			not carregou_chance and GS.turn == 4321,
			"carregou=%s turn=%d" % [carregou_chance, GS.turn])
	# E as duas que têm de entrar, senão as de cima passariam por um
	# `load_game()` que recusa toda segunda chance.
	var chances_boas := {
		"a chance gasta e já paga": {"segunda_chance_usada": true, "parcela_indice": 1,
			"parcelas_quitadas": 1},
		"a dívida por pagar na segunda cobrança": {"emprestimo_devido": 156800,
			"segunda_chance_usada": true, "parcela_indice": 1, "parcelas_quitadas": 1},
	}
	for caso in chances_boas:
		var boa := _save_valido(versao)
		for chave in chances_boas[caso]:
			boa[chave] = chances_boas[caso][chave]
		_escrever(boa)
		_confere("o save com %s entra, com a dívida e a chance" % caso,
			GS.load_game() and GS.segunda_chance_usada
				and GS.emprestimo_devido == int(boa["emprestimo_devido"]))
	GS.clear_save()


func _novo_jogo() -> void:
	GS.new_game()
	if GS.phase == "rival_offer":
		GS.resolve_rival_offer(true)


# Um save com a forma toda certa, parametrizado só pela versão. Serve de base
# para cada defeito ser injetado um de cada vez. A forma é a da CORRENTE (a 16,
# com a fase e sem o legado, `104`); as versões de baixo usam-na só para serem
# recusadas pela versão.
func _save_valido(versao: int) -> Dictionary:
	return {
		"versao": versao, "turn": 5, "cash": 1234, "reputation": 70.0,
		"docks": [{"boat": null, "worker_id": null}],
		"workers": [{"id": 1, "busy_turns": 0, "rosto": 0}],
		"numero_da_fase": 1,
		"estruturas": [], "obra_em_andamento": {}, "parcela_paid": false,
		"parcela_indice": 0, "parcelas_quitadas": 0, "total_pago_parcelas": 0,
		"emprestimo_devido": 0, "segunda_chance_usada": false,
		"phase": "playing", "fila": [], "pending_rival": -1, "rival_attempts_left": 2,
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
	# lugar, mesmo que o resolvedor o troque por `valor_da_parcela(0)` num
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
	_confere("o total contratado acompanha as três parcelas, sem usar o principal recebido",
		GS.texto("{totalParcelas}") == GS.moeda(GS.valor_da_parcela(0) + GS.valor_da_parcela(1) + GS.valor_da_parcela(2)))

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
		"Sr. Ribeiro (a dívida)": Narrativa.ribeiro_a_divida(GS.valor_da_parcela(0)),
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
# A SEGUNDA FONTE é o `NarradoraDaCida.gd`: a tabela vive na Narrativa e o
# gatilho na narradora, então comparar os dois não é um espelho. Lê-se o
# ARQUIVO e não o objeto, porque montá-lo para isto custaria a cena inteira.
# Até ao segundo corte do M8 (`096`) o gatilho vivia no `Main.gd`, e era esse
# o arquivo lido: com ele, as falas todas dariam por mudas — vermelho alto, e
# não um verde de graça.
#
# E as linhas de COMENTÁRIO saem antes da busca: este mesmo bloco nomeia as
# duas falas na prosa acima, e sem o corte elas contar-se-iam a si próprias —
# que é a regra do `contains()` do CLAUDE.md a morder de novo.
func _f4_toda_fala_chega_ao_jogo() -> void:
	var fonte := FileAccess.get_file_as_string("res://scripts/NarradoraDaCida.gd")
	_confere("a NarradoraDaCida.gd foi lida", fonte != "")
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
# continua provada, porque o esperado sai de `por_extenso(GS.semanas_da_fase())` —
# mexer na constante move os dois lados, mas mexer no TEXTO à mão reprova.
func _f4_numeros_do_fim() -> void:
	var texto: String = Narrativa.fim_de_fase()
	var semanas: String = Narrativa.por_extenso(GS.semanas_da_fase())
	_confere("o fim de fase diz as %s semanas que o jogo tem" % semanas,
		texto.to_lower().begins_with("%s semanas" % semanas),
		"começa com: " + texto.left(30))
	# E O ARCO: a Fase 1 do GDD tem três parcelas e o VS paga a primeira. O
	# esperado sai da CONSTANTE, então mexer nela move os dois lados — e mexer
	# no TEXTO à mão reprova, que é o ponto.
	var total: String = Narrativa.por_extenso(GS.parcelas_na_fase())
	_confere("e que as %s parcelas terminaram" % total,
		texto.to_lower().contains("as %s parcelas ficaram para trás" % total),
		"não achou em: " + texto.left(60))
	_confere("e que essa dívida não resta",
		texto.contains("Essa, não."),
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
	GS.fila = [GS._make_boat()]
	GS.pending_rival = 0
	GS.rival_attempts_left = GS.RIVAL_PATIENCE
	GS._set_phase("rival_offer")
	_confere("a montagem deixou o jogo em rival_offer com barco ao largo",
		GS.phase == "rival_offer" and GS.barco_da_oferta() != null)

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
		# O quarto desde a `101`: o Toninho do tutorial.
		"toninho": _chaves(nar["TONINHO_FALAS"]),
	}
	# Uma varredura que não acha nada passa sem conferir coisa nenhuma.
	_confere("achou as falas dos quatro personagens (%d)" % (
		falas["cida"].size() + falas["arlindo"].size() + falas["ribeiro"].size()
		+ falas["toninho"].size()),
		falas["cida"].size() >= 12 and falas["arlindo"].size() >= 7
		and falas["ribeiro"].size() >= 5 and falas["toninho"].size() >= 3)

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
	_f7_falas_do_toninho_chegam_ao_jogo(falas["toninho"])


# ⚠️ E O TONINHO É O IRMÃO DESTA PERGUNTA (`101`): as falas dele vivem na
# `Narrativa` e o gatilho no `TutorialDoToninho.gd` — outro arquivo, logo não é
# espelho. Mas ali a busca pelo id ENTRE ASPAS, que serve aos painéis, dava um
# verde de graça: «atracar» e «avancar» são também os nomes dos PASSOS
# (`passo = "atracar"`), e apagar a fala deixava o passo a satisfazer a busca.
# O que se procura é o argumento do `_dizer(...)`, que é quem põe a fala na
# fila. E por dois caminhos (`037`): quantas chamadas o texto tem, contra
# quantas a expressão leu — um `_dizer(id_composto)` reprova em vez de sumir.
func _f7_falas_do_toninho_chegam_ao_jogo(ids: Array[String]) -> void:
	var fonte := _sem_comentarios(
		FileAccess.get_file_as_string("res://scripts/TutorialDoToninho.gd"))
	_confere("F7: o TutorialDoToninho.gd foi lido", fonte.length() > 500)
	var re := RegEx.new()
	re.compile("(?<!func )_dizer\\(\"([a-z_]+)\"\\)")
	var ditos := {}
	var lidas := 0
	for c in re.search_all(fonte):
		ditos[c.get_string(1)] = true
		lidas += 1
	var chamadas := 0
	var i := fonte.find("_dizer(")
	while i >= 0:
		if not fonte.substr(maxi(0, i - 5), 5).ends_with("func "):
			chamadas += 1
		i = fonte.find("_dizer(", i + 1)
	_confere("F7: toda chamada do tutorial à fala passa um id literal (%d chamadas, %d lidas)"
		% [chamadas, lidas], chamadas > 0 and chamadas == lidas)
	var mudas: Array[String] = []
	for id in ids:
		if not ditos.has(id):
			mudas.append(id)
	_confere("toninho: as %d falas chegam todas ao jogo" % ids.size(),
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
	GS.fila = [GS._make_boat()]
	GS.pending_rival = 0
	GS.rival_attempts_left = GS.RIVAL_PATIENCE
	GS._set_phase("rival_offer")

	var painel: Node = cena.instantiate()
	root.add_child(painel)
	painel.setup(0)
	_confere("a contra-oferta abre com a fala de abertura",
		painel.texto_da_fala() != "")

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
		painel.texto_da_fala() == GS.texto(Narrativa.ARLINDO_PERDEU),
		"saiu: " + painel.texto_da_fala().left(60))
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


# ── F2b ─────────────────────────────────────────────────────────────────
# O ÍCONE DE CADA CABEÇALHO LÊ-SE NO SELO (`docs/decisoes/066`).
#
# O cabeçalho das famílias da frente 3 pousa o ícone num SELO claro
# (`SeloNarrativo`, #f0f6ff), e o desenho dos ícones não é um só: os do HUD são
# traço CLARO para a barra escura, os de painel têm disco navy. Em 26/09 o
# «Carregar partida» nasceu com o ícone `doca` — traço exatamente da cor do
# selo, contraste 1,0 — e saiu um quadrado vazio que só a FOTO mostrou. Era a
# segunda vez do mesmo ícone num fundo claro: o `CLAUDE.md` já contava que ele
# tinha sido um fantasma no painel branco.
#
# A pergunta é do PIXEL contra o fundo real do selo, e a medida é a MEDIANA
# do contraste dos pixels opacos — nunca a média, que se deixa puxar pelo miolo
# claro de um ícone de disco navy (`027`). As duas fontes: os ícones que os
# scripts PASSAM ao cabeçalho, lidos do código, e os pixels deles.
var _f2b_terminou := false

# Medido em 26/09 sobre os 24 ícones do `Icones.gd`: o `doca` dá 1,00 e os
# mais fracos dos que um cabeçalho usa, o âmbar do `recomecar` e o do `vitoria`,
# 1,63. O corte fica no MEIO da banda — 1,3× acima do `doca`, 1,25× abaixo do
# âmbar. ⚠️ O que ele NÃO diz: que 1,63 se lê bem. O âmbar separa-se do selo
# pelo MATIZ, e esta régua só vê valor; ela apanha o ícone da COR do selo, que
# é o defeito que já aconteceu duas vezes, e mais nada.
const F2B_CORTE_SELO := 1.3


func _f2b_lum(c: Color) -> float:
	var lin := func(v: float) -> float:
		return v / 12.92 if v <= 0.04045 else pow((v + 0.055) / 1.055, 2.4)
	return 0.2126 * lin.call(c.r) + 0.7152 * lin.call(c.g) + 0.0722 * lin.call(c.b)


func _f2b_mediana_no_selo(textura: Texture2D, fundo: Color) -> float:
	var img: Image = textura.get_image()
	if img.is_compressed():
		img.decompress()
	var razoes: Array = []
	var lf := _f2b_lum(fundo)
	for y in img.get_height():
		for x in img.get_width():
			var p := img.get_pixel(x, y)
			if p.a < 0.5:
				continue
			var lc := _f2b_lum(fundo.lerp(Color(p.r, p.g, p.b), p.a))
			razoes.append((maxf(lc, lf) + 0.05) / (minf(lc, lf) + 0.05))
	if razoes.is_empty():
		return 0.0
	razoes.sort()
	return razoes[razoes.size() / 2]


# As chamadas ao cabeçalho, com os parênteses EQUILIBRADOS: o primeiro
# argumento pode trazer outra chamada ou um ternário (`Icones.VITORIA if … else
# Icones.DERROTA`), e todo `Icones.X` dentro dele é um ícone que aparece no
# selo. A definição (`func titulo_encorpado(`) não é chamada.
func _f2b_icones_das_chamadas(fonte: String, nome: String, saida: Dictionary,
		cegas: Array) -> int:
	var lidas := 0
	var re_icone := RegEx.new()
	re_icone.compile("Icones\\.([A-Z_]+)")
	var de := 0
	while true:
		var i := fonte.find(nome + "(", de)
		if i < 0:
			break
		de = i + nome.length()
		if fonte.substr(maxi(i - 5, 0), 5) == "func ":
			continue
		var fundo := 0
		var j := i + nome.length()
		while j < fonte.length():
			var ch := fonte[j]
			if ch == "(":
				fundo += 1
			elif ch == ")":
				fundo -= 1
				if fundo == 0:
					break
			j += 1
		lidas += 1
		var achados := re_icone.search_all(fonte.substr(i, j - i))
		# ⚠️ CHAMADA SEM `Icones.X` É UM ÍCONE QUE A GUARDA NÃO VÊ — vindo de
		# uma variável, de um parâmetro. Contava como lida e não conferia nada.
		if achados.is_empty():
			cegas.append(fonte.substr(i, mini(j - i + 1, 60)))
		for achado in achados:
			saida[achado.get_string(1)] = true
	return lidas


func _f2b_icones_no_selo() -> void:
	var tema: Theme = load("res://ui/tema_brport.tres")
	var fundo: Color = (tema.get_stylebox("panel", "SeloNarrativo") as StyleBoxFlat).bg_color
	var consts: Dictionary = load(FONTE_ICONES).get_script_constant_map()

	var usados := {}
	var cegas: Array = []
	var chamadas := 0
	var ocorrencias := 0
	for arquivo in _f9_scripts_do_jogo():
		# O ANDAIME FICA DE FORA, e só ele: o `titulo_encorpado()` dele
		# reencaminha o ícone que RECEBEU para o `cabecalho_encorpado()`, e
		# quem o escolhe é quem chama o andaime — essas chamadas estão nos
		# outros arquivos, e são elas que se leem.
		if arquivo.get_file() == "PainelNarrativo.gd":
			continue
		var fonte := _sem_comentarios(FileAccess.get_file_as_string(arquivo))
		for nome in ["titulo_encorpado", "cabecalho_encorpado"]:
			chamadas += _f2b_icones_das_chamadas(fonte, nome, usados, cegas)
			ocorrencias += fonte.count(nome + "(") - fonte.count("func " + nome + "(")
	# ⚠️ A MESMA PERGUNTA POR DOIS CAMINHOS: quantas vezes o nome aparece, e
	# quantas chamadas o leitor conseguiu ler. Uma forma nova de chamada que
	# o leitor não saiba ler reprova aqui, em vez de sair da lista calada.
	_confere("F2b: o leitor leu as %d chamadas ao cabeçalho que o código tem (%d)" % [ocorrencias, chamadas],
		chamadas == ocorrencias and chamadas > 0)
	_confere("F2b: toda chamada nomeia o ícone por `Icones.X`, que é o que a guarda lê",
		cegas.is_empty(), " | ".join(cegas))
	_confere("F2b: os cabeçalhos usam ícones (%d)" % usados.size(), usados.size() >= 5)

	for nome in usados:
		if not consts.has(nome) or not (consts[nome] is Texture2D):
			_confere("F2b: Icones.%s existe" % nome, false)
			continue
		var mediana := _f2b_mediana_no_selo(consts[nome], fundo)
		_confere("F2b: Icones.%s lê-se no selo (mediana %.2f:1, corte %.2f)" % [nome, mediana, F2B_CORTE_SELO],
			mediana >= F2B_CORTE_SELO)
	_f2b_terminou = true


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


func _f8_recolher(texto: String, _kind: String, _assunto: String = "") -> void:
	_f8_sistema.append(texto)


# ⚠️ AS FALAS DO TONINHO NÃO ENTRAM AQUI. Desde a `101` o dia 1 tem o
# tutorial, e este bloco monta o `Main` no dia 1: a fala do passo 1 entra na
# mesma fila, no fim do mesmo frame, e com a prioridade da Dona Cida — e o
# `_f8_drenar()` devolvia-a como «a última mostrada» por cima da variante que
# o F8c2 pergunta. Este bloco pergunta pelo sistema e pela Dona Cida; o
# tutorial tem o seu, o F22, e é lá que a fala dele se prova vista.
func _f8_recolher_apresentada(texto: String, _kind: String) -> void:
	for id in Narrativa.TONINHO_FALAS:
		if texto == Narrativa.toninho(String(id)):
			return
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
# «Barco à espera» é, desde a `083`, um barco AO LARGO: a doca já não espera
# por trabalhador nenhum.
func _f8_por_barco_a_espera(sim: bool) -> void:
	for d in GS.docks:
		d["boat"] = null
		d["worker_id"] = null
	GS.fila = []
	if sim:
		var barco: Dictionary = GS._make_boat()
		barco["rival"] = false
		GS.fila = [barco]


func _f8_a_fala_e_vista() -> void:
	# ── F8a. A conclusão: `obra_concluida` e o "pronto" do sistema.
	if not _f8_abrir():
		return
	GS.comprar_estrutura("pier_2")
	_f8_avancar_ate(3)
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

	# ── F8b. O prazo é fixo: a fala não inventa atraso ou duração.
	# Guarda estreita de propósito: defende o regresso da frase medida falsa
	# ("Demorou o dobro do previsto"), não a verdade das falas em geral.
	var upgrade: String = Narrativa.cida("upgrade_pronto").to_lower()
	var tempo := ["demor", "atras", "levou", "semana", "dia", "mês", "mes ", "hora"]
	var achadas: Array[String] = []
	for palavra in tempo:
		if upgrade.contains(palavra):
			achadas.append(palavra)
	_confere("F8b: a fala da obra não inventa duração",
		achadas.is_empty(), "diz: " + ", ".join(achadas))

	# ── F8c. A semana nova escolhe pela CONDIÇÃO.
	# Chama `_semana_nova()` direto, na narradora do `Main`: o estado é montado
	# à mão e o esperado é escrito à mão a partir dele, nunca recalculado dos
	# mesmos predicados que a fala usa — isso seria o espelho, e um peso posto
	# a zero desapareceria dos dois lados ao mesmo tempo.
	if not _f8_abrir():
		return
	_f8_por_barco_a_espera(true)
	GS.cash = GS.valor_da_parcela(0) / 2 - 1
	_f8_main.narradora._semana_nova()
	_confere("F8c: com barco à espera e caixa curto, sai a variante das duas",
		_f8_drenar() == Narrativa.cida("semana_nova_fila_curto"),
		"ficou: " + _f8_drenar())
	_f8_por_barco_a_espera(false)
	GS.cash = GS.valor_da_parcela(0)
	_f8_main.narradora._semana_nova()
	_confere("F8c: sem barco e com caixa folgado, sai a variante de nenhuma das duas",
		_f8_drenar() == Narrativa.cida("semana_nova_parado_folgado"),
		"ficou: " + _f8_drenar())
	_f8_fechar()

	# ── F8c2. E O PREDICADO É LIDO ONDE A LINHA É ESCRITA, não onde o sinal
	# dispara. É o que separa uma fala verdadeira de uma que descreve um
	# instante que o jogador nunca vê: `turn_advanced` sai ANTES do sorteio do
	# dia, e medido em 18/09 `docas_esperando()` deu ZERO em 315 viradas ali
	# (desde a `083` a pergunta é `barcos_ao_largo()`, com o mesmo instante),
	# contra barco à espera em 74 de 155 um instante depois.
	#
	# A prova monta o estado A, dispara, TROCA para o estado B e exige que a
	# variante seja a de B. Se o predicado fosse lido no sinal, sairia a de A.
	if not _f8_abrir():
		return
	_f8_main.narradora._cida_semana(8, 1)          # regista a semana anterior, sem falar
	_f8_por_barco_a_espera(false)        # estado A: cais parado
	GS.cash = GS.valor_da_parcela(0)
	_f8_main.narradora._cida_semana(9, 2)          # dispara — a escolha fica para depois
	_f8_por_barco_a_espera(true)         # estado B: barco à espera
	GS.cash = GS.valor_da_parcela(0) / 2 - 1
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
	# ⚠️ O CAIXA SAI DO VALOR DO DIA, e não do `valor_da_parcela()`. A parcela
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
	GS.cash = GS.valor_da_parcela(0) / 2 - 1
	GS.parcela_paid = false
	_f8_main.narradora._semana_nova()
	_confere("F8f: com a parcela por pagar, é ela que a fala nomeia",
		_f8_drenar() == Narrativa.cida("semana_nova_parado_curto"),
		"ficou: " + _f8_drenar())
	GS.parcela_paid = true
	_f8_main.narradora._semana_nova()
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
	_f8_avancar_ate(3)
	await _f8_esperar()
	_f8_drenar()
	_confere("F8g: a primeira obra tem a reação de primeira vez",
		_f8_foi_apresentada(Narrativa.cida("upgrade_pronto")),
		"apresentadas: " + ", ".join(_f8_apresentadas))
	# A SEGUNDA CONCLUSÃO É A DUPLICATA SEMÂNTICA, e é aqui
	# que ela se prova: a fala é a MESMA string, logo funde-se; as duas
	# mensagens do sistema são DIFERENTES e não se fundem. É o caso que a nota
	# original da fila; desde `087` as obras levam dias e são sequenciais.
	var antes_da_segunda := _f8_apresentadas.size()
	GS.turn = GS.TURNS_PER_WEEK + 1
	GS.comprar_estrutura("armazem")
	_f8_avancar_ate(10)
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
	GS.turn = GS.dia_da_parcela(0) + 1
	GS.parcela_indice = 1
	GS.parcelas_quitadas = 1
	GS.comprar_estrutura("patio")
	_f8_avancar_ate(32)
	await _f8_esperar()
	_f8_drenar()
	_confere("F8g: da terceira em diante ela concede",
		_f8_foi_apresentada(Narrativa.cida("upgrade_pronto_rotina")),
		"apresentadas: " + ", ".join(_f8_apresentadas))
	_f8_fechar()

	# ── F8h. A NARRADORA MORRE COM O `Main` QUE A MONTOU (`096`).
	# Ela é um `RefCounted` ligado a sinais do `GameState`, que vive o jogo
	# inteiro. Ligada por MÉTODO, a ligação morre com ela; ligada por LAMBDA,
	# o lambda guarda-a viva — medido numa sonda em 11/10 —, e cada `Main`
	# solto (cada volta à tela inicial, cada bloco destas suítes) deixaria uma
	# narradora a ouvir o jogo e a falar para uma fila que ninguém pinta.
	# Nada na tela o mostra, e por isso a pergunta é feita aqui.
	if not _f8_abrir():
		return
	var narradora_viva: WeakRef = weakref(_f8_main.narradora)
	_confere("F8h: a montagem tem uma narradora para seguir",
		narradora_viva.get_ref() != null, "o Main não a montou")
	_f8_fechar()
	_confere("F8h: a narradora morre com o Main que a montou",
		narradora_viva.get_ref() == null,
		"continua viva — um sinal do GameState segura-a (um lambda no conectar()?)")

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
	var plural := _f9_expressao_do_plural_fixo()
	# ⚠️ E O TERNÁRIO QUE ESCOLHE A PALAVRA INTEIRA, e não só o «s» (`090`).
	# O rodapé do Construir escrevia `"disponível" if n == 1 else
	# "disponíveis"`, e a busca abaixo, que procura `else "s"`, não o via —
	# o nome desta asserção prometia mais do que ela perguntava. As duas
	# palavras entre aspas, com o `== 1` no meio: o `SAVE_ARQUIVO if n == 1`
	# do `GameState` escolhe um arquivo e não tem aspas do lado do «sim».
	var palavra_inteira := RegEx.new()
	palavra_inteira.compile("\"[^\"]*\"\\s+if\\s+[^\"\\n]+==\\s*1\\s+else\\s+\"")
	var fixos := []
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
			if limpa.contains("else \"s\"") or limpa.contains("else \"es\"") \
					or palavra_inteira.search(limpa) != null:
				ternarios.append("%s: %s" % [caminho.get_file(), limpa])
		var texto := "\n".join(uteis)
		# A DECLARAÇÃO não é chamada: o `Narrativa.gd` traz o `func concordar(`
		# e ele contaria como uma décima segunda chamada que ninguém faz.
		chamadas += texto.count("concordar(") - texto.count("func concordar(")
		for m in re.search_all(texto):
			pares.append([caminho.get_file(), m.get_string(1), m.get_string(2)])
		if not _f9_fala_com_quem_desenvolve(caminho):
			for palavra in _f9_plurais_fixos(plural, texto):
				fixos.append("%s: «%%d %s»" % [caminho.get_file(), palavra])

	_confere("F9: nenhum rótulo do jogo escreve \"(s)\" ao jogador",
		crus.is_empty(), "\n    " + "\n    ".join(crus))
	_confere("F9: nenhuma contagem concorda com um ternário à mão",
		ternarios.is_empty(), "\n    " + "\n    ".join(ternarios))

	# ⚠️ E A TERCEIRA FORMA NÃO DEIXA MARCA NENHUMA: o número seguido de um
	# plural escrito à mão (`090`). «%d dias de obra» saía certo com os prazos
	# de hoje, 2 e 3, e um prazo de um dia sairia «1 dias» sem `(s)` nem
	# ternário que as duas buscas acima vissem. A revisão de 09/10 achou-a em
	# dois sítios, a obra no Construir e na mensagem da compra; a busca pela
	# FORMA achou mais quatro, todas certas hoje só porque o número nunca era 1
	# ali — o recibo só se imprime com as três parcelas, o «parte em» só depois
	# de o `faltam <= 1` sair por outro ramo, os berços e as cobranças são
	# constantes. É a regra do `CLAUDE.md` outra vez: fecha-se pelo `grep` da
	# forma, e quem a cumpre passa pelo `concordar()`.
	# ⚠️ A EXPRESSÃO PROVA-SE ANTES DE VARRER: uma que não casasse nada daria
	# a lista vazia, que é o verde de graça. E o caso maiúsculo entra na prova
	# porque o painel das docas escrevia «%d BERÇOS», em caixa alta.
	_confere("F9: a expressão do ternário de palavra inteira reconhece a forma que caça",
		palavra_inteira.search("var p := \"disponível\" if n == 1 else \"disponíveis\"") != null
			and palavra_inteira.search("return SAVE_ARQUIVO if n == 1 else \"x_%d.json\" % n") == null)
	_confere("F9: a expressão do plural fixo reconhece a forma que caça",
		_f9_plurais_fixos(plural, "x = \"· %d dias de obra\" % n") == ["dias"]
			and _f9_plurais_fixos(plural, "x = \"%d DE %d BERÇOS\" % [a, b]") == ["BERÇOS"]
			and _f9_plurais_fixos(plural, "x = \"pronto no dia %d.\" % n").is_empty()
			and _f9_plurais_fixos(plural, "x = \"%d das estruturas\" % n").is_empty())
	_confere("F9: nenhum número escreve o plural à mão («%d dias»)",
		fixos.is_empty(), "\n    " + "\n    ".join(fixos))

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
			# Em minúsculas, porque o painel das docas concorda em caixa alta.
			if not palavra.to_lower().ends_with("s") and not _F9_INVARIAVEIS.has(palavra):
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


# O número seguido da palavra que ele conta: `%d`, com as bandeiras e a
# largura que o formato aceita, um espaço, e a palavra até à primeira
# pontuação. Quem conta é a palavra no plural — a singular («%d dia») é o
# mesmo defeito, mas um número seguido de palavra no singular é quase sempre
# um ordinal («semana %d encerrada», «dia %d vence»), e separar os dois pede
# um dicionário de português.
func _f9_expressao_do_plural_fixo() -> RegEx:
	var re := RegEx.new()
	re.compile("%[-+ 0#]*\\d*d\\s+([^\\s\"%,.;:!?·—()\\[\\]/]+)")
	return re


# As palavras no plural que seguem um `%d` no texto, menos as que não contam.
func _f9_plurais_fixos(re: RegEx, texto: String) -> Array:
	var achadas := []
	for m in re.search_all(texto):
		var palavra := m.get_string(1)
		var minuscula := palavra.to_lower()
		if minuscula.ends_with("s") and not _F9_NAO_CONTAM.has(minuscula):
			achadas.append(palavra)
	return achadas


# As palavras em -s que seguem um número sem serem o que ele conta. Curta pela
# mesma razão da lista acima: cada entrada é uma porta.
#   das, dos — o partitivo: em «3 das estruturas» o número conta o que vem
#              depois da preposição, e o partitivo é plural para qualquer n
#              («uma das estruturas»). O Parcela escreve-o assim.
const _F9_NAO_CONTAM := ["das", "dos"]


# Quem fala com quem DESENVOLVE e não com quem joga, dentro do escopo do F9 —
# o mesmo motivo que deixa `tools/` e `tests/` de fora, e que só vale para a
# forma do plural fixo: as duas buscas acima continuam a varrer tudo.
#   scripts/validation/ — o validador de assets e a régua do contraste
#                         imprimem no terminal da suíte;
#   autoload/Registro.gd — o «teto de %d linhas» vai para o `.jsonl` que o
#                          `ler_registros.py` lê, e nunca chega à tela.
func _f9_fala_com_quem_desenvolve(caminho: String) -> bool:
	return caminho.begins_with("res://scripts/validation/") \
		or caminho == "res://autoload/Registro.gd"


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
	GS.fase_concluida.connect(_f10_recolher_passagem)
	var nome: String = "W".repeat(int(GS.NOME_MAX_CARACTERES))

	# ── O Sr. Ribeiro. Sem dinheiro para a parcela a entrada tem os DOIS
	# botões, que é o cartão mais alto dela.
	if not _f10_ate_ao_vencimento(nome):
		return
	# O cenário mede o caminho sem dinheiro, não a dificuldade desta semente.
	# A parcela menor (`084`) fez a mesma partida conseguir pagar.
	GS.cash = int(GS.valor_da_parcela(0)) / 2
	var p: Node = await _f10_abrir(F10_RIBEIRO, [GS.valor_da_parcela(0)])
	_f10_medir(p, "Ribeiro, entrada", &"entrada")
	if not await _f10_tocar(p, "Não consigo"):
		return
	# A SEGUNDA CHANCE (`102`): na primeira cobrança o «não consigo» abre a
	# oferta, e quem perde o porto é quem a recusa.
	_confere("F10: «Não consigo pagar» na primeira cobrança não encerra a partida",
		GS.phase == "debt_payment" and not _f10_motivos.has(false))
	_f10_medir(p, "Ribeiro, segunda chance", &"segunda_chance")
	if not await _f10_tocar(p, "Recusar"):
		return
	_confere("F10: «Recusar» a segunda chance encerrou a partida",
		GS.phase == "game_over" and _f10_motivos.has(false))
	_f10_medir(p, "Ribeiro, não pagou", &"nao_pagou")
	_f10_fechar(p)

	# E quem a aceita: a resposta leva o dinheiro que fica e a dívida, na
	# linha de apoio, e é a mais comprida das tarjas desta cena.
	if not _f10_ate_ao_vencimento(nome):
		return
	GS.cash = int(GS.valor_da_parcela(0)) / 2
	p = await _f10_abrir(F10_RIBEIRO, [GS.valor_da_parcela(0)])
	if not await _f10_tocar(p, "Não consigo"):
		return
	if not await _f10_tocar(p, "Aceitar"):
		return
	_confere("F10: «Aceitar o empréstimo» pagou a parcela e a partida segue",
		GS.phase in ["playing", "rival_offer"] and GS.parcelas_quitadas == 1
			and GS.emprestimo_devido > 0)
	_f10_medir(p, "Ribeiro, emprestou", &"emprestou")
	_f10_fechar(p)

	if not _f10_ate_ao_vencimento(nome, GS.parcelas_na_fase()):
		return
	GS.cash = GS.principal_da_parcela()
	p = await _f10_abrir(F10_RIBEIRO, [GS.principal_da_parcela()])
	if not await _f10_tocar(p, "Pagar"):
		return
	# A última quitada passa à Fase 2, que recomeça o recibo (`104`): quem
	# prova o pagamento é a fase nova e a frase da passagem.
	_confere("F10: «Pagar» quitou mesmo a última parcela, e a partida passou à Fase 2",
		int(GS.numero_da_fase) == 2 and _f10_motivos.has(true))
	_f10_medir(p, "Ribeiro, pagou", &"pagou")
	_f10_fechar(p)

	# ── O Arlindo. A rodada abre; cada aposta que o cliente recusa acrescenta
	# a reação e, na última tentativa, a pressão — é a rodada mais comprida.
	for acao in ["Cortar metade", "Manter"]:
		if not _f10_ate_a_oferta(nome):
			return
		p = await _f10_abrir(F10_ARLINDO, [GS.pending_rival])
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
				p.texto_da_fala() == GS.texto(Narrativa.ARLINDO_VENCEU))
			_f10_medir(p, "Arlindo, despedida de quem venceu", &"despedida")
			_f10_sem_negociacao(p, "venceu")
		_f10_fechar(p)

	if not _f10_ate_a_oferta(nome):
		return
	p = await _f10_abrir(F10_ARLINDO, [GS.pending_rival])
	if not await _f10_tocar(p, "Igualar"):
		return
	_confere("F10: «Igualar» fecha e o Arlindo perde",
		p.texto_da_fala() == GS.texto(Narrativa.ARLINDO_PERDEU))
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
			# A narração é uma entrada do diário em duas páginas (`082`): o
			# «Virar a página» vira a folha, e o «Ver o balanço» só existe na
			# segunda, que o painel declara no fim da virada.
			var paginas: PackedStringArray = Narrativa.fim_de_fase_paginas()
			_f10_pagina_mostra(p, "primeira", paginas[0])
			if not await _f10_tocar(p, "Virar a página"):
				return
			if not await _f10_esperar_o_tempo(p, &"segunda_pagina"):
				return
			_f10_medir(p, "Fim, a segunda página", &"segunda_pagina")
			_f10_pagina_mostra(p, "segunda", paginas[1])
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
	GS.fase_concluida.disconnect(_f10_recolher_passagem)
	_f10_todo_nome_e_medido(nome)
	GS.clear_save()
	_f10_terminou = true


func _f10_recolher_fim(venceu: bool, motivo: String) -> void:
	_f10_motivos[venceu] = motivo


# A frase de quem PAGOU vem da passagem desde a `104`: a terceira quitação
# segue para a Fase 2, e o `game_over` só chega a quem perde.
func _f10_recolher_passagem(_numero: int, motivo: String) -> void:
	_f10_motivos[true] = motivo


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
func _f10_ate_ao_vencimento(nome: String, numero: int = 1) -> bool:
	_f10_partida_nova(nome)
	if numero > 1:
		GS.cash = GS.START_CASH * 25
	var voltas := 0
	while GS.phase != "game_over" and voltas < 200:
		if GS.phase == "debt_payment":
			if GS.parcela_indice + 1 == numero:
				break
			GS.pay_debt()
		if GS.phase == "rival_offer":
			GS.resolve_rival_offer(true)
		GS.advance_turn()
		voltas += 1
	_confere("F10: a partida chega ao vencimento da parcela (turno %d)" % int(GS.turn),
		GS.phase == "debt_payment", "parou na fase «%s»" % GS.phase)
	return GS.phase == "debt_payment"


# Enche os berços livres com os barcos ao largo, pela ordem da fila (`083`).
# É o «Alocar todos» com que estas guardas jogavam: o jogo deixou de o ter, e
# atracar leva o trabalhador junto.
func _atracar_tudo() -> void:
	while GS.atracagem_pendente() != Vector2i.ZERO:
		if not GS.atracar(0, false):
			return


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


# O QUE A PÁGINA À VISTA MOSTRA: o texto à mão da página de CIMA — a primeira
# enquanto não vira (a segunda está por baixo dela, montada e tapada), a única
# visível depois. O D22 prova que as duas metades são a peça; isto prova que
# o painel põe cada uma na sua folha, que é onde ele as podia trocar.
func _f10_pagina_mostra(painel: Node, qual: String, esperado: String) -> void:
	var caderno: Node = painel.get_node_or_null("Caderno")
	var visto := ""
	if caderno != null:
		for pagina in caderno.get_children():
			if pagina is PanelContainer and (pagina as Control).visible:
				var texto: Node = pagina.find_child("Texto", true, false)
				if texto is Label:
					visto = (texto as Label).text
	_confere("F10: a %s página do fim de fase mostra a %s metade da peça" % [qual, qual],
		visto == esperado, "mostra: " + visto.left(40))


# Um tempo que só chega no fim de uma animação — a virada da folha do fim de
# fase. Espera por ele, com teto, e reprova se não chegar: contar os frames da
# virada aqui seria um número a envelhecer no dia em que ela mudasse.
const F10_TETO_DO_TEMPO := 600


func _f10_esperar_o_tempo(painel: Node, tempo: StringName) -> bool:
	var frames := 0
	while painel.tempo != tempo and frames < F10_TETO_DO_TEMPO:
		await process_frame
		frames += 1
	_confere("F10: o painel chegou ao tempo «%s» (%d frames)" % [tempo, frames],
		painel.tempo == tempo, "ficou em «%s»" % painel.tempo)
	return painel.tempo == tempo


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
# três telas em fila (`VezDasTelas.gd`, `054`, `097`), e este bloco percorre
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
# bloco passa. Quem o apanha é a bateria de captura, cujos laços dispensam
# boletins por `remove_child()` — ver o comentário do `na_vez()`. Medido em
# 11/10 (`097`): o primeiro tiro a reprovar é o `boletim_otimo`, que pede o
# boletim da semana 2 e acha a tela vazia, antes de o `balanco` correr.
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
	var soltou = await _f11_soltar_com_fila()
	_f11_terminou = pagou == true and nao_pagou == true and quitou == true \
		and soltou == true
	GS.clear_save()


# O dinheiro é dado, com folga para os custos da semana 4: o que se testa é a
# ordem das telas, e o «Pagar» só está ligado com dinheiro.
func _f11_pagou() -> bool:
	if not _f11_ate_ao_ultimo_dia():
		return true
	GS.cash = GS.principal_da_parcela() * 2
	var main: Node = await _f11_main_e_virar_o_dia()
	var p: Node = _f11_sozinho(main, F11_RIBEIRO, "entrada", "pagou, no vencimento")
	if p == null or not await _f10_tocar(p, "Pagar", "F11"):
		main.free()
		return true
	# A Fase 1 ganha não acaba a partida (`104`): segue na Fase 2, e o fim de
	# fase abre por cima do jogo, na mesma vez.
	_confere("F11: pagou — o «Pagar» passou a partida à Fase 2",
		int(GS.numero_da_fase) == 2 and GS.phase != "game_over" and not bool(GS.won),
		"fase %d, «%s», won=%s" % [int(GS.numero_da_fase), GS.phase, str(GS.won)])
	await _f11_ate_ao_fim(main, _f11_sozinho(main, F11_RIBEIRO, "pagou",
		"pagou, depois do «Pagar»"), "Até a próxima", "narracao", "pagou")
	return true


# Dinheiro suficiente para fechar a semana, mas insuficiente para a parcela.
# O caminho da recusa não pode depender de uma semente continuar perdedora
# depois de rebalancear (`084`). Quem perde vai direto ao balanço.
func _f11_nao_pagou() -> bool:
	if not _f11_ate_ao_ultimo_dia():
		return true
	GS.cash = int(GS.principal_da_parcela()) / 2 + int(GS.MAINTENANCE_WEEKLY) \
		+ int(GS.SALARY_PER_WORKER) * GS.workers.size()
	var main: Node = await _f11_main_e_virar_o_dia()
	var p: Node = _f11_sozinho(main, F11_RIBEIRO, "entrada", "não pagou, no vencimento")
	if p == null or not await _f10_tocar(p, "Não consigo", "F11"):
		main.free()
		return true
	await _f11_ate_ao_fim(main, _f11_sozinho(main, F11_RIBEIRO, "nao_pagou",
		"não pagou, depois do «Não consigo»"), "Adeus", "balanco", "não pagou")
	return true


# SOLTAR O `Main` COM TELAS NA FILA NÃO ABRE A SEGUINTE (`097`). O «Pagar» da
# última parcela deixa o Sr. Ribeiro com a vez e o boletim e o fim de fase à
# espera; quem solta o `Main` nessa altura — «Jogar de novo», a saída para a
# tela inicial, cada bloco destas suítes — tira o painel da vez da árvore, e
# o `tree_exited` dele passaria a vez a uma tela que já não tem onde abrir.
# Medido em 11/10 sem a guarda do `_passar_a_vez()`: as seis suítes e a
# bateria passavam todas, na main e na branch — e ela é a única linha de
# comportamento que a extração mudou de forma (o `is_inside_tree()` passou a
# ser perguntado ao dono). Os órfãos contam-se pelo motor, antes e depois.
func _f11_soltar_com_fila() -> bool:
	if not _f11_ate_ao_ultimo_dia():
		return true
	GS.cash = GS.principal_da_parcela() * 2
	var main: Node = await _f11_main_e_virar_o_dia()
	var p: Node = _f11_sozinho(main, F11_RIBEIRO, "entrada", "soltar com fila, no vencimento")
	if p == null or not await _f10_tocar(p, "Pagar", "F11"):
		main.free()
		return true
	# A GUARDA SÓ VALE COM A FILA CHEIA: sem telas à espera, soltar o `Main`
	# não tem vez nenhuma a passar, e a asserção seguinte passaria de graça.
	var vez_das_telas = main.vez
	var a_espera: int = (vez_das_telas.get("_fila_da_vez") as Array).size()
	_confere("F11: soltar com fila — o «Pagar» deixou telas à espera da vez (%d)" % a_espera,
		a_espera >= 1)
	var antes: int = int(Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT))
	main.free()
	var orfaos: int = int(Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)) - antes
	_confere("F11: soltar o Main com telas na fila não abre a seguinte (%d nós órfãos)" % orfaos,
		orfaos == 0)
	return true


# Sem Sr. Ribeiro: é o «Avançar dia» do último dia que fecha a semana e acaba a
# partida, e o boletim abre primeiro.
func _f11_quitou_antes() -> bool:
	if not _f11_ate_ao_ultimo_dia():
		return true
	GS.cash = GS.principal_da_parcela() * 2
	_confere("F11: quitou antes — a parcela pagou-se no último dia a jogar",
		GS.pagar_parcela_adiantado())
	var main: Node = await _f11_main_e_virar_o_dia()
	_confere("F11: quitou antes — virar o último dia passou a partida à Fase 2",
		int(GS.numero_da_fase) == 2 and GS.phase != "game_over" and not bool(GS.won),
		"fase %d, «%s», won=%s" % [int(GS.numero_da_fase), GS.phase, str(GS.won)])
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
	GS.cash = GS.START_CASH * 25
	var voltas := 0
	while int(GS.turn) < int(GS.turnos_da_fase()) and voltas < 200:
		if GS.phase == "debt_payment":
			GS.pay_debt()
		if GS.phase == "rival_offer":
			GS.resolve_rival_offer(true)
		GS.advance_turn()
		voltas += 1
	if GS.phase == "rival_offer":
		GS.resolve_rival_offer(true)
	var ok: bool = GS.phase == "playing" and int(GS.turn) == int(GS.turnos_da_fase())
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
			# Da Fase 1: quem pagou já está na 2, que não tem última semana.
			_confere("F11: %s — o boletim é o da última semana" % caso,
				semana == int(GS.ultima_semana_da_fase(1)), "é o da semana %d" % semana)
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
# - o cartão mostra o ARQUIVO do rosto (o mutante: o `DocaCartao.gd` sem a
#   linha). Até à `083` era o cartão do trabalhador; desde a fila o rosto mora
#   no cabeçalho da doca do píer dele.
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
	var cena := load("res://scenes/dock/DocaCartao.tscn") as PackedScene

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
	while GS.docks.size() < GS.bercos_no_mapa():
		GS.docks.append({"boat": null, "worker_id": null})
	while GS.workers.size() < GS.bercos_no_mapa():
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
	cartao.setup(0)
	var tex: Texture2D = (cartao.get_node("Coluna/Cabecalho/Placa/Retrato") as TextureRect).texture
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
	var parcela: int = int(GS.valor_da_parcela(0))
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
	_f14_tom_confere(painel, "oferta da segunda chance")
	if not await _f10_tocar(painel, "Recusar", "F14"):
		_f10_fechar(painel)
		return
	var faltaram := _f14_reais(_f14_texto(painel, "Faltaram"))
	_confere("F14: a resposta de quem não pagou repete a falta",
		faltaram.size() == 1 and falta.size() == 1 and int(faltaram[0]) == int(falta[0]),
		str(faltaram))
	_f14_tom_confere(painel, "resposta de quem não pagou")
	_f10_fechar(painel)

	# A SEGUNDA CHANCE (`102`). A oferta promete dois números e um dia ANTES
	# do toque — o que o banco põe, o que volta e quando —, e a resposta mais
	# dois DEPOIS dele. Cada um contra o que o jogo fez: o emprestado é o que
	# o caixa ganhou além do boleto que saiu.
	if not _f10_ate_ao_vencimento("F14"):
		return
	GS.cash = parcela - 76543
	painel = await _f10_abrir(F10_RIBEIRO, [parcela])
	if not await _f10_tocar(painel, "Não consigo", "F14"):
		_f10_fechar(painel)
		return
	var oferta := _f14_reais(_f14_texto(painel, "Empréstimo"))
	var linha_volta := _f14_texto(painel, "Volta")
	var volta := _f14_reais(linha_volta)
	var dia_dito := RegEx.create_from_string("dia (\\d+)").search(linha_volta)
	var antes := int(GS.cash)
	if not await _f10_tocar(painel, "Aceitar", "F14"):
		_f10_fechar(painel)
		return
	_confere("F14: o empréstimo prometido é o que o banco pôs no caixa",
		oferta.size() == 1 and int(oferta[0]) == int(GS.cash) - antes + parcela,
		"prometeu %s; o caixa foi de %d a %d com o boleto de %d" % [
			str(oferta), antes, int(GS.cash), parcela])
	_confere("F14: o que «Volta» é a dívida que o jogo guardou",
		volta.size() == 1 and int(volta[0]) == int(GS.emprestimo_devido),
		"prometeu %s; o jogo deve %d" % [str(volta), int(GS.emprestimo_devido)])
	_confere("F14: e no dia da cobrança em que ela vence",
		dia_dito != null and int(dia_dito.get_string(1)) == int(GS.vencimento_da_parcela()),
		"«%s», a cobrança vence no dia %d" % [linha_volta, int(GS.vencimento_da_parcela())])
	var fica := _f14_reais(_f14_texto(painel, "Você fica com"))
	_confere("F14: a resposta de quem aceitou diz o dinheiro que fica e a dívida",
		fica.size() == 2 and int(fica[0]) == int(GS.cash)
			and int(fica[1]) == int(GS.emprestimo_devido), str(fica))
	_f14_tom_confere(painel, "resposta de quem aceitou")
	_f10_fechar(painel)
	_f14_cobranca_ok = true


# OS PREÇOS DOS TRÊS BOTÕES, contra o `matched_value` que o
# `_fechar_negocio()` escreve — que é o que o jogo paga. As apostas ganham pela
# semente, e a despedida tem de repetir o mesmo número.
func _f14_precos() -> void:
	for prefixo in ["Igualar", "Cortar", "Manter"]:
		if not _f10_ate_a_oferta("F14"):
			return
		var doca := int(GS.pending_rival)
		var barco: Dictionary = GS.fila[doca]
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
		var doca := int(GS.pending_rival)
		var barco: Dictionary = GS.fila[doca]
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
			# Desde a `083` o barco disputado está AO LARGO: perdido, sai da fila.
			_confere("F14: recusada a última, o barco foi mesmo para o rival",
				not GS.fila.has(barco) and int(GS.metrics["rival_refused"]) == perdidas + 1,
				"barco %s, perdidas %d" % [str(GS.fila.has(barco)), int(GS.metrics["rival_refused"])])
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
		var doca := int(GS.pending_rival)
		var molde: Dictionary = (GS.fila[doca] as Dictionary).duplicate(true)
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
				GS.fila = [molde.duplicate(true)]
				GS.pending_rival = 0
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
	# ProgressBar tem limites nos dois lados: prejuízo mostra barra vazia.
	var esperada := clampf(float(dinheiro) / float(parcela), 0.0, 1.0)
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
	# O EMPRÉSTIMO DA SEGUNDA CHANCE (`102`) vem À PARTE, abaixo da tarja, e o
	# número dele é o da semana — o laço de cima também o encheu, porque as
	# chaves saem do `SEMANA_ZERADA`. Sem dívida viva (partida nova), a frase
	# não promete devolução nenhuma.
	var emprestou := _f14_reais(_f14_texto(painel, "O Sr. Ribeiro emprestou"))
	_confere("F14: o boletim mostra o empréstimo da semana à parte, com o número dela",
		int(resumo["emprestimo"]) > 0 and emprestou.size() == 1
			and int(emprestou[0]) == int(resumo["emprestimo"]),
		"mostrou %s, a semana tem %d" % [str(emprestou), int(resumo["emprestimo"])])
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
	# A segunda chance (`102`): o boleto saiu, e o porto segue — é resultado
	# bom; a oferta, antes de aceitar, é um preço.
	"Parcela paga com o empréstimo": &"TarjaNarrativaBoa",
	"Empréstimo": &"TarjaNarrativa",
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


# Um botão visível, ainda não condenado, cujo texto começa assim.
func _f14_tem_botao(no: Node, inicio: String) -> bool:
	if no is Button and (no as Button).text.begins_with(inicio) \
			and (no as Control).is_visible_in_tree() and not no.is_queued_for_deletion():
		return true
	for filho in no.get_children():
		if _f14_tem_botao(filho, inicio):
			return true
	return false


func _f14_juntar_tarjas(no: Node, tarjas: Array) -> void:
	if no is PanelContainer and String((no as PanelContainer).theme_type_variation).begins_with("TarjaNarrativa") \
			and (no as Control).is_visible_in_tree() and not no.is_queued_for_deletion():
		tarjas.append(no)
	for filho in no.get_children():
		_f14_juntar_tarjas(filho, tarjas)


# O BALANÇO, pelos dois lados do fim. O motivo sai do `_check_end()` do jogo
# — dinheiro abaixo de zero, e o prazo acabado com a parcela paga —, e o
# painel abre com a frase que ele deixou. Quem venceu passa pela narração e
# chega ao balanço pelo botão dela, como a jogar.
#
# ⚠️ DESDE A `104` QUEM VENCE NÃO ACABA A PARTIDA: a frase vem da passagem
# (`fase_concluida`), e o balanço dele sai pela Fase 2. A saída é a pergunta
# nova — «Jogar de novo» por cima de um porto que acabou de passar apagá-lo-ia.
func _f14_balanco() -> void:
	for venceu in [false, true]:
		_f10_partida_nova("F14")
		if venceu:
			GS.parcela_paid = true
			GS.parcela_indice = GS.parcelas_na_fase() - 1
			GS.parcelas_quitadas = GS.parcelas_na_fase()
			GS.total_pago_parcelas = GS.valor_da_parcela(0) + GS.valor_da_parcela(1) + GS.valor_da_parcela(2)
			GS.turn = int(GS.turnos_da_fase()) + 1
		else:
			GS.cash = -1
		var passagem: Array = []
		var ouvir := func(_n: int, motivo: String) -> void: passagem.append(motivo)
		GS.fase_concluida.connect(ouvir)
		GS._check_end()
		GS.fase_concluida.disconnect(ouvir)
		if venceu:
			_confere("F14: a Fase 1 vencida passou à Fase 2, com a frase do balanço",
				int(GS.numero_da_fase) == 2 and GS.phase != "game_over" and passagem.size() == 1,
				"fase %d, «%s», %d passagens" % [int(GS.numero_da_fase), GS.phase, passagem.size()])
		else:
			_confere("F14: o jogo acabou perdido", GS.phase == "game_over" and not bool(GS.won),
				"fase %s" % GS.phase)
		var motivo: String = String(passagem[0]) if venceu and passagem.size() == 1 \
			else String(GS.end_reason)
		var painel: Node = await _f10_abrir(F10_FIM, [venceu, motivo])
		# Duas páginas de diário antes do balanço (`082`): vira-se a folha e
		# espera-se a segunda, como a jogar.
		if venceu and not (await _f10_tocar(painel, "Virar a página", "F14")
				and await _f10_esperar_o_tempo(painel, &"segunda_pagina")
				and await _f10_tocar(painel, "Ver o balanço", "F14")):
			_f10_fechar(painel)
			return
		_f14_tom_confere(painel, "balanço de quem %s" % ("venceu" if venceu else "perdeu"))
		var seguir := _f14_tem_botao(painel, "Seguir para a Fase 2")
		var de_novo := _f14_tem_botao(painel, "Jogar de novo")
		_confere("F14: o balanço de quem %s sai %s" % ["venceu" if venceu else "perdeu",
				"pela Fase 2, sem «Jogar de novo»" if venceu else "por «Jogar de novo»"],
			seguir == venceu and de_novo == (not venceu),
			"seguir=%s, de novo=%s" % [str(seguir), str(de_novo)])
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
				load("res://tools/estado_da_bancada.gd").instalar(GS, String(id))
	var ok: bool = GS.tem_estrutura("armazem") and GS.tem_estrutura("patio") \
		and GS.docks.size() == int(GS.bercos_no_mapa())
	_confere("F15: o porto completo tem armazém, pátio e as %d docas" % int(GS.bercos_no_mapa()),
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
		# ⚠️ E A FILA VAZIA (`083`): um barco ao largo com um dia de paciência
		# desiste na MESMA virada, e o «perdido» que este caso conta passaria a
		# ser dois — o da doca e o dele.
		GS.fila = []
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
	GS.fila = []
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

	# ⚠️ A BARRA DO TRABALHO promete o progresso AO FIM DE HOJE, e confere-se
	# contra o progresso que o barco tem depois da virada — num barco de três
	# dias, onde a barra não pode estar cheia nem vazia.
	GS.turn = 2
	GS._set_phase("playing")
	for doca in GS.docks:
		doca["boat"] = null
		doca["worker_id"] = null
	for w in GS.workers:
		w["busy_turns"] = 0
	var longo := _f15_barco("pescado", 34567)
	longo["op_turns"] = 3
	GS.docks[0]["boat"] = longo
	GS.assign_worker(int(GS.workers[0]["id"]), 0, false)
	for passo in range(3):
		# A virada anterior pode ter aberto uma oferta do rival noutra doca, e
		# nessa fase o `advance_turn()` sai calado (`CLAUDE.md`).
		if GS.phase == "rival_offer":
			GS.resolve_rival_offer(true)
		var aberto: Node = await _f10_abrir(F15_DOCAS, [])
		var trabalho := aberto.find_child("Trabalho", true, false) as ProgressBar
		var promete := int(trabalho.value) if trabalho else -1
		var de := int(trabalho.max_value) if trabalho else -1
		_f10_fechar(aberto)
		var id_longo: int = int(GS.docks[0]["boat"]["id"])
		GS.advance_turn()
		var barco_depois = GS.docks[0]["boat"]
		var feito: int = int(barco_depois["progress"]) \
			if barco_depois != null and int(barco_depois["id"]) == id_longo else 3
		_confere("F15 docas, barco de três dias, dia %d: a barra promete %d de %d, e o jogo fica em %d"
			% [passo + 1, promete, de, feito], promete == feito and de == 3)
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
	var ultimo_resultado := 0
	var ultimo_dia := 0
	var mais_barcos := [0, 0]
	var maior := [0, 0, ""]
	var semanas: Array = []
	for _i in range(F15_DIAS):
		if GS.phase == "rival_offer":
			GS.resolve_rival_offer(true)
		if GS.phase != "playing":
			break
		_atracar_tudo()
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
		ultimo_resultado = resultado
		ultimo_dia = dia
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
	# ONTEM CONTRA O MELHOR DIA: a barra da tarja mede o último dia jogado
	# contra o recorde, os dois tirados do OBSERVADOR.
	var barra_ontem := painel.find_child("Barra", true, false) as ProgressBar
	var apoio_ontem := ""
	var textos_caixa: Array[String] = []
	_f10_textos_visiveis(painel, textos_caixa)
	for t in textos_caixa:
		if t.contains("melhor dia"):
			apoio_ontem = t
	if ultimo_resultado > 0:
		var fracao := "o melhor dia da partida" if ultimo_dia == int(melhor_dia[1]) \
			else "%d%% do melhor dia" % int(round(100.0 * ultimo_resultado / float(melhor_dia[0])))
		_confere("F15 recordes: a barra de ontem é %s contra o melhor dia %s («%s»)" % [
			GS.moeda(ultimo_resultado), GS.moeda(int(melhor_dia[0])), apoio_ontem],
			barra_ontem != null and int(barra_ontem.value) == ultimo_resultado
				and int(barra_ontem.max_value) == int(melhor_dia[0]) and apoio_ontem.ends_with(fracao))
	else:
		_confere("F15 recordes: ontem sem lucro, a tarja não tem barra", barra_ontem == null)
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
	while int(GS.turn) < int(GS.dia_da_parcela(0)) and voltas < 200:
		if GS.phase == "rival_offer":
			GS.resolve_rival_offer(true)
		_atracar_tudo()
		GS.advance_turn()
		voltas += 1
	if GS.phase == "rival_offer":
		GS.resolve_rival_offer(true)
	_confere("F15 dia 32: a partida chega ao dia do vencimento a jogar",
		int(GS.turn) == int(GS.dia_da_parcela(0)) and GS.phase == "playing",
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
		int(r["melhor_dia"]["turno"]) == int(GS.dia_da_parcela(0))
			and int(r["melhor_dia"]["valor"]) == resultado)
	_f15_dia32_ok = true


func _f15_reputacao() -> void:
	_f10_partida_nova("F15")
	for rep in [76.6, 20.95, 64.3, 81.0, 100.0]:
		GS.reputation = rep
		var painel: Node = await _f10_abrir(F15_REPUTACAO, [])
		var bloco := painel.find_child("Comercial", true, false)
		var valor := (bloco.find_child("Valor", true, false) as Label).text if bloco else ""
		var proximo := (bloco.find_child("Proximo", true, false) as Label).text if bloco else ""
		_confere("F15 reputação %.2f: o quadro diz o patamar do jogo («%s»)" % [rep, valor],
			valor.ends_with("— " + String(GS.reputation_label())))
		_f15_escada(painel, rep)
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


# A ESCADA DE BARRAS contra o `reputation_label()`, que é quem aplica os
# limiares no jogo: o piso de cada degrau é onde o nome dele COMEÇA (um pouco
# acima já é ele, um pouco abaixo ainda não), o teto é o piso do de cima, a
# barra está no número do jogo, e só o degrau do nome atual leva o «▸».
func _f15_escada(painel: Node, rep: float) -> void:
	var degraus: Array = []
	for filho in painel.find_children("Degrau*", "HBoxContainer", true, false):
		degraus.append(filho)
	_confere("F15 reputação %.2f: a escada tem os cinco degraus" % rep, degraus.size() == 5,
		"%d degraus" % degraus.size())
	var teto_esperado := 100.0
	var marcados := 0
	for d in degraus:
		var rotulo := (d as Node).get_child(0) as Label
		var barra := (d as Node).get_child(1) as ProgressBar
		var nome: String = rotulo.text.get_slice("· ", 1)
		var piso: float = barra.min_value
		GS.reputation = piso + 0.01
		var no_piso: String = GS.reputation_label()
		GS.reputation = piso - 0.01
		var abaixo: String = GS.reputation_label() if piso > 0.0 else ""
		GS.reputation = rep
		_confere("F15 reputação %.2f: o degrau «%s» começa onde o jogo o começa (%s)" % [rep, nome, str(piso)],
			no_piso == nome and abaixo != nome, "a %.2f o jogo diz %s, a %.2f diz %s" % [
				piso + 0.01, no_piso, piso - 0.01, abaixo])
		_confere("F15 reputação %.2f: «%s» vai até ao degrau de cima e está no número do jogo" % [rep, nome],
			is_equal_approx(barra.max_value, teto_esperado)
				and is_equal_approx(barra.value, clampf(rep, piso, teto_esperado)))
		teto_esperado = piso
		if rotulo.text.begins_with("▸"):
			marcados += 1
			_confere("F15 reputação %.2f: o «▸» está no patamar do jogo" % rep,
				nome == String(GS.reputation_label()) and rotulo.theme_type_variation == &"RotuloAlerta")
	_confere("F15 reputação %.2f: um degrau marcado, e um só" % rep, marcados == 1, str(marcados))


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
		apoio.size() == 2 and int(apoio[0]) == int(GS.valor_da_parcela(0))
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
	var prazo := painel.find_child("Barra", true, false) as ProgressBar
	_confere("F15 calendário: a barra do prazo é o dia do jogo contra o fim da partida",
		prazo != null and int(prazo.value) == int(GS.turn) and int(prazo.max_value) == int(GS.turnos_da_fase()))
	_confere("F15 calendário: «%s» / «%s» são o dia e a semana do jogo" % [tarja, apoio],
		tarja == "Dia %d de %d" % [int(GS.turn), int(GS.turnos_da_fase())]
			and apoio.begins_with("Semana %d de %d" % [GS.current_week(), int(GS.semanas_da_fase())]))
	_f10_fechar(painel)
	_f15_calendario_ok = true



# ── F16 ─────────────────────────────────────────────────────────────────
# OS TRÊS ESPAÇOS DE SAVE E A TELA INICIAL (`docs/decisoes/066`).
#
# A família do sistema da frente 3 tirou o «Novo jogo (apaga progresso)» da
# pausa e pôs no lugar dele três espaços de save, uma tela inicial e um
# «Salvar e sair». Cada pergunta abaixo é o sítio onde a mudança podia perder
# uma partida SEM ERRO NENHUM — que é a única forma de falhar que um save tem:
#
#  - o espaço 1 é o ARQUIVO DE SEMPRE: se deixasse de o ser, a partida que o
#    jogador já tem sumia da tela inicial no dia da atualização;
#  - cada espaço grava no SEU arquivo, e começar num não apaga o outro;
#  - LER um espaço para o mostrar não toca no estado vivo nem no disco, e
#    recusa exatamente o que a carga recusa;
#  - o «Continuar» é o jogado por ÚLTIMO, e não o espaço em que o autoload
#    calhou de estar;
#  - a pausa não tem botão destrutivo, e apagar um porto pede o segundo toque.
#
# ⚠️ O BLOCO ESPERA UM SEGUNDO DUAS VEZES. Quem diz qual espaço foi jogado por
# último é a hora de modificação do arquivo, que tem um segundo de resolução
# — duas gravações no mesmo segundo EMPATAM, e o empate não prova ordem
# nenhuma. São ~2,2 s numa suíte que corre em dezenas.
var _f16_terminou := false


func _f16_os_espacos_de_save() -> void:
	for n in range(1, GS.ESPACOS + 1):
		GS.apagar_espaco(n)

	# ── o espaço 1 é o arquivo de sempre ──
	_confere("F16: o espaço 1 grava no arquivo que o save sempre teve (%s)" % GS.SAVE_ARQUIVO,
		GS.arquivo_do_espaco(1) == "savegame.json" and GS.SAVE_ARQUIVO == "savegame.json",
		GS.arquivo_do_espaco(1))
	var nomes := {}
	for n in range(1, GS.ESPACOS + 1):
		nomes[GS.arquivo_do_espaco(n)] = true
	_confere("F16: os %d espaços gravam em %d arquivos diferentes" % [GS.ESPACOS, nomes.size()],
		nomes.size() == GS.ESPACOS, ", ".join(nomes.keys()))

	# ── cada espaço no seu arquivo ──
	_f16_porto(1, "Um", 111)
	_f16_porto(2, "Dois", 222)
	GS.usar_espaco(1)
	_confere("F16: carregar o espaço 1 traz o porto dele (%s, %s)" % [GS.nome_porto, GS.moeda(GS.cash)],
		GS.espaco == 1 and GS.nome_porto == "Um" and GS.cash == 111)
	GS.usar_espaco(2)
	_confere("F16: carregar o espaço 2 traz o porto dele (%s, %s)" % [GS.nome_porto, GS.moeda(GS.cash)],
		GS.espaco == 2 and GS.nome_porto == "Dois" and GS.cash == 222)

	# ── começar num espaço não apaga o outro ──
	# Estado vivo no espaço 2; a partida nova vai para o 3. Um `clear_save()`
	# que corresse ANTES de apontar para o 3 apagaria o 2.
	GS.comecar_no_espaco(3)
	_confere("F16: começar no espaço 3 deixa o 2 como estava",
		String(GS.resumo_do_espaco(2).get("porto", "")) == "Dois",
		str(GS.resumo_do_espaco(2)))
	_confere("F16: e o 1 também", String(GS.resumo_do_espaco(1).get("porto", "")) == "Um")

	# ── o porto sem nome lê-se como livre ──
	_confere("F16: o espaço 3, começado e ainda sem nome, lê-se livre",
		GS.resumo_do_espaco(3).is_empty(), str(GS.resumo_do_espaco(3)))

	# ── ler não toca em nada, e recusa o que a carga recusa ──
	GS.usar_espaco(1)
	var vivo := [GS.espaco, GS.nome_porto, GS.cash, GS.turn]
	var outra_versao := _save_valido(GS.SAVE_VERSAO_MINIMA - 1)
	outra_versao["nome_porto"] = "Velho"
	_f16_escrever_espaco(3, JSON.stringify(outra_versao))
	_confere("F16: um espaço de versão que a cadeia não lê lê-se livre",
		GS.resumo_do_espaco(3).is_empty(), str(GS.resumo_do_espaco(3)))
	_confere("F16: e LER não o apaga — quem o apaga é a partida nova que o ocupar",
		FileAccess.file_exists(ArmazemLocal.caminho(GS.arquivo_do_espaco(3))))
	var sem_roster := _save_valido(GS.SAVE_VERSION)
	sem_roster["nome_porto"] = "Truncado"
	sem_roster["docks"] = []
	_f16_escrever_espaco(3, JSON.stringify(sem_roster))
	_confere("F16: um espaço que a carga recusa (sem docas) lê-se livre, e não como porto",
		GS.resumo_do_espaco(3).is_empty(), str(GS.resumo_do_espaco(3)))
	_confere("F16: ler os três não mexeu no estado vivo (espaço, porto, dinheiro, dia)",
		[GS.espaco, GS.nome_porto, GS.cash, GS.turn] == vivo,
		"%s → %s" % [vivo, [GS.espaco, GS.nome_porto, GS.cash, GS.turn]])
	GS.apagar_espaco(3)
	var r1: Dictionary = GS.resumo_do_espaco(1)
	_confere("F16: o resumo do espaço 1 é o que o save diz (%s)" % GS.linha_do_espaco(r1) if not r1.is_empty() else "F16: o resumo do espaço 1 existe",
		not r1.is_empty() and int(r1["espaco"]) == 1 and String(r1["porto"]) == "Um"
			and int(r1["dinheiro"]) == 111 and int(r1["turno"]) == GS.turn)

	# ── o mais recente é o último gravado ──
	# Os saves do 1 e do 2 foram gravados no mesmo segundo; a espera é o que
	# faz o SEGUNDO ser mais novo de verdade.
	OS.delay_msec(1100)
	_f16_porto(2, "Dois", 222)
	_confere("F16: o jogado por último é o 2 (%d)" % GS.espaco_mais_recente(),
		GS.espaco_mais_recente() == 2)
	OS.delay_msec(1100)
	_f16_porto(1, "Um", 111)
	_confere("F16: e passa a ser o 1 quando o 1 volta a gravar (%d)" % GS.espaco_mais_recente(),
		GS.espaco_mais_recente() == 1)
	_confere("F16: com o 1 e o 2 ocupados, o primeiro livre é o 3",
		GS.primeiro_espaco_livre() == 3)

	_f16_tela_inicial()
	_f16_pausa()
	_f16_painel_dos_espacos()
	_f16_registro()

	for n in range(1, GS.ESPACOS + 1):
		GS.apagar_espaco(n)
	GS.comecar_no_espaco(1)
	_f16_terminou = true


# Um porto com nome e dinheiro no espaço `n`, gravado. O dinheiro escreve-se
# à mão porque a pergunta aqui é de ARQUIVO — que número volta de cada espaço —,
# e não do que o jogo faz com ele.
func _f16_porto(n: int, porto: String, dinheiro: int) -> void:
	GS.comecar_no_espaco(n)
	if GS.phase == "rival_offer":
		GS.resolve_rival_offer(true)
	GS.definir_nomes(porto, "")
	GS.cash = dinheiro
	GS.save_game()


func _f16_escrever_espaco(n: int, texto: String) -> void:
	var f := FileAccess.open(ArmazemLocal.caminho(GS.arquivo_do_espaco(n)), FileAccess.WRITE)
	f.store_string(texto)
	f.close()


func _f16_textos_de_botao(no: Node, saida: Array) -> void:
	if no is Button and not no.is_queued_for_deletion():
		saida.append((no as Button).text)
	for filho in no.get_children():
		_f16_textos_de_botao(filho, saida)


func _f16_botao(no: Node, texto: String) -> Button:
	if no is Button and (no as Button).text == texto:
		return no
	for filho in no.get_children():
		var achado := _f16_botao(filho, texto)
		if achado != null:
			return achado
	return null


# A TELA INICIAL lê os espaços do disco. O «Continuar» é o jogado por último
# — e o estado vivo está AGORA num espaço que não é esse, de propósito: uma
# tela que perguntasse pelo `GS.espaco` mostraria o porto errado.
func _f16_tela_inicial() -> void:
	GS.usar_espaco(2)   # carregar não grava: o 1 continua o mais recente
	var cena: Node = (load("res://scenes/TelaInicial.tscn") as PackedScene).instantiate()
	root.add_child(cena)
	var textos: Array = []
	_f16_textos_de_botao(cena, textos)
	var ultima := cena.find_child("UltimaPartida", true, false) as Label
	_confere("F16 tela inicial: com portos guardados há Continuar, Nova partida, Carregar e Ajustes",
		textos == ["Continuar", "Nova partida", "Carregar", "Ajustes"], str(textos))
	_confere("F16 tela inicial: «%s» é o porto jogado por último, não o espaço em uso" % (ultima.text if ultima else "?"),
		ultima != null and ultima.text.contains("Um") and not ultima.text.contains("Dois"))
	root.remove_child(cena)
	cena.free()

	# E sem porto nenhum não há o que continuar nem carregar.
	var guardados := [GS.resumo_do_espaco(1), GS.resumo_do_espaco(2)]
	for n in range(1, GS.ESPACOS + 1):
		GS.apagar_espaco(n)
	var vazia: Node = (load("res://scenes/TelaInicial.tscn") as PackedScene).instantiate()
	root.add_child(vazia)
	textos.clear()
	_f16_textos_de_botao(vazia, textos)
	_confere("F16 tela inicial: sem porto guardado há só Nova partida e Ajustes",
		textos == ["Nova partida", "Ajustes"], str(textos))
	root.remove_child(vazia)
	vazia.free()
	# Os dois portos voltam, pela mesma porta, para os blocos seguintes.
	_f16_porto(1, String(guardados[0]["porto"]), int(guardados[0]["dinheiro"]))
	_f16_porto(2, String(guardados[1]["porto"]), int(guardados[1]["dinheiro"]))


# A PAUSA: três saídas e nenhuma destrutiva, e cada botão pede o que diz.
func _f16_pausa() -> void:
	var pausa: Node = (load("res://scenes/panels/PauseMenu.tscn") as PackedScene).instantiate()
	root.add_child(pausa)
	var textos: Array = []
	_f16_textos_de_botao(pausa, textos)
	_confere("F16 pausa: Continuar, Ajustes e Salvar e sair (%s)" % ", ".join(textos),
		textos.has("Continuar") and textos.has("Ajustes") and textos.has("Salvar e sair"))
	var destrutivo := textos.filter(func(t: String) -> bool:
		return t.containsn("novo jogo") or t.containsn("apaga"))
	_confere("F16 pausa: nenhum botão apaga a partida", destrutivo.is_empty(), str(destrutivo))
	var pedidos: Array = []
	pausa.connect("sair_para_inicio", func() -> void: pedidos.append("sair"))
	pausa.connect("pedir_ajustes", func() -> void: pedidos.append("ajustes"))
	pausa.connect("ver_balanco", func() -> void: pedidos.append("balanco"))
	_f16_botao(pausa, "Salvar e sair").pressed.emit()
	_f16_botao(pausa, "Ajustes").pressed.emit()
	_confere("F16 pausa: «Salvar e sair» pede a tela inicial e «Ajustes» pede os ajustes (%s)" % [pedidos],
		pedidos == ["sair", "ajustes"])
	root.remove_child(pausa)
	pausa.free()


# O PAINEL DOS ESPAÇOS: o livre não é botão ao carregar, e «Substituir» NÃO
# apaga — leva à confirmação, que é quem escolhe.
func _f16_painel_dos_espacos() -> void:
	var cena := load("res://scenes/panels/PainelEspacos.tscn") as PackedScene
	var carregar: Node = cena.instantiate()
	root.add_child(carregar)
	carregar.call("setup", "carregar")
	var acoes := carregar.find_children("Acao", "Button", true, false)
	_confere("F16 espaços: ao carregar, só os %d ocupados são botão (%d)" % [2, acoes.size()],
		acoes.size() == 2)
	root.remove_child(carregar)
	carregar.free()

	var nova: Node = cena.instantiate()
	root.add_child(nova)
	nova.call("setup", "nova")
	var escolhas: Array = []
	nova.connect("escolhido", func(n: int, modo: String) -> void: escolhas.append([n, modo]))
	var textos: Array = []
	_f16_textos_de_botao(nova, textos)
	_confere("F16 espaços: na partida nova os ocupados dizem «Substituir» e o livre «Começar aqui»",
		textos.count("Substituir") == 2 and textos.count("Começar aqui") == 1, str(textos))
	var substituir := nova.find_child("Espaco1", true, false).find_child("Acao", true, false) as Button
	substituir.pressed.emit()
	_confere("F16 espaços: «Substituir» não escolhe nada — pergunta antes (%s)" % String(nova.get("tempo")),
		escolhas.is_empty() and nova.get("tempo") == &"confirmar", str(escolhas))
	_confere("F16 espaços: e o porto que ia apagar continua no disco",
		String(GS.resumo_do_espaco(1).get("porto", "")) == "Um")
	_f16_botao(nova, "Apagar e começar").pressed.emit()
	_confere("F16 espaços: o segundo toque escolhe o espaço 1 para a partida nova (%s)" % [escolhas],
		escolhas == [[1, "nova"]])
	if is_instance_valid(nova):
		root.remove_child(nova)
		nova.free()


# O GRAVADOR DESARMA sem perder o caminho: a Ajustes da tela inicial copia a
# última partida jogada, e o que a tela inicial faz ao estado não entra nela.
func _f16_registro() -> void:
	var registro: Node = root.get_node("Registro")
	# ⚠️ PELO `Main`, E NÃO PELO `Registro`: a pergunta é se QUEM SAI desarma.
	# Provar só o `desarmar()` deixava passar um `_sair_para_inicio()` que se
	# esquecesse de o chamar — a guarda que escreve ela própria o estado prova
	# a leitura, não a escrita (`052`). A troca de cena que ele pede fica para
	# o fim do frame, depois de a suíte já ter acabado.
	var main: Node = (load("res://scenes/Main.tscn") as PackedScene).instantiate()
	root.add_child(main)
	_confere("F16 registro: o porto arma o gravador ao abrir", registro.armado())
	var caminho: String = registro.caminho_legivel()
	main.call("_sair_para_inicio")
	_confere("F16 registro: «Salvar e sair» desarma o gravador", not registro.armado())
	root.remove_child(main)
	main.free()
	# ⚠️ UM DIA JOGADO, e não só a partida nova. A primeira versão perguntava
	# pelo `comecar_no_espaco()` e mais nada — e com o gravador ARMADO passou na
	# mesma, porque aquele `new_game()` não calhou de emitir nada que ele grave
	# (medido com o `desarmar()` esvaziado: esta linha ficou verde). A virada
	# do dia grava sempre uma linha, armado; desarmado, nenhuma.
	var linhas_antes: int = registro.linhas_gravadas()
	GS.comecar_no_espaco(3)
	if GS.phase == "rival_offer":
		GS.resolve_rival_offer(true)
	GS.advance_turn()
	_confere("F16 registro: depois de sair, nem um dia jogado entra no registro da partida deixada",
		registro.linhas_gravadas() == linhas_antes,
		"%d → %d" % [linhas_antes, registro.linhas_gravadas()])
	_confere("F16 registro: e a Ajustes ainda copia a última partida",
		registro.caminho_legivel() == caminho and registro.texto_para_exportar() != "")


# ── F17 ─────────────────────────────────────────────────────────────────
# A CONVERSA DO CELULAR (`docs/decisoes/067`). O histórico da faixa passou a
# ser uma conversa com três vozes, e cada peça dela vem de um sítio que nada
# obrigava a concordar com a conversa:
#
#  1. O ASSUNTO DE CADA AVISO sai de quem o emite (`GameState.message`, o
#     terceiro argumento), e o ícone dele de uma tabela na `PainelMensagens`.
#     São dois arquivos: um assunto novo sem ícone rebentaria na conversa, e
#     um ícone sem quem o emita é arte que ninguém vê — o `barco_medio` outra
#     vez. As duas direções perguntam-se aqui, e a leitura é do ARQUIVO
#     INTEIRO: as chamadas partem-se em várias linhas, e a conta por dois
#     caminhos (quantas vezes o nome aparece contra quantas se leram) é o que
#     faz uma forma nova de chamada reprovar em vez de escapar (`037`).
#  2. A FALA DE UM PAINEL chega ao histórico pelo sinal `falou`, que o `Main`
#     liga no `_abrir_painel()` — e só lá. Uma fala que o painel mostra e o
#     histórico não guarda é «fala vista não é fala gravada», e nenhuma foto o
#     apanha: a conversa simplesmente não a tem. Pergunta-se ao HISTÓRICO,
#     pelo texto que o PAINEL mostra — dois nós, e não um espelho.
#  3. E A GRAVAÇÃO NÃO PASSA PELA FAIXA: a fala já está na tela do painel, e
#     dizê-la outra vez por baixo seria duas vezes a mesma frase.
var _f17_terminou := false
const F17_FONTES := {
	"res://autoload/GameState.gd": "message.emit(",
	"res://scripts/Main.gd": "_on_message(",
}


func _f17_a_conversa() -> void:
	var Msg: GDScript = load("res://scripts/PainelMensagens.gd")
	var icones: Dictionary = Msg.get_script_constant_map()["ICONE_DO_ASSUNTO"]
	var emitidos := {}
	for arq in F17_FONTES:
		var nome: String = F17_FONTES[arq]
		var texto := FileAccess.get_file_as_string(arq)
		var vistas := 0
		var lidas := 0
		var i := texto.find(nome)
		while i >= 0:
			var inicio_linha := texto.rfind("\n", i) + 1
			var antes := texto.substr(inicio_linha, i - inicio_linha)
			# A definição não é uma chamada, e o comentário também não.
			if not antes.strip_edges().begins_with("#") and not antes.ends_with("func "):
				vistas += 1
				var assunto := _f17_ultimo_argumento(texto, i + nome.length())
				if assunto != "":
					lidas += 1
					emitidos[assunto] = true
			i = texto.find(nome, i + 1)
		_confere("F17: todo aviso de %s diz o assunto (%d chamadas, %d lidas)"
			% [arq.get_file(), vistas, lidas], vistas > 0 and vistas == lidas)
	for assunto in emitidos:
		_confere("F17: o assunto «%s» tem ícone na conversa" % assunto, icones.has(assunto))
	for assunto in icones:
		_confere("F17: o ícone de «%s» tem quem o emita" % assunto, emitidos.has(assunto))

	# ── 2 e 3: as falas dos painéis chegam ao histórico, com a cara.
	GS.clear_save()
	GS.new_game()
	GS.definir_nomes("Cais de Teste", "")
	if GS.phase == "rival_offer":
		GS.resolve_rival_offer(true)
	var main: Node = (load("res://scenes/Main.tscn") as PackedScene).instantiate()
	root.add_child(main)
	var fila = main.get("_fila")
	_confere("F17: o Main tem a fila das mensagens", fila != null)
	if fila == null:
		main.free()
		return
	# A faixa como está ANTES das falas — e é conferida antes de a oferta se
	# resolver no fim, que emite um aviso de verdade para ela.
	var na_tela: Dictionary = fila.atual()
	var a_espera: int = fila.pendentes()

	var ribeiro: Control = main.call("_abrir_painel",
		load("res://scenes/panels/DebtPaymentPanel.tscn"))
	ribeiro.call("setup", int(GS.valor_da_parcela(0)))
	_f17_gravou(fila, "ribeiro", String(ribeiro.call("texto_da_fala")),
		Narrativa.retrato("ribeiro", "a_divida"))

	var boletim: Control = main.call("_abrir_painel",
		load("res://scenes/panels/PainelBoletim.tscn"))
	boletim.call("setup", GS.resumo_da_semana(1))
	var tom: String = Narrativa.tom_do_boletim(GS.resumo_da_semana(1))
	_f17_gravou(fila, "cida", Narrativa.boletim(tom), Narrativa.retrato("cida", tom))

	GS.fila = [GS._make_boat()]
	GS.pending_rival = 0
	GS.rival_attempts_left = GS.RIVAL_PATIENCE
	GS._set_phase("rival_offer")
	var arlindo: Control = main.call("_abrir_painel",
		load("res://scenes/panels/CounterOfferPanel.tscn"))
	arlindo.call("setup", 0)
	_f17_gravou(fila, "arlindo", String(arlindo.call("texto_da_fala")),
		Narrativa.retrato("arlindo", "abertura"))

	_confere("F17: gravar as falas não mexeu na faixa",
		fila.atual() == na_tela and fila.pendentes() == a_espera,
		"a faixa mostra «%s» e tem %d à espera (antes: %d)" % [
			String(fila.atual().get("texto", "")), fila.pendentes(), a_espera])
	GS.resolve_rival_offer(true)

	main.free()
	_f17_terminou = true


# A entrada mais recente do histórico é a fala que o painel acabou de mostrar,
# de quem a disse e com a cara que o painel lhe pôs.
func _f17_gravou(fila: Variant, quem: String, texto: String, cara: Texture2D) -> void:
	var h: Array = fila.historico
	var ultima: Dictionary = h[0] if not h.is_empty() else {}
	_confere("F17: a fala do painel de «%s» está no histórico" % quem,
		not ultima.is_empty() and String(ultima["fonte"]) == quem
			and String(ultima["texto"]) == texto and texto != "",
		"a mais recente é de «%s»: %s" % [String(ultima.get("fonte", "")),
			String(ultima.get("texto", "")).left(40)])
	_confere("F17: e com a cara dessa fala (%s)" % quem,
		not ultima.is_empty() and ultima["retrato"] == cara and cara != null)


# O último argumento de uma chamada, se for uma string literal — com os
# parênteses EQUILIBRADOS e as aspas respeitadas: `moeda(valor)` e `%` dentro
# dos argumentos partiriam uma expressão que parasse no primeiro fecho.
func _f17_ultimo_argumento(texto: String, desde: int) -> String:
	var fundo := 1
	var em_aspas := false
	var j := desde
	var ultima_virgula := desde - 1
	while j < texto.length() and fundo > 0:
		var c := texto[j]
		if c == "\"" and texto[j - 1] != "\\":
			em_aspas = not em_aspas
		elif not em_aspas:
			if c == "(" or c == "[":
				fundo += 1
			elif c == ")" or c == "]":
				fundo -= 1
			elif c == "," and fundo == 1:
				ultima_virgula = j
		j += 1
	var ultimo := texto.substr(ultima_virgula + 1, j - 1 - (ultima_virgula + 1)).strip_edges()
	if ultimo.length() >= 2 and ultimo.begins_with("\"") and ultimo.ends_with("\""):
		return ultimo.substr(1, ultimo.length() - 2)
	return ""



# ── F18 ─────────────────────────────────────────────────────────────────
# O PRAZO DA OBRA, PROMETIDO E CUMPRIDO (`090`, a resposta do Bruno ao D8).
#
# A `087` aceita a obra que só fica pronta no fecho do último dia, e até 10/10
# a mensagem dizia «pronto no dia 85» numa fase de 84 dias — o jogador pagava
# o preço inteiro por um porto que não chegava a usar, sem aviso nenhum. O
# Bruno respondeu AVISAR: no Construir, antes de comprar, e na mensagem.
#
# ⚠️ A FRONTEIRA DERIVA-SE DO JOGO, e não se escreve: o último dia em que cada
# reparo se compra sai do `impedimento_estrutura()`, andando o calendário de
# trás para a frente. E prova-se dos DOIS lados, como a `089` fez com a
# abertura — no último dia o aviso aparece e é verdade (a estrutura não está
# de pé em dia nenhum da fase); na véspera não aparece, e o «pronto no dia N»
# da mensagem é o dia em que ela fica de pé, lido no jogo e não no texto.
#
# ⚠️ E PELA PORTA DO JOGADOR: o toque no botão do cartão, e o cartão lido
# outra vez depois de o painel se remontar. O texto «com a obra a andar» é um
# terceiro leitor do prazo, e foi lá que o «dia 85» também morava.
const F18_CONSTRUIR := "res://scenes/panels/UpgradePanel.tscn"
const F18_AVISO := "não será usado nesta fase"
var _f18_terminou := false
var _f18_mensagens: Array = []


func _f18_a_obra_prometida() -> void:
	var ouvinte := func(texto: String, kind: String, _assunto: String):
		_f18_mensagens.append([texto, kind])
	GS.message.connect(ouvinte)
	var reparos := []
	for id in GS.ESTRUTURAS:
		if GS.dias_da_obra(String(id)) > 0 and not GS.abertura_do_reparo(String(id)).is_empty():
			reparos.append(String(id))
	# Os três de hoje; a contagem só garante que a derivação achou alguém.
	_confere("F18: há reparos com prazo de obra nesta fase", reparos.size() >= 3,
		str(reparos))
	var ultimos := {}
	for id in reparos:
		var ultimo := _f18_ultimo_dia_de_compra(id)
		ultimos[id] = ultimo
		if ultimo < 2:
			_confere("F18 %s: há um último dia de compra e uma véspera dele" % id, false,
				"último dia %d" % ultimo)
			continue
		var cumpriu: bool = await _f18_sem_uso(id, ultimo)
		if not cumpriu:
			continue
		await _f18_com_uso(id, ultimo - 1)
	await _f18_rodape(ultimos)
	GS.message.disconnect(ouvinte)
	GS.clear_save()
	GS._rng.seed = F10_SEMENTE
	GS.new_game()
	_f18_terminou = true


# O estado do fim da fase: duas cobranças quitadas e a terceira por vencer, que
# é o porto que o jogador tem nos dias 57 a 84. Dinheiro de sobra, para o
# impedimento que aperta ser o do CALENDÁRIO e não o do caixa.
func _f18_fim_de_fase(dia: int) -> void:
	_f10_partida_nova("F18")
	if GS.phase == "rival_offer":
		GS.resolve_rival_offer(true)
	GS.cash = 50000000
	GS.parcela_indice = GS.parcelas_na_fase() - 1
	GS.parcelas_quitadas = GS.parcelas_na_fase() - 1
	GS.turn = dia


func _f18_ultimo_dia_de_compra(id: String) -> int:
	_f18_fim_de_fase(GS.turnos_da_fase() + 1)
	for dia in range(GS.turnos_da_fase() + 1, 0, -1):
		GS.turn = dia
		if GS.impedimento_estrutura(id) == "":
			return dia
	return -1


# O cartão de uma estrutura, achado pelo NOME que ele mostra.
func _f18_cartao(painel: Node, id: String) -> Node:
	var nome := String(GS.ESTRUTURAS[id]["nome"])
	for rotulo in painel.find_children("*", "Label", true, false):
		if (rotulo as Label).text == nome:
			var no: Node = rotulo
			while no != null and not (no is PanelContainer):
				no = no.get_parent()
			return no
	return null


func _f18_texto(cartao: Node) -> String:
	var textos := PackedStringArray()
	for rotulo in cartao.find_children("*", "Label", true, false):
		textos.append((rotulo as Label).text)
	return " | ".join(textos)


# Compra pelo botão do cartão e devolve a mensagem da compra, `[texto, kind]`.
func _f18_comprar(painel: Node, id: String) -> Array:
	var cartao := _f18_cartao(painel, id)
	var botao: Button = null
	if cartao != null:
		for b in cartao.find_children("*", "Button", true, false):
			if (b as Button).text.begins_with("Construir"):
				botao = b
	if botao == null:
		_confere("F18 %s: o cartão tem o botão de construir" % id, false)
		return []
	_f18_mensagens.clear()
	botao.pressed.emit()
	await _f8_esperar()
	var prefixo := "%s — obra iniciada" % GS.ESTRUTURAS[id]["nome"]
	for m in _f18_mensagens:
		if String(m[0]).begins_with(prefixo):
			return m
	_confere("F18 %s: a compra deu a mensagem da obra" % id, false, str(_f18_mensagens))
	return []


# O ÚLTIMO DIA: o aviso antes de comprar, na mensagem e na obra a andar — e é
# verdade, porque a estrutura não fica de pé em dia nenhum da fase.
func _f18_sem_uso(id: String, dia: int) -> bool:
	_f18_fim_de_fase(dia)
	var inexistente := "dia %d" % (GS.turnos_da_fase() + 1)
	var painel: Node = await _f10_abrir(F18_CONSTRUIR, [])
	var cartao := _f18_cartao(painel, id)
	if cartao == null:
		_confere("F18 %s: o Construir tem o cartão" % id, false)
		_f10_fechar(painel)
		return false
	var antes := _f18_texto(cartao)
	var aviso := cartao.find_child("AvisoObraSemUso", true, false) as Label
	_confere("F18 %s, dia %d: o Construir avisa ANTES de comprar, em âmbar" % [id, dia],
		aviso != null and aviso.text.contains(F18_AVISO)
			and aviso.theme_type_variation == &"RotuloAlerta", antes)
	_confere("F18 %s, dia %d: e não promete um dia que a fase não tem" % [id, dia],
		not antes.contains(inexistente), antes)
	var msg: Array = await _f18_comprar(painel, id)
	if msg.is_empty():
		_f10_fechar(painel)
		return false
	_confere("F18 %s, dia %d: a mensagem avisa, em tom de aviso" % [id, dia],
		String(msg[0]).contains(F18_AVISO) and String(msg[1]) == "warn", str(msg))
	_confere("F18 %s, dia %d: e a mensagem não diz «%s»" % [id, dia, inexistente],
		not String(msg[0]).contains(inexistente), String(msg[0]))
	await _f8_esperar()
	cartao = _f18_cartao(painel, id)
	var andando := _f18_texto(cartao) if cartao != null else ""
	_confere("F18 %s, dia %d: com a obra a andar, o cartão continua a avisar" % [id, dia],
		andando.contains("Em obra") and andando.contains(F18_AVISO)
			and not andando.contains(inexistente), andando)
	_f10_fechar(painel)
	# O AVISO É VERDADE: nenhum dia jogável a vê de pé, e o fecho do último a
	# conclui (`087`) — é o «fim do dia» que o texto promete.
	_f8_avancar_ate(GS.turnos_da_fase())
	_confere("F18 %s: no dia %d, o último da fase, a obra ainda não está de pé"
		% [id, GS.turnos_da_fase()], GS.turn == GS.turnos_da_fase() and not GS.tem_estrutura(id),
		"dia %d, de pé %s" % [GS.turn, str(GS.tem_estrutura(id))])
	if GS.phase == "rival_offer":
		GS.resolve_rival_offer(true)
	GS.advance_turn()
	_confere("F18 %s: e fica pronta no fecho dele" % id,
		GS.turn == GS.turnos_da_fase() + 1 and GS.tem_estrutura(id),
		"dia %d, de pé %s" % [GS.turn, str(GS.tem_estrutura(id))])
	return true


# A VÉSPERA: sem aviso, e o «pronto no dia N» é o dia em que ela fica de pé.
func _f18_com_uso(id: String, dia: int) -> void:
	_f18_fim_de_fase(dia)
	var painel: Node = await _f10_abrir(F18_CONSTRUIR, [])
	var cartao := _f18_cartao(painel, id)
	var antes := _f18_texto(cartao) if cartao != null else ""
	_confere("F18 %s, dia %d: na véspera o Construir não avisa" % [id, dia],
		cartao != null and cartao.find_child("AvisoObraSemUso", true, false) == null
			and not antes.contains(F18_AVISO), antes)
	var msg: Array = await _f18_comprar(painel, id)
	if msg.is_empty():
		_f10_fechar(painel)
		return
	var re := RegEx.new()
	re.compile("pronto no dia (\\d+)")
	var achou := re.search(String(msg[0]))
	_confere("F18 %s, dia %d: a mensagem é boa e diz o dia, sem aviso" % [id, dia],
		achou != null and String(msg[1]) == "good" and not String(msg[0]).contains(F18_AVISO),
		str(msg))
	if achou == null:
		_f10_fechar(painel)
		return
	var prometido := int(achou.get_string(1))
	await _f8_esperar()
	cartao = _f18_cartao(painel, id)
	var andando := _f18_texto(cartao) if cartao != null else ""
	_confere("F18 %s, dia %d: o cartão da obra a andar promete o mesmo dia %d"
		% [id, dia, prometido],
		andando.contains("pronto no dia %d" % prometido) and not andando.contains(F18_AVISO),
		andando)
	_f10_fechar(painel)
	_confere("F18 %s: o dia prometido (%d) é um dia da fase" % [id, prometido],
		prometido <= GS.turnos_da_fase())
	_f8_avancar_ate(prometido - 1)
	var na_vespera: bool = GS.tem_estrutura(id)
	_f8_avancar_ate(prometido)
	_confere("F18 %s: de pé no dia %d e não antes" % [id, prometido],
		GS.turn == prometido and GS.tem_estrutura(id) and not na_vespera,
		"dia %d, de pé %s, na véspera %s" % [GS.turn, str(GS.tem_estrutura(id)), str(na_vespera)])



# O RODAPÉ CONTA O QUE O PAINEL DEIXA COMPRAR (O7, `090`). Até 10/10 ele
# contava só o que o calendário abria, e no dia 84 dizia «3 disponíveis» com
# os três cartões a responder «Não termina nesta fase.».
#
# ⚠️ A SEGUNDA FONTE É O PAINEL — os botões «Construir ·» que ele monta —, e
# não a função que o rodapé lê, senão a guarda seria o espelho dela. Com
# dinheiro de sobra e sem obra a andar, um botão só falta pelo calendário, que
# é a pergunta. Os dias vão da véspera do primeiro último dia ao fim da fase:
# a contagem tem de MUDAR lá dentro (3, 2, 0), senão a fronteira não foi
# atravessada.
#
# E o dinheiro, à parte, que é a outra metade da regra: sem caixa o painel
# tira os botões («Faltam R$…») e o rodapé NÃO desce — ele diz o que o
# calendário deixa, e quem não pode pagar lê o porquê no cartão.
func _f18_rodape(ultimos: Dictionary) -> void:
	var primeiro: int = GS.turnos_da_fase()
	for id in ultimos:
		primeiro = mini(primeiro, int(ultimos[id]) - 1)
	_f18_fim_de_fase(primeiro)
	GS.definir_nomes(GS.NOME_PORTO_PADRAO, "")
	var main: Node = (load("res://scenes/Main.tscn") as PackedScene).instantiate()
	root.add_child(main)
	await _f8_esperar()
	var contagens := {}
	for dia in range(primeiro, GS.turnos_da_fase() + 1):
		GS.turn = dia
		GS.obra_em_andamento = {}
		GS.cash = 50000000
		var rodape := _f18_contagem_do_rodape(main)
		var painel: Node = await _f10_abrir(F18_CONSTRUIR, [])
		var botoes := 0
		for b in painel.find_children("*", "Button", true, false):
			if (b as Button).text.begins_with("Construir ·"):
				botoes += 1
		_f10_fechar(painel)
		contagens[rodape] = true
		_confere("F18 rodapé, dia %d: conta %d disponíveis e o painel tem %d para construir"
			% [dia, rodape, botoes], rodape == botoes)
	_confere("F18 rodapé: a contagem muda dentro dos dias percorridos",
		contagens.size() >= 2, str(contagens.keys()))
	GS.turn = primeiro
	GS.cash = 50000000
	var com_dinheiro := _f18_contagem_do_rodape(main)
	GS.cash = 0
	var sem_dinheiro := _f18_contagem_do_rodape(main)
	_confere("F18 rodapé, dia %d: sem dinheiro o rodapé não desce (%d com, %d sem)"
		% [primeiro, com_dinheiro, sem_dinheiro],
		com_dinheiro > 0 and sem_dinheiro == com_dinheiro)
	main.free()


# O número do rodapé do Construir, lido no botão do `Main`: «N disponíveis»,
# ou zero quando ele manda «ver estruturas». −1 se não for nenhum dos dois,
# para um texto novo reprovar em vez de passar por zero.
func _f18_contagem_do_rodape(main: Node) -> int:
	main._refresh_hud()
	var texto := String(main._upgrade_button.text)
	var re := RegEx.new()
	re.compile("(\\d+) disponíve")
	var achou := re.search(texto)
	if achou != null:
		return int(achou.get_string(1))
	return 0 if texto.contains("ver estruturas") else -1


# ── F19 ─────────────────────────────────────────────────────────────────
# TODO NOME QUE AS SUÍTES E AS FERRAMENTAS LEEM POR STRING EXISTE NO ALVO
# (`docs/decisoes/093`, M6 da revisão de 09/10).
#
# Testes e ferramentas leem membros PRIVADOS do `Main`, do `Dock` e de painéis
# pelo nome escrito numa string — `doca.get("_tw_trabalho")` e afins. Medido
# numa sonda em 10/10: o `get`, o `set`, o `in` e o `has_method` de um nome
# que não existe devolvem `null`/`false` CALADOS; só o `call` grita, e aborta
# a função. E medido nas suítes, renomeando doze desses membros um a um:
# sete reprovaram por uma asserção qualquer, cinco deixaram o marcador verde
# com `SCRIPT ERROR` que só a varredura do CI apanha — e NENHUM dos doze disse
# que nome mudou. O erro aponta para a linha do teste que usou o `null`
# («Nonexistent 'Vector2' constructor»), ou rebenta em cascata dentro do
# `Dock.gd`, longe da causa. E das ferramentas que também leem assim, a da
# captura só corre na bateria, e o `medir_transito` e o `medir_fila_mensagens`
# não correm em CI nenhum.
#
# É a pré-condição do M8, que parte o `Main`: mover o tráfego dos camiões para
# outro script deixa o NOME a existir no projeto e a faltar no `Main`, e é ao
# `Main` que a suíte o pede. Por isso a pergunta é «existe NO ALVO», com o
# tipo que a leitura pede — `get`, `set` e `in` querem uma variável; `call`,
# `callv` e `has_method`, um método —, e quem responde é a REFLEXÃO do script
# da raiz da cena, não uma leitura do texto dele.
#
# ⚠️ O TEXTO DIZ O NOME, NÃO A QUEM ELE É PEDIDO. A declaração
# (`tests/nomes_lidos_por_string.json`) diz, por arquivo, que variável é que
# alvo; nenhum nome se lista lá à mão. E a varredura conta por DOIS caminhos:
# cada leitura que a expressão lê, e cada literal com cara de privado
# (`"_x"`) no arquivo. O literal que nenhuma leitura explica reprova — é o
# que impede uma forma nova (`(tela as Control).get(...)`, um `call_deferred`)
# de escapar calada, como as cinco chamadas partidas por linha escapavam ao
# F9 (`037`).
#
# ⚠️ O QUE ELE NÃO VÊ: o nome PÚBLICO lido por string (`tela.call("trechos_de")`
# — API do script, e o `call` grita); o membro lido direto num nó destipado
# (`main._refresh_hud()` — também grita); o caminho de nó do
# `get_node`; e a variável com o nome de um alvo apontada a outra classe, que
# pediria o nome ao alvo errado, porque o tipo não se infere. Ver a `093`.
#
# ⚠️ E ESTE BLOCO NÃO ESCREVE UM LITERAL PRIVADO NEM NOS SEUS PRÓPRIOS
# FIXTURES: este arquivo também é varrido, e o fixture escrito por extenso
# seria lido como uma leitura de verdade. Por isso as aspas entram por `%s`.
const F19_DECLARACAO := "res://tests/nomes_lidos_por_string.json"
const F19_PASTAS := ["res://tests", "res://tools", "res://scripts/validation", "res://scenes/tests"]
# Quem lê a declaração precisa destas quatro chaves; uma a faltar rebentaria o
# acesso direto lá em baixo, e a mensagem seria sobre um `Dictionary`.
const F19_CHAVES := ["alvos", "receptores", "indiretos", "nao_sao_membros"]
var _f19_terminou := false
var _f19_re_literal: RegEx
var _f19_re_direta: RegEx
var _f19_re_in: RegEx
var _f19_re_sem_nome: RegEx


func _f19_nomes_lidos_por_string() -> void:
	_f19_compilar()
	_confere("F19: as expressões reconhecem as formas que caçam, e só elas",
		_f19_prova_das_expressoes())

	var decl = JSON.parse_string(FileAccess.get_file_as_string(F19_DECLARACAO))
	var faltam := []
	if decl is Dictionary:
		for chave in F19_CHAVES:
			if not (decl as Dictionary).has(chave):
				faltam.append(chave)
	_confere("F19: a declaração lê-se e traz as quatro chaves",
		decl is Dictionary and faltam.is_empty(), "%s; faltam %s" % [F19_DECLARACAO, faltam])
	if not (decl is Dictionary) or not faltam.is_empty():
		return
	var alvos: Dictionary = decl["alvos"]
	var receptores: Dictionary = decl["receptores"]
	var indiretos: Array = decl["indiretos"]
	var nao_membros: Array = decl["nao_sao_membros"]

	var membros := {}
	var sem_membros := []
	for alvo in alvos:
		membros[alvo] = _f19_membros(String(alvos[alvo]))
		if (membros[alvo]["metodo"] as Dictionary).is_empty():
			sem_membros.append("%s (%s)" % [alvo, alvos[alvo]])
	_confere("F19: todo alvo tem um script com membros para perguntar",
		sem_membros.is_empty(), str(sem_membros))

	var arquivos: Array[String] = []
	for pasta in F19_PASTAS:
		_varrer_cenas(pasta, arquivos, ".gd")
	arquivos.sort()
	_confere("F19: a varredura achou as suítes e as ferramentas", arquivos.size() > 20,
		"achou %d" % arquivos.size())

	# Todo arquivo que a declaração nomeia tem de estar na varredura: um
	# caminho com erro de digitação deixaria o arquivo de verdade sem
	# receptores, e as leituras dele reprovariam pelo motivo errado.
	var fora := []
	var nomeados := receptores.keys()
	for entrada in indiretos + nao_membros:
		nomeados.append(entrada["arquivo"])
	for caminho in nomeados:
		if not arquivos.has(String(caminho)):
			fora.append(caminho)
	_confere("F19: todo arquivo da declaração está na varredura", fora.is_empty(), str(fora))

	var problemas := []
	var sem_dono := []
	var mortos := []
	var conferidos := {}
	var receptor_usado := {}
	var isentos_membros := []
	for caminho in arquivos:
		var curto := caminho.trim_prefix("res://")
		var lido := _f19_ler(_sem_comentarios(FileAccess.get_file_as_string(caminho)))
		var meus: Dictionary = receptores[caminho] if receptores.has(caminho) else {}
		var literais: Dictionary = lido["literais"]
		var contados := {}
		for d in lido["diretas"]:
			var recv: String = d[0]
			var op: String = d[1]
			var nome: String = d[2]
			contados[nome] = int(contados.get(nome, 0)) + 1
			var leitura := ("\"%s\" in %s" % [nome, recv]) if op == "in" \
				else ("%s.%s(\"%s\")" % [recv, op, nome])
			if not meus.has(recv):
				problemas.append("%s: %s — a declaração não diz que alvo é «%s»"
					% [curto, leitura, recv])
				continue
			receptor_usado[caminho + " " + recv] = true
			var alvo := String(meus[recv])
			var tipo := "propriedade" if op in ["get", "set", "in"] else "metodo"
			conferidos[alvo + "." + nome] = true
			if not membros.has(alvo):
				problemas.append("%s: «%s» aponta para o alvo «%s», que não existe" % [curto, recv, alvo])
			elif not (membros[alvo][tipo] as Dictionary).has(nome):
				problemas.append("%s: %s — o %s não tem %s com esse nome"
					% [curto, leitura, alvo, "a variável" if tipo == "propriedade" else "o método"])

		# O que este arquivo declara: as leituras sem o nome na chamada, e os
		# literais que não são membro de ninguém.
		var explicados := {}
		var chamadas := {}
		for ind in indiretos:
			if String(ind["arquivo"]) != caminho:
				continue
			var alvo := String(ind["alvo"])
			var tipo := String(ind["tipo"])
			for chamada in ind["chamadas"]:
				chamadas[String(chamada)] = false
			for nome in ind["nomes"]:
				explicados[String(nome)] = true
				conferidos[alvo + "." + String(nome)] = true
				if not membros.has(alvo) or not (membros[alvo] as Dictionary).has(tipo):
					problemas.append("%s: o indireto aponta para «%s»/«%s», que não existem"
						% [curto, alvo, tipo])
				elif not (membros[alvo][tipo] as Dictionary).has(String(nome)):
					var por := "procurado no código-fonte do alvo" if (ind["chamadas"] as Array).is_empty() \
						else "lido por " + ", ".join(PackedStringArray(ind["chamadas"]))
					problemas.append("%s: \"%s\" (%s) — o %s não tem %s com esse nome"
						% [curto, nome, por, alvo, "a variável" if tipo == "propriedade" else "o método"])
		for nm in nao_membros:
			if String(nm["arquivo"]) != caminho:
				continue
			var nome := String(nm["nome"])
			explicados[nome] = true
			for alvo in membros:
				for tipo in ["propriedade", "metodo"]:
					if (membros[alvo][tipo] as Dictionary).has(nome):
						isentos_membros.append("%s: \"%s\" está declarado como não-membro e o %s tem %s com esse nome"
							% [curto, nome, alvo, "a variável" if tipo == "propriedade" else "o método"])

		for site in lido["sem_nome"]:
			var recv := String(site).get_slice(".", 0)
			if not meus.has(recv):
				continue
			if chamadas.has(site):
				chamadas[site] = true
				receptor_usado[caminho + " " + recv] = true
			else:
				sem_dono.append("%s: %s — leitura sem o nome na chamada, e a declaração não a conhece"
					% [curto, site])
		for chamada in chamadas:
			if not chamadas[chamada]:
				mortos.append("%s: a chamada indireta «%s» já não existe" % [curto, chamada])

		# O SEGUNDO CAMINHO: cada literal com cara de privado tem de ser uma
		# leitura que a expressão leu, ou estar declarado. Menos literais do
		# que leituras é um valor impossível — a expressão leu o que não há.
		for nome in literais:
			var resto: int = int(literais[nome]) - int(contados.get(nome, 0))
			if resto < 0:
				problemas.append("%s: \"%s\" lido %d vezes e escrito %d — a contagem não fecha"
					% [curto, nome, int(contados[nome]), int(literais[nome])])
			elif resto > 0 and not explicados.has(nome):
				sem_dono.append("%s: \"%s\" fora de uma leitura que a guarda saiba ler (%d)"
					% [curto, nome, resto])
		for nome in explicados:
			var resto: int = int(literais.get(nome, 0)) - int(contados.get(nome, 0))
			if resto <= 0:
				mortos.append("%s: \"%s\" está declarado e já não aparece fora de uma leitura direta"
					% [curto, nome])

	for caminho in receptores:
		for recv in receptores[caminho]:
			if not receptor_usado.has(String(caminho) + " " + String(recv)):
				mortos.append("%s: o receptor «%s» já não lê nada por string"
					% [String(caminho).trim_prefix("res://"), recv])

	_confere("F19: todo nome lido por string existe no alvo, com o tipo que a leitura pede",
		problemas.is_empty(), _f19_agrupar(problemas))
	_confere("F19: todo literal com cara de privado é uma leitura lida ou está declarado",
		sem_dono.is_empty(), "\n    " + "\n    ".join(sem_dono))
	_confere("F19: nenhuma declaração está morta", mortos.is_empty(),
		"\n    " + "\n    ".join(mortos))
	# ⚠️ A ISENÇÃO É ONDE O DEFEITO CABE INTEIRO (`079`): um nome lido de
	# verdade declarado como «não é membro» nunca seria perguntado ao alvo.
	# Isto apanha a declaração errada enquanto o nome ainda existe, que é o
	# momento de a escrever; depois de ele mudar de nome, já não se distingue
	# de um sufixo, e quem segura é a revisão do JSON.
	_confere("F19: nenhum literal declarado como não-membro é membro de um alvo",
		isentos_membros.is_empty(), "\n    " + "\n    ".join(isentos_membros))
	var por_alvo := {}
	for chave in conferidos:
		var alvo := String(chave).get_slice(".", 0)
		por_alvo[alvo] = int(por_alvo.get(alvo, 0)) + 1
	# Medido em 10/10: 52 nomes — 38 do Main (oito deles indiretos), 12 do
	# Dock e um de cada painel. A revisão de 09/10 contava 38 (29, 7 e 2), sem
	# os indiretos; a varredura acha mais um no Main e cinco no Dock, que um
	# `grep` de linha também acha — a diferença não é a quebra de linha. O
	# piso prova que a varredura leu, não que nada mudou: o M8 vai tirar
	# leituras, e por isso fica abaixo da medida.
	# Medido em 11/10, com o trânsito fora do `Main` (`095`): 49 — 16 do Main,
	# 19 do Trafego, 12 do Dock e um de cada painel. Os três que faltam aos 52
	# passaram a chamadas públicas (`animar_caminhoes()`, `animar_retorno()`,
	# `docas_mudaram()`), lidas direto num objeto destipado, que gritam. O Trafego
	# entra no piso pela razão dos outros dois: um alvo que a varredura não
	# alcança daria «nenhum problema» a todas as leituras dele.
	# Medido em 11/10, com a Dona Cida fora do `Main` (`096`): os mesmos 49 —
	# 15 do Main e 1 da Narradora, que é o `_cida` que o F4 procura no texto
	# dela. Com a declaração velha, este bloco reprovou «o Main não tem o
	# método» `_cida`, uma vez: é o nome que muda de dono, outra vez.
	# E a vez das telas (`097`): nenhuma suíte lia os privados dela por string
	# até ao F11 perguntar pela fila à espera — 1 da `Vez`, os mesmos 15 do Main.
	_confere("F19: e há nomes para conferir (%d: %s)" % [conferidos.size(), por_alvo],
		conferidos.size() >= 30 and int(por_alvo.get("Main", 0)) > 0
			and int(por_alvo.get("Dock", 0)) > 0 and int(por_alvo.get("Trafego", 0)) > 0
			and int(por_alvo.get("Narradora", 0)) > 0 and int(por_alvo.get("Vez", 0)) > 0)

	_f19_terminou = true


func _f19_compilar() -> void:
	# O literal com cara de privado, com o `&` do StringName e o `^` do
	# NodePath que o Godot aceita à frente das aspas.
	_f19_re_literal = RegEx.new()
	_f19_re_literal.compile("[&^]?\"(_[A-Za-z][A-Za-z0-9_]*)\"")
	# A leitura direta. O receptor é um identificador inteiro — nunca a cauda
	# de `self.x` ou de `a.b`, que ficariam sem dono e reprovariam — ou uma
	# chamada sem argumentos, como o `_painel_de_cima()` da captura. O `\s*`
	# atravessa a quebra de linha entre o parêntesis e o nome.
	_f19_re_direta = RegEx.new()
	_f19_re_direta.compile("(?<![\\w.])([A-Za-z_]\\w*(?:\\(\\))?)\\s*\\.\\s*(get|set|call|callv|has_method)\\(\\s*[&^]?\"(_[A-Za-z][A-Za-z0-9_]*)\"")
	_f19_re_in = RegEx.new()
	_f19_re_in.compile("[&^]?\"(_[A-Za-z][A-Za-z0-9_]*)\"\\s+(?:not\\s+)?in\\s+([A-Za-z_]\\w*)\\b")
	# A leitura cujo primeiro argumento NÃO é uma string: devolve o texto até
	# ao primeiro argumento, que é a forma como a declaração a nomeia.
	_f19_re_sem_nome = RegEx.new()
	_f19_re_sem_nome.compile("(?<![\\w.])([A-Za-z_]\\w*(?:\\(\\))?)\\s*\\.\\s*(get|set|call|callv|has_method)\\(\\s*([^\"&^\\s,)][^,)\\n]*)")


# A mesma leitura em quinze sítios dá a mesma linha quinze vezes; conta-se.
func _f19_agrupar(linhas: Array) -> String:
	var vezes := {}
	var ordem := []
	for linha in linhas:
		if not vezes.has(linha):
			vezes[linha] = 0
			ordem.append(linha)
		vezes[linha] = int(vezes[linha]) + 1
	var saida := ""
	for linha in ordem:
		saida += "\n    %s%s" % [linha, "" if int(vezes[linha]) == 1 else "  (×%d)" % int(vezes[linha])]
	return saida


# Lê um texto de GDScript e devolve o que a guarda precisa dele: quantas vezes
# cada literal privado aparece, as leituras diretas `[receptor, op, nome]` e as
# leituras sem nome na chamada, como texto.
func _f19_ler(texto: String) -> Dictionary:
	var literais := {}
	for m in _f19_re_literal.search_all(texto):
		var nome := m.get_string(1)
		literais[nome] = int(literais.get(nome, 0)) + 1
	var diretas := []
	for m in _f19_re_direta.search_all(texto):
		diretas.append([m.get_string(1), m.get_string(2), m.get_string(3)])
	for m in _f19_re_in.search_all(texto):
		diretas.append([m.get_string(2), "in", m.get_string(1)])
	var sem_nome := []
	for m in _f19_re_sem_nome.search_all(texto):
		sem_nome.append("%s.%s(%s" % [m.get_string(1), m.get_string(2), m.get_string(3).strip_edges()])
	return {"literais": literais, "diretas": diretas, "sem_nome": sem_nome}


# A EXPRESSÃO PROVA-SE ANTES DE VARRER (a lição do F9): uma que não casasse
# nada daria as listas vazias, e as listas vazias são o verde de graça. O
# fixture traz cada forma que ela caça — a quebra de linha, o `in` e o `not
# in`, o StringName, o receptor que é chamada — e as que ela tem de DEIXAR
# SEM DONO: o receptor entre parêntesis, o `get_node`.
func _f19_prova_das_expressoes() -> bool:
	var q := "\""
	var texto := "\n".join(PackedStringArray([
		"var a = tela.get(%s_um%s)" % [q, q],
		"tela.call(\n\t\t%s_dois%s, 1)" % [q, q],
		"if not (%s_tres%s in no):" % [q, q],
		"var c = (tela as Control).get(%s_quatro%s)" % [q, q],
		"x = _painel_de_cima().get(%s_cinco%s)" % [q, q],
		"doca.callv(&%s_seis%s, [])" % [q, q],
		"var t = tela.get_node(%s_sete%s)" % [q, q],
		"if %s_oito%s not in no:" % [q, q],
		"tela.call(par[1], 0, ponta)",
		"m.get(id, 0)",
		"self.tela.get(%s_nove%s)" % [q, q],
	]))
	var lido := _f19_ler(texto)
	var diretas := []
	for d in lido["diretas"]:
		diretas.append("%s %s %s" % d)
	diretas.sort()
	# Os literais comparam-se SEM o sublinhado: escritos com ele, entre aspas,
	# eram nove literais privados sem dono — a primeira corrida deste bloco
	# reprovou por isso, no próprio fixture.
	var literais := []
	for nome in (lido["literais"] as Dictionary).keys():
		literais.append(String(nome).trim_prefix("_"))
	literais.sort()
	var esperadas := ["_painel_de_cima() get _cinco", "doca callv _seis", "no in _oito",
		"no in _tres", "tela call _dois", "tela get _um"]
	var esperados := ["cinco", "dois", "nove", "oito", "quatro", "seis", "sete", "tres", "um"]
	var certo: bool = diretas == esperadas and literais == esperados \
		and lido["sem_nome"] == ["tela.call(par[1]", "m.get(id"]
	if not certo:
		print("    F19 prova: diretas %s, literais %s, sem nome %s"
			% [diretas, literais, lido["sem_nome"]])
	return certo


# Os membros do script da RAIZ da cena — a variável e o método, por reflexão,
# herdados do script base incluídos (medido: o `PainelBoletim` não define o
# `_fechar` e a lista traz o do `PainelNarrativo`). Uma PASTA junta os de todas
# as cenas de lá, que é a pergunta de quem diz «um painel».
func _f19_membros(caminho: String) -> Dictionary:
	var scripts: Array[Script] = []
	# ⚠️ UM ALVO PODE SER UM SCRIPT, e não a raiz de uma cena, desde o M8
	# (`095`): o trânsito dos camiões é um objeto que o `Main` monta, e as
	# suítes leem-lhe os privados como liam os do `Main`. A reflexão é a mesma;
	# só o sítio de onde o script sai muda. `load()` e não `preload`, pela
	# regra do `gdscript.md`: ele fala do autoload.
	if caminho.ends_with(".gd"):
		var direto := load(caminho) as Script
		if direto != null:
			scripts.append(direto)
	else:
		var cenas: Array[String] = []
		if caminho.ends_with("/"):
			_varrer_cenas(caminho.trim_suffix("/"), cenas)
		else:
			cenas.append(caminho)
		for cena in cenas:
			var empacotada := load(cena) as PackedScene
			if empacotada == null:
				continue
			var estado := empacotada.get_state()
			for i in estado.get_node_property_count(0):
				if estado.get_node_property_name(0, i) != "script":
					continue
				var script := estado.get_node_property_value(0, i) as Script
				if script != null:
					scripts.append(script)
	var propriedades := {}
	var metodos := {}
	for script in scripts:
		for p in script.get_script_property_list():
			if int(p["usage"]) & PROPERTY_USAGE_SCRIPT_VARIABLE:
				propriedades[String(p["name"])] = true
		for m in script.get_script_method_list():
			metodos[String(m["name"])] = true
	return {"propriedade": propriedades, "metodo": metodos}


# ============================================================
# F20 — A TABELA DAS FASES (`docs/decisoes/094`)
#
# Desde o M7 o que é de uma fase vive na tabela `FASES` do `GameState`, e o
# jogo lê-a por funções. Três perguntas que nenhuma suíte fazia, porque eram
# constantes soltas e o compilador respondia por elas:
#
# 1. OS CAMPOS, E SÓ ELES. O que FALTA rebenta no primeiro sítio que o lê —
#    longe da tabela, e com um «Invalid access to key» que não diz que fase.
#    O que SOBRA não rebenta em sítio nenhum: um `berco` ao lado de `bercos`,
#    escrito a pensar que o jogo o lê, é dado morto com cara de regra. Daí o
#    conjunto FECHADO, em cada fase, em cada parcela e em cada reparo.
# 2. OS NÚMEROS NAS ESCALAS QUE O JOGO CONHECE: parcelas por ordem e dentro da
#    fase, reparos que existem no catálogo e abrem dentro dela, a reputação em
#    0–100 (o D4 do Bruno), e no máximo UMA quitada por reparo — o texto do
#    `desbloqueio_da_estrutura()` diz «primeira», e quem pedir duas escreve
#    outra frase antes.
# 3. AS AFIRMAÇÕES QUE NENHUMA REGRA LÊ. O `nivel_maximo` não trava nada (as
#    bancadas montam o porto de nível 3), e por isso só é verdade se alguém o
#    conferir: aqui, contra o nível que as compras da fase alcançam. Os
#    `bercos` contra as vagas que o `Main.tscn` desenha — as vagas curadas do
#    D3. E o capital das parcelas da Fase 1 contra o `START_CASH`, que é o
#    crédito que o jogador recebeu (`085`).
#
# ⚠️ DESDE A `104` TUDO CORRE EM TODAS AS LINHAS. Até lá as afirmações valiam
# só para a fase em jogo, que era sempre a primeira; com a Fase 2 no save, o
# nível e os berços conferem-se fase a fase (o `n` das funções de fase), e o
# capital continua a ser só da Fase 1, que é a do crédito.
#
# E A FASE SEM PRAZO (`103`): `semanas` em `null`, e só onde é verdade — na
# ÚLTIMA linha, que não tem seguinte a abrir num dia que não existe, e sem
# parcelas, que venceriam numa semana que não se conta.
# ============================================================
var _f20_terminou := false

const F20_CAMPOS_DA_FASE := ["bercos", "nivel_maximo", "parcelas", "reparos",
	"reputacao_inicial", "semanas"]
const F20_CAMPOS_DA_PARCELA := ["juros", "semana", "valor"]
const F20_CAMPOS_DO_REPARO := ["dias_de_obra", "quitadas", "semana"]


func _f20_a_tabela_das_fases() -> void:
	var fases: Array = GS.get_script().get_script_constant_map()["FASES"]
	_confere("F20: a tabela tem pelo menos uma fase (%d)" % fases.size(), fases.size() >= 1)
	for i in fases.size():
		_f20_campos_da_fase(i + 1, fases[i], i == fases.size() - 1)
	_f20_capital_da_fase_1()
	for i in fases.size():
		_f20_bercos_do_mapa(i + 1)
		_f20_nivel_alcancado(i + 1)
	_f20_terminou = true


# Compara as chaves como CONJUNTO, ordenadas: faltar e sobrar reprovam pela
# mesma linha, e o detalhe diz qual das duas.
func _f20_chaves(onde: String, d: Dictionary, esperadas: Array) -> bool:
	var tem: Array = d.keys()
	tem.sort()
	var quer: Array = esperadas.duplicate()
	quer.sort()
	_confere("F20: %s tem os campos todos, e só eles" % onde, tem == quer,
		"tem %s, a tabela pede %s" % [tem, quer])
	return tem == quer


func _f20_inteiro(v: Variant) -> bool:
	return typeof(v) == TYPE_INT


func _f20_campos_da_fase(n: int, fase: Variant, ultima: bool) -> void:
	var onde := "Fase %d" % n
	if typeof(fase) != TYPE_DICTIONARY:
		_confere("F20: a %s é um dicionário" % onde, false)
		return
	if not _f20_chaves("a " + onde, fase, F20_CAMPOS_DA_FASE):
		return
	var semanas: Variant = fase["semanas"]
	var com_prazo: bool = semanas != null
	if com_prazo:
		_confere("F20: a %s dura um número inteiro de semanas (%s)" % [onde, semanas],
			_f20_inteiro(semanas) and int(semanas) >= 1)
	else:
		var parcelas_sem_prazo: Variant = fase["parcelas"]
		_confere("F20: a %s não tem prazo, e só a última fase e sem cobrança o pode não ter"
				% onde,
			ultima and typeof(parcelas_sem_prazo) == TYPE_ARRAY
				and (parcelas_sem_prazo as Array).is_empty())
	var nivel: Variant = fase["nivel_maximo"]
	_confere("F20: o nível máximo da %s é um dos três do porto (%s)" % [onde, nivel],
		_f20_inteiro(nivel) and int(nivel) >= 1 and int(nivel) <= 3)
	var bercos: Variant = fase["bercos"]
	_confere("F20: a %s desenha pelo menos um berço (%s)" % [onde, bercos],
		_f20_inteiro(bercos) and int(bercos) >= 1)
	# O D4: 0–100 em cada fase. Uma reputação de 650 é a escala de 0–3000 do
	# GDD a entrar por engano, e a barra satura no primeiro barco.
	var reputacao: Variant = fase["reputacao_inicial"]
	_confere("F20: a reputação da %s começa na escala 0–100 (%s)" % [onde, reputacao],
		typeof(reputacao) in [TYPE_INT, TYPE_FLOAT] and float(reputacao) >= 0.0
			and float(reputacao) <= 100.0)

	# Vazia é fase sem cobrança (`104`); o que tem de ser é uma lista.
	var parcelas: Variant = fase["parcelas"]
	if typeof(parcelas) != TYPE_ARRAY:
		_confere("F20: a %s tem uma lista de parcelas" % onde, false)
		return
	var anterior := 0
	for k in (parcelas as Array).size():
		var p: Variant = parcelas[k]
		var onde_p := "parcela %d da Fase %d" % [k + 1, n]
		if typeof(p) != TYPE_DICTIONARY or not _f20_chaves("a " + onde_p, p, F20_CAMPOS_DA_PARCELA):
			continue
		var tipos: bool = _f20_inteiro(p["semana"]) and _f20_inteiro(p["valor"]) \
			and _f20_inteiro(p["juros"])
		_confere("F20: a %s é feita de inteiros" % onde_p, tipos)
		if not tipos:
			continue
		_confere("F20: a %s vence depois da anterior e dentro da fase (semana %d)"
				% [onde_p, int(p["semana"])],
			int(p["semana"]) > anterior and com_prazo and int(p["semana"]) <= int(semanas))
		_confere("F20: os juros da %s são parte do valor (%d de %d)"
				% [onde_p, int(p["juros"]), int(p["valor"])],
			int(p["juros"]) >= 0 and int(p["juros"]) < int(p["valor"]))
		anterior = int(p["semana"])

	var reparos: Variant = fase["reparos"]
	if typeof(reparos) != TYPE_DICTIONARY:
		_confere("F20: a %s tem um dicionário de reparos" % onde, false)
		return
	for id in reparos:
		var r: Variant = reparos[id]
		var onde_r := "reparo %s da Fase %d" % [id, n]
		_confere("F20: o %s está no catálogo das estruturas" % onde_r,
			GS.ESTRUTURAS.has(id))
		if typeof(r) != TYPE_DICTIONARY or not _f20_chaves("o " + onde_r, r, F20_CAMPOS_DO_REPARO):
			continue
		var tipos: bool = _f20_inteiro(r["semana"]) and _f20_inteiro(r["quitadas"]) \
			and _f20_inteiro(r["dias_de_obra"])
		_confere("F20: o %s é feito de inteiros" % onde_r, tipos)
		if not tipos:
			continue
		_confere("F20: o %s abre dentro da fase (semana %d)" % [onde_r, int(r["semana"])],
			int(r["semana"]) >= 1 and (not com_prazo or int(r["semana"]) <= int(semanas)))
		_confere("F20: o %s leva pelo menos um dia de obra (%d)" % [onde_r, int(r["dias_de_obra"])],
			int(r["dias_de_obra"]) >= 1)
		# Duas perguntas e não uma: pedir mais quitadas do que a fase cobra é
		# um reparo que nunca abre; pedir mais de UMA é um texto que mente.
		_confere("F20: o %s não pede mais quitadas do que a fase cobra (%d de %d)"
				% [onde_r, int(r["quitadas"]), (parcelas as Array).size()],
			int(r["quitadas"]) >= 0 and int(r["quitadas"]) <= (parcelas as Array).size())
		_confere("F20: o %s pede no máximo uma quitada — o desbloqueio diz «primeira» (%d)"
				% [onde_r, int(r["quitadas"])],
			int(r["quitadas"]) <= 1)


# O crédito inicial da `085`: R$400 mil recebidos, R$420 mil contratados. O
# comentário da tabela afirma que o arredondamento fecha o capital ao real, e
# era só isso — uma afirmação; mexer num juro deixava-a falsa sem um aviso.
func _f20_capital_da_fase_1() -> void:
	var capital := 0
	for i in int(GS.parcelas_na_fase(1)):
		capital += int(GS.valor_da_parcela(i, 1)) - int(GS.juros_da_parcela(i, 1))
	_confere("F20: o capital das parcelas da Fase 1 é o crédito que o jogador recebeu (%s de %s)"
			% [GS.moeda(capital), GS.moeda(int(GS.START_CASH))],
		capital == int(GS.START_CASH))


# As vagas curadas do D3: a tabela diz quantos berços o mapa desenha, e é o
# `Main.tscn` quem os desenha — a doca no mapa e o cartão por baixo dele. A
# cena instancia-se FORA da árvore, logo sem `_ready()`: só os nós.
func _f20_bercos_do_mapa(n: int) -> void:
	var main: Node = (load("res://scenes/Main.tscn") as PackedScene).instantiate()
	var docas := 0
	for filho in main.get_node("MapaWrap/Docas").get_children():
		if String(filho.name).begins_with("Doca"):
			docas += 1
	var cartoes := 0
	for filho in main.get_node("BarraDocas").get_children():
		if String(filho.name).begins_with("Cartao"):
			cartoes += 1
	main.free()
	var bercos := int(GS.bercos_no_mapa(n))
	_confere("F20: o mapa desenha os berços que a Fase %d declara (%d docas e %d cartões, declara %d)"
			% [n, docas, cartoes, bercos],
		docas == bercos and cartoes == bercos)


# O NÍVEL QUE AS COMPRAS DA FASE ALCANÇAM, contra o que ela declara. Percorre
# todo subconjunto dos reparos dela que a cadeia de `requer` deixa construir,
# num porto acabado de abrir — sem a montagem das bancadas, que o
# `new_game()` limpa —, e pergunta ao `nivel_do_porto()` do jogo. IGUAL e não
# «no máximo»: um nível declarado acima do que se alcança é a mesma mentira, do
# outro lado.
func _f20_nivel_alcancado(n: int) -> void:
	GS.new_game()
	var reparos: Array = GS.reparos_da_fase(n)
	var maior := 0
	var montados := 0
	for mascara in range(1 << reparos.size()):
		var feitas: Array = []
		for b in reparos.size():
			if mascara & (1 << b):
				feitas.append(reparos[b])
		var possivel := true
		for id in feitas:
			var requer := String(GS.ESTRUTURAS[id]["requer"])
			if requer != "" and not feitas.has(requer):
				possivel = false
		if not possivel:
			continue
		GS.estruturas = feitas
		maior = maxi(maior, int(GS.nivel_do_porto()))
		montados += 1
	GS.new_game()
	var declarado := int(GS.dados_da_fase(n)["nivel_maximo"])
	_confere("F20: o nível máximo da Fase %d é o que os reparos dela alcançam (declara %d, alcançam %d em %d portos)"
			% [n, declarado, maior, montados],
		montados > 1 and maior == declarado)


# ── F21 ─────────────────────────────────────────────────────────────────
# A MIGRAÇÃO ENCADEADA (`098`). Até a 14, save de outra versão era descartado;
# daqui para a frente cada versão nova traz o degrau que lê a anterior, e quem
# o prova é um save de EXEMPLO por versão, gravado pelo jogo dessa versão em
# `tests/saves/vNN.json`. Quatro perguntas:
#
# 1. HÁ UM EXEMPLO POR VERSÃO, do piso à corrente, e nenhum fora disso. Subir
#    a `SAVE_VERSION` sem gravar o exemplo novo reprova aqui — e o da
#    anterior, que fica, só carrega se o degrau existir.
# 2. TODO EXEMPLO CARREGA. O de uma versão antiga atravessa a cadeia e
#    depois todas as recusas, como se a corrente o tivesse gravado.
# 3. O EXEMPLO CORRENTE VOLTA IGUAL depois de carregado e regravado: tudo o
#    que o `save_game()` escreve, o `load_game()` repõe. Nenhuma suíte o
#    perguntava de uma vez: o F3 confere caixa e turno, o T15 a obra, o F15
#    os recordes, um bloco do `run_tests` a semana — medido, cada um apanha
#    o seu —, e o campo novo que ninguém lembre não tem bloco. Para morder, o
#    exemplo tem de trazer os campos CHEIOS, e a lista do que ele traz é a da
#    ferramenta que o grava (`faltas()`), chamada daqui sobre o estado
#    carregado. Do exemplo antigo pede-se que o porto chegue com os nomes.
# 4. A CADEIA, com degraus de mentira: até a `102` a 14 era piso e corrente,
#    o jogo não tinha degrau nenhum, e o laço que os sobe não tinha quem o
#    visse. Hoje o exemplo v14 sobe o degrau de verdade (pergunta 2).
#
# ⚠️ ATÉ A `102` ISTO NÃO VIA a chamada da cadeia dentro do `_save_aceite()`:
# sem degrau nenhum, tirá-la não mudava o que o jogo fazia. Desde que a 15
# existe, quem a vê é o exemplo v14 — sem a chamada, a pergunta da versão
# recusa-o. O que o degrau 14→15 faz a cada campo prova-o o T19.
const PASTA_DOS_EXEMPLOS := "res://tests/saves"
var _f21_terminou := false


func _f21_a_migracao() -> void:
	var piso: int = GS.SAVE_VERSAO_MINIMA
	var corrente: int = GS.SAVE_VERSION
	_confere("F21: o piso da migração não passa da versão corrente (%d ≤ %d)" % [piso, corrente],
		piso <= corrente)

	var exemplos := _f21_exemplos()
	for v in range(piso, corrente + 1):
		_confere("F21: há um save de exemplo da versão %d" % v, exemplos.has(v),
			"grave-o com res://tools/gravar_save_de_exemplo.gd no commit em que a %d é a corrente" % v)
	for v in exemplos:
		_confere("F21: o exemplo v%d está entre o piso e a corrente (%d a %d)" % [v, piso, corrente],
			v >= piso and v <= corrente,
			"exemplo que a cadeia não lê é exemplo morto: ou o piso subiu, ou o arquivo é do futuro")

	var versoes: Array = exemplos.keys()
	versoes.sort()
	for v in versoes:
		_f21_um_exemplo(int(v), String(exemplos[v]), corrente)

	_f21_a_cadeia()
	GS.clear_save()
	_novo_jogo()
	_f21_terminou = true


# Os exemplos da pasta, por versão — `{14: "res://tests/saves/v14.json"}`. Um
# arquivo de outro nome reprova: ninguém o leria, e quem o pôs lá contava que
# sim.
func _f21_exemplos() -> Dictionary:
	var achados := {}
	var re := RegEx.create_from_string("^v(\\d+)\\.json$")
	for nome in DirAccess.get_files_at(PASTA_DOS_EXEMPLOS):
		var m := re.search(nome)
		if m == null:
			_confere("F21: «%s» tem o nome de um exemplo (vNN.json)" % nome, false)
			continue
		achados[int(m.get_string(1))] = "%s/%s" % [PASTA_DOS_EXEMPLOS, nome]
	return achados


func _f21_um_exemplo(v: int, caminho: String, corrente: int) -> void:
	var texto := FileAccess.get_file_as_string(caminho)
	var lido = JSON.parse_string(texto)
	if typeof(lido) != TYPE_DICTIONARY:
		_confere("F21: o exemplo v%d é um JSON de objeto" % v, false, caminho)
		return
	var diz = lido.get("versao")
	_confere("F21: o exemplo v%d diz que é da versão %d" % [v, v],
		typeof(diz) in [TYPE_INT, TYPE_FLOAT] and float(diz) == v,
		"diz %s — foi regravado por outra versão?" % str(diz))

	_novo_jogo()
	_recusa_texto_escrever(texto)
	var carregou: bool = GS.load_game()
	_confere("F21: o save de exemplo da versão %d carrega" % v, carregou,
		"recusado — falta o degrau %d→%d em _migrar_um_passo(), ou ele entrega o que as recusas barram"
			% [v, v + 1])
	if not carregou:
		return
	if v != corrente:
		# O que o degrau faz com cada campo prova-se num teste DELE, escrito por
		# quem o escreveu. Aqui pergunta-se só se o porto não se perde: o nome
		# do cais e o de quem joga são o que o jogador reconhece no espaço, e
		# nenhum degrau tem razão para os mudar — o dia e o dinheiro, sim (a
		# reescala da `084` mudou o dinheiro).
		_confere("F21: o porto do exemplo v%d chega com os dois nomes dele" % v,
			GS.nome_porto == String(lido.get("nome_porto", "")) and GS.nome_porto != ""
				and GS.nome_jogador == String(lido.get("nome_jogador", "")),
			"«%s» / «%s»" % [GS.nome_porto, GS.nome_jogador])
		return
	# Sobre o estado CARREGADO, e por isso a lista acende também quando quem
	# perde o campo é o `load_game()` — medido: com ele a esquecer a obra, a
	# semana ou os recordes, reprovam esta e a ida e volta. Só esta reprova o
	# exemplo pobre, onde a ida e volta passa com a obra esquecida (`098`).
	var faltas: Array = load("res://tools/gravar_save_de_exemplo.gd").faltas(GS)
	_confere("F21: o exemplo corrente traz os campos cheios — obra, fila, atracado, parcela, reparo, semanas, recorde, nomes e a segunda chance",
		faltas.is_empty(), "faltam: %s — ou o exemplo não os tem (regrave-o com a ferramenta), ou o load_game() não os repôs (ver a ida e volta)"
			% ", ".join(faltas))
	GS.save_game()
	var regravado = JSON.parse_string(FileAccess.get_file_as_string(GS.save_path))
	var dif := _f21_diferenca(lido, regravado, "save")
	_confere("F21: o exemplo corrente volta igual depois de carregado e regravado", dif == "", dif)


# A primeira diferença entre dois valores lidos de JSON, com o caminho até
# ela; "" se forem iguais. Os dois lados vêm do `JSON.parse_string`, então
# todo número é float dos dois lados e o `==` compara o que o arquivo diz.
func _f21_diferenca(a: Variant, b: Variant, onde: String) -> String:
	if typeof(a) != typeof(b):
		return "%s: %s ≠ %s" % [onde, JSON.stringify(a), JSON.stringify(b)]
	if typeof(a) == TYPE_DICTIONARY:
		var chaves: Array = a.keys()
		for k in b.keys():
			if not chaves.has(k):
				chaves.append(k)
		chaves.sort()
		for k in chaves:
			if not a.has(k) or not b.has(k):
				return "%s.%s: só de um lado" % [onde, k]
			var d := _f21_diferenca(a[k], b[k], "%s.%s" % [onde, k])
			if d != "":
				return d
		return ""
	if typeof(a) == TYPE_ARRAY:
		if a.size() != b.size():
			return "%s: %d itens ≠ %d" % [onde, a.size(), b.size()]
		for i in a.size():
			var d := _f21_diferenca(a[i], b[i], "%s[%d]" % [onde, i])
			if d != "":
				return d
		return ""
	return "" if a == b else "%s: %s ≠ %s" % [onde, JSON.stringify(a), JSON.stringify(b)]


# A cadeia com degraus de mentira, que anotam por onde passaram. Cada pergunta
# é um defeito do laço: o degrau que falta, o que sobra, a versão por escrever,
# a origem mexida e o degrau que recusa sem parar a subida.
func _f21_a_cadeia() -> void:
	var degraus: Array = []
	var anota := func(de: int, d: Dictionary) -> Dictionary:
		degraus.append(de)
		var feitos: Array = d.get("degraus", [])
		feitos.append(de)
		d["degraus"] = feitos
		return d
	var origem := {"versao": 11, "porto": "Cais"}
	var r: Dictionary = GS.cadeia_de_migracao(origem, 14, anota)
	_confere("F21: a cadeia de 11 a 14 sobe os degraus 11, 12 e 13, por ordem",
		degraus == [11, 12, 13], str(degraus))
	# A versão vem da CADEIA: o degrau de mentira não a escreve, como o de
	# verdade pode esquecer-se de a escrever.
	_confere("F21: e entrega a versão 14, escrita pela cadeia, com o que cada degrau escreveu",
		r.get("versao") == 14 and r.get("degraus") == [11, 12, 13] and r.get("porto") == "Cais",
		str(r))
	_confere("F21: e a origem não foi tocada", origem == {"versao": 11, "porto": "Cais"}, str(origem))

	degraus.clear()
	var recusa_o_12 := func(de: int, d: Dictionary) -> Dictionary:
		degraus.append(de)
		return {} if de == 12 else d
	r = GS.cadeia_de_migracao({"versao": 11}, 14, recusa_o_12)
	_confere("F21: o degrau que não sabe ler recusa o save inteiro, e os de cima não correm",
		r.is_empty() and degraus == [11, 12], "%s depois de %s" % [r, degraus])

	degraus.clear()
	r = GS.cadeia_de_migracao({"versao": 14, "porto": "Cais"}, 14, anota)
	_confere("F21: o save já na versão corrente atravessa sem degrau nenhum",
		degraus.is_empty() and r == {"versao": 14, "porto": "Cais"}, "%s depois de %s" % [r, degraus])
	r = GS.cadeia_de_migracao({"versao": 15}, 14, anota)
	_confere("F21: e o do futuro também — chega com a versão dele, e quem o recusa é o _save_aceite (F3)",
		degraus.is_empty() and r.get("versao") == 15, "%s depois de %s" % [r, degraus])


# ── F22 ─────────────────────────────────────────────────────────────────
# O TUTORIAL DO TONINHO (`docs/decisoes/100`, `101`), jogado pelo `Main`.
#
# O F7 prova que cada fala dele tem cara, PNG e quem a peça no código; isto
# prova que ela SAI quando o recorte diz, e mais nenhuma vez. São quatro
# caminhos, cada um com a sua bandeira — um caminho que reprova cedo esconde o
# que os outros veriam (`054`):
#
#   1. ATRACAR ANTES DE LER: o passo 1 entra na fila atrás da mensagem de
#      abertura; quem atraca nesses segundos não o lê — ele SAI da fila e do
#      histórico —, e vem o passo 2, com o «AVANÇAR DIA» a pulsar até à
#      virada. Depois disso, nada: atracar no dia 2 não o repete.
#   2. O DIA VIRA ANTES DE ATRACAR: o passo 1 é visto, o dia vira pelo botão,
#      e sai a fala SÉRIA; atracar a seguir já não dá o passo 2. E o mesmo
#      quando o dia vira no MESMO frame em que o `Main` monta, antes de o
#      passo 1 ser pedido — a bateria de capturas joga assim, e a primeira
#      versão calava-se ali: a fala dependia do frame, e não do barco.
#   3. A ABERTURA: com o caderno na tela ele cala-se, e com a contra-oferta do
#      dia 1 por responder também — só fala quando há barco que se possa
#      chamar.
#   4. NÃO É DIA DE TUTORIAL: o dia 2, o dia 1 com barco já no píer (um save
#      recarregado) e o dia 1 sem barco ao largo passam calados.
#
# ⚠️ A CARA ESPERADA É LITERAL — calmo, irónico, sério, pela `100` —, e não
# lida da `EXPRESSOES`: trocar duas caras lá mudaria os dois lados de uma
# asserção que as comparasse.
const F22_CARA := {"atracar": "retrato_toninho_calmo.png",
	"avancar": "retrato_toninho_ironico.png", "dia_virou": "retrato_toninho_serio.png"}
const F22_AVANCAR := "AcoesTurno/Avancar"

var _f22_terminou := false
var _f22_ditas: Array[String] = []
var _f22_mostradas: Array[String] = []


func _f22_o_tutorial() -> void:
	var c1: bool = await _f22_atracar_antes_de_ler()
	_confere("F22: o caminho 1 (atracar antes de ler) correu até ao fim", c1)
	var c2: bool = await _f22_o_dia_vira_antes()
	_confere("F22: o caminho 2 (o dia vira antes de atracar) correu até ao fim", c2)
	var c3: bool = await _f22_a_abertura()
	_confere("F22: o caminho 3 (a abertura) correu até ao fim", c3)
	var c4: bool = await _f22_nao_e_dia()
	_confere("F22: o caminho 4 (não é dia de tutorial) correu até ao fim", c4)
	_f22_terminou = true


# A partida do dia 1 com UM barco pronto ao largo e os nomes escolhidos, sem
# contra-oferta: o estado é montado à mão, e o sorteio fica semeado para o
# que ele ainda decidir (a chegada do dia seguinte).
func _f22_dia_um(semente: int) -> void:
	GS.clear_save()
	GS._rng.seed = semente
	GS.new_game()
	GS.definir_nomes(GS.NOME_PORTO_PADRAO, "")
	GS.fila = [GS._make_boat()]
	GS.pending_rival = -1
	GS._set_phase("playing")


func _f22_montar() -> Node:
	var cena := load("res://scenes/Main.tscn") as PackedScene
	var main: Node = cena.instantiate()
	root.add_child(main)
	_f22_ditas.clear()
	_f22_mostradas.clear()
	main.tutorial.falou.connect(_f22_ouvir)
	main._fila.apresentou.connect(_f22_ver)
	return main


func _f22_ouvir(id: String, _linha: String) -> void:
	_f22_ditas.append(id)


func _f22_ver(texto: String, _kind: String) -> void:
	_f22_mostradas.append(texto)


func _f22_esperar() -> void:
	# Dois frames: `call_deferred` só corre depois do primeiro (`gdscript.md`).
	await process_frame
	await process_frame


func _f22_drenar(main: Node) -> void:
	var voltas := 0
	while main._fila.avancar(99.0) and voltas < 200:
		voltas += 1


# A entrada do histórico com este texto, ou vazio.
func _f22_no_historico(main: Node, texto: String) -> Dictionary:
	for e in main._fila.historico:
		if String(e["texto"]) == texto:
			return e
	return {}


func _f22_cara(e: Dictionary) -> String:
	var r = e.get("retrato", null)
	return "" if r == null else String((r as Texture2D).resource_path.get_file())


func _f22_atracar_antes_de_ler() -> bool:
	_f22_dia_um(20261012)
	var main := _f22_montar()
	var botao := main.get_node(F22_AVANCAR) as Button
	var linha1 := Narrativa.toninho("atracar")
	var abertura := String(main._fila.atual().get("texto", ""))
	await _f22_esperar()
	_confere("F22.1: no dia 1 com barco ao largo, o Toninho diz o passo 1",
		main.tutorial.passo == "atracar" and _f22_ditas == ["atracar"],
		"passo «%s», disse %s" % [main.tutorial.passo, _f22_ditas])
	var e1 := _f22_no_historico(main, linha1)
	_confere("F22.1: na voz dele e com a cara calma",
		String(e1.get("fonte", "")) == "toninho" and _f22_cara(e1) == F22_CARA["atracar"],
		"fonte «%s», cara «%s»" % [e1.get("fonte", ""), _f22_cara(e1)])
	# O ESTADO QUE APERTA: a fala ainda à espera, atrás da abertura. Se ela já
	# estivesse na tela, «sai da fila» passaria por não ter o que tirar.
	_confere("F22.1: e espera a vez atrás da mensagem de abertura",
		String(main._fila.atual().get("texto", "")) == abertura and main._fila.pendentes() >= 1,
		"na tela: «%s», %d à espera" % [main._fila.atual().get("texto", ""),
			main._fila.pendentes()])

	var antes := {}
	for t in get_processed_tweens():
		antes[t] = true
	_confere("F22.1: (o jogo aceitou o atracar)", GS.atracar(0))
	await _f22_esperar()
	_f22_drenar(main)
	_confere("F22.1: atracado antes de a ler, o passo 1 nunca chega à tela",
		not _f22_mostradas.has(linha1), "mostradas: %s" % [_f22_mostradas])
	_confere("F22.1: e sai do histórico — nunca foi dito",
		_f22_no_historico(main, linha1).is_empty())
	var linha2 := Narrativa.toninho("avancar")
	var e2 := _f22_no_historico(main, linha2)
	_confere("F22.1: vem o passo 2, visto, com a cara irónica",
		main.tutorial.passo == "avancar" and _f22_mostradas.has(linha2)
			and _f22_cara(e2) == F22_CARA["avancar"],
		"passo «%s», cara «%s»" % [main.tutorial.passo, _f22_cara(e2)])

	# O PULSO: o tween que o passo 2 criou, apanhado pela diferença da lista
	# (`testes-e-guardas.md`), e o NÓ lido depois de o andar.
	var novos: Array[Tween] = []
	for t in get_processed_tweens():
		if not antes.has(t):
			novos.append(t)
	for t in novos:
		if t.is_valid():
			t.custom_step(0.45)
	_confere("F22.1: e o «AVANÇAR DIA» pulsa (%d tweens novos)" % novos.size(),
		botao.modulate.r > 1.05, "modulate %s" % botao.modulate)

	# O PASSO 2 NÃO SE REPETE NO MESMO DIA. Desfazer o toque e atracar outra
	# vez (`desatracar()`, o «toque na doca para liberar») é um segundo
	# `atracou` no dia 1, com o tutorial ainda a ouvir. ⚠️ No dia 2 quem o
	# cala é o fim do tutorial, que desliga os sinais — e ali, sem a guarda do
	# passo no `_ao_atracar`, tudo continuava verde (medido: o mutante M7 da
	# `101` passou com a pergunta só no dia 2). É aqui que essa guarda aperta.
	var voltou: bool = GS.desatracar(0)
	var de_novo: bool = GS.atracar(0)
	await _f22_esperar()
	_f22_drenar(main)
	_confere("F22.1: desfazer e atracar outra vez no dia 1 não repete o passo 2",
		voltou and de_novo and _f22_ditas == ["atracar", "avancar"],
		"desatracou %s, atracou %s, disse %s" % [voltou, de_novo, _f22_ditas])

	botao.pressed.emit()
	for t in novos:
		if t.is_valid():
			t.custom_step(0.45)
	_confere("F22.1: virado o dia pelo botão, o pulso PARA (e não só volta ao branco)",
		botao.modulate == Color.WHITE and main.tutorial.passo == "fim",
		"modulate %s, passo «%s»" % [botao.modulate, main.tutorial.passo])

	# NÃO SE REPETE: no dia 2, com barco e berço, atracar não diz nada.
	if GS.phase == "rival_offer":
		GS.resolve_rival_offer(true)
	await _f22_esperar()
	for d in GS.docks:
		d["boat"] = null
		d["worker_id"] = null
	GS.fila = [GS._make_boat()]
	var atracou: bool = GS.atracar(0)
	await _f22_esperar()
	_confere("F22.1: no dia 2, atracar não repete o tutorial",
		atracou and _f22_ditas == ["atracar", "avancar"], "disse %s" % [_f22_ditas])
	main.free()
	return true


func _f22_o_dia_vira_antes() -> bool:
	_f22_dia_um(20261013)
	var main := _f22_montar()
	var botao := main.get_node(F22_AVANCAR) as Button
	await _f22_esperar()
	_f22_drenar(main)
	_confere("F22.2: o passo 1 chega à tela quando ninguém atraca",
		_f22_mostradas.has(Narrativa.toninho("atracar")))
	botao.pressed.emit()
	await _f22_esperar()
	_f22_drenar(main)
	var serio := Narrativa.toninho("dia_virou")
	var e := _f22_no_historico(main, serio)
	_confere("F22.2: o dia virou antes de atracar — sai a fala séria, vista",
		_f22_ditas == ["atracar", "dia_virou"] and _f22_mostradas.has(serio),
		"disse %s" % [_f22_ditas])
	_confere("F22.2: com a cara séria", _f22_cara(e) == F22_CARA["dia_virou"],
		"cara «%s»" % _f22_cara(e))
	_confere("F22.2: e o tutorial acaba", main.tutorial.passo == "fim")
	if GS.phase == "rival_offer":
		GS.resolve_rival_offer(true)
	GS.fila = [GS._make_boat()]
	var atracou: bool = GS.atracar(0)
	await _f22_esperar()
	_confere("F22.2: atracar depois já não dá o passo 2",
		atracou and _f22_ditas == ["atracar", "dia_virou"], "disse %s" % [_f22_ditas])
	main.free()

	# O dia vira no frame da montagem, sem esperar o passo 1.
	_f22_dia_um(20261019)
	main = _f22_montar()
	botao = main.get_node(F22_AVANCAR) as Button
	botao.pressed.emit()
	await _f22_esperar()
	var e2 := _f22_no_historico(main, serio)
	_confere("F22.2: virado o dia no frame da montagem, sai na mesma a fala séria",
		_f22_ditas == ["dia_virou"] and _f22_cara(e2) == F22_CARA["dia_virou"]
			and main.tutorial.passo == "fim",
		"passo «%s», disse %s" % [main.tutorial.passo, _f22_ditas])
	main.free()
	return true


func _f22_a_abertura() -> bool:
	# O caderno: a partida nova pergunta os nomes, e o Toninho espera-o.
	_f22_dia_um(20261014)
	GS.nome_porto = ""
	GS.nome_jogador = ""
	var main := _f22_montar()
	var overlay: Node = main.get_node("Overlay")
	await _f22_esperar()
	_confere("F22.3: com a folha de rosto na tela, o Toninho não fala",
		main.tutorial.passo == "" and _f22_ditas.is_empty(),
		"passo «%s», disse %s" % [main.tutorial.passo, _f22_ditas])
	var nomes: Node = _primeiro_com_script(overlay, "TelaNomes.gd")
	if nomes != null:
		GS.definir_nomes("Cais de Teste", "")
		nomes.fechou.emit()
	await _f22_esperar()
	_confere("F22.3: nem com o diário",
		_f22_ditas.is_empty(), "disse %s" % [_f22_ditas])
	var diario: Node = _primeiro_com_script(overlay, "PainelDiario.gd")
	_confere("F22.3: (a abertura abriu o diário)", diario != null)
	if diario != null:
		diario.fechou.emit()
	await _f22_esperar()
	_confere("F22.3: fechado o caderno, diz o passo 1",
		_f22_ditas == ["atracar"], "disse %s" % [_f22_ditas])
	main.free()

	# A contra-oferta do dia 1: o barco está nas mãos do Arlindo, e mandar
	# tocar nele seria mandar tocar no que não se pode chamar.
	_f22_dia_um(20261015)
	GS.fila[0]["rival"] = true
	GS.pending_rival = 0
	GS.rival_attempts_left = GS.RIVAL_PATIENCE
	GS._set_phase("rival_offer")
	main = _f22_montar()
	await _f22_esperar()
	_confere("F22.3: com a contra-oferta por responder, ele espera calado",
		main.tutorial.passo == "a_espera" and _f22_ditas.is_empty(),
		"passo «%s», disse %s" % [main.tutorial.passo, _f22_ditas])
	GS.resolve_rival_offer(true)
	await _f22_esperar()
	_confere("F22.3: e fala quando o cliente fica",
		_f22_ditas == ["atracar"], "disse %s" % [_f22_ditas])
	main.free()
	return true


func _f22_nao_e_dia() -> bool:
	_f22_dia_um(20261016)
	GS.turn = 2
	var main := _f22_montar()
	await _f22_esperar()
	_confere("F22.4: no dia 2 não há tutorial",
		main.tutorial.passo == "fim" and _f22_ditas.is_empty(),
		"passo «%s», disse %s" % [main.tutorial.passo, _f22_ditas])
	main.free()

	_f22_dia_um(20261017)
	GS.atracar(0, false)
	GS.fila = [GS._make_boat()]
	main = _f22_montar()
	await _f22_esperar()
	_confere("F22.4: no dia 1 com barco já no píer, também não",
		main.tutorial.passo == "fim" and _f22_ditas.is_empty(),
		"passo «%s», disse %s" % [main.tutorial.passo, _f22_ditas])
	main.free()

	# O fundeadouro vazio no dia 1 (0,25³ das partidas): nada a tocar, e o dia
	# passa calado — o passo 1 não manda tocar num barco que não existe, e a
	# fala séria não fala de um barco que não esperou.
	_f22_dia_um(20261018)
	GS.fila = []
	main = _f22_montar()
	var botao := main.get_node(F22_AVANCAR) as Button
	await _f22_esperar()
	_confere("F22.4: com o fundeadouro vazio ele espera calado",
		main.tutorial.passo == "a_espera" and _f22_ditas.is_empty(),
		"passo «%s», disse %s" % [main.tutorial.passo, _f22_ditas])
	botao.pressed.emit()
	await _f22_esperar()
	_confere("F22.4: e o dia vira sem fala nenhuma",
		main.tutorial.passo == "fim" and _f22_ditas.is_empty(),
		"passo «%s», disse %s" % [main.tutorial.passo, _f22_ditas])
	main.free()
	GS.clear_save()
	return true


# ══ F23 — A FASE 2 NA TELA, E O M9 (`104`) ══════════════════════════════════
#
# Duas perguntas que nenhum bloco fazia, porque a Fase 2 não existia:
#
# 1. O M9 TRANCADO: os estados do turno viraram constantes, e um literal
#    `"playing"` que volte ao código do JOGO (o `autoload/` e o `scripts/`,
#    fora das réguas de `validation/`) é a forma de onde um erro de digitação
#    sai calado. Varre-se o ARQUIVO, cortando o comentário de cada linha — os
#    comentários citam os estados a explicar o porquê, e a busca no texto
#    inteiro reprovaria o código certo. E o legado: o `GameState` já não tem o
#    `upgrade_purchased` nem o `buy_upgrade()`, e o save não o grava.
# 2. A FASE 2 ABRE NA TELA: a passagem com o `Main` aberto, e cada sítio que
#    lia a duração da fase — o dia do HUD, o cartão da parcela, o calendário,
#    o celular, a pausa, o boletim e a linha do espaço — desenhado SEM prazo.
#    Um sítio que ainda pedisse `turnos_da_fase()` rebenta (`int(null)`), e o
#    erro aborta só a função onde nasce: quem a chamou segue com um valor
#    vazio. Por isso cada asserção lê o TEXTO EXATO que a tela escreveu, e não
#    se o painel abriu. E a Dona Cida na passagem: a barra recomeça na escala
#    da Fase 2, e isso não é «andaram recusando contrato».
var _f23_terminou := false
var _f23_cida: Array[String] = []
const F23_PASTAS_DO_JOGO := ["res://autoload", "res://scripts"]
const F23_ESTADOS := ["playing", "rival_offer", "debt_payment", "game_over"]


func _f23_a_fase_2() -> void:
	var c1 := _f23_literais_de_estado()
	_confere("F23: o caminho do M9 correu até ao fim", c1)
	var c2: bool = await _f23_a_fase_2_na_tela()
	_confere("F23: o caminho da tela correu até ao fim", c2)
	_f23_terminou = true


func _f23_arquivos(pasta: String, saida: Array[String]) -> void:
	var d := DirAccess.open(pasta)
	if d == null:
		return
	for f in d.get_files():
		if f.ends_with(".gd"):
			saida.append(pasta.path_join(f))
	for sub in d.get_directories():
		# As réguas de `validation/` montam estados com o valor do save por
		# extenso, como as suítes; o que ali se mede é a tela, não o jogo.
		if sub != "validation":
			_f23_arquivos(pasta.path_join(sub), saida)


# A parte de CÓDIGO de uma linha: até ao primeiro `#` fora de aspas.
func _f23_codigo(linha: String) -> String:
	var aspas := ""
	for i in linha.length():
		var c := linha[i]
		if aspas != "":
			if c == aspas:
				aspas = ""
		elif c == "\"" or c == "'":
			aspas = c
		elif c == "#":
			return linha.substr(0, i)
	return linha


func _f23_literais_de_estado() -> bool:
	var arquivos: Array[String] = []
	for pasta in F23_PASTAS_DO_JOGO:
		_f23_arquivos(pasta, arquivos)
	var achados: Array[String] = []
	var definicoes := 0
	var tem_game_state := false
	var tem_main := false
	for caminho in arquivos:
		tem_game_state = tem_game_state or caminho.ends_with("autoload/GameState.gd")
		tem_main = tem_main or caminho.ends_with("scripts/Main.gd")
		var n := 0
		for linha in FileAccess.get_file_as_string(caminho).split("\n"):
			n += 1
			var codigo := _f23_codigo(linha)
			for estado in F23_ESTADOS:
				if not codigo.contains("\"%s\"" % estado):
					continue
				# A definição das constantes é o único sítio do texto solto.
				if codigo.strip_edges().begins_with("const ESTADO_"):
					definicoes += 1
				else:
					achados.append("%s:%d" % [caminho.get_file(), n])
	# A régua prova que leu: os dois arquivos que mais liam os estados estão
	# na lista, e as quatro definições foram achadas — sem elas, «zero
	# literais» seria a amostra vazia a dar verde.
	_confere("F23: a varredura leu o código do jogo (%d arquivos, GameState e Main entre eles)"
			% arquivos.size(), arquivos.size() > 10 and tem_game_state and tem_main)
	_confere("F23: e achou as quatro constantes que definem os estados (%d)" % definicoes,
		definicoes == F23_ESTADOS.size())
	_confere("F23: nenhum estado do turno por extenso no código do jogo (%d)" % achados.size(),
		achados.is_empty(), ", ".join(achados))
	var tem_legado := false
	for prop in GS.get_property_list():
		if String(prop["name"]) == "upgrade_purchased":
			tem_legado = true
	GS.save_game()
	var gravado: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(GS.save_path))
	_confere("F23: o legado saiu — sem `upgrade_purchased` nem `buy_upgrade()`, e o save sem ele",
		not tem_legado and not GS.has_method("buy_upgrade") and not gravado.has("upgrade_purchased"))
	return true


func _f23_ouvir_cida(id: String, _linha: String) -> void:
	_f23_cida.append(id)


func _f23_a_fase_2_na_tela() -> bool:
	GS.clear_save()
	GS._rng.seed = F10_SEMENTE
	GS.new_game()
	GS.definir_nomes("Cais da Fase 2", "")
	var voltas := 0
	while voltas < 200 and not (GS.phase == "debt_payment" and int(GS.parcela_indice) == 2):
		voltas += 1
		GS.cash = maxi(int(GS.cash), int(GS.START_CASH) * 25)
		if GS.phase == "debt_payment":
			GS.pay_debt()
		if GS.phase == "rival_offer":
			GS.resolve_rival_offer(true)
			continue
		GS.advance_turn()
	if not (GS.phase == "debt_payment" and int(GS.parcela_indice) == 2):
		_confere("F23: a partida chega à terceira cobrança", false, "fase «%s»" % GS.phase)
		return true
	var main: Node = (load("res://scenes/Main.tscn") as PackedScene).instantiate()
	root.add_child(main)
	await _f8_esperar()
	# «Referência» na Fase 1, PELO SINAL: a narradora só sabe a faixa que viu
	# passar, e a primeira que vê ela só regista. Escrita à mão, a barra a 100
	# nunca lhe chegava, o recomeço da passagem era a primeira — e o mutante
	# sem o `_cida_passagem()` passou verde (medido).
	GS.reputation = 99.0
	GS._change_reputation(1.0)
	await _f8_esperar()
	_f23_cida.clear()
	main.narradora.falou.connect(_f23_ouvir_cida)
	GS.pay_debt()
	await _f8_esperar()
	_confere("F23: a passagem com o Main aberto põe a partida na Fase 2",
		int(GS.numero_da_fase) == 2 and GS.phase != "game_over")
	_confere("F23: e a barra recomeçou abaixo da faixa em que a Fase 1 fechou",
		GS.reputation_label() != GS.rotulo_da_reputacao(100.0))
	_confere("F23: e a Dona Cida não anuncia o recomeço como queda (%s)" % ", ".join(_f23_cida),
		not _f23_cida.has("reputacao_caiu") and not _f23_cida.has("reputacao_subiu"))
	# O CONTROLO: ela continua a ouvir, a partir da faixa da Fase 2 — uma queda
	# de verdade, depois, é anunciada. Sem isto, uma narradora surda passava a
	# asserção de cima de graça.
	_f23_cida.clear()
	GS._change_reputation(-30.0)
	await _f8_esperar()
	_confere("F23: e uma queda de verdade, depois da passagem, ela anuncia (%s)" % ", ".join(_f23_cida),
		_f23_cida.has("reputacao_caiu"))
	var dia := main.get_node("HudBar/DiaPilula/Linha/Dia") as Label
	_confere("F23: o dia do HUD não tem «de quantos» na Fase 2 («%s»)" % dia.text,
		dia.text == "Dia %d" % int(GS.turn))
	var meta := main.get_node("MetaCartao/MetaColuna/MetaTituloLinha/MetaTitulo") as Label
	_confere("F23: o cartão da parcela diz que não há dívida («%s»)" % meta.text,
		meta.text == "Fase 2 — sem dívida com o banco")
	main.free()
	if GS.phase == "rival_offer":
		GS.resolve_rival_offer(true)

	# O CALENDÁRIO: a tarja sem prazo e as quatro semanas a partir da de hoje.
	var cal: Node = await _f10_abrir("res://scenes/panels/PainelCalendario.tscn", [])
	var celulas: Array[String] = []
	_f23_nomes_com_prefixo(cal, "Dia", celulas)
	var primeiro_da_semana: int = (int(GS.current_week()) - 1) * int(GS.TURNS_PER_WEEK) + 1
	_confere("F23: o calendário da Fase 2 diz o dia sem prazo («%s»)" % _f14_texto(cal, "Dia "),
		_f14_texto(cal, "Dia ") == "Dia %d" % int(GS.turn))
	_confere("F23: e mostra as quatro semanas a partir da de hoje (%d células, a primeira %s)"
			% [celulas.size(), celulas[0] if not celulas.is_empty() else "—"],
		celulas.size() == 4 * int(GS.TURNS_PER_WEEK)
			and celulas.has("Dia%d" % primeiro_da_semana)
			and not celulas.has("Dia%d" % (primeiro_da_semana - 1)))
	# A legenda explica só o que a grelha pode mostrar: sem cobrança, nada de
	# «vencimento da parcela», e o fecho de semana continua lá.
	_confere("F23: e a legenda não explica um vencimento que a fase não tem",
		_f14_texto(cal, "vencimento da parcela") == "" and _f14_texto(cal, "fecho de semana") != "")
	_f10_fechar(cal)

	# O CELULAR: a semana sem «de quantas», e a fita com os dias do calendário.
	var menu: Node = await _f10_abrir("res://scenes/panels/PainelMenu.tscn", [])
	var semana := menu.find_child("Semana", true, false) as Label
	var de_total := menu.find_child("DeTotal", true, false) as Label
	var fita := menu.find_child("FitaDosDias", true, false)
	var tracos := 0
	if fita != null:
		for grupo in fita.get_children():
			tracos += grupo.get_child_count()
	_confere("F23: o celular diz a semana e a fase, sem prazo («%s», «%s»)"
			% ["—" if semana == null else semana.text, "—" if de_total == null else de_total.text],
		semana != null and semana.text == "SEMANA %d" % int(GS.current_week())
			and de_total != null and de_total.text == "Fase 2")
	_confere("F23: e a fita tem os dias que o calendário mostra (%d)" % tracos,
		tracos == (GS.calendario() as Array).size())
	_f10_fechar(menu)

	# A PAUSA e a LINHA DO ESPAÇO: o dia pela fase.
	var pausa: Node = await _f10_abrir("res://scenes/panels/PauseMenu.tscn", [])
	var onde := _f14_texto(pausa, GS.texto("{portName}"))
	_confere("F23: a pausa diz em que fase e dia está («%s»)" % onde,
		onde.contains("Fase 2, dia %d" % int(GS.turn)))
	_f10_fechar(pausa)
	GS.save_game()
	var linha: String = GS.linha_do_espaco(GS.resumo_do_espaco(int(GS.espaco)))
	_confere("F23: a linha do espaço também («%s»)" % linha,
		linha.begins_with("Fase 2, dia %d" % int(GS.turn)))

	# O BOLETIM de uma semana da Fase 2: sem «de quantas».
	var boletim: Node = await _f10_abrir("res://scenes/panels/PainelBoletim.tscn",
		[GS.resumo_da_semana(int(GS.current_week()))])
	# Pela linha EXATA: o boletim tem também a «Semana anterior», e o
	# `_f14_texto()` dá vazio a dois achados.
	var textos: Array[String] = []
	_f10_textos_visiveis(boletim, textos)
	var com_prazo := textos.filter(func(t): return t.begins_with("Semana %d de" % int(GS.current_week())))
	_confere("F23: o boletim da Fase 2 diz a semana sem prazo (%s)" % str(com_prazo),
		textos.has("Semana %d" % int(GS.current_week())) and com_prazo.is_empty())
	_f10_fechar(boletim)
	GS.clear_save()
	return true


func _f23_nomes_com_prefixo(no: Node, prefixo: String, saida: Array[String]) -> void:
	var nome := String(no.name)
	if nome.begins_with(prefixo) and nome.substr(prefixo.length()).is_valid_int():
		saida.append(nome)
	for filho in no.get_children():
		_f23_nomes_com_prefixo(filho, prefixo, saida)
