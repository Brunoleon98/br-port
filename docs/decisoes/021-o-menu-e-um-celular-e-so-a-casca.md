# 021 — O menu é um celular, e esta sessão construiu só a CASCA

**13/09/2026.** O item **17** do segundo playtest, na letra do Bruno:

> *"Crie no HUD inferior uma botão de menu, onde nesse menu estarão os atalhos
> do mapa da cidade e loja, por exemplo. Inclusive esse menu pode ser um celular
> e os aplicativos seriam essas outras partes do jogo. Inclusive quero
> implementar o mapa da cidade e a loja na fase 1 do jogo, pode ter também uma
> parte com as missões, tendo as missões ativas e as que foram feitas."*

**Nada aqui encosta na economia.** O `GameState.gd` não foi tocado, nenhuma
constante `# TUNING:` mudou, e o balanceamento medido continua 100% / 80,2% /
37,3%. Isso não é cuidado de quem escreveu — é **construção**: a tela é um
overlay e não uma fase, então o `advance_turn()` e o laço do simulador nunca a
veem. Uma fase a mais já fez 24 de 30 partidas não terminarem com o CI verde.

---

## 1. O âmbito foi a primeira decisão, e ela diz NÃO a três quartos do pedido

O plano classifica os itens **17–21 como "um segundo jogo"** — menu-celular,
mapa da cidade, imobiliária, concessionária, delivery, mercado, missões, barras
de status e estresse, app de análise — e diz que eles assentam numa pergunta que
continua sem resposta: a da `BR_Port_GDD_V7_ERRATA_ECONOMIA.md`, sobre a
economia das fases seguintes.

**Construir a loja aqui seria escolher essa economia de passagem.** O que uma
imobiliária vende, a que preço, e o que isso faz à Parcela do Sr. Ribeiro são
exatamente as perguntas que a errata deixou abertas — e a `018` acabou de medir
que o caixa inicial não tem folga nenhuma para mexer.

Então esta sessão entrega **o botão, a tela, e as portas**. As portas que ainda
não abrem ficam visíveis e ditas, que é a outra metade da mesma decisão: um
menu com um botão morto ensina o jogador a não voltar lá.

---

## 2. Celular, e a conta que o decidiu custa 5,4%

A metáfora era sugestão do Bruno e não ordem, e tinha um custo plausível: uma
moldura, uma grelha de apps e um registo visual que o resto do jogo não tem.

**A conta que a aprovou é que a moldura SUBSTITUI a margem do cartão em vez de
se somar a ela.** Medido no tema:

| | largura útil num painel de 400 |
|---|---:|
| cartão padrão (borda 2 + margem 12 de cada lado) | **372 px** |
| celular (corpo: borda 2 + margem 10; tela: margem 12) | **352 px** |

São **20 px de 372 — 5,4%** — e em troca o menu ganha um registo próprio, que é
exatamente a divisão que os itens 18 a 21 fazem: o porto de um lado, a cidade do
outro.

⚠️ **E O QUE FEZ A METÁFORA LER NÃO FOI A MOLDURA — FOI A PROPORÇÃO.** A
primeira versão usava o `montar(largura, 0)` do andaime, que ajusta a altura ao
conteúdo, e saiu **400 × 390**: quase quadrado, e na captura lia-se como mais um
cartão de cantos redondos. Um telefone é ALTO, e a silhueta é o que o olho
reconhece antes de chegar ao primeiro ícone. A **680** (1:1,7) ninguém pergunta
o que é aquilo.

É a única altura fixa deste projeto que não é um defeito, e a diferença está
escrita na constante: a faixa branca que mordeu três painéis era cartão sem
conteúdo; este vazio é a tela de um telefone com lugar para os apps que vêm. A
nota do rodapé é empurrada para o fundo do visor de propósito — com as duas
pontas ancoradas, o vazio fica no meio, que é como um telefone com poucos apps
se parece de verdade.

---

## 3. O espaço no rodapé saiu da linha do CONSTRUIR, e as três saídas foram medidas

Não havia espaço livre: a pilha do rodapé acaba em 1251 numa tela de 1280, e os
29 px que sobram não chegam ao alvo de toque de 44.

| saída | cabia? | o que custava |
|---|---|---|
| terceiro botão no `AcoesTurno` | **sim** — "AVANÇAR DIA" pede 188 px e ficaria com 356 | a hierarquia: aquela linha é o que FECHA o turno, e o âmbar cheio é o único destaque da tela |
| tomar o lugar do `Pausar` | — | o pedido é por um botão no HUD **inferior** |
| partilhar a linha do `Construir` | **sim, com folga** | 54 px de uma linha de 692 |

**Escolheu-se a terceira, e a razão não é só o espaço: é o registo.** A linha do
`AcoesTurno` é o que gasta um dia; a do `Construir` é o que se faz ENTRE turnos,
que é o mesmo registo de abrir um menu.

Medido: o pior texto que o botão mostra é **"Construir · 7 disponíveis"**, que
pede **240 px**. Cedendo 54 ao menu mais 8 de separação, ele fica com **630** —
ainda 2,6 vezes o que precisa.

---

## 4. O que entra no menu: só o que NÃO TEM PORTA

As quatro pílulas do HUD já abrem caixa, calendário, reputação e docas; o cartão
da parcela abre a parcela; o botão Construir abre as estruturas. Repetir
qualquer uma delas seria o defeito que este projeto já registou a propósito do
chip do dia — *"abrir dois painéis para a mesma pergunta é pedir ao jogador para
comparar um com o outro"*.

Dessa peneira sobrou **uma coisa**: o **diário do avô**, que abre uma vez na
abertura, encadeado à tela de nomes, e nunca mais. É texto escrito — com a
origem do caixa inicial lá dentro (`018`) — que o jogador não podia reler.

**E o menu de pausa NÃO é absorvido.** Ele carrega volume, "Copiar registro da
partida" e "Novo jogo (apaga progresso)": coisas de SISTEMA, que existem fora da
ficção. Este celular é um objeto DO MUNDO. Misturar os dois poria um botão
destrutivo ao lado de uma loja, e o `Pausar` já está no canto onde a convenção
do gênero o põe.

**A porta fechada é um QUADRADO APAGADO, e não um botão que não responde.** O
app aceso é um `Button`; os quatro apagados são `PanelContainer`. A diferença
não é decorativa: um botão que não responde ensina a não tocar no menu, e um
quadrado que nunca foi botão não prometeu nada. Uma linha única no rodapé do
visor diz o que falta — **uma** para os quatro, porque a coluna tem 108 px e
repetir a frase dentro de cada tile triplicaria a altura da grelha.

**E o cadeado é um só de propósito.** Desenhar quatro ícones para quatro coisas
que ainda não existem seria escolher a gramática visual delas antes de as
construir; quem distingue os quatro é o NOME, que está sempre lá.

---

## 5. O que a sessão descobriu, e quase tudo custou uma asserção

### 5.1 A folha de ícones cortava em silêncio, e a lição estava escrita na IRMÃ

A folha da frota ganhou em 07/09 uma conta que **reprova ao transbordar**, com o
porquê escrito ao lado: *"uma folha cortada é pior do que nenhuma"*. A folha dos
**ícones** nunca a recebeu.

Medido: a duas colunas ela cabia em **22 ícones** e o 23.º empurrava a última
linha 46 px para fora dos 1280. Os três ícones desta sessão (`menu`, `diario`,
`bloqueado`) fá-la-iam transbordar — e o `capturar_evidencia.sh` não podia
apanhar, porque confere que o PNG tem mais de 20 KB e que a linha "Folha salva
em" apareceu, e uma folha cortada cumpre as duas.

Hoje ela tem a guarda **e** três colunas (a célula mede 189 px de conteúdo, logo
222 chegam), o que leva o teto a 33 ícones.

### 5.2 O contraste, do outro lado do D19

O menu é a primeira tela deste jogo com fundo ESCURO. O D19 tranca a armadilha
de usar a cor neutra do jogo (feita para fundo escuro) sobre o cartão branco;
aqui é o contrário — **a cor de texto PADRÃO do tema é navy**, porque todos os
outros painéis são brancos, e sobre a tela do aparelho ela seria navy sobre
navy. Daí as variações `TextoCelular` e `TextoCelularFraco`, e o **D23** a medir:
o neutro do jogo mede **5,05:1** sobre a tela — passa o AA, e é a primeira vez
neste projeto que ele está no fundo para o qual foi feito. Com a cor padrão,
**1,18:1 em sete rótulos**.

### 5.3 Três armadilhas de MEDIÇÃO, todas apanhadas por defeito injetado

⚠️ **`custom_minimum_size` menor do que o conteúdo é IGNORADO.** O botão de menu
declara 46 e ocupa **54**: o ícone de 26 mais as margens de 14+14 do tema pedem
mais. A asserção media o número declarado e dava 8 px de folga que não existem.
E o defeito injetado — baixar o mínimo para 30 — **não pegou nada**, porque não
mudou o que a guarda mede; quem aperta é o `icon_max_width`.

⚠️ **`size` de um painel acabado de instanciar é o tamanho MÍNIMO, e num `Button`
o mínimo sai do próprio texto.** A primeira versão do D23 perguntava
`pede <= construir.size.x` e passava com 5 px de folga — o esperado e o medido
saíam da mesma fonte. **Alargar o botão de menu não reprovava.** É a armadilha
do espelho, que este projeto já registou no sorteio de motivos, aqui em forma de
pixel. A conta certa deriva-se da linha: largura menos o menu menos a separação.

⚠️ **Numa grelha, um nome comprido alarga UMA coluna e não todas.** O defeito
"um app com nome de loja de verdade" falhou **por 4 px** à primeira, porque com
5 apps em 3 colunas o nome longo caía sozinho na sua. Uma letra a mais e a
guarda reprovou por 3. É a regra de montar o estado em que a guarda APERTA.

### 5.4 E o pior caso de um rótulo sai do que o JOGO escreve

⚠️ O D23 montava à mão `"Construir · %d estruturas"` como pior caso. O jogo
escreve **"Construir · 7 disponíveis"** — a palavra real é mais longa do que a
suposta (240 px contra 235), de modo que a asserção media um caso mais fácil do
que o que o jogador vê. **Quem apanhou foi a captura, não o teste.** Hoje o
pior caso é o `text` do próprio botão, num estado que o bloco monta e prova ser
o de mais estruturas por construir.

### 5.5 Estar na tabela não é chegar à tela

O D23 provava que o menu abre e que os apps se desenham — e **nenhuma asserção
perguntava se o app ACENDE alguma coisa**. O tile do diário podia apontar para
um caminho errado com as quatro perguntas anteriores todas verdes: é a pergunta
do `barco_medio` e a da fala escrita que nada disparava, numa grelha de apps.

⚠️ E o menu tem de SAIR ao abrir o app, senão ficam dois painéis empilhados — e
a pergunta é a da FILA (`is_queued_for_deletion()`), nunca `is_inside_tree()`:
o `queue_free()` marca o nó e só o tira da árvore no fim do frame, de modo que
um painel já condenado responde "estou cá" a quem perguntar assim.

### 5.6 E um número cravado saiu de uma asserção

O `teste_fumaca.gd` exigia `registrados.size() == 20` — reprovou o ícone 21 sem
nada estar errado, que é o vermelho que ensina a subir o número em vez de olhar.
As duas varreduras que já existiam respondem melhor, uma em cada direção: toda
constante tem arquivo, e todo arquivo tem constante.

⚠️ **E a primeira tentativa de conserto foi escrever a segunda delas outra vez,
dez linhas acima de onde ela já estava** — a guarda que outra já implica. Antes
de acrescentar asserção sobre algo que já tem duas, procura-se o estado que a
violaria sem violar as outras; aqui não havia nenhum.

---

## 6. Como se provou

**As cinco suítes verdes** (`TODOS OS TESTES PASSARAM`, `DESIGN OK`, `AUDIO OK`,
`FUMACA OK`, `ASSET OK`) e `DOCS OK`.

**A bateria de capturas correu DUAS vezes e as 14 imagens batem byte a byte** —
a `menu.png` é nova, e ela é tirada com `turn=9` de propósito: a barra de status
diz "Dia N/32 · Semana S", e num `GameState` recém-nascido as duas metades
leriam 1 e 1, que é o único estado em que um erro de conta entre elas não
apareceria.

**Oito defeitos injetados, cada um a reprovar pela guarda que se queria provar**
e com a base a passar entre um e o seguinte:

| defeito | quem reprovou |
|---|---|
| o botão de menu engorda para 500 | D23 — o Construir cabe o pior texto (240 pede, 184 sobram) |
| o `pressed.connect` do menu comentado | D23 — o toque no menu abriu um painel a mais |
| `TextoCelularFraco` volta ao navy de cartão branco | D23 — WCAG (1,18:1 em 7 rótulos) |
| um app com nome de loja de verdade | D23 — a grelha cabe na tela (359 pede, 356 tem) |
| o botão de menu encolhe **de verdade** (`icon_max_width`) | D6 — cabe no dedo (32 × 46) |
| a folha de ícones volta a 1 coluna | a guarda nova (2536 px numa tela de 1280) — **e a sentinela "Folha salva em" não apareceu** |
| o tile do diário aponta para outra cena | D23 — e o que abriu é o PainelDiario |
| o menu não sai ao abrir o app | D23 — e o menu saiu de cena em vez de ficar por baixo |

---

## 7. O que fica em aberto

**Os itens 18 a 21 continuam onde estavam**, e agora têm onde aterrar. Quando
uma porta abrir ela traz o ícone dela — a folha de contato tem lugar para mais
dez —, e a nota do rodapé do visor deixa de a nomear.

**A frase "abrem na Fase 2" é uma promessa**, e está escrita num sítio só
(`RODAPE_FECHADOS`). Se o âmbito da Fase 2 mudar, é ali que se corrige.
