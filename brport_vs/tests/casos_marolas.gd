extends RefCounted

# ============================================================
# D51 — as marolas que rolam para a costa, e a espuma que lava
# (`docs/decisoes/142`)
#
# Até à `142` as marolas eram desenho do mapa, paradas. Hoje são duas camadas
# (`porto_mapa_marolas0/1.svg`) que o `Main.gd` faz rolar `MAROLA_ROLA` para o
# cais em contrafase: cada uma acende num sexto do ciclo, fica acesa sozinha
# e apaga-se noutro sexto. O gerador só aceita uma marola se cada ponto dela,
# nas DUAS pontas do caminho, cair em água à vista — a camada vai por cima de
# tudo o que o mapa desenha, e no mapa a terra tapava as que lá caíam.
#
# AS PERGUNTAS, e de onde vem o esperado de cada uma:
#
#   §1 a cópia do caminho no `Main.gd` é a da tabela de âncoras, que o
#      gerador escreve — o pacote não leva a tabela;
#   §2 debaixo de cada pixel de marola, nas duas pontas e no meio do caminho
#      que a TABELA publica, os dois mapas são água — lido nos PNG, que é o
#      que se vê, e não na geometria que o gerador já usou para decidir;
#   §3 as duas camadas estão na cena, com a arte delas, entre o mapa e o
#      cenário, do tamanho do mapa e sem apanhar toque;
#   §4 um ciclo inteiro, lido no NÓ a cada passo: cada camada acende e
#      apaga, só anda no caminho provado e rumo à costa enquanto se vê, as
#      duas em contrafase e com a troca curta; e as duas camadas de espuma
#      variam de facto;
#   §5 com o movimento reduzido, a camada 0 fica acesa no sítio e a 1
#      apagada — o mar de antes da `142`, parado.
#
# ⚠️ A ESPUMA ENTRA AQUI PORQUE NENHUMA SUÍTE VIA QUE ELA NÃO LAVAVA. Desde
# que nasceu, o laço dela punha `set_parallel(true)` antes de cada passo, e
# no Godot 4 isso junta o passo seguinte ao corrente: a `Espuma0` ficou em
# 0,45 e no sítio, e a contrafase do comentário nunca existiu. As suítes
# passavam, porque nenhuma lia o nó ao longo do tempo. O defeito está no
# catálogo de mutantes com a forma dele.
# ============================================================

const CENA := "res://scenes/Main.tscn"
const SEMENTE := 20261025
## Medido (`142`), nos PNG do ThorVG: debaixo de cada pixel de marola, nas
## três posições e nos dois mapas, o azul da água (B − média de R e G) nunca
## desce de +57; com a camada empurrada 2 u para terra (o mutante) desce a
## +6, no concreto do cais. O corte fica a meio.
const AZUL_MIN := 32.0
## O alfa a partir do qual um pixel da camada conta como marola. A crista
## mais fraca, ao largo, sai a ~0,04 de opacidade por polígono, mas o
## antisserrilhado das bordas é o que se quer de fora.
const ALFA_MIN := 0.1
## Uma camada tem ~6.000 pixels de marola a 1080 (medido); menos de metade
## quer dizer que a régua não leu o que devia, e não que a água está limpa.
const LIDAS_MIN := 3000
## O passo da varredura do ciclo, menor do que o trecho mais curto (a troca,
## 1,17 s): um trecho inteiro dentro de um passo nunca seria lido.
const PASSO := 1.0 / 30.0
## A fração do ciclo em que as DUAS camadas estão a meio do brilho (entre
## 0,05 e 0,95). Pela conta, ~0,24 com a troca curta e ~0,71 com o brilho em
## seno do ciclo inteiro, que foi a primeira passagem; o corte fica a meio.
const CRUZADA_MAX := 0.48
## A espuma varia 0,275 de brilho e anda 1,33 px (`142`); parada, 0 e 0. Os
## cortes ficam a meio.
const ESPUMA_VARIA_MIN := 0.14
const ESPUMA_ANDA_MIN := 0.67

var falhas := 0
var completo := false


func conferir(nome: String, ok: bool, detalhe: String = "") -> void:
	if ok:
		print("  PASS  D51: %s" % nome)
	else:
		print("  FALHA D51: %s%s" % [nome, ("  — " + detalhe) if detalhe != "" else ""])
		falhas += 1


func rodar(gs: Node, arvore: SceneTree, ancoras: Dictionary, terra, patio,
		camadas: Array) -> void:
	var caminho := _caminho(ancoras)
	_a_copia(ancoras)
	_em_agua(caminho, terra, patio, camadas)
	var pref := PreferenciasDeApresentacao.atual()
	var antes := pref.reduzir_movimento
	# Em memória, e nunca no disco: o `guardar()` do `movimento_de_fundo` lê
	# a escolha quando a cena nasce, e é isso que se quer.
	pref.reduzir_movimento = false
	gs.clear_save()
	gs._rng.seed = SEMENTE
	gs.new_game()
	var vistos := {}
	for tw in arvore.get_processed_tweens():
		vistos[tw] = true
	var tela: Control = load(CENA).instantiate()
	arvore.root.add_child(tela)
	var novos: Array = []
	for tw in arvore.get_processed_tweens():
		if not vistos.has(tw):
			novos.append(tw)
	_na_cena(tela)
	_o_ciclo(tela, novos, caminho)
	arvore.root.remove_child(tela)
	tela.free()
	pref.reduzir_movimento = true
	tela = load(CENA).instantiate()
	arvore.root.add_child(tela)
	_em_repouso(tela)
	arvore.root.remove_child(tela)
	tela.free()
	pref.reduzir_movimento = antes
	gs.clear_save()
	completo = true


## O caminho inteiro de uma marola na tela, da TABELA: `rola` unidades em
## `+mx`, que é (+meia_larg, +meia_alt) por unidade.
func _caminho(ancoras: Dictionary) -> Vector2:
	var pr: Dictionary = ancoras["projecao"]
	var rola := float(ancoras.get("marolas", {}).get("rola", 0.0))
	return Vector2(float(pr["meia_larg"]), float(pr["meia_alt"])) * rola


# ── §1 ─────────────────────────────────────────────────────────────────────
func _a_copia(ancoras: Dictionary) -> void:
	var tabela := float(ancoras.get("marolas", {}).get("rola", -1.0))
	var copia := float((load("res://scripts/Main.gd") as Script)
		.get_script_constant_map().get("MAROLA_ROLA", -2.0))
	conferir("a tabela publica o caminho das marolas (%.3f u)" % tabela, tabela > 0.0)
	conferir("a cópia do Main.gd é a da tabela (%.3f contra %.3f)" % [copia, tabela],
		absf(copia - tabela) < 0.000001)


# ── §2 ─────────────────────────────────────────────────────────────────────
func _em_agua(caminho: Vector2, terra, patio, camadas: Array) -> void:
	if terra == null or patio == null or camadas.size() != 2 \
			or camadas[0] == null or camadas[1] == null:
		conferir("os dois mapas e as duas camadas abrem", false)
		return
	var mapas := [["terra", _rgba(terra.img), terra], ["pavimentado", _rgba(patio.img), patio]]
	for i in 2:
		var camada = camadas[i]
		var img := _rgba(camada.img)
		var w := img.get_width()
		var dados := img.get_data()
		var lidas := 0
		var fora := 0
		var pior := INF
		var onde := ""
		for y in img.get_height():
			for x in w:
				if dados[(y * w + x) * 4 + 3] < int(ALFA_MIN * 255.0):
					continue
				lidas += 1
				var t: Vector2 = Vector2(x + 0.5, y + 0.5) / float(camada.escala)
				for k in [-0.5, 0.0, 0.5]:
					for m in mapas:
						var q: Vector2i = m[2].pxv(t + caminho * k)
						if not m[2].dentro(q):
							continue
						var c: Color = m[1].get_pixelv(q)
						var azul := (c.b - (c.r + c.g) / 2.0) * 255.0
						if azul < AZUL_MIN:
							fora += 1
						if azul < pior:
							pior = azul
							onde = "pixel %s da camada, %+.1f u do caminho, no %s: %s" \
								% [Vector2i(x, y), k, m[0], c.to_html(false)]
		conferir("a camada %d foi lida (%d pixels de marola)" % [i, lidas], lidas >= LIDAS_MIN)
		conferir("a camada %d só pousa em água em todo o caminho (pior azul %+.1f, o mínimo é %+.1f; %d leituras fora)"
			% [i, pior, AZUL_MIN, fora], fora == 0, onde)


func _rgba(img: Image) -> Image:
	if img.get_format() == Image.FORMAT_RGBA8:
		return img
	var c := img.duplicate() as Image
	c.convert(Image.FORMAT_RGBA8)
	return c


# ── §3 ─────────────────────────────────────────────────────────────────────
func _na_cena(tela: Control) -> void:
	var wrap := tela.get_node("MapaWrap")
	var mapa := wrap.get_node_or_null("Mapa") as TextureRect
	var cenario := wrap.get_node_or_null("Cenario")
	for i in 2:
		var no := wrap.get_node_or_null("Marola%d" % i) as TextureRect
		conferir("a camada Marola%d está no MapaWrap" % i, no != null)
		if no == null or mapa == null or cenario == null:
			continue
		var arte: String = no.texture.resource_path if no.texture != null else ""
		conferir("a Marola%d desenha porto_mapa_marolas%d.svg" % [i, i],
			arte == "res://art/porto_mapa_marolas%d.svg" % i, arte)
		conferir("a Marola%d fica entre o mapa e o cenário (%d, %d, %d)"
			% [i, mapa.get_index(), no.get_index(), cenario.get_index()],
			mapa.get_index() < no.get_index() and no.get_index() < cenario.get_index())
		conferir("a Marola%d tem o tamanho do mapa e a mesma escala" % i,
			no.size == mapa.size and no.expand_mode == mapa.expand_mode)
		conferir("a Marola%d não apanha toque" % i, no.mouse_filter == Control.MOUSE_FILTER_IGNORE)


# ── §4 ─────────────────────────────────────────────────────────────────────
func _o_ciclo(tela: Control, tweens: Array, caminho: Vector2) -> void:
	var wrap := tela.get_node("MapaWrap")
	var base: Vector2 = (wrap.get_node("Mapa") as Control).position
	var nos: Array = []
	for n in ["Marola0", "Marola1", "Espuma0", "Espuma1"]:
		nos.append(wrap.get_node_or_null(n))
	if nos.has(null):
		conferir("as quatro camadas da água existem", false)
		return
	conferir("a cena criou os tweens do fundo (%d)" % tweens.size(), tweens.size() >= 4)
	var ciclo := float((load("res://scripts/Main.gd") as Script)
		.get_script_constant_map().get("MAROLA_CICLO", 7.0))
	var amostras: Array = []
	for n in range(ceili(ciclo * 2.0 / PASSO) + 1):
		var a: Array = []
		for no in nos:
			a.append([(no as Control).position, (no as Control).modulate.a])
		amostras.append(a)
		for tw in tweens:
			if tw.is_valid():
				tw.custom_step(PASSO)
	var c2 := caminho.length_squared()
	for i in 2:
		var alfas: Array = amostras.map(func(a: Array) -> float: return a[i][1])
		conferir("a Marola%d acende e apaga (brilho de %.2f a %.2f)"
			% [i, alfas.min(), alfas.max()], alfas.max() >= 0.99 and alfas.min() <= 0.01)
		var longe := 0.0
		var para_o_mar := 0.0
		var andou := 0.0
		for n in amostras.size():
			var p: Vector2 = amostras[n][i][0]
			var al: float = amostras[n][i][1]
			if al <= 0.01:
				continue
			# A distância ao segmento base ± caminho/2, em px de tela.
			var t: float = clampf((p - base).dot(caminho) / c2, -0.5, 0.5) if c2 > 0.0 else 0.0
			longe = maxf(longe, (p - (base + caminho * t)).length())
			if n > 0 and float(amostras[n - 1][i][1]) > 0.01:
				var d: float = (p - (amostras[n - 1][i][0] as Vector2)).dot(caminho)
				para_o_mar = maxf(para_o_mar, d)
				andou -= minf(d, 0.0)
		conferir("a Marola%d só anda no caminho provado (o mais longe: %.2f px)" % [i, longe],
			longe <= 0.5)
		conferir("a Marola%d só anda para a costa enquanto se vê" % i, para_o_mar <= 0.001,
			"recuou %.3f px² para o mar" % para_o_mar)
		# Em dois ciclos ela percorre o caminho duas vezes, menos as pontas em
		# que o brilho ainda não passou de 0,01; parada, zero.
		var percorrido: float = andou / sqrt(c2) if c2 > 0.0 else 0.0
		conferir("a Marola%d percorre o caminho enquanto se vê (%.1f px em dois ciclos; o caminho tem %.1f)"
			% [i, percorrido, sqrt(c2)], c2 > 0.0 and percorrido >= 0.8 * sqrt(c2))
	var soma_min := INF
	var cruzadas := 0
	for a in amostras:
		var a0: float = a[0][1]
		var a1: float = a[1][1]
		soma_min = minf(soma_min, a0 + a1)
		if a0 > 0.05 and a0 < 0.95 and a1 > 0.05 and a1 < 0.95:
			cruzadas += 1
	conferir("as duas marolas em contrafase: o mar nunca fica sem elas (soma mínima %.2f)"
		% soma_min, soma_min >= 0.9)
	var fracao := float(cruzadas) / float(amostras.size())
	conferir("a troca é curta: as duas a meio do brilho em %.0f%% do ciclo (o máximo é %.0f%%)"
		% [fracao * 100.0, CRUZADA_MAX * 100.0], fracao <= CRUZADA_MAX)
	for j in [2, 3]:
		var al: Array = amostras.map(func(a: Array) -> float: return a[j][1])
		var xs: Array = amostras.map(func(a: Array) -> float: return (a[j][0] as Vector2).x)
		conferir("a Espuma%d lava: o brilho varia %.3f e ela anda %.2f px"
			% [j - 2, al.max() - al.min(), xs.max() - xs.min()],
			al.max() - al.min() >= ESPUMA_VARIA_MIN and xs.max() - xs.min() >= ESPUMA_ANDA_MIN)


# ── §5 ─────────────────────────────────────────────────────────────────────
func _em_repouso(tela: Control) -> void:
	var wrap := tela.get_node("MapaWrap")
	var base: Vector2 = (wrap.get_node("Mapa") as Control).position
	for i in 2:
		var no := wrap.get_node_or_null("Marola%d" % i) as Control
		if no == null:
			conferir("a Marola%d existe com o movimento reduzido" % i, false)
			continue
		var quer: float = 1.0 if i == 0 else 0.0
		conferir("com o movimento reduzido a Marola%d fica no sítio, com brilho %.0f (tem %.2f em %s)"
			% [i, quer, no.modulate.a, no.position],
			no.position == base and is_equal_approx(no.modulate.a, quer))
