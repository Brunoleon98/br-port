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
# Estrutura levantada. Existe separado de `message` porque construir merece
# som PRÓPRIO: uma pancada de madeira, e não o mesmo tinido de "deu certo" que
# tocaria ao alocar um trabalhador. O áudio é o único ouvinte hoje.
signal estrutura_comprada(id: String)
signal rival_offer_triggered(dock_index: int)
signal debt_due(amount: int)
signal game_over(won: bool, reason: String)
signal message(text: String, kind: String)
signal state_loaded()
# Uma semana fechou, com o resumo por fonte. Existe separado de `message`
# porque o Boletim Financeiro da Dona Cida é uma TELA, não uma faixa de texto —
# e porque quem o escuta precisa dos números decompostos, que a mensagem não
# carrega. O simulador de balanceamento não escuta isto: ele nunca abre cena,
# então o boletim não existe para ele e não pode mexer no que ele mede.
signal semana_fechada(resumo: Dictionary)

# A contra-oferta do Arlindo fechou uma rodada: o que o jogador escolheu, no
# que deu, e em que tentativa. Sinal de OBSERVAÇÃO — nada no jogo o escuta,
# quem o escuta é o `Registro.gd` (item B7).
#
# Existe porque `negotiate_rival()` DEVOLVE o resultado em vez de o emitir, e
# um valor de retorno só chega a quem chamou. O painel da contra-oferta é o
# único que chama, então sem este sinal a escolha mais interessante da partida
# — a única em que o jogador aposta contra o acaso — seria a única que o
# registro não veria.
#
# O simulador de balanceamento chama `negotiate_rival()` milhares de vezes e
# portanto emite isto milhares de vezes; é de propósito que emitir seja barato
# e que o gravador esteja DESARMADO ali (ver o cabeçalho do `Registro.gd`).
signal negociacao_resolvida(acao: String, resultado: String, tentativa: int)

# ── TUNING: economia (fonte: GDD 7 — Sistemas > economia, Fase 1) ──
#
# ESCALA REALISTA E JOGO TRANQUILO (02/09) — os dois de uma vez, e a ordem em
# que foram feitos importa para quem vier reler isto.
#
# Primeiro os valores subiram ×100 e MEDIU-SE que nada mudava: todas as
# medianas escalaram exatamente ×100 (margem em regime R$2.943 -> R$295.116).
# Escala uniforme é cosmética, e prová-lo foi o que permitiu separar o efeito
# da escala do efeito dos ratios.
#
# Depois os RATIOS mudaram, e esses mudam o jogo. Os de antes não eram
# realistas: um trabalhador custava 60% de um barco, e a manutenção de um porto
# inteiro custava menos do que meio contrato. Agora a mão de obra é fração
# pequena da taxa de serviço, a manutenção é custo fixo de verdade, e o capital
# (píer, armazém) é o que pesa — que é o que um porto é.
#
# TUNING — medido, não estimado. 600 partidas por perfil em
# tools/simular_balanceamento.gd: **ótimo 99,8% · mediano 80,5% · descuidado
# 35,2%**. A mediana do mediano fecha em R$745.875 contra uma parcela de
# R$530.000. Mexer aqui SEM rodar o simulador quebra isso.
#
# O ALVO MUDOU, e é decisão registrada (docs/decisoes/005): o jogo é TRANQUILO.
# Os 47% do jogador mediano eram a fantasia de sobrevivência que essa decisão
# substituiu — a dívida deixou de ser o motor, e quem discrimina os jogadores
# passou a ser o PORTO QUE ELES CONSEGUEM LEVANTAR, não se pagam a parcela: o
# Ótimo atende 50,5 barcos e chega a 15,9/semana, o Descuidado atende 12,1 e
# fica em 3,2/semana. A manutenção alta é o que faz essa diferença doer, porque
# custo fixo pesa proporcionalmente muito mais em quem tem pouca vazão.
const START_CASH := 400000
const SALARY_PER_WORKER := 6000          # TUNING sobre a linha "Margem operacional base" do GDD, reescalada
const MAINTENANCE_WEEKLY := 40000        # TUNING sobre a mesma linha do GDD — o custo fixo que separa os perfis
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
		"custo": 150000, "ordem": 1, "requer": "",
	},
	"pier_3": {
		"nome": "Reconstruir o Píer 3",
		"desc": "+1 doca e +1 trabalhador",
		"custo": 260000, "ordem": 2, "requer": "pier_2",
	},
	"armazem": {
		"nome": "Consertar o armazém",
		"desc": "+50% no barco que vem deixar carga",
		"custo": 180000, "ordem": 3, "requer": "",
	},
	"patio": {
		"nome": "Pavimentar o pátio",
		"desc": "dobra a renda do píer e +30% no contêiner",
		"custo": 115000, "ordem": 4, "requer": "",
	},
	"escritorio": {
		"nome": "Reformar o escritório",
		"desc": "-50% nos salários da semana",
		"custo": 80000, "ordem": 5, "requer": "",
	},
	# ── OS DOIS UPGRADES DE NÍVEL ──
	#
	# O GDD 7 decidiu que "estruturas principais (grua, cais, armazém) têm
	# upgrade in-place de até 3 níveis", e a ARTE dos três já existia desde
	# 05/09 — `pier_n1..n3` e `lanca_n1..n3`, escolhidas por uma leitura
	# derivada. Estes dois são a MECÂNICA que faltava, e entram como estrutura
	# comprável e não como fase nova, de propósito: fase nova travaria o
	# `advance_turn()` e o simulador de balanceamento, que só sabe resolver
	# duas (ver a nota em `nivel_pier()`).
	#
	# ⚠️ ELES SÃO OS ÚLTIMOS DA CADEIA, E É ISSO QUE FAZ O BLOQUEIO. Sem
	# conceito de Fase no VS, quem tranca um upgrade até o porto estar de pé é
	# o `requer` que já existia — e trancar pelo pré-requisito é mais honesto
	# do que inventar uma Fase que o resto do jogo não conhece.
	"guindaste": {
		"nome": "Guindaste de pórtico",
		"desc": "corta um turno de cada operação",
		"custo": 120000, "ordem": 6, "requer": "pier_2",
	},
	"cais": {
		"nome": "Reforçar o cais",
		"desc": "+60% de chance de navio grande atracar",
		"custo": 150000, "ordem": 7, "requer": "guindaste",
	},
}

# O guindaste de pórtico corta o tempo de operação. É o único dos sete que mexe
# na VAZÃO em vez de no valor: os outros multiplicam dinheiro, este devolve
# turnos, e turno devolvido vira barco a mais.
#
# ⚠️ ELE CORTA UM TURNO DE QUALQUER OPERAÇÃO, e não "põe o navio grande em 1".
# A diferença só aparece desde que o granel existe: escrito como destino fixo,
# o pórtico levaria uma operação de três turnos ao mesmo lugar que uma de dois,
# e o barco mais pesado do jogo passaria a descarregar tão depressa quanto o
# mais leve. Para tudo o que não é granel a conta dá o mesmo de antes — grande
# 2 → 1, pequeno 1 → 1 —, que é o número que o balanceamento de 05/09 mediu.
const GUINDASTE_CORTA_TURNOS := 1        # TUNING
# O cais reforçado muda a MISTURA de barcos, não o valor de nenhum: um cais de
# concreto aguenta navio maior, e navio maior paga mais. Multiplicador sobre o
# `BOAT_LARGE_CHANCE`, preso a 1,0 para não passar de "só navio grande".
const CAIS_CHANCE_GRANDE := 1.60         # TUNING

# ⚠️ O BÓNUS DO ARMAZÉM DEIXOU DE SER GLOBAL EM 06/09. Ele era +20% em TODO
# barco atendido, o que fazia o armazém valorizar também o peixe que sai do
# cais direto para o mercado. Agora só vale para o barco cujo MOTIVO é deixar
# carga armazenada — ver o bloco `MOTIVOS` logo abaixo. A percentagem subiu de
# 0,20 para compensar: o bónus passou a cair em ~4 de cada 10 barcos em vez de
# em todos, e sem subir o armazém deixaria de se pagar.
const ARMAZEM_BONUS := 0.50             # TUNING
# O pátio pavimentado tem DOIS efeitos, e são de naturezas diferentes: dobra a
# renda semanal do píer (abaixo) e valoriza o contêiner que ele empilha. O
# segundo é o que dá motivo à pilha desenhada no mapa.
const PATIO_BONUS_CARGA := 0.30         # TUNING
const PATIO_BONUS_PIER := 1.00          # TUNING
# O escritório mexia na manutenção (R$30/sem): pouparia R$18 por semana e
# nunca se pagaria. Agora corta SALÁRIO, que é o custo que cresce com o
# porto — é o que torna a compra uma decisão e não uma armadilha.
const ESCRITORIO_DESCONTO_SALARIO := 0.50   # TUNING

# ── MOTIVO DA ESCALA ──
#
# POR QUE o navio veio ao porto. Até 05/09 um barco tinha VALOR e TAMANHO e
# mais nada: dois barcos de R$45.000 pediam exatamente a mesma coisa, e servir
# era sempre a mesma operação. O motivo é o que os faz pedir coisas diferentes.
#
# ⚠️ CADA MOTIVO PRENDE-SE A UMA ESTRUTURA QUE JÁ EXISTE, e é essa a decisão.
# Reparo pede oficina naval e reabastecimento pede posto de combustível — as
# duas são Fase 2 pelo GDD, que chama a fase 02 de "Cais com Oficina" e põe o
# posto como primeiro upgrade de infraestrutura. Inventá-las aqui seria codar a
# economia da Fase 2 antes de responder a pergunta que a
# `BR_Port_GDD_V7_ERRATA_ECONOMIA.md` deixou aberta. Carga e descarga cabem na
# Fase 1, e é só delas que este bloco trata (`docs/decisoes/008`).
#
# ⚠️ E O EFEITO É DA ESTRUTURA, NUNCA DO MOTIVO SOZINHO. Um motivo que pagasse
# mais por si seria só outro sorteio de valor, com um nome bonito por cima: o
# jogador veria a etiqueta mudar e não teria o que decidir. Preso à estrutura,
# ele diz onde gastar o próximo dinheiro — e o cais reforçado, que empurra a
# mistura para o barco grande, passa a decidir também QUAIS motivos aparecem.
#
# `peso_pequeno` e `peso_grande` são pesos de sorteio por tamanho de barco, em
# centos: o pesqueiro não traz contêiner e o graneleiro não é pesqueiro. Somam
# 100 em cada coluna, e é assim que se lê a mistura sem fazer conta.
const MOTIVOS := {
	"pescado": {
		"nome": "Pescado", "estrutura": "", "bonus": 0.0, "turnos_extra": 0,
		"peso_pequeno": 55, "peso_grande": 0,
	},
	"armazenagem": {
		"nome": "Armazenagem", "estrutura": "armazem", "bonus": ARMAZEM_BONUS,
		"turnos_extra": 0, "peso_pequeno": 45, "peso_grande": 35,
	},
	"conteiner": {
		"nome": "Contêiner", "estrutura": "patio", "bonus": PATIO_BONUS_CARGA,
		"turnos_extra": 0, "peso_pequeno": 0, "peso_grande": 40,
	},
	# O granel é o único que paga em TURNO em vez de em dinheiro, e de
	# propósito: quatro motivos que fossem quatro multiplicadores seriam o
	# mesmo motivo quatro vezes. Sem pórtico ele ocupa o berço um turno a mais,
	# que é o custo que o guindaste existe para pagar.
	"granel": {
		"nome": "Granel", "estrutura": "guindaste", "bonus": 0.0,
		"turnos_extra": 1, "peso_pequeno": 0, "peso_grande": 25,
	},
}

const PIER_SLOTS := 6                   # GDD "Margem operacional base": 6 vagas de píer
const PIER_RATE_PER_SLOT := 5000        # GDD "Margem operacional base", reescalado: renda fixa semanal

# GDD "Valor de contratos". A FAIXA do GDD (R$80–300) é de antes da reescala
# de 02/09 e não vale mais como valor absoluto; o que dela sobrevive é a
# PROPORÇÃO — barco pequeno contra grande, e barco contra infraestrutura.
# O que faz a parcela caber nunca foi inflar o barco: é a quantidade de
# turnos (ver TURNS_PER_WEEK abaixo).
const BOAT_VALUE_SMALL_MIN := 8000
const BOAT_VALUE_SMALL_MAX := 20000
const BOAT_VALUE_LARGE_MIN := 20000
const BOAT_VALUE_LARGE_MAX := 70000
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

# TUNING — o quanto a reputação pesa na aposta da contra-oferta (item A3).
# Ver `_chance_com_reputacao` para a conta e para o porquê deste ser o lugar
# onde a reputação atua, e não o preço ou a chegada de barco.
const REPUTACAO_EFEITO_NEGOCIACAO := 0.5

# ── REPUTAÇÃO COMERCIAL ──
# TUNING — a reputação MEXE na negociação (ver `_chance_com_reputacao`), e por
# isso estes números deixaram de ser cosméticos.
#
# Os ganhos foram divididos por cinco em 01/09, e a razão é medida: com +4 por
# barco atendido e um porto que atende ~13 barcos por semana, a barra batia no
# teto de 100 ainda na PRIMEIRA semana. Medido em 600 partidas por perfil,
# antes da correção: 79,8% das contra-ofertas do jogador Ótimo e 53,8% das do
# Mediano aconteciam já com reputação 100 — os dois perfis cuja separação é o
# que interessa chegavam à decisão com exatamente a mesma barra.
#
# Uma barra saturada não é um sistema: é um bónus fixo com mais código. Daí a
# escala nova, calibrada para a reputação SUBIR ao longo da partida inteira em
# vez de estourar no início.
const REPUTATION_START := 65.0
const REPUTATION_GAIN_SERVED := 0.8
const REPUTATION_LOSS_LOST := 2.5
const REPUTATION_GAIN_RIVAL_MATCHED := 1.0
const REPUTATION_LOSS_RIVAL_REFUSED := 8.0

# ── CADÊNCIA E PARCELA ──
# TUNING — esta é a constante que faz a economia da Fase 1 fechar.
# Com 3 turnos/semana a parcela de R$8.000 só cabia inflando o barco para
# R$240–760, fora da faixa do GDD. Com 8 turnos/semana o barco volta para
# os R$80–300 do GDD e a parcela continua alcançável. As taxas medidas estão
# no bloco de economia lá em cima — uma tabela só, para não haver duas
# versões dos mesmos números envelhecendo em ritmos diferentes.
const TURNS_PER_WEEK := 8
const WEEKS_TOTAL := 4
const TURNS_TOTAL := TURNS_PER_WEEK * WEEKS_TOTAL

# ⚠️ A PARCELA É O BOTÃO QUE MOVE O DESCUIDADO, E É SÓ ELE. Medido em
# `docs/decisoes/008`: com os motivos ligados, cada R$10.000 de parcela valem
# ~3 pontos de vitória para ele e ~0,5 para o mediano — os dois perfis não
# estão na mesma parte da distribuição, e é por isso que este número afina um
# sem estragar o outro. Desceu de R$550.000 em 06/09 para devolver ao
# descuidado os ~35% que a decisão 005 registou e que os upgrades de 05/09
# tinham levado a 31,0%.
const PARCELA_AMOUNT := 530000            # GDD "Parcelas validadas" / Protótipo VS — parcela única
const PARCELA_DUE_TURN := TURNS_PER_WEEK * 4   # vence ao fim da semana 4

# ── SAVE ──
const SAVE_PATH := "user://savegame.json"

# VERSÃO DO SAVE — subir SEMPRE que a forma do estado mudar.
#
# O save não tinha versão nenhuma, e isso já custou um bug de verdade: quando
# o porto passou a abrir com 1 doca em vez de 2, um jogo salvo antes continuou
# a ser carregado como se nada tivesse mudado. O jogador ficava com duas docas
# de graça, o painel de construção continuava a oferecer os píeres 2 e 3 (que
# nunca constaram de `estruturas`), e comprá-los levava o porto a 4 docas num
# mapa de 3. Save de outra versão não é save: é ruído com a extensão certa.
#
# 3 (01/09): o save passou a guardar os dois nomes que o jogador escolhe na
# abertura. Um save da versão 2 não os tem, e inventá-los seria adaptar — a
# partida recomeça, com a tela de nomes outra vez.
#
# 4 (01/09): e a contabilidade por fonte da semana, que o Boletim Financeiro
# lê. A 3 nunca saiu daqui, então podia ter-se reaproveitado o número — mas
# reaproveitar exige lembrar que se pode, e a regra vale mais barata do que a
# exceção: a forma mudou, a versão sobe.
#
# 6 (06/09): o barco passou a nascer com um MOTIVO, e a contabilidade ganhou a
# linha do pátio ao lado da do armazém. Um save da 5 traz barcos sem motivo, e
# `_lancar_receita()` indexa `MOTIVOS[motivo]` — o barco carregado rebentaria
# na primeira docagem, que é exatamente o tipo de estrago que a versão existe
# para evitar.
const SAVE_VERSION := 6

# ── OS DOIS NOMES ──
# O jogador escolhe-os na abertura, e a escolha é irrevogável (GDD 7).
#
# `Cais Mirim` é o nome-PADRÃO do porto, não o da cidade: a cidade é Porto
# Mirim e não muda. O GDD manda tratar o nome do porto como um token único em
# todo texto de interface e diálogo, com este valor exibido apenas se o jogador
# deixar o campo em branco.
const NOME_PORTO_PADRAO := "Cais Mirim"

# Para o nome do jogador NÃO há padrão, e é de propósito: inventar um nome
# seria pôr palavra na boca de quem não a escolheu. Quem deixa em branco fica
# sem vocativo, e as falas que o usariam têm variante para isso — o Toninho já
# trata por "chefia" e o Arlindo por "sobrinho", então ninguém fica sem
# forma de tratamento.
const NOME_JOGADOR_PADRAO := ""

# Limite de tamanho dos dois campos. Vem da tela, não do gosto: o nome do porto
# entra no cabeçalho do Boletim e na placa, e acima disto ele estoura a caixa
# nos 720px de largura do retrato.
const NOME_MAX_CARACTERES := 24

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

# Os nomes escolhidos na abertura. Vazios querem dizer "ainda não perguntámos"
# — é assim que o `Main` sabe abrir a tela de nomes, e não com um booleano à
# parte que pudesse discordar deles.
var nome_porto: String = ""
var nome_jogador: String = ""

# A CONTABILIDADE DA SEMANA EM CURSO, por fonte. Só OBSERVA: nenhum destes
# números entra numa conta do jogo, e o `cash` continua a ser mexido
# exatamente onde era. Existe porque o Boletim Financeiro pede receita e
# despesa DECOMPOSTAS, e `metrics` só guarda totais acumulados da partida —
# de onde não se consegue tirar uma semana.
#
# O bónus que uma estrutura acrescenta ao barco é contado à PARTE do valor
# dele. No jogo os dois vêm somados (`_lancar_receita`), e somado não dá para
# o mostrar como a linha própria que o boletim tem.
#
# ⚠️ AS LINHAS `armazem` E `patio` CHAMAM-SE COMO AS ESTRUTURAS, e isso é
# contrato: `_lancar_receita()` roteia o bónus por `destino[estrutura]`. Um
# motivo novo cujo `bonus` seja maior que zero e cuja estrutura não tenha linha
# aqui criaria a chave em silêncio — o Dictionary do GDScript aceita — e o
# dinheiro sumia da soma da receita sem erro nenhum. O bloco T5h da suíte
# tranca isso.
const SEMANA_ZERADA := {
	"docagens": 0, "armazem": 0, "patio": 0, "pier": 0,
	"salarios": 0, "manutencao": 0, "parcela": 0,
}
var semana_atual: Dictionary = SEMANA_ZERADA.duplicate()

# A MESMA CONTABILIDADE, MAS DO DIA. O boletim fecha a semana; o jogador toca
# no caixa a meio dela e quer saber o que entrou ONTEM — e isso não se tira do
# acumulador semanal, que já somou os outros dias.
#
# São dois dicionários e não um: `dia_atual` enche-se durante o turno e
# `dia_anterior` é o que ficou do turno que acabou. Sem os dois, tocar no caixa
# a meio de um turno mostraria uma soma parcial que muda enquanto se olha.
const DIA_ZERADO := {
	"docagens": 0, "armazem": 0, "patio": 0, "pier": 0,
	"salarios": 0, "manutencao": 0, "parcela": 0,
	"servidos": 0, "perdidos": 0, "turno": 0,
}
var dia_atual: Dictionary = DIA_ZERADO.duplicate()
var dia_anterior: Dictionary = DIA_ZERADO.duplicate()

# O resultado líquido de cada semana já fechada, em ordem. A Dona Cida compara
# a semana contra a média das anteriores para escolher o tom, e sem histórico
# não há com que comparar — na semana 1 ela usa só o sinal do resultado.
var historico_semanas: Array = []

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
	# Partida nova pergunta os nomes outra vez. Zerar aqui, e não deixar para
	# quem chama, é o que mantém o `new_game()` exaustivo — a lista de campos
	# que ele reescreve é a mesma que o `load_game()` lê, e um campo de fora
	# dessa lista é como o estado impossível atravessa de uma partida para a
	# seguinte (ver o comentário do load_game).
	nome_porto = ""
	nome_jogador = ""
	semana_atual = SEMANA_ZERADA.duplicate()
	dia_atual = DIA_ZERADO.duplicate()
	dia_anterior = DIA_ZERADO.duplicate()
	historico_semanas = []
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


# O NOME DO PORTO E O DO JOGADOR SAEM DAQUI, E SÓ DAQUI.
#
# O GDD manda tratar o nome do porto como um token único em todo texto de
# interface e diálogo, com "Cais Mirim" exibido só se o campo ficar em branco.
# Isso obriga a um ponto de substituição — a alternativa é cada tela lembrar-se
# de trocar, e a que esquecer mostra `{portName}` cru ao jogador.
#
# Mesma razão do `moeda()` logo acima: quatro telas mostram dinheiro e não pode
# haver quatro versões da regra. Aqui são sete telas e dois tokens.
#
# O nome do JOGADOR não tem padrão de propósito — inventar um seria pôr palavra
# na boca de quem não a escolheu. Quem deixa em branco fica sem vocativo, e as
# falas que o usariam têm variante para isso (ver Narrativa.gd).
func texto(modelo: String) -> String:
	var porto := nome_porto if nome_porto != "" else NOME_PORTO_PADRAO
	return modelo.replace("{portName}", porto).replace("{playerName}", nome_jogador)


# Se ainda não perguntámos os nomes. É derivado do estado, e não um booleano à
# parte que pudesse discordar dele: um save da versão 3 gravado depois da tela
# tem sempre nome de porto, nem que seja o padrão escrito por extenso.
func precisa_dos_nomes() -> bool:
	return nome_porto == ""


# Grava a escolha da tela de abertura. Vazio no porto vira o padrão do GDD, e
# não fica vazio: senão `precisa_dos_nomes()` voltaria a dar true no arranque
# seguinte e a tela reapareceria, contra a regra de a escolha ser irrevogável.
func definir_nomes(porto: String, jogador: String) -> void:
	nome_porto = porto.strip_edges().left(NOME_MAX_CARACTERES)
	if nome_porto == "":
		nome_porto = NOME_PORTO_PADRAO
	nome_jogador = jogador.strip_edges().left(NOME_MAX_CARACTERES)
	save_game()


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


# UM DICIONÁRIO POR DIA DA PARTIDA, com o que já se sabe de antemão sobre ele
# — é o que o calendário (toque no chip "Dia" do HUD) lê, e o teste confere
# sem abrir cena nenhuma, pela mesma razão de sempre: a conta vive uma vez só.
#
# A OFERTA DO RIVAL NÃO ENTRA AQUI. Ela é sorteada turno a turno dentro de
# `_spawn_boats()` — 30% de chance, por barco, não por dia — e um calendário
# que fingisse saber de antemão em que dia ela cai estaria a inventar uma
# certeza que o jogo não tem. Só entram os TRÊS eventos que o próprio
# calendário fixa antes de a partida começar: fecho de semana (píer e
# custos), o vencimento da parcela, e o último dia.
func calendario() -> Array:
	var dias: Array = []
	for t in range(1, TURNS_TOTAL + 1):
		dias.append({
			"turno": t,
			"semana": week_of(t),
			"hoje": t == turn,
			"passado": t < turn,
			"fecha_semana": t % TURNS_PER_WEEK == 0,
			"parcela_vence": t == PARCELA_DUE_TURN,
			"ultimo_dia": t == TURNS_TOTAL,
		})
	return dias


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


# Quantos trabalhadores estão parados e quantas docas esperam por um — nesta
# ordem, num `Vector2i`.
#
# Os dois números saem da MESMA varredura de propósito. A interface mostra os
# dois (o rótulo conta-os, o cartão do trabalhador muda de cor, o botão de
# alocar acende), e três leituras separadas do mesmo estado é convite a
# discordarem. Fora de "playing" é (0, 0): sem turno não há trabalho parado.
func trabalho_parado() -> Vector2i:
	# A fase NÃO se confere aqui, e é de propósito: `doca_aceita_trabalhador()`
	# já devolve `false` fora de "playing", então nenhuma doca conta e a
	# guarda dos zeros lá em baixo devolve (0, 0) sozinha. A primeira versão
	# repetia o `if phase != "playing"` no topo, e o defeito injetado para o
	# provar não reprovou nada — porque a outra cópia da regra o cobria. Duas
	# cópias da mesma regra é uma que pode envelhecer calada.
	var livres := 0
	for w in workers:
		if int(w["busy_turns"]) == 0 and worker_dock_index(int(w["id"])) < 0:
			livres += 1
	var esperando := 0
	for i in range(docks.size()):
		if doca_aceita_trabalhador(i):
			esperando += 1
	# Nem trabalhador parado sem doca, nem doca sem trabalhador é "trabalho
	# parado" — nos dois casos não há nada que o jogador possa fazer agora.
	if livres == 0 or esperando == 0:
		return Vector2i.ZERO
	return Vector2i(livres, esperando)


# Há trabalhador livre E doca esperando? É o que decide se o botão de alocar
# em lote fica aceso.
func has_pending_assignment() -> bool:
	return trabalho_parado() != Vector2i.ZERO


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
# Casca fina sobre `_negociar()`, e é só para emitir o sinal de observação num
# lugar em vez de em cinco. A função tem CINCO saídas ("invalido" duas vezes,
# "fechado" duas, "perdido", "insistiu") e um `emit` antes de cada `return` é
# a forma clássica de se esquecer um deles quando aparecer o sexto.
func negotiate_rival(acao: String) -> String:
	var restavam := rival_attempts_left
	var resultado := _negociar(acao)
	negociacao_resolvida.emit(acao, resultado, RIVAL_PATIENCE - restavam + 1)
	return resultado


func _negociar(acao: String) -> String:
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

	# "metade" e "manter" são apostas: gastam uma tentativa de paciência — e é
	# aqui, e só aqui, que a Reputação Comercial pesa (item A3).
	var base := RIVAL_HALF_CHANCE if acao == "metade" else RIVAL_KEEP_CHANCE
	var chance := _chance_com_reputacao(base)
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


# A Reputação Comercial entra no jogo POR AQUI (item A3 da fila, decisão em
# docs/decisoes/003). Reputação alta faz o cliente do Arlindo aceitar pagar mais
# vezes; reputação baixa faz o contrário.
#
# Por que na aposta, e não no preço do barco ou na chegada:
#   · é o único lugar onde o jogador está A DECIDIR quando o efeito acontece.
#     Preço e chegada agem pelas costas — o barco já vale mais, o barco já
#     chegou — e uma recompensa que ninguém vê não recompensa;
#   · é o que menos ameaça a economia medida. A contra-oferta dispara em 30%
#     dos turnos com barco e toca UM barco de cada vez, enquanto preço e vazão
#     multiplicam a receita inteira.
#
# A conta é ancorada em REPUTATION_START: quem começa a partida não leva bónus
# nem castigo, e a partir daí sobe ou desce com o que fizer. A âncora não é
# enfeite — ancorar noutro sítio faria a mecânica INFLAR o jogo todo em vez de
# redistribuir, e o balanceamento medido (100% / 47% / 0%) mede-se contra uma
# partida que começa neutra.
#
# O teto de 0.95 existe para "manter o preço" nunca virar jogada automática:
# com reputação máxima a aposta fica boa, não fica garantida.
func _chance_com_reputacao(base: float) -> float:
	var acima := (reputation - REPUTATION_START) / (100.0 - REPUTATION_START)
	return clampf(base * (1.0 + REPUTACAO_EFEITO_NEGOCIACAO * acima), 0.0, 0.95)


# Compat com a versão binária (usada pela suíte de testes de regressão).
func resolve_rival_offer(accept_match: bool) -> void:
	if accept_match:
		negotiate_rival("igualar")
	elif phase == "rival_offer" and pending_rival_dock >= 0:
		var restavam := rival_attempts_left
		_perder_para_rival()
		# Este caminho NÃO passa por `negotiate_rival()`, então emite o seu
		# próprio: um registro em que a oferta abre e nunca fecha leria como
		# jogador que fugiu do painel, que é uma conclusão errada.
		negociacao_resolvida.emit("recusar", "perdido", RIVAL_PATIENCE - restavam + 1)


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
				# Observação para o Boletim, e nada mais: o valor que entra no
				# caixa é o mesmo nas duas chamadas. Elas separam o bruto do
				# bónus da estrutura, para o boletim ter as linhas próprias que
				# o arquivo de escrita pede.
				var value := _lancar_receita(dia_atual, bruto, String(boat["motivo"]))
				_lancar_receita(semana_atual, bruto, String(boat["motivo"]))
				cash += value
				metrics["revenue"] += value
				dia_atual["servidos"] += 1
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
			dia_atual["perdidos"] += 1
			_change_reputation(-REPUTATION_LOSS_LOST)
			dock["boat"] = null

	var prev_turn := turn
	turn += 1
	cash_changed.emit(cash)

	if prev_turn % TURNS_PER_WEEK == 0:
		_process_week_end(week_of(prev_turn))

	# A VIRADA DO DIA vem DEPOIS do fecho de semana e ANTES do corte por dívida
	# — o dia que fechou já tem os números completos (pier/salários/manutenção
	# inclusive, se foi dia de fechar semana) antes de ir para `dia_anterior`.
	# Se a dívida vencer HOJE, `pay_debt()` ainda escreve na parcela DESTE
	# dia (`dia_anterior`), porque `advance_turn()` já devolveu por aqui e o
	# turno seguinte só começa depois de o jogador decidir.
	dia_atual["turno"] = prev_turn
	dia_anterior = dia_atual.duplicate()
	dia_atual = DIA_ZERADO.duplicate()

	if prev_turn == PARCELA_DUE_TURN and not parcela_paid:
		_set_phase("debt_payment")
		debt_due.emit(PARCELA_AMOUNT)
		save_game()
		return

	turn_advanced.emit(turn, current_week())
	_check_end()
	save_game()


# Píer e salários dependem só das estruturas e do roster — nada aqui muda
# turno a turno. Existe em separado porque `_process_week_end()` PRECISA
# destes números para mexer no caixa, e `projecao_do_dia()` precisa dos MESMOS
# números para os mostrar sem mexer em nada — duas contas de olho no mesmo
# resultado são convite a divergirem, e já divergiram noutro sítio deste
# arquivo (o `.get("preco", 0)` do Registro).
func _custos_da_semana() -> Dictionary:
	# Pátio pavimentado: mais vagas de píer alugáveis. Escritório reformado:
	# menos manutenção porque a administração deixa de ser improvisada.
	var pier_income := PIER_SLOTS * PIER_RATE_PER_SLOT
	if tem_estrutura("patio"):
		pier_income = int(round(pier_income * (1.0 + PATIO_BONUS_PIER)))
	var salarios := SALARY_PER_WORKER * workers.size()
	if tem_estrutura("escritorio"):
		salarios = int(round(salarios * (1.0 - ESCRITORIO_DESCONTO_SALARIO)))
	return {"pier": pier_income, "salarios": salarios, "manutencao": MAINTENANCE_WEEKLY}


func _process_week_end(ended_week: int) -> void:
	var custos := _custos_da_semana()
	var pier_income: int = int(custos["pier"])
	var salarios: int = int(custos["salarios"])
	var cost := salarios + int(custos["manutencao"])
	cash += pier_income
	cash -= cost
	metrics["pier_income"] = int(metrics.get("pier_income", 0)) + pier_income
	cash_changed.emit(cash)
	message.emit("Semana %d encerrada — +%s do aluguel do píer, -%s em custos (salários + manutenção)." % [ended_week, moeda(pier_income), moeda(cost)], "warn")

	# O resumo sai DEPOIS de tudo estar contado e ANTES de a semana zerar. A
	# média das anteriores vai no resumo em vez de ser recalculada por quem o
	# recebe: assim a Dona Cida e um teste leem o mesmo número, e ninguém tem
	# de saber que a média exclui a semana que acabou.
	semana_atual["pier"] = pier_income
	semana_atual["salarios"] = salarios
	semana_atual["manutencao"] = int(custos["manutencao"])
	dia_atual["pier"] = pier_income
	dia_atual["salarios"] = salarios
	dia_atual["manutencao"] = int(custos["manutencao"])
	var resumo := resumo_da_semana(ended_week)
	historico_semanas.append(int(resumo["resultado"]))
	semana_atual = SEMANA_ZERADA.duplicate()
	semana_fechada.emit(resumo)


# Fecha as contas da semana em curso num dicionário só. Vive aqui, e não no
# painel, porque o teste precisa de fazer a mesma conta sem abrir cena — e duas
# versões da mesma conta divergem, como já divergiram os números do GDD e os
# das constantes.
func resumo_da_semana(semana: int) -> Dictionary:
	var receita: int = int(semana_atual["docagens"]) + int(semana_atual["armazem"]) \
		+ int(semana_atual["patio"]) + int(semana_atual["pier"])
	var despesa: int = int(semana_atual["salarios"]) + int(semana_atual["manutencao"]) \
		+ int(semana_atual["parcela"])
	var media := 0.0
	for r in historico_semanas:
		media += float(r)
	if historico_semanas.size() > 0:
		media /= float(historico_semanas.size())
	return {
		"semana": semana,
		"docagens": int(semana_atual["docagens"]),
		"armazem": int(semana_atual["armazem"]),
		"patio": int(semana_atual["patio"]),
		"pier": int(semana_atual["pier"]),
		"salarios": int(semana_atual["salarios"]),
		"manutencao": int(semana_atual["manutencao"]),
		"parcela": int(semana_atual["parcela"]),
		"receita": receita,
		"despesa": despesa,
		"resultado": receita - despesa,
		"media_anterior": media,
		"tem_historico": historico_semanas.size() > 0,
		# A semana ANTERIOR, separada da média: o boletim mostra a comparação
		# com ela ("semana anterior: X"), enquanto o tom da Dona Cida sai da
		# média. São duas leituras diferentes do mesmo histórico e confundi-las
		# faria a fala dela discordar do número logo acima dela.
		"anterior": int(historico_semanas.back()) if historico_semanas.size() > 0 else 0,
	}


# O que ACONTECEU ontem, mais o que ACONTECERIA hoje se o jogador avançasse o
# dia agora — o par que o toque no dinheiro do HUD mostra. Existe porque o
# playtest pediu exatamente isto: "toque no dinheiro → resumo do ganho de
# ontem e o projetado para hoje".
#
# "Ontem" é `dia_anterior`, lido sem tocar em nada. "Hoje" não pode ser lido
# do mesmo jeito — o dia em curso ainda não aconteceu, `dia_atual` está vazio
# até o jogador avançar — então ele é uma SIMULAÇÃO do que `advance_turn()`
# faria: por doca, o barco que completaria hoje entra como servido; o que não
# tem trabalhador entra como perdido. Nenhuma das duas contas MEXE em nada —
# nem em `cash`, nem em `dia_atual`, nem em doca nenhuma.
func resumo_do_dia() -> Dictionary:
	return {"ontem": dia_anterior.duplicate(), "hoje": projecao_do_dia()}


func projecao_do_dia() -> Dictionary:
	var proj: Dictionary = DIA_ZERADO.duplicate()
	proj["turno"] = turn
	if phase != "playing":
		return proj
	for i in range(docks.size()):
		var doca: Dictionary = docks[i]
		var barco = doca["boat"]
		if barco == null:
			continue
		if doca["worker_id"] == null:
			proj["perdidos"] += 1
			continue
		if int(barco["progress"]) + 1 < int(barco["op_turns"]):
			continue
		var bruto: int = int(barco["matched_value"]) if barco.get("matched", false) else int(barco["value"])
		_lancar_receita(proj, bruto, String(barco["motivo"]))
		proj["servidos"] += 1
	# O fecho de semana e a parcela caem no MESMO dia que fariam cair no jogo
	# real — usar `_custos_da_semana()` em vez de repetir a conta é a mesma
	# razão que fez ela existir: uma só fonte para o número que o caixa muda
	# e o número que a projeção mostra.
	if turn % TURNS_PER_WEEK == 0:
		var custos := _custos_da_semana()
		proj["pier"] = int(custos["pier"])
		proj["salarios"] = int(custos["salarios"])
		proj["manutencao"] = int(custos["manutencao"])
	if turn == PARCELA_DUE_TURN and not parcela_paid:
		proj["parcela"] = PARCELA_AMOUNT
	return proj


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
#
# DUAS PORTAS PARA A MESMA DÍVIDA, e uma só função a baixá-la. `pay_debt()` é
# a porta do vencimento (fase "debt_payment", turno parado à espera da
# decisão); `pagar_parcela_adiantado()` é a porta que o playtest pediu — pagar
# antes do prazo, a qualquer momento em que o caixa dê. O dinheiro sai igual
# nas duas, e é por isso que sai de um lugar só: duas cópias desta conta
# divergiriam no dia em que uma delas ganhasse uma linha nova.
func pay_debt() -> void:
	if phase != "debt_payment":
		return
	if cash < PARCELA_AMOUNT:
		message.emit("Caixa insuficiente para pagar a parcela.", "bad")
		return
	# `advance_turn()` já fez a virada do dia antes de suspender em
	# "debt_payment", então o dia em que a dívida venceu é `dia_anterior` —
	# não `dia_atual`, que já é o dia seguinte, ainda por jogar.
	_baixar_parcela(dia_anterior)
	_set_phase("playing")
	turn_advanced.emit(turn, current_week())
	_check_end()
	save_game()


# Pagar ANTES do prazo — item do primeiro playtest ("pode haver a opção de
# pagar a dívida antes do tempo").
#
# O VALOR É O MESMO, e de propósito: desconto por antecipação mexeria na
# economia medida (100% / 79,5% / 31,0%) e isso não se faz sem passar pelo
# `/balancear`. O que se ganha aqui não é dinheiro — é deixar de carregar a
# dívida e o lembrete dela pelo resto da partida, e é uma escolha, porque o
# mesmo caixa também compra estrutura.
#
# O simulador de balanceamento NUNCA passa por aqui (ele só resolve a fase
# "debt_payment"), então a medição em vigor continua a descrever exatamente o
# que descrevia: a partida que paga no vencimento.
func pode_pagar_parcela_adiantado() -> bool:
	return phase == "playing" and not parcela_paid and cash >= PARCELA_AMOUNT


func pagar_parcela_adiantado() -> bool:
	if not pode_pagar_parcela_adiantado():
		return false
	# Aqui é o INVERSO do `pay_debt()`: o dia em curso ainda não foi jogado,
	# então a parcela cai em `dia_atual` — que vira `dia_anterior` na próxima
	# virada, e é lá que o resumo do dia a vai mostrar.
	_baixar_parcela(dia_atual)
	roster_changed.emit()
	save_game()
	return true


func _baixar_parcela(no_dia: Dictionary) -> void:
	cash -= PARCELA_AMOUNT
	# Só para o Boletim. A parcela vence NO fecho da semana 4, então cai na
	# semana em curso — que é onde o jogador espera vê-la, porque foi essa a
	# semana em que o dinheiro saiu.
	semana_atual["parcela"] += PARCELA_AMOUNT
	no_dia["parcela"] += PARCELA_AMOUNT
	parcela_paid = true
	cash_changed.emit(cash)
	message.emit("Parcela de %s paga ao Sr. Ribeiro." % moeda(PARCELA_AMOUNT), "good")


func fail_debt() -> void:
	_end_game(false, "Não foi possível pagar a parcela ao Sr. Ribeiro. Porto perdido.")


# ── UPGRADE (ampliar píer) ──
func tem_estrutura(id: String) -> bool:
	return estruturas.has(id)


## O NÍVEL DO PORTO, de 1 a 3 — quanto dele já foi levantado.
##
## É uma leitura DERIVADA e mais nada: não decide, não guarda estado próprio e
## não tem constante de balanceamento nenhuma. Existe porque o GDD 7 decidiu
## que "estruturas principais (grua, cais, armazém) têm upgrade in-place de até
## 3 níveis", e a ARTE desses níveis já existe (`pier_n1..n3`, `lanca_n1..n3`).
## A MECÂNICA do upgrade é da Fase 2 e não está feita — quando estiver, ela
## substitui esta função e nada mais precisa de mudar.
##
## ⚠️ E É POR ISSO QUE ELA NÃO É UM CAMPO NEM UMA FASE. O `advance_turn()`
## retorna calado fora de `"playing"` e o simulador de balanceamento só sabe
## resolver duas fases; qualquer estado novo aqui apareceria como partida que
## não termina. Ler estrutura comprada em vez de criar fase deixa o motor do
## turno intocado — os upgrades mexeram no balanceamento pelo CUSTO deles, que
## é o que se mede, e não por um estado novo que o simulador não saiba resolver.
## intocados por construção.
## ⚠️ SÃO DUAS LEITURAS DESDE QUE OS UPGRADES EXISTEM, e não uma.
## Enquanto o nível era derivado da contagem, píer e guindaste subiam juntos
## porque nada os separava. Agora cada um tem o seu upgrade, e comprar o
## guindaste não pode engrossar a laje do píer — o jogador veria mudar o que
## não comprou. `nivel_porto()` saiu; quem chamava era o `Dock.gd`.
func nivel_pier() -> int:
	if tem_estrutura("cais"):
		return 3
	return 2 if estruturas.size() >= 2 else 1


func nivel_guindaste() -> int:
	if tem_estrutura("guindaste"):
		return 3
	return 2 if estruturas.size() >= 2 else 1


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
	# nos lugares onde o dinheiro é contado (ver _lancar_receita e
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
	estrutura_comprada.emit(id)
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
# Lança a receita de UM barco servido num dos dicionários de contabilidade e
# devolve o que entra no caixa. O bruto vai na linha das docagens; o bónus do
# motivo vai na linha da ESTRUTURA que o pagou — e a linha chama-se como a
# estrutura de propósito, para não haver um segundo mapa a dizer qual é qual.
#
# É uma função só porque `advance_turn()` e `projecao_do_dia()` precisam do
# MESMO número: uma paga e a outra mostra o que se pagaria, e duas cópias desta
# conta divergiriam calado — foi o que já aconteceu com `_custos_da_semana()`.
func _lancar_receita(destino: Dictionary, bruto: int, motivo: String) -> int:
	var dados: Dictionary = MOTIVOS[motivo]   # direto: motivo desconhecido tem de rebentar
	destino["docagens"] += bruto
	var estrutura: String = dados["estrutura"]
	var bonus: float = dados["bonus"]
	if estrutura == "" or bonus <= 0.0 or not tem_estrutura(estrutura):
		return bruto
	var extra := int(round(bruto * bonus))
	destino[estrutura] += extra
	return bruto + extra


# ── GERAÇÃO DE BARCOS ──
# Sorteia o motivo pelos pesos da coluna do tamanho. O sorteio é por PESO e
# não por faixa escrita à mão porque a mistura tem de se ler na tabela: quem
# quiser saber com que frequência aparece um granel lê 25 na coluna, sem
# reconstruir intervalos de cabeça.
func _sortear_motivo(grande: bool) -> String:
	var coluna := "peso_grande" if grande else "peso_pequeno"
	var total := 0
	for id in MOTIVOS:
		total += int(MOTIVOS[id][coluna])
	var sorteio := _rng.randi_range(1, total)
	var acumulado := 0
	for id in MOTIVOS:
		acumulado += int(MOTIVOS[id][coluna])
		if sorteio <= acumulado:
			return id
	# Inalcançável: o sorteio vai de 1 a `total`, que é a soma dos pesos. Está
	# aqui porque o GDScript exige retorno em todo caminho, e devolver a base é
	# o único valor que não inventa dinheiro nem turno se algum dia chegar cá.
	return "pescado"


# Quantos turnos uma operação leva: o tamanho do barco, mais o que o motivo
# pesar, menos o que o pórtico corta. Nunca abaixo de um — barco que
# descarregasse em zero turnos entraria e sairia no mesmo avanço de dia, sem
# o jogador ter o que fazer.
func _turnos_de_operacao(grande: bool, motivo: String) -> int:
	var turnos := (2 if grande else 1) + int(MOTIVOS[motivo]["turnos_extra"])
	if tem_estrutura("guindaste"):
		turnos -= GUINDASTE_CORTA_TURNOS
	return maxi(1, turnos)


func _make_boat() -> Dictionary:
	# O cais reforçado aumenta a chance de navio grande. `min` porque um
	# multiplicador sem teto passaria de 1,0 e o porto deixaria de ver pesqueiro.
	var chance_grande: float = BOAT_LARGE_CHANCE
	if tem_estrutura("cais"):
		chance_grande = min(1.0, chance_grande * CAIS_CHANCE_GRANDE)
	var large := _rng.randf() < chance_grande
	var value: int
	if large:
		value = _rng.randi_range(BOAT_VALUE_LARGE_MIN, BOAT_VALUE_LARGE_MAX)
	else:
		value = _rng.randi_range(BOAT_VALUE_SMALL_MIN, BOAT_VALUE_SMALL_MAX)
	var motivo := _sortear_motivo(large)
	_uid += 1
	return {
		"id": _uid,
		"value": value,
		"motivo": motivo,
		"op_turns": _turnos_de_operacao(large, motivo),
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
		"nome_porto": nome_porto,
		"nome_jogador": nome_jogador,
		"semana_atual": semana_atual,
		"historico_semanas": historico_semanas,
		"dia_atual": dia_atual,
		"dia_anterior": dia_anterior,
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
		clear_save()
		return false

	# TUDO O QUE RECUSA VEM ANTES DE TUDO O QUE ESCREVE, e é de propósito.
	#
	# Save de outra versão do jogo é descartado, não adaptado. Migrar exigiria
	# adivinhar o que o jogador tinha comprado a partir de números que já não
	# querem dizer a mesma coisa — foi assim que apareceu o porto de 4 docas
	# num mapa de 3. Recomeçar é honesto; carregar um estado impossível não é.
	#
	# Só que "não adaptar" também vale para a recusa: enquanto os campos eram
	# escritos um a um e a sanidade do roster era conferida DEPOIS, um save
	# recusado deixava `turn` e `cash` do arquivo no estado vivo e o porto com
	# zero docas. Isso passava despercebido porque o `_ready()` chama
	# `new_game()` logo a seguir e ele por acaso reescreve todos os campos —
	# uma segurança que dependia de duas funções distantes continuarem a
	# concordar sobre a lista de campos. Bastava um campo novo no save que o
	# `new_game()` não zerasse para o estado impossível atravessar para a
	# partida seguinte: o bug das 4 docas outra vez, com outra roupa.
	# `tests/teste_fumaca.gd`, bloco F3, tranca isto.
	if int(parsed.get("versao", 1)) != SAVE_VERSION:
		clear_save()
		return false

	# O roster é lido do dicionário, não dos campos do jogo, justamente para
	# poder recusar sem ter tocado em nada. Porto sem doca ou sem trabalhador é
	# um estado que nenhuma partida produz — é arquivo truncado ou editado.
	var docas_lidas = parsed.get("docks", [])
	var trabalhadores_lidos = parsed.get("workers", [])
	if typeof(docas_lidas) != TYPE_ARRAY or typeof(trabalhadores_lidos) != TYPE_ARRAY \
			or docas_lidas.is_empty() or trabalhadores_lidos.is_empty():
		clear_save()
		return false

	turn = int(parsed.get("turn", 1))
	cash = int(parsed.get("cash", START_CASH))
	reputation = float(parsed.get("reputation", REPUTATION_START))
	docks = docas_lidas
	workers = trabalhadores_lidos
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
	nome_porto = String(parsed.get("nome_porto", ""))
	nome_jogador = String(parsed.get("nome_jogador", ""))
	# O JSON devolve números como float. Sem reconverter, o boletim mostraria
	# "R$1250.0" — e `moeda()` recebe int, então nem chegaria a mostrar.
	semana_atual = SEMANA_ZERADA.duplicate()
	var lida = parsed.get("semana_atual", {})
	if typeof(lida) == TYPE_DICTIONARY:
		for chave in SEMANA_ZERADA:
			semana_atual[chave] = int(lida.get(chave, 0))
	historico_semanas = []
	var hist = parsed.get("historico_semanas", [])
	if typeof(hist) == TYPE_ARRAY:
		for r in hist:
			historico_semanas.append(int(r))
	dia_atual = DIA_ZERADO.duplicate()
	var lido_atual = parsed.get("dia_atual", {})
	if typeof(lido_atual) == TYPE_DICTIONARY:
		for chave in DIA_ZERADO:
			dia_atual[chave] = int(lido_atual.get(chave, 0))
	dia_anterior = DIA_ZERADO.duplicate()
	var lido_anterior = parsed.get("dia_anterior", {})
	if typeof(lido_anterior) == TYPE_DICTIONARY:
		for chave in DIA_ZERADO:
			dia_anterior[chave] = int(lido_anterior.get(chave, 0))

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
