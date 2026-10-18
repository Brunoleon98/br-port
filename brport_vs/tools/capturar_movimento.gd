extends SceneTree

var _iniciado := false


func _process(_delta: float) -> bool:
	if not _iniciado:
		_iniciado = true
		_fotografar()
	return false


func _fotografar() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() != 2 or args[0] not in ["normal", "reduzido", "inicio", "pausa", "resultado"]:
		push_error("uso: capturar_movimento.gd -- <normal|reduzido|inicio|pausa|resultado> <saida.png>")
		quit(1)
		return
	var modo := args[0]
	var pref := PreferenciasDeApresentacao.atual()
	var existia := FileAccess.file_exists(pref.caminho)
	var original := FileAccess.get_file_as_bytes(pref.caminho) if existia else PackedByteArray()
	pref.definir_reduzir_movimento(modo != "normal")
	var gs: Node = root.get_node("GameState")
	gs._rng.seed = 42
	for n in range(1, int(gs.ESPACOS) + 1):
		gs.apagar_espaco(n)
	gs.comecar_no_espaco(1)
	gs.definir_nomes("Cais da comparação", "Bancada")
	if gs.phase == gs.ESTADO_OFERTA:
		gs.resolve_rival_offer(true)
	var tela: Control
	if modo == "inicio":
		tela = load("res://scenes/TelaInicial.tscn").instantiate()
		root.add_child(tela)
		tela._abrir_ajustes()
	else:
		if modo == "resultado":
			gs.atracar(0)
		tela = load("res://scenes/Main.tscn").instantiate()
		root.add_child(tela)
		if modo == "pausa":
			tela._on_pause_pressed()
			tela._abrir_ajustes()
		elif modo == "resultado":
			tela._on_advance_pressed()
	var estado := [gs.turn, gs.cash, gs._rng.state]
	await _esperar(30)
	await _salvar(args[1])
	if modo in ["normal", "reduzido"]:
		await _esperar(120)
		await _salvar(args[1].get_basename() + "_t1.png")
		if estado != [gs.turn, gs.cash, gs._rng.state]:
			push_error("a comparação temporal alterou dia, caixa ou RNG")
			quit(1)
			return
		var manifesto := {"modo": modo, "semente": 42, "fps_fixo": 60,
			"frames": [30, 150], "intervalo_segundos": 2,
			"janela": [720, 1280], "recorte_mapa": [0, 62, 720, 782],
			"turno": gs.turn, "caixa": gs.cash, "rng": str(gs._rng.state)}
		var arquivo := FileAccess.open(args[1].get_basename() + ".json", FileAccess.WRITE)
		arquivo.store_string(JSON.stringify(manifesto, "\t"))
		arquivo.close()
	if modo in ["inicio", "pausa"]:
		print("Paineis: res://scenes/panels/PainelAjustes.tscn")
	if existia:
		var arquivo := FileAccess.open(pref.caminho, FileAccess.WRITE)
		arquivo.store_buffer(original)
		arquivo.close()
	else:
		DirAccess.remove_absolute(pref.caminho)
	quit(0)


func _esperar(frames: int) -> void:
	for i in frames:
		root.size = Vector2i(720, 1280)
		await process_frame


func _salvar(caminho: String) -> void:
	await RenderingServer.frame_post_draw
	var imagem := root.get_texture().get_image()
	if imagem == null or imagem.get_size() != Vector2i(720, 1280) or imagem.save_png(caminho) != OK:
		push_error("a captura de movimento não gerou o quadro esperado")
		quit(1)
		return
	print("Tela salva em ", caminho, " (720x1280)")
