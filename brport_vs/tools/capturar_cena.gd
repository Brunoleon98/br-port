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

# O ponto único de estilo do projeto. Ver ui/tema_brport.tres.
const TEMA := "res://ui/tema_brport.tres"

var _cena := "res://scenes/tests/AssetPlacementTest.tscn"
var _saida := "user://cena.png"
var _montado := false
var _frames := 0
# Argumentos extra, entregues a `setup()` da cena quando ela tiver um.
var _extra: Array = []


func _process(_delta: float) -> bool:
	if not _montado:
		_montado = true
		_ler_argumentos()
		if not ResourceLoader.exists(_cena):
			push_error("cena não encontrada: %s" % _cena)
			quit(1)
			return true
		var no: Node = load(_cena).instantiate()
		# O TEMA TEM DE SER APLICADO À MÃO AQUI. No jogo quem o põe é o
		# `_abrir_painel()` do Main; uma cena instanciada solta nasce sem tema
		# nenhum e o Godot desenha-a com o estilo padrão — cinzento sobre
		# cinzento. A fotografia sai "funcionando" e não se parece nada com o
		# que o jogador vê, que é a pior espécie de captura: a que dá confiança
		# sem dar informação. Medido ao fotografar o Diário do Porto.
		if no is Control:
			(no as Control).theme = load(TEMA)
		root.add_child(no)
		_chamar_setup(no)
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


# Vários painéis do jogo só existem depois de alguém lhes chamar `setup()` —
# a cena da parcela precisa do valor, a de fim de fase precisa de saber se se
# ganhou. Instanciadas sem isso ficam VAZIAS, e a captura sai um retângulo em
# branco que passa por "a cena abre" sem mostrar nada do que se queria ver.
#
# Os argumentos extra da linha de comando são passados a `setup()` em ordem.
# São convertidos por forma: "true"/"false" viram bool e o que for só dígitos
# vira int, porque `setup(won: bool, ...)` recusa a String "true".
func _chamar_setup(no: Node) -> void:
	if _extra.is_empty() or not no.has_method("setup"):
		return
	var convertidos := []
	for bruto in _extra:
		if bruto == "true" or bruto == "false":
			convertidos.append(bruto == "true")
		elif bruto.is_valid_int():
			convertidos.append(int(bruto))
		else:
			convertidos.append(bruto)
	no.callv("setup", convertidos)


func _ler_argumentos() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		_cena = args[0]
	if args.size() > 1:
		_saida = args[1]
	if args.size() > 2:
		_extra = args.slice(2)
