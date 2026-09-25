extends PainelNarrativo

# ============================================================
# BR Port VS — o fim do VS: a primeira parcela da Fase 1, paga ou não
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
# Reserva medida para cabeçalho, margens e botão na tela de narração. O balanço
# cresce com as linhas que realmente aparecem, em vez de guardar um vão vazio.
const MOLDURA_NARRACAO := 170

# O TETO da narração, e só o teto: a altura de verdade sai do TEXTO
# (`altura_do_texto`). 900 é o que sobra dos 1280 da tela depois do título, do
# botão e das margens do cartão, com folga para o cartão não encostar na borda.
# Enquanto a peça couber aqui, o jogador lê-a inteira sem rolar — que é a
# diferença entre ver o remate e sair no botão antes dele.
const ALTURA_NARRACAO_MAX := 900
# O que o tema gasta de margem lateral dentro do cartão, medido no render.
const MARGEM_CARTAO := 36

var _venceu := false
# O TEMPO DA CENA NA TELA, para quem a fotografa. A cobertura das capturas
# (`tools/conferir_cobertura_paineis.py`) lê daqui o catálogo — cada
# `tempo = &"..."` escrito neste arquivo é um tempo que tem de ter foto — e as
# ferramentas de captura imprimem o valor dele. ⚠️ SEMPRE LITERAL: uma
# atribuição por variável a ferramenta não sabe ler, e reprova em vez de a
# saltar (`docs/decisoes/051`).
var tempo: StringName = &""
var _motivo := ""


func setup(won: bool, reason: String) -> void:
	_venceu = won
	_motivo = reason
	# A narração e o balanço pedem alturas diferentes. Ambos crescem a partir
	# do conteúdo; o balanço de 600 px deixava quase metade do cartão vazia.
	montar(LARGURA, 0)
	if _venceu:
		_mostrar_narracao()
	else:
		_mostrar_balanco()


func _mostrar_narracao() -> void:
	tempo = &"narracao"
	# ⚠️ O TÍTULO DIZIA "Fim da Fase 1", por cima de uma narração que abre com
	# "A primeira de três parcelas" e "Faltam duas" — o título a fechar a fase
	# e o texto a dizer que ela continua. Veredito do Bruno no gate do A5
	# (23/09): «não é o fim da fase 1, apenas o pagamento de uma das três
	# parcelas». Vencer é `parcela_paid` (ver `_check_end`), logo o título é
	# verdade sempre que esta tela aparece.
	titulo_encorpado(Icones.VITORIA, "Primeira parcela paga")
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
	tempo = &"balanco"
	titulo_encorpado(Icones.VITORIA if _venceu else Icones.DERROTA,
		"O balanço" if _venceu else "Fim de jogo")

	var m: Dictionary = GameState.metrics
	tarja(GameState.texto(_motivo))
	secao("OPERAÇÃO")
	_metrica("Barcos atendidos", str(int(m["boats_served"])))
	_metrica("Barcos perdidos", str(int(m["boats_lost"])))
	# ⚠️ «IGUALADAS» NÃO ERA O QUE O NÚMERO CONTA. `rival_matched` sobe no
	# `_fechar_negocio()`, por onde passam o igualar E as duas apostas que o
	# cliente aceitou — quem segurou o preço seis vezes lia «6 igualadas». O que
	# ele mede é a disputa GANHA; e a perdida já estava no jogo
	# (`rival_refused`), escondida dentro dos «barcos perdidos».
	_metrica("Disputas com o rival", "%s · %s" % [
		Narrativa.concordar(int(m["rival_matched"]), "ganha", "ganhas"),
		Narrativa.concordar(int(m["rival_refused"]), "perdida", "perdidas")])
	secao("RECEITAS")
	_metrica("Ganho com barcos", GameState.moeda(int(m["revenue"])))
	_metrica("Renda do píer", GameState.moeda(int(m.get("pier_income", 0))))
	fio()
	_metrica("Reputação final", "%d (%s)" % [
		int(GameState.reputation), GameState.reputation_label()])

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


func _metrica(nome: String, valor: String) -> void:
	var linha := HBoxContainer.new()
	linha.add_theme_constant_override("separation", 8)
	var rotulo := Label.new()
	rotulo.text = nome
	rotulo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	linha.add_child(rotulo)
	var numero := Label.new()
	numero.text = valor
	numero.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	linha.add_child(numero)
	_vbox.add_child(linha)
