"""Dona Cida, expressão SÉRIA — candidata v2 da cabeça REDONDA (frente 2 do A5).

    python3.11 art_lab/retratos/cida_seria/v2/gerar_retrato_cida_v2.py <pasta>
    PREVIA=1 python3.11 ...   # 384 px e 16 amostras, para iterar a forma

Grava `<pasta>/retrato_cida_seria.png` (768×768, alfa verdadeiro). É uma
CANDIDATA: não escreve em `brport_vs/` e não toca no manifest. O retrato do
jogo continua a ser o de `blender/brp_porto.py` até o Bruno aprovar a foto do
jogo (`art_lab/README.md` §3).

NÃO É UM SEGUNDO ESTÚDIO, pela mesma razão da v1: câmera, rig de três pontos,
paleta, resolução e render saem do `Estudio` de `blender/brp_studio.py`, e a
transformada de cor é o AgX de hoje (plano de arte §7.1).

O QUE A v2 MUDA, e porquê. O veredito do Bruno sobre a v1 (23/09) foi rejeitar
aquela cabeça como estava, marcar os quatro defeitos que a leitura apontou e
pedir para «melhorar o modelo como um todo»:

- NARIZ E BOCA — a sombra do nariz caía sobre a boca, e a boca era uma barra
  grossa: a 168 px ainda lia como bigode. O nariz passa a ser uma peça À PARTE
  que não projeta sombra, e a boca é uma curva fina que afila nas pontas;
- TRONCO — era uma bola de metaball com calombos. Passa a ser uma malha feita
  por ANÉIS, com o trapézio a descer do pescoço até um ombro MARCADO;
- GOLA — dois discos soltos no peito. Passa a ser duas abas com PONTA,
  pousadas no peito e no pescoço por raio, com os botões da blusa por baixo;
- CABELO E LÁPIS — um capacete com uma linha reta na testa e três espetos no
  alto; e o lápis a flutuar ao lado da cabeça. O cabelo passa a ser uma CASCA
  tirada da própria cabeça, colada ao crânio, com a linha do cabelo a descer
  para as têmporas e SULCOS penteados em direção ao coque; o lápis pousa no
  cabelo por cima da orelha;
- e o resto: a cara perde os calombos (suavização antes da subdivisão), as
  sobrancelhas afilam, os óculos ganham hastes e a blusa perde o ruído de
  desgaste, que num tecido lia como mancha.
"""

from __future__ import annotations

import math
import os
import pathlib
import sys

_RAIZ = pathlib.Path(__file__).resolve().parents[4]
sys.path.insert(0, str(_RAIZ / "blender"))
sys.path.insert(0, str(_RAIZ / "tools"))

# ⚠️ `bpy` ANTES de `bmesh`: como biblioteca, é o `bpy` que regista os
# submódulos, e `import bmesh` primeiro dá ModuleNotFoundError.
import bpy                                            # noqa: E402
import bmesh                                          # noqa: E402
from bpy_extras.object_utils import world_to_camera_view   # noqa: E402
from mathutils import Vector                          # noqa: E402

import gerar_props_iso as base                        # noqa: E402
from brp_studio import Estudio                        # noqa: E402

NOME = "retrato_cida_seria"

# O ENQUADRAMENTO DE HOJE, medido no PNG do jogo (`retrato_cida_seria.png`):
# o topo do cabelo a 16 px e o busto dentro de x ∈ [131, 637]. A caixa do
# retrato mostra o quadro INTEIRO em altura e corta 101 px de cada lado
# (`COVERED` de 768 em 168×228), logo a largura tem de ficar dentro de
# [101, 667] — com folga.
TOPO_PX = 16.0
CENTRO_X_PX = 384.0


def principled(nome, hexa, rough=1.0, spec=0.0):
    """A cor da paleta SEM o ruído de desgaste do `material_gasto`.

    ⚠️ O desgaste é para superfície FABRICADA (`DESGASTE` no gerador de
    props). Na blusa da v1 ele saiu como manchas de sujidade num tecido, e no
    cabelo como uma madeira manchada — o hex continua o da paleta.
    """
    m = base.material(nome, hexa)
    p = m.node_tree.nodes["Principled BSDF"]
    p.inputs["Roughness"].default_value = rough
    p.inputs["Specular IOR Level"].default_value = spec
    return m


def emissao(nome, forca):
    m = bpy.data.materials.new(nome)
    m.use_nodes = True
    nt = m.node_tree
    nt.nodes.remove(nt.nodes["Principled BSDF"])
    em = nt.nodes.new("ShaderNodeEmission")
    em.inputs["Color"].default_value = (1.0, 1.0, 1.0, 1.0)
    em.inputs["Strength"].default_value = forca
    nt.links.new(em.outputs[0], nt.nodes["Material Output"].inputs[0])
    return m


def metaball(nome, elementos, mat, resolucao=0.035, suavizar=0, nivel=1):
    """Funde elipsoides numa forma macia e devolve-a como MALHA suavizada.

    ⚠️ A SUPERFÍCIE SAI MENOR DO QUE OS RAIOS ESCRITOS (medido: raio 0,95 deu
    ±0,54), e por isso NADA se posiciona em coordenadas supostas: as feições
    pousam por `ray_cast` na malha que ficou (§7.2, P1).

    `suavizar` põe um `Smooth` ANTES da subdivisão. ⚠️ Na v1 a cara tinha
    calombos: cada elipsoide (bochecha, queixo) deixava a sua bossa na
    silhueta, e a subdivisão só os arredondava — não os fundia.
    """
    mb = bpy.data.metaballs.new(nome)
    mb.resolution = mb.render_resolution = resolucao
    ob = bpy.data.objects.new(nome, mb)
    bpy.context.scene.collection.objects.link(ob)
    for co, raio, tam in elementos:
        e = mb.elements.new()
        e.type = "ELLIPSOID"
        e.co = co
        e.radius = raio
        e.size_x, e.size_y, e.size_z = tam
    bpy.ops.object.select_all(action="DESELECT")
    bpy.context.view_layer.objects.active = ob
    ob.select_set(True)
    bpy.ops.object.convert(target="MESH")
    malha = bpy.context.active_object
    malha.name = nome
    bpy.ops.object.shade_smooth()
    malha.data.materials.append(mat)
    if suavizar:
        sm = malha.modifiers.new("liso", "SMOOTH")
        sm.factor = 0.8
        sm.iterations = suavizar
    sub = malha.modifiers.new("sub", "SUBSURF")
    sub.levels = sub.render_levels = nivel
    return malha


def esfera(nome, centro, raio, mat, seg=32, escala=(1.0, 1.0, 1.0)):
    bpy.ops.mesh.primitive_uv_sphere_add(radius=raio, location=centro,
                                         segments=seg, ring_count=seg // 2)
    o = bpy.context.active_object
    o.name = nome
    o.scale = escala
    o.data.materials.append(mat)
    bpy.ops.object.shade_smooth()
    return o


def curva(nome, pontos, espessura, mat, raios=None):
    """Um tubo por uma curva Bézier. `raios` afila (ponta de sobrancelha)."""
    cu = bpy.data.curves.new(nome, "CURVE")
    cu.dimensions = "3D"
    cu.bevel_depth = espessura
    cu.bevel_resolution = 3
    cu.use_fill_caps = True
    sp = cu.splines.new("BEZIER")
    sp.bezier_points.add(len(pontos) - 1)
    for i, (p, co) in enumerate(zip(sp.bezier_points, pontos)):
        p.co = co
        p.handle_left_type = p.handle_right_type = "AUTO"
        if raios:
            p.radius = raios[i]
    o = bpy.data.objects.new(nome, cu)
    bpy.context.scene.collection.objects.link(o)
    o.data.materials.append(mat)
    return o


def objeto_de_malha(nome, bm, mat):
    me = bpy.data.meshes.new(nome)
    bm.to_mesh(me)
    bm.free()
    o = bpy.data.objects.new(nome, me)
    bpy.context.scene.collection.objects.link(o)
    o.data.materials.append(mat)
    for p in me.polygons:
        p.use_smooth = True
    return o


def raio(objs, origem, direcao):
    """O primeiro acerto de um raio contra VÁRIOS objetos: (ponto, normal).

    ⚠️ `ray_cast` no objeto ORIGINAL com o `depsgraph`, e não no objeto
    avaliado: no avaliado o raio não acha nada (medido em 23/09, §7.2).
    """
    dg = bpy.context.evaluated_depsgraph_get()
    melhor = None
    for o in objs:
        inv = o.matrix_world.inverted()
        ok, hit, n, _ = o.ray_cast(inv @ origem, inv.to_3x3() @ direcao, depsgraph=dg)
        if not ok:
            continue
        hit = o.matrix_world @ hit
        n = (o.matrix_world.to_3x3() @ n).normalized()
        d = (hit - origem).length
        if melhor is None or d < melhor[0]:
            melhor = (d, hit, n)
    return None if melhor is None else (melhor[1], melhor[2])


class Superficie:
    """Pousa coisas na cabeça, por FRAÇÃO da caixa medida e por raio."""

    def __init__(self, obj):
        self.obj = obj
        dg = bpy.context.evaluated_depsgraph_get()
        oe = obj.evaluated_get(dg)
        m = oe.to_mesh()
        vs = [v.co.copy() for v in m.vertices]
        oe.to_mesh_clear()
        self.lo = Vector([min(v[i] for v in vs) for i in range(3)])
        self.hi = Vector([max(v[i] for v in vs) for i in range(3)])

    def x(self, f):
        return f * self.hi.x

    def z(self, f):
        return self.lo.z + f * (self.hi.z - self.lo.z)

    def frente(self, fx, fz, fora=0.0):
        """O ponto da cara em (fx, fz), visto de frente (−y), e a normal."""
        r = raio([self.obj], Vector((self.x(fx), -10.0, self.z(fz))), Vector((0, 1, 0)))
        assert r, "o raio da frente não achou a cara em %s" % ((fx, fz),)
        return r[0] + r[1] * fora, r[1]


def suave(t):
    t = max(0.0, min(1.0, t))
    return t * t * (3.0 - 2.0 * t)


def interp(tabela, x):
    """Interpolação linear numa tabela [(x, y), ...] ordenada por x."""
    if x <= tabela[0][0]:
        return tabela[0][1]
    for (x0, y0), (x1, y1) in zip(tabela, tabela[1:]):
        if x <= x1:
            return y0 + (y1 - y0) * (x - x0) / (x1 - x0)
    return tabela[-1][1]


def aneis(niveis, n=48, centro_y=0.0):
    """Uma malha fechada por anéis de SUPERELIPSE, de cima para baixo.

    Cada nível é (z, meia_largura, fundo_frente, fundo_trás, expoente,
    inclinação): o expoente 2 é uma elipse e 3 já tem ombro; a inclinação
    baixa a frente do anel e sobe as costas, que é a linha do decote e do
    trapézio vistos de lado.
    """
    bm = bmesh.new()
    rings = []
    for z, hw, df, db, e, inc in niveis:
        anel = []
        for i in range(n):
            t = 2.0 * math.pi * i / n
            c, s = math.cos(t), math.sin(t)
            x = hw * math.copysign(abs(c) ** (2.0 / e), c)
            yn = math.copysign(abs(s) ** (2.0 / e), s)
            y = centro_y + (df if yn < 0 else db) * yn
            anel.append(bm.verts.new((x, y, z + inc * yn)))
        rings.append(anel)
    for a, b in zip(rings, rings[1:]):
        for i in range(n):
            j = (i + 1) % n
            bm.faces.new((a[i], a[j], b[j], b[i]))
    bm.normal_update()
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    return bm


def montar_cida(M):
    """Todas as peças do busto, de FRENTE (a cara olha para −y).

    As unidades são de mundo e o tamanho final não importa aqui: quem enquadra
    é `enquadrar()`, que mede a projeção e escala o grupo inteiro.
    """
    pele = M["pele_escura"]
    escuro = M["vao"]
    cabelo = principled("cabelo_cida", base.PALETA["madeira_esc"], rough=0.55, spec=0.25)
    blusa = principled("blusa_cida", base.PALETA["casco_pesca"], rough=0.9)

    # ── A CABEÇA, REDONDA ─────────────────────────────────────────────────
    # Os elipsoides da v1 (o ovo, o queixo largo, as bochechas à frente e as
    # orelhas), menos o NARIZ, que sai da malha — ver abaixo.
    cabeca = metaball("cabeca", [
        ((0.0, 0.00, 1.45), 1.00, (0.92, 0.86, 1.00)),   # o ovo
        ((0.0, -0.16, 0.93), 0.62, (0.96, 0.80, 0.72)),  # queixo largo
        # ⚠️ AS BOCHECHAS DEIXARAM DE SER ELIPSOIDES À PARTE. Na v1 (a ±0,33,
        # raio 0,34) cada uma deixava uma bossa abaixo da orelha; a ±0,30 com
        # raio 0,40 a cara voltou à PERA; e a ±0,26 mais acima saíram duas
        # papadas dos lados da boca. Quem enche a cara para a FRENTE é uma
        # massa só, larga, que se funde com o ovo sem vinco.
        ((0.0, -0.22, 1.12), 0.66, (1.06, 0.78, 0.76)),
        ((-0.56, 0.06, 1.33), 0.13, (0.5, 0.9, 1.1)),    # orelha
        ((0.56, 0.06, 1.33), 0.13, (0.5, 0.9, 1.1)),     # orelha
    ], pele, suavizar=10, nivel=2)
    s = Superficie(cabeca)
    pecas = [cabeca]
    # A meia-largura da CARA (sem orelhas), medida por um raio de lado à
    # altura das bochechas: é a régua de tudo o que vem abaixo do queixo.
    W = raio([cabeca], Vector((10.0, -0.25, s.z(0.35))), Vector((-1, 0, 0)))[0].x
    print("MEDIDAS cabeça x ±%.3f z %.3f..%.3f | W %.3f" % (s.hi.x, s.lo.z, s.hi.z, W))

    # ── OS OLHOS, EM ESFERA (como na v1) ──────────────────────────────────
    r_olho = 0.095
    brilho = emissao("brilho_olho", 4.0)   # AgX come a força 1: 211 → 4 dá 250
    iris = M["porta"]
    centros_olho = []
    for sx in (-1.0, 1.0):
        p, _n = s.frente(0.34 * sx, 0.60)
        c = p + Vector((0.0, 0.45 * r_olho, 0.0))
        centros_olho.append(c)
        pecas.append(esfera("olho_%+d" % sx, c, r_olho, M["cabine"]))
        pecas.append(esfera("iris_%+d" % sx, c + Vector((0, -0.70 * r_olho, 0)),
                            0.64 * r_olho, iris))
        pecas.append(esfera("pupila_%+d" % sx, c + Vector((0, -0.92 * r_olho, 0)),
                            0.34 * r_olho, escuro))
        pecas.append(esfera("brilho_%+d" % sx,
                            c + Vector((-0.30 * r_olho, -1.02 * r_olho, 0.30 * r_olho)),
                            0.22 * r_olho, brilho, seg=16))
        bpy.ops.mesh.primitive_uv_sphere_add(radius=r_olho * 1.12, location=c,
                                             segments=32, ring_count=16)
        pal = bpy.context.active_object
        pal.name = "palpebra_%+d" % sx
        bm = bmesh.new()
        bm.from_mesh(pal.data)
        bmesh.ops.delete(bm, geom=[v for v in bm.verts if v.co.z < -0.02 * r_olho],
                         context="VERTS")
        bm.to_mesh(pal.data)
        bm.free()
        # ⚠️ A -22° da v1 a pálpebra tapava um terço do olho e a cara lia
        # SONOLENTA; séria é atenta. A -12° o descanso fica só na borda.
        pal.rotation_euler.x = math.radians(-12.0)
        pal.data.materials.append(pele)
        bpy.ops.object.shade_smooth()
        pal.modifiers.new("espessura", "SOLIDIFY").thickness = 0.012
        pecas.append(pal)

        bpy.ops.mesh.primitive_torus_add(major_radius=r_olho * 1.55,
                                         minor_radius=0.016,
                                         major_segments=40, minor_segments=8,
                                         location=c + Vector((0, -1.35 * r_olho, 0)),
                                         rotation=(math.radians(90), 0, 0))
        aro = bpy.context.active_object
        aro.name = "oculos_%+d" % sx
        aro.data.materials.append(M["metal"])
        bpy.ops.object.shade_smooth()
        # ⚠️ SEM SOMBRA: a da chave desenhava um SEGUNDO aro na cara (v1).
        aro.visible_shadow = False
        pecas.append(aro)
    ponte_e, _ = s.frente(-0.13, 0.62, fora=0.05)
    ponte_d, _ = s.frente(0.13, 0.62, fora=0.05)
    meio, _ = s.frente(0.0, 0.64, fora=0.08)
    pecas.append(curva("oculos_ponte", [ponte_e, meio, ponte_d], 0.014, M["metal"]))
    pecas[-1].visible_shadow = False

    # ── O NARIZ, À PARTE E SEM SOMBRA ─────────────────────────────────────
    # ⚠️ Na v1 o nariz era um elipsoide da cabeça, e a chave (dura, 1,6°)
    # deitava a sombra dele à direita e para BAIXO, em cima da boca: os dois
    # escuros juntavam-se num bigode. Aqui ele é uma peça própria que NÃO
    # PROJETA sombra — continua a ser sombreado pela chave, que é o que lhe dá
    # volume. Mais largo do que alto e pouco saliente: nesta câmera o que
    # avança da cara desce na imagem (§7.5).
    p_nariz, n_nariz = s.frente(0.0, 0.47)
    nariz = esfera("nariz", p_nariz + n_nariz * 0.015, 0.075, pele, seg=24,
                   escala=(1.35, 0.85, 0.95))
    nariz.visible_shadow = False
    pecas.append(nariz)

    # ── SOBRANCELHAS E BOCA, EM CURVA ─────────────────────────────────────
    def na_cara(fx, fz, fora=0.02):
        return s.frente(fx, fz, fora)[0]
    # Sobrancelhas que AFILAM para fora: um tubo de espessura constante lia
    # como um traço de marcador. Séria = quase RETAS. ⚠️ Com a ponta de
    # dentro mais baixa (a primeira prévia) a cara lia ZANGADA, e zangada é
    # outra expressão. E «retas» mede-se na IMAGEM: a ponta de dentro está
    # mais à frente na cara, e o que avança desce — ela sobe na tabela para
    # sair à altura das outras.
    for sx in (-1.0, 1.0):
        pecas.append(curva("sobrancelha_%+d" % sx,
                           [na_cara(0.14 * sx, 0.784), na_cara(0.33 * sx, 0.776),
                            na_cara(0.52 * sx, 0.756)], 0.020, escuro,
                           raios=[1.0, 0.95, 0.45]))
    # A BOCA: entre o nariz e o queixo medidos, FINA e com as pontas afiladas
    # e um nada abaixo do meio. ⚠️ Na v1 era uma barra de 0,024 de ponta a
    # ponta — com a sombra do nariz por cima, um bigode. Sem a sombra, a
    # espessura já não tem de compensar nada.
    vs = [cabeca.matrix_world @ v.co for v in cabeca.data.vertices]
    queixo_z = min(v.z for v in vs if v.y < s.lo.y * 0.4 and abs(v.x) < 0.2)
    base_nariz = p_nariz.z - 0.06
    # ⚠️ A FRAÇÃO LÊ-SE NA IMAGEM: a 0,48 e a 0,42 do caminho nariz→queixo
    # a boca saiu a dois terços dele na tela — o queixo recua, e a câmera de
    # cima encurta o que está abaixo da boca. Sem a sombra do nariz, ela pode
    # subir sem colar a nada.
    fz = ((base_nariz - 0.30 * (base_nariz - queixo_z)) - s.lo.z) / (s.hi.z - s.lo.z)
    pecas.append(curva("boca", [na_cara(-0.25, fz - 0.003), na_cara(-0.10, fz + 0.001),
                                na_cara(0.10, fz + 0.001), na_cara(0.25, fz - 0.003)],
                       0.016, escuro, raios=[0.55, 1.0, 1.0, 0.55]))

    # ── O CABELO: UMA CASCA TIRADA DA CABEÇA ──────────────────────────────
    # ⚠️ Na v1 o cabelo era uma bola de metaball maior do que a cabeça,
    # cortada por um plano: lia como CAPACETE — uma aba reta sobre a testa e a
    # massa descolada do crânio. Cabelo preso num coque é o contrário: COLADO
    # ao crânio. A casca sai da malha da própria cabeça, afastada pela normal
    # uma fração que cresce da linha do cabelo para o alto; a linha do cabelo
    # desce para as têmporas e passa por cima das orelhas.
    dg = bpy.context.evaluated_depsgraph_get()
    cabelo_me = bpy.data.meshes.new_from_object(cabeca.evaluated_get(dg))
    C = Vector((0.0, 0.0, s.z(0.62)))
    # O COQUE, atrás e ACIMA — é silhueta, e silhueta sobrevive ao tamanho.
    # ⚠️ A (0; 0,80; 0,60) ele saía no ALTO da cabeça e somava altura ao que
    # o enquadramento mede (a cabeça vale 60% do quadro): a cara encolhia na
    # caixa do telefone. Mais para trás, ele continua a ser silhueta.
    eixo = Vector((0.0, 0.86, 0.51)).normalized()
    # A orelha é a malha com |x| acima de 92% da maior: a linha do cabelo
    # passa por cima dela, com folga.
    orelha_topo = max(v.z for v in vs if abs(v.x) > 0.92 * s.hi.x)
    # A linha do cabelo por AZIMUTE à volta do eixo vertical: 0° é o meio da
    # testa, 90° a orelha, 180° a nuca. Frações da caixa MEDIDA.
    # Um ARCO: alto no meio da testa, a descer para as têmporas. ⚠️ Com o
    # meio a 0,835 e os 35° a 0,80 a câmera de cima achatava-o numa reta, e
    # a testa ficava com a franja de uma tigela.
    linha = [(0.0, s.z(0.885)), (30.0, s.z(0.855)), (60.0, s.z(0.73)),
             (80.0, orelha_topo + 0.04), (100.0, orelha_topo + 0.03),
             (118.0, s.z(0.38)), (180.0, s.z(0.22))]
    faixa = 0.22 * W
    # ⚠️ A LINHA DO CABELO NÃO SE FAZ APAGANDO VÉRTICES. A primeira versão
    # apagava os que ficavam abaixo dela, e a borda saiu SERRILHADA na testa —
    # a escada dos triângulos da malha, a 0,014 de altura da pele. A casca
    # agora ENTRA na pele numa faixa estreita (o afastamento passa de
    # negativo a positivo), e a borda é a interseção de duas superfícies
    # lisas: uma curva limpa que segue a tabela acima. Só se apaga o que fica
    # muito abaixo, que está escondido dentro da cabeça.
    entra = 0.05 * W
    # Os SULCOS: meridianos à volta do eixo do coque, a convergir nele. Rasos
    # e LARGOS o bastante para a malha os desenhar — ⚠️ três tubos pousados
    # por quatro pontos (a v1) levantavam-se do crânio entre um ponto e outro
    # e o alto da cabeça saía com espetos.
    u = Vector((1.0, 0.0, 0.0))
    v = eixo.cross(u).normalized()
    N_SULCOS = 22
    bm = bmesh.new()
    bm.from_mesh(cabelo_me)
    bpy.data.meshes.remove(cabelo_me)
    bm.normal_update()
    fora = []
    for vert in bm.verts:
        p = vert.co
        az = math.degrees(math.atan2(abs(p.x), -p.y))
        zl = interp(linha, az)
        if p.z < zl - 3.0 * entra:
            fora.append(vert)
            continue
        w = suave((p.z - zl) / faixa)
        borda = suave((p.z - zl + entra) / (2.0 * entra))
        d = p - C
        # Volume: colado na linha do cabelo, cheio no alto de trás, onde o
        # cabelo puxado se junta antes de entrar no coque.
        cheio = suave((d.normalized().dot(eixo) + 0.2) / 0.9)
        off = 0.014 + (0.030 + 0.050 * cheio) * w
        # O sulco: ângulo à volta do eixo do coque. Começa ACIMA da linha do
        # cabelo — rente a ela recortava a borda em franjas.
        phi = math.atan2(d.dot(v), d.dot(u))
        onda = (0.5 + 0.5 * math.cos(N_SULCOS * phi)) ** 3
        perto_coque = suave((d.normalized().dot(eixo) - 0.55) / 0.3)
        sulco = suave((p.z - zl) / (1.6 * faixa))
        off -= 0.022 * onda * sulco * (1.0 - perto_coque)
        off = -0.04 * W + (off + 0.04 * W) * borda
        vert.co = p + vert.normal * off
    bmesh.ops.delete(bm, geom=fora, context="VERTS")
    massa = objeto_de_malha("cabelo", bm, cabelo)
    sub = massa.modifiers.new("sub", "SUBSURF")
    sub.levels = sub.render_levels = 1
    pecas.append(massa)

    # O coque: uma bola ACHATADA, com a espiral de um cabelo enrolado. ⚠️ A
    # v1 tinha uma segunda esfera por cima e saía em CEBOLA, com bico.
    sup = raio([massa], C + eixo * 5.0, -eixo)
    assert sup, "o eixo do coque não achou o cabelo"
    r_coque = 0.56 * W
    coque_c = sup[0] + eixo * (0.72 * r_coque)
    bpy.ops.mesh.primitive_uv_sphere_add(radius=r_coque, location=coque_c,
                                         segments=64, ring_count=32)
    coque = bpy.context.active_object
    coque.name = "coque"
    bm = bmesh.new()
    bm.from_mesh(coque.data)
    bm.normal_update()
    for vert in bm.verts:
        # Local: o polo do coque é o eixo; a espiral é o ângulo em volta dele
        # somado ao ângulo polar — uma volta de cabelo enrolado.
        q = vert.co.normalized()
        pol = math.acos(max(-1.0, min(1.0, q.dot(eixo))))
        ang = math.atan2(q.dot(v), q.dot(u))
        onda = (0.5 + 0.5 * math.cos(ang + 5.0 * pol)) ** 2
        esc = 1.0 - 0.22 * (q.dot(eixo) ** 2)        # achata no eixo
        vert.co = vert.co * esc - vert.normal * (0.06 * r_coque * onda)
    bm.to_mesh(coque.data)
    bm.free()
    coque.data.materials.append(cabelo)
    bpy.ops.object.shade_smooth()
    pecas.append(coque)
    # A LIGA entre o cabelo e o coque: fina — a v1 tinha-a larga.
    bpy.ops.mesh.primitive_torus_add(major_radius=0.62 * r_coque, minor_radius=0.07 * r_coque,
                                     major_segments=40, minor_segments=10,
                                     location=sup[0] + eixo * (0.10 * r_coque))
    liga = bpy.context.active_object
    liga.name = "coque_liga"
    liga.rotation_mode = "QUATERNION"
    liga.rotation_quaternion = Vector((0, 0, 1)).rotation_difference(eixo)
    liga.data.materials.append(M["colete"])
    bpy.ops.object.shade_smooth()
    pecas.append(liga)

    # ── AS HASTES DOS ÓCULOS, do aro até à orelha, por cima do cabelo ─────
    for sx, c in zip((-1.0, 1.0), centros_olho):
        a0 = c + Vector((sx * 1.55 * r_olho, -1.30 * r_olho, 0.02))
        ok = raio([massa, cabeca], Vector((sx * 10.0, 0.0, orelha_topo + 0.01)),
                  Vector((-sx, 0, 0)))
        a2 = ok[0] + ok[1] * 0.02
        ok1 = raio([massa, cabeca], Vector((sx * 10.0, (a0.y + a2.y) / 2, (a0.z + a2.z) / 2)),
                   Vector((-sx, 0, 0)))
        a1 = ok1[0] + ok1[1] * 0.02
        pecas.append(curva("oculos_haste_%+d" % sx, [a0, a1, a2], 0.011, M["metal"]))
        pecas[-1].visible_shadow = False

    # ── O LÁPIS, POUSADO ATRÁS DA ORELHA DIREITA (da imagem) ──────────────
    # ⚠️ Na v1 ele estava 0,10 FORA da orelha e flutuava ao lado da cabeça.
    # Lápis atrás da orelha ENCOSTA: deitado quase de frente para trás, em
    # cima da raiz da orelha e contra o cabelo, com a ponta à frente e um nada
    # para baixo. ⚠️ Pousado só pela TANGENTE da cabeça (uma prévia), a ponta
    # atravessava a orelha — que é uma bossa, não o casco convexo — e só se
    # via a ponta de trás, a espetar do cabelo como um pauzinho.
    topo = max((vv for vv in vs if vv.x > 0.92 * s.hi.x), key=lambda vv: vv.z)
    ok = raio([massa, cabeca], Vector((10.0, topo.y, topo.z + 0.03)), Vector((-1, 0, 0)))
    assert ok, "o lápis não achou a cabeça"
    r_lapis = 0.040
    dirl = Vector((0.06, -1.0, -0.38)).normalized()
    centro_l = Vector((ok[0].x + 0.9 * r_lapis, topo.y + 0.03, topo.z + 0.7 * r_lapis))
    comp = 0.58
    rot = Vector((0, 0, 1)).rotation_difference(dirl)
    bpy.ops.mesh.primitive_cylinder_add(radius=r_lapis, depth=comp, vertices=6,
                                        location=centro_l)
    lapis = bpy.context.active_object
    lapis.name = "lapis"
    lapis.rotation_mode = "QUATERNION"
    lapis.rotation_quaternion = rot
    lapis.data.materials.append(M["capacete"])
    pecas.append(lapis)
    # A madeira apontada e o grafite: é a ponta que diz LÁPIS a este tamanho.
    for nome, dist, rr, prof, mat in (("lapis_madeira", comp / 2 + 0.05, r_lapis, 0.10, M["madeira"]),
                                      ("lapis_grafite", comp / 2 + 0.115, r_lapis * 0.35, 0.035, escuro)):
        bpy.ops.mesh.primitive_cone_add(radius1=rr, radius2=0.0, depth=prof, vertices=12,
                                        location=centro_l + dirl * dist)
        o = bpy.context.active_object
        o.name = nome
        o.rotation_mode = "QUATERNION"
        o.rotation_quaternion = rot
        o.data.materials.append(mat)
        pecas.append(o)

    # ── O PESCOÇO E O TRONCO, POR ANÉIS ───────────────────────────────────
    # ⚠️ Na v1 o tronco eram cinco elipsoides fundidos: cada um deixava uma
    # bossa e não havia OMBRO — lia como um balão verde. Aqui é uma malha por
    # anéis de superelipse: o trapézio desce do pescoço até ao ombro, que é
    # uma quina macia (expoente 3), e o braço cai a direito para fora do
    # quadro. Tudo em unidades de W (a meia-largura da cara MEDIDA).
    # ⚠️ A PRIMEIRA PRÉVIA saiu com o tronco colado ao queixo e os ombros
    # quadrados e altos: um BLOCO verde, sem pescoço à vista. O decote desce
    # (a câmera de cima esconde o pescoço atrás do queixo, e só se vê o que
    # fica abaixo dele), o trapézio inclina mais e a quina do ombro amacia.
    zn = s.lo.z - 0.24 * W           # a base do pescoço, à frente
    yc = 0.10 * W                    # o tronco um nada para trás da cara
    tronco_niveis = [
        # (z, meia-largura, fundo à frente, fundo atrás, expoente, inclinação)
        (zn + 0.00 * W, 0.52 * W, 0.44 * W, 0.44 * W, 2.0, 0.18 * W),  # decote
        (zn - 0.10 * W, 0.82 * W, 0.52 * W, 0.50 * W, 2.2, 0.12 * W),
        (zn - 0.30 * W, 1.26 * W, 0.60 * W, 0.56 * W, 2.5, 0.05 * W),  # trapézio
        (zn - 0.55 * W, 1.62 * W, 0.66 * W, 0.60 * W, 2.7, 0.0),       # ombro
        (zn - 0.82 * W, 1.84 * W, 0.72 * W, 0.62 * W, 2.8, 0.0),
        (zn - 1.15 * W, 1.92 * W, 0.80 * W, 0.64 * W, 2.8, 0.0),       # braço
        (zn - 1.60 * W, 1.90 * W, 0.86 * W, 0.66 * W, 2.8, 0.0),       # peito
        (zn - 2.40 * W, 1.86 * W, 0.80 * W, 0.66 * W, 2.8, 0.0),
        (zn - 3.60 * W, 1.84 * W, 0.78 * W, 0.66 * W, 2.8, 0.0),       # fora do quadro
    ]
    tronco = objeto_de_malha("tronco", aneis(tronco_niveis, centro_y=yc), blusa)
    sub = tronco.modifiers.new("sub", "SUBSURF")
    sub.levels = sub.render_levels = 2
    pescoco_niveis = [
        (s.z(0.40), 0.36 * W, 0.36 * W, 0.36 * W, 2.0, 0.0),
        (zn + 0.30 * W, 0.40 * W, 0.40 * W, 0.40 * W, 2.0, 0.0),
        (zn - 0.05 * W, 0.46 * W, 0.42 * W, 0.42 * W, 2.0, 0.0),
        (zn - 0.40 * W, 0.50 * W, 0.44 * W, 0.44 * W, 2.0, 0.0),
    ]
    pescoco = objeto_de_malha("pescoco", aneis(pescoco_niveis, n=32, centro_y=yc), pele)
    sub = pescoco.modifiers.new("sub", "SUBSURF")
    sub.levels = sub.render_levels = 1
    pecas += [pescoco, tronco]
    bpy.context.view_layer.update()

    # ── A GOLA: DUAS ABAS COM PONTA, E O PÉ À VOLTA DO PESCOÇO ────────────
    # ⚠️ Na v1 eram dois discos: leram como dois algodões no peito. Gola de
    # blusa tem PONTA: as abas descem deitadas no peito até à ponta, e o PÉ
    # da gola dá a volta por trás do pescoço. Cada aba é um retalho bilinear
    # entre quatro cantos no plano da frente, pousado ponto a ponto por raio
    # no pescoço E no tronco (o que estiver mais à frente).
    # ⚠️ E AS ABAS NÃO SOBEM PELO PESCOÇO: na primeira prévia o canto de
    # cima subia até ao lado dele, a superfície ficava a pique e a aba
    # esticava-se em listras. Quem sobe é o pé, que é uma fita à parte.
    gola = principled("gola_cida", base.PALETA["cabine"], rough=0.9)
    pe = aneis([(zn + 0.00 * W, 0.50 * W, 0.46 * W, 0.46 * W, 2.0, 0.18 * W),
                (zn + 0.16 * W, 0.47 * W, 0.43 * W, 0.43 * W, 2.0, 0.18 * W)],
               n=48, centro_y=yc)
    bmesh.ops.delete(pe, geom=[vv for vv in pe.verts if vv.co.y < yc - 0.30 * W],
                     context="VERTS")
    pe_gola = objeto_de_malha("gola_pe", pe, gola)
    so = pe_gola.modifiers.new("espessura", "SOLIDIFY")
    so.thickness = 0.025 * W
    sub = pe_gola.modifiers.new("sub", "SUBSURF")
    sub.levels = sub.render_levels = 1
    pecas.append(pe_gola)
    for sx in (-1.0, 1.0):
        A = Vector((0.03 * W * sx, zn - 0.10 * W))     # meio, na base do pescoço
        B = Vector((0.50 * W * sx, zn - 0.02 * W))     # lado da base do pescoço
        Cc = Vector((1.00 * W * sx, zn - 0.36 * W))    # para o ombro
        D = Vector((0.34 * W * sx, zn - 0.74 * W))     # a PONTA, no peito
        nu, nv = 10, 10
        bm = bmesh.new()
        grade = []
        for j in range(nv + 1):
            fv = j / nv
            linha_v = []
            for i in range(nu + 1):
                fu = i / nu
                q = (A * (1 - fu) * (1 - fv) + B * fu * (1 - fv)
                     + Cc * fu * fv + D * (1 - fu) * fv)
                # Perto do pescoço o raio pode passar ENTRE ele e o trapézio;
                # desce-se até acertar, em vez de inventar um ponto.
                ok = None
                for k in range(12):
                    ok = raio([tronco, pescoco], Vector((q.x, -10.0, q.y - 0.02 * W * k)),
                              Vector((0, 1, 0)))
                    if ok:
                        break
                assert ok, "a gola não achou o peito em %s" % (tuple(q),)
                pto = ok[0] + ok[1] * 0.018 * W
                linha_v.append(bm.verts.new(pto))
            grade.append(linha_v)
        for j in range(nv):
            for i in range(nu):
                f = (grade[j][i], grade[j][i + 1], grade[j + 1][i + 1], grade[j + 1][i])
                bm.faces.new(f if sx > 0 else tuple(reversed(f)))
        bm.normal_update()
        aba = objeto_de_malha("gola_%+d" % sx, bm, gola)
        so = aba.modifiers.new("espessura", "SOLIDIFY")
        so.thickness = 0.03 * W
        so.offset = 1.0
        sub = aba.modifiers.new("sub", "SUBSURF")
        sub.levels = sub.render_levels = 1
        pecas.append(aba)

    # Os BOTÕES da blusa, abaixo das pontas da gola: é o que diz BLUSA em vez
    # de camisola, e dá ao peito o desenho que a v1 não tinha.
    for k, fz_b in enumerate((0.78, 1.12, 1.46)):
        ok = raio([tronco], Vector((0.0, -10.0, zn - fz_b * W)), Vector((0, 1, 0)))
        assert ok, "o botão não achou o peito"
        b = esfera("botao_%d" % k, ok[0] + ok[1] * 0.01 * W, 0.07 * W, gola,
                   seg=16, escala=(1.0, 0.45, 1.0))
        pecas.append(b)
    return pecas


def pixels(cena, objs):
    """Caixa de todos os vértices AVALIADOS, em pixels do PNG (y para baixo)."""
    dg = bpy.context.evaluated_depsgraph_get()
    res = cena.render.resolution_x
    xs, ys = [], []
    for o in objs:
        oe = o.evaluated_get(dg)
        try:
            m = oe.to_mesh()
        except RuntimeError:
            continue
        mw = oe.matrix_world
        for v in m.vertices:
            p = world_to_camera_view(cena, cena.camera, mw @ v.co)
            xs.append(p.x * res)
            ys.append((1.0 - p.y) * res)
        oe.to_mesh_clear()
    return min(xs), min(ys), max(xs), max(ys)


def enquadrar(cena, pecas):
    """Escala e move o GRUPO para o enquadramento de hoje, medindo a projeção.

    O mesmo da v1: mede-se a cabeça a uma escala conhecida, escala-se para a
    altura-alvo e depois desloca-se no plano da imagem até o topo e o centro
    baterem.
    """
    bpy.ops.object.empty_add(location=(0, 0, 0))
    piv = bpy.context.active_object
    piv.name = "pivo_retrato"
    for o in pecas:
        o.parent = piv
    piv.rotation_euler.z = math.radians(45.0)
    bpy.context.view_layer.update()
    cabeca_e_cabelo = [o for o in pecas if o.name.startswith(("cabeca", "cabelo", "coque"))]
    x0, y0, x1, y1 = pixels(cena, cabeca_e_cabelo)
    # A CABEÇA VALE 60% DO QUADRO, como hoje.
    k = (0.60 * cena.render.resolution_y) / (y1 - y0)
    piv.scale = (k, k, k)
    bpy.context.view_layer.update()
    ref = pixels(cena, cabeca_e_cabelo)
    piv.location.z += 1.0
    bpy.context.view_layer.update()
    px_z = ref[1] - pixels(cena, cabeca_e_cabelo)[1]
    piv.location.z -= 1.0
    piv.location.x += 1.0
    bpy.context.view_layer.update()
    novo = pixels(cena, cabeca_e_cabelo)
    px_x = (novo[0] - ref[0], novo[1] - ref[1])
    piv.location.x -= 1.0
    f = cena.render.resolution_x / 768.0
    dx_alvo = CENTRO_X_PX * f - (ref[0] + ref[2]) / 2.0
    ax = dx_alvo / px_x[0]
    dy_depois_x = px_x[1] * ax
    dz = (ref[1] + dy_depois_x - TOPO_PX * f) / px_z
    piv.location.x += ax
    piv.location.z += dz
    bpy.context.view_layer.update()
    return pixels(cena, pecas), pixels(cena, cabeca_e_cabelo), k


def main() -> int:
    if len(sys.argv) < 2:
        print(__doc__.strip())
        return 2
    saida = pathlib.Path(sys.argv[-1]).resolve()
    est = Estudio("porto")
    if os.environ.get("PREVIA") == "1":
        est.cena.render.resolution_x = est.cena.render.resolution_y = 384
        est.cena.cycles.samples = 16
    pecas = montar_cida(est.M)
    tudo, cabeca, k = enquadrar(est.cena, pecas)
    print("ENQUADRAMENTO busto x %.0f..%.0f y %.0f..%.0f | cabeça x %.0f..%.0f y %.0f..%.0f | escala %.3f"
          % (tudo[0], tudo[2], tudo[1], tudo[3], cabeca[0], cabeca[2], cabeca[1], cabeca[3], k))
    for o in pecas:
        o.name = "%s_%s" % (NOME, o.name)
    est.registrar(NOME, pecas, ancora="retrato")
    est.exportar(str(saida), [NOME])
    print("RETRATO SALVO EM %s" % (saida / ("%s.png" % NOME)))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
