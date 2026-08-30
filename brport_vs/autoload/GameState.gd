extends Node

# ============================================================
# BR Port VS — GameState (autoload singleton)
#
# Porta a lógica do protótipo HTML já validado (Playtest V3 ✅ GO)
# para o loop core do Vertical Slice, com os números do GDD 7
# (Sistemas > economia, específicos da Fase 1). Toda a UI escuta
# os signals abaixo em vez de ler o estado diretamente — mesmo
# espírito do `render()` do protótipo, mas idiomático a Godot.
#
# Constantes de balanceamento marcadas # TUNING: são estimativas
# ou escolhas de cadência não fechadas explicitamente no GDD para
# o VS — ajustar aqui não exige tocar em lógica.
# ============================================================

signal cash_changed(new_cash: int)
signal reputation_changed(new_reputation: float)
signal turn_advanced(new_turn: int, week: int)
signal boats_spawned()
# Docas/trabalhadores mudaram (alocação, liberação ou upgrade).
signal roster_changed()
# Toda troca de fase passa por _set_phase() e emite isto. A UI depende
# disso para reabilitar botões — sem esse sinal o jogo trava (era o bug
# de travamento depois de resolver a oferta do rival).
signal phase_changed(new_phase: String)
signal rival_offer_triggered(dock_index: int)
signal debt_due(amount: int)
signal game_over(won: bool, reason: String)
signal message(text: String, kind: String)
signal state_loaded()

# ── TUNING: economia (fonte: GDD 7 — Sistemas > economia, Fase 1) ──
# TUNING — medido, não estimado. 600 partidas por perfil em
# tools/simular_balanceamento.gd: ótimo 100% · mediano 47% · descuidado 0%.
# A mediana do jogador mediano fecha em R$7.945 contra uma parcela de R$8.000:
# é para ficar nessa margem. Mexer aqui SEM rodar o simulador quebra isso.
const START_CASH := 3250
const SALARY_PER_WORKER := 100          # GDD "Margem operacional base": 2 trab. x R$100 = R$200/sem
const MAINTENANCE_WEEKLY := 30          # GDD "Margem operacional base": manutenção R$30/sem
# O porto ABRE PARADO. Um píer de pé, o resto em ruína — é o que a herança do
# avô do GDD descreve, e é a diferença entre "administrar um porto" e "levantar
# um porto", que é a fantasia do jogo.
const DOCKS_BASE := 1
const WORKERS_BASE := 1
const UPGRADE_EXTRA_DOCKS := 1
const UPGRADE_EXTRA_WORKERS := 1

# Quantos berços o mapa desenha. Não é número de interface: é o TETO do porto,
# e por isso mora aqui e não no Main. Enquanto vivia só lá em cima, nada
# impedia o estado de passar do que a tela sabe mostrar — e passou: um save
# antigo, gravado quando o porto abria com 2 docas, somava os dois píeres
# comprados e chegava a 4 docas contra 3 vagas desenhadas. A quarta doca
# existia, recebia barco e nunca aparecia.
const BERCOS_NO_MAPA := 3

# ── ESTRUTURAS ──
# O que o jogador compra ou conserta. Cada uma tem um efeito ECONÔMICO real —
# nenhuma é só enfeite, senão comprar seria só gastar.
#
# PROPORÇÃO, não escala. O problema dos preços antigos não era o R$ ser baixo:
# era um píer custar R$400 enquanto um barco paga R$80–300, ou seja UM barco
# comprava um píer. Aqui a infraestrutura custa DEZENAS de barcos, que é o que
# faz decidir onde gastar valer alguma coisa.
#
# `ordem` é só a apresentação no painel. `custo` é TUNING — medido em
# tools/simular_balanceamento.gd, não estimado.
const ESTRUTURAS := {
	"pier_2": {
		"nome": "Reconstruir o Píer 2",
		"desc": "+1 doca e +1 trabalhador",
		"custo": 900, "ordem": 1, "requer": "",
	},
	"pier_3": {
		"nome": "Reconstruir o Píer 3",
		"desc": "+1 doca e +1 trabalhador",
		"custo": 1600, "ordem": 2, "requer": "pier_2",
	},
	"armazem": {
		"nome": "Consertar o armazém",
		"desc": "+20% no valor de cada barco atendido",
		"custo": 1100, "ordem": 3, "requer": "",
	},
	"patio": {
		"nome": "Pavimentar o pátio",
		"desc": "dobra a renda semanal do píer",
		"custo": 700, "ordem": 4, "requer": "",
	},
	"escritorio": {
		"nome": "Reformar o escritório",
		"desc": "-50% nos salários da semana",
		"custo": 500, "ordem": 5, "requer": "",
	},
}

const ARMAZEM_BONUS := 0.20             # TUNING
const PATIO_BONUS_PIER := 1.00          # TUNING
# O escritório mexia na manutenção (R$30/sem): pouparia R$18 por semana e
# nunca se pagaria. Agora corta SALÁRIO, que é o custo que cresce com o
# porto — é o que torna a compra uma decisão e não uma armadilha.
const ESCRITORIO_DESCONTO_SALARIO := 0.50   # TUNING

const PIER_SLOTS := 6                   # GDD "Margem operacional base": 6 vagas de píer
const PIER_RATE_PER_SLOT := 40          # GDD "Margem operacional base": R$40/vaga -> R$240/sem

# GDD "Valor de contratos": Fase 1 = R$80–300. O VS respeita essa faixa —
# o que faz a parcela caber não é inflar o barco, é a quantidade de turnos
# (ver TURNS_PER_WEEK abaixo).
const BOAT_VALUE_SMALL_MIN := 80
const BOAT_VALUE_SMALL_MAX := 200
const BOAT_VALUE_LARGE_MIN := 200
const BOAT_VALUE_LARGE_MAX := 300
const BOAT_LARGE_CHANCE := 0.4          # TUNING
const BOAT_ARRIVAL_CHANCE := 0.75       # TUNING: chance POR doca vazia de chegar barco no turno

# ── Contra-oferta do Arlindo (GDD: "Limiar de paciência do cliente") ──
# O GDD define 3 presets — "Igualar rival −15%" / "Cortar metade −7%" /
# "Manter preço" — e um limiar de 2 tentativas antes de o cliente ir embora.
# Igualar fecha na hora; os outros dois são apostas que gastam paciência.
# As probabilidades não estão no GDD: são TUNING, calibradas para que
# nenhuma das três opções domine as outras.
const RIVAL_TRIGGER_CHANCE := 0.30      # Protótipo validado (Arlindo — dumping)
const RIVAL_DISCOUNT := 0.15            # "Igualar rival −15%" (GDD)
const RIVAL_HALF_DISCOUNT := 0.07       # "Cortar metade −7%" (GDD)
const RIVAL_HALF_CHANCE := 0.70         # TUNING: chance de o cliente aceitar o meio-termo
const RIVAL_KEEP_CHANCE := 0.45         # TUNING: chance de o cliente aceitar pagar cheio
# Insistir e falhar deixa o cliente irritado: igualar depois disso custa mais.
# É o que impede "apostar uma vez e depois igualar" de ser sempre a jogada certa.
const RIVAL_DISCOUNT_AFTER_FAIL := 0.28 # TUNING
const RIVAL_PATIENCE := 2               # GDD: máx. 2 tentativas antes de o cliente encerrar

const REPUTATION_START := 65.0
const REPUTATION_GAIN_SERVED := 4.0
const REPUTATION_LOSS_LOST := 5.0
const REPUTATION_GAIN_RIVAL_MATCHED := 5.0
const REPUTATION_LOSS_RIVAL_REFUSED := 15.0

# TUNING — esta é a constante que faz a economia da Fase 1 fechar.
# Com 3 turnos/semana a parcela de R$8.000 só cabia inflando o barco para
# R$240–760, fora da faixa do GDD. Com 8 turnos/semana o barco volta para
# os R$80–300 do GDD e a parcela continua alcançável. As taxas medidas estão
# no bloco de economia lá em cima — uma tabela só, para não haver duas
# versões dos mesmos números envelhecendo em ritmos diferentes.
const TURNS_PER_WEEK := 8
const WEEKS_TOTAL := 4
const TURNS_TOTAL := TURNS_PER_WEEK * WEEKS_TOTAL

const PARCELA_AMOUNT := 8000            # GDD "Parcelas validadas" / Protótipo VS — parcela única
const PARCELA_DUE_TURN := TURNS_PER_WEEK * 4   # vence ao fim da semana 4

const SAVE_PATH := "user://savegame.json"

# VERSÃO DO SAVE — subir SEMPRE que a forma do estado mudar.
#
# O save não tinha versão nenhuma, e isso já custou um bug de verdade: quando
# o porto passou a abrir com 1 doca em vez de 2, um jogo salvo antes continuou
# a ser carregado como se nada tivesse mudado. O jogador ficava com duas docas
# de graça, o painel de construção continuava a oferecer os píeres 2 e 3 (que
# nunca constaram de `estruturas`), e comprá-los levava o porto a 4 docas num
# mapa de 3. Save de outra versão não é save: é ruído com a extensão certa.
const SAVE_VERSION := 2

# ── STATE ──
var turn: int = 1
var cash: int = START_CASH
var reputation: float = REPUTATION_START
var docks: Array = []       # [{boat: Dictionary|null, worker_id: int|null}]
var workers: Array = []     # [{id:int, busy_turns:int}]
var upgrade_purchased: bool = false
# Estruturas já compradas, por id. Guardado como Array para o save ser um JSON
# simples — Dictionary de bool viraria ruído no ficheiro.
var estruturas: Array = []
var parcela_paid: bool = false
var phase: String = "playing"   # playing | rival_offer | debt_payment | game_over
var pending_rival_dock: int = -1
# Paciência restante do cliente na negociação aberta. Vive aqui e não no
# painel para sobreviver ao autosave — recarregar no meio de uma negociação
# não pode devolver as tentativas já gastas.
var rival_attempts_left: int = RIVAL_PATIENCE
var end_reason: String = ""
var won: bool = false

var metrics := {
	"boats_served": 0,
	"boats_lost": 0,
	"rival_matched": 0,
	"rival_refused": 0,
	"revenue": 0,
	"pier_income": 0,
}

var _uid := 1
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()
	if not load_game():
		new_game()


func new_game() -> void:
	_uid = 1
	turn = 1
	cash = START_CASH
	reputation = REPUTATION_START
	upgrade_purchased = false
	estruturas = []
	parcela_paid = false
	_set_phase("playing")
	pending_rival_dock = -1
	rival_attempts_left = RIVAL_PATIENCE
	end_reason = ""
	won = false
	metrics = {"boats_served": 0, "boats_lost": 0, "rival_matched": 0, "rival_refused": 0, "revenue": 0, "pier_income": 0}

	docks.clear()
	for i in range(DOCKS_BASE):
		docks.append({"boat": null, "worker_id": null})

	workers.clear()
	for i in range(WORKERS_BASE):
		workers.append({"id": i + 1, "busy_turns": 0})

	_spawn_boats()
	save_game()


func _set_phase(new_phase: String) -> void:
	if phase == new_phase:
		return
	phase = new_phase
	phase_changed.emit(phase)


# R$8000 lido de relance vira "R$800" ou "R$80000". Com o separador de milhar
# o número tem forma, e forma é o que o olho compara sem contar dígito.
# Vive aqui porque quatro telas mostram dinheiro e não pode haver quatro
# versões da mesma regra.
func moeda(valor: int) -> String:
	var negativo := valor < 0
	var digitos := str(abs(valor))
	var saida := ""
	var contados := 0
	for i in range(digitos.length() - 1, -1, -1):
		saida = digitos[i] + saida
		contados += 1
		if contados % 3 == 0 and i > 0:
			saida = "." + saida
	return "%sR$%s" % ["-" if negativo else "", saida]


# Uma doca só aceita trabalhador se existe, tem barco esperando, ninguém está
# nela e a negociação do rival já foi resolvida. Três telas precisavam saber
# disso e cada uma tinha a sua cópia da regra.
func doca_aceita_trabalhador(dock_index: int) -> bool:
	if phase != "playing":
		return false
	if dock_index < 0 or dock_index >= docks.size():
		return false
	var doca: Dictionary = docks[dock_index]
	var barco = doca["boat"]
	if barco == null or doca["worker_id"] != null:
		return false
	return not (barco.get("rival", false) and not barco.get("matched", false))


func week_of(t: int) -> int:
	return int(ceil(float(t) / float(TURNS_PER_WEEK)))


func current_week() -> int:
	return week_of(turn)


# ── WORKER ASSIGNMENT ──
# `avisar` só existe para a alocação em lote: chamar isto N vezes emitiria N
# mensagens e só a última sobreviveria na barra. Quem aloca em lote silencia
# aqui e emite um resumo no fim.
func assign_worker(worker_id: int, dock_index: int, avisar: bool = true) -> bool:
	if phase != "playing":
		return false
	if dock_index < 0 or dock_index >= docks.size():
		return false
	var dock: Dictionary = docks[dock_index]
	if dock["boat"] == null:
		if avisar:
			message.emit("Doca vazia — não há barco aqui.", "warn")
		return false
	if dock["worker_id"] != null:
		if avisar:
			message.emit("Essa doca já tem trabalhador operando.", "warn")
		return false
	var boat: Dictionary = dock["boat"]
	if boat.get("rival", false) and not boat.get("matched", false):
		if avisar:
			message.emit("Resolva a oferta do rival antes de alocar.", "warn")
		return false
	var worker = _find_worker(worker_id)
	if worker == null or int(worker["busy_turns"]) > 0:
		return false
	# `busy_turns` só é preenchido no advance_turn, então dentro do mesmo
	# turno ele não impede nada — é preciso olhar as docas para saber se o
	# trabalhador já está alocado, senão dá para colocar o mesmo sujeito em
	# várias docas e faturar de graça.
	var already := worker_dock_index(worker_id)
	if already >= 0:
		if avisar:
			message.emit("Trabalhador #%d já está na Doca %d. Toque na doca para liberá-lo." % [worker_id, already + 1], "warn")
		return false
	dock["worker_id"] = worker_id
	if avisar:
		message.emit("Trabalhador alocado. Avance o dia para operar.", "good")
	roster_changed.emit()
	save_game()
	return true


# Põe todo trabalhador livre numa doca que esteja esperando, do barco mais
# valioso para o menos. Existe porque arrastar um por um, todo turno, é o que
# mais cansa em quem joga — e quando há trabalhador para todas as docas não
# havia decisão nenhuma sendo tomada no arrasto.
#
# A ordem por valor NÃO é enfeite: quando há menos trabalhador que barco,
# atender o mais caro primeiro é a jogada certa, então o botão faz o que um
# bom jogador faria. Quem quiser outra coisa toca na doca para liberar e
# realoca — a escolha continua existindo, deixou é de ser obrigatória.
func assign_all_free_workers() -> int:
	if phase != "playing":
		return 0

	var livres: Array[int] = []
	for w in workers:
		var wid := int(w["id"])
		if int(w["busy_turns"]) == 0 and worker_dock_index(wid) < 0:
			livres.append(wid)
	if livres.is_empty():
		return 0

	var esperando: Array[int] = []
	for i in range(docks.size()):
		if doca_aceita_trabalhador(i):
			esperando.append(i)
	if esperando.is_empty():
		return 0

	esperando.sort_custom(func(a, b): return _valor_do_barco(a) > _valor_do_barco(b))

	var postos := 0
	for i in esperando:
		if postos >= livres.size():
			break
		if assign_worker(livres[postos], i, false):
			postos += 1

	if postos > 0:
		var sobraram := esperando.size() - postos
		var texto := "%d trabalhador(es) alocado(s). Avance o dia para operar." % postos
		if sobraram > 0:
			texto += " Faltou gente para %d doca(s)." % sobraram
		message.emit(texto, "good")
	return postos


func _valor_do_barco(dock_index: int) -> int:
	var barco = docks[dock_index]["boat"]
	if barco == null:
		return 0
	return int(barco["matched_value"]) if barco.get("matched", false) else int(barco["value"])


# Há trabalhador livre E doca esperando? É o que decide se o botão de alocar
# em lote fica aceso.
func has_pending_assignment() -> bool:
	if phase != "playing":
		return false
	var tem_livre := false
	for w in workers:
		if int(w["busy_turns"]) == 0 and worker_dock_index(int(w["id"])) < 0:
			tem_livre = true
			break
	if not tem_livre:
		return false
	for i in range(docks.size()):
		if doca_aceita_trabalhador(i):
			return true
	return false


# Devolve o índice da doca onde o trabalhador está alocado, ou -1.
func worker_dock_index(worker_id: int) -> int:
	for i in range(docks.size()):
		var assigned = docks[i]["worker_id"]
		if assigned != null and int(assigned) == worker_id:
			return i
	return -1


# Tira o trabalhador da doca — só enquanto a operação não começou, para o
# jogador poder desfazer um arrasto errado sem perder o turno.
func release_worker(dock_index: int) -> bool:
	if phase != "playing":
		return false
	if dock_index < 0 or dock_index >= docks.size():
		return false
	var dock: Dictionary = docks[dock_index]
	if dock["worker_id"] == null:
		return false
	var boat = dock["boat"]
	if boat != null and int(boat["progress"]) > 0:
		message.emit("A operação já começou — não dá para tirar o trabalhador agora.", "warn")
		return false
	var worker_id := int(dock["worker_id"])
	dock["worker_id"] = null
	message.emit("Trabalhador #%d liberado." % worker_id, "")
	roster_changed.emit()
	save_game()
	return true


func _find_worker(worker_id: int) -> Variant:
	for w in workers:
		if int(w["id"]) == worker_id:
			return w
	return null


# ── RIVAL (Arlindo) ──
# Três presets do GDD. Devolve o que aconteceu, para o painel saber se
# fecha a tela ("fechado"/"perdido") ou só atualiza a mood face ("insistiu").
#   acao: "igualar" | "metade" | "manter"
func negotiate_rival(acao: String) -> String:
	if phase != "rival_offer" or pending_rival_dock < 0:
		return "invalido"
	var dock: Dictionary = docks[pending_rival_dock]
	var boat = dock["boat"]
	if boat == null:
		_close_rival_offer()
		return "invalido"

	if acao == "igualar":
		# Igualar sempre fecha. O preço é pior se o jogador já tentou empurrar.
		var ja_insistiu := rival_attempts_left < RIVAL_PATIENCE
		var desconto := RIVAL_DISCOUNT_AFTER_FAIL if ja_insistiu else RIVAL_DISCOUNT
		var aviso := "Preço igualado" if not ja_insistiu else "Fechado, mas o cliente cobrou caro pela insistência"
		_fechar_negocio(boat, desconto, aviso)
		return "fechado"

	# "metade" e "manter" são apostas: gastam uma tentativa de paciência.
	var chance := RIVAL_HALF_CHANCE if acao == "metade" else RIVAL_KEEP_CHANCE
	var desconto_aposta := RIVAL_HALF_DISCOUNT if acao == "metade" else 0.0
	rival_attempts_left -= 1

	if _rng.randf() < chance:
		var texto := "Cortou metade e o cliente topou" if acao == "metade" else "Segurou o preço e o cliente topou"
		_fechar_negocio(boat, desconto_aposta, texto)
		return "fechado"

	if rival_attempts_left <= 0:
		_perder_para_rival()
		return "perdido"

	message.emit("O cliente não gostou — última tentativa antes de ele ir embora.", "warn")
	save_game()
	return "insistiu"


# Compat com a versão binária (usada pela suíte de testes de regressão).
func resolve_rival_offer(accept_match: bool) -> void:
	if accept_match:
		negotiate_rival("igualar")
	elif phase == "rival_offer" and pending_rival_dock >= 0:
		_perder_para_rival()


# A fase volta ANTES de emitir qualquer coisa: os sinais abaixo fazem a UI se
# redesenhar, e se ela ler `phase` ainda em "rival_offer" o botão de avançar o
# dia fica desabilitado para sempre (era o bug de travamento).
func _close_rival_offer() -> void:
	pending_rival_dock = -1
	rival_attempts_left = RIVAL_PATIENCE
	_set_phase("playing")


func _fechar_negocio(boat: Dictionary, desconto: float, aviso: String) -> void:
	var valor := int(round(boat["value"] * (1.0 - desconto)))
	boat["matched"] = true
	boat["rival"] = false
	boat["matched_value"] = valor
	metrics["rival_matched"] += 1
	_close_rival_offer()
	_change_reputation(REPUTATION_GAIN_RIVAL_MATCHED)
	message.emit("%s — barco fechado por %s." % [aviso, moeda(valor)], "good")
	roster_changed.emit()
	save_game()


func _perder_para_rival() -> void:
	var dock: Dictionary = docks[pending_rival_dock]
	metrics["rival_refused"] += 1
	metrics["boats_lost"] += 1
	dock["boat"] = null
	dock["worker_id"] = null
	_close_rival_offer()
	_change_reputation(-REPUTATION_LOSS_RIVAL_REFUSED)
	message.emit("O cliente perdeu a paciência e foi para o Porto Farol.", "bad")
	roster_changed.emit()
	save_game()


# ── TURN ADVANCE ──
func advance_turn() -> void:
	if phase != "playing":
		return

	for i in range(docks.size()):
		var dock: Dictionary = docks[i]
		var boat = dock["boat"]
		if boat == null:
			continue
		if dock["worker_id"] != null:
			boat["progress"] = int(boat["progress"]) + 1
			if int(boat["progress"]) >= int(boat["op_turns"]):
				var bruto: int = int(boat["matched_value"]) if boat.get("matched", false) else int(boat["value"])
				var value := _valor_recebido(bruto)
				cash += value
				metrics["revenue"] += value
				metrics["boats_served"] += 1
				_change_reputation(REPUTATION_GAIN_SERVED)
				var w = _find_worker(dock["worker_id"])
				if w != null:
					w["busy_turns"] = 0
				dock["boat"] = null
				dock["worker_id"] = null
			else:
				var w2 = _find_worker(dock["worker_id"])
				if w2 != null:
					w2["busy_turns"] = int(boat["op_turns"]) - int(boat["progress"])
		else:
			# Barco sem trabalhador foi embora — perdido para o rival.
			metrics["boats_lost"] += 1
			_change_reputation(-REPUTATION_LOSS_LOST)
			dock["boat"] = null

	var prev_turn := turn
	turn += 1
	cash_changed.emit(cash)

	if prev_turn % TURNS_PER_WEEK == 0:
		_process_week_end(week_of(prev_turn))

	if prev_turn == PARCELA_DUE_TURN and not parcela_paid:
		_set_phase("debt_payment")
		debt_due.emit(PARCELA_AMOUNT)
		save_game()
		return

	turn_advanced.emit(turn, current_week())
	_check_end()
	save_game()


func _process_week_end(ended_week: int) -> void:
	# Pátio pavimentado: mais vagas de píer alugáveis. Escritório reformado:
	# menos manutenção porque a administração deixa de ser improvisada.
	var pier_income := PIER_SLOTS * PIER_RATE_PER_SLOT
	if tem_estrutura("patio"):
		pier_income = int(round(pier_income * (1.0 + PATIO_BONUS_PIER)))
	var salarios := SALARY_PER_WORKER * workers.size()
	if tem_estrutura("escritorio"):
		salarios = int(round(salarios * (1.0 - ESCRITORIO_DESCONTO_SALARIO)))
	var cost := salarios + MAINTENANCE_WEEKLY
	cash += pier_income
	cash -= cost
	metrics["pier_income"] = int(metrics.get("pier_income", 0)) + pier_income
	cash_changed.emit(cash)
	message.emit("Semana %d encerrada — +%s do aluguel do píer, -%s em custos (salários + manutenção)." % [ended_week, moeda(pier_income), moeda(cost)], "warn")


func _check_end() -> void:
	if cash < 0:
		_end_game(false, "Caixa negativo. Operação inviável.")
		return
	if turn > TURNS_TOTAL:
		_end_game(parcela_paid, "Você quitou a parcela e manteve o porto no azul!" if parcela_paid else "Prazo encerrado com a parcela em aberto.")
		return
	_spawn_boats()


func _end_game(did_win: bool, reason: String) -> void:
	won = did_win
	end_reason = reason
	_set_phase("game_over")
	game_over.emit(did_win, reason)
	save_game()


# ── DÍVIDA (Sr. Ribeiro) ──
func pay_debt() -> void:
	if phase != "debt_payment":
		return
	if cash < PARCELA_AMOUNT:
		message.emit("Caixa insuficiente para pagar a parcela.", "bad")
		return
	cash -= PARCELA_AMOUNT
	parcela_paid = true
	_set_phase("playing")
	cash_changed.emit(cash)
	message.emit("Parcela de %s paga ao Sr. Ribeiro." % moeda(PARCELA_AMOUNT), "good")
	turn_advanced.emit(turn, current_week())
	_check_end()
	save_game()


func fail_debt() -> void:
	_end_game(false, "Não foi possível pagar a parcela ao Sr. Ribeiro. Porto perdido.")


# ── UPGRADE (ampliar píer) ──
func tem_estrutura(id: String) -> bool:
	return estruturas.has(id)


# Por que não dá para comprar: "" quando dá. O painel mostra este texto, então
# o jogador nunca fica com um botão apagado sem explicação.
func impedimento_estrutura(id: String) -> String:
	if not ESTRUTURAS.has(id):
		return "Estrutura desconhecida."
	if tem_estrutura(id):
		return "Já construída."
	if phase != "playing":
		return "Resolva o que está na tela primeiro."
	var def: Dictionary = ESTRUTURAS[id]
	var requer := String(def["requer"])
	if requer != "" and not tem_estrutura(requer):
		return "Precisa antes de: %s." % ESTRUTURAS[requer]["nome"]
	if cash < int(def["custo"]):
		return "Faltam %s." % moeda(int(def["custo"]) - int(cash))
	return ""


func comprar_estrutura(id: String) -> bool:
	if impedimento_estrutura(id) != "":
		return false
	var def: Dictionary = ESTRUTURAS[id]
	cash -= int(def["custo"])
	estruturas.append(id)

	# Os píeres são os únicos que mexem no roster. O resto é econômico e age
	# nos lugares onde o dinheiro é contado (ver _valor_recebido e
	# _process_week_end).
	if id == "pier_2" or id == "pier_3":
		upgrade_purchased = true          # compat: a suíte antiga ainda olha isto
		# Doca que o mapa não desenha é doca invisível: recebe barco, o barco
		# vai embora sem trabalhador e o jogador nunca vê por quê. E o
		# trabalhador SÓ ENTRA COM A DOCA — quando o teto barrava a doca e o
		# trabalhador vinha assim mesmo, sobrava gente na fileira sem lugar
		# nenhum para trabalhar, que é como um "#4" fantasma nasceria de novo.
		var abertas := 0
		for i in range(UPGRADE_EXTRA_DOCKS):
			if docks.size() >= BERCOS_NO_MAPA:
				break
			docks.append({"boat": null, "worker_id": null})
			abertas += 1
		for i in range(abertas * UPGRADE_EXTRA_WORKERS):
			workers.append({"id": workers.size() + 1, "busy_turns": 0})

	cash_changed.emit(cash)
	roster_changed.emit()
	message.emit("%s — pronto. %s" % [def["nome"], def["desc"]], "good")
	save_game()
	return true


# Compat com a suíte de regressão e o simulador, que conheciam um upgrade só.
func buy_upgrade() -> bool:
	if not tem_estrutura("pier_2"):
		return comprar_estrutura("pier_2")
	return comprar_estrutura("pier_3")


# Quanto o porto realmente recebe por um barco. O armazém entra aqui porque é
# aqui que o dinheiro é contado — espalhar o bônus pelos sítios que somam caixa
# é como se esquece um deles.
func _valor_recebido(bruto: int) -> int:
	if tem_estrutura("armazem"):
		return int(round(bruto * (1.0 + ARMAZEM_BONUS)))
	return bruto


# ── GERAÇÃO DE BARCOS ──
func _make_boat() -> Dictionary:
	var large := _rng.randf() < BOAT_LARGE_CHANCE
	var value: int
	if large:
		value = _rng.randi_range(BOAT_VALUE_LARGE_MIN, BOAT_VALUE_LARGE_MAX)
	else:
		value = _rng.randi_range(BOAT_VALUE_SMALL_MIN, BOAT_VALUE_SMALL_MAX)
	_uid += 1
	return {
		"id": _uid,
		"value": value,
		"op_turns": 2 if large else 1,
		"large": large,
		"progress": 0,
		"rival": false,
		"matched": false,
		"matched_value": 0,
	}


func _spawn_boats() -> void:
	# Cada doca vazia tem sua própria chance de receber barco (em vez de
	# no máximo 1 barco por turno) — aumenta a frequência de chegada e
	# mantém as docas ocupadas com mais consistência.
	var newly_spawned: Array = []
	for i in range(docks.size()):
		if docks[i]["boat"] != null:
			continue
		if _rng.randf() > BOAT_ARRIVAL_CHANCE:
			continue
		docks[i]["boat"] = _make_boat()
		newly_spawned.append(i)
	if newly_spawned.is_empty():
		return
	boats_spawned.emit()

	# No máximo 1 oferta do rival (Arlindo) por turno, sobre um dos barcos novos.
	if _rng.randf() < RIVAL_TRIGGER_CHANCE:
		var idx: int = newly_spawned[_rng.randi_range(0, newly_spawned.size() - 1)]
		docks[idx]["boat"]["rival"] = true
		pending_rival_dock = idx
		rival_attempts_left = RIVAL_PATIENCE
		_set_phase("rival_offer")
		rival_offer_triggered.emit(idx)


func _change_reputation(delta: float) -> void:
	reputation = clamp(reputation + delta, 0.0, 100.0)
	reputation_changed.emit(reputation)


func reputation_label() -> String:
	if reputation >= 81.0:
		return "Referência"
	elif reputation >= 61.0:
		return "Respeitado"
	elif reputation >= 41.0:
		return "Confiável"
	elif reputation >= 21.0:
		return "Questionável"
	else:
		return "Desconhecido"


# ── AUTOSAVE LOCAL ──
func save_game() -> void:
	var data := {
		"versao": SAVE_VERSION,
		"turn": turn,
		"cash": cash,
		"reputation": reputation,
		"docks": docks,
		"workers": workers,
		"upgrade_purchased": upgrade_purchased,
		"estruturas": estruturas,
		"parcela_paid": parcela_paid,
		"phase": phase,
		"pending_rival_dock": pending_rival_dock,
		"rival_attempts_left": rival_attempts_left,
		"end_reason": end_reason,
		"won": won,
		"metrics": metrics,
		"uid": _uid,
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()


func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return false
	var text := file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return false

	# Save de outra versão do jogo é descartado, não adaptado. Migrar exigiria
	# adivinhar o que o jogador tinha comprado a partir de números que já não
	# querem dizer a mesma coisa — foi assim que apareceu o porto de 4 docas
	# num mapa de 3. Recomeçar é honesto; carregar um estado impossível não é.
	if int(parsed.get("versao", 1)) != SAVE_VERSION:
		clear_save()
		return false

	turn = int(parsed.get("turn", 1))
	cash = int(parsed.get("cash", START_CASH))
	reputation = float(parsed.get("reputation", REPUTATION_START))
	docks = parsed.get("docks", [])
	workers = parsed.get("workers", [])
	upgrade_purchased = bool(parsed.get("upgrade_purchased", false))
	estruturas = parsed.get("estruturas", [])
	parcela_paid = bool(parsed.get("parcela_paid", false))
	phase = String(parsed.get("phase", "playing"))
	pending_rival_dock = int(parsed.get("pending_rival_dock", -1))
	rival_attempts_left = int(parsed.get("rival_attempts_left", RIVAL_PATIENCE))
	end_reason = String(parsed.get("end_reason", ""))
	won = bool(parsed.get("won", false))
	metrics = parsed.get("metrics", metrics)
	_uid = int(parsed.get("uid", 1))

	if docks.is_empty() or workers.is_empty():
		return false
	_reconciliar_roster()
	state_loaded.emit()
	return true


# Quantas docas e quantos trabalhadores o porto DEVE ter, dado o que está
# construído. É a única fonte da verdade: docas não são um contador que anda
# sozinho, são consequência dos píeres.
func docas_esperadas() -> int:
	var n := DOCKS_BASE
	for id in ["pier_2", "pier_3"]:
		if tem_estrutura(id):
			n += UPGRADE_EXTRA_DOCKS
	return mini(n, BERCOS_NO_MAPA)


func trabalhadores_esperados() -> int:
	var n := WORKERS_BASE
	for id in ["pier_2", "pier_3"]:
		if tem_estrutura(id):
			n += UPGRADE_EXTRA_WORKERS
	return n


# Rede de segurança do carregamento. A versão do save já barra o caso
# conhecido; isto barra o próximo, seja ele um arquivo editado à mão ou um
# bug futuro que some uma doca a mais. Sobra doca -> corta as do fim (as
# últimas são as que o mapa não desenha); falta -> completa vazia.
func _reconciliar_roster() -> void:
	var alvo_docas := docas_esperadas()
	while docks.size() > alvo_docas:
		var perdida: Dictionary = docks.pop_back()
		var trabalhador = perdida.get("worker_id")
		if trabalhador != null:
			var w = _find_worker(int(trabalhador))
			if w != null:
				w["busy_turns"] = 0
	while docks.size() < alvo_docas:
		docks.append({"boat": null, "worker_id": null})

	var alvo_trab := trabalhadores_esperados()
	while workers.size() > alvo_trab:
		workers.pop_back()
	while workers.size() < alvo_trab:
		workers.append({"id": workers.size() + 1, "busy_turns": 0})

	# Trabalhador cortado não pode continuar alocado numa doca que ficou: seria
	# um "#4" na tela sem cartão correspondente na fileira.
	for doca in docks:
		var alocado = doca["worker_id"]
		if alocado != null and _find_worker(int(alocado)) == null:
			doca["worker_id"] = null


func clear_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
