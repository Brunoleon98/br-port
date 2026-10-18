extends RefCounted

# ============================================================
# BR Port VS — A MATA DO MORRO E A RESTINGA DAS PONTAS (`docs/decisoes/127`)
#
# Atrás da vila o chão sobe num morro coberto de mata, e as árvores dele são
# props do Blender — copa redonda, palmeira-juçara, embaúba e ipê florido —
# que BALANÇAM com o vento, como os coqueiros. Foi a escolha do Bruno em
# 17/10, contra árvores paradas desenhadas no mapa, e ela tem um preço que a
# implantação paga: um prop pinta-se por cima de tudo o que o mapa desenhou,
# a vila incluída, e por isso nenhuma árvore do morro desce, na tela, abaixo
# do contorno da vila (`horizonte_da_vila` no gerador; o D47 confere-o nos
# pixels do PNG).
#
# A mesma lista leva a RESTINGA das duas pontas — aroeira, guriri e moitas
# entre a rua e a duna. Ali nada da vila fica à frente, e a pergunta é outra:
# o pé fora da areia (a crista à frente, `cristas` na tabela).
#
# As árvores nascem aqui, e não no `Main.tscn`, porque entram INTERCALADAS
# entre os irmãos do `Cenario` pela profundidade — a D3 exige a ordem, e o
# trânsito dos camiões já ordena pela mesma régua (`position.y`), de modo que
# um camião que passe continua a cair no sítio certo entre elas.
#
# ⚠️ NÃO É UM `class_name`, pela regra do `TrafegoDeCamioes` e da
# `ObraNoMapa`: o `Main` carrega-o por `preload`.
# ============================================================

const TEXTURAS := {
	"arvore_copa_m": preload("res://art/props/arvore_copa_m.png"),
	"arvore_copa_p": preload("res://art/props/arvore_copa_p.png"),
	"arvore_jucara_a": preload("res://art/props/arvore_jucara_a.png"),
	"arvore_jucara_b": preload("res://art/props/arvore_jucara_b.png"),
	"arvore_embauba_a": preload("res://art/props/arvore_embauba_a.png"),
	"arvore_embauba_b": preload("res://art/props/arvore_embauba_b.png"),
	"arvore_ipe_amarelo": preload("res://art/props/arvore_ipe_amarelo.png"),
	"arvore_ipe_rosa": preload("res://art/props/arvore_ipe_rosa.png"),
	"arvore_moita_a": preload("res://art/props/arvore_moita_a.png"),
	"arvore_moita_b": preload("res://art/props/arvore_moita_b.png"),
	"arvore_copa_m2": preload("res://art/props/arvore_copa_m2.png"),
	"arvore_copa_p2": preload("res://art/props/arvore_copa_p2.png"),
	"arvore_mata_a": preload("res://art/props/arvore_mata_a.png"),
	"arvore_mata_b": preload("res://art/props/arvore_mata_b.png"),
	"arvore_mata_c": preload("res://art/props/arvore_mata_c.png"),
	"arvore_mata_d": preload("res://art/props/arvore_mata_d.png"),
	"arvore_copa_larga": preload("res://art/props/arvore_copa_larga.png"),
	"arvore_copa_alta": preload("res://art/props/arvore_copa_alta.png"),
	"arvore_arvoreta_a": preload("res://art/props/arvore_arvoreta_a.png"),
	"arvore_arvoreta_b": preload("res://art/props/arvore_arvoreta_b.png"),
	"arvore_mangueira": preload("res://art/props/arvore_mangueira.png"),
	"arvore_aroeira_a": preload("res://art/props/arvore_aroeira_a.png"),
	"arvore_aroeira_b": preload("res://art/props/arvore_aroeira_b.png"),
	"arvore_guriri_a": preload("res://art/props/arvore_guriri_a.png"),
	"arvore_guriri_b": preload("res://art/props/arvore_guriri_b.png"),
}

# [variante, x, y] de TELA do PÉ de cada árvore, pela ordem de profundidade:
# a lista `mata` da tabela de âncoras, copiada porque o JSON não vai no
# pacote exportado (a razão da `ObraNoMapa`). O D47 confere a cópia contra a
# tabela, número a número; `gerar_mapa_iso.py --lista-da-mata` imprime-a.
const ARVORES: Array = [
	["arvore_mata_a", 42.0, 22.0],
	["arvore_embauba_a", 33.2, 26.0],
	["arvore_copa_alta", 55.3, 39.0],
	["arvore_arvoreta_a", 144.2, 59.4],
	["arvore_jucara_a", 24.8, 21.7],
	["arvore_moita_b", 46.4, 36.8],
	["arvore_moita_b", 37.7, 37.7],
	["arvore_ipe_rosa", 18.1, 26.2],
	["arvore_moita_b", 40.8, 41.3],
	["arvore_moita_b", 28.3, 39.8],
	["arvore_ipe_amarelo", 4.2, 27.9],
	["arvore_moita_b", 20.5, 41.8],
	["arvore_copa_larga", -6.3, 35.5],
	["arvore_moita_b", 7.9, 50.0],
	["arvore_copa_alta", 2.9, 53.5],
	["arvore_arvoreta_a", 76.0, 88.2],
	["arvore_arvoreta_a", 87.6, 90.0],
	["arvore_copa_m", -8.5, 51.0],
	["arvore_arvoreta_a", 77.5, 93.2],
	["arvore_moita_b", 70.3, 95.1],
	["arvore_moita_b", 6.9, 69.4],
	["arvore_arvoreta_a", 74.3, 99.0],
	["arvore_copa_alta", 5.2, 73.5],
	["arvore_moita_b", 61.7, 99.5],
	["arvore_mata_a", -9.9, 64.7],
	["arvore_moita_b", -0.5, 75.4],
	["arvore_moita_b", 60.4, 103.2],
	["arvore_arvoreta_b", 68.6, 103.4],
	["arvore_moita_b", 14.6, 87.1],
	["arvore_copa_alta", 2.6, 82.0],
	["arvore_jucara_a", -8.6, 75.2],
	["arvore_ipe_rosa", -4.7, 85.6],
	["arvore_copa_alta", 7.8, 96.5],
	["arvore_moita_b", -3.2, 90.2],
	["arvore_moita_b", -1.2, 94.3],
	["arvore_embauba_a", -4.8, 93.9],
	["arvore_moita_b", 20.0, 109.5],
	["arvore_mata_d", 4.7, 102.6],
	["arvore_moita_b", 29.2, 115.5],
	["arvore_moita_b", 11.9, 109.6],
	["arvore_moita_b", 1.0, 104.2],
	["arvore_mata_a", -9.2, 100.5],
	["arvore_moita_b", 15.5, 115.7],
	["arvore_copa_alta", 6.1, 115.7],
	["arvore_moita_b", 14.4, 121.8],
	["arvore_mata_b", -8.2, 116.9],
	["arvore_moita_b", -5.4, 129.0],
	["arvore_mata_d", -8.5, 283.1],
	["arvore_arvoreta_b", 2.9, 285.6],
	["arvore_arvoreta_b", -4.6, 287.8],
	["arvore_arvoreta_b", 10.6, 289.8],
	["arvore_arvoreta_b", 0.1, 292.1],
	["arvore_arvoreta_b", -9.4, 295.1],
	["arvore_arvoreta_b", -2.8, 297.8],
	["arvore_moita_b", -9.2, 300.5],
	["arvore_aroeira_b", 408.9, 79.3],
	["arvore_guriri_a", 512.0, 80.6],
	["arvore_guriri_b", 460.5, 105.2],
	["arvore_guriri_a", 436.2, 116.7],
	["arvore_guriri_a", 409.6, 124.5],
	["arvore_guriri_b", 101.3, 481.0],
	["arvore_guriri_a", 156.0, 498.2],
	["arvore_aroeira_b", 133.5, 500.5],
	["arvore_aroeira_a", 7.1, 540.5],
	["arvore_moita_a", 24.0, 634.7],
	["arvore_aroeira_a", 0.6, 649.7],
]

const MEIO_QUADRO := 256.0

# O balanço é o dos coqueiros (rajada, não pêndulo — `Main._animar_coqueiros`),
# mais fraco: a árvore inteira gira no PÉ, e a copa de uma árvore de 60 px
# anda o dobro do que andaria a copa do coqueiro girada no topo do tronco.
const AMPLITUDE := 0.022

var _cenario: Control
var _nos: Array[TextureRect] = []
var _rajadas: Array[Tween] = []


func _init(cenario: Control) -> void:
	_cenario = cenario
	for i in ARVORES.size():
		var a: Array = ARVORES[i]
		var no := TextureRect.new()
		no.name = "Arvore%02d" % i
		no.texture = TEXTURAS[a[0]]
		no.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		no.mouse_filter = Control.MOUSE_FILTER_IGNORE
		no.position = Vector2(float(a[1]) - MEIO_QUADRO, float(a[2]) - MEIO_QUADRO)
		no.size = Vector2(MEIO_QUADRO * 2.0, MEIO_QUADRO * 2.0)
		no.pivot_offset = Vector2(MEIO_QUADRO, MEIO_QUADRO)
		_cenario.add_child(no)
		_cenario.move_child(no, _indice_na_profundidade(no))
		_nos.append(no)


## As árvores plantadas, pela ordem de `ARVORES`.
func nos() -> Array[TextureRect]:
	return _nos


## A rajada de cada árvore, pela mesma ordem — o D47 anda-as com
## `custom_step()` sem mexer nas outras animações do jogo.
func rajadas() -> Array[Tween]:
	return _rajadas


## O índice que a profundidade pede: quantos irmãos estão ACIMA na tela. É a
## régua do `TrafegoDeCamioes._ordenar_por_profundidade` e a da D3.
func _indice_na_profundidade(no: Control) -> int:
	var indice := 0
	for outro in _cenario.get_children():
		if outro == no:
			continue
		if outro is Control and (outro as Control).position.y < no.position.y:
			indice += 1
	return indice


## A rajada, árvore a árvore, com tempo e fase que saem do índice — nunca do
## acaso: a captura tem de sair igual a cada corrida.
func animar() -> void:
	for i in _nos.size():
		var no := _nos[i]
		var dur := 2.4 + 0.37 * float(i % 5)
		var amplitude := AMPLITUDE * (1.0 if i % 2 == 0 else -1.0)
		var tw := no.create_tween().set_loops()
		_rajadas.append(tw)
		tw.tween_interval(0.23 * float(i % 7))
		tw.tween_property(no, "rotation", amplitude, dur * 0.35) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tw.tween_property(no, "rotation", -amplitude * 0.55, dur * 0.8) \
			.set_trans(Tween.TRANS_SINE)
		tw.tween_property(no, "rotation", amplitude * 0.22, dur * 0.5) \
			.set_trans(Tween.TRANS_SINE)
		tw.tween_property(no, "rotation", 0.0, dur * 0.45) \
			.set_trans(Tween.TRANS_SINE)
		tw.tween_interval(0.9 + 0.31 * float(i % 4))
