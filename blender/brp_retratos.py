"""BRP — os retratos de fala no kit de caixas AFINADO (`docs/decisoes/055`).

Não é um segundo estúdio: é o `retratos_de_fala` de `brp_porto.py` que chama
daqui, na mesma cena, com a câmera, o rig e a paleta de `preparar_cena()`. O que
este módulo acrescenta ao kit são as peças que o modelo novo precisou — o
tronco por anéis, a mecha contínua, o nariz em cunha, o aro oitavado — e o
enquadramento MEDIDO (a cabeça com o coque a 60% do quadro), que é o dele.

DE ONDE VEM. A Dona Cida séria passou por seis candidatas em
`art_lab/retratos/cida_seria/`: duas redondas (a v1 rejeitada; a v2 não
escolhida) e quatro quadradas, até à `quadrada_v3`, que o Bruno aceitou na foto
do jogo em 24/09. O código saiu do script dela, e as armadilhas de cada peça
estão escritas lá, tentativa a tentativa; aqui fica o que a peça É.

Estão neste modelo os três que falam — a Dona Cida (`055`), o Sr. Ribeiro e o
Arlindo (`056`) —, cada um com a sua `Rosto`: a forma POR PERSONAGEM do plano
de arte (P2). O kit de caixas que os fazia saiu do `brp_porto.py` com o último.
"""

from __future__ import annotations

import math

import bpy
import bmesh
from bpy_extras.object_utils import world_to_camera_view
from mathutils import Euler, Matrix, Vector

import gerar_props_iso as base
from brp_studio import na_face, prisma
from brp_porto import _contorno_oitavado, _lg, _pf, _alt, _niv


# ⚠️ A COR DOS RETRATOS É STANDARD A −0,35 EV, e é escolha do Bruno (`055`).
# O pipeline dá AgX a toda cena; os retratos pousam num cartão e não no mapa, e
# o AgX punha o `#eef2f5` da gola e do olho a ~191 e lavava a pele. A 0 EV o
# Standard ESTOURAVA — 54% dos pixels claros a 255, a gola sem sombreado —, e
# a −0,35 dá zero com o p99 a 239 e a saturação da pele igual.
COR_RETRATO = ("Standard", -0.35)

# O ENQUADRAMENTO, medido no PNG de hoje: o topo do cabelo a 16 px e o busto
# centrado; a caixa do retrato mostra o quadro inteiro em altura e corta 101 px
# de cada lado (`COVERED` de 768 em 168×228).
TOPO_PX = 16.0
CENTRO_X_PX = 384.0
CABECA_NO_QUADRO = 0.60

class Rosto:
    """A cabeça de UM personagem, em pixels de desenho como no kit.

    As peças da cara (olho, sobrancelha, nariz, boca) pousam na face da frente
    da caixa `larg × fundo × z`, e as alturas delas são ABSOLUTAS. A Dona Cida
    foi a primeira e as medidas dela eram constantes do módulo; o Sr. Ribeiro e
    o Arlindo têm outra cabeça (plano de arte P2: forma POR PERSONAGEM), e
    com constantes cada um teria de copiar as funções da cara.
    """

    def __init__(self, *, larg, fundo, z, maxilar, corte, z_olho, z_boca, pivo,
                 u_olho=31.0, olho=(38.0, 24.0), iris=(20.0, 22.0),
                 pupila=(10.0, 12.0), u_sobr=(23.0, 40.0), sobr=(18.0, 5.0, 4.5),
                 brilho=5.0, boca_k=1.0, boca_alt=3.5, labio_k=1.0):
        self.larg, self.fundo, self.z = larg, fundo, z
        self.maxilar, self.corte = maxilar, corte
        self.centro = (z[0] + z[1]) / 2.0
        self.z_olho, self.u_olho = z_olho, u_olho
        self.olho, self.iris, self.pupila = olho, iris, pupila
        self.u_sobr, self.sobr = u_sobr, sobr
        self.z_boca = z_boca
        # A boca de cada um: `boca_k` alarga-a inteira (troços e lábios) e
        # `boca_alt` engrossa a LINHA escura — o «boca mais marcada» do Sr.
        # Ribeiro. `brilho` é o lado do ponto de luz no olho.
        self.boca_k, self.boca_alt, self.brilho = boca_k, boca_alt, brilho
        # `labio_k` afina os lábios, com a borda que toca a linha no sítio.
        self.labio_k = labio_k
        self.pivo = pivo          # o meio do pescoço: a cabeça roda sobre ele


# ── AS MEDIDAS DA DONA CIDA ────────────────────────────────────────────────
_CAB_LARG, _CAB_FUNDO = 158.0, 76.0
_CAB_Z = (140.0, 284.0)
_MAXILAR = 196.0
_CORTE_CARA = 20.0
_DZ = 8.0                       # o tronco sobe com o queixo, menos do que ele
_Z_OLHO = 216.0
CIDA = Rosto(larg=_CAB_LARG, fundo=_CAB_FUNDO, z=_CAB_Z, maxilar=_MAXILAR,
             corte=_CORTE_CARA, z_olho=_Z_OLHO, z_boca=170.0, pivo=122.0)


# ────────────────────────────────────────────────────────────── utilitários
def _principled(nome, hexa, rough=1.0, spec=0.0):
    """A cor da paleta SEM o ruído de desgaste: num tecido lia como mancha."""
    m = base.material(nome, hexa)
    p = m.node_tree.nodes["Principled BSDF"]
    p.inputs["Roughness"].default_value = rough
    p.inputs["Specular IOR Level"].default_value = spec
    return m


def _emissao(nome, forca):
    m = bpy.data.materials.new(nome)
    m.use_nodes = True
    nt = m.node_tree
    nt.nodes.remove(nt.nodes["Principled BSDF"])
    em = nt.nodes.new("ShaderNodeEmission")
    em.inputs["Color"].default_value = (1.0, 1.0, 1.0, 1.0)
    em.inputs["Strength"].default_value = forca
    nt.links.new(em.outputs[0], nt.nodes["Material Output"].inputs[0])
    return m


def _objeto(nome, bm, mat):
    me = bpy.data.meshes.new(nome)
    bm.to_mesh(me)
    bm.free()
    o = bpy.data.objects.new(nome, me)
    bpy.context.scene.collection.objects.link(o)
    o.data.materials.append(mat)
    return o


def _raio(objs, origem, direcao):
    """O primeiro acerto de um raio contra vários objetos: (ponto, normal).

    ⚠️ `ray_cast` no objeto ORIGINAL com o `depsgraph`; no avaliado não acha.
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


def _plano_cabeca(r):
    centro = (0.0, 0.0, _niv(r.centro))
    tam = (_lg(r.larg), _pf(r.fundo), _alt(r.z[1] - r.z[0]))
    return centro, tam


def _placa(r, nome, u, z_px, larg, alt_px, mat, fora=0.0, esp=0.02, inclina=0.0):
    """Uma placa na cara de `r`, em `u` a partir do meio e à altura ABSOLUTA `z_px`.

    ⚠️ `inclina` positivo do lado ESQUERDO baixa a ponta de DENTRO — é o
    «franzida» do kit. Um arco quer o sinal contrário.
    """
    centro, tam = _plano_cabeca(r)
    o = na_face(nome, "-y", centro, tam, _lg(u), _alt(z_px - r.centro),
                _lg(larg), _alt(alt_px), esp, mat, fora)
    if inclina:
        o.rotation_euler.y = math.radians(inclina)
    return o


def _contorno_12(larg, fundo, corte):
    """O octógono do kit com cada quina partida em duas facetas."""
    p = _contorno_oitavado(larg, fundo, corte)
    lx, fy = _lg(larg) / 2.0, _pf(fundo) / 2.0
    quinas = {1: (lx, -fy), 3: (lx, fy), 5: (-lx, fy), 7: (-lx, -fy)}
    out = []
    for i in range(8):
        out.append(p[i])
        if i in quinas:
            c = Vector(quinas[i])
            a, b = Vector(p[i]), Vector(p[(i + 1) % 8])
            m = c + 0.293 * ((a - c) + (b - c))
            out.append((m.x, m.y))
    return out


def _anel_redondo(r_px, lados=10):
    r = _lg(r_px)
    return [(r * math.cos(2 * math.pi * i / lados), r * math.sin(2 * math.pi * i / lados))
            for i in range(lados)]


def _loft(nome, aneis, mat, contorno=_contorno_oitavado, fechar=(True, False)):
    """Uma malha FACETADA por anéis, de cima para baixo (o `prisma` com andares)."""
    bm = bmesh.new()
    rings = []
    for anel in aneis:
        if isinstance(anel[1], list):
            z_px, pts = anel[0], anel[1]
            dy = _pf(anel[2]) if len(anel) > 2 else 0.0
        else:
            z_px = anel[0]
            pts = contorno(*anel[1:4])
            dy = _pf(anel[4]) if len(anel) > 4 else 0.0
        rings.append([bm.verts.new((x, y + dy, _niv(z_px))) for x, y in pts])
    n = len(rings[0])
    for a, b in zip(rings, rings[1:]):
        for i in range(n):
            j = (i + 1) % n
            bm.faces.new((a[i], a[j], b[j], b[i]))
    if fechar[0]:
        bm.faces.new(rings[0])
    if fechar[1]:
        bm.faces.new(list(reversed(rings[-1])))
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    return _objeto(nome, bm, mat)


def _bastao(nome, a, b, raio_w, lados, mat):
    a, b = Vector(a), Vector(b)
    d = b - a
    bpy.ops.mesh.primitive_cylinder_add(vertices=lados, radius=raio_w, depth=d.length,
                                        location=(a + b) / 2.0)
    o = bpy.context.active_object
    o.name = nome
    o.rotation_mode = "QUATERNION"
    o.rotation_quaternion = Vector((0, 0, 1)).rotation_difference(d.normalized())
    o.data.materials.append(mat)
    return o


def _mecha(nome, perfil, escalas, x0, x1, esps, mat):
    """Uma faixa CONTÍNUA de cabelo ao longo de um perfil do plano YZ.

    Os troços partilham os vértices da dobra (ripas soltas liam como telhas), e
    a espessura é por ponto: afinada até quase zero na testa, a mecha NASCE da
    calote em vez de acabar numa aresta que se acende.
    """
    pts = [Vector((0.0, y, zz)) for y, zz in perfil]
    normais = []
    for i in range(len(pts)):
        n = Vector((0.0, 0.0, 0.0))
        for s in ([pts[i] - pts[i - 1]] if i > 0 else []) + \
                 ([pts[i + 1] - pts[i]] if i < len(pts) - 1 else []):
            n += Vector((0.0, -s.z, s.y)).normalized()
        normais.append(n.normalized())
    bm = bmesh.new()
    aneis = []
    for p, n, k, esp_w in zip(pts, normais, escalas, esps):
        aneis.append([bm.verts.new(p + Vector((x * k, 0.0, 0.0)) + n * off)
                      for x, off in ((x0, 0.0), (x1, 0.0), (x1, esp_w), (x0, esp_w))])
    for a, b in zip(aneis, aneis[1:]):
        for i in range(4):
            j = (i + 1) % 4
            bm.faces.new((a[i], a[j], b[j], b[i]))
    bm.faces.new(aneis[0])
    bm.faces.new(list(reversed(aneis[-1])))
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    return _objeto(nome, bm, mat)


def _retalho(nome, alvos, cantos, mat, afasta=1.2, espessura=2.0, espelhado=False, n=4):
    """Um retalho de pano POUSADO no peito por raios de frente: gola, lapela, gravata.

    `cantos` são quatro (u, z) em pixels de desenho, a contornar o retalho; a
    grade entre eles é bilinear e cada ponto desce até achar o tronco (um raio
    que passe ao lado de um ombro tenta 2 px mais abaixo). `afasta` empilha
    retalhos que se cruzam — o mesmo remédio das placas coplanares do kit.
    """
    A, B, C, D = cantos
    bm = bmesh.new()
    grade = []
    for j in range(n + 1):
        fv = j / n
        lin = []
        for i in range(n + 1):
            fu = i / n
            x = (A[0] * (1 - fu) * (1 - fv) + B[0] * fu * (1 - fv)
                 + C[0] * fu * fv + D[0] * (1 - fu) * fv)
            zz = (A[1] * (1 - fu) * (1 - fv) + B[1] * fu * (1 - fv)
                  + C[1] * fu * fv + D[1] * (1 - fu) * fv)
            ok = None
            for k in range(10):
                ok = _raio(alvos, Vector((_lg(x), -10.0, _niv(zz - 2.0 * k))),
                           Vector((0, 1, 0)))
                if ok:
                    break
            assert ok, "o retalho %s não achou o peito em %s" % (nome, (x, zz))
            lin.append(bm.verts.new(ok[0] + ok[1] * _pf(afasta)))
        grade.append(lin)
    for j in range(n):
        for i in range(n):
            f = (grade[j][i], grade[j][i + 1], grade[j + 1][i + 1], grade[j + 1][i])
            bm.faces.new(tuple(reversed(f)) if espelhado else f)
    o = _objeto(nome, bm, mat)
    o.modifiers.new("espessura", "SOLIDIFY").thickness = _pf(espessura)
    return o


def _ferradura(r, nome, mat, mat_fios, folga=(10.0, 5.0), esp=9.0, frente=-0.10,
               base=(214.0, 186.0), topo=(250.0, 275.0), camadas=5, recuo=2.5):
    """O cabelo de quem é careca: uma faixa em U, das têmporas à nuca. E, com
    o topo por baixo do boné, as camadas dos fios do Arlindo.

    Segue o contorno de 12 lados da cabeça e guarda só os pontos de trás de
    `frente` (fração do meio-fundo; negativo avança para a cara). Cada par é
    (TÊMPORA, NUCA): a `folga` à cabeça é maior nos lados — o «mais cheia nos
    lados» do Bruno (v3) —, a base desce por trás da orelha e o topo sobe.

    OS FIOS SÃO CAMADAS: a faixa parte-se em `camadas` na altura, e as
    ímpares vão recuadas e um tom abaixo (`mat_fios`). É a regra do kit para
    detalhe a esta escala — quem desenha é a fronteira de VALOR entre duas
    placas, não o relevo —, e as riscas correm ao comprido, como o cabelo
    penteado para trás.
    """
    pts = _contorno_12(r.larg, r.fundo, r.corte)
    y0 = frente * _pf(r.fundo / 2.0)
    atras = [p[1] >= y0 for p in pts]
    n = len(pts)
    # Começa no primeiro ponto de trás e dá a volta pela nuca até ao último:
    # o arco de trás tem de sair CONTÍNUO, sem saltar pela frente.
    ini = next(i for i in range(n) if atras[i] and not atras[i - 1])
    arco = []
    i = ini
    while atras[i]:
        arco.append(pts[i])
        i = (i + 1) % n
    y_max = max(p[1] for p in arco)
    meia = _lg(r.larg / 2.0)

    def tt(y):
        return max(0.0, min(1.0, (y - y0) / (y_max - y0)))
    pecas = []
    for c in range(camadas):
        recua = c % 2 == 1
        bm = bmesh.new()
        lados = []
        for x, y in arco:
            t = tt(y)
            zb0 = base[0] + (base[1] - base[0]) * t
            zt0 = topo[0] + (topo[1] - topo[0]) * t ** 0.7
            zb = zb0 + (zt0 - zb0) * c / camadas
            zt = zb0 + (zt0 - zb0) * (c + 1) / camadas
            f = folga[0] + (folga[1] - folga[0]) * t - (recuo if recua else 0.0)
            k_fora = (meia + _lg(f)) / meia
            k_dentro = (meia - _lg(esp)) / meia
            lados.append([bm.verts.new((x * k_fora, y * k_fora, _niv(zb))),
                          bm.verts.new((x * k_fora, y * k_fora, _niv(zt))),
                          bm.verts.new((x * k_dentro, y * k_dentro, _niv(zt))),
                          bm.verts.new((x * k_dentro, y * k_dentro, _niv(zb)))])
        for a, b in zip(lados, lados[1:]):
            for i in range(4):
                j = (i + 1) % 4
                bm.faces.new((a[i], b[i], b[j], a[j]))
        bm.faces.new(lados[0])
        bm.faces.new(list(reversed(lados[-1])))
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        pecas.append(_objeto("%s_%d" % (nome, c), bm, mat_fios if recua else mat))
    return pecas


def _cunha(r, nome, z_topo, z_ponta, larg_topo, larg_ponta, sai_topo, sai_ponta, mat):
    """Um nariz em CUNHA: estreito e rente na cana, largo e saliente na ponta."""
    y0 = -_pf(r.fundo / 2.0) + _pf(1.0)
    bm = bmesh.new()
    vs = []
    for z_px, lg_px, sai in ((z_topo, larg_topo, sai_topo), (z_ponta, larg_ponta, sai_ponta)):
        for x in (-lg_px / 2.0, lg_px / 2.0):
            vs.append((bm.verts.new((_lg(x), y0, _niv(z_px))),
                       bm.verts.new((_lg(x), y0 - _pf(sai), _niv(z_px)))))
    (tl_a, tl_f), (tr_a, tr_f), (bl_a, bl_f), (br_a, br_f) = vs
    for f in ((tl_f, tr_f, br_f, bl_f), (tl_a, bl_a, br_a, tr_a),
              (tl_a, tr_a, tr_f, tl_f), (bl_a, bl_f, br_f, br_a),
              (tl_a, tl_f, bl_f, bl_a), (tr_a, br_a, br_f, tr_f)):
        bm.faces.new(f)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    return _objeto(nome, bm, mat)


def _aro_oitavado(r, nome, u, z_px, larg, alt, corte, barra, fora, mat):
    """Um aro de óculos OITAVADO na face da frente: o redondo das caixas."""
    def octo(hl, ha, c):
        return [(-hl + c, -ha), (hl - c, -ha), (hl, -ha + c), (hl, ha - c),
                (hl - c, ha), (-hl + c, ha), (-hl, ha - c), (-hl, -ha + c)]
    dentro = octo(larg / 2.0, alt / 2.0, corte)
    fora_c = octo(larg / 2.0 + barra, alt / 2.0 + barra, corte + barra * 0.41)
    y_face = -_pf(r.fundo / 2.0)
    esp = 0.02
    bm = bmesh.new()
    camadas = []
    for y in (y_face - fora - esp, y_face - fora):
        camadas.append(([bm.verts.new((_lg(u + a), y, _niv(z_px + b))) for a, b in fora_c],
                        [bm.verts.new((_lg(u + a), y, _niv(z_px + b))) for a, b in dentro]))
    (fo_f, de_f), (fo_t, de_t) = camadas
    for i in range(8):
        j = (i + 1) % 8
        bm.faces.new((fo_f[i], fo_f[j], de_f[j], de_f[i]))
        bm.faces.new((fo_t[j], fo_t[i], de_t[i], de_t[j]))
        bm.faces.new((fo_f[j], fo_f[i], fo_t[i], fo_t[j]))
        bm.faces.new((de_f[i], de_f[j], de_t[j], de_t[i]))
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    return _objeto(nome, bm, mat)


# ────────────────────────────────────────────────────────────── a cara
# AS ALAVANCAS DA EXPRESSÃO, as mesmas cinco do kit (`_CARAS` em `brp_porto`),
# no desenho novo. Um valor que o desenho novo ainda não sabe fazer REBENTA em
# vez de sair com a cara séria — o `.get()` com omissão é a armadilha do
# `CLAUDE.md` para dicionários de configuração.
#
# As alturas das tabelas abaixo são relativas ao OLHO e à BOCA de cada `Rosto`
# (eram absolutas na Dona Cida, que era a única): um personagem de testa alta
# desce a cara inteira mexendo em dois números.
_OLHAR = {"frente": (0.0, 0.0), "baixo": (0.0, -4.0), "lado": (5.0, 0.0),
          "cima": (0.0, 3.0)}


def _olhos(r, M, cara, pele, escuro, oculos=False):
    """Esclera, íris, pupila, brilho, prega e pestana — e a pálpebra da emoção.

    `cerrado` desce a pálpebra de CIMA sobre a íris (o olhar por baixo da aba
    do Arlindo, a educação contrariada do Sr. Ribeiro); `sorrindo` sobe a de
    BAIXO, que é a bochecha a empurrá-la.
    """
    if cara["olho"] not in ("aberto", "sorrindo", "cerrado"):
        raise ValueError("olho %r ainda não existe no modelo novo" % cara["olho"])
    du, dz = _OLHAR[cara["olhar"]]
    brilho = _emissao("brilho_olho", 1.0)       # Standard: força 1 já dá 255
    lo, ao = r.olho
    zo = r.z_olho
    pecas = []
    for sx in (-1.0, 1.0):
        u = r.u_olho * sx
        pecas.append(_placa(r, "olho_branco_%+d" % sx, u, zo, lo, ao, M["cabine"]))
        pecas.append(_placa(r, "olho_iris_%+d" % sx, u + du, zo - 1.0 + dz, r.iris[0],
                            r.iris[1], M["porta"], fora=0.010))
        pecas.append(_placa(r, "olho_pupila_%+d" % sx, u + du, zo - 1.0 + dz, r.pupila[0],
                            r.pupila[1], escuro, fora=0.020))
        pecas.append(_placa(r, "olho_brilho_%+d" % sx, u - 5.0 + du, zo + 3.0 + dz, r.brilho,
                            r.brilho, brilho, fora=0.030))
        z_pestana = zo + ao / 2.0 - 4.0
        if cara["olho"] == "cerrado":
            # A PÁLPEBRA DE CIMA DESCE até ao meio do olho, e a pestana desce
            # com ela: é a BORDA escura que o olho lê, não a pele por cima.
            # Mais saliente do que o brilho (0,030), que ela também tapa.
            # Tapa o terço de cima, não a metade: a meio da íris a pálpebra
            # lia como SONO no tamanho do jogo (o Sr. Ribeiro grave).
            z_pestana = zo + ao / 2.0 - ao / 3.0
            pecas.append(_placa(r, "palpebra_cima_%+d" % sx, u, zo + ao / 2.0 - ao / 6.0,
                                lo + 2.0, ao / 3.0, pele, fora=0.032))
        pecas.append(_placa(r, "palpebra_%+d" % sx, u, zo + ao / 2.0 - 1.5, lo + 2.0, 3.5,
                            pele, fora=0.034))
        pecas.append(_placa(r, "pestana_%+d" % sx, u, z_pestana, lo + 2.0, 2.5, escuro,
                            fora=0.038))
        if cara["olho"] == "sorrindo":
            # A PÁLPEBRA DE BAIXO SOBE: é a bochecha a empurrá-la, e é o que
            # separa um sorriso de verdade de uma boca virada para cima. Uma
            # placa de pele à frente da íris e da pupila (mais saliente do que
            # o brilho, 0,030) e atrás da pálpebra de cima e dos óculos.
            pecas.append(_placa(r, "palpebra_baixo_%+d" % sx, u, zo - ao / 2.0 + 3.5,
                                lo + 2.0, 7.0, pele, fora=0.032))
        if oculos:
            pecas.append(_aro_oitavado(r, "oculos_%+d" % sx, u, zo, 46.0, 32.0, 9.0, 2.5,
                                       0.046, M["metal"]))
    if oculos:
        pecas.append(_placa(r, "oculos_ponte", 0.0, zo + 5.0, 14.0, 3.0, M["metal"],
                            fora=0.052))
        for sx in (-1.0, 1.0):
            pecas.append(_bastao("oculos_haste_%+d" % sx,
                                 (sx * _lg(56.0), -_pf(r.fundo / 2.0 + 1.5), _niv(zo + 6.0)),
                                 (sx * _lg(r.larg / 2.0 + 1.0), _pf(4.0), _niv(zo + 4.0)),
                                 _lg(1.4), 4, M["metal"]))
        for o in pecas:
            if o.name.startswith("oculos"):
                o.visible_shadow = False
    return pecas


# O CENHO, lado DIREITO: (z dentro, inclina dentro, z fora, inclina fora), com
# as alturas a partir do olho. A emoção é para onde vai a placa de DENTRO:
# franzida desce e inclina para o meio, erguida sobe.
_CENHOS = {
    "neutra":   (25.0, 0.0, 23.0, 14.0),
    "franzida": (22.5, -12.0, 22.5, 6.0),
    "erguida":  (28.0, 8.0, 25.5, 16.0),
    # A meio caminho da neutra: a erguida com a boca a sorrir lia como
    # ESPANTO na contente (veredito do Bruno, 24/09).
    "suave":    (26.5, 4.0, 24.5, 15.0),
    # O franzido FORTE: a ponta de dentro mais baixa e mais inclinada. A
    # `franzida` com o olho cerrado lia como SONO no tamanho do jogo (o Sr.
    # Ribeiro grave, primeira prova); é a gravidade de quem fica mais educado.
    "carregada": (20.5, -20.0, 22.0, 4.0),
    # O TRISTE: as pontas de DENTRO sobem e as de fora caem — desapontado, e
    # não zangado. O Bruno pediu o Sr. Ribeiro grave «mais triste» (24/09):
    # com a `carregada` ele lia bravo, e quem fica bravo fica MAIS educado.
    "triste":   (27.0, 18.0, 21.0, 12.0),
}


def _sobrancelhas(r, cara, mat):
    """Duas placas por lado: a de dentro e a de fora.

    `torta` é uma erguida e uma franzida — o cético, e o que sobra a quem
    perdeu e ainda não admitiu (o Arlindo contrariado): a da ESQUERDA da
    imagem sobe, a da direita franze.
    """
    estilo = cara["cenho"]
    if estilo == "torta":
        # A metade franzida é a CARREGADA: com a `franzida` o Arlindo
        # contrariado lia pouco (o Bruno, na v1).
        lados = {-1.0: _CENHOS["erguida"], 1.0: _CENHOS["carregada"]}
    elif estilo in _CENHOS:
        lados = {-1.0: _CENHOS[estilo], 1.0: _CENHOS[estilo]}
    else:
        raise ValueError("cenho %r ainda não existe no modelo novo" % estilo)
    larg, alt_d, alt_f = r.sobr
    pecas = []
    for sx in (-1.0, 1.0):
        z_d, i_d, z_f, i_f = lados[sx]
        pecas.append(_placa(r, "sobrancelha_dentro_%+d" % sx, r.u_sobr[0] * sx,
                            r.z_olho + z_d, larg, alt_d, mat, inclina=i_d * sx))
        pecas.append(_placa(r, "sobrancelha_fora_%+d" % sx, r.u_sobr[1] * sx,
                            r.z_olho + z_f, larg, alt_f, mat, fora=0.002, inclina=i_f * sx))
    return pecas


def _boca(r, M, cara, escuro, labio):
    """A linha entre os lábios, o lábio de baixo em cor e o de cima fino.

    Como no kit, o que se lê a este tamanho é para onde apontam as PONTAS: um
    canto fora da linha, acima ou abaixo dela. `labio=None` tira os lábios de
    cor (a boca de quem tem bigode por cima, ou lábio da cor da pele).
    """
    zb = r.z_boca
    k, la = r.boca_k, r.boca_alt
    estilo = cara["boca"]

    def lab(nome, u, z_px, larg, alt_px):
        if labio is None:
            return []
        if r.labio_k != 1.0:
            # Afina pela borda de FORA: a que toca a linha fica onde estava.
            borda = z_px + alt_px / 2.0 if z_px < zb else z_px - alt_px / 2.0
            alt_px *= r.labio_k
            z_px = borda - alt_px / 2.0 if z_px < zb else borda + alt_px / 2.0
        return [_placa(r, nome, u * k, z_px, larg * k, alt_px, labio)]

    def linha(nome, u, z_px, larg, **kw):
        return _placa(r, nome, u * k, z_px, larg * k, la, escuro, **kw)
    if estilo == "reta":
        return ([linha("boca", 0.0, zb, 36.0)]
                + lab("labio", 0.0, zb - 5.0, 26.0, 6.0)
                + lab("labio_cima", 0.0, zb + 3.5, 22.0, 3.0))
    if estilo == "descontente":
        pecas = ([linha("boca", 0.0, zb + 1.0, 28.0)]
                 + lab("labio", 0.0, zb - 4.0, 22.0, 6.0)
                 + lab("labio_cima", 0.0, zb + 4.5, 20.0, 3.0))
        pecas += [linha("boca_canto_%+d" % sx, 16.0 * sx, zb - 2.0, 8.0)
                  for sx in (-1.0, 1.0)]
        return pecas
    if estilo == "sorriso":
        pecas = ([linha("boca", 0.0, zb - 2.5, 30.0)]
                 + lab("labio", 0.0, zb - 7.5, 24.0, 5.0)
                 + lab("labio_cima", 0.0, zb + 3.5, 24.0, 3.0)
                 # Os DENTES: uma placa clara entre o lábio de cima e a linha —
                 # é o que separa um sorriso de uma boca virada para cima.
                 + [_placa(r, "dentes", 0.0, zb + 0.5, 22.0 * k, 3.0, M["cabine"])])
        pecas += [linha("boca_canto_%+d" % sx, 18.0 * sx, zb + 0.5, 8.0)
                  for sx in (-1.0, 1.0)]
        return pecas
    if estilo in ("sorriso_fechado", "sorriso_lado", "sorriso_curto"):
        # ⚠️ O «SORRISO» DE CIMA LÊ COMO ESPANTO: os dentes são uma fita clara
        # entre duas linhas escuras, e com os cantos só 3 px acima da linha a
        # boca parece ABERTA, não virada para cima (veredito do Bruno, 24/09).
        # Aqui a linha é um U de três troços: o do meio a direito e os dois de
        # fora INCLINADOS para cima, como as sobrancelhas em arco. O canto que
        # sobe ~6 px de desenho é ~1 px no telefone, e é ele que se lê.
        # `_lado`: só o canto direito (da imagem) sobe — meio sorriso.
        # `_curto`: o U mais estreito e menos fundo — a cortesia, não a alegria.
        #
        # Os cantos vão um passo à frente da linha do meio (`fora`), porque se
        # cruzam com ela: no mesmo plano o z-buffer escolheria ao acaso.
        curto = estilo == "sorriso_curto"
        meio, u_c, l_c, ang = (14.0, 11.5, 11.0, 18.0) if curto else (20.0, 15.0, 14.0, 25.0)
        pecas = ([linha("boca", 0.0, zb - 2.0, meio)]
                 + lab("labio", 0.0, zb - 6.5, meio + 2.0, 5.0)
                 + lab("labio_cima", 0.0, zb + 1.5, meio - 4.0, 2.5))
        for sx in (-1.0, 1.0):
            if estilo == "sorriso_lado" and sx < 0:
                pecas.append(linha("boca_canto_%+d" % sx, 14.0 * sx, zb - 2.0, 10.0,
                                   fora=0.002))
                continue
            # `inclina` negativo do lado direito baixa a ponta de DENTRO e sobe
            # a de fora (ver `_placa`): o sinal do franzido, que num arco de
            # boca é o sorriso.
            pecas.append(linha("boca_canto_%+d" % sx, u_c * sx, zb + 0.5, l_c,
                               fora=0.002, inclina=-ang * sx))
        return pecas
    if estilo == "sorriso_dentes":
        # O sorriso do Arlindo, que é o estado NORMAL dele («sempre sorrindo
        # quando ataca»): o U do fechado, mais fundo, com os DENTES entre a
        # linha e o bigode. O «sorriso» de cima tem dentes e lia como ESPANTO,
        # porque os cantos quase não subiam; aqui sobem a 28°.
        pecas = ([linha("boca", 0.0, zb - 2.5, 22.0)]
                 + lab("labio", 0.0, zb - 7.0, 22.0, 5.0)
                 + [_placa(r, "dentes", 0.0, zb + 0.5, 20.0 * k, 3.0, M["cabine"])])
        for sx in (-1.0, 1.0):
            pecas.append(linha("boca_canto_%+d" % sx, 16.0 * sx, zb + 0.5, 14.0,
                               fora=0.002, inclina=-28.0 * sx))
        return pecas
    raise ValueError("boca %r ainda não existe no modelo novo" % estilo)


# ────────────────────────────────────────────────────────────── a Dona Cida
def cida(M, cara):
    """O busto da Dona Cida, de FRENTE (a cara olha para −y): (tronco, cabeça).

    A cabeça é tudo o que roda com a pose — cara, cabelo, óculos, lápis,
    orelhas; o tronco fica quieto.

    O QUE A IDENTIDADE DELA JÁ TINHA DECIDIDO, no `_cida` de caixas que este
    substituiu, e que continua a valer: o COQUE fica atrás e acima, porque
    acima da linha do cabelo é SILHUETA, que é o que sobrevive ao tamanho; o
    LÁPIS é o acento único dela (o brinco saiu quando ele entrou — dois
    dourados não apontam para coisa nenhuma), e diz a profissão sem uma
    palavra; e a GOLA é a única peça clara do busto, sem a qual o peito é uma
    chapa verde.
    """
    r = CIDA
    pele = M["pele_escura"]
    sombra = M["pele_sombra"]
    escuro = M["vao"]
    cabelo = _principled("cabelo_cida", base.PALETA["madeira_esc"], rough=0.55, spec=0.25)
    cabelo_fundo = _principled("cabelo_fundo_cida", base.PALETA["cabelo_fundo"],
                               rough=0.8, spec=0.1)
    blusa = _principled("blusa_cida", base.PALETA["casco_pesca"], rough=0.9)
    gola = _principled("gola_cida", base.PALETA["cabine"], rough=0.9)
    labio = _principled("labio_cida", base.PALETA["telha_cume"], rough=0.7, spec=0.15)
    sobrancelha = _principled("sobrancelha_cida", base.PALETA["porta"], rough=0.9)
    cab, tronco_l = [], []

    # A CABEÇA: maxilar oitavado e o crânio em cúpula POR DENTRO da calote.
    cab.append(prisma("cabeca_maxilar",
                      _contorno_oitavado(_CAB_LARG, _CAB_FUNDO, _CORTE_CARA),
                      _niv(_CAB_Z[0]), _niv(_MAXILAR), (0.80, 1.0), pele))
    cab.append(_loft("cabeca_cranio", [
        (286.0, 96.0, 40.0, 12.0, 9.0),
        (276.0, 128.0, 56.0, 18.0, 6.0),
        (262.0, 149.0, _CAB_FUNDO, _CORTE_CARA),
        (_MAXILAR, _CAB_LARG, _CAB_FUNDO, _CORTE_CARA),
    ], pele))
    queixo = _placa(r, "queixo", 0.0, 150.0, 34.0, 12.0, pele, esp=_pf(4.0))
    queixo.visible_shadow = False
    cab.append(queixo)
    for sx in (-1.0, 1.0):
        o = prisma("orelha_%+d" % sx, _contorno_oitavado(16.0, 28.0, 5.0),
                   _niv(220.0), _niv(254.0), (1.0, 1.0), pele)
        o.location.x += sx * _lg(_CAB_LARG / 2.0 + 2.0)
        o.location.y += _pf(6.0)
        cab.append(o)

    cab += _olhos(r, M, cara, pele, escuro, oculos=True)
    cab += _sobrancelhas(r, cara, sobrancelha)
    nariz = _cunha(r, "nariz", 207.0, 188.0, 9.0, 22.0, 2.0, 9.0, pele)
    nariz.visible_shadow = False
    cab.append(nariz)
    cab.append(_placa(r, "nariz_base", 0.0, 185.5, 24.0, 3.5, sombra))
    cab += _boca(r, M, cara, escuro, labio)
    for sx in (-1.0, 1.0):
        m = _placa(r, "maca_%+d" % sx, 37.0 * sx, 188.0, 26.0, 14.0, pele, esp=_pf(1.2))
        m.visible_shadow = False
        cab.append(m)

    # O CABELO: calote baixa no tom de sombra, repartido ao meio em seis mechas
    # que convergem para o coque, têmporas até à orelha e o coque atrás.
    linha = 262.0

    def cranio(z_px):
        f = (z_px - _MAXILAR) / (_CAB_Z[1] - _MAXILAR)
        return _CAB_LARG - 12.0 * max(0.0, min(1.0, f))
    calote = _loft("cabelo_calote", [
        (292.0, 112.0, 46.0, 14.0, 9.0),
        (284.0, cranio(280.0) + 2.0, 58.0, 14.0, 7.0),
        (linha, cranio(linha) + 3.0, 78.0, 12.0, 0.5),
        (212.0, 164.0, 80.0, 26.0),
    ], cabelo_fundo)
    bm = bmesh.new()
    bm.from_mesh(calote.data)
    bmesh.ops.delete(bm, geom=[vv for vv in bm.verts
                               if vv.co.z < _niv(linha) - 1e-4 and vv.co.y < _pf(4.0)],
                     context="VERTS")
    bm.to_mesh(calote.data)
    bm.free()
    cab.append(calote)
    nuca = prisma("cabelo_nuca", _contorno_oitavado(166.0, 40.0, 14.0),
                  _niv(212.0), _niv(linha + 2.0), (1.0, 1.0), cabelo)
    nuca.location.y += _pf(22.0)
    cab.append(nuca)
    lx = _CAB_LARG / 2.0 - 3.0
    for sx in (-1.0, 1.0):
        f = Vector((sx * _lg(lx - _CORTE_CARA), -_pf(_CAB_FUNDO / 2.0)))
        s = Vector((sx * _lg(lx), -_pf(_CAB_FUNDO / 2.0 - _CORTE_CARA)))
        n = Vector((-(s - f).y, (s - f).x)).normalized() * sx
        if n.y > 0:
            n = -n
        bm = bmesh.new()
        topo, baixo = _niv(linha + 3.0), {"f": _niv(248.0), "s": _niv(236.0)}
        vs = []
        for off in (-_lg(1.0), _lg(3.5)):
            vs.append([bm.verts.new((f.x + n.x * off, f.y + n.y * off, baixo["f"])),
                       bm.verts.new((s.x + n.x * off, s.y + n.y * off, baixo["s"])),
                       bm.verts.new((s.x + n.x * off, s.y + n.y * off, topo)),
                       bm.verts.new((f.x + n.x * off, f.y + n.y * off, topo))])
        dentro, fora_ = vs
        bm.faces.new(fora_)
        bm.faces.new(list(reversed(dentro)))
        for i in range(4):
            j = (i + 1) % 4
            bm.faces.new((dentro[i], dentro[j], fora_[j], fora_[i]))
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        cab.append(_objeto("cabelo_tempora_%+d" % sx, bm, cabelo))
    perfil = [(-_pf(38.5), _niv(linha + 0.5)),
              (-_pf(22.0), _niv(284.0)), (-_pf(14.0), _niv(292.0)),
              (_pf(20.0), _niv(292.0))]
    escalas = (1.0, 0.78, 0.58, 0.30)
    for i, (u0, u1) in enumerate(((-60.0, -42.0), (-39.0, -21.0), (-18.0, -2.0),
                                  (2.0, 18.0), (21.0, 39.0), (42.0, 60.0))):
        cab.append(_mecha("cabelo_mecha_%d" % i, perfil, escalas, _lg(u0), _lg(u1),
                          (_pf(0.4), _pf(3.0), _pf(3.0), _pf(3.0)), cabelo))
    y_coque = 32.0
    cab.append(_loft("coque_liga", [(293.0, _anel_redondo(24.0, 12), y_coque),
                                    (287.0, _anel_redondo(24.0, 12), y_coque)],
                     M["colete"], fechar=(True, True)))
    cab.append(_loft("coque", [
        (322.0, _anel_redondo(11.0), y_coque),
        (315.0, _anel_redondo(24.0), y_coque),
        (304.0, _anel_redondo(31.0), y_coque),
        (293.0, _anel_redondo(29.0), y_coque),
        (286.0, _anel_redondo(19.0), y_coque),
    ], cabelo, fechar=(True, True)))

    # O LÁPIS, por cima da orelha direita (da imagem), com a ponta à frente.
    r_l = _lg(4.5)
    a = Vector((_lg(85.0), _pf(26.0), _niv(268.0)))
    b = Vector((_lg(89.0), -_pf(22.0), _niv(244.0)))
    cab.append(_bastao("lapis", a, b, r_l, 6, M["capacete"]))
    d = (b - a).normalized()
    for nome, t0, t1, rr, mat in (("lapis_madeira", 0.0, _lg(8.0), r_l, M["madeira"]),
                                  ("lapis_grafite", _lg(8.0), _lg(11.0), r_l * 0.4, escuro)):
        bpy.ops.mesh.primitive_cone_add(vertices=6, radius1=rr, radius2=rr * 0.35,
                                        depth=t1 - t0, location=b + d * ((t0 + t1) / 2.0))
        o = bpy.context.active_object
        o.name = nome
        o.rotation_mode = "QUATERNION"
        o.rotation_quaternion = Vector((0, 0, 1)).rotation_difference(d)
        o.data.materials.append(mat)
        cab.append(o)

    # O PESCOÇO E O TRONCO: secção de 12 lados, e um ombro de verdade —
    # trapézio, prateleira e a quina redonda do deltoide.
    tronco_l.append(prisma("pescoco", _contorno_oitavado(54.0, 46.0, 10.0),
                           _niv(84.0 + _DZ), _niv(152.0), (1.0, 1.0), pele))
    tronco_l.append(prisma("pescoco_sombra", _contorno_oitavado(55.0, 47.0, 10.0),
                           _niv(128.0), _niv(141.0), (1.0, 1.0), sombra))
    tronco = _loft("tronco", [
        (96.0 + _DZ, 62.0, 52.0, 15.0),
        (90.0 + _DZ, 108.0, 60.0, 21.0),
        (82.0 + _DZ, 172.0, 68.0, 28.0),
        (77.0 + _DZ, 206.0, 74.0, 33.0),
        (67.0 + _DZ, 227.0, 78.0, 36.0),
        (51.0 + _DZ, 236.0, 80.0, 38.0),
        (0.0 + _DZ, 238.0, 80.0, 38.0),
        (-90.0, 238.0, 80.0, 38.0),
    ], blusa, contorno=_contorno_12)
    tronco_l.append(tronco)
    tronco_l.append(prisma("gola_pe", _contorno_oitavado(62.0, 54.0, 14.0),
                           _niv(94.0 + _DZ), _niv(106.0 + _DZ), (1.0, 1.0), gola))
    y_peito = -_pf(40.0)
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0.0, y_peito - _pf(0.6),
                                                        (_niv(62.0) + _niv(-60.0)) / 2.0))
    carcela = bpy.context.active_object
    carcela.name = "carcela"
    carcela.scale = (_lg(14.0), _pf(2.4), _niv(62.0) - _niv(-60.0))
    carcela.data.materials.append(blusa)
    tronco_l.append(carcela)
    for nome, z_c, alt_b, larg_b, sai in (("bolso", 26.0, 28.0, 32.0, 0.8),
                                          ("bolso_pestana", 38.0, 7.0, 35.0, 1.8)):
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(_lg(52.0), y_peito - _pf(sai / 2.0),
                                                            _niv(z_c)))
        o = bpy.context.active_object
        o.name = nome
        o.scale = (_lg(larg_b), _pf(sai + 1.0), _alt(alt_b))
        o.data.materials.append(blusa)
        tronco_l.append(o)
    bpy.context.view_layer.update()
    for sx in (-1.0, 1.0):
        tronco_l.append(_retalho("gola_%+d" % sx, [tronco],
                                 ((4.0 * sx, 94.0 + _DZ), (28.0 * sx, 96.0 + _DZ),
                                  (54.0 * sx, 76.0 + _DZ), (18.0 * sx, 52.0 + _DZ)),
                                 gola, espelhado=sx < 0))
    for k, zz in enumerate((48.0, 30.0, 12.0)):
        ok = _raio([carcela], Vector((0.0, -10.0, _niv(zz))), Vector((0, 1, 0)))
        assert ok, "o botão não achou a carcela"
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=ok[0] + ok[1] * _pf(1.0))
        b = bpy.context.active_object
        b.name = "botao_%d" % k
        b.scale = (_lg(8.0), _pf(2.0), _alt(8.0))
        b.data.materials.append(gola)
        tronco_l.append(b)
    return tronco_l, cab


# ────────────────────────────────────────────────────────────── o Sr. Ribeiro
# RETANGULAR E ALTO (plano de arte P2: o quadrado lê sólido e fiável, e ele é
# o banco). A cabeça é mais estreita e mais alta do que a da Dona Cida — 146 ×
# 172 contra 158 × 144 —, com o maxilar QUADRADO (estreita 14% para o queixo,
# contra 20% dela), o crânio de tampo largo e careca, e os ombros do terno
# direitos, de prateleira quase plana.
RIBEIRO = Rosto(larg=150.0, fundo=80.0, z=(128.0, 278.0), maxilar=184.0, corte=16.0,
                z_olho=212.0, z_boca=160.0, pivo=112.0, u_olho=32.0,
                olho=(40.0, 26.0), iris=(21.0, 23.0), pupila=(11.0, 13.0),
                u_sobr=(23.0, 42.0), sobr=(23.0, 8.0, 7.0),
                brilho=6.5, boca_k=1.1, boca_alt=3.5, labio_k=0.55)


def ribeiro(M, cara):
    """O busto do Sr. Ribeiro, de FRENTE: (tronco, cabeça).

    O QUE A IDENTIDADE DELE JÁ TINHA DECIDIDO, no `_ribeiro` de caixas que este
    substitui: a CARECA com a coroa grisalha é metade da silhueta (ele é o mais
    velho dos três), as RUGAS dizem a idade que a careca sozinha não diz, e o
    terno lê como terno de BANCO pelas lapelas, a gravata e o lenço — peças da
    função, como a plataforma de carga do armazém.
    """
    r = RIBEIRO
    pele = M["pele_clara"]
    sombra = M["pele"]
    escuro = M["vao"]
    # ⚠️ O GRISALHO DA PALETA TEM O VALOR DA PELE CLARA (~161 os dois): no
    # bordo da cabeça ele não se separava dela. O cabelo branco-acinzentado
    # (`concreto`, ~192) separa pelo valor e continua a ler grisalho.
    cabelo = _principled("cabelo_ribeiro", base.PALETA["concreto"], rough=0.6, spec=0.2)
    # Os FIOS: as camadas recuadas da ferradura, um passo abaixo no cinzento.
    cabelo_fios = _principled("cabelo_fios_ribeiro", base.PALETA["cabelo_grisalho"],
                              rough=0.8, spec=0.1)
    # ⚠️ A SOBRANCELHA NÃO É DA COR DO CABELO: o grisalho (lum. ~161) e a
    # pele clara (~161) têm o MESMO valor, e uma sobrancelha grisalha some na
    # testa — a regra do contraste contra o FUNDO, com a testa por fundo.
    sobrancelha = _principled("sobrancelha_ribeiro", base.PALETA["metal"], rough=0.9)
    terno = _principled("terno_ribeiro", base.PALETA["casco"], rough=0.85)
    # A LAPELA É ACETINADA: um navy um passo mais escuro sumia no terno (as
    # duas primeiras prévias); com brilho ela apanha a luz-chave e desenha o V.
    lapela = _principled("lapela_ribeiro", base.PALETA["terno_lapela"], rough=0.35, spec=0.6)
    camisa = _principled("camisa_ribeiro", base.PALETA["cabine"], rough=0.9)
    gravata = _principled("gravata_ribeiro", base.PALETA["faixa"], rough=0.6, spec=0.2)
    labio = _principled("labio_ribeiro", base.PALETA["pele"], rough=0.8)
    cab, tronco_l = [], []

    # A CABEÇA: maxilar quadrado e o crânio de tampo largo, sem calote.
    cab.append(prisma("cabeca_maxilar", _contorno_oitavado(r.larg, r.fundo, r.corte),
                      _niv(r.z[0]), _niv(r.maxilar), (0.90, 1.0), pele))
    cab.append(_loft("cabeca_cranio", [
        (r.z[1], 112.0, 62.0, 16.0, 3.0),
        (r.z[1] - 6.0, 136.0, 72.0, 16.0, 1.5),
        (266.0, r.larg - 2.0, r.fundo, r.corte),
        (r.maxilar, r.larg, r.fundo, r.corte),
    ], pele))
    queixo = _placa(r, "queixo", 0.0, 138.0, 50.0, 12.0, pele, esp=_pf(4.0))
    queixo.visible_shadow = False
    cab.append(queixo)
    for sx in (-1.0, 1.0):
        o = prisma("orelha_%+d" % sx, _contorno_oitavado(16.0, 28.0, 5.0),
                   _niv(182.0), _niv(218.0), (1.0, 1.0), pele)
        o.location.x += sx * _lg(r.larg / 2.0 + 4.0)
        o.location.y += _pf(2.0)
        cab.append(o)

    cab += _olhos(r, M, cara, pele, escuro)
    cab += _sobrancelhas(r, cara, sobrancelha)
    nariz = _cunha(r, "nariz", 206.0, 179.0, 10.0, 21.0, 2.0, 9.0, pele)
    nariz.visible_shadow = False
    cab.append(nariz)
    cab.append(_placa(r, "nariz_base", 0.0, 176.5, 22.0, 3.5, sombra))
    # ⚠️ OS LÁBIOS SÃO FINOS (`labio_k`): o de baixo em `pele`, na altura da
    # Dona Cida, fazia uma PRATELEIRA escura por baixo da linha (a v2); sem
    # lábio nenhum a boca ficava um risco (a v3). E a boca é só 10% mais larga
    # do que a dela, com a linha da mesma grossura — o Bruno pediu-a «mais
    # curta» e «mais fina» depois de a v2 a ter alargado 30%.
    cab += _boca(r, M, cara, escuro, labio)

    # A IDADE, em placas de sombra: duas rugas na testa e os pés-de-galinha.
    # Rasas (`esp` pequeno), para não projetarem sombra.
    # ⚠️ O SULCO DO NARIZ À BOCA SAIU: dois traços que desciam até aos cantos
    # desenhavam PARÊNTESES à volta da boca, e ela lia como a de um boneco de
    # ventríloquo — «a boca parece meio estranha» (o Bruno, na v2).
    for i, (zz, lg) in enumerate(((248.0, 60.0), (256.0, 46.0))):
        cab.append(_placa(r, "ruga_testa_%d" % i, 0.0, zz, lg, 2.5, sombra, esp=_pf(0.8)))
    for sx in (-1.0, 1.0):
        cab.append(_placa(r, "pe_de_galinha_%+d" % sx, (r.u_olho + 23.0) * sx, r.z_olho - 2.0,
                          9.0, 2.0, sombra, esp=_pf(0.8), inclina=-12.0 * sx))
    for o in cab:
        if o.name.startswith(("ruga", "pe_de")):
            o.visible_shadow = False

    # O CABELO É UMA FERRADURA, uma peça só: das têmporas, por cima das
    # orelhas, à nuca. Na v2 eram três (dois lados e uma fita atrás), e o Bruno
    # leu a fita «solta dos lados».
    #
    # ⚠️ ELA SÓ SE VÊ SE PASSAR ACIMA DO CRÂNIO NA IMAGEM, e não no mundo. A
    # câmera olha de cima: o que está atrás SOBE na imagem (meia unidade de
    # altura por unidade de fundo), então o topo dela sobe da têmpora para a
    # nuca e, atrás, espreita por cima da borda de trás do crânio. De frente
    # ele continua careca.
    cab += _ferradura(r, "cabelo_ferradura", cabelo, cabelo_fios)

    # O PESCOÇO E O TERNO: o ombro é de PRATELEIRA quase plana, que é o que o
    # enchimento de um terno faz — o da Dona Cida cai, o dele não.
    tronco_l.append(prisma("pescoco", _contorno_oitavado(50.0, 46.0, 10.0),
                           _niv(76.0), _niv(140.0), (1.0, 1.0), pele))
    tronco_l.append(prisma("pescoco_sombra", _contorno_oitavado(51.0, 47.0, 10.0),
                           _niv(116.0), _niv(128.0), (1.0, 1.0), sombra))
    tronco = _loft("tronco", [
        (92.0, 64.0, 56.0, 16.0),
        (87.0, 122.0, 64.0, 22.0),
        (82.0, 200.0, 74.0, 30.0),
        (77.0, 250.0, 80.0, 34.0),
        (66.0, 268.0, 84.0, 36.0),
        (48.0, 272.0, 86.0, 38.0),
        (0.0, 272.0, 86.0, 38.0),
        (-90.0, 272.0, 86.0, 38.0),
    ], terno, contorno=_contorno_12)
    tronco_l.append(tronco)
    tronco_l.append(prisma("colarinho", _contorno_oitavado(58.0, 54.0, 14.0),
                           _niv(88.0), _niv(104.0), (1.0, 1.0), camisa))
    bpy.context.view_layer.update()
    # A CAMISA, a gravata e as lapelas cruzam-se, logo cada uma leva o seu
    # `afasta`: camisa rente, gravata por cima dela, lapelas por cima de tudo
    # (a gravata passa POR BAIXO do casaco, como num terno de verdade).
    tronco_l.append(_retalho("camisa", [tronco],
                             ((-24.0, 96.0), (24.0, 96.0), (3.0, 18.0), (-3.0, 18.0)),
                             camisa, afasta=1.0))
    tronco_l.append(_retalho("gravata", [tronco],
                             ((-6.0, 92.0), (6.0, 92.0), (9.0, 32.0), (-9.0, 32.0)),
                             gravata, afasta=2.2))
    tronco_l.append(_retalho("gravata_no", [tronco],
                             ((-8.0, 99.0), (8.0, 99.0), (6.0, 87.0), (-6.0, 87.0)),
                             gravata, afasta=3.2))
    for sx in (-1.0, 1.0):
        tronco_l.append(_retalho("colarinho_ponta_%+d" % sx, [tronco],
                                 ((4.0 * sx, 100.0), (26.0 * sx, 102.0),
                                  (22.0 * sx, 82.0), (9.0 * sx, 78.0)),
                                 camisa, afasta=3.6, espelhado=sx < 0))
        tronco_l.append(_retalho("lapela_%+d" % sx, [tronco],
                                 ((20.0 * sx, 96.0), (48.0 * sx, 90.0),
                                  (26.0 * sx, 16.0), (4.0 * sx, 16.0)),
                                 lapela, afasta=2.8, espelhado=sx < 0))
    # O LENÇO NO BOLSO, do lado esquerdo da imagem, com a boca do bolso por
    # baixo: três pixels de branco no navy que dizem «banco».
    tronco_l.append(_retalho("lenco", [tronco],
                             ((-66.0, 46.0), (-46.0, 49.0), (-46.0, 38.0), (-66.0, 38.0)),
                             camisa, afasta=1.6, espelhado=True))
    tronco_l.append(_retalho("bolso", [tronco],
                             ((-70.0, 38.0), (-42.0, 38.0), (-42.0, 34.0), (-70.0, 34.0)),
                             lapela, afasta=1.2, espelhado=True))
    tronco_l.append(_retalho("fecho", [tronco],
                             ((-1.5, 16.0), (1.5, 16.0), (1.5, -68.0), (-1.5, -68.0)),
                             lapela, afasta=1.0))
    ok = _raio([tronco], Vector((0.0, -10.0, _niv(6.0))), Vector((0, 1, 0)))
    assert ok, "o botão não achou o terno"
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=ok[0] + ok[1] * _pf(1.5))
    b = bpy.context.active_object
    b.name = "botao"
    b.scale = (_lg(9.0), _pf(2.0), _alt(9.0))
    b.data.materials.append(lapela)
    tronco_l.append(b)
    return tronco_l, cab


# ────────────────────────────────────────────────────────────── o Arlindo
# DE ÂNGULOS (plano de arte P2: o triângulo lê ameaça, e ele é o rival que
# sorri quando ataca). O maxilar é um V — largo nas maçãs, a fechar no
# queixo —, o bigode é uma divisa, as patilhas acabam em bico e a gola abre
# em pontas. O boné é a exceção, e redondo de propósito: é a peça redonda por
# excelência, e oitavado lia como caixa (o Bruno, na v1).
ARLINDO = Rosto(larg=156.0, fundo=78.0, z=(132.0, 276.0), maxilar=196.0, corte=22.0,
                z_olho=216.0, z_boca=162.0, pivo=112.0, u_olho=33.0,
                olho=(42.0, 26.0), iris=(21.0, 23.0), pupila=(11.0, 13.0),
                u_sobr=(24.0, 44.0), sobr=(24.0, 7.0, 6.0),
                brilho=7.0, boca_k=1.15, boca_alt=3.5, labio_k=0.55)


def _anel_eliptico(larg, fundo, lados=16):
    """Um anel ELÍPTICO de `lados`, em pixels de desenho: o redondo do boné."""
    return [(_lg(larg / 2.0) * math.cos(2 * math.pi * i / lados),
             _pf(fundo / 2.0) * math.sin(2 * math.pi * i / lados)) for i in range(lados)]


def _pala(nome, mat, faixa, z_px, avanca=26.0, desce=4.0, esp=5.0, abre=0.92):
    """A pala do boné: uma cunha em arco que NASCE da curva da faixa.

    `faixa` é (largura, fundo, y do centro) da elipse da faixa, em pixels de
    desenho; a pala cobre `abre` da largura dela, e cada ponto da base assenta
    na elipse — com a base a direito (a v3) as pontas da pala saíam soltas dos
    lados do boné, e o Bruno pediu-a «melhor encaixada».

    ⚠️ ELA NÃO PODE TAPAR AS SOBRANCELHAS, que são metade das caras dele — é
    a armadilha que o boné de caixas já tinha registado: nesta câmera avançar
    é descer na imagem (meia unidade por unidade de fundo).
    """
    lf, ff, yf = faixa
    meia = lf / 2.0 * abre
    pts = []
    for i in range(13):
        a = math.pi * i / 12.0
        x = -math.cos(a) * meia
        s_ = math.sin(a)
        y_base = yf - (ff / 2.0) * math.sqrt(max(0.0, 1.0 - (x / (lf / 2.0)) ** 2))
        pts.append((x, y_base, s_))
    bm = bmesh.new()
    camadas = []
    for dz in (0.0, esp):
        frente = [bm.verts.new((_lg(x), _pf(yb - avanca * s_), _niv(z_px - desce * s_ + dz)))
                  for x, yb, s_ in pts]
        base = [bm.verts.new((_lg(x), _pf(yb + 2.0), _niv(z_px + dz))) for x, yb, _ in pts]
        camadas.append((frente, base))
    (fb, bb), (ft, bt) = camadas
    for i in range(len(pts) - 1):
        j = i + 1
        bm.faces.new((bb[i], bb[j], fb[j], fb[i]))
        bm.faces.new((bt[i], ft[i], ft[j], bt[j]))
        bm.faces.new((fb[i], fb[j], ft[j], ft[i]))
        bm.faces.new((bb[j], bb[i], bt[i], bt[j]))
    bm.faces.new((bb[0], fb[0], ft[0], bt[0]))
    bm.faces.new((fb[-1], bb[-1], bt[-1], ft[-1]))
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    return _objeto(nome, bm, mat)


def _patilha(r, nome, sx, mat, z_topo=252.0, z_bico=198.0, fundo_px=26.0, esp=5.0):
    """Uma patilha que acaba em BICO para a frente — o corte em ângulo dele."""
    lx = r.larg / 2.0
    perfil = ((-_pf(r.fundo / 2.0 - 8.0), z_bico), (-_pf(r.fundo / 2.0 - 10.0), z_topo),
              (-_pf(r.fundo / 2.0 - 10.0 - fundo_px), z_topo),
              (-_pf(r.fundo / 2.0 - 10.0 - fundo_px), z_bico + 16.0))
    bm = bmesh.new()
    camadas = []
    for x_px in (lx - 2.0, lx + esp):
        camadas.append([bm.verts.new((sx * _lg(x_px), y, _niv(zz))) for y, zz in perfil])
    dentro, fora_ = camadas
    bm.faces.new(fora_)
    bm.faces.new(list(reversed(dentro)))
    for i in range(4):
        j = (i + 1) % 4
        bm.faces.new((dentro[i], dentro[j], fora_[j], fora_[i]))
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    return _objeto(nome, bm, mat)


def _envolver(nome, alvos, limites, mat, centro=(0.0, 0.0), angulos=(-35.0, 140.0),
              linhas=28, colunas=8, afasta=2.0, espessura=2.5, lado=1.0, ate_z=None):
    """Um retalho que ENVOLVE o tronco: das costas, por cima do ombro, pela frente.

    O `_retalho` pousa por raios de frente e o `_retalho_cima` por raios de
    cima; uma peça de roupa que passa o ombro precisava dos dois, e duas peças
    encostadas leem como «vários pedaços colados» (o Bruno, no colete da v4).
    Aqui os raios saem de um EIXO em `x`, no ponto `centro` (fundo, altura em
    pixels de desenho), em leque: o ângulo 0 é para cima, 90 é para a frente
    (−y), e cada linha da grade é um ângulo. Uma superfície só, contínua.

    `limites(z_px)` devolve (u de dentro, u de fora) da peça à altura em que a
    linha acerta o tronco — é o contorno dela, e é medido no desenho.
    """
    cy, cz = _pf(centro[0]), _niv(centro[1])
    bm = bmesh.new()
    grade = []
    for k in range(linhas + 1):
        a = math.radians(angulos[0] + (angulos[1] - angulos[0]) * k / linhas)
        d = Vector((0.0, -math.sin(a), math.cos(a)))
        # A altura desta linha: o raio do meio da peça.
        meio = _raio(alvos, Vector((lado * _lg(50.0), cy, cz)) + d * 20.0, -d)
        assert meio, "o retalho %s não achou o tronco na linha %d" % (nome, k)
        # `_niv` é afim: desfaz-se pela diferença de dois pontos.
        z_px = 1.0 + (meio[0].z - _niv(1.0)) / (_niv(2.0) - _niv(1.0))
        # `ate_z`: a peça acaba nesta altura da frente (a faixa vertical, que
        # desce do ombro só até à horizontal).
        if ate_z is not None and k > 0 and z_px < ate_z and d.y < 0:
            break
        u0, u1 = limites(z_px)
        lin = []
        for i in range(colunas + 1):
            u = u0 + (u1 - u0) * i / colunas
            ok = None
            for tent in range(6):
                ok = _raio(alvos, Vector((lado * _lg(u), cy, cz)) + d * 20.0, -d)
                if ok:
                    break
                u -= 2.0 * (1 if u > 0 else -1)
            assert ok, "o retalho %s não achou o tronco em u=%.0f" % (nome, u)
            lin.append(bm.verts.new(ok[0] + ok[1] * _pf(afasta)))
        grade.append(lin)
    for k in range(len(grade) - 1):
        for i in range(colunas):
            f = (grade[k][i], grade[k][i + 1], grade[k + 1][i + 1], grade[k + 1][i])
            bm.faces.new(tuple(reversed(f)) if lado < 0 else f)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    o = _objeto(nome, bm, mat)
    o.modifiers.new("espessura", "SOLIDIFY").thickness = _pf(espessura)
    return o


def _decalque(nome, alvos, u_c, z_c, ru, rz, mat, afasta=0.8, espessura=0.6, lados=14):
    """Uma placa OVAL pousada por raios de frente: o adesivo do capacete.

    Oval e chata de propósito: o quadrado claro com o miolo escuro da v4 lia
    como a LANTERNA de um capacete de mineiro (o Bruno).
    """
    bm = bmesh.new()
    pts = []
    for i in range(lados):
        a = 2.0 * math.pi * i / lados
        ok = _raio(alvos, Vector((_lg(u_c + ru * math.cos(a)), -10.0,
                                  _niv(z_c + rz * math.sin(a)))), Vector((0, 1, 0)))
        assert ok, "o decalque %s não achou o casco" % nome
        pts.append(bm.verts.new(ok[0] + ok[1] * _pf(afasta)))
    bm.faces.new(pts)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    o = _objeto(nome, bm, mat)
    o.modifiers.new("espessura", "SOLIDIFY").thickness = _pf(espessura)
    return o


def _retalho_cima(nome, alvos, cantos, mat, afasta=1.2, espessura=2.0, n=4):
    """O `_retalho` para um TETO: os pontos descem por raios de cima até ao
    tronco. `cantos` são quatro (u, fundo) em pixels de desenho, em planta —
    é o que pousa uma dragona ao comprido do ombro, que é teto e não peito.
    """
    A, B, C, D = cantos
    bm = bmesh.new()
    grade = []
    for j in range(n + 1):
        fv = j / n
        lin = []
        for i in range(n + 1):
            fu = i / n
            x = (A[0] * (1 - fu) * (1 - fv) + B[0] * fu * (1 - fv)
                 + C[0] * fu * fv + D[0] * (1 - fu) * fv)
            y = (A[1] * (1 - fu) * (1 - fv) + B[1] * fu * (1 - fv)
                 + C[1] * fu * fv + D[1] * (1 - fu) * fv)
            ok = _raio(alvos, Vector((_lg(x), _pf(y), 10.0)), Vector((0, 0, -1)))
            assert ok, "o retalho %s não achou o teto em %s" % (nome, (x, y))
            lin.append(bm.verts.new(ok[0] + ok[1] * _pf(afasta)))
        grade.append(lin)
    for j in range(n):
        for i in range(n):
            f = (grade[j][i], grade[j][i + 1], grade[j + 1][i + 1], grade[j + 1][i])
            bm.faces.new(f)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    o = _objeto(nome, bm, mat)
    o.modifiers.new("espessura", "SOLIDIFY").thickness = _pf(espessura)
    return o


def arlindo(M, cara):
    """O busto do Capitão Arlindo, de FRENTE: (tronco, cabeça).

    O QUE A IDENTIDADE DELE JÁ TINHA DECIDIDO, no `_arlindo` de caixas que este
    substitui: o BONÉ É NAVY e não branco (um boné de capitão branco mede
    0,016 de Weber contra o balão de fala — sobre o papel claro é um buraco com
    contorno), o EMBLEMA vai na frente do boné e não pousado na aba, e a GOLA
    é aberta — familiaridade como ferramenta; fechada com gravata seria o Sr.
    Ribeiro.
    """
    r = ARLINDO
    pele = M["pele"]
    sombra = M["pele_escura"]
    escuro = M["vao"]
    cabelo = _principled("cabelo_arlindo", base.PALETA["madeira_esc"], rough=0.6, spec=0.2)
    # ⚠️ O BIGODE EM `madeira` TEM QUASE O VALOR DA PELE (~112 contra ~133) e
    # sumia na cara; no escuro do cabelo ele lê, e a boca fica separada dele
    # por uma fresta de pele. A sobrancelha vai ao escuro da boca: debaixo do
    # boné a testa está na meia-sombra, e o castanho não se separava dela.
    bigode = _principled("bigode_arlindo", base.PALETA["madeira_esc"], rough=0.7)
    sobrancelha = _principled("sobrancelha_arlindo", base.PALETA["vao"], rough=0.9)
    bigode_fundo = _principled("bigode_fundo_arlindo", base.PALETA["cabelo_fundo"],
                               rough=0.8)
    # O FIO DO CABELO: o `porta`, quase o castanho — as camadas e as mechas
    # desenham-se pela sombra entre elas, não por um tom contrário.
    cabelo_fio = _principled("cabelo_fio_arlindo", base.PALETA["porta"], rough=0.7)
    bone = _principled("bone_arlindo", base.PALETA["casco"], rough=0.8)
    faixa = _principled("bone_faixa_arlindo", base.PALETA["capacete"], rough=0.45, spec=0.5)
    pala = _principled("bone_pala_arlindo", base.PALETA["vao"], rough=0.25, spec=0.7)
    # A CAMISA é o `azul` da paleta: o `vidro` da v1 era claro e lavado, e o
    # Bruno pediu «outro azul», mais escuro e saturado. As dragonas ficam
    # navy; a gola e os bolsos são da cor da camisa — a gola navy lia como um
    # babeiro (o Bruno, na v2) — e desenham-se pela sombra da borda.
    camisa = _principled("camisa_arlindo", base.PALETA["azul"], rough=0.9)
    navy = _principled("navy_arlindo", base.PALETA["casco"], rough=0.85)
    labio = _principled("labio_arlindo", base.PALETA["pele_escura"], rough=0.8)
    cab, tronco_l = [], []

    # A CABEÇA: o crânio (quase todo debaixo do boné) e o maxilar em V.
    # ⚠️ O V DA v1 FECHAVA NUM QUEIXO DE 40, e o Bruno leu-o pontudo demais;
    # o de 70 da v2 e da v3 ainda saía «mais fino do que os outros
    # personagens». O de agora fecha em 104 — o da Dona Cida acaba em 126 —,
    # e o ângulo fica nas maçãs, onde o V começa.
    # O crânio sobe até dentro da faixa: com o boné para trás (ver abaixo), um
    # crânio que acabasse aos 276 deixava uma fresta de fundo por baixo dela.
    cab.append(_loft("cabeca_cranio", [
        (r.z[1] + 6.0, 140.0, 70.0, 18.0, 2.0),
        (266.0, r.larg - 4.0, r.fundo, r.corte),
        (r.maxilar, r.larg, r.fundo, r.corte),
    ], pele))
    maxilar = _loft("cabeca_maxilar", [
        (r.maxilar, r.larg, r.fundo, r.corte),
        (178.0, 154.0, 76.0, 22.0),
        (160.0, 140.0, 72.0, 20.0),
        (145.0, 122.0, 64.0, 18.0),
        (r.z[0], 104.0, 56.0, 14.0),
    ], pele, fechar=(False, True))
    cab.append(maxilar)
    for sx in (-1.0, 1.0):
        o = prisma("orelha_%+d" % sx, _contorno_oitavado(16.0, 28.0, 5.0),
                   _niv(196.0), _niv(230.0), (1.0, 1.0), pele)
        o.location.x += sx * _lg(r.larg / 2.0 + 2.0)
        o.location.y += _pf(4.0)
        cab.append(o)

    cab += _olhos(r, M, cara, pele, escuro)
    cab += _sobrancelhas(r, cara, sobrancelha)
    # O nariz da v2 (22 de ponta, 10 de saliência) era grande (o Bruno).
    nariz = _cunha(r, "nariz", 210.0, 185.0, 9.0, 17.0, 2.0, 8.0, pele)
    nariz.visible_shadow = False
    cab.append(nariz)
    cab.append(_placa(r, "nariz_base", 0.0, 182.5, 18.0, 3.0, sombra))
    cab += _boca(r, M, cara, escuro, labio)
    # O BIGODE, CHEIO E REDONDO. As voltas: «maior» (v1), «mais detalhado»
    # (v3), «mais refinado» (v4) — e na v5 os cinco tufos a alternar um tom
    # claro liam como os DENTES DE UM PENTE. Agora: uma base escura por asa,
    # quatro tufos todos no castanho do cabelo por cima dela (o fio é a
    # sombra fina entre eles, e não um tom contrário) e as PONTAS a descer
    # pelos cantos da boca, que é o que o torna farto. A sorrir, as asas
    # abrem: o bigode sobe com as bochechas. O meio parte-se numa fresta de
    # pele (o sulco do lábio).
    asa = 5.0 if cara["boca"].startswith("sorriso") else 16.0
    zb = r.z_boca + 12.0
    tg = math.tan(math.radians(asa))
    for sx in (-1.0, 1.0):
        cab.append(_placa(r, "bigode_%+d" % sx, 18.0 * sx, zb, 40.0, 13.0, bigode_fundo,
                          fora=0.004, inclina=asa * sx))
        for k in range(4):
            du = 5.0 + 8.5 * k
            cab.append(_placa(r, "bigode_tufo_%+d_%d" % (sx, k), du * sx,
                              zb + 0.5 - (18.0 - du) * tg - 0.5 * k, 7.6, 11.0 - 0.8 * k,
                              bigode, fora=0.007, inclina=(asa + 5.0 * k - 6.0) * sx))
        cab.append(_placa(r, "bigode_ponta_%+d" % sx, 33.0 * sx, zb - 9.0 - 15.0 * tg, 7.0,
                          13.0, bigode, fora=0.007, inclina=12.0 * sx))
    cab.append(_placa(r, "bigode_sulco", 0.0, zb + 3.5, 3.0, 7.0, pele, fora=0.009))

    # A BARBA POR FAZER SAIU (o Bruno, na v3): em `pele_escura` lia como barba
    # cheia, e em cinzento eram manchas nos cantos do maxilar.

    # OS DETALHES DA EXPRESSÃO (o Bruno, na v3: «melhorar e refinar»). A pose,
    # a boca e a sobrancelha dizem a emoção; estas placas de sombra dizem-na
    # na pele, onde ela deixa marca:
    # - o sorriso vinca os cantos dos olhos (as maçãs num tom acima liam como
    #   RUBOR quadrado, e saíram);
    # - o franzido carregado vinca a pele ENTRE as sobrancelhas;
    # - a sobrancelha torta enruga a testa por cima da que sobe.
    rugas = []
    if cara["olho"] == "sorrindo":
        for sx in (-1.0, 1.0):
            rugas.append(_placa(r, "ruga_olho_%+d" % sx, (r.u_olho + 25.0) * sx, r.z_olho - 3.0,
                                9.0, 2.0, sombra, esp=_pf(0.8), inclina=-14.0 * sx))
            rugas.append(_placa(r, "ruga_olho_b_%+d" % sx, (r.u_olho + 24.0) * sx, r.z_olho + 3.0,
                                8.0, 2.0, sombra, esp=_pf(0.8), inclina=10.0 * sx))
    if cara["cenho"] == "carregada":
        for sx in (-1.0, 1.0):
            rugas.append(_placa(r, "ruga_cenho_%+d" % sx, 5.0 * sx, r.z_olho + 20.0, 2.0, 10.0,
                                sombra, esp=_pf(0.8), inclina=8.0 * sx))
    if cara["cenho"] == "torta":
        rugas.append(_placa(r, "ruga_testa", -40.0, r.z_olho + 37.0, 22.0, 2.0, sombra,
                            esp=_pf(0.8), inclina=6.0))
        # E a boca descontente puxa de UM lado: o canto direito desce mais.
        rugas.append(_placa(r, "boca_canto_torto", 21.0, r.z_boca - 5.0, 8.0, r.boca_alt,
                            escuro, fora=0.003, inclina=-30.0))
    for o in rugas:
        o.visible_shadow = False
    cab += rugas

    # O CABELO, em três camadas (o Bruno: «meio careca» na v3, e na v4 um
    # «capacete» liso):
    # - a CALOTE, cheia, no tom de sombra do cabelo — a mesma receita da Dona
    #   Cida: o que fica entre os fios é o degrau abaixo, não pele;
    # - por cima, dos lados e atrás, CAMADAS alternadas (a ferradura do Sr.
    #   Ribeiro, sem a parte de cima, que é do boné): os fios penteados;
    # - na testa, uma FRANJA de mechas curtas penteadas de lado, por baixo da
    #   pala.
    linha = 262.0
    calote = _loft("cabelo_calote", [
        (r.z[1] + 10.0, 134.0, 70.0, 18.0, 4.0),
        (272.0, r.larg + 4.0, r.fundo + 4.0, r.corte + 2.0, 1.0),
        (linha, r.larg + 6.0, r.fundo + 6.0, r.corte + 2.0),
        (228.0, r.larg + 6.0, r.fundo + 6.0, r.corte + 2.0),
        (204.0, r.larg + 2.0, r.fundo + 4.0, r.corte + 2.0),
    ], bigode_fundo)
    bm = bmesh.new()
    bm.from_mesh(calote.data)
    bmesh.ops.delete(bm, geom=[vv for vv in bm.verts
                               if vv.co.z < _niv(linha) - 1e-4 and vv.co.y < _pf(8.0)],
                     context="VERTS")
    bm.to_mesh(calote.data)
    bm.free()
    cab.append(calote)
    # ⚠️ SEIS CAMADAS RECUADAS 2,5 NUM TOM CLARO LIAM COMO LÂMINAS
    # empilhadas (o Bruno, na v5). Três, recuadas 1 e no `porta` — quase o
    # castanho do cabelo —, dão o fio sem o degrau.
    cab += _ferradura(r, "cabelo_camada", cabelo, cabelo_fio, folga=(4.0, 4.0), esp=4.0,
                      frente=-0.55, base=(236.0, 206.0), topo=(272.0, 276.0), camadas=3,
                      recuo=1.0)
    for k in range(9):
        u = -52.0 + 13.0 * k
        cab.append(_placa(r, "cabelo_mecha_%d" % k, u, linha + 5.0 + (1.5 if k % 2 else 0.0),
                          15.0, 9.0, cabelo if k % 2 == 0 else cabelo_fio,
                          fora=0.010, inclina=-22.0))
    for sx in (-1.0, 1.0):
        cab.append(_patilha(r, "cabelo_patilha_%+d" % sx, sx, cabelo, z_topo=linha + 2.0))

    # O BONÉ DE CAPITÃO, REDONDO, MOLE E PUXADO PARA TRÁS. As voltas:
    # - v1: copa alta, oitavada e aberta — o tampo navy, visto de cima, era do
    #   tamanho da cara, e a pala tapava as sobrancelhas;
    # - v2: redondo e mais pequeno, com a pala maior, que voltou a tapá-las;
    # - v3: 12° para trás, que virou o tampo para longe da câmera e subiu a
    #   pala — mas a copa baixa «parecia uma lata», a pala saía solta dos lados
    #   e o emblema em caixa «parecia fivela»;
    # - v4: 5° para trás, a copa mais alta e MOLE (abre em cima e arredonda a
    #   borda do tampo), a pala nascida da curva da faixa e uma âncora chata.
    y_bone = 2.0
    faixa_el = (150.0, 82.0, y_bone)
    bone_pecas = []
    bone_pecas.append(_loft("bone_copa", [
        (304.0, _anel_eliptico(146.0, 78.0), y_bone + 2.0),
        (301.0, _anel_eliptico(162.0, 90.0), y_bone + 1.0),
        (294.0, _anel_eliptico(160.0, 88.0), y_bone),
        (287.0, _anel_eliptico(150.0, 82.0), y_bone),
    ], bone, fechar=(True, True)))
    bone_pecas.append(_loft("bone_faixa", [
        (288.0, _anel_eliptico(152.0, 84.0), y_bone),
        (274.0, _anel_eliptico(150.0, 82.0), y_bone),
    ], faixa, fechar=(False, False)))
    p_ = _pala("bone_pala", pala, faixa_el, z_px=274.0)
    # A pala não projeta sombra: com ela, a chave apagava as sobrancelhas e
    # metade dos olhos, que são as caras dele.
    p_.visible_shadow = False
    bone_pecas.append(p_)
    # O FRISO fica POR BAIXO da pala e só a borda da frente sai dela: por
    # cima, cobria-a toda e a pala lia como vidro (a primeira prévia da v4).
    friso = _pala("bone_pala_friso", M["metal_claro"], faixa_el, z_px=272.5,
                  avanca=28.0, esp=1.5, abre=0.93)
    friso.visible_shadow = False
    bone_pecas.append(friso)
    # A ÂNCORA, chata na frente da copa. ⚠️ HASTE E CEPO SOZINHOS SÃO UMA
    # CRUZ: é o U largo dos braços, virado para cima, que a faz âncora (a
    # primeira prévia lia-se como crucifixo). O cepo é curto e a argola fica.
    y_anc = -_pf(45.5)
    for nome, u, zz, lg, alt, ang in (("ancora_haste", 0.0, 293.5, 3.0, 15.0, 0.0),
                                      ("ancora_cepo", 0.0, 298.5, 8.0, 2.5, 0.0),
                                      ("ancora_argola", 0.0, 302.0, 4.5, 4.0, 0.0),
                                      ("ancora_braco_-1", -6.0, 289.0, 12.0, 3.0, 40.0),
                                      ("ancora_braco_+1", 6.0, 289.0, 12.0, 3.0, -40.0),
                                      ("ancora_pata_-1", -11.5, 293.5, 4.0, 4.0, 0.0),
                                      ("ancora_pata_+1", 11.5, 293.5, 4.0, 4.0, 0.0)):
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(_lg(u), y_anc, _niv(zz)))
        a_ = bpy.context.active_object
        a_.name = "bone_%s" % nome
        a_.scale = (_lg(lg), _pf(2.0), _alt(alt))
        a_.rotation_euler.y = math.radians(ang)
        a_.data.materials.append(faixa)
        bone_pecas.append(a_)
    pivo = Vector((0.0, _pf(r.fundo / 2.0), _niv(276.0)))
    tras = Matrix.Translation(pivo) @ Matrix.Rotation(math.radians(-5.0), 4, "X") \
        @ Matrix.Translation(-pivo)
    bpy.context.view_layer.update()
    for o in bone_pecas:
        o.matrix_world = tras @ o.matrix_world
    cab += bone_pecas

    # O PESCOÇO E O TRONCO: ombro largo e a descer em V para a cintura.
    tronco_l.append(prisma("pescoco", _contorno_oitavado(56.0, 50.0, 12.0),
                           _niv(80.0), _niv(146.0), (1.0, 1.0), pele))
    # SEM A SOMBRA DO PESCOÇO: com o queixo largo ela já não fazia falta, e lia
    # como uma LINHA a meio do pescoço (o Bruno, na v3). ⚠️ E a linha AZUL que
    # sobrou (v5) era o TAMPO do tronco: o anel de cima, 5 px mais largo do
    # que o pescoço, fechava à volta dele num aro da cor da camisa. Agora esse
    # anel cabe dentro do pescoço.
    tronco = _loft("tronco", [
        (98.0, 50.0, 44.0, 12.0),
        (92.0, 132.0, 64.0, 22.0),
        (84.0, 218.0, 76.0, 30.0),
        (72.0, 262.0, 82.0, 36.0),
        (54.0, 274.0, 84.0, 38.0),
        (20.0, 266.0, 82.0, 36.0),
        (-40.0, 244.0, 78.0, 34.0),
        (-90.0, 236.0, 76.0, 32.0),
    ], camisa, contorno=_contorno_12)
    tronco_l.append(tronco)
    bpy.context.view_layer.update()
    # ⚠️ A GOLA ABERTA É LARGA E CURTA: o V de pele comprido, entre duas
    # pontas, lia como GRAVATA (o Bruno, na v1). Agora a pele é um trapézio
    # baixo, as pontas abrem para os ombros, e por baixo corre a CARCELA com
    # os botões — é ela que diz «camisa desabotoada».
    tronco_l.append(_retalho("peito", [tronco],
                             ((-26.0, 98.0), (26.0, 98.0), (8.0, 76.0), (-8.0, 76.0)),
                             pele, afasta=1.0))
    tronco_l.append(_retalho("carcela", [tronco],
                             ((-6.0, 78.0), (6.0, 78.0), (6.0, -70.0), (-6.0, -70.0)),
                             camisa, afasta=1.4))
    # OS BOTÕES SÃO DE LATÃO, redondos e com o miolo afundado — «mais
    # estilosos» (o Bruno, na v3): os quadrados brancos liam como pontos de
    # camisa de hospital; os de latão rimam com o boné e as dragonas.
    for k, zz in enumerate((62.0, 36.0, 10.0)):
        ok = _raio([tronco], Vector((0.0, -10.0, _niv(zz))), Vector((0, 1, 0)))
        assert ok, "o botão não achou a camisa"
        for nome, rr, sai, mat in (("botao_%d" % k, 4.5, 3.0, faixa),
                                   ("botao_miolo_%d" % k, 2.0, 3.8, bigode_fundo)):
            bpy.ops.mesh.primitive_cylinder_add(vertices=10, radius=_lg(rr),
                                                depth=_pf(1.6),
                                                location=ok[0] + ok[1] * _pf(sai))
            b = bpy.context.active_object
            b.name = nome
            b.rotation_euler.x = math.radians(90.0)
            b.data.materials.append(mat)
            tronco_l.append(b)
    for sx in (-1.0, 1.0):
        # A GOLA MAIS MARCADA (o Bruno, na v3): mais saliente e mais grossa, a
        # borda dela faz a sombra que a desenha. O PÉ DE GOLA à volta do
        # pescoço (a v4) lia como um «colar azul», e saiu.
        tronco_l.append(_retalho("gola_%+d" % sx, [tronco],
                                 ((18.0 * sx, 106.0), (50.0 * sx, 98.0),
                                  (44.0 * sx, 70.0), (24.0 * sx, 80.0)),
                                 camisa, afasta=4.0, espessura=3.5, espelhado=sx < 0))
        # O BOLSO É SÓ A PALA, da cor da camisa, saliente — a sombra dela é o
        # desenho (o Bruno, na v1: os bolsos navy eram dois retângulos soltos).
        # A pala do bolso da v4 não se lia (o Bruno): mais saliente, e com o
        # botão de latão ao meio, que rima com os da carcela.
        tronco_l.append(_retalho("bolso_pala_%+d" % sx, [tronco],
                                 ((40.0 * sx, 50.0), (78.0 * sx, 50.0),
                                  (76.0 * sx, 36.0), (42.0 * sx, 33.0)),
                                 camisa, afasta=3.6, espessura=3.6, espelhado=sx < 0))
        ok = _raio([tronco], Vector((sx * _lg(59.0), -10.0, _niv(39.0))), Vector((0, 1, 0)))
        assert ok, "o botão do bolso não achou a camisa"
        bpy.ops.mesh.primitive_cylinder_add(vertices=10, radius=_lg(3.5), depth=_pf(1.6),
                                            location=ok[0] + ok[1] * _pf(4.4))
        bb = bpy.context.active_object
        bb.name = "bolso_botao_%+d" % sx
        bb.rotation_euler.x = math.radians(90.0)
        bb.data.materials.append(faixa)
        tronco_l.append(bb)
    # AS DRAGONAS, FINAS E AO COMPRIDO DO OMBRO (o Bruno, na v1: os blocos na
    # ponta liam soltos): pousadas por raios de CIMA, do colarinho à ponta do
    # ombro, com duas riscas douradas na ponta.
    for sx in (-1.0, 1.0):
        tronco_l.append(_retalho_cima("dragona_%+d" % sx, [tronco],
                                      ((40.0 * sx, -12.0), (112.0 * sx, -12.0),
                                       (112.0 * sx, 12.0), (40.0 * sx, 12.0)),
                                      navy, afasta=1.5, espessura=3.0))
        # As riscas: três de 4 liam como PONTOS (o Bruno, na v2), e duas de 8
        # ainda só se viam nos cantos (na v4) — a dragona tapava-as. Duas de
        # 11, bem acima dela e a passar-lhe as bordas, de lado a lado.
        for k, u in enumerate((80.0, 97.0)):
            tronco_l.append(_retalho_cima("dragona_risca_%+d_%d" % (sx, k), [tronco],
                                          ((u * sx, -15.0), ((u + 11.0) * sx, -15.0),
                                           ((u + 11.0) * sx, 15.0), (u * sx, 15.0)),
                                          faixa, afasta=4.0, espessura=1.5, n=2))
    return tronco_l, cab


# ────────────────────────────────────────────────────────────── o trabalhador
# LARGO E BAIXO, com o maxilar quase da largura das maçãs (plano de arte P2: o
# quadrado lê sólido, e ele é quem carrega o porto). A cabeça é mais baixa do
# que as dos três que falam — 128 contra 144 a 150 — porque o topo dela é do
# CAPACETE, e é o capacete que o identifica.
TRABALHADOR = Rosto(larg=162.0, fundo=80.0, z=(134.0, 262.0), maxilar=188.0, corte=18.0,
                    z_olho=204.0, z_boca=160.0, pivo=114.0, u_olho=32.0,
                    olho=(40.0, 25.0), iris=(21.0, 22.0), pupila=(11.0, 12.0),
                    u_sobr=(23.0, 42.0), sobr=(22.0, 7.0, 6.0),
                    brilho=6.5, boca_k=1.35, boca_alt=3.5, labio_k=0.45)


def trabalhador(M, cara):
    """O busto do trabalhador do rodapé, de FRENTE: (tronco, cabeça).

    ⚠️ ELE ERA DE CORPO INTEIRO, E PASSOU A BUSTO POR ESCOLHA DO BRUNO (24/09).
    O corpo inteiro identificava a unidade pelo capacete e pelo colete, que são
    silhueta; o busto guarda os dois — o capacete é o topo da cabeça e o colete
    é o peito — e dá à cara o tamanho dos três que falam.

    O QUE O IDENTIFICA, e é o que o boneco de caixas já tinha decidido: o
    CAPACETE amarelo e REDONDO (em caixa lia como laje), com a aba ACIMA das
    sobrancelhas; e o COLETE laranja VESTIDO — a camisa aparece por cima e dos
    lados, senão é uma caixa laranja pousada à frente dele —, com UMA faixa
    refletiva (duas taparam o laranja inteiro no primeiro boneco).
    """
    r = TRABALHADOR
    pele = M["pele"]
    sombra = M["pele_escura"]
    escuro = M["vao"]
    cabelo = _principled("cabelo_trabalhador", base.PALETA["madeira_esc"], rough=0.6, spec=0.2)
    # A sobrancelha no escuro da boca, como a do Arlindo: debaixo de uma aba a
    # testa fica na meia-sombra, e o castanho não se separava dela.
    sobrancelha = _principled("sobrancelha_trabalhador", base.PALETA["vao"], rough=0.9)
    # A CAMISA É `calca`, a ganga: o `azul` do boneco antigo é a camisa do
    # Arlindo, e o azul-escuro separa-se mais do laranja do colete.
    camisa = _principled("camisa_trabalhador", base.PALETA["calca"], rough=0.9)
    colete = _principled("colete_trabalhador", base.PALETA["colete"], rough=0.85)
    # ⚠️ A 0,5 / 0,3 o topo das faixas verticais, onde dobram sobre o ombro
    # de frente para a luz principal, estourava (33 px a 255 na v4).
    refletivo = _principled("refletivo_trabalhador", base.PALETA["refletivo"], rough=0.7,
                            spec=0.15)
    # O capacete é PLÁSTICO: menos rugoso do que o pano, e o brilho curto é
    # o que o separa de um gorro amarelo. ⚠️ A 0,35 / 0,6 o brilho ESTOURAVA:
    # 2.119 pixels com o vermelho a 255 no topo do casco (0,77% do desenho),
    # que no cartão é uma mancha branca.
    casco = _principled("capacete_trabalhador", base.PALETA["capacete"], rough=0.5, spec=0.35)
    labio = _principled("labio_trabalhador", base.PALETA["pele_escura"], rough=0.8)
    cab, tronco_l = [], []

    # A CABEÇA: o crânio (todo debaixo do capacete) e o maxilar LARGO, que
    # fecha num queixo de 132 — o da Dona Cida é 126 e o do Arlindo 104.
    # ⚠️ O CRÂNIO ESTREITA E ARREDONDA ACIMA DOS 240, onde o capacete o tapa:
    # uma elipse justa não cobre as quinas de uma cabeça quase quadrada, e com
    # o casco da v3 elas furavam a ABA — quatro estrelas cor de pele na borda.
    cab.append(_loft("cabeca_cranio", [
        (266.0, 120.0, 60.0, 24.0, 2.0),
        (252.0, 146.0, 74.0, 26.0),
        (240.0, r.larg - 2.0, r.fundo, r.corte),
        (r.maxilar, r.larg, r.fundo, r.corte),
    ], pele))
    cab.append(_loft("cabeca_maxilar", [
        (r.maxilar, r.larg, r.fundo, r.corte),
        (170.0, 160.0, 78.0, 20.0),
        (150.0, 150.0, 74.0, 18.0),
        (r.z[0], 132.0, 64.0, 16.0),
    ], pele, fechar=(False, True)))
    for sx in (-1.0, 1.0):
        o = prisma("orelha_%+d" % sx, _contorno_oitavado(16.0, 28.0, 5.0),
                   _niv(186.0), _niv(220.0), (1.0, 1.0), pele)
        o.location.x += sx * _lg(r.larg / 2.0 + 2.0)
        o.location.y += _pf(4.0)
        cab.append(o)

    cab += _olhos(r, M, cara, pele, escuro)
    cab += _sobrancelhas(r, cara, sobrancelha)
    nariz = _cunha(r, "nariz", 196.0, 176.0, 9.0, 19.0, 2.0, 8.0, pele)
    nariz.visible_shadow = False
    cab.append(nariz)
    cab.append(_placa(r, "nariz_base", 0.0, 173.5, 20.0, 3.0, sombra))
    cab += _boca(r, M, cara, escuro, labio)

    # O CABELO é só o que o capacete deixa ver: uma faixa CURTA por baixo da
    # aba, das têmporas à nuca, e as patilhas à frente da orelha. ⚠️ Só com as
    # patilhas (a v1) ele «parecia careca» (o Bruno): duas placas escuras
    # soltas ao lado das orelhas não fazem cabelo. A faixa é um anel à volta da
    # cabeça sem a FACE da frente, que é a testa. ⚠️ Sem os VÉRTICES da frente
    # (a primeira prévia da v2) iam também as facetas das quinas, e são elas
    # as têmporas que esta câmera vê de frente: o cabelo sumia outra vez.
    # ⚠️ E NA COR DO CABELO DA DONA CIDA ELE LIA COMO SOMBRA DA PELE: o
    # `madeira_esc` tem quase o valor da `pele` na meia-sombra das têmporas, e
    # 2,5 px fora da cabeça a faixa não tinha borda que a separasse (prévia de
    # depuração, sem o capacete). Vai no degrau de baixo, `cabelo_fundo`, 4 px
    # fora, e com uma FRANJA de 10 px à frente, logo abaixo da aba — é aí que
    # o olho procura cabelo debaixo de um capacete.
    cabelo_curto = _principled("cabelo_curto_trabalhador", base.PALETA["cabelo_fundo"],
                               rough=0.8, spec=0.1)
    # A faixa segue o crânio que estreita (ver acima), 4 px fora dele.
    faixa_cab = _loft("cabelo_faixa", [
        (259.0, 142.0, 74.0, 28.0),
        (249.0, 156.0, 84.0, 26.0),
        (236.0, r.larg + 8.0, r.fundo + 8.0, r.corte + 3.0),
    ], cabelo_curto, contorno=_contorno_12, fechar=(False, False))
    bm = bmesh.new()
    bm.from_mesh(faixa_cab.data)
    # A frente de cada anel está a um fundo diferente: a face da testa é a
    # que tem os QUATRO vértices na frente do anel dela.
    frente = min(vv.co.y for vv in bm.verts) + _pf(5.0)
    franja = _niv(249.0) - 1e-4
    bmesh.ops.delete(bm, geom=[f for f in bm.faces
                               if all(vv.co.y < frente for vv in f.verts)
                               and min(vv.co.z for vv in f.verts) < franja],
                     context="FACES_ONLY")
    bm.to_mesh(faixa_cab.data)
    bm.free()
    faixa_cab.modifiers.new("espessura", "SOLIDIFY").thickness = _pf(3.0)
    cab.append(faixa_cab)
    for sx in (-1.0, 1.0):
        cab.append(_patilha(r, "cabelo_patilha_%+d" % sx, sx, cabelo_curto, z_topo=258.0,
                            z_bico=222.0, fundo_px=22.0, esp=4.0))

    # O CAPACETE: casco em cúpula e a aba de UMA peça. As voltas:
    # - v1: cúpula até aos 320, 16 lados, crista ao meio e uma pala à parte —
    #   «grande/alto» e «amassado» (o Bruno): a 42 px as facetas faziam
    #   manchas de luz, e as pontas da pala saíam como DENTES dos lados da aba
    #   (a queixa da pala do Arlindo na v3);
    # - v2: cúpula baixa (306) e lisa — 24 lados, seis anéis, sem crista — e a
    #   aba é uma elipse DESCENTRADA para a frente: a pala é a própria aba, e
    #   não há costura que faça ponta. «Ainda grande», e pediu-o «com mais
    #   detalhes e mais realista» (o Bruno);
    # - v3: o casco JUSTO à cabeça (168 × 90 na borda, 300 de topo) e os
    #   detalhes de um capacete de obra — três NERVURAS em cima (a do meio e
    #   duas laterais) e o FRISO de borda à volta, tudo no mesmo amarelo: a
    #   crista da v1 lia como amassado porque a cúpula tinha 16 lados, e não
    #   por ser crista.
    # ⚠️ A ABA NÃO PROJETA SOMBRA: com ela, a chave apagava as sobrancelhas,
    # como a pala do boné.
    # - v4: o capacete de obra de verdade (o Bruno: «mais realista sem perder
    #   a coerência»): a PALA curta à frente, nascida da aba; a aba ESTREITA
    #   à volta (a de 182 × 116 lia como aba de chapéu); as nervuras mais
    #   altas e largas; e o ADESIVO na frente, peça e material à parte — no
    #   futuro, o emblema que o jogador escolhe para a empresa.
    y_cap = 4.0
    capacete = []
    casco_o = _loft("capacete_casco", [
        (300.0, _anel_eliptico(56.0, 32.0, 24), y_cap + 3.0),
        (297.5, _anel_eliptico(98.0, 54.0, 24), y_cap + 2.5),
        (292.0, _anel_eliptico(132.0, 72.0, 24), y_cap + 2.0),
        (284.0, _anel_eliptico(154.0, 84.0, 24), y_cap + 1.5),
        (273.0, _anel_eliptico(165.0, 89.0, 24), y_cap + 1.0),
        (262.0, _anel_eliptico(168.0, 90.0, 24), y_cap),
    ], casco, fechar=(True, True))
    capacete.append(casco_o)
    capacete.append(_loft("capacete_friso", [(266.0, _anel_eliptico(175.0, 97.0, 24), y_cap),
                                             (261.0, _anel_eliptico(175.0, 97.0, 24), y_cap)],
                          casco, fechar=(False, False)))
    # A ABA SALIENTE DOS LADOS (v5): a de 178 × 100 com 3,5 de espessura
    # «sumia dos lados» (o Bruno) — 8 px fora do casco e 4,5 de espessura.
    borda = (184.0, 106.0, y_cap)
    aba = _loft("capacete_aba", [(261.0, _anel_eliptico(borda[0], borda[1], 24), y_cap),
                                 (256.5, _anel_eliptico(borda[0], borda[1], 24), y_cap)],
                casco, fechar=(True, True))
    aba.visible_shadow = False
    capacete.append(aba)
    # A PALA nasce da elipse da aba, com a MESMA espessura: nas pontas ela
    # afina a zero dentro da aba, e não sobra dente (a v1 ancorava a pala no
    # casco, mais pequeno do que a aba, e as pontas saíam dos lados).
    # ⚠️ CURTA E GROSSA: a de 20 de avanço a descer 4 «lembrava boné» (v4).
    pala = _pala("capacete_pala", casco, borda, z_px=256.5, avanca=12.0, desce=1.5,
                 esp=4.5, abre=0.58)
    pala.visible_shadow = False
    capacete.append(pala)
    bpy.context.view_layer.update()
    # As nervuras acabam ONDE A CÚPULA AINDA NÃO É PAREDE: levadas até aos
    # 40 de fundo, a ponta de cada uma dobrava num gancho sobre o friso.
    for nome, u0, u1, f, alt_n in (("capacete_nervura", -7.0, 7.0, 32.0, 5.0),
                                   ("capacete_nervura_-1", -35.0, -25.0, 26.0, 4.0),
                                   ("capacete_nervura_+1", 25.0, 35.0, 26.0, 4.0)):
        capacete.append(_retalho_cima(nome, [casco_o],
                                      ((u0, -f), (u1, -f), (u1, f), (u0, f)),
                                      casco, afasta=1.0, espessura=alt_n, n=6))
    # O ADESIVO: um decalque OVAL e chato na frente do casco, abaixo da
    # nervura, claro com uma faixa navy de lado a lado — o logotipo. Material
    # próprio de propósito: é o sítio do emblema da empresa do jogador, quando
    # ele existir. ⚠️ O quadrado claro com o miolo escuro da v4 lia como a
    # LANTERNA de um capacete de mineiro: a luz no meio é o que a faz lâmpada.
    adesivo = _principled("adesivo", base.PALETA["cabine"], rough=0.7)
    marca = _principled("adesivo_marca", base.PALETA["casco"], rough=0.8)
    capacete.append(_decalque("capacete_adesivo", [casco_o], 0.0, 280.0, 15.0, 7.5,
                              adesivo, afasta=0.6, espessura=0.6))
    capacete.append(_retalho("capacete_adesivo_marca", [casco_o],
                             ((-11.0, 281.5), (11.0, 281.5), (11.0, 278.5), (-11.0, 278.5)),
                             marca, afasta=1.0, espessura=0.4))
    cab += capacete

    # O PESCOÇO E O TRONCO: ombros largos e direitos, de quem carrega.
    # ⚠️ O ANEL DE CIMA CABE DENTRO DO PESCOÇO — 52 × 46 num pescoço de
    # 58 × 50 —, senão fecha à volta dele num aro da cor da camisa (o «colar
    # azul» do Arlindo, v5).
    tronco_l.append(prisma("pescoco", _contorno_oitavado(58.0, 50.0, 12.0),
                           _niv(80.0), _niv(142.0), (1.0, 1.0), pele))
    tronco = _loft("tronco", [
        (98.0, 52.0, 46.0, 12.0),
        (92.0, 136.0, 64.0, 22.0),
        (84.0, 214.0, 76.0, 30.0),
        (72.0, 256.0, 82.0, 36.0),
        (54.0, 268.0, 84.0, 38.0),
        (20.0, 262.0, 82.0, 36.0),
        (-40.0, 250.0, 80.0, 34.0),
        (-90.0, 246.0, 78.0, 32.0),
    ], camisa, contorno=_contorno_12)
    tronco_l.append(tronco)
    bpy.context.view_layer.update()

    # O COLETE, NUMA PEÇA SÓ, e as faixas COSTURADAS nele. As voltas:
    # - v1: dois painéis em V largo, com a gola da camisa por cima;
    # - v2: o V fechado e a faixa maior, sem a gola;
    # - v3: zíper, faixa horizontal inteira e faixas verticais — e o ombro
    #   partido: a alça e o painel não se tocavam;
    # - v4: a alça a descer até por cima do painel, bolsos e caneta — e «parece
    #   que vários pedaços foram colados um no outro» (o Bruno): painel, alça,
    #   faixas e bolsos eram placas empilhadas, cada uma com a sua borda.
    # - v5: o colete é UM retalho que ENVOLVE o tronco, das costas por cima do
    #   ombro até à frente (`_envolver`), e as faixas pousam a 0,8 dele, quase
    #   rentes, como fita costurada. O contorno é o de antes: o V no pescoço,
    #   o zíper abaixo dele, e a cava larga que deixa a camisa nos braços.
    # ⚠️ Quem cobre o ombro é o próprio colete: a v3 mostrou que duas peças
    # encostadas deixam camisa no meio, e a v4 que sobrepostas leem coladas.
    zona_v = 72.0

    def contorno_colete(z):
        if z >= 94.0:
            dentro = 30.0
        elif z >= zona_v:
            dentro = 2.0 + (z - zona_v) / (94.0 - zona_v) * 28.0
        else:
            dentro = 2.0
        fora = 68.0 if z >= 88.0 else 68.0 + (88.0 - z) * 30.0 / 178.0
        return dentro, fora

    faixa_v = lambda z: (34.0, 48.0)                    # noqa: E731
    for sx in (-1.0, 1.0):
        tronco_l.append(_envolver("colete_%+d" % sx, [tronco], contorno_colete, colete,
                                  afasta=2.0, espessura=2.5, lado=sx))
        # A faixa VERTICAL, costurada no colete: das costas, por cima do
        # ombro, até à horizontal — uma fita só, sem emenda no ombro.
        tronco_l.append(_envolver("colete_faixa_v_%+d" % sx, [tronco], faixa_v, refletivo,
                                  afasta=2.8, espessura=0.8, lado=sx, colunas=3, ate_z=33.0))
        # A faixa HORIZONTAL, inteira de lado a lado, baixa no peito.
        tronco_l.append(_retalho("colete_faixa_%+d" % sx, [tronco],
                                 ((0.0, 34.0), (74.0 * sx, 34.0),
                                  (76.0 * sx, 14.0), (0.0, 14.0)),
                                 refletivo, afasta=2.8, espessura=0.8, espelhado=sx < 0))
        # OS BOLSOS SAÍRAM (v6, o Bruno): na v4 estavam no colarinho e não se
        # viam, e na v5, já no peito e com a pestana num laranja mais fundo,
        # foram tirados. O colete lê pelas faixas, e é isso que o identifica.
    # O ZÍPER, do fundo do V para baixo, quase da cor do colete e rente a ele:
    # a faixa horizontal passa-lhe por cima. ⚠️ No `laranja_esc` (v3) era uma
    # linha escura que partia o colete ao meio.
    tronco_l.append(_retalho("colete_ziper", [tronco],
                             ((-2.0, zona_v), (2.0, zona_v), (2.0, -90.0), (-2.0, -90.0)),
                             _principled("ziper_trabalhador", base.PALETA["laranja"],
                                         rough=0.8), afasta=2.3, espessura=0.6))
    # A CANETA SAIU (v5): a 70 px ela era uma mancha azul junto ao V, que o
    # Bruno leu como mancha.

    # ⚠️ O TRONCO SOBE 10 (v5), com tudo o que pousa nele: o pescoço encurta
    # e o peito entra no quadro. É uma translação do grupo, feita no fim, para
    # que cada peça continue pousada onde os raios a puseram.
    for o in tronco_l:
        o.location.z += _alt(10.0)
    return tronco_l, cab


# QUEM ESTÁ NESTE KIT, e a cabeça de cada um: o `retratos_de_fala` de
# `brp_porto.py` tira daqui o construtor e o pivô da pose.
KIT = {"cida": (CIDA, cida), "ribeiro": (RIBEIRO, ribeiro), "arlindo": (ARLINDO, arlindo)}


def pousar_cabeca(pecas, pose, pivo_px):
    """Roll, pitch e yaw da cabeça, sobre o MEIO do pescoço (como no kit).

    ⚠️ CORRE DEPOIS DO `enquadrar`, e é na `matrix_basis` (o espaço do busto,
    debaixo do pivô). Posta antes, a cabeça inclinada entrava na medida do
    enquadramento, e o busto inteiro mudava de sítio de uma expressão para a
    outra: medido, a preocupada saía 12 px à direita e a contente 22 à
    esquerda. No kit de hoje o tronco fica quieto e só a cabeça roda.
    """
    roll, pitch, yaw = pose
    if roll == 0.0 and pitch == 0.0 and yaw == 0.0:
        return
    pivo = Vector((0.0, 0.0, _niv(pivo_px)))
    giro = Euler((math.radians(pitch), math.radians(roll),
                  math.radians(yaw)), "XYZ").to_matrix().to_4x4()
    mover = Matrix.Translation(pivo) @ giro @ Matrix.Translation(-pivo)
    for o in pecas:
        o.matrix_basis = mover @ o.matrix_basis


# ────────────────────────────────────────────────────────────── enquadrar
def _pixels(cena, objs):
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


def enquadrar(cena, nome, pecas, medir, cabeca=CABECA_NO_QUADRO):
    """Gira o grupo para a câmera e põe-no no quadro, MEDINDO a projeção.

    `medir` são as peças da cabeça com o cabelo e o coque: é a altura delas que
    vale 60% do quadro. ⚠️ Mexer na altura da cabeça mexe no tamanho de TUDO o
    resto — encurtá-la 12 ampliou o busto 11% (a `quadrada_v2`).

    `cabeca` é essa fração: 60% para os três que falam, e menos para o
    trabalhador, que se identifica pelo COLETE e precisa de mais peito à vista
    (a faixa de baixo saía cortada pelo quadro, v4).

    ⚠️ E CADA PERSONAGEM É MEDIDO PELA SUA cabeça, não à escala da Dona Cida.
    A primeira prova do Sr. Ribeiro usou a escala dela (os 60% dela incluem o
    coque, e a dele saía 8,5% menor), e o Bruno pediu-o MAIS PERTO: «cara
    pequena na caixa» (24/09).
    """
    piv = bpy.data.objects.new("pivo_%s" % nome, None)
    bpy.context.scene.collection.objects.link(piv)
    for o in pecas:
        o.parent = piv
    piv.rotation_euler.z = math.radians(45.0)
    bpy.context.view_layer.update()
    x0, y0, x1, y1 = _pixels(cena, medir)
    k = (cabeca * cena.render.resolution_y) / (y1 - y0)
    piv.scale = (k, k, k)
    bpy.context.view_layer.update()
    ref = _pixels(cena, medir)
    piv.location.z += 1.0
    bpy.context.view_layer.update()
    px_z = ref[1] - _pixels(cena, medir)[1]
    piv.location.z -= 1.0
    piv.location.x += 1.0
    bpy.context.view_layer.update()
    novo = _pixels(cena, medir)
    px_x = (novo[0] - ref[0], novo[1] - ref[1])
    piv.location.x -= 1.0
    f = cena.render.resolution_x / 768.0
    ax = (CENTRO_X_PX * f - (ref[0] + ref[2]) / 2.0) / px_x[0]
    dz = (ref[1] + px_x[1] * ax - TOPO_PX * f) / px_z
    piv.location.x += ax
    piv.location.z += dz
    bpy.context.view_layer.update()
    return k
