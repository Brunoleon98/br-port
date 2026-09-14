# 024 — O casco ganha curva, e a obra industrial fica quadrada

**14/09/2026.** A segunda fatia do item **8** do segundo playtest, na letra do
Bruno:

> *"Vi que as coisas são bastante quadradas, seja nas construções, como no mapa
> e seu desenho. Daí pode usar mais curvas e círculos para deixar o mapa mais
> real ao invés de quadrado e cheio de retas"*

A primeira fatia foi a costa (`023`). Esta é o **kit de props**, que a `023` §7
deixou nomeado: *"é de caixas por construção"* — 178 chamadas a `caixa()` contra
42 a `cone()` nos dois geradores.

**A contagem de chamadas descreve como o prop foi CONSTRUÍDO; não descreve o que
o jogador VÊ.** Por isso esta sessão começou por medir, e a medição mudou o
alvo: quem estava quadrado não eram as construções.

---

## 1. A régua: que fração da silhueta corre no eixo

`tools/medir_silhueta_props.py`. Nesta câmera, uma caixa alinhada aos eixos só
sabe desenhar **três direções** — +26,57°, −26,57° e a vertical, que são as
arestas X, Y e Z do mundo projetadas. Qualquer outra direção na silhueta é
curva, bisel ou peça girada. A medida é a fração do contorno que corre numa
dessas três.

O contorno sai por marching squares no alfa (subpixel, sem escada de pixel) e a
reta mede-se com a **régua do D28**: para cada ponto, até onde uma corda
centrada nele se estende sem que a linha se afaste mais de 1 px.

⚠️ **E A REFERÊNCIA ACOMPANHA A CAIXA ENVOLVENTE DA PEÇA — sem isso a métrica
mede o TAMANHO e a ESBELTEZ, não a forma.** Um contorno fechado dá 360° de
curva no total, então o preço das quinas é fixo em pixels e pesa tanto mais
quanto menor for a peça; e uma peça comprida corre quase toda na direção do
próprio comprimento. As duas coisas juntas quase decidiram esta sessão ao
contrário — ver §3.

A tabela que sai disso é o que dá sentido a qualquer número:

| peça | caixa ideal | cilindro | redondo | banda |
|---|---|---|---|---|
| 10×14 | 0,284 | 0,302 | 0,179 | 0,104 |
| 16×22 | 0,500 | 0,442 | 0,258 | 0,242 |
| 24×34 | 0,658 | 0,502 | 0,262 | **0,396** |
| 50×70 | 0,836 | 0,549 | 0,272 | 0,564 |
| 100×140 | 0,918 | 0,573 | 0,271 | 0,647 |
| 10×35 | 0,640 | **0,635** | 0,340 | 0,300 |
| 24×84 | 0,828 | **0,740** | 0,403 | 0,424 |

Duas leituras saem daí, e as duas são cortes:

- **abaixo de ~24 px de diagonal a caixa ideal e a forma redonda medem o
  MESMO.** A ferramenta recusa-se a dar índice aí, em vez de imprimir um número
  plausível. Ficam de fora as seis espécies de fauna, o cone, o cabeço e o
  poste de luz — não porque estejam bem, mas porque a silhueta, a esse tamanho,
  não sabe dizer redondo de quadrado;
- **numa peça ESBELTA a caixa e o cilindro medem quase o mesmo** (0,640 contra
  0,635 a 10×35). Peça comprida não se conserta arredondando a secção.

## 2. E o chanfro que o kit inteiro já aplica é invisível por construção

Varrendo o raio de filete numa caixa ideal e remedindo:

| raio | 40 px de largura | 60 px | 95 px |
|---|---|---|---|
| 0,5 px | −0,012 | −0,008 | −0,002 |
| 1,0 px | −0,010 | +0,004 | −0,019 |
| 2,0 px | +0,005 | −0,035 | −0,016 |
| **3,0 px** | **−0,074** | **−0,077** | **−0,050** |
| 6,0 px | −0,206 | −0,147 | −0,104 |

Abaixo de 2 px o número não se mexe fora do ruído: **o filete entra na imagem a
partir de ~3 px de raio e só LÊ a partir de ~6.** O `chanfrar()` do kit usa
0,020 unidades de mundo, e uma unidade vale 20 px de tela — **0,4 px**, vinte
vezes abaixo do que a régua consegue ver. É a irmã da regra do *"relevo de
0,9 px não sobrevive ao antisserrilhado"*, escrita em unidades de forma.

Daí o portão de tamanho: **um filete que se leia não cabe numa peça pequena.**
A 40 px de largura, um filete de 6 px já leva a caixa para BAIXO da linha do
cilindro — deixou de ser quina arredondada e passou a ser outra forma. Os
caminhões têm 35 a 49 px de diagonal e ficam fora por esta conta, não por gosto.

## 3. A medição inverteu o alvo: quem estava quadrado era o CASCO

Com tudo medido e pesado pelo que ocupa na tela (pixels opacos × instâncias
simultâneas, lidas de `Main.tscn` e do `Dock.tscn` ×3):

| prop | índice | maior reta | px na tela | o referente é caixa? |
|---|---|---|---|---|
| `pier_vazio` | 1,065 | 16 px | 5.454 | estaca — **ver abaixo** |
| `pallet` | 0,787 | 15 px | 229 | **sim** |
| `pier_n1` | 0,612 | 56 px | 17.907 | tabuado — **sim** |
| `barreira` | 0,588 | 17 px | 235 | **sim** |
| `galpao` | 0,563 | 61 px | 5.049 | **sim** |
| `pier_n2` | 0,522 | 56 px | 19.356 | **sim** |
| `barco_grande_conteiner` | 0,516 | 63 px | 22.870 | contêiner — **sim** |
| `escritorio` | 0,398 | 47 px | 3.304 | **sim** |
| `caminhao_*` | 0,09–0,34 | 16–22 px | ~2.000 | pequeno demais |

A leitura óbvia dessa tabela é *"a caixa que se vê nos barcos é o contêiner"* —
o porta-contêineres mede 0,516 e o irmão de carga geral 0,203. **E está
invertida.** Renderizado SOZINHO, sem contêiner, sem cabine e sem mastro, o
casco do cargueiro grande mede:

> **`sonda_casco_so` — índice 0,620, maior reta 56 px, 95 × 60**

Acima do galpão (0,563) e de tudo o mais que tem tamanho para a pergunta ter
resposta. **O contêiner não fazia o navio ler quadrado: ele TAPAVA o casco**, e
por isso os dois cargueiros mais "redondos" da tabela eram os que tinham carga
solta por cima. Quem estava reto era o bordo — dos sete pontos do contorno, o
lado de (1,55, 0,58) a (−1,45, 0,62) é uma reta de três unidades que cai
exatamente em cima de um eixo.

### E as estacas do píer NÃO ganham nada com serem redondas

O `pier_vazio` mede **1,065** — mais quadrado do que a caixa ideal do próprio
tamanho, e o valor mais alto do kit. A leitura óbvia (*"arredonde as estacas"*)
foi construída e medida, com uma estaca quadrada e uma cilíndrica renderizadas
lado a lado no mesmo sítio:

| | silhueta | linhas de dentro |
|---|---|---|
| estaca quadrada | 0,641 | 0,722 |
| estaca redonda | 0,626 | 0,617 |

Uma estaca tem 9 × 32 px, e **uma estaca cilíndrica tem exactamente os mesmos
dois lados verticais na silhueta**: o que a faz medir alto é ser COMPRIDA, não
ser quadrada — é a linha 10×35 da tabela do §1. O ganho não paga, e fica
registado em vez de arredondado.

## 4. A decisão: o que ganha curva, e o que é quadrado de verdade

**Ganha curva — o CASCO, e só ele.** Nove props saem de dois contornos, então
uma mudança serve os nove; são cinco na tela ao mesmo tempo (três docas mais
dois na Zona de Espera); e o porto em ruínas **só recebe pesqueiro** (`009`),
de modo que o principiante passa a partida inteira a olhar para eles.

**São quadrados de verdade, e por isso ficam como estão** — é o *"o cais é
concreto"* da `023` aplicado aos props:

| prop | índice | porquê fica |
|---|---|---|
| `galpao`, `galpao_velho` | 0,563 / 0,225 | um armazém É uma caixa |
| `escritorio`, `escritorio_ruina` | 0,398 / 0,367 | idem |
| convés dos três píeres | 0,50–0,61 | tabuado e laje são retângulo |
| `lanca_n2`, `lanca_n3` | 0,32 / 0,41 | treliça de aço |
| os contêineres do convés | — | um contêiner É uma caixa |
| `pallet`, `pilha_caixotes`, `barreira` | 0,79 / 0,06 / 0,59 | angulares por ofício |

**Fora da pergunta, por tamanho:** as seis espécies de fauna, o `cone_transito`,
o `cabeco` e o `poste_luz` — abaixo dos ~24 px em que a régua separa redondo de
quadrado. **Fora por não ler:** os oito caminhões, pelo portão do filete do §2.

E `doca_concreto` (índice 0,412, 136 × 88) saiu da lista por outra razão, que a
varredura encontrou de caminho: **ele não está no jogo.** É referido só por
`scenes/tests/AssetPlacementTest.gd`, que não é exportado — o `barco_medio` mais
uma vez, e desta vez num prop que nunca chegou a doca nenhuma.

## 5. O que mudou na geometria

**O contorno do casco deixou de ser uma lista de sete pontos e passou a sair de
`contorno_casco()`** — entrada, corpo paralelo e esgorjadura, amostrados a 18
passos por bordo. O passo fica em ~4 px de tela, abaixo dos 6 px que a régua
chama de reta: a curva lê-se como curva e não como um polígono novo. Os
extremos — proa, popa e boca máxima — **não se mexeram um pixel**, para a caixa
envolvente do prop ficar igual: o barco cai em `Dock.tscn` num `offset` fixo.

Três coisas vieram atrás, e nenhuma por gosto:

- **a linha de fundo ganhou curva PRÓPRIA.** Escalar um contorno curvo achata a
  curva dele: com `(0,88, 0,42)` a variação de meia-boca chegava lá 58% menor e
  o que sobrava desviava-se menos de 1 px ao longo de 60 px — a régua lia uma
  reta. O `prisma()` passou a aceitar `contorno_baixo`;
- **o guarda-corpo passou a seguir o bordo.** Enquanto o bordo era reto o
  `corrimao()` reto coincidia com ele por acidente; com o bordo curvo ficou
  atravessado no convés, com as pontas a morrer no meio da chapa;
- **o tosado (a amurada a subir para a proa) ficou de fora, medido.** Uma
  unidade de altura vale 24,5 px e o casco tem 0,62 delas; o tosado de um navio
  real anda por 8% do pontal, o que dá **1,2 px** — abaixo dos 3 px do §2.
  Seria geometria paga e invisível. O que esta câmera mostra é a PLANTA.

### O que a mudança mediu

| | antes | depois |
|---|---|---|
| casco sozinho, índice | 0,620 | **0,547** |
| linha de fundo, cargueiro | 70,2 px | **50,6 px** |
| linha de fundo, arrasteiro | 58,0 px | **43,9 px** |
| linha de fundo, traineira | 44,1 px | **31,9 px** |
| maior reta do navio inteiro | 62–66 px | **52 px** |

**E pára aí de propósito.** O que resta de reto no casco é o **corpo paralelo**,
que é o que um cargueiro tem mesmo — tirá-lo daria uma amêndoa, que lê como
canoa. É a mesma decisão do cais na `023`, um andar abaixo.

**Das catorze imagens da bateria mudaram as nove que mostram barco**; as cinco
de painel puro saíram byte a byte iguais.

### E o bote é pequeno demais para esta curva

Medido, e fica como está. A 0,62 do pesqueiro o fundo dele tem 2,4 px de
meia-boca: **a curva inteira cabe dentro do pixel de tolerância da régua**, e a
maior reta da linha de fundo mexeu-se de 0,574 para 0,597 do comprimento — para
o lado errado, por ruído. Tentou-se dar-lhe fundo chato (0,70 em vez de 0,42,
que é o que um bote aberto de linha tem mesmo): deu 0,621, e **a 6× de
ampliação as três versões são a mesma imagem**. É o §1 aplicado a um pedaço de
prop, e a resposta certa é não mexer.

## 6. O D29, e o defeito que só metade pegou

Nada neste projeto perguntava a **forma de um PROP**. O D28 pergunta a forma de
uma linha PUBLICADA; o D17, quanto desenho há à volta de um ponto; o D7,
encaixe; a guarda dos cascos distintos, se dois props desenham a mesma coisa.
Um casco de volta ao polígono de sete pontos passaria em todos eles, contente —
e foi assim que ele viveu como a peça mais quadrada do kit.

**O D29 mede a LINHA DE FUNDO**, e é ela por uma razão: nada num barco fica
abaixo do casco — nem mastro, nem contêiner, nem guindaste, nem chaminé. Logo o
pixel mais baixo de cada coluna é do casco e de mais nada, e a forma dele
mede-se num PNG já composto sem separar peça nenhuma. O bordo de cima não
serviria: ali passam a superestrutura e a carga. A posição sai com precisão
subpixel da rampa de alfa, senão o que se mede é a escada da rasterização.

⚠️ **E O CORTE DE TAMANHO É DERIVADO, NÃO UMA LISTA DE NOMES.** Cascos abaixo de
60 px ficam de fora *porque a curva lhes cabe dentro da tolerância da régua*
(§5) — um casco novo de 50 px sairia pela mesma conta, e a guarda diz na saída
quem saltou e porquê. A isenção que o D2 tinha era o defeito; esta é uma
medição.

Os dois defeitos injetados, cada um regerando os nove PNGs **e reimportando o
projeto** — senão o Godot lê o `.ctex` da corrida anterior —, com a base a
passar entre os dois e o original guardado com `cp` e nunca com `git`:

| defeito | o que reprovou |
|---|---|
| o casco volta ao polígono de sete pontos | **as 8 asserções do D29**, e só elas (68% a 74% contra o teto de 62%) |
| convés curvo, fundo outra vez escalado | **só o arrasteiro** (63%); os outros sete ficam em 55–59% e passam |

⚠️ **O SEGUNDO DEFEITO SÓ PEGOU NUM DE OITO, e isso fica escrito.** Apertar o
teto para 57% apanharia seis, e deixaria o arrasteiro bom a passar por 2 pontos
— margem que uma mexida futura no casco torna vermelha sem ninguém perceber
porquê. O teto ficou em 62%: o D29 defende a FORMA DO CONTORNO, e a curva
própria da linha de fundo é defendida pela medição do §5 e não por ele. Nem
tudo o que se mede precisa de guarda; o que não se pode é fingir que tem uma.

## 7. O que NÃO foi feito

O item 8 fecha aqui a parte que tinha resposta medida. Ficaram de fora, cada um
com o seu número:

- **as construções** (galpão, escritório, píer, lança) — §4, são caixas de
  verdade;
- **as estacas** — §3, redondas medem o mesmo;
- **os caminhões** — §2, pequenos demais para um filete que se leia;
- **o tronco do coqueiro** (índice 0,491, 16 × 61, três na tela) — a secção não
  ajuda, pela linha 16×56 da tabela do §1, mas **curvar o EIXO dele curvaria a
  silhueta**, e isso não foi medido. É o único candidato que sobra com uma
  pergunta em aberto, e cabe numa sessão pequena.
