class_name PainelCelular
extends PainelNarrativo

# ============================================================
# BR Port VS — o APARELHO: o celular de quem toma conta do porto
#
# O corpo, a tela, o papel de parede, a barra de status, a barra de gesto, os
# botões laterais e o «Guardar o telefone» por baixo. Viviam no `PainelMenu`
# desde a `066`; a família das telas de texto (`067`) pôs as MENSAGENS no
# mesmo telefone — escolha do Bruno: «conversa no celular» —, e duas cópias
# do mesmo aparelho divergiriam à primeira passagem. Os apps (a tela de
# início, a conversa) são o que cada painel põe DENTRO da tela.
#
# ⚠️ A EXTRAÇÃO NÃO MUDA O MENU, e prova-se na foto: a mesma árvore de nós,
# pelos mesmos nomes e na mesma ordem, e o `menu.png` da bateria com o mesmo
# hash antes e depois.
# ============================================================

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

# O que afasta o conteúdo da borda da tela. A barra de status vai de borda a
# borda (a tela não tem margem desde a `066`), e o resto vive dentro disto.
const MARGEM_TELA := 14

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
var _dentro: VBoxContainer


# Monta o aparelho e devolve a caixa DENTRO da tela, depois da barra de
# status, onde o app põe o que é dele. `com_parede` é a tela de início; um
# app aberto tem o fundo dele e não o papel de parede.
func montar_celular(com_parede: bool) -> VBoxContainer:
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

	if com_parede:
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

	_dentro = VBoxContainer.new()
	_dentro.add_theme_constant_override("separation", 16)
	miolo.add_child(_dentro)
	return _dentro


# O fecho do aparelho, depois de o app pôr o que é dele: a barra de gesto no
# pé da tela, os botões laterais e o «Guardar o telefone».
func acabar_celular() -> void:
	_dentro.add_child(_barra_de_gesto())
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
