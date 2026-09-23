# BR Port F1 — vegetação de grupo V3

**Status:** candidata visual isolada; aprovação estética e integração pendentes.

## Resposta à correção

A V2 simplificou demais o grupo e perdeu a densidade que funcionava na V1. A V3 parte da **estrutura vetorial da V1**: duas árvores distintas, arbustos frontais em profundidade, folhagem lateral e pequeno detalhe ocre. Mantém esses volumes e os contornos das copas; ajusta o intervalo dos verdes para a vegetação F1, reposiciona os ramos laterais que pareciam soltos e usa 82 × 52 pixels na prévia 720 × 720. A comparação coloca V1 e V3 na **mesma escala e posição**, com o conceito inteiro e o grupo de referência destacado.

A cor e a ocupação no mapa melhoraram frente à V1 sem a repetição dos arbustos da V2. **Limite visual:** as copas ainda têm planos rígidos e o arbusto do conceito é mais arredondado e integrado ao solo. A decisão de qualidade estética cabe ao Bruno.

## Arquivos

- `vegetacao_grupo_f1_v3.svg` — fonte vetorial editável; viewBox 300 × 190.
- `vegetacao_grupo_f1_v3.png` — RGBA 600 × 380, fundo transparente.
- `comparacao_v1_v3_no_mapa.png` — conceito completo, grupo marcado e antes/V1/V3 em escala igual.
- `tres_posicoes_v3.png` — alternativas exploratórias no mapa, sem aceitação de implantação.
- `mapa_v3_82px.png` — sobreposição estática em (12, 10), sem captura Godot.
- `build_source.py`, `build.py`, `previews.py`, `qa_v3.py` — reprodução e testes; V1 preservada à parte.

## Verificações e passagem ao código

`qa_v3.py`: **7 PASS, 0 FAIL** para dimensão, alfa, conteúdo, mapa, máscara independente e retângulos das três posições. A prévia alterou **1.621 pixels**, zero na máscara protegida por vias, lotes, acessos e píeres. Isso não verifica compatibilidade com todos os objetos e rotas no runtime. **PENDING:** avaliação estética, captura no Godot, teste no aparelho alvo, posição final, ordem de camadas e integração. `ready_for_release=false`.

Para integrar, usar uma única instância do grupo na camada ambiental de vegetação, após revisar sobreposição com árvores existentes; evitar repetição como arbusto individual. Se a posição passar a ser gerada proceduralmente, separar os sorteios de posição e forma por identidade estável. Esta peça isolada não usa RNG para posicionamento. O checkout `art/f01-galpao` só foi inspecionado; suas três modificações preexistentes permaneceram intocadas. Nenhum commit, push ou PR. Manter as decisões 034–036.
