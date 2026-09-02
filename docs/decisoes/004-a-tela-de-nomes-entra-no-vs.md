# 004 — A tela de nomes entra no VS, e as telas narrativas passam a sete

**Data:** 01/09/2026 · **Decisão de:** Bruno · **Estado:** fechada

> O item A4 do Plano v3 lista **seis** telas narrativas. Esta decisão acrescenta
> uma sétima, e ela é a primeira que o jogador vê.

---

## O problema

Todo o texto do VS foi escrito no Bloco 1, em
`docs/design/BR_Port_Frontload_Escrita_VS.md`, com dois tokens:

- `{portName}` — o nome do cais
- `{playerName}` — o nome do protagonista

O GDD 7 diz de onde eles vêm: *"Na primeira tela do jogo, o jogador define dois
nomes: o seu (exibido em diálogos e documentos) e o nome do Cais — que substitui
'Cais Mirim' em toda a interface"*, e acrescenta que **a decisão é irrevogável**.

Só que essa tela **não está entre as seis do A4**. Ao codar as telas narrativas
a pergunta ficou sem resposta possível: sem ela, o Sr. Ribeiro abre a cena da
parcela com *"Boa tarde, {playerName}"* e não há nome nenhum para pôr ali.

Havia duas saídas, e nenhuma era de código:

1. Fixar os nomes — "Cais Mirim" e um protagonista sem nome — e reescrever as
   falas que usam vocativo.
2. Abrir a sétima tela, fora do que o A4 lista.

## A decisão

**A sétima tela.** O jogador batiza o cais e diz o próprio nome, na abertura,
antes de qualquer outra coisa.

## Por quê

O nome do porto não é enfeite: ele aparece no diário do avô, nas falas do
Arlindo, na cena da parcela e na narração de fim de fase. Fixá-lo esvaziaria o
que o GDD chama de *"o nome do seu legado"* — e, o que é pior, esvaziaria em
silêncio, porque o jogo continuaria a funcionar.

## O que ficou decidido junto, e não estava perguntado

**O nome do jogador é opcional; o do cais não.** "Cais Mirim" é o padrão que o
GDD dá quando o campo fica em branco. Para o nome do jogador **não há padrão, e
é de propósito**: inventar um é pôr palavra na boca de quem não a escolheu.
Quem deixa em branco fica sem vocativo, e toda fala que o usaria tem variante —
a vírgula viaja com o nome, senão sai *"Boa tarde ,."*. O Toninho já trata por
"chefia" e o Arlindo por "sobrinho", então ninguém fica sem forma de tratamento.

**Porto Mirim é a CIDADE; Cais Mirim é o nome-padrão do PORTO.** São coisas
diferentes e o rascunho de escrita usa as duas — o banco do Sr. Ribeiro é de
Porto Mirim e não muda. Esta linha existe porque a confusão aconteceu de facto
ao ler os documentos, e trocar um pelo outro é o tipo de erro que só se vê a ler
em voz alta.

## A consequência técnica que quase foi um bug

A tela é **overlay, não fase do `GameState`** — e essa não é uma escolha de
estilo.

Uma fase nova que bloqueasse o turno seria errada de um jeito que **nada
reportaria**: o `advance_turn()` retorna calado fora de `"playing"`, e o laço do
`simular_balanceamento.gd` só sabe resolver `rival_offer` e `debt_payment`.
Medido, injetando exatamente essa fase: **24 de 30 partidas não terminam** — e o
CI passava na mesma, porque só procurava a linha `=== Leitura ===`.

O CI passou a reprovar `possível travamento`, mas a regra vale antes do CI:
como overlay, o balanceamento medido fica intocado **por construção**, e não por
cuidado de quem escreve. Está no `CLAUDE.md`, na seção de Interface.

## O custo

`SAVE_VERSION` sobe: os dois nomes entram no save. Save de outra versão é
descartado, não adaptado — a partida recomeça, com a tela de nomes outra vez.
O bloco F3 do `teste_fumaca.gd`, escrito no mesmo dia, tranca isso.

## O que continua em aberto

O gate humano do A4 — **ler o texto em voz alta** — continua por fazer, e é dele
que dependem os três desvios do rascunho de escrita registrados no plano.
