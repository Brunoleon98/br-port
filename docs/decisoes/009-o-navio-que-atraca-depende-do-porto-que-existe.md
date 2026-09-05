# 009 — O navio que atraca depende do porto que existe

**06/09/2026.** Pedido do Bruno, no mesmo dia em que o motivo da escala entrou:

> *"em relação aos barcos e navios o tamanho deles pode ser bloqueado pelo
> nível do píer e guindaste. Pois não faz sentido navios grandes e mais
> lucrativos conseguirem desembarcar em píer e guindastes iniciais"*

Tinha razão, e o defeito era maior do que parecia: o porto abre **em ruínas**,
com um píer de ripas de madeira e um pau-de-carga, e 40% dos barcos que
chegavam eram cargueiros de até R$70.000.

---

## A decisão

**Três classes de navio, travadas pelo NÍVEL DO PORTO.**

| classe | nível | valor | peso | turnos | motivos |
|---|---:|---|---:|---:|---|
| Pesqueiro | 1 | R$12.000–28.000 | 40 | 1 | pescado 55, armazenagem 45 |
| Cargueiro | 2 | R$22.000–50.000 | 40 | 2 | armazenagem 40, contêiner 40, granel 20 |
| Navio de longo curso | 3 | R$56.000–88.000 | 20 | 3 | armazenagem 25, contêiner 45, granel 30 |

**O nível do porto é o MENOR entre o do píer e o do guindaste** — não adianta
ter onde encostar sem ter com que descarregar, nem o contrário.

**E as duas leituras de nível já existiam.** `nivel_pier()` e
`nivel_guindaste()` foram escritas em 05/09 para a ARTE: o píer vai de ripas a
laje de concreto e a lança de pau-de-carga a pórtico, em três estados cada.
Agora elas decidem também quem atraca — e é por isso que a trava **não é estado
invisível**: o jogador vê o píer virar concreto e é exatamente aí que o navio
maior aparece.

**O `CAIS_CHANCE_GRANDE` saiu.** O cais reforçado era *"+60% de chance de navio
grande"*, um efeito estatístico que ninguém consegue ver acontecer. Agora ele é
o que **destrava** a classe de longo curso, e isso lê-se na primeira vez que ela
chega. O guindaste continua a cortar um turno de cada operação.

**Os pesos de motivo mudaram de casa.** Estavam em `MOTIVOS`, como duas colunas
por tamanho de barco (`peso_pequeno`, `peso_grande`); com três classes seriam
três colunas, e a cada classe nova uma coluna a mais numa tabela que não é sobre
navios. Hoje vivem dentro da classe, porque a pergunta que o jogo faz é **"que
carga traz ESTE navio"**.

---

## O que o jogador vê

O painel Construir passou a abrir com a linha do nível:

> Porto nível 1 — recebe pesqueiro
> Ainda não aguenta: cargueiro, navio de longo curso

⚠️ **E ela não promete nada na descrição das estruturas, de propósito.** O
nível 3 tem dono — é o cais, que já exige o pórtico pela cadeia de `requer` —,
mas o **nível 2 não tem**: ele sai de `estruturas.size() >= 2`, duas estruturas
QUAISQUER. Escrever *"e o cargueiro passa a atracar"* na descrição do Píer 2
seria mentira, porque quem comprar o escritório e o pátio chega lá sem tocar
num píer.

---

## O balanceamento, medido

600 partidas por perfil, semente 20260825, em todas as linhas. Os pesos são
`pesqueiro / cargueiro / longo curso`.

| configuração | Ótimo | Mediano | Descuidado | barcos Ó/M/D |
|---|---:|---:|---:|---|
| *antes da trava* | 99,8% | 80,5% | 35,2% | 50,5 / 38,1 / 12,1 |
| trava crua (55/30/15, faixas velhas) | 84,2% | **15,7%** | **3,5%** | 46,5 / 35,0 / 14,4 |
| 40/40/20 | 96,7% | 25,3% | 3,7% | 44,9 / 33,7 / 14,3 |
| 40/40/20 + cargueiro 24–54, longo 56–88 | 99,7% | 68,5% | 7,0% | 45,9 / 35,0 / 14,3 |
| ↑ + parcela 480k | 99,8% | 78,8% | 16,7% | 45,9 / 35,0 / 14,3 |
| ↑ + parcela 440k | 99,8% | 84,3% | 38,0% | 45,9 / 35,0 / 14,3 |
| 40/40/20 + **pesqueiro 11–26** | 100,0% | 83,0% | 29,8% | 46,5 / 35,8 / 13,7 |
| ↑ com pesqueiro 12–28 | 100,0% | 87,0% | 39,8% | 46,5 / 36,1 / 13,7 |
| ↑ com cargueiro 22–50 | 100,0% | 73,5% | 29,8% | 46,1 / 35,3 / 13,7 |
| **pesqueiro 12–28 · cargueiro 22–50 · longo 56–88** | **100,0%** | **80,2%** | **37,3%** | **46,1 / 35,5 / 13,6** |
| ↑ com parcela 540k | 100,0% | 78,8% | 32,0% | 46,1 / 35,5 / 13,6 |
| ↑ com parcela 550k | 100,0% | 77,5% | 27,3% | 46,1 / 35,5 / 13,6 |

**⚠️ A TRAVA CRUA MATA O JOGO, E NÃO É EXAGERO DE CALIBRAÇÃO.** É um problema
de arranque: o porto não consegue comprar aquilo que destrava o dinheiro de que
precisa para comprar. 47% da receita média vinha dos barcos acima de R$20.000;
tirá-los do começo levou o Mediano de 80,5% a 15,7%.

**O que resolveu foi o PESQUEIRO, e não a dívida.** Se o porto em ruínas só
recebe pescado, o pescado tem de dar para viver: subir a faixa dele de
R$8.000–20.000 para R$12.000–28.000 devolveu 8 pontos ao Mediano e 10 ao
Descuidado, e deixou a parcela onde a decisão 008 a tinha posto. Baixá-la para
440k dava um resultado parecido e teria custado a justificação inteira da 008.

**A parcela ficou em R$530.000, intocada.** É a primeira vez desde 05/09 que
uma mudança de mecânica é absorvida sem mexer nela.

**E os botões separaram-se com nitidez**, o que vale para a próxima afinação:
o **cargueiro** move o Mediano (22–50 contra 24–54 vale 13 pontos a ele e zero
ao Descuidado), o **pesqueiro** move o Descuidado (ele quase só vê pesqueiro), e
a **parcela** move o Descuidado sem tocar no Mediano, como a 008 já tinha
medido.

---

## O que MELHOROU, e é o que a decisão 005 pede

**O jogo perfeito voltou a 100%.** A exceção medida em 008 — uma partida em 600
em que o Ótimo levantava as sete estruturas num sorteio mau e chegava curto —
desapareceu: com a trava, o porto que constrói tudo também recebe navio melhor,
e a obra paga-se.

**E a discriminação passou a ser VISÍVEL.** Medido, a mistura de navios que cada
perfil recebe:

| perfil | Pesqueiro | Cargueiro | Longo curso | nível 3 em |
|---|---:|---:|---:|---:|
| Ótimo | 44,6% | 41,1% | 14,3% | 100% das partidas |
| Mediano | 47,2% | 41,6% | 11,2% | 100% |
| Descuidado | 84,2% | 15,8% | **0,0%** | **nenhuma** |

O Descuidado **nunca vê um navio de longo curso**. Não é um multiplicador
escondido numa planilha: é o porto dele.

---

## O que fica pior, e é honesto dizê-lo

**"Barcos atendidos" deixou de ser o bom discriminador.** O vão encolheu de
50,5 × 12,1 para 46,1 × 13,6 — e o Descuidado até atende MAIS barcos do que
antes, porque pesqueiro descarrega em um turno. É verdade e é boa ficção (porto
pobre movimenta muito barquinho), mas quem continuar a ler a discriminação por
ali vai concluir que a trava aproximou os perfis.

**A métrica que ficou é a MARGEM EM REGIME**, e essa manteve-se: R$674.019 do
Ótimo contra R$103.290 do Descuidado — 6,5×, contra os 6,7× de antes da trava.
A decisão 005 diz *"quem separa os jogadores é o porto que conseguem levantar"*;
o número que mede isso passa a ser a margem, não a contagem.

---

## Três coisas que a passagem apanhou, e nenhuma dava erro

**⚠️ O PROJETOR LIA A FAIXA DA FASE 1 NO GDD.** O GDD tem R$8.000–70.000
congelados e as classes passaram a ir de R$12.000 a R$88.000: o portão de
calibração reprovou os TRÊS perfis por ~23% de uma vez. Três fora ao mesmo tempo
nunca é métrica — é o modelo a ler a fonte errada. Hoje a Fase 1 sai do CÓDIGO,
que é a regra do projeto, e a Parcela 1 também (o GDD diz R$550.000 e o jogo
cobra R$530.000). As Fases 2 e 3 continuam a sair do GDD, porque delas o código
não sabe nada.

**⚠️ A FRAÇÃO DE NÍVEL NÃO SE DEDUZ DAS FRAÇÕES DE ESTRUTURA.** O nível 2 é
"duas estruturas quaisquer": somar a fração do armazém com a do pátio não diz em
quantas partidas houve DUAS ao mesmo tempo. A medição passou a exportar
`niveis`, e é dele que o projetor tira quais classes cada perfil chega a
receber.

**⚠️ E `mini` TROCADO POR `maxi` PASSAVA EM TUDO.** Injetado, não reprovou uma
única asserção — porque em quase todo estado do jogo o píer e o guindaste andam
ao mesmo nível. O estado que APERTA é um só: pórtico comprado, cais ainda não
(guindaste 3, píer 2). É a lição que o `CLAUDE.md` já regista sobre guardas
duplicadas, aplicada a um `min` de dois números.
