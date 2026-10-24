# 137 — Os testes mais rápidos sem tirar prova: cópias, fatias e o relógio fixo

**24/10/2026.** Main `bf2eafe` ao abrir; o PR #149 (as estradas, `136`) foi
levado a verde nesta conversa — os 166 mutantes em 100,4 min — e fundido
pelo Bruno (`b0ae8ee`), e a branch avançou para ele. Pedido do Bruno:
*pesquisar e analisar meios de ACELERAR OS TESTES — os que as IAs correm no
contêiner e os que o GitHub corre no CI*; a meio, *«sem perder a eficácia,
pois não adianta eles serem mais rápidos mas passarem bugs»*, e *«veja se
faltam testes para ver bugs em partes que não têm teste ainda»*. F1 a F4,
depois a implementação do que ele escolheu. As medições, os dados e as
ferramentas de medição estão em `docs/arquivo/MEDICOES_VELOCIDADE_TESTES_2026-10-24/`.

## O que a medição disse

**Um mutante custa a suíte que o reprova, e quase nada mais.** No CI do
PR #148 foram ~34 s cada, o tempo da suíte; o arranque do Godot é 0,8 s.
Reaproveitar um Godot vivo pouparia ~3%, com o risco de estado entre
corridas — **descartado**. O cache do `.godot/` importado pouparia 25 s por
job — **descartado**.

**O caminho crítico de um PR era o job dos mutantes:** 90 min para 158 no
#148, 100 min para 166 no #149, contra 18 da captura (o commit e a base em
série) e 8 da suíte. O catálogo cresceu de 37 para 166 em nove dias.

**E os núcleos estavam parados.** Quatro suítes ao mesmo tempo, em quatro
cópias do repositório, atrasam-se 0–10% umas às outras: o catálogo inteiro em
quatro cópias levou 30,8 min de parede para 120,4 de Godot somados — 98% dos
quatro núcleos —, os 158 reprovados pela guarda declarada.

**Em `--headless` o motor dorme até 6,9 ms por frame**, e o `run_tests`
passava ~12 s assim. Zerar o sono reprovou o F10, que conta frames: cada
frame passou a valer menos tempo de jogo. O `--fixed-fps 60` faz as duas
coisas de uma vez — passo de 1/60 s e nenhum sono (o `--help` do 4.6.3:
*«disables real-time synchronization»*) —, e é o relógio que a captura já
usava. As seis suítes passaram de 118,1 s para 96,6 s, e o catálogo de 158
reprovou pelas MESMAS guardas declaradas, em 24,8 min de parede.

**Os dois blocos mais pesados são prova, não desperdício.** O T26 gasta
metade do tempo a gravar e reler o save a cada passo, que é o invariante
«o save que o jogo grava, o jogo aceita»; o D35 gasta 22 dos 27 s a andar os
camiões 5400 s. Encurtá-los é conferir menos. O laço dos 2931 tweens
acumulados do D35 custa 4,5 s, e fica de fora (abaixo).

**A seleção por diff não paga o que tira.** Simulada nos últimos quinze PRs,
sete correriam o catálogo inteiro na mesma (tocaram o workflow, o executor
ou o `project.godot`), e nos outros a prova de um defeito INDIRETO — a regra
que passa a viver em dois sítios — sairia do PR para depois do merge. A
pesquisa diz o mesmo da literatura: «fazer menos» (amostrar mutantes, podar
testes) é o que perde defeitos (Gopinath et al.; os estudos de minimização
medem de quase nada a 88%), e o que não perde é paralelizar e executar mais
barato.

## A escolha do Bruno

Das quatro opções, com o custo, o ganho e o risco de cada uma, ele escolheu
três: **paralelo + matriz, `--fixed-fps 60` e captura em paralelo.** Ficaram
de fora os extras — parar a suíte quando a guarda declarada reprova (−24% do
tempo de mutante) e o laço do D35 (−4,5 s por `teste_design`).

Medidas as lacunas, escolheu mais três coisas: **fechar as treze graves antes
dos sprites de detalhes** — cada uma com a guarda e o defeito no catálogo —,
**abrir o PR** desta branch, e **as suítes em paralelo para os agentes, não
agora**. A meio, a pergunta dele — *«como assim à espera da bateria e da
amostra»* — pôs na `gerais.md` que trabalho em fundo se descreve pelo que
prova e quanto falta.

## O que mudou

- **`tools/conferir_mutantes.py`**: `--trabalhadores N` copia a árvore N
  vezes (sem o `.git`), exige cada cópia igual à original byte a byte e corre
  em cada uma o executor DELA, em série e sem mudança nenhuma no julgamento;
  o original nunca é tocado. `--fatia I/K` toma a I-ésima de K fatias, em roda
  por suíte e por id, sem tempo nem peso escrito à mão. `--juntar` recalcula
  as fatias e exige que as K pastas somem o catálogo, sem falta, repetição ou
  troca, cada mutante aprovado pelas suítes declaradas. E recusa o
  `testes.yml` que não corra as seis suítes com o relógio dele.
- **O marcador do trabalhador não é o do job.** O pai repassa a saída de
  cada cópia com `[tN]` à frente e não repassa o `MUTANTES OK` dela; o CI pede
  o marcador no início da linha. Sem as duas coisas, dois trabalhadores
  verdes e um furado davam o job por verde — o `grep -q "MUTANTES OK"` de
  antes casava com qualquer um (`gerais.md`, «um marcador novo pode conter
  um velho»).
- **`testes.yml`**: as seis suítes com `--fixed-fps 60`; o job dos
  mutantes passa a uma matriz de três fatias, cada uma com quatro
  trabalhadores e teto de 45 min, e o job `mutantes-juntos`, com o nome que o
  job único tinha, junta-as; o push novo de um PR cancela a corrida do
  anterior (também no `captura.yml`); e o autoteste do executor corre no
  início do job das suítes.
- **`tools/capturar_evidencia.sh`**: quatro tiros de cada vez, cada um com o
  seu `user://`, a sua sentinela do jogador plantada e conferida, e a sua tela
  virtual com número próprio; barreiras onde um passo lê os tiros de antes.
  `PARALELO=1` volta à série.
- **`tools/testar_conferir_mutantes.py`**: motor e repositório falsos, em
  segundos; espera `EXECUTOR PROVADO`.
- As receitas: o `CLAUDE.md`, o `AGENTS.md`, as skills, o hook, o
  `COMO_RODAR.md` e os cabeçalhos das suítes com o relógio; a receita de uma
  captura à mão desceu para a `captura.md` (o teto do que carrega sempre).

## Os defeitos injetados

Dezassete, cada um entre bases verdes, o original guardado com `cp` e conferido
por sha256 na volta, e cada um reprovado pelo caso que o nomeia: o código de
saída do trabalhador ignorado; o marcador dele ignorado; o relatório dele
ignorado; o marcador repassado sem neutralizar; o `--juntar` sem a fatia em
falta, sem recalcular a partilha, sem conferir a aprovação, aceitando a fatia
repetida; o relógio do CI não conferido; o `fatia.json` escrito antes do
verde; a partilha sem ordenar; a cópia que leva o `.git`; o `grep` da fatia
sem âncora; a matriz de duas com a fatia `/3`; o `testes.yml` real sem o
relógio no `run_tests`; e os dois da cópia recusada com trabalhadores vivos
(abaixo, na prova). Este último passou o primeiro autoteste — o caso do
relógio usava um workflow falso —, e o executor de verdade já o reprovava no
job das fatias (seis queixas, nada injetado); o autoteste passou a conferir
também o arquivo real.

O marcador e o relatório do trabalhador são cercas que o executor de hoje
nunca põe à prova — ele nunca sai com zero sem as duas coisas. Para não
serem confiança de graça, o autoteste remenda o executor da cópia falsa para
mentir de cada uma das formas, e o pai reprova.

**E um defeito apanhou-se a medir, não a injetar:** a limpeza que o
paralelo pôs na bateria corria `kill` sem processos no fim, e com `set -e`
isso derruba o trap com código 2 — a bateria inteira verde, `COBERTURA OK`,
saía com 2 e deixaria o CI vermelho. Uma sonda de uma linha reproduziu-o;
`|| true` corrigiu.

## A prova

- **O catálogo inteiro pelo executor novo, como o CI o corre:** as três
  fatias, cada uma em quatro cópias, `MUTANTES OK` em 645, 685 e 645 s
  (56 + 55 + 55), e o `--juntar` das três pastas: *«MUTANTES OK — 166
  defeito(s) do catálogo em 3 fatia(s)»*. Em série, aqui, seriam ~2 h.
- **A bateria de fotos:** 107 de 107 iguais ao byte entre `PARALELO=1` e
  `PARALELO=4`, e outra vez numa segunda corrida em paralelo; código 0 e
  254 s com a máquina livre.
- **O autoteste:** `EXECUTOR PROVADO`, doze casos; `GUARDAS OK`; `DOCS OK`.
- **O CI do PR #150, a primeira corrida no runner** (`b88027b`, corrida
  40061228980): o passo dos mutantes levou **8:30, 14:38 e 8:50** nas três
  fatias (55 ou 56 cada, quatro cópias), e o `--juntar` 13 s — *«MUTANTES OK
  — 166 defeito(s) do catálogo em 3 fatia(s)»*. O job dos mutantes acabou
  aos **15:37** da corrida, contra 100,4 min no #149. A fatia 2 levou 1,7×
  as outras com o mesmo número de mutantes, e os quatro trabalhadores dela
  atrasaram-se juntos: lê como máquina mais lenta e não como partilha
  torta — e a segunda corrida (`34c0fcf`, as mesmas fatias) separou-o:
  8:48, 10:00 e 9:33. As suítes no runner, com o
  relógio fixo: 19 / 39 / 12 / 11 s (`run_tests` / `teste_design` /
  `teste_fumaca` / `asset_validator`); o job «Godot headless» 7:18, o
  export 1:27. **A captura em paralelo ganhou menos lá do que aqui:** este
  commit fotografado em **6:17**, a base em série (o script dela) em 8:58 —
  no #148 eram 8:26 e 8:25. Aqui o paralelo dava ~3×; no runner dá 1,4×,
  com o rasterizador por software a dividir os mesmos núcleos. A «Evidência
  visual» (16:16) passou a ser o job mais longo do PR, e encolhe quando a
  base também fotografar em paralelo, no PR seguinte a este fundir.

**E a cerca da cópia reprovou de verdade no dia em que nasceu.** A regra de
testes foi editada enquanto o pai copiava a árvore para a fatia 3: os hashes
eram de antes e a t3 já trazia a edição, e o executor recusou provar uma
árvore que não era a pedida — e o `--juntar` deu pela fatia em falta. Só que
a t1 e a t2 já corriam, e o pai saiu sem as parar: dois órfãos a escrever
nas pastas da corrida seguinte (o `rm` dela bateu num). Hoje todas as cópias
se fazem e conferem antes de o primeiro trabalhador arrancar, e a pasta de
cada um começa vazia; o autoteste reinjeta o executor de antes e a recusa
que segue em frente, e reprova os dois. A fatia 3 correu outra vez, limpa.
(O contêiner reiniciou a meio dela uma vez antes disso; a 1 e a 2 ficaram
no disco, e o `--juntar` leu-as — a fatia também serve para retomar.)

## As lacunas

A outra metade do pedido mediu-se de duas maneiras, e está no README das
medições. **As seis suítes executam 98% das funções do jogo** (741 de 757);
a pergunta é se conferem o que executam. **Numa amostra de 205 defeitos
plausíveis, sorteados com semente nessas funções, 106 foram apanhados e 99
passaram nas seis suítes — 56% sem os 15 equivalentes.** A lógica que as
suítes perguntam está guardada; o que escapa é o que os painéis mostram e o
que os botões fazem, as preferências que se gravam, o som que se agenda e a
telemetria do playtest. Treze são de gravidade alta (a tabela está no README).

## O que fica de fora

- **Parar a suíte quando a guarda declarada reprova** (−24% do tempo de
  mutante com o passo fixo) e **o laço do D35** (−4,5 s): não escolhidos.
- **As seis suítes em paralelo para os agentes** (118 → 56 s, medido): o
  Bruno disse «não agora»; é o próximo passo barato, com um `user://` por
  suíte.
- **O teto de cada fatia (45 min) fica largo**: a mais lenta da primeira
  corrida levou 14:38 (acima, na prova).
- **O catálogo continua a crescer**: a matriz escala por K, e o K vive em
  dois sítios do `testes.yml` que o autoteste exige iguais.
