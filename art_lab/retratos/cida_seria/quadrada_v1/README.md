# Dona Cida, séria — QUADRADA v1: o kit de caixas, melhorado

**Estado: ESCOLHIDA como modelo pelo Bruno (24/09), e ajustada na `../quadrada_v2/`** — ele pediu mudanças no cabelo, nos óculos, no tronco e no rosto antes de ir para o jogo. Fica aqui como registo. Nada daqui está no jogo: o PNG de
`brport_vs/art/props/retrato_cida_seria.png` continua a ser o de
`blender/brp_porto.py`.

**Base:** `main` em `d9ab39e` (o merge do #79), mais a v2 redonda
(`../v2/`), de onde este script importa o raio, o enquadramento e os materiais.

## De onde vem

Com a v2 redonda à frente dele, o Bruno pediu (23/09) *«uma versão melhorada
da Dona Cida quadrada, para ver qual modelo escolho para melhorar»*. Esta é a
outra metade dessa escolha: continua na **oficina de caixas** — prismas
oitavados, placas na face, sombreado chapado e o `chanfrar()` do kit, a mesma
do `trabalhador_retrato` do rodapé — e refaz o que no retrato de hoje não lê.

**Para as duas se compararem só pela FORMA**, a quadrada partilha com a v2 tudo
o resto: o estúdio (câmera, rig, paleta, AgX), o enquadramento medido (a cabeça
com o coque a 60% do quadro), a blusa, a gola e o cabelo sem ruído de desgaste,
o brilho no olho, a gola de pontas com botões e o lápis por cima da orelha.

| No retrato de hoje | Na quadrada |
|---|---|
| a cabeça é uma coluna de 174 × 148 — a cara de um **moai**, com o queixo vazio | 156 × 158: quase tão alta quanto larga, a forma LARGA dela |
| os olhos são um quadrado branco com um quadrado preto — lê como **robô** | branco, íris castanha, pupila, **brilho** de emissão, pálpebra e pestana, em placas |
| o cabelo é um **vaso**: uma franja-cinta à volta e uma cúpula dentro, com o coque em cima como tampa | uma calote baixa em rampa, cinco **mechas** contínuas da testa até ao coque, e o coque atrás, em dois andares |
| o tronco é um **pedestal** oitavado de tampo chato, com um cubo branco por gola | um tronco por anéis oitavados, com o trapézio a descer até um ombro chanfrado, a gola de duas pontas, o pé da gola e três botões |
| o nariz é uma placa de sombra em «T», a boca uma barra de 12 | um nariz em caixa pequena que não projeta sombra, a boca a 5 com lábio por baixo |
| o lápis sai de lado, a flutuar | encosta na raiz da orelha, com a ponta à frente |

## Como se refaz

```sh
pip install "bpy==4.5.0"          # Python 3.11
python3.11 art_lab/retratos/cida_seria/quadrada_v1/gerar_retrato_cida_quadrada_v1.py art_lab/retratos/cida_seria/quadrada_v1
PREVIA=1 python3.11 ...           # 384 px e 16 amostras
```

~15 s ao todo, **13,8 s de render** (a v2 leva 19,2 s; o retrato de hoje
~13 s). ⚠️ O PNG não é byte-reprodutível (o denoiser e o carimbo de data do
Blender); quem pergunta "mudou?" é `tools/comparar_props.py`.

## Medido

| | hoje | quadrada | v2 |
|---|---|---|---|
| busto em x (a caixa mostra 101..667) | 131..636 | **144..623** | 143..624 |
| topo do cabelo | 16 px | **15 px** | 15 px |
| brilho no olho (lum. máx.) | — | **234** | 234 |
| alfa a 0 ou 255 | 99,2% | **99,4%** | 99,3% |

## As tentativas, e o que cada uma ensinou

Tudo em comentário no script, junto da linha que corrige:

1. **as mechas pousadas na frente a pique da calote caíram na testa como uma
   FRANJA**: a frente da calote passou a ser uma rampa para trás;
2. **mechas em ripas soltas, uma caixa por troço, leram como TELHAS** — nas
   dobras abriam-se frestas e sobreposições. São faixas contínuas, com os
   troços a partilhar os vértices da dobra;
3. **uma pala clara na linha do cabelo, com duas asas nas têmporas**, não
   cedeu a nada no cabelo: a calote justa ao crânio, as quinas mais curtas e
   uma rampa só deram a mesma imagem. Três prévias, cada uma sem uma peça do
   cabelo, mostraram a mesma pala — **era pele**: a quina de cima do crânio de
   tampo chato furava a calote em rampa. O crânio passou a cúpula facetada, por
   dentro dela. ⚠️ **Quando uma correção não muda NADA na imagem, a primeira
   pergunta é se se está a mexer na peça certa** — esconder peça a peça
   responde em três prévias;
4. **a 16 × 22 o nariz saiu uma barra** — com a base, o «T» de hoje;
5. **a 32 × 20 o olho sumia na caixa do telefone**: subiu até ao limite da
   parte plana da cara.

## Limitações — o que esta versão NÃO resolve

- **As mechas da frente ainda lembram uma franja** vistas de perto: a rampa
  começa na linha do cabelo, e nesta câmera a face que sobe para trás mostra-se
  inteira. Na caixa do telefone lêem como cabelo puxado.
- **O tronco são planos grandes** — a oficina de caixas é assim; os botões e a
  gola são o que o desenha.
- **A gola sai acinzentada pelo AgX**, como na v2 (a decisão AgX × Standard
  continua a ser do Bruno).
- **Uma expressão só.** As outras duas (preocupada, contente) usam a pose da
  tabela `_CARAS`.
- **O que a escolha arrasta.** Se ficar a quadrada, a oficina não muda: o Sr.
  Ribeiro, o Arlindo e o trabalhador do rodapé já são de caixas, e recebem as
  mesmas melhorias (olho, proporção, tronco). Se ficar a redonda, os outros
  dois seguem-na, e fica a pergunta do trabalhador.

## Arquivos

| Arquivo | O que é |
|---|---|
| `gerar_retrato_cida_quadrada_v1.py` | o script (hash em `sha256.txt`) |
| `retrato_cida_seria.png` | o PNG 768×768 |
| `prancha_hoje_quadrada_v2.png` | hoje, a quadrada e a v2 redonda, na caixa do telefone (168×228) e a 50% |
| `jogo_boletim_quadrada.png` | a foto do JOGO com a quadrada (tiro `boletim`, 720×1280) |
| `jogo_boletim_quadrada_vs_v2.png` | o cartão do boletim com a quadrada e com a v2, lado a lado |

## A prova no jogo

A mesma receita da v2: uma cópia da árvore (`git archive d9ab39e`) com SÓ
este PNG trocado, `--import` e a bateria inteira (`tools/capturar_evidencia.sh`,
semente e passo fixos), contra a bateria da árvore de hoje, comparadas em
**RGB**:

- **mudou 1 foto em 31** — o `boletim`, o único tiro onde a Dona Cida aparece
  com a cara `seria`;
- **e só dentro da caixa de 100×149 px do retrato** (x 158..258, y 755..904),
  a mesma da v2;
- a mesma foto dos dois lados dá zero exato, e as outras 30 saíram iguais.

No cartão, a quadrada é da mesma oficina do trabalhador do rodapé; a v2
redonda, ao lado, não é — que é a pergunta da oficina, do outro lado.
