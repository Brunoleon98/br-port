#!/usr/bin/env python3
"""
BR Port — quanto da silhueta de cada prop corre nas direções do eixo isométrico.

POR QUE ESTA RÉGUA EXISTE
-------------------------
O item 8 do segundo playtest pede menos quadrado e mais curva. A primeira
fatia (a costa, `docs/decisoes/023`) foi decidida com números; esta é a
segunda, e o alvo é o KIT DE PROPS — 142 chamadas a `caixa()` contra 23 a
`cone()` em `gerar_props_iso.py`. Contar chamadas diz como o prop foi
CONSTRUÍDO; não diz o que o jogador VÊ. Um cilindro de 5 px lê como um risco,
e uma caixa vista de canto lê como uma caixa mesmo cheia de chanfro.

O que o olho lê é a SILHUETA, e nesta câmera uma caixa alinhada aos eixos só
sabe desenhar três direções: +26,57°, -26,57° e a vertical (as arestas X, Y e
Z do mundo projetadas). Qualquer outra direção na silhueta é curva, bisel ou
peça girada. Daí a medida: que fração do contorno corre numa dessas três.

A RÉGUA É A DO D28, E DE PROPÓSITO
----------------------------------
⚠️ Medir "o ângulo entre segmentos vizinhos" mede o ARREDONDAMENTO, e isso já
custou uma asserção neste projeto (`docs/decisoes/023` §6). Aqui o contorno sai
por marching squares no alfa (subpixel, sem escada de pixel) e a reta mede-se
com uma RÉGUA POUSADA EM CIMA DO DESENHO: para cada ponto do contorno, até onde
uma corda centrada nele se estende sem que a linha se afaste mais de `TOL` px.
Ponto no meio de uma aresta reta tem corda longa; ponto em cima de uma quina
tem corda curta. É start-independent — não depende de onde se começou a andar.

O QUE SE COMPARA CONTRA
-----------------------
Sozinho o número não diz nada, então a ferramenta desenha três silhuetas
IDEAIS do mesmo tamanho e mede-as com a mesma régua:

  · caixa   — o hexágono que uma caixa alinhada aos eixos projeta aqui
  · cilindro— duas elipses e dois lados verticais (o lado vertical é eixo,
              logo o cilindro NÃO mede zero: é esse o ponto)
  · esfera  — um círculo, o piso de quem não tem aresta nenhuma

`indice` normaliza entre esfera (0) e caixa (1), que é o que torna os props
comparáveis entre si sem decorar o valor cru.

USO
---
    python3 tools/medir_silhueta_props.py brport_vs/art/props [--csv saida.csv]
    python3 tools/medir_silhueta_props.py brport_vs/art/props --limiar 0.7
"""

import argparse
import math
import os
import sys

import numpy as np
from PIL import Image

# As três direções que uma caixa alinhada aos eixos projeta nesta câmera.
# 26,565° = atan(MEIA_ALT / MEIA_LARG) = atan(0,5). A vertical é a aresta Z.
ISO = math.degrees(math.atan2(15.0, 30.0))
EIXOS = (ISO, -ISO, 90.0)

TOL = 1.0          # px — o quanto a linha pode afastar-se da corda
RETA_MIN = 6.0     # px — corda abaixo disto não é aresta, é quina
ANG_TOL = 8.0      # graus — folga em volta de cada eixo
PASSO = 0.5        # px — reamostragem do contorno
ALFA = 0.5         # limiar de silhueta


# ----------------------------------------------------------- marching squares
def _contornos(campo: np.ndarray, nivel: float):
    """Contornos fechados de `campo` no nível dado, com precisão subpixel.

    Implementado à mão (e não com scikit-image) para o conferidor viver com as
    mesmas duas dependências do resto das ferramentas de arte: numpy e pillow.
    O caso de cada célula sai vetorizado e o laço Python percorre só as células
    de FRONTEIRA — que são algumas centenas, e não os 261 mil de um quadro.
    """
    a = campo[:-1, :-1]
    b = campo[:-1, 1:]
    c = campo[1:, 1:]
    d = campo[1:, :-1]
    dentro = lambda v: (v >= nivel).astype(np.uint8)
    idx = dentro(a) * 8 + dentro(b) * 4 + dentro(c) * 2 + dentro(d)
    centro = (a + b + c + d) / 4.0
    ys, xs = np.nonzero((idx > 0) & (idx < 15))

    def _t(v0, v1):
        return 0.0 if v0 == v1 else (nivel - v0) / (v1 - v0)

    segs = []
    for y, x in zip(ys.tolist(), xs.tolist()):
        va, vb, vc, vd = a[y, x], b[y, x], c[y, x], d[y, x]
        caso = int(idx[y, x])
        T = (x + _t(va, vb), float(y))
        R = (float(x + 1), y + _t(vb, vc))
        B = (x + _t(vd, vc), float(y + 1))
        L = (float(x), y + _t(va, vd))
        if caso in (1, 14):
            segs.append((L, B))
        elif caso in (2, 13):
            segs.append((B, R))
        elif caso in (3, 12):
            segs.append((L, R))
        elif caso in (4, 11):
            segs.append((T, R))
        elif caso in (6, 9):
            segs.append((T, B))
        elif caso in (7, 8):
            segs.append((L, T))
        else:
            # Sela (5 e 10): o centro desempata. Escolha consistente — um
            # empate resolvido ao acaso partiria o contorno em dois.
            if (centro[y, x] >= nivel) == (caso == 10):
                segs.append((L, T))
                segs.append((B, R))
            else:
                segs.append((L, B))
                segs.append((T, R))

    # Os pontos são interpolados dos MESMOS dois cantos nas duas células que
    # partilham a aresta, logo casam bit a bit e dá para encadear por chave.
    vizinhos = {}
    for p, q in segs:
        vizinhos.setdefault(p, []).append(q)
        vizinhos.setdefault(q, []).append(p)

    vistos = set()
    saida = []
    for inicio in list(vizinhos):
        if inicio in vistos:
            continue
        cadeia = [inicio]
        vistos.add(inicio)
        atual, anterior = inicio, None
        while True:
            seguintes = [p for p in vizinhos.get(atual, ())
                         if p != anterior and p not in vistos]
            if not seguintes:
                break
            anterior, atual = atual, seguintes[0]
            vistos.add(atual)
            cadeia.append(atual)
        if len(cadeia) >= 4:
            saida.append(np.array(cadeia, dtype=np.float64))
    return saida


def _reamostrar(pontos: np.ndarray, passo: float):
    """Contorno fechado reamostrado a passo constante de arco."""
    fechado = np.vstack([pontos, pontos[:1]])
    d = np.linalg.norm(np.diff(fechado, axis=0), axis=1)
    s = np.concatenate([[0.0], np.cumsum(d)])
    total = s[-1]
    if total < passo * 8:
        return None, total
    n = max(8, int(round(total / passo)))
    alvo = np.linspace(0.0, total, n, endpoint=False)
    x = np.interp(alvo, s, fechado[:, 0])
    y = np.interp(alvo, s, fechado[:, 1])
    return np.stack([x, y], axis=1), total


def _corda_e_direcao(p: np.ndarray, passo: float, tol: float, teto: float):
    """Para cada ponto: comprimento da reta centrada nele, e a direção dela.

    Cresce a janela simetricamente enquanto todo ponto dentro dela ficar a menos
    de `tol` da corda que a fecha. É a régua do D28 aplicada ponto a ponto — e é
    por ser CENTRADA que não depende de onde a caminhada começou. Uma medida que
    partisse o contorno em corridas a partir de um ponto qualquer daria números
    diferentes conforme o ponto de partida.
    """
    n = len(p)
    k_max = max(1, min(n // 2 - 1, int(teto / passo / 2)))
    comp = np.zeros(n)
    dire = np.zeros(n)
    for i in range(n):
        melhor_k = 0
        melhor_dir = 0.0
        for k in range(1, k_max + 1):
            janela = p.take(range(i - k, i + k + 1), axis=0, mode="wrap")
            v = janela[-1] - janela[0]
            comprimento = math.hypot(v[0], v[1])
            if comprimento < 1e-9:
                break
            rel = janela - janela[0]
            desvio = np.abs(rel[:, 0] * v[1] - rel[:, 1] * v[0]) / comprimento
            if desvio.max() > tol:
                break
            melhor_k = k
            # y cresce para BAIXO na imagem; o sinal invertido põe o ângulo no
            # sentido em que este projeto fala dele (+26,57° sobe para a direita).
            melhor_dir = math.degrees(math.atan2(-v[1], v[0]))
        comp[i] = 2.0 * melhor_k * passo
        dire[i] = melhor_dir
    return comp, dire


def _no_eixo(graus: np.ndarray):
    g = np.mod(graus, 180.0)
    perto = np.zeros(len(g), dtype=bool)
    for eixo in EIXOS:
        e = eixo % 180.0
        d = np.abs(g - e)
        d = np.minimum(d, 180.0 - d)
        perto |= d <= ANG_TOL
    return perto


def contornos_medidos(alfa: np.ndarray, limiar: float = ALFA):
    """Mede CADA contorno da máscara: perímetro, diagonal e fração no eixo.

    ⚠️ MEDE TODOS OS CONTORNOS, e não só o de fora. Um prop deste kit pode ser
    feito de peças SOLTAS — o `pier_vazio` são oito estacas separadas, a copa do
    coqueiro são folhas —, e a primeira versão desta função escolhia "o contorno
    de maior caixa envolvente" como silhueta: no píer vazio isso mediu UMA
    estaca (74 px de perímetro num prop de 116x84) e deu por medido o resto.
    O que o olho lê é tudo o que está desenhado, vazado de treliça incluído.
    """
    saida = []
    for c in _contornos(alfa, limiar):
        if len(c) < 8:
            continue
        pontos, total = _reamostrar(c, PASSO)
        if pontos is None:
            continue          # respingo de antisserrilhado, não é desenho
        cw = c[:, 0].max() - c[:, 0].min()
        ch = c[:, 1].max() - c[:, 1].min()
        diag = math.hypot(cw, ch)
        # O teto da régua é a escala da PEÇA, e de cada peça: uma régua maior
        # do que o que ela mede acabaria a medir o quadro.
        cp, dr = _corda_e_direcao(pontos, PASSO, TOL,
                                  max(RETA_MIN * 2.0, 0.5 * diag))
        reta = cp >= RETA_MIN
        saida.append({
            "perim": total,
            "diag": diag,
            "larg": cw,
            "alt": ch,
            "f_reta": float(reta.mean()),
            "f_eixo": float((reta & _no_eixo(dr)).mean()),
            "maior_reta": float(cp.max()),
        })
    return saida


# --------------------------------------------------------- linhas de DENTRO
def linhas_internas(rgba: np.ndarray, limiar: float = ALFA):
    """Que fração da tinta desenhada por DENTRO do prop corre no eixo.

    A silhueta responde por metade da pergunta e não mais. ⚠️ NESTE ESTILO O
    DETALHE É DESENHADO COM FRONTEIRAS DE VALOR — está escrito no `CLAUDE.md`,
    e foi por isso que o contorno pelo compositor foi rejeitado: "o corrugado,
    as fiadas, as cantoneiras, porque a esta escala relevo não sobrevive ao
    antisserrilhado". Logo o que faz um prédio LER quadrado não é só o recorte
    dele contra o céu; são as fiadas do telhado, o vinco da chapa, a moldura da
    janela e a junta do tabuado, todas paralelas aos mesmos três eixos.

    Mede-se a ENERGIA do gradiente de luminância, e não a contagem de pixels:
    uma linha forte conta mais do que um véu, que é como o olho a lê. A borda
    contra o transparente fica de fora — essa é a silhueta, e já foi medida.
    """
    alfa = rgba[:, :, 3]
    dentro = alfa >= limiar
    if dentro.sum() < 16:
        return None
    lum = (0.2126 * rgba[:, :, 0] + 0.7152 * rgba[:, :, 1]
           + 0.0722 * rgba[:, :, 2])
    lum = np.where(dentro, lum, 0.0)
    gx = np.zeros_like(lum)
    gy = np.zeros_like(lum)
    gx[:, 1:-1] = (lum[:, 2:] - lum[:, :-2]) / 2.0
    gy[1:-1, :] = (lum[2:, :] - lum[:-2, :]) / 2.0
    # Só onde os dois vizinhos dos dois eixos são opacos: assim a silhueta
    # (a fronteira com o transparente) não entra na conta.
    nucleo = np.zeros_like(dentro)
    nucleo[1:-1, 1:-1] = (dentro[1:-1, 1:-1] & dentro[:-2, 1:-1]
                          & dentro[2:, 1:-1] & dentro[1:-1, :-2]
                          & dentro[1:-1, 2:])
    mag = np.hypot(gx, gy)
    forte = nucleo & (mag > 0.02)      # abaixo disto é ruído do denoiser
    if forte.sum() < 16:
        return None
    # A direção da LINHA é perpendicular à do gradiente.
    ang = np.degrees(np.arctan2(-gy[forte], gx[forte])) + 90.0
    peso = mag[forte]
    return {
        "e_eixo": float(peso[_no_eixo(ang)].sum() / peso.sum()),
        "energia": float(peso.sum()),
    }


# --------------------------------------------------------------- referências
def _mascara(desenho, larg: float, alt: float):
    """Rasteriza uma forma ideal com antisserrilhado, para servir de piso.

    O quadro acompanha a peça pedida: uma referência medida num quadro fixo
    mediria o quadro e não a forma.
    """
    ss = 4
    lx = int(larg) + 8
    ly = int(alt) + 8
    yy, xx = np.mgrid[0:ly * ss, 0:lx * ss]
    g = desenho((xx - lx * ss / 2.0) / ss,
                (yy - ly * ss / 2.0) / ss).astype(np.float32)
    return g.reshape(ly, ss, lx, ss).mean(axis=(1, 3))


def referencias(larg: float, alt: float):
    """As três silhuetas ideais com a MESMA caixa envolvente da peça medida.

    ⚠️ REFERÊNCIA DE PROPORÇÃO FIXA FAVORECE PEÇA COMPRIDA, e isso quase
    decidiu esta sessão ao contrário. A primeira versão comparava tudo contra
    formas de altura 1,1x a largura: a ESTACA do píer (9 x 32 px) mediu índice
    **1,37** — mais quadrada do que a caixa ideal —, e a leitura óbvia era
    "arredonde as estacas". Só que uma estaca CILÍNDRICA de 9 x 32 px tem
    exactamente os mesmos dois lados verticais na silhueta: o que a faz medir
    alto é ser COMPRIDA, não ser quadrada. Com a referência a acompanhar a
    proporção da peça, a banda entre caixa e redondo fecha-se sozinha onde a
    pergunta não tem resposta — e aí a ferramenta diz que não tem.
    """
    r = larg / 2.0
    # O hexágono da caixa gasta r/2 de altura em cada tampa; o cilindro gasta
    # o mesmo, que é o que mantém as três com a mesma caixa envolvente.
    hb = max(alt - r, r * 0.05)

    def redondo(x, y):
        # Elipse: o piso de quem não tem aresta nenhuma, na proporção da peça.
        return (x / r) ** 2 + (y / (alt / 2.0)) ** 2 <= 1.0

    def cilindro(x, y):
        # Nesta câmera: duas elipses 2:1 e dois lados VERTICAIS. O lado
        # vertical é direção de eixo, então o cilindro não mede zero — e numa
        # peça comprida ele mede quase o mesmo que a caixa, que é o ponto.
        corpo = (np.abs(x) <= r) & (np.abs(y) <= hb / 2)
        tampa = ((x / r) ** 2 + ((np.abs(y) - hb / 2) / (r / 2)) ** 2 <= 1.0)
        return corpo | tampa

    def caixa_iso(x, y):
        # O hexágono de uma caixa alinhada aos eixos: dois losangos 2:1 (o topo
        # e a base) ligados por duas verticais. Só três direções, e são as três
        # de `EIXOS`.
        corpo = (np.abs(x) <= r) & (np.abs(y) <= hb / 2)
        tampa = (np.abs(x) / r + (np.abs(y) - hb / 2) / (r / 2) <= 1.0) \
            & (np.abs(x) <= r)
        return corpo | tampa

    return {"caixa": _mascara(caixa_iso, larg, alt),
            "cilindro": _mascara(cilindro, larg, alt),
            "redondo": _mascara(redondo, larg, alt)}


# Abaixo de uma certa diagonal — e acima de uma certa esbeltez — a caixa ideal
# e a forma redonda medem O MESMO, e aí o índice não é um número pequeno: não
# existe. `BANDA_MIN` é o quanto a régua tem de separar as duas para a pergunta
# ter resposta.
BANDA_MIN = 0.15

_CACHE = {}


def banda(larg: float, alt: float, limiar: float = ALFA):
    """(redondo, caixa) para uma peça desta caixa envolvente."""
    # Arredonda para um degrau de 6% — duas peças com a mesma proporção e
    # tamanho quase igual não pagam duas vezes o mesmo render.
    def _degrau(v):
        return round(6.0 * 1.06 ** round(math.log(max(v, 6.0) / 6.0, 1.06)), 2)
    chave = (_degrau(larg), _degrau(alt), round(limiar, 3))
    if chave not in _CACHE:
        refs = referencias(chave[0], chave[1])
        vals = {}
        for nome, m in refs.items():
            cs = contornos_medidos(m, limiar)
            vals[nome] = (max(cs, key=lambda k: k["perim"])["f_eixo"]
                          if cs else 0.0)
        _CACHE[chave] = (vals["redondo"], vals["caixa"], vals["cilindro"])
    return _CACHE[chave]


def indice(larg: float, alt: float, f_eixo: float, limiar: float = ALFA):
    """0 = tão redondo quanto uma elipse da mesma caixa; 1 = tão quadrado
    quanto uma caixa alinhada aos eixos da mesma caixa.

    Devolve None onde a banda é estreita demais para a pergunta ter resposta —
    **recusar-se a adivinhar em vez de imprimir um número plausível** é a mesma
    regra do `gerar_tabela_numeros.py`.
    """
    lo, hi, _cil = banda(larg, alt, limiar)
    if hi - lo < BANDA_MIN:
        return None
    return (f_eixo - lo) / (hi - lo)


def varrer_filete(larg: float, alt: float, raios, limiar: float = ALFA):
    """Quanto de filete é preciso antes de a régua dar pela curva.

    A pergunta que decide se arredondar PAGA: a caixa ideal do tamanho da peça
    ganha um filete de raio `f` nas quinas, e mede-se de novo. Enquanto o
    `f_eixo` não se mexer, o arredondamento existe no modelo e NÃO existe na
    imagem — que é o mesmo que "relevo de 0,9 px não sobrevive ao
    antisserrilhado", escrito em unidades de forma em vez de em unidades de luz.
    """
    r = larg / 2.0
    hb = max(alt - r, r * 0.05)
    saida = []
    for f in raios:
        def caixa_filetada(x, y, f=f):
            # A caixa erodida por `f` e dilatada de volta: é a definição de
            # arredondar uma quina, e trata as seis de uma vez sem escrever
            # nenhuma delas à mão.
            rr = r - f

            def dentro(dx, dy):
                corpo = (np.abs(dx) <= rr) & (np.abs(dy) <= hb / 2)
                tampa = (np.abs(dx) / rr
                         + (np.abs(dy) - hb / 2) / (rr / 2) <= 1.0) \
                    & (np.abs(dx) <= rr)
                return corpo | tampa
            if f <= 0:
                return dentro(x, y)
            acc = np.zeros(x.shape, dtype=bool)
            for k in range(16):
                a = 2.0 * math.pi * k / 16.0
                acc |= dentro(x - f * math.cos(a), y - f * math.sin(a))
            return acc

        m = _mascara(caixa_filetada, larg, alt)
        cs = contornos_medidos(m, limiar)
        saida.append((f, max(cs, key=lambda k: k["perim"])["f_eixo"]))
    return saida


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("pasta")
    ap.add_argument("--csv", default=None)
    ap.add_argument("--limiar", type=float, default=ALFA)
    ap.add_argument("--tabela", action="store_true",
                    help="mostra a banda caixa/redondo por tamanho e proporção")
    ap.add_argument("--detalhe", default=None, metavar="PROP",
                    help="lista contorno a contorno o prop pedido")
    ap.add_argument("--filete", type=float, default=None, metavar="LARG",
                    help="varre o raio de filete numa caixa ideal desta "
                         "largura e diz a partir de quanto a régua o vê")
    args = ap.parse_args()

    if args.filete is not None:
        larg = args.filete
        raios = [f for f in (0.0, 0.5, 1.0, 1.5, 2.0, 3.0, 4.0, 6.0, 8.0)
                 if f < larg * 0.4]
        print("filete numa caixa ideal de %.0f px de largura:" % larg)
        print("  %6s %8s %8s" % ("raio", "f_eixo", "queda"))
        base = None
        for f, fe in varrer_filete(larg, larg * 1.4, raios, args.limiar):
            base = fe if base is None else base
            print("  %5.1fpx %8.3f %8.3f" % (f, fe, base - fe))
        return 0

    if args.detalhe:
        img = Image.open(os.path.join(args.pasta, args.detalhe + ".png"))
        alfa = np.asarray(img.convert("RGBA"), dtype=np.float32)[:, :, 3] / 255
        cs = contornos_medidos(alfa, args.limiar)
        print("%s — %d contornos" % (args.detalhe, len(cs)))
        print("  %10s %7s %7s %7s %7s %7s"
              % ("peça", "perim", "f_eixo", "caixa", "redondo", "indice"))
        for c in sorted(cs, key=lambda k: -k["perim"]):
            lo, hi, cil = banda(c["larg"], c["alt"], args.limiar)
            i = indice(c["larg"], c["alt"], c["f_eixo"], args.limiar)
            print("  %4.0fx%-5.0f %7.0f %7.3f %7.3f %7.3f %7s"
                  % (c["larg"], c["alt"], c["perim"], c["f_eixo"], hi, lo,
                     "--" if i is None else "%.3f" % i))
        return 0

    if args.tabela:
        print("banda entre a caixa ideal e a forma redonda, por peça:")
        print("  %9s %8s %9s %8s %7s" % ("peça", "caixa", "cilindro",
                                         "redondo", "banda"))
        for larg, prop in ((10, 1.4), (16, 1.4), (24, 1.4), (34, 1.4),
                           (50, 1.4), (70, 1.4), (100, 1.4),
                           (10, 3.5), (16, 3.5), (24, 3.5), (34, 3.5),
                           (50, 3.5), (70, 3.5)):
            lo, hi, cil = banda(larg, larg * prop, args.limiar)
            print("  %4.0fx%-4.0f %8.3f %9.3f %8.3f %7.3f"
                  % (larg, larg * prop, hi, cil, lo, hi - lo))
        print()

    linhas = []
    for arq in sorted(os.listdir(args.pasta)):
        if not arq.endswith(".png"):
            continue
        nome = arq[:-4]
        img = Image.open(os.path.join(args.pasta, arq)).convert("RGBA")
        alfa = np.asarray(img, dtype=np.float32)[:, :, 3] / 255.0
        rgba = np.asarray(img, dtype=np.float32) / 255.0
        cs = contornos_medidos(alfa, args.limiar)
        if not cs:
            print("  %-26s  sem contorno" % nome)
            continue
        li = linhas_internas(rgba, args.limiar)
        perim = sum(c["perim"] for c in cs)
        med = [(c, indice(c["larg"], c["alt"], c["f_eixo"], args.limiar))
               for c in cs]
        med = [(c, i) for c, i in med if i is not None]
        p_med = sum(c["perim"] for c, _ in med)
        idx = (sum(c["perim"] * i for c, i in med) / p_med) if p_med else None
        peso = np.array([c["perim"] for c in cs]) / perim
        mask = alfa >= args.limiar
        ys_i, xs_i = np.nonzero(mask)
        linhas.append({
            "nome": nome, "indice": idx,
            "f_eixo": float(sum(peso * np.array([c["f_eixo"] for c in cs]))),
            "f_reta": float(sum(peso * np.array([c["f_reta"] for c in cs]))),
            "maior_reta": max(c["maior_reta"] for c in cs),
            "maior_diag": max(c["diag"] for c in cs),
            "medivel": p_med / perim,
            "larg": int(xs_i.max() - xs_i.min() + 1),
            "alt": int(ys_i.max() - ys_i.min() + 1),
            "px": int(mask.sum()), "perim": perim, "pecas": len(cs),
            "e_eixo": None if li is None else li["e_eixo"],
        })

    com = sorted([r for r in linhas if r["indice"] is not None],
                 key=lambda r: -r["indice"])
    sem = sorted([r for r in linhas if r["indice"] is None],
                 key=lambda r: -r["maior_diag"])
    def _e(r):
        return "  --  " if r["e_eixo"] is None else "%6.3f" % r["e_eixo"]

    print("%-27s %6s %6s %6s %8s %9s %7s %5s %6s"
          % ("prop", "indice", "f_eixo", "linhas", "maior", "tamanho",
             "perim", "cont", "medív"))
    for r in com:
        print("%-27s %6.3f %6.3f %s %7.1fpx %4dx%-4d %7.0f %5d %5.0f%%"
              % (r["nome"], r["indice"], r["f_eixo"], _e(r),
                 r["maior_reta"], r["larg"], r["alt"], r["perim"], r["pecas"],
                 100 * r["medivel"]))
    if sem:
        print("\nA RÉGUA NÃO RESPONDE POR ESTES — nenhuma peça deles tem "
              "tamanho E proporção onde caixa e redondo se separem:")
        for r in sem:
            print("%-27s %6s %6.3f %s %7.1fpx %4dx%-4d %7.0f %5d %5.0f%%"
                  % (r["nome"], "--", r["f_eixo"], _e(r),
                     r["maior_reta"], r["larg"], r["alt"], r["perim"],
                     r["pecas"], 100 * r["medivel"]))

    if args.csv:
        with open(args.csv, "w", encoding="utf-8") as f:
            f.write("prop,indice,f_eixo,e_eixo,f_reta,maior_reta,maior_diag,"
                    "frac_medivel,larg,alt,px,perim,contornos\n")
            for r in com + sem:
                f.write("%s,%s,%.4f,%s,%.4f,%.2f,%.1f,%.3f,%d,%d,%d,%.1f,%d\n"
                        % (r["nome"],
                           "" if r["indice"] is None else "%.4f" % r["indice"],
                           r["f_eixo"],
                           "" if r["e_eixo"] is None else "%.4f" % r["e_eixo"],
                           r["f_reta"], r["maior_reta"],
                           r["maior_diag"], r["medivel"], r["larg"], r["alt"],
                           r["px"], r["perim"], r["pecas"]))
        print("\ncsv em %s" % args.csv)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
