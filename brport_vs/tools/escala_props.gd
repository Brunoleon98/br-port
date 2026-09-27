extends SceneTree

# ============================================================
# BR Port VS — a PÁGINA DE ESCALA dos props de mapa
# Ferramenta de apoio. NÃO faz parte do jogo.
#
# Todos os props de mapa a 1:1, com o PÉ na mesma linha, do mais alto ao mais
# baixo, e o trabalhador no começo de cada fila como régua. É a prancha de
# escala das referências de produção — «compare sempre contra uma referência
# conhecida» — e responde à nota do Bruno sobre os camiões (23/09): «tome
# cuidado com a proporção em relação ao mapa e seus itens, pois no futuro
# carros e pessoas devem ser adicionadas». Carros e pessoas entram contra esta
# régua, e o que já está desproporcionado vê-se aqui antes de se multiplicar
# (`docs/decisoes/068`).
#
# ⚠️ É A PERGUNTA QUE A FOLHA DE CONTATO NÃO FAZ. A folha põe cada prop numa
# célula do tamanho do MAIOR, centrado no chão dele, e a esse arranjo o olho lê
# "cabe tudo", não "quem é maior do que quem": o cachorro e o píer ficam a
# duzentos pixels um do outro. Aqui encostam.
#
# ⚠️ E ALINHAM PELO PÉ DO DESENHO, não pelo centro do quadro — a mesma razão da
# `prancha_prop.gd`: o trabalhador é desenhado à altura do tabuado do píer, e
# pelo centro do quadro flutuaria acima de tudo o que pousa no chão.
#
# ⚠️ E O NOME VAI PARA A LEGENDA, não para baixo do prop: `caminhao_armazenagem
# _retorno_mx` pede 200 px e o prop por cima dele tem 44. Um nome por baixo
# afastaria os props pela largura do NOME, que é exatamente a distância que
# esta página existe para não inventar.
#
# Uso (Linux, sem monitor — precisa de xvfb):
#   xvfb-run -a Godot --path brport_vs --rendering-driver opengl3 \
#     --resolution 720x1280 --script res://tools/escala_props.gd -- <saida.png>
# ============================================================

const FRAMES_ATE_ASSENTAR := 8
const REGUA := "trabalhador.png"
const TEXTURA_POR_TELA := 1.5

const FUNDO := Color(0.09, 0.16, 0.24)
# O chão de todas as filas é UM só, e neutro: a pergunta desta página é o
# tamanho, e o contraste de cada prop com o chão dele é da folha e da prancha.
const CHAO := Color(0.42, 0.46, 0.50)
const TINTA := Color(0.878, 0.914, 0.965)
const TINTA_FRACA := Color(0.62, 0.70, 0.78)
const TINTA_REGUA := Color(0.95, 0.75, 0.30)

const LARG := 720.0
const ALT := 1280.0
const MARGEM := 10.0
const CABECALHO := 46.0
const VAO := 8.0                 # entre dois props da mesma fila
const NUMERO := 13.0             # a linha do número por baixo de cada fila
const ENTRE_FILAS := 8.0
const FONTE_LEGENDA := 10
const LINHA_LEGENDA := 13.0
const COLUNAS_LEGENDA := 3
const DESENHO_MIN := 19

var _cat: RefCounted
var _saida := "user://escala.png"
var _montado := false
var _frames := 0
var _foto: Image = null
var _artes: Array = []


func _process(_delta: float) -> bool:
	if not _montado:
		_montado = true
		if not _montar():
			return true
		return false
	_frames += 1
	if _frames < FRAMES_ATE_ASSENTAR:
		return false
	if _foto == null:
		_foto = root.get_texture().get_image()
		for par in _artes:
			(par[0] as CanvasItem).hide()
		_frames = 0
		return false
	var sem := root.get_texture().get_image()
	var ausentes := 0
	for par in _artes:
		var arte := par[0] as TextureRect
		var n := PropIso.desenho_na_foto(_foto, sem, Rect2(arte.position, arte.size))
		if n < DESENHO_MIN:
			print("FALHOU  %s não chegou à foto: %d px mudam ao escondê-lo" % [par[1], n])
			ausentes += 1
	if ausentes > 0:
		quit(1)
		return true
	if _foto.save_png(_saida) != OK:
		print("FALHOU ao salvar em %s" % _saida)
		quit(1)
		return true
	print("Folha salva em %s (%dx%d) — escala de %d props" % [
		_saida, _foto.get_width(), _foto.get_height(), _artes.size()])
	quit(0)
	return true


func _montar() -> bool:
	var args := OS.get_cmdline_user_args()
	if args.size() >= 1:
		_saida = args[0]
	_cat = load("res://tools/catalogo_props.gd").new(root.get_node("GameState"))
	var nomes: Array = _cat.catalogo()
	if not nomes.has(REGUA):
		print("FALHOU — a régua '%s' saiu do catálogo." % REGUA)
		quit(1)
		return false

	# Cada prop com o recorte do desenho e o tamanho a 1:1 (em coordenada de
	# tela, que é o tamanho do jogo — a textura tem 1,5x isso).
	var pecas: Array = []
	for n in nomes:
		var tex: Texture2D = load("%s/%s" % [_cat.PASTA, n])
		var ur := PropIso.imagem(tex).get_used_rect()
		pecas.append({"nome": n, "tex": tex,
			"tam": Vector2(ur.size) * PropIso.escala(tex)})
	# Do mais alto ao mais baixo, e pelo nome no empate — uma ordem que não
	# dependa de como o disco lista a pasta, senão duas corridas iguais davam
	# duas páginas diferentes.
	pecas.sort_custom(func(x, y):
		if not is_equal_approx(x["tam"].y, y["tam"].y):
			return x["tam"].y > y["tam"].y
		return String(x["nome"]) < String(y["nome"]))
	for i in range(pecas.size()):
		pecas[i]["numero"] = i + 1

	var regua_tex: Texture2D = load("%s/%s" % [_cat.PASTA, REGUA])
	var regua_ur := PropIso.imagem(regua_tex).get_used_rect()
	var regua_tam := Vector2(regua_ur.size) * PropIso.escala(regua_tex)

	# AS FILAS: enche-se da esquerda para a direita, e a fila nova começa com a
	# régua. A altura de uma fila é a do mais alto dela — que é o primeiro,
	# pela ordem.
	var filas: Array = []
	var atual: Array = []
	var x := MARGEM + regua_tam.x + VAO * 2.0
	for p in pecas:
		var w: float = p["tam"].x
		if not atual.is_empty() and x + w > LARG - MARGEM:
			filas.append(atual)
			atual = []
			x = MARGEM + regua_tam.x + VAO * 2.0
		atual.append(p)
		x += w + VAO
	if not atual.is_empty():
		filas.append(atual)

	var alt_filas := 0.0
	for f in filas:
		alt_filas += maxf(float(f[0]["tam"].y), regua_tam.y) + NUMERO + ENTRE_FILAS
	var linhas_legenda := int(ceil(float(pecas.size()) / float(COLUNAS_LEGENDA)))
	var alt_legenda := 20.0 + float(linhas_legenda) * LINHA_LEGENDA

	# ⚠️ A PÁGINA QUE TRANSBORDA REPROVA, como a folha de contato: um prop novo
	# alto o bastante para empurrar a legenda para fora da tela sairia cortado
	# sem uma palavra, e a legenda é a única forma de saber quem é quem.
	if CABECALHO + alt_filas + alt_legenda + MARGEM > ALT:
		print("FALHOU — a escala pede %.0f px e a tela tem %.0f (%d filas, %d props)."
			% [CABECALHO + alt_filas + alt_legenda + MARGEM, ALT, filas.size(), pecas.size()])
		quit(1)
		return false

	# ⚠️ E O NOME DA LEGENDA TAMBÉM NÃO PODE SER CORTADO — `Label` que não cabe
	# corta sem erro. Mede-se o pior do catálogo, pela mesma chamada que o
	# desenha.
	var fonte := ThemeDB.fallback_font
	var col := (LARG - 2.0 * MARGEM) / float(COLUNAS_LEGENDA)
	for p in pecas:
		var t := _entrada(p)
		var w := fonte.get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, FONTE_LEGENDA).x
		if w > col - 4.0:
			print("FALHOU — a legenda '%s' pede %.0f px e a coluna dá %.0f." % [t, w, col - 4.0])
			quit(1)
			return false

	var fundo := ColorRect.new()
	fundo.color = FUNDO
	fundo.size = Vector2(LARG, ALT)
	root.add_child(fundo)
	_texto("ESCALA — os %d props de mapa a 1:1, com o pé na mesma linha" % pecas.size(),
		Vector2(MARGEM, 4.0), 15, TINTA)
	_texto("do mais alto ao mais baixo · a régua (a âmbar) é o trabalhador, no começo "
		+ "de cada fila · o número leva à legenda", Vector2(MARGEM, 25.0), 11, TINTA_FRACA)

	var y := CABECALHO
	for f in filas:
		var alt: float = maxf(float(f[0]["tam"].y), regua_tam.y)
		var chao_y := y + alt
		var faixa := ColorRect.new()
		faixa.color = CHAO
		faixa.position = Vector2(MARGEM, y - 2.0)
		faixa.size = Vector2(LARG - 2.0 * MARGEM, alt + 2.0)
		root.add_child(faixa)
		var linha := ColorRect.new()
		linha.color = Color(TINTA, 0.5)
		linha.position = Vector2(MARGEM, chao_y)
		linha.size = Vector2(LARG - 2.0 * MARGEM, 1.0)
		root.add_child(linha)

		# A régua não entra na prova: é a mesma textura do prop n.º tal, que já
		# é provado no sítio dele.
		_arte(regua_tex, Vector2(MARGEM + VAO, chao_y - regua_tam.y), regua_tam, "")
		_texto("régua", Vector2(MARGEM + 2.0, chao_y + 1.0), 9, TINTA_REGUA)
		var xx := MARGEM + regua_tam.x + VAO * 2.0
		for p in f:
			var tam: Vector2 = p["tam"]
			_arte(p["tex"], Vector2(xx, chao_y - tam.y), tam, String(p["nome"]))
			_texto(str(p["numero"]), Vector2(xx, chao_y + 1.0), 9, TINTA_FRACA)
			xx += tam.x + VAO
		y = chao_y + NUMERO + ENTRE_FILAS

	y += 6.0
	for i in range(pecas.size()):
		var c := i / linhas_legenda
		var l := i % linhas_legenda
		_texto(_entrada(pecas[i]),
			Vector2(MARGEM + float(c) * col, y + float(l) * LINHA_LEGENDA),
			FONTE_LEGENDA, TINTA_FRACA)
	return true


func _entrada(p: Dictionary) -> String:
	return "%d  %s" % [int(p["numero"]), String(p["nome"]).get_basename()]


func _arte(tex: Texture2D, onde: Vector2, tam: Vector2, prova: String) -> void:
	var t := TextureRect.new()
	t.texture = PropIso.recorte(tex)
	# O filtro do jogo, porque a promessa é o tamanho do jogo: a textura de 768
	# desenhada a 512 (ver a `folha_props`, «o filtro era `NEAREST`»).
	t.texture_filter = CanvasItem.TEXTURE_FILTER_PARENT_NODE
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_SCALE
	t.position = onde
	t.size = tam
	root.add_child(t)
	if prova != "":
		_artes.append([t, prova])


func _texto(texto: String, onde: Vector2, fonte: int, cor: Color) -> void:
	var l := Label.new()
	l.text = texto
	l.position = onde
	l.add_theme_color_override("font_color", cor)
	l.add_theme_font_size_override("font_size", fonte)
	root.add_child(l)
