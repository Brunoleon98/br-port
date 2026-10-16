extends RefCounted

# ============================================================
# BR Port VS — a OBRA NO MAPA (`docs/decisoes/121`)
#
# Do dia em que se paga uma obra ao dia em que ela fica pronta passam dois ou
# três dias jogados (`087`), e até à `121` o mapa não sabia: mostrava a mesma
# ruína, as mesmas estacas e a mesma terra batida, e a obra só existia no texto
# do botão Construir. O Bruno escolheu ver o que se está a fazer, DIA A DIA,
# sem pessoas: andaime e material no armazém, o tabuado a avançar no píer, e no
# pátio o asfalto a chegar do cais para a rua com o rolo na frente dele.
#
# O píer vive no `Dock` (a vaga sabe a textura dela); o armazém e o pátio vivem
# aqui. Os três perguntam o quadro ao MESMO sítio, `GameState.quadro_da_obra()`,
# e o D45 do teste de design confere, dia a dia, o que cada nó mostra.
#
# ⚠️ NÃO É UM `class_name`, pela regra do `TrafegoDeCamioes`: ele lê o
# `GameState` pelo nome. O `Main` carrega-o por `preload` e dá-lhe as três
# peças da cena que ele mexe.
# ============================================================

# Os quadros do armazém, um por dia de obra: a ruína limpa com andaime, e o
# galpão a que faltam o portão e um terço do telhado. Partilham o nó `Armazem`
# com a ruína e o pronto, como o pronto já partilhava com a ruína.
const ARMAZEM: Array[Texture2D] = [
	preload("res://art/props/galpao_obra_0.png"),
	preload("res://art/props/galpao_obra_1.png"),
]

# O canteiro do pátio, um por dia: o rolo compactador e a brita a gastar-se.
const CANTEIRO: Array[Texture2D] = [
	preload("res://art/props/patio_obra_0.png"),
	preload("res://art/props/patio_obra_1.png"),
	preload("res://art/props/patio_obra_2.png"),
]

# QUANTO DO PÁTIO JÁ É ASFALTO em cada quadro, a contar do avental para a
# rua — a obra chega do cais, que é por onde a carga entra. No primeiro dia
# não há asfalto nenhum: é o dia da brita. O rolo do quadro está desenhado na
# frente de cada fração (o comentário do `patio_obra_*` no gerador diz onde);
# quem mexer num número aqui mexe no `x` do rolo lá.
const ASFALTO_POR_QUADRO: Array[float] = [0.0, 0.40, 0.75]

# O PÁTIO DO MAPA, em unidades de mundo: `[my0, my1, mx da frente da rua, mx
# do avental]` por trecho de porto. É a lista `patio` da tabela de âncoras,
# copiada porque o JSON não vai no pacote exportado (`export_filter` é
# `all_resources`); o D45 confere a cópia contra a tabela, número a número.
const PATIO: Array = [
	[1.2, 8.06, 1.22, 4.7],
	[8.0, 16.06, 5.22, 8.7],
	[16.0, 22.5, 9.22, 12.7],
]

# A projeção do mapa no espaço TELA, a mesma da tabela de âncoras (`projecao`)
# e conferida contra ela no D45: o asfalto pousa à altura do cais.
const CX := 339.0
const CY := 95.5
const ALT_CAIS := 52.0 / 3.0
const MEIA_LARG := 20.0
const MEIA_ALT := 10.0

var _mapa: TextureRect
var _asfalto: Polygon2D
var _canteiro: TextureRect


func _init(mapa: TextureRect, asfalto: Polygon2D, canteiro: TextureRect) -> void:
	_mapa = mapa
	_asfalto = asfalto
	_canteiro = canteiro


## Onde um ponto do chão do porto cai na tela, à altura do cais.
static func tela(mx: float, my: float) -> Vector2:
	return Vector2(CX + (mx - my) * MEIA_LARG, CY + (mx + my) * MEIA_ALT - ALT_CAIS)


## Os quadriláteros de asfalto novo para uma fração do pátio, um por trecho:
## do avental até `fração` da largura, na direção da rua.
static func poligonos_do_asfalto(fracao: float) -> Array[PackedVector2Array]:
	var saida: Array[PackedVector2Array] = []
	if fracao <= 0.0:
		return saida
	for t in PATIO:
		var my0: float = t[0]
		var my1: float = t[1]
		var rua: float = t[2]
		var avental: float = t[3]
		var frente := avental - fracao * (avental - rua)
		saida.append(PackedVector2Array([tela(frente, my0), tela(avental, my0),
			tela(avental, my1), tela(frente, my1)]))
	return saida


## O armazém em obra, ou `null` quando ele não está em obra — e aí quem
## escolhe é o `Main`, entre a ruína e o pronto.
func textura_do_armazem() -> Texture2D:
	var q := int(GameState.quadro_da_obra("armazem", ARMAZEM.size()))
	if q < 0:
		return null
	return ARMAZEM[q]


## O pátio em obra: o canteiro e o asfalto que já chegou. Fora da obra os dois
## somem, e o mapa de baixo (terra ou pavimentado) é o `Main` que escolhe.
func refresh() -> void:
	var q := int(GameState.quadro_da_obra("patio", CANTEIRO.size()))
	if _canteiro != null:
		_canteiro.visible = q >= 0
		if q >= 0:
			_canteiro.texture = CANTEIRO[q]
	if _asfalto == null:
		return
	var fracao := 0.0
	if q >= 0:
		fracao = ASFALTO_POR_QUADRO[q]
	var partes := poligonos_do_asfalto(fracao)
	_asfalto.visible = not partes.is_empty()
	if partes.is_empty():
		return
	# O asfalto é o MAPA PRONTO recortado, e não uma cor: assim a mancha, a
	# junta e o acesso ao berço que o pátio pavimentado tem chegam com ele,
	# e no dia em que a obra acaba a troca do mapa inteiro não muda um pixel
	# do que já estava asfaltado.
	#
	# ⚠️ A UV É EM PIXEL DA TEXTURA, e a textura tem 1080 para um rect de 720
	# (`025`): o vértice multiplica-se pela razão, que sai das duas medidas
	# e não de um 1,5 escrito aqui.
	var razao := 1.0
	if _mapa != null and _mapa.size.x > 0.0 and _asfalto.texture != null:
		razao = float(_asfalto.texture.get_width()) / _mapa.size.x
	var vertices := PackedVector2Array()
	var indices: Array = []
	for parte in partes:
		var ids := PackedInt32Array()
		for v in parte:
			ids.append(vertices.size())
			vertices.append(v)
		indices.append(ids)
	var uv := PackedVector2Array()
	for v in vertices:
		uv.append(v * razao)
	_asfalto.polygon = vertices
	_asfalto.uv = uv
	_asfalto.polygons = indices
