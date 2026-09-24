"""As variações do trabalhador do rodapé — a leva v2.

O mesmo estúdio de `brport_vs/` (o `Estudio`, a câmera, o rig e a paleta de
`preparar_cena()`) e o mesmo construtor, `trabalhador()` de
`blender/brp_retratos.py`, com um `perfil` por retrato. O jogo não muda: o
`trabalhador_retrato` do `CATALOGO` continua sem perfil, que é o padrão.

    python3.11 art_lab/retratos/trabalhador_variacoes/v2/gerar_variacoes.py [nome ...]
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
# Os PELOS NO ROSTO, em alguns homens (o escopo do Bruno): nunca no jovem, que
# é o de cara lisa, e nunca no padrão, que tem de sair igual. Na v1 eram dois
# tipos em cinco homens; o Bruno pediu «mais variações de barba» — três tipos
# em sete, cada um em pelo menos duas cores.
_PELOS = {("adulto", "branca"): "barba", ("adulto", "preta"): "cavanhaque",
          ("adulto", "indigena"): "bigode",
          ("veterano", "branca"): "cavanhaque", ("veterano", "parda"): "bigode",
          ("veterano", "preta"): "barba", ("veterano", "amarela"): "cavanhaque"}
# O PENTEADO DELA: cinco, cada um três vezes, e nenhum repetido na mesma idade
# nem na mesma cor — o pedido do Bruno na v1 («mais variações de cabelo para
# mulher, mesmo de chapéu»).
_CABELOS = {
    ("jovem", "branca"): "rabo", ("jovem", "parda"): "crespo", ("jovem", "preta"): "tranca",
    ("jovem", "amarela"): "solto", ("jovem", "indigena"): "curto",
    ("adulto", "branca"): "solto", ("adulto", "parda"): "rabo", ("adulto", "preta"): "crespo",
    ("adulto", "amarela"): "curto", ("adulto", "indigena"): "tranca",
    ("veterano", "branca"): "curto", ("veterano", "parda"): "tranca",
    ("veterano", "preta"): "crespo", ("veterano", "amarela"): "rabo",
    ("veterano", "indigena"): "solto",
}


def _perfis():
    import brp_retratos as br
    tabela = {}
    for sexo in br.SEXOS:
        for idade in br.IDADES:
            for cor in br.CORES:
                homem = sexo == "homem"
                tabela["trabalhador_%s_%s_%s" % (sexo, idade, cor)] = dict(
                    sexo=sexo, idade=idade, cor=cor,
                    pelos=_PELOS.get((idade, cor)) if homem else None,
                    cabelo=None if homem else _CABELOS[(idade, cor)])
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
