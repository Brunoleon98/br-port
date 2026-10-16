extends SceneTree
var feito := false
func _process(_delta: float) -> bool:
	if feito:
		return false
	feito = true
	rodar()
	return false

func rodar() -> void:
	var bloco = load("res://tests/casos_como_jogar.gd").new()
	await bloco.rodar(root.get_node("GameState"), self)
	if bloco.completo and bloco.falhas == 0:
		print("T25 OK")
		quit(0)
	else:
		quit(1)
