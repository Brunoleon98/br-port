extends SceneTree

# ============================================================
# BR Port VS — captura de UMA CENA QUALQUER
# Ferramenta de apoio. NÃO faz parte do jogo.
#
# `capturar_tela.gd` fotografa o jogo: monta o Main, joga turnos, resolve a
# oferta do rival. Isso é o que se quer para a tela do jogo e é exatamente o
# que atrapalha para fotografar uma bancada de teste, que não tem partida
# nenhuma. Daí esta segunda ferramenta, que só instancia uma cena e espera.
#
# Uso (Linux, sem monitor — precisa de xvfb):
#   xvfb-run -a Godot --path brport_vs --resolution 720x1280 \
#     --rendering-driver opengl3 --script res://tools/capturar_cena.gd -- \
#     res://scenes/tests/AssetPlacementTest.tscn foto.png
#
# Teste verde não prova que ficou bonito. É para isto que ela existe.
# ============================================================

const FRAMES_ATE_ASSENTAR := 12

var _cena := "res://scenes/tests/AssetPlacementTest.tscn"
var _saida := "user://cena.png"
var _montado := false
var _frames := 0


func _process(_delta: float) -> bool:
	if not _montado:
		_montado = true
		_ler_argumentos()
		if not ResourceLoader.exists(_cena):
			push_error("cena não encontrada: %s" % _cena)
			quit(1)
			return true
		var no: Node = load(_cena).instantiate()
		root.add_child(no)
		return false

	# Alguns frames antes de fotografar: um Sprite2D só tem textura resolvida
	# depois de o recurso terminar de carregar, e um Label só mede o texto
	# depois do primeiro layout.
	_frames += 1
	if _frames < FRAMES_ATE_ASSENTAR:
		return false

	var img := root.get_texture().get_image()
	var erro := img.save_png(_saida)
	if erro != OK:
		push_error("falhou ao gravar %s (erro %d)" % [_saida, erro])
		quit(1)
		return true
	print("captura: %s  (%dx%d)" % [_saida, img.get_width(), img.get_height()])
	quit(0)
	return true


func _ler_argumentos() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		_cena = args[0]
	if args.size() > 1:
		_saida = args[1]
