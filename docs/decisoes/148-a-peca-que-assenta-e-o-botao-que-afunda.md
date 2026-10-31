# 148 — A peça nova que assenta, e o «Avançar dia» que afunda

**30/10/2026 · o segundo item do tema animação e toque, pela ordem do Bruno
(A1′ → A1 → T1 → A3, `144`): o A1, o retorno ao toque.** Branch
`claude/sharp-lamport-kf55gf`, que arranca da cabeça da `144`
(`ccr-83914c2f-kuj4zq`, `68ed363`): o PR #156 dela estava aberto e com o CI a
correr, e é acompanhado noutra conversa. Main `0a2e16f` no arranque e
`d11311b` no fecho (os PRs #156, #157 e #158 fundiram durante a conversa).
**Escrita como 145**, que o pré-PR deu por livre no arranque; o Codex fundiu
a 145 dele (o revisor de mensagens) primeiro, e esta passou a 148 pelo
`tools/renumerar_decisao.py`, só nas linhas desta branch.

## O que se mediu antes

- **A virada que conclui uma obra troca a textura num quadro, e mais nada.**
  Uma sonda (fora do repositório) abriu a cena na véspera de cada uma das
  oito obras do catálogo, premiu o «Avançar dia» e comparou cada nó do mapa
  antes e depois: a escala ficou em 1,000 nos 40 quadros seguintes, em todas.
  O que muda em cada uma:
  - píer 2 e píer 3: o `Pier` da vaga (obra → `pier_n1`) e a `Lanca`, que
    aparece;
  - treliça e pórtico: o `Pier` e a `Lanca` de cada vaga construída (o
    pórtico mostra também a empilhadeira do n3); cais: só o `Pier`;
  - armazém e escritório: o nó deles, da ruína (ou da obra) ao pronto;
  - pátio: o MAPA inteiro (terra → pavimentado), o equipamento que aparece
    (empilhadeira, caixotes, guincho, pallet), os postes e as placas do
    último trecho da rua (velho → novo) e os cones que saem.
- **Desempenho** (`medir_desempenho.gd`): 405,5 e 602,7 chamadas de desenho,
  389 nós, 99 e 102 tweens — o mesmo da `144`.
- **O botão, pelas duas saídas que a `144` desenhou** (um contentor reescreve
  a `scale` do filho, `interface.md`), cada uma num protótipo com o
  `teste_design` inteiro:
  - **o botão num `Control` simples** que o `HBoxContainer` arruma: o caminho
    passa a `AcoesTurno/AvancarCaixa/Avancar`, e a metade de contraste do D43
    deixa de correr — `Node not found` e `SCRIPT ERROR`, 4 das 14 asserções.
    Pedia mudar o caminho no D43, no RB5, no F22 e em quatro ferramentas;
  - **o premido do tema desenhado menor** (margens de expansão negativas no
    stylebox `pressed`): as 14 asserções do D43 passam iguais. **Foi esta.**
  - ⚠️ E com a primeira a suíte imprimiu **`DESIGN OK`** e «o bloco D43
    correu até ao fim»: a bandeira dele não cobre o sub-bloco do contraste.
    Quem o apanharia é o passo do `SCRIPT ERROR` do CI. Ficou como tarefa à
    parte.

## O A1, como está no jogo

- **Na virada que conclui uma obra, a peça nova assenta**: de 94% a 100% em
  0,3 s, a travar (quadrática), **com o pivô no chão** — o centro do quadro
  de 512, que é a origem do mundo do prop. Não passa de 100%. O desenho da
  `144` dizia 97%; no vídeo, a 1:1, quase não se via (no armazém, ~6 px), e
  o Bruno pediu o dobro.
- **E a obra esvai-se por baixo dela**: o andaime, a ruína e as estacas
  sumiam num quadro e só depois a peça assentava. O aspeto de cada peça é
  lido ANTES da virada (`_aspeto_da_obra()`: o `roster_changed` já trocou a
  textura quando o `obra_concluida` chega), e a que mudou deixa um RASTO —
  uma cópia com a textura velha, no mesmo pai e logo abaixo dela — que se
  apaga em 0,25 s (eram 0,15, e mal se via o andaime sair). **A lança não
  deixa rasto**: duas lanças cruzadas são o «X» que o Bruno recusou na `144`.
- **No pátio, o canteiro e os cones saem em 0,1 s**: a 0,25 o rolo cruzava-se
  com o equipamento novo que assenta no mesmo sítio, e lia-se como duas
  imagens. **E o CHÃO esvai-se**: os últimos 20% do asfalto e o último trecho
  da rua trocavam num quadro. Na véspera de a obra do pátio acabar, o mapa de
  terra e as três camadas da obra (asfalto, rua por recapear e recapeada) são
  lidos com a forma que têm (`_chao_do_patio()`, só nesse dia), e o rasto do
  chão entra acima das camadas do chão e abaixo das marolas, a esvair-se em
  0,25 s. Custa uma cópia do mapa nesse tempo: a textura de terra já está na
  memória (o `Main` faz-lhe `preload`).
- **Que peça, por obra** (`Main.pecas_da_obra()`, `Dock.pecas_da_obra()`):
  - o píer N assenta o `Pier` e a `Lanca` da vaga dele; a treliça, o pórtico
    e o cais, os das vagas construídas (`Dock.OBRAS_DE_TODA_DOCA`);
  - **a lança assenta com o píer, à volta do MESMO chão**: pousa na base que
    o PNG do píer desenha, e cada um no seu chão descolava-a da base — medido
    no mutante, 2,4 px;
  - **a empilhadeira do n3 fica de fora**: é veículo, e o ciclo dela anda-lhe
    a posição;
  - o armazém e o escritório, o nó deles;
  - **o pátio assenta o equipamento que traz, e não o chão**: o asfalto é o
    mapa inteiro, e encolhê-lo seria o porto a respirar (o chão esvai-se,
    acima). A sinalização já estava de pé durante a obra; os postes e as
    placas novos trocam num quadro, como antes — os fios do poste pousam nos
    isoladores (`140`), e a 94% o poste deixava-os no ar.
- **A posição COMPENSA a escala**, em vez de se mexer no `pivot_offset`: a
  lança gira no eixo dela e pode estar a varrer, e uma escala uniforme comuta
  com a rotação (`Main.pose_assentada()`).
- **Só o botão arma o assentar**, como a contagem do dinheiro (`078`): as
  suítes, a bateria e as bancadas concluem obras pela `estado_da_bancada.gd`,
  e uma peça a 94% numa foto ou numa régua seria um estado que o jogo nunca
  mostra parado. **A bateria de capturas fica igual**: ela não conclui obra
  pelo botão sem levar a virada ao fim, e o `_concluir_virada()` acaba também
  o assentar. Medido nas duas árvores: as 110 fotos iguais ao pixel, o tiro
  `virada` incluído (a régua dá 0 no mesmo arquivo e 919.487 píxeis entre
  dois tiros). O premido e o assentar só se veem no vídeo.
- **Com o movimento reduzido (RB6) a peça aparece inteira**, e ligá-lo a meio
  acaba o assentar. É transição de virada, e não ciclo de fundo: o
  `MovimentoDeFundo` diz no cabeçalho que não os recebe, e quem os trata é o
  `_aplicar_movimento()`, como à contagem.
- **O «Avançar dia» afunda 4% enquanto está premido** (`primario_press_barra`
  no tema): o mesmo premido âmbar escuro, desenhado 2% mais estreito de cada
  lado dos 692 × 58 do rodapé, **com o ícone à mesma distância da borda** (a
  margem de conteúdo cresce o que a borda encolhe; sem isso, visto no
  primeiro vídeo, o ícone encostava a 3 px dela) **e o conteúdo 1 px
  abaixo** (11 em cima, 9 em baixo: a soma, e com ela a altura mínima que o
  texto Maior usa, fica nos 20). Volta ao soltar, que é o próprio estado do
  botão, e o dia vira ao soltar, como antes. **Fica com o movimento
  reduzido**: é o estado premido, sem animação nenhuma, como o escurecer que
  já tinha. Com o texto Maior o rodapé cresce, e o encolher vertical fica
  pouco abaixo dos 4% (a margem é em px).
- **E no rodapé o «passar por cima» é o repouso**: no telefone o rato é
  emulado do toque e fica onde o dedo saiu, e o botão ficava âmbar claro
  depois de solto. Vale também no Web com rato, de propósito.
- **O cartão «Ao largo» afunda também** (melhoria escolhida no segundo
  veredito): era o único dos três toques do A1 que não dizia nada ao premir
  — atraca ao soltar. Três variações `*Premido` no tema (doca, à espera,
  rival): **o fundo escurece o passo do botão** (−0,07 de L em OKLab, o do
  âmbar para o premido dele; só a encolher, no cartão escuro, mudava pouco —
  veredito 3), **4% mais estreito** à volta do centro (4,48 px de cada lado)
  e **o conteúdo 1 px abaixo**. **Na altura fica inteiro**: encolhido também
  aí, a última linha pisava a borda (visto na passagem 4). As margens
  laterais de conteúdo ficam, que mudá-las mudava a largura mínima e a fila
  rearrumava-se a meio do toque. O premir não é aceite: com o texto Maior a
  fila vive num rolo, e o arrastar a partir do cartão é o que o faz rolar.

## A guarda, e os defeitos que a provam

O **D53** é novo (`tests/casos_assentar_obra.gd`): abre a cena com a obra a
acabar, prime o botão pelo `push_input` como o jogador, e lê cada nó do mapa
a cada 1/60 s.

1. **só na virada que conclui**: a do porto completo, a de uma obra que
   ainda não acaba e a obra concluída pela bancada não escalam nada;
2. **só na peça que concluiu, em CADA estrutura do catálogo**: todo nó que
   assenta mudou nesta virada (ou é a lança de um píer que assenta); todo
   píer, armazém, escritório e equipamento de pátio que mudou assenta; cada
   estrutura assenta alguma coisa — o esperado sai do que a virada mudou no
   nó, não da lista do jogo;
3. **a curva**: começa a 94%, nunca encolhe, nunca passa de 100%, trava, dura,
   e acaba em 1 exato e no sítio exato;
4. **o chão parado** (0,0000 px) e **a lança presa à base** (0,0000 px);
5. o `_concluir_virada()` a meio põe tudo inteiro já;
6. com o movimento reduzido não assenta, e ligado a meio acaba-o;
7. **o botão**: premido, desenha-se a 0,960 × 0,960 à volta do centro, com o
   ícone a 14 px da borda (como solto) e o conteúdo 1 px abaixo, e o dia
   ainda não virou; solto, inteiro e com a cor do repouso ainda com o rato
   por cima, e o dia virou uma vez;
8. **o rasto**: cada peça que mudou de textura (menos a lança) deixa o rasto
   do que mostrava antes, logo abaixo dela, que começa opaco, só esmaece,
   ainda se vê aos 80% do tempo dele e some nele (0,25 s; o canteiro e os
   cones do pátio, 0,1); o chão do pátio deixa o dele, com o mapa de terra,
   acima do chão e abaixo das marolas; nas viradas do §1, a meio e com o
   movimento reduzido, nenhum;
9. **o cartão «Ao largo»**: premido pelo `push_input`, desenha-se a 0,960 ×
   1,000 com o conteúdo 1 px abaixo, a última linha a 2 px da borda (nos três
   estados, pelo tema) e o fundo a escurecer o passo do botão (−0,070 nos
   dois), e ainda não atracou; solto, inteiro, e atracou.

Trinta e um defeitos no catálogo (`tools/mutantes.toml`, secção da `148`), cada
um apanhado pela pergunta escrita para ele; os que nasceram de um veredito
dizem-no no `o_que`:

| Mutante | Quem reprova |
|---|---|
| O assentar pendurado na virada: tudo o que está construído assenta a cada dia | §1, o porto completo |
| A doca dá o píer a qualquer obra | §2, o armazém faz assentar o píer 1 |
| Sem valor final nem fecho: a peça fica a 94% | §3, acaba inteira e no sítio |
| A curva com recuo (passa de 100%) | §3 |
| O fim que não repõe: o toque a meio deixa-a a 98% | §5 |
| O `_concluir_virada()` esquece o assentar | §5 |
| O pivô no canto do quadro | §4, 10,9 px a 97% |
| A lança à volta do eixo dela | §4, 2,4 px a 97% |
| O movimento reduzido ignorado; ligado a meio, não acaba | §6 (dois) |
| A obra da bancada também assenta | §1 |
| O premido sem as margens; o estilo afundado no normal | §7 (dois) |
| O ícone encosta à borda; o conteúdo não desce; o hover claro | §7 (três, dos vereditos 1 e 2) |
| O aspeto de antes não é lido; o rasto por cima da peça; o rasto que não esvai; o que fica | §8 (quatro) |
| O rasto de 0,15 s; o canteiro no tempo dos outros; o pátio sem rasto | §8 (três, do veredito 2) |
| O chão sem rasto; o chão por cima do cenário | §8 (dois) |
| O cartão sem premido; preso premido; atraca ao premir | §9 (três) |
| O cartão premido com o fundo de sempre; a encolher na altura | §9 (dois, dos vereditos 3 e 4) |
| Uma obra do D53 que rebenta a meio | a bandeira dela, «pier_2 correu até ao fim» |

⚠️ **E A BANDEIRA DE CADA OBRA veio com a `main` do fecho**: o PR #157 deu
bandeira a todo sub-bloco dos arquivos de casos, e os dois ajudantes
aninhados do D53 (`_uma_obra` e `_nada_assenta`) passaram a devolvê-la.
Medido sem ela, o defeito não passava verde — reprovava de raspão, pelos
rastos que a cena deixada aberta largava no §1, longe da causa.

⚠️ **E «a meio do tempo dele ainda se vê» não apanhava o rasto rápido**: o
de 0,15 s, o que o Bruno achou rápido, ainda se via aos 0,125 s de um de
0,25. A pergunta passou a ser aos 80%. O defeito que fica é o que PEDIU a
guarda (`testes-e-guardas.md`).

⚠️ **Sem a reposição no fim, a posição acaba a 0,00001 px do repouso** (a
conta em vírgula flutuante não volta ao número exato), e o «exatos» do §3
apanhou-o: a reposição é precisa, e não é só limpeza.

## O custo

- **Desenho** (`medir_desempenho.gd`, antes → depois, na mesma árvore):
  405,5 → 406,6 e 602,7 → 603,2 chamadas por quadro (os intervalos de 60
  quadros, 402–409 e 403–411, sobrepõem-se), os mesmos **389 nós** e os
  mesmos 99 e 102 tweens. Em repouso não há nada a mais: o assentar e os
  rastos só existem nos 0,3 s depois de uma obra acabar — um tween, até
  quatro rastos (o pátio), e no pátio uma cópia do mapa de terra, cuja
  textura já está na memória.
- **Tema:** quatro estilos novos (o premido do rodapé e os três do cartão).
- **O catálogo**: 31 defeitos a mais. O catálogo inteiro, 273, em 3.609 s
  em quatro cópias, `MUTANTES OK`; as seis suítes em 58 s.

## O veredito, passagem a passagem

| Passagem | Resposta |
|---|---|
| 1 (97%, sem rasto) | «Ajustar», com os quatro defeitos da lista marcados — o assentar quase não se vê, a obra some de uma vez, o botão fica claro ao soltar, o texto não afunda — e *«veja que outras melhorias podem ser feitas também»* |
| 2 (94%, rasto de 0,15 s) | «Ajustar»: o rolo do pátio cruza o equipamento novo, o rasto rápido demais; das quatro melhorias encontradas, **o cartão «Ao largo» afunda** e **o chão do pátio esvai-se** (as outras duas ficam de fora, abaixo) |
| 3 (rasto de 0,25 s, o chão, o cartão) | «Ajustar»: **o cartão premido muda pouco** (dos dois defeitos da lista; o outro, «o chão lê-se como sombra», não) |
| 4 (o cartão escurece o passo do botão) | **«Aceito»** |

## O que fica de fora

- **A háptica (T1) e o casco que rola (A3)**, uma conversa cada, com o
  desenho na `144`; depois a esteira, a fumaça e o fundeadouro, com a ordem
  entre os três a perguntar.
- **As duas melhorias que o Bruno não escolheu**, para quando ele as pedir:
  o «Dia N» do HUD a marcar a virada (hoje o número muda num quadro; um
  brilho de 0,2 s na pílula) e os postes e as placas do último trecho da rua
  a esvaírem-se no fim do pátio (os fios mudam de ponta e saltam na mesma).

## O que se aprendeu

- **O premido desenha-se no ESTILO, não na escala**, quando o botão vive num
  contentor; e quem encolhe a borda tem de mover o conteúdo com ela — o
  ícone encostou, e no cartão a última linha pisou a borda (`interface.md`).
- **A saída que «não mexe» numa guarda mede-se com a suíte, e a suíte pode
  mentir verde**: com o botão num `Control`, o D43 perdeu dez asserções e a
  suíte disse `DESIGN OK` (`testes-e-guardas.md`; tarefa à parte).
- **Num teste que não deixa passar frames, o toque precisa do contentor
  arrumado à mão e da coordenada da cena** (`push_input(…, true)`): sem os
  dois o botão tinha 188 × 50 px e o toque caía fora dele
  (`testes-e-guardas.md`).
- **Tween que compensa a posição não volta ao número exato**: sem a
  reposição no fim, 0,00001 px (`gdscript.md`).
- **No telefone o «passar por cima» fica depois do toque**: o rato emulado
  fica onde o dedo saiu. Só o rodapé o trata; os outros botões continuam com
  o hover deles (`interface.md`).
- **O `--explorar` corre em série, e o bloco num arquivo próprio corre
  sozinho em ~10 s**: aplicar cada defeito e correr só o D53 escolheu as
  guardas, e o executor confirmou-as em paralelo (`testes-e-guardas.md`).
- **E renomear uma asserção deixa o rótulo declarado para trás**: o
  `rasto-nao-esvai` deu FURADO porque «e some em 0,15 s» passou a «e some no
  tempo dele» (`testes-e-guardas.md`).
- **O veredito em quatro passagens, e a pergunta sozinha no bloco a seguir
  ao vídeo voltou nas quatro**, com dois reinícios do worker pelo meio; o
  «procure mais melhorias» do Bruno respondeu-se com uma terceira pergunta,
  as melhorias medidas e com custo, e ele escolheu duas de quatro (`/arte`).
