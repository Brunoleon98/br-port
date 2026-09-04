extends SceneTree

# BR Port — mede o ENQUADRAMENTO de cada variante de projeção.
#
# POR QUE EM GODOT E NÃO EM PYTHON
# --------------------------------
# Este contêiner não tem rasterizador de SVG nenhum (nem `cairosvg`, nem
# `rsvg-convert`, nem `PIL`). O Godot tem — é o ThorVG, o MESMO que importa o
# mapa no jogo —, então medir aqui mede o que o jogador vê, e não o que um
# segundo rasterizador acharia que ele vê.
#
# AS DUAS MEDIDAS, E POR QUE SÃO DUAS
# -----------------------------------
# **Contagem de pixel** (rasterizada): quanto do quadro é terra, quanto é
# terra NATURAL — o mundo que se está a estender, por oposição ao porto
# construído em cima dele — e quanto é o "azul vazio" do mar aberto. É o que a
# medição de 03/09 contava, e é por isso que a coluna `natural` dá ~27% num
# quadro que é 68% não-mar: são perguntas diferentes.
#
# **Borda do mundo** (geométrica): quantos pixels da FRONTEIRA do mundo caem
# dentro da janela. É a medida que importa para esta etapa, e a de 03/09 não a
# tinha: o problema de baixar o `MEIA_LARG` nunca foi "há pouca terra", foi
# **ver o mapa acabar**. São três fronteiras, e cada uma sai por um lado:
#
#   fundo   `mx = FUNDO_TERRA`, a diagonal reta onde a terra termina — canto
#           superior esquerdo;
#   norte   `my = DEGRAUS[0][0]`, onde a costa começa — canto superior direito;
#   sul     `my = DEGRAUS[-1][1]`, onde ela acaba — canto inferior esquerdo.
#
# Zero px em todas as três quer dizer que o mundo transborda dos quatro lados,
# que é o contrato escrito no cabeçalho de `gerar_mapa_iso.py`: "gerar o mundo
# MAIOR que o ecrã e cortar".
#
# ⚠️ A CLASSIFICAÇÃO É POR COR MAIS PRÓXIMA, e a paleta vem do gerador por
# JSON de propósito: uma lista de cores escrita aqui à mão envelheceria calada
# na primeira vez que alguém mexesse no dicionário `C`.
#
# Uso: $G --headless --path brport_vs \
#        --script res://tools/medir_enquadramento.gd -- /tmp/enq

var _paleta_nomes: PackedStringArray = []
var _paleta_cores: PackedColorArray = []
var _agua: Dictionary = {}
var _funda: Dictionary = {}
var _natural: Dictionary = {}
var _mundo: Dictionary = {}


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	if args.is_empty():
		printerr("uso: --script res://tools/medir_enquadramento.gd -- <dir>")
		quit(1)
		return
	var dir: String = args[0]
	var m: Dictionary = _ler_json(dir.path_join("medicao.json"))
	if m.is_empty():
		quit(1)
		return

	for nome in m["paleta"]:
		_paleta_nomes.append(nome)
		_paleta_cores.append(Color(String(m["paleta"][nome])))
	for lista in [["agua", _agua], ["funda", _funda], ["natural", _natural]]:
		for nome in m[lista[0]]:
			(lista[1] as Dictionary)[nome] = true
	_mundo = m["mundo"]

	var janela := Vector2i(int(m["janela"][0]), int(m["janela"][1]))
	print("=== enquadramento: janela %dx%d, centro do mundo fixo em mx=%.2f my=%.2f ==="
		% [janela.x, janela.y, float(m["centro_mundo"][0]), float(m["centro_mundo"][1])])
	print("                     pixel do quadro      |  borda do mundo no quadro")
	print("MEIA_LARG | terra | natural | agua funda |  fundo | norte |   sul")
	for v in m["variantes"]:
		_medir(dir, v, janela)
	quit(0)


func _ler_json(caminho: String) -> Dictionary:
	var f := FileAccess.open(caminho, FileAccess.READ)
	if f == null:
		printerr("não abriu ", caminho)
		return {}
	var j = JSON.parse_string(f.get_as_text())
	return j if j is Dictionary else {}


func _medir(dir: String, v: Dictionary, janela: Vector2i) -> void:
	var f := FileAccess.open(dir.path_join(String(v["arquivo"])), FileAccess.READ)
	if f == null:
		printerr("não abriu ", v["arquivo"])
		return
	var img := Image.new()
	if img.load_svg_from_string(f.get_as_text(), 1.0) != OK:
		printerr("o ThorVG não desenhou ", v["arquivo"])
		return

	var terra := 0
	var natural := 0
	var funda := 0
	var total := 0
	for y in range(janela.y):
		for x in range(janela.x):
			var nome := _classificar(img.get_pixel(x, y))
			total += 1
			if _agua.has(nome):
				if _funda.has(nome):
					funda += 1
				continue
			terra += 1
			if _natural.has(nome):
				natural += 1

	var b := _bordas(v, janela)
	print("%9.0f | %4.1f%% | %6.1f%% | %9.1f%% | %5.0f px | %4.0f px | %4.0f px"
		% [float(v["meia_larg"]), 100.0 * terra / total,
		   100.0 * natural / total, 100.0 * funda / total, b[0], b[1], b[2]])


# Quantos pixels de cada fronteira do mundo caem dentro da janela. Anda-se a
# linha a passo curto e soma-se o que está dentro — é o mesmo método do bloco
# D15 do teste de design, que mede a costa visível de cada praia.
func _bordas(v: Dictionary, janela: Vector2i) -> Array:
	var degraus: Array = _mundo["degraus"]
	var fundo: float = float(_mundo["fundo_terra"])
	var alt: float = float(v["alt_cais"])
	var my_n: float = float((degraus[0] as Array)[0])
	var my_s: float = float((degraus[-1] as Array)[1])
	var borda_n: float = float((degraus[0] as Array)[2])
	var borda_s: float = float((degraus[-1] as Array)[2])
	return [
		_linha_visivel(v, janela, Vector2(fundo, my_n), Vector2(fundo, my_s), alt),
		_linha_visivel(v, janela, Vector2(fundo, my_n), Vector2(borda_n, my_n), alt),
		_linha_visivel(v, janela, Vector2(fundo, my_s), Vector2(borda_s, my_s), alt),
	]


func _linha_visivel(v: Dictionary, janela: Vector2i, a: Vector2, b: Vector2,
		alt: float) -> float:
	var visivel := 0.0
	var ant := Vector2.INF
	var passos := 2000
	for i in range(passos + 1):
		var m := a.lerp(b, float(i) / passos)
		var ponto := Vector2(
			float(v["cx"]) + (m.x - m.y) * float(v["meia_larg"]),
			float(v["cy"]) + (m.x + m.y) * float(v["meia_alt"]) - alt)
		var dentro: bool = (ponto.x >= 0.0 and ponto.x <= janela.x
			and ponto.y >= 0.0 and ponto.y <= janela.y)
		if dentro and ant != Vector2.INF:
			visivel += ponto.distance_to(ant)
		ant = ponto if dentro else Vector2.INF
	return visivel


func _classificar(c: Color) -> String:
	var melhor := ""
	var d := INF
	for i in range(_paleta_cores.size()):
		var q: Color = _paleta_cores[i]
		var e: float = ((c.r - q.r) * (c.r - q.r) + (c.g - q.g) * (c.g - q.g)
			+ (c.b - q.b) * (c.b - q.b))
		if e < d:
			d = e
			melhor = _paleta_nomes[i]
	return melhor
