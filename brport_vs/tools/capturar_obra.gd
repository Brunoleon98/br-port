extends SceneTree

# ============================================================
# BR Port VS — a foto de um DIA DE OBRA no jogo (`docs/decisoes/122`)
# Ferramenta de apoio. NÃO faz parte do jogo.
#
# Monta o porto com a obra pedida em andamento no quadro pedido e fotografa
# a tela. Existe porque nenhuma outra ferramenta alcança esse estado: a
# `prancha_prop.gd` joga 16 turnos à espera de ver o prop e reprova («não
# teve foto do jogo em 16 turnos») — o pátio só abre depois da primeira
# cobrança (`085`), e a obra só dura dois ou três dias (`087`) —, e a bateria
# fotografa um dia de obra só, o do píer, com o painel Construir por cima.
#
# Uso (Linux, sem monitor):
#   xvfb-run -a Godot --path brport_vs --resolution 720x1280 \
#     --rendering-driver opengl3 --fixed-fps 60 \
#     --script res://tools/capturar_obra.gd -- <saida.png> <obra> <quadro> [no=png ...]
#
# `obra` é `pier_2`, `armazem` ou `patio`, e `quadro` é o dia jogado da obra
# a contar de 0. Cada `no=png` troca a textura de um nó do `Main` pela de um
# PNG lido do ARQUIVO, para fotografar uma candidata no mesmo estado — por
# exemplo `MapaWrap/Cenario/CanteiroDoPatio=/tmp/cand/patio_obra_1.png` ou
# `MapaWrap/Docas/Doca1/Pier=...` (o píer 2 é a `Doca1`).
#
# ⚠️ A OBRA ESCREVE-SE COMO O `comprar_estrutura()` A ESCREVE, com o início
# recuado `quadro` dias: é o `quadro_da_obra()` que decide o que cada nó
# mostra, e o `Main` monta depois, já com ela no estado. O porto à volta é o
# de uma partida semeada jogada oito dias, com as obras de antes da pedida
# montadas pela bancada (`estado_da_bancada.gd`): o armazém tem o píer 2, o
# pátio tem os dois. Não é uma partida que alguém jogue assim — é a obra no
# sítio dela, com os vizinhos de verdade.
#
# ⚠️ E O `--fixed-fps 60` FAZ PARTE DO USO: sem ele duas fotos do mesmo
# estado não se comparam (`.claude/rules/captura.md`).
# ============================================================

const SEMENTE := 20260902
const DIAS_ANTES := 8
const FRAMES_ATE_TROCAR := 5
const FRAMES_ATE_DISPARAR := 60

var GS
var _main: Control
var _frames := 0
var _saida := ""
var _obra := ""
var _quadro := 0
var _trocas := {}


func _process(_delta: float) -> bool:
	if _main == null:
		if not _montar():
			quit(1)
		return false
	_frames += 1
	if _frames == FRAMES_ATE_TROCAR:
		for no in _trocas:
			var alvo: TextureRect = _main.get_node_or_null(no)
			var img := Image.load_from_file(String(_trocas[no]))
			if alvo == null or img == null:
				push_error("capturar_obra: não troco '%s' por '%s'" % [no, _trocas[no]])
				quit(1)
				return false
			alvo.texture = ImageTexture.create_from_image(img)
	if _frames < FRAMES_ATE_DISPARAR:
		return false
	print("Obra %s no quadro %d, dia %d" % [_obra,
		int(GS.quadro_da_obra(_obra, 3)), int(GS.turn)])
	root.get_viewport().get_texture().get_image().save_png(_saida)
	print("Tela salva em %s" % _saida)
	quit(0)
	return false


func _montar() -> bool:
	var args := OS.get_cmdline_user_args()
	if args.size() < 3 or not str(args[2]).is_valid_int():
		push_error("capturar_obra: uso -- <saida.png> <obra> <quadro> [no=png ...]")
		return false
	_saida = str(args[0])
	_obra = str(args[1])
	_quadro = int(args[2])
	for extra in args.slice(3):
		var par: PackedStringArray = str(extra).split("=", true, 1)
		_trocas[par[0]] = par[1]
	GS = root.get_node("GameState")
	if not GS.ESTRUTURAS.has(_obra):
		push_error("capturar_obra: não há obra '%s'" % _obra)
		return false
	for n in range(2, GS.ESPACOS + 1):
		GS.apagar_espaco(n)
	GS._rng.seed = SEMENTE
	GS.comecar_no_espaco(1)
	GS.definir_nomes(GS.NOME_PORTO_PADRAO, "")
	var bancada = load("res://tools/estado_da_bancada.gd")
	GS.cash += 600000
	if _obra != "pier_2":
		bancada.instalar(GS, "pier_2")
	if _obra == "patio":
		bancada.instalar(GS, "armazem")
	for i in range(DIAS_ANTES + 1):
		if GS.phase == "rival_offer":
			GS.resolve_rival_offer(true)
		while GS.atracagem_pendente() != Vector2i.ZERO:
			if not GS.atracar(0):
				break
		if i < DIAS_ANTES:
			GS.advance_turn()
	var t := int(GS.turn)
	GS.obra_em_andamento = {"id": _obra, "inicio": t - _quadro,
		"conclusao": t - _quadro + int(GS.dias_da_obra(_obra))}
	_main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(_main)
	return true
