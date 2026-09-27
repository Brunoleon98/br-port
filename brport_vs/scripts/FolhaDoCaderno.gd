extends Control

# ============================================================
# BR Port VS — o que o papel do caderno desenha por baixo do texto
#
# A pauta azul, a linha vermelha da margem, a sombra da lombada e a fita
# marcadora (`docs/decisoes/067`, a família das telas de texto). O papel é o
# `CadernoPagina` do tema — um `StyleBoxFlat` creme, que é o fundo contra o
# qual o D33 mede a tinta; isto só desenha as linhas finas por cima dele.
#
# ⚠️ AS CORES SAEM DO TEMA, e não daqui. «Script não pinta cor na mão» (o
# `CLAUDE.md`, Interface): os `draw_*` ficam fora do `conferir_escopo_ui.py`
# por serem pintura de arte, e mesmo assim a cor de cada linha é um item do
# tema (`CadernoPagina/colors/*`), para o papel mudar num sítio só.
#
# ⚠️ E NÃO É UM `TextureRect`, de propósito. Uma imagem por trás do texto dá
# PENDÊNCIA na régua do contraste (`066`), e com razão: ela não sabe a cor de
# uma pintura. A pauta são linhas finas de uma cor só, e a régua mede a tinta
# contra o creme — que é o que o olho vê em quase todo o traço da letra.
#
# ⚠️ A PAUTA SAI DA LETRA, nunca de um número em pixel. O passo é a altura da
# fonte mais o `line_spacing` do rótulo que ela acompanha, e a primeira linha
# pousa na linha de base dele: mudar o tamanho da letra no tema muda a pauta
# junto, e a letra continua a cair em cima da linha. Um passo escrito à mão
# envelheceria calado no dia em que alguém mexesse no tamanho.
# ============================================================

# De onde o papel tira as cores.
const TIPO := &"CadernoPagina"
# Onde corre a linha vermelha, a partir da borda da página do lado da lombada.
# A margem de texto do `PainelNarrativo` fica à direita dela.
const MARGEM_X := 44.0
# A sombra da lombada: onde a página entra na costura.
const LOMBADA := 16.0
# A fita sai do pé da página a esta fração da largura, e passa do caderno
# por FITA_QUEDA — é o que diz «livro» antes de se ler uma palavra.
const FITA_X := 0.8
const FITA_LARG := 18.0
const FITA_QUEDA := 46.0
# A linha de pauta pousa um pouco abaixo da linha de base: é onde a caneta a
# encontra, com as hastes do «g» e do «p» a atravessá-la, como no papel.
const PAUTA_ABAIXO_DA_BASE := 3.0
# A ORELHA: o canto dobrado de uma folha com uso. Qual canto, e de que tamanho.
enum Orelha { NENHUMA, CIMA, BAIXO }
const ORELHA_LADO := 34.0
# A costura das folhas, que se vê na lombada de um caderno aberto: um ponto de
# linha a cada tanto, dentro da sombra da lombada.
const COSTURA_PASSO := 86.0
const COSTURA_PONTO := 14.0

var pautada := false
var com_fita := false
var orelha := Orelha.NENHUMA
# A semente do traço à mão (a data sublinhada) e da fibra do papel: cada
# página a sua, para duas folhas seguidas não terem o papel igual.
var semente := 1
# O rótulo cujo ritmo a pauta segue. Sem ele não há pauta — só a margem. A
# primeira linha dele é a DATA da entrada, e leva o traço à mão por baixo.
var linha_ref: Label

# ── A VIRADA ── (`TelaNomes`, `docs/decisoes/067`, segunda passagem)
# Na folha que vira: quanto ela já se levantou (0 a 1). A borda livre curva-se
# para a luz — uma faixa clara, com a sombra da dobra por dentro dela.
var dobra := 0.0
# Na página de baixo: onde está a borda da folha que vira, e quanto ela a
# ensombra. A sombra cai para a DIREITA dessa borda, sobre o que se revela.
var sombra_x := -1.0
var sombra := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func pautar_por(rotulo: Label) -> void:
	linha_ref = rotulo
	# O rótulo só tem posição depois de o contentor o arrumar, e volta a
	# mexer-se se a página crescer: a pauta redesenha-se com ele.
	rotulo.item_rect_changed.connect(queue_redraw)
	queue_redraw()


## O passo da pauta, a partir da letra do rótulo que ela acompanha.
static func passo_de(rotulo: Control) -> float:
	var fonte: Font = rotulo.get_theme_font("font")
	var tamanho: int = rotulo.get_theme_font_size("font_size")
	return fonte.get_height(tamanho) + rotulo.get_theme_constant("line_spacing")


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()


func _draw() -> void:
	var lombada: Color = get_theme_color("lombada", TIPO)
	# Oito faixas sobrepostas, cada uma mais estreita: a sombra escurece para
	# dentro da costura sem se lerem degraus (com quatro liam-se riscas).
	for i in 8:
		var larg := LOMBADA * (1.0 - i / 8.0)
		draw_rect(Rect2(0, 0, larg, size.y), Color(lombada, lombada.a * 0.22))
	_costura_das_folhas()

	if pautada:
		_pauta()
	if com_fita:
		_fita()
	if sombra > 0.0 and sombra_x >= 0.0:
		_sombra_da_folha()
	if dobra > 0.0:
		_dobra()
	if orelha != Orelha.NENHUMA:
		_orelha()


# A COSTURA DAS FOLHAS na lombada — o «lombada com relevo» da terceira
# passagem: pontos de linha clara a intervalos, com o furo escuro em cada
# ponta, a meio da sombra. O grão e as manchas do papel, que viviam aqui,
# passaram para o shader (`ui/shaders/papel.gdshader`).
func _costura_das_folhas() -> void:
	var linha: Color = get_theme_color("linha", TIPO)
	var furo: Color = get_theme_color("lombada", TIPO)
	var x := LOMBADA * 0.45
	var y := COSTURA_PASSO * 0.5
	while y + COSTURA_PONTO < size.y:
		draw_line(Vector2(x, y), Vector2(x, y + COSTURA_PONTO), linha, 1.6, true)
		draw_circle(Vector2(x, y - 1.0), 1.4, Color(furo, 0.9))
		draw_circle(Vector2(x, y + COSTURA_PONTO + 1.0), 1.4, Color(furo, 0.9))
		y += COSTURA_PASSO


# O CANTO DOBRADO: o triângulo do canto sai da folha (vê-se a de baixo) e
# deita-se por cima dela, virado ao contrário — o verso, mais escuro, com a
# sombra que a aba faz no papel.
func _orelha() -> void:
	var verso: Color = get_theme_color("verso", TIPO)
	var baixo: Color = get_theme_color("folhas", &"CadernoCapa")
	var sombra: Color = get_theme_color("sombra_virada", TIPO)
	var s := ORELHA_LADO
	var w := size.x
	var h := size.y
	var canto: Vector2
	var a: Vector2
	var b: Vector2
	if orelha == Orelha.CIMA:
		canto = Vector2(w, 0)
		a = Vector2(w - s, 0)
		b = Vector2(w, s)
	else:
		canto = Vector2(w, h)
		a = Vector2(w - s, h)
		b = Vector2(w, h - s)
	# A aba é o canto espelhado na linha da dobra.
	var aba := a + b - canto
	draw_colored_polygon(PackedVector2Array([a, canto, b]), baixo)
	draw_colored_polygon(PackedVector2Array([a + Vector2(-2, 2), aba + Vector2(-3, 3),
		b + Vector2(-2, 2)]), Color(sombra, sombra.a * 0.5))
	draw_colored_polygon(PackedVector2Array([a, aba, b]), verso)
	draw_polyline(PackedVector2Array([a, aba, b, a]), Color(sombra, 0.35), 1.0, true)


func _pauta() -> void:
	var pauta: Color = get_theme_color("pauta", TIPO)
	var margem: Color = get_theme_color("margem", TIPO)
	if linha_ref != null and is_instance_valid(linha_ref):
		var passo := passo_de(linha_ref)
		var fonte: Font = linha_ref.get_theme_font("font")
		var tamanho: int = linha_ref.get_theme_font_size("font_size")
		# A posição do rótulo NESTE controle, desfeita a escala de quem vira
		# a página: durante a virada os dois encolhem juntos.
		var topo: Vector2 = get_global_transform().affine_inverse() \
			* linha_ref.global_position
		var base := topo.y + fonte.get_ascent(tamanho) + PAUTA_ABAIXO_DA_BASE
		var y := base - floorf(base / passo) * passo
		while y < size.y - 6.0:
			if y > 6.0:
				draw_line(Vector2(LOMBADA, y), Vector2(size.x, y), pauta, 1.0)
			y += passo
		_sublinhar_data(topo, base, fonte, tamanho)
	draw_line(Vector2(MARGEM_X, 0), Vector2(MARGEM_X, size.y), margem, 1.5)


# A DATA SUBLINHADA À MÃO, como se data uma entrada num diário: um traço na
# tinta da letra, um pouco torto, por baixo só do que está escrito — a largura
# sai do texto, e não de um número.
func _sublinhar_data(topo: Vector2, base: float, fonte: Font, tamanho: int) -> void:
	var data := linha_ref.text.get_slice("\n", 0)
	var larg := fonte.get_string_size(data, HORIZONTAL_ALIGNMENT_LEFT, -1, tamanho).x
	var fim := topo.x + linha_ref.size.x
	var ini := fim - larg - 4.0
	var tinta: Color = linha_ref.get_theme_color("font_color")
	var rng := RandomNumberGenerator.new()
	rng.seed = semente + 7
	var pontos := PackedVector2Array()
	var passos := 14
	for i in passos + 1:
		var t := float(i) / passos
		# Sobe meio pixel da esquerda para a direita, e treme um quarto: é o
		# traço de quem sublinha sem régua.
		pontos.append(Vector2(lerpf(ini, fim + 2.0, t),
			base + 2.0 - t * 1.5 + rng.randf_range(-0.6, 0.6)))
	draw_polyline(pontos, Color(tinta, 0.85), 1.6, true)


# ⚠️ A FITA SAI DE ENTRE AS FOLHAS, no pé, e nunca por cima do papel: a
# primeira começava 26 px acima do pé, com uma ponta quadrada pousada na
# página, e lia-se colada em vez de presa na costura.
func _fita() -> void:
	var fita: Color = get_theme_color("fita", TIPO)
	var x0 := size.x * FITA_X
	var topo := size.y - 1.0
	var pe := size.y + FITA_QUEDA
	var bico := pe - FITA_LARG * 0.55
	draw_colored_polygon(PackedVector2Array([
		Vector2(x0, topo), Vector2(x0 + FITA_LARG, topo),
		Vector2(x0 + FITA_LARG, pe), Vector2(x0 + FITA_LARG * 0.5, bico),
		Vector2(x0, pe)]), fita)
	# A dobra do tecido: uma linha mais escura no meio, que é o que separa uma
	# fita de um retângulo vermelho.
	draw_line(Vector2(x0 + FITA_LARG * 0.5, topo), Vector2(x0 + FITA_LARG * 0.5, bico),
		Color(fita.darkened(0.25), 0.7), 1.0)
	# E a sombra da folha por cima dela, onde sai do livro.
	draw_rect(Rect2(x0, topo, FITA_LARG, 4.0), Color(fita.darkened(0.45), 0.6))


# A SOMBRA QUE A FOLHA A VIRAR DEITA NA PÁGINA DE BAIXO: mais forte junto à
# borda dela, a desvanecer para a direita. Sem ela a folha encolhia sobre o
# papel como um cartão a deslizar, que foi o «a virada é plana».
func _sombra_da_folha() -> void:
	var cor: Color = get_theme_color("sombra_virada", TIPO)
	var larg := 46.0
	for i in 12:
		var t := float(i) / 12.0
		draw_rect(Rect2(sombra_x + t * larg, 0, larg / 12.0 + 0.5, size.y),
			Color(cor, cor.a * sombra * (1.0 - t) * (1.0 - t)))


# A BORDA LIVRE DA FOLHA QUE SE LEVANTA: uma faixa escura por dentro (o papel
# a curvar-se para longe da luz) e um fio claro no gume (o lado que a apanha).
# Cresce com a `dobra`, que o `TelaNomes` anda de 0 a 1.
func _dobra() -> void:
	var escuro: Color = get_theme_color("sombra_virada", TIPO)
	var luz: Color = get_theme_color("luz_dobra", TIPO)
	var larg := 90.0 * dobra
	for i in 10:
		var t := float(i) / 10.0
		draw_rect(Rect2(size.x - larg + t * larg, 0, larg / 10.0 + 0.5, size.y),
			Color(escuro, escuro.a * dobra * t))
	draw_rect(Rect2(size.x - 3.0, 0, 3.0, size.y), Color(luz, luz.a * dobra))


# ── A CAPA ──
# O que a capa desenha à volta das páginas: a costura pespontada a meio da
# borda de couro, os cantos gastos e as bordas das folhas empilhadas por baixo
# da de cima. Vive como PRIMEIRO filho da capa, e por isso as páginas tapam-na
# no meio: o que fica à vista é a borda.
#
# ⚠️ E DESENHA FORA DO PRÓPRIO RETÂNGULO, de propósito: ele ocupa o lugar das
# páginas (o contentor arruma-o lá), e a costura e os cantos vivem na margem
# da capa, à volta. A margem sai do tema (`content_margin` da `CadernoCapa`).
#
# ⚠️ O COURO É UM SHADER POR BAIXO DE TUDO (`ui/shaders/couro.gdshader`), num
# `ColorRect` do tamanho da capa inteira: o grão, o gasto e o volume da lombada
# («capa ainda chapada», terceira passagem). A cor vem do `StyleBoxFlat` da
# capa, lida aqui e passada ao shader — ele não traz paleta nenhuma. A
# costura, os cantos e as folhas desenham-se num segundo filho, POR CIMA dele:
# um `Control` desenha-se antes dos filhos, e o couro tapava-os.
class CapaDoCaderno extends Control:
	const TIPO := &"CadernoCapa"
	const COURO := preload("res://ui/shaders/couro.gdshader")
	var _couro: ColorRect
	var _detalhes: DetalhesDaCapa

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		_couro = ColorRect.new()
		_couro.name = "Couro"
		_couro.mouse_filter = Control.MOUSE_FILTER_IGNORE
		# Transparente: quem pinta é o shader. E transparente importa para a
		# régua do contraste, que lê um `ColorRect` por trás como um fundo.
		_couro.color = Color(1, 1, 1, 0)
		var m := ShaderMaterial.new()
		m.shader = COURO
		_couro.material = m
		add_child(_couro)
		_detalhes = DetalhesDaCapa.new()
		_detalhes.name = "Detalhes"
		_detalhes.anchor_right = 1.0
		_detalhes.anchor_bottom = 1.0
		add_child(_detalhes)
		_acertar()

	func _notification(what: int) -> void:
		if what == NOTIFICATION_RESIZED or what == NOTIFICATION_THEME_CHANGED:
			_acertar()

	# O couro ocupa a capa INTEIRA, e este controle só o lugar das páginas: a
	# margem da capa sai do tema.
	func _acertar() -> void:
		if _couro == null:
			return
		var caixa: StyleBox = get_parent().get_theme_stylebox("panel", TIPO)
		var margem: float = caixa.get_margin(SIDE_LEFT)
		var capa := DetalhesDaCapa.capa_de(caixa, size)
		_couro.position = capa.position
		_couro.size = capa.size
		var m := _couro.material as ShaderMaterial
		if caixa is StyleBoxFlat:
			var flat := caixa as StyleBoxFlat
			m.set_shader_parameter("base", flat.bg_color)
			m.set_shader_parameter("raio", float(flat.corner_radius_top_right))
		m.set_shader_parameter("tamanho", _couro.size)
		m.set_shader_parameter("lombada", margem)
		_detalhes.queue_redraw()


class DetalhesDaCapa extends Control:
	const TIPO := &"CadernoCapa"
	const FOLHAS := 3
	const PASSO_FOLHA := 2.0

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	# A capa inteira, a partir do lugar das páginas e das margens do tema — que
	# não são iguais: a lombada é mais larga.
	static func capa_de(caixa: StyleBox, miolo: Vector2) -> Rect2:
		return Rect2(Vector2.ZERO, miolo).grow_individual(
			caixa.get_margin(SIDE_LEFT), caixa.get_margin(SIDE_TOP),
			caixa.get_margin(SIDE_RIGHT), caixa.get_margin(SIDE_BOTTOM))

	func _draw() -> void:
		var caixa: StyleBox = get_theme_stylebox("panel", TIPO)
		var capa := capa_de(caixa, size)
		_cantos(capa)
		# O pesponto a meio da borda de cima (a mais estreita das quatro).
		var meio: float = caixa.get_margin(SIDE_TOP) * 0.5
		_costura(capa.grow(-meio))
		_folhas()

	# As folhas de baixo, a espreitar à direita e no pé da de cima.
	func _folhas() -> void:
		var papel: Color = get_theme_color("folhas", TIPO)
		var fio: Color = get_theme_color("fio_folhas", TIPO)
		for i in range(FOLHAS, 0, -1):
			var d := i * PASSO_FOLHA
			var folha := Rect2(Vector2(0, d), size)
			folha.position.x += d
			draw_rect(folha, papel)
			draw_rect(folha, fio, false, 1.0)

	# O pesponto: traços curtos a meio da borda de couro, à volta da capa.
	func _costura(r: Rect2) -> void:
		var linha: Color = get_theme_color("costura", TIPO)
		var traco := 7.0
		var vao := 5.0
		var cantos := [r.position, Vector2(r.end.x, r.position.y), r.end,
			Vector2(r.position.x, r.end.y)]
		for i in 4:
			var a: Vector2 = cantos[i]
			var b: Vector2 = cantos[(i + 1) % 4]
			var comp := a.distance_to(b)
			var dir := (b - a) / comp
			var t := 6.0
			while t + traco < comp - 6.0:
				draw_line(a + dir * t, a + dir * (t + traco), linha, 1.2, true)
				t += traco + vao

	# Os cantos gastos: o couro clareia onde a mão o apanha, ao longo das
	# duas bordas que se encontram no canto, e desvanece ao afastar-se dele.
	# ⚠️ SÓ DENTRO DA FAIXA DE COURO, e depois da curva do canto: a primeira
	# versão eram círculos centrados no canto, que saíam da capa para o escuro
	# e se liam como quatro botões pregados.
	func _cantos(r: Rect2) -> void:
		var gasto: Color = get_theme_color("desgaste", TIPO)
		var caixa: StyleBox = get_parent().get_theme_stylebox("panel", TIPO)
		var faixa: float = caixa.get_margin(SIDE_LEFT) - 2.0
		var curva := 14.0
		var comp := 34.0
		var passos := 8
		for canto in 4:
			var sx := 1.0 if canto in [0, 3] else -1.0
			var sy := 1.0 if canto in [0, 1] else -1.0
			var origem := Vector2(r.position.x if sx > 0 else r.end.x,
				r.position.y if sy > 0 else r.end.y)
			for i in passos:
				var t := float(i) / passos
				var a := Color(gasto, gasto.a * 0.55 * (1.0 - t))
				var ao_longo := curva + t * comp
				# Na borda de cima ou de baixo, e na do lado.
				draw_rect(Rect2(origem + Vector2(sx * ao_longo, sy * 1.0)
					- Vector2(0 if sx > 0 else comp / passos, 0 if sy > 0 else faixa),
					Vector2(comp / passos, faixa)), a)
				draw_rect(Rect2(origem + Vector2(sx * 1.0, sy * ao_longo)
					- Vector2(0 if sx > 0 else faixa, 0 if sy > 0 else comp / passos),
					Vector2(faixa, comp / passos)), a)


# ── AS CANTONEIRAS DA FOTO ──
# Os quatro triângulos de papel escuro que prendem a foto à folha. Vivem aqui
# porque são o mesmo tipo de desenho — linha e cor do tema, por cima do papel.
# O fio claro na hipotenusa é o vinco do papel dobrado: sem ele eram quatro
# triângulos pretos chapados.
class Cantoneiras extends Control:
	const LADO := 26.0

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _notification(what: int) -> void:
		if what == NOTIFICATION_RESIZED:
			queue_redraw()

	func _draw() -> void:
		var cor: Color = get_theme_color("cantoneira", &"CadernoFoto")
		var luz: Color = get_theme_color("cantoneira_luz", &"CadernoFoto")
		var l := LADO
		var w := size.x
		var h := size.y
		var tri := [
			[Vector2(-4, -4), Vector2(l, -4), Vector2(-4, l)],
			[Vector2(w + 4, -4), Vector2(w + 4, l), Vector2(w - l, -4)],
			[Vector2(-4, h + 4), Vector2(-4, h - l), Vector2(l, h + 4)],
			[Vector2(w + 4, h + 4), Vector2(w - l, h + 4), Vector2(w + 4, h - l)],
		]
		for t in tri:
			var pts := PackedVector2Array(t)
			draw_colored_polygon(pts, cor)
			# O contorno antisserrilhado tira o serrilhado das arestas, e a
			# hipotenusa (do segundo ao terceiro ponto) leva o vinco claro.
			var fecho := PackedVector2Array(t)
			fecho.append(t[0])
			draw_polyline(fecho, cor, 1.0, true)
			draw_line(t[1], t[2], luz, 1.5, true)
