# 096 — A narradora da Dona Cida sai do `Main`, e a bateria não vê diferença

**11/10/2026.** Main `09f5e4e` (PR #119, o primeiro corte do M8, fundido;
nenhum PR aberto do Codex); 096 livre conferida na main antes de escrever. É o
**segundo dos três PRs do M8** da fila de `docs/REVISAO_GERAL_2026-10-09.md`
(§6) — partir o `Main.gd`, uma extração por PR. Refatoração pura: nada do que
o jogador vê pode mudar, e a prova é a bateria de capturas byte a byte,
calibrada na `095`.

## O que mudou

**`scripts/NarradoraDaCida.gd`** — as falas da Dona Cida em jogo: as sete
ligações aos sinais do `GameState`, os gatilhos (`_cida_negociacao`,
`_cida_contrato`, `_cida_rival`, `_cida_reputacao`, `_cida_caixa`,
`_cida_semana`, `_semana_nova`, `_obra_pronta`), o `_cida` que adia e o
`_cida_agora` que enfileira, as duas constantes e as quatro memórias — a faixa
e o valor da reputação vistos, a travessia do dinheiro curto e a semana já
anunciada. O `Main.gd` foi de 1.373 linhas e 62 funções para 1.163 e 52. O
texto movido, conferido por `diff` contra o original, mudou em duas linhas:

- a ligação da obra pronta era um lambda e passou a método
  (`_on_obra_concluida`) — abaixo;
- o `_cida_agora` emite `falou(id, linha)` antes de enfileirar — abaixo.

**No `Main`:** o `preload`, o membro público `narradora` (montado com a fila,
como a fila), e o `narradora.conectar()` no fim do `_connect_game_state()`,
onde as sete ligações estavam.

**Nos leitores:** o F4 do `teste_fumaca` lê o texto da narradora em vez do do
`Main`; o F8 chama `_semana_nova()` e `_cida_semana()` em
`_f8_main.narradora`; a declaração do F19 ganhou o alvo `Narradora`, o indireto
`_cida` passou para ele e o piso exige-o; a sonda da régua da faixa ouve o
`falou` em vez de sobrescrever o `_cida_agora`. A `narrativa.md` passa a
carregar ao abrir o script novo, e a frase dela que mandava procurar o gatilho
no `Main` diz onde ele está.

## Porquê assim

**Um objeto do `Main`, sem `class_name`, por `preload`** — a forma da `095`,
pelas mesmas razões: a árvore da cena fica igual, e um `class_name` que lê o
`GameState` pelo nome não compila a partir de um `--script`.

**A ordem das ligações é a de antes.** Um sinal chama quem o ouve pela ordem em
que se ligaram, e o `call_deferred` das falas entra na fila adiada por essa
ordem. O `conectar()` corre exactamente onde as sete linhas corriam, depois das
ligações do HUD aos mesmos sinais.

**Método, e não lambda, e é medido.** Uma sonda em 11/10, num projeto à parte:
um lambda ligado a um sinal guarda uma referência forte ao `RefCounted` onde
nasceu — largado o objeto, ele continua vivo e a ouvir; ligado por método,
morre com a última referência e a ligação com ele. Num `Node` o lambda morre
com o nó (medido na mesma sonda), e por isso o `Main` podia usá-lo. Na
narradora, cada `Main` solto — cada volta à tela inicial, cada bloco das
suítes — deixaria uma narradora a ouvir o `GameState` para sempre, a falar para
uma fila que ninguém pinta. Nada na tela o mostraria; o **F8h** pergunta-o.

**O `falou` existe para a régua.** A sonda de `medir_fila_mensagens` herdava o
`Main` e sobrescrevia o `_cida_agora` para registar o id que o jogo escolheu;
herdar o `Main` já não chega à narradora. Um sinal é a forma que a fila já usa
para quem a mede (`apresentou`), e o jogo não o liga a nada.

**`narradora` é público**, pela razão do `trafego`: a régua ouve-lhe o sinal e
o F8 chama-lhe a semana nova, lidos direto, e um nome errado grita. Os
privados dela ficam privados.

## A prova de refatoração pura

ANTES é a main, numa worktree; DEPOIS é a branch. Em sequência — as duas
árvores partilham o `user://ferramentas/`.

- **A bateria:** **66 de 66 fotos iguais ao byte.** O controle positivo — a
  Dona Cida calada no `_cida_agora` do script novo — mudou **17 das 66** (o
  celular das mensagens, o largo, o porto, os boletins…): a bateria vê a
  narradora, e vê-a onde ela vive agora.
- **As seis suítes** verdes dos dois lados, com as mesmas asserções (o
  `teste_design` 1.224, o `teste_fumaca` 975 mais as duas do F8h). As
  diferenças linha a linha: o nome do arquivo que o F4 lê, a contagem do F19,
  e o F10 a 78 contra 79 frames — que a própria branch deu nas duas formas em
  corridas diferentes, logo é ruído do motor (`095`).
- **O simulador**, 600 partidas por perfil, semente 20260825: o JSON igual ao
  byte.
- **A régua da faixa** (que não corre em CI): a mesma saída dos dois lados,
  com 1.024 falas da Dona Cida contadas.
- **O F19 de pé:** com a declaração velha, reprovou uma vez e pelo motivo
  certo — «o Main não tem o método» `_cida`, o nome que mudou de dono. Com a
  nova, os mesmos 49 nomes: 15 do `Main` e 1 da `Narradora`.

## Os mutantes

O original guardado por `cp` e conferido por `cmp` depois de cada um; a suíte
verde exigida entre todos.

| # | Defeito | Reprova |
|---|---|---|
| X1 | o gatilho do `bom_contrato` apagado no script novo | F4: «mudas: bom_contrato», e só ele |
| X2 | a obra pronta ligada outra vez por lambda | F8h: a narradora continua viva, e só ele |
| X3 | o `Main` sem o `narradora.conectar()` | F8a, F8e e as duas pontas do F8g |
| X4 | a sonda velha, a que sobrescrevia o `_cida_agora` | a régua: código 1, sem marcador (0 ações) |
| X5 | a sonda nova sem a ligação ao `falou` | a régua: código 1, sem marcador (Dona Cida 0) |

O X3 diz também o que o F8 não depende da ligação: o F8c, o F8c2 e o F8f
chamam a semana nova à mão, e passam sem ela.

## A régua que fechava com zero

Antes da guarda nova, o X4 fez a régua imprimir `=== FILA MEDIDA ===` com
**zero ações e zero falas**, código 0 — a sonda velha não compila, porque o
`super(id)` pede ao `Main` um `_cida_agora` que ele já não tem. E o X5 é a
forma calada do mesmo defeito: compila, corre 2.753 ações e conta o sistema
(538), e a Dona Cida sai a zero. Numa corrida saudável as duas fontes escrevem
centenas de vezes, e zero não é medida: a régua passou a recusar o marcador
com uma fonte a zero. É a lição do valor impossível (`gerais.md`), e a de quem
SOBRESCREVE um nome que muda de dono ficou em `testes-e-guardas.md`.

## O PR que falta

**A fila de painéis** (`_na_vez`, `_dar_a_vez_ao_proximo`, `_passar_a_vez`,
que a `087` alargou e a `interface.md` cita no `Main`). A prova é a mesma: a
bateria contra o hash do commit anterior, com um controle positivo no script
novo — e procurar, além de quem lê os nomes, quem os sobrescreve.
