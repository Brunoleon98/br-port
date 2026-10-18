#!/usr/bin/env python3
"""Compara pares temporais controlados do RB6, sem medir desempenho."""
import json
from pathlib import Path
import sys
from PIL import Image, ImageChops


def mudados(a, b):
    assert a.size == b.size == (720, 1280), "quadros fora do tamanho contratado"
    # RGB: getbbox num delta RGBA olharia apenas o alfa, igual nas duas fotos.
    delta = ImageChops.difference(a.convert("RGB"), b.convert("RGB")).crop((0, 62, 720, 782))
    r, g, b = delta.split()
    mascara = ImageChops.lighter(ImageChops.lighter(r, g), b)
    return mascara.width * mascara.height - mascara.histogram()[0]


def main():
    pasta = Path(sys.argv[1])
    pares = {}
    manifestos = {}
    for modo in ("normal", "reduzido"):
        nome = f"movimento_{modo}"
        a, b = [Image.open(pasta / f"{nome}{sufixo}.png") for sufixo in ("", "_t1")]
        assert mudados(a, a) == 0, "a régua inventa diferenças"
        pares[modo] = mudados(a, b)
        manifestos[modo] = json.loads((pasta / f"{nome}.json").read_text())
    for chave in ("semente", "fps_fixo", "frames", "janela", "recorte_mapa", "turno", "caixa", "rng"):
        assert manifestos["normal"][chave] == manifestos["reduzido"][chave], chave
    assert pares["normal"] > 0, "controle positivo não mostrou movimento"
    assert pares["reduzido"] == 0, "fundo ainda se move com a escolha ligada"
    print(json.dumps({"pixels_alterados_no_mapa_em_2s": pares}, ensure_ascii=False))
    print("COMPARACAO TEMPORAL CONFERIDA")


if __name__ == "__main__":
    main()
