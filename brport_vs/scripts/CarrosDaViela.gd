extends RefCounted

# ============================================================
# BR Port VS — OS CARROS DA VIELA (`docs/decisoes/141`)
#
# *«Os carros estacionados»*, que a `140` deixou de fora. Na rua do porto
# não cabem — entre o camião e o meio-fio sobram 0,18, e um carro tem ~0,3
# —, e o Bruno pô-los na VIELA DE TERRA entre as duas fileiras de casas,
# com a rua a ser rodovia. Os velhos (fusca, kombi, picape e hatch
# desbotados) são do porto em ruínas; os novos (hatch e picape) chegam com a
# Fase 2. As motos da primeira passagem saíram: a 13 px liam como um ponto.
# O número cresce com a FASE e com as OBRAS do porto, escolha
# dele: cada carro tem a fase em que aparece e quantos reparos dessa fase já
# têm de estar prontos (`aparece()`).
#
# Estão parados e não trocam de textura, ao contrário do mobiliário da rua:
# plantam-se UMA vez ao montar a cena, entre os irmãos do `Cenario` pela
# profundidade (a razão da mata — o trânsito reordena os camiões entre
# eles), e o `refresh()` só os mostra ou esconde.
#
# ⚠️ A VIELA ESTÁ QUASE TODA ATRÁS DA FILEIRA DA FRENTE, e os sítios foram
# escolhidos onde um carro se vê acima de 80% (`CARROS_DA_VIELA` no
# gerador). O que sobra atrás de um lote esconde-o o shader do mobiliário
# (`vila_a_frente.gdshader`), pelo contorno de cada lote — a pergunta do
# poste atrás da igreja, um carro abaixo.
#
# ⚠️ NÃO É UM `class_name`, pela regra do `TrafegoDeCamioes`, da
# `ObraNoMapa` e da `MataNoMapa`: o `Main` carrega-o por `preload`.
# ============================================================

const Obra := preload("res://scripts/ObraNoMapa.gd")

# `[prop, ponto em mundo, fase, obras]`: a lista `carros_da_viela` da tabela
# de âncoras, copiada porque o JSON não vai no pacote exportado (a razão da
# `ObraNoMapa`). O D50 confere a cópia contra a tabela.
const CARROS: Array = [
	["carro_fusca_velho", Vector2(-3.725, 1.2), 1, 0],
	["carro_kombi_velha", Vector2(0.275, 13.6), 1, 0],
	["carro_fusca_velho_b", Vector2(-3.725, 2.5), 1, 0],
	["carro_picape_velha", Vector2(4.275, 17.6), 1, 1],
	["carro_hatch_velho", Vector2(-3.725, 4.6), 1, 2],
	["carro_hatch_velho_b", Vector2(0.275, 8.8), 1, 3],
	["carro_hatch_novo", Vector2(-2.875, 0.2), 2, 0],
	["carro_picape_nova", Vector2(-3.725, 6.0), 2, 1],
	["carro_hatch_novo_b", Vector2(1.125, 14.2), 2, 2],
	["carro_hatch_novo_c", Vector2(4.275, 18.9), 2, 3],
	["carro_moto_velha", Vector2(-2.875, 1.6), 1, 0],
	["carro_moto_nova", Vector2(1.125, 8.9), 2, 0],
	["carro_moto_velha_b", Vector2(4.275, 16.75), 1, 2],
	["carro_moto_nova_b", Vector2(-2.875, 2.7), 2, 2],
]

const ARTE := {
	"carro_fusca_velho": preload("res://art/props/carro_fusca_velho.png"),
	"carro_kombi_velha": preload("res://art/props/carro_kombi_velha.png"),
	"carro_fusca_velho_b": preload("res://art/props/carro_fusca_velho_b.png"),
	"carro_picape_velha": preload("res://art/props/carro_picape_velha.png"),
	"carro_hatch_velho": preload("res://art/props/carro_hatch_velho.png"),
	"carro_hatch_velho_b": preload("res://art/props/carro_hatch_velho_b.png"),
	"carro_hatch_novo": preload("res://art/props/carro_hatch_novo.png"),
	"carro_picape_nova": preload("res://art/props/carro_picape_nova.png"),
	"carro_hatch_novo_b": preload("res://art/props/carro_hatch_novo_b.png"),
	"carro_hatch_novo_c": preload("res://art/props/carro_hatch_novo_c.png"),
	"carro_moto_velha": preload("res://art/props/carro_moto_velha.png"),
	"carro_moto_nova": preload("res://art/props/carro_moto_nova.png"),
	"carro_moto_velha_b": preload("res://art/props/carro_moto_velha_b.png"),
	"carro_moto_nova_b": preload("res://art/props/carro_moto_nova_b.png"),
}

# `[índice em CARROS, primeira coluna, o y de cima do que fica à frente]`: a
# lista `mascara_dos_carros` da tabela, copiada pela mesma razão.
const MASCARA: Array = [
	[3, 32, [
		316.0, 316.0, 317.4, 317.4, 314.9, 314.4, 314.0, 314.0, 314.4, 314.9,
		318.2, 317.7, 317.2, 316.7, 316.2, 315.7, 315.2, 314.7, 314.2, 313.7,
		313.2, 312.7, 312.2, 311.7, 311.2, 310.7, 310.2, 309.7, 309.2, 308.7,
		308.2, 307.7, 307.2, 306.7, 306.6, 307.0, 307.5, 307.1, 306.6, 306.1,
		305.6, 305.1, 304.6, 304.1, 303.6, 303.1, 302.6, 302.1, 301.6, 301.1,
		300.6, 300.1, 299.6, 299.1, 298.6, 298.1, 297.6, 297.1, 296.6, 296.5,
		296.9, 297.4, 297.9, 288.5, 287.3, 286.1, 284.9, 283.8, 282.6, 281.4,
		280.3, 279.1, 277.9, 276.7, 276.4, 276.5, 276.7, 276.9, 267.5, 266.7,
		266.0
	]],
	[4, 133, [
		133.1, 132.6, 132.0, 131.6, 131.1, 130.5, 130.1, 129.6, 129.1, 128.5,
		128.1, 127.6, 127.3, 127.6, 128.3, 129.1, 129.8, 130.5, 131.2, 131.9,
		132.6, 133.4, 134.1, 134.8, 135.5, 136.2, 136.9, 137.7, 138.4, 139.1,
		139.8, 140.5, 141.2, 142.0, 142.7, 143.4, 144.1, 144.8, 145.5, 146.3,
		154.9, 155.4, 155.9, 187.1, 187.6, 188.1, 188.6, 189.1, 189.6, 101.9,
		101.4, 99.7, 99.8, 87.1, 86.6, 86.1, 85.6, 85.1, 84.6, 84.1,
		83.6, 83.1, 82.6, 82.1, 81.6, 81.1, 80.6, 80.1, 79.6, 79.1,
		78.6, 78.1, 77.6, 77.6, 78.0, 78.5, 79.0, 79.5, 80.0, 80.5,
		81.0
	]],
	[5, 129, [
		186.8, 186.8, 186.8, 186.8, 186.8, 186.8, 188.1, 188.8, 189.5, 189.3,
		177.6, 177.6, 175.2, 172.9, 172.9, 172.9, 172.2, 172.2, 171.4, 169.9,
		169.9, 169.9, 169.9, 169.9, 171.4, 171.4, 171.4, 171.4, 171.4, 172.9,
		172.9, 174.5, 173.7, 173.7, 174.5, 175.2, 177.6, 182.2, 182.6, 183.1,
		183.6, 184.1, 184.6, 185.1, 185.6, 186.1, 186.6, 187.1, 187.6, 188.1,
		188.6, 189.1, 189.6, 190.1, 190.6, 191.1, 191.6, 192.1, 192.6, 193.1,
		193.6, 194.1, 202.5, 203.0, 203.5, 204.0, 204.5, 720.0, 720.0, 720.0,
		720.0, 720.0, 720.0, 720.0, 720.0, 720.0, 720.0, 720.0, 720.0, 720.0,
		720.0
	]],
	[8, 38, [
		241.3, 241.3, 240.7, 240.0, 239.4, 238.7, 238.7, 238.7, 240.0, 240.0,
		240.7, 240.7, 241.3, 241.3, 240.7, 240.7, 241.3, 243.2, 243.2, 245.8,
		247.7, 247.7, 254.4, 253.9, 253.5, 253.0, 252.5, 252.1, 252.2, 252.7,
		253.2, 253.7, 254.2, 254.7, 255.2, 255.7, 256.2, 256.7, 257.2, 257.7,
		258.2, 258.7, 259.2, 259.7, 260.2, 260.7, 261.2, 261.7, 262.2, 262.7,
		268.5, 269.4, 270.3, 271.2, 274.4, 274.9, 275.4, 276.0, 287.3, 286.1,
		284.9, 283.8, 282.6, 281.4, 280.3, 279.1, 277.9, 276.7, 276.4, 276.5,
		276.7, 276.9, 267.5, 266.7, 266.0, 265.2, 264.4, 263.6, 262.9, 262.1,
		261.3
	]],
	[9, 7, [
		348.5, 348.0, 347.5, 347.0, 346.5, 346.0, 345.5, 326.4, 326.7, 324.9,
		321.6, 321.6, 319.5, 317.4, 317.4, 317.4, 316.7, 316.0, 314.6, 314.6,
		314.6, 314.6, 314.6, 316.0, 316.0, 316.0, 316.0, 317.4, 317.4, 314.9,
		314.4, 314.0, 314.0, 314.4, 314.9, 318.2, 317.7, 317.2, 316.7, 316.2,
		315.7, 315.2, 314.7, 314.2, 313.7, 313.2, 312.7, 312.2, 311.7, 311.2,
		310.7, 310.2, 309.7, 309.2, 308.7, 308.2, 307.7, 307.2, 306.7, 306.6,
		307.0, 307.5, 307.1, 306.6, 306.1, 305.6, 305.1, 304.6, 304.1, 303.6,
		303.1, 302.6, 302.1, 301.6, 301.1, 300.6, 300.1, 299.6, 299.1, 298.6,
		298.1
	]],
	[11, 144, [
		172.9, 172.2, 172.2, 171.4, 169.9, 169.9, 169.9, 169.9, 169.9, 171.4,
		171.4, 171.4, 171.4, 171.4, 172.9, 172.9, 174.5, 173.7, 173.7, 174.5,
		175.2, 177.6, 182.2, 182.6, 183.1, 183.6, 184.1, 184.6, 185.1, 185.6,
		186.1, 186.6, 187.1, 187.6, 188.1, 188.6, 189.1, 189.6, 190.1, 190.6,
		191.1, 191.6, 192.1, 192.6, 193.1, 193.6, 194.1, 202.5, 203.0, 203.5,
		204.0, 204.5, 720.0, 720.0, 720.0, 720.0, 720.0, 720.0, 720.0, 720.0,
		720.0, 720.0, 720.0, 720.0, 720.0, 720.0, 720.0, 720.0, 720.0, 720.0,
		720.0, 720.0, 720.0, 720.0, 720.0, 720.0, 720.0, 720.0, 720.0, 720.0,
		720.0
	]],
	[12, 50, [
		314.2, 313.7, 313.2, 312.7, 312.2, 311.7, 311.2, 310.7, 310.2, 309.7,
		309.2, 308.7, 308.2, 307.7, 307.2, 306.7, 306.6, 307.0, 307.5, 307.1,
		306.6, 306.1, 305.6, 305.1, 304.6, 304.1, 303.6, 303.1, 302.6, 302.1,
		301.6, 301.1, 300.6, 300.1, 299.6, 299.1, 298.6, 298.1, 297.6, 297.1,
		296.6, 296.5, 296.9, 297.4, 297.9, 288.5, 287.3, 286.1, 284.9, 283.8,
		282.6, 281.4, 280.3, 279.1, 277.9, 276.7, 276.4, 276.5, 276.7, 276.9,
		267.5, 266.7, 266.0, 265.2, 264.4, 263.6, 262.9, 262.1, 261.3, 260.5,
		255.7, 255.2, 253.8, 253.7, 253.9, 254.0, 260.3, 261.1, 261.9, 262.6,
		263.4
	]],
	[13, 188, [
		86.1, 85.6, 85.1, 84.6, 84.1, 83.6, 83.1, 82.6, 82.1, 81.6,
		81.1, 80.6, 80.1, 79.6, 79.1, 78.6, 78.1, 77.6, 77.6, 78.0,
		78.5, 79.0, 79.5, 80.0, 80.5, 81.0, 81.5, 82.0, 82.5, 83.0,
		83.5, 84.0, 84.5, 85.0, 85.5, 86.0, 86.5, 87.0, 87.5, 88.0,
		88.5, 89.0, 89.5, 90.0, 90.5, 91.0, 91.5, 92.0, 104.4, 720.0,
		720.0, 720.0, 720.0, 720.0, 720.0, 720.0, 720.0, 720.0, 720.0, 720.0,
		720.0, 720.0, 720.0, 720.0, 720.0, 720.0, 720.0, 720.0, 720.0, 720.0,
		720.0, 720.0, 720.0, 720.0, 720.0, 720.0, 720.0, 720.0, 720.0, 720.0,
		720.0
	]],
]

var _nos: Array[TextureRect] = []


## Planta os carros no `cenario`, escondidos: quem os mostra é o `refresh()`.
func _init(cenario: Control) -> void:
	for i in CARROS.size():
		var carro: Array = CARROS[i]
		var no := Obra._prop_no_chao(ARTE[carro[0]], carro[1])
		no.name = "CarroDaViela%d" % i
		no.visible = false
		no.material = _mascara(i, no.position)
		Obra._plantar(cenario, no)
		_nos.append(no)


## A máscara do carro `i`, num nó com o canto em `origem`, ou `null` se
## nenhum lote da vila lhe fica à frente (`MASCARA`).
static func _mascara(i: int, origem: Vector2) -> ShaderMaterial:
	for m in MASCARA:
		if int(m[0]) == i:
			var mat := ShaderMaterial.new()
			mat.shader = Obra.VILA_A_FRENTE
			mat.set_shader_parameter("x0", float(m[1]))
			mat.set_shader_parameter("origem", origem)
			mat.set_shader_parameter("teto", PackedFloat32Array(m[2]))
			return mat
	return null


## Os reparos que contam para os carros da fase `n`: os da Fase 1 são os da
## tabela dela; os da Fase 2, os que ela ACRESCENTA — os da Fase 1 continuam
## a abrir nela (`FASES`), e não podem pôr na rua os carros novos.
static func obras_da_fase(n: int) -> Array:
	var fases: Array = GameState.FASES
	var antes: Array = [] if n <= 1 else (fases[0]["reparos"] as Dictionary).keys()
	var out: Array = []
	for id in (fases[n - 1]["reparos"] as Dictionary).keys():
		if not antes.has(id):
			out.append(id)
	return out


## O carro `carro` está estacionado na fase `fase`, com as estruturas
## `prontas`? Desde a fase dele, com `obras` reparos dessa fase prontos.
static func aparece(carro: Array, fase: int, prontas: Array) -> bool:
	var dele: int = carro[2]
	if fase < dele:
		return false
	var n := 0
	for id in obras_da_fase(dele):
		if prontas.has(id):
			n += 1
	return n >= int(carro[3])


func refresh() -> void:
	var fase: int = GameState.numero_da_fase
	var prontas: Array = GameState.estruturas
	for i in CARROS.size():
		_nos[i].visible = aparece(CARROS[i], fase, prontas)


## Os nós dos carros, pela ordem de `CARROS` (o D50 lê-os).
func nos() -> Array[TextureRect]:
	return _nos
