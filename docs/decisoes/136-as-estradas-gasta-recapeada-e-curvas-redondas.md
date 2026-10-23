# 136 — As estradas: a rua gasta, a recapeada por partes e as curvas redondas

**19/10/2026 · item 2 da fila da `126`.** Main `fc05203` (PR #144, a
vegetação da `130`, fundido pelo Bruno); nenhum PR aberto, nenhum ramo de
outro agente nos últimos três dias, e 131 livre pelo
`tools/conferir_colaboracao.py`. **Nasceu `131` e é `136`**: enquanto ela
corria, o Codex fundiu a `131` (a bancada de texto), a `132` e a `133`, e o
D48 dele (o fundo da inicial), e o PR #148 dele, aberto antes do push
desta, trazia a `134` e a `135`; quem renumerou foi esta branch, no fecho de
23/10, e o bloco dela é o D49 (`119`). A conversa abriu com a foto do jogo (dia 1 e
porto completo, ampliados a 1080) e a pergunta do escopo pela `/arte`; foram
três passagens, com prancha contra a `main` e veredito em cada uma, e a
terceira foi **aceite**.

## O escopo que ele escolheu

| Pergunta | O que marcou | O «Outro» |
|---|---|---|
| Defeitos | os quatro: o fio claro dos cotovelos, o fio azul da ponta norte, o acesso de asfalto no pátio de terra, as rachaduras do pátio | *«as sinalizações aparecem do nada depois atualizar o pátio»* |
| A rua | os quatro: sinalização brasileira, asfalto e calçada com vida, acessos com cara de entrada de porto, rua gasta no dia 1 e recapeada com o pátio | *«essa troca tem que acontecer por partes que nem quando algo está sendo construído ou reformado»* |
| A rede | só a rua que existe (a vila da `123` intocada) | — |

| Passagem | Veredito, e o que marcou |
|---|---|
| 1 | Ajustar: remendos quadrados, boca de lobo escura, obra sem sinalização, linha contínua pesada; *«consegue deixar as curvas mais arredondadas»* |
| 2 | Ajustar: cones amontoados, recapeado liso demais, curva de dentro pouco visível, curva de fora ainda pouco redonda |
| 3 | **Aceito** |

## O que «aparece do nada» era, medido

Os dois mapas — o de terra, até o pátio ficar pronto, e o pavimentado — só
diferiam no pátio, e a obra do pátio (`121`) recortava o pavimentado por cima
do pátio, dia a dia. Tudo o resto que diferia trocava de uma vez no fim da
obra: **26.901 px**, fora do recorte. Eram a linha central e as zebras, que só
o pavimentado tinha, mas também a VIELA e os QUINTAIS da vila, que clareavam
de `terra_escura` para `terra_clara`, e a faixa amarela do avental, um pixel
além da borda do recorte. Hoje nada muda fora da obra: a viela e os quintais
ficaram com a cor do dia 1 nos dois mapas, a faixa do avental passou para o
lado do pátio, e a rua tem a sua obra.

## A rua gasta e a recapeada, por partes

O mapa do porto em ruínas leva a rua que a cidade deixou envelhecer: asfalto
mais claro (`asfalto_gasto`), remendos de borda irregular mais escuros do que
ela, fissuras ramificadas, buracos, óleo, sulco de pneu nas curvas e a tinta
apagada a falhar. O do pátio pronto leva a recapeada, no tom de antes
(`asfalto_via`), com um tom muito leve por dia de obra, a emenda onde dois
dias se encontram e uma trinca selada.

**A obra do pátio recapeia a rua um trecho por dia, do norte para o sul**
(`obra_da_rua()`), e o último trecho fica pronto com o mapa inteiro. O jogo
faz isso como já fazia ao pátio, recortando mapas: `RuaRecapeada` mostra o
pavimentado nos trechos prontos, e `RuaPorRecapear` o mapa de terra nos que
faltam — por cima do asfalto do pátio, que atravessa três cotovelos e os
recapearia antes do dia deles. Cada recorte vai até ao meio da calçada, que é
igual nos dois mapas. Três cones ficam no troço reto do cotovelo seguinte, a
0,9 uns dos outros: a 0,45 liam como um monte, antes da curva caíam na
passadeira, e na curva o camião passa a 0,2 do eixo.

## A sinalização e os acessos

A linha central é **amarela** (no Brasil separa os sentidos opostos; era
branca), existe desde o dia 1 e é contínua só no cotovelo — com 0,9 de cada
lado, o zigue-zague pesava. As zebras e as retenções antes delas ficam
apagadas no dia 1 e novas com o trecho. O acesso de cada berço é de **terra
com sulco** no porto em ruínas e chega asfaltado com a obra do pátio; a boca
dele é uma guia rebaixada nos dois mapas, e no pavimentado leva a retenção e
o zebrado amarelo de manobra junto do avental. A calçada tem junta e capim
nas frestas; o meio-fio, bocas de lobo; a pista, uma tampa de bueiro por reta.

## As curvas redondas

A quina de fora do cotovelo era um chanfro a 45°; é um **arco**, e os três
contornos (asfalto, meio-fio, calçada) são concêntricos. O raio sai do mesmo
porta-contêiner de que saía o chanfro: é o maior com que a carroçaria, a
cortar a curva pela diagonal, não sai do asfalto. Com o corte de antes (0,636)
não passava de **0,86**, e o Bruno pediu mais.

A saída que eu propus — o camião a fazer a curva em arco — **foi medida e não
serve**: o sprite não roda, e a meio da curva a ponta dele aponta para a quina
e sai do asfalto em qualquer raio (+0,24 a +0,26). O que abre a curva é o
camião cortar mais CEDO pela mesma diagonal: o `corte_da_curva()` passou a
meia rua (0,9) nos dois lados do contrato, e o arco subiu a **1,38**; o D13
§7j mede a carroçaria a 0,002 dentro dele. A quina de dentro arredonda a
**0,45**, e a calçada acompanha.

## As provas

- **D49** (novo, `casos_estradas.gd`): §1 tudo o que muda entre os dois mapas
  cai dentro da obra (5 px fora contra 26.901 na `main`); §2 nenhuma junta de
  cotovelo tem fio claro (0 a +4 contra +30); §3 a água não aparece na borda
  norte do pátio (+17,5 contra +90,5).
- **D45 §6**: a cópia da obra da rua e dos cones contra a tabela, um trecho
  por dia e o último no fim, e a cada dia os dois recortes e os três cones.
- **D13 §7j**: mede contra o arco publicado (`raio`), e não contra o chanfro.
- Oito mutantes no catálogo, três deles os defeitos corrigidos.

## O que fica

- Na curva de fora o camião passa a 0,2 da linha central e encosta nela por
  dois pixels — o preço do corte maior.
- A calçada da quina de dentro avança até 0,095 sobre o canto do pátio e o da
  vila, fora do cerco retangular que a tabela publica; nenhum prop pousa lá.
- **Para os sprites de detalhes** (item 3), vistos nas fotos: postes e placas
  na calçada nova, carros estacionados, lixeiras, um ponto de ônibus, e
  cavaletes de obra ao lado dos cones.

## O veredito

Vista a prancha da terceira passagem, o Bruno **aceitou**. O item 2 da fila da
`126` fecha, e a conversa seguinte é a dos sprites de detalhes (item 3).
