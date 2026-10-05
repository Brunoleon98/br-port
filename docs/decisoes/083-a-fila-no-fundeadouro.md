# 083 — A fila no fundeadouro: atracar passa a ser a escolha

**04–05/10/2026 · terceira parte da melhoria de design** (plano v3, §7): a
conversa abriu com a pergunta do escopo, e o Bruno escolheu **o design de
jogo** (a recomendada), entre ele e o mapa e os props. **Aceite do Bruno em
05/10**, na quarta passagem da tela.

## Por que mexer no verbo do dia

Medido antes de propor: **trabalhadores = docas, sempre** (cada píer traz o
seu), e o «Alocar todos» **acertava sempre** — não havia combinação melhor do
que pôr toda a gente em todo barco. O verbo central do jogo era uma tarefa,
não uma escolha. As duas partes já feitas (`081`, `082`) só tinham mexido no
visual.

## O que o Bruno escolheu

| Pergunta | Resposta |
|---|---|
| A parte | **Design de jogo** (a recomendada) |
| Por onde | **Alocar vira escolha** (a recomendada), contra «diagnosticar primeiro» e os itens do playtest 2 |
| A mecânica | **A fila no fundeadouro** (a recomendada, do GDD: «Prioridade de doca»), contra especialidades e mais gente por píer |
| O alcance | **Mecânica + medição + tela** (a recomendada); o barco a deslizar do largo ao berço fica para a passagem seguinte |
| Como se atraca | **Um toque, e o trabalhador vai junto** (a recomendada): o «Alocar todos» deixa de existir |
| Onde fica a fila | **No lugar dos trabalhadores** (a recomendada): a linha «Ao largo», e o retrato passa para dentro do cartão da doca |
| Onde cai o Arlindo | **No barco que chega ao largo** (a recomendada) |
| Como se compensa a receita | **Contratos mais baratos** (a recomendada), contra subir a parcela e menos barcos a chegar |
| Veredito da primeira passagem | **«Ajustar»**, com os quatro: retrato maior na doca, «dias» também na doca, casco maior na fila, o 3.º barco no mapa |
| Onde fica o 3.º barco | **B, acima e à direita** — o Bruno trocou a recomendada (A, abaixo, na linha dos dois) pela B: a ordem da fila deixa de se ler pela posição, e quem a diz é o cartão |
| A parcela, com o Descuidado a 41,5% | **Fica em R$530.000** (a recomendada) |
| Veredito da segunda passagem | **«Ajustar»**: «dias» também com acordo, o lugar livre mais discreto, o casco ainda maior, o retrato maior ainda |
| Veredito da terceira | **«Ajustar»**: os cascos na mesma escala, o nome do porte maior, e no «Outro»: *«Melhore o texto, parece bem simples e pode ser melhorado»* |
| Veredito da quarta | **«Aceito»** |

## A regra

- **Três lugares ao largo** (`FILA_LUGARES`). Cada lugar vazio recebe um barco
  com probabilidade **0,75** por dia (`BOAT_ARRIVAL_CHANCE`, agora POR LUGAR);
  a chegada nunca põe barco direto na doca.
- **Cada barco espera dois dias** (`PACIENCIA_FILA`). O que não for chamado
  sai ao fim deles: conta como barco perdido, no dia que fechou, e custa a
  reputação de um barco perdido (`REPUTATION_LOSS_LOST`).
- **Tocar num barco atraca-o no primeiro berço livre, com o trabalhador do
  píer** (`id = doca + 1`; os outros só se ele faltar). Os dias de operação
  contam-se no porto de HOJE: o barco que chegou antes do pórtico descarrega
  com ele.
- **Tocar na doca devolve o barco ao largo** — só antes de o trabalho começar
  e com lugar na fila. É o desfazer de um toque errado, não uma segunda
  mecânica.
- **A oferta do Arlindo cai no barco que CHEGA** à fila, a 30%, antes de o
  jogador o escolher. Ganha, o barco fica ao largo com o preço fechado; perde,
  sai da fila para o Porto Farol. Um barco sob oferta não se atraca.
- `SAVE_VERSION` **10**: a fila e o índice da oferta entram no save, e o
  `_save_aceite` recusa uma fila maior do que os lugares, um barco sem
  paciência e uma oferta fora da fila — antes de escrever seja o que for.

## A medição — 600 partidas por perfil, semente 20260825

Os perfis do simulador passaram a ESCOLHER: o Ótimo chama o barco que mais
rende por dia de berço, o Mediano e o Antecipado o mais caro, o Descuidado
quem chegou primeiro; e cada berço livre tem a chance de esquecimento de cada
perfil.

**O controle — a fila com os contratos de antes — deu 100 / 100 / 55,8%.** A
fila FACILITA, por dois caminhos: chega mais barco (com um lugar por barco e
três lugares, o Mediano atende **46,5** barcos contra **35,5** na `main`), e
quem escolhe chama o caro (1,08× o valor médio de quem chega, medido já com
os contratos novos). O alvo da `005` (~100 / ~80 / ~35) saiu pela janela, e a
pergunta passou a ser qual botão o traz de volta.

**Chegada e paciência não movem a linha** (300 partidas cada):

| Chegada \ paciência | 1 | 2 | 3 |
|---|---|---|---|
| 0,50 | 99,7 / 88,7 / 51,0 | 99,7 / 96,0 / 50,0 | 100 / 96,3 / 56,0 |
| 0,60 | 100 / 98,7 / 51,3 | 100 / 99,3 / 52,7 | 100 / 99,7 / 55,0 |
| 0,75 | 100 / 100 / 52,3 | 100 / 100 / 54,7 | 100 / 100 / 55,0 |
| 0,90 | 100 / 100 / 57,7 | 100 / 100 / 54,7 | 100 / 100 / 54,7 |

O Descuidado fica entre 50 e 58% em toda a grelha: ele perde barcos por
esquecer o berço, não por falta de barco ao largo.

**A parcela move só o Descuidado** — é a `008` outra vez (a mediana do Mediano
fecha muito acima dela):

| Parcela | Ótimo | Mediano | Descuidado |
|---|---|---|---|
| 560.000 | 100 | 100 | 42,3 |
| 590.000 | 100 | 100 | 29,3 |
| 620.000 | 100 | 100 | 11,7 |

**Os contratos movem os dois**, e é o botão que se escolheu:

| Fator nas faixas | Ótimo | Mediano | Descuidado | Margem em regime (Ót. / Med. / Desc.) |
|---|---|---|---|---|
| 0,70 | 100 | 65,3 | 32,7 | 523k / 433k / 91k |
| 0,71 | 100 | 77,5 | 41,5 | 539k / 451k / 94k |
| **0,72** | **100** | **78,7** | **41,5** | **538.184 / 451.322 / 94.955** |
| 0,74 | 100 | 86,5 | 49,3 | 561k / 470k / 97k |
| 0,76 | 100 | 90,0 | 50,2 | 576k / 491k / 99k |

**Ficou 0,72**: pesqueiro R$9.000–20.000, cargueiro R$16.000–36.000, longo
curso R$40.000–63.000 (cada um `# TUNING`). **100% / 78,7% / 41,5%**, com a
mediana do Mediano em **R$629.683** contra a parcela de R$530.000, e a margem
em regime a separar o porto bom do pobre por **5,7×** (R$538.184 contra
R$94.955). A fila pede escolha em **58,1%** dos dias do Mediano e em 91,5% dos
do Descuidado (que deixa barco ao largo por esquecimento).

⚠️ **O Descuidado ficou seis pontos acima dos ~35.** O que o leva lá é a
parcela, não os contratos, e a conta está medida: a **R$545.000** dá 74,0 /
32,2 e a **R$555.000** dá 71,7 / 26,8 — o Mediano paga cinco a sete pontos por
isso. **O Bruno escolheu ficar a R$530.000**: é o ponto mais perto do alvo no
total (1,3 + 6,5 pontos contra 6,0 + 2,8), e o jogo continua tranquilo.

**O prémio da escolha é medido e entra no projetor.** O
`projetar_parcelas.py` modela a margem com o valor MÉDIO de quem chega, e
reprovou o Mediano por 5,5% com a fila: quem escolhe o caro atraca acima da
média. O simulador publica `premio_da_escolha` (valor do atracado sobre o de
quem chega) — 1,028× o Ótimo, 1,083× o Mediano, 0,970× o Descuidado — e o
projetor multiplica por ele, sem valor por omissão.

## A tela, como ficou na quarta passagem

- **A linha «Ao largo»** ocupa a dos trabalhadores: três cartões com o casco,
  o porte a 14 px («Bote», «Traineira», «Arrasteiro» — do mesmo
  `porte_do_barco()` que escolhe o casco), o valor, **«Pescado · fica 1 dia»**
  (quanto tempo prende o berço) e **«aguarda mais 1 dia»** ou **«vai embora
  hoje»** em âmbar, que é a linha que muda a escolha. Sob oferta, o cartão
  veste o do rival e diz **«Arlindo quer este cliente»**; vazio, é uma **«vaga
  no fundeadouro»** sem fundo e de borda tracejada.
- **Os cascos estão todos na mesma escala**: o maior recorte da frota enche os
  70 px (o longo curso), e o bote sai com 33 — o porte lê-se pelo tamanho antes
  do nome. Até à terceira passagem cada casco esticava até à caixa.
- **O título diz QUAL doca**: «Doca 1 livre — escolha quem atraca», em âmbar;
  «Ao largo — à espera de doca livre»; «Ao largo — ninguém fundeado hoje»; e,
  com o único barco nas mãos do Arlindo, «Ao largo — o Arlindo disputa um
  cliente». A primeira versão dizia «os berços estão ocupados» também aí, com
  o berço livre.
- **A doca diz quando o berço volta a abrir**: «Armazenagem · parte em 2
  dias», «parte amanhã»; livre, «livre — chame um barco» (ou «ninguém ao
  largo»); fechada, «píer em ruínas». O retrato do trabalhador mora no
  cabeçalho, numa placa de **52 px** (30 na primeira passagem, 44 na segunda),
  e a linha de baixo diz «#2 · descarregando», «#2 · toque p/ devolver» ou, com
  acordo, «acordo · toque p/ devolver».
- **Os barcos da Zona de Espera são a fila**: três, um por lugar, cada um com o
  casco do barco que lá está, e água vazia onde o lugar está vazio. Antes eram
  dois cenários com a classe mais alta que o porto recebia.
- **Os 22 px que a doca e a fila cresceram saíram das folgas** do rodapé: do
  mapa às docas 10 → 6, os vãos de baixo 8 → 6, a margem inferior 25 → 15.
- Saíram o cartão do trabalhador, a vaga, a seleção por toque, o arrasto e o
  «Alocar todos», com as variações do tema que só eles vestiam.

## O que fica para depois

- **O barco a deslizar do fundeadouro ao berço** — escolha de alcance do Bruno.
- O `PainelDocas` ainda sabe dizer «sem trabalhador»: deixou de ser alcançável
  (o trabalhador vai com o barco) e ficou, porque é o painel que diz a verdade
  se a regra mudar.

## As guardas, e o defeito que cada uma apanhou

Cada mutante correu contra a suíte que o devia ver, com a base limpa conferida
antes (a mesma suíte verde) e o original guardado com `cp`:

| Mutante | Quem reprovou |
|---|---|
| `atracar()` sem pôr o trabalhador | T4d (cinco asserções, e o T6: «serviram barcos (0)») |
| A equipe do píer ignorada — vai sempre o primeiro livre | T4d, «o berço 2 chama o trabalhador 2» — **depois de a guarda ser refeita** (abaixo) |
| `atracagem_pendente()` a contar um berço só | T5h |
| A desistência sem custo de reputação | T4d |
| O `_save_aceite` sem o teto de lugares | F3, «mais barcos do que lugares» |
| O `_save_aceite` sem a faixa da oferta | F3, «oferta fora da fila» e «abaixo de -1» |
| O título a contar berços em vez de nomear docas | D9, nos dois estados (uma doca livre; a 1 e a 3) |
| Dois espaços no «parte em N dias» | D18, 205 de 200 px |
| Dois espaços no «· acordo» da espera | D18, 202 de 200 px |
| O caso «vai embora hoje» do D33 sem a virada | D33, «pediu "vai embora hoje" na tela e nenhum rótulo o mostra» |
| O projetor sem o `premio_da_escolha` | Mediano a 5,5%, `FORA` |

⚠️ **A guarda da equipe do píer passou verde com o defeito posto na primeira
versão.** Ela punha os berços 1 e 2 ocupados pelos trabalhadores 2 e 1 e
jurava no comentário que «o primeiro livre» daria outra resposta — mas o único
livre era o 3, e as duas regras davam o mesmo. Com os berços ocupados pelos
seus, as duas coincidem SEMPRE; o estado que as separa é um trabalhador fora
do sítio (o berço 1 com o 3), e é esse que a guarda monta hoje.

⚠️ **O D18 media cópias.** Escrevia à mão os formatos do cartão da doca e da
fila, e o acordo a mudar de linha teria passado verde com a cópia velha. Os
textos dos dois cartões são hoje funções estáticas
(`DocaCartao.texto_do_progresso()`, `BarcoFila.texto_da_espera()` e as
irmãs), e o D18 mede o pior caso chamando-as.

E duas guardas novas da sessão sem mutante próprio, por serem a mesma pergunta
de outras: o F3 da fila (sete saves impossíveis recusados sem tocar no turno,
e os dois válidos a entrar) responde pelos mutantes do `_save_aceite` acima; e
o D43 do lugar livre recua por construção (sem fundo, a razão é 1,00).

**Fica de fora**: nada pergunta que os cascos estão na mesma escala — a prova é
a foto, e a regra «nem tudo o que se mede precisa de asserção» (`CLAUDE.md`).
