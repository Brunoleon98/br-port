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
verdes; das catorze imagens da bateria mudaram as nove que mostram barco.

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

## O que espera o Bruno, e nenhuma sessão destrava

- **A5** — olhar o antes/depois de toda a trilha de arte, agora com a costa e os
  cascos. É o gate mais atrasado;
- **A4** — reler em voz alta o texto que mudou desde a primeira leitura (13/09);
- **A6** — ouvir os 14 efeitos. Este contêiner não tem placa de som;
- **A1/A7** — jogar outra vez, e a ORDEM do resto da fila.

## Prompt pronto para colar

```text
Continuando o BR Port. Leia primeiro CLAUDE.md, docs/ESTADO_DO_PROJETO.md,
docs/design/BR_Port_Plano_v3_Claude_Code.md §7, docs/decisoes/024 e
docs/arquivo/BRIEFING_PROXIMA_CONVERSA_2026-09-14.md.

Confirme que o PR do casco foi integrado e NÃO refaça os cascos nem arredonde o
resto do kit — o §4 da 024 diz, com número, o que é quadrado de verdade.

Trabalhe no único item do 8 que ficou em aberto: o TRONCO DO COQUEIRO. Comece
pela F1: meça o que curvar o EIXO dele faz à silhueta (a secção já está medida e
não ajuda), e decida com número se o ganho paga. São três na tela, 16x61 px.

É sessão de Blender: pip install "bpy==4.5.0". Prop não é artefato
byte-reprodutível — compare com tools/comparar_props.py e prove pela captura.
Não toque na projeção, nas âncoras nem na pegada publicada. Feche com as seis
suítes, o asset_validator, a captura antes/depois e o fechar-sessao.

Se a medição disser que o ganho não paga, pare e registe a medição.
```
