extends PainelNarrativo

# ============================================================
# BR Port VS — o detalhe das docas, ao toque no chip do HUD
#
# O chip só soma "X/Y" — quantas docas o porto tem contra quantas o mapa
# comporta. O que falta nesse número é a pergunta que ele provoca: "e como é
# que eu chego na próxima?". Este painel responde com o que já existe —
# `impedimento_estrutura()` é o mesmo texto que o painel de construção usa —
# em vez de inventar uma segunda explicação que pudesse discordar dela.
#
# ⚠️ E DESDE 26/09 RESPONDE TAMBÉM «QUANTO VEM, E DE QUE TRABALHO» (`065`),
# pedido do Bruno no gate do A5: renda esperada e tipo de trabalho. O que cada
# doca vai pagar sai do `GameState.receita_da_doca()`, que passa pelo MESMO
# `_lancar_receita()` do `advance_turn()` — o bónus do armazém e do pátio
# incluído, que é o que o cartão da doca no rodapé NÃO mostra (ele mostra o
# valor do barco). Por isso a linha de apoio diz de onde sai a diferença. O
# F15 do `teste_fumaca` confere a promessa contra o que o jogo paga.
# ============================================================

const LARGURA := 440
const ALTURA := 0

# (id da estrutura que abre a doca seguinte, indexado por quantas docas já
# existem). Só há duas docas para desbloquear — a base já vem com uma.
const PROXIMA_DOCA := {1: "pier_2", 2: "pier_3"}

# De onde vem o bónus, na palavra das linhas do boletim. Acesso DIRETO: uma
# estrutura nova que pague bónus e não esteja aqui tem de rebentar, e não
# escrever uma linha sem nome (a regra do `.get(chave, omissão)`).
const ORIGEM_DO_BONUS := {"armazem": "do armazém", "patio": "do pátio"}


func setup(_sem_argumentos: Variant = null) -> void:
	montar(LARGURA, ALTURA, ESCURO_DECISAO)
	titulo_encorpado(Icones.BARCO, "Docas")

	var trabalhando := 0
	var sem_gente := 0
	var vazias := 0
	var a_receber := 0
	var em_risco := 0
	for i in range(GameState.docks.size()):
		var doca: Dictionary = GameState.docks[i]
		if doca["boat"] == null:
			vazias += 1
		elif doca["worker_id"] != null:
			trabalhando += 1
			a_receber += GameState.receita_da_doca(i)
		else:
			sem_gente += 1
			em_risco += GameState.receita_da_doca(i)
	_tarja(trabalhando, sem_gente, a_receber, em_risco)

	# Os três estados de uma doca, cada um no seu quadro. O rótulo é a
	# CATEGORIA e não concorda com o número (ver `quadro()`).
	var quadros := grade_de_quadros(3)
	quadro(quadros, "Trabalhando", str(trabalhando))
	quadro(quadros, "Sem trabalhador", str(sem_gente))
	quadro(quadros, "Vazias", str(vazias))

	secao("DOCA A DOCA · %d DE %d BERÇOS CONSTRUÍDOS"
		% [GameState.docks.size(), GameState.BERCOS_NO_MAPA])
	for i in range(GameState.docks.size()):
		_linha_da_doca(i)

	var total: int = GameState.docks.size()
	if PROXIMA_DOCA.has(total):
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


# A TARJA É O DINHEIRO QUE VEM, e só o de quem tem trabalhador: o barco sem
# ninguém sai no fim do dia (`advance_turn()`), e somá-lo prometeria dinheiro
# que o jogo não paga. Esse vai para a linha de apoio, dito como perda — que é
# o que o jogador pode ainda evitar.
#
# Tom neutro de propósito: «a receber» é uma previsão, não um resultado, e a
# `064` só pinta estados e resultados.
func _tarja(trabalhando: int, sem_gente: int, a_receber: int, em_risco: int) -> void:
	var apoio := ""
	if sem_gente > 0:
		# «sem trabalhador» fica FORA do `concordar()`: é invariável, e o F9
		# exige que toda palavra da forma plural esteja no plural.
		apoio = "Perde %s ao avançar o dia: %s sem trabalhador." % [
			GameState.moeda(em_risco), Narrativa.concordar(sem_gente, "doca", "docas")]
	if trabalhando > 0:
		tarja("A receber: %s" % GameState.moeda(a_receber), apoio)
	elif sem_gente > 0:
		tarja("Nenhuma doca trabalhando", apoio)
	else:
		tarja("Nenhum barco nas docas", "Os barcos chegam a cada dia que avança.")


# UMA DOCA POR QUADRO: nome e TIPO DE TRABALHO na linha de cima, com o que ela
# vai pagar à direita; a classe do navio, quando paga e quem trabalha nela, por
# baixo. O tipo é o `motivo` — Pescado, Armazenagem, Contêiner, Granel —, o
# mesmo nome que o cartão da doca e o boletim já usam.
func _linha_da_doca(i: int) -> void:
	var doca: Dictionary = GameState.docks[i]
	var barco = doca["boat"]
	var bloco := PanelContainer.new()
	bloco.name = "Doca%d" % (i + 1)
	bloco.theme_type_variation = "BlocoNumero"
	_vbox.add_child(bloco)
	var coluna := VBoxContainer.new()
	coluna.add_theme_constant_override("separation", 0)
	bloco.add_child(coluna)
	var topo := HBoxContainer.new()
	coluna.add_child(topo)
	var nome := Label.new()
	nome.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	topo.add_child(nome)
	var valor := Label.new()
	valor.name = "Valor"
	valor.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	topo.add_child(valor)

	if barco == null:
		nome.text = "Doca %d" % (i + 1)
		valor.text = "—"
		_apoio(coluna, "aguardando barco")
		return

	var motivo: String = String(barco["motivo"])
	nome.text = "Doca %d · %s" % [i + 1, String(GameState.MOTIVOS[motivo]["nome"])]
	var paga: int = GameState.receita_da_doca(i)
	valor.text = GameState.moeda(paga)

	var classe: String = String(GameState.CLASSES_DE_NAVIO[String(barco["classe"])]["nome"])
	if barco.get("rival", false) and not barco.get("matched", false):
		_apoio(coluna, "%s · oferta do rival em curso" % classe)
	elif doca["worker_id"] == null:
		_apoio(coluna, "%s · sem trabalhador — sai ao avançar o dia" % classe)
	else:
		var faltam: int = int(barco["op_turns"]) - int(barco["progress"])
		var quando := "paga ao avançar o dia" if faltam <= 1 \
			else "paga em %s" % Narrativa.concordar(faltam, "dia", "dias")
		# O TRABALHO À VISTA (segunda passagem): a barra do HUD com o que
		# estará feito AO FIM DE HOJE — o progresso mais o dia que o
		# trabalhador vai dar. Com o progresso de agora, o barco de um dia (o
		# pesqueiro, que é metade do porto pobre) teria a barra sempre vazia
		# até ao instante em que sai; assim, cheia quer dizer «paga ao avançar».
		var trabalho := barra_do_hud(int(barco["progress"]) + 1, int(barco["op_turns"]))
		trabalho.name = "Trabalho"
		coluna.add_child(trabalho)
		_apoio(coluna, "%s · %s · #%d" % [classe, quando, int(doca["worker_id"])])

	# O BÓNUS DITO, porque o cartão do rodapé mostra o valor do BARCO e este
	# quadro o que entra no dinheiro: sem esta linha os dois números
	# discordariam sem razão à vista.
	var barco_so: int = int(barco["matched_value"]) if barco.get("matched", false) \
		else int(barco["value"])
	if paga > barco_so:
		var estrutura: String = GameState.MOTIVOS[motivo]["estrutura"]
		_apoio(coluna, "%s do barco + %s %s" % [GameState.moeda(barco_so),
			GameState.moeda(paga - barco_so), ORIGEM_DO_BONUS[estrutura]])


func _apoio(coluna: VBoxContainer, texto: String) -> void:
	var rotulo := Label.new()
	rotulo.theme_type_variation = "RotuloApoio"
	rotulo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rotulo.text = texto
	coluna.add_child(rotulo)
