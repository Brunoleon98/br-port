# `art/brp/` — assets FORA do escopo do vertical slice

Terreno, cidade e fauna produzidos pelo pipeline do pacote de arte
(`blender/`, FASES 3, 5 e 6 do prompt mestre).

**Nada aqui entra em `Main.tscn`.** A decisão registrada em
`docs/decisoes/001-pacote-de-arte-externo-e-o-gdd-7.md` mantém cidade e fauna
na lista `VS — OUT` do GDD 7, e o chão do jogo é o SVG de
`tools/gerar_mapa_iso.py`, não estes tiles.

Existem para `scenes/tests/AssetPlacementTest.tscn`, que é onde o critério de
aprovação do prompt se verifica: o mesmo asset em três posições do mapa sem
perder origem, escala nem ordem de desenho.

Quem os quiser no jogo tem de reabrir a decisão 001 primeiro — não é uma
questão de arrastar o arquivo.

---

⚠️ **`gerar_brp.py todos <dir>` despeja os 24 assets no MESMO diretório**, e
nove deles são estes — os que não entram no jogo. Regerar o catálogo apontando
para `brport_vs/art/props` deixa lá nove PNGs que ninguém pediu, e o
`asset_validator.gd` acha-os na primeira pasta em que procura e passa: a
duplicata não dá erro, dá dois arquivos a divergirem no dia seguinte. Regere
para um diretório temporário e copie de lá o que pertence a cada pasta.
