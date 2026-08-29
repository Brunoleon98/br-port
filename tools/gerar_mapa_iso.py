#!/usr/bin/env python3
"""
BR Port — gerador do mapa do porto em projeção isométrica.

POR QUE UM GERADOR E NÃO SVG ESCRITO À MÃO
------------------------------------------
Em isométrico cada ponto do chão é uma conta:

    tela_x = CX + (mx - my) * MEIA_LARG
    tela_y = CY + (mx + my) * MEIA_ALT - altura

Escrever isso na mão é onde erro de meio pixel vira píer torto. Aqui o porto é
descrito em coordenadas de MUNDO e a projeção acontece num lugar só. Mudar o
ângulo é mudar duas constantes e regerar, não redesenhar tudo.

AS DUAS ARMADILHAS QUE ISTO RESOLVE
-----------------------------------
1. **A caixa de um plano isométrico é sempre 2:1.** Vale para qualquer formato
   de terreno — um cais comprido e fino projeta a mesma caixa 2:1 que um
   terreno quadrado. Num ecrã 720x1280 isso limitaria o chão a ~360px de
   altura. A saída é gerar o mundo MAIOR que o ecrã e cortar: o mapa transborda
   dos quatro lados e o jogador vê uma janela para dentro dele.

2. **Costa reta empurra as docas para o lado, não para baixo.** Com a costa
   toda no mesmo `mx`, cada doca seguinte anda ~8 unidades em `my`, e como
   `tela_x` depende de `(mx - my)`, elas marcham para a esquerda e saem do
   ecrã retrato. Por isso a costa aqui é em DEGRAUS: cada doca avança também
   em `mx`, e a marcha vira vertical. A regra é `Δmx > Δmy / 3`.

Uso:
    python3 tools/gerar_mapa_iso.py brport_vs/art/porto_mapa_iso.svg
"""

import sys

MEIA_LARG = 30
MEIA_ALT = 15            # a razão 2:1 com MEIA_LARG é o que define o ângulo
ALT_CAIS = 26            # altura do cais acima da água
ALT_PIER = 15            # o tabuado fica mais baixo que o cais

CX, CY = 452, 8
LARG, ALT = 720, 720

# Costa em degraus. Cada entrada: (my inicial, my final, mx da beira do cais).
# O salto de 4 em mx contra 8 em my é o que satisfaz Δmx > Δmy/3.
DEGRAUS = [(-6.0, 8.0, 6.0), (8.0, 16.0, 10.0), (16.0, 24.0, 14.0), (24.0, 34.0, 18.0)]
FUNDO_TERRA = -8.0       # o quanto a terra recua para trás (fora do ecrã)
PIER_ALCANCE = 4.5

# (my inicial, my final, mx da beira) de cada píer — alinhados aos degraus.
PIERES = [(2.0, 4.4, 6.0), (10.0, 12.4, 10.0), (18.0, 20.4, 14.0)]

C = {
    "agua": "#2b6f8c", "agua_funda": "#27647e", "agua_rasa": "#3d87a4",
    "cais_topo": "#b9c2c8", "cais_dir": "#76828a", "cais_esq": "#8e9aa2",
    "asfalto": "#6f7b85", "madeira": "#9a6438", "madeira_dir": "#633d20",
    "madeira_esq": "#7a4d2a", "telhado": "#c85420", "parede": "#eef2f5",
    "parede_dir": "#b3bfc7", "parede_esq": "#cfd8de", "verde": "#2d7a3a",
    "vidro": "#7fb6cc", "porta": "#5a3a20",
}


def p(mx: float, my: float, h: float = 0.0) -> tuple:
    return (CX + (mx - my) * MEIA_LARG, CY + (mx + my) * MEIA_ALT - h)


def poli(pontos, cor: str) -> str:
    return '  <polygon points="%s" fill="%s"/>\n' % (
        " ".join("%.1f,%.1f" % pt for pt in pontos), cor)


def laje(x0, y0, x1, y1, h, topo, dir_, esq) -> str:
    """Laje isométrica: as duas faces visíveis (+mx e +my) e o topo."""
    s = poli([p(x1, y0, h), p(x1, y1, h), p(x1, y1, 0), p(x1, y0, 0)], dir_)
    s += poli([p(x0, y1, h), p(x1, y1, h), p(x1, y1, 0), p(x0, y1, 0)], esq)
    s += poli([p(x0, y0, h), p(x1, y0, h), p(x1, y1, h), p(x0, y1, h)], topo)
    return s


def caixa(x0, y0, x1, y1, base, altura, topo, dir_, esq) -> str:
    t = base + altura
    s = poli([p(x1, y0, t), p(x1, y1, t), p(x1, y1, base), p(x1, y0, base)], dir_)
    s += poli([p(x0, y1, t), p(x1, y1, t), p(x1, y1, base), p(x0, y1, base)], esq)
    s += poli([p(x0, y0, t), p(x1, y0, t), p(x1, y1, t), p(x0, y1, t)], topo)
    return s


# As duas faces visíveis de um volume isométrico. Servem para pintar aberturas
# em cima de uma parede já desenhada, sem redesenhar o volume.
def face_mx(mx, my0, my1, z0, z1, cor) -> str:
    return poli([p(mx, my0, z1), p(mx, my1, z1), p(mx, my1, z0), p(mx, my0, z0)], cor)


def face_my(my, mx0, mx1, z0, z1, cor) -> str:
    return poli([p(mx0, my, z1), p(mx1, my, z1), p(mx1, my, z0), p(mx0, my, z0)], cor)


def predio(mx0, my0, mx1, my1, base, altura, telhado, telhado_dir, telhado_esq,
           janelas: int = 2) -> str:
    """Prédio com porta, janelas e telhado que sobressai.

    Antes eram caixas lisas com a face de cima pintada de telhado: à distância
    liam-se como blocos de cor. O que dá escala a um edifício é a ABERTURA —
    uma porta diz de que tamanho é a construção sem precisar de mais nada.
    """
    t = base + altura
    s = caixa(mx0, my0, mx1, my1, base, altura,
              C["parede"], C["parede_dir"], C["parede_esq"])

    # Porta na face +my (a que fica virada para o cais).
    meio = (mx0 + mx1) / 2
    s += face_my(my1, meio - 0.55, meio + 0.55, base, base + min(16, altura - 8),
                 C["porta"])

    # Janelas nas duas faces visíveis, distribuídas ao longo do vão.
    alt_j0, alt_j1 = base + altura * 0.52, base + altura * 0.78
    vao_y = (my1 - my0) / (janelas + 1)
    for i in range(1, janelas + 1):
        cy = my0 + vao_y * i
        s += face_mx(mx1, cy - 0.42, cy + 0.42, alt_j0, alt_j1, C["vidro"])
    vao_x = (mx1 - mx0) / (janelas + 1)
    for i in range(1, janelas + 1):
        cx = mx0 + vao_x * i
        if abs(cx - meio) < 0.75:
            continue                       # não abre janela em cima da porta
        s += face_my(my1, cx - 0.42, cx + 0.42, alt_j0, alt_j1, C["vidro"])

    # Telhado sobressaindo dos quatro lados — é o beiral que faz parecer coberto.
    s += caixa(mx0 - 0.3, my0 - 0.3, mx1 + 0.3, my1 + 0.3, t, 8,
               telhado, telhado_dir, telhado_esq)
    return s


def gerar(com_pieres: bool = True, com_coqueiros: bool = True) -> str:
    s = '<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d" viewBox="0 0 %d %d">\n' % (
        LARG, ALT, LARG, ALT)

    # ---- água ----
    s += '  <rect width="%d" height="%d" fill="%s"/>\n' % (LARG, ALT, C["agua"])
    for cx_, cy_, rx, ry in [(560, 90, 150, 90), (120, 430, 140, 90), (600, 620, 150, 85)]:
        s += '  <ellipse cx="%d" cy="%d" rx="%d" ry="%d" fill="%s"/>\n' % (
            cx_, cy_, rx, ry, C["agua_funda"])
    s += '  <g fill="none" stroke="%s" stroke-width="4" stroke-linecap="round">\n' % C["agua_rasa"]
    for ox, oy in [(500, 60), (620, 200), (80, 300), (560, 380), (60, 560),
                   (300, 660), (640, 500), (180, 120), (420, 690), (660, 90)]:
        s += '    <path d="M%d %d q9-6 18 0 q9 6 18 0"/>\n' % (ox, oy)
    s += '  </g>\n'

    # ---- terra, degrau por degrau (de trás para a frente) ----
    for my0, my1, borda in DEGRAUS:
        s += laje(FUNDO_TERRA, my0, borda, my1, ALT_CAIS,
                  C["cais_topo"], C["cais_dir"], C["cais_esq"])
        s += poli([p(FUNDO_TERRA, my0 + 0.5, ALT_CAIS), p(borda - 1.3, my0 + 0.5, ALT_CAIS),
                   p(borda - 1.3, my1 - 0.5, ALT_CAIS), p(FUNDO_TERRA, my1 - 0.5, ALT_CAIS)],
                  C["asfalto"])
        s += ('  <path d="M%.1f,%.1f L%.1f,%.1f" stroke="#e0a81f" '
              'stroke-width="2.5" fill="none"/>\n' % (
                  *p(borda - 0.9, my0 + 0.3, ALT_CAIS), *p(borda - 0.9, my1 - 0.3, ALT_CAIS)))

    # ---- píeres ----
    # Em jogo o píer TROCA DE ESTADO (vaga por construir -> píer construído), e
    # o que muda de estado não pode estar assado no fundo. Com --sem-pieres o
    # mapa sai só com água e terra, e as três vagas viram props posicionados
    # por cima — que é como o Main.tscn os usa.
    for my0, my1, borda in (PIERES if com_pieres else []):
        s += laje(borda, my0, borda + PIER_ALCANCE, my1, ALT_PIER,
                  C["madeira"], C["madeira_dir"], C["madeira_esq"])
        for i in range(1, 6):
            mx = borda + (PIER_ALCANCE / 6) * i
            s += ('  <path d="M%.1f,%.1f L%.1f,%.1f" stroke="%s" '
                  'stroke-width="1.8" fill="none"/>\n' % (
                      *p(mx, my0, ALT_PIER), *p(mx, my1, ALT_PIER), C["madeira_dir"]))
        for my in (my0 + 0.3, my1 - 0.3):
            s += caixa(borda + 0.2, my - 0.16, borda + 0.55, my + 0.16,
                       ALT_PIER, 9, "#4a535a", "#2b3238", "#3c4348")

    # ---- prédios no pátio, de trás para a frente ----
    B = ALT_CAIS
    s += predio(-1.0, -3.5, 3.0, 0.5, B, 34, C["telhado"], "#8f3822", "#a8452a")
    s += predio(2.0, 5.0, 6.4, 9.4, B, 44, "#3f6f4a", "#2a4d33", "#335c3d", 3)
    s += predio(6.0, 13.0, 10.4, 17.4, B, 32, C["telhado"], "#8f3822", "#a8452a")
    s += predio(10.0, 21.0, 14.4, 25.4, B, 30, "#3f6f4a", "#2a4d33", "#335c3d")

    cores = [("#c23030", "#7a1a1a", "#8f2020"), ("#2f74b0", "#1d4a75", "#245a8c"),
             ("#e0a81f", "#9c7a15", "#b8901a"), ("#2d7a3a", "#19512d", "#1f6236")]
    k = 0
    for mx, my in [(2.4, 1.6), (3.9, 1.6), (6.2, 10.4), (7.7, 10.4),
                   (10.2, 18.4), (11.7, 18.4), (1.0, 12.0), (5.0, 20.0)]:
        c = cores[k % len(cores)]
        s += caixa(mx, my, mx + 1.2, my + 1.6, B, 13, c[0], c[1], c[2])
        k += 1

    # Coqueiros chapados: só saem quando --sem-coqueiros. Eles viraram props
    # low-poly com copa e tronco SEPARADOS, porque o que balança não pode
    # estar assado no fundo — a mesma razão que tirou os píeres daqui.
    for mx, my in ([] if not com_coqueiros else
                   [(-4.0, -2.0), (-3.0, 6.0), (0.0, 14.0), (3.0, 22.0), (7.0, 29.0)]):
        bx, by = p(mx, my, ALT_CAIS)
        s += '  <path d="M%.1f,%.1f l0,-22" stroke="#7a4d2a" stroke-width="4"/>\n' % (bx, by)
        s += '  <g transform="translate(%.1f,%.1f)">\n' % (bx, by - 22)
        for ang in range(0, 360, 51):
            s += ('    <ellipse rx="6" ry="14" cy="-11" fill="%s" '
                  'transform="rotate(%d)"/>\n' % (C["verde"], ang))
        s += '  </g>\n'

    s += "</svg>\n"
    return s


def main() -> int:
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    com_pieres = "--sem-pieres" not in sys.argv
    com_coqueiros = "--sem-coqueiros" not in sys.argv
    destino = args[0] if args else "porto_mapa_iso.svg"
    conteudo = gerar(com_pieres, com_coqueiros)      # gerar ANTES de abrir: open(...,"w")
    with open(destino, "w", encoding="utf-8") as f:   # trunca de imediato, e um
        f.write(conteudo)                             # erro deixaria o mapa vazio
    print("%s — %dx%d, chão transbordando de propósito (o ecrã é a janela)%s" % (
        destino, LARG, ALT, ("" if com_pieres else "  [SEM os píeres]")
        + ("" if com_coqueiros else "  [SEM os coqueiros]")))

    # O centro de cada píer no chão. É por aqui que o Main.tscn ancora o prop:
    # o render mira a origem do chão, então o canto do TextureRect é este ponto
    # menos meio quadro.
    print("\nCentro de cada píer, em pixels do mapa (h=0):")
    for i, (my0, my1, borda) in enumerate(PIERES):
        x, y = p(borda + PIER_ALCANCE / 2, (my0 + my1) / 2, 0)
        print("  Vaga %d: (%.0f, %.0f)" % (i + 1, x, y))

    print("\nAncoras de barco (centro, encostado em cada píer):")
    for i, (my0, my1, borda) in enumerate(PIERES):
        x, y = p(borda + PIER_ALCANCE / 2, my1 + 1.6, 0)
        print("  Doca %d: (%.0f, %.0f)" % (i + 1, x, y))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
