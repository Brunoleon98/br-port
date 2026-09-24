# Sr. Ribeiro no kit afinado — v1 a v4

**Estado: ✅ v4 ACEITA pelo Bruno na foto do jogo (24/09), e já no jogo.**
O construtor é o `ribeiro()` de `blender/brp_retratos.py` (com a `RIBEIRO`),
as três caras estão na `_CARAS` de `blender/brp_porto.py`, e os PNG em
`brport_vs/` saíram do estúdio iguais à candidata (0 pixels diferentes). A
decisão é a `056`.

**Base:** `main` em `5276efa` (o merge do #80), mais o checkpoint `05b63dd`
(a cabeça parametrizada por personagem).

## O que se pediu

O passo seguinte da `055`: o Sr. Ribeiro no kit de caixas afinado da Dona
Cida, com a SUA forma — plano de arte P2, «retangular e alto» — e não a dela
com outro cabelo. A identidade que o `_ribeiro` de caixas já tinha decidido
continua: a careca com a coroa grisalha (ele é o mais velho dos três), as
rugas, e o terno de banco lido pelas lapelas, a gravata e o lenço.

## As quatro versões

| | o que era | o veredito do Bruno |
|---|---|---|
| **v1** | cabeça 150 × 156, maxilar quadrado (estreita 10%), crânio de tampo largo, grisalho em lajes dos lados, sobrancelha cinzento-escura, rugas e sulcos, terno de ombro direito com a lapela acetinada; à MESMA escala de desenho da Dona Cida | ajustar: cúpula grande, cara pequena na caixa, cabelo, expressões |
| **v2** | cúpula 6 mais baixa; enquadrado pela PRÓPRIA cabeça (mais perto); uma fita grisalha atrás a espreitar por cima; olho maior com brilho maior; boca 30% mais larga e mais grossa; poses mais fortes, cordial com os olhos a sorrir | ajustar: a coroa «solta dos lados», a boca estranha, a grave «mais triste» |
| **v3** | o cabelo numa FERRADURA só, das têmporas à nuca; sem os sulcos do nariz à boca e sem lábio; a grave triste (cenho `triste`, olhar baixo, cabeça de lado) | ajustar: a ferradura mais cheia nos lados e com fios; a boca mais curta, mais fina e com lábios discretos |
| **v4** ✅ | a ferradura mais afastada nas têmporas, em cinco camadas alternadas (as claras salientes, as escuras recuadas: os fios); a boca 1,1× a da Dona Cida, com a linha da grossura dela e os lábios a 55% da altura | **aceite** |

## O que cada volta ensinou

Tudo em comentário no código, junto da linha que corrige:

1. **Medida pela cabeça da Dona Cida, a cara dele saía pequena.** Os 60% do
   quadro dela incluem o coque; à mesma escala a cabeça dele saía 8,5% menor
   (k 1,066 contra 1,157), e o Bruno pediu-o mais perto. Cada personagem é
   medido pela SUA cabeça.
2. **O cabelo de um careca só se vê se passar acima do crânio NA IMAGEM.** A
   câmera olha de cima: o que está atrás sobe meia unidade por unidade de
   fundo. A primeira fita atrás, com o topo 2 acima do crânio, cobria a
   cabeça toda e lia como cabelo penteado para trás; a ferradura sobe da
   têmpora à nuca e espreita só atrás.
3. **Dois sulcos do nariz à boca desenham PARÊNTESES à volta dela**, e a boca
   lia como a de um boneco de ventríloquo — «a boca parece meio estranha».
4. **O lábio de baixo largo, num tom escuro, é uma prateleira**; sem lábio,
   a boca é um risco. Lábios finos (`labio_k`), afinados pela borda de fora.
5. **O grisalho da paleta tem o VALOR da pele clara** (~161 os dois): no
   bordo da cabeça ele não se separava dela. O cabelo é `concreto` (~192) e
   os fios `cabelo_grisalho`; a sobrancelha é `metal`, que se lê na testa.
6. **A lapela um passo mais escura sumia no terno**; acetinada, apanha a luz e
   desenha o V.
7. **A pele clara em Standard a −0,35 EV não estoura** (0% nas três caras),
   que era o risco que o briefing apontava.

## A prova no jogo

Numa cópia da árvore (`git archive 5276efa`), com SÓ os três PNG trocados e o
`--import`, os três tiros da bateria que o mostram — `ribeiro` (a entrada,
cordial), `ribeiro_pagou` (cordial) e `ribeiro_nao_pagou` (grave) — com os
argumentos do `capturar_evidencia.sh`:

- os três mudam **só dentro da caixa do retrato** (x 164..272), e cada tiro
  dá zero exato contra ele próprio;
- ⚠️ **a formal não tem tiro na bateria** («a dívida», o segundo tempo da
  entrada) — viu-se na prancha das três caras.

## Arquivos

| Pasta | O que há |
|---|---|
| `v1/`–`v3/` | o script do candidato (as caras de cada volta), a prancha do jogo (hoje × vN) e a das três caras. ⚠️ O script corre contra o estúdio de HOJE, não o daquela volta: não refaz a vN |
| `v4/` | o script, a prancha do jogo, a das três caras e as fotos do jogo da entrada e do «não pagou». Os PNG são os de `brport_vs/art/props/retrato_ribeiro_*.png` |
