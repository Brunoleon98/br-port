extends "res://tools/capturar_cena.gd"

# Os mesmos estados e botões da foto padrão, com a preferência só em memória.
func _initialize() -> void:
	PreferenciasDeApresentacao.atual().tamanho_do_texto = PreferenciasDeApresentacao.MAIOR
