extends "res://autoload/GameState.gd"

# Bancada da `110`, nunca instanciada pelo jogo. Não adiciona campos ao save
# nem muda sua versão: o histórico experimental vive só no JSON da medição.
var gravar_autosave := false
var multa_fracao := 0.10
var perda_reputacao := 5.0
var cancelamentos: Array = []


func save_game() -> void:
	if gravar_autosave:
		super.save_game()


func clear_save() -> void:
	if gravar_autosave:
		super.clear_save()


func new_game() -> void:
	cancelamentos.clear()
	super.new_game()


func multa_do_experimento(doca: int) -> int:
	return ceili(float(_valor_do_barco(doca)) * multa_fracao)


func cancelar_no_experimento(doca: int, uid: int) -> bool:
	if phase != ESTADO_JOGANDO or doca < 0 or doca >= docks.size():
		return false
	var barco = docks[doca]["boat"]
	if barco == null or int(barco["id"]) != uid:
		return false
	if int(barco["progress"]) <= 0 or int(barco["progress"]) >= int(barco["op_turns"]):
		return false
	if docks[doca]["worker_id"] == null:
		return false
	var trabalhador = _find_worker(docks[doca]["worker_id"])
	if trabalhador == null:
		return false
	var multa := multa_do_experimento(doca)
	var evento := {"dia": turn, "doca": doca, "uid": uid,
		"classe": barco["classe"], "motivo": barco["motivo"],
		"operados": int(barco["progress"]), "total": int(barco["op_turns"]),
		"valor_acordado": _valor_do_barco(doca), "receita_abandonada": receita_da_doca(doca),
		"multa": multa, "caixa_antes": cash, "rep_antes": reputation,
		"missao_antes": primeiro_cargueiro, "meta_antes": meta_concluida}
	cash -= multa
	_change_reputation(-perda_reputacao)
	metrics["boats_lost"] += 1
	dia_atual["perdidos"] += 1
	trabalhador["busy_turns"] = 0
	docks[doca]["boat"] = null
	docks[doca]["worker_id"] = null
	evento["caixa_depois"] = cash
	evento["rep_depois"] = reputation
	cancelamentos.append(evento)
	# A bancada desconta no caixa e na margem. Não implementa boletim, overlay,
	# registro ou migração: seriam produto fora da autorização de medir.
	save_game()
	return true
