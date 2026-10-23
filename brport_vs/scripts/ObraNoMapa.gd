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
#
# ⚠️ ERAM 40% E 75%, e o dia 2 não lia: na tela inteira, 40% do pátio é uma
# faixa cinzenta rente ao avental que se confunde com ele. O Bruno pediu mais
# asfalto nesse dia; o dia 3 subiu junto para a passada não encurtar.
const ASFALTO_POR_QUADRO: Array[float] = [0.0, 0.55, 0.80]

# O PÁTIO DO MAPA, em unidades de mundo: `[my0, my1, mx da frente da rua, mx
# do avental]` por trecho de porto. É a lista `patio` da tabela de âncoras,
# copiada porque o JSON não vai no pacote exportado (`export_filter` é
# `all_resources`); o D45 confere a cópia contra a tabela, número a número.
const PATIO: Array = [
	[1.2, 8.06, 1.22, 4.7],
	[8.0, 16.06, 5.22, 8.7],
	[16.0, 22.5, 9.22, 12.7],
]

# A RUA QUE A OBRA DO PÁTIO RECAPEIA (`136`), um trecho por dia, do norte
# para o sul: `[quadro, contorno em mundo]`. O Bruno pediu que a rua gasta do
# porto em ruínas virasse a recapeada *«por partes, que nem quando algo está
# sendo construído»*; o quadro 3 é o dia em que a obra acaba e o mapa inteiro
# troca. Cada contorno vai até ao MEIO da calçada, que é igual nos dois mapas.
# É a lista `obra_da_rua` da tabela de âncoras, copiada pela razão do `PATIO`,
# e o D45 confere a cópia contra a tabela.
const RUA: Array = [
	[0, [
		Vector2(-4.91, -14.0), Vector2(-2.89, -14.0), Vector2(-2.89, -7.8), Vector2(-4.91, -7.8)]],
	[0, [
		Vector2(-4.91, -7.91), Vector2(-0.38, -7.91), Vector2(-0.186, -7.897),
		Vector2(0.006, -7.859), Vector2(0.19, -7.797), Vector2(0.365, -7.71), Vector2(0.527, -7.602),
		Vector2(0.674, -7.474), Vector2(0.802, -7.327), Vector2(0.91, -7.165), Vector2(0.997, -6.99),
		Vector2(1.059, -6.806), Vector2(1.097, -6.614), Vector2(1.11, -6.42), Vector2(1.11, -5.89),
		Vector2(-3.42, -5.89), Vector2(-3.614, -5.903), Vector2(-3.806, -5.941),
		Vector2(-3.99, -6.003), Vector2(-4.165, -6.09), Vector2(-4.327, -6.198),
		Vector2(-4.474, -6.326), Vector2(-4.602, -6.473), Vector2(-4.71, -6.635),
		Vector2(-4.797, -6.81), Vector2(-4.859, -6.994), Vector2(-4.897, -7.186),
		Vector2(-4.91, -7.38)]],
	[0, [
		Vector2(-2.89, -7.91), Vector2(-2.89, -8.25), Vector2(-2.887, -8.206),
		Vector2(-2.878, -8.162), Vector2(-2.864, -8.12), Vector2(-2.844, -8.08),
		Vector2(-2.82, -8.043), Vector2(-2.79, -8.01), Vector2(-2.757, -7.98),
		Vector2(-2.72, -7.956), Vector2(-2.68, -7.936), Vector2(-2.638, -7.922),
		Vector2(-2.594, -7.913), Vector2(-2.55, -7.91)]],
	[0, [
		Vector2(-0.91, -5.89), Vector2(-0.91, -5.55), Vector2(-0.913, -5.594),
		Vector2(-0.922, -5.638), Vector2(-0.936, -5.68), Vector2(-0.956, -5.72),
		Vector2(-0.98, -5.757), Vector2(-1.01, -5.79), Vector2(-1.043, -5.82),
		Vector2(-1.08, -5.844), Vector2(-1.12, -5.864), Vector2(-1.162, -5.878),
		Vector2(-1.206, -5.887), Vector2(-1.25, -5.89)]],
	[0, [
		Vector2(-0.91, -6.0), Vector2(1.11, -6.0), Vector2(1.11, 6.2), Vector2(-0.91, 6.2)]],
	[1, [
		Vector2(-0.91, 6.09), Vector2(3.62, 6.09), Vector2(3.814, 6.103), Vector2(4.006, 6.141),
		Vector2(4.19, 6.203), Vector2(4.365, 6.29), Vector2(4.527, 6.398), Vector2(4.674, 6.526),
		Vector2(4.802, 6.673), Vector2(4.91, 6.835), Vector2(4.997, 7.01), Vector2(5.059, 7.194),
		Vector2(5.097, 7.386), Vector2(5.11, 7.58), Vector2(5.11, 8.11), Vector2(0.58, 8.11),
		Vector2(0.386, 8.097), Vector2(0.194, 8.059), Vector2(0.01, 7.997), Vector2(-0.165, 7.91),
		Vector2(-0.327, 7.802), Vector2(-0.474, 7.674), Vector2(-0.602, 7.527),
		Vector2(-0.71, 7.365), Vector2(-0.797, 7.19), Vector2(-0.859, 7.006), Vector2(-0.897, 6.814),
		Vector2(-0.91, 6.62)]],
	[1, [
		Vector2(1.11, 6.09), Vector2(1.11, 5.75), Vector2(1.113, 5.794), Vector2(1.122, 5.838),
		Vector2(1.136, 5.88), Vector2(1.156, 5.92), Vector2(1.18, 5.957), Vector2(1.21, 5.99),
		Vector2(1.243, 6.02), Vector2(1.28, 6.044), Vector2(1.32, 6.064), Vector2(1.362, 6.078),
		Vector2(1.406, 6.087), Vector2(1.45, 6.09)]],
	[1, [
		Vector2(3.09, 8.11), Vector2(3.09, 8.45), Vector2(3.087, 8.406), Vector2(3.078, 8.362),
		Vector2(3.064, 8.32), Vector2(3.044, 8.28), Vector2(3.02, 8.243), Vector2(2.99, 8.21),
		Vector2(2.957, 8.18), Vector2(2.92, 8.156), Vector2(2.88, 8.136), Vector2(2.838, 8.122),
		Vector2(2.794, 8.113), Vector2(2.75, 8.11)]],
	[1, [
		Vector2(3.09, 8.0), Vector2(5.11, 8.0), Vector2(5.11, 14.2), Vector2(3.09, 14.2)]],
	[2, [
		Vector2(3.09, 14.09), Vector2(7.62, 14.09), Vector2(7.814, 14.103), Vector2(8.006, 14.141),
		Vector2(8.19, 14.203), Vector2(8.365, 14.29), Vector2(8.527, 14.398), Vector2(8.674, 14.526),
		Vector2(8.802, 14.673), Vector2(8.91, 14.835), Vector2(8.997, 15.01), Vector2(9.059, 15.194),
		Vector2(9.097, 15.386), Vector2(9.11, 15.58), Vector2(9.11, 16.11), Vector2(4.58, 16.11),
		Vector2(4.386, 16.097), Vector2(4.194, 16.059), Vector2(4.01, 15.997), Vector2(3.835, 15.91),
		Vector2(3.673, 15.802), Vector2(3.526, 15.674), Vector2(3.398, 15.527),
		Vector2(3.29, 15.365), Vector2(3.203, 15.19), Vector2(3.141, 15.006), Vector2(3.103, 14.814),
		Vector2(3.09, 14.62)]],
	[2, [
		Vector2(5.11, 14.09), Vector2(5.11, 13.75), Vector2(5.113, 13.794), Vector2(5.122, 13.838),
		Vector2(5.136, 13.88), Vector2(5.156, 13.92), Vector2(5.18, 13.957), Vector2(5.21, 13.99),
		Vector2(5.243, 14.02), Vector2(5.28, 14.044), Vector2(5.32, 14.064), Vector2(5.362, 14.078),
		Vector2(5.406, 14.087), Vector2(5.45, 14.09)]],
	[2, [
		Vector2(7.09, 16.11), Vector2(7.09, 16.45), Vector2(7.087, 16.406), Vector2(7.078, 16.362),
		Vector2(7.064, 16.32), Vector2(7.044, 16.28), Vector2(7.02, 16.243), Vector2(6.99, 16.21),
		Vector2(6.957, 16.18), Vector2(6.92, 16.156), Vector2(6.88, 16.136), Vector2(6.838, 16.122),
		Vector2(6.794, 16.113), Vector2(6.75, 16.11)]],
	[2, [
		Vector2(7.09, 16.0), Vector2(9.11, 16.0), Vector2(9.11, 22.2), Vector2(7.09, 22.2)]],
	[3, [
		Vector2(7.09, 22.09), Vector2(11.62, 22.09), Vector2(11.814, 22.103),
		Vector2(12.006, 22.141), Vector2(12.19, 22.203), Vector2(12.365, 22.29),
		Vector2(12.527, 22.398), Vector2(12.674, 22.526), Vector2(12.802, 22.673),
		Vector2(12.91, 22.835), Vector2(12.997, 23.01), Vector2(13.059, 23.194),
		Vector2(13.097, 23.386), Vector2(13.11, 23.58), Vector2(13.11, 24.11), Vector2(8.58, 24.11),
		Vector2(8.386, 24.097), Vector2(8.194, 24.059), Vector2(8.01, 23.997), Vector2(7.835, 23.91),
		Vector2(7.673, 23.802), Vector2(7.526, 23.674), Vector2(7.398, 23.527),
		Vector2(7.29, 23.365), Vector2(7.203, 23.19), Vector2(7.141, 23.006), Vector2(7.103, 22.814),
		Vector2(7.09, 22.62)]],
	[3, [
		Vector2(9.11, 22.09), Vector2(9.11, 21.75), Vector2(9.113, 21.794), Vector2(9.122, 21.838),
		Vector2(9.136, 21.88), Vector2(9.156, 21.92), Vector2(9.18, 21.957), Vector2(9.21, 21.99),
		Vector2(9.243, 22.02), Vector2(9.28, 22.044), Vector2(9.32, 22.064), Vector2(9.362, 22.078),
		Vector2(9.406, 22.087), Vector2(9.45, 22.09)]],
	[3, [
		Vector2(11.09, 24.11), Vector2(11.09, 24.45), Vector2(11.087, 24.406),
		Vector2(11.078, 24.362), Vector2(11.064, 24.32), Vector2(11.044, 24.28),
		Vector2(11.02, 24.243), Vector2(10.99, 24.21), Vector2(10.957, 24.18),
		Vector2(10.92, 24.156), Vector2(10.88, 24.136), Vector2(10.838, 24.122),
		Vector2(10.794, 24.113), Vector2(10.75, 24.11)]],
	[3, [
		Vector2(11.09, 24.0), Vector2(13.11, 24.0), Vector2(13.11, 32.2), Vector2(11.09, 32.2)]],
	[3, [
		Vector2(11.09, 32.09), Vector2(15.62, 32.09), Vector2(15.814, 32.103),
		Vector2(16.006, 32.141), Vector2(16.19, 32.203), Vector2(16.365, 32.29),
		Vector2(16.527, 32.398), Vector2(16.674, 32.526), Vector2(16.802, 32.673),
		Vector2(16.91, 32.835), Vector2(16.997, 33.01), Vector2(17.059, 33.194),
		Vector2(17.097, 33.386), Vector2(17.11, 33.58), Vector2(17.11, 34.11), Vector2(12.58, 34.11),
		Vector2(12.386, 34.097), Vector2(12.194, 34.059), Vector2(12.01, 33.997),
		Vector2(11.835, 33.91), Vector2(11.673, 33.802), Vector2(11.526, 33.674),
		Vector2(11.398, 33.527), Vector2(11.29, 33.365), Vector2(11.203, 33.19),
		Vector2(11.141, 33.006), Vector2(11.103, 32.814), Vector2(11.09, 32.62)]],
	[3, [
		Vector2(13.11, 32.09), Vector2(13.11, 31.75), Vector2(13.113, 31.794),
		Vector2(13.122, 31.838), Vector2(13.136, 31.88), Vector2(13.156, 31.92),
		Vector2(13.18, 31.957), Vector2(13.21, 31.99), Vector2(13.243, 32.02),
		Vector2(13.28, 32.044), Vector2(13.32, 32.064), Vector2(13.362, 32.078),
		Vector2(13.406, 32.087), Vector2(13.45, 32.09)]],
	[3, [
		Vector2(15.09, 34.11), Vector2(15.09, 34.45), Vector2(15.087, 34.406),
		Vector2(15.078, 34.362), Vector2(15.064, 34.32), Vector2(15.044, 34.28),
		Vector2(15.02, 34.243), Vector2(14.99, 34.21), Vector2(14.957, 34.18),
		Vector2(14.92, 34.156), Vector2(14.88, 34.136), Vector2(14.838, 34.122),
		Vector2(14.794, 34.113), Vector2(14.75, 34.11)]],
	[3, [
		Vector2(15.09, 34.0), Vector2(17.11, 34.0), Vector2(17.11, 42.06), Vector2(15.09, 42.06)]],
]

# A projeção do mapa no espaço TELA, a mesma da tabela de âncoras (`projecao`)
# e conferida contra ela no D45: o asfalto pousa à altura do cais.
const CX := 339.0
const CY := 95.5
const ALT_CAIS := 52.0 / 3.0
const MEIA_LARG := 20.0
const MEIA_ALT := 10.0

# OS CONES DA OBRA DA RUA (`136`): três no eixo, na frente do trecho que a
# obra recapeia a seguir — `[dia, pontos em mundo]`, um dia por quadro do
# canteiro. *«Obra da rua sem sinalização»*: o trecho trocava de cor e mais
# nada. É a lista `cones_da_obra` da tabela, copiada pela razão do `PATIO`.
# Nascem e morrem com a obra, entre os irmãos do `Cenario` pela profundidade,
# como os camiões; fora da obra não existem, e nenhuma guarda de cenário os
# vê pisar a rua — é a única vez que um cone a pisa com razão (D2).
const CONE := preload("res://art/props/cone_transito.png")
const CONES: Array = [
	[0, [
		Vector2(1.08, 7.1), Vector2(1.98, 7.1), Vector2(2.88, 7.1)]],
	[1, [
		Vector2(5.08, 15.1), Vector2(5.98, 15.1), Vector2(6.88, 15.1)]],
	[2, [
		Vector2(9.08, 23.1), Vector2(9.98, 23.1), Vector2(10.88, 23.1)]],
]

var _mapa: TextureRect
var _asfalto: Polygon2D
var _canteiro: TextureRect
var _rua_velha: Polygon2D
var _rua_nova: Polygon2D
var _cones: Array[TextureRect] = []


## A rua: `rua_velha` é o mapa de TERRA por cima do asfalto novo do pátio,
## nos trechos ainda por recapear — o recorte do pátio atravessa três
## cotovelos, e sem ele o pátio recapeava-os antes do dia deles —, e
## `rua_nova` o mapa PAVIMENTADO nos trechos prontos, por cima de tudo.
func _init(mapa: TextureRect, asfalto: Polygon2D, canteiro: TextureRect,
		rua_velha: Polygon2D = null, rua_nova: Polygon2D = null) -> void:
	_mapa = mapa
	_asfalto = asfalto
	_canteiro = canteiro
	_rua_velha = rua_velha
	_rua_nova = rua_nova


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


## Os contornos da rua na tela: os trechos PRONTOS no quadro `quadro`
## (`prontos`), ou os que ainda faltam.
static func poligonos_da_rua(quadro: int, prontos: bool) -> Array[PackedVector2Array]:
	var saida: Array[PackedVector2Array] = []
	for trecho in RUA:
		if (int(trecho[0]) <= quadro) != prontos:
			continue
		var pontos := PackedVector2Array()
		for v in trecho[1]:
			pontos.append(tela(v.x, v.y))
		saida.append(pontos)
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
	# A rua primeiro: ela recapeia já no dia da brita, quando o pátio ainda
	# não tem asfalto nenhum.
	var prontos: Array = []
	var faltam: Array = []
	if q >= 0:
		prontos = poligonos_da_rua(q, true)
		faltam = poligonos_da_rua(q, false)
	_recortar(_rua_nova, prontos)
	_recortar(_rua_velha, faltam)
	_sinalizar_a_rua(q)
	var fracao := 0.0
	if q >= 0:
		fracao = ASFALTO_POR_QUADRO[q]
	_recortar(_asfalto, poligonos_do_asfalto(fracao))


## Os cones do dia `q` da obra, e nenhum fora dela. Cada um entra no
## `Cenario` no índice que a profundidade dele pede — contar os irmãos acima
## dele na tela, a mesma leitura do `_ordenar_por_profundidade()` dos camiões.
func _sinalizar_a_rua(q: int) -> void:
	for cone in _cones:
		if is_instance_valid(cone):
			cone.get_parent().remove_child(cone)
			cone.free()
	_cones.clear()
	if q < 0 or _canteiro == null:
		return
	var cenario := _canteiro.get_parent()
	for dia in CONES:
		if int(dia[0]) != q:
			continue
		for v in dia[1]:
			var cone := TextureRect.new()
			cone.name = "ConeDaRua%d" % _cones.size()
			cone.texture = CONE
			cone.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			cone.mouse_filter = Control.MOUSE_FILTER_IGNORE
			cone.size = Vector2(PropIso.QUADRO, PropIso.QUADRO)
			cone.position = tela(v.x, v.y) - Vector2(PropIso.QUADRO, PropIso.QUADRO) / 2.0
			var indice := 0
			for outro in cenario.get_children():
				if outro is Control and (outro as Control).position.y < cone.position.y:
					indice += 1
			cenario.add_child(cone)
			cenario.move_child(cone, indice)
			_cones.append(cone)


## Um recorte do mapa: o nó mostra a textura DELE nos contornos dados, e
## some quando não há nenhum.
##
## O asfalto é o MAPA PRONTO recortado, e não uma cor: assim a mancha, a
## junta e o acesso ao berço que o pátio pavimentado tem chegam com ele, e no
## dia em que a obra acaba a troca do mapa inteiro não muda um pixel do que já
## estava asfaltado. A rua velha é o mapa de TERRA recortado pela mesma conta.
func _recortar(no: Polygon2D, partes: Array) -> void:
	if no == null:
		return
	no.visible = not partes.is_empty()
	if partes.is_empty():
		return
	# ⚠️ A UV É EM PIXEL DA TEXTURA, e a textura tem 1080 para um rect de 720
	# (`025`): o vértice multiplica-se pela razão, que sai das duas medidas
	# e não de um 1,5 escrito aqui.
	var razao := 1.0
	if _mapa != null and _mapa.size.x > 0.0 and no.texture != null:
		razao = float(no.texture.get_width()) / _mapa.size.x
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
	no.polygon = vertices
	no.uv = uv
	no.polygons = indices
