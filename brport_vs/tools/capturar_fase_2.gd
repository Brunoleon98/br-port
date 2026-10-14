extends SceneTree

# A etapa 2 da `103` precisa de uma PARTIDA até ao cargueiro, não do porto
# montado pela bancada. Compra com o caixa ganho desde o dia 1, paga as três
# cobranças, toca nos painéis e avança pelo botão do Main, sem dias sob modal.
# Uso: --fixed-fps 60 --script res://tools/capturar_fase_2.gd -- pasta [construir]
var GS
var _main
var _frames := 0
var _passos := 0
var _assentar := -1
var _pasta := ""
var _construir := false
var _cargueiros := 0
var _modo := "porto"


func _process(_delta: float) -> bool:
	if _main == null:
		var args := OS.get_cmdline_user_args()
		_pasta = args[0]
		_construir = args.has("construir")
		for modo in ["meta", "diario", "livre", "suspenso"]:
			if args.has(modo):
				_modo = modo
		GS = root.get_node("GameState")
		GS.clear_save()
		GS._rng.seed = 20260902
		GS.new_game()
		GS.definir_nomes(GS.NOME_PORTO_PADRAO, "")
		GS.contrato_fechado.connect(_serviu)
		_main = load("res://scenes/Main.tscn").instantiate()
		root.add_child(_main)
		root.size = Vector2i(720, 1280)
		root.position = Vector2i.ZERO
		return false
	_frames += 1
	if _assentar >= 0:
		_assentar += 1
		if _assentar == 180:
			_fotografar()
		return false
	# Dois frames deixam correr a fila adiada do Main e a saída do painel.
	if _frames % 2 != 0:
		return false
	_passos += 1
	if _passos > 900 or GS.phase == GS.ESTADO_FIM:
		var cenas := []
		for p in _main.get_node("Overlay").get_children():
			cenas.append(p.scene_file_path)
		push_error("capturar_fase_2: não alcançou o alvo; dia %d, estado %s, painéis %s"
			% [GS.turn, GS.phase, cenas])
		quit(1)
		return false
	var overlay: Node = _main.get_node("Overlay")
	if overlay.get_child_count() > 0:
		var painel: Node = overlay.get_child(overlay.get_child_count() - 1)
		if _modo == "diario" and painel.scene_file_path == "res://scenes/panels/DiarioFase2.tscn":
			_assentar = 0
			return false
		if painel.scene_file_path.ends_with("CounterOfferPanel.tscn") and GS.phase == GS.ESTADO_OFERTA:
			painel._negociar("igualar")
			return false
		for botao in painel.find_children("*", "Button", true, false):
			if not botao.is_visible_in_tree() or botao.disabled:
				continue
			var texto: String = botao.text.to_lower()
			if texto.begins_with("não") or texto.begins_with("recusar") or texto == "jogar de novo":
				continue
			# O botão da folha fica no sítio enquanto vira. Não repetir o toque
			# na animação; ao acabar ele passa a dizer «Ver o balanço» (`104`).
			if painel.scene_file_path == "res://scenes/EndGame.tscn" \
					and painel._virando and texto.begins_with("virar"):
				return false
			botao.pressed.emit()
			return false
		return false
	if GS.phase == GS.ESTADO_OFERTA:
		GS.resolve_rival_offer(true)
		return false
	var ordem: Array = ["pier_2", "armazem", "patio"] if GS.numero_da_fase == 1 \
		else ["pier_2", "armazem", "patio", "trelica", "pier_3", "escritorio"]
	for id in ordem:
		if GS.comprar_estrutura(id):
			print("Compra jogada: %s, dia %d, caixa %d" % [id, GS.turn, GS.cash])
			break
	# Atraca pelo mesmo método do toque e conserva o barco sorteado. Depois
	# de um cargueiro atendido, a foto pede outro a trabalhar no segundo dia.
	var deixar_desistir: bool = _modo == "suspenso" and GS.tem_estrutura("pier_3") and _cargueiros > 0
	for _vaga in range(0 if deixar_desistir else GS.bercos_livres()):
		for i in range(GS.fila.size()):
			if GS.atracar(i, false):
				break
	var trabalha := false
	for d in GS.docks:
		if d["boat"] != null and d["boat"]["classe"] == "medio" \
				and int(d["boat"]["progress"]) == 1 and int(d["boat"]["op_turns"]) == 2:
			trabalha = true
	var alvo: bool = trabalha and _cargueiros > 0
	if _modo == "diario":
		alvo = false # Espera a página automática, pela vez do Main.
	elif _modo == "livre":
		alvo = GS.meta_concluida
	elif _modo == "suspenso":
		alvo = GS.cargueiros_suspensos()
	if GS.numero_da_fase == 2 and GS.tem_estrutura("trelica") and GS.tem_estrutura("pier_3") and alvo:
		print("PARTIDA ALCANCADA: dia %d, fase %d, porto %d, %d cargueiros atendidos, caixa %d"
			% [GS.turn, GS.numero_da_fase, GS.nivel_do_porto(), _cargueiros, GS.cash])
		if GS.has_meta(&"guindaste_intermediario_da_bancada"):
			push_error("capturar_fase_2: a compra não pode vir da meta da bancada")
			quit(1)
			return false
		if _construir:
			_main._on_upgrade_pressed()
		elif _modo in ["meta", "suspenso"]:
			var toque := InputEventMouseButton.new()
			toque.button_index = MOUSE_BUTTON_LEFT
			toque.pressed = false
			_main._on_meta_cartao_input(toque)
		_assentar = 0
		return false
	_main._advance_button.pressed.emit()
	_main._concluir_virada()
	return false


func _serviu(_valor: int, classe: String) -> void:
	if GS.numero_da_fase == 2 and classe == "medio":
		_cargueiros += 1


func _fotografar() -> void:
	var esperado := 1 if _construir or _modo in ["meta", "diario", "suspenso"] else 0
	var paineis: int = _main.get_node("Overlay").get_child_count()
	if paineis != esperado:
		push_error("capturar_fase_2: %d painéis, esperava %d" % [paineis, esperado])
		quit(1)
		return
	print("Overlay: %d painel(eis)  [fase %s, turno %d, %d estrutura(s)]"
		% [paineis, GS.phase, GS.turn, GS.estruturas.size()])
	var cenas := PackedStringArray()
	for p in _main.get_node("Overlay").get_children():
		cenas.append(p.scene_file_path)
	print("Paineis: %s" % (", ".join(cenas) if not cenas.is_empty() else "—"))
	var img: Image = root.get_texture().get_image()
	if img.get_size() != Vector2i(720, 1280):
		push_error("capturar_fase_2: captura fora de 720×1280")
		quit(1)
		return
	var nome := "construir_fase_2.png" if _construir else "porto_fase_2.png"
	if _modo != "porto":
		nome = _modo + "_fase_2.png"
	if img.save_png(_pasta.path_join(nome)) != OK:
		push_error("capturar_fase_2: não gravou a imagem")
		quit(1)
		return
	print("Tela salva em %s (%dx%d)" % [_pasta.path_join(nome), img.get_width(), img.get_height()])
	quit(0)
