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

Só a Dona Cida está neste modelo. O Sr. Ribeiro e o Arlindo continuam no
`_corpo()` do `brp_porto.py` até serem refeitos — é o passo seguinte da `055`.
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

# ── AS MEDIDAS DA CABEÇA, em pixels de desenho como no kit ─────────────────
_CAB_LARG, _CAB_FUNDO = 158.0, 76.0
_CAB_Z = (140.0, 284.0)
_MAXILAR = 196.0
_CAB_CENTRO = (_CAB_Z[0] + _CAB_Z[1]) / 2.0
_CORTE_CARA = 20.0
_DZ = 8.0                       # o tronco sobe com o queixo, menos do que ele
_PIVO = 122.0                   # o meio do pescoço: a cabeça roda sobre ele
_Z_OLHO = 216.0


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


def _plano_cabeca():
    centro = (0.0, 0.0, _niv(_CAB_CENTRO))
    tam = (_lg(_CAB_LARG), _pf(_CAB_FUNDO), _alt(_CAB_Z[1] - _CAB_Z[0]))
    return centro, tam


def _placa(nome, u, z_px, larg, alt_px, mat, fora=0.0, esp=0.02, inclina=0.0):
    """Uma placa na cara, em `u` a partir do meio e à altura ABSOLUTA `z_px`.

    ⚠️ `inclina` positivo do lado ESQUERDO baixa a ponta de DENTRO — é o
    «franzida» do kit. Um arco quer o sinal contrário.
    """
    centro, tam = _plano_cabeca()
    o = na_face(nome, "-y", centro, tam, _lg(u), _alt(z_px - _CAB_CENTRO),
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


def _cunha(nome, z_topo, z_ponta, larg_topo, larg_ponta, sai_topo, sai_ponta, mat):
    """Um nariz em CUNHA: estreito e rente na cana, largo e saliente na ponta."""
    y0 = -_pf(_CAB_FUNDO / 2.0) + _pf(1.0)
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


def _aro_oitavado(nome, u, z_px, larg, alt, corte, barra, fora, mat):
    """Um aro de óculos OITAVADO na face da frente: o redondo das caixas."""
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
_OLHAR = {"frente": (0.0, 0.0), "baixo": (0.0, -4.0), "lado": (5.0, 0.0),
          "cima": (0.0, 3.0)}


def _olhos(M, cara, pele, escuro):
    if cara["olho"] != "aberto":
        raise ValueError("olho %r ainda não existe no modelo novo" % cara["olho"])
    du, dz = _OLHAR[cara["olhar"]]
    brilho = _emissao("brilho_olho", 1.0)       # Standard: força 1 já dá 255
    pecas = []
    for sx in (-1.0, 1.0):
        u = 31.0 * sx
        pecas.append(_placa("olho_branco_%+d" % sx, u, _Z_OLHO, 38.0, 24.0, M["cabine"]))
        pecas.append(_placa("olho_iris_%+d" % sx, u + du, _Z_OLHO - 1.0 + dz, 20.0, 22.0,
                            M["porta"], fora=0.010))
        pecas.append(_placa("olho_pupila_%+d" % sx, u + du, _Z_OLHO - 1.0 + dz, 10.0, 12.0,
                            escuro, fora=0.020))
        pecas.append(_placa("olho_brilho_%+d" % sx, u - 5.0 + du, _Z_OLHO + 3.0 + dz, 5.0, 5.0,
                            brilho, fora=0.030))
        pecas.append(_placa("palpebra_%+d" % sx, u, _Z_OLHO + 10.5, 40.0, 3.5, pele, fora=0.034))
        pecas.append(_placa("pestana_%+d" % sx, u, _Z_OLHO + 8.0, 40.0, 2.5, escuro, fora=0.038))
        pecas.append(_aro_oitavado("oculos_%+d" % sx, u, _Z_OLHO, 46.0, 32.0, 9.0, 2.5,
                                   0.046, M["metal"]))
    pecas.append(_placa("oculos_ponte", 0.0, _Z_OLHO + 5.0, 14.0, 3.0, M["metal"], fora=0.052))
    for sx in (-1.0, 1.0):
        pecas.append(_bastao("oculos_haste_%+d" % sx,
                             (sx * _lg(56.0), -_pf(_CAB_FUNDO / 2.0 + 1.5), _niv(_Z_OLHO + 6.0)),
                             (sx * _lg(_CAB_LARG / 2.0 + 1.0), _pf(4.0), _niv(_Z_OLHO + 4.0)),
                             _lg(1.4), 4, M["metal"]))
    for o in pecas:
        if o.name.startswith("oculos"):
            o.visible_shadow = False
    return pecas


def _sobrancelhas(cara, mat):
    """Duas placas por lado: a de dentro e a de fora. A emoção é para onde
    vai a de DENTRO: franzida desce e inclina para o meio, erguida sobe."""
    estilo = cara["cenho"]
    tabela = {
        #            (z dentro, inclina dentro, z fora, inclina fora) — lado DIREITO
        "neutra":   (241.0, 0.0, 239.0, 14.0),
        "franzida": (238.5, -12.0, 238.5, 6.0),
        "erguida":  (244.0, 8.0, 241.5, 16.0),
    }
    if estilo not in tabela:
        raise ValueError("cenho %r ainda não existe no modelo novo" % estilo)
    z_d, i_d, z_f, i_f = tabela[estilo]
    pecas = []
    for sx in (-1.0, 1.0):
        pecas.append(_placa("sobrancelha_dentro_%+d" % sx, 23.0 * sx, z_d, 18.0, 5.0, mat,
                            inclina=i_d * sx))
        pecas.append(_placa("sobrancelha_fora_%+d" % sx, 40.0 * sx, z_f, 18.0, 4.5, mat,
                            fora=0.002, inclina=i_f * sx))
    return pecas


def _boca(M, cara, escuro, labio):
    """A linha entre os lábios, o lábio de baixo em cor e o de cima fino.

    Como no kit, o que se lê a este tamanho é para onde apontam as PONTAS: um
    canto fora da linha, acima ou abaixo dela.
    """
    estilo = cara["boca"]
    if estilo == "reta":
        return [_placa("boca", 0.0, 170.0, 36.0, 3.5, escuro),
                _placa("labio", 0.0, 165.0, 26.0, 6.0, labio),
                _placa("labio_cima", 0.0, 173.5, 22.0, 3.0, labio)]
    if estilo == "descontente":
        pecas = [_placa("boca", 0.0, 171.0, 28.0, 3.5, escuro),
                 _placa("labio", 0.0, 166.0, 22.0, 6.0, labio),
                 _placa("labio_cima", 0.0, 174.5, 20.0, 3.0, labio)]
        pecas += [_placa("boca_canto_%+d" % sx, 16.0 * sx, 168.0, 8.0, 3.5, escuro)
                  for sx in (-1.0, 1.0)]
        return pecas
    if estilo == "sorriso":
        pecas = [_placa("boca", 0.0, 167.5, 30.0, 3.5, escuro),
                 _placa("labio", 0.0, 162.5, 24.0, 5.0, labio),
                 _placa("labio_cima", 0.0, 173.5, 24.0, 3.0, labio),
                 # Os DENTES: uma placa clara entre o lábio de cima e a linha —
                 # é o que separa um sorriso de uma boca virada para cima.
                 _placa("dentes", 0.0, 170.5, 22.0, 3.0, M["cabine"])]
        pecas += [_placa("boca_canto_%+d" % sx, 18.0 * sx, 170.5, 8.0, 3.5, escuro)
                  for sx in (-1.0, 1.0)]
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
    queixo = _placa("queixo", 0.0, 150.0, 34.0, 12.0, pele, esp=_pf(4.0))
    queixo.visible_shadow = False
    cab.append(queixo)
    for sx in (-1.0, 1.0):
        o = prisma("orelha_%+d" % sx, _contorno_oitavado(16.0, 28.0, 5.0),
                   _niv(220.0), _niv(254.0), (1.0, 1.0), pele)
        o.location.x += sx * _lg(_CAB_LARG / 2.0 + 2.0)
        o.location.y += _pf(6.0)
        cab.append(o)

    cab += _olhos(M, cara, pele, escuro)
    cab += _sobrancelhas(cara, sobrancelha)
    nariz = _cunha("nariz", 207.0, 188.0, 9.0, 22.0, 2.0, 9.0, pele)
    nariz.visible_shadow = False
    cab.append(nariz)
    cab.append(_placa("nariz_base", 0.0, 185.5, 24.0, 3.5, sombra))
    cab += _boca(M, cara, escuro, labio)
    for sx in (-1.0, 1.0):
        m = _placa("maca_%+d" % sx, 37.0 * sx, 188.0, 26.0, 14.0, pele, esp=_pf(1.2))
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
        A = (4.0 * sx, 94.0 + _DZ)
        B = (28.0 * sx, 96.0 + _DZ)
        C = (54.0 * sx, 76.0 + _DZ)
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
                    ok = _raio([tronco], Vector((_lg(x), -10.0, _niv(zz - 2.0 * k))),
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
        tronco_l.append(aba)
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


def pousar_cabeca(pecas, pose):
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
    pivo = Vector((0.0, 0.0, _niv(_PIVO)))
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


def enquadrar(cena, nome, pecas, medir):
    """Gira o grupo para a câmera e põe-no no quadro, MEDINDO a projeção.

    `medir` são as peças da cabeça com o cabelo e o coque: é a altura delas que
    vale 60% do quadro. ⚠️ Mexer na altura da cabeça mexe no tamanho de TUDO o
    resto — encurtá-la 12 ampliou o busto 11% (a `quadrada_v2`).
    """
    piv = bpy.data.objects.new("pivo_%s" % nome, None)
    bpy.context.scene.collection.objects.link(piv)
    for o in pecas:
        o.parent = piv
    piv.rotation_euler.z = math.radians(45.0)
    bpy.context.view_layer.update()
    x0, y0, x1, y1 = _pixels(cena, medir)
    k = (CABECA_NO_QUADRO * cena.render.resolution_y) / (y1 - y0)
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
