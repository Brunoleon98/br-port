extends "res://tools/medir_fase_2.gd"

# Controle exclusivamente da bancada: o fecho real precisa registrar a quebra.
func _construir_na_fase_2(perfil: Dictionary) -> int:
	if OS.get_cmdline_user_args().has("--apos-meta") and not GS.meta_concluida:
		return super._construir_na_fase_2(perfil)
	GS.cash = -1000000
	return 0
