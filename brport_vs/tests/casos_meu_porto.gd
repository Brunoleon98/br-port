extends RefCounted

var gs
var arvore: SceneTree
var falhas := 0
var completo := false
var conteudo


func conferir(nome: String, condicao: bool) -> void:
	print("PASS T27: " if condicao else "FAIL T27: ", nome)
	if not condicao:
		falhas += 1


func assentar() -> void:
	for i in range(5):
		await arvore.process_frame


func botao(no: Node, texto: String) -> Button:
	if no is Button and no.text == texto:
		return no
	for filho in no.get_children():
		var achado := botao(filho, texto)
		if achado != null:
			return achado
	return null


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
	var estado_registro := {}
	for propriedade in registro.get_property_list():
		var nome: String = propriedade["name"]
		if int(propriedade["usage"]) & PROPERTY_USAGE_SCRIPT_VARIABLE:
			estado_registro[nome] = registro.get(nome)
	return {"estado": var_to_str(estado), "rng": gs._rng.state,
		"arquivos": arquivos(String(gs.save_path).get_base_dir()),
		"registro": registro.texto_para_exportar(), "linhas": registro.linhas_gravadas(),
		"estado_registro": var_to_str(estado_registro)}


func novo() -> void:
	gs._rng.seed = 42
	gs.comecar_no_espaco(1)
	gs.definir_nomes("Cais da retomada", "Teste")
	if gs.phase == gs.ESTADO_OFERTA:
		gs.resolve_rival_offer(true)
	gs.cash = 10000000


func avancar() -> void:
	if gs.phase == gs.ESTADO_OFERTA:
		gs.resolve_rival_offer(true)
	elif gs.phase == gs.ESTADO_COBRANCA:
		gs.pay_debt()
	else:
		gs.advance_turn()


func ate_fase_2() -> void:
	novo()
	for passo in range(150):
		if gs.numero_da_fase == 2:
			break
		avancar()
	conferir("controle: partida chega à Fase 2", gs.numero_da_fase == 2)
	if gs.phase == gs.ESTADO_OFERTA:
		gs.resolve_rival_offer(true)


func painel(disponivel: bool = true) -> Control:
	var no: Control = load("res://scenes/panels/PainelMeuPorto.tscn").instantiate()
	no.theme = load("res://ui/tema_brport.tres")
	arvore.root.add_child(no)
	no.setup(disponivel)
	return no


func ler() -> Dictionary:
	# Bytes/mtime sozinhos não veem regravar o mesmo JSON no mesmo segundo.
	# Um destino ainda ausente torna até essa escrita observável pelo teste.
	var caminho: String = gs.save_path
	gs.save_path = caminho.get_base_dir().path_join("sonda_consulta.json")
	if FileAccess.file_exists(gs.save_path):
		DirAccess.remove_absolute(gs.save_path)
	var antes := fotografia()
	var r: Dictionary = conteudo.resumir(gs)
	conferir("gerar conteúdo preserva estado, RNG, arquivos e registro", fotografia() == antes)
	gs.save_path = caminho
	return r


func rodar(estado, tree: SceneTree) -> void:
	gs = estado
	arvore = tree
	conteudo = load("res://scripts/ConteudoMeuPorto.gd")
	arvore.root.get_node("Registro").desarmar()
	for n in range(1, int(gs.ESPACOS) + 1):
		gs.apagar_espaco(n)
	novo()
	var r := ler()
	conferir("Fase 1 usa dia, saldo e meta reais", r["dia"].contains("Fase 1")
		and r["dia"].contains(gs.rotulo_do_dia(gs.turn)) and r["caixa"] == gs.moeda(gs.cash)
		and r["meta"].contains("0 de %d" % gs.parcelas_na_fase()))
	conferir("porto sem obras nem serviços é explícito", r["obra"] == "Nenhuma obra em andamento." and r["servicos"].is_empty())
	gs.emprestimo_devido = 12345
	r = ler()
	conferir("boleto inclui segunda chance", r["cobranca"].contains(gs.moeda(gs.principal_da_parcela())))
	gs.emprestimo_devido = 0
	conferir("controle: antecipação aceita", gs.pagar_parcela_adiantado())
	r = ler()
	conferir("antecipação mantém recibo e próxima cobrança futura", r["cobranca"].contains("Parcela 1 quitada")
		and r["cobranca"].contains(gs.moeda(gs.valor_da_parcela(1)))
		and r["cobranca"].contains("dia %d" % gs.dia_da_parcela(1))
		and r["cobranca"].contains("Ainda não aberta"))
	conferir("controle: compra real inicia obra", gs.comprar_estrutura("pier_2"))
	r = ler()
	conferir("obra usa prazo real e dias restantes", r["obra"].contains(gs.prazo_da_obra(gs.obra_em_andamento["conclusao"]))
		and r["obra"].contains(Narrativa.concordar(gs.dias_restantes_da_obra(), "dia", "dias")))
	# O prazo prometido é conferido contra o dia em que a estrutura abre.
	var abre: int = gs.obra_em_andamento["conclusao"]
	for passo in range(6):
		if gs.tem_estrutura("pier_2"):
			break
		avancar()
	conferir("prazo mostrado corresponde à conclusão no jogo", gs.tem_estrutura("pier_2") and gs.turn == abre)
	gs.turn = gs.ultimo_dia_da_fase() - gs.dias_da_obra("armazem") + 1
	gs.parcela_indice = 2
	gs.parcelas_quitadas = 3
	gs.parcela_paid = true
	conferir("controle: obra no último fecho inicia", gs.comprar_estrutura("armazem"))
	r = ler()
	conferir("obra do último fecho não promete dia inexistente", r["obra"].contains("fim do dia %d" % gs.ultimo_dia_da_fase())
		and r["obra"].contains("não será usado nesta fase"))
	conferir("última antecipação não inventa parcela seguinte", r["cobranca"].contains("Todas as parcelas")
		and not r["cobranca"].contains("Próxima cobrança"))
	novo()
	gs.turn = gs.vencimento_da_parcela()
	gs.advance_turn()
	r = ler()
	conferir("vencimento identifica dia fechado sem adiantar decisão", gs.phase == gs.ESTADO_COBRANCA
		and r["situacao"].contains("dia %d" % gs.vencimento_da_parcela())
		and r["cobranca"].contains("Cobrança pendente")
		and r["dia"].contains(gs.rotulo_do_dia(gs.vencimento_da_parcela())) and r["dia"].ends_with("encerrado")
		and r["semana"] == "Semana %d" % gs.week_of(gs.vencimento_da_parcela()))

	ate_fase_2()
	r = ler()
	conferir("Fase 2 sem cobrança nem prazo fictícios", r["cobranca"] == "Sem cobranças nesta fase."
		and r["meta"].contains("sem prazo") and not r["dia"].contains(" de "))
	var bancada = load("res://tools/estado_da_bancada.gd")
	for id in ["pier_2", "armazem", "patio", "trelica"]:
		bancada.instalar(gs, id)
	conferir("controle: píer 3 comprado ainda em obra", gs.comprar_estrutura("pier_3"))
	r = ler()
	conferir("meta não conta estrutura ainda em obra", r["meta"].contains("1 de 2 estruturas concluídas"))
	for passo in range(8):
		if gs.tem_estrutura("pier_3"):
			break
		avancar()
	if gs.phase == gs.ESTADO_OFERTA:
		gs.resolve_rival_offer(true)
	gs.dias_de_reputacao = 1
	r = ler()
	conferir("meta lê dias fechados e infraestrutura pronta", r["meta"].contains("1 de %d dias" % gs.dados_da_fase()["meta"]["dias"])
		and r["meta"].contains("2 de 2 estruturas concluídas") and r["meta"].contains("0 de 1"))
	# Sorteio real de cargueiro com bônus. A duração é a contratada, mesmo
	# se uma estrutura mudar depois; não se chama o cálculo de barco novo.
	var barco: Dictionary = {}
	for tentativa in range(150):
		var candidato: Dictionary = gs._make_boat()
		if candidato["classe"] == "medio" and candidato["motivo"] == "armazenagem":
			barco = candidato
			break
	conferir("controle: cargueiro com armazenagem sorteado", not barco.is_empty())
	if barco.is_empty():
		return
	gs.fila = [barco]
	conferir("controle: serviço contratado pela atracação", gs.atracar(0))
	gs.advance_turn()
	if gs.phase == gs.ESTADO_OFERTA:
		gs.resolve_rival_offer(true)
	r = ler()
	var doca: Dictionary = gs.docks[0]
	var recebimento: int = gs.receita_da_doca(0)
	conferir("serviço mostra progresso guardado e receita com bônus", r["servicos"].size() == 1
		and r["servicos"][0].contains("%d de %d" % [doca["boat"]["progress"], doca["boat"]["op_turns"]])
		and r["servicos"][0].contains(gs.moeda(recebimento)) and recebimento > int(doca["boat"]["value"]))
	var bruto_antes: int = gs.metrics["revenue"]
	var faltam: int = int(doca["boat"]["op_turns"]) - int(doca["boat"]["progress"])
	for dia in range(faltam):
		if gs.phase == gs.ESTADO_OFERTA:
			gs.resolve_rival_offer(true)
		gs.advance_turn()
	conferir("recebimento mostrado confere com entrega real", gs.docks[0]["boat"] == null
		and int(gs.metrics["revenue"]) - bruto_antes == recebimento and gs.primeiro_cargueiro)
	if gs.phase == gs.ESTADO_OFERTA:
		gs.resolve_rival_offer(true)
	gs.fila = [barco.duplicate(true)]
	gs.fila[0]["progress"] = 0
	conferir("controle: outro serviço atraca", gs.atracar(0))
	gs.docks[0]["worker_id"] = null
	r = ler()
	conferir("sem trabalhador não promete recebimento", r["servicos"][0].contains("sem recebimento previsto")
		and not r["servicos"][0].contains("Recebimento previsto:"))
	gs.dias_de_reputacao = gs.dados_da_fase()["meta"]["dias"]
	gs.primeiro_cargueiro = true
	gs.meta_concluida = true
	r = ler()
	conferir("jogo livre conserva conquista sem novo objetivo", r["meta"].contains("jogo livre")
		and not r["meta"].contains("0 de") and r["cobranca"] == "Sem cobranças nesta fase.")
	gs.cash = -321
	gs._end_game(false, "O dinheiro acabou. Operação inviável.")
	r = ler()
	conferir("encerramento e caixa negativo são reais", r["situacao"].contains(gs.end_reason)
		and r["situacao"].contains("Partida encerrada") and r["caixa"] == gs.moeda(-321))
	conferir("conquista fica registrada após encerramento", r["meta"].contains("concluída antes do encerramento"))
	novo()
	conferir("controle: obra e serviço antes do encerramento", gs.comprar_estrutura("pier_2") and gs.atracar(0))
	gs.cash = -321
	gs._end_game(false, "O dinheiro acabou. Operação inviável.")
	r = ler()
	conferir("encerrada não promete obra nem recebimento futuros", r["encerrada"]
		and r["obra"].contains("interrompida") and not r["obra"].contains("pronto no dia")
		and r["servicos"][0].contains("Atendimento interrompido")
		and not r["servicos"][0].contains("Recebimento previsto:") and not r["meta"].contains("Quitar"))
	await interface_e_fluxo()
	completo = true


func interface_e_fluxo() -> void:
	ate_fase_2()
	var bancada = load("res://tools/estado_da_bancada.gd")
	for id in ["pier_2", "armazem", "patio", "pier_3", "trelica"]:
		bancada.instalar(gs, id)
	for i in range(3):
		gs.fila = [gs._make_boat()]
		conferir("controle: doca ocupada para layout %d" % i, gs.atracar(0))
	gs.save_game()
	arvore.root.get_node("Registro").armar()
	var antes := fotografia()
	var no := painel()
	var entradas_indevidas: Array = []
	no.entrar_no_porto.connect(func(): entradas_indevidas.append(true))
	await assentar()
	var ir := botao(no, "Ir ao porto")
	var voltar := botao(no, "Voltar ao início")
	conferir("botões acessíveis fora da leitura", ir != null and voltar != null
		and ir.size.y >= 44 and voltar.size.y >= 44
		and no.get_viewport_rect().encloses(ir.get_global_rect())
		and no.get_viewport_rect().encloses(voltar.get_global_rect()))
	var motor = load("res://scripts/validation/contraste_ui.gd").new()
	var linhas: Array = motor.medir(no)
	var legivel := not linhas.is_empty()
	for linha in linhas:
		legivel = legivel and linha["estado"] == "passa"
	conferir("resumo tem contraste medido sem pendências", legivel)
	var rolo: ScrollContainer = no.find_child("Leitura", true, false)
	rolo.scroll_vertical = 10000
	await assentar()
	conferir("leitura alcança meta e botões continuam fora da rolagem", rolo.scroll_vertical > 0
		and not rolo.is_ancestor_of(voltar) and not rolo.is_ancestor_of(ir))
	voltar.pressed.emit()
	await assentar()
	conferir("consulta visual preserva estado, RNG, arquivos e registro", fotografia() == antes and entradas_indevidas.is_empty())
	arvore.root.get_node("Registro").desarmar()

	# A inicial real carrega o espaço 2 escolhido, não a partida viva do 1.
	gs.comecar_no_espaco(2)
	gs.definir_nomes("Segundo porto", "Outra pessoa")
	gs.cash = 123456
	gs.save_game()
	gs.usar_espaco(1)
	var inicio = load("res://scenes/TelaInicial.tscn").instantiate()
	arvore.root.add_child(inicio)
	var recente: Dictionary = gs.resumo_do_espaco(gs.espaco_mais_recente())
	inicio._continuar()
	await assentar()
	var resumo = inicio.get_child(inicio.get_child_count() - 1)
	conferir("Continuar abre resumo do mais recente sem criar Main", resumo.scene_file_path == "res://scenes/panels/PainelMeuPorto.tscn"
		and gs.espaco == recente["espaco"] and resumo.resumo["porto"] == recente["porto"]
		and arvore.root.find_child("Main", true, false) == null)
	var quantidade: int = inicio.get_child_count()
	inicio._continuar()
	conferir("retomada repetida não duplica painel", inicio.get_child_count() == quantidade)
	antes = fotografia()
	inicio.notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	await assentar()
	conferir("Voltar do aparelho fica na inicial e preserva consulta", not is_instance_valid(resumo)
		and is_instance_valid(inicio) and fotografia() == antes)
	inicio._abrir_espacos("carregar")
	var espacos = inicio.get_child(inicio.get_child_count() - 1)
	botao(espacos.find_child("Espaco2", true, false), "Carregar").pressed.emit()
	await assentar()
	resumo = inicio.get_child(inicio.get_child_count() - 1)
	conferir("Carregar mostra o espaço escolhido", gs.espaco == 2 and resumo.resumo["porto"] == "Segundo porto"
		and resumo.resumo["caixa"] == gs.moeda(123456))
	var entradas: Array = []
	resumo.entrar_no_porto.connect(func(): entradas.append(true))
	# Desliga só a troca de cena para provar a ação e a carga única; abaixo
	# a cena do porto REAL comprova a recuperação das decisões persistidas.
	resumo.entrar_no_porto.disconnect(inicio._ir_para_o_porto)
	antes = fotografia()
	botao(resumo, "Ir ao porto").pressed.emit()
	await assentar()
	conferir("Ir ao porto emite entrada única sem recarregar", entradas.size() == 1 and fotografia() == antes)
	arvore.root.remove_child(inicio)
	inicio.free()
	for estado_pendente in [gs.ESTADO_OFERTA, gs.ESTADO_COBRANCA, gs.ESTADO_FIM]:
		novo()
		if estado_pendente == gs.ESTADO_OFERTA:
			gs._rng.seed = 0
			gs.fila = []
			gs._spawn_boats()
		elif estado_pendente == gs.ESTADO_COBRANCA:
			gs.turn = gs.vencimento_da_parcela()
			gs.advance_turn()
		else:
			gs._end_game(false, "Fim do teste")
		conferir("controle: estado pendente alcançado " + estado_pendente, gs.phase == estado_pendente)
		gs.save_game()
		inicio = load("res://scenes/TelaInicial.tscn").instantiate()
		arvore.root.add_child(inicio)
		inicio._continuar()
		await assentar()
		resumo = inicio.get_child(inicio.get_child_count() - 1)
		var recuperada := String(gs.phase)
		conferir("consulta mantém decisão pendente " + estado_pendente, resumo.tempo == &"resumo" and recuperada == estado_pendente)
		# A troca de cena verdadeira prova o botão da inicial, além do sinal.
		arvore.current_scene = inicio
		botao(resumo, "Ir ao porto").pressed.emit()
		await assentar()
		var main = arvore.current_scene
		var entrou: bool = main != null and main.scene_file_path == "res://scenes/Main.tscn"
		conferir("Ir ao porto troca para a cena real " + estado_pendente, entrou)
		if not entrou:
			arvore.current_scene = null
			if is_instance_valid(inicio):
				arvore.root.remove_child(inicio)
				inicio.free()
			continue
		var cena: String = {"rival_offer": "CounterOfferPanel.tscn", "debt_payment": "DebtPaymentPanel.tscn", "game_over": "EndGame.tscn"}[estado_pendente]
		var overlay: Node = main.get_node("Overlay")
		conferir("porto recupera painel original " + estado_pendente, overlay.get_child_count() == 1
			and overlay.get_child(0).scene_file_path.ends_with(cena) and gs.phase == recuperada)
		arvore.current_scene = null
		arvore.root.remove_child(main)
		main.free()
		arvore.root.get_node("Registro").desarmar()
	# Um arquivo que mudou entre a lista e o toque não pode criar partida nova.
	novo()
	inicio = load("res://scenes/TelaInicial.tscn").instantiate()
	arvore.root.add_child(inicio)
	var caminho: String = gs.save_path
	var file := FileAccess.open(caminho, FileAccess.WRITE)
	file.store_string("{}")
	file.close()
	antes = fotografia()
	inicio._continuar()
	await assentar()
	resumo = inicio.get_child(inicio.get_child_count() - 1)
	conferir("recusa não inicia partida nem apaga arquivo", resumo.tempo == &"indisponivel"
		and botao(resumo, "Ir ao porto") == null and fotografia() == antes)
	inicio.notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	await assentar()
	arvore.root.remove_child(inicio)
	inicio.free()
	# As duas portas de partida nova continuam sem resumo de retomada.
	for primeira_instalacao in [false, true]:
		if primeira_instalacao:
			for n in range(1, int(gs.ESPACOS) + 1):
				gs.apagar_espaco(n)
		else:
			novo()
		inicio = load("res://scenes/TelaInicial.tscn").instantiate()
		arvore.root.add_child(inicio)
		arvore.current_scene = inicio
		if primeira_instalacao:
			botao(inicio, "Nova partida").pressed.emit()
		else:
			inicio._ao_escolher_espaco(3, "nova")
		await assentar()
		var main = arvore.current_scene
		conferir("partida nova segue sem resumo: instalação %s" % primeira_instalacao,
			main != null and main.scene_file_path == "res://scenes/Main.tscn"
			and main.find_child("PainelMeuPorto", true, false) == null and gs.turn == 1 and gs.nome_porto == "")
		arvore.current_scene = null
		if main != null:
			arvore.root.remove_child(main)
			main.free()
		arvore.root.get_node("Registro").desarmar()
	novo()
