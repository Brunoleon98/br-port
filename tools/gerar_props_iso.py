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

Sem nomes, gera tudo. Ao fim confere a largura do tabuado contra a conta do
mapa — se divergir, a projeção saiu errada e o resto não presta.
"""

import math
import os
import sys

import bpy
import numpy as np
from mathutils import Vector

# ---------------------------------------------------------------- projeção
# Os mesmos valores de tools/gerar_mapa_iso.py. Mudar aqui sem mudar lá
# desalinha os props do chão.
MEIA_LARG, MEIA_ALT = 30.0, 15.0

# Câmera ortográfica: a razão vertical/horizontal de um passo no chão é
# sen(elevação). Com 15/30 = 0,5 -> elevação 30° -> rotação X = 60°.
# (O 54,736° dos tutoriais é isométrico VERDADEIRO, 1,732:1. Aqui daria errado.)
ROT_X, ROT_Z = 60.0, 45.0

RESOLUCAO = 512

# Uma unidade de mundo na horizontal tem de valer MEIA_LARG pixels. Numa câmera
# ortográfica a 45° de azimute isso é (RESOLUCAO / ortho_scale) * cos(45°),
# então ortho_scale = RESOLUCAO / (MEIA_LARG / cos(45°)).
ESCALA_ORTO = RESOLUCAO / (MEIA_LARG / math.cos(math.radians(45.0)))

# ALTURA: o ponto onde os dois mundos quase não se falam.
#
# `gerar_mapa_iso.py` trata altura como PIXELS livres — ALT_PIER=15, ALT_CAIS=26,
# um armazém com 44. É uma convenção de desenho, não uma projeção.
# O Blender faz projeção DE VERDADE: uma unidade de altura projeta
# (RESOLUCAO/ortho_scale) * cos(elevação) = 36,74 px.
#
# Ignorar isso põe um píer renderizado 2,4x mais alto que o cais desenhado ao
# lado dele. Por isso os props falam a mesma língua do mapa: altura em PIXELS
# DO MAPA, convertida aqui num lugar só.
ALTURA_PX = (RESOLUCAO / ESCALA_ORTO) * math.cos(math.radians(90.0 - ROT_X))


def z(altura_px: float) -> float:
    """Altura em pixels do mapa -> unidades de mundo do Blender."""
    return altura_px / ALTURA_PX


PIER_ALCANCE = 4.5
PIER_LARG = 2.4
ALT_PIER = z(15.0)          # ALT_PIER do mapa, em pixels

PALETA = {
    "madeira": "#9a6438", "madeira_esc": "#633d20", "madeira_velha": "#7d7266",
    "metal": "#4a535a", "metal_claro": "#6d7880",
    "casco": "#24466e", "faixa": "#c23030", "cabine": "#eef2f5",
    "tronco": "#8a5a34", "folha": "#2d7a3a", "folha_clara": "#4a9c58",
    "telhado": "#c85420", "telhado_velho": "#8f6a4a", "parede": "#eef2f5",
    "laranja": "#c85420", "azul": "#2f7690", "amarelo": "#e09a10",
    "boia": "#d94f2a", "corda": "#c9b48a",
    "colete": "#e0561f", "capacete": "#e0a81f", "pele": "#b07b52",
    "calca": "#24466e", "rede": "#8d9aa6", "casco_pesca": "#2f6f4a", "parede_suja": "#9a9c93", "vidro": "#7fb6cc",
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
    "rede": 14.0, "corda": 13.0,
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


def paleta_completa() -> dict:
    """A paleta virada em materiais: gasto onde faz sentido, chapado no resto."""
    return {k: (material_gasto(k, v, DESGASTE[k]) if k in DESGASTE
                else material(k, v))
            for k, v in PALETA.items()}


def chanfrar(objs, largura: float = 0.020, segmentos: int = 2) -> None:
    """Chanfro em toda peça, aplicado no fim e nunca na geometria de origem.

    Aresta viva não pega luz: os dois lados dela devolvem o seu tom chapado e o
    encontro entre eles é um salto. Chanfrada, o encontro vira uma faixa fina
    que apanha a luz de raspão, e o volume aparece sem que nada mais mude.

    A largura é pequena porque ela ENCOLHE a silhueta — cada canto recua cerca
    de `largura`. Com 0,020 o tabuado perde ~1,7 px dos 207, dentro da margem
    de 4 px da verificação de projeção lá embaixo. Subir isto sem olhar aquela
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


def caixa(nome, centro, tam, mat, rot=(0, 0, 0)):
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=centro)
    o = bpy.context.active_object
    o.name = nome
    o.scale = tam
    o.rotation_euler = tuple(math.radians(a) for a in rot)
    o.data.materials.append(mat)
    return o


def cone(nome, centro, r1, r2, alt, lados, mat, rot=(0, 0, 0)):
    bpy.ops.mesh.primitive_cone_add(vertices=lados, radius1=r1, radius2=r2,
                                    depth=alt, location=centro)
    o = bpy.context.active_object
    o.name = nome
    o.rotation_euler = tuple(math.radians(a) for a in rot)
    o.data.materials.append(mat)
    return o


def prisma(nome, contorno, z0, z1, escala_baixo, mat):
    """Contorno fechado puxado para baixo e estreitado.

    É o que torna forma não-caixa possível em código: em vez de esculpir, você
    lista os pontos do contorno. O casco de barco sai daqui — e sai idêntico
    toda vez, ao contrário de um desenho.
    """
    ex, ey = escala_baixo
    verts = [(x, y, z1) for x, y in contorno] + \
            [(x * ex, y * ey, z0) for x, y in contorno]
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
    """Ponto do mundo -> pixel dentro do PNG de 512.

    A câmera mira a origem, então a origem cai no centro do quadro. O resto é
    projetar em cima dos eixos da câmera. Serve para DERIVAR o pivot_offset da
    lança em Dock.tscn em vez de o acertar no olho — o pivô errado faz a lança
    girar em torno de um ponto que não é o topo do mastro, e aí ela desencaixa
    da torre a cada varrida.
    """
    rx, rz = math.radians(ROT_X), math.radians(ROT_Z)
    direita = Vector((math.cos(rz), math.sin(rz), 0.0))
    cima = Vector((-math.sin(rz) * math.cos(rx), math.cos(rz) * math.cos(rx),
                   math.sin(rx)))
    px_por_unidade = RESOLUCAO / ESCALA_ORTO
    p = Vector(p)
    return (RESOLUCAO / 2.0 + p.dot(direita) * px_por_unidade,
            RESOLUCAO / 2.0 - p.dot(cima) * px_por_unidade)


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

    tabuado = [caixa("tabuado", (0, 0, ALT_PIER - z(2.2)),
                     (PIER_ALCANCE, PIER_LARG, z(4.4)), M["madeira"])]

    # Carga no convés. Um píer limpo parece cenário; com caixotes à espera de
    # embarque parece que ali se trabalha. Fica na ponta do mar (+mx) e do lado
    # oposto ao barco, que atraca no +my — o meio do tabuado é da chip.
    def _no_conves(nome, mx, my, altura_px, tam, mat, rot=(0, 0, 0)):
        px, py, pz = pos(mx, my, 15.0 + altura_px / 2.0)
        return caixa(nome, (px, py, pz), (tam[0], tam[1], z(altura_px)), mat, rot)

    tabuado += [
        _no_conves("cont_conves", 1.95, -0.72, 15.0, (1.05, 0.5), M["laranja"]),
        _no_conves("cont_topo", 1.95, -0.72, 1.6, (1.02, 0.47), M["azul"]),
        _no_conves("caixote_a", 2.00, 0.50, 11.0, (0.42, 0.42), M["madeira"]),
        _no_conves("caixote_b", -1.95, 0.68, 9.5, (0.38, 0.38), M["madeira"],
                   rot=(0, 0, 18)),
    ]
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

    # Base: sapata, chapa e parafusos. Três peças que custam nada e dizem que a
    # torre foi PARAFUSADA no píer em vez de nascer dele.
    g_base = [
        caixa("g_sapata", (GX, GY, ALT_PIER + 0.10), (0.66, 0.66, 0.20), M["metal"]),
        caixa("g_chapa", (GX, GY, ALT_PIER + 0.24), (0.52, 0.52, 0.08), M["laranja"]),
    ]
    for sx in (-0.21, 0.21):
        for sy in (-0.21, 0.21):
            g_base.append(caixa("g_parafuso_%.2f_%.2f" % (sx, sy),
                                (GX + sx, GY + sy, ALT_PIER + 0.30),
                                (0.08, 0.08, 0.08), M["metal"]))

    # Torre vazada + cabine do operador encostada nela.
    g_mastro = trelica("g_torre", (GX, GY, ALT_PIER + 0.28), (GX, GY, TOPO + 0.05),
                       0.19, M["laranja"], montantes=6, esp=0.052)
    g_mastro += [
        caixa("g_cabine", (GX + 0.30, GY - 0.02, TOPO - 0.55),
              (0.30, 0.34, 0.34), M["laranja"]),
        caixa("g_cabine_vidro", (GX + 0.36, GY - 0.02, TOPO - 0.50),
              (0.22, 0.30, 0.24), M["vidro"]),
    ]

    # Lança e contralança. O contrapeso não é enfeite: é ele que equilibra a
    # silhueta e impede a peça de ler como poste com um braço.
    g_lanca = trelica("g_lanca", (GX, GY - 0.18, TOPO), (GX, BARCO_Y, TOPO),
                      0.13, M["laranja"], montantes=7, esp=0.044)
    g_lanca += trelica("g_contra", (GX, GY + 0.18, TOPO), (GX, GY + 1.05, TOPO),
                       0.11, M["laranja"], montantes=3, esp=0.042)
    g_lanca += [
        caixa("g_contrapeso", (GX, GY + 1.18, TOPO - 0.06),
              (0.30, 0.26, 0.30), M["metal"]),
        caixa("g_torreta", (GX, GY, TOPO + 0.42), (0.09, 0.09, 0.70), M["metal"]),
    ]
    # Tirantes do topo até os dois extremos: é o que amarra a silhueta.
    g_lanca += [
        barra("g_tirante_frente", (GX, GY, TOPO + 0.75),
              (GX, BARCO_Y + 0.35, TOPO + 0.06), 0.028, M["metal"]),
        barra("g_tirante_tras", (GX, GY, TOPO + 0.75),
              (GX, GY + 1.05, TOPO + 0.06), 0.028, M["metal"]),
    ]
    # Carro, cabo e moitão, pendurados sobre o barco.
    CARRO_Y = BARCO_Y + 0.55
    g_lanca += [
        caixa("g_carro", (GX, CARRO_Y, TOPO - 0.14), (0.17, 0.26, 0.13), M["metal"]),
        caixa("g_cabo", (GX, CARRO_Y, TOPO - 0.72), (0.035, 0.035, 1.05), M["metal"]),
        caixa("g_moitao", (GX, CARRO_Y, TOPO - 1.32), (0.19, 0.15, 0.22), M["amarelo"]),
    ]
    # Base e mastro entram no PRÓPRIO píer: um guindaste é o que faz uma
    # estrutura de madeira ler como porto e não como pontão de pesca. A lança
    # fica solta porque é ela que gira — e o que se move não pode estar assado.
    grupos["pier_construido"] = estacas + tabuado + g_base + g_mastro
    grupos["guindaste_lanca"] = g_lanca
    grupos["pier_ampliado"] = estacas + tabuado + g_base + g_mastro + g_lanca

    # -- BARCOS ----------------------------------------------------------
    # O pesqueiro tinha o mesmo casco dos cargueiros e uma caixa bege no lugar
    # da carga: os três liam-se como o mesmo barco com adereços trocados. Agora
    # ele tem casco PRÓPRIO, mais curto e mais estreito, e o que carrega é
    # pau-de-carga e rede — silhueta diferente, não pintura diferente.
    CARGA = [(2.30, 0.0), (1.55, 0.58), (-1.45, 0.62), (-2.05, 0.44),
             (-2.05, -0.44), (-1.45, -0.62), (1.55, -0.58)]
    PESCA = [(1.55, 0.0), (1.05, 0.42), (-0.95, 0.46), (-1.40, 0.32),
             (-1.40, -0.32), (-0.95, -0.46), (1.05, -0.42)]

    def casco(sufixo, contorno, altura, cor_casco, cor_faixa):
        return [prisma("casco" + sufixo, contorno, 0.0, altura, (0.88, 0.42), cor_casco),
                prisma("faixa" + sufixo, contorno, altura - 0.12, altura + 0.02,
                       (0.99, 0.97), cor_faixa)]

    grupos["barco_pequeno"] = casco("_p", PESCA, 0.44, M["casco_pesca"], M["cabine"]) + [
        caixa("cabine_p", (-0.75, 0.0, 0.70), (0.85, 0.62, 0.50), M["cabine"]),
        caixa("mastro_p", (0.25, 0.0, 1.25), (0.09, 0.09, 1.7), M["madeira_esc"]),
        # Pau-de-carga inclinado: é o que diz "pesqueiro" à primeira vista.
        caixa("pau", (0.72, 0.0, 1.35), (1.3, 0.07, 0.07), M["madeira_esc"],
              rot=(0, -26, 0)),
        caixa("rede_p", (-0.15, 0.0, 0.60), (0.7, 0.5, 0.26), M["rede"]),
        caixa("boia_p", (1.05, 0.30, 0.52), (0.2, 0.2, 0.18), M["boia"])]

    grupos["barco_medio"] = casco("_m", CARGA, 0.62, M["casco"], M["faixa"]) + [
        caixa("cabine_m", (-1.15, 0.0, 0.95), (1.1, 0.85, 0.62), M["cabine"]),
        caixa("chamine_m", (-1.55, 0.0, 1.42), (0.22, 0.22, 0.42), M["metal"]),
        caixa("carga_a", (0.75, 0.22, 0.85), (0.6, 0.42, 0.42), M["laranja"]),
        caixa("carga_b", (0.75, -0.25, 0.82), (0.55, 0.4, 0.38), M["azul"]),
        caixa("carga_c", (0.05, 0.0, 0.82), (0.55, 0.5, 0.38), M["amarelo"])]

    grupos["barco_grande"] = casco("_g", CARGA, 0.62, M["casco"], M["faixa"]) + [
        caixa("cabine_g", (-1.35, 0.0, 1.00), (0.95, 0.8, 0.72), M["cabine"]),
        caixa("chamine_g", (-1.7, 0.0, 1.52), (0.24, 0.24, 0.46), M["metal"]),
        caixa("pilha_a", (0.95, 0.22, 0.86), (0.7, 0.42, 0.44), M["laranja"]),
        caixa("pilha_b", (0.95, -0.25, 0.86), (0.7, 0.42, 0.44), M["azul"]),
        caixa("pilha_c", (0.95, 0.0, 1.30), (0.68, 0.42, 0.42), M["amarelo"]),
        caixa("pilha_d", (0.05, 0.1, 0.86), (0.6, 0.5, 0.44), M["azul"]),
        caixa("grua_g", (-0.5, 0.0, 1.65), (0.13, 0.13, 2.0), M["metal_claro"]),
        caixa("lanca_g", (0.25, 0.0, 2.5), (1.6, 0.11, 0.11), M["metal_claro"],
              rot=(0, -18, 0))]

    # -- TRABALHADOR no píer: até agora ele só existia como "#1" na chip.
    # De pé no tabuado, a doca ocupada lê-se sem ter de ler texto.
    # Fica do lado de TERRA e afastado do centro, porque o barco atraca do
    # outro lado e a chip cobre o meio do convés.
    # Em coordenadas DO MAPA: recuado para terra (mx negativo) e do lado oposto
    # ao barco, que atraca no +my. A conversão de eixo fica toda em pos().
    MX, MY = -1.35, -0.68
    ALT = 15.0                     # topo do tabuado, em pixels do mapa
    def _t(nome, subir_px, tam_px, mat, dmx=0.0):
        px, py, pz = pos(MX + dmx, MY, ALT + subir_px)
        return caixa(nome, (px, py, pz),
                     (tam_px[0], tam_px[1], z(tam_px[2])), mat)

    grupos["trabalhador"] = [
        _t("t_pernas", 5.0, (0.20, 0.17, 10.0), M["calca"]),
        _t("t_corpo", 15.5, (0.30, 0.24, 11.5), M["colete"]),
        _t("t_cabeca", 24.0, (0.18, 0.16, 6.0), M["pele"]),
        _t("t_capacete", 28.2, (0.25, 0.23, 4.4), M["capacete"]),
        _t("t_aba", 26.6, (0.34, 0.25, 1.8), M["capacete"], dmx=0.06),
    ]

    # -- COQUEIRO: copa e tronco separados, para o balanço ---------------
    grupos["coqueiro_tronco"] = [
        cone("tronco", (0, 0, 1.15), 0.17, 0.11, 2.3, 6, M["tronco"], rot=(4, 0, 0)),
        cone("raiz", (0, 0, 0.12), 0.3, 0.18, 0.25, 6, M["madeira_esc"])]
    copa = []
    for i in range(7):
        a = i * (360.0 / 7)
        r = math.radians(a)
        copa.append(cone(f"folha{i}",
                         (0.42 * math.cos(r), 0.42 * math.sin(r) + 0.16, 2.32),
                         0.30, 0.02, 1.5, 4,
                         M["folha"] if i % 2 else M["folha_clara"],
                         rot=(66, 0, a + 90)))
    copa.append(cone("coco", (0.1, 0.1, 2.26), 0.13, 0.13, 0.2, 6, M["madeira_esc"]))
    grupos["coqueiro_copa"] = copa

    # -- CENÁRIO solto ---------------------------------------------------
    grupos["conteiner"] = [caixa("c", (0, 0, 0.45), (2.4, 1.1, 0.9), M["laranja"]),
                           caixa("c_topo", (0, 0, 0.92), (2.35, 1.05, 0.06), M["azul"])]
    grupos["caixote"] = [caixa("k", (0, 0, 0.35), (0.8, 0.8, 0.7), M["madeira"]),
                         caixa("k_cinta", (0, 0, 0.35), (0.84, 0.5, 0.72), M["madeira_esc"])]
    grupos["boia"] = [cone("b", (0, 0, 0.3), 0.34, 0.28, 0.6, 8, M["boia"]),
                      cone("b_topo", (0, 0, 0.66), 0.1, 0.06, 0.3, 6, M["metal"])]
    grupos["marcador"] = [cone("m", (0, 0, 0.55), 0.26, 0.04, 1.1, 4, M["amarelo"]),
                          caixa("m_base", (0, 0, 0.06), (0.5, 0.5, 0.12), M["metal"])]

    # -- GALPÃO nos dois estados: mesmas paredes, telhado diferente ------
    paredes = [caixa("gal_parede", (0, 0, 0.85), (3.4, 2.4, 1.7), M["parede"]),
               caixa("gal_porta", (0, -1.21, 0.6), (1.4, 0.06, 1.2), M["madeira_esc"])]
    grupos["galpao"] = paredes + [
        caixa("gal_telha", (0, 0, 1.95), (3.7, 2.7, 0.36), M["telhado"])]
    grupos["galpao_velho"] = paredes + [
        caixa("gal_telha_v", (0, 0.1, 1.92), (3.7, 2.5, 0.3), M["telhado_velho"],
              rot=(0, 0, 2)),
        caixa("gal_buraco", (0.9, -0.6, 1.99), (0.8, 0.7, 0.32), M["madeira_esc"])]

    # -- ESCRITÓRIO nos dois estados. O armazém reaproveita galpao/galpao_velho.
    # A ruína não é o prédio "pintado de velho": é MENOS prédio — parede caída,
    # telhado furado. Um jogador tem de ver de longe que ali não se opera.
    esc_base = [caixa("esc_parede", (0, 0, 0.70), (2.4, 2.0, 1.4), M["parede"]),
                caixa("esc_porta", (0, -1.01, 0.45), (0.8, 0.06, 0.9), M["madeira_esc"])]
    grupos["escritorio"] = esc_base + [
        caixa("esc_telha", (0, 0, 1.62), (2.7, 2.3, 0.3), M["telhado"]),
        caixa("esc_janela", (1.21, 0.3, 0.95), (0.05, 0.7, 0.45), M["vidro"]),
        caixa("esc_placa", (0, -1.05, 1.25), (1.2, 0.06, 0.3), M["amarelo"])]
    grupos["escritorio_ruina"] = [
        caixa("ruina_parede_alta", (-0.55, 0, 0.55), (1.3, 2.0, 1.1), M["parede_suja"]),
        caixa("ruina_parede_baixa", (0.75, 0, 0.22), (1.1, 2.0, 0.44), M["parede_suja"]),
        caixa("ruina_viga", (0.1, 0.35, 1.05), (2.3, 0.12, 0.12), M["madeira_esc"],
              rot=(0, 9, 0)),
        caixa("ruina_entulho_a", (-1.35, -0.85, 0.16), (0.7, 0.6, 0.32), M["madeira_esc"]),
        caixa("ruina_entulho_b", (0.95, -0.95, 0.12), (0.5, 0.45, 0.24), M["parede_suja"],
              rot=(0, 0, 22))]

    return grupos


# ---------------------------------------------------------------- cena
def ligar_contorno(cena, espessura: float = 1.6) -> None:
    """Contorno de silhueta por Freestyle.

    É o que mais aproxima um render 3D da arte ilustrada — e também o que mais
    facilmente estraga tudo, porque traço de espessura fixa engrossa em relação
    à peça conforme a peça encolhe. Fica atrás da flag `--contorno` até se
    provar na tela do jogo, não na do render.
    """
    cena.render.use_freestyle = True
    vl = cena.view_layers[0]
    vl.use_freestyle = True

    # Ligar `use_freestyle` já cria um lineset — e cria-o SEM estilo. Criar
    # outro por cima não resolve: o Freestyle percorre todos e rebenta no
    # primeiro com 'NoneType' has no attribute use_chaining. Reaproveita-se o
    # que existe e garante-se estilo em cada um.
    conjuntos = vl.freestyle_settings.linesets
    conjunto = conjuntos[0] if len(conjuntos) else conjuntos.new("contorno")
    for cj in conjuntos:
        if cj.linestyle is None:
            cj.linestyle = bpy.data.linestyles.new("contorno_%s" % cj.name)

    conjunto.select_silhouette = True
    conjunto.select_border = True
    conjunto.select_crease = False
    estilo = conjunto.linestyle
    # Escuro da própria cena, não preto: preto puro num porto ensolarado lê
    # como desenho técnico colado por cima da imagem.
    estilo.color = (0.10, 0.09, 0.12)
    estilo.thickness = espessura


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
SOMBRA = {"galpao", "galpao_velho", "escritorio", "escritorio_ruina",
          "coqueiro_tronco", "conteiner", "caixote", "marcador"}
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

    # Freestyle desligado no passe de sombra: ligado, ele contorna o PLANO
    # apanhador e o contorno dele entra na composição — um losango escuro de
    # 16 unidades à volta do prop. O plano é andaime, não desenho.
    freestyle = cena.render.use_freestyle
    cena.render.use_freestyle = False

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
    cena.render.use_freestyle = freestyle
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
    args = [a for a in sys.argv[1:] if not a.startswith("-")]
    if not args:
        print(__doc__.strip().splitlines()[-1])
        return 2
    saida, pedidos = args[0], args[1:]

    cena = preparar_cena()
    if contorno:
        ligar_contorno(cena)
    M = paleta_completa()
    grupos = montar(M)

    # Chanfro só aqui, depois de tudo montado: as funções de prop continuam
    # falando de caixas, e quem quiser reaproveitá-las não herda o modificador.
    chanfrar({o for g in grupos.values() for o in g})

    if pedidos:
        desconhecidos = [p for p in pedidos if p not in grupos]
        if desconhecidos:
            print("prop desconhecido: %s" % ", ".join(desconhecidos))
            print("disponíveis: %s" % ", ".join(sorted(grupos)))
            return 2
        alvos = pedidos
    else:
        alvos = list(grupos)

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
    # (comprimento + largura) * MEIA_LARG.
    if "pier_construido" in alvos:
        esperado = (PIER_ALCANCE + PIER_LARG) * MEIA_LARG
        medido = largura_opaca("%s/pier_construido.png" % saida.rstrip("/"))
        erro = abs(medido - esperado)
        print("\nverificação da projeção:")
        print("  tabuado esperado %.0f px, medido %d px (erro %.0f px)"
              % (esperado, medido, erro))
        if erro > 4:
            print("  FALHOU — a projeção não bate com gerar_mapa_iso.py")
            return 1
        print("  ok — os PNGs caem no mapa em escala 1:1")

    # O pivô da lança NÃO se acerta no olho: girar em torno de um ponto que não
    # é o topo da torre desencaixa a lança da torre a cada varrida. Sai daqui,
    # em pixels do PNG, e vai DIRETO para o `pivot_offset` do nó Lanca em
    # Dock.tscn: o nó tem exatamente 512x512, o tamanho da textura, então o
    # pixel do PNG e o pixel do nó são o mesmo número.
    if "guindaste_lanca" in alvos:
        gx = PIER_ALCANCE / 2 - 0.95
        px, py = para_pixel((gx, 0.55, ALT_PIER + 2.70))
        print("\npivô da lança (topo da torre):")
        print("  no PNG: (%.0f, %.0f) px" % (px, py))
        print("  pivot_offset em Dock.tscn: Vector2(%.0f, %.0f)" % (px, py))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
