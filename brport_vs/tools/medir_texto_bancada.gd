extends RefCounted

# Só a bancada usa isto. O tamanho efetivo de cada nó inclui os overrides
# das cenas; mudar apenas o Theme deixaria justamente o HUD sem ampliação.
# A base fica no próprio nó para uma segunda aplicação nunca somar escala.
static func aplicar(raiz: Node, fator: float) -> Array:
	var fontes: Array = []
	for no in _textos(raiz):
		if not no.has_meta(&"bancada_texto_base"):
			no.set_meta(&"bancada_texto_base", no.get_theme_font_size("font_size"))
		var base: int = int(no.get_meta(&"bancada_texto_base"))
		var tamanho: int = maxi(1, roundi(base * fator))
		no.add_theme_font_size_override("font_size", tamanho)
		fontes.append({"no": str(raiz.get_path_to(no)), "base": base,
			"aplicado": tamanho})
	return fontes


static func medir(raiz: Control) -> Dictionary:
	var textos: Array = []
	var janela := Rect2(Vector2.ZERO, raiz.get_viewport_rect().size)
	for no in _textos(raiz):
		if not no.is_visible_in_tree() or String(no.text).is_empty():
			continue
		var tamanho: int = no.get_theme_font_size("font_size")
		var fonte: Font = no.get_theme_font("font")
		var desenho := Rect2()
		var tem_desenho := false
		if no is Label:
			# A caixa do Label não denuncia texto desenhado para fora dela.
			# É a mesma pergunta dos nomes longos: ler os caracteres desenhados.
			for i in String(no.text).length():
				var letra: Rect2 = no.get_character_bounds(i)
				if letra.size.x <= 0.0 or letra.size.y <= 0.0:
					continue
				desenho = desenho.merge(letra) if tem_desenho else letra
				tem_desenho = true
		else:
			var pedido: Vector2 = fonte.get_multiline_string_size(
				no.text, HORIZONTAL_ALIGNMENT_LEFT, -1, tamanho)
			desenho = Rect2(Vector2.ZERO, pedido)
			tem_desenho = true
		var local := Rect2(Vector2.ZERO, no.size)
		var global := Rect2(no.global_position + desenho.position, desenho.size)
		var rolo: ScrollContainer = _rolo(no)
		var fora_local := _excesso(desenho, local) if tem_desenho else 0.0
		var fora_janela := _excesso(global, janela) if tem_desenho else 0.0
		# Conteúdo que passa pela janela de um ScrollContainer é alcançável
		# pela rolagem, não um texto cortado. O relatório conserva os dois fatos.
		var minimo: Vector2 = no.get_combined_minimum_size()
		var linha := {"no": str(raiz.get_path_to(no)), "classe": no.get_class(),
			"texto": String(no.text), "fonte": tamanho,
			"tamanho": [no.size.x, no.size.y],
			"minimo": [minimo.x, minimo.y],
			"desenho": [desenho.position.x, desenho.position.y,
				desenho.size.x, desenho.size.y],
			"excesso_local": fora_local, "excesso_janela": fora_janela,
			"em_rolagem": rolo != null,
			"minimo_maior_que_area": maxf(0.0, minimo.x - no.size.x)}
		textos.append(linha)
	return {"textos": textos, "quantidade": textos.size()}


static func _textos(raiz: Node) -> Array:
	var saida: Array = []
	if raiz is Label or raiz is Button:
		saida.append(raiz)
	for filho in raiz.get_children():
		saida.append_array(_textos(filho))
	return saida


static func _rolo(no: Node) -> ScrollContainer:
	var pai := no.get_parent()
	while pai != null:
		if pai is ScrollContainer:
			return pai
		pai = pai.get_parent()
	return null


static func _excesso(desenho: Rect2, limite: Rect2) -> float:
	return maxf(0.0, maxf(limite.position.x - desenho.position.x,
		maxf(limite.position.y - desenho.position.y,
		maxf(desenho.end.x - limite.end.x, desenho.end.y - limite.end.y))))
