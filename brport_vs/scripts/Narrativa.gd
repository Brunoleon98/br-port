class_name Narrativa
extends RefCounted

# ============================================================
# BR Port VS — o texto narrativo, num lugar só
#
# Item A4 do plano v3: as telas que carregam a Fase 1 como HISTÓRIA. O jogo
# tinha o loop inteiro e nenhum NPC — a Dona Cida não aparecia uma única vez no
# código, e o Sr. Ribeiro era uma linha de texto solta num painel.
#
# Este arquivo é para o texto o que o `Icones.gd` é para o ícone: o único lugar
# que sabe qual palavra é de quem. A alternativa — cada painel carregando as
# suas falas — foi o que aconteceu com os emojis, e trocar um custava caçar
# string por string em sete scripts.
#
# A FONTE é `docs/design/BR_Port_Frontload_Escrita_VS.md`, escrito no Bloco 1
# justamente para o texto não ser inventado à pressa na hora de codar. O que
# está aqui é aquele rascunho, com três desvios que o jogo OBRIGOU e que ficam
# registrados por escrito:
#
# 1. O FIM DE FASE FALAVA DE DOZE SEMANAS. O texto original abria com "Doze
#    semanas / Trinta e seis turnos de decisão / Três parcelas" — que é a Fase 1
#    inteira do GDD. O VS tem `WEEKS_TOTAL` semanas e UMA parcela. Escrever doze
#    seria mentir para o jogador sobre o jogo que ele acabou de jogar, então os
#    números saem das constantes (ver `fim_de_fase`) e não do texto: assim eles
#    não podem envelhecer quando o VS crescer.
#
# 2. O NOME DO JOGADOR PODE ESTAR VAZIO. O GDD dá padrão ao nome do porto
#    ("Cais Mirim") e não dá ao do jogador, e inventar um seria pôr palavra na
#    boca de quem não a escolheu. Toda fala com vocativo tem variante sem ele —
#    ver `_vocativo`. O Toninho já trata por "chefia" e o Arlindo por "meu
#    caro", então ninguém fica sem forma de tratamento.
#
# 3. PORTO MIRIM É A CIDADE, CAIS MIRIM É O PORTO. São coisas diferentes e o
#    rascunho usa as duas: o banco do Sr. Ribeiro é de Porto Mirim (fixo) e o
#    cais é o que o jogador batiza. Trocar um pelo outro é o tipo de erro que
#    só se vê lendo em voz alta.
#
# Os tokens `{portName}` e `{playerName}` são resolvidos por
# `GameState.texto()`, que é o único ponto de substituição. Quem escrever texto
# novo aqui NÃO deve substituir à mão.
# ============================================================


# ── DIÁRIO DO PORTO — primeira página ──
# Abre uma vez, na semana 1. Primeira pessoa, incerteza com leveza.
#
# ⚠️ A FRASE DO CAIXA RESPONDE A UMA QUEIXA DE PLAYTEST, e a forma dela foi
# escolhida contra outra. A queixa era "é estranho o porto ter dívida mas o
# jogador começar com R$400.000", e a triagem propôs chamar EMPRÉSTIMO ao caixa
# inicial. Isso contradiz o que o Sr. Ribeiro já diz duas telas depois — "O Seu
# Maneco assinou isso. Agora é seu" —: a dívida é do avô, herdada com o porto, e
# o empréstimo dele já foi gasto no porto, que é por isso que ele está em
# ruínas. Chamar empréstimo ao caixa poria o Ribeiro a cobrar R$530.000 sobre
# R$400.000 em quatro semanas, que é agiotagem e não é o personagem escrito
# ("não é punição, é contrato").
#
# O que faltava não era rótulo nenhum: era uma frase a dizer de onde vem o
# dinheiro, e ela nunca existiu. Herda-se o ativo e o passivo do mesmo homem, e
# isso não é estranho — só não estava escrito. O valor sai do `{caixaInicial}`
# e nunca da prosa; o bloco F4 do `teste_fumaca.gd` tranca as duas metades.
const DIARIO_PRIMEIRA_PAGINA := """Nunca pensei que ia escrever nesse diário.

O avô escrevia aqui toda semana — vinte e três anos de {portName}, letra miúda, tinta azul. Eu achava bobagem.

Hoje abri a primeira página em branco.

O {portName} tem dívida, tem madeira podre no píer e tem um rival que sabe o meu nome antes de eu saber o dele direito.

O avô também deixou {caixaInicial} na conta. Contei três vezes.
Não é dinheiro meu — é o prazo que ele me comprou.

Mas tem gente que acreditou o suficiente pra estar aqui na primeira semana.
Dona Cida. Toninho. Zezão.

Talvez o avô soubesse o que tava fazendo quando deixou tudo isso pra mim.

Talvez."""

const DIARIO_CABECALHO := "Porto Mirim, primeira semana"


# ── DONA CIDA — o boletim financeiro semanal ──
# Os tons saem do resultado da semana contra a média das anteriores, e o
# vermelho divide-se pela semana anterior e pela parcela (ver
# `tom_do_boletim`). A faixa do meio existe para a comemoração ser RARA: sem ela,
# qualquer semana no azul soaria a festa e o tom perderia o valor.
# ⚠️ CADA TOM AFIRMA MAIS DO QUE O NÚMERO QUE O ESCOLHE, e até 23/09 ninguém
# conferia as afirmações. Medido com `tools/medir_boletim.gd` (200 partidas por
# perfil, cinco perfis): o tom ruim dizia "a semana passada foi menos pior" e
# isso foi falso em **856 de 856** vezes — nunca aconteceu —, "de novo" em 256
# e "o Sr. Ribeiro não aceita boa vontade" em 252, porque a semana ruim mais
# comum é a 4, em que o jogador ACABOU de pagar o Sr. Ribeiro. Hoje o tom lê
# também a semana anterior e a parcela (`tom_do_boletim`), e cada variante só
# afirma o que a condição dela garante (`docs/decisoes/048`).
#
# "De novo": a semana anterior também fechou no vermelho.
const CIDA_BOLETIM_RUIM := """Conseguimos a façanha de gastar mais do que ganhar. De novo.
Dinheiro não estica só porque a gente olha pra ele."""

# A semana anterior NÃO fechou no vermelho — o "de novo" seria mentira.
const CIDA_BOLETIM_RUIM_VIROU := """Conseguimos a façanha de gastar mais do que ganhar.
Semana passada não foi assim. Alguém lembra o que a gente fez de diferente?"""

# A semana que pagou a parcela. O vermelho é o Sr. Ribeiro, e reclamar dele
# seria reclamar do jogador por ter pago — era o que o tom ruim fazia na semana
# 4 em quase todas as partidas que pagavam.
const CIDA_BOLETIM_RUIM_RIBEIRO := """Fechou no vermelho, chefia — mas quem levou foi o Sr. Ribeiro.
Esse vermelho eu assino embaixo."""

# ⚠️ E O PRIMEIRO BOLETIM NÃO TEM COM QUE COMPARAR. O tom RUIM abre a dizer "a
# semana anterior foi melhor", e na semana 1 não há semana anterior — a Dona
# Cida afirmava uma coisa que o estado não garante, logo no primeiro boletim
# que o jogador vê. Medido em 12/09: quem aloca trabalhador nunca cai aqui (0
# de 60 partidas), quem não aloca ninguém cai SEMPRE (60 de 60, a -R$16.000) —
# ou seja, é exatamente o principiante que ainda não percebeu a alocação que
# ouvia a frase errada. A última linha sobrevive porque é a que trabalha.
# "Não tenho com o que comparar — é a primeira" repetia a linha de cima: a
# fala dizia duas vezes que era a primeira semana. A parcela aqui é sempre
# verdade — a semana que a pagasse sairia pelo tom do Sr. Ribeiro, antes deste.
const CIDA_BOLETIM_PRIMEIRA_RUIM := """Primeira semana, e já no vermelho, chefia.
Saiu mais do que entrou — isso eu sei ler sem comparar com nada.
A parcela não espera a gente aprender."""

# "Os números fecharam" era narrar o painel que o jogador tem à frente.
const CIDA_BOLETIM_NEUTRO := """Entrou mais do que saiu. Sem milagre, sem susto.
Porto que fecha a semana no azul é porto que não para."""

# "Olha esse resultado" narrava o painel, e "a parcela da próxima semana" foi
# falsa em 641 de 1.229 boletins: o tom ótimo sai nas semanas 2 a 4, e a
# parcela só vence na 4 — na 2 ela está a duas semanas, na 4 já foi paga. A
# fala ficou sem parcela nenhuma, e com o mesmo fecho.
const CIDA_BOLETIM_OTIMO := """Chefia. Não vou fazer festa, que festa dá azar.
Mas foi uma boa semana. Pronto, eu disse."""

# Acima de quanto da média das semanas anteriores o resultado conta como
# excepcional. Fonte: o próprio arquivo de escrita ("+30%").
const CIDA_LIMIAR_OTIMO := 0.30

# OS TONS POR ID, e é o id que o resto do jogo passa a usar.
#
# ⚠️ ELE EXISTE PORQUE O RETRATO PRECISA DE SABER QUAL TOM SAIU. Até 13/09 o
# `tom_do_boletim()` devolvia o TEXTO, o que bastava enquanto a fala era só
# texto; com uma cara ao lado, quem abre o painel tem de escolher também a
# expressão — e escolhê-la comparando strings de fala seria o pior espelho
# possível. A outra saída era uma segunda função a decidir o tom, e duas
# versões da mesma conta divergem: este projeto já pagou isso com os números
# do GDD contra os das constantes. Uma decisão só, um id, duas tabelas a lê-lo.
const CIDA_BOLETIM := {
	"ruim": CIDA_BOLETIM_RUIM,
	"ruim_virou": CIDA_BOLETIM_RUIM_VIROU,
	"ruim_ribeiro": CIDA_BOLETIM_RUIM_RIBEIRO,
	"primeira_ruim": CIDA_BOLETIM_PRIMEIRA_RUIM,
	"neutro": CIDA_BOLETIM_NEUTRO,
	"otimo": CIDA_BOLETIM_OTIMO,
}


# ── DONA CIDA — as linhas do loop ──
# Reagem a evento, não a turno: uma linha por semana viraria papel de parede.
# A chave é o id do evento; quem dispara é o `Main`.
const CIDA_LINHAS := {
	"reputacao_subiu": "O pessoal tá falando bem do cais, chefia. Raro. Aproveita.",
	# Dizia "Dois contratos recusados essa semana", e o gatilho é a queda de
	# FAIXA da reputação — nunca dois contratos. Número em fala tem de sair de
	# onde o evento sai, e este não saía de lado nenhum.
	"reputacao_caiu": "Andaram recusando contrato, chefia. Arlindo vai saber antes de nós.",
	# ⚠️ DUAS VARIANTES PORQUE A PARCELA PODE JÁ TER SIDO PAGA. O
	# `pagar_parcela_adiantado()` existe desde o playtest, então um jogador que
	# quite no turno 5 ouviria "a parcela não vai esperar" nos 27 turnos
	# seguintes — verdadeira em português e falsa neste mundo. Quem separa é
	# `parcela_paid`, que já existe; nenhum limiar novo entra aqui.
	"caixa_baixo": "A conta tá mais fina que folha de papel. A parcela não vai esperar.",
	# ⚠️ "CAIXA" É JARGÃO, e a leitura em voz alta de 19/09 apanhou-o: o jogo é
	# para quem pode não saber finanças, e "caixa" só quer dizer dinheiro para
	# quem já trabalhou com ele. O termo sai daqui e da fala da semana nova; o
	# rótulo "Caixa:" do painel da parcela é do mesmo achado e fica registado.
	"caixa_baixo_quitado": "O dinheiro tá no fim, chefia. Ao menos o Sr. Ribeiro já tá pago.",
	# "Perdeu pro Arlindo" narrava o que o jogador acabou de ver acontecer.
	"perdeu_para_arlindo": "O Arlindo vai contar essa na padaria amanhã. Deixa contar, chefia.",
	"bom_contrato": "Esse contrato fecha a semana. Anota aí.",
	# ⚠️ QUATRO VARIANTES, E NENHUMA AFIRMA O QUE A CONDIÇÃO DELA NÃO GARANTE.
	# A linha única dizia "Barcos na fila, caixa no limite" em TODA semana ≥ 2,
	# sem olhar nem uma coisa nem outra: medido em 18/09, na semente padrão ela
	# saía com o cais vazio e R$384.000 em caixa. Os dois critérios já existem
	# — `docas_esperando()` e `caixa_curto()` —, e é de propósito que saem do
	# GameState em vez de serem recontados aqui.
	"semana_nova_fila_curto": "Semana nova. Barcos esperando, dinheiro curto. Dia típico.",
	"semana_nova_fila_folgado": "Semana nova. Barcos esperando e dinheiro no caixa. Aproveita.",
	# ⚠️ E A PARCELA SÓ SE MENCIONA SE ELA ESTIVER MESMO PENDENTE. É a mesma
	# armadilha que a `caixa_baixo_quitado` existe para tapar, e ela estava por
	# tapar aqui: quem quita cedo — `pagar_parcela_adiantado()` — ouviria "a
	# parcela correndo" em toda semana até ao fim da partida. Quem separa é
	# `parcela_paid`, que já existe.
	"semana_nova_parado_curto": "Semana nova. Cais parado e a parcela correndo. Não gosto disso.",
	"semana_nova_parado_curto_quitado": "Semana nova. Cais parado e pouco dinheiro. Não gosto disso.",
	"semana_nova_parado_folgado": "Semana nova. Tudo quieto por enquanto, chefia.",
	# ⚠️ A OBRA É INSTANTÂNEA: `comprar_estrutura()` emite "pronto" na mesma
	# chamada. A linha dizia "Demorou o dobro do previsto", que não descreve
	# nada que aconteça neste jogo — o ceticismo dela fica, a duração sai.
	# ⚠️ E DUAS VARIANTES PORQUE ELA SAI NAS SETE OBRAS. "Olha que eu duvidei"
	# é uma reação de primeira vez; à terceira o ceticismo já foi desmentido
	# duas vezes, e repeti-lo lê como a Dona Cida não estar a prestar atenção.
	# Da terceira em diante ela concede — que é a mesma regra da DOSE do
	# maneirismo do Arlindo, com o sinal trocado: ali faltava repetição para
	# fazer padrão, aqui sobra. O corte sai de `estruturas.size()`, que é a
	# contagem do próprio jogo.
	"upgrade_pronto": "Zezão terminou. Ficou bom — e olha que eu duvidei.",
	"upgrade_pronto_rotina": "Zezão terminou mais uma. Já nem pergunto se vai dar certo.",
	# ⚠️ "TUDO QUE A GENTE RECUSA" PRESSUPÕE UMA RECUSA, e a primeira oferta do
	# Arlindo chega antes de existir qualquer uma. Quem conta é
	# `metrics["rival_refused"]`, que já existe.
	"arlindo_indireto": "O Porto Farol tá aceitando tudo que a gente recusa. Coincidência, chefia?",
	"arlindo_primeira": "O Porto Farol tá de olho no que passa por aqui, chefia.",
}


# ── ARLINDO — a contra-oferta ──
# Ele NÃO fala com o jogador: fala com o cliente, e o jogador ouve. É o que
# torna a tela uma negociação assistida em vez de uma discussão.
# ⚠️ O "SOBRINHO" DO FIM SAIU EM 23/09, e a DOSE não o tinha salvo. O GDD
# assina o maneirismo — *"chama todo mundo de sobrinho ou querido,
# independente da idade"* (`gdd/sistemas/voz_personagens.md`) —, e a primeira
# leitura perguntou "como assim sobrinho?". A correção de 13/09 foi plantar o
# "querido" nesta abertura, para a segunda ocorrência ler como assinatura; a
# leitura seguinte tropeçou no MESMO sítio («achei estranho ele chamar de
# sobrinho»). A leitura provável — ninguém a mediu: parentesco dito a quem não
# é parente lê-se literal antes de ler como tique, e em sete linhas não há
# tempo para virar tique. Escolha do Bruno: "meu caro" — a mesma
# condescendência sorridente, sem parentesco. O "querido" fica: é a outra
# metade do maneirismo, e nunca foi queixa.
const ARLINDO_ABERTURA := "{portName} fez uma proposta. Entendo, querido. Mas eu consigo cobrir isso — e um pouco mais."

# A reação sai do preset escolhido. As chaves batem com as três opções do
# painel; ver RIVAL_DISCOUNT / RIVAL_HALF_DISCOUNT / manter, no GameState.
const ARLINDO_REACOES := {
	"igualar": "Ficou nervoso, hein? Bom sinal.",
	"metade": "Metade do esforço. Respeito a tentativa.",
	"manter": "Autoconfiante. Gosto. Autoconfiante não paga conta — mas gosto.",
}

const ARLINDO_ULTIMA_TENTATIVA := "Minha oferta não expira. A paciência do senhor, sim."
# "A casa" é o maneirismo do guia de voz para o próprio porto, e "sempre bom
# fazer negócio" podia sair da boca de qualquer um.
const ARLINDO_VENCEU := "A casa agradece a preferência. Boa sorte pro {portName}."
const ARLINDO_PERDEU := "Dessa vez não. Mas tem mais semanas pela frente, meu caro."

# ⚠️ AS DUAS ÚLTIMAS ESTAVAM MUDAS DESDE 01/09, e é a QUARTA vez que este
# projeto apanha a mesma coisa. Elas estavam escritas, passavam no bloco que
# pergunta *"todo id da tabela tem fala?"* — e nenhuma linha do jogo as
# disparava: a negociação resolvia-se e o painel fechava calado, ganhasse quem
# ganhasse. O F4 não podia apanhar, porque ele varre `CIDA_LINHAS` e mais
# nada. É o `barco_medio` outra vez (gerado, validado, e nunca posto em doca
# nenhuma), e a lição continua a mesma: fala nova entra com o GATILHO no mesmo
# commit. Hoje o gatilho é o segundo tempo do painel da contra-oferta, e o
# fumaça varre esta tabela como já varria a da Dona Cida.
const ARLINDO_FALAS := {
	"abertura": ARLINDO_ABERTURA,
	"ultima_tentativa": ARLINDO_ULTIMA_TENTATIVA,
	"venceu": ARLINDO_VENCEU,
	"perdeu": ARLINDO_PERDEU,
}


# ── SR. RIBEIRO — a cena da parcela ──
# Cena tensa, sem penalidade mecânica: o que ele traz é peso, não número. O
# número já está no botão.
# ⚠️ "VIM PESSOALMENTE PORQUE..." EXPLICAVA O PRÓPRIO GESTO, e a resposta a quem
# não pagava dizia-o outra vez. A queixa do Bruno em 23/09 foi exatamente esta
# — "muito óbvia e sem graça" —, e a troca é por um DETALHE que diz o mesmo sem
# o dizer: o avô pagava na véspera, e é no dia que o Sr. Ribeiro aparece.
const RIBEIRO_ENTRADA := """Boa tarde{vocativo}. Rivaldo Ribeiro, Banco Porto Mirim.
Fui amigo do seu avô — uns trinta anos, se não me engano.
Ele pagava sempre na véspera. Dizia que no dia já é tarde."""

# "a parcela", minúscula: "Parcela" é o rótulo do HUD, e um homem a falar não
# diz maiúsculas. Era a marca mais clara de manual de instruções no roteiro.
const RIBEIRO_A_DIVIDA := """A parcela vence hoje: {valor}. Tenho o documento aqui se quiser conferir.
O Seu Maneco assinou isso. Agora é seu."""

# "Me procura antes de ter problema" repetia a despedida que vem logo a seguir,
# no mesmo balão.
const RIBEIRO_PAGOU := """Conferido. O Seu Maneco pagava na véspera — mas o dia também serve.
O banco não esquece quem paga em dia. Eu também não."""

# ⚠️ A FALA ANTIGA PROMETIA O QUE O JOGO NÃO FAZ. Vinha do rascunho da Fase 1
# do GDD, com três parcelas e tolerância — "uma vez eu deixo passar com uma
# conversa" —, e no VS `fail_debt()` encerra a partida: "Porto perdido". O Sr.
# Ribeiro dizia que perdoava a quem acabava de perder o porto, e ainda "vim
# pessoalmente porque sei que é o primeiro mês", o gesto explicado pela segunda
# vez e um mês que o jogo não tem. Quando bravo ele fica MAIS educado (guia de
# voz), e é por aí que a frase pesa.
const RIBEIRO_NAO_PAGOU := """Então o cais passa para o banco. Não é castigo — é o que está no papel.
Sinto muito. O Seu Maneco passou trinta anos sem atrasar um dia."""

# ⚠️ SÓ DEPOIS DE PAGAR. Ela promete crédito para o porto crescer, e era dita
# também a quem acabava de o perder (`DebtPaymentPanel._mostrar_resposta`).
# "O banco existe pra isso" era frase de folheto; o conselho do banqueiro é a
# regra do crédito, dita por quem a cobra.
const RIBEIRO_DESPEDIDA := """Uma coisa antes de ir.
O Seu Maneco dizia que o pior erro de um portuário é achar que dá conta de tudo sozinho.
Quando precisar de crédito, me procure cedo. Crédito pedido no aperto sai mais caro."""

# As cinco por id, pela mesma razão das do Arlindo: é por aqui que a expressão
# se prende à fala, e é isto que o fumaça percorre.
const RIBEIRO_FALAS := {
	"entrada": RIBEIRO_ENTRADA,
	"a_divida": RIBEIRO_A_DIVIDA,
	"pagou": RIBEIRO_PAGOU,
	"nao_pagou": RIBEIRO_NAO_PAGOU,
	"despedida": RIBEIRO_DESPEDIDA,
}


# ── A CARA QUE CADA FALA PEDE ───────────────────────────────────────────────
#
# Item do plano pedido na leitura em voz alta de 13/09: *"o sprite com a
# reação do personagem mais a mensagem"*. A reação é ESTA tabela; o arquivo de
# cada expressão vive no `Retratos.gd`, como o arquivo de cada ícone vive no
# `Icones.gd`.
#
# ⚠️ ELA PERCORRE AS FALAS, e não o contrário. A tentação é listar as três
# expressões de cada um e deixar o painel escolher — e aí uma fala nova nasce
# sem cara, cai no `null` e o balão fica sem retrato sem nada a apontá-lo. Com
# a tabela do lado das FALAS, o bloco F6 do fumaça pode perguntar as três
# coisas que interessam, cada uma contra uma fonte diferente: toda fala tem
# expressão (contra as tabelas de texto acima), toda expressão tem PNG (contra
# o disco) e toda expressão desenhada é usada por alguma fala (contra o
# `Retratos.gd`) — que é a pergunta do `barco_medio`, do lado da arte.
#
# A escolha de cada uma sai do TOM que o guia de voz descreve, e não do
# assunto: a Dona Cida é "pragmática, brava, leal", e por isso a cara padrão
# dela é séria e não sorridente; o Arlindo "sempre sorrindo quando ataca", e
# por isso o sorriso é o estado normal dele e o que muda é o sorriso SAIR; o
# Sr. Ribeiro "quando bravo fica MAIS educado", e por isso a cara grave dele é
# a cordial com a boca em baixo, nunca uma cara zangada.
const EXPRESSOES := {
	"cida": {
		"ruim": "preocupada",
		"ruim_virou": "preocupada",
		"ruim_ribeiro": "seria",
		"primeira_ruim": "preocupada",
		"neutro": "seria",
		"otimo": "contente",
		"reputacao_subiu": "contente",
		"reputacao_caiu": "preocupada",
		"caixa_baixo": "preocupada",
		"caixa_baixo_quitado": "preocupada",
		"perdeu_para_arlindo": "preocupada",
		"bom_contrato": "contente",
		"semana_nova_fila_curto": "seria",
		"semana_nova_fila_folgado": "contente",
		"semana_nova_parado_curto": "preocupada",
		"semana_nova_parado_curto_quitado": "preocupada",
		"semana_nova_parado_folgado": "seria",
		"upgrade_pronto": "contente",
		"upgrade_pronto_rotina": "contente",
		"arlindo_indireto": "seria",
		"arlindo_primeira": "seria",
	},
	"arlindo": {
		"abertura": "sorriso",
		"igualar": "sorriso",
		"metade": "sorriso",
		"manter": "sorriso",
		"ultima_tentativa": "pressao",
		"venceu": "sorriso",
		"perdeu": "contrariado",
	},
	"ribeiro": {
		"entrada": "cordial",
		"a_divida": "formal",
		"pagou": "cordial",
		"nao_pagou": "grave",
		"despedida": "cordial",
	},
}


# ── BOLETIM DO DIA ──
# Abre o turno com o que mudou desde ontem. Curto de propósito: é a tela que
# mais vezes se vê na partida inteira, e tela repetida cansa por acumulação.
const BOLETIM_DIA_TITULO := "Semana {semana}, dia {dia}"


# O AUTOLOAD NÃO RESOLVE PELO NOME AQUI DENTRO, e custou uma corrida a
# descobrir. `GameState.x` funciona num script de cena, que o Godot compila com
# os autoloads já registrados como identificadores; NÃO funciona dentro de um
# `class_name` alcançado a partir de um script de `--script`, porque essa classe
# é compilada antes disso. O erro sai como *"Compile Error: Identifier not
# found: GameState"* e derruba a suíte inteira, não só a linha culpada.
#
# É a irmã da regra do `GS` destipado que já está no CLAUDE.md, e tem a mesma
# origem: a suíte roda o jogo POR FORA, e por fora nem tudo o que existe em
# jogo existe. Buscar pela árvore funciona nos dois mundos.
#
# O tipo de retorno é `Node`, então quem receber algo dele escreve o tipo à
# mão — `var n: int = _gs().WEEKS_TOTAL`, nunca `:=`.
static func _gs() -> Node:
	return Engine.get_main_loop().root.get_node("GameState")


# O vocativo do jogador, com a vírgula que o precede — ou nada, se ele deixou o
# nome em branco. Devolver a vírgula junto é o que impede "Boa tarde ,." de
# aparecer na tela: a pontuação faz parte da decisão, não do modelo.
static func _vocativo() -> String:
	var nome: String = _gs().nome_jogador
	return ", " + nome if nome != "" else ""


# A fala de entrada do Sr. Ribeiro, já com vocativo resolvido. Os tokens de
# nome continuam a passar pelo `GameState.texto()`, que é o ponto único.
static func ribeiro_entrada() -> String:
	return _gs().texto(RIBEIRO_ENTRADA.replace("{vocativo}", _vocativo()))


static func ribeiro_a_divida(valor: int) -> String:
	return _gs().texto(RIBEIRO_A_DIVIDA.replace("{valor}", _gs().moeda(valor)))


# Qual dos tons da Dona Cida a semana merece. `media_anterior` vem do
# histórico; na primeira semana não há com que comparar, e aí o que decide é só
# o sinal do resultado — comparar contra zero seria chamar de excepcional
# qualquer semana que fechasse no azul.
#
# DEVOLVE O ID, e não o texto: quem abre o painel precisa das duas coisas que
# saem dele — a fala e a cara —, e uma segunda função a repetir esta decisão
# seria a divergência de sempre. Ver `CIDA_BOLETIM`.
#
# ⚠️ RECEBE O RESUMO INTEIRO desde 23/09, e não três números: as falas afirmam
# coisas sobre a semana ANTERIOR e sobre a PARCELA, e a escolha que só via o
# resultado e a média deixava-as sair onde eram falsas (`docs/decisoes/048`).
# Acesso DIRETO às chaves — é o `resumo_da_semana()` do GameState, e uma chave
# que falte tem de rebentar em vez de virar zero.
static func tom_do_boletim(resumo: Dictionary) -> String:
	var resultado := int(resumo["resultado"])
	var tem_historico := bool(resumo["tem_historico"])
	var media_anterior := float(resumo["media_anterior"])
	if resultado < 0:
		# ⚠️ A PARCELA VEM PRIMEIRO, antes até da primeira semana: quem a
		# quitasse já na semana 1 ouviria "a parcela não espera a gente
		# aprender" com ela paga.
		if int(resumo["parcela"]) > 0:
			return "ruim_ribeiro"
		# A ORDEM IMPORTA: o `tem_historico` tem de ser perguntado ANTES de se
		# escolher o tom mau, senão a semana 1 recebe a fala que compara com a
		# semana 0. Era assim até 12/09, e nada reprovava.
		if not tem_historico:
			return "primeira_ruim"
		return "ruim" if int(resumo["anterior"]) < 0 else "ruim_virou"
	if not tem_historico:
		return "neutro"
	if float(resultado) > media_anterior * (1.0 + CIDA_LIMIAR_OTIMO):
		return "otimo"
	return "neutro"


# O texto de um dos tons, já com os nomes resolvidos.
static func boletim(id: String) -> String:
	return _gs().texto(String(CIDA_BOLETIM.get(id, "")))


# A expressão que uma fala pede. Devolve vazio para um par desconhecido, que o
# `Retratos.de()` traduz num balão sem cara — uma expressão que falta é um
# retrato a menos, não um crash. Quem garante que não falta nenhuma é o F6.
static func expressao(personagem: String, id: String) -> String:
	var caras: Dictionary = EXPRESSOES.get(personagem, {})
	return String(caras.get(id, ""))


# O retrato pronto para o painel: personagem + id da fala -> textura.
#
# Existe aqui e não em cada painel para que a ligação fala->cara passe por UM
# ponto, que é a mesma razão do `GameState.texto()` e do `moeda()`.
static func retrato(personagem: String, id: String) -> Texture2D:
	return Retratos.de(personagem, expressao(personagem, id))


# A narração de fim de Fase 1.
#
# OS NÚMEROS SAEM DAS CONSTANTES, e é o ponto todo desta função. O rascunho
# dizia "Doze semanas / Trinta e seis turnos / Três parcelas", que é a Fase 1
# do GDD e não o VS — e um texto com número escrito à mão é um número a mais
# para envelhecer, que é exatamente o problema que a tabela dos números existe
# para resolver.
## Número por extenso, de 0 a 99. Existe porque DERIVAR DA CONSTANTE E IMPRIMIR
## COM `%d` TROCA UM PROBLEMA POR OUTRO: a narração de fim de fase passou a
## dizer "4 semanas." e "32 turnos", e dígito no meio de uma peça literária lê
## como planilha. O `%d` consertou o número que envelhecia e estragou a prosa,
## e ninguém reparou porque a guarda existente pergunta pela FORMA do dinheiro,
## não pela dos numerais. Aqui o número continua a sair da constante — só chega
## à página escrito como quem fala.
static func por_extenso(n: int) -> String:
	const UNS := ["zero", "uma", "duas", "três", "quatro", "cinco", "seis",
		"sete", "oito", "nove", "dez", "onze", "doze", "treze", "catorze",
		"quinze", "dezasseis", "dezassete", "dezoito", "dezanove"]
	const DEZ := ["", "", "vinte", "trinta", "quarenta", "cinquenta",
		"sessenta", "setenta", "oitenta", "noventa"]
	if n < 0 or n > 99:
		return str(n)
	if n < 20:
		return UNS[n]
	var d := n / 10
	var u := n % 10
	return DEZ[d] if u == 0 else DEZ[d] + " e " + UNS[u]


## Concorda uma frase com uma CONTAGEM — "1 dia restante" / "2 dias restantes".
##
## Chama-se `concordar` e não `plural` porque o que ela acerta é a frase
## inteira e não só o substantivo: o adjetivo e o particípio concordam junto,
## e foi por não terem onde concordar que cinco rótulos deste jogo escreviam
## "dia(s) restante(s)" e "trabalhador(es) alocado(s)" ao jogador.
##
## ⚠️ O SINGULAR É SÓ EM `n == 1`, e o caso que se esquece é o ZERO: em
## português zero leva PLURAL — "0 dias restantes", nunca "0 dia restante".
## Um `n <= 1` escrito por distração é a forma mais fácil de errar isto, e é
## um dos mutantes que o bloco T9 injeta.
##
## ⚠️ E O ADJETIVO VIAJA COM O SUBSTANTIVO, de propósito. A alternativa era
## receber substantivo e adjetivo em separado e concordá-los aqui — o que
## obrigaria esta função a saber género e a distinguir "restante" (que não
## muda) de "alocado" (que muda). Quem escreve a frase já sabe as duas formas;
## esta só escolhe entre elas. É a mesma razão pela qual o `por_extenso` acima
## fala no feminino e quem o chama é que sabe se serve.
static func concordar(n: int, um: String, varios: String) -> String:
	return "%d %s" % [n, um if n == 1 else varios]


## O resultado de um dia ou de uma semana, na palavra de quem não é da finança:
## "lucro de R$12.000", "prejuízo de R$16.000" — e o ZERO, que não é nenhum dos
## dois. Pedido do Bruno no gate A4 (23/09): "caixa" virou "dinheiro" e, onde
## coubesse, "resultado" virou lucro ou prejuízo.
##
## ⚠️ O PREJUÍZO LEVA O VALOR SEM SINAL. A palavra já diz que saiu dinheiro;
## "prejuízo de -R$16.000" seria dizê-lo duas vezes, e uma dupla negação lida
## depressa inverte o sentido. E o zero não é "lucro de R$0": um dia sem barco
## e sem custo não ganhou nada, e escrever lucro ali é afirmar o que não houve.
##
## A moeda entra como `Callable` porque esta classe é alcançada a partir de
## `--script` e não pode chamar o autoload pelo nome (`CLAUDE.md`); quem chama
## passa `GameState.moeda`, e o teste passa a do `GameState` que tem à mão.
## `inicio` põe a primeira letra em maiúscula, para quando a frase abre a linha.
static func lucro_ou_prejuizo(valor: int, moeda: Callable, inicio := false) -> String:
	var t := "nem lucro nem prejuízo"
	if valor > 0:
		t = "lucro de %s" % moeda.call(valor)
	elif valor < 0:
		t = "prejuízo de %s" % moeda.call(-valor)
	return _maiuscula(t) if inicio else t


## Só a PRIMEIRA letra. O `capitalize()` do Godot maiusculiza cada palavra, e
## "trinta e dois" sairia "Trinta E Dois" — o que só se vê com um número acima
## de vinte, que é precisamente o caso que o VS tem.
static func _maiuscula(t: String) -> String:
	return t.substr(0, 1).to_upper() + t.substr(1) if t != "" else t


static func fim_de_fase() -> String:
	# ⚠️ A LINHA DOS DIAS SAIU EM 13/09, e a razão é aritmética: ela dizia
	# "Trinta e dois dias" logo abaixo de "Quatro semanas", e quatro semanas
	# dão VINTE E OITO. O `TURNS_PER_WEEK` é 8, então o "dia" deste jogo não é
	# um dia de calendário — a interface inteira chama turno de dia (o botão
	# "Avançar dia", o "Vence no dia 32"), e pôr os dois números lado a lado
	# na mesma peça fez a conta aparecer. Até 12/09 a linha dizia "turnos", que
	# não prometia nada; trocá-la por "dias" foi o que destapou isto.
	#
	# O `por_extenso` fala no FEMININO, que é o que "semanas" e "parcelas"
	# pedem — as duas únicas contagens que sobraram aqui.
	var semanas: String = _maiuscula(por_extenso(_gs().WEEKS_TOTAL))
	# O ARCO, e não o VS. A Fase 1 do GDD tem três parcelas e este jogo paga a
	# primeira — dizer só "Uma parcela" fazia a vitória soar a dívida quitada,
	# que ela não é. O feminino do `por_extenso` serve aqui sem correção:
	# "três parcelas", "faltam duas".
	var total: String = por_extenso(_gs().PARCELAS_NA_FASE)
	var restantes: String = por_extenso(_gs().PARCELAS_NA_FASE - 1)
	var modelo := """%s semanas.

A primeira de %s parcelas.
E ela venceu.

Faltam %s.
Mas a primeira é a que prova que dá.

O {portName} respira.

Ainda tem dívida?
Tem.

Ainda tem Arlindo no horizonte?
Tem.

Mas o cais que o Seu Maneco deixou
ainda é nosso.

—

O píer é o mesmo.

A mesma madeira velha.
O mesmo cheiro de maresia.
Os mesmos trabalhadores que conhecem cada tábua podre de cor.

Mas tem alguma coisa diferente.

Não no píer.

Em quem tá olhando.""" % [semanas, total, restantes]
	return _gs().texto(modelo)


# O texto do diário, com os nomes já resolvidos.
static func diario() -> String:
	return _gs().texto(DIARIO_PRIMEIRA_PAGINA)


# Uma linha da Dona Cida por id de evento. Devolve vazio para id desconhecido
# em vez de rebentar: uma fala que falta é um silêncio, não um crash — e o
# `teste_fumaca` confere que os ids usados pelo jogo existem todos aqui.
static func cida(id: String) -> String:
	return _gs().texto(String(CIDA_LINHAS.get(id, "")))
