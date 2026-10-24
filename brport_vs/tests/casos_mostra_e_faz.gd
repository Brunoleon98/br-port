extends RefCounted

# ============================================================
# T31 — o que a tela MOSTRA e o que o toque FAZ (`138`)
#
# A amostra de mutação da `137` pôs 205 defeitos plausíveis nas funções que as
# seis suítes executam, e 99 passaram verdes. Treze eram graves, e sete moram
# aqui: a reputação que deixa de subir ao servir, o save trocado por partida
# nova no arranque, o bloco «Entrou» do caixa ao contrário, a parcela e a meta
# sem botão de fechar, o cartão da doca sem o valor e os cascos da fila a zero.
# As suítes abriam estes painéis e perguntavam se cabiam; ninguém lia o número
# nem premia o botão — executar não é conferir.
#
# Cada caso entra pela PORTA DO JOGADOR — o toque que solta na pílula, no
# cartão da parcela, no barco ao largo — e pergunta pelo TEXTO e pela AÇÃO. O
# esperado sai do estado montado, nunca do código do painel: um esperado lido
# de onde o defeito mora é um espelho (`testes-e-guardas.md`).
#
# Os outros seis vivem ao lado das irmãs deles: o cancelamento no T24, os
# Ajustes e o arrasto com o dedo no RB5 do `teste_design`, o volume e o mar no
# `teste_audio`.
# ============================================================

const CENA := "res://scenes/Main.tscn"

var gs
var arvore: SceneTree
var falhas := 0
var completo := false


func conferir(nome: String, condicao: bool) -> void:
	print("PASS T31: " if condicao else "FAIL T31: ", nome)
	if not condicao:
		falhas += 1


# Dois frames, e não um: `await process_frame` retoma antes do flush da fila
# adiada (`gdscript.md`), e o `queue_free()` do painel fechado só age lá.
func assentar() -> void:
	await arvore.process_frame
	await arvore.process_frame


func barco(id: int, valor: int, dias: int = 1, progresso: int = 0) -> Dictionary:
	return {"id": id, "value": valor, "classe": "pesqueiro", "motivo": "pescado",
		"op_turns": dias, "progress": progresso, "rival": false, "matched": false,
		"matched_value": 0, "paciencia": 2}


# Partida semeada, fora do dia 1 (o tutorial do Toninho só fala nele) e com os
# nomes já escolhidos (a folha de rosto abriria por cima de tudo).
func montar() -> void:
	gs._rng.seed = 3131
	gs.new_game()
	if gs.phase == gs.ESTADO_OFERTA:
		gs.resolve_rival_offer(true)
	gs.nome_porto = "Cais do T31"
	gs.nome_jogador = "Teste"
	gs.turn = 3
	gs.fila = []
	gs.pending_rival = -1


# O toque que SOLTA, que é o que as pílulas, os cartões e os barcos escutam.
func soltar() -> InputEventMouseButton:
	var ev := InputEventMouseButton.new()
	ev.button_index = MOUSE_BUTTON_LEFT
	ev.pressed = false
	return ev


func textos(no: Node) -> Array:
	var lista := []
	for rotulo in no.find_children("*", "Label", true, false):
		lista.append(String(rotulo.text))
	return lista


# O botão que o jogador vê com ESTE texto — pelo texto, e não pelo nome do nó:
# é pelo que o botão diz que se escolhe.
func botao(no: Node, texto: String) -> Button:
	for b in no.find_children("*", "Button", true, false):
		if b.text == texto and b.is_visible_in_tree():
			return b
	return null


func ultimo_painel(main: Node) -> Node:
	var overlay: Node = main.get_node("Overlay")
	return overlay.get_child(overlay.get_child_count() - 1) if overlay.get_child_count() > 0 else null


# Fecha o que um defeito tiver deixado aberto, para o caso seguinte começar
# com o overlay vazio e reprovar pela pergunta dele.
func limpar_overlay(main: Node) -> void:
	for painel in main.get_node("Overlay").get_children():
		if not painel.is_queued_for_deletion():
			painel.queue_free()
	await assentar()


func rodar(estado, tree: SceneTree) -> void:
	gs = estado
	arvore = tree
	reputacao_ao_servir()
	await arranque_carrega_o_save()
	montar()
	var main: Node = load(CENA).instantiate()
	arvore.root.add_child(main)
	await assentar()
	await caixa_diz_o_que_entrou(main)
	await parcela_com_falta_deixa_fechar(main)
	await meta_deixa_fechar(main)
	await doca_mostra_o_valor(main)
	await cascos_da_fila_a_vista(main)
	main.queue_free()
	await assentar()
	arvore.root.get_node("Registro").desarmar()
	montar()
	completo = true


# ⚠️ O T26 PERGUNTA SE A REPUTAÇÃO FICA ENTRE 0 E 100, E O T5 SE A DESISTÊNCIA
# A FAZ DESCER — nenhum perguntava se servir a faz SUBIR. Apagar o ganho
# deixava as seis suítes verdes e o simulador a chegar ao fim (ele não confere
# as taxas). Reputação a meio da barra, fila vazia (a desistência também mexe
# nela) e meio da semana: o único movimento do dia é o barco servido.
func reputacao_ao_servir() -> void:
	montar()
	gs.reputation = 50.0
	gs.docks[0] = {"boat": barco(901, 8000), "worker_id": int(gs.workers[0]["id"])}
	gs.workers[0]["busy_turns"] = 1
	var servidos: int = int(gs.metrics["boats_served"])
	var ganho: float = gs.REPUTATION_GAIN_SERVED
	gs.advance_turn()
	conferir("atender um barco sobe a reputação em %s" % ganho,
		int(gs.metrics["boats_served"]) == servidos + 1
		and is_equal_approx(float(gs.reputation), 50.0 + ganho))


# ⚠️ O ARRANQUE É O ÚNICO SÍTIO QUE NENHUMA SUÍTE ATRAVESSA: o `_ready()` do
# autoload corre uma vez, antes de qualquer bloco, num `user://` vazio. Trocar
# o `not load_game()` por `load_game()` faria o jogo abrir sempre um porto
# novo por cima do que o jogador gravou — e ninguém o via. Um `GameState`
# NOVO, posto na árvore, corre o mesmo `_ready()` contra o disco que se
# escolheu; o autoload de verdade não é tocado. Os três espaços voltam ao que
# eram, byte a byte, porque o T27 e o F16 da fumaça também os usam.
func arranque_carrega_o_save() -> void:
	var guardados := {}
	for n in range(1, gs.ESPACOS + 1):
		var c: String = ArmazemLocal.caminho(gs.arquivo_do_espaco(n))
		guardados[c] = FileAccess.get_file_as_bytes(c) if FileAccess.file_exists(c) else null
	var espaco_antes: int = gs.espaco
	for n in range(1, gs.ESPACOS + 1):
		gs.apagar_espaco(n)
	gs._apontar_espaco(1)
	montar()
	gs.turn = 17
	gs.cash = 271828
	gs.save_game()

	var arranque: Node = load("res://autoload/GameState.gd").new()
	arranque.name = "ArranqueDoT31"
	arvore.root.add_child(arranque)
	conferir("o arranque abre a partida gravada, e não uma nova",
		int(arranque.turn) == 17 and int(arranque.cash) == 271828
		and String(arranque.nome_porto) == "Cais do T31")
	arvore.root.remove_child(arranque)
	arranque.free()

	# E o controlo: sem save nenhum, o mesmo arranque abre partida nova — senão
	# a asserção de cima passaria com um `_ready()` que não faz nada.
	for n in range(1, gs.ESPACOS + 1):
		gs.apagar_espaco(n)
	var vazio: Node = load("res://autoload/GameState.gd").new()
	vazio.name = "ArranqueVazioDoT31"
	arvore.root.add_child(vazio)
	conferir("sem save, o arranque abre partida nova",
		int(vazio.turn) == 1 and String(vazio.nome_porto) == ""
		and vazio.docks.size() > 0 and int(vazio.cash) == int(gs.START_CASH))
	arvore.root.remove_child(vazio)
	vazio.free()

	for c in guardados:
		if guardados[c] == null:
			if FileAccess.file_exists(c):
				DirAccess.remove_absolute(c)
		else:
			var f := FileAccess.open(c, FileAccess.WRITE)
			f.store_buffer(guardados[c])
			f.close()
	gs._apontar_espaco(espaco_antes)
	await arvore.process_frame


# ⚠️ O D10 DO DESIGN ABRE ESTE PAINEL NUM PORTO QUE ACABOU DE NASCER, e lá
# ontem não existe e hoje não rende: «Entrou» não aparece em nenhuma das duas
# versões da condição. Aqui ontem serviu um barco, e a pergunta é a lista dos
# blocos «Entrou» com o total de cada um, contra a receita do estado.
func caixa_diz_o_que_entrou(main: Node) -> void:
	montar()
	gs.docks[0] = {"boat": barco(902, 8000), "worker_id": int(gs.workers[0]["id"])}
	gs.workers[0]["busy_turns"] = 1
	gs.advance_turn()
	var ontem: Dictionary = gs.dia_anterior
	var hoje: Dictionary = gs.projecao_do_dia()
	var esperado := []
	for dia in [ontem, hoje]:
		var receita: int = int(dia["docagens"]) + int(dia["armazem"]) \
			+ int(dia["patio"]) + int(dia["pier"])
		if receita != 0:
			esperado.append(gs.moeda(receita))
	main._refresh_all()
	main.get_node("HudBar/CaixaPilula").gui_input.emit(soltar())
	var painel: Node = ultimo_painel(main)
	var entrou := []
	if painel != null:
		for rotulo in painel.find_children("*", "Label", true, false):
			if rotulo.text == "Entrou":
				entrou.append(rotulo.get_parent().get_child(rotulo.get_index() + 1).text)
	conferir("o caixa diz o que entrou ontem (%s), com o total de cada dia" % ", ".join(esperado),
		esperado.size() >= 1 and entrou == esperado)
	await limpar_overlay(main)


# A parcela com falta é o caso que mais se abre na Fase 1 — o jogador toca no
# cartão para saber quanto falta —, e o único sem botão de quitar: se o de
# fechar some, o cartão fica preso por cima do porto.
func parcela_com_falta_deixa_fechar(main: Node) -> void:
	montar()
	var valor: int = gs.valor_da_parcela_hoje()
	gs.cash = valor - 12345
	main._refresh_all()
	main.get_node("MetaCartao").gui_input.emit(soltar())
	var painel: Node = ultimo_painel(main)
	var aberto: bool = painel != null and painel.scene_file_path.ends_with("PainelParcela.tscn")
	conferir("a parcela diz quanto falta para quitar hoje", aberto
		and textos(painel).has("Faltam %s para quitar hoje." % gs.moeda(12345)))
	var fechar: Button = botao(painel, "Fechar") if aberto else null
	if fechar != null:
		fechar.pressed.emit()
	conferir("a parcela com falta deixa fechar", fechar != null and painel.is_queued_for_deletion())
	await limpar_overlay(main)


# Na Fase 2 o cartão abre a meta, e ela volta ao porto. Antes dela o `Main`
# não a abre — o ramo «a meta abre na Fase 2» é de quem a abrir por outra
# porta —, mas um painel que se pode abrir tem de se poder fechar.
func meta_deixa_fechar(main: Node) -> void:
	montar()
	gs.numero_da_fase = 2
	gs.turn = 86
	main._refresh_all()
	main.get_node("MetaCartao").gui_input.emit(soltar())
	var painel: Node = ultimo_painel(main)
	var voltar: Button = null
	if painel != null and painel.scene_file_path.ends_with("PainelMeta.tscn"):
		voltar = botao(painel, "Voltar ao porto")
	if voltar != null:
		voltar.pressed.emit()
	conferir("a meta da Fase 2 volta ao porto", voltar != null and painel.is_queued_for_deletion())
	await limpar_overlay(main)

	gs.numero_da_fase = 1
	gs.turn = 3
	var cedo: Node = load("res://scenes/panels/PainelMeta.tscn").instantiate()
	main.get_node("Overlay").add_child(cedo)
	cedo.setup()
	var fechar: Button = botao(cedo, "Fechar")
	if fechar != null:
		fechar.pressed.emit()
	conferir("antes da Fase 2 a meta diz quando abre e deixa fechar",
		textos(cedo).has("A meta abre na Fase 2.") and fechar != null and cedo.is_queued_for_deletion())
	await limpar_overlay(main)


# O VALOR É A PRIMEIRA COISA DO CARTÃO — é por ele que o jogador escolhe quem
# atraca, e o cartão da doca continua a dizê-lo enquanto o barco opera. O D18
# mede se o pior texto CABE; aqui pergunta-se se o texto ESTÁ lá, depois de o
# barco atracar pelo toque, e o do acordo do Arlindo, que paga outro valor.
func doca_mostra_o_valor(main: Node) -> void:
	montar()
	gs.workers[0]["busy_turns"] = 0
	gs.fila = [barco(903, 8765, 2)]
	main._refresh_all()
	main._fila_lugares.get_child(0)._gui_input(soltar())
	await assentar()
	var valor: Label = main._dock_cards.get_child(0).get_node("Coluna/Cabecalho/Valor")
	var atracou: bool = gs.docks[0]["boat"] != null and int(gs.docks[0]["boat"]["id"]) == 903
	conferir("o cartão da doca mostra o valor do barco atracado",
		atracou and valor.text == gs.moeda(8765))
	if atracou:
		gs.docks[0]["boat"]["matched"] = true
		gs.docks[0]["boat"]["matched_value"] = 7650
	main._refresh_all()
	conferir("e, com o acordo, o valor acordado", atracou and valor.text == gs.moeda(7650))
	await limpar_overlay(main)


# ⚠️ OS CASCOS DA FILA SAEM DE UMA ESCALA CALCULADA UMA VEZ, e a conta guarda-
# se num `static var`: com a guarda do cálculo trocada (`>= 0.0`), ela devolve
# o zero inicial para sempre, os três barcos ao largo ficam com 0 px de casco e
# o cartão continua a caber — que era tudo o que se perguntava. O bote mede 33
# px a esta escala e o maior recorte da frota 70 (o comentário da escala);
# os três valores são os três portes do pesqueiro, do bote ao arrasteiro.
func cascos_da_fila_a_vista(main: Node) -> void:
	montar()
	gs.fila = [barco(904, 4500), barco(905, 6500), barco(906, 8800)]
	main._refresh_all()
	var alturas := []
	for lugar in main._fila_lugares.get_children():
		if lugar.barco() == null:
			continue
		var desenho: TextureRect = lugar.get_node("Coluna/Casco/Desenho")
		alturas.append(roundi(desenho.custom_minimum_size.y) if desenho.texture != null else 0)
	var a_vista := alturas.size() == 3
	for h in alturas:
		a_vista = a_vista and h >= 20 and h <= 70
	conferir("cada barco ao largo tem casco à vista (%s px)" % str(alturas), a_vista)
	await limpar_overlay(main)
