extends SceneTree

# Este script fica fora do pacote e lê o recurso DENTRO dele, com --main-pack.
# O esperado vem do Git no job, não do mesmo arquivo que estamos conferindo.
func _process(_delta: float) -> bool:
	var args := OS.get_cmdline_user_args()
	var recurso: Resource = load("res://dados/identificacao_build.tres")
	if args.size() != 1 or recurso == null or recurso.get_meta("commit", "") != args[0] \
			or recurso.get_meta("modificado", true) != false or recurso.get_meta("formato", 0) != 1:
		push_error("a identificação no pacote não corresponde ao commit limpo do export")
		quit(1)
		return false
	print("BUILD EXPORTADO CONFERIDO — ", args[0])
	quit(0)
	return false
