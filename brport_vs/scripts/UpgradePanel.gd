extends Control

# Upgrade único do VS — ampliar o píer (+1 doca, +1 trabalhador).


func _ready() -> void:
	_build_ui()


func _build_ui() -> void:
	anchor_right = 1.0
	anchor_bottom = 1.0

	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.6)
	dim.anchor_right = 1.0
	dim.anchor_bottom = 1.0
	add_child(dim)

	var box := PanelContainer.new()
	box.anchor_left = 0.5
	box.anchor_top = 0.5
	box.anchor_right = 0.5
	box.anchor_bottom = 0.5
	box.offset_left = -160
	box.offset_top = -110
	box.offset_right = 160
	box.offset_bottom = 110
	add_child(box)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	box.add_child(vbox)

	vbox.add_child(Icones.rotulo(Icones.AMPLIAR_PIER, "Ampliar o píer"))

	var body := Label.new()
	body.autowrap_mode = TextServer.AUTOWRAP_WORD
	body.text = "Custo: R$%d\nEfeito: +1 doca e +1 trabalhador.\nCaixa atual: R$%d" % [GameState.UPGRADE_COST, int(GameState.cash)]
	vbox.add_child(body)

	var btn_row := HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 8)
	vbox.add_child(btn_row)

	var btn_buy := Button.new()
	btn_buy.text = "Comprar"
	btn_buy.disabled = GameState.cash < GameState.UPGRADE_COST
	btn_buy.pressed.connect(func():
		GameState.buy_upgrade()
		queue_free()
	)
	btn_row.add_child(btn_buy)

	var btn_cancel := Button.new()
	btn_cancel.text = "Cancelar"
	btn_cancel.pressed.connect(func(): queue_free())
	btn_row.add_child(btn_cancel)
