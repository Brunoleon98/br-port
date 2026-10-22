# 133 — Ilustração v3 somente na tela inicial

**22/10/2026.** Continuação do fundo pedido na `132`, após o #146 ser
mesclado por Bruno. Base `0cd4ca3646fb86b0c8fdda555f2199f51138bc9a`.

A foto de runtime foi recriada no Godot 4.6.3 a partir da candidata
versionada, em cópia isolada. Bruno respondeu: “Aprovo esta v3 para a tela
inicial”. Porto ao fundo, navio inteiro acima do cartão e faixa de água
entre os dois; título e quatro botões mantêm suas posições.

A fonte de `art_lab/tela_inicial/v3/fundo.png` passa sem retoque para
`brport_vs/art/tela_inicial/fundo_inicial.png`: RGB opaco, 941×1672,
SHA256 `c8dd35c73b11a13da9d3f773ba916cce10b9307c8d7d1addb79faf9571e7ec6f`.
A largura é inferior aos 1080 px do briefing antigo; o aceite refere-se
à imagem real apresentada em 720×1280, sem alegar resolução diferente.

`FUNDO_INICIAL` serve somente à inicial. `TelaInicial.FUNDO` conserva o
degradê consumido pelo celular. Não muda o logotipo, outras telas, save,
preferências de movimento/texto ou arte do mapa.

O bloco D48, em arquivo próprio, verifica a fonte aceita no nó desenhado
pela inicial e o degradê no papel de parede real do celular. Os defeitos
contrários ficam no catálogo oficial. As fotos julgam composição e leitura;
a identidade da textura não substitui essa inspeção.

O aceite da arte não autoriza publicar esta nova entrega. Preparação local,
sem novo PR, push ou merge; publicação depende de pedido próprio do Bruno.
