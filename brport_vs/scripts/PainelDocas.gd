extends PainelNarrativo

# ============================================================
# BR Port VS — o detalhe das docas, ao toque no chip do HUD
#
# O chip só soma "X/Y" — quantas docas o porto tem contra quantas o mapa
# comporta. O que falta nesse número é a pergunta que ele provoca: "e como é
# que eu chego na próxima?". Este painel responde com o que já existe —
# `impedimento_estrutura()` é o mesmo texto que o painel de construção usa —
# em vez de inventar uma segunda explicação que pudesse discordar dela.
# ============================================================

const LARGURA := 400
const ALTURA := 0

# (id da estrutura que abre a doca seguinte, indexado por quantas docas já
# existem). Só há duas docas para desbloquear — a base já vem com uma.
const PROXIMA_DOCA := {1: "pier_2", 2: "pier_3"}


func setup(_sem_argumentos: Variant = null) -> void:
	montar(LARGURA, ALTURA, ESCURO_DECISAO)
	titulo(Icones.BARCO, "Docas")

	var total: int = GameState.docks.size()
	var alvo: int = GameState.BERCOS_NO_MAPA
	paragrafo("%d de %d berços construídos" % [total, alvo])

	var ocupadas := 0
	var esperando := 0
	var livres := 0
	for doca in GameState.docks:
		if doca["boat"] == null:
			livres += 1
		elif doca["worker_id"] != null:
			ocupadas += 1
		else:
			esperando += 1
	var partes := PackedStringArray()
	if ocupadas > 0:
		partes.append("%d ocupada%s" % [ocupadas, "" if ocupadas == 1 else "s"])
	if esperando > 0:
		partes.append("%d esperando trabalhador" % esperando)
	if livres > 0:
		partes.append("%d livre%s" % [livres, "" if livres == 1 else "s"])
	if not partes.is_empty():
		paragrafo(" · ".join(partes))

	if PROXIMA_DOCA.has(total):
		fio()
		secao("A PRÓXIMA DOCA")
		var id: String = PROXIMA_DOCA[total]
		var def: Dictionary = GameState.ESTRUTURAS[id]
		paragrafo("%s — %s" % [String(def["nome"]), GameState.moeda(int(def["custo"]))])
		var impedimento := GameState.impedimento_estrutura(id)
		if impedimento != "":
			paragrafo(impedimento)
		else:
			paragrafo("Já dá para construir.")
	else:
		fio()
		paragrafo("O porto tem todas as docas que o mapa comporta.")

	botao_fechar("Fechar")
