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
# Compra paga a obra; conclusão libera a estrutura e a reação da Dona Cida.
signal obra_concluida(id: String)
# O índice é o da FILA, não o de uma doca (`083`): o Arlindo disputa o barco
# que acabou de chegar ao fundeadouro, antes de o jogador o escolher.
signal rival_offer_triggered(indice_fila: int)
# A fila no fundeadouro mudou — chegou, atracou, voltou, desistiu ou foi para
# o rival. Separado de `roster_changed` porque a fila muda também na virada do
# dia, quando ninguém mexeu em doca nem em trabalhador.
signal fila_mudou()
# O jogador escolheu um barco da fila: em que doca entrou, qual, e os valores
# do que estava ao largo nesse instante. Sinal de OBSERVAÇÃO — quem o escuta é
# o `Registro.gd`: é a escolha que a `083` criou, e um playtest que não a
# gravasse não saberia dizer se o jogador chama o mais caro, o que sai amanhã
# ou o primeiro da fila.
signal atracou(doca: int, barco: Dictionary, valores_ao_largo: Array)
signal debt_due(amount: int)
# O jogador aceitou a segunda chance do Sr. Ribeiro (`102`): quanto entrou e
# quanto volta com a cobrança seguinte. Sinal de OBSERVAÇÃO, para o
# `Registro.gd` — é a escolha que só o playtest diz se alguém faz.
signal segunda_chance_aceita(emprestado: int, devolver: int)
signal game_over(won: bool, reason: String)
# A fase `numero` fechou e a partida SEGUE na seguinte (`104`): as três
# quitações da Fase 1 deixaram de ser `game_over`. O `motivo` é a frase do
# balanço, a mesma que o fim de jogo levava. Quem o escuta é o `Main`, que abre
# a página do diário por cima do jogo — o turno não espera por ela: tela nova é
# overlay, nunca estado do turno (`interface.md`), e o simulador não a abre.
signal fase_concluida(numero: int, motivo: String)
# ⚠️ O TERCEIRO ARGUMENTO É O ASSUNTO (`docs/decisoes/067`): de que fala o aviso
# — trabalhador, doca, rival, cliente, negocio, semana, dinheiro, obra. Quem o sabe é
# QUEM EMITE, e por isso ele nasce aqui e não se adivinha do texto depois: a
# conversa do celular põe o ícone do assunto em cada nota do porto, e ler
# «trabalhador» dentro de uma frase seria a mesma aposta frágil que o F9
# recusa para as contagens. O F17 do fumaça confere que todo assunto emitido
# tem ícone.
signal message(text: String, kind: String, assunto: String)
signal state_loaded()
signal meta_atualizada()
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

# UM CONTRATO FECHOU, e por quanto. Existe para a faixa de mensagem poder
# reagir ao TAMANHO do negócio — a Dona Cida tinha a fala escrita desde 01/09 e
# nada a disparava, porque nenhum sinal dizia o valor. Carrega a classe junto
# para quem ouve poder comparar com a faixa dela em vez de com um número solto.
signal contrato_fechado(valor: int, classe: String)
signal gerenciamento_solicitado(doca: int, id: int)
signal servico_cancelado(evento: Dictionary)

# Candidato da bancada 110, aceite pelo Bruno na 111. A multa não inclui bônus.
const CANCELAMENTO_REPUTACAO := 5.0 # TUNING: custo medido na 110 e aceite na 111
const CANCELAMENTO_MULTA := 0.10    # TUNING: fração do acordo, sem bônus, medida na 110

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
# TUNING — medido, não estimado, com 600 partidas por perfil em
# tools/simular_balanceamento.gd. Mexer aqui SEM rodar o simulador quebra isso.
#
# ⚠️ AS TAXAS MEDIDAS NÃO SE REPETEM AQUI, e é decisão de 18/09 (docs/decisoes/
# 032): elas viviam em cinco sítios e três deles envelheceram caladinhos, com
# o resumo semanal do CI a publicar um número que já não era medido havia
# duas semanas. Hoje o endereço é UM — o CLAUDE.md, secção "Antes de fechar" —
# e `tools/conferir_docs.py` reprova o segundo que aparecer.
#
# O ALVO MUDOU, e é decisão registrada (docs/decisoes/005): o jogo é TRANQUILO.
# Os 47% do jogador mediano eram a fantasia de sobrevivência que essa decisão
# substituiu — a dívida deixou de ser o motor, e quem discrimina os jogadores
# passou a ser o PORTO QUE ELES CONSEGUEM LEVANTAR, não se pagam a parcela.
#
# ⚠️ E DESDE A TRAVA DE 06/09 QUEM MEDE ISSO É A MARGEM, NÃO A CONTAGEM DE
# BARCOS (`docs/decisoes/009`): o porto pobre só recebe pesqueiro, que
# descarrega num turno. Na base da fila (`083`) a margem era R$538.184
# contra R$94.955 — 5,7× —, e os barcos atendidos 55,1 contra 18,6, só 3×: a
# contagem conta outra história. A manutenção alta é o que faz essa diferença doer, porque
# custo fixo pesa proporcionalmente muito mais em quem tem pouca vazão.
# Frente 5 (`085`): Bruno recuperou a escala anterior à `084`, para manter
# coerência com expansões e futuros bens pessoais: caixa R$400 mil e preços
# na moeda anterior. Depois substituiu a dívida por capital mais juros em
# três parcelas menores e iguais. São valores de jogo, não uma tabela
# auditada de tarifas ou salários. O método está no guia de economia.
const ESCALA_MONETARIA_GDD := 1.0
const START_CASH := 400000
const SALARY_PER_WORKER := 6000          # TUNING sobre a linha "Margem operacional base" do GDD, reescalada
const MAINTENANCE_WEEKLY := 40000        # TUNING sobre a mesma linha do GDD — o custo fixo que separa os perfis
# O porto ABRE PARADO. Um píer de pé, o resto em ruína — é o que a herança do
# avô do GDD descreve, e é a diferença entre "administrar um porto" e "levantar
# um porto", que é a fantasia do jogo.
const DOCKS_BASE := 1
const WORKERS_BASE := 1
# O que cada píer reconstruído traz. O nome vem de quando o porto tinha UMA
# compra só, «ampliar o píer»; a compra saiu na `104` (M9), e o que ela trazia
# é o que cada píer traz até hoje.
const UPGRADE_EXTRA_DOCKS := 1
const UPGRADE_EXTRA_WORKERS := 1

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
	# A treliça chega na Fase 2 (`103`). Compra o nível intermediário que
	# antes só a bancada montava; não corta dias como o pórtico.
	# TUNING: preço mantido após a varredura da meta completa (`108`).
	# O píer 2 com ela dá os dois reparos do nível 2.
	"trelica": {
		"nome": "Guindaste de treliça",
		"desc": "o cargueiro passa a atracar",
		"custo": 80000, "ordem": 6, "requer": "pier_2",
	},
	# ── OS UPGRADES DO NÍVEL 3 ──
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
		"custo": 120000, "ordem": 7, "requer": "pier_2",
	},
	# ⚠️ O CAIS DEIXOU DE SER UM MULTIPLICADOR EM 06/09. Ele dava "+60% de
	# chance de navio grande" — um efeito estatístico que ninguém vê acontecer,
	# e que punha um cargueiro de R$70.000 a atracar num píer de ripas de
	# madeira desde o primeiro dia. Agora ele DESTRAVA a classe de longo curso,
	# que se lê na primeira vez que ela chega (`CLASSES_DE_NAVIO`).
	"cais": {
		"nome": "Reforçar o cais",
		"desc": "o navio de longo curso passa a atracar",
		"custo": 150000, "ordem": 8, "requer": "guindaste",
	},
}

# O guindaste de pórtico corta o tempo de operação. É o único que mexe
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
# ⚠️ OS PESOS DE SORTEIO NÃO ESTÃO AQUI, e é de propósito: eles vivem em
# `CLASSES_DE_NAVIO`, porque a pergunta que o jogo faz é "que carga traz ESTE
# navio". Até 06/09 eram duas colunas aqui dentro (`peso_pequeno` e
# `peso_grande`); com três classes seriam três, e a cada classe nova uma coluna
# a mais numa tabela que não é sobre navios.
const MOTIVOS := {
	"pescado": {
		"nome": "Pescado", "estrutura": "", "bonus": 0.0, "turnos_extra": 0,
	},
	"armazenagem": {
		"nome": "Armazenagem", "estrutura": "armazem", "bonus": ARMAZEM_BONUS,
		"turnos_extra": 0,
	},
	"conteiner": {
		"nome": "Contêiner", "estrutura": "patio", "bonus": PATIO_BONUS_CARGA,
		"turnos_extra": 0,
	},
	# O granel é o único que paga em TURNO em vez de em dinheiro, e de
	# propósito: quatro motivos que fossem quatro multiplicadores seriam o
	# mesmo motivo quatro vezes. Sem pórtico ele ocupa o berço um turno a mais,
	# que é o custo que o guindaste existe para pagar.
	"granel": {
		"nome": "Granel", "estrutura": "guindaste", "bonus": 0.0,
		"turnos_extra": 1,
	},
}

const PIER_SLOTS := 6                   # GDD "Margem operacional base": 6 vagas de píer
const PIER_RATE_PER_SLOT := 5000        # GDD "Margem operacional base", reescalado: renda fixa semanal

# ── AS TRÊS CLASSES DE NAVIO ──
#
# QUE NAVIO O PORTO CONSEGUE RECEBER. Até 06/09 era um booleano `large` com
# 40% de chance, e o cais reforçado multiplicava essa chance — o que punha um
# cargueiro de R$70.000 a atracar num píer de ripas de madeira com um
# pau-de-carga ao lado. A queixa foi essa, e tem razão: o porto em ruínas não
# tem onde encostar um navio daqueles.
#
# ⚠️ A TRAVA É O NÍVEL, E O NÍVEL JÁ ESTÁ DESENHADO NA TELA. `nivel_pier()` e
# `nivel_guindaste()` existem desde 05/09 porque a ARTE do píer e da lança tem
# três estados; agora eles decidem também quem atraca. É a razão de a trava não
# ser estado invisível: o jogador vê o píer virar concreto e a lança virar
# pórtico, e é exatamente aí que o navio maior aparece.
#
# ⚠️ E O `CAIS_CHANCE_GRANDE` SAIU. O cais era "+60% de chance de navio grande"
# — um efeito estatístico que ninguém consegue ver acontecer. Agora é o que
# DESTRAVA a classe grande, que se lê na primeira vez que ela chega.
#
# `nivel` é o do PORTO, que é o menor dos dois (píer e guindaste): não adianta
# ter onde encostar sem ter com que descarregar, nem o contrário.
#
# `turnos` é a operação SEM pórtico. Ele corta um (`GUINDASTE_CORTA_TURNOS`),
# e o grande está desenhado à volta disso: os 3 turnos dele nunca se jogam,
# porque a classe só existe no nível 3 e o nível 3 exige o pórtico. Quem lê 3
# aqui está a ler o navio, não o que o porto faz com ele.
#
# `motivos` são os pesos de sorteio DENTRO da classe, e somam 100 em cada uma.
# Vivem aqui e não em `MOTIVOS` porque a pergunta é "que carga traz este
# navio?" e não "que navio traz esta carga" — um pesqueiro não traz contêiner,
# e escrever isso do lado do motivo obrigava a uma coluna por classe.
#
# ⚠️ AS FAIXAS DE VALOR DESCERAM ×0,72 COM A FILA (`083`), escolha do Bruno
# («contratos mais baratos»). Com o barco a esperar ao largo o berço deixou de
# ficar vazio — 1% dos dias, contra 25% quando o barco nascia na doca — e a
# receita subiu um terço: o Mediano chegou a 100%. Varrido com 600 partidas:
# ×0,70 dá 100 / 65,3 / 32,7, ×0,72 dá 100 / 78,7 / 41,5, ×0,74 dá
# 100 / 86,5 / 49,3. Era 12–28 / 22–50 / 56–88 mil. Arredondadas ao milhar.
# `085`: após restaurar a moeda e trocar a dívida pelo crédito de R$400 mil,
# o arco de doze semanas acumulava caixa demais. Medidos retornos ×0,60 e
# ×0,45, escolheu-se ×0,45 com faixas arredondadas; custos de reparo intactos.
# Contratos agregados ficcionais, não tarifas por tonelada (guia de economia).
const CLASSES_DE_NAVIO := {
	"pesqueiro": {
		"nome": "Pesqueiro", "nivel": 1, "peso": 40, "turnos": 1,
		"valor_min": 4000, "valor_max": 9000,          # TUNING (`085`)
		"motivos": {"pescado": 55, "armazenagem": 45},
	},
	"medio": {
		"nome": "Cargueiro", "nivel": 2, "peso": 40, "turnos": 2,
		"valor_min": 7000, "valor_max": 16000,         # TUNING (`085`)
		"motivos": {"armazenagem": 40, "conteiner": 40, "granel": 20},
	},
	"grande": {
		"nome": "Navio de longo curso", "nivel": 3, "peso": 20, "turnos": 3,
		"valor_min": 18000, "valor_max": 28000,         # TUNING (`085`)
		"motivos": {"armazenagem": 25, "conteiner": 45, "granel": 30},
	},
}

# ── A FILA NO FUNDEADOURO (`docs/decisoes/083`) ──
#
# O barco já não nasce na doca: chega ao LARGO e espera lá, e é o jogador quem
# escolhe qual entra no berço livre. Até 04/10 o número de trabalhadores era
# sempre o de docas (cada píer traz o seu) e o «Alocar todos» acertava sempre —
# o verbo central do jogo não pedia escolha nenhuma, e o simulador só sabia
# modelar o mau jogador como DISTRAÍDO. É o «Prioridade de doca» do GDD: «qual
# navio entra primeiro quando há fila? O jogador decide.»
#
# Três lugares porque é o que a linha «Ao largo» do HUD mostra sem rolar, e o
# que a Zona de Espera do mapa desenha.
const FILA_LUGARES := 3
# Quantas viradas de dia um barco aguenta ao largo. Com 2, ele chega na virada,
# fica «aguarda mais 1 dia» no dia seguinte e «vai embora hoje» no outro —
# duas chances de o escolher, e a segunda já é a última.
const PACIENCIA_FILA := 2               # TUNING
# Chance POR LUGAR VAZIO DA FILA de chegar barco na virada. Por lugar e não por
# doca: a fila tem de ter mais barcos do que berços livres em boa parte dos
# dias, senão volta a não haver escolha — atracava-se tudo o que chegasse.
const BOAT_ARRIVAL_CHANCE := 0.75       # TUNING

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
# vez de estourar no início. Onde ela começa é da fase — `reputacao_inicial`,
# na tabela `FASES` (`094`).
const REPUTATION_GAIN_SERVED := 0.8
const REPUTATION_LOSS_LOST := 2.5
const REPUTATION_GAIN_RIVAL_MATCHED := 1.0
const REPUTATION_LOSS_RIVAL_REFUSED := 8.0

# ── CADÊNCIA ──
# TUNING (`085`) — a semana tem sete dias, e é a do calendário inteiro, não a
# de uma fase: o que muda de uma fase para a outra é QUANTAS semanas ela dura,
# e isso vive na tabela `FASES`, logo abaixo (`094`).
const TURNS_PER_WEEK := 7

# ── AS FASES ──
#
# O QUE MUDA DE UMA FASE PARA A OUTRA, EM DADOS (`docs/decisoes/094`). Até
# 11/10 a Fase 1 vivia em constantes soltas — `WEEKS_TOTAL`, `TURNS_TOTAL`, os
# três `PARCELA_*_AMOUNT` e os três `JUROS_PARCELA_*`, `PARCELA_DUE_TURN`,
# `PARCELAS_NA_FASE`, `DIAS_DAS_OBRAS`, `BERCOS_NO_MAPA`, `REPUTATION_START` —
# e a abertura de cada reparo num `match`. A Fase 2 teria de as duplicar com
# um sufixo, ou de as trocar à mão nos duzentos sítios que as liam; aqui ela é
# uma segunda linha. Cada número é o que a constante dizia, e a mudança
# provou-o: a tabela dos números, o JSON do simulador e a bateria de capturas
# saíram iguais.
#
# ⚠️ QUEM LÊ UM NÚMERO DA FASE PASSA PELAS FUNÇÕES DE «A FASE EM JOGO», NUNCA
# POR `FASES[0]`. O número da fase em jogo está no save desde a 16
# (`numero_da_fase`, `104`), e `dados_da_fase()` é o único sítio que o lê. É
# também por isso que as constantes antigas SAÍRAM em vez de ficarem como
# apelido: uma constante com o valor da Fase 1 continuaria a dizê-lo na Fase 2,
# sem erro nenhum.
#
# Os campos, todos obrigatórios — o F20 do `teste_fumaca` recusa o que falte e
# o que sobre, e confere as afirmações que nenhuma regra do jogo lê:
# - `semanas`: quanto a fase dura. Os dias são `semanas × TURNS_PER_WEEK`, e a
#   fase seguinte abre no dia a seguir ao último. `null` é a fase SEM PRAZO
#   (`103`): não acaba por calendário, e quem lhe pedir a duração rebenta —
#   `int(null)` é erro de script —, em vez de receber um zero que se leria
#   como «acabou ontem». Pergunta-se antes pelo `fase_tem_prazo()`. Só a
#   última fase da tabela pode não ter prazo: a seguinte abriria num dia que
#   não existe.
# - `parcelas`: as cobranças do Sr. Ribeiro, por ordem. `semana` é a que ela
#   fecha, contada desde o início da fase (vence no último dia dela, e a
#   janela de cada uma começa no vencimento da anterior); `valor` é o boleto,
#   capital mais juros; `juros` é a parte que quitar cedo abate (`085`). Na
#   Fase 1 o capital das três soma o `START_CASH`, que é o crédito que o
#   jogador recebeu. Lista vazia é fase sem cobrança.
# - `reparos`: o que o jogador pode construir nesta fase, e QUANDO. `semana` é
#   a primeira em que o reparo abre, contada desde o início da fase;
#   `quitadas`, quantas cobranças DESTA fase ele pede pagas; `dias_de_obra`,
#   em dias jogados (`087`). O que não está aqui não se compra nesta fase.
# - `nivel_maximo`: o nível do porto que as compras desta fase alcançam. Não é
#   trava — as bancadas montam o porto de nível 3 e o jogo tem de o desenhar —,
#   é uma afirmação: quem puser aqui o guindaste da Fase 2 sem subir o nível
#   vê o F20 reprovar.
# - `bercos`: quantos berços o MAPA da fase desenha — as vagas curadas por
#   fase que o Bruno escolheu no D3, no lugar da grade livre do GDD. É o teto
#   das docas (`docas_esperadas()`).
# - `reputacao_inicial`: onde a barra começa. A escala é 0–100 em CADA fase,
#   resposta do Bruno ao D4; os 0–3000 do GDD ficam como narrativa. O patamar
#   para avançar entra com a regra da Fase 2 que o leia: a Fase 1 fecha-se
#   pelas três quitações (`085`), e um campo que nada lê seria declaração
#   morta.
const FASES := [
	{
		"semanas": 12,
		# TUNING (`085`): três parcelas iguais, R$20 mil de juros no total —
		# a amortização de parcelas iguais (~2,48% por período de 28 dias), e
		# o arredondamento fecha exatamente R$400 mil de capital. Quitar cedo
		# abate só os juros da janela, nunca o capital, e não abre a seguinte.
		"parcelas": [
			{"semana": 4, "valor": 140000, "juros": 9919},
			{"semana": 8, "valor": 140000, "juros": 6693},
			{"semana": 12, "valor": 140000, "juros": 3388},
		],
		# O píer 2 desde o início, o armazém na semana 2, o pátio depois da
		# primeira cobrança quitada (`085`). Os prazos são os da `087`: o
		# armazém leva os dois dias do tutorial do GDD.
		"reparos": {
			"pier_2": {"semana": 1, "quitadas": 0, "dias_de_obra": 2},
			"armazem": {"semana": 2, "quitadas": 0, "dias_de_obra": 2},
			"patio": {"semana": 5, "quitadas": 1, "dias_de_obra": 3},
		},
		# A madeira fica a Fase 1 inteira (`086`): o porto só recebe pesca.
		"nivel_maximo": 1,
		"bercos": 3,
		"reputacao_inicial": 65.0,
	},
	# A FASE 2 (`103`, `104`): as três quitações abrem-na no dia seguinte ao
	# último da Fase 1, no mesmo save, sem dívida e sem prazo. Perde-se só pelo
	# caixa. A meta da etapa 3 fecha-a no diário e conserva o jogo livre (`106`).
	{
		"semanas": null,
		"parcelas": [],
		# Os três reparos da Fase 1 continuam a abrir — quem chega aqui sem o
		# armazém não fica sem ele para sempre —, e entram o píer 3 e o
		# escritório, os dois com arte desde a ruína. Todos desde o primeiro dia
		# dela, uma obra de cada vez (`087`). A treliça entra na etapa 2.
		# TUNING: os dias de obra dos dois novos são PROVISÓRIOS até à etapa 4
		# (`/balancear`): o píer 3 com os três do pátio, que é a obra grande, e
		# o escritório com os dois dos reparos pequenos.
		"reparos": {
			"pier_2": {"semana": 1, "quitadas": 0, "dias_de_obra": 2},
			"armazem": {"semana": 1, "quitadas": 0, "dias_de_obra": 2},
			"patio": {"semana": 1, "quitadas": 0, "dias_de_obra": 3},
			"pier_3": {"semana": 1, "quitadas": 0, "dias_de_obra": 3},
			"escritorio": {"semana": 1, "quitadas": 0, "dias_de_obra": 2},
			# TUNING: dois dias mantidos na medição da meta completa (`108`);
			# a obra continua seguindo a regra dos reparos da Fase 1.
			"trelica": {"semana": 1, "quitadas": 0, "dias_de_obra": 2},
		},
		# A treliça e o nível declarado sobem juntos: o F20 compara este
		# número com o que as combinações de compras realmente alcançam.
		"nivel_maximo": 2,
		"bercos": 3,
		# TUNING: onde a barra recomeça. A escala é 0–100 em cada fase (D4), e
		# a passagem põe-na aqui. Mantido pela medição (`108`), como na Fase 1,
		# que é a âncora neutra da negociação (`_chance_com_reputacao`).
		"reputacao_inicial": 65.0,
		# TUNING: patamares mantidos após a medição da etapa 4 (`108`).
		# O piso abaixo do início conserva o acesso ao entrar; a meta pede avanço.
		"meta": {"reputacao": 80.0, "dias": 3, "infra": ["pier_3", "trelica"]},
		"piso_cargueiro": 40.0,
	},
]

# ── ANTECIPAÇÃO ──
# Modelo genérico anterior (`019`), preservado para contratos futuros.
# A Fase 1 usa juros limitados da janela em `valor_da_parcela_hoje()` (`085`).
# TUNING: o que o banco devolve por TURNO de antecipação, como fração do
# principal. É o item 24 do segundo playtest — "quitar antes pode diminuir o
# valor, já que teria menos juros" —, e a forma sai daí: o desconto é o juro
# que o banco deixa de correr, logo é PROPORCIONAL ao tempo e não fixo.
#
# ⚠️ FIXO FOI MEDIDO E REJEITADO, e a razão é a distribuição: o Ótimo fecha
# com R$1.309.646 em caixa e levaria o abatimento de graça, enquanto o Mediano
# só cruza a parcela no fim da partida e quase nunca o veria. Botão que só move
# quem não precisa dele (`docs/decisoes/008`).
#
# O teto é o prazo da janela atual. Quem quita no próprio dia do vencimento
# não desconta nada, e por isso o `pay_debt()` não passa por aqui.
const JUROS_POR_TURNO := 0.0025           # TUNING: fração do principal abatida por turno de antecipação

# ── A SEGUNDA CHANCE DO SR. RIBEIRO (`docs/decisoes/102`) ──
# No vencimento, a quem não tem o boleto, o banco empresta o que falta MAIS
# uma semana de custos, e o jogador devolve-o com a cobrança seguinte. Uma vez
# por fase, e só onde HÁ cobrança seguinte: a última da fase fica como era.
#
# O ACRÉSCIMO É FIXO, e é escolha do Bruno: os 3% por semana da Linha Porto,
# quatro semanas, num número só — «cubro R$50.000, você me devolve R$56.000».
# Juro corrido seria mais fiel ao banco e mais difícil de ler para quem não
# sabe finanças, e o crédito inicial (`085`) já ensina a janela; este é o
# crédito caro, e o caro tem de se ler de uma vez. Por isso a antecipação não
# o abate: quitar antes desconta só os juros da janela da PARCELA.
#
# ⚠️ E A SEMANA A MAIS NÃO É GENEROSIDADE. Sem ela o jogador saía do
# vencimento com R$0, e o primeiro fecho a seguir acabava a partida por «O
# dinheiro acabou»: a segunda chance seria uma semana de adiamento.
#
# Nenhum dos quatro perfis do simulador chega a pedi-la: o pior caixa medido
# na decisão (P10 da `087`) é R$175.244 contra um boleto de R$140.000. O valor
# não move o balanceamento medido; quem o valida é o playtest (A7).
const SEGUNDA_CHANCE_ACRESCIMO := 0.12    # TUNING: o que o empréstimo da segunda chance custa, sobre o emprestado

# ── SAVE ──
# O NOME é constante; o CAMINHO decide-o o `ArmazemLocal`, por processo: o
# jogo grava em `user://` e toda ferramenta com `--script` em
# `user://ferramentas/` (`docs/decisoes/061`). Não há `SAVE_PATH` de propósito:
# uma constante com o caminho do jogador era o que as suítes usavam para
# escrever saves inválidos — no arquivo do Bruno, se o isolamento falhasse.
const SAVE_ARQUIVO := "savegame.json"
var save_path: String = ArmazemLocal.caminho(SAVE_ARQUIVO)

# VERSÃO DO SAVE — subir quando a forma ou a interpretação do estado mudar.
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
#
# 7 (06/09): o barco trocou o booleano `large` por uma CLASSE, e a classe é a
# chave de `CLASSES_DE_NAVIO`. Um save da 6 traz `large` e nenhuma classe: o
# cartão, o casco e a conta dos turnos indexariam com chave vazia.
#
# 8 (24/09): o trabalhador passou a nascer com um ROSTO, o índice do retrato
# dele (`059`). Um save da 7 traz trabalhadores sem rosto, e o cartão indexaria
# a tabela dos retratos com uma chave que não existe.
#
# 9 (25/09): os RECORDES da partida (`065`) — o melhor dia, o dia com mais
# barcos e o maior negócio. Um save da 8 não os tem, e o painel do dinheiro
# afirmaria recordes que a partida não guardou.
#
# 10 (04/10): a FILA NO FUNDEADOURO (`083`). O barco deixou de nascer na doca
# e passou a esperar ao largo, com paciência; a oferta do Arlindo aponta para
# a fila e não para uma doca. Um save da 9 traz barcos em docas sem
# trabalhador, que esta versão daria por perdidos na primeira virada, e um
# índice de oferta que apontaria para a lista errada.
# 11 (07/10): unidade monetária ×0,1 (`084`). A 10 já guarda a fila, mas seu
# caixa, contratos ao largo/atracados e recordes usam a moeda antiga. Recusar
# antes de escrever é o contrato existente; adaptar só o caixa corromperia a
# contabilidade e deixaria contratos e recordes dez vezes maiores.
# 12 (`085`): calendário de sete dias, três cobranças, recibos e desbloqueios.
# O booleano da 11 só representava a primeira quitação; adaptar esse recibo
# inventaria duas cobranças e um calendário que a partida nunca jogou.
# 13 (`086`): os reparos não promovem mais o guindaste na Fase 1. A 12 podia
# guardar cargueiros com duas estruturas; reinterpretar esse porto com madeira
# carregaria barcos incompatíveis. Recusar a versão inteira evita inventar
# equipamento, remover contratos ou converter a partida do jogador.
# 14 (`087`): uma obra paga, ainda sem capacidade/renda, pode atravessar dias
# e carregamentos. Bruno autorizou a mudança e o recomeço sem migração.
# 15 (`102`): a segunda chance do Sr. Ribeiro — a dívida dela e se já foi
# usada, e a linha do empréstimo na semana. A primeira versão acima do piso:
# o Bruno autorizou-a COM o degrau, e um save da 14 chega aqui sem recomeçar.
# 16 (`103`, `104`): o NÚMERO DA FASE, porque a Fase 2 joga-se no mesmo save, e
# o que a obra, a parcela e o dia querem dizer depende dela. Sai junto o
# `upgrade_purchased` (M9), que só a suíte antiga lia. Autorizada pelo Bruno
# com o degrau, que escreve a Fase 1 nos saves de antes.
# A 17 (`106`), autorizada com migração, guarda dias seguidos, primeiro
# cargueiro e conquista. A 16 não conhecia o passado destes três marcos.
# A 18 (`111`), aceite com migração, guarda multas e contadores do
# cancelamento; a 17 sobe com esses campos a zero, sem recomeçar a partida.
# A 19 (`141`), autorizada com migração, guarda compras, capítulos lidos e
# despesas das lojas. O porto da 18 permanece; estes campos começam vazios.
const SAVE_VERSION := 19

# O PISO DA MIGRAÇÃO (`098`). Até a 14, save de outra versão era descartado,
# e servia ao protótipo, onde recomeçar custa uma partida de teste. Não serve
# ao jogo publicado, que promete «você nunca precisa se preocupar em perder o
# porto», e a resposta do Bruno ao D5 (11/10) foi a migração ENCADEADA:
# cada versão nova traz o passo que lê a anterior, e um save da 14 chega à
# corrente pelos degraus, sem ninguém escrever um atalho desde o piso.
#
# As de baixo do piso foram recusadas pelas decisões que as subiram, com o
# acordo do Bruno, e continuam: quem as recusa é a CADEIA, que não tem o passo
# — o piso não se confere no `_save_aceite()`, que seria a regra em dois
# sítios. Ele existe para o F21 do `teste_fumaca`, que exige um save de
# exemplo em `tests/saves/vNN.json` por versão, do piso à corrente, e que
# todos carreguem. Subir a versão pede, por isso, três coisas no mesmo
# commit: o passo em `_migrar_um_passo()`, o exemplo da versão nova
# (`tools/gravar_save_de_exemplo.gd`) e o da anterior INTACTO — é ele que
# prova o passo.
const SAVE_VERSAO_MINIMA := 14

# ── OS ESPAÇOS DE SAVE (`docs/decisoes/066`) ──
#
# Três partidas lado a lado, «que nem é feito em outros jogos» — o pedido do
# Bruno no lugar do «Novo jogo (apaga progresso)» que vivia na pausa. Três
# porque cabem numa tela de celular sem rolar, com o cais, o nome, o dia e o
# dinheiro de cada um à vista.
#
# ⚠️ O ESPAÇO 1 É O ARQUIVO DE SEMPRE, e é isso que poupa uma migração. Mudar
# o nome do save para `espaco_1.json` obrigaria a mover o `savegame.json` que o
# jogador já tem — e mover é código que corre UMA vez no aparelho de cada um,
# que é o tipo de código que nenhuma suíte exercita duas vezes. Com o espaço 1
# no mesmo nome, a partida que existia aparece nele sem ninguém lhe tocar, e o
# `SAVE_VERSION` fica onde estava: a forma do save não mudou, só o número de
# arquivos.
#
# ⚠️ E QUEM DIZ QUAL FOI JOGADO POR ÚLTIMO É O DISCO, não um campo no save. Um
# carimbo de hora dentro do JSON mudaria a forma e subiria a versão — o que
# descartaria outra vez a partida do Bruno, um dia depois da `065`. A hora de
# modificação do arquivo diz a mesma coisa, porque todo lance do jogo grava
# (`save_game()` em cada compra, turno e decisão), e só tem um segundo de
# resolução, o que para «qual jogou por último» chega.
const ESPACOS := 3
var espaco := 1


# O nome do arquivo de cada espaço. O 1 é o de sempre — ver acima.
static func arquivo_do_espaco(n: int) -> String:
	return SAVE_ARQUIVO if n == 1 else "savegame_%d.json" % n


func _apontar_espaco(n: int) -> void:
	espaco = clampi(n, 1, ESPACOS)
	save_path = ArmazemLocal.caminho(arquivo_do_espaco(espaco))


# Passa a jogar no espaço `n`: carrega o que lá houver, ou abre partida nova.
# É o «Carregar» e o «Continuar» da tela inicial.
func usar_espaco(n: int) -> void:
	_apontar_espaco(n)
	if not load_game():
		new_game()


# Partida nova no espaço `n`, por cima do que lá estiver. Quem pergunta antes
# de apagar é a tela — aqui já se decidiu.
func comecar_no_espaco(n: int) -> void:
	_apontar_espaco(n)
	clear_save()
	new_game()


# Apaga o ARQUIVO do espaço `n` e mais nada — o estado vivo fica como estava,
# mesmo quando `n` é o espaço em uso. Não há botão que o chame: quem apaga um
# porto no jogo é a partida nova que ocupa o espaço (`comecar_no_espaco`). Isto
# é para as ferramentas e as suítes, que partem de um disco conhecido.
func apagar_espaco(n: int) -> void:
	var caminho := ArmazemLocal.caminho(arquivo_do_espaco(n))
	if FileAccess.file_exists(caminho):
		DirAccess.remove_absolute(caminho)


# O que a tela inicial mostra de um espaço, lido do ARQUIVO e sem tocar no
# estado vivo nem no disco. Vazio quer dizer livre.
#
# ⚠️ LER NÃO É CARREGAR, e a diferença é a regra do save do outro lado: o
# `load_game()` APAGA o que recusa, porque um save recusado que fica no disco é
# tentado outra vez a cada arranque. Aqui recusar não apaga nada — um espaço de
# outra versão lê-se como livre, e quem o apaga é a partida nova que o ocupar.
# Pela mesma regra, as recusas são AS MESMAS do `load_game()` (`_save_aceite`):
# um resumo que aceitasse o que a carga recusa mostraria um porto que, tocado,
# abre partida nova.
#
# ⚠️ E O PORTO SEM NOME TAMBÉM É LIVRE. O `new_game()` grava logo, antes da
# tela dos nomes — um arranque sem save, ou uma «Nova partida» abandonada a
# meio, deixa no disco um dia 1 sem nome e sem lance nenhum. Mostrá-lo como
# ocupado pediria ao jogador para confirmar que apaga uma partida que nunca
# começou.
func resumo_do_espaco(n: int) -> Dictionary:
	var caminho := ArmazemLocal.caminho(arquivo_do_espaco(n))
	if not FileAccess.file_exists(caminho):
		return {}
	var lido := _save_aceite(FileAccess.get_file_as_string(caminho))
	if lido.is_empty() or String(lido.get("nome_porto", "")) == "":
		return {}
	return {
		"espaco": n,
		"porto": String(lido["nome_porto"]),
		"jogador": String(lido.get("nome_jogador", "")),
		"turno": int(lido.get("turn", 1)),
		"dinheiro": int(lido.get("cash", 0)),
		# O ESTADO DO TURNO, e não a fase da campanha: chamava-se «fase» até à
		# `104`, ao lado de uma Fase 2 que passou a existir.
		"estado": String(lido.get("phase", ESTADO_JOGANDO)),
		"numero_da_fase": int(lido["numero_da_fase"]),
		"venceu": bool(lido.get("won", false)),
		"gravado": FileAccess.get_modified_time(caminho),
	}


# O espaço jogado por último, entre os ocupados; 0 se não houver nenhum. No
# empate de segundo ganha o de número menor, para a resposta não depender da
# ordem em que o sistema lista os arquivos.
func espaco_mais_recente() -> int:
	var melhor := 0
	var quando := -1
	for n in range(1, ESPACOS + 1):
		var r := resumo_do_espaco(n)
		if r.is_empty():
			continue
		if int(r["gravado"]) > quando:
			melhor = n
			quando = int(r["gravado"])
	return melhor


# A linha que diz em que ponto vai a partida de um espaço — igual no cartão do
# espaço e na tela inicial: o dia contra o prazo e o dinheiro, que é o que se
# lê de relance para reconhecer um porto. O nome do jogador vai À FRENTE
# quando existe; ele pode estar vazio, e nenhum padrão o preenche.
#
# O prazo é o da fase DO ESPAÇO, e não o da partida viva (`104`): a tela
# inicial mostra os três lado a lado. Na fase sem prazo não há «de quantos», e
# o que diz onde o porto vai é a fase.
func linha_do_espaco(r: Dictionary) -> String:
	var linha := "%s · %s" % [rotulo_do_dia(int(r["turno"]), int(r["numero_da_fase"])),
		moeda(int(r["dinheiro"]))]
	var jogador := String(r.get("jogador", ""))
	return "%s · %s" % [jogador, linha] if jogador != "" else linha


## O DIA COMO A FRASE O ESCREVE, num lugar só: «dia 12 de 84» com prazo — o
## dia não passa do último, que é onde a partida acabada fica —, e «Fase 2,
## dia 90» sem ele (`104`). Leem-no a linha do espaço e o menu de pausa.
func rotulo_do_dia(turno: int, n: int = 0) -> String:
	if not fase_tem_prazo(n):
		return "Fase %d, dia %d" % [n if n > 0 else numero_da_fase, turno]
	return "dia %d de %d" % [mini(turno, ultimo_dia_da_fase(n)), ultimo_dia_da_fase(n)]


# O primeiro espaço livre; 0 se os três estiverem ocupados.
func primeiro_espaco_livre() -> int:
	for n in range(1, ESPACOS + 1):
		if resumo_do_espaco(n).is_empty():
			return n
	return 0

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
# trata por "chefia" e o Arlindo por "meu caro", então ninguém fica sem
# forma de tratamento.
const NOME_JOGADOR_PADRAO := ""

# Limite de tamanho dos dois campos. Vem da tela, não do gosto: o nome do porto
# entra no cabeçalho do Boletim e na placa, e acima disto ele estoura a caixa
# nos 720px de largura do retrato.
const NOME_MAX_CARACTERES := 24

# ── OS ESTADOS DO TURNO (M9, `104`) ──
# O que o turno espera: o jogador a jogar, a resposta à oferta do Arlindo, a
# decisão da cobrança, ou nada — a partida acabou. Viviam como texto solto em
# 89 sítios, e um erro de digitação num deles (`"debt_paymnet"`) não daria
# erro nenhum: a comparação daria falso e o botão ficaria apagado para sempre.
# Com a constante, o nome errado não compila.
#
# ⚠️ ESTE «ESTADO» NÃO É A FASE DA CAMPANHA. A variável chama-se `phase` desde
# o protótipo, e a Fase 1, a 2… são `numero_da_fase`: os dois nomes conviviam
# a confundir-se (a revisão de 09/10 anotou-o), e a Fase 2 pô-los no mesmo
# arquivo. Os VALORES ficam em inglês porque estão em todo save gravado;
# trocá-los seria uma migração por gosto.
const ESTADO_JOGANDO := "playing"
const ESTADO_OFERTA := "rival_offer"
const ESTADO_COBRANCA := "debt_payment"
const ESTADO_FIM := "game_over"
const ESTADOS_DO_TURNO := [ESTADO_JOGANDO, ESTADO_OFERTA, ESTADO_COBRANCA, ESTADO_FIM]

# ── STATE ──
var turn: int = 1
var cash: int = START_CASH
# A FASE DA CAMPANHA em jogo, a partir de 1 — a linha `numero_da_fase - 1` da
# `FASES` (`104`). Declarada antes da reputação, que a lê para saber onde
# começa.
var numero_da_fase: int = 1
var reputation: float = reputacao_inicial()
# Só dias FECHADOS contam. A missão e a conquista não se perdem com a queda.
var dias_de_reputacao: int = 0
var primeiro_cargueiro: bool = false
var meta_concluida: bool = false
var docks: Array = []       # [{boat: Dictionary|null, worker_id: int|null}]
var workers: Array = []     # [{id:int, busy_turns:int}]
# Estruturas já concluídas, por id. Guardado como Array para o save ser um JSON
# simples — Dictionary de bool viraria ruído no ficheiro.
var estruturas: Array = []
var obra_em_andamento: Dictionary = {}
var parcela_paid: bool = false
var parcela_indice: int = 0
var parcelas_quitadas: int = 0
var total_pago_parcelas: int = 0
# A SEGUNDA CHANCE (`102`): o que o jogador deve ao banco por ela, já com o
# acréscimo, e que se soma ao boleto da cobrança corrente; e se ela já foi
# usada nesta fase. Zero e falso numa partida que nunca a pediu.
var emprestimo_devido: int = 0
var segunda_chance_usada: bool = false
var phase: String = ESTADO_JOGANDO   # um dos `ESTADOS_DO_TURNO`
# Os barcos ao largo, por ordem de chegada (`083`). Cada um é o mesmo
# dicionário de um barco atracado, mais a `paciencia` que lhe resta.
var fila: Array = []
# O barco da FILA sobre o qual o Arlindo fez oferta, ou -1. Chamava-se
# `pending_rival_dock` e apontava para uma doca; um nome que dissesse doca e
# apontasse para a fila seria a armadilha do comentário que mente.
var pending_rival: int = -1
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
#
# ⚠️ O `emprestimo` NÃO É RECEITA NEM DESPESA (`102`): é o dinheiro que o
# banco pôs no caixa pela segunda chance. Crédito não é lucro — o
# `resumo_da_semana()` não o soma ao resultado, e o boletim mostra-o à parte.
const SEMANA_ZERADA := {
	"docagens": 0, "armazem": 0, "patio": 0, "pier": 0,
	"salarios": 0, "manutencao": 0, "parcela": 0, "emprestimo": 0, "cancelamento": 0, "lojas": 0,
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
	"salarios": 0, "manutencao": 0, "parcela": 0, "cancelamento": 0, "lojas": 0,
	"servidos": 0, "perdidos": 0, "turno": 0,
}
var dia_atual: Dictionary = DIA_ZERADO.duplicate()
var dia_anterior: Dictionary = DIA_ZERADO.duplicate()

# O resultado líquido de cada semana já fechada, em ordem. A Dona Cida compara
# a semana contra a média das anteriores para escolher o tom, e sem histórico
# não há com que comparar — na semana 1 ela usa só o sinal do resultado.
var historico_semanas: Array = []

# Compras e leitura pertencem ao espaço da partida, não às preferências.
# O degrau 18→19 mantém o porto e começa este histórico vazio (`141`).
var vida_do_porto: Dictionary = VidaDoPorto.vazio()

# ── OS RECORDES DA PARTIDA (`065`) ──
# O painel do dinheiro mostra o melhor dia, o dia com mais barcos, o maior
# negócio e a melhor semana, e zeram com a partida — escolha do Bruno, que os
# quer para comparar com «ontem», e não como recorde pessoal entre partidas.
# A melhor semana não mora aqui: sai do `historico_semanas`, que já existe.
#
# ⚠️ O DIA ENTRA NO RECORDE UMA VIRADA DEPOIS, e é de propósito. O
# `pay_debt()` escreve a parcela no `dia_anterior` DEPOIS de o dia ter virado
# (ver `advance_turn()`), então um dia só está fechado de verdade quando o
# seguinte vira. Gravar na virada punha o dia 32 como um dia bom com a parcela
# ainda por sair dele. Aqui ficam os dias ANTERIORES ao
# `dia_anterior`, e quem lê é `recordes()`, que soma o `dia_anterior` vivo.
#
# O maior negócio grava-se no instante do pagamento, porque o valor de um
# barco não muda depois de ele sair — e é o mesmo `_lancar_receita()` que põe
# o dinheiro no caixa quem diz quanto ele pagou.
#
# `turno` 0 é «ainda não houve», e é o que a partida nova traz.
const RECORDES_ZERADOS := {
	"melhor_dia": {"valor": 0, "turno": 0},
	"mais_barcos": {"n": 0, "turno": 0},
	"maior_negocio": {"valor": 0, "turno": 0, "motivo": "", "classe": ""},
}
var _recordes: Dictionary = RECORDES_ZERADOS.duplicate(true)

var metrics := {
	"servicos_cancelados": 0,
	"multas_cancelamento": 0,
	"boats_served": 0,
	"boats_lost": 0,
	"rival_matched": 0,
	"rival_refused": 0,
	"revenue": 0,
	"pier_income": 0,
}

var _uid := 1
var _rng := RandomNumberGenerator.new()


## Um trabalhador acabado de chegar ao porto, com o ROSTO dele (`059`): um dos
## retratos de `Retratos.TRABALHADORES`, sem repetir nenhum da fileira. É a
## porta ÚNICA por onde um trabalhador nasce — a partida nova, o píer comprado
## e o roster reconciliado —, e os testes que montam porto à mão passam por ela.
##
## ⚠️ O ROSTO NÃO GASTA O SORTEIO DA PARTIDA. O `_rng` é o que o simulador mede
## (os barcos, os motivos, o rival), e um sorteio a mais aqui mudaria todas as
## partidas medidas sem mexer em regra nenhuma. O rosto sai de um gerador
## PRÓPRIO, semeado pelo ESTADO do `_rng` — ler o estado não o avança —, e daí
## saem as três coisas que se queria: cada partida com caras diferentes (o
## estado anda), a mesma cara com a mesma semente (as fotos da bateria
## comparam-se) e o balanceamento medido intocado por construção.
func novo_trabalhador() -> Dictionary:
	return {"id": workers.size() + 1, "busy_turns": 0, "rosto": _rosto_livre()}


## Quantos rostos há. Sai do registo dos retratos, e não de uma constante que
## o espelhasse: são trinta enquanto a tabela do estúdio tiver trinta.
func rostos() -> int:
	return Retratos.TRABALHADORES.size()


func _rosto_livre() -> int:
	var usados := {}
	for w in workers:
		usados[int(w["rosto"])] = true
	var livres: Array[int] = []
	for k in range(rostos()):
		if not usados.has(k):
			livres.append(k)
	if livres.is_empty():
		return workers.size() % rostos()
	var gerador := RandomNumberGenerator.new()
	gerador.seed = hash([_rng.state, workers.size()])
	return livres[gerador.randi_range(0, livres.size() - 1)]


func _ready() -> void:
	_rng.randomize()
	# O arranque abre o espaço jogado por último (`066`), que é o que a tela
	# inicial oferece em «Continuar». Sem espaço ocupado, o 1 — o arquivo de
	# sempre, e o único que as ferramentas usam.
	_apontar_espaco(maxi(espaco_mais_recente(), 1))
	if not load_game():
		new_game()


func new_game() -> void:
	_limpar_guindaste_da_bancada()
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
	_recordes = RECORDES_ZERADOS.duplicate(true)
	vida_do_porto = VidaDoPorto.vazio()
	cash = START_CASH
	# A fase ANTES da reputação: é ela que diz onde a barra começa.
	numero_da_fase = 1
	dias_de_reputacao = 0
	primeiro_cargueiro = false
	meta_concluida = false
	reputation = reputacao_inicial()
	estruturas = []
	obra_em_andamento = {}
	parcela_paid = false
	parcela_indice = 0
	parcelas_quitadas = 0
	total_pago_parcelas = 0
	emprestimo_devido = 0
	segunda_chance_usada = false
	_set_phase(ESTADO_JOGANDO)
	fila = []
	pending_rival = -1
	rival_attempts_left = RIVAL_PATIENCE
	end_reason = ""
	won = false
	metrics = {"boats_served": 0, "boats_lost": 0, "fila_desistiu": 0, "rival_matched": 0, "rival_refused": 0, "revenue": 0, "pier_income": 0, "servicos_cancelados": 0, "multas_cancelamento": 0}

	docks.clear()
	for i in range(DOCKS_BASE):
		docks.append({"boat": null, "worker_id": null})

	workers.clear()
	for i in range(WORKERS_BASE):
		workers.append(novo_trabalhador())

	_spawn_boats()
	save_game()


func capitulos_do_porto() -> Array[String]:
	return VidaDoPorto.disponiveis(turn, numero_da_fase, TURNS_PER_WEEK,
		estruturas, parcelas_quitadas, vida_do_porto["compras"])


func proxima_historia_do_porto() -> String:
	for id in capitulos_do_porto():
		if not vida_do_porto["cenas_lidas"].has(id):
			return id
	return ""


func concluir_capitulo(id: String) -> bool:
	if not capitulos_do_porto().has(id) or vida_do_porto["cenas_lidas"].has(id):
		return false
	vida_do_porto["cenas_lidas"].append(id)
	save_game()
	return true


func impedimento_compra_loja(id: String) -> String:
	if not VidaDoPorto.PRODUTOS.has(id):
		return "Este produto não está no catálogo."
	if vida_do_porto["compras"].has(id):
		return "Esta compra já foi feita."
	if phase != ESTADO_JOGANDO:
		return "Resolva a decisão do porto antes de comprar."
	if cash < int(VidaDoPorto.PRODUTOS[id]["preco"]):
		return "Dinheiro insuficiente para esta compra."
	return ""


func comprar_na_loja(id: String) -> bool:
	if impedimento_compra_loja(id) != "":
		return false
	var produto: Dictionary = VidaDoPorto.PRODUTOS[id]
	var preco := int(produto["preco"])
	# O direito à conversa e o lançamento são feitos antes de emitir sinais:
	# um segundo clique ou ouvinte não pode comprar nem cobrar outra vez.
	vida_do_porto["compras"].append(id)
	cash -= preco
	dia_atual["lojas"] += preco
	semana_atual["lojas"] += preco
	save_game()
	cash_changed.emit(cash)
	message.emit("%s comprado por %s. Uma conversa nova está nas lojas." % [
		String(produto["nome"]), moeda(preco)], "good", "dinheiro")
	return true


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
# haver quatro versões da regra. Aqui são sete telas e três tokens.
#
# O nome do JOGADOR não tem padrão de propósito — inventar um seria pôr palavra
# na boca de quem não a escolheu. Quem deixa em branco fica sem vocativo, e as
# falas que o usariam têm variante para isso (ver Narrativa.gd).
#
# O `{caixaInicial}` sai do START_CASH e existe porque o diário CONTA de onde
# vem o dinheiro do jogador. Escrever o valor na prosa é o defeito que a
# narração de fim de fase já teve uma vez ("Doze semanas / Três parcelas", que
# era a Fase 1 do GDD e não o VS): número em fala envelhece calado quando a
# constante muda, e a constante já foi varrida uma vez (`docs/decisoes/018`).
func texto(modelo: String) -> String:
	var porto := nome_porto if nome_porto != "" else NOME_PORTO_PADRAO
	return modelo.replace("{portName}", porto) \
		.replace("{playerName}", nome_jogador) \
		.replace("{caixaInicial}", moeda(START_CASH)) \
		.replace("{totalParcelas}", moeda(total_das_parcelas(1)))


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


func week_of(t: int) -> int:
	return int(ceil(float(t) / float(TURNS_PER_WEEK)))


func current_week() -> int:
	return week_of(turn)


# ── A FASE EM JOGO (`094`, `104`) ──
## A linha de `FASES` da fase `n`, contada a partir de 1; com `n` em 0, a da
## fase que se está a jogar (`numero_da_fase`, no save desde a 16). Todo número
## de fase passa por aqui, e foi isso que fez da Fase 2 uma linha e um campo
## no save, e não as duzentas leituras que as constantes tinham.
##
## ⚠️ O `n` EXPLÍCITO É PARA QUEM FALA DE OUTRA FASE QUE NÃO A EM JOGO: o
## diário que fecha a Fase 1 abre já na Fase 2 (a passagem é imediata), e o
## `_save_aceite()` confere o arquivo contra a fase DELE, antes de ela ser a
## em jogo. Com o 0 ali, o diário contaria as semanas da Fase 2 — que não as
## tem — e o save seria lido pela fase de quem o abre.
func dados_da_fase(n: int = 0) -> Dictionary:
	return FASES[(n if n > 0 else numero_da_fase) - 1]


## Se a fase acaba por calendário. A Fase 2 não acaba (`103`): ver `semanas`
## no cabeçalho da `FASES`.
func fase_tem_prazo(n: int = 0) -> bool:
	return dados_da_fase(n)["semanas"] != null


## Quanto a fase dura. Numa fase sem prazo REBENTA — `int(null)` —, e é de
## propósito: o zero que daria leria-se como duração (`gerais.md`, «zero é o
## pior valor de omissão»). Quem lê pergunta antes pelo `fase_tem_prazo()`.
func semanas_da_fase(n: int = 0) -> int:
	return int(dados_da_fase(n)["semanas"])


func turnos_da_fase(n: int = 0) -> int:
	return semanas_da_fase(n) * TURNS_PER_WEEK


## O primeiro dia da fase, no calendário da partida inteira: a Fase 1 abre no
## dia 1, e cada uma no dia a seguir ao último da anterior. O calendário não
## recomeça (`103`): a semana 13 é a primeira da Fase 2, e o boletim continua.
func inicio_da_fase(n: int = 0) -> int:
	var alvo := n if n > 0 else numero_da_fase
	var dia := 1
	for k in range(1, alvo):
		dia += turnos_da_fase(k)
	return dia


## O último dia da fase, no mesmo calendário. Só existe com prazo.
func ultimo_dia_da_fase(n: int = 0) -> int:
	return inicio_da_fase(n) + turnos_da_fase(n) - 1


## A semana desse último dia — o «de 12» do boletim e do celular.
func ultima_semana_da_fase(n: int = 0) -> int:
	return week_of(ultimo_dia_da_fase(n))


## As parcelas da fase, por ÍNDICE a partir de 0 — o mesmo do
## `parcela_indice`. O valor é o boleto (capital mais juros); o dia é o último
## da semana que ela fecha.
func parcelas_na_fase(n: int = 0) -> int:
	return (dados_da_fase(n)["parcelas"] as Array).size()


## Se há cobrança por vencer nesta fase. Na Fase 2 não há nenhuma (`103`), e
## é ESTA a pergunta que vem antes de qualquer leitura da parcela corrente: o
## `parcela_indice` 0 de uma fase sem parcelas aponta para fora da lista, e
## quem a ler sem perguntar rebenta em vez de inventar um boleto.
func tem_cobranca() -> bool:
	return parcela_indice < parcelas_na_fase()


func valor_da_parcela(indice: int, n: int = 0) -> int:
	return int(dados_da_fase(n)["parcelas"][indice]["valor"])


func juros_da_parcela(indice: int, n: int = 0) -> int:
	return int(dados_da_fase(n)["parcelas"][indice]["juros"])


func dia_da_parcela(indice: int, n: int = 0) -> int:
	return inicio_da_fase(n) - 1 \
		+ int(dados_da_fase(n)["parcelas"][indice]["semana"]) * TURNS_PER_WEEK


## O que as parcelas da fase somam — o `{totalParcelas}` das falas. As falas
## que o leem são as do crédito da Fase 1, e por isso ele as lê dela.
func total_das_parcelas(n: int = 0) -> int:
	var total := 0
	for i in range(parcelas_na_fase(n)):
		total += valor_da_parcela(i, n)
	return total


## Os reparos que a fase deixa construir, na ordem da tabela.
func reparos_da_fase(n: int = 0) -> Array:
	return (dados_da_fase(n)["reparos"] as Dictionary).keys()


## Quantos berços o mapa da fase desenha. Não é número de interface: é o TETO
## do porto, e por isso mora aqui e não no Main. Enquanto vivia só lá em cima,
## nada impedia o estado de passar do que a tela sabe mostrar — e passou: um
## save antigo, gravado quando o porto abria com 2 docas, somava os dois píeres
## comprados e chegava a 4 docas contra 3 vagas desenhadas. A quarta doca
## existia, recebia barco e nunca aparecia.
func bercos_no_mapa(n: int = 0) -> int:
	return int(dados_da_fase(n)["bercos"])


func reputacao_inicial(n: int = 0) -> float:
	return float(dados_da_fase(n)["reputacao_inicial"])


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
	# Os vencimentos saem da tabela, e não de um múltiplo: com as parcelas a
	# cada quatro semanas os dois davam o mesmo, e uma fase com janelas
	# desiguais marcaria o dia errado sem erro nenhum.
	var vencimentos := {}
	for i in range(parcelas_na_fase()):
		vencimentos[dia_da_parcela(i)] = true
	# A FASE SEM PRAZO não tem último dia por onde acabar a lista (`104`): o
	# calendário mostra a semana de hoje e as três seguintes, que é o que se
	# planeia daqui — a Fase 1 inteira são doze, e quem as lê rola. Sem
	# parcela nem último dia, a única marca que sobra é o fecho de semana.
	var primeiro := inicio_da_fase()
	var ultimo := ultimo_dia_da_fase() if fase_tem_prazo() else 0
	if not fase_tem_prazo():
		primeiro = maxi(primeiro, (current_week() - 1) * TURNS_PER_WEEK + 1)
		ultimo = primeiro + CALENDARIO_SEM_PRAZO_SEMANAS * TURNS_PER_WEEK - 1
	var dias: Array = []
	for t in range(primeiro, ultimo + 1):
		dias.append({
			"turno": t,
			"semana": week_of(t),
			"hoje": t == turn,
			"passado": t < turn,
			"fecha_semana": t % TURNS_PER_WEEK == 0,
			"parcela_vence": vencimentos.has(t),
			"ultimo_dia": fase_tem_prazo() and t == ultimo,
		})
	return dias


## Quantas semanas o calendário mostra numa fase sem prazo: a de hoje e as
## três seguintes.
const CALENDARIO_SEM_PRAZO_SEMANAS := 4


# ── WORKER ASSIGNMENT ──
# ⚠️ DESDE A `083` O JOGO NÃO PASSA POR AQUI: o `atracar()` põe barco e
# trabalhador no berço de uma vez, e a fileira que arrastava trabalhadores
# para as docas deu o lugar à fila. Fica porque as suítes MONTAM estados com
# ela — um barco escrito à mão numa doca, e alguém para o operar — e porque
# é ela que diz não a um trabalhador em duas docas, que é a regra que o
# `atracar()` respeita ao escolher só quem não tem doca.
func assign_worker(worker_id: int, dock_index: int, avisar: bool = true) -> bool:
	if phase != ESTADO_JOGANDO:
		return false
	if dock_index < 0 or dock_index >= docks.size():
		return false
	var dock: Dictionary = docks[dock_index]
	if dock["boat"] == null:
		if avisar:
			message.emit("Doca vazia — não há barco aqui.", "warn", "doca")
		return false
	if dock["worker_id"] != null:
		if avisar:
			message.emit("Essa doca já tem trabalhador operando.", "warn", "doca")
		return false
	var boat: Dictionary = dock["boat"]
	if boat.get("rival", false) and not boat.get("matched", false):
		if avisar:
			message.emit("Resolva a oferta do rival antes de alocar.", "warn", "rival")
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
			message.emit("Trabalhador #%d já está na Doca %d. Toque na doca para liberá-lo." % [worker_id, already + 1], "warn", "trabalhador")
		return false
	dock["worker_id"] = worker_id
	if avisar:
		message.emit("Trabalhador alocado. Avance o dia para operar.", "good", "trabalhador")
	roster_changed.emit()
	save_game()
	return true


# ── ATRACAR (`083`) ──
# O primeiro berço sem barco, ou -1. Os berços são iguais entre si — o nível é
# do porto, não do píer (`007`) —, então escolher QUAL não mudaria nada, e o
# toque escolhe só o barco.
func berco_livre() -> int:
	for i in range(docks.size()):
		if docks[i]["boat"] == null:
			return i
	return -1


func bercos_livres() -> int:
	var n := 0
	for d in docks:
		if d["boat"] == null:
			n += 1
	return n


# Um barco da fila pode atracar se não estiver sob oferta por resolver.
func barco_pronto(indice: int) -> bool:
	if indice < 0 or indice >= fila.size():
		return false
	var barco: Dictionary = fila[indice]
	return not (barco.get("rival", false) and not barco.get("matched", false))


# Quantos barcos ao largo podem atracar (sem oferta por resolver). É o
# «barcos esperando» da fala da semana nova (`083`): até lá ela perguntava por
# docas à espera de trabalhador, que deixaram de existir.
func barcos_ao_largo() -> int:
	var n := 0
	for i in range(fila.size()):
		if barco_pronto(i):
			n += 1
	return n


# Há escolha a fazer AGORA? Berço livre e barco pronto ao largo, nesta ordem,
# num `Vector2i` — ou (0, 0). É o sucessor do `trabalho_parado()`: desde a
# fila o trabalhador vai junto com o barco, e o que fica por fazer é escolher.
func atracagem_pendente() -> Vector2i:
	if phase != ESTADO_JOGANDO:
		return Vector2i.ZERO
	var prontos := barcos_ao_largo()
	var livres := bercos_livres()
	if livres == 0 or prontos == 0:
		return Vector2i.ZERO
	return Vector2i(livres, prontos)


# Tira o barco `indice` da fila e põe-no no primeiro berço livre, com o
# trabalhador livre (há sempre um por berço: cada píer traz o seu). É o toque
# do jogador no cartão do barco, e a escolha do jogo inteiro (`083`).
#
# Os turnos de operação RECALCULAM-SE aqui: o barco pode ter chegado antes de
# o pórtico ser comprado, e o que conta é o porto em que ele descarrega.
func atracar(indice: int, avisar: bool = true) -> bool:
	if phase != ESTADO_JOGANDO:
		return false
	if not barco_pronto(indice):
		return false
	var doca := berco_livre()
	if doca < 0:
		if avisar:
			message.emit("Os berços estão todos ocupados.", "warn", "doca")
		return false
	var trabalhador := _trabalhador_sem_doca(doca)
	if trabalhador < 0:
		if avisar:
			message.emit("Não há trabalhador livre para operar.", "warn", "trabalhador")
		return false
	var barco: Dictionary = fila[indice]
	var valores_ao_largo: Array = []
	for b in fila:
		valores_ao_largo.append(int(b["value"]))
	fila.remove_at(indice)
	barco["op_turns"] = _turnos_de_operacao(String(barco["classe"]), String(barco["motivo"]))
	docks[doca]["boat"] = barco
	docks[doca]["worker_id"] = trabalhador
	if avisar:
		message.emit("%s na Doca %d. Avance o dia para operar." % [
			String(CLASSES_DE_NAVIO[barco["classe"]]["nome"]), doca + 1], "good", "doca")
	atracou.emit(doca, barco, valores_ao_largo)
	fila_mudou.emit()
	roster_changed.emit()
	save_game()
	return true


# Desfaz o toque: o barco volta ao largo com a paciência que tinha, e o
# trabalhador fica livre. Só antes de a operação começar — é o «toque na doca
# para liberar» de sempre, com o barco a voltar em vez de ficar sem ninguém.
func desatracar(dock_index: int) -> bool:
	if phase != ESTADO_JOGANDO:
		return false
	if dock_index < 0 or dock_index >= docks.size():
		return false
	var doca: Dictionary = docks[dock_index]
	var barco = doca["boat"]
	if barco == null:
		return false
	if int(barco["progress"]) > 0:
		message.emit("A operação já começou — o barco não sai agora.", "warn", "doca")
		return false
	if fila.size() >= FILA_LUGARES:
		message.emit("O fundeadouro está cheio.", "warn", "doca")
		return false
	doca["boat"] = null
	doca["worker_id"] = null
	fila.append(barco)
	message.emit("O barco voltou ao largo.", "", "doca")
	fila_mudou.emit()
	roster_changed.emit()
	save_game()
	return true


# As duas metades da doca abrem a mesma confirmação. Sem dia operado,
# preserva-se a devolução gratuita, inclusive a recusa com fila cheia.
func tocar_doca(doca: int) -> void:
	if phase != ESTADO_JOGANDO or doca < 0 or doca >= docks.size():
		return
	var barco = docks[doca]["boat"]
	if barco == null:
		return
	if int(barco["progress"]) == 0:
		desatracar(doca)
	else:
		gerenciamento_solicitado.emit(doca, int(barco["id"]))


func custos_do_cancelamento(doca: int, id: int) -> Dictionary:
	if phase != ESTADO_JOGANDO or doca < 0 or doca >= docks.size():
		return {}
	var barco = docks[doca]["boat"]
	if barco == null or int(barco["id"]) != id:
		return {}
	if int(barco["progress"]) <= 0 or int(barco["progress"]) >= int(barco["op_turns"]):
		return {}
	if docks[doca]["worker_id"] == null or _find_worker(docks[doca]["worker_id"]) == null:
		return {}
	var multa := ceili(float(_valor_do_barco(doca)) * CANCELAMENTO_MULTA)
	return {"dia": turn, "doca": doca, "uid": id,
		"classe": barco["classe"], "motivo": barco["motivo"],
		"operados": int(barco["progress"]), "total": int(barco["op_turns"]),
		"valor_acordado": _valor_do_barco(doca), "receita_abandonada": receita_da_doca(doca),
		"multa": multa, "caixa_antes": cash, "caixa_depois": cash - multa,
		"rep_antes": reputation, "rep_depois": clampf(reputation - CANCELAMENTO_REPUTACAO, 0, 100)}


# O orçamento exibido é revalidado inteiro: identidade impede cobrar outro
# barco; valores impedem confirmar custos diferentes dos que foram lidos.
# Nenhum fecho é antecipado e a multa já paga nunca é debitada na virada.
func cancelar_servico(doca: int, id: int, confirmado: Dictionary) -> bool:
	var evento := custos_do_cancelamento(doca, id)
	if evento.is_empty() or evento != confirmado:
		return false
	var trabalhador = _find_worker(docks[doca]["worker_id"])
	cash -= int(evento["multa"])
	metrics["boats_lost"] += 1
	metrics["servicos_cancelados"] += 1
	metrics["multas_cancelamento"] += int(evento["multa"])
	dia_atual["perdidos"] += 1
	dia_atual["cancelamento"] += int(evento["multa"])
	semana_atual["cancelamento"] += int(evento["multa"])
	trabalhador["busy_turns"] = 0
	docks[doca]["boat"] = null
	docks[doca]["worker_id"] = null
	_change_reputation(-CANCELAMENTO_REPUTACAO)
	servico_cancelado.emit(evento.duplicate(true))
	cash_changed.emit(cash)
	roster_changed.emit()
	message.emit("Serviço cancelado. Multa de %s; doca e trabalhador livres." % moeda(int(evento["multa"])), "warn", "doca")
	save_game()
	return true


# A EQUIPE DO PÍER primeiro: o trabalhador nº N nasce com o píer N
# (`novo_trabalhador()` numera por ordem de chegada, e cada píer traz um), e
# atracar no berço N chama-o se ele estiver livre. É o que deixa o cartão da
# doca mostrar sempre a mesma cara no mesmo píer. Só se ele estiver preso
# noutro berço, por uma alocação anterior, vai o
# primeiro livre.
func _trabalhador_sem_doca(doca: int) -> int:
	var primeiro := -1
	for w in workers:
		var wid := int(w["id"])
		if int(w["busy_turns"]) != 0 or worker_dock_index(wid) >= 0:
			continue
		if wid == doca + 1:
			return wid
		if primeiro < 0:
			primeiro = wid
	return primeiro


func _valor_do_barco(dock_index: int) -> int:
	var barco = docks[dock_index]["boat"]
	if barco == null:
		return 0
	return int(barco["matched_value"]) if barco.get("matched", false) else int(barco["value"])


# O CAIXA ESTÁ CURTO? O critério vivia dentro do `_cida_caixa` do Main, e
# passou a haver um segundo leitor (a fala da semana nova). Duas cópias da
# mesma linha é uma que pode envelhecer calada — e esta decide o que a Dona
# Cida AFIRMA, de modo que divergirem seria ela dizer "caixa no limite" e
# "conta fina" em estados diferentes.
#
# Meia parcela não é número novo: é o que o aviso de caixa curto já usava
# desde que existe.
#
# ⚠️ SEM COBRANÇA NÃO HÁ META, e o caixa não está curto de nada (`104`). As
# falas que este predicado escolhe falam todas da parcela; na Fase 2 o aviso
# de dinheiro é outro, e vem com as falas dela (etapa 3).
func caixa_curto() -> bool:
	return tem_cobranca() and cash < principal_da_parcela() / 2


# Sem dívida, o aviso compara dinheiro com a próxima semana de operação.
func dinheiro_curto_na_fase_livre() -> bool:
	if tem_cobranca():
		return false
	var custos := _custos_da_semana()
	return cash < int(custos["salarios"]) + int(custos["manutencao"])


# Devolve o índice da doca onde o trabalhador está alocado, ou -1.
func worker_dock_index(worker_id: int) -> int:
	for i in range(docks.size()):
		var assigned = docks[i]["worker_id"]
		if assigned != null and int(assigned) == worker_id:
			return i
	return -1


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
# O barco sobre o qual o Arlindo fez oferta, ou null. Existe para o painel e
# o jogo lerem o MESMO barco: até à `083` o painel ia buscá-lo a
# `docks[indice]["boat"]`, e a oferta passou a viver na fila.
func barco_da_oferta() -> Variant:
	if pending_rival < 0 or pending_rival >= fila.size():
		return null
	return fila[pending_rival]


func negotiate_rival(acao: String) -> String:
	var restavam := rival_attempts_left
	var resultado := _negociar(acao)
	negociacao_resolvida.emit(acao, resultado, RIVAL_PATIENCE - restavam + 1)
	return resultado


func _negociar(acao: String) -> String:
	if phase != ESTADO_OFERTA or pending_rival < 0:
		return "invalido"
	var boat = barco_da_oferta()
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

	message.emit("O cliente não gostou — última tentativa antes de ele ir embora.", "warn", "cliente")
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
# A conta é ancorada em `reputacao_inicial()`: quem começa a fase não leva
# bónus nem castigo, e a partir daí sobe ou desce com o que fizer. A âncora não é
# enfeite — ancorar noutro sítio faria a mecânica INFLAR o jogo todo em vez de
# redistribuir, e o balanceamento medido (100% / 47% / 0%) mede-se contra uma
# partida que começa neutra.
#
# O teto de 0.95 existe para "manter o preço" nunca virar jogada automática:
# com reputação máxima a aposta fica boa, não fica garantida.
func _chance_com_reputacao(base: float) -> float:
	var acima := (reputation - reputacao_inicial()) / (100.0 - reputacao_inicial())
	return clampf(base * (1.0 + REPUTACAO_EFEITO_NEGOCIACAO * acima), 0.0, 0.95)


# Compat com a versão binária (usada pela suíte de testes de regressão).
func resolve_rival_offer(accept_match: bool) -> void:
	if accept_match:
		negotiate_rival("igualar")
	elif phase == ESTADO_OFERTA and pending_rival >= 0:
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
	pending_rival = -1
	rival_attempts_left = RIVAL_PATIENCE
	_set_phase(ESTADO_JOGANDO)


func _fechar_negocio(boat: Dictionary, desconto: float, aviso: String) -> void:
	var valor := int(round(boat["value"] * (1.0 - desconto)))
	boat["matched"] = true
	boat["rival"] = false
	boat["matched_value"] = valor
	metrics["rival_matched"] += 1
	_close_rival_offer()
	_change_reputation(REPUTATION_GAIN_RIVAL_MATCHED)
	message.emit("%s — barco fechado por %s." % [aviso, moeda(valor)], "good", "negocio")
	roster_changed.emit()
	save_game()


func _perder_para_rival() -> void:
	metrics["rival_refused"] += 1
	metrics["boats_lost"] += 1
	dia_atual["perdidos"] += 1
	if pending_rival >= 0 and pending_rival < fila.size():
		fila.remove_at(pending_rival)
	_close_rival_offer()
	fila_mudou.emit()
	_change_reputation(-REPUTATION_LOSS_RIVAL_REFUSED)
	message.emit("O cliente perdeu a paciência e foi para o Porto Farol.", "bad", "rival")
	roster_changed.emit()
	save_game()


# ── TURN ADVANCE ──
func advance_turn() -> void:
	if phase != ESTADO_JOGANDO:
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
				_registrar_negocio(value, boat)
				cash += value
				metrics["revenue"] += value
				dia_atual["servidos"] += 1
				metrics["boats_served"] += 1
				_change_reputation(REPUTATION_GAIN_SERVED)
				if numero_da_fase == 2 and boat["classe"] == "medio" and not primeiro_cargueiro:
					primeiro_cargueiro = true
					message.emit("Missão cumprida: primeiro cargueiro atendido.", "good", "meta")
				contrato_fechado.emit(bruto, String(boat["classe"]))
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

	# A FILA ESPERA UM DIA A MENOS (`083`). Quem chega a zero desiste e vai
	# para o Porto Farol — é o mesmo barco perdido de quando ele nascia na
	# doca e ninguém o atendia, e custa o mesmo à reputação. De trás para a
	# frente, porque remover desloca os índices de quem vem depois.
	var desistiram := 0
	for idx in range(fila.size() - 1, -1, -1):
		var esperando: Dictionary = fila[idx]
		esperando["paciencia"] = int(esperando["paciencia"]) - 1
		if int(esperando["paciencia"]) > 0:
			continue
		fila.remove_at(idx)
		desistiram += 1
		metrics["boats_lost"] += 1
		metrics["fila_desistiu"] += 1
		dia_atual["perdidos"] += 1
		_change_reputation(-REPUTATION_LOSS_LOST)
	if desistiram > 0:
		fila_mudou.emit()

	var prev_turn := turn
	turn += 1
	cash_changed.emit(cash)

	# O dia que fechou venceu uma cobrança? Na Fase 2 nunca (`104`): sem
	# parcela não há vencimento, e perguntá-lo leria fora da lista.
	var venceu_hoje := tem_cobranca() and prev_turn == vencimento_da_parcela()
	if prev_turn % TURNS_PER_WEEK == 0:
		# No vencimento, os custos da semana precisam sair ANTES de o caixa dizer
		# se a parcela cabe, mas o boletim só pode fechar DEPOIS de a decisão: é
		# nele que a parcela paga neste dia tem de aparecer.
		var espera_parcela := venceu_hoje and not parcela_paid
		_process_week_end(week_of(prev_turn), espera_parcela)

	# A VIRADA DO DIA vem DEPOIS dos lançamentos do fecho e ANTES do corte por dívida
	# — o dia que fechou já tem os números completos (pier/salários/manutenção
	# inclusive, se foi dia de fechar semana) antes de ir para `dia_anterior`.
	# Se a dívida vencer HOJE, `pay_debt()` ainda escreve na parcela DESTE
	# dia (`dia_anterior`), porque `advance_turn()` já devolveu por aqui e o
	# turno seguinte só começa depois de o jogador decidir.
	dia_atual["turno"] = prev_turn
	# O dia que SAI do `dia_anterior` está fechado agora — ver `_recordes`.
	_registrar_dia(dia_anterior, _recordes)
	dia_anterior = dia_atual.duplicate()
	dia_atual = DIA_ZERADO.duplicate()

	# O dia fechado usa o porto que existia durante ele, inclusive salários
	# e renda semanal. A obra só libera benefícios para o dia que vai abrir.
	# Também conclui no vencimento: decidir a dívida não acrescenta um dia.
	_concluir_obra_se_pronta()
	_contar_dia_da_meta()

	if venceu_hoje and not parcela_paid:
		_set_phase(ESTADO_COBRANCA)
		debt_due.emit(principal_da_parcela())
		save_game()
		return
	if venceu_hoje:
		_seguir_cobranca()

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


func _process_week_end(ended_week: int, adiar_resumo: bool = false) -> void:
	var custos := _custos_da_semana()
	var pier_income: int = int(custos["pier"])
	var salarios: int = int(custos["salarios"])
	var cost := salarios + int(custos["manutencao"])
	cash += pier_income
	cash -= cost
	metrics["pier_income"] = int(metrics.get("pier_income", 0)) + pier_income
	cash_changed.emit(cash)
	message.emit("Semana %d encerrada — +%s do aluguel do píer, -%s em custos (salários + manutenção)." % [ended_week, moeda(pier_income), moeda(cost)], "warn", "semana")

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
	if adiar_resumo:
		return
	_fechar_resumo_da_semana(ended_week)


# Separado da cobrança dos custos porque a última semana para entre as duas
# metades: os custos já saíram, o Sr. Ribeiro recebe a parcela e só então o
# boletim pode fotografar e zerar a semana.
func _fechar_resumo_da_semana(ended_week: int) -> void:
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
		+ int(semana_atual["parcela"]) + int(semana_atual["cancelamento"]) + int(semana_atual["lojas"])
	var media := 0.0
	for r in historico_semanas:
		media += float(r)
	if historico_semanas.size() > 0:
		media /= float(historico_semanas.size())
	return {
		"semana": semana,
		# A fase da semana, que o boletim lê para o «de 12»: o da semana 12
		# abre já na Fase 2, atrás da página do diário (`104`).
		"numero_da_fase": numero_da_fase,
		"docagens": int(semana_atual["docagens"]),
		"armazem": int(semana_atual["armazem"]),
		"patio": int(semana_atual["patio"]),
		"pier": int(semana_atual["pier"]),
		"salarios": int(semana_atual["salarios"]),
		"manutencao": int(semana_atual["manutencao"]),
		"parcela": int(semana_atual["parcela"]),
		"cancelamento": int(semana_atual["cancelamento"]),
		"lojas": int(semana_atual["lojas"]),
		# Fora do resultado, de propósito: ver `SEMANA_ZERADA`.
		"emprestimo": int(semana_atual["emprestimo"]),
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


# O resultado de um dia fechado — a MESMA conta do painel do dinheiro e do
# boletim: o que entrou menos o que saiu, parcela incluída.
static func resultado_do_dia(dia: Dictionary) -> int:
	var receita: int = int(dia["docagens"]) + int(dia["armazem"]) \
		+ int(dia["patio"]) + int(dia["pier"])
	var despesa: int = int(dia["salarios"]) + int(dia["manutencao"]) + int(dia["parcela"]) + int(dia.get("cancelamento", 0)) + int(dia.get("lojas", 0))
	return receita - despesa


# Dobra um dia FECHADO nos recordes de `alvo`. Estrito (`>`): no empate fica o
# dia mais antigo, que foi quem o fez primeiro.
func _registrar_dia(dia: Dictionary, alvo: Dictionary) -> void:
	var t := int(dia["turno"])
	if t <= 0:
		return
	var resultado := resultado_do_dia(dia)
	if int(alvo["melhor_dia"]["turno"]) == 0 or resultado > int(alvo["melhor_dia"]["valor"]):
		alvo["melhor_dia"] = {"valor": resultado, "turno": t}
	var n := int(dia["servidos"])
	if n > int(alvo["mais_barcos"]["n"]):
		alvo["mais_barcos"] = {"n": n, "turno": t}


func _registrar_negocio(valor: int, barco: Dictionary) -> void:
	if int(_recordes["maior_negocio"]["turno"]) == 0 \
			or valor > int(_recordes["maior_negocio"]["valor"]):
		_recordes["maior_negocio"] = {"valor": valor, "turno": turn,
			"motivo": String(barco["motivo"]), "classe": String(barco["classe"])}


## OS RECORDES COMO O JOGADOR OS LÊ: os guardados mais o `dia_anterior` VIVO
## (ver `_recordes`), e a melhor semana tirada do `historico_semanas`. Devolve
## cópia — quem lê não escreve.
func recordes() -> Dictionary:
	var r: Dictionary = _recordes.duplicate(true)
	_registrar_dia(dia_anterior, r)
	r["melhor_semana"] = {"valor": 0, "semana": 0}
	for i in range(historico_semanas.size()):
		var v := int(historico_semanas[i])
		if int(r["melhor_semana"]["semana"]) == 0 or v > int(r["melhor_semana"]["valor"]):
			r["melhor_semana"] = {"valor": v, "semana": i + 1}
	return r


## QUANTO A DOCA `i` VAI PAGAR quando o barco dela acabar — o bruto (ou o
## preço fechado com o rival) mais o bónus da estrutura, pelo MESMO
## `_lancar_receita()` que o `advance_turn()` usa, num dicionário de rascunho.
## Zero se a doca estiver vazia. Não diz SE vai pagar: sem trabalhador, o
## barco sai no fim do dia.
func receita_da_doca(i: int) -> int:
	var barco = docks[i]["boat"]
	if barco == null:
		return 0
	return _lancar_receita(DIA_ZERADO.duplicate(), _valor_do_barco(i), String(barco["motivo"]))


func projecao_do_dia() -> Dictionary:
	var proj: Dictionary = DIA_ZERADO.duplicate()
	# Já saiu do caixa hoje; aparece no resultado, sem nova cobrança no fecho.
	proj["cancelamento"] = dia_atual["cancelamento"]
	proj["lojas"] = dia_atual["lojas"]
	proj["perdidos"] = dia_atual["perdidos"]
	proj["turno"] = turn
	if phase != ESTADO_JOGANDO:
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
	# E O QUE SAI DO LARGO HOJE (`083`): o barco com um dia de paciência que
	# não atracar vai para o Porto Farol na virada — é o mesmo «perdido» que o
	# `advance_turn()` conta, lido antes de acontecer.
	for barco in fila:
		if int(barco["paciencia"]) <= 1:
			proj["perdidos"] += 1
	# O fecho de semana e a parcela caem no MESMO dia que fariam cair no jogo
	# real — usar `_custos_da_semana()` em vez de repetir a conta é a mesma
	# razão que fez ela existir: uma só fonte para o número que o caixa muda
	# e o número que a projeção mostra.
	if turn % TURNS_PER_WEEK == 0:
		var custos := _custos_da_semana()
		proj["pier"] = int(custos["pier"])
		proj["salarios"] = int(custos["salarios"])
		proj["manutencao"] = int(custos["manutencao"])
	if tem_cobranca() and turn == vencimento_da_parcela() and not parcela_paid:
		proj["parcela"] = principal_da_parcela()
	return proj


func _check_end() -> void:
	if cash < 0:
		_end_game(false, "O dinheiro acabou. Operação inviável.")
		return
	# A FASE SEM PRAZO não acaba por calendário (`103`): perde-se só pelo
	# caixa, logo acima.
	if fase_tem_prazo() and turn > ultimo_dia_da_fase():
		var quitou := parcelas_quitadas == parcelas_na_fase()
		if not quitou:
			_end_game(false, "Prazo encerrado com parcela em aberto.")
			return
		# A ÚLTIMA DA TABELA com prazo ainda acaba em vitória — hoje nenhuma o
		# é, porque a Fase 2 não tem prazo; a regra fica para não ser preciso
		# lembrá-la no dia em que a tabela crescer.
		if numero_da_fase >= FASES.size():
			_end_game(true, MOTIVO_DA_FASE_1)
			return
		_passar_de_fase(MOTIVO_DA_FASE_1)
	# A quebra tem prioridade sobre a conquista no mesmo fecho. A página é
	# overlay; marcar ANTES do sinal impede repeti-la por uma chamada reentrante.
	if numero_da_fase == 2 and not meta_concluida:
		var meta := progresso_da_meta()
		if meta["dias"] == meta["dias_alvo"] and meta["infra"] == meta["infra_alvo"] and primeiro_cargueiro:
			meta_concluida = true
			fase_concluida.emit(2, "O porto cumpriu a meta da Fase 2. O trabalho continua.")
	meta_atualizada.emit()
	_spawn_boats()


# A frase do balanço de quem fecha a Fase 1. Era o motivo do fim de jogo; desde
# a `104` é o da passagem, e o «três» é o da Fase 1 de sempre.
const MOTIVO_DA_FASE_1 := "Você quitou as três parcelas e manteve o porto no azul!"


# A PASSAGEM (`103`, `104`): a fase em jogo fecha e a partida segue na seguinte,
# no mesmo dia e no mesmo save. O turno NÃO pára — quem abre a página do diário
# é o `Main`, por cima do jogo, ao ouvir `fase_concluida`; o simulador e as
# ferramentas que medem a Fase 1 param aqui por esse sinal.
#
# O que recomeça é o que a `FASES` diz que é DE CADA FASE: a cobrança (a
# Fase 2 não tem nenhuma, e o recibo da 1 já está no `total_pago_parcelas`), a
# segunda chance (uma por fase, `102`) e a reputação, que recomeça na escala
# da fase nova (D4). O porto, o caixa, a fila e o calendário seguem como estão.
#
# ⚠️ O SINAL SAI ANTES DE A FASE MUDAR, e é a única ordem que serve a quem o
# ouve: o simulador mede a Fase 1 e lê a reputação com que ela FECHOU, e o
# balanço do diário mostra-a. Emitido depois, os dois leriam a da Fase 2,
# acabada de recomeçar — sem erro nenhum, e com a paridade do simulador a
# denunciar só a média.
func _passar_de_fase(motivo: String) -> void:
	var concluida := numero_da_fase
	fase_concluida.emit(concluida, motivo)
	numero_da_fase += 1
	dias_de_reputacao = 0
	primeiro_cargueiro = false
	meta_concluida = false
	parcela_indice = 0
	parcela_paid = false
	parcelas_quitadas = 0
	# Já é zero: a dívida da segunda chance vence com a cobrança seguinte, e a
	# última de uma fase não a admite. Escrito para o estado novo não depender
	# dessa regra estar de pé.
	emprestimo_devido = 0
	segunda_chance_usada = false
	reputation = reputacao_inicial()
	reputation_changed.emit(reputation)


func _end_game(did_win: bool, reason: String) -> void:
	won = did_win
	end_reason = reason
	_set_phase(ESTADO_FIM)
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
	if phase != ESTADO_COBRANCA:
		return
	if cash < principal_da_parcela():
		message.emit("Dinheiro insuficiente para pagar a parcela.", "bad", "dinheiro")
		return
	# `advance_turn()` já fez a virada do dia antes de suspender em
	# "debt_payment", então o dia em que a dívida venceu é `dia_anterior` —
	# não `dia_atual`, que já é o dia seguinte, ainda por jogar.
	# O PRINCIPAL INTEIRO: aqui não há antecipação nenhuma para descontar.
	_baixar_parcela(dia_anterior, principal_da_parcela())
	_retomar_depois_da_cobranca()


# O que vem depois de o boleto do vencimento ser pago, pelas duas portas que
# o pagam (`pay_debt()` e `aceitar_segunda_chance()`). Uma cópia em cada uma
# divergiria no dia em que uma ganhasse uma linha — ver o `_baixar_parcela()`.
func _retomar_depois_da_cobranca() -> void:
	# O fecho da semana da cobrança ficou de propósito à espera desta decisão: antes
	# daqui o resumo esconderia a maior despesa da semana e inflaria o resultado
	# exatamente pelo valor da parcela.
	_fechar_resumo_da_semana(week_of(turn - 1))
	_seguir_cobranca()
	_set_phase(ESTADO_JOGANDO)
	turn_advanced.emit(turn, current_week())
	_check_end()
	save_game()


# ── A SEGUNDA CHANCE (`docs/decisoes/102`) ──
#
# A TERCEIRA PORTA DO VENCIMENTO, ao lado de pagar e de não poder. Só abre a
# quem não tem o boleto, uma vez por fase, e onde houver cobrança seguinte
# para a devolver — na última da fase não há, e a Fase 2 não tem cobrança
# nenhuma (`104`).
func pode_pedir_segunda_chance() -> bool:
	return phase == ESTADO_COBRANCA and cash < principal_da_parcela() \
		and not segunda_chance_usada and parcela_indice < parcelas_na_fase() - 1


## O que o banco põe no caixa: o que falta para o boleto e mais uma semana de
## custos — salários e manutenção da semana que abre, pela MESMA conta do fecho
## (`_custos_da_semana()`). Depois de pagar, o jogador fica exatamente com essa
## semana na mão. Com o caixa negativo (o fecho da semana pode tê-lo posto
## abaixo de zero antes da cobrança), o que falta é maior, e a conta é a mesma.
func emprestimo_da_segunda_chance() -> int:
	var custos := _custos_da_semana()
	var semana := int(custos["salarios"]) + int(custos["manutencao"])
	return principal_da_parcela() - cash + semana


## O que se devolve com a cobrança seguinte: o emprestado e o acréscimo fixo.
func devolucao_da_segunda_chance() -> int:
	return int(round(emprestimo_da_segunda_chance() * (1.0 + SEGUNDA_CHANCE_ACRESCIMO)))


func aceitar_segunda_chance() -> bool:
	if not pode_pedir_segunda_chance():
		return false
	var emprestado := emprestimo_da_segunda_chance()
	var devolver := devolucao_da_segunda_chance()
	# O dinheiro do banco entra ANTES de o boleto sair, e o boleto sai pela
	# porta de sempre, com o valor de sempre: o recibo, a contabilidade e a
	# cobrança seguinte não sabem que houve empréstimo, e não precisam.
	cash += emprestado
	semana_atual["emprestimo"] += emprestado
	segunda_chance_usada = true
	_baixar_parcela(dia_anterior, principal_da_parcela())
	# DEPOIS do `_baixar_parcela()`, que zera a dívida que paga: escrito antes,
	# o empréstimo seria quitado no mesmo instante em que nasce.
	emprestimo_devido = devolver
	segunda_chance_aceita.emit(emprestado, devolver)
	message.emit("O Sr. Ribeiro cobriu a parcela. Na próxima cobrança, mais %s."
		% moeda(devolver), "warn", "dinheiro")
	_retomar_depois_da_cobranca()
	return true


# ── QUITAR ANTES DO PRAZO — item 24, `docs/decisoes/019` ──
## O DESCONTO DE UMA DÍVIDA QUITADA ANTES DO PRAZO, em dinheiro.
##
## ⚠️ RECEBE O PRINCIPAL E O PRAZO EM VEZ DE OS IR BUSCAR À PARCELA, e isso é
## pedido e não gosto: o empréstimo bancário da Fase 2 vai querer esta mesma
## conta com outro principal e outro prazo, e uma versão que leia a parcela
## da fase por dentro teria de ser copiada para lá — que é como duas
## contas da mesma coisa começam a divergir neste arquivo (ver o
## `_custos_da_semana()`, que existe separado exatamente por isso).
##
## ⚠️ O PISO EM ZERO VIVE AQUI E SÓ AQUI. A primeira versão clampava também no
## sítio que conta os turnos, e duas guardas iguais sobre a mesma coisa é
## exatamente a armadilha que o `CLAUDE.md` regista: com a cópia de pé, tirar
## esta não reprovava nada. Quem chama é dono do seu domínio; quem responde
## pelo dinheiro é esta linha, que nunca devolve desconto negativo — um prazo
## já vencido não pode ENCARECER a dívida.
func desconto_por_antecipacao(principal: int, turnos: int) -> int:
	return int(round(principal * JUROS_POR_TURNO * maxi(turnos, 0)))


## O que a parcela custa SE for quitada agora. O jogador vê este número no
## painel. Neste crédito inicial o abatimento é proporcional aos juros da
## janela. A fórmula antiga sobre todo o boleto podia devolver menos que os
## R$400 mil emprestados; o cálculo genérico acima continua separado para
## contratos futuros, que ainda precisam definir seus próprios encargos.
##
## A JANELA é o período desta parcela: do vencimento da anterior (ou do começo
## da fase) ao dela. Até a `094` eram os `PARCELA_DUE_TURN` dias de todas, o
## que dava o mesmo enquanto as três janelas tinham quatro semanas; uma fase
## com janelas desiguais abateria pela janela errada sem erro nenhum.
func valor_da_parcela_hoje() -> int:
	var juros := juros_da_parcela(parcela_indice)
	var abre := dia_da_parcela(parcela_indice - 1) if parcela_indice > 0 else 0
	var janela := vencimento_da_parcela() - abre
	var dias := clampi(vencimento_da_parcela() - turn, 0, janela)
	var abatimento := int(round(float(juros) * dias / janela))
	return principal_da_parcela() - abatimento


func principal_da_parcela() -> int:
	# Nome legado: este é o valor nominal do boleto, incluindo juros — e o
	# empréstimo da segunda chance, que vence com ele (`102`). Somado aqui, e
	# não em quem lê, para o HUD, o painel, a projeção do dia, o vencimento e o
	# simulador pedirem o mesmo número; o abatimento do `valor_da_parcela_hoje()`
	# sai só dos juros da janela, e o acréscimo fixo do empréstimo não se abate.
	return valor_da_parcela(parcela_indice) + emprestimo_devido


func vencimento_da_parcela() -> int:
	return dia_da_parcela(parcela_indice)


# Só o fecho do período muda a parcela. O recibo antecipado fica visível
# até lá, sem permitir gastar a cobrança seguinte duas vezes no mesmo dia.
func _seguir_cobranca() -> void:
	if parcela_paid and parcela_indice < parcelas_na_fase() - 1:
		parcela_indice += 1
		parcela_paid = false


func pode_pagar_parcela_adiantado() -> bool:
	# Contra o valor COM desconto, não contra o principal: o abatimento também
	# abre a porta mais cedo, e fechá-la no número cheio mostraria um preço que
	# o jogador não consegue pagar.
	return phase == ESTADO_JOGANDO and tem_cobranca() and not parcela_paid \
		and cash >= valor_da_parcela_hoje()


# Pagar ANTES do prazo — item do primeiro playtest ("pode haver a opção de
# pagar a dívida antes do tempo").
#
# O VALOR SAI MAIS BARATO QUANTO MAIS CEDO SE PAGA, desde 12/09 — item 24 do
# segundo playtest, decidido em `docs/decisoes/019`. Até aí era o principal
# cheio, e o comentário aqui dizia que um desconto "mexeria na economia
# medida": MEDIDO, não mexe. Os três perfis antigos nunca passam por esta
# porta, e o quarto (Antecipado) quita no turno 30 de 32, onde o desconto vale
# 0,5% — a janela é que quase não existe, não o efeito.
#
# O que se ganha continua a ser sobretudo deixar de carregar a dívida, e a
# escolha continua a ser uma escolha: o mesmo caixa também compra estrutura.
func pagar_parcela_adiantado() -> bool:
	if not pode_pagar_parcela_adiantado():
		return false
	# Aqui é o INVERSO do `pay_debt()`: o dia em curso ainda não foi jogado,
	# então a parcela cai em `dia_atual` — que vira `dia_anterior` na próxima
	# virada, e é lá que o resumo do dia a vai mostrar.
	_baixar_parcela(dia_atual, valor_da_parcela_hoje())
	roster_changed.emit()
	save_game()
	return true


# O VALOR VEM DE FORA porque as duas portas pagam quantias diferentes: no
# vencimento sai o principal inteiro, antecipado sai o principal menos o juro
# que o banco deixa de correr. Derivá-lo aqui dentro obrigaria esta função a
# saber por que porta entrou, que é precisamente o que o argumento evita.
func _baixar_parcela(no_dia: Dictionary, valor: int) -> void:
	cash -= valor
	# Só para o Boletim. A parcela vence no fecho do período, então cai na
	# semana em curso — que é onde o jogador espera vê-la, porque foi essa a
	# semana em que o dinheiro saiu.
	semana_atual["parcela"] += valor
	no_dia["parcela"] += valor
	parcela_paid = true
	parcelas_quitadas += 1
	total_pago_parcelas += valor
	# O valor que entra aqui é o `principal_da_parcela()` ou o de hoje, e os dois
	# já trazem o empréstimo: pago o boleto, pago o empréstimo.
	emprestimo_devido = 0
	cash_changed.emit(cash)
	message.emit("Parcela de %s paga ao Sr. Ribeiro." % moeda(valor), "good", "dinheiro")


func fail_debt() -> void:
	# RECUSAR TAMBÉM É DECIDIR, e o fecho da semana 4 estava à espera de uma
	# decisão — não de um pagamento. Sem esta metade o adiamento do
	# `_process_week_end()` fica órfão no caminho da derrota: a semana nunca
	# fecha, o boletim nunca abre e `semana_atual` vai para o fim da partida
	# com meia semana dentro. Medido em 12/09: `historico_semanas` acabava com
	# TRÊS entradas em vez de quatro, e nenhuma suíte perguntava.
	#
	# A fase é a guarda exata, e não uma aproximação: "debt_payment" só se
	# escreve no mesmo ramo que adia o resumo, com a mesma condição. Ela também
	# torna esta função idempotente — a segunda chamada já encontra "game_over".
	if phase == ESTADO_COBRANCA:
		_fechar_resumo_da_semana(week_of(turn - 1))
	_end_game(false, "Não foi possível pagar a parcela ao Sr. Ribeiro. Porto perdido.")


# ── UPGRADE (ampliar píer) ──
func tem_estrutura(id: String) -> bool:
	return estruturas.has(id)


## O NÍVEL DO PORTO, de 1 a 3 — quanto dele já foi levantado.
##
## O píer lê as estruturas; o guindaste lê seu equipamento, separadamente.
## Os reparos da Fase 1 não compram um guindaste novo (`086`). O aparelho
## de madeira permanece a Fase 1 inteira; a treliça é compra da Fase 2, na
## etapa 2 da `103`. A arte e
## o pórtico futuro continuam exercitados pelas bancadas. Seu nível intermediário é montagem efêmera,
## restrita a --script; não é um campo do jogador nem entra no save.
func nivel_pier() -> int:
	if tem_estrutura("cais"):
		return 3
	return 2 if estruturas.size() >= 2 else 1


func nivel_guindaste() -> int:
	if tem_estrutura("guindaste"):
		return 3
	if tem_estrutura("trelica"):
		return 2
	if ArmazemLocal.sob_ferramenta() and has_meta(&"guindaste_intermediario_da_bancada"):
		return 2
	return 1


# Uma bancada anterior não altera a próxima partida nem um save retomado.
func _limpar_guindaste_da_bancada() -> void:
	if has_meta(&"guindaste_intermediario_da_bancada"):
		remove_meta(&"guindaste_intermediario_da_bancada")


# Por que não dá para comprar: "" quando dá. O painel mostra este texto, então
# o jogador nunca fica com um botão apagado sem explicação.
func impedimento_estrutura(id: String) -> String:
	if not ESTRUTURAS.has(id):
		return "Estrutura desconhecida."
	if tem_estrutura(id):
		return "Já construída."
	if phase != ESTADO_JOGANDO:
		return "Resolva o que está na tela primeiro."
	var bloqueio := desbloqueio_da_estrutura(id)
	if bloqueio != "":
		return bloqueio
	if not obra_em_andamento.is_empty():
		return "Conclua a obra em andamento primeiro."
	if not obra_termina_na_fase(id):
		return "Não termina nesta fase."
	var def: Dictionary = ESTRUTURAS[id]
	var requer := String(def["requer"])
	if requer != "" and not tem_estrutura(requer):
		return "Precisa antes de: %s." % ESTRUTURAS[requer]["nome"]
	if cash < int(def["custo"]):
		return "Faltam %s." % moeda(int(def["custo"]) - int(cash))
	return ""


# EM QUE DIA CADA REPARO DA FASE ABRE, e com quantas cobranças quitadas — num
# lugar só (`089`). Leem daqui as duas pontas da regra: o
# `desbloqueio_da_estrutura()`, que decide o botão do Construir, e o
# `_save_aceite()`, que recusa a obra começada antes de o reparo abrir. Até
# 10/10 o save escrevia `8` e `29` à mão enquanto o botão os tirava da semana e
# do vencimento: coincidiam, e mudar o `TURNS_PER_WEEK` ou o prazo da cobrança
# faria o jogo recusar saves válidos sem erro nenhum. Medido: um save que
# abrisse o armazém no dia 9 passava as seis suítes. O T17 tranca-o.
#
# Desde a `094` a SEMANA vem da tabela `FASES`, e o dia é o primeiro dela. O
# pátio dizia «o dia seguinte ao vencimento da primeira cobrança», que é o
# primeiro da semana 5 enquanto a cobrança vencer na 4: quem mudar uma escreve
# a outra, porque a tabela diz as duas.
#
# `{}` para o que não se compra nesta fase.
#
# Desde a `104` a semana conta-se desde o INÍCIO da fase, que na Fase 2 é o dia
# 85: o reparo dela «na semana 1» abre no primeiro dia dela, e não no dia 1 da
# partida. O `n` é o do `dados_da_fase()` — o save confere a obra contra a fase
# do arquivo.
func abertura_do_reparo(id: String, n: int = 0) -> Dictionary:
	var reparos: Dictionary = dados_da_fase(n)["reparos"]
	if not reparos.has(id):
		return {}
	var r: Dictionary = reparos[id]
	return {"dia": inicio_da_fase(n) + (int(r["semana"]) - 1) * TURNS_PER_WEEK,
		"quitadas": int(r["quitadas"])}


# A Fase 1 recupera o porto pequeno. O catálogo e a arte do porto completo
# continuam disponíveis às bancadas; compra pelo jogador respeita este limite.
# ⚠️ O texto do pátio diz «primeira» porque a abertura pede UMA quitada; quem
# subir esse número escreve outra frase — e o F20 reprova a tabela que peça
# mais de uma enquanto ela não for escrita.
func desbloqueio_da_estrutura(id: String) -> String:
	var abre := abertura_do_reparo(id)
	if abre.is_empty():
		return "Disponível nas próximas fases."
	var dia := int(abre["dia"])
	if int(abre["quitadas"]) > 0 and (turn < dia or parcelas_quitadas < int(abre["quitadas"])):
		return "Abre após a primeira cobrança paga."
	if turn < dia:
		return "Abre na semana %d." % week_of(dia)
	return ""


func comprar_estrutura(id: String) -> bool:
	if impedimento_estrutura(id) != "":
		return false
	var def: Dictionary = ESTRUTURAS[id]
	var conclusao := turn + dias_da_obra(id)
	cash -= int(def["custo"])
	obra_em_andamento = {"id": id, "inicio": turn, "conclusao": conclusao}
	cash_changed.emit(cash)
	estrutura_comprada.emit(id)
	# A obra sem uso na fase AVISA, e o aviso tem o `kind` dele: é o que pinta
	# a faixa de âmbar e toca o som de aviso, em vez do verde de quem comprou
	# bem (`090`).
	message.emit("%s — obra iniciada. %s; %s." % [def["nome"],
		Narrativa.concordar(dias_da_obra(id), "dia", "dias"), prazo_da_obra(conclusao)],
		"warn" if obra_sem_uso_na_fase(conclusao) else "good", "obra")
	save_game()
	return true


# Zero para o que esta fase não constrói — o painel pergunta por todas as
# estruturas, e as que não abrem não têm prazo a mostrar.
func dias_da_obra(id: String, n: int = 0) -> int:
	var reparos: Dictionary = dados_da_fase(n)["reparos"]
	return int(reparos[id]["dias_de_obra"]) if reparos.has(id) else 0


# A OBRA QUE, COMEÇADA HOJE, AINDA ACABA NESTA FASE — contando com o fecho do
# último dia, que a `087` aceita. Num lugar só porque são dois os leitores: o
# `impedimento_estrutura()`, que decide o botão do Construir, e o rodapé do
# `Main`, que conta os reparos «disponíveis». Até 10/10 o rodapé contava só o
# que o calendário abria e dizia «3 disponíveis» no dia 84, com o painel a
# responder «Não termina nesta fase.» aos três (O7, `090`).
#
# Na fase sem prazo toda obra acaba nela (`104`).
func obra_termina_na_fase(id: String) -> bool:
	return not fase_tem_prazo() or turn + dias_da_obra(id) <= ultimo_dia_da_fase() + 1


# A OBRA QUE SÓ FICA PRONTA NO FECHO DO ÚLTIMO DIA. A `087` aceita-a — o limite
# do `impedimento_estrutura()` é `turnos_da_fase() + 1` —, e o dia em que ela abre
# não existe nesta fase: a mensagem dizia «pronto no dia 85» numa fase de 84, e
# o jogador pagava por um porto que não chegava a usar. O Bruno respondeu ao D8
# em 10/10: AVISAR, e não recusar (`090`). E disse porquê é só «por enquanto»:
# no futuro o jogo terá anos de 365 dias, e uma obra assim passa simplesmente
# para o dia seguinte. Quando o calendário deixar de acabar, esta função
# deixa de ter razão de ser — não se lhe acrescenta um caso.
#
# ⚠️ E A FASE 2 É ESSE CALENDÁRIO, e a meio caminho (`104`): ela não acaba,
# logo nunca avisa. Na Fase 1 o aviso continua verdadeiro — a obra não serve à
# Fase 1 —, e quem paga a terceira parcela usa-a no dia 85, na Fase 2.
func obra_sem_uso_na_fase(conclusao: int) -> bool:
	return fase_tem_prazo() and conclusao > ultimo_dia_da_fase()


# O PRAZO DA OBRA COMO O JOGADOR O LÊ, num lugar só: a mensagem da compra e os
# dois estados do Construir (antes de comprar e com a obra a andar) leem
# daqui (`090`). `conclusao` é o dia que ABRE com a obra pronta; o da obra sem
# uso não existe, e o texto nomeia o último que existe. O número sai da
# constante, e é masculino porque as três estruturas que se compram — píer,
# armazém e pátio — o são.
func prazo_da_obra(conclusao: int) -> String:
	if obra_sem_uso_na_fase(conclusao):
		return prazo_curto_da_obra(conclusao) + ", e não será usado nesta fase"
	return prazo_curto_da_obra(conclusao)


# O MESMO PRAZO SEM O AVISO, para o cartão da doca em obra (`121`): o cartão
# tem 200 px e a frase inteira não cabe. O aviso já foi dito na compra e
# continua no Construir; o cartão diz só QUANDO.
func prazo_curto_da_obra(conclusao: int) -> String:
	if obra_sem_uso_na_fase(conclusao):
		return "pronto só no fim do dia %d" % ultimo_dia_da_fase()
	return "pronto no dia %d" % conclusao


func dias_restantes_da_obra() -> int:
	if obra_em_andamento.is_empty():
		return 0
	return maxi(0, int(obra_em_andamento["conclusao"]) - turn)


## A estrutura que levanta a vaga de índice `doca`: a 1 é o `pier_2`, a 2 o
## `pier_3` — o número do catálogo é o da doca a contar de 1 (`121`). É a
## ordem em que o `_concluir_obra_se_pronta()` acrescenta as docas, e são
## dois os leitores (a vaga no mapa e o cartão), por isso vive aqui.
func id_do_pier(doca: int) -> String:
	return "pier_%d" % (doca + 1)


## O QUADRO DA OBRA QUE O MAPA DESENHA, de 0 a `quadros − 1`; −1 quando
## `id` não está em obra (`121`). Num lugar só porque são três os leitores —
## o píer no `Dock`, o armazém e o pátio no `ObraNoMapa` — e o D45 confere, dia
## a dia, o quadro que os três mostram na cena.
##
## Conta o dia JOGADO e não o de calendário: a obra comprada no dia 1 com
## dois dias mostra o quadro 0 no dia 1 e o 1 no dia 2, e no dia 3 já está
## pronta. Com tantos quadros quantos dias é o dia da obra; com menos, os
## dias repartem-se pelos quadros — o píer 3 da Fase 2 leva TRÊS dias
## na tabela `FASES` e o píer tem dois quadros, e um índice cru passaria do fim da
## lista no terceiro dia.
##
## ⚠️ O PRAZO SAI DA OBRA GRAVADA, e não do `dias_da_obra()` de hoje: uma
## obra começada antes de um ajuste de prazo acaba no dia que ficou no save
## (`conclusao`), e o último quadro tem de calhar no último dia dela.
func quadro_da_obra(id: String, quadros: int) -> int:
	if obra_em_andamento.is_empty() or String(obra_em_andamento["id"]) != id:
		return -1
	var inicio := int(obra_em_andamento["inicio"])
	var total := maxi(1, int(obra_em_andamento["conclusao"]) - inicio)
	var dia := clampi(turn - inicio, 0, total - 1)
	return dia * quadros / total


func _concluir_obra_se_pronta() -> void:
	if obra_em_andamento.is_empty() or dias_restantes_da_obra() > 0:
		return
	var id := String(obra_em_andamento["id"])
	var def: Dictionary = ESTRUTURAS[id]
	obra_em_andamento = {}
	estruturas.append(id)

	# Os píeres são os únicos que mexem no roster. O resto é econômico e age
	# nos lugares onde o dinheiro é contado (ver _lancar_receita e
	# _process_week_end).
	if id == "pier_2" or id == "pier_3":
		# Doca que o mapa não desenha é doca invisível: recebe barco, o barco
		# vai embora sem trabalhador e o jogador nunca vê por quê. E o
		# trabalhador SÓ ENTRA COM A DOCA — quando o teto barrava a doca e o
		# trabalhador vinha assim mesmo, sobrava gente na fileira sem lugar
		# nenhum para trabalhar, que é como um "#4" fantasma nasceria de novo.
		var abertas := 0
		for i in range(UPGRADE_EXTRA_DOCKS):
			if docks.size() >= bercos_no_mapa():
				break
			docks.append({"boat": null, "worker_id": null})
			abertas += 1
		for i in range(abertas * UPGRADE_EXTRA_WORKERS):
			workers.append(novo_trabalhador())

	cash_changed.emit(cash)
	roster_changed.emit()
	obra_concluida.emit(id)
	message.emit("%s — pronto. %s" % [def["nome"], def["desc"]], "good", "obra")


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
# O NÍVEL DO PORTO é o MENOR dos dois, e não a média nem o do píer sozinho:
# não adianta ter onde encostar sem ter com que descarregar, nem o contrário.
# É ele que decide que classes de navio chegam.
func nivel_do_porto() -> int:
	return mini(nivel_pier(), nivel_guindaste())


# O píer n2 continua a sair de duas estruturas QUAISQUER (`007`), mas a
# treliça agora é a compra que abre o cargueiro (`103`): requer o píer 2,
# logo sua conclusão garante também a segunda estrutura e o píer n2. Não
# basta reconstruir píeres enquanto o guindaste continua em madeira (`086`).
#
# Quem conta a regra ao jogador, então: o painel Construir, que mostra o nível
# do porto e o que cada um recebe (`UpgradePanel.gd`), a arte do píer e da
# lança, que mudam nesses mesmos degraus, e o cartão da doca, que nomeia a
# classe do navio que chegou.


# A fase permanece conquistada; só NOVAS chegadas são suspensas (`103`).
# A fila e o serviço já contratado continuam, inclusive abaixo do piso.
func cargueiros_suspensos() -> bool:
	return numero_da_fase == 2 and reputation < float(dados_da_fase()["piso_cargueiro"])


func regra_dos_cargueiros() -> String:
	if numero_da_fase != 2:
		return "A treliça e o cargueiro abrem na Fase 2."
	var piso := int(dados_da_fase()["piso_cargueiro"])
	return ("Cargueiros suspensos: recupere a reputação até %d. " % piso if cargueiros_suspensos()
		else "Abaixo de %d de reputação, novos cargueiros deixam de vir. " % piso) \
		+ "Os já contratados continuam. A fase conquistada permanece."


func progresso_da_meta() -> Dictionary:
	if numero_da_fase != 2:
		return {}
	var alvo: Dictionary = dados_da_fase()["meta"]
	var prontas := 0
	for id in alvo["infra"]:
		if tem_estrutura(id):
			prontas += 1
	return {"dias": dias_de_reputacao, "dias_alvo": int(alvo["dias"]),
		"reputacao_alvo": float(alvo["reputacao"]), "infra": prontas,
		"infra_alvo": alvo["infra"].size(), "missao": 1 if primeiro_cargueiro else 0,
		"concluida": meta_concluida, "piso": float(dados_da_fase()["piso_cargueiro"])}


func _contar_dia_da_meta() -> void:
	if numero_da_fase != 2 or meta_concluida:
		return
	var alvo: Dictionary = dados_da_fase()["meta"]
	if reputation >= float(alvo["reputacao"]):
		dias_de_reputacao = mini(dias_de_reputacao + 1, int(alvo["dias"]))
	else:
		dias_de_reputacao = 0


# As classes disponíveis na ordem da tabela. Nunca volta vazia: o pesqueiro
# é de nível 1, e a reputação só suspende o cargueiro.
func classes_disponiveis() -> Array:
	var nivel := nivel_do_porto()
	var out: Array = []
	for id in CLASSES_DE_NAVIO:
		if id == "medio" and cargueiros_suspensos():
			continue
		if int(CLASSES_DE_NAVIO[id]["nivel"]) <= nivel:
			out.append(id)
	return out


# Sorteio por PESO entre as classes disponíveis. Os pesos são os da tabela e
# não se renormalizam à mão: tirar uma classe da lista redistribui sozinho o
# peso dela pelas que ficam, que é o que faz o porto em ruínas ver só
# pesqueiro sem nenhum número escrito para esse caso.
func _sortear_classe() -> String:
	var disponiveis := classes_disponiveis()
	var total := 0
	for id in disponiveis:
		total += int(CLASSES_DE_NAVIO[id]["peso"])
	var sorteio := _rng.randi_range(1, total)
	var acumulado := 0
	for id in disponiveis:
		acumulado += int(CLASSES_DE_NAVIO[id]["peso"])
		if sorteio <= acumulado:
			return String(id)
	# Inalcançável — o sorteio vai de 1 à soma dos pesos. O GDScript exige
	# retorno em todo caminho, e a classe base é a única que não inventa
	# dinheiro nem turno se algum dia se chegar aqui.
	return "pesqueiro"


# Sorteia o motivo pelos pesos DA CLASSE. Por peso e não por faixa escrita à
# mão porque a mistura tem de se ler na tabela: quem quiser saber com que
# frequência um cargueiro traz granel lê 20 ao lado dele.
func _sortear_motivo(classe: String) -> String:
	var pesos: Dictionary = CLASSES_DE_NAVIO[classe]["motivos"]
	var total := 0
	for id in pesos:
		total += int(pesos[id])
	var sorteio := _rng.randi_range(1, total)
	var acumulado := 0
	for id in pesos:
		acumulado += int(pesos[id])
		if sorteio <= acumulado:
			return String(id)
	return "pescado"


# Quantos turnos uma operação leva: o da CLASSE, mais o que o motivo pesar,
# menos o que o pórtico corta. Nunca abaixo de um — barco que descarregasse em
# zero turnos entraria e sairia no mesmo avanço de dia, sem o jogador ter o
# que fazer.
func _turnos_de_operacao(classe: String, motivo: String) -> int:
	var turnos := int(CLASSES_DE_NAVIO[classe]["turnos"]) \
		+ int(MOTIVOS[motivo]["turnos_extra"])
	if tem_estrutura("guindaste"):
		turnos -= GUINDASTE_CORTA_TURNOS
	return maxi(1, turnos)


func _make_boat() -> Dictionary:
	var classe := _sortear_classe()
	var dados: Dictionary = CLASSES_DE_NAVIO[classe]
	var value := _rng.randi_range(int(dados["valor_min"]), int(dados["valor_max"]))
	var motivo := _sortear_motivo(classe)
	_uid += 1
	return {
		"id": _uid,
		"value": value,
		"classe": classe,
		"motivo": motivo,
		"op_turns": _turnos_de_operacao(classe, motivo),
		"progress": 0,
		"rival": false,
		"matched": false,
		"matched_value": 0,
		"paciencia": PACIENCIA_FILA,
	}


func _spawn_boats() -> void:
	# Os barcos chegam ao LARGO, e não à doca (`083`): cada lugar vazio da fila
	# tem a sua chance. A doca só recebe barco quando o jogador o escolhe.
	var chegados: Array = []
	var vagas := FILA_LUGARES - fila.size()
	for i in range(vagas):
		if _rng.randf() > BOAT_ARRIVAL_CHANCE:
			continue
		fila.append(_make_boat())
		chegados.append(fila.size() - 1)
	if chegados.is_empty():
		return
	boats_spawned.emit()
	fila_mudou.emit()

	# No máximo 1 oferta do rival (Arlindo) por turno, sobre um dos barcos que
	# acabaram de chegar: ele disputa o cliente ANTES de ele encostar.
	if _rng.randf() < RIVAL_TRIGGER_CHANCE:
		var idx: int = chegados[_rng.randi_range(0, chegados.size() - 1)]
		fila[idx]["rival"] = true
		pending_rival = idx
		rival_attempts_left = RIVAL_PATIENCE
		_set_phase(ESTADO_OFERTA)
		rival_offer_triggered.emit(idx)


func _change_reputation(delta: float) -> void:
	reputation = clamp(reputation + delta, 0.0, 100.0)
	reputation_changed.emit(reputation)


func reputation_label() -> String:
	return rotulo_da_reputacao(reputation)


# A faixa de um valor de reputação qualquer — o balanço da Fase 1 mostra a
# reputação com que ela FECHOU, e a viva já recomeçou na Fase 2 (`104`).
static func rotulo_da_reputacao(valor: float) -> String:
	if valor >= 81.0:
		return "Referência"
	elif valor >= 61.0:
		return "Respeitado"
	elif valor >= 41.0:
		return "Confiável"
	elif valor >= 21.0:
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
		"numero_da_fase": numero_da_fase,
		"dias_de_reputacao": dias_de_reputacao,
		"primeiro_cargueiro": primeiro_cargueiro,
		"meta_concluida": meta_concluida,
		"estruturas": estruturas,
		"obra_em_andamento": obra_em_andamento,
		"parcela_paid": parcela_paid,
		"parcela_indice": parcela_indice,
		"parcelas_quitadas": parcelas_quitadas,
		"total_pago_parcelas": total_pago_parcelas,
		"emprestimo_devido": emprestimo_devido,
		"segunda_chance_usada": segunda_chance_usada,
		"phase": phase,
		"fila": fila,
		"pending_rival": pending_rival,
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
		"recordes": _recordes,
		"vida_do_porto": vida_do_porto,
	}
	var file := FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()


func load_game() -> bool:
	if not FileAccess.file_exists(save_path):
		return false
	var file := FileAccess.open(save_path, FileAccess.READ)
	if not file:
		return false
	var text := file.get_as_text()
	file.close()
	var parsed := _save_aceite(text)
	if parsed.is_empty():
		clear_save()
		return false

	_limpar_guindaste_da_bancada()
	vida_do_porto = parsed["vida_do_porto"].duplicate(true)
	turn = int(parsed.get("turn", 1))
	cash = int(parsed.get("cash", START_CASH))
	# A fase ANTES da reputação, que lê dela o padrão. Acesso direto: o
	# `_save_aceite()` já exigiu o campo, e na fase certa.
	numero_da_fase = int(parsed["numero_da_fase"])
	dias_de_reputacao = int(parsed["dias_de_reputacao"])
	primeiro_cargueiro = bool(parsed["primeiro_cargueiro"])
	meta_concluida = bool(parsed["meta_concluida"])
	reputation = float(parsed.get("reputation", reputacao_inicial()))
	docks = parsed["docks"]
	workers = parsed["workers"]
	estruturas = parsed.get("estruturas", [])
	# O JSON devolve float, e até 10/10 a obra ficava assim no estado vivo (O6
	# da revisão de 09/10): funcionava porque toda leitura passa por `int()`, e
	# um uso futuro como chave de dicionário tropeçaria num `8.0`. O
	# `_save_aceite()` já provou que são inteiros; aqui só mudam de tipo.
	var obra_lida: Dictionary = parsed["obra_em_andamento"]
	obra_em_andamento = {}
	if not obra_lida.is_empty():
		obra_em_andamento = {"id": String(obra_lida["id"]),
			"inicio": int(obra_lida["inicio"]), "conclusao": int(obra_lida["conclusao"])}
	parcela_paid = bool(parsed.get("parcela_paid", false))
	parcela_indice = int(parsed["parcela_indice"])
	parcelas_quitadas = int(parsed["parcelas_quitadas"])
	total_pago_parcelas = int(parsed["total_pago_parcelas"])
	emprestimo_devido = int(parsed["emprestimo_devido"])
	segunda_chance_usada = bool(parsed["segunda_chance_usada"])
	phase = String(parsed.get("phase", ESTADO_JOGANDO))
	fila = parsed["fila"]
	pending_rival = int(parsed.get("pending_rival", -1))
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
	# Pela mesma razão dos dias: o JSON devolve float, e o painel escreve o
	# dia do recorde com `%d`. A forma é a de `RECORDES_ZERADOS`, lida chave a
	# chave, e um campo que falte fica em «ainda não houve».
	_recordes = RECORDES_ZERADOS.duplicate(true)
	var lidos = parsed.get("recordes", {})
	if typeof(lidos) == TYPE_DICTIONARY:
		for nome in RECORDES_ZERADOS:
			var lido = lidos.get(nome, {})
			if typeof(lido) != TYPE_DICTIONARY:
				continue
			for chave in RECORDES_ZERADOS[nome]:
				if typeof(RECORDES_ZERADOS[nome][chave]) == TYPE_STRING:
					_recordes[nome][chave] = String(lido.get(chave, ""))
				else:
					_recordes[nome][chave] = int(lido.get(chave, 0))

	_reconciliar_roster()
	state_loaded.emit()
	return true


# O save de `texto` se ele passar TODAS as recusas; `{}` se não. Quem decide o
# que fazer com a recusa é quem chama: o `load_game()` apaga o arquivo, o
# `resumo_do_espaco()` lê-o como livre e não toca em nada (`066`).
#
# É também o que mantém a regra de ouro do `load_game()` de pé: TUDO O QUE
# RECUSA VEM ANTES DE TUDO O QUE ESCREVE. Com as recusas numa função que só
# LÊ, não há como uma delas ficar depois da primeira escrita no estado vivo.
func _save_aceite(texto: String) -> Dictionary:
	var parsed = JSON.parse_string(texto)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}

	# Até a `098`, save de outra versão era descartado, não adaptado: migrar
	# às cegas era adivinhar o que o jogador tinha comprado a partir de números
	# que já não queriam dizer a mesma coisa — foi assim que apareceu o porto
	# de 4 docas num mapa de 3. Recomeçar é honesto; carregar um estado
	# impossível não é. A migração de hoje não adivinha: cada passo é escrito
	# por quem mudou a forma, sabendo o que mudou, e o que ele entrega passa
	# por TODAS as recusas abaixo como se a versão corrente o tivesse gravado.
	# O que nenhum passo lê continua recusado.
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
	var versao = parsed.get("versao", null)
	if typeof(versao) not in [TYPE_INT, TYPE_FLOAT] or not is_finite(float(versao)) \
			or float(versao) != int(versao):
		return {}
	# A cadeia trabalha numa CÓPIA e não escreve nada; a versão decide-se só
	# aqui, depois dela, e a pergunta recusa as duas pontas: o que vem de baixo
	# do piso volta vazio, e o que vem do FUTURO (um build mais novo, depois um
	# mais velho) atravessa a cadeia sem passo nenhum e chega com a versão dele.
	parsed = _migrar(parsed)
	if parsed.is_empty() or int(parsed["versao"]) != SAVE_VERSION:
		return {}
	if not VidaDoPorto.estado_valido(parsed.get("vida_do_porto")):
		return {}
	for grupo_loja in ["dia_atual", "dia_anterior", "semana_atual"]:
		var contas_loja = parsed.get(grupo_loja)
		if typeof(contas_loja) != TYPE_DICTIONARY:
			return {}
		var gasto_loja = contas_loja.get("lojas")
		if typeof(gasto_loja) not in [TYPE_INT, TYPE_FLOAT] or not is_finite(float(gasto_loja)) \
				or float(gasto_loja) != int(gasto_loja) or int(gasto_loja) < 0:
			return {}
	# Campos novos obrigatórios: a 17 ganha zero no degrau; uma 18 truncada
	# não pode apagar multas já pagas por uma leitura com omissão.
	for grupo in ["dia_atual", "dia_anterior", "semana_atual", "metrics"]:
		if typeof(parsed.get(grupo)) != TYPE_DICTIONARY:
			return {}
		var chaves := ["servicos_cancelados", "multas_cancelamento"] if grupo == "metrics" else ["cancelamento"]
		for chave in chaves:
			var valor_novo = parsed[grupo].get(chave)
			if typeof(valor_novo) not in [TYPE_INT, TYPE_FLOAT] or not is_finite(float(valor_novo)) \
					or float(valor_novo) != int(valor_novo) or int(valor_novo) < 0:
				return {}
	# A FASE DO ARQUIVO PRIMEIRO (`104`), e tudo o que vem abaixo confere-se
	# contra ela — a obra, a cobrança, o dia —, e não contra a fase em jogo de
	# quem o abre: o `resumo_do_espaco()` lê os três espaços com a partida do
	# espaço 1 viva, e o mesmo arquivo seria aceite ou recusado conforme a fase
	# do vizinho. É o que a regra do save pedia desde a `094`.
	var fase_lida = parsed.get("numero_da_fase", null)
	if typeof(fase_lida) not in [TYPE_INT, TYPE_FLOAT] or not is_finite(float(fase_lida)) \
			or float(fase_lida) != int(fase_lida) \
			or int(fase_lida) < 1 or int(fase_lida) > FASES.size():
		return {}
	var fase := int(fase_lida)
	var dias = parsed.get("dias_de_reputacao", null)
	if typeof(dias) not in [TYPE_INT, TYPE_FLOAT] or not is_finite(float(dias)) \
			or float(dias) != int(dias) or int(dias) < 0:
		return {}
	if typeof(parsed.get("primeiro_cargueiro")) != TYPE_BOOL \
			or typeof(parsed.get("meta_concluida")) != TYPE_BOOL:
		return {}
	if fase == 1:
		if int(dias) != 0 or parsed["primeiro_cargueiro"] or parsed["meta_concluida"]:
			return {}
	else:
		var alvo: Dictionary = dados_da_fase(fase)["meta"]
		if int(dias) > int(alvo["dias"]):
			return {}
		if parsed["meta_concluida"]:
			if int(dias) != int(alvo["dias"]) or not parsed["primeiro_cargueiro"]:
				return {}
			if typeof(parsed.get("estruturas")) != TYPE_ARRAY:
				return {}
			for id in alvo["infra"]:
				if not parsed.get("estruturas", []).has(id):
					return {}
	# O DIA DENTRO DA FASE: a partir do primeiro dela e, com prazo, até ao dia a
	# seguir ao último — o da cobrança que fecha a fase, à espera da decisão, ou
	# o do fim. Um dia 40 na Fase 2 é um save que nenhuma partida grava, e
	# carregado poria a obra e o calendário a contar de antes de a fase abrir.
	var dia = parsed.get("turn", null)
	if typeof(dia) not in [TYPE_INT, TYPE_FLOAT] or not is_finite(float(dia)) \
			or float(dia) != int(dia) or int(dia) < inicio_da_fase(fase) \
			or (fase_tem_prazo(fase) and int(dia) > ultimo_dia_da_fase(fase) + 1):
		return {}
	if typeof(parsed.get("estruturas")) != TYPE_ARRAY:
		return {}
	var quitadas_lidas = parsed.get("parcelas_quitadas")
	if typeof(quitadas_lidas) not in [TYPE_INT, TYPE_FLOAT] or not is_finite(float(quitadas_lidas)):
		return {}
	var capitulos_possiveis := VidaDoPorto.disponiveis(int(dia), fase, TURNS_PER_WEEK,
		parsed["estruturas"], int(quitadas_lidas), parsed["vida_do_porto"]["compras"])
	for capitulo_lido in parsed["vida_do_porto"]["cenas_lidas"]:
		if not capitulos_possiveis.has(capitulo_lido):
			return {}
	# O ESTADO DO TURNO, que até à 15 entrava como texto qualquer: um valor
	# fora dos quatro deixava o turno à espera de um painel que não existe.
	if typeof(parsed.get("phase")) != TYPE_STRING or not ESTADOS_DO_TURNO.has(parsed["phase"]):
		return {}
	# Validar a obra pela leitura, antes de aplicar QUALQUER campo. Ausência
	# não significa obra vazia: a forma faz parte do Save 14 autorizado.
	var obra = parsed.get("obra_em_andamento", null)
	var feitas = parsed.get("estruturas", null)
	if typeof(obra) != TYPE_DICTIONARY or typeof(feitas) != TYPE_ARRAY:
		return {}
	if not obra.is_empty():
		if obra.size() != 3 or typeof(obra.get("id")) != TYPE_STRING \
				or not dados_da_fase(fase)["reparos"].has(obra["id"]) or feitas.has(obra["id"]):
			return {}
		for chave in ["inicio", "conclusao"]:
			var numero = obra.get(chave, null)
			if typeof(numero) not in [TYPE_INT, TYPE_FLOAT] \
					or not is_finite(float(numero)) or float(numero) != int(numero):
				return {}
		var inicio := int(obra["inicio"])
		var conclusao := int(obra["conclusao"])
		# O dia em que o reparo abre sai da MESMA função que decide o botão
		# (`089`); a cobrança que ele pede confere-se abaixo, depois de lido o
		# recibo. Sem prazo, a obra não tem teto.
		var abre := abertura_do_reparo(obra["id"], fase)
		if abre.is_empty() or inicio < int(abre["dia"]) or inicio > int(dia) \
				or conclusao <= int(dia) \
				or (fase_tem_prazo(fase) and conclusao > ultimo_dia_da_fase(fase) + 1) \
				or conclusao != inicio + dias_da_obra(obra["id"], fase):
			return {}
	# O recibo e a janela são parte da interpretação do save v12. Converter
	# texto para inteiro aceitaria silenciosamente uma cobrança inexistente.
	for chave in ["parcela_indice", "parcelas_quitadas", "total_pago_parcelas"]:
		var numero = parsed.get(chave, null)
		if typeof(numero) not in [TYPE_INT, TYPE_FLOAT] or float(numero) != int(numero):
			return {}
	if typeof(parsed.get("parcela_paid")) != TYPE_BOOL:
		return {}
	var indice := int(parsed["parcela_indice"])
	var quitadas := int(parsed["parcelas_quitadas"])
	if int(parsed["total_pago_parcelas"]) < 0:
		return {}
	# A FASE SEM COBRANÇA tem o recibo a zero (`104`): a passagem recomeça-o, e
	# o que a fase anterior pagou já está no `total_pago_parcelas`.
	if parcelas_na_fase(fase) == 0:
		if indice != 0 or quitadas != 0 or parsed["parcela_paid"]:
			return {}
	elif indice < 0 or indice >= parcelas_na_fase(fase) \
			or quitadas != indice + (1 if parsed["parcela_paid"] else 0):
		return {}
	# A SEGUNDA CHANCE (`102`), lida como o recibo: tipo antes de valor. A
	# dívida dela só existe depois de usada, nunca na primeira cobrança (ela
	# nasce ao pagar uma e vence com a SEGUINTE) e nunca com o boleto da
	# corrente já pago, porque pagá-lo é pagá-la.
	var devido = parsed.get("emprestimo_devido", null)
	if typeof(devido) not in [TYPE_INT, TYPE_FLOAT] or not is_finite(float(devido)) \
			or float(devido) != int(devido) or int(devido) < 0 \
			or typeof(parsed.get("segunda_chance_usada")) != TYPE_BOOL:
		return {}
	if int(devido) > 0 and (not parsed["segunda_chance_usada"] or indice < 1
			or parsed["parcela_paid"]):
		return {}
	# Sem cobrança não há a que pedir a segunda chance (`102`), e a passagem
	# põe-na por usar (uma por fase).
	if parcelas_na_fase(fase) == 0 and parsed["segunda_chance_usada"]:
		return {}
	# Lê as quitadas de HOJE, não as do dia em que a obra começou: elas só
	# sobem, então quem as tem hoje e não as tinha no início nunca passaria o
	# botão — e o botão é quem escreve a obra.
	if not obra.is_empty() and quitadas < int(abertura_do_reparo(obra["id"], fase)["quitadas"]):
		return {}

	# O roster é lido do dicionário, não dos campos do jogo, justamente para
	# poder recusar sem ter tocado em nada. Porto sem doca ou sem trabalhador é
	# um estado que nenhuma partida produz — é arquivo truncado ou editado.
	var docas_lidas = parsed.get("docks", [])
	var trabalhadores_lidos = parsed.get("workers", [])
	if typeof(docas_lidas) != TYPE_ARRAY or typeof(trabalhadores_lidos) != TYPE_ARRAY \
			or docas_lidas.is_empty() or trabalhadores_lidos.is_empty():
		return {}
	# E O ROSTO DE CADA UM (`059`), pela mesma razão: um fora da tabela é um
	# cartão sem cara, dois iguais são o mesmo retrato duas vezes na fileira.
	# ⚠️ O TIPO confere-se, e não só o valor: `int("x")` é 0, que é um rosto
	# válido — a armadilha da chave de Godot 3 no `CLAUDE.md`, do lado do save.
	var rostos_lidos := {}
	for w in trabalhadores_lidos:
		if typeof(w) != TYPE_DICTIONARY or not w.has("rosto") \
				or typeof(w["rosto"]) not in [TYPE_INT, TYPE_FLOAT]:
			return {}
		var k := int(w["rosto"])
		if k != float(w["rosto"]) or k < 0 or k >= rostos() or rostos_lidos.has(k):
			return {}
		rostos_lidos[k] = true
	# A FILA (`083`): no máximo os lugares que o fundeadouro tem, cada barco
	# com a paciência que lhe resta, e a oferta a apontar para dentro dela.
	# Um índice de oferta fora da fila abriria o painel do Arlindo sobre um
	# barco que não existe.
	var fila_lida = parsed.get("fila", null)
	if typeof(fila_lida) != TYPE_ARRAY or fila_lida.size() > FILA_LUGARES:
		return {}
	for b in fila_lida:
		if typeof(b) != TYPE_DICTIONARY or not b.has("paciencia") \
				or typeof(b["paciencia"]) not in [TYPE_INT, TYPE_FLOAT]:
			return {}
	var oferta_lida = parsed.get("pending_rival", -1)
	if typeof(oferta_lida) not in [TYPE_INT, TYPE_FLOAT] \
			or int(oferta_lida) < -1 or int(oferta_lida) >= fila_lida.size():
		return {}
	return parsed


# O save `dados` (com a `versao` já inteira) levado à versão corrente, degrau a
# degrau; `{}` se algum degrau não o souber ler. Não toca no estado vivo nem
# no disco: corre dentro do `_save_aceite()`, antes das recusas — e por isso o
# `resumo_do_espaco()` mostra o porto já migrado sem o gravar (`098`).
func _migrar(dados: Dictionary) -> Dictionary:
	return cadeia_de_migracao(dados, SAVE_VERSION, _migrar_um_passo)


# A cadeia, separada dos degraus para se provar com degraus de mentira: até a
# `102` a 14 era ao mesmo tempo o piso e a corrente, o jogo não tinha degrau
# nenhum, e um laço que nunca corre não tem quem o veja. O F21 do
# `teste_fumaca` corre-o com degraus que anotam por onde passaram, e hoje
# também pelo degrau de verdade, com o exemplo da 14.
#
# ⚠️ QUEM ESCREVE A `versao` DE CADA DEGRAU É A CADEIA, não o degrau: um
# degrau que se esquecesse dela devolveria um save da 15 a dizer 14, e o
# degrau seguinte seria outra vez o 14→15. E a cadeia copia UMA vez, à
# entrada: o que os degraus mexerem no dicionário não chega a quem chamou.
static func cadeia_de_migracao(dados: Dictionary, alvo: int, passo: Callable) -> Dictionary:
	var versao := int(dados["versao"])
	var atual := dados.duplicate(true)
	while versao < alvo:
		var saida = passo.call(versao, atual)
		if typeof(saida) != TYPE_DICTIONARY or saida.is_empty():
			return {}
		atual = saida
		versao += 1
		atual["versao"] = versao
	return atual


# Um degrau: o save da versão `de` na forma da `de + 1`, ou `{}` se não o
# souber ler. Escrito por quem mudou a forma, e provado pelo exemplo da
# versão de onde ele parte (`tests/saves/vNN.json`), que o F21 exige
# carregado (`098`).
func _migrar_um_passo(de: int, dados: Dictionary) -> Dictionary:
	match de:
		14:
			return _de_14_para_15(dados)
		15:
			return _de_15_para_16(dados)
		16:
			return _de_16_para_17(dados)
		17:
			return _de_17_para_18(dados)
		18:
			return _de_18_para_19(dados)
		_:
			return {}


# 14 → 15 (`102`): a 14 não conhecia a segunda chance, logo nenhuma partida
# dela a usou — sem dívida e com a chance por usar, que é o que uma partida
# nova da 15 também diz. A semana em curso ganha a linha do empréstimo a zero;
# sem ela o `load_game()` também a poria a zero, mas o degrau escreve a forma
# INTEIRA da versão a que chega, para o que vier depois dele não depender
# dessa tolerância.
func _de_14_para_15(dados: Dictionary) -> Dictionary:
	dados["emprestimo_devido"] = 0
	dados["segunda_chance_usada"] = false
	var semana = dados.get("semana_atual", null)
	if typeof(semana) == TYPE_DICTIONARY:
		semana["emprestimo"] = 0
	return dados


# 15 → 16 (`104`): a 15 só conhecia a Fase 1, logo todo save dela é da Fase 1
# — menos um. A partida GANHA da 15 é a que pagou as três cobranças, e na 16
# isso não é fim de jogo: é a Fase 2 no dia seguinte ao último. Deixá-la no
# fim de jogo era prender o porto do jogador numa página que agora diz
# «segue»; o degrau faz a passagem que a 15 não sabia fazer, com os mesmos
# recomeços do `_passar_de_fase()` — e sem a página, que ele já leu. Não é
# adivinhar: o arquivo diz `won` e as três quitadas, e é isso que a 16 pede.
#
# E sai o `upgrade_purchased` (M9): só a suíte antiga o lia, e o save corrente
# não o grava; deixá-lo no dicionário seria um campo que nenhuma versão
# escreve a atravessar as seguintes.
func _de_15_para_16(dados: Dictionary) -> Dictionary:
	dados["numero_da_fase"] = 1
	dados.erase("upgrade_purchased")
	if dados.get("phase") == ESTADO_FIM and dados.get("won") == true:
		dados["numero_da_fase"] = 2
		dados["phase"] = ESTADO_JOGANDO
		dados["won"] = false
		dados["end_reason"] = ""
		dados["parcela_indice"] = 0
		dados["parcela_paid"] = false
		dados["parcelas_quitadas"] = 0
		dados["emprestimo_devido"] = 0
		dados["segunda_chance_usada"] = false
		dados["reputation"] = reputacao_inicial(2)
	return dados


# A 16 não guardava a classe dos barcos já servidos nem os fechos acima da
# meta. Não se inventa passado: mantém-se o porto e começa-se a contagem aqui.
func _de_16_para_17(dados: Dictionary) -> Dictionary:
	dados["dias_de_reputacao"] = 0
	dados["primeiro_cargueiro"] = false
	dados["meta_concluida"] = false
	return dados


func _de_18_para_19(dados: Dictionary) -> Dictionary:
	dados["vida_do_porto"] = VidaDoPorto.vazio()
	for grupo in ["dia_atual", "dia_anterior", "semana_atual"]:
		if typeof(dados.get(grupo)) != TYPE_DICTIONARY:
			return {}
		dados[grupo]["lojas"] = 0
	return dados


func _de_17_para_18(dados: Dictionary) -> Dictionary:
	for chave in ["semana_atual", "dia_atual", "dia_anterior", "metrics"]:
		if typeof(dados.get(chave)) != TYPE_DICTIONARY:
			return {}
	for chave in ["semana_atual", "dia_atual", "dia_anterior"]:
		dados[chave]["cancelamento"] = 0
	dados["metrics"]["servicos_cancelados"] = 0
	dados["metrics"]["multas_cancelamento"] = 0
	return dados


# Quantas docas e quantos trabalhadores o porto DEVE ter, dado o que está
# construído. É a única fonte da verdade: docas não são um contador que anda
# sozinho, são consequência dos píeres.
func docas_esperadas() -> int:
	var n := DOCKS_BASE
	for id in ["pier_2", "pier_3"]:
		if tem_estrutura(id):
			n += UPGRADE_EXTRA_DOCKS
	return mini(n, bercos_no_mapa())


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
		workers.append(novo_trabalhador())

	# Trabalhador cortado não pode continuar alocado numa doca que ficou: seria
	# um "#4" na tela sem cartão correspondente na fileira.
	for doca in docks:
		var alocado = doca["worker_id"]
		if alocado != null and _find_worker(int(alocado)) == null:
			doca["worker_id"] = null


func clear_save() -> void:
	if FileAccess.file_exists(save_path):
		DirAccess.remove_absolute(save_path)
