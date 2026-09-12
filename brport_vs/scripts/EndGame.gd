extends PainelNarrativo

# ============================================================
# BR Port VS — o fim da Fase 1
#
# Era uma tela de números: "VITÓRIA!" e uma lista de métricas. Item A4 do
# plano — a sexta das telas narrativas é a cena de fim de fase, e o arquivo de
# escrita pede tom CONTEMPLATIVO, sem exagero dramático.
#
# DOIS TEMPOS, E A ORDEM IMPORTA. Quem sobreviveu lê primeiro a narração e só
# depois os números, com um clique pelo meio. Trocar a ordem é o que faz a
# diferença entre "o porto respira" e "você fez 47 pontos": a mesma informação
# a dizer coisas opostas sobre o que o jogo é.
#
# QUEM PERDE NÃO LEVA A NARRAÇÃO. Ela fala de um cais que continua de pé —
# lê-la por cima de uma derrota seria escárnio. A derrota vai direta aos
# números, que é o que quem perdeu quer saber: onde é que isto se torceu.
# ============================================================

const LARGURA := 440
const ALTURA := 600
const ALTURA_TEXTO := 430

# O TETO da narração, e só o teto: a altura de verdade sai do TEXTO
# (`altura_do_texto`). 900 é o que sobra dos 1280 da tela depois do título, do
# botão e das margens do cartão, com folga para o cartão não encostar na borda.
# Enquanto a peça couber aqui, o jogador lê-a inteira sem rolar — que é a
# diferença entre ver o remate e sair no botão antes dele.
const ALTURA_NARRACAO_MAX := 900
# O que o tema gasta de margem lateral dentro do cartão, medido no render.
const MARGEM_CARTAO := 36

var _venceu := false
var _motivo := ""


func setup(won: bool, reason: String) -> void:
	_venceu = won
	_motivo = reason
	# A NARRAÇÃO AJUSTA-SE AO TEXTO e o balanço mantém a altura fixa: são duas
	# telas de tamanhos muito diferentes a partilhar um painel, e uma altura só
	# servia mal as duas. Com o rolo à medida do texto já não há rolo nenhum,
	# e é por isso que aqui se pode pedir o cartão ajustado ao conteúdo.
	if _venceu:
		montar(LARGURA, 0)
		_mostrar_narracao()
	else:
		montar(LARGURA, ALTURA)
		_mostrar_balanco()


func _mostrar_narracao() -> void:
	titulo(Icones.VITORIA, "Fim da Fase 1")
	var texto := Narrativa.fim_de_fase()
	var pedido := altura_do_texto(texto, LARGURA - MARGEM_CARTAO)
	paragrafo_rolavel(texto, mini(pedido, ALTURA_NARRACAO_MAX))
	var botao := Button.new()
	botao.text = "Ver o balanço"
	botao.custom_minimum_size = Vector2(0, TOQUE_MIN)
	botao.pressed.connect(func() -> void:
		for filho in _vbox.get_children():
			filho.queue_free()
		# Os filhos só saem da árvore no fim do frame; sem isto o balanço
		# desenha-se POR BAIXO da narração que ainda não morreu.
		await get_tree().process_frame
		_mostrar_balanco()
	)
	_vbox.add_child(botao)


func _mostrar_balanco() -> void:
	titulo(Icones.VITORIA if _venceu else Icones.DERROTA,
		"O balanço" if _venceu else "Fim de jogo")

	var m: Dictionary = GameState.metrics
	paragrafo_rolavel("%s\n\nBarcos atendidos: %d\nBarcos perdidos: %d\nOfertas do rival igualadas: %d\nReceita de barcos: %s\nRenda do píer: %s\nReputação final: %d (%s)" % [
		GameState.texto(_motivo),
		int(m["boats_served"]), int(m["boats_lost"]), int(m["rival_matched"]),
		GameState.moeda(int(m["revenue"])),
		GameState.moeda(int(m.get("pier_income", 0))),
		int(GameState.reputation), GameState.reputation_label(),
	], ALTURA_TEXTO)

	var recomecar := Button.new()
	Icones.no_botao(recomecar, Icones.RECOMECAR)
	recomecar.text = "Jogar de novo"
	recomecar.custom_minimum_size = Vector2(0, TOQUE_MIN)
	recomecar.pressed.connect(func() -> void:
		GameState.clear_save()
		GameState.new_game()
		queue_free()
		get_tree().reload_current_scene()
	)
	_vbox.add_child(recomecar)

	# ⚠️ O BALANÇO ERA UM BECO SEM SAÍDA, e a segunda jogada no telefone bateu
	# nele (06/09): *"seria legal conseguir fechar essa tela, para que eu
	# pudesse ir nas configurações e pegar as informações completas da partida
	# ao invés de apenas esse print"*. Com um botão só — "Jogar de novo" — o
	# menu de pausa ficava inalcançável, e com ele o `Copiar registro da
	# partida`, que é justamente o `.jsonl` que responde melhor do que o print.
	#
	# ⚠️ E FECHAR NÃO PODE ABRIR OUTRO BECO. Quem fecha isto tem de conseguir
	# voltar: o menu de pausa ganhou "Ver o balanço" enquanto a partida está em
	# `game_over`, e é por isso que o rótulo diz por onde se volta. Um botão
	# que fecha sem dizer isso troca um beco por outro.
	var fechar := Button.new()
	fechar.text = "Fechar — volta pelo menu de pausa"
	fechar.custom_minimum_size = Vector2(0, TOQUE_MIN)
	fechar.pressed.connect(queue_free)
	_vbox.add_child(fechar)
