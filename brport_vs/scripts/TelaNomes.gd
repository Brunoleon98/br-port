extends PainelNarrativo

# ============================================================
# BR Port VS — a tela de abertura: os dois nomes
#
# A PRIMEIRA coisa que o jogador vê. Ele batiza o cais (que substitui
# "Cais Mirim" em toda a interface e em todo diálogo) e diz o próprio nome
# (que os NPCs usam). O GDD 7 é explícito em que a escolha é IRREVOGÁVEL —
# não há tela de opções para a desfazer, e é de propósito: o nome do porto é
# o nome do legado.
#
# POR QUE ISTO É UM OVERLAY E NÃO UMA FASE DO JOGO.
#
# A tentação era criar uma fase `"nomes"` no GameState que bloqueasse o turno
# até os campos estarem preenchidos. Seria errado, e de um jeito que não daria
# erro nenhum: o `advance_turn()` retorna CALADO fora da fase `"playing"`
# (GameState.gd), e o laço do `simular_balanceamento.gd` só sabe resolver
# `rival_offer` e `debt_payment`. Uma fase nova faria o simulador girar até
# bater no limite de segurança de 300 voltas e contar a partida como travada —
# e o CI passaria assim mesmo, porque só procura a linha `=== Leitura ===`.
#
# Como overlay, a fase continua `"playing"` o tempo todo. O jogador não avança
# o dia porque o painel está por cima do botão, não porque o estado o proíbe.
# O simulador nunca abre cena nenhuma, então não vê esta tela e joga com os
# nomes-padrão: **o balanceamento medido fica intocado por construção, e não
# por cuidado de quem escreveu.**
#
# É também o padrão que todos os outros painéis já usam (`_abrir_painel` no
# Main.gd) — UpgradePanel, CounterOffer, DebtPayment e EndGame.
# ============================================================

# ── A FOLHA DE ROSTO DO DIÁRIO (`docs/decisoes/067`) ──
#
# Era um cartão branco com dois campos, e o pedido do Bruno foi «melhore isso,
# sendo que é a tela que vira logo depois de iniciar nova partida». A escolha
# dele (26/09): a folha de rosto do mesmo caderno que o diário é — a foto do
# porto colada, os dois nomes escritos à mão nas linhas impressas — e, ao
# abrir o porto, a folha VIRA para a primeira entrada.
#
# ⚠️ A VIRADA TEM O QUE REVELAR PORQUE HÁ DUAS PÁGINAS. A de baixo nasce em
# branco e pautada; ao abrir o porto, os nomes gravam-se, a entrada escreve-se
# nela (a mesma função do `PainelDiario`) e a de cima encolhe para a lombada.
# Quando ela some, o `fechou` sai e o `Main` abre o diário no MESMO retângulo,
# com a mesma página — é assim que duas telas leem como uma folha a virar.
#
# ⚠️ O TEXTO DA LEGENDA É O DE SEMPRE («O cais é seu» e a frase do Seu
# Maneco), fora da folha: é a voz de quem conta, e não a de quem escreve no
# diário. Os rótulos impressos mudaram (os dois do pedido que ele escolheu), e
# por isso passam pela leitura em voz alta do A4 como todo texto novo.

# A foto do porto de antigamente. PROVISÓRIA: céu e mar em sépia, sem porto
# nenhum, até a de verdade chegar do `art_lab/diario/` — é esta linha que
# muda.
const FOTO := preload("res://art/diario/foto_provisoria.svg")
const PainelDiarioScript := preload("res://scripts/PainelDiario.gd")
const FOLHA_VIRANDO := preload("res://ui/shaders/folha_virando.gdshader")
const FOTO_LARGURA := 500
const FOTO_ALTURA := 354
const FOTO_GIRO := -2.5
# A virada: curta, para não atrasar quem já quer jogar, e longa o bastante
# para o olho a seguir. Com a largura a cair pelo cosseno, o primeiro terço
# anda devagar — a folha a descolar — e por isso ela é um pouco mais longa
# do que a da primeira passagem (0,45 s, a encolher a direito).
const VIRAR_S := 0.55
# Quanto a folha cresce na vertical a meio da virada: é o que ela se aproxima
# do olho ao levantar-se, e a única pista de profundidade que um `Control`
# plano pode dar.
const VIRAR_ERGUE := 0.035
# A FOLHA QUE CURVA (terceira passagem): quanto dura, o raio do cilindro que
# a enrola e a inclinação da dobra — a mão levanta pelo canto de baixo, que o
# eixo inclinado apanha primeiro.
const CURVAR_S := 0.8
const CURVA_RAIO := 44.0
const CURVA_INCLINACAO := 0.18

var _campo_porto: LineEdit
var _campo_jogador: LineEdit
var _legenda: Control
var _virando := false
# A página de baixo, guardada para a entrada se escrever nela na virada.
var _caixa_de_baixo: VBoxContainer
var _folha_de_baixo: Control
var _rosto: PanelContainer
var _folha_do_rosto: Control
var _curva: ShaderMaterial


func _ready() -> void:
	super()
	# Fechar esta tela BATIZA o cais, e o nome não muda depois. O Voltar do
	# Android é o único jeito de a dispensar sem se ler o que ela pede, então
	# é o único jeito de alguém ficar com um porto que não escolheu.
	fecha_com_voltar = false
	montar_caderno(ESCURO_LEITURA)
	# A página de BAIXO primeiro: a primeira entrada do diário, ainda em
	# branco. É ela que traz a fita, que é do livro e não da folha.
	_caixa_de_baixo = pagina_do_caderno(true, true, FolhaDoCaderno.Orelha.BAIXO)
	_folha_de_baixo = _folha
	pagina_atual().name = "PaginaSeguinte"

	var pagina := pagina_do_caderno(false, false, FolhaDoCaderno.Orelha.CIMA)
	_rosto = pagina_atual()
	_rosto.name = "FolhaDeRosto"
	_folha_do_rosto = _folha
	_legenda = legenda_acima_do_caderno("O cais é seu",
		"O Seu Maneco deixou o porto para você. Antes de abrir os portões, duas coisas.")

	foto_colada(FOTO, FOTO_LARGURA, FOTO_ALTURA, FOTO_GIRO)
	# A ETIQUETA ao meio do que sobra da folha. Na primeira passagem os campos
	# iam colados à foto e a nota no pé, com 200 px de papel vazio entre eles
	# («vazio na folha de rosto»); dentro do quadro impresso, com a nota, o
	# formulário passa a ser uma peça, e o vão divide-se por cima e por baixo.
	pagina.add_child(_vao_elastico())
	etiqueta_da_folha()

	impresso("Nome do cais")
	# O limite vem do GameState e não daqui: quem corta o nome ao gravar é o
	# `definir_nomes()`, e dois limites diferentes seriam duas regras.
	_campo_porto = _campo(GameState.NOME_PORTO_PADRAO)
	impresso("Este diário pertence a")
	# O campo do jogador é o único opcional dos dois, e a sugestão diz isso em
	# vez de deixar o jogador adivinhar: sem nome, as falas com vocativo têm
	# variante — ninguém fica sem forma de tratamento (ver Narrativa.gd).
	_campo_jogador = _campo("(pode deixar em branco)")

	# O aviso fecha a etiqueta, como a nota impressa de um formulário.
	impresso("O nome do cais não muda depois.")
	pagina.add_child(_vao_elastico())

	botao_abaixo_do_caderno("Abrir o porto")
	_campo_porto.grab_focus()


func _vao_elastico() -> Control:
	var vao := Control.new()
	vao.size_flags_vertical = Control.SIZE_EXPAND_FILL
	return vao


func _campo(sugestao: String) -> LineEdit:
	var entrada := campo_a_mao(sugestao)
	entrada.max_length = GameState.NOME_MAX_CARACTERES
	# Enter em qualquer um dos dois campos abre o porto: obrigar a acertar no
	# botão depois de digitar é atrito sem motivo, e no telefone o teclado
	# ainda estaria por cima dele.
	entrada.text_submitted.connect(func(_t: String) -> void: _fechar())
	return entrada


# Sobrepõe o fecho da base para GRAVAR ANTES DE SAIR. A base emite `fechou` e
# liberta o nó; se os nomes fossem gravados por um `pressed` ligado à parte, a
# ordem entre os dois passaria a depender da ordem de ligação dos sinais — e o
# diário que abre a seguir leria o nome do porto ainda vazio.
#
# ⚠️ E GRAVA ANTES DE VIRAR, não depois: a entrada que a virada revela usa o
# nome do cais. O `fechou` só sai no fim da virada — quem encadeia o diário
# nele abre-o no instante em que a folha de rosto desaparece.
func _fechar() -> void:
	if _virando:
		return
	_virando = true
	GameState.definir_nomes(_campo_porto.text, _campo_jogador.text)
	# O botão NÃO se desliga: o estilo desligado é um azul pálido que piscava
	# por meio segundo. Um segundo toque já não faz nada, pelo `_virando`.
	_campo_porto.editable = false
	_campo_jogador.editable = false
	# A sugestão impressa esconde-se ao escrever (`text_changed`), mas texto
	# posto por código não emite esse sinal: na virada ela ficava por baixo do
	# nome, lida através dele. O que o jogador vê a virar é o que escreveu.
	for campo in [_campo_porto, _campo_jogador]:
		(campo as LineEdit).get_node("Sugestao").visible = (campo as LineEdit).text == ""

	_vbox = _caixa_de_baixo
	_folha = _folha_de_baixo
	PainelDiarioScript.escrever(self)

	# A FOLHA CURVA quando há imagem da tela para a dobrar; sem ela (o
	# renderizador das suítes não desenha nada), gira sobre a lombada como na
	# segunda passagem — o `fechou` sai no fim das duas.
	var t := create_tween()
	var foto := _fotografar_rosto()
	if foto != null:
		_montar_curva(foto)
		t.tween_method(_curvar, 0.0, 1.0, CURVAR_S)
	else:
		_rosto.pivot_offset = Vector2(0, _rosto.size.y / 2.0)
		t.tween_method(_virar, 0.0, 1.0, VIRAR_S)
	t.tween_callback(_depois_de_virar)


# A folha de rosto como está na tela neste instante, com os nomes escritos.
# ⚠️ A TELA DO APARELHO NÃO É A DE 720: com `canvas_items` o jogo desenha na
# resolução nativa (`CLAUDE.md`, o viewport é um sistema de coordenadas), e o
# recorte passa pela transformação final da janela — escala e faixas.
func _fotografar_rosto() -> Texture2D:
	var tela := get_viewport().get_texture()
	if tela == null:
		return null
	var img := tela.get_image()
	if img == null or img.is_empty():
		return null
	var xf: Transform2D = get_viewport().get_final_transform() \
		* _rosto.get_global_transform_with_canvas()
	var canto: Vector2 = xf * Vector2.ZERO
	var fim: Vector2 = xf * _rosto.size
	var r := Rect2i(Rect2(canto, fim - canto).abs())
	r = r.intersection(Rect2i(Vector2i.ZERO, img.get_size()))
	if r.size.x < 8 or r.size.y < 8:
		return null
	return ImageTexture.create_from_image(img.get_region(r))


# A foto da folha entra no lugar dela — a capa é um contentor, e arruma-a no
# mesmo retângulo das páginas — e a folha de verdade esconde-se.
func _montar_curva(foto: Texture2D) -> void:
	var folha := TextureRect.new()
	folha.name = "FolhaVirando"
	folha.texture = foto
	folha.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	folha.stretch_mode = TextureRect.STRETCH_SCALE
	folha.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_curva = ShaderMaterial.new()
	_curva.shader = FOLHA_VIRANDO
	_curva.set_shader_parameter("tamanho", _rosto.size)
	_curva.set_shader_parameter("raio", CURVA_RAIO)
	_curva.set_shader_parameter("inclinacao", CURVA_INCLINACAO)
	_curva.set_shader_parameter("verso", get_theme_color("verso", &"CadernoPagina"))
	_curva.set_shader_parameter("sombra", get_theme_color("sombra_virada", &"CadernoPagina"))
	folha.material = _curva
	_caderno_capa.add_child(folha)
	_rosto.visible = false
	_curvar(0.0)


# UM PASSO DA CURVA, de 0 (a folha deitada) a 1 (enrolada para lá da
# lombada). O eixo do cilindro anda da borda direita até passar a esquerda, e
# o shader faz o resto — ver o cabeçalho de `folha_virando.gdshader`.
func _curvar(t: float) -> void:
	var n := Vector2(1.0, CURVA_INCLINACAO).normalized()
	var longe: float = _rosto.size.dot(n)
	var suave := t * t * (3.0 - 2.0 * t)
	_curva.set_shader_parameter("dobra", lerpf(longe + 4.0, -CURVA_RAIO - 140.0, suave))
	_legenda.modulate.a = 1.0 - t


# UM PASSO DA VIRADA SEM IMAGEM, de 0 (a folha deitada) a 1 (a folha de pé,
# de lado, a sumir na lombada) — a da segunda passagem, que fica para quando
# a tela não se pode fotografar. A primeira passagem só encolhia a folha e escurecia-a por
# igual, e lia-se como um cartão a deslizar («a virada é plana»). Agora:
#   · a LARGURA cai pelo cosseno do ângulo, que é a projeção de uma folha a
#     girar — devagar ao descolar, depressa no fim;
#   · a folha ERGUE-SE um pouco na vertical a meio, a aproximar-se do olho;
#   · a borda livre CURVA-SE: sombra por dentro e um fio de luz no gume;
#   · a página de baixo apanha a SOMBRA da folha junto à borda dela.
func _virar(t: float) -> void:
	var angulo := t * PI / 2.0
	_rosto.scale = Vector2(maxf(cos(angulo), 0.001), 1.0 + VIRAR_ERGUE * sin(2.0 * angulo))
	_rosto.modulate = Color.WHITE.lerp(Color(0.8, 0.78, 0.74), sin(angulo))
	_folha_do_rosto.dobra = sin(angulo)
	_folha_do_rosto.queue_redraw()
	_folha_de_baixo.sombra_x = _rosto.size.x * cos(angulo)
	_folha_de_baixo.sombra = sin(PI * t)
	_folha_de_baixo.queue_redraw()
	# A legenda é da folha de rosto e vai-se com ela: o diário que abre a
	# seguir não a tem, e ela sumia de um frame para o outro.
	_legenda.modulate.a = 1.0 - t


func _depois_de_virar() -> void:
	super._fechar()
