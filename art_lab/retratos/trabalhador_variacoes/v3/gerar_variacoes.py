"""As variações do trabalhador do rodapé — a leva v3.

O mesmo estúdio de `brport_vs/` (o `Estudio`, a câmera, o rig e a paleta de
`preparar_cena()`) e o mesmo construtor, `trabalhador()` de
`blender/brp_retratos.py`, com um `perfil` por retrato. O jogo não muda: o
`trabalhador_retrato` do `CATALOGO` continua sem perfil, que é o padrão.

    python3.11 art_lab/retratos/trabalhador_variacoes/v3/gerar_variacoes.py [nome ...]
    PREVIA=1 python3.11 ...           # 384 px e 16 amostras, para iterar

Sem nomes, sai a tabela inteira (`PERFIS`, 30 retratos); `padrao` é o
trabalhador de hoje, pelo MESMO caminho — é a prova de que ele não mudou.
"""

import os
import pathlib
import shutil
import sys

AQUI = pathlib.Path(__file__).resolve().parent
RAIZ = AQUI.parents[3]
sys.path.insert(0, str(RAIZ / "blender"))

# A cara e o enquadramento do trabalhador de hoje, lidos do estúdio e não
# copiados: o que muda aqui é só o perfil.
# A TABELA DOS 30 é a do estúdio desde o aceite da v3 (`059`): o
# `TRABALHADOR_PERFIS` de `blender/brp_porto.py`, uma fonte só. Aqui cada um
# sai com o nome do seu perfil — o padrão também, como
# `trabalhador_homem_adulto_parda`, para a folha o pôr na grade.
def _perfis():
    import brp_porto
    tabela = {}
    for nome, perfil in brp_porto.TRABALHADOR_PERFIS:
        if perfil is None:
            nome, perfil = "trabalhador_homem_adulto_parda", dict(
                sexo="homem", idade="adulto", cor="parda")
        tabela[nome] = perfil
    return tabela


def main() -> int:
    import bpy  # noqa: F401 — o `mathutils` só existe depois dele
    import brp_porto
    import brp_retratos
    from brp_studio import Estudio

    perfis = _perfis()
    perfis["padrao"] = None
    pedidos = sys.argv[1:] or [n for n in perfis if n != "padrao"]
    for n in pedidos:
        if n not in perfis:
            raise SystemExit("perfil desconhecido: %s" % n)

    cara = brp_porto.TRABALHADOR_CARA

    def montar(M, est):
        for nome in pedidos:
            tronco, cabeca = brp_retratos.trabalhador(M, cara, perfis[nome])
            pecas = tronco + cabeca
            medir = [o for o in cabeca
                     if o.name.startswith(("cabeca", "cabelo", "capacete"))]
            for peca in pecas:
                peca.name = "%s_%s" % (nome, peca.name)
            brp_retratos.enquadrar(est.cena, nome, pecas, medir,
                                   cabeca=brp_porto.TRABALHADOR_CABECA)
            brp_retratos.pousar_cabeca(cabeca, cara["pose"], brp_retratos.TRABALHADOR.pivo)
            brp_porto.origem(nome, tipo="retrato")
            est.registrar(nome, pecas, ancora="retrato", cor=brp_retratos.COR_RETRATO)

    est = Estudio("porto")
    previa = os.environ.get("PREVIA") == "1"
    if previa:
        est.cena.render.resolution_x = est.cena.render.resolution_y = 384
        est.cena.cycles.samples = 16
    est.montar(montar)
    saida = AQUI / ("previa" if previa else "png")
    tmp = AQUI / "_tmp"
    est.exportar(str(tmp), pedidos)
    saida.mkdir(exist_ok=True)
    for png in tmp.glob("*.png"):
        shutil.move(str(png), str(saida / png.name))
    shutil.rmtree(tmp)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
