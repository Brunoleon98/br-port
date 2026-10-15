extends SceneTree

var rodou := false


func _process(_delta: float) -> bool:
	if rodou:
		return false
	rodou = true
	testar()
	return false


func testar() -> void:
	var casos = load("res://tests/casos_cancelamento.gd").new()
	await casos.rodar(root.get_node("GameState"), self)
	if casos.completo and casos.falhas == 0:
		print("CANCELAMENTO INTEGRADO OK")
		quit(0)
	else:
		quit(1)
