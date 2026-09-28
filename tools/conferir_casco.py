#!/usr/bin/env python3
"""Que peça de um barco sai para fora do casco — medido, não a olho.

Uso (precisa do `bpy`, num Python 3.11 — ver «Como rodar» no `CLAUDE.md`):

    python3.11 tools/conferir_casco.py                 # todos os barco_*
    python3.11 tools/conferir_casco.py -- barco_medio_geral barco_grande_granel

Monta o prop pelo MESMO `montar()` do `gerar_props_iso.py`, lê a amurada do
próprio objeto `casco_*` (o anel de vértices no topo dele) e, para cada outra
peça, mede o quanto cada vértice passa da meia-boca do casco no `x` dele.
Imprime, por prop, as peças que passam mais de 0,02 unidades, da pior para a
melhor. É RELATÓRIO, não portão: há peças que saem de propósito — os pneus
de defensa pendurados no costado, o pau-de-carga da traineira a içar por cima
da amurada, a bandeira a voar —, e quem decide se uma saída é defeito é quem
olha para ela.

⚠️ NASCEU PORQUE O OLHO NÃO CHEGOU (`docs/decisoes/072`). O Bruno disse três
vezes «partes do navio saindo do casco», e a cada volta a correção à vista
deixava outra: primeiro a baleeira e as letras em pé, depois a carga da proa
dos graneleiros e do porta-contêineres de longo curso — que passava da borda
desde 07/09 sem ninguém o perguntar —, e por fim a amarra (0,075) e o pau da
frente da carga geral (0,022), que só a medição apanhou. É a regra do
`get_used_rect()` (`CLAUDE.md`, Arte) com o casco no lugar do quadro: a caixa
do prop não sabe nada do barco que está dentro dela.

⚠️ AS PEÇAS DO PRÓPRIO CASCO NÃO SE MEDEM. A faixa, o convés e a faixa
antivegetativa partilham o contorno da amurada, e no espelho de popa — que é
um corte — o anel tem os dois bordos no mesmo `x`: medidas contra ele davam
0,44 «fora» sem haver nada fora. Saem pelo prefixo do nome.
"""

import sys

sys.path.insert(0, "tools")

import bpy  # noqa: E402  (só existe no Python do Blender)
import gerar_props_iso as g  # noqa: E402

DO_CASCO = ("casco_", "faixa_", "conves_", "antiveg")
FOLGA = 0.02


def anel_da_amurada(casco, dg):
    """(x, meia-boca) dos vértices no topo do casco, ordenados por x."""
    vs = [casco.matrix_world @ v.co for v in casco.evaluated_get(dg).data.vertices]
    topo = max(v.z for v in vs)
    return sorted((v.x, abs(v.y)) for v in vs if abs(v.z - topo) < 1e-3)


def meia_boca(anel, x):
    x = min(max(x, anel[0][0]), anel[-1][0])
    melhor = 0.0
    for (x0, y0), (x1, y1) in zip(anel, anel[1:]):
        if x0 <= x <= x1:
            t = (x - x0) / (x1 - x0) if x1 > x0 else 0.0
            melhor = max(melhor, y0 + (y1 - y0) * t)
    return melhor


def main() -> int:
    grupos = g.montar(g.paleta_completa())
    alvo = (sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv
            else sorted(k for k in grupos if k.startswith("barco_")))
    dg = bpy.context.evaluated_depsgraph_get()
    for nome in alvo:
        objs = grupos[nome]
        casco = next(o for o in objs if o.name.startswith("casco_"))
        anel = anel_da_amurada(casco, dg)
        xmin, xmax = anel[0][0], anel[-1][0]
        fora = []
        for o in objs:
            if o.type != "MESH" or o.name.startswith(DO_CASCO):
                continue
            pior = 0.0
            for v in o.evaluated_get(dg).data.vertices:
                w = o.matrix_world @ v.co
                if w.x < xmin - FOLGA or w.x > xmax + FOLGA:
                    pior = max(pior, max(xmin - w.x, w.x - xmax))
                pior = max(pior, abs(w.y) - meia_boca(anel, w.x))
            if pior > FOLGA:
                fora.append((round(pior, 3), o.name))
        fora.sort(reverse=True)
        print("%-26s %s" % (nome, fora if fora else "tudo dentro"))
    print("=== CASCO CONFERIDO ===")
    return 0


if __name__ == "__main__":
    sys.exit(main())
