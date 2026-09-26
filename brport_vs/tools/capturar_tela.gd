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
# Para fotografar o PAINEL da contra-oferta em vez da tela principal, use
# --  0  e rode com uma semente que abra oferta no primeiro turno.
#
# `limpo`, `pausa` e `alocar` são bandeiras e leem-se em QUALQUER posição
# depois da saída — fecham os painéis de rotina, abrem o menu de pausa no fim
# e alocam os trabalhadores antes do disparo. `ocioso` é o contrário: nenhum
# trabalhador é alocado, nunca. `--boletim=N` fecha os boletins das semanas
# anteriores e pára no da semana N.
#
# Toda foto sai com uma linha `Retratos:` por cara de personagem que o painel
# de cima mostra, provada nos pixels (`caras_na_foto.gd`, `docs/decisoes/060`).
#
# `--painel=<nome>` abre um dos cinco painéis do HUD no fim, pela mesma porta
# que o jogador toca. Ver a tabela `PAINEIS`: é por aqui que o `PainelCaixa`
# passou a ser fotografável, porque quem lhe monta o `Dictionary` é o jogo.
#
# ⚠️ E `turnos` SÃO TURNOS, não voltas de laço: a ferramenta avança até o
# `turn` do jogo subir essa quantidade, pelo mesmo botão que o jogador carrega,
# e PÁRA se houver um painel por cima que ela não tenha licença para fechar.
# Quem chama confere na linha `Overlay:` em que turno ela parou — é assim que
# um tiro promete o Boletim aberto no turno certo em vez de o atravessar.
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

## Frames a MAIS antes de disparar, com o passo de tempo fixo do `--fixed-fps`.
##
## ⚠️ ELES SÃO TEMPO SIMULADO, e é isso que os torna comparáveis. Os quinze
## frames de assentar chegam para o layout, e não chegam para nada que se mexa:
## o camião leva ~4,7s a sair da rua e encostar no berço, que a 60 quadros por
## segundo são 282 frames. Sem isto, a visita à doca existia no código, passava
## em sete asserções e não aparecia em fotografia nenhuma — que é a forma exata
## do buraco do `barco_medio`. Com `--fixed-fps` cada frame vale 1/60s
## exatamente, então a foto continua a ser byte a byte reprodutível.
var _frames_extra := 0

## As três bandeiras que não são POSIÇÃO, e por que deixaram de ser.
##
## `limpo` sempre se leu por pertença (`has`), e `pausa` lia-se por posição —
## `args[3] == "pausa"`. Era a armadilha que o cabeçalho do `_montar()` já
## descreve para as opções `--`: quem escrevesse `completo limpo pausa` punha o
## `limpo` na casa 3 e o menu de pausa simplesmente não abria, com a foto a
## sair por boa. Lidas todas aqui, a ordem em que se escrevem deixa de contar.
var _limpo := false
var _pausa := false
var _alocar := false
## `ocioso` é o jogador que NUNCA aloca ninguém — o principiante que ainda não
## percebeu a alocação, e o único que ouve a Dona Cida preocupada na primeira
## semana (medido em 12/09: 60 de 60 partidas, e nenhuma de quem aloca). Só no
## porto em RUÍNAS: com `completo` o aluguel dos píeres paga a semana e ela
## fica séria (medido em 24/09). O laço deixa de chamar o `_alocar_todos()`.
var _ocioso := false
## `--boletim=N` fotografa o boletim da semana N: os das semanas anteriores
## fecham como o jogador os fecharia, e o laço pára no dela. O tom — e com ele
## a cara da Dona Cida — sai da partida, e quem diz qual foi é a linha
## `Retratos:` da foto (`docs/decisoes/060`), nunca este número.
var _boletim_semana := 0
var _escolher := false
var _mensagens := false
var _mensagens_aberto := false

## O BALANÇO DO FIM DA FASE, que foi a última lacuna declarada da cobertura
## (`docs/decisoes/051`). Ele lê `GameState.metrics`, e numa cena solta a
## partida é nova: a foto diria «Barcos atendidos: 0», que se LÊ como medida.
## Aqui a partida é JOGADA até ao vencimento pelo laço de sempre, a parcela
## paga-se no botão do Sr. Ribeiro — que só está ligado se o dinheiro chegar —
## e o balanço abre no «Ver o balanço» da narração. Nada disto se escreve à mão.
##
## ⚠️ E O CAMINHO ATÉ ELE PASSA POR TRÊS TELAS, UMA DE CADA VEZ. Desde que o
## `Main` pôs em fila as telas que abrem sozinhas (`_na_vez()`), o «Pagar»
## deixa na tela só a resposta do Sr. Ribeiro; o boletim da semana 4 abre
## quando ela fecha, e o fim de fase quando o boletim fecha. Cada passo espera
## `FRAMES_POR_PASSO` — o painel fechado sai no fim do frame, e é aí que o
## seguinte abre — e REPROVA se o painel de cima não for o que a ordem diz,
## ou se houver outro por baixo dele. A contagem final (um painel) prova que o
## fim chegou só; os passos provam que chegou por esta ordem.
##
## ⚠️ O DINHEIRO NÃO SE DÁ: sai da partida. Medido em 23/09 com a política
## desta ferramenta (todos alocados a cada dia, a oferta do rival pela metade),
## a semente padrão chega ao turno 33 com R$841.372 contra a parcela de
## R$530.000, e três outras sementes com R$775.573 a R$827.159. Se deixar de
## chegar, o botão fica desligado e o tiro REPROVA em vez de pagar à força.
var _balanco := false
# 0 antes de pagar, 1 à espera do boletim, 2 à espera do fim de fase, 3 feito.
var _passo_balanco := 0
var _frames_do_passo := 0
# O `_fechar()` faz `queue_free()`, que só tira o painel no fim do frame — é
# nesse instante que o `tree_exited` passa a vez ao seguinte. Dois frames, como
# o `_f8_esperar()` da suíte de fumaça.
const FRAMES_POR_PASSO := 2

## OS CINCO PAINÉIS QUE NENHUMA FOTO MOSTRAVA, e cada um abre PELA PORTA DO
## JOGADOR — a mesma pílula do HUD que ele toca, não uma chamada ao painel.
##
## ⚠️ E É ISTO QUE RESOLVE O `PainelCaixa`, que era INCAPTURÁVEL. O `setup()`
## dele exige um `Dictionary`, e a linha de comando não sabe escrever um: o
## `capturar_cena.gd` chamava-o com zero argumentos, o painel não montava, e a
## ferramenta imprimia "Tela salva em" e saía com código 0 com uma foto PRETA
## (medido em 21/09, `docs/decisoes/037`). Inventar uma sintaxe de dicionário
## na linha de comando seria FINGIR o estado; aqui quem passa o argumento é o
## `_on_caixa_pilula_input` do jogo, com `GameState.resumo_do_dia()` — que é a
## regra desta ferramenta desde sempre: o estado DERIVA-SE, não se escreve.
##
## O segundo campo diz se a porta é um TOQUE (as quatro pílulas do HUD pedem
## um `InputEvent`, e o `_e_toque_de_soltar` do Main tem uma regra própria que
## uma chamada direta não exercitaria) ou um botão. Nome que não esteja aqui
## REBENTA: um `--painel=caixaa` que não abrisse nada sairia com a foto do
## mapa e o nome do painel, que é a fotografia mentirosa outra vez.
const PAINEIS := {
	"construir": ["_on_upgrade_pressed", false],
	"caixa": ["_on_caixa_pilula_input", true],
	"calendario": ["_on_dia_pilula_input", true],
	"reputacao": ["_on_rep_pilula_input", true],
	"docas": ["_on_docas_pilula_input", true],
}
var _painel := ""
# A prova das caras e o tamanho da foto já gravada, para a linha de sucesso.
var _prova = null
var _tamanho := Vector2i.ZERO


func _process(_delta: float) -> bool:
	if not _montado:
		_montado = true
		_montar()
		return false

	# A PROVA DAS CARAS ANDA DEPOIS DA FOTO, que já está gravada
	# (`caras_na_foto.gd`).
	if _prova != null:
		if not _prova.andar(root):
			return false
		return _fechar_com_caras()

	# O BALANÇO ANDA ANTES DE ASSENTAR: cada passo toca um botão e espera que a
	# fila do `Main` ponha o painel seguinte na tela. Os frames de assentar só
	# começam a contar depois do último, com o balanço já montado.
	if _balanco and _passo_balanco in [1, 2]:
		_frames_do_passo += 1
		if _frames_do_passo < FRAMES_POR_PASSO:
			return false
		_frames_do_passo = 0
		return not _andar_o_balanco()

	# Alguns frames antes de fotografar: containers só calculam o layout
	# depois de um ciclo, e a foto sai com tudo empilhado no canto se for tirada
	# no primeiro frame.
	_frames += 1
	if _frames < FRAMES_ATE_ASSENTAR + _frames_extra:
		if GS.phase == "rival_offer":
			GS.negotiate_rival("igualar")
		# A contra-oferta fecha sempre — ela nunca é o assunto de foto nenhuma.
		# O BOLETIM só fecha se quem chamou pediu `limpo`, porque há um tiro
		# que existe para o fotografar.
		#
		# ⚠️ MENOS NO BALANÇO. O boletim da semana 4 é um dos passos dele, e
		# fecha-se pelo botão do boletim, como a jogar; dispensá-lo por aqui
		# saltaria o passo que prova que ele abriu na vez certa.
		if not _balanco:
			_fechar_paineis_de_rotina(_limpo)
		return false

	# ⚠️ O HISTÓRICO DA FAIXA ABRE DEPOIS DE ASSENTAR, e não no fim do laço de
	# turnos — e a diferença foi MEDIDA. Ele é um retrato do instante em que se
	# toca, e as falas da Dona Cida entram por `call_deferred`: aberto na mesma
	# volta em que o último turno acabou, a lista saía com CINCO enquanto a
	# faixa por trás já anunciava "+7", porque três linhas daquele turno ainda
	# não tinham corrido. A foto não estava errada — estava adiantada, que é
	# pior, porque parece um defeito da fila.
	#
	# É a regra dos dois frames do `CLAUDE.md` com outra roupa: o que foi posto
	# em `call_deferred` num frame só corre no fim dele.
	#
	# ⚠️ E ELE ABRE PELO TOQUE, não por uma chamada ao painel: a ferramenta usa
	# o caminho do jogador, como o avanço por turno usa o botão. O
	# `_on_faixa_input` tem uma regra própria — só reage ao SOLTAR — que uma
	# chamada direta não exercitaria.
	if _mensagens and not _mensagens_aberto:
		_mensagens_aberto = true
		var toque := InputEventMouseButton.new()
		toque.button_index = MOUSE_BUTTON_LEFT
		toque.pressed = false
		_main._on_faixa_input(toque)
		# O painel precisa de assentar como tudo o resto nesta ferramenta.
		_frames_extra += FRAMES_ATE_ASSENTAR
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
	# O balanço PROVA que chegou, e prova-o no nó: o laço, o pagamento e o
	# toque já reprovaram cada um pelo seu passo; aqui confere-se o que a
	# câmara vai apanhar — o painel de CIMA é o fim de fase, no segundo tempo,
	# de uma partida ganha.
	if _balanco:
		var topo: Node = _painel_de_cima()
		if topo == null or topo.scene_file_path != "res://scenes/EndGame.tscn" \
				or String(topo.get("tempo")) != "balanco" or not bool(GS.won):
			push_error("capturar_tela: pediu-se `balanco` e o painel de cima é %s no tempo «%s» (won=%s)"
				% ["(nenhum)" if topo == null else topo.scene_file_path,
				   "" if topo == null else String(topo.get("tempo")), str(GS.won)])
			quit(1)
			return true
	# O BOLETIM PEDIDO, e só ele: caso que declara um estado prova que o obteve
	# (`docs/decisoes/043`). A semana vem do resumo que o painel recebeu, como
	# no balanço — um boletim de outra semana também seria «o boletim».
	if _boletim_semana > 0:
		var topo_b: Node = _painel_de_cima()
		var semana_vista := -1
		if topo_b != null and topo_b.scene_file_path == "res://scenes/panels/PainelBoletim.tscn":
			semana_vista = int((topo_b.get("_resumo") as Dictionary)["semana"])
		if semana_vista != _boletim_semana or _paineis_abertos() != 1:
			push_error("capturar_tela: pediu-se o boletim da semana %d e a tela tem %d painel(eis), o de cima %s (semana %d)"
				% [_boletim_semana, _paineis_abertos(),
				   "(nenhum)" if topo_b == null else topo_b.scene_file_path, semana_vista])
			quit(1)
			return true
	# E O OCIOSO PROVA QUE NINGUÉM TRABALHOU, pela consequência: sem
	# trabalhador nenhum barco é servido. Um laço que voltasse a alocar
	# daria o boletim de quem joga com o nome de quem não joga.
	if _ocioso and int(GS.metrics["boats_served"]) != 0:
		push_error("capturar_tela: `ocioso` e a partida serviu %d barco(s)" % int(GS.metrics["boats_served"]))
		quit(1)
		return true
	print("Overlay: %d painel(eis)  [fase %s, turno %d, %d estrutura(s)]"
		% [_paineis_abertos(), GS.phase, GS.turn, GS.estruturas.size()])
	# ⚠️ E QUAL PAINEL, que é outra pergunta. A contagem diz QUANTOS e não QUAIS:
	# um tiro que prometa o Caixa e fotografe o Calendário cumpre a contagem e
	# entrega a foto errada. Mais fundo do que isso, era esta a pergunta que
	# faltava ao projeto INTEIRO — nada perguntava se um painel tem fotografia,
	# e foi assim que cinco deles viveram sem nenhuma (`docs/decisoes/038`).
	#
	# Com esta linha a cobertura passa a ser MEDIDA e não declarada: o
	# `conferir_cobertura_paineis.py` lê os logs da bateria e compara o conjunto
	# com o que o `Main` sabe abrir. Uma declaração à mão podia mentir; a foto
	# não.
	#
	# ⚠️ E O RÓTULO É ASCII DE PROPÓSITO. A saída desta ferramenta é contrato —
	# o `capturar_evidencia.sh` procura `Overlay:` e `Tela salva em` —, e um
	# padrão com acento depende do locale de quem roda o `grep`. O que se perde
	# é um til; o que se ganha é a guarda não mudar de comportamento entre o
	# contêiner e o runner.
	print("Paineis: %s" % _paineis_na_tela())
	# O TEMPO de cada painel que tenha mais de um — a mesma linha do
	# `capturar_cena.gd`, lida pelo `conferir_cobertura_paineis.py`
	# (`docs/decisoes/051`).
	for linha in _tempos_na_tela():
		print(linha)

	var img: Image = root.get_texture().get_image()
	var erro := img.save_png(_saida)
	if erro != OK:
		print("FALHOU ao salvar em %s (erro %d)" % [_saida, erro])
		quit(1)
		return true
	_tamanho = img.get_size()
	# E AS CARAS DO PAINEL DE CIMA, que é o único que a foto mostra inteiro: o
	# de baixo fica atrás do escurecer e, quase sempre, do cartão do de cima
	# (`docs/decisoes/060`). A prova anda nas voltas seguintes — esconde as
	# caras e fotografa outra vez —, e o PNG que fica é este.
	_prova = load("res://tools/caras_na_foto.gd").new(_painel_de_cima(), img)
	return false


func _fechar_com_caras() -> bool:
	for falha in _prova.falhas:
		print("FALHOU  %s" % falha)
	if not _prova.falhas.is_empty():
		quit(1)
		return true
	for linha in _prova.linhas:
		print(linha)
	print("Tela salva em %s (%dx%d)" % [_saida, _tamanho.x, _tamanho.y])
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
		if bruto.begins_with("--frames="):
			var qtd := bruto.substr(9)
			if not qtd.is_valid_int():
				push_error("captura: --frames= precisa de um inteiro, veio '%s'" % qtd)
				quit(1)
				return
			_frames_extra = int(qtd)
			continue
		if bruto.begins_with("--painel="):
			var nome := bruto.substr(9)
			if not PAINEIS.has(nome):
				push_error("captura: --painel= não conhece '%s'. São: %s"
					% [nome, ", ".join(PAINEIS.keys())])
				quit(1)
				return
			_painel = nome
			continue
		if bruto.begins_with("--boletim="):
			var semana := bruto.substr(10)
			if not semana.is_valid_int() or int(semana) < 1:
				push_error("captura: --boletim= precisa de uma semana (1 ou mais), veio '%s'" % semana)
				quit(1)
				return
			_boletim_semana = int(semana)
			continue
		if bruto.begins_with("--semente="):
			var valor := bruto.substr(10)
			if not valor.is_valid_int():
				push_error("captura: --semente= precisa de um inteiro, veio '%s'" % valor)
				quit(1)
				return
			_semente = int(valor)
			continue
		args.append(bruto)

	_limpo = args.has("limpo")
	_pausa = args.has("pausa")
	_alocar = args.has("alocar")
	_ocioso = args.has("ocioso")
	# ⚠️ BANDEIRAS QUE SE DESMENTEM REPROVAM, em vez de uma ganhar em silêncio:
	# `ocioso alocar` fotografaria o porto a operar com o nome de quem nunca
	# alocou, e `limpo` fecha todo boletim — o do `--boletim=` também.
	if _ocioso and _alocar:
		push_error("captura: `ocioso` e `alocar` desmentem-se — escolha um")
		quit(1)
		return
	if _boletim_semana > 0 and args.has("limpo"):
		push_error("captura: `limpo` fecha o boletim que o `--boletim=` quer fotografar")
		quit(1)
		return
	_escolher = args.has("escolher")
	_mensagens = args.has("mensagens")
	_balanco = args.has("balanco")

	var turnos := TURNOS_PADRAO
	if args.size() >= 1 and str(args[0]).is_valid_int():
		turnos = int(args[0])
	if args.size() >= 2:
		_saida = str(args[1])

	# ⚠️ E O ESPAÇO É O 1, COM OS OUTROS VAZIOS (`066`). O autoload arranca no
	# espaço jogado por último, e a pasta das ferramentas guarda o que a foto
	# anterior da bateria lá deixou — as da tela inicial ocupam o 3. A pausa
	# escreve «espaço N de 3», e N sairia da ORDEM dos tiros.
	for n in range(2, GS.ESPACOS + 1):
		GS.apagar_espaco(n)

	# A SEMENTE VEM ANTES DE `new_game()`, e é a mesma armadilha que o
	# `simular_balanceamento.gd` documenta: `new_game()` já chama
	# `_spawn_boats()`, de modo que semear depois deixaria a mão inicial a sair
	# do gerador não semeado (`_rng.randomize()` no `_ready`). Lá custava
	# medianas diferentes entre duas rodadas iguais; aqui custa uma foto que
	# não se pode comparar com a anterior.
	GS._rng.seed = _semente
	GS.comecar_no_espaco(1)

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

	# ⚠️ O AVANÇO É POR TURNO EFETIVO, E PELO CAMINHO DO JOGADOR.
	#
	# Até 17/09 isto era `for t in range(turnos)` com um `continue` na oferta
	# do rival, e o `continue` gastava a iteração sem virar turno nenhum:
	# `-- 10` entregava o turno 9. Não era um turno de erro fixo — com esta
	# semente, `-- 34` entregava o turno 27, sete iterações comidas, e o erro
	# cresce com N porque cada oferta come mais uma.
	#
	# E o laço avançava POR BAIXO DO MODAL. O botão "Avançar dia" do jogo fica
	# debaixo do escurecer de todo `PainelNarrativo` — um `ColorRect` ancorado
	# a tela cheia, no `CanvasLayer` do Overlay, com o `mouse_filter` de
	# omissão —, de modo que com um painel aberto o toque não lhe chega. Este
	# laço chamava `GS.advance_turn()` direto e não tinha como saber disso:
	# medido, `-- 12` dava "Dia 11/32" com o Boletim por cima a dizer "Semana 1
	# de 4", e `-- 34` empilhava TRÊS Boletins. Nenhuma dessas fotos é um
	# estado que alguém alcance a jogar, que é tudo o que uma captura serve
	# para provar.
	#
	# Quem avança agora é `_main._on_advance_pressed()`, o mesmo que o botão
	# chama. A condição de parar é a do botão (`phase != "playing"` desliga-o)
	# mais a do escurecer: com um painel por cima, ou ele é de ROTINA e fecha
	# como o jogador o fecharia, ou o avanço acaba ali.
	var alvo: int = int(GS.turn) + turnos
	# O TETO É DE VOLTAS, não de turnos, e é a contrapartida de o laço ter
	# deixado de contar iterações: a oferta do rival passou a poder repetir a
	# volta sem virar turno, e uma fase que esta ferramenta não saiba responder
	# giraria aqui para sempre. Não é hipótese: um erro de execução dentro do
	# `_process` de um `SceneTree` não aborta nada — repete-se a cada frame, e
	# uma sonda escreveu 11 MB de log em dois minutos a provar isso.
	# Duas voltas por turno pedido chegam de sobra, que a oferta não se repete
	# no mesmo turno; as oito de folga são para o caso de N ser zero.
	var teto: int = turnos * 2 + 8
	var voltas := 0
	while int(GS.turn) < alvo:
		voltas += 1
		if voltas > teto:
			push_error("captura: %d voltas para avancar %d turno(s) — parado no turno %d, fase %s"
				% [voltas, turnos, int(GS.turn), GS.phase])
			quit(1)
			return
		# A oferta do rival é uma DECISÃO, e responder a uma decisão não é
		# gastar um dia: o `while` olha o turno, portanto esta volta não conta.
		if GS.phase == "rival_offer":
			GS.negotiate_rival("metade")
			_fechar_paineis_de_rotina(false)
			continue
		if GS.phase != "playing":
			break
		if _paineis_abertos() > 0:
			_fechar_paineis_de_rotina(_limpo)
			# Sobrou painel: ou é o Boletim num tiro que o quer fotografar, ou
			# é uma tela que o jogo espera que alguém responda. Nos dois casos
			# o dia acaba aqui — e quem chamou confere o turno em que acabou.
			if _paineis_abertos() > 0:
				break
		if not _ocioso:
			_alocar_todos()
		_main._on_advance_pressed()

	# `pausa` fotografa o menu de pausa, que é onde vivem os sliders de volume.
	# Sem isto a única forma de conferir aquele painel era abrir o editor — e é
	# um painel construído por código, portanto o que mais escapa ao olho.
	#
	# ⚠️ E ELE ABRE DEPOIS DE JOGAR, que é a única ordem possível. Estava
	# ANTES do laço, e nessa ordem os oito turnos daquele tiro corriam por
	# baixo do menu de pausa — o mesmo defeito do Boletim, na tela que o
	# jogador usa justamente para PARAR o jogo. Com o laço a recusar-se a
	# avançar sob modal, abrir aqui é o que o torna fotografável: joga-se, e
	# só então se pausa.
	if _pausa:
		_main._on_pause_pressed()

	if _balanco and not _pagar_a_parcela():
		return


	# ⚠️ E UMA ALOCAÇÃO NO FIM, sob pedido. O laço aloca ANTES de cada avanço,
	# de modo que a foto sai sempre com os trabalhadores livres e as docas à
	# espera — que é um estado verdadeiro do jogo, e é por isso que os tiros do
	# mapa ficam como estão. Mas há uma mecânica que só existe com o porto A
	# OPERAR: o camião que sai da rua e encosta no berço do navio que está a ser
	# servido. Sem esta linha ela não aparece em fotografia nenhuma, que é a
	# forma exata do buraco do `barco_medio`.
	if _alocar:
		_alocar_todos()
		_main._refresh_all()

	# ⚠️ E UMA SELEÇÃO, sob pedido. O cartão do trabalhador ESCOLHIDO tem
	# borda própria — âmbar e do dobro da largura —, e até 22/09 ele não estava
	# em foto NENHUMA das 24: a seleção é um TOQUE, e nada na bateria tocava.
	# A cor dele viveu assim quatro levas de migração, fora do alcance da única
	# prova que as outras quatro usaram (a identidade byte a byte com controle
	# positivo), porque um controle positivo sobre um estado que nenhuma foto
	# monta mexe em ZERO fotos e não prova coisa nenhuma — `docs/decisoes/042`.
	#
	# Entra pela PORTA DO JOGADOR: `_on_worker_selecionado()` é o que o
	# `_gui_input` do cartão emite. Escrever `_selecionado` à mão poria a
	# borda certa com o resto do HUD parado.
	if _escolher:
		_escolher_trabalhador()


	# ⚠️ E O PAINEL ABRE POR ÚLTIMO, DEPOIS DA ALOCAÇÃO. Os cinco leem o estado
	# no `setup()`, uma vez, e nunca mais: o `PainelDocas` conta as docas
	# ocupadas e o `PainelCaixa` projeta o dia a partir de quem tem trabalhador.
	# Aberto antes do `_alocar_todos()`, cada um retrataria o estado de ANTES da
	# última alocação enquanto o mapa por trás já mostrava o de depois — a foto
	# adiantada de 19/09 com a tela e o painel trocados de lado.
	#
	# E é aqui, e não no `_process`, porque estes não dependem de nada adiado:
	# o histórico da faixa abre lá por causa das falas em `call_deferred`, e
	# aqui os quinze frames de assentar correm DEPOIS da abertura, que é o que
	# dá ao cartão o ciclo de layout de que ele precisa.
	if _painel != "":
		_abrir_painel_do_jogador()


# ⚠️ A PORTA TEM DE EXISTIR, e um nome trocado no `Main` não dá erro nenhum:
# `call()` num método inexistente devolve `null` e segue. A foto sairia do mapa
# com o nome do painel no arquivo — a fotografia mentirosa que a contagem de
# painéis do `capturar_evidencia.sh` apanha, mas só depois de a corrida inteira
# ter acontecido e só porque alguém escreveu o número lá. Perguntar aqui custa
# uma linha e diz QUAL porta mudou de sítio.
func _abrir_painel_do_jogador() -> void:
	var dados: Array = PAINEIS[_painel]
	var metodo: String = String(dados[0])
	if not _main.has_method(metodo):
		push_error("captura: o Main não tem %s — a porta do painel '%s' mudou de nome"
			% [metodo, _painel])
		quit(1)
		return
	if bool(dados[1]):
		var toque := InputEventMouseButton.new()
		toque.button_index = MOUSE_BUTTON_LEFT
		toque.pressed = false
		_main.call(metodo, toque)
	else:
		_main.call(metodo)


# O VENCIMENTO E O PAGAMENTO, cada um pela porta do jogador e cada um a
# reprovar se não chegar onde diz. O `pay_debt()` sai CALADO fora de
# `debt_payment` (`docs/decisoes/051`), por isso a fase confere-se ANTES do
# toque, e o dinheiro DEPOIS — é ele que prova que o toque pagou. O resto do
# caminho até ao balanço anda no `_process`, um passo por vez.
func _pagar_a_parcela() -> bool:
	var ribeiro: Node = _painel_de_cima()
	if GS.phase != "debt_payment" or ribeiro == null \
			or ribeiro.scene_file_path != "res://scenes/panels/DebtPaymentPanel.tscn":
		push_error("capturar_tela: `balanco` precisa do Sr. Ribeiro por cima no vencimento — fase %s, turno %d, painel de cima %s"
			% [GS.phase, int(GS.turn), "(nenhum)" if ribeiro == null else ribeiro.scene_file_path])
		quit(1)
		return false
	if not _tocar(ribeiro, "Pagar"):
		return false
	if not bool(GS.parcela_paid) or GS.phase != "game_over" or not bool(GS.won):
		push_error("capturar_tela: o «Pagar» não acabou a partida paga (parcela_paid=%s, fase %s, won=%s)"
			% [str(GS.parcela_paid), GS.phase, str(GS.won)])
		quit(1)
		return false
	# A partida acabou e a semana 4 fechou, mas o boletim e o fim de fase estão
	# na fila: na tela fica só a resposta de quem recebeu.
	if not _sozinho_por_cima("res://scenes/panels/DebtPaymentPanel.tscn", "pagou",
			"depois de pagar"):
		return false
	if not _tocar(ribeiro, "Até a próxima"):
		return false
	_passo_balanco = 1
	return true


# UM PASSO DA FILA DO FIM: o painel que a ordem diz está SOZINHO na tela, e o
# botão dele passa a vez ao seguinte. Devolve `false` depois de reprovar.
func _andar_o_balanco() -> bool:
	if _passo_balanco == 1:
		if not _sozinho_por_cima("res://scenes/panels/PainelBoletim.tscn", "",
				"fechada a resposta do Sr. Ribeiro"):
			return false
		# A semana vem do resumo que o boletim recebeu, e não do calendário: um
		# boletim de outra semana que calhasse aqui também seria «o boletim».
		var semana: int = int((_painel_de_cima().get("_resumo") as Dictionary)["semana"])
		if semana != int(GS.WEEKS_TOTAL):
			push_error("capturar_tela: o boletim do fim é o da semana %d, e a última é a %d"
				% [semana, int(GS.WEEKS_TOTAL)])
			quit(1)
			return false
		if not _tocar(_painel_de_cima(), "Fechar o boletim"):
			return false
		_passo_balanco = 2
		return true
	if not _sozinho_por_cima("res://scenes/EndGame.tscn", "narracao",
			"fechado o boletim"):
		return false
	if not _tocar(_painel_de_cima(), "Ver o balanço"):
		return false
	_passo_balanco = 3
	return true


func _sozinho_por_cima(cena: String, tempo: String, quando: String) -> bool:
	var topo: Node = _painel_de_cima()
	var tempo_visto: String = "" if topo == null or not "tempo" in topo \
		else String(topo.get("tempo"))
	if topo != null and topo.scene_file_path == cena and tempo_visto == tempo \
			and _paineis_abertos() == 1:
		return true
	push_error("capturar_tela: %s devia estar só %s%s na tela, e estão %d: %s  [%s]"
		% [quando, cena, "" if tempo == "" else " «%s»" % tempo, _paineis_abertos(),
		   _paineis_na_tela(), " ".join(_tempos_na_tela())])
	quit(1)
	return false


# O BOTÃO VERDADEIRO, e um só, ligado — a regra do `--tocar=` do
# `capturar_cena.gd`: dois seria escolher por posição, e um desligado seria um
# toque que o jogador não consegue dar.
func _tocar(painel: Node, prefixo: String) -> bool:
	var achados: Array = []
	_botoes_com(painel, prefixo, achados)
	if achados.size() != 1 or (achados[0] as Button).disabled:
		push_error("capturar_tela: esperava um botão «%s…» ligado em %s e achei %d%s"
			% [prefixo, painel.scene_file_path, achados.size(),
			   " (desligado)" if achados.size() == 1 else ""])
		quit(1)
		return false
	(achados[0] as Button).pressed.emit()
	return true


func _botoes_com(no: Node, prefixo: String, achados: Array) -> void:
	if no is Button and (no as Button).is_visible_in_tree() \
			and not no.is_queued_for_deletion() and (no as Button).text.begins_with(prefixo):
		achados.append(no)
	for filho in no.get_children():
		_botoes_com(filho, prefixo, achados)


func _painel_de_cima() -> Node:
	var overlay: Node = null if _main == null else _main.get_node_or_null("Overlay")
	if overlay == null or overlay.get_child_count() == 0:
		return null
	return overlay.get_child(overlay.get_child_count() - 1)


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
		# O `--boletim=N` fecha os das semanas de ANTES, que são o caminho até
		# ele, e deixa o dele na tela — é aí que o laço pára.
		if _boletim_semana > 0 and script != null \
				and script.resource_path.ends_with("PainelBoletim.gd") \
				and int((painel.get("_resumo") as Dictionary)["semana"]) < _boletim_semana:
			rotina = true
		if rotina:
			overlay.remove_child(painel)
			painel.queue_free()


# A CENA de cada painel aberto, e não o script dele: é `.tscn` que o `Main`
# guarda nos `preload`, então é `.tscn` que o portão compara. `(nenhum)` está
# escrito por extenso porque uma linha VAZIA não se distingue de uma linha que
# não chegou a ser impressa — a mesma razão de o `tirar()` perguntar primeiro
# se o log existe.
func _paineis_na_tela() -> String:
	if _main == null:
		return "(nenhum)"
	var overlay := _main.get_node_or_null("Overlay")
	if overlay == null:
		return "(nenhum)"
	var cenas := PackedStringArray()
	for painel in overlay.get_children():
		var cena: String = painel.scene_file_path
		cenas.append(cena if cena != "" else "(sem cena)")
	if cenas.is_empty():
		return "(nenhum)"
	return " ".join(cenas)


func _tempos_na_tela() -> PackedStringArray:
	var linhas := PackedStringArray()
	var overlay: Node = null if _main == null else _main.get_node_or_null("Overlay")
	if overlay == null:
		return linhas
	for painel in overlay.get_children():
		if "tempo" in painel and String(painel.get("tempo")) != "":
			linhas.append("Tempo: %s %s" % [painel.scene_file_path, String(painel.get("tempo"))])
	return linhas


func _paineis_abertos() -> int:
	if _main == null:
		return 0
	var overlay := _main.get_node_or_null("Overlay")
	if overlay == null:
		return 0
	return overlay.get_child_count()


# ⚠️ E ELA REPROVA SE NÃO CONSEGUIR O ESTADO. Um tiro que peça a seleção e não
# a obtenha sairia com o cartão em repouso, com o tamanho certo e o turno
# certo, e passaria por bom — é «estado que não monta publica linhas
# plausíveis» (`docs/decisoes/043`) com um PNG no lugar da linha. A prova é
# DERIVADA: vai ver no `Main` quem ficou escolhido.
func _escolher_trabalhador() -> void:
	for w in GS.workers:
		var wid := int(w["id"])
		if int(w["busy_turns"]) > 0 or GS.worker_dock_index(wid) >= 0:
			continue
		_main._on_worker_selecionado(wid)
		break
	if _main._selecionado < 0:
		push_error("capturar_tela: pediu-se `escolher` e nenhum trabalhador ficou escolhido")
		quit(1)
		return
	print("Escolhido: trabalhador #%d" % _main._selecionado)


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
