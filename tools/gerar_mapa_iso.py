#!/usr/bin/env python3
"""
BR Port — gerador do mapa do porto em projeção isométrica.

POR QUE UM GERADOR E NÃO SVG ESCRITO À MÃO
------------------------------------------
Em isométrico cada ponto do chão é uma conta:

    tela_x = CX + (mx - my) * MEIA_LARG
    tela_y = CY + (mx + my) * MEIA_ALT - altura

Escrever isso na mão é onde erro de meio pixel vira píer torto. Aqui o porto é
descrito em coordenadas de MUNDO e a projeção acontece num lugar só. Mudar o
ângulo é mudar duas constantes e regerar, não redesenhar tudo.

AS DUAS ARMADILHAS QUE ISTO RESOLVE
-----------------------------------
1. **A caixa de um plano isométrico é sempre 2:1.** Vale para qualquer formato
   de terreno — um cais comprido e fino projeta a mesma caixa 2:1 que um
   terreno quadrado. Num ecrã 720x1280 isso limitaria o chão a ~360px de
   altura. A saída é gerar o mundo MAIOR que o ecrã e cortar: o mapa transborda
   dos quatro lados e o jogador vê uma janela para dentro dele.

2. **Costa reta empurra as docas para o lado, não para baixo.** Com a costa
   toda no mesmo `mx`, cada doca seguinte anda ~8 unidades em `my`, e como
   `tela_x` depende de `(mx - my)`, elas marcham para a esquerda e saem do
   ecrã retrato. Por isso a costa aqui é em DEGRAUS: cada doca avança também
   em `mx`, e a marcha vira vertical. A regra é `Δmx > Δmy / 3`.

Uso:
    python3 tools/gerar_mapa_iso.py brport_vs/art/porto_mapa_iso.svg
"""

import base64
import collections
import json
import math
import pathlib
import random
import re
import struct
import sys
import zlib

MEIA_LARG = 30
MEIA_ALT = 15            # a razão 2:1 com MEIA_LARG é o que define o ângulo
ALT_CAIS = 26            # altura do cais acima da água
ALT_PIER = 15            # o tabuado fica mais baixo que o cais

# ── O ENQUADRAMENTO: a câmera AFASTA-SE, e o desenho não muda ────────────
#
# O Bruno escolheu `MEIA_LARG = 20` em 03/09, olhando o mapa gerado em três
# larguras. A tentação é escrever 20 aqui em cima e regerar — e ela está
# errada por uma razão que só aparece medindo: **altura, neste arquivo, é
# PIXEL**. O `ALT_CAIS = 26`, o `ALT_PIER = 15`, as paredes da vila, o `h` de
# cada `com_saia`, a largura de cada traço: são todos números absolutos,
# afinados para um mundo em que uma unidade vale 30 px. Baixar só o
# `MEIA_LARG` encolheria a PLANTA e deixaria as ALTURAS onde estavam — o
# porto inteiro esticado 1,5x para cima, que é o defeito que o CLAUDE.md
# regista duas vezes ("em isométrico é a ALTURA que projeta a silhueta") e
# que nenhuma das cinco suítes leria.
#
# Escalar os ~100 literais à mão é a outra armadilha escrita: "encolher um
# prop escala-se no GRUPO, nunca reescrevendo as literais — são trinta
# números e trinta chances de um ficar por escalar".
#
# Então o mundo continua a ser DESENHADO na mesma escala de sempre, num quadro
# maior, e o `viewBox` do SVG encolhe o quadro inteiro para os 720 px que o
# jogo carrega. É exatamente o que afastar uma câmera faz, é uniforme por
# construção — altura, traço, textura e planta juntos — e é uma linha.
#
# Ficam DOIS espaços, e a fronteira entre eles é a função `tela()`:
#
#   DESENHO   o que `p()` devolve. `MEIA_LARG = 30`, quadro de LARGxALT.
#             Todo literal deste arquivo vive aqui, e nenhum deles mudou.
#   TELA      o PNG de SAIDAxSAIDA que o `Main.tscn` carrega, e o espaço em
#             que a tabela de âncoras publica tudo. `MEIA_LARG` efetivo = 20.
#
# Quem lê a tabela de âncoras (o teste de design, o validador de assets) e
# quem posiciona prop no `Main.tscn` fala TELA. Quem desenha, DESENHO.
ZOOM = 2.0 / 3.0         # 30 * ZOOM = os 20 escolhidos em 03/09
SAIDA = 720              # o PNG que o jogo carrega

LARG = ALT = round(SAIDA / ZOOM)

# A JANELA que o jogador vê não é o PNG: o `MapaWrap` do `Main.tscn` tem 720 de
# largura e corta a altura em 660. Compor contra os 720x720 do arquivo é compor
# contra 60px que ninguém vê.
JANELA = (720, 660)


# Costa em degraus. Cada entrada: (my inicial, my final, mx da beira do cais).
# O salto de 4 em mx contra 8 em my é o que satisfaz Δmx > Δmy/3.
#
# ⚠️ O PRIMEIRO E O ÚLTIMO DEGRAU NÃO TÊM PORTO NENHUM, e existem só para o
# mundo TRANSBORDAR do quadro. É o passo 1 da ordem que a medição de 03/09
# fixou: com a câmera a 30 o mundo saía dos quatro lados sozinho, e ao afastá-
# la para 20 as três fronteiras dele entravam no ecrã — 313 px do fundo da
# terra no canto superior esquerdo, 200 px do começo da costa no superior
# direito e 113 px do fim dela no inferior esquerdo. Um degrau de cada lado
# põe as três a ZERO, e dois não trazem nada que se veja (medido:
# `tools/medir_enquadramento.py`).
#
# Eles são praia por construção, e não por escolha: `na_praia()` chama praia a
# tudo o que está fora dos berços, e não há berço nenhum aqui.
DEGRAUS = [(-14.0, -6.0, 2.0),
           (-6.0, 8.0, 6.0), (8.0, 16.0, 10.0), (16.0, 24.0, 14.0),
           (24.0, 34.0, 18.0), (34.0, 42.0, 22.0)]
# O quanto a terra recua para trás. Era -8 e a palavra do comentário era "fora
# do ecrã" — deixou de ser verdade ao afastar a câmera: a -8 a terra acabava
# numa diagonal reta contra água funda, 121 px dentro do canto superior
# esquerdo. Medido, o mínimo é -15; -16 é esse mínimo com uma unidade de folga,
# e o que passa dela é polígono que `no_quadro()` corta de qualquer maneira.
FUNDO_TERRA = -16.0
ALTURA_DE_MATO = 9.0     # px do mapa que um tufo de capim se levanta do chão
COSTURA = 0.06           # sobreposição entre degraus (ver `gerar`)
PIER_ALCANCE = 4.5

# (my inicial, my final, mx da beira) de cada píer — alinhados aos degraus.
PIERES = [(2.0, 4.4, 6.0), (10.0, 12.4, 10.0), (18.0, 20.4, 14.0)]
def _centro_do_porto() -> tuple:
    """O ponto do mundo que fica no meio da janela: o centroide dos berços.

    ⚠️ A LARGURA É METADE DO ENQUADRAMENTO; a outra metade é O QUÊ se vê, e
    ela custou uma volta. Com a câmera a 20 e o centro no ponto que lá estava
    a 30, o quadro saía com o porto encostado à direita e um bloco de mata e
    telhado a ocupar a esquerda inteira — 61% do quadro em terra. A leitura das
    referências é explícita nas duas pontas: *"a água ocupa perto de metade do
    quadro, e a maior parte dela é água aberta sem nada — vazio de propósito, é
    o que dá escala ao porto"*, e *"a cidade é uma FAIXA atrás do cais, nunca
    um bloco"*.

    Centrado aqui, a água mede 52,7% (`tools/medir_enquadramento.py`). E o
    centro é DERIVADO: se um berço mudar de sítio, a câmera vai atrás dele em
    vez de ficar num par de números que ninguém sabe de onde saiu.
    """
    return (math.fsum(b for _a, _b, b in PIERES) / len(PIERES) + PIER_ALCANCE / 2.0,
            math.fsum((a + b) / 2.0 for a, b, _c in PIERES) / len(PIERES))


def _camera() -> tuple:
    """`CX`/`CY` de DESENHO que põem `_centro_do_porto()` no meio da janela.

    ⚠️ ARREDONDADOS, E ISSO NÃO É ZELO — é o que faz o mapa sair igual em toda
    máquina. O CI regera os dois SVG e compara BYTE A BYTE com os versionados,
    e o gerador imprime coordenada com `%.1f`: um erro de 1e-14 no `CX` desloca
    meio pixel na impressão e reprova a corrida inteira.
    
    E foi exatamente o que aconteceu em 05/09. O `sum()` de floats **mudou na
    Python 3.12**, que passou a somar por compensação de Neumaier; o runner do
    CI é `ubuntu-latest` e subiu de versão. Medido, o mesmo arquivo:
    
        3.10 e 3.11   CX = 508.49999999999994
        3.12 e 3.13   CX = 508.50000000000006
    
    Dá 190 linhas de diferença nos dois mapas — `83.3` contra `83.2` — sem
    nenhuma coordenada do mundo ter mudado. O `math.fsum` acima resolve a
    causa (ele é corretamente arredondado em toda versão); o `round` aqui
    resolve a CLASSE do problema, porque congela a entrada de tudo o que vem
    depois num número que as duas somas dão igual.
    """
    mx, my = _centro_do_porto()
    return (round(JANELA[0] / 2.0 / ZOOM - (mx - my) * MEIA_LARG, 6),
            round(JANELA[1] / 2.0 / ZOOM - (mx + my) * MEIA_ALT, 6))


CX, CY = _camera()

# ── AS DUAS PONTAS DE AREIA ──────────────────────────────────────────────
#
# A leitura de composição das cinco referências (`docs/design/referencias/`)
# responde à pergunta que travou esta metade da Etapa 1 durante dois dias, e
# a resposta NÃO é a que se supunha:
#
#   "A areia fica onde o PORTO NÃO ESTÁ — nas duas pontas da costa, para além
#    do primeiro e do último berço, emoldurando o porto."
#
# Nunca entre a água e o cais: nas cinco imagens o cais é pedra descendo
# direto à água, e a praia aparece nos dois cantos do quadro, com pedras e
# coqueiros. Logo isto não é uma faixa ao longo do cais inteiro — são dois
# REMATES, e por isso o porto (avental, asfalto, junta, mancha, enrocamento)
# simplesmente PARA nos dois trechos abaixo.
#
# ⚠️ ONDE PARAR FOI MEDIDO, e não escolhido. As duas pontas não são simétricas
# porque o que está lá hoje não é simétrico. Costa VISÍVEL na janela do jogo
# (720x660) e o que ocupa cada corte:
#
#   corte norte   costa       corte sul    costa       ocupado hoje
#   ─────────────────────     ──────────────────────────────────────────
#     0,4         112 px        21,0       283 px      coqueiro, pilha, palete,
#     0,8         125 px                               empilhadeira, carga
#   → 1,2         139 px        22,0       250 px      empilhadeira, carga
#     1,6         152 px      → 22,5       233 px      empilhadeira, carga
#                              23,0       216 px      empilhadeira, carga
#                              24,0        49 px      carga
#
# O norte para em 1,2 porque 1,6 comeria a carga do pátio e só traria 13 px;
# o sul para em 22,5 porque é onde a conta vira — 22,0 traz 17 px a mais e
# custa mais três props, e 24,0 (o degrau seguinte, que parecia o corte
# natural) **derruba a costa visível de 233 para 49 px**, porque é ali que a
# costa sai do quadro pelo canto de baixo. Seria repetir a mata de 04/09:
# desenhar praia onde ninguém a vê.
PRAIA_FOLGA = (0.8, 2.1)   # cais que sobra além do primeiro e do último berço
PONTA_NORTE = PIERES[0][0] - PRAIA_FOLGA[0]     # 1,2 — daqui para trás, praia
PONTA_SUL = PIERES[-1][1] + PRAIA_FOLGA[1]      # 22,5 — daqui para a frente

PRAIA_PROF = 1.3           # a rampa de areia, em mx, da crista à linha de água
PRAIA_SUBMERSA = 1.15      # o baixio de areia que se vê pela água rasa


def na_praia(my: float) -> bool:
    """Este `my` fica numa das duas pontas, fora do porto?

    Irmã de `_sob_pier`, e usada do mesmo jeito: tudo o que o porto constrói
    ao longo da margem pergunta por ela antes de se desenhar.
    """
    return my < PONTA_NORTE or my > PONTA_SUL


def trechos_de_porto(my0: float, my1: float) -> list:
    """A parte de (my0, my1) onde o porto existe. Zero ou um trecho."""
    a, b = max(my0, PONTA_NORTE), min(my1, PONTA_SUL)
    return [(a, b)] if a < b else []


def trechos_de_praia(my0: float, my1: float) -> list:
    """A parte de (my0, my1) onde o porto NÃO existe. Zero, um ou dois."""
    out = []
    if my0 < PONTA_NORTE:
        out.append((my0, min(my1, PONTA_NORTE)))
    if my1 > PONTA_SUL:
        out.append((max(my0, PONTA_SUL), my1))
    return out


def praias() -> list:
    """(índice, my inicial, my final) de cada ponta de areia. São DUAS.

    ⚠️ FORAM TRÊS, uma por degrau, e essa foi a versão errada. A costa é uma
    ESCADA: entre o degrau 2 e o 3 ela anda 4 unidades em `mx` de uma vez, e
    uma praia por degrau desenhava duas rampas soltas com um degrau verde de
    2,7 unidades entre elas — terra a pique onde devia haver areia a virar a
    esquina. É exatamente a armadilha que o `costa_deslocada` já traz escrita
    um andar acima ("a versão anterior tratava cada degrau como uma faixa
    solta"), e ela mordeu de novo aqui.

    A praia acompanha o CONTORNO, como a faixa de profundidade e o
    enrocamento — e por isso é um trecho de `my` por ponta, degraus incluídos.
    """
    return [(0, DEGRAUS[0][0], PONTA_NORTE),
            (1, PONTA_SUL, DEGRAUS[-1][1] + COSTURA)]


# ── MALHA VIÁRIA E VILA ──────────────────────────────────────────────────
# TUDO AQUI É MEDIDO A PARTIR DA BEIRA DO CAIS, nunca em `mx` absoluto, e a
# razão é a janela: a terra visível é uma faixa que acompanha a costa, e o
# cais avança 4 unidades a cada degrau. Uma rua em `mx` fixo ficaria a 4
# unidades da água no primeiro degrau e a 16 no último — no ecrã, sairia pela
# esquerda antes do terceiro. Medindo do cais, rua e casas acompanham a costa
# e continuam enquadradas do começo ao fim.
#
# A ordem, da água para dentro: avental (manobra colada ao navio), pátio do
# porto (onde estão armazém, escritório e a carga), rua, e a vila atrás dela.
APRON = 1.3              # concreto entre o pátio e a beira do cais
#
# ⚠️ O PÁTIO TEM DE CABER O ARMAZÉM, e é isso que fixa o RUA_RECUO.
#
# Ele valeu 4,3 até 03/09, o que deixava entre o asfalto e o avental uma faixa
# de 1,68 unidades — e o armazém ocupa 3,86 (3,4 de parede mais 0,18 de beiral
# de cada lado) e o escritório 2,76. Os dois foram postos a olho em `Main.tscn`
# e transbordaram: o escritório entrava 0,20 no asfalto e o armazém 0,70, mais
# de metade da largura da rua, ainda por cima com 0,08 pendurados sobre a água.
# A primeira jogada num telefone leu aquilo como "o escritório está em cima da
# rua", que é exatamente o que era.
#
# A conta, para quem mexer nisto outra vez:
#
#     pátio = RUA_RECUO - RUA_LARG - CALCADA - APRON
#
# Com 6,8 o pátio dá 4,18 e o armazém entra com 0,32 de folga. Mexer no APRON,
# na RUA_LARG ou na CALCADA muda o pátio na mesma proporção — e prédio que não
# cabe não dá erro nenhum, só sai por cima do asfalto.
RUA_RECUO = 6.8          # da beira do cais até a face de TERRA da rua

# ⚠️ A RUA TEM DUAS FAIXAS DESDE 07/09, e a largura foi MEDIDA e não escolhida.
#
# ⚠️ E A CONTA ACIMA NÃO É A QUE APERTA. Ela diz que o pátio aguenta o armazém
# até 2,2 de rua, e por isso a primeira tentativa foi a 2,0. Reprovou: quem
# fecha antes é a janela em MY entre o ACESSO AO BERÇO e o COTOVELO, que é onde
# os dois prédios do pátio vivem. Ela vale `my1 - RUA_LARG - CALCADA` menos o
# fim do acesso, ou seja 3,98 - RUA_LARG — e o armazém ocupa 1,987 em `my`:
#
#     rua 1,8 -> janela 2,18   cabe, 0,19 de folga
#     rua 1,9 -> janela 2,08   cabe, 0,09
#     rua 2,0 -> janela 1,98   NÃO CABE, por 7 milésimos
#
# Duas faixas de 0,9 contra um camião de 0,45 — ele ocupa metade da sua faixa,
# que era o ponto.
#
# ⚠️ E EMPURRAR O `RUA_RECUO` NÃO DESTRAVA NADA DISTO, ao contrário do que este
# comentário dizia até 23/09 (`docs/decisoes/047`). A janela é em `my` e o
# `RUA_RECUO` mexe em `mx`: o cotovelo tem a largura da rua em `my` onde quer
# que ela esteja. Acima de 1,9 quem se mexe é o ACESSO AO BERÇO (1,2 em `my`)
# ou o armazém; o pátio em `mx` só aperta aos 2,17. E os "1,48 de folga até à
# vila" eram até ao FUNDO do lote — da calçada à frente da casa há 0,13.
# A rua FICA em 1,8, e é decisão: a 2,0 ela ganha 3,6 px na tela.
RUA_LARG = 1.8
PASSADEIRA_COMP = 0.75   # o quanto a zebra ocupa ao longo da rua
CALCADA = 0.22

# A FAIXA DO LADO DA ÁGUA, que é onde a rua encontra cada acesso ao berço.
#
# Com uma faixa só, andar no meio do asfalto era a única leitura possível. Com
# duas, andar no meio é andar EM CIMA DA LINHA — e a linha é justamente o que
# faz a rua ler como de mão dupla. Sai daqui a `entrada` publicada de cada
# acesso: o meio da faixa de fora, na altura do berço.
#
# ⚠️ ESTE COMENTÁRIO DIZIA que "quem segue em `+my` tem a água à direita", e
# que por isso era a faixa da descida. Na conta, com `mx` e `my` lidos como
# `x` e `y` de um caderno, tem; na tela não, porque a projeção espelha o chão:
# `+my` é para baixo e para a esquerda, e quem desce assim tem a VILA à
# direita. Desde 23/09 os camiões andam pela direita na tela (`docs/decisoes/052`)
# e esta é a faixa de quem SOBE — o retorno vira aqui para o berço, e a ida,
# que desce pela faixa da vila, atravessa-a. O nome ficou, e o número também:
# a boca do acesso é a mesma, e o mapa sai byte a byte igual.
def faixa_do_caminhao(borda) -> float:
    return borda - RUA_RECUO + RUA_LARG * 0.75
# A vila acompanha a rua: 0,13 de folga entre o fundo da calçada e a frente do
# lote, que é o que havia antes e o que mantém as casas fora do passeio.
VILA_RECUO = 8.5         # fundo dos lotes, também medido do cais
VILA_PROF = 1.35         # profundidade da casa em mx
VILA_PASSO = 1.95        # de uma casa à seguinte, em my

C = {
    # ÁGUA TROPICAL — Etapa 1 do plano de arte (A5), em 02/09. Os valores da
    # água RASA saem AMOSTRADOS das imagens de referência, pela tabela de
    # paleta de `docs/design/referencias/README.md`: turquesa #3fb6cf–#57c6dc.
    # O mapa era de mar frio (#4a96b4 rasa, #1d4f68 funda) num jogo cuja
    # referência é o litoral brasileiro, e o README chama a troca de "o ajuste
    # mais barato e mais visível" que existe.
    #
    # ⚠️ TROCAR SÓ O MATIZ ACHATOU A ÁGUA, e foi preciso olhar a captura
    # ampliada para ver. Pôr os dois valores amostrados nas duas pontas
    # (#1b7fa8 funda, #57c6dc baixio) comprimiu a rampa de profundidade de
    # 89,7 para 67,3 de luminância — 25% a menos — e o mar virou uma chapa
    # turquesa. A espuma piorou junto: traço claro sobre água ESCURA
    # contrastava, sobre água CLARA não, e o contraste de Weber caiu de 0,57
    # para 0,46 ainda que a diferença absoluta quase não mudasse.
    #
    # A correção mantém a amostragem ONDE ELA VALE — a referência mostra a
    # água rasa junto ao cais, que é o que ela enquadra — e estende a rampa
    # para baixo na água funda, no mesmo matiz ciano. O #1b7fa8 amostrado
    # passou a ser a faixa MÉDIA. Amplitude final 99,4 (era 89,7 no mar frio),
    # Weber da espuma 0,56 (era 0,57): tropical no matiz, e com mais
    # profundidade do que antes em vez de menos.
    #
    # ⚠️ E O FUNDO DA RAMPA ESTAVA AO CONTRÁRIO ATÉ 17/10 (`124`). O degradê
    # do largo vai de `agua` (perto) a `agua_funda` (longe), e a `agua_funda`
    # era a MAIS CLARA das duas (76,6 contra 65,6): medida no mapa, a água
    # escurecia até ~12 unidades da costa (73) e voltava a clarear ao fundo da
    # tela — o «como se fosse mais raso» que o Bruno viu. Os dois tons
    # trocaram de nome, e a rampa desce do baixio ao largo sem voltar atrás.
    "agua": "#0f5a7d", "agua_funda": "#0d4d6b", "agua_media": "#1b7fa8",
    "agua_rasa": "#3fb6cf", "agua_baixio": "#57c6dc", "espuma": "#eafaff",
    "pedra": "#5a666b", "pedra_clara": "#7c888e", "pedra_media": "#6b767b",
    # AREIA — a metade que faltava da Etapa 1 (A5), em 04/09. O tom seco é o
    # AMOSTRADO da referência (#e8d9a8, tabela de paleta do
    # `docs/design/referencias/README.md`); os outros saem dele por uma rampa
    # de VALOR, e não por gosto, porque a lição de 02/09 vale aqui inteira:
    # cor escolhida só pelo matiz achata a imagem.
    #
    # As razões são as do concreto do cais, que já estão medidas no mapa:
    # `cais_dir` vale 0,67 do `cais_topo` e `cais_esq` 0,80. A face do
    # barranco é a que olha para a água, logo leva a razão do `dir`; o pé
    # lavado pela onda desce mais, porque areia molhada é mesmo escura.
    "areia": "#e8d9a8", "areia_face": "#bda06a",
    "areia_seca": "#d3c08a", "areia_funda": "#a8ddd0",
    #
    # ⚠️ O `areia_funda` NÃO É AREIA, e a primeira versão dele era. Pintar
    # areia (#d8cb9c) por cima da água turquesa a 0,40 dá **#8bc8c2**, que
    # mede 0,06 de Weber contra o baixio — some — e a faixa lavada, pelo mesmo
    # caminho, dava um **#a4b094 azeitona** que na captura lia como lama, não
    # como baixio de areia. Fundo de areia visto pela água não é a cor da
    # areia misturada: é água CLARA e pouco saturada, e por isso este tom é
    # escolhido pelo VALOR (209 contra os 176 do baixio, Weber 0,19) em vez
    # de sair de uma mistura. Mesma lição da água de 02/09, do outro lado.
    # A sombra sob o muro do cais acompanha a água: escura o bastante para o pé
    # do cais continuar a assentar, no matiz novo. No matiz antigo ela lia como
    # uma mancha cinza sobre turquesa.
    "sombra_agua": "#093a52",
    "cais_topo": "#b9c2c8", "cais_dir": "#76828a", "cais_esq": "#8e9aa2",
    "cais_junta": "#9aa5ac", "cais_mancha": "#a8b2b8",
    "asfalto": "#6f7b85", "madeira": "#9a6438", "madeira_dir": "#633d20",
    "madeira_esq": "#7a4d2a", "telhado": "#c85420", "parede": "#f2e6cf",
    # PAREDE CREME, não branco frio. Amostrado: #f2e6cf. O #eef2f5 anterior era
    # azulado, e num porto tropical isso puxava o prédio para o mesmo cinza do
    # cais. As duas faces sombreadas seguem os mesmos fatores do `_sombrear`
    # que as casas da vila já usavam (0,80 e 0,91), para prédio e casa
    # receberem a mesma luz.
    "parede_dir": "#c1b8a6", "parede_esq": "#dcd1bc", "verde": "#3e8f3a",
    "vidro": "#7fb6cc", "porta": "#5a3a20", "terra": "#8a7a63",
    "terra_clara": "#9c8b71", "terra_escura": "#75664f", "poca": "#6b6f66",
    "mato": "#5c7343",
    # A RESTINGA (`127`): o capim-da-praia em dois tons, o verde e a palha,
    # porque o chão dele vai do relvado à areia e nenhum tom só ganha os dois
    # fundos (`arte.md`); e a salsa-da-praia, a rasteira de flor roxa que
    # desce a duna.
    "capim_praia": "#6f8a3c", "capim_palha": "#b2a55e",
    "salsa": "#456f2f", "salsa_clara": "#5f8c3c", "salsa_flor": "#c25ba6",
    # COPA DE ÁRVORE — o par AMOSTRADO da referência (`docs/design/
    # referencias/README.md`: "Vegetação #3e8f3a com #6fbf4e no realce"). Ele
    # não existia como cor: a copa era pintada em `mato` (#5c7343), que é o
    # verde-azeitona do capinzal e não o da folha.
    #
    # ⚠️ E O VALOR AMOSTRADO SOZINHO ACHATARIA A COPA, que é a armadilha da
    # §3 da skill `/arte`. Medido: #3e8f3a tem luminância 119,6 contra 134,3
    # do `solo` em que a árvore pousa — 0,11 de contraste de Weber, e a regra
    # do CLAUDE.md diz que prop da cor do chão onde pousa DESAPARECE. O que
    # separa a árvore do relvado não é o tom do topo, é a SAIA (0,45) e a
    # sombra projetada; o topo amostrado fica onde a referência o pôs.
    "copa": "#3e8f3a",
    "copa_luz": "#6fbf4e",
    "tronco": "#5a4632", "asfalto_claro": "#7d8993", "asfalto_escuro": "#616c76",
    # Solo tropical e mangue. Entraram em 31/08: até então o chão ATRÁS da rua
    # era a mesma laje de asfalto do pátio, estendida até FUNDO_TERRA, e ocupava
    # perto de 40% do enquadramento sem nada em cima. Um porto não tem
    # estacionamento de oito unidades atrás das casas — tem mato.
    "solo": "#7b8f52", "solo_claro": "#8ba05f", "solo_escuro": "#67793f",
    # O capim é o REALCE da vegetação, e é a resposta à linha "sem realce" da
    # tabela de paleta: a referência traz #3e8f3a com #6fbf4e por cima, e a
    # vegetação do mapa era um verde só. O capim já era o traço mais claro do
    # solo — passou a ser claro o bastante para se ver.
    "mangue": "#425f3c", "mangue_raiz": "#5a4a34", "capim": "#6fbf4e",
    # O CHÃO DA MATA (`127`): o que se vê entre as copas do morro é sombra e
    # folha caída, e não relvado. Escuro de propósito — 81 de luminância contra
    # os 134 do `solo` —, para a fresta entre duas copas ler como fundo da mata
    # e não como clareira. Era #55663a (95), e a segunda passagem escureceu-o
    # para a encosta se separar do relvado de baixo.
    "chao_mata": "#47572f",
    # O que o chão da mata ganhou na `130`: a folha caída, castanha e baça, e
    # o pingo de sol entre as copas, um verde quente mais claro do que o
    # `chao_mata` e mais escuro do que o relvado — luz, e não clareira.
    "folhas_caidas": "#6e5f36", "luz_da_mata": "#6a8340",
    # A PEDRA DO MORRO (`130`): granito à mostra, como os morros do litoral
    # — cinzento quente, mais claro do que o enrocamento do cais, com a face
    # de sombra e o veio escuro que a chuva desenha.
    "granito": "#a8a296", "granito_luz": "#c4bfb2", "granito_sombra": "#7c776d",
    "granito_veio": "#5f5b53",
    # AS FLORES DO RELVADO e a HORTA (`130`): «relvado da vila com vida».
    # As flores do relvado repetem as dos jardins (`flor_ipe`, `flor_branca`,
    # `flor_primavera`) e acrescentam o lilás da trapoeraba.
    "flor_lilas": "#b88ad6",
    "horta_terra": "#5e4a33", "horta_folha": "#5f9a3c", "trilha": "#8f7c5c",
    "trilha_clara": "#a8946f",
    "tinta": "#e0a81f",
    # A via ficou MAIS ESCURA que o pátio em 31/08. Antes era #5f6a73 contra o
    # #6f7b85 do pátio — dois cinzas a um passo um do outro, que na tela viravam
    # uma chapa só de ponta a ponta. Sem borda, uma rua não lê como rua: lê como
    # o chão que sobrou. O meio-fio (`meiofio`) faz o resto do trabalho.
    "asfalto_via": "#49535b", "calcada": "#aeb8bf", "faixa_via": "#e6ebee",
    "meiofio": "#8d979e",
    # A RUA GASTA (`136`): o mapa do porto em ruínas leva a rua que a cidade
    # deixou envelhecer — o asfalto desbotado e MAIS CLARO do que o
    # `asfalto_via`, que passou a ser o da rua recapeada com o pátio. O
    # remendo é mais ESCURO do que o asfalto à volta, porque é mais novo do
    # que ele; a fissura e o buraco, mais escuros ainda.
    "asfalto_gasto": "#5b6268", "remendo": "#4c545a", "fissura": "#3b4247",
    "buraco": "#2b3034", "buraco_borda": "#737a7f", "oleo": "#262b2f",
    # A GUIA REBAIXADA na boca de cada acesso: concreto mais escuro do que a
    # calçada, e a 20/255 dela — fora da folga de 4 com que o D20 casa a
    # calçada, que a rota do camião não pode pisar.
    # A boca de lobo é a grelha da sarjeta, quase da cor dela: escura como o
    # buraco, lia como tracinhos pretos rente ao meio-fio (segunda passagem).
    "rebaixo": "#9aa4ab", "junta_calcada": "#959fa6", "bueiro": "#3f464c",
    "grelha": "#727b81", "tampa": "#5a6065",
    # "cada casa de uma cor", diz a leitura da referência. A `casa_c` era
    # #cfd8de — o mesmo azul-acinzentado da parede antiga, de modo que um terço
    # da vila lia como concreto. Virou verde-água claro, que é cor de casa de
    # litoral e não repete nenhuma das outras duas.
    "casa_a": "#f0e7d3", "casa_b": "#e6d5b8", "casa_c": "#cfe0d2",
    # Os três pastéis da `123` — amarelo, rosa e azul-claro —, pedidos pela
    # mesma frase da referência. São CLAROS de propósito: a parede é a peça
    # que diz "tem gente dentro", e o que a separa do quintal é o valor (as
    # seis passam de 200 de luminância contra os 141 do quintal pavimentado);
    # o matiz só distingue uma casa da vizinha.
    "casa_d": "#f1dc9f", "casa_e": "#eec6b8", "casa_f": "#c8dbe8",
    "telha_a": "#b1512a", "telha_b": "#9d6a3c", "telha_c": "#7f8c98",
    "telha_d": "#a05a52",
    # A igreja, a praça e a obra da `123`. `caiacao` é a parede da igreja,
    # mais branca do que o creme das casas; `telha_torre` é o barro escuro
    # da pirâmide do campanário, que é a única peça da vila com esta cor —
    # é por ela que o D24 acha a torre sem se satisfazer com o telhado de
    # uma vizinha. `gramado` são os canteiros da praça e `tijolo`, a parede
    # por acabar da obra.
    "caiacao": "#f7f3ea", "telha_torre": "#8d3a22", "gramado": "#7cab49",
    # ⚠️ O TIJOLO ERA #c4673d E LIA COMO TELHA na primeira foto: 120 de
    # luminância contra os 99 da `telha_a`, o mesmo laranja-escuro. O tijolo
    # baiano novo é mais claro e mais alaranjado do que a telha velha, e é o
    # VALOR que os separa: 146 contra 99.
    "tijolo": "#d9844f",
    # A caixa-d'água de fibra azul em cima do telhado, a marca mais brasileira
    # que cabe num telhado de 51 px (`123`).
    "caixa_dagua": "#3d84c6", "caixa_dagua_lado": "#2c64a0",
    # A CASA HUMILDE (`123`, segunda passagem): o reboco por pintar e a telha
    # ondulada de fibrocimento cinzenta, as duas marcas da casa simples que o
    # Bruno pediu para o nível 1 — «em fases mais para frente casas melhores».
    "reboco": "#cdc4b2", "fibrocimento": "#a7aeb0",
    # As cores de acento (porta, folhas, portão) e as das flores dos quintais,
    # a primavera magenta e o ipê amarelo: pequenas e saturadas, porque são
    # elas que salpicam uma rua de casas claras (terceira passagem da `123`).
    # ⚠️ 20% MENOS SATURADAS do que nasceram (#3f7e55, #3a6ca6, #a8432f,
    # #c4932c): na quarta foto as folhas das janelas saltavam da fachada.
    "acento_verde": "#4c7e5d", "acento_azul": "#5078a6",
    "acento_vermelho": "#a85747", "acento_ocre": "#c49d4a",
    "poste": "#4a4f55", "luminaria": "#f0dc8a",
    "caixa_dagua_friso": "#5596d3", "caixa_dagua_tampa": "#6aa6dc",
    "flor_primavera": "#c9477f", "flor_ipe": "#e6c13a", "flor_branca": "#f3efe6",
}


def p(mx: float, my: float, h: float = 0.0) -> tuple:
    """Mundo -> pixel de DESENHO. Ver o bloco do enquadramento, lá em cima."""
    return (CX + (mx - my) * MEIA_LARG, CY + (mx + my) * MEIA_ALT - h)


def tela(mx: float, my: float, h: float = 0.0) -> tuple:
    """Mundo -> pixel do PNG que o jogo carrega. A fronteira dos dois espaços.

    Existe num lugar só de propósito: é ela que a tabela de âncoras usa, e
    quem publicasse pixel de DESENHO poria todos os props do `Main.tscn` 1,5x
    fora do sítio sem erro nenhum a apontá-lo.
    """
    x, y = p(mx, my, h)
    return (x * ZOOM, y * ZOOM)


def contorno_costa() -> list:
    """Os vértices (mx, my) da linha que separa terra de água, em ordem de my.

    A costa é uma ESCADA, não uma diagonal. Cada degrau avança 4 em `mx` e
    8 em `my` (ver o cabeçalho), e entre um e o seguinte há uma quina de
    verdade: primeiro o muro do degrau atual, depois o espelho que liga ao
    muro do próximo. Descrever isso como uma linha só é o que faz tudo o que
    acompanha a margem — faixa de profundidade, enrocamento, espuma — virar a
    esquina junto com ela.
    """
    v = [(DEGRAUS[0][2], DEGRAUS[0][0])]
    for i, (_, my1, borda) in enumerate(DEGRAUS):
        v.append((borda, my1))
        if i + 1 < len(DEGRAUS):
            v.append((DEGRAUS[i + 1][2], my1))
    return v


def costa_deslocada(d: float) -> list:
    """O contorno da costa empurrado `d` unidades para dentro da ÁGUA.

    Cada tipo de segmento tem a água de um lado diferente: num muro (mx
    constante) a água está no +mx; num espelho de degrau (my constante) ela
    está no -my, porque o degrau seguinte é mais largo e come o +my.

    Era exatamente isto que faltava. A versão anterior empurrava tudo em +mx
    e tratava cada degrau como uma faixa solta: nas quinas a faixa entrava
    pelo cais adentro, e o enrocamento aparecia como cascalho pintado em cima
    do concreto — o "textura de pedra por cima do mapa" reportado no playtest.
    """
    v = contorno_costa()
    ponta = len(v) - 1
    return [(mx + d, my if i in (0, ponta) else my - d)
            for i, (mx, my) in enumerate(v)]


# ── AS DUAS PONTAS SÃO COSTA DE VERDADE, E O CAIS É RETO ─────────────────
#
# Item 8 do segundo playtest, primeira fatia: *"as coisas são bastante
# quadradas, seja nas construções, como no mapa e seu desenho"*. Medida a
# costa antes de mexer nela, a queixa tem endereço exato — e NÃO é a praia
# inteira:
#
#   praia norte   3 corridas retas, a maior de 179 px, 2 quinas de 126,9 graus
#   praia sul     5 corridas retas, a maior de 224 px, 4 quinas de 126,9 graus
#
# A CRISTA JÁ RESPIRA desde 02/09 (o `_meandro`, amp 0,16), e vê-se na
# captura: a fronteira entre o relvado e a duna serpenteia. Quem é régua é a
# LINHA DE ÁGUA, que tinha `LINHA_DE_AGUA = (1.0, 0.0, 0.0)` — amplitude zero
# — e por isso desenhava um V de dois traços perfeitos em cada ponta.
#
# ⚠️ E O CAIS NÃO GANHA CURVA NENHUMA, de propósito. Cais é concreto: um porto
# de verdade tem a beira reta, e curvá-la mexeria no `borda` de que TUDO em
# terra é medido (`APRON`, `RUA_RECUO`, `VILA_RECUO`, os píeres, as âncoras).
# A máscara abaixo é zero entre `PONTA_NORTE` e `PONTA_SUL` e sobe suave para
# fora delas — o que muda é só a parte do mundo onde o porto não chegou.
#
# COMO ISTO NÃO SE DESMANCHA: tudo o que acompanha a costa (a linha de água, o
# baixio, a espuma, as pedras, a rampa da areia, o campo de cor da água) sai da
# MESMA família de curvas — uma concêntrica, com o fileto de cada quina em
# volta de um centro FIXO e o raio a crescer com a distância. É a lição que o
# `costa_deslocada` já trazia escrita ("a versão anterior tratava cada degrau
# como uma faixa solta") levada ao passo seguinte: aqui nem as quinas são
# soltas. Duas curvas da mesma família nunca se cruzam, e por isso não há
# costura possível entre a areia e a água.
ONDA_AMP = 0.34          # unidades de mundo, medidas ao longo da normal
ONDA_ENTRADA = 1.8       # o arco em que a ondulação nasce, saindo do cais
ONDA_ALCANCE = 2.4       # até onde ela sobrevive, água adentro e terra adentro
PASSO_COSTA = 0.12       # a densidade da reamostragem, em unidades

# AS QUINAS DE PRAIA, e cada uma é de um tipo. A primeira de cada degrau é uma
# ENSEADA (a água faz um canto de 90 graus dentro da terra) e a segunda é uma
# PONTA (a terra é que faz o canto). O centro do fileto da enseada fica na
# ÁGUA, então o raio ENCOLHE ao afastar-se — a enseada fecha-se, que é o que a
# distância à costa faz mesmo; o da ponta fica na TERRA e o raio CRESCE.
# Quando o raio chega a zero a curva volta a ser a quina de sempre, e é por
# isso que esta construção reproduz o `costa_deslocada` letra por letra no
# trecho do cais: lá não há fileto nenhum.
#
# Os raios não são iguais entre si de propósito: duas pontas com a mesma curva
# leem-se como um carimbo. O da enseada sul é o mais curto porque `PONTA_SUL`
# está a 1,5 dela — o fileto come `raio` de cada perna, e o que passasse disso
# começaria a curvar dentro do cais.
QUINAS_DE_PRAIA = (((2.0, -6.0), 1.35, -1.0), ((6.0, -6.0), 1.05, 1.0),
                   ((14.0, 24.0), 1.15, -1.0), ((18.0, 24.0), 1.45, 1.0),
                   ((18.0, 34.0), 1.50, -1.0), ((22.0, 34.0), 1.20, 1.0))


def _suave(t: float) -> float:
    """Smoothstep: 0 e 1 com derivada nula, para a costa não ganhar um vinco."""
    t = max(0.0, min(1.0, t))
    return t * t * (3.0 - 2.0 * t)


def _mascara_de_praia(my: float) -> float:
    """1 onde a costa é natural, 0 onde ela é cais, e a rampa entre as duas."""
    if my <= PONTA_NORTE:
        return _suave((PONTA_NORTE - my) / ONDA_ENTRADA)
    if my >= PONTA_SUL:
        return _suave((my - PONTA_SUL) / ONDA_ENTRADA)
    return 0.0


def _onda(s: float) -> float:
    """A serpentina da linha de água, em unidades, ao longo do arco `s`.

    Duas senóides como no `_meandro`, e pela mesma razão medida em 02/09:
    sacudir cada amostra dá ruído de 11 px de período, que na tela não é nada.
    Os períodos são 8,5 e 3,9 unidades; o raio de curvatura mínimo que isto
    produz é 2,7, maior do que o maior afastamento que alguém lhe pede (2,19
    do baixio), senão as curvas da família cruzavam-se entre si.
    """
    return ONDA_AMP * math.fsum((0.58 * math.sin(math.fsum((s * 0.74, 0.7))),
                                 0.42 * math.sin(math.fsum((s * 1.61, 2.9)))))


def _atenua(d: float) -> float:
    """A ondulação morre ao afastar-se da linha de água, para os dois lados."""
    return max(0.0, 1.0 - abs(d) / ONDA_ALCANCE)


def _quinas() -> list:
    """A geometria de cada fileto: centro, raio base, ângulos e de que lado.

    Sai uma vez do contorno base e não muda: o centro é FIXO e é o que faz a
    família ser concêntrica.
    """
    v = contorno_costa()
    fora = []
    for i in range(1, len(v) - 1):
        qx, qy = v[i]
        alvo = next((q for q in QUINAS_DE_PRAIA
                     if abs(q[0][0] - qx) < 1e-9 and abs(q[0][1] - qy) < 1e-9),
                    None)
        # ⚠️ A QUINA DE CAIS ENTRA NA TABELA TAMBÉM, com raio zero. Ela não
        # ganha fileto nenhum — o cais é reto —, mas precisa de estar aqui pelo
        # OUTRO motivo: é no encontro das duas pernas deslocadas que a quina
        # existe, e uma perna que acabasse na própria normal cortaria o canto.
        # Foi o que aconteceu na primeira versão: as duas quinas do cais saíam
        # chanfradas de `d`, a sombra do muro encolhia e nada apontava para isso.
        _pt, raio, lado = alvo if alvo is not None else ((qx, qy), 0.0, 0.0)
        (ax, ay), (bx, by) = v[i - 1], v[i + 1]
        u0 = _unidade(qx - ax, qy - ay)       # chega por aqui
        u1 = _unidade(bx - qx, by - qy)       # sai por ali
        # O centro está à distância `raio` das duas pernas, do lado para onde a
        # linha vira. A quina é sempre de 90 graus neste mapa, então o ponto de
        # tangência fica a `raio` da quina em cada perna.
        n0 = (u0[1], -u0[0])                  # normal do lado da ÁGUA
        n1 = (u1[1], -u1[0])
        centro = (qx - u0[0] * raio - n0[0] * raio * lado,
                  qy - u0[1] * raio - n0[1] * raio * lado)
        p0 = (qx - u0[0] * raio, qy - u0[1] * raio)
        p1 = (qx + u1[0] * raio, qy + u1[1] * raio)
        a0 = math.atan2(p0[1] - centro[1], p0[0] - centro[0])
        a1 = math.atan2(p1[1] - centro[1], p1[0] - centro[0])
        while a1 - a0 > math.pi:
            a1 -= math.tau
        while a0 - a1 > math.pi:
            a1 += math.tau
        # ⚠️ E QUANTO DA PERNA A QUINA COME, que é o que faltava à primeira
        # versão. Numa quina sem fileto a linha deslocada acaba no ENCONTRO das
        # duas pernas, e não na normal do vértice: seguir a perna até ao fim e
        # só então saltar para o encontro faz a linha ANDAR PARA TRÁS `d`
        # unidades — um bico de 0,33 sobre si mesma a 0,45 de distância, que
        # não dá erro nenhum e sai no desenho como uma farpa. Estes dois
        # produtos escalares dizem, com o sinal, se a quina come perna (a
        # enseada) ou se a estica (a ponta).
        fora.append({"i": i, "quina": (qx, qy), "centro": centro, "raio": raio,
                     "lado": lado, "a0": a0, "a1": a1, "n0": n0, "n1": n1,
                     "come0": -(n1[0] * u0[0] + n1[1] * u0[1]),
                     "come1": n0[0] * u1[0] + n0[1] * u1[1],
                     "p0": p0, "p1": p1})
    return fora


def _unidade(dx: float, dy: float) -> tuple:
    comp = math.hypot(dx, dy)
    return (dx / comp, dy / comp) if comp > 1e-12 else (0.0, 0.0)


_QUINAS = None
_ARCOS = None


def _geometria_da_costa() -> tuple:
    """(vértices, comprimentos, arco acumulado, quinas por índice)."""
    global _QUINAS, _ARCOS
    if _QUINAS is None:
        v = contorno_costa()
        comp = [math.hypot(v[i + 1][0] - v[i][0], v[i + 1][1] - v[i][1])
                for i in range(len(v) - 1)]
        arco = [0.0]
        for c in comp:
            arco.append(math.fsum((arco[-1], c)))
        _ARCOS = (v, comp, arco)
        _QUINAS = {q["i"]: q for q in _quinas()}
    return _ARCOS + (_QUINAS,)


def _cruzamento(p0: tuple, u0: tuple, p1: tuple, u1: tuple) -> tuple:
    """Onde as duas pernas deslocadas se encontram — a quina de sempre.

    No contorno base as pernas são paralelas aos eixos, então isto devolve
    coordenada EXATA e o trecho do cais sai byte a byte igual ao que o
    `costa_deslocada` escrevia.
    """
    if abs(u0[0]) < 1e-12:                     # perna vertical, depois horizontal
        return (p0[0], p1[1])
    if abs(u0[1]) < 1e-12:
        return (p1[0], p0[1])
    den = u0[0] * u1[1] - u0[1] * u1[0]
    if abs(den) < 1e-12:
        return p1
    t = ((p1[0] - p0[0]) * u1[1] - (p1[1] - p0[1]) * u1[0]) / den
    return (p0[0] + u0[0] * t, p0[1] + u0[1] * t)


def ponto_costeiro(i: int, f: float, d: float) -> tuple:
    """O ponto DESENHADO da costa: segmento `i`, fração `f`, a `d` da terra.

    `d` positivo é água adentro e negativo é terra adentro. Devolve
    (mx, my, normal, tangente), com a normal a apontar para o mar — a mesma
    convenção do `andar_costa`, que é quem espalha pedra e espuma por aqui.

    É O ÚNICO SÍTIO que sabe a forma da costa desenhada. A `linha_costeira`
    (os polígonos), o `andar_costa` (o que se espalha) e o campo de cor da
    água saem todos daqui, e é isso que garante que a areia e a água não
    tenham costura: uma costura é duas contas a discordar, e aqui só há uma.
    """
    v, comp, arco, quinas = _geometria_da_costa()
    (x0, y0), (x1, y1) = v[i], v[i + 1]
    u = _unidade(x1 - x0, y1 - y0)
    n = (u[1], -u[0])
    base = (math.fsum((x0, (x1 - x0) * f)), math.fsum((y0, (y1 - y0) * f)))
    s = math.fsum((arco[i], comp[i] * f))

    # ── a quina, quando o ponto cai dentro do fileto ──
    for chave, dist, entrada in ((i + 1, comp[i] * (1.0 - f), True),
                                 (i, comp[i] * f, False)):
        q = quinas.get(chave)
        if q is None:
            continue
        comido = (q["come0"] if entrada else q["come1"]) * d
        if dist > max(q["raio"], comido, 0.0) and not (
                q["raio"] <= 0.0 and dist <= 1e-9):
            continue
        raio = q["raio"] + q["lado"] * d
        fatia = (0.5 * (1.0 - dist / q["raio"]) if entrada
                 else 0.5 + 0.5 * (dist / q["raio"])) if q["raio"] > 0.0 else 0.5
        if raio <= 1e-9:
            # O fileto fechou-se — a enseada some ao afastar-se dela, e a
            # ponta some ao entrar em terra. Aí a costa volta a ser a quina de
            # sempre, e o ponto é o encontro das duas pernas deslocadas: a
            # MESMA conta que o `costa_deslocada` faz desde 30/08.
            pin = (math.fsum((q["quina"][0], q["n0"][0] * d)),
                   math.fsum((q["quina"][1], q["n0"][1] * d)))
            pout = (math.fsum((q["quina"][0], q["n1"][0] * d)),
                    math.fsum((q["quina"][1], q["n1"][1] * d)))
            pt = _cruzamento(pin, (-q["n0"][1], q["n0"][0]),
                             pout, (-q["n1"][1], q["n1"][0]))
            return (pt[0], pt[1], q["n0"] if entrada else q["n1"], u)
        ang = math.fsum((q["a0"], (q["a1"] - q["a0"]) * fatia))
        radial = (math.cos(ang), math.sin(ang))
        para_o_mar = (radial[0] * q["lado"], radial[1] * q["lado"])
        # A ondulação mede-se sempre PARA O MAR; no fileto o mar está no
        # sentido `lado` do raio, então somá-la ao raio é multiplicá-la por
        # `lado`.
        #
        # ⚠️ E A FASE ATRAVESSA O FILETO, em vez de ser a da quina. Com a fase
        # congelada no vértice, a onda SALTAVA no ponto de tangência — a curva
        # entrava no arco com um degrau de até 0,15 unidades, e o que se media
        # ali era uma quina de 106 graus no meio de uma praia que o resto do
        # contorno já tinha amaciado. Aqui o arco continua a contagem de arco
        # da perna que chega e entrega-a à perna que sai, e por isso as duas
        # emendas são contínuas por construção.
        s_fileto = math.fsum((arco[chave], q["raio"] * (2.0 * fatia - 1.0)))
        my_fileto = math.fsum((q["p0"][1], (q["p1"][1] - q["p0"][1]) * fatia))
        onda = (_onda(s_fileto) * _mascara_de_praia(my_fileto) * _atenua(d))
        raio_final = max(0.0, math.fsum((raio, q["lado"] * onda)))
        return (math.fsum((q["centro"][0], radial[0] * raio_final)),
                math.fsum((q["centro"][1], radial[1] * raio_final)),
                para_o_mar, (-para_o_mar[1], para_o_mar[0]))

    # ── perna reta: desloca pela normal e soma a ondulação ──
    onda = _onda(s) * _mascara_de_praia(base[1]) * _atenua(d)
    total = math.fsum((d, onda))
    return (math.fsum((base[0], n[0] * total)),
            math.fsum((base[1], n[1] * total)), n, u)


def linha_costeira(d: float, passo: float = PASSO_COSTA) -> list:
    """A linha inteira a `d` da terra: densa nas pontas, e a escada no cais.

    O cais sai com os MESMOS vértices que o `costa_deslocada` escrevia — nada
    de reamostrar o que é reto, que só engordaria o SVG.
    """
    v, comp, _arco, quinas = _geometria_da_costa()
    pontos = []
    for i in range(len(v) - 1):
        mole = (_mascara_de_praia(v[i][1]) > 0.0
                or _mascara_de_praia(v[i + 1][1]) > 0.0
                or quinas.get(i, {}).get("raio", 0.0) > 0.0
                or quinas.get(i + 1, {}).get("raio", 0.0) > 0.0)
        n = max(1, int(math.ceil(comp[i] / passo))) if mole else 1
        for k in range(n + 1):
            mx, my, _n, _t = ponto_costeiro(i, k / n, d)
            if (not pontos or abs(mx - pontos[-1][0]) > 1e-9
                    or abs(my - pontos[-1][1]) > 1e-9):
                pontos.append((mx, my))
    return pontos


def andar_costa(d: float, passo: tuple, r: random.Random):
    """Percorre a linha de água a `d` da terra, a passos irregulares.

    Devolve (mx, my, normal, tangente) — a normal aponta para o mar, e é ela
    que garante que nada do que se espalha por aqui caia do lado da terra.

    ⚠️ A CAMINHADA É NA ESCADA E O PONTO É O DESENHADO, e isso não é desleixo.
    O passo sai do comprimento do segmento da ESCADA, como desde 30/08, para a
    sequência de sorteios não mudar: o enrocamento do cais são 300 pedras
    tiradas deste mesmo `r`, e bastaria reamostrar a costa para TODAS elas
    trocarem de sítio — meia sessão de diferença visual no porto por causa de
    uma correção na praia. Quem muda é só o ponto onde cada coisa cai, que
    passa a ser a costa que o mapa desenha.
    """
    v = costa_deslocada(d)
    for i in range(len(v) - 1):
        (x0, y0), (x1, y1) = v[i], v[i + 1]
        muro = abs(x1 - x0) < 1e-6
        comprimento = abs(y1 - y0) if muro else abs(x1 - x0)
        andado = 0.0
        while andado < comprimento:
            mx, my, normal, tangente = ponto_costeiro(i, andado / comprimento, d)
            yield (mx, my, normal, tangente)
            andado += r.uniform(*passo)


# Folga em `my` de cada lado do píer onde nada da margem é desenhado. Um
# pouco maior que o tabuado, para a interrupção ficar visivelmente alinhada
# com ele em vez de aparecer como falha.
PIER_FOLGA = 0.55


def _borda_em(my: float) -> float:
    """A beira do cais no `my` dado — o degrau a que aquele ponto pertence."""
    for my0, my1, borda in DEGRAUS:
        if my0 <= my < my1:
            return borda
    return DEGRAUS[-1][2]


def _sob_pier(my: float) -> bool:
    return any(my0 - PIER_FOLGA <= my <= my1 + PIER_FOLGA for my0, my1, _ in PIERES)


def costa(de: float, ate: float) -> list:
    """Os pontos de uma faixa que acompanha a costa em degraus.

    A costa não é reta — cada doca avança também em `mx` (ver o cabeçalho).
    Uma elipse solta na água não sabe disso e por isso nunca pareceu praia:
    faixa de profundidade tem de SEGUIR a linha da terra, e é isso que faz o
    olho ler "isto é uma margem" em vez de "isto é uma mancha".
    """
    perto = [p(mx, my) for mx, my in costa_deslocada(de)]
    longe = [p(mx, my) for mx, my in costa_deslocada(ate)]
    return perto + list(reversed(longe))


def _corta_em_my(v: list, mya: float, myb: float) -> list:
    """Recorta a polilinha da costa ao intervalo [mya, myb] de `my`.

    Existe porque as duas pontas deixaram de ser cais: a sombra que o muro
    lança na água tem de PARAR onde o muro para, e a areia molhada tem de
    existir só onde há areia. Sem isto, ou se pinta sombra de muro ao pé de
    uma praia, ou se redesenha a costa inteira duas vezes.

    O espelho de degrau (`my` constante) é caso à parte de propósito: ele não
    se recorta, entra inteiro ou não entra — recortá-lo por interpolação daria
    divisão por zero e, pior, um vértice no meio da quina.
    """
    def em(a, b, t):
        """Interpola os DOIS ou TRÊS componentes: as linhas da rampa carregam
        um terceiro, a altura, e cortá-lo fora deixaria a ponta da faixa
        pousada no chão."""
        return tuple(a[k] + (b[k] - a[k]) * t for k in range(len(a)))

    out = []
    for i in range(len(v) - 1):
        a, b = v[i], v[i + 1]
        y0, y1 = a[1], b[1]
        if abs(y1 - y0) < 1e-9:
            trecho = [a, b] if mya <= y0 <= myb else []
        else:
            t0, t1 = 0.0, 1.0
            for sinal, lim in ((1.0, myb), (-1.0, mya)):
                den, num = sinal * (y1 - y0), sinal * (y0 - lim)
                t = -num / den
                if den > 0:
                    t1 = min(t1, t)
                else:
                    t0 = max(t0, t)
            trecho = [] if t0 >= t1 else [em(a, b, t0), em(a, b, t1)]
        for q in trecho:
            if not out or abs(q[0] - out[-1][0]) > 1e-9 or abs(q[1] - out[-1][1]) > 1e-9:
                out.append(q)
    return out


# ── NÚMERO DA DOCA, PINTADO NO CAIS ──────────────────────────────────────
# Os nomes das docas eram Labels brancos flutuando por cima do mapa: liam-se
# como legenda de diagrama, não como porto. Numa doca de verdade o número está
# PINTADO NO CHÃO, para ser lido de dentro do navio — então é isso que ele é
# aqui, e o cartão da doca lá embaixo é que diz "DOCA 1" por extenso.
#
# Por que estêncil e não uma fonte: o importador de SVG do Godot é o ThorVG,
# que não desenha <text>. Um dígito escrito com fonte sairia vazio no jogo.
# Três dígitos como polígonos custam vinte linhas e ainda dão o traço grosso e
# chapado que a tinta de piso tem de verdade.

# Cada dígito numa caixa de 6x10, y para baixo. Barras = (x0, y0, x1, y1).
DIGITOS = {
    "1": [(2.2, 0.0, 3.8, 10.0), (0.8, 8.4, 5.2, 10.0), (0.9, 1.3, 2.2, 2.6)],
    "2": [(0.0, 0.0, 6.0, 1.6), (4.4, 1.2, 6.0, 4.8), (0.0, 4.0, 6.0, 5.6),
          (0.0, 5.2, 1.6, 8.8), (0.0, 8.4, 6.0, 10.0)],
    "3": [(0.0, 0.0, 6.0, 1.6), (4.4, 0.0, 6.0, 10.0), (1.4, 4.2, 6.0, 5.8),
          (0.0, 8.4, 6.0, 10.0)],
}


def pintura_doca(digito: str, mx0: float, my0: float, altura: float,
                 cor: str, opacidade: float) -> str:
    """Um dígito deitado no plano do chão, para ser lido da água.

    O eixo do texto acompanha a beira do cais (-my sobe para a direita) e a
    altura das letras cai para dentro da terra (+mx). Não há rotação que
    resolva isto: um plano isométrico precisa de CISALHAMENTO, e é por isso que
    a conta vive aqui e não num nó de interface.
    """
    escala = altura / 10.0
    out = []
    for x0, y0, x1, y1 in DIGITOS[digito]:
        # (u ao longo de -my, v ao longo de +mx), ambos em unidades de mundo.
        quina = []
        for u, v in [(x0, y0), (x1, y0), (x1, y1), (x0, y1)]:
            quina.append(p(mx0 + v * escala, my0 - u * escala, ALT_CAIS))
        out.append('  <polygon points="%s" fill="%s" opacity="%.2f"/>\n'
                   % (" ".join("%.1f,%.1f" % q for q in quina), cor, opacidade))
    return "".join(out)


SEMENTE_CHAO = 20260829   # fixo: o mapa tem de sair igual toda vez


def manchas_chao(indice: int, mx0: float, my0: float, mx1: float, my1: float,
                 pavimentado: bool) -> str:
    """Quebra a chapa de cor do pátio com manchas rentes ao chão.

    Uma cor chapada de 700x300px não lê como terreno, lê como preenchimento —
    e era isso que fazia o pátio parecer um recorte por baixo dos prédios.

    Duas regras que valem para qualquer mancha aqui:

    1. **Mancha no chão é elipse 2:1**, não círculo. Um disco desenhado no
       plano do chão projeta achatado igual ao resto do mundo; um círculo em
       coordenadas de ecrã flutua por cima da cena.
    2. **Recortar no polígono do pátio.** Sem `clip-path` a mancha transborda
       para a beira do cais e a laje deixa de ter aresta.
    """
    r = random.Random(SEMENTE_CHAO + indice)
    ident = "patio%d" % indice
    quina = [p(mx0, my0, ALT_CAIS), p(mx1, my0, ALT_CAIS),
             p(mx1, my1, ALT_CAIS), p(mx0, my1, ALT_CAIS)]
    out = ['  <clipPath id="%s"><polygon points="%s"/></clipPath>\n' % (
        ident, " ".join("%.1f,%.1f" % q for q in quina))]
    out.append('  <g clip-path="url(#%s)">\n' % ident)

    # A opacidade do asfalto é MENOR que a da terra de propósito: os dois tons
    # de cinza contrastam mais entre si que os dois de terra, e na primeira
    # tentativa (mesma opacidade para os dois) o pátio pavimentado saiu com
    # bolinhas em vez de remendo. Faixa de raio larga pelo mesmo motivo —
    # mancha toda do mesmo tamanho lê como padrão, não como desgaste.
    if pavimentado:
        paleta = [(C["asfalto_escuro"], 0.34), (C["asfalto_claro"], 0.24)]
    else:
        paleta = [(C["terra_escura"], 0.50), (C["terra_clara"], 0.45),
                  (C["poca"], 0.35)]
    for _ in range(16):
        cor, opac = paleta[r.randrange(len(paleta))]
        cx, cy = p(r.uniform(mx0, mx1), r.uniform(my0, my1), ALT_CAIS)
        raio = r.uniform(10.0, 55.0)
        out.append('    <ellipse cx="%.0f" cy="%.0f" rx="%.0f" ry="%.0f" '
                   'fill="%s" opacity="%.2f"/>\n'
                   % (cx, cy, raio, raio / 2.0, cor, opac))

    if pavimentado:
        # Rachaduras: linha quebrada rente ao chão, não risco sobre a imagem.
        #
        # ⚠️ ERAM TRÊS TRAÇOS RETOS DE ATÉ 1,1 UNIDADE, e liam como rabisco —
        # um «X» atrás do escritório, um triângulo ao pé do cone (`136`). A
        # fissura de verdade anda aos ziguezagues curtos e abre um ramo. Sai
        # de um `Random` próprio: o das manchas acaba nelas e não muda.
        rf = random.Random(SEMENTE_CHAO + 720 + indice)
        for _ in range(4):
            mx, my = rf.uniform(mx0, mx1), rf.uniform(my0, my1)
            ang = rf.uniform(0.0, math.tau)
            ramos, caminhos = [(mx, my, ang, rf.randint(7, 12))], []
            while ramos:
                bx, by, ba, passos = ramos.pop()
                linha = [p(bx, by, ALT_CAIS)]
                for j in range(passos):
                    ba += rf.uniform(-0.5, 0.5)
                    passo = rf.uniform(0.08, 0.17)
                    bx, by = bx + math.cos(ba) * passo, by + math.sin(ba) * passo
                    linha.append(p(bx, by, ALT_CAIS))
                    if j == passos // 2 and not caminhos and rf.random() < 0.7:
                        ramos.append((bx, by, ba + rf.choice((-1, 1)) * rf.uniform(0.6, 1.1),
                                      rf.randint(3, 6)))
                caminhos.append(linha)
            out.append('    <path d="%s" fill="none" stroke="#4e5860" stroke-width="1.0" '
                       'stroke-linecap="round" stroke-linejoin="round" opacity="0.55"/>\n'
                       % " ".join("M%.1f,%.1f " % c[0] + " ".join("L%.1f,%.1f" % q
                                                                  for q in c[1:])
                                  for c in caminhos))
    else:
        # Cascalho: o pátio de terra batida é chão de obra, não jardim.
        for _ in range(60):
            gx, gy = p(r.uniform(mx0, mx1), r.uniform(my0, my1), ALT_CAIS)
            raio = r.uniform(1.6, 3.4)
            out.append('    <ellipse cx="%.0f" cy="%.0f" rx="%.1f" ry="%.1f" '
                       'fill="#6d6152" opacity="0.5"/>\n'
                       % (gx, gy, raio, raio * 0.55))

        # Mato nas frestas: o pátio de terra é o porto PARADO, e mato é o que
        # cresce onde ninguém passa.
        #
        # A primeira versão eram três riscos retos saindo de um ponto, com 9px
        # de altura e traço grosso. Espalhados um a um pelo pátio leram como
        # SETAS verdes, não como planta. O que corrige é tufo e escala: folha
        # CURVA, baixa, fina, várias juntas — mato aparece em moita, e é a
        # moita que o olho reconhece.
        # A receita do tufo vive em `tufo_de_capim`, num lugar só. Ela nasceu
        # aqui e ficou aqui — e a `vegetacao_do_solo`, que tinha os mesmos
        # três riscos retos, nunca soube dela. Duas cópias da mesma regra é
        # exatamente o que faz um defeito injetado não reprovar.
        for _ in range(11):
            cx, cy = p(r.uniform(mx0, mx1), r.uniform(my0, my1), ALT_CAIS)
            out.append(tufo_de_capim(cx, cy, r))
    out.append('  </g>\n')
    return "".join(out)


def no_quadro(mx: float, my: float, h: float = ALT_CAIS,
              folga: float = 60.0) -> bool:
    """O ponto cai dentro do PNG que o jogo mostra?

    Existe por causa da medição de 04/09, e ela é o achado desta passagem: das
    136 copas que a orla de mata gerava, **7** tinham o centro dentro do
    quadro. A causa não era o número, era o VIÉS — `r.random() ** 2.2` esmaga
    as copas contra `mx0`, que é `FUNDO_TERRA`, e o nome dessa constante já
    diz o que ela é: "o quanto a terra recua para trás (FORA DO ECRÃ)". O
    comentário da função descrevia a intenção com todas as letras — "a
    densidade cresce para o fundo" — e o fundo é justamente o que ninguém vê.

    Medido por degrau, a fração da faixa de mata que cai no quadro:
    11%, 50%, 10% e **0%**. No último degrau a mata inteira está fora, à
    esquerda. Adiantar de nada aumentar a contagem sem mexer nisto.

    A folga é generosa de propósito: uma copa cujo pé cai 40px fora ainda
    aparece pela metade, e cortar pelo pé deixaria uma borda reta de árvores.
    """
    x, y = p(mx, my, h)
    return -folga <= x <= LARG + folga and -folga <= y <= ALT + folga


def tufo_de_capim(px: float, py: float, r: random.Random,
                  n: tuple = (4, 7), alt: tuple = (4.0, 7.0),
                  cor: str = "", opac: float = 0.7) -> str:
    """Uma moita de capim: folhas CURVAS, baixas, finas, várias juntas.

    ⚠️ ESTA LIÇÃO JÁ ESTAVA APRENDIDA, e num só dos dois lugares. O
    `manchas_chao` registou-a por escrito — "três riscos retos saindo de um
    ponto leram como SETAS verdes, não como planta" — e corrigiu-se; a
    `vegetacao_do_solo`, que fazia exatamente os mesmos três riscos retos com
    traço de 1,7, nunca foi visitada. Ampliada 3x na captura de 03/09 ela sai
    como um punhado de tracinhos verdes fluorescentes espetados no relvado.

    Agora é um lugar só, e as duas chamam-no.
    """
    s = ""
    for _ in range(r.randint(*n)):
        tx, ty = px + r.uniform(-6.0, 6.0), py + r.uniform(-3.0, 3.0)
        dx = r.uniform(-3.5, 3.5)
        a = r.uniform(*alt)
        s += ('  <path d="M%.0f %.0f q%.1f %.1f %.1f %.1f" stroke="%s" '
              'stroke-width="1.3" fill="none" stroke-linecap="round" '
              'opacity="%s"/>\n'
              % (tx, ty, dx * 0.25, -a * 0.7, dx, -a, cor or C["mato"],
                 "%g" % opac))
    return s


def tufo_em_leque(px: float, py: float, r: random.Random,
                  n: tuple = (5, 8), alt: tuple = (6.0, 10.0),
                  cor: str = "") -> str:
    """Um tufo de capim-da-praia em LEQUE: lâminas CHEIAS que abrem do pé.

    ⚠️ O TRAÇO DE 1,3 LIA ARRANHÃO NA AREIA (`130`): «capim da restinga em
    fios», marcou o Bruno. O `tufo_de_capim` é um traço de largura fixa que
    acaba redondo, e sobre a areia clara um traço fino é um risco. A lâmina
    aqui é uma FOLHA — larga no pé, a afinar até à ponta, curva —, as do meio
    em pé e as de fora a deitar, e o pé leva a sombra do tufo: é a mancha
    escura na base que faz o leque assentar no chão.
    """
    cor = cor or C["capim_praia"]
    escura = "#%02x%02x%02x" % tuple(round(c * 0.72) for c in _rgb(cor))
    s = ('  <ellipse cx="%.1f" cy="%.1f" rx="%.1f" ry="%.1f" fill="%s" '
         'opacity="0.45"/>\n' % (px, py + 0.6, r.uniform(4.0, 5.5), 1.7, escura))
    k = r.randint(*n)
    for i in range(k):
        # Do lado esquerdo para o direito, a abrir: −62° a +62° da vertical.
        th = math.radians(-62.0 + 124.0 * (i + r.uniform(0.2, 0.8)) / k)
        a = r.uniform(*alt) * (1.0 - 0.35 * abs(math.sin(th)))
        bx = px + r.uniform(-1.5, 1.5)
        dx, dy = math.sin(th), -math.cos(th)
        tx, ty = bx + dx * a * 1.15, py + dy * a + a * 0.12 * abs(dx)
        w = r.uniform(1.4, 2.0)
        # A curva: o meio da lâmina sai para fora, e a ponta cai.
        mx_, my_ = bx + dx * a * 0.55, py + dy * a * 0.62
        s += ('  <path d="M%.1f %.1f Q%.1f %.1f %.1f %.1f Q%.1f %.1f %.1f %.1f Z" '
              'fill="%s" opacity="0.95"/>\n'
              % (bx - w / 2.0, py, mx_ - w * 0.3, my_, tx, ty,
                 mx_ + w * 0.3, my_, bx + w / 2.0, py,
                 escura if i % 3 == 1 else cor))
    return s


def vegetacao_do_solo(indice: int, mx0: float, my0: float, mx1: float,
                      my1: float) -> str:
    """A mata BAIXA atrás da rua: moita e capim no quintal de trás.

    O guia de terrenos do pacote pede "solo tropical, mangue e restinga" e
    "vegetação: gramínea, moita". Aqui isso é DESENHO no mapa, e não tile: o
    chão deste jogo é um SVG gerado, e uma moita que muda de estado não existe.

    ⚠️ ESTA FUNÇÃO DESENHAVA A MATA INTEIRA ATÉ 17/10, e duas das três partes
    saíram dela (`127`):

    - a VARIAÇÃO DE TOM — cinco manchas escuras a 0,22, que tiravam a chapa e
      pouco mais — é hoje o campo do chão (`campo_do_chao`), com ruído em
      duas escalas e o morro;
    - as COPAS — 36 por degrau, a antiga `arvore()` de lobos com saia — são hoje
      props do Blender por cima do mapa, a balançar como os coqueiros, por
      escolha do Bruno. Ficavam aqui DUAS árvores para cada sítio.

    O que fica é a moita e o capim, e só no chão PLANO à frente do pé do
    morro: na encosta, a altura do chão muda a cada ponto e o que lá cresce
    fica por baixo das copas.

    A lição do orçamento continua a valer (04/09): o que cai fora do quadro
    não se desenha — `no_quadro`.
    """
    r = random.Random(SEMENTE_CHAO + 91 + indice)
    s = ""
    largura = mx1 - mx0
    for _ in range(30):
        vies = r.random() ** 0.7
        mx = mx0 + largura * 0.35 + vies * (largura * 0.62)
        my = r.uniform(my0, my1)
        if mx > mx1 - 0.25 or not no_quadro(mx, my):
            continue
        if altura_do_morro(mx - 0.4, my) > 0.0:
            continue
        if r.random() < 0.3:
            rr = r.uniform(0.14, 0.30)
            pts = []
            for k in range(8):
                ang = math.radians(k * 45.0)
                pts.append(p(mx + rr * math.cos(ang) * r.uniform(0.8, 1.2),
                             my + rr * 0.8 * math.sin(ang) * r.uniform(0.8, 1.2),
                             ALT_CAIS))
            s += poli(pts, C["mato"], 0.9)
        else:
            gx, gy = p(mx, my, ALT_CAIS)
            s += tufo_de_capim(gx, gy, r)
    return s


# ── O MORRO E O CHÃO (`127`) ─────────────────────────────────────────────
#
# O Bruno escolheu, em 17/10, «encosta de mata»: o chão sobe atrás da vila até
# a borda de cima do quadro, todo coberto de mata, e a vila fica ao pé do
# morro. É o único chão de FUNDO que a câmera vê — o canto de cima à esquerda,
# umas sete unidades atrás da segunda fileira de casas nos degraus 1 e 2.
#
# ⚠️ O PÉ DO MORRO SAI DO FUNDO DOS LOTES, e não de um número: a vila recua
# quatro unidades a cada degrau, e um pé escrito à mão subiria por dentro dos
# quintais do degrau seguinte.
#
# ⚠️ E O PÉ NÃO É A ESCADA DOS LOTES, É O CASCO CONVEXO POR BAIXO DELA. A
# primeira versão seguia a escada e, na junta, andava as quatro unidades do
# degrau em duas de `my`; com a altura medida na vertical (`pé − mx`), a
# encosta dobrava-se ali num VINCO escuro, de alto a baixo do morro. O pé de
# hoje liga os cantos DE DENTRO da escada (o fundo do lote no fim de cada
# degrau): nunca passa à frente de uma casa, e só tem cantos em que a
# inclinação cresce. A altura sai da DISTÂNCIA EUCLIDIANA a ele, e desse lado
# de um canto assim os contornos são arcos — sem vinco nenhum. O preço é um
# quintal de trás em cunha, fundo no começo de cada degrau e nulo no fim.
#
# ⚠️ E A ALTURA É POLINÓMIO, pela regra da sombra do muro: o CI compara o PNG
# byte a byte, e a `pow` fracionária de cada libm pode discordar no último bit.
MORRO_PE = 0.5            # quintal de trás: o morro começa este tanto atrás do lote
# ⚠️ A (8; 1,6) E A (12; 2,4) «O MORRO NÃO SE NOTA», marcou o Bruno na
# primeira passagem: a encosta subia devagar demais para as copas de trás se
# empilharem por cima das da frente, e é esse degrau de copas que diz morro.
MORRO_SUBIDA = (15.0, 3.4)  # altura = a·t + b·t² px de DESENHO, t em unidades atrás do pé

# Uma unidade de altura do Blender vale isto em px de DESENHO — a conta do
# `ALTURA_PX` de `gerar_props_iso.py`, que é quem faz as árvores. Serve aqui
# para a normal do morro e a luz dele falarem a mesma língua dos props.
ALTURA_PX_BLENDER = (MEIA_LARG / math.cos(math.radians(45.0))) \
    * math.cos(math.radians(30.0))
# De onde VEM o sol, em (mx, my, z): a `luz_chave` do estúdio de props, a
# (48°, 0, 28°), com o `y` do Blender trocado em `my` (`pos()`). É a mesma luz
# que escurece a face `+mx` das casas (`com_saia`), por isso a encosta que
# olha para o cais clareia um pouco e a junta de um degrau escurece.
SOL_DO_MORRO = (0.3488, 0.6560, 0.6691)


def _pe_do_morro_vertices() -> list:
    """Os vértices (my, mx) do pé: os cantos de dentro da escada dos lotes."""
    def pe(i: int) -> float:
        return DEGRAUS[i][2] - VILA_RECUO_2 - MORRO_PE
    v = [(DEGRAUS[0][0] - 12.0, pe(0))]
    v += [(DEGRAUS[i][1], pe(i)) for i in range(len(DEGRAUS) - 1)]
    return v + [(DEGRAUS[-1][1] + 12.0, pe(len(DEGRAUS) - 1))]


_PE_DO_MORRO = None


def pe_do_morro(my: float) -> float:
    """O `mx` onde o chão começa a subir, no `my` dado."""
    global _PE_DO_MORRO
    if _PE_DO_MORRO is None:
        _PE_DO_MORRO = _pe_do_morro_vertices()
    v = _PE_DO_MORRO
    if my <= v[0][0]:
        return v[0][1]
    for (my0, mx0), (my1, mx1) in zip(v, v[1:]):
        if my <= my1:
            return mx0 + (mx1 - mx0) * (my - my0) / (my1 - my0)
    return v[-1][1]


def fundo_do_morro(mx: float, my: float) -> tuple:
    """(t, ux, uy): quanto o ponto está atrás do pé, e para onde o chão sobe.

    `t` é a distância euclidiana ao pé, em unidades, e zero à frente dele;
    (ux, uy) é o unitário que se afasta do pé — a direção da subida.
    """
    if mx >= pe_do_morro(my):
        return 0.0, 0.0, 0.0
    melhor = None
    for (my0, mx0), (my1, mx1) in zip(_PE_DO_MORRO, _PE_DO_MORRO[1:]):
        vx, vy = mx1 - mx0, my1 - my0
        u = max(0.0, min(1.0, ((mx - mx0) * vx + (my - my0) * vy)
                         / (vx * vx + vy * vy)))
        dx, dy = mx - (mx0 + vx * u), my - (my0 + vy * u)
        d2 = dx * dx + dy * dy
        if melhor is None or d2 < melhor[0]:
            melhor = (d2, dx, dy)
    t = math.sqrt(melhor[0])
    if t == 0.0:
        return 0.0, 0.0, 0.0
    return t, melhor[1] / t, melhor[2] / t


def altura_do_morro(mx: float, my: float) -> float:
    """Quanto o chão sobe acima do cais em (mx, my), em px de DESENHO."""
    t = fundo_do_morro(mx, my)[0]
    if t <= 0.0:
        return 0.0
    a, b = MORRO_SUBIDA
    return a * t + b * t * t


def no_morro(mx: float, my: float) -> tuple:
    """(mx, my, h) de DESENHO de um ponto do chão, com o morro: para `p()`."""
    return (mx, my, ALT_CAIS + altura_do_morro(mx, my))


# AS CLAREIRAS DO MORRO (`130`): «morro que se leia», marcou o Bruno. Debaixo
# das copas não se via a encosta subir; onde a mata se abre aparecem o chão
# claro e o granito, e uma fresta de chão ACIMA de copas e ABAIXO de outras é
# o que diz que o chão sobe. (mx, my, raio) no mundo, no morro que o quadro
# vê — medido pela área livre acima da vila, e não escolhido no mundo: o
# morro é quase todo fora da tela (`mapa.md`, «antes de gerar mais»).
# ⚠️ A SEGUNDA, mais acima e menor, na volta seguinte: «uma clareira só» —
# com duas a alturas diferentes a encosta lê a subir.
CLAREIRAS = ((-7.2, 7.6, 0.75), (-8.0, 4.4, 0.50))


_PEDRAS = None


def pedras_do_morro() -> tuple:
    """(svg, pedras): o granito à mostra nas clareiras do morro (`130`).

    Uma laje grande e uma ou duas pequenas por clareira, no sólido facetado
    do enrocamento (`com_saia`), com o realce de cima e o VEIO escuro que a
    chuva desenha na face — é o veio que diz granito e não pedra solta. Cada
    pedra publica a caixa de TELA e a profundidade (`mx + my`): a mata que
    balança é prop e pintar-se-ia por cima da que lhe fica à frente.
    """
    global _PEDRAS
    if _PEDRAS is not None:
        return _PEDRAS
    r = random.Random(SEMENTE_CHAO + 640)
    s, pedras = "", []
    for cx, cy, raio in CLAREIRAS:
        # ⚠️ A PRIMEIRA PEDRA LIA UM BLOCO cinzento (alta como larga): o
        # granito do litoral é LAJEDO — baixo, largo, em lombos —, e o que o
        # diz são os veios escuros a escorrer e o musgo nas costas.
        # O tamanho da pedra acompanha o da clareira (a de 0,75 é a medida).
        k = raio / 0.75
        lajes = [(cx - raio * 0.15, cy + raio * 0.10, k * r.uniform(19.0, 23.0)),
                 (cx - raio * 0.40, cy - raio * 0.20, k * r.uniform(12.0, 15.0))]
        for _ in range(r.randint(1, 2)):
            a = r.uniform(0.0, math.tau)
            lajes.append((cx + raio * 0.45 * math.cos(a), cy + raio * 0.45 * math.sin(a),
                          k * r.uniform(6.0, 9.0)))
        for mx, my, rx in sorted(lajes, key=lambda q: q[0] + q[1]):
            px, py = p(mx, my, ALT_CAIS + altura_do_morro(mx, my))
            ry = rx * r.uniform(0.52, 0.62)
            alto = rx * r.uniform(0.28, 0.36)
            canto = _lobo(px, py - alto, rx, ry, r)
            s += com_saia(canto, alto, C["granito"])
            luz = [(px - rx * 0.20 + (q[0] - px) * 0.55,
                    py - alto - ry * 0.18 + (q[1] - py + alto) * 0.55) for q in canto]
            s += poli(luz, C["granito_luz"], 0.85)
            # O MUSGO nas costas da pedra, a mancha verde do lado de trás.
            s += ('  <ellipse cx="%.1f" cy="%.1f" rx="%.1f" ry="%.1f" fill="%s" '
                  'opacity="0.8"/>\n' % (px - rx * 0.30, py - alto - ry * 0.45,
                                         rx * 0.35, ry * 0.30, C["luz_da_mata"]))
            for k in range(2 if rx > 11.0 else 1):
                vx = px + rx * (r.uniform(-0.2, 0.1) + 0.45 * k)
                s += ('  <path d="M%.1f %.1f q%.1f %.1f %.1f %.1f" stroke="%s" '
                      'stroke-width="1.8" fill="none" stroke-linecap="round"/>\n'
                      % (vx, py - alto + ry * 0.75, rx * 0.06, alto * 0.45, -rx * 0.04,
                         alto * 0.9, C["granito_veio"]))
            xs = [q[0] for q in canto]
            ys = [q[1] for q in canto]
            pedras.append({"x0": round(min(xs) * ZOOM, 1), "x1": round(max(xs) * ZOOM, 1),
                           "y0": round(min(ys) * ZOOM, 1),
                           "y1": round((max(ys) + alto) * ZOOM, 1),
                           "prof": round(mx + my, 3)})
    _PEDRAS = (s, pedras)
    return _PEDRAS


def clareira_em(mx: float, my: float) -> float:
    """Quanto o ponto está aberto, de 0 (mata) a 1 (meio de uma clareira)."""
    melhor = 0.0
    for cx, cy, raio in CLAREIRAS:
        dx, dy = mx - cx, my - cy
        d = math.sqrt(dx * dx + dy * dy)
        if d < raio:
            melhor = max(melhor, _suave((raio - d) / (raio * 0.35)))
    return melhor


def _ruido(x: float, y: float, semente: int) -> float:
    """Ruído de valor em [0, 1), suave, com o sorteio num HASH inteiro.

    Inteiros do Python são exatos e o resto é soma e produto IEEE: sai igual
    em toda máquina, sem `Random` partilhado nem função da libm.
    """
    i0, j0 = math.floor(x), math.floor(y)
    fx, fy = x - i0, y - j0
    ux, uy = fx * fx * (3.0 - 2.0 * fx), fy * fy * (3.0 - 2.0 * fy)

    def canto(i: int, j: int) -> float:
        h = (i * 374761393 + j * 668265263 + semente * 2147483647) & 0xFFFFFFFF
        h = ((h ^ (h >> 13)) * 1274126177) & 0xFFFFFFFF
        return ((h ^ (h >> 16)) & 0xFFFFFF) / 16777216.0

    c00, c10 = canto(i0, j0), canto(i0 + 1, j0)
    c01, c11 = canto(i0, j0 + 1), canto(i0 + 1, j0 + 1)
    em_y0 = c00 + (c10 - c00) * ux
    em_y1 = c01 + (c11 - c01) * ux
    return em_y0 + (em_y1 - em_y0) * uy


def _no_chao_de_tras(mx: float, my: float) -> bool:
    """O ponto cai no solo atrás da rua — onde vivem a vila, o morro e a mata?"""
    return mx <= _borda_em(my) - RUA_RECUO - CALCADA + 0.1


def _cor_do_chao(mx: float, my: float, h: float) -> tuple:
    """A cor do chão de trás num ponto do mundo, com o morro a `h` px.

    ⚠️ O RELVADO SÓ ESCURECE, E QUASE NÃO CLAREIA. A regra que a própria
    `vegetacao_do_solo` registou: «manchas grandes e claras leem como FALHA de
    grama». O claro (`solo_claro`) entra só onde as duas escalas de ruído
    coincidem no alto, que é pouco chão; o resto do campo é solo e solo
    escuro, em manchas largas (1,7 u) com um grão por cima (0,55 u).
    """
    # ⚠️ RODADO FORA DOS EIXOS DO MUNDO: o ruído de valor tem a grelha dele, e
    # alinhada a `mx`/`my` ela projeta-se em LOSANGOS na tela — a primeira
    # foto lia como camuflagem. Três escalas em três ângulos apagam a grelha.
    u, w = 0.8253 * mx - 0.5646 * my, 0.5646 * mx + 0.8253 * my
    largo = _ruido(u / 1.9, w / 1.9, 1)
    medio = _ruido(w / 0.8 + 17.0, -u / 0.8, 2)
    grao = _ruido((mx + my) / 0.32 + 31.0, (mx - my) / 0.32, 3)
    v = 0.56 * largo + 0.29 * medio + 0.15 * grao
    solo, escuro, claro = _rgb(C["solo"]), _rgb(C["solo_escuro"]), _rgb(C["solo_claro"])
    if v < 0.5:
        cor = _entre_rgb(escuro, solo, 0.25 + 0.75 * _suave((v - 0.22) / 0.28))
    else:
        cor = _entre_rgb(solo, claro, 0.5 * _suave((v - 0.64) / 0.2))
    if h <= 0.0:
        return cor

    # O CHÃO DA MATA: sob as copas a luz não chega, e o que se vê entre elas
    # é sombra e folha caída. Escurece a partir do pé, e a luz do sol desenha
    # a encosta — a que olha para o cais clareia, a junta de um degrau escurece.
    t, ux, uy = fundo_do_morro(mx, my)
    a, b = MORRO_SUBIDA
    subida = (a + 2.0 * b * t) / ALTURA_PX_BLENDER
    gx, gy = subida * ux, subida * uy
    sx, sy, sz = SOL_DO_MORRO
    luz = (-gx * sx - gy * sy + sz) / math.sqrt(gx * gx + gy * gy + 1.0) / sz
    # A CLAREIRA (`130`): o chão volta a relva e a sol onde a mata se abre,
    # e é o claro entre as copas que deixa ler a encosta a subir.
    aberta = clareira_em(mx, my)
    cor = _entre_rgb(cor, _rgb(C["chao_mata"]), 0.92 * _suave(t / 1.0) * (1.0 - aberta))
    # AS FOLHAS CAÍDAS E A LUZ QUE PASSA ENTRE AS COPAS (`130`): «o chão da
    # mata é um verde-oliva uniforme», marcou o Bruno. Duas manchas de borda
    # NÍTIDA — o corte do ruído num limiar, pela regra da areia da restinga —,
    # a folhagem castanha em grão miúdo e a luz em pingos maiores.
    if t > 0.25 and aberta < 0.5:
        u, w = 0.8253 * mx - 0.5646 * my, 0.5646 * mx + 0.8253 * my
        folha = _ruido(u / 0.21 + 3.0, w / 0.21, 11)
        cor = _entre_rgb(cor, _rgb(C["folhas_caidas"]),
                         0.55 * _suave((folha - 0.70) / 0.05 + 0.5))
        pingo = _ruido(w / 0.33 - 7.0, -u / 0.33, 12) * _ruido(u / 0.9, w / 0.9, 13)
        cor = _entre_rgb(cor, _rgb(C["luz_da_mata"]),
                         0.65 * _suave((pingo - 0.42) / 0.04 + 0.5))
    k = max(0.70, min(1.18, luz))
    return tuple(max(0, min(255, round(c * k))) for c in cor)


def _cristas_do_mundo() -> list:
    """(my inicial, my final, segmentos) da crista de cada ponta, no MUNDO.

    Cada segmento leva o intervalo de `my` que ocupa, para a conta do pixel
    só olhar os que podem estar a menos de `RESTINGA_MANCHAS` dele.
    """
    out = []
    for j, a, b in praias():
        pts = _pontos_da_praia(*CRISTA[j], a, b)
        segs = []
        for (x0, y0, _q0), (x1, y1, _q1) in zip(pts, pts[1:]):
            segs.append((min(y0, y1) - RESTINGA_MANCHAS, max(y0, y1) + RESTINGA_MANCHAS,
                         x0, y0, x1, y1))
        out.append((a, b, segs))
    return out


def _dentro_da_restinga(mx: float, my: float, cristas: list):
    """A distância do ponto à crista, em unidades, se ele cai no chão da
    restinga — à frente da rua de uma ponta; `None` fora dela.

    O recorte (a crista) é que corta o lado da areia: aqui basta não pintar o
    que é de outro chão. ⚠️ A RAIZ É `math.sqrt`, e não `hypot`: a cor sai
    desta conta, e o CI compara o mapa byte a byte (`mapa.md`).
    """
    for a, b, segs in cristas:
        if not (a - 0.05 <= my <= b + 0.05):
            continue
        borda = _borda_em(my)
        if mx <= borda - RUA_RECUO - CALCADA or mx > borda + 0.2:
            return None
        melhor = RESTINGA_MANCHAS + 1.0
        for y_lo, y_hi, x0, y0, x1, y1 in segs:
            if not (y_lo <= my <= y_hi):
                continue
            dx, dy = x1 - x0, y1 - y0
            n = dx * dx + dy * dy
            t = 0.0 if n == 0.0 else max(0.0, min(1.0, ((mx - x0) * dx + (my - y0) * dy) / n))
            ex, ey = mx - (x0 + dx * t), my - (y0 + dy * t)
            d = math.sqrt(ex * ex + ey * ey)
            if d < melhor:
                melhor = d
        return melhor
    return None


def _areia_da_restinga(mx: float, my: float, d: float) -> float:
    """Quanto de areia aparece no chão da restinga, de 0 a 1.

    Junto da crista a areia domina e a relva entra em línguas; para trás só
    restam manchas soltas, até `RESTINGA_MANCHAS`. É o que faz a duna e o
    relvado passarem um ao outro, em vez da aresta de régua que havia: a
    restinga é areia com planta, não relva com praia ao lado.
    """
    u, w = 0.8253 * mx - 0.5646 * my, 0.5646 * mx + 0.8253 * my
    perto = _suave((RESTINGA_AREIA - d) / 0.8 + (_ruido(u / 0.7 + 5.0, w / 0.7, 8) - 0.5) * 1.3)
    longe = _suave((_ruido(w / 1.1 - 9.0, -u / 1.1, 9) - 0.68) / 0.16) \
        * _suave((RESTINGA_MANCHAS - d) / 1.0) * 0.8
    return max(perto, longe)


def campo_do_chao() -> str:
    """O chão de trás em raster, com textura e o morro, recortado pelo solo.

    É a receita do campo da água (`campos_costeiros`): 720×720 no espaço TELA,
    esticado sobre o `viewBox` de 1080, porque o chão também é campo contínuo
    sem fronteira a afiar — as arestas são o recorte em vetor, por cima.

    ⚠️ CADA COLUNA PINTA-SE DE TRÁS PARA A FRENTE, à maneira do pintor. Com o
    morro, o ponto que se vê num pixel já não é a desprojeção plana dele: o
    chão que sobe projeta-se para cima, e numa junta de degrau o pé anda para
    a frente mais depressa do que a coluna, de modo que a mesma linha da tela
    pode receber dois pontos do mundo. Marcha-se a coluna em passos de
    `PASSO_DO_MORRO` e cada amostra pinta as linhas entre ela e a anterior; a
    da frente, pintada depois, ganha.
    """
    PASSO_DO_MORRO = 0.03
    passo_y = 1.0 / ZOOM
    pe_max = max(b for _a, _b, b in DEGRAUS) - VILA_RECUO_2 - MORRO_PE
    cristas = _cristas_do_mundo()
    seca, clara = _rgb(C["areia_seca"]), _rgb(C["areia"])
    pixels = bytearray(SAIDA * SAIDA * 4)
    for x in range(SAIDA):
        X = (x + 0.5) / ZOOM
        a = (X - CX) / MEIA_LARG                     # mx - my, fixo na coluna
        # As linhas onde o morro pintou: (mx, my, h) por linha.
        linha = [None] * SAIDA
        b = (-30.0 + ALT_CAIS - CY) / MEIA_ALT       # acima do topo, mesmo plano
        y_ant = None
        while True:
            mx, my = (a + b) / 2.0, (b - a) / 2.0
            if mx > pe_max + 0.5:
                break
            h = altura_do_morro(mx, my)
            Y = CY + b * MEIA_ALT - ALT_CAIS - h
            yt = Y * ZOOM
            if h > 0.0 and y_ant is not None:
                lo, hi = sorted((y_ant, yt))
                for yy in range(max(0, math.ceil(lo - 0.5)),
                                min(SAIDA, math.ceil(hi - 0.5) + 1)):
                    linha[yy] = (mx, my, h)
            y_ant = yt if h > 0.0 else None
            if yt > SAIDA + 2:
                break
            b += PASSO_DO_MORRO
        for y in range(SAIDA):
            if linha[y] is not None:
                mx, my, h = linha[y]
            else:
                bb = ((y + 0.5) * passo_y + ALT_CAIS - CY) / MEIA_ALT
                mx, my, h = (a + bb) / 2.0, (bb - a) / 2.0, 0.0
            areia = 0.0
            if not _no_chao_de_tras(mx, my):
                d = _dentro_da_restinga(mx, my, cristas)
                if d is None:
                    continue
                areia = _areia_da_restinga(mx, my, d)
            cor = _cor_do_chao(mx, my, h)
            if areia > 0.0:
                # A areia da restinga é a SECA, e clareia até à da duna junto
                # da crista, para o raster chegar à rampa já na cor dela.
                # ⚠️ COM BORDA, E NÃO EM DEGRADÊ (`130`): misturada pela
                # fração `areia`, 29,5% do chão da restinga saía a meio-tom
                # entre relva e areia, e lia-se como um BORRÃO no meio de um
                # mapa de bordas limpas — «areia da restinga nítida», marcou
                # o Bruno. O campo continua o mesmo; o que muda é cortá-lo num
                # LIMIAR, com um texel de antisserrilhado, e a relva junto da
                # borda escurece um pouco, a saia que o mapa dá a toda peça.
                k_areia = _suave((areia - RESTINGA_LIMIAR) / RESTINGA_BORDA + 0.5)
                if k_areia < 1.0 and areia > RESTINGA_LIMIAR - RESTINGA_SAIA:
                    cor = tuple(round(c * 0.88) for c in cor)
                cor = _entre_rgb(cor, _entre_rgb(seca, clara, _suave(1.0 - d / 0.5)),
                                 k_areia)
            k = (y * SAIDA + x) * 4
            pixels[k:k + 4] = bytes((*cor, 255))

    recorte = []
    for my0, my1, borda in DEGRAUS:
        fundo_da_rua = borda - RUA_RECUO - CALCADA
        recorte.append('<polygon points="%s"/>' % " ".join(
            "%.1f,%.1f" % q for q in (
                p(FUNDO_TERRA, my0, ALT_CAIS), p(fundo_da_rua, my0, ALT_CAIS),
                p(fundo_da_rua, my1 + COSTURA, ALT_CAIS),
                p(FUNDO_TERRA, my1 + COSTURA, ALT_CAIS))))
    # E o chão da restinga, até à crista: o polígono do `praia_chao`.
    for j, a, b in praias():
        crista = linha_da_praia(*CRISTA[j], a, b)
        recorte.append('<polygon points="%s"/>' % " ".join(
            "%.1f,%.1f" % q for q in [p(FUNDO_TERRA, a, ALT_CAIS)] + crista
            + [p(FUNDO_TERRA, b, ALT_CAIS)]))
    return ('  <clipPath id="chao">%s</clipPath>\n  <g clip-path="url(#chao)">\n'
            % "".join(recorte)) + _imagem_embutida(bytes(pixels)) + '  </g>\n'


# ── A MATA DO MORRO: onde cada árvore pousa (`127`) ──────────────────────
#
# As árvores são PROPS do Blender por cima do mapa — o Bruno quis que
# balançassem como os coqueiros —, e um prop por cima do mapa pinta-se por
# cima de TUDO o que o mapa desenhou, a vila incluída. Uma árvore atrás de uma
# casa sairia com a copa por cima do telhado. Logo a regra da implantação não
# é «atrás da vila no mundo», é «acima da vila NA TELA»: cada coluna do PNG
# da árvore, sombra incluída, tem de acabar acima da linha mais alta que a
# vila e as vias pintam naquela coluna.
# ⚠️ E SÓ DO QUE LHE FICA À FRENTE, desde a `130` (`pecas_da_vila`, por lote,
# e `orla_embutida`, árvore a árvore): por coluna o contorno da vila inteira é
# o mínimo, e uma casa lá atrás proibia uma árvore à frente dela.
#
# ⚠️ O CONTORNO DA VILA SAI DO SVG QUE ELA EMITE, e não da geometria dos
# lotes: a caixa-d'água, a cruz da igreja e a copa de um quintal sobem acima
# do telhado, e uma conta pelos lotes esqueceria qualquer peça que se
# acrescente amanhã. Quem desenha diz onde desenhou.
#
# ⚠️ E O PERFIL DE CADA ÁRVORE SAI DO PNG DELA (`arvores_da_mata.json`, que o
# `gerar_props_iso.py` mede ao renderizar), e não do raio da copa: a sombra
# vai para baixo e para a direita do pé, e era ela que tocava o telhado.
MEDIDAS_DA_MATA = pathlib.Path(__file__).resolve().parent.parent \
    / "brport_vs" / "art" / "props" / "arvores_da_mata.json"
SEMENTE_MATA = SEMENTE_CHAO + 600
MATA_FOLGA_VILA = 3          # px de TELA entre o fundo de uma árvore e a vila
# (meia largura, acima, abaixo) em px de TELA: a caixa de um bicho da fauna,
# que se desenha DEPOIS do `Cenario` e pintar-se-ia por cima de uma copa.
MATA_FOLGA_FAUNA = (34, 44, 18)
# (variante, raio da copa em unidades, quantas). OS DESTAQUES vêm primeiro,
# para ficarem à vista: o ipê, o único acento de cor, e as duas silhuetas que
# não são copa — a juçara, que fura o dossel, e a embaúba de folha prateada.
# O raio da juçara e da embaúba é o do tronco que precisa de chão, e não o da
# copa, que passa por cima das outras.
# ⚠️ NA PRIMEIRA ORDEM da `127`, juçaras e embaúbas antes das copas, saíram
# 13 delas contra 2 copas grandes: a mata lia como palmeiral. Por isso são
# poucas, e contadas.
MATA_DESTAQUES = [
    ("arvore_ipe_amarelo", 0.80, 2), ("arvore_ipe_rosa", 0.78, 2),
    ("arvore_jucara_a", 0.30, 3), ("arvore_jucara_b", 0.30, 2),
    ("arvore_embauba_a", 0.40, 2), ("arvore_embauba_b", 0.40, 2),
]
# A MASSA da mata, por SACO e não por ordem (`130`): «parece que a maioria das
# árvores é a mesma», marcou o Bruno — a `127` punha as duas copas escuras em
# levas de 99, e a encosta era a mesma bola em fila. O saco tem cada forma o
# número de vezes da tabela (a regra da vila, `_tirar_do_saco`), e é a
# FORMA que muda de uma árvore para a vizinha: a escura grande, a emergente em
# guarda-chuva, a média, a alta e estreita, e as claras da vila que sobem o
# morro. As três massas de valor que a `127` pedia — escuro, médio, claro —
# saem das proporções: seis escuras, três médias, uma clara.
MATA_MASSA = [
    ("arvore_mata_a", 1.00, 2), ("arvore_mata_c", 1.15, 2),
    ("arvore_mata_b", 0.82, 2), ("arvore_mata_d", 0.62, 2),
    ("arvore_copa_m", 0.85, 1), ("arvore_copa_m2", 0.80, 1),
    ("arvore_copa_alta", 0.55, 1), ("arvore_copa_larga", 1.05, 1),
]
# Px de TELA entre dois destaques da mesma espécie (as variantes `_a` e `_b`
# contam como uma): o acento só acentua enquanto é raro, e dois juntos são uma
# mancha.
MATA_DESTAQUE_LONGE = 55.0
# ⚠️ E A PALMEIRA E A EMBAÚBA NÃO SÃO ACENTO DE COR, são SILHUETA: «poucas
# juçaras e embaúbas», marcou o Bruno na quarta volta, e a conta dava-lhe
# razão — com os 55 px do ipê, das nove pedidas só cabiam DUAS de cada na
# faixa do morro. A 26 px cabem três e quatro, e uma silhueta fina ao lado
# de outra igual continua a ler-se como duas árvores.
MATA_PALMEIRA_LONGE = 26.0
# ⚠️ E CADA FORMA TEM TETO (`130`): o morro visível é uma faixa estreita, e
# nela cabem sobretudo as copas ESTREITAS. Sem teto, a 0,32 de aperto, a alta
# e a escura média deram 12 e 11 das 39 copas, em fila — a mesma árvore em
# parede, que era a queixa.
MATA_TETO = 6
# Os dardos de uma forma que o saco deixou a zero (`arvores_da_mata`).
MATA_DARDOS_DA_QUE_FALTA = 1500
# A copa a partir da qual a forma é GRANDE (raio em unidades), e quantas de
# cada uma se tentam antes do saco.
MATA_GRANDE = 0.80
MATA_GRANDES_PRIMEIRO = 3
# O aperto do sub-bosque: a moita entra na copa da árvore cujo pé tapa.
MATA_APERTO_SUB = 0.12
# O que se tenta no relvado plano entre os degraus, e quantas de cada.
# ⚠️ A MOITA DA MATA É A ESCURA: com dez de cada, as 56 moitas da primeira
# volta (sobretudo a `moita_a`, da paleta clara da vila) fizeram do meio um
# matagal claro, e não mata.
# ⚠️ E NA VOLTA SEGUINTE, «moita demais, árvore de menos» (48 moitas em 82):
# as ARVORETAS — árvore baixa de tronco curto, que cabe onde a moita cabe —
# vêm primeiro, e a moita escura só enche o que sobra.
MATA_DO_RELVADO = [("arvore_arvoreta_a", 0.48, 8), ("arvore_arvoreta_b", 0.42, 8),
                   ("arvore_mata_d", 0.62, 4), ("arvore_copa_p2", 0.45, 3),
                   ("arvore_moita_b", 0.36, 5)]
# ⚠️ E OS DESTAQUES DESCEM AO RELVADO, em JOVENS: «poucas juçaras e
# embaúbas», marcou o Bruno na quarta volta. No morro não cabiam mais, e as
# adultas no relvado pintariam por cima das casas da frente — medido, nem uma
# cabia. A jovem tem o porte da arvoreta e a silhueta da espécie. Vêm antes
# das arvoretas, que senão lhes tomam o chão, e com a distância entre iguais
# das adultas (a jovem conta como da espécie dela, `_especie`).
MATA_DESTAQUES_DO_RELVADO = [("arvore_jucara_c", 0.26, 2), ("arvore_embauba_c", 0.32, 2)]
# ⚠️ E O DESTAQUE SÓ CONTA ONDE SE VÊ (`130`): o mapa começa a 62 px do topo
# da tela, debaixo da barra do HUD, e metade das juçaras e embaúbas do morro
# tinha o pé a y 21–36 — a copa inteira atrás da barra. O topo da copa de um
# destaque fica no máximo a este tanto acima do topo do mapa (a ponta pode
# entrar debaixo da barra; o corpo, não).
MATA_COPA_VISIVEL = -10.0
# ⚠️ E NADA À FRENTE DA COPA DE UM DESTAQUE (`130`): as jovens nasceram no
# relvado e as arvoretas plantadas depois, em tufos à volta delas, taparam-nas
# pela frente — da juçara só se viam as pontas das folhas. Nenhuma árvore fica
# À FRENTE (pé mais abaixo na tela, que é a ordem do `MataNoMapa`) da parte de
# cima de um destaque — a fração da altura dele que é copa, por espécie — em
# mais de `MATA_COPA_TAPADA` da caixa dela. ⚠️ Com 45% da altura para todas
# e nada tapado, caíram sete árvores do morro: 45% de uma juçara adulta é
# quase só estipe, e é a copa dela que fura o dossel por cima das outras.
MATA_DESTACADAS = {"arvore_jucara": 0.30, "arvore_embauba": 0.35,
                   "arvore_ipe_amarelo": 0.55, "arvore_ipe_rosa": 0.55}
MATA_COPA_TAPADA = 0.25
MATA_COPA_TAPADA_ENTRE = 0.65
# ⚠️ E UM DESTAQUE TAPA OUTRO, pela COPA: medido nos pixels pelo D47 §12, a
# embaúba do morro saiu com 90% da copa debaixo da do ipê amarelo, com o pé a
# 7,6 px do dele — a regra só perguntava pelas árvores comuns. Pela caixa
# inteira do da frente, e somando todas as da frente, a regra tirava do morro
# as palmeiras e do relvado as arvoretas (de 63 árvores a 42): o estipe da
# juçara não tapa nada, e a cada aperto o empacotamento desabava em cascata.
# Quantas vezes o saco inteiro se tenta encher: a mata acaba quando acaba o
# chão, e não numa conta.
MATA_SACOS = 12
# As moitas fecham as frestas que sobram entre as copas.
# ⚠️ NA MATA SÓ A MOITA ESCURA (`130`): «moita clara destoa», marcou o
# Bruno — a `moita_a` tem o verde claro da vila e saltava na mata escura. A
# clara fica nos jardins. E poucas: «moita demais, árvore de menos».
MATA_MIUDA = [("arvore_moita_b", 0.36, 4)]
# A copa de uma árvore pode entrar este tanto na da vizinha: a mata FECHA-SE,
# e é a sobreposição que faz dela uma massa em vez de um pomar. Era 0,72 e
# 0,55; a terceira passagem fechou-a mais.
# ⚠️ E A `130` FECHOU-A A 0,34: sem a orla escura embutida, a massa do morro
# passou a ser só a mata que balança, e o que a limita é o CHÃO livre, não os
# dardos (medido: 30 sacos e 400 tentativas dão 41 árvores contra 36). O
# aperto é que enche: 36 árvores a 0,45, 46 a 0,38, 59 a 0,32.
MATA_APERTO = 0.34


def _contornos_do_svg(svg: str):
    """Cada peça do SVG como uma linha fechada de pontos de DESENHO.

    Só os três elementos que a vila e as vias emitem; o arco e a curva entram
    pelo ponto de CONTROLO, que fica sempre do lado de fora — o contorno sai
    um pouco mais alto do que o desenho, nunca mais baixo.

    ⚠️ E ELEMENTO QUE NÃO SABE LER REBENTA. Um `<rect>` ou um `<circle>` que
    a vila passe a emitir ficaria fora do contorno sem uma palavra, e uma
    árvore pintar-se-ia por cima dele — a regra do `.get(chave, omissão)`
    com uma TAG no lugar da chave.
    """
    desconhecidas = set(re.findall(r"<(\w+)", svg)) - {"polygon", "ellipse", "path",
                                                          "use"}
    if desconhecidas:
        raise SystemExit("gerar_mapa_iso: o contorno da vila não sabe ler %s"
                         % ", ".join(sorted(desconhecidas)))
    for m in re.finditer(r'<polygon points="([^"]+)"', svg):
        n = [float(v) for v in re.split(r"[ ,]+", m.group(1).strip())]
        pts = list(zip(n[0::2], n[1::2]))
        yield pts + pts[:1]
    for m in re.finditer(r'<ellipse cx="([-\d.]+)" cy="([-\d.]+)" '
                         r'rx="([-\d.]+)" ry="([-\d.]+)"', svg):
        cx, cy, rx, ry = (float(v) for v in m.groups())
        yield [(cx + rx * math.cos(k * math.tau / 24),
                cy + ry * math.sin(k * math.tau / 24)) for k in range(25)]
    # A ÁRVORE EMBUTIDA (`<use>`) entra pelo PERFIL da espécie — a linha de
    # cima de cada coluna, medida no PNG pelo estúdio —, na escala do `<use>`.
    # O perfil está em px de TELA a contar do pé; o `<use>` em DESENHO.
    medidas = None
    for m in re.finditer(r'<use xlink:href="#(\w+)" transform="translate\(([-\d.]+),'
                         r'([-\d.]+)\) scale\(([-\d.]+)\)"', svg):
        if medidas is None:
            medidas = _medidas_da_mata()
        perfil = medidas[m.group(1)]
        tx, ty, k = float(m.group(2)), float(m.group(3)), float(m.group(4))
        pts = []
        for i, cima in enumerate(perfil["cima"]):
            if cima is None:
                continue
            for borda_col in (0.0, 1.0):
                pts.append((tx + k * (perfil["dx0"] + i + borda_col) / ZOOM,
                            ty + k * cima / ZOOM))
        yield pts
    if len(re.findall(r"<use ", svg)) != len(re.findall(r'<use xlink:href="#\w+" '
                                                         r'transform="translate', svg)):
        raise SystemExit("gerar_mapa_iso: um <use> da vila não tem a forma que o "
                         "contorno sabe ler")
    for m in re.finditer(r' d="([^"]+)"', svg):
        tok = re.findall(r"[A-Za-z]|-?\d+(?:\.\d+)?", m.group(1))
        pts, i, cmd, x, y = [], 0, None, 0.0, 0.0
        while i < len(tok):
            if tok[i].isalpha():
                cmd = tok[i]
                i += 1
                if cmd in "Zz":
                    if pts:
                        pts.append(pts[0])
                    continue
            if cmd in "ML":
                x, y = float(tok[i]), float(tok[i + 1])
                i += 2
            elif cmd == "q":
                cx, cy = x + float(tok[i]), y + float(tok[i + 1])
                pts.append((cx, cy))
                x, y = x + float(tok[i + 2]), y + float(tok[i + 3])
                i += 4
            elif cmd == "A":
                ry = float(tok[i + 1])
                nx, ny = float(tok[i + 5]), float(tok[i + 6])
                pts.append(((x + nx) / 2.0, min(y, ny) - ry))
                x, y = nx, ny
                i += 7
            else:
                raise SystemExit("gerar_mapa_iso: comando de path %r sem leitura"
                                 % cmd)
            pts.append((x, y))
        yield pts


def _envolver(svg: str, topo: list) -> None:
    """Desce `topo` (por coluna de TELA) até à linha mais alta que `svg` pinta.
    Um px de desenho a mais por cima de cada peça: o traço do capim e o
    antisserrilhado saem para fora da linha."""
    for pts in _contornos_do_svg(svg):
        for (x0, y0), (x1, y1) in zip(pts, pts[1:]):
            xa, ya, xb, yb = x0 * ZOOM, (y0 - 1.0) * ZOOM, \
                x1 * ZOOM, (y1 - 1.0) * ZOOM
            if xb < xa:
                xa, ya, xb, yb = xb, yb, xa, ya
            for c in range(max(0, math.floor(xa)),
                           min(SAIDA - 1, math.floor(xb)) + 1):
                if xb == xa:
                    y = min(ya, yb)
                else:
                    e, d = max(xa, c), min(xb, c + 1.0)
                    y = min(ya + (yb - ya) * (e - xa) / (xb - xa),
                            ya + (yb - ya) * (d - xa) / (xb - xa))
                if y < topo[c]:
                    topo[c] = y




def _fauna_da_cena() -> list:
    """(nome, x, y) de TELA de cada bicho do `Main.tscn`, LIDO da cena."""
    texto = CENA_PRINCIPAL.read_text("utf-8")
    achados = re.findall(r'\[node name="(\w+)" parent="MapaWrap/Fauna"[^\]]*\]\s*'
                         r'position = Vector2\(([-\d.]+), ([-\d.]+)\)', texto)
    if not achados:
        raise SystemExit("gerar_mapa_iso: a fauna não está em %s" % CENA_PRINCIPAL)
    return [(n, float(x), float(y)) for n, x, y in achados]


def _especie(variante: str) -> str:
    """A espécie de uma variante: `arvore_jucara_c` e `arvore_jucara_a` são
    a mesma juçara, a jovem e a adulta."""
    return re.sub(r"_[abc]$", "", variante)


def arvores_da_mata() -> list:
    """Onde pousa cada árvore da mata: (variante, mx, my, h, x, y) de TELA.

    Dardos no chão atrás da vila: primeiro os destaques, contados, depois a
    massa da mata por saco até acabar o chão, e as moitas nas frestas. Uma
    árvore fica se: o pé cai no quadro e fora das clareiras; cada coluna do
    PNG dela acaba `MATA_FOLGA_VILA` acima do contorno da vila; não pinta por
    cima de uma pedra que lhe fica à frente; não toca a caixa de nenhum bicho;
    e o pé está a mais de `MATA_APERTO` das duas copas somadas de qualquer
    outra. Sai ordenada pela profundidade — quem tem `mx + my` menor
    desenha-se primeiro.
    """
    perfis = json.loads(MEDIDAS_DA_MATA.read_text("utf-8"))
    fl, fc, fb = MATA_FOLGA_FAUNA
    fauna = [(x - fl, y - fc, x + fl, y + fb) for _n, x, y in _fauna_da_cena()]
    pedras = pedras_do_morro()[1]
    orla = [(_colunas_da_embutida(perfis[v], x, y, k), prof)
            for v, x, y, k, prof in orla_embutida()]
    r = random.Random(SEMENTE_MATA)
    postas = []

    def cabe(variante: str, raio: float, mx: float, my: float,
             sozinha: float = 0.0, aperto: float = MATA_APERTO,
             so_plano: bool = False):
        """(h, x, y) se a árvore pode ficar com o pé em (mx, my), ou `None`.

        `sozinha`: px de TELA até ao destaque mais perto da mesma espécie —
        os dois ipês amarelos saíram COLADOS, e liam um bolo amarelo só. É
        também o que marca um DESTAQUE, que só nasce onde a copa se vê
        (`MATA_COPA_VISIVEL`).
        `aperto`: quanto a copa entra na da vizinha (o sub-bosque entra mais).
        `so_plano`: só no chão plano, fora do morro (as moitas do relvado).
        """
        perfil = perfis[variante]
        largura = len(perfil["baixo"])
        cima = min(v for v in perfil["cima"] if v is not None)
        if mx > _borda_em(my) - VILA_RECUO_2 - 0.1 or clareira_em(mx, my) > 0.0:
            return None
        morro = altura_do_morro(mx, my)
        if so_plano and morro > 0.0:
            return None
        h = ALT_CAIS + morro
        x, y = tela(mx, my, h)
        if not (-10.0 <= x <= SAIDA + 10.0 and 20.0 <= y <= SAIDA):
            return None
        if any(math.hypot(mx - o[1], my - o[2]) < aperto * (raio + o[6]) for o in postas):
            return None
        if sozinha and y + cima < MATA_COPA_VISIVEL:
            return None
        if sozinha and any(_especie(o[0]) == _especie(variante)
                           and math.hypot(x - o[4], y - o[5]) < sozinha
                           for o in postas):
            return None
        topo = _a_frente(mx, my)
        for k in range(largura):
            baixo = perfil["baixo"][k]
            # Com o `x` fracionário a coluna do perfil cai em TRÊS do mapa:
            # o perfil mede o PNG a 768 em colunas de TELA inteiras, e um
            # pixel de 2/3 com o pé a x = 80,8 chega a `c + 2`. ⚠️ ERAM DUAS,
            # e o D47 viu uma árvore 0,8 px por cima de uma embutida que o
            # gerador julgava livre (`130`).
            c = math.floor(x) + perfil["dx0"] + k
            if baixo is None:
                continue
            if any(0 <= cc < SAIDA and y + baixo > topo[cc] - MATA_FOLGA_VILA
                   for cc in (c, c + 1, c + 2)):
                return None
            # A PEDRA E A ÁRVORE EMBUTIDA À FRENTE (`130`): as duas são
            # desenho do mapa, e a árvore de trás, prop, pintar-se-ia por
            # cima delas. As de trás, não: a árvore da frente tapa-as, e é o
            # que se quer. A pedra, aliás, nem a da frente a pode tapar: é a
            # clareira que se quer ver.
            cima_k = perfil["cima"][k]
            for pd in pedras:
                if pd["x0"] - 2 <= c + 1 and c <= pd["x1"] + 2 \
                        and y + baixo > pd["y0"] - 2 and y + cima_k < pd["y1"] + 2:
                    return None
            for cols, prof in orla:
                if prof <= mx + my:
                    continue
                for cc in (c, c + 1, c + 2):
                    e = cols.get(cc)
                    if e is not None and y + baixo > e[0] - MATA_FOLGA_VILA \
                            and y + cima_k < e[1]:
                        return None
        x0, x1 = x + perfil["dx0"], x + perfil["dx0"] + largura
        y0 = y + cima
        y1 = y + max(v for v in perfil["baixo"] if v is not None)
        if any(x0 < b[2] and b[0] < x1 and y0 < b[3] and b[1] < y1 for b in fauna):
            return None
        # A COPA DE UM DESTAQUE À VISTA: o de pé mais abaixo fica à frente, e
        # tapa a copa do de trás — com a caixa inteira, se for uma árvore
        # comum; só com a copa, se for outro destaque.
        destaque = _especie(variante) in MATA_DESTACADAS
        for o in postas:
            outro = _especie(o[0]) in MATA_DESTACADAS
            if o[5] == y or not (destaque if o[5] > y else outro):
                continue
            if o[5] > y:
                copa = _copa_na_tela(variante, x, y)
                frente = _copa_na_tela(o[0], o[4], o[5]) if outro \
                    else _caixa_na_tela(o[0], o[4], o[5])
            else:
                copa = _copa_na_tela(o[0], o[4], o[5])
                frente = _copa_na_tela(variante, x, y) if destaque else (x0, x1, y0, y1)
            tapado = max(0.0, min(frente[1], copa[1]) - max(frente[0], copa[0])) \
                * max(0.0, min(frente[3], copa[3]) - max(frente[2], copa[2]))
            teto = MATA_COPA_TAPADA_ENTRE if (destaque and outro) else MATA_COPA_TAPADA
            if tapado > teto * (copa[1] - copa[0]) * (copa[3] - copa[2]):
                return None
        return h, x, y

    def _copa_na_tela(variante: str, x: float, y: float) -> tuple:
        """A caixa de TELA da COPA de um destaque: a fração de cima da caixa
        dele que a `MATA_DESTACADAS` diz ser copa."""
        cx0, cx1, cy0, cy1 = _caixa_na_tela(variante, x, y)
        return (cx0, cx1, cy0, cy0 + MATA_DESTACADAS[_especie(variante)] * (cy1 - cy0))

    def _caixa_na_tela(variante: str, x: float, y: float) -> tuple:
        pf = perfis[variante]
        a = x + pf["dx0"]
        return (a, a + len(pf["baixo"]), y + min(v for v in pf["cima"] if v is not None),
                y + max(v for v in pf["baixo"] if v is not None))

    def por(variante: str, raio: float, mx: float, my: float, onde: tuple) -> None:
        h, x, y = onde
        postas.append((variante, round(mx, 3), round(my, 3), round(h, 2),
                       round(x, 1), round(y, 1), raio))

    def plantar(variante: str, raio: float, tentativas: int, solta: bool = False,
                **regras) -> bool:
        for _ in range(tentativas):
            # ⚠️ EM TUFOS, E NÃO ESPALHADA POR IGUAL (`127`): a pesquisa
            # repete que mata espalhada por igual lê como plantação. Sete
            # dardos em dez nascem junto de uma árvore já posta; os outros
            # abrem tufos novos.
            # ⚠️ MENOS A `solta` (`130`): o destaque do relvado nasce antes
            # das árvores do relvado, e os dardos junto de uma já posta caíam
            # no morro — 621 das 800 tentativas das jovens morriam no «só no
            # plano», e nenhuma nasceu.
            if postas and not solta and r.random() < 0.7:
                o = postas[r.randrange(len(postas))]
                a = r.uniform(0.0, math.tau)
                d = r.uniform(0.9, 1.5) * (raio + o[6]) * MATA_APERTO
                mx, my = o[1] + d * math.cos(a), o[2] + d * math.sin(a)
            else:
                my = r.uniform(-4.0, 20.0)
                mx = r.uniform(FUNDO_TERRA + 2.0, _borda_em(my) - VILA_RECUO_2 - 0.1)
            onde = cabe(variante, raio, mx, my, **regras)
            if onde is not None:
                por(variante, raio, mx, my, onde)
                return True
        return False

    for variante, raio, quantas in MATA_DESTAQUES:
        for _ in range(quantas):
            plantar(variante, raio, 300, sozinha=MATA_DESTAQUE_LONGE if "ipe" in variante
                    else MATA_PALMEIRA_LONGE)
    # AS GRANDES PRIMEIRO: a copa larga não cabe onde as estreitas já
    # estão, e com o saco baralhado desde o início saíam duas grandes em 39.
    contas = collections.Counter()
    for v, raio, _n in sorted(MATA_MASSA, key=lambda q: -q[1]):
        if raio >= MATA_GRANDE:
            for _ in range(MATA_GRANDES_PRIMEIRO):
                if plantar(v, raio, 300):
                    contas[v] += 1
    saco = [(v, raio) for v, raio, n in MATA_MASSA for _ in range(n)]
    for _ in range(MATA_SACOS):
        r.shuffle(saco)
        feitas = 0
        for v, raio in saco:
            if contas[v] < MATA_TETO and plantar(v, raio, 120):
                contas[v] += 1
                feitas += 1
        if not feitas:
            break
    # ⚠️ E TODA FORMA ENTRA AO MENOS UMA VEZ (`130`): com a copa de folhas e a
    # regra dos destaques, o saco deixou a escura grande e a escura alta a
    # zero — a encosta perdia duas das seis formas, que era a queixa da
    # primeira volta («a maioria das árvores é a mesma»), e a folha dos props
    # ficava sem chão para elas. A que faltar tenta outra vez, com mais dardos.
    for v, raio, _n in MATA_MASSA:
        if not contas[v] and plantar(v, raio, MATA_DARDOS_DA_QUE_FALTA):
            contas[v] += 1
    # O SUB-BOSQUE (`130`): «troncos em fila», marcou o Bruno — na borda da
    # mata virada para a vila, os troncos das copas ficavam à mostra em
    # paliçada. Uma moita no pé, À FRENTE de cada árvore (para o cais e para
    # a esquerda da tela), a entrar-lhe na copa; onde a vila à frente não a
    # deixa caber, fica o tronco.
    altas = [o for o in postas if "moita" not in o[0]]
    for i, o in enumerate(sorted(altas, key=lambda q: -(q[1] + q[2]))):
        # Uma em cada três árvores fica sem moita no pé: o sub-bosque de todas
        # é uma fileira de moitas a seguir a fileira de troncos.
        if i % 3 == 2:
            continue
        variante, raio = MATA_MIUDA[0][:2]
        for _ in range(6):
            mx = o[1] + r.uniform(0.25, 0.60)
            my = o[2] + r.uniform(-0.25, 0.45)
            onde = cabe(variante, raio, mx, my, aperto=MATA_APERTO_SUB)
            if onde is not None:
                por(variante, raio, mx, my, onde)
                break
    for variante, raio, quantas in MATA_MIUDA:
        for _ in range(quantas):
            plantar(variante, raio, 300)
    # A MATA DO RELVADO (`130`): «mata parada no meio», marcou o Bruno — a
    # massa do relvado entre os degraus era toda embutida. Onde uma moita que
    # balança cabe sem pintar por cima da vila, a orla deixa-lhe o sítio
    # (`quintal_de_tras`), e é aqui que ela nasce, só no chão plano: primeiro
    # as árvores pequenas que lá couberem, depois as moitas.
    for variante, raio, quantas in MATA_DESTAQUES_DO_RELVADO:
        for _ in range(quantas):
            plantar(variante, raio, 1200, solta=True, so_plano=True,
                    sozinha=MATA_PALMEIRA_LONGE)
    for variante, raio, quantas in MATA_DO_RELVADO:
        for _ in range(quantas):
            plantar(variante, raio, 400, so_plano=True)
    postas.sort(key=lambda o: (o[1] + o[2], o[2]))
    return [o[:6] for o in postas]


# ── A RESTINGA DAS PONTAS: onde pousa cada planta (`127`) ─────────────────
#
# Os mesmos props que balançam, entre a rua e a duna. Aqui o perigo não é a
# vila: a restinga está À FRENTE da rua, e uma copa que suba por cima do
# asfalto ou de um telhado está certa. E também não é a areia à frente, e
# isso foi medido no erro: a primeira versão exigia a planta inteira, SOMBRA
# incluída, acima da crista, e a restinga ficou com as plantas todas
# encostadas à rua — a faixa tem 33 px de alto numa coluna e a sombra desce
# 10 abaixo do pé. Chão plano à frente nunca tapa um prop: o pixel do prop
# acima do pé está À FRENTE do chão que cobre, e a sombra abaixo dele é
# sombra no chão, que é onde ela cai. O que fica é o PÉ na restinga — o
# desenho opaco não desce à areia —, e quem o confere é o D47.
# ⚠️ A CRISTA À FRENTE, e não a mais alta da coluna: a ponta sul vira a
# esquina de dois degraus, e na mesma coluna a areia do degrau de trás fica
# ACIMA da restinga do da frente — um contorno por coluna, como o da vila,
# recusava-a.
SEMENTE_RESTINGA = SEMENTE_CHAO + 620
# (variante, raio, quantas POR PONTA, dentro mínimo, dentro máximo): o
# «dentro» conta-se da crista para terra, e põe cada espécie na faixa dela —
# o guriri e a moita pequena junto da duna, a aroeira grande lá atrás, contra
# a rua. ⚠️ POR PONTA: com a quota das duas juntas, a primeira ponta a
# receber dardos levava quase tudo.
RESTINGA_ESPECIES = [
    ("arvore_aroeira_a", 0.50, 4, 1.5, 9.0),
    ("arvore_aroeira_b", 0.40, 4, 0.9, 9.0),
    ("arvore_moita_a", 0.45, 4, 0.8, 9.0),
    ("arvore_guriri_a", 0.32, 4, 0.30, 1.8),
    ("arvore_guriri_b", 0.26, 4, 0.25, 1.5),
    ("arvore_moita_b", 0.36, 4, 0.4, 9.0),
]
# A restinga NÃO fecha, ao contrário da mata: entre as moitas há areia.
RESTINGA_APERTO = 0.85
# Px de TELA entre o pé de uma planta e a crista à frente. ⚠️ ERA 2, e o
# guriri da `130` — pecíolos que saem do chão — tem desenho opaco 2 px abaixo
# do pé: o D47 leu-o a 0,01 px dentro da areia. O gerador é mais folgado do
# que a guarda (`mapa.md`).
RESTINGA_FOLGA_AREIA = 3
RESTINGA_TOPO = 4            # px de TELA: nenhuma copa acima, que é a barra do HUD
# A caixa de um prop PARADO do `Cenario` (os camiões andam e a profundidade
# resolve-os), em px de TELA a partir do pé dele: (esquerda, cima, direita,
# baixo). O gerador só lê a CENA, e não os PNG; as caixas são as medidas em
# 17/10 com um px de folga — a do coqueiro, e para os outros a do escritório,
# o maior prop perto de uma ponta. ⚠️ A PRIMEIRA ERA UMA SÓ, a maior de todas
# (o armazém aos lados), e apagava meia ponta sul. E a do coqueiro não leva
# a SOMBRA dele, que desce 60 px pelo chão: uma planta por cima dela, ou ela
# por cima de uma planta, é a profundidade a decidir, como entre quaisquer
# dois props; o que não se quer é uma copa a tapar o tronco. Quem confere no
# desenho OPACO de cada PNG é o D47.
RESTINGA_CAIXA_COQUEIRO = (49, 72, 41, 8)
RESTINGA_CAIXA_PROP = (34, 41, 52, 44)


def _props_parados_da_cena() -> list:
    """(nome, x, y) de TELA do pé de cada prop parado do `Cenario`."""
    texto = CENA_PRINCIPAL.read_text("utf-8")
    achados = re.findall(r'\[node name="(\w+)" type="TextureRect" '
                         r'parent="MapaWrap/Cenario"\]\s*layout_mode = 0\s*'
                         r'offset_left = ([-\d.]+)\s*offset_top = ([-\d.]+)', texto)
    if not achados:
        raise SystemExit("gerar_mapa_iso: o Cenario não está em %s" % CENA_PRINCIPAL)
    return [(n, float(x) + 256.0, float(y) + 256.0) for n, x, y in achados
            if not n.startswith("Caminhao")]


def cristas_da_tela() -> list:
    """A crista de cada ponta em px de TELA — a linha onde a areia começa."""
    return [[(round(x * ZOOM, 1), round(y * ZOOM, 1))
             for x, y in linha_da_praia(*CRISTA[j], a, b)] for j, a, b in praias()]


def crista_a_frente(crista: list, c: float, y_pe: float):
    """O `y` onde a crista corta a coluna `c` ABAIXO do pé, ou `None`.

    Abaixo do pé com 3 px de folga para cima: o pé de uma planta junto da
    duna pode estar um triz abaixo da crista sorteada da vizinha.
    """
    melhor = None
    for (x0, y0), (x1, y1) in zip(crista, crista[1:]):
        if x1 < x0:
            x0, y0, x1, y1 = x1, y1, x0, y0
        if not (x0 <= c <= x1) or x1 == x0:
            continue
        y = y0 + (y1 - y0) * (c - x0) / (x1 - x0)
        if y >= y_pe - 3.0 and (melhor is None or y < melhor):
            melhor = y
    return melhor


def arvores_da_restinga() -> list:
    """Onde pousa cada planta da restinga: (variante, mx, my, h, x, y) de TELA.

    Dardos entre a crista e a rua, ponta a ponta, metade em tufos junto de
    uma já posta. Uma planta fica se: o pé e a copa cabem no quadro; o pé
    fica `RESTINGA_FOLGA_AREIA` acima da crista que tem à frente; não toca a
    caixa de um bicho nem a de um prop parado; e fica a mais de
    `RESTINGA_APERTO` das duas copas somadas de qualquer outra.
    """
    perfis = _medidas_da_mata()
    fl, fc, fb = MATA_FOLGA_FAUNA
    caixas = [(x - fl, y - fc, x + fl, y + fb) for _n, x, y in _fauna_da_cena()]
    for n, x, y in _props_parados_da_cena():
        el, ec, ed, eb = RESTINGA_CAIXA_COQUEIRO if n.startswith("Coqueiro") \
            else RESTINGA_CAIXA_PROP
        caixas.append((x - el, y - ec, x + ed, y + eb))
    cristas = cristas_da_tela()
    recuos = recuos_das_praias()
    fundo = RUA_RECUO - RUA_LARG - CALCADA - PRAIA_PROF - 0.15
    # ⚠️ O «dentro» CONTA-SE DA COSTA, E A RUA NÃO A SEGUE. Junto do salto de
    # um degrau a costa corre em `my` (o espelho) e a rua vira noutro sítio
    # (o cotovelo): a primeira implantação pôs seis aroeiras no asfalto da
    # ponta norte, e quem o disse foi o D2. O pé tem de cair à frente da rua
    # do degrau DELE, fora dos cotovelos, e aquém do cerco da areia que a
    # tabela publica (o D15).
    cotovelos = [(borda - RUA_RECUO - CALCADA, DEGRAUS[i + 1][2] - RUA_RECUO + RUA_LARG
                  + CALCADA, my1 - RUA_LARG - CALCADA, my1 + CALCADA)
                 for i, (_my0, my1, borda) in enumerate(DEGRAUS[:-1])]
    r = random.Random(SEMENTE_RESTINGA)
    bases = []
    for j, a, b in praias():
        for mx, my, (nmx, nmy), _t in andar_costa(-PRAIA_PROF, (0.25, 0.45), r):
            if a <= my <= b and no_quadro(mx, my):
                bases.append((j, mx, my, nmx, nmy))
    postas = []
    for ponta in range(len(cristas)):
        daqui = [q for q in bases if q[0] == ponta]
        if not daqui:
            continue
        for variante, raio, quantas, d0, d1 in RESTINGA_ESPECIES:
            perfil = perfis[variante]
            largura = len(perfil["baixo"])
            cima = min(v for v in perfil["cima"] if v is not None)
            baixo_max = max(v for v in perfil["baixo"] if v is not None)
            feitas = 0
            for _ in range(600):
                if feitas >= quantas:
                    break
                j, mx, my, nmx, nmy = daqui[r.randrange(len(daqui))]
                vizinhas = [o for o in postas if o[7][0] == ponta]
                if vizinhas and r.random() < 0.5:
                    j, mx, my, nmx, nmy = vizinhas[r.randrange(len(vizinhas))][7]
                dentro = r.uniform(d0, min(d1, fundo))
                ax, ay = mx - nmx * dentro, my - nmy * dentro
                borda = _borda_em(ay)
                if not (borda - RUA_RECUO + RUA_LARG + CALCADA + 0.15 <= ax
                        <= borda - recuos[j] - 0.02):
                    continue
                if any(c0 - 0.15 <= ax <= c1 + 0.15 and c2 - 0.15 <= ay <= c3 + 0.15
                       for c0, c1, c2, c3 in cotovelos):
                    continue
                x, y = tela(ax, ay, ALT_CAIS)
                if not (0.0 <= x <= SAIDA and y + cima >= RESTINGA_TOPO
                        and y <= SAIDA - 4):
                    continue
                if any(math.hypot(ax - o[1], ay - o[2]) < RESTINGA_APERTO * (raio + o[6])
                       for o in postas):
                    continue
                # ⚠️ E NA TELA: três aroeiras saíram na MESMA coluna, uma atrás
                # da outra a 15 px, e liam como uma torre de copas — longe no
                # mundo, empilhadas na vista. A 26 px ainda saíam duas.
                # ⚠️ E A 34 AINDA SAÍAM (`130`): «aroeiras empilhadas», marcou o
                # Bruno — duas na mesma coluna a 37 px na ponta norte, e duas
                # COLADAS lado a lado a 14 px na borda da ponta sul, que a
                # coluna de 12 px deixava passar. A copa da aroeira tem ~40 px
                # de largo: em coluna, 16 px e 44 de altura; lado a lado, 22 px.
                if any((abs(x - o[4]) < 16.0 and abs(y - o[5]) < 44.0)
                       or (abs(x - o[4]) < 22.0 and abs(y - o[5]) < 14.0)
                       for o in postas):
                    continue
                # O PÉ na restinga: as colunas do tronco acabam acima da crista.
                if any(frente is None or y > frente - RESTINGA_FOLGA_AREIA
                       for frente in (crista_a_frente(cristas[j], c, y)
                                      for c in (x - 2.0, x, x + 2.0))):
                    continue
                x0, x1 = x + perfil["dx0"], x + perfil["dx0"] + largura
                y0, y1 = y + cima, y + baixo_max
                if any(x0 < q[2] and q[0] < x1 and y0 < q[3] and q[1] < y1
                       for q in caixas):
                    continue
                postas.append((variante, round(ax, 3), round(ay, 3), ALT_CAIS,
                               round(x, 1), round(y, 1), raio, (j, mx, my, nmx, nmy)))
                feitas += 1
    # ⚠️ A SUBESTAÇÃO MUDA DE SÍTIO A PLANTA QUE CAI NO LOTE DELA, DEPOIS DO
    # SORTEIO (quinta passagem da `140`, *«fora da areia, no relvado»*): o
    # relvado do campo norte é estreito, e ela só cabe inteira nele no sítio da
    # aroeira, que o Bruno deixou mudar de lugar. Recusar o dardo DURANTE o
    # sorteio mudaria todos os seguintes, nas duas pontas (`mapa.md`, o sorteio
    # novo vem de um `Random` novo); mudada no fim, as outras ficam onde
    # estavam. Vai para `PLANTA_FORA_DA_SUBESTACAO`, e o D47 confere-a como a
    # qualquer outra.
    tiradas = [o for o in postas if _no_lote_da_subestacao(o[1], o[2])]
    if len(tiradas) > 1:
        raise SystemExit("gerar_mapa_iso: %d plantas no lote da subestação, e só "
                         "há sítio para uma" % len(tiradas))
    postas = [o for o in postas if not _no_lote_da_subestacao(o[1], o[2])]
    for o in tiradas:
        ax, ay = PLANTA_FORA_DA_SUBESTACAO
        x, y = tela(ax, ay, ALT_CAIS)
        postas.append((o[0], ax, ay, ALT_CAIS, round(x, 1), round(y, 1)) + o[6:])
    postas.sort(key=lambda o: (o[1] + o[2], o[2]))
    return [o[:6] for o in postas]


# O pé da planta que a subestação tira do lote dela (a aroeira): um ponto
# que cumpre as regras do sorteio — a crista da praia à frente nas três
# colunas do tronco, a folga da rua, o aperto e a pilha na tela contra as
# outras plantas — e cuja copa não toca, na tela, a caixa da subestação, do
# pórtico, da torre, dos postes nem a de um bicho (medido numa grelha de
# 0,05). A sul da cerca, a (1,6, 0,5), faltava a crista; a leste, a (4,0,
# −2,6), a copa caía no quero-quero: o D47 reprovou os dois. Fica a norte da
# torre, a 3,2 de onde estava, no meio de uma faixa de 21 pontos válidos.
PLANTA_FORA_DA_SUBESTACAO = (2.9, -5.0)


def _no_lote_da_subestacao(mx: float, my: float) -> bool:
    """O pé (mx, my) cai na caixa da subestação, com a folga de meia copa da
    aroeira à volta (a `FOLGA_DA_PLANTA` do D45)?"""
    (cx, cy), (lx, ly) = SUBESTACAO, SUBESTACAO_TAM
    return abs(mx - cx) < lx / 2.0 + 0.3 and abs(my - cy) < ly / 2.0 + 0.3


def recuos_das_praias() -> list:
    """O cerco da areia de cada ponta, em unidades da beira do cais para dentro:
    o MAIOR recuo que a crista desenhada alcança, com um centésimo de folga.

    A tabela publica-o (o D15 não deixa equipamento de porto na areia), e a
    restinga não planta para lá dele — o mesmo número dos dois lados.
    """
    out = []
    for _j, my_a, my_b in praias():
        fundo = 0.0
        v, comp, _arc, _qs = _geometria_da_costa()
        for i in range(len(v) - 1):
            # ⚠️ SÓ OS MUROS. Medir `borda - mx` no ESPELHO de um degrau dá 4
            # unidades de "recuo" e não quer dizer nada: ali a praia corre em
            # `my`, não em `mx`, e a primeira versão desta medição publicou um
            # cerco de 5,01 que chamaria areia a meio pátio. O cerco é em `mx`
            # desde que existe, e é em `mx` que ele se mede.
            if abs(v[i + 1][0] - v[i][0]) > 1e-9:
                continue
            n = max(1, int(math.ceil(comp[i] / 0.05)))
            for k in range(n + 1):
                f = k / n
                base_my = v[i][1] + (v[i + 1][1] - v[i][1]) * f
                desvio = PRAIA_PROF * CRISTA[_j][1] * _meandro(base_my,
                                                               CRISTA[_j][2])
                mx, my, _n, _t = ponto_costeiro(i, f, -(PRAIA_PROF + desvio))
                # E só onde a amostra continua no degrau do seu próprio muro:
                # dentro do fileto a crista dá a volta à quina e entra no `my`
                # do degrau seguinte, onde `borda` salta 4 unidades de uma vez
                # e a subtração deixa de querer dizer o que diz.
                if my_a <= my <= my_b and abs(_borda_em(my) - v[i][0]) < 1e-9:
                    fundo = max(fundo, _borda_em(my) - mx)
        out.append(round(fundo + 0.01, 3))
    return out


def plantas_do_mapa() -> list:
    """A mata do morro e a da restinga, cada uma com o chão dela:
    (variante, mx, my, h, x, y, chão). É a lista que o `MataNoMapa.gd` copia."""
    return [(*o, "morro") for o in arvores_da_mata()] \
        + [(*o, "restinga") for o in arvores_da_restinga()]


# ── AS ÁRVORES EMBUTIDAS: o desenho do Blender DENTRO do mapa (`127`) ─────
#
# Segunda passagem: o Bruno marcou «árvores dos quintais» (as copas em SVG da
# vila, no desenho antigo) e pediu no «Outro» árvores «no meio da cidade
# para não ficar sem nada», em tamanhos diferentes. Um prop por cima do mapa
# não pode ficar atrás de uma casa; dentro do SVG, na ordem em que a `vila()`
# desenha, pode — atrás de uma e à frente de outra. O preço é não balançar:
# quem balança é a mata do morro, que é prop.
#
# Cada espécie entra UMA vez num `<defs>` — o recorte que o estúdio de props
# guardou no `arvores_da_mata.json` — e cada árvore é um `<use>` com a escala
# dela. 1 px do PNG é 1 px de DESENHO (768 de PNG para 512 de tela, e o
# desenho é a tela a 1,5), e o pé é o centro do quadro do PNG.
_ARVORES_USADAS = set()
_MEDIDAS = None


def _medidas_da_mata() -> dict:
    global _MEDIDAS
    if _MEDIDAS is None:
        _MEDIDAS = json.loads(MEDIDAS_DA_MATA.read_text("utf-8"))
    return _MEDIDAS


_EMBUTIDAS = []


def arvore_embutida(variante: str, mx: float, my: float, escala: float,
                    h: float = ALT_CAIS) -> str:
    """Uma árvore do Blender no mapa, com o pé em (mx, my) à altura `h`."""
    _medidas_da_mata()[variante]          # rebenta se a espécie não existir
    _ARVORES_USADAS.add(variante)
    bx, by = p(mx, my, h)
    _EMBUTIDAS.append((variante, round(bx * ZOOM, 1), round(by * ZOOM, 1), escala,
                       round(mx + my, 3)))
    return ('  <use xlink:href="#%s" transform="translate(%.1f,%.1f) scale(%.3f)"/>\n'
            % (variante, bx, by, escala))


def _sob_a_casa(variante: str, mx: float, my: float, escala: float,
                casa: list) -> float:
    """A fração da COPA de uma árvore embutida que cai abaixo da linha de cima
    da casa `casa` (o contorno por coluna de TELA, `_envolver`): tapada, se a
    árvore está atrás; por cima do telhado, se está à frente.

    A copa é a parte de cima do perfil — 70% da altura dele: o resto é tronco
    e sombra, que estão no chão e não sobre a casa.
    """
    perfil = _medidas_da_mata()[variante]
    bx, by = p(mx, my, ALT_CAIS)
    x, y = bx * ZOOM, by * ZOOM
    total = sob = 0.0
    for i, (cima, baixo) in enumerate(zip(perfil["cima"], perfil["baixo"])):
        if cima is None:
            continue
        c = math.floor(x + escala * (perfil["dx0"] + i))
        y0 = y + escala * cima
        y1 = y + escala * (cima + 0.7 * (baixo - cima))
        total += y1 - y0
        if 0 <= c < SAIDA and casa[c] < y1:
            sob += y1 - max(y0, casa[c])
    return sob / total if total > 0.0 else 0.0


def arvore_da_cidade(mx: float, my: float, raio: float, r: random.Random,
                     luz: float = 0.5, teto: float = 0.8, casa: list = None,
                     atras: bool = False, sem_ipe: bool = False) -> str:
    """A árvore de um quintal ou da praça, com a assinatura da antiga `arvore()`
    em SVG (que saiu na `127`, com a restinga): quem a chamava não mudou.

    O `raio` escolhe o tamanho, a `luz` qual das duas variantes de cada um, e
    um sorteio a espécie.
    ⚠️ TERCEIRA PASSAGEM (`127`): «árvores repetidas» pediu a segunda
    variante de cada tamanho; «mais cor na vila», os ipês e a mangueira;
    «árvores demais», um teto de escala.
    ⚠️ E A QUARTA: «pode variar as árvores na vila com versões menores das
    maiores… parece que estão muito grandes». Medido antes de mexer: a casa
    térrea tem ~22 px de alto e ~50 de largo; a copa pequena da vila, a 0,62,
    24 por 22 — mais estreita do que a casa, o que no mundo real (copa de
    mangueira ~10 m, casa ~7 m) é o contrário. O peso vinha da densidade e das
    copas ao lado da casa. Entraram a copa ESCURA da mata e a mangueira em
    pequeno, e o teto desceu de 1,0 para 0,8 (0,65 ao lado da casa).
    """
    sorte = r.random()
    # ⚠️ O IPÊ SUBIU DE 7% PARA 12% DO SORTEIO (`130`): com a regra da casa e a
    # da praça, a vila do dia 1 ficou sem ipê nenhum à vista — o acento de cor
    # que o Bruno pediu na `127` («mais cor na vila»). O sorteio é o mesmo, e
    # muda só onde se corta.
    if sorte < 0.07:
        variante, nominal = "arvore_ipe_amarelo", 0.62
    elif sorte < 0.12:
        variante, nominal = "arvore_ipe_rosa", 0.62
    elif sorte < 0.17:
        variante, nominal = "arvore_mangueira", 0.72
    elif sorte < 0.22:
        variante, nominal = "arvore_jucara_b", 0.60
    elif sorte < 0.40:
        variante = "arvore_mata_b" if luz < 0.5 else "arvore_mata_a"
        nominal = 0.80
    elif raio < 0.40:
        variante = "arvore_copa_p" if luz < 0.5 else "arvore_copa_p2"
        nominal = 0.48
    else:
        variante = "arvore_copa_m" if luz < 0.5 else "arvore_copa_m2"
        nominal = 0.66
    # ⚠️ NA PRAÇA E NOS LOTES ESPECIAIS, O IPÊ É COPA (`130`): o do quintal de
    # trás do lote da praça ficava 55% atrás das árvores dela, desenhadas
    # depois — o D47 §10 viu-o —, e a regra da casa não chega a um lote sem
    # casa. O sorteio é o mesmo; só a espécie muda.
    if sem_ipe and variante.startswith("arvore_ipe"):
        variante, nominal = "arvore_copa_m2", 0.66
    escala = max(0.45, min(teto, raio / nominal))
    # ⚠️ A CASA DO LOTE DECIDE SE A ÁRVORE SE LÊ (`130`). «Árvore no telhado,
    # ipê escondido», marcou o Bruno: uma copa da mata a 0,45 no quintal do
    # LADO pousava inteira em cima do telhado da casa, e um ipê no quintal de
    # TRÁS só mostrava um bolo amarelo acima da cumeeira. À frente da casa,
    # copa que cobre mais de um terço do telhado vira a moita do jardim; atrás
    # dela, árvore que a casa esconde mais de 60% não se planta — e o ipê,
    # que é acento e não massa, só vai com 60% da copa à vista (o D47 §10
    # exige metade da flor: o gerador é o mais apertado dos dois). A 70% a
    # vila do dia 1 ficou sem ipê nenhum. Sem sorteio
    # novo: os do `r` já foram gastos, e a vila não muda de sítio.
    if atras:
        # A de trás pergunta a TODAS as casas que lhe ficam à frente, e não só
        # à do lote: o ipê rosa da `130` passou a regra da casa dele com 39% de
        # copa tapada e saiu um bolo acima de DOIS telhados — o da vizinha,
        # desenhada depois, tapava o resto (o D47 §10 viu-o a 38% à vista).
        casa = _casas_a_frente(mx, my)
    if casa is not None:
        tapado = _sob_a_casa(variante, mx, my, escala, casa)
        if atras and tapado > (0.40 if variante.startswith("arvore_ipe") else 0.60):
            return ""
        if not atras and tapado > 0.35:
            variante, escala = "arvore_moita_a", 0.8
    return arvore_embutida(variante, mx, my, round(escala, 3))


def _com_as_arvores(svg: str) -> str:
    """Põe o `<defs>` das espécies usadas logo a seguir à raiz do SVG."""
    if not _ARVORES_USADAS:
        return svg
    medidas = _medidas_da_mata()
    defs = ["  <defs>"]
    for v in sorted(_ARVORES_USADAS):
        x0, y0, larg, alt = medidas[v]["recorte"]
        defs.append('<image id="%s" x="%d" y="%d" width="%d" height="%d" '
                    'preserveAspectRatio="none" xlink:href="data:image/png;base64,%s"/>'
                    % (v, x0 - 384, y0 - 384, larg, alt, medidas[v]["png"]))
    defs.append("</defs>\n")
    ini = svg.index("\n") + 1
    return svg[:ini] + "".join(defs) + svg[ini:]


# Unidades atrás do fundo dos lotes, e a parte da frente, que é quintal; a de
# trás é mata escura (a «mata do morro maior» da `127`).
# ⚠️ A MATA ESCURA EMBUTIDA COMEU O MORRO enquanto o contorno da vila a
# contava (`horizonte_da_vila`): por coluna ele é o MÍNIMO, ela subia-o acima
# do topo da tela, e as 21 árvores do morro couberam nos 31 px da borda
# esquerda (5.589 px² de morro livre, contra 24.139 sem orla). Na `130` o
# contorno deixou de a contar, a mata do morro pergunta-lhe árvore a árvore
# pela profundidade, e ela só se embute onde um prop não pode estar — o
# relvado da junta de dois degraus, à frente de casas de trás. Encolhida a
# 0,9 nessa passagem, deixou esse relvado vazio, e a encosta perdeu a massa.
ORLA_DO_QUINTAL = 3.0
ORLA_DA_MATA = 0.9
ORLA_SEBE = ("arvore_moita_b", "arvore_copa_p2", "arvore_arvoreta_a", "arvore_copa_p")
ORLA_FORMAS = ("arvore_mata_a", "arvore_mata_b", "arvore_mata_c", "arvore_mata_d",
               "arvore_copa_m", "arvore_copa_alta")


def quintal_de_tras(indice: int, my0: float, my1: float, borda: float) -> str:
    """A faixa de relva entre o fundo dos lotes e o pé do morro, com mata baixa.

    O Bruno marcou-a vazia na primeira passagem. É chão ATRÁS da vila — sai
    antes dela, e a vila tapa o que deve tapar —, mas À FRENTE da mata do
    morro, que é prop e não lhe pode pintar por cima (`orla_embutida`).
    Moitas e árvores pequenas, numa ORLA de `ORLA_DO_QUINTAL` atrás dos
    lotes.

    ⚠️ A PRIMEIRA VERSÃO IA ATÉ AO PÉ DO MORRO, e a mata que balança ficou com
    12 árvores, quase todas moitas: o que se embute à frente sobe o contorno,
    e o morro ficava sem chão para os props. A orla é a vila a desfiar-se em
    quintal; o morro é da mata.
    """
    r = random.Random(SEMENTE_CHAO + 610 + indice)
    fundo = borda - VILA_RECUO_2
    postas = []
    s = ""
    for _ in range(260):
        my = r.uniform(my0, my1)
        mx = r.uniform(fundo - ORLA_DO_QUINTAL, fundo - 0.25)
        if not no_quadro(mx, my):
            continue
        # ⚠️ EM TUFOS, COM RELVA ENTRE ELES (`130`, «moitas em fileira»): a
        # orla corre ao longo do fundo dos lotes, e cheia de ponta a ponta lia
        # uma sebe plantada. Um ruído largo do sítio abre-lhe vãos — sem gastar
        # sorteio, que a orla ficava toda noutro sítio.
        if _ruido(my * 1.4 + 3.0, mx * 1.4, 24) < 0.42:
            continue
        # ⚠️ NO MORRO, PARA LÁ DO QUINTAL, NÃO SE EMBUTE NADA (`130`): cada
        # copa parada atrás das casas obrigava a mata do morro a subir acima
        # dela, e com a orla de 3,0 inteira embutida as que balançam voltaram
        # todas aos 35 px da borda esquerda. A mata escura embutida fica no
        # chão PLANO — o relvado da junta de dois degraus, à frente de casas
        # de trás, onde nenhum prop cabe —, e o morro é da que balança.
        if mx < fundo - ORLA_DA_MATA and altura_do_morro(mx, my) > 0.0:
            continue
        if mx < fundo - ORLA_DA_MATA:
            raio = 0.70
        else:
            moita = r.random() < 0.6
            raio = 0.42 if moita else 0.52
        # ⚠️ A MATA FECHA-SE; O QUINTAL NÃO. A 0,62 das duas copas somadas a
        # parte escura saiu em fileiras de árvores soltas, com o tronco à
        # mostra — pomar e não mata. As copas escuras entram umas nas outras.
        aperto = 0.38 if raio > 0.6 else 0.62
        if any(math.hypot(mx - a, my - b) < aperto * (raio + c) for a, b, c in postas):
            continue
        postas.append((mx, my, raio))
    medidas = _medidas_da_mata()
    for mx, my, raio in sorted(postas, key=lambda o: o[0] + o[1]):
        h = ALT_CAIS + altura_do_morro(mx, my)
        if raio < 0.5:
            # A moita da orla é a ESCURA, quase sempre: a orla é a borda da
            # mata vista da vila, e a clara destoava nela (`130`).
            variante = "arvore_moita_a" if r.random() < 0.2 else "arvore_moita_b"
            escala = r.uniform(0.75, 1.1)
        elif raio > 0.6:
            # A MATA ESCURA da orla em seis formas, e não em duas: «parece que
            # a maioria das árvores é a mesma» (`130`).
            variante = ORLA_FORMAS[r.randrange(len(ORLA_FORMAS))]
            escala = r.uniform(0.75, 0.95)
        else:
            variante = "arvore_copa_p" if r.random() < 0.5 else "arvore_copa_p2"
            escala = r.uniform(0.6, 0.9)
        # ⚠️ SÓ SE EMBUTE O QUE UM PROP NÃO PODE SER (`127`, a copa escura; e
        # na `130` toda a orla): embutida, a árvore fica parada. Onde a
        # planta, como prop, ficaria inteira acima da vila e das vias, o sítio
        # fica para a mata que balança.
        x, y = tela(mx, my, h)
        topo = _a_frente(mx, my)
        if _cabe_acima(medidas[variante], x, y, escala, topo):
            continue
        # ⚠️ E NO RELVADO PLANO A MATA ESCURA SÓ FICA ONDE NEM UMA MOITA QUE
        # BALANÇA CABERIA (`130`, «mata parada no meio»): onde uma moita, prop,
        # cabe sem pintar por cima da vila, o sítio fica vazio, e a mata do
        # morro planta lá a moita ou a árvore pequena (`MATA_DO_RELVADO`).
        # Medido: com metade dos sítios vagos ao acaso, e depois com a faixa
        # da frente vaga, nenhuma coube no meio do relvado — atrás de uma copa
        # parada nenhum prop pode estar, e havia sempre outra à frente.
        if raio > 0.6 and _cabe_acima(medidas["arvore_moita_a"], x, y, 1.0, topo):
            continue
        # E O QUE TEM DE SE EMBUTIR AQUI É BAIXO: uma copa alta parada logo
        # atrás de uma casa sobe 40 a 55 px e fecha a qualquer prop o relvado
        # de trás. Uma sebe de moitas e copas pequenas deixa a mata que
        # balança crescer por trás dela.
        if raio > 0.6 and altura_do_morro(mx, my) == 0.0:
            variante = ORLA_SEBE[math.floor(_ruido(mx * 3.1, my * 3.1, 22) * len(ORLA_SEBE))]
            escala = 0.80 + 0.25 * _ruido(my * 2.7, mx * 2.7, 23)
        s += arvore_embutida(variante, mx, my, round(escala, 3), h)
    return s


def arvores_embutidas() -> list:
    """(variante, x, y, escala, prof, chao) de TELA de cada árvore embutida no
    mapa do porto: a mata baixa do quintal de trás (`quintal`) e as da vila
    (`vila`), pela ordem em que se desenham. A tabela publica-as para o
    catálogo da folha dos props e para o D47, que confere que nenhuma árvore
    do morro pinta por cima de uma do quintal que lhe fica à frente — a
    profundidade é o `mx + my` do pé."""
    return [e + ("quintal",) for e in orla_embutida()] + [e + ("vila",) for e in _da_vila()]


_ORLA = None


def orla_embutida() -> list:
    """(variante, x, y, escala, prof) de cada árvore EMBUTIDA da mata baixa do
    quintal de trás. Uma árvore do morro, prop, não pode descer por cima de
    nenhuma que lhe fique à frente — e pode, por cima das de trás."""
    global _ORLA
    if _ORLA is None:
        pecas_da_vila()
        _EMBUTIDAS.clear()
        mata_baixa()
        _ORLA = list(_EMBUTIDAS)
    return _ORLA


def _da_vila() -> list:
    _EMBUTIDAS.clear()
    vila(1, False)
    return list(_EMBUTIDAS)


def _colunas_da_embutida(perfil: dict, x: float, y: float, k: float) -> dict:
    """{coluna de TELA: (cima, baixo)} do desenho de uma árvore embutida.

    ⚠️ COM UMA COLUNA DE FOLGA PARA CADA LADO (`130`): o perfil põe cada pixel
    do PNG na coluna onde ele COMEÇA, e o pixel da borda de uma copa embutida
    a 0,639 entrava 0,17 px na coluna seguinte — o D47 §3c viu uma arvoreta
    1,5 px por cima da copa ali, que o gerador julgava só sombra até y 67,5.
    """
    cols = {}
    for i, (cima, baixo) in enumerate(zip(perfil["cima"], perfil["baixo"])):
        if cima is None:
            continue
        c0 = math.floor(x + k * (perfil["dx0"] + i))
        for c in range(c0 - 1, math.floor(x + k * (perfil["dx0"] + i + 1)) + 2):
            a, b = y + k * cima, y + k * baixo
            velho = cols.get(c)
            cols[c] = (a, b) if velho is None else (min(velho[0], a), max(velho[1], b))
    return cols


def _cabe_acima(perfil: dict, x: float, y: float, k: float, topo: list) -> bool:
    """O PNG da árvore, com o pé em (x, y) de TELA e na escala `k`, acaba
    acima do contorno `topo` em todas as colunas?"""
    for i, baixo in enumerate(perfil["baixo"]):
        if baixo is None:
            continue
        c = math.floor(x + k * (perfil["dx0"] + i))
        for cc in (c, c + 1, c + 2):
            if 0 <= cc < SAIDA and y + k * baixo > topo[cc] - MATA_FOLGA_VILA:
                return False
    return True


def relvado_da_vila() -> str:
    """O relvado da vila com vida (`130`): trilhas, flores rasteiras e hortas.

    «O chão verde entre os lotes é liso», marcou o Bruno. É CHÃO, e sai antes
    da mata baixa, da rua e da vila — o que lhe cair debaixo de uma casa ou
    de uma viela fica tapado, que é onde uma casa ou uma viela o tapariam.
    Três coisas que dizem que ali vive gente:

    - as TRILHAS de terra batida nos vãos da fileira de trás, da viela até ao
      pé do morro e um pouco por ele acima: o caminho que o pé abre para a
      mata. Sobem a encosta, e é a curva delas a subir que mostra o morro;
    - as FLORES rasteiras em touceiras, no relvado que sobra entre os lotes;
    - as HORTAS — canteiros de terra escura com fileiras de verde — encostadas
      ao lado de um terreno, que é onde a vila as faz.

    Um `Random` só deste chão (`mapa.md`): sorteio novo vem de um novo.
    """
    r = random.Random(SEMENTE_CHAO + 650)
    lotes = lotes_da_vila()
    terrenos = terrenos_da_vila(lotes)
    caixas = [(t[0] - 0.08, t[1] + 0.08, t[2] - 0.08, t[3] + 0.08) for t in terrenos]

    def livre(mx: float, my: float) -> bool:
        return (_no_chao_de_tras(mx, my) and altura_do_morro(mx, my) == 0.0
                and no_quadro(mx, my)
                and not any(a <= mx <= b and c <= my <= d for a, b, c, d in caixas))

    s = ""
    # AS TRILHAS, nos vãos de pelo menos meia unidade entre dois terrenos da
    # fileira de trás do mesmo degrau.
    trilhas = []
    fundo = sorted((t for t, l in zip(terrenos, lotes) if l[5]), key=lambda t: t[2])
    for ta, tb in zip(fundo, fundo[1:]):
        if tb[2] - ta[3] < 0.5 or abs(ta[0] - tb[0]) > 0.5:
            continue
        my = (ta[3] + tb[2]) / 2.0 + r.uniform(-0.12, 0.12)
        if not no_quadro(ta[1], my):
            continue
        ini, fim = pe_do_morro(my) - 1.1, max(ta[1], tb[1]) + 0.15
        fase = r.uniform(0.0, math.tau)
        pts = []
        for k in range(10):
            t = k / 9.0
            mx = ini + (fim - ini) * t
            yy = my + 0.13 * math.sin(fase + t * 4.2) * (1.0 - 0.6 * t)
            pts.append(p(mx, yy, ALT_CAIS + altura_do_morro(mx, yy)))
        d = "M" + " L".join("%.1f %.1f" % q for q in pts)
        s += ('  <path d="%s" stroke="%s" stroke-width="6" fill="none" '
              'stroke-linecap="round" stroke-linejoin="round" opacity="0.9"/>\n'
              % (d, C["trilha"]))
        s += ('  <path d="%s" stroke="%s" stroke-width="2.2" fill="none" '
              'stroke-linecap="round" stroke-linejoin="round" opacity="0.75"/>\n'
              % (d, C["trilha_clara"]))
        trilhas.append(my)

    # AS HORTAS, ao lado de um terreno da fileira da frente ou de trás, no
    # relvado livre: o canteiro inteiro tem de caber fora dos lotes.
    hortas = 0
    for t in terrenos:
        if hortas >= 6 or r.random() < 0.55:
            continue
        lado = r.choice((-1.0, 1.0))
        my0 = t[3] + 0.14 if lado > 0 else t[2] - 0.14 - 0.34
        mx0 = t[0] + (t[1] - t[0]) * r.uniform(0.15, 0.45)
        canto = [(mx0, my0), (mx0 + 0.55, my0), (mx0 + 0.55, my0 + 0.34), (mx0, my0 + 0.34)]
        if not all(livre(a, b) for a, b in canto + [(mx0 + 0.27, my0 + 0.17)]):
            continue
        if any(abs(my0 + 0.17 - m) < 0.4 for m in trilhas):
            continue
        hortas += 1
        s += poli([p(a, b, ALT_CAIS) for a, b in canto], C["horta_terra"])
        # ⚠️ AS FILEIRAS DEIXAM A TERRA À VISTA: com pés de 2,4 px a 0,10 u
        # a horta lia um tapete verde. É a terra escura entre as linhas que
        # diz canteiro.
        for k in range(3):
            yy = my0 + 0.07 + k * 0.10
            for j in range(6):
                gx, gy = p(mx0 + 0.06 + j * 0.087, yy, ALT_CAIS)
                s += ('  <ellipse cx="%.1f" cy="%.1f" rx="1.5" ry="1.1" fill="%s"/>\n'
                      % (gx, gy - 0.8, C["horta_folha"]))

    # AS FLORES, em touceiras no relvado que sobra.
    cores = ("flor_ipe", "flor_branca", "flor_lilas", "flor_primavera", "flor_ipe")
    flores = 0
    for _ in range(900):
        if flores >= 60:
            break
        my = r.uniform(-8.0, 32.0)
        mx = r.uniform(_borda_em(my) - RUA_RECUO - 9.0, _borda_em(my) - RUA_RECUO - CALCADA)
        cor = C[cores[r.randrange(len(cores))]]
        if not livre(mx, my):
            continue
        flores += 1
        cx, cy = p(mx, my, ALT_CAIS)
        s += ('  <ellipse cx="%.1f" cy="%.1f" rx="%.1f" ry="%.1f" fill="%s" '
              'opacity="0.7"/>\n' % (cx, cy, r.uniform(4.0, 6.0), 2.2, C["solo_escuro"]))
        for _k in range(r.randint(4, 7)):
            s += ('  <circle cx="%.1f" cy="%.1f" r="%.1f" fill="%s"/>\n'
                  % (cx + r.uniform(-4.5, 4.5), cy - r.uniform(0.0, 2.5),
                     r.uniform(1.1, 1.6), cor))
    return s


def mata_baixa() -> str:
    """O quintal de trás de todos os degraus, de trás para a frente."""
    return "".join(quintal_de_tras(i, my0, my1, borda)
                   for i, (my0, my1, borda) in enumerate(DEGRAUS))


def poli(pontos, cor: str, opacidade: float = 1.0) -> str:
    extra = "" if opacidade >= 1.0 else ' opacity="%.2f"' % opacidade
    return '  <polygon points="%s" fill="%s"%s/>\n' % (
        " ".join("%.1f,%.1f" % pt for pt in pontos), cor, extra)


def _misturar_cor(a: str, b: str, t: float) -> str:
    """Interpola RGB com entrada arredondada e acumulação estável."""
    t = round(max(0.0, min(1.0, t)), 8)
    ca, cb = a.lstrip("#"), b.lstrip("#")
    canais = []
    for i in (0, 2, 4):
        va, vb = int(ca[i:i + 2], 16), int(cb[i:i + 2], 16)
        canais.append(round(math.fsum((va * (1.0 - t), vb * t))))
    return "#%02x%02x%02x" % tuple(canais)


def _passos_de_um_pixel(distancia: float) -> int:
    """Quantas amostras deixam cada transição com no máximo 1 px."""
    return max(1, int(math.ceil(distancia * 2.0 * MEIA_LARG * ZOOM)))


def _png_rgba(largura: int, altura: int, pixels: bytes) -> bytes:
    """PNG byte-estável entre zlib e zlib-ng, sem depender do compressor.

    Mesmo ``Z_FIXED`` só fixa a árvore de Huffman: zlib e zlib-ng ainda podem
    escolher casamentos LZ diferentes. O runner Linux e o Python do Windows
    acabavam, por isso, com pixels iguais dentro de PNGs de bytes diferentes.
    Aqui o DEFLATE fixo e a procura LZ são nossos; zlib fica só com CRC/Adler.
    """
    def bloco(tipo: bytes, dados: bytes) -> bytes:
        return (struct.pack(">I", len(dados)) + tipo + dados
                + struct.pack(">I", zlib.crc32(tipo + dados) & 0xffffffff))

    passo = largura * 4
    linhas = []
    for y in range(0, len(pixels), passo):
        linha = pixels[y:y + passo]
        # Filtro Sub do PNG: depois do primeiro pixel, áreas chapadas viram
        # sequências de zero e a procura LZ simples continua compacta.
        filtrada = bytearray(linha[:4])
        filtrada.extend((linha[i] - linha[i - 4]) & 0xff
                        for i in range(4, len(linha)))
        linhas.append(b"\x01" + bytes(filtrada))
    bruto = b"".join(linhas)
    idat = _zlib_fixo(bruto)
    return (b"\x89PNG\r\n\x1a\n"
            + bloco(b"IHDR", struct.pack(">IIBBBBB", largura, altura,
                                           8, 6, 0, 0, 0))
            + bloco(b"IDAT", idat) + bloco(b"IEND", b""))


def _zlib_fixo(dados: bytes) -> bytes:
    """Codifica um único bloco DEFLATE de Huffman fixo, deterministicamente."""
    saida = bytearray()
    acumulador = 0
    n_bits = 0

    def escrever(valor: int, quantidade: int) -> None:
        nonlocal acumulador, n_bits
        acumulador |= valor << n_bits
        n_bits += quantidade
        while n_bits >= 8:
            saida.append(acumulador & 0xff)
            acumulador >>= 8
            n_bits -= 8

    def inverter(valor: int, quantidade: int) -> int:
        resultado = 0
        for _ in range(quantidade):
            resultado = (resultado << 1) | (valor & 1)
            valor >>= 1
        return resultado

    def simbolo_fixo(simbolo: int) -> None:
        if simbolo <= 143:
            codigo, quantidade = 0x30 + simbolo, 8
        elif simbolo <= 255:
            codigo, quantidade = 0x190 + simbolo - 144, 9
        elif simbolo <= 279:
            codigo, quantidade = simbolo - 256, 7
        else:
            codigo, quantidade = 0xc0 + simbolo - 280, 8
        escrever(inverter(codigo, quantidade), quantidade)

    bases_comprimento = (3, 4, 5, 6, 7, 8, 9, 10, 11, 13, 15, 17,
                         19, 23, 27, 31, 35, 43, 51, 59, 67, 83, 99,
                         115, 131, 163, 195, 227, 258)
    extras_comprimento = (0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 2, 2,
                          2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 0)
    tabela_comprimento = [None] * 259
    for indice, base in enumerate(bases_comprimento):
        quantidade = extras_comprimento[indice]
        fim = base if indice == 28 else base + (1 << quantidade) - 1
        for comprimento in range(base, fim + 1):
            tabela_comprimento[comprimento] = (
                257 + indice, comprimento - base, quantidade)

    bases_distancia = (1, 2, 3, 4, 5, 7, 9, 13, 17, 25, 33, 49, 65,
                       97, 129, 193, 257, 385, 513, 769, 1025, 1537,
                       2049, 3073, 4097, 6145, 8193, 12289, 16385, 24577)
    extras_distancia = (0, 0, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6,
                        6, 7, 7, 8, 8, 9, 9, 10, 10, 11, 11, 12, 12,
                        13, 13)

    # BFINAL=1, BTYPE=01 (Huffman fixo), na ordem de bits do DEFLATE.
    escrever(0b011, 3)
    ultima = [-1] * 65536
    posicao = 0
    limite = len(dados)
    while posicao < limite:
        comprimento = 0
        distancia = 0
        if posicao + 2 < limite:
            chave = ((dados[posicao] * 251 + dados[posicao + 1]) * 251
                     + dados[posicao + 2]) & 0xffff
            anterior = ultima[chave]
            if (anterior >= 0 and posicao - anterior <= 32768
                    and dados[anterior:anterior + 3]
                    == dados[posicao:posicao + 3]):
                maximo = min(258, limite - posicao)
                comprimento = 3
                while (comprimento < maximo
                       and dados[anterior + comprimento]
                       == dados[posicao + comprimento]):
                    comprimento += 1
                distancia = posicao - anterior

        if comprimento >= 3:
            simbolo, extra, quantidade = tabela_comprimento[comprimento]
            simbolo_fixo(simbolo)
            escrever(extra, quantidade)
            for indice, base in enumerate(bases_distancia):
                bits = extras_distancia[indice]
                if distancia <= base + (1 << bits) - 1:
                    escrever(inverter(indice, 5), 5)
                    escrever(distancia - base, bits)
                    break
            avancar = comprimento
        else:
            simbolo_fixo(dados[posicao])
            avancar = 1

        fim = min(posicao + avancar, limite - 2)
        for i in range(posicao, fim):
            chave = ((dados[i] * 251 + dados[i + 1]) * 251
                     + dados[i + 2]) & 0xffff
            ultima[chave] = i
        posicao += avancar

    simbolo_fixo(256)
    if n_bits:
        saida.append(acumulador & 0xff)
    return b"\x78\x01" + bytes(saida) + struct.pack(">I", zlib.adler32(dados))


def _rgb(hexa: str) -> tuple:
    h = hexa.lstrip("#")
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))


def _entre_rgb(a: tuple, b: tuple, t: float) -> tuple:
    t = round(max(0.0, min(1.0, t)), 8)
    return tuple(round(math.fsum((a[i] * (1.0 - t), b[i] * t)))
                 for i in range(3))


def _distancia_ao_contorno(px: float, py: float, segmentos: list) -> tuple:
    """(distância em px, my interpolado) até o segmento de costa mais perto."""
    melhor_d2, melhor_my = float("inf"), 0.0
    for x0, y0, x1, y1, my0, my1 in segmentos:
        vx, vy = x1 - x0, y1 - y0
        den = math.fsum((vx * vx, vy * vy))
        t = 0.0 if den == 0.0 else max(0.0, min(1.0,
            math.fsum(((px - x0) * vx, (py - y0) * vy)) / den))
        qx = math.fsum((x0, vx * t))
        qy = math.fsum((y0, vy * t))
        dx, dy = px - qx, py - qy
        d2 = math.fsum((dx * dx, dy * dy))
        if d2 < melhor_d2:
            melhor_d2 = d2
            melhor_my = round(math.fsum((my0 * (1.0 - t), my1 * t)), 8)
    return math.sqrt(melhor_d2), melhor_my


# Até onde chega a água costeira, em unidades: além disto é o largo. Vive
# num lugar só porque a mancha RASA também pergunta por ele (`124`).
ALCANCE_COSTEIRO = 6.0

# Quantos pixels de lado tem o bloco do índice espacial, e o raio dele.
BLOCO_AGUA = 8
_RAIO_BLOCO = math.hypot(BLOCO_AGUA, BLOCO_AGUA) / 2.0


def _caixa_dos_segmentos(segmentos: list) -> list:
    return [(min(s[0], s[2]), min(s[1], s[3]), max(s[0], s[2]), max(s[1], s[3]))
            for s in segmentos]


def _longe_da_caixa(cx0, cy0, cx1, cy1, caixa) -> float:
    """Piso da distância entre um retângulo e a caixa de um segmento."""
    dx = max(0.0, caixa[0] - cx1, cx0 - caixa[2])
    dy = max(0.0, caixa[1] - cy1, cy0 - caixa[3])
    return math.hypot(dx, dy)


# ── A SOMBRA DO MURO, que esvai na água (`124`) ──────────────────────────
# Era uma faixa CHAPADA de `sombra_agua` a 0,30, de 1,15 unidade, pelo
# `costa_deslocada`: aresta reta do lado do mar, e nas quinas dos degraus — ao
# lado das docas 2 e 3 — um paralelogramo com a ponta em esquadria, que o
# Bruno leu como «uma sombra bem QUADRADA nos píeres». E pintava 1.105 px por
# cima do TERREIRO do degrau seguinte: a faixa do espelho do degrau fica atrás
# do muro na tela, e ela era desenhada depois do cais.
#
# Hoje é raster, no MESMO laço do campo de cor da água (a distância já está
# medida lá): escura colada ao muro e a apagar-se em `SOMBRA_MURO_ALCANCE`, e
# só onde a água está À VISTA. A queda é um smoothstep invertido — patamar
# junto ao muro, onde a faixa velha dava 0,30, e saída sem degrau nenhum. A
# primeira versão caía em quadrado, e a 0,4 u já só dava 0,18: a espuma ao pé
# do muro clareou 30 pontos, e o cais deixou de assentar. É polinómio e não
# `**` fracionário porque o CI compara o PNG byte a byte, e a `pow` de cada
# libm pode discordar no último bit.
SOMBRA_MURO_OPAC = 0.40
SOMBRA_MURO_ALCANCE = 1.5     # unidades: onde a sombra chega a zero
SOMBRA_MURO_REMATE = 1.6      # o trecho em que ela nasce e morre nas pontas do cais:
# a 0,6 a sombra forte do muro acabava numa quina, e a água da ponta lia como
# um raio de luz entre ela e o raso da praia
# ⚠️ E ELA COMEÇA UM TEXEL ATRÁS DA FACE DO MURO. O campo é raster a 720 sob
# um desenho a 1080, e o primeiro texel ao pé do muro tem o centro do lado da
# terra: sem esta folga ele ficava sem sombra e deixava ver a espuma por baixo
# do antisserrilhado do muro — um fio claro de 1,5 px colado ao cais, que a
# faixa chapada tapava por ser desenhada por cima. A folga escurece só o
# rodapé da face, que é onde a água molha o concreto.
SOMBRA_MURO_PE = 0.06


def _agua_a_vista(px: float, py: float) -> bool:
    """O pixel de TELA (px, py) é água que nenhum degrau do cais tapa?

    Desprojetado a h = 0 ele tem de cair na água; e subindo até `ALT_CAIS` o
    ponto do mundo anda (+1, +1) por `ALT_CAIS / (2 · MEIA_ALT)` — se nesse
    caminho atravessar o espelho de um degrau e cair dentro do concreto, é o
    cais que se vê ali, e não a água. Foi assim que a faixa velha pintou o
    terreiro.
    """
    a = round((px / ZOOM - CX) / MEIA_LARG, 8)       # mx - my
    b = round((py / ZOOM - CY) / MEIA_ALT, 8)        # mx + my
    mx, my = (a + b) / 2.0, (b - a) / 2.0
    if mx <= _borda_em(my) - SOMBRA_MURO_PE:
        return False
    subida = ALT_CAIS / (2.0 * MEIA_ALT)
    for _my0, my1, _b in DEGRAUS[:-1]:
        if my < my1 <= my + subida and mx + (my1 - my) <= _borda_em(my1):
            return False
    return True


def _alfa_da_sombra(px: float, py: float, distancia: float, my: float) -> int:
    """O alfa (0–255) da sombra do muro num pixel, a `distancia` unidades da
    costa cujo ponto mais perto está em `my`."""
    if distancia >= SOMBRA_MURO_ALCANCE:
        return 0
    ponta = min(my - PONTA_NORTE, PONTA_SUL - my)
    if ponta <= 0.0 or not _agua_a_vista(px, py):
        return 0
    t = round(distancia / SOMBRA_MURO_ALCANCE, 8)
    resto = 1.0 - t * t * (3.0 - 2.0 * t)
    remate = min(1.0, round(ponta / SOMBRA_MURO_REMATE, 8))
    return round(SOMBRA_MURO_OPAC * resto * remate * 255.0)


def _imagem_embutida(pixels: bytes) -> str:
    dados = base64.b64encode(_png_rgba(SAIDA, SAIDA, pixels)).decode("ascii")
    return ('  <image x="0" y="0" width="%d" height="%d" '
            'preserveAspectRatio="none" href="data:image/png;base64,%s"/>\n'
            % (LARG, ALT, dados))


def campos_costeiros() -> tuple:
    """Os dois campos da distância à costa: a cor da água e a sombra do muro.

    Devolve as duas `<image>` que o `gerar()` põe em sítios diferentes — a
    água no fundo de tudo, a sombra depois do cais e antes do enrocamento,
    onde vivia a faixa chapada que ela substitui. Saem do mesmo laço porque a
    distância de cada pixel é a conta cara, e a sombra é uma rampa dela.

    Campo de distância à costa, rasterizado dentro do SVG.

    ⚠️ A COSTA GANHOU CURVA NAS DUAS PONTAS (item 8), e este campo tem de ler
    a MESMA linha que a areia desenha — senão a faixa de baixio fica a
    acompanhar a escada enquanto a areia serpenteia, e abre-se uma costura de
    meia unidade entre as duas. É por isso que aqui entra a `linha_costeira` e
    não o contorno base. No cais ela devolve exatamente os mesmos vértices de
    sempre, então o porto continua igual ao que era.
    #
    O que arredonda nos cotovelos do CAIS continua a ser só a propagação da
    COR, como luz em volta de uma quina: ali a linha é reta, e é assim que tem
    de ser.

    ⚠️ E O ÍNDICE ESPACIAL NÃO É AFINAÇÃO, É O QUE TORNA ISTO POSSÍVEL. Com a
    escada eram 10 segmentos e a força bruta custava segundos; com as pontas
    desenhadas são ~500, e 518 mil pixels contra 500 segmentos seriam minutos
    em cada um dos quatro mapas que o CI regera. O índice divide a tela em
    blocos de 8 px, mede o CENTRO de cada um contra todos os segmentos e
    guarda só os que ainda podem ganhar em algum pixel do bloco — um segmento
    cuja caixa esteja mais longe do que `centro + meia diagonal` não ganha em
    lado nenhum dali. A conta continua a ser a mesma: a lista de candidatos
    mantém a ORDEM original, de modo que um empate é desempatado como antes, e
    o PNG sai byte a byte igual ao da força bruta (conferido com o contorno
    velho antes de a costa mudar).
    """
    alcance = ALCANCE_COSTEIRO
    costa = linha_costeira(0.0)
    tela_costa = [tela(mx, my) for mx, my in costa]
    segmentos = [(tela_costa[i][0], tela_costa[i][1],
                  tela_costa[i + 1][0], tela_costa[i + 1][1],
                  costa[i][1], costa[i + 1][1])
                 for i in range(len(costa) - 1)]
    caixas = _caixa_dos_segmentos(segmentos)
    baixio, rasa, media, espuma_ = (_rgb(C[n]) for n in
                                    ("agua_baixio", "agua_rasa",
                                     "agua_media", "espuma"))
    pixels = bytearray()
    sombra = bytearray()
    tom_da_sombra = _rgb(C["sombra_agua"])
    px_por_unidade = 2.0 * MEIA_LARG * ZOOM
    amplitude = PRAIA_PROF * CRISTA[0][1] / alcance
    # Além deste raio o pixel é transparente faça o meandro o que fizer: a
    # largura da rampa nunca passa de `1 + amplitude`.
    corte = alcance * px_por_unidade * (1.0 + amplitude) + 1.0
    vizinhos = {}
    for by in range(0, SAIDA, BLOCO_AGUA):
        for bx in range(0, SAIDA, BLOCO_AGUA):
            cx, cy = bx + BLOCO_AGUA / 2.0, by + BLOCO_AGUA / 2.0
            centro, _my = _distancia_ao_contorno(cx, cy, segmentos)
            if centro - _RAIO_BLOCO >= corte:
                vizinhos[(bx, by)] = None          # bloco inteiro transparente
                continue
            limite = centro + _RAIO_BLOCO
            vizinhos[(bx, by)] = [
                (s, c) for s, c in zip(segmentos, caixas)
                if _longe_da_caixa(bx, by, bx + BLOCO_AGUA, by + BLOCO_AGUA,
                                   c) <= limite]
    for y in range(SAIDA):
        by = y - y % BLOCO_AGUA
        for x in range(SAIDA):
            perto = vizinhos[(x - x % BLOCO_AGUA, by)]
            if perto is None:
                pixels.extend((0, 0, 0, 0))
                sombra.extend((*tom_da_sombra, 0))
                continue
            distancia_px, my = _distancia_ao_contorno(x + 0.5, y + 0.5,
                                                       [s for s, _c in perto])
            sombra.extend((*tom_da_sombra, _alfa_da_sombra(
                x + 0.5, y + 0.5, round(distancia_px / px_por_unidade, 8), my)))
            largura = 1.0 + amplitude * _meandro(my, CRISTA[0][2])
            d = round(distancia_px / px_por_unidade / largura, 8)
            if d >= alcance:
                pixels.extend((0, 0, 0, 0))
                continue
            if d <= 1.0:
                cor = _entre_rgb(baixio, rasa, d)
                alfa = 1.0
            elif d <= 2.6:
                cor = _entre_rgb(rasa, media, (d - 1.0) / 1.6)
                alfa = 1.0
            else:
                cor = media
                alfa = 1.0 - (d - 2.6) / (alcance - 2.6)

            # A espuma é a ponta da mesma rampa, não duas fitas por cima.
            if d < 0.42:
                if d <= 0.16:
                    f = 0.55 - (0.55 - 0.34) * d / 0.16
                else:
                    f = 0.34 * (1.0 - (d - 0.16) / (0.42 - 0.16))
                cor = _entre_rgb(cor, espuma_, f)
            pixels.extend((*cor, round(alfa * 255.0)))

    return _imagem_embutida(bytes(pixels)), _imagem_embutida(bytes(sombra))


def espuma_costeira_gradiente() -> str:
    """A base da espuma já é composta no campo raster acima."""
    return ""


def laje(x0, y0, x1, y1, h, topo, dir_, esq) -> str:
    """Laje isométrica: as duas faces visíveis (+mx e +my) e o topo."""
    s = poli([p(x1, y0, h), p(x1, y1, h), p(x1, y1, 0), p(x1, y0, 0)], dir_)
    s += poli([p(x0, y1, h), p(x1, y1, h), p(x1, y1, 0), p(x0, y1, 0)], esq)
    s += poli([p(x0, y0, h), p(x1, y0, h), p(x1, y1, h), p(x0, y1, h)], topo)
    return s


def caixa(x0, y0, x1, y1, base, altura, topo, dir_, esq) -> str:
    t = base + altura
    s = poli([p(x1, y0, t), p(x1, y1, t), p(x1, y1, base), p(x1, y0, base)], dir_)
    s += poli([p(x0, y1, t), p(x1, y1, t), p(x1, y1, base), p(x0, y1, base)], esq)
    s += poli([p(x0, y0, t), p(x1, y0, t), p(x1, y1, t), p(x0, y1, t)], topo)
    return s


# As duas faces visíveis de um volume isométrico. Servem para pintar aberturas
# em cima de uma parede já desenhada, sem redesenhar o volume.
def face_mx(mx, my0, my1, z0, z1, cor) -> str:
    return poli([p(mx, my0, z1), p(mx, my1, z1), p(mx, my1, z0), p(mx, my0, z0)], cor)


def face_my(my, mx0, mx1, z0, z1, cor) -> str:
    return poli([p(mx0, my, z1), p(mx1, my, z1), p(mx1, my, z0), p(mx0, my, z0)], cor)


# O tamanho de um lote reservado, num lugar só: o desenho, a tabela de âncoras
# e o teste leem daqui. Ver a varredura no `gerar()`.
LOTE_COMP = 1.6
LOTE_LARG = 1.4
LOTES_RESERVADOS = [(4.7, 8.2), (3.8, 20.1)]   # (recuo do cais, my inicial)


def lote_reservado(mx0, my0, mx1, my1, base) -> str:
    """Terreno demarcado à espera de construção: chão, contorno e estacas.

    ⚠️ O CONTORNO É TRACEJADO, e é o que faz a marca ler como PROVISÓRIA. Um
    retângulo de contorno cheio no asfalto lê como pintura de estacionamento;
    tracejado lê como demarcação. É o mesmo sinal que a vaga de doca por
    construir já dava com as estacas sob contorno tracejado.

    ⚠️ E AS QUATRO ESTACAS SÃO O QUE O SEPARA DE UMA MANCHA. A esta escala um
    quadrilátero de tom ligeiramente diferente no asfalto some — a regra do
    `pilha_caixotes`, faces vizinhas do mesmo tom fundem-se. As estacas têm
    altura, e altura é a única coisa que uma marca no chão não tem.
    """
    chao = [p(mx0, my0, base), p(mx1, my0, base),
            p(mx1, my1, base), p(mx0, my1, base)]
    s = poli(chao, C["asfalto_escuro"])
    s += ('  <polygon points="%s" fill="none" stroke="%s" stroke-width="1.6" '
          'stroke-dasharray="7 5"/>\n'
          % (" ".join("%.1f,%.1f" % pt for pt in chao), C["faixa_via"]))
    for cx, cy in ((mx0, my0), (mx1, my0), (mx1, my1), (mx0, my1)):
        s += caixa(cx - 0.07, cy - 0.07, cx + 0.07, cy + 0.07, base, 7,
                   C["madeira"], C["madeira_dir"], C["madeira_dir"])
    return s


def predio(mx0, my0, mx1, my1, base, altura, telhado, telhado_dir, telhado_esq,
           janelas: int = 2) -> str:
    """Prédio com porta, janelas e telhado que sobressai.

    Antes eram caixas lisas com a face de cima pintada de telhado: à distância
    liam-se como blocos de cor. O que dá escala a um edifício é a ABERTURA —
    uma porta diz de que tamanho é a construção sem precisar de mais nada.
    """
    t = base + altura
    s = caixa(mx0, my0, mx1, my1, base, altura,
              C["parede"], C["parede_dir"], C["parede_esq"])

    # Porta na face +my (a que fica virada para o cais).
    meio = (mx0 + mx1) / 2
    s += face_my(my1, meio - 0.55, meio + 0.55, base, base + min(16, altura - 8),
                 C["porta"])

    # Janelas nas duas faces visíveis, distribuídas ao longo do vão.
    alt_j0, alt_j1 = base + altura * 0.52, base + altura * 0.78
    vao_y = (my1 - my0) / (janelas + 1)
    for i in range(1, janelas + 1):
        cy = my0 + vao_y * i
        s += face_mx(mx1, cy - 0.42, cy + 0.42, alt_j0, alt_j1, C["vidro"])
    vao_x = (mx1 - mx0) / (janelas + 1)
    for i in range(1, janelas + 1):
        cx = mx0 + vao_x * i
        if abs(cx - meio) < 0.75:
            continue                       # não abre janela em cima da porta
        s += face_my(my1, cx - 0.42, cx + 0.42, alt_j0, alt_j1, C["vidro"])

    # Telhado sobressaindo dos quatro lados — é o beiral que faz parecer coberto.
    s += caixa(mx0 - 0.3, my0 - 0.3, mx1 + 0.3, my1 + 0.3, t, 8,
               telhado, telhado_dir, telhado_esq)
    return s


# ── VIAS E VILA ──────────────────────────────────────────────────────────
# Isto substitui as faixas claras que atravessavam o pátio. Elas não eram
# desenho: eram a margem de meia unidade que sobrava entre um degrau e o
# seguinte, e por isso iam dar na água sem levar a lugar nenhum. Uma rua de
# porto tem forma conhecida — corre paralela ao cais, tem acesso curto até
# cada berço e tem casa do outro lado — e é o que se desenha aqui.


def _chao(pontos, cor, opac=1.0) -> str:
    """Polígono deitado no plano do chão, em coordenadas de mundo."""
    return poli([p(mx, my, ALT_CAIS) for mx, my in pontos], cor, opac)


def _faixa_mx(mx0, mx1, my0, my1, cor, opac=1.0) -> str:
    """Retângulo deitado no plano do chão, em coordenadas de mundo."""
    return _chao([(mx0, my0), (mx1, my0), (mx1, my1), (mx0, my1)], cor, opac)


# Meia largura do meio-fio: 6cm de nada que fazem a rua ter margem em vez de
# acabar. Ele vive numa constante porque o cotovelo o desenha pelo CONTORNO, e
# um segundo `0.05` escrito lá dentro seria a mesma linha em dois sítios.
MEIOFIO = 0.05

# ── O COTOVELO É UM POLÍGONO, E AS DUAS PONTAS SALIENTES SÃO CHANFRADAS ──
#
# ⚠️ ELE ERA UM RETÂNGULO, E ERA ESSA A QUEIXA. A segunda jogada circulou a
# vermelho três sítios onde *"a estrada acaba no nada"*, um por cotovelo
# visível. Medido em 07/09 (`docs/decisoes/012`), a rede está LIGADA — não
# falta retângulo nenhum, e é por isso que não há asserção de geometria a
# escrever. O que falta é a ESQUINA: um retângulo que salta 4 unidades de uma
# vez deixa, de cada lado da curva, uma ponta de 90° a apontar para fora, e
# ponta de asfalto no meio do relvado lê-se como estrada que acabou. A viela de
# 07/09 tapou 34% da face virada para a vila; o resto é isto.
#
# CHANFRA-SE SÓ AS DUAS PONTAS SALIENTES, e são mesmo só duas: a que aponta
# para a vila (o lado de fora da curva) e a que aponta para o avental (o lado
# de dentro da seguinte). As outras duas quinas são REENTRANTES — é por ali que
# a rua continua —, e "arredondá-las" seria ACRESCENTAR asfalto fora do
# retângulo que a tabela de âncoras publica, que é exatamente o defeito que os
# lotes reservados pagaram em 07/09: desenho do mapa que nenhuma faixa declara.
#
# O CORTE SAI DA FAIXA DO CAMIÃO, e não de um número escrito aqui. Até 23/09
# era meia rua (0,9), escolhida por ler como raio de giro — e com a mão
# direita (`docs/decisoes/052`) cada rota passou a fazer à volta desta ponta
# uma curva ABERTA, cortada por uma diagonal paralela ao chanfro. O camião anda
# nela com a silhueta do eixo, um retângulo a 45°, e a quina de trás da
# carroçaria saía 0,207 para lá do asfalto, por cima do meio-fio e do passeio.
# A ordem inverteu-se (`docs/decisoes/053`): a diagonal é da RUA, e o chanfro
# é o que sobra dela depois de lá caber o maior camião.
#
# A diagonal passa a meia faixa do vértice do caminho — `CORTE_DA_CURVA`, a
# contar dele ao longo de cada trecho, que é o `corte_da_curva()` do
# `TrafegoDeCamioes.gd`, e o D13 §7i confere que são o mesmo. Somadas as
# distâncias às duas bordas de fora, ela fica a
# `RUA_LARG / 2 + CORTE_DA_CURVA`; a quina da carroçaria fica
# `(chassi + largura) / 2` para dentro dela; e o chanfro é essa soma,
# arredondada PARA BAIXO ao centésimo — número que alimenta toda coordenada
# da rua tem de ser exato (ver o `sum()` da Python 3.12 no `CLAUDE.md`), e
# arredondar para baixo é arredondar para o lado do asfalto.
#
# O MAIOR CAMIÃO é o porta-contêiner do `blender/brp_porto.py`: chassi 1,96 e
# largura 0,62, vezes o `ESCALA_CAMINHAO` (0,72). É uma cópia, como a do D35;
# se o camião crescer e ela não, é o D13 §7j que reprova.
#
# ⚠️ E ISTO MUDOU O MAPA, de 0,9 para 0,6: a ponta recua menos, e a esquina
# continua chanfrada — o que o 4b pediu (`docs/decisoes/013`) é que ela não
# acabe em ponta de 90°, e não um tamanho. A viela, que o chanfro de 0,9 comia
# 0,08, deixa de ser tocada: ela abre a 0,82 da quina.
# ⚠️ E O CORTE CRESCEU NA `136`, de `RUA_LARG * raiz(2) / 4` (0,636) para
# MEIA RUA: o Bruno pediu a curva de fora mais redonda, e o raio do arco sai
# deste corte — com 0,636 não passava de 0,86. Fazer o camião andar em ARCO
# não serve: o sprite não roda, e a meio da curva a ponta dele aponta para a
# quina e sai do asfalto em qualquer raio (medido: +0,24 a +0,26). Cortar mais
# CEDO pela mesma diagonal afasta-o da quina, e o arco sobe a 1,38.
CORTE_DA_CURVA = RUA_LARG / 2.0
CAMIAO_MAIOR = (1.96 * 0.72, 0.62 * 0.72)     # chassi, largura
# ⚠️ E DESDE A `136` NÃO HÁ CHANFRO: a quina é um arco, e o raio dele sai da
# mesma conta do camião — ver `RAIO_COTOVELO`, logo abaixo. O chanfro de 0,6
# que esta conta dava deixou de ser desenhado.

# ── A CURVA REDONDA (`136`) ──────────────────────────────────────────────
#
# O Bruno pediu, na conversa das estradas, *«curvas mais arredondadas»*: a
# quina saliente era um chanfro a 45°, e a reentrante, um canto vivo. A
# saliente passou a um ARCO tangente às duas bordas, e o raio dele sai do
# mesmo camião de que saía o chanfro — é o maior com que a carroçaria do
# porta-contêiner, a cortar a curva pela diagonal (`trechos_de()` do
# trânsito), não sai do asfalto. A conta: a quina da carroçaria anda na reta
# `dx + dy = s`, a `s = RUA_LARG / 2 + CORTE_DA_CURVA - (chassi + largura) / 2`
# das duas bordas (a mesma do chanfro), e o ponto que mais aperta o arco é o
# do meio da diagonal, a `(x, y)` das bordas; o arco tangente de raio `R` deixa
# esse ponto no asfalto enquanto `R <= s + raiz(s² - x² - y²)`. Dá 0,869, e
# arredonda-se PARA BAIXO, que é o lado do asfalto. O D13 §7j mede-o.
_S_CURVA = RUA_LARG / 2.0 + CORTE_DA_CURVA - (CAMIAO_MAIOR[0] + CAMIAO_MAIOR[1]) / 2.0
_X_CURVA = RUA_LARG / 4.0 + CORTE_DA_CURVA / 2.0 - CAMIAO_MAIOR[1] / 2.0
_Y_CURVA = RUA_LARG / 4.0 + CORTE_DA_CURVA / 2.0 - CAMIAO_MAIOR[0] / 2.0
RAIO_COTOVELO = math.floor(
    (_S_CURVA + math.sqrt(_S_CURVA ** 2 - _X_CURVA ** 2 - _Y_CURVA ** 2)) * 100.0) / 100.0
# A quina de DENTRO arredondava-se só dentro da calçada (raio 0,22, a
# calçada em canto vivo), e não se notava: «curva de dentro pouco visível»,
# na terceira passagem. A 0,45 a calçada também arredonda (raio 0,23) e
# avança até 0,095 sobre o canto do pátio e o da vila — fora do cerco que a
# tabela publica, que é retângulo; a obra da rua recorta-a com o cotovelo.
RAIO_DE_DENTRO = 0.45
# Os segmentos de cada quarto de arco: a 0,86 de raio são 2,4 px por lado.
PASSOS_DO_ARCO = 12


def _arco(cx, cy, raio, de, ate, passos=PASSOS_DO_ARCO) -> list:
    """Pontos do arco de centro (cx, cy), de `de` a `ate` graus, em mundo."""
    out = []
    for k in range(passos + 1):
        t = math.radians(de + (ate - de) * k / passos)
        # Arredondado ao milionésimo: o seno de uma libm pode diferir da de
        # outra no último bit, e o CI compara o mapa byte a byte (`mapa.md`).
        out.append((round(cx + raio * math.cos(t), 6), round(cy + raio * math.sin(t), 6)))
    return out


def cotovelo_pontos(borda, prox, my1, folga: float = 0.0) -> list:
    """O contorno do cotovelo, inflado de `folga` (calçada, meio-fio).

    A `folga` empurra o contorno para fora nos quatro lados, o que faz o mesmo
    polígono servir de asfalto, de meio-fio e de calçada — desenhá-los como
    três retângulos independentes é o que deixava a calçada com a esquina
    quadrada por baixo de um asfalto já arredondado.

    ⚠️ AS DUAS QUINAS SALIENTES SÃO ARCOS desde a `136` — eram um chanfro a
    45° —, e os arcos dos três contornos são CONCÊNTRICOS: o raio cresce com
    a folga e o centro fica. O chanfro precisava de recuar o corte de
    `folga * (2 - raiz(2))` para a calçada não sair o dobro da largura em
    cima do bisel (3,9 px nas retas contra 8,8 no bisel, lido como um muro);
    o arco concêntrico não tem esse problema, porque é a mesma curva afastada.
    Sobra a projeção — em isométrico a direção (1,1) comprime-se e a (1,-1)
    estica-se —, e isso não é defeito: corrigi-lo seria escrever pixel dentro
    de geometria de mundo, que é a fronteira que o `tela()` existe para não
    deixar atravessar.
    """
    x0 = borda - RUA_RECUO
    x1 = prox - RUA_RECUO + RUA_LARG
    ya = my1 - RUA_LARG
    yb = my1
    rho = RAIO_COTOVELO + folga
    # A saliente de `mx` alto e `my` baixo: o asfalto fica a −mx e a +my.
    alta = _arco(x1 - RAIO_COTOVELO, ya + RAIO_COTOVELO, rho, -90.0, 0.0)
    # A saliente de `mx` baixo e `my` alto: o asfalto fica a +mx e a −my.
    baixa = _arco(x0 + RAIO_COTOVELO, yb - RAIO_COTOVELO, rho, 90.0, 180.0)
    return ([(x0 - folga, ya - folga)] + alta + [(x1 + folga, yb + folga)] + baixa)


def quinas_de_dentro(borda, prox, my1, folga: float = 0.0, asfalto: bool = False) -> list:
    """O que se acrescenta nas duas quinas REENTRANTES de um cotovelo, para a
    curva de dentro sair redonda: o pedaço entre o canto vivo e o arco de raio
    `RAIO_DE_DENTRO - folga`, com o mesmo centro nos contornos todos.

    A primeira é a da reta de cima a virar para `+mx` (no lado da ÁGUA da
    reta), a segunda a do cotovelo a virar para a reta de baixo (no lado da
    VILA). Com `folga = CALCADA` o raio é zero e não há nada a acrescentar.
    """
    r = RAIO_DE_DENTRO
    rho = r - folga
    if rho <= 1e-6:
        return []
    f = borda - RUA_RECUO + RUA_LARG          # a face da água da reta de cima
    ya = my1 - RUA_LARG
    d = prox - RUA_RECUO                      # a face da vila da reta de baixo
    yb = my1
    um = [(f + folga, ya - folga)] + _arco(f + r, ya - r, rho, 180.0, 90.0)
    dois = [(d - folga, yb + folga)] + _arco(d - r, yb + r, rho, 0.0, -90.0)
    if asfalto:
        # O asfalto leva também a meia largura do meio-fio da RETA que fica
        # do lado de dentro da curva: o meio-fio reto vem até ao canto vivo,
        # e sem isto ficava uma lasca dele a direito por dentro do arco.
        um = [(f - MEIOFIO, ya), (f - MEIOFIO, ya - r)] + um[1:]
        dois = [(d + MEIOFIO, yb), (d + MEIOFIO, yb + r)] + dois[1:]
    return [um, dois]


def passadeira(borda, my_centro, gasta=None) -> str:
    """Faixa de pedestres a atravessar a rua, na altura de um prédio do pátio.

    ⚠️ AS BARRAS CORREM NO SENTIDO DO TRÁFEGO, que aqui é `my`. Desenhá-las
    atravessadas seria desenhar uma escada deitada na estrada: numa zebra o que
    se repete ao longo da via é o VÃO, e cada barra acompanha quem passa por
    cima dela. Como a rua deste mapa corre em `my`, as barras correm em `my` e
    repetem-se em `mx`.

    ⚠️ ELA SÓ EXISTIA COM O PAVIMENTO, e aparecia do nada no dia em que o
    pátio ficava pronto — com a linha central, 27 mil pixels fora do recorte
    da obra (`136`). A rua é da cidade e já lá estava: no porto em ruínas a
    zebra está GASTA (`gasta` traz o sorteio do desgaste), e a obra do pátio
    repinta-a com o trecho de rua dela.
    """
    dentro = borda - RUA_RECUO
    fora = dentro + RUA_LARG
    s = ""
    # A largura da barra e o passo saem da rua: quatro barras por faixa, com
    # vão igual à barra. Números cravados envelheceriam quando a rua mudasse de
    # largura — e ela mudou em 07/09, que é a razão desta função existir.
    passo = RUA_LARG / 8.0
    mx = dentro + passo * 0.5
    while mx + passo * 0.5 <= fora:
        y0 = my_centro - PASSADEIRA_COMP / 2.0
        y1 = my_centro + PASSADEIRA_COMP / 2.0
        opac = 0.85
        if gasta is not None:
            # A tinta gasta some primeiro onde a roda passa: cada barra perde
            # uma ponta, ou fica só a sombra dela.
            opac = gasta.uniform(0.26, 0.42)
            if gasta.random() < 0.45:
                corte = gasta.uniform(0.12, 0.35) * PASSADEIRA_COMP
                if gasta.random() < 0.5:
                    y0 += corte
                else:
                    y1 -= corte
        s += _faixa_mx(mx, mx + passo * 0.5, y0, y1, C["faixa_via"], opac)
        mx += passo
    return s


def vias(pavimentado: bool) -> str:
    """A rua do porto, com calçada, e o acesso de cada berço.

    A rua acompanha a escada da costa. No degrau ela salta 4 unidades em `mx`,
    e o cotovelo que liga um trecho ao seguinte é desenhado com a MESMA
    largura da rua — desenhá-lo como um retângulo de canto a canto foi a
    primeira tentativa, e virava uma laje de asfalto do tamanho de um quarteirão.
    Ele é um POLÍGONO desde 08/09, com as duas pontas salientes chanfradas: ver
    `cotovelo_pontos`.
    """
    s = ""
    dentro = lambda b: b - RUA_RECUO
    fora = lambda b: b - RUA_RECUO + RUA_LARG
    # A RUA DO PORTO EM RUÍNAS É GASTA, e a do pátio pronto é recapeada
    # (`136`): os dois mapas diferem DENTRO do contorno da rua, e a obra do
    # pátio recapeia-a trecho a trecho (`obra_da_rua()`). O que muda no chão
    # gasto — remendo, fissura, buraco, a tinta apagada — vive em
    # `vias_detalhes()`; aqui só o tom do asfalto.
    asfalto = C["asfalto_via"] if pavimentado else C["asfalto_gasto"]

    for i, (my0, my1, borda) in enumerate(DEGRAUS):
        vira = i + 1 < len(DEGRAUS)
        prox = DEGRAUS[i + 1][2] if vira else None
        # ⚠️ A FAIXA RETA ACABA ONDE O COTOVELO COMEÇA, e não no `my1`.
        #
        # Ela ia até lá, e com o cotovelo chanfrado isso passou a IMPORTAR: o
        # retângulo da faixa reta encheria de volta o triângulo que o chanfro
        # corta, e a esquina saía quadrada com o polígono a dizer que não era.
        # Quem faz a costura entre os dois é o próprio cotovelo, que cobre a
        # última largura de rua inteira — a `COSTURA` de sobreposição continua,
        # do lado de DENTRO dele, para não deixar fio de fundo na junta.
        fim = (my1 - RUA_LARG + COSTURA) if vira else (my1 + COSTURA)
        s += _faixa_mx(dentro(borda) - CALCADA, fora(borda) + CALCADA,
                       my0, fim, C["calcada"])
        # ⚠️ A CALÇADA E O MEIO-FIO DO COTOVELO VÊM ANTES DO ASFALTO DA FAIXA,
        # e até 08/09 a calçada vinha DEPOIS. Ela é 0,22 mais funda do que o
        # asfalto nos quatro lados, e o que sobrava era uma FITA DE PASSEIO
        # ATRAVESSADA NA PISTA, da largura da rua, na entrada de cada cotovelo.
        # Medida no render, em (139,260): #aeb8bf, que é a calçada, onde tinha
        # de estar o #49535b do asfalto.
        #
        # Nada perguntava, e não era descuido de ninguém: toda a maquinaria de
        # cerco deste projeto mede POSIÇÃO em coordenadas de mundo, e a COR com
        # que o mapa pinta um ponto não era pergunta de suíte nenhuma. Hoje é —
        # o bloco D20 do teste de design rasteriza o mapa e lê a pista.
        if vira:
            s += _chao(cotovelo_pontos(borda, prox, my1, CALCADA), C["calcada"])
            s += _chao(cotovelo_pontos(borda, prox, my1, MEIOFIO), C["meiofio"])
        # ⚠️ E A RETA COMEÇA DENTRO DO COTOVELO DE TRÁS, pela `COSTURA`. Até
        # 19/10 ela começava no `my0`, a borda exata onde o cotovelo acaba: as
        # duas bordas antisserrilhadas no mesmo sítio deixavam passar a
        # calçada de baixo, e cada um dos quatro cotovelos à vista tinha um
        # fio claro atravessado na pista (+25 a +30 de luminância, `136`) —
        # a «linha fina diagonal junto do coqueiro sul» da `130`. Do outro
        # lado a costura já existia: a reta acaba DENTRO do cotovelo (`fim`),
        # e o cotovelo desenha-se por cima dela.
        ini = my0 - COSTURA if i > 0 else my0
        s += _faixa_mx(dentro(borda), fora(borda), ini, fim, asfalto)
        # O meio-fio da faixa reta acaba com ela: daí para a frente quem tem
        # margem é o contorno do cotovelo, que já está desenhado por baixo.
        for m in (dentro(borda), fora(borda)):
            s += _faixa_mx(m - MEIOFIO, m + MEIOFIO, my0, fim, C["meiofio"])

        if vira:
            s += _chao(cotovelo_pontos(borda, prox, my1), asfalto)

    # A CURVA DE DENTRO (`136`), depois do laço: a quina reentrante de baixo
    # fica na reta do degrau seguinte, que se desenha na volta seguinte e
    # tapava o que aqui se pusesse. Primeiro o meio-fio, depois o asfalto.
    for i in range(len(DEGRAUS) - 1):
        my1, borda = DEGRAUS[i][1], DEGRAUS[i][2]
        prox = DEGRAUS[i + 1][2]
        for pedaco in quinas_de_dentro(borda, prox, my1, MEIOFIO):
            s += _chao(pedaco, C["meiofio"])
        for pedaco in quinas_de_dentro(borda, prox, my1, asfalto=True):
            s += _chao(pedaco, asfalto)

    # Acesso de cada berço: liga a rua ao avental, na altura do píer. É o que
    # explica para que serve a rua — sem ele ela passeia sem servir a nada.
    #
    # ⚠️ NO PORTO EM RUÍNAS ELE É DE TERRA (`136`). Era asfalto novo nos dois
    # mapas, três faixas escuras a cortar a terra batida de um porto que
    # abre em ruínas; o asfalto chega agora com a obra do pátio, que já
    # recorta o mapa pavimentado do avental para a rua. No de terra fica só
    # o sulco dos pneus, em `vias_detalhes()`. E ele começa na FRENTE da
    # calçada: a boca dele, que era asfalto por cima do passeio, é a guia
    # rebaixada — igual nos dois mapas, porque a calçada não se recapeia.
    for my0, my1, borda in PIERES:
        meio = (my0 + my1) / 2.0
        frente = fora(borda) + CALCADA
        if pavimentado:
            s += _faixa_mx(frente - COSTURA, borda - APRON,
                           meio - 0.6, meio + 0.6, asfalto)
        s += guia_rebaixada(borda, meio)
    return s


# A boca do acesso: 0,6 para cada lado do meio, a mesma largura do acesso.
ACESSO_MEIA = 0.6
# A aba de cada lado, onde o passeio desce até à guia.
ABA = 0.22


def guia_rebaixada(borda, meio) -> str:
    """A boca do acesso, onde ele atravessa a calçada do lado da água.

    O camião sobe do asfalto para o avental por cima do passeio, e o que lá
    está numa rua de verdade é a guia rebaixada: a calçada desce em rampa até
    ao nível da rua, com uma aba de cada lado e o meio-fio interrompido. Até à
    `136` era o asfalto do acesso pintado por cima do passeio.
    """
    f = borda - RUA_RECUO + RUA_LARG
    frente = f + CALCADA
    y0, y1 = meio - ACESSO_MEIA, meio + ACESSO_MEIA
    s = _faixa_mx(f - MEIOFIO, frente, y0, y1, C["rebaixo"])
    # As abas, em triângulo: largas na guia e a morrer no fundo do passeio.
    for borda_y, fora_y in ((y0, y0 - ABA), (y1, y1 + ABA)):
        s += _chao([(f - MEIOFIO, borda_y), (frente, borda_y),
                    (f - MEIOFIO, fora_y)], C["rebaixo"], 0.6)
    # O degrau da guia rebaixada, uma aresta fina rente à rua.
    s += _faixa_mx(f - MEIOFIO, f - MEIOFIO + 0.03, y0, y1, C["meiofio"])
    return s


# ── OS DETALHES DA RUA, GASTA E RECAPEADA (`136`) ────────────────────────
#
# Na conversa das estradas o Bruno escolheu tudo o que estava na mesa: a
# sinalização brasileira, o asfalto e a calçada com vida, os acessos com cara
# de entrada de porto, e a rua GASTA no porto em ruínas, recapeada com o
# pátio. E escreveu duas coisas que a lista não tinha: *«as sinalizações
# aparecem do nada depois de atualizar o pátio»* — medido, 27 mil pixels
# mudavam fora do recorte da obra — e *«essa troca tem que acontecer por
# partes, que nem quando algo está sendo construído»*: é a `obra_da_rua()`.
#
# ⚠️ NADA DAQUI SAI DO CONTORNO DA RUA, e é por isso que esta parte vive fora
# do `vias()`. O `horizonte_das_vias()` — a linha acima da qual a mata pode
# pintar — lê o contorno do `vias()`, e um tufo que subisse dois pixels acima
# do passeio mexeria a mata que o Bruno aceitou na `130`. Aqui pode haver
# traço e recorte (`<path>`, `<clipPath>`), que o leitor de contornos não
# conhece; e tudo cai dentro do passeio.
#
# ⚠️ E CADA SORTEIO TEM O SEU `Random` (`mapa.md`, `123`): a junta, a boca de
# lobo, o desgaste, o óleo, a tampa. O que é igual nos dois mapas sai da
# MESMA semente nos dois, e o que é só de um não mexe no outro.
SEMENTE_VIAS = SEMENTE_CHAO + 700
# A linha central: meia largura, traço e passo (o traço de 0,5 a cada 1,2 é o
# de antes), e quanto ela corre contínua antes e depois de cada cotovelo —
# nada, desde a segunda passagem da `136`: com 0,9 de cada lado o zigue-zague
# amarelo pesava em cada curva («linha contínua da curva pesada»).
FAIXA_MEIA = 0.05
TRACO, PASSO_TRACO = 0.5, 1.2
CURVA_CONTINUA = 0.0


def caminho_da_faixa(o: float, arcos: bool = False) -> tuple:
    """A linha que corre a `o` da face de TERRA da rua, de ponta a ponta.

    Nas retas ela fica a `o` da face de terra; nos cotovelos, a `o` da borda
    de `my` alto — é a regra das duas rotas do `TrafegoDeCamioes.gd` (a ida a
    `RUA_LARG / 4`, o retorno a 3/4), e o eixo da rua é `RUA_LARG / 2`. As
    quinas saem cortadas a `CORTE_DA_CURVA` de cada lado, que é como o camião
    as corta: pela diagonal (o sulco do pneu cai debaixo da roda) ou, com
    `arcos`, por um arco tangente nos mesmos dois pontos — a linha central,
    redonda desde a `136`, e entre as duas rotas, sem cruzar nenhuma.

    Devolve `(pontos, marcas)`: `marcas[i]` são os índices das quatro pontas
    das duas quinas do cotovelo `i` — as que o arco ou a diagonal ligam —, e
    a reta `i` começa na última do cotovelo de trás (no ponto 0, a primeira).
    """
    c = CORTE_DA_CURVA
    # O arco é CONCÊNTRICO com o da borda de fora: a primeira quina de cada
    # cotovelo contorna a saliente a `o` das bordas, a segunda a `RUA_LARG - o`,
    # e o raio é o da borda menos essa distância — no eixo, 1,38 − 0,9.
    ca = max(RAIO_COTOVELO - o, 0.05)
    cb = max(RAIO_COTOVELO - (RUA_LARG - o), 0.05)
    pts = [(DEGRAUS[0][2] - RUA_RECUO + o, DEGRAUS[0][0])]
    marcas = []
    for i in range(len(DEGRAUS) - 1):
        a = DEGRAUS[i][2] - RUA_RECUO + o
        b = DEGRAUS[i + 1][2] - RUA_RECUO + o
        y = DEGRAUS[i][1] - o
        a1 = len(pts)
        # A quina de cima: entra a descer (+my) e sai para o cais (+mx).
        pts += _arco(a + ca, y - ca, ca, 180.0, 90.0) if arcos else [(a, y - c), (a + c, y)]
        a2 = len(pts) - 1
        b1 = len(pts)
        # A de baixo: entra para o cais (+mx) e sai a descer (+my).
        pts += _arco(b - cb, y + cb, cb, -90.0, 0.0) if arcos else [(b - c, y), (b, y + c)]
        marcas.append((a1, a2, b1, len(pts) - 1))
    pts.append((DEGRAUS[-1][2] - RUA_RECUO + o, DEGRAUS[-1][1]))
    return pts, marcas


def _comprimentos(pts) -> list:
    acc = [0.0]
    for (x0, y0), (x1, y1) in zip(pts, pts[1:]):
        acc.append(math.fsum((acc[-1], math.hypot(x1 - x0, y1 - y0))))
    return acc


def _trecho(pts, acc, s0: float, s1: float) -> list:
    """Os pontos do caminho entre as distâncias `s0` e `s1`, ao longo dele."""
    out = []
    for k in range(len(pts) - 1):
        a, b = acc[k], acc[k + 1]
        if b <= s0 or a >= s1 or b - a < 1e-9:
            continue
        (x0, y0), (x1, y1) = pts[k], pts[k + 1]
        for s in ((max(s0, a),) if not out else ()) + (min(s1, b),):
            t = (s - a) / (b - a)
            out.append((x0 + (x1 - x0) * t, y0 + (y1 - y0) * t))
    return out


def _fita(pts, meia: float) -> list:
    """O contorno de uma fita de meia largura `meia` ao longo de `pts`, com as
    quinas em esquadria: a fita do cotovelo vira sem dente nem fresta."""
    limpos = []
    for q in pts:
        if not limpos or math.hypot(q[0] - limpos[-1][0], q[1] - limpos[-1][1]) > 1e-6:
            limpos.append(q)
    if len(limpos) < 2:
        return []
    normais = []
    for (x0, y0), (x1, y1) in zip(limpos, limpos[1:]):
        comp = math.hypot(x1 - x0, y1 - y0)
        normais.append((-(y1 - y0) / comp, (x1 - x0) / comp))
    esq, dir_ = [], []
    for k, (x, y) in enumerate(limpos):
        if k == 0:
            n = normais[0]
        elif k == len(limpos) - 1:
            n = normais[-1]
        else:
            (ax, ay), (bx, by) = normais[k - 1], normais[k]
            d = 1.0 + ax * bx + ay * by
            n = ((ax + bx) / d, (ay + by) / d)
        esq.append((x + n[0] * meia, y + n[1] * meia))
        dir_.append((x - n[0] * meia, y - n[1] * meia))
    return esq + dir_[::-1]


def _menos(intervalos, tira) -> list:
    """Os intervalos de `intervalos` sem os de `tira`."""
    out = []
    for a, b in intervalos:
        partes = [(a, b)]
        for c0, c1 in tira:
            novas = []
            for u, v in partes:
                if c1 <= u or c0 >= v:
                    novas.append((u, v))
                    continue
                if c0 > u:
                    novas.append((u, c0))
                if c1 < v:
                    novas.append((c1, v))
            partes = novas
        out += partes
    return out


def _zebras() -> list:
    """(degrau, my) de cada passadeira: na altura de cada prédio do pátio.

    ⚠️ O `my` SAI DOS PRÉDIOS, não de um número escrito aqui. Eles andaram em
    07/09 quando a rua alargou, e uma passadeira cravada ficaria a marcar a
    travessia de um prédio que já não está ali. O pedido era «faixas de
    pedestres perto do armazém e escritório»: quem trabalha no pátio
    atravessa a rua para a vila.
    """
    out = []
    for i, (my0, my1, _b) in enumerate(DEGRAUS):
        for _n, _pmx, pmy, _spr in PREDIOS_DO_PATIO:
            if my0 <= pmy < my1:
                out.append((i, pmy))
    return out


def _fio(pts, meia, cor, opac) -> str:
    """Uma fita de tinta no chão, ao longo de `pts` em coordenadas de mundo."""
    contorno = _fita(pts, meia)
    return _chao(contorno, cor, opac) if contorno else ""


def linha_central(gasta) -> str:
    """O eixo da rua, AMARELO: no Brasil é a cor que separa sentidos opostos.

    ⚠️ ERA BRANCO, e só no mapa do pátio pronto: tracejado nas retas e nada
    nos cotovelos, de modo que a mão dupla deixava de estar pintada em cada
    curva (`136`). Hoje é tracejado nas retas, CONTÍNUO à volta de cada
    cotovelo — na curva não se ultrapassa —, e interrompido nas passadeiras,
    onde a linha de retenção toma o lugar dele. `gasta` traz o sorteio do
    desgaste do porto em ruínas: a tinta apagada, a falhar aos bocados.
    """
    pts, marcas = caminho_da_faixa(RUA_LARG / 2.0, arcos=True)
    acc = _comprimentos(pts)
    continuas = [(acc[m[0]] - CURVA_CONTINUA, acc[m[3]] + CURVA_CONTINUA) for m in marcas]
    cortes = []
    for i, pmy in _zebras():
        k = 0 if i == 0 else marcas[i - 1][3]
        meio = acc[k] + (pmy - pts[k][1])
        meia = PASSADEIRA_COMP / 2.0 + 0.3
        cortes.append((meio - meia, meio + meia))
    pecas = list(_menos(continuas, cortes))
    for u, v in _menos(_menos([(0.0, acc[-1])], continuas), cortes):
        s = u + (PASSO_TRACO - TRACO) / 2.0
        while s + TRACO <= v:
            pecas.append((s, s + TRACO))
            s += PASSO_TRACO
    out = ""
    for u, v in pecas:
        partes = [(u, v)]
        if gasta is not None:
            if v - u > TRACO + 0.01:
                # O trecho contínuo gasta aos bocados.
                partes, s = [], u
                while s < v:
                    comp = gasta.uniform(0.35, 1.2)
                    partes.append((s, min(v, s + comp)))
                    s += comp + gasta.uniform(0.06, 0.3)
            elif gasta.random() < 0.22:
                continue          # o traço que já não está lá
            else:
                partes = [(u + gasta.uniform(0.0, 0.12), v - gasta.uniform(0.0, 0.12))]
        for a, b in partes:
            mx, my = _trecho(pts, acc, (a + b) / 2.0, (a + b) / 2.0 + 1e-3)[0]
            if not no_quadro(mx, my):
                continue
            opac = gasta.uniform(0.30, 0.46) if gasta is not None else 0.92
            out += _fio(_trecho(pts, acc, a, b), FAIXA_MEIA, C["tinta"], opac)
    return out


def retencoes(gasta) -> str:
    """A linha de retenção antes de cada passadeira, uma por sentido.

    A ida desce em `+my` pela faixa da vila e para antes da zebra; o retorno
    sobe pela faixa da água e para depois dela (`docs/decisoes/052`).
    """
    s = ""
    for i, pmy in _zebras():
        d = DEGRAUS[i][2] - RUA_RECUO
        meio = d + RUA_LARG / 2.0
        meia = PASSADEIRA_COMP / 2.0 + 0.28
        for x0, x1, y in ((d + 0.08, meio - 0.08, pmy - meia),
                          (meio + 0.08, d + RUA_LARG - 0.08, pmy + meia)):
            opac = gasta.uniform(0.25, 0.4) if gasta is not None else 0.9
            s += _faixa_mx(x0, x1, y - 0.04, y + 0.04, C["faixa_via"], opac)
    return s


def _regioes_do_asfalto(encolhe: float) -> list:
    """O asfalto da rua em polígonos, reta a reta e cotovelo a cotovelo,
    encolhido de `encolhe` para o desgaste não pintar o meio-fio:
    (polígono, (mx0, mx1, my0, my1), ao longo de my?)."""
    out = []
    n = len(DEGRAUS)
    for i, (my0, my1, borda) in enumerate(DEGRAUS):
        d = borda - RUA_RECUO
        fim = my1 - RUA_LARG if i + 1 < n else my1
        x0, x1 = d + MEIOFIO + encolhe, d + RUA_LARG - MEIOFIO - encolhe
        out.append(([(x0, my0), (x1, my0), (x1, fim), (x0, fim)],
                    (x0, x1, my0, fim), True))
        if i + 1 < n:
            prox = DEGRAUS[i + 1][2]
            pol = cotovelo_pontos(borda, prox, my1, -(MEIOFIO + encolhe))
            xs = [q[0] for q in pol]
            ys = [q[1] for q in pol]
            out.append((pol, (min(xs), max(xs), min(ys), max(ys)), False))
    return out


def desgaste_da_rua(r: random.Random) -> str:
    """O asfalto do porto em ruínas: remendos, fissuras e buracos.

    O remendo é mais ESCURO do que a rua (é mais novo do que ela) e tem a
    selagem à volta; a fissura anda aos ziguezagues e abre um ramo; o buraco
    é um poço escuro com a borda clara do lado de lá. Tudo recortado ao
    asfalto, reta a reta, para nada pisar o meio-fio.
    """
    s = ""
    for k, (pol, (x0, x1, y0, y1), ao_longo_my) in enumerate(_regioes_do_asfalto(0.04)):
        comp = (y1 - y0) if ao_longo_my else (x1 - x0)
        dentro = ""

        def ponto():
            return r.uniform(x0, x1), r.uniform(y0, y1)

        for _ in range(max(1, round(comp / 4.0))):
            cx, cy = ponto()
            if r.random() < 0.35:
                # Remendo de uma faixa inteira: o corte de uma obra antiga.
                ao = r.uniform(0.4, 1.1)
                fx = (x0, (x0 + x1) / 2.0) if r.random() < 0.5 else ((x0 + x1) / 2.0, x1)
                caixa = ((fx[0], cy - ao / 2.0, fx[1], cy + ao / 2.0) if ao_longo_my
                         else (cx - ao / 2.0, y0 + r.uniform(0.0, 0.6),
                               cx + ao / 2.0, y1 - r.uniform(0.0, 0.6)))
            else:
                a, b = r.uniform(0.3, 0.8), r.uniform(0.25, 0.5)
                if not ao_longo_my:
                    a, b = b, a
                caixa = (cx - b / 2.0, cy - a / 2.0, cx + b / 2.0, cy + a / 2.0)
            if not no_quadro((caixa[0] + caixa[2]) / 2.0, (caixa[1] + caixa[3]) / 2.0):
                continue
            # ⚠️ DE BORDA IRREGULAR E SEM SELAGEM À VOLTA: retângulos com o
            # contorno escuro liam como CAIXAS desenhadas no asfalto (segunda
            # passagem da `136`, «remendos quadrados no dia 1»).
            cantos = [(caixa[0], caixa[1]), (caixa[2], caixa[1]),
                      (caixa[2], caixa[3]), (caixa[0], caixa[3])]
            canto = []
            for j in range(4):
                (ax, ay), (bx, by) = cantos[j], cantos[(j + 1) % 4]
                for t in (0.0, 0.34, 0.67):
                    canto.append((ax + (bx - ax) * t + r.uniform(-0.045, 0.045),
                                  ay + (by - ay) * t + r.uniform(-0.045, 0.045)))
            dentro += _chao(canto, C["remendo"], r.uniform(0.55, 0.8))
        for _ in range(max(1, round(comp / 2.2))):
            mx, my = ponto()
            if not no_quadro(mx, my):
                continue
            ang = (math.pi / 2.0 if ao_longo_my else 0.0) if r.random() < 0.6 \
                else (0.0 if ao_longo_my else math.pi / 2.0)
            ang += r.uniform(-0.45, 0.45)
            ramos = [(mx, my, ang, r.randint(6, 11))]
            caminhos = []
            while ramos:
                bx, by, ba, passos = ramos.pop()
                linha = [p(bx, by, ALT_CAIS)]
                for j in range(passos):
                    ba += r.uniform(-0.45, 0.45)
                    passo = r.uniform(0.09, 0.18)
                    bx, by = bx + math.cos(ba) * passo, by + math.sin(ba) * passo
                    linha.append(p(bx, by, ALT_CAIS))
                    if j == passos // 2 and len(caminhos) == 0 and r.random() < 0.55:
                        ramos.append((bx, by, ba + r.choice((-1, 1)) * r.uniform(0.6, 1.1),
                                      r.randint(3, 5)))
                caminhos.append(linha)
            d = " ".join("M%.1f,%.1f " % c[0] + " ".join("L%.1f,%.1f" % q for q in c[1:])
                         for c in caminhos)
            dentro += ('  <path d="%s" fill="none" stroke="%s" stroke-width="1.0" '
                       'stroke-linecap="round" stroke-linejoin="round" opacity="0.5"/>\n'
                       % (d, C["fissura"]))
        if ao_longo_my and r.random() < 0.6:
            # O buraco, numa faixa de rodagem.
            mx = (x0 + (x0 + x1) / 2.0) / 2.0 if r.random() < 0.5 else ((x0 + x1) / 2.0 + x1) / 2.0
            my = r.uniform(y0 + 0.5, y1 - 0.5)
            if no_quadro(mx, my):
                cx, cy = p(mx + r.uniform(-0.15, 0.15), my, ALT_CAIS)
                rx = r.uniform(3.5, 5.5)
                dentro += ('  <ellipse cx="%.1f" cy="%.1f" rx="%.1f" ry="%.1f" fill="%s" '
                           'opacity="0.8"/>\n' % (cx, cy + 0.6, rx + 1.2, rx / 2.0 + 0.7,
                                                  C["buraco_borda"]))
                dentro += ('  <ellipse cx="%.1f" cy="%.1f" rx="%.1f" ry="%.1f" fill="%s"/>\n'
                           % (cx, cy, rx, rx / 2.0, C["buraco"]))
        if dentro:
            ident = "rua_gasta%d" % k
            s += '  <clipPath id="%s"><polygon points="%s"/></clipPath>\n' % (
                ident, " ".join("%.1f,%.1f" % p(x, y, ALT_CAIS) for x, y in pol))
            s += '  <g clip-path="url(#%s)">\n%s  </g>\n' % (ident, dentro)
    return s


def _quadro_do_pedaco(j: int) -> int:
    """O dia da obra de cada pedaço de `_regioes_do_asfalto`: a reta `i` é o
    pedaço `2i`, o cotovelo `i` o `2i + 1` — e a obra leva as duas primeiras
    retas e o primeiro cotovelo no dia 0, e cada cotovelo com a reta a
    seguir nos dias seguintes (`obra_da_rua`)."""
    i, cotovelo = divmod(j, 2)
    if cotovelo:
        return min(i, OBRA_DIAS)
    return 0 if i <= 1 else min(i - 1, OBRA_DIAS)


def emendas_do_recapeamento(r: random.Random) -> str:
    """O asfalto recapeado não é uma chapa: cada dia da obra deixou o seu tom,
    muito leve, a junta onde um dia encontrou o seguinte, e uma trinca selada
    aqui e ali (terceira passagem da `136`, «rua recapeada lisa demais»). Os
    tons e as juntas caem nos trechos da obra, e a obra mostra-os com eles."""
    tons = [("#ffffff", 0.035), ("#000000", 0.04), ("#ffffff", 0.02), ("#000000", 0.025)]
    s = ""
    regioes = _regioes_do_asfalto(0.0)
    for j, (pol, (x0, x1, y0, y1), ao_longo_my) in enumerate(regioes):
        cor, opac = tons[_quadro_do_pedaco(j) % len(tons)]
        s += _chao(pol, cor, opac)
    for i in range(len(DEGRAUS) - 1):
        if _quadro_do_pedaco(2 * i) == _quadro_do_pedaco(2 * i + 1):
            continue
        d = DEGRAUS[i][2] - RUA_RECUO
        ya = DEGRAUS[i][1] - RUA_LARG
        if no_quadro(d + RUA_LARG / 2.0, ya):
            s += ('  <path d="M%.1f,%.1f L%.1f,%.1f" stroke="#353c42" stroke-width="1.0" '
                  'opacity="0.45"/>\n' % (*p(d + MEIOFIO, ya, ALT_CAIS),
                                          *p(d + RUA_LARG - MEIOFIO, ya, ALT_CAIS)))
    for pol, (x0, x1, y0, y1), ao_longo_my in regioes:
        if not ao_longo_my or y1 - y0 < 3.0:
            continue
        mx, my = r.uniform(x0 + 0.2, x1 - 0.2), r.uniform(y0 + 0.8, y1 - 0.8)
        if not no_quadro(mx, my):
            continue
        ang = math.pi / 2.0 + r.uniform(-0.3, 0.3)
        linha = [p(mx, my, ALT_CAIS)]
        for _ in range(r.randint(6, 10)):
            ang += r.uniform(-0.35, 0.35)
            mx = min(max(mx + math.cos(ang) * 0.15, x0 + 0.05), x1 - 0.05)
            my += math.sin(ang) * 0.15
            linha.append(p(mx, my, ALT_CAIS))
        s += ('  <path d="M%s" stroke="#2f363b" stroke-width="1.3" fill="none" '
              'stroke-linecap="round" stroke-linejoin="round" opacity="0.28"/>\n'
              % " L".join("%.1f,%.1f" % q for q in linha))
    return s


def manchas_da_rua(r: random.Random, gasta: bool) -> str:
    """O óleo que pinga no meio de cada faixa, mais junto da boca dos acessos,
    e o sulco do pneu em cada curva — na rua gasta, mais e mais escuros."""
    s = ""
    for o in (RUA_LARG / 4.0, RUA_LARG * 3.0 / 4.0):
        pts, _marcas = caminho_da_faixa(o)
        acc = _comprimentos(pts)
        for _ in range(26 if gasta else 7):
            v = r.uniform(0.0, acc[-1] - 0.01)
            mx, my = _trecho(pts, acc, v, v + 1e-3)[0]
            if not no_quadro(mx, my):
                continue
            cx, cy = p(mx + r.uniform(-0.06, 0.06), my, ALT_CAIS)
            rx = r.uniform(3.5, 9.0)
            s += ('  <ellipse cx="%.1f" cy="%.1f" rx="%.1f" ry="%.1f" fill="%s" '
                  'opacity="%.2f"/>\n' % (cx, cy, rx, rx / 2.0, C["oleo"],
                                          r.uniform(0.12, 0.24) if gasta
                                          else r.uniform(0.08, 0.14)))
        # O sulco das rodas em cada curva, de um lado e do outro do camião.
        # ⚠️ AOS BOCADOS: inteiro e paralelo ao eixo, lia como uma faixa
        # pintada a mais (a primeira passagem da `136`).
        for roda in (-0.16, 0.16):
            rp, rm = caminho_da_faixa(o + roda)
            ra = _comprimentos(rp)
            for a1, a2, b1, b2 in rm:
                for k0, k1 in ((a1, a2), (b1, b2)):
                    a = ra[k0] - r.uniform(0.1, 0.35)
                    while a < ra[k1] + 0.2:
                        b = a + r.uniform(0.15, 0.4)
                        trecho = _trecho(rp, ra, a, b)
                        if trecho and no_quadro(*trecho[0]):
                            s += _fio(trecho, 0.022, C["oleo"],
                                      r.uniform(0.08, 0.16) if gasta else r.uniform(0.05, 0.1))
                        a = b + r.uniform(0.05, 0.25)
    for my0, my1, borda in PIERES:
        meio = (my0 + my1) / 2.0
        faixa = borda - RUA_RECUO + RUA_LARG * 0.75
        for _ in range(4 if gasta else 2):
            cx, cy = p(faixa + r.uniform(-0.2, 0.25), meio + r.uniform(-0.7, 0.7), ALT_CAIS)
            rx = r.uniform(4.0, 8.0)
            s += ('  <ellipse cx="%.1f" cy="%.1f" rx="%.1f" ry="%.1f" fill="%s" '
                  'opacity="%.2f"/>\n' % (cx, cy, rx, rx / 2.0, C["oleo"],
                                          r.uniform(0.14, 0.26) if gasta else 0.12))
    return s


def tampas_da_rua(r: random.Random) -> str:
    """Uma tampa de bueiro por reta, numa faixa de rodagem — igual nos dois
    mapas: o recapeamento passa à volta dela."""
    s = ""
    n = len(DEGRAUS)
    zebras = _zebras()
    for i, (my0, my1, borda) in enumerate(DEGRAUS):
        fim = my1 - RUA_LARG if i + 1 < n else my1
        mx = borda - RUA_RECUO + r.choice((RUA_LARG / 4.0, RUA_LARG * 3.0 / 4.0))
        my = r.uniform(my0 + 0.9, fim - 0.9) if fim - my0 > 2.0 else (my0 + fim) / 2.0
        if any(j == i and abs(my - pmy) < 1.0 for j, pmy in zebras) or not no_quadro(mx, my):
            continue
        cx, cy = p(mx, my, ALT_CAIS)
        s += ('  <ellipse cx="%.1f" cy="%.1f" rx="5.0" ry="2.5" fill="%s" '
              'stroke="%s" stroke-width="1.0"/>\n' % (cx, cy, C["tampa"], C["bueiro"]))
        s += ('  <ellipse cx="%.1f" cy="%.1f" rx="3.0" ry="1.5" fill="none" '
              'stroke="%s" stroke-width="0.6"/>\n' % (cx, cy, C["grelha"]))
    return s


def _boca_de_lobo(x0, x1, y0, y1, ao_longo_my: bool) -> str:
    s = _chao([(x0, y0), (x1, y0), (x1, y1), (x0, y1)], C["bueiro"])
    linhas = []
    for t in (0.25, 0.5, 0.75):
        if ao_longo_my:
            y = y0 + (y1 - y0) * t
            linhas.append((p(x0, y, ALT_CAIS), p(x1, y, ALT_CAIS)))
        else:
            x = x0 + (x1 - x0) * t
            linhas.append((p(x, y0, ALT_CAIS), p(x, y1, ALT_CAIS)))
    s += ('  <path d="%s" stroke="%s" stroke-width="0.7" fill="none"/>\n'
          % (" ".join("M%.1f,%.1f L%.1f,%.1f" % (a + b) for a, b in linhas), C["grelha"]))
    return s


def bocas_de_lobo() -> str:
    """A grelha da boca de lobo na sarjeta, rente ao meio-fio, dos dois lados
    — a cada 3,1 unidades, fora das bocas dos acessos e das zebras."""
    s = ""
    n = len(DEGRAUS)
    zebras = _zebras()
    acessos = [(my0 + my1) / 2.0 for my0, my1, _b in PIERES]
    for i, (my0, my1, borda) in enumerate(DEGRAUS):
        d = borda - RUA_RECUO
        f = d + RUA_LARG
        fim = my1 - RUA_LARG if i + 1 < n else my1
        y = my0 + 1.0
        while y < fim - 0.6:
            livre = not any(j == i and abs(y - pmy) < 0.8 for j, pmy in zebras)
            if livre and no_quadro(d + RUA_LARG / 2.0, y):
                s += _boca_de_lobo(d + MEIOFIO, d + MEIOFIO + 0.07, y - 0.14, y + 0.14, True)
                if all(abs(y - a) > ACESSO_MEIA + ABA + 0.3 for a in acessos):
                    s += _boca_de_lobo(f - MEIOFIO - 0.07, f - MEIOFIO, y - 0.14, y + 0.14, True)
            y += 3.1
        if i + 1 < n:
            # No cotovelo, uma na sarjeta de baixo, a meio do meio-fio livre.
            prox = DEGRAUS[i + 1][2]
            x = (d + RAIO_COTOVELO + prox - RUA_RECUO) / 2.0
            if no_quadro(x, my1):
                s += _boca_de_lobo(x - 0.14, x + 0.14, my1 - MEIOFIO - 0.07, my1 - MEIOFIO, False)
    return s


def _tufinho(px: float, py: float, r: random.Random) -> str:
    """Capim na fresta da calçada: duas ou três lâminas de três pixels."""
    s = ""
    for _ in range(r.randint(2, 3)):
        tx, ty = px + r.uniform(-1.5, 1.5), py + r.uniform(-0.5, 0.5)
        dx, a = r.uniform(-2.0, 2.0), r.uniform(2.0, 3.4)
        s += ('  <path d="M%.1f %.1f q%.1f %.1f %.1f %.1f" stroke="%s" stroke-width="1.0" '
              'fill="none" stroke-linecap="round" opacity="0.7"/>\n'
              % (tx, ty, dx * 0.25, -a * 0.7, dx, -a, C["mato"]))
    return s


def juntas_da_calcada(r: random.Random) -> str:
    """A calçada em placas de cimento: a junta a cada 0,55, e capim nalgumas
    frestas do lado de BAIXO na tela (o da água nas retas, o de `my` alto nos
    cotovelos), onde o tufo não sobe acima do passeio."""
    juntas, tufos = [], ""
    n = len(DEGRAUS)
    acessos = [(my0 + my1) / 2.0 for my0, my1, _b in PIERES]

    def junta(a, b, capim_em=None):
        if not no_quadro(*a):
            return ""
        juntas.append((p(*a, ALT_CAIS), p(*b, ALT_CAIS)))
        if capim_em is not None and r.random() < 0.2:
            return _tufinho(*p(*capim_em, ALT_CAIS), r)
        return ""

    for i, (my0, my1, borda) in enumerate(DEGRAUS):
        d = borda - RUA_RECUO
        f = d + RUA_LARG
        fim = my1 - RUA_LARG if i + 1 < n else my1
        y = my0 + 0.3
        while y < fim:
            tufos += junta((d - MEIOFIO, y), (d - CALCADA, y))
            if all(abs(y - a) > ACESSO_MEIA + ABA for a in acessos):
                tufos += junta((f + MEIOFIO, y), (f + CALCADA, y),
                               (f + CALCADA - 0.03, y))
            y += 0.55
        if i + 1 < n:
            prox = DEGRAUS[i + 1][2]
            f1 = prox - RUA_RECUO + RUA_LARG
            ya, yb = my1 - RUA_LARG, my1
            x = d + RUA_LARG + 0.3
            while x < f1 - RAIO_COTOVELO - 0.2:
                tufos += junta((x, ya - MEIOFIO), (x, ya - CALCADA))
                x += 0.55
            x = d + RAIO_COTOVELO + 0.2
            while x < f1 - RUA_LARG - 0.3:
                tufos += junta((x, yb + MEIOFIO), (x, yb + CALCADA),
                               (x, yb + CALCADA - 0.03))
                x += 0.55
    s = ""
    if juntas:
        s += ('  <path d="%s" stroke="%s" stroke-width="0.8" fill="none"/>\n'
              % (" ".join("M%.1f,%.1f L%.1f,%.1f" % (a + b) for a, b in juntas),
                 C["junta_calcada"]))
    return s + tufos


def acessos_detalhes(gasta: bool, r: random.Random) -> str:
    """O acesso de cada berço: o sulco de terra no porto em ruínas, e no pátio
    pronto a retenção na boca e o zebrado amarelo de manobra junto do avental,
    onde o camião encosta de ré (`136`)."""
    s = ""
    for k, (my0, my1, borda) in enumerate(PIERES):
        meio = (my0 + my1) / 2.0
        frente = borda - RUA_RECUO + RUA_LARG + CALCADA
        av = borda - APRON
        if gasta:
            # A terra batida pelo uso, e os dois sulcos das rodas.
            s += _faixa_mx(frente, av, meio - 0.42, meio + 0.42, C["terra_escura"], 0.2)
            for roda in (-0.17, 0.17):
                linha, x = [], frente + 0.05
                while x < av - 0.05:
                    linha.append(p(x, meio + roda + r.uniform(-0.03, 0.03), ALT_CAIS))
                    x += r.uniform(0.35, 0.6)
                linha.append(p(av - 0.05, meio + roda, ALT_CAIS))
                s += ('  <path d="M%s" stroke="#66563f" stroke-width="2.2" fill="none" '
                      'stroke-linecap="round" stroke-linejoin="round" opacity="0.45"/>\n'
                      % " L".join("%.1f,%.1f" % q for q in linha))
            continue
        s += _faixa_mx(frente + 0.1, frente + 0.17, meio - 0.55, meio + 0.55,
                       C["faixa_via"], 0.9)
        x0, x1 = av - 0.42, av - 0.08
        y0, y1 = meio - 0.5, meio + 0.5
        ident = "zebrado%d" % k
        caixa = [(x0, y0), (x1, y0), (x1, y1), (x0, y1)]
        s += '  <clipPath id="%s"><polygon points="%s"/></clipPath>\n' % (
            ident, " ".join("%.1f,%.1f" % p(x, y, ALT_CAIS) for x, y in caixa))
        listras = ""
        t = x0 + y0
        while t < x1 + y1:
            # A listra a 45° no chão: entre `mx + my = t` e `t + 0,08`.
            listras += _chao([(t - y0 + 0.3, y0 - 0.3), (t + 0.08 - y0 + 0.3, y0 - 0.3),
                              (t + 0.08 - y1 - 0.3, y1 + 0.3), (t - y1 - 0.3, y1 + 0.3)],
                             C["tinta"], 0.9)
            t += 0.22
        s += '  <g clip-path="url(#%s)">\n%s  </g>\n' % (ident, listras)
        for a, b, c, d in ((x0, x1, y0, y0 + 0.04), (x0, x1, y1 - 0.04, y1),
                           (x0, x0 + 0.04, y0, y1), (x1 - 0.04, x1, y0, y1)):
            s += _faixa_mx(a, b, c, d, C["tinta"], 0.9)
    return s


def vias_detalhes(pavimentado: bool) -> str:
    """Tudo o que se pinta DENTRO do contorno da rua: a rua gasta do porto em
    ruínas, ou a recapeada do pátio pronto (`136`)."""
    gasta = not pavimentado
    s = ""
    if gasta:
        s += desgaste_da_rua(random.Random(SEMENTE_VIAS + 3))
    else:
        s += emendas_do_recapeamento(random.Random(SEMENTE_VIAS + 8))
    s += manchas_da_rua(random.Random(SEMENTE_VIAS + (4 if gasta else 14)), gasta)
    s += tampas_da_rua(random.Random(SEMENTE_VIAS + 5))
    s += bocas_de_lobo()
    tinta = random.Random(SEMENTE_VIAS + 6) if gasta else None
    s += linha_central(tinta)
    for i, pmy in _zebras():
        s += passadeira(DEGRAUS[i][2], pmy, tinta)
    s += retencoes(tinta)
    s += acessos_detalhes(gasta, random.Random(SEMENTE_VIAS + 7))
    s += juntas_da_calcada(random.Random(SEMENTE_VIAS + 1))
    return s


# ── A OBRA DA RUA (`136`) ────────────────────────────────────────────────
#
# A rua recapeia-se com a obra do pátio, UM TRECHO POR DIA, do norte para o
# sul: o Bruno pediu que a troca da rua gasta pela nova acontecesse *«por
# partes, que nem quando algo está sendo construído»*. O jogo mostra cada
# trecho pronto recortando o mapa pavimentado por cima do de terra, como já
# fazia ao pátio (`ObraNoMapa.gd`, `121`); o último trecho fica para o dia em
# que a obra acaba e o mapa inteiro troca.
#
# Cada polígono vai até ao MEIO da calçada, que é igual nos dois mapas: o
# antisserrilhado da borda do recorte cai em chão que não muda. E o trecho
# seguinte sobrepõe-se ao anterior (o cotovelo começa `CALCADA / 2` antes do
# fim da reta), para a junta entre dois trechos prontos não abrir uma fresta.
#
# `OBRA_DIAS` são os dias da obra do pátio — os quadros do `CANTEIRO` do
# `ObraNoMapa.gd`; o D45 confere que são os mesmos.
OBRA_DIAS = 3


def cones_da_obra() -> list:
    """(quadro, pontos em mundo) dos cones de cada dia da obra da rua.

    *«Obra da rua sem sinalização»*, marcou o Bruno na segunda passagem da
    `136`: o trecho a recapear trocava de cor e mais nada. No dia `q` a obra
    está na FRENTE do trecho seguinte — onde a rua nova acaba e a gasta
    continua —, e é lá que ficam dois cones no eixo, do lado da rua gasta,
    no troço reto do cotovelo que a abre, com o cavalete entre eles — ali a
    linha central fica a 0,45 de cada rota, e a carroçaria mais o cone cabem
    em 0,32; na curva o camião corta pela diagonal e passa a 0,2 do eixo.
    """
    pts, marcas = caminho_da_faixa(RUA_LARG / 2.0, arcos=True)
    acc = _comprimentos(pts)
    out = []
    for q in range(OBRA_DIAS):
        # O trecho seguinte abre no cotovelo `q + 1`. Os cones ficam no troço
        # RETO dele, entre os dois arcos do eixo: depois do primeiro arco.
        reto = acc[marcas[q + 1][1]]
        cones = []
        # ⚠️ NO RETO DO COTOVELO (terceira passagem). A 0,45 uns dos outros
        # liam como um monte («cones amontoados»); antes da curva caíam na
        # passadeira, que fica logo antes de cada cotovelo; e NA curva o
        # camião, que a corta pela diagonal, passa a 0,2 do eixo e pisá-los-ia.
        # ⚠️ E SÃO DOIS, A 1,9 UM DO OUTRO (quarta passagem, escolha do Bruno:
        # cone, cavalete, cone). Com três cones e dois cavaletes a 0,9 sobrava
        # 0,1 entre a base de um e o pé do outro, e a fila lia como uma
        # barreira só (*«pode afastar o espaço entre os cones e cavaletes»*);
        # assim sobra 0,6 de cada lado. O troço que o camião deixa livre vai de
        # 1,0 a 3,2 do eixo (medido na terceira), e os dois cabem nele de
        # ponta a ponta: a base de cada cone (0,15) encosta a um extremo.
        # O poste da quina de dentro, sem luminária, fica na tela na coluna
        # do eixo a 1,88: entre o primeiro cone e o cavalete, a tapar-lhe
        # só a ponta com a haste (`brp_porto.POSTE_GIROS`).
        for avanco in (0.57, 2.47):
            mx, my = _trecho(pts, acc, reto + avanco, reto + avanco + 1e-3)[0]
            cones.append((round(mx, 3), round(my, 3)))
        out.append((q, cones))
    return out


def obra_da_rua() -> list:
    """(quadro, polígono em mundo) de cada pedaço da rua, pela ordem da obra.

    O quadro `q` é o dia da obra em que o pedaço fica pronto; `OBRA_DIAS` é
    o dia em que a obra acaba. O dia 0 leva a reta de cima, o primeiro
    cotovelo e a reta do berço 1; cada dia seguinte, um cotovelo e a reta a
    seguir a ele; e o fim, o resto para sul.
    """
    n = len(DEGRAUS)
    meia = CALCADA / 2.0

    def reta(i):
        my0, my1, borda = DEGRAUS[i]
        d = borda - RUA_RECUO
        fim = my1 - RUA_LARG if i + 1 < n else my1 + COSTURA
        return [(d - meia, my0), (d + RUA_LARG + meia, my0),
                (d + RUA_LARG + meia, fim), (d - meia, fim)]

    def cotovelo(i):
        return cotovelo_pontos(DEGRAUS[i][2], DEGRAUS[i + 1][2], DEGRAUS[i][1], meia)

    def dentro(i):
        # As duas quinas de dentro do cotovelo, que avançam sobre o canto do
        # pátio e o da vila: chegam com o cotovelo.
        return quinas_de_dentro(DEGRAUS[i][2], DEGRAUS[i + 1][2], DEGRAUS[i][1], meia)

    pecas = [(0, reta(0)), (0, cotovelo(0))] + [(0, q) for q in dentro(0)] + [(0, reta(1))]
    for i in range(1, n - 1):
        q = quadro_da_reta(i + 1)
        pecas += [(q, cotovelo(i))] + [(q, d) for d in dentro(i)] + [(q, reta(i + 1))]
    return [(q, [(round(x, 3), round(y, 3)) for x, y in pol]) for q, pol in pecas]


def quadro_da_reta(i: int) -> int:
    """O dia da obra em que a reta `i` da rua fica recapeada: as duas de cima
    no dia 0, cada uma das seguintes no dia a seguir, e o resto no fim
    (`OBRA_DIAS`). Um lugar só, para a `obra_da_rua()` e o mobiliário que
    troca com ela (`140`) não poderem discordar."""
    return 0 if i <= 1 else min(i - 1, OBRA_DIAS)


def cavaletes_da_obra() -> list:
    """(quadro, pontos em mundo) dos cavaletes de cada dia da obra da rua.

    ⚠️ NA CALÇADA DO PÁTIO, E NÃO NO EIXO (quarta passagem, escolha do
    Bruno). Ele ia ENTRE os cones, e o poste da quina de dentro, na calçada
    da vila do lado de cá do cotovelo, cai na tela na coluna do meio do troço
    livre do eixo (a 1,88, entre 1,0 e 3,2): com o braço da luz tapava o
    cavalete, sem ele encostava-lhe (*«poste junto ao cavalete»*), e não há
    sítio do troço que fuja dele. Agora os dois cones ficam no eixo com o
    poste no vão entre eles, e o cavalete fecha a calçada do pátio do mesmo
    cotovelo, ao longo dela, como numa obra de passeio — a `FRACAO_DO_CAVALETE`
    do troço reto dela, à direita do segundo cone na tela."""
    out = []
    for q, _cones in cones_da_obra():
        i = q + 1
        _my0, my1, borda = DEGRAUS[i]
        de = borda - RUA_RECUO + RUA_LARG + RAIO_DE_DENTRO
        ate = DEGRAUS[i + 1][2] - RUA_RECUO + RUA_LARG - RAIO_COTOVELO
        mx = de + (ate - de) * FRACAO_DO_CAVALETE
        out.append((q, [(round(mx, 3), round(my1 - RUA_LARG - CALCADA / 2.0, 3))]))
    return out


# Onde vai o cavalete no troço reto da calçada do pátio do cotovelo, da quina
# de dentro para a curva de fora: aos 3/4, a ~1 px à direita do segundo cone
# na tela e atrás dele, e longe do braço da luz do poste da quina.
FRACAO_DO_CAVALETE = 0.75


# ── O MOBILIÁRIO DA RUA (`140`) ──────────────────────────────────────────
#
# Escolha do Bruno: postes de luz só na calçada da VILA, e as placas — o PARE
# na boca de cada acesso ao berço e uma de velocidade na do PORTO, a de
# pedestres antes de cada zebra na da vila. Cada peça troca da velha para a
# nova no dia em que o trecho dela é recapeado (`quadro_da_reta()`), como o
# asfalto. E desde a quarta passagem a rede tem de onde vir: a subestação no
# campo ao norte do pátio, com a linha que chega da borda de cima do mapa.
#
# ⚠️ AS PLACAS SERVEM QUEM SOBE A RUA POR CAUSA DA CÂMARA, e não por gosto.
# Ela só vê as faces viradas para `+mx` e `+my`: uma placa para quem DESCE a
# rua (`+my`) olha para `-my` e mostraria o verso. As de pedestres e a de
# velocidade servem quem SOBE; o PARE olha para `+mx`, para o camião que sai
# do acesso.
#
# O `my` dos postes das retas saiu da foto (`140`): um a cada ~3,5 de
# calçada, contando os das curvas, e nenhum em frente a uma zebra. O último
# fica fora do quadro, para a rede não acabar à vista; o primeiro recebe o
# ramal da subestação, por cima da rua (`ramal`, a cruzeta a −45°).
POSTES_DA_RUA = [(1, -1.0), (1, 2.5), (2, 11.8), (3, 19.7), (4, 27.2), (4, 30.7)]
# OS POSTES DAS CURVAS, em cada cotovelo à vista (o 0 fica acima do quadro e
# o 4 à esquerda dele). Terceira passagem, *«a rede acaba no cotovelo»*: um a
# meio do arco de fora. Quarta, *«fio corta o cotovelo»* e *«fio por cima
# das casas»*: a corda desse poste até ao primeiro da reta seguinte
# atravessava o asfalto da curva e o lote da esquina, onde está a igreja.
# Agora vão dois no arco de fora, a 1/4 e a 3/4 dele, e um na quina de
# dentro: as cordas ficam no meio da calçada, a no máximo 0,113 dele (a corda
# de um arco de 45°), e a calçada tem 0,11 de meia largura. O D45 confere-o.
QUINAS_DA_RUA = [1, 2, 3]
# Os ângulos, no arco de fora (de 180°, na reta, a 90°, no cotovelo), dos
# dois postes da curva; o giro de cada um é o ângulo da cruzeta de través à
# rua, que o `brp_porto.POSTE_GIROS` renderiza.
ARCO_DOS_POSTES = [("curva_a", 157.5), ("curva_b", 112.5)]
# (reta, my) da placa de velocidade: para quem sobe, a entrar na reta 3.
VELOCIDADE_DA_RUA = [(3, 21.4)]
# A placa fica fora da guia rebaixada do acesso (`ABA`) e da zebra, a esta
# distância delas.
FOLGA_DA_PLACA = 0.15
# ⚠️ A DE PEDESTRES VIVE NA CALÇADA DA VILA (quarta passagem da `140`,
# escolha do Bruno). Na do porto, a 1,0 do meio da zebra, a chapa subia na
# tela por cima das barras (*«placa de pedestres sobre a zebra»*), e medido a
# cada 0,1 ao longo daquela calçada os sítios que a zebra não apanha são os
# que o escritório e o armazém tapam; a calçada do pátio do cotovelo também
# não lhe serviu. Na da vila, a esta distância do meio da zebra para `+my`,
# ela é «antes da travessia» para quem SOBE — à esquerda dele, que é a face
# que a câmara vê — e a chapa sobe na tela sobre o lote de trás, 9 px ao lado
# das barras.
AVISO_DA_ZEBRA = 1.0

# A LINHA DA REDE E A SUBESTAÇÃO (quarta passagem): *«pode colocar postes até
# um dos limites do mapa para mostrar que a energia vem de algum lugar, pode
# até fazer uma subestação de energia lá»*; o Bruno escolheu o campo ao norte
# do pátio. A linha chega-lhe de fora do quadro, pelo campo da reta 0, e o
# poste de saída leva a energia por cima da rua até ao primeiro poste da
# vila. Ficam sempre NOVOS (`quadro` −1): são da cidade, e a obra do porto
# não lhes toca.
# ⚠️ NO RELVADO, E A AROEIRA SAI (quinta passagem, *«fora da areia, no
# relvado»*). Medido no raster do mapa sem props: o relvado vai da calçada a
# ~3,0 em `mx` a meio do campo e a ~4,0 a sul, e as plantas da restinga
# desenham-se por cima de todo prop (o D47 reprova qualquer caixa que lhes
# toque). Com todas lá, a subestação inteira só cabia em relva com 1,3 × 1,6;
# sem a aroeira, cabe com 1,4 × 1,9 no sítio dela, a 99%. O Bruno deixou-a
# sair; quem a tira é o `_no_lote_da_subestacao()`, depois do sorteio.
# A linha de alta tensão desce de fora do quadro por duas torres e pousa no
# PÓRTICO, no lado norte da cerca; o poste de SAÍDA, dentro dela, fica no
# `my` do primeiro poste da vila, e o ramal atravessa a rua de frente
# (*«ramal reto sobre a rua»*).
SUBESTACAO = (2.15, -1.6)
SUBESTACAO_TAM = (1.4, 1.9)        # o `brp_porto.SUBESTACAO_LARG`/`_FUNDO`
LINHA_DA_REDE = [("torre", -0.3, -8.2), ("torre", 2.2, -4.0), ("portico", 2.15, -2.45),
                 ("saida", 1.62, -1.0)]


def mobiliario_da_rua() -> list:
    """(tipo, mx, my, quadro) de cada peça do mobiliário, pela ordem: os
    postes das retas (o primeiro é o `ramal`), os das curvas e quinas, os
    PARE, as de pedestres e a de velocidade — no MEIO da calçada, que é igual
    nos dois mapas —, e por fim a subestação e a linha que lhe chega, pela
    ordem dos fios, com o `quadro` −1 de quem não muda com a obra."""
    def reta_de(my):
        for i, (my0, my1, _b) in enumerate(DEGRAUS):
            if my0 <= my < my1:
                return i
        raise ValueError("my %.2f fora da rua" % my)

    def vila(i):
        return DEGRAUS[i][2] - RUA_RECUO - CALCADA / 2.0

    def porto(i):
        return DEGRAUS[i][2] - RUA_RECUO + RUA_LARG + CALCADA / 2.0

    out = [("ramal" if k == 0 else "poste", vila(i), my, quadro_da_reta(i))
           for k, (i, my) in enumerate(POSTES_DA_RUA)]
    # A quina de fora do cotovelo `i` é um arco de raio `RAIO_COTOVELO` no
    # asfalto, e a calçada é concêntrica com ele (`136`): o meio dela corre a
    # `RAIO_COTOVELO + CALCADA/2` do mesmo centro — o arco que o
    # `caminho_da_faixa(-CALCADA/2, arcos=True)` desenha. A quina de dentro é
    # um arco de raio `RAIO_DE_DENTRO`, com o centro do lado do lote, e o meio
    # da calçada dela corre a `RAIO_DE_DENTRO - CALCADA/2`; o poste vai a meio
    # dele (−45°). Todos chegam com o cotovelo: o dia da reta SEGUINTE, que é
    # o dia em que a `obra_da_rua()` o recapeia.
    for i in QUINAS_DA_RUA:
        a = vila(i)
        y = DEGRAUS[i][1] + CALCADA / 2.0
        ca = RAIO_COTOVELO + CALCADA / 2.0
        q = quadro_da_reta(i + 1)
        for tipo, graus in ARCO_DOS_POSTES:
            ang = math.radians(graus)
            out.append((tipo, a + ca + ca * math.cos(ang), y - ca + ca * math.sin(ang), q))
        d = DEGRAUS[i + 1][2] - RUA_RECUO
        cd = RAIO_DE_DENTRO - CALCADA / 2.0
        ang = math.radians(-45.0)
        out.append(("quina", d - RAIO_DE_DENTRO + cd * math.cos(ang),
                    DEGRAUS[i][1] + RAIO_DE_DENTRO + cd * math.sin(ang), q))
    for my0, my1, _b in PIERES:
        # Do lado de `-my` da boca, que é a direita do camião que sai do
        # acesso para a rua (a conta do `(-hy, hx)`, `052`).
        my = (my0 + my1) / 2.0 - ACESSO_MEIA - ABA - FOLGA_DA_PLACA
        i = reta_de(my)
        out.append(("pare", porto(i), my, quadro_da_reta(i)))
    for i, pmy in _zebras():
        out.append(("pedestres", vila(i), pmy + AVISO_DA_ZEBRA, quadro_da_reta(i)))
    for i, my in VELOCIDADE_DA_RUA:
        out.append(("velocidade", porto(i), my, quadro_da_reta(i)))
    out.append(("subestacao", SUBESTACAO[0], SUBESTACAO[1], -1))
    out += [(t, mx, my, -1) for t, mx, my in LINHA_DA_REDE]
    return [(t, round(mx, 3), round(my, 3), q) for t, mx, my, q in out]


# ── A FIAÇÃO ATRÁS DA VILA (quarta passagem da `140`) ──────────────────────
#
# *«Tem fio passando por cima de construções, como a igreja»*. O fio da curva
# do segundo cotovelo corre pela calçada da vila ao longo dele, e o lote da
# esquina — a igreja — fica-lhe À FRENTE (`lote_a_frente`): a torre sobe na
# tela por cima da altura do fio. Só que a vila é o MAPA, um fundo chapado, e
# a fiação desenha-se por cima dele inteira. Pôr os postes noutro sítio não
# chega (a rede vira com a rua, e a torre está na esquina); o jogo esconde o
# fio onde o lote à frente o tapa, pelo contorno do lote, que é o que a mata
# do morro já lê (`pecas_da_vila`, `130`).
#
# Os tipos que são poste: os da linha, pela ordem da tabela, e depois os da
# rua pela ordem de `my`, cada um ligado ao seguinte — como no jogo
# (`cadeia_dos_postes()`): o de saída da subestação liga-se ao `ramal`.
POSTES_DA_LINHA = ("torre", "portico", "saida")
POSTES_DA_FIACAO = ("ramal", "poste", "curva_a", "curva_b", "quina")
# O topo do isolador acima do chão, em px de DESENHO: o `POSTE_ISOLADOR` do
# `brp_porto.py`, que o `ObraNoMapa.gd` também copia.
ALTURA_DO_FIO = 50.0
# Quanto o fio pode descer abaixo da reta dos topos, em px de tela: a barriga
# do velho (4,5), o tombo e a altura do isolador da ponta. Vão cujo lote à
# frente não chegue a esta distância do fio não é publicado.
FOLGA_DO_FIO = 12.0
# Colunas a mais de cada lado do vão: os dois fios correm a ±7 px da reta dos
# pés, nos isoladores das pontas da cruzeta.
LADO_DO_FIO = 8


def fiacao_atras_da_vila() -> list:
    """(a, b, x0, teto) de cada vão da fiação que passa atrás de um lote da
    vila: os índices dos dois postes no `mobiliario_da_rua()`, a primeira
    coluna de TELA e, por coluna, o `y` de cima do que lhe fica à frente —
    `SAIDA` onde nada fica. O ponto do chão de cada coluna é o da reta entre
    os pés dos dois postes nessa coluna (as pontas, fora dela), e à frente
    dele estão os lotes que o `lote_a_frente` diz. O D45 refaz a conta pelos
    `pecas_da_vila` da tabela, e confere o fio desenhado contra ela."""
    mob = mobiliario_da_rua()
    ids = [i for i, m in enumerate(mob) if m[0] in POSTES_DA_LINHA] + sorted(
        (i for i, m in enumerate(mob) if m[0] in POSTES_DA_FIACAO), key=lambda i: mob[i][2])
    pecas = pecas_da_vila()
    out = []
    for a, b in zip(ids, ids[1:]):
        (ax, ay), (bx, by) = mob[a][1:3], mob[b][1:3]
        xa = tela(ax, ay)[0]
        xb = tela(bx, by)[0]
        x0 = int(math.floor(min(xa, xb))) - LADO_DO_FIO
        x1 = int(math.ceil(max(xa, xb))) + LADO_DO_FIO
        teto = []
        perto = False
        for c in range(x0, x1 + 1):
            # O vão a 45° no chão (a corda entre os dois postes da curva) é
            # VERTICAL na tela: todas as colunas são a do meio dele.
            f = min(1.0, max(0.0, (c - xa) / (xb - xa))) if abs(xb - xa) >= 1.0 else 0.5
            mx, my = ax + (bx - ax) * f, ay + (by - ay) * f
            y_fio = tela(mx, my, ALT_CAIS + ALTURA_DO_FIO)[1]
            t = float(SAIDA)
            for caixa, cols in pecas:
                if c in cols and lote_a_frente(caixa, mx, my):
                    t = min(t, cols[c])
            teto.append(t)
            perto = perto or t < y_fio + FOLGA_DO_FIO
        if perto:
            out.append((a, b, x0, teto))
    return out


# ── O MOBILIÁRIO ATRÁS DA VILA (quinta passagem da `140`) ────────────────
#
# *«Veja as sombras dos postes, pois parecem estar sobrepondo edifícios, como
# a igreja»*. É a regra da fiação um andar abaixo: o PNG do poste traz a
# sombra de contacto, que desce para a direita do pé, e nos dois postes da
# curva de fora dos cotovelos 2 e 3 ela cai na tela onde o lote da esquina —
# a igreja, no 2 — lhe fica à frente; o mapa é chapado e o poste pinta-se por
# cima (medido: 124 e 38 px no 2, 94 e 16 no 3, todos de sombra). O jogo
# esconde, com um shader, o que da peça fica abaixo do topo do lote à frente
# em cada coluna (`ui/shaders/vila_a_frente.gdshader`).
#
# Colunas de tela de cada lado do pé (a caixa da subestação, a maior peça,
# vai a ±37), e o que a sombra desce abaixo dele, em px de tela.
MASCARA_LADO = 40
MASCARA_ABAIXO = 10.0


def mascara_da_vila() -> list:
    """(índice, x0, teto) de cada peça do `mobiliario_da_rua()` com um lote
    da vila à frente do PÉ dela que chega à caixa dela na tela: o `y` de cima
    do lote por coluna, de `x0` a `x0 + 2·MASCARA_LADO` (`SAIDA` onde nada
    fica à frente). A conta da `fiacao_atras_da_vila()`, com o ponto do pé."""
    out = []
    for k, (_t, mx, my, _q) in enumerate(mobiliario_da_rua()):
        m = _mascara_do_pe(mx, my)
        if m is not None:
            out.append((k,) + m)
    return out


def _mascara_do_pe(mx: float, my: float):
    """`(x0, teto)` de uma peça com o pé em (mx, my): o `y` de cima dos lotes
    da vila que lhe ficam à frente, coluna a coluna, de `x0` a
    `x0 + 2·MASCARA_LADO` — ou `None` se nenhum chega à caixa dela."""
    pecas = pecas_da_vila()
    x, y = tela(mx, my, ALT_CAIS)
    # ⚠️ O MEIO ARREDONDA-SE PARA CIMA, COMO NO GODOT (`141`): o `round()`
    # do Python leva 168,5 ao PAR (168) e o `roundi()` do jogo e do D50 a 169,
    # e a máscara do carro com o pé nessa coluna saía um pixel ao lado.
    x0 = int(math.floor(x + 0.5)) - MASCARA_LADO
    teto = []
    for c in range(x0, x0 + 2 * MASCARA_LADO + 1):
        v = float(SAIDA)
        for caixa, cols in pecas:
            if c in cols and lote_a_frente(caixa, mx, my):
                v = min(v, cols[c])
        teto.append(v)
    return (x0, teto) if min(teto) < y + MASCARA_ABAIXO else None


# ── OS CARROS DA VIELA (`141`) ───────────────────────────────────────────
#
# *«Os carros estacionados»* que a `140` deixou de fora. Medido antes do
# escopo: na rua não cabem — entre o camião e o meio-fio sobram 0,18, e um
# carro tem ~0,3 —, e o Bruno pô-los na VIELA DE TERRA (`viela_da_vila()`),
# com a rua do porto a ser rodovia: nenhum carro nela.
#
# ⚠️ A VIELA ESTÁ QUASE TODA ATRÁS DA FILEIRA DA FRENTE. Varrida a cada 0,1
# em `my`, dos dois lados, a fração de um carro que se vê (os lotes à frente
# e o topo do mapa, debaixo do HUD): a do degrau 1 vê-se de −3,3 a 6,6 do
# lado das casas de trás, onde o vão do escritório tirou a fileira da
# frente; a do 2 só de 8,5 a 9,1 e de 12,7 a 14,7; a do 3 de 16,5 a 19,4; a
# do 4 quase nada. Os sítios abaixo estão todos acima de 80%, e a máscara
# da vila esconde o resto, como ao poste (`mascara_dos_carros()`).
#
# `(prop, degrau, lado, my, fase, obras)`: o carro aparece desde a `fase`,
# com `obras` reparos DESSA fase já prontos (os da Fase 1 são os três da
# tabela dela, os da Fase 2 os que ela acrescenta) — escolha do Bruno: o
# número cresce com a fase e com as obras do porto, e os da Fase 2 são os
# novos. O `lado` é a margem da viela: `tras` junto às casas de trás.
CARROS_DA_VIELA = (
    ("carro_fusca_velho", 1, "tras", 1.2, 1, 0),
    ("carro_kombi_velha", 2, "tras", 13.6, 1, 0),
    ("carro_fusca_velho_b", 1, "tras", 2.5, 1, 0),
    ("carro_picape_velha", 3, "tras", 17.6, 1, 1),
    ("carro_hatch_velho", 1, "tras", 4.6, 1, 2),
    ("carro_hatch_velho_b", 2, "tras", 8.8, 1, 3),
    ("carro_hatch_novo", 1, "frente", 0.2, 2, 0),
    ("carro_picape_nova", 1, "tras", 6.0, 2, 1),
    ("carro_hatch_novo_b", 2, "frente", 14.2, 2, 2),
    ("carro_hatch_novo_c", 3, "tras", 18.9, 2, 3),
    # As motos voltaram na terceira passagem, do lado das casas da frente,
    # nos trechos da viela que se veem (`_moto` no `brp_porto.py`).
    ("carro_moto_velha", 1, "frente", 1.6, 1, 0),
    ("carro_moto_nova", 2, "frente", 8.9, 2, 0),
    # E mais duas na quarta passagem (*«mais motos»*).
    ("carro_moto_velha_b", 3, "tras", 16.75, 1, 2),
    ("carro_moto_nova_b", 1, "frente", 2.7, 2, 2),
)
# A meia largura do carro mais largo (a kombi, 0,31 × a `ESCALA_CARRO` de
# 1,25 do `brp_porto.py`) e a folga dele à borda da terra batida.
CARRO_MEIA_LARG = 0.195
CARRO_FOLGA = 0.06


def faixa_da_viela(i: int) -> tuple:
    """`(mx0, mx1)` da viela de terra do degrau `i`."""
    borda = DEGRAUS[i][2]
    return borda - VILA_RECUO_2 + VILA_PROF + 0.12, borda - VILA_RECUO - 0.12


def carros_da_viela() -> list:
    """`(prop, mx, my, fase, obras)` de cada carro, com o `mx` da margem da
    viela que o `lado` pede."""
    out = []
    for prop, i, lado, my, fase, obras in CARROS_DA_VIELA:
        mx0, mx1 = faixa_da_viela(i)
        d = CARRO_FOLGA + CARRO_MEIA_LARG
        mx = mx0 + d if lado == "tras" else mx1 - d
        out.append((prop, round(mx, 3), my, fase, obras))
    return out


def mascara_dos_carros() -> list:
    """`(índice, x0, teto)` de cada carro com um lote da vila à frente dele
    que chega à caixa dele na tela: a conta da `mascara_da_vila()`."""
    out = []
    for k, (_p, mx, my, _f, _o) in enumerate(carros_da_viela()):
        m = _mascara_do_pe(mx, my)
        if m is not None:
            out.append((k,) + m)
    return out


# ── A VILA QUE CRESCE ────────────────────────────────────────────────────
# O porto não fica sozinho na paisagem: a cidade nasce atrás dele. Cada casa
# tem um NÍVEL, e é só ele que muda entre as Fases — 1 é casa térrea de telha
# de barro, 2 é sobrado, 3 é prédio. Subir a Fase é passar `--nivel-vila=2`
# ao gerador e regerar os dois mapas; nada no jogo precisa saber disso.
#
# Por que assado no SVG e não como prop: prop é para o que troca de estado
# DENTRO de uma partida (píer, armazém, escritório). A vila troca entre
# Fases, que é fronteira de conteúdo e não de turno — e assar poupa vinte nós
# permanentemente visíveis que nunca seriam tocados.
#
# POR QUE `casa()` E NÃO `predio()`. A primeira versão reusou o prédio do
# pátio e as casas saíram como LAJES LARANJA deitadas no chão: o beiral de
# 0,3 e o telhado de 8px do prédio são desenhados para um galpão de 4,4
# unidades, e numa casa de 1,35 o telhado engolia a parede inteira. Numa casa
# o que se tem de ver é a PAREDE — é ela que diz que aquilo tem gente dentro.

# Por nível: (altura da parede em px do mapa, telha, linhas de janela).
VILA_NIVEIS = {
    1: [(20, "telha_a", 1), (18, "telha_b", 1), (22, "telha_d", 1)],
    2: [(34, "telha_a", 2), (31, "telha_b", 2), (37, "telha_d", 2)],
    3: [(56, "telha_c", 3), (48, "telha_c", 3), (64, "telha_c", 3)],
}
# ⚠️ A COR DA PAREDE DEIXOU DE SER A VARIANTE (`123`). Até 17/10 a variante
# escolhia altura, telha E parede, e a vila tinha três casas e só três. Os
# pastéis novos não podiam entrar no mesmo sorteio: o `randrange(3)` da
# variante vive no `Random` que põe cada lote no sítio, e um quarto valor
# mudaria a sequência e mexeria a vila inteira. A parede sai de um `Random`
# próprio, em `paredes_da_vila()`, e a geminada continua a herdar a da vizinha.
VILA_PAREDES = ["casa_a", "casa_b", "casa_c", "casa_d", "casa_e", "casa_f"]

# ── ONDE NÃO CABE CASA: os vãos que os prédios do pátio obrigam a abrir ──
#
# O escritório e o armazém são props do CENÁRIO, postos em `Main.tscn`, e o
# gerador do mapa não sabe deles. O resultado era o que se via na captura de
# 31/08: os dois pousados em cima da fileira de casas, com um telhado de casa a
# sair por baixo de cada um. Não é erro de profundidade — a ordem está certa —,
# é que ali havia duas construções no mesmo lugar.
#
# ⚠️ ATÉ 04/09 ISTO ERAM DOIS INTERVALOS ESCRITOS À MÃO, e o comentário que
# eles carregavam avisava, com todas as letras, que envelheciam calados: "os
# dois termos da conta mudaram em 03/09... quem mexer só num dos lados deixa o
# vão no sítio antigo — e um vão no sítio errado não dá erro: dá uma casa
# fatiada por um telhado e um buraco na fileira a seis unidades dali."
#
# Um comentário que descreve como a constante ao lado apodrece é um pedido para
# a constante deixar de existir. Agora ela é DERIVADA, por `vaos_da_vila()`, e
# a conta que estava escrita em prosa está escrita em código.
#
# A CONTA, porque ela não é óbvia: a casa que um prédio tapa NÃO está no `my`
# dele. As duas coisas vivem em `mx` diferentes — a vila lá atrás, o prédio no
# pátio —, e na projeção quem decide a coluna da tela é `mx - my`. Igualando:
#
#     my_casa = mx_vila - (mx_predio - my_predio)
#
# ⚠️ E A COLUNA DA TELA NÃO CHEGA, o que a versão escrita à mão escondia por
# ter uma linha por prédio. Medido em 04/09: o armazém, em (6,6 / 14,5), cai na
# MESMA coluna que a vila do degrau 0 em my=5,4 — e não tapa casa nenhuma lá,
# porque está 273px abaixo na tela e o sprite dele tem 185. Derivar só pela
# coluna abriria um vão a mais, num sítio onde não há nada a esconder. É por
# isso que a altura do sprite entra na conta: um prédio tapa para CIMA, e só
# até onde ele chega.

# (nome, mx, my, sprite em px) de cada prédio do pátio, lido de `Main.tscn`.
# A largura manda no vão em `my`; a altura manda em QUAL fileira ele alcança.
# (nome, mx, my, largura do sprite em PIXEL DO PNG). A largura é a do estado
# MAIOR de cada prédio — o escritório pronto tem 103px e a ruína 82; o armazém
# 124 nos dois estados —, porque o vão tem de servir aos dois.
#
# ⚠️ ELA ENCOLHEU COM A CÂMERA em 05/09 (era 154 e 185). É pixel de PNG, e o
# PNG passou a ser renderizado 1,5x menor; deixar os números antigos abriria
# na vila um vão meia casa maior do que o prédio precisa, sem erro nenhum a
# apontá-lo — só um buraco na fileira.
# ⚠️ A POSIÇÃO JÁ NÃO SE COPIA — DERIVA-SE DA CENA (07/09), e a correção veio
# do defeito que a cópia à mão tinha deixado passar. O comentário acima dizia
# "lido de `Main.tscn`" e ele NÃO era lido: era copiado. Medido em 06/09,
# desprojetando os nós da cena com esta mesma projeção e pousando-os a
# `ALT_CAIS`, como manda o contrato, o `mx` batia exato e o `my` estava 1,10 e
# 1,05 unidades ADIANTADO — o vão da vila abria ~21 px ao lado do prédio que ele
# existe para desocupar, meia casa fora do sítio. E o D14 não pegava, porque lê
# esta constante, que era a mesma fonte do defeito: um teste que monta o
# esperado de onde o defeito mora é um espelho.
#
# ⚠️ E O `round(..., 3)` NÃO É COSMÉTICO. Estes números entram em toda
# coordenada da vila, e a saída do gerador é comparada BYTE A BYTE pelo CI: um
# `my` que saia de duas divisões e chegue com 1e-14 de resíduo desloca meio
# pixel na impressão a `%.1f` e reprova a corrida numa versão de Python e não
# noutra. É a mesma regra do `_camera()`, aplicada à outra entrada.
PREDIOS_DO_PATIO_SPRITE = (
    # (nome do nó em `Main.tscn`, largura do sprite em PIXEL DO PNG)
    ("Escritorio", 103.0),
    ("Armazem", 124.0),
)

# O quadro de todo prop isométrico tem 512 e o centro dele é a origem do mundo.
MEIO_QUADRO = 256.0
CENA_PRINCIPAL = pathlib.Path(__file__).resolve().parent.parent \
    / "brport_vs" / "scenes" / "Main.tscn"


def _predios_do_patio() -> list:
    """(nome, mx, my, largura do sprite) de cada prédio do pátio, LIDO da cena.

    O prédio está onde o `Main.tscn` o põe, e o vão da vila tem de estar onde o
    prédio está. Ler daqui é o que faz mover um prédio na cena mover o vão
    junto — e é o que impede a constante de apodrecer calada, que é a regra
    deste arquivo.

    Falta um nó? REBENTA. Um prédio do pátio que a cena deixe de ter não pode
    virar um vão silenciosamente ausente na vila.
    """
    texto = CENA_PRINCIPAL.read_text("utf-8")
    saida = []
    for nome, largura in PREDIOS_DO_PATIO_SPRITE:
        bloco = re.search(
            r'\[node name="%s" type="\w+" parent="MapaWrap/Cenario"\]'
            r'(.*?)(?=\n\[node |\Z)' % nome, texto, re.S)
        if bloco is None:
            raise SystemExit("gerar_mapa_iso: %s não está em %s"
                             % (nome, CENA_PRINCIPAL))
        esq = float(re.search(r"offset_left = (-?[\d.]+)", bloco.group(1)).group(1))
        topo = float(re.search(r"offset_top = (-?[\d.]+)", bloco.group(1)).group(1))
        # O inverso de `tela(mx, my, ALT_CAIS)`. A altura entra: quem está em
        # terra pousa a `ALT_CAIS`, e desprojetar a 0 desloca o prédio +0,87 em
        # mx E em my — pouco para se notar, e suficiente para mudar o degrau.
        u = ((esq + MEIO_QUADRO) / ZOOM - CX) / MEIA_LARG
        v = ((topo + MEIO_QUADRO) / ZOOM - CY + ALT_CAIS) / MEIA_ALT
        saida.append((nome, round((u + v) / 2.0, 3), round((v - u) / 2.0, 3),
                      largura))
    return saida


PREDIOS_DO_PATIO = _predios_do_patio()


def vaos_da_vila(recuo: float = None) -> list:
    """Os intervalos de `my` onde não se põe casa, um por prédio do pátio.

    O raio é ~0,6 da meia-largura do sprite: tapar tudo o que a silhueta
    alcança abriria um vão de sete unidades e deixaria um buraco na fileira. O
    que incomoda é a casa FATIADA pela quina, não a que espreita atrás.

    `recuo` é o da fileira que se está a povoar: a fileira de trás está noutro
    `mx`, logo o prédio tapa nela um `my` DIFERENTE. Passar o vão da fileira
    da frente para a de trás abriria o buraco no sítio errado — que é o mesmo
    defeito que esta função existe para não repetir.
    """
    if recuo is None:
        recuo = VILA_RECUO
    vaos = []
    for _nome, pmx, pmy, sprite in PREDIOS_DO_PATIO:
        # ⚠️ O SPRITE É PIXEL DE TELA E O `p()` DEVOLVE PIXEL DE DESENHO, que
        # desde 05/09 são coisas diferentes (ver o bloco do enquadramento).
        # Misturar os dois daria um vão 1,5x maior do que devia — e um vão
        # errado não dá erro, dá buraco na fileira de casas.
        # ⚠️ E LEVA A MARGEM DO PONTO DE REFERÊNCIA, que faltava.
        #
        # O `0,6` da meia-largura dá exatamente o mesmo número que o `0,30` da
        # largura com que o D14 mede — zero de folga entre os dois. Só que eles
        # NÃO MEDEM DO MESMO SÍTIO: aqui o `centro` sai do canto do lote
        # (`borda - recuo`), e o teste mede do CENTRO da casa, que está
        # `(dmx - dmy) / 2` ao lado. Com `dmy` sorteado entre 0,72 e 1,28, essa
        # diferença chega a 0,315 unidades — e uma casa cujo CENTRO cai dentro
        # do limiar do teste, mas cujo CANTO cai fora do meu, escapa ao vão e
        # aparece fatiada pelo prédio. Foi o que o D14 apanhou em 07/09, e só
        # depois de os prédios se mexerem: até aí nenhuma casa calhava naquela
        # fatia de 6 px.
        meia = 0.6 * (sprite / 2.0) / (MEIA_LARG * ZOOM) + (VILA_PROF - 0.72) / 2.0
        _, py = tela(pmx, pmy, ALT_CAIS)
        for my0, my1, borda in DEGRAUS:
            mx_vila = borda - recuo
            centro = mx_vila - (pmx - pmy)
            # ⚠️ O QUE INTERESSA É O VÃO SE ENCOSTAR AO DEGRAU, não o centro
            # dele cair lá dentro. A versão anterior exigia `my0 <= centro <
            # my1` e por isso perdia o degrau VIZINHO: a silhueta do armazém
            # tem 109 px e alcança casas a 33 px da coluna dele, que num
            # degrau ao lado ficam a menos de meia unidade de `my` — mas o
            # centro exato cai fora da faixa, e nenhum vão se abria. Só se viu
            # em 07/09, quando a rua alargou e os dois prédios tiveram de
            # andar: o D14 apanhou uma casa que o armazém tapava e que a
            # fileira não tinha aberto. Interseção de intervalos, como sempre.
            if centro + meia <= my0 or centro - meia >= my1:
                continue
            # O prédio tapa para CIMA, e só até à altura do sprite dele. A
            # altura mede-se DENTRO do degrau, no meio do pedaço de vão que
            # cai nele — medi-la no `centro` seria medi-la num `my` que este
            # degrau não tem.
            meio_no_degrau = min(max(centro, my0), my1)
            _, hy = tela(mx_vila, meio_no_degrau, ALT_CAIS)
            if 0.0 <= py - hy <= sprite:
                vaos.append((centro - meia, centro + meia))
    return vaos


# ── PEGADAS: quanto CHÃO um prop ocupa, e não onde a âncora dele caiu ────
#
# Existe por causa do defeito de 02/09. O bloco D2 do teste de design conferia
# a âncora — um ponto — e a âncora dos dois prédios estava no pátio, certinha.
# O que estava fora era a PEGADA: o armazém ocupa 3,86 em `mx` e o pátio tinha
# 1,68, então 0,70 dele ficavam no asfalto e 0,08 sobre a água. Ponto nenhum
# pega isso, por mais bem posto que esteja.
#
# Os números saem das literais de `tools/gerar_props_iso.py` (`ESC` e `GAL`),
# mais o beiral de 0,18 que `telhado_duas_aguas()` acrescenta de cada lado —
# é o telhado que manda, porque é ele o mais largo:
#
#     escritório  parede 2,4 × 2,0  →  telhado 2,76 × 2,36
#     armazém     parede 3,4 × 2,4  →  telhado 3,76 × 2,76
#
# ⚠️ E NO ARMAZÉM O TELHADO DEIXOU DE MANDAR (05/09). Ele ganhou uma
# PLATAFORMA DE CARGA na face `+x`, e a testa dela — deck, tampo e defensas
# de borracha — chega a `x = 2,16` contra os 1,88 do beiral. Quem responde
# pela pegada em `mx` é a plataforma: 4,32 (2 × 2,16) em vez de 3,76. Em `my`
# nada mudou, porque tudo o que sai na face `-y` (calha, tambor, defensas)
# para dentro dos 1,38 do beiral.
#
# É exatamente o defeito de 02/09 outra vez, e por isso está escrito aqui em
# vez de descoberto na captura: peça nova que avança o CHÃO do prop avança a
# pegada, e a âncora — que é um ponto — não sabe disso. Com 4,32 sobram 0,52
# unidades até o asfalto e 0,54 até o avental; foi por esses números que o
# deck foi para `+x` e não para `-y`, onde a folga até o cotovelo da rua é de
# 0,236 e o mesmo deck exigiria 3,46 em `my` — pegada que o D2 REPROVA, e que
# foi injetada de propósito para o provar.
#
# ⚠️ E MULTIPLICADOS POR `ESCALA_PREDIO`, que em 03/09 passou a 0,72. Os dois
# prédios encolheram porque o playtest os leu como "muito grandes, e em cima
# da estrada": a base estava legal, mas o armazém ocupava 90% da largura do
# pátio e os dois levantavam-se 4x a altura de uma casa — em isométrico é a
# altura que derrama a silhueta por cima do que está atrás. Quem mexer naquela
# escala mexe NESTES quatro números, e o gerador de props é que a define.
#
# Estão escritos à mão porque `gerar_props_iso.py` precisa do `bpy` para dizer
# o mesmo, e um teste que exija 1 GB de Blender não roda no CI nem numa sessão
# normal. O preço é este: quem mexer na geometria de um prédio mexe aqui.
# O teste fecha o resto do cerco — um prop do cenário cuja silhueta passe de
# 130px sem pegada declarada REPROVA, para que um prédio novo não escape.
ESCALA_PREDIO = 0.72                    # espelha `gerar_props_iso.ESCALA_PREDIO`
PEGADAS = {
    "escritorio": (2.76 * ESCALA_PREDIO, 2.36 * ESCALA_PREDIO),
    # A ruína é menor, e é medida pelo que ela VAI SER: o vão que ela ocupa tem
    # de caber o prédio consertado, senão consertar empurraria o prop para cima
    # do asfalto e o teste só reprovaria depois da compra.
    "escritorio_ruina": (2.76 * ESCALA_PREDIO, 2.36 * ESCALA_PREDIO),
    "galpao": (4.32 * ESCALA_PREDIO, 2.76 * ESCALA_PREDIO),
    # A ruína ainda não tem plataforma — mas responde pela do prédio
    # consertado, pela mesma razão que a do escritório: o vão que ela ocupa
    # tem de caber o que vai nascer ali.
    "galpao_velho": (4.32 * ESCALA_PREDIO, 2.76 * ESCALA_PREDIO),
}


# ── A RECEITA DO VOLUME PEQUENO: polígono irregular + saia ───────────────
#
# Saiu do enrocamento, onde foi descoberta em 03/09, e está aqui com nome
# próprio porque a copa de árvore precisava exatamente dela. As duas formas
# que o enrocamento tentou antes são as MESMAS que a copa tinha:
#
#   · elipse extrudada (tampo do tamanho da base) → ficha de pôquer;
#   · elipse com uma cópia menor deslocada para cima → elipse chapada com
#     sombra, que é o defeito de origem outra vez.
#
# O que faz um volume pequeno ler como volume é ARESTA: contorno quebrado e
# duas faces de tons diferentes, como em toda a outra peça deste mapa.
def com_saia(canto: list, h: float, topo: str) -> str:
    """Tampo irregular com uma saia por aresta virada para BAIXO na tela.

    As arestas de cima não levam saia: ficam por trás do tampo, e desenhá-las
    é pintar por baixo de quem vai tapar. A face virada para a direita é a
    mais escura, seguindo a mesma luz de `madeira_esq` / `madeira_dir`.
    """
    s = ""
    n = len(canto)
    for k in range(n):
        a, b = canto[k], canto[(k + 1) % n]
        ex, ey = b[0] - a[0], b[1] - a[1]
        nx, ny = ey, -ex
        if ny <= 0.0:
            continue
        tom = _sombrear(topo, 0.62 if nx > 0.0 else 0.76)
        s += ('  <polygon points="%.1f,%.1f %.1f,%.1f %.1f,%.1f %.1f,%.1f" '
              'fill="%s"/>\n'
              % (a[0], a[1], b[0], b[1], b[0], b[1] + h, a[0], a[1] + h, tom))
    return s + ('  <polygon points="%s" fill="%s"/>\n'
                % (" ".join("%.1f,%.1f" % c for c in canto), topo))


def _lobo(px: float, py: float, rx: float, ry: float, r: random.Random) -> list:
    """Um contorno de 6 ou 7 vértices com raio e ângulo sacudidos.

    Polígono REGULAR sai cristal, e a esta escala um cristal lê-se como erro
    de desenho — a mesma razão pela qual as pedras do enrocamento não são
    hexágonos certinhos.
    """
    n = r.choice((6, 7))
    a0 = r.uniform(0.0, math.tau)
    canto = []
    for k in range(n):
        a = a0 + math.tau * k / n + r.uniform(-0.22, 0.22)
        f = r.uniform(0.76, 1.0)
        canto.append((px + math.cos(a) * rx * f, py + math.sin(a) * ry * f))
    return canto


# TUDO AQUI SAI DO CONTORNO (`costa_deslocada`), e nunca da `borda` de um
# degrau. A rampa tem de virar a esquina da escada junto com a costa; medida
# por degrau, ela partia-se em duas com um degrau de terra a pique no meio.


def contorno_recuado(d: float) -> list:
    """O contorno da costa recuado `d` para DENTRO da terra.

    ⚠️ NÃO É O `costa_deslocada` COM O SINAL TROCADO, e a diferença custou uma
    rodada inteira. Aquele empurra cada VÉRTICE na diagonal (+d em mx, -d em
    my), o que serve perfeitamente para uma faixa de água; mas ao longo de um
    muro isso desloca também o `my`, e a crista da praia saía 1,3 unidade
    adiantada em relação à linha de água. No fim do cais aquilo abriu um
    TRIÂNGULO DE ÁGUA FUNDA entre o muro e a duna — água a nascer no meio da
    terra, e a captura mostrou-a como uma cunha azul-escura.

    Aqui cada segmento recua pela sua PRÓPRIA normal, e cada quina leva o
    remate que pede: onde a terra abraça a quina (o degrau que sobe) entram
    DOIS pontos, um chanfro, porque a praia dá a volta por fora; onde ela é
    uma ponta de terra entra UM, o cruzamento das duas linhas recuadas, senão
    o recuo passava para lá da própria costa.
    """
    v = contorno_costa()
    seg = []
    for i in range(len(v) - 1):
        (x0, y0), (x1, y1) = v[i], v[i + 1]
        if abs(x1 - x0) < 1e-9:                       # muro: a terra é -mx
            seg.append(((x0 - d, y0), (x1 - d, y1), True))
        else:                                          # espelho: a terra é +my
            seg.append(((x0, y0 + d), (x1, y1 + d), False))
    out = [seg[0][0]]
    for i, (_a, b, muro) in enumerate(seg):
        if i + 1 == len(seg):
            out.append(b)
            break
        c = seg[i + 1][0]
        quina = v[i + 1]
        if muro:
            out.append((b[0], quina[1]))
            out.append((quina[0], c[1]))
        else:
            out.append((c[0], b[1]))
    return out


def _meandro(my: float, fase: float) -> float:
    """Uma serpentina lenta ao longo da costa, entre -1 e 1.

    ⚠️ A PRIMEIRA VERSÃO SACUDIA CADA AMOSTRA e não serpenteava nada: era
    ruído de 11 px de período e, na tela, as três faixas da rampa saíam como
    três FITAS paralelas de largura constante — o defeito que a rampa em três
    tons existe para evitar. O que o olho lê como orla é meandro LONGO; duas
    senóides de períodos diferentes bastam, e continuam reproduzíveis sem
    semente nenhuma.
    """
    return 0.62 * math.sin(my * 0.83 + fase) + 0.38 * math.sin(my * 2.1 + fase * 1.7)


def linha_da_praia(t0: float, amp: float, fase: float, my_a: float,
                   my_b: float, passo: float = 0.30) -> list:
    """Uma das linhas da rampa, já em pixels e já recortada ao trecho.

    `t0 = 0` é a crista (recuada `PRAIA_PROF`, à altura do cais); `t0 = 1` é a
    linha de água, à altura zero. A rampa é reta entre as duas, então o recuo
    e a altura andam sempre juntos — inclusive na ondulação, senão a linha
    serpenteia no chão e fica reta no ar.

    ⚠️ E O `amp` DEIXOU DE SALTAR A QUINA. Ele sacudia muro e espelho e punha
    `desvio = 0` no chanfro, porque torcer o chanfro desmanchava a volta que a
    praia dava ao degrau. Com a costa desenhada pela família concêntrica isso
    deixou de ser preciso: a volta é um ARCO, e empurrá-lo para dentro ou para
    fora é só mudar o raio dele — quem faz essa conta é o `ponto_costeiro`, e
    a linha continua fechada.
    """
    return [p(mx, my, ALT_CAIS * q)
            for mx, my, q in _pontos_da_praia(t0, amp, fase, my_a, my_b, passo)]


def _pontos_da_praia(t0: float, amp: float, fase: float, my_a: float,
                     my_b: float, passo: float = 0.30) -> list:
    """A mesma linha em (mx, my, q) do MUNDO — `q` é a fração da altura do cais.

    O chão da restinga mede a distância de cada pixel à crista (`127`), e essa
    conta faz-se no mundo: na tela o isométrico estica a direção (1, −1) e
    comprime a (1, 1), e a mesma distância daria dois números.
    """
    recuo = PRAIA_PROF * (1.0 - t0)
    v, comp, _arco, _q = _geometria_da_costa()
    pontos = []
    for i in range(len(v) - 1):
        (x0, y0), (x1, y1) = v[i], v[i + 1]
        n = max(1, int(comp[i] / passo))
        for k in range(n + 1):
            f = k / n
            base_my = math.fsum((y0, (y1 - y0) * f))
            desvio = PRAIA_PROF * amp * _meandro(base_my, fase) if amp else 0.0
            mx, my, _n, _t = ponto_costeiro(i, f, -math.fsum((recuo, desvio)))
            pontos.append((mx, my, math.fsum((recuo, desvio)) / PRAIA_PROF))
    return _corta_em_my(pontos, my_a, my_b)


def _faixa_da_rampa(a: tuple, b: tuple, my_a: float, my_b: float, cor: str,
                    opac: float = 1.0) -> str:
    """Uma faixa da rampa entre duas linhas, cada uma (t0, amplitude, fase)."""
    perto = linha_da_praia(*a, my_a, my_b)
    longe = linha_da_praia(*b, my_a, my_b)
    if len(perto) < 2 or len(longe) < 2:
        return ""
    return poli(perto + list(reversed(longe)), cor, opac)


def _linha_rampa_continua(indice: int, t: float, my_a: float,
                          my_b: float) -> list:
    """Interpola crista, lavado e água sem criar fronteira de cor."""
    t_lavado, amp_lavado, fase_lavado = LAVADO[indice]
    if t <= t_lavado:
        f = t / t_lavado
        amp = math.fsum((CRISTA[indice][1] * (1.0 - f), amp_lavado * f))
        fase = math.fsum((CRISTA[indice][2] * (1.0 - f), fase_lavado * f))
    else:
        f = (t - t_lavado) / (1.0 - t_lavado)
        amp = amp_lavado * (1.0 - f)
        fase = fase_lavado
    return linha_da_praia(round(t, 8), round(amp, 8), round(fase, 8),
                          my_a, my_b)


def _rampa_degrade(indice: int, my_a: float, my_b: float) -> str:
    """Areia seca e pé molhado em polígonos opacos e aninhados."""
    crista = linha_da_praia(*CRISTA[indice], my_a, my_b)
    n = _passos_de_um_pixel(PRAIA_PROF)
    s = ""
    for i in range(n, 0, -1):
        t = round(i / n, 8)
        longe = _linha_rampa_continua(indice, t, my_a, my_b)
        if len(crista) < 2 or len(longe) < 2:
            continue
        s += poli(crista + list(reversed(longe)),
                  _misturar_cor(C["areia"], C["areia_face"], t))
    return s


def _baixio_de_areia(indice: int, my_a: float, my_b: float) -> str:
    """Areia vista pela água, escolhida por VALOR e dissolvida no baixio.

    Antes eram duas chapas sobrepostas, a larga a 0,30 e a curta a 0,90. A
    mesma cobertura agora é uma rampa de opacidade: clara junto à linha de
    água e transparente antes de chegar à água rasa. Não há mistura da cor da
    areia com a água — `areia_funda` continua sendo o tom claro, pouco
    saturado, medido para não sumir contra o baixio.
    """
    alcance = round(PRAIA_SUBMERSA * 1.9, 6)
    costa_px = [p(mx, my) for mx, my in
                _corta_em_my(linha_costeira(0.0), my_a, my_b)]
    n = _passos_de_um_pixel(alcance)
    acumulada = 0.0
    s = ""
    for i in range(n, 0, -1):
        d = round(alcance * i / n, 6)
        longe = [p(mx, my) for mx, my in
                 _corta_em_my(linha_costeira(d), my_a, my_b)]
        if len(costa_px) < 2 or len(longe) < 2:
            continue
        alvo = 0.90 * (1.0 - d / alcance)
        alvo = max(acumulada, alvo)
        camada = (alvo - acumulada) / max(1e-9, 1.0 - acumulada)
        s += poli(costa_px + list(reversed(longe)), C["areia_funda"],
                  round(camada, 4))
        acumulada = alvo
    return s


# As três linhas de cada ponta, num lugar só: o chão (`praia_chao`) e a areia
# (`praia_areia`) desenham a partir da CRISTA, e se as duas divergissem sairia
# uma fresta entre o relvado e a duna. As fases mudam de uma ponta para a
# outra para as duas praias não saírem com o mesmo meandro.
CRISTA = [(0.0, 0.16, 0.4), (0.0, 0.16, 3.3)]
LAVADO = [(0.78, 0.16, 1.5), (0.78, 0.16, 4.9)]
LINHA_DE_AGUA = (1.0, 0.0, 0.0)


def praia_chao(indice: int, my_a: float, my_b: float) -> str:
    """O bloco de terra da praia: do fundo do mundo só até a crista.

    Nos trechos de porto quem desenha isto é a `laje`, que segue até `borda` e
    fecha com o muro. Aqui não há muro nenhum para fechar — quem fecha é a
    rampa, desenhada depois, junto com o enrocamento.
    """
    mundo = _pontos_da_praia(*CRISTA[indice], my_a, my_b)
    crista = [p(mx, my, ALT_CAIS * q) for mx, my, q in mundo]
    if len(crista) < 2:
        return ""
    # ⚠️ E ELE PASSA POR BAIXO DO PORTO, pela `COSTURA` e À ALTURA DO CAIS
    # (`136`). Acabava no `PONTA_NORTE` exato, onde a laje e o pátio começam,
    # e fechava na ponta da crista — que o meandro levanta até 1,09 do cais:
    # a borda saía inclinada, longe da laje junto do cais e colada a ela lá
    # atrás, e a ÁGUA, que é o fundo do mapa, via-se num fio azul que
    # engrossava para o cais (#1f86ac, anotado na `130`). A laje, desenhada
    # depois, tapa o que ele avança.
    if indice == 0:
        mx = mundo[-1][0]
        ini = [p(FUNDO_TERRA, my_a, ALT_CAIS)]
        fim = [p(mx, my_b + COSTURA, ALT_CAIS), p(FUNDO_TERRA, my_b + COSTURA, ALT_CAIS)]
    else:
        mx = mundo[0][0]
        ini = [p(FUNDO_TERRA, my_a - COSTURA, ALT_CAIS), p(mx, my_a - COSTURA, ALT_CAIS)]
        fim = [p(FUNDO_TERRA, my_b, ALT_CAIS)]
    s = poli(ini + crista + fim, C["solo"])
    return s


# A RESTINGA DAS PONTAS (`127`). Da crista para dentro, como na restinga de
# verdade: a areia ainda aparece entre a relva (o chão, em `campo_do_chao`),
# o capim-da-praia fecha-se junto da duna e rareia para trás, a salsa-da-praia
# desce a areia (`praia_areia`), e os arbustos e as árvores baixas — a
# aroeira penteada pelo vento, o guriri, a moita — são props que balançam
# (`arvores_da_restinga`).
RESTINGA_AREIA = 1.0     # unidades da crista para dentro onde a areia domina
RESTINGA_MANCHAS = 2.6   # até onde ainda há manchas de areia na relva
# O corte do campo `areia` em relva OU areia (`130`): o limiar, a largura da
# rampa de antisserrilhado (em unidades do campo, ~1 texel onde ele corre
# depressa) e a faixa de relva escurecida do lado de fora da borda.
RESTINGA_LIMIAR = 0.5
RESTINGA_BORDA = 0.08
RESTINGA_SAIA = 0.12


def restinga_rasteira(indice: int, my_a: float, my_b: float) -> str:
    """O capim-da-praia da restinga: denso junto da crista, raro para trás.

    ⚠️ VEM DEPOIS DO CAMPO DO CHÃO, e não com o chão da praia. Até à `127` o
    capim saía em `praia_chao` — antes da rua e da vila, que é a lição de
    04/09 (desenhado depois de uma casa, cai-lhe em cima). Continua antes
    delas; mas o chão da restinga passou a ser o raster do `campo_do_chao`,
    desenhado depois do laço dos degraus, e tapava-o.

    ⚠️ E DOIS TONS: o verde lê na areia e some na relva, a palha o contrário.
    """
    r = random.Random(SEMENTE_CHAO + 210 + indice)
    fundo = RUA_RECUO - RUA_LARG - CALCADA - PRAIA_PROF - 0.15
    s = ""
    for mx, my, (nmx, nmy), _t in andar_costa(-PRAIA_PROF, (0.07, 0.16), r):
        if not (my_a <= my <= my_b):
            continue
        # Mais perto da crista, mais capim: a distância sai de um sorteio
        # enviesado para zero, e os de trás ainda perdem metade.
        dentro = 0.05 + (fundo - 0.05) * r.random() ** 2.2
        if dentro > RESTINGA_AREIA and r.random() < 0.55:
            continue
        gx, gy = mx - nmx * dentro, my - nmy * dentro
        if not no_quadro(gx, gy):
            continue
        ex, ey = p(gx, gy, ALT_CAIS)
        palha = r.random() < (0.35 if dentro < RESTINGA_AREIA else 0.75)
        s += tufo_em_leque(ex, ey, r, n=(5, 8), alt=(6.0, 10.0),
                           cor=C["capim_palha"] if palha else C["capim_praia"])
    return s


def praia_areia(indice: int, my_a: float, my_b: float) -> str:
    """A rampa de areia, o pé molhado, o fundo submerso e as pedras.

    ⚠️ A RAMPA SAIU EM TRÊS TONS NA PRIMEIRA VERSÃO, e três era um a mais.
    Uma chapa de 58 px na tela não tem lado nenhum, isso é verdade — mas duas
    fronteiras internas a 0,27 e 0,13 da largura da rampa dão duas fitas de 16
    e 8 px de largura CONSTANTE, e na captura elas leram-se como as listras de
    uma bandeira. Ficaram duas: areia clara (que é o que a referência pede,
    "uma faixa clara") e o pé molhado, com a fronteira a serpentear largo.
    """
    r = random.Random(SEMENTE_CHAO + 170 + indice)
    s = _rampa_degrade(indice, my_a, my_b)

    # Manchas secas no alto da duna — o mesmo remédio do `manchas_chao` para o
    # pátio: tirar a chapa sem se fazer notar.
    for mx, my, (nmx, nmy), _t in andar_costa(0.0, (0.9, 2.0), r):
        if not (my_a <= my <= my_b) or r.random() < 0.35:
            continue
        t = r.uniform(0.06, 0.44)
        d = -PRAIA_PROF * (1.0 - t)
        cx, cy = p(mx + nmx * d, my + nmy * d, ALT_CAIS * (1.0 - t))
        s += ('  <ellipse cx="%.0f" cy="%.0f" rx="%.0f" ry="%.0f" fill="%s" '
              'opacity="0.45" transform="rotate(%.0f %.0f %.0f)"/>\n'
              % (cx, cy, r.uniform(9.0, 20.0), r.uniform(3.0, 6.0),
                 C["areia_seca"], r.uniform(-38, -14), cx, cy))

    s += salsa_da_praia(indice, my_a, my_b)

    # O baixio de areia é uma rampa de opacidade, não duas fitas sobrepostas.
    s += _baixio_de_areia(indice, my_a, my_b)

    # As pedras. A referência pede "faixa clara com pedras e coqueiros", e a
    # receita já existe: o sólido facetado do enrocamento (`com_saia`). O que
    # muda é a DENSIDADE — enrocamento é blindagem contínua, pedra de praia é
    # avulsa —, e por isso aqui são poucas, maiores e espalhadas entre o meio
    # da rampa e o baixio.
    tons = [C["pedra"], C["pedra_media"], C["pedra_clara"]]
    pedras = []
    for mx, my, (nmx, nmy), _t in andar_costa(0.0, (0.75, 1.8), r):
        if not (my_a <= my <= my_b):
            continue
        t = r.uniform(0.34, 1.26)          # acima de 1 já é dentro da água
        d = -PRAIA_PROF * (1.0 - t)
        bx, by = mx + nmx * d, my + nmy * d
        if not no_quadro(bx, by, 0.0):
            continue
        px, py = p(bx, by, ALT_CAIS * max(0.0, 1.0 - t))
        rx = r.uniform(5.0, 11.0)
        ry = rx * r.uniform(0.46, 0.62)
        n = r.choice((5, 6))
        a0 = r.uniform(0.0, math.tau)
        canto = []
        for k in range(n):
            a = a0 + math.tau * k / n + r.uniform(-0.25, 0.25)
            f = r.uniform(0.78, 1.0)
            canto.append((px + math.cos(a) * rx * f, py + math.sin(a) * ry * f))
        pedras.append((py, canto, rx * r.uniform(0.32, 0.60), tons[r.randrange(3)]))
    for _py, canto, h, topo in sorted(pedras, key=lambda q: q[0]):
        s += com_saia(canto, h, topo)

    return s


def salsa_da_praia(indice: int, my_a: float, my_b: float) -> str:
    """A salsa-da-praia: ramas rasteiras que descem da crista pela areia seca,
    com folha redonda e a flor roxa — a planta que segura a duna.

    ⚠️ DE UM `Random` PRÓPRIO: o da `praia_areia` espalha as pedras logo a
    seguir, e um sorteio a mais aqui mudava-as todas de sítio (`mapa.md`).
    E SÓ ATÉ `t = 0,4` da rampa: abaixo disso é a areia que a maré lava.
    """
    r = random.Random(SEMENTE_CHAO + 630 + indice)
    s = ""
    for mx, my, (nmx, nmy), (tmx, tmy) in andar_costa(0.0, (0.45, 1.0), r):
        if not (my_a <= my <= my_b) or r.random() < 0.40:
            continue
        if not no_quadro(mx, my):
            continue
        t0 = r.uniform(-0.04, 0.03)
        ramos, folhas, flores = [], [], []
        for _ in range(r.randint(3, 5)):
            giro = math.radians(r.uniform(-65.0, 65.0))
            # A rama corre para o mar torcida até 65° para os lados.
            ux = nmx * math.cos(giro) + tmx * math.sin(giro)
            uy = nmy * math.cos(giro) + tmy * math.sin(giro)
            comp = r.uniform(0.22, 0.48)
            # Começa na crista e anda `f` ao longo de `u`; a altura sai da parte
            # de `f` que vai para o mar — a rampa é reta da crista à água. Com
            # `comp` até 0,48 e o giro até 65°, `t` não passa de ~0,4.
            recuo = PRAIA_PROF * (1.0 - t0)
            sx, sy = mx - nmx * recuo, my - nmy * recuo
            pts = []
            for k in range(5):
                f = comp * k / 4.0
                lado = 0.05 * math.sin(k * 1.7 + giro * 3.0)
                bx, by = sx + ux * f + tmx * lado, sy + uy * f + tmy * lado
                t = t0 + f * math.cos(giro) / PRAIA_PROF
                pts.append(p(bx, by, ALT_CAIS * (1.0 - max(0.0, t))))
            ramos.append(pts)
            for k, (qx, qy) in enumerate(pts[1:], 1):
                for lado in (-1.0, 1.0):
                    if r.random() < 0.25:
                        continue
                    folhas.append((qx + lado * r.uniform(1.0, 2.6),
                                   qy + r.uniform(-1.2, 1.2),
                                   C["salsa"] if r.random() < 0.5 else C["salsa_clara"]))
                if r.random() < 0.22:
                    flores.append((qx + r.uniform(-1.5, 1.5), qy - r.uniform(0.5, 1.8)))
        for pts in ramos:
            s += ('  <path d="M%s" stroke="%s" stroke-width="1.1" fill="none" '
                  'stroke-linecap="round" stroke-linejoin="round"/>\n'
                  % (" L".join("%.1f,%.1f" % q for q in pts), C["salsa"]))
        for fx, fy, cor in folhas:
            s += ('  <ellipse cx="%.1f" cy="%.1f" rx="2.6" ry="1.8" fill="%s"/>\n'
                  % (fx, fy, cor))
        for fx, fy in flores:
            s += ('  <ellipse cx="%.1f" cy="%.1f" rx="1.7" ry="1.7" fill="%s"/>\n'
                  % (fx, fy, C["salsa_flor"]))
    return s


def _sombrear(hexa: str, fator: float) -> str:
    n = int(hexa[1:], 16)
    r, g, b = (n >> 16) & 255, (n >> 8) & 255, n & 255
    return "#%02x%02x%02x" % tuple(min(255, int(c * fator)) for c in (r, g, b))


# ── O TELHADO DE QUATRO ÁGUAS E A SOMBRA DA CASA (`123`) ─────────────────
#
# Até 17/10 o telhado era uma CAIXA de 5 px por cima da parede — uma tampa
# chata, que na foto do jogo lia como laje laranja e não como telhado. A casa
# térrea brasileira de telha de barro tem quatro panos e uma cumeeira curta, e
# a diferença de luz entre os dois panos que a câmera vê é o que desenha o
# volume, sem crescer quase nada para cima.
#
# A cumeeira corre ao longo do lado MAIOR, e cada rincão sobe a 45° em planta:
# é a forma de um telhado de quatro águas de inclinação igual nos quatro panos.
# A altura sai do lado MENOR, porque é ele que dá o vão da tesoura.
TELHADO_SUBIDA = 9.0      # px de cumeeira por unidade do lado menor do telhado
TELHADO_TESTEIRA = 2.0    # px da borda do beiral, que é o que lhe dá espessura
BEIRAL_CASA = 0.12        # o mesmo que o D14 lê como `BEIRAL_DA_CASA`


def telhado_quatro_aguas(x0, y0, x1, y1, base, cor) -> str:
    """Testeira e quatro panos sobre o retângulo do beiral, a partir de `base`.

    Os panos de trás (−mx, −my) saem primeiro e os da frente por cima: num
    volume convexo isso basta para que o pano de trás só apareça onde passa
    acima da cumeeira, que é o que a câmera de cima de facto vê.
    """
    dx, dy = x1 - x0, y1 - y0
    h = min(dx, dy) * TELHADO_SUBIDA
    t = base + TELHADO_TESTEIRA
    s = caixa(x0, y0, x1, y1, base, TELHADO_TESTEIRA, cor,
              _sombrear(cor, 0.62), _sombrear(cor, 0.74))
    if dx >= dy:
        m = (y0 + y1) / 2.0
        a, b = (x0 + dy / 2.0, m), (x1 - dy / 2.0, m)
        tras_my = [(x0, y0, t), (x1, y0, t), (b[0], b[1], t + h), (a[0], a[1], t + h)]
        tras_mx = [(x0, y0, t), (a[0], a[1], t + h), (x0, y1, t)]
        frente_mx = [(x1, y0, t), (x1, y1, t), (b[0], b[1], t + h)]
        frente_my = [(x0, y1, t), (a[0], a[1], t + h), (b[0], b[1], t + h), (x1, y1, t)]
    else:
        m = (x0 + x1) / 2.0
        a, b = (m, y0 + dx / 2.0), (m, y1 - dx / 2.0)
        tras_my = [(x0, y0, t), (x1, y0, t), (a[0], a[1], t + h)]
        tras_mx = [(x0, y0, t), (a[0], a[1], t + h), (b[0], b[1], t + h), (x0, y1, t)]
        frente_mx = [(x1, y0, t), (x1, y1, t), (b[0], b[1], t + h), (a[0], a[1], t + h)]
        frente_my = [(x0, y1, t), (b[0], b[1], t + h), (x1, y1, t)]
    # A LUZ É A DAS PAREDES: a face +mx é a de sombra (0,80) e a +my a de luz
    # (0,91), logo o pano que olha para +my leva o tom puro da telha e o que
    # olha para +mx o mais escuro. O pano puro é também o que o D24 lê.
    for pano, fator in ((tras_my, 0.84), (tras_mx, 0.95),
                        (frente_mx, 0.74), (frente_my, 1.0)):
        s += poli([p(*q) for q in pano], cor if fator == 1.0 else _sombrear(cor, fator))
    if cor != C["fibrocimento"]:
        # Na água +my o beiral é o lado 0–3 e a cumeeira o 1–2; na +mx, que
        # é triângulo quando a cumeeira corre em mx, os dois lados sobem do
        # beiral (0 e 1) ao mesmo ápice (2).
        if len(frente_my) == 4:
            s += _fiadas(frente_my, (0, 1), (3, 2), _sombrear(cor, 0.86))
        else:
            s += _fiadas(frente_my, (0, 1), (2, 1), _sombrear(cor, 0.86))
        if len(frente_mx) == 4:
            s += _fiadas(frente_mx, (0, 3), (1, 2), _sombrear(cor, 0.64))
        else:
            s += _fiadas(frente_mx, (0, 2), (1, 2), _sombrear(cor, 0.64))
    return s


def _fiadas(pano, lado_a, lado_b, cor) -> str:
    """Duas fiadas de telha paralelas ao beiral, a um e a dois terços da água.

    `lado_a` e `lado_b` são os índices (beiral, cumeeira) das duas arestas que
    sobem do beiral; a fiada é a tira entre os dois pontos à mesma fração da
    subida. É o que diz «telha de barro» e não «chapa laranja» (terceira
    passagem da `123`).
    """
    s = ""

    def em(ab, f):
        a, b = pano[ab[0]], pano[ab[1]]
        return tuple(a[k] + (b[k] - a[k]) * f for k in range(3))
    for f in (0.33, 0.66):
        q = [em(lado_a, f), em(lado_b, f), em(lado_b, f + 0.07), em(lado_a, f + 0.07)]
        s += poli([p(*v) for v in q], cor)
    return s


def altura_do_telhado(x0, y0, x1, y1) -> float:
    """O quanto o telhado sobe acima da parede, testeira incluída."""
    return TELHADO_TESTEIRA + min(x1 - x0, y1 - y0) * TELHADO_SUBIDA


# A SOMBRA anda na direção da das árvores antigas do mapa (a `arvore()` em
# SVG, que saiu com a restinga da `127`: 0,72 para +mx e 0,52
# para +my por raio de copa), mais curta por pixel de altura: medida na copa,
# a árvore lança ~0,016 unidades por px, e uma casa com essa razão cobriria o
# passeio inteiro até ao asfalto. A esta razão a de uma térrea acaba no
# passeio, e o volume assenta no chão sem a rua ganhar uma mancha.
SOMBRA_POR_PX = (0.0100, 0.0072)
SOMBRA_OPACIDADE = 0.26


def sombra_de_volume(x0, y0, x1, y1, altura) -> str:
    """O hexágono que a caixa lança no chão: a planta e ela deslocada.

    Quem chama passa o retângulo do BEIRAL e a altura da PAREDE: é a borda do
    beiral, à altura da parede, que desenha a orla da sombra; a cumeeira sobe
    mais, mas fica no meio, e a sombra dela cai dentro deste hexágono.
    """
    dx, dy = altura * SOMBRA_POR_PX[0], altura * SOMBRA_POR_PX[1]
    return _chao([(x0, y0), (x1, y0), (x1 + dx, y0 + dy), (x1 + dx, y1 + dy),
                  (x0 + dx, y1 + dy), (x0, y1)], C["mangue"], SOMBRA_OPACIDADE)


def casa(mx0, my0, mx1, my1, altura, parede, telha, janelas, acento=None) -> str:
    """Uma casa da vila: parede, porta, janela e telhado de quatro águas.

    O beiral é 0,12 — proporção de casa, não de galpão. A porta fica na face
    +my e ocupa pouco mais de um terço do vão, que é o que dá escala humana à
    construção. A sombra no chão sai à parte (`sombra_de_volume`), porque tem
    de ir para baixo da árvore do quintal da frente.
    """
    s = _paredes(mx0, my0, mx1, my1, altura, parede)
    s += _porta_my(my1, mx0, mx1, 0.33, 0.67, ALT_CAIS, ALT_CAIS + altura * 0.55,
                   acento)
    for linha in range(janelas):
        j0 = ALT_CAIS + altura * (0.30 + 0.62 * linha / max(janelas, 1))
        j1 = j0 + altura * 0.24
        s += _janela_mx(mx1, my0, my1, 0.36, 0.64, j0, j1, acento)
        if linha > 0 or janelas == 1:
            s += _janela_my(my1, mx0, mx1, 0.74, 0.90, j0, j1, acento)

    s += telhado_quatro_aguas(mx0 - BEIRAL_CASA, my0 - BEIRAL_CASA,
                              mx1 + BEIRAL_CASA, my1 + BEIRAL_CASA,
                              ALT_CAIS + altura, C[telha])
    return s


# ── AS SEIS CASAS DA VILA (`123`) ─────────────────────────────────────────
#
# Até 17/10 a vila tinha UMA casa — caixa, porta, janela e telhado — em três
# alturas e três cores, e na foto do jogo lia como um loteamento. O pedido do
# Bruno foi «mais variações de casa, seguindo o padrão brasileiro», e o que
# separa uma casa da outra a 51 px de lote é a SILHUETA, a mesma regra que
# escolheu a igreja, a praça e a obra (`022`). Daí seis formas, cada uma com um
# contorno que nenhuma outra tem:
#
#   · QUATRO ÁGUAS — a térrea de telha de barro, a de sempre;
#   · EMPENA — a casinha de duas águas com o triângulo virado para a rua, a da
#     vila de pescador, estreita, com a porta no meio da empena;
#   · PLATIBANDA — a fachada que sobe acima do telhado e o esconde, com a
#     cornija branca: o casario das cidades de porto, e a única que encosta na
#     vizinha (geminada) e de outra cor, como em Paraty;
#   · ALPENDRE — a varanda de esteios na frente, com a meia-água por cima;
#   · EM L — a casa com a ala recuada, que deixa um pátio na quina da frente;
#   · SOBRADO — dois pisos e a sacada, a altura do nível seguinte da vila.
#
# Cada uma devolve só o desenho; a SOMBRA sai em `sombra_da_casa`, porque vai
# para baixo do muro e da árvore da frente, que são desenhados depois.
CASA_TIPOS = {
    # tipo: (no saco da fileira da frente, no da de trás, largura mín., máx.)
    # ⚠️ A PLATIBANDA E O SOBRADO NÃO ESTÃO NO SACO (segunda passagem da
    # `123`): «por enquanto faça casas mais humildes, em fases mais para frente
    # casas melhores podem aparecer». O nível 1 é a vila simples — a meia-água,
    # a casinha de empena, a térrea de quatro águas, a de varanda e a em L — e
    # as duas melhores são a MELHORIA do mesmo lote no nível 2 da vila
    # (`forma_no_nivel`): a vila cresce casa a casa, sem mudar de terreno.
    "quatro_aguas": (3, 3, 0.76, 1.10),
    "empena": (3, 2, 0.62, 0.82),
    "meia_agua": (2, 3, 0.66, 0.92),
    "alpendre": (2, 2, 0.96, 1.22),
    "em_l": (1, 1, 1.14, 1.38),
    "platibanda": (0, 0, 0.72, 1.00),
    "sobrado": (0, 0, 0.80, 1.04),
}

# A casa melhor que cada forma humilde vira no nível seguinte da vila.
MELHORIA = {"meia_agua": "quatro_aguas", "empena": "platibanda",
            "quatro_aguas": "sobrado", "alpendre": "alpendre", "em_l": "em_l",
            "platibanda": "sobrado", "sobrado": "sobrado"}


def forma_no_nivel(forma: str, nivel: int) -> str:
    """A forma de um lote no nível pedido: o nível 1 é a sorteada.

    No nível 3 a vila é de prédios (`VILA_NIVEIS`), e toda forma volta a ser a
    caixa de quatro águas, que é a que aguenta três andares de janelas.
    """
    if nivel <= 1:
        return forma
    if nivel >= 3:
        return "quatro_aguas"
    return MELHORIA[forma]


def _tirar_do_saco(saco: list, r: random.Random, fundo: bool) -> str:
    """A forma seguinte da fileira, tirada de um SACO embaralhado.

    ⚠️ PESO SORTEADO CASA A CASA DEIXOU UMA FORMA DE FORA, duas vezes seguidas:
    a casa em L é a mais larga, e é a que o fim do degrau e os vãos dos prédios
    do pátio mais recusam — com peso 1,6 em 11 nenhuma chegou à tela. O saco
    tem cada forma o número de vezes da tabela, e só se enche outra vez quando
    acaba: em cada onze casas sorteadas, todas as formas saem.
    """
    if not saco:
        saco.extend(t for t, v in CASA_TIPOS.items() for _k in range(v[1 if fundo else 0]))
        r.shuffle(saco)
    if not saco:
        raise ValueError("o saco da fileira está vazio — CASA_TIPOS sem contagem")
    return saco.pop()


def _paredes(x0, y0, x1, y1, altura, parede) -> str:
    """As paredes e o barrado, nas duas faces que a câmera vê."""
    s = caixa(x0, y0, x1, y1, ALT_CAIS, altura, parede,
              _sombrear(parede, 0.80), _sombrear(parede, 0.91))
    barra = _sombrear(parede, 0.78)
    s += face_mx(x1, y0, y1, ALT_CAIS, ALT_CAIS + BARRADO_ALT, _sombrear(barra, 0.80))
    s += face_my(y1, x0, x1, ALT_CAIS, ALT_CAIS + BARRADO_ALT, _sombrear(barra, 0.91))
    return s


def _vao_mx(x, y0, y1, a, b, z0, z1, cor) -> str:
    """Uma abertura na face +mx, entre as frações `a` e `b` do lado."""
    return face_mx(x, y0 + (y1 - y0) * a, y0 + (y1 - y0) * b, z0, z1, cor)


def _vao_my(y, x0, x1, a, b, z0, z1, cor) -> str:
    """Uma abertura na face +my, entre as frações `a` e `b` do lado."""
    return face_my(y, x0 + (x1 - x0) * a, x0 + (x1 - x0) * b, z0, z1, cor)


# ── O DETALHE QUE DÁ VIDA À CASA HUMILDE (terceira passagem da `123`) ────
#
# «Melhore alguns detalhes para deixar as casas mais ricas em detalhes, assim
# torna a cidade um pouco mais viva.» A casa continua simples; o que a rua
# brasileira tem e a vila não tinha é COR PEQUENA: cada casa tem uma cor de
# acento — a das folhas da janela, a da porta e a do portão —, e é ela que
# salpica a fileira. A janela ganha a moldura e as duas folhas abertas, e a
# parede o BARRADO, a faixa escura que a casa simples pinta na base para
# esconder a lama da chuva.
ACENTOS = ["acento_verde", "acento_azul", "acento_vermelho", "acento_ocre"]
BARRADO_ALT = 2.6         # px da faixa escura na base da parede


def _folhas(face, plano, a0, a1, z0, z1, lim0, lim1, acento, sombra) -> str:
    """A moldura e as duas folhas abertas de uma janela entre `a0` e `a1`."""
    f = face_mx if face == "mx" else face_my
    larg = (a1 - a0) * 0.42
    s = f(plano, a0 - 0.012, a1 + 0.012, z0 - 0.8, z1 + 0.8,
          _sombrear(C["caiacao"], sombra))
    if acento:
        cor = _sombrear(C[acento], sombra)
        if a0 - 0.012 - larg > lim0:
            s += f(plano, a0 - 0.012 - larg, a0 - 0.012, z0, z1, cor)
        if a1 + 0.012 + larg < lim1:
            s += f(plano, a1 + 0.012, a1 + 0.012 + larg, z0, z1, cor)
    return s


def _janela_mx(x, y0, y1, a, b, z0, z1, acento=None) -> str:
    """Janela na face +mx: moldura clara, as folhas na cor de acento, vidro."""
    ya, yb = y0 + (y1 - y0) * a, y0 + (y1 - y0) * b
    return _folhas("mx", x, ya, yb, z0, z1, y0 + 0.01, y1 - 0.01, acento, 0.80) \
        + face_mx(x, ya, yb, z0, z1, C["vidro"])


def _janela_my(y, x0, x1, a, b, z0, z1, acento=None) -> str:
    """Janela na face +my: a mesma, com a luz da face +my."""
    xa, xb = x0 + (x1 - x0) * a, x0 + (x1 - x0) * b
    return _folhas("my", y, xa, xb, z0, z1, x0 + 0.01, x1 - 0.01, acento, 0.91) \
        + face_my(y, xa, xb, z0, z1, C["vidro"])


def _porta_mx(x, y0, y1, a, b, z0, z1, acento=None) -> str:
    """A porta na face +mx: de madeira, ou pintada da cor de acento."""
    cor = _sombrear(C[acento], 0.80) if acento else C["porta"]
    return _vao_mx(x, y0, y1, a, b, z0, z1, cor)


def _porta_my(y, x0, x1, a, b, z0, z1, acento=None) -> str:
    cor = _sombrear(C[acento], 0.91) if acento else C["porta"]
    return _vao_my(y, x0, x1, a, b, z0, z1, cor)


def telhado_duas_aguas(x0, y0, x1, y1, base, cor, parede, beiral=BEIRAL_CASA,
                       ponta=0.06, subida=TELHADO_SUBIDA * 1.25,
                       respiro=False) -> str:
    """Duas águas com a cumeeira ao longo de mx e a empena na face +mx.

    O retângulo é o da PAREDE; o beiral sai dos lados e a `ponta` sobre a
    empena. ⚠️ O PANO −my PARTE-SE NA EMPENA: a parte de trás dele fica atrás
    dela e tem de sair antes; a tira da ponta, à frente, sai depois — senão a
    empena come a borda do telhado do lado da sombra (a nave da igreja ensinou
    isto primeiro).
    """
    ym = (y0 + y1) / 2.0
    h = (y1 - y0) * subida
    t = base
    tras = lambda xa, xb: poli([p(xa, y0 - beiral, t), p(xb, y0 - beiral, t),
                                p(xb, ym, t + h), p(xa, ym, t + h)],
                               _sombrear(cor, 0.84))
    s = tras(x0 - ponta, x1)
    s += poli([p(x1, y0, t), p(x1, y1, t), p(x1, ym, t + h)], _sombrear(parede, 0.80))
    if respiro:
        # O óculo do sótão: um quadrado escuro no terço de baixo da empena.
        s += face_mx(x1, ym - (y1 - y0) * 0.07, ym + (y1 - y0) * 0.07,
                     t + h * 0.22, t + h * 0.42, C["porta"])
    s += tras(x1, x1 + ponta)
    s += poli([p(x0 - ponta, y1 + beiral, t), p(x1 + ponta, y1 + beiral, t),
               p(x1 + ponta, ym, t + h), p(x0 - ponta, ym, t + h)], cor)
    return s


def _caixa_dagua(mx, my, z) -> str:
    """A caixa de fibra azul: o costado e a tampa, uma elipse e um arco.

    Em planta o raio vira uma elipse de `r·√2·MEIA_LARG` por `r·√2·MEIA_ALT`;
    o costado é o retângulo entre a tampa e a metade de BAIXO da elipse da
    base (o arco com `sweep` 0 vai das 9 às 3 passando pelas 6, com o y da
    tela para baixo).
    """
    r, alt = 0.085, 5.5
    cx, cy = p(mx, my, z)
    rx, ry = r * MEIA_LARG * math.sqrt(2.0), r * MEIA_ALT * math.sqrt(2.0)
    s = ('  <path d="M%.1f,%.1f L%.1f,%.1f A%.1f,%.1f 0 0 0 %.1f,%.1f L%.1f,%.1f Z" '
         'fill="%s"/>\n' % (cx - rx, cy - alt, cx - rx, cy, rx, ry, cx + rx, cy,
                            cx + rx, cy - alt, C["caixa_dagua_lado"]))
    # OS DOIS FRISOS do costado, as nervuras da caixa de fibra: cada um é a
    # metade de baixo da elipse a uma altura, com 0,7 px de espessura — ida
    # pelo arco de baixo (`sweep` 0) e volta por ele ao contrário (`sweep` 1).
    for zf in (1.6, 3.5):
        y = cy - zf
        s += ('  <path d="M%.1f,%.1f A%.1f,%.1f 0 0 0 %.1f,%.1f L%.1f,%.1f '
              'A%.1f,%.1f 0 0 1 %.1f,%.1f Z" fill="%s"/>\n'
              % (cx - rx, y, rx, ry, cx + rx, y, cx + rx, y - 0.7, rx, ry,
                 cx - rx, y - 0.7, C["caixa_dagua_friso"]))
    # A tampa: o aro, a tampa mais clara dentro dele e o pegador no meio.
    s += ('  <ellipse cx="%.1f" cy="%.1f" rx="%.1f" ry="%.1f" fill="%s"/>\n'
          % (cx, cy - alt, rx, ry, C["caixa_dagua"]))
    s += ('  <ellipse cx="%.1f" cy="%.1f" rx="%.1f" ry="%.1f" fill="%s"/>\n'
          % (cx, cy - alt, rx * 0.66, ry * 0.66, C["caixa_dagua_tampa"]))
    s += ('  <ellipse cx="%.1f" cy="%.1f" rx="%.1f" ry="%.1f" fill="%s"/>\n'
          % (cx, cy - alt - 0.4, rx * 0.22, ry * 0.22, C["caixa_dagua_lado"]))
    return s


# ── A CAIXA ASSENTA NO TELHADO (quinta passagem da `123`) ────────────────
#
# «Melhore os detalhes das caixas da água, e tente encaixar melhor nas casas.»
# Até aqui a caixa era um cilindro posto a uma altura escolhida à mão, e o pé
# dela ou afundava na água do telhado ou pairava acima dela, conforme a casa.
# Agora cada forma diz a ALTURA DO TELHADO em qualquer ponto (`z_*`), e a caixa
# pousa num murete de alvenaria cujos quatro cantos de baixo seguem a água
# naquele sítio e cujo topo é plano: é o que a casa de verdade faz, e o pé
# deixa de ser uma aposta.
CAIXA_BASE = 0.105        # meio lado do murete, um nada maior do que a caixa


def z_quatro_aguas(x0, y0, x1, y1, base):
    """A altura do telhado de quatro águas sobre o retângulo do beiral."""
    dx, dy = x1 - x0, y1 - y0
    h = min(dx, dy) * TELHADO_SUBIDA
    k = h / (min(dx, dy) / 2.0)
    t = base + TELHADO_TESTEIRA
    return lambda x, y: t + min(h, k * max(0.0, min(x - x0, x1 - x, y - y0, y1 - y)))


def z_duas_aguas(y0, y1, base, beiral=BEIRAL_CASA, subida=TELHADO_SUBIDA * 1.25):
    """A altura do telhado de duas águas, com a cumeeira ao longo de mx."""
    ym, h = (y0 + y1) / 2.0, (y1 - y0) * subida
    meia = (y1 - y0) / 2.0 + beiral
    return lambda x, y: base + max(0.0, h * (1.0 - abs(y - ym) / meia))


def z_meia_agua(mx0, mx1, base):
    """A altura da água única, a cair do muro de trás para a frente."""
    queda = _meia_agua(mx0, mx1)
    return lambda x, y: base + queda * (mx1 - x) / (mx1 - mx0)


def _caixa_assente(cx, cy, z_telhado) -> str:
    """O murete que nivela a caixa sobre a água, e a caixa por cima dele."""
    a = CAIXA_BASE
    zc = {(sx, sy): z_telhado(cx + sx * a, cy + sy * a)
          for sx in (-1, 1) for sy in (-1, 1)}
    zt = max(zc.values()) + 1.5
    cor = C["reboco"]
    s = poli([p(cx + a, cy - a, zt), p(cx + a, cy + a, zt),
              p(cx + a, cy + a, zc[(1, 1)]), p(cx + a, cy - a, zc[(1, -1)])],
             _sombrear(cor, 0.80))
    s += poli([p(cx - a, cy + a, zt), p(cx + a, cy + a, zt),
               p(cx + a, cy + a, zc[(1, 1)]), p(cx - a, cy + a, zc[(-1, 1)])],
              _sombrear(cor, 0.91))
    s += poli([p(cx - a, cy - a, zt), p(cx + a, cy - a, zt),
               p(cx + a, cy + a, zt), p(cx - a, cy + a, zt)], cor)
    return s + _caixa_dagua(cx, cy, zt)


def _caixa_no_telhado(x0, y0, x1, y1, base) -> str:
    """A caixa-d'água sobre a cumeeira de um telhado de quatro águas.

    ⚠️ EM CIMA DA CUMEEIRA, e não no pano de trás: atrás dela, a cumeeira fica
    entre a câmera e o pé do murete, e o murete, desenhado depois do telhado,
    pintava-se por cima dela. Na cumeeira não há telhado à frente do pé.
    """
    cx, cy = (x0 + x1) / 2.0, (y0 + y1) / 2.0
    return _caixa_assente(cx - 0.04, cy - 0.04, z_quatro_aguas(x0, y0, x1, y1, base))


def casa_empena(mx0, my0, mx1, my1, altura, parede, telha, janelas, acento=None) -> str:
    """A casinha de duas águas, com a empena e a porta viradas para a rua."""
    s = _paredes(mx0, my0, mx1, my1, altura, parede)
    s += _porta_mx(mx1, my0, my1, 0.38, 0.62, ALT_CAIS, ALT_CAIS + altura * 0.62, acento)
    for linha in range(janelas):
        z0 = ALT_CAIS + altura * (0.32 + 0.62 * linha / max(janelas, 1))
        s += _janela_my(my1, mx0, mx1, 0.30, 0.58, z0, z0 + altura * 0.26, acento)
    s += telhado_duas_aguas(mx0, my0, mx1, my1, ALT_CAIS + altura, C[telha],
                            parede, respiro=True)
    return s


MEIA_AGUA_SUBIDA = 6.5    # px de queda do telhado por unidade de fundo


def _meia_agua(mx0, mx1) -> float:
    return (mx1 - mx0) * MEIA_AGUA_SUBIDA


def casa_meia_agua(mx0, my0, mx1, my1, altura, parede, telha, janelas, acento=None) -> str:
    """A mais simples: um telhado de uma água só, a cair para a rua.

    ⚠️ CAI PARA A FRENTE (+mx) E NÃO PARA TRÁS. Caído para trás, o pano olha
    para longe da câmera e a 60° quase some; caído para a frente ele mostra-se
    inteiro, e o oitão do lado +my — o triângulo de parede entre a água e o
    muro de trás, mais alto — é o contorno que nenhuma outra casa tem.
    A telha ondulada leva vincos ao comprido da água: é o que a diz
    fibrocimento e não laje.
    """
    queda = _meia_agua(mx0, mx1)
    t = ALT_CAIS + altura
    p_esq = _sombrear(parede, 0.91)
    s = _paredes(mx0, my0, mx1, my1, altura, parede)
    s += poli([p(mx1, my1, t), p(mx0, my1, t), p(mx0, my1, t + queda)], p_esq)
    s += _porta_mx(mx1, my0, my1, 0.56, 0.80, ALT_CAIS, ALT_CAIS + altura * 0.70, acento)
    s += _janela_mx(mx1, my0, my1, 0.16, 0.38, ALT_CAIS + altura * 0.36,
                 ALT_CAIS + altura * 0.66, acento)
    s += _janela_my(my1, mx0, mx1, 0.40, 0.66, ALT_CAIS + altura * 0.34,
                 ALT_CAIS + altura * 0.62, acento)
    e = 0.08
    cor = C[telha]
    z = lambda x: t + queda * (mx1 - x) / (mx1 - mx0)
    xa, xb, ya, yb = mx0 - e, mx1 + e, my0 - e, my1 + e
    s += poli([p(xa, ya, z(xa)), p(xa, yb, z(xa)), p(xb, yb, z(xb)), p(xb, ya, z(xb))],
              _sombrear(cor, 0.92))
    if telha == "fibrocimento":
        n = max(3, int((yb - ya) / 0.11))
        for k in range(1, n):
            y = ya + (yb - ya) * k / n
            s += poli([p(xa, y, z(xa)), p(xa, y + 0.018, z(xa)),
                       p(xb, y + 0.018, z(xb)), p(xb, y, z(xb))], _sombrear(cor, 0.78))
    s += poli([p(xb, ya, z(xb)), p(xb, yb, z(xb)), p(xb, yb, z(xb) - 1.4),
               p(xb, ya, z(xb) - 1.4)], _sombrear(cor, 0.62))
    s += poli([p(xa, yb, z(xa)), p(xb, yb, z(xb)), p(xb, yb, z(xb) - 1.4),
               p(xa, yb, z(xa) - 1.4)], _sombrear(cor, 0.74))
    return s


PLATIBANDA_ALTURA = 6.0   # px que a fachada sobe acima da parede


def casa_platibanda(mx0, my0, mx1, my1, altura, parede, telha, janelas, acento=None) -> str:
    """O casario: a fachada sobe acima do telhado e acaba numa cornija branca.

    O telhado fica ATRÁS da platibanda e sem beiral dos lados — é o que deixa
    duas destas encostarem sem um telhado fatiar o outro, a armadilha que
    obrigava a geminada a herdar a variante da vizinha (`_fileira`).
    """
    s = _paredes(mx0, my0, mx1, my1, altura, parede)
    s += _porta_mx(mx1, my0, my1, 0.12, 0.34, ALT_CAIS, ALT_CAIS + altura * 0.66, acento)
    for a, b in ((0.46, 0.64), (0.74, 0.90)):
        s += _janela_mx(mx1, my0, my1, a, b, ALT_CAIS + altura * 0.34,
                     ALT_CAIS + altura * 0.66, acento)
    if janelas > 1:
        for a, b in ((0.12, 0.34), (0.46, 0.64), (0.74, 0.90)):
            s += _janela_mx(mx1, my0, my1, a, b, ALT_CAIS + altura * 0.78,
                         ALT_CAIS + altura * 0.92, acento)
    s += telhado_quatro_aguas(mx0 + 0.04, my0 + 0.02, mx1 - 0.10, my1 - 0.02,
                              ALT_CAIS + altura, C[telha])
    t = ALT_CAIS + altura
    s += caixa(mx1 - 0.05, my0, mx1, my1, t, PLATIBANDA_ALTURA, parede,
               _sombrear(parede, 0.80), _sombrear(parede, 0.91))
    branco = C["caiacao"]
    s += caixa(mx1 - 0.07, my0 - 0.01, mx1 + 0.02, my1 + 0.01,
               t + PLATIBANDA_ALTURA, 1.6, branco,
               _sombrear(branco, 0.80), _sombrear(branco, 0.91))
    return s


def _alpendre(mx0, mx1) -> float:
    return min(0.34, (mx1 - mx0) * 0.28)


def casa_alpendre(mx0, my0, mx1, my1, altura, parede, telha, janelas, acento=None) -> str:
    """A casa de varanda: esteios na frente e a meia-água por cima.

    A ordem não é a do resto: a meia-água sai ANTES do telhado do corpo,
    porque o beiral do corpo passa por cima da cabeça dela. Os esteios são de
    madeira escura — brancos contra a parede branca não se viam.
    """
    bx1 = mx1 - _alpendre(mx0, mx1)
    s = _paredes(mx0, my0, bx1, my1, altura, parede)
    s += _porta_mx(bx1, my0, my1, 0.40, 0.60, ALT_CAIS, ALT_CAIS + altura * 0.62, acento)
    for a, b in ((0.12, 0.30), (0.70, 0.88)):
        s += _janela_mx(bx1, my0, my1, a, b, ALT_CAIS + altura * 0.34,
                     ALT_CAIS + altura * 0.64, acento)
    s += _janela_my(my1, mx0, bx1, 0.30, 0.60, ALT_CAIS + altura * 0.32,
                 ALT_CAIS + altura * 0.58, acento)
    piso = 1.5
    s += caixa(bx1, my0 + 0.03, mx1, my1 - 0.03, ALT_CAIS, piso, C["calcada"],
               _sombrear(C["calcada"], 0.80), _sombrear(C["calcada"], 0.91))
    topo, borda = ALT_CAIS + altura - 1.0, ALT_CAIS + altura * 0.70
    lado = 0.04
    for y in (my0 + 0.06, (my0 + my1) / 2.0 - lado / 2.0, my1 - 0.06 - lado):
        s += caixa(mx1 - 0.06, y, mx1 - 0.06 + lado, y + lado, ALT_CAIS + piso,
                   borda - ALT_CAIS - piso, C["tronco"],
                   _sombrear(C["tronco"], 0.80), _sombrear(C["tronco"], 0.91))
    s += poli([p(bx1, my0 - 0.04, topo), p(bx1, my1 + 0.04, topo),
               p(mx1 + 0.04, my1 + 0.04, borda), p(mx1 + 0.04, my0 - 0.04, borda)],
              _sombrear(C[telha], 0.86))
    s += face_mx(mx1 + 0.04, my0 - 0.04, my1 + 0.04, borda - 1.2, borda,
                 _sombrear(C[telha], 0.62))
    s += telhado_quatro_aguas(mx0 - BEIRAL_CASA, my0 - BEIRAL_CASA,
                              bx1 + BEIRAL_CASA, my1 + BEIRAL_CASA,
                              ALT_CAIS + altura, C[telha])
    return s


def _em_l(mx0, my0, mx1, my1) -> tuple:
    """O corpo e a ala da casa em L, em planta."""
    ya = my0 + (my1 - my0) * 0.56
    xw = mx0 + (mx1 - mx0) * 0.58
    return (mx0, my0, mx1, ya), (mx0, ya, xw, my1)


def casa_em_l(mx0, my0, mx1, my1, altura, parede, telha, janelas, acento=None) -> str:
    """O corpo ao comprido e a ala recuada, com o pátio na quina da frente.

    ⚠️ A ALA SAI DEPOIS DO CORPO E ISSO NÃO É GOSTO: os dois encostam no plano
    `my = ya`, a ala está do lado +my dele, e a câmera olha desse lado — logo
    nada do corpo pode tapar a ala. A porta é a da ala, virada para o pátio.
    """
    (cx0, cy0, cx1, cy1), (ax0, ay0, ax1, ay1) = _em_l(mx0, my0, mx1, my1)
    s = _paredes(cx0, cy0, cx1, cy1, altura, parede)
    s += _janela_mx(cx1, cy0, cy1, 0.30, 0.70, ALT_CAIS + altura * 0.34,
                 ALT_CAIS + altura * 0.64, acento)
    s += _janela_my(cy1, cx0, cx1, 0.68, 0.88, ALT_CAIS + altura * 0.32,
                 ALT_CAIS + altura * 0.58, acento)
    s += telhado_quatro_aguas(cx0 - BEIRAL_CASA, cy0 - BEIRAL_CASA,
                              cx1 + BEIRAL_CASA, cy1 + BEIRAL_CASA,
                              ALT_CAIS + altura, C[telha])
    s += _paredes(ax0, ay0, ax1, ay1, altura, parede)
    s += _porta_mx(ax1, ay0, ay1, 0.36, 0.64, ALT_CAIS, ALT_CAIS + altura * 0.62, acento)
    s += _janela_my(ay1, ax0, ax1, 0.30, 0.62, ALT_CAIS + altura * 0.32,
                 ALT_CAIS + altura * 0.58, acento)
    s += telhado_quatro_aguas(ax0 - BEIRAL_CASA, ay0 - BEIRAL_CASA,
                              ax1 + BEIRAL_CASA, ay1 + BEIRAL_CASA,
                              ALT_CAIS + altura, C[telha])
    return s


def altura_do_sobrado(nivel: int, variante: int) -> int:
    """O sobrado tem a parede do nível SEGUINTE da vila, como a obra."""
    if nivel + 1 in VILA_NIVEIS:
        return VILA_NIVEIS[nivel + 1][variante][0]
    return int(VILA_NIVEIS[nivel][variante][0] * 1.34)


def sobrado(mx0, my0, mx1, my1, altura, parede, telha, janelas, acento=None) -> str:
    """Dois pisos, a porta e a sacada na face da rua, quatro águas por cima."""
    s = _paredes(mx0, my0, mx1, my1, altura, parede)
    # ⚠️ A PORTA DO TÉRREO VAI PARA UM LADO: no eixo, por baixo da porta da
    # sacada, as duas liam como UMA porta comprida (segunda foto da `123`).
    s += _porta_mx(mx1, my0, my1, 0.10, 0.28, ALT_CAIS, ALT_CAIS + altura * 0.36, acento)
    for a, b in ((0.42, 0.58), (0.72, 0.88)):
        s += _janela_mx(mx1, my0, my1, a, b, ALT_CAIS + altura * 0.16,
                     ALT_CAIS + altura * 0.34, acento)
    for z0 in (ALT_CAIS + altura * 0.16, ALT_CAIS + altura * 0.62):
        s += _janela_my(my1, mx0, mx1, 0.30, 0.56, z0, z0 + altura * 0.18, acento)
    # A SACADA: a porta do piso de cima, a laje que sai da fachada e o
    # guarda-corpo escuro, que é o traço que a faz ler a esta escala.
    zb = ALT_CAIS + altura * 0.52
    s += _porta_mx(mx1, my0, my1, 0.38, 0.62, zb, zb + altura * 0.30, acento)
    ya, yb = my0 + (my1 - my0) * 0.28, my0 + (my1 - my0) * 0.72
    s += caixa(mx1, ya, mx1 + 0.10, yb, zb - 1.2, 1.2, C["caiacao"],
               _sombrear(C["caiacao"], 0.80), _sombrear(C["caiacao"], 0.91))
    s += face_mx(mx1 + 0.10, ya, yb, zb + 2.2, zb + 3.2, C["tronco"])
    for y in (ya, (ya + yb) / 2.0, yb - 0.02):
        s += face_mx(mx1 + 0.10, y, y + 0.02, zb, zb + 3.2, C["tronco"])
    s += telhado_quatro_aguas(mx0 - BEIRAL_CASA, my0 - BEIRAL_CASA,
                              mx1 + BEIRAL_CASA, my1 + BEIRAL_CASA,
                              ALT_CAIS + altura, C[telha])
    return s


CASAS = {"quatro_aguas": casa, "empena": casa_empena,
         "meia_agua": casa_meia_agua,
         "platibanda": casa_platibanda, "alpendre": casa_alpendre,
         "em_l": casa_em_l, "sobrado": sobrado}


def sombra_da_casa(tipo, mx0, my0, mx1, my1, altura) -> str:
    """A sombra de cada forma: os volumes que a lançam, à altura da parede."""
    b = BEIRAL_CASA
    if tipo == "platibanda":
        return sombra_de_volume(mx0, my0, mx1, my1, altura + PLATIBANDA_ALTURA)
    if tipo == "meia_agua":
        return sombra_de_volume(mx0 - 0.08, my0 - 0.08, mx1 + 0.08, my1 + 0.08,
                                altura + _meia_agua(mx0, mx1) * 0.5)
    if tipo == "alpendre":
        bx1 = mx1 - _alpendre(mx0, mx1)
        return sombra_de_volume(mx0 - b, my0 - b, bx1 + b, my1 + b, altura)
    if tipo == "em_l":
        (cx0, cy0, cx1, cy1), (ax0, ay0, ax1, ay1) = _em_l(mx0, my0, mx1, my1)
        return sombra_de_volume(cx0 - b, cy0 - b, cx1 + b, cy1 + b, altura) \
            + sombra_de_volume(ax0 - b, ay0 - b, ax1 + b, ay1 + b, altura)
    return sombra_de_volume(mx0 - b, my0 - b, mx1 + b, my1 + b, altura)


def caixa_dagua_da_casa(tipo, mx0, my0, mx1, my1, altura) -> str:
    """Onde cada forma leva a caixa-d'água, se levar."""
    b = BEIRAL_CASA
    t = ALT_CAIS + altura
    if tipo == "meia_agua":
        # Junto do muro de trás, o mais alto: é onde a casa simples a põe.
        return _caixa_assente(mx0 + 0.20, (my0 + my1) / 2.0,
                              z_meia_agua(mx0, mx1, t))
    if tipo == "empena":
        return _caixa_assente((mx0 + mx1) / 2.0 - 0.15, (my0 + my1) / 2.0 - 0.03,
                              z_duas_aguas(my0, my1, t))
    if tipo == "platibanda":
        return _caixa_no_telhado(mx0 + 0.04, my0 + 0.02, mx1 - 0.10, my1 - 0.02, t)
    if tipo == "alpendre":
        return _caixa_no_telhado(mx0 - b, my0 - b, mx1 - _alpendre(mx0, mx1) + b,
                                 my1 + b, t)
    if tipo == "em_l":
        (cx0, cy0, cx1, cy1), _ala = _em_l(mx0, my0, mx1, my1)
        return _caixa_no_telhado(cx0 - b, cy0 - b, cx1 + b, cy1 + b, t)
    return _caixa_no_telhado(mx0 - b, my0 - b, mx1 + b, my1 + b, t)


# ── O TERRENO: O MURO BAIXO E O QUINTAL DENTRO DELE (`123`) ──────────────
#
# A casa brasileira tem MURO. Até à `123` o quintal era uma mancha de terra
# meio transparente à volta da casa, que passava por cima do passeio, e o que
# se pediu foi «mais espaço para terrenos»: o terreno passa a ter limite — o
# muro baixo da frente, com o portão, e o das divisas — e o quintal fica dentro
# dele. O muro da frente fica um nada antes da calçada (ou da viela, na fileira
# de trás), e a casa recua `VILA_QUINTAL_FRENTE` dele.
VILA_QUINTAL_FRENTE = 0.12
# ⚠️ ERA 3,5 PX E UM TOM ABAIXO DA PAREDE (0,95), e na foto do jogo era uma
# linha clara que ninguém lia como muro (segunda foto da `123`). A 5 px e a
# 0,85 da parede ele marca o terreno sem virar uma muralha.
VILA_MURO_ALT = 5.0
VILA_MURO_ESP = 0.04
VILA_DIVISA = 0.16        # o quanto o terreno sai da casa para cada lado


def linha_do_muro(borda: float, fundo: bool) -> float:
    """O `mx` do muro da frente: antes da calçada, ou antes da viela."""
    if fundo:
        return borda - VILA_RECUO_2 + VILA_PROF + 0.12 - 0.03
    return borda - RUA_RECUO - CALCADA - 0.03


def _borda_do_lote(my0: float) -> float:
    for a, b, borda in DEGRAUS:
        if a <= my0 < b:
            return borda
    raise ValueError("lote fora dos degraus: my=%.2f" % my0)


def terrenos_da_vila(lotes: list) -> list:
    """(x_trás, x_muro, y_esq, y_dir, muro_esq, muro_dir) de cada lote.

    A divisa fica a meio do vão até à vizinha, e nunca a mais de `VILA_DIVISA`
    da casa; geminada não tem muro do lado da vizinha — a parede é a divisa.
    """
    saida = []
    for i, (mx0, my0, dmx, dmy, _v, fundo, _c) in enumerate(lotes):
        esq, dir_ = math.inf, math.inf
        for j, (_x, oy0, _dx, ody, _ov, ofundo, _oc) in enumerate(lotes):
            if j == i or ofundo != fundo:
                continue
            if oy0 + ody <= my0 + 1e-9:
                esq = min(esq, my0 - (oy0 + ody))
            elif oy0 >= my0 + dmy - 1e-9:
                dir_ = min(dir_, oy0 - (my0 + dmy))
        borda = _borda_do_lote(my0)
        saida.append((mx0 - 0.28, linha_do_muro(borda, fundo),
                      my0 - min(VILA_DIVISA, esq / 2.0),
                      my0 + dmy + min(VILA_DIVISA, dir_ / 2.0),
                      esq > 0.02, dir_ > 0.02))
    return saida


def _muro(x0, y0, x1, y1, parede) -> str:
    cor = _sombrear(parede, 0.85)
    return caixa(x0, y0, x1, y1, ALT_CAIS, VILA_MURO_ALT, cor,
                 _sombrear(cor, 0.80), _sombrear(cor, 0.91))


# Onde fica a porta na face da rua, em fração do lado (`my`); a de quatro águas
# e a casa em L abrem para o lado, e o portão vai para a ponta +my.
PORTA_NA_FRENTE = {"empena": 0.50, "meia_agua": 0.68, "alpendre": 0.50,
                   "sobrado": 0.19, "platibanda": 0.23}


def muros_do_terreno(terreno, parede, porta=None, acento=None) -> tuple:
    """(o que fica atrás da casa, o que fica à frente) do muro do terreno.

    O muro da divisa −my está atrás da casa e sai antes dela; o da +my e o da
    frente estão à frente e saem depois. O portão é um vão no muro da frente
    em frente à porta (ou na ponta +my, quando a porta abre para o lado), com
    a folha na cor de acento e o caminho de cimento até à casa.
    """
    xt, xm, ye, yd, me, md = terreno
    e = VILA_MURO_ESP
    atras = _muro(xt + 0.10, ye, xm, ye + e, parede) if me else ""
    frente = _muro(xt + 0.10, yd - e, xm, yd, parede) if md else ""
    meio = yd - 0.22 if porta is None or porta >= yd - 0.12 else porta
    meio = min(max(meio, ye + 0.18), yd - 0.18)
    p0, p1 = meio - 0.11, meio + 0.11
    # O caminho de cimento sai antes do muro, que o corta à altura do portão.
    frente = _faixa_mx(xm - VILA_QUINTAL_FRENTE - 0.02, xm, p0 + 0.03, p1 - 0.03,
                       C["calcada"], 0.9) + frente
    if p0 - ye > 0.06:
        frente += _muro(xm - e, ye, xm, p0, parede)
    if yd - p1 > 0.06:
        frente += _muro(xm - e, p1, xm, yd, parede)
    if acento:
        # A folha do portão, recuada no vão e mais baixa do que o muro.
        frente += face_mx(xm - e * 0.5, p0, p1, ALT_CAIS,
                          ALT_CAIS + VILA_MURO_ALT - 1.0, _sombrear(C[acento], 0.80))
    return atras, frente


def _moita(mx, my, flor, r: random.Random) -> str:
    """Uma moita florida junto da casa: a primavera, o ipê, o jasmim.

    É a receita da copa (`com_saia`), pequena e rente ao chão, com quatro
    pontos de flor por cima — a cor que um quintal brasileiro tem e a vila não
    tinha. ⚠️ Gasta o `r` da vila: as árvores que vêm depois mudam de sítio
    com isso, como já mudavam a cada passagem desta decisão.
    """
    bx, by = p(mx, my, ALT_CAIS)
    # ⚠️ ALTA O BASTANTE PARA PASSAR O MURO (quarta foto: «moitas pouco
    # visíveis»). Na frente da casa o muro tapava-a inteira; no quintal do lado
    # o muro da divisa +my, que sai depois dela, tapa-lhe só o pé — é o
    # encaixe certo, a moita por trás do muro e a copa florida por cima dele.
    raio = 0.10 * MEIA_LARG
    canto = _lobo(bx, by - raio * 1.05, raio, raio * 0.72, r)
    s = com_saia(canto, raio * 0.75, C["copa"])
    for k in range(5):
        ang = math.radians(20 + 70 * k + r.uniform(-12, 12))
        fx = bx + math.cos(ang) * raio * 0.58
        fy = by - raio * 1.12 + math.sin(ang) * raio * 0.32
        s += ('  <ellipse cx="%.1f" cy="%.1f" rx="2.1" ry="1.7" fill="%s"/>\n'
              % (fx, fy, C[flor]))
    return s


# ── OS TRÊS LOTES QUE NÃO SÃO CASA ───────────────────────────────────────
#
# Item 12 do segundo playtest: *"modelos de prédio em reforma e construção,
# assim como edifícios mais avançados, como casas de dois andares, comércios
# variados, pracinha, igreja e etc, para irem aparecendo à medida que o porto
# cresce"*.
#
# ⚠️ O ÂMBITO FOI DECIDIDO POR MEDIÇÃO, e ele diz não a uma parte do pedido.
# O que sobrou está em `docs/decisoes/022`; o resumo é este:
#
#   · "casas de dois andares" JÁ EXISTEM — é o `--nivel-vila=2`, desde 04/09;
#   · "prédio em obra" NÃO pode ser um terceiro estado do armazém nem do
#     escritório, porque `comprar_estrutura()` é INSTANTÂNEO: desconta o caixa
#     e acrescenta à lista, sem duração nenhuma. Um estado "em obra" só existe
#     se a obra DURAR, e fazer a obra durar é mexer na vazão, que é a economia
#     medida. Na VILA, ao contrário, ele não custa mecânica nenhuma;
#   · "à medida que o porto cresce" ficaria caro e reabre decisão registada: a
#     vila é ASSADA no SVG de propósito, e troca entre FASES e não entre
#     turnos. O que ela ganha aqui é o INDICADOR que o pedido quer, por outro
#     caminho — a obra de um nível é desenhada com a altura do nível SEGUINTE,
#     de modo que a vila mostra o que vem a seguir em vez de só o que é.
#
# E a escala decidiu o desenho. Medido: uma casa tem 51 px de largura e 12 a
# 15 px de parede na tela, e 24 dos 34 lotes caem dentro do quadro. A essa
# escala não há detalhe nenhum a distinguir um comércio de uma casa — o que
# distingue é a SILHUETA, que é a mesma lição do arrasteiro e dos retratos. Daí
# os três que entraram serem os três que mudam a forma: um lote SEM TELHADO
# (obra), um lote com uma VERTICAL (igreja) e um lote SEM CASA (praça).


def _cone(cx, cy, raio, base, altura, cor, cor_sombra) -> str:
    """Um monte cónico: os dois meios-cones que a câmera vê, luz e sombra.

    O arco da frente vai de −45° a 135° em planta — os dois pontos onde a
    elipse da base é mais larga na tela —, e é por eles que passa a orla do
    monte. O meio que olha para +my leva a luz, o que olha para +mx a sombra,
    como as paredes.
    """
    def arco(a0, a1):
        n = 8
        return [p(cx + raio * math.cos(math.radians(a0 + (a1 - a0) * k / n)),
                  cy + raio * math.sin(math.radians(a0 + (a1 - a0) * k / n)), base)
                for k in range(n + 1)]
    topo = p(cx, cy, base + altura)
    return poli([topo] + arco(-45.0, 45.0), cor_sombra) \
        + poli([topo] + arco(45.0, 135.0), cor)


# ⚠️ A OBRA RECUA DA FRENTE DO LOTE para o material caber à frente dela. Entre
# a frente da casa e o passeio há poucos centésimos, e do lado das vizinhas o
# monte cairia debaixo do quintal da casa seguinte, que é desenhado depois e a
# meia opacidade por cima dele. Na frente do próprio lote ele é o primeiro
# plano da obra, que é onde um canteiro de verdade o deixa.
OBRA_RECUO_DA_FRENTE = 0.22


def geometria_da_obra(mx0, my0, mx1, my1) -> tuple:
    """A planta do prédio por acabar dentro do lote: o desenho e a prova."""
    return mx0, my0, mx1 - OBRA_RECUO_DA_FRENTE, my1


def _sem_telhado(mx0, my0, mx1, my1, altura) -> str:
    """O prédio EM OBRA: laje, pilares, o piso de cima, tijolo e andaime.

    ⚠️ A COR DA ESTRUTURA NÃO É CINZENTA, E ISSO FOI MEDIDO CONTRA O FUNDO.
    Concreto pede um cinzento, e todo cinzento desta paleta cai na banda de um
    dos dois quintais: o mapa pavimentado desenhava `terra_clara` (lum 141) e o
    outro `terra_escura` (lum 104) — desde a `136` são ambos a escura —, e
    `pedra_clara` mede **0,05 de Weber** sobre o primeiro — some — enquanto
    `pedra_media` fica em 0,18 e 0,12, fraca nos dois. É a regra do gancho do pau-de-carga: um prop atravessa dois fundos e
    nenhum tom do meio ganha os dois. O creme mede 0,64 e 1,24, e laje de
    concreto novo é mesmo clara.

    E o que separa isto das CASAS não é a cor, que é a mesma — é não ter
    telhado. Numa fileira de telhas, o lote sem telha é o que salta, e essa
    leitura sobrevive a qualquer escala. É a regra da ruína com o sinal
    trocado: ali menos prédio era abandono, aqui é prédio por acabar.

    ⚠️ E ATÉ À `123` ERA SÓ ESQUELETO, e lia como uma GAIOLA creme. O que faz
    obra brasileira é o TIJOLO À MOSTRA: as paredes do térreo levantadas pela
    metade, de alturas diferentes, entre os pilares claros. O tijolo não se
    separa do quintal pelo valor — separa-se pelo matiz, como a telha —, e
    dentro da peça quem o desenha é o creme dos pilares e da laje à volta.
    """
    mx_lote = mx1
    mx0, my0, mx1, my1 = geometria_da_obra(mx0, my0, mx1, my1)
    laje = 3.0
    pilar = (mx1 - mx0) * 0.14
    meia = ALT_CAIS + laje + (altura - laje) * 0.52
    s = _faixa_mx(mx0 - 0.10, mx_lote + 0.04, my0 - 0.10, my1 + 0.10,
                  C["terra_escura"], 0.55)
    s += sombra_de_volume(mx0, my0, mx1, my1, meia - ALT_CAIS)
    # A laje do térreo, e a do piso de cima meio metro abaixo do topo: são as
    # duas horizontais que dizem "isto vai ter andares".
    s += caixa(mx0, my0, mx1, my1, ALT_CAIS, laje,
               C["casa_a"], _sombrear(C["casa_a"], 0.80),
               _sombrear(C["casa_a"], 0.91))
    cantos = ((mx0, my0), (mx0, my1 - pilar), (mx1 - pilar, my0),
              (mx1 - pilar, my1 - pilar))

    def pilar_em(x0, y0):
        return caixa(x0, y0, x0 + pilar, y0 + pilar, ALT_CAIS + laje,
                     altura - laje, C["casa_a"],
                     _sombrear(C["casa_a"], 0.78), _sombrear(C["casa_a"], 0.89))

    # Os três pilares de trás primeiro; o da frente sai depois do tijolo, que
    # fica um nada recuado do plano dos pilares para eles o emoldurarem.
    for x0, y0 in cantos[:3]:
        s += pilar_em(x0, y0)
    chao = ALT_CAIS + laje
    andar = meia - chao
    recuo = 0.02
    # A face +my (a da luz) e a +mx (a da sombra), cada uma em dois panos de
    # alturas diferentes: parede inteira de um lado, meia do outro. A parede
    # por acabar é a que não tem a mesma altura de ponta a ponta.
    xa, xb = mx0 + pilar, mx1 - pilar
    xm = xa + (xb - xa) * 0.55
    s += face_my(my1 - recuo, xa, xm, chao, meia, _sombrear(C["tijolo"], 0.94))
    s += face_my(my1 - recuo, xm, xb, chao, chao + andar * 0.50,
                 _sombrear(C["tijolo"], 0.94))
    ya, yb = my0 + pilar, my1 - pilar
    ym = ya + (yb - ya) * 0.45
    s += face_mx(mx1 - recuo, ya, ym, chao, chao + andar * 0.70,
                 _sombrear(C["tijolo"], 0.80))
    s += face_mx(mx1 - recuo, ym, yb, chao, meia, _sombrear(C["tijolo"], 0.80))
    # A ARGAMASSA: duas fiadas escuras a um terço e a dois terços do andar,
    # cortadas na altura de cada pano. É o que diz «parede de tijolo» e não
    # «parede laranja», e corta-se no pano porque a fiada acima da parede
    # meia pairaria no ar.
    for k in (1.0 / 3.0, 2.0 / 3.0):
        z = chao + andar * k
        for a0, a1, topo_pano in ((xa, xm, meia), (xm, xb, chao + andar * 0.50)):
            if z + 0.8 < topo_pano:
                s += face_my(my1 - recuo, a0, a1, z, z + 0.8,
                             _sombrear(C["tijolo"], 0.70))
        for a0, a1, topo_pano in ((ya, ym, chao + andar * 0.70), (ym, yb, meia)):
            if z + 0.8 < topo_pano:
                s += face_mx(mx1 - recuo, a0, a1, z, z + 0.8,
                             _sombrear(C["tijolo"], 0.58))
    s += pilar_em(*cantos[3])
    s += caixa(mx0, my0, mx1, my1, meia, 2.2,
               C["casa_a"], _sombrear(C["casa_a"], 0.80),
               _sombrear(C["casa_a"], 0.91))
    # O ANDAIME, nas duas faces visíveis. Escuro de propósito: `tronco` mede
    # 0,48 e 0,30 sobre os dois quintais, e é o par claro/escuro dentro da
    # própria peça que a faz ler como estrutura em vez de caixa branca.
    #
    # ⚠️ E ELE VAI NAS DUAS FACES VISÍVEIS, com travessa grossa. A primeira
    # versão punha três travessas finas só em `+my`, e a 4x de ampliação a
    # peça lia-se lindamente enquanto na captura a 1x era uma CAIXA CREME: o
    # creme ganha do fundo (0,64 e 1,24 de Weber) mas não se separa das casas
    # vizinhas, que são do mesmo creme. É a regra do armazém — a esta escala
    # quem separa não é o tom, é a linha escura —, e uma linha escura numa só
    # das duas faces é meia linha.
    topo = ALT_CAIS + laje + (altura - laje)
    for k in range(3):
        z = ALT_CAIS + laje + (altura - laje) * (0.18 + 0.36 * k)
        if z < topo - 1.4:
            s += face_my(my1 + 0.06, mx0 - 0.04, mx1 + 0.04, z, z + 2.0,
                         C["tronco"])
            s += face_mx(mx1 + 0.06, my0 - 0.04, my1 + 0.04, z, z + 2.0,
                         C["tronco"])
    for x in (mx0 + (mx1 - mx0) * 0.20, mx0 + (mx1 - mx0) * 0.74):
        s += face_my(my1 + 0.06, x, x + 0.07, ALT_CAIS + laje, topo,
                     C["tronco"])
    for y in (my0 + (my1 - my0) * 0.24, my0 + (my1 - my0) * 0.76):
        s += face_mx(mx1 + 0.06, y, y + 0.07, ALT_CAIS + laje, topo,
                     C["tronco"])
    # O MATERIAL, à frente: um monte de areia e uma pilha de tijolos. O monte
    # é mais íngreme do que o real pela razão da brita do pátio (`122`): na
    # rampa real a câmera achata-o num disco claro.
    dmy = my1 - my0
    s += _cone(mx1 + 0.11, my0 + dmy * 0.30, 0.10, ALT_CAIS, 7.0,
               C["areia"], C["areia_face"])
    s += caixa(mx1 + 0.04, my0 + dmy * 0.60, mx1 + 0.18, my0 + dmy * 0.84,
               ALT_CAIS, 3.5, _sombrear(C["tijolo"], 1.08),
               _sombrear(C["tijolo"], 0.80), _sombrear(C["tijolo"], 0.94))
    return s


# ⚠️ ERA 0,20 e o adro lia como uma faixa (quarta foto: «adro da igreja
# pequeno»); a 0,35 cabem os dois bancos e o poste.
IGREJA_ADRO = 0.35


def geometria_da_igreja(mx0, my0, dmx, dmy, altura) -> dict:
    """Onde fica cada peça da igreja, num lugar só.

    Quem a lê são três: o desenho (`_igreja`), a prova do D24
    (`pontos_de_prova`) e a guarda de que a torre cabe no quadro
    (`conferir_a_torre_cabe`). Até à `123` cada um refazia a conta da torre
    por si, e a mesma conta escrita três vezes é a que um dia sai diferente.
    """
    # ⚠️ ERA 0,36 DO LOTE e lia fina contra a nave na primeira foto (`123`);
    # a 0,44 ela pesa mais do que a empena que tapa, sem passar a ser um bloco.
    larg = min(dmx, dmy) * 0.44
    mx1, my1 = mx0 + dmx, my0 + dmy
    # A TORRE FICA TODA À FRENTE DA NAVE, no eixo da fachada. Enfiada metade
    # na nave, como nas igrejas grandes, a ordem de desenho deixava de ser
    # uma só: a face +my da torre ficava atrás da empena numa altura e à frente
    # dela noutra. À frente, a torre tapa a empena no meio e sobram dois
    # triângulos brancos dos dois lados, que é a silhueta que se pediu.
    # ⚠️ E ELA RECUA `IGREJA_ADRO` DA FRENTE DO LOTE (terceira foto da `123`,
    # «igreja colada na rua»): o adro de calçada fica à frente da porta, e a
    # nave estende-se para o quintal de trás o que perdeu na frente.
    tx0, tx1 = mx1 - IGREJA_ADRO - larg, mx1 - IGREJA_ADRO
    meio = (my0 + my1) / 2.0
    ty0, ty1 = meio - larg / 2.0, meio + larg / 2.0
    nave = (mx0 - 0.14, my0 + dmy * 0.14, tx0, my1 - dmy * 0.14)
    alt_nave = altura * 1.3
    # E A TORRE SOBE TRÊS VEZES A PAREDE DE UMA CASA. Medido no render de
    # 13/09: a 2,0 ela assomava 14 px acima do beiral, que à escala desta vila
    # é a altura de um telhado — não se lê como vertical, lê-se como saliência.
    alt_torre = altura * 3.0
    cornija = 2.0
    alt_piramide = altura * 0.75
    z_base_piramide = ALT_CAIS + alt_torre + cornija
    folga = larg * 0.08                  # o beiral da pirâmide sobre a cornija
    piramide = (tx0 - folga, ty0 - folga, tx1 + folga, ty1 + folga)
    apice = ((tx0 + tx1) / 2.0, meio, z_base_piramide + alt_piramide)
    # A CRUZ MEDE-SE EM FRAÇÕES DA TORRE (`mapa.md`: a de 13/09 media-se em
    # unidades de mundo e saiu mais larga do que o campanário).
    cruz = 6.0
    return {"larg": larg, "torre": (tx0, ty0, tx1, ty1), "nave": nave,
            "alt_nave": alt_nave, "alt_torre": alt_torre, "cornija": cornija,
            "piramide": piramide, "z_piramide": z_base_piramide,
            "apice": apice, "cruz": cruz,
            "topo": apice[2] + cruz + 1.0}


def _piramide(x0, y0, x1, y1, base, apice, cor) -> str:
    """Quatro águas que se encontram num ponto: o telhado da torre."""
    a = apice
    tras_my = [(x0, y0, base), (x1, y0, base), a]
    tras_mx = [(x0, y0, base), a, (x0, y1, base)]
    frente_mx = [(x1, y0, base), (x1, y1, base), a]
    frente_my = [(x0, y1, base), a, (x1, y1, base)]
    s = ""
    for pano, fator in ((tras_my, 0.84), (tras_mx, 0.95),
                        (frente_mx, 0.74), (frente_my, 1.0)):
        s += poli([p(*q) for q in pano], cor if fator == 1.0 else _sombrear(cor, fator))
    return s


def _igreja(mx0, my0, mx1, my1, altura) -> str:
    """A igreja de vila: a nave de duas águas e a torre no eixo da fachada.

    ⚠️ QUEM FAZ O TRABALHO É A VERTICAL, e a nave quase não conta. A 51 px de
    largura de lote não há vitral nem portão que se leiam; o que se lê numa
    fileira de telhados deitados é uma coisa DE PÉ. Até à `123` a torre era
    uma caixa com um remate cinzento por cima, e o remate lia como caixa-
    -d'água; agora acaba numa pirâmide de barro escuro com a cruz, e a nave
    vira a empena branca para a avenida, a aparecer dos dois lados da torre.
    """
    g = geometria_da_igreja(mx0, my0, mx1 - mx0, my1 - my0, altura)
    nx0, ny0, nx1, ny1 = g["nave"]
    tx0, ty0, tx1, ty1 = g["torre"]
    branco = C["caiacao"]
    b_dir, b_esq = _sombrear(branco, 0.80), _sombrear(branco, 0.91)
    s = sombra_de_volume(nx0, ny0, nx1, ny1, g["alt_nave"])
    s += sombra_de_volume(tx0, ty0, tx1, ty1, g["alt_torre"])
    # A NAVE, e o telhado dela em duas águas com a cumeeira para a avenida.
    s += caixa(nx0, ny0, nx1, ny1, ALT_CAIS, g["alt_nave"], branco, b_dir, b_esq)
    # Duas janelas altas e estreitas no flanco que se vê: é o ritmo de nave.
    for k in (0.25, 0.62):
        x = nx0 + (nx1 - nx0) * k
        s += face_my(ny1, x, x + 0.07, ALT_CAIS + g["alt_nave"] * 0.35,
                     ALT_CAIS + g["alt_nave"] * 0.75, C["vidro"])
    t = ALT_CAIS + g["alt_nave"]
    e = 0.07
    ym = (ny0 + ny1) / 2.0
    h = (ny1 - ny0) * TELHADO_SUBIDA * 1.3
    telha = C["telha_a"]
    # ⚠️ O PANO −my PARTE-SE NA EMPENA. A parte de trás dele fica atrás da
    # empena e tem de sair antes dela; a tira do beiral, à frente da empena,
    # sai depois — senão a empena come a borda do telhado do lado da sombra.
    pano_tras = lambda xa, xb: poli([p(xa, ny0 - e, t), p(xb, ny0 - e, t),
                                     p(xb, ym, t + h), p(xa, ym, t + h)],
                                    _sombrear(telha, 0.84))
    s += pano_tras(nx0 - e, nx1)
    s += poli([p(nx1, ny0, t), p(nx1, ny1, t), p(nx1, ym, t + h)], b_dir)
    s += pano_tras(nx1, nx1 + e)
    s += poli([p(nx0 - e, ny1 + e, t), p(nx1 + e, ny1 + e, t),
               p(nx1 + e, ym, t + h), p(nx0 - e, ym, t + h)], telha)
    # A TORRE, à frente da empena: a porta da igreja é a dela, e o vão do sino
    # é o furo escuro no alto que diz torre e não poste.
    at = g["alt_torre"]
    s += caixa(tx0, ty0, tx1, ty1, ALT_CAIS, at, branco, b_dir, b_esq)
    larg = g["larg"]
    s += face_mx(tx1, ty0 + larg * 0.28, ty1 - larg * 0.28,
                 ALT_CAIS, ALT_CAIS + g["alt_nave"] * 0.50, C["porta"])
    for face in ("mx", "my"):
        z0, z1 = ALT_CAIS + at * 0.76, ALT_CAIS + at * 0.92
        if face == "mx":
            s += face_mx(tx1, ty0 + larg * 0.26, ty1 - larg * 0.26, z0, z1, C["porta"])
        else:
            s += face_my(ty1, tx0 + larg * 0.26, tx1 - larg * 0.26, z0, z1, C["porta"])
    # A cornija, um nada mais larga do que o fuste, e a pirâmide por cima.
    c = larg * 0.05
    s += caixa(tx0 - c, ty0 - c, tx1 + c, ty1 + c, ALT_CAIS + at, g["cornija"],
               branco, b_dir, b_esq)
    s += _piramide(*g["piramide"], g["z_piramide"], g["apice"], C["telha_torre"])
    # A CRUZ, e ela são dois traços. Não se "lê" a esta escala — o que faz é
    # quebrar o topo, e um topo quebrado não é chaminé.
    ax, ay, az = g["apice"]
    w = larg * 0.07
    s += caixa(ax - w / 2, ay - w / 2, ax + w / 2, ay + w / 2, az - 1.0,
               g["cruz"] + 1.0, C["tronco"], _sombrear(C["tronco"], 0.8),
               _sombrear(C["tronco"], 0.9))
    s += caixa(ax - w / 2, ay - larg * 0.18, ax + w / 2, ay + larg * 0.18,
               az + g["cruz"] * 0.55, 1.2, C["tronco"],
               _sombrear(C["tronco"], 0.8), _sombrear(C["tronco"], 0.9))
    return s


def _banco(x0, y0, x1, y1) -> str:
    """Um banco de praça: o assento de madeira e o encosto do lado de trás.

    O encosto vai para o lado −mx ou −my (o mais comprido diz qual), que é o
    que fica atrás de quem se senta virado para a câmera.
    """
    cor = C["tronco"]
    s = caixa(x0, y0, x1, y1, ALT_CAIS, 2.2, _sombrear(cor, 1.25),
              _sombrear(cor, 0.80), _sombrear(cor, 0.95))
    if x1 - x0 >= y1 - y0:
        e = (x0, y0, x1, y0 + 0.018)
    else:
        e = (x0, y0, x0 + 0.018, y1)
    s += caixa(*e, ALT_CAIS + 2.2, 2.6, _sombrear(cor, 1.10),
               _sombrear(cor, 0.80), _sombrear(cor, 0.95))
    return s


def _poste(x, y, alt=16.0) -> str:
    """O poste de luz: o fuste escuro e a luminária amarela no topo."""
    l = 0.022
    s = caixa(x - l, y - l, x + l, y + l, ALT_CAIS, alt, C["poste"],
              _sombrear(C["poste"], 0.80), _sombrear(C["poste"], 0.91))
    s += caixa(x - 0.045, y - 0.045, x + 0.045, y + 0.045, ALT_CAIS + alt, 2.4,
               C["luminaria"], _sombrear(C["luminaria"], 0.85),
               _sombrear(C["luminaria"], 0.93))
    return s


def _octogono(cx, cy, raio) -> list:
    """Os oito vértices em planta, com um lado virado para cada eixo."""
    return [(cx + raio * math.cos(math.radians(22.5 + 45.0 * k)),
             cy + raio * math.sin(math.radians(22.5 + 45.0 * k)))
            for k in range(8)]


def geometria_do_coreto(mx0, my0, mx1, my1) -> dict:
    """O coreto da praça: o desenho e a prova do D24 leem daqui."""
    cx, cy = (mx0 + mx1) / 2.0, (my0 + my1) / 2.0
    # ⚠️ A 0,17 DO LOTE ELE LIA, MAS ERA A PEÇA MENOR DA PRAÇA (primeira foto
    # da `123`, «coreto ainda pequeno»); todo ele cresce ~25%, e o largo do
    # meio cresce com ele, porque o chanfro dos canteiros sai do beiral.
    raio = min(mx1 - mx0, my1 - my0) * 0.21
    base = 3.0
    pilar = 12.5
    beiral = raio * 1.18
    z_telhado = ALT_CAIS + base + pilar
    apice = (cx, cy, z_telhado + 10.0)
    return {"centro": (cx, cy), "raio": raio, "base": base, "pilar": pilar,
            "beiral": beiral, "z_telhado": z_telhado, "apice": apice}


def _faces_do_telhado_do_coreto(g) -> list:
    """(pontos, normal em planta, fator de luz) de cada água do telhado.

    ⚠️ DUAS ÁGUAS FICAM DE PERFIL À CÂMERA — as de normal a 135° e a 315°, que
    a projeção achata numa linha —, e `cos + sin` delas dá ±1e-16 em vez de
    zero. Decidir frente e trás por `> 0` punha-as de um lado ou do outro ao
    sabor do arredondamento, e a prova do D24, que procura a água pura mais
    virada para +my, escolhia justamente a de 135°. A folga as põe atrás.
    """
    cx, cy = g["centro"]
    v = _octogono(cx, cy, g["beiral"])
    faces = []
    for k in range(8):
        a, b = v[k], v[(k + 1) % 8]
        ang = math.radians(45.0 * (k + 1))      # a normal do lado k em planta
        nx, ny = math.cos(ang), math.sin(ang)
        if nx + ny <= 1e-6:
            fator = 0.86                        # de costas, ou de perfil
        elif ny >= nx - 1e-6:
            fator = 1.0                         # a luz, como a parede +my
        else:
            fator = 0.74
        faces.append(([(a[0], a[1], g["z_telhado"]), (b[0], b[1], g["z_telhado"]),
                       g["apice"]], (nx, ny), fator))
    return faces


PRACA_LARGURA_MIN = 1.05


def planta_da_praca(mx0, my0, dmx, dmy) -> tuple:
    """O retângulo da praça: o lote, alargado para o vão livre da esquina.

    A praça só cai em esquina (`lotes_especiais`), com pelo menos 0,7 livre do
    lado +my; um lote estreito alarga até `PRACA_LARGURA_MIN` para esse lado,
    e o coreto, que se mede pelo lado menor, não encolhe com ele. O desenho e
    a prova do D24 leem daqui.
    """
    return mx0, my0, mx0 + dmx, my0 + max(dmy, PRACA_LARGURA_MIN)


def _pracinha(mx0, my0, mx1, my1, r: random.Random) -> str:
    """A praça: o lote em que NÃO há casa.

    Numa frente de rua contínua o buraco é que chama o olho — a mesma razão de
    a travessa dar esquina à vila. ⚠️ ATÉ À `123` ELA LIA COMO ESTACIONAMENTO:
    calçada cinzenta de borda a borda e um coreto de telhado quadrado que, a
    51 px de lote, era uma garagem. O que diz praça é o VERDE: os quatro
    quadrantes viram canteiros de grama, a calçada fica só nos caminhos em cruz
    e na borda, e o coreto passa a octogonal, branco, com telhado pontudo.
    """
    # ⚠️ O CHÃO É CALÇADA, E NÃO TERRA. A primeira versão usava `solo_claro`,
    # que é a cor certa para um terreno e a errada para se VER: ele mede
    # **0,07 de Weber** contra o `terra_clara` do quintal onde a praça pousa —
    # some, exatamente como o gancho do pau-de-carga sobre o baixio. `calcada`
    # mede 0,30 sobre esse quintal, 0,76 sobre o do mapa não pavimentado e
    # 0,52 sobre o relvado à volta: ganha os três. E não é cor nova nenhuma —
    # é o mesmo material do passeio da rua, que é o que uma praça tem mesmo.
    # ⚠️ E ELA LEVA MEIO-FIO, porque o piso dela é a MESMA calçada do passeio.
    # Medido na captura: sem ele a praça e o passeio da rua eram um bloco claro
    # contínuo, e o que devia ler como um vão na frente de rua lia como um
    # alargamento do passeio. E ele é o `meiofio` da rua, não um tom novo.
    # O piso vai até à linha do muro das vizinhas, e não mais: até à `123`
    # passava 0,30 da frente do lote, por cima do passeio da rua.
    x0, x1 = mx0 - 0.20, mx1 + VILA_QUINTAL_FRENTE
    y0, y1 = my0 - 0.25, my1 + 0.25
    s = _faixa_mx(x0 - 0.06, x1 + 0.06, y0 - 0.06, y1 + 0.06, C["meiofio"], 1.0)
    s += _faixa_mx(x0, x1, y0, y1, C["calcada"], 1.0)
    # OS CANTEIROS: um por quadrante, com a borda de calçada à volta e os dois
    # caminhos em cruz entre eles. A quina de cada um que dá para o meio é
    # chanfrada, e o que sobra no centro é o largo redondo do coreto.
    g = geometria_do_coreto(mx0, my0, mx1, my1)
    cx, cy = g["centro"]
    borda, caminho = 0.10, 0.09
    chanfro = g["beiral"] * 1.25
    for qx0, qx1 in ((x0 + borda, cx - caminho), (cx + caminho, x1 - borda)):
        for qy0, qy1 in ((y0 + borda, cy - caminho), (cy + caminho, y1 - borda)):
            pts = [(qx0, qy0), (qx1, qy0), (qx1, qy1), (qx0, qy1)]
            # A quina do meio é a mais perto do centro; ela dá lugar a duas,
            # cada uma recuada `chanfro` ao longo do lado que lá chega.
            i = min(range(4), key=lambda k: math.hypot(pts[k][0] - cx, pts[k][1] - cy))
            q = pts[i]
            novos = []
            for viz in (pts[i - 1], pts[(i + 1) % 4]):
                d = math.hypot(viz[0] - q[0], viz[1] - q[1])
                f = min(chanfro, d * 0.6) / d
                novos.append((q[0] + (viz[0] - q[0]) * f, q[1] + (viz[1] - q[1]) * f))
            pts[i:i + 1] = novos
            s += _chao(pts, C["gramado"])
    # ⚠️ AS ÁRVORES VÃO PARA AS QUINAS, e não sorteadas pelo lote. Sorteadas,
    # duas das três calharam em cima do coreto e taparam-no: o contador dizia
    # quatro peças e o render mostrava três, que é a boia com a corrente dentro
    # do cone outra vez. Numa praça pequena o meio é do coreto; o resto é dela.
    # ⚠️ E ELAS FICAM NA BORDA DO PISO, NÃO DENTRO DELE. Nas quinas a 0,06 a
    # copa cobria o quadrante inteiro — a praça tinha piso e não se via piso
    # nenhum, que é a boia com a corrente dentro do cone à escala de um lote.
    # Na borda a copa transborda para o quintal, como as árvores da vila já
    # fazem, e o piso fica livre no meio.
    # E são TRÊS, não quatro. Medido no raster: com uma copa em cada quina, o
    # piso da praça aparecia só em manchas — 142 pixels soltos num lote de
    # 51x47 —, e o ponto que o D24 mede calhava debaixo de uma delas. A copa
    # projeta-se para cima e para trás e cobre muito mais chão do que a planta
    # dela sugere; é a mesma conta que mandou as árvores da vila para o quintal.
    # ⚠️ AS ÁRVORES SAEM ANTES DO CORETO. Até à `123` as três saíam no fim, e
    # a de trás — que fica atrás dele e cresce para cima na tela — pintava-se
    # por cima do telhado (segunda foto da `123`). O `r` gasta-se na mesma
    # ordem de sempre — as mesmas chamadas, as mesmas três árvores —, porque é
    # o das árvores da vila.
    # ⚠️ E DESDE A QUINTA PASSAGEM ELAS FICAM NAS DUAS BORDAS DE TRÁS, longe
    # dos postes («praça sem movimento» pôs um poste por quina, e árvore e
    # poste juntos eram um poste dentro de uma copa). Todas atrás do meio da
    # praça, e saem antes do coreto.
    frente = ""
    for qx, qy in ((-0.12, 0.76), (0.13, -0.12), (0.72, -0.12)):
        if r.random() < 0.85:
            s += arvore_da_cidade(mx0 + (mx1 - mx0) * qx + r.uniform(-0.04, 0.04),
                        my0 + (my1 - my0) * qy + r.uniform(-0.05, 0.05),
                        r.uniform(0.24, 0.34), r, r.random(), sem_ipe=True)
    # OS QUATRO POSTES e os DOIS BANCOS nos caminhos, virados para o coreto:
    # os de trás antes dele, os da frente depois.
    # ⚠️ AS QUINAS DE CIMA E DE BAIXO ESTÃO NO EIXO DO CORETO NA TELA — numa
    # praça quase quadrada o coreto e essas duas quinas caem na mesma coluna
    # (`mx − my`) —, e o poste da quina da frente atravessava-lhe a entrada.
    # Esses dois correm 38% ao longo da borda; os das quinas dos lados ficam.
    q = 0.07
    larg = y1 - y0
    s += _poste(x0 + q, y0 + larg * 0.38) + _poste(x0 + q, y1 - q)
    frente += _banco(cx + caminho + 0.10, cy + caminho + 0.03,
                     cx + caminho + 0.30, cy + caminho + 0.08)
    frente += _banco(cx - caminho - 0.08, cy + caminho + 0.10,
                     cx - caminho - 0.03, cy + caminho + 0.30)
    frente += _poste(x1 - q, y0 + q) + _poste(x1 - q, y1 - larg * 0.38)
    # O CORETO: plataforma, oito pilares e o telhado de oito águas.
    s += sombra_de_volume(cx - g["beiral"], cy - g["beiral"],
                          cx + g["beiral"], cy + g["beiral"], g["base"] + g["pilar"])
    oct_ = _octogono(cx, cy, g["raio"])
    zb = ALT_CAIS + g["base"]
    branco = C["casa_a"]
    for k in range(8):
        a, b = oct_[k], oct_[(k + 1) % 8]
        ang = math.radians(45.0 * (k + 1))
        nx, ny = math.cos(ang), math.sin(ang)
        if nx + ny > 1e-6:                   # os lados que olham para a câmera;
            # os dois de perfil dão ±1e-16 e um polígono sem área (ver o telhado)
            s += poli([p(a[0], a[1], zb), p(b[0], b[1], zb),
                       p(b[0], b[1], ALT_CAIS), p(a[0], a[1], ALT_CAIS)],
                      _sombrear(branco, 0.80 if nx > ny else 0.91))
    s += poli([p(x, y, zb) for x, y in oct_], branco)
    lado = 0.035
    pilares = sorted(_octogono(cx, cy, g["raio"] * 0.86), key=lambda q: q[0] + q[1])
    for px_, py_ in pilares:
        s += caixa(px_ - lado, py_ - lado, px_ + lado, py_ + lado, zb, g["pilar"],
                   branco, _sombrear(branco, 0.78), _sombrear(branco, 0.89))
    faces = _faces_do_telhado_do_coreto(g)
    telha = C["telha_d"]
    # As de trás primeiro, depois as da frente da mais funda para a mais perto:
    # numa pirâmide convexa é a ordem que basta.
    for pts, _n, fator in sorted(faces, key=lambda f: (f[2] != 0.86,
                                                     math.fsum(q[0] + q[1] for q in f[0]))):
        s += poli([p(*q) for q in pts], telha if fator == 1.0 else _sombrear(telha, fator))
    s += frente
    return s


# ⚠️ QUEM É ESPECIAL ESCOLHE-SE ENTRE OS LOTES VISÍVEIS, e não entre todos.
#
# É a lição das 136 copas de mata com 7 dentro do quadro, aplicada a uma peça
# de que só há UMA: sorteada entre os 34 lotes, a igreja tinha 29% de hipótese
# de nascer fora do PNG — gerada, a passar em toda a validação, e por olhar.
# Medido, 24 dos 34 estão dentro; a escolha corre só sobre esses, e o bloco
# **D24** do teste de design exige que os três cheguem à tela.
#
# A igreja e a praça vão para a fileira da FRENTE, que é a que se vê inteira;
# as obras, uma em cada fileira, porque uma cidade não cresce só na beira.
def _vaos_do_lote(lotes: list, i: int) -> tuple:
    """O vão até à vizinha da mesma fileira, de cada lado (−my, +my)."""
    _x, my0, _dx, dmy, _v, fundo, _c = lotes[i]
    esq, dir_ = math.inf, math.inf
    for j, o in enumerate(lotes):
        if j == i or o[5] != fundo:
            continue
        if o[1] + o[3] <= my0 + 1e-9:
            esq = min(esq, my0 - (o[1] + o[3]))
        elif o[1] >= my0 + dmy - 1e-9:
            dir_ = min(dir_, o[1] - (my0 + dmy))
    return esq, dir_


def lotes_especiais(lotes: list) -> dict:
    # ⚠️ LOTE COLADO À VIZINHA NÃO É ESPECIAL (`123`). Quando o casario de
    # platibanda encostava (a primeira passagem), a escolha pôs a praça no meio
    # de uma fieira — com a fachada da vizinha a tapar meio coreto — e uma obra
    # com uma parede partilhada que ela não tem. O nível 1 já não encosta, e a
    # guarda fica para o dia em que alguma forma voltar a encostar.
    soltos = {i for i in range(len(lotes)) if min(_vaos_do_lote(lotes, i)) > 0.02}
    visiveis = [i for i, l in enumerate(lotes)
                if i in soltos
                and no_quadro(l[0] + l[2] / 2.0, l[1] + l[3] / 2.0, folga=0.0)]
    frente = [i for i in visiveis if not lotes[i][5]]
    fundo = [i for i in visiveis if lotes[i][5]]
    r = random.Random(SEMENTE_CHAO + 420)
    especiais = {}
    if frente:
        # A igreja no MEIO da frente visível, e não sorteada: ela é a peça mais
        # alta da vila, e o meio é o único sítio onde se tem a certeza de que a
        # torre não assoma meio cortada pela borda do quadro.
        # ⚠️ E NUM LOTE LARGO (`123`): com as casas de larguras diferentes, o
        # do meio podia ser o de uma casinha de empena, de 0,64, e a nave não
        # cabia ao lado da torre. É o largo mais perto do meio.
        meio = len(frente) // 2
        largos = [k for k, i in enumerate(frente) if lotes[i][3] >= 1.0] or [meio]
        especiais[frente[min(largos, key=lambda k: abs(k - meio))]] = "igreja"
    livres = [i for i in frente if i not in especiais]
    if livres:
        # A PRAÇA NA ESQUINA, quando há: no fim do quarteirão, com a travessa do
        # lado +my, nenhuma casa à frente dela lhe tapa o coreto — a casa que o
        # tapava ficava desse lado, e é a altura dela que se projeta por cima.
        # E BEM DENTRO DO QUADRO: a primeira esquina que este critério achou
        # ficava a 23 px do topo, com o coreto a assomar para fora dele.
        # ⚠️ E A ESQUINA É EXIGÊNCIA, não preferência: a segunda foto ainda a
        # mostrou apertada contra uma vizinha a 0,45 («praça apertada»), que
        # era o recurso quando faltava esquina bem dentro do quadro. O que se
        # relaxa primeiro é o quadro, nunca o vão +my de quase um metro.
        # ⚠️ E A ESQUINA PODE SER ESTREITA (terceira foto: «praça muito na
        # borda»). Exigir lote largo deixava uma esquina só, colada à borda
        # esquerda; a praça alarga para o vão livre da esquina
        # (`planta_da_praca`), e entre as esquinas bem dentro do quadro fica a
        # mais perto da igreja — a praça da matriz, como numa vila de verdade.
        # A 0,7 de vão +my a vizinha ainda não chega ao coreto.
        esquinas = [i for i in livres if _vaos_do_lote(lotes, i)[1] >= 0.7]
        for folga in (-60.0, -20.0, 0.0):
            dentro = [i for i in esquinas
                      if no_quadro(lotes[i][0] + lotes[i][2] / 2.0,
                                   lotes[i][1] + lotes[i][3] / 2.0, folga=folga)]
            if dentro:
                break
        dentro = dentro or esquinas or livres
        igreja = [i for i, t in especiais.items() if t == "igreja"]
        if igreja:
            ix, iy = tela(lotes[igreja[0]][0], lotes[igreja[0]][1])
            dentro = sorted(dentro, key=lambda i: math.hypot(
                tela(lotes[i][0], lotes[i][1])[0] - ix,
                tela(lotes[i][0], lotes[i][1])[1] - iy))
        especiais[dentro[0]] = "praca"
    for grupo in (frente, fundo):
        candidatos = [i for i in grupo if i not in especiais]
        if candidatos:
            especiais[r.choice(candidatos)] = "obra"
    return especiais


# ⚠️ COM CACHE, E NÃO UMA LINHA DE MÓDULO. A primeira versão era
# `_tipos_publicados = lotes_especiais(lotes_da_vila())` aqui mesmo, e rebentou
# com `NameError`: esta função vive ACIMA de `lotes_da_vila` no arquivo, e no
# nível do módulo isso corre antes de ela existir. A função adiada resolve, e
# o cache é o que garante que a vila e a tabela de âncoras dizem o MESMO lote
# — com a semente fixa dariam o mesmo de qualquer forma, mas isso seria uma
# coincidência e não uma garantia.
_TIPOS_CACHE: dict = {}


def tipos_dos_lotes() -> dict:
    if not _TIPOS_CACHE:
        _TIPOS_CACHE.update(lotes_especiais(lotes_da_vila()))
    return _TIPOS_CACHE


# ⚠️ A TORRE É A PEÇA MAIS ALTA DA VILA, E ELA CRESCE COM O NÍVEL.
#
# Ela sobe três vezes a parede, e a parede vai de 20 px no nível 1 a 64 no
# nível 3 — ou seja, a torre passa de ~60 a ~192 px de desenho, mais o remate
# e a cruz. Em isométrico altura projeta-se para CIMA, então o que cabe no
# quadro hoje pode sair dele na Fase em que a vila subir, e sair do quadro não
# dá erro nenhum: dá uma torre decapitada que ninguém vê porque ninguém gera o
# nível 3 para olhar.
#
# Esta guarda corre a cada geração e percorre os TRÊS níveis, não só o que se
# está a gerar. É a mesma escolha do `gerar_props_iso.py`, que confere a
# própria projeção ao fim em vez de esperar que alguém repare.
def pontos_de_prova(nivel: int = 1) -> dict:
    """Por lote especial: onde olhar no PNG, e que cor lá tem de estar.

    ⚠️ EXISTE PARA O D24 NÃO SER UM ESPELHO. O teste podia recalcular a altura
    da torre e o topo da laje — e aí estaria a reconstruir a decisão que quer
    conferir, que é a armadilha do sorteio de motivos. Assim o gerador publica
    a INTENÇÃO ("no pixel (x, y) tem de estar o remate da igreja") e o teste
    pergunta ao RASTER o que lá ficou: se o desenho sair na ordem errada, se
    uma peça tapar a outra, ou se alguém trocar a cor, os dois deixam de bater.
    """
    lotes = lotes_da_vila()
    perfis = VILA_NIVEIS[min(nivel, max(VILA_NIVEIS))]
    saida = {}
    for i, tipo in tipos_dos_lotes().items():
        mx0, my0, dmx, dmy, variante, _fundo, _casa = lotes[i]
        altura = perfis[variante][0]
        # ⚠️ CADA PROVA TRAZ O SEU RAIO, e isto veio de dois defeitos injetados
        # que NÃO pegaram. Com um raio único de 12 px: tirar o campanário da
        # igreja passava, porque a janela ainda apanhava o remate 7 px abaixo;
        # e dar um telhado à obra passava também, porque à volta dela há creme
        # por todo o lado — a guarda satisfazia-se com o VIZINHO, que é a mesma
        # armadilha que já tinha obrigado a tirar a prova do piso da praça de
        # cima da calçada da rua. Uma peça de 18 px pede uma janela pequena;
        # uma laje de 50, uma grande.
        #
        # E a obra ganhou uma prova NEGATIVA: o que a define não é ter laje
        # creme (as casas também são cremes) — é NÃO TER TELHA por cima.
        if tipo == "igreja":
            # A pirâmide da torre, no barro escuro que só ela tem: é o que faz
            # a torre não ler como chaminé nem como caixa-d'água (`123`).
            # ⚠️ O PONTO MIRA A ÁGUA QUE A PROJEÇÃO MOSTRA EM TOM PURO, que é a
            # +my. A primeira prova desta igreja (13/09) apontava para metade da
            # altura do remate, que em isométrico cai na FACE lateral e não no
            # topo: o teste lia o tom sombreado e reprovava um desenho certo.
            # O baricentro do triângulo +my fica dentro dele por construção, e
            # longe da cruz, que nasce no ápice.
            g = geometria_da_igreja(mx0, my0, dmx, dmy, altura)
            x0, _y0, x1, y1 = g["piramide"]
            z = g["z_piramide"]
            bx = (x0 + x1 + g["apice"][0]) / 3.0
            by = (y1 + y1 + g["apice"][1]) / 3.0
            bz = (z + z + g["apice"][2]) / 3.0
            saida[i] = {"tipo": tipo, "cor": "telha_torre", "raio": 4, "minimo": 6,
                        "px": [round(c, 1) for c in tela(bx, by, bz)]}
        elif tipo == "obra":
            # O TOPO da obra é laje, não telhado — é isso que a faz ler como
            # prédio por acabar, e é a única coisa que a separa das vizinhas.
            # A planta é a da OBRA, que recua da frente do lote (`123`).
            ox0, oy0, ox1, oy1 = geometria_da_obra(mx0, my0, mx0 + dmx, my0 + dmy)
            saida[i] = {"tipo": tipo, "cor": "casa_a", "raio": 10, "minimo": 40,
                        "proibidas": ["telha_a", "telha_b", "telha_c", "telha_d"],
                        "px": [round(c, 1) for c in tela((ox0 + ox1) / 2.0,
                                                         (oy0 + oy1) / 2.0,
                                                         ALT_CAIS + altura)]}
        elif tipo == "praca":
            # O piso: fora do caminho em cruz, que passa pelo meio.
            # ⚠️ A PROVA É O CORETO, e não o piso. O piso é a MESMA calçada do
            # passeio, que passa a poucos pixels dali: uma janela posta sobre
            # ele contaria os pixels da RUA e passaria mesmo com a praça
            # apagada — a guarda que se satisfaz com o vizinho. O coreto é a
            # única peça que só a praça tem, é sólido, e fica no meio, onde
            # nenhuma copa chega desde que as árvores foram para a borda.
            # Desde a `123` o telhado do coreto é de oito águas, e a prova mira
            # o baricentro da água em tom puro que mais olha para +my.
            g = geometria_do_coreto(*planta_da_praca(mx0, my0, dmx, dmy))
            pts, _n, _f = max((f for f in _faces_do_telhado_do_coreto(g)
                               if f[2] == 1.0), key=lambda f: f[1][1])
            # `math.fsum`, não `sum`: o CI compara a tabela ao byte, e o `sum` de
            # floats mudou na Python 3.12 (`mapa.md`).
            bx, by, bz = (math.fsum(q[k] for q in pts) / 3.0 for k in range(3))
            saida[i] = {"tipo": tipo, "cor": "telha_d", "raio": 6, "minimo": 8,
                        "px": [round(c, 1) for c in tela(bx, by, bz)]}
    return saida


def conferir_a_torre_cabe() -> list:
    """Devolve as queixas; lista vazia quer dizer que cabe em todos os níveis."""
    lotes = lotes_da_vila()
    queixas = []
    igrejas = [i for i, t in tipos_dos_lotes().items() if t == "igreja"]
    for i in igrejas:
        mx0, my0, dmx, dmy, variante, _fundo, _casa = lotes[i]
        for nivel, perfis in sorted(VILA_NIVEIS.items()):
            altura = perfis[variante][0]
            # O topo sai da MESMA geometria que o desenho usa: fuste, cornija,
            # pirâmide e cruz.
            g = geometria_da_igreja(mx0, my0, dmx, dmy, altura)
            _x, y = tela(g["apice"][0], g["apice"][1], g["topo"])
            if y < 0.0:
                queixas.append(
                    "a torre da igreja (lote %d) sai %0.0f px por cima do quadro "
                    "no nível %d da vila" % (i, -y, nivel))
    return queixas


# ── A VILA É UM QUARTEIRÃO, NÃO UM PENTE ─────────────────────────────────
#
# Medido em 04/09, no mapa de 03/09: 16 lotes, e **11 dos 15 vãos entre casas
# mediam exatamente 1,95** — o `VILA_PASSO`, batido como um metrónomo. Casa,
# vão, casa, vão, todas do mesmo tamanho e à mesma distância. É por isso que a
# fileira lia como cerca e não como cidade: um loteamento novo tem esse ritmo;
# uma vila de porto, não.
#
# As plantas de cidade portuária que a leitura das referências manda consultar
# (`docs/design/referencias/README.md`) dizem duas coisas que valem aqui, e a
# morfologia urbana confirma-as: o tecido divide-se em QUARTEIRÕES CURTOS
# cortados por ruas transversais, e dentro do quarteirão as casas encostam-se
# — em São Sebastião e em Paraty a frente de rua é feita de casas geminadas,
# sem recuo, e o vão aparece na esquina e não entre vizinhos.
#
# Então o passo deixou de ser constante e passou a ter DOIS regimes:
#
#   · dentro do quarteirão, 3 a 5 lotes com 0,10 a 0,38 entre eles, e um par
#     em cada três COLADO (geminado, vão zero);
#   · entre quarteirões, uma TRAVESSA de 1,5 a 1,9 — a rua que desce para o
#     cais, e que é o que dá esquina à vila.
#
# O alinhamento à rua é POR QUARTEIRÃO e não por casa: as casas de um mesmo
# quarteirão partilham a linha de frente, com um desvio pequeno. Sortear o
# recuo casa a casa, que era o que se fazia, desmancha a frente de rua — e a
# frente de rua contínua é justamente o que se lê como cidade de longe.
VILA_LOTES_POR_QUARTEIRAO = (3, 5)
VILA_TRAVESSA = (1.5, 1.9)      # o vão da rua transversal, em `my`
# ⚠️ O VÃO ENTRE VIZINHOS MEXEU DUAS VEZES NA `123`. Era 0,10 a 0,38, com um
# par em cada três colado; com o muro de divisa a meio dele, 0,10 não deixava
# terreno, e a primeira passagem abriu-o a 0,22–0,52 — «a vila ficou rala»,
# disse a foto seguinte. A 0,16–0,40 o muro ainda cabe e o quarteirão fecha.
# E nenhuma casa do nível 1 encosta na vizinha: o telhado com beiral de uma
# fatiaria o da outra, e a casa humilde de vila é solta no terreno.
VILA_VAO = (0.16, 0.40)         # entre vizinhos do mesmo quarteirão


def _fileira(recuo: float, semente: int, fundo: bool = False) -> list:
    """Os lotes de UMA fileira, medidos do cais. Ver `lotes_da_vila`.

    `fundo` rareia a fileira de trás: quarteirões mais curtos e travessas mais
    largas. Uma vila que acaba numa parede de telhados é tão errada quanto uma
    que acaba numa fileira só — o que a orla de uma cidade pequena faz é
    DESFIAR-SE, e o que enche o vão são as árvores dos quintais.
    """
    r = random.Random(semente)
    vaos = vaos_da_vila(recuo)
    quarteirao = (2, 3) if fundo else VILA_LOTES_POR_QUARTEIRAO
    travessa = (2.2, 3.4) if fundo else VILA_TRAVESSA
    saida = []
    saco: list = []
    for my0, my1, borda in DEGRAUS:
        my = my0 + 0.35
        # A linha de frente do quarteirão. `frente` é o recuo partilhado.
        frente = r.uniform(0.0, 0.20)
        restam = r.randint(*quarteirao)
        muro = linha_do_muro(borda, fundo)
        while my < my1 - 0.5:
            mx = borda - recuo + frente + r.uniform(0.0, 0.05)
            visivel = no_quadro(mx, my, folga=110.0)
            # O SACO SÓ SERVE QUEM SE VÊ, e a forma de um lote recusado volta
            # para ele: metade dos lotes desta fileira cai fora do quadro ou
            # num vão, e um saco gasto neles deixava formas inteiras de fora da
            # tela outra vez, cada vez outras, a cada ajuste na geometria.
            do_saco = visivel
            tipo = _tirar_do_saco(saco, r, fundo) if visivel else "quatro_aguas"
            dmy = r.uniform(*CASA_TIPOS[tipo][2:])
            if my + dmy > my1 - 0.15:
                if do_saco:
                    saco.append(tipo)
                break
            # A casa recua do muro da frente o bastante para ele caber.
            dmx = min(VILA_PROF - r.uniform(0.0, 0.26),
                      muro - VILA_QUINTAL_FRENTE - mx)
            variante = r.randrange(3)
            # ⚠️ E O QUE CAI FORA DO QUADRO NÃO ENTRA, pelo mesmo motivo que a
            # mata: medido em 04/09, só **17,3 das 40 unidades** da fileira da
            # frente estão dentro do PNG — 43%. O degrau 3 inteiro está fora, à
            # esquerda, e gerava cinco casas que ninguém nunca viu. A folga é
            # larga porque um telhado assoma no quadro muito antes do canto do
            # lote lá chegar.
            if not visivel:
                pass
            # O vão só vale se a casa INTEIRA couber fora dele: testar o
            # canto, como se fazia, deixava passar a casa que entra no vão
            # pela outra ponta.
            elif not any(a < my + dmy and my < b for a, b in vaos):
                saida.append((mx, my, dmx, dmy, variante, fundo, tipo))
            elif do_saco:
                saco.append(tipo)
            restam -= 1
            if restam <= 0:
                my += dmy + r.uniform(*travessa)
                frente = r.uniform(0.0, 0.20)
                restam = r.randint(*quarteirao)
            else:
                # ⚠️ ATÉ À `123` UM PAR EM CADA TRÊS ENCOSTAVA (geminada), e a
                # geminada tinha de herdar a variante da vizinha: telhados de
                # alturas diferentes liam como um fatiado pelo outro, porque o
                # beiral de 0,12 de cada lado os sobrepunha 0,24.
                my += dmy + r.uniform(*VILA_VAO)
    return saida


# ── A SEGUNDA FILEIRA, E POR QUE ELA DEIXOU DE SER "NÃO SE VÊ" ───────────
#
# A `lotes_da_vila` dizia, em comentário: "uma fileira só, e não duas: a
# segunda cairia fora da esquerda do ecrã a partir do terceiro degrau, e casa
# que ninguém vê é desenho pago em nada". A frase estava certa E a conclusão
# errada, e é a terceira vez neste projeto que medir sai mais barato do que
# supor: medido em 04/09, a segunda fileira tem **11,7 unidades dentro do
# quadro contra 17,3 da primeira — 67%**. Ela cai fora do ecrã no degrau 3,
# como o comentário dizia; só que o degrau 3 já estava fora inteiro, e nos
# outros três ela aparece.
#
# O que mudou não foi a geometria, foi haver `no_quadro`: com ele, uma fileira
# que só é visível em parte simplesmente não gera o resto, e o argumento "casa
# que ninguém vê é desenho pago em nada" deixa de se aplicar.
#
# E a segunda fileira é o que faz a vila ler como CIDADE. A leitura das
# referências pede uma FAIXA atrás do cais, "nunca um bloco", e uma faixa de
# uma casa de espessura não é faixa: é cerca. Com duas, aparece a coisa que o
# olho reconhece como tecido urbano — um telhado atrás do vão entre dois
# telhados da frente.
# ⚠️ E A TRAVESSA DE TRÁS TEM DE VALER MAIS DE UM TELHADO. Medido em 04/09,
# e é a regra que faltava: um telhado desta vila mede ~78 px na tela, e a
# separação entre fileiras é `Δmx * MEIA_LARG`. Com a travessa de 0,55 que
# esta constante teve primeiro, isso dava **57 px** — a casa de trás ficava
# 73% tapada pela da frente, e a captura mostrava três telhados fundidos num
# borrão de telha em vez de duas fileiras. Com 1,60 dá 88 px, e o telhado de
# trás sai inteiro por cima do da frente.
#
# O preço está medido e é aceitável: a segunda fileira encolhe de 11,6 para
# 8,5 unidades visíveis — ainda metade da primeira, que tem 17,3.
VILA_TRAVESSA_FUNDO = 1.60
VILA_RECUO_2 = VILA_RECUO + VILA_PROF + VILA_TRAVESSA_FUNDO


def lotes_da_vila() -> list:
    """(mx0, my0, dmx, dmy, variante, fundo, casa) de cada lote, do cais.

    `casa` é a forma (`CASA_TIPOS`); quem decide se o lote é casa, igreja,
    praça ou obra é `tipos_dos_lotes()`.

    Duas fileiras, e o que decide quais casas existem é o quadro: ver
    `_fileira` e `VILA_RECUO_2`.
    """
    return _fileira(VILA_RECUO, SEMENTE_CHAO + 210) \
        + _fileira(VILA_RECUO_2, SEMENTE_CHAO + 211, fundo=True)


def viela_da_vila(pavimentado: bool) -> str:
    """A viela de terra entre as duas fileiras de casas.

    ⚠️ ELA RESPONDE A DUAS QUEIXAS DA MESMA JOGADA, e a medida é que as juntou.
    A primeira pedia *"caminhos de terra para as casas"*; a segunda circulava a
    vermelho os sítios onde *"a estrada acaba no nada"*. Medido: entre a
    calçada e a frente da casa da frente há **0,13 unidades**, quatro pixels —
    não cabe caminho nenhum ali, e é a mesma medida que já tinha mandado as
    árvores da vila para o quintal. O espaço que existe é o de **1,60 entre as
    duas fileiras**, e é para lá que a face que "acaba no nada" aponta: o
    cotovelo da rua acaba numa aresta virada para a vila, e essa aresta cai
    exatamente na boca deste vão.
    A viela sai dela e serve a fileira de trás, que até 07/09 não tinha
    acesso nenhum — uma fileira de casas sem rua, que é a mesma queixa vista
    do outro lado.

    ⚠️ E ELA COMEÇA NO COTOVELO DO DEGRAU ANTERIOR, por isso o primeiro degrau
    não a leva: sem cotovelo atrás dela a viela nasceria solta no relvado, que
    é o defeito que ela existe para corrigir.
    """
    s = ""
    for i, (my0, my1, borda) in enumerate(DEGRAUS):
        if i == 0:
            continue
        # A mesma faixa onde estacionam os carros (`141`).
        mx0, mx1 = faixa_da_viela(i)
        if mx1 - mx0 < 0.4:
            continue
        # Ela acaba na última casa de trás do quarteirão, e não num `my`
        # escolhido: viela que passa da última casa é viela que acaba no nada,
        # que é justamente o que se está a corrigir.
        fim = None
        for lmx0, lmy0, dmx, dmy, _v, fundo, _c in lotes_da_vila():
            if fundo and my0 <= lmy0 < my1:
                fim = max(fim, lmy0 + dmy) if fim is not None else lmy0 + dmy
        if fim is None:
            continue
        # ⚠️ A MESMA TERRA NOS DOIS MAPAS (`136`). Ela clareava para
        # `terra_clara` no mapa do pátio pronto, e a viela inteira trocava de
        # cor no dia em que a obra do pátio acabava — longe da obra e fora do
        # recorte dela, «do nada». A vila não é do porto; fica com a do dia 1.
        s += _faixa_mx(mx0, mx1, my0, min(fim + 0.45, my1), C["terra_escura"])
    return s


def paredes_da_vila(lotes: list) -> list:
    """A cor da parede de cada lote, pela ordem de `lotes_da_vila()`.

    Vizinhas de porta não repetem a cor — "cada casa de uma cor", na leitura
    da referência. Nem a geminada: desde a `123` só o casario de platibanda
    encosta, e casario é cada fachada de uma cor.
    """
    r = random.Random(SEMENTE_CHAO + 430)
    saida = []
    for i, lote in enumerate(lotes):
        ant = lotes[i - 1] if i > 0 else None
        vizinha = saida[-1] if ant is not None and ant[5] == lote[5] else None
        # A casa por pintar: o reboco cru, em metade das meias-águas e numa
        # casa em seis das outras — a vila humilde do nível 1 (`123`).
        if vizinha != "reboco" and r.random() < (0.5 if lote[6] == "meia_agua" else 0.16):
            saida.append("reboco")
            continue
        saida.append(r.choice([c for c in VILA_PAREDES if c != vizinha]))
    return saida


def caixas_que_caem_na_igreja(lotes: list, especiais: dict, perfis: list) -> set:
    """Os lotes cuja caixa-d'água, na tela, cairia em cima da igreja.

    ⚠️ A CAIXA É DA CASA DE TRÁS, MAS O OLHO DÁ-A À IGREJA: na segunda foto da
    `123` a caixa azul da casa atrás da nave assomava colada à torre, e a
    igreja parecia ter uma caixa-d'água no telhado. Uma caixa cujo ponto na
    tela cai dentro do retângulo da igreja não se desenha.
    """
    caixa_igreja = None
    for i, t in especiais.items():
        if t != "igreja":
            continue
        mx0, my0, dmx, dmy, variante, _f, _c = lotes[i]
        g = geometria_da_igreja(mx0, my0, dmx, dmy, perfis[variante][0])
        pts = [tela(x, y, z) for x in (mx0, mx0 + dmx) for y in (my0, my0 + dmy)
               for z in (ALT_CAIS, g["topo"])]
        caixa_igreja = (min(q[0] for q in pts) - 4, min(q[1] for q in pts) - 4,
                        max(q[0] for q in pts) + 4, max(q[1] for q in pts) + 4)
    if caixa_igreja is None:
        return set()
    fora = set()
    for i, (mx0, my0, dmx, dmy, variante, _f, _c) in enumerate(lotes):
        if i in especiais:
            continue
        x, y = tela(mx0 + dmx / 2.0, my0 + dmy / 2.0, ALT_CAIS + perfis[variante][0] + 8)
        if caixa_igreja[0] <= x <= caixa_igreja[2] and caixa_igreja[1] <= y <= caixa_igreja[3]:
            fora.add(i)
    return fora


def contorno_da_casa(lote: tuple, nivel: int = 1) -> list:
    """Por coluna de TELA, a linha mais alta que a casa do lote pinta.

    A mesma casa que a `vila()` desenha — forma do nível, altura do sobrado —,
    sem a cor, o acento e as janelas, que não mudam o contorno (`130`).
    """
    mx0, my0, dmx, dmy, variante, _fundo, forma = lote
    altura, telha, janelas = VILA_NIVEIS[min(nivel, max(VILA_NIVEIS))][variante]
    forma = forma_no_nivel(forma, nivel)
    if forma == "sobrado":
        altura = altura_do_sobrado(nivel, variante)
    topo = [float(SAIDA)] * SAIDA
    _envolver(CASAS[forma](mx0, my0, mx0 + dmx, my0 + dmy, altura, C["casa_a"],
                           telha, janelas, None), topo)
    return topo


_CASAS = None


def _casas_a_frente(mx: float, my: float) -> list:
    """O contorno, por coluna de TELA, das casas dos lotes que ficam à frente
    do ponto (mx, my) — a regra do eixo de `lote_a_frente`, pela caixa do
    terreno. Só as CASAS: é o que esconde uma árvore de quintal."""
    global _CASAS
    if _CASAS is None:
        lotes = lotes_da_vila()
        especiais = tipos_dos_lotes()
        _CASAS = [(tuple(t[:4]), {c: y for c, y in enumerate(contorno_da_casa(l)) if y < SAIDA})
                  for i, (l, t) in enumerate(zip(lotes, terrenos_da_vila(lotes)))
                  if not especiais.get(i, "")]
    topo = [float(SAIDA)] * SAIDA
    for caixa, cols in _CASAS:
        if lote_a_frente(caixa, mx, my):
            for c, y in cols.items():
                if y < topo[c]:
                    topo[c] = y
    return topo


def telhado_do_lote(lote: tuple) -> list:
    """O ponto de TELA logo abaixo do alto do telhado, na coluna do meio do
    lote: o sítio que o D47 olha para saber se uma copa pousou nele."""
    mx0, my0, dmx, dmy = lote[:4]
    x, _y = tela(mx0 + dmx / 2.0, my0 + dmy / 2.0, ALT_CAIS)
    topo = contorno_da_casa(lote)
    c = max(0, min(SAIDA - 1, math.floor(x)))
    return [round(c + 0.5, 1), round(topo[c] + 3.0, 1)]


def vila(nivel: int, pavimentado: bool) -> str:
    """As casas atrás da rua, no nível pedido, e as árvores entre elas.

    Desenhadas de trás para a frente (por `mx + my` crescente), senão uma casa
    de trás aparece por cima da que está à frente dela — e a mesma ordem serve
    às árvores, que por isso entram nesta lista e não numa passagem própria.

    ⚠️ AS ÁRVORES DA VILA SÃO O GANHO DE DENSIDADE, e o sítio delas foi
    medido antes de escolhido. A referência pede árvore de rua ("uma cidade
    planta árvores regularmente espaçadas ao longo do passeio"), mas **entre a
    calçada e a frente do lote há 0,13 unidades**, que são 4 px: não cabe
    tronco nenhum. E plantar na calçada punha a copa a pender sobre o asfalto,
    onde o caminhão — que é PROP, desenhado por cima do mapa — passaria por
    cima dela.
    Então elas vão para o QUINTAL, à frente e atrás da casa, dentro do lote.
    Na projeção a copa sobe e recua na tela, ou seja, para longe da rua: uma
    árvore no quintal da frente tapa parte da própria casa, que é o que ela faz
    na vida real, e nunca a estrada.
    """
    if nivel <= 0:
        return ""
    perfis = VILA_NIVEIS[min(nivel, max(VILA_NIVEIS))]
    r = random.Random(SEMENTE_CHAO + 300 + nivel)
    # A VIELA VEM PRIMEIRO, porque é CHÃO. O que cresce no chão pertence à
    # camada do chão — a mesma lição que o capim da restinga pagou ao aparecer
    # por cima dos telhados.
    s = viela_da_vila(pavimentado)
    lotes = lotes_da_vila()
    especiais = tipos_dos_lotes()
    paredes = paredes_da_vila(lotes)
    # ⚠️ O ÍNDICE VEM DE ANTES DA ORDENAÇÃO. Os lotes desenham-se de trás para
    # a frente, mas quem é a igreja decidiu-se sobre a lista COMO ELA SAI DE
    # `lotes_da_vila()` — que é a mesma que a tabela de âncoras publica. Ordenar
    # primeiro e indexar depois faria a igreja mudar de lote de cada vez que uma
    # casa se mexesse, sem erro nenhum a apontá-lo.
    terrenos = terrenos_da_vila(lotes)
    # A caixa-d'água sai de um `Random` só dela, pela ordem dos lotes: o `r`
    # da vila é o das árvores, e cada sorteio a mais lá mudava-as de sítio.
    # ⚠️ ERA UMA CASA EM CADA 2,5, e na terceira foto eram caixas demais.
    rc = random.Random(SEMENTE_CHAO + 440)
    caixas = [rc.random() < 0.25 for _l in lotes]
    # A telha de fibrocimento, também de um `Random` próprio, e SÓ na meia-água:
    # com uma empena em cinco e uma casa em dez também de cinzento, a terceira
    # foto ainda leu «cinza demais nos telhados». A telha de barro é tão
    # humilde quanto ela, e é a cor quente da vila.
    rf = random.Random(SEMENTE_CHAO + 450)
    fibro = [l[6] == "meia_agua" and rf.random() < 0.8 for l in lotes]
    # A cor de acento de cada casa e a moita florida do quintal, cada uma do
    # seu `Random`, pela ordem dos lotes.
    ra = random.Random(SEMENTE_CHAO + 460)
    acentos = [ra.choice(ACENTOS) if ra.random() < 0.85 else None for _l in lotes]
    rj = random.Random(SEMENTE_CHAO + 470)
    jardins = [(rj.random() < 0.45, rj.choice(["flor_primavera", "flor_ipe",
                                                "flor_primavera", "flor_branca"]),
                rj.uniform(0.15, 0.85)) for _l in lotes]
    sem_caixa = caixas_que_caem_na_igreja(lotes, especiais, perfis)
    marcas = []
    for i, (mx0, my0, dmx, dmy, variante, fundo, forma) in sorted(
            enumerate(lotes), key=lambda par: par[1][0] + par[1][1]):
        # Onde começa o desenho de cada lote, para o contorno POR LOTE
        # (`pecas_da_vila`), com a caixa do TERRENO — onde vivem a casa, os
        # muros e as árvores dele.
        marcas.append((tuple(round(v, 3) for v in terrenos[i][:4]), len(s)))
        altura, telha, janelas = perfis[variante]
        tipo: str = especiais.get(i, "")
        xt, xm, ye, yd, _me, _md = terrenos[i]
        moita = False
        # Na fileira de trás planta-se mais: é ela que desfia a vila contra a
        # mata, e é a árvore — não o vão vazio — que faz a orla parecer orla.
        # ⚠️ ERA 0,85 E 0,55, com a copa em SVG: na segunda passagem da `127`
        # o Bruno pediu árvores «no meio da cidade para não ficar sem nada»,
        # e as do Blender entram no mesmo sítio da ordem de desenho.
        # ⚠️ E NA TERCEIRA PASSAGEM a da frente desceu a 0,5: «árvores demais
        # na vila», com copas a tapar meia casa.
        pomar = 1.0 if fundo else 0.5
        # Quintal: a casa não ocupa o lote todo, e o que sobra é chão batido
        # mesmo no mapa pavimentado — quintal não é asfalto. Desde a `123` é o
        # TERRENO, de muro a muro; antes saía 0,5 para a frente da casa e
        # passava por cima do passeio. E é a MESMA terra nos dois mapas desde
        # a `136`, pela razão da viela: o quintal não muda com o pátio.
        s += _faixa_mx(xt, xm, ye, yd, C["terra_escura"], 0.5)
        # O CONTORNO DA CASA, para as árvores do lote saberem quanto ela as
        # tapa ou quanto lhe tapam (`130`). É o mesmo desenho que sai mais
        # abaixo — a casa não sorteia nada —, só que medido antes.
        casa = None if tipo else contorno_da_casa(lotes[i], nivel)
        # Árvore do QUINTAL DE TRÁS, desenhada antes da casa para a casa a
        # tapar em parte — é o que a põe atrás em vez de colada por cima.
        if r.random() < pomar:
            s += arvore_da_cidade(mx0 - r.uniform(0.10, 0.26),
                        my0 + r.uniform(-0.1, dmy + 0.1),
                        r.uniform(0.30, 0.52), r, r.random(), atras=True,
                        sem_ipe=bool(tipo))
        if tipo == "praca":
            s += _pracinha(*planta_da_praca(mx0, my0, dmx, dmy), r)
        elif tipo == "igreja":
            # O ADRO: a calçada à frente da porta, da torre até ao passeio —
            # a igreja recuou da frente do lote para ele caber (`IGREJA_ADRO`).
            g = geometria_da_igreja(mx0, my0, dmx, dmy, altura)
            s += _faixa_mx(g["torre"][2] - 0.02, xm + 0.03, my0 + dmy * 0.06,
                           my0 + dmy * 0.94, C["meiofio"])
            s += _faixa_mx(g["torre"][2] - 0.02, xm + 0.03, my0 + dmy * 0.06 + 0.04,
                           my0 + dmy * 0.94 - 0.04, C["calcada"])
            # O banco do lado −my do adro e o poste, na quina desse lado, ficam
            # atrás da torre na tela e saem antes dela; o banco +my, depois.
            # (O poste na quina +my caía mesmo à frente da porta da torre.)
            tx1, ty0, ty1 = g["torre"][2], g["torre"][1], g["torre"][3]
            s += _banco(tx1 + 0.08, ty0 - 0.16, tx1 + 0.28, ty0 - 0.11)
            s += _poste(xm - 0.06, my0 + dmy * 0.06 + 0.10)
            s += _igreja(mx0, my0, mx0 + dmx, my0 + dmy, altura)
            s += _banco(tx1 + 0.08, ty1 + 0.08, tx1 + 0.28, ty1 + 0.13)
        elif tipo == "obra":
            # ⚠️ A OBRA É DESENHADA COM A ALTURA DO NÍVEL SEGUINTE, e é isto
            # que responde ao "indicadores que farão a cidade ir crescendo" do
            # pedido sem tocar em mecânica nenhuma: o que está em obra no nível
            # 1 tem o tamanho do que estará pronto no nível 2. No último nível
            # não há seguinte, e ela sobe um terço — a cidade não para de
            # crescer só porque a Fase 5 acabou.
            proximo = perfis[variante][0]
            if nivel + 1 in VILA_NIVEIS:
                proximo = VILA_NIVEIS[nivel + 1][variante][0]
            else:
                proximo = int(altura * 1.34)
            s += _sem_telhado(mx0, my0, mx0 + dmx, my0 + dmy, proximo)
        else:
            parede = C[paredes[i]]
            forma = forma_no_nivel(forma, nivel)
            if nivel <= 1 and fibro[i]:
                telha = "fibrocimento"
            if forma == "sobrado":
                altura, janelas = altura_do_sobrado(nivel, variante), janelas + 1
            porta = my0 + dmy * PORTA_NA_FRENTE.get(forma, 1.0)
            atras, frente = muros_do_terreno(terrenos[i], parede, porta, acentos[i])
            s += atras
            s += sombra_da_casa(forma, mx0, my0, mx0 + dmx, my0 + dmy, altura)
            s += CASAS[forma](mx0, my0, mx0 + dmx, my0 + dmy, altura,
                              parede, telha, janelas, acentos[i])
            if caixas[i] and i not in sem_caixa:
                s += caixa_dagua_da_casa(forma, mx0, my0, mx0 + dmx, my0 + dmy,
                                         altura)
            tem, flor, onde = jardins[i]
            lado = yd - (my0 + dmy)
            moita = tem and lado > 0.10
            if moita:
                s += _moita(mx0 + dmx * (0.35 + 0.5 * onde), my0 + dmy + lado * 0.5,
                            flor, r)
            s += frente
        # Árvore do quintal do LADO, entre a casa e a divisa +my.
        # ⚠️ ERA DA FRENTE, a 0,10–0,34 da fachada, e desde a `123` a frente
        # tem 0,12 até ao muro: o tronco cairia em cima dele ou da calçada.
        # O lado é onde o terreno brasileiro tem espaço, e a copa, que sobe e
        # recua na tela, tapa a própria casa como na vida real e nunca a rua.
        # E NÃO NOS LOTES ESPECIAIS: na praça ela nascia no piso, à frente do
        # coreto, e tapava-lhe a base; na igreja, a da torre (`123`).
        lado = yd - (my0 + dmy)
        if tipo:
            continue
        # O quintal do lado com moita não leva árvore: uma tapava a outra.
        if lado > 0.10 and not moita and r.random() < pomar - 0.05:
            s += arvore_da_cidade(mx0 + dmx * r.uniform(0.45, 0.90), my0 + dmy + lado * 0.6,
                        r.uniform(0.22, 0.36), r, r.random(), teto=0.65, casa=casa)
        elif r.random() < 0.7:
            gx, gy = p(mx0 + dmx + r.uniform(0.02, VILA_QUINTAL_FRENTE - 0.02),
                       my0 + r.uniform(0.1, dmy), ALT_CAIS)
            s += tufo_de_capim(gx, gy, r, n=(3, 5), alt=(3.0, 5.5))
    if nivel == 1:
        _DESENHO_POR_LOTE[pavimentado] = [
            (prof, s[ini:(marcas[k + 1][1] if k + 1 < len(marcas) else len(s))])
            for k, (prof, ini) in enumerate(marcas)]
    return s


_DESENHO_POR_LOTE = {}
_PECAS = None


def pecas_da_vila() -> list:
    """[(caixa, {coluna de TELA: linha de cima})] — o contorno de CADA LOTE
    da vila (a casa, os muros, as árvores e a caixa-d'água dele), com a caixa
    do terreno no mundo, `(mx0, mx1, my0, my1)`.

    ⚠️ O CONTORNO DA VILA INTEIRA É O MÍNIMO DA COLUNA (`130`), e uma casa lá
    ATRÁS proibia uma árvore que balança À FRENTE dela: a mata do morro caiu
    toda nos 35 px da borda esquerda, porque à direita disso há casas da
    fileira de trás mais acima na tela. Uma árvore só pode errar sobre o que
    lhe fica À FRENTE — e é isso que estas peças deixam perguntar, lote a
    lote. Vale a menor das duas versões do mapa, como o contorno.
    """
    global _PECAS
    if _PECAS is None:
        # ⚠️ O `vila()` ACRESCENTA as árvores dele à lista das embutidas, e
        # esta função corre a meio de quem a está a recolher (a orla pergunta
        # pelos lotes à frente): sem repor a lista, a orla publicada levava as
        # árvores da vila, conforme a ordem das chamadas — e a cópia do jogo
        # deixou de bater com a tabela.
        guardadas = list(_EMBUTIDAS)
        juntas = {}
        for pavimentado in (False, True):
            vila(1, pavimentado)
            for caixa, desenho in _DESENHO_POR_LOTE[pavimentado]:
                topo = [float(SAIDA)] * SAIDA
                _envolver(desenho, topo)
                cols = juntas.setdefault(caixa, {})
                for c, y in enumerate(topo):
                    if y < SAIDA:
                        cols[c] = min(cols.get(c, y), y)
        _PECAS = [(caixa, {c: round(math.floor(y * 10.0) / 10.0, 1)
                           for c, y in sorted(cols.items())})
                  for caixa, cols in sorted(juntas.items())]
        _EMBUTIDAS[:] = guardadas
    return _PECAS


def lote_a_frente(caixa: tuple, mx: float, my: float) -> bool:
    """O lote de terreno `caixa` está à frente do ponto (mx, my) do chão?

    A regra do eixo que separa: o ponto só fica à frente se passar do fim do
    terreno num dos dois eixos — `mx` maior (mais perto do cais) ou `my`
    maior (mais para a esquerda e para baixo na tela). Pela soma `mx + my`,
    um ponto atrás de uma casa e ao lado dela em `my` contava-se à frente, e
    a árvore pintar-se-ia por cima do telhado.
    """
    return not (mx >= caixa[1] or my >= caixa[3])


_TOPO_DAS_VIAS = None


def horizonte_das_vias() -> list:
    """O contorno das vias, que estão à frente de toda a mata: por coluna."""
    global _TOPO_DAS_VIAS
    if _TOPO_DAS_VIAS is None:
        topo = [float(SAIDA)] * SAIDA
        for pavimentado in (False, True):
            _envolver(vias(pavimentado), topo)
        _TOPO_DAS_VIAS = [round(math.floor(y * 10.0) / 10.0, 1) for y in topo]
    return _TOPO_DAS_VIAS


_A_FRENTE = {}


def _a_frente(mx: float, my: float) -> list:
    """O contorno do que fica À FRENTE do ponto (mx, my): as vias, que estão à
    frente de toda a mata, e os lotes que `lote_a_frente` diz."""
    chave = (round(mx, 2), round(my, 2))
    if chave not in _A_FRENTE:
        topo = list(horizonte_das_vias())
        for caixa, cols in pecas_da_vila():
            if lote_a_frente(caixa, mx, my):
                for c, y in cols.items():
                    if y < topo[c]:
                        topo[c] = y
        _A_FRENTE[chave] = topo
    return _A_FRENTE[chave]


# ── ESPUMA: DEIXOU DE SER FUNDO E PASSOU A SER CAMADA ────────────────────
#
# Pedido do playtest: "animações mais fluidas, e novas animações, para o
# coqueiro, ondas e até fazer o caminhão andar". O coqueiro e o caminhão eram
# tween; a onda não era, e a razão está medida: a espuma estava ASSADA no SVG
# do mapa, que é UMA textura. Não havia nó de onda nenhum para animar, e
# animar o mapa inteiro seria fazer a costa deslizar.
#
# Agora ela sai em ARQUIVO PRÓPRIO, transparente, do mesmo tamanho do mapa e
# na mesma projeção — o jogo põe-na por cima da água e faz a lavagem. São
# DUAS camadas de sementes diferentes, em contrafase: uma entra enquanto a
# outra sai, e é isso que dá continuidade. Uma camada só a pulsar dava uma
# costa inteira a piscar ao mesmo tempo, que é exatamente o que a versão de
# traço contínuo já tinha ensinado a não fazer.
#
# ⚠️ E O MAPA DEIXOU DE A TER. Se ela ficasse assada E em camada, a espuma
# apareceria a dobrar e a parte assada nunca se mexeria — meia costa viva e
# meia parada é pior do que uma costa parada.
def espuma(semente: int) -> str:
    """As manchas de arrebentação, como camada solta.

    MANCHAS, não traço, e isto passou por duas versões erradas: linha contínua
    ao longo do cais leu como arame esticado, e quebrá-la em `stroke-dasharray`
    só trocou o arame por faixa de rodovia — traço claro de espessura constante
    sobre pedra escura é o desenho de uma pintura de solo. O que lê como
    arrebentação é borrão de tamanho e opacidade irregulares: a espuma não tem
    espessura, tem quantidade.
    """
    s = ""
    r = random.Random(semente)
    for mx, my, (nmx, nmy), _t in andar_costa(0.45, (0.18, 0.42), r):
        if r.random() >= 0.72 or _sob_pier(my):
            continue
        fora = r.uniform(0.0, 0.55)
        fx, fy = p(mx + nmx * fora, my + nmy * fora)
        rx = r.uniform(4.0, 11.0)
        s += ('  <ellipse cx="%.0f" cy="%.0f" rx="%.1f" ry="%.1f" '
              'fill="%s" opacity="%.2f"/>\n'
              % (fx, fy, rx, r.uniform(1.8, 3.2), C["espuma"],
                 r.uniform(0.28, 0.60)))
    return s


# ── AS MAROLAS (`124`) ───────────────────────────────────────────────────
# Os riscos «~» eram um TRAÇO de espessura constante no plano da TELA, o mesmo
# til de 18 a 38 px perto e longe da costa: liam como carimbo por cima do mar,
# e o Bruno pediu-os fora — «se conseguir, coloque algo melhor no lugar, que
# futuramente possa ser animado como ondas».
#
# A marola é desenhada no plano da ÁGUA e projetada, como tudo o que acompanha
# a costa: a crista corre em `my` (paralela ao cais) com um arco leve para
# terra, afina até zero nas duas pontas, e leva por baixo — do lado do mar,
# que é a face `+mx`, a de sombra neste mapa — um cavado escuro mais curto. É
# o par claro/escuro que dá relevo; uma crista sozinha era outro traço. Perto
# da costa ela é maior e mais viva; ao largo encurta e apaga-se, e é isso que
# deixa o fundo calmo depois de a rampa voltar a descer até lá.
#
# E CADA UMA É UMA PEÇA COM CENTRO, não um traço solto: para as animar basta
# escrevê-las numa camada própria, como a espuma (`--espuma=N`), em duas
# sementes que o `Main.gd` lave em contrafase. Hoje ficam no mapa; a VRAM de
# uma camada a 1080 sem compressão são ~4,7 MB.
MAROLAS_POR_DEGRAU = 22
MAROLA_PERTO = 2.0            # unidades da borda do degrau até à primeira
MAROLA_LONGE = 26.0           # e até à última
MAROLA_VIES = 2.1             # o expoente que as encosta à costa
MAROLA_FOLGA_TERRA = 1.8      # nenhum ponto dela a menos disto do cais
# A ONDULAÇÃO CHEGA EM SÉRIES: atrás de uma crista vêm outras, paralelas e cada
# vez mais fracas, a esta distância uma da outra. Uma crista solta lê como
# risco; duas ou três em fila leem como mar a andar para a costa (segunda
# passagem da `124`, a pedido de «deixar a água mais realista»).
MAROLA_ESPACO = 0.95
MAROLA_SERIE_FRACA = 0.72     # o que cada crista de trás guarda da da frente


def _lente(mx, my, meio, grossura, arco, frente) -> list:
    """O contorno de uma lente deitada na água, afinada nas pontas.

    `meio` é meio comprimento em `my`; `grossura` a espessura máxima em `mx`,
    da qual `frente` vai para terra e o resto para o mar; `arco` o quanto o
    meio avança para terra.
    """
    terra, mar = [], []
    for i in range(11):
        s = -1.0 + i / 5.0
        cheio = 1.0 - s * s
        eixo = mx - arco * cheio
        terra.append(p(eixo - grossura * frente * cheio, my + s * meio))
        mar.append(p(eixo + grossura * (1.0 - frente) * cheio, my + s * meio))
    return terra + mar[::-1]


def _na_agua_livre(mx, my, meio, arco) -> bool:
    """A lente inteira cai no mar, longe do cais e fora dos berços?"""
    if any(mx - arco <= _borda_em(my + k * meio) + MAROLA_FOLGA_TERRA
           for k in (-1.0, -0.5, 0.0, 0.5, 1.0)):
        return False
    return not (mx - _borda_em(my) < PIER_ALCANCE + 1.0 and _sob_pier(my))


def marolas() -> str:
    r = random.Random(SEMENTE_CHAO + 500)
    s = '  <g>\n'
    for my0, my1, borda in DEGRAUS:
        for _ in range(MAROLAS_POR_DEGRAU):
            vies = r.random() ** MAROLA_VIES         # mais perto da costa
            dmx = MAROLA_PERTO + vies * (MAROLA_LONGE - MAROLA_PERTO)
            my = r.uniform(my0 - 1.0, my1 + 3.0)
            longe = 1.0 - vies * 0.55
            meio = r.uniform(0.50, 0.95) * longe
            grossura = r.uniform(0.09, 0.13) * longe
            arco = r.uniform(0.08, 0.16) * longe
            opac = 0.46 - vies * 0.34
            serie = 1 + (r.random() < 0.55) + (r.random() < 0.30)
            for j in range(serie):
                fraca = MAROLA_SERIE_FRACA ** j
                mx = borda + dmx + j * MAROLA_ESPACO
                mj = my + j * meio * 0.12          # a série não é uma pilha
                if not _na_agua_livre(mx, mj, meio * fraca, arco):
                    continue
                s += poli(_lente(mx + grossura * 1.8, mj + meio * 0.08,
                                 meio * 0.82 * fraca, grossura * 0.70 * fraca,
                                 arco, 0.5),
                          C["sombra_agua"], round(opac * 0.55 * fraca, 2))
                s += poli(_lente(mx, mj, meio * fraca, grossura * fraca, arco, 0.35),
                          C["espuma"], round(opac * fraca, 2))
    return s + '  </g>\n'


# AS CORRENTES DO LARGO: faixas escuras compridas, deitadas ao longo da costa,
# onde o fundo da rampa já não varia. São o que a mancha funda redonda não dá
# ao largo — sem elas a água do fundo da tela é uma chapa só. Só escuras: a
# claridade solta no mar aberto era a queixa.
CORRENTES = 9


def correntes() -> str:
    r = random.Random(SEMENTE_CHAO + 510)
    angulo = math.degrees(math.atan2(MEIA_ALT, -MEIA_LARG)) - 180.0
    s = ''
    for _ in range(CORRENTES):
        my0, my1, borda = DEGRAUS[r.randrange(len(DEGRAUS))]
        cx, cy = p(borda + r.uniform(9.0, 26.0), r.uniform(my0 - 2.0, my1 + 4.0))
        rx = r.uniform(240.0, 420.0)
        ry = rx * r.uniform(0.14, 0.22)
        giro = angulo + r.uniform(-7.0, 7.0)
        s += ('  <ellipse cx="%.0f" cy="%.0f" rx="%.0f" ry="%.0f" '
              'fill="url(#mcorrente)" transform="rotate(%.0f %.0f %.0f)"/>\n'
              % (cx, cy, rx, ry, giro, cx, cy))
    return s


# ── A ARREBENTAÇÃO E AS CÁUSTICAS DA PRAIA (`124`) ───────────────────────
# A terceira passagem da `124` veio com um pedido de pesquisa: «técnicas para
# deixar o mar mais bonito e realista». A busca (os resumos; as páginas não
# abrem por este proxy, `063`) devolveu o mesmo vocabulário em toda a água
# estilizada: a cor pela profundidade, que a rampa já faz; LINHAS DE ESPUMA
# QUE CONTORNAM a margem, em faixas; e CÁUSTICAS — a rede de luz no fundo —
# só no raso. As duas últimas vivem na praia, que é onde a onda quebra e o
# fundo de areia se vê; no cais o fundo é dragado e o muro já tem espuma.
#
# As duas desenham-se pela MESMA família de curvas da costa
# (`ponto_costeiro`), parametrizadas pelo comprimento ao longo dela e pela
# distância à água — senão abriam costura com a areia, que é a regra do
# `mapa.md`. E vêm DEPOIS da areia submersa, que as tapava.
#
# A faixa é uma LENTE ao longo da costa, afinada nas duas pontas: traço claro
# de espessura constante lê como pintura de solo (`espuma()` conta a história).
ARREBENTACAO = ((1.35, 0.075, 0.42), (2.30, 0.055, 0.24))   # (d, grossura, opacidade)
CAUSTICA_PASSO = 0.21         # unidades entre dois vértices da rede, ao longo da costa
CAUSTICA_FILAS = ((0.32, 0.20), (0.62, 0.15), (0.92, 0.10))  # (d, opacidade)


def _amostras_da_costa(passo: float) -> list:
    """(i, f) a cada `passo` unidades ao longo do contorno da costa."""
    _v, comp, arco, _q = _geometria_da_costa()
    out, i, k = [], 0, 0
    while True:
        s = round(k * passo, 8)
        if s > arco[-1]:
            return out
        while i < len(comp) - 1 and s > arco[i + 1]:
            i += 1
        out.append((i, 0.0 if comp[i] == 0.0 else min(1.0, (s - arco[i]) / comp[i])))
        k += 1


def _na_praia_a(i: int, f: float, d: float) -> bool:
    return na_praia(ponto_costeiro(i, f, d)[1])


def arrebentacao() -> str:
    r = random.Random(SEMENTE_CHAO + 530)
    amostras = _amostras_da_costa(0.12)
    s = '  <g>\n'
    for d0, grossura, opac in ARREBENTACAO:
        k = 0
        while k < len(amostras):
            n = int(r.uniform(0.9, 2.6) / 0.12)
            trecho = amostras[k:k + n]
            k += n + int(r.uniform(0.4, 1.3) / 0.12)
            d = d0 + r.uniform(-0.14, 0.14)
            if len(trecho) < 4 or not all(_na_praia_a(i, f, d) for i, f in trecho):
                continue
            terra, mar = [], []
            for j, (i, f) in enumerate(trecho):
                u = j / (len(trecho) - 1)
                t = grossura * 4.0 * u * (1.0 - u)
                a = ponto_costeiro(i, f, d - t)
                b = ponto_costeiro(i, f, d + t)
                terra.append(p(a[0], a[1]))
                mar.append(p(b[0], b[1]))
            s += poli(terra + mar[::-1], C["espuma"], opac)
    return s + '  </g>\n'


def causticas() -> str:
    """A rede de luz no fundo de areia: filas ao longo da costa, com degraus
    entre elas em posições alternadas — a parede de tijolo que, torta, dá
    células de cinco e seis lados, e não a malha de uma rede de pesca."""
    r = random.Random(SEMENTE_CHAO + 540)
    amostras = _amostras_da_costa(CAUSTICA_PASSO)
    tremor = [[r.uniform(-0.10, 0.10) for _ in amostras] for _ in CAUSTICA_FILAS]
    falha = [[r.random() < 0.3 for _ in amostras] for _ in CAUSTICA_FILAS]
    s = '  <g fill="none" stroke="%s" stroke-linejoin="round">\n' % C["espuma"]

    def ponto(fila, k):
        i, f = amostras[k]
        d = CAUSTICA_FILAS[fila][0] + tremor[fila][k]
        return (i, f, d) if _na_praia_a(i, f, d) else None

    for fila, (_d, opac) in enumerate(CAUSTICA_FILAS):
        corrida = []
        for k in range(len(amostras) + 1):
            q = ponto(fila, k) if k < len(amostras) else None
            if q is not None:
                mx, my = ponto_costeiro(*q)[:2]
                corrida.append(p(mx, my))
                continue
            if len(corrida) >= 3:
                s += ('    <polyline points="%s" stroke-width="1.1" opacity="%.2f"/>\n'
                      % (" ".join("%.1f,%.1f" % c for c in corrida), opac))
            corrida = []
        if fila + 1 == len(CAUSTICA_FILAS):
            continue
        for k in range(fila % 2, len(amostras), 2):
            a, b = ponto(fila, k), ponto(fila + 1, k + (1 if k + 1 < len(amostras) else 0))
            if a is None or b is None or falha[fila][k]:
                continue
            pa, pb = ponto_costeiro(*a), ponto_costeiro(*b)
            s += ('    <polyline points="%.1f,%.1f %.1f,%.1f" stroke-width="1.0" '
                  'opacity="%.2f"/>\n'
                  % (*p(pa[0], pa[1]), *p(pb[0], pb[1]), opac * 0.85))
    return s + '  </g>\n'


def gerar_espuma(semente: int) -> str:
    return ('<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d" '
            'viewBox="0 0 %d %d">\n%s</svg>\n'
            % (SAIDA, SAIDA, LARG, ALT, espuma(semente)))


def gerar(com_pieres: bool = True, com_coqueiros: bool = True,
          com_predios: bool = True, com_pavimento: bool = True,
          nivel_vila: int = 1) -> str:
    # ⚠️ O `xmlns:xlink` NÃO É ENFEITE: o ThorVG do Godot só segue um `<use>`
    # pelo `xlink:href` — medido em 17/10, o `href` sozinho não desenha nada.
    s = ('<svg xmlns="http://www.w3.org/2000/svg" '
         'xmlns:xlink="http://www.w3.org/1999/xlink" width="%d" height="%d" '
         'viewBox="0 0 %d %d">\n' % (SAIDA, SAIDA, LARG, ALT))
    _ARVORES_USADAS.clear()

    # ---- água: rampa de profundidade a partir da costa ----
    # Do mais fundo (fundo do ecrã) para o mais raso (encostado na terra), cada
    # faixa por cima da anterior.
    # O BAIXIO acompanha a costa em degraus e tem aresta dura — é raso, e raso
    # tem contorno. O FUNDO não: a primeira versão punha o mar aberto também
    # como faixa em degraus, e a aresta dela cortava a água ao meio numa
    # diagonal reta que lia como falha de desenho. Longe da praia a
    # profundidade não copia o formato da costa, então ali vai degradê.
    #
    # O eixo do degradê é perpendicular, NA TELA, às linhas de mx constante
    # (direção (-MEIA_LARG, MEIA_ALT)) — assim as faixas de cor saem
    # paralelas à costa em vez de tortas em relação a ela.
    nx, ny = MEIA_ALT, 2.0 * MEIA_ALT
    norma = (nx * nx + ny * ny) ** 0.5
    ini = p(12.0, 12.0)
    alcance = (22.0 * MEIA_LARG * nx + 22.0 * MEIA_ALT * ny) / norma
    fim = (ini[0] + alcance * nx / norma, ini[1] + alcance * ny / norma)
    s += ('  <defs><linearGradient id="fundo" gradientUnits="userSpaceOnUse" '
          'x1="%.0f" y1="%.0f" x2="%.0f" y2="%.0f">'
          '<stop offset="0" stop-color="%s"/>'
          '<stop offset="1" stop-color="%s"/>'
          '</linearGradient>'
          # Manchas de profundidade: gradiente RADIAL, e não polígono
          # translúcido. A primeira versão usava um polígono de 12 lados a 0,16
          # de opacidade e na tela saía uma FACETA — aresta reta e visível, que
          # lê como erro de malha em vez de corrente. Gradiente que morre na
          # borda é o que dá mancha sem contorno. `objectBoundingBox` deixa os
          # dois `defs` servirem todas as manchas.
          #
          # ⚠️ E A MANCHA FUNDA TEM DE SER MAIS ESCURA DO QUE A ÁGUA DEBAIXO
          # DELA. Ela era `agua_funda` a 0,30 — e, enquanto esse tom foi o mais
          # claro do largo, cada «mancha funda» CLAREAVA a água (+3 de
          # luminância). Hoje é o tom da sombra do muro, o único abaixo do fundo
          # inteiro da rampa, e escurece de 3 a 6 pontos onde quer que caia.
          '<radialGradient id="mfunda" gradientUnits="objectBoundingBox" '
          'cx="0.5" cy="0.5" r="0.5">'
          '<stop offset="0" stop-color="%s" stop-opacity="0.20"/>'
          '<stop offset="0.55" stop-color="%s" stop-opacity="0.10"/>'
          '<stop offset="1" stop-color="%s" stop-opacity="0"/>'
          '</radialGradient>'
          '<radialGradient id="mcorrente" gradientUnits="objectBoundingBox" '
          'cx="0.5" cy="0.5" r="0.5">'
          '<stop offset="0" stop-color="%s" stop-opacity="0.34"/>'
          '<stop offset="0.6" stop-color="%s" stop-opacity="0.18"/>'
          '<stop offset="1" stop-color="%s" stop-opacity="0"/>'
          '</radialGradient>'
          '<radialGradient id="mrasa" gradientUnits="objectBoundingBox" '
          'cx="0.5" cy="0.5" r="0.5">'
          '<stop offset="0" stop-color="%s" stop-opacity="0.26"/>'
          '<stop offset="0.55" stop-color="%s" stop-opacity="0.13"/>'
          '<stop offset="1" stop-color="%s" stop-opacity="0"/>'
          '</radialGradient>'
          '</defs>\n'
          % (ini[0], ini[1], fim[0], fim[1], C["agua"], C["agua_funda"],
             C["sombra_agua"], C["sombra_agua"], C["sombra_agua"],
             C["sombra_agua"], C["sombra_agua"], C["sombra_agua"],
             C["agua_baixio"], C["agua_baixio"], C["agua_baixio"]))
    s += '  <rect width="%d" height="%d" fill="url(#fundo)"/>\n' % (LARG, ALT)

    # A costa mantém as MESMAS três distâncias e os MESMOS tons medidos, mas
    # em amostras de no máximo um pixel, com meandro longo de duas senóides.
    agua_costeira, sombra_do_muro = campos_costeiros()
    s += agua_costeira

    # ESPUMA na linha de costa. O guia de terrenos do pacote é explícito:
    # "espuma somente nas bordas de praia, rochas, docas e colisões de barcos".
    # É a peça que faltava — a água encostava no cais com uma aresta dura, como
    # dois papéis colados, e é isso que fazia o mar parecer um preenchimento.
    s += espuma_costeira_gradiente()

    # Renda da espuma: a borda regular acima ainda lê como fita. Estes traços
    # curtos e desiguais por cima dela quebram a régua.
    re_ = random.Random(SEMENTE_CHAO + 31)
    s += ('  <g fill="none" stroke="%s" stroke-linecap="round" opacity="0.7">\n'
          % C["espuma"])
    for my0, my1, borda in DEGRAUS:
        my = my0
        while my < my1:
            if not _sob_pier(my):
                a = p(borda + re_.uniform(0.05, 0.30), my)
                b = p(borda + re_.uniform(0.05, 0.30), my + re_.uniform(0.35, 0.9))
                s += ('    <path d="M%.1f,%.1f L%.1f,%.1f" stroke-width="%.1f"/>\n'
                      % (a[0], a[1], b[0], b[1], re_.uniform(1.6, 3.2)))
            my += re_.uniform(0.7, 1.6)
    s += '  </g>\n'

    # VARIAÇÃO DE PROFUNDIDADE: manchas largas e suaves, para o mar não ser
    # três faixas de cor com aresta. O guia chama a isto "manchas largas e
    # suaves, sem ruído excessivo, sugerindo profundidade e corrente".
    #
    # ⚠️ A MANCHA RASA SÓ CAI ONDE A ÁGUA É RASA. Ela é a cor do BAIXIO, e
    # sorteada até 26 unidades da costa punha bancos de areia no meio do mar
    # aberto: das 18, duas caíam visíveis a 17 e a 25 unidades, e eram as
    # manchas claras «ao fundo» da queixa (`124`). Fora da faixa costeira ela
    # não se desenha — e os sorteios continuam todos, pela mesma ordem, para
    # as manchas fundas não mudarem de sítio.
    rv = random.Random(SEMENTE_CHAO + 47)
    for _ in range(18):
        my0, my1, borda = DEGRAUS[rv.randrange(len(DEGRAUS))]
        dmx = rv.uniform(2.0, 26.0)
        cx, cy = p(borda + dmx, rv.uniform(my0 - 3.0, my1 + 5.0))
        rx = rv.uniform(70.0, 190.0)
        ry = rx * rv.uniform(0.34, 0.58)
        mancha = "mfunda" if rv.random() < 0.62 else "mrasa"
        giro = rv.uniform(-40, 40)
        if mancha == "mrasa" and dmx >= ALCANCE_COSTEIRO:
            continue
        s += ('  <ellipse cx="%.0f" cy="%.0f" rx="%.0f" ry="%.0f" fill="url(#%s)" '
              'transform="rotate(%.0f %.0f %.0f)"/>\n'
              % (cx, cy, rx, ry, mancha, giro, cx, cy))

    # As correntes do largo e as MAROLAS no lugar dos riscos «~» (`124`):
    # ver cada função.
    s += correntes()
    s += marolas()

    # ---- terra, degrau por degrau (de trás para a frente) ----
    # O `+ COSTURA` no my1: duas lajes que encostam exatamente no mesmo my
    # deixam meio pixel de fundo entre elas, e na tela isso vira uma linha
    # escura pontilhada atravessando o cais. Como o degrau seguinte é
    # desenhado por cima, esticar um triz o anterior fecha a fresta sem
    # mudar nada do que se vê.
    # As faixas claras que apareciam ATRAVESSANDO o pátio de ponta a ponta não
    # eram estrada: eram a meia unidade de concreto que sobrava entre um degrau
    # e o seguinte, porque o pátio era desenhado com margem em `my`. Do chão
    # elas liam como ruas que iam dar na água e não levavam a lugar nenhum.
    # Agora o pátio ocupa o degrau inteiro (`- COSTURA` no fim, só para não
    # abrir fresta) e as vias são DESENHADAS, com traçado que serve para
    # alguma coisa — ver `vias()`.
    # O CHÃO DAS DUAS PONTAS vem antes do laço dos degraus, e não dentro dele:
    # a ponta sul atravessa o salto entre o degrau 2 e o 3, e não pertence a
    # nenhum dos dois. O `solo` e a mata que o laço desenha caem por cima, na
    # mesma cor — é o mesmo chão.
    # O chão inteiro da praia — terra e areia — vem antes da estrada e da
    # vila. `praia_areia` era a irmã esquecida desta varredura e, desenhada
    # tarde, cobria o asfalto embora as geometrias não se cruzassem.
    for j, a, b in praias():
        s += praia_chao(j, a, b)
        s += praia_areia(j, a, b)
    # Por cima da areia submersa, que as tapava (`124`).
    s += causticas()
    s += arrebentacao()

    for i, (my0, my1, borda) in enumerate(DEGRAUS):
        # ⚠️ A LAJE DO CAIS PARA ONDE O PORTO PARA. Nas duas pontas (ver
        # `na_praia`) o que existe é terra que DESCE até a água, e uma laje
        # com muro a pique ali seria exatamente o "avental cor de areia" que
        # esta etapa não podia ser. O chão da praia vai só até a crista; a
        # rampa da crista à água é desenhada com o enrocamento, mais abaixo.
        for a, b in trechos_de_porto(my0, my1 + COSTURA):
            s += laje(FUNDO_TERRA, a, borda, b, ALT_CAIS,
                      C["cais_topo"], C["cais_dir"], C["cais_esq"])

        # SOLO TROPICAL do fundo do mundo até a calçada de trás da rua. É o
        # chão em que a vila se assenta, e é o que estava faltando: antes esta
        # faixa inteira era pátio, o que punha asfalto atrás das casas.
        fundo_da_rua = borda - RUA_RECUO - CALCADA
        s += poli([p(FUNDO_TERRA, my0, ALT_CAIS), p(fundo_da_rua, my0, ALT_CAIS),
                   p(fundo_da_rua, my1 + COSTURA, ALT_CAIS),
                   p(FUNDO_TERRA, my1 + COSTURA, ALT_CAIS)], C["solo"])
        # ⚠️ A MATA ACABA NO FUNDO DO LOTE, e não no fundo da calçada. Ela ia
        # até `fundo_da_rua`, o que a punha a crescer POR DENTRO da vila —
        # cada árvore ali era tapada pela casa desenhada depois (a vila vem
        # ~20 linhas abaixo), ou seja, polígono pago e nunca visto. Medido:
        # a janela visível da mata acabava exatamente em `borda - VILA_RECUO`
        # nos três degraus que aparecem, então o corte não perdia nada — e com
        # a segunda fileira ele recuou mais um lote, para `VILA_RECUO_2`. A
        # mata é o FUNDO da vila; onde há casa, quem planta é `vila()`.
        # As árvores DA vila são outra coisa e vivem em `vila()`, sorteadas
        # junto com as casas para a profundidade sair certa entre elas.

        # PÁTIO: só entre a calçada da frente e o avental. É esta a área que
        # trabalha, e é ela que troca de terra batida para asfalto.
        frente_da_rua = borda - RUA_RECUO + RUA_LARG + CALCADA
        # E o pátio para junto com a laje: asfalto que morre numa praia é o
        # porto a existir onde ele não está.
        for a, b in trechos_de_porto(my0, my1 + COSTURA):
            s += poli([p(frente_da_rua, a, ALT_CAIS), p(borda - APRON, a, ALT_CAIS),
                       p(borda - APRON, b, ALT_CAIS),
                       p(frente_da_rua, b, ALT_CAIS)],
                      C["asfalto"] if com_pavimento else C["terra"])
            s += manchas_chao(i, frente_da_rua, a, borda - APRON, b, com_pavimento)
            if com_pavimento:
                # Faixa do avental, rente à borda interna dele — mais para
                # dentro riscaria o número da doca, pintado logo ao lado.
                # ⚠️ E DO LADO DO PÁTIO desde a `136`: a 0,05 para dentro do
                # avental ela ficava um pixel além do recorte da obra e
                # aparecia do nada no fim dela; a 0,06 para dentro chega com
                # a primeira faixa de asfalto, que a obra pinta do avental.
                s += ('  <path d="M%.1f,%.1f L%.1f,%.1f" stroke="#e0a81f" '
                      'stroke-width="2.5" fill="none"/>\n' % (
                          *p(borda - APRON - 0.06, a + 0.3, ALT_CAIS),
                          *p(borda - APRON - 0.06, b - 0.3, ALT_CAIS)))

    # O CHÃO DE TRÁS, com textura e com o morro (`127`): depois do laço,
    # porque o recorte é a união do solo de todos os degraus e o morro de um
    # degrau sobe, na tela, por cima da faixa do vizinho; antes da mata baixa,
    # que cresce nele, e da rua e da vila, que estão à frente dele.
    s += campo_do_chao()
    # O granito das clareiras e o relvado da vila (`130`): chão, logo antes
    # da mata baixa, da rua e da vila, que estão à frente dele.
    s += pedras_do_morro()[0]
    s += relvado_da_vila()
    for j, a, b in praias():
        s += restinga_rasteira(j, a, b)
    for i, (my0, my1, borda) in enumerate(DEGRAUS):
        s += vegetacao_do_solo(i, FUNDO_TERRA, my0, borda - VILA_RECUO_2, my1)
    s += mata_baixa()

    s += vias(com_pavimento)
    s += vias_detalhes(com_pavimento)
    s += vila(nivel_vila, com_pavimento)

    # ---- concreto do cais: juntas e desgaste ----
    # O cais era a única superfície ainda 100% chapada da cena — pátio já tem
    # manchas, água já tem faixas. Junta de dilatação resolve duas coisas de
    # uma vez: quebra a chapa E dá escala, porque o olho conhece o tamanho de
    # uma placa de concreto e usa isso para medir o resto do porto.
    #
    # ⚠️ E O DESGASTE ESTAVA A SER PINTADO NO RELVADO. Até 04/09 o centro de
    # cada mancha saía de `uniform(FUNDO_TERRA, borda)` — o bloco de terra
    # INTEIRO, do fundo do mundo à beira do cais —, e não da faixa de concreto.
    # Onze manchas de concreto (#a8b2b8, cinza-azulado) caíam em cima da mata e
    # da vila, e mediam 19 a 37 px de raio: no relvado elas lêem como falha de
    # grama, que é a queixa "a vegetação é bem pobre" a ser causada por um
    # descuido do CAIS. Medido na captura: 2.324 px do tom resultante, num
    # recorte de 320x300 da área verde.
    #
    # A junta de dilatação, dez linhas abaixo, sempre esteve certa — e o
    # comentário dela diz porquê, com todas as letras: "levá-la mais para
    # dentro riscava a terra batida, que não tem junta nenhuma". A mesma frase
    # valia para a mancha, e a mancha estava logo acima sem ninguém reparar.
    # Duas regras irmãs, uma escrita e a outra não.
    #
    # O recorte é o mesmo idioma do `manchas_chao`: sem ele uma mancha de 40 px
    # de raio numa faixa de 39 px de largura transborda para a água.
    #
    # E o `clip-path` FUNCIONA no importador do Godot — medido em 04/09, e vale
    # escrever porque o ThorVG não desenha tudo o que o SVG permite (`<text>`,
    # por exemplo, sai vazio, e é por isso que os números das docas são
    # estêncil). Antes desta correção havia 2.324 px de mancha de concreto na
    # área verde da captura; depois, zero — se o recorte fosse ignorado, os
    # dois números seriam iguais.
    rc = random.Random(SEMENTE_CHAO + 40)
    for i, (my0, my1, borda) in enumerate(DEGRAUS):
        # E o recorte já não é o degrau inteiro: é o trecho de PORTO dele.
        # Concreto desgastado numa praia é o mesmo erro que o desgaste no
        # relvado, um degrau acima.
        porto = trechos_de_porto(my0, my1 + COSTURA)
        if not porto:
            continue
        pmy0, pmy1 = porto[0]
        quina = [p(borda - APRON, pmy0, ALT_CAIS), p(borda, pmy0, ALT_CAIS),
                 p(borda, pmy1, ALT_CAIS),
                 p(borda - APRON, pmy1, ALT_CAIS)]
        s += '  <clipPath id="cais%d"><polygon points="%s"/></clipPath>\n' % (
            i, " ".join("%.1f,%.1f" % q for q in quina))
        s += '  <g clip-path="url(#cais%d)">\n' % i
        for _ in range(9):
            cx, cy = p(rc.uniform(borda - APRON, borda),
                       rc.uniform(pmy0, pmy1), ALT_CAIS)
            raio = rc.uniform(16.0, 40.0)
            s += ('    <ellipse cx="%.0f" cy="%.0f" rx="%.0f" ry="%.0f" fill="%s" '
                  'opacity="0.35"/>\n' % (cx, cy, raio, raio / 2.0, C["cais_mancha"]))
        s += '  </g>\n'
        # A junta vive na FAIXA DE CONCRETO que sobra entre o pátio e a beira
        # (o pátio come até `borda - 1.3`). Levá-la mais para dentro riscava a
        # terra batida, que não tem junta nenhuma.
        my = pmy0 + 1.2
        while my < pmy1 - 0.3:
            s += ('  <path d="M%.1f,%.1f L%.1f,%.1f" stroke="%s" stroke-width="1.8" '
                  'opacity="0.85" fill="none"/>\n'
                  % (*p(borda - 1.25, my, ALT_CAIS), *p(borda, my, ALT_CAIS),
                     C["cais_junta"]))
            my += 1.9

    # ---- número de cada doca, pintado na faixa de concreto ----
    # Vai DEPOIS da junta e da faixa amarela porque tinta de piso é a última
    # camada a ser aplicada — e porque assim o dígito não sai riscado ao meio.
    for i, (my0, my1, borda) in enumerate(PIERES):
        s += pintura_doca(str(i + 1), borda - 1.20, (my0 + my1) / 2.0 - 0.20,
                          1.05, C["tinta"], 0.90)

    # ---- pé do cais: sombra do muro, enrocamento e espuma ----
    # Sem isto o cais encontra a água numa aresta limpa, que é o que fazia a
    # margem parecer recortada em papel.
    #
    # A primeira tentativa foi uma FAIXA chapada de cinza com seixos regulares
    # por cima. Na tela leu como sujeira pintada no muro: faixa uniforme não
    # vira pedra, vira listra. O que faz o olho ler enrocamento é o CONTORNO
    # irregular — pedras de tamanhos diferentes, encavaladas, cada uma tapando
    # um pedaço da anterior.
    # E ela para nas duas pontas: onde a terra desce em rampa não há muro
    # nenhum a lançar sombra, e uma faixa escura ao pé de uma praia lê-se como
    # sujeira na água. Desde a `124` ela esvai em vez de acabar numa aresta, e
    # sai do campo costeiro (`campos_costeiros`).
    s += sombra_do_muro

    #
    # A SEGUNDA correção veio do playtest: as pedras eram espalhadas por
    # degrau, cada um ao longo do seu próprio `borda`, e nas quinas da escada
    # isso as jogava para dentro do degrau seguinte — que é mais largo. Vistas
    # na tela pareciam cascalho pintado no concreto do cais. Agora elas andam
    # pelo CONTORNO (andar_costa) e só se afastam na direção do mar, então
    # nenhuma pode cair em terra: a quina passou a ser uma quina de pedra.
    #
    # A TERCEIRA correção veio do mesmo playtest, e é a queixa de que as pedras
    # eram "chapadas": cada uma era UMA elipse de um tom só, e elipse de um tom
    # não tem lado nenhum. Agora cada pedra é um SÓLIDO FACETADO — um polígono
    # irregular de topo e uma saia por aresta —, que é o vocabulário do resto
    # do mapa: é o mesmo desenho da `caixa()` e da `laje()`, reduzido a um
    # seixo. Custa dois a quatro nós por pedra e nenhuma imagem nova.
    #
    # ⚠️ DUAS FORMAS FORAM TENTADAS ANTES E DESCARTADAS, e não por gosto:
    #   · elipse extrudada (tampo do mesmo tamanho da base) sai FICHA DE
    #     PÔQUER — cilindro perfeito, e onde um tampo claro caía sobre a saia
    #     escura da pedra ao lado lia-se um ANEL, que o olho lê como buraco;
    #   · elipse com uma cópia menor deslocada para cima lê como elipse chapada
    #     com sombra por baixo, que é o defeito de origem outra vez.
    #   O que faz uma pedra pequena ler como pedra é ARESTA: contorno quebrado
    #   e duas faces de tons diferentes, como em toda a outra peça deste mapa.
    #
    # ⚠️ E ORDENADAS POR PROFUNDIDADE, o que enquanto foram chapadas não era
    # preciso. Duas elipses lisas encavaladas dão o mesmo desenho em qualquer
    # ordem; duas pedras COM ALTURA, não — a de trás desenhada por último tapa
    # a da frente pela saia, e o enrocamento sobe em vez de descer. Aqui, como
    # no cenário do jogo, o Y de tela é a profundidade.
    r = random.Random(SEMENTE_CHAO + 90)
    tons = [C["pedra"], C["pedra_media"], C["pedra_clara"]]
    pedras = []
    for mx, my, (nmx, nmy), (tmx, tmy) in andar_costa(0.06, (0.22, 0.40), r):
        # O enrocamento PARA onde o píer começa. Ele não some por baixo do
        # tabuado: ali não há enrocamento nenhum, porque ninguém joga pedra na
        # frente da entrada de um píer. Sem isto a faixa cruzava a raiz do
        # tabuado e as pedras liam-se como se estivessem POR CIMA dele — o
        # muro é que continua atrás, e é o que se vê.
        # Nem sob o píer nem nas duas pontas: enrocamento é blindagem de cais,
        # e a praia tem as pedras dela — poucas e avulsas, em `praia_areia`.
        if _sob_pier(my) or na_praia(my):
            continue
        for _ in range(2):
            fora = r.uniform(0.0, 0.42)
            ao_longo = r.uniform(-0.12, 0.12)
            px, py = p(mx + nmx * fora + tmx * ao_longo,
                       my + nmy * fora + tmy * ao_longo)
            rx = r.uniform(4.5, 9.5)
            ry = rx * r.uniform(0.48, 0.62)
            # O contorno: cinco ou seis vértices com o raio e o ângulo
            # sacudidos. Polígono REGULAR sai cristal, e nesta escala um
            # cristal lê-se como erro de desenho; a irregularidade é o que
            # faz cinco arestas passarem por pedra.
            n = r.choice((5, 6))
            a0 = r.uniform(0.0, math.tau)
            canto = []
            for k in range(n):
                a = a0 + math.tau * k / n + r.uniform(-0.25, 0.25)
                f = r.uniform(0.78, 1.0)
                canto.append((px + math.cos(a) * rx * f,
                              py + math.sin(a) * ry * f))
            pedras.append((py, canto, rx * r.uniform(0.30, 0.62),
                           tons[r.randrange(3)]))

    for _py, canto, h, topo in sorted(pedras, key=lambda q: q[0]):
        s += com_saia(canto, h, topo)

    # ---- píeres ----
    # Em jogo o píer TROCA DE ESTADO (vaga por construir -> píer construído), e
    # o que muda de estado não pode estar assado no fundo. Com --sem-pieres o
    # mapa sai só com água e terra, e as três vagas viram props posicionados
    # por cima — que é como o Main.tscn os usa.
    for my0, my1, borda in (PIERES if com_pieres else []):
        s += laje(borda, my0, borda + PIER_ALCANCE, my1, ALT_PIER,
                  C["madeira"], C["madeira_dir"], C["madeira_esq"])
        for i in range(1, 6):
            mx = borda + (PIER_ALCANCE / 6) * i
            s += ('  <path d="M%.1f,%.1f L%.1f,%.1f" stroke="%s" '
                  'stroke-width="1.8" fill="none"/>\n' % (
                      *p(mx, my0, ALT_PIER), *p(mx, my1, ALT_PIER), C["madeira_dir"]))
        for my in (my0 + 0.3, my1 - 0.3):
            s += caixa(borda + 0.2, my - 0.16, borda + 0.55, my + 0.16,
                       ALT_PIER, 9, "#4a535a", "#2b3238", "#3c4348")

    # ---- prédios no pátio, de trás para a frente ----
    B = ALT_CAIS
    # Prédios e contêineres saem do mapa quando --sem-predios: eles TROCAM DE
    # ESTADO em jogo (ruína -> consertado), e o que muda de estado não pode
    # estar assado no fundo. Mesma regra dos píeres e dos coqueiros.
    # Carga empilhada no pátio: só faz sentido com o chão pavimentado.
    if com_pavimento:
        # ── OS DOIS LOTES RESERVADOS ────────────────────────────────────
        #
        # ⚠️ AQUI HAVIA SEIS CAIXAS DE COR CHAPADA, e a segunda jogada no
        # telefone leu-as pelo que eram: *"não entendi pq existem os
        # placeholders azul, vermelho, amarelo e verde"*. Ele tem razão, e a
        # razão é de vocabulário: eram volumes de cor primária sem canto
        # escuro, sem corrugado e sem sombra, num jogo que TEM vocabulário de
        # contêiner — o do convés do píer e o da carreta. Uma caixa que não
        # usa o vocabulário da coisa que representa lê como marcador de
        # posição, porque é isso que ela é.
        #
        # O que ele pediu no lugar foi *"uma marcação de que algo no futuro
        # será construído ali, por exemplo, a estação de reabastecimento e a
        # oficina de consertos"* — as duas estruturas que o GDD põe na Fase 2
        # e que `docs/decisoes/008` deixou de fora de propósito.
        #
        # ⚠️ E O VOCABULÁRIO DE "AINDA NÃO CONSTRUÍDO" JÁ EXISTIA NO JOGO: a
        # terceira vaga de doca mostra as estacas velhas sob contorno
        # tracejado. O lote reservado é a mesma ideia em terra — chão limpo
        # mais escuro, contorno tracejado e quatro estacas de topografia nos
        # cantos. Não inventa mecânica nenhuma: é uma marca no chão.
        # ⚠️ OS DOIS SÍTIOS SÃO MEDIDOS, E OS PRIMEIROS ESTAVAM ERRADOS. Eles
        # nasceram a olho em (2,45 / 2,6) e (2,45 / 18,6) — e o `my` de cada um
        # calhava ser exatamente onde começa o ACESSO AO BERÇO que o `vias()`
        # desenha logo acima. Ninguém viu enquanto o camião passava reto pela
        # rua; assim que ele passou a entrar na doca, foi encostar em cima da
        # demarcação. Os dois também transbordavam para o avental: 1,7 de
        # largura a partir de um recuo de 2,45 acaba em `borda - 0,75`, e o
        # pátio acaba em `borda - APRON`.
        #
        # Varrido o pátio inteiro contra os acessos, os cotovelos, os dois
        # prédios e os props da cena, um lote de 2,0 x 1,7 tem UMA posição
        # livre — e são precisas duas, uma por estrutura de Fase 2. A 1,6 x 1,4
        # abrem-se duas com folga de 0,73 e 0,30 unidades, e são estas. O
        # bloco D13, §8, do teste de design tranca-as contra os acessos publicados.
        for recuo, my in LOTES_RESERVADOS:
            borda = _borda_em(my)
            s += lote_reservado(borda - recuo, my, borda - recuo + LOTE_LARG,
                                my + LOTE_COMP, B)

    if not com_predios:
        s += "</svg>\n"
        return _com_as_arvores(s)

    s += predio(-1.0, -3.5, 3.0, 0.5, B, 34, C["telhado"], "#8f3822", "#a8452a")
    s += predio(2.0, 5.0, 6.4, 9.4, B, 44, "#3f6f4a", "#2a4d33", "#335c3d", 3)
    s += predio(6.0, 13.0, 10.4, 17.4, B, 32, C["telhado"], "#8f3822", "#a8452a")
    s += predio(10.0, 21.0, 14.4, 25.4, B, 30, "#3f6f4a", "#2a4d33", "#335c3d")


    # Coqueiros chapados: só saem quando --sem-coqueiros. Eles viraram props
    # low-poly com copa e tronco SEPARADOS, porque o que balança não pode
    # estar assado no fundo — a mesma razão que tirou os píeres daqui.
    for mx, my in ([] if not com_coqueiros else
                   [(-4.0, -2.0), (-3.0, 6.0), (0.0, 14.0), (3.0, 22.0), (7.0, 29.0)]):
        bx, by = p(mx, my, ALT_CAIS)
        s += '  <path d="M%.1f,%.1f l0,-22" stroke="#7a4d2a" stroke-width="4"/>\n' % (bx, by)
        s += '  <g transform="translate(%.1f,%.1f)">\n' % (bx, by - 22)
        for ang in range(0, 360, 51):
            s += ('    <ellipse rx="6" ry="14" cy="-11" fill="%s" '
                  'transform="rotate(%d)"/>\n' % (C["verde"], ang))
        s += '  </g>\n'

    s += "</svg>\n"
    return _com_as_arvores(s)


# ── TABELA DE ÂNCORAS ────────────────────────────────────────────────────
# O gerador sabe onde tudo está no MUNDO; o Main.tscn põe os props por
# OFFSET DE TELA. Nada obrigava os dois a concordarem — e quando discordam o
# píer renderizado pousa ao lado do píer desenhado, o que só se descobre
# olhando. Exportar a tabela transforma "olhar" em asserção: o teste de design
# lê este JSON e confere cada prop contra ele.
#
# Tudo em pixels do PNG QUE O JOGO CARREGA — espaço de TELA, e não de desenho
# —, com h=0, que é onde o quadro de 512 de cada prop tem o seu centro (ver
# `para_pixel` em gerar_props_iso.py). É por isso que o `px()` abaixo chama
# `tela()` e não `p()`: ver o bloco do enquadramento no topo do arquivo.
#
# E a PROJEÇÃO publicada é a efetiva — `MEIA_LARG * ZOOM` —, porque é com ela
# que o teste de design desprojeta um prop de volta ao mundo. Publicar os 30
# do desenho daria uma tabela inteira de posições plausível e errada.


def tabela_ancoras() -> dict:
    def px(mx, my, h=0.0):
        x, y = tela(mx, my, h)
        return [round(x, 1), round(y, 1)]

    pieres = []
    for i, (my0, my1, borda) in enumerate(PIERES):
        pieres.append({
            "doca": i + 1,
            "centro": px(borda + PIER_ALCANCE / 2, (my0 + my1) / 2),
            "barco": px(borda + PIER_ALCANCE / 2, my1 + 1.6),
            "raiz": px(borda, (my0 + my1) / 2),
        })


    # Faixas em `mx` medidas do cais, por degrau. O teste usa isto para saber
    # se um prop caiu no asfalto da rua ou dentro de um lote da vila.
    faixas = []
    for my0, my1, borda in DEGRAUS:
        faixas.append({
            "my": [my0, my1], "borda": borda,
            "avental": [borda - APRON, borda],
            "rua": [borda - RUA_RECUO - CALCADA, borda - RUA_RECUO + RUA_LARG + CALCADA],
            # A PISTA SEM A CALÇADA. O `rua` acima é o CERCO (prédio em cima do
            # passeio também está errado) e por isso inclui-a; o D20 lê a cor
            # do que tem de ser rodagem, e ali a calçada é justamente o que não
            # pode aparecer. São duas perguntas, e por isso são dois números.
            "asfalto": [borda - RUA_RECUO, borda - RUA_RECUO + RUA_LARG],
            "vila": [borda - VILA_RECUO, borda - VILA_RECUO + VILA_PROF],
            # A fileira de trás, publicada para o D14 poder conferir que as
            # duas se separam por mais de um telhado — a régua tem de sair do
            # gerador, senão o teste passa a ter a sua própria cópia dela.
            "vila_fundo": [borda - VILA_RECUO_2, borda - VILA_RECUO_2 + VILA_PROF],
        })

    # ⚠️ E OS COTOVELOS, que são rua tanto quanto as faixas retas.
    #
    # Publicá-los custou um bloco inteiro de trabalho perdido. O D2 conferia a
    # pegada dos dois prédios contra `rua` e dizia OK, e o jogador continuava a
    # ver os prédios em cima do asfalto: entre um degrau e o seguinte a rua
    # VIRA, e o cotovelo que ela desenha para virar corre em `mx` por cinco
    # unidades — mesmo asfalto, sem faixa nenhuma a declará-lo. Tanto o
    # armazém como o escritório estavam com meia unidade de pegada lá dentro.
    #
    # Os números saem das MESMAS expressões que o `vias()` usa para desenhar, e
    # incluem a calçada: prédio em cima do passeio também está errado.
    cotovelos = []
    for i, (_my0, my1, borda) in enumerate(DEGRAUS[:-1]):
        prox = DEGRAUS[i + 1][2]
        # ⚠️ O `mx`/`my` CONTINUA A SER O RETÂNGULO, e o desenho já não é um.
        # Desde 08/09 o cotovelo tem as duas pontas salientes chanfradas, logo
        # o retângulo publicado é MAIOR do que o asfalto — e é assim que tem de
        # ser: ele é o cerco contra o qual o D2 mede pegada de prop, e um cerco
        # que erra tem de errar para o lado seguro. O `chanfro` sai à parte,
        # para quem precisa da forma DESENHADA (o D20) a poder reconstruir.
        cotovelos.append({
            "mx": [borda - RUA_RECUO - CALCADA, prox - RUA_RECUO + RUA_LARG + CALCADA],
            "my": [my1 - RUA_LARG - CALCADA, my1 + CALCADA],
            "asfalto_mx": [round(borda - RUA_RECUO, 3),
                           round(prox - RUA_RECUO + RUA_LARG, 3)],
            "asfalto_my": [round(my1 - RUA_LARG, 3), round(my1, 3)],
            # O raio dos arcos das duas quinas salientes (`136`), que era
            # um chanfro: o D13 §7j reconstrói o desenho com ele.
            "raio": round(RAIO_COTOVELO, 3),
            # O raio das duas quinas de DENTRO, centrado do lado do lote: o
            # D45 reconstrói com ele a calçada da vila, por onde corre a
            # fiação (`140`).
            "raio_dentro": round(RAIO_DE_DENTRO, 3),
            # A diagonal de que o chanfro foi derivado, para o jogo a
            # poder conferir contra a dele (D13 §7i).
            "corte_da_curva": round(CORTE_DA_CURVA, 4),
        })

    # ⚠️ E OS ACESSOS AOS BERÇOS, publicados pela mesma razão que os cotovelos:
    # eles são asfalto que nenhuma faixa declara. O `vias()` desenha, para cada
    # píer, uma ligação da rua até o avental — é ela que explica para que serve
    # a estrada —, e até 07/09 ela existia só no desenho. O camião que passa
    # levava a carga da doca do mesmo índice e passava reto; para ele ENTRAR na
    # doca é por aqui que ele entra, e sem estes números o D13 não teria contra
    # o que conferir o desvio.
    #
    # Os limites saem das MESMAS expressões que o `vias()` usa para desenhar.
    acessos = []
    for j, (my0, my1, borda) in enumerate(PIERES):
        meio = (my0 + my1) / 2.0
        acessos.append({
            "doca": j + 1,
            "mx": [round(borda - RUA_RECUO + RUA_LARG, 3), round(borda - APRON, 3)],
            "my": [round(meio - 0.6, 3), round(meio + 0.6, 3)],
            # A boca do acesso na faixa do lado da água: o meio dela, na altura
            # do berço. É onde o RETORNO vira (a `entrada` do `ACESSOS_DOCA`
            # do `TrafegoDeCamioes.gd`); a ida vira à mesma altura na faixa da
            # vila.
            "entrada": [round(faixa_do_caminhao(borda), 3), round(meio, 3)],
        })

    # E O PÁTIO, publicado para a obra dele (`121`): durante os três dias o
    # jogo recorta o mapa PRONTO por cima do de terra, e o recorte tem de cair
    # exatamente onde o gerador troca terra batida por asfalto. Os limites
    # saem das MESMAS expressões que pintam o pátio, em `gerar()` — da frente
    # da rua ao avental, só nos trechos de PORTO (`trechos_de_porto`) —, e o
    # D45 confere a cópia do `ObraNoMapa.gd` contra esta lista.
    patio = []
    for my0, my1, borda in DEGRAUS:
        for a, b in trechos_de_porto(my0, my1 + COSTURA):
            patio.append({
                "my": [round(a, 3), round(b, 3)],
                "mx": [round(borda - RUA_RECUO + RUA_LARG + CALCADA, 3),
                       round(borda - APRON, 3)],
            })

    # E A OBRA DA RUA (`136`): os pedaços da rua que a obra do pátio recapeia,
    # cada um com o dia em que fica pronto. O `ObraNoMapa.gd` copia-os (o JSON
    # não vai no pacote) e o D45 confere a cópia contra esta lista; o D49 mede
    # nos dois mapas que tudo o que muda entre eles cai dentro deles ou do
    # pátio.
    obra_rua = [{"quadro": q, "pontos": [[x, y] for x, y in pol]}
                for q, pol in obra_da_rua()]
    cones_obra = [{"quadro": q, "pontos": [[x, y] for x, y in pts]}
                  for q, pts in cones_da_obra()]
    # E O MOBILIÁRIO DA RUA (`140`): os cavaletes entre os cones, e os postes
    # e as placas, cada um com o dia em que o trecho dele fica pronto. O jogo
    # copia-os como copia os cones, e o D45 confere a cópia.
    cavaletes_obra = [{"quadro": q, "pontos": [[x, y] for x, y in pts]}
                      for q, pts in cavaletes_da_obra()]
    mobiliario = [{"tipo": t, "ponto": [x, y], "quadro": q}
                  for t, x, y, q in mobiliario_da_rua()]

    # E OS LOTES RESERVADOS, publicados para o D13 §8 os poder conferir contra os
    # acessos. Um deles já esteve em cima de um; sem os números aqui, a única
    # coisa que denunciava isso era um camião estacionado por cima da marca.
    reservados = []
    for recuo, my in LOTES_RESERVADOS:
        b = _borda_em(my)
        reservados.append({
            "mx": [round(b - recuo, 3), round(b - recuo + LOTE_LARG, 3)],
            "my": [round(my, 3), round(my + LOTE_COMP, 3)],
        })

    # ⚠️ E AS DUAS PONTAS DE AREIA, publicadas pela mesma razão que os
    # cotovelos: elas são chão em que NÃO se pousa equipamento de porto, e
    # nada no `Main.tscn` sabia disso. A empilhadeira ficou na restinga da
    # ponta sul assim que ela existiu, e nenhuma asserção reprovou.
    #
    # O `recuo` é o MAIOR que a crista alcança (a ondulação incluída), de modo
    # que a faixa de areia publicada seja sempre um pouco mais larga do que a
    # desenhada: um cerco que erra tem de errar para o lado seguro.
    # ⚠️ E O RECUO DEIXOU DE SER UMA FÓRMULA, porque a crista deixou de ser uma
    # linha paralela ao cais. Ele valia `PRAIA_PROF * (1 + amp)` — a conta da
    # ondulação de 02/09 — e com a costa desenhada a linha de água também anda
    # para dentro da terra, levando a duna com ela. Uma fórmula que não some as
    # duas coisas publica um cerco MAIS ESTREITO do que a areia que o mapa
    # pinta, e um cerco que erra para o lado errado deixa passar exatamente o
    # que existe para pegar. Aqui ele é MEDIDO na crista desenhada, com um
    # centésimo de folga.
    areia = [{"my": [round(my_a, 2), round(my_b, 2)], "recuo": recuo}
             for (_j, my_a, my_b), recuo in zip(praias(), recuos_das_praias())]

    return {
        # O `fundo_terra` é UNIDADE DE MUNDO e por isso não leva `ZOOM`. Ele
        # entra aqui para o bloco D16 do teste de design poder conferir que o
        # mundo transborda o quadro pelos quatro lados — que é o contrato
        # escrito no cabeçalho deste arquivo e que, até 05/09, nada verificava.
        "projecao": {"cx": round(CX * ZOOM, 4), "cy": round(CY * ZOOM, 4),
                     "meia_larg": MEIA_LARG * ZOOM, "meia_alt": MEIA_ALT * ZOOM,
                     "alt_cais": ALT_CAIS * ZOOM, "fundo_terra": FUNDO_TERRA},
        "praias": areia,
        # ⚠️ O CONTORNO DESENHADO, em pixels do PNG — e ele é NOVO por uma razão
        # que este projeto já pagou três vezes: toda a maquinaria de cerco aqui
        # pergunta POSIÇÃO ou COR a um ponto, e nenhuma perguntava a FORMA de
        # uma linha. A costa das duas pontas deixou de ser a escada (item 8) e
        # nada saberia dizer se ela voltou a ser: o desenho continuaria a
        # passar em D15, D20, D21 e D27 com um V de dois traços em cada ponta.
        #
        # Sai daqui a INTENÇÃO (a linha que o gerador desenhou) e o raster diz
        # o RESULTADO (de que cor é cada lado dela) — as duas fontes que o D24
        # ensinou a separar. É decimado a ~0,3 unidades porque o que se mede
        # com ele é a forma, e 500 pontos não dizem mais sobre forma do que 170.
        "contorno": [[round(x, 1), round(y, 1)] for x, y in
                     (tela(mx, my) for mx, my in linha_costeira(0.0, 0.3))],
        # AS CORES DA RUA, e elas saem do dicionário `C` de propósito. O D20
        # compara a cor lida do render com estas; uma lista escrita à mão do
        # lado do Godot envelheceria calada na primeira vez que alguém mexesse
        # na paleta — que é a mesma razão de `medir_enquadramento` já receber a
        # sua por JSON em vez de a repetir.
        "cores_da_rua": {"asfalto": C["asfalto_via"], "calcada": C["calcada"],
                         "meiofio": C["meiofio"]},
        # O D20 lê estas cores no mapa rasterizado para garantir que a praia,
        # que é chão, nunca volta a ser pintada por cima da rota da estrada.
        "cores_da_areia": {"areia": C["areia"],
                            "areia_seca": C["areia_seca"],
                            "areia_face": C["areia_face"],
                            "areia_funda": C["areia_funda"]},
        # AS FAIXAS DE ÁGUA, pela mesma razão e para a mesma pergunta. O que o
        # D21 quer saber é se a Zona de Espera fundeia AO LARGO, e a divisão
        # que responde isso está aqui e não num número: `costeiras` são as três
        # bandas que ACOMPANHAM a costa — o baixio, a rasa e a média, desenhadas
        # a `costa(0, d)` — e `largo` é o que fica para lá delas, que é o fundo
        # do mapa. Um barco atracado está numa costeira por construção; um
        # fundeado não pode estar.
        #
        # ⚠️ E ISTO É UMA DIVISÃO, NÃO UMA LISTA DE TONS. Quem acrescentar uma
        # quarta banda costeira tem de a pôr aqui, senão ela passa a contar como
        # largo e o D21 deixa de reprovar o que existe para reprovar.
        #
        # O `alcance_costeiro` diz onde o largo COMEÇA, em unidades: o D46
        # parte dali para provar que a água escurece até ao fundo da tela
        # (`124`), e escrito à mão no teste seria o espelho que envelhece.
        "cores_da_agua": {
            "costeiras": [C["agua_baixio"], C["agua_rasa"], C["agua_media"]],
            "largo": [C["agua"], C["agua_funda"]],
            "alcance_costeiro": ALCANCE_COSTEIRO,
        },
        "pegadas": {k: list(v) for k, v in sorted(PEGADAS.items())},
        "mapa": {"largura": SAIDA, "altura": SAIDA},
        "pieres": pieres,
        "faixas": faixas,
        "cotovelos": cotovelos,
        "acessos": acessos,
        "patio": patio,
        "obra_da_rua": obra_rua,
        "obra_dias": OBRA_DIAS,
        "cones_da_obra": cones_obra,
        "cavaletes_da_obra": cavaletes_obra,
        "mobiliario_da_rua": mobiliario,
        # A caixa da subestação (quarta passagem da `140`), para o D45 a
        # conferir contra o campo onde pousa.
        "subestacao": {"centro": list(SUBESTACAO), "tam": list(SUBESTACAO_TAM)},
        # O que a vila tapa da fiação (quarta passagem da `140`): o jogo copia-o
        # para esconder o fio atrás da torre da igreja.
        "fiacao_atras_da_vila": [{"vao": [a, b], "x0": x0,
                                  "teto": [round(t, 1) for t in teto]}
                                 for a, b, x0, teto in fiacao_atras_da_vila()],
        # E o que ela tapa das peças, a sombra do poste incluída (quinta
        # passagem): o jogo copia-o para o shader.
        "mascara_da_vila": [{"peca": k, "x0": x0, "teto": [round(t, 1) for t in teto]}
                            for k, x0, teto in mascara_da_vila()],
        # Os carros da viela (`141`) e o que os lotes da vila lhes tapam: o
        # jogo copia os dois, e o D50 confere a cópia contra esta tabela.
        "carros_da_viela": [{"prop": p, "ponto": [x, y], "fase": f, "obras": o}
                            for p, x, y, f, o in carros_da_viela()],
        "mascara_dos_carros": [{"carro": k, "x0": x0,
                                "teto": [round(t, 1) for t in teto]}
                               for k, x0, teto in mascara_dos_carros()],
        "lotes_reservados": reservados,
        # ⚠️ O `tipo` ENTRA NA TABELA para o teste de design poder perguntar ao
        # DESENHO se a igreja, a praça e a obra chegaram lá. Sem ele o bloco
        # D24 teria de recalcular a escolha, e um teste que reconstrói a
        # decisão que está a conferir é um espelho — a regra do sorteio de
        # motivos. Assim a tabela diz a INTENÇÃO e o raster diz o RESULTADO.
        "lotes": [{"mx": round(l[0], 2), "my": round(l[1], 2),
                   "dmx": round(l[2], 2), "dmy": round(l[3], 2),
                   "fundo": bool(l[5]),
                   "casa": l[6],
                   "tipo": tipos_dos_lotes().get(i, ""),
                   "canto": px(l[0], l[1], ALT_CAIS),
                   # O alto do telhado, para o D47 §9 (`130`).
                   "telhado": telhado_do_lote(l)}
                  for i, l in enumerate(lotes_da_vila())],
        # As cores com que a vila pinta o que não é casa. O D24 lê-as daqui em
        # vez de as escrever à mão, pela mesma razão que o D20 lê as da rua.
        "cores_da_vila": {"calcada": C["calcada"], "telha_c": C["telha_c"],
                          "casa_a": C["casa_a"], "tronco": C["tronco"],
                          "telha_d": C["telha_d"], "meiofio": C["meiofio"],
                          "telha_a": C["telha_a"], "telha_b": C["telha_b"],
                          "telha_torre": C["telha_torre"]},
        "provas_da_vila": [{"lote": i, **v}
                           for i, v in sorted(pontos_de_prova().items())],
        # A MATA DO MORRO (`127`): onde pousa o pé de cada árvore do Blender,
        # pela ordem de profundidade, e o CONTORNO DA VILA que nenhuma delas
        # pode atravessar — a linha mais alta que a vila e as vias pintam em
        # cada coluna da tela. O D47 lê os dois: confere a cópia do
        # `MataNoMapa.gd` contra a lista e os pixels de cada árvore contra o
        # contorno. O `h` é a altura do chão do morro no pé, em TELA.
        # E A RESTINGA DAS PONTAS na mesma lista, com `chao` a dizer qual
        # das duas perguntas o D47 lhe faz: o contorno da vila ou a crista à
        # frente (`cristas`, uma polilinha de TELA por ponta).
        "mata": [{"arvore": v, "mx": mx, "my": my,
                  "h": round(h * ZOOM, 2), "pe": [x, y], "chao": chao}
                 for v, mx, my, h, x, y, chao in plantas_do_mapa()],
        "cristas": [[list(q) for q in c] for c in cristas_da_tela()],
        # O granito das clareiras (`130`): a caixa de TELA e a profundidade
        # de cada pedra — o D47 §8 confere que nenhuma árvore de trás a tapa.
        "pedras_do_morro": pedras_do_morro()[1],
        # ⚠️ O CONTORNO DA VILA É POR LOTE desde a `130` (`pecas_da_vila`): o
        # de cada terreno, com a caixa dele no mundo, e o das vias à parte. O
        # mínimo da coluna, que a `127` publicava, proibia uma árvore à
        # frente de uma casa que lhe ficava atrás.
        "horizonte_das_vias": horizonte_das_vias(),
        "pecas_da_vila": [{"caixa": list(caixa), "x0": min(cols),
                           "topo": [cols.get(c, float(SAIDA))
                                    for c in range(min(cols), max(cols) + 1)]}
                          for caixa, cols in pecas_da_vila() if cols],
        # As árvores EMBUTIDAS no mapa (`127`, segunda passagem): a da vila e a
        # mata baixa do quintal de trás. Não são nós da cena; o catálogo da
        # folha dos props ancora nelas as espécies que não são prop.
        "arvores_embutidas": [{"arvore": v, "pe": [x, y], "escala": k,
                               "prof": prof, "chao": chao}
                              for v, x, y, k, prof, chao in arvores_embutidas()],
    }


# As duas sementes da espuma. A primeira é a que o mapa usava quando ela era
# assada — assim a camada 0 sai com as MESMAS manchas de sempre e a mudança
# não é uma costa nova, é a mesma costa que agora respira.
SEMENTES_ESPUMA = (SEMENTE_CHAO + 55, SEMENTE_CHAO + 56)


def lista_da_mata() -> str:
    """A constante `ARVORES` do `MataNoMapa.gd`, pronta a colar.

    O JSON da tabela não vai no pacote exportado, e por isso o jogo leva uma
    cópia (a razão da `ObraNoMapa`); o D47 confere-a número a número.
    """
    linhas = ["const ARVORES: Array = ["]
    for v, _mx, _my, _h, x, y, _chao in plantas_do_mapa():
        linhas.append('\t["%s", %.1f, %.1f],' % (v, x, y))
    return "\n".join(linhas + ["]"])


def main() -> int:
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    if "--lista-da-mata" in sys.argv:
        print(lista_da_mata())
        return 0
    # `--espuma=N` escreve SÓ a camada de espuma de índice N, e é assim que o
    # CI a regenera ao lado dos dois mapas.
    for a in sys.argv[1:]:
        if a.startswith("--espuma="):
            i = int(a.split("=", 1)[1])
            destino_e = args[0] if args else "porto_mapa_espuma%d.svg" % i
            conteudo_e = gerar_espuma(SEMENTES_ESPUMA[i])
            with open(destino_e, "w", encoding="utf-8") as f:
                f.write(conteudo_e)
            print("%s — camada de espuma %d, %dx%d" % (destino_e, i, SAIDA, SAIDA))
            return 0
    com_pieres = "--sem-pieres" not in sys.argv
    com_coqueiros = "--sem-coqueiros" not in sys.argv
    com_predios = "--sem-predios" not in sys.argv
    com_pavimento = "--sem-pavimento" not in sys.argv
    destino = args[0] if args else "porto_mapa_iso.svg"
    nivel_vila = 1
    for a in sys.argv[1:]:
        if a.startswith("--nivel-vila="):
            nivel_vila = int(a.split("=", 1)[1])
    # ⚠️ A GUARDA CORRE ANTES DE ESCREVER, e reprova em vez de avisar. Um mapa
    # com a torre cortada sai bonito no nível 1 e decapitado no 3, e ninguém
    # gera o nível 3 para olhar — é a irmã da folha de contato que transborda.
    queixas = conferir_a_torre_cabe()
    if queixas:
        for q in queixas:
            print("FALHOU — %s" % q, file=sys.stderr)
        return 1

    conteudo = gerar(com_pieres, com_coqueiros, com_predios, com_pavimento,
                     nivel_vila)                  # gerar ANTES de abrir: open(...,"w")
    with open(destino, "w", encoding="utf-8") as f:   # trunca de imediato, e um
        f.write(conteudo)                             # erro deixaria o mapa vazio
    print("%s — %dx%d, chão transbordando de propósito (o ecrã é a janela)%s" % (
        destino, SAIDA, SAIDA, ("" if com_pieres else "  [SEM os píeres]")
        + ("" if com_coqueiros else "  [SEM os coqueiros]")
        + ("" if com_predios else "  [SEM os prédios]")
        + ("" if com_pavimento else "  [terra batida]")
        + ("  [vila nível %d]" % nivel_vila)))

    # O centro de cada píer no chão. É por aqui que o Main.tscn ancora o prop:
    # o render mira a origem do chão, então o canto do TextureRect é este ponto
    # menos meio quadro.
    print("\nCentro de cada píer, em pixels do PNG (h=0):")
    for i, (my0, my1, borda) in enumerate(PIERES):
        x, y = tela(borda + PIER_ALCANCE / 2, (my0 + my1) / 2, 0)
        print("  Vaga %d: (%.0f, %.0f)" % (i + 1, x, y))

    print("\nAncoras de barco (centro, encostado em cada píer):")
    for i, (my0, my1, borda) in enumerate(PIERES):
        x, y = tela(borda + PIER_ALCANCE / 2, my1 + 1.6, 0)
        print("  Doca %d: (%.0f, %.0f)" % (i + 1, x, y))

    # A tabela sai ao lado do mapa, sempre. É o contrato que o teste de design
    # confere contra o Main.tscn — gerar o mapa sem gerar a tabela deixaria o
    # teste a validar contra um mundo que já não existe.
    ancoras = destino.rsplit("/", 1)[0] + "/porto_mapa_ancoras.json" \
        if "/" in destino else "porto_mapa_ancoras.json"
    with open(ancoras, "w", encoding="utf-8") as f:
        json.dump(tabela_ancoras(), f, ensure_ascii=False, indent=1, sort_keys=True)
    print("\nÂncoras em %s — é contra elas que tests/teste_design.gd confere." % ancoras)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
