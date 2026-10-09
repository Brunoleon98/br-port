extends RefCounted

# Montagem de componente para as bancadas de arte e de efeitos econômicos.
# Não representa uma compra alcançável na Fase 1. Os bloqueios do jogador
# são exercitados pela porta real em T14; o porto completo continua a precisar
# de teste e fotografia mesmo enquanto só será liberado em fases futuras.
static func instalar(gs: Node, id: String) -> void:
	if gs.tem_estrutura(id):
		return
	gs.cash -= int(gs.ESTRUTURAS[id]["custo"])
	gs.estruturas.append(id)
	gs._reconciliar_roster()
	gs.cash_changed.emit(gs.cash)
	gs.roster_changed.emit()
	gs.estrutura_comprada.emit(id)
