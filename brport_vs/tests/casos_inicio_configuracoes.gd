extends RefCounted

var falhas := 0
var completo := false


func conferir(rotulo: String, ok: bool) -> void:
	print("PASS T30: " if ok else "FAIL T30: ", rotulo)
	if not ok:
		falhas += 1


func rodar(gs: Node, arvore: SceneTree) -> void:
	var apoio = load("res://tests/casos_como_jogar.gd").new()
	apoio.gs = gs
	apoio.arvore = arvore
	var destinos := {"Ajustes": "PainelAjustes", "Como jogar": "PainelComoJogar",
		"Versão e diagnóstico": "PainelDiagnostico"}
	for ocupado in [false, true]:
		for n in range(1, int(gs.ESPACOS) + 1):
			gs.apagar_espaco(n)
		if ocupado:
			gs._rng.seed = 42
			gs.comecar_no_espaco(1)
			gs.definir_nomes("Cais da verificação", "Teste")
		var inicio: Control = load("res://scenes/TelaInicial.tscn").instantiate()
		arvore.root.add_child(inicio)
		await apoio.assentar()
		var antes: Dictionary = apoio.fotografia()
		var botoes: Array = _botoes(inicio)
		conferir("início tem exatamente quatro entradas em ambas as situações",
			botoes.map(func(b): return b.text) == ["Continuar", "Nova partida", "Saves", "Configurações"])
		conferir("Continuar só está habilitado quando há partida salva",
			apoio.botao(inicio, "Continuar").disabled == (not ocupado))
		apoio.botao(inicio, "Saves").pressed.emit()
		await apoio.assentar()
		var espacos: Control = inicio.get_child(inicio.get_child_count() - 1)
		conferir("Saves abre a lista compartilhada de espaços",
			espacos.scene_file_path == "res://scenes/panels/PainelEspacos.tscn")
		inicio.notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
		await apoio.assentar()
		apoio.botao(inicio, "Configurações").pressed.emit()
		await apoio.assentar()
		var menu: Control = inicio.get_child(inicio.get_child_count() - 1)
		conferir("Configurações reúne as três consultas e Voltar",
			_botoes(menu).map(func(b): return b.text) == ["Ajustes", "Como jogar", "Versão e diagnóstico", "Voltar"])
		for entrada in _botoes(menu):
			conferir("consulta cabe e tem alvo de toque: " + entrada.text,
				entrada.size.y >= 44 and menu.get_viewport_rect().encloses(entrada.get_global_rect()))
		for texto in destinos:
			var botao: Button = apoio.botao(menu, texto)
			botao.pressed.emit()
			await apoio.assentar()
			var painel: Control = inicio.get_child(inicio.get_child_count() - 1)
			conferir("Configurações usa a consulta compartilhada: " + texto,
				painel.scene_file_path == "res://scenes/panels/%s.tscn" % destinos[texto])
			conferir("a consulta oculta o menu de Configurações", not menu.visible and painel.visible)
			var total := inicio.get_child_count()
			botao.pressed.emit()
			await apoio.assentar()
			conferir("pedido repetido conserva um único painel", inicio.get_child_count() == total)
			if texto == "Ajustes":
				_contraste(painel)
			inicio.notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
			conferir("Voltar do aparelho fecha somente a consulta", painel.is_queued_for_deletion()
				and not menu.is_queued_for_deletion())
			await apoio.assentar()
			conferir("fechar a consulta devolve o mesmo menu visível", menu.visible and inicio.get_child_count() == total - 1)
		conferir("abrir e fechar as consultas preserva partida, RNG, arquivos e registro", apoio.fotografia() == antes)
		inicio.notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
		conferir("Voltar de Configurações devolve a inicial", menu.is_queued_for_deletion())
		await apoio.assentar()
		for botao in _botoes(inicio):
			conferir("entrada cabe e tem alvo de toque: " + botao.text,
				botao.size.y >= 44 and inicio.get_viewport_rect().encloses(botao.get_global_rect()))
		inicio.free()
	completo = true


func _contraste(painel: Control) -> void:
	var motor = load("res://scripts/validation/contraste_ui.gd").new()
	# O D33 mede normal/disabled; o defeito do telefone mora em hover_pressed.
	# Ler o estado efetivo do tema apanha a omissão que cai no StyleBoxEmpty.
	# A «Vibração» (`149`) nasce ligada, e é por isso a que o telefone mostra
	# em `hover_pressed` logo ao primeiro toque.
	var rotulos := {"ReduzirMovimento": "movimento", "Vibracao": "vibração"}
	for nome in rotulos:
		var escolha: CheckButton = painel.find_child(nome, true, false)
		conferir("%s está nos Ajustes" % nome, escolha != null)
		if escolha == null:
			continue
		var rotulo: String = rotulos[nome]
		for estado in ["normal", "hover", "pressed", "hover_pressed"]:
			var estilo: StyleBox = escolha.get_theme_stylebox(estado)
			var chave := "font_color" if estado == "normal" else "font_%s_color" % estado
			var fundo: Color = (estilo as StyleBoxFlat).bg_color if estilo is StyleBoxFlat else Color.TRANSPARENT
			var opaco := fundo.a == 1.0
			var razao: float = motor.contraste(escolha.get_theme_color(chave), fundo) if opaco else 0.0
			conferir("%s %s tem fundo opaco e contraste AA" % [rotulo, estado], opaco and razao >= 4.5)


func _botoes(no: Node) -> Array:
	var lista: Array = []
	if no is Button and not no.is_queued_for_deletion():
		lista.append(no)
	for filho in no.get_children():
		lista.append_array(_botoes(filho))
	return lista
