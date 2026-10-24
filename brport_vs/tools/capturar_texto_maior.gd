extends "res://tools/capturar_tela.gd"

# Mesmos estados jogados e provas de captura, com a preferência em memória.
# Nunca escreve a apresentação do jogador nem troca as réguas padrão.
func _initialize() -> void:
	PreferenciasDeApresentacao.atual().tamanho_do_texto = PreferenciasDeApresentacao.MAIOR
	PreferenciasDeApresentacao.atual().reduzir_movimento = OS.get_environment("BRPORT_CAPTURA_REDUZIDO") == "1"
