extends SceneTree

# Processo separado para provar reinício, sem importar código de teste no
# jogo exportado. O caminho real vem de ArmazemLocal, inclusive nesta sonda.
func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() != 2 or args[0] not in ["ler", "escrever"] or args[1] not in ["true", "false"]:
		quit(1)
		return
	var pref := PreferenciasDeApresentacao.new()
	var esperado := args[1] == "true"
	var ok := true
	if args[0] == "escrever":
		ok = pref.definir_reduzir_movimento(esperado) == OK
	ok = ok and pref.reduzir_movimento == esperado
	if ok:
		print("PREFERENCIA CONFERIDA ", args[0], " ", args[1])
	quit(0 if ok else 1)
