# 056 — Os três que falam no kit afinado, cada um com a sua cabeça

**24/09/2026 · frente 2 do A5 (retratos de fala), decidido pelo Bruno** nos
vereditos desta conversa, todos na foto do jogo: a contente da Dona Cida (B),
o Sr. Ribeiro (v4) e o Arlindo (v6).

## O que se decidiu

1. **A Dona Cida contente sorri de boca FECHADA e com os olhos**: a boca em U
   (`sorriso_fechado`), a sobrancelha a meio caminho da neutra (`suave`) e a
   pálpebra de baixo a subir (`sorrindo`). A de boca aberta e sobrancelha
   erguida lia como ESPANTO. A séria e a preocupada da `055` ficam.
2. **O Sr. Ribeiro e o Arlindo passam ao kit afinado da `055`, cada um com a
   SUA forma** (plano de arte P2): o Ribeiro retangular e alto — maxilar
   quadrado, careca com uma ferradura grisalha, terno de ombro direito —, e o
   Arlindo de ângulos — maxilar em V, bigode em divisa, patilhas em bico,
   boné de capitão redondo puxado para trás, dragonas. Em Standard a −0,35 EV,
   como a Dona Cida.
3. **Cada personagem é enquadrado pela SUA cabeça** (60% do quadro, a medida
   da `055`), e não à escala da Dona Cida. À escala dela a cara do Ribeiro
   saía 8,5% menor, e o Bruno pediu-o mais perto.
4. **O kit de caixas dos retratos de fala saiu** (`_corpo()`, `_arlindo`,
   `_ribeiro` e as peças deles em `brp_porto.py`). Quem continua no kit de
   antes é só o trabalhador do rodapé, que é outro retrato (corpo inteiro).

## Por que

- **A cabeça é um objeto por personagem** (`Rosto` em `brp_retratos.py`):
  largura, fundo, alturas, olho, boca, brilho e lábio. Com constantes da Dona
  Cida, cada personagem teria de copiar as funções da cara; com a `Rosto`, as
  alavancas da expressão são as mesmas para os três e as medidas não.
- **As caras saem da FALA que acompanham**, e não de um adjetivo: a pressão
  do Arlindo («Minha oferta não expira. A paciência do senhor, sim.») é um
  meio sorriso frio — «sempre sorrindo quando ataca» —, e a grave do Ribeiro
  é triste, não zangada — «quando bravo fica MAIS educado».
- **Os detalhes da expressão vivem na pele** (rugas nos cantos dos olhos, os
  vincos entre as sobrancelhas, a ruga da testa), pedidos na v3 do Arlindo:
  «melhorar e refinar detalhes das expressões».

## Como

- `blender/brp_retratos.py`: `CIDA`, `RIBEIRO`, `ARLINDO` e o `KIT`, que o
  `retratos_de_fala` percorre. Alavancas novas: boca `sorriso_fechado`,
  `sorriso_lado`, `sorriso_curto`, `sorriso_dentes`; cenho `suave`,
  `carregada`, `triste` (e a `torta` com a metade carregada); olho
  `sorrindo` e `cerrado` a um terço. Peças novas: `_retalho` (o pano pousado
  por raios de frente), `_retalho_cima` (por raios de cima: as dragonas),
  `_ferradura` (o cabelo em U, em camadas alternadas), `_pala` (nascida da
  curva da faixa) e `_anel_eliptico`.
- As caras dos três estão na `_CARAS` de `brp_porto.py`, com a fala ao lado.
- O caminho de cada um, volta a volta, está em `art_lab/retratos/`
  (`cida_contente/v1/`, `ribeiro/v1`–`v4`, `arlindo/v1`–`v6`), com o
  veredito do Bruno em cada volta nos README.

## A prova

- **Cada PNG em `brport_vs/` é o da candidata aceite**: 0 pixels diferentes
  entre o que o estúdio gera e o que o Bruno viu na foto.
- **Nenhum pixel estourado** nas nove caras a −0,35 EV, a pele clara do
  Ribeiro incluída (era o risco que o briefing apontava).
- **O manifest sai idêntico** (as fichas não mudam), e o validador do Blender
  dá `BRP BLENDER OK`.
- **No jogo, a bateria inteira** (`tools/capturar_evidencia.sh`) na árvore
  da `main` (`5276efa`) e na de hoje, comparadas em RGB: **mudam 5 fotos em
  31** — `ribeiro`, `ribeiro_pagou`, `ribeiro_nao_pagou`, `contraoferta` e
  `contraoferta_fim` —, cada uma só dentro da caixa do retrato; o `boletim`
  não muda, porque mostra a Dona Cida séria. Sem tiro na bateria: a
  preocupada e a contente da Dona Cida, a formal do Ribeiro e a pressão do
  Arlindo — viram-se nas pranchas e, a contente, numa foto do boletim ótimo
  tirada numa cópia.
- **A Dona Cida séria e preocupada não foram regeradas**: o código dela não
  mudou (o refactor da `Rosto` dá os mesmos pixels que o de antes na mesma
  corrida), e o `comparar_props.py` dá 0,0000 contra as PNG da `055`.

⚠️ **E «RUÍDO ENTRE MÁQUINAS» ERA UM PALPITE, E ERRADO.** O commit do
checkpoint (`05b63dd`) atribuiu a ~700 pixels de diferença entre a Dona Cida
de hoje e a da sessão anterior ao contêiner ser outro. Medido depois: o MESMO
código, nesta mesma máquina, deu dois resultados estáveis — a séria de uma
corrida bate a **0** pixels com a PNG da sessão anterior e a **787** com a de
outra corrida desta tarde (Δ máx 45, num pixel; no Ribeiro Δ máx 4). O que
decide qual dos dois sai não se mediu. O que vale: `px diferentes = 0` entre
duas corridas acontece, mas não se garante — a prova de «não mudou» é o
`comparar_props.py`, que dá 0,0000 nos dois casos.

## O que fica por fazer

- **O trabalhador do rodapé** no kit afinado: é o único retrato em AgX e no
  desenho de antes, e fica ao lado da Dona Cida no boletim.
- **Os tiros das caras sem foto na bateria** (preocupada, contente, formal,
  pressão), com o catálogo de capturas ao nível do TEMPO (`051`).
- **As alavancas que nenhuma cara usa** (`sorriso`, `sorriso_dentes`,
  `sorriso_curto`) ficam porque os scripts das candidatas as usam; saem no
  dia em que ninguém as quiser refazer.
