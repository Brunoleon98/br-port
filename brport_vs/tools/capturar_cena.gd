extends SceneTree

# ============================================================
# BR Port VS — captura de UMA CENA QUALQUER
# Ferramenta de apoio. NÃO faz parte do jogo.
#
# `capturar_tela.gd` fotografa o jogo: monta o Main, joga turnos, resolve a
# oferta do rival. Isso é o que se quer para a tela do jogo e é exatamente o
# que atrapalha para fotografar uma bancada de teste, que não tem partida
# nenhuma. Daí esta segunda ferramenta, que só instancia uma cena e espera.
#
# Uso (Linux, sem monitor — precisa de xvfb):
#   xvfb-run -a Godot --path brport_vs --resolution 720x1280 \
#     --rendering-driver opengl3 --script res://tools/capturar_cena.gd -- \
#     res://scenes/tests/AssetPlacementTest.tscn foto.png
#
# Teste verde não prova que ficou bonito. É para isto que ela existe.
# ============================================================

const FRAMES_ATE_ASSENTAR := 12

# O ponto único de estilo do projeto. Ver ui/tema_brport.tres.
const TEMA := "res://ui/tema_brport.tres"

var _cena := "res://scenes/tests/AssetPlacementTest.tscn"
var _saida := "user://cena.png"
var _montado := false
var _frames := 0
# Argumentos extra, entregues a `setup()` da cena quando ela tiver um.
var _extra: Array = []
# Pares `campo=valor` a escrever no GameState antes de a cena nascer.
var _estado: Array = []


func _process(_delta: float) -> bool:
	if not _montado:
		_montado = true
		_ler_argumentos()
		if not ResourceLoader.exists(_cena):
			push_error("cena não encontrada: %s" % _cena)
			quit(1)
			return true
		var no: Node = load(_cena).instantiate()
		# O TEMA TEM DE SER APLICADO À MÃO AQUI. No jogo quem o põe é o
		# `_abrir_painel()` do Main; uma cena instanciada solta nasce sem tema
		# nenhum e o Godot desenha-a com o estilo padrão — cinzento sobre
		# cinzento. A fotografia sai "funcionando" e não se parece nada com o
		# que o jogador vê, que é a pior espécie de captura: a que dá confiança
		# sem dar informação. Medido ao fotografar o Diário do Porto.
		if no is Control:
			(no as Control).theme = load(TEMA)
		_estado_conhecido()
		_montar_estado()
		root.add_child(no)
		_chamar_setup(no)
		return false

	# Alguns frames antes de fotografar: um Sprite2D só tem textura resolvida
	# depois de o recurso terminar de carregar, e um Label só mede o texto
	# depois do primeiro layout.
	_frames += 1
	if _frames < FRAMES_ATE_ASSENTAR:
		return false

	var img := root.get_texture().get_image()
	var erro := img.save_png(_saida)
	if erro != OK:
		push_error("falhou ao gravar %s (erro %d)" % [_saida, erro])
		quit(1)
		return true
	# "Tela salva em" é CONTRATO com o `capturar_evidencia.sh`, que procura essa
	# linha em vez de olhar o código de saída — um erro de compilação do GDScript
	# sai com 0 sem a ferramenta ter feito nada. Antes daqui dizia "captura:", e
	# por isso esta ferramenta não podia entrar na bateria do CI.
	print("Tela salva em %s  (%dx%d)" % [_saida, img.get_width(), img.get_height()])
	quit(0)
	return true


# Vários painéis do jogo só existem depois de alguém lhes chamar `setup()` —
# a cena da parcela precisa do valor, a de fim de fase precisa de saber se se
# ganhou. Instanciadas sem isso ficam VAZIAS, e a captura sai um retângulo em
# branco que passa por "a cena abre" sem mostrar nada do que se queria ver.
#
# Os argumentos extra da linha de comando são passados a `setup()` em ordem.
# São convertidos por forma: "true"/"false" viram bool e o que for só dígitos
# vira int, porque `setup(won: bool, ...)` recusa a String "true".
# ⚠️ E CHAMA-SE MESMO SEM ARGUMENTOS NENHUNS. Até 12/09 a primeira condição
# aqui era `_extra.is_empty()`, e com ela um painel cujo `setup()` não EXIGE
# argumentos — `setup(_sem_argumentos: Variant = null)`, que são quatro deles:
# Calendário, Docas, Parcela e Reputação — nunca recebia a chamada. A captura
# saía com o escurecer e um cartão de altura zero, imprimia "Tela salva em" e
# passava por boa. É exatamente o buraco que o comentário acima descreve, com
# a guarda a cavá-lo. O Diário escapou por montar no `_ready()`, e foi por
# isso que isto viveu escondido.
func _chamar_setup(no: Node) -> void:
	if not no.has_method("setup"):
		return
	var convertidos := []
	for bruto in _extra:
		if bruto == "true" or bruto == "false":
			convertidos.append(bruto == "true")
		elif bruto.is_valid_int():
			convertidos.append(int(bruto))
		else:
			convertidos.append(bruto)
	no.callv("setup", convertidos)


func _ler_argumentos() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		_cena = args[0]
	if args.size() > 1:
		_saida = args[1]
	# Os extra dividem-se por FORMA: `chave=valor` monta o estado do jogo antes
	# de a cena nascer; o resto vai para o `setup()` em ordem.
	for bruto in args.slice(2):
		if bruto.contains("=") and not bruto.begins_with("res://"):
			_estado.append(bruto)
		else:
			_extra.append(bruto)


# ⚠️ E PARTE-SE SEMPRE DE UMA PARTIDA NOVA, porque o autoload NÃO nasce vazio.
# O `GameState._ready()` tenta `load_game()` antes de `new_game()`, então uma
# cena fotografada por esta ferramenta herdava o autosave que estivesse em
# `user://` — e a bateria tira as fotos de JOGO primeiro, que gravam. Medido em
# 12/09: o painel da parcela dizia "R$498.200 são MENOS DE UMA das estruturas
# que faltam" porque o save deixado pela foto anterior já tinha as SETE
# construídas; com partida nova a mesma quantia compra quatro. O Diário vinha
# pelo mesmo cano. Foto de comparação que depende do que está no disco não
# compara nada — é a regra "ferramenta que finge um estado tem de o DERIVAR
# dele", e o `capturar_tela.gd` já a cumpria ao lado.
func _estado_conhecido() -> void:
	var GS: Node = root.get_node("GameState")
	GS.clear_save()
	# A SEMENTE ANTES do `new_game()`, que já sorteia a mão inicial — a mesma
	# armadilha que o `capturar_tela.gd` e o simulador documentam.
	seed(20260825)
	GS.new_game()


# ⚠️ PAINEL QUE SÓ DIZ ALGO NUM ESTADO DO JOGO PRECISA DE MONTAR ESSE ESTADO.
# O desconto por antecipação (`docs/decisoes/019`) só aparece com a parcela por
# pagar e o vencimento ainda longe; um `GameState` recém-nascido está no fim do
# prazo, e a captura saía a mostrar o caso SEM desconto — bonita, verdadeira e
# sobre outra coisa. É a regra do `CLAUDE.md` sobre arte presa a uma condição
# do jogo, aplicada a um painel em vez de a um prop.
#
# Só campos que JÁ EXISTEM: um nome errado rebenta em vez de criar um campo
# novo em silêncio, que é a armadilha do `.get(chave, omissão)`.
func _montar_estado() -> void:
	if _estado.is_empty():
		return
	var GS: Node = root.get_node("GameState")
	for par in _estado:
		var corte: int = par.find("=")
		var chave: String = par.substr(0, corte)
		var valor: String = par.substr(corte + 1)
		if not chave in GS:
			push_error("GameState não tem o campo %s" % chave)
			quit(1)
			return
		GS.set(chave, int(valor) if valor.is_valid_int() else valor)
		print("  estado: %s = %s" % [chave, valor])
