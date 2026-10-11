extends SceneTree
## O custo por quadro do jogo aberto — chamadas de desenho, nós e o tempo de
## cada `_process` —, para pôr ao lado do FPS que o Bruno mede no telefone
## (M11, `docs/decisoes/099`).
##
##   xvfb-run -a $G --path brport_vs --resolution 720x1280 \
##     --rendering-driver opengl3 --script res://tools/medir_desempenho.gd
##
## Espera-se `DESEMPENHO MEDIDO`. Mede DOIS estados, porque o porto do dia 1
## é o mais vazio que o jogo tem: a abertura (o mapa do dia 1, com os nomes já
## dados) e o meio da partida, que é o save de exemplo da versão corrente
## (`tests/saves/vNN.json`, jogado até ter obra, fila e barco atracado, `098`).
##
## ⚠️ O TEMPO DE QUADRO DO MOTOR NÃO SE LÊ NESTE CONTÊINER, e foram as duas
## primeiras tentativas da revisão de 09/10 (N9, `REVISAO_GERAL_2026-10-09.md`):
##  - sob `xvfb-run`, o `Performance.TIME_PROCESS` inclui o DESENHO, que aqui é
##    por software, e deu 86 ms — mede o rasterizador, não o jogo;
##  - em `--headless`, o laço dorme até 6,9 ms por quadro (o sono do modo de
##    baixo consumo), com e sem o `Main` aberto, e devolve o mesmo número nos
##    dois casos.
## O que se cronometra aqui é a chamada DIRETA de cada `_process`, em laço. O
## FPS e o aquecimento medem-se no telefone, e quem os mede é o Bruno. Os
## tweens CONTAM-SE e não se cronometram: quem os anda é o motor.
##
## ⚠️ E AS DUAS RÉGUAS CALIBRAM-SE ANTES DE MEDIR, como a da VRAM (`049`),
## porque aqui um zero leria como «de graça»:
##  - a do desenho põe na tela sprites de textura própria, que não se juntam
##    num lote, e exige que o monitor os conte (medido: doze dão 12,0; com a
##    MESMA textura, 1,0). Em `--headless` o motor não desenha e o monitor dá
##    0: a régua recusa-se em vez de o publicar;
##  - a do tempo cronometra uma sonda cujo `_process` espera um tempo sabido
##    de cor, e exige lê-lo de volta. Um laço que chamasse a função errada, ou
##    dividisse pelo número errado, daria um número plausível para tudo.
##
## ⚠️ E TEMPO COMPARA-SE EMPARELHADO (`gerais.md`): a mesma máquina deriva 20%
## entre a manhã e a tarde. Quem compara duas versões corre as duas seguidas.
## As chamadas de desenho e os nós não derivam — dependem do que está na tela.

const QUADROS_ATE_ASSENTAR := 28
const QUADROS_AMOSTRA := 60
const CAL_SPRITES := 12
const SONDA_US := 200
const CHAMADAS_POR_RODADA := 400
const RODADAS := 5
const DELTA := 1.0 / 60.0

var _comecou := false
var _gs: Node


func _process(_delta: float) -> bool:
	# `false` sempre: quem encerra é o `quit()`. Um `true` mataria a árvore no
	# fim do frame e os `await` de `_correr()` nunca voltariam (`gdscript.md`).
	if not _comecou:
		_comecou = true
		_correr()
	return false


func _correr() -> void:
	_gs = root.get_node("GameState")
	await _quadros(2)
	if not await _calibrar_desenho() or not await _calibrar_tempo():
		quit(1)
		return

	_gs.clear_save()
	_gs._rng.seed = 12345
	_gs.new_game()
	_resolver_oferta()
	# Com os nomes dados, o `Main` abre no mapa e não no caderno: o que se mede
	# é a tela onde se joga, e o caderno só aparece uma vez por partida.
	_gs.definir_nomes("Cais Mirim", "")
	if not await _medir("abertura: o mapa do dia 1"):
		quit(1)
		return

	var versao: int = _gs.SAVE_VERSION
	var exemplo := "res://tests/saves/v%d.json" % versao
	if not FileAccess.file_exists(exemplo):
		push_error("medir_desempenho: falta %s — o F21 do teste_fumaca diz como o gravar" % exemplo)
		quit(1)
		return
	var f := FileAccess.open(_gs.save_path, FileAccess.WRITE)
	f.store_string(FileAccess.get_file_as_string(exemplo))
	f.close()
	if not _gs.load_game():
		push_error("medir_desempenho: o load_game() recusou %s" % exemplo)
		quit(1)
		return
	_resolver_oferta()
	var turno: int = _gs.turn
	if not await _medir("meio da partida: o exemplo v%d, dia %d" % [versao, turno]):
		quit(1)
		return

	print("=== DESEMPENHO MEDIDO ===")
	quit(0)


func _resolver_oferta() -> void:
	# Uma oferta pendente abre o painel do Arlindo por cima do mapa, e a medida
	# passaria a ser a do painel (`testes-e-guardas.md`, «teste que joga»).
	if _gs.phase == "rival_offer":
		_gs.resolve_rival_offer(true)


func _quadros(n: int) -> void:
	for i in n:
		await process_frame


# A média de chamadas de desenho em `n` quadros. O monitor responde pelo
# quadro ANTERIOR, e por isso se lê depois de esperar.
func _desenho_medio(n: int) -> float:
	var soma := 0.0
	for i in n:
		await process_frame
		soma += Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
	return soma / n


func _calibrar_desenho() -> bool:
	var antes: float = await _desenho_medio(10)
	var sprites: Array[Sprite2D] = []
	for i in CAL_SPRITES:
		var img := Image.create_empty(8, 8, false, Image.FORMAT_RGBA8)
		img.fill(Color.WHITE)
		var sp := Sprite2D.new()
		sp.texture = ImageTexture.create_from_image(img)
		sp.position = Vector2(40 + 50 * i, 40)
		root.add_child(sp)
		sprites.append(sp)
	await _quadros(3)
	var depois: float = await _desenho_medio(10)
	for sp in sprites:
		sp.queue_free()
	await _quadros(3)
	var visto := depois - antes
	print("Calibração do desenho: %d sprites de textura própria, %.1f chamadas a mais no monitor"
		% [CAL_SPRITES, visto])
	if visto < CAL_SPRITES:
		push_error("medir_desempenho: o monitor não contou os %d sprites de calibração "
			% CAL_SPRITES + "— corra com xvfb-run e --rendering-driver opengl3")
		return false
	return true


func _calibrar_tempo() -> bool:
	var codigo := GDScript.new()
	codigo.source_code = (
		"extends Node\nvar us := 0\nfunc _process(_d: float) -> void:\n"
		+ "\tvar t := Time.get_ticks_usec()\n\twhile Time.get_ticks_usec() - t < us:\n\t\tpass\n")
	if codigo.reload() != OK:
		push_error("medir_desempenho: a sonda do tempo não compilou")
		return false
	var sonda := Node.new()
	sonda.set_script(codigo)
	sonda.set("us", SONDA_US)
	root.add_child(sonda)
	var lido := _custo_us(sonda)
	sonda.queue_free()
	await _quadros(1)
	print("Calibração do tempo: sonda de %d µs por chamada, lida a %.1f µs" % [SONDA_US, lido])
	# Espera ocupada não fica abaixo do pedido; acima, só o preço da chamada e
	# uma ou outra preempção, que a mediana das rodadas já apara.
	if lido < SONDA_US or lido > SONDA_US * 1.5:
		push_error("medir_desempenho: a sonda de %d µs foi lida a %.1f — o laço não mede o que chama"
			% [SONDA_US, lido])
		return false
	return true


# Microssegundos por chamada do `_process` de `no`: a mediana de RODADAS
# rodadas de CHAMADAS_POR_RODADA. Chamar avança o estado do nó como quadros a
# mais, o que é o que o jogo faria com ele.
#
# `no` DESTIPADO E A CHAMADA DIRETA, de propósito: o nome escrito numa string
# (`call`, `has_method`) é o que o F19 do `teste_fumaca` pede declarado contra
# um alvo, e aqui o receptor é qualquer nó (`093`). A chamada direta num
# destipado grita se o nome faltar, que é o que o F19 protege.
func _custo_us(no) -> float:
	var rodadas: Array[float] = []
	for r in RODADAS:
		var t0 := Time.get_ticks_usec()
		for i in CHAMADAS_POR_RODADA:
			no._process(DELTA)
		rodadas.append(float(Time.get_ticks_usec() - t0) / CHAMADAS_POR_RODADA)
	rodadas.sort()
	return rodadas[RODADAS / 2]


# O motor liga o processamento sozinho a quem define `_process`; um nó que o
# ligasse à mão sem o definir faria a chamada direta gritar, e não somar zero.
func _com_process(no: Node, achados: Array) -> void:
	if no.get_script() != null and no.is_processing():
		achados.append(no)
	for filho in no.get_children():
		_com_process(filho, achados)


func _medir(nome: String) -> bool:
	var cena: PackedScene = load("res://scenes/Main.tscn")
	if cena == null:
		push_error("medir_desempenho: Main.tscn não carregou")
		return false
	var main := cena.instantiate()
	root.add_child(main)
	await _quadros(QUADROS_ATE_ASSENTAR)
	# O estado declara-se «o mapa», e prova-se: um painel aberto por cima dele
	# (o caderno, uma oferta, um boletim) mudaria o que se conta, e as linhas
	# sairiam plausíveis sobre outra tela (`interface.md`). Os painéis vivem no
	# `Overlay` do `Main`, que é onde a captura também os conta.
	var overlay := main.get_node_or_null("Overlay")
	if overlay == null or overlay.get_child_count() > 0:
		push_error("medir_desempenho: %s — o mapa não está sozinho na tela (%s)"
			% [nome, "sem Overlay" if overlay == null
				else ", ".join(overlay.get_children().map(func(p): return p.scene_file_path))])
		return false

	var chamadas: Array[float] = []
	var objetos := 0.0
	var primitivas := 0.0
	for i in QUADROS_AMOSTRA:
		await process_frame
		chamadas.append(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
		objetos += Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)
		primitivas += Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)
	var nos := int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))
	var tweens := get_processed_tweens().size()

	var achados: Array = []
	_com_process(root, achados)
	var por_script := {}
	for no in achados:
		var caminho: String = (no.get_script() as Script).resource_path
		if not por_script.has(caminho):
			por_script[caminho] = [0, 0.0]
		por_script[caminho][0] += 1
		por_script[caminho][1] += _custo_us(no)

	print("")
	print("== %s ==" % nome)
	var soma := 0.0
	for c in chamadas:
		soma += c
	print("Chamadas de desenho por quadro: %.1f (mín %d, máx %d, em %d quadros)"
		% [soma / chamadas.size(), int(chamadas.min()), int(chamadas.max()), chamadas.size()])
	print("Objetos desenhados por quadro: %.1f · primitivas: %.1f"
		% [objetos / QUADROS_AMOSTRA, primitivas / QUADROS_AMOSTRA])
	print("Nós na árvore: %d · tweens vivos: %d" % [nos, tweens])
	print("Script por quadro (chamada direta, mediana de %d rodadas de %d):"
		% [RODADAS, CHAMADAS_POR_RODADA])
	var total := 0.0
	var caminhos := por_script.keys()
	caminhos.sort()
	for caminho in caminhos:
		var n: int = por_script[caminho][0]
		var us: float = por_script[caminho][1]
		total += us
		print("  %.4f ms  %s%s" % [us / 1000.0, caminho, " ×%d" % n if n > 1 else ""])
	print("  %.4f ms  total" % (total / 1000.0))

	main.queue_free()
	await _quadros(3)
	# A amostra vazia lê-se como «o script não custa nada». O `Main` tem
	# `_process`; se a varredura não o achou, quem está errado é ela.
	if not por_script.has("res://scripts/Main.gd"):
		push_error("medir_desempenho: a varredura não achou o _process do Main")
		return false
	return true
