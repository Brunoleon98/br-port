# BR Port — briefing da próxima conversa

> Fechado em 14/09/2026, depois das DUAS fatias do item 8: a costa das pontas
> (`023`, de manhã) e o casco dos barcos (`024`, à tarde). Este é um ponto de
> entrada curto; o estado canónico continua em `docs/ESTADO_DO_PROJETO.md` e a
> ordem do projeto, na §7 do plano v3.

## O que acabou de ficar pronto

A branch `claude/br-port-construcoes-f1-5we9uo` traz a **segunda fatia do item 8
do segundo playtest** — as construções —, e o que ela entrega não é o que o
recorte previa, porque a medição inverteu o alvo.

`tools/medir_silhueta_props.py` (novo) mede que fração da silhueta de cada prop
corre nas três direções que uma caixa alinhada aos eixos sabe desenhar nesta
câmera. Renderizado sozinho, o **casco** mediu 0,620 — acima do galpão (0,563) e
de tudo o resto. **As construções não eram o problema; o casco era**, e o
contêiner por cima TAPAVA-O.

Os nove barcos passaram a sair de `contorno_casco()`, com linha de fundo de
curva própria e o guarda-corpo a seguir o bordo. O **D29** tranca a forma da
linha de fundo. As seis suítes, o validador e o `conferir_docs.py` fecharam
verdes; da bateria mudaram só as imagens que mostram barco, e as de painel
puro saíram byte a byte iguais.

**Não refaça isto, e sobretudo não "arredonde o resto do kit".** O §4 da `024`
lista, com número, o que é quadrado DE VERDADE — armazém, escritório, convés dos
píeres, treliça, pallet, caixote, barreira, contêiner — e o §3 mostra a medição
que diz que arredondar as estacas do píer não muda nada.

## O que sobrou, e é pequeno

1. **O tronco do coqueiro** — índice 0,491, três na tela. A secção não ajuda (é
   esbelto, e caixa e cilindro medem quase o mesmo aí), mas **curvar o EIXO**
   curvaria a silhueta, e isso não foi medido. É uma sessão pequena, e é a
   única pergunta do item 8 que ficou em aberto.
2. **`doca_concreto` não está no jogo** — é referido só por
   `scenes/tests/AssetPlacementTest.gd`, que não é exportado. O `barco_medio`
   outra vez. Ou entra no mapa, ou sai do catálogo: **é decisão do Bruno**.
3. **A rua parou em 1,8** — alargá-la empurra o `RUA_RECUO` e o enquadramento
   inteiro (`012`). Continua a ser sessão própria.

## E entrou um item NOVO na §7, proposto no fim do dia

**A resolução dos assets, e o detalhe que ela destrava.** O Bruno perguntou se
valia a pena aumentar a resolução do jogo para poder detalhar melhor. A §7 do
plano tem o item inteiro e a Etapa 7 do plano de arte tem a metade de desenho.
O resumo em três linhas:

- **o viewport NÃO se mexe** — com `stretch/mode="canvas_items"` o jogo já
  desenha a 1080 num telefone de 1080; o 720 é sistema de coordenadas;
- **o mapa já carrega a precisão que falta** — os quatro SVG declaram 720 sobre
  `viewBox` de 1080, e o importador está a deitar fora um terço deles;
- **resolução sozinha compra nitidez, não detalhe.** O que ela paga é o
  orçamento de detalhe, e o plano lista o que hoje está recusado POR TAMANHO,
  com o número de cada recusa.

Não é uma sessão: são cinco ou seis. **A ordem é do Bruno**, e nada disto entra
na fila numerada até ele o pôr lá.

## O que espera o Bruno, e nenhuma sessão destrava

- **A5** — olhar o antes/depois de toda a trilha de arte, agora com a costa e os
  cascos. É o gate mais atrasado;
- **A4** — reler em voz alta o texto que mudou desde a primeira leitura (13/09);
- **A6** — ouvir os 14 efeitos. Este contêiner não tem placa de som;
- **A1/A7** — jogar outra vez, e a ORDEM do resto da fila.

## O próximo recorte, escolhido pelo Bruno: a ALAVANCA A

Dos itens abaixo, o que ele escolheu para a próxima conversa é a **alavanca A
da resolução dos assets** — o `svg/scale` dos quatro SVG de mapa. É a mais
barata das três e a única que não pede um traço novo: a geometria já está
desenhada a 1080 e o importador entrega 720.

Condições do recorte, e elas são o que o mantém numa sessão:

- **só o MAPA.** Os props (`RESOLUCAO` 512 → 768) são a alavanca B e são outra
  sessão; o viewport é a alavanca C e **não se mexe**, medido;
- **medir o ganho antes de aceitar**, e não a olho: rasterizar `porto_mapa_iso`
  a 720 e a 1080 com o mesmo ThorVG e comparar a energia de gradiente que
  sobrevive ao antisserrilhado;
- **varrer o gerador à procura de constante medida em pixel.** A largura de
  cada traço, o passo do tabuado e as fiadas foram escolhidos olhando o render
  a 720 — a 1,5× um traço de 1 px passa a 1,5 e um vinco calibrado para quase
  sumir pode reaparecer. É a família dos cinco números que o `ZOOM` custou em
  05/09;
- **medir o custo**, que ninguém mediu: o `.ctex`, o APK e o `brport-web` antes
  e depois. O mapa a 1080² são 2,25× os pixels;
- **o portão é o do bote da `024`:** se a diferença não se vir no telefone,
  pare e registe a medição em vez de a deixar entrar.

Os três nós de mapa (`Mapa`, `Espuma0`, `Espuma1`) desenham hoje a textura no
tamanho nativo dela — vão precisar de `expand_mode`/`stretch_mode`, como os
ícones do HUD já têm. E são DUAS texturas de mapa, não uma: o `Main.gd` troca
entre `porto_mapa_iso` e `_patio` conforme o pátio esteja construído.

## Os outros, e nenhum deles é urgente

1. **O tronco do coqueiro** — índice 0,491, três na tela. A secção não ajuda (é
   esbelto), mas **curvar o EIXO** curvaria a silhueta, e isso não foi medido.
   É a única pergunta do item 8 que ficou em aberto.
2. **`doca_concreto` não está no jogo** — referido só por
   `scenes/tests/AssetPlacementTest.gd`, que não é exportado. O `barco_medio`
   outra vez. Ou entra no mapa, ou sai do catálogo: **é decisão do Bruno**.
3. **A rua parou em 1,8** — alargá-la empurra o `RUA_RECUO` e o enquadramento
   inteiro (`012`). Sessão própria.
4. **As alavancas B e C**, e o detalhe que a resolução destrava — §7 do plano e
   Etapa 7 do plano de arte.

## Prompt pronto para colar

```text
Continuando o BR Port. Leia primeiro CLAUDE.md, docs/ESTADO_DO_PROJETO.md,
docs/design/BR_Port_Plano_v3_Claude_Code.md §7 (o item "A RESOLUÇÃO DOS
ASSETS"), a Etapa 7 de docs/design/BR_Port_Plano_Arte_Blender.md,
docs/decisoes/024 e docs/arquivo/BRIEFING_PROXIMA_CONVERSA_2026-09-14.md.

Confirme que o PR do casco foi integrado e NÃO refaça os cascos nem arredonde o
resto do kit — o §4 da 024 diz, com número, o que é quadrado de verdade.

Trabalhe SÓ na ALAVANCA A: a resolução do MAPA, subindo o `svg/scale` dos
quatro SVG que declaram width=720 sobre viewBox=1080. Não toque nos props
(alavanca B) nem no viewport (alavanca C — medido, não dá um pixel).

Comece pela F1 e meça o ANTES com número, não a olho: rasterize
porto_mapa_iso.svg a 720 e a 1080 com o mesmo ThorVG do jogo e compare quanta
fronteira de valor sobrevive ao antisserrilhado. Depois varra gerar_mapa_iso.py
à procura de TODA constante medida em pixel e pergunte de que escala ela é — a
1,5x um traço de 1 px passa a 1,5 e um vinco calibrado para quase sumir pode
reaparecer. Meça também o custo: .ctex, APK e brport-web antes e depois.

Os três nós de mapa desenham a textura no tamanho nativo e vão pedir
expand_mode/stretch_mode; são duas texturas, porque o Main.gd troca para a do
pátio. Não toque na projeção, nas âncoras nem na pegada publicada.

Feche com as seis suítes, o asset_validator, a captura antes/depois AMPLIADA e
o fechar-sessao. Se a diferença não se vir no telefone, pare e registe a
medição em vez de a deixar entrar.
```
