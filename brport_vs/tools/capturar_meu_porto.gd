extends SceneTree

# Evidência própria do RB2: joga até a fase, inicia obra/serviço de verdade e
# abre a consulta pela inicial. Roda em user://ferramentas/, como a bateria.
var _iniciado := false


func _process(_delta: float) -> bool:
	if not _iniciado:
		_iniciado = true
		_fotografar()
	return false


func _fotografar() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() < 2:
		push_error("uso: capturar_meu_porto.gd -- <fase1|fase2|livre|encerrada|indisponivel> <saida.png> [fim]")
		quit(1)
		return
	var gs: Node = root.get_node("GameState")
	gs._rng.seed = 42
	for n in range(1, int(gs.ESPACOS) + 1):
		gs.apagar_espaco(n)
	gs.comecar_no_espaco(1)
	gs.definir_nomes("Porto da Boa Esperança", "Teste")
	gs.cash = 10000000
	if gs.phase == gs.ESTADO_OFERTA:
		gs.resolve_rival_offer(true)
	var cenario := String(args[0])
	if cenario in ["fase2", "livre"]:
		for passo in range(150):
			if gs.numero_da_fase == 2:
				break
			_avancar(gs)
		if gs.numero_da_fase != 2:
			push_error("a partida da captura não chegou à Fase 2")
			quit(1)
			return
		for id in ["pier_2", "armazem", "patio", "pier_3", "trelica"]:
			if gs.phase == gs.ESTADO_OFERTA:
				gs.resolve_rival_offer(true)
			if not gs.comprar_estrutura(id):
				push_error("a captura não comprou " + id)
				quit(1)
				return
			for passo in range(8):
				if gs.tem_estrutura(id):
					break
				_avancar(gs)
		if gs.phase == gs.ESTADO_OFERTA:
			gs.resolve_rival_offer(true)
		# Contrata cargueiros sorteados, sem inventar duração, acordo ou bônus.
		for i in range(3):
			if gs.berco_livre() < 0:
				break
			var barco: Dictionary = {}
			for tentativa in range(150):
				var candidato: Dictionary = gs._make_boat()
				if candidato["classe"] == "medio":
					barco = candidato
					break
			if barco.is_empty():
				push_error("a captura não sorteou um cargueiro")
				quit(1)
				return
			gs.fila = [barco]
			if not gs.atracar(0):
				push_error("a captura não contratou o serviço")
				quit(1)
				return
		if cenario == "livre":
			for passo in range(40):
				if gs.meta_concluida:
					break
				_avancar(gs)
			if not gs.meta_concluida:
				push_error("a captura não conquistou a meta")
				quit(1)
				return
	else:
		for passo in range(15):
			if gs.turn >= 8:
				break
			_avancar(gs)
		if gs.phase == gs.ESTADO_OFERTA:
			gs.resolve_rival_offer(true)
		if not gs.pagar_parcela_adiantado() or not gs.comprar_estrutura("armazem"):
			push_error("a captura não montou recibo e obra")
			quit(1)
			return
		if gs.fila.is_empty():
			gs._spawn_boats()
			if gs.phase == gs.ESTADO_OFERTA:
				gs.resolve_rival_offer(true)
		if not gs.atracar(0):
			push_error("a captura não contratou o serviço da Fase 1")
			quit(1)
			return
		if cenario == "encerrada":
			gs.cash = -321
			gs._check_end()
	gs.save_game()
	var inicio: Control = load("res://scenes/TelaInicial.tscn").instantiate()
	root.add_child(inicio)
	if cenario == "indisponivel":
		gs.apagar_espaco(1)
	inicio._continuar()
	for frame in range(4):
		# Reaplica depois da janela nascer: o Windows pode limitar a altura.
		root.size = Vector2i(720, 1280)
		await process_frame
	var painel: Control = inicio.get_child(inicio.get_child_count() - 1)
	if args.has("fim"):
		var rolo: ScrollContainer = painel.find_child("Leitura", true, false)
		if rolo == null:
			push_error("a captura pediu rolagem sem área de leitura")
			quit(1)
			return
		rolo.scroll_vertical = 100000
		for frame in range(3):
			await process_frame
	await RenderingServer.frame_post_draw
	var img := root.get_texture().get_image()
	if img.get_size() != Vector2i(720, 1280) or img.save_png(args[1]) != OK:
		push_error("a captura não gravou o quadro 720x1280")
		quit(1)
		return
	print("Paineis: %s" % painel.scene_file_path)
	print("Tempo: %s %s" % [painel.scene_file_path, painel.tempo])
	print("Tela salva em %s  (720x1280)" % args[1])
	quit(0)


func _avancar(gs: Node) -> void:
	if gs.phase == gs.ESTADO_OFERTA:
		gs.resolve_rival_offer(true)
	elif gs.phase == gs.ESTADO_COBRANCA:
		gs.pay_debt()
	else:
		while gs.atracagem_pendente() != Vector2i.ZERO:
			if not gs.atracar(0, false):
				break
		gs.advance_turn()
