"""Dona Cida, expressão SÉRIA — candidata QUADRADA v1: o kit de caixas, melhorado.

    python3.11 art_lab/retratos/cida_seria/quadrada_v1/gerar_retrato_cida_quadrada_v1.py <pasta>
    PREVIA=1 python3.11 ...   # 384 px e 16 amostras, para iterar a forma

Grava `<pasta>/retrato_cida_seria.png` (768×768, alfa verdadeiro). É uma
CANDIDATA: não escreve em `brport_vs/` e não toca no manifest.

PORQUE EXISTE. Com a v2 redonda à frente dele, o Bruno pediu (23/09) «uma
versão melhorada da Dona Cida quadrada, para ver qual modelo escolho para
melhorar». Esta é a irmã da v2 do OUTRO lado: continua na oficina de CAIXAS —
prismas oitavados, placas na face, sombreado chapado e o `chanfrar()` do kit,
a mesma do `trabalhador_retrato` do rodapé — e refaz o que no retrato de hoje
não lê. Para as duas se compararem só pela FORMA, partilham o resto com a v2:
o estúdio, o enquadramento medido (a cabeça com o coque a 60% do quadro), os
materiais sem ruído, o brilho no olho e o AgX.

O QUE O RETRATO DE HOJE (`blender/brp_porto.py`) NÃO LÊ, e o que esta muda:

- A CABEÇA É UMA COLUNA — 174 de alto por 148 de largo, a cara comprida de um
  moai, com o queixo vazio. Passa a 156 por 158: a forma dela, que é LARGA;
- OS OLHOS SÃO QUADRADOS BRANCOS COM PUPILA PRETA, que leem como robô. Passam a
  ter íris castanha, pupila, BRILHO de emissão e pálpebra — a mesma anatomia do
  olho da v2, em placas;
- O CABELO É UM VASO: uma franja-cinta à volta da cabeça e uma cúpula dentro,
  com o coque em cima como uma tampa. Passa a ser uma calote baixa com MECHAS
  em ripa penteadas para trás, e o coque fica ATRÁS, em dois andares, com a
  liga à vista;
- O TRONCO É UM PEDESTAL — um octógono de tampo chato com uma caixa branca por
  gola, que lê como busto de troféu. Passa a ser uma malha por anéis oitavados
  (o trapézio desce até um ombro chanfrado) com a gola de duas PONTAS, o pé da
  gola e três botões;
- e o nariz ganha volume (uma caixa pequena que não projeta sombra, e a sombra
  da base), a boca afina e ganha lábio, e o lápis passa a encostar por cima da
  orelha.
"""

from __future__ import annotations

import os
import pathlib
import sys

_AQUI = pathlib.Path(__file__).resolve().parent
_RAIZ = _AQUI.parents[3]
sys.path.insert(0, str(_RAIZ / "blender"))
sys.path.insert(0, str(_RAIZ / "tools"))
# O raio, o enquadramento e os materiais sem ruído são os da v2, de propósito:
# as duas candidatas têm de diferir só na geometria.
sys.path.insert(0, str(_AQUI.parent / "v2"))

import bpy                                            # noqa: E402
import bmesh                                          # noqa: E402
from mathutils import Vector                          # noqa: E402

import gerar_props_iso as base                        # noqa: E402
from brp_studio import Estudio, cone, na_face, prisma  # noqa: E402
from brp_porto import _contorno_oitavado, _lg, _pf, _alt, _niv  # noqa: E402
from gerar_retrato_cida_v2 import emissao, enquadrar, principled, raio  # noqa: E402

NOME = "retrato_cida_seria"

# ── AS MEDIDAS, em PIXELS DE DESENHO como no kit ───────────────────────────
# (`brp_porto.py` explica porquê: depois da rotação de 45° a largura, a altura
# e a profundidade andam em três fatores diferentes.)
#
# ⚠️ A CABEÇA DE HOJE É 174 × 148 e lê como um MOAI: a cara é uma coluna, e o
# queixo fica com um palmo vazio por baixo da boca. A forma da Dona Cida é a
# LARGA (plano de arte §7.2, P2), e numa caixa isso é proporção: quase tão
# alta quanto larga, com as quinas mais cortadas.
_CAB_LARG, _CAB_FUNDO = 158.0, 76.0
_CAB_Z = (128.0, 284.0)
_MAXILAR = 198.0
_CAB_CENTRO = (_CAB_Z[0] + _CAB_Z[1]) / 2.0


def _plano_cabeca():
    """O centro e o tamanho da face `-y` da cabeça, como `na_face` os quer.

    ⚠️ A parte PLANA da face acaba em ±(largura/2 − corte) = ±57: uma placa
    que passe disso fica a flutuar sobre o bisel (a «orelha de tinta» que o
    kit já registou nos óculos). Os óculos acabam em ±52.
    """
    centro = (0.0, 0.0, _niv(_CAB_CENTRO))
    tam = (_lg(_CAB_LARG), _pf(_CAB_FUNDO), _alt(_CAB_Z[1] - _CAB_Z[0]))
    return centro, tam


def placa(nome, u, v, larg, alt_px, mat, fora=0.0, esp=0.02):
    """Uma placa na cara, em pixels de desenho a partir do centro da cabeça."""
    centro, tam = _plano_cabeca()
    return na_face(nome, "-y", centro, tam, _lg(u), _alt(v),
                   _lg(larg), _alt(alt_px), esp, mat, fora)


def loft(nome, aneis, mat):
    """Uma malha FACETADA por anéis oitavados, de cima para baixo.

    É o `prisma` do kit com mais de dois andares: sem subdivisão nem
    `shade smooth`, cada anel é uma aresta e cada faixa uma faceta — a
    gramática de caixas continua, e o tronco ganha o ombro que o prisma de
    dois andares não consegue dar. O anel de cima fecha-se (o pescoço pousa
    nele); o de baixo fica aberto, fora do quadro.
    """
    bm = bmesh.new()
    rings = []
    for anel in aneis:
        z_px, larg, fundo, corte = anel[:4]
        dy = _pf(anel[4]) if len(anel) > 4 else 0.0     # recua o anel inteiro
        rings.append([bm.verts.new((x, y + dy, _niv(z_px)))
                      for x, y in _contorno_oitavado(larg, fundo, corte)])
    n = len(rings[0])
    for a, b in zip(rings, rings[1:]):
        for i in range(n):
            j = (i + 1) % n
            bm.faces.new((a[i], a[j], b[j], b[i]))
    bm.faces.new(rings[0])
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    me = bpy.data.meshes.new(nome)
    bm.to_mesh(me)
    bm.free()
    o = bpy.data.objects.new(nome, me)
    bpy.context.scene.collection.objects.link(o)
    o.data.materials.append(mat)
    return o


def bastao(nome, a, b, raio_w, lados, mat):
    """Um prisma de `lados` faces entre dois pontos do mundo (o lápis)."""
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


def mecha(nome, perfil, escalas, x0, x1, esp_w, mat):
    """Uma faixa CONTÍNUA de cabelo ao longo de um perfil do plano YZ.

    `perfil` são pontos (y, z) do mundo na superfície da calote, da testa para
    trás; `escalas` aproxima a faixa do meio em cada ponto (o leque que
    converge no coque); a faixa sai `esp_w` para fora, pela normal do perfil.
    ⚠️ A primeira versão eram RIPAS soltas, uma caixa por troço: nas dobras
    abriam-se frestas e sobreposições, e o cabelo lia como TELHAS. Aqui os
    troços partilham os vértices da dobra, com a normal média dos dois.
    """
    pts = [Vector((0.0, y, zz)) for y, zz in perfil]
    normais = []
    for i in range(len(pts)):
        segs = []
        if i > 0:
            segs.append(pts[i] - pts[i - 1])
        if i < len(pts) - 1:
            segs.append(pts[i + 1] - pts[i])
        n = Vector((0.0, 0.0, 0.0))
        for s in segs:
            n += Vector((0.0, -s.z, s.y)).normalized()   # normal para FORA
        normais.append(n.normalized())
    bm = bmesh.new()
    aneis = []
    for p, n, k in zip(pts, normais, escalas):
        aneis.append([bm.verts.new(p + Vector((x * k, 0.0, 0.0)) + n * off)
                      for x, off in ((x0, 0.0), (x1, 0.0), (x1, esp_w), (x0, esp_w))])
    for a, b in zip(aneis, aneis[1:]):
        for i in range(4):
            j = (i + 1) % 4
            bm.faces.new((a[i], a[j], b[j], b[i]))
    bm.faces.new(aneis[0])
    bm.faces.new(list(reversed(aneis[-1])))
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    me = bpy.data.meshes.new(nome)
    bm.to_mesh(me)
    bm.free()
    o = bpy.data.objects.new(nome, me)
    bpy.context.scene.collection.objects.link(o)
    o.data.materials.append(mat)
    return o


def montar_cida(M):
    pele = M["pele_escura"]
    sombra = M["pele_sombra"]
    escuro = M["vao"]
    cabelo = principled("cabelo_cida", base.PALETA["madeira_esc"], rough=0.55, spec=0.25)
    blusa = principled("blusa_cida", base.PALETA["casco_pesca"], rough=0.9)
    gola = principled("gola_cida", base.PALETA["cabine"], rough=0.9)
    pecas = []

    # ── A CABEÇA: MAXILAR E CRÂNIO, oitavados ─────────────────────────────
    # O maxilar estreita para o queixo SÓ EM `x` (o kit explica: estreitar a
    # profundidade recuaria a face onde a cara vive).
    pecas.append(prisma("cabeca_maxilar",
                        _contorno_oitavado(_CAB_LARG, _CAB_FUNDO, 24.0),
                        _niv(_CAB_Z[0]), _niv(_MAXILAR), (0.80, 1.0), pele))
    # O CRÂNIO É UMA CÚPULA FACETADA, por dentro da calote do cabelo.
    # ⚠️ Como prisma de tampo chato (o de hoje) a quina de cima dele FURAVA o
    # cabelo: a frente da calote recua em rampa e a testa do crânio subia a
    # direito até 284 — saía uma PALA de pele na linha do cabelo, com duas
    # asas nas quinas. Três prévias, cada uma sem uma peça do cabelo, deram a
    # mesma pala; era pele, e não cabelo. Acima da linha do cabelo o crânio
    # recua mais do que a calote em cada anel.
    pecas.append(loft("cabeca_cranio", [
        (292.0, 96.0, 40.0, 12.0, 9.0),
        (280.0, 128.0, 56.0, 18.0, 6.0),
        (262.0, 149.0, _CAB_FUNDO, 22.0),
        (_MAXILAR, _CAB_LARG, _CAB_FUNDO, 22.0),
    ], pele))
    for sx in (-1.0, 1.0):
        o = prisma("orelha_%+d" % sx, _contorno_oitavado(16.0, 28.0, 5.0),
                   _niv(222.0), _niv(256.0), (1.0, 1.0), pele)
        o.location.x += sx * _lg(_CAB_LARG / 2.0 + 2.0)
        o.location.y += _pf(6.0)
        pecas.append(o)

    # ── OS OLHOS: branco, íris, pupila, brilho e pálpebra ─────────────────
    # ⚠️ Hoje são um quadrado branco com um quadrado preto: um ROBÔ. Quem dá
    # vida ao olho a este tamanho é a íris COLORIDA e o brilho (§7.5: o de
    # maior ganho por custo, e «funciona também no kit de hoje»). A pálpebra
    # de descanso tapa o alto do branco — atenta, não sonolenta.
    # Cada placa um passo mais à frente do que a de baixo: duas no mesmo plano
    # dão o losango preto do z-buffer.
    brilho = emissao("brilho_olho", 4.0)
    for sx in (-1.0, 1.0):
        u = 30.0 * sx
        # ⚠️ A 32 × 20 (uma prévia) o olho sumia na caixa do telefone: a
        # pupila ficava com um pixel. O limite é a parte plana da cara (±57),
        # e os óculos à volta deste acabam em ±55.
        pecas.append(placa("olho_branco_%+d" % sx, u, 12.0, 34.0, 22.0, M["cabine"]))
        pecas.append(placa("olho_iris_%+d" % sx, u, 11.0, 18.0, 19.0, M["porta"], fora=0.010))
        pecas.append(placa("olho_pupila_%+d" % sx, u, 11.0, 9.0, 10.0, escuro, fora=0.020))
        # O brilho do lado da luz-chave (a esquerda da imagem) e em cima.
        pecas.append(placa("olho_brilho_%+d" % sx, u - 4.5, 13.5, 4.5, 4.5, brilho, fora=0.030))
        pecas.append(placa("palpebra_%+d" % sx, u, 20.5, 36.0, 5.0, pele, fora=0.034))
        pecas.append(placa("pestana_%+d" % sx, u, 17.5, 36.0, 2.5, escuro, fora=0.038))
        # ÓCULOS: uma moldura de barras de 4 px à volta de um vão de 42×30,
        # à frente de tudo. ⚠️ Os de hoje têm barras de 6 e um vão justo ao
        # branco do olho: liam como duas janelas cinzentas.
        for nome, du, dv, lg, al in (("cima", 0.0, 17.0, 50.0, 4.0), ("baixo", 0.0, -17.0, 50.0, 4.0),
                                     ("fora", 23.0 * sx, 0.0, 4.0, 30.0),
                                     ("dentro", -23.0 * sx, 0.0, 4.0, 30.0)):
            pecas.append(placa("oculos_%s_%+d" % (nome, sx), u + du, 12.0 + dv,
                               lg, al, M["metal"], fora=0.046))
    pecas.append(placa("oculos_ponte", 0.0, 17.0, 16.0, 4.0, M["metal"], fora=0.046))
    # As hastes: a moldura continua pelo lado da cabeça até à orelha. De
    # frente só se vê a ponta delas no bisel, que é o bastante.
    for sx in (-1.0, 1.0):
        pecas.append(bastao("oculos_haste_%+d" % sx,
                            (sx * _lg(52.0), -_pf(_CAB_FUNDO / 2.0 + 1.5), _niv(_CAB_CENTRO + 29.0)),
                            (sx * _lg(_CAB_LARG / 2.0 + 1.0), _pf(4.0), _niv(_CAB_CENTRO + 27.0)),
                            _lg(1.6), 4, M["metal"]))
    for o in pecas:
        if o.name.startswith("oculos"):
            o.visible_shadow = False

    # ── SOBRANCELHAS, NARIZ E BOCA ────────────────────────────────────────
    for sx in (-1.0, 1.0):
        pecas.append(placa("sobrancelha_%+d" % sx, 30.0 * sx, 38.0, 34.0, 7.0, escuro))
    # O NARIZ GANHA VOLUME: uma caixa pequena, chanfrada pelo kit, que NÃO
    # projeta sombra (a lição da v1: a sombra dura do nariz caía na boca e
    # lia-se bigode). A base leva a placa de sombra do kit de hoje.
    # ⚠️ A 16 × 22 ele saiu uma BARRA fina — com a base, o «T» do retrato de
    # hoje. Mais largo do que alto, lê como nariz.
    nariz = placa("nariz", 0.0, -8.0, 22.0, 18.0, pele, esp=_pf(9.0))
    nariz.visible_shadow = False
    pecas.append(nariz)
    pecas.append(placa("nariz_base", 0.0, -18.5, 26.0, 4.0, sombra))
    # A BOCA: mais fina do que a barra de 12 de hoje, e com LÁBIO — uma placa
    # um tom abaixo da pele por baixo da linha, que é o que a faz ler como boca
    # e não como uma fita colada.
    pecas.append(placa("boca", 0.0, -40.0, 40.0, 5.0, escuro))
    pecas.append(placa("labio", 0.0, -46.0, 26.0, 5.0, sombra))

    # ── O CABELO: CALOTE BAIXA, MECHAS EM RIPA E O COQUE ATRÁS ────────────
    # ⚠️ Hoje é um VASO: uma franja em cinta a toda a volta e uma cúpula lá
    # dentro, com o coque em cima como a tampa. Cabelo preso é baixo e colado:
    # uma calote que acaba na linha do cabelo, e o desenho de PENTEADO vem das
    # ripas que correm da testa para trás, com a calote mais escura à vista
    # nos sulcos entre elas.
    linha = 262.0                               # a linha do cabelo na testa
    # ⚠️ A FRENTE DA CALOTE INCLINA PARA TRÁS. Na primeira prévia ela subia a
    # direito 26 px desde a linha do cabelo, e as mechas pousadas nela caíam na
    # testa como uma FRANJA — o contrário de cabelo puxado. Cada anel recua
    # (o quinto número), e a frente passa a ser uma rampa — UMA: com um anel a
    # meio (272) o troço de baixo ficava quase a pique e acendia-se numa PALA
    # clara ao longo da testa.
    # ⚠️ E ELA SEGUE A LARGURA DO CRÂNIO NA ALTURA DE CADA ANEL, que não é a
    # da cara: o crânio estreita de 158 para 146 até ao alto, e na linha do
    # cabelo mede ~149. Duas prévias com a calote a 164 e a 160 sobravam 5 a
    # 7 px de cada lado, e as quinas desse anel acendiam-se em duas ASAS nas
    # têmporas — a aba de um capacete. Aqui cada anel leva +3 sobre o crânio.
    # ⚠️ E AS ASAS NÃO ERAM SÓ A SOBRA: com a calote justa elas ficaram. Eram
    # as QUINAS de 45° dos anéis, viradas para a luz-chave, que se acendiam num
    # triângulo claro em cada têmpora. O corte das quinas desce para 12 e as
    # mechas estendem-se até elas.
    def cranio(z_px):
        f = (z_px - _MAXILAR) / (_CAB_Z[1] - _MAXILAR)
        return _CAB_LARG - 12.0 * max(0.0, min(1.0, f))
    pecas.append(loft("cabelo_calote", [
        (298.0, 118.0, 48.0, 14.0, 10.0),
        (290.0, cranio(284.0) + 2.0, 60.0, 14.0, 8.0),
        (linha, cranio(linha) + 3.0, 78.0, 12.0, 0.5),
        (212.0, 164.0, 80.0, 26.0),
    ], cabelo))
    # ⚠️ A calote a descer até 212 à FRENTE taparia a testa e os olhos: ela é
    # recortada pela frente, e só a nuca e os lados atrás da orelha descem.
    calote = pecas[-1]
    bm = bmesh.new()
    bm.from_mesh(calote.data)
    bmesh.ops.delete(bm, geom=[vv for vv in bm.verts
                               if vv.co.z < _niv(linha) - 1e-4 and vv.co.y < _pf(4.0)],
                     context="VERTS")
    bm.to_mesh(calote.data)
    bm.free()
    # Por baixo da calote recortada, a nuca: uma caixa oitavada atrás das
    # orelhas, que fecha o buraco que o recorte abriu.
    nuca = prisma("cabelo_nuca", _contorno_oitavado(166.0, 40.0, 14.0),
                  _niv(212.0), _niv(linha + 2.0), (1.0, 1.0), cabelo)
    nuca.location.y += _pf(22.0)
    pecas.append(nuca)
    # AS MECHAS: cinco faixas da testa por cima da cabeça até ao coque, em
    # leque. Pousam na FRENTE de cada anel da calote (a parte plana dele) e
    # meia espessura fora; as de fora ficam dentro da parte plana de cada anel,
    # senão flutuavam sobre o bisel.
    perfil = [(-_pf(38.5), _niv(linha + 0.5)),
              (-_pf(22.0), _niv(290.0)), (-_pf(14.0), _niv(298.0)),
              (_pf(20.0), _niv(298.0))]
    escalas = (1.0, 0.90, 0.76, 0.52)
    for i, (u0, u1) in enumerate(((-60.0, -38.0), (-34.0, -12.0), (-9.0, 9.0),
                                  (12.0, 34.0), (38.0, 60.0))):
        pecas.append(mecha("cabelo_mecha_%d" % i, perfil, escalas,
                           _lg(u0), _lg(u1), _pf(3.0), cabelo))
    # O COQUE: atrás e acima, em DOIS andares (a volta do cabelo enrolado), com
    # a liga à vista entre ele e a calote. ⚠️ Hoje é um cilindro em cima da
    # cabeça, e com a franja-cinta por baixo lia como a tampa de um vaso.
    y_coque = _pf(30.0)
    pecas.append(cone("coque_liga", (0.0, y_coque, _niv(305.0)), _lg(26.0), _lg(26.0),
                      _alt(5.0), 12, M["colete"]))
    pecas.append(cone("coque", (0.0, y_coque, _niv(318.0)), _lg(36.0), _lg(30.0),
                      _alt(22.0), 12, cabelo))
    pecas.append(cone("coque_volta", (0.0, y_coque, _niv(334.0)), _lg(24.0), _lg(18.0),
                      _alt(10.0), 12, cabelo))

    # ── O LÁPIS, POR CIMA DA ORELHA DIREITA (da imagem) ───────────────────
    # Hoje ele sai de lado, a flutuar. Encosta na raiz da orelha, deitado com a
    # ponta à frente e para baixo, e fica à vista no perfil da cabeça.
    r_l = _lg(4.5)
    a = Vector((_lg(85.0), _pf(26.0), _niv(270.0)))
    b = Vector((_lg(89.0), -_pf(22.0), _niv(246.0)))
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
    # ⚠️ Hoje o tronco é um PEDESTAL: um octógono de tampo chato com uma caixa
    # branca por gola — busto de troféu. Aqui é um loft de anéis oitavados: o
    # trapézio desce do pescoço até ao ombro chanfrado, cada anel uma aresta.
    pecas.append(prisma("pescoco", _contorno_oitavado(54.0, 46.0, 10.0),
                        _niv(84.0), _niv(150.0), (1.0, 1.0), pele))
    pecas.append(prisma("pescoco_sombra", _contorno_oitavado(55.0, 47.0, 10.0),
                        _niv(116.0), _niv(129.0), (1.0, 1.0), sombra))
    tronco = loft("tronco", [
        (96.0, 72.0, 52.0, 16.0),       # o decote, onde o pescoço pousa
        (88.0, 150.0, 64.0, 24.0),      # trapézio
        (70.0, 236.0, 74.0, 34.0),      # alto do ombro
        (50.0, 286.0, 78.0, 40.0),      # a quina do ombro
        (20.0, 298.0, 80.0, 40.0),
        (-90.0, 298.0, 80.0, 40.0),     # fora do quadro
    ], blusa)
    pecas.append(tronco)
    # O PÉ DA GOLA: uma fita baixa à volta do pescoço. ⚠️ A gola de hoje é
    # uma caixa de 22 de alto, e lia como um cubo branco debaixo do queixo.
    pecas.append(prisma("gola_pe", _contorno_oitavado(62.0, 54.0, 14.0),
                        _niv(94.0), _niv(106.0), (1.0, 1.0), gola))
    bpy.context.view_layer.update()
    # AS ABAS COM PONTA, pousadas ponto a ponto no tronco por raio — facetadas
    # porque o tronco é: cada ponto da grelha segue a faceta onde cai.
    for sx in (-1.0, 1.0):
        A = (4.0 * sx, 96.0)
        B = (30.0 * sx, 100.0)
        C = (64.0 * sx, 80.0)
        D = (20.0 * sx, 54.0)
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
        me = bpy.data.meshes.new("gola_%+d" % sx)
        bm.to_mesh(me)
        bm.free()
        aba = bpy.data.objects.new("gola_%+d" % sx, me)
        bpy.context.scene.collection.objects.link(aba)
        aba.data.materials.append(gola)
        aba.modifiers.new("espessura", "SOLIDIFY").thickness = _pf(2.0)
        pecas.append(aba)
    for k, zz in enumerate((40.0, 24.0, 8.0)):
        ok = raio([tronco], Vector((0.0, -10.0, _niv(zz))), Vector((0, 1, 0)))
        assert ok, "o botão não achou o peito"
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
    # O chanfro do kit, por último e em tudo — é a gramática da oficina.
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
