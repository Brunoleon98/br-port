extends RefCounted

class CopiadorDeTeste:
	extends Node
	signal concluida(sucesso: bool)
	var pedidos: Array[String] = []
	func copiar(texto: String) -> void:
		pedidos.append(texto)

var gs
var arvore: SceneTree
var falhas := 0
var completo := false
var apoio
var dados_de_layout: Dictionary


func conferir(nome: String, condicao: bool) -> void:
	print("PASS T28: " if condicao else "FAIL T28: ", nome)
	if not condicao:
		falhas += 1


func rodar(estado, tree: SceneTree) -> void:
	gs = estado
	arvore = tree
	# A fotografia já compara estado do registro e bytes/mtime dos arquivos.
	apoio = load("res://tests/casos_meu_porto.gd").new()
	apoio.gs = gs
	apoio.arvore = arvore
	var conteudo = load("res://scripts/DiagnosticoDoJogo.gd")
	var recurso := Resource.new()
	recurso.set_meta("formato", 1)
	recurso.set_meta("commit", "1234567890abcdef1234567890abcdef12345678")
	recurso.set_meta("modificado", true)
	var dados: Dictionary = conteudo.validar(recurso)
	dados_de_layout = dados
	conferir("identidade conserva commit completo e marca modificada", dados.size() == 2
		and dados["commit"] == "1234567890abcdef1234567890abcdef12345678"
		and conteudo.versao(dados) == "Build 1234567890 · modificado")
	recurso.set_meta("modificado", false)
	conferir("build limpo não recebe marca de modificado", conteudo.versao(conteudo.validar(recurso)) == "Build 1234567890")
	recurso.set_meta("commit", "invalido")
	conferir("identidade inválida não se apresenta como build", conteudo.validar(recurso).is_empty()
		and conteudo.validar(null).is_empty())
	conferir("editor não usa identidade possivelmente velha de outro export", not OS.has_feature("editor") or conteudo.identificacao().is_empty())
	var texto: String = conteudo.texto(dados)
	conferir("diagnóstico informa motor e plataforma reais", texto.contains("Godot: " + String(Engine.get_version_info()["string"]))
		and texto.contains("Plataforma: " + OS.get_name())
		and texto.contains("Renderização: " + RenderingServer.get_current_rendering_method()))
	gs._rng.seed = 42
	gs.comecar_no_espaco(1)
	gs.definir_nomes("PORTO_NAO_COMPARTILHAR", "PESSOA_NAO_COMPARTILHAR")
	if gs.phase == gs.ESTADO_OFERTA:
		gs.resolve_rival_offer(true)
	gs.advance_turn()
	gs.save_game()
	var inicio: Control = load("res://scenes/TelaInicial.tscn").instantiate()
	arvore.root.add_child(inicio)
	await apoio.assentar()
	await porta(inicio, inicio)
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
	await porta(pausa, main._overlay_layer, main)
	conferir("fechar consulta conserva a pausa", is_instance_valid(pausa) and not pausa.is_queued_for_deletion())
	main.queue_free()
	await apoio.assentar()
	arvore.root.get_node("Registro").desarmar()
	var copiador: Node = load("res://scripts/CopiaDoDiagnostico.gd").new()
	arvore.root.add_child(copiador)
	var resultados: Array = []
	copiador.concluida.connect(func(ok: bool): resultados.append(ok))
	if not OS.has_feature("web") and not DisplayServer.has_feature(DisplayServer.FEATURE_CLIPBOARD):
		copiador.copiar("teste")
		conferir("backend indisponível reprova a cópia", resultados == [false])
	copiador.queue_free()
	completo = true


func porta(origem: Node, pai: Node, dono: Node = null) -> void:
	# Um destino ausente revela até a regravação dos mesmos bytes no mesmo
	# segundo, que hash/mtime de um save existente não distinguem (`125`).
	var caminho: String = gs.save_path
	gs.save_path = caminho.get_base_dir().path_join("sonda_diagnostico.json")
	if FileAccess.file_exists(gs.save_path):
		DirAccess.remove_absolute(gs.save_path)
	var antes: Dictionary = apoio.fotografia()
	var botao: Button = apoio.botao(origem, "Versão e diagnóstico")
	conferir("porta de versão e diagnóstico existe", botao != null)
	if botao == null:
		return
	botao.pressed.emit()
	await apoio.assentar()
	var painel = pai.get_child(pai.get_child_count() - 1)
	conferir("as duas portas abrem a consulta compartilhada", painel.scene_file_path == "res://scenes/panels/PainelDiagnostico.tscn")
	if painel.scene_file_path != "res://scenes/panels/PainelDiagnostico.tscn":
		return
	var total := pai.get_child_count()
	botao.pressed.emit()
	await apoio.assentar()
	conferir("pedido repetido não empilha consulta", pai.get_child_count() == total)
	conferir("abrir não inicia cópia automaticamente", painel.tempo == &"consulta" and not painel._aviso.visible)
	var previa: String = painel._previa.text
	conferir("prévia exclui dados da partida e caminhos", not previa.contains("NAO_COMPARTILHAR")
		and not previa.contains("user://") and not previa.contains(gs.save_path)
		and previa.split("\n").size() in [5, 6])
	var falso := CopiadorDeTeste.new()
	painel.remove_child(painel._copiador)
	painel._copiador.queue_free()
	painel._copiador = falso
	painel.add_child(falso)
	falso.concluida.connect(painel._ao_copiar)
	painel._copiar.pressed.emit()
	conferir("copia exatamente a prévia por ação explícita", falso.pedidos == [previa])
	conferir("não confirma antes da resposta", painel._copiar.disabled and painel._aviso.text == "Aguardando a cópia…")
	painel._copiar.pressed.emit()
	conferir("toque repetido não inicia segunda cópia pendente", falso.pedidos.size() == 1)
	falso.concluida.emit(false)
	conferir("falha não anuncia sucesso e permite tentar de novo", painel.tempo == &"indisponivel"
		and painel._aviso.text.begins_with("Não foi possível copiar") and not painel._copiar.disabled)
	conferir("recusa da cópia mantém texto legível", legivel(painel))
	painel._copiar.pressed.emit()
	falso.concluida.emit(true)
	conferir("confirma somente a cópia concluída", painel.tempo == &"copiado"
		and painel._aviso.text.begins_with("Diagnóstico copiado"))
	conferir("confirmação da cópia mantém texto legível", legivel(painel))
	# No editor a prévia é mais curta. O pior caso vem do mesmo formatador,
	# com SHA completo e marca de modificado, sem copiar seu formato à mão.
	painel._previa.text = load("res://scripts/DiagnosticoDoJogo.gd").texto(dados_de_layout)
	await apoio.assentar()
	var voltar: Button = apoio.botao(painel, "Voltar")
	conferir("botões têm alvo e cabem na tela", voltar != null and voltar.size.y >= 44
		and painel._copiar.size.y >= 44 and painel.get_viewport_rect().encloses(voltar.get_global_rect())
		and painel.get_viewport_rect().encloses(painel._copiar.get_global_rect()))
	conferir("consulta e cópia preservam estado, RNG, arquivos e registro", apoio.fotografia() == antes)
	if dono == null:
		origem.notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	else:
		dono.notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	conferir("Voltar do aparelho fecha a consulta", painel.is_queued_for_deletion())
	await apoio.assentar()
	botao.pressed.emit()
	await apoio.assentar()
	painel = pai.get_child(pai.get_child_count() - 1)
	apoio.botao(painel, "Voltar").pressed.emit()
	conferir("botão Voltar fecha a consulta", painel.is_queued_for_deletion())
	await apoio.assentar()
	conferir("fechar preserva a partida", apoio.fotografia() == antes)
	gs.save_path = caminho


func legivel(painel: Node) -> bool:
	var motor = load("res://scripts/validation/contraste_ui.gd").new()
	var linhas: Array = motor.medir(painel)
	if linhas.is_empty():
		return false
	for linha in linhas:
		if linha["estado"] != "passa":
			return false
	return true
