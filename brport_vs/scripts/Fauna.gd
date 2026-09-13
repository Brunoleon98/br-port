extends Node2D

# Um comportamento pequeno por habitat. A arte continua no estúdio Blender;
# aqui só vivem movimento, toque e o pedido de som.
@export_enum("gaivota", "maria_farinha", "tartaruga_verde") var especie := "gaivota"

@onready var _sprite: Sprite2D = $Sprite
@onready var _toque: Area2D = $Toque

var _origem := Vector2.ZERO
var _tempo := 0.0
var _reagindo := false


func _ready() -> void:
	_origem = position
	_toque.input_event.connect(_ao_input)


func _process(delta: float) -> void:
	if _reagindo:
		return
	_tempo += delta
	match especie:
		"gaivota":
			position = _origem + Vector2(sin(_tempo * 0.55) * 22.0,
					cos(_tempo * 0.31) * 5.0)
			rotation = sin(_tempo * 0.42) * 0.045
			# A silhueta é uma pose só; comprimir e abrir no eixo das asas dá
			# leitura de batida sem inventar uma spritesheet que o estúdio não fez.
			_sprite.scale.y = 0.90 + sin(_tempo * 4.2) * 0.10
		"maria_farinha":
			position = _origem + Vector2(sin(_tempo * 0.90) * 10.0, 0.0)
			rotation = sin(_tempo * 1.80) * 0.035
		"tartaruga_verde":
			position = _origem + Vector2(sin(_tempo * 0.38) * 5.0,
					cos(_tempo * 0.72) * 3.0)
			rotation = sin(_tempo * 0.50) * 0.055


func _ao_input(_viewport: Node, evento: InputEvent, _forma: int) -> void:
	var tocou := evento is InputEventScreenTouch and (evento as InputEventScreenTouch).pressed
	if evento is InputEventMouseButton:
		var mouse := evento as InputEventMouseButton
		tocou = mouse.pressed and mouse.button_index == MOUSE_BUTTON_LEFT
	if not tocou:
		return
	get_viewport().set_input_as_handled()
	reagir()


func reagir() -> void:
	if _reagindo:
		return
	_reagindo = true
	match especie:
		"gaivota":
			Audio.tocar("gaivota")
			_reacao_gaivota()
		"maria_farinha":
			Audio.tocar("areia")
			_reacao_maria_farinha()
		"tartaruga_verde":
			Audio.tocar("mergulho")
			_reacao_tartaruga()


func _reacao_gaivota() -> void:
	var t := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.tween_property(self, "position", position + Vector2(-30.0, -22.0), 0.18)
	t.parallel().tween_property(self, "scale", Vector2(1.16, 0.62), 0.18)
	t.tween_property(self, "position", _origem, 0.42).set_ease(Tween.EASE_IN_OUT)
	t.parallel().tween_property(self, "scale", Vector2.ONE, 0.42)
	t.finished.connect(_fim_da_reacao)


func _reacao_maria_farinha() -> void:
	var t := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	t.tween_property(self, "position", position + Vector2(34.0, 1.0), 0.18)
	t.parallel().tween_property(self, "scale", Vector2(0.24, 0.24), 0.18)
	t.parallel().tween_property(self, "modulate", Color(1, 1, 1, 0.18), 0.18)
	t.tween_interval(0.20)
	t.tween_property(self, "position", _origem, 0.24).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(self, "scale", Vector2.ONE, 0.24)
	t.parallel().tween_property(self, "modulate", Color.WHITE, 0.24)
	t.finished.connect(_fim_da_reacao)


func _reacao_tartaruga() -> void:
	var t := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(self, "position", position + Vector2(2.0, 14.0), 0.28)
	t.parallel().tween_property(self, "scale", Vector2(0.74, 0.74), 0.28)
	t.parallel().tween_property(self, "modulate", Color(0.72, 0.92, 1.0, 0.42), 0.28)
	t.tween_interval(0.18)
	t.tween_property(self, "position", _origem, 0.38)
	t.parallel().tween_property(self, "scale", Vector2.ONE, 0.38)
	t.parallel().tween_property(self, "modulate", Color.WHITE, 0.38)
	t.finished.connect(_fim_da_reacao)


func _fim_da_reacao() -> void:
	position = _origem
	rotation = 0.0
	scale = Vector2.ONE
	modulate = Color.WHITE
	_reagindo = false
