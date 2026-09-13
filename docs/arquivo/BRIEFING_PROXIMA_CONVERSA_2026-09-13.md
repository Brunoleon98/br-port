# BR Port — briefing da próxima conversa

> Fechado em 13/09/2026, depois da correção da areia e da expansão da fauna.
> Este é um ponto de entrada curto; o estado canônico continua em
> `docs/ESTADO_DO_PROJETO.md` e a ordem do projeto, na §7 do plano v3.

## O que acabou de ficar pronto

A branch `codex/fix-sand-fauna-scale` contém três entregas encadeadas:

1. a areia passou a ser desenhada antes das vias, sem atravessar o asfalto;
2. gaivota, maria-farinha e tartaruga-verde voltaram à régua do jogo e
   ganharam ciclos naturais de entrada, presença e saída;
3. entraram cachorro caramelo, quero-quero e capivara, e os três costeiros
   ganharam outro ponto coerente de aparição.

O jogo está agora com **seis espécies em nove avistamentos**. O D25 prende
escala e alvo tátil; o D26 percorre os seis ciclos; o D27 conta as instâncias e
lê o terreno real sob cada habitat. Mover a capivara para o asfalto fez somente
a nova guarda de habitat falhar. As cinco suítes Godot, o validador Blender e a
documentação fecharam verdes; o manifest tem 44 assets.

Não refaça esta fauna nem aumente a densidade antes de jogar: os tempos são
desencontrados justamente para o mapa respirar e para nem todos os animais
ficarem visíveis ao mesmo tempo.

## Próximo recorte recomendado

O único item visual ainda aberto do segundo playtest é o **8 — “menos
quadrado, mais curva”**. A análise já o classificou como grande e maior que uma
sessão. Portanto, a próxima conversa deve atacar só a primeira fatia:
**naturalizar o contorno da costa e das duas praias**, preservando a geometria
funcional de vias, vila, cais, píeres e âncoras.

Condições do recorte:

- medir e capturar o contorno atual antes de editar;
- alterar a aparência da borda, não a projeção (`MEIA_LARG`, `MEIA_ALT`) nem a
  rota logística;
- manter as faixas de água e areia derivadas da mesma costa, sem costuras;
- não transformar prédios/props em curvas nesta conversa;
- acrescentar uma guarda raster que prove continuidade e ausência de areia na
  rua, além de conservar D20, D21, D24 e D27;
- regerar os dois mapas, capturar antes/depois e rodar o fecho completo.

Se o contorno orgânico exigir mover berços, vias, lotes ou âncoras, pare na
investigação e escreva a proposta: isso já seria outra sessão e outra decisão.

## Prompt pronto para colar

```text
Continuando o BR Port. Leia primeiro CLAUDE.md, docs/ESTADO_DO_PROJETO.md,
docs/design/BR_Port_Plano_v3_Claude_Code.md §7 e
docs/arquivo/BRIEFING_PROXIMA_CONVERSA_2026-09-13.md.

Confirme que o PR da branch codex/fix-sand-fauna-scale foi integrado e não
refaça a fauna. Trabalhe no primeiro recorte do item 8 do segundo playtest:
deixar o contorno da costa e das duas praias mais orgânico e menos quadrado,
sem mudar a projeção, as vias, a vila, os cais, os píeres ou as âncoras.

Meça e capture o antes; mantenha água e areia derivadas da mesma costa; crie
uma guarda raster para continuidade e para a areia não voltar à rua; regenere
os dois mapas; confira o resultado visualmente; rode as cinco suítes Godot e
os validadores/documentação exigidos pelo fechar-sessao. Se o recorte não
couber sem mover geometria funcional, faça apenas a investigação, registre uma
proposta medida e pare antes de ampliar o escopo.
```
