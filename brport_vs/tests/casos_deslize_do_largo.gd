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
#      toque, e o trabalhador também.
#
# ⚠️ FICA DE FORA: que a curva não passe por cima de um píer ou de uma boia.
# A última perna é a faixa da `078` (o §3 prende-a) e o resto é mar aberto
# nos três berços, visto na prancha da `144`; uma régua de pixel do casco
# contra o tabuado custaria mais do que o que prende.
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
	conferir("§2 e com a arte do barco tocado", barco.texture == artes[0])

	# §3 e §4 ── o caminho, passo a passo
	var centros: Array = [comeco]
	var maior_salto := 0.0
	var esmaece := 0
	var no_tabuado := 0
	var opera := 0
	var giro_min := lanca.rotation
	var giro_max := lanca.rotation
	var passos := 0
	while doca.deslizando() and passos < int(3.0 / PASSO):
		_andar(antes, PASSO)
		passos += 1
		var c := _centro(barco)
		maior_salto = maxf(maior_salto, c.distance_to(centros[centros.size() - 1]))
		centros.append(c)
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
		and duracao >= 0.5 and duracao < 3.0)
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
