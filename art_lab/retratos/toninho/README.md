# O Toninho no kit afinado — v1 a v6

**Estado: ✅ v6 ACEITA pelo Bruno na foto do jogo (12/10), e os PNG já em
`brport_vs/art/props/`** — mas ainda sem fala: o registro em `Retratos.gd`
entra com as falas do tutorial, na sessão seguinte (o F7 do fumaça reprova
cara registada que nenhuma fala pede). O construtor é o `toninho()` de
`blender/brp_retratos.py` (com a `TONINHO`), as três caras estão na `_CARAS`
de `blender/brp_porto.py`. A decisão é a `100`.

**Base:** `main` em `fbd2b64` (o PR #123, o M11, fundido).

## O que se pediu

O guia do **tutorial curto** (frente 5, escolha do Bruno em 11/10). O GDD pede
o Toninho — o estivador-chefe, vinte anos com o avô —, que o jogo só citava
no diário; a recomendação era a Dona Cida, que já tem rosto, e o Bruno
escolheu **o Toninho com rosto novo**. O escopo foi dele, numa volta, todas as
recomendadas:

- pele **preta** (a `pele_funda` dos trabalhadores) — a única que nenhum dos
  três que falam usa;
- **cabelo branco rente e bigodão branco** — o único topo branco e cheio, e
  o único bigode branco (o do Arlindo é escuro e fino);
- **camisa de botão mostarda gasta, aberta no peito, e um pano no ombro** —
  o que o estivador usa para pôr a saca ao ombro; a única peça assimétrica de
  um tronco;
- **três expressões, uma por fala**: calmo, irônico e sério.

## As seis versões

| | o que era | o veredito do Bruno |
|---|---|---|
| **v1** | a cabeça do trabalhador sem capacete; cabelo em CACHOS (esferas) sobre uma calote; bigodão em tufos; camisa com V de pele e gola escura; pano liso. A prévia tinha a calote no grisalho e lia «touca cinzenta com pontos brancos», e o cabelo foi refeito antes de a mostrar | ajustar: cabelo mais rente, laterais lembram capacete, pano curto e dobrado, boca some no sério — e «veja outros detalhes» |
| **v2** | cachos menores pousados POR RAIO na calote (os das têmporas estavam enterrados na quina do oitavado); sem patilhas; bigode cheio e boca 2 px abaixo; duas rugas por olho; pano curto com a ponta dobrada; sombra debaixo do queixo | ajustar: «capacete com bolinhas brancas», cabelo ainda alto |
| **v3** | SEM esferas: a calote colada ao crânio, o grão crespo no MATERIAL (Voronoi), contorno irregular por Displace, entradas nas têmporas e degradê até à pele nos lados; crânio 8 px mais baixo; sobrancelhas brancas | ajustar: topo quadrado, linha do cabelo em escada, «dê uma melhorada na camisa» |
| **v4** | o crânio e o cabelo em CÚPULA (`_cupula`), com a linha do cabelo como a última linha da malha; a camisa pela receita do Arlindo — V baixo, gola e carcela da cor da camisa, botões de coco redondos, bolso de pala | ajustar: riscos no tampo do cabelo, gola com raios |
| **v5** | o relevo apaga-se à volta do ápice e a calote é suave; a gola com grade mais fina, suave e com os cantos dentro do tronco | ajustar (pela lista): a frente do cabelo, o bigode lê como pente, as rugas como bigode de gato, o irônico desconfiado |
| **v6** ✅ | a borda do cabelo AFINA até ao crânio e a cor rareia até à pele; a linha do cabelo passou de M a arco; o bigode é uma massa só com o grão do cabelo; sem rugas no canto dos olhos; o irônico com a sobrancelha suave | **aceite** |

Cada pasta guarda o script da volta (`gerar_candidato.py`, que monta o
`Estudio` de verdade com o Toninho na lista dos que falam) e a prancha que o
Bruno viu: o cartão do boletim em tamanho real, hoje × candidata (os PNG da
Dona Cida trocados SÓ para a foto e devolvidos por `cp`, conferidos por
`cmp`), e as três caras a 3× sem suavizar sobre a placa proposta. Os scripts
das voltas antigas chamam o construtor de HOJE: o que cada volta era está na
tabela acima, e não no código.

## O que cada volta ensinou

- **Cachos numa ELIPSE enterram-se na quina de um OITAVADO.** Aos 45° a
  elipse da mesma largura fica ~9 px dentro da quina cortada: as têmporas
  liam lisas, como a borda de um capacete. Peça que tem de assentar numa
  superfície pousa-se POR RAIO nela.
- **Uma calote de cor única e lados retos é um capacete, ponha-lhe o que se
  puser por cima.** Esferas punham-lhe bolinhas; o que a fez cabelo foi tirar
  a borda dura — o grão no material, o contorno irregular, o degradê até à
  pele nos lados e na nuca, e (v6) a borda da frente a afinar até ao crânio.
- **Apagar faces de uma grade desenha uma ESCADA.** A linha do cabelo saiu
  lisa quando passou a ser a última linha da malha — cada coluna desce até à
  altura dela.
- **Um leque que se fecha num ápice faz lascas de meio píxel**, e com relevo
  e luz chapada elas desenham uma estrela. O relevo apaga-se perto do eixo, e
  a peça é suave.
- **Retalho pousado por raios acima do anel do ombro desce aos saltos.** Os
  cantos de cima da gola do Arlindo (106 e 98) estão acima do anel de 98 do
  tronco; com a grade fina, isso dava pontas soltas e triângulos pretos.
- **Uma borda de fios iguais é um pente.** O bigode em tufos, por mais que se
  sobrepusessem, lia como dentes; uma massa de contorno desenhado com o grão
  do cabelo lê como bigode.
- **A ponta de uma linha do cabelo em M fica uma língua quando o resto recua.**
  Com a borda a afinar, as entradas recuaram mais e o meio do M desceu
  sozinho pela testa; a linha em arco não tem meio a ficar para trás.
- **Rugas em leque no canto do olho são bigodes de gato** numa cara grande no
  quadro — três, e depois duas. A idade ficou nas sobrancelhas brancas, na
  olheira e num vinco na testa.
- **O AgX e o estouro**: a −0,35 EV em Standard (a escolha da `055`) os três
  PNG da v6 dão 0 pixels a 255 e o p99 a 238, como a Dona Cida (239). A v2
  tinha 106 pixels a 255 num cacho virado à luz-chave.

## O tom do balão (para a sessão do tutorial)

A camisa é a `placa_velha` (`#c29a4a`); clareada em OKLCH com o matiz dela,
o balão sai a **`#f5daa9`** (L 0,90, C 0,07) e a placa a **`#e1c797`** (L
0,84). Em CIELAB, o balão fica a **ΔE 27,2** da Dona Cida, **31,9** do Sr.
Ribeiro e **47,4** do Arlindo (o par mais próximo de hoje está a 19,9). O D38
lê o matiz da roupa NO PNG, pela mediana do tronco: quem aplicar o tom confere
o matiz contra o PNG da v6, não contra o hex da paleta. ⚠️ **E o tronco dele
não é só camisa**: o pano branco ao ombro, o V de pele e a gola entram na
mesma janela, e uma mediana por luminância sobre o tronco inteiro pode cair no
pano — a janela é a da camisa, do lado esquerdo da imagem, abaixo da gola.
