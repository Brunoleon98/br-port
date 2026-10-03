# 079 — O pórtico do nível 3 descarrega, e ele leva o pallet de empilhadeira

**03/10/2026 · frente 4 do A5, família animação**: o degrau 3, que a `075`
deixou desenhado (*«3 pallets e empilhadeira»*) e a `076` e a `077` deixaram
por fazer. Até aqui, no nível 3, o pórtico varria parado e o trabalhador
ficava de pé no cais, e a empilhadeira do pátio tinha o tamanho de um camião
(47 px de caixa, contra 37 do camião: a régua da `069` não chegou a ela).
Teve uma vista em GIF, com as três docas do porto completo e a doca 1 a 4×,
e uma comparação do pátio. O veredito foi «Aceito».

## O que o Bruno escolheu

| Pergunta | Resposta |
|---|---|
| A tarefa da sessão | **O degrau 3**, contra a frente 5. Sem recomendação: o briefing mandava perguntar e não escolher |
| Quem faz o quê | **O pórtico tira, ele conduz** (recomendada): o operador do pórtico está na cabine e não se vê; o pórtico pousa a carga num pallet, e o trabalhador alocado leva-o de empilhadeira. Os dois ao mesmo tempo, porque o pórtico corta um turno e ~72% dos serviços do nível 3 duram um |
| Para onde ela leva | **Pilha no cais e camião** (recomendada): a uma pilha na raiz do píer, em laço; com o camião do serviço encostado de ré, às portas de trás dele |
| O contêiner | **Pallets agora, contêiner depois** (recomendada): ele pousa no cais como no n2, e a máquina dele é outra passagem |
| A escala da empilhadeira | **A da pessoa, 1,5x** (recomendada): ele cabe sentado nela, de capacete. A do pátio e o pallet passam a ser os mesmos |
| Onde o pórtico pousa, com prévia em ASCII | **A meio do cais** (recomendada): o carro recolhe ao longo da lança, e a empilhadeira leva o pallet pelo comprimento do píer até à raiz. A outra era pousar na raiz, como no n2, e ela quase não andar |
| O GIF | «Aceito» |

## O que está no jogo

- **O pórtico gira e o carro recolhe** (`portico_n3()` em
  `tools/gerar_props_iso.py`). Gira os mesmos 18° do n2 até ao porão, e daí
  para terra até ~71°, com o carro a vir de 3,30 a ~1,96 da torre: é o que põe
  o pallet a meio do cais, a 0,55 de mundo da torre. A linha do carro a 0°,
  que é o movimento de um pórtico de verdade, caía na PROA de todos os cascos
  (medido antes de desenhar): a torre fica perto da ponta e o porão para terra
  dela. O ciclo é o do n1 e do n2, pelos mesmos nomes do `CICLO_N1`.
- **O spreader não gira com a lança**: fica ao comprido do cais, como vão os
  contêineres no convés. Leva um gancho por baixo para os pallets, que pendem
  em quatro cintas; o contêiner prende-se nas travas.
- **A carga é a do n2 em pallet**: duas colunas por duas das mesmas caixas de
  peixe, de papelão e de sacos, em dois andares (os sacos em três). O
  `CARGA_DO_SERVICO` ganhou a linha do navio de longo curso, que só atraca no
  nível 3 e leva o mesmo que o cargueiro.
- **A empilhadeira e o pallet são peças do kit**, em `gerar_props_iso.py`
  (`empilhadeira_pecas()`, `pallet_pecas()`), com MEDIDAS REAIS — uma de 2,5 t
  e um pallet de 1,2 x 1,0 m — passadas pela régua do mundo com o fator da
  pessoa. São as mesmas no cais e no pátio: o `brp_porto` chama-as, e a do
  pátio fica de garfo para a câmara. Ela tem cobertura escura, contrapeso
  escuro, pirilampo laranja e o encosto do garfo VAZADO: ela leva a carga a
  andar para terra, de costas para a câmara, e uma chapa tapava o pallet.
- **Quem conduz** é o boneco da `075` sentado (`sentado()`): a anca no banco,
  as coxas para a frente, os braços no volante. Quatro quadros — ele e ela,
  com o garfo em baixo e levantado — e um parado, sem ninguém.
- **No cais, a empilhadeira e o pallet são dois nós** (`Empilhadeira` e
  `Garfo`, com o quadro do píer). Quem os anda é o `Dock.gd`, como o andar da
  `075`. O pallet vem antes dela na ordem da cena (está do lado de longe da
  câmara), e é o MESMO nó no chão e no garfo: o spreader larga-o no passo
  «pilha», ele espera no pouso, e ela encosta, apanha-o e leva-o.
- **A pilha da raiz tem três pallets**, e o da frente está no sítio exato onde
  ela larga o dela: o caminho até lá não está escrito, sai do canto de baixo
  dos dois desenhos (`_destino_da_empilhadeira()`), e o que ela traz entra no
  lugar sem saltar. Como no n2, a pilha não cresce.
- **Com o camião encostado** o caminho vai às portas de trás dele, que o
  `Main` lê no camião que parou (`portas_do_camiao()`, da `077`), e o garfo
  não desce: a carga entra pelas portas à altura a que vinha.
- **A velocidade tem teto.** Até à pilha são ~25 px, que ela anda a 20 px/s
  com folga no ciclo do pórtico. Até ao camião são 80 a 88 px: ela acelera
  até 36 px/s, e o que ainda não couber abranda o ciclo inteiro (x1,30 no
  caminho mais comprido). A primeira versão só acelerava, e o D42 mediu-a a
  52 px/s, ~43 km/h na régua.
- **O contêiner** pousa num contêiner no pouso, como o do n2, e ela espera ao
  volante.
- **No nível 3 o nó do trabalhador sai do tabuado**: ele vai na empilhadeira.
  Sem ninguém alocado, ela fica parada à espera, no cais do nível 3.
- **O degrau liga com o pórtico**, como os outros com a lança: com o guindaste
  comprado e o cais ainda por reforçar, ela anda no tabuado do píer 2.

## A medição que mudou o desenho

- **A linha do carro a 0° caía na proa.** Medido no PNG de cada casco, com a
  conta da projeção, antes de desenhar: com a torre em `GX`, a linha cobria o
  costado só da proa para fora — por isso o pórtico gira até ao porão.
- **À espera, a traseira dela encostava na casa de máquinas** do pórtico, com
  o pouso a −0,39 (vista na primeira prancha). O pouso foi para −0,55, e a
  espera de 0,55 para 0,45 de mundo.
- **A régua do D42 mentia com a sombra.** A caixa desenhada do pátio inclui a
  sombra de contacto e o chão projetado, e dava 2,6x a pessoa a uma
  empilhadeira certa. Sem a sombra, a de antes media 30,7 px — a MESMA altura
  do camião da carga geral —, e as de agora 20,7 (cais) e 24,0 (pátio).

## As guardas

O **D42** é novo, e faz seis perguntas:

1. **As tabelas.** Todo par (classe, motivo) que o nível 3 recebe tem tipo;
   todo tipo tem as duas pontas, as nove lingadas e a pilha, e os de pallet o
   garfo em baixo e levantado. Nenhum tipo das tabelas fica sem serviço.
2. **O ciclo, como aritmética**: a carga só pende onde o pórtico está; o
   pallet só espera no chão depois de largado; **ela está à espera sempre
   que o pallet seguinte desce** (senão pousava-lhe no garfo); ela não salta;
   os seis trechos e os dois garfos passam.
3. **No render**:
   - a carga desce dentro dos doze cascos que o nível 3 recebe;
   - o pallet que o spreader larga e o que ela apanha caem no mesmo sítio
     (0,0 px), e o que ela larga é o da frente da pilha (96% em cima dela);
   - o caminho até à pilha anda em `−mx` (0,7°);
   - ela pisa o tabuado à espera, no pouso e na pilha, nos píeres 2 e 3;
   - à espera, não toca o pallet que desce;
   - ele e ela ao volante são figuras distintas, e o garfo sobe;
   - a empilhadeira do cais e a do pátio estão na régua: abaixo de 0,89 do
     camião (a de antes dava 1,00) e acima de 1,2 da pessoa.
4. **Na doca montada**, com uma mulher e um navio de longo curso:
   - o nó do trabalhador sai e ela vai ao volante;
   - os nove passos do pórtico, as nove lingadas e os dois garfos passam
     pelos nós;
   - o pallet no garfo anda com ela, nunca está no spreader e no garfo ao
     mesmo tempo, e não some entre os dois;
   - no nó, ela não salta;
   - um `refresh()` a meio não recomeça, e o segundo turno continua;
   - com contêiner ela espera ao volante;
   - acabado o serviço, fica parada sem ninguém, e no nível 2 sai.
5. **O camião**, pela cena inteira: encostado pelo `Main`, o caminho vai às
   portas de trás, no eixo (pior 2,0° nas seis transportadoras que levam
   pallet), o pallet acaba junto a elas, o garfo não desce lá, e o caminho
   mais comprido cabe sem ela passar do teto, com o ciclo esticado.
6. **Ninguém à frente**: até à pilha e até ao camião, nas três docas, com os
   prédios em ruína e prontos, ela não se pinta por cima de prop do cenário
   que lhe está à frente (0 px).

O **D39** deixou de dizer que no nível 3 ela fica de pé: diz que vai na
empilhadeira, e que o pau do n1 não fica a trabalhar por cima.

Foram injetados **catorze defeitos**, e todos reprovaram:

- a empilhadeira a encostar 0,3 s antes de o spreader largar (três: §2 duas
  vezes, e o pallet no spreader e no garfo ao mesmo tempo, §4);
- **o pallet parado no pouso enquanto ela anda** (§4). Na primeira corrida
  **passou verde**: a guarda isentava o pallet «no pouso», e o defeito cabia
  todo na isenção. A guarda pergunta agora onde ELA está;
- a empilhadeira antes do pallet na ordem da cena (§4);
- o caminho até à pilha medido do canto errado do desenho (§5, sem camião);
- o pallet em baixo trocado pelo levantado (três: §3 duas vezes e §4);
- o garfo a descer nas portas do camião (§5);
- sem o teto da velocidade (duas, §5);
- o ciclo esticado sem o tween a durar mais (§5: um segundo andava um
  segundo de ciclo);
- a empilhadeira visível no nível 2 (§4);
- o nó do trabalhador visível no nível 3 (o D39 e o §4);
- o pallet largado sem o nó que o mostra no chão (§4: 12 passos sem ele);
- a empilhadeira antiga de volta ao pátio (§3: 1,00x o camião);
- a espera a 0,15 do pouso (§3: ela toca 11% do pallet que desce);
- a volta a acabar no pouso e a saltar para a espera (§4: 10,2 px num passo).

O «não salta» do §2 refaz a conta do `Dock.gd`, e por isso não via este
último: é a pergunta do nó que o apanha.

## O custo

O `.pck` cresceu **454.012 bytes contra a `main`, +3,22% do `.pck`**. São 65
PNGs novos no atlas — quinze passos do pórtico, 36 lingadas, quatro pilhas,
seis pallets no garfo e cinco empilhadeiras —, e o `lanca_n3`, a
`empilhadeira` e o `pallet` do pátio foram regerados.

- A folha de props tem 234 peças, em doze páginas.
- A página de escala conta a empilhadeira do cais pela parada: os quadros com
  quem conduz, o pallet no garfo, as pontas e as lingadas são quadros dessa
  animação (`escala_props.gd`).
- Na bateria mudaram as 19 fotos do porto completo, da escala e da folha de
  props; as outras 35 saíram iguais byte a byte às da `main`, as do nível 1 e
  2 incluídas.
- Os 65 quadros foram renderizados com um arnês de sessão que desliga o
  `view_layer.update()` do `bpy.ops` nos `primitive_*_add` (3 min contra mais
  de 30). Os quadros de controlo que a sessão não mudou saíram com 0 pixels
  diferentes dos do repositório.

## O que fica de fora

- **A máquina do contêiner** (uma empilhadeira de contêiner, ou o pórtico a
  pousá-lo no camião): o contêiner pousa no cais, como no n2.
- **A pilha não cresce** com o que ela traz, como a do n2 com a lingada.
- **O camião só leva do pouso**: com ele encostado, ela leva-lhe o pallet que
  o pórtico acabou de largar, e a pilha fica como está.
- **Na bateria, o camião não encosta** nas fotos do nível 3: quem prova a ida
  até ele é o D42 §5.
- **Mais de um trabalhador por píer** (frente 5).
