extends PainelCelular

# ============================================================
# BR Port VS — O QUE JÁ FOI DITO (R5 da §7.1)
#
# A faixa de mensagem cabe uma frase de cada vez, e o jogo diz mais do que
# isso: medido em 19/09, uma só pressão de "Avançar dia" escreve nela até
# QUATRO vezes, e comprar uma estrutura escreve 2,29 em média
# (`tools/medir_fila_mensagens.gd`). A fila resolve o atropelo — mostra uma de
# cada vez, por ordem — e abre a pergunta seguinte: e o que passou enquanto eu
# olhava para o mapa?
#
# ⚠️ É OVERLAY, e nunca fase do `GameState`. Uma fase a mais fez 24 de 30
# partidas não terminarem e o CI passar na mesma; como overlay, o balanceamento
# medido fica intocado POR CONSTRUÇÃO e não por cuidado de quem escreveu.
#
# ⚠️ E O HISTÓRICO É DA SESSÃO, não do save. A §7.1 pede "recuperação em
# memória da sessão, sem migrar save", e é o que mantém o `SAVE_VERSION`
# intocado: fechar o jogo esquece o que foi dito, como esquece o que estava na
# faixa.
#
# ── UMA CONVERSA NO CELULAR (`docs/decisoes/067`) ──
#
# Era um cartão branco com as frases umas por baixo das outras, e o pedido do
# Bruno foi «se inspire em outros jogos de referência». A escolha dele: uma
# conversa, no MESMO telefone do menu (`PainelCelular`). A pista é o Chirper
# do *Cities: Skylines* e o telefone dos jogos de vida — pista de padrão, de
# memória: nenhuma página nem busca foi lida para isto (`docs/decisoes/063`).
# Na conversa:
#
#   · a Dona Cida fala em BALÕES, à esquerda, com o retrato dela no primeiro
#     balão de cada fala seguida — como num chat de grupo;
#   · o que o PORTO informa é uma NOTA ao centro, com a cor do tom na borda
#     (bom, aviso, ruim), como o aviso de sistema de um app de mensagens;
#   · os dias SEPARAM a conversa, e a mais recente fica no fundo, à vista —
#     a ordem de um chat, e não a de uma lista.
#
# ⚠️ E CONTINUA SEM RÓTULO DE ORADOR. O cabeçalho deste arquivo explicava que
# um nome escrito seria texto novo para o gate A4; o balão com a cara dela diz
# quem fala sem uma palavra, e a nota ao centro diz que é o porto.
# ============================================================

# As notas do porto e os balões ocupam no máximo esta fração da largura: um
# balão da largura toda lê-se como um cartão, não como uma fala.
const BALAO_MAX := 0.8
# 44 e não 34 desde a segunda passagem: «cara da Dona Cida maior». A 34 a
# cara tinha 30 px de lado e os óculos eram dois pontos.
const AVATAR := 44
# O ícone do assunto na nota do porto, e o que ele ocupa ao lado do texto.
const ICONE := 18
const VAO_ICONE := 6

# ⚠️ O ASSUNTO DE CADA AVISO VEM DE QUEM O EMITE (`GameState.message`, o
# terceiro argumento), e cada um tem o seu ícone aqui. O acesso é DIRETO: um
# assunto novo sem ícone rebenta em vez de sair sem ele calado — e o F17 do
# fumaça confere a tabela contra o `GameState.gd` antes de alguém jogar.
# Todos aguentam a placa escura da nota (`Icones.gd` diz qual serve onde:
# `parcela` é navy e sumia, e o dinheiro da parcela usa o `caixa`).
#
# ⚠️ E CADA UM DIZ O ASSUNTO SEM LEGENDA (terceira passagem, «ícones pouco
# claros»): o negócio fechado era o `acordo`, um disco âmbar que se lia como
# uma moeda, e passou ao BARCO que se fechou; a obra era o visto verde, que
# diz «feito» e não «obra», e passou ao guindaste; e o cliente que perde a
# paciência tem a cara dele, e não as espadas do rival que ainda não ganhou.
const ICONE_DO_ASSUNTO := {
	"porto": Icones.DOCA,
	"doca": Icones.DOCA,
	"trabalhador": Icones.TRABALHADOR,
	"rival": Icones.RIVAL,
	"cliente": Icones.CLIENTE_IMPACIENTE,
	"negocio": Icones.BARCO,
	"semana": Icones.DIA,
	"dinheiro": Icones.CAIXA,
	"obra": Icones.AMPLIAR_PIER,
}
# Onde a conversa ENTRA na tela, e o que ela gasta à volta: a coluna do
# telefone, menos o avatar e o vão ao lado dele.
const VAO_AVATAR := 8


func setup(historico: Variant = null) -> void:
	var dentro := montar_celular(false)
	dentro.add_child(_cabecalho())

	var lista: Array = historico if historico is Array else []
	if lista.is_empty():
		var vazio := Label.new()
		vazio.theme_type_variation = &"TextoConversaVazia"
		vazio.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vazio.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		vazio.text = "Ainda não aconteceu nada por aqui."
		vazio.size_flags_vertical = Control.SIZE_EXPAND_FILL
		vazio.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		dentro.add_child(vazio)
		acabar_celular()
		return

	# A JANELA DA CONVERSA: o rolo e, por cima dele, o esbatido do topo — o que
	# sobe por baixo do cabeçalho desvanece em vez de ser cortado a direito
	# (segunda passagem, «melhorar alguns detalhes»). O esbatido vem DEPOIS do
	# rolo, por cima; por trás do texto não há imagem nenhuma.
	var janela := Control.new()
	janela.name = "Janela"
	janela.size_flags_vertical = Control.SIZE_EXPAND_FILL
	janela.clip_contents = true
	dentro.add_child(janela)
	var rolo := ScrollContainer.new()
	rolo.name = "Conversa"
	rolo.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	rolo.anchor_right = 1.0
	rolo.anchor_bottom = 1.0
	janela.add_child(rolo)
	janela.add_child(_esbatido())
	var fio := VBoxContainer.new()
	fio.add_theme_constant_override("separation", 10)
	fio.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rolo.add_child(fio)

	# O histórico vem do mais recente para o mais antigo; a conversa lê-se ao
	# contrário, com a última no fundo.
	var dia_anterior := FilaDeMensagens.SEM_DIA
	# As falas SEGUIDAS da mesma pessoa juntam-se num grupo mais apertado, como
	# num chat: 4 px entre os balões dela, 10 entre peças diferentes.
	var grupo: VBoxContainer = null
	var quem_fala := ""
	for i in range(lista.size() - 1, -1, -1):
		var entrada: Dictionary = lista[i]
		var dia: int = int(entrada["dia"])
		if dia != FilaDeMensagens.SEM_DIA and dia != dia_anterior:
			fio.add_child(_separador(dia))
			dia_anterior = dia
			grupo = null
		var fonte := String(entrada["fonte"])
		if fonte == "sistema":
			grupo = null
			fio.add_child(_nota(String(entrada["texto"]), String(entrada["kind"]),
				String(entrada["assunto"])))
			continue
		var primeiro := grupo == null or fonte != quem_fala
		if primeiro:
			grupo = VBoxContainer.new()
			grupo.add_theme_constant_override("separation", 4)
			fio.add_child(grupo)
			quem_fala = fonte
		grupo.add_child(_balao(String(entrada["texto"]),
			_cara_de(fonte, entrada["retrato"]), primeiro))

	# A ÚLTIMA À VISTA: a barra de rolagem só sabe o tamanho depois de a
	# conversa se arrumar, e a cada vez que o tamanho muda ela vai ao fundo.
	var barra := rolo.get_v_scroll_bar()
	barra.changed.connect(func() -> void: rolo.scroll_vertical = int(barra.max_value))
	acabar_celular()


# O CABEÇALHO DO APP: as três caras de quem fala nesta conversa, umas sobre
# as outras como num grupo, e o título de sempre. É a barra de cima de toda
# conversa num telefone — e desde a terceira passagem a conversa é de três.
const QUEM_FALA := [["cida", "neutro"], ["ribeiro", "entrada"], ["arlindo", "abertura"]]
const CARA_DO_GRUPO := 36

func _cabecalho() -> Control:
	var barra := PanelContainer.new()
	barra.name = "CabecalhoDaConversa"
	barra.theme_type_variation = &"ConversaCabecalho"
	var linha := HBoxContainer.new()
	linha.add_theme_constant_override("separation", 10)
	barra.add_child(linha)
	# As caras sobrepõem-se um terço: um contentor de separação NEGATIVA
	# desenharia a seguinte por baixo da anterior, e o grupo lê-se da esquerda.
	var grupo := HBoxContainer.new()
	grupo.name = "Grupo"
	grupo.add_theme_constant_override("separation", -CARA_DO_GRUPO / 3)
	for par in QUEM_FALA:
		grupo.add_child(_avatar(Narrativa.retrato(String(par[0]), String(par[1])),
			CARA_DO_GRUPO))
	linha.add_child(grupo)
	var titulo_ := Label.new()
	titulo_.theme_type_variation = &"TextoConversaTitulo"
	titulo_.text = "O que já foi dito"
	titulo_.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	linha.add_child(titulo_)
	return barra


# A cara dela, redonda: a CABEÇA do retrato (`Retratos.cabeca()`, e não o
# quadro inteiro, que num círculo deste tamanho não mostrava cara nenhuma)
# dentro de um aro claro, como um telefone mostra um contacto.
const CIRCULO := preload("res://ui/shaders/circulo.gdshader")

func _avatar(retrato: Texture2D, lado: int) -> Control:
	var aro := PanelContainer.new()
	aro.name = "Avatar"
	aro.theme_type_variation = &"AvatarConversa"
	aro.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	aro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var cara := TextureRect.new()
	cara.texture = Retratos.cabeca(retrato)
	cara.custom_minimum_size = Vector2(lado, lado)
	cara.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	cara.stretch_mode = TextureRect.STRETCH_SCALE
	cara.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var mascara := ShaderMaterial.new()
	mascara.shader = CIRCULO
	mascara.set_shader_parameter("tamanho", Vector2(lado, lado))
	cara.material = mascara
	aro.add_child(cara)
	return aro


# A CARA DE UMA FALA: a que o jogo lhe deu ao dizê-la (a expressão da
# Dona Cida muda com o que ela diz), e sem ela a de omissão da pessoa.
const CARA_DE_OMISSAO := {"cida": "neutro", "ribeiro": "entrada", "arlindo": "abertura"}

func _cara_de(fonte: String, retrato: Variant) -> Texture2D:
	if retrato is Texture2D:
		return retrato
	return Narrativa.retrato(fonte, String(CARA_DE_OMISSAO[fonte]))


# UM BALÃO DE QUEM FALA. O primeiro de uma fala seguida leva a cara; os
# seguintes guardam o lugar dela vazio, para os balões alinharem.
func _balao(texto: String, retrato: Texture2D, com_cara: bool) -> Control:
	var linha := HBoxContainer.new()
	linha.add_theme_constant_override("separation", VAO_AVATAR)
	if com_cara:
		linha.add_child(_avatar(retrato, AVATAR))
	else:
		var lugar := Control.new()
		lugar.custom_minimum_size = Vector2(AVATAR + 4, 0)
		linha.add_child(lugar)
	var balao := PanelContainer.new()
	# O primeiro balão tem o bico ao lado da cara; os seguidos, não.
	if com_cara:
		balao.theme_type_variation = &"BalaoConversa"
	else:
		balao.theme_type_variation = &"BalaoConversaSeguido"
	balao.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	var rotulo := Label.new()
	rotulo.theme_type_variation = &"TextoBalao"
	rotulo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rotulo.text = texto
	balao.add_child(rotulo)
	linha.add_child(balao)
	# A coluna do balão é a do telefone menos a cara — com o aro dela, que
	# são 2 px de cada lado (`AvatarConversa`).
	_largura_do_balao(balao, rotulo, texto, float(LARGURA - 2 * MARGEM_TELA
		- AVATAR - 4 - VAO_AVATAR))
	return linha


# UMA NOTA DO PORTO, ao centro, com a cor do tom na borda. As variações são
# LITERAIS, uma por ramo, pela razão da `tingir_tarja()`: o
# `conferir_escopo_ui.py` só confere o nome que vê depois do `=`.
func _nota(texto: String, tom: String, assunto: String) -> Control:
	var centro := CenterContainer.new()
	var nota := PanelContainer.new()
	match tom:
		"good":
			nota.theme_type_variation = &"NotaConversaBoa"
		"warn":
			nota.theme_type_variation = &"NotaConversaAviso"
		"bad":
			nota.theme_type_variation = &"NotaConversaRuim"
		_:
			nota.theme_type_variation = &"NotaConversa"
	var linha := HBoxContainer.new()
	linha.add_theme_constant_override("separation", VAO_ICONE)
	# AO CENTRO, como o aviso de sistema de um app de mensagens: a segunda
	# passagem encostou-as à esquerda com o ícone, e liam-se como balões de
	# uma quarta pessoa.
	linha.alignment = BoxContainer.ALIGNMENT_CENTER
	nota.add_child(linha)
	var reserva := 0.0
	if assunto != "":
		var icone := Icones.imagem(ICONE_DO_ASSUNTO[assunto], ICONE)
		icone.name = "Assunto"
		icone.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		linha.add_child(icone)
		reserva = ICONE + VAO_ICONE
	var rotulo := Label.new()
	rotulo.theme_type_variation = &"TextoNotaConversa"
	rotulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rotulo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rotulo.text = texto
	linha.add_child(rotulo)
	centro.add_child(nota)
	_largura_do_balao(nota, rotulo, texto, float(LARGURA - 2 * MARGEM_TELA), reserva)
	return centro


# O dia, numa pílula ao centro — o separador de data de um chat.
func _separador(dia: int) -> Control:
	var centro := CenterContainer.new()
	var pilula := PanelContainer.new()
	pilula.theme_type_variation = &"DiaConversa"
	var rotulo := Label.new()
	rotulo.theme_type_variation = &"TextoDiaConversa"
	rotulo.text = "Dia %d" % dia
	pilula.add_child(rotulo)
	centro.add_child(pilula)
	return centro


# ⚠️ UM RÓTULO QUE QUEBRA NÃO TEM LARGURA PRÓPRIA: num contentor que encolhe,
# o `autowrap` pede zero e o balão sai com uma palavra por linha. A largura
# sai do TEXTO — o que ele ocupa numa linha só, mais as margens do balão —,
# com o teto de `BALAO_MAX` da coluna; acima dele, quebra. É por isso que uma
# nota curta fica curta e uma fala comprida ocupa a coluna.
func _largura_do_balao(caixa: PanelContainer, rotulo: Label, texto: String,
		coluna: float, reserva: float = 0.0) -> void:
	var fonte: Font = rotulo.get_theme_font("font")
	var tamanho: int = rotulo.get_theme_font_size("font_size")
	var estilo: StyleBox = caixa.get_theme_stylebox("panel")
	var margens: float = estilo.get_margin(SIDE_LEFT) + estilo.get_margin(SIDE_RIGHT)
	var numa_linha: float = fonte.get_string_size(texto, HORIZONTAL_ALIGNMENT_LEFT,
		-1, tamanho).x
	var teto: float = coluna * BALAO_MAX - margens - reserva
	rotulo.custom_minimum_size.x = ceilf(minf(numa_linha + 2.0, teto))


# O ESBATIDO DO TOPO: a cor da tela, de opaca a transparente, numa faixa por
# cima do rolo. A cor sai do `StyleBoxFlat` da tela no tema — é a MESMA cor,
# e por isso o que sobe por baixo do cabeçalho some na tela em vez de parar
# numa aresta.
const ESBATIDO := 18

func _esbatido() -> Control:
	var faixa := TextureRect.new()
	faixa.name = "Esbatido"
	faixa.mouse_filter = Control.MOUSE_FILTER_IGNORE
	faixa.anchor_right = 1.0
	faixa.offset_bottom = ESBATIDO
	var tela := get_theme_stylebox("panel", &"CelularTela") as StyleBoxFlat
	var cor: Color = tela.bg_color if tela != null else Color(0, 0, 0)
	var degrade := Gradient.new()
	degrade.set_color(0, cor)
	degrade.set_color(1, Color(cor, 0.0))
	var textura := GradientTexture2D.new()
	textura.gradient = degrade
	textura.fill_from = Vector2(0, 0)
	textura.fill_to = Vector2(0, 1)
	textura.width = 4
	textura.height = ESBATIDO
	faixa.texture = textura
	faixa.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	faixa.stretch_mode = TextureRect.STRETCH_SCALE
	return faixa
