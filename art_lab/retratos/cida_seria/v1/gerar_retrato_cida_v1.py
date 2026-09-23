"""Dona Cida, expressão SÉRIA — candidata v1 da cabeça REDONDA (frente 2 do A5).

    python3.11 art_lab/retratos/cida_seria/v1/gerar_retrato_cida_v1.py <pasta>

Grava `<pasta>/retrato_cida_seria.png` (768×768, alfa verdadeiro). É uma
CANDIDATA: não escreve em `brport_vs/` e não toca no manifest. O retrato do
jogo continua a ser o de `blender/brp_porto.py` até o Bruno aprovar a foto do
jogo (`art_lab/README.md` §3).

NÃO É UM SEGUNDO ESTÚDIO. A câmera, o rig de três pontos, a paleta, a
resolução e o render saem do `Estudio` de `blender/brp_studio.py`, que por sua
vez os tira de `tools/gerar_props_iso.py` — o mesmo caminho dos nove retratos
de hoje. O que muda é só a GEOMETRIA, e é isso que se quer comparar. Pela mesma
razão o render usa a transformada de cor de hoje (o AgX que ninguém declarou,
plano de arte §7.1): trocar a cor ao mesmo tempo que o modelo misturaria as
duas perguntas.

O que esta versão aplica, e onde cada coisa foi pesquisada e medida (plano de
arte §7.2 e §7.5): cabeça de METABALL suavizada (P1), forma REDONDA por ser ela
(P2), olhos em ESFERA com BRILHO e PÁLPEBRA (P3), sobrancelhas e boca em CURVA
(P4), e o cabelo em MECHAS que puxam para o coque. Os traços de identidade de
hoje ficam: coque atrás e acima, óculos, lápis atrás da orelha, gola clara e a
blusa verde.
"""

from __future__ import annotations

import math
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


def metaball(nome, elementos, mat, resolucao=0.035):
    """Funde elipsoides numa forma macia e devolve-a como MALHA suavizada.

    ⚠️ A SUPERFÍCIE SAI MENOR DO QUE OS RAIOS ESCRITOS (medido: raio 0,95 deu
    ±0,54), e por isso NADA se posiciona em coordenadas supostas: as feições
    pousam por `ray_cast` na malha que ficou (§7.2, P1).
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
    sub = malha.modifiers.new("sub", "SUBSURF")
    sub.levels = sub.render_levels = 1
    return malha


def esfera(nome, centro, raio, mat, seg=32):
    bpy.ops.mesh.primitive_uv_sphere_add(radius=raio, location=centro,
                                         segments=seg, ring_count=seg // 2)
    o = bpy.context.active_object
    o.name = nome
    o.data.materials.append(mat)
    bpy.ops.object.shade_smooth()
    return o


def curva(nome, pontos, espessura, mat, raios=None):
    """Um tubo por uma curva Bézier. `raios` afila (mecha) — 1,0 é inteiro."""
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


class Superficie:
    """Pousa coisas na cabeça, por FRAÇÃO da caixa medida e por raio.

    ⚠️ `ray_cast` no objeto ORIGINAL com o `depsgraph`, e não no objeto
    avaliado: no avaliado o raio não acha nada (medido em 23/09, §7.2).
    """

    def __init__(self, obj):
        self.obj = obj
        self.dg = bpy.context.evaluated_depsgraph_get()
        bb = [Vector(v) for v in obj.bound_box]
        self.lo = Vector([min(v[i] for v in bb) for i in range(3)])
        self.hi = Vector([max(v[i] for v in bb) for i in range(3)])

    def x(self, f):
        return f * self.hi.x

    def z(self, f):
        return self.lo.z + f * (self.hi.z - self.lo.z)

    def frente(self, fx, fz, fora=0.0):
        """O ponto da cara em (fx, fz), visto de frente (−y), e a normal."""
        ok, hit, n, _ = self.obj.ray_cast(Vector((self.x(fx), -10.0, self.z(fz))),
                                          Vector((0, 1, 0)), depsgraph=self.dg)
        assert ok, "o raio da frente não achou a cara em %s" % ((fx, fz),)
        return hit + n * fora, n

    def lado(self, y, fz):
        """O ponto da orelha direita, por um raio vindo de +x."""
        ok, hit, n, _ = self.obj.ray_cast(Vector((10.0, y, self.z(fz))),
                                          Vector((-1, 0, 0)), depsgraph=self.dg)
        assert ok, "o raio do lado não achou a cabeça em %s" % ((y, fz),)
        return hit

    def cima(self, x, y, fora=0.0):
        """O ponto do alto da cabeça em (x, y), visto de CIMA.

        ⚠️ A testa é mais estreita do que a caixa: se o raio falha, recua
        para o meio em vez de inventar um ponto (medido nas mechas, §7.5).
        """
        for ky in (1.0, 0.85, 0.7, 0.55):
            for k in (1.0, 0.85, 0.7, 0.55, 0.4):
                ok, hit, n, _ = self.obj.ray_cast(Vector((x * k, y * ky, 10.0)),
                                                  Vector((0, 0, -1)), depsgraph=self.dg)
                if ok and hit.z > self.z(0.45):
                    return hit + n * fora
        raise AssertionError("o raio de cima não achou a cabeça em %s" % ((x, y),))


def montar_cida(M):
    """Todas as peças do busto, de FRENTE (a cara olha para −y).

    As unidades são de mundo e o tamanho final não importa aqui: quem enquadra
    é `enquadrar()`, que mede a projeção e escala o grupo inteiro — a regra de
    "encolher escala-se no GRUPO" do `CLAUDE.md`.
    """
    pele = M["pele_escura"]
    cabelo = M["madeira_esc"]
    escuro = M["vao"]

    # ── A CABEÇA, REDONDA ─────────────────────────────────────────────────
    # P2: a forma dela é o CÍRCULO — acolhedora, e a que a separa do Sr.
    # Ribeiro (retângulo) e do Arlindo (ângulo). Bochechas cheias e queixo
    # curto e macio; o crânio é largo em cima. Nariz PEQUENO, de propósito:
    # nesta câmera o que avança da cara desce na imagem, e um nariz grande
    # tapou a boca inteira no manequim (§7.5).
    # ⚠️ A PRIMEIRA TENTATIVA SAIU EM PERA: bochechas a ±0,46 incharam a cara
    # para os LADOS e o queixo afinou em bico — o triângulo que é do Arlindo.
    # Redondo é um OVO com as bochechas a encher para a FRENTE e o queixo
    # largo e curto; as orelhas encostadas, que de fora liam como asas.
    cabeca = metaball("cabeca", [
        ((0.0, 0.00, 1.45), 1.00, (0.92, 0.86, 1.00)),   # o ovo
        # O queixo desce: curto demais, a boca não tinha onde ficar — ou colava
        # ao nariz (bigode) ou caía na linha do queixo.
        ((0.0, -0.16, 0.88), 0.62, (0.96, 0.80, 0.72)),  # queixo largo
        ((-0.33, -0.33, 1.06), 0.34, (1.0, 0.9, 0.9)),   # bochecha, à frente
        ((0.33, -0.33, 1.06), 0.34, (1.0, 0.9, 0.9)),    # bochecha, à frente
        ((0.0, -0.74, 1.27), 0.11, (1, 1, 1)),           # nariz-botão
        ((-0.56, 0.06, 1.33), 0.13, (0.5, 0.9, 1.1)),    # orelha
        ((0.56, 0.06, 1.33), 0.13, (0.5, 0.9, 1.1)),     # orelha
    ], pele)
    s = Superficie(cabeca)
    pecas = [cabeca]

    # ── OS OLHOS, EM ESFERA ───────────────────────────────────────────────
    # P3: o olhar é a posição da íris; a pálpebra é uma casca. Séria = olhar em
    # frente e pálpebra de descanso (tapa o topo do olho, que é o que dá calma
    # sem sono).
    raio = 0.095
    brilho = emissao("brilho_olho", 4.0)   # AgX come a força 1: 211 → 4 dá 250
    iris = M["porta"]
    for sx in (-1.0, 1.0):
        p, _n = s.frente(0.34 * sx, 0.60)
        c = p + Vector((0.0, 0.45 * raio, 0.0))
        pecas.append(esfera("olho_%+d" % sx, c, raio, M["cabine"]))
        pecas.append(esfera("iris_%+d" % sx, c + Vector((0, -0.70 * raio, 0)),
                            0.64 * raio, iris))
        pecas.append(esfera("pupila_%+d" % sx, c + Vector((0, -0.92 * raio, 0)),
                            0.34 * raio, escuro))
        # O BRILHO fica em cima e do lado da luz-chave, que vem da esquerda da
        # imagem — fixo, sem depender de a luz calhar num reflexo.
        pecas.append(esfera("brilho_%+d" % sx,
                            c + Vector((-0.30 * raio, -1.02 * raio, 0.30 * raio)),
                            0.22 * raio, brilho, seg=16))
        bpy.ops.mesh.primitive_uv_sphere_add(radius=raio * 1.12, location=c,
                                             segments=32, ring_count=16)
        pal = bpy.context.active_object
        pal.name = "palpebra_%+d" % sx
        bm = bmesh.new()
        bm.from_mesh(pal.data)
        bmesh.ops.delete(bm, geom=[v for v in bm.verts if v.co.z < -0.02 * raio],
                         context="VERTS")
        bm.to_mesh(pal.data)
        bm.free()
        pal.rotation_euler.x = math.radians(-22.0)
        pal.data.materials.append(pele)
        bpy.ops.object.shade_smooth()
        pal.modifiers.new("espessura", "SOLIDIFY").thickness = 0.012
        pecas.append(pal)

        # ÓCULOS REDONDOS — a forma dela outra vez. Aro FINO mas não de um
        # pixel: 0,016 de raio menor dá ~2 px na caixa do telefone.
        bpy.ops.mesh.primitive_torus_add(major_radius=raio * 1.55,
                                         minor_radius=0.016,
                                         major_segments=40, minor_segments=8,
                                         location=c + Vector((0, -1.35 * raio, 0)),
                                         rotation=(math.radians(90), 0, 0))
        aro = bpy.context.active_object
        aro.name = "oculos_%+d" % sx
        aro.data.materials.append(M["metal"])
        bpy.ops.object.shade_smooth()
        # ⚠️ SEM SOMBRA: a da chave caía na cara e desenhava um SEGUNDO aro,
        # mais escuro e deslocado — a 168 px lia como óculos duplos.
        aro.visible_shadow = False
        pecas.append(aro)
    ponte_e, _ = s.frente(-0.13, 0.62, fora=0.05)
    ponte_d, _ = s.frente(0.13, 0.62, fora=0.05)
    meio, _ = s.frente(0.0, 0.64, fora=0.08)
    pecas.append(curva("oculos_ponte", [ponte_e, meio, ponte_d], 0.014, M["metal"]))
    pecas[-1].visible_shadow = False

    # ── SOBRANCELHAS E BOCA, EM CURVA ─────────────────────────────────────
    # P4: a expressão é a posição de três pontos. Séria = sobrancelha quase
    # reta e boca reta com as pontas um nada abaixo, que é a cara de quem fez
    # as contas e não gostou. Tubos de ≥ 2 px na caixa do telefone.
    def na_cara(fx, fz, fora=0.02):
        return s.frente(fx, fz, fora)[0]
    for sx in (-1.0, 1.0):
        pecas.append(curva("sobrancelha_%+d" % sx,
                           [na_cara(0.15 * sx, 0.756), na_cara(0.34 * sx, 0.766),
                            na_cara(0.53 * sx, 0.750)], 0.022, escuro))
    # ⚠️ A BOCA POUSA ENTRE MARCOS MEDIDOS, não numa fração suposta: na
    # primeira tentativa ela caiu debaixo do nariz e, em `pele_sombra`, não se
    # via — a 168 px ela precisa do escuro das sobrancelhas. O nariz é o
    # vértice mais à frente; o queixo, o mais baixo da frente.
    vs = [cabeca.matrix_world @ v.co for v in cabeca.data.vertices]
    nariz = min(vs, key=lambda v: v.y)
    queixo = min((v for v in vs if v.y < s.lo.y * 0.4), key=lambda v: v.z)
    # ⚠️ A 42% do caminho nariz→queixo a boca colou à sombra do nariz e os
    # dois leram-se como BIGODE: a câmera olha de cima e encurta essa
    # distância na imagem. Com o queixo mais comprido, a meio ela descola.
    fz = ((nariz.z - 0.50 * (nariz.z - queixo.z)) - s.lo.z) / (s.hi.z - s.lo.z)
    # E LARGA: a ±0,19 os três pontos ficavam tão juntos que o tubo fechava
    # num "o" — a cara de quem assobia, não a de quem fez as contas.
    pecas.append(curva("boca", [na_cara(-0.27, fz - 0.004), na_cara(0.0, fz),
                                na_cara(0.27, fz - 0.004)], 0.024, escuro))

    # ── O CABELO: MASSA, MECHAS E COQUE ───────────────────────────────────
    # A MASSA é uma casca de metaball por cima do crânio: sem ela a pele
    # apareceria entre as mechas. As MECHAS dão o desenho (grande-médio-
    # pequeno: poucas e gordas), e todas puxam para trás, para o coque.
    massa = metaball("cabelo_massa", [
        ((0.0, 0.10, 1.78), 1.02, (1.02, 0.94, 0.90)),
    ], cabelo)
    # A franja não pode descer sobre a cara: corta-se a massa na linha do
    # cabelo pela frente, com uma inclinação para trás nas têmporas.
    bm = bmesh.new()
    bm.from_mesh(massa.data)
    linha = s.z(0.80)
    bmesh.ops.delete(bm, geom=[v for v in bm.verts
                               if v.co.z < linha - 0.35 * max(0.0, v.co.y + 0.2)
                               and v.co.y < 0.35], context="VERTS")
    bm.to_mesh(massa.data)
    bm.free()
    pecas.append(massa)
    # O coque mais ATRÁS e maior: em cima da cabeça ele fazia uma cebola.
    coque_c = Vector((0.0, 0.78, s.z(0.93)))
    # ⚠️ AS MECHAS DA PRIMEIRA TENTATIVA PENDURARAM-SE NA TESTA como
    # dreadlocks: eram tubos inteiros pousados na CABEÇA, com a ponta da frente
    # fora da massa. Cabelo penteado para trás são SULCOS: tubos meio
    # enterrados na MASSA (`fora` negativo), que só levantam um relevo — e
    # pousam nela, que é onde o cabelo está.
    sm = Superficie(massa)
    # TRÊS, e rasas: com quatro a convergir no coque o alto da cabeça saía uma
    # coroa de espetos.
    for i, fx in enumerate((-0.55, 0.0, 0.55)):
        x = sm.x(fx)
        pts = [sm.cima(x, 0.50 * sm.lo.y, fora=-0.03), sm.cima(x * 0.9, 0.15 * sm.lo.y, fora=-0.02),
               sm.cima(x * 0.6, 0.35 * sm.hi.y, fora=-0.02), coque_c + Vector((x * 0.15, -0.10, -0.05))]
        pecas.append(curva("mecha_%d" % i, pts, 0.07, cabelo,
                           raios=[0.6, 1.0, 0.8, 0.3]))
    # O COQUE, atrás e ACIMA da linha do cabelo — é silhueta, e silhueta é o
    # que sobrevive ao tamanho (a regra que já o pôs lá na versão de hoje).
    pecas.append(metaball("coque", [
        (tuple(coque_c), 0.50, (1.0, 0.95, 0.90)),
        (tuple(coque_c + Vector((0.0, 0.05, 0.16))), 0.28, (1, 1, 1)),
    ], cabelo))
    bpy.ops.mesh.primitive_torus_add(major_radius=0.20, minor_radius=0.05,
                                     location=coque_c + Vector((0, -0.18, -0.12)),
                                     rotation=(math.radians(70), 0, 0))
    liga = bpy.context.active_object
    liga.name = "coque_liga"
    liga.data.materials.append(M["colete"])
    bpy.ops.object.shade_smooth()
    pecas.append(liga)

    # O LÁPIS ATRÁS DA ORELHA DIREITA (da imagem): a ferramenta da profissão.
    # ⚠️ FORA do cabelo e da orelha, com folga: peça pequena encostada a peça
    # grande desaparece sem erro (duas tentativas em 13/09, `CLAUDE.md`).
    orelha = s.lado(0.05, 0.52)
    bpy.ops.mesh.primitive_cylinder_add(radius=0.045, depth=0.62, vertices=12,
                                        location=orelha + Vector((0.10, 0.02, 0.22)),
                                        rotation=(0, math.radians(-16), 0))
    lapis = bpy.context.active_object
    lapis.name = "lapis"
    lapis.data.materials.append(M["capacete"])
    pecas.append(lapis)
    bpy.ops.mesh.primitive_cone_add(radius1=0.045, radius2=0.0, depth=0.12, vertices=12,
                                    location=orelha + Vector((0.18, 0.02, -0.12)),
                                    rotation=(math.radians(180), math.radians(-16), 0))
    ponta = bpy.context.active_object
    ponta.name = "lapis_ponta"
    ponta.data.materials.append(M["madeira_esc"])
    pecas.append(ponta)

    # ── O BUSTO ───────────────────────────────────────────────────────────
    # Ombros MACIOS e largos (duas cabeças), a descer para fora — e o corte é
    # o do quadro: o tronco continua para baixo da borda, como numa foto, em
    # vez de acabar num fundo chato a flutuar dentro dela.
    # ⚠️ NA SEGUNDA TENTATIVA A CABEÇA FLUTUAVA: o pescoço de metaball saía
    # fino (a superfície encolhe) e, com a câmera a olhar de CIMA, o queixo
    # tapava-o inteiro — ficava ar entre o queixo e o ombro. O pescoço
    # engrossa e o TRAPÉZIO sobe ao encontro dele, que é também o que faz o
    # ombro cair para fora em vez de ser uma almofada.
    pescoco = metaball("pescoco", [((0.0, 0.08, 0.60), 0.60, (0.55, 0.55, 1.00))], pele)
    tronco = metaball("tronco", [
        # Uma massa só, larga até abaixo do quadro: ombros em bola davam um
        # halterofilista com cintura.
        ((0.0, 0.12, 0.20), 0.50, (1.20, 0.70, 0.50)),   # trapézio
        ((0.0, 0.10, -0.30), 1.05, (1.32, 0.70, 0.78)),
        ((-0.64, 0.10, -0.26), 0.46, (1.2, 0.9, 0.8)),
        ((0.64, 0.10, -0.26), 0.46, (1.2, 0.9, 0.8)),
        ((0.0, 0.10, -1.10), 1.25, (1.34, 0.75, 0.85)),
    ], M["casco_pesca"])
    pecas += [pescoco, tronco]
    # A GOLA CLARA — a única peça clara do busto. ⚠️ A primeira era um anel
    # inteiro à volta do pescoço e saiu uma BOIA a flutuar. Gola de blusa são
    # DUAS PONTAS de colarinho pousadas no peito, a abrir para os ombros, e o
    # decote entre elas; pousam no tronco por raio, como as feições na cara.
    # ⚠️ E POUSAM NA BASE DO PESCOÇO MEDIDA, não numa fração do tronco: a
    # 0,93 da caixa do tronco caíram no meio do peito, como um bigode.
    dg = bpy.context.evaluated_depsgraph_get()
    base_z = min(v.co.z for v in pescoco.data.vertices
                 if v.co.y < 0.0 and abs(v.co.x) < 0.1) + 0.02
    for sx in (-1.0, 1.0):
        # Um nada ABAIXO da base do pescoço e mais para fora: à altura dela a
        # gola escondia-se debaixo do queixo, que a câmera de cima põe à frente.
        ok, p, n, _ = tronco.ray_cast(Vector((0.21 * sx, -10.0, base_z - 0.10)),
                                      Vector((0, 1, 0)), depsgraph=dg)
        assert ok, "a gola não achou o tronco"
        bpy.ops.mesh.primitive_uv_sphere_add(radius=1.0, location=p + n * 0.02,
                                             segments=24, ring_count=12)
        ponta = bpy.context.active_object
        ponta.name = "gola_%+d" % sx
        # Pontas a cair para fora e para BAIXO, deitadas no peito: de lado
        # (a primeira rotação) liam como um laço.
        ponta.scale = (0.22, 0.06, 0.15)
        ponta.rotation_euler = (math.radians(-35), math.radians(42 * sx), 0)
        ponta.data.materials.append(M["cabine"])
        bpy.ops.object.shade_smooth()
        pecas.append(ponta)
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

    Dois passos, porque a câmera é ortográfica e a escala é linear: mede-se a
    cabeça a uma escala conhecida, escala-se para a altura-alvo e depois
    desloca-se no plano da imagem até o topo e o centro baterem.
    """
    bpy.ops.object.empty_add(location=(0, 0, 0))
    piv = bpy.context.active_object
    piv.name = "pivo_retrato"
    for o in pecas:
        o.parent = piv
    # A cara olha para −y; a câmera está a 45° em Z. Girar o grupo põe a cara
    # de frente para quem olha — o mesmo `_girar_para_a_camera` de hoje.
    piv.rotation_euler.z = math.radians(45.0)
    bpy.context.view_layer.update()
    cabeca_e_cabelo = [o for o in pecas if o.name.startswith(("cabeca", "cabelo", "coque", "mecha"))]
    x0, y0, x1, y1 = pixels(cena, cabeca_e_cabelo)
    # A CABEÇA VALE 60% DO QUADRO, como hoje (o busto de 13/09 pôs a cabeça a
    # 61% da altura para a cara ter pixels) — e o resto do quadro é ombro.
    k = (0.60 * cena.render.resolution_y) / (y1 - y0)
    piv.scale = (k, k, k)
    bpy.context.view_layer.update()
    x0, y0, x1, y1 = pixels(cena, cabeca_e_cabelo)
    # Deslocar no plano da imagem: a direita da tela é (+X, +Y)/√2 no mundo e
    # o "cima" é +Z (mais a profundidade, que aqui não entra: o grupo move-se
    # por inteiro). Um passo de 1 unidade em Z sobe `px_z` pixels — medido.
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
    # Mover em X do mundo mexe x E y da imagem; resolve-se o par (X, Z).
    # Os alvos estão em pixels do quadro de 768; a prévia renderiza a outra
    # resolução, e escala-os.
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
    import os
    if os.environ.get("PREVIA") == "1":
        # Para ITERAR a forma: metade da resolução e poucas amostras. O
        # enquadramento é medido na resolução que estiver posta, logo sai o
        # mesmo desenho, só mais grosso.
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
