# 058 — O trabalhador do rodapé em busto

**24/09/2026 · escolha do Bruno**, perguntada antes de produzir (a técnica de
um asset é dele): entre corpo inteiro no kit afinado, busto e só a cor, **o
busto**. Aceite na v6, na foto do jogo.

## O que se decidiu

**O `trabalhador_retrato` passou ao kit afinado dos retratos, em BUSTO e em
Standard a −0,35 EV**, como os três que falam (`055`, `056`). O construtor é o
`trabalhador()` de `blender/brp_retratos.py`; o de caixas de corpo inteiro e o
`_girar_para_a_camera` saíram do `brp_porto.py`.

**O busto dele é mais ABERTO: a cabeça, com o capacete, vale 56% do quadro, e
não 60%** (`TRABALHADOR_CABECA`; o `enquadrar` ganhou o parâmetro). Ele
identifica-se pelo COLETE, e a 60% a faixa de baixo saía cortada pelo quadro.
O tronco sobe 10 px de desenho pela mesma razão.

**O adesivo da frente do capacete tem peça e material próprios**
(`capacete_adesivo`, `adesivo`): pedido do Bruno, é o sítio do emblema que o
jogador escolherá para a empresa. Hoje é um decalque oval claro com uma faixa
navy.

## Por que

A regra do enquadramento (`CLAUDE.md`, Arte) dizia que o trabalhador era de
corpo inteiro porque o que o identifica é silhueta — capacete e colete. A
regra continua certa; o que o busto mostrou é que os dois cabem nele se o
quadro deixar peito à vista, e a cara ganha o tamanho dos três que falam: no
cartão de 70 px o boneco de corpo inteiro media ~18×41 px.

## Como

- Seis voltas em `art_lab/retratos/trabalhador/`, cada uma com a foto do jogo
  numa cópia da árvore e a pergunta com opções; o que cada volta corrigiu está
  no README de lá e em comentário no código.
- **O colete é uma superfície só** (`_envolver`): raios em leque de um eixo,
  das costas por cima do ombro até à frente. Painéis e alças empilhados liam
  «colados» (v4) e encostados deixavam camisa no meio (v3).
- A cor: sem estouro (0 px a 255, p99 236). O especular do casco e do
  refletivo foi baixado duas vezes por isso.
- O PNG do estúdio é a candidata a 0 pixels; o atlas do busto (512×764) ainda
  custa menos do que o quadro, e fica em atlas (`ASSET OK`).
- O arquivo do jogo mudou só nas caixas dos retratos: 14 das 31 fotos da
  bateria, todas em y 860–929.

## O que fica para depois

- **As variações** (pedido do Bruno, escopo escolhido por ele): 2 sexos × 3
  idades × as 5 cores do IBGE, **30 retratos**; rabo de cavalo nas mulheres,
  grisalho e rugas nos veteranos, cara lisa nos jovens, bigode ou cavanhaque
  em alguns homens, sem caricatura. Hoje o trabalhador nasce com o píer e todos
  usam o mesmo retrato; a variação entra escolhida pelo `id`, sem campo novo no
  save e sem gastar sorteio do `GameState` (a partida medida não se mexe), e o
  **sistema de RH** futuro põe cada uma no currículo e na negociação de
  salário.
- **O emblema do jogador** no adesivo do capacete.
