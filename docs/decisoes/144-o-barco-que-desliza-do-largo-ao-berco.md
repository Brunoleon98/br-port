# 144 — O barco que desliza do largo ao berço, e o desenho do tema animação e toque

**29–30/10/2026 · o segundo tempo do bloco de 29/10 (`143`), para o tema
que o Bruno escolheu: a animação e o toque.** A conversa mediu, desenhou os
quatro itens (A1, A1′, A3, T1), perguntou-lhe o desenho de cada um e a ordem,
e implementou só o primeiro: **o A1′, o barco tocado ao largo que vai até ao
berço** — aceite à quarta passagem, em vídeo. Os outros três ficam na §7, um
por conversa, com o desenho escrito aqui. Main `0a2e16f` (o PR #155 da `143`
fundiu a meio da conversa; a branch avançou por fast-forward).

## O que se mediu antes de desenhar

Uma sonda nova (fora do repositório, como a da `143`) leu o mapa quadro a
quadro nos três momentos do A1: o toque num cartão «Ao largo», a virada que
acaba uma obra e o «Avançar dia».

- **Atracar não tinha gesto nenhum.** O barco aparecia no berço no quadro do
  toque (f001). A chegada da `078`, pelo `RUMO_DO_MAR`, é criada e morta no
  mesmo `refresh()`: desde a `083` o trabalhador vai com o barco, e «quem
  aloca a meio da chegada encosta o barco já». **A `143` dizia o contrário,
  e estava errada**: a frase da pergunta original («não tem gesto») era a
  verdadeira, e a correção leu o `Dock.gd` em vez de o medir. O D41 monta os
  barcos SEM trabalhador à mão, e prova um caminho a que o jogo já não chega.
- **O barco que sumia do mapa não era o tocado.** Cada lugar ao largo
  pintava a mesma POSIÇÃO da fila: atracar o primeiro escondia o último e
  passava os cascos dos outros um lugar para trás.
- **A obra que acaba** troca a textura do píer num quadro, e mais nada.
- **Háptica:** nenhuma chamada no jogo, nenhuma permissão `VIBRATE`.
- **Desempenho** (`medir_desempenho.gd`): 405,6 e 604,0 chamadas de
  desenho, 99 e 102 tweens — o mesmo da `143`.

## O que o Bruno escolheu, passagem a passagem

| Pergunta | Resposta |
|---|---|
| O desenho dos quatro itens | As quatro recomendadas: o A1′ em curva, o A3 a 1,5°, o A1 com a peça que assenta e o botão que afunda, a T1 ligada com «Vibração» nos Ajustes |
| A ordem | **A1′ → A1 → T1 → A3** (a recomendada) |
| As boias no caminho (6 de 9 caminhos) | **Tirá-las do caminho** (a recomendada), contra contorná-las, a profundidade e deixar |
| Veredito 1 | «Ajustar»: «entrar de ré estranha», «as boias novas leem pior», e no «Outro» *«um movimento mais lento e realista, também uma animação de água e até fumaça nos navios enquanto navegam»* |
| O escopo dessa abertura | **Arte nova com 4 direções**; **~2,5 s a arrancar e a travar**; a esteira e a fumaça como **itens seguintes da §7**; as boias **do lado do mar** (B) — as quatro recomendadas |
| Os cruzamentos com barcos parados | **Aceitar agora, fundeadouro depois** (a recomendada) |
| Veredito 2 | «Ajustar»: «a viragem salta», «parar para virar é robótico», «a ré na faixa é longa» |
| Veredito 3 | «Ajustar»: «o X na viragem», «a deriva não se nota» |
| Veredito 4 | **«Aceito»** |

## O A1′, como está no jogo

- **O lugar ao largo é do BARCO** (`Main._lugar_do_barco`): quem chega fica
  com o primeiro lugar livre, quem sai deixa o seu vazio, e os outros não se
  mexem. O cartão «Ao largo» continua pela ordem da fila (`083`).
- **O `atracou` diz à doca de onde o barco vem** (`Dock.chegar_de()`), antes
  do `fila_mudou` que esvazia o lugar e do `roster_changed` que a refresca.
- **Três trechos, como um barco manobra** (`Dock.pose_do_deslize()`): de
  PROA do lugar até perto da boca do berço (1,1 × o `RUMO_DO_MAR` para fora
  dele, ~110 px), com a arte que aponta para onde ele vai; a VIRAGEM em passos
  de 90° (0,35 s cada) sem parar — o casco desliza ~40 px pela faixa e a arte
  nova só aparece nos últimos 0,1 s de cada passo, numa segunda imagem por
  cima (`BarcoVira`) —; e a RÉ pela faixa da `078`, que é a que não cruza o
  píer, a travar no berço. A velocidade não cai a zero entre trechos (um
  Hermite por trecho, com a deriva nas pontas). Total ~2,6 s.
- **O trabalho espera o casco encostar**; o «Avançar dia» a meio encosta-o
  já. **Com o movimento reduzido não há deslize**, e a origem nem se guarda.
- **A captura** leva o deslize ao fim antes da foto do tiro `atracar`.
- **As boias do lado do mar**: o cone e as duas boias saíram do corredor
  entre os lugares e os berços (a `Ancoragem1` passou para o fim do
  `Cenario`, pela profundidade do D3).

## A arte nova: o casco virado para o cais

Os 9 cascos únicos ganharam uma variante `_ao_cais`
(`gerar_props_iso.py`, `SUFIXO_AO_CAIS`): o MESMO grupo do Blender espelhado
em `x`, por um Empty-pai de escala (−1, 1, 1) posto só durante o render. É a
única transformação que serve: rodado 180° ele mostraria os lados que o kit
não detalha (corrimão, vigias, letras e pneus vivem no costado `-y`,
`arte.md`); espelhado em `x` a proa vai para o cais, a câmara vê a POPA, e o
costado detalhado continua à vista. A luz fica no mundo, como em todo prop.
Com o espelho da IMAGEM (o navio é simétrico), dá quatro rumos
(`Dock.arte_no_rumo()`). O controle: o bote normal re-renderizado pelo
gerador alterado mede **0,0000** contra o do repositório
(`comparar_props.py`). Entram como atlas (`projecao.md`), na tabela
`Dock.CASCOS_AO_CAIS` (acesso direto: um casco novo sem a variante rebenta) e
na família do nó `Barco` do catálogo dos props. **VRAM: ~1,05 MB** sem
compressão, os 9 atlas aparados — o mesmo que os 9 cascos de antes.

## As guardas, e os defeitos que as provam

O **D52** é novo (`tests/casos_deslize_do_largo.gd`): abre a cena com três
cascos diferentes ao largo, toca no primeiro cartão pela porta do jogador e
lê o nó a cada 1/60 s.

1. o lugar tocado esvazia e os outros ficam com o casco que tinham;
2. o casco começa no centro do lugar tocado (0,2 px; corte 3);
3. a arte de CADA passo contra o andar dele: de proa no primeiro trecho (64
   passos), nunca de lado, de ré só na faixa e ENTRANDO de ré por ela (48
   passos; corte 24), a viragem 90° de cada vez a
   deslizar devagar (nem parado nem depressa), a arte nova por cima só no fim
   de cada passo (≤ 6 passos de mistura por viragem), nunca salta, não
   esmaece, acaba no berço, e a menos de 50 px dele está no eixo da faixa
   (0,0 px; corte 11 — a reta dava 18,5);
4. enquanto desliza, ninguém no tabuado, o guindaste não opera e a lança
   varre; encostado, o trabalhador aparece;
5. o `_concluir_virada()` a meio encosta-o e arma o trabalho;
6. com o movimento reduzido está no berço no toque, com o ciclo a correr;
7. no porto completo, os 9 caminhos pela pose do jogo e com a máscara de
   cada rumo (o casco maior e o menor da frota): nenhum passa por cima da
   ancoragem, com um controle positivo (248 px), e **só os 3 cruzamentos
   aceites** passam por cima de outro barco parado — lista fechada nos dois
   sentidos.

**O T29 apanhou um defeito na primeira corrida**: com o movimento reduzido a
origem ficava pendente e o guindaste do n1 não arrancava. Ficou no catálogo.

Treze defeitos no catálogo (`tools/mutantes.toml`, secção da `144`), cada
um com a guarda que o apanhou na exploração:

| Mutante | Quem reprova |
|---|---|
| O `Main` não ouve o `atracou` (o barco aparece no berço, como antes) | §2, a 279 px do lugar |
| O lugar pinta a posição da fila (o defeito de antes) | §1, «0 de 2» |
| A boca do berço no próprio berço: chega de proa e vira em cima dele | §3, 1 passo de ré contra 48 |
| A arte de sempre o caminho todo (de ré e de lado, outra vez) | §3, 0 passos de proa |
| O espelho da arte trocado de rumo | §3, 64 passos de lado |
| A meia-volta de uma vez na boca do berço | §3, 1 meia-volta |
| A viragem parada (a deriva a zero) | §3, 41 passos parado |
| A arte nova a misturar o passo inteiro (o «X») | §3, 41 passos a misturar |
| O trabalho arranca com o casco no mar | §4, 83 passos com gente no tabuado |
| O casco encosta e o trabalho não rearma | §4 e §5 |
| A lança presa no repouso enquanto o casco vem | §4, «0,000 rad» |
| A origem guardada com o movimento reduzido (o defeito do T29) | o T29 e o §6 |
| O cone de volta ao corredor | §7, 5 caminhos |

⚠️ **Três sobreviveram à primeira versão da guarda que os devia ver**, e cada
um pediu uma pergunta nova: a reta (um cosseno com o número «medido» escrito
antes de medir; ficou a distância ao eixo da faixa), a boca no berço (nada
exigia que a ré EXISTISSE; ficou a contagem dos passos de ré) e as boias (a
régua das máscaras dava zero em tudo; ficou o controle positivo).

## O custo

CUSTO_POR_MEDIR

## O desenho dos outros três, para as conversas seguintes

Cada um é uma conversa (a ordem é a do Bruno). Todos passam pelo movimento
reduzido (RB6) e mostram-se em VÍDEO antes do veredito.

**A1 — a peça nova assenta, e o «Avançar dia» afunda.**
- *O que mexe:* na virada que conclui a obra (o `obra_concluida`), o nó da
  peça nova — o `Pier` da doca, ou a estrutura do `ObraNoMapa` — assenta de
  97% a 100% em 0,3 s, a travar, **com o pivô no CHÃO** (a origem do mundo
  no quadro de 512, `projecao.md`). Sem passar de 100%: pedra não salta. O
  botão afunda 4% ao `button_down` e volta ao `button_up`.
- ⚠️ **O botão vive num `HBoxContainer`, e um contentor reescreve a
  `scale` do filho** (`interface.md`): ou ele vai para um `Control` simples
  que o contentor arruma, ou o afundar é do conteúdo (a margem do stylebox),
  e mede-se qual não mexe no D43.
- *Como se prova:* sonda ao longo dos frames — o assentar acontece SÓ na
  virada que conclui e SÓ na peça que concluiu, acaba em escala 1 exata, e
  com o movimento reduzido não acontece. Mutantes: assentar em toda virada;
  a peça errada; acabar em 0,97. A bateria fica igual fora do tiro `virada`.

**T1 — a háptica.**
- *O que mexe:* um ponto único, como o `Audio.gd`, que recebe o MOMENTO
  (`atracar` ~20 ms; `obra pronta` e `parcela paga` ~40 ms) e chama
  `Input.vibrate_handheld()`; «Vibração» nos Ajustes, na
  `PreferenciasDeApresentacao` (fora do save), ligada por omissão; a
  permissão `VIBRATE` no preset Android (`plataforma.md`). A virada simples
  não vibra.
- *Como se prova:* o ponto único conta os pedidos por momento; a guarda
  confere um por atracar, um por obra, um por parcela, zero por virada e zero
  com a preferência desligada; o `teste_fumaca` lê a permissão no preset.
  Mutantes: a preferência ignorada; vibrar em toda virada; a permissão fora.
  A linha nova dos Ajustes entra no D33 e no RB5. *Gate:* o telefone.

**A3 — o casco que rola 1,5°.**
- *O que mexe:* o barco atracado (`Dock._iniciar_balanco()`, uma rotação em
  paralelo com o subir, 1,7 s, pivô no centro do quadro) e os três ao largo
  (`Main._animar_ancorados()`, pelo `MovimentoDeFundo`). ⚠️ **Desde esta
  decisão o nó `Barco` também espelha (`flip_h`) e tem uma segunda imagem
  (`BarcoVira`)**: o deslize e a partida põem a rotação a 0, e a `BarcoVira`
  roda com o `Barco` ou fica a direito.
- *Como se prova:* sonda — dentro de ±1,5°, em fase com o subir; com o
  movimento reduzido, 0. Mutantes: 3°; rolar com o movimento reduzido. A
  bateria muda UMA vez, em toda foto com barco. *Custo* medido no
  protótipo: +1 tween por barco atracado, nenhuma chamada de desenho.

## O que fica de fora, e para onde vai

- **O fundeadouro** (item novo da §7): com os lugares de hoje, **3 dos 9
  caminhos passam por cima do barco parado no lugar 1**, mesmo pesqueiro
  contra pesqueiro (o lugar 1 fica no meio dos caminhos dos lugares 2 e 3), e
  o do lugar 2 para o berço 1 tem o trecho de proa a ~56° do rumo (cosseno
  0,56: os caminhos para os berços de cima são quase verticais na tela, entre
  as quatro direções). Numa procura de 749 disposições dos três lugares, por
  caixas, nenhuma deixou os 9 limpos e de proa; uma rota pelos eixos cruzava
  5. As saídas medidas a seguir: a profundidade (o casco no `Cenario`
  durante o deslize), as diagonais (que pedem os DOIS costados detalhados no
  kit) ou outra composição do largo.
- **A esteira e a fumaça** (dois itens da §7, a pedido): a esteira sem
  partículas (uma risca de espuma que se desfaz atrás do casco), a fumaça
  como o primeiro sistema de partículas (A4: semente fixa, pára no RB6), as
  duas a valer também para o barco que parte na virada.
- **A chegada da `078` pelo mar** continua no código e só o D41 a percorre.
- **O barco devolvido ao largo** sai pelo mar e reaparece no primeiro lugar
  livre, sem o caminho de volta.

## O que se aprendeu

- **A pergunta que descreve o estado de hoje mede-o antes** (`/arte`) — e a
  correção também: a `143` corrigiu uma frase verdadeira lendo o código.
- **E a opção recomendada mede-se antes de ser recomendada.** Recomendei as
  4 direções sem medir para onde os caminhos apontam; eram quase verticais na
  tela, entre as quatro (`arte.md`).
- **O defeito passou de primeira duas vezes**: o `deslize-em-reta`
  sobreviveu ao cosseno do último trecho, com um comentário a afirmar um
  número que ninguém tinha medido (a regra do «comentário escrito no futuro»,
  `testes-e-guardas.md`); e a régua das boias deu zero em tudo até ao
  controle positivo, porque o `PropIso.desenho()` mede a partir do CENTRO do
  quadro (`projecao.md`).
- **A animação pendurada no verbo morre com ele** (`testes-e-guardas.md`).
