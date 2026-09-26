extends PainelNarrativo

# ============================================================
# BR Port VS — o MENU, que é um celular
#
# Item 17 do segundo playtest, na letra do Bruno: *"Crie no HUD inferior uma
# botão de menu, onde nesse menu estarão os atalhos do mapa da cidade e loja,
# por exemplo. Inclusive esse menu pode ser um celular e os aplicativos seriam
# essas outras partes do jogo."*
#
# ESTA TELA É A CASCA, e só ela. O mapa da cidade, as lojas e as missões são
# os itens 18 a 21, que o próprio plano classifica como "um segundo jogo" e
# que assentam numa pergunta ainda sem resposta — a economia das fases
# seguintes, na `BR_Port_GDD_V7_ERRATA_ECONOMIA.md`. Construí-los aqui seria
# escolher essa economia de passagem.
#
# ⚠️ E ELA É UM OVERLAY, NUNCA UMA FASE DO `GameState`. Uma fase a mais fez 24
# de 30 partidas não terminarem, com o CI verde — o `advance_turn()` retorna
# calado fora de "playing" e o laço do simulador só sabe resolver duas fases.
# Como overlay, o balanceamento medido fica intocado POR CONSTRUÇÃO e não por
# cuidado de quem escreveu isto.
#
# ── POR QUE CELULAR, E NÃO MAIS UM CARTÃO BRANCO ──
#
# A metáfora era sugestão e não ordem, e a conta que a aprovou é esta: a
# moldura do aparelho SUBSTITUI a margem do cartão em vez de se somar a ela.
# Medido — o cartão padrão tem 12 px de margem de cada lado e 2 de borda, o
# que num painel de 400 deixa 372 de conteúdo; o corpo do celular gasta 10 de
# margem e 2 de borda, e a tela mais 12, o que deixa 352. **São 20 px de 372,
# 5,4%** (13/09; desde a `066` a moldura é 12 e o miolo 14, o que deixa 348 —
# 24 px, 6,5%), e em troca o menu ganha um registo visual próprio — que é
# exactamente a divisão que os itens 18 a 21 fazem: o porto de um lado, a
# cidade do outro.
#
# ── O QUE ENTRA AQUI, E O QUE NÃO ENTRA ──
#
# Só o que NÃO TEM PORTA. As quatro pílulas do HUD já abrem caixa, calendário,
# reputação e docas; o cartão da parcela abre a parcela; o botão Construir
# abre as estruturas. Repetir qualquer uma delas aqui seria o defeito que este
# projeto já registou a propósito do chip do dia — "abrir dois painéis para a
# mesma pergunta é pedir ao jogador para comparar um com o outro".
#
# O que sobrou dessa peneira foi UMA coisa: o **diário do avô**, que abre uma
# vez na abertura do jogo, encadeado à tela de nomes, e nunca mais. É texto
# escrito, com a origem do caixa inicial lá dentro (`docs/decisoes/018`), que
# o jogador não podia reler.
#
# ── E O MENU DE PAUSA NÃO É ABSORVIDO ──
#
# Ele carrega volume, "Copiar registro da partida" e "Novo jogo (apaga
# progresso)" — coisas de SISTEMA, que existem fora da ficção. Este celular é
# um objeto DO MUNDO: o telefone de quem toma conta do porto. Misturar os dois
# poria um botão destrutivo ao lado de uma loja, e o botão Pausar já está no
# canto onde a convenção do gênero o põe.
# ============================================================

## Pedido para abrir um app. É SINAL e não uma chamada ao `Main`, pela mesma
## razão do `ver_balanco` do menu de pausa: este painel vive no
## `_overlay_layer` e não conhece quem o abriu — alcançar o pai pelo caminho
## seria um `get_parent().get_parent()` que quebra calado no dia em que a
## árvore mudar.
##
## ⚠️ E ELE LEVA A CENA, NÃO O ID. Com um id, o Main precisaria da sua própria
## tabela de "qual id abre o quê" — e duas listas que nada obriga a concordar
## são a fonte dupla que já custou caro neste projeto. A tabela abaixo é a
## única que sabe o que cada app abre.
signal abrir_app(cena: String)

const LARGURA := 400

# ⚠️ A ALTURA É FIXA, E É A ÚNICA COISA QUE FAZ ISTO LER COMO UM TELEFONE.
#
# O andaime deste projeto manda `montar(largura, 0)` — ajustar ao conteúdo —
# porque altura fixa já deixou faixa branca debaixo do botão em três painéis.
# Aqui é ao contrário, e mede-se: com altura ao conteúdo o aparelho saía
# 400 x 390, quase quadrado, e na primeira captura lia-se como mais um cartão
# de cantos redondos. Um telefone é ALTO — a proporção é o que o olho
# reconhece antes do ícone —, e 400 x 680 dá 1:1,7.
#
# E o vazio que sobra na tela não é a tal faixa branca: aquela era cartão sem
# conteúdo, esta é a tela de um telefone com lugar para mais apps, que é
# exatamente o que os itens 18 a 21 vão pôr lá. Cabe nos 1280 do retrato com
# 300 px de folga de cada lado — 230 em baixo desde que o «Guardar o
# telefone» saiu do aparelho para debaixo dele (`066`).
const ALTURA := 680

# O tile de um app. 72 está acima do alvo de toque mínimo (44) com folga, e é
# o tamanho em que o ícone de telefone — quadrado de cor com o desenho dentro —
# se lê a meio metro do rosto.
const TILE := 72
const COLUNAS := 3
const SEPARACAO_H := 30
const SEPARACAO_V := 14
# O que afasta o conteúdo da borda da tela. A barra de status vai de borda a
# borda (a tela não tem margem desde a `066`), e o resto vive dentro disto.
const MARGEM_TELA := 14

# ⚠️ A TABELA DOS APPS, E CADA UM TEM O SEU ÍCONE desde 26/09 (`066`).
#
# Até então os quatro que não abrem mostravam o MESMO cadeado, de propósito:
# desenhar a gramática de uma loja antes de a construir era escolher a
# economia dela de passagem. O Bruno reabriu isto na família do sistema —
# «ícones com cor própria» — e os fechados passaram a mostrar, velados, o que
# vão ser; o cadeado ficou como selo por cima. Quem o distingue continua a ser
# também o NOME, que está sempre lá.
#
# `cena` vazia quer dizer porta fechada — e é o campo que decide, não uma
# segunda lista de ids que pudesse discordar desta.
const APPS := [
	{"id": "diario", "nome": "Diário", "icone": Icones.APP_DIARIO, "cena": "res://scenes/panels/PainelDiario.tscn"},
	{"id": "cidade", "nome": "Cidade", "icone": Icones.APP_CIDADE, "cena": ""},
	{"id": "lojas", "nome": "Lojas", "icone": Icones.APP_LOJAS, "cena": ""},
	{"id": "missoes", "nome": "Missões", "icone": Icones.APP_MISSOES, "cena": ""},
	{"id": "analise", "nome": "Análise", "icone": Icones.APP_ANALISE, "cena": ""},
]

# ⚠️ A LINHA QUE FAZ DE UMA PORTA FECHADA UMA PORTA, e não um botão morto.
#
# Ela é UMA para todos os fechados em vez de uma por tile, e isso é escolha de
# espaço medida: a coluna tem ~100 px e "Abre na Fase 2" pede duas linhas de
# texto dentro dela, o que triplicaria a altura da grelha para repetir quatro
# vezes a mesma frase. Desde a `066` ela é um aviso, no cartão de um widget,
# com o cadeado ao lado — o mesmo selo que vai em cima dos ícones.
const RODAPE_FECHADOS := "Os apps com cadeado abrem na Fase 2, quando a cidade abrir."

# O PAPEL DE PAREDE é a ilustração da tela inicial (escolha do Bruno: uma
# peça, dois usos). Lida da constante de lá, e não de um segundo caminho
# escrito aqui: quando a ilustração chegar, muda uma linha e mudam os dois.
const TelaInicialScript := preload("res://scripts/TelaInicial.gd")

# A HORA DAS FERRAMENTAS. A barra de status mostra a hora do aparelho, e uma
# foto com a hora de verdade seria diferente a cada minuto — a bateria de
# captura compara fotos. Sob `--script` a hora é esta, fixa; é a mesma regra
# do `ArmazemLocal`, que dá às ferramentas o que o jogo não lhes pode dar.
const HORA_DAS_FERRAMENTAS := "09:41"

var _hora: Label


func setup(_sem_argumentos: Variant = null) -> void:
	montar(LARGURA, ALTURA, ESCURO_DECISAO, "Celular")

	# SEM `titulo()`, e não por esquecimento: o título do andaime é um `Label`
	# com a cor padrão do tema, que é navy porque todos os outros painéis são
	# cartões brancos. Sobre a tela do celular ele seria navy sobre navy. Quem
	# faz o papel de título aqui é a barra de status.
	var tela := PanelContainer.new()
	tela.name = "Tela"
	tela.theme_type_variation = &"CelularTela"
	# A TELA ESTICA E O CONTEÚDO DELA NÃO. Sem o `EXPAND_FILL` a tela encolhe
	# ao tamanho dos apps e o resto do aparelho fica com a cor do CORPO.
	tela.size_flags_vertical = Control.SIZE_EXPAND_FILL
	# ⚠️ A TELA RECORTA OS FILHOS PELO QUE ELA DESENHA: é o canto de 32 do
	# `CelularTela` que arredonda o papel de parede. Sem isto a imagem sairia
	# com quatro pontas quadradas por fora do vidro.
	tela.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
	_vbox.add_child(tela)

	var parede := TextureRect.new()
	parede.name = "PapelDeParede"
	parede.texture = TelaInicialScript.FUNDO
	parede.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	parede.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	parede.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tela.add_child(parede)

	var coluna := VBoxContainer.new()
	coluna.add_theme_constant_override("separation", 0)
	tela.add_child(coluna)
	coluna.add_child(_barra_de_status())

	var miolo := MarginContainer.new()
	miolo.name = "Miolo"
	for lado in ["margin_left", "margin_top", "margin_right", "margin_bottom"]:
		miolo.add_theme_constant_override(lado, MARGEM_TELA)
	miolo.size_flags_vertical = Control.SIZE_EXPAND_FILL
	coluna.add_child(miolo)

	var dentro := VBoxContainer.new()
	dentro.add_theme_constant_override("separation", 16)
	miolo.add_child(dentro)
	dentro.add_child(_widget_do_dia())

	var grade := GridContainer.new()
	grade.columns = COLUNAS
	grade.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	grade.add_theme_constant_override("h_separation", SEPARACAO_H)
	grade.add_theme_constant_override("v_separation", SEPARACAO_V)
	dentro.add_child(grade)
	for app in APPS:
		grade.add_child(_app(app))

	# O VÃO QUE EMPURRA O AVISO PARA O FUNDO DO VISOR: os apps em cima, o aviso
	# em baixo, e o papel de parede a ver-se no meio — que é como um telefone
	# com poucos apps se parece de verdade.
	var vao := Control.new()
	vao.size_flags_vertical = Control.SIZE_EXPAND_FILL
	dentro.add_child(vao)
	dentro.add_child(_aviso_dos_fechados())
	dentro.add_child(_barra_de_gesto())

	_botoes_laterais()
	_botao_guardar()


# A BARRA DE STATUS: a hora à esquerda, a câmera no meio, o sinal e a bateria
# à direita — o desenho de todo telefone com entalhe. O dia do jogo, que vivia
# aqui, passou para o widget abaixo, que é onde um telefone põe a data grande.
# Desde a quarta passagem ela não tem fundo: pousa no papel de parede.
func _barra_de_status() -> Control:
	var barra := PanelContainer.new()
	barra.name = "BarraDeStatus"
	barra.theme_type_variation = &"CelularBarra"
	var linha := HBoxContainer.new()
	barra.add_child(linha)

	# ⚠️ A HORA POUSA NO PAPEL DE PAREDE desde a quarta passagem (`066`), e o
	# fundo dela passou a ser o CONTORNO da letra (`TextoCelularStatus`) — é
	# contra ele que a régua a mede, e sem ele ela volta a pendência.
	_hora = Label.new()
	_hora.name = "Hora"
	_hora.theme_type_variation = &"TextoCelularStatus"
	_hora.text = _hora_agora()
	_hora.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	linha.add_child(_hora)

	var camera := PanelContainer.new()
	camera.name = "Camera"
	camera.theme_type_variation = &"CelularCamera"
	camera.custom_minimum_size = Vector2(64, 18)
	camera.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	linha.add_child(camera)

	var direita := HBoxContainer.new()
	direita.alignment = BoxContainer.ALIGNMENT_END
	direita.add_theme_constant_override("separation", 6)
	direita.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	direita.add_child(Icones.imagem(Icones.CELULAR_SINAL, 16))
	direita.add_child(Icones.imagem(Icones.CELULAR_BATERIA, 20))
	linha.add_child(direita)

	# O RELÓGIO ANDA enquanto o telefone está aberto — uma hora parada num
	# telefone lê-se como defeito. Sob ferramenta não há relógio: a foto é
	# sempre a mesma.
	if not ArmazemLocal.sob_ferramenta():
		var relogio := Timer.new()
		relogio.wait_time = 5.0
		relogio.autostart = true
		relogio.timeout.connect(func() -> void: _hora.text = _hora_agora())
		barra.add_child(relogio)
	return barra


static func _hora_agora() -> String:
	if ArmazemLocal.sob_ferramenta():
		return HORA_DAS_FERRAMENTAS
	var agora := Time.get_time_dict_from_system()
	return "%02d:%02d" % [int(agora["hour"]), int(agora["minute"])]


# O WIDGET DO DIA: o número grande, como a data na tela de início de um
# telefone. Os números saem do `GameState`, e não são escritos aqui — é a
# mesma regra do `_refresh_hud`.
#
# ⚠️ E ELE «PARECIA CAMPO» (quarta passagem da `066`): um retângulo contornado
# com duas linhas de texto encostadas à esquerda é a forma de uma caixa de
# texto. O que o faz ler como widget é a HIERARQUIA — o cabeçalho pequeno em
# cor, o número grande, e uma peça que não é texto: a FITA DOS DIAS, um traço
# por dia da partida, agrupados por semana. É a forma do calendário, e diz
# «semana 2 de 4» sem uma palavra.
func _widget_do_dia() -> Control:
	var cartao := PanelContainer.new()
	cartao.name = "WidgetDoDia"
	cartao.theme_type_variation = &"CelularWidget"
	var coluna := VBoxContainer.new()
	coluna.add_theme_constant_override("separation", 2)
	cartao.add_child(coluna)

	var dia: int = mini(GameState.turn, GameState.TURNS_TOTAL)
	var cabeca := Label.new()
	cabeca.name = "Semana"
	cabeca.theme_type_variation = &"TextoCelularDestaque"
	cabeca.text = ("Semana %d de %d" % [GameState.week_of(maxi(dia, 1)),
		GameState.WEEKS_TOTAL]).to_upper()
	coluna.add_child(cabeca)

	var linha := HBoxContainer.new()
	linha.add_theme_constant_override("separation", 8)
	coluna.add_child(linha)
	var grande := Label.new()
	grande.name = "Dia"
	grande.theme_type_variation = &"TextoCelularGrande"
	grande.text = "Dia %d" % dia
	linha.add_child(grande)
	var total := Label.new()
	total.name = "DeTotal"
	total.theme_type_variation = &"TextoCelularFraco"
	total.text = "de %d" % GameState.TURNS_TOTAL
	# Na linha de base do número, e não no meio dele: é como uma data se lê.
	total.size_flags_vertical = Control.SIZE_SHRINK_END
	total.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	linha.add_child(total)

	var vao := Control.new()
	vao.custom_minimum_size = Vector2(0, 6)
	coluna.add_child(vao)
	coluna.add_child(_fita_dos_dias(dia))
	return cartao


# A FITA: TURNS_TOTAL traços, em WEEKS_TOTAL grupos. Os grupos e os traços
# esticam por igual (`EXPAND_FILL`), então a fita enche a placa sem uma
# largura escrita aqui — e continua a caber se a semana mudar de tamanho.
func _fita_dos_dias(dia: int) -> Control:
	var fita := HBoxContainer.new()
	fita.name = "FitaDosDias"
	fita.add_theme_constant_override("separation", 7)
	var por_semana: int = GameState.TURNS_PER_WEEK
	for s in GameState.WEEKS_TOTAL:
		var semana := HBoxContainer.new()
		semana.add_theme_constant_override("separation", 2)
		semana.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		fita.add_child(semana)
		for d in por_semana:
			var n: int = s * por_semana + d + 1
			var traco := PanelContainer.new()
			traco.custom_minimum_size = Vector2(2, 6)
			traco.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			traco.mouse_filter = Control.MOUSE_FILTER_IGNORE
			if n < dia:
				traco.theme_type_variation = &"CelularDiaPassado"
			elif n == dia:
				traco.theme_type_variation = &"CelularDiaHoje"
			else:
				traco.theme_type_variation = &"CelularDiaFuturo"
			semana.add_child(traco)
	return fita


# Um app: o ícone por cima, o nome por baixo, numa pílula.
#
# O ícone ABERTO é um `Button` e o FECHADO é um `PanelContainer`, e a
# diferença não é decorativa. Um botão que não responde ao toque ensina o
# jogador a não tocar no menu — e este menu vai encher-se de portas nos itens
# seguintes. Um ícone velado que nunca foi botão não promete nada, e o aviso
# diz o que falta para ele acender.
func _app(app: Dictionary) -> Control:
	var caixa := VBoxContainer.new()
	caixa.add_theme_constant_override("separation", 6)
	caixa.alignment = BoxContainer.ALIGNMENT_BEGIN

	var aberto: bool = String(app["cena"]) != ""
	var icone: Texture2D = app["icone"]

	if aberto:
		var botao := Button.new()
		botao.name = "Tile_%s" % String(app["id"])
		botao.theme_type_variation = &"AppAberto"
		botao.custom_minimum_size = Vector2(TILE, TILE)
		botao.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		botao.tooltip_text = String(app["nome"])
		botao.icon = icone
		botao.expand_icon = true
		botao.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var cena: String = String(app["cena"])
		botao.pressed.connect(func() -> void:
			abrir_app.emit(cena)
			queue_free())
		caixa.add_child(botao)
	else:
		var quadro := PanelContainer.new()
		quadro.name = "Tile_%s" % String(app["id"])
		quadro.theme_type_variation = &"AppFechado"
		quadro.custom_minimum_size = Vector2(TILE, TILE)
		quadro.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		var img := TextureRect.new()
		img.texture = icone
		img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		quadro.add_child(img)
		var veu := PanelContainer.new()
		veu.name = "Veu"
		veu.theme_type_variation = &"AppVeu"
		quadro.add_child(veu)
		quadro.add_child(_selo_do_cadeado())
		caixa.add_child(quadro)

	# O NOME É CLARO NOS DOIS, desde a quarta passagem: o nome cinzento dos
	# fechados somava-se ao véu e ao cadeado a dizer a mesma coisa, e era parte
	# do «apagados demais». Quem diz «fechado» é o selo.
	var pilula := PanelContainer.new()
	pilula.theme_type_variation = &"CelularRotulo"
	pilula.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var nome := Label.new()
	nome.name = "Nome_%s" % String(app["id"])
	nome.theme_type_variation = &"TextoCelular"
	nome.text = String(app["nome"])
	nome.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pilula.add_child(nome)
	caixa.add_child(pilula)
	return caixa


# O SELO DO CADEADO: o ícone `bloqueado` num anel claro, no canto de baixo do
# tile e a sair dele — como o selo de um app que ainda está a instalar.
#
# ⚠️ A 22 px, DENTRO do véu, era «pequeno demais» (quarta passagem da `066`):
# ele morava dentro do quadrado e disputava lugar com o desenho do app. A 32,
# a sair do canto, é uma peça por cima do ícone, e é ELE que carrega o estado
# desde que o véu ficou mais leve. Sai 8 px para a direita, onde a grelha tem
# 30 de vão, e só 3 para baixo, onde o nome está a 6.
const SELO := 32

func _selo_do_cadeado() -> Control:
	var ancora := Control.new()
	ancora.name = "Selo"
	ancora.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var anel := PanelContainer.new()
	anel.theme_type_variation = &"AppSelo"
	anel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	anel.anchor_left = 1.0
	anel.anchor_right = 1.0
	anel.anchor_top = 1.0
	anel.anchor_bottom = 1.0
	anel.offset_left = 8 - SELO
	anel.offset_right = 8
	anel.offset_top = 3 - SELO
	anel.offset_bottom = 3
	anel.add_child(Icones.imagem(Icones.BLOQUEADO, SELO - 4))
	ancora.add_child(anel)
	return ancora


func _aviso_dos_fechados() -> Control:
	var cartao := PanelContainer.new()
	cartao.name = "AvisoDosFechados"
	cartao.theme_type_variation = &"CelularWidget"
	var linha := HBoxContainer.new()
	linha.add_theme_constant_override("separation", 10)
	cartao.add_child(linha)
	# O MESMO SELO dos tiles, no mesmo anel: o disco navy do cadeado sozinho
	# sumia na placa do widget, que é navy também.
	var selo := PanelContainer.new()
	selo.theme_type_variation = &"AppSelo"
	selo.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	selo.add_child(Icones.imagem(Icones.BLOQUEADO, 24))
	linha.add_child(selo)
	var texto := Label.new()
	texto.theme_type_variation = &"TextoCelular"
	texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	texto.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	texto.text = RODAPE_FECHADOS
	linha.add_child(texto)
	return cartao


func _barra_de_gesto() -> Control:
	var linha := HBoxContainer.new()
	linha.alignment = BoxContainer.ALIGNMENT_CENTER
	var gesto := PanelContainer.new()
	gesto.name = "BarraDeGesto"
	gesto.theme_type_variation = &"CelularGesto"
	gesto.custom_minimum_size = Vector2(110, 5)
	linha.add_child(gesto)
	return linha


# OS BOTÕES DO APARELHO: um à direita (o de ligar) e dois à esquerda (o
# volume), a sair da borda do corpo. Vão ANTES do corpo na ordem de desenho,
# e o corpo tapa a metade de dentro deles — que é como se veem num telefone.
func _botoes_laterais() -> void:
	var metade := LARGURA / 2.0
	var altura := ALTURA / 2.0
	var lados := [
		[metade - 2.0, metade + 4.0, -altura + 150.0, -altura + 214.0],
		[-metade - 4.0, -metade + 2.0, -altura + 130.0, -altura + 172.0],
		[-metade - 4.0, -metade + 2.0, -altura + 184.0, -altura + 226.0],
	]
	for i in lados.size():
		var b := PanelContainer.new()
		b.name = "BotaoLateral%d" % (i + 1)
		b.theme_type_variation = &"CelularLateral"
		b.mouse_filter = Control.MOUSE_FILTER_IGNORE
		b.anchor_left = 0.5
		b.anchor_right = 0.5
		b.anchor_top = 0.5
		b.anchor_bottom = 0.5
		b.offset_left = lados[i][0]
		b.offset_right = lados[i][1]
		b.offset_top = lados[i][2]
		b.offset_bottom = lados[i][3]
		add_child(b)
		# Depois do escurecer (filho 0) e antes do corpo.
		move_child(b, 1)


# «GUARDAR O TELEFONE» FICA FORA DO APARELHO desde a `066`: dentro dele era
# um botão do jogo desenhado dentro de um telefone, que é o que desfazia a
# metáfora. Por baixo do corpo, é o gesto de o pôr de lado.
func _botao_guardar() -> void:
	var botao := Button.new()
	botao.name = "Guardar"
	botao.text = "Guardar o telefone"
	botao.anchor_left = 0.5
	botao.anchor_right = 0.5
	botao.anchor_top = 0.5
	botao.anchor_bottom = 0.5
	botao.offset_left = -130
	botao.offset_right = 130
	botao.offset_top = ALTURA / 2.0 + 18
	botao.offset_bottom = ALTURA / 2.0 + 18 + TOQUE_MIN + 8
	botao.pressed.connect(_fechar)
	add_child(botao)
