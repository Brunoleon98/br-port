extends Control

# Vitória/derrota — texto simples. A cena narrativa de fim de
# Fase 1 (estática, com arte) entra no Bloco 4/5, não aqui.


func setup(won: bool, reason: String) -> void:
	_build_ui(won, reason)


func _build_ui(won: bool, reason: String) -> void:
	anchor_right = 1.0
	anchor_bottom = 1.0

	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.8)
	dim.anchor_right = 1.0
	dim.anchor_bottom = 1.0
	add_child(dim)

	var box := PanelContainer.new()
	box.anchor_left = 0.5
	box.anchor_top = 0.5
	box.anchor_right = 0.5
	box.anchor_bottom = 0.5
	box.offset_left = -210
	box.offset_top = -170
	box.offset_right = 210
	box.offset_bottom = 170
	add_child(box)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	box.add_child(vbox)

	var title := Label.new()
	title.text = "🏆 VITÓRIA!" if won else "💸 GAME OVER"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var m := GameState.metrics
	var body := Label.new()
	body.autowrap_mode = TextServer.AUTOWRAP_WORD
	body.text = "%s\n\nBarcos atendidos: %d\nBarcos perdidos: %d\nOfertas do rival igualadas: %d\nReceita total: R$%d\nReputação final: %d (%s)" % [
		reason,
		int(m["boats_served"]), int(m["boats_lost"]), int(m["rival_matched"]), int(m["revenue"]),
		int(GameState.reputation), GameState.reputation_label()
	]
	vbox.add_child(body)

	var btn_restart := Button.new()
	btn_restart.text = "🔄 Jogar de novo"
	btn_restart.pressed.connect(func():
		GameState.clear_save()
		GameState.new_game()
		queue_free()
		get_tree().reload_current_scene()
	)
	vbox.add_child(btn_restart)
