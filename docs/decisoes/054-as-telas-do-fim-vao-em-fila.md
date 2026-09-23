# 054 — As telas do fim vão em fila

**23/09/2026 · opção (b) do briefing que fechou a sétima sessão, decidida pelo
Bruno:** «em fila» — resposta do Sr. Ribeiro → boletim da semana 4 → fim de
fase, uma de cada vez.

## O que se decidiu

**O `Main` põe em fila as três telas que abrem sozinhas** — o Sr. Ribeiro, o
boletim e o fim de fase (`_na_vez()`). Quem tem a vez fica na tela; quem chega
depois espera, por ordem de chegada, e abre quando a anterior sai. Os três
caminhos que acabam a partida com a semana a fechar ficam assim:

| caminho | antes (de baixo para cima) | depois (uma de cada vez) |
|---|---|---|
| «Pagar» | Ribeiro · boletim · **fim de fase** | Ribeiro (pagou) → boletim da semana 4 → fim de fase |
| «Não consigo pagar» | Ribeiro · boletim · **fim de jogo** | Ribeiro (não pagou) → boletim → fim de jogo |
| quitou antes do prazo | boletim · **fim de fase** | boletim → fim de fase |

**Nada mudou no `GameState`.** Os sinais saem na ordem de sempre —
`pay_debt()` → `_fechar_resumo_da_semana()` → `_check_end()` —, e quem decide o
que vai para a tela é o `Main`. O simulador não abre painel, logo não tem o que
medir: é a regra «tela nova é overlay» aplicada à ORDEM das telas.

## Por que

O toque só alcança o painel de cima, e o fim de fase oferece «Jogar de novo»:
quem o tocava nunca lia a resposta do banqueiro, reescrita na `048`, nem o
último boletim. A foto `balanco` da sétima sessão mostrou a pilha — três
painéis — e deixou a ordem como pergunta.

## Como

- **A contra-oferta do Arlindo fica fora da fila.** É uma decisão que trava o
  turno, e pô-la atrás de um boletim mudaria uma ordem a meio da partida que
  ninguém pediu para mudar.
- **Quem passa a vez é o `tree_exited`, não o `fechou`.** É o único sinal por
  onde passa toda saída: o `_fechar()` do andaime, o `queue_free()` seco do
  «Fechar» do fim de fase e o `remove_child()` com que as ferramentas de
  captura dispensam o boletim.
- **Se o próprio `Main` está a sair da árvore, a fila não abre ninguém.**

## As guardas

**F11** no `teste_fumaca` percorre a fila pelos botões do jogador, nos três
caminhos, com um `Main` vivo. Cada passo pergunta **sozinho** e não só «por
cima» (sem a fila, a resposta do Sr. Ribeiro continua lá, por baixo), e a
ordem pergunta-se passo a passo. O boletim confere-se pela semana do resumo
que recebeu. Cada caminho corre mesmo que outro reprove, e sai com `true` em
toda saída: só um erro de execução devolve outra coisa.

**O tiro `balanco`** da bateria de captura percorre a mesma fila com os mesmos
passos, e a contagem passou de 3 painéis para **1**.

| mutante | F11 | tiro `balanco` |
|---|---|---|
| M1 sem fila (abre sempre) | os três caminhos | reprova depois do «Pagar» (3 painéis) |
| M2 a fila serve o último a chegar | pagou, não pagou — **o terceiro passa**: nele nunca há dois à espera | reprova no passo 1 (fim de fase antes do boletim) |
| M3 o Sr. Ribeiro abre fora da fila | pagou, não pagou — o terceiro não tem Sr. Ribeiro | reprova depois do «Pagar» (2 painéis) |
| M4 o fim de fase abre fora da fila | os três caminhos | reprova depois do «Pagar» (2 painéis) |
| M5 a vez passa pelo `fechou` | **passa** — a jogar, toda tela da vez sai pelo `_fechar()` | reprova: vencimento em `debt_payment` **sem painel nenhum**, o Sr. Ribeiro preso na fila |
| M9b a última semana fecha depois do fim, só no `advance_turn()` | **só** o terceiro caminho | não corrido |
| T1 erro de execução no terceiro caminho | a bandeira do bloco | não corrido |

M9, o primeiro desenho do M9b (adiar TODO fecho de semana), estragou também a
montagem dos outros caminhos e não isolava nada — daí o estreito.

A guarda `is_inside_tree()` mediu-se numa sonda: sem ela, libertar o `Main`
com dois painéis na fila dá *"Parent node is busy setting up children,
`add_child()` failed"* e deixa 36 nós órfãos. Não tem asserção: quem a exerce
é uma suíte a libertar o `Main` a meio da fila, e isso só acontece depois de
outro vermelho.

Base verde antes da leva e no fim dela; entre um mutante e o seguinte o
original voltou por `cp`, e o `cmp` conferiu-o byte a byte contra a cópia
tirada da base verde.

## O que fica de fora

- **Um save carregado em `game_over` abre só o fim de fase**, como antes: o
  save não guarda painéis, e o boletim da semana 4 e a resposta do Sr. Ribeiro
  não voltam.
- **O botão Voltar continua sem efeito fora de `"playing"`** (T5g), e a fila
  corre toda em `game_over`: no telefone, cada tela sai pelo botão dela.
- **Se a partida acabar por falta de dinheiro a meio da semana**, não há
  boletim, e o fim de jogo abre direto, como antes.
