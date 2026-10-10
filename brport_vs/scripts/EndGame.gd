extends PainelNarrativo

# ============================================================
# BR Port VS — o fim da Fase 1: três parcelas quitadas, ou o porto perdido
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

# ⚠️ A NARRAÇÃO É UMA ENTRADA DO DIÁRIO desde a `082`, e não um cartão. Era o
# cartão branco de sempre com a peça em seminegrito corrido — o momento de mais
# peso da partida a ler-se como um extrato —, e o Bruno escolheu-a como página
# do caderno que o diário abre na primeira semana: o fim fecha o que o começo
# abriu. Duas páginas, porque a peça pede 34 linhas de pauta com a data e a
# folha leva 26 (medido no D22); o «—» do meio, que já a partia em duas, é a
# virada da folha (a mesma da tela de nomes). O D22 confere que cada página
# cabe, com o nome mais comprido.
#
# O cartão de antes media a altura do texto (`altura_do_texto`) para não
# esconder o remate debaixo de uma dobra; o caderno não rola, e a pergunta
# passou a ser se cada página cabe na folha.

var _venceu := false
# O TEMPO DA CENA NA TELA, para quem a fotografa. A cobertura das capturas
# (`tools/conferir_cobertura_paineis.py`) lê daqui o catálogo — cada
# `tempo = &"..."` escrito neste arquivo é um tempo que tem de ter foto — e as
# ferramentas de captura imprimem o valor dele. ⚠️ SEMPRE LITERAL: uma
# atribuição por variável a ferramenta não sabe ler, e reprova em vez de a
# saltar (`docs/decisoes/051`).
var tempo: StringName = &""
var _motivo := ""
# As duas páginas da narração e o botão por baixo do caderno, que vira a
# folha na primeira e abre o balanço na segunda.
var _primeira: PanelContainer
var _folha_da_primeira: Control
var _folha_da_segunda: Control
var _botao: Button
var _virando := false


func setup(won: bool, reason: String) -> void:
	_venceu = won
	_motivo = reason
	if _venceu:
		_mostrar_narracao()
	else:
		# O balanço cresce a partir do conteúdo; o de 600 px deixava quase
		# metade do cartão vazia.
		montar(LARGURA, 0)
		_mostrar_balanco()


func _mostrar_narracao() -> void:
	tempo = &"narracao"
	var paginas := Narrativa.fim_de_fase_paginas()
	montar_caderno(ESCURO_LEITURA)
	# A SEGUNDA PÁGINA PRIMEIRO, por baixo, e já escrita: é ela que a virada
	# revela. Traz a fita, que é do livro (`pagina_do_caderno`).
	var segunda := pagina_do_caderno(true, true)
	_folha_da_segunda = _folha
	entrada_do_diario("", paginas[1])
	# O RECIBO DA PARCELA no que sobra da folha (terceira passagem): a peça
	# acaba a meio da segunda página, e a primeira tentativa de a encher — o
	# remate descido ao pé — deixava-o «isolado», nas palavras do Bruno. Ele
	# voltou ao lugar dele, e o vão é do papel que se guarda. Centrado entre o
	# texto e o pé por dois vãos elásticos: o recibo não está na pauta, e por
	# isso pode pousar em qualquer altura.
	segunda.add_child(_vao())
	recibo_colado(_linhas_do_recibo(), GameState.moeda(GameState.total_pago_parcelas),
		"PAGO")
	segunda.add_child(_vao())
	# A primeira por cima, datada como o diário, com a orelha no canto de
	# baixo — o canto que a mão levanta para virar.
	pagina_do_caderno(true, false, FolhaDoCaderno.Orelha.BAIXO)
	_primeira = pagina_atual()
	_primeira.name = "PrimeiraPagina"
	_folha_da_primeira = _folha
	entrada_do_diario(Narrativa.fim_de_fase_cabecalho(), paginas[0])
	# A 085 completa as três cobranças: esta tela só abre após a terceira.
	# A peça e o título agora fecham o mesmo arco, mantendo o caderno aprovado.
	legenda_acima_do_caderno("Fase 1 concluída", "", Icones.VITORIA)
	_botao = botao_abaixo_do_caderno("Virar a página", _virar_pagina)


# O recibo soma o que saiu do caixa, incluindo descontos por antecipação.
# Imprimir a soma dos principais cobraria juros que o jogador não pagou.
# É papel impresso de banco e não prosa — os dígitos são do documento, e a
# regra «nenhum dígito na narração» é da peça escrita à mão por cima dele.
func _linhas_do_recibo() -> Array:
	return ["BANCO PORTO MIRIM",
		"Recibo — %s" % Narrativa.concordar(int(GameState.parcelas_quitadas),
			"parcela quitada", "parcelas quitadas"),
		GameState.texto("{portName}")]


func _vao() -> Control:
	var vao := Control.new()
	vao.size_flags_vertical = Control.SIZE_EXPAND_FILL
	return vao


func _virar_pagina() -> void:
	if _virando:
		return
	_virando = true
	var t := virar_folha(_primeira, _folha_da_primeira, _folha_da_segunda)
	t.tween_callback(_na_segunda_pagina)


# A folha virada SAI: na tela de nomes o painel fechava no fim da virada e o
# que sobrava dela não se via; aqui a segunda página fica na tela, e a folha
# enrolada (ou encolhida, sem imagem) ficaria por cima dela.
func _na_segunda_pagina() -> void:
	tempo = &"segunda_pagina"
	_primeira.visible = false
	var curva := _caderno_capa.get_node_or_null("FolhaVirando")
	if curva != null:
		curva.queue_free()
	_botao.text = "Ver o balanço"
	_botao.pressed.disconnect(_virar_pagina)
	_botao.pressed.connect(_ver_balanco)


func _ver_balanco() -> void:
	for filho in get_children():
		filho.queue_free()
	# Os filhos só saem da árvore no fim do frame; sem isto o balanço
	# desenha-se POR BAIXO do caderno que ainda não morreu.
	await get_tree().process_frame
	montar(LARGURA, 0)
	_mostrar_balanco()


func _mostrar_balanco() -> void:
	tempo = &"balanco"
	titulo_encorpado(Icones.VITORIA if _venceu else Icones.DERROTA,
		"O balanço" if _venceu else "Fim de jogo")

	var m: Dictionary = GameState.metrics
	# Verde quem quitou, vermelho quem perdeu o porto — o motivo, logo ao lado,
	# é quem o diz; o tom só o repete (quinta passagem, `063`).
	tarja(GameState.texto(_motivo), "", &"bom" if _venceu else &"ruim")
	secao("OPERAÇÃO")
	# OS NÚMEROS DA PARTIDA EM QUADROS (25/09, quarta passagem). Eram quatro
	# linhas de «rótulo … número» iguais às da receita, e o balanço lia-se como
	# o meio de um extrato. Tela de fim de nível mostra os seus números em
	# destaque, cada um no seu quadro — é a caixa do lucro das finanças do
	# *Two Point Hospital* —, e os contados vão para cima; o dinheiro continua
	# em linhas, porque é soma e compara-se em coluna.
	#
	# ⚠️ O RÓTULO VAI EM CIMA E NÃO CONCORDA COM O NÚMERO, de propósito: é o
	# nome da categoria («Barcos atendidos», com 1 ou com 24), e por isso não
	# precisa do `concordar()` que o F9 exige a toda contagem escrita em frase.
	#
	# ⚠️ «IGUALADAS» NÃO ERA O QUE O NÚMERO CONTA. `rival_matched` sobe no
	# `_fechar_negocio()`, por onde passam o igualar E as duas apostas que o
	# cliente aceitou — quem segurou o preço seis vezes lia «6 igualadas». O que
	# ele mede é a disputa GANHA; e a perdida já estava no jogo
	# (`rival_refused`), escondida dentro dos «barcos perdidos».
	var quadros := grade_de_quadros()
	quadro(quadros, "Barcos atendidos", str(int(m["boats_served"])))
	quadro(quadros, "Barcos perdidos", str(int(m["boats_lost"])))
	quadro(quadros, "Disputas ganhas", str(int(m["rival_matched"])))
	quadro(quadros, "Disputas perdidas", str(int(m["rival_refused"])))
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
