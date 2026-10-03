# 078 — A virada do dia na tela: o barco parte, o dinheiro conta, o ganho sobe

**03/10/2026 · frente 4 do A5, família animação**: a outra metade do item 4,
*«uma transição suave entre turnos»* (plano v3, §7). O pedido nunca disse o
que devia ficar suave, e a sessão começou por perguntar. Até aqui, tocar em
«Avançar dia» virava tudo de um quadro para o outro: o barco servido sumia, o
seguinte aparecia no lugar e os números saltavam. Teve duas vistas em GIF, nos
portos de pesca e completo. A primeira voltou «Ajustar», com quatro defeitos
marcados; a segunda, com os quatro feitos, foi «Aceito».

## O que o Bruno escolheu

| Pergunta | Resposta |
|---|---|
| A tarefa da sessão | **A transição entre turnos**, contra o degrau 3 e a frente 5. Sem recomendação: o briefing mandava perguntar e não escolher |
| O que a tela mostra quando o dia vira | **O barco servido parte** e **o dinheiro conta** (as duas recomendadas), contra um véu de fim de tarde sobre o mapa (o porto opera 24 horas) e um cartão «Dia 5» no meio da tela (32 vezes por partida) |
| O ritmo | **Um toque a meio termina a virada já** e vira o dia seguinte (recomendada), contra o botão esperar ~1 s a cada turno |
| De onde sobe o «+R$» | **Sobre o barco** (recomendada), contra sair do cartão da doca. É a exceção registada à regra «nada de interface pousa sobre o mapa» (abaixo) |
| Depois do primeiro GIF | «Ajustar»: *barco parece fantasma*, *partida/chegada rápidas*, *«+R$» no lugar errado*, *caixa conta rápido demais* — as quatro |
| Onde o «+R$» fica | **No casco, subindo pouco** (recomendada), contra acompanhar o barco para o largo e nascer acima da grua |
| Depois do segundo GIF | «Aceito» |

## O que está no jogo

- **O `GameState` continua a virar o dia de uma vez.** A transição é a TELA a
  alcançar o estado novo, e nada do que ela faz volta ao jogo: o balanceamento
  e o simulador ficam intocados por construção, e o `GameState.gd` não mudou
  uma linha.
- **O barco servido parte, e só então entra o seguinte** (`Dock.gd`,
  `_mostrar_barco`). A troca é uma fila num tween só: o casco sai pela faixa
  do berço, ao longo do píer, para o largo (`RUMO_DO_MAR`, `(90, 45)` na tela),
  e o novo entra de ré pelo mesmo lado. Sai de proa porque atraca do lado de
  baixo do píer com a proa para o mar. São 0,8 s cada (`PARTIDA_SEG`,
  `CHEGADA_SEG`), e o casco fica OPACO a não ser na ponta de fora: os últimos
  30% da partida e os primeiros 30% da chegada (`ESMAECER`). O barco perdido
  para o rival sai da mesma maneira.
- **A primeira vista não anima**: o porto que se abre (partida nova, save
  carregado) mostra os barcos onde estão. E **quem aloca a meio da chegada
  encosta o barco já**: o guindaste descarrega do porão no berço, e com o
  casco a deslizar a carga sairia da água ao lado dele.
- **O dinheiro conta** do valor antigo ao novo em 1,2 s (`CONTAGEM_SEG`), o
  mesmo tempo do «+R$» no ar, e o cartão da parcela conta junto: os dois leem
  o valor MOSTRADO (`_caixa_mostrado`). **Só o botão arma a contagem**: comprar,
  pagar a parcela ou uma suíte que escreve `GS.cash` continuam a saltar para o
  valor certo, e por isso nenhuma asserção que lê o HUD logo depois de uma
  ação mudou.
- **O «+R$» sobe do barco servido**, um por doca que pagou, no verde do
  dinheiro do HUD com contorno navy (`GanhoNoMapa` no tema). O valor sai do
  `receita_da_doca()`, o mesmo `_lancar_receita()` que põe o dinheiro no
  caixa, lido ANTES da virada; quem pagou lê-se no RESULTADO, o barco que tinha
  trabalhador e já não está lá, em vez de repetir a regra do `progress`. Nasce
  12 px acima do centro do quadro do barco (o centro cai no fundo do casco) e
  sobe 20 px; vive na camada `MapaWrap/Ganhos`, depois das docas, porque ordem
  de nó só é profundidade entre irmãos.
- **Um toque a meio acaba a virada** (`_concluir_virada()`): o dinheiro no
  valor certo, cada barco no berço e nenhum «+R$» no ar, e só depois vira o
  dia seguinte.

## A exceção à regra do mapa

O `CLAUDE.md` diz «nada de interface pousa sobre o mapa». A regra nasceu de
nomes e chips PERMANENTES que tapavam a arte (`HISTORICO.md`, item 4 do
bloco 4). O «+R$» dura 1,2 s, não recebe toque (`mouse_filter = 2`) e é a
consequência visível do barco que sai: o Bruno escolheu-o sobre o barco, com a
exceção dita na pergunta. A regra continua de pé para tudo o que fica.

## O que a medição achou antes de mexer

- **A chegada deslizante estava escrita e nunca corria.** O `Dock.gd` tinha,
  desde o início, o barco novo a entrar do lado da zona de espera — e uma
  sonda que vira 24 dias pelo botão contou **21 barcos novos e zero
  chegadas**. A virada esvazia a doca (`turn_advanced`) antes de a encher
  (`boats_spawned`), o esvaziar zerava o id, e a chegada só deslizava quando
  havia um barco ANTERIOR. Com a fila nova, a mesma sonda deu 21 de 21.
- **E o rumo dela atravessava o píer.** A chegada antiga usava `(90, -45)`, e a
  primeira foto da partida mostrou o casco a passar por cima do tabuado — o
  `Barco` desenha-se depois do `Pier`. Ninguém o tinha visto porque aquele
  código nunca correu.
- **A primeira pergunta ao Bruno descreveu errado o estado de hoje** (*«o novo
  entra deslizando»*), lido no comentário e não medido. A legenda do primeiro
  GIF corrigiu-o.

## As guardas

O **D41** é novo, e faz seis perguntas na cena inteira, andando os tweens com
`custom_step()` e lendo o nó:

1. **O rumo** do barco é a direção do píer para o mar, contra a PROJEÇÃO
   publicada (`+mx` na tela), e não contra a constante.
2. **A fila**: o barco velho chega ao mar antes de o novo aparecer, o novo
   aparece no mar e não no berço, o velho só se afasta e o novo só se
   aproxima, e o velho não volta.
3. **Opaco a maior parte do caminho**: medido 0,70 da partida, corte 0,40; o
   primeiro GIF dava ~0,1.
4. **A soma dos «+R$»** é a receita que o `GameState` lançou no dia e o que o
   caixa ganhou, com o bónus do armazém no meio para o valor bruto não passar.
5. **A primeira vista não anima**, com barcos sem trabalhador.
6. **O toque seguinte acaba a virada** (os «+R$» saem, o dinheiro fica no
   valor prometido, cada barco encosta antes de sair), e **só o botão arma a
   contagem**.

O `capturar_tela.gd` leva a última virada ao fim antes da foto, a menos que o
tiro peça `virada`, e reprova pelas duas pontas: o tiro `virada` sem a virada
na foto, e um tiro de estado com ela. Concluída, a foto do `porto` saiu com o
**mesmo md5** da `main`: a virada acabada é byte a byte o estado de antes.

Foram injetados **oito defeitos**:

- o rumo antigo, `(90, -45)` (§1, e só ela);
- o barco a esmaecer o caminho todo, como no primeiro GIF (§3: 0,09);
- a primeira vista a animar (§5) — e este **passou verde na primeira
  corrida**: o D41 abria a cena com os trabalhadores já alocados, e quem
  aloca a meio da chegada encosta o barco. Era essa guarda que segurava a
  asserção. Com os barcos sem trabalhador ao abrir, reprova nas três docas;
- o toque sem o `_concluir_virada()` (§6, em três asserções: os «+R$» que
  sobram, o dinheiro a meio e os barcos a meio da chegada);
- toda mudança de dinheiro a contar (§6, e o D12, que lê o cartão da parcela
  logo depois de escrever `GS.cash`);
- o «+R$» com o valor bruto, sem bónus (§4: 87.559 contra 131.339);
- a chegada a saltar a partida (§2 e §3). Esta pedia uma asserção que não
  havia — «o velho chega ao mar antes de o novo aparecer» —, porque sem
  partida a fração opaca ficava no valor por omissão;
- o cartão da parcela a ler o jogo em vez do valor mostrado (§2 do dinheiro:
  71 passos em que os dois números discordam).

E o D41 apanhou-se a si mesmo uma vez: um erro de execução num sub-bloco
(uma chave que o registo do dia não tem) abortou-o, e a suíte disse
`DESIGN OK` com o bloco «corrido até ao fim». Cada sub-bloco ganhou a sua
bandeira, que é a regra do `CLAUDE.md` a morder outra vez.

## O custo

O `.pck` cresceu **3.424 bytes contra a `main`, +0,024% do `.pck`**: não há
arte nova, só código, uma variação de tema e um nó vazio na cena.

- A bateria ganhou o tiro `virada`, no dia 6 do porto de pesca, 36 frames
  depois do toque. **As outras 53 fotos saíram iguais byte a byte** às da
  `main`, com a virada concluída antes de cada uma.
- As seis suítes passam, e o simulador não foi corrido: o `GameState` não
  mudou.

## O que fica de fora

- **O som da virada.** O plano de áudio da Fase 2 lista «transição de turno»,
  e o encanamento já toca o navio quando os barcos chegam; som novo é do A6.
- **O resto do HUD não conta**: o dia, a reputação e as docas mudam de uma
  vez. O pedido escolhido foi o dinheiro.
- **O camião não espera a virada**: vai e vem pelo trânsito dele, como antes.
- **Com a oferta do Arlindo**, o painel abre por cima da virada, que continua
  por trás do escurecer.
- **O degrau 3** (pallets e empilhadeira) e **mais de um trabalhador por
  píer** (frente 5).
