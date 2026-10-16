extends RefCounted

var gs
var arvore: SceneTree
var falhas := 0
var completo := false
var artigos_compartilhados: Array = []


func conferir(nome: String, condicao: bool) -> void:
	print("PASS T25: " if condicao else "FAIL T25: ", nome)
	if not condicao:
		falhas += 1


func assentar() -> void:
	# A restauração da leitura espera o layout; a consulta espera dois frames.
	for i in range(5):
		await arvore.process_frame


func botao(no: Node, texto: String) -> Button:
	if no is Button and no.text == texto and not no.is_queued_for_deletion():
		return no
	for filho in no.get_children():
		var achado := botao(filho, texto)
		if achado != null:
			return achado
	return null


func tocar(no: Node, texto: String) -> bool:
	var alvo := botao(no, texto)
	conferir("botão alcançável: " + texto, alvo != null)
	if alvo == null:
		return false
	alvo.pressed.emit()
	return true


func clicar(posicao: Vector2) -> void:
	var movimento := InputEventMouseMotion.new()
	movimento.position = posicao
	arvore.root.push_input(movimento, true)
	await arvore.process_frame
	for pressionado in [true, false]:
		var evento := InputEventMouseButton.new()
		evento.position = posicao
		evento.button_index = MOUSE_BUTTON_LEFT
		evento.pressed = pressionado
		arvore.root.push_input(evento, true)
		await arvore.process_frame


func arquivos(pasta: String) -> Dictionary:
	var resultado := {}
	var dir := DirAccess.open(pasta)
	if dir == null:
		return resultado
	for nome in dir.get_files():
		var caminho := pasta.path_join(nome)
		resultado[caminho] = [FileAccess.get_sha256(caminho), FileAccess.get_modified_time(caminho)]
	for nome in dir.get_directories():
		resultado.merge(arquivos(pasta.path_join(nome)))
	return resultado


func fotografia() -> Dictionary:
	var estado := {}
	for propriedade in gs.get_property_list():
		var nome: String = propriedade["name"]
		if int(propriedade["usage"]) & PROPERTY_USAGE_SCRIPT_VARIABLE and not (gs.get(nome) is RandomNumberGenerator):
			estado[nome] = gs.get(nome)
	var registro: Node = arvore.root.get_node("Registro")
	return {"estado": var_to_str(estado), "rng": gs._rng.state,
		"arquivos": arquivos(String(gs.save_path).get_base_dir()),
		"registro": registro.texto_para_exportar(), "linhas": registro.linhas_gravadas()}


func consulta(origem: Node, pai: Node) -> void:
	# Controle positivo de hit-test: o mesmo botão recebe antes/depois e deve
	# ficar mudo sob o escurecimento, fora do cartão, durante a consulta.
	var recebidos: Array = []
	var alvo := Button.new()
	alvo.position = Vector2(12, 12)
	alvo.size = Vector2(60, 60)
	alvo.pressed.connect(func(): recebidos.append(true))
	var superficie: Node = origem if origem == pai else pai.get_child(0)
	superficie.add_child(alvo)
	await assentar()
	await clicar(alvo.get_global_rect().get_center())
	conferir("controle: botão de baixo recebe toque antes da ajuda", recebidos.size() == 1)
	recebidos.clear()
	var antes := fotografia()
	if not tocar(origem, "Como jogar"):
		return
	await assentar()
	var ajuda = pai.get_child(pai.get_child_count() - 1)
	conferir("a porta abre a cena compartilhada", ajuda.scene_file_path == "res://scenes/panels/PainelComoJogar.tscn")
	if ajuda.scene_file_path != "res://scenes/panels/PainelComoJogar.tscn":
		return
	await clicar(alvo.get_global_rect().get_center())
	conferir("toque no fundo não atravessa a ajuda", recebidos.is_empty())
	conferir("abre pelo índice com seis assuntos e glossário", ajuda.tempo == &"indice" and ajuda.artigos.size() == 7)
	if artigos_compartilhados.is_empty():
		artigos_compartilhados = ajuda.artigos.duplicate(true)
	conferir("mesmo conteúdo em todas as origens e fases", ajuda.artigos == artigos_compartilhados)
	var quantidade := pai.get_child_count()
	tocar(origem, "Como jogar")
	await assentar()
	conferir("pedido repetido não duplica ajuda", pai.get_child_count() == quantidade)
	if pai.get_child_count() != quantidade:
		return
	var artigos: Array = ajuda.artigos.duplicate(true)
	for artigo in artigos:
		tocar(ajuda, artigo["titulo"])
		await assentar()
		conferir("artigo selecionado: " + artigo["id"], ajuda.assunto_atual == artigo["id"]
			and ajuda.find_child("Corpo", true, false).text == artigo["texto"])
		# O Voltar real do dono deve subir um nível, sem dispensar o painel.
		origem.notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
		await assentar()
		conferir("Voltar retorna ao índice: " + artigo["id"], is_instance_valid(ajuda)
			and not ajuda.is_queued_for_deletion() and ajuda.tempo == &"indice")
		if not is_instance_valid(ajuda) or ajuda.is_queued_for_deletion():
			return
	# Os botões também percorrem artigo → índice → origem.
	tocar(ajuda, "Glossário")
	await assentar()
	var rolo: ScrollContainer = ajuda.find_child("Leitura", true, false)
	rolo.scroll_vertical = 90
	await assentar()
	var posicao := rolo.scroll_vertical
	conferir("glossário realmente rola", posicao > 0)
	var area: Rect2 = ajuda.get_viewport_rect()
	var voltar := botao(ajuda, "Assuntos")
	conferir("botão de retorno fica fora da rolagem e dentro da tela", area.encloses(voltar.get_global_rect())
		and voltar.size.y >= 44 and not rolo.is_ancestor_of(voltar))
	tocar(ajuda, "Assuntos")
	await assentar()
	tocar(ajuda, "Glossário")
	await assentar()
	conferir("consulta conserva posição do artigo", ajuda.find_child("Leitura", true, false).scroll_vertical == posicao)
	tocar(ajuda, "Assuntos")
	await assentar()
	tocar(ajuda, "Fechar")
	await assentar()
	conferir("Fechar dispensa a consulta", not is_instance_valid(ajuda))
	conferir("consulta preserva estado, RNG, arquivos e registro", fotografia() == antes)
	await clicar(alvo.get_global_rect().get_center())
	conferir("controle: toque volta a alcançar a origem", recebidos.size() == 1)
	# Reabrir não restaura a página da consulta anterior.
	if not tocar(origem, "Como jogar"):
		return
	await assentar()
	ajuda = pai.get_child(pai.get_child_count() - 1)
	conferir("reabrir começa no índice", ajuda.tempo == &"indice")
	origem.notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	await assentar()
	conferir("Voltar no índice retorna à origem", not is_instance_valid(ajuda))
	conferir("fechar por Voltar também preserva tudo", fotografia() == antes)


func rodar(estado, tree: SceneTree) -> void:
	gs = estado
	arvore = tree
	var tema: Theme = load("res://ui/tema_brport.tres")
	for n in range(1, int(gs.ESPACOS) + 1):
		gs.apagar_espaco(n)
	gs._rng.seed = 42
	gs.new_game()
	gs.definir_nomes("Cais da consulta", "Teste")
	var conteudo = load("res://scripts/ConteudoComoJogar.gd")
	var artigos: Array = conteudo.artigos(gs)
	conferir("espaços e cobranças vêm das regras", artigos[3]["texto"].contains(Narrativa.por_extenso(gs.ESPACOS) + " espaços")
		and artigos[5]["texto"].contains(Narrativa.por_extenso(gs.parcelas_na_fase(1)) + " cobranças"))
	conferir("custos reais e regra sem parcial na ajuda", artigos[4]["texto"].contains(str(int(gs.CANCELAMENTO_MULTA * 100)) + " por cento")
		and artigos[4]["texto"].contains(str(int(gs.CANCELAMENTO_REPUTACAO)) + " pontos")
		and artigos[4]["texto"].contains("sem pagamento parcial"))
	# Hash e mtime veem alterações no disco; esta guarda adicional reprova até
	# uma gravação idêntica no mesmo segundo, que os dois não distinguiriam.
	for script in ["PainelComoJogar", "ConteudoComoJogar"]:
		var fonte := FileAccess.get_file_as_string("res://scripts/%s.gd" % script)
		conferir("consulta não tem porta de escrita: " + script,
			not fonte.contains("save_game(") and not fonte.contains("FileAccess.WRITE")
			and not fonte.contains("new_game(") and not fonte.contains(".armar("))
	for ocupado in [false, true]:
		for n in range(1, int(gs.ESPACOS) + 1):
			gs.apagar_espaco(n)
		if ocupado:
			gs.save_game()
		var inicio = load("res://scenes/TelaInicial.tscn").instantiate()
		inicio.theme = tema
		arvore.root.add_child(inicio)
		await assentar()
		conferir("ajuda sem depender de save (ocupado=%s)" % ocupado, botao(inicio, "Como jogar") != null)
		await consulta(inicio, inicio)
		inicio.free()
	# As duas fases, serviço iniciado, saldo negativo e meta conquistada.
	for caso in ["fase1", "iniciado", "negativo", "livre", "fim"]:
		gs.new_game()
		gs.definir_nomes("Cais da consulta", "Teste")
		gs.phase = gs.ESTADO_JOGANDO
		if caso != "fase1":
			gs.numero_da_fase = 2
			gs.turn = 86
		if caso == "iniciado":
			gs.estruturas = ["pier_2", "trelica"]
			gs.docks[0]["boat"] = {"id": 999, "value": 10000, "classe": "medio", "motivo": "conteiner", "op_turns": 2, "progress": 1, "matched": false, "rival": false}
			gs.docks[0]["worker_id"] = gs.workers[0]["id"]
			gs.workers[0]["busy_turns"] = 1
		if caso == "negativo":
			gs.cash = -1000
		if caso == "livre":
			gs.meta_concluida = true
		if caso == "fim":
			gs.phase = gs.ESTADO_FIM
		var porto = load("res://scenes/Main.tscn").instantiate()
		arvore.root.add_child(porto)
		await assentar()
		var overlay: CanvasLayer = porto.get_node("Overlay")
		for painel in overlay.get_children():
			painel.free()
		porto._on_pause_pressed()
		await assentar()
		var pausa: Node = overlay.get_child(0)
		await consulta(porto, overlay)
		conferir("pausa permanece na origem: " + caso, is_instance_valid(pausa)
			and not pausa.is_queued_for_deletion() and overlay.get_child_count() == 1)
		porto.free()
		arvore.root.get_node("Registro").desarmar()
	await proporcoes(tema)
	completo = true


func proporcoes(tema: Theme) -> void:
	for tamanho in [Vector2i(720, 1280), Vector2i(720, 1600), Vector2i(720, 1152)]:
		var tela := SubViewport.new()
		tela.size = tamanho
		arvore.root.add_child(tela)
		var ajuda = load("res://scenes/panels/PainelComoJogar.tscn").instantiate()
		ajuda.theme = tema
		tela.add_child(ajuda)
		await assentar()
		var area := Rect2(Vector2.ZERO, Vector2(tamanho))
		for titulo in ["Atracar e atender", "Avançar o dia", "Dinheiro e semana", "Salvar e retomar", "Devolver ou cancelar", "Fases e metas", "Glossário", "Fechar"]:
			var alvo := botao(ajuda, titulo)
			conferir("índice alcançável em %s: %s" % [tamanho, titulo], alvo != null
				and area.encloses(alvo.get_global_rect()) and alvo.size.y >= 44)
		tocar(ajuda, "Glossário")
		await assentar()
		var leitura: ScrollContainer = ajuda.find_child("Leitura", true, false)
		leitura.scroll_vertical = 100000
		await assentar()
		var barra := leitura.get_v_scroll_bar()
		conferir("fim do glossário alcançável em %s" % tamanho, leitura.scroll_vertical > 0
			and absf(float(leitura.scroll_vertical) - (barra.max_value - barra.page)) <= 1.0)
		conferir("retorno visível no fim em %s" % tamanho, area.encloses(botao(ajuda, "Assuntos").get_global_rect()))
		tela.free()
