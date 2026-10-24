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

# OS CAVALETES DA OBRA DA RUA (`140`): entre os cones, no eixo, um dia por
# quadro — cone, cavalete, cone, cavalete, cone. É a lista
# `cavaletes_da_obra` da tabela, copiada pela razão do `PATIO`; nascem e
# morrem com os cones.
const CAVALETE := preload("res://art/props/cavalete_obra.png")
const CAVALETES: Array = [
	[0, [Vector2(1.53, 7.1), Vector2(2.43, 7.1)]],
	[1, [Vector2(5.53, 15.1), Vector2(6.43, 15.1)]],
	[2, [Vector2(9.53, 23.1), Vector2(10.43, 23.1)]],
]

# O MOBILIÁRIO DA RUA (`140`): os postes na calçada da vila e as placas na do
# porto, `[tipo, ponto em mundo, quadro]`. Escolha do Bruno: a rua gasta do
# porto em ruínas leva os VELHOS, e a obra do pátio troca cada um pelo novo
# no dia em que o trecho dele é recapeado — o mesmo `quadro` da `RUA`. Ao
# contrário dos cones, existem sempre: plantam-se ao montar a cena, entre os
# irmãos do `Cenario` pela profundidade, e o que muda é a textura. É a lista
# `mobiliario_da_rua` da tabela, copiada pela razão do `PATIO`.
const MOBILIARIO: Array = [
	["poste", Vector2(-0.91, -1.0), 0], ["poste", Vector2(-0.91, 2.5), 0],
	["poste", Vector2(3.09, 9.5), 1], ["poste", Vector2(3.09, 11.8), 1],
	["poste", Vector2(7.09, 17.0), 2], ["poste", Vector2(7.09, 20.5), 2],
	["poste", Vector2(11.09, 25.0), 3], ["poste", Vector2(11.09, 28.5), 3],
	["pare", Vector2(1.11, 2.23), 0], ["pare", Vector2(5.11, 10.23), 1],
	["pare", Vector2(9.11, 18.23), 2],
	["pedestres", Vector2(1.11, 5.89), 0], ["pedestres", Vector2(5.11, 13.89), 1],
	["velocidade", Vector2(9.11, 21.4), 2],
]
## A arte de cada tipo: `[velha, nova]`.
const ARTE_DO_MOBILIARIO := {
	"poste": [preload("res://art/props/poste_rua_velho.png"),
		preload("res://art/props/poste_rua_novo.png")],
	"pare": [preload("res://art/props/placa_pare_velha.png"),
		preload("res://art/props/placa_pare_nova.png")],
	"pedestres": [preload("res://art/props/placa_pedestres_velha.png"),
		preload("res://art/props/placa_pedestres_nova.png")],
	"velocidade": [preload("res://art/props/placa_velocidade_velha.png"),
		preload("res://art/props/placa_velocidade_nova.png")],
}

var _mapa: TextureRect
var _asfalto: Polygon2D
var _canteiro: TextureRect
var _rua_velha: Polygon2D
var _rua_nova: Polygon2D
## A lâmpada de sódio do poste VELHO, à parte para piscar (`140`): o nome
## começa por `PosteLuz`, e é por ele que o `_animar_luzes` do `Main` a acha,
## como à do poste do pátio — aqui na `RedeDaRua`, e não no `Cenario`. O
## poste novo é LED e não pisca.
const LUZ_DE_SODIO := preload("res://art/props/poste_rua_luz.png")

# A FIAÇÃO (`140`): três fios de cruzeta a cruzeta, entre os postes da mesma
# reta, pousados nos isoladores. Os números são os do `brp_porto.py`
# (`POSTE_ISOLADOR`, `POSTE_ISOLADORES`, `POSTE_VELHO_TOMBO`) com a régua das
# alturas do kit (`ALTURA_PX`, 36,74 px do mapa por unidade, a 2/3 no espaço
# tela); o D45 confere no PNG que a ponta de cada fio cai em cima do desenho
# do isolador, nos dois estados — se o poste mudar e isto não, reprova.
const POSTE_ISOLADOR_PX := 50.0
const POSTE_ISOLADORES: Array[float] = [-0.27, 0.13, 0.27]
const POSTE_VELHO_TOMBO := 6.0
const ALTURA_PX := 36.742346
const ZOOM := 2.0 / 3.0
## A barriga do fio a meio do vão, em px de tela: mais solta na rede velha.
const FIO_BARRIGA: Array[float] = [4.5, 3.0]
const FIO_PONTOS := 9

var _cones: Array[TextureRect] = []
var _mobiliario: Array[TextureRect] = []
var _luzes: Array[TextureRect] = []
## Os fios, `[índice do poste A, índice do poste B, isolador, Line2D]`.
var _fios: Array = []


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
	_plantar_o_mobiliario()


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
	_trocar_o_mobiliario(q)
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
	# Os cavaletes vão na mesma lista dos cones: nascem e morrem com eles.
	for par in [[CONES, CONE, "ConeDaRua"], [CAVALETES, CAVALETE, "CavaleteDaRua"]]:
		for dia in par[0]:
			if int(dia[0]) != q:
				continue
			for v in dia[1]:
				var peca := _prop_no_chao(par[1], v)
				peca.name = "%s%d" % [par[2], _cones.size()]
				_plantar(cenario, peca)
				_cones.append(peca)


## Um prop pousado no chão do porto em `v`, no quadro de 512 (`029`).
static func _prop_no_chao(textura: Texture2D, v: Vector2) -> TextureRect:
	var no := TextureRect.new()
	no.texture = textura
	no.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	no.mouse_filter = Control.MOUSE_FILTER_IGNORE
	no.size = Vector2(PropIso.QUADRO, PropIso.QUADRO)
	no.position = tela(v.x, v.y) - Vector2(PropIso.QUADRO, PropIso.QUADRO) / 2.0
	return no


## Entra no `Cenario` no índice que a profundidade pede — contar os irmãos
## acima dele na tela, a mesma leitura do `_ordenar_por_profundidade()` dos
## camiões e da D3.
static func _plantar(cenario: Node, no: Control) -> void:
	var indice := 0
	for outro in cenario.get_children():
		if outro is Control and (outro as Control).position.y < no.position.y:
			indice += 1
	cenario.add_child(no)
	cenario.move_child(no, indice)


## O mobiliário da rua, plantado UMA vez ao montar a cena, com a arte velha:
## quem a troca é o `_trocar_o_mobiliario()`. Planta-se aqui, e não no
## primeiro `refresh()`, pela razão da mata: o trânsito reordena os camiões
## entre os irmãos, e os irmãos têm de lá estar antes de ele começar.
func _plantar_o_mobiliario() -> void:
	if _canteiro == null or _canteiro.get_parent() == null:
		return
	var cenario := _canteiro.get_parent()
	# A REDE DA RUA — as lâmpadas de sódio e a fiação — desenha-se ANTES do
	# `Cenario`, por cima do mapa e debaixo de todo prop: os postes tapam as
	# pontas dos fios, e os camiões, os prédios do pátio e os coqueiros, que
	# estão todos à frente da calçada da vila, passam-lhe por cima — que é
	# onde estão.
	# ⚠️ A LÂMPADA NÃO VAI NO `Cenario` AO LADO DO POSTE, como a do poste do
	# pátio: lá o D30 lê todo par no mesmo quadro como duas metades em que a
	# de cima POUSA NA PONTA da de baixo, e esta pende do braço, abaixo do
	# topo do poste. Aqui, debaixo dele, o poste não lhe tapa nada — a cúpula
	# fica por cima e a lâmpada por baixo —, e o quadro é o mesmo, ao pixel.
	var rede := Node2D.new()
	rede.name = "RedeDaRua"
	cenario.get_parent().add_child(rede)
	cenario.get_parent().move_child(rede, cenario.get_index())
	for i in MOBILIARIO.size():
		var peca: Array = MOBILIARIO[i]
		var tipo: String = peca[0]
		var no := _prop_no_chao(ARTE_DO_MOBILIARIO[tipo][0], peca[1])
		no.name = ("PosteDaRua%d" if tipo == "poste" else "PlacaDaRua%d") % i
		_plantar(cenario, no)
		_mobiliario.append(no)
		var luz: TextureRect = null
		if tipo == "poste":
			luz = _prop_no_chao(LUZ_DE_SODIO, peca[1])
			luz.name = "PosteLuzDaRua%d" % i
			rede.add_child(luz)
		_luzes.append(luz)
	for a in MOBILIARIO.size():
		for b in range(a + 1, MOBILIARIO.size()):
			if not _postes_vizinhos(a, b):
				continue
			for k in POSTE_ISOLADORES.size():
				var fio := Line2D.new()
				fio.name = "Fio%d_%d_%d" % [a, b, k]
				fio.width = 1.0
				fio.default_color = Color(0.13, 0.15, 0.17, 0.85)
				fio.antialiased = true
				rede.add_child(fio)
				_fios.append([a, b, k, fio])
			break


## Dois postes ligam-se por fios quando estão na MESMA reta (o mesmo `mx`) e
## nenhum outro poste fica entre eles — a fiação não vira nos cotovelos.
static func _postes_vizinhos(a: int, b: int) -> bool:
	var pa: Array = MOBILIARIO[a]
	var pb: Array = MOBILIARIO[b]
	if pa[0] != "poste" or pb[0] != "poste":
		return false
	if not is_equal_approx((pa[1] as Vector2).x, (pb[1] as Vector2).x):
		return false
	for c in MOBILIARIO.size():
		var pc: Array = MOBILIARIO[c]
		if c == a or c == b or pc[0] != "poste":
			continue
		var vc: Vector2 = pc[1]
		if is_equal_approx(vc.x, (pa[1] as Vector2).x) \
				and vc.y > minf(pa[1].y, pb[1].y) and vc.y < maxf(pa[1].y, pb[1].y):
			return false
	return true


## Onde o fio pousa no isolador `k` de um poste em `v`, no espaço tela: o
## topo do isolador, rodado com o poste quando ele é o VELHO e pende para a
## rua (`+mx`) — a mesma rotação em Y do `_inclinar` do estúdio.
static func ponta_do_fio(v: Vector2, k: int, velho: bool) -> Vector2:
	var x := POSTE_ISOLADORES[k]
	var h := POSTE_ISOLADOR_PX / ALTURA_PX
	var t := deg_to_rad(POSTE_VELHO_TOMBO if velho else 0.0)
	var dx := x * cos(t) + h * sin(t)
	var dz := -x * sin(t) + h * cos(t)
	return tela(v.x + dx, v.y) - Vector2(0.0, dz * ALTURA_PX * ZOOM)


## O mobiliário plantado, pela ordem de `MOBILIARIO` (o D45 lê-o).
func mobiliario() -> Array[TextureRect]:
	return _mobiliario


## As lâmpadas de sódio, pela mesma ordem (`null` onde a peça não é poste).
func luzes() -> Array[TextureRect]:
	return _luzes


## Os fios, `[poste A, poste B, isolador, Line2D]`.
func fios() -> Array:
	return _fios


## A arte de cada peça no quadro `q` da obra do pátio: a nova onde o trecho
## dela já está recapeado. Fora da obra, quem decide é o pátio — pronto, a
## rua inteira é a nova; por fazer, é a gasta do porto em ruínas.
func _trocar_o_mobiliario(q: int) -> void:
	var pronto_fora_da_obra: bool = GameState.tem_estrutura("patio")
	var novos: Array[bool] = []
	for i in _mobiliario.size():
		var peca: Array = MOBILIARIO[i]
		var nova := int(peca[2]) <= q if q >= 0 else pronto_fora_da_obra
		novos.append(nova)
		_mobiliario[i].texture = ARTE_DO_MOBILIARIO[peca[0]][1 if nova else 0]
		if _luzes[i] != null:
			_luzes[i].visible = not nova
	# Os dois postes de um vão são da mesma reta, logo do mesmo estado.
	for f in _fios:
		var a: int = f[0]
		var b: int = f[1]
		var velho := not novos[a]
		var pa := ponta_do_fio(MOBILIARIO[a][1], f[2], velho)
		var pb := ponta_do_fio(MOBILIARIO[b][1], f[2], velho)
		var barriga: float = FIO_BARRIGA[0 if velho else 1]
		var pontos := PackedVector2Array()
		for s in FIO_PONTOS:
			var t := float(s) / float(FIO_PONTOS - 1)
			pontos.append(pa.lerp(pb, t) + Vector2(0.0, barriga * 4.0 * t * (1.0 - t)))
		(f[3] as Line2D).points = pontos


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
