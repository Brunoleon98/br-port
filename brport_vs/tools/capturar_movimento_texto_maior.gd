extends "res://tools/capturar_movimento.gd"

# O mesmo percurso da bateria, com o texto maior apenas na memória.
func _initialize() -> void:
	PreferenciasDeApresentacao.atual().tamanho_do_texto = PreferenciasDeApresentacao.MAIOR
