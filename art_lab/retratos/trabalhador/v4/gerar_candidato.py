"""O trabalhador do rodapé em BUSTO no kit afinado — a candidata v4.

Não é um segundo estúdio: é o `Estudio` de verdade, com a câmera, o rig e a
paleta de `preparar_cena()`, e o construtor `trabalhador()` de
`blender/brp_retratos.py`. O jogo só muda com o aceite do Bruno: até lá o
`CATALOGO` de `brp_porto.py` continua a exportar o boneco de corpo inteiro.

    python3.11 art_lab/retratos/trabalhador/v4/gerar_candidato.py
    PREVIA=1 python3.11 ...           # 384 px e 16 amostras, para iterar
"""

import os
import pathlib
import shutil
import sys

AQUI = pathlib.Path(__file__).resolve().parent
RAIZ = AQUI.parents[3]
sys.path.insert(0, str(RAIZ / "blender"))

NOME = "trabalhador_retrato"

# A CARA, uma só: o cartão do rodapé mostra o mesmo retrato em todos os estados
# (livre, parado, escolhido). O meio sorriso curto é a cortesia de quem está
# pronto a trabalhar — nem a alegria da Dona Cida contente, nem a cara fechada
# que no estado «parado» leria como queixa. A cabeça inclina 4°: a pose vale
# mais do que a cara a este tamanho (`CLAUDE.md`, Arte).
CARA = dict(boca="sorriso_curto", cenho="neutra", olho="aberto", olhar="frente",
            pose=(4.0, -2.0, 0.0))


def montar(M, est):
    import brp_porto
    import brp_retratos
    tronco, cabeca = brp_retratos.trabalhador(M, CARA)
    pecas = tronco + cabeca
    medir = [o for o in cabeca if o.name.startswith(("cabeca", "cabelo", "capacete"))]
    for peca in pecas:
        peca.name = "%s_%s" % (NOME, peca.name)
    brp_retratos.enquadrar(est.cena, NOME, pecas, medir)
    brp_retratos.pousar_cabeca(cabeca, CARA["pose"], brp_retratos.TRABALHADOR.pivo)
    brp_porto.origem(NOME, tipo="retrato")
    est.registrar(NOME, pecas, ancora="retrato", cena_godot="res://scenes/worker/Worker.tscn",
                  cor=brp_retratos.COR_RETRATO)


def main() -> int:
    import bpy  # noqa: F401 — o `mathutils` só existe depois dele
    from brp_studio import Estudio

    est = Estudio("porto")
    previa = os.environ.get("PREVIA") == "1"
    if previa:
        est.cena.render.resolution_x = est.cena.render.resolution_y = 384
        est.cena.cycles.samples = 16
    est.montar(montar)
    saida = AQUI / ("previa" if previa else ".")
    tmp = AQUI / "_tmp"
    est.exportar(str(tmp), [NOME])
    saida.mkdir(exist_ok=True)
    for png in tmp.glob("*.png"):
        shutil.move(str(png), str(saida / png.name))
    shutil.rmtree(tmp)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
