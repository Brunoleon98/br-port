extends RefCounted

# ============================================================
# D53 — a peça nova assenta, e o «Avançar dia» afunda (`docs/decisoes/145`)
#
# Medido na `145` antes de escrever uma linha: em cada uma das oito obras do
# catálogo, a virada que a conclui trocava a textura num quadro e nada mais —
# a escala dos nós ficou em 1,000 nos 40 quadros seguintes. O desenho é o da
# `144`: o que a obra levantou cresce até 100% em 0,3 s, a travar, com o pivô
# no chão, e o «Avançar dia» afunda 4% enquanto está premido. O veredito do
# Bruno ao primeiro vídeo pôs o começo a 94% (a 97% quase não se via), a obra
# a esvair-se por baixo da peça, o conteúdo do botão a descer e o «passar por
# cima» do rodapé igual ao repouso.
#
# AS PERGUNTAS, e de onde vem o esperado de cada uma:
#
#   §1 SÓ NA VIRADA QUE CONCLUI: a virada do porto completo, a de uma obra
#      que ainda não acaba e a obra concluída pela bancada (fora do botão)
#      não escalam nó nenhum do mapa;
#   §2 SÓ NA PEÇA QUE CONCLUIU, em CADA estrutura do catálogo: todo nó que
#      assenta mudou de textura ou de visibilidade NESTA virada (ou é a lança
#      de um píer que assenta, que pousa na base desenhada nele); todo píer,
#      armazém, escritório e equipamento de pátio que mudou assenta; e cada
#      estrutura assenta alguma coisa. O esperado sai do que a virada mudou no
#      nó, lido antes e depois do toque — não da lista do jogo;
#   §3 A CURVA, lida no nó a cada passo: começa a 94%, nunca encolhe, nunca
#      passa de 100%, trava (a meio do tempo já fez mais de metade) e acaba
#      em 1 EXATO, no sítio exato, depois de ~0,3 s;
#   §4 O CHÃO PARADO: o centro do quadro de cada peça sem giro fica onde
#      estava, e o eixo da lança, lido no quadro do píer, não se mexe — a
#      lança não descola da base;
#   §5 O TOQUE A MEIO: o `_concluir_virada()` — o que o botão faz antes de
#      virar — põe cada peça inteira e no sítio já;
#   §6 COM O MOVIMENTO REDUZIDO não assenta, e ligá-lo a meio acaba-o;
#   §7 O BOTÃO, premido pelo `push_input` como o jogador: enquanto premido
#      desenha-se 4% menor à volta do centro, com o ícone à mesma distância
#      da borda e o conteúdo 1 px abaixo; solto, inteiro, com a cor do
#      repouso ainda com o rato por cima (o do telefone fica onde o dedo
#      saiu), e o dia vira uma vez só;
#   §8 O RASTO DA OBRA: cada peça que mudou de textura (menos a lança) deixa
#      uma cópia do que mostrava ANTES, no mesmo pai e logo abaixo dela, que
#      começa opaca, só esmaece, e some em 0,25 s; no pátio, o canteiro e os
#      cones que a virada tira também, em 0,1 s (antes de meio assentar), e o
#      CHÃO de antes — o mapa de terra com as camadas da obra — por cima do
#      novo e abaixo das marolas. O esperado sai da foto de antes do toque.
#      Nas viradas do §1, no toque a meio e com o movimento reduzido não há
#      rasto nenhum;
#   §9 O CARTÃO «AO LARGO», premido pelo `push_input`: desenha-se 4% mais
#      estreito à volta do centro, com a altura inteira e o conteúdo 1 px
#      abaixo sem a última linha pisar a borda, e o fundo escurece o passo do
#      botão; ainda não atracou; solto, inteiro, e o barco atracou.
#
# ⚠️ FICA DE FORA: o premido com o texto Maior, em que o rodapé cresce e o
# encolher vertical fica um pouco abaixo dos 4% (a margem é em px).
#
# Bloco num arquivo próprio, pela regra do `AGENTS.md` §2.
# ============================================================

const CENA := "res://scenes/Main.tscn"
const SEMENTE := 20261030
const PASSO := 1.0 / 60.0
## O assentar dura 0,3 s; a guarda anda até 0,6 s.
const PASSOS := 36
const DE := 0.94
## O rasto da obra some em 0,15 s.
const RASTO_SEG := 0.25
## O canteiro e os cones do pátio saem antes, para não se cruzarem com o
## equipamento novo que assenta no mesmo sítio.
const RASTO_DO_CANTEIRO_SEG := 0.1
## O encolher do premido, em fração do botão. A margem é em px, e no
## rodapé padrão (692 × 58) dá 0,960 nos dois eixos.
const PREMIDO := 0.96
const PREMIDO_TOLERA := 0.002

var falhas := 0
var completo := false

var _gs: Node
var _arvore: SceneTree
var _pref: Object
var _bancada: Script


func conferir(nome: String, ok: bool, detalhe: String = "") -> void:
	if ok:
		print("  PASS  D53: %s" % nome)
	else:
		print("  FALHA D53: %s%s" % [nome, ("  — " + detalhe) if detalhe != "" else ""])
		falhas += 1


func rodar(gs: Node, arvore: SceneTree) -> void:
	_gs = gs
	_arvore = arvore
	_bancada = load("res://tools/estado_da_bancada.gd")
	_pref = load("res://scripts/PreferenciasDeApresentacao.gd").atual()
	var reduzido_antes: bool = _pref.reduzir_movimento
	_pref.definir_reduzir_movimento(false)
	conferir("as obras do catálogo correram até ao fim", _as_obras() == true)
	conferir("as viradas sem obra a acabar correram até ao fim", _sem_obra_a_acabar() == true)
	conferir("o toque a meio correu até ao fim", _o_toque_a_meio() == true)
	conferir("o movimento reduzido correu até ao fim", _o_reduzido() == true)
	_pref.definir_reduzir_movimento(false)
	conferir("o botão correu até ao fim", _o_botao() == true)
	conferir("o cartão ao largo correu até ao fim", _o_cartao() == true)
	_pref.definir_reduzir_movimento(reduzido_antes)
	_gs.clear_save()
	completo = true


# ── a montagem ──────────────────────────────────────────────────────────────

func _partida() -> void:
	_gs.clear_save()
	_gs._rng.seed = SEMENTE
	_gs.new_game()
	_gs.definir_nomes(_gs.NOME_PORTO_PADRAO, "")
	if _gs.phase == "rival_offer":
		_gs.resolve_rival_offer(true)


## Os requisitos de `id`, pela cadeia `requer` do catálogo, montados pela
## bancada antes de a cena abrir.
func _requisitos(id: String) -> void:
	var r: String = String(_gs.ESTRUTURAS[id]["requer"])
	if r != "":
		_requisitos(r)
		_bancada.instalar(_gs, r)


## Partida com a obra `id` a acabar no próximo dia (ou a `dias` dias), e a
## cena aberta.
func _abrir_com_obra(id: String, dias: int = 1) -> Control:
	_partida()
	_requisitos(id)
	_gs.cash = 5000000
	_gs.obra_em_andamento = {"id": id, "inicio": _gs.turn - 1, "conclusao": _gs.turn + dias}
	return _abrir_cena()


func _abrir_cena() -> Control:
	var tela: Control = load(CENA).instantiate()
	_arvore.root.add_child(tela)
	# Os contentores arrumam-se no frame seguinte, e esta suíte não deixa
	# passar nenhum: sem a ordem dada à mão, o botão tem o tamanho mínimo e o
	# toque cai fora dele (como no D43).
	(tela.get_node("AcoesTurno") as Container).notification(Container.NOTIFICATION_SORT_CHILDREN)
	(tela.get_node("Fila") as Container).notification(Container.NOTIFICATION_SORT_CHILDREN)
	return tela


func _fechar(tela: Control) -> void:
	_arvore.root.remove_child(tela)
	tela.free()


func _tweens() -> Dictionary:
	var r := {}
	for tw in _arvore.get_processed_tweens():
		r[tw] = true
	return r


func _andar(antes: Dictionary, segundos: float) -> void:
	for tw in _arvore.get_processed_tweens():
		if not antes.has(tw) and (tw as Tween).is_valid():
			(tw as Tween).custom_step(segundos)


## O «Avançar dia» premido e solto pelo `push_input`, no centro dele — o
## caminho do toque no telefone, que o motor entrega como rato. Em coordenada
## da cena (`true`), como o `casos_como_jogar`: a janela do `--headless` não
## tem o tamanho da cena.
func _premir(tela: Control, soltar: bool = true) -> Button:
	var botao := tela.get_node("AcoesTurno/Avancar") as Button
	var onde := botao.get_global_rect().get_center()
	var mexe := InputEventMouseMotion.new()
	mexe.position = onde
	mexe.global_position = onde
	_arvore.root.push_input(mexe, true)
	var ev := InputEventMouseButton.new()
	ev.button_index = MOUSE_BUTTON_LEFT
	ev.position = onde
	ev.global_position = onde
	ev.pressed = true
	_arvore.root.push_input(ev, true)
	if soltar:
		_soltar(botao)
	return botao


func _soltar(botao: Button) -> void:
	var ev := InputEventMouseButton.new()
	ev.button_index = MOUSE_BUTTON_LEFT
	ev.position = botao.get_global_rect().get_center()
	ev.global_position = ev.position
	ev.pressed = false
	_arvore.root.push_input(ev, true)


## Cada `Control` do mapa: `{caminho: [nó, textura, visível, posição]}`.
func _foto(tela: Control) -> Dictionary:
	var mapa := tela.get_node("MapaWrap")
	var out := {}
	var pilha: Array = [mapa]
	while not pilha.is_empty():
		var no: Node = pilha.pop_back()
		if no is Control:
			var tex = (no as TextureRect).texture if no is TextureRect else null
			out[str(mapa.get_path_to(no))] = [no, tex, (no as Control).is_visible_in_tree(),
				(no as Control).position]
		pilha.append_array(no.get_children())
	return out


## Os nós do mapa com escala diferente de 1, agora.
func _escalados(foto: Dictionary) -> Array:
	var r: Array = []
	for k in foto:
		var no: Control = foto[k][0]
		if is_instance_valid(no) and no.scale != Vector2.ONE:
			r.append(k)
	return r


# §1 a §4 ───────────────────────────────────────────────────────────────────
func _as_obras() -> bool:
	var ids: Array = _gs.ESTRUTURAS.keys()
	conferir("o catálogo tem estruturas para percorrer (%d)" % ids.size(), ids.size() >= 2)
	for id in ids:
		_uma_obra(String(id))
	return true


func _uma_obra(id: String) -> void:
	var tela := _abrir_com_obra(id)
	tela._concluir_virada()
	var antes := _foto(tela)
	var tw0 := _tweens()
	var dia: int = _gs.turn
	_premir(tela)
	conferir("%s: o toque virou o dia e concluiu a obra" % id,
		_gs.turn == dia + 1 and _gs.tem_estrutura(id))
	var depois := _foto(tela)

	# §2 ── quem assenta, lido no primeiro passo
	var assentam := _escalados(depois)
	conferir("%s: alguma peça assenta (%d)" % [id, assentam.size()], not assentam.is_empty())
	var mudou := {}
	for k in depois:
		if antes.has(k) and (antes[k][1] != depois[k][1] or antes[k][2] != depois[k][2]):
			mudou[k] = true
	var estranhos: Array = []
	for k in assentam:
		if mudou.has(k):
			continue
		# A lança pousa na base desenhada no píer: assenta com ele.
		if String(k).get_file() == "Lanca" and String(k).get_base_dir() + "/Pier" in assentam:
			continue
		estranhos.append(k)
	conferir("%s: só assenta o que a virada mudou" % id, estranhos.is_empty(),
		"assentam sem mudar: %s" % [estranhos])
	var equipamento: Array = tela.get_script().get_script_constant_map()["EQUIPAMENTO_DE_PATIO"]
	var esquecidos: Array = []
	for k in mudou:
		var nome := String(k).get_file()
		var e_peca: bool = nome == "Pier" or k in ["Cenario/Armazem", "Cenario/Escritorio"] \
			or (String(k).begins_with("Cenario/") and nome in equipamento
				and not antes[k][2] and depois[k][2])
		if e_peca and k not in assentam:
			esquecidos.append(k)
	conferir("%s: toda peça que a virada mudou assenta" % id, esquecidos.is_empty(),
		"mudaram e não assentam: %s" % [esquecidos])

	# §8 ── o rasto da obra, lido no primeiro passo: o que se espera sai da
	# foto de antes do toque — as peças que trocaram de textura (menos a
	# lança) e, no pátio, o canteiro e os cones que a virada tirou.
	var esperados: Array = []
	for k in mudou:
		if k in assentam and String(k).get_file() != "Lanca" and antes[k][1] != depois[k][1]:
			esperados.append(k)
	if id == "patio":
		for k in antes:
			var nome := String(k).get_file()
			var da_obra := nome == "CanteiroDoPatio" or nome.begins_with("ConeDaRua") \
				or nome.begins_with("CavaleteDaRua")
			if da_obra and antes[k][2] and (not depois.has(k) or not is_instance_valid(depois[k][0])
					or not depois[k][2]):
				esperados.append(k)
	var mapa := tela.get_node("MapaWrap")
	var rastos: Array = []
	var chaos: Array = []
	for r in _rastos_na_arvore():
		if r is TextureRect:
			rastos.append(r)
		else:
			chaos.append(r)
	var segundos := {}
	var sem_rasto: Array = []
	var por_cima: Array = []
	var achados := {}
	for k in esperados:
		var pai := mapa.get_node(String(k).get_base_dir()) if String(k).get_base_dir() != "" else mapa
		var achado: TextureRect = null
		for r in rastos:
			if r.get_parent() == pai and r.texture == antes[k][1] and r.position == antes[k][3]:
				achado = r
		if achado == null:
			sem_rasto.append(k)
			continue
		achados[achado] = true
		var nome_k := String(k).get_file()
		segundos[achado] = RASTO_DO_CANTEIRO_SEG if nome_k == "CanteiroDoPatio" \
			or nome_k.begins_with("ConeDaRua") or nome_k.begins_with("CavaleteDaRua") else RASTO_SEG
		var peca = depois[k][0] if depois.has(k) else null
		if is_instance_valid(peca) and (peca as Node).get_parent() == pai \
				and achado.get_index() != (peca as Node).get_index() - 1:
			por_cima.append("%s (rasto %d, peça %d)" % [k, achado.get_index(), (peca as Node).get_index()])
	conferir("%s §8: a obra deixa rasto (%d)" % [id, esperados.size()], not esperados.is_empty())
	conferir("%s §8: cada peça que mudou deixa o rasto do que mostrava antes" % id,
		sem_rasto.is_empty(), "sem rasto: %s" % [sem_rasto])
	conferir("%s §8: e mais nenhum rasto (%d de %d)" % [id, rastos.size(), esperados.size()],
		rastos.size() == achados.size())
	conferir("%s §8: o rasto fica logo abaixo da peça" % id, por_cima.is_empty(), str(por_cima))
	# O chão de antes, só no pátio: o mapa de terra por cima do novo, logo
	# acima das camadas do chão e abaixo das marolas.
	if id == "patio":
		var chao: Control = chaos[0] if chaos.size() == 1 else null
		var mapa_velho: TextureRect = null
		if chao != null and chao.get_child_count() > 0:
			mapa_velho = chao.get_child(0) as TextureRect
		conferir("patio §8: o chão de antes deixa rasto, com o mapa de terra",
			chao != null and mapa_velho != null and mapa_velho.texture == antes["Mapa"][1]
				and (depois["Mapa"][0] as TextureRect).texture != antes["Mapa"][1],
			"%d rasto(s) de chão" % chaos.size())
		if chao != null:
			conferir("patio §8: o rasto do chão fica acima do chão e abaixo das marolas",
				chao.get_parent() == mapa
					and chao.get_index() == mapa.get_node("RuaRecapeada").get_index() + 1
					and chao.get_index() < mapa.get_node("Marola0").get_index(),
				"índice %d" % chao.get_index())
			segundos[chao] = RASTO_SEG
			rastos.append(chao)
	else:
		conferir("%s §8: e o chão não deixa rasto" % id, chaos.is_empty())
	# Um rasto que não casou com nada já reprovou acima; aqui só precisa de um
	# tempo para a conta não rebentar.
	for r in rastos:
		if not segundos.has(r):
			segundos[r] = RASTO_SEG
	var opaco := true
	for r in rastos:
		opaco = opaco and is_equal_approx(r.modulate.a, 1.0)
	conferir("%s §8: o rasto começa opaco" % id, opaco)
	var alfas := {}
	for r in rastos:
		alfas[r] = [r.modulate.a]

	# §3 e §4 ── a curva e o chão, passo a passo
	var repouso := {}
	var centro := {}
	var eixo := {}
	for k in assentam:
		var no: Control = depois[k][0]
		repouso[k] = antes[k][3]
		centro[k] = antes[k][3] + no.size * 0.5
		if String(k).get_file() == "Lanca":
			eixo[k] = (antes[k][3] + no.pivot_offset) - antes[String(k).get_base_dir() + "/Pier"][3]
	var serie := {}
	for k in assentam:
		serie[k] = [(depois[k][0] as Control).scale]
	var chao_max := 0.0
	var eixo_max := 0.0
	var fora: Array = []
	for passo in range(PASSOS):
		for k in assentam:
			var no: Control = depois[k][0]
			if String(k).get_file() == "Lanca":
				var pier: Control = depois[String(k).get_base_dir() + "/Pier"][0]
				var no_pier: Vector2 = pier.get_transform().affine_inverse() * (no.position + no.pivot_offset)
				eixo_max = maxf(eixo_max, no_pier.distance_to(eixo[k]))
			elif is_zero_approx(no.rotation):
				chao_max = maxf(chao_max, (no.get_transform() * (no.size * 0.5)).distance_to(centro[k]))
		_andar(tw0, PASSO)
		for k in assentam:
			serie[k].append((depois[k][0] as Control).scale)
		for r in alfas:
			alfas[r].append(r.modulate.a if is_instance_valid(r) and r.is_inside_tree() else 0.0)
		for k in _escalados(depois):
			if k not in assentam and k not in fora:
				fora.append(k)
	conferir("%s: nenhum outro nó escala depois do primeiro passo" % id, fora.is_empty(), str(fora))
	var comeco_ruim: Array = []
	var desigual: Array = []
	var encolhe: Array = []
	var passa: Array = []
	var nao_trava: Array = []
	var cedo: Array = []
	var fim_ruim: Array = []
	for k in assentam:
		var s: Array = serie[k]
		if absf((s[0] as Vector2).x - DE) > 0.0005:
			comeco_ruim.append("%s %.4f" % [k, (s[0] as Vector2).x])
		for i in range(s.size()):
			var v: Vector2 = s[i]
			if not is_equal_approx(v.x, v.y):
				desigual.append(k)
				break
		for i in range(1, s.size()):
			if (s[i] as Vector2).x < (s[i - 1] as Vector2).x - 1e-6:
				encolhe.append(k)
				break
		for v in s:
			if (v as Vector2).x > 1.0 + 1e-6:
				passa.append(k)
				break
		# A meio do tempo (0,15 s = 9 passos) já fez mais de metade do caminho.
		if ((s[9] as Vector2).x - DE) / (1.0 - DE) <= 0.5:
			nao_trava.append("%s %.4f" % [k, (s[9] as Vector2).x])
		# E dura: aos 0,25 s (15 passos) ainda não chegou.
		if (s[15] as Vector2).x >= 1.0:
			cedo.append(k)
		var no: Control = depois[k][0]
		if no.scale != Vector2.ONE or no.position != repouso[k]:
			fim_ruim.append("%s %s %s/%s" % [k, no.scale, no.position, repouso[k]])
	conferir("%s §3: começa a 94%%" % id, comeco_ruim.is_empty(), str(comeco_ruim))
	conferir("%s §3: a escala é a mesma nos dois eixos" % id, desigual.is_empty(), str(desigual))
	conferir("%s §3: nunca encolhe" % id, encolhe.is_empty(), str(encolhe))
	conferir("%s §3: nunca passa de 100%%" % id, passa.is_empty(), str(passa))
	conferir("%s §3: trava (a meio do tempo já fez mais de metade)" % id, nao_trava.is_empty(),
		str(nao_trava))
	conferir("%s §3: dura (aos 0,25 s ainda não chegou)" % id, cedo.is_empty(), str(cedo))
	conferir("%s §3: acaba inteira e no sítio, exatos" % id, fim_ruim.is_empty(), str(fim_ruim))
	conferir("%s §4: o chão das peças fica parado (%.4f px)" % [id, chao_max], chao_max < 0.01)
	conferir("%s §4: a lança não descola da base do píer (%.4f px)" % [id, eixo_max],
		eixo_max < 0.01)
	var acende: Array = []
	var demora: Array = []
	for r in alfas:
		var a: Array = alfas[r]
		var fim_do_rasto := ceili(float(segundos[r]) / PASSO) + 1
		for i in range(1, a.size()):
			if a[i] > a[i - 1] + 1e-6:
				acende.append(i)
				break
		if a[fim_do_rasto] > 0.0:
			demora.append("%.3f aos %.2f s" % [a[fim_do_rasto], float(segundos[r])])
	conferir("%s §8: o rasto só esmaece" % id, acende.is_empty(), str(acende))
	conferir("%s §8: e some no tempo dele (0,25 s; o canteiro e os cones, 0,1)" % id,
		demora.is_empty(), str(demora))
	# Nem depressa demais: aos 80% do tempo dele ainda se vê. A meio não
	# chegava — o rasto de 0,15 s, o que o Bruno achou rápido, ainda se via
	# aos 0,125 s de um de 0,25.
	var cedo_demais: Array = []
	for r in alfas:
		var a: Array = alfas[r]
		var quase := int(float(segundos[r]) / PASSO * 0.8)
		if a[quase] <= 0.0:
			cedo_demais.append("%.2f s" % float(segundos[r]))
	conferir("%s §8: e aos 80%% do tempo dele ainda se vê" % id, cedo_demais.is_empty(),
		str(cedo_demais))
	conferir("%s §8: no fim não fica rasto nenhum" % id, _rastos_na_arvore().is_empty())
	_fechar(tela)


## Os rastos da obra que estão na árvore, a desenhar-se.
func _rastos_na_arvore() -> Array:
	var r: Array = []
	for no in _arvore.get_nodes_in_group(&"rasto_da_obra"):
		if no.is_inside_tree() and not no.is_queued_for_deletion():
			r.append(no)
	return r


# §1 ────────────────────────────────────────────────────────────────────────
func _sem_obra_a_acabar() -> bool:
	# O porto completo: tudo construído, e uma virada sem obra nenhuma.
	_partida()
	_gs.cash = 5000000
	for id in _gs.ESTRUTURAS:
		_bancada.instalar(_gs, String(id))
	var tela := _abrir_cena()
	tela._concluir_virada()
	conferir("§1 o porto completo tem tudo construído", _gs.estruturas.size() == _gs.ESTRUTURAS.size())
	_nada_assenta(tela, "§1 a virada do porto completo não assenta nada")
	_fechar(tela)

	# Uma obra que ainda não acaba nesta virada.
	tela = _abrir_com_obra("armazem", 2)
	tela._concluir_virada()
	_nada_assenta(tela, "§1 a virada de uma obra que ainda não acaba não assenta nada")
	conferir("§1 e a obra continua por acabar", not _gs.tem_estrutura("armazem"))
	_fechar(tela)

	# A obra concluída pela bancada, com a cena aberta e fora do botão.
	_partida()
	tela = _abrir_cena()
	var tw0 := _tweens()
	_bancada.instalar(_gs, "armazem")
	var foto := _foto(tela)
	var algum := _escalados(foto)
	_andar(tw0, PASSO)
	algum.append_array(_escalados(foto))
	conferir("§1 a obra concluída fora do botão não assenta nada", algum.is_empty(), str(algum))
	_fechar(tela)
	return true


func _nada_assenta(tela: Control, nome: String) -> void:
	var foto := _foto(tela)
	var tw0 := _tweens()
	var dia: int = _gs.turn
	_premir(tela)
	var algum := _escalados(foto)
	for passo in range(PASSOS):
		_andar(tw0, PASSO)
		for k in _escalados(foto):
			if k not in algum:
				algum.append(k)
	conferir(nome, algum.is_empty() and _gs.turn == dia + 1 and _rastos_na_arvore().is_empty(),
		"escalaram %s; dia %d → %d; %d rasto(s)" % [algum, dia, _gs.turn, _rastos_na_arvore().size()])


# §5 ────────────────────────────────────────────────────────────────────────
func _o_toque_a_meio() -> bool:
	var tela := _abrir_com_obra("pier_2")
	tela._concluir_virada()
	var antes := _foto(tela)
	var tw0 := _tweens()
	_premir(tela)
	var assentam := _escalados(antes)
	_andar(tw0, PASSO * 5)
	conferir("§5 a meio, o píer 2 ainda assenta", assentam.has("Docas/Doca1/Pier")
		and (antes["Docas/Doca1/Pier"][0] as Control).scale.x < 1.0)
	tela._concluir_virada()
	var ruins: Array = []
	for k in assentam:
		var no: Control = antes[k][0]
		if no.scale != Vector2.ONE or no.position != antes[k][3]:
			ruins.append("%s %s %s" % [k, no.scale, no.position])
	conferir("§5 o `_concluir_virada()` põe cada peça inteira e no sítio já", ruins.is_empty()
		and not assentam.is_empty(), str(ruins))
	conferir("§5 e a virada deixa de estar em curso", not tela.virada_em_curso())
	conferir("§5 e o rasto da obra sai já", _rastos_na_arvore().is_empty())
	_fechar(tela)
	return true


# §6 ────────────────────────────────────────────────────────────────────────
func _o_reduzido() -> bool:
	_pref.definir_reduzir_movimento(true)
	var tela := _abrir_com_obra("armazem")
	tela._concluir_virada()
	var foto := _foto(tela)
	var tw0 := _tweens()
	_premir(tela)
	var algum := _escalados(foto)
	_andar(tw0, PASSO)
	algum.append_array(_escalados(foto))
	conferir("§6 com o movimento reduzido a obra conclui e nada assenta",
		_gs.tem_estrutura("armazem") and algum.is_empty(), str(algum))
	conferir("§6 nem deixa rasto", _rastos_na_arvore().is_empty())
	_fechar(tela)

	# Ligado a meio do assentar, acaba-o.
	_pref.definir_reduzir_movimento(false)
	tela = _abrir_com_obra("armazem")
	tela._concluir_virada()
	foto = _foto(tela)
	tw0 = _tweens()
	_premir(tela)
	_andar(tw0, PASSO * 3)
	var a_meio := _escalados(foto)
	_pref.definir_reduzir_movimento(true)
	var armazem: Control = foto["Cenario/Armazem"][0]
	conferir("§6 ligado a meio, o armazém fica inteiro e no sítio já",
		a_meio.has("Cenario/Armazem") and armazem.scale == Vector2.ONE
			and armazem.position == foto["Cenario/Armazem"][3] and _escalados(foto).is_empty(),
		"a meio %s; depois %s em %s" % [a_meio, armazem.scale, armazem.position])
	conferir("§6 e o rasto sai com ele", _rastos_na_arvore().is_empty())
	_pref.definir_reduzir_movimento(false)
	_fechar(tela)
	return true


# §7 ────────────────────────────────────────────────────────────────────────
## A fração do botão que o estilo do estado atual desenha: o retângulo do
## botão crescido pelas margens de expansão desse estilo.
func _estilo(botao: Button) -> StyleBox:
	var estados := {BaseButton.DRAW_NORMAL: "normal", BaseButton.DRAW_PRESSED: "pressed",
		BaseButton.DRAW_HOVER: "hover", BaseButton.DRAW_DISABLED: "disabled",
		BaseButton.DRAW_HOVER_PRESSED: "hover_pressed"}
	return botao.get_theme_stylebox(estados[botao.get_draw_mode()])


func _desenhado(botao: Button) -> Rect2:
	var estilo := _estilo(botao)
	var r := Rect2(Vector2.ZERO, botao.size)
	if estilo is StyleBoxFlat:
		var f := estilo as StyleBoxFlat
		r = r.grow_individual(f.get_expand_margin(SIDE_LEFT), f.get_expand_margin(SIDE_TOP),
			f.get_expand_margin(SIDE_RIGHT), f.get_expand_margin(SIDE_BOTTOM))
	return r


## Onde fica o meio do conteúdo (texto e ícone) na vertical, pelo estilo do
## estado atual.
func _meio_do_conteudo(botao: Button) -> float:
	var estilo := _estilo(botao)
	return estilo.get_margin(SIDE_TOP) \
		+ (botao.size.y - estilo.get_margin(SIDE_TOP) - estilo.get_margin(SIDE_BOTTOM)) * 0.5


## Do canto esquerdo DESENHADO ao ícone, que o botão põe na margem de conteúdo
## do estilo do estado atual.
func _folga_do_icone(botao: Button) -> float:
	var estilo := _estilo(botao)
	return estilo.get_margin(SIDE_LEFT) - _desenhado(botao).position.x


func _o_botao() -> bool:
	_partida()
	var tela := _abrir_cena()
	tela._concluir_virada()
	var dia: int = _gs.turn
	var viradas: Array = []
	var botao := tela.get_node("AcoesTurno/Avancar") as Button
	botao.pressed.connect(func(): viradas.append(_gs.turn))
	conferir("§7 o botão do rodapé tem o tamanho medido (692 × 58)",
		botao.size.is_equal_approx(Vector2(692, 58)), str(botao.size))
	var solto := _desenhado(botao)
	var folga_solto := _folga_do_icone(botao)
	var meio_solto := _meio_do_conteudo(botao)
	var cor_solto: Color = (_estilo(botao) as StyleBoxFlat).bg_color
	conferir("§7 em repouso desenha-se inteiro", solto == Rect2(Vector2.ZERO, botao.size), str(solto))
	_premir(tela, false)
	var premido := _desenhado(botao)
	var fx := premido.size.x / botao.size.x
	var fy := premido.size.y / botao.size.y
	conferir("§7 premido, está no estado premido e o dia ainda não virou",
		botao.get_draw_mode() == BaseButton.DRAW_PRESSED and _gs.turn == dia,
		"modo %d, dia %d → %d" % [botao.get_draw_mode(), dia, _gs.turn])
	conferir("§7 premido, desenha-se 4%% menor nos dois eixos (%.3f × %.3f)" % [fx, fy],
		absf(fx - PREMIDO) <= PREMIDO_TOLERA and absf(fy - PREMIDO) <= PREMIDO_TOLERA)
	conferir("§7 e à volta do centro",
		premido.get_center().distance_to(Rect2(Vector2.ZERO, botao.size).get_center()) < 0.01,
		str(premido))
	# Visto no vídeo: com o painel 14 px mais estreito de cada lado, o ícone
	# ficava onde estava e encostava a 3 px da borda.
	var folga_premido := _folga_do_icone(botao)
	conferir("§7 e o ícone fica à mesma distância da borda (%.2f px premido, %.2f solto)"
		% [folga_premido, folga_solto], absf(folga_premido - folga_solto) < 0.01)
	var desce := _meio_do_conteudo(botao) - meio_solto
	conferir("§7 e o conteúdo desce 1 px (%.2f)" % desce, absf(desce - 1.0) < 0.01)
	_soltar(botao)
	var volta := _desenhado(botao)
	conferir("§7 solto, volta a desenhar-se inteiro", volta.size == botao.size, str(volta))
	# O rato do telefone é emulado do toque e fica onde o dedo saiu: o botão
	# fica «por cima», e era aí que ficava âmbar claro.
	conferir("§7 solto, com o rato ainda por cima, tem a cor do repouso",
		botao.get_draw_mode() == BaseButton.DRAW_HOVER
			and (_estilo(botao) as StyleBoxFlat).bg_color == cor_solto,
		"modo %d" % botao.get_draw_mode())
	conferir("§7 e o dia virou uma vez só", _gs.turn == dia + 1 and viradas.size() == 1,
		"dia %d → %d, %d pressed" % [dia, _gs.turn, viradas.size()])
	_fechar(tela)
	return true


# §9 ────────────────────────────────────────────────────────────────────────
func _o_cartao() -> bool:
	_partida()
	# Dois barcos: depois de atracar o primeiro, o cartão 1 mostra o segundo
	# e continua a ser um cartão — vazio, o estilo dele é outro.
	_gs.fila = [_gs._make_boat(), _gs._make_boat()]
	var tela := _abrir_cena()
	tela._concluir_virada()
	var cartao := tela.get_node("Fila").get_child(0) as PanelContainer
	conferir("§9 o lugar 1 tem o barco e o berço 1 está livre",
		cartao.barco() != null and _gs.docks[0]["boat"] == null)
	var tamanho := cartao.size
	var antes := cartao.get_theme_stylebox("panel") as StyleBoxFlat
	var meio_antes := antes.get_margin(SIDE_TOP) \
		+ (tamanho.y - antes.get_margin(SIDE_TOP) - antes.get_margin(SIDE_BOTTOM)) * 0.5
	conferir("§9 em repouso desenha-se inteiro", antes.get_expand_margin(SIDE_LEFT) == 0.0
		and antes.get_expand_margin(SIDE_TOP) == 0.0)
	var onde := cartao.get_global_rect().get_center()
	var ev := InputEventMouseButton.new()
	ev.button_index = MOUSE_BUTTON_LEFT
	ev.position = onde
	ev.global_position = onde
	ev.pressed = true
	_arvore.root.push_input(ev, true)
	var premido := cartao.get_theme_stylebox("panel") as StyleBoxFlat
	var r := Rect2(Vector2.ZERO, tamanho).grow_individual(premido.get_expand_margin(SIDE_LEFT),
		premido.get_expand_margin(SIDE_TOP), premido.get_expand_margin(SIDE_RIGHT),
		premido.get_expand_margin(SIDE_BOTTOM))
	var fx := r.size.x / tamanho.x
	var fy := r.size.y / tamanho.y
	conferir("§9 premido, ainda não atracou", _gs.docks[0]["boat"] == null and _gs.fila.size() == 2)
	conferir("§9 premido, desenha-se 4%% mais estreito, com a altura inteira (%.3f × %.3f)" % [fx, fy],
		absf(fx - PREMIDO) <= PREMIDO_TOLERA and fy == 1.0, "cartão %s" % tamanho)
	# A última linha não pisa a borda: do fundo do conteúdo ao lado de dentro
	# da borda desenhada fica pelo menos 1 px. Com o cartão 3 px mais baixo em
	# baixo e o conteúdo a descer, ela pisava-a (visto na quarta passagem).
	var folga_baixo := premido.get_margin(SIDE_BOTTOM) + premido.get_expand_margin(SIDE_BOTTOM) \
		- premido.border_width_bottom
	conferir("§9 e a última linha não pisa a borda (%.2f px)" % folga_baixo, folga_baixo >= 1.0)
	# E nos três estados premidos, pelo tema — o porto deste bloco só monta o
	# cartão à espera (como o D43 mede os cartões).
	var tema: Theme = load("res://ui/tema_brport.tres")
	var pisam: Array = []
	for variacao in [&"CartaoDocaPremido", &"CartaoDocaEsperaPremido", &"CartaoDocaRivalPremido"]:
		var sb := tema.get_stylebox(&"panel", variacao) as StyleBoxFlat
		var folga := sb.get_margin(SIDE_BOTTOM) + sb.get_expand_margin(SIDE_BOTTOM) - sb.border_width_bottom
		if folga < 1.0 or sb.get_expand_margin(SIDE_TOP) != 0.0:
			pisam.append("%s %.2f" % [variacao, folga])
	conferir("§9 e nos três estados premidos a última linha não pisa a borda", pisam.is_empty(),
		str(pisam))
	conferir("§9 e à volta do centro",
		r.get_center().distance_to(Rect2(Vector2.ZERO, tamanho).get_center()) < 0.01, str(r))
	var meio := premido.get_margin(SIDE_TOP) \
		+ (tamanho.y - premido.get_margin(SIDE_TOP) - premido.get_margin(SIDE_BOTTOM)) * 0.5
	conferir("§9 e o conteúdo desce 1 px (%.2f)" % (meio - meio_antes), absf(meio - meio_antes - 1.0) < 0.01)
	# O passo de escuro é o do botão, lido no tema dele: só a encolher, no
	# cartão escuro, mudava pouco (o veredito 3).
	var botao := tela.get_node("AcoesTurno/Avancar") as Button
	var passo_botao := _luz((botao.get_theme_stylebox("pressed") as StyleBoxFlat).bg_color) \
		- _luz((botao.get_theme_stylebox("normal") as StyleBoxFlat).bg_color)
	var passo := _luz(premido.bg_color) - _luz(antes.bg_color)
	conferir("§9 e o fundo escurece o passo do botão (%.3f, o botão %.3f)" % [passo, passo_botao],
		passo_botao < -0.01 and absf(passo - passo_botao) < 0.005)
	var solta := InputEventMouseButton.new()
	solta.button_index = MOUSE_BUTTON_LEFT
	solta.position = onde
	solta.global_position = onde
	solta.pressed = false
	_arvore.root.push_input(solta, true)
	var depois := cartao.get_theme_stylebox("panel") as StyleBoxFlat
	conferir("§9 solto, atracou", _gs.docks[0]["boat"] != null and _gs.fila.size() == 1)
	conferir("§9 e o cartão volta a desenhar-se inteiro", depois != null
		and depois.get_expand_margin(SIDE_LEFT) == 0.0 and depois.get_expand_margin(SIDE_TOP) == 0.0,
		String(cartao.theme_type_variation))
	_fechar(tela)
	return true


## A luminância de uma cor em OKLab (o L), que é a medida em que o passo de
## escuro do botão e o do cartão se comparam.
static func _luz(c: Color) -> float:
	var r := c.srgb_to_linear()
	var l := pow(0.4122214708 * r.r + 0.5363325363 * r.g + 0.0514459929 * r.b, 1.0 / 3.0)
	var m := pow(0.2119034982 * r.r + 0.6806995451 * r.g + 0.1073969566 * r.b, 1.0 / 3.0)
	var s := pow(0.0883024619 * r.r + 0.2817188376 * r.g + 0.6299787005 * r.b, 1.0 / 3.0)
	return 0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s
