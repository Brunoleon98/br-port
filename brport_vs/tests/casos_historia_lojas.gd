extends RefCounted

# T32: entra pelas lojas do celular, confirma/cancela com os botões visíveis
# e prova os direitos na retomada. Os defeitos ficam no catálogo (`141`).
var gs
var arvore: SceneTree
var falhas := 0
var completo := false


func conferir(nome: String, ok: bool) -> void:
	print("PASS T32: " if ok else "FAIL T32: ", nome)
	if not ok:
		falhas += 1


func assentar() -> void:
	await arvore.process_frame
	await arvore.process_frame


func nova() -> void:
	gs._rng.seed = 32
	gs.new_game()
	if gs.phase == gs.ESTADO_OFERTA:
		gs.resolve_rival_offer(true)
	gs.nome_porto = "Porto da História"
	gs.turn = 3
	gs.fila.clear()


func botao(no: Node, texto: String) -> Button:
	for b in no.find_children("*", "Button", true, false):
		if b.text == texto:
			return b
	return null


func tocar(no: Node, texto: String) -> bool:
	await assentar()
	var b := botao(no, texto)
	conferir("botão alcançável: " + texto, b != null and not b.disabled)
	if b == null or b.disabled:
		return false
	b.pressed.emit()
	await assentar()
	return true


func rotulos(no: Node) -> String:
	var textos := PackedStringArray()
	for l in no.find_children("*", "Label", true, false):
		textos.append(l.text)
	return "\n".join(textos)


func rodar(estado: Node, tree: SceneTree) -> void:
	gs = estado
	arvore = tree
	var caminho: String = gs.save_path
	var espaco: int = gs.espaco
	nova()
	var antigo := FileAccess.get_file_as_string("res://tests/saves/v18.json")
	var migrado: Dictionary = gs._save_aceite(antigo)
	var original: Dictionary = JSON.parse_string(antigo)
	conferir("18 migra sem perder saldo, fase, obra ou nomes", not migrado.is_empty()
		and migrado["cash"] == original["cash"]
		and migrado["numero_da_fase"] == original["numero_da_fase"]
		and migrado["obra_em_andamento"] == original["obra_em_andamento"]
		and migrado["nome_porto"] == original["nome_porto"])
	conferir("migração não inventa compras nem leituras", migrado.get("vida_do_porto") == VidaDoPorto.vazio()
		and migrado["dia_atual"]["lojas"] == 0
		and FileAccess.get_file_as_string("res://tests/saves/v18.json") == antigo)

	gs.cash = 179
	var baixo: int = gs.cash
	conferir("dinheiro insuficiente e id desconhecido não debitam", not gs.comprar_na_loja("cafe")
		and not gs.comprar_na_loja("inexistente") and gs.cash == baixo
		and gs.vida_do_porto == VidaDoPorto.vazio())
	gs.cash = 1000
	for fase in [gs.ESTADO_OFERTA, gs.ESTADO_COBRANCA, gs.ESTADO_FIM]:
		gs.phase = fase
		conferir("decisão pendente impede compra: " + fase, not gs.comprar_na_loja("cafe") and gs.cash == 1000)
	gs.phase = gs.ESTADO_JOGANDO
	conferir("compra debita uma vez e libera a conversa", gs.comprar_na_loja("cafe")
		and gs.cash == 820 and gs.capitulos_do_porto().has("cafe")
		and int(gs.dia_atual["lojas"]) == 180 and int(gs.semana_atual["lojas"]) == 180)
	conferir("clique repetido não duplica item nem cobrança", not gs.comprar_na_loja("cafe")
		and gs.cash == 820 and gs.vida_do_porto["compras"] == ["cafe"])
	var dia: Dictionary = gs.projecao_do_dia()
	var semana: Dictionary = gs.resumo_da_semana(1)
	conferir("dia e semana incluem a despesa já paga", int(dia["lojas"]) == 180
		and gs.resultado_do_dia(dia) == -180
		and int(semana["despesa"]) == 180 and int(semana["resultado"]) == -180)
	conferir("não conclui capítulo bloqueado", not gs.concluir_capitulo("envelope"))
	conferir("conclusão é idempotente", gs.concluir_capitulo("cafe") and not gs.concluir_capitulo("cafe"))
	gs.save_game()
	var salvo := FileAccess.get_file_as_string(gs.save_path)
	gs.vida_do_porto = VidaDoPorto.vazio()
	gs.cash = 0
	conferir("retomada conserva compra, leitura e dinheiro", gs.load_game() and gs.cash == 820
		and gs.vida_do_porto["compras"] == ["cafe"] and gs.vida_do_porto["cenas_lidas"] == ["cafe"])
	gs.advance_turn()
	conferir("virar dia não cobra compra novamente", gs.cash == 820 and int(gs.dia_anterior["lojas"]) == 180
		and int(gs.dia_atual["lojas"]) == 0)
	var ruim: Dictionary = JSON.parse_string(salvo)
	ruim["vida_do_porto"]["compras"] = ["cafe", "cafe"]
	conferir("save recusa compras duplicadas", gs._save_aceite(JSON.stringify(ruim)).is_empty())
	ruim = JSON.parse_string(salvo)
	ruim.erase("vida_do_porto")
	conferir("19 truncada não vira inventário vazio", gs._save_aceite(JSON.stringify(ruim)).is_empty())
	ruim = JSON.parse_string(salvo)
	ruim["dia_atual"]["lojas"] = -1
	conferir("save recusa despesa inválida", gs._save_aceite(JSON.stringify(ruim)).is_empty())
	ruim = JSON.parse_string(salvo)
	ruim["vida_do_porto"]["cenas_lidas"] = ["envelope"]
	conferir("save não permite ler cena antes do acontecimento", gs._save_aceite(JSON.stringify(ruim)).is_empty())
	gs.save_game()
	gs.comecar_no_espaco(2)
	conferir("outro espaço começa sem compras", gs.vida_do_porto == VidaDoPorto.vazio())
	gs.usar_espaco(espaco)
	conferir("voltar ao espaço recupera seus itens", gs.vida_do_porto["compras"] == ["cafe"])
	gs.save_path = caminho
	nova()
	conferir("jogo novo zera compras e cenas", gs.vida_do_porto == VidaDoPorto.vazio())

	# Condição temporal e acontecimento são independentes. Nenhum mês é
	# concluído só porque a parcela foi antecipada.
	gs.turn = 7
	conferir("caneca espera a primeira semana fechar", not gs.capitulos_do_porto().has("caneca"))
	gs.turn = 8
	conferir("caneca chega na semana seguinte", gs.capitulos_do_porto().has("caneca"))
	gs.parcelas_quitadas = 1
	gs.turn = 28
	conferir("antecipar parcela não antecipa capítulo", not gs.capitulos_do_porto().has("recibo"))
	gs.turn = 29
	conferir("recibo exige o mês fechado e parcela paga", gs.capitulos_do_porto().has("recibo"))
	gs.turn = 43
	gs.obra_em_andamento = {"id": "armazem", "inicio": 42, "conclusao": 44}
	conferir("obra não revela documentos", not gs.capitulos_do_porto().has("envelope"))
	gs.estruturas.append("armazem")
	gs.obra_em_andamento = {}
	conferir("armazém pronto revela envelope no meio da fase", gs.capitulos_do_porto().has("envelope"))
	var textos_completos := true
	for id in VidaDoPorto.CAPITULOS:
		var falas: Array = Narrativa.falas_da_historia(id)
		textos_completos = textos_completos and falas.size() >= 3
		for linha in falas:
			textos_completos = textos_completos and linha.size() == 3 and not String(linha[2]).is_empty()
	conferir("todo capítulo possui diálogo e cada fala tem texto", textos_completos)

	await _interface()
	gs.espaco = espaco
	gs.save_path = caminho
	nova()
	completo = true


func _interface() -> void:
	nova()
	var main = load("res://scenes/Main.tscn").instantiate()
	arvore.root.add_child(main)
	main._on_menu_pressed()
	var overlay: Node = main.get_node("Overlay")
	var menu: Node = overlay.get_child(overlay.get_child_count() - 1)
	var lojas := menu.find_child("Tile_lojas", true, false) as Button
	conferir("lojas estão abertas no celular", lojas != null)
	if lojas != null:
		lojas.pressed.emit()
	await assentar()
	var painel: Node = overlay.get_child(overlay.get_child_count() - 1)
	conferir("app abre catálogo de lojas", rotulos(painel).contains("MERCADO DA PRAÇA")
		and rotulos(painel).contains("DELIVERY DO MANÉ"))
	await tocar(painel, "Visitar o mercado")
	await tocar(painel, "Conversar com Seu Biu")
	conferir("visita tem interlocutor e fala", rotulos(painel).contains("Seu Biu")
		and rotulos(painel).contains("Seu avô escolhia o café"))
	await tocar(painel, "Continuar a conversa")
	await tocar(painel, "Concluir conversa")
	await tocar(painel, "Comprar Kit de café")
	var antes: int = gs.cash
	conferir("confirmação informa preço e efeito", rotulos(painel).contains("R$180")
		and rotulos(painel).contains("Café no cais"))
	await tocar(painel, "Voltar sem comprar")
	conferir("desistir preserva dinheiro e inventário", gs.cash == antes
		and gs.vida_do_porto["compras"].is_empty())
	await tocar(painel, "Comprar Kit de café")
	await tocar(painel, "Confirmar compra por R$180")
	conferir("confirmar compra abre a história e debita", gs.cash == antes - 180
		and rotulos(painel).contains("Esse cheiro chega na ponta do píer"))
	await tocar(painel, "Ler depois")
	await assentar()
	conferir("sair cedo não consome cena", not gs.vida_do_porto["cenas_lidas"].has("cafe"))
	main._on_historia_pedida("cafe")
	painel = overlay.get_child(overlay.get_child_count() - 1)
	for _i in range(3):
		await tocar(painel, "Continuar a conversa")
	await tocar(painel, "Concluir conversa")
	await assentar()
	conferir("ler até o fim grava conclusão", gs.vida_do_porto["cenas_lidas"].has("cafe"))
	# A oferta do capítulo entra pela pausa semanal, sem empilhar automaticamente
	# outra decisão. O botão é o caminho para quem não abre as lojas.
	gs.turn = 8
	var resumo: Dictionary = gs.resumo_da_semana(1)
	main._on_semana_fechada(resumo)
	await assentar()
	var boletim: Node = overlay.get_child(overlay.get_child_count() - 1)
	await tocar(boletim, "Ler história: A caneca que ficou")
	painel = overlay.get_child(overlay.get_child_count() - 1)
	conferir("boletim leva ao capítulo disponível", rotulos(painel).contains("Separei uma caneca a mais"))
	await tocar(painel, "Ler depois")
	await assentar()
	await tocar(boletim, "Fechar o boletim")
	main._on_menu_pressed()
	menu = overlay.get_child(overlay.get_child_count() - 1)
	lojas = menu.find_child("Tile_lojas", true, false) as Button
	lojas.pressed.emit()
	await assentar()
	painel = overlay.get_child(overlay.get_child_count() - 1)
	await tocar(painel, "Ver o delivery")
	await tocar(painel, "Conversar com Mané")
	conferir("delivery tem visita própria", rotulos(painel).contains("Entrega no cais?"))
	await tocar(painel, "Continuar a conversa")
	await tocar(painel, "Concluir conversa")
	await tocar(painel, "Comprar Almoço para a equipe")
	antes = gs.cash
	await tocar(painel, "Confirmar compra por R$240")
	conferir("delivery entrega item e conversa próprios", gs.cash == antes - 240
		and gs.vida_do_porto["compras"].has("almoco")
		and rotulos(painel).contains("quem senta na cabeceira"))
	await assentar()
	await assentar()
	arvore.root.remove_child(main)
	main.free()
	await assentar()
