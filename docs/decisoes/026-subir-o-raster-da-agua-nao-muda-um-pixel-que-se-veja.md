# 026 — Subir o raster da água não muda um pixel que se veja

**14/09/2026.** O que sobrou da alavanca A (`025` §8), recortado pelo Bruno
como a sessão seguinte: *"o campo de cor da água é um PNG de 720×720 embutido
no SVG, esticado sobre o viewBox de 1080 — são 43% da janela, e a única parte
do mapa cuja precisão não está no arquivo."*

**Construiu-se, mediu-se e NÃO ENTRA.** O portão era o do bote da `024` — *se a
diferença não se vir, pare e registe a medição* —, e ele disparou pelo lado que
ninguém esperava: não pelo custo, que era o suspeito escrito no briefing, mas
pelo **ganho, que é zero**.

---

## 1. O que se fez, para poder medir

O `SAIDA = 720` não se toca: dele sai `LARG = ALT = round(SAIDA / ZOOM)`, que é
o `viewBox` de 1080 e o sistema de coordenadas do mapa inteiro. Quem estava a
720 era só o campo da água, que é o **único desenho deste gerador a viver no
espaço TELA** — todo o resto fala DESENHO. Levá-lo para 1080 é levá-lo para o
espaço de toda a gente: os segmentos de costa passam a sair de `p()` em vez de
`tela()`, o `px_por_unidade` perde o `ZOOM` (40 → 60 px por unidade) e a
`<image>`, que já declarava `width="1080"`, passa a ser 1:1 em vez de esticada.

A geometria não se mexe, e a prova é a **tabela de âncoras: zero linhas de
diferença**.

## 2. O ganho, que é a resposta

`brport_vs/tools/medir_resolucao_mapa.gd`, a régua da `025`, ganhou um **modo
de dois arquivos**: a alavanca A comparava o MESMO arquivo lido a duas escalas,
e aqui o que muda é o arquivo e não a escala — os dois SVG importam a 1,5 e só
o PNG embutido difere, sem reamostragem nenhuma pelo meio.

Na janela do `MapaWrap` (1080×990), os dois mapas base a 1,5:

| região | px | pico antes | pico depois | o que o jogador vê MUDAR |
|---|---:|---:|---:|---|
| tudo | 1.067.131 | 26,38 | 26,38 (−0,0%) | **0,00%** acima de 6/255 |
| vetor | 610.580 | 25,56 | 25,57 (+0,0%) | **0,00%**, \|ΔL\| máx **1** |
| **raster (água)** | 456.551 | 29,73 | **29,71 (−0,1%)** | **0,00%**, \|ΔL\| médio 0,21, máx **3** |

⚠️ **E A RÉGUA É SÓ LUMINÂNCIA, que neste projeto já escondeu uma mudança de
matiz.** Conferido por canal, RGBA, na mesma janela: **máx 4/255**, 0,016% dos
pixels (174) chegam a 3, e **nenhum — zero de 1.069.200 — chega a 6**, que é o
piso de Weber com que este projeto diz que uma peça *some* contra o fundo.

O `.ctex` é `compress/mode=0`, lossless, então o que a régua lê é o que chega à
GPU.

### E o instrumento prova que sabe falar

Um "0,00%" só vale depois de se saber que a ferramenta não está muda — é a
regra do defeito injetado, aplicada a uma régua em vez de a um validador,
porque aqui o número É a conclusão da sessão:

| o que se lhe deu | o que respondeu |
|---|---|
| o MESMO arquivo dos dois lados | 0,00 em tudo, \|ΔL\| máx **0,00** — sem ruído próprio |
| o mapa base contra o mapa do **pátio** | **5,89%** da janela acima do piso, máx **145**, p99 37 |

E o segundo caso confirma a máscara de caminho: contra um mapa mesmo diferente,
a região do RASTER continua a dar 0,01%, porque o que muda entre aqueles dois
arquivos é vetor.

## 3. Por que é zero, e isto era derivável

**Resolução só se paga onde há FRONTEIRA para afiar, e este raster não tem
nenhuma.** Ele é, por construção, uma rampa contínua da distância à costa: as
três bandas de cor interpolam, a espuma é a ponta da mesma rampa (16,8 px de
largura a 40 px/unidade) e o alfa desce a zero continuamente. Tudo o que tem
TRAÇO naquela água — as pedras, a espuma vetorial, os riscos de onda, a linha
de areia — é vetor, e já ganhou na alavanca A.

A `025` §3 tinha isto escrito em prosa: *"não se denuncia como pixelização
porque o que ela desenha é campo CONTÍNUO — um gradiente ampliado continua um
gradiente"*. Medir confirmou a previsão ao ponto.

⚠️ **CONTAR PIXELS RESPONDE À PERGUNTA ERRADA.** "43% da janela" e "2,25× de
informação" são verdadeiros e não querem dizer nada: a pergunta não é quantos
pixels a camada tem, é **que fronteira há dentro dela**. Uma camada pode ser
metade do quadro e não dever nada à resolução.

## 4. O custo, medido na mesma — porque é o que fecha a porta

| | 720 | 1080 | |
|---|---:|---:|---|
| gerar `porto_mapa_iso.svg` | **23,06 / 22,17 s** | **40,60 / 40,96 s** | **1,8×** |
| as duas espumas | 0,05 s | 0,05 s | não levam raster nenhum |
| `porto_mapa_iso.svg` | 2.012.226 B | 2.631.374 B | +619.148 B (+30,8%) |
| `porto_mapa_iso_patio.svg` | 1.984.995 B | 2.604.143 B | +619.148 B (+31,2%) |

⚠️ **As duas voltas alternadas são a medição, e não a primeira corrida.** Solto,
o mesmo comando a 720 deu 18,71 s de manhã e 22–23 s à tarde — 20% de deriva da
máquina, que é mais do que muita diferença que este projeto mede. Tempo compara-
se EMPARELHADO, uma volta de cada, ou compara-se a carga do contêiner.

O passo do CI que regera os quatro mapas mede ~40 s e passaria a ~72 — num job
de ~115 s. **É o preço de repetir, a cada push, uma conta cujo resultado ninguém
vê.**

⚠️ **E O `.pck` ENCOLHE, o que contraria a suposição do briefing.** O pacote
leva o `.ctex` e o `.svg.import`, **nunca o SVG** — conferido: não há um
`viewBox` dentro dele. Logo os 1,24 MB a mais de repositório não chegam ao
jogador, e o que chega vai na direção contrária:

| | 720 | 1080 | |
|---|---:|---:|---|
| `.ctex` do mapa base | 461.210 B | 440.748 B | −20.462 |
| `.ctex` do mapa do pátio | 460.610 B | 441.780 B | −18.830 |
| **`.pck`** | 4.415.176 B | **4.375.880 B** | **−39.296 B (−0,89%)** |
| VRAM | — | — | **igual**: quem fixa as dimensões é o `svg/scale` |

O campo nativo comprime melhor do que o mesmo campo ampliado por bilinear, que
inventa um joelho de derivada a cada 1,5 px. **É dado melhor com resultado
invisível** — e 39 KB de pacote não compram trinta segundos de CI a cada push.

## 5. O caminho a 1080 estava CERTO, e isso também se prova

Para que "não entra" não se leia como "não funcionou": a versão a 1080 foi
conferida contra a **força bruta** — o mesmo campo sem índice espacial nenhum,
todos os ~500 segmentos contra cada um dos 1.166.400 pixels — e sai byte a
byte igual. O índice também foi varrido em blocos de 6, 8, 12 e 16 px, com os
quatro a darem o MESMO PNG: é o que a poda promete, já que ela só descarta
segmento que não pode ganhar e mantém a ORDEM, que é quem desempata.

⚠️ **E O BLOCO DO ÍNDICE É UMA MEDIDA DE MUNDO DISFARÇADA DE PIXEL.** Os 8 px
de hoje são **0,2 unidades** a 40 px/unidade; a 60 px/unidade os mesmos 8 px
cercariam 0,133, e o índice fica fino demais — a varredura dos centros de bloco
cresce mais depressa do que a poda por pixel encolhe. Medido a 1080: 44,0 / 36,8
/ **33,6** / 34,0 s para 6 / 8 / 12 / 16 px, com o fundo da curva exatamente na
mesma janela de mundo de sempre. **Nada a mudar a 720** — os 8 já são esse
número —, mas quem lá voltar leva a conta feita.

## 6. O que fica escrito, e é sobre a ORDEM de medir

⚠️ **UMA PREVISÃO DERIVADA NUMA DECISÃO ANTIGA MEDE-SE COM O MENOR EXPERIMENTO
QUE A TESTA, e não com a tabela inteira.** O briefing mandava medir o CUSTO
primeiro, porque era ele o suspeito de reprovar; e medir o custo pedia gerar os
mapas, varrer o bloco do índice e exportar o pacote — seis gerações e uns
minutos de CPU — antes de a régua responder, em dois minutos, que **o ganho era
zero e o custo não interessava**. A `025` §3 já dizia porquê. Quando a decisão
anterior contém uma previsão de zero, a primeira coisa a fazer é UM mapa e UMA
medição do ganho; a tabela de custo só interessa depois de o ganho existir.

## 7. O que NÃO foi feito

- **a alavanca B** (props a 768) — é onde a armadilha da constante em pixel vale
  de verdade, porque os props são desenhados nas unidades da saída;
- **mipmaps** — `025` §6, não há aliasing que os pague;
- **o detalhe que a resolução destrava** — a tabela da Etapa 7 do plano de arte,
  inteira. **Resolução sozinha compra nitidez, não detalhe**, e este item nem
  nitidez comprou;
- **o campo da água NÃO mudou de espaço.** Continua a ser o único desenho do
  gerador em coordenadas de TELA, e isso continua a ser uma verruga — mas
  arrumá-la custa os mesmos trinta segundos de CI por push, e não paga.
