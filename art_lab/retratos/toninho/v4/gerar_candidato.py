"""O Toninho no kit afinado — a candidata v4, nas três expressões.

Não é um segundo estúdio: é o `Estudio` de verdade, com o `retratos_de_fala`
de `brp_porto.py`, a quem este script acrescenta o Toninho à lista dos que
falam. O construtor dele vive em `blender/brp_retratos.py` (`toninho`,
`TONINHO`); o jogo só muda com o aceite.

    python3.11 art_lab/retratos/toninho/v4/gerar_candidato.py
    PREVIA=1 python3.11 ...           # 384 px e 16 amostras, para iterar
"""

import os
import pathlib
import shutil
import sys

AQUI = pathlib.Path(__file__).resolve().parent
RAIZ = AQUI.parents[3]
sys.path.insert(0, str(RAIZ / "blender"))
sys.path.insert(0, str(RAIZ / "tools"))

GRUPOS = ["retrato_toninho_calmo", "retrato_toninho_ironico", "retrato_toninho_serio"]

# AS CARAS DO CANDIDATO, uma por fala (o escopo do Bruno, 11/10):
# - calmo («Escolhe quem entra»): o sorriso fechado, a sobrancelha suave e
#   a cabeça de lado — o afeto de quem mostra o cais ao neto do amigo;
# - irónico («O resto o dia resolve»): o sorriso de canto, a sobrancelha torta
#   e os olhos a sorrir — «irônico sem amargura», o tom do GDD;
# - sério («Olha, chefia...»): a boca reta, o queixo baixo e o olhar direto —
#   a pausa antes do que importa.
CARAS = {
    ("toninho", "calmo"): dict(boca="sorriso_fechado", cenho="suave", olho="aberto",
                               olhar="frente", pose=(5.0, -2.0, 5.0)),
    ("toninho", "ironico"): dict(boca="sorriso_lado", cenho="torta", olho="sorrindo",
                                 olhar="frente", pose=(-5.0, 3.0, -6.0)),
    ("toninho", "serio"): dict(boca="reta", cenho="neutra", olho="aberto",
                               olhar="frente", pose=(0.0, 6.0, 0.0)),
}


def main() -> int:
    import bpy  # noqa: F401 — o `mathutils` só existe depois dele
    import brp_porto
    from brp_studio import Estudio

    brp_porto._CARAS.update(CARAS)
    brp_porto.RETRATOS = {"toninho": ("calmo", "ironico", "serio")}
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
