extends SceneTree

# Fotos determinísticas das respostas do navegador: o copiador de bancada
# devolve sucesso/recusa pelo mesmo sinal que o backend real. Não toca na área
# de transferência de quem executa a captura (`128`).
class CopiadorDeBancada:
	extends Node
	signal concluida(sucesso: bool)
	var sucesso := false
	func copiar(_texto: String) -> void:
		concluida.emit(sucesso)

var _iniciado := false


func _process(_delta: float) -> bool:
	if not _iniciado:
		_iniciado = true
		_fotografar()
	return false


func _fotografar() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() != 2 or not args[0] in ["consulta", "copiado", "indisponivel"]:
		push_error("uso: capturar_diagnostico.gd -- <consulta|copiado|indisponivel> <saida.png>")
		quit(1)
		return
	# O fundo da inicial também aparece sob o escurecimento. Derivamos seus
	# espaços, em vez de herdar o que a captura anterior deixou no disco.
	var gs: Node = root.get_node("GameState")
	gs._rng.seed = 42
	for n in range(1, int(gs.ESPACOS) + 1):
		gs.apagar_espaco(n)
	gs.comecar_no_espaco(1)
	var inicio: Control = load("res://scenes/TelaInicial.tscn").instantiate()
	root.add_child(inicio)
	inicio._abrir_diagnostico()
	var painel = inicio.get_child(inicio.get_child_count() - 1)
	if args[0] != "consulta":
		painel.remove_child(painel._copiador)
		painel._copiador.queue_free()
		var copia := CopiadorDeBancada.new()
		copia.sucesso = args[0] == "copiado"
		painel._copiador = copia
		painel.add_child(copia)
		copia.concluida.connect(painel._ao_copiar)
		painel._copiar.pressed.emit()
	for frame in range(5):
		root.size = Vector2i(720, 1280)
		await process_frame
	if String(painel.tempo) != args[0]:
		push_error("a captura não alcançou a resposta pedida")
		quit(1)
		return
	await RenderingServer.frame_post_draw
	var imagem := root.get_texture().get_image()
	var erro := imagem.save_png(args[1])
	if erro != OK:
		push_error("não foi possível guardar a captura")
		quit(1)
		return
	print("Paineis: ", painel.scene_file_path)
	print("Tempo: ", painel.tempo)
	print("Tela salva em ", args[1], " (", imagem.get_width(), "x", imagem.get_height(), ")")
	quit(0)
