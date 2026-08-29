extends Control

# Cena da parcela — texto placeholder do Sr. Ribeiro (sprite e
# diálogo completo entram no Bloco 4, com arte final).

var amount: int = 0


func setup(due_amount: int) -> void:
	amount = due_amount
	_build_ui()


func _build_ui() -> void:
	anchor_right = 1.0
	anchor_bottom = 1.0

	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.7)
	dim.anchor_right = 1.0
	dim.anchor_bottom = 1.0
	add_child(dim)

	var box := PanelContainer.new()
	box.anchor_left = 0.5
	box.anchor_top = 0.5
	box.anchor_right = 0.5
	box.anchor_bottom = 0.5
	box.offset_left = -190
	box.offset_top = -130
	box.offset_right = 190
	box.offset_bottom = 130
	add_child(box)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	box.add_child(vbox)

	vbox.add_child(Icones.rotulo(Icones.PARCELA, "Sr. Ribeiro — Banco de Porto Mirim"))

	var can_pay: bool = GameState.cash >= amount
	var body := Label.new()
	body.autowrap_mode = TextServer.AUTOWRAP_WORD
	body.text = "\"A Parcela vence hoje: R$%d. Fui amigo do seu avô — vim pessoalmente porque o porto merece esse respeito.\"\n\nCaixa atual: R$%d" % [amount, int(GameState.cash)]
	vbox.add_child(body)

	var btn_pay := Button.new()
	btn_pay.text = "Pagar R$%d" % amount
	btn_pay.disabled = not can_pay
	btn_pay.pressed.connect(_on_pay)
	vbox.add_child(btn_pay)

	if not can_pay:
		var btn_fail := Button.new()
		btn_fail.text = "Não consigo pagar"
		btn_fail.pressed.connect(_on_fail)
		vbox.add_child(btn_fail)


func _on_pay() -> void:
	GameState.pay_debt()
	queue_free()


func _on_fail() -> void:
	GameState.fail_debt()
	queue_free()
