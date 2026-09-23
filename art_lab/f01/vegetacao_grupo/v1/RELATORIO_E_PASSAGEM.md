# BR Port — vegetação F1, grupo completo V1

**Status:** candidata visual isolada, sem integração nem aprovação estética. Referência: `13_arbustos_vegetacao_baixa_mangue_v4.png`, **conjunto completo superior esquerdo**, incluindo a árvore alta à esquerda, árvore menor à direita, folhagem baixa, ramos laterais e sombras. A imagem de comparação também mantém o conceito inteiro visível.

## Entrega

- `vegetacao_grupo_f1_v1.svg`: fonte vetorial editável, viewBox 300 × 190.
- `vegetacao_grupo_f1_v1.png`: RGBA 600 × 380, sem halo pintado. Caixa de pixels visíveis registrada em `qa_grupo.json`.
- `comparacao_grupo_v1.png`: conceito inteiro com alvo marcado, alvo ampliado, asset em fundo quadriculado, uso estático no mapa e zoom.
- `tres_posicoes_estaticas_v1.png`: três explorações no canto da mata; **não são posições aceitas**. O posicionamento à beira da casa em uma alternativa exemplifica por que é necessária avaliação humana.
- `mapa_estatico_v1.png`: sobreposição exploratória a 100 × 63 pixels, origem de tela (12, 10). Não é captura de Godot nem novo mapa do jogo.

## Direção visual

A V1 preserva a composição inteira e separa duas árvores com troncos visíveis e estratos de arbustos. Usa faces largas por volume, folhas compridas isoladas nas extremidades e pequenas sombras de contato, sem a saia rígida do arbusto 13A anterior. **Diferença perceptível:** as copas da V1 continuam mais angulosas e planas que o arredondado orgânico e as nuances de iluminação do conceito; as pequenas folhas laterais podem desaparecer no tamanho de uso. A avaliação estética de Bruno permanece pendente.

## Guardas

`qa_grupo.py` executado: **6 PASS, 0 FAIL** para dimensões, RGBA, cantos transparentes, conteúdo visível, tamanho do mapa e diferença fora da máscara. A máscara independente usada em `art_lab/f01/13a/v5/mascara_geometria_protegida_v5.png` deriva de lotes, vias, acessos e píeres; na prévia foram alterados 2.462 pixels, dos quais **zero** sob essa máscara. A máscara não cobre todos os objetos da vegetação e não valida composição ou rotas em runtime.

Também reexecutados os **14 testes** de `qa_assets.py` (todos passaram) e a auditoria laboratorial V5 de 13A (**14 PASS, 0 FAIL, 4 PENDING**). Esses testes exercitam o verificador e o arbusto 13A V5; **não** aprovam este grupo automaticamente. Godot, aparelho alvo e avaliação visual permanecem **PENDING**. `ready_for_release=false`.

## Passagem ao código

Usar a textura RGBA como uma única peça ambiental posicionada na camada de vegetação, em origem de tela ou coordenada de mundo decidida no gerador. Tamanho de ensaio no raster 720 × 720: 100 × 63 pixels. Não duplicar sobre casas/estradas; rever profundidade, sombras e escala no Godot e no aparelho alvo. A opção estática (12, 10) tem máscara protegida livre, mas sobrepõe vegetação já presente. Se o grupo for desenhado pelo gerador, separar sorteios de forma e posição por identidade estável; a peça isolada não usa RNG de posicionamento.

O repositório `art/f01-galpao` foi somente inspecionado. As alterações preexistentes em `tools/gerar_mapa_iso.py` e nos dois SVGs do mapa foram preservadas; nenhum commit ou push foi feito. Manter as decisões 034–036 e integrar somente depois de escolher implantação e revisar o jogo.
