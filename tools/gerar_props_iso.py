#!/usr/bin/env python3
"""
BR Port — gerador dos props isométricos do porto.

POR QUE BLENDER POR SCRIPT E NÃO UM GERADOR DE IMAGEM
-----------------------------------------------------
Duas levas de sprite já foram perdidas pelo mesmo motivo: o gerador não erra o
desenho, erra o ÂNGULO. Num plano isométrico nenhum eixo é horizontal (ambos
saem a 26,57°), e sprite gerado deitado fica atravessado em cima do píer.
Rotacionar no Godot não conserta, porque a perspectiva e a luz estão assadas
dentro da imagem.

Aqui a projeção é conta, não desenho: a câmera ortográfica a (60°, 0, 45°)
produz exatamente o 2:1 que `gerar_mapa_iso.py` usa. O ângulo não pode sair
errado.

O QUE ISTO RESOLVE QUE NADA MAIS RESOLVIA
-----------------------------------------
1. **O píer não pula ao ampliar.** `pier_construido` e `pier_ampliado` são a
   MESMA geometria com peças a mais ligadas. Não é um cuidado que alguém tomou,
   é uma coisa que não tem como dar errado.
2. **Peças separadas registram.** Copa e tronco do coqueiro, e as três partes
   do guindaste, saem de renders diferentes da MESMA câmera. O Tween pode mexer
   numa sem a outra sair do lugar.
3. **Escala 1:1 com o mapa.** Ver ESCALA_ORTO abaixo: o PNG cai no mapa sem
   redimensionar.
4. **Alpha de verdade** (`film_transparent`). O truque do fundo magenta e o
   `preparar_sprites.py` só existem por causa de gerador de imagem; aqui não
   fazem falta.

O QUE ISTO **NÃO** FAZ
----------------------
Retrato de personagem. Arlindo e o Sr. Ribeiro não se escrevem em coordenadas —
esses continuam sendo trabalho de gerador de imagem, e lá a perspectiva não
importa porque eles vivem em painel.

INSTALAÇÃO
----------
O Blender entra como biblioteca Python, sem interface:

    python3 -m venv ~/bpy-venv
    ~/bpy-venv/bin/pip install "bpy==4.5.13"     # ~950 MB, precisa de Python 3.11

USO
---
    ~/bpy-venv/bin/python tools/gerar_props_iso.py <pasta_de_saida> [prop ...]
    ~/bpy-venv/bin/python tools/gerar_props_iso.py /tmp/props pier_construido
    ~/bpy-venv/bin/python tools/gerar_props_iso.py --despejar=/tmp/cena.txt

`--despejar=<arquivo>` monta a cena, escreve-a em texto e sai SEM render: é a
prova de que o arnês da montagem não muda nada (ver `primitiva`).

Sem nomes, gera tudo. Ao fim confere a largura do tabuado contra a conta do
mapa — se divergir, a projeção saiu errada e o resto não presta.
"""

import hashlib
import math
import os
import sys
import time

import bpy
import numpy as np
from mathutils import Matrix, Vector

# ---------------------------------------------------------------- projeção
# Os mesmos valores de tools/gerar_mapa_iso.py. Mudar aqui sem mudar lá
# desalinha os props do chão.
MEIA_LARG, MEIA_ALT = 30.0, 15.0

# ── E O ZOOM, que é o terceiro membro do contrato desde 05/09 ────────────
#
# O mapa deixou de ser desenhado na escala em que é entregue: ele desenha a
# `MEIA_LARG = 30` num quadro maior e o `viewBox` do SVG encolhe o quadro
# inteiro (ver o bloco do enquadramento em `gerar_mapa_iso.py`). O prop não
# tem `viewBox`: ele é PNG, e cai no `Main.tscn` a 1:1. Então quem encolhe o
# prop é a CÂMERA — o `ESCALA_ORTO` abaixo, e mais nada.
#
# ⚠️ E É SÓ O `ESCALA_ORTO`. O `z()` continua a converter altura pela escala
# de DESENHO, e por isso a geometria construída neste arquivo não muda um
# milímetro: o `ALTURA_PX` de tela encolheria na mesma proporção do
# `ESCALA_ORTO`, os dois cancelam-se, e mexer nele levantaria cada prop 1,5x
# — o mesmo defeito que o mapa evita não reescrevendo os literais dele.
# Afastar uma câmera não estica o que ela filma.
ZOOM = 2.0 / 3.0
MEIA_LARG_TELA = MEIA_LARG * ZOOM

# Câmera ortográfica: a razão vertical/horizontal de um passo no chão é
# sen(elevação). Com 15/30 = 0,5 -> elevação 30° -> rotação X = 60°.
# (O 54,736° dos tutoriais é isométrico VERDADEIRO, 1,732:1. Aqui daria errado.)
ROT_X, ROT_Z = 60.0, 45.0

# ── E A RESOLUÇÃO É O QUARTO MEMBRO DO CONTRATO desde 16/09 ─────────────
#
# Alavanca B do item da resolução (`docs/decisoes/029`). A A fez o mesmo ao
# mapa e não tocou num traço: ali o desenho já existia a 1080 e o importador
# deitava-o fora, então bastou parar de o reduzir (`025`). Aqui NÃO há nada
# guardado — o prop é renderizado, e a única forma de ele ter mais pixels é
# renderizá-lo com mais.
#
# SÃO DOIS NÚMEROS, E CONFUNDI-LOS É NÃO MUDAR NADA. O `RESOLUCAO_TELA` é o
# quadro em COORDENADAS: 512 de lado, com a origem do mundo no centro, e é o
# que `Main.tscn`, `Dock.tscn`, o teste de design e a tabela de âncoras leem.
# Ele NÃO se mexe. O `RESOLUCAO` é o quadro em PIXELS, e é só ele que sobe.
#
# ⚠️ E O `ESCALA_ORTO` TEM DE SAIR DO PRIMEIRO. Ele estava escrito a partir do
# `RESOLUCAO`, e assim os dois sobem juntos: a câmera afasta-se na mesma
# proporção em que o quadro cresce, o prop sai do mesmo TAMANHO em pixels com
# 256 px de moldura vazia a mais, e a alavanca não entrega um pixel. Com o
# `ortho_scale` preso à escala de TELA a câmera continua a enquadrar o mesmo
# volume de mundo e os 768 px caem todos dentro do desenho.
#
# Quem mostra o PNG desfaz a diferença com `expand_mode = 1`: o rect continua
# com 512 de coordenadas e a textura carrega 768 pixels, exactamente como os
# três nós de mapa fazem desde a `025`.
RESOLUCAO_TELA = 512
RESOLUCAO = 768

# O que converte um do outro. Todo número medido em pixel do PNG passa por
# aqui — é ele que separa "medi no desenho" de "medi na tela", e as duas
# respostas deixaram de ser o mesmo número.
FATOR_RES = float(RESOLUCAO) / float(RESOLUCAO_TELA)

# Uma unidade de mundo na horizontal tem de valer MEIA_LARG_TELA pixels de
# TELA. Numa câmera ortográfica a 45° de azimute isso é (RESOLUCAO_TELA /
# ortho_scale) * cos(45°), então ortho_scale = RESOLUCAO_TELA /
# (MEIA_LARG_TELA / cos(45°)) — e no PNG a mesma unidade vale FATOR_RES vezes
# mais, que é o ponto inteiro da alavanca.
ESCALA_ORTO = RESOLUCAO_TELA / (MEIA_LARG_TELA / math.cos(math.radians(45.0)))

# ALTURA: o ponto onde os dois mundos quase não se falam.
#
# `gerar_mapa_iso.py` trata altura como PIXELS livres — ALT_PIER=15, ALT_CAIS=26,
# um armazém com 44. É uma convenção de desenho, não uma projeção.
# O Blender faz projeção DE VERDADE: uma unidade de altura projeta
# (RESOLUCAO/ortho_scale) * cos(elevação) = 24,49 px de TELA — 36,74 no PNG,
# que é o mesmo desenho com FATOR_RES vezes mais pixels.
#
# ⚠️ ESTE COMENTÁRIO DIZIA 36,74 DESDE ANTES DO ZOOM DE 05/09, e a conta ao
# lado dele dava 24,49 havia onze dias: é o "número em pixel escrito à mão"
# que este projeto já registou cinco vezes, desta vez num comentário em vez de
# numa constante. Ninguém o lê, então ninguém o desmente.
#
# Ignorar isso põe um píer renderizado 2,4x mais alto que o cais desenhado ao
# lado dele. Por isso os props falam a mesma língua do mapa: altura em PIXELS
# DO MAPA, convertida aqui num lugar só.
# ⚠️ E ESTE FATOR SAI DA ESCALA DE DESENHO, não da de tela — ver o bloco do
# ZOOM acima. É `MEIA_LARG / cos(45°) * cos(30°)`, escrito assim para se ler
# que é a mesma conta do `ESCALA_ORTO` com o outro `MEIA_LARG`.
ALTURA_PX = (MEIA_LARG / math.cos(math.radians(45.0))) \
    * math.cos(math.radians(90.0 - ROT_X))


def z(altura_px: float) -> float:
    """Altura em pixels do mapa -> unidades de mundo do Blender."""
    return altura_px / ALTURA_PX


PIER_ALCANCE = 4.5
PIER_LARG = 2.4
ALT_PIER = z(15.0)          # ALT_PIER do mapa, em pixels

# A RÉGUA DO MUNDO, e a da pessoa dentro dela (27/09, `docs/decisoes/069`).
#
# Medida no que o kit já desenha com tamanho real conhecido: o contêiner do
# pátio (2,44 x 2,59 m) e a cabine do camião (2,5 m de largura, ~3,2 m de
# altura). As duas peças concordam entre si e discordam de um EIXO para o
# outro — o kit desenha as alturas mais achatadas do que o chão:
#
#   chão    contêiner 0,50 u -> 4,9 m/u · camião 0,45 u -> 5,6 m/u
#   altura  contêiner 15 px  -> 5,8 px/m · cabine 17,3 px -> 5,4 px/m
#
# Pessoas e carros comparam-se pela ALTURA — é o que o olho alinha e o que a
# página de escala põe lado a lado —, logo a régua deles é a de altura. O
# trabalhador de 13/09 media 30,4 px: **5,4 m**, mais alto do que a cabine do
# camião a que ia encostar. A escolha do Bruno é **1,5x o real**, porque no
# real (9,8 px) o capacete e o colete perdem-se: 1,75 m x 1,5 x 5,6 = 14,7 px,
# e 14,7 / 30,4 = 0,48.
#
# ⚠️ A PRIMEIRA CONTA DESTE BLOCO DEU 0,65, e o Bruno chegou a aprová-la. Ela
# lia a cabine do camião ANTES do `ESCALA_CAMINHAO` (0,72) que o `brp_porto`
# aplica no fim, e por isso as duas réguas pareciam concordar em 4,9 m/u. A
# 0,65 a pessoa media 19,8 px — 2x o real, e ainda mais alta do que a cabine.
# Medida de prop lê-se no PNG, ou depois de TODA escala que o gerador aplica.
#
# ⚠️ E A FAUNA NÃO ANDA COM ELA — escolha do Bruno, com as duas na prancha.
# Encolhida pelo mesmo número, a fauna ficava com 6 a 8 px: o cachorro com 9
# pixels opacos, e a gaivota, a tartaruga e o cachorro do mesmo tamanho. Ela
# ficou como estava (10 a 11 px), e isso é o real que a regra antiga não era:
# a envergadura de uma gaivota é ~3x os ombros de uma pessoa. O D25 passou de
# «nenhum bicho passa da pessoa» a «nenhum fica abaixo dela».
PX_POR_METRO = 5.6          # altura: pixels do mapa por metro
METROS_POR_U = 5.2          # chão: metros por unidade de mundo
REGUA_DA_PESSOA = 0.48

# O CAMINHO DO TRABALHADOR NO TABUADO (`075`) saiu com o degrau 2 (`077`):
# as pilhas do papelão e do saco, que pousavam no fim dele, vivem agora
# onde o guindaste do n2 as larga — o mesmo ponto da pilha do peixe do n1.

# Os props que só servem de RÉGUA na página de escala, e nunca vão ao mapa.
# Regeram-se pelo nome, para a pasta deles:
#   python3 tools/gerar_props_iso.py brport_vs/tools/referencia carro pedestre
REFERENCIAS = ("carro", "pedestre")

# O QUE O GERADOR DESENHA E O JOGO AINDA NÃO MOSTRA, que sai só pelo nome,
# para uma pasta de rascunho: em `art/props` seria arte órfã. Esteve aqui a
# carga ao ombro, aprovada na prancha da `075` e sem quem a levasse desde a
# `076`; voltou ao jogo com a ida ao camião do degrau 2 (`077`). Vazia hoje,
# e fica: é o sítio onde mora a peça do degrau 3 enquanto não tiver cena.
PROXIMO_NIVEL = ()

# A CAIXA DE PAPELÃO E O SACO DE RÁFIA, nas unidades do boneco — o lado e a
# frente em unidades de mundo antes da régua da pessoa, a altura em pixels do
# mapa antes dela (`_bloco`). Num sítio só porque são as MESMAS peças em três
# lugares: ao ombro dele, na lingada do guindaste do n2 e na pilha do tabuado.
# Escritas duas vezes, a caixa que ele carrega e a da pilha divergiriam no
# primeiro ajuste, sem erro nenhum.
CAIXA_PAPELAO = (0.30, 0.28, 5.6)
SACO_RAFIA = (0.40, 0.22, 4.2)

PALETA = {
    "madeira": "#9a6438", "madeira_esc": "#633d20", "madeira_velha": "#7d7266",
    "metal": "#4a535a", "metal_claro": "#6d7880",
    "casco": "#24466e", "faixa": "#c23030", "cabine": "#eef2f5",
    "tronco": "#8a5a34", "folha": "#2d7a3a", "folha_clara": "#4a9c58",
    "telhado": "#c85420", "telhado_velho": "#8f6a4a", "parede": "#eef2f5", "parede_dir": "#cdd8e0", "porta": "#5a3a20",
    "telha_cume": "#8f3822", "luz_poste": "#ffe6a8",
    "laranja": "#c85420", "azul": "#2f7690", "amarelo": "#e09a10",
    # O vinco do corrugado do contêiner. Tem de ser MATERIAL e não geometria:
    # a face comprida dele tem 31px na tela, e a esta escala duas faces do
    # mesmo tom fundem-se — o `pilha_caixotes` mediu isso e ficou escrito lá.
    "laranja_esc": "#9c3f18",
    # Faixa refletiva de boia e marcador. Branco puro estoura ao lado do
    # laranja; este é o `cabine` levado um passo para o creme.
    "refletivo": "#f2f5f7",
    "boia": "#d94f2a", "corda": "#c9b48a",
    # ── AS MARCAS DA FROTA DE PESCA (frente 4, família frota) ────────────
    #
    # O ESCORRIDO de cada amurada, que é a cor dela levada ao escuro: o sujo
    # que a água do convés arrasta pelo embornal é da cor da tinta por onde
    # passa, e não uma mancha de outro material.
    # ⚠️ A BANDEIRA DO BRASIL SAIU DE TODOS OS NAVIOS (`073`, ordem do Bruno
    # ao fechar a `072`), e as três cores dela saíram com ela.
    "escorrido_vermelho": "#7a2220", "escorrido_azul": "#1d4a5c",
    # ⚠️ O ESCORRIDO DO AMARELO É MAIS CLARO do que a regra da cor levada ao
    # escuro daria (#8a5c10): o amarelo é a faixa mais clara das três, e o
    # mesmo fator punha nela o sujo mais forte da frota — o Bruno apontou-o
    # na primeira candidata («escorrido forte no amarelo»).
    "escorrido_amarelo": "#b07c1c",
    # A tinta ANTIVEGETATIVA da linha de água dos cargueiros: o vermelho-tijolo
    # que todo navio mercante mostra acima da água. Mais escuro do que a
    # `faixa` de cima, para o vermelho de acento continuar a ser um só.
    "antivegetativo": "#b4443a",
    # A rede de NYLON verde, que é a do pescador: o `rede` cinzento do kit é
    # de caixa, e encosta no `metal_claro` (ver o saco do arrasteiro).
    # ⚠️ E ELE É ESCURO E POUCO SATURADO: a #4a9a5a da segunda candidata pôs
    # o tambor a ser a peça mais chamativa do arrasteiro, a competir com o
    # pórtico, que é a silhueta dele (o Bruno: «tambor verde forte»).
    "rede_nylon": "#4f7d57", "rede_fio": "#22402a",
    # O peixe dentro do saco cheio, prateado, e o fio da rede da traineira,
    # que fica cinzenta (o Bruno, na segunda candidata).
    "peixe": "#b9c6cc", "rede_fio_cinza": "#4f5a62",
    "colete": "#e0561f", "capacete": "#e0a81f", "pele": "#b07b52",
    # ── AS TRÊS PELES E O CABELO GRISALHO, para os retratos de fala ──────
    #
    # O elenco do VS é de litoral brasileiro e tinha UMA cor de pele, porque
    # até aqui só existia um boneco. Com três rostos no mesmo cartão, a pele
    # deixa de ser um detalhe e passa a ser metade do que distingue um do
    # outro a 96px — é a regra da silhueta aplicada à cara.
    #
    # ⚠️ E NENHUMA DAS TRÊS É UMA ESCOLHA DO GDD: ele descreve o TOM de fala
    # de cada personagem e não a aparência de nenhum (`gdd/sistemas/npcs.md`).
    # Trocar qualquer uma é mudar uma chave aqui e regerar — está assim de
    # propósito, para a decisão poder ser do Bruno sem custar geometria.
    "pele_clara": "#c99a70", "pele_escura": "#8a5a3b",
    # ⚠️ E CADA TOM DE PELE PRECISA DO DEGRAU ABAIXO DELE, porque é a
    # SOMBRA que desenha o nariz — geometria não desenha nariz nenhum num
    # rosto de 44px (as faces laterais de uma peça saliente têm menos de um
    # pixel, e o resto apanha a mesma luz da cara). O `pele` serve de sombra
    # ao `pele_clara` e o `pele_escura` ao `pele`; o mais escuro dos três é
    # que não tinha degrau nenhum por baixo, e passa a ter.
    "pele_sombra": "#6e4630",
    # A lapela do terno do Sr. Ribeiro: o `casco` um passo abaixo. Duas
    # peças do mesmo tom encostadas fundem-se (a regra do caixote de
    # `madeira` no tabuado de `madeira`), e sem este degrau o peito dele
    # volta a ser a chapa navy que a primeira versão era.
    "terno_lapela": "#1a3554",
    # O grisalho do Sr. Ribeiro. Não é o `metal_claro` (#6d7880), que é a cor
    # de CHAPA deste kit e veste o poste e o guincho: um cabelo com a mesma
    # tinta de uma peça de metal lê como capacete, e a cabeça dele é metade da
    # silhueta que o distingue dos outros dois. Este é o mesmo cinza dois
    # passos mais claro (161 de luminância contra 118), que é a distância que
    # o põe acima da pele em vez de abaixo dela.
    "cabelo_grisalho": "#9aa3a8",
    # O DEGRAU ABAIXO do cabelo castanho, como o `pele_sombra` é o da pele: o
    # `madeira_esc` a 60%. É a calote da Dona Cida por baixo das mechas
    # (`docs/decisoes/055`) — no mesmo tom delas, as frestas acendiam-se e a
    # rampa da testa lia como UMA placa, uma franja curta.
    "cabelo_fundo": "#3b2513",
    # ── AS PELES DAS VARIAÇÕES DO TRABALHADOR (as cinco cores do IBGE) ────
    #
    # A branca é a `pele_clara` e a parda é a `pele`, que já existiam; estas
    # são as três que faltavam, cada uma com o DEGRAU abaixo dela (a regra de
    # cima: é a sombra que desenha o nariz). A amarela e a indígena
    # distinguem-se pelo TOM e pelo cabelo, nunca pelo desenho do rosto (o
    # escopo do Bruno, `058`): a amarela é a mais clara e a mais amarela das
    # cinco, a indígena a acobreada, mais vermelha do que a parda. A preta
    # fica entre o `pele_escura` e o `pele_sombra`: a `#5a3826` da v1 foi
    # «escura demais» (o Bruno) — 0,039 de luminância na bochecha, contra
    # 0,180 da parda.
    "pele_amarela": "#d4ab7e", "pele_amarela_sombra": "#b38a5e",
    "pele_cobre": "#a2663f", "pele_cobre_sombra": "#7d4a2c",
    "pele_funda": "#74492f", "pele_funda_sombra": "#56341f",
    # O cabelo preto, liso ou curto. O `vao` é o escuro do kit puxado a navy,
    # que é o da sombra do mapa; cabelo quer um preto quase neutro.
    "cabelo_preto": "#17181b",
    # O lábio de cor das trabalhadoras. Na v1 era o `telha_cume` da Dona Cida
    # e um rosado pálido, e «quase some» no cartão (o Bruno): mais saturados,
    # e na pele preta um amora, mais escuro do que ela e puxado ao roxo.
    "labio_rosado": "#c4545a", "labio_vermelho": "#a23d33", "labio_amora": "#7e2f3a",
    "calca": "#24466e", "rede": "#8d9aa6", "casco_pesca": "#2f6f4a", "parede_suja": "#9a9c93", "vidro": "#7fb6cc",
    # O TRABALHADOR QUE ANDA (`075`): a bota escura é o que faz o passo ler —
    # a 13 px de pessoa, os dois pés escuros a trocarem de lugar são o ciclo
    # inteiro. E as três cargas que ele leva ao ombro, uma por serviço: a
    # caixa de peixe é PLÁSTICO AZUL (a do pescador brasileiro), o papelão é
    # a carga geral e o saco de ráfia é o granel.
    "bota": "#2b2420", "caixa_peixe": "#2c6fb5", "papelao": "#b88a52",
    "rafia": "#f4f2ea",
    # O VÃO: o dentro de uma janela sem vidro ou de uma porta que já não há.
    # É a peça que faz uma ruína ler como ruína, e ela é uma COR e não um
    # buraco — furar a parede daria duas faces coplanares no batente, que é o
    # losango preto que este arquivo já registou duas vezes. Não é preto: preto
    # chapado ao lado do `parede_suja` lê como recorte falhado. É o navio do
    # tema levado ao escuro, que é a sombra que o resto do mapa já usa.
    "vao": "#2b3138",
    # O cais REFORÇADO do nível 3: concreto, e o mesmo tom que o mapa já
    # desenha no cais de pedra (`cais_topo`), para o píer de betão ler como
    # continuação dele e não como uma peça de outro jogo.
    "concreto": "#b9c2c8", "concreto_borda": "#8e9aa2",
    "pneu": "#33383c",
    # As cabines da segunda transportadora (`069`). Escolhidas contra o
    # ASFALTO (#49535b, luminância 0,084) pelo VALOR e não só pelo matiz: o
    # vermelho da primeira candidata separava-se dele só pela cor, e o Bruno
    # apontou-o. O verde mede 0,25 e o coral 0,21 — duas a três vezes o chão.
    "cab_verde": "#3e9a5c", "cab_coral": "#d9534f",
    # O VIDRO DE CAMIÃO: escuro e inteiro. O `vidro` do kit é o de CASA —
    # azul-claro, com moldura e travessa —, e no camião lia como janela de casa
    # (o Bruno, na segunda candidata). Para-brisa de camião lê escuro.
    "vidro_cab": "#34495a",
    # O PISO que sobra quando as paredes caem: o `parede_suja` levado ao
    # escuro. Sem ele a ruína inteira sai num cinzento só e as peças fundem-se
    # umas nas outras — a mesma regra do caixote que era `madeira` num tabuado
    # de `madeira`, aplicada dentro de um prop em vez de contra o cenário.
    "piso_ruina": "#6f736c",
    # A telha caída e o barrote à mostra. O `telhado_velho` é a água inteira;
    # estes dois são o que sobra dela.
    "barrote": "#6b543c",
    # ── A FAMÍLIA DE PADRÕES DIRIGIDOS (Etapa 4) ─────────────────────────
    # A ferrugem que escorre pelo casco. Ela é MAIS CLARA que o navio (86 de
    # luminância contra 66): num casco navy a mancha escura desapareceria, e o
    # que se vê num cargueiro real é justamente o rasto claro descendo.
    "ferrugem": "#8a4b2a",
    # ── O ARMAZÉM DEIXOU DE SER UMA CASA GRANDE (05/09) ──────────────────
    #
    # O VINCO DA CHAPA CORRUGADA. Mesma receita do contêiner, e pela mesma
    # razão: a face comprida do galpão tem 49px e a curta 34px, então doze
    # vincos de relevo dariam 2,5px cada — a LIXA que o `DESGASTE` já
    # registou. Quem desenha o corrugado aqui é a DIFERENÇA DE VALOR (21%
    # abaixo do `parede`), em painéis de 4 a 5px, e não o relevo.
    "chapa_vinco": "#b2c0c9",
    # O TELHADO DE ZINCO.
    #
    # ⚠️ ELE NASCEU COM O VALOR DO TELHADO DE TELHA, E ISSO NÃO CHEGOU.
    # A primeira versão foi escolhida pela regra do §3 da skill `/arte` lida
    # ao contrário — trocar o MATIZ sem tocar no VALOR —, e a conta fechava:
    # `#5f6e7a` dá 108 de luminância relativa contra os 105 do `telhado` de
    # telha. Medido no jogo rodando, o telhado ficou a **0,12 de Weber**
    # contra o asfalto do pátio... que é EXATAMENTE o que a telha já dava
    # (0,13). E aí está a lição: **a telha nunca se separou do chão pelo
    # VALOR, separou-se pelo MATIZ** — terracota contra cinza-azulado. Copiar
    # a luminância dela copiou a metade que não fazia o trabalho, e o zinco,
    # sendo cinza-azulado como o asfalto, ficou sem separação nenhuma.
    #
    # É a irmã da armadilha que a água registou em 02/09, do outro lado: lá
    # trocou-se o matiz e esqueceu-se o valor, e a imagem achatou; aqui
    # copiou-se o valor certo de uma cor que não vivia dele.
    #
    # A correção é DESCER: `#4e5b66` mede 0,26 de Weber contra o mesmo
    # asfalto. Custa 15 pontos de luminância média ao PROP (122,7 → 107,5) e
    # **zero ao mapa** — medida a captura inteira, média e amplitude ficam em
    # 116,3 e 151, contra 116,5 e 151 antes. Um prédio não move a composição;
    # move a própria leitura.
    "zinco": "#4e5b66", "zinco_vinco": "#3e4a54",
    # ── A RUÍNA COM DESGASTE (frente 4, família ruína, `074`) ────────────
    #
    # O TIJOLO que aparece onde o reboco caiu e nas quinas lascadas. Mais
    # escuro e mais castanho do que a telha (`telhado`, #c85420): os dois
    # vivem no mesmo prop, e a telha tem de continuar a ser a cor do telhado
    # do escritório pronto, que é o que o entulho laranja conta.
    "tijolo": "#84503c",
    # A LONA AZUL, que é a de todo telhado remendado no Brasil. É a cor de
    # acento do galpão em ruína, no lugar do laranja do portão do pronto, e
    # tem de ser uma: o portão caído fica desbotado de propósito.
    "lona": "#2c63b0",
    # A chapa e o zinco VELHOS: o `parede` e o `zinco` do galpão pronto
    # levados ao sujo. A chapa perde o branco — é ela que diz, de longe, que
    # o prédio não é o mesmo — e o zinco fica mais claro e mais baço, que é
    # o que a oxidação faz ao galvanizado.
    "chapa_velha": "#a9aea8", "chapa_velha_vinco": "#8b918c",
    "zinco_velho": "#6f7773", "zinco_velho_vinco": "#5b6360",
    # O laranja do portão, desbotado: o mesmo matiz do `laranja` do pronto,
    # para o jogador reconhecer a peça quando ela se levantar.
    "laranja_velho": "#a3593a",
    # O toldo azul e a placa amarela do escritório pronto, desbotados. São a
    # IDENTIDADE da ruína: sem eles, o canto de alvenaria é uma ruína
    # qualquer; com eles, é o escritório que o jogador vai reconstruir.
    "toldo_velho": "#4d8294", "placa_velha": "#c29a4a",
    # O capim que cresce nas frestas: mais amarelo do que a copa (`folha`),
    # para mato e árvore não se fundirem num verde só.
    "capim": "#7c9444",
}


# ---------------------------------------------------------------- material
def _linear(v: int) -> float:
    c = v / 255.0
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4


def material(nome: str, hexa: str):
    m = bpy.data.materials.new(nome)
    m.use_nodes = True
    b = m.node_tree.nodes["Principled BSDF"]
    h = hexa.lstrip("#")
    b.inputs["Base Color"].default_value = tuple(
        _linear(int(h[i:i + 2], 16)) for i in (0, 2, 4)) + (1.0,)
    # Sem brilho: flat design não tem realce especular.
    b.inputs["Roughness"].default_value = 1.0
    b.inputs["Specular IOR Level"].default_value = 0.0
    return m


def _escurecer(hexa: str, fator: float) -> tuple:
    h = hexa.lstrip("#")
    return tuple(_linear(max(0, min(255, int(int(h[i:i + 2], 16) * fator))))
                 for i in (0, 2, 4)) + (1.0,)


# Superfície fabricada ganha desgaste; o resto fica chapado. Folha, pele e
# vidro ficam de fora de propósito — ruído em folha vira sujeira e em pele
# vira doença.
#
# O NÚMERO É ESCALA DE RUÍDO, E ELA É RELATIVA AO TAMANHO DA PEÇA.
# Foi o erro da primeira tentativa: usei 14–24 para tudo. Numa longarina de
# guindaste com 0,045 de espessura isso dá uma marca por peça, que é o que se
# quer; numa parede de galpão com 3 unidades de largura dá setenta marcas, e
# na tela aquilo deixa de ser desgaste e vira LIXA — parede branca virou
# reboco, telhado virou chapa de cimento. A regra que ficou: peça grande pede
# número pequeno, e o teste é olhar o prop, não a tabela.
DESGASTE = {
    # superfícies grandes e lisas: mancha larga, quase um tom irregular
    "parede": 2.6, "parede_suja": 3.0, "telhado": 3.0, "telhado_velho": 2.6,
    "casco": 3.5, "casco_pesca": 3.5, "faixa": 4.0, "cabine": 5.0,
    # médias
    "madeira": 6.0, "madeira_esc": 6.0, "madeira_velha": 5.5,
    "azul": 5.0, "boia": 7.0, "tronco": 8.0,
    # peças pequenas: aqui sim número alto, senão a marca não cabe na peça
    "metal": 12.0, "metal_claro": 12.0, "laranja": 11.0, "amarelo": 13.0,
    "laranja_esc": 11.0,
    "rede": 14.0, "corda": 13.0,
    # O vão é pequeno e quer marca; o barrote é uma ripa fina, idem.
    "vao": 9.0, "barrote": 9.0, "piso_ruina": 4.0,
    "concreto": 3.0, "concreto_borda": 4.0, "pneu": 10.0,
    # A água de zinco é superfície grande; o vinco é um painel de 4px.
    "zinco": 3.0, "zinco_vinco": 8.0, "chapa_vinco": 8.0,
    # O tijolo solto da ruína é uma peça de 3px: número alto.
    "tijolo": 9.0,
    # `ferrugem` NÃO entra aqui: quem lhe dá superfície é o padrão dirigido que
    # a usa, e um ruído por cima de outro ruído é lixa.
}


def material_gasto(nome: str, hexa: str, escala: float):
    """A MESMA cor, manchada por um ruído e com um resto de brilho.

    Duas caixas da mesma cor chapada leem como a mesma caixa. É o ruído que as
    separa — não porque alguém vá reparar na mancha, mas porque sem ela a peça
    não tem superfície, só contorno preenchido.

    A rampa é estreita (0,42 a 0,62) de propósito: rampa larga vira degradê e
    o prop perde o ar de desenho, que é o que o mapa em SVG do lado dele tem.
    """
    m = bpy.data.materials.new(nome)
    m.use_nodes = True
    nt = m.node_tree
    b = nt.nodes["Principled BSDF"]

    ruido = nt.nodes.new("ShaderNodeTexNoise")
    ruido.inputs["Scale"].default_value = escala
    ruido.inputs["Detail"].default_value = 6.0
    ruido.inputs["Roughness"].default_value = 0.7

    rampa = nt.nodes.new("ShaderNodeValToRGB")
    rampa.color_ramp.elements[0].position = 0.42
    rampa.color_ramp.elements[0].color = _escurecer(hexa, 1.0)
    rampa.color_ramp.elements[1].position = 0.62
    # 0,78 escurecia demais e a mancha lia como sujeira pintada. 0,87 é a
    # diferença entre "esta parede tem superfície" e "esta parede está suja".
    rampa.color_ramp.elements[1].color = _escurecer(hexa, 0.87)

    nt.links.new(ruido.outputs["Fac"], rampa.inputs["Fac"])
    nt.links.new(rampa.outputs["Color"], b.inputs["Base Color"])
    b.inputs["Roughness"].default_value = 0.62
    b.inputs["Specular IOR Level"].default_value = 0.30
    return m


# ---------------------------------------------------- materiais DIRIGIDOS
#
# A Etapa 4 do plano de arte pede "uma família de padrões: ripa, corrugado,
# fiada de telha, ferrugem que escorre, cal descascada nas quinas". O
# `material_gasto` acima dá MANCHA — ruído isotrópico, sem direção nenhuma —, e
# mancha diz "esta superfície tem textura" e mais nada. Um padrão DIRIGIDO diz
# de que a superfície é FEITA: tábuas correm num sentido, ferrugem escorre para
# baixo.
#
# Estão aqui a RIPA e a FERRUGEM. Dos outros três:
#
# · o CORRUGADO ficou em 05/09 e saiu como PEÇA (`chapa_vinco` em `na_face`),
#   não como material — a face do armazém tem 49px e o passo tinha de bater com
#   as aberturas ao lado. Mesma família, ferramenta diferente: o padrão vira
#   material quando a superfície é grande e contínua, e vira peça quando é
#   pequena e o passo tem de concordar com um vizinho;
# · a FIADA DE TELHA já era geometria em `telhado_duas_aguas` desde 30/08, e
#   refazê-la como material seria desenhar por cima do desenho — que é
#   exatamente o que a Etapa 3 mediu e rejeitou;
# · a CAL DESCASCADA NAS QUINAS foi tentada e NÃO SE FAZ nesta geometria. Ver
#   o bloco abaixo, que é a lição e fica no lugar da função.
#
# ⚠️ A CAL DESCASCADA MORRE NO `Pointiness`, E A CAUSA É A GEOMETRIA DE CAIXA.
# O caminho óbvio é o nó `Geometry > Pointiness`, que mede convexidade e devia
# valer ~0,5 no pano e mais na quina. Só que **ele é um atributo de VÉRTICE**, e
# uma caixa chanfrada não tem vértice nenhum no meio da face: todos estão na
# aresta. O valor no pano não é medido, é INTERPOLADO dos cantos — não existe
# campo plano contra o qual comparar. Medido no galpão em ruína, a saída crua
# do `Pointiness` varia de 29 a 181 (0..255) com mediana 146 e **31% da parede
# acima de mediana+10**: uma distribuição larga e contínua, quando o efeito
# precisa de uma bimodal. Aplicado, ele pintou a parede INTEIRA de reboco e a
# ruína virou um barracão castanho.
#
# Subdividir a parede resolveria em teoria e não na prática: para uma orla de
# 2px seriam precisos vértices a cada ~0,1 unidade, e com a densidade que este
# kit usa (um vértice a cada 0,85) o efeito sai como um vinhetamento de 12px.
# Cal descascada, se voltar, vem de uma coordenada — distância à aresta da
# própria caixa —, nunca da curvatura da malha.
#
# ⚠️ E ELES NÃO ENTRAM NA PALETA, ENTRAM PEÇA A PEÇA. `madeira` veste o tabuado
# de 4,5×2,4 e também o caixote de 25px: ripar a entrada da paleta poria oito
# tábuas dentro de um caixote, que é a regra do `DESGASTE` outra vez — número
# grande em peça pequena vira lixa. Cada um destes é um material NOVO, atribuído
# aos objetos em que cabe.
#
# ⚠️ E O CORRUGADO NÃO ESTÁ AQUI, de propósito. Ele ficou em 05/09 no armazém e
# saiu como PEÇA (`chapa_vinco` em `na_face`), não como material, porque a face
# tem 49px e o passo tinha de ser exato. Mesma família, ferramenta diferente: o
# padrão vira material quando a superfície é grande e contínua, e vira peça
# quando ela é pequena e o passo tem de bater com uma abertura ao lado.


def _coord_do_eixo(nt, eixo: str):
    """A coordenada de OBJETO num eixo, que é onde todo padrão dirigido começa.

    Objeto e não UV: nenhuma peça deste projeto tem UV, e coordenada de objeto
    é o que faz o passo ficar em unidades de MUNDO — que é a única escala que
    este arquivo conhece, e a que a conta de pixels usa.
    """
    coord = nt.nodes.new("ShaderNodeTexCoord")
    sep = nt.nodes.new("ShaderNodeSeparateXYZ")
    nt.links.new(coord.outputs["Object"], sep.inputs["Vector"])
    return sep.outputs[eixo]


def material_ripado(nome: str, hexa: str, passo: float,
                    eixo: str = "Y", contraste: float = 0.88,
                    junta: float = 0.24, escuro_junta: float = 0.44):
    """Tábuas paralelas: uma JUNTA escura por tábua e um TOM próprio em cada.

    ⚠️ O TOM POR TÁBUA É O QUE SEPARA ISTO DE UM PENTE. Riscar linhas escuras a
    passo constante dá exatamente aquilo que a vila já ensinou a não fazer —
    *"73% dos vãos mediam o VILA_PASSO, e aquilo lia como cerca"*. O que faz um
    tabuado ler como tabuado é cada tábua ter a sua cor: a junta diz onde uma
    acaba, o tom diz que são peças diferentes. Sai de um `White Noise` 1D
    alimentado pelo ÍNDICE da tábua (`floor`), não pela posição — assim a tábua
    inteira tem um valor só, em vez de um degradê ao longo dela.

    `junta` é a fração da tábua que a sombra ocupa, e só de UM lado. Nos dois
    lados a sombra da tábua encontra a da vizinha e sai o dobro da largura: num
    tabuado de 0,30 (6px) isso dá 2px de junta para 4px de tábua, e o convés lê
    como grelha.
    """
    m = bpy.data.materials.new(nome)
    m.use_nodes = True
    nt = m.node_tree
    b = nt.nodes["Principled BSDF"]

    c = _coord_do_eixo(nt, eixo)

    div = nt.nodes.new("ShaderNodeMath")
    div.operation = "DIVIDE"
    div.inputs[1].default_value = passo
    nt.links.new(c, div.inputs[0])

    piso = nt.nodes.new("ShaderNodeMath")
    piso.operation = "FLOOR"
    nt.links.new(div.outputs["Value"], piso.inputs[0])

    # A posição DENTRO da tábua, por subtração — sem depender do nome do
    # operador de fração, que já mudou de identificador entre versões.
    dentro = nt.nodes.new("ShaderNodeMath")
    dentro.operation = "SUBTRACT"
    nt.links.new(div.outputs["Value"], dentro.inputs[0])
    nt.links.new(piso.outputs["Value"], dentro.inputs[1])

    ruido = nt.nodes.new("ShaderNodeTexWhiteNoise")
    ruido.noise_dimensions = "1D"
    nt.links.new(piso.outputs["Value"], ruido.inputs["W"])

    # Máscara da junta: 0 na sombra, 1 no corpo da tábua.
    #
    # ⚠️ COM DOIS PONTOS SÓ, A JUNTA NÃO SOBREVIVE À ESCALA. Uma rampa linear
    # de 0 a `junta` só chega ao escuro TOTAL no último pixel, e num passo de
    # 6px o que se vê é um degradê de um pixel — medido no jogo rodando, o
    # convés lia como bandas de tom e não como tábuas. O terceiro ponto dá à
    # sombra um PATAMAR: ela é escura de verdade em metade da sua largura e só
    # depois sobe. É a mesma lição das fiadas do telhado — o que o olho lê a
    # esta escala é a sombra ENTRE as peças, e sombra precisa de corpo.
    mascara = nt.nodes.new("ShaderNodeValToRGB")
    mascara.color_ramp.elements[0].position = 0.0
    mascara.color_ramp.elements[0].color = (0, 0, 0, 1)
    patamar = mascara.color_ramp.elements.new(junta * 0.45)
    patamar.color = (0, 0, 0, 1)
    mascara.color_ramp.elements[2].position = junta
    mascara.color_ramp.elements[2].color = (1, 1, 1, 1)
    nt.links.new(dentro.outputs["Value"], mascara.inputs["Fac"])

    combina = nt.nodes.new("ShaderNodeMath")
    combina.operation = "MULTIPLY"
    nt.links.new(ruido.outputs["Value"], combina.inputs[0])
    nt.links.new(mascara.outputs["Color"], combina.inputs[1])

    # UMA rampa resolve as três cores — junta, tábua escura, tábua clara — e
    # evita nós de mistura, cuja assinatura mudou entre versões do Blender.
    rampa = nt.nodes.new("ShaderNodeValToRGB")
    rampa.color_ramp.elements[0].position = 0.0
    rampa.color_ramp.elements[0].color = _escurecer(hexa, escuro_junta)
    e_meio = rampa.color_ramp.elements.new(0.14)
    e_meio.color = _escurecer(hexa, contraste)
    rampa.color_ramp.elements[2].position = 1.0
    rampa.color_ramp.elements[2].color = _escurecer(hexa, 1.0)
    nt.links.new(combina.outputs["Value"], rampa.inputs["Fac"])

    nt.links.new(rampa.outputs["Color"], b.inputs["Base Color"])
    b.inputs["Roughness"].default_value = 0.72
    b.inputs["Specular IOR Level"].default_value = 0.0
    return m


def material_escorrido(nome: str, hexa: str, cor_corrida: str,
                       escala: float = 7.0, alongamento: float = 0.16,
                       inicio: float = 0.52, fim: float = 0.70,
                       mundo: bool = False):
    """Ferrugem que ESCORRE: manchas esticadas no eixo Z, de cima para baixo.

    A diferença entre isto e o `material_gasto` é uma só, e é a que dá o nome à
    etapa: a mancha dele é isotrópica e não sabe onde é em cima. Ferrugem sabe.
    Ela nasce numa solda, num rebite ou numa amurada e a chuva puxa-a para
    baixo, então o rasto é comprido no vertical e estreito no horizontal.

    Quem faz isso é o `Mapping`, esticando a COORDENADA em Z antes do ruído —
    a escala do `Noise` é um número só e não sabe fazer anisotropia sozinha.
    `alongamento` de 0,16 estica as manchas cerca de seis vezes.

    ⚠️ E A RAMPA COMEÇA ALTA (0,52) DE PROPÓSITO. Ferrugem que cobre metade do
    casco não é um navio enferrujado, é um navio castanho — a peça perde a cor
    que a identifica, que é exatamente o que o contorno da Etapa 3 fez à lança.
    Aqui só o topo do ruído vira rasto; o resto do casco fica casco.

    `mundo` troca a coordenada de OBJETO pela de MUNDO, e é para quem veste
    peças feitas por `caixa()`: essas nascem com tamanho 1 e esticam-se pelo
    `scale`, que a coordenada de objeto não vê (`071`) — cada chapa do galpão
    teria o mesmo número de rastos, fosse ela de palmo ou de parede inteira.
    O casco não precisa: é um `prisma` com a malha no tamanho de verdade.
    """
    m = bpy.data.materials.new(nome)
    m.use_nodes = True
    nt = m.node_tree
    b = nt.nodes["Principled BSDF"]

    if mundo:
        fonte = nt.nodes.new("ShaderNodeNewGeometry").outputs["Position"]
    else:
        fonte = nt.nodes.new("ShaderNodeTexCoord").outputs["Object"]
    mapa = nt.nodes.new("ShaderNodeMapping")
    mapa.inputs["Scale"].default_value = (1.0, 1.0, alongamento)
    nt.links.new(fonte, mapa.inputs["Vector"])

    ruido = nt.nodes.new("ShaderNodeTexNoise")
    ruido.inputs["Scale"].default_value = escala
    ruido.inputs["Detail"].default_value = 4.0
    ruido.inputs["Roughness"].default_value = 0.62
    nt.links.new(mapa.outputs["Vector"], ruido.inputs["Vector"])

    rampa = nt.nodes.new("ShaderNodeValToRGB")
    rampa.color_ramp.elements[0].position = inicio
    rampa.color_ramp.elements[0].color = _escurecer(hexa, 1.0)
    rampa.color_ramp.elements[1].position = fim
    rampa.color_ramp.elements[1].color = _escurecer(cor_corrida, 1.0)
    nt.links.new(ruido.outputs["Fac"], rampa.inputs["Fac"])

    nt.links.new(rampa.outputs["Color"], b.inputs["Base Color"])
    b.inputs["Roughness"].default_value = 0.78
    b.inputs["Specular IOR Level"].default_value = 0.0
    return m


def material_alvenaria_velha(nome: str, hexa: str, cor_tijolo: str,
                             z_umido: tuple, escala: float = 3.0,
                             escala_reboco: float = 2.4,
                             limiar_reboco: float = 0.63,
                             quina: float = 0.035, limiar_quina: float = 0.10,
                             escala_lasca: float = 9.0,
                             limiar_lasca: float = 0.60):
    """Parede de alvenaria ABANDONADA: reboco caído, quina lascada, umidade.

    São as três marcas que a frente 4 pediu para a ruína (`074`), e as três
    saem da MESMA superfície — daí um material só, e não três peças:

    · o REBOCO CAÍDO é o topo de um ruído largo: onde ele passa do limiar, o
      que aparece é o tijolo. Irregular por construção, que é o que um remendo
      de `na_face` retangular não seria;
    · a QUINA LASCADA é o nó Ambient Occlusion com `inside`, que traça raios
      para DENTRO da peça e escurece onde há outra face perto — a terceira via
      que o plano de arte (§7.3, C3) mediu depois de o `Pointiness` morrer
      nesta geometria. A oclusão sozinha dá uma faixa lisa ao longo da aresta,
      que lê como vinheta; um segundo ruído parte-a em lascas;
    · a UMIDADE sobe do chão: a altura de MUNDO, sacudida por ruído, escurece
      a base. `z_umido` é (onde ela é plena, onde acaba), em unidades de mundo
      DEPOIS de toda escala do prédio — quem chama passa-as já escaladas.

    ⚠️ A COORDENADA É A DE MUNDO (`Geometry > Position`), e não a de objeto
    que o resto do kit usa. A parede é uma `caixa()` esticada pelo `scale`, e
    a coordenada de objeto lê a malha ANTES dele (`071`): o mesmo material
    daria um remendo por parede, fosse ela de meio metro ou de três. Em mundo
    o tamanho da marca é o mesmo em todas as peças que o vestem.
    """
    m = bpy.data.materials.new(nome)
    m.use_nodes = True
    nt = m.node_tree
    b = nt.nodes["Principled BSDF"]

    def op(operacao, a, c):
        n = nt.nodes.new("ShaderNodeMath")
        n.operation = operacao
        for i, v in enumerate((a, c)):
            if isinstance(v, (int, float)):
                n.inputs[i].default_value = v
            else:
                nt.links.new(v, n.inputs[i])
        return n.outputs[0]

    def ruido(esc, detalhe=5.0, aspereza=0.6):
        n = nt.nodes.new("ShaderNodeTexNoise")
        n.inputs["Scale"].default_value = esc
        n.inputs["Detail"].default_value = detalhe
        n.inputs["Roughness"].default_value = aspereza
        nt.links.new(geo.outputs["Position"], n.inputs["Vector"])
        return n.outputs["Fac"]

    geo = nt.nodes.new("ShaderNodeNewGeometry")
    xyz = nt.nodes.new("ShaderNodeSeparateXYZ")
    nt.links.new(geo.outputs["Position"], xyz.inputs["Vector"])

    mancha = ruido(escala)
    reboco = op("GREATER_THAN", ruido(escala_reboco, 3.0, 0.55), limiar_reboco)

    ao = nt.nodes.new("ShaderNodeAmbientOcclusion")
    ao.inside = True
    ao.only_local = True
    ao.samples = 8
    ao.inputs["Distance"].default_value = quina
    # `1 − AO` é quanto a quina aperta, e um ruído mais largo escolhe EM QUE
    # TROÇOS dela a tinta caiu.
    # ⚠️ SOMAR O RUÍDO À OCLUSÃO NÃO PARTE A FAIXA — CONTORNA O PRÉDIO. Foi a
    # primeira candidata: com a oclusão a 0,07 e o ruído somado, toda aresta
    # passava do limiar em quase todo o comprimento, e o escritório saiu com
    # uma MOLDURA laranja à volta de cada parede. Lasca é a interseção de
    # duas coisas — perto da quina E num troço sorteado —, e isso é um E, que
    # é um produto, e não uma soma.
    aperto = op("SUBTRACT", 1.0, ao.outputs["AO"])
    quina_viva = op("MULTIPLY", op("GREATER_THAN", aperto, limiar_quina),
                    op("GREATER_THAN", ruido(escala_lasca, 3.0), limiar_lasca))

    tijolo = op("MAXIMUM", reboco, quina_viva)
    estado = op("MULTIPLY", mancha, op("SUBTRACT", 1.0, tijolo))

    rampa = nt.nodes.new("ShaderNodeValToRGB")
    rampa.color_ramp.elements[0].position = 0.0
    rampa.color_ramp.elements[0].color = _escurecer(cor_tijolo, 1.0)
    e = rampa.color_ramp.elements.new(0.05)
    e.color = _escurecer(cor_tijolo, 1.0)
    e = rampa.color_ramp.elements.new(0.06)
    e.color = _escurecer(hexa, 1.0)
    e = rampa.color_ramp.elements.new(0.42)
    e.color = _escurecer(hexa, 1.0)
    rampa.color_ramp.elements[-1].position = 0.62
    rampa.color_ramp.elements[-1].color = _escurecer(hexa, 0.87)
    nt.links.new(estado, rampa.inputs["Fac"])

    # A umidade: a altura sacudida, levada a um fator que MULTIPLICA a cor.
    altura = op("ADD", xyz.outputs["Z"],
                op("MULTIPLY", op("SUBTRACT", ruido(7.0, 3.0), 0.5), 0.12))
    faixa = nt.nodes.new("ShaderNodeMapRange")
    faixa.clamp = True
    faixa.inputs["From Min"].default_value = z_umido[0]
    faixa.inputs["From Max"].default_value = z_umido[1]
    faixa.inputs["To Min"].default_value = 0.66
    faixa.inputs["To Max"].default_value = 1.0
    nt.links.new(altura, faixa.inputs["Value"])

    escala_cor = nt.nodes.new("ShaderNodeVectorMath")
    escala_cor.operation = "SCALE"
    nt.links.new(rampa.outputs["Color"], escala_cor.inputs[0])
    nt.links.new(faixa.outputs["Result"], escala_cor.inputs["Scale"])
    nt.links.new(escala_cor.outputs["Vector"], b.inputs["Base Color"])
    b.inputs["Roughness"].default_value = 0.9
    b.inputs["Specular IOR Level"].default_value = 0.0
    return m


def material_malha(nome: str, fio: str, fundo: str, escala: float = 16.0,
                   espessura: float = 0.10):
    """Rede: um fundo com fios escuros em malha IRREGULAR.

    O Voronoi com `DISTANCE_TO_EDGE` dá a distância à fronteira da célula; o
    que fica abaixo de `espessura` é fio. As células saem desiguais, e é isso
    que uma rede amontoada ou enrolada parece — o losango certo só se vê com
    a rede esticada, e aqui ela nunca está.
    """
    m = bpy.data.materials.new(nome)
    m.use_nodes = True
    nt = m.node_tree
    b = nt.nodes["Principled BSDF"]
    coord = nt.nodes.new("ShaderNodeTexCoord")
    vor = nt.nodes.new("ShaderNodeTexVoronoi")
    vor.feature = "DISTANCE_TO_EDGE"
    vor.inputs["Scale"].default_value = escala
    nt.links.new(coord.outputs["Object"], vor.inputs["Vector"])
    rampa = nt.nodes.new("ShaderNodeValToRGB")
    rampa.color_ramp.interpolation = "CONSTANT"
    rampa.color_ramp.elements[0].position = 0.0
    rampa.color_ramp.elements[0].color = _escurecer(fio, 1.0)
    rampa.color_ramp.elements[1].position = espessura
    rampa.color_ramp.elements[1].color = _escurecer(fundo, 1.0)
    nt.links.new(vor.outputs["Distance"], rampa.inputs["Fac"])
    nt.links.new(rampa.outputs["Color"], b.inputs["Base Color"])
    b.inputs["Roughness"].default_value = 0.9
    b.inputs["Specular IOR Level"].default_value = 0.0
    return m


def material_malha_losango(nome: str, fio: str, fundo: str,
                           passo: float = 0.07, espessura: float = 0.30):
    """Rede ESTICADA: losangos regulares, que é como um saco cheio a pende.

    ⚠️ A MALHA DO VORONOI LÊ COMO PEDRA num volume redondo: células
    desiguais sobre uma bola cinzenta são a textura de um calhau (o Bruno, na
    quarta candidata: «saco lê como pedra»). O saco içado tem a rede esticada
    pelo peso, e aí a malha é regular. Duas famílias de planos a 45°, `(x+y)±z`,
    e o que fica a menos de `espessura` de um plano é fio.
    """
    m = bpy.data.materials.new(nome)
    m.use_nodes = True
    nt = m.node_tree
    b = nt.nodes["Principled BSDF"]

    def op(operacao, a, c):
        n = nt.nodes.new("ShaderNodeMath")
        n.operation = operacao
        for i, v in enumerate((a, c)):
            if isinstance(v, (int, float)):
                n.inputs[i].default_value = v
            else:
                nt.links.new(v, n.inputs[i])
        return n.outputs[0]

    coord = nt.nodes.new("ShaderNodeTexCoord")
    xyz = nt.nodes.new("ShaderNodeSeparateXYZ")
    nt.links.new(coord.outputs["Object"], xyz.inputs["Vector"])
    h = op("MULTIPLY", op("ADD", xyz.outputs["X"], xyz.outputs["Y"]),
           1.0 / passo)
    v = op("MULTIPLY", xyz.outputs["Z"], 1.0 / passo)
    fio_a = op("LESS_THAN", op("FRACT", op("ADD", h, v), 0.0), espessura)
    fio_b = op("LESS_THAN", op("FRACT", op("SUBTRACT", h, v), 0.0), espessura)
    rampa = nt.nodes.new("ShaderNodeValToRGB")
    rampa.color_ramp.interpolation = "CONSTANT"
    rampa.color_ramp.elements[0].position = 0.0
    rampa.color_ramp.elements[0].color = _escurecer(fundo, 1.0)
    rampa.color_ramp.elements[1].position = 0.5
    rampa.color_ramp.elements[1].color = _escurecer(fio, 1.0)
    nt.links.new(op("MAXIMUM", fio_a, fio_b), rampa.inputs["Fac"])
    nt.links.new(rampa.outputs["Color"], b.inputs["Base Color"])
    b.inputs["Roughness"].default_value = 0.8
    b.inputs["Specular IOR Level"].default_value = 0.0
    return m


# Preenchido por paleta_completa(). O kit de detalhe lê daqui em vez de
# receber `M` em toda assinatura — são seis funções e o dicionário é um só.
PALETA_MAT: dict = {}


def paleta_completa() -> dict:
    """A paleta virada em materiais: gasto onde faz sentido, chapado no resto."""
    global PALETA_MAT
    PALETA_MAT = {k: (material_gasto(k, v, DESGASTE[k]) if k in DESGASTE
                      else material(k, v))
                  for k, v in PALETA.items()}
    return PALETA_MAT


def chanfrar(objs, largura: float = 0.020, segmentos: int = 2) -> None:
    """Chanfro em toda peça, aplicado no fim e nunca na geometria de origem.

    Aresta viva não pega luz: os dois lados dela devolvem o seu tom chapado e o
    encontro entre eles é um salto. Chanfrada, o encontro vira uma faixa fina
    que apanha a luz de raspão, e o volume aparece sem que nada mais mude.

    A largura é pequena porque ela ENCOLHE a silhueta — cada canto recua cerca
    de `largura`. Com 0,020 o tabuado perde ~1,13 px dos 138 de TELA, dentro
    da margem de 4 px da verificação de projeção lá embaixo. (Dizia "1,7 px
    dos 207", que é a conta de antes do ZOOM de 05/09 e nunca foi refeita — os
    207 são 6,9 × MEIA_LARG, e o que se mede é 6,9 × MEIA_LARG_TELA.) Subir isto sem olhar aquela
    conta é como se quebra o alinhamento com o mapa.
    """
    for o in objs:
        if o.type != "MESH":
            continue
        mod = o.modifiers.new("chanfro", "BEVEL")
        mod.width = largura
        mod.segments = segmentos
        mod.limit_method = "ANGLE"
        mod.angle_limit = math.radians(40.0)


# ---------------------------------------------------------------- geometria
def desloc_trabalhador() -> tuple:
    """O deslocamento (Δmx, Δmy) do quadro do TRABALHADOR contra o do PÍER,
    lido dos `offset` dos dois nós no `Dock.tscn` (`076`).

    É o que deixa desenhar o operador do guincho, que fica ao pé do mastro do
    píer, num PNG do trabalhador: os dois quadros têm 512 e a origem do mundo
    no centro, mas o nó do trabalhador foi deslocado na cena para o pôr à
    beira do costado. Um par de números copiado daqui envelheceria no dia em
    que alguém mexesse naquele nó — e o D39 lê a figura no render para o
    confirmar.
    """
    cena = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..",
                        "brport_vs", "scenes", "dock", "Dock.tscn")
    nos, atual = {}, None
    for linha in open(cena, encoding="utf-8"):
        if linha.startswith("[node "):
            atual = linha.split('name="')[1].split('"')[0]
            nos[atual] = {}
        elif atual and linha.startswith(("offset_left", "offset_top")):
            chave, valor = linha.split("=")
            nos[atual][chave.strip()] = float(valor)
    dx = nos["Trabalhador"]["offset_left"] - nos["Pier"]["offset_left"]
    dy = nos["Trabalhador"]["offset_top"] - nos["Pier"]["offset_top"]
    # tela: dx = (Δmx − Δmy)·MEIA_LARG_TELA e dy = (Δmx + Δmy)·MEIA_LARG_TELA/2
    soma, dif = dy / (MEIA_LARG_TELA / 2.0), dx / MEIA_LARG_TELA
    return ((soma + dif) / 2.0, (soma - dif) / 2.0)


def pos(mx: float, my: float, altura_px: float = 0.0) -> tuple:
    """Coordenada DO MAPA -> coordenada do Blender.

    O sinal de Y é invertido, e isso não é capricho. No Blender a direita da
    tela é o vetor (+X, +Y): os dois eixos do chão puxam para a direita. No
    mapa, `tela_x = (mx - my) * MEIA_LARG` — o +my puxa para a ESQUERDA.
    Logo `y_blender = -my`.

    Um prop simétrico em Y não denuncia a diferença, e por isso o píer passou
    despercebido; o primeiro prop assimétrico (o trabalhador, que fica de lado
    no tabuado) saiu 40px fora do lugar. Use isto sempre que a posição vier de
    coordenadas do mapa.
    """
    return (mx, -my, z(altura_px))


# ── O ARNÊS DA MONTAGEM: as primitivas sem o `view_layer.update()` ─────────
#
# Todo `bpy.ops.*` passa pelo invólucro Python de `bpy/ops.py`, que chama
# `view_layer.update()` ANTES e DEPOIS do operador. Depois de um objeto novo,
# essa atualização refaz o grafo da cena inteira — custa o número de objetos
# que já lá estão —, e o catálogo monta-se todo numa cena só, mesmo quando se
# pede um prop: a montagem é QUADRÁTICA. A do porto passou dos 30 min sem um
# PNG (`079`).
#
# Uma primitiva não precisa de nenhuma das duas. O operador cria a malha e o
# objeto a partir dos argumentos, e o que o kit escreve a seguir — nome,
# escala, rotação, material — é dado ORIGINAL, que nenhum grafo lê. Quem
# precisa da cena avaliada pede-a: o raio dos retratos tira-a do
# `evaluated_depsgraph_get()`, que atualiza antes de devolver, a câmera tem o
# seu `update()` explícito, e o render avalia tudo. As outras chamadas de
# `bpy.ops` ficam como estavam (`docs/decisoes/080`).
#
# ⚠️ O GANCHO É PRIVADO: `_BPyOpsSubModOp._view_layer_update`, no `bpy` 4.5.
# Um Blender que não o tenha monta pelo caminho lento e di-lo numa linha — o
# arnês só compra tempo, e na falta dele o resultado é o mesmo.
# ⚠️ E O QUE O PROVA É O DESPEJO, NÃO O RENDER: com `BRP_CAMINHO_LENTO=1` a
# montagem volta ao caminho de sempre, e as duas cenas despejadas por
# `--despejar` saem iguais byte a byte. O PNG não serve de prova, porque o
# denoiser do Cycles varia ±2/255 entre duas corridas do mesmo código.
def _resolver_arnes():
    """(classe, staticmethod original) do gancho, ou (None, motivo)."""
    if os.environ.get("BRP_CAMINHO_LENTO") == "1":
        return None, "pedido por BRP_CAMINHO_LENTO=1"
    try:
        from bpy import ops as _ops
        classe = _ops._BPyOpsSubModOp
        return (classe, classe.__dict__["_view_layer_update"]), ""
    except (ImportError, AttributeError, KeyError):
        return None, "este bpy não tem o gancho _view_layer_update"


_ARNES, _SEM_ARNES = _resolver_arnes()


def _nao_atualizar(_contexto):
    pass


def primitiva(operador: str, **argumentos):
    """`bpy.ops.mesh.<operador>(**argumentos)` sem as duas atualizações do
    grafo, e devolve o objeto criado (que o operador deixa ativo).

    Toda primitiva do kit e dos retratos passa por aqui: uma chamada direta
    a `bpy.ops.mesh.primitive_*` montaria certo e devolveria a lentidão.
    """
    operacao = getattr(bpy.ops.mesh, operador)
    if _ARNES is None:
        operacao(**argumentos)
    else:
        classe, original = _ARNES
        classe._view_layer_update = staticmethod(_nao_atualizar)
        try:
            operacao(**argumentos)
        finally:
            classe._view_layer_update = original
    return bpy.context.active_object


def caminho_da_montagem() -> str:
    """A linha que diz por que caminho a cena foi montada."""
    if _ARNES is None:
        return "montagem: caminho LENTO (%s)" % _SEM_ARNES
    return "montagem: arnês ligado (primitivas sem view_layer.update)"


def despejar_cena(caminho: str) -> int:
    """Escreve a cena montada em texto, objeto a objeto, e devolve quantos.

    É a régua do arnês: duas montagens que despejam os mesmos bytes renderizam
    a mesma imagem, porque o render só lê o que está aqui — a geometria
    AVALIADA (depois do chanfro), a matriz, a visibilidade e os materiais. Os
    floats saem em `repr`, que é exato: o despejo não arredonda nada, e por
    isso não tem ruído próprio (duas corridas do mesmo caminho dão os mesmos
    bytes, medido em `080`).

    ⚠️ AS UVs FICAM DE FORA, E ISSO TEM CONDIÇÃO. O chanfro interpola-as com
    um erro de 1 ULP (5,96e-8) que muda de caixa para caixa: oito caixas
    IGUAIS na mesma cena davam quatro UVs diferentes, e dois despejos do
    MESMO caminho divergiam em 2.570 linhas — a régua tinha ruído próprio, e
    ele tapava qualquer diferença de verdade. Ignorá-las só vale enquanto
    nenhum material as ler (hoje todos leem a coordenada `Object`, a
    `Position` ou a `Generated` das texturas procedurais), e é isso que a
    guarda abaixo pergunta antes de despejar.
    """
    for mat in bpy.data.materials:
        for no in (mat.node_tree.nodes if mat.node_tree else ()):
            le_uv = (no.bl_idname in ("ShaderNodeUVMap", "ShaderNodeTexImage",
                                      "ShaderNodeNormalMap", "ShaderNodeTangent")
                     or (no.bl_idname == "ShaderNodeTexCoord"
                         and no.outputs["UV"].is_linked))
            if le_uv:
                raise SystemExit(
                    "despejo: o material %s lê UV (%s), e o despejo ignora as "
                    "UVs — ver despejar_cena()" % (mat.name, no.bl_idname))
    bpy.context.view_layer.update()
    grafo = bpy.context.evaluated_depsgraph_get()
    linhas = []
    objetos = sorted(bpy.data.objects, key=lambda o: o.name)
    for o in objetos:
        mw = [v for linha in o.matrix_world for v in linha]
        linhas.append("%s %s pai=%s" % (o.name, o.type,
                                        o.parent.name if o.parent else "-"))
        linhas.append("  mw %s" % " ".join(repr(v) for v in mw))
        linhas.append("  vis render=%d camera=%d sombra=%d" % (
            o.hide_render, o.visible_camera, o.visible_shadow))
        linhas.append("  mats %s" % ",".join(
            s.material.name if s.material else "-" for s in o.material_slots))
        if o.type != "MESH":
            continue
        avaliado = o.evaluated_get(grafo)
        malha = avaliado.to_mesh()
        resumo = hashlib.sha256()
        for colecao, atributo, largura, tipo in (
                (malha.vertices, "co", 3, np.float32),
                (malha.loops, "vertex_index", 1, np.int32),
                (malha.polygons, "loop_start", 1, np.int32),
                (malha.polygons, "material_index", 1, np.int32),
                (malha.corner_normals, "vector", 3, np.float32)):
            dados = np.empty(len(colecao) * largura, dtype=tipo)
            colecao.foreach_get(atributo, dados)
            resumo.update(dados.tobytes())
        linhas.append("  malha v=%d f=%d %s" % (
            len(malha.vertices), len(malha.polygons), resumo.hexdigest()))
        avaliado.to_mesh_clear()
    # Monta o texto todo antes de abrir: `open(..., "w")` trunca de imediato,
    # e um erro a meio deixaria o despejo vazio — que compara igual a outro
    # despejo vazio.
    texto = "\n".join(linhas) + "\n"
    with open(caminho, "w", encoding="utf-8") as f:
        f.write(texto)
    return len(objetos)


def caixa(nome, centro, tam, mat, rot=(0, 0, 0)):
    o = primitiva("primitive_cube_add", size=1.0, location=centro)
    o.name = nome
    o.scale = tam
    o.rotation_euler = tuple(math.radians(a) for a in rot)
    o.data.materials.append(mat)
    return o


def cone(nome, centro, r1, r2, alt, lados, mat, rot=(0, 0, 0)):
    o = primitiva("primitive_cone_add", vertices=lados, radius1=r1, radius2=r2,
                  depth=alt, location=centro)
    o.name = nome
    o.rotation_euler = tuple(math.radians(a) for a in rot)
    o.data.materials.append(mat)
    return o


def bola(nome, centro, raios, mat, rot=(0, 0, 0)):
    """Uma esfera esticada: o lobo de um saco de rede cheio."""
    o = primitiva("primitive_uv_sphere_add", segments=16, ring_count=8,
                  radius=1.0, location=centro)
    o.name = nome
    o.scale = raios
    # ⚠️ A ESCALA APLICA-SE NA MALHA: a coordenada `Object` de um material lê
    # a malha ANTES do `scale`, e numa esfera de raio 1 esticada a 0,16 a
    # malha de losangos saía seis vezes mais fina do que o pedido — um
    # granulado sem losango nenhum.
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    o.rotation_euler = tuple(math.radians(a) for a in rot)
    o.data.materials.append(mat)
    return o


def anel(nome, centro, r_maior, r_menor, mat, rot=(0, 0, 0), lados=16):
    """Um toro: a boia salva-vidas. Nenhuma caixa nem cone faz um anel."""
    o = primitiva("primitive_torus_add", major_radius=r_maior,
                  minor_radius=r_menor, major_segments=lados,
                  minor_segments=6, location=centro)
    o.name = nome
    o.rotation_euler = tuple(math.radians(a) for a in rot)
    o.data.materials.append(mat)
    return o


# ── O TRONCO DO COQUEIRO, arqueado ────────────────────────────────────────
#
# `CURVA_TRONCO` é o giro TOTAL do pé ao topo, em graus de MUNDO, somado ao
# caimento de 4° que o tronco sempre teve. ⚠️ Graus de mundo NÃO são graus de
# tela — esta câmera comprime a direção (1,1) e estica a (1,-1) —, então o
# número escolhe-se olhando o PNG e medindo o desvio em PIXEL, nunca aqui.
CAIMENTO_TRONCO = 4.0      # o que o tronco já tinha, e continua a ter no pé
# ⚠️ OS 30° SÃO MEDIDOS NA IMAGEM, e a varredura está em `docs/decisoes/028`:
# a flecha da silhueta contra a corda dá 1,73 px no tronco reto (que é o RUÍDO
# da régua, não zero — 16 px de largura, seis faces e antisserrilhado), 2,53 aos
# 15°, 3,66 aos 30° e 4,54 aos 45°. Aos 30 o topo anda 8,8 px, mais de meia
# largura do próprio tronco. Aos 45 o tronco PERDE 23% da altura na tela e lê
# como cajado, não como palmeira — o corte não fica colado a nenhuma ponta.
CURVA_TRONCO = 30.0        # graus a mais do pé ao topo; 0 = a reta de sempre
SEG_TRONCO = 6             # segmentos do arco
FOLGA_TRONCO = 0.12        # sobreposição entre segmentos, em fração do passo

ALT_TRONCO = 2.3
RAIO_TRONCO = (0.17, 0.11)


def tronco_arqueado(M):
    """Os segmentos do tronco, e o DESLOCAMENTO do topo em relação à reta.

    A 0° de curva devolve UM cone idêntico ao que o coqueiro sempre teve — é o
    que torna a varredura honesta, porque o ponto de partida dela é o prop
    commitado e não uma aproximação dele.
    """
    a0 = math.radians(CAIMENTO_TRONCO)
    # O pé fica onde já estava: o cone de sempre tem o CENTRO em (0, 0, 1,15) e
    # roda sobre ele, o que põe o pé em y = +0,080. Mexer nisso deslocaria o
    # coqueiro inteiro dentro do quadro de 512 sem que nada reprovasse.
    d0 = (0.0, -math.sin(a0), math.cos(a0))
    pe = (0.0, -d0[1] * ALT_TRONCO / 2.0, 1.15 - d0[2] * ALT_TRONCO / 2.0)
    topo_reto = (pe[0] + d0[0] * ALT_TRONCO,
                 pe[1] + d0[1] * ALT_TRONCO,
                 pe[2] + d0[2] * ALT_TRONCO)

    if abs(CURVA_TRONCO) < 1e-9:
        return ([cone("tronco", (0, 0, 1.15), RAIO_TRONCO[0], RAIO_TRONCO[1],
                      ALT_TRONCO, 6, M["tronco"], rot=(CAIMENTO_TRONCO, 0, 0))],
                (0.0, 0.0, 0.0))

    n = max(2, SEG_TRONCO)
    passo = ALT_TRONCO / n
    pecas = []
    p = list(pe)
    for i in range(n):
        # O ângulo da TANGENTE cresce linearmente com o comprimento de arco —
        # é o que faz um arco de círculo, e não um joelho no meio do tronco.
        a = a0 + math.radians(CURVA_TRONCO) * (i + 0.5) / n
        d = (0.0, -math.sin(a), math.cos(a))
        t0, t1 = i / float(n), (i + 1) / float(n)
        r1 = RAIO_TRONCO[0] + (RAIO_TRONCO[1] - RAIO_TRONCO[0]) * t0
        r2 = RAIO_TRONCO[0] + (RAIO_TRONCO[1] - RAIO_TRONCO[0]) * t1
        alt = passo * (1.0 + FOLGA_TRONCO)
        centro = (p[0] + d[0] * passo / 2.0,
                  p[1] + d[1] * passo / 2.0,
                  p[2] + d[2] * passo / 2.0)
        pecas.append(cone("tronco%d" % i, centro, r1, r2, alt, 6, M["tronco"],
                          rot=(math.degrees(a), 0, 0)))
        p = [p[0] + d[0] * passo, p[1] + d[1] * passo, p[2] + d[2] * passo]

    return pecas, (p[0] - topo_reto[0], p[1] - topo_reto[1], p[2] - topo_reto[2])


def prisma(nome, contorno, z0, z1, escala_baixo, mat, contorno_baixo=None):
    """Contorno fechado puxado para baixo e estreitado.

    É o que torna forma não-caixa possível em código: em vez de esculpir, você
    lista os pontos do contorno. O casco de barco sai daqui — e sai idêntico
    toda vez, ao contrário de um desenho.

    ⚠️ ESCALAR UM CONTORNO CURVO ACHATA A CURVA DELE, e num casco isso deixou a
    linha de fundo reta depois de o convés já estar curvo. Com `escala_baixo =
    (0,88, 0,42)` a variação de meia-boca encolhe 58%, e o que sobra desvia-se
    menos de um pixel ao longo de 60 px — ou seja, a régua lê uma reta. Quem
    quiser um fundo com curva PRÓPRIA passa `contorno_baixo` e o `escala_baixo`
    deixa de ser usado; os dois contornos têm de ter o mesmo número de pontos,
    porque é ponto a ponto que as faces do costado se fecham.
    """
    if contorno_baixo is None:
        ex, ey = escala_baixo
        contorno_baixo = [(x * ex, y * ey) for x, y in contorno]
    elif len(contorno_baixo) != len(contorno):
        raise ValueError("%s: contorno de %d pontos e fundo de %d"
                         % (nome, len(contorno), len(contorno_baixo)))
    verts = [(x, y, z1) for x, y in contorno] + \
            [(x, y, z0) for x, y in contorno_baixo]
    n = len(contorno)
    faces = [[i, (i + 1) % n, n + (i + 1) % n, n + i] for i in range(n)]
    faces.append(list(range(n - 1, -1, -1)))
    faces.append(list(range(n, 2 * n)))
    me = bpy.data.meshes.new(nome)
    me.from_pydata(verts, [], faces)
    me.update()
    o = bpy.data.objects.new(nome, me)
    bpy.context.collection.objects.link(o)
    o.data.materials.append(mat)
    return o


def barra(nome, a, b, esp: float, mat):
    """Uma peça reta ligando dois pontos quaisquer.

    Sem isto toda estrutura inclinada vira conta de seno na mão — foi assim que
    a primeira treliça saiu torta. `to_track_quat` resolve a orientação de uma
    vez: dá a rotação que aponta o +Z do cubo para o vetor a->b.
    """
    a, b = Vector(a), Vector(b)
    d = b - a
    o = caixa(nome, tuple((a + b) / 2.0), (esp, esp, d.length), mat)
    o.rotation_euler = d.to_track_quat("Z", "Y").to_euler()
    return o


def trelica(nome, a, b, lado: float, mat, montantes: int = 6,
            esp: float = 0.05) -> list:
    """Quatro banzos, travessas e diagonais entre dois pontos.

    É a peça que mais separa um guindaste de verdade de uma caixa comprida:
    guindaste é VAZADO, e o vazado deixa o fundo aparecer no meio da estrutura.
    Nenhuma quantidade de luz faz uma caixa maciça ler como guindaste.

    Funciona em qualquer direção — torre (vertical), lança (horizontal) ou
    tirante (inclinado) saem todos daqui.
    """
    a, b = Vector(a), Vector(b)
    eixo = (b - a).normalized()
    # Referência qualquer que não seja paralela ao eixo, senão o produto
    # vetorial degenera e a treliça nasce achatada.
    ref = Vector((0, 0, 1)) if abs(eixo.z) < 0.9 else Vector((1, 0, 0))
    u = eixo.cross(ref).normalized()
    v = eixo.cross(u).normalized()

    pecas = []
    cantos = [lado * u + lado * v, lado * u - lado * v,
              -lado * u + lado * v, -lado * u - lado * v]
    for i, k in enumerate(cantos):
        pecas.append(barra("%s_banzo%d" % (nome, i), a + k, b + k, esp, mat))
    for i in range(montantes + 1):
        p = a + (b - a) * (i / montantes)
        pecas.append(barra("%s_tu%d" % (nome, i), p + lado * u + lado * v,
                           p + lado * u - lado * v, esp * 0.75, mat))
        pecas.append(barra("%s_tv%d" % (nome, i), p - lado * u + lado * v,
                           p - lado * u - lado * v, esp * 0.75, mat))
    for i in range(montantes):
        p0 = a + (b - a) * (i / montantes)
        p1 = a + (b - a) * ((i + 1) / montantes)
        sinal = 1.0 if i % 2 == 0 else -1.0
        pecas.append(barra("%s_da%d" % (nome, i), p0 + lado * u + sinal * lado * v,
                           p1 + lado * u - sinal * lado * v, esp * 0.65, mat))
        pecas.append(barra("%s_db%d" % (nome, i), p0 - lado * u + sinal * lado * v,
                           p1 - lado * u - sinal * lado * v, esp * 0.65, mat))
    return pecas


def para_pixel(p) -> tuple:
    """Ponto do mundo -> pixel dentro do PNG, que tem RESOLUCAO de lado.

    A câmera mira a origem, então a origem cai no centro do quadro. O resto é
    projetar em cima dos eixos da câmera.

    ⚠️ ISTO DEVOLVE PIXEL DO PNG, E O NÓ DO GODOT FALA TELA. Enquanto os dois
    quadros tinham 512 os dois números eram o mesmo e ninguém tinha de
    escolher; desde a alavanca B não são, e quem quiser o número que vai para
    um `.tscn` chama `para_pixel_tela()`. É a armadilha que o `MEIO_QUADRO` do
    teste de design tem do outro lado: dois números iguais medidos de sítios
    diferentes não são a mesma medida.
    """
    rx, rz = math.radians(ROT_X), math.radians(ROT_Z)
    direita = Vector((math.cos(rz), math.sin(rz), 0.0))
    cima = Vector((-math.sin(rz) * math.cos(rx), math.cos(rz) * math.cos(rx),
                   math.sin(rx)))
    px_por_unidade = RESOLUCAO / ESCALA_ORTO
    p = Vector(p)
    return (RESOLUCAO / 2.0 + p.dot(direita) * px_por_unidade,
            RESOLUCAO / 2.0 - p.dot(cima) * px_por_unidade)


def para_pixel_tela(p) -> tuple:
    """O mesmo ponto, em pixel do NÓ — que é o que um `.tscn` quer ler."""
    px, py = para_pixel(p)
    return (px / FATOR_RES, py / FATOR_RES)


# ------------------------------------------------------------ kit de detalhe
# A distância entre o que este gerador entregava e a arte de referência não é
# luz nem cor — é DENSIDADE DE PEÇA. Um galpão da referência tem moldura de
# janela, peitoril, calha, fiada de telha, degrau e placa; o daqui tinha uma
# caixa e um buraco de porta. Detalhe acrescentado prop a prop é caro; detalhe
# como PEÇA REUTILIZÁVEL é barato, e fica mais barato a cada prop novo.
#
# SÓ DUAS FACES IMPORTAM. A câmera está em (+X, −Y, +Z) olhando para a origem,
# então de qualquer volume vêem-se a face +X e a face −Y e mais nada. Detalhar
# as outras duas é render que ninguém vê. Todas as funções aqui aceitam
# `face` como "+x" ou "-y" e recusam o resto, para o engano ser barulhento.
#
# COORDENADA DE FACE. Cada peça é descrita em (u, v) na face — `u` corre ao
# longo dela, `v` sobe — e não em (x, y, z) absolutos. Era essa aritmética à
# mão que punha a janela cinco centímetros dentro da parede.

FACES = ("+x", "-y")


def _plano_da_face(face: str, centro, tam):
    if face not in FACES:
        raise ValueError("face %r invisível para esta câmera; use %s" % (face, FACES))
    cx, cy, cz = centro
    sx, sy, sz = tam
    if face == "+x":
        return (cx + sx / 2.0, cy, cz), (0, 1, 0), (0, 0, 1), (1, 0, 0)
    return (cx, cy - sy / 2.0, cz), (1, 0, 0), (0, 0, 1), (0, -1, 0)


def na_face(nome, face, centro, tam, u, v, larg, alt, esp, mat, fora=0.0):
    """Uma placa rente à face, saliente `fora` (negativo = recuada)."""
    org, eu, ev, n = _plano_da_face(face, centro, tam)
    p = tuple(org[i] + eu[i] * u + ev[i] * v + n[i] * (esp / 2.0 + fora)
              for i in range(3))
    t = tuple(abs(eu[i]) * larg + abs(ev[i]) * alt + abs(n[i]) * esp
              for i in range(3))
    return caixa(nome, p, t, mat)


def moldura(nome, face, centro, tam, u, v, larg, alt, esp, mat, fora=0.0,
            barra_larg=0.07):
    """As quatro barras em volta de um vão — e não uma chapa do tamanho dele.

    Foi o erro da primeira versão do kit: moldura desenhada como placa cheia
    fica NA FRENTE do vidro e tapa exatamente o que devia emoldurar. A janela
    saía como um retângulo cinza e a porta desaparecia.
    """
    b = barra_larg
    return [
        na_face("%s_cima" % nome, face, centro, tam, u, v + alt / 2.0 + b / 2.0,
                larg + 2 * b, b, esp, mat, fora),
        na_face("%s_baixo" % nome, face, centro, tam, u, v - alt / 2.0 - b / 2.0,
                larg + 2 * b, b, esp, mat, fora),
        na_face("%s_esq" % nome, face, centro, tam, u - larg / 2.0 - b / 2.0, v,
                b, alt, esp, mat, fora),
        na_face("%s_dir" % nome, face, centro, tam, u + larg / 2.0 + b / 2.0, v,
                b, alt, esp, mat, fora),
    ]


def janela(nome, face, centro, tam, u, v, larg, alt, M, peitoril=True):
    """Vidro recuado, moldura saliente, travessa e peitoril.

    O que faz uma janela ler como janela não é o retângulo azul: é a SOMBRA
    da moldura em volta dele. Por isso a moldura sai da parede e o vidro entra.
    """
    pecas = [na_face(nome + "_vidro", face, centro, tam, u, v,
                     larg, alt, 0.04, M["vidro"], -0.03)]
    pecas += moldura(nome + "_m", face, centro, tam, u, v, larg, alt,
                     0.06, M["parede_dir"], 0.01)
    # Travessa central: duas folhas leem melhor que um vidro só a esta escala.
    pecas.append(na_face(nome + "_travessa", face, centro, tam, u, v,
                         0.05, alt, 0.05, M["parede_dir"], 0.005))
    if peitoril:
        pecas.append(na_face(nome + "_peitoril", face, centro, tam,
                             u, v - alt / 2.0 - 0.11,
                             larg + 0.26, 0.08, 0.13, M["parede_dir"], 0.045))
    return pecas


def vao_cego(nome, face, centro, tam, u, v, larg, alt, M, batente=True):
    """Uma abertura SEM nada atrás: janela partida, porta que já não há.

    É a peça de ruína que faltava, e ela é a `janela()` ao contrário — lá o que
    faz ler é o vidro claro com a moldura a fazer sombra; aqui é o VÃO ESCURO,
    e o batente é o que resta dele: duas barras, e não quatro.

    ⚠️ E ela é uma PLACA RECUADA, não um furo. Furar a parede punha o batente
    coplanar com a face e devolvia o losango preto do z-buffer que este arquivo
    já registou duas vezes — e num prop de 40px o resultado não se lê como
    buraco, lê como falha de render.
    """
    pecas = [na_face(nome + "_vao", face, centro, tam, u, v,
                     larg, alt, 0.05, M["vao"], -0.045)]
    if batente:
        # Só o topo e um lado: o batente inteiro devolveria a janela ARRUMADA,
        # que é exatamente o que a ruína não é.
        pecas.append(na_face(nome + "_verga", face, centro, tam, u,
                             v + alt / 2.0 + 0.035, larg + 0.14, 0.07, 0.06,
                             M["parede_dir"], 0.01))
        pecas.append(na_face(nome + "_umbral", face, centro, tam,
                             u - larg / 2.0 - 0.035, v - 0.06,
                             0.07, alt - 0.12, 0.06, M["parede_dir"], 0.01))
    return pecas


# O perfil de uma parede que caiu: (largura, altura, profundidade), todas
# relativas ao trecho inteiro. Os números são IRREGULARES de propósito e são
# literais e não sorteio — o gerador é determinístico e o CI compara o PNG.
#
# ⚠️ A PRIMEIRA VERSÃO DESCIA EM DEGRAUS IGUAIS e saiu uma ESCADA. Três caixas
# da mesma largura, descendo por um passo constante, é exatamente o desenho de
# um lance de escada — e ampliada a 5x era isso que se via, com a janela
# partida encaixada num dos degraus como se fosse um patamar. É a irmã da
# regra que a vila já registou ("73% dos vãos mediam exatamente o VILA_PASSO, e
# aquilo lia como cerca"): o que denuncia geometria gerada não é a forma, é a
# REGULARIDADE dela.
#
# Aqui a largura varia de 0,22 a 0,40, a altura não é monótona (o segundo
# pedaço é MAIS alto que o primeiro, que é o que uma parede faz quando racha em
# vez de desmoronar por igual) e os dois últimos são mais finos, porque parede
# que caiu partiu-se também na espessura.
_PERFIL_QUEDA = ((0.24, 0.86, 1.00), (0.22, 1.00, 0.96),
                 (0.32, 0.47, 0.78), (0.22, 0.24, 0.62))


def parede_partida(nome, centro, tam, mat, resto=0.42):
    """Um trecho de parede que DESABOU: o topo em pedaços irregulares.

    O topo reto de uma caixa lê como parede por acabar; o que lê como parede
    CAÍDA é a linha de cima quebrada — e quebrada de verdade, ver `_PERFIL_QUEDA`.
    `resto` é a fração da altura a que o último pedaço chega.
    """
    cx, cy, cz = centro
    sx, sy, sz = tam
    base = cz - sz / 2.0
    esq = cx - sx / 2.0
    pecas = []
    n = len(_PERFIL_QUEDA)
    for i, (larg, alto, fundo) in enumerate(_PERFIL_QUEDA):
        f = i / float(n - 1)
        # A envolvente desce de 1 até `resto`; o perfil sacode-a por cima.
        h = sz * (1.0 - (1.0 - resto) * f) * alto
        w = sx * larg
        pecas.append(caixa("%s%d" % (nome, i),
                           (esq + w / 2.0, cy, base + h / 2.0),
                           (w + 0.02, sy * fundo, h), mat))
        esq += w
    return pecas


def tufo(nome, pe, alt, mat, rot_z=0.0):
    """Um tufo de capim: folhas finas que abrem para fora do pé.

    Cone de quatro lados e ponta fina, e não bola: capim a esta escala lê pela
    PONTA, e um volume redondo verde é arbusto. Os ângulos são literais — o
    gerador é determinístico e o CI compara o PNG. A orientação sai do
    `to_track_quat`, como na `barra()`: conta de Euler à mão tomba a folha
    para o lado errado em metade dos azimutes.
    """
    p = Vector(pe)
    pecas = []
    for i, (az, inc, k) in enumerate(((0, 14, 1.0), (100, 30, 0.75),
                                      (215, 24, 0.85), (300, 34, 0.65))):
        a, t = math.radians(az + rot_z), math.radians(inc)
        d = Vector((math.sin(t) * math.cos(a), math.sin(t) * math.sin(a),
                    math.cos(t))) * (alt * k)
        o = cone("%s%d" % (nome, i), tuple(p + d / 2.0), 0.07, 0.006,
                 d.length, 4, mat)
        o.rotation_euler = d.to_track_quat("Z", "Y").to_euler()
        pecas.append(o)
    return pecas


def copa_bolas(nome, lobos, M):
    """A copa de uma árvore que cresce onde ninguém a plantou: bolas achatadas.

    Duas cores alternadas (`folha` e `folha_clara`), pela mesma razão da copa
    do coqueiro: um verde só lê como mancha chapada, e é a troca de valor
    entre lobos que dá o volume. `lobos` é ((x, y, z), (rx, ry, rz)) por bola.
    """
    return [bola("%s%d" % (nome, i), c, r,
                 M["folha"] if i % 2 == 0 else M["folha_clara"])
            for i, (c, r) in enumerate(lobos)]


def porta(nome, face, centro, tam, u, larg, alt, M, base=None):
    """Porta com batente e degrau. `base` é o z do chão da construção."""
    chao = base if base is not None else centro[2] - tam[2] / 2.0
    v = chao + alt / 2.0 - centro[2]      # `v` é medido do centro da parede
    pecas = [na_face(nome + "_vao", face, centro, tam, u, v,
                     larg, alt, 0.06, M["porta"], -0.035)]
    pecas += moldura(nome + "_b", face, centro, tam, u, v, larg, alt,
                     0.07, M["parede_dir"], 0.01, barra_larg=0.09)
    org, eu, _ev, n = _plano_da_face(face, centro, tam)
    pe = tuple(org[i] + eu[i] * u + n[i] * 0.16 for i in range(3))
    pecas.append(caixa(nome + "_degrau",
                       (pe[0], pe[1], centro[2] - tam[2] / 2.0 + 0.05),
                       (larg + 0.3 if face == "-y" else 0.34,
                        0.34 if face == "-y" else larg + 0.3, 0.10),
                       M["parede_dir"]))
    return pecas


def telhado_duas_aguas(nome, centro, tam, altura, mat, mat_cume, fiadas=5,
                       nervuras=0, mat_nerv=None):
    """Telhado de duas águas com fiadas de telha visíveis.

    A laje chapada que havia antes lia como tampa. O que dá a leitura de
    TELHADO é a inclinação e a linha horizontal das fiadas — duas coisas que
    custam meia dúzia de caixas e mudam o prédio inteiro.

    A cumeeira corre em X, e a água desce em Y, porque é assim que as duas
    faces visíveis (+X e −Y) mostram uma água inteira e o beiral da outra.

    ⚠️ `nervuras` TROCA O SENTIDO DO TRAÇO, e é essa troca que separa telha
    de CHAPA METÁLICA. A fiada corre em X, paralela à cumeeira, e na tela sai
    como um feixe de linhas descendo para a direita — é o desenho de um
    telhado de telha, e é o que faz um galpão ler como casa grande. A nervura
    do zinco corre no sentido da ÁGUA (em Y, da cumeeira ao beiral) e sai como
    um feixe subindo para a direita: o mesmo custo de geometria, a leitura
    trocada. Passar `nervuras=N` desliga as fiadas (`fiadas=0`) por conta de
    quem chama — os dois traços ao mesmo tempo dariam uma grelha, que não é
    nem um telhado nem o outro.

    A largura da nervura sai da face dividida pelo número delas, e não de um
    número escolhido a olho: é a mesma conta do corrugado do contêiner, que
    mediu que o que se lê a esta escala são painéis de ~6px de valor
    diferente, e não vincos de 2,5px.
    """
    if mat_nerv is None:
        mat_nerv = mat_cume
    cx, cy, cz = centro
    sx, sy = tam[0], tam[1]          # a espessura da laje não interessa aqui
    beiral = 0.18
    meia = sy / 2.0 + beiral
    ang = math.degrees(math.atan2(altura, meia))
    comp = math.hypot(altura, meia)
    pecas = []
    for lado, sinal in (("a", -1), ("b", 1)):
        agua = caixa("%s_agua_%s" % (nome, lado),
                     (cx, cy + sinal * meia / 2.0, cz + altura / 2.0),
                     (sx + 2 * beiral, comp, 0.10), mat,
                     rot=(-sinal * ang, 0, 0))
        pecas.append(agua)
        # Nervura do zinco: corre com a água, da cumeeira ao beiral.
        for i in range(nervuras):
            u = (i + 0.5) / float(nervuras) - 0.5
            pecas.append(caixa("%s_nerv_%s%d" % (nome, lado, i),
                               (cx + u * (sx + 2 * beiral),
                                cy + sinal * meia / 2.0,
                                cz + altura / 2.0 + 0.02),
                               ((sx + 2 * beiral) / (nervuras * 2.0),
                                comp * 0.96, 0.12),
                               mat_nerv, rot=(-sinal * ang, 0, 0)))
        # Fiadas: ressaltos finos paralelos à cumeeira. Não são telhas — são a
        # sombra entre elas, que é o que o olho lê a esta escala.
        for i in range(1, fiadas):
            f = i / float(fiadas)
            dy = sinal * meia * f
            dz = altura * (1.0 - f)
            pecas.append(caixa("%s_fiada_%s%d" % (nome, lado, i),
                               (cx, cy + dy, cz + dz + 0.02),
                               (sx + 2 * beiral, 0.05, 0.12),
                               mat_cume, rot=(-sinal * ang, 0, 0)))
    pecas.append(caixa(nome + "_cumeeira", (cx, cy, cz + altura + 0.03),
                       (sx + 2 * beiral + 0.05, 0.16, 0.10), mat_cume))
    return pecas


def corrimao(nome, a, b, altura, mat, postes=5, esp=0.035):
    """Guarda-corpo: dois corrimãos e os montantes entre eles.

    É a peça que mais separa um casco de navio de uma cunha de cor. Vazado, de
    propósito: é o fundo aparecendo entre os montantes que dá a escala.
    """
    a, b = Vector(a), Vector(b)
    pecas = [barra(nome + "_alto", a + Vector((0, 0, altura)),
                   b + Vector((0, 0, altura)), esp, mat),
             barra(nome + "_meio", a + Vector((0, 0, altura * 0.55)),
                   b + Vector((0, 0, altura * 0.55)), esp, mat)]
    for i in range(postes):
        t = i / float(max(postes - 1, 1))
        p = a.lerp(b, t)
        pecas.append(barra("%s_poste%d" % (nome, i), p,
                           p + Vector((0, 0, altura)), esp * 1.1, mat))
    return pecas


def corrimao_bordo(nome, pontos, altura, mat, esp=0.030) -> list:
    """Guarda-corpo que acompanha uma linha quebrada em vez de uma reta.

    ⚠️ CURVAR O CASCO SEM CURVAR O CORRIMÃO DEIXA-O ATRAVESSADO NO CONVÉS.
    Enquanto o bordo era uma reta de três unidades, o `corrimao()` reto
    coincidia com ele por acidente; assim que o bordo virou curva, o corrimão
    ficou a cortar o convés em diagonal, com as pontas a morrer no meio da
    chapa vermelha. Nenhuma asserção podia apanhar — é a mesma família do
    "ao corrigir um, VARRA OS IRMÃOS": quem muda a linha muda o que assentava
    nela.

    Um montante por ponto e dois corrimãos por vão; os montantes ficam FORA do
    laço dos vãos para as juntas não levarem dois montantes no mesmo sítio,
    que é a armadilha das duas faces coplanares aplicada a uma peça repetida.
    """
    pecas = []
    for i, (a, b) in enumerate(zip(pontos, pontos[1:])):
        A, B = Vector(a), Vector(b)
        pecas.append(barra("%s_alto%d" % (nome, i), A + Vector((0, 0, altura)),
                           B + Vector((0, 0, altura)), esp, mat))
        pecas.append(barra("%s_meio%d" % (nome, i),
                           A + Vector((0, 0, altura * 0.55)),
                           B + Vector((0, 0, altura * 0.55)), esp, mat))
    for i, ponto in enumerate(pontos):
        P = Vector(ponto)
        pecas.append(barra("%s_poste%d" % (nome, i), P,
                           P + Vector((0, 0, altura)), esp * 1.1, mat))
    return pecas


def escotilhas(nome, face, centro, tam, v, quantas, passo, raio, mat):
    """Fileira de vigias. Uma janela redonda a esta escala é um disco escuro
    com um anel claro — e é o anel que a faz parecer furo, não mancha."""
    pecas = []
    for i in range(quantas):
        u = (i - (quantas - 1) / 2.0) * passo
        pecas.append(na_face("%s_anel%d" % (nome, i), face, centro, tam, u, v,
                             raio * 2.4, raio * 2.4, 0.04, mat, 0.0))
        pecas.append(na_face("%s_vidro%d" % (nome, i), face, centro, tam, u, v,
                             raio * 1.5, raio * 1.5, 0.04, PALETA_MAT["vidro"],
                             -0.012))
    return pecas


def poste_de_luz(nome, base, altura, mat, mat_luz):
    """Poste com braço e luminária. O cenário da referência é pontuado por
    eles — é o que dá escala a uma rua vazia."""
    x, y, z = base
    return [
        caixa(nome + "_pe", (x, y, z + 0.06), (0.26, 0.26, 0.12), mat),
        cone(nome + "_haste", (x, y, z + altura / 2.0), 0.055, 0.038,
             altura, 6, mat),
        barra(nome + "_braco", (x, y, z + altura),
              (x - 0.34, y, z + altura + 0.10), 0.05, mat),
        caixa(nome + "_luminaria", (x - 0.40, y, z + altura + 0.06),
              (0.26, 0.16, 0.07), mat_luz),
    ]


# ── A EMPILHADEIRA E O PALLET, NA RÉGUA DA PESSOA (03/10, `docs/decisoes/079`)
#
# A empilhadeira do pátio media 47 px de caixa, a de um camião inteiro: a
# `069` acertou a régua das pessoas e dos camiões e não chegou a ela. O Bruno
# escolheu-a À RÉGUA DA PESSOA, 1,5x o real, porque é a pessoa que a conduz:
# a 1x o capacete de quem vai sentado sairia pela cobertura. O pallet vai na
# mesma régua, porque é a ele que o garfo entra.
#
# As MEDIDAS SÃO REAIS (uma empilhadeira de 2,5 t, um pallet de 1,2 x 1,0 m),
# passadas pela régua do mundo com o fator da pessoa: o chão por
# `METROS_POR_U`, a altura por `PX_POR_METRO` — a régua de altura, que é a que
# o olho alinha (`069`). É a segunda peça do kit desenhada a partir de metros,
# depois do carro.
#
# UMA FUNÇÃO SÓ PARA AS TRÊS: a do pátio (`brp_porto`), a parada no cais do
# nível 3 e a que trabalha nele. Duas cópias divergiriam no primeiro ajuste.
ESCALA_EMPILHADEIRA = 1.5


def _hm(metros: float) -> float:
    """Metros de chão -> unidades de mundo, à régua da pessoa."""
    return metros * ESCALA_EMPILHADEIRA / METROS_POR_U


def _vm(metros: float) -> float:
    """Metros de altura -> unidades do Blender, à régua da pessoa."""
    return z(metros * ESCALA_EMPILHADEIRA * PX_POR_METRO)


# O pallet (1,2 x 1,0 m) e a altura dele, que levanta a carga de cima. Mais
# alto do que os 0,144 m do real: a 1,2 px de tela ele era um risco.
PALLET_M = (1.2, 1.0, 0.18)
# Onde o garfo entra, contra o centro do pallet: o mastro fica logo atrás da
# ponta de cá dele, e o garfo de 1,07 m corre por baixo quase todo.
FOLGA_MASTRO_M = 0.02


def pallet_pecas(M, nome, cx, cy, z0) -> list:
    """Um pallet de madeira com o centro em (cx, cy) e o fundo em `z0`:
    três tábuas por cima, comprido em `x`, e três blocos por baixo.

    ⚠️ AS TÁBUAS AFUNDAM 0,3 px NOS BLOCOS, e os blocos são mais estreitos
    do que as tábuas: nenhuma face encosta noutra (o losango preto)."""
    pl, pf, ph = PALLET_M
    tabua_z = _vm(ph * 0.40)
    bloco_z = _vm(ph * 0.60) + z(0.3)
    p = []
    for i, dy in enumerate((-0.38, 0.0, 0.38)):
        p.append(caixa("%s_bloco%d" % (nome, i),
                       (cx, cy + _hm(pf * dy), z0 + bloco_z / 2.0),
                       (_hm(pl * 0.96), _hm(0.12), bloco_z), M["madeira_esc"]))
    for i, dy in enumerate((-0.36, 0.0, 0.36)):
        p.append(caixa("%s_tabua%d" % (nome, i),
                       (cx, cy + _hm(pf * dy), z0 + bloco_z - z(0.3) + tabua_z / 2.0),
                       (_hm(pl), _hm(0.26), tabua_z), M["madeira"]))
    return p


def altura_do_pallet() -> float:
    """Do chão ao tampo do pallet, em unidades do Blender."""
    return _vm(PALLET_M[2] * 0.60) + _vm(PALLET_M[2] * 0.40)


def empilhadeira_pecas(M, nome, cx, cy, z0, garfo_m=0.0):
    """A empilhadeira com o CENTRO DO PALLET que ela leva em (cx, cy), o chão
    em `z0` e o garfo para `−x`, levantado `garfo_m` metros.

    Devolve as peças e o assento — (x, y, altura em px de tela acima do chão)
    —, onde quem a conduz se senta.

    ⚠️ O GARFO APONTA PARA `−x`, E A CÂMARA VÊ `+x` E `−y`. Ela leva a carga a
    andar para terra, que no cais é `−x`: vê-se o CONTRAPESO e o flanco, e a
    carga por cima do capô, atrás do mastro. É a vista de uma empilhadeira que
    se afasta, e é por isso que o mastro e a grade do encosto são VAZADOS —
    duas barras e não uma chapa: uma chapa tapava a carga que ela leva.
    """
    xm = cx + _hm(PALLET_M[0] / 2.0 + FOLGA_MASTRO_M)   # a face do mastro
    g = _vm(garfo_m)
    p = []

    def em(dx_m, dy_m, z_m):
        return (xm + _hm(dx_m), cy + _hm(dy_m), z0 + _vm(z_m))

    # O GARFO: duas lanças de 1,07 m, à frente do mastro. Ao chão ficam dentro
    # do pallet, e é por isso que a espessura não precisa de ser real.
    for i, dy in enumerate((-0.30, 0.30)):
        p.append(caixa("%s_garfo%d" % (nome, i),
                       (xm - _hm(0.535), cy + _hm(dy), z0 + g + _vm(0.06)),
                       (_hm(1.07), _hm(0.12), _vm(0.08)), M["metal"]))
        # O talão que sobe do garfo à placa: é ele que diz que o garfo
        # pertence ao mastro, e não é uma tábua solta no chão.
        p.append(caixa("%s_talao%d" % (nome, i),
                       (xm + _hm(0.03), cy + _hm(dy), z0 + g + _vm(0.35)),
                       (_hm(0.06), _hm(0.12), _vm(0.62)), M["metal"]))
    # O ENCOSTO, vazado: duas travessas e as duas pernas do talão.
    for i, zz in enumerate((0.32, 0.95)):
        p.append(caixa("%s_encosto%d" % (nome, i),
                       (xm + _hm(0.05), cy, z0 + g + _vm(zz)),
                       (_hm(0.05), _hm(0.98), _vm(0.06)), M["metal"]))
    # O MASTRO: dois montantes, uma travessa em cima.
    for i, dy in enumerate((-0.40, 0.40)):
        p.append(caixa("%s_mastro%d" % (nome, i), em(0.14, dy, 1.13),
                       (_hm(0.12), _hm(0.10), _vm(2.06)), M["metal_claro"]))
    p.append(caixa("%s_mastro_topo" % nome, em(0.14, 0.0, 2.14),
                   (_hm(0.13), _hm(0.92), _vm(0.08)), M["metal_claro"]))

    # O CORPO, amarelo: chassi baixo, para-lamas, e o contrapeso atrás. O
    # contrapeso é ESCURO — a face `+x` é a que se vê, e um bloco amarelo do
    # mesmo tom do chassi fundia-se nele (a regra das faces vizinhas).
    p += [
        caixa("%s_chassi" % nome, em(1.22, 0.0, 0.62),
              (_hm(2.0), _hm(1.10), _vm(0.74)), M["amarelo"]),
        caixa("%s_contrapeso" % nome, em(2.18, 0.0, 0.74),
              (_hm(0.52), _hm(1.14), _vm(0.98)), M["metal"]),
        caixa("%s_capo" % nome, em(1.40, 0.0, 1.03),
              (_hm(0.62), _hm(1.02), _vm(0.10)), M["amarelo"]),
        # O banco, e o encosto dele, escuros sobre o amarelo.
        caixa("%s_banco" % nome, em(1.36, 0.0, 1.11),
              (_hm(0.42), _hm(0.46), _vm(0.08)), M["pneu"]),
        caixa("%s_banco_costas" % nome, em(1.60, 0.0, 1.34),
              (_hm(0.08), _hm(0.44), _vm(0.42)), M["pneu"]),
        # O painel e o volante à frente do banco.
        caixa("%s_painel" % nome, em(0.62, 0.0, 1.16),
              (_hm(0.24), _hm(0.80), _vm(0.30)), M["amarelo"]),
        barra("%s_coluna" % nome, em(0.62, 0.0, 1.20), em(0.86, 0.0, 1.48),
              _hm(0.06), M["pneu"]),
    ]
    # A COBERTURA: quatro montantes e a grade de cima. Os da frente inclinam
    # para a frente, como nas de verdade; a grade é escura e não amarela, que
    # é a linha que fecha a silhueta por cima.
    for i, (dx0, dx1, dy) in enumerate(((0.42, 0.34, -0.50), (0.42, 0.34, 0.50),
                                        (1.86, 1.86, -0.50), (1.86, 1.86, 0.50))):
        p.append(barra("%s_coluna_cob%d" % (nome, i), em(dx0, dy, 0.98),
                       em(dx1, dy, 2.24), _hm(0.07), M["metal"]))
    p.append(caixa("%s_cobertura" % nome, em(1.10, 0.0, 2.27),
                   (_hm(1.62), _hm(1.10), _vm(0.06)), M["metal"]))
    # O PIRILAMPO laranja atrás, em cima: o sinal de toda máquina de pátio.
    p.append(caixa("%s_pirilampo" % nome, em(1.80, 0.36, 2.37),
                   (_hm(0.12), _hm(0.12), _vm(0.14)), M["laranja"]))
    # AS RODAS, de borracha: a da frente maior, debaixo do mastro.
    for i, (dx, raio, dy) in enumerate(((0.36, 0.33, -0.48), (0.36, 0.33, 0.48),
                                        (1.94, 0.28, -0.48), (1.94, 0.28, 0.48))):
        p.append(cone("%s_roda%d" % (nome, i), em(dx, dy, raio),
                      _vm(raio), _vm(raio), _hm(0.22), 12, M["pneu"],
                      rot=(90, 0, 0)))
    assento = (xm + _hm(1.30), cy, 1.15 * ESCALA_EMPILHADEIRA * PX_POR_METRO)
    return p, assento


# ---------------------------------------------------------------- os props
# Cada função devolve a lista de objetos daquele prop. Props que partilham
# geometria (o píer nos três estados) montam a partir das MESMAS peças: é o que
# faz o píer não pular quando o jogador amplia.
def montar(M: dict) -> dict:
    grupos = {}

    # -- ESTACAS: a base comum dos três estados do píer -------------------
    estacas = []
    for i in range(4):
        x = -PIER_ALCANCE / 2 + 0.5 + i * (PIER_ALCANCE - 1.0) / 3
        for lado, y in enumerate((-PIER_LARG / 2 + 0.28, PIER_LARG / 2 - 0.28)):
            estacas.append(caixa(f"estaca_{i}_{lado}", (x, y, ALT_PIER / 2 - z(13.0)),
                                 (0.22, 0.22, ALT_PIER + z(26.0)), M["madeira_esc"]))

    # Vaga por construir: as mesmas estacas, gastas, sem tabuado.
    estacas_velhas = []
    for i in range(4):
        x = -PIER_ALCANCE / 2 + 0.5 + i * (PIER_ALCANCE - 1.0) / 3
        for lado, y in enumerate((-PIER_LARG / 2 + 0.28, PIER_LARG / 2 - 0.28)):
            # Alturas irregulares — é o que faz "abandonado" ler à primeira vista.
            h = ALT_PIER + z(26.0) - (z(13.0) if (i + lado) % 3 == 0 else 0.0)
            estacas_velhas.append(caixa(
                f"velha_{i}_{lado}", (x, y, h / 2 - z(13.0)), (0.22, 0.22, h),
                M["madeira_velha"], rot=(0, 2 if i % 2 else -3, 0)))
    grupos["pier_vazio"] = estacas_velhas

    # ⚠️ O CONVÉS DO n2 ERA UMA CHAPA LISA, e é a MAIOR superfície do jogo:
    # 4,5 × 2,4, cerca de 138px de silhueta, e ela aparece três vezes na tela.
    # O n1 gasta geometria em nove ripas com fresta — a fresta é o que diz
    # "provisório" —, e o n2, que é a MELHORIA, não tinha desenho nenhum: lia
    # como uma folha de compensado. O píer melhor parecia menos construído que
    # o pior.
    #
    # Aqui a ripa é MATERIAL e não peça, e a escolha é o contrário da do n1 por
    # uma razão de leitura: no n2 as tábuas estão JUSTAS, então o que existe é
    # a junta, não o vão. Vinte caixas para desenhar vinte juntas seria pagar
    # geometria por uma linha de sombra.
    TABUA = 0.30                  # 6px na tela — o passo que o contêiner mediu
    tabuado = [caixa("tabuado", (0, 0, ALT_PIER - z(2.2)),
                     (PIER_ALCANCE, PIER_LARG, z(4.4)),
                     material_ripado("tabuado_ripado", PALETA["madeira"],
                                     TABUA, eixo="Y"))]

    # Carga no convés. Um píer limpo parece cenário; com caixotes à espera de
    # embarque parece que ali se trabalha. Fica na ponta do mar (+mx) e do lado
    # oposto ao barco, que atraca no +my — o meio do tabuado é da chip.
    def _no_conves(nome, mx, my, altura_px, tam, mat, rot=(0, 0, 0)):
        px, py, pz = pos(mx, my, 15.0 + altura_px / 2.0)
        return caixa(nome, (px, py, pz), (tam[0], tam[1], z(altura_px)), mat, rot)

    # -- A CAUDA DA CARGA DO CONVÉS (Etapa 2 do plano de arte) -----------
    #
    # O contêiner tinha DUAS peças — a caixa laranja e uma faixa azul de 1,6px
    # debaixo dela. O caixote tinha UMA.
    #
    # ⚠️ E O PLANO PEDE ~14 PEÇAS PARA O CONTÊINER, NÚMERO QUE NÃO SE APLICA A
    # ESTE. Ele foi escrito para o prop `conteiner` AVULSO, de 2,4 unidades,
    # que saiu do projeto em 31/08 (a razão está no comentário do `grupos` mais
    # abaixo). O que sobrou é a carga do convés, e ela é pequena:
    #
    #     contêiner   46 × 38 px na tela, e a face comprida tem só 31 px
    #     caixote_a   25 × 24 px          caixote_b   23 × 21 px
    #
    # Catorze peças numa face de 31px dão 2,5px cada, que é a LIXA da regra do
    # `DESGASTE` com outra roupa. E o `pilha_caixotes` já mediu o resto: a esta
    # escala "faces vizinhas do mesmo tom fundem-se, e não há chanfro que as
    # separe — o que separa é o MATERIAL". Por isso o que entra aqui é pouca
    # peça com valor diferente, e não muita peça da mesma cor:
    #
    #   · o corrugado são QUATRO chapas de laranja escuro, de 6px cada, e não
    #     doze vincos de 2,5px. Elas são quase RENTES à face de propósito:
    #     painel recuado numa caixa sólida fica DENTRO do volume e não se vê,
    #     e um relevo de 0,9px não sobrevive ao antisserrilhado. Quem desenha
    #     o corrugado aqui é a diferença de valor, não o relevo;
    #   · as cantoneiras são metal escuro nos cantos — a assinatura visual de
    #     um contêiner é o canto escuro, e escuro lê-se a 3px onde uma linha
    #     não se lê;
    #   · a porta é a face +x partida em duas folhas, e a junta vertical é o
    #     vão entre elas — junta desenhada a 1px seria uma linha cinzenta.
    def _face_conves(nome, face, centro, tam, u, v, larg, alt, mat, fora):
        # 0,05 e não 0,03: o chanfro tem 0,020 de largura e numa chapa de 0,03
        # ele consome a espessura inteira — o que sai é um seixo arredondado
        # em vez de uma chapa. Com 0,05 sobra face plana no meio.
        return na_face(nome, face, centro, tam, u, v, larg, alt, 0.05, mat, fora)

    CONT_MX, CONT_MY, CONT_ALT = 1.95, -0.72, 15.0
    CONT_TAM = (1.05, 0.5, z(CONT_ALT))
    CONT_C = pos(CONT_MX, CONT_MY, 15.0 + CONT_ALT / 2.0)

    conteiner = [caixa("cont_corpo", CONT_C, CONT_TAM, M["laranja"])]

    # Corrugado: quatro painéis recuados na face comprida (-y). O passo sai da
    # largura da face dividida por quatro, não de um número escolhido a olho.
    for i in range(4):
        u = (i - 1.5) * 0.245
        conteiner.append(_face_conves(
            "cont_vinco%d" % i, "-y", CONT_C, CONT_TAM, u, 0.0,
            0.175, z(CONT_ALT) * 0.74, M["laranja_esc"], -0.032))

    # Cantoneiras: o canto escuro é o que faz ler "contêiner" e não "caixa".
    for i, (sx, sz) in enumerate(((-1, -1), (-1, 1), (1, -1), (1, 1))):
        conteiner.append(caixa(
            "cont_canto%d" % i,
            (CONT_C[0] + sx * (CONT_TAM[0] / 2 - 0.055),
             CONT_C[1] - CONT_TAM[1] / 2 + 0.055,
             CONT_C[2] + sz * (CONT_TAM[2] / 2 - z(2.2))),
            (0.11, 0.11, z(4.4)), M["metal"]))

    # Porta: a face +x em duas folhas, e a junta vertical é o vão entre elas.
    #
    # AZUL, e é aqui que o azul do contêiner passa a viver. Ele estava numa
    # faixa de 1,6px DEBAIXO da caixa, onde ninguém o via; tentou-se depois
    # como plaquinha de marcação de 5×4px na lateral, e a essa escala não leu
    # como marca — leu como um pixel ciano perdido. A porta tem 15px de largura
    # e é uma FORMA, não um detalhe: dá o contêiner de dois tons que o mapa já
    # tinha, com a leitura que o detalhe não conseguia.
    for i, u in enumerate((-0.115, 0.115)):
        conteiner.append(_face_conves(
            "cont_folha%d" % i, "+x", CONT_C, CONT_TAM, u, 0.0,
            0.195, z(CONT_ALT) * 0.78, M["azul"], -0.030))

    # Longarina do topo: DUAS barras nas arestas visíveis, e não uma chapa
    # sobre o topo inteiro. A primeira versão era uma caixa da largura do
    # contêiner em `metal`, e o resultado está medido: desta câmera vê-se o
    # topo, a face de cima do metal escuro recebe pouca luz, e o contêiner
    # saiu com um buraco PRETO em cima — lia como caçamba aberta. O topo tem
    # de continuar a ser da cor do contêiner.
    for face, larg in (("-y", CONT_TAM[0]), ("+x", CONT_TAM[1])):
        conteiner.append(_face_conves(
            "cont_rail_%s" % face[1], face, CONT_C, CONT_TAM,
            0.0, CONT_TAM[2] / 2 - z(0.9), larg, z(1.8), M["metal"], -0.032))

    # -- CAIXOTE ---------------------------------------------------------
    # A 25px o caixote aguenta TRÊS elementos, não dez ripas.
    #
    # ⚠️ E O PRIMEIRO DELES É A COR DO CORPO, o que não é óbvio. O caixote era
    # `madeira` pousado num tabuado de `madeira`: o corpo dele FUNDIA-SE com o
    # convés, e enquanto era uma caixa lisa isso passava. Ao acrescentar tampo
    # escuro e cinta clara, o que ficou visível foram só as peças novas
    # flutuando sobre o chão — e o caixote saiu da renderização parecendo um
    # BANQUINHO, com tampo e pernas. A captura ampliada mostrou-o; a suíte,
    # não. É a lição do `pilha_caixotes` outra vez ("faces vizinhas do mesmo
    # tom fundem-se") aplicada ao par peça/chão em vez de peça/peça.
    #
    # Por isso os dois caixotes trocam de tom E trocam entre si: um em madeira
    # escura, outro na madeira gasta acinzentada, nenhum na cor do tabuado.
    #
    # Feito com trigonometria em vez do `na_face` porque o caixote_b é TORTO —
    # `na_face` monta alinhado aos eixos, então numa peça rodada ele punha a
    # cinta a atravessar a madeira em diagonal.
    def _caixote(nome, mx, my, alt_px, lado, giro, corpo, cinta, tampo):
        c = pos(mx, my, 15.0 + alt_px / 2.0)
        rot = (0, 0, giro)
        topo_z = c[2] + z(alt_px) / 2
        # Caixote de baixo.
        pecas = [caixa(nome, c, (lado, lado, z(alt_px)), M[corpo], rot)]
        # Cinta: a linha de valor destacado. Fica no TERÇO DE CIMA e não ao
        # meio — ao meio ela partia os 11px de corpo em dois de 4px e o
        # caixote lia como uma pilha de tábuas.
        pecas.append(caixa("%s_cinta" % nome,
                           (c[0], c[1], c[2] + z(alt_px) * 0.22),
                           (lado + 0.010, lado + 0.010, z(1.4)), M[cinta], rot))
        # O SEGUNDO CAIXOTE, e é ele que faz o prop ler.
        #
        # ⚠️ Tentou-se antes fazer um caixote só com detalhe por dentro —
        # montantes, cinta ao meio, tampo. Não funciona: a peça tem 25×24px e
        # só 11px de corpo, e três tons empilhados nesses 11px viram listras.
        # O que funciona a esta escala é o idioma que o `pilha_caixotes` já
        # mediu: SILHUETA MÚLTIPLA com tons diferentes. Duas caixas tortas uma
        # sobre a outra leem-se como caixotes; uma caixa listrada, não.
        menor = lado * 0.72
        pecas.append(caixa("%s_topo" % nome,
                           (c[0] + lado * 0.06, c[1] - lado * 0.05,
                            topo_z + z(alt_px * 0.62) / 2 - z(0.6)),
                           (menor, menor, z(alt_px * 0.62)), M[tampo],
                           (0, 0, giro - 17)))
        return pecas

    tabuado += conteiner
    tabuado += _caixote("caixote_a", 2.00, 0.50, 11.0, 0.42, 0,
                        "madeira_esc", "metal_claro", "madeira")
    tabuado += _caixote("caixote_b", -1.95, 0.68, 9.5, 0.38, 18,
                        "madeira_velha", "metal", "madeira_esc")
    for x in (-PIER_ALCANCE / 2 + 0.7, PIER_ALCANCE / 2 - 0.7):
        tabuado.append(caixa(f"cabeco_{x:.1f}",
                             (x, -PIER_LARG / 2 + 0.3, ALT_PIER + z(4.5)),
                             (0.3, 0.3, z(9.0)), M["metal"]))
    # -- GUINDASTE em peças: o Tween gira a lança sem mexer no mastro -----
    #
    # PARA QUE LADO A LANÇA APONTA. Era o defeito antigo: ela estendia-se ao
    # LONGO do píer, para terra, e o barco atraca de LADO. A conta que resolve
    # está no próprio gerador do mapa, que imprime o centro do píer e a âncora
    # do barco: entre os dois há Δmx = 0 e Δmy = +2,8. Ou seja o barco não fica
    # na ponta, fica encostado no flanco +my — e como `pos()` inverte o Y, isso
    # é o -Y local aqui. A lança tem de varrer para -Y, atravessando o convés.
    GX = PIER_ALCANCE / 2 - 0.95          # perto da ponta, onde o navio encosta
    GY = 0.55                             # recuada do flanco: a lança é que alcança
    TOPO = ALT_PIER + 2.70                # altura do encontro lança/torre
    BARCO_Y = -2.30                       # até onde a lança precisa chegar

    # ⚠️ A TORRE É DE CADA NÍVEL, E ANTES ERA UMA SÓ — o defeito estava à vista
    # e ninguém o via, porque a asserção olhava para o lado errado.
    #
    # Até aqui `g_base` e `g_mastro` entravam nos TRÊS píeres, e só a LANÇA
    # mudava. Só que a lança é o braço fino lá em cima e a torre é a coluna que
    # ocupa a silhueta inteira: posto o porto inicial ao lado do completo, o
    # jogador via o mesmo guindaste duas vezes. Foi essa a queixa — *"parecem
    # ser o mesmo, sendo que o porto inicial possui o mesmo guindaste do porto
    # mais avançado"* —, e ela estava certa.
    #
    # O que de facto está preso é UM PONTO: `TOPO`, `GX` e `GY`, porque o
    # `pivot_offset` do nó `Lanca` em `Dock.tscn` é um só para as três lanças e
    # nomeia o topo da torre. Tudo o que fica ABAIXO desse ponto é livre — e o
    # comentário antigo dizia "a torre é a mesma nos três" como se a amarra
    # fosse a torre inteira, quando é só onde ela acaba.
    #
    #   n1  pau de carga: mastro de MADEIRA com dois estais, e um pau só
    #       preso por gooseneck com amantilho ao topo. Sem treliça, sem
    #       cabine — quem opera puxa o cabo à mão;
    #   n2  a treliça laranja de sempre, com a cabine encostada;
    #   n3  pórtico: treliça mais larga, casa de máquinas no convés, cabine
    #       maior e escada. É a mesma altura, e lê-se como o dobro.
    def _sapata(nome, lado, alt, mat):
        return caixa(nome, (GX, GY, ALT_PIER + alt / 2.0), (lado, lado, alt), mat)

    # -- n1: o pau de carga ----------------------------------------------
    # Madeira, e é a única grua do jogo que não é laranja. O laranja é a cor do
    # MAQUINÁRIO do porto; um pontão provisório não tem maquinário, tem um pau
    # amarrado. Tirar a cor é o que faz a diferença ler de longe.
    #
    # ⚠️ O MASTRO PASSA DO GOOSENECK, e é isso que torna o resto possível. Até
    # 08/09 ele acabava em `TOPO + 0,05` — rente ao ponto onde a lança se
    # prende — e daí não havia de onde pendurar um amantilho: qualquer linha
    # saída dali nasceria paralela ao pau e não desenharia triângulo nenhum. A
    # peça que faltava para o n1 ler como pau de carga estava ABAIXO da lança,
    # não dentro dela.
    ALTO_N1 = TOPO + 0.80
    mastro_n1 = [
        _sapata("m1_sapata", 0.34, 0.14, M["metal"]),
        # DUAS SEÇÕES, e a de cima mais fina. A 4 px de largura um mastro não
        # tem textura que se veja; o que se vê é a silhueta a estreitar, e é
        # ela que separa "mastro" de "ripa espetada" — que era a razão de as
        # cintas existirem quando o poste era uma caixa só.
        caixa("m1_poste", (GX, GY, ALT_PIER + 0.95), (0.15, 0.15, 1.66),
              M["madeira_esc"]),
        caixa("m1_mastareu", (GX, GY, (ALT_PIER + 1.70 + ALTO_N1) / 2.0),
              (0.105, 0.105, ALTO_N1 - ALT_PIER - 1.70), M["madeira_esc"]),
        # O cabeço remata o topo. Sem ele o mastaréu lê como pau serrado.
        caixa("m1_cabeco", (GX, GY, ALTO_N1 + 0.04), (0.16, 0.16, 0.09),
              M["metal"]),
    ]
    # Duas cintas de metal, cada uma na secção que abraça — a de cima cai em
    # cima da junta das duas, que é onde uma amarração de verdade iria.
    for h, lado in ((0.80, 0.19), (1.74, 0.145)):
        mastro_n1.append(caixa("m1_cinta%.2f" % h, (GX, GY, ALT_PIER + h),
                               (lado, lado, 0.07), M["metal"]))
    # Os estais. São eles que dizem "isto está amarrado, não construído".
    #
    # ⚠️ E ELES POUSAM NO CONVÉS, o que não é óbvio de conferir. A primeira
    # versão amarrava a ±0,95 de `GY`, e o de trás caía em `y = 1,50` — meia
    # unidade PARA ALÉM da beira, que está em 1,20. No render ele acabava no
    # ar, e nada reprovava: um cabo que não chega a lado nenhum passa em todas
    # as asserções que este projeto tem. Com ±0,62 os dois pousam, e levam
    # olhal para pousarem em ALGUMA COISA.
    #
    # ⚠️ E OS OLHAIS ENCOLHERAM, por causa do GANCHO. Eles mediam 0,11 no
    # mesmo `metal` do gancho que pende do pau — quatro blocos cinzentos do
    # mesmo tamanho no mesmo prop, e o olho não tinha como saber qual deles
    # levanta carga. Quem trabalha ficou claro e maior; quem só amarra ficou
    # pequeno. É a regra do acento aplicada a ferragem em vez de a cor.
    for sy in (-0.62, 0.62):
        mastro_n1.append(barra("m1_estai%.2f" % sy, (GX, GY, TOPO + 0.30),
                               (GX, GY + sy, ALT_PIER + 0.08), 0.026, M["metal"]))
        mastro_n1.append(caixa("m1_olhal%.2f" % sy, (GX, GY + sy, ALT_PIER + 0.05),
                               (0.075, 0.075, 0.10), M["metal"]))

    # O GUINCHO (`076`): o pau-de-carga passou a DESCARREGAR, e quem o manobra
    # é o trabalhador, ao pé do mastro. Fica do lado do barco e um pouco para
    # terra, para o operador ficar entre ele e o mastro, de frente para a
    # lingada. Corpo AZUL, e por medição: o `metal` sobre o tabuado do n1 é
    # castanho-escuro sobre castanho-escuro; o azul separa-se pelo MATIZ, que
    # é o que a telha já ensinou. O tambor é claro, com o cabo enrolado.
    GUINCHO_N1 = (GX - 0.30, GY - 0.30)
    gx, gy = GUINCHO_N1
    mastro_n1 += [
        caixa("m1_guincho_base", (gx, gy, ALT_PIER + 0.05), (0.26, 0.17, 0.10),
              M["azul"]),
        caixa("m1_guincho_lado_a", (gx - 0.11, gy, ALT_PIER + 0.15),
              (0.035, 0.15, 0.17), M["azul"]),
        caixa("m1_guincho_lado_b", (gx + 0.11, gy, ALT_PIER + 0.15),
              (0.035, 0.15, 0.17), M["azul"]),
        cone("m1_guincho_tambor", (gx, gy, ALT_PIER + 0.17), 0.06, 0.06, 0.19,
             12, M["metal_claro"], rot=(0, 90, 0)),
        # A alavanca, do lado do operador, e o cabo do tambor ao pé do mastro.
        barra("m1_guincho_alavanca", (gx + 0.13, gy + 0.06, ALT_PIER + 0.16),
              (gx + 0.15, gy + 0.16, ALT_PIER + 0.36), 0.025, M["metal"]),
        barra("m1_guincho_cabo", (gx + 0.02, gy + 0.05, ALT_PIER + 0.22),
              (GX - 0.06, GY - 0.04, ALT_PIER + 0.45), 0.016, M["metal"]),
    ]
    # O operador, em coordenada do MAPA no quadro do píer (o `y` do Blender é
    # `−my`), e daí no quadro do trabalhador.
    _dmx, _dmy = desloc_trabalhador()
    OPERADOR_N1 = (gx - _dmx, -(gy + 0.26) - _dmy)

    # -- n2: a treliça de sempre -----------------------------------------
    base_n2 = [
        _sapata("m2_sapata", 0.66, 0.20, M["metal"]),
        caixa("m2_chapa", (GX, GY, ALT_PIER + 0.24), (0.52, 0.52, 0.08), M["laranja"]),
    ]
    for sx in (-0.21, 0.21):
        for sy in (-0.21, 0.21):
            base_n2.append(caixa("m2_parafuso_%.2f_%.2f" % (sx, sy),
                                 (GX + sx, GY + sy, ALT_PIER + 0.30),
                                 (0.08, 0.08, 0.08), M["metal"]))
    mastro_n2 = base_n2 + trelica(
        "m2_torre", (GX, GY, ALT_PIER + 0.28), (GX, GY, TOPO + 0.05),
        0.19, M["laranja"], montantes=6, esp=0.052)
    # ⚠️ A CABINE JÁ NÃO MORA AQUI (`077`). Num guindaste de torre ela gira
    # com a lança, e desde o degrau 2 a lança do n2 gira 62° a descarregar:
    # uma cabine assada no mastro ficava a olhar para o barco com a lança
    # virada para terra. Ela vive no `guindaste_n2()`, e no arco que a lança
    # varre fica sempre do lado da câmara, à frente da torre.

    # -- n3: o pórtico ---------------------------------------------------
    # ⚠️ ELE NÃO PODE CRESCER PARA CIMA, então cresce para os LADOS e para
    # BAIXO. A treliça vai de 0,19 a 0,27 de meia-largura (+42%), ganha uma
    # casa de máquinas no convés e uma cabine que desce até meia altura — o
    # olho lê "maior" pela ÁREA da coluna, não pela altura, e a altura é o
    # único número que este prop não pode mexer.
    mastro_n3 = [
        _sapata("m3_sapata", 0.86, 0.24, M["metal"]),
        caixa("m3_chapa", (GX, GY, ALT_PIER + 0.28), (0.70, 0.70, 0.08), M["laranja"]),
    ]
    mastro_n3 += trelica("m3_torre", (GX, GY, ALT_PIER + 0.32),
                         (GX, GY, TOPO + 0.05), 0.27, M["laranja"],
                         montantes=8, esp=0.058)
    mastro_n3 += [
        # ⚠️ CASA DE MÁQUINAS À FRENTE DA TORRE, E NÃO ATRÁS DELA. Ela nasceu
        # em `+y`, que parecia o lado certo — é o lado de terra, e a lança
        # varre para `-y`. Só que `+y` é `-my`, ou seja SOBE no ecrã: no render
        # ela ficou por trás do contêiner empilhado, que está mais à frente em
        # `x`. Peça de 0,54 pintada e tapada é a regra da boia outra vez.
        # Em `-y` ela fica entre a torre e a água, que é onde a máquina de um
        # guindaste de cais de facto vive, e a lança passa 2,7 acima dela.
        caixa("m3_casa", (GX, GY - 0.72, ALT_PIER + 0.34),
              (0.54, 0.46, 0.48), M["laranja"]),
        caixa("m3_casa_teto", (GX, GY - 0.72, ALT_PIER + 0.60),
              (0.60, 0.52, 0.06), M["metal_claro"]),
        caixa("m3_casa_porta", (GX + 0.29, GY - 0.72, ALT_PIER + 0.28),
              (0.04, 0.22, 0.34), M["metal"]),
        # Cabine maior e mais baixa: um pórtico tem posto de operação a meia
        # altura, e descê-la separa a silhueta da do n2 mesmo de longe.
        caixa("m3_cabine", (GX + 0.38, GY - 0.04, TOPO - 1.05),
              (0.34, 0.40, 0.44), M["laranja"]),
        caixa("m3_cabine_vidro", (GX + 0.46, GY - 0.04, TOPO - 0.98),
              (0.24, 0.34, 0.30), M["vidro"]),
    ]
    # Escada lateral, do convés até a cabine. Duas barras e nada mais: a esta
    # escala os degraus viram serrilha.
    for sy in (-0.06, 0.06):
        mastro_n3.append(barra("m3_escada%.2f" % sy,
                               (GX - 0.30, GY + sy, ALT_PIER + 0.30),
                               (GX - 0.30, GY + sy, TOPO - 1.15), 0.022,
                               M["metal_claro"]))

    # A lança do n2 — treliça, contralança, contrapeso, carro e moitão — é
    # o `guindaste_n2()`, mais abaixo: desde o degrau 2 ela gira a
    # descarregar, e cada quadro é ela renderizada no seu ângulo (`077`).
    # ── OS TRÊS NÍVEIS DO PÍER E DA LANÇA ───────────────────────────
    #
    # O GDD 7 já decidiu isto: *"estruturas principais (grua, cais, armazém)
    # têm upgrade in-place de até 3 níveis"*. A MECÂNICA desse upgrade é da
    # Fase 2 e não existe; a ARTE existe desde já, exatamente como a vila, que
    # tem `--nivel-vila=N` no gerador do mapa e cresce a cada Fase "sem o jogo
    # precisar saber disso". Quem escolhe o nível é `GameState.nivel_porto()`,
    # que só LÊ o que já está construído — não decide nada e não acrescenta
    # número nenhum ao balanceamento.
    #
    # ⚠️ A TORRE É A MESMA NOS TRÊS, e isso não é economia de render: é o
    # `pivot_offset` do nó `Lanca` em `Dock.tscn`, que é UM para as três lanças.
    # Torre mais alta no nível 3 desencaixaria a lança do topo dela ao girar, e
    # o defeito só apareceria a meio de uma varrida. `GX`, `GY` e `TOPO` ficam
    # onde estão; o que muda é o CONVÉS por baixo e o BRAÇO por cima.
    #
    # O que separa os três é o material e o equipamento, não o tamanho:
    #
    #   n1  estacas e tabuado de madeira crua, com frestas. Dois cabeços e mais
    #       nada — um pontão a que se amarra um barco;
    #   n2  o de sempre: tabuado inteiro, contêiner e caixotes à espera;
    #   n3  laje de concreto sobre estacas de aço, meio-fio, defensas de pneu na
    #       borda do mar e contêiner empilhado. É porto, e não pontão.

    # -- n1: o pontão de tábuas -------------------------------------------
    # Tabuado de RIPAS com fresta, e não uma laje: a fresta é o que diz
    # "provisório". Uma laje pintada de madeira velha leria como o n2 sujo, que
    # é o erro que o galpão em ruína cometeu ao partilhar as paredes do acabado.
    RIPAS = 9
    passo = PIER_LARG / RIPAS
    deck_n1 = []
    for i in range(RIPAS):
        y = -PIER_LARG / 2 + passo * (i + 0.5)
        deck_n1.append(caixa("ripa%d" % i, (0, y, ALT_PIER - z(2.2)),
                             (PIER_ALCANCE, passo - 0.045, z(4.4)),
                             M["madeira"] if i % 2 else M["madeira_esc"]))
    for i, (mx, my) in enumerate(((-1.6, 0.72), (1.5, 0.72))):
        px, py, pz = pos(mx, my, 15.0)
        deck_n1 += [
            caixa("n1_cabeco%d" % i, (px, py, pz + z(9.0) / 2), (0.16, 0.16, z(9.0)),
                  M["metal"]),
            caixa("n1_cabeco%d_topo" % i, (px, py, pz + z(10.5)),
                  (0.22, 0.22, z(3.0)), M["metal_claro"]),
        ]

    # -- n3: o cais de concreto -------------------------------------------
    estacas_aco = []
    for i in range(4):
        x = -PIER_ALCANCE / 2 + 0.5 + i * (PIER_ALCANCE - 1.0) / 3
        for lado, y in enumerate((-PIER_LARG / 2 + 0.28, PIER_LARG / 2 - 0.28)):
            estacas_aco.append(caixa(f"aco_{i}_{lado}", (x, y, ALT_PIER / 2 - z(13.0)),
                                     (0.20, 0.20, ALT_PIER + z(26.0)), M["metal"]))
    deck_n3 = [
        # A LAJE TINHA O MESMO DEFEITO DO CONVÉS DO n2 — 4,5 × 2,4 de cinzento
        # chapado —, e leva a mesma família de padrão com os números do
        # MATERIAL e não os da madeira: painel de 0,90 (18px) em vez de tábua
        # de 0,30, junta fina, e quase nenhuma variação de tom entre painéis.
        # Concreto lançado em fôrma varia pouco; tábua serrada varia muito, e é
        # essa diferença que impede os dois píeres de se parecerem.
        #
        # E as juntas correm ATRAVESSADAS (eixo `X`), não ao comprido: junta de
        # dilatação de um cais é transversal, e assim as duas lajes não repetem
        # a direção do tabuado que o nível anterior já usou.
        caixa("laje", (0, 0, ALT_PIER - z(2.4)),
              (PIER_ALCANCE, PIER_LARG, z(4.8)),
              material_ripado("laje_junta", PALETA["concreto"], 0.90,
                              eixo="X", contraste=0.955, junta=0.10,
                              escuro_junta=0.74)),
        # Meio-fio na borda do mar. Sem ele a laje acaba numa aresta e lê como
        # tampo; com ele lê como cais — a mesma peça que a rua do mapa usa.
        caixa("laje_meiofio", (0, -PIER_LARG / 2 + 0.05, ALT_PIER + z(1.4)),
              (PIER_ALCANCE, 0.10, z(3.4)), M["concreto_borda"]),
    ]
    # Defensas de pneu, penduradas na borda. São a assinatura de um cais que
    # recebe navio, e escuras sobre concreto claro leem-se a 3px.
    for i in range(5):
        x = -PIER_ALCANCE / 2 + 0.55 + i * (PIER_ALCANCE - 1.1) / 4
        deck_n3.append(cone("defensa%d" % i, (x, -PIER_LARG / 2 - 0.02, ALT_PIER - z(6.0)),
                            0.13, 0.13, 0.09, 8, M["pneu"], rot=(90, 0, 0)))
    for i, (mx, my) in enumerate(((-1.7, 0.74), (-0.5, 0.74), (0.7, 0.74), (1.7, 0.74))):
        px, py, pz = pos(mx, my, 15.0)
        deck_n3 += [
            caixa("n3_cabeco%d" % i, (px, py, pz + z(9.0) / 2), (0.17, 0.17, z(9.0)),
                  M["metal"]),
            caixa("n3_cabeco%d_topo" % i, (px, py, pz + z(10.5)),
                  (0.24, 0.24, z(3.0)), M["amarelo"]),
        ]
    # Contêiner EMPILHADO: é o que um cais forte tem e um pontão não.
    #
    # ⚠️ E EMPILHAR NÃO É PASSAR UMA ALTURA MAIOR. A primeira tentativa deu ao
    # de cima `altura_px` maior, e o `_no_conves` interpreta isso como uma CAIXA
    # MAIS ALTA assente no convés — o segundo contêiner engoliu o primeiro e o
    # que saiu no render foi um cubo azul do tamanho da cabine do guindaste.
    # Duas caixas iguais, uma com o centro um andar acima.
    CONT_H = 13.0
    for j, (dmx, dmy, cor) in enumerate(
            ((0.0, 0.0, "laranja"), (0.10, 0.05, "azul"))):
        px, py, pz = pos(CONT_MX + dmx, CONT_MY + dmy,
                         15.0 + CONT_H / 2.0 + j * CONT_H)
        deck_n3.append(caixa("n3_cont%d" % j, (px, py, pz),
                             (1.00, 0.46, z(CONT_H)), M[cor]))
        # A cantoneira escura no canto: é a assinatura que faz ler "contêiner"
        # e não "caixa", e a esta escala é a única peça que cabe.
        for sx in (-1, 1):
            deck_n3.append(caixa("n3_cont%d_canto%d" % (j, sx),
                                 (px + sx * 0.46, py - 0.20, pz),
                                 (0.08, 0.07, z(CONT_H) * 0.96), M["metal"]))

    # -- as três lanças ---------------------------------------------------
    # ⚠️ TODAS COMEÇAM EM `TOPO`, no eixo da torre. É esse ponto que o
    # `pivot_offset` do `Dock.tscn` nomeia, e uma lança que não o cubra
    # desprende-se da torre ao girar. O bloco D17 do teste de design tranca isto
    # de duas maneiras — a moldura tem de conter o pivô E tem de haver DESENHO
    # à volta dele. A segunda entrou em 08/09: a moldura sozinha é quase de
    # graça de satisfazer, porque um cabo fino a estica para o outro lado do
    # prop.
    # ⚠️ O n1 ERA UMA TRELIÇA, E TRELIÇA É A ASSINATURA DO n2 E DO n3. O
    # comentário do mastro prometia "sem treliça" desde 06/09 e o MASTRO
    # cumpria; a lança não, e ninguém foi lá conferir. Posto o porto em ruínas
    # ao lado do completo, o que se via era a mesma máquina três vezes, mais
    # castanha e mais pequena — que é exatamente a queixa que a torre já tinha
    # levado um andar abaixo, e a regra que este projeto já paga noutro sítio:
    # a ruína não é o prédio pintado de velho, é MENOS prédio.
    #
    # E no jogo era pior do que na bancada. A doca 1 é a que fica encostada à
    # PRAIA, e é a única que o porto em ruínas tem: o vazado da treliça deixava
    # passar a areia clara por trás, e as quatro travessas liam-se como os
    # degraus de uma passadiça de madeira descendo para o areal. Vê-se na
    # captura `pesca`, que existe desde 08/09 exatamente para mostrar este
    # estado — foi ela que denunciou isto.
    #
    # O que substitui é a gramática do aparelho de verdade: UM PAU só, preso
    # ao mastro por um gooseneck, e um AMANTILHO do topo do mastro à ponta do
    # pau. O triângulo mastro/pau/amantilho é o que diz "pau de carga" — não a
    # quantidade de peça, que aqui até desceu de 25 para 8.
    #
    # ⚠️ E O ÂNGULO DO PAU FOI ESCOLHIDO NA IMAGEM, nunca no mundo, que é a
    # regra que o pau-de-carga do arrasteiro já pagou. A câmera come 0,82 de
    # subida no mundo só para o pau sair HORIZONTAL na tela: a treliça de
    # antes era perfeitamente horizontal no Blender e caía 26,6° no ecrã, com
    # ar de coisa a ceder. Com `SOBE_N1` o pau cai 13,7°, que continua a
    # apontar para o barco — ele atraca em `-y`, abaixo e à esquerda — sem ler
    # como rampa. Medido no PNG, não estimado.
    # ⚠️ O PAU FICOU MAIS COMPRIDO EM 02/10, e por causa da carga (`076`). Até
    # ali ele parava a 2,10 do mastro e o gancho pendia na ÁGUA, entre o
    # tabuado e o costado — servia de silhueta. Desde que o pau-de-carga
    # DESCARREGA (escolha do Bruno: «é ele que sempre fará isso»), o gancho
    # tem de descer ao porão do pesqueiro. `SOBE_N1` cresce na mesma razão,
    # para o pau cair os mesmos 13,7° na tela que foram medidos no PNG.
    #
    # ⚠️ O PORÃO NÃO ESTÁ EM FRENTE AO MASTRO. A primeira conta apontou o pau
    # a 0° (direto ao costado) com 3,15 de alcance, e o gancho desceu na PROA:
    # ao lado do bote, na ponta da traineira. Medido nos três cascos, o porão
    # está ~1,0 para terra disso, em (0,3; 2,6) do píer — daí 3,30 de alcance
    # e 18° de giro no barco.
    R_N1 = 3.30
    SOBE_N1 = 0.42 * R_N1 / 2.10
    # O GIRO: 0° seria o pau a apontar para o costado (o `-y` do Blender), e
    # cresce para TERRA (`-x`). Vai de 18° (o porão) a 80° (a pilha, por cima
    # do tabuado e antes da ponta de terra — a 90° a pilha passava da beira).
    # Sete ângulos, ~10° por passo: o pau lê-se a girar e não a saltar.
    GIRO_N1 = (18.0, 28.0, 39.0, 49.0, 59.0, 70.0, 80.0)
    # As alturas do fundo do gancho: a de viagem é a de sempre; a do barco põe
    # a carga no convés do pesqueiro, e a da pilha pousa-a em cima dela.
    GANCHO_CIMA = TOPO - 0.82
    GANCHO_BARCO = ALT_PIER + 0.20
    # A carga ao gancho é a mesma caixa de peixe da pilha (`075`): duas
    # colunas de duas, numa lingada. À régua das cargas (1,5x o real, como a
    # pessoa), cada caixa mede 0,17 x 0,115 x 0,07.
    CAIXA_PEIXE = (0.17, 0.115, 0.07)
    LINGADA = 0.12                 # do bico do gancho ao tampo das caixas
    # O ponto de largada, no último ângulo do giro.
    PILHA_N1 = (GX - R_N1 * math.sin(math.radians(GIRO_N1[-1])),
                GY - R_N1 * math.cos(math.radians(GIRO_N1[-1])))
    PILHA_ANDARES = 3
    GANCHO_PILHA = ALT_PIER + PILHA_ANDARES * (CAIXA_PEIXE[2] - 0.004) \
        + 2 * CAIXA_PEIXE[2] + LINGADA + 0.01

    def _caixas_de_peixe(nome, cx, cy, z0, colunas, andares):
        """Caixas de peixe azuis com gelo por cima, encostadas sem coplanar:
        cada andar afunda 4 mm no de baixo, e o gelo é mais estreito do que a
        caixa."""
        cl, cf, ch = CAIXA_PEIXE
        p = []
        for i, (dx, dy) in enumerate(colunas):
            for a in range(andares):
                z = z0 + a * (ch - 0.004) + ch / 2.0
                p.append(caixa("%s_%d_%d" % (nome, i, a), (cx + dx, cy + dy, z),
                               (cl, cf, ch), M["caixa_peixe"]))
            p.append(caixa("%s_%d_gelo" % (nome, i),
                           (cx + dx, cy + dy, z0 + andares * (ch - 0.004) + 0.006),
                           (cl * 0.80, cf * 0.78, 0.02), M["cabine"]))
        return p

    def pau_de_carga(sufixo, giro, gancho, carga):
        """O pau-de-carga do n1 girado `giro` graus para terra, com o fundo do
        gancho à altura `gancho` e, se `carga`, a lingada de peixe pendurada.

        ⚠️ O GOOSENECK FICA SEMPRE EM `TOPO`, no eixo do mastro: é o pivô que o
        `pivot_offset` do nó nomeia, e os níveis 2 e 3 ainda giram a imagem por
        ele. Os quadros deste não giram imagem nenhuma — cada um é o pau
        renderizado no seu ângulo, porque a 90° a imagem girada no plano da
        tela já não é um pau visto em isométrico (encurta e entorta).
        """
        a = math.radians(giro)
        dx, dy = -math.sin(a), -math.cos(a)        # para onde o pau aponta
        ponta = (GX + dx * R_N1, GY + dy * R_N1, TOPO + SOBE_N1)
        meio = (GX + dx * R_N1 / 2.0, GY + dy * R_N1 / 2.0,
                TOPO + SOBE_N1 / 2.0)
        p = [
            caixa("l1_gooseneck" + sufixo, (GX, GY, TOPO), (0.13, 0.13, 0.16),
                  M["metal"]),
            # DUAS SECÇÕES, a de fora mais fina: um pau afila, e numa peça só
            # ele lia como tábua. `madeira_esc` medido no jogo, contra a areia.
            barra("l1_pau" + sufixo, (GX + dx * 0.05, GY + dy * 0.05, TOPO - 0.02),
                  (meio[0], meio[1], meio[2] + 0.01), 0.095, M["madeira_esc"]),
            barra("l1_pau_ponta" + sufixo,
                  (meio[0] - dx * 0.10, meio[1] - dy * 0.10, meio[2] - 0.01),
                  ponta, 0.065, M["madeira_esc"]),
            # O AMANTILHO, do topo do mastro à ponta: `metal` e não `corda`,
            # medido sobre a areia da doca 1.
            barra("l1_amantilho" + sufixo, (GX, GY, ALTO_N1 - 0.02),
                  (ponta[0], ponta[1], ponta[2] + 0.02), 0.028, M["metal"]),
        ]
        # O cabo desce da ponta ao moitão, e o moitão fica logo acima do
        # gancho a qualquer altura: é o cabo que estica, não o aparelho.
        topo_cabo = ponta[2]
        fundo_cabo = gancho + 0.25
        p.append(caixa("l1_cabo" + sufixo,
                       (ponta[0], ponta[1], (topo_cabo + fundo_cabo) / 2.0),
                       (0.030, 0.030, topo_cabo - fundo_cabo), M["metal"]))
        p += [
            caixa("l1_moitao" + sufixo, (ponta[0], ponta[1], gancho + 0.24),
                  (0.11, 0.10, 0.15), M["metal"]),
            caixa("l1_gancho" + sufixo, (ponta[0], ponta[1], gancho + 0.11),
                  (0.06, 0.06, 0.22), M["metal"]),
            caixa("l1_gancho_bico" + sufixo, (ponta[0], ponta[1] - 0.065,
                                              gancho + 0.03),
                  (0.055, 0.13, 0.06), M["metal"]),
        ]
        if carga:
            # A LINGADA: duas cintas do bico às pontas do bloco de caixas, que
            # pende por baixo dele. As cintas são escuras — a 13 px de pessoa
            # é a linha escura que diz «pendurado», não o tom.
            topo = gancho - LINGADA
            meia = CAIXA_PEIXE[0] / 2.0
            for lado in (-1.0, 1.0):
                p.append(barra("l1_cinta%+d%s" % (lado, sufixo),
                               (ponta[0], ponta[1], gancho + 0.01),
                               (ponta[0] + lado * meia, ponta[1], topo + 0.01),
                               0.018, M["madeira_esc"]))
            p += _caixas_de_peixe("l1_carga" + sufixo, ponta[0], ponta[1],
                                  topo - 2 * CAIXA_PEIXE[2],
                                  ((-meia, 0.0), (meia, 0.0)), 2)
        return p

    # O DE REPOUSO é o de sempre: a apontar para o barco, gancho em cima,
    # vazio. É ele que o `Dock.gd` varre sem trabalhador, como até aqui.
    lanca_n1 = pau_de_carga("", GIRO_N1[0], GANCHO_CIMA, False)
    for i, giro in enumerate(GIRO_N1):
        if i > 0:
            grupos["lanca_n1_g%d" % i] = pau_de_carga("_g%d" % i, giro,
                                                      GANCHO_CIMA, False)
        grupos["lanca_n1_g%dc" % i] = pau_de_carga("_g%dc" % i, giro,
                                                   GANCHO_CIMA, True)
    grupos["lanca_n1_barco"] = pau_de_carga("_bv", GIRO_N1[0], GANCHO_BARCO,
                                            False)
    grupos["lanca_n1_barco_c"] = pau_de_carga("_bc", GIRO_N1[0], GANCHO_BARCO,
                                              True)
    grupos["lanca_n1_pilha"] = pau_de_carga("_pv", GIRO_N1[-1], GANCHO_PILHA,
                                            False)
    grupos["lanca_n1_pilha_c"] = pau_de_carga("_pc", GIRO_N1[-1], GANCHO_PILHA,
                                              True)

    # A PILHA de peixe, no ponto de largada e no quadro do PÍER — o mesmo do
    # pau. Três colunas desencontradas de três andares: é a altura que a faz
    # ler como pilha (`075`), e o gancho pousa a carga em cima da do meio. As
    # colunas correm na LARGURA do píer (`y`): no comprimento, a da ponta
    # passava da beira de terra.
    grupos["pilha_peixe"] = _caixas_de_peixe(
        "pl_peixe", PILHA_N1[0], PILHA_N1[1], ALT_PIER - 0.004,
        ((0.02, -0.135), (0.0, 0.0), (-0.03, 0.135)), PILHA_ANDARES)

    # O PÓRTICO DO n3 — treliça, contralança, carro e spreader — é o
    # `portico_n3()`, mais abaixo: desde o degrau 3 ele gira a descarregar
    # com o carro a recolher, e cada quadro é ele renderizado no seu passo
    # (`079`). O de repouso é o primeiro desses passos.

    # Base e mastro entram no PRÓPRIO píer: um guindaste é o que faz uma
    # estrutura de madeira ler como porto e não como pontão de pesca. A lança
    # fica solta porque é ela que gira — e o que se move não pode estar assado.
    grupos["pier_n1"] = estacas + deck_n1 + mastro_n1
    grupos["pier_n2"] = estacas + tabuado + mastro_n2
    grupos["pier_n3"] = estacas_aco + deck_n3 + mastro_n3
    grupos["lanca_n1"] = lanca_n1
    # O `lanca_n2` e o `lanca_n3` saem com os quadros deles, depois dos
    # cascos (`077`, `079`).
    # NÃO existe um "pier_ampliado" assado. Existiu, e foi retirado em 31/08:
    # era o píer com a lança já colada, e o jogo monta essa imagem em tempo de
    # execução com as duas peças acima, justamente para poder girar a lança.
    # Um render estático da montagem só serve para alguém o usar por engano e
    # perder a varrida.

    # -- BARCOS ----------------------------------------------------------
    # O pesqueiro tinha o mesmo casco dos cargueiros e uma caixa bege no lugar
    # da carga: os três liam-se como o mesmo barco com adereços trocados. Agora
    # ele tem casco PRÓPRIO, mais curto e mais estreito, e o que carrega é
    # pau-de-carga e rede — silhueta diferente, não pintura diferente.
    #
    # ⚠️ E O CASCO ERA A PEÇA MAIS QUADRADA DO KIT INTEIRO — medido em 14/09,
    # e ao contrário do que o palpite dizia. O `medir_silhueta_props.py`
    # pergunta que fração da silhueta corre nas três direções que uma caixa
    # alinhada aos eixos sabe desenhar (+-26,57° e a vertical), normalizada
    # contra formas ideais DA MESMA caixa envolvente. Renderizado sozinho, sem
    # contêiner nem cabine, o casco do cargueiro grande mediu **0,620** —
    # acima do galpão (0,563) e de tudo o resto que tem tamanho para a
    # pergunta ter resposta.
    #
    # E a leitura óbvia estava invertida: o porta-contêineres media 0,516 e o
    # irmão de carga geral 0,203, o que parecia dizer "a caixa que se vê é o
    # contêiner". Não é. O contêiner é uma caixa DE VERDADE e não se mexe; o
    # que ele fazia era TAPAR o casco. Quem estava reto era o bordo.
    #
    # A causa tinha nome e comprimento: destes sete pontos, o lado de
    # (1,55, 0,58) a (-1,45, 0,62) é uma RETA DE 3 UNIDADES, e nesta câmera ela
    # cai exatamente em cima de um dos eixos — 56 px de reta contínua no PNG,
    # a mais comprida do kit depois do convés dos píeres, que é retângulo de
    # propósito. Um casco não tem bordo reto: tem entrada, corpo paralelo e
    # esgorjadura.
    #
    # ⚠️ E O TOSADO (a amurada a subir para a proa) FICOU DE FORA, MEDIDO.
    # Uma unidade de altura vale 24,5 px de tela e o casco tem 0,62 delas; o
    # tosado de um navio real anda por 8% do pontal, o que dá **1,2 px** —
    # abaixo dos 3 px em que a régua começa sequer a ver uma curva (a varredura
    # de filete está na `docs/decisoes/024`). Seria geometria paga e invisível.
    # O que se vê desta câmera é a PLANTA, e é a planta que se curva.
    def contorno_casco(frente, re, boca, boca_re, cheio=0.42, recuo=0.22,
                       n=18):
        """A meia-boca de proa a popa, amostrada como curva e não como quina.

        Três trechos, que é como um casco se desenha: a ENTRADA abre da roda de
        proa até à boca máxima, o CORPO PARALELO segura-a, e a ESGORJADURA
        afina até ao painel de popa. Os extremos são os mesmos de antes —
        `frente`, `re` e `boca` não se mexem — para a caixa envolvente do prop
        não mudar um pixel: o barco cai em `Dock.tscn` num `offset` fixo, e
        um casco mais gordo ou mais curto mexeria nele sem dar erro nenhum.

        ⚠️ O PASSO TEM DE FICAR ABAIXO DA MENOR RETA QUE A RÉGUA CONTA. Com
        n=18 o segmento mais comprido do corpo paralelo dá ~4 px na tela, e a
        régua do `medir_silhueta_props.py` só chama reta a uma corda de 6 px ou
        mais — ou seja, a curva é lida como curva e não como um polígono novo.
        Com n=6 sairiam quinas, que é trocar uma reta comprida por seis curtas.
        """
        comp = frente - re
        x_cheio = frente - cheio * comp
        x_recuo = re + recuo * comp

        def meia_boca(x):
            if x >= x_cheio:                      # entrada
                u = (frente - x) / (frente - x_cheio)
                return boca * math.sin(math.pi / 2 * u) ** 0.85
            if x >= x_recuo:                      # corpo paralelo
                return boca
            # ⚠️ O `min(1,0)` NÃO É ZELO. O último passo cai em `re` com uma
            # sobra de 1e-16, `v` passa de 1, o cosseno fica NEGATIVO e um
            # negativo elevado a 1,3 é um COMPLEXO — o gerador rebentava no
            # pesqueiro e passava no cargueiro, porque o erro do último passo
            # depende do comprimento.
            v = min(1.0, (x_recuo - x) / (x_recuo - re))    # esgorjadura
            return boca_re + (boca - boca_re) * math.cos(math.pi / 2 * v) ** 1.3

        bordo = []
        for i in range(1, n + 1):
            x = frente - comp * i / float(n)
            bordo.append((round(x, 4), round(meia_boca(x), 4)))
        # Proa como ponto e popa como painel: a popa é um corte, não uma quina.
        # ⚠️ O ESPELHO LEVA O ÚLTIMO PONTO, senão não há painel de popa. Com
        # `reversed(bordo[:-1])` o contorno saltava de (re, +boca_re) para o
        # bordo de baixo uma amostra à frente, e o que fechava a popa era uma
        # DIAGONAL atravessada — um casco cortado de esguelha, sem erro nenhum
        # a apontá-lo.
        return ([(frente, 0.0)] + bordo
                + [(x, -y) for x, y in reversed(bordo)])

    def casco_e_fundo(frente, re, boca, boca_re):
        """O par de contornos de um casco: a amurada e a linha de fundo.

        ⚠️ E O FUNDO TEM CURVA PRÓPRIA, MEDIDO. Enquanto ele era a amurada
        escalada por `(0,88, 0,42)`, a curva chegava lá achatada 58% e o que a
        régua lia na silhueta era uma RETA DE 60 px — a mais comprida que
        sobrou depois de o convés curvar, e por isso a que continuava a fazer o
        casco medir quadrado. Um casco de verdade afina MAIS em baixo do que em
        cima: a linha de fundo tem entrada mais longa e esgorjadura mais longa
        do que a amurada, e é isso que os dois jogos de `cheio`/`recuo` dizem.
        Os dois contornos saem da mesma função e com o mesmo `n`, que é o que
        os deixa fechar face a face sem uma linha de exceção.
        """
        return (contorno_casco(frente, re, boca, boca_re, 0.42, 0.22),
                contorno_casco(frente * 0.88, re * 0.88,
                               boca * 0.42, boca_re * 0.42, 0.60, 0.38))

    CARGA, CARGA_FUNDO = casco_e_fundo(2.30, -2.05, 0.62, 0.44)
    PESCA, PESCA_FUNDO = casco_e_fundo(1.55, -1.40, 0.46, 0.32)

    def escalar(contorno, k):
        """O mesmo contorno noutro porte.

        ⚠️ ESCALA-SE O CONTORNO, NUNCA SE REESCREVEM OS PONTOS. É a regra que
        o `galpao` já paga ("encolher um prop escala-se no GRUPO"), aplicada um
        andar acima: catorze números escritos três vezes seriam catorze
        oportunidades de um ficar por escalar, e um casco com a proa de um
        porte e a popa de outro não dá erro nenhum — dá um barco torto.
        """
        return [(x * k, y * k) for x, y in contorno]

    def escalar_par(par, k):
        """Amurada e fundo do mesmo casco noutro porte, pela mesma razão."""
        return (escalar(par[0], k), escalar(par[1], k))

    def casco(sufixo, contorno, fundo, altura, cor_casco, cor_faixa, vigias=4,
              postes=6):
        """Casco, faixa de amurada, guarda-corpo e vigias.

        O casco sozinho lia como uma CUNHA DE COR. O que separa navio de cunha
        é o vazado do guarda-corpo e a fileira de vigias: dois detalhes que dão
        escala — o olho conhece o tamanho de uma vigia e mede o resto por ela.

        ⚠️ `vigias=0` É UM PEDIDO, e não um descuido. Um bote aberto não tem
        vigia nenhuma: vigia é janela de compartimento ABAIXO do convés, e um
        casco de 42px que não tem compartimento nenhum passaria a ter oito
        furos a dizer que tem. O `postes` desce pela mesma conta — seis
        montantes num corrimão de 42px ficam a menos de 2px um do outro, e o
        vazado que eles existem para dar fecha-se.
        """
        meio = max(p[0] for p in contorno) * 0.55
        largura = max(p[1] for p in contorno) * 0.80
        pecas = [
            prisma("casco" + sufixo, contorno, 0.0, altura, None, cor_casco,
                   contorno_baixo=fundo),
            prisma("faixa" + sufixo, contorno, altura - 0.12, altura + 0.02,
                   (0.99, 0.97), cor_faixa),
            # Convés: um plano claro dentro da amurada, senão o interior do
            # casco fica com a cor do costado e o barco parece maciço.
            prisma("conves" + sufixo, contorno, altura - 0.06, altura - 0.02,
                   (0.80, 0.62), PALETA_MAT["cabine"]),
        ]
        # O guarda-corpo segue o BORDO — ver `corrimao_bordo`. Os montantes
        # saem do próprio contorno, afinados para o número pedido, e recuam
        # 20% da meia-boca, que é onde o corrimão reto ficava no corpo
        # paralelo: assim o n1 e o n3 não saltam de sítio.
        borda = sorted([p for p in contorno
                        if p[1] < 0 and -meio <= p[0] <= meio],
                       key=lambda p: p[0])
        if len(borda) > postes:
            salto = (len(borda) - 1) / float(max(postes - 1, 1))
            borda = [borda[int(round(i * salto))] for i in range(postes)]
        pecas += corrimao_bordo(
            "cor" + sufixo, [(x, y * 0.80, altura) for x, y in borda],
            0.20, PALETA_MAT["metal_claro"], esp=0.030)
        # Vigias na face que a câmera vê. O casco não é uma caixa, mas nesta
        # escala a fileira só precisa de acompanhar a linha de água.
        for i in range(vigias):
            u = (i - (vigias - 1) / 2.0) * (meio * 1.5 / max(vigias - 1, 1))
            pecas.append(caixa("vig%s%d" % (sufixo, i),
                               (u, -largura - 0.02, altura * 0.55),
                               (0.13, 0.05, 0.13), PALETA_MAT["metal_claro"]))
            pecas.append(caixa("vigv%s%d" % (sufixo, i),
                               (u, -largura - 0.05, altura * 0.55),
                               (0.08, 0.03, 0.08), PALETA_MAT["vidro"]))
        return pecas

    def no_costado(contorno, x):
        """Onde está o costado VISÍVEL (-y) em `x`, e para onde ele aponta.

        Devolve o `y` da amurada e o giro em `z` que a acompanha. O que se
        pinta ou pendura no costado segue a curva: uma letra direita na
        entrada da proa ficaria meio dentro do casco e meio a flutuar.
        """
        lado = sorted([p for p in contorno if p[1] < 0], key=lambda p: p[0])

        def meia(xx):
            for (x0, y0), (x1, y1) in zip(lado, lado[1:]):
                if x0 <= xx <= x1:
                    t = (xx - x0) / (x1 - x0) if x1 > x0 else 0.0
                    return -(y0 + (y1 - y0) * t)
            return -(lado[0][1] if xx < lado[0][0] else lado[-1][1])

        inclin = (meia(x + 0.02) - meia(x - 0.02)) / 0.04
        return -meia(x), math.degrees(math.atan(-inclin))

    def marcas_de_casco(sufixo, contorno, altura, k, letra, pneus, letras,
                        rolo=None, cabecos=None, letras_rentes=False):
        """O que um barco de verdade traz no costado e no convés.

        Nasceu com a pesca (`071`) e serve também aos cargueiros, que levam
        as mesmas letras, rolo e cabeços, e nenhum pneu.

        A frente 4 (família frota) pediu os quatro grupos de uma vez —
        defensas e amarração, nome e bandeira, equipamento, desgaste —, e os
        três portes partilham a GRAMÁTICA destas marcas e não as posições: `k`
        é o porte (o do `escalar_par`), e cada barco diz onde elas cabem entre
        as peças que já tem.

        - DEFENSAS: pneus velhos pendurados na amurada, pelo lado que se vê. É
          o que o pescador brasileiro usa, e é escuro sobre a faixa de cor.
        - NOME: uma fileira de letras na proa, que a 2 px não se leem e não é
          preciso — lê-se que o barco TEM nome, que é o que dá escala.
        - ESCORRIDO: NÃO mora aqui, mora no material da faixa de cor
          (`material_escorrido` com a cor dela levada ao escuro), e não é
          ferrugem — a ferrugem continua a ser marca da classe de CARGA. A
          primeira candidata desenhava-o com caixas de 0,026 por baixo da
          amurada, e a 1 px elas não apareciam em barco nenhum.
        - BANDEIRA: SAIU (`073`). Viveu aqui o pavilhão do Brasil num pau na
          popa, e nos cargueiros no mastro de sinais; o Bruno tirou-o de todos
          os navios ao fechar a `072`.
        - AMARRAÇÃO: rolo de cabo e cabeços na proa. O cabo ATÉ O PÍER não
          entra no prop: o barco chega e balança, e um cabo preso ao casco
          chegaria já esticado a apontar para o ar.
        """
        pecas = []
        for i, x in enumerate(pneus):
            y, _ = no_costado(contorno, x)
            zc = altura - 0.055 * k
            pecas += [
                # Um ANEL e não um disco: o furo mostra a faixa por trás, e
                # é o furo que faz a mancha escura ler como pneu (o Bruno, na
                # primeira candidata: «pneus leem como mancha»).
                anel("pneu%s%d" % (sufixo, i), (x, y - 0.045 * k, zc),
                     0.072 * k, 0.030 * k, M["pneu"], rot=(90, 0, 0)),
                caixa("pneuc%s%d" % (sufixo, i),
                      (x, y - 0.030 * k, altura + 0.03 * k),
                      (0.018 * k, 0.018 * k, 0.05 * k), M["corda"]),
            ]
        # ⚠️ RENTES NO CARGUEIRO: a 0,012 de espessura e 0,008 para fora, as
        # letras do casco de carga liam-se como blocos brancos EM PÉ na borda
        # (o Bruno: «partes do navio para fora do casco»). Nos barcos de pesca
        # aceites elas ficam como estavam.
        fora, esp = (0.004, 0.006) if letras_rentes else (0.008, 0.012)
        for i, x in enumerate(letras):
            y, ang = no_costado(contorno, x)
            pecas.append(caixa("letra%s%d" % (sufixo, i),
                               (x, y - fora, altura - 0.05 * k),
                               (0.05 * k, esp, 0.085 * k), letra,
                               rot=(0, 0, ang)))
        if rolo is not None:
            rx, ry = rolo
            zr = altura - 0.02 + 0.018 * k + 0.003
            pecas += [
                cone("rolo" + sufixo, (rx, ry, zr), 0.07 * k, 0.07 * k,
                     0.036 * k, 14, M["corda"]),
                cone("roloc" + sufixo, (rx, ry, zr + 0.02 * k), 0.028 * k,
                     0.028 * k, 0.006, 10, M["vao"]),
            ]
        if cabecos is not None:
            for i, s in enumerate((-1, 1)):
                pecas.append(cone("cabeco%s%d" % (sufixo, i),
                                  (cabecos, s * 0.07 * k,
                                   altura - 0.02 + 0.045 * k),
                                  0.028 * k, 0.028 * k, 0.09 * k, 8, M["metal"]))
        return pecas

    # ── A FROTA DE PESCA TEM TRÊS PORTES ────────────────────────────────
    #
    # Até 08/09 havia UM barco de pesca, e ele era o único que o porto em
    # ruínas recebia: a trava de `docs/decisoes/009` prende o pesqueiro ao
    # nível 1, então o jogador que ainda não construiu nada via o MESMO barco
    # em todas as docas, em todos os turnos, a partida inteira. É o buraco do
    # `barco_medio` virado do avesso mais uma vez — ali um prop existia e não
    # chegava à tela; aqui um prop chegava à tela e mais nenhum existia.
    #
    # ⚠️ E O EIXO NÃO É O MOTIVO — a afirmação de `docs/decisoes/010` fica de
    # pé. O pesqueiro chega com `pescado` ou com `armazenagem`, que é o mesmo
    # peixe indo para o mercado ou para a câmara, e o DESTINO da carga continua
    # a não mudar o barco. O que o muda é o PORTE, e o porte sai do valor do
    # contrato: um bote de linha não traz uma escala de R$28.000. Os três
    # partilham o `casco()` e separam-se pelo que têm em cima — a mesma regra
    # que separa o porta-contêineres do graneleiro, aplicada a um eixo
    # diferente.
    #
    # ⚠️ CADA PORTE TEM VOCABULÁRIO PRÓPRIO, e não é o mesmo barco esticado.
    # É a regra que o armazém pagou em 05/09 e que a frota de 07/09 repetiu:
    # escalar o mesmo desenho três vezes daria três barcos iguais e três
    # etiquetas de tamanho. São três gramáticas — o CONVÉS ABERTO com caixas
    # de peixe e motor de popa, o PAU-DE-CARGA sobre a cabine, e o PÓRTICO DE
    # POPA com tangones e tambor de rede.
    #
    # ⚠️ E NENHUM DELES ENFERRUJA, mesmo o maior. A conta que isentou o
    # pesqueiro em 07/09 era de tamanho (67px contra 97), e o arrasteiro tem
    # 83 — perto o suficiente para a pergunta voltar. A resposta continua a ser
    # não, e agora por outra razão: um rasto de ferrugem em UM dos três faria a
    # ferrugem ler como marca de porte, e o que separa estes três é a
    # gramática do convés. Quem enferruja é a classe de carga, inteira.
    rede_nylon = material_malha("rede_nylon", PALETA["rede_fio"],
                                PALETA["rede_nylon"])
    rede_cinza = material_malha("rede_cinza", PALETA["rede_fio_cinza"],
                                PALETA["rede"])
    # O saco CHEIO: o fio verde por cima do prateado do peixe. Com a malha
    # fina sobre verde, o saco da segunda candidata lia-se como um arbusto
    # («saco verde como mancha»); o que diz «rede cheia» é o peixe a
    # aparecer entre os fios, e por isso a célula é maior e o fio mais grosso.
    # A célula mede-se no PNG: a 0,07 os losangos tinham menos de 2 px e o
    # saco saía granulado; a 0,11 cabem três de lado a lado.
    saco_cheio = material_malha_losango("saco_cheio", PALETA["rede_fio"],
                                        PALETA["peixe"], passo=0.11,
                                        espessura=0.26)
    BOTE = escalar_par((PESCA, PESCA_FUNDO), 0.62)
    ARRASTO = escalar_par((PESCA, PESCA_FUNDO), 1.24)
    # ⚠️ E O BOTE É PEQUENO DEMAIS PARA ESTA CURVA — medido, e ele fica como
    # está. A 0,62 do pesqueiro o fundo dele tem 2,4 px de meia-boca: a curva
    # INTEIRA cabe dentro do pixel de tolerância com que a régua mede reta, e a
    # maior reta da linha de fundo dele mexeu-se de 0,574 para 0,597 do
    # comprimento — para o lado errado, e por ruído. Tentou-se dar-lhe fundo
    # chato (0,70 em vez de 0,42, que é o que um bote aberto de linha tem
    # mesmo): deu 0,621, e a 6x de ampliação as três versões são a MESMA
    # imagem. É a lição do `medir_silhueta_props.py` aplicada a um pedaço de
    # prop — abaixo de certo tamanho a pergunta não tem resposta, e a resposta
    # certa é não mexer em vez de arredondar por arredondar.

    # O BOTE: convés aberto, e é a ausência que o desenha. Sem cabine, sem
    # vigia, sem pau-de-carga — o que se vê lá dentro são as caixas do peixe,
    # que num barco maior estariam no porão.
    grupos["barco_pesca_bote"] = casco(
        "_pb", BOTE[0], BOTE[1], 0.30, M["casco_pesca"],
        material_escorrido("faixa_esc_pb", PALETA["faixa"],
                           PALETA["escorrido_vermelho"], escala=7.0 / 0.62),
        vigias=0, postes=4) + [
        # Console de pilotagem: um barco aberto não tem ponte, tem um posto de
        # pé com um para-brisa. A 8px ele é o que diz que ali vai alguém.
        caixa("console_pb", (-0.42, 0.0, 0.49), (0.34, 0.40, 0.38), M["cabine"]),
        caixa("parabrisa_pb", (-0.42, 0.0, 0.60), (0.35, 0.41, 0.11), M["vidro"]),
        caixa("teto_pb", (-0.42, 0.0, 0.71), (0.40, 0.46, 0.05), M["metal_claro"]),
        # Mastro de luz: o único vertical do barco. Sem ele a silhueta é uma
        # linha deitada, e uma linha deitada na água lê como tábua.
        caixa("mastro_pb", (-0.10, 0.0, 0.70), (0.08, 0.08, 0.80), M["madeira_esc"]),
        caixa("luz_pb", (-0.10, 0.0, 1.14), (0.11, 0.11, 0.11), M["luz_poste"]),
        # As caixas do peixe, que são a carga à vista: num barco maior elas
        # estariam no porão, e é isso que faz o convés aberto ler como bote.
        #
        # ⚠️ ALTERNAM DE TOM, E A PRIMEIRA VERSÃO ERRADA A ESCOLHA. Ela usava
        # `cabine` numa delas e punha uma caixa de gelo do MESMO branco ao
        # lado: as duas fundiram-se numa mancha só que ficou a maior peça do
        # barco, e o branco competia com o console. É a lição do
        # `pilha_caixotes` — faces vizinhas do mesmo tom fundem-se — apanhada
        # dentro de um prop de 44px. Agora alternam entre os dois tons de
        # MADEIRA, e o único branco é a caixa de gelo, pequena e na proa.
        caixa("cxp_pb0", (0.02, 0.13, 0.36), (0.26, 0.22, 0.18), M["corda"]),
        caixa("cxp_pb1", (0.02, -0.13, 0.36), (0.26, 0.22, 0.18), M["madeira"]),
        caixa("cxp_pb2", (0.30, 0.13, 0.36), (0.26, 0.22, 0.18), M["madeira"]),
        caixa("cxp_pb3", (0.30, -0.13, 0.36), (0.26, 0.22, 0.18), M["corda"]),
        caixa("gelo_pb", (0.62, 0.0, 0.37), (0.26, 0.24, 0.20), M["cabine"]),
        # Motor de popa: pendurado ATRÁS do espelho de popa, como um motor de
        # popa está. É a peça que diz "pequeno" sem depender de comparação.
        caixa("motor_pb", (-0.97, 0.0, 0.34), (0.16, 0.22, 0.28), M["metal"]),
        caixa("rabeta_pb", (-1.00, 0.0, 0.10), (0.09, 0.09, 0.30), M["metal"]),
    ]
    grupos["barco_pesca_bote"] += marcas_de_casco(
        "_pb", BOTE[0], 0.30, 0.62, M["cabine"],
        # Sem NOME nem PNEUS: a 44 px as letras eram um traço branco e os
        # pneus pontos soltos no costado (o Bruno, na primeira e na terceira
        # candidatas), e o bote diz-se pelo gelo e pelo rolo de cabo — e pela
        # bandeira, até ela sair de todos os navios (`073`).
        pneus=(), letras=(),
        rolo=(0.84, 0.0))

    # A TRAINEIRA: o porte do meio, e o casco, a cabine, o mastro e a rede são
    # os de sempre. Duas coisas mudaram, e as DUAS por defeitos que este
    # arquivo já tinha registados noutro prop:
    #
    # ⚠️ 1. O PAU-DE-CARGA LIA COMO UMA CRUZ. Erguido no plano do mastro, ele
    # projeta-se nesta câmera como dois traços a cortar a vertical — o desenho
    # de uma antena, não o de um guindaste. A lição está escrita ao lado, no
    # `deck_geral` dos cargueiros, e foi aplicada lá em 07/09; ao pesqueiro
    # nunca chegou, porque ninguém voltou a olhar para o prop depois de o
    # fazer. Girado 38° para `-y`, ele sai por cima da amurada como quem está
    # a içar o cesto do peixe, que é a leitura que o justifica.
    #
    # ⚠️ 2. A AMURADA ERA BRANCA E A CABINE TAMBÉM. Duas peças de `cabine`
    # encostadas uma na outra — a lição do `pilha_caixotes` outra vez, e a
    # razão de o barco inteiro ler como uma mancha clara com um fundo verde. A
    # faixa passou a azul; o verde do fundo é o que os TRÊS partilham, e é a
    # amurada que os separa (vermelha, azul, amarela) sem que a cor tenha de
    # fazer o trabalho da gramática.
    PAU_PIVO, PAU_BRACO = (0.136, 0.0, 1.065), 1.3
    prx, prz = math.radians(26.0), math.radians(38.0)
    dir_pau_p = (math.cos(prx) * math.cos(prz), -math.cos(prx) * math.sin(prz),
                 math.sin(prx))
    grupos["barco_pesca_traineira"] = casco(
        "_p", PESCA, PESCA_FUNDO, 0.44, M["casco_pesca"],
        material_escorrido("faixa_esc_p", PALETA["azul"],
                           PALETA["escorrido_azul"])) + [
        caixa("cabine_p", (-0.75, 0.0, 0.70), (0.85, 0.62, 0.50), M["cabine"]),
        # A cabine era um bloco branco sem janela nenhuma — uma casa do leme
        # de onde ninguém via o mar. Fita de vidro e teto, como a do
        # arrasteiro, e a balsa salva-vidas no teto (frente 4, «mais
        # realista»).
        caixa("fita_p", (-0.75, 0.0, 0.84), (0.86, 0.63, 0.12), M["vidro"]),
        caixa("teto_p", (-0.75, 0.0, 0.99), (0.93, 0.70, 0.07),
              M["metal_claro"]),
        # ⚠️ A BALSA LEVA BERÇO E CINTAS: o cilindro branco solto no teto
        # lia-se como um balão (o Bruno). O bujão de verdade assenta num
        # berço de ferro e é preso por duas cintas.
        # ⚠️ E É PEQUENA, COM CINTAS ESCURAS: com 0,22 e cintas laranja ela
        # chamava a atenção do barco inteiro para o teto (o Bruno, na quarta
        # candidata). O laranja deste barco é a salva-vidas.
        caixa("balsa_berco_p", (-1.00, 0.12, 1.04), (0.09, 0.18, 0.03),
              M["metal"]),
        cone("balsa_p", (-1.00, 0.12, 1.095), 0.048, 0.048, 0.17, 12,
             M["cabine"], rot=(90, 0, 0)),
        anel("balsa_cinta_p0", (-1.00, 0.07, 1.095), 0.051, 0.010,
             M["metal"], rot=(90, 0, 0)),
        anel("balsa_cinta_p1", (-1.00, 0.17, 1.095), 0.051, 0.010,
             M["metal"], rot=(90, 0, 0)),
        caixa("mastro_p", (0.25, 0.0, 1.25), (0.09, 0.09, 1.7), M["madeira_esc"]),
        caixa("pau", tuple(PAU_PIVO[k] + dir_pau_p[k] * PAU_BRACO / 2.0
                           for k in range(3)),
              (PAU_BRACO, 0.07, 0.07), M["madeira_esc"], rot=(0, -26, -38)),
        # ⚠️ O BLOCO LARANJA DA PROA SAIU. Era a `boia_p`, um cubo de 0,2 no
        # convés, e o Bruno leu-o como «um bloco laranja perdido no casco,
        # talvez seja um erro»: uma boia que não tem forma de boia é uma
        # caixa. A cor dela vive agora na salva-vidas, que tem forma.
        caixa("rede_p", (-0.15, 0.0, 0.60), (0.7, 0.5, 0.26), rede_cinza)]
    grupos["barco_pesca_traineira"] += marcas_de_casco(
        "_p", PESCA, 0.44, 1.0, M["cabine"],
        pneus=(-0.43, 0.0, 0.43), letras=(0.56, 0.66, 0.82, 0.92, 1.02),
        rolo=(0.78, -0.15), cabecos=1.18) + [
        # A boia salva-vidas na parede da cabine que se vê.
        anel("salva_p", (-0.52, -0.335, 0.63), 0.085, 0.026, M["boia"],
             rot=(90, 0, 0)),
    ] + [
        # As cortiças da rede de cerco, pela borda de cima: é o que faz o
        # monte cinzento ler como REDE e não como mais uma caixa.
        caixa("cortica_p%d" % i, (x, -0.22, 0.75), (0.065, 0.065, 0.05),
              M["amarelo"])
        for i, x in enumerate((-0.28, -0.15, -0.02, 0.11))]

    # O ARRASTEIRO: a POPA é que trabalha, e é ela que tem de estar à frente.
    #
    # ⚠️ NESTA CÂMERA O `-x` É O FUNDO DA IMAGEM, e a primeira versão pôs lá o
    # arrasto inteiro — pórtico, tambor e rede atrás de uma casa do leme a
    # meia-nau. O tambor saiu invisível e o pórtico leu como uma parede ao
    # fundo. A ordem certa é a que a traineira já usava sem o dizer: a cabine
    # recua para `-x` e o que se quer VER avança para `+x`. Aqui isso põe a
    # casa do leme à frente e o convés de trabalho atrás dela, que é
    # exatamente a planta de um arrasteiro de popa — a leitura e a verdade
    # do barco calharam do mesmo lado.
    #
    # ⚠️ E A SEGUNDA VERSÃO ERRADA A QUANTIDADE, não a posição. Ela tinha dois
    # TANGONES a abrir do mastro por cima do convés, e a 82px eles saíram no
    # mesmo ângulo de tela do pórtico: as três peças cinzentas fundiram-se num
    # ANDAIME só, com o mastro desaparecido lá dentro. A esta escala um prop
    # tem lugar para UMA silhueta memorável, não para cinco a competir — e a
    # que ganha é o arco de popa com a rede pendurada, porque é a única que não
    # existe em mais nenhum prop deste jogo. Os tangões saíram (são de barco de
    # camarão, não de arrasteiro de popa) e o que ficou por cima é UM mastro
    # vertical com uma verga curta e UM pau inclinado — uma vertical e uma
    # diagonal, que se distinguem uma da outra.
    #
    # ⚠️ E O PÓRTICO É `laranja` POR VOCABULÁRIO, não por gosto. As lanças dos
    # guindastes deste porto são laranja; equipamento de içar, aqui, tem cor
    # própria. Em cinzento ele encostava no telhado da casa do leme e nos dois
    # tons de metal do tambor — a lição do `pilha_caixotes` aplicada entre
    # peças do mesmo prop, e a razão de as três cinzentas se terem fundido.
    grupos["barco_pesca_arrasteiro"] = casco(
        "_pa", ARRASTO[0], ARRASTO[1], 0.56, M["casco_pesca"],
        material_escorrido("faixa_esc_pa", PALETA["amarelo"],
                           PALETA["escorrido_amarelo"], escala=7.0 / 1.24),
        vigias=5, postes=8) + [
        # Casa do leme: mais alta e mais estreita que a cabine da traineira, e
        # com fita de vidro. NÃO sai da `superestrutura()` dos cargueiros de
        # propósito — aquela é a peça que diz "cargueiro", e um pesqueiro que a
        # vestisse leria como o cargueiro mais pequeno do porto. Encolheu de
        # (0,95 × 0,78 × 0,84) porque a 82px ela ocupava perto de metade da
        # imagem e o convés de trabalho — que é o assunto do barco — sobrava.
        caixa("leme_pa", (0.60, 0.0, 0.90), (0.80, 0.70, 0.78), M["cabine"]),
        caixa("fita_pa", (0.60, 0.0, 1.08), (0.81, 0.71, 0.20), M["vidro"]),
        caixa("teto_pa", (0.60, 0.0, 1.32), (0.88, 0.78, 0.07), M["metal_claro"]),
        # Mastro com verga: a VERTICAL do prop. Nasce no teto da casa do leme,
        # que é onde um arrasteiro o tem, e a verga curta lá em cima é o que
        # impede a haste sozinha de ler como antena.
        caixa("mastro_pa", (0.60, 0.0, 1.76), (0.10, 0.10, 0.80), M["metal_claro"]),
        # ⚠️ NO TOPO VAI UMA CAIXA, E NÃO UMA VERGA. A verga que aqui esteve
        # tinha 0,52 de vão e saiu como uma CRUZ perfeita — a mesma leitura que
        # o pau-de-carga do cargueiro pagou em 07/09 e a traineira nesta
        # sessão, e desta vez sem nem sequer haver um pau. Uma horizontal
        # simétrica no topo de uma vertical é um crucifixo em qualquer escala.
        # A caixa do radar dá a mesma "haste com equipamento" sem a simetria.
        caixa("radar_pa", (0.60, 0.0, 2.03), (0.13, 0.22, 0.14), M["metal_claro"]),
    ]
    # O PAU DE CARGA, a diagonal. A conta é a do pau-de-carga do cargueiro,
    # escrita por extenso porque a correspondência entre o `rot` e a direção
    # não é óbvia: `rot=(0, ry, rz)` dá
    # `dir = (cos ry · cos rz, cos ry · sen rz, −sen ry)`.
    # Aqui ele desce (ry > 0) e aponta para a POPA (cos rz < 0) e para o
    # costado que se vê (sen rz < 0) — a ponta acaba por cima do convés de
    # trabalho, que é o que ele serve.
    #
    # ⚠️ 26° NÃO CHEGAM, e o número tem de sair do RENDER. A 26° o pau saía,
    # nesta projeção, como uma BARRA HORIZONTAL por cima do convés — no mesmo
    # ângulo de tela da travessa do pórtico e do tambor, que é o andaime outra
    # vez com uma peça a menos. A 42° ele desce visivelmente e a vertical do
    # mastro passa a ter com o que contrastar. Ângulo de peça inclinada neste
    # projeto mede-se na imagem, nunca no mundo: a câmera comprime a direção
    # (1,1) e estica a (1,−1), e 26° de mundo não são 26° de tela.
    #
    # ⚠️ E ELE É CINZENTO. Em `laranja` ficavam DUAS peças laranja no prop, e
    # aí o laranja deixa de apontar para alguma coisa — a cor de acento só
    # acentua enquanto for uma. O arco é a silhueta que este barco tem para
    # dar; o pau é apoio.
    PAU_A, apivo = 0.90, (0.60, 0.0, 1.66)
    arx, arz = math.radians(42.0), math.radians(-145.0)
    dir_a = (math.cos(arx) * math.cos(arz), math.cos(arx) * math.sin(arz),
             -math.sin(arx))
    grupos["barco_pesca_arrasteiro"] += [
        caixa("pau_pa", tuple(apivo[k] + dir_a[k] * PAU_A / 2.0 for k in range(3)),
              (PAU_A, 0.09, 0.09), M["metal_claro"], rot=(0, 42, -145)),
        # Escotilha do porão, no convés de trabalho e não na proa: é por ali
        # que o peixe desce. A braçola fica meio milímetro abaixo da tampa —
        # a mesma receita do graneleiro, e pela mesma razão.
        #
        # ⚠️ A TAMPA É `concreto` E NÃO `metal_claro`: com os dois cinzentos do
        # kit, tampa e braçola mediam 0,17 de contraste de Weber e a escotilha
        # inteira saía como uma mancha escura no convés — o buraco que ela é o
        # contrário de. Tampa de porão de pesqueiro é isolada e clara.
        caixa("brac_pa", (-0.05, 0.0, 0.60), (0.52, 0.48, 0.10), M["metal"]),
        caixa("tampa_pa", (-0.05, 0.0, 0.68), (0.48, 0.42, 0.07), M["concreto"]),
        # O guincho do arrasto, entre a escotilha e o tambor. Peça pequena e
        # escura, mas é ela que explica por que o convés está vazio: ele está
        # vazio porque é ali que se trabalha.
        caixa("guincho_pa", (-0.48, 0.0, 0.66), (0.22, 0.26, 0.22), M["metal"]),
        # Tambor de rede: um cilindro DEITADO atravessado no convés. É a peça
        # que diz que a rede vem por cima da popa e não pelo costado. Os dois
        # discos das pontas são `metal_claro` para o cilindro ler como
        # cilindro — em `metal` sobre `rede` ele era um vulto escuro.
        # ⚠️ E ELE É PEQUENO. A 0,22 de raio saía com 10px de raio e 17 de
        # comprimento, e a esta escala isso não é um tambor: é um TANQUE
        # atravessado a meia-nau, a competir com o arco pela silhueta. Um
        # tambor de rede é um acessório e vive encostado à popa, junto do
        # pórtico por onde a rede sai.
        cone("tambor_pa", (-1.02, 0.0, 0.74), 0.15, 0.15, 0.62, 12, rede_nylon,
             rot=(90, 0, 0)),
        cone("tamb_pa_bb", (-1.02, -0.32, 0.74), 0.175, 0.175, 0.06, 12,
             M["metal_claro"], rot=(90, 0, 0)),
        cone("tamb_pa_eb", (-1.02, 0.32, 0.74), 0.175, 0.175, 0.06, 12,
             M["metal_claro"], rot=(90, 0, 0)),
        # Pórtico de popa: duas colunas e a travessa. A travessa é mais FUNDA
        # que as colunas (0,15 contra 0,12) para as faces de `x` não ficarem
        # coplanares — a quina que dá a barra preta, registada duas vezes.
        caixa("port_pa_bb", (-1.42, -0.40, 1.06), (0.12, 0.12, 1.00), M["laranja"]),
        caixa("port_pa_eb", (-1.42, 0.40, 1.06), (0.12, 0.12, 1.00), M["laranja"]),
        caixa("port_pa_trav", (-1.42, 0.0, 1.60), (0.15, 1.02, 0.14), M["laranja"]),
        # A rede. Foi uma CHAPA de `rede` (um retângulo não lê como rede, e o
        # cinzento fundia-se no `metal_claro`) e depois um CONE de `corda`
        # pendurado no arco, que se lia como um funil; o Bruno pediu-a
        # melhor, «e até mudando ela de lugar» (frente 4, família frota).
        # Agora está onde a rede de um arrasteiro está depois de içada: o
        # corpo ENROLADO no tambor, em nylon verde, e o SACO cheio no convés
        # de popa, ao pé do pórtico, preso ao cadernal por um cabo. O arco
        # continua a ser a silhueta; o cabo é o que o liga ao saco.
        #
        #
        # ⚠️ E O SACO VOLTOU AO ARCO, MEDIDO NAS DUAS OUTRAS POSIÇÕES. No
        # convés de popa ele ficava tapado pelo tambor e pelo pórtico (o `-x`
        # é o fundo da imagem); à frente do tambor lia-se como uma mancha
        # verde-clara, um arbusto (o Bruno, na segunda e na terceira
        # candidatas). Pendurado do cadernal, a meio do arco, ele recorta-se
        # contra a água — e é a imagem de um arrasteiro a içar a captura. O
        # que o separa do funil de antes é a FORMA: redondo e cheio em baixo,
        # com um gargalo curto onde o cabo o prende.
        # ⚠️ E SEM CINTAS À VOLTA, E PRATEADO: três gomos verdes com duas
        # cintas horizontais liam-se como um PINHEIRO enfeitado. O que diz
        # «peixe» é o prateado a dominar, com o fio da rede fino por cima.
        # E COMPRIDO: o saco içado estica com o peso, e uma bola redonda com
        # a mesma malha lia-se como um calhau.
        bola("saco_pa0", (-1.42, -0.05, 1.17), (0.07, 0.07, 0.08), saco_cheio),
        bola("saco_pa1", (-1.42, -0.05, 0.90), (0.16, 0.16, 0.24), saco_cheio),
        caixa("cadernal_pa", (-1.42, -0.05, 1.46), (0.10, 0.09, 0.14),
              M["metal"]),
        caixa("cabo_saco_pa", (-1.42, -0.05, 1.32), (0.02, 0.02, 0.16),
              M["metal_claro"]),
        # Guincho da âncora, na proa. Um convés de proa completamente vazio
        # num barco com este porte lê como barco por acabar.
        caixa("ancora_pa", (1.34, 0.0, 0.66), (0.26, 0.30, 0.20), M["metal_claro"]),
    ]
    grupos["barco_pesca_arrasteiro"] += marcas_de_casco(
        "_pa", ARRASTO[0], 0.56, 1.24, M["vao"],
        pneus=(-0.75, -0.25, 0.25),
        letras=(0.62, 0.74, 0.94, 1.06, 1.18),
        rolo=(1.10, -0.24), cabecos=1.62) + [
        anel("salva_pa", (0.80, -0.37, 0.74), 0.10, 0.03, M["boia"],
             rot=(90, 0, 0)),
        # A balsa salva-vidas no teto da casa do leme: o bujão branco que
        # todo barco de pesca registado leva.
        caixa("balsa_berco_pa", (0.36, 0.18, 1.375), (0.15, 0.30, 0.04),
              M["metal"]),
        cone("balsa_pa", (0.36, 0.18, 1.465), 0.075, 0.075, 0.27, 12,
             M["cabine"], rot=(90, 0, 0)),
        anel("balsa_cinta_pa0", (0.36, 0.10, 1.465), 0.079, 0.014,
             M["metal"], rot=(90, 0, 0)),
        anel("balsa_cinta_pa1", (0.36, 0.26, 1.465), 0.079, 0.014,
             M["metal"], rot=(90, 0, 0)),
        # As PORTAS DE ARRASTO, penduradas do pórtico por fora do costado. São
        # as duas chapas que abrem a boca da rede no fundo, e o que diz
        # «arrasteiro» a quem já viu um — o arco sozinho diz só «popa alta».
        caixa("porta_pa_bb", (-1.42, -0.53, 0.86), (0.28, 0.04, 0.17),
              M["metal"]),
        caixa("porta_pa_eb", (-1.42, 0.53, 0.86), (0.28, 0.04, 0.17),
              M["metal"]),
        caixa("cadeia_pa_bb", (-1.42, -0.52, 1.29), (0.02, 0.02, 0.62),
              M["metal_claro"]),
    ]

    # ⚠️ A SUPERESTRUTURA TEM DOIS NÍVEIS desde a `073`, e foi a baleeira que
    # os pediu. Num bloco só não havia sítio para ela: pendurada na parede
    # caía sempre sobre janelas (o Bruno, duas candidatas: «presa nas
    # janelas»), afastada passava da borda do casco, e no teto «não é
    # realista». Num cargueiro ela vive no CONVÉS DE EMBARCAÇÕES — o teto de
    # um nível de baixo mais largo, ao lado de um nível de cima mais estreito
    # —, e foi isso que o Bruno escolheu. A caixa envolvente não mudou: o
    # topo, o comprimento e a boca são os de antes, e a chaminé, o radar e o
    # `topo_sup` ficam onde estavam.
    NIVEL_BAIXO = 0.20    # a altura do nível de baixo: um convés
    CONVES_BAL = 0.18     # a largura do convés de embarcações, de cada bordo
    FITA_ALT = 0.12       # a fita de vidro da ponte, no alto do nível de cima

    def conves_de_embarcacoes(z, tam):
        """O `z` do convés de embarcações e a meia-boca do nível de cima.

        A baleeira de 0,18 de boca cabe no convés com a borda 0,03 para fora
        do nível de baixo — onde o turco a segura — e 0,03 de folga da parede
        de cima. Menos do que 0,18 e ela encosta à parede; mais, e o nível de
        cima do longo curso fica uma torre fina.
        """
        return z - tam[2] / 2.0 + NIVEL_BAIXO, tam[1] / 2.0 - CONVES_BAL

    def superestrutura(sufixo, x, z, tam):
        """Dois níveis de acomodação, a fita de vidro da ponte e o teto.

        A cabine era um bloco branco. Uma superestrutura de navio tem uma
        FITA DE JANELA correndo à volta da ponte — é ela que diz de que lado
        alguém está a olhar, e é a peça que mais barato transforma o bloco.

        ⚠️ A FITA SUBIU PARA O ALTO DO NÍVEL DE CIMA: onde estava, a 18% da
        altura acima do meio, a baleeira do convés de embarcações chegava-lhe
        — e baleeira sobre vidro é o «presa nas janelas» outra vez. Entre a
        baleeira e a fita a parede de cima é CEGA de propósito.
        """
        L, W, H = tam
        z1 = z + H / 2.0
        zc, meia = conves_de_embarcacoes(z, tam)
        return [
            caixa("cab" + sufixo, (x, 0.0, zc - NIVEL_BAIXO / 2.0),
                  (L, W, NIVEL_BAIXO), PALETA_MAT["cabine"]),
            # A borda do convés de embarcações: a chapa sai um pouco do nível
            # de baixo, e é a linha escura dela que desenha o degrau.
            caixa("convesb" + sufixo, (x, 0.0, zc + 0.01),
                  (L * 1.02, W + 0.035, 0.035), PALETA_MAT["metal_claro"]),
            caixa("cabs" + sufixo, (x, 0.0, (zc + z1) / 2.0),
                  (L, 2.0 * meia, z1 - zc), PALETA_MAT["cabine"]),
            caixa("fita" + sufixo, (x, 0.0, z1 - 0.04 - FITA_ALT / 2.0),
                  (L * 1.01, 2.0 * meia + 0.006, FITA_ALT),
                  PALETA_MAT["vidro"]),
            caixa("teto" + sufixo, (x, 0.0, z1 + 0.03),
                  (L * 1.10, 2.0 * meia + 0.08, 0.07),
                  PALETA_MAT["metal_claro"]),
        ]

    def chamine(sufixo, x, z, raio, alt):
        return [
            cone("cham" + sufixo, (x, 0.0, z), raio, raio * 0.92, alt, 10,
                 PALETA_MAT["metal"]),
            cone("chamf" + sufixo, (x, 0.0, z + alt * 0.16), raio * 1.06,
                 raio * 1.02, alt * 0.28, 10, PALETA_MAT["faixa"]),
            cone("chamt" + sufixo, (x, 0.0, z + alt / 2.0), raio * 1.12,
                 raio * 1.12, 0.06, 10, PALETA_MAT["metal"]),
        ]

    # ── O QUE O NAVIO TRAZ, DESENHADO NO CONVÉS ─────────────────────────
    #
    # Até 06/09 havia um casco por CLASSE, e os dois cargueiros levavam as
    # mesmas quatro caixinhas coloridas: o jogo já sabia que um trazia
    # contêiner e o outro granel (é o motivo da escala, `docs/decisoes/008`) e
    # o desenho não dizia nada disso. É a mesma falta que o `barco_medio`
    # tinha do outro lado — ali o prop existia e não chegava à tela, aqui a
    # MECÂNICA existe e não chega ao desenho.
    #
    # ⚠️ O CONVÉS É QUE MUDA, E NÃO O CASCO. Um porta-contêineres e um
    # graneleiro do mesmo porte têm a mesma silhueta de casco; o que os separa
    # é o que está em cima. Refazer o casco por serviço seria seis cascos a
    # divergir — a regra do `_pecas_do_caminhao`, que existe por isto mesmo.
    #
    # ⚠️ E CADA UM PRECISA DO VOCABULÁRIO DA FUNÇÃO DELE, que é a regra que o
    # armazém pagou em 05/09: repintar as mesmas caixas de outra cor daria
    # três navios com o mesmo desenho e três etiquetas. Aqui são três
    # gramáticas diferentes — GRADE alinhada, TAMPA de porão, PALETE solto —
    # e é a gramática que se lê a 97px, não a cor.
    ALT_CONVES = 0.62                     # o topo do casco de carga
    CONT_TAM = (0.64, 0.42, 0.36)         # contêiner de convés: 14 x 9 px na tela

    def meia_carga(x):
        """A meia-boca da amurada de carga em `x` — o limite do que cabe no
        convés.

        ⚠️ A CARGA DA PROA PASSAVA DA BORDA, e ninguém o perguntava desde 07/09:
        a última baia do porta-contêineres de longo curso e as últimas tampas
        dos dois graneleiros ficavam com a boca do corpo paralelo numa proa
        que já estreitou, e saíam por cima da água (o Bruno, na frota:
        «partes do navio saindo do casco»). Quem estreita agora é a peça, pela
        meia-boca do casco no sítio dela.
        """
        return -no_costado(CARGA, x)[0]

    def deck_conteiner(sufixo, x0, baias, andares, comp=None):
        """Porta-contêineres: a PILHA ALINHADA, em grade e com guias.

        ⚠️ A GRADE NÃO SE FAZ COM FRESTA. Uma folga de 0,05 entre caixas dá 1px
        na tela e o antisserrilhado come-a — a mesma conta que fez o corrugado
        do contêiner do pátio ser diferença de VALOR e não relevo. Quem desenha
        a grade aqui é a cor: as caixas encostam-se e alternam em xadrez, e o
        olho lê as fronteiras de tom como fronteiras de caixa.

        As GUIAS de proa e de popa são o outro metade: duas verticais escuras
        de 2px a fechar a pilha nas pontas. São a peça que distingue "pilha
        arrumada num navio" de "caixas empilhadas no convés" — e a esta escala
        uma vertical escura lê onde uma linha desenhada não leria.
        """
        cores = (M["laranja"], M["azul"], M["amarelo"])
        # ⚠️ O LONGO CURSO LEVA CONTÊINERES CURTOS (de 20 pés), e é para caber:
        # quatro baias de 40 pés passavam da proa, e a de proa numa fila só
        # lia-se como uma torre (o Bruno). O comprimento sai da conta de
        # quantas baias cabem até onde o casco ainda leva duas filas.
        passo = comp if comp is not None else CONT_TAM[0]
        tam = (passo, CONT_TAM[1], CONT_TAM[2])
        pecas = []
        duplas = 0
        for i in range(baias):
            x = x0 + i * passo
            # Duas filas onde o casco as leva; UMA, ao meio, onde a proa já
            # estreitou — é o que a baia de proa de um navio de verdade faz.
            if meia_carga(x + passo / 2.0) - 0.03 >= 0.425:
                filas = (0.215, -0.215)
                duplas += 1
            else:
                filas = (0.0,)
            for j, y in enumerate(filas):
                for k in range(andares):
                    zc = ALT_CONVES + CONT_TAM[2] * (k + 0.5)
                    pecas.append(caixa("cx%s_%d%d%d" % (sufixo, i, j, k),
                                       (x, y, zc), tam,
                                       cores[(i + j + k) % 3]))
        comprimento = passo * baias
        alto = CONT_TAM[2] * andares
        meio_x = x0 + comprimento / 2.0 - passo / 2.0
        for lado, sx in (("proa", 1), ("popa", -1)):
            # DUAS COLUNAS e não uma antepara: a primeira versão era uma caixa
            # de 0,50 de fundo, e a 11px de largura ela saía como uma PAREDE
            # escura a fechar a pilha — lia-se como carga tapada, não como
            # guia. Duas colunas nos bordos deixam ver a pilha entre elas, que
            # é o que uma guia de célula faz.
            xg = meio_x + sx * comprimento / 2.0
            yg = min(0.40, meia_carga(xg) - 0.08)
            for j, y in enumerate((yg, -yg)):
                pecas.append(caixa("guia%s_%s%d" % (sufixo, lado, j),
                                   (xg, y, ALT_CONVES + alto / 2.0 + 0.03),
                                   (0.09, 0.11, alto + 0.06), M["metal"]))
        # Passadiço de peação, na face que a câmera vê. Ele corre por cima da
        # junta entre o primeiro e o segundo andar e é o que impede a pilha de
        # ler como um bloco só de cor — uma horizontal escura a meia altura.
        # Só ao longo das baias de duas filas, que é onde há costado de pilha.
        comp_p = passo * duplas
        pecas.append(caixa("peacao" + sufixo,
                           (x0 - passo / 2.0 + comp_p / 2.0, -0.455,
                            ALT_CONVES + CONT_TAM[2] + 0.02),
                           (comp_p * 0.96, 0.05, 0.06), M["metal"]))
        return pecas

    def deck_granel(sufixo, x0, poroes, guindastes, passo=0.62):
        """Graneleiro: PORÕES E ESCOTILHAS, e o convés vazio de propósito.

        A carga de um graneleiro está DENTRO. O que se vê é a fileira de tampas
        de porão sobre a braçola, e é essa fileira — clara sobre o convés,
        repetida a passo certo — que faz o navio ler como graneleiro sem uma
        única caixa em cima.

        ⚠️ A BRAÇOLA NÃO ENCOSTA NA TAMPA, e não é detalhe: duas faces à mesma
        altura dão o losango preto que este projeto já registou duas vezes. Ela
        fica meio milímetro abaixo, e o que se vê é o fio escuro à volta da
        tampa — que é justamente o que faz a tampa parecer tampa.
        """
        pecas = []
        comp = passo - 0.12
        for i in range(poroes):
            x = x0 + i * passo
            # A boca da escotilha é a do corpo paralelo onde ele a leva, e a
            # da proa onde ela já estreitou (ver `meia_carga`).
            boca = min(0.88, 2.0 * (meia_carga(x + comp / 2.0) - 0.08))
            # Braçola: mais larga e mais baixa que a tampa, em metal escuro.
            pecas.append(caixa("brac%s%d" % (sufixo, i), (x, 0.0, ALT_CONVES + 0.03),
                               (comp + 0.04, boca + 0.06, 0.10), M["metal"]))
            pecas.append(caixa("tampa%s%d" % (sufixo, i), (x, 0.0, ALT_CONVES + 0.11),
                               (comp, boca, 0.07), M["metal_claro"]))
            # Três vincos na tampa: uma tampa de porão é chapa dobrada, e a
            # esta escala três vincos chegam para o dizer. Mais seria a lixa
            # que o `DESGASTE` já registou.
            for k, dy in ((0, -0.26), (1, 0.0), (2, 0.26)):
                pecas.append(caixa("vinc%s%d%d" % (sufixo, i, k),
                                   (x, dy * boca / 0.88, ALT_CONVES + 0.145),
                                   (comp, 0.05, 0.03), M["metal"]))
        for i in range(guindastes):
            # Guindaste de bordo entre porões: é a peça que dá altura a um
            # convés que, por definição, não tem carga em cima.
            x = x0 + (i * 2 + 1) * passo - passo / 2.0
            pecas += [
                caixa("gcol%s%d" % (sufixo, i), (x, 0.0, ALT_CONVES + 0.42),
                      (0.16, 0.16, 0.84), M["amarelo"]),
                caixa("gcab%s%d" % (sufixo, i), (x, 0.0, ALT_CONVES + 0.92),
                      (0.26, 0.24, 0.20), M["metal_claro"]),
                caixa("glan%s%d" % (sufixo, i), (x + 0.42, 0.0, ALT_CONVES + 1.20),
                      (0.94, 0.08, 0.08), M["amarelo"], rot=(0, -22, 0)),
            ]
        return pecas

    def deck_geral(sufixo, x0, paletes):
        """Carga geral: PALETES no convés e paus-de-carga para os embarcar.

        O contrário do porta-contêineres, e de propósito: ali tudo é grade,
        aqui nada alinha. Palete de altura diferente, saco por cima de uns e
        não de outros — é a irregularidade que diz "carga geral", como a grade
        dizia "contêiner".

        Os dois mastros com pau-de-carga são a silhueta clássica do cargueiro
        de linha, e fazem aqui o trabalho que a pilha faz no outro: dar altura
        e dizer, de longe, de que navio se trata.
        """
        pecas = []
        # Palete: estrado escuro e carga clara por cima. O estrado é a peça que
        # impede a carga de flutuar — a queixa nº 1 da auditoria do pacote.
        # ⚠️ A ORDEM DA LISTA É POR COLUNA, e não por par. Ela nasceu agrupada
        # (dois paletes em cada `dx`), e o médio — que leva CINCO — ficava com
        # um monte apertado a meia nau e o resto do convés vazio: ao lado do
        # porta-contêineres e do graneleiro lia-se como navio por carregar.
        # Assim, os cinco primeiros já cobrem as três colunas.
        arranjo = ((0.00, 0.22, 0.30, "corda"), (0.56, -0.20, 0.32, "corda"),
                   (1.12, 0.20, 0.26, "corda"), (0.00, -0.24, 0.24, "madeira"),
                   (0.56, 0.24, 0.22, "madeira"), (1.12, -0.22, 0.30, "madeira"))
        for i in range(min(paletes, len(arranjo))):
            dx, dy, alt, cor = arranjo[i]
            x = x0 + dx
            pecas.append(caixa("est%s%d" % (sufixo, i), (x, dy, ALT_CONVES + 0.04),
                               (0.40, 0.34, 0.08), M["madeira_esc"]))
            pecas.append(caixa("cga%s%d" % (sufixo, i),
                               (x, dy, ALT_CONVES + 0.08 + alt / 2.0),
                               (0.36, 0.30, alt), M[cor]))
            # Cinta: um traço escuro a meia altura da carga. Sem ela um saco
            # claro e um estrado escuro leem como uma peça só de dois tons.
            pecas.append(caixa("cin%s%d" % (sufixo, i),
                               (x, dy, ALT_CONVES + 0.08 + alt * 0.55),
                               (0.37, 0.31, 0.04), M["madeira_esc"]))
        # ⚠️ O PAU-DE-CARGA APONTA PARA O COSTADO, e não só para cima. Erguido
        # no plano do mastro ele projeta-se, nesta câmera, como uma cruz — dois
        # traços a cortar o mastro, que é o desenho de uma antena e não o de um
        # guindaste. Girado 38° para `-y` (o costado que se vê), ele sai por
        # cima da amurada como quem está a embarcar carga, que é a leitura que
        # justifica os paletes ao lado. O deslocamento do centro segue a mesma
        # rotação: uma caixa girada em torno do centro dela só fica no sítio se
        # o centro andar com ela.
        #
        # ⚠️ E NASCE NO PÉ DO MASTRO, a subir. Articulado a meio do mastro e
        # quase deitado, o da frente saía por cima da água; virado para trás
        # lia-se como uma barra horizontal solta (o Bruno, duas candidatas).
        # O pau-de-carga de verdade tem o pé junto ao convés e sobe até perto
        # do tope — a 55° e a 25° para o costado, a ponta fica dentro do casco
        # nos dois mastros e ele lê como o que é.
        # O da frente abre só 16°: a proa ali já estreitou, e a 25° a ponta
        # passava 0,02 da borda no médio (medido contra o casco).
        BRACO = 1.00
        rx = math.radians(55.0)
        for i, (dx, abre) in enumerate(((-0.30, 25.0), (1.42, 16.0))):
            x = x0 + dx
            rz = math.radians(abre)
            dir_pau = (math.cos(rx) * math.cos(rz),
                       -math.cos(rx) * math.sin(rz), math.sin(rx))
            pivo = (x + 0.06, 0.0, ALT_CONVES + 0.30)
            pecas += [
                caixa("mst%s%d" % (sufixo, i), (x, 0.0, ALT_CONVES + 0.80),
                      (0.11, 0.11, 1.60), M["metal_claro"]),
                caixa("pau%s%d" % (sufixo, i),
                      tuple(pivo[k] + dir_pau[k] * BRACO / 2.0 for k in range(3)),
                      # 0,11 de secção: a 0,07 liam-se como traços finos
                      # (o Bruno, na quarta candidata).
                      (BRACO, 0.11, 0.11), M["metal_claro"],
                      rot=(0, -55, -abre)),
            ]
        return pecas

    # ⚠️ SÓ OS CARGUEIROS ENFERRUJAM, e o pesqueiro não — não por narrativa,
    # por tamanho: ele tem 67px de silhueta contra os 97 dos outros, e um rasto
    # de ferrugem que precisa de correr o pontal inteiro não cabe. É a mesma
    # conta do `DESGASTE`, aplicada a um padrão em vez de a um ruído.
    casco_ferrugem = material_escorrido("casco_ferrugem", PALETA["casco"],
                                        PALETA["ferrugem"])

    def cargueiro(sufixo, vigias, sup, cham, deck):
        """Casco de carga + superestrutura + chaminé + o convés do SERVIÇO.

        Os três serviços partilham tudo menos o convés, e é isso que faz o
        porte (médio contra longo curso) continuar a ler-se: quem muda com a
        classe é a superestrutura e a fileira de vigias; quem muda com o motivo
        da escala é só o que está em cima do convés.
        """
        return casco(sufixo, CARGA, CARGA_FUNDO, ALT_CONVES, casco_ferrugem,
                     M["faixa"], vigias) \
            + superestrutura(sufixo, sup[0], sup[1], sup[2]) \
            + chamine(sufixo, cham[0], cham[1], cham[2], cham[3]) + deck \
            + marcas_de_carga(sufixo, sup)

    def no_casco(x, z):
        """O ponto do costado VISÍVEL a uma altura `z` do casco de carga.

        O casco de carga é um prisma entre dois contornos — o fundo, estreito,
        a 0, e a amurada, larga, a `ALT_CONVES` —, e o costado é INCLINADO:
        uma peça pintada nele tem de se deitar com ele (giro em `x`) e de
        seguir a curva da proa (giro em `z`), senão fica meio dentro e meio a
        flutuar. Devolve o `y` e os dois giros.
        """
        t = z / ALT_CONVES
        y_topo, az = no_costado(CARGA, x)
        y_fundo, _ = no_costado(CARGA_FUNDO, x)
        y = y_fundo + (y_topo - y_fundo) * t
        ax = math.degrees(math.atan((y_fundo - y_topo) / ALT_CONVES))
        return y, ax, az

    def marcas_de_carga(sufixo, sup):
        """As marcas de navio mercante, iguais nos seis cascos de carga.

        A gramática é a da pesca (`marcas_de_casco`) sem os pneus — navio
        grande encosta nas defensas do CAIS, não leva as suas — e com o que
        só um navio de carga tem: a âncora no escovém com o rasto de ferrugem
        por baixo, as marcas de calado na proa, o molinete, a baleeira nos
        turcos do convés de embarcações, a cúpula do radar e a faixa
        antivegetativa na linha de água.
        """
        sx, sz, st = sup
        topo_sup = sz + st[2] / 2.0 + 0.07
        # ⚠️ `z_emb` E NÃO `zc`: o laço das marcas de calado, mais abaixo,
        # usa `zc` e deixava-o em 0,46 — a baleeira nasceu DENTRO do casco,
        # sem erro nenhum, e a primeira foto não tinha um pixel laranja.
        z_emb, meia = conves_de_embarcacoes(sz, st)
        z_ponte = sz + st[2] / 2.0 - 0.04 - FITA_ALT   # o pé da fita da ponte
        # As letras vão ao porte 1,0 (cabem na faixa de 0,14); sem cabeços,
        # que na proa liam-se como pontos soltos.
        # ⚠️ E SEM BANDEIRA: ela viveu num mastro de sinais à frente do teto
        # da ponte, e saiu de todos os navios (`073`, ordem do Bruno); o
        # mastro saiu com ela.
        pecas = marcas_de_casco(
            sufixo, CARGA, ALT_CONVES, 1.0, M["cabine"], pneus=(),
            letras=(1.00, 1.11, 1.22, 1.40, 1.51),
            rolo=(1.60, -0.24), letras_rentes=True)
        # A LINHA DE ÁGUA: um anel do casco entre 0 e 0,09, 1% para fora, com
        # a mesma interpolação entre os dois contornos que o prisma do casco
        # faz. Os dois contornos têm o mesmo número de pontos — é o que os
        # deixa fechar face a face (ver `casco_e_fundo`).
        # ⚠️ A 0,09 E A 0,15 ELA NÃO APARECIA (o Bruno: «linha de água não se
        # vê»): o costado de baixo é inclinado, e visto desta câmera uma fita
        # nele encolhe para metade. A 0,24 — perto de 40% do pontal, que é o
        # que um cargueiro em lastro mostra — lê-se.
        # ⚠️ E AFASTADA POR UMA FOLGA FIXA, não só em proporção: a 1,2% da
        # meia-boca, junto à roda a folga ia a zero e o casco e a faixa
        # disputavam o mesmo plano — saíam DENTES vermelhos e azuis ao longo
        # da proa, sem erro nenhum.
        t = 0.24 / ALT_CONVES

        def fora(y):
            return y * 1.02 + math.copysign(0.008, y) if y else 0.0

        anel_topo = [(xf + (xt - xf) * t, fora(yf + (yt - yf) * t))
                     for (xt, yt), (xf, yf) in zip(CARGA, CARGA_FUNDO)]
        pecas.append(prisma("antiveg" + sufixo, anel_topo, 0.0, 0.24, None,
                            M["antivegetativo"],
                            contorno_baixo=[(x, fora(y))
                                            for x, y in CARGA_FUNDO]))
        # A ÂNCORA no escovém, logo abaixo da faixa, e a ferrugem que ela
        # arrasta pelo costado: a marca mais reconhecível de um navio de
        # carga visto de lado.
        # ⚠️ RENTE E ESCURA: com 0,03 de espessura e em `metal` ela saía
        # como um bloco cinzento espetado no costado. A âncora de verdade
        # encosta ao casco, recolhida no escovém.
        xa = 1.72

        def rente(nome, z, tam, mat, fora=0.006, disco=False):
            # Cada peça pede o costado À SUA altura: ele é inclinado, e um `y`
            # só para a âncora inteira punha os braços a flutuar.
            y, ax, az = no_casco(xa, z)
            if disco:
                return cone(nome, (xa, y - fora, z), tam, tam, 0.006, 10, mat,
                            rot=(90 + ax, 0, az))
            return caixa(nome, (xa, y - fora, z), tam, mat, rot=(ax, 0, az))

        pecas += [
            rente("escovem" + sufixo, ALT_CONVES - 0.15, 0.045, M["vao"],
                  fora=0.003, disco=True),
            rente("anc_haste" + sufixo, ALT_CONVES - 0.22,
                  (0.035, 0.012, 0.13), M["vao"]),
            rente("anc_braco" + sufixo, ALT_CONVES - 0.285,
                  (0.13, 0.012, 0.035), M["vao"]),
        ]
        y, ax, az = no_casco(xa, ALT_CONVES - 0.40)
        pecas.append(caixa("anc_ferr" + sufixo, (xa, y - 0.004, ALT_CONVES - 0.40),
                           (0.035, 0.006, 0.18), M["ferrugem"],
                           rot=(ax, 0, az)))
        # As MARCAS DE CALADO: a escada de traços brancos junto à roda de proa.
        # ⚠️ RECUADAS DA RODA: a 2,02 o casco já é quase uma aresta, e os
        # traços pendiam para fora dela.
        for i, zc in enumerate((0.30, 0.38, 0.46)):
            y, ax, az = no_casco(1.92, zc)
            pecas.append(caixa("calado%s%d" % (sufixo, i),
                               (1.92, y - 0.004, zc), (0.07, 0.006, 0.035),
                               M["cabine"], rot=(ax, 0, az)))
        # O MOLINETE da âncora: UMA peça clara e a amarra que desce dela até ao
        # escovém. Dois tambores e dois cabeços escuros soltos no convés liam-se
        # como «pontos soltos» (o Bruno); a amarra é o que liga a máquina à
        # âncora e diz para que ela serve.
        pecas += [
            caixa("molinete" + sufixo, (1.80, -0.02, ALT_CONVES + 0.05),
                  (0.20, 0.30, 0.10), M["metal_claro"]),
            # A amarra acaba NA BORDA, onde o escovém a leva para fora: com
            # 0,24 de comprimento passava 0,075 da amurada.
            caixa("amarra" + sufixo,
                  (1.76, -(0.14 + meia_carga(1.76) - 0.02) / 2.0,
                   ALT_CONVES + 0.012),
                  (0.03, meia_carga(1.76) - 0.02 - 0.14, 0.02), M["vao"]),
        ]
        # A BALEEIRA no turco, pendurada ao lado da superestrutura pelo lado
        # que se vê: o laranja de salvamento que todo navio SOLAS leva.
        # ⚠️ AFASTADA DA PAREDE E EM CÁPSULA: uma caixa laranja encostada à
        # superestrutura lia-se como uma faixa pintada nela. A baleeira de
        # verdade é uma cápsula e pende do turco POR FORA.
        # ⚠️ E SEM MONTANTES DE PÉ: dois traços escuros verticais sobre a
        # cápsula liam-se como uma CARA («1 1» por cima de um sorriso). O
        # turco fica só nos dois braços que saem da parede por cima dela.
        # ⚠️ E POR DENTRO DO CASCO: a 0,13 da parede ela passava a borda do
        # costado (o Bruno: «partes do navio para fora do casco»).
        # ⚠️ E DO TAMANHO DE UMA BALEEIRA: encostada à parede a 0,27 ela
        # perdeu presença (o Bruno: «baleeira pequena»). Cresce em comprimento
        # e em altura, que é para onde há lugar; a boca fica presa à borda.
        # ⚠️ E NO TETO, NUM BERÇO: pendurada na parede, a meio ou à ré, ela
        # ficava sempre por cima de janelas (o Bruno, duas candidatas: «os
        # botes de salvamento estão presos nas janelas»). No teto da
        # superestrutura, a ré e pelo bordo que se vê, entre o radar e a
        # chaminé, ela não toca em parede nem em vidro.
        # ⚠️ E O TETO FOI RECUSADO — «não é realista» (`072`).
        # ⚠️ E FOI PARA O CONVÉS DE EMBARCAÇÕES (`073`, escolha do Bruno): o
        # teto do nível de baixo, pelo bordo que se vê, a ré e ao lado da
        # parede CEGA do nível de cima. A borda de fora passa 0,03 da borda
        # do nível de baixo, que é onde uma baleeira de turco fica estivada.
        xbal = sx - 0.15
        yb = -st[1] / 2.0 + 0.06
        z_bal = z_emb + 0.0275   # o topo da chapa do convés de embarcações
        pecas += [
            caixa("berco_bal" + sufixo, (xbal, yb, z_bal + 0.015),
                  (0.34, 0.12, 0.03), M["metal"]),
            bola("baleeira" + sufixo, (xbal, yb, z_bal + 0.09),
                 (0.25, 0.09, 0.08), M["laranja"]),
        ]
        # Os TURCOS: um braço por ponta, do pé da parede de cima à cabeça por
        # cima da baleeira — INCLINADOS, que é como um turco de gravidade fica
        # estivado. Os montantes de pé foram a «cara» da primeira passagem.
        pe_y, cab_y = -meia - 0.015, yb - 0.01
        dz = 0.24
        ang = math.degrees(math.atan2(pe_y - cab_y, dz))
        for i, xd in enumerate((xbal - 0.19, xbal + 0.19)):
            pecas.append(caixa("turco%s%d" % (sufixo, i),
                               (xd, (pe_y + cab_y) / 2.0, z_bal + dz / 2.0),
                               (0.04, 0.04, math.hypot(pe_y - cab_y, dz)),
                               M["metal"], rot=(ang, 0, 0)))
        # As ASAS DO PASSADIÇO: a plataforma que sai da ponte para os dois
        # bordos, ao nível do chão dela — o pé da fita —, até quase à borda
        # do casco — é por ali que o piloto olha o costado ao atracar. E as
        # JANELAS soltas da acomodação: a fita corrida é só da ponte (frente
        # 4, «mais realista»).
        x_asa = sx + st[0] / 2.0 - 0.08
        larg_asa = meia_carga(x_asa) - 0.03 - meia
        for lado in (-1, 1):
            pecas.append(caixa("asa%s%d" % (sufixo, lado + 1),
                               (x_asa, lado * (meia + larg_asa / 2.0),
                                z_ponte - 0.02), (0.16, larg_asa, 0.035),
                               M["cabine"]))
        # Uma fila no nível de baixo, a correr o costado todo — a baleeira
        # fica POR CIMA dela, do outro lado da borda do convés.
        z_jan = z_emb - NIVEL_BAIXO / 2.0
        x_jan = sx - st[0] / 2.0 + 0.12
        n = int((sx + st[0] / 2.0 - 0.08 - x_jan) / 0.20) + 1
        for i in range(n):
            xj = x_jan + i * 0.20
            pecas.append(caixa("jan%s%d" % (sufixo, i),
                               (xj, -st[1] / 2.0 - 0.004, z_jan),
                               (0.09, 0.012, 0.07), M["vidro"]))
        for i, yj in enumerate((-0.22, 0.0, 0.22)):
            pecas.append(caixa("janf%s%d" % (sufixo, i),
                               (sx + st[0] / 2.0 + 0.004, yj * st[1] / 0.85,
                                z_jan), (0.012, 0.09, 0.07), M["vidro"]))
        # E outra no nível de cima, só À FRENTE da baleeira: no vão dela a
        # parede é cega, que é o que a deixa de estar «presa nas janelas».
        z_jan2 = (z_bal + z_ponte) / 2.0
        x_jan2 = xbal + 0.25 + 0.10
        n2 = int((sx + st[0] / 2.0 - 0.08 - x_jan2) / 0.20) + 1
        for i in range(max(n2, 0)):
            xj = x_jan2 + i * 0.20
            pecas.append(caixa("jans%s%d" % (sufixo, i),
                               (xj, -meia - 0.004, z_jan2),
                               (0.09, 0.012, 0.07), M["vidro"]))
        for i, yj in enumerate((-0.5, 0.5)):
            pecas.append(caixa("jansf%s%d" % (sufixo, i),
                               (sx + st[0] / 2.0 + 0.004, yj * meia, z_jan2),
                               (0.012, 0.09, 0.07), M["vidro"]))
        # E as marcas de calado da POPA, como as da proa.
        for i, zc in enumerate((0.30, 0.38, 0.46)):
            y, ax, az = no_casco(-1.90, zc)
            pecas.append(caixa("caladop%s%d" % (sufixo, i),
                               (-1.90, y - 0.004, zc), (0.07, 0.006, 0.035),
                               M["cabine"], rot=(ax, 0, az)))
        # O RADAR no teto da ponte: uma CÚPULA branca num pedestal curto. O
        # mastro com a caixa ao lado lia-se como um gancho (o Bruno), e a verga
        # simétrica seria a cruz que este arquivo já pagou três vezes.
        pecas += [
            caixa("radar_m" + sufixo, (sx + 0.12, 0.10, topo_sup + 0.05),
                  (0.06, 0.06, 0.10), M["metal_claro"]),
            bola("radar_c" + sufixo, (sx + 0.12, 0.10, topo_sup + 0.14),
                 (0.09, 0.09, 0.07), M["cabine"]),
        ]
        return pecas

    # O médio: superestrutura larga e baixa, três baias, quatro porões.
    SUP_M = (-1.15, 0.95, (1.1, 0.85, 0.62))
    CHAM_M = (-1.55, 1.48, 0.13, 0.5)
    grupos["barco_medio_conteiner"] = cargueiro(
        "_mc", 4, SUP_M, CHAM_M, deck_conteiner("_mc", -0.30, 3, 2))
    grupos["barco_medio_granel"] = cargueiro(
        "_mn", 4, SUP_M, CHAM_M, deck_granel("_mn", -0.35, 4, 1))
    grupos["barco_medio_geral"] = cargueiro(
        "_mg", 4, SUP_M, CHAM_M, deck_geral("_mg", -0.15, 5))

    # O de longo curso: superestrutura mais alta e estreita, e mais de tudo em
    # cima do convés — é assim que os 97px de casco iguais continuam a dizer
    # qual dos dois é o maior.
    SUP_G = (-1.35, 1.00, (0.95, 0.8, 0.72))
    CHAM_G = (-1.7, 1.58, 0.15, 0.56)
    grupos["barco_grande_conteiner"] = cargueiro(
        "_gc", 5, SUP_G, CHAM_G, deck_conteiner("_gc", -0.56, 4, 3, comp=0.54))
    grupos["barco_grande_granel"] = cargueiro(
        "_gn", 5, SUP_G, CHAM_G, deck_granel("_gn", -0.55, 5, 2, passo=0.55))
    grupos["barco_grande_geral"] = cargueiro(
        "_gg", 5, SUP_G, CHAM_G, deck_geral("_gg", -0.30, 6))

    # -- O GUINDASTE DO NÍVEL 2 QUE DESCARREGA (02/10, `docs/decisoes/077`) --
    #
    # Escolhas do Bruno, perguntadas antes do render: o guindaste tira a
    # lingada do barco e pousa-a numa pilha no tabuado, o trabalhador
    # desengata-a, e nos serviços de mais de um turno leva a carga ao camião;
    # a lança GIRA para terra, como o pau do n1, e a cabine gira com ela; o
    # contêiner também desce, e fica no tabuado.
    #
    # ⚠️ O PASSO É O DO PAU DO n1, DE PROPÓSITO: o mesmo raio (`R_N1`, 3,30)
    # e o mesmo giro (`GIRO_N1`, 18° a 80°), à volta do mesmo eixo. A lança de
    # 2,85 não chegava a carga nenhuma — o porão do pesqueiro está a 3,30 da
    # torre e o convés dos três médios a 3,2–3,5 —, e com o raio do n1 o
    # gancho cai no porão do pesqueiro que o D39 já mediu, a 18° cai também em
    # cima da carga dos três médios (a segunda baia do porta-contêineres, a
    # segunda tampa do graneleiro, a palete de madeira do de carga geral), e a
    # 80° larga no MESMO ponto da pilha do peixe do n1. Logo a pilha do peixe
    # serve aos dois níveis sem render novo.
    #
    # ⚠️ A CARGA PENDURADA É OUTRO PNG, e não está nos quadros da lança. O pau
    # do n1 levava a carga dentro (18 quadros, um tipo de carga). Aqui são
    # quatro tipos — peixe, papelão, saco e contêiner —, e com a carga dentro
    # seriam 4 x 9 quadros de uma treliça grande; separada, são 15 quadros de
    # lança e 36 lingadas pequenas, que o atlas corta à volta do desenho. Todas
    # nascem no quadro do PÍER, já no sítio do gancho: o Godot não faz conta
    # nenhuma.
    R_PONTA_N2 = R_N1 + 0.15         # a ponta da lança, logo à frente do carro
    # O gancho em cima: mais alto do que o do n1, porque o contêiner pendurado
    # tem de passar por cima da pilha do porta-contêineres (1,34) a sair.
    GANCHO_CIMA_N2 = TOPO - 0.95
    LINGADA_CONT = 0.25              # do bico do gancho ao teto do contêiner
    TIPOS_N2 = ("peixe", "caixa", "saco", "conteiner")
    K_N2 = REGUA_DA_PESSOA
    CAIXA_N2 = {
        "peixe": CAIXA_PEIXE,
        "caixa": (CAIXA_PAPELAO[0] * K_N2, CAIXA_PAPELAO[1] * K_N2,
                  z(CAIXA_PAPELAO[2] * K_N2)),
        "saco": (SACO_RAFIA[0] * K_N2, SACO_RAFIA[1] * K_N2, z(SACO_RAFIA[2] * K_N2)),
        "conteiner": CONT_TAM,
    }

    def guindaste_n2(sufixo, giro, gancho):
        """A lança do n2 girada `giro` graus para terra, com o fundo do gancho
        à altura `gancho` — sem carga: a carga é a `lingada_*`.

        ⚠️ A TORRETA E O TOPO DOS TIRANTES FICAM NO EIXO, em `TOPO`: é o
        pivô que o `pivot_offset` do nó nomeia, e o quadro de repouso ainda
        varre a imagem à volta dele. Tudo o resto gira — e a cabine também,
        que num guindaste de torre vive na parte que gira.
        """
        a = math.radians(giro)
        d = Vector((-math.sin(a), -math.cos(a), 0.0))   # para onde aponta
        e = Vector((math.cos(a), -math.sin(a), 0.0))    # o lado da cabine
        rz = (0, 0, -giro)

        def em(r, lado=0.0, h=0.0):
            return (GX + d.x * r + e.x * lado, GY + d.y * r + e.y * lado,
                    TOPO + h)

        p = trelica("g_lanca" + sufixo, em(0.18), em(R_PONTA_N2), 0.13,
                    M["laranja"], montantes=8, esp=0.044)
        # A contralança e o contrapeso: é ele que equilibra a silhueta e
        # impede a peça de ler como poste com um braço.
        p += trelica("g_contra" + sufixo, em(-0.18), em(-1.05), 0.11,
                     M["laranja"], montantes=3, esp=0.042)
        p += [
            # A PLATAFORMA DE GIRO, por cima da torre: liga a lança à
            # contralança no eixo. Sem ela havia um vão de 0,36 no pivô, e a
            # lança girada a 18° tinha só 7% de desenho à volta do ponto em
            # que o nó a varre (a de 0° tinha 62%, por acaso da projeção) —
            # medido pelo D17, que existe para apanhar uma lança fora do eixo.
            caixa("g_giro" + sufixo, (GX, GY, TOPO - 0.02), (0.40, 0.40, 0.14),
                  M["laranja"], rz),
            caixa("g_contrapeso" + sufixo, em(-1.18, h=-0.06),
                  (0.30, 0.26, 0.30), M["metal"], rz),
            caixa("g_torreta" + sufixo, (GX, GY, TOPO + 0.42),
                  (0.09, 0.09, 0.70), M["metal"]),
            # Tirantes do topo até os dois extremos: é o que amarra a silhueta.
            barra("g_tirante_frente" + sufixo, (GX, GY, TOPO + 0.75),
                  em(R_PONTA_N2 - 0.40, h=0.06), 0.028, M["metal"]),
            barra("g_tirante_tras" + sufixo, (GX, GY, TOPO + 0.75),
                  em(-1.05, h=0.06), 0.028, M["metal"]),
            # A cabine e o vidro, com a mesma folga de antes: o vidro sai 0,02
            # da face de fora, e nenhuma face encosta noutra.
            caixa("g_cabine" + sufixo, em(0.02, 0.30, -0.55),
                  (0.30, 0.34, 0.34), M["laranja"], rz),
            caixa("g_cabine_vidro" + sufixo, em(0.02, 0.36, -0.50),
                  (0.22, 0.30, 0.24), M["vidro"], rz),
        ]
        # O carro fica na ponta, no raio do pau do n1; o cabo estica dele ao
        # moitão, e o moitão fica logo acima do gancho a qualquer altura.
        cx, cy, _ = em(R_N1)
        moitao = gancho + 0.33
        topo_cabo = TOPO - 0.20
        p += [
            caixa("g_carro" + sufixo, em(R_N1, h=-0.14), (0.17, 0.26, 0.13),
                  M["metal"], rz),
            caixa("g_cabo" + sufixo,
                  (cx, cy, (topo_cabo + moitao + 0.11) / 2.0),
                  (0.035, 0.035, topo_cabo - moitao - 0.11), M["metal"]),
            caixa("g_moitao" + sufixo, (cx, cy, moitao), (0.19, 0.15, 0.22),
                  M["amarelo"], rz),
            caixa("g_gancho" + sufixo, (cx, cy, gancho + 0.11),
                  (0.06, 0.06, 0.22), M["metal"]),
            caixa("g_gancho_bico" + sufixo, (cx, cy - 0.065, gancho + 0.03),
                  (0.055, 0.13, 0.06), M["metal"]),
        ]
        return p

    def _lote(nome, tipo, cx, cy, z0, colunas, andares):
        """Caixas, sacos ou contêineres do `tipo`, em colunas de `andares`, com
        o fundo em `z0`. Cada andar afunda 4 mm no de baixo: nenhuma face
        encosta noutra."""
        if tipo == "peixe":
            return _caixas_de_peixe(nome, cx, cy, z0, colunas, andares)
        cl, cf, ch = CAIXA_N2[tipo]
        p = []
        for i, (dx, dy) in enumerate(colunas):
            for a in range(andares):
                zc = z0 + a * (ch - 0.004) + ch / 2.0
                c = (cx + dx, cy + dy, zc)
                if tipo == "conteiner":
                    p.append(caixa("%s_%d_%d" % (nome, i, a), c, (cl, cf, ch),
                                   M["amarelo"]))
                    continue
                mat = M["papelao"] if tipo == "caixa" else M["rafia"]
                p.append(caixa("%s_%d_%d" % (nome, i, a), c, (cl, cf, ch), mat))
                if tipo == "saco":
                    # A faixa verde, como no saco ao ombro (`_faixa`): é ela que
                    # o separa do concreto do n3.
                    p.append(caixa("%s_%d_%d_f" % (nome, i, a), c,
                                   (0.10 * K_N2, cf + 0.02 * K_N2, ch + z(0.2 * K_N2)),
                                   M["folha"]))
            if tipo == "caixa":
                # A fita da tampa, só na de cima: nas de baixo ficava dentro
                # da caixa que lhe pousa em cima.
                topo = z0 + (andares - 1) * (ch - 0.004) + ch
                p.append(caixa("%s_%d_fita" % (nome, i),
                               (cx + dx, cy + dy, topo + z(0.4 * K_N2) / 2 - 0.002),
                               (cl + 0.01 * K_N2, 0.05 * K_N2, z(0.4 * K_N2)),
                               M["madeira_esc"]))
        return p

    def lingada(nome, tipo, hx, hy, gancho):
        """A carga pendurada no gancho em (hx, hy), com as cintas: duas
        colunas de dois andares, ou um contêiner preso pelos quatro cantos."""
        cl, cf, ch = CAIXA_N2[tipo]
        if tipo == "conteiner":
            topo = gancho - LINGADA_CONT
            cantos = [(sx * cl * 0.42, sy * cf * 0.40)
                      for sx in (-1, 1) for sy in (-1, 1)]
            corpo = _lote(nome, tipo, hx, hy, topo - ch, ((0.0, 0.0),), 1)
        else:
            topo = gancho - LINGADA
            cantos = [(-cl / 2.0, 0.0), (cl / 2.0, 0.0)]
            corpo = _lote(nome, tipo, hx, hy, topo - 2 * ch,
                          ((-cl / 2.0, 0.0), (cl / 2.0, 0.0)), 2)
        # As cintas são escuras: a esta escala é a linha escura que diz
        # «pendurado», não o tom (`076`).
        cintas = [barra("%s_cinta%d" % (nome, i), (hx, hy, gancho + 0.01),
                        (hx + ox, hy + oy, topo + 0.01), 0.018,
                        M["madeira_esc"])
                  for i, (ox, oy) in enumerate(cantos)]
        return cintas + corpo

    def gancho_para(tipo, fundo):
        """A altura do gancho que pousa a lingada do `tipo` com o fundo em
        `fundo` — a conta inversa da `lingada()`."""
        ch = CAIXA_N2[tipo][2]
        if tipo == "conteiner":
            return fundo + ch + LINGADA_CONT
        return fundo + 2 * ch + LINGADA

    # ONDE A LINGADA POUSA NO BARCO, pelo fundo dela. O gancho a 18° e 3,30
    # cai em (0,28; 0,21) do casco, e cada número é o que está ali em cima
    # do convés — medido no desenho de cada médio, e o D40 confere no render
    # que a carga cai dentro do casco.
    FUNDO_BARCO = {
        # o porão do pesqueiro, o mesmo do n1
        "peixe": GANCHO_BARCO - LINGADA - 2 * CAIXA_PEIXE[2],
        # a palete de madeira de 0,22 do `deck_geral`, em (0,41; 0,24)
        "caixa": ALT_CONVES + 0.08 + 0.22 + 0.002,
        # a tampa da segunda escotilha do `deck_granel`, em x 0,27
        "saco": ALT_CONVES + 0.165,
        # o lugar do segundo andar da segunda baia: o contêiner sai DA pilha
        "conteiner": ALT_CONVES + CONT_TAM[2],
    }
    # A PILHA de cada tipo, no ponto de largada do n1. Três colunas de três
    # andares, como a do peixe (`075`: é a altura que a faz ler como pilha);
    # o contêiner é um só, no tabuado, e o que desce pousa em cima dele.
    ANDARES_PILHA = {"peixe": PILHA_ANDARES, "caixa": 3, "saco": 3,
                     "conteiner": 1}
    COLUNAS_PILHA = ((0.02, -0.135), (0.0, 0.0), (-0.03, 0.135))
    for tipo in TIPOS_N2[1:]:
        colunas = ((0.0, 0.0),) if tipo == "conteiner" else COLUNAS_PILHA
        grupos["pilha_" + tipo] = _lote(
            "pl2_" + tipo, tipo, PILHA_N1[0], PILHA_N1[1], ALT_PIER - 0.004,
            colunas, ANDARES_PILHA[tipo])

    def fundo_pilha(tipo):
        ch = CAIXA_N2[tipo][2]
        return ALT_PIER + ANDARES_PILHA[tipo] * (ch - 0.004) + 0.01

    def gancho_em(giro):
        a = math.radians(giro)
        return (GX - R_N1 * math.sin(a), GY - R_N1 * math.cos(a))

    # OS QUADROS DA LANÇA: o repouso (`lanca_n2`, o g0 — é ele que varre sem
    # trabalho), os seis ângulos do giro com o gancho em cima, e o gancho em
    # baixo no barco e na pilha, um por tipo — cada tipo pousa a outra altura.
    grupos["lanca_n2"] = guindaste_n2("", GIRO_N1[0], GANCHO_CIMA_N2)
    for i, giro in enumerate(GIRO_N1):
        if i > 0:
            grupos["lanca_n2_g%d" % i] = guindaste_n2(
                "_g%d" % i, giro, GANCHO_CIMA_N2)
    for tipo in TIPOS_N2:
        grupos["lanca_n2_barco_" + tipo] = guindaste_n2(
            "_b" + tipo, GIRO_N1[0], gancho_para(tipo, FUNDO_BARCO[tipo]))
        grupos["lanca_n2_pilha_" + tipo] = guindaste_n2(
            "_p" + tipo, GIRO_N1[-1], gancho_para(tipo, fundo_pilha(tipo)))
    # AS LINGADAS: a carga no gancho em cada passo em que ele a leva.
    for tipo in TIPOS_N2:
        hx, hy = gancho_em(GIRO_N1[0])
        grupos["lingada_%s_barco" % tipo] = lingada(
            "lg_%s_b" % tipo, tipo, hx, hy, gancho_para(tipo, FUNDO_BARCO[tipo]))
        for i, giro in enumerate(GIRO_N1):
            hx, hy = gancho_em(giro)
            grupos["lingada_%s_g%d" % (tipo, i)] = lingada(
                "lg_%s_%d" % (tipo, i), tipo, hx, hy, GANCHO_CIMA_N2)
        hx, hy = gancho_em(GIRO_N1[-1])
        grupos["lingada_%s_pilha" % tipo] = lingada(
            "lg_%s_p" % tipo, tipo, hx, hy, gancho_para(tipo, fundo_pilha(tipo)))

    # -- TRABALHADOR no píer: até agora ele só existia como "#1" na chip.
    # De pé no tabuado, a doca ocupada lê-se sem ter de ler texto.
    # Fica do lado de TERRA e afastado do centro, porque o barco atraca do
    # outro lado e a chip cobre o meio do convés.
    # Em coordenadas DO MAPA: recuado para terra (mx negativo) e do lado oposto
    # ao barco, que atraca no +my. A conversão de eixo fica toda em pos().
    MX, MY = -1.35, -0.68
    ALT = 15.0                     # topo do tabuado, em pixels do mapa
    # A régua escala o boneco INTEIRO em volta dos pés — alturas, tamanhos e o
    # avanço da aba —, e os pés ficam onde estavam: o trabalhador continua no
    # mesmo sítio do tabuado, só mais pequeno (ver `REGUA_DA_PESSOA`).
    def _t(nome, subir_px, tam_px, mat, dmx=0.0):
        k = REGUA_DA_PESSOA
        subir_px, dmx = subir_px * k, dmx * k
        tam_px = (tam_px[0] * k, tam_px[1] * k, tam_px[2] * k)
        px, py, pz = pos(MX + dmx, MY, ALT + subir_px)
        return caixa(nome, (px, py, pz),
                     (tam_px[0], tam_px[1], z(tam_px[2])), mat)

    # O `trabalhador` deixou de ser este grupo de cinco caixas sem braços: é o
    # quadro parado do boneco articulado logo abaixo (`075`). O `_t` fica,
    # porque o pedestre da página de escala ainda é o corpo de sempre.

    # -- O TRABALHADOR QUE ANDA (02/10, `docs/decisoes/075`) ---------------
    #
    # Escolhas do Bruno, perguntadas antes do render: ele ATRAVESSA o tabuado,
    # do costado do barco até uma pilha no meio do píer, e volta — vai vazio,
    # de FRENTE para a câmara (`+my`), e volta com a carga ao OMBRO, de costas
    # (`-my`); o ciclo das pernas é quadro do Blender, e a figura é uma por
    # SEXO. No ombro a carga vê-se nos dois sentidos; nos braços sumiria atrás
    # do corpo na volta, que é justamente a viagem que a leva.
    #
    # Todo quadro nasce no MESMO ponto do mundo, o pé do `trabalhador` de
    # sempre (MX, MY): quem anda é o nó no Godot, que desliza o quadro inteiro
    # pelo caminho. Numa câmara ortográfica um quadro deslocado na tela é o
    # mesmo render, logo nenhum quadro precisa de saber onde está no caminho.
    #
    # ⚠️ O BONECO É ARTICULADO, e o de sempre não era: pernas numa caixa só e
    # nenhum braço. O `trabalhador` passou a ser o quadro PARADO do homem (os
    # pés juntos, virado para o barco), porque um parado sem braços ao lado de
    # um andar com braços faria os braços aparecerem e sumirem a cada viagem.
    #
    # As unidades são as do `_t`: o lado e a frente em unidades de MUNDO antes
    # da régua, a altura em pixels do MAPA antes da régua, e a régua escala o
    # boneco inteiro em volta dos pés. `s` é o sentido: −1 de frente para o
    # barco (o `−y` do Blender, que a câmara vê), +1 de costas a ir para a
    # pilha. Girar 180° troca o lado E a frente, e é por isso que os dois
    # levam o mesmo `s` — a mão direita fica à direita da pessoa nos dois.
    # O pé do boneco, no quadro do TRABALHADOR (o do `Dock.tscn`). Mutável
    # porque o operador do guincho fica noutro ponto do mesmo quadro; quem o
    # muda é o `boneco()`, e só durante ele.
    _base = [MX, MY]

    def _no_boneco(l, f, h_px, s):
        k = REGUA_DA_PESSOA
        bx, by, bz = pos(_base[0], _base[1], ALT)
        return (bx + s * l * k, by + s * f * k, bz + z(h_px * k))

    def _bloco(nome, l, f, h_px, tam, mat, s):
        """Uma caixa do boneco que não roda: `tam` = (lado, frente, alt_px)."""
        k = REGUA_DA_PESSOA
        return caixa(nome, _no_boneco(l, f, h_px, s),
                     (tam[0] * k, tam[1] * k, z(tam[2] * k)), mat)

    def _membro(nome, l, f, h_px, larg, comp_px, mat, s, frente=0.0,
                fora=0.0, desde_px=0.0):
        """Um membro pendurado do pivô (l, f, h_px), e o que ele faz.

        `frente` é o balanço em graus para a frente da pessoa (o passo), e
        `fora` o levantamento lateral, para o lado do `l` dele (o braço que
        segura a carga). `desde_px` começa a peça mais abaixo no MESMO eixo —
        é o que põe a bota no fim da perna sem a desalinhar dela.
        """
        k = REGUA_DA_PESSOA
        px, py, pz = _no_boneco(l, f, h_px, s)
        comp = z(comp_px * k)
        desde = z(desde_px * k)
        a, g = math.radians(frente), math.radians(fora)
        lado = 1.0 if l >= 0 else -1.0
        # A direção do pivô à ponta: para baixo, inclinada para a frente da
        # pessoa (`s` no eixo Y) ou para fora (o lado dela, que é `s·lado` no
        # X do Blender — ver o `s` acima).
        dx = s * lado * math.sin(g)
        dy = s * math.sin(a) * math.cos(g)
        dz = -math.cos(a) * math.cos(g)
        meio = desde + comp / 2.0
        centro = (px + dx * meio, py + dy * meio, pz + dz * meio)
        # O `(0, 0, −1)` da caixa roda até à direção: no X pelo passo, no Y
        # pelo levantamento — um membro só faz um dos dois neste boneco.
        if fora:
            rot = (0.0, math.degrees(math.atan2(-dx, -dz)), 0.0)
        else:
            rot = (math.degrees(math.atan2(dy, -dz)), 0.0, 0.0)
        return caixa(nome, centro, (larg[0] * k, larg[1] * k, comp), mat, rot=rot)

    # O PASSO, medido a 13 px de pessoa: a perna a 26° põe os dois pés a ~2 px
    # um do outro na tela, e menos do que isso funde-se num traço só. O braço
    # balança contra a perna do mesmo lado. Quadro 0 é a direita à frente, 1
    # os pés juntos e 2 a esquerda à frente; o ciclo é 0-1-2-1, e o 1 é também
    # o PARADO — a mesma pose, que é o que impede um salto ao parar.
    PASSO_PERNA, PASSO_BRACO = 26.0, 22.0
    QUADROS_DO_PASSO = (1.0, 0.0, -1.0)
    # A carga ao ombro direito, em cima dele: o pivô do braço que a segura é
    # o ombro, e ele sobe quase a pino para a mão chegar ao lado dela.
    OMBRO_L, OMBRO_H = 0.17, 20.6
    CARGA_ALT = 21.0              # o fundo da carga, pousado no ombro

    def _girar(pecas, giro):
        """Roda `pecas` à volta do pé do boneco (`_base`), em graus,
        anti-horário visto de cima. Pela `matrix_basis`, que se compõe da
        posição, da rotação e da escala já escritas; a `matrix_world` só se
        atualiza no próximo passo do grafo, e rodá-la aqui rodaria a de ontem."""
        if not giro:
            return pecas
        piv = Vector(pos(_base[0], _base[1], ALT))
        m = (Matrix.Translation(piv)
             @ Matrix.Rotation(math.radians(giro), 4, "Z")
             @ Matrix.Translation(-piv))
        for o in pecas:
            o.matrix_basis = m @ o.matrix_basis
        return pecas

    def boneco(sufixo, sexo, quadro, s, com_carga, base=None, bracos=None,
               giro=0.0, ombro="d"):
        """`base` muda o pé (no quadro do trabalhador) e `bracos` fixa o
        balanço dos dois braços — (direito, esquerdo), em graus para a frente —
        em vez de o tirar do passo: é a pose de quem mexe numa alavanca.

        `giro` roda o boneco inteiro à volta dos pés, em graus (anti-horário
        visto de cima). O `s` só sabe olhar para ±y; quem desengata no n2 olha
        para a pilha, em −x (`077`). `ombro` é o lado da carga: o direito
        de sempre, ou o esquerdo quando é ele que fica do lado da câmara."""
        _base[:] = list(base) if base is not None else [MX, MY]
        mulher = sexo == "m"
        sinal = QUADROS_DO_PASSO[quadro]
        pp, pb = PASSO_PERNA * sinal, PASSO_BRACO * sinal
        # Tronco um pouco mais estreito nela — é a única diferença de corpo; a
        # altura é a mesma, porque a régua da pessoa é uma só (`069`).
        tronco = 0.26 if mulher else 0.30
        p = []
        for lado, l in (("d", 0.055), ("e", -0.055)):
            perna = pp if lado == "d" else -pp
            p.append(_membro(f"tb_perna_{lado}{sufixo}", l, 0.0, 10.0,
                             (0.09, 0.15), 7.8, M["calca"], s, frente=perna))
            # A bota é o fim da MESMA perna, um pouco mais funda para a
            # frente: o pé. Começa 0,3 px dentro da calça — encostar daria a
            # face coplanar que este arquivo já pagou duas vezes.
            p.append(_membro(f"tb_bota_{lado}{sufixo}", l, 0.04, 10.0,
                             (0.10, 0.22), 2.5, M["bota"], s, frente=perna,
                             desde_px=7.5))
        p.append(_bloco(f"tb_quadril{sufixo}", 0.0, 0.0, 10.4,
                        (0.22, 0.15, 2.0), M["calca"], s))
        p.append(_bloco(f"tb_corpo{sufixo}", 0.0, 0.0, 15.5,
                        (tronco, 0.19, 11.5), M["colete"], s))
        # OS BRAÇOS SÃO MANGA DO COLETE, e não de outra cor: a 13 px uma
        # camisa azul ao lado da calça azul faria do boneco um borrão escuro
        # com um colete a flutuar no meio. A mão é a ponta de pele.
        meio = tronco / 2.0 + 0.035
        for lado, l in (("d", meio), ("e", -meio)):
            if com_carga and lado == ombro:
                    # O braço segura a carga PELO LADO DE FORA: a 118° ele chega
                # ao meio da face dela. A pino ficava DENTRO da caixa e só a
                # ponta saía por cima, a ler como uma antena.
                p.append(_membro(f"tb_braco_{lado}{sufixo}", l, 0.0, OMBRO_H,
                                 (0.07, 0.08), 7.5, M["colete"], s, fora=118.0))
                p.append(_membro(f"tb_mao_{lado}{sufixo}", l, 0.0, OMBRO_H,
                                 (0.075, 0.085), 1.8, M["pele"], s, fora=118.0,
                                 desde_px=7.3))
                continue
            braco = -pb if lado == "d" else pb
            if bracos is not None:
                braco = bracos[0] if lado == "d" else bracos[1]
            p.append(_membro(f"tb_braco_{lado}{sufixo}", l, 0.0, OMBRO_H,
                             (0.07, 0.08), 8.0, M["colete"], s, frente=braco))
            p.append(_membro(f"tb_mao_{lado}{sufixo}", l, 0.0, OMBRO_H,
                             (0.075, 0.085), 1.8, M["pele"], s, frente=braco,
                             desde_px=7.8))
        p.append(_bloco(f"tb_cabeca{sufixo}", 0.0, 0.0, 24.0,
                        (0.17, 0.16, 6.0), M["pele"], s))
        p.append(_bloco(f"tb_capacete{sufixo}", 0.0, 0.0, 28.2,
                        (0.24, 0.23, 4.4), M["capacete"], s))
        p.append(_bloco(f"tb_aba{sufixo}", 0.0, 0.07, 26.6,
                        (0.25, 0.34, 1.8), M["capacete"], s))
        if mulher:
            # A MARCA DELA É O CABELO: o rabo de cavalo sai por baixo da nuca
            # do capacete e desce até ao ombro — de costas é o que se vê
            # primeiro —, e duas mechas emolduram a cara, que é o que se vê de
            # frente, onde a cabeça tapa o rabo. Mais fundo do que a cabeça e
            # mais largo do que ela: nenhuma face encosta noutra.
            # ⚠️ A PRIMEIRA VERSÃO (0,08 de lado, 6 px) NÃO SE VIA: de costas
            # era um risco escuro na beira do colete, a ler como sombra, e de
            # frente nada. Mais grosso, mais comprido, e as mechas a descerem
            # até ao ombro, que é por onde a cabeça já não as tapa.
            p.append(_bloco(f"tb_rabo{sufixo}", 0.0, -0.12, 21.8,
                            (0.11, 0.10, 8.0), M["cabelo_preto"], s))
            for lado, l in (("d", 0.092), ("e", -0.092)):
                p.append(_bloco(f"tb_mecha_{lado}{sufixo}", l, 0.0, 23.4,
                                (0.035, 0.12, 6.0), M["cabelo_preto"], s))
        return _girar(p, giro)

    # ⚠️ OS QUADROS DE ANDAR SAÍRAM NO MESMO DIA EM QUE ENTRARAM (`076`). Ele
    # atravessava o tabuado com a caixa ao ombro, do barco à pilha; o Bruno
    # viu-o no jogo e pediu o que o porto de verdade faz: quem DESCARREGA é o
    # guindaste, «é ele que sempre fará isso», e o trabalhador opera-o. A ida
    # ao camião, nos serviços de mais de um turno, anda ao longo do píer — no
    # outro eixo —, e esses quadros fazem-se quando ela vier.
    #
    # O PARADO de cada sexo fica (os níveis 2 e 3 ainda o mostram, à beira do
    # costado), e o do homem continua a ser o `trabalhador`: a régua da fauna
    # e da página de escala.
    grupos["trabalhador"] = boneco("_hp", "h", 1, -1.0, False)
    grupos["trab_m_parado"] = boneco("_mp", "m", 1, -1.0, False)

    # O OPERADOR DO GUINCHO, ao pé do mastro do n1 e atrás do guincho, de
    # frente para o barco — é para onde olha quem manobra uma lingada. O ponto
    # vem do píer (`GUINCHO_N1`) e passa ao quadro do trabalhador pelo
    # deslocamento do nó dele no `Dock.tscn` (`DESLOC_TRABALHADOR`). Dois
    # quadros: os braços na alavanca, a empurrar e a puxar.
    for sexo in ("h", "m"):
        for q, bracos in enumerate(((48.0, 62.0), (70.0, 40.0))):
            grupos[f"trab_{sexo}_guincho_{q}"] = boneco(
                f"_{sexo}g{q}", sexo, 1, -1.0, False, base=OPERADOR_N1,
                bracos=bracos)
    _base[:] = [MX, MY]

    # AS CARGAS: um PNG à parte de cada uma, no ombro do quadro da volta — o
    # Godot põe-na por cima do boneco e ela desliza com ele. Quadros com a
    # carga dentro seriam três vezes os seis da volta; assim o boneco não sabe
    # o que leva. A carga não balança com o passo, porque o boneco também não:
    # a anca fica à mesma altura nos três quadros.
    def _carga(nome, tam, mat, extra=(), l=OMBRO_L):
        k_l, k_f, k_h = tam
        c = [_bloco(nome, l, 0.0, CARGA_ALT + k_h / 2.0,
                    (k_l, k_f, k_h), mat, 1.0)]
        return c + list(extra)

    # ⚠️ ELAS SAEM ONDE A IDA AO CAMIÃO COMEÇA, e no ombro ESQUERDO (`077`).
    # Desde a `076` ninguém as levava; no degrau 2 ele leva-as da pilha ao
    # camião, de costas e virado para terra (`−x`), e virado assim o ombro
    # direito fica do lado de longe — a caixa ficava atrás da cabeça. O nó
    # da carga é filho do do trabalhador e anda com ele.
    _dmx, _dmy = desloc_trabalhador()
    PEGA_N2 = (PILHA_N1[0] + 0.05, PILHA_N1[1] - 0.34)
    base_ida = (PEGA_N2[0] - _dmx, -PEGA_N2[1] - _dmy)
    _base[:] = list(base_ida)
    grupos["carga_caixa"] = _girar(_carga(
        "cg_caixa", CAIXA_PAPELAO, M["papelao"],
        # A fita que fecha a tampa: a linha escura é o que separa a caixa do
        # tabuado de madeira, que tem o mesmo matiz.
        [_bloco("cg_caixa_fita", -OMBRO_L, 0.0, CARGA_ALT + 5.7,
                (0.31, 0.05, 0.4), M["madeira_esc"], 1.0)], l=-OMBRO_L), 90.0)
    # ⚠️ O SACO LEVA UMA FAIXA IMPRESSA, e não é enfeite: a ráfia é creme e o
    # granel só atraca nos píeres 2 e 3 — no concreto do 3 a pilha creme
    # sumia, a 0,2 de Weber. Mudar a cor do saco tirava-lhe o que ele é; a
    # faixa verde é o que o saco de ráfia de verdade traz, e é ela que separa.
    # Mais estreita do que o saco e mais funda e alta do que ele: nenhuma face
    # encosta noutra.
    def _faixa(nome, l, f, h_fundo, tam):
        return _bloco(nome, l, f, h_fundo + tam[2] / 2.0,
                      (0.10, tam[1] + 0.02, tam[2] + 0.2), M["folha"], 1.0)

    grupos["carga_saco"] = _girar(_carga(
        "cg_saco", SACO_RAFIA, M["rafia"],
        [_faixa("cg_saco_f", -OMBRO_L, 0.0, CARGA_ALT, SACO_RAFIA)],
        l=-OMBRO_L), 90.0)

    # A IDA AO CAMIÃO (`077`): nos serviços de mais de um turno, a partir do
    # segundo, ele leva a carga da pilha ao flanco do camião encostado e volta.
    # Apanha-a À FRENTE da pilha, do lado da câmara: do sítio onde desengata,
    # do lado do mar, o caminho para terra passava por dentro dela. Todo
    # quadro nasce no MESMO ponto, como no andar da `075`: quem anda é o nó,
    # e o `Dock.gd` tira o fim do caminho do camião que o `Main` encostou.
    # Três quadros por sentido, o ciclo 0-1-2-1: vai de costas com a carga
    # (`giro` 90, para `−x`), volta de frente e vazio (`giro` −90, para `+x`).
    for sexo in ("h", "m"):
        for q in range(3):
            grupos[f"trab_{sexo}_leva_{q}"] = boneco(
                f"_{sexo}l{q}", sexo, q, 1.0, True, base=base_ida, giro=90.0,
                ombro="e")
            grupos[f"trab_{sexo}_volta_{q}"] = boneco(
                f"_{sexo}v{q}", sexo, q, 1.0, False, base=base_ida, giro=-90.0)
    _base[:] = [MX, MY]

    # QUEM DESENGATA, no nível 2 (`077`): o guindaste pousa a lingada na
    # pilha e ele solta-a. Fica AO LADO dela, do lado do mar e virado para
    # ela (`giro` 90: de `+y` para `−x`), um pouco para o lado da câmara — é
    # o lado em que o `Dock.tscn` o desenha por cima da pilha.
    # ⚠️ À FRENTE DELA TAPAVA-A: a primeira versão punha-o entre a pilha e a
    # câmara, e a 7 px de pessoa contra 8 de pilha a de papelão desaparecia
    # atrás dele. A 0,42 do centro fica a 0,05 da ponta do contêiner, o maior.
    # Dois quadros por sexo: à espera, de braços em baixo, e a soltar o
    # gancho, de braços no ar. Quem escolhe entre eles é o ciclo do guindaste.
    _dmx, _dmy = desloc_trabalhador()
    DESENGATE_N2 = (PILHA_N1[0] + 0.42, PILHA_N1[1] - 0.10)
    base_n2 = (DESENGATE_N2[0] - _dmx, -DESENGATE_N2[1] - _dmy)
    for sexo in ("h", "m"):
        for q, bracos in enumerate((None, (155.0, 145.0))):
            grupos[f"trab_{sexo}_pilha_{q}"] = boneco(
                f"_{sexo}d{q}", sexo, 1, 1.0, False, base=base_n2,
                bracos=bracos, giro=90.0)
    _base[:] = [MX, MY]

    # -- O PÓRTICO DO NÍVEL 3 E A EMPILHADEIRA (03/10, `docs/decisoes/079`) --
    #
    # Escolhas do Bruno, perguntadas antes do render: o pórtico tira a carga
    # do barco e pousa-a num PALLET a meio do cais; o trabalhador alocado leva
    # o pallet de empilhadeira pelo comprimento do píer, até à pilha da raiz —
    # ou ao camião, se ele estiver encostado. Os dois ao mesmo tempo: com o
    # pórtico, ~72% dos serviços do nível 3 duram UM turno, e o «primeiro
    # descarrega, depois leva» do n2 quase não aconteceria. O contêiner fica
    # como no n2: pousa no cais, e a máquina dele é outra passagem.
    #
    # ⚠️ O PÓRTICO GIRA COMO A LANÇA DO n2 E O CARRO RECOLHE AO LONGO DELA.
    # Um pórtico de verdade não gira, corre no trilho; este tem a torre fixa
    # perto da ponta, e o porão dos cascos fica para terra dela — medido com a
    # linha do carro a 0°, ela caía na PROA de todos os cascos e ao lado do
    # bote. Gira o mesmo de 18° (o porão, que o n2 já mediu) até ao ponto de
    # pouso, e o carro vem de 3,30 a ~1,8: é o que põe o pallet a meio do
    # cais, e o que separa o movimento dele do do n2.
    #
    # ⚠️ O SPREADER NÃO GIRA COM A LANÇA. Fica ao comprido do cais (`x`), que
    # é como vão os contêineres no convés dos cascos — e o rotador dele existe
    # para isso. O gancho debaixo dele leva os pallets.
    Y_RUN_N3 = -0.10                       # a linha da empilhadeira, em `y`
    # ⚠️ O POUSO FICA A 0,55 DA TORRE, e não mais perto: à espera, a
    # empilhadeira está 0,45 para trás dele, e a −0,39 a traseira dela
    # encostava na casa de máquinas do pórtico (vista na primeira prancha).
    POUSO_N3 = (-0.55, Y_RUN_N3)           # onde o pórtico pousa o pallet
    DEPOSITO_N3 = (-1.65, Y_RUN_N3)        # a frente da pilha, na raiz
    _px, _py = GX - POUSO_N3[0], GY - POUSO_N3[1]
    R_POUSO_N3 = math.hypot(_px, _py)
    GIRO_POUSO_N3 = math.degrees(math.atan2(_px, _py))
    GIRO_N3 = tuple(GIRO_N1[0] + (GIRO_POUSO_N3 - GIRO_N1[0]) * i / 6.0
                    for i in range(7))
    RAIO_N3 = tuple(R_N1 + (R_POUSO_N3 - R_N1) * i / 6.0 for i in range(7))
    R_PONTA_N3 = R_N1 + 0.25               # a ponta, à frente do carro no barco
    SPREADER_CIMA_N3 = TOPO - 0.90         # o fundo do spreader em viagem
    GANCHO_N3 = 0.16                       # do fundo do spreader ao bico
    LIG_N3 = 0.20                          # do bico ao tampo da carga
    TRAVA_N3 = 0.065                       # o contêiner prende-se aqui abaixo
    TIPOS_N3 = ("peixe", "caixa", "saco")  # o que vai em pallet

    def portico_n3(sufixo, giro, raio, fundo):
        """O pórtico do n3 girado `giro` graus para terra, com o carro a
        `raio` da torre e o fundo do spreader à altura `fundo`.

        ⚠️ A TORRETA E O TOPO DOS TIRANTES FICAM NO EIXO, em `TOPO`: é o
        pivô do nó `Lanca`, e o quadro de repouso ainda varre à volta dele.
        A plataforma de giro está lá pela mesma razão que no n2 (o D17)."""
        a = math.radians(giro)
        d = Vector((-math.sin(a), -math.cos(a), 0.0))
        rz = (0, 0, -giro)

        def em(r, h=0.0):
            return (GX + d.x * r, GY + d.y * r, TOPO + h)

        p = trelica("p3_lanca" + sufixo, em(0.20), em(R_PONTA_N3), 0.16,
                    M["laranja"], montantes=9, esp=0.048)
        p += trelica("p3_contra" + sufixo, em(-0.20), em(-1.25), 0.13,
                     M["laranja"], montantes=4, esp=0.046)
        p += [
            caixa("p3_giro" + sufixo, (GX, GY, TOPO - 0.02), (0.44, 0.44, 0.14),
                  M["laranja"], rz),
            caixa("p3_contrapeso" + sufixo, em(-1.42, -0.08), (0.34, 0.34, 0.38),
                  M["metal"], rz),
            caixa("p3_torreta" + sufixo, (GX, GY, TOPO + 0.50), (0.10, 0.10, 0.82),
                  M["metal"]),
            barra("p3_tirante_frente" + sufixo, (GX, GY, TOPO + 0.86),
                  em(R_PONTA_N3 - 0.45, 0.06), 0.030, M["metal"]),
            barra("p3_tirante_tras" + sufixo, (GX, GY, TOPO + 0.86),
                  em(-1.25, 0.06), 0.030, M["metal"]),
            caixa("p3_carro" + sufixo, em(raio, -0.16), (0.30, 0.19, 0.14),
                  M["metal"], rz),
        ]
        cx, cy, _ = em(raio)
        topo_cabo = TOPO - 0.22
        for i, lado in enumerate((-0.09, 0.09)):
            p.append(caixa("p3_cabo%d%s" % (i, sufixo),
                           (cx + lado, cy, (topo_cabo + fundo + 0.10) / 2.0),
                           (0.03, 0.03, topo_cabo - fundo - 0.10), M["metal"]))
        p.append(caixa("p3_spreader" + sufixo, (cx, cy, fundo + 0.05),
                       (0.70, 0.22, 0.10), M["amarelo"]))
        for sx in (-0.28, 0.28):
            p.append(caixa("p3_trava%+.2f%s" % (sx, sufixo),
                           (cx + sx, cy, fundo - 0.005), (0.10, 0.16, 0.12),
                           M["metal"]))
        p.append(caixa("p3_gancho" + sufixo, (cx, cy, fundo - GANCHO_N3 / 2.0),
                       (0.06, 0.06, GANCHO_N3), M["metal"]))
        return p

    # A CARGA EM PALLET: o pallet à régua da pessoa e, por cima, duas
    # colunas por duas das MESMAS caixas e sacos do n2 — a de papelão e a de
    # peixe em dois andares, os sacos em três, que são baixos.
    ANDARES_N3 = {"peixe": 2, "caixa": 2, "saco": 3}
    MEIO_N3 = {"peixe": (0.085, 0.058), "caixa": (0.072, 0.067),
               "saco": (0.087, 0.055)}

    def carga_pallet(nome, tipo, cx, cy, z0):
        mx_, my_ = MEIO_N3[tipo]
        colunas = [(sx * mx_, sy * my_) for sx in (-1, 1) for sy in (-1, 1)]
        return pallet_pecas(M, nome + "_pal", cx, cy, z0) + _lote(
            nome, tipo, cx, cy, z0 + altura_do_pallet() - 0.004, colunas,
            ANDARES_N3[tipo])

    def altura_carga(tipo):
        ch = CAIXA_N2[tipo][2]
        return altura_do_pallet() - 0.004 + ANDARES_N3[tipo] * (ch - 0.004) + 0.004

    def fundo_para(tipo, fundo_carga):
        """O fundo do spreader que pousa a carga do `tipo` com o fundo em
        `fundo_carga` — a conta inversa da `lingada_n3()`."""
        if tipo == "conteiner":
            return fundo_carga + CAIXA_N2["conteiner"][2] + TRAVA_N3
        return fundo_carga + altura_carga(tipo) + LIG_N3 + GANCHO_N3

    def lingada_n3(nome, tipo, hx, hy, fundo):
        """A carga pendurada do spreader cujo fundo está em `fundo`: o
        contêiner preso nas travas, ou o pallet em quatro cintas do gancho."""
        if tipo == "conteiner":
            ch = CAIXA_N2["conteiner"][2]
            return _lote(nome, tipo, hx, hy, fundo - TRAVA_N3 - ch,
                         ((0.0, 0.0),), 1)
        bico = fundo - GANCHO_N3
        topo = bico - LIG_N3
        base = topo - altura_carga(tipo)
        mx_, my_ = MEIO_N3[tipo]
        cl, cf = CAIXA_N2[tipo][0], CAIXA_N2[tipo][1]
        cantos = [(sx * (mx_ + cl / 2.0 - 0.01), sy * (my_ + cf / 2.0 - 0.01))
                  for sx in (-1, 1) for sy in (-1, 1)]
        cintas = [barra("%s_cinta%d" % (nome, i), (hx, hy, bico + 0.01),
                        (hx + ox, hy + oy, topo + 0.01), 0.016, M["madeira_esc"])
                  for i, (ox, oy) in enumerate(cantos)]
        return cintas + carga_pallet(nome, tipo, hx, hy, base)

    def carro_em(i):
        a = math.radians(GIRO_N3[i])
        return (GX - RAIO_N3[i] * math.sin(a), GY - RAIO_N3[i] * math.cos(a))

    CHAO_N3 = ALT_PIER - 0.004
    # O contêiner pousa num contêiner que já lá está, como no n2: a pilha
    # dele é um só, no ponto de pouso.
    FUNDO_POUSO_N3 = {t: CHAO_N3 for t in TIPOS_N3}
    FUNDO_POUSO_N3["conteiner"] = CHAO_N3 + CAIXA_N2["conteiner"][2] - 0.004

    # OS QUADROS DO PÓRTICO: o repouso (`lanca_n3`, o g0 — é ele que varre
    # sem trabalho), os seis passos do giro com o carro a recolher, e o
    # spreader em baixo no barco e no pouso, um por tipo.
    grupos["lanca_n3"] = portico_n3("", GIRO_N3[0], RAIO_N3[0], SPREADER_CIMA_N3)
    for i in range(1, 7):
        grupos["lanca_n3_g%d" % i] = portico_n3(
            "_g%d" % i, GIRO_N3[i], RAIO_N3[i], SPREADER_CIMA_N3)
    for tipo in TIPOS_N3 + ("conteiner",):
        grupos["lanca_n3_barco_" + tipo] = portico_n3(
            "_b" + tipo, GIRO_N3[0], RAIO_N3[0],
            fundo_para(tipo, FUNDO_BARCO[tipo]))
        grupos["lanca_n3_pouso_" + tipo] = portico_n3(
            "_p" + tipo, GIRO_N3[-1], RAIO_N3[-1],
            fundo_para(tipo, FUNDO_POUSO_N3[tipo]))
        hx, hy = carro_em(0)
        grupos["lingada_n3_%s_barco" % tipo] = lingada_n3(
            "l3_%s_b" % tipo, tipo, hx, hy, fundo_para(tipo, FUNDO_BARCO[tipo]))
        for i in range(7):
            hx, hy = carro_em(i)
            grupos["lingada_n3_%s_g%d" % (tipo, i)] = lingada_n3(
                "l3_%s_%d" % (tipo, i), tipo, hx, hy, SPREADER_CIMA_N3)
        hx, hy = carro_em(6)
        grupos["lingada_n3_%s_pouso" % tipo] = lingada_n3(
            "l3_%s_p" % tipo, tipo, hx, hy, fundo_para(tipo, FUNDO_POUSO_N3[tipo]))

    # A PILHA DO CONTÊINER, no ponto de pouso — como a do n2, um só.
    grupos["pilha_n3_conteiner"] = _lote(
        "pl3_cont", "conteiner", POUSO_N3[0], POUSO_N3[1], CHAO_N3,
        ((0.0, 0.0),), 1)

    # A CARGA NO GARFO, no ponto de pouso: em baixo (a que o pórtico larga e
    # a que entra na pilha) e levantada 0,30 m para andar. É o MESMO PNG que
    # o nó `Carga` mostra no chão depois de o spreader a largar — quem a
    # apanha é a empilhadeira, e a troca de nó não se vê.
    GARFO_ALTO_M = 0.30
    for tipo in TIPOS_N3:
        grupos["carga_n3_%s_baixo" % tipo] = carga_pallet(
            "cg3_%s_b" % tipo, tipo, POUSO_N3[0], POUSO_N3[1], CHAO_N3)
        grupos["carga_n3_%s_alto" % tipo] = carga_pallet(
            "cg3_%s_a" % tipo, tipo, POUSO_N3[0], POUSO_N3[1],
            CHAO_N3 + _vm(GARFO_ALTO_M))

    # A PILHA DE PALLETS na raiz: o primeiro na frente, no sítio exato onde a
    # empilhadeira larga o dela — os dois quadros coincidem, e o que ela traz
    # entra no lugar sem saltar —, um atrás dele e um por cima deste.
    passo_pilha = _hm(PALLET_M[0]) + 0.02
    for tipo in TIPOS_N3:
        x0, y0 = DEPOSITO_N3
        grupos["pilha_n3_" + tipo] = (
            carga_pallet("pl3_%s_0" % tipo, tipo, x0, y0, CHAO_N3)
            + carga_pallet("pl3_%s_1" % tipo, tipo, x0 - passo_pilha, y0, CHAO_N3)
            + carga_pallet("pl3_%s_2" % tipo, tipo, x0 - passo_pilha, y0,
                           CHAO_N3 + altura_carga(tipo)))

    # QUEM CONDUZ, sentado: o boneco de sempre com a anca no banco, as
    # coxas para a frente e os braços no volante. O tronco é o mesmo, porque a
    # régua da pessoa é uma só (`069`). Virado para `−x`, como a empilhadeira.
    def sentado(sufixo, sexo, base, assento_px):
        _base[:] = list(base)
        s = 1.0
        q = assento_px / REGUA_DA_PESSOA + 1.0 - 10.4
        tronco = 0.26 if sexo == "m" else 0.30
        p = [_bloco(f"ts_quadril{sufixo}", 0.0, 0.0, 10.4 + q,
                    (0.22, 0.15, 2.0), M["calca"], s)]
        for lado, l in (("d", 0.055), ("e", -0.055)):
            p.append(_bloco(f"ts_coxa_{lado}{sufixo}", l, 0.16, 10.0 + q,
                            (0.09, 0.30, 2.0), M["calca"], s))
        p.append(_bloco(f"ts_corpo{sufixo}", 0.0, 0.0, 15.5 + q,
                        (tronco, 0.19, 11.5), M["colete"], s))
        meio = tronco / 2.0 + 0.035
        for lado, l in (("d", meio), ("e", -meio)):
            p.append(_membro(f"ts_braco_{lado}{sufixo}", l, 0.0, OMBRO_H + q,
                             (0.07, 0.08), 8.0, M["colete"], s, frente=55.0))
            p.append(_membro(f"ts_mao_{lado}{sufixo}", l, 0.0, OMBRO_H + q,
                             (0.075, 0.085), 1.8, M["pele"], s, frente=55.0,
                             desde_px=7.8))
        p.append(_bloco(f"ts_cabeca{sufixo}", 0.0, 0.0, 24.0 + q,
                        (0.17, 0.16, 6.0), M["pele"], s))
        p.append(_bloco(f"ts_capacete{sufixo}", 0.0, 0.0, 28.2 + q,
                        (0.24, 0.23, 4.4), M["capacete"], s))
        p.append(_bloco(f"ts_aba{sufixo}", 0.0, 0.07, 26.6 + q,
                        (0.25, 0.34, 1.8), M["capacete"], s))
        if sexo == "m":
            p.append(_bloco(f"ts_rabo{sufixo}", 0.0, -0.12, 21.8 + q,
                            (0.11, 0.10, 8.0), M["cabelo_preto"], s))
            for lado, l in (("d", 0.092), ("e", -0.092)):
                p.append(_bloco(f"ts_mecha_{lado}{sufixo}", l, 0.0, 23.4 + q,
                                (0.035, 0.12, 6.0), M["cabelo_preto"], s))
        return _girar(p, 90.0)

    # A EMPILHADEIRA, no quadro do PÍER, com o pallet dela no ponto de pouso:
    # parada (sem ninguém, a do cais quando a doca não trabalha) e, por sexo,
    # com o garfo em baixo e levantado. Quem a anda é o nó, como o andar da
    # `075`: em câmara ortográfica um quadro deslocado é o mesmo render.
    pecas, _ = empilhadeira_pecas(M, "e3_parada", POUSO_N3[0], POUSO_N3[1],
                                  ALT_PIER)
    grupos["empilhadeira_n3"] = pecas
    for sexo in ("h", "m"):
        for alt, garfo in (("baixo", 0.0), ("alto", GARFO_ALTO_M)):
            pecas, (ax, ay, apx) = empilhadeira_pecas(
                M, "e3_%s_%s" % (sexo, alt), POUSO_N3[0], POUSO_N3[1],
                ALT_PIER, garfo)
            grupos["emp_%s_%s" % (sexo, alt)] = pecas + sentado(
                "_e%s%s" % (sexo, alt[0]), sexo, (ax, -ay), apx)
    _base[:] = [MX, MY]

    # A geometria do degrau, impressa para quem a confere. O `Dock.gd` não
    # copia nenhum destes números: o caminho até à pilha sai dos desenhos.
    print("degrau 3: giro %.2f..%.2f, carro %.3f..%.3f; pouso (%.2f, %.2f)"
          % (GIRO_N3[0], GIRO_N3[-1], RAIO_N3[0], RAIO_N3[-1], *POUSO_N3))

    # -- AS REFERÊNCIAS DE ESCALA: um pedestre e um carro (27/09, `069`) ------
    #
    # Não entram no mapa. São as réguas das pessoas e dos carros que o Bruno
    # quer pôr no mapa mais tarde («no futuro carros e pessoas devem ser
    # adicionadas»), e por agora só aparecem na página de escala, ao lado do
    # que já lá está — é o escopo que ele escolheu. Por isso NÃO saem com
    # `gerar_props_iso.py <pasta>` sem nomes (ver `REFERENCIAS`), e vivem em
    # `brport_vs/tools/referencia/`, que o export não leva e o `arte_orfa`
    # não varre: arte que o jogo não mostra não pode morar em `art/props`.
    #
    # O PEDESTRE é o corpo do trabalhador — a mesma régua, 1,5x o real — com
    # camisa e cabelo no lugar do colete e do capacete. Partilhar o corpo é o
    # ponto: a régua de uma pessoa é uma só.
    grupos["pedestre"] = [
        _t("ped_pernas", 5.0, (0.20, 0.17, 10.0), M["calca"]),
        _t("ped_corpo", 15.5, (0.30, 0.24, 11.5), M["azul"]),
        _t("ped_cabeca", 24.0, (0.18, 0.16, 6.0), M["pele"]),
        # O cabelo afunda 0,3 px na cabeça e é mais largo do que ela: faces
        # coplanares dariam o losango preto.
        _t("ped_cabelo", 27.6, (0.20, 0.18, 1.8), M["cabelo_preto"]),
    ]

    # O CARRO é EM TAMANHO REAL, como os camiões — a folga de 1,5x é só das
    # pessoas, que precisam dela para se ler. Um hatch das ruas brasileiras,
    # 3,9 x 1,7 x 1,5 m, pela régua do mundo (`PX_POR_METRO`, `METROS_POR_U`):
    # as alturas em metros passam por `_m()`, o chão por `METROS_POR_U`. É a
    # primeira peça do kit desenhada a partir de medidas reais.
    def _m(metros):
        return metros * PX_POR_METRO              # metros -> pixels do mapa
    def _faixa_z(de_m, ate_m):
        return z((_m(de_m) + _m(ate_m)) / 2.0), z(_m(ate_m) - _m(de_m))
    CAR_L, CAR_W = 3.9 / METROS_POR_U, 1.7 / METROS_POR_U
    zc, zt = _faixa_z(0.30, 0.95)
    carro = [caixa("car_corpo", (0.0, 0.0, zc), (CAR_L, CAR_W, zt), M["faixa"])]
    # A estufa afunda 2 cm no corpo e é mais estreita do que ele; o teto
    # afunda 2 cm nela e é mais largo — nenhuma face encosta noutra.
    zc, zt = _faixa_z(0.93, 1.42)
    carro.append(caixa("car_vidro", (-0.04, 0.0, zc),
                       (CAR_L * 0.55, CAR_W * 0.88, zt), M["vidro"]))
    zc, zt = _faixa_z(1.40, 1.50)
    carro.append(caixa("car_teto", (-0.04, 0.0, zc),
                       (CAR_L * 0.57, CAR_W * 0.92, zt), M["faixa"]))
    zc, zt = _faixa_z(0.0, 0.60)
    for sx in (-1.0, 1.0):
        for sy in (-1.0, 1.0):
            carro.append(caixa("car_roda%+d%+d" % (sx, sy),
                               (sx * CAR_L * 0.32, sy * CAR_W * 0.47, zc),
                               (0.12, 0.05, zt), M["pneu"]))
    grupos["carro"] = carro

    # -- COQUEIRO: copa e tronco separados, para o balanço ---------------
    #
    # ⚠️ O TRONCO ARQUEIA-SE NO EIXO, e a curva é do EIXO e não da SECÇÃO. A
    # `024` mediu que arredondar a secção de uma peça esbelta não paga — a 16x61
    # o cilindro ideal mede 0,741 contra 0,768 da caixa, 92% do caminho até ela
    # —, e deixou a outra metade em aberto: *curvar o eixo curvaria a silhueta*.
    #
    # Os segmentos SOBREPÕEM-SE de propósito (`FOLGA_TRONCO`). Encostados topo a
    # topo, cada junta seria um par de faces coplanares, e o z-buffer escolhe ao
    # acaso: é o losango preto que já mordeu duas vezes neste kit, aqui
    # multiplicado pelo número de juntas.
    tronco, topo_tronco = tronco_arqueado(M)
    grupos["coqueiro_tronco"] = tronco + [
        cone("raiz", (0, 0, 0.12), 0.3, 0.18, 0.25, 6, M["madeira_esc"])]
    # A copa era uma ESTRELA CHAPADA: sete cones retos saindo de um ponto, e a
    # esta escala lia como uma folha de papel recortada. Palmeira de verdade
    # tem folha que sai para cima e CAI — são dois segmentos por folha, e é a
    # dobra entre eles que faz a copa ter volume.
    # ⚠️ A COPA ANDA COM O TOPO DO TRONCO, senão ela fica a pairar ao lado de
    # uma palmeira torta. O `+0,14` em `y` NÃO é isso e fica onde está: ele é
    # anterior ao arco e desloca a copa contra a PROJEÇÃO (nesta câmera a
    # profundidade projeta-se para cima), não contra o caimento. O que a curva
    # acrescenta é o DELTA do topo, derivado da geometria em vez de escrito.
    desvio_copa = topo_tronco
    copa = []
    for i in range(8):
        a = i * (360.0 / 8) + (7 if i % 2 else 0)
        r = math.radians(a)
        cor = M["folha"] if i % 2 else M["folha_clara"]
        base = (0.30 * math.cos(r) + desvio_copa[0],
                0.30 * math.sin(r) + 0.14 + desvio_copa[1], 2.34 + desvio_copa[2])
        copa.append(cone("folha%d_a" % i, base, 0.16, 0.11, 0.62, 4, cor,
                         rot=(52, 0, a + 90)))
        ponta = (base[0] + 0.62 * math.cos(r), base[1] + 0.62 * math.sin(r),
                 base[2] + 0.20)
        copa.append(cone("folha%d_b" % i, ponta, 0.12, 0.015, 0.95, 4, cor,
                         rot=(104, 0, a + 90)))
    for j, (dx, dy) in enumerate([(0.09, 0.07), (-0.06, 0.10), (0.02, -0.09)]):
        copa.append(cone("coco%d" % j, (dx + desvio_copa[0], dy + desvio_copa[1],
                                       2.24 + desvio_copa[2]),
                         0.085, 0.085, 0.14, 6, M["madeira_esc"]))
    grupos["coqueiro_copa"] = copa

    # -- CENÁRIO solto ---------------------------------------------------
    # NÃO existem `conteiner` e `caixote` avulsos. Existiram, e saíram em
    # 31/08 depois de serem experimentados no pátio: o contêiner de 2,4
    # unidades é maior que a carga que o mapa já assa ao lado dele e lia como
    # peça de outro jogo; o caixote sozinho desaparecia atrás dos prédios e não
    # acrescentava nada ao lado da `pilha_caixotes`, que lê melhor.
    #
    # A carga do convés do píer é montada aqui mesmo, por `_no_conves`, e a do
    # pátio é desenhada pelo SVG do mapa. Prop avulso que ninguém carrega é
    # convite a engano — foi assim que `guindaste_base` e `guindaste_mastro`
    # sobreviveram meses depois de a torre ir para dentro do píer.
    # A boia e o marcador tinham DUAS peças cada, e é o resto da Etapa 2. Eles
    # são as peças MAIS PEQUENAS que o mapa mostra — 20×22 px a boia, 16×40 px
    # o marcador —, então aqui a conta da escala é ainda mais apertada do que
    # na carga do convés: o que entra tem de se ler por VALOR contra o laranja
    # e o amarelo, e nada mais se lê.
    #
    # Daí a faixa refletiva ser a peça principal das duas. Ela é o traço claro
    # sobre corpo escuro, que é o contraste que a Etapa 1 mediu como o que o
    # olho vê — razão, e não diferença. Uma argola de metal a 3px seria uma
    # mancha; uma faixa branca a 2px atravessada num corpo laranja lê-se.
    grupos["boia"] = [
        cone("b", (0, 0, 0.3), 0.34, 0.28, 0.6, 8, M["boia"]),
        cone("b_topo", (0, 0, 0.66), 0.1, 0.06, 0.3, 6, M["metal"]),
        # Faixa refletiva à altura da linha de água aparente.
        cone("b_faixa", (0, 0, 0.40), 0.322, 0.305, 0.10, 8, M["refletivo"]),
        # Argola: o anel por onde a corrente passa, POUSADA no topo do mastro.
        # Cone chato de 6 lados em vez de um toro — a esta escala o furo do
        # toro não sobrevive ao antisserrilhado e o que resta é um borrão.
        cone("b_argola", (0, 0, 0.80), 0.085, 0.085, 0.06, 6, M["metal"]),
    ]
    # ⚠️ Havia aqui uma quinta peça, uma corrente descendo para a água, e ela
    # foi RETIRADA depois de renderizada: ficava dentro do cone do corpo e não
    # se via um pixel dela. Peça invisível não é detalhe — é contagem inflada
    # e tempo de render pago por nada. A regra que fica: contar peças só vale
    # depois de olhar o render, porque o contador não sabe o que está tapado.
    grupos["marcador"] = [
        cone("m", (0, 0, 0.55), 0.26, 0.04, 1.1, 4, M["amarelo"]),
        caixa("m_base", (0, 0, 0.06), (0.5, 0.5, 0.12), M["metal"]),
        # DUAS faixas, e não uma: uma faixa só num corpo cónico lê como
        # emenda de fabrico. Duas leem como sinalização, que é o que ele é.
        cone("m_faixa_a", (0, 0, 0.42), 0.196, 0.183, 0.09, 4, M["refletivo"]),
        cone("m_faixa_b", (0, 0, 0.78), 0.116, 0.104, 0.08, 4, M["refletivo"]),
        # A lanterna no topo. É o único ponto quente do prop e ancora o olho
        # no alto de uma peça que, sem ele, afina até desaparecer.
        cone("m_luz", (0, 0, 1.13), 0.05, 0.035, 0.09, 6, M["luz_poste"]),
    ]

    # -- O ARMAZÉM ACABADO: um GALPÃO, e não a maior casa da vila --------
    #
    # ⚠️ ELE ERA UMA CASA, E A CAUSA ESTAVA NAS QUATRO PEÇAS QUE O DESENHAVAM
    # (05/09). Parede lisa `parede`, telhado de TELHA com fiada horizontal,
    # três janelas de moldura e travessa, e um portão que era a `porta()` do
    # kit esticada — a mesma função que faz a porta do escritório. Posto ao
    # lado das casas da vila, que têm parede clara e telhado de telha, ele
    # lia-se como o que era: a maior casa do bairro. O Bruno disse-o assim:
    # *"o galpão ainda lê como casinha e não como armazém — portão chato, sem
    # plataforma de carga, sem corrugado"*.
    #
    # É a IRMÃ do defeito que o `galpao_velho` teve até ao mesmo dia, e do
    # outro lado do par: lá o estado ANTES partilhava as peças do DEPOIS; aqui
    # o estado DEPOIS nunca teve vocabulário próprio nenhum. As duas metades
    # do par só se distinguem se cada uma souber o que é.
    #
    # As quatro trocas, por ordem de quanto cada uma vale na tela:
    #
    #   1. TELHADO DE ZINCO com a nervura no sentido da água. É a maior
    #      superfície do prop e é ela que grita "casa" num bairro de telha.
    #      A cor sai da telha por matiz E por valor, e o porquê de terem de
    #      ser os dois está medido no comentário do `zinco`, na paleta.
    #   2. PLATAFORMA DE CARGA. O plinto de 0,18 virou uma doca de 0,44 —
    #      altura de estrado de caminhão —, com deck saliente na face `+x`,
    #      defensas de borracha e dois degraus. O portão passou a assentar
    #      NELA, e é a soleira alta que diz que ali se carrega.
    #   3. CHAPA CORRUGADA nas duas faces visíveis, pela receita do
    #      contêiner: painéis de valor diferente, não vincos de relevo.
    #   4. PORTÃO DE ENROLAR, laranja, com o tambor por cima e as guias dos
    #      lados — no lugar do retângulo castanho chapado que havia.
    #
    # ⚠️ A ALTURA NÃO CRESCEU UM PIXEL, e isso é decisão e não acaso. A
    # cumeeira continua em 2,32 (0,44 de doca + 1,26 de parede + 0,62 de
    # telhado, contra os 1,70 + 0,62 de antes): a doca COME parte da parede em
    # vez de se empilhar debaixo dela. Empilhar teria devolvido metade do
    # defeito que o `ESCALA_PREDIO` de 03/09 existe para corrigir — os dois
    # prédios do pátio a levantarem-se ~4x a altura de uma casa e a derramarem
    # a silhueta por cima da estrada.
    DOCA_ALT = 0.44                   # altura de estrado de caminhão
    GAL = ((0, 0, 1.07), (3.4, 2.4, 1.26))
    paredes = [
        # A DOCA. `concreto_borda` (luminância 152) contra a parede (241) e
        # contra o asfalto do pátio (121): ela lê como faixa escura na base
        # dos dois lados, que é o que uma plataforma de carga é.
        caixa("gal_doca", (0, 0, DOCA_ALT / 2.0), (3.5, 2.5, DOCA_ALT),
              M["concreto_borda"]),
        caixa("gal_parede", *GAL, M["parede"]),
    ]

    # ⚠️ O DECK SAI PELA FACE `+x`, E NÃO PELA `-y`, POR CAUSA DA PEGADA.
    #
    # As duas faces são visíveis, mas o espaço à volta delas não é o mesmo, e
    # a diferença não se adivinha — mede-se em `porto_mapa_ancoras.json`. O
    # armazém está em `mx = 6,60`, `my = 13,45`, e a folga que sobra da pegada
    # de hoje é **0,236** unidades em `+my`, até o COTOVELO da rua em 14,68,
    # contra **0,746** em `+mx`, até o avental em 8,70.
    #
    # Traduzido em avanço de deck: em `-y` cabem 0,25 e nem um a mais; em `+x`
    # cabem 0,45 e ainda sobra meia unidade de cada lado. E foi CONFERIDO com
    # o defeito injetado — pôr a pegada em `my` nos 3,46 que este mesmo deck
    # exigiria do lado `-y` faz o bloco D2 reprovar com
    # *"a pegada entra no cotovelo da rua"*, e sair com código 1.
    #
    # A história ainda ajuda: em `+x` a plataforma dá para o avental, que é
    # por onde a carga do navio chega. Mas quem decidiu foi a régua.
    DECK_FRENTE = 2.08                # x da testa do deck
    paredes += [
        caixa("gal_deck", (1.84, 0.10, 0.18), (0.48, 2.00, 0.36),
              M["concreto_borda"]),
        # ⚠️ O TAMPO É UMA PEÇA À PARTE, e não é enfeite: tampo e testa da
        # mesma cor FUNDEM-SE — é a regra do caixote que era `madeira` num
        # tabuado de `madeira`, aplicada dentro de um prop. O `concreto`
        # (192) sobre o `concreto_borda` (152) é a aresta que dá volume ao
        # deck. E ele fica 0,04 ABAIXO do topo da doca, para que os dois
        # tampos não fiquem coplanares onde se sobrepõem — o losango preto
        # que este arquivo já registou três vezes.
        caixa("gal_deck_topo", (1.84, 0.10, 0.37), (0.52, 2.04, 0.06),
              M["concreto"]),
        # Dois degraus, encaixados um no outro e no deck: nada aqui encosta,
        # tudo se sobrepõe uma fração.
        caixa("gal_degrau0", (1.89, -1.155, 0.08), (0.30, 0.17, 0.16),
              M["concreto_borda"]),
        caixa("gal_degrau1", (1.89, -0.98, 0.16), (0.30, 0.24, 0.32),
              M["concreto_borda"]),
    ]
    # Defensas de borracha: na testa do deck e ao lado do portão. São o que
    # diz que um caminhão encosta aqui, e a esta escala funcionam pelo mesmo
    # motivo que as cantoneiras do contêiner — escuro lê-se a 3px.
    for i, u in enumerate((0.62, -0.42)):
        paredes.append(na_face("gal_defensa%d" % i, "+x",
                               (1.84, 0.10, 0.18), (0.48, 2.00, 0.36),
                               u, 0.0, 0.24, 0.22, 0.10, M["pneu"], -0.02))
    for i, u in enumerate((-0.90, 0.90)):
        paredes.append(na_face("gal_defensa_y%d" % i, "-y",
                               (0, 0, DOCA_ALT / 2.0), (3.5, 2.5, DOCA_ALT),
                               u, 0.0, 0.24, 0.22, 0.10, M["pneu"], -0.02))

    # O PORTÃO DE ENROLAR. Ele é uma FORMA e não um detalhe — 26px de largura
    # numa face de 49 —, e é a mesma lição que a porta do contêiner mediu.
    #
    # LARANJA, e a escolha é de composição: o telhado saiu de terracota, e
    # tirar o quente do prédio sem o repor deixaria o armazém cinzento no meio
    # de um pátio cinzento. O quente muda de sítio em vez de desaparecer, e
    # `laranja` é a cor que os guindastes do porto já usam — o prédio passa a
    # pertencer ao maquinário e não ao bairro.
    # ⚠️ A JUNTA ESCURA NO TOPO DA DOCA, e ela existe porque MEDIR desmentiu o
    # desenho. Na paleta a doca (`concreto_borda`, 152) fica bem abaixo da
    # parede (241) e devia separar-se sozinha; no render, com a luz da cena,
    # a doca sai a ~150 e os VINCOS da chapa saem a ~135 — a faixa da base e
    # a textura da parede caem na MESMA banda de valor, e o que devia ser o
    # degrau que diz "plataforma" lê-se como mais uma sombra do corrugado.
    # A saída é a mesma do contêiner: quem separa a esta escala não é o tom,
    # é a LINHA escura. Três pixels de `metal` no topo da doca fazem o que
    # 90 pontos de luminância na paleta não fizeram.
    #
    # ⚠️ ELA PARA ANTES DAS QUINAS E ANTES DO TOPO. A primeira versão tinha a
    # largura da doca (3,5) e o topo em 0,44, que é a altura da doca: as
    # pontas saíam para fora da quina como duas farpas escuras no vazio, e a
    # face de cima ficava COPLANAR com o tampo da doca — as duas armadilhas
    # que este arquivo já regista, apanhadas de uma vez só numa peça de 1px.
    paredes.append(na_face("gal_junta", "-y", (0, 0, DOCA_ALT / 2.0),
                           (3.5, 2.5, DOCA_ALT), 0.0, 0.17, 3.40, 0.06, 0.06,
                           M["metal"], 0.005))

    # ⚠️ A ALTURA DO PORTÃO SAI DA FITA DE VIDRO, e não do que parece bem
    # sozinho. A parede tem 1,26 e nela cabem, por esta ordem de baixo para
    # cima: soleira, portão, tambor, fita e beiral. A primeira versão pôs o
    # portão a 0,80 e a fita sobrou 1,5px de espessura média — o beiral come
    # os 0,10 de cima da parede (0,18 de aba × tan 30°) e o tambor comia por
    # baixo. Com 0,72 a fita ganha 3,9px e continua livre dos dois.
    V_PORTAO = (DOCA_ALT + 0.36) - GAL[0][2]      # soleira na doca, 0,72 de alto
    paredes += [
        na_face("gal_portao", "-y", *GAL, 0.0, V_PORTAO, 1.5, 0.72, 0.06,
                M["laranja"], -0.025),
    ]
    # As lâminas: DUAS faixas largas de valor diferente, e não seis riscos.
    # Um risco de 0,05 daria 0,9px e desapareceria no antisserrilhado.
    for i, dv in enumerate((0.20, -0.20)):
        paredes.append(na_face("gal_lamina%d" % i, "-y", *GAL, 0.0,
                               V_PORTAO + dv, 1.42, 0.18, 0.05,
                               M["laranja_esc"], -0.010))
    paredes += [
        # O tambor por cima e as guias dos lados: é o que distingue portão de
        # enrolar de retângulo pintado na parede.
        na_face("gal_tambor", "-y", *GAL, 0.0, V_PORTAO + 0.425, 1.70, 0.13,
                0.10, M["metal_claro"], 0.02),
        na_face("gal_guia0", "-y", *GAL, -0.80, V_PORTAO, 0.10, 0.78, 0.07,
                M["metal"], 0.015),
        na_face("gal_guia1", "-y", *GAL, 0.80, V_PORTAO, 0.10, 0.78, 0.07,
                M["metal"], 0.015),
    ]

    # A PORTA DA PLATAFORMA, na face `+x`: um deck sem porta é uma varanda.
    #
    # Ela é MENOR que o portão e não leva tambor, de propósito. Na primeira
    # versão as duas tinham quase a mesma largura e o mesmo desenho, e o prop
    # ampliado lia-se como GARAGEM de duas vagas — dois portões iguais em duas
    # faces é uma leitura, e um armazém com o portão principal e uma porta de
    # serviço é outra. Uma delas tem de mandar.
    paredes += [
        na_face("gal_porta_x", "+x", *GAL, 0.10, V_PORTAO, 0.80, 0.72, 0.06,
                M["laranja"], -0.025),
        na_face("gal_lamina_x0", "+x", *GAL, 0.10, V_PORTAO + 0.20,
                0.74, 0.18, 0.05, M["laranja_esc"], -0.010),
        na_face("gal_lamina_x1", "+x", *GAL, 0.10, V_PORTAO - 0.20,
                0.74, 0.18, 0.05, M["laranja_esc"], -0.010),
        na_face("gal_verga_x", "+x", *GAL, 0.10, V_PORTAO + 0.40,
                0.94, 0.08, 0.07, M["metal"], 0.015),
    ]

    # ⚠️ A JANELA ALTA CORRIDA SUBSTITUI AS TRÊS JANELAS DE MOLDURA, e a troca
    # é metade da leitura. Janela com moldura, travessa e peitoril é janela de
    # CASA, e três delas em fila numa parede branca são a assinatura de uma
    # casa — a `janela()` do kit desenha exatamente isso, e desenha bem. Um
    # galpão ilumina-se por uma fita de vidro rente ao beiral, que na tela é
    # uma linha clara de 3px e não três retângulos com sombra em volta.
    for face, larg in (("-y", 2.9), ("+x", 1.9)):
        paredes.append(na_face("gal_fita_%s" % face[1], face, *GAL,
                               0.0, 0.44, larg, 0.22, 0.05, M["vidro"], -0.03))

    # CHAPA CORRUGADA: painéis de valor, nos campos de parede que sobram.
    # Eles PARAM antes do portão e antes da fita de vidro — corrugado por cima
    # de abertura daria a grelha que a `telhado_duas_aguas` também evita.
    for i, u in enumerate((-1.49, -1.06, 1.06, 1.49)):
        paredes.append(na_face("gal_vinco%d" % i, "-y", *GAL, u, -0.16,
                               0.30, 0.78, 0.05, M["chapa_vinco"], -0.032))
    for i, u in enumerate((-0.98, -0.62, 0.92)):
        paredes.append(na_face("gal_vinco_x%d" % i, "+x", *GAL, u, -0.16,
                               0.28, 0.72, 0.05, M["chapa_vinco"], -0.032))

    grupos["galpao"] = paredes + [
        na_face("gal_calha", "-y", *GAL, 0.0, 0.64, 3.5, 0.09, 0.09,
                M["metal_claro"], 0.03),
    ] + telhado_duas_aguas("gal_tel", (0, 0, 1.70), (3.4, 2.4), 0.62,
                           M["zinco"], M["metal"], fiadas=0, nervuras=6,
                           mat_nerv=M["zinco_vinco"])
    # -- O ARMAZÉM EM RUÍNA: o casco do galpão, e não uma casa caída --------
    #
    # ⚠️ ELE FOI REFEITO EM 28/09 (`074`), E A CAUSA ERA A MESMA DO PRONTO EM
    # 05/09, DO OUTRO LADO. A ruína de 05/09 deixou de partilhar as peças do
    # acabado — e foi desenhada com o repertório da CASA: parede de alvenaria
    # lisa, telhado de duas águas de madeira, janela com tábua. Ao lado do
    # galpão pronto, que tem doca, chapa, zinco e portão de enrolar, ela lia
    # como a ruína de OUTRO prédio: o jogador comprava o armazém e via nascer
    # uma coisa que não estava lá antes. A ruína tem de ser o MESMO galpão com
    # menos galpão: a doca, a chapa, o zinco e o portão continuam, velhos.
    #
    # A leitura é a V3 que o Bruno aprovou com o ChatGPT
    # (`art_lab/plano/decisoes_da_frente/036`), refeita daqui porque a branch
    # dela nunca foi publicada: baia aberta, pórtico e contravento à vista,
    # lona, tijolo aparente, umidade, telhado incompleto e calha partida. A
    # composição foi perguntada ANTES do render, com uma prévia em ASCII
    # (`073`): o terço do lado do cais perdeu chapa e telhado, e mostra o
    # esqueleto de aço; o resto fica de pé, remendado.
    #
    # ⚠️ TUDO CABE NA PEGADA DO GALPÃO PRONTO (±2,16 em x, ±1,38 em y, antes
    # da escala do prédio — `PEGADAS` em `gerar_mapa_iso.py`). O D2 confere a
    # pegada DECLARADA e não a geometria: um tufo de capim a mais para a frente
    # iria parar no asfalto sem uma asserção a reprovar.
    K = ESCALA_PREDIO
    alv_gal = material_alvenaria_velha("alv_gal", PALETA["parede_suja"],
                                       PALETA["tijolo"], (0.48 * K, 0.80 * K))
    chapa = material_escorrido("chapa_ferr", PALETA["chapa_velha"],
                               PALETA["ferrugem"], escala=6.0, mundo=True)
    chapa_v = material_escorrido("chapa_ferr_v", PALETA["chapa_velha_vinco"],
                                 PALETA["ferrugem"], escala=6.0, mundo=True)
    zinco_v = material_escorrido("zinco_ferr", PALETA["zinco_velho"],
                                 PALETA["ferrugem"], escala=5.0, mundo=True,
                                 inicio=0.50, fim=0.72)
    portao_v = material_ripado("portao_velho", PALETA["laranja_velho"],
                               passo=0.19, eixo="Z", contraste=0.86,
                               junta=0.22, escuro_junta=0.55)
    lona = material_gasto("lona_gasta", PALETA["lona"], 4.0)
    capim = material("capim", PALETA["capim"])

    CORTE = 0.55                      # daqui para +x ficou só o esqueleto
    NAVE = ((-1.70 + CORTE) / 2.0, 0.0, 1.07)
    NAVE_T = (CORTE + 1.70, 2.40, 1.26)
    galv = [
        # A DOCA, a do galpão pronto — com a QUINA DE +x/−y PARTIDA. O pedaço
        # que ficou fica 0,01 abaixo do resto para as duas faces de cima não
        # ficarem coplanares onde se tocam.
        caixa("galv_doca", (-0.20, 0, 0.22), (3.10, 2.50, 0.44),
              M["concreto_borda"]),
        caixa("galv_doca_q", (1.545, 0.20, 0.215), (0.42, 2.10, 0.43),
              M["concreto_borda"]),
        caixa("galv_lasca", (1.56, -1.04, 0.13), (0.38, 0.30, 0.20),
              M["concreto_borda"], rot=(10, -16, 12)),
        caixa("galv_lasca2", (1.20, -1.33, 0.06), (0.20, 0.10, 0.12),
              M["concreto_borda"], rot=(0, 0, 25)),
        # O DECK de +x, com a ponta de −y caída: a laje partiu e a metade solta
        # desce para o chão.
        caixa("galv_deck", (1.84, 0.375, 0.18), (0.48, 1.45, 0.36),
              M["concreto_borda"]),
        caixa("galv_deck_topo", (1.84, 0.375, 0.37), (0.52, 1.49, 0.06),
              M["concreto"]),
        caixa("galv_deck_caido", (1.86, -0.62, 0.20), (0.46, 0.62, 0.08),
              M["concreto"], rot=(24, 4, 0)),
        # A NAVE que ficou de pé: um bloco só, de chapa enferrujada, e as peças
        # de fora vestem-no.
        caixa("galv_nave", NAVE, NAVE_T, chapa),
        # O interior, visto pelo esqueleto: a face +x da nave é o escuro de
        # DENTRO do galpão, e não uma parede.
        na_face("galv_dentro", "+x", NAVE, NAVE_T, 0.0, -0.05, 2.36, 1.14,
                0.02, M["vao"], 0.0),
    ]
    # A MURETA de alvenaria debaixo da chapa, que é onde o tijolo aparece. Ela
    # é PLACA na face −y, e não bloco: o bloco teria de ser furado pela baia.
    for i, (u, larg) in enumerate(((-0.845, 0.57), (0.845, 0.57))):
        galv.append(na_face("galv_mureta%d" % i, "-y", NAVE, NAVE_T, u, -0.47,
                            larg, 0.32, 0.06, alv_gal, 0.0))
    # A BAIA ABERTA, com o portão de enrolar fora do trilho e encostado à
    # frente dela. O tambor e a guia da esquerda ficaram; a da direita dobrou.
    #
    # ⚠️ O VÃO É MENOR DO QUE A PAREDE E TEM ALGUMA COISA A CORTÁ-LO. A ruína
    # de 05/09 aprendeu-o num portão: um vão escuro do tamanho de meia parede
    # não lê como abertura, lê como FALHA DE RECORTE no PNG. Quem o faz ler
    # como vão é o portão de través à frente dele.
    galv += vao_cego("galv_baia", "-y", NAVE, NAVE_T, 0.0, -0.22, 1.08, 0.84,
                     M, batente=False)
    galv += [
        # ⚠️ O PORTÃO FICA NO CHÃO, encostado, e não pendurado. A primeira
        # conta pendurava-o pela ponta do tambor, e a ponta de baixo caía
        # 0,17 abaixo do tampo da doca, a pairar em frente à face dela.
        caixa("galv_portao", (-0.52, -1.30, 0.55), (1.04, 0.05, 0.94),
              portao_v, rot=(-6, 9, 0)),
        na_face("galv_tambor", "-y", NAVE, NAVE_T, 0.0, 0.31, 1.26, 0.13,
                0.10, M["metal_claro"], 0.02),
        na_face("galv_guia0", "-y", NAVE, NAVE_T, -0.58, -0.20, 0.08, 0.84,
                0.07, M["metal"], 0.015),
        barra("galv_guia1", (-0.02, -1.24, 1.32), (0.06, -1.30, 0.70), 0.07,
              M["metal"]),
    ]
    # A CHAPA: os painéis de vinco que ficaram, e um que caiu (o escuro no
    # lugar dele). A receita do galpão pronto: painéis de VALOR, não relevo.
    for i, u in enumerate((-0.95, -0.70, 0.70)):
        galv.append(na_face("galv_vinco%d" % i, "-y", NAVE, NAVE_T, u, 0.12,
                            0.22, 0.86, 0.05, chapa_v, -0.032))
    galv.append(na_face("galv_buraco", "-y", NAVE, NAVE_T, 0.96, 0.22, 0.22,
                        0.62, 0.05, M["vao"], -0.040))
    # A CALHA PARTIDA: o troço da esquerda no sítio, o da direita pendurado.
    galv += [
        caixa("galv_calha", (-1.05, -1.275, 1.71), (1.40, 0.09, 0.09),
              M["metal_claro"]),
        barra("galv_calha2", (-0.33, -1.29, 1.70), (0.30, -1.33, 1.16), 0.09,
              M["metal_claro"]),
    ]
    # O TELHADO que sobra: zinco velho, com a lona azul presa por dois pneus
    # sobre o buraco da água da frente.
    galv += telhado_duas_aguas("galv_tel", (NAVE[0], 0, 1.70),
                               (NAVE_T[0], 2.40), 0.62, zinco_v, M["metal"],
                               fiadas=0, nervuras=4,
                               mat_nerv=material_escorrido(
                                   "zinco_ferr_v", PALETA["zinco_velho_vinco"],
                                   PALETA["ferrugem"], escala=5.0, mundo=True))
    ang_tel = math.degrees(math.atan2(0.62, 2.40 / 2.0 + 0.18))

    def na_agua(y):
        """O z do tampo da água da frente, no `y` pedido (y < 0)."""
        return 1.70 + 0.62 * (1.0 - abs(y) / 1.38) + 0.05

    galv.append(caixa("galv_lona", (0.02, -0.66, na_agua(-0.66) + 0.05),
                      (0.84, 0.92, 0.03), lona, rot=(ang_tel, 0, 0)))
    for i, (x, y) in enumerate(((-0.20, -0.52), (0.30, -0.86))):
        galv.append(cone("galv_pneu%d" % i, (x, y, na_agua(y) + 0.11), 0.14,
                         0.14, 0.07, 10, M["pneu"], rot=(ang_tel, 0, 0)))

    # O ESQUELETO, no terço do lado do cais: pilares, viga de beiral, tesoura
    # na empena e contravento em X. ⚠️ ARMAÇÃO SEM PEÇA HORIZONTAL FLUTUA: os
    # barrotes da ruína de 05/09 liam como gravetos espetados até ganharem
    # cumeeira e terça, e aqui quem as faz é o banzo e as terças. Metal escuro sobre o escuro de dentro não
    # se veria — quem o faz ler é o CHÃO claro da doca por baixo e o céu (o
    # fundo do mapa) por cima, que é o vazado que o guindaste já usa.
    PIL = 0.10
    for i, (x, y) in enumerate(((0.63, -1.14), (1.62, -1.14), (1.62, 1.14),
                                (0.63, 1.14))):
        # O pilar da quina partida desce até ao entulho: o concreto que o
        # segurava caiu, e é isso que o pé dele à vista conta.
        base = 0.05 if (x, y) == (1.62, -1.14) else 0.42
        galv.append(caixa("galv_pilar%d" % i, (x, y, (base + 1.70) / 2.0),
                          (PIL, PIL, 1.70 - base), M["metal"]))
    galv += [
        barra("galv_viga_a", (0.60, -1.14, 1.70), (1.67, -1.14, 1.70), 0.08,
              M["metal"]),
        barra("galv_viga_b", (0.60, 1.14, 1.70), (1.67, 1.14, 1.70), 0.08,
              M["metal"]),
        # A tesoura da empena: banzo, pernas, pendural e duas escoras.
        barra("galv_banzo", (1.62, -1.20, 1.70), (1.62, 1.20, 1.70), 0.07,
              M["metal"]),
        barra("galv_perna_a", (1.62, -1.26, 1.67), (1.62, 0.0, 2.30), 0.07,
              M["metal"]),
        barra("galv_perna_b", (1.62, 1.26, 1.67), (1.62, 0.0, 2.30), 0.07,
              M["metal"]),
        barra("galv_pendural", (1.62, 0.0, 1.70), (1.62, 0.0, 2.28), 0.05,
              M["metal"]),
        barra("galv_escora_a", (1.62, 0.0, 1.73), (1.62, -0.62, 1.98), 0.045,
              M["metal"]),
        barra("galv_escora_b", (1.62, 0.0, 1.73), (1.62, 0.62, 1.98), 0.045,
              M["metal"]),
        # As terças que ficaram: duas na água da frente, a da cumeeira e uma
        # atrás. Correm do telhado que sobra até à empena.
        barra("galv_terca0", (0.66, -0.46, 2.12), (1.70, -0.46, 2.12), 0.06,
              M["metal"]),
        barra("galv_terca1", (0.66, -0.92, 1.89), (1.70, -0.92, 1.89), 0.06,
              M["metal"]),
        barra("galv_terca2", (0.66, 0.0, 2.35), (1.70, 0.0, 2.35), 0.06,
              M["metal"]),
        barra("galv_terca3", (0.66, 0.70, 2.00), (1.70, 0.70, 2.00), 0.06,
              M["metal"]),
        # Contravento em X na empena, e o da frente PARTIDO: uma diagonal
        # inteira, a outra quebrada a meio e com o troço solto pendurado.
        barra("galv_cv_x0", (1.66, -1.08, 0.82), (1.66, 1.08, 1.64), 0.035,
              M["metal"]),
        barra("galv_cv_x1", (1.66, -1.08, 1.64), (1.66, 1.08, 0.82), 0.035,
              M["metal"]),
        barra("galv_cv_y0", (0.68, -1.19, 0.82), (1.56, -1.19, 1.64), 0.035,
              M["metal"]),
        barra("galv_cv_y1", (0.68, -1.19, 1.64), (1.10, -1.19, 1.25), 0.035,
              M["metal"]),
        barra("galv_cv_y2", (1.10, -1.21, 1.25), (1.20, -1.26, 0.86), 0.035,
              M["metal"]),
        # Uma chapa que ficou pendurada da viga, a balançar.
        caixa("galv_chapa_solta", (1.32, -1.23, 1.30), (0.34, 0.03, 0.68),
              chapa, rot=(0, 16, 0)),
        # O chão de dentro, sujo: o tampo da doca ao ar livre.
        caixa("galv_piso", (1.13, 0.125, 0.45), (1.10, 1.95, 0.02),
              M["piso_ruina"]),
    ]
    # A mureta do esqueleto, partida: na frente e na empena, com troços baixos.
    for i, (c, t) in enumerate((
            ((0.93, -1.185, 0.595), (0.46, 0.09, 0.33)),
            ((1.245, -1.185, 0.495), (0.17, 0.09, 0.13)),
            ((1.685, -0.57, 0.59), (0.09, 0.54, 0.34)),
            ((1.685, 0.02, 0.51), (0.09, 0.64, 0.18)),
            ((1.685, 0.72, 0.57), (0.09, 0.76, 0.30)))):
        galv.append(caixa("galv_mureta_e%d" % i, c, t, alv_gal))
    # A chapa do fundo, que se vê pelo esqueleto: três painéis de alturas
    # diferentes, e o terceiro já caiu.
    for i, (x, topo) in enumerate(((0.84, 1.60), (1.14, 1.22))):
        galv.append(caixa("galv_fundo%d" % i, (x, 1.165, (0.76 + topo) / 2.0),
                          (0.30, 0.05, topo - 0.76), chapa))
    # ENTULHO no chão de dentro: chapas de zinco caídas e tijolo.
    galv += [
        caixa("galv_ent_zinco0", (1.10, 0.30, 0.50), (0.62, 0.44, 0.03),
              zinco_v, rot=(6, -8, 18)),
        caixa("galv_ent_zinco1", (1.30, -0.28, 0.52), (0.52, 0.40, 0.03),
              zinco_v, rot=(-10, 12, -25)),
    ]
    for i, (x, y, rz) in enumerate(((0.92, -0.62, 10), (1.02, -0.72, 70),
                                    (1.44, -0.50, 35), (0.80, 0.70, -20))):
        galv.append(caixa("galv_tijolo%d" % i, (x, y, 0.50),
                          (0.16, 0.08, 0.07), M["tijolo"], rot=(0, 0, rz)))

    # O MATO: um arbusto que cresceu dentro do esqueleto, capim na base da
    # doca e nas frestas, e uma trepadeira a subir a ponta esquerda da chapa.
    galv += [cone("galv_arb_tronco", (1.20, 0.52, 0.72), 0.05, 0.03, 0.52, 6,
                  M["tronco"])]
    galv += copa_bolas("galv_arb", (((1.14, 0.46, 1.05), (0.30, 0.28, 0.22)),
                                    ((1.34, 0.62, 1.16), (0.24, 0.22, 0.20)),
                                    ((1.02, 0.66, 1.20), (0.20, 0.20, 0.17))),
                       M)
    for i, (pe, alt) in enumerate((((-1.45, -1.29, 0.0), 0.34),
                                   ((-0.10, -1.29, 0.0), 0.28),
                                   ((0.92, -1.29, 0.0), 0.30),
                                   ((2.04, -0.20, 0.0), 0.32),
                                   ((2.04, 0.95, 0.0), 0.26),
                                   ((1.50, -1.18, 0.0), 0.30),
                                   ((0.80, -0.95, 0.44), 0.26),
                                   ((1.60, 0.40, 0.46), 0.24))):
        galv += tufo("galv_capim%d_" % i, pe, alt, capim, rot_z=37.0 * i)
    # A TREPADEIRA é um manto CHATO colado à chapa, e não bolas: a primeira
    # candidata tinha cinco esferas de 0,17 de raio, e a luz da cena
    # sombreava cada uma como um volume — liam como balões verdes pregados
    # na parede. Com 0,02 de fundo a luz não tem por onde as arredondar.
    # ⚠️ `zt` e não `z`: um `z` num laço daqui torna-o LOCAL em todo o
    # `montar`, e a `z()` do módulo deixa de existir para as estacas lá em
    # cima — `UnboundLocalError` na primeira linha que a chama (`073`). É a
    # mesma razão de a copa deste kit se chamar `copa_bolas`: o coqueiro tem
    # uma lista `copa` neste `montar`, e uma `copa()` do módulo morria nela.
    for i, (x, zt, rx, rz) in enumerate(((-1.62, 0.56, 0.12, 0.16),
                                         (-1.46, 0.64, 0.10, 0.12),
                                         (-1.56, 0.84, 0.11, 0.14),
                                         (-1.40, 0.98, 0.09, 0.12),
                                         (-1.58, 1.08, 0.10, 0.13),
                                         (-1.47, 1.24, 0.09, 0.11),
                                         (-1.60, 1.34, 0.07, 0.10),
                                         (-1.38, 1.40, 0.06, 0.08),
                                         (-1.52, 1.50, 0.06, 0.08))):
        y = -1.275 if zt < 0.80 else -1.215
        galv += [bola("galv_trep%d" % i, (x, y, zt), (rx, 0.02, rz),
                      M["folha"] if i % 2 == 0 else M["folha_clara"])]
    grupos["galpao_velho"] = galv

    # -- ESCRITÓRIO nos dois estados. O armazém reaproveita galpao/galpao_velho.
    # A ruína não é o prédio "pintado de velho": é MENOS prédio — parede caída,
    # telhado furado. Um jogador tem de ver de longe que ali não se opera.
    ESC = ((0, 0, 0.78), (2.4, 2.0, 1.56))
    esc_base = [caixa("esc_plinto", (0, 0, 0.08), (2.5, 2.1, 0.16), M["parede_suja"]),
                caixa("esc_parede", *ESC, M["parede"])]
    esc_base += porta("esc_porta", "-y", *ESC, -0.55, 0.62, 0.98, M, base=0.16)
    grupos["escritorio"] = esc_base + [
        # Toldo sobre a entrada: é o que a referência usa para dizer
        # "aqui se atende alguém" sem escrever nada.
        na_face("esc_toldo", "-y", *ESC, -0.55, 0.42, 1.0, 0.10, 0.42,
                M["azul"], 0.18),
        na_face("esc_placa", "-y", *ESC, 0.45, 0.52, 1.05, 0.30, 0.07,
                M["amarelo"], 0.03),
    ] + janela("esc_j1", "-y", *ESC, 0.45, -0.05, 0.62, 0.44, M) \
      + janela("esc_j2", "+x", *ESC, -0.42, -0.05, 0.56, 0.44, M) \
      + janela("esc_j3", "+x", *ESC, 0.42, -0.05, 0.56, 0.44, M) \
      + telhado_duas_aguas("esc_tel", (0, 0, 1.56), (2.4, 2.0), 0.50,
                           M["telhado"], M["telha_cume"])
    # ⚠️ E A RUÍNA DO ESCRITÓRIO FALHAVA PELO LADO OPOSTO À DO ARMAZÉM. Ela
    # seguia a regra ("menos prédio") e mesmo assim não lia: eram duas caixas
    # cinzentas e um pau, e ampliada a 5x saía como uma PILHA DE LAJES DE
    # CONCRETO — nada ali dizia que aquilo tinha sido um edifício. Menos prédio
    # não é menos ARQUITETURA: o que faz o olho ler "ruína" e não "entulho" é
    # reconhecer o que falta, e para isso é preciso que alguma coisa fique de
    # pé com um vão dentro.
    #
    # Então fica um CANTO: a parede de trás inteira, a lateral inteira, a porta
    # onde ela estava e uma janela sem vidro. O resto desaba em degraus, e a
    # viga do telhado cai da parede que ficou para o entulho — é ela que liga
    # as duas metades e conta o que aconteceu.
    #
    # ⚠️ E EM 28/09 (`074`) O CANTO GANHOU O QUE O LIGA AO ESCRITÓRIO PRONTO.
    # De pé e limpo, ele era a ruína de um prédio QUALQUER: o jogador comprava
    # o escritório e via nascer uma casa de toldo azul e placa amarela que não
    # tinha nada a ver com o que lá estava. Agora o toldo está lá, rasgado e
    # pendurado sobre a porta, a placa caiu e está encostada à parede, e a
    # telha no chão é LARANJA, a do telhado que vai voltar. O desgaste é o
    # que a frente 4 pediu — reboco caído com o tijolo à vista, quina lascada,
    # umidade a subir da base, capim nas frestas — e uma árvore cresce lá
    # dentro, com a copa por cima das paredes: é a marca de abandono que se lê
    # de mais longe. A composição foi perguntada antes do render (`073`).
    #
    # ⚠️ A ÁRVORE NÃO PASSA DA CUMEEIRA DO PRONTO (2,09 antes da escala). O
    # nó do jogo é o mesmo nos dois estados, e o que a vila sabe sobre onde o
    # prédio a tapa sai do sprite: uma ruína mais alta do que o prédio pronto
    # taparia casas que o pronto deixa ver.
    alv_esc = material_alvenaria_velha("alv_esc", PALETA["parede_suja"],
                                       PALETA["tijolo"],
                                       (0.14 * ESCALA_PREDIO,
                                        0.50 * ESCALA_PREDIO))
    toldo = material_gasto("toldo_gasto", PALETA["toldo_velho"], 5.0)
    placa = material_gasto("placa_gasta", PALETA["placa_velha"], 6.0)
    capim_e = material("capim_esc", PALETA["capim"])
    ALT_R = 1.42
    # ⚠️ A PAREDE DE −y SAI 0,005 PARA FORA DO PISO. Com a face dela no mesmo
    # plano da borda do piso (y = −1,05), as duas ficavam coplanares na faixa
    # de 0,09 a 0,18 de altura, com duas cores diferentes a disputar o pixel.
    PAR_Y = ((0.42, -0.9425, 0.09 + ALT_R / 2.0), (1.56, 0.225, ALT_R))
    PAR_X = ((1.09, -0.19, 0.09 + ALT_R / 2.0), (0.22, 1.28, ALT_R))
    esc_r = [
        # O PISO. É a peça que diz "aqui havia um prédio" mesmo onde já não há
        # parede nenhuma, e é a razão de ele ter tom próprio: a ruína inteira
        # em `parede_suja` saía como um bloco cinzento só.
        caixa("ruina_piso", (0, 0, 0.09), (2.5, 2.1, 0.18), M["piso_ruina"]),
        # O CANTO QUE FICOU DE PÉ. As duas paredes são as duas que a câmera vê
        # — a de `-y` e a de `+x` (só essas duas faces existem para esta
        # projeção).
        # ⚠️ AS DUAS ENCAIXAM EM L, E NÃO SE SOBREPÕEM. Cruzadas no canto, as
        # duas faces `+x` ficavam NO MESMO PLANO por toda a altura, e o render
        # tinha uma BARRA PRETA de pé na quina, que se lia como uma coluna que
        # não existe. A de `-y` leva a quina inteira e a de `+x` começa onde
        # ela acaba.
        caixa("ruina_parede_y", *PAR_Y, alv_esc),
        caixa("ruina_parede_x", *PAR_X, alv_esc),
    ]
    # O que sobrou das outras duas, desfazendo-se para longe do canto.
    esc_r += parede_partida("ruina_qy", (-0.74, -0.9425, 0.09 + ALT_R / 2.0),
                            (0.76, 0.225, ALT_R), alv_esc, resto=0.20)
    esc_r += parede_partida("ruina_qx", (1.09, 0.72, 0.09 + ALT_R / 2.0),
                            (0.22, 0.55, ALT_R), alv_esc, resto=0.24)
    # A porta na parede de `-y` e a janela na de `+x`, cada uma na sua.
    esc_r += vao_cego("ruina_porta", "-y", *PAR_Y, -0.18, -0.20, 0.60, 0.94, M)
    # ⚠️ A JANELA AFASTA-SE DA QUINA, e isto custou um render. A `u = -0.30`
    # ficava a 0,05 do canto: o vão é uma placa RECUADA, e tão perto da quina
    # atravessa a parede vizinha e aparece do outro lado como uma barra preta.
    # Vão perto de quina precisa de meia largura de folga, e mais um pouco.
    esc_r += vao_cego("ruina_jan", "+x", *PAR_X, 0.06, 0.18, 0.52, 0.42, M)
    # A tábua pregada de través na janela: alguém ainda fecha isto.
    tabua = na_face("ruina_tabua", "+x", *PAR_X, 0.06, 0.20, 0.66, 0.09, 0.04,
                    M["madeira_velha"], 0.02)
    tabua.rotation_euler[0] = math.radians(-22)
    esc_r.append(tabua)
    esc_r += [
        # A viga do telhado, caída do alto do canto para o entulho. É ela que
        # liga as duas metades e conta o que aconteceu.
        caixa("ruina_viga", (0.30, -0.35, 0.90), (2.3, 0.13, 0.13),
              M["barrote"], rot=(0, 27, -22)),
        caixa("ruina_ripa", (0.10, -1.10, 0.42), (1.5, 0.09, 0.09),
              M["barrote"], rot=(0, 30, 8)),
        # A TELHA no chão é a do telhado que vai voltar: laranja, e partida em
        # cacos — uma telha inteira lia como tampa de caixa.
        caixa("ruina_telha", (-0.55, -1.06, 0.03), (0.30, 0.18, 0.05),
              M["telhado"], rot=(0, 0, -10)),
        caixa("ruina_telha1", (-0.20, -0.62, 0.22), (0.26, 0.20, 0.05),
              M["telhado"], rot=(6, 0, 34)),
        caixa("ruina_telha2", (0.62, 0.30, 0.22), (0.24, 0.18, 0.05),
              M["telhado"], rot=(-8, 4, -12)),
        # Entulho, todo do lado que caiu — amontoado num canto lê como pilha,
        # espalhado pelos quatro lê como sujeira.
        caixa("ruina_entulho_a", (-0.95, -0.62, 0.26), (0.55, 0.48, 0.34),
              alv_esc, rot=(0, 0, 14)),
        caixa("ruina_entulho_b", (-0.52, 0.10, 0.22), (0.44, 0.4, 0.26),
              alv_esc, rot=(0, 0, -20)),
        caixa("ruina_entulho_c", (0.20, 0.62, 0.19), (0.38, 0.34, 0.2),
              alv_esc, rot=(0, 0, 9)),
    ]
    for i, (x, y, rz) in enumerate(((-0.70, -0.30, 15), (-0.58, -0.36, 80),
                                    (0.40, -0.10, -30))):
        esc_r.append(caixa("ruina_tijolo%d" % i, (x, y, 0.215),
                           (0.16, 0.08, 0.07), M["tijolo"], rot=(0, 0, rz)))
    # O TOLDO, rasgado: preso ainda por cima da porta, a cair a pique, e uma
    # tira solta pendurada ao lado. É o azul do toldo pronto, desbotado.
    esc_r += [
        caixa("ruina_toldo", (0.24, -1.11, 1.08), (0.76, 0.40, 0.03), toldo,
              rot=(64, 9, 0)),
        caixa("ruina_toldo_tira", (0.58, -1.10, 0.86), (0.07, 0.02, 0.36),
              toldo, rot=(0, 6, 0)),
        barra("ruina_toldo_braco", (-0.10, -1.06, 1.26), (-0.12, -1.16, 1.22),
              0.035, M["metal"]),
        # A PLACA caiu e está encostada à parede, à direita da porta.
        caixa("ruina_placa", (0.85, -1.105, 0.155), (0.58, 0.04, 0.28), placa,
              rot=(-16, 0, 3)),
    ]
    # A ÁRVORE que cresce lá dentro: o tronco sai do piso atrás do canto, e a
    # copa aparece por cima das duas paredes.
    esc_r += [cone("ruina_arv_tronco", (-0.18, 0.28, 0.72), 0.08, 0.05, 1.08,
                   6, M["tronco"], rot=(4, -5, 0))]
    esc_r += copa_bolas("ruina_arv",
                        (((-0.30, 0.26, 1.46), (0.44, 0.40, 0.30)),
                         ((0.06, 0.06, 1.56), (0.34, 0.32, 0.26)),
                         ((-0.12, 0.50, 1.70), (0.30, 0.28, 0.22)),
                         ((-0.52, -0.08, 1.38), (0.28, 0.26, 0.21))), M)
    # O CAPIM: no piso, na base das paredes, e um tufo em cima da parede
    # partida, que é onde o mato mostra que ninguém mexe ali há anos.
    for i, (pe, alt) in enumerate((((-1.00, -1.10, 0.0), 0.30),
                                   ((1.26, -0.55, 0.0), 0.28),
                                   ((1.26, 0.40, 0.0), 0.24),
                                   ((-0.30, -0.95, 0.18), 0.26),
                                   ((0.70, -0.40, 0.18), 0.24),
                                   ((-0.65, -0.94, 0.40), 0.20))):
        esc_r += tufo("ruina_capim%d_" % i, pe, alt, capim_e, rot_z=53.0 * i)
    grupos["escritorio_ruina"] = esc_r

    # ⚠️ OS DOIS PRÉDIOS DO PÁTIO ENCOLHEM AQUI, e não nas literais deles.
    #
    # O primeiro playtest disse "o armazém e o escritório estão muito grandes,
    # além disso estão em cima da estrada". As duas frases são a mesma: medido,
    # o armazém ocupava 90% da largura do pátio e os dois levantavam-se ~4x a
    # altura de uma casa da vila. A BASE estava legal (o bloco D2 do teste de
    # design prova a pegada contra o asfalto desde 03/09) — o que derramava por
    # cima da estrada era a SILHUETA, porque em isométrico é a altura que
    # projeta para cima e para trás. Escala, não posição.
    #
    # Encolher pela escala do GRUPO, e não reescrevendo as literais, mantém
    # todas as proporções internas de pé: porta contra parede, janela contra
    # porta, beiral contra telhado. Reescrever à mão trinta números era trinta
    # chances de uma delas ficar por escalar.
    _encolher(grupos, ("escritorio", "escritorio_ruina", "galpao", "galpao_velho"),
              ESCALA_PREDIO)
    return grupos


# Quanto os dois prédios do pátio encolheram, e o alvo que o número serve:
#
#   antes: armazém 3,76 de largura em `mx` num pátio de 4,18 (90%), e 2,32 de
#          altura contra 0,54 de uma casa da vila (4,3x)
#   com 0,72: 2,71 de largura (65% do pátio) e 1,67 de altura (3,1x a casa)
#
# O sprite do armazém passa de 258px para ~150px, que é a escala do maior
# navio do jogo (146px) — antes ele era 1,8x o navio, o que é o que se lia
# como "muito grande".
ESCALA_PREDIO = 0.72


def _encolher(grupos: dict, nomes: tuple, k: float) -> None:
    """Escala uniforme, em torno da origem do mundo, dos grupos pedidos.

    ⚠️ CADA OBJETO UMA VEZ SÓ, e a razão MUDOU sem a regra mudar. Até 05/09
    `galpao` e `galpao_velho` partilhavam a lista de paredes, e o `set()` era
    o que impedia que as peças comuns fossem escaladas duas vezes e saíssem a
    `k²` — um armazém com paredes menores que o próprio telhado, sem erro
    nenhum a apontá-lo. Hoje os quatro grupos têm geometria própria (partilhar
    peças entre o estado ANTES e o DEPOIS era o defeito, não a economia), mas
    o `set()` fica: é ele que deixa acrescentar um grupo a esta chamada sem ter
    de saber o que ele reaproveita.

    Escalar em torno da origem — `location` e `scale` pelo mesmo fator — mantém
    a base assente no chão, porque a base está em z≈0. Escalar só o `scale`
    deixaria as peças nos lugares antigos e o prédio desmontava-se.
    """
    unicos = set()
    for nome in nomes:
        for o in grupos.get(nome, []):
            unicos.add(o)
    for o in unicos:
        o.location = tuple(c * k for c in o.location)
        o.scale = tuple(c * k for c in o.scale)


# ---------------------------------------------------------------- cena
# ---------------------------------------------------------- contorno (Etapa 3)
CONTORNO_COR = (0.09, 0.10, 0.13)     # o escuro da cena, nunca preto puro
CONTORNO_FORCA = 0.45                 # quanto o traço escurece o que está por baixo
CONTORNO_PERTO, CONTORNO_LONGE = 36.0, 44.0   # a faixa de profundidade útil
CONTORNO_LIMIAR = (0.10, 0.34)        # onde a rampa abre e fecha
# ⚠️ QUANTOS PIXELS O TRAÇO RECUA PARA DENTRO DA SILHUETA, e é o número que faz
# esta função não ser o Freestyle outra vez.
#
# A primeira versão multiplicava a borda pelo alfa cru, e o resultado foi
# EXATAMENTE o defeito que fez rejeitar o Freestyle, por outro caminho: os
# montantes da treliça da lança têm 2px, o Sobel dá 1px de traço de cada lado,
# e a peça inteira virou traço. Medido, a silhueta não mudou um pixel (1133
# opacos antes e depois — os vazados ficaram abertos, que era o critério
# escrito), e mesmo assim a lança passou de LARANJA a castanho-escuro: o
# Freestyle fechava o vazado, este apagava a cor. O critério da etapa estava
# incompleto.
#
# Erodir o alfa 1px antes de multiplicar resolve pela raiz, e resolve-o pela
# pergunta certa: uma peça de 2px não tem interior nenhum depois da erosão,
# logo não recebe traço; uma face grande perde só o pixel da beira, e o traço
# assenta 1px para dentro dela. É a "espessura proporcional à profundidade" que
# o plano pedia, substituída pelo que nesta câmera de facto varia — não a
# distância, que é fixa em ortográfica, mas o TAMANHO DA PEÇA na tela.
CONTORNO_RECUO = 2


def ligar_contorno_compositor(cena) -> None:
    """Contorno pelos passes de normal e de Z — a Etapa 3, TESTADA E REJEITADA.

    ⚠️ **ISTO NÃO ESTÁ LIGADO, E NÃO É PARA LIGAR.** Fica atrás de `--contorno`
    como a PROVA, que se refaz em vinte segundos:

        python3 tools/gerar_props_iso.py --contorno /tmp/x lanca_n3 galpao

    A Etapa 3 do plano de arte pedia contorno pelo compositor depois de o
    Freestyle ser rejeitado, e a razão da rejeição parecia ser a técnica: o
    Freestyle desenha uma LINHA GEOMÉTRICA de espessura fixa, e numa treliça
    com montantes de 0,045 a linha é mais larga que a peça — os vazados fecham
    e a treliça vira uma barra. Um traço nascido da IMAGEM não pode fechar um
    vazado, porque onde há vazado há fundo e o fundo tem alfa zero. A ideia
    estava certa e o resultado medido diz que o problema era outro.

    **O que se mediu, nas duas peças pelas quais o plano manda medir:**

    | | treliça da lança | parede do galpão |
    |---|---|---|
    | sem contorno | saturação 117,9 | saturação 53,0 · desvio 29,7 |
    | traço rente à silhueta | **93,3 (−21%)** | 47,0 · 24,9 |
    | traço recuado 2px | 112,1 (−5%) | 46,9 · **25,6 (−14%)** |

    Duas conclusões, e a segunda é a que importa:

    1. **Na peça FINA o traço apaga a COR, não a forma.** A silhueta não mudou
       um pixel (1133 opacos com e sem, os vazados abertos — o critério escrito
       na Etapa 3 passava), e mesmo assim a lança saiu de laranja a castanho.
       O Freestyle fechava o vazado; este descolore. O critério da etapa media
       a metade errada. Recuar o traço 2px salva a cor — e, salvando-a, deixa
       a lança exatamente como estava: na peça fina o contorno ou estraga ou
       não existe.
    2. **Na peça GRANDE o traço redesenha o que o desenho já dizia.** E é aqui
       que a etapa morre, por uma razão que não é de técnica nenhuma: **este
       projeto desenha o detalhe COM fronteiras de valor** — o corrugado do
       contêiner e o do armazém, as fiadas do telhado, as cantoneiras — porque
       a essa escala relevo não sobrevive ao antisserrilhado. Um filtro de
       borda procura exatamente fronteiras de valor. Ele encontra o desenho e
       desenha-o outra vez por cima: a chapa corrugada, que é uma superfície
       com nervura, passa a ler-se como um gradeado, e o desvio local (que é a
       textura da parede) CAI 14% em vez de subir.

    E há um terceiro facto que fecha a questão, e estava escrito ao lado desde
    a Etapa 2: o rig de três pontos do `preparar_cena()` tem um CONTRALUZ que
    existe para isto — *"põe um fio de luz na quina de cima, e é esse fio que
    separa a peça do fundo; faz o trabalho de um contorno desenhado sem ter de
    desenhar contorno nenhum"*. Ele separa a silhueta sem tocar nas fronteiras
    de valor de dentro do prop, que é precisamente o que o contorno não
    consegue.

    Como se monta, e por que cada passo (o desenho está correto — o que falhou
    foi a ideia, não a construção):

    · **Sobel na NORMAL** apanha os vincos — a quina entre duas faces do mesmo
      objeto, que é onde o volume se lê. É o que o Freestyle chamava `crease`
      e que estava desligado lá, porque com espessura fixa ele engordava tudo.
    · **Sobel no Z** apanha a silhueta e as bordas de oclusão — o mastro à
      frente da lança, o píer à frente da água. O Z vem em unidades de mundo e
      o fundo vem em 1e10, então passa por um `Map Range` com `clamp`: o fundo
      encosta em 1,0 e o degrau prop→fundo vira o traço mais forte de todos.
    · **O máximo dos dois**, e não a soma: somar dá traço duplo onde vinco e
      silhueta coincidem, que é justamente na quina de cima de cada peça.
    · **Multiplicado pelo ALFA do próprio render.** É a peça-chave. O Sobel
      centra-se na borda, então metade do traço cai FORA da silhueta, em
      pixel transparente; sem esta multiplicação o prop ganharia um halo
      escuro que o mapa mostraria como sujeira à volta de tudo. Com ela o
      traço é INTERNO, que é o que um sprite chapado pede.

    O plano pedia *"espessura proporcional à profundidade"*, e isso não se
    aplica aqui: a câmera é ORTOGRÁFICA e todos os props são renderizados à
    mesma escala de mundo→pixel — é o contrato da projeção. Não há perto e
    longe para variar; há uma escala só. O que de facto varia, e por isso é o
    que o `CONTORNO_RECUO` usa, é o TAMANHO DA PEÇA na tela.
    """
    vl = cena.view_layers[0]
    vl.use_pass_normal = True
    vl.use_pass_z = True

    cena.use_nodes = True
    cena.render.use_compositing = True
    nt = cena.node_tree
    for no in list(nt.nodes):
        nt.nodes.remove(no)

    camadas = nt.nodes.new("CompositorNodeRLayers")
    saida = nt.nodes.new("CompositorNodeComposite")

    def _sobel(entrada):
        f = nt.nodes.new("CompositorNodeFilter")
        f.filter_type = "SOBEL"
        f.inputs["Fac"].default_value = 1.0
        nt.links.new(entrada, f.inputs["Image"])
        return f.outputs["Image"]

    # Z -> faixa útil, com o fundo (1e10) preso em 1,0.
    faixa = nt.nodes.new("CompositorNodeMapRange")
    faixa.use_clamp = True
    faixa.inputs["From Min"].default_value = CONTORNO_PERTO
    faixa.inputs["From Max"].default_value = CONTORNO_LONGE
    faixa.inputs["To Min"].default_value = 0.0
    faixa.inputs["To Max"].default_value = 1.0
    nt.links.new(camadas.outputs["Depth"], faixa.inputs["Value"])

    borda_z = _sobel(faixa.outputs["Value"])
    borda_n = _sobel(camadas.outputs["Normal"])

    maior = nt.nodes.new("CompositorNodeMixRGB")
    maior.blend_type = "LIGHTEN"
    maior.inputs["Fac"].default_value = 1.0
    nt.links.new(borda_z, maior.inputs[1])
    nt.links.new(borda_n, maior.inputs[2])

    # A rampa é o que separa "borda" de "ruído do denoiser". Aberta demais,
    # cada mancha do `material_gasto` vira um risco.
    rampa = nt.nodes.new("CompositorNodeValToRGB")
    rampa.color_ramp.elements[0].position = CONTORNO_LIMIAR[0]
    rampa.color_ramp.elements[1].position = CONTORNO_LIMIAR[1]
    nt.links.new(maior.outputs["Image"], rampa.inputs["Fac"])

    # ⚠️ O TRAÇO SÓ VIVE ONDE HÁ ESPAÇO PARA ELE, e é isto que separa este
    # contorno do Freestyle. Ver `CONTORNO_RECUO` e a docstring.
    recuo = nt.nodes.new("CompositorNodeDilateErode")
    recuo.mode = "STEP"
    recuo.distance = -CONTORNO_RECUO
    nt.links.new(camadas.outputs["Alpha"], recuo.inputs["Mask"])

    dentro = nt.nodes.new("CompositorNodeMixRGB")
    dentro.blend_type = "MULTIPLY"
    dentro.inputs["Fac"].default_value = 1.0
    nt.links.new(rampa.outputs["Image"], dentro.inputs[1])
    nt.links.new(recuo.outputs["Mask"], dentro.inputs[2])

    forca = nt.nodes.new("CompositorNodeMixRGB")
    forca.blend_type = "MULTIPLY"
    forca.inputs["Fac"].default_value = 1.0
    forca.inputs[2].default_value = (CONTORNO_FORCA,) * 3 + (1.0,)
    nt.links.new(dentro.outputs["Image"], forca.inputs[1])

    traco = nt.nodes.new("CompositorNodeMixRGB")
    traco.blend_type = "MIX"
    traco.inputs[2].default_value = CONTORNO_COR + (1.0,)
    nt.links.new(forca.outputs["Image"], traco.inputs["Fac"])
    nt.links.new(camadas.outputs["Image"], traco.inputs[1])

    # ⚠️ E O ALFA TEM DE SER REPOSTO À MÃO. O `MixRGB` devolve o alfa da
    # entrada 1, que aqui é a imagem — mas o traço passou por multiplicações
    # que mexem no canal alfa dos nós intermédios, e sem este `Set Alpha` o
    # PNG sai com a silhueta comida na borda, que é exatamente onde o traço
    # está. O `asset_validator` apanharia isto como recorte.
    repor = nt.nodes.new("CompositorNodeSetAlpha")
    repor.mode = "REPLACE_ALPHA"
    nt.links.new(traco.outputs["Image"], repor.inputs["Image"])
    nt.links.new(camadas.outputs["Alpha"], repor.inputs["Alpha"])
    nt.links.new(repor.outputs["Image"], saida.inputs["Image"])


def preparar_cena():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    cena = bpy.context.scene
    cena.render.engine = "CYCLES"
    cena.cycles.device = "CPU"
    # 24 amostras chegavam para um sol duro e NÃO chegam para luz de área: o
    # rig de três pontos saía granulado. Com o denoiser ligado, 64 sai limpo e
    # mais barato que 128 sem ele.
    cena.cycles.samples = 64
    cena.cycles.use_denoising = True
    cena.render.film_transparent = True
    cena.render.resolution_x = cena.render.resolution_y = RESOLUCAO

    # RIG DE TRÊS PONTOS.
    #
    # Era um sol só, com sombra dura: as três faces de um volume saíam em três
    # tons e parava aí — o mesmo que o mapa em SVG já faz à mão. Serve, mas é o
    # teto. O que este rig acrescenta são duas coisas que o sol sozinho não dá:
    #
    #   o PREENCHIMENTO frio tira a sombra do preto morto (sombra de porto ao
    #   ar livre é azul, porque quem a ilumina é o céu, não o sol);
    #
    #   o CONTRALUZ põe um fio de luz na quina de cima, e é esse fio que separa
    #   a peça do fundo — faz o trabalho de um contorno desenhado sem ter de
    #   desenhar contorno nenhum.
    #
    # A chave mantém o ângulo do mapa (48°/28°): é dela que sai a sombra
    # própria das faces, e ela tem de concordar com o SVG ao lado.
    bpy.ops.object.light_add(type="SUN", location=(6, -8, 12))
    chave = bpy.context.active_object
    chave.data.energy = 3.4
    chave.data.angle = math.radians(1.6)   # beirada macia, não borrada
    chave.data.color = (1.0, 0.93, 0.82)
    chave.rotation_euler = (math.radians(48), 0, math.radians(28))

    chave.name = "luz_chave"

    bpy.ops.object.light_add(type="AREA", location=(-7, 5, 5))
    enchimento = bpy.context.active_object
    enchimento.name = "luz_enchimento"
    # 260 lavava a forma: com o preenchimento forte demais as três faces do
    # volume voltavam a ter quase o mesmo tom, que é justamente o que a chave
    # existe para evitar. Ele é para tirar o preto da sombra, não para iluminar.
    enchimento.data.energy = 150.0
    enchimento.data.size = 12.0
    enchimento.data.color = (0.62, 0.75, 1.0)
    enchimento.rotation_euler = (math.radians(58), 0, math.radians(-135))

    bpy.ops.object.light_add(type="AREA", location=(4, 7, 6))
    contraluz = bpy.context.active_object
    contraluz.name = "luz_contraluz"
    contraluz.data.energy = 420.0
    contraluz.data.size = 6.0
    contraluz.data.color = (1.0, 0.97, 0.88)
    contraluz.rotation_euler = (math.radians(120), 0, math.radians(35))

    cena.world = bpy.data.worlds.new("mundo")
    cena.world.use_nodes = True
    fundo = cena.world.node_tree.nodes["Background"]
    fundo.inputs[0].default_value = (0.60, 0.68, 0.80, 1)
    fundo.inputs[1].default_value = 0.42

    bpy.ops.object.camera_add()
    cam = bpy.context.active_object
    cam.data.type = "ORTHO"
    cam.data.ortho_scale = ESCALA_ORTO
    cam.rotation_euler = (math.radians(ROT_X), 0.0, math.radians(ROT_Z))

    # A direção de vista NÃO pode sair de cam.matrix_world: ela só é recalculada
    # no próximo depsgraph, e logo após mexer no rotation_euler ainda é a antiga
    # — a câmera vai parar longe do alvo e o render sai vazio.
    rx, rz = math.radians(ROT_X), math.radians(ROT_Z)
    dx, dy, dz = 0.0, math.sin(rx), -math.cos(rx)
    d = (dx * math.cos(rz) - dy * math.sin(rz),
         dx * math.sin(rz) + dy * math.cos(rz), dz)
    # A câmera mira a ORIGEM DO CHÃO, não o meio do prop: assim o centro do
    # quadro corresponde a p(mx, my, 0) do mapa, e posicionar um prop na cena
    # vira uma subtração de meio quadro em vez de um ajuste no olho.
    cam.location = tuple(-d[i] * 40.0 for i in range(3))
    bpy.context.view_layer.update()
    cena.camera = cam
    return cena


# ---------------------------------------------------------------- sombra
# Props que se APOIAM no chão do mapa e por isso ganham sombra de contato. Os
# que ficam sobre a água (píer, barcos, boia), no ar (copa, lança) ou em cima
# de outro prop (o trabalhador, que fica no tabuado) ficam de fora: a sombra
# deles cairia num plano que não existe no lugar onde o jogo os desenha.
# `marcador` SAIU daqui em 31/08, e `conteiner`/`caixote` deixaram de existir.
# O marcador é a baliza da Zona de Espera: ela fica na ÁGUA, e uma sombra de
# contato dura projetada na água lê como uma mancha de óleo — que foi
# exatamente o que apareceu na captura. O próprio comentário abaixo já dizia
# que o que fica sobre a água fica de fora; o marcador tinha ficado dentro.
SOMBRA = {"galpao", "galpao_velho", "escritorio", "escritorio_ruina",
          "coqueiro_tronco"}
SOMBRA_COR = (0.06, 0.09, 0.13)   # azulada: sombra ao ar livre é céu, não breu
SOMBRA_FORCA = 0.42
SOMBRA_LIMIAR = 0.06              # abaixo disto é véu de oclusão, não sombra


def _ler_png(caminho: str) -> np.ndarray:
    img = bpy.data.images.load(caminho)
    img.colorspace_settings.name = "Non-Color"
    a = np.array(img.pixels[:], dtype=np.float32).reshape(
        img.size[1], img.size[0], 4).copy()
    bpy.data.images.remove(img)
    return a


def _gravar_png(caminho: str, a: np.ndarray) -> None:
    alt, larg = a.shape[0], a.shape[1]
    img = bpy.data.images.new("saida_tmp", larg, alt, alpha=True)
    img.colorspace_settings.name = "Non-Color"
    img.pixels = a.ravel()
    img.filepath_raw = caminho
    img.file_format = "PNG"
    img.save()
    bpy.data.images.remove(img)


def render_sombra(cena, grupo, caminho: str) -> None:
    """Renderiza SÓ a sombra do prop num plano, com a chave e mais nada.

    Por que só a chave: com o rig inteiro ligado, as duas luzes de área
    espalham penumbra fraquíssima pelo plano todo e o apanhador escreve alpha
    quase zero no quadro inteiro — medido em 108.590 px contra 14.552 px de
    prop. Sombra tem de vir de UMA fonte, senão não é sombra, é véu.

    Por que a chave sobe para 62°: nos 48° do mapa a sombra sai comprida e o
    sprite ganha um rabo escuro atravessado. Sombra de sprite serve para grudar
    a peça no chão, não para contar a hora do dia.

    POR QUE O AZIMUTE MUDA, E POR QUE ISSO É DE PROPÓSITO.
    Manter o azimute do mapa parecia o certo e foi a primeira tentativa. Só que
    a convenção de faces do SVG (a face +mx mais escura que a +my) implica luz
    vindo de baixo-esquerda NA TELA, e a sombra correspondente cai para cima e
    para a direita — ou seja, ATRÁS do prop, onde o próprio prop a esconde.
    Medido na tela: os coqueiros ficaram bem, e o armazém e os contentores não
    ganharam sombra nenhuma que se visse. Sombra invisível não gruda nada.

    Então este passe usa um azimute próprio (250°), que joga a sombra para
    baixo-direita, à frente da peça. Não é a mesma luz que sombreia as faces, e
    isso é uma inconsistência assumida: a sombra aqui não existe para dizer de
    onde vem o sol, existe para dizer que a peça toca o chão.
    """
    chave = bpy.data.objects["luz_chave"]
    apagadas = [bpy.data.objects["luz_enchimento"],
                bpy.data.objects["luz_contraluz"]]
    forca_mundo = cena.world.node_tree.nodes["Background"].inputs[1].default_value
    rot_chave = tuple(chave.rotation_euler)

    # ⚠️ O CONTORNO FICA DE FORA DESTE PASSE, e a razão sobreviveu à troca de
    # técnica. O Freestyle, ligado aqui, contornava o PLANO apanhador de 16
    # unidades e o contorno dele entrava na composição como um losango escuro
    # à volta do prop; o contorno pelo compositor faria pior, porque o plano é
    # maior que o quadro e o traço sairia como uma moldura inteira. O plano é
    # andaime, não desenho.
    compositor = cena.render.use_compositing
    cena.render.use_compositing = False

    for luz in apagadas:
        luz.hide_render = True
    cena.world.node_tree.nodes["Background"].inputs[1].default_value = 0.0
    chave.rotation_euler = (math.radians(62), 0, math.radians(250))

    bpy.ops.mesh.primitive_plane_add(size=16, location=(0, 0, 0))
    plano = bpy.context.active_object
    plano.is_shadow_catcher = True
    # visible_camera=False e NÃO hide_render: escondido do render, o prop
    # deixaria de projetar junto e o passe sairia vazio.
    for o in grupo:
        o.visible_camera = False

    cena.render.filepath = caminho
    bpy.ops.render.render(write_still=True)

    for o in grupo:
        o.visible_camera = True
    bpy.data.objects.remove(plano, do_unlink=True)
    cena.render.use_compositing = compositor
    for luz in apagadas:
        luz.hide_render = False
    cena.world.node_tree.nodes["Background"].inputs[1].default_value = forca_mundo
    chave.rotation_euler = rot_chave


def compor_sombra(caminho_prop: str, caminho_sombra: str) -> None:
    """Põe a sombra POR BAIXO do prop e grava por cima do PNG do prop."""
    prop = _ler_png(caminho_prop)
    sombra = _ler_png(caminho_sombra)

    a_s = np.clip((sombra[:, :, 3] - SOMBRA_LIMIAR) / (1.0 - SOMBRA_LIMIAR),
                  0.0, 1.0) * SOMBRA_FORCA
    a_p = prop[:, :, 3]
    a_out = a_p + a_s * (1.0 - a_p)

    cor_sombra = np.array(SOMBRA_COR, dtype=np.float32)
    numerador = (prop[:, :, :3] * a_p[:, :, None]
                 + cor_sombra[None, None, :] * (a_s * (1.0 - a_p))[:, :, None])
    seguro = np.where(a_out > 1e-5, a_out, 1.0)[:, :, None]

    saida = np.empty_like(prop)
    saida[:, :, :3] = numerador / seguro
    saida[:, :, 3] = a_out
    _gravar_png(caminho_prop, saida)


# ---------------------------------------------------------------- verificação
def largura_opaca(caminho: str) -> int:
    """Largura em pixels do que não é transparente no PNG."""
    import struct
    import zlib

    with open(caminho, "rb") as f:
        dados = f.read()
    i, idat = 8, b""
    largura = altura = canais = 0
    while i < len(dados):
        n = struct.unpack(">I", dados[i:i + 4])[0]
        tipo = dados[i + 4:i + 8]
        corpo = dados[i + 8:i + 8 + n]
        if tipo == b"IHDR":
            largura, altura, _, cor = struct.unpack(">IIBB", corpo[:10])
            canais = {0: 1, 2: 3, 4: 2, 6: 4}[cor]
        elif tipo == b"IDAT":
            idat += corpo
        i += 12 + n

    bruto = zlib.decompress(idat)
    anterior = bytearray(largura * canais)
    off, x_min, x_max = 0, largura, -1
    for _ in range(altura):
        filtro = bruto[off]
        off += 1
        linha = bytearray(bruto[off:off + largura * canais])
        off += largura * canais
        for x in range(len(linha)):
            a = linha[x - canais] if x >= canais else 0
            b = anterior[x]
            c = anterior[x - canais] if x >= canais else 0
            if filtro == 1:
                linha[x] = (linha[x] + a) & 255
            elif filtro == 2:
                linha[x] = (linha[x] + b) & 255
            elif filtro == 3:
                linha[x] = (linha[x] + (a + b) // 2) & 255
            elif filtro == 4:
                pa, pb, pc = abs(b - c), abs(a - c), abs(a + b - 2 * c)
                pr = a if (pa <= pb and pa <= pc) else (b if pb <= pc else c)
                linha[x] = (linha[x] + pr) & 255
        for x in range(largura):
            if linha[x * canais + canais - 1] > 8:
                x_min = min(x_min, x)
                x_max = max(x_max, x)
        anterior = linha
    return 0 if x_max < 0 else x_max - x_min + 1


# ---------------------------------------------------------------- principal
def main() -> int:
    contorno = "--contorno" in sys.argv
    despejo = next((a.split("=", 1)[1] for a in sys.argv[1:]
                    if a.startswith("--despejar=")), None)
    args = [a for a in sys.argv[1:] if not a.startswith("-")]
    if not args and despejo is None:
        print(__doc__.strip().splitlines()[-1])
        return 2

    print(caminho_da_montagem())
    inicio = time.monotonic()
    cena = preparar_cena()
    if contorno:
        ligar_contorno_compositor(cena)
    M = paleta_completa()
    grupos = montar(M)

    # Chanfro só aqui, depois de tudo montado: as funções de prop continuam
    # falando de caixas, e quem quiser reaproveitá-las não herda o modificador.
    chanfrar({o for g in grupos.values() for o in g})
    print("montagem: %d objetos em %.1f s"
          % (len(bpy.data.objects), time.monotonic() - inicio))
    if despejo is not None:
        print("despejo: %d objetos em %s" % (despejar_cena(despejo), despejo))
        return 0
    saida, pedidos = args[0], args[1:]

    if pedidos:
        desconhecidos = [p for p in pedidos if p not in grupos]
        if desconhecidos:
            print("prop desconhecido: %s" % ", ".join(desconhecidos))
            print("disponíveis: %s" % ", ".join(sorted(grupos)))
            return 2
        alvos = pedidos
    else:
        # As referências de escala e as cargas do nível 2 só saem quando
        # pedidas pelo nome: numa regeração de tudo iriam parar a `art/props`,
        # onde seriam arte órfã (`REFERENCIAS`, `PROXIMO_NIVEL`).
        alvos = [n for n in grupos
                 if n not in REFERENCIAS and n not in PROXIMO_NIVEL]

    todos = {o for g in grupos.values() for o in g}
    for nome in alvos:
        for o in todos:
            o.hide_render = True
        for o in grupos[nome]:
            o.hide_render = False
        alvo = "%s/%s.png" % (saida.rstrip("/"), nome)
        cena.render.filepath = alvo
        bpy.ops.render.render(write_still=True)
        if nome in SOMBRA:
            temp = "%s/_sombra_tmp.png" % saida.rstrip("/")
            render_sombra(cena, grupos[nome], temp)
            compor_sombra(alvo, temp)
            os.remove(temp)
            print("  %s  (+ sombra)" % nome)
        else:
            print("  %s" % nome)

    # A projeção sai certa ou sai errada; não há meio termo, e o resto do
    # trabalho depende dela. O tabuado tem largura conhecida pela conta do mapa:
    # (comprimento + largura) * MEIA_LARG_TELA — a escala de TELA, e não a do
    # desenho do mapa.
    #
    # ⚠️ E ELA MEDE-SE EM TELA, NÃO NO PNG, desde que os dois deixaram de ser o
    # mesmo número. `largura_opaca` conta pixels do arquivo, então o que sai
    # dela divide-se pelo FATOR_RES antes de encontrar o esperado. Escalar o
    # ESPERADO em vez do MEDIDO daria a mesma resposta e escalaria também a
    # tolerância sem ninguém decidir: os 4 px são a folga do chanfro, que vale
    # 1,13 px de TELA em qualquer resolução — em pixel de PNG ela cresceria com
    # o FATOR_RES e a guarda ficaria mais frouxa a cada alavanca.
    if "pier_n2" in alvos:
        esperado = (PIER_ALCANCE + PIER_LARG) * MEIA_LARG_TELA
        bruto = largura_opaca("%s/pier_n2.png" % saida.rstrip("/"))
        medido = bruto / FATOR_RES
        erro = abs(medido - esperado)
        print("\nverificação da projeção:")
        print("  tabuado esperado %.0f px de tela, medido %.1f (%d px do PNG,"
              " /%.2f) — erro %.1f px" % (esperado, medido, bruto, FATOR_RES, erro))
        if erro > 4:
            print("  FALHOU — a projeção não bate com gerar_mapa_iso.py")
            return 1
        print("  ok — os PNGs caem no mapa em escala 1:1")

    # O pivô da lança NÃO se acerta no olho: girar em torno de um ponto que não
    # é o topo da torre desencaixa a lança da torre a cada varrida. Sai daqui e
    # vai DIRETO para o `pivot_offset` do nó Lanca em Dock.tscn.
    #
    # ⚠️ E ELE DEIXOU DE SER O PIXEL DO PNG. Dizia-se aqui que "o nó tem
    # exatamente 512x512, o tamanho da textura, então o pixel do PNG e o pixel
    # do nó são o mesmo número" — verdade enquanto foi verdade, e a frase que
    # esconde a armadilha da alavanca B: o nó continua com 512 e a textura tem
    # 768. O `pivot_offset` é do NÓ, logo a linha que se copia é a de TELA. A
    # do PNG fica impressa ao lado porque é ela que se confere contra o render.
    #
    # ⚠️ E ELE NÃO IMPRIMIA NADA HAVIA MUITO. A condição pedia
    # `"guindaste_lanca" in alvos` e o catálogo não tem nenhum grupo com esse
    # nome — são `lanca_n1`, `lanca_n2` e `lanca_n3` desde que a lança ganhou
    # três níveis. Um `if` que nunca é verdade não dá erro: a ferramenta corria
    # inteira, saía com 0, e a única linha que derivava o pivô ficou muda.
    # É o "comentário que diz «lido de X» e não lê X" em forma de guarda —
    # achado ao subir a resolução, quando alguém foi finalmente ler o número.
    # O `lanca_n2` é o gatilho porque é a lança que o `Dock.tscn` carrega, e o
    # pivô é o mesmo nos três níveis de propósito (`pivot_offset` é um só).
    if "lanca_n2" in alvos:
        gx = PIER_ALCANCE / 2 - 0.95
        px, py = para_pixel((gx, 0.55, ALT_PIER + 2.70))
        tx, ty = para_pixel_tela((gx, 0.55, ALT_PIER + 2.70))
        print("\npivô da lança (topo da torre):")
        print("  no PNG de %d: (%.0f, %.0f) px" % (RESOLUCAO, px, py))
        print("  pivot_offset em Dock.tscn (nó de %d): Vector2(%.0f, %.0f)"
              % (RESOLUCAO_TELA, tx, ty))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
