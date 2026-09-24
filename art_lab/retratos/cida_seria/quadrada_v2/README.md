# Dona Cida, séria — QUADRADA v2: o kit de caixas, ajustado

**Estado: AJUSTADA na `../quadrada_v3/`** — o Bruno pediu mais ajustes (cabelo, cores, rosto, corpo) e escolheu Standard nos retratos (24/09). Fica aqui como registo. Nada daqui está no jogo: o PNG de
`brport_vs/art/props/retrato_cida_seria.png` continua a ser o de
`blender/brp_porto.py`.

**Base:** `main` em `d9ab39e` (o merge do #79), mais a v2 redonda (`../v2/`),
de onde o script importa o raio, o enquadramento e os materiais.

## De onde vem

Entre a redonda v2 e a quadrada v1, **o Bruno escolheu a QUADRADA** para
melhorar (24/09) e pediu ajustes antes de ela ir para o jogo, nos quatro
pontos que a leitura da v1 apontava: cabelo, óculos, tronco e rosto.

| Na quadrada v1 | Na quadrada v2 |
|---|---|
| **cabelo:** as mechas da frente lembravam uma franja; o coque de dois andares, um bolo | as mechas **convergem** para o coque (a ponta de trás a 0,30 em vez de 0,52) e **nascem** da calote, afinadas até quase zero na testa; as **têmporas** ganham cabelo e a linha do cabelo passa a arco; o coque é **uma** bola facetada, atrás |
| **óculos:** quatro barras de 4 px à volta de um vão reto — pesavam e tapavam o olho | aro **oitavado** (o redondo das caixas) de 2,5 px |
| **tronco:** três anéis de octógono — planos grandes, uma ombreira | secção de **12 lados** e um ombro de verdade: trapézio, prateleira no alto e a quina redonda do deltoide; a blusa ganha a **carcela** dos botões e um **bolso** com pestana |
| **rosto:** olho de 34 × 22 com a pálpebra a tapar 6 px; um palmo de cara vazia entre a boca e o queixo | cabeça **144 × 158** (o queixo sobe 12); o olho cresce para 38 × 24 até ao limite da parte plana (±59) e a pálpebra só apara 3,5 px; as feições descem para o meio da cara; o queixo ganha volume (uma caixa baixa sem sombra) |

O resto é o da quadrada v1: a oficina de caixas (prismas, placas, sombreado
chapado, `chanfrar()`), o brilho no olho, o nariz em caixa sem sombra, a boca
com lábio, a gola de pontas e o lápis por cima da orelha.

## Como se refaz

```sh
pip install "bpy==4.5.0"          # Python 3.11
python3.11 art_lab/retratos/cida_seria/quadrada_v2/gerar_retrato_cida_quadrada_v2.py art_lab/retratos/cida_seria/quadrada_v2
PREVIA=1 python3.11 ...           # 384 px e 16 amostras
```

~16 s ao todo, **15,2 s de render**. ⚠️ O PNG não é byte-reprodutível (o
denoiser e o carimbo de data do Blender); quem pergunta "mudou?" é
`tools/comparar_props.py`.

## Medido

| | hoje | quadrada v1 | quadrada v2 |
|---|---|---|---|
| busto em x (a caixa mostra 101..667) | 131..636 | 144..623 | **142..625** |
| topo do cabelo | 16 px | 15 px | **15 px** |
| brilho no olho (lum. máx.) | — | 234 | **234** |
| alfa a 0 ou 255 | 99,2% | 99,4% | **99,4%** |

## As tentativas, e o que cada uma ensinou

Tudo em comentário no script, junto da linha que corrige:

1. **a cabeça mais baixa AMPLIOU o busto**: o enquadramento põe a cabeça com
   o coque a 60% do quadro, e encurtá-la 12 fez tudo o resto crescer 11% — a
   primeira prévia saiu com um busto corcunda a comer o cartão. O tronco
   estreitou 10%. ⚠️ **Com o enquadramento medido pela cabeça, mexer na altura
   dela mexe no tamanho de TUDO o que não é cabeça**;
2. **anéis a alargar por igual do pescoço ao braço deram um SINO** — o balão
   da redonda v1, com facetas. Um ombro são três coisas: o trapézio inclinado,
   uma prateleira quase plana e a quina redonda do deltoide;
3. **mechas com 3 px de ponta a ponta acabavam numa aresta que se acendia**, e
   as cinco em fila liam como a borda de uma franja. Afinadas até quase zero na
   linha do cabelo, nascem da calote.

## Limitações — o que esta versão NÃO resolve

- **A rampa da frente da calote ainda acende** numa faixa clara por cima da
  testa: é a face virada para a luz-chave. Na caixa do telefone lê como cabelo
  puxado; de perto, ainda lembra uma franja curta.
- **Um pixel escuro na aba esquerda da gola** (a 768); some na caixa do
  telefone.
- **A gola sai acinzentada pelo AgX**, como nas outras (a decisão AgX ×
  Standard continua a ser do Bruno).
- **Uma expressão só.** As outras duas (preocupada, contente) usam a pose da
  tabela `_CARAS`.
- **O que o aceite arrasta**: a oficina não muda — o Sr. Ribeiro, o Arlindo e
  o trabalhador do rodapé já são de caixas, e recebem as mesmas melhorias
  (olho, proporção por personagem, tronco com ombro, cabelo).

## Arquivos

| Arquivo | O que é |
|---|---|
| `gerar_retrato_cida_quadrada_v2.py` | o script (hash em `sha256.txt`) |
| `retrato_cida_seria.png` | o PNG 768×768 |
| `prancha_hoje_q1_q2.png` | hoje, a quadrada v1 e a v2, na caixa do telefone (168×228) e a 50% |
| `jogo_boletim_quadrada_v2.png` | a foto do JOGO com esta (tiro `boletim`, 720×1280) |
| `jogo_boletim_hoje_vs_q2.png` | o cartão do boletim, hoje e com esta, lado a lado |

## A prova no jogo

A mesma receita das outras: uma cópia da árvore (`git archive d9ab39e`) com
SÓ este PNG trocado, `--import` e a bateria inteira
(`tools/capturar_evidencia.sh`, semente e passo fixos), contra a bateria da
árvore de hoje, comparadas em **RGB**:

- **mudou 1 foto em 31** — o `boletim`, o único tiro onde a Dona Cida aparece
  com a cara `seria`;
- **e só dentro da caixa de 100×149 px do retrato** (x 158..258, y 755..904);
- a mesma foto dos dois lados dá zero exato, e as outras 30 saíram iguais.

No cartão ela é da mesma oficina do trabalhador do rodapé, que é a razão da
escolha.
