# 127 — O morro, o chão, a mata do Blender e a restinga das pontas

**17/10/2026 · item 1 da fila da `125`** — «melhorar o terreno e a
vegetação». Foto do jogo antes e o escopo perguntado ao Bruno, pela `/arte`.
A mata andou quatro passagens, todas «Ajustar» até à terceira; a quarta e a
primeira da restinga foram entregues em foto e **não foram aceites** (ver
«O veredito», no fim).

## O que o Bruno escolheu

| Pergunta | Resposta |
|---|---|
| Escopo | as quatro: mata densa (recomendada), restinga das pontas, chão com textura, morro ao fundo |
| Técnica das árvores | **Blender, como os coqueiros** (contra «no mapa, como hoje», a recomendada) |
| Coqueiros | deixar os três (recomendada) |
| Forma do morro | encosta de mata (recomendada) |
| Espécies | copa redonda, palmeira-juçara, embaúba, ipê florido |
| Movimento | **balançam, como os coqueiros** (contra «paradas, no mapa», a recomendada) |

## A medição de antes

8,1% do mapa era chão verde chapado; o capim, traço de 1,3 px a 0,7, com
Weber −0,21 contra o solo; as copas em SVG, lobos com saia de uma espécie só;
a restinga, relva chapada até uma aresta de régua contra a areia.

## O preço da escolha, e como se pagou

Um prop pinta-se por cima de TUDO o que o mapa desenhou. Uma árvore que
balança atrás de uma casa sai com a copa em cima do telhado. Daí duas regras:

- **a mata do morro é prop** e fica, na tela, ACIMA do contorno da vila
  (`horizonte_da_vila`: por coluna, a linha mais alta que a vila, as vias e a
  mata baixa pintam, lida do SVG que elas emitem). O perfil de cada árvore
  sai do PNG dela (`arvores_da_mata.json`, medido ao renderizar), sombra
  incluída;
- **a árvore entre as casas é EMBUTIDA** no SVG — o recorte do PNG num
  `<defs><image>` e um `<use>` por árvore, na ordem em que a `vila()`
  desenha. Fica atrás de uma casa e à frente de outra, e não balança. O
  ThorVG só desenha o `<use>` com `xlink:href` e o `xmlns:xlink` na raiz.

## As passagens da mata

1. **O morro e o chão.** O chão de trás passou a RASTER (o campo da água como
   receita): três oitavas de ruído de valor em hash inteiro, rodadas fora dos
   eixos — alinhadas, liam losangos. O morro sobe atrás da vila, com o pé no
   invólucro convexo das quinas dos degraus (pelo degrau, abria um vinco em
   cada junta) e o sol pela encosta. Quatro espécies no Blender, nove
   variantes, e o `MataNoMapa.gd` a plantá-las entre os irmãos do `Cenario`
   pela profundidade. «Ajustar»: quintal vazio, embaúba branca, o morro não
   se nota, e *«encaixar árvores no meio da cidade… em diferentes tamanhos»*.
2. **As embutidas e o quintal.** As copas SVG da vila deram lugar às do
   Blender embutidas; moitas no quintal de trás; a embaúba escureceu (o AgX
   leva o verde-acinzentado ao papel). «Ajustar»: árvores repetidas, árvores
   demais na vila, morro fraco, mais cor, e *«a textura das árvores está
   estranha em relação ao jogo… pesquise»*.
3. **Facetas.** A pesquisa (resumos; as páginas não abrem, `063`) repetiu o
   sombreamento chapado em facetas: a copa passou a icosferas de 80 faces,
   chapadas, com os vértices tremidos — o desenho do mapa em polígonos, no
   Blender. Segundas variantes, ipês e mangueira na vila, teto de escala, a
   mata ESCURA do morro. «Ajustar»: mata do morro maior, fruta da mangueira,
   copas claras demais, e *«versões menores das maiores… parece que as
   árvores estão muito grandes, inclusive o coqueiro»*.
4. **A quarta.** Paleta das copas um degrau abaixo, mangas de 0,12, a copa
   escura da mata e a mangueira em pequeno na vila (0,45 a 0,8 do tamanho), e
   a orla escura do quintal de trás embutida SÓ onde um prop não cabe — na
   primeira tentativa a faixa embutida subiu o contorno e comeu o chão da mata
   que balança. **Medido antes de mexer no coqueiro:** a casa térrea tem 20–25
   px de alto e ~50 de largo; o coqueiro 71 px, ≈3× a casa, que é a proporção
   real (8–12 m contra 3–4 m). Ficou como estava.

## A restinga das pontas (primeira passagem)

Da crista para dentro, como a restinga de verdade: o chão raster continua até
à crista e deixa a AREIA SECA aparecer entre a relva — domina a menos de 1 u
da duna, em manchas até 2,6 u —; o capim-da-praia em dois tons, verde e palha,
porque nenhum tom só ganha a relva e a areia; a salsa-da-praia, rama rasteira
de flor roxa, desce a areia seca até `t = 0,4` da rampa. As plantas são props
que balançam: a **aroeira** penteada pelo vento (copa deitada para terra,
fruta vermelha nas faces que se veem), o **guriri** sem tronco, e as moitas.
A árvore SVG antiga (`arvore()`) saiu com o seu último chamador.

A implantação aprendeu três coisas no erro:

- **chão plano à frente nunca tapa um prop.** A primeira versão exigia a
  planta inteira, sombra incluída, acima da crista, e as plantas encostaram
  todas à rua: a faixa tem 33 px de alto numa coluna e a sombra desce 10. O
  pixel acima do pé está à frente do chão que cobre, e a sombra abaixo dele é
  sombra no chão. O que fica é o PÉ fora da areia;
- **o «dentro» conta-se da costa, e a rua não a segue.** Junto do salto de um
  degrau seis aroeiras caíram no asfalto da ponta norte — o D2 viu-o. O pé
  cai à frente da rua do degrau dele, fora dos cotovelos e aquém do cerco da
  areia que a tabela publica (`recuos_das_praias`, o mesmo número do D15);
- **perto no mundo, empilhado na tela**: três aroeiras na mesma coluna liam
  como uma torre de copas, e a implantação ganhou uma folga na tela.

E o **quero-quero** passou de (455, 105) a (456, 76): a areia nova da restinga
caiu debaixo dele, e o D27 exige-o na relva.

## As provas

O **D47** (`casos_mata_do_morro.gd`) pergunta: a cópia do `MataNoMapa.gd`
contra a tabela; os nós no `Cenario`; os pixels de cada árvore do morro contra
o contorno da vila; o tronco de cada planta da restinga contra a crista à
frente (`cristas`, polilinha de tela por ponta — a crista À FRENTE, porque na
ponta sul a areia do degrau de trás fica acima da restinga do da frente); o
contorno contra os LOTES; a fauna; o balanço em volta do pé; e nenhuma copa a
tapar o desenho opaco de um prop parado. O D15 passou a deixar `Arvore` na
ponta de praia — a espécie, não o sítio: a areia continua proibida. Nove
mutantes no catálogo, um por pergunta, e dois sobreviveram à primeira: o do
contorno subia um lote, e o contorno, que é o mínimo da coluna, já vinha de
casas de trás 100 a 350 px acima — o mutante passou a cegá-lo nas colunas
da casa; e o do bicho em cima de uma moita passava porque a GUARDA lia a
caixa do sprite da fauna, que é atlas, pela região do `get_image()`, 256 px
ao lado (`049`). Corrigida pelo `PropIso.imagem()`, reprova — e o jogo de
hoje continua verde nela.

## O custo

Os dois mapas crescem 383 KB cada (o chão raster maior e os recortes
embutidos); a tabela de âncoras de 17,7 para 48 KB (o contorno, a lista e as
cristas); 19 PNG de árvore, 372 KB em disco e 144 KB de atlas; e a folha
dos props passou a treze páginas (260 props), porque cada espécie entra lá
uma vez, ancorada na primeira árvore dela.

## O que fica para outras conversas

- **Estradas:** um fio azul de 1 px corre ao longo da borda do pátio de
  terra, na ponta norte, contra a restinga — visto nas fotos, não medido nem
  investigado; pode ser o «fio diagonal» que a `125` deixou fora da fila.
- **Sprites de detalhes:** se o Bruno quiser o coqueiro menor, a medida está
  acima.

## O veredito

Ao fecho, vistas as fotos, o Bruno **não aceitou**: *«continue isso na
próxima conversa focando na melhoria de detalhes e correção de erros para que
a vegetação fique boa; além disso, o terreno pode ser melhorado também»*. O
item 1 da fila continua na conversa seguinte, e as estradas esperam por ele.
