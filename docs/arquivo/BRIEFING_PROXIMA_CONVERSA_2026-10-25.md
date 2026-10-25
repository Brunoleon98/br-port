# BR Port — o mobiliário da rua (`140`) aceite; a fila da `126` acabou, e a seguinte é do Bruno

**25/10/2026.** Branch `ccr-421ae807-dm522g`, a partir da `main` `06a1b63`
(PR #151, a `138`, levado a verde no começo da conversa). Esta branch não
tem PR: ele não o pediu.

**Decisão `140` — o mobiliário da rua**, o item 3 da fila da `126` (os
sprites de detalhes), **aceite à oitava passagem**. O escopo foi dele:
postes e placas, cavaletes junto dos cones, só na rua do porto, trocando
trecho a trecho com a obra do pátio, como o asfalto da `136`. O que ficou:

- postes de concreto na calçada da vila, velho (escuro, a pender, cruzeta de
  madeira, luz de sódio que pisca) e novo (claro, LED), dois na curva de fora
  e um na quina de dentro de cada cotovelo;
- a fiação, dois fios por vão pousados nos isoladores lidos no PNG, que some
  atrás do lote da vila que lhe fica à frente — e um shader faz o mesmo ao
  sprite do poste atrás da igreja;
- a rede vem de uma subestação no relvado ao norte do pátio, com a linha de
  alta tensão numa torre treliçada desde a borda de cima e um ramal reto
  sobre a rua; a aroeira que ali estava mudou-se para junto da torre;
- PARE de frente para a câmara com as quatro letras, pedestres na calçada da
  vila antes da zebra, uma de 40; o raio da chapa é 0,150;
- dois cones no eixo do cotovelo seguinte e o cavalete na calçada do pátio.

**A prova:** o D45 §7 do `teste_design` (cópias da tabela, cada peça na
calçada do tipo dela, o dia do trecho, a planta da fiação, cada fio num
isolador, a máscara da vila), os D2/D15, e os 21 mutantes da secção `140`
do catálogo, cada um com a asserção que o reprova.

⚠️ Com `Y = 90` o Euler do kit está em bloqueio, e o giro do octógono do
PARE guinava a chapa (`.claude/rules/arte.md`).

⚠️ No `fragment()` de um `canvas_item`, o `COLOR` já traz a textura
(`.claude/rules/interface.md`, ao lado da regra do shader que só compila
onde é desenhado).

⚠️ O pixel do PNG de prop MULTIPLICA-se por `PropIso.escala()`; dividido, a
guarda da máscara contou zero (`.claude/rules/projecao.md`).

⚠️ A peça nova que expulsa uma planta da restinga tira-a DEPOIS do sorteio
(`.claude/rules/mapa.md`).

⚠️ O «Ajustar» chegou duas vezes sem texto; e quando os vereditos cercam um
número, as candidatas vão lado a lado no jogo (`/arte`, o veredito na
conversa, `140`).

**Pendente:** o PR desta branch, que é decisão do Bruno — com ele o catálogo
passa a 212 mutantes nas três fatias do CI. Os carros estacionados ficaram
fora do escopo (*«na rua, junto ao meio-fio»*, quando entrarem). As quinze
lacunas médias que a `138` deixou de fora continuam nomeadas lá.

**A próxima conversa:** a fila da `126` acabou, e o item seguinte é do
Bruno. Ela abre a perguntar-lho, com opções e a recomendada primeiro, sem
escolher por ele.

Prompt para colar:

```text
Continuando o BR Port. Leia CLAUDE.md, ESTADO_DO_PROJETO.md, a §7 do plano v3
e a decisão 140 (o mobiliário da rua, aceite). Confira a main remota, os PRs
abertos e o CI do último merge, e rode python3 tools/conferir_colaboracao.py
com o trabalho commitado (ele lê o HEAD). Se o trabalho da 140 (branch
ccr-421ae807-dm522g) ainda não estiver na main, pergunte ao Bruno se abre o
PR dele; se ele disser que sim, conduza-o até verde antes de começar: o
catálogo passou de 191 para 212 mutantes, e o job das três fatias cresce com
ele — leia o tempo de cada fatia e registe-o na 140.

A fila da 126 acabou (terreno, estradas e os sprites de detalhes), e o item
seguinte é do Bruno. Abra a conversa com a pergunta do que vem a seguir, com
opções e a recomendada primeiro, e não escolha por ele. O que está nomeado e
por fazer: os carros estacionados na rua, junto ao meio-fio (140); as quinze
lacunas médias que a 138 deixou de fora (treze visuais, uma de texto, uma
fora do headless); animar as marolas e o fio diagonal da ponta norte do cais
(124); o galpão recuperado V3; trabalhadores e crédito; e os gates A4 e A7,
que são dele. Se ele escolher arte, use /arte e comece pela foto do jogo e
pela pergunta do escopo.

Não comece outra funcionalidade por conta própria. Ao encerrar, aplique
/fechar-sessao e entregue o prompt completo da próxima conversa em bloco
copiável.
```
