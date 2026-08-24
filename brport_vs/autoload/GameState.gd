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
signal worker_assigned()
signal rival_offer_triggered(dock_index: int)
signal debt_due(amount: int)
signal game_over(won: bool, reason: String)
signal message(text: String, kind: String)
signal state_loaded()

# ── TUNING: economia (fonte: GDD 7 — Sistemas > economia, Fase 1) ──
const START_CASH := 600                 # GDD "Abertura de caixa": R$600 herdado
const SALARY_PER_WORKER := 100          # GDD "Margem operacional base": 2 trab. x R$100 = R$200/sem
const MAINTENANCE_WEEKLY := 30          # GDD "Margem operacional base": manutenção R$30/sem
const DOCKS_BASE := 2                   # GDD "VS — Sistemas IN": 2 slots simultâneos
const WORKERS_BASE := 2
const UPGRADE_COST := 400               # TUNING: GDD não define custo do upgrade de VS; estimado
const UPGRADE_EXTRA_DOCKS := 1
const UPGRADE_EXTRA_WORKERS := 1

const BOAT_VALUE_SMALL_MIN := 80        # GDD "Valor de contratos" Fase 1: R$80–300
const BOAT_VALUE_SMALL_MAX := 150
const BOAT_VALUE_LARGE_MIN := 150
const BOAT_VALUE_LARGE_MAX := 300
const BOAT_LARGE_CHANCE := 0.4          # TUNING
const BOAT_ARRIVAL_CHANCE := 0.75       # TUNING: chance de 1 barco novo por turno

const RIVAL_TRIGGER_CHANCE := 0.30      # Protótipo validado (Arlindo — dumping)
const RIVAL_DISCOUNT := 0.15            # Protótipo validado — 15% de desconto

const REPUTATION_START := 65.0
const REPUTATION_GAIN_SERVED := 4.0
const REPUTATION_LOSS_LOST := 5.0
const REPUTATION_GAIN_RIVAL_MATCHED := 5.0
const REPUTATION_LOSS_RIVAL_REFUSED := 15.0

const TURNS_PER_WEEK := 3               # TUNING: cadência do protótipo pequeno já validado
const WEEKS_TOTAL := 4
const TURNS_TOTAL := TURNS_PER_WEEK * WEEKS_TOTAL

const PARCELA_AMOUNT := 8000            # GDD "Parcelas validadas" / Protótipo VS — parcela única
const PARCELA_DUE_TURN := TURNS_PER_WEEK * 4   # vence ao fim da semana 4

const SAVE_PATH := "user://savegame.json"

# ── STATE ──
var turn: int = 1
var cash: int = START_CASH
var reputation: float = REPUTATION_START
var docks: Array = []       # [{boat: Dictionary|null, worker_id: int|null}]
var workers: Array = []     # [{id:int, busy_turns:int}]
var upgrade_purchased: bool = false
var parcela_paid: bool = false
var phase: String = "playing"   # playing | rival_offer | debt_payment | game_over
var pending_rival_dock: int = -1
var end_reason: String = ""
var won: bool = false

var metrics := {
	"boats_served": 0,
	"boats_lost": 0,
	"rival_matched": 0,
	"rival_refused": 0,
	"revenue": 0,
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
	parcela_paid = false
	phase = "playing"
	pending_rival_dock = -1
	end_reason = ""
	won = false
	metrics = {"boats_served": 0, "boats_lost": 0, "rival_matched": 0, "rival_refused": 0, "revenue": 0}

	docks.clear()
	for i in range(DOCKS_BASE):
		docks.append({"boat": null, "worker_id": null})

	workers.clear()
	for i in range(WORKERS_BASE):
		workers.append({"id": i + 1, "busy_turns": 0})

	_spawn_boats()
	save_game()


func week_of(t: int) -> int:
	return int(ceil(float(t) / float(TURNS_PER_WEEK)))


func current_week() -> int:
	return week_of(turn)


# ── WORKER ASSIGNMENT ──
func assign_worker(worker_id: int, dock_index: int) -> bool:
	if phase != "playing":
		return false
	if dock_index < 0 or dock_index >= docks.size():
		return false
	var dock: Dictionary = docks[dock_index]
	if dock["boat"] == null:
		message.emit("Doca vazia — não há barco aqui.", "warn")
		return false
	if dock["worker_id"] != null:
		message.emit("Essa doca já tem trabalhador operando.", "warn")
		return false
	var boat: Dictionary = dock["boat"]
	if boat.get("rival", false) and not boat.get("matched", false):
		message.emit("Resolva a oferta do rival antes de alocar.", "warn")
		return false
	var worker = _find_worker(worker_id)
	if worker == null or int(worker["busy_turns"]) > 0:
		return false
	dock["worker_id"] = worker_id
	message.emit("✅ Trabalhador alocado. Avance o dia para operar.", "good")
	worker_assigned.emit()
	save_game()
	return true


func _find_worker(worker_id: int) -> Variant:
	for w in workers:
		if int(w["id"]) == worker_id:
			return w
	return null


# ── RIVAL (Arlindo) ──
func resolve_rival_offer(accept_match: bool) -> void:
	if phase != "rival_offer" or pending_rival_dock < 0:
		return
	var dock: Dictionary = docks[pending_rival_dock]
	var boat = dock["boat"]
	if boat == null:
		phase = "playing"
		return
	if accept_match:
		var discounted := int(round(boat["value"] * (1.0 - RIVAL_DISCOUNT)))
		boat["matched"] = true
		boat["rival"] = false
		boat["matched_value"] = discounted
		metrics["rival_matched"] += 1
		_change_reputation(REPUTATION_GAIN_RIVAL_MATCHED)
		message.emit("🤝 Preço igualado. Barco aceito por R$%d." % discounted, "")
	else:
		metrics["rival_refused"] += 1
		metrics["boats_lost"] += 1
		docks[pending_rival_dock]["boat"] = null
		docks[pending_rival_dock]["worker_id"] = null
		_change_reputation(-REPUTATION_LOSS_RIVAL_REFUSED)
		message.emit("❌ Barco foi para o rival (Arlindo). Reputação caiu.", "bad")
	pending_rival_dock = -1
	phase = "playing"
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
				var value: int = int(boat["matched_value"]) if boat.get("matched", false) else int(boat["value"])
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
		phase = "debt_payment"
		debt_due.emit(PARCELA_AMOUNT)
		save_game()
		return

	turn_advanced.emit(turn, current_week())
	_check_end()
	save_game()


func _process_week_end(ended_week: int) -> void:
	var cost := (SALARY_PER_WORKER * workers.size()) + MAINTENANCE_WEEKLY
	cash -= cost
	cash_changed.emit(cash)
	message.emit("⚓ Semana %d encerrada — -R$%d em custos (salários + manutenção)." % [ended_week, cost], "warn")


func _check_end() -> void:
	if cash < 0:
		_end_game(false, "Caixa negativo. Operação inviável.")
		return
	if turn > TURNS_TOTAL:
		_end_game(parcela_paid, "Você quitou a parcela e manteve o porto no azul!" if parcela_paid else "Prazo encerrado com a parcela em aberto.")
		return
	_spawn_boats()


func _end_game(did_win: bool, reason: String) -> void:
	phase = "game_over"
	won = did_win
	end_reason = reason
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
	phase = "playing"
	cash_changed.emit(cash)
	message.emit("✅ Parcela de R$%d paga ao Sr. Ribeiro." % PARCELA_AMOUNT, "good")
	turn_advanced.emit(turn, current_week())
	_check_end()
	save_game()


func fail_debt() -> void:
	_end_game(false, "Não foi possível pagar a parcela ao Sr. Ribeiro. Porto perdido.")


# ── UPGRADE (ampliar píer) ──
func buy_upgrade() -> bool:
	if phase != "playing" or upgrade_purchased:
		return false
	if cash < UPGRADE_COST:
		message.emit("Caixa insuficiente para o upgrade. Precisa de R$%d." % UPGRADE_COST, "warn")
		return false
	cash -= UPGRADE_COST
	upgrade_purchased = true
	for i in range(UPGRADE_EXTRA_DOCKS):
		docks.append({"boat": null, "worker_id": null})
	for i in range(UPGRADE_EXTRA_WORKERS):
		workers.append({"id": workers.size() + 1, "busy_turns": 0})
	cash_changed.emit(cash)
	message.emit("🏗️ Píer ampliado! +1 doca e +1 trabalhador.", "good")
	save_game()
	return true


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
	if _rng.randf() > BOAT_ARRIVAL_CHANCE:
		return
	var empty_indices: Array = []
	for i in range(docks.size()):
		if docks[i]["boat"] == null:
			empty_indices.append(i)
	if empty_indices.is_empty():
		return
	var idx: int = empty_indices[_rng.randi_range(0, empty_indices.size() - 1)]
	docks[idx]["boat"] = _make_boat()
	boats_spawned.emit()

	# Chance de oferta do rival (Arlindo) sobre o barco recém-chegado.
	if _rng.randf() < RIVAL_TRIGGER_CHANCE:
		docks[idx]["boat"]["rival"] = true
		pending_rival_dock = idx
		phase = "rival_offer"
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
		"turn": turn,
		"cash": cash,
		"reputation": reputation,
		"docks": docks,
		"workers": workers,
		"upgrade_purchased": upgrade_purchased,
		"parcela_paid": parcela_paid,
		"phase": phase,
		"pending_rival_dock": pending_rival_dock,
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

	turn = int(parsed.get("turn", 1))
	cash = int(parsed.get("cash", START_CASH))
	reputation = float(parsed.get("reputation", REPUTATION_START))
	docks = parsed.get("docks", [])
	workers = parsed.get("workers", [])
	upgrade_purchased = bool(parsed.get("upgrade_purchased", false))
	parcela_paid = bool(parsed.get("parcela_paid", false))
	phase = String(parsed.get("phase", "playing"))
	pending_rival_dock = int(parsed.get("pending_rival_dock", -1))
	end_reason = String(parsed.get("end_reason", ""))
	won = bool(parsed.get("won", false))
	metrics = parsed.get("metrics", metrics)
	_uid = int(parsed.get("uid", 1))

	if docks.is_empty() or workers.is_empty():
		return false
	state_loaded.emit()
	return true


func clear_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
