"""Dona Cida, expressão SÉRIA — candidata QUADRADA v2: o kit de caixas, ajustado.

    python3.11 art_lab/retratos/cida_seria/quadrada_v2/gerar_retrato_cida_quadrada_v2.py <pasta>
    PREVIA=1 python3.11 ...   # 384 px e 16 amostras, para iterar a forma

Grava `<pasta>/retrato_cida_seria.png` (768×768, alfa verdadeiro). É uma
CANDIDATA: não escreve em `brport_vs/` e não toca no manifest.

DE ONDE VEM. Entre a redonda v2 e a quadrada v1, o Bruno escolheu (24/09) a
QUADRADA para melhorar, e pediu ajustes antes de ela ir para o jogo — nos
quatro pontos que a leitura da v1 apontava:

- CABELO — as mechas da frente lembravam uma franja, e o coque de dois
  andares um bolo. As mechas convergem com força para o coque (o leque diz
  «puxado para trás»), as têmporas ganham cabelo e a linha do cabelo passa a
  ARCO à volta da cara, e o coque é uma bola facetada só, atrás;
- ÓCULOS — a armação quadrada de 4 px pesava e tapava o olho. Passa a
  OITAVADA (quase redonda, ainda em caixas) e fina, de 2,5 px;
- TRONCO — planos grandes e lisos, com ar de armadura. A secção passa de 8 a
  12 lados e o ombro ganha anéis (cai redondo em vez de em placa), e a blusa
  ganha desenho: a CARCELA dos botões e um BOLSO com pestana;
- ROSTO — olhos pequenos e meio fechados, e um palmo de cara vazia entre a
  boca e o queixo. A cabeça baixa (o queixo sobe 12), as feições descem para o
  meio da cara, o olho cresce até ao limite da parte plana e abre (a pálpebra
  só apara o alto), e o queixo ganha volume.

Tudo o que não é forma continua partilhado com a v2 redonda (o estúdio, o
enquadramento, os materiais sem ruído, o brilho no olho, o AgX), e o que não
está nesta lista continua o da quadrada v1.
"""

from __future__ import annotations

import math
import os
import pathlib
import sys

_AQUI = pathlib.Path(__file__).resolve().parent
_RAIZ = _AQUI.parents[3]
sys.path.insert(0, str(_RAIZ / "blender"))
sys.path.insert(0, str(_RAIZ / "tools"))
sys.path.insert(0, str(_AQUI.parent / "v2"))

import bpy                                            # noqa: E402
import bmesh                                          # noqa: E402
from mathutils import Vector                          # noqa: E402

import gerar_props_iso as base                        # noqa: E402
from brp_studio import Estudio, na_face, prisma       # noqa: E402
from brp_porto import _contorno_oitavado, _lg, _pf, _alt, _niv  # noqa: E402
from gerar_retrato_cida_v2 import emissao, enquadrar, principled, raio  # noqa: E402

NOME = "retrato_cida_seria"

# ── AS MEDIDAS, em PIXELS DE DESENHO como no kit ───────────────────────────
# ⚠️ A CABEÇA BAIXA: 144 × 158 (a v1 tinha 156 × 158). Na v1 sobrava um palmo
# de cara vazia entre a boca e o queixo; subir o queixo encurta-o sem mexer na
# testa, e deixa a forma dela ainda mais LARGA.
_CAB_LARG, _CAB_FUNDO = 158.0, 76.0
_CAB_Z = (140.0, 284.0)
_MAXILAR = 196.0
_CAB_CENTRO = (_CAB_Z[0] + _CAB_Z[1]) / 2.0     # 212
# O corte das quinas da cara desce de 24/22 para 20: a parte plana da face
# passa a ±59, e é ela o limite do olho e dos óculos.
_CORTE_CARA = 20.0
# O tronco sobe com o queixo, menos do que ele: o pescoço à vista fica o de
# antes.
_DZ = 8.0


def _plano_cabeca():
    centro = (0.0, 0.0, _niv(_CAB_CENTRO))
    tam = (_lg(_CAB_LARG), _pf(_CAB_FUNDO), _alt(_CAB_Z[1] - _CAB_Z[0]))
    return centro, tam


def placa(nome, u, z_px, larg, alt_px, mat, fora=0.0, esp=0.02):
    """Uma placa na cara, em `u` a partir do meio e à altura ABSOLUTA `z_px`."""
    centro, tam = _plano_cabeca()
    return na_face(nome, "-y", centro, tam, _lg(u), _alt(z_px - _CAB_CENTRO),
                   _lg(larg), _alt(alt_px), esp, mat, fora)


def _contorno_12(larg, fundo, corte):
    """O octógono do kit com cada quina partida em DUAS facetas.

    ⚠️ No tronco da quadrada v1 as quinas de 45° eram planos grandes, e o ombro
    lia como uma ombreira de armadura. Com o ponto do arco a meio de cada
    quina a secção fica com 12 lados — ainda facetada, já não em placas.
    """
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


def loft(nome, aneis, mat, contorno=_contorno_oitavado, fechar=(True, False)):
    """Uma malha FACETADA por anéis, de cima para baixo (o `prisma` com andares).

    Cada anel é (z, largura, fundo, corte[, recuo]) para o `contorno`, ou
    (z, pontos[, recuo]) com os pontos já no mundo. `fechar` diz se o anel de
    cima e o de baixo levam tampa.
    """
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


def _objeto(nome, bm, mat):
    me = bpy.data.meshes.new(nome)
    bm.to_mesh(me)
    bm.free()
    o = bpy.data.objects.new(nome, me)
    bpy.context.scene.collection.objects.link(o)
    o.data.materials.append(mat)
    return o


def bastao(nome, a, b, raio_w, lados, mat):
    """Um prisma de `lados` faces entre dois pontos do mundo."""
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


def mecha(nome, perfil, escalas, x0, x1, esps, mat):
    """Uma faixa CONTÍNUA de cabelo ao longo de um perfil do plano YZ.

    A da quadrada v1 (lá está porque não são ripas soltas), com a espessura
    POR PONTO: ⚠️ com 3 px de ponta a ponta, a ponta de cada mecha acabava na
    linha do cabelo numa aresta que se acendia, e as cinco em fila liam como
    a borda de uma franja. Afinada até quase zero, a mecha NASCE da calote.
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


def aro_oitavado(nome, u, z_px, larg, alt, corte, barra, fora, mat):
    """Um aro de óculos OITAVADO na face da frente: o vão e a armação à volta.

    ⚠️ A quadrada v1 tinha quatro barras de 4 px à volta de um vão reto, e o
    Bruno achou-os pesados; a esta escala o oitavado é o redondo das caixas.
    """
    def octo(hl, ha, c):
        return [(-hl + c, -ha), (hl - c, -ha), (hl, -ha + c), (hl, ha - c),
                (hl - c, ha), (-hl + c, ha), (-hl, ha - c), (-hl, -ha + c)]
    dentro = octo(larg / 2.0, alt / 2.0, corte)
    fora_c = octo(larg / 2.0 + barra, alt / 2.0 + barra, corte + barra * 0.41)
    y_face = -_pf(_CAB_FUNDO / 2.0)
    esp = 0.02
    bm = bmesh.new()
    camadas = []
    for y in (y_face - fora - esp, y_face - fora):
        camadas.append(([bm.verts.new((_lg(u + a), y, _niv(z_px + b))) for a, b in fora_c],
                        [bm.verts.new((_lg(u + a), y, _niv(z_px + b))) for a, b in dentro]))
    (fo_f, de_f), (fo_t, de_t) = camadas
    for i in range(8):
        j = (i + 1) % 8
        bm.faces.new((fo_f[i], fo_f[j], de_f[j], de_f[i]))     # frente
        bm.faces.new((fo_t[j], fo_t[i], de_t[i], de_t[j]))     # trás
        bm.faces.new((fo_f[j], fo_f[i], fo_t[i], fo_t[j]))     # borda de fora
        bm.faces.new((de_f[i], de_f[j], de_t[j], de_t[i]))     # borda de dentro
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    return _objeto(nome, bm, mat)


def montar_cida(M):
    pele = M["pele_escura"]
    sombra = M["pele_sombra"]
    escuro = M["vao"]
    cabelo = principled("cabelo_cida", base.PALETA["madeira_esc"], rough=0.55, spec=0.25)
    blusa = principled("blusa_cida", base.PALETA["casco_pesca"], rough=0.9)
    gola = principled("gola_cida", base.PALETA["cabine"], rough=0.9)
    pecas = []

    # ── A CABEÇA ──────────────────────────────────────────────────────────
    pecas.append(prisma("cabeca_maxilar",
                        _contorno_oitavado(_CAB_LARG, _CAB_FUNDO, _CORTE_CARA),
                        _niv(_CAB_Z[0]), _niv(_MAXILAR), (0.80, 1.0), pele))
    # O crânio em cúpula facetada POR DENTRO da calote (a lição da quadrada
    # v1: de tampo chato, a quina dele furava o cabelo numa pala de pele).
    pecas.append(loft("cabeca_cranio", [
        (292.0, 96.0, 40.0, 12.0, 9.0),
        (280.0, 128.0, 56.0, 18.0, 6.0),
        (262.0, 149.0, _CAB_FUNDO, _CORTE_CARA),
        (_MAXILAR, _CAB_LARG, _CAB_FUNDO, _CORTE_CARA),
    ], pele))
    # O QUEIXO GANHA VOLUME: uma caixa baixa e larga, como o nariz, sem
    # sombra. É o que desenha o fundo da cara — a luz apanha-lhe o topo e a
    # base fica no escuro — sem uma placa que se lesse como segunda boca.
    queixo = placa("queixo", 0.0, 150.0, 34.0, 12.0, pele, esp=_pf(4.0))
    queixo.visible_shadow = False
    pecas.append(queixo)
    for sx in (-1.0, 1.0):
        o = prisma("orelha_%+d" % sx, _contorno_oitavado(16.0, 28.0, 5.0),
                   _niv(220.0), _niv(254.0), (1.0, 1.0), pele)
        o.location.x += sx * _lg(_CAB_LARG / 2.0 + 2.0)
        o.location.y += _pf(6.0)
        pecas.append(o)

    # ── OS OLHOS, MAIORES E ABERTOS ───────────────────────────────────────
    # ⚠️ Na quadrada v1 o olho tinha 34 × 22 e a pálpebra tapava 6 px dele: na
    # caixa do telefone lia pequeno e meio fechado. Cresce até ao limite da
    # parte plana (±59, com o aro) e a pálpebra só apara o alto: séria é
    # atenta. Cada placa um passo à frente da de baixo (o losango do z-buffer).
    brilho = emissao("brilho_olho", 4.0)
    z_olho = 216.0
    for sx in (-1.0, 1.0):
        u = 31.0 * sx
        pecas.append(placa("olho_branco_%+d" % sx, u, z_olho, 38.0, 24.0, M["cabine"]))
        pecas.append(placa("olho_iris_%+d" % sx, u, z_olho - 1.0, 20.0, 22.0, M["porta"], fora=0.010))
        pecas.append(placa("olho_pupila_%+d" % sx, u, z_olho - 1.0, 10.0, 12.0, escuro, fora=0.020))
        pecas.append(placa("olho_brilho_%+d" % sx, u - 5.0, z_olho + 3.0, 5.0, 5.0, brilho, fora=0.030))
        pecas.append(placa("palpebra_%+d" % sx, u, z_olho + 10.5, 40.0, 3.5, pele, fora=0.034))
        pecas.append(placa("pestana_%+d" % sx, u, z_olho + 8.0, 40.0, 2.5, escuro, fora=0.038))
        pecas.append(aro_oitavado("oculos_%+d" % sx, u, z_olho, 46.0, 32.0, 9.0, 2.5,
                                  0.046, M["metal"]))
    pecas.append(placa("oculos_ponte", 0.0, z_olho + 5.0, 14.0, 3.0, M["metal"], fora=0.052))
    for sx in (-1.0, 1.0):
        pecas.append(bastao("oculos_haste_%+d" % sx,
                            (sx * _lg(56.0), -_pf(_CAB_FUNDO / 2.0 + 1.5), _niv(z_olho + 6.0)),
                            (sx * _lg(_CAB_LARG / 2.0 + 1.0), _pf(4.0), _niv(z_olho + 4.0)),
                            _lg(1.4), 4, M["metal"]))
    for o in pecas:
        if o.name.startswith("oculos"):
            o.visible_shadow = False

    # ── SOBRANCELHAS, NARIZ E BOCA — mais ao meio da cara ─────────────────
    for sx in (-1.0, 1.0):
        pecas.append(placa("sobrancelha_%+d" % sx, 31.0 * sx, 240.0, 34.0, 7.0, escuro))
    nariz = placa("nariz", 0.0, 196.0, 22.0, 18.0, pele, esp=_pf(9.0))
    nariz.visible_shadow = False
    pecas.append(nariz)
    pecas.append(placa("nariz_base", 0.0, 185.0, 26.0, 4.0, sombra))
    pecas.append(placa("boca", 0.0, 170.0, 40.0, 5.0, escuro))
    pecas.append(placa("labio", 0.0, 164.0, 26.0, 5.0, sombra))

    # ── O CABELO ──────────────────────────────────────────────────────────
    linha = 262.0

    def cranio(z_px):
        f = (z_px - _MAXILAR) / (_CAB_Z[1] - _MAXILAR)
        return _CAB_LARG - 12.0 * max(0.0, min(1.0, f))
    calote = loft("cabelo_calote", [
        (298.0, 118.0, 48.0, 14.0, 10.0),
        (290.0, cranio(284.0) + 2.0, 60.0, 14.0, 8.0),
        (linha, cranio(linha) + 3.0, 78.0, 12.0, 0.5),
        (212.0, 164.0, 80.0, 26.0),
    ], cabelo)
    bm = bmesh.new()
    bm.from_mesh(calote.data)
    bmesh.ops.delete(bm, geom=[vv for vv in bm.verts
                               if vv.co.z < _niv(linha) - 1e-4 and vv.co.y < _pf(4.0)],
                     context="VERTS")
    bm.to_mesh(calote.data)
    bm.free()
    pecas.append(calote)
    nuca = prisma("cabelo_nuca", _contorno_oitavado(166.0, 40.0, 14.0),
                  _niv(212.0), _niv(linha + 2.0), (1.0, 1.0), cabelo)
    nuca.location.y += _pf(22.0)
    pecas.append(nuca)
    # AS TÊMPORAS: o cabelo desce pelas quinas da cara até à orelha, e a linha
    # do cabelo passa de uma reta a um ARCO à volta da cara. ⚠️ Na quadrada v1
    # a calote acabava a direito nas quinas, e a reta sobre a testa — com as
    # mechas por cima — era o que se lia como franja. Cada têmpora cobre a
    # faceta de 45° da cara, mais baixa do lado da orelha.
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
        pecas.append(_objeto("cabelo_tempora_%+d" % sx, bm, cabelo))
    # AS MECHAS, cinco, com o LEQUE mais fechado do que na v1: a escala da
    # ponta de trás passa de 0,52 a 0,30, e as faixas apontam para o coque —
    # é a convergência que diz «puxado para trás», e não a faixa em si.
    perfil = [(-_pf(38.5), _niv(linha + 0.5)),
              (-_pf(22.0), _niv(290.0)), (-_pf(14.0), _niv(298.0)),
              (_pf(20.0), _niv(298.0))]
    escalas = (1.0, 0.78, 0.58, 0.30)
    for i, (u0, u1) in enumerate(((-60.0, -38.0), (-34.0, -12.0), (-9.0, 9.0),
                                  (12.0, 34.0), (38.0, 60.0))):
        pecas.append(mecha("cabelo_mecha_%d" % i, perfil, escalas, _lg(u0), _lg(u1),
                           (_pf(0.4), _pf(3.0), _pf(3.0), _pf(3.0)), cabelo))
    # O COQUE: UMA bola facetada atrás e acima, com a liga à vista por baixo.
    # ⚠️ O de dois andares da v1 lia como um BOLO em cima da cabeça.
    y_coque = 26.0
    pecas.append(loft("coque_liga", [(299.0, _anel_redondo(24.0, 12), y_coque),
                                     (293.0, _anel_redondo(24.0, 12), y_coque)],
                      M["colete"], fechar=(True, True)))
    pecas.append(loft("coque", [
        (330.0, _anel_redondo(11.0), y_coque),
        (323.0, _anel_redondo(24.0), y_coque),
        (312.0, _anel_redondo(31.0), y_coque),
        (300.0, _anel_redondo(29.0), y_coque),
        (292.0, _anel_redondo(19.0), y_coque),
    ], cabelo, fechar=(True, True)))

    # ── O LÁPIS, POR CIMA DA ORELHA DIREITA (da imagem), como na v1 ───────
    r_l = _lg(4.5)
    a = Vector((_lg(85.0), _pf(26.0), _niv(268.0)))
    b = Vector((_lg(89.0), -_pf(22.0), _niv(244.0)))
    pecas.append(bastao("lapis", a, b, r_l, 6, M["capacete"]))
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
        pecas.append(o)

    # ── O PESCOÇO E O TRONCO ──────────────────────────────────────────────
    pecas.append(prisma("pescoco", _contorno_oitavado(54.0, 46.0, 10.0),
                        _niv(84.0 + _DZ), _niv(152.0), (1.0, 1.0), pele))
    pecas.append(prisma("pescoco_sombra", _contorno_oitavado(55.0, 47.0, 10.0),
                        _niv(128.0), _niv(141.0), (1.0, 1.0), sombra))
    # ⚠️ Na quadrada v1 o ombro eram três anéis de octógono, e lia como uma
    # OMBREIRA: planos grandes com quinas vivas. Aqui são mais anéis a cair em
    # curva e secção de 12 lados.
    # ⚠️ E O TRONCO ESTREITA 10% contra o da v1: com a cabeça mais baixa, o
    # enquadramento (a cabeça com o coque a 60% do quadro) ampliou tudo 11%,
    # e a primeira prévia saiu com um busto CORCUNDA a comer o cartão.
    # ⚠️ E O OMBRO NÃO É UMA CURVA CONTÍNUA: com os anéis a alargar por igual
    # do pescoço ao braço, o busto saiu um SINO — o balão da redonda v1 com
    # facetas. Um ombro são três coisas: o trapézio inclinado, uma prateleira
    # quase plana no alto e a quina redonda do deltoide a cair no braço.
    tronco = loft("tronco", [
        (96.0 + _DZ, 65.0, 52.0, 15.0),         # o decote
        (90.0 + _DZ, 120.0, 60.0, 22.0),        # trapézio
        (82.0 + _DZ, 196.0, 68.0, 30.0),
        (77.0 + _DZ, 234.0, 74.0, 36.0),        # a prateleira do ombro
        (67.0 + _DZ, 258.0, 78.0, 40.0),        # a quina do deltoide
        (51.0 + _DZ, 268.0, 80.0, 42.0),
        (0.0 + _DZ, 270.0, 80.0, 42.0),         # o braço, a direito
        (-90.0, 270.0, 80.0, 42.0),
    ], blusa, contorno=_contorno_12)
    pecas.append(tronco)
    pecas.append(prisma("gola_pe", _contorno_oitavado(62.0, 54.0, 14.0),
                        _niv(94.0 + _DZ), _niv(106.0 + _DZ), (1.0, 1.0), gola))
    # A CARCELA: a tira dos botões, um nada saliente, da ponta da gola para
    # baixo. ⚠️ O peito da v1 era uma chapa lisa com três botões soltos nela.
    y_peito = -_pf(40.0)
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0.0, y_peito - _pf(0.6),
                                                        (_niv(62.0) + _niv(-60.0)) / 2.0))
    carcela = bpy.context.active_object
    carcela.name = "carcela"
    carcela.scale = (_lg(14.0), _pf(2.4), _niv(62.0) - _niv(-60.0))
    carcela.data.materials.append(blusa)
    pecas.append(carcela)
    # O BOLSO, no peito esquerdo dela (à direita da imagem), com a PESTANA.
    for nome, z_c, alt_b, larg_b, sai in (("bolso", 26.0, 28.0, 32.0, 0.8),
                                          ("bolso_pestana", 38.0, 7.0, 35.0, 1.8)):
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(_lg(58.0), y_peito - _pf(sai / 2.0),
                                                            _niv(z_c)))
        o = bpy.context.active_object
        o.name = nome
        o.scale = (_lg(larg_b), _pf(sai + 1.0), _alt(alt_b))
        o.data.materials.append(blusa)
        pecas.append(o)
    bpy.context.view_layer.update()
    for sx in (-1.0, 1.0):
        A = (4.0 * sx, 94.0 + _DZ)
        B = (28.0 * sx, 96.0 + _DZ)
        C = (58.0 * sx, 76.0 + _DZ)
        D = (18.0 * sx, 52.0 + _DZ)
        bm = bmesh.new()
        grade = []
        nu = nv = 4
        for j in range(nv + 1):
            fv = j / nv
            lin = []
            for i in range(nu + 1):
                fu = i / nu
                x = (A[0] * (1 - fu) * (1 - fv) + B[0] * fu * (1 - fv)
                     + C[0] * fu * fv + D[0] * (1 - fu) * fv)
                zz = (A[1] * (1 - fu) * (1 - fv) + B[1] * fu * (1 - fv)
                      + C[1] * fu * fv + D[1] * (1 - fu) * fv)
                ok = None
                for k in range(10):
                    ok = raio([tronco], Vector((_lg(x), -10.0, _niv(zz - 2.0 * k))),
                              Vector((0, 1, 0)))
                    if ok:
                        break
                assert ok, "a gola não achou o peito em %s" % ((x, zz),)
                lin.append(bm.verts.new(ok[0] + ok[1] * _pf(1.2)))
            grade.append(lin)
        for j in range(nv):
            for i in range(nu):
                f = (grade[j][i], grade[j][i + 1], grade[j + 1][i + 1], grade[j + 1][i])
                bm.faces.new(f if sx > 0 else tuple(reversed(f)))
        aba = _objeto("gola_%+d" % sx, bm, gola)
        aba.modifiers.new("espessura", "SOLIDIFY").thickness = _pf(2.0)
        pecas.append(aba)
    for k, zz in enumerate((48.0, 30.0, 12.0)):
        ok = raio([carcela], Vector((0.0, -10.0, _niv(zz))), Vector((0, 1, 0)))
        assert ok, "o botão não achou a carcela"
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=ok[0] + ok[1] * _pf(1.0))
        b = bpy.context.active_object
        b.name = "botao_%d" % k
        b.scale = (_lg(8.0), _pf(2.0), _alt(8.0))
        b.data.materials.append(gola)
        pecas.append(b)
    return pecas


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
    base.chanfrar({o for o in pecas if o.type == "MESH"})
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
