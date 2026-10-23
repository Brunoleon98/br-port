class_name AcomodacaoDeLeitura
extends RefCounted

# O conteúdo conserva seus nós, sinais, campos e foco. Só ganha um rolo
# vertical; ao voltar ao Padrão o pai e os mínimos originais são restaurados.
var _rolos := {}
var _caixas := {}
var _separacoes := {}


func aplicar(raiz: Control, maior: bool) -> void:
	for conteudo in _rolos.keys():
		if not is_instance_valid(conteudo):
			_rolos.erase(conteudo)
	for cartao in _caixas.keys():
		if not is_instance_valid(cartao):
			_caixas.erase(cartao)
	for caixa in _separacoes.keys():
		if not is_instance_valid(caixa):
			_separacoes.erase(caixa)
	if not maior:
		_restaurar()
		_acomodar_aparelhos(raiz)
		return
	for no in TextoDaInterface.descendentes(raiz):
		if not no is Control:
			continue
		if no is GridContainer and no.has_meta(&"apps_rb5"):
			if not no.has_meta(&"colunas_base_rb5"):
				no.set_meta(&"colunas_base_rb5", no.columns)
			no.columns = 2
		if no is HBoxContainer and no.name == &"FitaDosDias":
			_compactar_fita(no)
		if no.has_meta(&"conteudo_rolavel_rb5"):
			_enrolar(no)
		if no.has_meta(&"cartao_rolavel_rb5"):
			_acomodar_cartao(no)
	_acomodar_aparelhos(raiz)


func _compactar_fita(fita: HBoxContainer) -> void:
	# Os 84 traços permanecem: são os espaços entre eles que cabem no visor.
	# A largura mínima da fita anterior já alargava o aparelho no Padrão.
	if not _separacoes.has(fita):
		_separacoes[fita] = fita.get_theme_constant("separation")
	fita.add_theme_constant_override("separation", 2)
	for semana in fita.get_children():
		if not _separacoes.has(semana):
			_separacoes[semana] = semana.get_theme_constant("separation")
		semana.add_theme_constant_override("separation", 1)


func _acomodar_aparelhos(raiz: Control) -> void:
	for no in TextoDaInterface.descendentes(raiz):
		if no is PanelContainer and no.has_meta(&"celular_tamanho_rb5"):
			# A grelha antiga pode ter alargado o Control antes de os filhos
			# assentarem. Diminuir o mínimo não devolve sozinho seus offsets.
			var tamanho: Vector2 = no.get_meta(&"celular_tamanho_rb5")
			no.offset_left = -tamanho.x / 2.0
			no.offset_right = tamanho.x / 2.0
			no.offset_top = -tamanho.y / 2.0
			no.offset_bottom = tamanho.y / 2.0


func _enrolar(conteudo: Control) -> void:
	if _rolos.has(conteudo):
		return
	var pai := conteudo.get_parent()
	var rolo := ScrollContainer.new()
	rolo.name = "LeituraAmpliada"
	rolo.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	rolo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rolo.size_flags_vertical = Control.SIZE_EXPAND_FILL
	rolo.follow_focus = true
	_rolos[conteudo] = {"rolo": rolo, "pai": pai, "indice": conteudo.get_index(),
		"horizontal": conteudo.size_flags_horizontal, "vertical": conteudo.size_flags_vertical,
		"minimo": conteudo.custom_minimum_size}
	pai.add_child(rolo)
	pai.move_child(rolo, conteudo.get_index())
	conteudo.reparent(rolo, false)
	conteudo.custom_minimum_size = Vector2.ZERO
	conteudo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	conteudo.size_flags_vertical = Control.SIZE_FILL


func _acomodar_cartao(cartao: PanelContainer) -> void:
	var conteudo: Control = cartao.get_meta(&"cartao_rolavel_rb5")
	if not is_instance_valid(conteudo):
		return
	if not _caixas.has(cartao):
		_caixas[cartao] = {"topo": cartao.offset_top, "pe": cartao.offset_bottom,
			"minimo": cartao.custom_minimum_size, "altura": cartao.size.y}
	var disponivel := cartao.get_viewport_rect().size.y - 200.0
	# A consulta já reserva a sobra para seu ScrollContainer expansível.
	# Envolver esse VBox num segundo rolo retira a altura da leitura na
	# abertura direta, quando as quebras ainda pedem larguras intermediárias.
	for filho in conteudo.get_children():
		if filho is ScrollContainer:
			return
	# Uma área de leitura existente já administra o próprio espaço. Não criar
	# dois rolos para uma ajuda que cabe inteira com o seu Voltar fora dela.
	if not _rolos.has(conteudo) and cartao.get_combined_minimum_size().y < disponivel:
		return
	_enrolar(conteudo)
	# Uma quebra ainda sem largura pode ter pedido o teto no primeiro frame.
	# Depois de assentar, o cartão volta ao conteúdo em vez de guardar uma
	# faixa branca abaixo dos botões. Altura declarada conserva ajuda/consulta.
	var altura_fixa := float(cartao.get_meta(&"cartao_altura_rb5", 0))
	var pedido := conteudo.get_combined_minimum_size().y \
		+ cartao.get_theme_stylebox("panel").get_minimum_size().y
	var altura := minf(disponivel, maxf(altura_fixa, pedido))
	if cartao.get_parent() is CenterContainer:
		cartao.custom_minimum_size.y = altura
		cartao.size.y = altura
	else:
		cartao.offset_top = -altura / 2.0
		cartao.offset_bottom = altura / 2.0
		cartao.size.y = altura


func _restaurar() -> void:
	for caixa in _separacoes:
		if is_instance_valid(caixa):
			caixa.add_theme_constant_override("separation", _separacoes[caixa])
	_separacoes.clear()
	for conteudo in _rolos:
		var base: Dictionary = _rolos[conteudo]
		if not is_instance_valid(conteudo) or not is_instance_valid(base.pai):
			continue
		conteudo.reparent(base.pai, false)
		base.pai.move_child(conteudo, base.indice)
		conteudo.size_flags_horizontal = base.horizontal
		conteudo.size_flags_vertical = base.vertical
		conteudo.custom_minimum_size = base.minimo
		base.rolo.queue_free()
	_rolos.clear()
	for cartao in _caixas:
		if not is_instance_valid(cartao):
			continue
		var base: Dictionary = _caixas[cartao]
		cartao.custom_minimum_size = base.minimo
		cartao.offset_top = base.topo
		cartao.offset_bottom = base.pe
		cartao.size.y = base.altura
	_caixas.clear()


func restaurar_grelhas(raiz: Control) -> void:
	for no in TextoDaInterface.descendentes(raiz):
		if no is GridContainer and no.has_meta(&"colunas_base_rb5"):
			no.columns = no.get_meta(&"colunas_base_rb5")
