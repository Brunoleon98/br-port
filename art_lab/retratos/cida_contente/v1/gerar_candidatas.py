"""A Dona Cida CONTENTE com um sorriso mais claro — as candidatas da v1.

O Bruno aceitou a séria e a preocupada do estúdio (24/09) e pediu, para a
contente, «sorriso mais claro»: os cantos da boca para cima e as sobrancelhas
menos altas, para ela não ler como ESPANTO. Este script não é um segundo
estúdio: monta os nove retratos de fala com o `Estudio` de verdade, troca SÓ a
linha `("cida", "contente")` da tabela `_CARAS` pela de cada candidata e
exporta só aquele grupo. As alavancas novas (`sorriso_fechado`,
`sorriso_lado`, o cenho `suave`, o olho `sorrindo`) já vivem em
`blender/brp_retratos.py`; a tabela do jogo só muda com o aceite.

    python3.11 art_lab/retratos/cida_contente/v1/gerar_candidatas.py [nome ...]

Um estúdio por processo (`preparar_cena()` apaga a cena), daí o laço reexecutar
este script para cada candidata.
"""

import pathlib
import shutil
import subprocess
import sys

AQUI = pathlib.Path(__file__).resolve().parent
RAIZ = AQUI.parents[3]
sys.path.insert(0, str(RAIZ / "blender"))

# As candidatas. A pose é a de hoje (a cabeça de lado lê interesse, e o Bruno
# não a pôs em causa); o que muda é a boca, a sobrancelha e o olho.
CANDIDATAS = {
    # a de hoje, para a prancha: boca aberta com dentes, sobrancelha erguida
    "hoje": dict(boca="sorriso", cenho="erguida", olho="aberto", olhar="frente",
                 pose=(6.0, -3.0, 0.0)),
    # A: sorriso fechado em U, sobrancelha a meio caminho da neutra
    "a_fechado": dict(boca="sorriso_fechado", cenho="suave", olho="aberto",
                      olhar="frente", pose=(6.0, -3.0, 0.0)),
    # B: a A com a pálpebra de baixo a subir — o sorriso chega aos olhos
    "b_fechado_olhos": dict(boca="sorriso_fechado", cenho="suave", olho="sorrindo",
                            olhar="frente", pose=(6.0, -3.0, 0.0)),
    # C: meio sorriso, só um canto sobe — o «pronto, eu disse» da fala dela
    "c_de_lado": dict(boca="sorriso_lado", cenho="suave", olho="aberto",
                      olhar="frente", pose=(6.0, -3.0, 0.0)),
}


def uma(nome: str) -> None:
    import bpy  # noqa: F401 — o `mathutils` só existe depois dele
    import brp_porto
    from brp_studio import Estudio

    brp_porto._CARAS[("cida", "contente")] = CANDIDATAS[nome]
    est = Estudio("porto")
    est.montar(brp_porto.retratos_de_fala)
    tmp = AQUI / ("_tmp_%s" % nome)
    est.exportar(str(tmp), ["retrato_cida_contente"])
    shutil.move(str(tmp / "retrato_cida_contente.png"),
                str(AQUI / ("contente_%s.png" % nome)))
    shutil.rmtree(tmp)


def main() -> int:
    pedidos = sys.argv[1:]
    if len(pedidos) == 1:
        uma(pedidos[0])
        return 0
    for nome in pedidos or list(CANDIDATAS):
        print("=== %s ===" % nome, flush=True)
        r = subprocess.run([sys.executable, __file__, nome])
        if r.returncode:
            return r.returncode
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
