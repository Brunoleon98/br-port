extends Control


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
