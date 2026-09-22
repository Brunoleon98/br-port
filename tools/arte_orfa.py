#!/usr/bin/env python3
"""BR Port — que arte existe no disco e NÃO chega à tela.

POR QUE ISTO EXISTE. Toda a maquinaria de validação deste projeto pergunta se
o que está na CENA existe no disco: o `asset_validator` percorre o manifest, o
teste de design percorre as âncoras, o de fumaça percorre os ícones. **Nenhuma
pergunta o contrário**, e o repositório já foi mordido três vezes por isso — o
`barco_medio` renderizado, validado e nunca posto em doca nenhuma; o
`doca_concreto`, que só um teste não exportado refere; e a pasta `art/brp`
inteira, que o mapa em SVG substituiu sem nunca ter sido retirada do catálogo.

⚠️ ISTO É UM RELATÓRIO, NÃO UM PORTÃO. Hoje ele encontra órfãos de verdade, e
o que fazer com cada um — entra no jogo, ou sai do catálogo — é decisão do
Bruno, não de quem varre. O `--reprovar` existe para o dia em que essa decisão
estiver tomada: a partir daí, um órfão NOVO passa a ser vermelho.

⚠️ «ÓRFÃO» E «APAGÁVEL» SÃO DUAS PERGUNTAS, e esta varredura só faz a
primeira. Medido em 22/09, ao triar os onze que ela relatava: **nove deles
têm propósito ESCRITO** — os oito de `art/brp/` e o `doca_concreto` servem a
`scenes/tests/AssetPlacementTest.tscn`, que esta ferramenta exclui DE
PROPÓSITO (teste não põe arte no jogo), e o `art/brp/README.md` até nomeia a
condição para voltarem: reabrir a `docs/decisoes/001`. Só DOIS não eram
referidos por coisa nenhuma — os SVG de píer da raiz, superados por props PNG
do mesmo nome —, e foram esses que saíram (`docs/decisoes/046`). Quem ler o
relatório e contar apagáveis conta a mais.

⚠️ E APAGAR UM DOS NOVE REPROVA O `asset_validator`. Eles estão no
`BRP_EXPORT_MANIFEST.json`, e o validador diz «no manifest e não no disco»:
medido com o defeito posto, código 1 e nove problemas. A entrada do manifest
sai junto com o arquivo, ou não sai nenhum dos dois.

⚠️ E DISCO NÃO É PACOTE, que é o número que decide se vale a pena. Os onze
mediam 687 KB em disco e **282 KB no `.pck`** (4,49%), porque o que embarca é
o `.ctex` comprimido. Eles embarcam mesmo sem serem referidos, porque o
preset é `export_filter="all_resources"` e o export não faz tree-shaking — o
`exclude_filter` tira a CENA de teste e não tira a ARTE que ela usa. Os dois
que saíram valiam 3.516 bytes: isto foi arrumação, não tamanho.

⚠️ E OS COMENTÁRIOS SÃO CORTADOS ANTES DA BUSCA, que é a armadilha desta
varredura e já mordeu neste repositório: a lição escrita sobre um prop órfão
NOMEIA o prop, e uma busca ingénua acha o nome no comentário que explica que
ele não é usado — e dá-o por vivo. Cortar comentário de linha inteira não
chega: um `# como o galpao.png` no fim de uma linha de código faria o mesmo.
Por isso a varredura corta do `#` até ao fim da linha sempre que ele estiver
FORA de aspas, e só aí procura.

Uso:
    python3 tools/arte_orfa.py [--reprovar]
"""
import os
import sys

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ARTE = os.path.join(RAIZ, "brport_vs", "art")

# Onde um asset conta como USADO. `tools/` e `scenes/tests/` ficam de fora de
# propósito: uma ferramenta que fotografa um prop e um teste que o instancia
# não o põem no jogo — foi exactamente assim que o `doca_concreto` passou por
# vivo durante duas sessões.
# ⚠️ E A CONFIGURAÇÃO CONTA COMO FONTE. As duas camadas do ícone adaptativo do
# Android não aparecem em cena nenhuma — vivem no `export_presets.cfg` —, e a
# primeira corrida desta ferramenta deu-as por órfãs. Validador que reprova o
# que está certo gasta-se depressa.
FONTES = [("brport_vs", (".gd", ".tscn", ".tres", ".godot", ".cfg"))]
FORA = ("brport_vs/scenes/tests", "brport_vs/tools", "brport_vs/tests")

# O que não é arte: a papelada do importador e a tabela que sai do gerador.
NAO_E_ARTE = (".import", ".uid", ".json", ".md")


def sem_comentarios(texto: str) -> str:
    """Corta `#` até ao fim da linha quando ele está fora de aspas."""
    saida = []
    for linha in texto.splitlines():
        aspas = ""
        corte = len(linha)
        i = 0
        while i < len(linha):
            c = linha[i]
            if aspas:
                if c == "\\":
                    i += 2
                    continue
                if c == aspas:
                    aspas = ""
            elif c in "\"'":
                aspas = c
            elif c == "#":
                corte = i
                break
            i += 1
        saida.append(linha[:corte])
    return "\n".join(saida)


def corpo_do_projeto() -> str:
    pedacos = []
    for base, exts in FONTES:
        for dp, dn, fn in os.walk(os.path.join(RAIZ, base)):
            rel = os.path.relpath(dp, RAIZ).replace(os.sep, "/")
            if any(rel == f or rel.startswith(f + "/") for f in FORA):
                continue
            if "/.godot" in "/" + rel:
                continue
            for f in fn:
                if not f.endswith(exts):
                    continue
                caminho = os.path.join(dp, f)
                try:
                    with open(caminho, encoding="utf-8", errors="replace") as fh:
                        pedacos.append(sem_comentarios(fh.read()))
                except OSError:
                    pass
    return "\n".join(pedacos)


def main() -> int:
    corpo = corpo_do_projeto()
    total = 0
    orfaos = {}
    for dp, dn, fn in os.walk(ARTE):
        pasta = os.path.relpath(dp, ARTE).replace(os.sep, "/")
        for f in sorted(fn):
            if f.endswith(NAO_E_ARTE):
                continue
            total += 1
            # Procura-se pelo nome COM extensão: `pier_n1` aparece em prosa e
            # em nomes de nó, `pier_n1.png` só aparece num caminho.
            if f not in corpo:
                orfaos.setdefault(pasta if pasta != "." else "(raiz)", []).append(f)

    n = sum(len(v) for v in orfaos.values())
    for pasta in sorted(orfaos):
        print("art/%s — %d sem uso:" % (pasta, len(orfaos[pasta])))
        for f in orfaos[pasta]:
            print("    %s" % f)
    print("ARTE: %d de %d arquivos não são referidos por cena nem por script"
          % (n, total))
    print("(fora da conta: %s — ferramenta e teste não põem arte no jogo)"
          % ", ".join(FORA))
    if n and "--reprovar" in sys.argv:
        return 1
    return 0


sys.exit(main())
