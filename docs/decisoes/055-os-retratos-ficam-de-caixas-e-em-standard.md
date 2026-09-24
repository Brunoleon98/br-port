# 055 — Os retratos ficam de caixas, afinados, e em Standard

**24/09/2026 · frente 2 do A5 (retratos de fala), decidido pelo Bruno** em
cinco vereditos na mesma conversa, o último na foto do jogo: «Aceito, levar
para o jogo».

## O que se decidiu

1. **O modelo dos retratos continua a ser o de CAIXAS** — prismas oitavados,
   placas na face, sombreado chapado, o `chanfrar()` do kit —, a mesma oficina
   do `trabalhador_retrato` do rodapé. A forma REDONDA (metaball suavizado,
   plano de arte §7.2, P1) foi feita duas vezes e não foi escolhida: a v1
   rejeitada, a v2 posta ao lado de uma quadrada melhorada, e ele escolheu a
   quadrada «para melhorar».
2. **Os retratos renderizam em STANDARD a −0,35 EV** (plano de arte P6). Os
   props do mapa continuam no AgX, agora ESCRITO no estúdio (`COR_PADRAO`,
   C1): a troca global continua por decidir.
3. **A Dona Cida é a primeira no kit afinado**, nas três expressões. O Sr.
   Ribeiro e o Arlindo continuam no `_corpo()` de antes até serem refeitos da
   mesma maneira, e o trabalhador do rodapé também.

## Por que

- **Caixas e não redondo:** o `Retratos.gd` já o pedia — os retratos têm de
  pertencer à oficina do trabalhador, que está no mesmo cartão (o boletim
  mostra os dois). Com a quadrada, a oficina não muda; com a redonda, os
  outros dois e o trabalhador teriam de a seguir.
- **Standard e não AgX:** o AgX punha o `#eef2f5` da gola e do olho a ~191 e
  lavava a pele. Os retratos pousam num cartão, não no mapa, e a coerência com
  os props não os prende (P6).
- **E −0,35 EV, medido:** a 0 EV o Standard estourava **54% dos pixels
  claros** (a gola, o branco do olho, os botões a 255, sem o sombreado das
  facetas); varrido na prévia, −0,2 ainda estoura 0,07%, **−0,35 dá zero** com
  o p99 a 239 e a saturação da pele igual (0,58), −0,5 só escurece.

## Como

- **`blender/brp_retratos.py`** — o kit afinado, que o `retratos_de_fala` de
  `brp_porto.py` chama para quem está em `_NO_KIT_AFINADO`. O código saiu do
  script da `art_lab/retratos/cida_seria/quadrada_v3/`, e as armadilhas de
  cada peça estão lá e no fim do §7.5 do plano de arte.
- **O enquadramento é MEDIDO** (a cabeça com o cabelo e o coque a 60% do
  quadro, topo a 16 px), e não os `_K`/`_MEIO` do kit. ⚠️ **E a pose entra
  DEPOIS dele**: com a cabeça já inclinada na medida, o busto inteiro mudava de
  sítio de uma expressão para a outra (a preocupada 12 px à direita, a
  contente 22 à esquerda).
- **A cor é por grupo** (`Estudio.registrar(..., cor=)`), fora da ficha do
  manifest, que descreve o quadro que o jogo lê e não como foi pintado.
- **As alavancas da expressão são as do kit** (`_CARAS`): boca, sobrancelha,
  olho, olhar e pose. Valor que o desenho novo ainda não faz REBENTA, em vez
  de sair com a cara séria.
- **A paleta ganha o `cabelo_fundo`** (`#3b2513`, o `madeira_esc` a 60%): o
  degrau abaixo do cabelo, como o `pele_sombra` é o da pele.

## A prova

- **A séria do estúdio É a candidata aceita**: `tools/comparar_props.py` dá
  **0,0081** de diferença máxima (um pixel de deslocamento dá 0,022).
- **Nenhum pixel estourado** nas três expressões; o tronco no mesmo sítio nas
  três (x 169..598 do PNG), só a cabeça roda.
- **A bateria de capturas** muda **1 foto em 31**, o `boletim`, e só na caixa
  do retrato (x 158..258, y 755..904). A preocupada e a contente não aparecem
  em tiro nenhum — já era assim com as de caixas —, e as fotos de aceite delas
  saíram de uma cópia da árvore, com a ferramenta de cena a receber o resumo da
  semana (`art_lab/retratos/cida_seria/quadrada_v3/jogo_tres_caras.png`): a
  preocupada no boletim de prejuízo, a contente no de lucro acima da média.
- **As seis suítes** verdes; o manifest sai idêntico (as fichas não mudam); a
  segunda geração pelo estúdio dá os mesmos três PNG (0,0000).

## As guardas

O `blender/validate_brp_assets.py` (à mão, não corre no CI — precisa do `bpy`)
reprovava as três caras novas por «sair do quadro», e por DUAS razões:

- **em cima, a −1 px, falso**: media os oito cantos da caixa de cada peça, e a
  caixa do coque (redondo) tem quinas que não existem. Passou a projetar os
  vértices da malha AVALIADA — o vértice está sempre dentro da caixa, logo
  nada que passava passa a reprovar;
- **em baixo, a 892 px, verdadeiro e de propósito**: o busto novo sai pela
  borda de baixo, como numa fotografia; o de caixas de antes acabava dentro do
  quadro num tampo chato, e lia como pedestal. Para âncoras `retrato`, a borda
  de baixo deixou de contar; a de cima e as dos lados continuam.

| defeito injetado | o que o validador disse |
|---|---|
| M1 — a cabeça da Dona Cida sobe para fora (`TOPO_PX = −40`) | reprova as três: «sai do quadro», y a −40/−32/−43 |
| M2 — o busto dela foge pelo lado (`CENTRO_X_PX = 190`) | reprova as três: x a −23 |
| M3 — um prop do MAPA sai pela borda de baixo (o cone a `pos(14, 14)`) | reprova: «sai do quadro», y 793..808 — a isenção não cobre quem não é `retrato` |

⚠️ **E o M3 não reprovou à primeira**, com o cone a `pos(7, 7)`: uma sonda
mostrou-o a y ≈ 590, ainda DENTRO do quadro — o defeito não tinha chegado a
quem o havia de ver. Entre cada defeito, a base voltou por `cp` e o validador
passou.

## O que fica por fazer

- **O Sr. Ribeiro e o Arlindo no kit afinado**, com a forma de cada um (P2:
  ele retangular e alto, o Arlindo de ângulos), e em Standard.
- **O trabalhador do rodapé**, que continua no AgX e no desenho de antes — no
  boletim fica ao lado da Dona Cida.
- **Os tiros da preocupada e da contente na bateria**: o boletim ruim e o
  ótimo, que nenhum tiro monta. Pede o catálogo de capturas ao nível do TEMPO
  (`051`) e a guarda de que o tiro mostra a cara que promete.
- **A troca global AgX × Standard nos props**, que é outra pergunta.
