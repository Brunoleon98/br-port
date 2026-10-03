# 077 — O guindaste do nível 2 descarrega, e ele leva a carga ao camião

**02–03/10/2026 · frente 4 do A5, família animação**: o degrau 2, que a `075`
deixou desenhado (*«no 2 o guindaste tira a carga e ele desengata»*) e a `076`
deixou por fazer, com a ida ao camião nos serviços de mais de um turno. Teve
três vistas em GIF. A primeira, o guindaste a descarregar, foi «Aceito». A
segunda, a ida ao camião, voltou com uma pergunta: *«Na doca 2 o trabalhador
está aparecendo na frente do armazém?»* Estava. A terceira, depois de uma
correção, voltou com um pedido: *«Pode fazer o trabalhador entregar na parte
de trás do caminhão, como se estivesse colocando a carga lá»*. Com o camião a
encostar de ré, foi «Aceito».

## O que o Bruno escolheu

| Pergunta | Resposta |
|---|---|
| A tarefa da sessão | **O degrau 2 da animação** (recomendada), contra o degrau 3, a transição entre turnos e a frente 5 |
| Quem faz o quê | **O guindaste pousa, ele leva** (recomendada): o operador está na cabine e não se vê; a lingada pousa numa pilha no tabuado, e o trabalhador desengata-a |
| Como a carga vai ao camião | **Ao ombro, uma por viagem** (recomendada), contra um carrinho de mão |
| Quando toca cada parte | **1º turno descarrega, depois leva** (recomendada): só anda com o camião no berço, e sem ele espera ao pé da pilha |
| O cargueiro de contêiner (40% dos do nível 2) | **Pousa no tabuado** (recomendada): ele desengata, e não há ida, porque o contêiner sai pelo pátio no nível 3 |
| Como se move o guindaste | **Gira para terra** (recomendada), como o pau do n1, com a lança mais comprida |
| Onde entrega, na primeira versão | Na lateral que se vê (recomendada). Saiu na terceira vista |
| Depois do primeiro GIF | «Aceito» |
| Depois do segundo | *«Na doca 2 o trabalhador está aparecendo na frente do armazém?»* |
| Depois do terceiro, em texto | entregar pelas portas de trás |
| Como fica o camião | **Encosta de ré** (recomendada): portas viradas para o píer, sai de frente. A outra era ele contornar o camião, com metade do caminho atrás do armazém |
| Depois do quarto GIF | «Aceito» |

## O que está no jogo

- **O guindaste do nível 2 descarrega**, no primeiro turno do serviço. A
  lança cresceu 0,15 (`R_PONTA_N2`), e gira como o pau do n1, pelos mesmos
  sete ângulos do `CICLO_N1`. O gancho desce no porão e na pilha, e a altura
  muda com a carga (`FUNDO_BARCO`): em cima das caixas de peixe, da tampa do
  porão ou do contêiner de baixo. A cabine saiu do mastro e gira com a
  lança, sobre uma plataforma laranja.
- **A carga é do serviço**, pelo par (classe, motivo), na mesma chave do casco
  (`CARGA_DO_SERVICO`). O pesqueiro leva peixe, a armazenagem do cargueiro
  leva caixas de papelão, o granel leva sacos de ráfia e o contêiner leva um
  contêiner em quatro cintas.
- **A carga vive numa camada sua**, o nó `Carga`, no quadro do píer. A lança
  tem 15 quadros: 7 ângulos e 8 pontas, duas por tipo. As 36 lingadas, nove
  por tipo, nascem já no sítio do gancho de cada passo. Pôr a carga dentro
  dos quadros da lança daria 36 quadros GRANDES em vez de 36 pequenos.
- **A pilha é por tipo**, no ponto da pilha do peixe do n1. O trabalhador fica
  AO LADO dela, de lado para a câmara (`DESENGATE_N2`, giro de 90°). À frente
  dela tapava 43% a 49% da pilha; ao lado tapa 4% a 14%. Ele tem dois quadros
  por sexo, a esperar e a soltar o gancho. Fica por cima da carga na ordem dos
  nós, e quem o move é o `Dock.gd`.
- **Fase por doca**: com «Alocar todos» os três guindastes giravam como um
  mecanismo só (visto no primeiro GIF). Cada doca começa a um terço do ciclo
  da anterior.
- **A partir do segundo turno o guindaste pára e varre em repouso.** Se o
  camião do serviço está no berço, o trabalhador leva a carga da pilha às
  portas de trás dele, ao ombro, e volta. Sem camião, espera ao pé da pilha.
  São três quadros a andar para cada lado, por sexo, mais a caixa e o saco ao
  ombro esquerdo, no quadro dele (o nó `Trabalhador/Ombro`). Anda no passo da
  `075`.
- **O camião encosta de RÉ**, nas duas rotas: a ida e o retorno entram no
  berço em marcha-atrás e saem de frente. O ponto de entrega não está escrito
  em lado nenhum: o `Main` lê-o no desenho do camião que parou
  (`portas_do_camiao()`, o pixel opaco mais à direita), e avisa a doca ao
  encostar e ao largar (`_avisar_doca()`). A traseira vai de 0,60 a 0,76 da
  âncora, conforme o serviço e a empresa. Um número só, por doca, erraria
  num camião ou noutro.

## O que a segunda vista apanhou

A primeira versão entregava a meio do flanco do camião. Na doca 2 esse
ponto fica no corredor atrás do armazém, e **as docas desenham-se depois do
`Cenario`**: ali o trabalhador saía pintado por cima do prédio. O D40 mediu
**117 px** de figura sobre o armazém na doca 2, e nenhum nas outras duas.
Nenhuma guarda perguntava isto. Toda a maquinaria de profundidade compara
props DENTRO da mesma árvore, e uma figura que anda numa doca atravessa
para a frente de quem está noutra. Hoje o **D40 §6** pergunta-o nas três
docas, com os prédios em ruína e prontos: zero pixels.

## As guardas

O **D40** é novo, e faz seis perguntas:

1. **As tabelas.** Todo par (classe, motivo) que o nível 2 recebe tem tipo.
   Todo tipo tem as duas pontas, as nove lingadas e a pilha. Nenhum tipo das
   tabelas fica sem serviço.
2. **O ciclo, como aritmética**: a carga só pende onde a lança está, ele
   solta o gancho só na pilha, e todo quadro passa.
3. **No render**:
   - a lingada desce dentro dos nove cascos do nível 2 (100% de casco à
     volta, medido no PONTO DE BAIXO dela: no centro, as cintas puxam-no para
     cima, e dava 41% a 53%);
   - pousa em cima da pilha, numa banda por tipo;
   - quem desengata pisa o tabuado e tapa no máximo 25% da pilha.
4. **Na doca montada**, com uma mulher:
   - o guindaste trabalha no primeiro turno;
   - a pilha é a do tipo;
   - ela fica por cima da carga;
   - os 9 quadros da lança e as 9 lingadas passam pelo nó;
   - um `refresh()` a meio não recomeça o ciclo;
   - no segundo turno a lança varre e ela espera;
   - acabado o serviço, sai tudo.
5. **A ida ao camião**, pelo `Main` real:
   - sem camião, ela espera;
   - com ele encostado pelo `_encostou()`, ela anda;
   - o caminho fica no eixo dos quadros com os quatro camiões que levam
     carga ao ombro (pior 12,5°, corte 15°);
   - os pés acabam encostados às portas (9% de camião à volta, 0% sob eles);
   - a carga vai ao ombro só na ida, e o quadro olha para onde ele anda;
   - quando o camião larga, a doca deixa de o ter.
6. **Ninguém à frente**: em nenhum ponto do caminho, em nenhuma das três
   docas, ele se pinta por cima de um prop do cenário que lhe está à frente.

O **D13** passou a exigir a entrada de ré nas duas rotas, e o **D39** a
pergunta do nível ao 3 (no 2 o pau já não varre). O **D17** apanhou a lança
nova sem desenho à volta do pivô (7%): a plataforma do giro está lá por isso.

Foram injetados **dezassete defeitos**, e todos reprovaram:

- um par do nível 2 sem tipo, e um tipo sem serviço (§1);
- quem desengata a soltar no barco (§2);
- as pilhas do papelão e do saco trocadas, e a lingada do porão trocada pela
  da pilha (§3);
- sem o `move_child` que o põe por cima da carga, e o guindaste a ignorar o
  `progress` (§4);
- a carga sempre ao ombro, e os dois sentidos com o quadro de ida (§5);
- as portas no flanco, e as portas sem folga, dentro da carroçaria (§5);
- o `_encostou()` e o `_largar_berco()` sem avisar a doca (§5);
- a ida e o retorno a entrar de frente (D13);
- a doca 2 a entregar no corredor atrás do armazém (§6, com os mesmos 117
  px; nenhuma outra reprovou);
- a doca a refrescar-se inteira a cada manobra do camião (D35, que rebenta no
  `value` dos barcos de ensaio).

**O quadro de ida trocado** reprovou três guardas, e **soltar no barco** só
uma: a aritmética. A doca montada vê os dois quadros dela passarem, e não
pergunta onde.

## O custo

O `.pck` cresceu **404.260 bytes contra a `main`, +2,95% do `.pck`**. São
71 PNGs novos no atlas, e o `pier_n2` e a `lanca_n2` foram regerados.

- A folha de props tem 169 peças, em nove páginas.
- A página de escala conta a lança e as lingadas pelo repouso, e os quadros
  de quem desengata e da ida não contam (`escala_props.gd`).
- A bateria ganhou o tiro `guindaste2`, no dia 2: as três docas do nível 2
  em três fases do ciclo. **E o `docas` passou de 400 para 1000 frames.** A
  400, medido com uma sonda no `_ocupante_do_berco`, NENHUM camião estava
  encostado, e a `main` dava a mesma foto byte a byte: o comentário que
  prometia dois deles estava velho antes desta sessão. A 1000, o retorno
  encosta de ré no berço 1, que é a única foto da manobra.

## O que fica de fora

- **A pilha não diminui** enquanto ele leva, e a lingada não a faz crescer:
  é o mesmo laço do peixe no n1.
- **O contêiner do convés fica no navio.** O barco é uma imagem fixa.
- **Na bateria, a ida ao camião não tem foto.** O camião só encosta com a
  carga do navio, e com a semente da bateria nenhum encostou em 3.000 frames.
  Quem a prova é o D40 §5. O tiro `guindaste2` mostra o primeiro turno, com as
  três docas em fases diferentes do ciclo.
- **O degrau 3** (pallets e empilhadeira, no nível 3) e a **transição entre
  turnos**. **Mais de um trabalhador por píer** é da frente 5.
