# 023 — A costa das duas pontas é desenhada, e o cais continua reto

**14/09/2026.** O item **8** do segundo playtest, na letra do Bruno:

> *"Vi que as coisas são bastante quadradas, seja nas construções, como no mapa
> e seu desenho. Daí pode usar mais curvas e círculos para deixar o mapa mais
> real ao invés de quadrado e cheio de retas"*

A triagem classificou-o como **grande, e é direção de arte**: *"toca o gerador do
mapa inteiro e o kit de props, que é de caixas por construção. Não é uma
sessão."* Esta é a **primeira fatia**, a que o briefing de 13/09 recortou:
naturalizar o contorno da costa e das duas praias, sem tocar na projeção, nas
vias, na vila, nos cais, nos píeres ou nas âncoras.

**Nada aqui encosta na economia.** O `GameState.gd` não foi tocado, e das
catorze imagens da bateria mudaram as **sete que mostram o mapa** — `icones`,
`frota` e os cinco painéis saíram byte a byte iguais.

---

## 1. A queixa tinha endereço, e não era a praia inteira

Medida a costa **antes** de lhe tocar, em pixels de tela, juntando os segmentos
colineares da linha de água:

| trecho | corridas retas | a maior | quinas |
|---|---|---|---|
| praia norte | 3 | **179 px** | 2 de 126,9° |
| praia sul | 5 | **224 px** | 4 de 126,9° |
| cais | 5 | 179 px | 4 de 126,9° |

E a captura ampliada das duas pontas disse o resto: **a crista da duna já
serpenteava** desde 02/09 — a fronteira entre o relvado e a areia é uma linha
viva —, e quem era régua era a **linha de água**. Ela tinha
`LINHA_DE_AGUA = (1.0, 0.0, 0.0)`, amplitude **zero**, e por isso desenhava um V
de dois traços perfeitos em cada ponta.

Ou seja: a metade do problema que se ia atacar já estava resolvida havia doze
dias, e a outra metade estava numa constante com um zero. **Olhar antes de codar
custou dez minutos e mudou o que havia para fazer.**

## 2. O cais NÃO ganha curva, e isso é a decisão

Curvar a beira do cais seria o defeito e não a correção, por duas razões:

**Cais é concreto.** Um porto de verdade tem a beira reta — é o que a torna
legível como obra humana ao lado da praia, que é o que não é.

**E `borda` é a origem de tudo o que vive em terra.** `APRON`, `RUA_RECUO`,
`VILA_RECUO`, os três píeres, os acessos aos berços e a tabela de âncoras inteira
medem-se a partir dela. Curvá-la não é uma mudança de aparência: é mexer no
contrato entre `gerar_mapa_iso.py`, `Main.tscn` e o teste de design.

Então a ondulação nasce de uma **máscara** que vale zero entre `PONTA_NORTE` e
`PONTA_SUL` e sobe suave para fora delas. O que muda é só a parte do mundo onde
o porto não chegou. Conferido ponto a ponto: no trecho do cais a linha desenhada
cai em cima da escada de sempre a **1e-15 unidades**.

## 3. Uma família concêntrica, para não haver costura

Tudo o que acompanha a costa — a linha de água, o baixio de areia, a espuma, as
pedras, as três linhas da rampa, o capim, e o campo de cor da água — passou a
sair de **uma função só**, `ponto_costeiro(segmento, fração, distância)`.

É a lição que o `costa_deslocada` já trazia escrita desde 30/08 (*"a versão
anterior tratava cada degrau como uma faixa solta"*) levada um andar acima:
**aqui nem as quinas são soltas.** Cada quina de praia ganha um fileto em volta
de um centro FIXO, e o raio cresce com a distância à terra:

- a **enseada** (a água faz o canto) tem o centro na água, e o raio ENCOLHE ao
  afastar-se: a enseada fecha-se, que é o que a distância à costa faz mesmo;
- a **ponta** (a terra faz o canto) tem o centro na terra, e o raio CRESCE.

Quando o raio chega a zero, a curva volta a ser a quina de sempre — o encontro
das duas pernas deslocadas, que é exatamente a conta que o `costa_deslocada`
fazia. É por isso que a mesma construção serve o cais sem lhe tocar.

**Duas curvas desta família nunca se cruzam** (conferido em oito distâncias, de
1,3 terra adentro a 2,185 água adentro: zero cruzamentos), e é isso que torna a
costura impossível. Uma costura é duas contas a discordar; aqui só há uma.

## 4. O que se mediu depois

| trecho | corridas retas | a maior | maior quina |
|---|---|---|---|
| praia norte | 137 | **16,5 px** | 14,3° |
| praia sul | 214 | **13,2 px** | 13,4° |
| cais | 5 | 179 px | 126,9° |

A largura da areia, que era constante, passa a variar entre **1,11 e 1,63**
unidades. O cerco publicado (`praias[].recuo`) deixou de ser uma fórmula e passa
a ser **medido na crista desenhada**: 1,505 e 1,495 contra os 1,508 de antes.

## 5. O índice espacial não é afinação — é o que torna isto possível

O campo de cor da água é um raster de 518 mil pixels que mede a distância de
cada um à costa. Com a escada eram **10 segmentos**; com as pontas desenhadas
são **~500**, e a força bruta passou de 5 s para **182 s por mapa** — vezes os
quatro que o CI regera.

O índice divide a tela em blocos de 8 px, mede o CENTRO de cada bloco contra
todos os segmentos e guarda só os que ainda podem ganhar em algum pixel dali (um
segmento cuja caixa esteja mais longe do que `centro + meia diagonal` não ganha
em lado nenhum do bloco). Bloco inteiro longe demais sai transparente sem
trabalho nenhum.

⚠️ **E a poda TEM DE MANTER A ORDEM.** O empate, aqui, é desempatado pelo
primeiro segmento da lista — e uma poda que reordenasse trocaria o `my` que
alimenta o meandro da largura, mudando a cor de pixels que ninguém pediu para
mudar. A lista de candidatos sai na ordem original e só se descartam segmentos
que **não podem** ganhar. Provado: o PNG sai **byte a byte igual** ao da força
bruta, nas duas costas (a velha e a nova), em **12 s** em vez de 182.

## 6. O D28, e o defeito que quase não pegou

Nada neste projeto perguntava **a forma de uma linha**. O D15 pergunta se a
praia aparece e quem a pisa; o D20 e o D21 perguntam de que COR o mapa pinta um
ponto; o D27 pergunta que terreno há debaixo de cada bicho. Uma costa que
voltasse a ser uma escada passaria em todos eles, contente.

O **D28** faz quatro perguntas, e cada uma tem um estado que a viola sem violar
as outras — mais a de baixo, que é o cerco:

1. a linha publicada é contínua e atravessa cada ponta inteira;
2. nas praias não há reta longa nem quina de ângulo reto;
3. no cais **há** reta longa (senão bastava curvar o cais para "passar");
4. o mapa pinta água de um lado dela e terra do outro;
5. a areia para antes do passeio.

⚠️ **E A PRIMEIRA VERSÃO DA MÉTRICA DA RETA NÃO REPROVOU A ESCADA.** Ela juntava
segmentos cujo ângulo batesse a menos de meio grau — e a tabela publica pixel
com **uma casa decimal**, o que num segmento de 6,7 px dá 0,43° de ruído de
arredondamento. O que se estava a medir era o arredondamento, não a forma: com a
costa de volta à escada, a asserção da reta passou e só a da quina reprovou.
A métrica passou a ser a de **uma régua pousada em cima do desenho** — até onde
ela vai sem que a linha se afaste mais de um pixel dela —, e aí a escada mede
223,6 px contra os 16,5 da costa desenhada.

⚠️ **E UMA QUINTA ASSERÇÃO FOI CONSTRUÍDA, MEDIDA E RETIRADA.** Ela procurava a
borda desenhada atravessando a linha de 1 em 1 px, e reprovou o mapa CERTO por 7
a 10 px: sobre a rampa pousam pedras cinzento-azuladas (a referência pede
*"faixa clara com pedras"*), o pé molhado é escuro o bastante para uma conta de
azulidade o dar por água, e na emenda com o cais não há areia nenhuma — há
concreto dos dois lados. O defeito que ela existia para apanhar (a tabela
publicada 12 px fora do desenho) reprova na mesma, na **cobertura das praias**.

Os cinco defeitos injetados, cada um regerando o mapa **e reimportando o
projeto** — senão o Godot lê o `.ctex` da corrida anterior —, com a base a passar
entre cada dois:

| defeito | o que reprovou |
|---|---|
| `ONDA_AMP = 0` e sem filetos | a reta (223,6 px), a quina (126,9°) e a cor dos dois lados |
| máscara = 1 (curva o cais também) | **só** "o cais continua reto" (53,2 px) |
| contorno publicado 12 px ao lado | a cobertura das duas praias |
| contorno decimado a 1,1 unidades | "a tabela publica o contorno" (63 pontos) |
| `PRAIA_PROF = 5,1` | o cerco das duas praias contra o passeio |

## 7. O que NÃO foi feito

O item 8 continua aberto. Esta fatia é a costa; o **kit de props é de caixas por
construção** e o pedido fala também das construções. Isso é outra sessão, e
provavelmente mais do que uma.

E ficou de fora, medido e de propósito: **os cotovelos da rua não ganharam
curva.** Eles já levam chanfro de meia largura desde 08/09 (`013`), e arredondá-
los mexe no asfalto que o D20 percorre e no desvio que o camião faz para entrar
na doca — geometria funcional, que o recorte proibia.
