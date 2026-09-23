extends SceneTree
## A memória de textura do jogo aberto, como o motor a declara.
##
##   xvfb-run -a $G --path brport_vs --resolution 720x1280 \
##     --rendering-driver opengl3 --script res://tools/medir_vram.gd
##
## Espera-se `VRAM MEDIDA`. É a régua que mediu o corte do quadro dos props
## (`docs/decisoes/049`): 235,68 MB antes, 64,04 MB depois. Precisa de contexto
## gráfico — em `--headless` o motor não aloca textura nenhuma e o monitor dá 0.
##
## ⚠️ O MONITOR NÃO CONTA `w×h×4`. Medido em 23/09 com uma sonda de UMA textura,
## onde a resposta se sabe de cor: um prop de 768² em RGBA8 são 2,25 MB e o
## monitor deu 3,00 — 4/3. A primeira leitura da `049` não fechava por causa
## disto (180 MB para 155 de conta). Por isso esta régua CALIBRA-SE antes de
## medir: cria uma textura de tamanho conhecido e imprime a razão que o motor
## aplica, em vez de a supor.
##
## ⚠️ E A BASE NÃO É ZERO. Um autoload chega ao `Retratos.gd`, que faz
## `preload` dos nove retratos de fala — eles já estão na VRAM antes de o `Main`
## abrir, e um delta tirado depois deles mente por omissão. A régua imprime a
## base E o total; quem comparar duas versões compara o TOTAL, emparelhado.

const FRAMES_ATE_ASSENTAR := 28
const LADO_CALIBRACAO := 256

var _f := 0
var _base := 0.0
var _calibracao: ImageTexture = null
var _antes_calibracao := 0.0


func _process(_delta: float) -> bool:
	_f += 1
	if _f == 2:
		_antes_calibracao = _mem()
		var img := Image.create_empty(LADO_CALIBRACAO, LADO_CALIBRACAO, false,
			Image.FORMAT_RGBA8)
		_calibracao = ImageTexture.create_from_image(img)
	elif _f == 4:
		var medido := _mem() - _antes_calibracao
		var conta := float(LADO_CALIBRACAO * LADO_CALIBRACAO * 4)
		print("Calibração: textura %dx%d RGBA8 = %d B de conta, %d B no monitor "
			% [LADO_CALIBRACAO, LADO_CALIBRACAO, int(conta), int(medido)]
			+ "(razão %.3f)" % (medido / conta))
		if medido <= 0.0:
			# Sem contexto gráfico o motor não aloca nada, e tudo o que viesse a
			# seguir seria um zero a passar por medida.
			push_error("medir_vram: o monitor não viu a textura de calibração "
				+ "— corra com xvfb-run e --rendering-driver opengl3")
			quit(1)
			return false
		# Liberta-a antes da base, senão ela entra no total e o número deixa de
		# se comparar com os da `049`, que foram medidos sem ela.
		_calibracao = null
	elif _f == 6:
		_base = _mem()
		var gs: Node = root.get_node("GameState")
		gs.clear_save()
		gs._rng.seed = 12345
		gs.new_game()
		root.add_child(load("res://scenes/Main.tscn").instantiate())
	elif _f == 6 + FRAMES_ATE_ASSENTAR:
		var total := _mem()
		print("Textura antes do Main: %.2f MB (inclui os retratos, por preload)"
			% (_base / 1048576.0))
		print("Textura com o Main aberto: %.2f MB" % (total / 1048576.0))
		print("Vídeo com o Main aberto: %.2f MB" % (
			Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1048576.0))
		print("=== VRAM MEDIDA ===")
		quit(0)
	return false


func _mem() -> float:
	return Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED)
