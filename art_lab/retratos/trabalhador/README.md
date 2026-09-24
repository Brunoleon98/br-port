# O trabalhador do rodapé em busto no kit afinado — v1 a v6

**Estado: ✅ v6 ACEITA pelo Bruno na foto do jogo (24/09), e já no jogo.**
O construtor é o `trabalhador()` de `blender/brp_retratos.py` (com a
`TRABALHADOR`), a cara e a fração do quadro são a `TRABALHADOR_CARA` e a
`TRABALHADOR_CABECA` de `blender/brp_porto.py`, e o PNG em `brport_vs/` saiu
do estúdio igual à candidata (0 pixels diferentes). A decisão é a `058`.

**Base:** `main` em `1cfd339` (o PR #81 fundido).

## O que se pediu

O último retrato no kit de caixas e em AgX. Perguntado como passava ao kit
afinado — corpo inteiro, busto ou só a cor —, o Bruno escolheu **busto**, como
os três que falam. O que o identifica continua a ser o que o boneco de caixas
já tinha decidido: o CAPACETE amarelo e redondo e o COLETE laranja vestido.

## As seis voltas

| | o que mudou | o veredito do Bruno |
|---|---|---|
| **v1** | cabeça larga e baixa, capacete em cúpula com aba, pala e crista, colete em dois painéis com V largo, gola da camisa por cima, faixa refletiva | ajustar: capacete grande e «amassado»; «alguns detalhes» na cara — careca, pontas soltas na aba, boca e queixo; colete: mais laranja no peito, faixa maior, sem gola |
| **v2** | cúpula baixa e lisa (24 lados), aba de uma peça descentrada para a frente, cabelo curto por baixo da aba, boca larga com lábio fino, V fechado, faixa maior | ajustar: capacete «ainda grande», «com mais detalhes e mais realista»; a roupa refletiva «cortada» |
| **v3** | casco justo com três nervuras e friso; colete com zíper, faixa horizontal inteira e faixas verticais pelos ombros | ajustar: pala marcada, aba mais fina, nervuras mais marcadas, adesivo na frente (o futuro emblema da empresa); colete «conecte as partes soltas, parece que se ele andar o colete cai», zíper menos marcado, bolsos |
| **v4** | pala curta, aba estreita, adesivo quadrado, alça sobreposta ao painel, bolsos e caneta | ajustar: o adesivo «lê como lanterna», a pala «lembra boné», a aba some dos lados; bolsos na altura do peito, caneta como mancha; «vários pedaços colados», faixas como suspensórios, faixa de baixo cortada |
| **v5** | colete de UMA peça que envolve o ombro, faixas costuradas nele, busto mais aberto (56%), pala curta e grossa, decalque oval | ajustar: «retire bolsos» |
| **v6** ✅ | a v5 sem os bolsos | **aceite** |

## O que cada volta ensinou

Em comentário no código, junto da linha que corrige. As que valem além dele
estão no fim do §7.5 do plano de arte (`docs/design/BR_Port_Plano_Arte_Blender.md`).

## A prova no jogo

Numa cópia da árvore (`git archive`), com SÓ o PNG trocado e o `--import`
duas vezes (ele vive em atlas), a bateria inteira do `capturar_evidencia.sh`:
em cada volta as mesmas 14 fotos mudaram, todas só dentro das caixas dos
retratos (y 860–929), e na árvore real as 31 saíram iguais às da prova da v6.

## Arquivos

| Pasta | O que há |
|---|---|
| `v1/`–`v6/` | o script do candidato e a prancha do jogo (hoje × as voltas anteriores × esta). ⚠️ O script corre contra o estúdio de HOJE, não o daquela volta: não refaz a vN. O PNG da v6 é o de `brport_vs/art/props/trabalhador_retrato.png` |
