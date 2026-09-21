# 041 — A cor migra por FUNDO, e a cena que não carregava era invisível

**21/09/2026 · a primeira leva das 27 cores declaradas em
`tools/excecoes_cor_ui.json` · a §7.1 tinha acabado, e esta é a opção (c) do
briefing de 21/09e, escolhida pelo Bruno**

## O que saiu, e por que foi esta leva

A `036` deixou **27 chamadas em 19 locais** declaradas como exceção à regra *"o
tema é o ponto único de estilo"*, com a ordem por fazer. O registro já dizia
como: **por LEVA e por FUNDO, nunca linha a linha** — nenhum tom ganha dois
fundos, e migrar cego quebra o que a `035` mediu.

A leva escolhida é a **barra escura do `Main.tscn`, inteira**: as quatro
pílulas do HUD, o stylebox delas, o `TrabalhadoresTitulo` e os três ramos do
`_refresh_titulo_trabalhadores()`. **10 das 27 chamadas, 8 das 19 entradas.**

| | antes | depois |
|---|---:|---:|
| cores de tema pintadas à mão | 27 em 19 locais | **17 em 11** |
| exceções declaradas | 19 | **11** |
| estados do percurso do D33 | 19 / 214 textos | **20 / 237** |

⚠️ **E O CRITÉRIO NÃO FOI O TAMANHO DA LEVA — FOI O QUE A RÉGUA ALCANÇA.** A
entrada do `UpgradePanel` no registro já escrevia a regra para si mesma:
*"migrar uma cor que o portão de contraste não alcança seria trocar uma dívida
visível por uma invisível"*. Das cinco levas possíveis, a barra escura é a
única em que o percurso dos 19 estados **já media todos os textos menos um** —
o verde do `UpgradePanel` só existe com estrutura construída, o âmbar do
`DocaCartao` só com doca sob oferta do rival, e nenhum dos dois estados é
montado.

As sete variações novas — `Pilula`, `BotaoPilula`, `TextoPilula`,
`TextoPilulaBom`, `TextoPilulaDestaque`, `TextoBarra` e `TextoBarraAlerta` —
carregam os **MESMOS valores** que estavam nos overrides. E são duas famílias
porque são dois fundos: a pílula é `#17293d` e o `Fundo` da cena é `#0d1a26`.

⚠️ **O TAMANHO NÃO VEIO JUNTO, e é a lição do `RotuloApoio` aplicada.** As
quatro pílulas medem 16px e o `TrabalhadoresTitulo` 13, e os
`theme_override_font_sizes` ficaram todos onde estavam: esta migração só devia
mexer na COR, e o leiaute é medido pelo D18 e pelo D22.

## A prova — e ela é de que NADA mudou

Uma migração que mexa num número não é migração; é mudança de cor a
fingir-se de arrumação. Logo o critério é a identidade, por dois caminhos:

1. **As 214 linhas dos 19 estados antigos saíram com razão, corte, px, estado
   e texto IDÊNTICOS**, e só a coluna ORIGEM mudou — em exatamente **10**
   linhas, as da leva e mais nenhuma:

   | | origem | razão |
   |---|---|---:|
   | `R$100.000` / `R$900.000` | → `TextoPilulaBom` | 8,37:1 |
   | `Dia 1/32` e `1/3` | → `TextoPilula` | 13,63:1 |
   | `65 Respeitado` | → `TextoPilulaDestaque` | 8,37:1 |
   | `1 trabalhador parado — 1 doca esperando` | → `TextoBarraAlerta` | 5,53:1 |

2. **As 24 fotos da bateria saíram byte a byte idênticas ao ANTES**, com os
   turnos e as contagens de painel dos 24 logs a baterem também.

⚠️ **E A SEGUNDA PROVA SÓ VALE PORQUE A RÉGUA FOI CALIBRADA PRIMEIRO.** Antes
de comparar qualquer coisa, a bateria correu **duas vezes na MESMA árvore** e
os 24 hashes bateram. É *"o mesmo arquivo dos dois lados tem de dar zero
EXATO"* com um PNG no lugar do arquivo: sem esse controle, "os bytes não
mudaram" não distingue uma migração limpa de uma régua que não sabe medir.

⚠️ **E A FOTO RESPONDE POR ESTADOS QUE O PERCURSO NÃO MONTA.** As 24 imagens
são uma partida sorteada com semente e passo de tempo fixos; o percurso são 20
estados escolhidos. As duas provas não se substituem — é por isso que são duas.

## ⚠️ O achado: o registro diz onde a COR é declarada, nunca quem CONSOME a peça

**O botão Pausar vestia o MESMO stylebox `pilula`**, por `styles/normal` em vez
de `styles/panel`. Ao mover aquele `SubResource` para o tema, o `Main.tscn`
deixou de carregar inteiro.

O inventário da leva saiu do registro de exceções, e o registro **não podia
dizer isto**: ele lista `sub_resource:pilula / bg_color` e
`sub_resource:pilula / border_color` — onde a COR está escrita —, e uma
referência ao stylebox não é uma cor, logo nunca entrou no `conferir_escopo_ui`
nem no registro. A contagem do portão estava certa; a minha lista de quem
mexer é que estava incompleta. **Antes de mover uma peça de estilo, procure
todos os `SubResource("<id>")`, e não as cores dentro dele** — a peça tem
consumidores que a cor não tem.

Um `Button` não pode vestir a variação `Pilula`, cujo `base_type` é
`PanelContainer`: daí o `BotaoPilula`, que declara só o `normal` — o hover e o
pressed continuam a sair do `Button` do tema, como na cena.

## ⚠️ O segundo achado: cena que não CARREGA era invisível às duas réguas

O defeito acima entregou, de graça, o buraco que ele atravessou.

`montar_caso()` conferia `ResourceLoader.exists()`, que só diz que o ARQUIVO
está lá. Com um `SubResource` órfão, o `load()` devolve `null`, o
`.instantiate()` num `null` **aborta a função**, e quem chama recebe o mesmo
`null` que significa *"já me queixei"* — faz `continue`, e:

- a ferramenta encerrou com **`CONTRASTE MEDIDO` e código 0**, com **46 textos
  a menos** (168 contra 214) e três estados por medir;
- o D33 disse **`PASS — nenhum texto abaixo do AA em 147 medidos`**, um verde
  declarado sobre 38% dos textos em falta.

É *"zero textos não é este painel passou"* um andar acima, e com o sinal
trocado: ali a cena montava e não produzia texto, **e havia guarda**; aqui ela
nunca chegou a montar, e não havia nenhuma. Hoje `montar_caso()` separa
`load()` de `instantiate()` e põe a falha em `falhas`, que o D33 já lê.

⚠️ **E O QUE ELA DEFENDE ESTÁ MEDIDO, com o que fica de fora dito.** Com um
painel quebrado, **18 outras asserções já reprovam por cascata** — procurei nos
três painéis e não achei nenhum em que a guarda nova seja a única a falar. O
que ela acrescenta são duas coisas, e não mais: é a **única linha que nomeia a
causa** (`cena não carregou: res://... (estado Calendário)`), e é a única que
impede o **próprio D33** de publicar um verde com um terço da amostra fora.
A ferramenta, essa, não está no CI — lá o único que fala é ela.

## O percurso ganhou um estado, e foi por AÇÃO e não por campo

O repouso NEUTRO do título dos trabalhadores **nunca esteve nos 214 textos**.
Não é distração: `trabalho_parado()` devolve ZERO quando não há trabalhador
livre, e o porto abre com UM livre e uma doca à espera — logo os dois estados
de HUD do percurso mediam **sempre o âmbar**, e uma cor escrita em dois sítios
viveu fora do alcance da régua que existe para a medir.

Nenhum `GS.set()` alcança esse estado, porque ele é o RESULTADO de uma regra.
O percurso passou a aceitar `"acao"`, uma lista de métodos chamados sobre o
mundo já montado, e o estado entra pela **porta do jogador**:
`assign_all_free_workers()` é o que o botão "Alocar todos" chama. Escrever o
estado à mão poria o rótulo certo com o resto parado — a armadilha da `038`.

Ele mede **6,01:1**, e trouxe de brinde um texto isento novo: com todos os
trabalhadores alocados, "Alocar todos" fica desligado a 2,16:1 — legítimo, e a
guarda do motivo do bloqueio aceita-o porque a mesma frase aparece VIVA noutros
estados.

## Os mutantes

Cada um sozinho, com os originais guardados por `cp` (nunca `git`, que não sabe
o que ainda não foi commitado), controle positivo antes e depois, e o código de
saída lido **sem cano**.

| # | Defeito | Resultado |
|---|---|---|
| X0 | base limpa (controle positivo) | verde nas três réguas |
| X1 | `SubResource` órfão no `Main.tscn` | ferramenta **reprova**, código 1, nomeia o estado |
| **X1b** | **o MESMO, com a guarda nova retirada** | **passa**: `CONTRASTE MEDIDO`, código 0, 168 textos |
| X1c | um PAINEL que não carrega | **D33 reprova** — *"cena não carregou … (estado Calendário)"* |
| **X1d** | **o MESMO, sem a guarda** | **D33 PASSA** *"em 147 medidos"* — 90 textos em falta, verde |
| X2 | variação com o nome trocado na cena | reprovam **as duas**: o escopo pelo NOME, o D33 pelo contraste |
| X3 | cor de `TextoBarra` trocada pelo navy | escopo **verde** (não é cor à mão), D33 reprova |
| **X3b** | **o MESMO, com o percurso VELHO de 19** | **passa**: 0 reprovas em 214 textos |
| X4 | `pilula` do tema pintado de branco | **12 reprovas** = 4 números × 3 estados de HUD |

⚠️ **O X1b, O X1d E O X3b SÃO O QUE PROVA A SESSÃO.** Sozinhos, o X1 e o X3 só
mostram que alguma régua reprova alguma coisa. O par é que diz que a guarda
nova e o estado novo fazem falta: **o mesmo arquivo passa por tudo o que havia
antes.** É a forma do X1b/X2b da `040`.

⚠️ **E O X4 PROVA O STYLEBOX PELO QUE ESTÁ POR CIMA DELE.** Nenhuma guarda mede
a cor de um fundo diretamente — o que se mede é o TEXTO contra ele. Pintar a
pílula de branco no tema move as quatro razões de uma vez, e é isso que
demonstra que a variação está mesmo a chegar aos quatro nós: **o fundo
verifica-se pela frente.**

⚠️ **E NO X2 SÃO DUAS GUARDAS, e é preciso dizer qual seguraria sozinha.** O
escopo apanha-o porque exige que toda variação usada exista no tema; o D33
apanha-o porque o nó cai no `Label` base e sai navy sobre azul-escuro. Se um
dia a variação errada tiver cor legível, só o escopo o apanha.

## O que fica de fora, dito

- **As outras quatro levas não se tocaram**, e cada uma tem a sua razão escrita
  no registro: a faixa de mensagem (creme, outro fundo), o cartão da doca
  (quatro styleboxes e alfa 0,96 sobre o MAPA), o verde do `UpgradePanel` e o
  âmbar do `DocaCartao` (estados que o percurso não monta) e a borda do
  `Worker.gd` (não é texto, logo fora do portão de contraste).
- **O percurso continua sem montar o estado do `UpgradePanel`.** A ordem que o
  registro manda é percurso primeiro, cor depois — e esta sessão cumpriu-a para
  a barra escura, não para as outras.
- **Nada aqui diz que a barra ficou mais bonita.** Os valores são os mesmos, e
  as 24 fotos provam-no byte a byte. O que mudou foi de onde a cor VEM.
