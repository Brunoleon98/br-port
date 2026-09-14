# 025 — O mapa entrega os 1080 que o arquivo já tinha

**14/09/2026.** A **alavanca A** do item *"A resolução dos assets"* da §7 do
plano v3, recortada pelo Bruno como a próxima conversa. Nasceu da pergunta
dele: *"valia a pena aumentar a resolução do jogo para que o mapa e outras
coisas tivessem mais pixels para poder detalhar melhor"*.

São três alavancas e só esta foi tocada. A **B** (os props a 768) é outra
sessão; a **C** (o viewport a 1080×1920) está medida e **não dá um pixel** —
com `stretch/mode="canvas_items"` o jogo já desenha na resolução nativa do
aparelho, e o 720 é sistema de coordenadas.

**Nada aqui encosta no `GameState.gd`, na projeção, nas âncoras ou na pegada
publicada.** Das catorze imagens da bateria mudaram as **sete que mostram
mapa**; as sete de painel e as duas folhas de contato saíram byte a byte iguais.

---

## 1. O que estava a acontecer: uma redução seguida de uma ampliação

Os quatro SVG de mapa — `porto_mapa_iso`, `_patio` e as duas espumas —
declaram `width="720"` sobre um `viewBox="0 0 1080 1080"`. O importador
rasterizava pelo `width` com `svg/scale=1.0`, e o `canvas_items` voltava a
ampliar 1,5× no aparelho. **A geometria existia a 1080, chegava à textura a 720
e era esticada de volta a 1080.** A alavanca A não pede um traço novo — pede
que se pare de deitar fora o que já está no arquivo.

O `svg/scale` passou a **1,5** nos quatro, e os três nós de mapa do `Main.tscn`
(`Mapa`, `Espuma0`, `Espuma1`) ganharam `expand_mode = 1` (IGNORE_SIZE), que é
o que permite ao rect continuar com 720 de coordenadas enquanto a textura tem
1080. Sem isso o tamanho mínimo do nó passaria a ser o da textura e o mapa
cresceria para 1080 de coordenadas, arrastando consigo a pegada e todo prop
posicionado em cima dele.

## 2. A comparação honesta não é 720 contra 1080

`brport_vs/tools/medir_resolucao_mapa.gd` (novo), com o **mesmo ThorVG** que
importa o mapa no jogo. Comparar a textura de 720 com a de 1080 compararia
tamanhos; o que o jogador vê num telefone de 1080 de largura é:

| | como chega à tela |
|---|---|
| **antes** | ThorVG a 720 → a GPU amplia 1,5× para 1080 |
| **depois** | ThorVG a 1080 → 1:1 |

As duas imagens têm 1080 px, e é assim que se medem.

⚠️ **E A MÉTRICA NÃO É A SOMA DA ENERGIA DE GRADIENTE.** A energia total de uma
fronteira é o salto de valor dela, e isso **não muda** quando ela se espalha por
mais pixels: ampliar conserva a soma quase toda. O que ampliar destrói é o
**pico** — a mesma fronteira passa a subir ao longo de 1,5 px em vez de 1.

⚠️ **E A CONTAGEM DE PIXELS ACIMA DO PISO MEDE A LARGURA DA FRONTEIRA, NÃO
QUANTAS HÁ** — ela cai 14,3%, e ler isso como perda é ler ao contrário: uma
fronteira borrada espalha-se por mais pixels e cada um passa o piso.

Na janela do `MapaWrap` (1080×990), com o piso em 6/255 de luminância (~0,05 de
Weber a meio tom):

| região | pico médio antes | depois | px que o jogador vê mudar acima do piso |
|---|---|---|---|
| **tudo** | 17,29 | **26,38** (+52,6%) | **5,12%** (1,96% acima de 12/255) |
| **vetor** | 17,16 | 25,56 (+48,9%) | 6,76% |
| **raster (água)** | 17,74 | 29,73 (+67,6%) | 2,93% |

Os +52,6% do pico são, ao ponto, o 1,5× teórico.

## 3. O mapa tem DUAS camadas com escalas diferentes, e uma não ganha nada

⚠️ **O campo de cor da água é um PNG de 720×720 EMBUTIDO no SVG**, esticado
sobre o `viewBox` de 1080 (`agua_costeira_gradiente`, `SAIDA = 720`). Subir o
`svg/scale` **não lhe acrescenta um pixel de informação**: é o único sítio do
mapa onde a precisão que falta não está no arquivo. Medir o quadro inteiro de
uma vez misturaria o ganho real do vetor com o zero garantido do raster.

A máscara para os separar sai do próprio SVG: rasteriza-se uma segunda vez com
a `<image>` retirada, e onde as duas versões diferem é onde o raster está à
vista. São **456.587 px da janela — 43%**.

E mesmo assim a água melhora (+67,6% de pico), **por outra razão**: hoje ela faz
720 → 1080 (viewBox) → 720 (saída) → 1080 (GPU), três reamostragens; depois faz
720 → 1080 → 1080 → 1080, uma. **Ela não ganha informação, deixa de perder.**

E não se denuncia como pixelização porque o que ela desenha é campo CONTÍNUO:
um gradiente ampliado continua um gradiente. O que tem traço ali — as pedras, a
espuma, os riscos de onda, a linha de areia — é vetor, e ganha. Conferido no
recorte a 3× da praia.

## 4. A armadilha que o plano previu NÃO existe, e a conta diz porquê

A §7 do plano e a Etapa 7 do plano de arte avisavam, com todas as letras, que
*"a 1,5× um traço de 1 px passa a 1,5 e um vinco calibrado para quase
desaparecer pode reaparecer"*, e mandavam varrer o gerador à procura de toda
constante medida em pixel. **A varredura tem uma resposta derivada, e ela
dispensa a varredura.**

A alavanca A **não toca no gerador**: o SVG é o mesmo arquivo, byte a byte. Um
`stroke-width="1.6"` está em unidades do `viewBox` de 1080, e chega à tela
FÍSICA do telefone assim:

| | na textura | na tela de 1080 |
|---|---|---|
| antes | 1,6 × 720/1080 = **1,067 px** | ampliado 1,5× = **1,6 px** |
| depois | **1,6 px** | 1:1 = **1,6 px** |

**A largura física de todo traço é exatamente a mesma.** Subir o `svg/scale`
remove uma redução; não amplia um desenho. A armadilha é real — mas para um
asset desenhado nas unidades da SAÍDA, que é a alavanca B, e não para um
`viewBox` que já estava em 1080.

E a medição confirma-o sem depender da conta: se o desenho tivesse sido
ampliado, a rampa de cada fronteira ocuparia 1,5× mais pixels. Ela ficou **14,3%
mais estreita**.

## 5. O custo, que ninguém tinha medido

| | antes | depois | |
|---|---|---|---|
| `.ctex` dos quatro | 549.956 B | 962.196 B | +75,0% |
| **`.pck` (é o que o APK e o `brport-web` carregam)** | **4.003.064 B** | **4.415.304 B** | **+412.240 B, +10,30%** |
| VRAM (RGBA8, sem mipmaps) | 7,91 MB | 17,80 MB | +9,89 MB |

As duas texturas de mapa são `preload` no `Main.gd` (ele troca para a do pátio),
e as duas espumas são camadas permanentes: os 17,80 MB são simultâneos.

O `.pck` sai do `--export-pack`, que não precisa dos templates de exportação —
é por isso que este número foi medido aqui, e não deixado para o CI.

## 6. O portão: a diferença vê-se, e o aparelho pequeno não piora

O portão era o do bote da `024` — *se a captura a 1,5× não mostrar diferença que
se veja no telefone, pare e registe a medição*.

⚠️ **E A BATERIA DE 720 NÃO PODE RESPONDER A ESSA PERGUNTA.** Ela é travada a
720×1280 (está escrito no `capturar_evidencia.sh`), e a 720 a textura de 1080 é
reduzida pela GPU — de volta a quase o que era. O antes/depois honesto é a
**1080×1920**, que é 1,5× exato nos dois eixos e o telefone que o plano mediu
como padrão de facto.

A 1080, no recorte a 3×, a diferença é evidente peça a peça: as fiadas do
telhado deixam de ser um borrão vermelho e viram linhas; as barras da passadeira
ganham quinas; o campanário, as janelas, o toldo e o meio-fio ganham aresta; as
pedras da praia passam de manchas a sólidos com faces.

**E o aparelho de 720 melhora, não piora** — o risco que faltava medir era o
aliasing de uma redução de 1,5:1 sem mipmaps:

| na área do mapa, a 720 | antes | depois |
|---|---|---|
| pico médio da fronteira | 25,90 | 24,58 (−5,1%, mais suave) |
| **pontos soltos** (a assinatura do aliasing) | **3,10%** das fronteiras | **2,90%** |

O downscale de 1,5:1 age como supersampling parcial e **limpa** o serrilhado.
Mipmaps não fazem falta, e ficam de fora: custariam +33% de VRAM para corrigir
um defeito que não existe.

## 7. E a mudança destapou o último bloco raster que provava por PIXEL ÚNICO

O teste de design reprovou em **18 pontos**, e a primeira falha nomeava a causa:
*"porto_mapa_iso.svg tem os 720×720 da tabela"*. **A guarda funcionou** — o
comentário dela dizia exatamente isto: *"um mapa reimportado noutra escala faria
cada amostra cair num sítio diferente do que se pede, e todas passariam, porque
o relvado também não é calçada. Ler no sítio errado é pior do que não ler."*

Seis blocos amostram o mapa por coordenada de TELA (D20, D21, D24, D27, D28 e a
Zona de Espera) e todos assumiam calados que a textura tinha a resolução da
tabela. Passaram a ir por um leitor único, `_mapa_lido`, que devolve a imagem
**com o fator de escala já conferido**. A guarda deixou de comparar com 720 e
passa a exigir o que sempre quis dizer: **um múltiplo inteiro e igual nos dois
eixos** do que a tabela publica. Uma imagem de outra proporção, mais pequena ou
esticada num eixo só continua a reprovar; uma reimportada a 1×, 1,5× ou 2× lê no
sítio certo sem ninguém tocar no teste. O fator sai da imagem contra a tabela,
que são duas fontes — nunca de uma constante, que seria o espelho.

⚠️ **E A JANELA E O MÍNIMO ESCALAM POR EXPOENTES DIFERENTES.** O raio de uma
prova é uma DISTÂNCIA e cresce com o fator; o mínimo de pixels dentro dela é uma
CONTAGEM e cresce com o **quadrado**. Escalar só o raio pediria os mesmos 40 px
numa janela 2,25× maior, e a prova passaria de graça.

### O D20 reprovava o mapa CERTO, e sempre pôde

Corrigida a escala, sobrou **uma** falha: a rota do camião a cair em calçada no
mapa do pátio. Não era. Ali a rota atravessa a fronteira entre o pavimento do
pátio (`#ced4d7`) e o asfalto (`#49535b`), e o pixel de antisserrilhado dessa
fronteira sai a `#b1b8bc` — que fica a **3/255** da calçada (`#aeb8bf`), dentro
da folga de 4 que o `_mesma_cor` dá ao próprio antisserrilhado. Conferido dos
dois lados: no mapa **sem** pátio a mesma coordenada é `#49535b` puro em toda a
vizinhança.

⚠️ **É a regra do `CLAUDE.md` *"casar hexadecimal exato só serve em tinta
chapada"* com a roupa trocada.** A rua É chapada — mas a **fronteira entre duas
tintas chapadas não é**, e o valor por que ela passa pode calhar na banda de uma
**terceira** cor da paleta. A escala não criou o defeito: mudou onde a fronteira
cai e destapou um que estava lá desde que o bloco existe.

O D20 era o último bloco raster do projeto a provar por pixel único — o D17 e o
D24 já tinham aprendido a perguntar **quanto desenho há à volta do ponto**. Agora
conta numa janela de 7×7 de tela e exige 9 px (18%).

### Os dois defeitos injetados, e o número de cada um

Cada um regerando os dois mapas **e reimportando**, com a base a passar entre
eles e o original guardado com `cp` e nunca com `git`:

| defeito | asserção | medido | mínimo | o mapa certo dá |
|---|---|---|---|---|
| a calçada do cotovelo volta a ser desenhada depois do asfalto (`013`) | calçada | **42** | 20 | **5** |
| a duna atravessa o passeio **e** é desenhada por cima da rua | areia | **66** | 20 | **0** |

⚠️ **O PRIMEIRO CORTE QUE ESCOLHI REPROVAVA POR UM PIXEL — 42 contra 41.** A
banda medida vai de 5 (legítimo) a 42 (defeito) e eu tinha posto o corte colado
à ponta do defeito, o que é a mesma doença do *"portão alimentado com fumaça"*:
um teto rente fica verde ou vermelho por acaso na primeira vez que alguém mexer
no mapa. O corte foi para o meio da banda — 4× de folga do lado legítimo e 2,1×
do lado do defeito.

⚠️ **E O SEGUNDO DEFEITO SÓ PEGA COM AS DUAS METADES.** Adiar a ordem sozinha
não põe areia na pista (o recuo do mundo segura-a); deslocar a duna sozinha
também não (a rua é desenhada depois e cobre-a). São **duas proteções
diferentes**, não uma regra duplicada — e por isso o defeito que aperta a
asserção tem de quebrar as duas. Três tentativas antes disso não pegaram, e cada
uma por uma razão que fica escrita:

- a ordem sozinha — o recuo segurava;
- as **manchas secas** com o sinal trocado — elas saem a `opacity="0.45"`, e uma
  cor misturada nunca casa com um tom publicado: **a asserção da areia só apanha
  areia OPACA**;
- a duna sozinha — a rua desenhada depois cobria-a; o que reprovou foi o **D27**,
  com os bichos sobre areia, que é a armadilha *"confira QUAL guarda reprovou"*.

E antes de dar a janela por culpada, mediu-se o contrário: com o mínimo em **1**
— mais sensível do que o pixel único que lá estava — a asserção da areia continua
a dar 0 nesses três casos. **A limitação é anterior a esta sessão e não veio da
mudança.**

## 8. O que NÃO foi feito

- **a alavanca B** (props a 768) e **a C** (o viewport) — §7 do plano;
- **mipmaps** — §6, não há aliasing que os pague;
- **o raster da água a 1080** (`SAIDA` no gerador). Ele é 43% da janela e é a
  única parte do mapa cuja precisão não está no arquivo. Subi-lo mudaria os
  bytes dos quatro SVG que o CI compara e multiplicaria por 2,25 os 518 mil
  pixels que o campo de distância já mede em cada um dos quatro mapas — é
  sessão própria, com o custo de CI medido antes;
- **o detalhe que a resolução destrava** — a tabela da Etapa 7 continua inteira.
  **Resolução sozinha compra nitidez, não detalhe**, e esta sessão comprou
  nitidez.
