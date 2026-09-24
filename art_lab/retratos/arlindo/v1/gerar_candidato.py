"""O Arlindo no kit afinado — a candidata v1, nas três expressões.

Não é um segundo estúdio: é o `Estudio` de verdade, com o `retratos_de_fala`
de `brp_porto.py`, a quem este script só acrescenta o Arlindo à lista dos que
já estão no kit afinado (`_NO_KIT_AFINADO`). O construtor dele vive em
`blender/brp_retratos.py` (`arlindo`, `ARLINDO`); o jogo só muda com o aceite.

    python3.11 art_lab/retratos/arlindo/v1/gerar_candidato.py
    PREVIA=1 python3.11 ...           # 384 px e 16 amostras, para iterar
"""

import os
import pathlib
import shutil
import sys

AQUI = pathlib.Path(__file__).resolve().parent
RAIZ = AQUI.parents[3]
sys.path.insert(0, str(RAIZ / "blender"))

GRUPOS = ["retrato_arlindo_sorriso", "retrato_arlindo_pressao", "retrato_arlindo_contrariado"]

# AS CARAS DO CANDIDATO. Ficam aqui e não na `_CARAS` do `brp_porto.py`
# porque o Arlindo de caixas antigo lê a mesma tabela até ao aceite, e não
# conhece as alavancas novas (cairia calado numa cara neutra).
# - sorriso: o estado NORMAL dele. O sorriso com dentes, e os olhos ABERTOS —
#   o sorriso que não chega aos olhos é o «simpático na superfície,
#   competitivo por baixo» do GDD;
# - pressão: o queixo em baixo, o olho cerrado e o franzido carregado, a
#   olhar por baixo da pala;
# - contrariado: a sobrancelha torta, os olhos a fugir para o lado e a
#   cabeça a virar-se — o último a admitir que perdeu.
CARAS = {
    ("arlindo", "sorriso"): dict(boca="sorriso_dentes", cenho="neutra", olho="aberto",
                                 olhar="frente", pose=(4.0, -2.0, 6.0)),
    ("arlindo", "pressao"): dict(boca="reta", cenho="carregada", olho="cerrado",
                                 olhar="frente", pose=(0.0, 6.0, 0.0)),
    ("arlindo", "contrariado"): dict(boca="descontente", cenho="torta", olho="aberto",
                                     olhar="lado", pose=(-2.0, 1.0, -9.0)),
}


def main() -> int:
    import bpy  # noqa: F401 — o `mathutils` só existe depois dele
    import brp_porto
    from brp_studio import Estudio

    brp_porto._NO_KIT_AFINADO = ("cida", "ribeiro", "arlindo")
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
