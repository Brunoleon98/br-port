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
import sys

import bpy

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
    "calca": "#24466e", "rede": "#8d9aa6", "casco_pesca": "#2f6f4a",
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
    g_base = [caixa("g_base", (PIER_ALCANCE / 2 - 1.0, PIER_LARG / 2 - 0.4,
                               ALT_PIER + 0.18), (0.6, 0.6, 0.36), M["metal"])]
    g_mastro = [caixa("g_mastro", (PIER_ALCANCE / 2 - 1.0, PIER_LARG / 2 - 0.4,
                                   ALT_PIER + 1.5), (0.24, 0.24, 2.6), M["metal_claro"])]
    g_lanca = [caixa("g_lanca", (PIER_ALCANCE / 2 - 1.9, PIER_LARG / 2 - 0.4,
                                 ALT_PIER + 2.7), (2.0, 0.18, 0.18), M["metal_claro"]),
               caixa("g_cabo", (PIER_ALCANCE / 2 - 2.75, PIER_LARG / 2 - 0.4,
                                ALT_PIER + 2.25), (0.05, 0.05, 0.8), M["metal"]),
               caixa("g_gancho", (PIER_ALCANCE / 2 - 2.75, PIER_LARG / 2 - 0.4,
                                  ALT_PIER + 1.78), (0.2, 0.2, 0.24), M["amarelo"])]
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

    return grupos


# ---------------------------------------------------------------- cena
def preparar_cena():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    cena = bpy.context.scene
    cena.render.engine = "CYCLES"
    cena.cycles.device = "CPU"
    cena.cycles.samples = 24
    cena.render.film_transparent = True
    cena.render.resolution_x = cena.render.resolution_y = RESOLUCAO

    # Um sol só, sombra dura: as três faces de um volume saem em três tons, que
    # é o que o mapa em SVG já faz à mão (topo / dir / esq).
    bpy.ops.object.light_add(type="SUN", location=(6, -8, 12))
    sol = bpy.context.active_object
    sol.data.energy = 3.2
    sol.data.angle = 0.0
    sol.rotation_euler = (math.radians(48), 0, math.radians(28))

    cena.world = bpy.data.worlds.new("mundo")
    cena.world.use_nodes = True
    fundo = cena.world.node_tree.nodes["Background"]
    fundo.inputs[0].default_value = (0.55, 0.6, 0.68, 1)
    fundo.inputs[1].default_value = 0.55

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
    args = [a for a in sys.argv[1:] if not a.startswith("-")]
    if not args:
        print(__doc__.strip().splitlines()[-1])
        return 2
    saida, pedidos = args[0], args[1:]

    cena = preparar_cena()
    M = {k: material(k, v) for k, v in PALETA.items()}
    grupos = montar(M)

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
        cena.render.filepath = "%s/%s.png" % (saida.rstrip("/"), nome)
        bpy.ops.render.render(write_still=True)
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
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
