extends RefCounted

class CadernoSemFoto:
	extends PainelNarrativo
	func _fotografar_folha() -> Texture2D:
		return null

var gs
var arvore: SceneTree
var apoio
var falhas := 0
var completo := false


func conferir(nome: String, ok: bool) -> void:
	print("PASS T29: " if ok else "FAIL T29: ", nome)
	if not ok:
		falhas += 1


func foto() -> Dictionary:
	var f: Dictionary = apoio.fotografia()
	# Só este arquivo pode mudar ao escolher uma preferência. A partida, o
	# registro, o áudio e qualquer arquivo novo continuam na fotografia.
	f["arquivos"].erase(PreferenciasDeApresentacao.atual().caminho)
	return f


func rodar(estado, tree: SceneTree) -> void:
	gs = estado
	arvore = tree
	apoio = load("res://tests/casos_meu_porto.gd").new()
	apoio.gs = gs
	apoio.arvore = tree
	var pref := PreferenciasDeApresentacao.atual()
	var existia := FileAccess.file_exists(pref.caminho)
	var original := FileAccess.get_file_as_bytes(pref.caminho) if existia else PackedByteArray()
	_preferencia()
	pref.definir_reduzir_movimento(false)
	apoio.novo()
	var inicio: Control = load("res://scenes/TelaInicial.tscn").instantiate()
	arvore.root.add_child(inicio)
	await apoio.assentar()
	await _porta(inicio, inicio)
	inicio.queue_free()
	await apoio.assentar()
	var main: Control = load("res://scenes/Main.tscn").instantiate()
	arvore.root.add_child(main)
	await apoio.assentar()
	main._concluir_virada()
	for painel in main._overlay_layer.get_children():
		painel.queue_free()
	await apoio.assentar()
	main._on_pause_pressed()
	await apoio.assentar()
	var pausa: Node = main._overlay_layer.get_child(0)
	await _porta(pausa, main._overlay_layer, main)
	conferir("retorno dos Ajustes mantém a pausa", not pausa.is_queued_for_deletion())
	pausa.queue_free()
	await apoio.assentar()
	await _cenario(main)
	await _folha()
	main.queue_free()
	await apoio.assentar()
	# Novo Main com a escolha já ligada: não depende de receber o sinal que
	# os nós anteriores ouviram. A operação é montada pelas ações do jogo.
	pref.definir_reduzir_movimento(true)
	apoio.novo()
	main = load("res://scenes/Main.tscn").instantiate()
	arvore.root.add_child(main)
	await apoio.assentar()
	conferir("elementos criados depois nascem com fundo parado", _parado(main))
	var toque := InputEventMouseButton.new()
	toque.button_index = MOUSE_BUTTON_LEFT
	toque.pressed = false
	main._fila_lugares.get_child(0)._gui_input(toque)
	conferir("controle: serviço contratado pela ação de atracar", gs.docks[0]["boat"] != null)
	await apoio.assentar()
	var doca = main._docks_container.get_child(0)
	conferir("operação mantém trabalhador e ciclo de serviço", doca._trabalhador_prop.visible
		and doca._tw_trabalho != null and doca._tw_trabalho.is_running())
	var visita_vista := false
	# Atracar depois de montar Main pode encontrar o caminhão já carregado
	# para outro destino. Esperar voltas completas, derivadas da rota real,
	# exercita também a visita que nasce depois de a preferência estar ligada.
	var ciclo: float = main.trafego._tempo_dos_pontos(main.trafego.ROTA_ESTRADA) + main.trafego.CAMINHAO_INTERVALO
	for passo in range(ceili(ciclo * 3.0 / 0.1)):
		for tw in arvore.get_processed_tweens():
			if tw.is_valid() and tw.is_running():
				tw.custom_step(0.1)
		for camiao in main.trafego._camioes():
			if main.trafego._ocupante_do_berco.has(camiao["no"]):
				visita_vista = camiao["no"].visible
		if visita_vista:
			break
	conferir("visita operacional do caminhão continua visível", visita_vista)
	var antes := foto()
	pref.definir_reduzir_movimento(false)
	pref.definir_reduzir_movimento(true)
	conferir("troca com operação preserva estado, RNG, arquivos e registro", foto() == antes)
	var dia: int = gs.turn
	var servidos: int = gs.metrics["boats_served"]
	main._on_advance_pressed()
	conferir("serviço e dia concluem com movimento reduzido", gs.turn == dia + 1
		and gs.metrics["boats_served"] == servidos + 1 and not doca.em_troca())
	conferir("caixa mostra resultado final sem contagem", main._cash_label.text == gs.moeda(gs.cash))
	conferir("resultado do serviço continua visível e imóvel", main._ganhos.get_child_count() > 0
		and main._ganhos.get_child(0).modulate.a == 1.0)
	# O relógio do descarte continua vivo mesmo com seu movimento pausado.
	for tw in arvore.get_processed_tweens():
		if tw.is_valid() and tw.is_running():
			tw.custom_step(1.3)
	await apoio.assentar()
	conferir("resultado termina sem esperar tween decorativo pausado", main._ganhos.get_child_count() == 0)
	main.queue_free()
	await apoio.assentar()
	arvore.root.get_node("Registro").desarmar()
	pref.definir_reduzir_movimento(false)
	if existia:
		var arquivo := FileAccess.open(pref.caminho, FileAccess.WRITE)
		arquivo.store_buffer(original)
		arquivo.close()
	else:
		DirAccess.remove_absolute(pref.caminho)
	# Restaurar o objeto compartilhado à mesma escolha que estava no disco.
	pref.reduzir_movimento = PreferenciasDeApresentacao.new().reduzir_movimento
	completo = true


func _preferencia() -> void:
	var pref := PreferenciasDeApresentacao.atual()
	DirAccess.remove_absolute(pref.caminho)
	var nova := PreferenciasDeApresentacao.new()
	conferir("ausência mantém padrão e leitura não cria arquivo", not nova.reduzir_movimento
		and not FileAccess.file_exists(pref.caminho))
	for invalido in ["true", 1, [], null]:
		var cfg := ConfigFile.new()
		cfg.set_value("apresentacao", "reduzir_movimento", invalido)
		cfg.save(pref.caminho)
		conferir("valor inválido mantém movimento atual: %s" % str(invalido),
			not PreferenciasDeApresentacao.new().reduzir_movimento)
	conferir("escrita de preferência informa sucesso real", pref.definir_reduzir_movimento(true) == OK)
	conferir("nova instância relê escolha persistente", PreferenciasDeApresentacao.new().reduzir_movimento)
	conferir("bancada pode derivar padrão sem herdar outra ferramenta", not PreferenciasDeApresentacao.new(false).reduzir_movimento)
	conferir("preferência de ferramenta é isolada", pref.caminho.begins_with(ArmazemLocal.RAIZ_DAS_FERRAMENTAS))
	conferir("jogo usa preferência fora da pasta de ferramentas", ArmazemLocal.caminho(
		PreferenciasDeApresentacao.ARQUIVO, PackedStringArray()) == ArmazemLocal.RAIZ_DO_JOGADOR + PreferenciasDeApresentacao.ARQUIVO)
	for n in range(1, int(gs.ESPACOS) + 1):
		gs._apontar_espaco(n)
		conferir("preferência independe do espaço %d" % n, PreferenciasDeApresentacao.new().reduzir_movimento)
	gs._apontar_espaco(1)


func _porta(origem: Node, pai: Node, dono: Node = null) -> void:
	var caminho: String = gs.save_path
	gs.save_path = caminho.get_base_dir().path_join("sonda_rb6_ausente.json")
	DirAccess.remove_absolute(gs.save_path)
	var antes := foto()
	var botao: Button = apoio.botao(origem, "Ajustes")
	conferir("porta dos Ajustes disponível", botao != null)
	if botao == null:
		return
	botao.pressed.emit()
	await apoio.assentar()
	var painel = pai.get_child(pai.get_child_count() - 1)
	conferir("início e pausa abrem os mesmos Ajustes", painel.scene_file_path == "res://scenes/panels/PainelAjustes.tscn")
	var total := pai.get_child_count()
	botao.pressed.emit()
	await apoio.assentar()
	conferir("Ajustes repetidos não duplicam painel", total == pai.get_child_count())
	var escolha: CheckButton = apoio.botao(painel, "Reduzir movimento") as CheckButton
	conferir("preferência acessível e sincronizada", escolha != null
		and escolha.button_pressed == PreferenciasDeApresentacao.atual().reduzir_movimento)
	if escolha == null:
		return
	escolha.button_pressed = not escolha.button_pressed
	conferir("toque aplica imediatamente e permanece no disco", PreferenciasDeApresentacao.atual().reduzir_movimento
		== escolha.button_pressed and PreferenciasDeApresentacao.new().reduzir_movimento == escolha.button_pressed)
	var pref := PreferenciasDeApresentacao.atual()
	var config := pref.caminho
	pref.caminho = config.get_base_dir() # diretório existente: escrita deve falhar
	escolha.button_pressed = not escolha.button_pressed
	conferir("falha ao lembrar é explícita e escolha vale na sessão", painel._aviso_preferencia.visible
		and pref.reduzir_movimento == escolha.button_pressed)
	pref.caminho = config
	await apoio.assentar()
	var voltar: Button = apoio.botao(painel, "Voltar")
	conferir("escolha e Voltar alcançáveis com alvo mínimo", escolha.size.y >= 44 and voltar.size.y >= 44
		and painel.get_viewport_rect().encloses(escolha.get_global_rect())
		and painel.get_viewport_rect().encloses(voltar.get_global_rect()))
	var tamanho := arvore.root.size
	for altura in [1152, 1280, 1600]:
		arvore.root.size = Vector2i(720, altura)
		await apoio.assentar()
		conferir("Ajustes cabem na altura lógica %d" % altura,
			painel.get_viewport_rect().encloses(escolha.get_global_rect())
			and painel.get_viewport_rect().encloses(voltar.get_global_rect()))
	arvore.root.size = tamanho
	await apoio.assentar()
	var motor = load("res://scripts/validation/contraste_ui.gd").new()
	var linhas: Array = motor.medir(painel)
	var legivel := not linhas.is_empty()
	for linha in linhas:
		legivel = legivel and linha["estado"] in ["passa", "isento"]
	conferir("preferência e explicação mantêm texto legível", legivel)
	conferir("Ajustes preservam partida, RNG, arquivos e registro", foto() == antes)
	if dono == null:
		origem.notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	else:
		dono.notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	conferir("Voltar do aparelho fecha somente os Ajustes", painel.is_queued_for_deletion())
	await apoio.assentar()
	botao.pressed.emit()
	await apoio.assentar()
	painel = pai.get_child(pai.get_child_count() - 1)
	apoio.botao(painel, "Voltar").pressed.emit()
	conferir("botão Voltar fecha os Ajustes", painel.is_queued_for_deletion())
	await apoio.assentar()
	conferir("fechar Ajustes preserva a partida", foto() == antes)
	gs.save_path = caminho


func _parado(main: Node) -> bool:
	var ciclos: Array = main.movimento_de_fundo._ciclos
	if ciclos.size() < main.mata.nos().size() + 10:
		return false
	for ciclo in ciclos:
		if ciclo["tween"].is_running():
			return false
	return true


func _cenario(main: Node) -> void:
	var pref := PreferenciasDeApresentacao.atual()
	pref.definir_reduzir_movimento(false)
	var arvore_da_mata: Control = main.mata.nos()[0]
	main.mata.rajadas()[0].custom_step(0.3)
	conferir("controle: mata se move na apresentação padrão", absf(arvore_da_mata.rotation) > 0.00001)
	var antes := foto()
	pref.definir_reduzir_movimento(true)
	conferir("escolha para fundo já aberto e repõe pose inteira", _parado(main)
		and arvore_da_mata.rotation == 0.0)
	var poses: Array = []
	for ciclo in main.movimento_de_fundo._ciclos:
		var no: Node = ciclo["no"].get_ref()
		poses.append([no.position, no.rotation, no.modulate])
	await apoio.assentar()
	var depois: Array = []
	for ciclo in main.movimento_de_fundo._ciclos:
		var no: Node = ciclo["no"].get_ref()
		depois.append([no.position, no.rotation, no.modulate])
	conferir("comparação temporal: fundo reduzido fica estável", poses == depois)
	conferir("mudança de apresentação preserva partida e RNG", foto() == antes)
	var vaga = main._docks_container.get_child(0)
	var brilho: Color = vaga._pier.modulate
	conferir("berço livre mantém realce fixo", brilho == vaga.REALCE and gs.atracagem_pendente() != Vector2i.ZERO)
	var fila = main._fila_lugares.get_child(0)
	conferir("barco chamável mantém realce e ação", fila.modulate == fila.PULSO_COR
		and (fila._tw_pulso == null or not fila._tw_pulso.is_valid() or not fila._tw_pulso.is_running()))
	for camiao in main.trafego._camioes():
		conferir("trânsito sem serviço fica oculto", not camiao["no"].visible)
	var fauna: Array = main.find_children("*", "Node2D", true, false).filter(func(no: Node) -> bool:
		return no.has_method("reagir"))
	conferir("controle: fauna exercitada", not fauna.is_empty())
	for bicho in fauna:
		var posicao: Vector2 = bicho.position
		bicho.reagir()
		bicho._process(2.0)
		conferir("fauna reduzida mantém pose e toque", bicho.position == posicao and bicho.esta_presente())
	pref.definir_reduzir_movimento(false)
	conferir("desligar restaura ciclos decorativos", main.mata.rajadas()[0].is_running())


func _folha() -> void:
	var pref := PreferenciasDeApresentacao.atual()
	var painel := CadernoSemFoto.new()
	arvore.root.add_child(painel)
	var folha := PanelContainer.new()
	var desenho: Control = load("res://scripts/FolhaDoCaderno.gd").new()
	var baixo: Control = load("res://scripts/FolhaDoCaderno.gd").new()
	folha.add_child(desenho)
	painel.add_child(folha)
	painel.add_child(baixo)
	var completou: Array = []
	pref.definir_reduzir_movimento(false)
	var tw := painel.virar_folha(folha, desenho, baixo)
	tw.tween_callback(func() -> void: completou.append("em curso"))
	pref.definir_reduzir_movimento(true)
	conferir("mudar a meio conclui callback da transição", completou == ["em curso"])
	completou.clear()
	tw = painel.virar_folha(folha, desenho, baixo)
	tw.tween_callback(func() -> void: completou.append("reduzida"))
	tw.custom_step(0.001)
	conferir("transição reduzida conclui próximo callback sem espera", completou == ["reduzida"])
	painel.queue_free()
	await apoio.assentar()
