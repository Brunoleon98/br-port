---
paths:
  - "brport_vs/scripts/Narrativa.gd"
  - "brport_vs/scripts/Retratos.gd"
  - "brport_vs/scripts/Main.gd"
  - "brport_vs/scripts/NarradoraDaCida.gd"
  - "brport_vs/scripts/TutorialDoToninho.gd"
  - "brport_vs/scripts/PainelBoletim.gd"
  - "brport_vs/scripts/PainelDiario.gd"
  - "brport_vs/scripts/PainelMensagens.gd"
  - "brport_vs/scripts/CounterOfferPanel.gd"
  - "brport_vs/scripts/DebtPaymentPanel.gd"
  - "brport_vs/scripts/EndGame.gd"
  - "brport_vs/scripts/TelaNomes.gd"
  - "brport_vs/tools/medir_boletim.gd"
  - "docs/design/BR_Port_Frontload_Escrita_VS.md"
---

# Regras — narrativa

> Carrega quando a sessão lê ou edita um arquivo do `paths:` acima. Veio do
> `CLAUDE.md` em 10/10, palavra por palavra (`docs/decisoes/091`); o índice
> de todas as regras está no núcleo. Lição nova deste tema entra aqui.

### Narrativa

- **Todo texto de fala vive em `scripts/Narrativa.gd`**, como o ícone vive no
  `Icones.gd`. Fala espalhada por painel é o que aconteceu com os emojis, e
  trocar um custava caçar string por string em sete scripts.
  ⚠️ **E O `get_script_constant_map()` NÃO A LÊ TODA.** A narração do fim de
  fase é um texto LOCAL do `fim_de_fase()`, e o mapa das constantes, que o F4
  usa, não o vê. Catálogo de fala que tem de ser completo lê o ARQUIVO — é o
  que faz a guarda do nome longo no F10 (`053`).
- **O nome do porto e o do jogador saem por `GameState.texto()`**, um lugar só,
  como o dinheiro sai pelo `moeda()`. Os textos trazem `{portName}` e
  `{playerName}`; quem não passar pela substituição mostra a chaveta crua ao
  jogador, e isso não dá erro nenhum. O `teste_fumaca.gd`, bloco F4, tranca:
  todo token tem de ser um dos seis conhecidos, e nada que saia de um
  resolvedor pode ter chaveta.
- **Porto Mirim é a CIDADE; Cais Mirim é o nome-padrão do PORTO.** São coisas
  diferentes e o rascunho de escrita usa as duas. O banco do Sr. Ribeiro é de
  Porto Mirim e não muda; o cais é o que o jogador batiza, e a escolha é
  irrevogável (GDD 7).
- **O nome do jogador pode estar vazio, e nenhum padrão o preenche.** Inventar
  um é pôr palavra na boca de quem não a escolheu. Toda fala com vocativo tem
  variante sem ele — e a vírgula viaja com o nome, senão sai "Boa tarde ,.".
- **Número em prosa sai de constante, nunca escrito à mão.** A narração de fim
  de fase dizia "Doze semanas / Três parcelas", que é a Fase 1 do GDD e não o
  VS. Texto com número cravado é um número a mais para envelhecer — o mesmo
  problema que a tabela dos números existe para resolver.
  ⚠️ **E O VALOR À MÃO COINCIDE COM A CONSTANTE NO DIA EM QUE É ESCRITO**, que
  é o que torna este defeito invisível: uma guarda que compare o NÚMERO passa
  contente (`moeda(400000)` é exactamente o que a prosa diz) e só divergiria na
  sessão seguinte. Quem o pega pergunta pela FORMA — nenhuma fala escreve `R$`
  seguido de dígito —, e é o que o F4 faz desde 11/09 (`docs/decisoes/018`).
- **⚠️ E A GUARDA QUE APANHOU ISSO COBRIA UM PERSONAGEM SÓ.** Em 13/09 o mesmo
  defeito estava vivo ao lado: `ARLINDO_VENCEU` e `ARLINDO_PERDEU` escritas
  desde 01/09 e nunca disparadas — a negociação fechava calada, ganhasse quem
  ganhasse —, e o F4 passava contente porque varre `CIDA_LINHAS` e mais nada.
  É a regra "ao corrigir um, VARRA OS IRMÃOS" aplicada a uma GUARDA em vez de a
  um prop: quem escreve a asserção para uma tabela pergunta logo quais são as
  outras tabelas da mesma forma, senão o defeito sobrevive à sua própria lição.
- **⚠️ FALA ESCRITA NÃO É FALA OUVIDA, e nada perguntava a diferença.** É o
  `barco_medio` na narrativa, e a terceira vez que este projeto o apanha:
  `perdeu_para_arlindo` e `bom_contrato` viviam em `CIDA_LINHAS` desde 01/09 e
  **nenhuma linha do projeto as disparava** — um quarto da voz da Dona Cida em
  jogo, mudo. O bloco do fumaça não podia apanhar, porque perguntava *"todo id
  da tabela tem fala?"*, lendo a tabela dos DOIS lados. A pergunta que pega é a
  inversa, e a sua segunda fonte é o `NarradoraDaCida.gd` (até à `096`, o
  `Main.gd`): a tabela vive na Narrativa e o gatilho na narradora, logo não é
  espelho. **Ao escrever fala nova, escreva o
  gatilho no mesmo commit** — e ao varrer código como texto, corte as linhas de
  COMENTÁRIO antes, senão o próprio comentário que explica a armadilha
  satisfaz a busca.
- **⚠️ E UMA VOZ NOVA NA FAIXA ENTRA EM TODA RÉGUA QUE A LÊ.** O Toninho do
  tutorial (`101`) fala para a mesma fila que o sistema e a Dona Cida, no fim
  do frame, no dia 1 — e o dia 1 é o estado que os blocos de teste montam.
  Na primeira corrida o F8c2 reprovou: o `_f8_drenar()` devolvia «a última
  mostrada», e a última passou a ser ele. O D38 reprovou também, a pedir a
  amostra da voz nova; a sonda da régua da faixa, essa, calava-se: ouvia DUAS
  fontes, e as falas dele chegavam à tela sem nunca terem entrado na conta.
  Quem acrescenta uma fonte à fila varre quem a lê — a sonda, os
  blocos que leem a última mostrada e a amostra do histórico — pela FORMA
  (`apresentou`, `historico`, `fonte`), e não pela lista de quem já se conhece.
- **⚠️ E FALA DISPARADA NÃO É FALA VISTA — a QUARTA cara do `barco_medio`.**
  A de cima pergunta se alguém a dispara, e alguém dispara. Esta é do outro
  lado do frame: **o que sobrou no `Label` depois de TODOS os emits daquele
  evento.** O `GameState` emite o sinal narrativo uma linha ANTES do
  `message.emit` da mesma chamada, e os dois escrevem no mesmo rótulo. Medido
  em 18/09, cinco sementes, partidas inteiras: `upgrade_pronto` escrita 35
  vezes e vista ZERO, `caixa_baixo` 11 e zero, `reputacao_caiu` 12 e zero.
  ⚠️ **E A MEMÓRIA É QUEIMADA JUNTO COM A FALA**: o `_cida_caixa` marca a
  travessia e o `_cida_semana` marca a semana mesmo quando a linha é tapada —
  não é "tapada", é consumida, e não volta naquela travessia.
  ⚠️ **E A REVISÃO CONTOU QUATRO PARES; ERAM CINCO.** Faltavam
  `_fechar_negocio` e `_perder_para_rival`, que chamam `_change_reputation()` e
  emitem `message` logo a seguir — é "ao corrigir um, VARRA OS IRMÃOS" com um
  SINAL no lugar do prop. Quem conserta um par procura os outros pelo PADRÃO
  (sinal seguido de `message.emit` na mesma chamada), nunca pela lista de quem
  já se conhece. O bloco **F8** do `teste_fumaca` tranca isto (`033`).
- **⚠️ E O PREDICADO DE UMA FALA LÊ-SE ONDE ELA É ESCRITA, não onde o sinal
  dispara.** `turn_advanced` sai ANTES de `_check_end() -> _spawn_boats()`, e o
  laço de serviço já esvaziou toda doca sem trabalhador: medido, em **315**
  viradas de turno `docas_esperando()` deu **zero todas as vezes**, e um
  instante depois deu barco à espera em **148 de 310** (48%). Uma variante que
  dissesse *"Barcos na fila"* no instante do sinal seria uma frase que ninguém
  jamais leria — o `barco_medio` outra vez, e desta vez a caminho de ser
  escrito de propósito. **Antes de condicionar uma fala, meça o predicado NO
  INSTANTE EM QUE ELA APARECE** — e se a condição nunca puder ser verdade ali,
  o que está errado é o momento, não a frase.
- **⚠️ E CONSERTAR A ORDEM EXPÕE AS FRASES QUE A ORDEM ESCONDIA.** `caixa_baixo`
  afirma *"A parcela não vai esperar"*, e `pagar_parcela_adiantado()` existe
  desde o playtest: medido com um perfil que quita assim que pode, **12
  travessias com a parcela já paga e ZERO com ela por pagar** — para esse
  jogador a frase era falsa em todas as ocorrências, e estava escondida pela
  mesma mensagem que a engolia. Um defeito de VISIBILIDADE e um defeito de
  VERDADE na mesma fala não se consertam em sessões diferentes: o primeiro
  mascara o segundo, e fechar só o primeiro entrega a frase falsa à tela.
- **⚠️ E DERIVAR O NÚMERO DA CONSTANTE PODE ESTRAGAR A PROSA.** A regra acima
  manda o número sair da constante, e está certa — mas `"%d semanas"` pôs
  **"4 semanas." e "32 turnos de decisão."** na narração de fim de fase, e
  dígito no meio de uma peça literária lê como leitura de instrumento. Pior: a
  guarda que provava a ligação comparava o DÍGITO, então era ela que mantinha o
  defeito de pé — reprovou o texto certo no dia em que ele foi escrito por
  extenso. Derive **e escreva por extenso** (`por_extenso()`), faça a guarda
  procurar a forma escrita, e acrescente a metade que falta: **nenhum dígito na
  narração**, senão ninguém impede o regresso.
- **⚠️ E FALA QUE AFIRMA O ESTADO TEM DE SER VERDADE NO PRIMEIRO TURNO.** O tom
  mau do boletim abre a dizer *"A semana anterior foi melhor"*, e o
  `tom_do_boletim()` escolhia-o só por `resultado < 0`, sem olhar se havia
  semana anterior. Medido em 12/09: quem aloca trabalhador nunca cai ali (0 de
  60 partidas), quem **não aloca ninguém cai sempre** (60 de 60, a −R$16.000) —
  ou seja, quem ouvia a frase errada era exatamente o principiante, no primeiro
  boletim que via. O estado que APERTA uma fala é o mais pobre, não o médio.
  ⚠️ **E o número dentro da fala sai de onde o EVENTO sai.** A mesma varredura
  achou *"Dois contratos recusados essa semana"* num gatilho que é a queda de
  FAIXA da reputação — nunca dois contratos. Não havia o que corrigir no
  número: ele não saía de lado nenhum.
  ⚠️ **E O TOM ESCOLHIDO POR UM NÚMERO AFIRMA MAIS DO QUE O NÚMERO.** O
  boletim escolhia o tom pelo resultado e pela média, e as falas afirmavam a
  semana ANTERIOR e a PARCELA. Medido em 23/09 com `tools/medir_boletim.gd`:
  **2.005 afirmações falsas em 4.000 boletins**, e *"a semana passada foi
  menos pior"* falsa em 856 de 856 — nunca verdade. Cada afirmação de uma fala
  tem de estar numa condição de quem a escolhe; e na régua, ⚠️ **afirmação
  que É a condição do tom é espelho** — ela só reprova quando lê um campo que a
  escolha não leu (`048`).
- **⚠️ FALA QUE NARRA O QUE A TELA JÁ MOSTROU É FALA QUE NINGUÉM PRECISAVA.**
  Queixa do Bruno em 23/09 sobre *"Mas vim pessoalmente porque sei que é o
  primeiro mês"*: o Sr. Ribeiro explicava o próprio gesto, pela segunda vez na
  mesma cena. Vale para toda fala já escrita e para as que vierem. Os sinais:
  abrir narrando o evento (*"Perdeu pro Arlindo"*, *"Os números fecharam"*);
  explicar o motivo do personagem; repetir na resposta o que a entrada ou a
  despedida já dizem; frase que qualquer personagem diria (*"o banco existe
  pra isso"*). **Cada linha traz o que a tela não diz** — um detalhe do mundo,
  uma opinião, um subtexto: *"ele pagava sempre na véspera; dizia que no dia
  já é tarde"* diz mais sobre o prazo do que *"vim pessoalmente"* (`048`).
- **⚠️ PALAVRA DE OFÍCIO NUMA FALA É JARGÃO, e nenhuma asserção a vê.** A
  leitura em voz alta de 19/09 apanhou "caixa": ele é o termo certo, está no
  HUD e no painel da parcela — e só quer dizer *dinheiro* para quem já
  trabalhou com ele. O jogo é de gestão para quem pode não saber finanças, e a
  palavra passou a ser "dinheiro" nas falas. É a irmã da regra abaixo: ali a
  frase é verdadeira em português e falsa neste mundo, aqui é verdadeira nos
  dois e ilegível para quem joga. Só uma pessoa a ler vê qualquer uma das duas.
- **⚠️ E CONDIÇÃO QUE UMA FALA JÁ APRENDEU, A IRMÃ DELA NÃO APRENDEU.** No
  mesmo dia: `caixa_baixo` tinha a variante para a parcela já quitada desde
  18/09, e a fala da SEMANA NOVA — escrita no mesmo commit, a ler o mesmo
  `caixa_curto()` — continuava a dizer "a parcela correndo" a quem já a tinha
  pago. "Ao corrigir um, VARRA OS IRMÃOS" com um PREDICADO no lugar do prop, e
  quem o apanhou foi o Bruno a ler, não uma suíte.
- **⚠️ FRASE QUE VAI AO GATE FOTOGRAFA-SE NO ESTADO EM QUE APARECE.** O A4
  carregou *"0 dias daqui"* por quatro dias como palavra a decidir, e ela nunca
  chegava à tela — a conta só dava zero depois do vencimento. Fotografado o
  painel no dia 32, o defeito era outro: *"1 dia daqui"* no próprio dia em que
  vence, porque a conta contava os dias que ainda se JOGAM (certo para o "N dias
  restantes" do HUD) e "daqui" pede a DISTÂNCIA. **O mesmo número serve a uma
  palavra e mente noutra**; antes de pedir uma decisão de redação, monte o
  estado e leia o que o jogador lê (`037`, T11).
- **⚠️ A FRASE PODE SER VERDADEIRA EM PORTUGUÊS E FALSA NESTE MUNDO.** A Dona
  Cida dizia *"porto que fecha no azul é porto que abre segunda-feira"* — bonita,
  idiomática, e **errada: um porto opera 24/7 e não abre na segunda.** Nenhuma
  das cinco suítes podia apanhar, e nenhuma régua de escrita também: não há
  token cru, não há número à mão, não há contradição interna. Só quem conhece o
  mundo vê. É a razão de o gate do A4 ser uma pessoa a LER, e não uma asserção
  — e a primeira leitura em voz alta (13/09) achou-a à segunda frase.
- **⚠️ E MELHORAR A PROSA PODE INTRODUZIR UM ERRO DE FACTO.** Na véspera, a
  narração de fim de fase dizia *"32 turnos de decisão"* — vocabulário de
  máquina, e trocá-lo por *"Trinta e dois dias"* foi uma melhoria de leitura
  real. Só que "turno" não promete calendário e "dia" promete: logo abaixo de
  *"Quatro semanas"*, a frase passou a afirmar que quatro semanas dão trinta e
  dois dias. **Dão vinte e oito.** O `TURNS_PER_WEEK` é 8 e a interface inteira
  já chamava turno de dia, então a contradição existia dispersa pelo jogo e só
  ficou visível quando os dois números se encostaram na mesma peça. Ao trocar
  uma palavra técnica por uma palavra do mundo, pergunte o que a nova palavra
  PROMETE — e se o resto do jogo cumpre a promessa.
- **⚠️ MANEIRISMO QUE APARECE UMA VEZ NÃO É MANEIRISMO — É TROPEÇO.** O Arlindo
  fechava a negociação perdida com *"sobrinho"*, e a primeira pergunta da
  leitura foi *"como assim sobrinho?"*. A palavra está CERTA e documentada — o
  GDD assina *"chama todo mundo de sobrinho ou querido, independente da
  idade"* —, e mesmo assim a intenção não chegou: no GDD ele fala assim em toda
  cena, no VS diz sete linhas e usa o maneirismo numa. **A dose é parte da
  escrita.** Antes de cortar o que soou estranho, conte quantas vezes ele
  aparece — pode faltar, e não sobrar.
  ⚠️ **E A CORREÇÃO DE ESCRITA É HIPÓTESE ATÉ A LEITURA SEGUINTE.** A de 13/09
  foi de dose — plantar o "querido" na abertura —, e a leitura de 23/09
  tropeçou no MESMO sítio: *"achei estranho ele chamar de sobrinho"*. A
  palavra saiu (é "meu caro", escolha do Bruno). Quem corrige uma queixa de
  leitura pede outra leitura; o raciocínio que justificou a correção não a
  prova.
- **⚠️ CONTAGEM QUE O JOGADOR LÊ CONCORDA A FRASE INTEIRA, e zero leva
  PLURAL.** `Narrativa.concordar(n, um, varios)` recebe as duas frases
  completas — "dia restante" / "dias restantes" —, e não substantivo e adjetivo
  em separado: concordá-los dentro da função obrigaria-a a saber género e a
  distinguir "restante" (que muda) de "esperando" (que não muda), que é um
  dicionário de português. ⚠️ **O singular é SÓ em `n == 1`**, e o zero é o
  ÚNICO estado em que um `n <= 1` escrito por distração diverge — com 1, 2 e 32
  as duas versões dão o mesmo texto (`docs/decisoes/037`).
  ⚠️ **E A BUSCA PELA PEÇA ACHA MENOS DO QUE A BUSCA PELA FORMA.** A revisão
  nomeou TRÊS rótulos; o `grep` por `(s)` achou **cinco** (dois deles no
  `GameState.gd`, que ninguém tinha aberto); e o `grep` pela FORMA achou
  **oito** — os últimos três escreviam a concordância com um ternário à mão
  (`"" if n == 1 else "s"`), com saída certa e a regra duplicada em cinco
  sítios. Num deles a MESMA condição estava escrita duas vezes na mesma
  expressão, uma para o substantivo e outra para o particípio. Hoje quem
  pergunta é o bloco **F9** do `teste_fumaca`.
  ⚠️ **E A FORMA TINHA TRÊS CARAS, e o F9 conhecia duas.** O número seguido
  de plural fixo («%d dias») não deixa `(s)` nem `else "s"`: a revisão nomeou
  dois sítios e a forma achou seis, um em CAIXA ALTA («%d BERÇOS»), mais um
  ternário de palavra inteira que a asserção «nenhum ternário à mão» não via —
  o nome dela prometia mais do que perguntava (`090`).
- **⚠️ QUEIXA DE ESTRANHEZA PODE SER LACUNA, e aí não há rótulo a corrigir.** A
  triagem leu *"é estranho o porto ter dívida mas o jogador começar com
  R$400.000"* como um nome errado e propôs chamar EMPRÉSTIMO ao caixa — que
  contradizia o contrato herdado que o Sr. Ribeiro cobrava na `018`.
  Não faltava rótulo: **faltava uma frase a dizer de onde vinha o dinheiro**.
  Antes de renomear o que o jogador achou estranho, leia o que o jogo já diz.
  Em `085`, Bruno mudou explicitamente o contrato: caixa de abertura é um
  empréstimo para reconstruir, pago nas três parcelas da Fase 1. Diário,
  banco e painel precisam contar o mesmo contrato, com valor recebido e total
  contratado derivados das constantes; novos empréstimos continuam pendentes.
