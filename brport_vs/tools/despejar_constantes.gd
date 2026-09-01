extends SceneTree

# ============================================================
# BR Port VS — Despejo das constantes do GameState em JSON
# Ferramenta de apoio ao A2. NÃO faz parte do jogo.
#
# Existe para dar ao gerador da tabela (tools/gerar_tabela_numeros.py) algo
# CONTRA o que ser conferido. O gerador lê o texto do GameState.gd para
# recolher os comentários — que são metade do valor da tabela, porque dizem se
# o número veio do GDD ou é TUNING —, e ler texto é onde um gerador silencioso
# nasce: basta uma constante mudar de forma para ela sumir da tabela sem
# ninguém notar, e a partir daí a tabela envelhece parecendo em dia.
#
# Aqui o Godot avalia as constantes de verdade, inclusive as derivadas
# (TURNS_TOTAL = TURNS_PER_WEEK * WEEKS_TOTAL), e o gerador falha se o que ele
# leu do texto não bater com isto — nome a nome, valor a valor.
#
# Uso:
#   Godot --headless --path brport_vs \
#     --script res://tools/despejar_constantes.gd -- saida.json
#
# Sem argumento, imprime na saída padrão.
# ============================================================


func _init() -> void:
	var args := OS.get_cmdline_user_args()

	# Apaga o destino ANTES de tentar qualquer coisa. Sem isto, um despejo que
	# falha deixa no lugar o arquivo da corrida anterior, e o conferidor lá na
	# frente aprova em cima de números velhos achando que os leu agora. Foi
	# assim que um defeito injetado passou despercebido durante a construção
	# desta ferramenta.
	if not args.is_empty():
		DirAccess.remove_absolute(args[0])

	var script: Resource = load("res://autoload/GameState.gd")
	if script == null:
		# Um erro de compilação do GDScript sai com código 0 — é a mesma
		# armadilha que fez o CI deste projeto exigir a LINHA de sucesso em vez
		# do $?. Aqui saímos com != 0 de propósito.
		push_error("GameState.gd não compila — não há constantes para despejar.")
		quit(1)
		return

	var mapa: Dictionary = script.get_script_constant_map()
	if mapa.is_empty():
		push_error("GameState.gd não expôs constante nenhuma.")
		quit(1)
		return

	# Ordem estável: sem isto o JSON muda de ordem entre corridas e o passo de
	# CI que compara o arquivo gerado acusaria diferença sem ninguém ter mexido
	# em número nenhum.
	var nomes: Array = mapa.keys()
	nomes.sort()
	var ordenado := {}
	for n in nomes:
		ordenado[n] = mapa[n]

	var texto := JSON.stringify(ordenado, "  ", true)

	if args.is_empty():
		print(texto)
	else:
		var f := FileAccess.open(args[0], FileAccess.WRITE)
		if f == null:
			push_error("Não consegui escrever em %s" % args[0])
			quit(1)
			return
		f.store_string(texto + "\n")
		f.close()
		# A linha de sucesso é o que o CI confere. Ver o comentário acima sobre
		# o código de saída 0 de um script que nem chegou a rodar.
		print("CONSTANTES OK — %d despejadas em %s" % [ordenado.size(), args[0]])
	quit(0)
