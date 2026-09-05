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

import json
import math
import random
import sys

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
RUA_LARG = 1.1
CALCADA = 0.22
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
    "agua": "#0d4d6b", "agua_funda": "#0f5a7d", "agua_media": "#1b7fa8",
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
    "tinta": "#e0a81f",
    # A via ficou MAIS ESCURA que o pátio em 31/08. Antes era #5f6a73 contra o
    # #6f7b85 do pátio — dois cinzas a um passo um do outro, que na tela viravam
    # uma chapa só de ponta a ponta. Sem borda, uma rua não lê como rua: lê como
    # o chão que sobrou. O meio-fio (`meiofio`) faz o resto do trabalho.
    "asfalto_via": "#49535b", "calcada": "#aeb8bf", "faixa_via": "#e6ebee",
    "meiofio": "#8d979e",
    # "cada casa de uma cor", diz a leitura da referência. A `casa_c` era
    # #cfd8de — o mesmo azul-acinzentado da parede antiga, de modo que um terço
    # da vila lia como concreto. Virou verde-água claro, que é cor de casa de
    # litoral e não repete nenhuma das outras duas.
    "casa_a": "#f0e7d3", "casa_b": "#e6d5b8", "casa_c": "#cfe0d2",
    "telha_a": "#b1512a", "telha_b": "#9d6a3c", "telha_c": "#7f8c98",
    "telha_d": "#a05a52",
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


def andar_costa(d: float, passo: tuple, r: random.Random):
    """Percorre a linha de água a `d` da terra, a passos irregulares.

    Devolve (mx, my, normal, tangente) — a normal aponta para o mar, e é ela
    que garante que nada do que se espalha por aqui caia do lado da terra.
    """
    v = costa_deslocada(d)
    for i in range(len(v) - 1):
        (x0, y0), (x1, y1) = v[i], v[i + 1]
        muro = abs(x1 - x0) < 1e-6
        normal = (1.0, 0.0) if muro else (0.0, -1.0)
        tangente = (0.0, 1.0) if muro else (1.0, 0.0)
        comprimento = abs(y1 - y0) if muro else abs(x1 - x0)
        andado = 0.0
        while andado < comprimento:
            f = andado / comprimento
            yield (x0 + (x1 - x0) * f, y0 + (y1 - y0) * f, normal, tangente)
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


def costa_entre(de: float, ate: float, mya: float, myb: float) -> list:
    """`costa(de, ate)`, mas só no trecho de `my` pedido."""
    perto = [p(mx, my) for mx, my in _corta_em_my(costa_deslocada(de), mya, myb)]
    longe = [p(mx, my) for mx, my in _corta_em_my(costa_deslocada(ate), mya, myb)]
    if len(perto) < 2 or len(longe) < 2:
        return []
    return perto + list(reversed(longe))


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
        for _ in range(5):
            mx, my = r.uniform(mx0, mx1), r.uniform(my0, my1)
            pts = [p(mx, my, ALT_CAIS)]
            for _ in range(3):
                mx += r.uniform(-1.1, 1.1)
                my += r.uniform(-1.1, 1.1)
                pts.append(p(mx, my, ALT_CAIS))
            out.append('    <polyline points="%s" fill="none" stroke="#4e5860" '
                       'stroke-width="1.6" opacity="0.5"/>\n'
                       % " ".join("%.1f,%.1f" % q for q in pts))
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
                  n: tuple = (4, 7), alt: tuple = (4.0, 7.0)) -> str:
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
              'opacity="0.7"/>\n'
              % (tx, ty, dx * 0.25, -a * 0.7, dx, -a, C["mato"]))
    return s


def vegetacao_do_solo(indice: int, mx0: float, my0: float, mx1: float,
                      my1: float) -> str:
    """Povoa o solo atrás da rua: mata fechada no fundo, moita e capim à frente.

    O guia de terrenos do pacote pede "solo tropical, mangue e restinga" e
    "vegetação: gramínea, moita". Aqui isso é DESENHO no mapa, e não tile: o
    chão deste jogo é um SVG gerado, e uma moita que muda de estado não existe.

    TRÊS COISAS QUE AS VERSÕES ANTERIORES ERRARAM, e ficam registadas:

    1. Manchas grandes e claras leem como FALHA de grama, não como relevo — o
       terreno parecia um campo de golfe malcuidado. Agora são poucas, escuras
       e a 0,22 de opacidade: servem para tirar a chapa, não para se ver.
    2. Havia uma faixa de mangue no fundo do mundo (`mx0`), que cai fora do
       enquadramento e ninguém vê. Além disso mangue é vegetação de BEIRA DE
       ÁGUA, e ali é o miolo da terra — atrás da vila o que existe é mata.
    3. ⚠️ **O VIÉS DA DENSIDADE APONTAVA PARA FORA DO ECRÃ** (04/09, e é o
       achado desta passagem). Ver `no_quadro`: 7 copas de 136 apareciam. A
       correção é dupla e nenhuma metade chega sozinha —
         · o viés passou a apontar para a FRENTE (`1 - random ** 2.0`), que é
           o lado da vila, onde a câmera olha; e
         · o que cai fora do quadro não se desenha, para o orçamento de
           polígono ir todo para o que se vê.
       A leitura de composição das referências pedia densidade ("em qualquer
       recorte de 200x200 há 6 a 12 objetos; no nosso mapa há 1 a 3") e a
       resposta não era gerar mais: era gerar no sítio certo.

    A mata continua a fechar-se para o fundo — só que "fundo" agora acaba
    onde o quadro acaba, e não onde o mundo acaba.
    """
    r = random.Random(SEMENTE_CHAO + 91 + indice)
    s = ""
    largura = mx1 - mx0

    # 1. Variação de tom. Discreta.
    for _ in range(5):
        cx = r.uniform(mx0 + 0.6, mx1 - 0.6)
        cy = r.uniform(my0, my1)
        rx, ry = r.uniform(1.4, 2.6), r.uniform(1.0, 2.0)
        pts = []
        for k in range(10):
            ang = math.radians(k * 36.0)
            pts.append(p(cx + rx * math.cos(ang) * r.uniform(0.85, 1.15),
                         cy + ry * math.sin(ang) * r.uniform(0.85, 1.15),
                         ALT_CAIS))
        s += poli(pts, C["solo_escuro"], 0.22)

    # 2. Orla de mata, do fundo para a frente. Cada árvore é sombra + tronco +
    # copa em lobos (`arvore`) — a receita das pedras do enrocamento.
    copas = []
    tentativas = 0
    # ⚠️ O ORÇAMENTO É DE ÁRVORES DESENHADAS, NÃO DE SORTEIOS. Um número fixo
    # de sorteios dá densidades diferentes por degrau, porque a fração da
    # faixa que cabe no quadro é 11%, 50%, 10% e 0% — o degrau 2 ficava com um
    # punhado de árvores ao lado de um degrau 1 fechado, sem que nada no
    # código dissesse porquê. Contar o que se desenha iguala-os.
    while len(copas) < 36 and tentativas < 900:
        tentativas += 1
        # ⚠️ O EXPOENTE MANDA NA COMPOSIÇÃO INTEIRA. `random ** 2.2` empilhava
        # tudo em `mx0`; `1 - random ** 2.0` empilha na frente, junto à vila,
        # e deixa as poucas do fundo a fechar a orla.
        vies = 1.0 - r.random() ** 2.0
        mx = mx0 + 0.2 + vies * (largura * 0.96)
        my = r.uniform(my0 - 0.4, my1 + 0.4)
        raio = r.uniform(0.34, 0.78)
        if not no_quadro(mx, my):
            continue
        copas.append((mx, my, raio, r.random()))
    # Desenhadas de trás para a frente: a saia de quem está à frente tem de
    # cair sobre quem está atrás, como no enrocamento e na vila.
    for mx, my, raio, luz in sorted(copas, key=lambda c: c[0] + c[1]):
        s += arvore(mx, my, raio, r, luz)

    # 3. Moitas e capim, do meio para a frente, onde a mata já rareou.
    for _ in range(30):
        vies = r.random() ** 0.7
        mx = mx0 + largura * 0.35 + vies * (largura * 0.62)
        my = r.uniform(my0, my1)
        if mx > mx1 - 0.25 or not no_quadro(mx, my):
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


def poli(pontos, cor: str, opacidade: float = 1.0) -> str:
    extra = "" if opacidade >= 1.0 else ' opacity="%.2f"' % opacidade
    return '  <polygon points="%s" fill="%s"%s/>\n' % (
        " ".join("%.1f,%.1f" % pt for pt in pontos), cor, extra)


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


def _faixa_mx(mx0, mx1, my0, my1, cor, opac=1.0) -> str:
    """Retângulo deitado no plano do chão, em coordenadas de mundo."""
    return poli([p(mx0, my0, ALT_CAIS), p(mx1, my0, ALT_CAIS),
                 p(mx1, my1, ALT_CAIS), p(mx0, my1, ALT_CAIS)], cor, opac)


def vias(pavimentado: bool) -> str:
    """A rua do porto, com calçada, e o acesso de cada berço.

    A rua acompanha a escada da costa. No degrau ela salta 4 unidades em `mx`,
    e o cotovelo que liga um trecho ao seguinte é desenhado com a MESMA
    largura da rua — desenhá-lo como um retângulo de canto a canto foi a
    primeira tentativa, e virava uma laje de asfalto do tamanho de um quarteirão.
    """
    s = ""
    dentro = lambda b: b - RUA_RECUO
    fora = lambda b: b - RUA_RECUO + RUA_LARG

    for i, (my0, my1, borda) in enumerate(DEGRAUS):
        fim = my1 + COSTURA
        s += _faixa_mx(dentro(borda) - CALCADA, fora(borda) + CALCADA,
                       my0, fim, C["calcada"])
        s += _faixa_mx(dentro(borda), fora(borda), my0, fim, C["asfalto_via"])
        # Meio-fio: 6cm de nada que fazem a rua ter margem em vez de acabar.
        for m in (dentro(borda), fora(borda)):
            s += _faixa_mx(m - 0.05, m + 0.05, my0, fim, C["meiofio"])

        if i + 1 < len(DEGRAUS):
            prox = DEGRAUS[i + 1][2]
            s += _faixa_mx(dentro(borda) - CALCADA, fora(prox) + CALCADA,
                           my1 - RUA_LARG - CALCADA, my1 + CALCADA, C["calcada"])
            s += _faixa_mx(dentro(borda), fora(prox),
                           my1 - RUA_LARG, my1, C["asfalto_via"])

        if pavimentado:
            meio = (dentro(borda) + fora(borda)) / 2.0
            my = my0 + 0.5
            while my < my1 - 1.4:
                s += _faixa_mx(meio - 0.05, meio + 0.05, my, my + 0.5,
                               C["faixa_via"], 0.7)
                my += 1.2

    # Acesso de cada berço: liga a rua ao avental, na altura do píer. É o que
    # explica para que serve a rua — sem ele ela passeia sem servir a nada.
    for my0, my1, borda in PIERES:
        meio = (my0 + my1) / 2.0
        s += _faixa_mx(fora(borda), borda - APRON,
                       meio - 0.6, meio + 0.6, C["asfalto_via"])
    return s


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
VILA_PAREDES = ["casa_a", "casa_b", "casa_c"]

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
PREDIOS_DO_PATIO = [
    ("Escritorio", 2.6, 6.7, 103.0),
    ("Armazem", 6.6, 14.5, 124.0),
]


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
        meia = 0.6 * (sprite / 2.0) / (MEIA_LARG * ZOOM)
        _, py = tela(pmx, pmy, ALT_CAIS)
        for my0, my1, borda in DEGRAUS:
            mx_vila = borda - recuo
            centro = mx_vila - (pmx - pmy)
            if not (my0 <= centro < my1):
                continue
            # O prédio tapa para CIMA, e só até à altura do sprite dele.
            _, hy = tela(mx_vila, centro, ALT_CAIS)
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
    "galpao": (3.76 * ESCALA_PREDIO, 2.76 * ESCALA_PREDIO),
    "galpao_velho": (3.76 * ESCALA_PREDIO, 2.76 * ESCALA_PREDIO),
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


def arvore(mx: float, my: float, raio: float, r: random.Random,
           luz: float = 0.5) -> str:
    """Uma árvore do chão: sombra projetada, tronco e copa em lobos.

    ⚠️ A COPA ERA DUAS ELIPSES CONCÊNTRICAS, e isso não lia como árvore.
    Medido na captura de 03/09, ampliada 3x: a elipse escura de baixo (a
    "sombra da própria copa") e a clara de cima estavam separadas por 8 a 14
    px numa copa de 40 px — 70% de sobreposição. O que saía era uma mancha
    escura com halo, que é exatamente o que o enrocamento fazia antes de
    ganhar arestas. A copa herdou a correção das pedras (`com_saia`).

    As três peças, e o que cada uma faz:

    1. **A sombra PROJETADA no chão**, deslocada para +mx/+my. Ela é o que
       tira a árvore do plano — sem sombra, o lobo mais escuro passa a ler-se
       como a sombra, e a copa volta a ser chapada.
    2. **O tronco**, que é o que levanta a copa. Sem ele os lobos flutuam.
    3. **A copa em LOBOS**, dois ou três, o mais alto com o realce amostrado
       da referência (`copa_luz`). Um lobo só, por mais bem desenhado que
       esteja, tem uma silhueta convexa — e copa de árvore não é convexa.

    `luz` de 0 a 1 escolhe o quanto o topo puxa para o realce: uma fileira de
    árvores todas do mesmo tom lê como carimbo repetido.
    """
    s = ""
    # 1. Sombra. O deslocamento é PROPORCIONAL ao raio: sombra que não anda
    # com o tamanho da árvore lê como mancha de tinta debaixo de todas elas.
    #
    # ⚠️ E ELA TEM DE SER MENOR QUE A COPA. A primeira versão desta função
    # deu-lhe 1,05 do raio e 0,34 de opacidade: na captura ampliada saía uma
    # elipse pálida do tamanho da árvore, mal deslocada — e o olho não a lia
    # como sombra, lia como falha de grama, que é exatamente a queixa que a
    # variação de tom desta mesma função já tinha registado ("manchas grandes
    # e claras leem como FALHA de grama"). Sombra pequena, escura e afastada
    # lê como sombra; grande e pálida lê como buraco no relvado.
    sx, sy = p(mx + raio * 0.72, my + raio * 0.52, ALT_CAIS)
    s += ('  <ellipse cx="%.0f" cy="%.0f" rx="%.1f" ry="%.1f" fill="%s" '
          'opacity="0.30"/>\n'
          % (sx, sy, raio * MEIA_LARG * 0.66, raio * MEIA_LARG * 0.33,
             C["mangue"]))

    # 2. Tronco — curto e fino, só o suficiente para a copa não pousar.
    tronco = raio * r.uniform(0.55, 0.85) * MEIA_LARG
    bx, by = p(mx, my, ALT_CAIS)
    largura = max(2.0, raio * MEIA_LARG * 0.16)
    s += poli([(bx - largura, by), (bx + largura, by),
               (bx + largura * 0.7, by - tronco), (bx - largura * 0.7, by - tronco)],
              C["tronco"])

    # 3. Copa. Os lobos sobem e vão para trás do anterior — desenhados do mais
    # baixo para o mais alto, para a saia de cada um cair sobre o de baixo.
    lobos = []
    n = r.choice((2, 3))
    for k in range(n):
        f = (k + 1.0) / n
        lx = bx + r.uniform(-0.30, 0.30) * raio * MEIA_LARG
        ly = by - tronco - (0.25 + 0.55 * f) * raio * MEIA_LARG
        rr = raio * MEIA_LARG * r.uniform(0.62, 0.92) * (1.0 - 0.16 * k)
        lobos.append((ly, _lobo(lx, ly, rr, rr * 0.72, r),
                      rr * r.uniform(0.34, 0.52)))
    topo_base = C["copa"]
    for i, (_ly, canto, h) in enumerate(sorted(lobos, key=lambda q: -q[0])):
        # O lobo mais alto puxa para o realce amostrado; os de baixo ficam no
        # tom do corpo. Copa toda de um tom é a mesma chapa de sempre.
        alto = i == len(lobos) - 1
        tom = C["copa_luz"] if (alto and r.random() < 0.10 + luz * 0.35) else topo_base
        s += com_saia(canto, h, tom)
    return s


# ── A AREIA DAS DUAS PONTAS ──────────────────────────────────────────────
#
# ⚠️ A PRIMEIRA IDEIA ERA PINTAR O AVENTAL DE AREIA, e ela não podia funcionar:
# o chão do cais é uma laje a `ALT_CAIS` do plano da água e o muro cai a pique
# dela. Areia por cima disso é um muro cor de areia, e o olho lê muro. O que faz
# praia é a terra DESCER até a água — então nos trechos de praia a laje acaba na
# crista e o que vai da crista à linha de água é uma RAMPA, desenhada aqui.
#
# A linha de água continua exatamente onde estava, de propósito: a camada de
# espuma, as faixas de profundidade e a tabela de âncoras todas a usam, e mover
# a costa por causa da areia seria pagar a etapa três vezes.
#
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

    O `amp` só sacode muro e espelho, nunca o chanfro da quina: torcer o
    chanfro desmancharia justamente a volta que a praia dá ao degrau.
    """
    recuo = PRAIA_PROF * (1.0 - t0)
    v = contorno_recuado(recuo)
    pontos = []
    for i in range(len(v) - 1):
        (x0, y0), (x1, y1) = v[i], v[i + 1]
        muro = abs(x1 - x0) < 1e-9
        espelho = abs(y1 - y0) < 1e-9
        n = max(1, int(max(abs(x1 - x0), abs(y1 - y0)) / passo))
        for k in range(n + 1):
            f = k / n
            mx, my = x0 + (x1 - x0) * f, y0 + (y1 - y0) * f
            desvio = PRAIA_PROF * amp * _meandro(my, fase) if amp else 0.0
            if muro:
                mx -= desvio
            elif espelho:
                my += desvio
            else:
                desvio = 0.0
            pontos.append((mx, my, (recuo + desvio) / PRAIA_PROF))
    return [p(mx, my, ALT_CAIS * q)
            for mx, my, q in _corta_em_my(pontos, my_a, my_b)]


def _faixa_da_rampa(a: tuple, b: tuple, my_a: float, my_b: float, cor: str,
                    opac: float = 1.0) -> str:
    """Uma faixa da rampa entre duas linhas, cada uma (t0, amplitude, fase)."""
    perto = linha_da_praia(*a, my_a, my_b)
    longe = linha_da_praia(*b, my_a, my_b)
    if len(perto) < 2 or len(longe) < 2:
        return ""
    return poli(perto + list(reversed(longe)), cor, opac)


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
    crista = linha_da_praia(*CRISTA[indice], my_a, my_b)
    if len(crista) < 2:
        return ""
    s = poli([p(FUNDO_TERRA, my_a, ALT_CAIS)] + crista
             + [p(FUNDO_TERRA, my_b, ALT_CAIS)], C["solo"])

    # ⚠️ E O CAPIM VEM AQUI, E NÃO COM A AREIA. Ele nasceu em `praia_areia`,
    # que é desenhada lá no fim junto com o enrocamento — depois da rua e
    # DEPOIS DA VILA. Na captura viam-se tufos por cima do telhado das casas e
    # do passeio: o mundo estava certo (o capim para 0,15 antes da calçada),
    # a ORDEM é que não, porque uma casa levanta-se 20 px e o que se desenha
    # depois dela cai-lhe em cima. O chão da praia corre antes de tudo o que
    # se constrói em terra, e é o lugar do que cresce nele.
    r = random.Random(SEMENTE_CHAO + 210 + indice)
    # Capim de restinga na terra atrás da crista. Sem ele o trecho fica verde
    # chapado entre a rua e a areia. E quem decide o orçamento é o
    # `no_quadro`: o que cai fora do PNG não se desenha, que é a lição da mata
    # de 04/09 — 136 copas sorteadas, 7 dentro do ecrã.
    fundo = RUA_RECUO - RUA_LARG - CALCADA - PRAIA_PROF - 0.15
    for mx, my, (nmx, nmy), _t in andar_costa(-PRAIA_PROF, (0.16, 0.34), r):
        if not (my_a <= my <= my_b):
            continue
        dentro = r.uniform(0.10, max(0.3, fundo))
        gx, gy = mx - nmx * dentro, my - nmy * dentro
        if not no_quadro(gx, gy):
            continue
        if r.random() < 0.20:
            rr = r.uniform(0.16, 0.34)
            pts = []
            for k in range(8):
                ang = math.radians(k * 45.0)
                pts.append(p(gx + rr * math.cos(ang) * r.uniform(0.8, 1.2),
                             gy + rr * 0.8 * math.sin(ang) * r.uniform(0.8, 1.2),
                             ALT_CAIS))
            s += poli(pts, C["mato"], 0.9)
        else:
            ex, ey = p(gx, gy, ALT_CAIS)
            s += tufo_de_capim(ex, ey, r)

    # E umas árvores baixas, que é o que a referência pede a seguir às pedras.
    # ⚠️ COQUEIRO AQUI NÃO CABE, e isso foi medido: o coqueiro é PROP, tem a
    # copa 110 px acima da âncora, e a restinga norte inteira cai a menos de
    # 92 px do topo do quadro — um coqueiro ali sairia decapitado pela barra
    # do HUD. A árvore da mata é baixa e serve, e a `no_quadro` da COPA (e não
    # do pé) é que decide se ela entra.
    arvores = []
    for mx, my, (nmx, nmy), _t in andar_costa(-PRAIA_PROF, (1.5, 3.4), r):
        if not (my_a <= my <= my_b) or r.random() < 0.45:
            continue
        dentro = r.uniform(0.5, max(0.6, fundo - 0.3))
        ax, ay = mx - nmx * dentro, my - nmy * dentro
        if not no_quadro(ax, ay) or not no_quadro(ax, ay, ALT_CAIS + 70.0, 0.0):
            continue
        arvores.append((ax, ay, r.uniform(0.30, 0.52), r.random()))
    for ax, ay, raio, luz in sorted(arvores, key=lambda c: c[0] + c[1]):
        s += arvore(ax, ay, raio, r, luz)
    return s


def praia_areia(indice: int, my_a: float, my_b: float) -> str:
    """A rampa de areia, o pé molhado, o fundo submerso, as pedras e o capim.

    ⚠️ A RAMPA SAIU EM TRÊS TONS NA PRIMEIRA VERSÃO, e três era um a mais.
    Uma chapa de 58 px na tela não tem lado nenhum, isso é verdade — mas duas
    fronteiras internas a 0,27 e 0,13 da largura da rampa dão duas fitas de 16
    e 8 px de largura CONSTANTE, e na captura elas leram-se como as listras de
    uma bandeira. Ficaram duas: areia clara (que é o que a referência pede,
    "uma faixa clara") e o pé molhado, com a fronteira a serpentear largo.
    """
    r = random.Random(SEMENTE_CHAO + 170 + indice)
    s = _faixa_da_rampa(CRISTA[indice], LAVADO[indice], my_a, my_b, C["areia"])
    s += _faixa_da_rampa(LAVADO[indice], LINHA_DE_AGUA, my_a, my_b, C["areia_face"])

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

    # O baixio de areia, já do lado da água: duas faixas, a larga quase
    # transparente só para a de dentro não acabar numa aresta. Elas não são
    # opacas de todo porque a renda de espuma já está desenhada ali por baixo.
    for ate, opac in ((PRAIA_SUBMERSA * 1.9, 0.30), (PRAIA_SUBMERSA, 0.90)):
        faixa = costa_entre(0.0, ate, my_a, my_b)
        if faixa:
            s += poli(faixa, C["areia_funda"], opac)

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


def _sombrear(hexa: str, fator: float) -> str:
    n = int(hexa[1:], 16)
    r, g, b = (n >> 16) & 255, (n >> 8) & 255, n & 255
    return "#%02x%02x%02x" % tuple(min(255, int(c * fator)) for c in (r, g, b))


def casa(mx0, my0, mx1, my1, altura, parede, telha, janelas) -> str:
    """Uma casa da vila: parede, porta, janela e telhado com beiral curto.

    O beiral é 0,12 e o telhado tem 5px — proporção de casa, não de galpão.
    A porta fica na face +my (virada para a rua) e ocupa pouco mais de um
    terço do vão, que é o que dá escala humana à construção.
    """
    p_dir, p_esq = _sombrear(parede, 0.80), _sombrear(parede, 0.91)
    s = caixa(mx0, my0, mx1, my1, ALT_CAIS, altura, parede, p_dir, p_esq)

    meio = (mx0 + mx1) / 2.0
    vao = (mx1 - mx0)
    s += face_my(my1, meio - vao * 0.17, meio + vao * 0.17,
                 ALT_CAIS, ALT_CAIS + altura * 0.55, C["porta"])
    for linha in range(janelas):
        j0 = ALT_CAIS + altura * (0.30 + 0.62 * linha / max(janelas, 1))
        j1 = j0 + altura * 0.24
        s += face_mx(mx1, my0 + (my1 - my0) * 0.34, my0 + (my1 - my0) * 0.66,
                     j0, j1, C["vidro"])
        if linha > 0 or janelas == 1:
            s += face_my(my1, mx0 + vao * 0.66, mx0 + vao * 0.88, j0, j1, C["vidro"])

    t = ALT_CAIS + altura
    s += caixa(mx0 - 0.12, my0 - 0.12, mx1 + 0.12, my1 + 0.12, t, 5,
               C[telha], _sombrear(C[telha], 0.72), _sombrear(C[telha], 0.86))
    return s


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
VILA_VAO = (0.10, 0.38)         # entre vizinhos do mesmo quarteirão
VILA_GEMINADA = 0.34            # com que frequência dois vizinhos encostam


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
    for my0, my1, borda in DEGRAUS:
        my = my0 + 0.35
        # A linha de frente do quarteirão. `frente` é o recuo partilhado.
        frente = r.uniform(0.0, 0.20)
        restam = r.randint(*quarteirao)
        par = None            # a variante a herdar, quando a casa é geminada
        while my < my1 - 0.5:
            dmy = r.uniform(0.72, 1.28)
            if my + dmy > my1 - 0.15:
                break
            dmx = VILA_PROF - r.uniform(0.0, 0.26)
            mx = borda - recuo + frente + r.uniform(0.0, 0.05)
            # ⚠️ E O QUE CAI FORA DO QUADRO NÃO ENTRA, pelo mesmo motivo que a
            # mata: medido em 04/09, só **17,3 das 40 unidades** da fileira da
            # frente estão dentro do PNG — 43%. O degrau 3 inteiro está fora, à
            # esquerda, e gerava cinco casas que ninguém nunca viu. A folga é
            # larga porque um telhado assoma no quadro muito antes do canto do
            # lote lá chegar.
            if not no_quadro(mx, my, folga=110.0):
                pass
            # O vão só vale se a casa INTEIRA couber fora dele: testar o
            # canto, como se fazia, deixava passar a casa que entra no vão
            # pela outra ponta.
            elif not any(a < my + dmy and my < b for a, b in vaos):
                saida.append((mx, my, dmx, dmy,
                              r.randrange(3) if par is None else par, fundo))
            restam -= 1
            if restam <= 0:
                my += dmy + r.uniform(*travessa)
                frente = r.uniform(0.0, 0.20)
                restam = r.randint(*quarteirao)
                par = None
            elif r.random() < VILA_GEMINADA:
                # ⚠️ GEMINADA HERDA A VARIANTE DA VIZINHA, e sem isso ela sai
                # pior do que não existir. Duas casas encostadas com telhados
                # de ALTURAS e cores diferentes não leem como par geminado:
                # leem como um telhado fatiado pelo outro, porque o beiral de
                # 0,12 de cada lado faz os dois sobreporem-se 0,24 e o mais
                # alto corta o mais baixo ao meio. Com a mesma variante os
                # dois telhados encaixam e o que se vê é UM prédio comprido,
                # que é o que uma casa geminada é.
                par = saida[-1][4] if saida else None
                my += dmy                      # parede partilhada
            else:
                par = None
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
    """(mx0, my0, dmx, dmy, variante, fundo) de cada casa, medido do cais.

    Duas fileiras, e o que decide quais casas existem é o quadro: ver
    `_fileira` e `VILA_RECUO_2`.
    """
    return _fileira(VILA_RECUO, SEMENTE_CHAO + 210) \
        + _fileira(VILA_RECUO_2, SEMENTE_CHAO + 211, fundo=True)


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
    s = ""
    for mx0, my0, dmx, dmy, variante, fundo in sorted(lotes_da_vila(),
                                                      key=lambda l: l[0] + l[1]):
        altura, telha, janelas = perfis[variante]
        # Na fileira de trás planta-se mais: é ela que desfia a vila contra a
        # mata, e é a árvore — não o vão vazio — que faz a orla parecer orla.
        pomar = 0.85 if fundo else 0.55
        # Quintal: a casa não ocupa o lote todo, e o que sobra é chão batido
        # mesmo no mapa pavimentado — quintal não é asfalto.
        s += _faixa_mx(mx0 - 0.28, mx0 + dmx + 0.5, my0 - 0.3, my0 + dmy + 0.3,
                       C["terra_clara"] if pavimentado else C["terra_escura"], 0.5)
        # Árvore do QUINTAL DE TRÁS, desenhada antes da casa para a casa a
        # tapar em parte — é o que a põe atrás em vez de colada por cima.
        if r.random() < pomar:
            s += arvore(mx0 - r.uniform(0.10, 0.26),
                        my0 + r.uniform(-0.1, dmy + 0.1),
                        r.uniform(0.30, 0.52), r, r.random())
        s += casa(mx0, my0, mx0 + dmx, my0 + dmy, altura,
                  C[VILA_PAREDES[variante]], telha, janelas)
        # Árvore do quintal da FRENTE, entre a casa e o passeio.
        if r.random() < pomar - 0.05:
            s += arvore(mx0 + dmx + r.uniform(0.10, 0.34),
                        my0 + r.uniform(0.0, dmy),
                        r.uniform(0.26, 0.44), r, r.random())
        elif r.random() < 0.7:
            gx, gy = p(mx0 + dmx + r.uniform(0.12, 0.4),
                       my0 + r.uniform(0.1, dmy), ALT_CAIS)
            s += tufo_de_capim(gx, gy, r, n=(3, 5), alt=(3.0, 5.5))
    return s


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


def gerar_espuma(semente: int) -> str:
    return ('<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d" '
            'viewBox="0 0 %d %d">\n%s</svg>\n'
            % (SAIDA, SAIDA, LARG, ALT, espuma(semente)))


def gerar(com_pieres: bool = True, com_coqueiros: bool = True,
          com_predios: bool = True, com_pavimento: bool = True,
          nivel_vila: int = 1) -> str:
    s = '<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d" viewBox="0 0 %d %d">\n' % (
        SAIDA, SAIDA, LARG, ALT)

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
          '<radialGradient id="mfunda" gradientUnits="objectBoundingBox" '
          'cx="0.5" cy="0.5" r="0.5">'
          '<stop offset="0" stop-color="%s" stop-opacity="0.30"/>'
          '<stop offset="0.55" stop-color="%s" stop-opacity="0.16"/>'
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
             C["agua_funda"], C["agua_funda"], C["agua_funda"],
             C["agua_baixio"], C["agua_baixio"], C["agua_baixio"]))
    s += '  <rect width="%d" height="%d" fill="url(#fundo)"/>\n' % (LARG, ALT)
    for de, ate, cor in [(0.0, 6.0, C["agua_media"]),
                         (0.0, 2.6, C["agua_rasa"]),
                         (0.0, 1.0, C["agua_baixio"])]:
        s += poli(costa(de, ate), cor)

    # ESPUMA na linha de costa. O guia de terrenos do pacote é explícito:
    # "espuma somente nas bordas de praia, rochas, docas e colisões de barcos".
    # É a peça que faltava — a água encostava no cais com uma aresta dura, como
    # dois papéis colados, e é isso que fazia o mar parecer um preenchimento.
    s += poli(costa(0.0, 0.42), C["espuma"], 0.34)
    s += poli(costa(0.0, 0.16), C["espuma"], 0.55)

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
    rv = random.Random(SEMENTE_CHAO + 47)
    for _ in range(18):
        my0, my1, borda = DEGRAUS[rv.randrange(len(DEGRAUS))]
        cx, cy = p(borda + rv.uniform(2.0, 26.0), rv.uniform(my0 - 3.0, my1 + 5.0))
        rx = rv.uniform(70.0, 190.0)
        s += ('  <ellipse cx="%.0f" cy="%.0f" rx="%.0f" ry="%.0f" fill="url(#%s)" '
              'transform="rotate(%.0f %.0f %.0f)"/>\n'
              % (cx, cy, rx, rx * rv.uniform(0.34, 0.58),
                 "mfunda" if rv.random() < 0.62 else "mrasa",
                 rv.uniform(-40, 40), cx, cy))

    # ONDAS. A primeira versão usava OITO deslocamentos fixos, repetidos igual
    # em todos os degraus, e sempre o mesmo desenho `q8-5 16 0 q8 5 16 0`. Na
    # tela isso vira papel de parede: o olho encontra o padrão em dois segundos
    # e o mar deixa de ser mar. Agora comprimento, curvatura, opacidade e
    # posição variam, com semente fixa para o mapa continuar reproduzível.
    #
    # A densidade cai com a distância da costa — é assim que a água mostra de
    # que lado fica a terra.
    ro = random.Random(SEMENTE_CHAO + 7)
    s += ('  <g fill="none" stroke="%s" stroke-linecap="round">\n' % C["espuma"])
    for my0, my1, borda in DEGRAUS:
        for _ in range(26):
            vies = ro.random() ** 1.9          # esmagado contra a costa
            dmx = 1.2 + vies * 27.0
            wx, wy = p(borda + dmx, ro.uniform(my0 - 2.0, my1 + 4.0))
            comp = ro.uniform(9.0, 19.0)
            curva = ro.uniform(3.0, 6.5)
            op = max(0.10, 0.62 - vies * 0.5)
            s += ('    <path d="M%.0f %.0f q%.0f-%.0f %.0f 0 q%.0f %.0f %.0f 0" '
                  'stroke-width="%.1f" opacity="%.2f"/>\n'
                  % (wx - comp, wy, comp / 2, curva, comp,
                     comp / 2, curva, comp, ro.uniform(2.0, 3.4), op))
    s += '  </g>\n'

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
    for j, a, b in praias():
        s += praia_chao(j, a, b)

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
        s += vegetacao_do_solo(i, FUNDO_TERRA, my0, borda - VILA_RECUO_2, my1)

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
                s += ('  <path d="M%.1f,%.1f L%.1f,%.1f" stroke="#e0a81f" '
                      'stroke-width="2.5" fill="none"/>\n' % (
                          *p(borda - APRON + 0.05, a + 0.3, ALT_CAIS),
                          *p(borda - APRON + 0.05, b - 0.3, ALT_CAIS)))

    s += vias(com_pavimento)
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
    # sujeira na água.
    s += poli(costa_entre(0.0, 1.15, PONTA_NORTE, PONTA_SUL),
              C["sombra_agua"], 0.30)

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

    # ---- as duas pontas de areia ----
    # Vêm aqui, e não no laço dos degraus, pela mesma razão que o enrocamento:
    # é a última camada da margem, e tudo o que o cais desenha na beira já
    # passou. O chão delas foi desenhado lá atrás (`praia_chao`); o que falta
    # é a rampa que desce até a água.
    for j, a, b in praias():
        s += praia_areia(j, a, b)

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
        cores = [("#c23030", "#7a1a1a", "#8f2020"), ("#2f74b0", "#1d4a75", "#245a8c"),
                 ("#e0a81f", "#9c7a15", "#b8901a"), ("#2d7a3a", "#19512d", "#1f6236")]
        # Recuo do CAIS, como tudo o mais que vive em terra. Em `mx` absoluto
        # dois destes caíam na rua e outros dois no meio da vila, porque o
        # cais avança 4 unidades por degrau e eles não avançavam com ele.
        k = 0
        # Recuo entre 1,3 (avental) e 2,98 (meio-fio da rua). O teste de design
        # pegou os antigos 2,8–3,1 em cima do asfalto da via.
        # ⚠️ ERAM SETE, e a sétima ficava em my=26,4 — dentro da ponta sul de
        # areia desde 04/09. Contêiner pousado na restinga, atrás de uma
        # praia. Não se mudou de sítio porque o pátio entre my=16 e 22,5 já
        # tem o coqueiro, a pilha e o palete a menos de 20 px uns dos outros:
        # empurrá-la para lá trocava um defeito visível por outro.
        for recuo, my in [(2.05, 1.4), (2.6, 3.2), (2.05, 9.9), (2.6, 11.7),
                          (2.05, 18.2), (2.6, 20.0)]:
            borda = _borda_em(my)
            mx = borda - recuo
            c = cores[k % len(cores)]
            s += caixa(mx, my, mx + 1.15, my + 1.5, B, 13, c[0], c[1], c[2])
            k += 1

    if not com_predios:
        s += "</svg>\n"
        return s

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
    return s


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
        cotovelos.append({
            "mx": [borda - RUA_RECUO - CALCADA, prox - RUA_RECUO + RUA_LARG + CALCADA],
            "my": [my1 - RUA_LARG - CALCADA, my1 + CALCADA],
        })

    # ⚠️ E AS DUAS PONTAS DE AREIA, publicadas pela mesma razão que os
    # cotovelos: elas são chão em que NÃO se pousa equipamento de porto, e
    # nada no `Main.tscn` sabia disso. A empilhadeira ficou na restinga da
    # ponta sul assim que ela existiu, e nenhuma asserção reprovou.
    #
    # O `recuo` é o MAIOR que a crista alcança (a ondulação incluída), de modo
    # que a faixa de areia publicada seja sempre um pouco mais larga do que a
    # desenhada: um cerco que erra tem de errar para o lado seguro.
    areia = []
    for _j, my_a, my_b in praias():
        areia.append({"my": [round(my_a, 2), round(my_b, 2)],
                      "recuo": round(PRAIA_PROF * (1.0 + CRISTA[_j][1]), 3)})

    return {
        # O `fundo_terra` é UNIDADE DE MUNDO e por isso não leva `ZOOM`. Ele
        # entra aqui para o bloco D16 do teste de design poder conferir que o
        # mundo transborda o quadro pelos quatro lados — que é o contrato
        # escrito no cabeçalho deste arquivo e que, até 05/09, nada verificava.
        "projecao": {"cx": round(CX * ZOOM, 4), "cy": round(CY * ZOOM, 4),
                     "meia_larg": MEIA_LARG * ZOOM, "meia_alt": MEIA_ALT * ZOOM,
                     "alt_cais": ALT_CAIS * ZOOM, "fundo_terra": FUNDO_TERRA},
        "praias": areia,
        "pegadas": {k: list(v) for k, v in sorted(PEGADAS.items())},
        "mapa": {"largura": SAIDA, "altura": SAIDA},
        "pieres": pieres,
        "faixas": faixas,
        "cotovelos": cotovelos,
        "lotes": [{"mx": round(l[0], 2), "my": round(l[1], 2),
                   "dmx": round(l[2], 2), "dmy": round(l[3], 2),
                   "fundo": bool(l[5]),
                   "canto": px(l[0], l[1], ALT_CAIS)} for l in lotes_da_vila()],
    }


# As duas sementes da espuma. A primeira é a que o mapa usava quando ela era
# assada — assim a camada 0 sai com as MESMAS manchas de sempre e a mudança
# não é uma costa nova, é a mesma costa que agora respira.
SEMENTES_ESPUMA = (SEMENTE_CHAO + 55, SEMENTE_CHAO + 56)


def main() -> int:
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
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
