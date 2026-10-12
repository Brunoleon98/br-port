# 102 — A segunda chance do Sr. Ribeiro: o crédito opcional da frente 5

**12/10/2026.** Base `6178a4e` (o PR #125, o tutorial do Toninho, fundido);
102 livre conferida na main pelo GitHub, sem PR aberto do Codex. Recorte da
frente 5 escolhido pelo Bruno nesta conversa, entre crédito opcional,
cancelamento de trabalho, mais trabalhadores por píer e a progressão das
fases. As três falas do Toninho (A4) ainda não foram lidas em voz alta.

## O que se leu antes de perguntar

O GDD dá ao Sr. Ribeiro linhas de empréstimo (`gdd/conceitos/banco_investimentos.md`:
a Linha Porto, fases 1–2, a 3%/semana, só com o histórico limpo) e, à dívida,
válvulas de escape — a primeira é a **renegociação única**
(`gdd/conceitos/dividas.md`). O atraso de uma semana é «cena tensa, sem
penalidade mecânica». O plano guardava o pedido do Bruno de 23/09 com outras
palavras: *«segunda chance com empréstimo caro»* (§5, item 5).

E três leituras do jogo de hoje mudaram o peso das opções:

- **Na Fase 1 todo serviço acaba no dia em que se avança.** O nível máximo é
  1 (`FASES`), só o pesqueiro atraca, e o pesqueiro serve num turno. Não há
  trabalho a cancelar, e um segundo trabalhador no mesmo píer não acelera
  nada: os dois recortes só ganham sentido quando houver barco de dois dias,
  que é a Fase 2.
- **Quem trava a obra é o calendário, não o dinheiro.** Píer 2 e armazém
  custam R$330.000 e o jogador começa com R$400.000; o pátio abre no dia 29
  depois da primeira quitação. Uma linha voluntária para construir antes
  quase não teria uso até haver mais o que construir.
- **Nenhum perfil chega perto de não pagar.** Na medição em vigor (`087`), o
  P10 do caixa na decisão, entre os quatro perfis e as três cobranças, nunca
  fica abaixo de R$175.244 para uma parcela de R$140.000. Quem perde o porto
  numa cobrança é o jogador de verdade que errou — e hoje perde tudo: o
  `fail_debt()` encerra a partida no dia 28 tal como no 84.

## As quatro respostas do Bruno

| Pergunta | Resposta (todas as recomendadas) |
|---|---|
| O recorte da frente 5 | **Crédito opcional** |
| A forma | **Segunda chance**: no vencimento, se faltar dinheiro, o Sr. Ribeiro oferece um empréstimo caro no lugar de «Porto perdido». Uma vez por fase. Recusar continua a perder o porto |
| Quanto cobre e quando volta | **O que falta mais uma semana de custos**, devolvido **junto com a próxima cobrança**. Vale nas parcelas 1 e 2; a da semana 12 não tem próxima até a Fase 2 existir, e fica como hoje |
| O custo | **+12% fixo** — os 3%/semana da Linha Porto, quatro semanas, num número só no painel |
| O save | **Versão 15, com o degrau 14→15**: as partidas em curso continuam |

A linha voluntária, o cancelamento, os trabalhadores extras e a progressão
continuam pendentes. O A4 do Toninho continua por ler.

## O desenho

- **Quando se oferece:** na fase `debt_payment`, com o dinheiro abaixo do
  boleto, a chance por usar nesta fase e uma cobrança seguinte na fase
  (`pode_pedir_segunda_chance()`).
- **Quanto empresta:** o que falta para o boleto **mais uma semana de custos**
  — salários e manutenção da semana que abre, pelo `_custos_da_semana()`, a
  mesma conta do fecho. Depois de pagar, o jogador fica exatamente com essa
  semana na mão. Sem ela sairia do vencimento com R$0 e o primeiro fecho a
  seguir terminava a partida por «O dinheiro acabou» — a segunda chance seria
  uma semana de adiamento.
- **Quanto devolve:** o emprestado **+12%**, arredondado, somado ao boleto
  da cobrança seguinte. O acréscimo é fixo: quitar a parcela antes abate só
  os juros da janela da PARCELA (`085`), nunca o do empréstimo, e o número
  que o Sr. Ribeiro diz é o que se paga.
- **Uma vez por fase.** Quem a usou na parcela 1 e não consegue pagar a 2
  perde o porto, como hoje.
- **Sem penalidade além do dinheiro** — é o que o GDD diz do atraso de uma
  semana, e é o que o painel já prometia («cena tensa, sem penalidade
  mecânica»): nem reputação, nem píer penhorado.
- **Crédito não é lucro** (guia de economia, §2): o empréstimo não entra na
  receita nem no resultado da semana. O boletim mostra-o numa linha à parte,
  abaixo do resultado, com o que se devolve e quando.

## O que entrou

**No `GameState`**: `pode_pedir_segunda_chance()`, `emprestimo_da_segunda_chance()`,
`devolucao_da_segunda_chance()` e `aceitar_segunda_chance()`, a terceira porta
do vencimento. O dinheiro do banco entra antes de o boleto sair, e o boleto
sai pela porta de sempre (`_baixar_parcela()`), com o valor de sempre; o
`pay_debt()` e ela partilham o que vem depois (`_retomar_depois_da_cobranca()`).
A dívida (`emprestimo_devido`) soma-se ao `principal_da_parcela()`, e por isso
o HUD, o painel, a projeção do dia, o vencimento e o simulador pedem o mesmo
número; pagar o boleto — no vencimento ou antes — paga-a. O acréscimo é a
constante `SEGUNDA_CHANCE_ACRESCIMO` (`# TUNING:`), e um sinal de observação,
`segunda_chance_aceita`, leva o emprestado e a devolução ao gravador.

**Na cena do Sr. Ribeiro** (`DebtPaymentPanel`): o «Não consigo pagar» abre,
onde ela existe, um **tempo do meio** (`segunda_chance`): a fala troca, a
tarja diz o empréstimo e a linha de apoio o que volta e em que dia; «Aceitar
o empréstimo» leva à resposta (`emprestou`), com a despedida — «crédito pedido
no aperto sai mais caro» é, ali, o que acabou de acontecer —, e «Recusar e
entregar o cais» ao «não pagou» de sempre. Os tempos novos não têm o nome das
falas (`oferta`, `aceitou`): o F7 procura o id entre aspas no painel, e um
tempo homónimo satisfá-lo-ia sozinho (a armadilha da `101`). Os de antes,
`pagou` e `nao_pagou`, têm-no — lido, não medido; fica anotado.

**Fora da cena**: o cartão da parcela diz que a cobrança inclui a segunda
chance e que antecipar não a abate; o boletim mostra o empréstimo numa linha
à parte, abaixo do resultado, que não o soma; a mensagem do sistema diz quanto
volta. O gravador do playtest passou à versão 3, com a linha `segunda_chance`
— numa partida da 2 o jogo ainda não a oferecia, e a falta da linha não quer
dizer «não a pediu» —, e o leitor (`ler_registros.py`) conta-a por partida,
com o desfecho, e diz «não sei» nas da 2.

## As falas — rascunho para a leitura do A4

| Id | Cara | Fala |
|---|---|---|
| `oferta` | formal | «Então vamos conversar. Um cais parado não paga ninguém, nem o banco. / Eu cubro o que falta e mais o dinheiro de uma semana, para o porto não parar. Volta tudo na próxima cobrança, com o custo de quem pede no aperto. / Isso eu faço uma vez.» |
| `aceitou` | formal | «Assinado. O cais continua no seu nome. / O banco anota tudo. Eu também.» |

Sem número nenhum: os valores estão na tarja logo abaixo, e a fala traz o
que a tela não diz — por que uma semana a mais, e que não há terceira. O
avô fica de fora de propósito: a resposta a quem não paga diz que ele
«passou trinta anos sem atrasar um dia», e um ano de aperto dele
desdizê-la-ia. Para a leitura: se «o custo de quem pede no aperto» se
entende sem a despedida, que quem falha a primeira cobrança nunca ouviu.

## O save 15

Autorizado pelo Bruno com o degrau, e o primeiro acima do piso da `098`. O
`_de_14_para_15()` escreve «sem dívida, chance por usar» e a linha
`emprestimo` da semana a zero, e o `_save_aceite()` recusa, antes de aplicar
qualquer campo, a dívida de tipo errado, negativa, sem a chance usada, na
primeira cobrança ou com o boleto já pago. O exemplo `tests/saves/v15.json`
joga mal o primeiro mês de propósito — conserta o que pode e não atraca
ninguém —, chega ao vencimento com o caixa em −R$18.000, aceita
R$210.000 e pára no dia 34 a dever R$235.200: o F21 exige-lhe os campos
cheios, e um exemplo que nunca a pediu gravá-la-ia a zero.

## As guardas, e os defeitos que as provam

- **T18** (lógica, novo): onde ela não abre (fora do vencimento, com o boleto
  inteiro, na última cobrança — sem tocar no estado); o empréstimo com o
  caixa NEGATIVO e os custos com DOIS trabalhadores e o escritório, que é o
  estado em que uma conta à mão divergiria da do fecho; o jogador fica
  exatamente com a semana; o sinal uma vez; o boletim com o empréstimo à
  parte e o resultado sem ele; a semana seguinte fecha no azul sem um barco;
  o boleto seguinte com a dívida, que a antecipação não abate; a ida e volta
  do save; pagar antes e no vencimento quitam a dívida; uma vez por fase; e
  partida nova sem nada.
- **T19** (lógica, novo): o degrau 14→15 contra o `v14.json` — os campos
  novos, a linha da semana, nenhum campo da 14 mexido, a origem intacta, e o
  carregamento de verdade.
- **F3** (fumaça): nove saves com a segunda chance mal formada recusados sem
  tocar no estado, e dois bons que entram.
- **F10** e **F14** (fumaça): os tempos novos cabem com o nome mais comprido;
  a oferta promete o empréstimo, a devolução e o dia, e a resposta o dinheiro
  que fica e a dívida, cada número contra o que o jogo fez; o tom de cada
  tarja; e o boletim mostra o empréstimo da semana.
- **F21** (fumaça): o `v15.json` com a dívida e a chance usada, e a ida e
  volta exata.
- **R8** (registro, novo): a linha `segunda_chance` com o que o jogo
  emprestou e deve; e o autoteste do leitor, com o «não sei» da versão 2.
