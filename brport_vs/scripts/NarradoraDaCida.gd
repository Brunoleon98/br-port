extends RefCounted

# ============================================================
# BR Port VS — a NARRADORA DA DONA CIDA
#
# As falas da Dona Cida EM JOGO, as que entram na faixa de mensagem: o que a
# põe a falar (sete sinais do `GameState`), a variante que cada momento pede
# e as memórias que impedem a mesma fala de se repetir — a faixa da reputação,
# a travessia do dinheiro curto e a semana já anunciada. O TEXTO não vive aqui:
# vive todo no `Narrativa.gd`, e isto escolhe o id. Até ao M8 da revisão de
# 09/10 (`docs/decisoes/096`) vivia no `Main.gd`; saiu palavra por palavra, e
# o que mudou está dito abaixo.
#
# ⚠️ NÃO É UM `class_name`, pela razão do trânsito dos camiões (`095`): lê o
# `GameState` pelo nome, e dentro de um `class_name` alcançado a partir de um
# `--script` isso não compila (`gdscript.md`). O `Main` carrega-a por
# `preload`; as ferramentas chegam-lhe pelo `Main` montado.
#
# ⚠️ E É UM OBJETO DO `Main`, como a `FilaDeMensagens` e o trânsito, e não um
# nó: não desenha nada e não tem `_process`. Fala para a fila que o `Main` lhe
# dá, e é lá que ela espera a vez dela na faixa.
#
# ⚠️ A ORDEM DAS LIGAÇÕES É A DE ANTES. Um sinal chama quem o ouve pela ordem
# em que se ligaram, e o `call_deferred` das falas entra na fila adiada por
# essa ordem: o `Main` chama o `conectar()` no fim do `_connect_game_state()`,
# exactamente onde as sete linhas estavam, e assim o HUD continua a ouvir o
# dinheiro e a reputação ANTES dela. Mudar a ordem seria mudar o jogo, e esta
# extração não muda nada — a bateria saiu igual ao byte (`096`).
# ============================================================

## O que ela acabou de dizer: o id que o jogo escolheu e o texto, no instante
## em que a linha entra na fila. Quem ouve é a sonda da régua da faixa
## (`tools/sonda_mensagens.gd`): até ao M8 ela herdava o `Main` e sobrescrevia
## o `_cida_agora` — e herdar o `Main` já não chega a esta função. O jogo não
## o liga a nada.
signal falou(id: String, linha: String)

# A fila da faixa, a do `Main`. A fala não escreve no Label: enfileira-se, e
# quem pinta é o `Main` quando a vez chega (`034`).
var _fila: FilaDeMensagens


func _init(fila: FilaDeMensagens) -> void:
	_fila = fila


func conectar() -> void:
	# AS FALAS DA DONA CIDA penduram-se em sinais que já existiam. Nenhuma
	# delas abre painel: são a faixa de mensagem que o jogo já tem, com voz.
	# Uma tela por evento seria um clique a cada coisa que acontece — e o
	# plano é explícito em que tela nova não pode mudar o ritmo do turno.
	GameState.obra_concluida.connect(_on_obra_concluida)
	GameState.rival_offer_triggered.connect(_cida_rival)
	# ⚠️ ESTAS DUAS ESTAVAM ESCRITAS E MUDAS desde 01/09 — um quarto da voz da
	# Dona Cida em jogo. `perdeu_para_arlindo` e `bom_contrato` viviam na
	# tabela, passavam o bloco F4 do fumaça e nenhuma linha do projeto as
	# disparava. O F4 não podia apanhar: ele pergunta "todo id da tabela tem
	# fala?", lendo a tabela dos DOIS lados — o espelho que o `CLAUDE.md`
	# nomeia. Quem apanhou foi a pergunta inversa, hoje no bloco F6.
	GameState.negociacao_resolvida.connect(_cida_negociacao)
	GameState.contrato_fechado.connect(_cida_contrato)
	GameState.reputation_changed.connect(_cida_reputacao)
	GameState.cash_changed.connect(_cida_caixa)
	GameState.turn_advanced.connect(_cida_semana)


# ⚠️ UM MÉTODO, E NÃO O LAMBDA QUE ISTO ERA NO `Main`. Ligado a um sinal, um
# lambda guarda uma referência FORTE ao `RefCounted` onde nasceu — medido numa
# sonda em 11/10: largado o objeto, ele continuava vivo e a ouvir o sinal, e a
# ligação por método morria com ele. Como o `GameState` vive o jogo inteiro,
# cada `Main` que as suítes montam e soltam deixaria uma narradora a falar
# para uma fila que ninguém pinta. No `Main`, um nó, o lambda morria com ele.
func _on_obra_concluida(_id: String) -> void:
	_obra_pronta.call_deferred()


# ⚠️ ESTE COMENTÁRIO AFIRMAVA O CONTRÁRIO DO QUE ACONTECIA, e foi por isso que
# ninguém foi ver: dizia que a fala "NÃO tapa a mensagem do sistema, porque
# quem chama isto chama-o depois do evento". Só `_cida_negociacao` e
# `_cida_contrato` são chamados assim; os outros cinco vêm de sinais que o
# GameState emite ANTES do `message.emit` da mesma chamada. Quem garante a
# ordem agora é o `_cida`, num lugar só — e é lá que está a medição.
#
# O barco foi mesmo para o Porto Farol. A fala existe para o jogador que
# NEGOCIOU e perdeu — "perdeu perdendo bem" —, então só sai no resultado
# "perdido" e nunca quando ele fecha negócio.
func _cida_negociacao(_acao: String, resultado: String, _tentativa: int) -> void:
	if resultado == "perdido":
		_cida("perdeu_para_arlindo")


# O QUE CONTA POR "BOM CONTRATO" sai da faixa da própria CLASSE, e não de um
# número escrito aqui: o quarto de cima do que aquela classe pode valer. Assim
# a fala continua rara quando o porto cresce e passa a receber navio grande —
# um limiar em reais viraria "todo navio de longo curso fecha o mês", que é o
# contrário de "Anota aí".
#
# Não mexe em dinheiro nenhum: é faixa de mensagem, não decisão nem tela, e por
# isso não toca no ritmo que a economia mede.
const BOM_CONTRATO_QUARTIL := 0.75


func _cida_contrato(valor: int, classe: String) -> void:
	if not GameState.CLASSES_DE_NAVIO.has(classe):
		return
	var faixa: Dictionary = GameState.CLASSES_DE_NAVIO[classe]
	var minimo: int = int(faixa["valor_min"])
	var maximo: int = int(faixa["valor_max"])
	if valor >= minimo + int(round((maximo - minimo) * BOM_CONTRATO_QUARTIL)):
		_cida("bom_contrato")


# ⚠️ A FALA ENTRA NO FIM DO FRAME, e não no instante do sinal. O comentário
# acima afirmava que ela não tapa a mensagem do sistema "porque quem chama isto
# chama-o depois do evento" — e isso era verdade só para os gatilhos que o Main
# chama à mão. Nos que vêm do GameState era o CONTRÁRIO: `obra_concluida`
# sai uma linha ANTES do `message.emit("… — pronto")`, e os dois escrevem no
# mesmo Label na mesma chamada.
#
# Medido em 18/09, cinco sementes, partidas inteiras: `upgrade_pronto` foi
# escrita 35 vezes e VISTA nenhuma; `caixa_baixo` 11 e nenhuma; `reputacao_caiu`
# 12 e nenhuma. São cinco pares — os três que a revisão contou em `cash_changed`
# mais os dois que `_fechar_negocio` e `_perder_para_rival` escondiam.
#
# O `call_deferred` conserta os cinco de uma vez e mantém a regra num lugar só,
# em vez de reordenar cinco sítios do GameState e deixar o sexto por nascer.
# O preço é o inverso: agora é a mensagem do sistema que fica por baixo. Mostrar
# as DUAS é a fila do R5, e é item próprio — isto entrega a fala VISTA, que é o
# que a §7.1 promete aqui.
# A PRIMEIRA OFERTA CHEGA ANTES DE EXISTIR RECUSA NENHUMA, e a fala afirmava
# que o Porto Farol aceita "tudo que a gente recusa". Quem conta as recusas é
# `metrics["rival_refused"]`, que já existe — nenhum limiar novo.
func _cida_rival(_doca: int) -> void:
	if int(GameState.metrics.get("rival_refused", 0)) > 0:
		_cida("arlindo_indireto")
	else:
		_cida("arlindo_primeira")


func _cida(id: String) -> void:
	_cida_agora.call_deferred(id)


# Escreve já. Existe em separado para quem precisa de RESOLVER o id no mesmo
# instante em que a linha é escrita — se `_semana_nova()` chamasse `_cida()`
# ficaria com DUAS camadas de adiamento e passaria à frente das falas adiadas
# uma vez só, invertendo a prioridade entre elas sem que nada o dissesse.
func _cida_agora(id: String) -> void:
	var linha := Narrativa.cida(id)
	if linha != "":
		falou.emit(id, linha)
		_fila.enfileirar(linha, "", "cida", GameState.turn, "",
			Narrativa.retrato("cida", id))


# A REPUTAÇÃO SÓ FALA QUANDO CRUZA UMA FAIXA, não a cada ponto. Ela mexe-se em
# quase todo turno (±0,8 por barco), e uma fala por movimento seria a Dona Cida
# a comentar ruído. A faixa qualitativa já existe em `reputation_label()` e é a
# unidade em que o jogador pensa — "respeitado" virou "admirado" é notícia,
# 71,2 virar 72,0 não é.
var _faixa_reputacao := ""
var _reputacao_vista := 0.0


func _cida_reputacao(valor: float) -> void:
	var faixa: String = GameState.reputation_label()
	# A primeira chamada só regista onde a barra estava: sem um valor anterior
	# não há direção nenhuma para anunciar.
	if _faixa_reputacao == "":
		_faixa_reputacao = faixa
		_reputacao_vista = valor
		return
	if faixa != _faixa_reputacao:
		# A DIREÇÃO SAI DO VALOR GUARDADO, não da barra corrente. A primeira
		# versão comparava a reputação com ela própria, o que dá sempre falso —
		# a Dona Cida teria dito "caiu" mesmo quando subia, e nada reprovaria.
		_cida("reputacao_subiu" if valor > _reputacao_vista else "reputacao_caiu")
		_faixa_reputacao = faixa
	_reputacao_vista = valor


# O aviso de caixa curto dispara UMA VEZ por travessia, não a cada centavo
# abaixo da linha. Sem a memória do estado anterior ele repetir-se-ia em todo
# turno enquanto o jogador estivesse apertado — que é justamente quando ele
# menos precisa de ser lembrado.
var _caixa_estava_curto := false


func _cida_caixa(_valor: int) -> void:
	# O CRITÉRIO SAI DO GAMESTATE, que é o mesmo que a fala da semana nova lê.
	# Estava escrito aqui como `valor < PARCELA_AMOUNT / 2`, e a segunda
	# leitora teria feito uma cópia.
	var curto: bool = GameState.caixa_curto()
	if curto and not _caixa_estava_curto:
		# ⚠️ E A PARCELA PODE JÁ TER SIDO PAGA — `pagar_parcela_adiantado()`
		# quita a qualquer momento. "A parcela não vai esperar" seria falsa
		# desde esse turno até ao fim da partida.
		if GameState.parcela_paid:
			_cida("caixa_baixo_quitado")
		else:
			_cida("caixa_baixo")
	_caixa_estava_curto = curto


var _semana_vista := 0


func _cida_semana(_turno: int, semana: int) -> void:
	if semana == _semana_vista:
		return
	# A semana 1 não é "semana nova": é a primeira, e o jogador acabou de ler o
	# diário. A fala é sobre voltar ao trabalho, não sobre começar.
	if _semana_vista > 0:
		_semana_nova.call_deferred()
	_semana_vista = semana


# ⚠️ O PREDICADO LÊ-SE ONDE A LINHA É ESCRITA, e não onde o sinal dispara.
# `turn_advanced` sai ANTES de `_check_end() -> _spawn_boats()`, e o laço de
# serviço já esvaziou toda doca sem trabalhador: medido em 18/09, em 315
# viradas de turno sobre cinco sementes e duas formas de jogar,
# `docas_esperando()` deu ZERO todas as vezes. Uma variante que dissesse
# "Barcos na fila" ali seria uma frase que ninguém jamais leria — o
# `barco_medio` outra vez, agora na narrativa.
#
# Um instante depois, com o sorteio do dia já feito, a mesma conta dá barco à
# espera em 74 de 155 viradas. E é esse o estado que o jogador tem à frente
# quando lê a faixa.
#
# ⚠️ E DESDE A `083` A PERGUNTA É OUTRA: «barcos esperando» passou a ser a
# fila no fundeadouro (`barcos_ao_largo()`), e o barco já não espera NA doca
# por um trabalhador — o `docas_esperando()` daria zero sempre, que é o
# defeito acima com outra causa.
#
# ⚠️ OS IDs SÃO LITERAIS, e de propósito: o bloco F4 do `teste_fumaca` varre
# este arquivo à procura das strings de `_cida`, e um id composto por
# concatenação seria mudo para ela — a guarda daria um verde de graça.
func _semana_nova() -> void:
	var fila: bool = GameState.barcos_ao_largo() > 0
	var curto: bool = GameState.caixa_curto()
	if fila and curto:
		_cida_agora("semana_nova_fila_curto")
	elif fila:
		_cida_agora("semana_nova_fila_folgado")
	elif curto:
		# ⚠️ A PARCELA SÓ ENTRA NA FRASE SE ELA EXISTIR. `caixa_curto()` é a
		# meia parcela e não diz nada sobre ela estar paga; quem quita cedo
		# ouviria "a parcela correndo" em todas as semanas seguintes, que é a
		# frase verdadeira em português e falsa neste mundo. É o mesmo par que
		# o `_cida_caixa()` já fazia uma dobra acima, e que aqui faltava.
		if GameState.parcela_paid:
			_cida_agora("semana_nova_parado_curto_quitado")
		else:
			_cida_agora("semana_nova_parado_curto")
	else:
		_cida_agora("semana_nova_parado_folgado")


# A OBRA: a reação muda a partir da TERCEIRA, e a contagem é a do próprio jogo.
#
# "Olha que eu duvidei" é fala de primeira vez. As estruturas são SETE, e um
# jogador que as levante todas ouviria a mesma dúvida sete vezes — a partir da
# terceira ela já foi desmentida duas, e repeti-la lê como a Dona Cida não
# estar a ver o porto crescer. É a regra da DOSE que o maneirismo do Arlindo
# ensinou, com o sinal trocado: ali faltava repetição para o "sobrinho" fazer
# padrão (e nem a repetição o salvou — saiu em 23/09), aqui sobra.
#
# ⚠️ E A CONTAGEM SAI DE `estruturas`, que é onde o jogo a guarda. Um contador
# próprio aqui seria uma segunda verdade a divergir da primeira — e esta não
# precisa sequer de memória: a conclusão faz `estruturas.append(id)`
# ANTES de emitir, logo no fim do frame a lista já conta esta obra.
#
# Desde `087`, só uma obra ocorre por vez. A fala reage à conclusão, nunca
# ao pagamento; o porto ainda está em ruínas enquanto os dias não passam.
const OBRA_ROTINA_A_PARTIR_DE := 3


func _obra_pronta() -> void:
	if GameState.estruturas.size() >= OBRA_ROTINA_A_PARTIR_DE:
		_cida_agora("upgrade_pronto_rotina")
	else:
		_cida_agora("upgrade_pronto")
