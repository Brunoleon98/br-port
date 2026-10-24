#!/usr/bin/env python3
"""Medição (não é ferramenta do projeto): cobertura por FUNÇÃO dos scripts do
jogo, numa CÓPIA do projeto.

instrumentar COPIA        põe uma sonda no início de cada função dos scripts
                          do jogo e um autoload que despeja as sondas no fim;
                          escreve COPIA/../cobertura_mapa.json (id -> função)
ler COPIA DESPEJO...      cruza os despejos com o mapa e imprime o relatório

A sonda é `if not Engine.has_meta(&"cN"): Engine.set_meta(&"cN", 1)`: o
`Engine` existe em qualquer script (estático, `class_name`, antes dos
autoloads), e a meta morre com o processo — quem a despeja é o autoload
`_Cobertura`, no `_exit_tree`, para o arquivo da variável COBERTURA.
"""
import glob, json, os, re, sys

PASTAS = ["autoload/*.gd", "scripts/*.gd", "scenes/**/*.gd"]
DEF = re.compile(r"^(\s*)(?:static\s+)?func\s+(\w+)\s*\(")


def _sem_strings(linha: str) -> str:
    """Tira strings e comentário de uma linha, para contar parênteses."""
    out, i, q = [], 0, None
    while i < len(linha):
        c = linha[i]
        if q:
            if c == "\\": i += 2; continue
            if c == q: q = None
            i += 1; continue
        if c in "\"'": q = c; i += 1; continue
        if c == "#": break
        out.append(c); i += 1
    return "".join(out)


def _fim_da_assinatura(linhas, i):
    """Devolve (j, col): a linha e a coluna (na linha ORIGINAL) do ':' que
    fecha a assinatura — fora de string, de parênteses e de comentário."""
    prof = 0; j = i
    while j < len(linhas):
        s = linhas[j]; q = None; col = 0
        while col < len(s):
            c = s[col]
            if q:
                if c == "\\": col += 2; continue
                if c == q: q = None
            elif c in "\"'": q = c
            elif c == "#": break
            elif c in "([{": prof += 1
            elif c in ")]}": prof -= 1
            elif c == ":" and prof == 0:
                return j, col
            col += 1
        j += 1
    raise ValueError("assinatura sem ':' a partir da linha %d" % (i + 1))


def instrumentar(copia):
    mapa = {}; n = 0; uma_linha = 0
    for padrao in PASTAS:
        for arq in sorted(glob.glob(os.path.join(copia, padrao), recursive=True)):
            rel = os.path.relpath(arq, copia)
            if rel.startswith(("tests/", "tools/", "scripts/validation/")):
                continue
            linhas = open(arq, encoding="utf-8").read().split("\n")
            saida = []; i = 0
            while i < len(linhas):
                m = DEF.match(linhas[i])
                if not m:
                    saida.append(linhas[i]); i += 1; continue
                j, col = _fim_da_assinatura(linhas, i)
                saida.extend(linhas[i:j])
                # A coluna é sobre a linha SEM strings; a assinatura raramente
                # tem string antes do ':' final, e confere-se abaixo.
                lj = linhas[j]
                resto = _sem_strings(lj[col + 1:]).strip()
                n += 1; cid = "c%d" % n
                mapa[cid] = {"arquivo": rel, "funcao": m.group(2), "linha": i + 1}
                ind_def = len(m.group(1).expandtabs(4))
                sonda = 'if not Engine.has_meta(&"%s"): Engine.set_meta(&"%s", 1)' % (cid, cid)
                if resto:
                    # Função de uma linha: parte-se em duas.
                    uma_linha += 1
                    pre, corpo = lj[:col + 1], lj[col + 1:]
                    ind = m.group(1) + "\t"
                    saida += [pre, ind + sonda, ind + corpo.strip()]
                    i = j + 1; continue
                saida.append(lj)
                # Indentação do corpo: a primeira linha com código a seguir.
                k = j + 1
                while k < len(linhas) and (not linhas[k].strip() or linhas[k].strip().startswith("#")):
                    k += 1
                corpo_ind = re.match(r"^(\s*)", linhas[k]).group(1) if k < len(linhas) else ""
                if len(corpo_ind.expandtabs(4)) <= ind_def:
                    raise ValueError("%s:%d: corpo vazio" % (rel, j + 1))
                saida.append(corpo_ind + sonda)
                i = j + 1
            open(arq, "w", encoding="utf-8").write("\n".join(saida))
    # O autoload que despeja.
    open(os.path.join(copia, "_Cobertura.gd"), "w").write(
        "extends Node\n\n"
        "func _exit_tree() -> void:\n"
        "\tvar p := OS.get_environment(\"COBERTURA\")\n"
        "\tif p == \"\":\n\t\treturn\n"
        "\tvar f := FileAccess.open(p, FileAccess.WRITE)\n"
        "\tfor nome in Engine.get_meta_list():\n"
        "\t\tif String(nome).begins_with(\"c\"):\n"
        "\t\t\tf.store_line(String(nome))\n"
        "\tf.close()\n")
    pg = os.path.join(copia, "project.godot")
    txt = open(pg, encoding="utf-8").read()
    txt = txt.replace("[autoload]\n", '[autoload]\n\n_Cobertura="*res://_Cobertura.gd"\n', 1)
    assert "_Cobertura" in txt
    open(pg, "w", encoding="utf-8").write(txt)
    json.dump(mapa, open(os.path.join(copia, "..", "cobertura_mapa.json"), "w"), indent=0)
    print("%d funções instrumentadas (%d de uma linha, partidas)" % (n, uma_linha))


def ler(copia, despejos):
    mapa = json.load(open(os.path.join(copia, "..", "cobertura_mapa.json")))
    vistos = {}
    for d in despejos:
        nome = os.path.basename(d)
        for l in open(d):
            vistos.setdefault(l.strip(), set()).add(nome)
    por_arq = {}
    for cid, f in mapa.items():
        por_arq.setdefault(f["arquivo"], []).append((cid, f))
    tot = len(mapa); cob = sum(1 for c in mapa if c in vistos)
    print("funções: %d; executadas por alguma suíte: %d (%.0f%%)" % (tot, cob, 100 * cob / tot))
    linhas = []
    for arq, fs in por_arq.items():
        nao = [f["funcao"] for cid, f in fs if cid not in vistos]
        linhas.append((len(nao), len(fs), arq, nao))
    for nao, total, arq, nomes in sorted(linhas, key=lambda x: (-x[0], x[2])):
        if nao:
            print("%3d de %3d sem execução  %s: %s" % (nao, total, arq, ", ".join(nomes)))
    json.dump({cid: sorted(v) for cid, v in vistos.items()},
              open(os.path.join(copia, "..", "cobertura_vistos.json"), "w"))


if __name__ == "__main__":
    if sys.argv[1] == "instrumentar":
        instrumentar(sys.argv[2])
    else:
        ler(sys.argv[2], sys.argv[3:])
