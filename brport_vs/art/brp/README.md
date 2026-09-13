# `art/brp/` — assets do pacote ainda FORA do vertical slice

Terreno, cidade e vegetação produzidos pelo pipeline do pacote de arte
(`blender/`, FASES 3, 5 e 6 do prompt mestre).

**Nada que permaneceu aqui entra em `Main.tscn`.** O item 9 do segundo
playtest reabriu só três animais; gaivotão, maria-farinha e tartaruga-verde
passaram para `art/props/` e para a cena principal. Cidade, tiles e a vegetação
experimental continuam fora, e o chão do jogo é o SVG de
`tools/gerar_mapa_iso.py`, não estes tiles.

Existem para `scenes/tests/AssetPlacementTest.tscn`, que é onde o critério de
aprovação do prompt se verifica: o mesmo asset em três posições do mapa sem
perder origem, escala nem ordem de desenho.

Quem quiser puxar o restante para o jogo ainda tem de reabrir a decisão 001 —
o recorte de três espécies não autoriza o pacote inteiro.

---

⚠️ **`gerar_brp.py todos <dir>` despeja os 24 assets no MESMO diretório**, e
nove deles são estes — os que não entram no jogo. Regerar o catálogo apontando
para `brport_vs/art/props` deixa lá nove PNGs que ninguém pediu, e o
`asset_validator.gd` acha-os na primeira pasta em que procura e passa: a
duplicata não dá erro, dá dois arquivos a divergirem no dia seguinte. Regere
para um diretório temporário e copie de lá o que pertence a cada pasta.
