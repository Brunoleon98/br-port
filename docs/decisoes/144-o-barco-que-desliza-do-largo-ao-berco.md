# 144 — O barco que desliza do largo ao berço, e o desenho do tema animação e toque

**29–30/10/2026 · o segundo tempo do bloco de 29/10 (`143`), para o tema
que o Bruno escolheu: a animação e o toque.** A conversa mediu, desenhou os
quatro itens (A1, A1′, A3, T1), perguntou-lhe o desenho de cada um e a ordem,
e implementou só o primeiro: **o A1′, o barco que desliza do largo ao
berço.** Os outros três ficam na §7, um por conversa, com o desenho escrito
aqui. Main `0a2e16f` (o PR #155 da `143` fundido a meio da conversa; a
branch avançou por fast-forward, sem nada à frente).

## O que se mediu antes de desenhar

Uma sonda nova (fora do repositório, como a da `143`) leu o mapa quadro a
quadro nos três momentos do A1: o toque num cartão «Ao largo», a virada que
acaba uma obra e o «Avançar dia».

- **Atracar não tinha gesto nenhum.** O barco aparecia no berço no quadro do
  toque (f001). A chegada da `078`, pelo `RUMO_DO_MAR`, é criada e morta no
  mesmo `refresh()`: desde a `083` o trabalhador vai com o barco, e «quem
  aloca a meio da chegada encosta o barco já». **A `143` dizia o contrário,
  e estava errada** — a frase da pergunta original («não tem gesto») era a
  verdadeira, e a correção leu o `Dock.gd` em vez de o medir. É a `078` a
  morder do outro lado: ali o código escrito não corria e lia-se como se
  corresse; aqui corria em 03/10 e deixou de correr dois dias depois, com a
  fila, sem guarda nenhuma a dar por isso — o D41 monta os barcos SEM
  trabalhador à mão, e prova um caminho a que o jogo já não chega.
- **O barco que sumia do mapa não era o tocado.** Cada lugar ao largo
  pintava a mesma POSIÇÃO da fila: atracar o primeiro escondia o último e
  passava os cascos dos outros um lugar para trás. Na virada, o arrasteiro e
  o bote trocavam de lugar no mesmo quadro.
- **A obra que acaba** troca a textura do píer num quadro (`pier_obra_1` →
  `pier_n1`), e mais nada.
- **Háptica:** nenhuma chamada no jogo, nenhuma permissão `VIBRATE` no
  preset Android.
- **Desempenho** (`medir_desempenho.gd`, 29/10): 405,6 e 604,0 chamadas de
  desenho, 99 e 102 tweens — o mesmo da `143`.

Os protótipos do A1′ e do A3 foram feitos NA SONDA, sem mexer no jogo: ela
deixava o jogo atracar e conduzia o casco ela própria. Saíram em MP4
(H.264, três voltas), que é o que o app mostra (`142`).

## O que o Bruno escolheu

| Pergunta | Resposta |
|---|---|
| A1′ — como o barco vai do largo ao berço | **Curva até à boca do berço, e entra de ré pela faixa da `078`, em 1,4 s** (a recomendada), contra a reta em 1,0 s e a chegada da `078` religada (que não sai de onde se tocou) |
| A3 — quanto o casco rola | **1,5°** (a recomendada), contra 3° e não rolar |
| A1 — o retorno na obra e no botão | **A peça nova assenta, e o «Avançar dia» afunda ao toque** (a recomendada), contra isso mais a máquina da obra a partir, e só o botão |
| T1 — a háptica | **Ligada por omissão, com «Vibração» nos Ajustes**, em três momentos (a recomendada), contra desligada por omissão e também a cada virada |
| A ordem | **A1′ → A1 → T1 → A3** (a recomendada) |

## O A1′, como está no jogo

- **O lugar ao largo é do BARCO** (`Main._lugar_do_barco`, id → nó em
  `ANCORADOS`). Quem chega fica com o primeiro lugar livre; quem sai (atraca,
  desiste, vai para o Arlindo) deixa o seu vazio, e os outros não se mexem.
  O cartão «Ao largo» continua pela ordem da fila — a ordem nunca se leu pela
  posição no mapa (`083`).
- **O `atracou` diz à doca de onde o barco vem** (`Dock.chegar_de()`, com o
  centro global do lugar). O sinal sai antes do `fila_mudou` que esvazia o
  lugar e do `roster_changed` que refresca a doca, e é por isso que o lugar
  ainda está no mapa quando se lê.
- **O casco faz uma curva de ré** (`Dock.ponto_do_deslize()`, uma Bézier
  cúbica): o primeiro controlo puxa 35% do caminho para a boca do berço, o
  segundo está na faixa dele, e a curva acaba TANGENTE ao `RUMO_DO_MAR` — a
  última perna é a chegada da `078`, que é a que não cruza o píer. 1,4 s, a
  travar no fim. Opaco o caminho todo: sai de onde o jogador o viu.
- **O trabalho espera o casco encostar.** Enquanto desliza, ninguém no
  tabuado e a lança varre como numa doca vazia; o `_pousar_barco()` chama o
  `refresh()` que arma o trabalho. O «Avançar dia» a meio encosta-o já (o
  `_concluir_virada()` da `078`), e o trabalho arranca antes de o dia virar.
- **Com o movimento reduzido não há deslize** (RB6): a origem nem se guarda,
  e o barco está no berço no toque, como antes.
- **A captura** leva o deslize ao fim antes da foto do tiro `atracar`, como
  já levava a virada; sem isso a guarda da virada reprovava a foto.

## As guardas, e os defeitos que as provam

O **D52** é novo (`tests/casos_deslize_do_largo.gd`), e abre a cena com três
cascos diferentes ao largo, toca no PRIMEIRO cartão pela porta do jogador e
lê o nó a cada passo de 1/60 s:

1. o lugar tocado esvazia e os outros dois ficam com o casco que tinham;
2. o casco começa no centro do lugar tocado (0,2 px; o corte é 3);
3. o caminho nunca salta (maior passo 5,4 px; corte 20), não esmaece, acaba
   no berço, e o último sexto chega pela faixa (cosseno 1,000 contra o
   `−RUMO_DO_MAR`; corte 0,9);
4. enquanto desliza, ninguém no tabuado, o guindaste não opera e a lança
   varre; encostado, o trabalhador aparece;
5. o `_concluir_virada()` a meio encosta-o e arma o trabalho;
6. com o movimento reduzido está no berço no toque, com o ciclo do guindaste
   a correr.

**O T29 apanhou um defeito na primeira corrida**: com o movimento reduzido a
origem ficava pendente, o `_guindaste_opera()` dizia que não no refresh do
toque, e nada rearmava o guindaste do n1. A correção é não a guardar, e o
defeito ficou no catálogo.

DEFEITOS_POR_MEDIR

## O custo

CUSTO_POR_MEDIR

## O desenho dos outros três, para as conversas seguintes

Cada um é uma conversa (a ordem é a do Bruno). Todos passam pelo movimento
reduzido (RB6) e mostram-se em vídeo antes do veredito.

**A1 — a peça nova assenta, e o «Avançar dia» afunda.**
- *O que mexe:* na virada que conclui a obra (o `obra_concluida`), o nó da
  peça nova — o `Pier` da doca, ou a estrutura do `ObraNoMapa` — assenta de
  97% a 100% do tamanho em 0,3 s, a travar, **com o pivô no CHÃO** (a origem
  do mundo no quadro de 512, `projecao.md`), para não levantar do lugar.
  Pedra não salta: sem passar de 100%. O botão afunda 4% ao `button_down` e
  volta ao `button_up`.
- ⚠️ **O botão vive num `HBoxContainer`, e um contentor reescreve a
  `scale` do filho** (`interface.md`, o giro que se desfaz): ou o botão vai
  para um `Control` simples que o contentor arruma, ou o afundar é do
  conteúdo (a margem do stylebox), e mede-se qual não mexe no D43.
- *Como se prova:* uma sonda ao longo dos frames — o assentar acontece SÓ na
  virada que conclui e SÓ na peça que concluiu, acaba em escala 1 exata, e
  com o movimento reduzido não acontece. Mutantes: assentar em toda virada;
  a peça errada; acabar em 0,97. A captura leva-o ao fim com a virada
  (`_concluir_virada()`), e a bateria fica igual ao byte fora do tiro
  `virada`.
- *Custo:* um tween passageiro por obra.

**T1 — a háptica.**
- *O que mexe:* um ponto único, como o `Audio.gd`, que recebe o MOMENTO
  (`atracar` ~20 ms; `obra pronta` e `parcela paga` ~40 ms) e chama
  `Input.vibrate_handheld()`; a preferência «Vibração» nos Ajustes, ao lado
  do Reduzir movimento, na `PreferenciasDeApresentacao` (fora do save da
  partida), ligada por omissão; a permissão `VIBRATE` no preset Android
  (`plataforma.md`). A virada simples não vibra.
- *Como se prova:* a suíte não sente vibração; prova-se o PEDIDO. O ponto
  único conta os pedidos por momento (como o `Audio` conta o que toca), e a
  guarda confere um por atracar, um por obra pronta, um por parcela paga,
  zero por virada simples e zero com a preferência desligada; o `teste_fumaca`
  lê a permissão no preset. Mutantes: a preferência ignorada; vibrar em toda
  virada; a permissão fora. A linha nova dos Ajustes entra no D33 (contraste)
  e no RB5 (texto ajustável).
- *Gate:* o telefone do Bruno; o APK só sai do CI. No Web, o Android Chrome
  vibra e o iOS não.

**A3 — o casco que rola 1,5°.**
- *O que mexe:* o barco atracado (`Dock._iniciar_balanco()`, uma rotação em
  paralelo com o subir, no mesmo período de 1,7 s, pivô no centro do
  quadro) e os três ao largo (`Main._animar_ancorados()`, que já passa pelo
  `MovimentoDeFundo` — a rotação 0 entra no repouso). O deslize do A1′ e a
  partida da `078` põem a rotação a 0.
- *Cuidados:* a carga pendurada do n2/n3 e a empilhadeira não rodam com o
  casco; a 1,5° as pontas de um casco de 100 px mexem ~2,6 px e o porão,
  perto do centro, menos de 1 — vê-se no vídeo do D42. O «+R$» nasce do
  `centro_do_barco()`, que não roda.
- *Como se prova:* sonda ao longo dos frames — o casco roda dentro de ±1,5°,
  a subir de um lado e a descer do outro; com o movimento reduzido, rotação
  0. Mutantes: 3°; rolar com o movimento reduzido; ficar torto depois de o
  ligar. A bateria muda UMA vez, em toda foto com barco.
- *Custo:* medido no protótipo, +1 tween por barco atracado (+2 no porto
  completo) e nenhuma chamada de desenho.

## O que fica de fora

- **A chegada da `078` pelo mar** continua no código e só o D41 a percorre:
  no jogo, todo barco que entra num berço vem do largo, e a que vem SEM
  origem (um barco que o mapa não pintou) encosta no toque, como antes.
- **O barco devolvido ao largo** (tocar na doca, `083`) sai pelo mar, como
  o servido, e reaparece no primeiro lugar livre — não faz o caminho de
  volta.
- **Que a curva não passe por cima de um píer ou de uma boia** não tem
  guarda: a última perna é a faixa da `078` (o §3 prende-a), e o resto é mar
  aberto nos três berços, visto na prancha. O casco desenha-se na doca,
  depois do `Cenario`, e por isso passaria POR CIMA de uma boia que cruzasse.
