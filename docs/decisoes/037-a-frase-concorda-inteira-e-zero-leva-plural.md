# 037 — A frase concorda INTEIRA, e zero leva plural

**21/09/2026 · R8 da §7.1 do plano v3 · origem: revisão externa de 17/09 (§3)**

## A superfície, e ela cresce conforme a pergunta

A ficha nomeia três sítios — *"dia(s) restante(s)"*, *"dia(s) daqui"* e
*"tentativa(s)"*. Medido:

| Pergunta | Acha |
|---|---|
| os três que a revisão nomeou | 3 |
| `grep` por `(s)` no que o jogo exporta | **5** |
| `grep` pela FORMA (o `(s)` **e** o ternário à mão) | **8** |

Os dois que a revisão não viu estão no `GameState.gd` —
`"%d trabalhador(es) alocado(s)"` e `"%d doca(s)"` —, num arquivo que ninguém
tinha aberto porque a revisão andava pelos painéis.

Os três seguintes não escrevem `(s)`: escrevem a concordância com um ternário à
mão, `"" if n == 1 else "s"`. A saída deles estava **certa**; o que estava
errado é a regra do plural viver em cinco sítios — e num deles,
`PainelCaixa.gd`, a MESMA condição estava escrita duas vezes na mesma
expressão, uma para o substantivo e outra para o particípio:

```gdscript
partes.append("%d barco%s atendido%s" % [int(dia["servidos"]),
    "" if int(dia["servidos"]) == 1 else "s",
    "" if int(dia["servidos"]) == 1 else "s"])
```

⚠️ **É a regra do `CLAUDE.md` outra vez: fecha-se pelo `grep` da FORMA que
causou o defeito, nunca pela peça onde ele apareceu.** A busca por `(s)` é a
busca pela peça.

## A decisão 1 — zero leva PLURAL

Em português o singular é **só** em `n == 1`: "0 dias restantes", nunca "0 dia
restante". Um `n <= 1` escrito por distração dá o texto errado sem erro nenhum,
e **o zero é o único estado em que as duas versões divergem** — com 1, 2 e 32
elas dão o mesmo. É o mutante M1, e é por isso que ele existe.

## A decisão 2 — o adjetivo viaja com o substantivo

`Narrativa.concordar(n, um, varios)` recebe as **duas frases inteiras**, não
substantivo e adjetivo em separado.

A alternativa era concordá-los aqui dentro — e isso obrigaria a função a saber
género e a distinguir "restante" (que muda) de "esperando" (que não muda), o
que é um dicionário de português. A ficha proíbe: *"não criar pipeline de
tradução só por três ocorrências"*. Quem escreve a frase já sabe as duas
formas; esta função só escolhe entre elas.

É a mesma divisão do `por_extenso()` ao lado, que fala no feminino e deixa quem
chama decidir se serve.

## A decisão 3 — a cópia privada sai

`Main.gd` tinha um `_plural(n, singular, plural)` privado, e ao lado dele um
ternário solto a tratar do adjetivo:

```gdscript
"%s parado%s — %s esperando" % [_plural(parado.x, ...), "" if parado.x == 1 else "s", ...]
```

O helper tratava do substantivo e o adjetivo ficava de fora, à mão, na mesma
expressão. Foi apagado: **quando uma regra vive em dois sítios, a correção é
apagar a cópia, não reforçar o teste.**

## O que ficou, e onde

| Onde | Antes | Depois |
|---|---|---|
| `Main.gd` (HUD da parcela) | `%d dia(s) restante(s)` | `concordar(n, "dia restante", "dias restantes")` |
| `Main.gd` (trabalhadores) | `_plural` + ternário solto | dois `concordar`, adjetivo dentro |
| `PainelParcela.gd` | `%d dia(s) daqui` | `concordar(n, "dia", "dias")` + `" daqui"` |
| `CounterOfferPanel.gd` | `%d tentativa(s)` | `concordar(n, "tentativa", "tentativas")` |
| `GameState.gd` ×2 | `trabalhador(es) alocado(s)`, `doca(s)` | `concordar`, particípio dentro |
| `PainelCaixa.gd` ×2 | três ternários à mão | `concordar(n, "barco atendido", "barcos atendidos")` |
| `PainelDocas.gd` ×2 | dois ternários à mão | `concordar` |

São **11 chamadas**. O `"%d esperando trabalhador"` do `PainelDocas` **não**
passou pelo helper, e é decisão: o gerúndio é invariável e "trabalhador" ali é
genérico, não uma contagem — duas docas à espera não esperam dois trabalhadores
nomeados. Passá-lo por `concordar` com as duas formas iguais seria afirmar no
código que há concordância onde não há; ficou o comentário a dizê-lo.

## As guardas, e o que cada uma vê que a outra não vê

**T9** (`run_tests.gd`) — a aritmética, com o esperado **literal**. Montá-lo
chamando o próprio helper seria o espelho que este projeto já registou: o
defeito mudaria os dois lados e a asserção passaria contente.

**F9** (`teste_fumaca.gd`) — a superfície, varrida e não listada: nenhum `(s)`
cru, nenhum ternário à mão, e **todos os pares derivados do CÓDIGO** com a
forma plural mesmo no plural.

Medido pelos mutantes, nos dois sentidos:

- **M1** (zero em singular) reprova o **T9** e o F9 fica verde — o F9 é cego à
  aritmética por construção.
- **M2** (o adjetivo por concordar numa CHAMADA) reprova o **F9** e o T9 fica
  verde — o T9 prova o helper com um par escrito no teste, e nunca vê aquela
  chamada.

É a resposta medida a *"antes de dar um teste por redundante, pergunte que
defeito ele vê que o outro não vê"*.

## ⚠️ A guarda reprovou na estreia, e por uma razão de verdade

O F9 varria **linha a linha** e achou **6 das 11** chamadas. A prosa e o código
deste repositório quebram aos ~79 caracteres, e cinco das chamadas têm o
`concordar(` numa linha e as duas formas na seguinte. Pior do que reprovar: as
cinco **escapavam caladas** — não entravam na lista e não havia queixa nenhuma.

É a armadilha que o `CLAUDE.md` já regista para o `grep` de facto, cometida
dentro da guarda escrita para a caçar. O remédio é o mesmo: ler o arquivo
INTEIRO com a expressão a atravessar a quebra.

⚠️ **E O QUE A APANHOU FOI A CONTA POR DOIS CAMINHOS.** O F9 conta quantas
vezes a palavra `concordar(` aparece e quantos pares a expressão conseguiu ler,
e exige que os dois números sejam iguais — *"uma régua que responde à mesma
pergunta por dois caminhos denuncia-se sozinha"*. Sem essa asserção, a versão
linha-a-linha teria dito verde com cinco chamadas por olhar. É também o que
torna o **M5** possível: uma chamada de forma nova, que a expressão não saiba
ler, reprova em vez de ser ignorada.

⚠️ **E O PRIMEIRO ARGUMENTO PODE TER PARÊNTESES *E* ASPAS.** O `PainelCaixa`
passa `int(dia["servidos"])`. Uma expressão que casasse a primeira string a
seguir ao parêntesis leria `"servidos"` como a forma singular; uma que
proibisse parênteses no argumento saltava as duas chamadas daquele painel — e
foi o que fez a segunda tentativa achar 9 em vez de 11. O que se casa são as
**duas últimas strings antes do fecho**, com um nível de parênteses pelo meio.

## Os mutantes

Seis, cada um sozinho, base exigida VERDE entre eles, cópia com `cp` e não com
`git`, código de saída lido **sem cano**. A coluna diz qual guarda reprovou —
e, tão importante quanto, que a outra ficou verde.

| # | Defeito | T9 | F9 |
|---|---|---|---|
| M1 | `n <= 1` no helper (zero em singular) | **reprovou** | verde |
| M2 | `"dias restante"` numa chamada real | verde | **reprovou** |
| M3 | `(s)` de volta num rótulo | verde | **reprovou** |
| M4 | ternário `"" if n == 1 else "s"` de volta | verde | **reprovou** |
| M5 | chamada com variáveis, que a expressão não lê | verde | **reprovou** (pela contagem cruzada) |
| M6 | `(s)` dentro de COMENTÁRIO | verde | **verde**, como devia |

⚠️ **O M6 sozinho não prova nada**, e é por isso que o M3 é no mesmo arquivo: a
única diferença entre os dois é o `#`, e um passa e o outro reprova. Sem o par,
"verde" podia querer dizer "o scanner nunca olhou para este arquivo".

## Dois achados de OUTROS itens, registados e não corrigidos aqui

⚠️ **O `PainelCaixa` NÃO É CAPTURÁVEL, e a ferramenta não se queixa.** O
`setup()` dele exige um `Dictionary`, que a linha de comando não sabe passar: o
`capturar_cena.gd` chamou `setup()` com zero argumentos, o painel não montou, e
a ferramenta **imprimiu "Tela salva em" e saiu com código 0** com uma foto
preta. O erro existe na saída (`Method expected 1 argument(s), but called with
0`) e ninguém o lê. É a mesma família do `setup()` saltado de 12/09, com o
argumento no lugar da guarda de atalho — e o painel também não está na bateria.

A frase foi provada por outro caminho, e o caminho importa: com o porto de UMA
doca, `servidos` nunca passa de 1 por dia, e **com 1 a versão certa e a errada
dão o mesmo texto**. Só com o porto inteiro levantado é que a contagem sobe —
medido, melhor dia com 3: **"3 barcos atendidos"** e **"2 perdidos"**. É a
regra da contagem que só se testa acima de um, com uma frase no lugar do
contador.

⚠️ **E o `PainelDocas` também não está na bateria** — foi capturado à mão para
esta sessão. Junta-se ao Construir, ao Calendário, à Reputação e ao Caixa, que
o R7 já tinha registado: cinco painéis que o percurso do D33 mede e que nenhuma
foto mostra.

## O que fica de fora, dito

- **A REDAÇÃO não se tocou.** ⚠️ *Nota de 23/09:* o "0 dias daqui" não chega
  à tela — a conta só dá zero depois do dia 32, quando a cena do Sr. Ribeiro já
  tapa tudo ou a parcela está paga. O que o jogador lê no vencimento é **"1 dia
  daqui"**, fotografado (`capturar_cena.gd` com `turn=32`). "0 dias daqui" no painel da parcela é
  gramaticalmente correto e soa a máquina; trocá-lo por "hoje" é escolha de
  palavra, e palavra neste projeto é gate de quem lê em voz alta. Pela mesma
  razão a §2.5 — se o dia atual conta na parcela — ficou intocada, como a ficha
  manda.
- **A lista de invariáveis do F9 tem UMA palavra** (`esperando`) e é a porta
  por onde um adjetivo por concordar entraria sem a asserção o ver. Fica curta
  de propósito: cada entrada nova paga o seu lugar.
- **O F9 não julga gramática**, e não pode: distinguir "restante" de
  "esperando" exige um dicionário. Ele exige que cada palavra da forma plural
  termine em "s" ou esteja declarada como invariável — o que apanha o M2 e não
  apanha um plural irregular que este jogo não tem.
