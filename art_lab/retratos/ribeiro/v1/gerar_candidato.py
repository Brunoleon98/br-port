"""O Sr. Ribeiro no kit afinado — a candidata v1, nas três expressões.

Não é um segundo estúdio: é o `Estudio` de verdade, com o `retratos_de_fala`
de `brp_porto.py`, a quem este script só acrescenta o Sr. Ribeiro à lista dos
que já estão no kit afinado (`_NO_KIT_AFINADO`). O construtor dele vive em
`blender/brp_retratos.py` (`ribeiro`, `RIBEIRO`); o jogo só muda com o aceite.

    python3.11 art_lab/retratos/ribeiro/v1/gerar_candidato.py
    PREVIA=1 python3.11 ...           # 384 px e 16 amostras, para iterar
"""

import os
import pathlib
import shutil
import sys

AQUI = pathlib.Path(__file__).resolve().parent
RAIZ = AQUI.parents[3]
sys.path.insert(0, str(RAIZ / "blender"))

GRUPOS = ["retrato_ribeiro_cordial", "retrato_ribeiro_formal", "retrato_ribeiro_grave"]

# AS CARAS DO CANDIDATO. Ficam aqui e não na `_CARAS` do `brp_porto.py`
# porque o Sr. Ribeiro de caixas antigo lê a mesma tabela até ao aceite, e
# não conhece o cenho `carregada` (cairia calado numa sobrancelha neutra).
# A cordial e a formal são as de hoje; a grave troca a `franzida` pela
# `carregada`, que lia como SONO com o olho cerrado.
CARAS = {
    ("ribeiro", "cordial"): dict(boca="sorriso_curto", cenho="neutra", olho="aberto",
                                 olhar="frente", pose=(3.0, -2.0, 3.0)),
    ("ribeiro", "formal"): dict(boca="reta", cenho="neutra", olho="aberto",
                                olhar="frente", pose=(0.0, 0.0, 0.0)),
    ("ribeiro", "grave"): dict(boca="descontente", cenho="carregada", olho="cerrado",
                               olhar="frente", pose=(0.0, 5.0, 0.0)),
}


def main() -> int:
    import bpy  # noqa: F401 — o `mathutils` só existe depois dele
    import brp_porto
    from brp_studio import Estudio

    brp_porto._NO_KIT_AFINADO = ("cida", "ribeiro")
    brp_porto._CARAS.update(CARAS)
    est = Estudio("porto")
    previa = os.environ.get("PREVIA") == "1"
    if previa:
        est.cena.render.resolution_x = est.cena.render.resolution_y = 384
        est.cena.cycles.samples = 16
    est.montar(brp_porto.retratos_de_fala)
    saida = AQUI / ("previa" if previa else ".")
    tmp = AQUI / "_tmp"
    est.exportar(str(tmp), sys.argv[1:] or GRUPOS)
    saida.mkdir(exist_ok=True)
    for png in tmp.glob("*.png"):
        shutil.move(str(png), str(saida / png.name))
    shutil.rmtree(tmp)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
