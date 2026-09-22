# 044 — O percurso primeiro, e a contagem que teve de ser exata

**22/09/2026 · a quarta leva das cores declaradas em
`tools/excecoes_cor_ui.json` · continuação pedida na mesma conversa da `043`**

## O que saiu

O **verde do `UpgradePanel`**: o título da linha e o "Construída" ao lado do
ícone, os dois pintados quando `tem_estrutura()` é verdadeiro. **2 das 3
chamadas, 2 das 3 entradas.**

| | antes | depois |
|---|---:|---:|
| cores de tema pintadas à mão | 3 em 3 locais | **1 em 1** |
| exceções declaradas | 3 | **1** |
| estados do percurso do D33 | 23 / 305 textos | **24 / 330** |

Uma variação nova: `TextoEstruturaFeita`, só cor — os dois rótulos medem 15 e
12 px e continuam a declará-lo na cena, que esta migração não mexe em leiaute.

**A cor mede 5,39:1** sobre o cartão branco, contra um corte de 4,5. Passa.

## A ordem que o registro mandava, cumprida

A entrada que saiu dizia: *"o percurso abre o painel com o porto em RUÍNAS,
logo nenhuma estrutura está construída e esta cor nunca entra nos textos
medidos. Migrar uma cor que o portão de contraste não alcança seria trocar uma
dívida visível por uma invisível: primeiro o percurso ganha o estado, depois a
cor vai para o tema."*

Era afirmação NEGATIVA, do tipo que a régua confirma ao não publicar a linha —
e conferiu-se **contando**, que é a regra que a `042` deixou escrita: **25
linhas no painel Construir, e ZERO por `override`.**

Daí a prova do outro lado ser mais forte do que nas levas anteriores: os 23
estados antigos saíram com **298 linhas e NENHUMA mudou** — nem sequer a coluna
ORIGEM, porque aquela cor nunca tinha chegado a ser publicada. A 3ª leva mudou
50 origens; esta mudou zero, e é o mesmo resultado dito de outra maneira.

## ⚠️ O achado: o `acao_vista` não serve a um painel

O briefing previa que o `acao_vista` da `042` destravasse este verde —
*"`comprar_estrutura` é um método, exactamente o que este mecanismo destrava"*.
**Não serve.** Ele traz uma guarda própria:

```gdscript
if not ("_fila" in no):
    falhas.append("cena de %s não tem fila de mensagem para drenar" % ...)
```

Um painel não tem fila — é literalmente o mutante **X3 da `042`** a disparar,
e essa guarda está certa: drenar o que não existe seria o dreno a não drenar
nada.

E o que este estado pedia era o CONTRÁRIO do da faixa de mensagem. Ali a ação
tinha de correr **depois** da cena, porque o texto vive numa fila com tempo
mínimo; aqui tem de correr **antes**, porque o painel Construir lê o
`GameState` enquanto se monta. **Duas coisas que parecem o mesmo mecanismo —
"agir para alcançar o estado" — e que caem em lados opostos do frame.**

Daí a chave `estruturas`, ao lado do `barco`: compra pela porta do jogador
(`comprar_estrutura`) antes de a cena existir.

⚠️ **E o `acao`, que é a chave que corre antes da cena, NÃO É USADA POR CASO
NENHUM** — medido, zero ocorrências. A `042` moveu tudo para o `acao_vista`. É
maquinaria viva que nada exercita; fica registada e não mexida, porque tirá-la
é decisão de outro dia.

## ⚠️ E COMPRA RECUSADA É CALADA — mas a regra não é geral

`comprar_estrutura()` devolve `false` sem se queixar: sem caixa, sem o
`requer`, ou em `rival_offer`. Num caso cujo propósito é ter a estrutura de pé,
isso é falha, e a chave reprova.

**A tentação era fazer disso regra geral** — toda ação do percurso que devolva
`false` é falha. Medido antes de escrever: o caso do aviso da faixa chama
`["assign_worker", 1, 0]` **para ser recusado**, porque é a recusa que emite a
mensagem que ele mede. Uma guarda cega teria reprovado o que está certo, e o
X0 da `042` tê-la-ia apanhado — mas só depois de escrita. **Antes de promover
uma verificação a regra geral, procure a chamada que depende do contrário.**

## ⚠️ O segundo achado: o piso passava, e a contagem teve de ser EXATA

A guarda nova é a irmã do `_barco_chegou` da `043`, escrita ao mesmo tempo de
propósito: um caso que pede um estado e não o obtém publica linhas plausíveis.
Ela conta quantos rótulos do painel vestem a variação de «feito».

A primeira versão pedia `>= pedidas.size()`, para não se prender ao desenho do
cartão — e o comentário ao lado dizia isso com todas as letras. **O mutante Y3
passou por ela.** Tirar a variação de UM dos dois rótulos deixa 2 marcas para
2 estruturas, o piso cumpre-se, e o rótulo órfão cai no `Label` base, que sobre
o cartão branco mede **12,58:1** e passa o contraste com folga. Nada no projeto
o via.

É a condição que a regra do **«não se aperta o teto até apanhar um SEGUNDO
DEFEITO»** nomeia, e desta vez ela foi cumprida em vez de invocada: o Y2 foi o
primeiro defeito, o Y3 o segundo, e apertar não reprova nada de legítimo —
duas estruturas de pé dão sempre quatro rótulos, deterministicamente.

O preço está escrito ao lado: **quem acrescentar um terceiro rótulo verde por
linha reprova aqui e tem de subir o número de propósito.** É o que se quer; a
alternativa — a guarda contar o que o painel produz — é o espelho.

## A prova, por dois caminhos

1. **Os 23 estados antigos, 298 linhas, ZERO mudadas.**

2. **As 24 fotos da bateria: 0 mexeram.** E o controle positivo responde pela
   terceira vez de maneira diferente das anteriores: pintar o verde de
   vermelho mexeu **1 de 24** — a `construir.png`, que é tirada numa partida
   JOGADA e por isso tem estrutura de pé.

| leva | fotos mexidas pela entrega | pelo controle positivo |
|---|---:|---:|
| 2ª (`042`, faixa) | 0 | 12 — e nenhuma mostra o estado mudado |
| 3ª (`043`, cartão) | 0 | 13 |
| **4ª (esta, verde)** | **0** | **1** |

Três respostas diferentes à mesma pergunta, e nenhuma se adivinhava: **o
número de fotos que veem uma cor não se deduz do tamanho da peça.**

## Os mutantes

Cada um sozinho, originais por `cp`, controle positivo entre cada um, código
de saída lido sem cano.

| # | Defeito | Resultado |
|---|---|---|
| X0 | base limpa | verde nas dez |
| Y1 | caixa a 1.000: a compra é recusada calada | **reprova**, nomeando a estrutura: *"não conseguiu comprar a estrutura pier_2"* |
| Y2 | a compra passa e NENHUM dos dois rótulos veste a variação | **reprova**: *"comprou 2 estruturas: esperava 4 rótulos verdes e achou 0"* |
| **Y2b** | **o MESMO, com o estado novo fora do percurso** | **passa**, `DESIGN OK` — o estado faz falta |
| Y3 | **UM** dos dois rótulos perde a variação | com o piso `>=`: **passa nas duas réguas**. Com a contagem EXATA: **reprova** |
| Y4 | `TextoEstruturaFeita` fora do tema | **só o escopo** reprova; o D33 não, porque o `Label` base sobre branco mede 12,58:1 e a contagem continua a bater |

⚠️ **O Y2b E O Y4 DIZEM QUAL RÉGUA SEGURA O QUÊ, e elas não se cobrem.** O
escopo apanha a variação que NÃO EXISTE no tema, lendo texto; a contagem
apanha a variação que não foi POSTA no nó, lendo o nó montado. É o inverso do
X3 da `043`, onde só o D33 segurava — e a soma das duas é a razão de haver duas.

## O que fica de fora, dito

- **Resta UMA entrada**: a borda do `Worker.gd` (1 chamada). É BORDA e não
  texto, fora do portão de contraste, e a prova dela não pode ser de contraste
  — **isso é decisão por tomar, e não se tomou aqui.**
- **As duas formas dinâmicas da `043`** continuam registadas e não corrigidas.
- **O `acao` do percurso continua sem um único caso a usá-lo.**
- **Nada aqui mudou um pixel do jogo.** O painel Construir está exactamente
  como estava; o que mudou foi de onde a cor dele vem, e que a régua passou a
  alcançá-la.
