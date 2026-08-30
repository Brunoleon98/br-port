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

import random
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
COSTURA = 0.06           # sobreposição entre degraus (ver `gerar`)
PIER_ALCANCE = 4.5

# (my inicial, my final, mx da beira) de cada píer — alinhados aos degraus.
PIERES = [(2.0, 4.4, 6.0), (10.0, 12.4, 10.0), (18.0, 20.4, 14.0)]

C = {
    "agua": "#2b6f8c", "agua_funda": "#1d4f68", "agua_media": "#33789a",
    "agua_rasa": "#4a96b4", "agua_baixio": "#63aec7", "espuma": "#b6dcea",
    "pedra": "#5a666b", "pedra_clara": "#7c888e", "pedra_media": "#6b767b",
    "sombra_agua": "#12384c",
    "cais_topo": "#b9c2c8", "cais_dir": "#76828a", "cais_esq": "#8e9aa2",
    "cais_junta": "#9aa5ac", "cais_mancha": "#a8b2b8",
    "asfalto": "#6f7b85", "madeira": "#9a6438", "madeira_dir": "#633d20",
    "madeira_esq": "#7a4d2a", "telhado": "#c85420", "parede": "#eef2f5",
    "parede_dir": "#b3bfc7", "parede_esq": "#cfd8de", "verde": "#2d7a3a",
    "vidro": "#7fb6cc", "porta": "#5a3a20", "terra": "#8a7a63",
    "terra_clara": "#9c8b71", "terra_escura": "#75664f", "poca": "#6b6f66",
    "mato": "#5c7343", "asfalto_claro": "#7d8993", "asfalto_escuro": "#616c76",
    "tinta": "#e0a81f",
}


def p(mx: float, my: float, h: float = 0.0) -> tuple:
    return (CX + (mx - my) * MEIA_LARG, CY + (mx + my) * MEIA_ALT - h)


def contorno_costa() -> list:
    """Os vértices (mx, my) da linha que separa terra de água, em ordem de my.

    A costa é uma ESCADA, não uma diagonal. Cada degrau avança 4 em `mx` e
    8 em `my` (ver o cabeçalho), e entre um e o seguinte há uma quina de
    verdade: primeiro o muro do degrau atual, depois o espelho que liga ao
    muro do próximo. Descrever isso como uma linha só é o que faz tudo o que
    acompanha a margem — faixa de profundidade, enrocamento, espuma — virar a
    esquina junto com ela.
    """
    v = [(DEGRAUS[0][2], DEGRAUS[0][0])]
    for i, (_, my1, borda) in enumerate(DEGRAUS):
        v.append((borda, my1))
        if i + 1 < len(DEGRAUS):
            v.append((DEGRAUS[i + 1][2], my1))
    return v


def costa_deslocada(d: float) -> list:
    """O contorno da costa empurrado `d` unidades para dentro da ÁGUA.

    Cada tipo de segmento tem a água de um lado diferente: num muro (mx
    constante) a água está no +mx; num espelho de degrau (my constante) ela
    está no -my, porque o degrau seguinte é mais largo e come o +my.

    Era exatamente isto que faltava. A versão anterior empurrava tudo em +mx
    e tratava cada degrau como uma faixa solta: nas quinas a faixa entrava
    pelo cais adentro, e o enrocamento aparecia como cascalho pintado em cima
    do concreto — o "textura de pedra por cima do mapa" reportado no playtest.
    """
    v = contorno_costa()
    ponta = len(v) - 1
    return [(mx + d, my if i in (0, ponta) else my - d)
            for i, (mx, my) in enumerate(v)]


def andar_costa(d: float, passo: tuple, r: random.Random):
    """Percorre a linha de água a `d` da terra, a passos irregulares.

    Devolve (mx, my, normal, tangente) — a normal aponta para o mar, e é ela
    que garante que nada do que se espalha por aqui caia do lado da terra.
    """
    v = costa_deslocada(d)
    for i in range(len(v) - 1):
        (x0, y0), (x1, y1) = v[i], v[i + 1]
        muro = abs(x1 - x0) < 1e-6
        normal = (1.0, 0.0) if muro else (0.0, -1.0)
        tangente = (0.0, 1.0) if muro else (1.0, 0.0)
        comprimento = abs(y1 - y0) if muro else abs(x1 - x0)
        andado = 0.0
        while andado < comprimento:
            f = andado / comprimento
            yield (x0 + (x1 - x0) * f, y0 + (y1 - y0) * f, normal, tangente)
            andado += r.uniform(*passo)


def costa(de: float, ate: float) -> list:
    """Os pontos de uma faixa que acompanha a costa em degraus.

    A costa não é reta — cada doca avança também em `mx` (ver o cabeçalho).
    Uma elipse solta na água não sabe disso e por isso nunca pareceu praia:
    faixa de profundidade tem de SEGUIR a linha da terra, e é isso que faz o
    olho ler "isto é uma margem" em vez de "isto é uma mancha".
    """
    perto = [p(mx, my) for mx, my in costa_deslocada(de)]
    longe = [p(mx, my) for mx, my in costa_deslocada(ate)]
    return perto + list(reversed(longe))


# ── NÚMERO DA DOCA, PINTADO NO CAIS ──────────────────────────────────────
# Os nomes das docas eram Labels brancos flutuando por cima do mapa: liam-se
# como legenda de diagrama, não como porto. Numa doca de verdade o número está
# PINTADO NO CHÃO, para ser lido de dentro do navio — então é isso que ele é
# aqui, e o cartão da doca lá embaixo é que diz "DOCA 1" por extenso.
#
# Por que estêncil e não uma fonte: o importador de SVG do Godot é o ThorVG,
# que não desenha <text>. Um dígito escrito com fonte sairia vazio no jogo.
# Três dígitos como polígonos custam vinte linhas e ainda dão o traço grosso e
# chapado que a tinta de piso tem de verdade.

# Cada dígito numa caixa de 6x10, y para baixo. Barras = (x0, y0, x1, y1).
DIGITOS = {
    "1": [(2.2, 0.0, 3.8, 10.0), (0.8, 8.4, 5.2, 10.0), (0.9, 1.3, 2.2, 2.6)],
    "2": [(0.0, 0.0, 6.0, 1.6), (4.4, 1.2, 6.0, 4.8), (0.0, 4.0, 6.0, 5.6),
          (0.0, 5.2, 1.6, 8.8), (0.0, 8.4, 6.0, 10.0)],
    "3": [(0.0, 0.0, 6.0, 1.6), (4.4, 0.0, 6.0, 10.0), (1.4, 4.2, 6.0, 5.8),
          (0.0, 8.4, 6.0, 10.0)],
}


def pintura_doca(digito: str, mx0: float, my0: float, altura: float,
                 cor: str, opacidade: float) -> str:
    """Um dígito deitado no plano do chão, para ser lido da água.

    O eixo do texto acompanha a beira do cais (-my sobe para a direita) e a
    altura das letras cai para dentro da terra (+mx). Não há rotação que
    resolva isto: um plano isométrico precisa de CISALHAMENTO, e é por isso que
    a conta vive aqui e não num nó de interface.
    """
    escala = altura / 10.0
    out = []
    for x0, y0, x1, y1 in DIGITOS[digito]:
        # (u ao longo de -my, v ao longo de +mx), ambos em unidades de mundo.
        quina = []
        for u, v in [(x0, y0), (x1, y0), (x1, y1), (x0, y1)]:
            quina.append(p(mx0 + v * escala, my0 - u * escala, ALT_CAIS))
        out.append('  <polygon points="%s" fill="%s" opacity="%.2f"/>\n'
                   % (" ".join("%.1f,%.1f" % q for q in quina), cor, opacidade))
    return "".join(out)


SEMENTE_CHAO = 20260829   # fixo: o mapa tem de sair igual toda vez


def manchas_chao(indice: int, mx0: float, my0: float, mx1: float, my1: float,
                 pavimentado: bool) -> str:
    """Quebra a chapa de cor do pátio com manchas rentes ao chão.

    Uma cor chapada de 700x300px não lê como terreno, lê como preenchimento —
    e era isso que fazia o pátio parecer um recorte por baixo dos prédios.

    Duas regras que valem para qualquer mancha aqui:

    1. **Mancha no chão é elipse 2:1**, não círculo. Um disco desenhado no
       plano do chão projeta achatado igual ao resto do mundo; um círculo em
       coordenadas de ecrã flutua por cima da cena.
    2. **Recortar no polígono do pátio.** Sem `clip-path` a mancha transborda
       para a beira do cais e a laje deixa de ter aresta.
    """
    r = random.Random(SEMENTE_CHAO + indice)
    ident = "patio%d" % indice
    quina = [p(mx0, my0, ALT_CAIS), p(mx1, my0, ALT_CAIS),
             p(mx1, my1, ALT_CAIS), p(mx0, my1, ALT_CAIS)]
    out = ['  <clipPath id="%s"><polygon points="%s"/></clipPath>\n' % (
        ident, " ".join("%.1f,%.1f" % q for q in quina))]
    out.append('  <g clip-path="url(#%s)">\n' % ident)

    # A opacidade do asfalto é MENOR que a da terra de propósito: os dois tons
    # de cinza contrastam mais entre si que os dois de terra, e na primeira
    # tentativa (mesma opacidade para os dois) o pátio pavimentado saiu com
    # bolinhas em vez de remendo. Faixa de raio larga pelo mesmo motivo —
    # mancha toda do mesmo tamanho lê como padrão, não como desgaste.
    if pavimentado:
        paleta = [(C["asfalto_escuro"], 0.34), (C["asfalto_claro"], 0.24)]
    else:
        paleta = [(C["terra_escura"], 0.50), (C["terra_clara"], 0.45),
                  (C["poca"], 0.35)]
    for _ in range(16):
        cor, opac = paleta[r.randrange(len(paleta))]
        cx, cy = p(r.uniform(mx0, mx1), r.uniform(my0, my1), ALT_CAIS)
        raio = r.uniform(10.0, 55.0)
        out.append('    <ellipse cx="%.0f" cy="%.0f" rx="%.0f" ry="%.0f" '
                   'fill="%s" opacity="%.2f"/>\n'
                   % (cx, cy, raio, raio / 2.0, cor, opac))

    if pavimentado:
        # Rachaduras: linha quebrada rente ao chão, não risco sobre a imagem.
        for _ in range(5):
            mx, my = r.uniform(mx0, mx1), r.uniform(my0, my1)
            pts = [p(mx, my, ALT_CAIS)]
            for _ in range(3):
                mx += r.uniform(-1.1, 1.1)
                my += r.uniform(-1.1, 1.1)
                pts.append(p(mx, my, ALT_CAIS))
            out.append('    <polyline points="%s" fill="none" stroke="#4e5860" '
                       'stroke-width="1.6" opacity="0.5"/>\n'
                       % " ".join("%.1f,%.1f" % q for q in pts))
    else:
        # Cascalho: o pátio de terra batida é chão de obra, não jardim.
        for _ in range(60):
            gx, gy = p(r.uniform(mx0, mx1), r.uniform(my0, my1), ALT_CAIS)
            raio = r.uniform(1.6, 3.4)
            out.append('    <ellipse cx="%.0f" cy="%.0f" rx="%.1f" ry="%.1f" '
                       'fill="#6d6152" opacity="0.5"/>\n'
                       % (gx, gy, raio, raio * 0.55))

        # Mato nas frestas: o pátio de terra é o porto PARADO, e mato é o que
        # cresce onde ninguém passa.
        #
        # A primeira versão eram três riscos retos saindo de um ponto, com 9px
        # de altura e traço grosso. Espalhados um a um pelo pátio leram como
        # SETAS verdes, não como planta. O que corrige é tufo e escala: folha
        # CURVA, baixa, fina, várias juntas — mato aparece em moita, e é a
        # moita que o olho reconhece.
        for _ in range(11):
            cmx, cmy = r.uniform(mx0, mx1), r.uniform(my0, my1)
            for _ in range(r.randint(4, 7)):
                tx, ty = p(cmx + r.uniform(-0.5, 0.5),
                           cmy + r.uniform(-0.5, 0.5), ALT_CAIS)
                dx = r.uniform(-3.5, 3.5)
                alt = r.uniform(4.0, 7.0)
                out.append('    <path d="M%.0f %.0f q%.1f %.1f %.1f %.1f" '
                           'stroke="%s" stroke-width="1.3" fill="none" '
                           'stroke-linecap="round" opacity="0.7"/>\n'
                           % (tx, ty, dx * 0.25, -alt * 0.7, dx, -alt, C["mato"]))
    out.append('  </g>\n')
    return "".join(out)


def poli(pontos, cor: str, opacidade: float = 1.0) -> str:
    extra = "" if opacidade >= 1.0 else ' opacity="%.2f"' % opacidade
    return '  <polygon points="%s" fill="%s"%s/>\n' % (
        " ".join("%.1f,%.1f" % pt for pt in pontos), cor, extra)


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


def gerar(com_pieres: bool = True, com_coqueiros: bool = True,
          com_predios: bool = True, com_pavimento: bool = True) -> str:
    s = '<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d" viewBox="0 0 %d %d">\n' % (
        LARG, ALT, LARG, ALT)

    # ---- água: rampa de profundidade a partir da costa ----
    # Do mais fundo (fundo do ecrã) para o mais raso (encostado na terra), cada
    # faixa por cima da anterior.
    # O BAIXIO acompanha a costa em degraus e tem aresta dura — é raso, e raso
    # tem contorno. O FUNDO não: a primeira versão punha o mar aberto também
    # como faixa em degraus, e a aresta dela cortava a água ao meio numa
    # diagonal reta que lia como falha de desenho. Longe da praia a
    # profundidade não copia o formato da costa, então ali vai degradê.
    #
    # O eixo do degradê é perpendicular, NA TELA, às linhas de mx constante
    # (direção (-MEIA_LARG, MEIA_ALT)) — assim as faixas de cor saem
    # paralelas à costa em vez de tortas em relação a ela.
    nx, ny = MEIA_ALT, 2.0 * MEIA_ALT
    norma = (nx * nx + ny * ny) ** 0.5
    ini = p(12.0, 12.0)
    alcance = (22.0 * MEIA_LARG * nx + 22.0 * MEIA_ALT * ny) / norma
    fim = (ini[0] + alcance * nx / norma, ini[1] + alcance * ny / norma)
    s += ('  <defs><linearGradient id="fundo" gradientUnits="userSpaceOnUse" '
          'x1="%.0f" y1="%.0f" x2="%.0f" y2="%.0f">'
          '<stop offset="0" stop-color="%s"/>'
          '<stop offset="1" stop-color="%s"/>'
          '</linearGradient></defs>\n'
          % (ini[0], ini[1], fim[0], fim[1], C["agua"], C["agua_funda"]))
    s += '  <rect width="%d" height="%d" fill="url(#fundo)"/>\n' % (LARG, ALT)
    for de, ate, cor in [(0.0, 6.0, C["agua_media"]),
                         (0.0, 2.6, C["agua_rasa"]),
                         (0.0, 1.0, C["agua_baixio"])]:
        s += poli(costa(de, ate), cor)

    # Ondulação: acompanha a costa em vez de ser espalhada ao acaso, e rareia
    # para o mar aberto — é assim que a água mostra de que lado fica a terra.
    s += '  <g fill="none" stroke="%s" stroke-width="3" stroke-linecap="round" opacity="0.55">\n' % C["espuma"]
    for my0, my1, borda in DEGRAUS:
        for dmx, dmy in [(2.0, 1.4), (4.6, 3.6), (3.1, 5.9), (6.8, 2.2),
                         (5.4, 6.8), (8.6, 4.6), (11.0, 1.8), (9.4, 6.2)]:
            if my0 + dmy > my1:
                continue
            wx, wy = p(borda + dmx, my0 + dmy)
            s += '    <path d="M%.0f %.0f q8-5 16 0 q8 5 16 0"/>\n' % (wx - 16, wy)
    s += '  </g>\n'

    # Mar aberto: mais fraco e mais espaçado. Sem isto o canto fundo do ecrã
    # fica um bloco de azul sem nada — água parada não é água, é fundo.
    s += ('  <g fill="none" stroke="%s" stroke-width="3" stroke-linecap="round" '
          'opacity="0.20">\n' % C["espuma"])
    ro = random.Random(SEMENTE_CHAO + 7)
    for my0, my1, borda in DEGRAUS:
        for _ in range(7):
            wx, wy = p(borda + ro.uniform(13.0, 30.0), ro.uniform(my0, my1 + 6.0))
            s += '    <path d="M%.0f %.0f q8-5 16 0 q8 5 16 0"/>\n' % (wx - 16, wy)
    s += '  </g>\n'

    # ---- terra, degrau por degrau (de trás para a frente) ----
    # O `+ COSTURA` no my1: duas lajes que encostam exatamente no mesmo my
    # deixam meio pixel de fundo entre elas, e na tela isso vira uma linha
    # escura pontilhada atravessando o cais. Como o degrau seguinte é
    # desenhado por cima, esticar um triz o anterior fecha a fresta sem
    # mudar nada do que se vê.
    for i, (my0, my1, borda) in enumerate(DEGRAUS):
        s += laje(FUNDO_TERRA, my0, borda, my1 + COSTURA, ALT_CAIS,
                  C["cais_topo"], C["cais_dir"], C["cais_esq"])
        # Pátio: terra batida no início, asfalto com faixa depois de pavimentado.
        s += poli([p(FUNDO_TERRA, my0 + 0.5, ALT_CAIS), p(borda - 1.3, my0 + 0.5, ALT_CAIS),
                   p(borda - 1.3, my1 - 0.5, ALT_CAIS), p(FUNDO_TERRA, my1 - 0.5, ALT_CAIS)],
                  C["asfalto"] if com_pavimento else C["terra"])
        s += manchas_chao(i, FUNDO_TERRA, my0 + 0.5, borda - 1.3, my1 - 0.5,
                          com_pavimento)
        if com_pavimento:
            s += ('  <path d="M%.1f,%.1f L%.1f,%.1f" stroke="#e0a81f" '
                  'stroke-width="2.5" fill="none"/>\n' % (
                      *p(borda - 0.9, my0 + 0.3, ALT_CAIS), *p(borda - 0.9, my1 - 0.3, ALT_CAIS)))

    # ---- concreto do cais: juntas e desgaste ----
    # O cais era a única superfície ainda 100% chapada da cena — pátio já tem
    # manchas, água já tem faixas. Junta de dilatação resolve duas coisas de
    # uma vez: quebra a chapa E dá escala, porque o olho conhece o tamanho de
    # uma placa de concreto e usa isso para medir o resto do porto.
    rc = random.Random(SEMENTE_CHAO + 40)
    for my0, my1, borda in DEGRAUS:
        for _ in range(9):
            cx, cy = p(rc.uniform(FUNDO_TERRA, borda), rc.uniform(my0, my1), ALT_CAIS)
            raio = rc.uniform(16.0, 40.0)
            s += ('  <ellipse cx="%.0f" cy="%.0f" rx="%.0f" ry="%.0f" fill="%s" '
                  'opacity="0.35"/>\n' % (cx, cy, raio, raio / 2.0, C["cais_mancha"]))
        # A junta vive na FAIXA DE CONCRETO que sobra entre o pátio e a beira
        # (o pátio come até `borda - 1.3`). Levá-la mais para dentro riscava a
        # terra batida, que não tem junta nenhuma.
        my = my0 + 1.2
        while my < my1 - 0.3:
            s += ('  <path d="M%.1f,%.1f L%.1f,%.1f" stroke="%s" stroke-width="1.8" '
                  'opacity="0.85" fill="none"/>\n'
                  % (*p(borda - 1.25, my, ALT_CAIS), *p(borda, my, ALT_CAIS),
                     C["cais_junta"]))
            my += 1.9

    # ---- número de cada doca, pintado na faixa de concreto ----
    # Vai DEPOIS da junta e da faixa amarela porque tinta de piso é a última
    # camada a ser aplicada — e porque assim o dígito não sai riscado ao meio.
    for i, (my0, my1, borda) in enumerate(PIERES):
        s += pintura_doca(str(i + 1), borda - 1.20, (my0 + my1) / 2.0 - 0.20,
                          1.05, C["tinta"], 0.90)

    # ---- pé do cais: sombra do muro, enrocamento e espuma ----
    # Sem isto o cais encontra a água numa aresta limpa, que é o que fazia a
    # margem parecer recortada em papel.
    #
    # A primeira tentativa foi uma FAIXA chapada de cinza com seixos regulares
    # por cima. Na tela leu como sujeira pintada no muro: faixa uniforme não
    # vira pedra, vira listra. O que faz o olho ler enrocamento é o CONTORNO
    # irregular — pedras de tamanhos diferentes, encavaladas, cada uma tapando
    # um pedaço da anterior.
    s += poli(costa(0.0, 1.15), C["sombra_agua"], 0.30)

    #
    # A SEGUNDA correção veio do playtest: as pedras eram espalhadas por
    # degrau, cada um ao longo do seu próprio `borda`, e nas quinas da escada
    # isso as jogava para dentro do degrau seguinte — que é mais largo. Vistas
    # na tela pareciam cascalho pintado no concreto do cais. Agora elas andam
    # pelo CONTORNO (andar_costa) e só se afastam na direção do mar, então
    # nenhuma pode cair em terra: a quina passou a ser uma quina de pedra.
    r = random.Random(SEMENTE_CHAO + 90)
    tons = [C["pedra"], C["pedra_media"], C["pedra_clara"]]
    for mx, my, (nmx, nmy), (tmx, tmy) in andar_costa(0.06, (0.22, 0.40), r):
        for _ in range(2):
            fora = r.uniform(0.0, 0.42)
            ao_longo = r.uniform(-0.12, 0.12)
            px, py = p(mx + nmx * fora + tmx * ao_longo,
                       my + nmy * fora + tmy * ao_longo)
            rx = r.uniform(4.5, 9.5)
            s += ('  <ellipse cx="%.0f" cy="%.0f" rx="%.1f" ry="%.1f" '
                  'fill="%s"/>\n'
                  % (px, py, rx, rx * r.uniform(0.48, 0.62), tons[r.randrange(3)]))

    # Espuma: MANCHAS, não traço.
    # Passou por duas versões erradas antes desta. Linha contínua ao longo do
    # cais leu como arame esticado; quebrar em `stroke-dasharray` só trocou o
    # arame por faixa de rodovia, porque traço claro de espessura constante
    # sobre pedra escura é exatamente o desenho de uma pintura de solo. O que
    # lê como arrebentação é borrão de tamanho e opacidade irregulares — a
    # espuma não tem espessura, tem quantidade.
    re_ = random.Random(SEMENTE_CHAO + 55)
    for mx, my, (nmx, nmy), _t in andar_costa(0.45, (0.18, 0.42), re_):
        if re_.random() >= 0.72:
            continue
        fora = re_.uniform(0.0, 0.55)
        fx, fy = p(mx + nmx * fora, my + nmy * fora)
        rx = re_.uniform(4.0, 11.0)
        s += ('  <ellipse cx="%.0f" cy="%.0f" rx="%.1f" ry="%.1f" '
              'fill="%s" opacity="%.2f"/>\n'
              % (fx, fy, rx, re_.uniform(1.8, 3.2), C["espuma"],
                 re_.uniform(0.28, 0.60)))

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
    # Prédios e contêineres saem do mapa quando --sem-predios: eles TROCAM DE
    # ESTADO em jogo (ruína -> consertado), e o que muda de estado não pode
    # estar assado no fundo. Mesma regra dos píeres e dos coqueiros.
    # Carga empilhada no pátio: só faz sentido com o chão pavimentado.
    if com_pavimento:
        cores = [("#c23030", "#7a1a1a", "#8f2020"), ("#2f74b0", "#1d4a75", "#245a8c"),
                 ("#e0a81f", "#9c7a15", "#b8901a"), ("#2d7a3a", "#19512d", "#1f6236")]
        k = 0
        for mx, my in [(2.4, 1.6), (3.9, 1.6), (6.2, 10.4), (7.7, 10.4),
                       (10.2, 18.4), (11.7, 18.4), (1.0, 12.0), (5.0, 20.0)]:
            c = cores[k % len(cores)]
            s += caixa(mx, my, mx + 1.2, my + 1.6, B, 13, c[0], c[1], c[2])
            k += 1

    if not com_predios:
        s += "</svg>\n"
        return s

    s += predio(-1.0, -3.5, 3.0, 0.5, B, 34, C["telhado"], "#8f3822", "#a8452a")
    s += predio(2.0, 5.0, 6.4, 9.4, B, 44, "#3f6f4a", "#2a4d33", "#335c3d", 3)
    s += predio(6.0, 13.0, 10.4, 17.4, B, 32, C["telhado"], "#8f3822", "#a8452a")
    s += predio(10.0, 21.0, 14.4, 25.4, B, 30, "#3f6f4a", "#2a4d33", "#335c3d")


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
    com_predios = "--sem-predios" not in sys.argv
    com_pavimento = "--sem-pavimento" not in sys.argv
    destino = args[0] if args else "porto_mapa_iso.svg"
    conteudo = gerar(com_pieres, com_coqueiros, com_predios, com_pavimento)      # gerar ANTES de abrir: open(...,"w")
    with open(destino, "w", encoding="utf-8") as f:   # trunca de imediato, e um
        f.write(conteudo)                             # erro deixaria o mapa vazio
    print("%s — %dx%d, chão transbordando de propósito (o ecrã é a janela)%s" % (
        destino, LARG, ALT, ("" if com_pieres else "  [SEM os píeres]")
        + ("" if com_coqueiros else "  [SEM os coqueiros]")
        + ("" if com_predios else "  [SEM os prédios]")
        + ("" if com_pavimento else "  [terra batida]")))

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
