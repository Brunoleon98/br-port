# BR Port F1 — grupo completo de vegetação V2

**Status:** candidata para avaliação visual, sem integração. Referência: grupo superior esquerdo inteiro de `13_arbustos_vegetacao_baixa_mangue_v4.png`. A V1 original permanece preservada.

## Correção de estilo

A V1 era grande, escura e cheia de raminhos de alta frequência. A V2 usa a cor de copa `#3e8f3a`, realce `#6fbf4e`, tronco `#5a4632` e sombra `#425f3c` do gerador F1. Sua prévia usa 62 × 39 px, com as duas árvores e o sub-bosque como uma só textura. A comparação lado a lado coloca **V1 e V2 no mesmo tamanho e na mesma posição**, com o conceito inteiro e o grupo marcado.

A V2 combina melhor com o tamanho e o contraste da vegetação existente. Continua **mais geométrica e menos orgânica** que o conceito; alguns arbustos repetem um perfil semelhante. Isso precisa de avaliação visual do Bruno antes de aprovação.

## Arquivos

- `vegetacao_grupo_f1_v2.svg` — fonte vetorial; viewBox 300 × 190.
- `vegetacao_grupo_f1_v2.png` — textura RGBA 600 × 380; transparência real.
- `comparacao_v1_v2_no_mapa.png` — referência completa, grupo marcado, V1 e V2 na mesma escala e antes/depois no mapa.
- `tres_posicoes_v2.png` — três posições exploratórias na faixa de mata, não aprovadas como composição final.
- `mapa_estatico_v2.png` — montagem estática em (22, 15), não captura de Godot.
- `build.py`, `previews.py`, `qa_v2.py`, `qa_v2.json` — regeneração e verificação.

## Verificação e passagem

`qa_v2.py`: **7 PASS, 0 FAIL** para RGBA, transparência, conteúdo, tamanho, máscara de geometria protegida, as três posições e presença das cores de copa do projeto. A prévia alterou **598 pixels; zero em regiões protegidas** da máscara independente de vias, lotes, acessos e píeres. A máscara não prova que a composição sobreposta à vegetação atual esteja boa.

**PENDING:** julgamento visual, captura em Godot, teste no aparelho alvo, decisão de posição e integração. `ready_for_release=false`. Para integrar, substituir ou compor com a vegetação presente na área escolhida; revisar ordem de camadas e não repetir o grupo várias vezes como se fosse um arbusto. Esta peça isolada não usa RNG; se um gerador de posições for implementado, separar RNG por identidade e canais de posição/forma.

O checkout `art/f01-galpao` foi apenas inspecionado. Seus três arquivos alterados anteriormente foram preservados; nenhum commit, push ou PR foi feito. Manter decisões 034–036.
