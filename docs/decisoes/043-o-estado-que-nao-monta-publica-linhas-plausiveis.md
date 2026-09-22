# 043 — O estado que não monta publica linhas plausíveis, e foi uma chave morta

**22/09/2026 · a terceira leva das cores declaradas em
`tools/excecoes_cor_ui.json` · opção (c) do briefing de 22/09, escolhida pelo
Bruno**

## O que saiu

O **cartão da doca inteiro**: os quatro rótulos da cena mais os quatro ramos
do `refresh()`. **8 das 11 chamadas, 5 das 8 entradas.**

| | antes | depois |
|---|---:|---:|
| cores de tema pintadas à mão | 11 em 8 locais | **3 em 3** |
| exceções declaradas | 8 | **3** |
| estados do percurso do D33 | 22 / 283 textos | **23 / 305** |

Cinco variações novas: `TextoDocaNome`, `TextoDocaValor`,
`TextoDocaProgresso`, `TextoDocaProgressoRival` e `TextoDocaTrabalhador`.

**E foi migração de VALORES, como a `041`.** As 277 linhas dos 22 estados
antigos saíram com razão, corte, px e texto **idênticos**; 50 delas mudaram
só a coluna ORIGEM, de `override` para o nome da variação. Zero mudaram
conteúdo.

## ⚠️ O que o briefing dizia, e o que a medição disse

O briefing chamava esta leva de *"a maior, e a mais difícil"*, por dois
motivos. Nenhum dos dois se sustentou, e conferi-los custou dez minutos.

**1. «alfa 0,96 sobre o MAPA — composição que NÃO FECHA, logo a resposta
honesta são duas.»** Já estava construído. O `fundo_de()` devolve as duas
pontas desde a `035`, e o comentário dele nomeia este cartão — *"O cartão da
doca pulsa por aqui"*. Contadas as linhas, quatro das cinco entradas já
publicavam medição em todo estado de HUD.

**2. «o estado âmbar não é medido: o percurso não monta doca sob oferta.»**
Verdadeiro — e é a afirmação NEGATIVA, que a régua confirma ao não publicar a
linha, logo era de confiar (é a regra que a `042` deixou escrita). O que ela
não dizia é POR QUE não era, e é aí que estava o defeito.

## O defeito: uma chave que ninguém lê

O `montar_caso` montava a oferta do rival assim:

```gdscript
GS.docks[d]["rival_offer"] = true
```

**`docks[d]["rival_offer"]` não existe no jogo.** Procurado no projeto
inteiro, aquela linha era o único sítio que a escrevia e não havia nenhum que
a lesse. O `Dictionary` do Godot cria a chave em silêncio — é o
`destino[chave] += x` do `CLAUDE.md` com o sinal trocado, e não dá erro nenhum.

O jogo escreve outra coisa, em `_spawn_boats()`:
`docks[idx]["boat"]["rival"] = true`, mais o `pending_rival_dock` e a fase. E
o cartão lê `boat["rival"]`.

O caso da **contra-oferta** nunca deu por isso, porque é um painel solto cujo
`setup()` lê o barco. Quem pagou foi o CARTÃO, que nunca chegou ao estado
vermelho — e com ele os outros três rótulos, que sobre aquele fundo medem
diferente do que a tabela publicava.

Com os campos do jogo copiados de onde o jogo os escreve, o quarto fundo entra:

| papel | `CartaoDoca` | `CartaoDocaEspera` | `CartaoDocaObra` | **`CartaoDocaRival`** |
|---|---:|---:|---:|---:|
| Nome | 6,76 | 5,98 | 7,39 | **6,96** |
| Valor | 13,71 | 12,13 | 15,00 | **14,13** |
| Progresso | 8,52 | 7,54 | 9,32 | **8,68** (âmbar) |
| Trabalhador | 8,42 | 7,45 | vazio | vazio |

Todos passam. O pior é o nome a 5,98:1 contra um corte de 4,5 — logo UM tom
serve os quatro fundos, que é o que o código já fazia. **O que faltava não era
cor: era a régua chegar lá.**

## ⚠️ O achado: ESTADO QUE NÃO MONTA PUBLICA LINHAS PLAUSÍVEIS

A `042` registou que *fala disparada não é fala vista*. Esta é a irmã, um
andar acima: **um caso do percurso que pede um estado e não o obtém não se
queixa** — ele monta, mede, e publica linhas verdadeiras sobre o estado
errado.

Aconteceu duas vezes no mesmo dia, e a primeira foi comigo. Ao investigar o
custo desta leva, pus uma sonda com `barco: 0` no HUD para ver se o âmbar era
alcançável. **A sonda não pegou** — o progresso saiu no mesmo 7,54:1 calmo — e
nada disse uma palavra. Foi por ter a régua "o defeito injetado pegou?" na
cabeça que se olhou para a linha em vez de se concluir que o estado era
inalcançável.

O percurso ganhou `_barco_chegou()`: o caso diz `barco`, e a guarda vai ver a
CONSEQUÊNCIA disso — qual variação o cartão daquela doca está a vestir. É
derivada e não declarada, que é a lição da `039`.

## ⚠️ O segundo achado: o X6 da `042` estava VIVO neste arquivo

A `042` escolheu quatro literais `&"..."` em vez de um dicionário, porque o
`conferir_escopo_ui.py` procura o nome depois do `=`, e mediu que um nome por
`StringName(...)` não é visto por régua nenhuma. Isso está certo — e o mesmo
arquivo que a leva de hoje tinha de abrir carregava exatamente essa forma:

```gdscript
func _estilo(variacao: String) -> void:
	theme_type_variation = StringName(variacao)
```

Quatro chamadas, as quatro invisíveis ao portão. Medido: com
`_estilo("CartaoDocaRivl")` escrito à mão, o portão saiu **verde**. A função
dissolveu-se em quatro literais, que é o que a `042` já sabia.

⚠️ **E A GUARDA NOVA APANHA O QUE A REGEX NÃO VÊ.** Na `042` o X6 passava por
ambas as réguas; aqui o mutante X3 é exatamente ele e o **D33 reprova**,
nomeando a variação errada. A diferença é o tipo de pergunta: a regex lê o
TEXTO da atribuição e uma expressão dinâmica escapa-lhe sempre; a guarda lê a
CONSEQUÊNCIA no nó montado, e não há forma de código que a contorne. **Onde
uma varredura de texto não alcança, quem alcança é uma pergunta em runtime.**

⚠️ **Restam duas formas dinâmicas no projeto, e nenhuma é cor.** O
`PainelNarrativo.montar()` recebe a variação por PARÂMETRO — é API, e os
chamadores passam literais —, e o `Worker._aplicar_estilo()` passa o nome a
`get_theme_stylebox(prop, TIPO)`, que o portão nem procura. Ficam
**registados e não corrigidos**: fechá-los é mexer numa API e num mecanismo
diferente, e nenhum dos dois entrega cor. Vão com a leva do `Worker.gd`.

## O pulso, medido e arrumado

O cartão PULSA no estado Espera (`modulate` de branco a `(1,3 · 1,18 · 0,8)`),
e a régua mede um instante só — o de `modulate` branco, porque num `--script`
o tween não corre. A pergunta *"o instante medido é o pior?"* respondeu-se com
uma sonda que fixa o pico:

| papel | medido | no pico do pulso |
|---|---:|---:|
| Nome | 5,98 | **7,34** |
| Valor | 12,13 | 11,55 |
| Progresso | 7,54 | **9,43** |
| Trabalhador | 7,45 | **8,67** |

Três melhoram e um piora, e esse tem corte de 3,0 por ser de 19px. **O
instante que a régua mede é o pior para três dos quatro**, e nenhum se
aproxima do corte. Não é asserção — é medição registada, que é o que a `029`
manda fazer quando nem tudo o que se mede precisa de guarda.

## A prova, por dois caminhos

1. **As 277 linhas dos estados antigos**, com 50 a mudarem só a ORIGEM e
   ZERO a mudarem razão, corte, px ou texto.

2. **As 24 fotos da bateria**, com a bateria calibrada primeiro por duas
   corridas da MESMA árvore: **0 de 24** mexeram, e a migração mexeu em **0**.

⚠️ **E ESTA SEGUNDA PROVA PRECISOU DO CONTROLE POSITIVO, como na `042`** — e
desta vez ele responde para o outro lado. Lá o âmbar mudado não estava em foto
nenhuma, e as duas provas eram complementares por isso. Aqui, pintar o
`TextoDocaValor` de vermelho mexeu **13 das 24 fotos**: a bateria vê este
cartão em mais de metade delas, e a migração não mexeu numa só. **A identidade
byte a byte só quer dizer alguma coisa depois de se saber que a régua veria a
diferença** — e aqui ela veria, em treze sítios.

## Os mutantes

Cada um sozinho, com os originais guardados por `cp` (nunca `git`), controle
positivo antes e depois de cada um, e o código de saída lido **sem cano**.

| # | Defeito | Resultado |
|---|---|---|
| X0 | base limpa (controle positivo) | verde nas dez |
| X1 | a chave morta `docks[d]["rival_offer"]` de volta | **D33 reprova**, código 1: *"pediu o barco 0 sob oferta e o cartão vestiu «CartaoDocaEspera»"* |
| **X1b** | **o MESMO, com a guarda `_barco_chegou` RETIRADA** | **passa**, `DESIGN OK`, e a tabela publica **306 linhas** com o estado do rival a mostrar o progresso CALMO a 7,54:1 |
| X2 | `&"TextoDocaValorr"` na cena (forma literal) | **o escopo reprova**, pelo nome e pela linha |
| X3 | o `_estilo(StringName)` reposto, com `"CartaoDocaRivl"` | **escopo VERDE** — a regex não o vê — e **o D33 reprova**, pela variação vestida |
| X4 | `TextoDocaProgressoRival` fora do tema | **as DUAS reprovam**: o escopo pelo nome, o D33 por 1,22:1 (o `Label` base é navy, e o cartão do rival é vermelho) |
| **X4b** | **o MESMO, com o percurso VELHO de 22** | **o D33 passa** — só o escopo segura, porque a variação nunca é renderizada |

⚠️ **O X1b E O X4b SÃO O QUE PROVA A SESSÃO.** Sozinhos, o X1 e o X4 mostram
que alguma régua reprova alguma coisa. O par diz o que cada peça nova entrega:
o X1b, que **a guarda faz falta** — sem ela o mesmo arquivo fica verde com um
estado por montar; o X4b, que **o estado novo faz falta** — sem ele metade das
guardas fica cega a uma variação que não existe. É a forma do X1b/X3b da
`042` e do X1b/X2b da `040`.

⚠️ **E NO X3 É PRECISO DIZER QUAL SEGURARIA SOZINHA:** só o D33, e é o inverso
do X5 da `042`, onde só o escopo segurava. As duas réguas respondem a
perguntas diferentes e nenhuma cobre a outra — a do escopo pergunta de onde a
cor veio, lendo texto; a do D33 pergunta o que o nó vestiu, lendo o nó.

## O que fica de fora, dito

- **Duas levas restantes**, 3 chamadas em 3 locais: o verde do `UpgradePanel`
  (2/2), que continua a pedir **percurso primeiro, cor depois**, e a borda do
  `Worker.gd` (1/1), que é BORDA e não texto, fora do portão de contraste.
- **As duas formas dinâmicas** acima, registadas e não corrigidas.
- **Nada aqui mudou um pixel do jogo**, e é isso que as duas provas dizem. O
  cartão da doca está exatamente como estava; o que mudou foi de onde a cor
  dele vem, e quanto dele a régua consegue ver.
