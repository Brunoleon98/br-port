#!/usr/bin/env python3
"""
BR Port — gera o mapa em várias projeções para MEDIR o enquadramento.

POR QUE ESTA FERRAMENTA EXISTE
------------------------------
Em 03/09 mediu-se `MEIA_LARG` em 30, 24 e 20 e o resultado desmentiu a
premissa da Etapa 1: a terra visível SATURA em ~24% e depois cai, porque o
mundo é FINITO — os `DEGRAUS` acabam e o `FUNDO_TERRA` também. Aquela medição
foi feita à mão e não ficou no repositório, de modo que a sessão seguinte não
tinha como a repetir contra um mundo já estendido. Agora tem.

A ARMADILHA QUE ELA RESOLVE
---------------------------
Comparar duas projeções sem recalcular `CX`/`CY` mede o DESLOCAMENTO DA
ORIGEM, e não o enquadramento: o mapa inteiro escorrega para o canto e a
conta de "quanta terra se vê" responde a outra pergunta. Aqui o `CX`/`CY` de
cada variante é derivado de manter o MESMO ponto do mundo no centro da janela
do jogo — que é o `MapaWrap`, 720x660, e não o PNG de 720x720.

Uso:
    python3 tools/medir_enquadramento.py /tmp/enq --larguras 30,24,20
    $G --headless --path brport_vs \
       --script res://tools/medir_enquadramento.gd -- /tmp/enq
"""

import argparse
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import gerar_mapa_iso as M          # noqa: E402

# A janela que o jogador vê. O mapa tem 720 de altura e o `MapaWrap` corta em
# 660 — medir no PNG inteiro contaria 60 px de água que ninguém vê.
JANELA = (720, 660)

# O que é ÁGUA, por nome de cor. O `areia_funda` entra aqui de propósito: ele
# não é areia (ver o comentário dele em `gerar_mapa_iso.py`), é o baixio de
# areia visto pela água, e para efeito de enquadramento é mar.
AGUA = ["agua", "agua_funda", "agua_media", "agua_rasa", "agua_baixio",
        "espuma", "sombra_agua", "areia_funda"]

# E o que é TERRA NATURAL — o mundo que esta etapa está a estender, por
# oposição ao porto CONSTRUÍDO em cima dele. A medição de 03/09 contava esta,
# e é por isso que ela dava ~20% num quadro que é 68% "não-mar".
NATURAL = ["solo", "solo_claro", "solo_escuro", "mato", "mangue", "mangue_raiz",
           "capim", "copa", "copa_luz", "tronco", "terra", "terra_clara",
           "terra_escura", "areia", "areia_face", "areia_seca"]

# E o que é ÁGUA FUNDA — o "azul vazio" que a medição de 03/09 contava. São as
# duas pontas do degradê de fundo e a faixa média; do baixio para dentro já é
# margem, que lê como porto e não como vazio.
FUNDA = ["agua", "agua_funda"]


def centro_do_mundo() -> tuple:
    """O ponto do mundo que hoje cai no centro da janela do jogo.

    É a âncora da comparação: toda variante recalcula `CX`/`CY` para o manter
    ali. Desprojeta-se a `h = 0` (a lâmina de água) por ser o plano que existe
    em todo o quadro — a `ALT_CAIS` só existe onde há terra.

    ⚠️ E DESPROJETA-SE EM ESPAÇO DE TELA. `M.CX`/`M.CY` são de DESENHO desde
    o enquadramento de 05/09 (ver o bloco do topo de `gerar_mapa_iso.py`);
    misturar os dois daria uma âncora 1,5x fora e uma comparação que mede o
    deslocamento da origem em vez do enquadramento — que é exatamente o erro
    que esta função existe para não cometer.
    """
    px, py = JANELA[0] / 2.0, JANELA[1] / 2.0
    u = (px / M.ZOOM - M.CX) / M.MEIA_LARG
    v = (py / M.ZOOM - M.CY) / M.MEIA_ALT
    return ((u + v) / 2.0, (v - u) / 2.0)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("saida")
    ap.add_argument("--larguras", default="30,24,20",
                    help="MEIA_LARG EFETIVO de cada variante (o do espaço de tela)")
    ap.add_argument("--nivel-vila", type=int, default=1)
    ap.add_argument("--centro", default=None, metavar="mx,my",
                    help="o ponto do mundo a manter no centro da janela; por "
                         "omissão, o que lá está hoje. É a OUTRA metade do "
                         "enquadramento: a largura diz quanto se vê, o centro "
                         "diz o quê.")
    args = ap.parse_args()

    os.makedirs(args.saida, exist_ok=True)
    mx0, my0 = centro_do_mundo()
    if args.centro:
        mx0, my0 = [float(v) for v in args.centro.split(",")]
    base = (M.ZOOM, M.CX, M.CY, M.LARG, M.ALT)
    variantes = []

    # A câmera é o ZOOM, e é só nele que se mexe: o desenho fica onde está e o
    # `viewBox` encolhe o quadro. Mexer no `MEIA_LARG` aqui mediria outra coisa
    # — a planta a encolher com as alturas paradas.
    for larg in [float(x) for x in args.larguras.split(",")]:
        M.ZOOM = larg / M.MEIA_LARG
        M.LARG = M.ALT = round(M.SAIDA / M.ZOOM)
        M.CX = JANELA[0] / 2.0 / M.ZOOM - (mx0 - my0) * M.MEIA_LARG
        M.CY = JANELA[1] / 2.0 / M.ZOOM - (mx0 + my0) * M.MEIA_ALT
        nome = "mapa_%g.svg" % larg
        with open(os.path.join(args.saida, nome), "w") as f:
            f.write(M.gerar(nivel_vila=args.nivel_vila))
        variantes.append({"arquivo": nome, "meia_larg": larg, "meia_alt": larg / 2.0,
                          "cx": M.CX * M.ZOOM, "cy": M.CY * M.ZOOM,
                          "alt_cais": M.ALT_CAIS * M.ZOOM})
        print("gerado %s  MEIA_LARG efetivo=%g  quadro de desenho %dx%d"
              % (nome, larg, M.LARG, M.ALT))

    M.ZOOM, M.CX, M.CY, M.LARG, M.ALT = base
    with open(os.path.join(args.saida, "medicao.json"), "w") as f:
        json.dump({"janela": list(JANELA), "variantes": variantes,
                   "paleta": M.C, "agua": AGUA, "funda": FUNDA, "natural": NATURAL,
                   "centro_mundo": [mx0, my0],
                   "mundo": {"fundo_terra": M.FUNDO_TERRA,
                             "degraus": M.DEGRAUS}}, f, indent=1)
    print("centro do mundo fixado em mx=%.2f my=%.2f" % (mx0, my0))
    return 0


if __name__ == "__main__":
    sys.exit(main())
