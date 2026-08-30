extends Control

# Menu de pausa — e o único lugar com controle de volume.
#
# Os dois sliders são separados de propósito. Quem baixa a trilha para ouvir
# outra coisa não quer perder o retorno sonoro dos botões; quem acha o efeito
# cansativo não quer perder a trilha. Um slider só obriga a escolher entre as
# duas, e é por isso que o `default_bus_layout.tres` tem dois buses.
#
# O valor vai direto ao bus e é gravado na hora (`user://audio.cfg`), sem botão
# de confirmar: mexer no volume e ouvir mudar É a confirmação.


func _ready() -> void:
	_build_ui()


func _build_ui() -> void:
	anchor_right = 1.0
	anchor_bottom = 1.0

	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.75)
	dim.anchor_right = 1.0
	dim.anchor_bottom = 1.0
	add_child(dim)

	var box := PanelContainer.new()
	box.anchor_left = 0.5
	box.anchor_top = 0.5
	box.anchor_right = 0.5
	box.anchor_bottom = 0.5
	box.offset_left = -140
	box.offset_top = -90
	box.offset_right = 140
	box.offset_bottom = 90
	add_child(box)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	box.add_child(vbox)

	vbox.add_child(Icones.rotulo(Icones.PAUSAR, "Pausado", Icones.TAM_TITULO, true))

	vbox.add_child(_slider_de_volume("Música", "Musica"))
	vbox.add_child(_slider_de_volume("Efeitos", "SFX"))

	var btn_resume := Button.new()
	btn_resume.text = "Continuar"
	btn_resume.pressed.connect(func(): queue_free())
	vbox.add_child(btn_resume)

	var btn_new := Button.new()
	btn_new.text = "Novo jogo (apaga progresso)"
	btn_new.pressed.connect(func():
		GameState.clear_save()
		GameState.new_game()
		queue_free()
		get_tree().reload_current_scene()
	)
	vbox.add_child(btn_new)


func _slider_de_volume(rotulo: String, bus: String) -> Control:
	var linha := HBoxContainer.new()
	linha.add_theme_constant_override("separation", 8)

	var nome := Label.new()
	nome.text = rotulo
	nome.custom_minimum_size = Vector2(64, 0)
	nome.add_theme_font_size_override("font_size", 13)
	linha.add_child(nome)

	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.05
	slider.value = Audio.volume(bus)
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.custom_minimum_size = Vector2(0, 28)
	linha.add_child(slider)

	var pct := Label.new()
	pct.custom_minimum_size = Vector2(40, 0)
	pct.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	pct.add_theme_font_size_override("font_size", 13)
	pct.text = "%d%%" % int(round(slider.value * 100.0))
	linha.add_child(pct)

	slider.value_changed.connect(func(v: float):
		Audio.definir_volume(bus, v)
		pct.text = "%d%%" % int(round(v * 100.0))
	)
	return linha
