extends SceneTree

# ============================================================
# BR Port VS — captura de tela
# Ferramenta de apoio. NÃO faz parte do jogo.
#
# Monta a cena real, joga alguns turnos e salva um PNG. Serve para olhar a
# interface sem abrir o editor — útil no Bloco 4, quando cada asset novo
# precisa ser conferido na tela e não só no papel.
#
# Uso (Linux, sem monitor — precisa de xvfb):
#   xvfb-run -a Godot --path brport_vs --resolution 720x1280 \
#     --rendering-driver opengl3 --script res://tools/capturar_tela.gd -- [turnos] [saida.png]
#
# No Windows, com monitor, dispensa o xvfb:
#   Godot_v4.6.3-stable_win64.exe --path . --resolution 720x1280 \
#     --script res://tools/capturar_tela.gd -- 10 tela.png
#
# `turnos` avança a partida antes de fotografar (0 = tela inicial), e a
# oferta do rival é resolvida para a tela sair limpa. Um terceiro argumento
# `completo` compra todas as estruturas antes de montar a cena, para
# fotografar o porto reconstruído (mapa pavimentado, píeres e prédios de pé).
# Um quarto argumento `pausa` abre o menu de pausa por cima. Para fotografar o
# PAINEL da contra-oferta em vez da tela principal, use --  0  e rode com
# uma semente que abra oferta no primeiro turno.
#
# `--semente=N`, em qualquer posição, escolhe o mundo sorteado. O PADRÃO É
# FIXO de propósito: a captura é publicada como artefato de cada PR (item B3
# do plano), e duas fotos de partidas diferentes não se comparam — a barra de
# reputação muda, os barcos mudam, e quem olha não sabe o que é a mudança que
# o PR fez. Com semente fixa, o que muda na foto é o que mudou no código.
# ============================================================

const TURNOS_PADRAO := 10
const SAIDA_PADRAO := "user://tela.png"
const FRAMES_ATE_ASSENTAR := 15

# O dia em que a captura passou a ser artefato de PR. O valor não tem
# significado nenhum — o que importa é ele NÃO MUDAR, senão a foto de hoje
# deixa de se comparar com a de ontem.
const SEMENTE_PADRAO := 20260902

var GS
var _main: Control
var _montado := false
var _frames := 0
var _saida := SAIDA_PADRAO
var _semente := SEMENTE_PADRAO


func _process(_delta: float) -> bool:
	if not _montado:
		_montado = true
		_montar()
		return false

	# Alguns frames antes de fotografar: containers só calculam o layout
	# depois de um ciclo, e a foto sai com tudo empilhado no canto se for tirada
	# no primeiro frame.
	_frames += 1
	if _frames < FRAMES_ATE_ASSENTAR:
		if GS.phase == "rival_offer":
			GS.negotiate_rival("igualar")
		# A contra-oferta fecha sempre — ela nunca é o assunto de foto nenhuma.
		# O BOLETIM só fecha se quem chamou pediu `limpo`, porque há um tiro
		# que existe para o fotografar.
		_fechar_paineis_de_rotina(OS.get_cmdline_user_args().has("limpo"))
		return false

	# QUANTOS PAINÉIS ESTÃO POR CIMA. A linha existe porque a captura do porto
	# reconstruído saiu com o Boletim Financeiro tapando o mapa inteiro: com a
	# semente fixa, doze turnos calham num fim de semana, e o painel abre. A
	# foto tinha o nome "porto" e mostrava uma tabela — a fotografia mentirosa
	# outra vez, e desta vez sem sequer um `push_error` a denunciá-la.
	#
	# Quem chama é que sabe o que quer: `capturar_evidencia.sh` exige zero nos
	# tiros do mapa e pelo menos um no do menu de pausa. Assim, se um dia uma
	# constante deslocar a fronteira da semana, o CI diz o que aconteceu em vez
	# de anexar a imagem errada.
	# A FASE VAI JUNTO, e não é enfeite: quando esta contagem diverge entre
	# máquinas, o que se quer saber primeiro é em que estado o jogo ficou — e
	# sem isto o log do CI diz "viu 1" e mais nada, o que obriga a adivinhar.
	print("Overlay: %d painel(eis)  [fase %s, turno %d, %d estrutura(s)]"
		% [_paineis_abertos(), GS.phase, GS.turn, GS.estruturas.size()])

	var img: Image = root.get_texture().get_image()
	var erro := img.save_png(_saida)
	if erro != OK:
		print("FALHOU ao salvar em %s (erro %d)" % [_saida, erro])
		quit(1)
		return true
	print("Tela salva em %s (%dx%d)" % [_saida, img.get_width(), img.get_height()])
	quit(0)
	return true


func _montar() -> void:
	GS = root.get_node("GameState")

	# As opções `--` saem da lista ANTES das posicionais. Sem isto, passar uma
	# semente empurraria `completo` e `pausa` uma casa para o lado, e a captura
	# sairia do porto em ruínas sem se queixar de nada — o mesmo defeito calado
	# que o caixa cravado já tinha causado aqui.
	var args: Array = []
	for bruto in OS.get_cmdline_user_args():
		if bruto.begins_with("--semente="):
			var valor := bruto.substr(10)
			if not valor.is_valid_int():
				push_error("captura: --semente= precisa de um inteiro, veio '%s'" % valor)
				quit(1)
				return
			_semente = int(valor)
			continue
		args.append(bruto)

	var turnos := TURNOS_PADRAO
	if args.size() >= 1 and str(args[0]).is_valid_int():
		turnos = int(args[0])
	if args.size() >= 2:
		_saida = str(args[1])

	GS.clear_save()

	# A SEMENTE VEM ANTES DE `new_game()`, e é a mesma armadilha que o
	# `simular_balanceamento.gd` documenta: `new_game()` já chama
	# `_spawn_boats()`, de modo que semear depois deixaria a mão inicial a sair
	# do gerador não semeado (`_rng.randomize()` no `_ready`). Lá custava
	# medianas diferentes entre duas rodadas iguais; aqui custa uma foto que
	# não se pode comparar com a anterior.
	GS._rng.seed = _semente
	GS.new_game()

	# OS NOMES SÃO DADOS AQUI, e sem isto a ferramenta deixou de servir. Desde
	# que a abertura passou a perguntar o nome do cais e do jogador, o `Main`
	# abre a tela de nomes quando eles faltam — e ela fica POR CIMA de tudo o
	# que se queria fotografar. A primeira captura depois disso saiu com o
	# porto inteiro escondido atrás do painel de abertura.
	#
	# São nomes de ferramenta, não do jogo: "Cais Mirim" é o padrão do GDD, e
	# o do jogador fica vazio de propósito — assim a captura mostra a variante
	# SEM vocativo, que é a que ninguém se lembra de conferir.
	GS.definir_nomes(GS.NOME_PORTO_PADRAO, "")

	# `completo` fotografa o porto NO FIM da reconstrução. O mapa tem dois
	# estados (terra batida e pavimentado) e props que trocam de textura; sem
	# isto só dava para conferir na tela o estado inicial, e o segundo mapa
	# ficava sem ninguém olhando.
	# `meio` compra só as DUAS primeiras, e existe porque o píer, a lança e os
	# prédios ganharam três níveis em 05/09: n1 sem porto, n2 com duas
	# estruturas de pé, e n3 quando o UPGRADE respectivo é comprado. Sem este
	# modo, as capturas do CI
	# mostravam só os dois EXTREMOS — o do meio não tinha como ser olhado, e o
	# gate A5 é olhar.
	if args.size() >= 3 and args[2] in ["completo", "meio"]:
		# new_game() sorteia a mão inicial e tem 30% de abrir oferta do rival.
		# Com o jogo em "rival_offer" toda compra é recusada com "Resolva o que
		# está na tela primeiro", e a foto saía do porto EM RUÍNAS com o nome
		# "completo" — sem erro nenhum, o que é pior. Resolver antes de comprar.
		if GS.phase == "rival_offer":
			GS.resolve_rival_offer(true)
		# O CAIXA VEM DA TABELA DE PREÇOS, não de um número escrito aqui.
		# Estava `+= 100000`, que chegava para o porto inteiro antes da reescala
		# de 02/09 e deixou de chegar depois dela: as duas últimas compras
		# falhavam e a foto saía com o porto A MEIO, com o nome "completo". Dava
		# um `push_error` por compra, que num log de captura passa por ruído —
		# é o mesmo defeito que já tinha acontecido com o rival, e a mesma lição
		# que tirou o dinheiro cravado da suíte.
		var custo_total: int = 0
		for eid_custo in GS.ESTRUTURAS:
			custo_total += int(GS.ESTRUTURAS[eid_custo]["custo"])
		GS.cash += custo_total

		var ids: Array = GS.ESTRUTURAS.keys()
		var tabela: Dictionary = GS.ESTRUTURAS
		ids.sort_custom(func(a, b): return int(tabela[a]["ordem"]) < int(tabela[b]["ordem"]))
		if args[2] == "meio":
			ids = ids.slice(0, 2)
		for eid in ids:
			if not GS.comprar_estrutura(eid):
				push_error("captura: nao consegui comprar %s (%s)"
					% [eid, GS.impedimento_estrutura(eid)])
		# A foto tem de PROVAR o nível que promete. Comprar e não conferir é
		# como o `completo` que saía com o porto a meio depois da reescala —
		# nome certo, imagem errada, e sem erro nenhum.
		# ⚠️ SÃO DOIS NÍVEIS DESDE QUE OS UPGRADES EXISTEM, e conferir só um
		# deixaria passar exatamente o defeito que esta asserção existe para
		# pegar: comprar tudo menos o `cais` daria guindaste n3 sobre laje n2,
		# e a foto do porto "completo" sairia com metade do upgrade.
		var nivel_dito: int = 3 if args[2] == "completo" else 2
		if int(GS.nivel_pier()) != nivel_dito or int(GS.nivel_guindaste()) != nivel_dito:
			push_error("captura: pedi nivel %d e o porto esta em pier %d / guindaste %d (%d estruturas)"
				% [nivel_dito, int(GS.nivel_pier()), int(GS.nivel_guindaste()),
				   GS.estruturas.size()])

	_main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(_main)

	# `pausa` fotografa o menu de pausa, que é onde vivem os sliders de volume.
	# Sem isto a única forma de conferir aquele painel era abrir o editor — e é
	# um painel construído por código, portanto o que mais escapa ao olho.
	if args.size() >= 4 and args[3] == "pausa":
		_main._on_pause_pressed()

	for t in range(turnos):
		if GS.phase == "rival_offer":
			GS.negotiate_rival("metade")
			_fechar_paineis_de_rotina(false)
			continue
		if GS.phase != "playing":
			break
		_alocar_todos()
		GS.advance_turn()


# Resolver a oferta direto no GameState NÃO fecha o painel: quem o fecha é o
# próprio painel, quando é ele que chama negotiate_rival(). Sem isto a foto sai
# sempre com o modal por cima e o mapa escurecido pelo dim — que era exatamente
# o que se queria fotografar.
#
# ⚠️ E O BOLETIM ENTROU NESTA LISTA quando os upgrades mudaram o fluxo de
# turnos — mas só sob pedido, e a diferença importa.
#
# O tiro do mapa era fotografado ao turno 10 "porque onze já abrem o Boletim":
# um número escolhido para cair rente à fronteira da semana. Bastou a vazão
# mudar para o 10 passar do outro lado dela, e a foto do `porto` saiu com a
# tabela por cima do mapa — que é exatamente o defeito que a contagem de
# painéis existe para denunciar, e que o comentário dela previu por escrito.
# Amarrar uma foto a um turno que "por acaso" cai antes da fronteira é o mesmo
# número cravado que este arquivo já perdeu duas vezes.
#
# Quem quer mapa limpo passa `limpo` e o Boletim fecha; quem quer fotografá-lo
# não passa. A contra-oferta fecha nos dois casos: ela não é assunto de foto
# nenhuma, e deixá-la aberta escurece o mapa inteiro com o dim.
#
# As telas de fim de jogo e da PARCELA continuam fotografáveis de propósito:
# essas são o assunto de outras fotos, e fechá-las tiraria o que se quer ver.
func _fechar_paineis_de_rotina(fechar_boletim: bool) -> void:
	if _main == null:
		return
	var overlay := _main.get_node_or_null("Overlay")
	if overlay == null:
		return
	for painel in overlay.get_children():
		var rotina := "dock_index" in painel
		var script: Script = painel.get_script()
		if fechar_boletim and script != null \
				and script.resource_path.ends_with("PainelBoletim.gd"):
			rotina = true
		if rotina:
			overlay.remove_child(painel)
			painel.queue_free()


func _paineis_abertos() -> int:
	if _main == null:
		return 0
	var overlay := _main.get_node_or_null("Overlay")
	if overlay == null:
		return 0
	return overlay.get_child_count()


func _alocar_todos() -> void:
	for w in GS.workers:
		var wid := int(w["id"])
		if int(w["busy_turns"]) > 0 or GS.worker_dock_index(wid) >= 0:
			continue
		for i in range(GS.docks.size()):
			var doca = GS.docks[i]
			if doca["boat"] == null or doca["worker_id"] != null:
				continue
			var barco = doca["boat"]
			if barco.get("rival", false) and not barco.get("matched", false):
				continue
			if GS.assign_worker(wid, i):
				break
