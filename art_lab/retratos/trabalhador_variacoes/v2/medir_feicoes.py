"""O contraste das feições contra a pele, em cada variação.

A pergunta que o briefing deixou: a sobrancelha e a boca em `vao` somem na
pele mais escura? Mede-se no PNG, que é o que o jogo desenha: a pele é a
MEDIANA de uma janela na bochecha (a mediana é um pixel de verdade, e não se
deixa mover por uma aresta — `CLAUDE.md`, Arte), a feição é o p10 da janela
dela, e o contraste é Weber, (pele − feição) / pele, em luminância relativa.

As janelas são do quadro de 768 do padrão, medidas no PNG dele; todas as
variações têm o mesmo enquadramento (a cabeça medida inclui o capacete, que é
o mesmo nos 30). O PISO é a mesma conta com a janela da própria bochecha no
lugar da feição: é o contraste que a sombra da pele dá sozinha, e uma feição
que meça perto dele não se separa da pele.

    python3 art_lab/retratos/trabalhador_variacoes/v2/medir_feicoes.py [png]
"""

import pathlib
import sys

import numpy as np
from PIL import Image

AQUI = pathlib.Path(__file__).resolve().parent
# (x0, y0, x1, y1) no quadro de 768.
BOCHECHA = ((296, 368, 328, 396), (442, 368, 474, 396))
BOCA = (366, 401, 424, 413)
SOBRANCELHA = (312, 272, 356, 290)


def _lum(im):
    a = np.asarray(im.convert("RGB")).astype(float) / 255.0
    lin = np.where(a <= 0.04045, a / 12.92, ((a + 0.055) / 1.055) ** 2.4)
    return lin @ np.array([0.2126, 0.7152, 0.0722])


def medir(png):
    lum = _lum(Image.open(png))
    pele = float(np.median(np.concatenate([lum[y0:y1, x0:x1].ravel()
                                           for x0, y0, x1, y1 in BOCHECHA])))

    def feicao(caixa):
        x0, y0, x1, y1 = caixa
        return float(np.percentile(lum[y0:y1, x0:x1], 10))
    piso = (pele - feicao(BOCHECHA[0])) / pele
    return pele, piso, (pele - feicao(BOCA)) / pele, (pele - feicao(SOBRANCELHA)) / pele


def main():
    pasta = AQUI / (sys.argv[1] if len(sys.argv) > 1 else "png")
    print("%-40s %6s %6s %6s %6s" % ("retrato", "pele", "piso", "boca", "sobr."))
    for png in sorted(pasta.glob("*.png")):
        pele, piso, boca, sobr = medir(png)
        print("%-40s %6.3f %6.2f %6.2f %6.2f" % (png.stem, pele, piso, boca, sobr))


if __name__ == "__main__":
    main()
