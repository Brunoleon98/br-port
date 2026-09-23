# 029 — Os props a 768, e a moldura vazia que se paga junto

**16/09/2026.** A **alavanca B** do item *"A resolução dos assets"* da §7 do
plano v3. A **A** (o mapa a 1,5×) fechou em 14/09 na `025`; a **C** (o viewport)
está medida e **não dá um pixel**, e não foi tocada.

`RESOLUCAO` passou de **512 para 768** em `tools/gerar_props_iso.py`, que é a
câmera que os quatro estúdios `brp_*` importam — logo os **69 assets** do
catálogo (61 em `art/props`, 8 em `art/brp`) foram regerados.

**A projeção, as âncoras, a pegada e o `GameState.gd` ficaram intactos.** A
verificação do próprio gerador fecha em 0,7 px: *tabuado esperado 138 px de
tela, medido 138,7*.

---

## 1. São DOIS números, e confundi-los seria não mudar nada

O `ESCALA_ORTO` estava escrito a partir do `RESOLUCAO`. Assim os dois sobem
juntos: a câmera afasta-se na mesma proporção em que o quadro cresce, o prop
sai do **mesmo tamanho em pixels** com 256 px de moldura vazia a mais, e a
alavanca entrega 2,25× de VRAM em troca de coisa nenhuma.

Hoje são dois:

| | Valor | O que é |
|---|---|---|
| `RESOLUCAO_TELA` | **512** | o quadro em COORDENADA. `Main.tscn`, `Dock.tscn`, a tabela de âncoras e o teste de design leem este. **Não se mexeu.** |
| `RESOLUCAO` | **768** | o quadro em PIXEL. Só ele subiu. |
| `FATOR_RES` | **1,5** | derivado; toda medida em pixel do PNG passa por aqui |

`ESCALA_ORTO` sai do primeiro, então a câmera enquadra o mesmo volume de mundo
e os 768 px caem todos dentro do desenho.

**Quem desfaz a diferença na tela**, e é a mesma linha que os três nós de mapa
levaram na `025`:

| Quem mostra | Como |
|---|---|
| **31 `TextureRect`** (27 em `Main.tscn`, 4 em `Dock.tscn`) | `expand_mode = 1` — o rect fica com 512, a textura carrega 768 |
| **9 `Sprite2D`** (as seis cenas de fauna) | `scale`, escrita pelo `Fauna.gd` a partir da própria textura |
| toda régua que leia `get_used_rect()` | `PropIso.escala()` / `PropIso.desenho()`, novo, num lugar só |

---

## 2. ⚠️ A ALAVANCA B NÃO REDESENHA NADA — e o item previa que sim

O plano dizia, com todas as letras, que *"os props são desenhados nas unidades
da SAÍDA"*, logo todo número em pixel do gerador teria de ser varrido, e que a
armadilha dos cinco números de 05/09 valia aqui.

**Medido: não vale.** A geometria do gerador está em unidades de MUNDO — o
`chanfrar()` usa 0,020, o `TABUA` 0,30, o ruído idem —, e os *"31 px na tela"*
dos comentários são OBSERVAÇÕES do que esses valores produzem, não entradas.
Com o `ortho_scale` parado, o mesmo mundo é amostrado mais fino.

A prova é o `comparar_props.py`, que reduz os dois lados a 16×16 e por isso é
cego à resolução. Comparando a leva de 512 com a de 768:

```
51 props de mapa      máximo 0,0059
um pixel de desloc.          0,022   (a calibração da ferramenta)
um prop trocado              0,42
```

É a mesma razão estrutural pela qual a A também não encontrou a armadilha, e o
que sobra é a regra: **antes de varrer constantes por causa de uma mudança de
escala, pergunte se o que mudou foi o DESENHO ou só a amostragem dele.**

O que a alavanca envelheceu foi o **outro lado** — os números de quem MEDE o
PNG: `MEIO_QUADRO` (256 na cena, 384 na textura), o pivô da lança, a régua da
pessoa de 15 px, o `D29_LARG_MIN`, o `ZOOM` das duas folhas de contato.

---

## 3. ⚠️ E OS QUATRO PROPS QUE MUDARAM DENUNCIARAM GEOMETRIA DEGENERADA

Dos 61, quatro passaram o limiar — três retratos do Sr. Ribeiro (0,08) e um do
Arlindo. A **gravata** e a **camisa** do Ribeiro estavam ambas em `fora = 0`
no `_no_peito()`: duas caixas a disputar a mesma lasca de espaço à frente do
peito, com o Cycles a resolver o empate por amostra.

A 512 os 64 samples misturavam as duas num vermelho plausível. A 768 o empate
**passou a desenhar-se**: a gravata saiu partida ao meio, escura em cima e rosa
lavado em baixo, com uma costura horizontal a direito.

O defeito é de 01/09 e nenhuma das cinco suítes o via. Quem o apanhou foi a
régua que compara LEVAS, ao dizer que quatro mudaram enquanto 57 não mudaram.

`_no_peito()` ganhou uma `camada`, e a gravata, o nó e o lenço ganharam a sua.
**Subir a resolução não cria geometria degenerada: tira-lhe o disfarce.**

O quarto — o vão sob o queixo do Arlindo — resolve-se mais nítido e não é
defeito diagnosticável: fica **anotado para o olho do Bruno** (gate A5), sem se
lhe tocar na geometria.

---

## 4. O CUSTO, que ninguém tinha medido

| | 512 | 768 | Δ |
|---|---|---|---|
| PNG no repositório (61) | 3.764.269 B | 7.987.548 B | +112% |
| `.ctex` importados | 1.709.318 B | 3.445.640 B | +102% |
| **`.pck` do export Android** | 4.415.560 B | 6.282.820 B | **+1.867.260 B (+42,3%)** |
| **VRAM RGBA8 dos props** | 63,96 MB | 143,92 MB | **+79,95 MB (+125%)** |
| render de um prop (`galpao`, emparelhado) | 9,31 s | 20,72 s | 2,23× |

Os 25 props do gerador levam **4m55s**; o catálogo inteiro, ~17 min.

### E o APK e o `brport-web`, lidos do CI

O `dl.google.com` responde 403 aqui, então o export do APK só se verifica no CI,
que corre a cada push no `main` e a cada *pull request*. O **antes** saiu da
corrida 35143708422 (sobre o commit que é a base desta branch) e o **depois** da
35166240746, a primeira do PR 54:

| artefato | antes (512) | depois (768) | Δ |
|---|---|---|---|
| `brport-apk` | 31.607.335 B | 33.476.268 B | **+1.868.933 B (+5,91%)** |
| `brport-web` | 13.799.272 B | 15.671.290 B | **+1.872.018 B (+13,57%)** |
| `.pck`, medido aqui | 4.415.560 B | 6.282.820 B | +1.867.260 B (+42,29%) |

⚠️ **E O `.pck` MEDIDO AQUI PREVÊ O APK, o que faz dele a régua de custo deste
projeto.** Os três crescem os MESMOS ~1,87 MB: o delta do APK é 1,0009× o do
`.pck` e o do web 1,0025×, ou seja o `--export-pack Android` deste contêiner
responde à pergunta do pacote com **0,09% de erro** e sem esperar uma corrida.

⚠️ **E A MESMA CONTA TEM TRÊS PERCENTAGENS, das quais só uma é a do jogador.**
+42,29% no `.pck` soa a alarme e é verdade; no APK que alguém descarrega são
**+5,91%**, porque o APK é sobretudo o binário do Godot e o `.pck` é um sexto
dele. Ao citar o custo de um asset, diga contra QUE denominador — a mesma
mudança parece sete vezes maior no `.pck` do que no download.

⚠️ **E 89,6% DESSE QUADRO É MOLDURA VAZIA.** Medido nos 61: o desenho ocupa
**10,4%** do quadro. Só os dez retratos enchem mais de metade dele; os 51 props
de mapa ocupam de 0,04% (o poste) a 7,4% (o píer n1). Dos 143,92 MB de VRAM,
cerca de **129 MB são transparência** — e era assim antes, com 57 dos 64 MB.

---

## 5. O PORTÃO, e o que ele diz

O portão é o do bote da `024`: *se a captura não mostrar diferença que se veja
no telefone, pare e registe a medição*. A bateria é travada a 720×1280, onde a
textura maior é reduzida de volta pela GPU, então a medição honesta é a
**1080×1920** — o `tools/medir_nitidez_captura.py`, novo, com a mesma métrica da
`025` (pico do gradiente acima de 6/255 de luminância).

A máscara sai da DIFERENÇA entre as duas capturas, dilatada de um pixel: o mapa
não mudou e ocupa quase toda a janela, e medir o quadro inteiro afogaria o ganho
— a armadilha que a `025` teve com o raster da água. Calibrada nas duas voltas
que o `CLAUDE.md` exige: o mesmo arquivo dos dois lados dá máscara VAZIA e 0,00
em tudo; um par que se sabe diferente dá 29,4% da janela.

**Onde os props estão:**

| | inicio | porto | pesca |
|---|---|---|---|
| pico do gradiente | +27,3% | **+31,5%** | +27,7% |
| energia acima do piso | +37,5% | +47,9% | +38,1% |
| muda acima do piso de Weber | 14,4% | **18,7%** | 14,9% |

**Na janela inteira:** pico +2,7% / +4,2% / +2,8%; muda **0,67% / 1,56% / 0,71%**.

**A diferença vê-se, e não é subtil.** No recorte a 3× do `porto`, a treliça do
guindaste passa de um borrão laranja a diagonais separadas com os vazados
abertos; as balaustradas do cargueiro passam de uma mancha cinzenta a
balaústres contados; os caixotes do pátio deixam de ser blocos. **O portão
passa.**

---

## 6. ⚠️ MAS O PREÇO POR PIXEL VISÍVEL É 15 A 27 VEZES O DA ALAVANCA A

É a leitura que este item existia para produzir, e ela só aparece ao lado da A:

| | janela que muda | `.pck` | VRAM | KB por ponto | MB de VRAM por ponto |
|---|---|---|---|---|---|
| **A** — o mapa (`025`) | 5,12% | +412 KB | +9,89 MB | **80** | **1,93** |
| **B** — os props | 1,56% | +1.867 KB | +79,95 MB | **1.197** | **51,2** |

E a razão está medida, não suposta: **a resolução paga-se no quadro inteiro e
entrega nos 10,4% que têm desenho.** A A não tinha esse problema porque o mapa
é uma janela cheia de desenho.

**O que torna a B barata é CORTAR O QUADRO, e isso é item próprio.** Um quadro
ajustado ao desenho, com a âncora publicada por prop em vez de ser o centro,
derrubaria a VRAM ~10× — e derrubaria também os 64 MB de hoje. Mexe no contrato
"o centro do quadro é a origem do mundo", que é o que o `PropIso`, o teste de
design, os 31 `offset` e a tabela de âncoras leem. **Não se faz de passagem.**

**A decisão de PAGAR ou não os 80 MB é do Bruno**, e é por isso que este
documento sai com os dois lados medidos em vez de com um veredito.

---

## 7. A guarda nova — D31

Nada perguntava se quem MOSTRA um prop reconcilia os pixels da textura com as
coordenadas do nó, porque até 16/09 não havia o que reconciliar. O **D31**
percorre a árvore do `MapaWrap` e exige, em cada `TextureRect` e em cada
`Sprite2D` que mostre arte de `art/props/`, que o nó ocupe as 512 coordenadas e
que a textura seja um múltiplo coerente delas — 86 asserções em 43 nós.

⚠️ **A varredura é do `MapaWrap`, e não da cena.** A primeira versão percorria
tudo e reprovou o `Retrato` do cartão do trabalhador: ele mostra um PNG de
`art/props/`, mas é arte de INTERFACE, que se mede no tamanho do widget. Um prop
de mapa é o que vive NO mapa.

**Três defeitos injetados, três reprovas, cada uma pela guarda certa:**

| Defeito | O que reprovou |
|---|---|
| tirar `expand_mode = 1` do `Cabeco` | **só** o D31 — *"o nó ocupa 768x768"*. Nenhuma outra guarda o via: as de âncora leem `no.position`, que não se mexe |
| `_escala_png = Vector2.ONE` no `Fauna.gd` | o D31 nos nove `Sprite2D` **e** o D25 nas seis larguras — a sobreposição está escrita no bloco |
| `cabeco.png` a 700×700 | **só** a asserção do múltiplo coerente |

---

## 8. ⚠️ E A PESSOA ENCOLHEU UM PIXEL SEM O DESENHO MUDAR

`get_used_rect()` conta todo pixel com alfa acima de ZERO, logo conta a franja
do antisserrilhado — e a franja mede cerca de um TEXEL de cada lado **em
qualquer resolução**, o que em coordenada são dois terços do que era. Medido nos
sete desenhos, nenhum deles alterado:

```
trabalhador  15 -> 21 px (14,00)    gaivota    15 -> 22 (14,67)
tartaruga    14 -> 21 px (14,00)    cachorro   15 -> 22 (14,67)
maria-far.   12 -> 18 px (12,00)    quero-q.   13 -> 19 (12,67)
capivara     17 -> 25 px (16,67)
```

Seis dos sete arredondam para o mesmo número de antes. O sétimo é a pessoa, que
passou a 14 — e com isso a gaivota e o cachorro deixaram de caber nela. **Elas
nunca cabiam:** a 512 as três mediam 15 por EMPATE de arredondamento, e a régua
mais fina só mostrou os 0,67 px que já lá estavam.

⚠️ **E NÃO HÁ RÉGUA QUE DÊ O MESMO NÚMERO NAS DUAS RESOLUÇÕES** — procurou-se
uma. A caixa de alfa>0 conta a franja; a de alfa>0,5 salta 43% na maria-farinha,
cujas patas só chegam a meio alfa a 768; e a largura SUAVE (a soma da cobertura
máxima por coluna) sobe de +1,4% a +11%, tanto mais quanto mais fina for a peça.
Não é ruído das réguas: é DESENHO que não cabia num pixel e passou a caber.
**Uma peça com detalhe subpixel não tem largura única.**

O D25 ficou com um pixel de folga, e está escrito o que fica de fora: ele nasceu
medido contra um defeito de DOBRAR a gaivota (30 px contra 14), e um pixel não
lhe tira nada disso — o que ele deixou de apanhar é um bicho 7% maior do que a
pessoa, que é onde a gaivota e o cachorro já estavam.

---

## 9. O que ficou destravado, e o que continua recusado

A `024` mediu que a régua da forma não separa caixa de redondo abaixo de 24 px
de DIAGONAL DO DESENHO. Esse corte não se mexeu — mas o desenho cresceu 1,5×,
então ele **passou a valer 16 px do desenho de ontem**. O `medir_silhueta_props.py`
não precisou de uma linha: a banda dele é derivada do que mede.

O `D29_LARG_MIN` foi o contrário, e de propósito: a linha de fundo do casco
passou a medir-se em COORDENADA, para os 60 px continuarem a descrever os
mesmos cascos. A régua ALCANÇA agora o bote (63 px de textura), e **isso é uma
linha da tabela do detalhe destravado — outra sessão, com a sua medição.**

E o que **não** se destravou continua a não se destravar, como o item prometia:
as estacas do píer continuam esbeltas, a fauna quase não atravessa o corte de
24 px, e o tosado do casco continua abaixo dos 3 px em que a régua vê curva.

---

## 10. Um aviso de README virou guarda

`gerar_brp.py todos <dir>` despeja os 24 assets no MESMO diretório, e nove deles
vivem em `art/brp`. O `art/brp/README.md` avisa disto por escrito desde que
existe — **e caí nele nesta sessão**, ao regerar o catálogo: oito PNGs de 768
foram parar a `art/props`, onde o `asset_validator.gd` os acharia primeiro e
passaria contente, com as cópias de `art/brp` a envelhecer em silêncio.

Um aviso num README não é uma guarda. O validador passou a reprovar o mesmo
nome em duas pastas — cinco linhas.

---

## 11. E o bloco que imprimia o pivô da lança nunca imprimia

Achado ao ir finalmente LER o número: a condição pedia `"guindaste_lanca" in
alvos` e o catálogo não tem nenhum grupo com esse nome — são `lanca_n1`, `n2` e
`n3` desde que a lança ganhou três níveis. Um `if` que nunca é verdade não dá
erro: a ferramenta corria inteira, saía com 0, e a única linha que DERIVA o
pivô ficou muda. É o *"comentário que diz «lido de X» e não lê X"* em forma de
guarda. Hoje o gatilho é o `lanca_n2` e ele imprime as duas linhas — a do PNG e
a do NÓ, que é a que se copia.

O valor não mudou: `Vector2(293, 187)`, porque o quadro em coordenada é o mesmo.

---

## 12. O que fica medido para quem voltar

- **o antes/depois honesto é a 1080×1920**, e a bateria é travada a 720 —
  `tools/medir_nitidez_captura.py` existe para essa pergunta;
- **o `.pck` mede-se sem templates**: `--export-pack Android` basta. O APK e o
  `brport-web` leem-se dos artefatos do CI, porque o `dl.google.com` responde
  403 aqui;
- **a moldura vazia é 89,6%**, e é o número que decide se a alavanca vale;
- e o `bpy==4.5.0` renderizou os quatro estúdios, **fauna incluída** — o que a
  sessão de 13/09 registou como falha de alocação não se repetiu.

---

⚠️ **Adenda, 23/09 — o corte fechou na `049`, e sem mexer no contrato.** O
importador `texture_atlas` apara a moldura e a margem do `AtlasTexture` repõe
os 768: a VRAM de textura em jogo foi de 235,68 para 64,04 MB e o `.pck`
perdeu 17,4%, com nenhum nó, âncora ou manifest mexido.
