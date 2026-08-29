extends SceneTree

# ============================================================
# BR Port VS — captura de tela
# Ferramenta de apoio. NÃO faz parte do jogo.
#
# Monta a cena real, joga alguns turnos e salva um PNG. Serve para olhar a
# interface sem abrir o editor — útil no Bloco 4, quando cada asset novo
# precisa ser conferido na tela e não só no papel.
#
# Uso (Linux, sem monitor — precisa de xvfb):
#   xvfb-run -a Godot --path brport_vs --resolution 720x1280 \
#     --rendering-driver opengl3 --script res://tools/capturar_tela.gd -- [turnos] [saida.png]
#
# No Windows, com monitor, dispensa o xvfb:
#   Godot_v4.6.3-stable_win64.exe --path . --resolution 720x1280 \
#     --script res://tools/capturar_tela.gd -- 10 tela.png
#
# `turnos` avança a partida antes de fotografar (0 = tela inicial), e a
# oferta do rival é resolvida para a tela sair limpa. Para fotografar o
# PAINEL da contra-oferta em vez da tela principal, use --  0  e rode com
# uma semente que abra oferta no primeiro turno.
# ============================================================

const TURNOS_PADRAO := 10
const SAIDA_PADRAO := "user://tela.png"
const FRAMES_ATE_ASSENTAR := 15

var GS
var _main: Control
var _montado := false
var _frames := 0
var _saida := SAIDA_PADRAO


func _process(_delta: float) -> bool:
	if not _montado:
		_montado = true
		_montar()
		return false

	# Alguns frames antes de fotografar: containers só calculam o layout
	# depois de um ciclo, e a foto sai com tudo empilhado no canto se for tirada
	# no primeiro frame.
	_frames += 1
	if _frames < FRAMES_ATE_ASSENTAR:
		if GS.phase == "rival_offer":
			GS.negotiate_rival("igualar")
			_fechar_painel_do_rival()
		return false

	var img: Image = root.get_texture().get_image()
	var erro := img.save_png(_saida)
	if erro != OK:
		print("FALHOU ao salvar em %s (erro %d)" % [_saida, erro])
		quit(1)
		return true
	print("Tela salva em %s (%dx%d)" % [_saida, img.get_width(), img.get_height()])
	quit(0)
	return true


func _montar() -> void:
	GS = root.get_node("GameState")

	var args := OS.get_cmdline_user_args()
	var turnos := TURNOS_PADRAO
	if args.size() >= 1 and args[0].is_valid_int():
		turnos = int(args[0])
	if args.size() >= 2:
		_saida = args[1]

	GS.clear_save()
	GS.new_game()
	_main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(_main)

	for t in range(turnos):
		if GS.phase == "rival_offer":
			GS.negotiate_rival("metade")
			_fechar_painel_do_rival()
			continue
		if GS.phase != "playing":
			break
		_alocar_todos()
		GS.advance_turn()


# Resolver a oferta direto no GameState NÃO fecha o painel: quem o fecha é o
# próprio painel, quando é ele que chama negotiate_rival(). Sem isto a foto sai
# sempre com o modal por cima e o mapa escurecido pelo dim — que era exatamente
# o que se queria fotografar.
#
# Só o painel da contra-oferta é fechado (é o único que carrega `dock_index`):
# as telas de fim de jogo e da parcela continuam fotografáveis.
func _fechar_painel_do_rival() -> void:
	if _main == null:
		return
	var overlay := _main.get_node_or_null("Overlay")
	if overlay == null:
		return
	for painel in overlay.get_children():
		if "dock_index" in painel:
			overlay.remove_child(painel)
			painel.queue_free()


func _alocar_todos() -> void:
	for w in GS.workers:
		var wid := int(w["id"])
		if int(w["busy_turns"]) > 0 or GS.worker_dock_index(wid) >= 0:
			continue
		for i in range(GS.docks.size()):
			var doca = GS.docks[i]
			if doca["boat"] == null or doca["worker_id"] != null:
				continue
			var barco = doca["boat"]
			if barco.get("rival", false) and not barco.get("matched", false):
				continue
			if GS.assign_worker(wid, i):
				break
