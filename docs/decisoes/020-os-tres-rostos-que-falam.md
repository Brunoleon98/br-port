# 020 — Os três rostos que falam, e a cara sai da FALA

**13/09/2026.** O fecho da parte que se podia fechar do item novo do A4 — o
🎭 **retrato do personagem com REAÇÃO**, pedido pelo Bruno na primeira leitura
em voz alta: *"seria legal aparecer o sprite dos personagens, poderia ser o
sprite com a reação do personagem mais a mensagem"*.

**Nada aqui encosta na economia.** O `GameState.gd` não foi tocado, nenhuma
constante `# TUNING:` mudou, e a decisão pendente da semana de sete turnos fica
exatamente onde estava. O simulador corre sem travamento e as doze capturas de
antes e depois são idênticas byte a byte **menos uma** — o boletim, que é onde
a cara nova aparece. Essa foto é a medida da contenção da mudança.

**E também não encosta no que a sessão da água e da fauna está a mexer**: o
`gerar_mapa_iso.py`, o `brp_fauna.py`, o `Audio.gd`, o `gerar_sons.py` e o
`Main.tscn` ficaram fechados de propósito, e a §5 diz o que isso custou ao
item.

---

## 1. O item tinha três partes, e duas fecharam inteiras

O plano descreve-o assim: **(a)** retratos dos três no estúdio partilhado, cada
um com um punhado de expressões; **(b)** uma tabela que ligue cada fala à
expressão que ela pede — *"e ela tem de percorrer as falas, senão volta o
buraco das duas linhas mudas"*; **(c)** a faixa de mensagem passa a cartão com
retrato.

O (a) e o (b) estão feitos. O (c) está feito **nos três painéis onde alguém
fala** — o Boletim Financeiro, a cena da parcela e a contra-oferta — e **não**
na faixa de mensagem do rodapé, que é a parte que o próprio plano manda medir
antes (§5).

---

## 2. É BUSTO, e o `trabalhador_retrato` continua de corpo inteiro

Os dois cartões pedem coisas diferentes, e a diferença mede-se.

O retrato do trabalhador identifica uma **unidade**: o que o distingue é o
capacete e o colete, que são silhueta, e silhueta sobrevive a qualquer
tamanho. Estes três carregam uma **expressão**, e expressão vive em meia dúzia
de pixels de cara.

Medido no primeiro render, de corpo inteiro: **84px de rosto num PNG de 406**,
o que a 96px no cartão dá **16px de cara e 2 de olho** — a essa escala as nove
imagens deste bloco seriam a mesma imagem. Cortado no peito, com a cabeça a
valer 61% da altura, a cara fica com **44px e o olho com 5**, e a diferença
entre uma boca reta e uma boca descontente passa a ser de 2px, que se veem.

**Três armadilhas de projeção, todas medidas no PNG e nenhuma óbvia:**

1. **A profundidade projeta-se para CIMA.** A primeira cabeça tinha 96 de fundo
   e o cabelo 104, e o que saiu foi um capote de cabelo a comer o quadro com a
   cara lá em baixo. Cortar o fundo nesta câmera não achata nada — tira
   TELHADO, que era o que roubava o espaço da cara.
2. **O ombro tem de ser MUITO mais largo do que a cabeça.** A 178 contra 150
   (dezoito por cento) saiu uma cabeça pousada num caixote, sem pescoço à vista
   e sem nada que se lesse como ombro. Hoje são 300 contra 140.
3. **Duas peças à mesma altura no mundo não estão à mesma altura na imagem se
   estiverem a fundos diferentes.** A gola nasceu como placa na face do peito e
   saiu a FLUTUAR dez pixels abaixo do pescoço, com um buraco de blusa pelo
   meio: a placa vive em `y = -fundo/2` e o pescoço em `y = 0`, e cada unidade
   de profundidade vale meia de altura na tela. Hoje é uma caixa à volta do
   pescoço, que partilha o fundo dele e encosta.

**O enquadramento é medido, não escolhido:** `_K = 1.68` e `_MEIO = 285.0` em
`brp_porto.py` saem de renderizar e medir a caixa opaca do PNG, e põem o busto
a ocupar de 446 a 480 dos 512 px do quadro, conforme o chapéu de cada um. É a armadilha que o retrato do trabalhador
já tinha pago: um `TextureRect` em `KEEP_ASPECT_CENTERED` escala o quadro
INTEIRO, transparência incluída.

---

## 3. Nove imagens, três alavancas — e o contraste medido contra o papel

Cada expressão é uma combinação de **boca**, **sobrancelha** e **olho**, e não
um desenho novo. A esta escala é o que existe: nariz não cabe (o trabalhador
também não tem) e ruga é ruído.

| | Dona Cida | Arlindo | Sr. Ribeiro |
|---|---|---|---|
| padrão | `seria` | `sorriso` | `cordial` |
| e mais | `preocupada`, `contente` | `pressao`, `contrariado` | `formal`, `grave` |

A escolha sai do TOM que o guia de voz descreve, e não do assunto: a Dona Cida
é *"pragmática, brava, leal"*, e por isso a cara padrão dela é séria e não
sorridente; o Arlindo *"sempre sorrindo quando ataca"*, e por isso o que muda
quando a negociação aperta é o sorriso SAIR; o Sr. Ribeiro *"quando bravo fica
MAIS educado"*, e por isso a cara grave dele é a cordial com a boca em baixo.

**O contraste mede-se contra o FUNDO, e o fundo aqui é papel.** O balão de fala
tem 245,4 de luminância (amostrado da captura) e o cartão tem 255. Medida a
luminância média dos pixels opacos de cada PNG:

| | luminância | Weber contra o balão |
|---|---:|---:|
| Dona Cida | 82,1 | **0,67** |
| Sr. Ribeiro | 111,2 | **0,55** |
| Arlindo | 117,7 | **0,52** |

Todos muito acima do 0,26 que este projeto trata como "separa" e longe do 0,12
que some. **E foi por isto que o boné do Arlindo é navy e não branco**: um boné
de capitão de verdade é branco, e `cabine` (#eef2f5) mede **0,016** contra o
balão — sobre o cartão claro deste jogo não seria um boné, seria um buraco com
contorno.

⚠️ **A APARÊNCIA DOS TRÊS É DECISÃO DESTA PASSAGEM, e não do GDD.** As fichas
(`gdd/sistemas/npcs.md`) e o guia de voz dão tom, maneirismo e papel; não há
uma linha sobre a aparência de nenhum deles. Ficou escrito de maneira a poder
ser mudado barato: o que distingue cada um são três ou quatro peças nomeadas e
uma cor de pele que sai da paleta — trocar qualquer delas é **uma linha e um
render de três segundos**. O gate é o A5, e é o Bruno que olha.

---

## 4. A tabela percorre as FALAS, e é isso que a torna testável

A tentação é listar as três expressões de cada um e deixar o painel escolher —
e aí uma fala nova nasce sem cara, cai no `null`, e o balão fica sem retrato
sem nada a apontá-lo. Com a tabela do lado das falas (`Narrativa.EXPRESSOES`),
o bloco **F7** do teste de fumaça pode fazer quatro perguntas, **cada uma
contra uma fonte diferente**:

1. toda fala tem cara — `EXPRESSOES` contra as tabelas de TEXTO;
2. toda cara tem arquivo — `EXPRESSOES` contra o DISCO;
3. **toda cara desenhada é usada** — `Retratos.gd` contra `EXPRESSOES`;
4. toda fala chega ao jogo — as tabelas contra os PAINÉIS.

A 3 é a pergunta do `barco_medio` do lado da arte: nove PNG renderizados,
validados pelo `asset_validator` e sem ninguém a pedi-los seria exactamente o
defeito que este projeto já apanhou três vezes.

**Cinco defeitos injetados, e um deles apanhou uma asserção fraca minha.** A
guarda comportamental usava `is_inside_tree()` para dizer que o painel não
fechou — e `queue_free()` só tira o nó da árvore no fim do frame, de modo que
um painel já condenado ainda responde "estou cá". Ela passou com o defeito
posto, e só a asserção do texto ao lado reprovava; a pergunta que distingue é a
da FILA (`is_queued_for_deletion()`). É a lição do `CLAUDE.md` sobre saber qual
guarda está a segurar a asserção, apanhada em flagrante.

### E encontrou-se um defeito de verdade a caminho

`ARLINDO_VENCEU` e `ARLINDO_PERDEU` estavam escritas desde 01/09 e **nenhuma
linha do jogo as disparava**: a negociação resolvia-se e o painel fechava
calado, ganhasse quem ganhasse. É a **quarta** vez que este projeto apanha a
mesma coisa (o `barco_medio`, as duas falas da Dona Cida em 12/09, e agora
estas), e o bloco F4 não podia apanhar porque varre `CIDA_LINHAS` e mais nada.

Hoje a contra-oferta tem **segundo tempo**, como a cena da parcela: resolvida a
negociação, a tela fica com a despedida dele e um botão de fechar. Não mexe em
dinheiro nenhum — o `negotiate_rival()` já resolveu tudo antes —, e por isso
não toca no que o simulador mede, que nunca abre cena. E as duas falas ganharam
a cara que pediam: `contrariado` para quem perdeu, `sorriso` para quem levou o
cliente.

---

## 5. O que NÃO entrou: a faixa de mensagem, e o número que o diz

O plano avisa que a alínea (c) *"esbarra numa regra deste arquivo: nada de
interface pousa sobre o mapa"*, e manda medir onde o cartão cabe **antes** de o
escrever. Medido, nos offsets do `Main.tscn`:

- a faixa de mensagem **não pousa sobre o mapa** — ela vive no RODAPÉ, entre os
  trabalhadores (acaba em 984) e o cartão da meta (começa em 1054);
- ela tem **52px de altura** (994 a 1046), o que dá para um retrato de ~44px
  sem crescer nada — e a 44px a expressão deixa de se ler, pela conta da §2;
- o rodapé inteiro acaba em **1251 de 1280**: são **29px de folga**, e pôr lá
  um retrato de 76px gastaria 24 deles.

Ou seja: a faixa cabe um retrato pequeno de graça, ou um retrato legível ao
preço de quase toda a folga do rodapé — **e o rodapé cheio é uma decisão em
aberto do Bruno desde o primeiro playtest** (*"o rodapé tem sete faixas e 29px
de folga, e um botão de 44px não cabe"*). Não é uma escolha para se fazer de
passagem.

Some-se a isso que o `Main.tscn` está a ser editado em paralelo na sessão da
água e da fauna, e que a metade de Cida que vive na faixa são as **oito linhas
de loop** dela — que continuam a tocar, sem cara, exactamente como antes.

**O que falta, então, é uma linha de decisão e um nó**: escolher entre os 44px
de graça e os 76px que custam 24 da folga, e pôr um `TextureRect` dentro do
`MensagemCartao`. A tabela de expressões já cobre as oito linhas de loop, e o
F7 já as tranca.
