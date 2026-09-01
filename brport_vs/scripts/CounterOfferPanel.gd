extends Control

# Contra-oferta do Arlindo — GDD, "Limiar de paciência do cliente":
# 3 presets em botões ("Igualar rival −15%" / "Cortar metade −7%" /
# "Manter preço") + mood face do cliente em 3 estados.
#
# O painel é só a tela: quem sorteia e decide é o GameState. A paciência
# restante também mora lá, para o autosave não devolver tentativas gastas.

var dock_index: int = -1

var _mood_label: Label
# A fala do Arlindo troca a cada rodada da negociação: abertura, reação ao que
# o jogador ofereceu, e a linha da última tentativa. É guardada porque o painel
# não se reconstrói entre rodadas — só se refresca.
var _fala_arlindo: Label
var _mood_icone: TextureRect
var _btn_igualar: Button
var _btn_metade: Button
var _btn_manter: Button


func setup(index: int) -> void:
	dock_index = index
	_build_ui()
	_refresh()


func _build_ui() -> void:
	anchor_right = 1.0
	anchor_bottom = 1.0

	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.6)
	dim.anchor_right = 1.0
	dim.anchor_bottom = 1.0
	add_child(dim)

	# Centralizado e do tamanho do conteúdo — com offsets fixos sobrava um
	# tampão vazio embaixo dos botões.
	var centro := CenterContainer.new()
	centro.anchor_right = 1.0
	centro.anchor_bottom = 1.0
	add_child(centro)

	var box := PanelContainer.new()
	box.custom_minimum_size = Vector2(400, 0)
	centro.add_child(box)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	box.add_child(vbox)

	vbox.add_child(Icones.rotulo(Icones.RIVAL, "Arlindo (Porto Farol) fez uma oferta"))

	# O ARLINDO FALA COM O CLIENTE, NÃO COM O JOGADOR — é isso que faz a tela
	# ser uma negociação assistida em vez de uma discussão, e o arquivo de
	# escrita é explícito nisso. Daí as aspas: o jogador está a ouvir.
	_fala_arlindo = Label.new()
	_fala_arlindo.autowrap_mode = TextServer.AUTOWRAP_WORD
	_fala_arlindo.text = "\"%s\"" % GameState.texto(Narrativa.ARLINDO_ABERTURA)
	vbox.add_child(_fala_arlindo)

	var info_label := Label.new()
	info_label.text = "Valor original: %s" % GameState.moeda(_valor_barco())
	info_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(info_label)

	# A cara do cliente é um ícone que troca no meio da negociação, então a
	# linha é guardada em pedaços: o texto e o ícone mudam juntos em _refresh().
	var mood_linha := Icones.rotulo(Icones.CLIENTE_CALMO, "", Icones.TAM_TEXTO)
	_mood_icone = mood_linha.get_node("Icone")
	_mood_label = mood_linha.get_node("Texto")
	vbox.add_child(mood_linha)

	var btn_row := VBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 6)
	vbox.add_child(btn_row)

	_btn_igualar = Button.new()
	Icones.no_botao(_btn_igualar, Icones.ACORDO)
	_btn_igualar.pressed.connect(func(): _negociar("igualar"))
	btn_row.add_child(_btn_igualar)

	_btn_metade = Button.new()
	Icones.no_botao(_btn_metade, Icones.CORTAR)
	_btn_metade.pressed.connect(func(): _negociar("metade"))
	btn_row.add_child(_btn_metade)

	_btn_manter = Button.new()
	Icones.no_botao(_btn_manter, Icones.FIRMEZA)
	_btn_manter.pressed.connect(func(): _negociar("manter"))
	btn_row.add_child(_btn_manter)


func _valor_barco() -> int:
	if dock_index < 0 or dock_index >= GameState.docks.size():
		return 0
	var boat = GameState.docks[dock_index]["boat"]
	return int(boat["value"]) if boat != null else 0


func _negociar(acao: String) -> void:
	# A reação sai do que o jogador ESCOLHEU, e por isso é lida antes de o
	# GameState resolver: depois de resolver, a ação já não está em lado nenhum.
	var reacao: String = String(Narrativa.ARLINDO_REACOES.get(acao, ""))
	var resultado := GameState.negotiate_rival(acao)
	if resultado == "insistiu":
		# Cliente ainda na mesa, mas mais impaciente — e igualar ficou mais caro.
		_refresh(reacao)
		return
	queue_free()


func _refresh(reacao: String = "") -> void:
	var valor := _valor_barco()
	var restantes := GameState.rival_attempts_left
	var ja_insistiu := restantes < GameState.RIVAL_PATIENCE

	var desconto_igualar: float = GameState.RIVAL_DISCOUNT_AFTER_FAIL if ja_insistiu else GameState.RIVAL_DISCOUNT
	_btn_igualar.text = "Igualar (−%d%%) → %s  ·  fecha na hora" % [
		int(round(desconto_igualar * 100.0)),
		GameState.moeda(int(round(valor * (1.0 - desconto_igualar))))]

	_btn_metade.text = "Cortar metade (−%d%%) → %s  ·  %d%% de chance" % [
		int(round(GameState.RIVAL_HALF_DISCOUNT * 100.0)),
		GameState.moeda(int(round(valor * (1.0 - GameState.RIVAL_HALF_DISCOUNT)))),
		int(round(GameState.RIVAL_HALF_CHANCE * 100.0))]

	_btn_manter.text = "Manter preço → %s  ·  %d%% de chance" % [
		GameState.moeda(valor),
		int(round(GameState.RIVAL_KEEP_CHANCE * 100.0))]

	var desc := "Cliente ouvindo a proposta."
	_mood_icone.texture = Icones.CLIENTE_CALMO
	if restantes <= 1:
		_mood_icone.texture = Icones.CLIENTE_IMPACIENTE
		desc = "Cliente impaciente — se esta não colar, ele vai embora."
	_mood_label.text = "%s (%d tentativa(s))" % [desc, restantes]

	# Duas falas dele numa rodada só: o que achou da oferta, e a pressão da
	# última tentativa. Juntas porque são o mesmo momento — separá-las em dois
	# balões daria dois cliques a uma coisa que se lê de uma vez.
	if reacao != "":
		var falas := "\"%s\"" % GameState.texto(reacao)
		if restantes <= 1:
			falas += "\n\n\"%s\"" % GameState.texto(Narrativa.ARLINDO_ULTIMA_TENTATIVA)
		_fala_arlindo.text = falas
