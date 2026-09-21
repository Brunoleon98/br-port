extends SceneTree

# ============================================================
# BR Port VS — a tabela do contraste de toda a interface
# Ferramenta de apoio. NÃO faz parte do jogo.
#
# Ela IMPRIME o que o bloco D33 do `teste_design.gd` REPROVA, e as duas leem o
# mesmo motor — `scripts/validation/contraste_ui.gd` —, que é onde vivem o
# percurso, a conta e a calibração. Duas cópias divergiriam calado: a
# ferramenta diria verde de uma medição e o CI de outra.
#
# Ela existe porque as três guardas de contraste que havia perguntavam cada uma
# por UM sítio (D19 o painel Construir, D23 o menu-celular, D32 o contador da
# faixa), e o neutro do jogo mediu 2,93:1 sobre branco pela QUARTA vez em
# 17/09 — desta vez pelo TEMA, na variação `RotuloSecao`, que vive nos nove
# painéis onde nenhuma das três olha.
#
# Uso:
#   Godot --headless --path brport_vs \
#     --script res://tools/medir_contraste_ui.gd -- [--so-falhas]
#
# O marcador final é `CONTRASTE MEDIDO`, e ele diz que a ferramenta chegou ao
# fim — não que está tudo verde. Quem aprova é o D33.
# ============================================================

const TEMA := "res://ui/tema_brport.tres"

var _feito := false


func _process(_delta: float) -> bool:
	if _feito:
		return true
	_feito = true

	var so_falhas := OS.get_cmdline_user_args().has("--so-falhas")
	# ⚠️ `load()` E NÃO `preload()`. Um `preload` num `--script` compila o alvo
	# ANTES de os autoloads existirem, e o que sai é um GDScript VAZIO que só
	# se denuncia como "Nonexistent function" na hora de o usar.
	# ⚠️ E O TIPO ESCREVE-SE À MÃO no que sai dele. O motor é alcançado por
	# `load()`, logo o Godot não lhe sabe o tipo e recusa-se a inferir a partir
	# dele: "Cannot infer the type of X because the value doesn't have a set
	# type" — a mesma armadilha que o `GS` do `root.get_node()` já cobrou três
	# vezes num dia só, e que encerra com código ZERO.
	var motor: RefCounted = load("res://scripts/validation/contraste_ui.gd").new()

	print("── CALIBRAÇÃO DA RÉGUA ──")
	var ruim: PackedStringArray = motor.calibrar()
	if ruim.is_empty():
		print("  ok  os cinco controles batem — a régua sabe medir e sabe reprovar")
	else:
		for l in ruim:
			print("  ERRO %s" % l)
		push_error("a régua não está calibrada: a tabela abaixo não valeria nada")
		quit(1)
		return false

	var GS: Node = root.get_node("GameState")
	var tema: Theme = load(TEMA)
	var total := 0
	var contas := {"reprova": 0, "pendente": 0, "isento": 0, "passa": 0}

	for caso in motor.percurso():
		var no: Node = motor.montar_caso(root, GS, caso, tema)
		if no == null:
			continue
		var linhas: Array = motor.medir(no)
		# ⚠️ ZERO TEXTOS NÃO É "ESTE PAINEL PASSOU". Um `setup()` que rebentou
		# deixa a cena montada e vazia, e o Godot encerra com zero na mesma. É
		# a regra da amostra vazia, e mordeu aqui em dois casos de uma vez.
		if linhas.is_empty():
			motor.falhas.append("%s não produziu texto nenhum" % caso["nome"])
		total += linhas.size()
		var cabecalho := false
		for l in linhas:
			contas[l["estado"]] += 1
			if so_falhas and l["estado"] == "passa":
				continue
			if not cabecalho:
				print("── %s ──" % caso["nome"])
				cabecalho = true
			print("   %-8s %5.2f:1 (corte %.1f) %2dpx  %-14s  %s"
				% [String(l["estado"]).to_upper(), l["razao"], l["corte"],
					l["px"], l["fonte"], l["texto"]])
			if String(l["nota"]) != "":
				print("            ↳ %s" % l["nota"])
		root.remove_child(no)
		no.queue_free()

	print("\n── RESUMO ──")
	print("  %d texto(s) medidos em %d estado(s) de painel"
		% [total, motor.percurso().size()])
	print("  %d reprovam o AA, %d pendentes de composição, %d isentos, %d passam"
		% [contas["reprova"], contas["pendente"], contas["isento"],
			contas["passa"]])

	# ⚠️ UM `quit(1)` A MEIO NÃO PARA NADA, e o `quit(0)` do fim apaga-o. Medido
	# aqui: dois casos rebentaram, a tabela saiu curta e a ferramenta encerrou
	# com ZERO — quem olha o código de saída conclui que correu.
	if not motor.falhas.is_empty():
		for f in motor.falhas:
			push_error(f)
		quit(1)
		return false
	print("\nCONTRASTE MEDIDO")
	quit(0)
	return false
