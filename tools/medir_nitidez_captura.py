#!/usr/bin/env python3
"""
BR Port — a régua da ALAVANCA B: quanta fronteira de valor sobrevive ao
antisserrilhado numa CAPTURA do jogo, antes e depois de os props subirem de
resolução.

POR QUE UMA CAPTURA, E NÃO O PNG DO PROP
----------------------------------------
A `025` mediu o MAPA rasterizando o SVG duas vezes, porque ali o que muda é a
amostragem de um desenho que já existia. Aqui o que muda é o RENDER: o prop a
768 não é o prop a 512 mais nítido, é outro arquivo, e comparar os dois PNGs
diretamente compararia tamanhos. O que se pode comparar é o que o jogador vê —
a mesma partida, com a mesma semente e o mesmo passo de tempo, fotografada nas
duas versões.

⚠️ E A COMPARAÇÃO HONESTA É A 1080x1920. Com `stretch/mode="canvas_items"` o
jogo desenha na resolução NATIVA do aparelho: a 720 a textura de 768 é reduzida
pela GPU quase de volta ao que era, e a medição diria que a alavanca não fez
nada. A bateria do `capturar_evidencia.sh` é travada a 720x1280 de propósito
(as folhas de contato dependem disso), então as fotos desta régua tiram-se à
parte, com `--resolution 1080x1920`.

A MÉTRICA É A MESMA DA `025`, e de propósito
--------------------------------------------
Ampliar uma imagem conserva quase toda a energia de gradiente e destrói o PICO:
a mesma fronteira passa a subir ao longo de 1,5 px em vez de 1. Então mede-se a
CONTAGEM de pixels cujo gradiente local passa de um piso de leitura, e a energia
ACIMA desse piso. O piso é 6/255 de luminância, ~0,05 de contraste de Weber a
meio tom — o mesmo corte com que este projeto diz que uma peça "some".

A MÁSCARA SAI DA DIFERENÇA, e é isso que separa o prop do mapa
--------------------------------------------------------------
O mapa não mudou nesta alavanca, e ele ocupa quase toda a janela: medir o quadro
inteiro afogaria o ganho dos props numa área que não se mexeu — a mesma
armadilha que a `025` teve com o raster da água. Aqui a máscara é onde as duas
capturas diferem, dilatada de um pixel para a janela do gradiente caber. Ela é
derivada e não escrita: um prop que não mude não entra na conta, e um que mude
entra sozinho.

CALIBRAÇÃO (o que faz "zero" querer dizer zero)
-----------------------------------------------
    python3 tools/medir_nitidez_captura.py foto.png foto.png
o mesmo arquivo dos dois lados tem de dar máscara VAZIA e 0,00 em tudo. E um par
que se sabe diferente tem de dar muito. Sem as duas voltas, um "0,00%" pode ser
a régua a comparar um arquivo consigo mesma.

Uso:
    python3 tools/medir_nitidez_captura.py <antes.png> <depois.png> [--json f]
"""

import argparse
import json
import sys

import numpy as np
from PIL import Image

PISO = 6.0          # 6/255 de luminância ~ 0,05 de Weber a meio tom


def _lum(rgb):
    return (0.2126 * rgb[:, :, 0] + 0.7152 * rgb[:, :, 1]
            + 0.0722 * rgb[:, :, 2])


def _gradiente(lum):
    """O mesmo `max(|dx|, |dy|)` do `medir_resolucao_mapa.gd`."""
    g = np.zeros_like(lum)
    dx = np.abs(lum[:-1, 1:] - lum[:-1, :-1])
    dy = np.abs(lum[1:, :-1] - lum[:-1, :-1])
    g[:-1, :-1] = np.maximum(dx, dy)
    return g


def _dilatar(m):
    d = m.copy()
    d[1:, :] |= m[:-1, :]
    d[:-1, :] |= m[1:, :]
    d[:, 1:] |= m[:, :-1]
    d[:, :-1] |= m[:, 1:]
    return d


def medir(lum, mascara):
    g = _gradiente(lum)[mascara]
    acima = g >= PISO
    n = int(acima.sum())
    return {
        "pixels": int(mascara.sum()),
        "acima_do_piso": n,
        "fracao_acima": (n / max(int(mascara.sum()), 1)),
        "energia_acima": float((g[acima] - PISO).sum()),
        "pico_medio": float(g[acima].mean()) if n else 0.0,
    }


def erro_visivel(la, ld, mascara):
    d = np.abs(ld - la)[mascara]
    if d.size == 0:
        return {"frac_piso": 0.0, "frac_2piso": 0.0, "medio": 0.0,
                "p99": 0.0, "maximo": 0.0}
    return {
        "frac_piso": float((d >= PISO).mean()),
        "frac_2piso": float((d >= 2 * PISO).mean()),
        "medio": float(d.mean()),
        "p99": float(np.percentile(d, 99)),
        "maximo": float(d.max()),
    }


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("antes")
    ap.add_argument("depois")
    ap.add_argument("--json")
    a = ap.parse_args()

    ia = np.asarray(Image.open(a.antes).convert("RGB"), dtype=np.float32)
    idp = np.asarray(Image.open(a.depois).convert("RGB"), dtype=np.float32)
    if ia.shape != idp.shape:
        print("FALHOU — %s tem %s e %s tem %s: a régua compara a MESMA janela."
              % (a.antes, ia.shape[:2], a.depois, idp.shape[:2]))
        return 1

    la, ld = _lum(ia), _lum(idp)
    tudo = np.ones(la.shape, dtype=bool)
    mudou = _dilatar(np.any(ia != idp, axis=2))

    print("janela  %d x %d px" % (la.shape[1], la.shape[0]))
    print("mudou   %d px (%.2f%% do quadro)"
          % (mudou.sum(), 100.0 * mudou.mean()))
    if mudou.sum() == 0:
        print("\n⚠️ A MÁSCARA ESTÁ VAZIA — as duas capturas são o mesmo pixel a"
              " pixel.\n   É o que se espera ao calibrar a régua com o mesmo"
              " arquivo dos dois lados;\n   num antes/depois de verdade quer"
              " dizer que nada chegou à tela.")

    for nome, m in (("o quadro inteiro", tudo), ("onde MUDOU", mudou)):
        if m.sum() == 0:
            continue
        ma, md = medir(la, m), medir(ld, m)
        print("\n=== %s (%d px) ===" % (nome, m.sum()))
        print("  %-22s %12s %12s %10s" % ("", "antes", "depois", "delta"))
        for chave, rot, fmt in (
                ("acima_do_piso", "px acima do piso", "%d"),
                ("energia_acima", "energia acima", "%.0f"),
                ("pico_medio", "pico médio", "%.2f")):
            va, vd = ma[chave], md[chave]
            delta = (100.0 * (vd - va) / va) if va else float("nan")
            print(("  %-22s " + fmt + " " + fmt + "   %+8.1f%%")
                  % (rot, va, vd, delta))
        ev = erro_visivel(la, ld, m)
        print("  muda acima do piso de Weber: %.2f%% (2x o piso: %.2f%%)"
              % (100.0 * ev["frac_piso"], 100.0 * ev["frac_2piso"]))
        print("  |Δ| médio %.2f · p99 %.0f · máximo %.0f"
              % (ev["medio"], ev["p99"], ev["maximo"]))

    if a.json:
        with open(a.json, "w") as f:
            json.dump({"antes": a.antes, "depois": a.depois, "piso": PISO,
                       "mudou_px": int(mudou.sum()),
                       "quadro": {"antes": medir(la, tudo),
                                  "depois": medir(ld, tudo),
                                  "erro": erro_visivel(la, ld, tudo)},
                       "mudou": {"antes": medir(la, mudou),
                                 "depois": medir(ld, mudou),
                                 "erro": erro_visivel(la, ld, mudou)}},
                      f, indent=1)
    return 0


if __name__ == "__main__":
    sys.exit(main())
