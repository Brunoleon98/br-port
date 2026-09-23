# BR Port — candidata 13A V5

Abra `13a_v5_comparacao_conceito_v4_v5.jpg`, `13a_v5_tres_posicoes.jpg` e `RELATORIO_13A_V5.md`. A referência conceitual está em `reference/Jogo - BR Port/13_arbustos_vegetacao_baixa_mangue_v4.png` na raiz do ZIP.

O pacote preserva a V4 para comparação e inclui uma cópia de trabalho do gerador V5, os SVGs completos **para prévia**, o PNG isolado, o patch de passagem e os testes. O jogo continua inalterado. Não copie os mapas sobre um checkout atualizado.

Para reconstruir o gerador, execute `python3 art_lab/f01/13a/v5/build.py` a partir da raiz extraída; ele exige o hash registrado da fonte V4 e o snapshot `Main.tscn` no pacote. Para reproduzir os PNGs, rasterize cada SVG com Inkscape a 720 × 720 e o espécime a 256 × 256. Depois, execute `python3 art_lab/f01/13a/v5/qa_v5.py` e `python3 art_lab/f01/13a/v5/previews.py`. Requer Python 3.10+, Pillow e Inkscape. Os testes leem o raster incluído; regenerá-lo antes de comparar outras fontes.

Antes de integrar, confira as mudanças atuais em `Brunoleon98/br-port`, reaplique o patch apenas sobre a base apropriada e capture a cena Godot em dispositivo. `ready_for_release=false`.
