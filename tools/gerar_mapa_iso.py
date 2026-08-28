#!/usr/bin/env python3
"""
BR Port — gerador do mapa do porto em projeção isométrica.

POR QUE UM GERADOR E NÃO SVG ESCRITO À MÃO
------------------------------------------
Em isométrico, cada ponto do chão vira uma conta:

    tela_x = cx + (mundo_x - mundo_y) * MEIA_LARG
    tela_y = cy + (mundo_x + mundo_y) * MEIA_ALT

Escrever isso na mão é onde erro de meio pixel vira píer torto. Aqui o mapa é
descrito em COORDENADAS DE MUNDO (que doca fica em que posição da costa) e a
projeção é feita uma vez, num lugar só. Mudar o ângulo é mudar MEIA_LARG /
MEIA_ALT e regerar — não redesenhar tudo.

A CONSEQUÊNCIA QUE ISSO REVELA
------------------------------
A caixa que envolve um plano isométrico é SEMPRE 2:1 — largura = 2 x altura,
qualquer que seja o formato do terreno, porque os dois eixos abrem em leque a
partir do mesmo ponto. Num ecrã retrato de 720x1280 isso significa que o chão
jogável nunca passa de ~360px de altura se ocupar os 720 de largura. É por
isso que todo mockup isométrico de porto é quadrado.

Uso:
    python3 tools/gerar_mapa_iso.py brport_vs/art/porto_mapa_iso.svg
"""

import sys

MEIA_LARG = 18          # metade da largura do losango de um tile
MEIA_ALT = 9            # metade da altura — a razão 2:1 é o que define o ângulo
ESPESSURA_CAIS = 15     # altura do cais acima da água
ESPESSURA_PIER = 9      # o tabuado fica mais baixo que o cais

CX, CY = 532, 260
LARG, ALT = 720, 740

# Mundo: x = distância para dentro da terra, y = ao longo da costa.
TERRA_X, TERRA_Y = 10, 24
PIERES = [(3.0, 5.4), (10.0, 12.4), (17.0, 19.4)]   # faixas de y de cada píer
PIER_ALCANCE = 4.2                                   # o quanto avança na água

C = {
    "agua": "#2b6f8c", "agua_funda": "#27647e", "agua_rasa": "#3d87a4",
    "cais_topo": "#b9c2c8", "cais_dir": "#8e9aa2", "cais_esq": "#76828a",
    "asfalto": "#6f7b85", "faixa": "#98a3aa",
    "madeira": "#9a6438", "madeira_dir": "#7a4d2a", "madeira_esq": "#633d20",
    "telhado": "#c85420", "parede": "#eef2f5", "parede_dir": "#cfd8de",
    "parede_esq": "#b3bfc7", "verde": "#2d7a3a", "areia": "#edd9b0",
}


def p(wx: float, wy: float, h: float = 0.0) -> tuple:
    return (CX + (wx - wy) * MEIA_LARG, CY + (wx + wy) * MEIA_ALT - h)


def poli(pontos, cor: str, extra: str = "") -> str:
    d = " ".join("%.1f,%.1f" % pt for pt in pontos)
    return '  <polygon points="%s" fill="%s"%s/>\n' % (d, cor, extra)


def laje(x0, y0, x1, y1, h, topo, dir_, esq) -> str:
    """Uma laje isométrica: face direita, face esquerda e o topo."""
    s = poli([p(x1, y0, h), p(x1, y1, h), p(x1, y1, 0), p(x1, y0, 0)], dir_)
    s += poli([p(x0, y1, h), p(x1, y1, h), p(x1, y1, 0), p(x0, y1, 0)], esq)
    s += poli([p(x0, y0, h), p(x1, y0, h), p(x1, y1, h), p(x0, y1, h)], topo)
    return s


def caixa(x0, y0, x1, y1, base, altura, topo, dir_, esq) -> str:
    """Um prédio: mesma laje, mas levantada do chão."""
    t = base + altura
    s = poli([p(x1, y0, t), p(x1, y1, t), p(x1, y1, base), p(x1, y0, base)], dir_)
    s += poli([p(x0, y1, t), p(x1, y1, t), p(x1, y1, base), p(x0, y1, base)], esq)
    s += poli([p(x0, y0, t), p(x1, y0, t), p(x1, y1, t), p(x0, y1, t)], topo)
    return s


def gerar() -> str:
    s = '<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d" viewBox="0 0 %d %d">\n' % (
        LARG, ALT, LARG, ALT)

    # ---- água ----
    s += '  <rect width="%d" height="%d" fill="%s"/>\n' % (LARG, ALT, C["agua"])
    for cx_, cy_, rx, ry in [(600, 120, 130, 80), (150, 760, 150, 90), (620, 880, 120, 70)]:
        s += '  <ellipse cx="%d" cy="%d" rx="%d" ry="%d" fill="%s"/>\n' % (
            cx_, cy_, rx, ry, C["agua_funda"])
    s += '  <g fill="none" stroke="%s" stroke-width="4" stroke-linecap="round">\n' % C["agua_rasa"]
    for ox, oy in [(90, 150), (260, 90), (470, 130), (630, 300), (120, 560),
                   (250, 900), (450, 940), (640, 700), (80, 380), (600, 520)]:
        s += '    <path d="M%d %d q9-6 18 0 q9 6 18 0"/>\n' % (ox, oy)
    s += '  </g>\n'

    # ---- terra: o cais, uma laje só ----
    s += laje(0, 0, TERRA_X, TERRA_Y, ESPESSURA_CAIS,
              C["cais_topo"], C["cais_dir"], C["cais_esq"])

    # pátio de asfalto sobre o cais (recuado da borda, que fica de concreto)
    s += poli([p(1.2, 0.8, ESPESSURA_CAIS), p(TERRA_X, 0.8, ESPESSURA_CAIS),
               p(TERRA_X, TERRA_Y - 0.8, ESPESSURA_CAIS), p(1.2, TERRA_Y - 0.8, ESPESSURA_CAIS)],
              C["asfalto"])

    # faixa amarela de segurança na beira
    s += '  <path d="M%.1f,%.1f L%.1f,%.1f" stroke="#e0a81f" stroke-width="2.5" fill="none"/>\n' % (
        *p(0.9, 0.4, ESPESSURA_CAIS), *p(0.9, TERRA_Y - 0.4, ESPESSURA_CAIS))

    # faixa de areia atrás do pátio
    s += poli([p(TERRA_X, 0, ESPESSURA_CAIS), p(TERRA_X + 1.6, 0, ESPESSURA_CAIS),
               p(TERRA_X + 1.6, TERRA_Y, ESPESSURA_CAIS), p(TERRA_X, TERRA_Y, ESPESSURA_CAIS)],
              C["areia"])

    # ---- píeres, de trás para a frente ----
    for y0, y1 in PIERES:
        s += laje(-PIER_ALCANCE, y0, 0, y1, ESPESSURA_PIER,
                  C["madeira"], C["madeira_dir"], C["madeira_esq"])
        # tábuas
        n = 6
        for i in range(1, n):
            wx = -PIER_ALCANCE + (PIER_ALCANCE / n) * i
            s += '  <path d="M%.1f,%.1f L%.1f,%.1f" stroke="%s" stroke-width="1.6" fill="none"/>\n' % (
                *p(wx, y0, ESPESSURA_PIER), *p(wx, y1, ESPESSURA_PIER), C["madeira_dir"])
        # cabeços
        for wy in (y0 + 0.25, y1 - 0.25):
            s += poli([p(-0.5, wy - 0.14, ESPESSURA_PIER + 7), p(-0.2, wy - 0.14, ESPESSURA_PIER + 7),
                       p(-0.2, wy + 0.14, ESPESSURA_PIER + 7), p(-0.5, wy + 0.14, ESPESSURA_PIER + 7)],
                      "#3c4348")
            s += poli([p(-0.2, wy - 0.14, ESPESSURA_PIER + 7), p(-0.2, wy + 0.14, ESPESSURA_PIER + 7),
                       p(-0.2, wy + 0.14, ESPESSURA_PIER), p(-0.2, wy - 0.14, ESPESSURA_PIER)],
                      "#2b3238")

    # ---- prédios, de trás para a frente (menor wx+wy primeiro) ----
    B = ESPESSURA_CAIS
    # armazém ao fundo
    s += caixa(6.2, 1.4, 9.4, 5.2, B, 30, C["telhado"], "#a8452a", "#8f3822")
    # escritório
    s += caixa(5.6, 8.0, 9.2, 12.0, B, 38, C["parede"], C["parede_dir"], C["parede_esq"])
    s += poli([p(5.6, 8.0, B + 38), p(9.2, 8.0, B + 38),
               p(9.2, 12.0, B + 38), p(5.6, 12.0, B + 38)], C["telhado"])
    # galpão da frente
    s += caixa(6.0, 15.0, 9.4, 19.4, B, 26, C["telhado"], "#a8452a", "#8f3822")

    # pilhas de contêiner no pátio
    cores = [("#c23030", "#8f2020", "#7a1a1a"), ("#2f74b0", "#245a8c", "#1d4a75"),
             ("#e0a81f", "#b8901a", "#9c7a15"), ("#2d7a3a", "#1f6236", "#19512d")]
    k = 0
    for wy in (2.2, 4.0, 13.2, 15.0, 20.4):
        for wx in (2.4, 3.7):
            c = cores[k % len(cores)]
            s += caixa(wx, wy, wx + 1.1, wy + 1.5, B, 11, c[0], c[1], c[2])
            k += 1

    # coqueiros na faixa de areia
    for wy in (1.0, 6.0, 11.0, 16.0, 21.5):
        bx, by = p(TERRA_X + 0.8, wy, ESPESSURA_CAIS)
        s += '  <path d="M%.1f,%.1f l0,-16" stroke="#7a4d2a" stroke-width="3.5"/>\n' % (bx, by)
        s += '  <g transform="translate(%.1f,%.1f)">\n' % (bx, by - 16)
        for ang in range(0, 360, 51):
            s += ('    <ellipse rx="4.5" ry="11" cy="-9" fill="%s" '
                  'transform="rotate(%d)"/>\n' % (C["verde"], ang))
        s += '  </g>\n'

    s += "</svg>\n"
    return s


def main() -> int:
    destino = sys.argv[1] if len(sys.argv) > 1 else "porto_mapa_iso.svg"
    open(destino, "w", encoding="utf-8").write(gerar())

    xs = [p(wx, wy)[0] for wx in (-PIER_ALCANCE, TERRA_X + 1.6) for wy in (0, TERRA_Y)]
    ys = [p(wx, wy)[1] for wx in (-PIER_ALCANCE, TERRA_X + 1.6) for wy in (0, TERRA_Y)]
    larg, alt = max(xs) - min(xs), max(ys) - min(ys)
    print("%s — chão isométrico %.0f x %.0f px (razão %.2f:1)" % (destino, larg, alt, larg / alt))
    print("  x de %.0f a %.0f · y de %.0f a %.0f" % (min(xs), max(xs), min(ys), max(ys)))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
