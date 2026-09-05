extends Node2D
## Cena de teste de encaixe — FASE 11 do prompt mestre do pacote de arte.
##
## O critério de aprovação que o prompt define é este, textualmente: "o mesmo
## asset pode ser colocado em pelo menos três posições diferentes do mapa sem
## perder origem, escala ou ordem visual". Por isso NADA aqui é posicionado à
## mão: cada peça é colocada por `_tela()`, que é a projeção do contrato escrita
## em GDScript. Se a projeção mudar num lado e não no outro, esta cena denuncia,
## em vez de acomodar.
##
## O caminhão aparece de propósito em TRÊS posições — é o teste do critério.
##
## Esta cena não toca o jogo. `Main.tscn` continua com o mapa em SVG e os props
## que já tinha; aqui estão também os assets que a decisão 001 mantém fora do
## vertical slice (cidade, fauna, tiles de terreno), porque é este o único lugar
## onde eles são legítimos.

const MANIFEST := "res://data/assets/BRP_EXPORT_MANIFEST.json"

# DUAS ZONAS, e a divisão não é estética.
#
# Em cima, o DIORAMA: as peças em relação umas com as outras, que é onde se vê
# o que a lista de revisão do pacote manda procurar — doca cortada, navio a
# atravessar terra, rua a acabar na água, prédio em escala errada.
#
# Em baixo, a BANCADA: cada asset novo sozinho na sua célula, com a cruz da
# âncora à vista. É onde se vê o que o diorama esconde — um prop que encosta
# certo por acaso, porque o vizinho o tapava.
#
# As duas usam `_tela()`, com origens diferentes. Uma bancada em pixels não
# provaria projeção nenhuma.
# Origens escolhidas pela conta, não no olho: a extensão do diorama em x é
# (mx-my)*30 sobre todas as peças, e a origem é o que centra esse intervalo em
# 360, que é o meio dos 720 do retrato.
const CX := 490.0
const CY := 230.0
const CX_BANCADA := 180.0
const CY_BANCADA := 800.0

# Os rótulos vivem numa camada própria, acrescentada DEPOIS de todos os
# sprites. Sem isso, um rótulo escrito cedo fica debaixo de um prop desenhado
# tarde — e como a ordem é a profundidade, quem some é justamente o rótulo do
# que está mais atrás, que é o que mais precisa de ser identificado. Foi o que
# escondeu os três caminhões, que são o critério de aprovação do prompt.
var _rotulos := Node2D.new()

var _meia_larg := 30.0
var _meia_alt := 15.0
var _contrato: Dictionary = {}
var _grade := true


# Cada linha: nome do arquivo, pasta, mx, my, altura em px do mapa, rótulo.
# A altura é a do PONTO DE CONTATO, não a do prop: um barco flutua na água (0),
# um guindaste assenta no tabuado do píer (ALT_PIER=15), uma casa no chão do
# degrau (0).
#
# O espaçamento é largo de propósito. A primeira versão punha as peças a 1 e 2
# células de distância e o galpão — que tem 3 unidades de frente — engolia
# metade do diorama. Os props do jogo e os do pacote não estão na mesma ordem
# de grandeza, e a bancada tem de mostrar isso, não escondê-lo.
const CENA := [
	# ── chão: praia -> costa -> água, cada tile ocupa 2x2 células ──
	["terreno_areia",   "brp",   -5.0, -3.0, 0.0, ""],
	["terreno_areia",   "brp",   -3.0, -3.0, 0.0, "areia"],
	["terreno_rua",     "brp",   -5.0, -1.0, 0.0, "rua"],
	["terreno_costa",   "brp",   -3.0, -1.0, 0.0, "costa"],
	["terreno_agua",    "brp",   -1.0, -1.0, 0.0, "água"],
	["terreno_agua",    "brp",   -1.0,  1.0, 0.0, ""],
	["terreno_agua",    "brp",    1.0,  1.0, 0.0, ""],

	# ── terra ──
	["escritorio",      "props", -7.5,  2.0, 0.0, "escritório"],
	["galpao",          "props", -7.0,  6.0, 0.0, "armazém"],
	["casa_costeira",   "brp",   -4.6,  0.8, 0.0, "casa"],
	["mercado",         "brp",   -4.2,  3.6, 0.0, "mercado · selecionável"],
	["coqueiro_jovem",  "brp",   -6.2, -0.4, 0.0, ""],
	["arbusto",         "brp",   -3.2, -2.2, 0.0, ""],

	# ── o caminhão em TRÊS posições: é o critério de aprovação do prompt ──
	["caminhao",        "props", -2.4,  1.4, 0.0, "caminhão 1/3"],
	["caminhao",        "props", -1.0,  4.4, 0.0, "caminhão 2/3"],
	["caminhao",        "props",  0.6,  7.0, 0.0, "caminhão 3/3"],

	# ── pátio ──
	["empilhadeira",    "props", -2.8,  5.6, 0.0, ""],
	["pilha_caixotes",  "props", -4.0,  6.6, 0.0, ""],
	["poste",           "props", -5.2,  4.6, 0.0, ""],

	# ── água: doca, guindaste, trabalhador, barcos, boia ──
	["doca_concreto",   "props",  1.4,  4.6, 0.0, "doca de concreto"],
	# O guindaste do JOGO são duas peças: a torre vem assada em
	# `pier_n2` e só a lança é prop, porque é ela que gira. A primeira
	# versão desta bancada usava `guindaste_base` e `guindaste_mastro`, que já
	# não existem — o gerador deixou de os produzir quando a torre foi para
	# dentro do píer, e ninguém reparou porque só esta cena os carregava. Uma
	# bancada que monta o asset de um jeito que o jogo não usa não verifica
	# nada.
	["pier_n2", "props",  1.4,  4.6, 0.0, ""],
	["lanca_n2", "props",  1.4,  4.6, 0.0, "píer + lança, como no jogo"],
	["trabalhador",     "props",  0.6,  4.2, 15.0, ""],
	["cabeco",          "props", -0.4,  6.4, 0.0, ""],
	["barco_pequeno",   "props",  2.4,  7.6, 0.0, "barco de pesca"],
	["barco_grande",    "props",  3.6,  2.6, 0.0, "cargueiro"],
	["boia",            "props",  4.2,  5.6, 0.0, "boia"],
	["gaivota",         "brp",    2.0, -1.4, 60.0, "gaivota · voo"],
]

## A bancada: cada asset novo sozinho, para o vizinho não o tapar.
## Colunas de 2 em 2 células, linhas de 2 em 2.
const BANCADA := [
	["caminhao",       "props", "caminhão"],
	["empilhadeira",   "props", "empilhadeira"],
	["pilha_caixotes", "props", "caixotes"],
	["doca_concreto",  "props", "doca concreto"],
	["pallet",         "props", "pallet"],
	["pneus",          "props", "pneus"],
	["cone_transito",  "props", "cone"],
	["barreira",       "props", "barreira"],
	["bote",           "props", "bote"],
	["guincho",        "props", "guincho"],
	["cabeco",         "props", "cabeço"],
	["poste",          "props", "poste"],
	["casa_costeira",  "brp",   "casa"],
	["mercado",        "brp",   "mercado"],
	["coqueiro_jovem", "brp",   "coqueiro"],
	["arbusto",        "brp",   "arbusto"],
	["gaivota",        "brp",   "gaivota"],
	["terreno_costa",  "brp",   "tile costa"],
]

# O que é selecionável, e o tamanho da BASE — nunca o da silhueta.
const SELECIONAVEIS := {
	"mercado": Vector2(1.7, 1.25),
	"doca_concreto": Vector2(4.5, 2.4),
}


func _ready() -> void:
	_ler_contrato()
	_montar()
	_montar_bancada()
	_rotulos.name = "Rotulos"
	add_child(_rotulos)
	queue_redraw()


func _ler_contrato() -> void:
	var f := FileAccess.open(MANIFEST, FileAccess.READ)
	if f == null:
		push_warning("manifest não encontrado: %s" % MANIFEST)
		return
	var lido: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	if typeof(lido) != TYPE_DICTIONARY or not lido.has("contrato"):
		push_warning("manifest sem bloco `contrato`")
		return
	_contrato = lido["contrato"]
	# A projeção vem do manifest, que a escreveu no momento em que os PNGs
	# foram renderizados. Ler daqui em vez de repetir 30/15 no código é o que
	# faz esta cena falhar quando o contrato muda, que é a graça dela.
	_meia_larg = float(_contrato["meia_larg"])
	_meia_alt = float(_contrato["meia_alt"])


## Coordenada de mundo -> pixel da tela. O inverso de `_mundo()` do teste de
## design, e a mesma conta de `gerar_mapa_iso.py`.
func _tela(mx: float, my: float, altura_px: float = 0.0) -> Vector2:
	return Vector2(CX + (mx - my) * _meia_larg,
		CY + (mx + my) * _meia_alt - altura_px)


## A mesma projeção, com a outra origem. Repetir a conta em vez de a
## parametrizar deixaria duas verdades; passar a origem deixa uma.
func _tela_em(origem: Vector2, mx: float, my: float, alt: float = 0.0) -> Vector2:
	return Vector2(origem.x + (mx - my) * _meia_larg,
		origem.y + (mx + my) * _meia_alt - alt)


## Célula da bancada -> coordenada de mundo. Quatro colunas, 2 células de passo.
func _celula(i: int) -> Vector2:
	# Passo de 2 células na coluna e 3 na linha: em pixels dá 120 de coluna e 90
	# de linha. A 60 as casas encavalitavam-se na linha de baixo.
	var col := i % 4
	var lin := i / 4
	return Vector2(float(col * 2 + lin * 3), float(lin * 3 - col * 2))


func _montar() -> void:
	# ORDEM DE NÓ É PROFUNDIDADE. Quem tem mx+my maior está mais perto da
	# câmera e tapa quem tem menor — a mesma regra que o teste de design cobra
	# em Main.tscn. Ordenar aqui é o que impede o cargueiro de aparecer por
	# cima do píer que está à frente dele.
	var linhas := CENA.duplicate()
	linhas.sort_custom(func(a, b): return (a[2] + a[3]) < (b[2] + b[3]))

	for linha in linhas:
		var arquivo: String = linha[0]
		var pasta: String = linha[1]
		var mx: float = linha[2]
		var my: float = linha[3]
		var alt: float = linha[4]
		var rotulo: String = linha[5]

		var caminho := "res://art/%s/%s.png" % [pasta, arquivo]
		if not ResourceLoader.exists(caminho):
			push_warning("asset ausente: %s" % caminho)
			continue

		var s := Sprite2D.new()
		s.texture = load(caminho)
		s.name = "%s_%d_%d" % [arquivo, int(mx * 10), int(my * 10)]
		# O quadro tem 512 e o centro dele É a origem do mundo. Com `centered`
		# ligado, pôr o prop no lugar é atribuir a posição — não há meio quadro
		# para subtrair, nem ajuste no olho.
		s.centered = true
		s.position = _tela(mx, my, alt)
		add_child(s)

		if rotulo != "":
			var l := Label.new()
			l.text = rotulo
			l.add_theme_font_size_override("font_size", 9)
			l.add_theme_color_override("font_color", Color(0.08, 0.13, 0.2))
			l.add_theme_color_override("font_outline_color", Color(1, 1, 1, 0.85))
			l.add_theme_constant_override("outline_size", 3)
			l.position = _tela(mx, my, alt) + Vector2(-45, 5)
			l.size = Vector2(90, 12)
			l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			_rotulos.add_child(l)

		if SELECIONAVEIS.has(arquivo):
			_area_de_selecao(arquivo, mx, my, SELECIONAVEIS[arquivo])


## `Area2D` dimensionada pela BASE. A lista de revisão visual do pacote manda
## procurar "colisões maiores que o prédio", e é por isso que o polígono sai
## das células da base e não da caixa do sprite: o toldo do mercado avança
## 0,34 unidade e não pode roubar o toque de quem está no passeio.
func _montar_bancada() -> void:
	var origem := Vector2(CX_BANCADA, CY_BANCADA)
	for i in BANCADA.size():
		var arquivo: String = BANCADA[i][0]
		var caminho := "res://art/%s/%s.png" % [BANCADA[i][1], arquivo]
		if not ResourceLoader.exists(caminho):
			push_warning("asset ausente na bancada: %s" % caminho)
			continue
		var c := _celula(i)
		var p := _tela_em(origem, c.x, c.y)

		var s := Sprite2D.new()
		s.texture = load(caminho)
		s.name = "bancada_%s" % arquivo
		s.centered = true
		s.position = p
		add_child(s)

		var l := Label.new()
		l.text = BANCADA[i][2]
		l.add_theme_font_size_override("font_size", 9)
		l.add_theme_color_override("font_color", Color(0.08, 0.13, 0.2))
		l.add_theme_color_override("font_outline_color", Color(1, 1, 1, 0.9))
		l.add_theme_constant_override("outline_size", 3)
		l.position = p + Vector2(-45, 8)
		l.size = Vector2(90, 12)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_rotulos.add_child(l)


func _area_de_selecao(nome: String, mx: float, my: float, base: Vector2) -> void:
	var a := Area2D.new()
	a.name = "Selecao_%s" % nome
	a.input_pickable = true
	var poly := CollisionPolygon2D.new()
	var meia := base * 0.5
	var cantos := PackedVector2Array()
	for canto in [Vector2(-meia.x, -meia.y), Vector2(meia.x, -meia.y),
			Vector2(meia.x, meia.y), Vector2(-meia.x, meia.y)]:
		cantos.append(_tela(mx + canto.x, my + canto.y))
	poly.polygon = cantos
	a.add_child(poly)
	add_child(a)


func _draw() -> void:
	if not _grade:
		return
	# Grade de depuração: losangos de 1x1 célula. É ela que torna visível um
	# asset fora de escala — um prop certo encaixa nos losangos, um prop
	# desenhado noutra projeção cruza-os.
	var cor := Color(0.35, 0.45, 0.58, 0.28)
	for i in range(-9, 11):
		draw_line(_tela(i, -4), _tela(i, 9), cor, 1.0)
		draw_line(_tela(-9, i), _tela(10, i), cor, 1.0)

	# Grade da bancada, e uma cruz por célula.
	var origem := Vector2(CX_BANCADA, CY_BANCADA)
	for i in range(-8, 10):
		draw_line(_tela_em(origem, i, -8), _tela_em(origem, i, 10), cor, 1.0)
		draw_line(_tela_em(origem, -8, i), _tela_em(origem, 10, i), cor, 1.0)
	for i in BANCADA.size():
		var c := _celula(i)
		var p := _tela_em(origem, c.x, c.y)
		var cc := Color(0.78, 0.33, 0.13, 0.9)
		draw_line(p + Vector2(-5, 0), p + Vector2(5, 0), cc, 1.5)
		draw_line(p + Vector2(0, -3), p + Vector2(0, 3), cc, 1.5)

	# Cruz de âncora no ponto de contato de cada asset: é onde o prop DIZ que
	# encosta. Se a cruz não estiver debaixo da peça, a origem está errada.
	for linha in CENA:
		var p := _tela(linha[2], linha[3], linha[4])
		var c := Color(0.78, 0.33, 0.13, 0.9)
		draw_line(p + Vector2(-5, 0), p + Vector2(5, 0), c, 1.5)
		draw_line(p + Vector2(0, -3), p + Vector2(0, 3), c, 1.5)

	# Caixa de seleção, para se ver que ela cobre a base e não a silhueta.
	for nome in SELECIONAVEIS:
		for linha in CENA:
			if linha[0] != nome:
				continue
			var meia: Vector2 = SELECIONAVEIS[nome] * 0.5
			var pts := PackedVector2Array()
			for canto in [Vector2(-meia.x, -meia.y), Vector2(meia.x, -meia.y),
					Vector2(meia.x, meia.y), Vector2(-meia.x, meia.y),
					Vector2(-meia.x, -meia.y)]:
				pts.append(_tela(linha[2] + canto.x, linha[3] + canto.y))
			draw_polyline(pts, Color(0.11, 0.48, 0.25, 0.95), 1.5)
