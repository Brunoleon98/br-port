extends SceneTree

# ============================================================
# BR Port VS — captura de UMA CENA QUALQUER
# Ferramenta de apoio. NÃO faz parte do jogo.
#
# `capturar_tela.gd` fotografa o jogo: monta o Main, joga turnos, resolve a
# oferta do rival. Isso é o que se quer para a tela do jogo e é exatamente o
# que atrapalha para fotografar uma bancada de teste, que não tem partida
# nenhuma. Daí esta segunda ferramenta, que só instancia uma cena e espera.
#
# Uso (Linux, sem monitor — precisa de xvfb):
#   xvfb-run -a Godot --path brport_vs --resolution 720x1280 \
#     --rendering-driver opengl3 --script res://tools/capturar_cena.gd -- \
#     res://scenes/tests/AssetPlacementTest.tscn foto.png
#
# E para o SEGUNDO TEMPO de um painel, o toque e onde ele tem de parar:
#   ... DebtPaymentPanel.tscn foto.png @PARCELA_AMOUNT parcela=vencida \
#     cash=@PARCELA_AMOUNT --tocar=Pagar --tempo=pagou
#
# Teste verde não prova que ficou bonito. É para isto que ela existe.
# ============================================================

const FRAMES_ATE_ASSENTAR := 12

# O ponto único de estilo do projeto. Ver ui/tema_brport.tres.
const TEMA := "res://ui/tema_brport.tres"

# A mesma semente das outras capturas da bateria. Fixa, e num lugar só.
const SEMENTE := 20260825

var _cena := "res://scenes/tests/AssetPlacementTest.tscn"
var _saida := "user://cena.png"
var _montado := false
var _frames := 0
# Argumentos extra, entregues a `setup()` da cena quando ela tiver um.
var _extra: Array = []
# Pares `campo=valor` a escrever no GameState antes de a cena nascer.
var _estado: Array = []
# Botões a tocar, por ordem, antes da foto — `--tocar=<início do rótulo>`.
var _toques: Array = []
# O tempo em que o painel tem de estar na foto — `--tempo=<id>`, vazio = sem
# exigência.
var _tempo_esperado := ""
# Uma consequência exclusiva do caminho fotografado — `--provar=<id>`. O
# tempo e a cara não distinguem as duas despedidas do Arlindo; a métrica que
# `_perder_para_rival()` incrementa, sim.
var _prova_esperada := ""
# A cena montada, para o toque a percorrer e a foto lhe ler o tempo.
var _no: Node = null
# A prova das caras, que anda depois da foto (`caras_na_foto.gd`), e o tamanho
# da foto já gravada, para a linha de sucesso.
var _prova = null
var _tamanho := Vector2i.ZERO
# `aposta=recusada`: antes de cada toque o sorteio do jogo é semeado para a
# aposta do cliente falhar — ver `_semear_recusa()`.
var _aposta_recusada := false


func _process(_delta: float) -> bool:
	if not _montado:
		_montado = true
		_ler_argumentos()
		if not ResourceLoader.exists(_cena):
			push_error("cena não encontrada: %s" % _cena)
			quit(1)
			return true
		var no: Node = load(_cena).instantiate()
		# O TEMA TEM DE SER APLICADO À MÃO AQUI. No jogo quem o põe é o
		# `_abrir_painel()` do Main; uma cena instanciada solta nasce sem tema
		# nenhum e o Godot desenha-a com o estilo padrão — cinzento sobre
		# cinzento. A fotografia sai "funcionando" e não se parece nada com o
		# que o jogador vê, que é a pior espécie de captura: a que dá confiança
		# sem dar informação. Medido ao fotografar o Diário do Porto.
		if no is Control:
			(no as Control).theme = load(TEMA)
		_estado_conhecido()
		_montar_estado()
		root.add_child(no)
		_no = no
		_chamar_setup(no)
		return false

	# AS CARAS VÊM DEPOIS DA FOTO, e a foto já está gravada: a prova esconde-as
	# e fotografa outra vez, e o PNG que fica é o de antes (`caras_na_foto.gd`).
	if _prova != null:
		if not _prova.andar(root):
			return false
		return _fechar_com_caras()

	# Alguns frames antes de fotografar: um Sprite2D só tem textura resolvida
	# depois de o recurso terminar de carregar, e um Label só mede o texto
	# depois do primeiro layout.
	_frames += 1
	if _frames < FRAMES_ATE_ASSENTAR:
		return false
	if not _toques.is_empty():
		if not _tocar(String(_toques.pop_front())):
			quit(1)
			return true
		_frames = 0
		return false

	# ⚠️ O TEMPO PROMETIDO CONFERE-SE ANTES DA FOTO. O tiro diz onde devia
	# parar e o painel diz onde está — duas fontes, como o turno dos tiros de
	# jogo. Sem isto um `--tocar` que calhasse no botão errado entregava o
	# outro tempo com o nome deste, e a cobertura contava-o na mesma.
	var tempo := _tempo_do_painel()
	if _tempo_esperado != "" and tempo != _tempo_esperado:
		push_error("esperava o tempo «%s» e o painel está em «%s»" % [
			_tempo_esperado, tempo])
		quit(1)
		return true
	if not _provar_estado():
		quit(1)
		return true

	var img := root.get_texture().get_image()
	var erro := img.save_png(_saida)
	if erro != OK:
		push_error("falhou ao gravar %s (erro %d)" % [_saida, erro])
		quit(1)
		return true
	_tamanho = img.get_size()
	# A CENA QUE ESTA FERRAMENTA MONTOU, no mesmo rótulo que o `capturar_tela.gd`
	# usa para os painéis que estão por cima do jogo. É daqui que o
	# `conferir_cobertura_paineis.py` sabe que o Diário, a parcela, o Sr.
	# Ribeiro, a contra-oferta, o menu-celular, a tela de nomes e o fim de Fase 1
	# têm fotografia — medido no log, e não declarado ao lado do tiro.
	print("Paineis: %s" % _cena)
	# E O TEMPO DELE, quando o painel tem mais de um. Um painel é uma cena, mas
	# a cena do Sr. Ribeiro são três telas — a entrada, a de quem pagou e a de
	# quem não pôde —, e até 23/09 a bateria fotografava só a primeira das três
	# (`docs/decisoes/051`).
	if tempo != "":
		print("Tempo: %s %s" % [_cena, tempo])
	# E AS CARAS DELE, uma andar abaixo do tempo (`docs/decisoes/060`): a cena
	# da contra-oferta é uma tela na rodada e mostra duas caras diferentes
	# conforme a aposta. `load()` e não `preload`, pela regra dos `--script`.
	_prova = load("res://tools/caras_na_foto.gd").new(_no, img)
	return false


func _fechar_com_caras() -> bool:
	for falha in _prova.falhas:
		print("FALHOU  %s" % falha)
	if not _prova.falhas.is_empty():
		quit(1)
		return true
	for linha in _prova.linhas:
		print(linha)
	# "Tela salva em" é CONTRATO com o `capturar_evidencia.sh`, que procura essa
	# linha em vez de olhar o código de saída — um erro de compilação do GDScript
	# sai com 0 sem a ferramenta ter feito nada. Antes daqui dizia "captura:", e
	# por isso esta ferramenta não podia entrar na bateria do CI.
	print("Tela salva em %s  (%dx%d)" % [_saida, _tamanho.x, _tamanho.y])
	quit(0)
	return true


# Vários painéis do jogo só existem depois de alguém lhes chamar `setup()` —
# a cena da parcela precisa do valor, a de fim de fase precisa de saber se se
# ganhou. Instanciadas sem isso ficam VAZIAS, e a captura sai um retângulo em
# branco que passa por "a cena abre" sem mostrar nada do que se queria ver.
#
# Os argumentos extra da linha de comando são passados a `setup()` em ordem.
# São convertidos por forma: "true"/"false" viram bool e o que for só dígitos
# vira int, porque `setup(won: bool, ...)` recusa a String "true".
# ⚠️ E CHAMA-SE MESMO SEM ARGUMENTOS NENHUNS. Até 12/09 a primeira condição
# aqui era `_extra.is_empty()`, e com ela um painel cujo `setup()` não EXIGE
# argumentos — `setup(_sem_argumentos: Variant = null)`, que são quatro deles:
# Calendário, Docas, Parcela e Reputação — nunca recebia a chamada. A captura
# saía com o escurecer e um cartão de altura zero, imprimia "Tela salva em" e
# passava por boa. É exatamente o buraco que o comentário acima descreve, com
# a guarda a cavá-lo. O Diário escapou por montar no `_ready()`, e foi por
# isso que isto viveu escondido.
#
# ⚠️ E UM ARGUMENTO PODE VIR DO ESTADO, com `@`. A cena da parcela recebe o
# valor a pagar, e escrevê-lo à mão na bateria (`530000`) seria pôr a foto a
# dizer um número que a constante já sabe — no dia em que o `PARCELA_AMOUNT`
# mudar, a captura mostra o Sr. Ribeiro a cobrar o valor de ontem, verdadeira
# na aparência e falsa no facto. É a mesma regra que já tirou os R$100.000
# cravados do `capturar_tela.gd`: ferramenta que finge um estado tem de o
# DERIVAR. `@PARCELA_AMOUNT` lê a constante do `GameState`, e um nome que não
# exista lá rebenta em vez de virar zero.
func _chamar_setup(no: Node) -> void:
	if not no.has_method("setup"):
		return
	var GS: Node = root.get_node("GameState")
	var convertidos := []
	for bruto in _extra:
		if bruto.begins_with("@"):
			# A CONSTANTE NÃO É UMA PROPRIEDADE, e o `get()` devolveria `null`
			# sem se queixar — o painel abriria a cobrar R$0. As constantes do
			# script vêm do mapa delas; os campos vivos, do próprio nó.
			var chave: String = bruto.substr(1)
			var consts: Dictionary = GS.get_script().get_script_constant_map()
			if consts.has(chave):
				convertidos.append(consts[chave])
			elif chave in GS:
				convertidos.append(GS.get(chave))
			else:
				push_error("GameState não tem %s" % chave)
				quit(1)
				return
		elif bruto == "true" or bruto == "false":
			convertidos.append(bruto == "true")
		elif bruto.is_valid_int():
			convertidos.append(int(bruto))
		else:
			convertidos.append(bruto)
	no.callv("setup", convertidos)


func _ler_argumentos() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		_cena = args[0]
	if args.size() > 1:
		_saida = args[1]
	# Os extra dividem-se por FORMA: `chave=valor` monta o estado do jogo antes
	# de a cena nascer; o resto vai para o `setup()` em ordem.
	for bruto in args.slice(2):
		if bruto.begins_with("--tocar="):
			_toques.append(bruto.substr("--tocar=".length()))
		elif bruto.begins_with("--tempo="):
			_tempo_esperado = bruto.substr("--tempo=".length())
		elif bruto.begins_with("--provar="):
			_prova_esperada = bruto.substr("--provar=".length())
		elif bruto.contains("=") and not bruto.begins_with("res://"):
			_estado.append(bruto)
		else:
			_extra.append(bruto)


# ⚠️ E PARTE-SE SEMPRE DE UMA PARTIDA NOVA, porque o autoload NÃO nasce vazio.
# O `GameState._ready()` tenta `load_game()` antes de `new_game()`, então uma
# cena fotografada por esta ferramenta herdava o autosave que estivesse em
# `user://` — e a bateria tira as fotos de JOGO primeiro, que gravam. Medido em
# 12/09: o painel da parcela dizia "R$498.200 são MENOS DE UMA das estruturas
# que faltam" porque o save deixado pela foto anterior já tinha as SETE
# construídas; com partida nova a mesma quantia compra quatro. O Diário vinha
# pelo mesmo cano. Foto de comparação que depende do que está no disco não
# compara nada — é a regra "ferramenta que finge um estado tem de o DERIVAR
# dele", e o `capturar_tela.gd` já a cumpria ao lado.
#
# ⚠️ E A SEMENTE GLOBAL NÃO SEMEIA O JOGO, o que fez desta ferramenta uma
# fotógrafa não reprodutível durante cinco dias sem ninguém notar. O `seed()`
# de baixo mexe no gerador GLOBAL do Godot; o `GameState` sorteia com um
# `RandomNumberGenerator` próprio, que o `_ready()` dele `randomize()`. Enquanto
# os painéis fotografados não liam sorteio nenhum isto não aparecia — no dia em
# que entrou a captura da contra-oferta, duas corridas do MESMO código deram
# R$16.104 e R$0, porque numa delas o sorteio não pôs barco na doca. O
# `capturar_tela.gd` já semeava o `_rng` e explicava porquê ao lado; esta cópia
# tinha só metade da receita.
func _estado_conhecido() -> void:
	var GS: Node = root.get_node("GameState")
	GS.clear_save()
	# A SEMENTE ANTES do `new_game()`, que já sorteia a mão inicial — a mesma
	# armadilha que o `capturar_tela.gd` e o simulador documentam.
	seed(SEMENTE)
	GS._rng.seed = SEMENTE
	GS.new_game()


# ⚠️ PAINEL QUE SÓ DIZ ALGO NUM ESTADO DO JOGO PRECISA DE MONTAR ESSE ESTADO.
# O desconto por antecipação (`docs/decisoes/019`) só aparece com a parcela por
# pagar e o vencimento ainda longe; um `GameState` recém-nascido está no fim do
# prazo, e a captura saía a mostrar o caso SEM desconto — bonita, verdadeira e
# sobre outra coisa. É a regra do `CLAUDE.md` sobre arte presa a uma condição
# do jogo, aplicada a um painel em vez de a um prop.
#
# Só campos que JÁ EXISTEM: um nome errado rebenta em vez de criar um campo
# novo em silêncio, que é a armadilha do `.get(chave, omissão)`.
func _montar_estado() -> void:
	if _estado.is_empty():
		return
	var GS: Node = root.get_node("GameState")
	for par in _estado:
		var corte: int = par.find("=")
		var chave: String = par.substr(0, corte)
		var valor: String = par.substr(corte + 1)
		# ⚠️ `barco=N` NÃO É UM CAMPO, é uma montagem — e existe porque o painel
		# da contra-oferta não diz nada sem um barco na doca. Deixá-lo ao
		# sorteio da mão inicial é o que fez a foto sair a cobrar R$0 metade das
		# vezes: com a semente fixa a mão é sempre a mesma, mas "sempre a mesma"
		# incluía não ter barco nenhum naquela doca. Montar o estado é a regra
		# desta ferramenta desde 12/09; isto é a mesma regra, para uma coisa que
		# não cabe numa atribuição.
		if chave == "barco":
			var doca: int = int(valor)
			GS.docks[doca]["boat"] = GS._make_boat()
			GS.pending_rival_dock = doca
			GS.rival_attempts_left = GS.RIVAL_PATIENCE
			GS._set_phase("rival_offer")
			print("  estado: barco na doca %d" % doca)
			continue
		# ⚠️ `parcela=vencida` TAMBÉM É MONTAGEM, e pelo caminho do jogo: o
		# `advance_turn()` até à fase "debt_payment", resolvendo as ofertas do
		# rival pelo caminho. Fora dessa fase o `pay_debt()` sai CALADO, e o
		# tiro do "Pagar" mostrava a resposta de quem pagou sem o dinheiro ter
		# mudado de mãos — medido pelo F10 em 23/09 (`docs/decisoes/051`).
		if chave == "parcela":
			if valor != "vencida":
				push_error("parcela=%s: a única montagem é «vencida»" % valor)
				quit(1)
				return
			var voltas := 0
			while GS.phase != "debt_payment" and GS.phase != "game_over" and voltas < 200:
				if GS.phase == "rival_offer":
					GS.resolve_rival_offer(true)
				GS.advance_turn()
				voltas += 1
			if GS.phase != "debt_payment":
				push_error("a partida não chegou ao vencimento (fase %s)" % GS.phase)
				quit(1)
				return
			print("  estado: parcela vencida, turno %d" % GS.turn)
			continue
		# ⚠️ `aposta=recusada` TAMBÉM É MONTAGEM, e do DADO, não do resultado.
		# A cara da pressão do Arlindo só existe depois de uma aposta RECUSADA
		# (`ultima_tentativa`), e recusar é sorteio: com a semente fixa a
		# resposta sai sempre a mesma, só que "sempre a mesma" é um número de
		# sorte que qualquer sorteio a mais antes do toque vira do avesso. Aqui
		# o resultado continua a sair do `negotiate_rival()`, pelo botão; o que
		# se escolhe é o dado, como o F10 do fumaça já faz (`060`).
		#
		# ⚠️ E COM A SEMENTE DA BATERIA A DERIVAÇÃO NÃO É QUEM SEGURA — calha
		# recusar sem ela, e o mutante que a tira passa. Medido em 24/09 com
		# seis sementes: sem a derivação duas aceitavam (o tiro fica vermelho
		# pelo `--tempo=rodada`, que é quem prova a recusa); com ela, as seis
		# mostram a pressão. Ela existe para o tiro não depender da sorte.
		if chave == "aposta":
			if valor != "recusada":
				push_error("aposta=%s: a única montagem é «recusada»" % valor)
				quit(1)
				return
			_aposta_recusada = true
			print("  estado: aposta recusada")
			continue
		if not chave in GS:
			push_error("GameState não tem o campo %s" % chave)
			quit(1)
			return
		# E O VALOR PODE SER UMA CONSTANTE, com `@`, pela razão do `setup()`:
		# `cash=@PARCELA_AMOUNT` é "o bastante para pagar" sem cravar o número.
		if valor.begins_with("@"):
			var consts: Dictionary = GS.get_script().get_script_constant_map()
			if not consts.has(valor.substr(1)):
				push_error("GameState não tem a constante %s" % valor.substr(1))
				quit(1)
				return
			GS.set(chave, consts[valor.substr(1)])
			print("  estado: %s = %s" % [chave, consts[valor.substr(1)]])
			continue
		GS.set(chave, int(valor) if valor.is_valid_int() else valor)
		print("  estado: %s = %s" % [chave, valor])


func _tempo_do_painel() -> String:
	if _no == null or not "tempo" in _no:
		return ""
	return String(_no.get("tempo"))


# A DESPEDIDA NÃO PROVA QUEM VENCEU: «Igualar» e duas apostas recusadas chegam
# ambas ao tempo `despedida`, e o sorriso já aparece na abertura. O que só o
# segundo caminho produz é `rival_refused`, incrementado por
# `_perder_para_rival()`. Exigir o valor EXATO também recusa uma prova herdada
# de outra negociação; esta ferramenta sempre parte de uma partida nova.
func _provar_estado() -> bool:
	if _prova_esperada == "":
		return true
	if _prova_esperada != "arlindo_venceu":
		push_error("--provar=%s: a única prova é «arlindo_venceu»" % _prova_esperada)
		return false
	var GS: Node = root.get_node("GameState")
	var recusas: int = int(GS.metrics["rival_refused"])
	if recusas != 1:
		push_error("prova «arlindo_venceu»: esperava metrics.rival_refused = 1 e viu %d" % recusas)
		return false
	print("Prova: arlindo_venceu (metrics.rival_refused = 1)")
	return true


# O SEGUNDO TEMPO DE UM PAINEL SÓ SE ALCANÇA PELA PORTA DO JOGADOR: o botão.
# Chamar a função por baixo dele (`_mostrar_resposta("pagou")`) daria o texto
# certo sem o `pay_debt()` ter corrido — um estado que ninguém alcança a jogar,
# que é a regra do `--painel=` do `capturar_tela.gd` (`docs/decisoes/038`). E o
# botão só vale na fase certa, que é o `parcela=vencida` acima.
#
# ⚠️ E O BOTÃO DESLIGADO REPROVA. "Pagar" existe no painel sem dinheiro para a
# parcela, só que desligado; `pressed.emit()` dispara-o na mesma, e a foto
# sairia a mostrar o pagamento de uma parcela que o jogador não tinha como
# pagar. Medido: sem esta guarda o tiro passa. O estado que o permite
# monta-se antes (`cash=@PARCELA_AMOUNT`).
#
# E o início do rótulo tem de casar UM botão só: dois seria escolher por
# posição, e zero seria fotografar o primeiro tempo com o nome do segundo.
func _tocar(prefixo: String) -> bool:
	var achados: Array = []
	_botoes_de(_no, prefixo, achados)
	if achados.size() != 1:
		push_error("--tocar=%s casou %d botões visíveis" % [prefixo, achados.size()])
		return false
	var botao: Button = achados[0]
	if botao.disabled:
		push_error("--tocar=%s: o botão «%s» está desligado" % [prefixo, botao.text])
		return false
	if _aposta_recusada and not _semear_recusa():
		return false
	print("  toque: %s" % botao.text)
	botao.pressed.emit()
	return true


# A PRIMEIRA SEMENTE CUJO PRIMEIRO SORTEIO RECUSA AS DUAS APOSTAS, derivada da
# chance que o jogo aplica — a da reputação de agora, pelo mesmo
# `_chance_com_reputacao()` que o `_negociar()` chama. Contra a MAIOR das duas,
# para servir ao «Cortar metade» e ao «Manter» sem saber qual se toca.
# Semear o `_rng` JUSTO antes do toque é o que faz o primeiro sorteio dele ser
# o da aposta: nada corre entre as duas linhas.
func _semear_recusa() -> bool:
	var GS: Node = root.get_node("GameState")
	var chance: float = maxf(GS._chance_com_reputacao(GS.RIVAL_HALF_CHANCE),
		GS._chance_com_reputacao(GS.RIVAL_KEEP_CHANCE))
	for semente in range(1, 1000):
		var r := RandomNumberGenerator.new()
		r.seed = semente
		if r.randf() >= chance:
			GS._rng.seed = semente
			return true
	push_error("aposta=recusada: nenhuma semente até 999 recusa a chance %.2f" % chance)
	return false


func _botoes_de(no: Node, prefixo: String, achados: Array) -> void:
	if no is Button and (no as Button).is_visible_in_tree() \
			and not no.is_queued_for_deletion() \
			and (no as Button).text.begins_with(prefixo):
		achados.append(no)
	for filho in no.get_children():
		_botoes_de(filho, prefixo, achados)
