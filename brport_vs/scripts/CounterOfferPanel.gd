extends Control

# Contra-oferta do Arlindo — GDD, "Limiar de paciência do cliente":
# 3 presets em botões ("Igualar rival −15%" / "Cortar metade −7%" /
# "Manter preço") + mood face do cliente em 3 estados.
#
# O painel é só a tela: quem sorteia e decide é o GameState. A paciência
# restante também mora lá, para o autosave não devolver tentativas gastas.

var dock_index: int = -1

var _mood_label: Label
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

	var title := Label.new()
	title.text = "⚔️ Arlindo (Porto Farol) fez uma oferta"
	title.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(title)

	var info_label := Label.new()
	info_label.text = "Cliente considerando ir para o Porto Farol.\nValor original: R$%d" % _valor_barco()
	info_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(info_label)

	_mood_label = Label.new()
	_mood_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(_mood_label)

	var btn_row := VBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 6)
	vbox.add_child(btn_row)

	_btn_igualar = Button.new()
	_btn_igualar.pressed.connect(func(): _negociar("igualar"))
	btn_row.add_child(_btn_igualar)

	_btn_metade = Button.new()
	_btn_metade.pressed.connect(func(): _negociar("metade"))
	btn_row.add_child(_btn_metade)

	_btn_manter = Button.new()
	_btn_manter.pressed.connect(func(): _negociar("manter"))
	btn_row.add_child(_btn_manter)


func _valor_barco() -> int:
	if dock_index < 0 or dock_index >= GameState.docks.size():
		return 0
	var boat = GameState.docks[dock_index]["boat"]
	return int(boat["value"]) if boat != null else 0


func _negociar(acao: String) -> void:
	var resultado := GameState.negotiate_rival(acao)
	if resultado == "insistiu":
		# Cliente ainda na mesa, mas mais impaciente — e igualar ficou mais caro.
		_refresh()
		return
	queue_free()


func _refresh() -> void:
	var valor := _valor_barco()
	var restantes := GameState.rival_attempts_left
	var ja_insistiu := restantes < GameState.RIVAL_PATIENCE

	var desconto_igualar: float = GameState.RIVAL_DISCOUNT_AFTER_FAIL if ja_insistiu else GameState.RIVAL_DISCOUNT
	_btn_igualar.text = "🤝 Igualar (−%d%%) → R$%d  ·  fecha na hora" % [
		int(round(desconto_igualar * 100.0)),
		int(round(valor * (1.0 - desconto_igualar)))]

	_btn_metade.text = "✂️ Cortar metade (−%d%%) → R$%d  ·  %d%% de chance" % [
		int(round(GameState.RIVAL_HALF_DISCOUNT * 100.0)),
		int(round(valor * (1.0 - GameState.RIVAL_HALF_DISCOUNT))),
		int(round(GameState.RIVAL_HALF_CHANCE * 100.0))]

	_btn_manter.text = "💪 Manter preço → R$%d  ·  %d%% de chance" % [
		valor,
		int(round(GameState.RIVAL_KEEP_CHANCE * 100.0))]

	var face := "🙂"
	var desc := "Cliente ouvindo a proposta."
	if restantes <= 1:
		face = "😟"
		desc = "Cliente impaciente — se esta não colar, ele vai embora."
	_mood_label.text = "%s %s (%d tentativa(s))" % [face, desc, restantes]
