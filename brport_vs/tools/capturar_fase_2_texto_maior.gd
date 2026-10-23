extends "res://tools/capturar_fase_2.gd"

func _initialize() -> void:
	PreferenciasDeApresentacao.atual().tamanho_do_texto = PreferenciasDeApresentacao.MAIOR
	PreferenciasDeApresentacao.atual().reduzir_movimento = OS.get_environment("BRPORT_CAPTURA_REDUZIDO") == "1"
