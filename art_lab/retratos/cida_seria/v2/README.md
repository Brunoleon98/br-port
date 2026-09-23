# Dona Cida, séria — v2 da cabeça REDONDA

**Estado: candidata, à espera do Bruno** — ao lado da QUADRADA melhorada
(`../quadrada_v1/`), que ele pediu para escolher entre as duas qual modelo
melhorar. Nada daqui está no jogo: o PNG de
`brport_vs/art/props/retrato_cida_seria.png` continua a ser o de
`blender/brp_porto.py`.

**Base:** `main` em `d9ab39e` (o merge do #79, que trouxe a v1).

## De onde vem

O veredito do Bruno sobre a v1 (23/09): rejeitou aquela cabeça como estava,
marcou os quatro defeitos que a leitura apontou — **nariz e boca** (ainda um
bigode), **tronco** (um balão com calombos), **gola** (dois algodões) e
**cabelo e lápis** (um capacete com espetos, e o lápis a flutuar) — e pediu
para **«melhorar o modelo como um todo»**. A v2 é essa resposta: o mesmo
estúdio, a mesma câmera, a mesma paleta e o mesmo AgX, com a geometria refeita.

| Defeito da v1 | O que a v2 faz |
|---|---|
| a sombra do nariz caía na boca, e a boca era uma barra grossa | o nariz é uma peça à parte que **não projeta sombra**; a boca é uma curva fina (0,016) que afila nas pontas |
| o tronco era cinco elipsoides fundidos, sem ombro | uma malha por **anéis de superelipse**: o trapézio desce do pescoço até um ombro macio, e o braço cai a direito para fora do quadro |
| a gola eram dois discos | duas **abas com ponta**, pousadas no peito ponto a ponto por raio, mais o **pé** da gola à volta do pescoço e três botões |
| o cabelo era uma bola cortada por um plano, com três tubos espetados | uma **casca tirada da própria cabeça**, colada ao crânio, com a linha do cabelo em arco e 22 **sulcos** penteados até ao coque |
| o lápis flutuava 0,10 fora da orelha | deitado **por cima da raiz da orelha**, contra o cabelo, com a ponta à frente e o grafite à vista |
| e o resto | a cara perde os calombos (uma massa só para as bochechas, suavizada antes da subdivisão); a pálpebra sobe (a v1 lia sonolenta); as sobrancelhas afilam; os óculos ganham hastes; a blusa, a gola e o cabelo perdem o ruído de desgaste, que num tecido lia como mancha |

## Como se refaz

```sh
pip install "bpy==4.5.0"          # Python 3.11
python3.11 art_lab/retratos/cida_seria/v2/gerar_retrato_cida_v2.py art_lab/retratos/cida_seria/v2
PREVIA=1 python3.11 ...           # 384 px e 16 amostras, para iterar a forma
```

~32 s ao todo, **19,2 s de render** (a v1 levava 21,4 s; o retrato de hoje
~13 s). ⚠️ O PNG não é byte-reprodutível — o denoiser varia ±2/255 e o Blender
carimba a data (`CLAUDE.md`, Arte); quem pergunta "mudou?" é
`tools/comparar_props.py`.

## Medido

| | hoje | v1 | v2 |
|---|---|---|---|
| busto em x (a caixa mostra 101..667) | 131..636 | 151..616 | **143..624** |
| topo do cabelo | 16 px | 15 px | **15 px** |
| brilho no olho (lum. máx.) | — | 234 | **234** |
| alfa a 0 ou 255 | 99,2% | 99,2% | **99,3%** |

A cabeça continua a valer 60% da altura do quadro, e o tronco sai pela borda
de baixo, como numa fotografia.

## As tentativas, e o que cada uma ensinou

Tudo está em comentário no script, junto da linha que corrige:

1. **a primeira prévia saiu com o tronco colado ao queixo e os ombros
   quadrados e altos** — um bloco verde sem pescoço. A câmera de cima esconde
   o pescoço atrás do queixo: o decote tem de descer para se ver algum;
2. **sobrancelhas com a ponta de dentro mais baixa leram ZANGADAS**, e
   «retas» mede-se na imagem: a ponta de dentro está mais à frente na cara, e
   o que avança desce — ela sobe na tabela para sair à altura das outras;
3. **a linha do cabelo feita a apagar vértices saiu SERRILHADA** — a escada
   dos triângulos da malha, à vista na testa. A casca passou a ENTRAR na pele
   numa faixa estreita, e a borda é a interseção de duas superfícies lisas;
4. **as abas da gola que subiam pelo pescoço esticaram-se em listras**: a
   superfície fica a pique e o retalho estica. Quem sobe é o pé, à parte;
5. **as bochechas custaram três formas**: na v1 deixavam uma bossa cada, a
   ±0,30 com raio 0,40 a cara voltou à PERA, e mais acima saíram duas papadas
   dos lados da boca. Uma massa só, larga, funde-se com o ovo sem vinco;
6. **o lápis pousado pela tangente da cabeça atravessou a orelha** — ela é
   uma bossa, não o casco convexo —, e só se via a ponta de trás, a espetar
   do cabelo como um pauzinho;
7. **a posição da boca também se lê na imagem**: a 0,48 e a 0,42 do caminho
   nariz→queixo ela saiu a dois terços dele na tela (o queixo recua); ficou a
   0,30, e sem a sombra do nariz não cola a nada;
8. **o coque no alto da cabeça encolhia a cara**: o enquadramento põe a
   cabeça COM o coque a 60% do quadro, e um coque alto rouba altura à cara.

## Limitações — o que esta versão NÃO resolve

- **A gola sai acinzentada**: o `#eef2f5` passa pelo AgX a ~191. É a decisão
  AgX × Standard (plano de arte §7.1 e P6), que continua a ser do Bruno.
- **A pele é um tom só**: sem rubor nem variação; os sulcos do cabelo são
  regulares (22 meridianos), e a 768 lêem um nada mecânicos — na caixa do
  telefone lêem como cabelo penteado.
- **É uma expressão só.** As outras duas (preocupada, contente) e a pose de
  cada uma ficam para depois de o Bruno aprovar a direção.
- ⚠️ **E a pergunta da oficina continua de pé**: o `Retratos.gd` diz que os
  retratos têm de combinar com o `trabalhador_retrato` do rodapé, que é de
  caixas, e o Sr. Ribeiro e o Arlindo também são. O Bruno deixou-a para
  depois da v2.

## Arquivos

| Arquivo | O que é |
|---|---|
| `gerar_retrato_cida_v2.py` | o script (hash em `sha256.txt`) |
| `retrato_cida_seria.png` | o PNG 768×768 |
| `prancha_hoje_v1_v2.png` | hoje, a v1 e a v2 na caixa do telefone (168×228) e a 50% |
| `jogo_boletim_v2.png` | a foto do JOGO com a v2 (tiro `boletim` da bateria, 720×1280) |
| `jogo_boletim_hoje_vs_v2.png` | o cartão do boletim, hoje e com a v2, lado a lado |

## A prova no jogo

Numa cópia da árvore (`git archive HEAD`) com SÓ este PNG trocado, `--import`
e a bateria inteira (`tools/capturar_evidencia.sh`, semente e passo fixos),
contra a bateria de outra cópia da árvore de hoje, comparadas em **RGB**:

- **mudou 1 foto em 31** — o `boletim`, o único tiro onde a Dona Cida aparece
  com a cara `seria`;
- **e só dentro de uma caixa de 100×149 px** (x 158..258, y 755..904 da
  captura), que é a caixa do retrato — a mesma da v1;
- a mesma foto dos dois lados dá zero exato, e as outras 30 saíram iguais nas
  duas corridas: a bateria não tem ruído próprio neste par, e VÊ o retrato,
  porque o `boletim` mudou.

⚠️ **E a mesma foto mostra a pergunta da oficina**: o cartão do trabalhador,
no rodapé, continua a ser o boneco de caixas.
