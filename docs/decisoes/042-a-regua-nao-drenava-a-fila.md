# 042 — A régua não drenava a fila, e por isso o âmbar da faixa nunca foi medido

**22/09/2026 · a segunda leva das cores declaradas em
`tools/excecoes_cor_ui.json` · opção (c) do briefing de 21/09f, escolhida pelo
Bruno**

## O que saiu

A **faixa de mensagem inteira**: o stylebox creme, a barra âmbar dele e os
quatro ramos do `_pintar()`. **6 das 17 chamadas, 3 das 11 entradas.**

| | antes | depois |
|---|---:|---:|
| cores de tema pintadas à mão | 17 em 11 locais | **11 em 8** |
| exceções declaradas | 11 | **8** |
| estados do percurso do D33 | 20 / 237 textos | **22 / 283** |

Cinco variações novas: `FaixaMensagem` (o stylebox) e `TextoFaixa`,
`TextoFaixaBom`, `TextoFaixaAviso`, `TextoFaixaRuim`.

## ⚠️ Mas esta leva NÃO foi uma migração de valores, e a `041` fazia falta

A `041` provou que nada mudara. Aqui **uma cor mudou**, e a razão é que a leva
encontrou um defeito.

O registro de exceções afirmava, na entrada que agora saiu, que *"o contraste
dos quatro já é medido pelo D33"*. O briefing da conversa repetia-o. **Não
era.** O `_message_label` dava **três linhas em 237**, e as três eram
`12.13:1` — o mesmo estado NEUTRO, três vezes. Os outros três nunca foram
medidos.

Com o percurso a alcançá-los, o que estava por baixo:

| estado | cor | sobre o creme | corte |
|---|---|---:|---|
| `good` | verde | 5,19:1 | passa |
| `bad` | vermelho | 5,38:1 | passa |
| neutro | navy | 12,13:1 | passa |
| **`warn`** | **âmbar de marca** | **3,07:1** | **REPROVA (4,5)** |

E `warn` é o `kind` **mais emitido do jogo** — 6 dos 14.

O conserto não foi escolhido aqui: é o **mesmo âmbar escurecido** que o R6
criou em `035` para este problema exato no cartão branco, e que o comentário
do `Main.gd` já descrevia ao lado. Mede **4,87:1** no creme (5,06:1 no
branco). Os outros três migraram com o valor intacto.

⚠️ **E A BARRA ÂMBAR DE 4px NÃO MUDOU.** Ela é MASSA e não texto, fora do
portão de contraste — é *"quem resolve não é a cor, é a MASSA"* com um rótulo
no lugar do prop. A cor de marca continua a apontar a faixa; o que escureceu
foi o texto.

## ⚠️ O achado: FALA DISPARADA NÃO É FALA VISTA, agora na régua do CONTRASTE

A `033` registou isto para a faixa de mensagem: o que o `GameState` emite não
é o que o jogador lê. **A régua do contraste caiu no mesmo buraco**, e a razão
é dupla:

1. O `acao` do percurso corre **ANTES de a cena existir**, logo o `message`
   que ele provoca sai para ninguém.
2. E mesmo emitido depois, o texto entra numa **FILA com tempo mínimo**. O que
   fica no rótulo é a mensagem de ABERTURA, que é neutra.

Medido: o estado "HUD (nada parado)" da `041` tinha uma mensagem BOA presa na
fila com `pendentes() == 1`, e a régua publicava a neutra de trás dela. A
linha estava na tabela, com razão e veredito, e descrevia outro estado.

O percurso ganhou `acao_vista`: métodos corridos sobre a cena **já montada**,
cada um seguido de drenar a fila.

⚠️ **E DRENAR SÓ NO FIM NÃO CHEGA — a fila ordena por PRIORIDADE.** Medido:
com um dreno único no fim, o caso do aviso publicava o VERDE da ação anterior,
porque `bad > warn > good` põe o aviso à frente na fila e o verde sai por
último. Duas ações seguidas entregam na tela a de menor prioridade, e não a
última. O dreno é **depois de cada ação**, que é também a ordem em que o
jogador as veria.

## As portas são do jogador, e há três

Nenhum estado se escreveu à mão — é a regra da `038`, e a `041` já a cumprira
com `assign_all_free_workers`.

| estado | porta | o que a faixa diz |
|---|---|---|
| `good` | "Alocar todos" | "1 trabalhador alocado. Avance o dia para operar." |
| `warn` | tocar numa doca que já opera | "Essa doca já tem trabalhador operando." |
| `bad` | o botão do painel do Sr. Ribeiro sem caixa | "Caixa insuficiente para pagar a parcela." |

## A prova, por dois caminhos

1. **Os 20 estados antigos saíram com 237 linhas, e só TRÊS mudaram.** Duas
   mudaram **só a coluna ORIGEM** (`override` → `TextoFaixa`), com razão,
   corte, px e texto idênticos. A terceira mudou de conteúdo, e é a correção:
   "HUD (nada parado)" passou de `12.13:1` neutro para `5.19:1` bom — a linha
   que descrevia a mensagem errada.

2. **As 24 fotos da bateria**, com a bateria calibrada primeiro por duas
   corridas da MESMA árvore.

⚠️ **E AQUI A SEGUNDA PROVA TEM O SINAL TROCADO EM RELAÇÃO À `041`.** Lá o
critério era a identidade byte a byte, porque nenhum valor mudava. Aqui um
valor MUDA, logo a foto que mostrar uma mensagem de aviso TEM de mudar — e
nenhuma outra. "Zero diferenças" seria a régua a não saber medir.

## ⚠️ O segundo achado: o portão do escopo não vê nome de variação em dicionário

O `_pintar()` ia ficar com um `const VARIACAO_DA_FAIXA := {...}` e um
`.get(kind, "TextoFaixa")` — mais arrumado do que quatro ramos.

Só que o `conferir_escopo_ui.py` procura
`theme_type_variation\s*=\s*&?"([^"]*)"`, e num dicionário o nome não está
depois do `=`. As quatro variações ficariam **invisíveis ao portão que existe
para as conferir**, e um erro de digitação cairia no `Label` base sem uma
palavra — que é exatamente a armadilha escrita no cabeçalho do portão.

Os quatro ramos voltaram a ser literais `&"..."`, como o
`_refresh_titulo_trabalhadores()` da `041`. **A forma do código escolheu-se
pelo que a régua ALCANÇA**, que é a mesma regra por que a `041` escolheu a
leva.

## Os mutantes

Cada um sozinho, com os originais guardados por `cp` (nunca `git`, que não sabe
o que ainda não foi commitado), controle positivo antes e depois de cada um, e
o código de saída lido **sem cano**.

| # | Defeito | Resultado |
|---|---|---|
| X0 | base limpa (controle positivo) | verde nas três réguas |
| X1 | `TextoFaixaAviso` volta ao âmbar de MARCA | **D33 reprova**, código 1; escopo VERDE, e com razão — não é cor à mão |
| **X1b** | **o MESMO, com o percurso VELHO de 20** | **passa**: `nenhum texto abaixo do AA em 237 medidos` |
| X2 | `acao_vista` com método que o `GameState` não tem | reprova nomeando o método E o estado |
| X3 | `acao_vista` numa cena SEM fila (um painel) | reprova: *"não tem fila de mensagem para drenar"* |
| **X3b** | **o MESMO, com a guarda da fila RETIRADA** | **passa**: `PASS … em 276 medidos` — sete textos a menos, e verde |
| X4 | o stylebox `faixa_msg` do tema pintado de navy | **6 reprovas em DUAS guardas**: as cinco linhas da faixa no D33 (1,00 / 1,00 / 2,33 / 2,49 / 2,25) e o contador no D32 |
| X5 | variação com o nome trocado no `Main.tscn` | **só o escopo** reprova, pelo NOME; o D33 não, porque o fallback do `Label` base é o MESMO navy |
| **X6** | **o nome por `StringName("TextoFaixaAvizo")`** | **NADA o apanha** — D33 verde em 283, escopo verde |

⚠️ **O X1b E O X3b SÃO O QUE PROVA A SESSÃO.** Sozinhos, o X1 e o X3 só mostram
que alguma régua reprova alguma coisa. O par diz que o percurso novo e a guarda
da fila fazem falta: **o mesmo arquivo passa por tudo o que havia antes.** É a
forma do X1b/X3b da `041` e do X1b/X2b da `040`.

⚠️ **E O X6 É A JUSTIFICAÇÃO DOS QUATRO LITERAIS, medida em vez de afirmada.**
Ele é a forma de código que eu ia escrever, com um erro de digitação dentro: o
rótulo cai no `Label` base, que sobre o creme mede 12,13:1 e PASSA, e a regex
do portão não vê o nome. Duas réguas verdes sobre uma variação que não existe.

⚠️ **E NO X5 É PRECISO DIZER QUAL SEGURARIA SOZINHA:** só o escopo. O D33 não
pode apanhá-lo porque a variação que falta cai no `Label` base, cuja cor é
exactamente a mesma do `TextoFaixa` — a razão não se mexe um centésimo.

## ⚠️ O terceiro achado: as 24 fotos nunca veem a faixa COLORIDA

A `041` fechou com as 24 fotos byte a byte. Aqui **um valor mudou**, e eu
previ que a foto com uma mensagem de aviso mudaria. **Mudaram zero.**

Isso não se aceita como verde: a calibração prova que a bateria não tem ruído
PRÓPRIO, não que ela veria ESTA mudança. O controle positivo responde —
pintar o `TextoFaixa` (o NEUTRO) de vermelho mexeu **12 das 24 fotos**.

| medição | fotos mexidas |
|---|---:|
| duas corridas da MESMA árvore (calibração) | 0 de 24 |
| o **neutro** pintado de vermelho (controle) | **12** de 24 |
| o **âmbar** mudado a sério (a entrega) | **0** de 24 |

Logo a bateria VÊ a faixa, em metade das fotos — e **as doze mostram-na sempre
no estado NEUTRO**. O defeito morava exactamente onde nenhuma foto olha, que é
a irmã de *"arte presa a um estado do jogo não é sorteio — é pior"*.

É também o que torna as duas provas complementares em vez de redundantes: a
tabela do D33 é a única que vê os estados coloridos, e as fotos são as únicas
que veem os doze estados de jogo que o percurso não monta.

## O que fica de fora, dito

- **As três levas restantes não se tocaram** — cartão da doca (5 entradas / 8
  chamadas), verde do `UpgradePanel` (2/2) e borda do `Worker.gd` (1/1). O
  `UpgradePanel` continua a pedir **percurso primeiro, cor depois**, e agora
  há um mecanismo a mais para lho dar: `acao_vista` alcança estado que resulta
  de uma regra, não só de um campo.
- **A barra âmbar de 4px da faixa não mudou de cor**, e isso é escolha: é
  massa e não texto. Quem olhar a faixa continua a ver o âmbar de marca.
- **Nada aqui diz que a faixa ficou mais bonita.** O texto de aviso ESCURECEU,
  e isso vê-se. O que se pode provar é que passou de 3,07:1 para 4,87:1 num
  corte de 4,5 — e que nenhuma das 24 fotos o mostra, logo o gate A5 não o
  cobre. **Fica para o olho do Bruno**, com a `035` como precedente.
