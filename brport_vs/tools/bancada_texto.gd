extends SceneTree

# Protótipo por --script, excluído dos exports. Não acrescenta preferência
# ao jogo nem grava apresentacao.cfg; os três fatores são candidatos medidos.
var _iniciado := false
var _frames := 0
var _gs: Node
var _tela: Control
var _painel: Control
var _medidor: Script
var _saida := ""
var _capturar := false
var _cenario := ""
var _fator := 1.0


func _process(_delta: float) -> bool:
	_frames += 1
	if not _iniciado:
		_iniciado = true
		_rodar()
	if _frames > 1200:
		push_error("bancada de texto não concluiu em 1200 quadros")
		quit(1)
	return false


func _rodar() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() < 3 or args[0] not in ["ajustes-inicio", "ajustes-pausa", "artigo", "hud", "doca", "calibracao"]:
		push_error("uso: bancada_texto.gd -- <cenario> <1|1.25|1.5> <saida-base> [capturar]")
		quit(1)
		return
	_cenario = args[0]
	_fator = float(args[1])
	_saida = args[2]
	_capturar = args.size() > 3 and args[3] == "capturar"
	if _fator not in [1.0, 1.25, 1.5] or not ArmazemLocal.sob_ferramenta():
		push_error("a bancada exige --script e um dos três fatores declarados")
		quit(1)
		return
	root.size = Vector2i(720, 1280)
	_medidor = load("res://tools/medir_texto_bancada.gd")
	_gs = root.get_node("GameState")
	root.get_node("Registro").desarmar()
	_gs._rng.seed = 42
	for n in range(1, int(_gs.ESPACOS) + 1):
		_gs.apagar_espaco(n)
	_gs.comecar_no_espaco(1)
	_gs.definir_nomes("Cais da leitura", "Bancada")
	if _gs.phase == _gs.ESTADO_OFERTA:
		_gs.resolve_rival_offer(true)
	# O mesmo fundo parado em todos os candidatos. A escolha é só em memória,
	# antes de montar os nós, sem tocar na preferência persistente do RB6.
	PreferenciasDeApresentacao.atual().reduzir_movimento = true
	await _montar()
	await _esperar(8)
	if _cenario == "calibracao":
		for rotulo in _tela.get_children():
			rotulo.size = Vector2(100, 60)
	var apoio: RefCounted = load("res://tests/casos_meu_porto.gd").new()
	apoio.gs = _gs
	apoio.arvore = self
	var antes: Dictionary = apoio.fotografia()
	var areas_originais: Array = _areas()
	var alvo: Control = _painel if _painel != null else _tela
	var fontes: Array = _medidor.aplicar(alvo, _fator)
	await _esperar(12)
	var medicao: Dictionary = _medidor.medir(alvo)
	# Os retângulos originais e os atuais ficam lado a lado: um contentor pode
	# alargar-se para caber na letra e invadir o vizinho sem cortar o Label.
	medicao["areas"] = _areas()
	medicao["areas_originais"] = areas_originais
	var rolos: Array = []
	for no in _descendentes(_tela):
		if no is ScrollContainer:
			var barra: VScrollBar = no.get_v_scroll_bar()
			rolos.append({"no": str(_tela.get_path_to(no)), "altura": no.size.y,
				"conteudo": barra.max_value, "pagina": barra.page})
	medicao["rolagem"] = rolos
	if _capturar:
		await _salvar(_saida + ".png")
		if _cenario == "artigo":
			_painel._rolo.scroll_vertical = int(_painel._rolo.get_v_scroll_bar().max_value)
			await _esperar(5)
			await _salvar(_saida + "_fim.png")
	var depois: Dictionary = apoio.fotografia()
	var manifesto := {"cenario": _cenario, "fator": _fator,
		"semente": 42, "fps_fixo": 60, "janela": [720, 1280],
		"movimento_reduzido_em_memoria": true, "persistencia_rb5": false,
		"mesmo_estado_apos_ampliar": antes == depois,
		"turno": _gs.turn, "caixa": _gs.cash, "rng": str(_gs._rng.state),
		"alvo": "painel" if _painel != null else "interface_do_porto",
		"fontes": fontes, "medicao": medicao}
	# Reaplicar o mesmo fator e voltar ao padrão exercita a base, sem usar
	# uma nova cena para esconder acumulação de escala no mesmo nó.
	manifesto["fontes_reaplicadas"] = _medidor.aplicar(alvo, _fator)
	manifesto["fontes_restauradas"] = _medidor.aplicar(alvo, 1.0)
	var arquivo := FileAccess.open(_saida + ".json", FileAccess.WRITE)
	if arquivo == null:
		push_error("não foi possível escrever o manifesto da bancada")
		quit(1)
		return
	arquivo.store_string(JSON.stringify(manifesto, "\t"))
	arquivo.close()
	print("BANCADA TEXTO MEDIDA ", _cenario, " fator=", _fator,
		" textos=", medicao["quantidade"], " estado_igual=", antes == depois)
	root.get_node("Registro").desarmar()
	quit(0)


func _montar() -> void:
	if _cenario == "calibracao":
		_tela = Control.new()
		_tela.theme = load("res://ui/tema_brport.tres")
		root.add_child(_tela)
		_tela.size = Vector2(720, 1280)
		for i in 2:
			var rotulo := Label.new()
			rotulo.name = "Cabe" if i == 0 else "Transborda"
			rotulo.text = "OK" if i == 0 else "WWWWWWWWWWWWWWWWWWWW"
			rotulo.position = Vector2(20, 20 + 80 * i)
			rotulo.clip_text = true
			rotulo.size = Vector2(100, 60)
			rotulo.add_theme_font_size_override("font_size", 19)
			_tela.add_child(rotulo)
		return
	if _cenario == "ajustes-inicio":
		_tela = load("res://scenes/TelaInicial.tscn").instantiate()
		root.add_child(_tela)
		_tela._abrir_ajustes()
		_painel = _buscar_painel(_tela, "PainelAjustes.gd")
		_inserir_amostra()
		return
	_tela = load("res://scenes/Main.tscn").instantiate()
	root.add_child(_tela)
	await _esperar(3)
	_tela._concluir_virada()
	for painel in _tela._overlay_layer.get_children():
		painel.queue_free()
	await _esperar(3)
	if _cenario == "ajustes-pausa":
		_tela._on_pause_pressed()
		_tela._abrir_ajustes()
		_painel = _buscar_painel(_tela, "PainelAjustes.gd")
		_inserir_amostra()
	elif _cenario == "artigo":
		_painel = load("res://scenes/panels/PainelComoJogar.tscn").instantiate()
		_painel.theme = load("res://ui/tema_brport.tres")
		_tela._overlay_layer.add_child(_painel)
		var maior := ""
		var tamanho := 0
		for artigo in _painel.artigos:
			if String(artigo["texto"]).length() > tamanho:
				tamanho = String(artigo["texto"]).length()
				maior = String(artigo["id"])
		_painel._mostrar(maior)
	elif _cenario == "doca":
		_montar_pior_cartao()


func _inserir_amostra() -> void:
	# Só a instância da bancada recebe estes controles. O jogo exportado e o
	# apresentacao.cfg continuam sem tamanho de texto até o tamanho ser escolhido.
	var titulo := Label.new()
	titulo.text = "Tamanho do texto — bancada"
	var indice := 0
	for filho in _painel._vbox.get_children():
		if filho is Label and filho.text == "APRESENTAÇÃO":
			indice = filho.get_index() + 1
	_painel._vbox.add_child(titulo)
	_painel._vbox.move_child(titulo, indice)
	var modos := HBoxContainer.new()
	modos.name = "CandidatosDeTexto"
	_painel._vbox.add_child(modos)
	_painel._vbox.move_child(modos, indice + 1)
	for valor in [1.0, 1.25, 1.5]:
		var botao := Button.new()
		botao.text = "Padrão" if valor == 1.0 else "+%d%%" % int((valor - 1.0) * 100)
		botao.toggle_mode = true
		botao.button_pressed = valor == _fator
		botao.custom_minimum_size.y = 44
		botao.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		modos.add_child(botao)
	var exemplo := Label.new()
	exemplo.text = "Exemplo: Serviço concluído — R$125.000."
	exemplo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_painel._vbox.add_child(exemplo)
	_painel._vbox.move_child(exemplo, indice + 2)


func _montar_pior_cartao() -> void:
	# Mesmo caso de texto do D18: deriva os extremos das tabelas e usa os
	# formatadores reais. É uma fixture de apresentação, não uma partida jogada.
	var cartao: Control = _tela.get_node("BarraDocas").get_child(0)
	var script: Script = cartao.get_script()
	var maior := ""
	var teto := 0
	var dias := 0
	for motivo in _gs.MOTIVOS:
		var nome: String = _gs.MOTIVOS[motivo]["nome"]
		if nome.length() > maior.length():
			maior = nome
	for classe in _gs.CLASSES_DE_NAVIO:
		teto = maxi(teto, int(_gs.CLASSES_DE_NAVIO[classe]["valor_max"]))
		for motivo in _gs.MOTIVOS:
			dias = maxi(dias, int(_gs._turnos_de_operacao(classe, motivo)))
	cartao.get_node("Coluna/Cabecalho/Nome").text = "DOCA %d" % _gs.bercos_no_mapa()
	cartao.get_node("Coluna/Cabecalho/Valor").text = _gs.moeda(teto)
	cartao.get_node("Coluna/ProgressoLinha/Progresso").text = script.texto_do_progresso(maior, 0, dias)
	cartao.get_node("Coluna/TrabalhadorLinha/Trabalhador").text = script.texto_do_trabalhador(_gs.bercos_no_mapa(), true, 1)
	cartao.get_node("Coluna/TrabalhadorLinha/Icone").visible = true


func _areas() -> Array:
	var areas: Array = []
	for caminho in ["HudBar", "BarraDocas", "Fila", "MensagemCartao", "MetaCartao", "LinhaConstruir", "AcoesTurno"]:
		if _tela.has_node(caminho):
			var no: Control = _tela.get_node(caminho)
			areas.append({"no": caminho, "posicao": [no.position.x, no.position.y],
				"tamanho": [no.size.x, no.size.y],
				"minimo": [no.get_combined_minimum_size().x, no.get_combined_minimum_size().y]})
	return areas


func _buscar_painel(no: Node, arquivo: String) -> Control:
	if no is Control and no.get_script() != null and no.get_script().resource_path.ends_with(arquivo):
		return no
	for filho in no.get_children():
		var encontrado := _buscar_painel(filho, arquivo)
		if encontrado != null:
			return encontrado
	return null


func _descendentes(no: Node) -> Array:
	var todos: Array = []
	for filho in no.get_children():
		todos.append(filho)
		todos.append_array(_descendentes(filho))
	return todos


func _esperar(quantos: int) -> void:
	for i in quantos:
		root.size = Vector2i(720, 1280)
		await process_frame


func _salvar(caminho: String) -> void:
	await RenderingServer.frame_post_draw
	var imagem := root.get_texture().get_image()
	if imagem == null or imagem.get_size() != Vector2i(720, 1280) or imagem.save_png(caminho) != OK:
		push_error("a bancada não gerou a captura 720x1280")
		quit(1)
		return
	print("Tela salva em ", caminho, " (720x1280)")
