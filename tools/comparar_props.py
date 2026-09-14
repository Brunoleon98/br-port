#!/usr/bin/env python3
"""
BR Port — compara duas levas de props sem acreditar nos bytes.

⚠️ PROP NÃO É ARTEFATO BYTE-REPRODUTÍVEL, e o `CLAUDE.md` diz porquê: o
denoiser do Cycles varia +-2/255 em algumas dezenas de pixels entre corridas, e
os props que não estão em `SOMBRA` ainda levam um carimbo de data do Blender no
PNG. `cmp` num prop responde sempre "mudou", e por isso não responde nada.

O que responde é reduzir os dois a 16x16 e comparar: cada célula é a média de
~1.000 pixels, o que apaga aquele ruído por construção. É a mesma régua que o
`CLAUDE.md` escolheu para separar dois cascos que partilham o costado.

⚠️ E A CAIXA DESENHADA NÃO É O DESENHO. Dois props bem distintos podem ter o
MESMO `get_used_rect()` — aconteceu com o porta-contêineres e o graneleiro
médios, 97 x 83 no mesmo sítio —, então a redução faz-se sobre o QUADRO INTEIRO
de 512, e não sobre o recorte: recortar antes de reduzir é comparar duas peças
depois de as alinhar, que esconde exactamente o que se quer ver.

USO
---
    python3 tools/comparar_props.py antes/ depois/ [--limiar 0.02]
"""

import argparse
import os
import sys

import numpy as np
from PIL import Image

LADO = 16
# Limiar em unidades de 0..1 sobre a média das células. 0,02 são ~5/255, bem
# acima do ruído do denoiser (medido: 0,002 entre duas corridas do mesmo
# código) e bem abaixo de qualquer mudança de geometria que se veja.
LIMIAR = 0.02


def reduzir(caminho: str) -> np.ndarray:
    im = Image.open(caminho).convert("RGBA")
    a = np.asarray(im, dtype=np.float32) / 255.0
    # Pré-multiplica pelo alfa: sem isso a cor de um pixel transparente (que o
    # render deixa em preto) entraria na média e a peça pareceria mudar quando
    # só a borda se mexeu.
    a[:, :, :3] *= a[:, :, 3:4]
    h, w = a.shape[0] // LADO, a.shape[1] // LADO
    return a[:LADO * h, :LADO * w].reshape(LADO, h, LADO, w, 4).mean(axis=(1, 3))


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("antes")
    ap.add_argument("depois")
    ap.add_argument("--limiar", type=float, default=LIMIAR)
    args = ap.parse_args()

    nomes = sorted(n[:-4] for n in os.listdir(args.depois)
                   if n.endswith(".png"))
    if not nomes:
        print("nada em %s" % args.depois)
        return 2
    mudou, igual, faltou = [], [], []
    for n in nomes:
        a = os.path.join(args.antes, n + ".png")
        if not os.path.exists(a):
            faltou.append(n)
            continue
        d = np.abs(reduzir(a) - reduzir(os.path.join(args.depois, n + ".png")))
        alvo = mudou if d.max() >= args.limiar else igual
        alvo.append((n, float(d.max()), float(d.mean())))

    print("%-27s %8s %9s" % ("prop", "maior", "média"))
    for n, mx, me in sorted(mudou, key=lambda t: -t[1]):
        print("%-27s %8.4f %9.5f   MUDOU" % (n, mx, me))
    for n, mx, me in sorted(igual, key=lambda t: -t[1]):
        print("%-27s %8.4f %9.5f   igual" % (n, mx, me))
    for n in faltou:
        print("%-27s %8s %9s   SÓ NO DEPOIS" % (n, "--", "--"))
    print("\n%d mudaram, %d iguais, %d novos (limiar %.3f)"
          % (len(mudou), len(igual), len(faltou), args.limiar))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
