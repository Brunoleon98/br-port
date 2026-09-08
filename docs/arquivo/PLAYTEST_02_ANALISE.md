# Playtest 2 — a segunda jogada no telefone (06/09/2026)

**A passagem seguinte do A1.** O APK foi jogado depois do pacote de 05–07/09 —
os três níveis de píer, lança e torre, a trava do nível do porto
(`docs/decisoes/009`), o motivo da escala (`008`) e a frota por serviço
(`010`). Esta página é a devolução do Bruno, transcrita, mais a triagem.

O documento original é `Análise 1 - 06/09.pdf`, oito páginas com quatro
capturas anotadas. **O PDF não entrou no repositório** — ele chegou por anexo
de conversa, e anexo não vira arquivo no disco do contêiner. O que segue é o
texto integral, extraído, e a descrição do que cada captura circula.

> **Nada aqui descreve o jogo de hoje.** Isto é o que se viu no dia 06/09 e o
> que se decidiu fazer com isso; o estado atual está em
> `docs/ESTADO_DO_PROJETO.md`.

---

## O que o Bruno escreveu, na íntegra

> Veja a análise abaixo, e adicione isso no projeto, para que essas melhorias e
> ajustes sejam feitos.

**1** — Notei que os caminhões podem ser bem grandes comparados a outras
estruturas, daí poderia dimensionar melhor eles

**2** — Seria legal fazer uma via de mão dupla, com caminhões aparecendo não só
de cima e sumindo embaixo, mas também ao contrário, aparecendo na parte de
baixo e sumindo na parte de cima

**3** — Os caminhões poderiam entrar nas docas, no caso seriam caminhões
relacionados aos serviços.
>
> Daí ao alocar um navio de um determinado serviço, um caminhão relacionado
> pode aparecer na estrada e ir para a doca desse navios. Caso o navio vá
> embora, esse caminhão vai embora também.
>
> Toma cuidado para não gerar um trânsito muito grande de caminhões, e tome
> cuidado para os caminhões não terem bugs

**4** — Notei que as ruas estão sem tantos detalhes, quando for aumentar o
tamanho dela para ter duas faixas, pode colocar mais detalhes como faixas
dividindo a pista, e até faixas de pedestres perto do armário e escritório, por
exemplo.
>
> Abaixo também circulei em vermelho, a falta de conexão das estradas

*A captura da página 2 (dia 1, porto em ruínas) circula a vermelho **três
tocos de acesso** que saem da rua para a vila e acabam no nada — não chegam a
casa nenhuma.*

**5** — Acho que o jogador poderia começar com um valor bem menor do que
400.000, por exemplo. Ou esses 400.000 poderiam fazer parte de um empréstimo,
daí é uma das coisas que está sendo paga nas três parcelas

**6** — O design do guindaste de madeira pode ser melhorado

**7** — Tem poucas variações de barcos, parece que apenas os navios tiveram
atenção para criar uma variedade deles. Logo faça diferentes designs de barcos
para os diferentes serviços que existem.

**8** — Vi que as coisas são bastante quadradas, seja nas construções, como no
mapa e seu desenho. Daí pode usar mais curvas e círculos para deixar o mapa
mais real ao invés de quadrado e cheio de retas

**9** — A areia e a água poderia ter um gradiente de cores melhor, pode seguir
o exemplo do jogo Boom Beach, inclusive tem animações boas de água, assim como
devo adicionar alguns animais no mar, ar e terra para deixar o jogo mais vivo

**10** — Não entendi pq existem os placeholders azul, vermelho, amarelo e
verde. Talvez seja melhor tirá-los, e deixar uma marcação de que algo no futuro
será construído ali, por exemplo, a estação de reabastecimento e a oficina de
consertos. Circulei os placeholders de branco na imagem abaixo.

*A captura da página 4 (dia 9, pátio pavimentado) circula a branco **três dos
seis blocos coloridos** do pátio.*

**11** — As casas longe da rua parecem não ter caminhos para os moradores, daí
pode criar caminhos de terra, varie na criação para não ficarem iguais e serem
apenas linhas retas. Além disso, com o crescimento da cidade alguns desses
caminhos de terra podem virar ruas

**12** — Pode criar modelos de prédio em reforma e construção, assim como
edifícios mais avançados, como casas de dois andares, comércios variados,
pracinha, igreja e etc, para irem aparecendo à medida que o porto cresce e se
expande. Podemos ver indicadores que farão a cidade só redor ir crescendo junto
do porto

**13** — Acho que poderia os edifícios com upgrades podem ter cinco níveis,
sendo que cada nível é liberado a cada fase, logo na fase 5 teria todos os
níveis liberados.
>
> Inclusive cada nível teria seu próprio design e bônus

**14** — O cone no meio da estrada não faz sentido, circulei ele de vermelho na
imagem abaixo

*A captura da página 6 (dia 9) circula a vermelho o **cone de trânsito**,
plantado no meio do asfalto da rua.*

**15** — A área de espera dos navios pode ficar mais afastada do porto, e ao
invés de ter barcos genéricos, pode ter os navios e barcos que realmente podem
atracar nos Piers

**16** — Acho muito cedo para navios atracarem na fase 1 do jogo, daí os barcos
podem ficar nela, e os navios podem vir na próxima fase ou mais na frente.
Talvez uma categoria intermediária possa ser feita, deixando os navios a partir
das fase 4, por exemplo.

**17** — Crie no HUD inferior uma botão de menu, onde nesse menu estarão os
atalhos do mapa da cidade e loja, por exemplo. Inclusive esse menu pode ser um
celular e os aplicativos seriam essas outras partes do jogo. Inclusive quero
implementar o mapa da cidade e a loja na fase 1 do jogo, pode ter também uma
parte com as missões, tendo as missões ativas e as que foram feitas.

**18** — Após criado o menu, o mapa da cidade pode ser criado, sendo que ele
mudará à medida que a cidade expande e novos prédios interativos aparecem nele,
inclusive alguns personagens estariam nesses prédios interativos

**19** — A loja, na verdade terão diferentes lojas, no caso terá a imobiliária
para comprar imóveis da cidade. Terá a concessionária para comprar carros, o
que poderá aumentar o status logo reputação. Terá o Delivery e também o
Mercado, onde poderá comprar alimentos e coisas para diminuir o estresse

**20** — As barras de status e estresse podem ser criadas, junto da barra do
porto. Logo a média das três barras irá gerar a reputação do personagem. Sendo
que essa reputação poderá dar bônus ou penalidades dependendo do nível que ela
estiver. Isso deverá ser bem balanceado devido à complexidade, e cada barra
poderá aparecer em casa um dos atos da fase um, inclusive a barra do porto será
a primeira barra a compor a reputação. As outras duas barras podem aparecer no
menu quando aperta a reputação, mas devem estar com um ? Pois não foram
desbloqueadas

**21** — No menu pode ter um "aplicativo" de análise onde terão informações e
gráficos mais detalhados das finanças, reputação e etc

**22** — Dar mais destaque ao botão alocar todos, pois tem sido melhor para
alocar os funcionários

**23** — Os upgrades poderia afetar um píer de cada vez, ao invés de todos
subirem de nível. Daí em upgrades, poderia organizar melhor as melhorias, até
para que essa divisão de upgrades seja melhor mostrada. Além disso será
necessário rever os preços dos upgrades já que seria muito caro pagar o preço
atual de upgrade para cada píer. Outro desafio é no design, onde podem haver
construções de diversos níveis existindo ao mesmo tempo no mapa

**24** — Quitar a dívida antes pode diminuir o valor a ser pago nela, não
precisa ser um desconto muito grande, mas é legal se tiver um desconto já que
teria menos juros

**25** — Segue abaixo o print com os dados da partida, seria legal conseguir
fechar essa tela, para que eu pudesse ir nas configurações e pegar as
informações completas da partida ao invés de apenas esse print.

*A captura da página 8 mostra o painel "O balanço" com um botão só —
"Jogar de novo".*

---

## A triagem

O que segue é a leitura de cada item contra o código, feita em 07/09. **Quatro
itens foram MEDIDOS**, e é por isso que o que se afirma sobre eles tem número.
Os outros estão dimensionados por leitura, e isso está dito onde é o caso.

### 🐛 Defeitos medidos — pequenos, e nenhum deles tem teste que os pegue

| Item | O que se mediu | Por que nenhuma suíte o pegou |
|---|---|---|
| **14** · o cone na rua | `ConeTransito` está em `mx=7,80`; o asfalto daquele degrau ocupa `6,98..8,52`. Ele está no MEIO da faixa, não na beira | O bloco **D2** tem `PODEM_PISAR_A_RUA := ["Caminhao", "ConeTransito"]` — o cone foi ISENTADO da regra, e a isenção é a origem do defeito. Um cone sinaliza obra; ali não há obra |
| **10** · os blocos coloridos | Seis caixas de 1,15 × 1,5 unidades, 13 px de altura, em `#c23030` / `#2f74b0` / `#e0a81f` / `#2d7a3a`, desenhadas no SVG do pátio (linha ~2186 do `gerar_mapa_iso.py`) e só com `--com-pavimento` | Nenhuma suíte pergunta se um desenho do MAPA tem vocabulário. Eles leem como placeholder porque são: caixa chapada de cor primária, sem canto escuro, sem corrugado, sem sombra — o projeto TEM vocabulário de contêiner (o do convés do píer, o da carreta) e estes não o usam |
| **4b** · acessos que acabam no nada | Os três círculos caem, um a um, sobre os TRÊS COTOVELOS da rua (`my` 8, 16 e 24). Medido no render com cada peça do `vias()` tingida: a rede está LIGADA — o cotovelo encosta na faixa do degrau com 0,00 de folga nas duas pontas. O que acaba no nada é a PONTA DA FAIXA depois da curva: em `my=16` a faixa do degrau 2 (`mx 3,20..4,30`) termina num topo de meio-fio quadrado virado para a vila, e a rua reaparece 4 unidades adiante, no degrau 3 | O **D2** confere que prop nenhum pisa a rua; nada confere que a rua CHEGA a algum sítio — e nenhuma asserção seria capaz de pegar este, porque geometricamente não há buraco nenhum. É defeito de LEITURA: um salto de 4 unidades de uma vez, sem chanfro nem esquina, lê como três ruas que param |
| **1** · escala do camião | A carreta tem 1,96 unidades de comprimento. O ESCRITÓRIO tem 1,99 × 1,70 e a casa da vila 1,35 de profundidade. **Um camião é tão comprido quanto o escritório inteiro** — e mais comprido do que uma casa é larga. A rua tem 1,10 de largura contra os 0,62 do camião: ele ocupa 56% dela | O `asset_validator` mede quadro, alfa e recorte; o **D2** mede pegada contra faixas. Nenhum dos dois compara o tamanho de um prop com o de OUTRO — a escala relativa não tem guarda |

⚠️ **O 4b NÃO É UM BURACO NA REDE, e isso muda qual é o conserto.** A primeira
leitura desta tabela dizia "tocos de acesso que saem da rua para a vila" — e
estava errada. Tingindo separadamente as três peças que o `vias()` desenha
(faixa do degrau, cotovelo, acesso ao berço) e medindo o render pixel a pixel,
a rua sai LIGADA de ponta a ponta: em `my=15,0` o cotovelo começa em `mx=3,4` e
em `my=14,0` a faixa começa em `mx=3,3` — a mesma linha de meio-fio, dentro do
antisserrilhado. Não falta retângulo nenhum.

O que o Bruno circulou é o **lado de fora de cada curva**. A escada salta 4
unidades em `mx` de uma vez, e quem desce a rua vê a faixa acabar num topo
quadrado com meio-fio, de frente para o relvado, enquanto o asfalto continua
quatro unidades ao lado. Três cotovelos, três círculos.

Logo não há asserção a escrever: **um teste de geometria não pega um defeito de
leitura.** As duas saídas são de desenho, e nenhuma é de uma linha — ou a
esquina ganha chanfro para que a curva se leia como curva, ou o lado de fora
dela continua como rua de vila. A segunda é a que responde à queixa dele com as
palavras dele, e é irmã do item **11** (caminhos de terra para as casas): vale
fazer as duas na mesma passagem, como o **4a** vale fazer junto com o **2**.

⚠️ **O item 1 tem duas saídas, e a escolha não é óbvia.** Encolher os camiões é
contido; mas a medida também diz que os PRÉDIOS estão pequenos — um escritório
de porto do tamanho de um camião é o mesmo defeito visto do outro lado. Encolher
o camião conserta a leitura por metade do preço; crescer os prédios mexe em
pegada, em vão da vila e no enquadramento. **É decisão do Bruno**, e está aqui
para ele a tomar com o número na mão.

### 🎨 Arte — entra na fila do plano de arte

| Item | Tamanho | Nota |
|---|---|---|
| **4a** · detalhe da rua (faixa central, passadeiras) | pequeno, **depende do 2** | Faz sentido fazer junto com a via de mão dupla: alargar e detalhar na mesma passagem, senão desenha-se duas vezes |
| ✅ **6** · o guindaste de madeira do n1 | pequeno | É o pau-de-carga do porto em ruínas — o primeiro guindaste que o jogador vê. **FEITO em 08/09**, `docs/decisoes/015` |
| **7** · variedade de BARCOS | médio | O trabalho de 07/09 deu seis cascos aos CARGUEIROS e deixou o pesqueiro com um só, e isso está registado como decisão (`010`). O que ele pede é o outro lado: a classe pesqueiro merece variação própria. É extensão do que já existe, não redesenho |
| **8** · menos quadrado, mais curva | **grande, e é direção de arte** | Toca o gerador do mapa inteiro e o kit de props, que é de caixas por construção. Não é uma sessão |
| **9** · gradiente de água e areia + fauna | médio | A paleta da água já foi medida em 02/09 (a amplitude de luminância, a espuma). Refazê-la exige repetir essa medição, senão achata outra vez. A fauna já tem estúdio (`brp_fauna.py`, a gaivota) |
| **11** · caminhos de terra para as casas | pequeno-médio | Sai do gerador do mapa, ao lado do `vias()` |
| **12** · prédios em obra e avançados | médio | A vila já tem `--nivel-vila=N` e três níveis; isto é acrescentar estados, não construir a máquina |
| **15** · zona de espera afastada + barcos reais | pequeno | Metade já foi feita em 07/09 (o ancorado segue a classe e o motivo). Falta afastar |

### 🖥️ Interface

| Item | Tamanho | Nota |
|---|---|---|
| **25** · fechar o balanço | **pequeno, e é um beco sem saída de verdade** | `EndGame.gd` mostra o balanço com um botão só, "Jogar de novo". O menu de pausa — onde vive o botão que exporta o `.jsonl` da partida — fica inalcançável, e é justamente esse arquivo que responde melhor do que o print |
| **22** · destaque do "Alocar todos" | pequeno | Ele é secundário ao lado do âmbar do "Avançar dia". O tema já tem a variação de destaque |
| **17 · 18 · 19 · 21** · menu-celular, mapa da cidade, lojas, app de análise | **muito grande** | Ver a nota abaixo |

### 💰 Economia — nada disto se mexe sem `/balancear`, e três reabrem decisões

| Item | O que ele toca |
|---|---|
| **5** · caixa inicial menor, ou os 400.000 como empréstimo | `START_CASH = 400000` contra a `PARCELA_AMOUNT = 530000`. Mexe no eixo que o balanceamento de 06/09 mediu em 100% / 80,2% / 37,3%. O empréstimo é a resposta narrativa da queixa nº 1 do playtest 1 ("é estranho o porto ter dívida mas o jogador começar com 400.000") |
| **24** · desconto por quitar antes | Pequeno em código, mas é um botão que move o eixo da dívida. Medir |
| **23** · upgrade por píer | **Grande, e reabre `docs/decisoes/007`**, que decidiu os upgrades como estrutura única. Ele já antecipa as duas consequências certas: rever preços e desenhar níveis diferentes coexistindo no mapa |
| **16** · navios só a partir da fase 4 | **Reabre `docs/decisoes/009`**, de 06/09 — a trava por nível do porto. Não é ajuste: é outra régua |
| **20** · barras de status e estresse | **Reabre `docs/decisoes/005`** (o jogo é tranquilo, a dívida não é o motor) e cria dois eixos novos que entram na reputação. Ele mesmo escreve que "deverá ser bem balanceado devido à complexidade" |
| **13** · cinco níveis por edifício, um por fase | **Grande**, e é regra de progressão das cinco fases — não de arte |

### 🏗️ Sistema — maior que um item de arte

| Item | Tamanho | Nota |
|---|---|---|
| **2** · via de mão dupla | **médio, e é o mais contido dos três** | A rota é uma escada de 12 pontos com sentido único. Duas faixas pedem alargar a rua no gerador (e aí entra o **4a**), uma segunda rota no sentido inverso e uma terceira silhueta por carga — só as faces `+x` e `-y` são visíveis, então um camião que suba não se obtém espelhando o que desce |
| **3** · o camião vai à doca do navio | **médio, e é a continuação natural do que 07/09 construiu** | Hoje o camião leva a carga da doca do mesmo índice mas passa reto. Isto é dar-lhe um destino e um regresso. Os dois cuidados que ele pede — não encher a estrada e não ter bug — são a razão de o número de camiões e a repartição no ciclo serem DERIVADOS hoje, e não escritos à mão |

---

## As três coisas que esta análise pede e que não são "melhorias"

Vale separá-las, porque tratá-las como itens de fila seria construir por cima
de perguntas em aberto.

**1. Os itens 17–21 são um SEGUNDO JOGO.** Menu-celular, mapa da cidade,
imobiliária, concessionária, delivery, mercado, missões, barras de status e
estresse, app de análise. Isso é a camada de vida do personagem que o GDD 7 põe
nas fases seguintes — e ele escreve *"quero implementar o mapa da cidade e a
loja na fase 1"*, o que é mudar o âmbito da Fase 1. **A pergunta que a
`BR_Port_GDD_V7_ERRATA_ECONOMIA.md` deixou em aberto e que o Bruno adiou de
propósito em 03/09 continua sem resposta**, e ela é exatamente sobre a economia
das fases seguintes. Codar lojas e barras de estresse antes de a responder é o
que o `CLAUDE.md` chama de construir em cima de uma pergunta.

**2. Os itens 13, 16, 20 e 23 reabrem decisões registadas** (`005`, `007`,
`009`). Reabrir é legítimo — as decisões existem para poder ser revistas com
argumento —, mas não é a mesma coisa que corrigir um defeito, e não deve
entrar na fila com a mesma etiqueta.

**3. O item 1 é uma pergunta de escala, não um ajuste.** A medida diz que o
camião é do tamanho do escritório; qual dos dois está errado é decisão de arte.

---

## A ordem sugerida, e por quê

Sugestão, não fila: **quem reordena a fila é o Bruno.**

1. **Os quatro defeitos medidos** (14, 10, 4b, 1) — são pequenos, são visíveis
   na primeira captura, e três deles existem porque nenhuma suíte fazia a
   pergunta. Cada um leva também a asserção que faltava.
2. **25 e 22** — interface, pequenos, e o 25 desbloqueia justamente o arquivo
   de partida que ele queria em vez do print.
3. **2 + 4a juntos** — a via de mão dupla e o detalhe da rua na mesma passagem.
4. **3** — o camião que vai à doca, que é a continuação do que 07/09 deixou.
5. **7, 6, 15, 11, 12** — arte, por ordem de custo.
6. **5 e 24 juntos, por `/balancear`** — os dois mexem no eixo da dívida, e
   medi-los na mesma passagem é uma medição em vez de duas.
7. **13, 16, 20, 23** — só depois de ele decidir se reabre as decisões.
8. **17–21** — só depois da pergunta da Fase 2.

E **9 e 8** ficam de fora desta ordem de propósito: o 9 pede refazer uma paleta
que já foi medida uma vez (e achatou a imagem quando se mexeu nela sem medir),
e o 8 é direção de arte sobre o gerador inteiro. Os dois querem uma sessão só
deles.
