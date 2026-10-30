extends RefCounted

# ============================================================
# D52 — o barco que desliza do largo ao berço (`docs/decisoes/144`)
#
# Tocar num barco ao largo atraca-o, e até à `144` o casco aparecia no berço
# no quadro do toque: a chegada da `078` arrancava e morria logo, porque o
# trabalhador vai com o barco (`083`) e «quem aloca a meio da chegada encosta
# o barco já». E no mapa sumia o barco do ÚLTIMO lugar, não o tocado — cada
# lugar pintava a posição da fila. Agora o lugar é do barco, e o casco sai de
# lá, faz uma curva de ré até à boca do berço e entra pela faixa da `078`; o
# trabalho espera que encoste.
#
# AS PERGUNTAS, e de onde vem o esperado de cada uma:
#
#   §1 O LUGAR É DO BARCO: com três cascos diferentes ao largo, tocar no
#      PRIMEIRO cartão esvazia o lugar dele e deixa os outros dois com o
#      casco que tinham. O esperado sai da arte de cada barco da fila
#      (`arte_do_barco`), lida antes do toque — e a pintura por posição dava
#      o lugar 1 ao segundo barco e escondia o 3;
#   §2 O COMEÇO: no primeiro passo o centro do casco está no centro do lugar
#      ao largo que se tocou (lido no nó, antes do toque), e não no berço nem
#      no mar da `078`;
#   §3 O CAMINHO, lido no NÓ a cada passo: nunca salta, nunca esmaece, acaba
#      no berço, e perto dele o casco já está NA faixa do berço (o eixo do
#      `RUMO_DO_MAR`) — a faixa que a `078` provou não cruzar o píer;
#   §4 O TRABALHO ESPERA: enquanto desliza, ninguém no tabuado e a lança a
#      varrer como numa doca vazia; encostado, o trabalhador aparece;
#   §5 O TOQUE A MEIO: o `_concluir_virada()` — o que o «Avançar dia» faz
#      antes de virar — encosta o casco já, e o trabalho arranca;
#   §6 COM O MOVIMENTO REDUZIDO não há deslize: o casco está no berço no
#      toque, e o trabalhador também;
#   §7 NENHUM CASCO PASSA POR CIMA DA ANCORAGEM: no porto completo, os nove
#      caminhos (3 lugares × 3 berços), com o casco de maior e o de menor
#      desenho da frota, píxel a píxel contra o cone e as duas boias, nas duas
#      pontas do balanço delas; e os barcos parados ao largo também não lhes
#      tocam. ⚠️ Com as peças onde estavam até à `144`, 6 dos 9 caminhos lhes
#      passavam por cima, e o casco desenha-se DEPOIS do `Cenario` — por cima
#      até da boia que lhe fica à frente. O Bruno escolheu tirá-las do
#      corredor. Leva um controle: o casco posto em cima de uma boia tem de
#      dar píxeis, senão o zero era de graça (e foi, na primeira sonda: o
#      `PropIso.desenho()` mede a partir do CENTRO do quadro).
#
# ⚠️ FICA DE FORA: que a curva não passe por cima de um píer. A última perna
# é a faixa da `078` (o §3 prende-a), e o resto é mar aberto nos três
# berços, visto na prancha da `144`.
#
# Bloco num arquivo próprio, pela regra do `AGENTS.md` §2.
# ============================================================

const CENA := "res://scenes/Main.tscn"
const SEMENTE := 20261029
const PASSO := 1.0 / 60.0
## O casco começa onde estava ao largo. O primeiro passo é de 1 ms, e nele o
## casco anda menos de 1 px; o lugar ao largo sobe e desce 4 px, e o centro
## lê-se no instante do toque. A chegada da `078` começava a ~100 px do berço
## e a ~300 do lugar.
const COMECO_MAX := 3.0
## O maior salto de um passo de 1/60 s. Medido: ~5 px no arranque, que é onde
## a curva corre mais; um salto do largo ao berço são centenas.
const SALTO_MAX := 20.0
## PERTO DO BERÇO O CASCO ESTÁ NA FAIXA DELE: com o centro a menos de
## `PERTO` px do berço, a maior distância ao EIXO da faixa (a reta do berço
## ao longo do `RUMO_DO_MAR`). Medido (`144`): 3,2 px com a curva, e 18,5 px
## com a reta do lugar ao berço (o mutante `deslize-em-reta`). O corte fica a
## meio. ⚠️ A primeira versão perguntava o COSSENO do último sexto contra a
## faixa, com um comentário a dizer que a reta dava 0,80 — escrito antes de
## medir. Do lugar 1 a reta chega quase alinhada (0,924), passava o corte de
## 0,9, e o mutante sobreviveu: a direção não separa, a distância ao eixo sim.
const PERTO := 50.0
const FORA_DA_FAIXA_MAX := 11.0
## Os passos de ré pela faixa: o casco ENTRA de ré, não vira em cima do
## berço. Medido (`144`): 48 passos com a boca a 1,1 × o `RUMO_DO_MAR`; 1 com
## a boca no próprio berço (o mutante `deslize-sem-faixa`, que sobreviveu a
## todas as outras perguntas do §3). O corte fica a meio.
const RE_MIN := 24

var falhas := 0
var completo := false

var _gs: Node
var _arvore: SceneTree
var _pref: Object


func conferir(nome: String, ok: bool, detalhe: String = "") -> void:
	if ok:
		print("  PASS  D52: %s" % nome)
	else:
		print("  FALHA D52: %s%s" % [nome, ("  — " + detalhe) if detalhe != "" else ""])
		falhas += 1


func rodar(gs: Node, arvore: SceneTree) -> void:
	_gs = gs
	_arvore = arvore
	_pref = load("res://scripts/PreferenciasDeApresentacao.gd").atual()
	var reduzido_antes: bool = _pref.reduzir_movimento
	_pref.definir_reduzir_movimento(false)
	conferir("o caminho correu até ao fim", _o_caminho() == true)
	conferir("o toque a meio correu até ao fim", _o_toque_a_meio() == true)
	_pref.definir_reduzir_movimento(true)
	conferir("o movimento reduzido correu até ao fim", _o_reduzido() == true)
	_pref.definir_reduzir_movimento(reduzido_antes)
	conferir("a ancoragem correu até ao fim", _a_ancoragem() == true)
	_gs.clear_save()
	completo = true


## Partida nova com TRÊS barcos de casco diferente ao largo e o berço 1
## livre, e a cena aberta. As três artes saem dos três portes da pesca, que é
## o que o porto em ruínas recebe; o que o bloco pede confere-se aqui.
func _abrir() -> Control:
	_gs.clear_save()
	_gs._rng.seed = SEMENTE
	_gs.new_game()
	_gs.definir_nomes(_gs.NOME_PORTO_PADRAO, "")
	if _gs.phase == "rival_offer":
		_gs.resolve_rival_offer(true)
	var fila: Array = []
	for k in range(3):
		var b: Dictionary = _gs._make_boat()
		var dados: Dictionary = _gs.CLASSES_DE_NAVIO[String(b["classe"])]
		var vmin: int = int(dados["valor_min"])
		var vmax: int = int(dados["valor_max"])
		@warning_ignore("integer_division")
		b["value"] = vmin + (vmax - vmin) * (2 * k + 1) / 6
		fila.append(b)
	_gs.fila = fila
	var tela: Control = load(CENA).instantiate()
	_arvore.root.add_child(tela)
	return tela


func _fechar(tela: Control) -> void:
	_arvore.root.remove_child(tela)
	tela.free()


func _arte(b: Dictionary) -> Texture2D:
	return load("res://scripts/Dock.gd").arte_do_barco(String(b["classe"]),
		String(b["motivo"]), int(b["value"]))


func _lugar(tela: Control, k: int) -> TextureRect:
	return tela.get_node("MapaWrap/Cenario/BarcoEspera%d" % (k + 1)) as TextureRect


func _tocar_o_primeiro(tela: Control) -> void:
	var toque := InputEventMouseButton.new()
	toque.button_index = MOUSE_BUTTON_LEFT
	toque.pressed = false
	tela.get_node("Fila").get_child(0)._gui_input(toque)


func _tweens() -> Dictionary:
	var r := {}
	for tw in _arvore.get_processed_tweens():
		r[tw] = true
	return r


func _andar(antes: Dictionary, segundos: float) -> void:
	for tw in _arvore.get_processed_tweens():
		if not antes.has(tw) and (tw as Tween).is_valid():
			(tw as Tween).custom_step(segundos)


func _centro(no: Control) -> Vector2:
	return no.get_global_rect().get_center()


## O rumo que o nó do barco MOSTRA (`Dock.RUMO_*`), pela textura e pelo
## espelho; −1 se a arte não for a do casco `mar` nem a dele virada ao cais.
func _rumo_visto(barco: TextureRect, mar: Texture2D, cais: Texture2D) -> int:
	if barco.texture == mar:
		return 1 if barco.flip_h else 0
	if barco.texture == cais:
		return 3 if barco.flip_h else 2
	return -1


# §1 a §4 ───────────────────────────────────────────────────────────────────
func _o_caminho() -> bool:
	var tela := _abrir()
	var artes: Array = []
	for b in _gs.fila:
		artes.append(_arte(b))
	conferir("os três barcos ao largo têm cascos diferentes (o estado do bloco)",
		artes[0] != artes[1] and artes[1] != artes[2] and artes[0] != artes[2])
	var no_lugar := 0
	for k in range(3):
		if _lugar(tela, k).visible and _lugar(tela, k).texture == artes[k]:
			no_lugar += 1
	conferir("ao abrir, cada lugar ao largo mostra o barco da fila (%d de 3)" % no_lugar,
		no_lugar == 3)
	var doca = tela.get_node("MapaWrap/Docas").get_child(0)
	var barco := doca.get_node("Barco") as TextureRect
	var trabalhador := doca.get_node("Trabalhador") as TextureRect
	var lanca := doca.get_node("Lanca") as TextureRect
	var de_onde := _centro(_lugar(tela, 0))
	var antes := _tweens()
	_tocar_o_primeiro(tela)
	conferir("o toque atracou o primeiro barco no berço 1",
		_gs.docks[0]["boat"] != null and _gs.fila.size() == 2)

	# §1 ── o lugar é do barco
	conferir("§1 o lugar do barco tocado esvazia", not _lugar(tela, 0).visible)
	var ficaram := 0
	for k in [1, 2]:
		if _lugar(tela, k).visible and _lugar(tela, k).texture == artes[k]:
			ficaram += 1
	conferir("§1 os outros dois ficam no lugar deles, com o casco que tinham (%d de 2)"
		% ficaram, ficaram == 2, "texturas %s, visíveis %s" % [
			[_lugar(tela, 1).texture, _lugar(tela, 2).texture],
			[_lugar(tela, 1).visible, _lugar(tela, 2).visible]])

	# §2 ── o começo
	_andar(antes, 0.001)
	var comeco := _centro(barco)
	conferir("§2 o casco começa no lugar ao largo que se tocou (%.1f px)"
		% comeco.distance_to(de_onde), comeco.distance_to(de_onde) <= COMECO_MAX,
		"começa em %s, o lugar estava em %s, o berço em %s" % [comeco, de_onde,
			doca.centro_do_barco()])
	var k_doca: Dictionary = (load("res://scripts/Dock.gd") as Script).get_script_constant_map()
	var direcoes: Array = k_doca["DIRECAO_DO_RUMO"]
	var cais: Texture2D = k_doca["CASCOS_AO_CAIS"][(artes[0] as Texture2D).resource_path]
	conferir("§2 e com a arte do barco tocado",
		_rumo_visto(barco, artes[0], cais) >= 0)

	# §3 e §4 ── o caminho, passo a passo
	var centros: Array = [comeco]
	var maior_salto := 0.0
	var esmaece := 0
	var no_tabuado := 0
	var opera := 0
	var giro_min := lanca.rotation
	var giro_max := lanca.rotation
	var passos := 0
	# A ARTE DE CADA PASSO, contra o andar desse passo: o rumo que ela mostra
	# e para onde o casco se moveu, na tela.
	var faixa: float = (k_doca["RUMO_DO_MAR"] as Vector2).length() * float(k_doca["DESLIZE_BOCA"])
	var rumo_antes := _rumo_visto(barco, artes[0], cais)
	var desconhecida := 0
	var de_proa := 0
	var de_lado := 0
	var re_fora := 0
	var re_na_faixa := 0
	var viragens := 0
	var meias_voltas := 0
	var vira_parado := 0
	var vira_depressa := 0
	var em_mistura := 0
	var mistura_fora := 0
	var mistura_inteira := 0
	var mistura_fora_da_viragem := 0
	# Quantos passos de 90° a viragem deste caminho tem, pela mesma conta do
	# jogo (a duração menos os dois trechos, em passos).
	var viragens_previstas: int = roundi((float(doca.duracao_do_deslize(
		doca.get_global_transform().affine_inverse() * de_onde - barco.size * 0.5,
		doca._barco_base)) - float(k_doca["DESLIZE_PROA_SEG"])
		- float(k_doca["DESLIZE_RE_SEG"])) / float(k_doca["DESLIZE_VIRA_SEG"]))
	while doca.deslizando() and passos < int(4.0 / PASSO):
		_andar(antes, PASSO)
		passos += 1
		var c := _centro(barco)
		var anda: Vector2 = c - centros[centros.size() - 1]
		maior_salto = maxf(maior_salto, anda.length())
		centros.append(c)
		var rumo := _rumo_visto(barco, artes[0], cais)
		var vira: TextureRect = doca._barco_vira
		var t_agora: float = passos * PASSO
		var virando: bool = doca.deslizando() and t_agora > float(k_doca["DESLIZE_PROA_SEG"]) \
			and t_agora < float(k_doca["DESLIZE_PROA_SEG"]) \
				+ float(k_doca["DESLIZE_VIRA_SEG"]) * viragens_previstas
		if rumo < 0:
			desconhecida += 1
		elif doca.deslizando():
			if rumo != rumo_antes:
				viragens += 1
				if (rumo - rumo_antes + 4) % 4 == 2:
					meias_voltas += 1
			if virando:
				if anda.length() < 0.15:
					vira_parado += 1
				elif anda.length() > 1.5:
					vira_depressa += 1
				if vira.visible:
					var chega := _rumo_visto(vira, artes[0], cais)
					if chega < 0 or (chega - rumo + 4) % 4 == 2 or chega == rumo:
						mistura_fora += 1
					elif vira.modulate.a > 0.0 and vira.modulate.a < 1.0:
						em_mistura += 1
					else:
						mistura_inteira += 1
			elif vira.visible:
				mistura_fora_da_viragem += 1
			if not virando and anda.length() > 0.3:
				var cosseno: float = anda.normalized().dot((direcoes[rumo] as Vector2).normalized())
				if cosseno >= 0.7:
					de_proa += 1
				elif cosseno <= -0.9:
					if c.distance_to(doca.centro_do_barco()) > faixa + 4.0:
						re_fora += 1
					else:
						re_na_faixa += 1
				else:
					de_lado += 1
		rumo_antes = rumo
		if barco.modulate.a < 0.999:
			esmaece += 1
		if doca.deslizando():
			if trabalhador.visible:
				no_tabuado += 1
			if doca._guindaste_opera():
				opera += 1
			giro_min = minf(giro_min, lanca.rotation)
			giro_max = maxf(giro_max, lanca.rotation)
	var duracao: float = passos * PASSO
	conferir("§3 o deslize acaba (%.2f s)" % duracao, not doca.deslizando()
		and duracao >= 2.0 and duracao < 3.2)
	conferir("§3 a arte é sempre a do barco tocado, num dos quatro rumos (%d passos fora)"
		% desconhecida, desconhecida == 0)
	conferir("§3 o casco navega de proa do largo à boca do berço (%d passos)" % de_proa,
		de_proa >= 30)
	conferir("§3 nunca anda de lado (%d passos)" % de_lado, de_lado == 0)
	conferir("§3 só anda de ré na faixa do berço (%d passos fora dela)" % re_fora, re_fora == 0)
	conferir("§3 entra de ré pela faixa (%d passos)" % re_na_faixa, re_na_faixa >= RE_MIN)
	conferir("§3 vira 90° de cada vez a deslizar devagar (%d viragens, %d meias-voltas, %d passos parado, %d depressa)"
		% [viragens, meias_voltas, vira_parado, vira_depressa],
		viragens >= 1 and meias_voltas == 0 and vira_parado == 0 and vira_depressa == 0)
	# 0,1 s de troca por passo são 6 passos de 1/60 s, menos as duas pontas.
	conferir("§3 na viragem a arte que chega aparece por cima da que sai, só no fim de cada passo (%d passos a misturar, %d fora de 90°, %d inteiros, %d fora da viragem)"
		% [em_mistura, mistura_fora, mistura_inteira, mistura_fora_da_viragem],
		em_mistura >= 4 * viragens_previstas and em_mistura <= 6 * viragens_previstas
			and mistura_fora == 0 and mistura_fora_da_viragem == 0)
	conferir("§3 nenhum passo salta (maior %.1f px)" % maior_salto, maior_salto <= SALTO_MAX)
	conferir("§3 o casco não esmaece no caminho (%d passos)" % esmaece, esmaece == 0)
	conferir("§3 no fim o casco está no berço",
		_centro(barco).distance_to(doca.centro_do_barco()) < 0.5 and not doca.em_troca(),
		"%s contra %s" % [_centro(barco), doca.centro_do_barco()])
	var eixo: Vector2 = (load("res://scripts/Dock.gd").RUMO_DO_MAR as Vector2).normalized()
	var berco: Vector2 = doca.centro_do_barco()
	var fora := 0.0
	var perto := 0
	for c in centros:
		var rel: Vector2 = c - berco
		if rel.length() <= PERTO:
			perto += 1
			fora = maxf(fora, absf(rel.cross(eixo)))
	conferir("§3 perto do berço o casco está na faixa dele (%.1f px fora do eixo, em %d passos)"
		% [fora, perto], perto >= 5 and fora <= FORA_DA_FAIXA_MAX,
		"o corte é %.1f px" % FORA_DA_FAIXA_MAX)
	conferir("§4 ninguém no tabuado enquanto o casco desliza (%d passos)" % no_tabuado,
		no_tabuado == 0)
	conferir("§4 o guindaste não opera enquanto desliza (%d passos)" % opera, opera == 0)
	conferir("§4 a lança varre como numa doca vazia (%.3f rad)" % (giro_max - giro_min),
		giro_max - giro_min > 0.01)
	conferir("§4 encostado, o trabalhador aparece", trabalhador.visible)
	_fechar(tela)
	return true


# §5 ─────────────────────────────────────────────────────────────────────────
func _o_toque_a_meio() -> bool:
	var tela := _abrir()
	var doca = tela.get_node("MapaWrap/Docas").get_child(0)
	var barco := doca.get_node("Barco") as TextureRect
	var antes := _tweens()
	_tocar_o_primeiro(tela)
	_andar(antes, 0.4)
	conferir("§5 a 0,4 s o casco ainda desliza, longe do berço",
		doca.deslizando() and _centro(barco).distance_to(doca.centro_do_barco()) > 10.0)
	var main = tela
	main._concluir_virada()
	conferir("§5 concluída a virada, o casco está no berço e parado",
		not doca.deslizando() and not doca.em_troca()
			and _centro(barco).distance_to(doca.centro_do_barco()) < 0.5)
	conferir("§5 e o trabalho arrancou",
		(doca.get_node("Trabalhador") as TextureRect).visible)
	_fechar(tela)
	return true


# §6 ─────────────────────────────────────────────────────────────────────────
func _o_reduzido() -> bool:
	var tela := _abrir()
	var doca = tela.get_node("MapaWrap/Docas").get_child(0)
	var barco := doca.get_node("Barco") as TextureRect
	_tocar_o_primeiro(tela)
	conferir("§6 com o movimento reduzido o casco está no berço no toque",
		not doca.deslizando() and not doca.em_troca() and barco.texture != null
			and _centro(barco).distance_to(doca.centro_do_barco()) < 0.5)
	conferir("§6 e o trabalhador também, com o ciclo do guindaste a correr",
		(doca.get_node("Trabalhador") as TextureRect).visible
			and doca._tw_trabalho != null and doca._tw_trabalho.is_running())
	_fechar(tela)
	return true


# §7 ─────────────────────────────────────────────────────────────────────────
const MEIO_QUADRO := Vector2(256, 256)
## OS TRÊS CAMINHOS QUE PASSAM POR CIMA DO BARCO PARADO NO LUGAR 1, aceites
## pelo Bruno na `144` («aceitar agora, fundeadouro depois»): o lugar 1 fica
## no meio dos caminhos dos outros dois, e numa procura de 749 disposições
## dos três lugares nenhuma deixou os 9 limpos e de proa. A lista é FECHADA
## para os dois lados: um cruzamento novo reprova, e o que o item do
## fundeadouro (§7 do plano) resolver também — e tira-se daqui.
const CRUZAMENTOS_ACEITES := ["lugar 2 -> berço 1", "lugar 3 -> berço 2", "lugar 3 -> berço 3"]
## Quanto a boia sobe no balanço dela (`Main._animar_boias()`, `base.y − 3`).
const BOIA_SOBE := 3.0


func _mascara(tex: Texture2D) -> Dictionary:
	var P: Script = load("res://scripts/PropIso.gd")
	return {"img": P.imagem(tex), "k": P.escala(tex), "r": P.desenho(tex)}


var _mascaras_no_rumo := {}


## A máscara do casco `mar` a apontar para `rumo`, com a arte e o espelho que
## o jogo escolhe (`Dock.arte_no_rumo()`). Espelhada, a imagem vira em `x` e
## o desenho passa para o outro lado do centro do quadro.
func _mascara_no_rumo(DockS: Script, mar: Texture2D, rumo: int) -> Dictionary:
	var chave := "%s|%d" % [mar.resource_path, rumo]
	if _mascaras_no_rumo.has(chave):
		return _mascaras_no_rumo[chave]
	var arte: Array = DockS.arte_no_rumo(mar, rumo)
	var m := _mascara(arte[0])
	if arte[1]:
		var img: Image = (m["img"] as Image).duplicate()
		img.flip_x()
		var r: Rect2 = m["r"]
		m = {"img": img, "k": m["k"],
			"r": Rect2(Vector2(-(r.position.x + r.size.x), r.position.y), r.size)}
	_mascaras_no_rumo[chave] = m
	return m


## Píxeis opacos em comum entre o desenho `a` com o quadro em `oa` e o `b`
## com o quadro em `ob` (cantos dos nós, em coordenada global). O `desenho()`
## é relativo ao CENTRO do quadro, que é a origem do mundo.
func _sobrepostos(a: Dictionary, oa: Vector2, b: Dictionary, ob: Vector2) -> int:
	var ra := Rect2(oa + MEIO_QUADRO + (a["r"] as Rect2).position, (a["r"] as Rect2).size)
	var rb := Rect2(ob + MEIO_QUADRO + (b["r"] as Rect2).position, (b["r"] as Rect2).size)
	var i := ra.intersection(rb)
	var n := 0
	for y in range(floori(i.position.y), ceili(i.end.y)):
		for x in range(floori(i.position.x), ceili(i.end.x)):
			var g := Vector2(x, y)
			if _opaco(a, g - oa) and _opaco(b, g - ob):
				n += 1
	return n


func _opaco(m: Dictionary, local: Vector2) -> bool:
	var img: Image = m["img"]
	var px := Vector2i(int(local.x / float(m["k"])), int(local.y / float(m["k"])))
	if px.x < 0 or px.y < 0 or px.x >= img.get_width() or px.y >= img.get_height():
		return false
	return img.get_pixelv(px).a > 0.5


func _a_ancoragem() -> bool:
	_gs.clear_save()
	_gs._rng.seed = SEMENTE
	_gs.new_game()
	_gs.definir_nomes(_gs.NOME_PORTO_PADRAO, "")
	if _gs.phase == "rival_offer":
		_gs.resolve_rival_offer(true)
	var custo: int = 0
	for e in _gs.ESTRUTURAS:
		custo += int(_gs.ESTRUTURAS[e]["custo"])
	_gs.cash += custo
	for e in _gs.ESTRUTURAS:
		load("res://tools/estado_da_bancada.gd").instalar(_gs, e)
	var tela: Control = load(CENA).instantiate()
	_arvore.root.add_child(tela)
	var docas: Array = tela.get_node("MapaWrap/Docas").get_children()
	conferir("§7 o porto completo tem os três berços", docas.size() == 3
		and _gs.docks.size() == 3)
	var DockS: Script = load("res://scripts/Dock.gd")
	var P: Script = load("res://scripts/PropIso.gd")
	var cascos: Array = []
	var casco_d: Dictionary = DockS.CASCOS
	for classe in casco_d:
		for motivo in casco_d[classe]:
			for tex in casco_d[classe][motivo]:
				cascos.append(tex)
	cascos.sort_custom(func(x, y): return P.desenho(x).get_area() < P.desenho(y).get_area())
	var extremos: Array = [_mascara(cascos[0]), _mascara(cascos[cascos.size() - 1])]
	var pecas: Array = []
	for no in tela.get_node("MapaWrap/Cenario").get_children():
		if String(no.name).begins_with("Ancoragem"):
			pecas.append({"m": _mascara((no as TextureRect).texture),
				"o": (no as Control).get_global_transform().origin, "nome": String(no.name)})
	conferir("§7 a ancoragem tem as três peças (%d)" % pecas.size(), pecas.size() == 3)

	# o controle: o casco maior com o centro do desenho no da primeira peça
	var c: Dictionary = extremos[1]
	var p0: Dictionary = pecas[0]
	var em_cima: Vector2 = p0["o"] + (p0["m"]["r"] as Rect2).get_center() \
		- (c["r"] as Rect2).get_center()
	var controle := _sobrepostos(c, em_cima, p0["m"], p0["o"])
	conferir("§7 controle: o casco posto em cima de %s dá píxeis (%d)" % [p0["nome"], controle],
		controle > 100)

	# Cada caminho anda pela POSE do jogo (`Dock.pose_do_deslize()`), passo a
	# passo, com a arte do rumo de cada passo — de proa ela é a `_ao_cais`, e
	# espelhada desenha-se do outro lado do centro do quadro. Os obstáculos:
	# as três peças da ancoragem, nas duas pontas do balanço, e os barcos
	# PARADOS nos outros dois lugares ao largo (o casco maior, parado de proa
	# para o mar).
	var cruzam: Array = []
	var por_cima_de_barco: Array = []
	var parado_maior: Dictionary = extremos[1]
	for k in range(3):
		var lugar := tela.get_node("MapaWrap/Cenario/BarcoEspera%d" % (k + 1)) as TextureRect
		var centro := lugar.get_global_rect().get_center()
		for p in pecas:
			for m in extremos:
				var parado := _sobrepostos(m, lugar.get_global_transform().origin, p["m"], p["o"]) \
					+ _sobrepostos(m, lugar.get_global_transform().origin, p["m"],
						p["o"] - Vector2(0, BOIA_SOBE))
				if parado > 0:
					cruzam.append("o lugar %d parado toca %s" % [k + 1, p["nome"]])
		for d in range(3):
			var doca = docas[d]
			var barco := doca.get_node("Barco") as TextureRect
			var base: Vector2 = doca._barco_base
			var inicio: Vector2 = doca.get_global_transform().affine_inverse() * centro \
				- barco.size * 0.5
			var dur: float = DockS.duracao_do_deslize(inicio, base)
			var aqui := 0
			var sobre_barco := 0
			var t := 0.0
			while t <= dur + 0.0001:
				var pose: Dictionary = DockS.pose_do_deslize(inicio, base, t)
				var o: Vector2 = doca.get_global_transform() * Vector2(pose["pos"])
				for casco in [cascos[0], cascos[cascos.size() - 1]]:
					var m := _mascara_no_rumo(DockS, casco, int(pose["rumo"]))
					for p in pecas:
						aqui += _sobrepostos(m, o, p["m"], p["o"])
						aqui += _sobrepostos(m, o, p["m"], p["o"] - Vector2(0, BOIA_SOBE))
					for j in range(3):
						if j == k:
							continue
						var outro := tela.get_node("MapaWrap/Cenario/BarcoEspera%d" % (j + 1)) as TextureRect
						sobre_barco += _sobrepostos(m, o, parado_maior,
							outro.get_global_transform().origin)
				t += PASSO
			if aqui > 0:
				cruzam.append("lugar %d -> berço %d (%d px)" % [k + 1, d + 1, aqui])
			if sobre_barco > 0:
				por_cima_de_barco.append("lugar %d -> berço %d (%d px)" % [k + 1, d + 1, sobre_barco])
	conferir("§7 nenhum casco passa por cima da ancoragem nos 9 caminhos (%d casos)"
		% cruzam.size(), cruzam.is_empty(), ", ".join(cruzam))
	var chaves: Array = []
	for caso in por_cima_de_barco:
		chaves.append(String(caso).get_slice(" (", 0))
	chaves.sort()
	conferir("§7 só os cruzamentos aceites passam por cima de outro barco ao largo (%d)"
		% chaves.size(), chaves == CRUZAMENTOS_ACEITES, ", ".join(por_cima_de_barco))
	_fechar(tela)
	return true
