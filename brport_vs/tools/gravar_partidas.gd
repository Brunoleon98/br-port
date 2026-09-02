extends SceneTree

# ============================================================
# BR Port VS — Gerador de registros de partida (apoio ao item B7)
#
# Joga N partidas headless com o `Registro` ARMADO e copia os `.jsonl` para uma
# pasta, para que `tools/ler_registros.py` tenha o que ler.
#
# ⚠️ POR QUE ISTO EXISTE, E É A RAZÃO INTEIRA: **o gravador e o leitor são dois
# arquivos em duas linguagens que têm de concordar sobre a forma de cada
# evento, e nada os obriga a isso.** Acrescentar um campo no `Registro.gd` não
# quebra o Python; mudar o nome de um evento também não. A divergência só
# aparece no dia em que alguém cola um registro de verdade — que é o dia em que
# o dado do playtest já foi produzido e não se repete. Este arquivo põe os dois
# a encontrar-se a cada corrida do CI.
#
# ⚠️ E OS NÚMEROS QUE ISTO PRODUZ NÃO SÃO PLAYTEST. São partidas de máquina:
# o tempo de deliberação sai perto de zero porque ninguém pensou entre um turno
# e o outro, e a taxa de esquecimento é o `--esquecer` que se lhe deu, não uma
# medida de gente. Serve para provar que o cano está aberto, e mais nada — a
# mesma distinção que separa as 30 partidas do CI das 600 que medem
# balanceamento.
#
# Uso:
#   Godot --headless --path brport_vs \
#     --script res://tools/gravar_partidas.gd -- [partidas] [pasta] [semente]
# ============================================================

const PARTIDAS_PADRAO := 5
const SEMENTE_PADRAO := 20260902


var _feito := false


# `_init()` corre ANTES de os autoloads entrarem na raiz — lá o
# `get_node("Registro")` devolve null. É a mesma razão por que o simulador de
# balanceamento e as quatro suítes arrancam todos daqui.
func _process(_delta: float) -> bool:
	if _feito:
		return true
	_feito = true
	_rodar()
	return true


func _rodar() -> void:
	var args := OS.get_cmdline_user_args()
	var quantas := int(args[0]) if args.size() > 0 else PARTIDAS_PADRAO
	var destino := String(args[1]) if args.size() > 1 else ""
	var semente := int(args[2]) if args.size() > 2 else SEMENTE_PADRAO

	var R := root.get_node_or_null("Registro")
	var GS := root.get_node_or_null("GameState")
	if R == null or GS == null:
		print("FALHA: Registro ou GameState não estão registrados.")
		quit(1)
		return

	# Limpa a pasta antes: um registro de uma corrida anterior misturado com
	# esta daria um relatório que não corresponde a nada que se tenha jogado.
	var d := DirAccess.open(R.PASTA)
	if d != null:
		for n in d.get_files():
			DirAccess.remove_absolute("%s/%s" % [R.PASTA, n])

	var rng := RandomNumberGenerator.new()
	rng.seed = semente
	GS._rng.seed = semente

	# Três jeitos de jogar, para o relatório ter o que separar. Não são os
	# perfis do simulador de balanceamento e não pretendem ser: são só variação
	# suficiente para exercitar cada seção do leitor.
	var jeitos := [
		{"esquecer": 0.0, "iguala": 0.0},
		{"esquecer": 0.12, "iguala": 0.65},
		{"esquecer": 0.30, "iguala": 0.10},
	]

	for p in range(quantas):
		var jeito: Dictionary = jeitos[p % jeitos.size()]
		# ARMA DEPOIS do `new_game()`, como o jogo faz: no jogo o
		# `GameState._ready()` já correu quando o `Main._ready()` arma. Armar
		# antes deixava o cabeçalho com o `turn` da partida ANTERIOR, e o
		# relatório marcava as cinco como "retomada no t33".
		GS.new_game()
		R._armado = false
		R.armar()
		GS.definir_nomes("Cais %d" % (p + 1), "" if p % 2 == 0 else "Testador")

		var voltas := 0
		while GS.phase != "game_over" and voltas < 400:
			voltas += 1
			if GS.phase == "rival_offer":
				if rng.randf() < float(jeito["iguala"]):
					GS.negotiate_rival("igualar")
				else:
					GS.negotiate_rival("metade" if rng.randf() < 0.5 else "manter")
				continue
			if GS.phase == "debt_payment":
				if GS.cash >= GS.PARCELA_AMOUNT:
					GS.pay_debt()
				else:
					GS.fail_debt()
				continue
			# Compra o que couber, para o relatório ter obras e turnos de obra.
			for id in GS.ESTRUTURAS.keys():
				if not GS.tem_estrutura(id) and GS.impedimento_estrutura(id) == "":
					var preco: int = int(GS.ESTRUTURAS[id]["custo"])
					if GS.cash > preco * 2:
						GS.comprar_estrutura(id)
			for i in range(GS.docks.size()):
				if GS.docks[i]["boat"] == null or GS.docks[i]["worker_id"] != null:
					continue
				if rng.randf() < float(jeito["esquecer"]):
					continue
				for w in GS.workers:
					if GS.worker_dock_index(int(w["id"])) < 0:
						GS.assign_worker(int(w["id"]), i, false)
						break
			GS.advance_turn()

	var nomes := _listar(R.PASTA)
	print("Gravadas %d partida(s) em %s" % [nomes.size(), ProjectSettings.globalize_path(R.PASTA)])

	if destino != "":
		DirAccess.make_dir_recursive_absolute(destino)
		for n in nomes:
			var texto := FileAccess.get_file_as_string("%s/%s" % [R.PASTA, n])
			var f := FileAccess.open("%s/%s" % [destino, n], FileAccess.WRITE)
			if f == null:
				print("FALHA: não consegui escrever em %s" % destino)
				quit(1)
				return
			f.store_string(texto)
			f.close()
		print("Copiadas para %s" % destino)

	if nomes.size() != quantas:
		print("FALHA: pedi %d partidas e ficaram %d arquivos." % [quantas, nomes.size()])
		quit(1)
		return

	print("GRAVACAO OK")
	quit(0)


func _listar(pasta: String) -> Array:
	var d := DirAccess.open(pasta)
	if d == null:
		return []
	var fora: Array = []
	for n in d.get_files():
		if n.ends_with(".jsonl"):
			fora.append(n)
	fora.sort()
	return fora
