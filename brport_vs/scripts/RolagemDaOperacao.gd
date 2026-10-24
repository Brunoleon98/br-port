class_name RolagemDaOperacao
extends ScrollContainer

# O rolo recebe o gesto antes da GUI. Soltar depois de arrastar não chega
# aos cartões: ler a cobrança não pode atracar/liberar um barco por acidente.
const LIMIAR := 12.0
var _pressionado := false
var _arrastou := false
var _origem := Vector2.ZERO
var _inicio := 0


func _input(evento: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	# _input precede a GUI: o dim de um painel ainda não teve oportunidade
	# de bloquear o toque. Nunca roubar sua rolagem para o porto por baixo.
	var overlay := get_parent().get_node_or_null("Overlay")
	if overlay != null:
		for painel in overlay.get_children():
			if painel is Control and painel.is_visible_in_tree() and not painel.is_queued_for_deletion():
				_pressionado = false
				_arrastou = false
				return
	if evento is InputEventScreenTouch and evento.index == 0:
		if evento.pressed:
			_pressionado = get_global_rect().has_point(evento.position)
			_arrastou = false
			_origem = evento.position
			_inicio = scroll_vertical
		elif _arrastou:
			_pressionado = false
			get_viewport().set_input_as_handled()
	elif evento is InputEventScreenDrag and evento.index == 0 and _pressionado:
		_arrastar(evento.position)
	elif evento is InputEventMouseButton and evento.button_index == MOUSE_BUTTON_LEFT:
		if evento.pressed:
			_pressionado = get_global_rect().has_point(evento.position)
			_arrastou = false
			_origem = evento.position
			_inicio = scroll_vertical
		else:
			_pressionado = false
			if _arrastou:
				get_viewport().set_input_as_handled()
	elif evento is InputEventMouseMotion and _pressionado:
		_arrastar(evento.position)


func _arrastar(posicao: Vector2) -> void:
	if posicao.distance_to(_origem) > LIMIAR:
		_arrastou = true
	if _arrastou:
		scroll_vertical = _inicio - roundi(posicao.y - _origem.y)
		get_viewport().set_input_as_handled()


static func contem(no: Node) -> bool:
	var pai := no.get_parent()
	while pai != null:
		if pai is RolagemDaOperacao:
			return true
		pai = pai.get_parent()
	return false
