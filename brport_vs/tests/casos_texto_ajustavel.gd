extends RefCounted

var falhas := 0
var completo := false
var arvore: SceneTree
var gs
var _preferencias: PreferenciasDeApresentacao


func conferir(rotulo: String, ok: bool) -> void:
	print("PASS RB5: " if ok else "FAIL RB5: ", rotulo)
	if not ok:
		falhas += 1


func assentar() -> void:
	for i in 8:
		await arvore.process_frame


func rodar(na_arvore: SceneTree) -> void:
	arvore = na_arvore
	gs = arvore.root.get_node("GameState")
	_preferencias = PreferenciasDeApresentacao.atual()
	var modo_anterior := _preferencias.tamanho_do_texto
	var movimento_anterior := _preferencias.reduzir_movimento
	var caminho_anterior := _preferencias.caminho
	_preferencias.caminho = ArmazemLocal.caminho("rb5-sonda.cfg")
	_persistencia()
	_preferencias.tamanho_do_texto = PreferenciasDeApresentacao.PADRAO
	_preferencias.reduzir_movimento = true
	await _interface()
	await _inicio()
	await _leitura_e_campos()
	await _nome_na_fala()
	await _paineis()
	await _abertura_direta()
	await _proporcoes()
	_preferencias.tamanho_do_texto = modo_anterior
	_preferencias.reduzir_movimento = movimento_anterior
	_preferencias.caminho = caminho_anterior
	DirAccess.remove_absolute(ArmazemLocal.caminho("rb5-sonda.cfg"))
	completo = true


func _persistencia() -> void:
	var caminho := ArmazemLocal.caminho(PreferenciasDeApresentacao.ARQUIVO)
	var existia := FileAccess.file_exists(caminho)
	var original := FileAccess.get_file_as_bytes(caminho) if existia else PackedByteArray()
	DirAccess.remove_absolute(caminho)
	var p := PreferenciasDeApresentacao.new()
	conferir("sem arquivo usa padrao e movimento completo", p.tamanho_do_texto == "padrao"
		and not p.reduzir_movimento and not FileAccess.file_exists(caminho))
	for invalido in ["MAIOR", "maior ", 1, true, [], null]:
		var invalida := ConfigFile.new()
		invalida.set_value("apresentacao", "tamanho_do_texto", invalido)
		invalida.save(caminho)
		conferir("leitor recusa tamanho invalido " + str(invalido), PreferenciasDeApresentacao.new().tamanho_do_texto == "padrao")
	for texto in ["padrao", "maior"]:
		for movimento in [false, true]:
			for ordem in [0, 1]:
				if ordem == 0:
					p.definir_reduzir_movimento(movimento)
					p.definir_tamanho_do_texto(texto)
				else:
					p.definir_tamanho_do_texto(texto)
					p.definir_reduzir_movimento(movimento)
				var cfg := ConfigFile.new()
				var erro := cfg.load(p.caminho)
				conferir("duas preferencias no disco %s/%s ordem %d" % [texto, movimento, ordem],
					erro == OK and cfg.get_value("apresentacao", "tamanho_do_texto") == texto
					and cfg.get_value("apresentacao", "reduzir_movimento") == movimento)
				var relida := PreferenciasDeApresentacao.new()
				conferir("leitor restaura %s/%s ordem %d" % [texto, movimento, ordem],
					relida.tamanho_do_texto == texto and relida.reduzir_movimento == movimento)
	var cfg := ConfigFile.new()
	cfg.set_value("futura", "sentinela", 42)
	cfg.save(p.caminho)
	p.definir_tamanho_do_texto("maior")
	cfg.load(p.caminho)
	conferir("setter conserva chave desconhecida", cfg.get_value("futura", "sentinela") == 42)
	conferir("valor invalido nao altera a escolha", p.definir_tamanho_do_texto("enorme") == ERR_INVALID_PARAMETER
		and p.tamanho_do_texto == "maior")
	p.caminho += "/pasta-inexistente/preferencia.cfg"
	conferir("falha de escrita conserva texto na sessao", p.definir_tamanho_do_texto("padrao") != OK
		and p.tamanho_do_texto == "padrao")
	if existia:
		var arquivo := FileAccess.open(caminho, FileAccess.WRITE)
		arquivo.store_buffer(original)
		arquivo.close()
	else:
		DirAccess.remove_absolute(caminho)


func _interface() -> void:
	gs.clear_save()
	gs._rng.seed = 42
	gs.new_game()
	gs.definir_nomes("WWWWWWWWWWWWWWWWWWWWWWWW", "Leitura")
	if gs.phase == gs.ESTADO_OFERTA:
		gs.resolve_rival_offer(true)
	var tela: Control = load("res://scenes/Main.tscn").instantiate()
	arvore.root.add_child(tela)
	await assentar()
	tela._concluir_virada()
	for painel in tela._overlay_layer.get_children():
		painel.queue_free()
	await assentar()
	var mapa: Rect2 = tela.get_node("MapaWrap").get_global_rect()
	var originais := _fontes(tela)
	var posicoes := {}
	for nome in ["BarraDocas", "Fila", "FilaTitulo", "MensagemCartao", "MetaCartao", "LinhaConstruir", "AcoesTurno", "HudBar"]:
		posicoes[nome] = tela.get_node(nome).get_rect()
	var apoio = load("res://tests/casos_meu_porto.gd").new()
	apoio.gs = gs
	apoio.arvore = arvore
	var antes: Dictionary = apoio.fotografia()
	# Para testar apresentação sem confundir escrita autorizada da preferência
	# com save da partida, o sinal usa a escolha em memória neste bloco.
	_preferencias.tamanho_do_texto = "maior"
	_preferencias.texto_mudou.emit("maior")
	await assentar()
	conferir("troca conserva partida RNG arquivos e registro", antes == apoio.fotografia())
	conferir("mapa conserva o retangulo", mapa == tela.get_node("MapaWrap").get_global_rect())
	conferir("override da cena amplia de 19 para 24", tela.get_node("AcoesTurno/Avancar").get_theme_font_size("font_size") == 24)
	var rolo: ScrollContainer = tela.get_node_or_null("OperacaoRolavel")
	conferir("operacao tem rolagem vertical e tres colunas", rolo != null
		and tela._dock_cards.get_parent().get_parent() == rolo
		and tela._dock_cards.get_child_count() == 3
		and tela._fila_lugares.get_child_count() == 3
		and rolo.horizontal_scroll_mode == ScrollContainer.SCROLL_MODE_DISABLED)
	var captura = load("res://tools/capturar_tela.gd")
	conferir("captura jogada encontra o barco dentro do rolo", captura.primeiro_barco_da_fila(tela)
		== tela._fila_lugares.get_child(0))
	var acao: Button = tela.get_node("AcoesTurno/Avancar")
	conferir("acoes fixas cabem fora do rolo", not rolo.is_ancestor_of(acao)
		and acao.get_global_rect().end.y <= tela.get_viewport_rect().size.y
		and acao.size.y >= 44)
	tela._on_pause_pressed()
	await assentar()
	var pausa: Control = tela._overlay_layer.get_child(tela._overlay_layer.get_child_count() - 1)
	var medidor = load("res://tools/medir_texto_bancada.gd")
	var nome_longo_cabe := false
	for texto in medidor.medir(pausa).textos:
		if texto.texto.contains("WWWWWWWWWWWWWWWWWWWWWWWW"):
			nome_longo_cabe = texto.fonte == 19 and texto.excesso_local <= 2.0
	conferir("nome de 24 letras cabe na pausa sem encolher", nome_longo_cabe)
	_mouse(Vector2(60, 810), true)
	var arrasto := InputEventMouseMotion.new()
	arrasto.position = Vector2(60, 740)
	arrasto.global_position = arrasto.position
	arrasto.relative = Vector2(0, -70)
	arrasto.button_mask = MOUSE_BUTTON_MASK_LEFT
	arvore.root.push_input(arrasto, true)
	_mouse(arrasto.position, false)
	conferir("painel aberto bloqueia gesto no porto de baixo", rolo.scroll_vertical == 0)
	pausa.queue_free()
	await assentar()
	await _gestos(tela, rolo, apoio)
	var tardio := Label.new()
	tardio.text = "Aviso posterior"
	tardio.add_theme_font_size_override("font_size", 12)
	tela.add_child(tardio)
	await assentar()
	conferir("no criado depois recebe tamanho escolhido", tardio.get_theme_font_size("font_size") == 15)
	tardio.queue_free()
	for i in 3:
		_preferencias.texto_mudou.emit("maior")
	await assentar()
	conferir("reaplicar nao acumula escala", acao.get_theme_font_size("font_size") == 24)
	_preferencias.tamanho_do_texto = "padrao"
	_preferencias.texto_mudou.emit("padrao")
	await assentar()
	conferir("ciclo restaura todas as fontes", _fontes(tela) == originais)
	var restaurou := true
	for nome in posicoes:
		restaurou = restaurou and tela.has_node(nome) and tela.get_node(nome).get_rect() == posicoes[nome]
	conferir("ciclo restaura a composicao padrao", restaurou)
	conferir("captura jogada encontra o barco no padrao", captura.primeiro_barco_da_fila(tela)
		== tela._fila_lugares.get_child(0))
	tela.free()
	arvore.root.get_node("Registro").desarmar()


func _inicio() -> void:
	var tela: Control = load("res://scenes/TelaInicial.tscn").instantiate()
	arvore.root.add_child(tela)
	tela._abrir_ajustes()
	await assentar()
	var botao: Button = tela.find_child("TextoMaior", true, false)
	conferir("ajustes oferecem os dois tamanhos", botao != null and tela.find_child("TextoPadrao", true, false) != null)
	botao.grab_focus()
	botao.pressed.emit()
	await assentar()
	conferir("controle aplica tamanho e preserva foco", _preferencias.tamanho_do_texto == "maior"
		and botao.button_pressed and botao.has_focus())
	conferir("logotipo conserva tamanho 68", tela.get_node("Logo").get_theme_font_size("font_size") == 68)
	var exemplo: Label = tela.find_child("ExemploDoTexto", true, false)
	conferir("exemplo usa fonte maior do tema", exemplo.get_theme_font_size("font_size") == 19)
	_conferir_faixa(tela, "ajustes acompanham conteudo sem faixa branca")
	var padrao: Button = tela.find_child("TextoPadrao", true, false)
	padrao.pressed.emit()
	await assentar()
	conferir("controle retorna ao padrao", exemplo.get_theme_font_size("font_size") == 15
		and padrao.button_pressed and not botao.button_pressed)
	var caminho := _preferencias.caminho
	_preferencias.caminho += "/nao-existe/apresentacao.cfg"
	botao.pressed.emit()
	await assentar()
	var aviso: Label
	for no in TextoDaInterface.descendentes(tela):
		if no is Label and no.text == "Não foi possível lembrar a escolha. Ela vale nesta sessão.":
			aviso = no
	conferir("falha ao lembrar texto aparece nos Ajustes", aviso != null and aviso.is_visible_in_tree()
		and _preferencias.tamanho_do_texto == "maior")
	_preferencias.caminho = caminho
	tela.free()
	# Também a tela que já nasce no Maior: a quebra ainda sem largura podia
	# criar o rolo no teto e conservar uma faixa branca depois de assentar.
	var nova: Control = load("res://scenes/TelaInicial.tscn").instantiate()
	arvore.root.add_child(nova)
	nova._abrir_ajustes()
	await assentar()
	_conferir_faixa(nova, "ajustes novos no maior nao guardam faixa vazia")
	nova.free()


func _conferir_faixa(tela: Control, rotulo: String) -> void:
	var voltar: Button
	for no in TextoDaInterface.descendentes(tela):
		if no is Button and no.text == "Voltar":
			voltar = no
	var cartao: Node = voltar.get_parent()
	while not cartao.has_meta(&"cartao_rolavel_rb5"):
		cartao = cartao.get_parent()
	conferir(rotulo, cartao.get_global_rect().end.y - voltar.get_global_rect().end.y <= 32.0)


func _gestos(tela: Control, rolo: ScrollContainer, apoio: RefCounted) -> void:
	var antes: Dictionary = apoio.fotografia()
	var origem := Vector2(60, 810)
	_mouse(origem, true)
	var mover := InputEventMouseMotion.new()
	mover.position = origem - Vector2(0, 70)
	mover.global_position = mover.position
	mover.relative = Vector2(0, -70)
	mover.button_mask = MOUSE_BUTTON_MASK_LEFT
	arvore.root.push_input(mover, true)
	_mouse(mover.position, false)
	await assentar()
	conferir("arrastar rola sem executar acao da partida", rolo.scroll_vertical > 0 and antes == apoio.fotografia())
	rolo.scroll_vertical = 0
	await assentar()
	# O controle contrário é um toque completo no barco, pela GUI real.
	var cartao: Control = tela._fila_lugares.get_child(0)
	var toque: Vector2 = cartao.get_global_rect().get_center()
	var barcos: int = gs.fila.size()
	_mouse(toque, true)
	_mouse(toque, false)
	await assentar()
	conferir("toque sem arrasto continua atracando", gs.fila.size() == barcos - 1
		and gs.docks[0].boat != null)
	rolo.scroll_vertical = 0
	await assentar()
	antes = apoio.fotografia()
	origem = tela._dock_cards.get_child(0).get_global_rect().get_center()
	_mouse(origem, true)
	mover.position = origem - Vector2(0, 60)
	mover.global_position = mover.position
	arvore.root.push_input(mover, true)
	_mouse(mover.position, false)
	await assentar()
	conferir("arrasto sobre barco atracado nao libera ao premir", antes == apoio.fotografia()
		and gs.docks[0].boat != null)
	# Desfaz pela porta do jogo antes de comparar o retorno de apresentação.
	gs.tocar_doca(0)
	tela._refresh_all()
	await assentar()


func _mouse(posicao: Vector2, pressionado: bool) -> void:
	var evento := InputEventMouseButton.new()
	evento.position = posicao
	evento.global_position = posicao
	evento.button_index = MOUSE_BUTTON_LEFT
	evento.pressed = pressionado
	arvore.root.push_input(evento, true)


func _leitura_e_campos() -> void:
	_preferencias.tamanho_do_texto = "padrao"
	var ajuda: Control = load("res://scenes/panels/PainelComoJogar.tscn").instantiate()
	ajuda.theme = TextoDaInterface.TEMA
	arvore.root.add_child(ajuda)
	ajuda._mostrar("glossario")
	await assentar()
	var rolo: ScrollContainer = ajuda._rolo
	rolo.scroll_vertical = 280
	await assentar()
	var marca := MemoriaDeLeitura.marcar(rolo)
	_preferencias.tamanho_do_texto = "maior"
	_preferencias.texto_mudou.emit("maior")
	await assentar()
	var letra: Rect2 = marca.no.get_character_bounds(marca.caractere)
	var deslocamento: float = marca.no.global_position.y + letra.position.y - rolo.global_position.y
	conferir("troca conserva caractere na dobra da leitura", absf(deslocamento - marca.deslocamento) <= 2.0
		and ajuda.assunto_atual == "glossario")
	var posicao := rolo.scroll_vertical
	ajuda._mostrar("")
	await assentar()
	ajuda._mostrar("glossario")
	await assentar()
	conferir("retorno ao artigo conserva leitura no tamanho novo", abs(ajuda._rolo.scroll_vertical - posicao) <= 1)
	ajuda.free()
	_preferencias.tamanho_do_texto = "padrao"
	var nomes: Control = load("res://scenes/panels/TelaNomes.tscn").instantiate()
	nomes.theme = TextoDaInterface.TEMA
	arvore.root.add_child(nomes)
	await assentar()
	var campos: Array = []
	for no in TextoDaInterface.descendentes(nomes):
		if no is LineEdit:
			campos.append(no)
	campos[0].text = "Cais das letras"
	campos[0].grab_focus()
	campos[0].caret_column = 7
	_preferencias.tamanho_do_texto = "maior"
	_preferencias.texto_mudou.emit("maior")
	await assentar()
	conferir("troca conserva campo texto cursor e foco", campos.size() == 2
		and campos[0].text == "Cais das letras" and campos[0].caret_column == 7 and campos[0].has_focus())
	campos[0].select(2, 8)
	_preferencias.tamanho_do_texto = "padrao"
	_preferencias.texto_mudou.emit("padrao")
	await assentar()
	conferir("troca conserva selecao existente", campos[0].has_selection()
		and campos[0].get_selection_from_column() == 2 and campos[0].get_selection_to_column() == 8)
	# O getter sem seleção devolve -1 e escreve erro C++, mas não aborta.
	# O valor do campo continuava correto: quem prova ausência desse defeito
	# é o log real do motor, não uma comparação de texto/cursor.
	var caminho_log := OS.get_user_data_dir().path_join("logs/godot.log")
	var log := FileAccess.get_file_as_string(caminho_log)
	conferir("campo sem selecao nao gera erro do motor", not log.is_empty()
		and not log.contains("get_selection_from_column") and not log.contains("get_selection_to_column"))
	nomes.free()


func _fontes(tela: Node) -> Dictionary:
	var fontes := {}
	for no in TextoDaInterface.descendentes(tela):
		if no is Label or no is Button or no is LineEdit:
			fontes[String(tela.get_path_to(no))] = no.get_theme_font_size("font_size")
	return fontes


func _nome_na_fala() -> void:
	# A pausa é larga o bastante para a palavra sozinha. O balão ao lado
	# do retrato é estreito: o nome válido precisa quebrar sem diminuir a letra.
	_preferencias.tamanho_do_texto = "padrao"
	var percurso = load("res://scripts/validation/contraste_ui.gd").new()
	var nome := "W".repeat(24)
	var caso := {"nome": "Fala com nome longo", "cena": "res://scenes/panels/CounterOfferPanel.tscn",
		"barco": 0, "setup": [0], "estado": {"nome_porto": nome}}
	var tela: Control = percurso.montar_caso(arvore.root, gs, caso, TextoDaInterface.TEMA)
	if tela == null:
		conferir("nome longo montou a fala", false)
		return
	await assentar()
	var rotulo: Label
	for no in TextoDaInterface.descendentes(tela):
		if no is Label and no.text.contains(nome):
			rotulo = no
	var base := rotulo.get_theme_font_size("font_size") if rotulo != null else 0
	_preferencias.tamanho_do_texto = "maior"
	_preferencias.texto_mudou.emit("maior")
	await assentar()
	var legivel := false
	for texto in load("res://tools/medir_texto_bancada.gd").medir(tela).textos:
		if texto.texto.contains(nome):
			legivel = base > 0 and texto.fonte == roundi(base * 1.25) \
				and texto.excesso_local <= 2.0 and texto.excesso_janela <= 2.0
	conferir("nome de 24 letras cabe no balao sem encolher", legivel)
	tela.free()
	arvore.root.get_node("Registro").desarmar()


func _paineis() -> void:
	var percurso = load("res://scripts/validation/contraste_ui.gd").new()
	var medidor = load("res://tools/medir_texto_bancada.gd")
	var medidas: Array = []
	for caso in percurso.percurso():
		_preferencias.tamanho_do_texto = "padrao"
		var tela: Control = percurso.montar_caso(arvore.root, gs, caso, TextoDaInterface.TEMA)
		if tela == null:
			conferir("montou " + caso.nome, false)
			continue
		await assentar()
		if caso.nome == "Mensagens":
			var conversa: ScrollContainer = tela.find_child("Conversa", true, false)
			var barra := conversa.get_v_scroll_bar()
			conferir("conversa nova mostra fim do historico", barra.max_value > barra.page
				and absf(conversa.scroll_vertical - (barra.max_value - barra.page)) <= 1.0)
		var originais := {}
		var aparelhos_originais := {}
		for no in TextoDaInterface.descendentes(tela):
			if no is Label or no is Button or no is LineEdit:
				originais[no] = no.get_theme_font_size("font_size")
			if no is PanelContainer and no.has_meta(&"celular_tamanho_rb5"):
				aparelhos_originais[no] = no.get_global_rect()
		_preferencias.tamanho_do_texto = "maior"
		_preferencias.texto_mudou.emit("maior")
		await assentar()
		var fontes_certas := true
		for no in originais:
			# O próprio nó, não seu caminho: o reparent não pode isentar os
			# cartões e as páginas justamente quando começam a rolar.
			if no.theme_type_variation != &"LogoInicial":
				fontes_certas = fontes_certas and no.get_theme_font_size("font_size") == roundi(originais[no] * 1.25)
		conferir("fontes do painel " + caso.nome, fontes_certas)
		var medida: Dictionary = medidor.medir(tela)
		var cortes: Array = []
		for texto in medida.textos:
			if texto.classe == "Label" and (texto.excesso_local > 2.0 or
					(not texto.em_rolagem and texto.excesso_janela > 2.0)):
				cortes.append({"no": texto.no, "excesso": texto.excesso_local,
					"janela": texto.excesso_janela, "texto": texto.texto})
		medidas.append({"caso": caso.nome, "cortes": cortes})
		conferir("texto sem corte local " + caso.nome, cortes.is_empty())
		var acoes_legiveis := true
		var acoes_de_obra := 0
		for no in TextoDaInterface.descendentes(tela):
			if no is Button and no.text.begins_with("Construir · "):
				acoes_de_obra += 1
				var fonte: Font = no.get_theme_font("font")
				var largura: float = fonte.get_string_size(no.text, HORIZONTAL_ALIGNMENT_LEFT, -1,
					no.get_theme_font_size("font_size")).x
				acoes_legiveis = acoes_legiveis and no.size.x >= largura and no.size.y < 100
		if caso.nome.begins_with("Construir"):
			conferir("acao de obra permanece legivel " + caso.nome, acoes_legiveis)
			if caso.nome == "Construir":
				conferir("percurso mede uma acao de obra", acoes_de_obra > 0)
		var rolos_validos := true
		var aparelhos_certos := true
		for no in TextoDaInterface.descendentes(tela):
			if no is ScrollContainer and no.is_visible_in_tree():
				rolos_validos = rolos_validos and no.size.y >= 44.0
			if no is PanelContainer and no.has_meta(&"celular_tamanho_rb5"):
				var tamanho: Vector2 = no.get_meta(&"celular_tamanho_rb5")
				aparelhos_certos = aparelhos_certos and no.size == tamanho \
					and no.get_global_rect().get_center() == tela.get_global_rect().get_center()
		conferir("janelas de leitura tem altura util " + caso.nome, rolos_validos)
		conferir("aparelho conserva medidas e centro " + caso.nome, aparelhos_certos)
		if not aparelhos_originais.is_empty():
			_preferencias.tamanho_do_texto = "padrao"
			_preferencias.texto_mudou.emit("padrao")
			await assentar()
			var restaurou := true
			for no in aparelhos_originais:
				restaurou = restaurou and no.get_global_rect() == aparelhos_originais[no]
			conferir("aparelho volta a geometria padrao " + caso.nome, restaurou)
		tela.free()
		arvore.root.get_node("Registro").desarmar()
	var log := FileAccess.open(ArmazemLocal.caminho("rb5-paineis.json"), FileAccess.WRITE)
	log.store_string(JSON.stringify(medidas, "\t"))
	conferir("percurso montou todos os estados", medidas.size() == percurso.percurso().size()
		and percurso.falhas.is_empty())


func _abertura_direta() -> void:
	# Trocar depois do Padrão não prova a primeira abertura: ali as larguras
	# já assentaram. Meu Porto perdia a altura do rolo só no arranque em Maior.
	var percurso = load("res://scripts/validation/contraste_ui.gd").new()
	_preferencias.tamanho_do_texto = "maior"
	for caso in percurso.percurso():
		var tela: Control = percurso.montar_caso(arvore.root, gs, caso, TextoDaInterface.TEMA)
		if tela == null:
			conferir("abertura direta montou " + caso.nome, false)
			continue
		await assentar()
		var leitura_visivel := true
		for no in TextoDaInterface.descendentes(tela):
			if no is ScrollContainer and no.is_visible_in_tree():
				leitura_visivel = leitura_visivel and no.size.y >= 44.0
		conferir("abertura maior conserva area de leitura " + caso.nome, leitura_visivel)
		tela.free()
		arvore.root.get_node("Registro").desarmar()
	conferir("aberturas diretas terminaram", percurso.falhas.is_empty())


func _proporcoes() -> void:
	var motor = load("res://scripts/validation/contraste_ui.gd").new()
	var medidor = load("res://tools/medir_texto_bancada.gd")
	_preferencias.tamanho_do_texto = "maior"
	for tamanho in [Vector2i(720, 1152), Vector2i(720, 1600)]:
		for cena in ["PainelAjustes", "PainelComoJogar", "PainelDiagnostico", "PainelMeuPorto", "PainelDiario", "TelaNomes", "PainelMenu"]:
			var visor := SubViewport.new()
			visor.size = tamanho
			arvore.root.add_child(visor)
			var caso := {"nome": cena, "cena": "res://scenes/panels/%s.tscn" % cena}
			if cena in ["PainelAjustes", "PainelMeuPorto", "PainelMenu"]:
				caso.setup = []
			var tela: Control = motor.montar_caso(visor, gs, caso, TextoDaInterface.TEMA)
			await assentar()
			var cabe := true
			for texto in medidor.medir(tela).textos:
				if texto.classe == "Label":
					cabe = cabe and texto.excesso_local <= 2.0 \
						and (texto.em_rolagem or texto.excesso_janela <= 2.0)
			conferir("leitura maior cabe em %s: %s" % [tamanho, cena], cabe)
			visor.free()
