extends SceneTree
var feito := false

func _process(_delta: float) -> bool:
	if not feito:
		feito = true
		rodar()
	return false

func assentar() -> void:
	for i in range(6):
		await process_frame
	await RenderingServer.frame_post_draw

func botao(no: Node, texto: String) -> Button:
	if no is Button and no.text == texto and not no.is_queued_for_deletion():
		return no
	for filho in no.get_children():
		var b := botao(filho, texto)
		if b != null:
			return b
	return null

func rodar() -> void:
	var args := OS.get_cmdline_user_args()
	var dimensoes := args[1].split("x")
	var gs: Node = root.get_node("GameState")
	gs.comecar_no_espaco(1)
	gs.definir_nomes("Cais da prova", "Teste")
	if gs.phase == gs.ESTADO_OFERTA:
		gs.resolve_rival_offer(true)
	if args[3] == "1":
		for dia in range(8):
			if gs.phase == gs.ESTADO_OFERTA:
				gs.resolve_rival_offer(true)
			gs.advance_turn()
		if gs.phase == gs.ESTADO_OFERTA:
			gs.resolve_rival_offer(true)
	var tela := SubViewport.new()
	tela.size = Vector2i(int(dimensoes[0]), int(dimensoes[1]))
	tela.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(tela)
	var caminho := "res://scenes/Main.tscn" if args[3] == "1" else "res://scenes/TelaInicial.tscn"
	var origem: Control = load(caminho).instantiate()
	tela.add_child(origem)
	await assentar()
	if args[3] == "1":
		for p in origem.get_node("Overlay").get_children():
			p.free()
		origem.get_node("HudBar/Pausar").pressed.emit()
		await assentar()
	botao(origem, "Como jogar").pressed.emit()
	await assentar()
	if args[4] != "":
		botao(origem, args[4]).pressed.emit()
		await assentar()
	if args[2] == "1":
		var leitura: ScrollContainer = origem.find_child("Leitura", true, false)
		leitura.scroll_vertical = 100000
		await assentar()
		print("Rolagem da ajuda: %d / %.0f" % [leitura.scroll_vertical, leitura.get_v_scroll_bar().max_value - leitura.get_v_scroll_bar().page])
	var foto := tela.get_texture().get_image()
	assert(foto.get_size() == tela.size)
	var erro := foto.save_png(args[0])
	if erro != OK:
		push_error("Não gravou quadro de prova: %d" % erro)
		quit(1)
		return
	print("Quadro de prova: %s, origem %s, dia %d" % [tela.size, caminho, gs.turn])
	print("Tela salva em %s" % args[0])
	quit(0)
