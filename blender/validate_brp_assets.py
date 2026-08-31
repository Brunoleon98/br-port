"""BRP — validação do lado do Blender. FASE 12 do prompt mestre.

    python3 blender/validate_brp_assets.py            # todos os estúdios
    python3 blender/validate_brp_assets.py porto

Confere o que só existe ENQUANTO a cena está montada e desaparece no PNG:
âncora, nome, coleção de exportação, apoio e volume de seleção. O que sobrevive
no PNG — alfa, tamanho, projeção — é conferido do outro lado, por
`tools/conferir_lote_de_arte.py` e por `scripts/validation/asset_validator.gd`.

A lista de falhas obrigatórias do prompt está implementada assim:

    falta ORIGIN_anchor .................. checa_ancora
    objeto selecionável sem COL_select ... checa_selecao
    origem muito longe da base ........... checa_apoio
    asset fora do limite de escala ....... checa_escala
    objeto sem camada ou grupo ........... checa_export

Sai com código != 0 se qualquer asset falhar, para poder entrar no CI.
"""

import importlib
import pathlib
import subprocess
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))

from brp_studio import Estudio, RESOLUCAO, z                 # noqa: E402
from gerar_brp import ESTUDIOS                               # noqa: E402

# Um asset não pode ser maior que o quadro: se for, o render corta-o e o corte
# só aparece quando alguém olha. O quadro tem 512px e uma unidade de mundo na
# horizontal vale MEIA_LARG=30, logo cabem ~17 unidades — mas metade disso já é
# um prop que ocupa a tela inteira do jogo, então o limite prático é menor.
ESCALA_MAXIMA = 8.0

# Quanto a base da malha pode ficar afastada da âncora, em unidades de mundo.
# 0,02 é a largura do chanfro: uma peça chanfrada sobe esse tanto e não é erro.
FOLGA_APOIO = 0.05


def _caixa(objetos):
    """Menor caixa que contém todas as malhas do grupo, em coordenadas do
    mundo. `bound_box` é local, então cada canto passa pela matriz do objeto —
    sem isso um prop rodado mede a caixa errada."""
    xs, ys, zs = [], [], []
    for o in objetos:
        if o.type != "MESH":
            continue
        for canto in o.bound_box:
            p = o.matrix_world @ __import__("mathutils").Vector(canto)
            xs.append(p.x); ys.append(p.y); zs.append(p.z)
    if not xs:
        return None
    return (min(xs), max(xs), min(ys), max(ys), min(zs), max(zs))


def validar(categoria: str) -> list:
    """Devolve a lista de falhas (vazia = tudo certo)."""
    import bpy

    est = Estudio(categoria)
    est.montar(importlib.import_module(ESTUDIOS[categoria][0]).montar)

    # Garante que `matrix_world` está atual antes de medir. MEDIDO: sem esta
    # linha o caso testado (prop levantado depois de criado) continua sendo
    # pego, ou seja ela não é o que faz a validação funcionar — fica como
    # seguro barato, porque a armadilha existe e está documentada em
    # `preparar_cena()` do outro lado, para a câmera.
    #
    # Fica registrado o caminho, que foi mais útil que a linha: a primeira
    # tentativa de provar o validador NÃO injetou defeito nenhum, porque
    # `CATALOGO` é uma tupla montada no import e trocar o atributo do módulo
    # não a altera. O validador parecia furado e o furado era o teste.
    bpy.context.view_layer.update()

    falhas = []
    ancoras = {o.name: o for o in bpy.data.objects
               if o.name.startswith("ORIGIN_")}
    selecoes = {o.name: o for o in bpy.data.objects
                if o.name.startswith("COL_select_")}

    for nome, objetos in est.grupos.items():
        ficha = est.fichas[nome]

        # -- âncora ------------------------------------------------------
        anc = ancoras.get("ORIGIN_%s" % nome)
        if anc is None:
            falhas.append("%s: sem ORIGIN_anchor" % nome)
            continue

        cx = _caixa(objetos)
        if cx is None:
            falhas.append("%s: nenhuma malha" % nome)
            continue
        x0, x1, y0, y1, z0, z1 = cx

        # -- apoio -------------------------------------------------------
        # Só se cobra de quem DIZ que se apoia. Uma ave em voo e uma peça de
        # encaixe estão certas a flutuar — foi para isto que `origem()` pede
        # o tipo em vez de o adivinhar.
        tipo = anc.get("brp_ancora", "base")
        if tipo == "base":
            if z0 > anc.location.z + FOLGA_APOIO:
                falhas.append(
                    "%s: flutua — a malha começa em z=%.3f e a âncora está em "
                    "z=%.3f" % (nome, z0, anc.location.z))
            if z0 < anc.location.z - 0.6:
                falhas.append(
                    "%s: enterrado — a malha desce %.2f abaixo da âncora"
                    % (nome, anc.location.z - z0))
        elif tipo == "waterline":
            if z0 > anc.location.z:
                falhas.append("%s: flutua acima da própria linha de água"
                              % nome)

        # -- escala ------------------------------------------------------
        larg, fundo, alt = x1 - x0, y1 - y0, z1 - z0
        for eixo, v in (("largura", larg), ("fundo", fundo), ("altura", alt)):
            if v > ESCALA_MAXIMA:
                falhas.append("%s: %s de %.1f unidades passa o limite de %.1f "
                              "— vai sair cortado do quadro de %dpx"
                              % (nome, eixo, v, ESCALA_MAXIMA, RESOLUCAO))

        # -- seleção -----------------------------------------------------
        if ficha["selectable"] and "COL_select_%s" % nome not in selecoes:
            falhas.append("%s: declarado selecionável e sem COL_select" % nome)
        if not ficha["selectable"] and "COL_select_%s" % nome in selecoes:
            falhas.append("%s: tem COL_select e não é selecionável" % nome)
        sel = selecoes.get("COL_select_%s" % nome)
        if sel is not None:
            # A colisão sai da BASE. Maior que a silhueta rouba o toque do
            # vizinho — está na lista de revisão visual do pacote.
            if sel.scale.x > larg + 0.4 or sel.scale.y > fundo + 0.4:
                falhas.append(
                    "%s: COL_select (%.1f x %.1f) é maior que a peça "
                    "(%.1f x %.1f)" % (nome, sel.scale.x, sel.scale.y,
                                       larg, fundo))

        # -- exportação e nome -------------------------------------------
        fora = [o.name for o in objetos if o.name not in est.exportacao.objects]
        if fora:
            falhas.append("%s: %d peça(s) fora da coleção EXPORT" % (nome,
                                                                     len(fora)))
        if not ficha["id"].startswith("BRP_"):
            falhas.append("%s: id `%s` foge de BRP_<categoria>_<nome>_<variante>"
                          % (nome, ficha["id"]))

    return falhas


def main() -> int:
    pedidos = sys.argv[1:] or list(ESTUDIOS)

    # Um estúdio por processo: `preparar_cena()` apaga a cena inteira, então
    # validar dois no mesmo processo validaria o segundo duas vezes.
    if len(pedidos) > 1:
        total = 0
        for c in pedidos:
            r = subprocess.run([sys.executable, __file__, c])
            total += r.returncode
        return 1 if total else 0

    categoria = pedidos[0]
    if categoria not in ESTUDIOS:
        print("estúdio desconhecido: %s" % categoria)
        return 2

    falhas = validar(categoria)
    print("\n── %s ──" % categoria)
    if not falhas:
        print("  BRP BLENDER OK")
        return 0
    for f in falhas:
        print("  FALHOU  %s" % f)
    print("  %d problema(s)" % len(falhas))
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
