extends Control

# ============================================================
# BR Port VS — a TELA INICIAL (`docs/decisoes/066`)
#
# A família do sistema da frente 3 do A5: o «Salvar e sair» da pausa precisava
# de um sítio para onde ir, e o jogo não tinha nenhum — abria direto no porto
# e só saía fechando a aplicação. O Bruno escolheu, com opções na mão:
#
#  - uma CENA PRÓPRIA, com ilustração, e não o porto vivo por trás. É a cena
#    principal do projeto, e o `Main` passa a ser para onde ela leva;
#  - a ilustração sai do GERADOR DE IMAGEM, pelo `art_lab/` — é arte de painel
#    e não prop no mapa, que é a linha que o `CLAUDE.md` traça. Até ela chegar
#    o fundo é um degradê que não finge ser a arte (`FUNDO`);
#  - TRÊS espaços de save, e os botões Continuar, Nova partida, Carregar e
#    Ajustes.
#
# ⚠️ ELA NÃO É UMA FASE DO `GameState`, e é por isso que o balanceamento não a
# vê: o simulador nunca abre cena nenhuma, e a regra «tela nova é overlay,
# nunca fase» continua cumprida — do lado de fora do porto, em vez de por cima.
#
# ⚠️ E NÃO HÁ «SAIR DO JOGO». No Android a regra do sistema é não ter botão de
# fechar a aplicação: o Voltar, aqui, fecha-a (`_notification`).
# ============================================================

# O FUNDO, num sítio só. Quando a ilustração chegar do `art_lab/`, é esta
# linha que muda. A mesma peça vai ser o papel de parede do celular (escolha
# do Bruno: uma peça, dois usos) — isso é a terceira passagem da família, e
# ainda não está feito.
const FUNDO := preload("res://art/tela_inicial/fundo_provisorio.svg")
const CENA_DO_PORTO := "res://scenes/Main.tscn"
const PainelEspacosScene := preload("res://scenes/panels/PainelEspacos.tscn")
const PainelAjustesScene := preload("res://scenes/panels/PainelAjustes.tscn")

const LARGURA_CARTAO := 560
const ALTURA_BOTAO := 56
const ALTURA_CONTINUAR := 64
# O cartão pousa a esta distância do pé da tela. Um telefone de 9:20 corta
# ~240 px em cima e em baixo do quadro de 9:16 (ver o `project.godot`), e o
# cartão fica dentro da parte que sobra em qualquer proporção.
const MARGEM_INFERIOR := 96

var _mais_recente := 0


func _ready() -> void:
	anchor_right = 1.0
	anchor_bottom = 1.0
	_mais_recente = GameState.espaco_mais_recente()
	_montar_fundo()
	_montar_logo()
	_montar_cartao()


func _montar_fundo() -> void:
	var fundo := TextureRect.new()
	fundo.name = "Fundo"
	fundo.texture = FUNDO
	fundo.anchor_right = 1.0
	fundo.anchor_bottom = 1.0
	# COBRE e corta, em vez de encolher com faixas: a tela do aparelho não
	# tem a proporção do quadro, e uma ilustração com barras pretas lê-se como
	# defeito. O briefing pede o miolo importante longe das bordas.
	fundo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	fundo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	fundo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fundo)


func _montar_logo() -> void:
	var logo := Label.new()
	logo.name = "Logo"
	logo.theme_type_variation = &"LogoInicial"
	logo.text = "BR Port"
	logo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	logo.anchor_right = 1.0
	logo.offset_top = 300
	logo.offset_bottom = 400
	logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(logo)


# O cartão dos botões, BRANCO e no pé da tela: o vocabulário das duas famílias
# da frente 3 (cartão do tema, botão primário âmbar, texto de apoio), e o único
# fundo que se conhece por baixo das letras — a ilustração não entra ali.
func _montar_cartao() -> void:
	var cartao := PanelContainer.new()
	cartao.name = "Cartao"
	cartao.anchor_left = 0.5
	cartao.anchor_right = 0.5
	cartao.anchor_top = 1.0
	cartao.anchor_bottom = 1.0
	cartao.offset_left = -LARGURA_CARTAO / 2.0
	cartao.offset_right = LARGURA_CARTAO / 2.0
	cartao.offset_top = -MARGEM_INFERIOR
	cartao.offset_bottom = -MARGEM_INFERIOR
	# Cresce PARA CIMA a partir do pé, à medida dos botões — com três espaços
	# vazios há dois botões, com algum ocupado há quatro e a linha de apoio.
	cartao.grow_vertical = Control.GROW_DIRECTION_BEGIN
	add_child(cartao)

	var coluna := VBoxContainer.new()
	coluna.add_theme_constant_override("separation", 10)
	cartao.add_child(coluna)

	if _mais_recente > 0:
		var r: Dictionary = GameState.resumo_do_espaco(_mais_recente)
		var apoio := Label.new()
		apoio.name = "UltimaPartida"
		apoio.theme_type_variation = &"RotuloApoio"
		apoio.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		apoio.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		apoio.text = "Última partida: %s · %s" % [String(r["porto"]), GameState.linha_do_espaco(r)]
		coluna.add_child(apoio)
		var continuar := _botao(coluna, "Continuar", ALTURA_CONTINUAR, _continuar)
		continuar.theme_type_variation = &"BotaoPrimario"

	_botao(coluna, "Nova partida", ALTURA_BOTAO, _nova_partida)
	if _mais_recente > 0:
		_botao(coluna, "Carregar", ALTURA_BOTAO, func() -> void:
			_abrir_espacos("carregar"))
	_botao(coluna, "Ajustes", ALTURA_BOTAO, func() -> void:
		_abrir_painel(PainelAjustesScene).call("setup"))


func _botao(onde: Control, texto: String, altura: int, ao_tocar: Callable) -> Button:
	var botao := Button.new()
	botao.name = "Botao%s" % texto.replace(" ", "")
	botao.text = texto
	botao.custom_minimum_size = Vector2(0, altura)
	botao.pressed.connect(ao_tocar)
	onde.add_child(botao)
	return botao


# Os painéis desta tela entram por aqui, como os do porto entram pelo
# `_abrir_painel` do `Main` — e o `conferir_cobertura_paineis.py` lê os dois.
# O tema chega sozinho: a raiz desta cena é um `Control` com o tema, e o painel
# é filho dela (no `Main` é que eles vivem num `CanvasLayer`, que o corta).
func _abrir_painel(cena: PackedScene) -> Control:
	var painel: Control = cena.instantiate()
	add_child(painel)
	return painel


func _abrir_espacos(modo: String) -> void:
	var painel := _abrir_painel(PainelEspacosScene)
	painel.connect("escolhido", _ao_escolher_espaco)
	painel.call("setup", modo)


func _continuar() -> void:
	GameState.usar_espaco(_mais_recente)
	_ir_para_o_porto()


# NOVA PARTIDA SEM ESPAÇO OCUPADO NÃO PERGUNTA ONDE. Na primeira vez que o
# jogo abre os três estão livres, e uma lista de três «Começar aqui» seria um
# toque a mais para uma escolha que não existe — vai para o espaço 1.
func _nova_partida() -> void:
	if _mais_recente == 0:
		GameState.comecar_no_espaco(1)
		_ir_para_o_porto()
		return
	_abrir_espacos("nova")


func _ao_escolher_espaco(espaco: int, modo: String) -> void:
	if modo == "nova":
		GameState.comecar_no_espaco(espaco)
	else:
		GameState.usar_espaco(espaco)
	_ir_para_o_porto()


func _ir_para_o_porto() -> void:
	get_tree().change_scene_to_file(CENA_DO_PORTO)


# O VOLTAR DO ANDROID. Com um painel aberto fecha-o — pelo `_fechar()` dele,
# que é quem emite `fechou` —; sem nada aberto, fecha o jogo, que é o que o
# sistema espera do Voltar na primeira tela de uma aplicação. O
# `quit_on_go_back=false` do `project.godot` desliga o padrão, e o `Main`
# trata o Voltar do porto (abre a pausa).
func _notification(qual: int) -> void:
	if qual != NOTIFICATION_WM_GO_BACK_REQUEST:
		return
	for i in range(get_child_count() - 1, -1, -1):
		var filho := get_child(i)
		if filho is PainelNarrativo and not filho.is_queued_for_deletion():
			if (filho as PainelNarrativo).fecha_com_voltar:
				(filho as PainelNarrativo)._fechar()
			return
	get_tree().quit()
