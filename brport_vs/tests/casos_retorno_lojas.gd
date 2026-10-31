extends RefCounted

# T34 entra pelos mesmos botões do jogador. Cada percurso tem bandeira própria:
# um erro numa função chamada não pode transformar a volta esperada em verde.
var gs
var arvore: SceneTree
var falhas := 0
var completo := false
var _lojas_completas := {}
var _arquivo_completo := false
var _boletim_completo := false


func conferir(nome: String, ok: bool) -> void:
	print("PASS T34: " if ok else "FAIL T34: ", nome)
	if not ok:
		falhas += 1


func assentar() -> void:
	await arvore.process_frame
	await arvore.process_frame


func botao(no: Node, texto: String) -> Button:
	if not is_instance_valid(no):
		return null
	for b in no.find_children("*", "Button", true, false):
		if b.text == texto:
			return b
	return null


func rotulos(no: Node) -> String:
	if not is_instance_valid(no):
		return ""
	var textos := PackedStringArray()
	for l in no.find_children("*", "Label", true, false):
		textos.append(l.text)
	return "\n".join(textos)


func tocar(no: Node, texto: String) -> void:
	# Cada toque já deixa dois frames para o próximo. Esperar outra vez antes
	# dele duplicava a espera e fazia este percurso atingir o vigia da suíte.
	var b := botao(no, texto)
	conferir("botão alcançável: " + texto, b != null and not b.disabled)
	if b != null and not b.disabled:
		b.pressed.emit()
	await assentar()


func ate_o_final(painel: Node) -> void:
	# Um teto limita o percurso com defeito; o botão de conclusão é a segunda
	# fonte, sem copiar o tamanho da lista de falas que o painel consome.
	for _i in range(12):
		if botao(painel, "Continuar a conversa") == null:
			break
		await tocar(painel, "Continuar a conversa")
	conferir("chegou ao botão de conclusão", botao(painel, "Concluir conversa") != null)


func abrir() -> Node:
	gs._rng.seed = 34
	gs.new_game()
	if gs.phase == gs.ESTADO_OFERTA:
		gs.resolve_rival_offer(true)
	gs.nome_porto = "Porto dos Retornos"
	gs.turn = 8
	gs.fila.clear()
	var main = load("res://scenes/Main.tscn").instantiate()
	arvore.root.add_child(main)
	main._on_menu_pressed()
	var overlay: Node = main.get_node("Overlay")
	var menu: Node = overlay.get_child(overlay.get_child_count() - 1)
	var lojas := menu.find_child("Tile_lojas", true, false) as Button
	conferir("entrada das lojas no celular", lojas != null)
	if lojas != null:
		lojas.pressed.emit()
	return main


func fechar(main: Node) -> void:
	arvore.root.remove_child(main)
	main.free()
	await assentar()


func rodar(estado: Node, tree: SceneTree) -> void:
	gs = estado
	arvore = tree
	for loja in ["mercado", "delivery"]:
		await percurso_da_loja(loja)
		conferir("percurso completo: " + loja, _lojas_completas.has(loja))
	await percurso_do_arquivo()
	conferir("percurso completo: arquivo", _arquivo_completo)
	await percurso_do_boletim()
	conferir("percurso completo: boletim", _boletim_completo)
	gs.new_game()
	completo = true


func percurso_da_loja(loja: String) -> void:
	var mercado := loja == "mercado"
	var produto := "cafe" if mercado else "almoco"
	var nome_item := "Kit de café" if mercado else "Almoço para a equipe"
	var preco := 180 if mercado else 240
	var nome_cena := "Café no cais" if mercado else "A mesa do cais"
	var conversar := "Conversar com Seu Biu" if mercado else "Conversar com Mané"
	var retorno := "Voltar ao mercado" if mercado else "Voltar ao delivery"
	var primeira := "Seu avô escolhia o café" if mercado else "Entrega no cais?"
	var reencontro := "E o café lá no cais, chefia? O pessoal gostou?" if mercado \
		else "E o almoço, chefia? Deu pra sentar com o pessoal?"
	var main := abrir()
	await assentar()
	var overlay: Node = main.get_node("Overlay")
	var painel: Node = overlay.get_child(overlay.get_child_count() - 1)
	await tocar(painel, "Visitar o mercado" if mercado else "Ver o delivery")
	await tocar(painel, conversar)
	conferir("primeira visita preservada: " + loja, rotulos(painel).contains(primeira))
	await tocar(painel, retorno)
	conferir("interromper visita volta à loja: " + loja, botao(painel, conversar) != null)
	await tocar(painel, conversar)
	await ate_o_final(painel)
	await tocar(painel, "Concluir conversa")
	conferir("concluir visita volta à loja: " + loja, botao(painel, conversar) != null)
	await tocar(painel, "Comprar " + nome_item)
	var antes: int = gs.cash
	await tocar(painel, "Confirmar compra por " + gs.moeda(preco))
	await ate_o_final(painel)
	# Ver a última fala ainda não é concluir: interromper aqui tem de conservar
	# tanto o direito comprado quanto a pendência de leitura.
	await tocar(painel, retorno)
	conferir("compra volta à loja com item visível: " + loja,
		botao(painel, "Ler a conversa") != null and rotulos(painel).contains("Já comprado."))
	conferir("interromper preserva compra e leitura pendente: " + loja,
		gs.vida_do_porto["compras"].has(produto) and not gs.vida_do_porto["cenas_lidas"].has(produto)
		and gs.cash == antes - preco)
	await tocar(painel, conversar)
	conferir("comprar sem concluir não antecipa reencontro: " + loja, rotulos(painel).contains(primeira))
	await tocar(painel, retorno)
	await tocar(painel, "Ler a conversa")
	await ate_o_final(painel)
	await tocar(painel, "Concluir conversa")
	conferir("concluir compra volta à loja e grava leitura: " + loja,
		botao(painel, conversar) != null and gs.vida_do_porto["cenas_lidas"].has(produto))
	await tocar(painel, conversar)
	conferir("reencontro acompanha cena concluída: " + loja, rotulos(painel).contains(reencontro))
	await tocar(painel, "Continuar a conversa")
	conferir("reencontro tem remate próprio: " + loja, rotulos(painel).contains(
		"manda ele tomar mais devagar" if mercado else "respeitado o prato da Cida"))
	await tocar(painel, "Concluir conversa")
	gs.save_game()
	conferir("retomada preserva leitura: " + loja, gs.load_game() and gs.vida_do_porto["cenas_lidas"].has(produto))
	await tocar(painel, conversar)
	conferir("reencontro continua após retomar: " + loja, rotulos(painel).contains(reencontro))
	await tocar(painel, retorno)
	await tocar(painel, "Ler a conversa")
	await ate_o_final(painel)
	await tocar(painel, "Concluir conversa")
	conferir("reler na loja não cobra nem duplica leitura: " + loja,
		botao(painel, conversar) != null and gs.cash == antes - preco
		and gs.vida_do_porto["cenas_lidas"].count(produto) == 1)
	await tocar(painel, "Voltar às lojas")
	await tocar(painel, "História do porto")
	await tocar(painel, "Reler: " + nome_cena)
	await tocar(painel, "Voltar às histórias")
	conferir("releitura volta ao arquivo sem cobrar: " + loja,
		botao(painel, "Reler: " + nome_cena) != null and gs.cash == antes - preco)
	# A outra loja não pode comentar uma refeição que este espaço não viveu.
	await tocar(painel, "Voltar às lojas")
	await tocar(painel, "Ver o delivery" if mercado else "Visitar o mercado")
	await tocar(painel, "Conversar com Mané" if mercado else "Conversar com Seu Biu")
	conferir("reencontro não vaza entre lojas: " + loja,
		rotulos(painel).contains("Entrega no cais?" if mercado else "Seu avô escolhia o café"))
	await fechar(main)
	_lojas_completas[loja] = true


func percurso_do_arquivo() -> void:
	var main := abrir()
	await assentar()
	var overlay: Node = main.get_node("Overlay")
	var painel: Node = overlay.get_child(overlay.get_child_count() - 1)
	await tocar(painel, "História do porto")
	await tocar(painel, "Nova: A caneca que ficou")
	await tocar(painel, "Voltar às histórias")
	conferir("interromper capítulo novo conserva pendência no arquivo",
		botao(painel, "Nova: A caneca que ficou") != null and not gs.vida_do_porto["cenas_lidas"].has("caneca"))
	await tocar(painel, "Nova: A caneca que ficou")
	await ate_o_final(painel)
	await tocar(painel, "Concluir conversa")
	conferir("concluir capítulo mostra reler no arquivo",
		botao(painel, "Reler: A caneca que ficou") != null and gs.vida_do_porto["cenas_lidas"].has("caneca"))
	await tocar(painel, "Voltar ao porto")
	conferir("saída explícita fecha o app", not is_instance_valid(painel))
	await fechar(main)
	_arquivo_completo = true


func percurso_do_boletim() -> void:
	var main := abrir()
	await assentar()
	var overlay: Node = main.get_node("Overlay")
	var painel: Node = overlay.get_child(overlay.get_child_count() - 1)
	await tocar(painel, "Voltar ao porto")
	main._on_semana_fechada(gs.resumo_da_semana(1))
	await assentar()
	var boletim: Node = overlay.get_child(overlay.get_child_count() - 1)
	await tocar(boletim, "Ler história: A caneca que ficou")
	painel = overlay.get_child(overlay.get_child_count() - 1)
	await tocar(painel, "Voltar ao boletim")
	conferir("interromper volta ao mesmo boletim sem consumir capítulo",
		not is_instance_valid(painel) and botao(boletim, "Fechar o boletim") != null
		and not gs.vida_do_porto["cenas_lidas"].has("caneca"))
	await tocar(boletim, "Ler história: A caneca que ficou")
	painel = overlay.get_child(overlay.get_child_count() - 1)
	await ate_o_final(painel)
	await tocar(painel, "Concluir conversa")
	conferir("concluir volta ao mesmo boletim e grava capítulo",
		not is_instance_valid(painel) and botao(boletim, "Fechar o boletim") != null
		and gs.vida_do_porto["cenas_lidas"].has("caneca"))
	await tocar(boletim, "Fechar o boletim")
	await fechar(main)
	_boletim_completo = true
