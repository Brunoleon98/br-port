extends "res://autoload/GameState.gd"

# O mesmo motor, sem autosave: medir não retoma partidas do disco. No Windows
# as gravações tornaram a rodada de 600 partidas uma espera de minutos.
# Só o simulador escolhe esta montagem por --sem-save; sem essa opção a
# persistência permanece, para comparar os JSONs. Nenhuma regra é substituída.
func save_game() -> void:
	pass


func clear_save() -> void:
	pass
