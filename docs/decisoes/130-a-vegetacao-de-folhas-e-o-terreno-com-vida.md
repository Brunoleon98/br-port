# 130 — A vegetação de folhas, o morro com clareiras e os destaques à vista

**18/10/2026 · item 1 da fila da `126`, segunda conversa.** A `127` entregou o
terreno e a vegetação e **não foi aceite**: *«melhorar os detalhes e corrigir
os erros da vegetação até ela ficar boa, e melhorar também o terreno»*. O PR
#141 foi fundido pelo Bruno antes desta conversa abrir, e ela recomeçou da
`main`. Foram sete passagens, cada uma com foto do jogo, prancha contra a
`main` e veredito pela `/arte`; as quatro primeiras voltaram «Ajustar» e a
sétima foi **aceite**.

## O que ele marcou, volta a volta

| Volta | O que marcou (e o «Outro») |
|---|---|
| 1 | as doze opções, e *«parece que a maioria das árvores é a mesma»* |
| 2 | mata parada no meio, moitas pequenas, troncos em fila, *«as folhas da mata c não estão boas… mais natural e bonito, faça o mesmo com modelos semelhantes»* |
| 3 | moitas em fileira, uma clareira só, moita demais e árvore de menos, moita clara destoa, *«a vegetação parece que ficou mais artificial… não precisa economizar na quantidade de polígonos»* |
| 4 | poucas juçaras e embaúbas, *«as folhas parecem bolinhas… pesquise… uma das árvores»* |
| 5 | prova em três árvores: **aplicar a todas** (recomendada); juçaras e embaúbas: **mudas no relvado + só onde se vê** (recomendada) |
| 7 | **Aceitar** |

## O lugar das árvores: o contorno por LOTE

A mata que balança encostava à borda esquerda e deixava o meio parado. A
causa era o contorno da vila: por coluna, ele era o MÍNIMO de tudo o que a
vila pinta, e uma casa lá atrás proibia uma árvore à frente dela. Hoje cada
lote publica a sua peça (`pecas_da_vila`), e uma árvore só respeita as que
lhe ficam À FRENTE, pela regra do eixo que separa (`lote_a_frente`). A orla
escura do quintal só se embute onde nem uma moita que balança caberia, e a
árvore de trás não desce por cima da embutida da frente (D47 §3c).

## O desenho: a copa de FOLHAS

A copa já tinha sido de cinco jeitos, e nenhum lia folhagem: bola lisa,
relevo de ruído, facetas de 80, facetas de 20 («mais artificial») e tufos de
icosfera, cada um no tom da sua exposição — trinta sóis pequenos, «bolinhas».
A pesquisa pedida (resumos, as páginas não abrem, `063`) repetiu uma técnica
em todas as fontes: **folhas pequenas espalhadas pelo volume, com as normais
reescritas para a copa inteira**, para a luz ver uma massa só.

- cada tufo é um punhado de folhas em losango (0,15 u, ~2 px no jogo), numa
  malha só, com a normal 65% da copa e 35% do tufo (`MISTURA_DO_TUFO`);
- uma FRANJA irregular para fora (`FOLHA_FRANJA`) tira a borda redonda que
  ainda lia bolinha;
- os tufos recuam a 0,85 (`FOLHA_RECUO`): com folha e franja a copa engordava
  13–20%, e o morro perdia dez árvores — o perfil sai do PNG;
- a cor sai da exposição de cada folha; a copa achatada (moita) leva um VIÉS
  para o escuro, e a aroeira um para o claro, medidos contra o tom de antes;
- o vento da aroeira afasta os TUFOS, não as folhas: esticadas, saiu um
  charuto riscado.

Provada primeiro em três árvores, no jogo, antes de ir às dezanove. As
formas novas da volta 2 ficaram: a emergente em cachos (`mata_c`, `copa_m`,
`copa_larga`), a alta, as arvoretas, a embaúba com anéis e umbela cheia, o
guriri de folha arqueada e a fruta pousada num tufo.

## O terreno

O chão da mata ganhou folhas caídas e manchas de luz; o morro, **duas
clareiras** com granito; o relvado da vila, trilhas, hortas e flores; a
restinga, a borda nítida contra a areia e plantas mais espaçadas. A mata do
relvado nasce onde uma moita que balança cabe (contra a embutida parada),
com as arvoretas antes das moitas e um sub-bosque à frente de duas em cada
três árvores.

## Os destaques à vista

*«Poucas juçaras e embaúbas»* tinha três causas, medidas:

1. a distância entre iguais era a do ipê (55 px), e cabiam duas de cada —
   passou a 26 para as silhuetas (`MATA_PALMEIRA_LONGE`);
2. **o HUD**: o `MapaWrap` começa no y 62 da tela e recorta o que sobe acima
   dele, e metade das juçaras e embaúbas tinha o pé em y 21–36, com a copa
   inteira atrás da barra. Um destaque só nasce com a copa abaixo dela
   (`MATA_COPA_VISIVEL`);
3. no relvado as adultas pintariam por cima das casas da frente: nasceram a
   **juçara e a embaúba jovens** (`arvore_jucara_c`, `arvore_embauba_c`), do
   porte da arvoreta, e as arvoretas plantadas depois em tufo taparam-nas —
   nenhuma árvore tapa mais de um quarto da copa de um destaque, nem outro
   destaque mais de 0,65 da caixa da copa (`MATA_COPA_TAPADA`, `_ENTRE`).

Medido nos pixels pelo D47 §12, a primeira versão da regra deixou uma
embaúba com 90% da copa debaixo do ipê à frente (só perguntava pelas árvores
comuns). Somar tudo pela caixa inteira tirava do morro todas as palmeiras e,
numa cascata, as nove arvoretas do relvado (63 árvores → 42). O que ficou:
árvore comum tapa com a caixa, destaque com a copa, um a um. Visíveis: de 1
juçara e 1 embaúba para 4 juçaras e 5 embaúbas, em 62 árvores.

Estas regras apertaram-se DEPOIS do aceite, pelas provas do fecho, e
tiraram a escura alta (`mata_d`) do morro; a folha dos props deu pela falta
dela e da escura grande. Toda forma da massa entra agora ao menos uma vez
(`MATA_DARDOS_DA_QUE_FALTA`), e a escura alta voltou. A escura grande
(`mata_a`) já não cabia no morro desde a copa de folhas — também não estava
no estado aceite — e vive só em duas embutidas fora da tela; o catálogo da
folha ancora-a no ponto do mapa mais perto do pé, como já fazia à mata que
só pousa fora.

## As provas

O **D47** ganhou o §3c (a orla embutida à frente, pela profundidade), o §8 (o
granito da clareira), o §9 (copa embutida no telhado, lido no mapa
rasterizado), o §10 (o ipê embutido mostra a flor), o §11 (a copa de cada
destaque abaixo do recorte do mapa, que lê o `clip_contents` da cena) e o
§12 (a copa de um destaque não fica tapada, contada pixel a pixel). Cada um
tem o seu mutante no catálogo, e dois nasceram furados: o do telhado trocava
a moita por uma espécie que o SVG não embute — o `<use>` não desenha nada —,
e o do destaque tapado era fraco (73%, abaixo do corte); o que ficou é o caso
que pediu a guarda. Os dois mutantes órfãos da `127` foram reescritos contra
a mata nova.

## O que fica

- **O ipê amarelo da borda tem 63% da copa debaixo da embaúba à frente** —
  a guarda corta a 76% (a meio entre ele e o defeito); não é verde por ela.
- **A juçara jovem e a embaúba jovem** são pequenas (~20×33 px) e parecem-se
  uma com a outra; os destaques do morro ficam na borda esquerda, meio fora
  da tela, que é onde o morro se vê.
- **A escura grande (`mata_a`) não aparece no jogo**: o morro visível não lhe
  tem lugar com a copa de folhas, e as duas embutidas ficam fora da tela.
- **Estradas:** o fio azul na borda do pátio de terra da ponta norte, e uma
  linha fina diagonal no asfalto junto do coqueiro sul — vistos nas fotos,
  não investigados.

## O veredito

Vista a prancha da sétima passagem, o Bruno **aceitou**. O item 1 da fila da
`126` fecha, e a conversa seguinte é a das estradas (item 2).
