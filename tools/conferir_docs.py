#!/usr/bin/env python3
"""Confere a documentação em camadas do BR Port — item B5 do plano v3.

POR QUE ISTO EXISTE. Em 02/09 as camadas foram arrumadas, e a arrumação
sozinha não vale nada: o estado anterior também tinha nascido arrumado. O que
aconteceu depois foi silencioso e é o que este programa procura.

O `ESTADO_DO_PROJETO.md` tinha 20 KB quando o plano descreveu a dor e tinha
**42.707 bytes** quando se foi mexer nele — dobrou sem ninguém decidir dobrar.
E dentro dele conviviam TRÊS respostas para "por onde começo" (o cabeçalho
mandava a um briefing de 29/08, a tabela a outro de 28/08, e o rodapé dizia
para apontar o próprio arquivo) e DUAS parcelas do Sr. Ribeiro, R$8.000 e
R$550.000, ambas lidas como atuais.

Nenhum teste via nada disso, porque documento não compila.

Uso:
    python3 tools/conferir_docs.py

Espera `DOCS OK` na última linha. É a linha que o CI procura — o código de
saída sozinho não chega, pela mesma razão que vale para a suíte do Godot.
"""
import os
import re
import sys

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# As quatro camadas, e mais nenhuma. Quem quiser uma quinta muda esta lista de
# propósito, que é o ponto: passa a ser decisão em vez de acidente.
CAMADAS = [
    ("Regras",   "CLAUDE.md"),
    ("Estado",   "docs/ESTADO_DO_PROJETO.md"),
    ("Rumo",     "docs/design/BR_Port_Plano_v3_Claude_Code.md"),
    ("Decisões", "docs/decisoes"),
]

ARQUIVO = "docs/arquivo"

# TETO DO ESTADO — alarme de fumaça, não regra de estilo. Ele existe porque o
# modo de falhar medido foi o crescimento CALADO, não o tamanho em si. Subir
# este número é perfeitamente legítimo; o que não é legítimo é o documento
# dobrar sem ninguém reparar. Em 02/09 o arquivo ficou com ~18 KB.
TETO_ESTADO = 26000

# `00_INDICE.md` é citado na decisão 001 como um arquivo que NÃO veio no pacote
# de arte — é prosa sobre uma ausência, não uma referência a resolver. É a
# única exceção, e fica escrita aqui em vez de o conferidor ficar esperto.
AUSENTES_DE_PROPOSITO = {"00_INDICE.md"}

REF = re.compile(r'(?:\[[^\]]*\]\(([^)\s]+\.md)\)|`([^`\n]+?\.md)`)')

IGNORAR_PASTAS = {".git", ".godot", "node_modules", ".venv"}


def documentos():
    for dp, dn, fn in os.walk(RAIZ):
        dn[:] = [d for d in dn if d not in IGNORAR_PASTAS]
        for f in fn:
            if f.endswith(".md"):
                yield os.path.join(dp, f)


def main():
    falhas = []
    docs = sorted(documentos())

    # Índice de nomes-base: o repositório cita documentos pelo nome nu com
    # muita frequência (`ESTADO_DO_PROJETO.md`), e isso é convenção daqui, não
    # descuido. O que se exige é que o documento EXISTA — não que a citação
    # traga o caminho todo.
    por_nome = {}
    for d in docs:
        por_nome.setdefault(os.path.basename(d), []).append(d)

    # ── 1. As camadas existem ──────────────────────────────────────────────
    for papel, caminho in CAMADAS:
        if not os.path.exists(os.path.join(RAIZ, caminho)):
            falhas.append("camada %s: falta %s" % (papel, caminho))

    # ── 2. Toda referência de documento tem destino ────────────────────────
    for doc in docs:
        rel = os.path.relpath(doc, RAIZ)
        texto = open(doc, encoding="utf-8").read()
        for m in REF.finditer(texto):
            alvo = (m.group(1) or m.group(2)).strip()
            if alvo.startswith(("http", "#")) or "*" in alvo or "NNN" in alvo:
                continue
            if os.path.basename(alvo) in AUSENTES_DE_PROPOSITO:
                continue
            raizes = [os.path.dirname(doc), RAIZ,
                      os.path.join(RAIZ, "docs"), os.path.join(RAIZ, "brport_vs")]
            if any(os.path.exists(os.path.join(r, alvo)) for r in raizes):
                continue
            if os.path.basename(alvo) in por_nome and "/" not in alvo:
                continue
            falhas.append("%s aponta para %s, que não existe" % (rel, alvo))

    # ── 3. Registro de sessão vive no arquivo, e em nenhum outro lugar ─────
    # A regra é por FUNÇÃO, não por nome — mas o prefixo `BLOCO` é o sintoma
    # que se consegue conferir, e foi ele que encheu a raiz de `docs/` com 12
    # documentos, três deles chamados "briefing para continuar".
    for doc in docs:
        rel = os.path.relpath(doc, RAIZ).replace(os.sep, "/")
        if os.path.basename(rel).startswith("BLOCO") and not rel.startswith(ARQUIVO + "/"):
            falhas.append("%s é registro de sessão e devia estar em %s/" % (rel, ARQUIVO))

    # ── 4. O índice do arquivo cobre o que está lá ─────────────────────────
    # É o que torna "nada se apaga" verificável em vez de promessa: um
    # documento que entra no arquivo sem entrar no índice está enterrado.
    dir_arquivo = os.path.join(RAIZ, ARQUIVO)
    if os.path.isdir(dir_arquivo):
        indice = open(os.path.join(dir_arquivo, "README.md"), encoding="utf-8").read()
        for f in sorted(os.listdir(dir_arquivo)):
            if f == "README.md" or f.startswith("."):
                continue
            if f not in indice:
                falhas.append("%s/%s não está no índice do arquivo (README.md)" % (ARQUIVO, f))
    else:
        falhas.append("falta a pasta %s/" % ARQUIVO)

    # ── 5. O estado não voltou a inchar sem ninguém decidir ────────────────
    estado = os.path.join(RAIZ, "docs/ESTADO_DO_PROJETO.md")
    if os.path.exists(estado):
        tam = os.path.getsize(estado)
        if tam > TETO_ESTADO:
            falhas.append(
                "docs/ESTADO_DO_PROJETO.md tem %d bytes, acima do teto de %d. "
                "Ou o histórico desceu para docs/arquivo/HISTORICO.md, ou o teto "
                "sobe de propósito em tools/conferir_docs.py." % (tam, TETO_ESTADO))

    if falhas:
        print("DOCS FALHOU — %d problema(s):" % len(falhas))
        for f in falhas:
            print("  · %s" % f)
        return 1

    print("%d documentos, %d no arquivo, estado com %d bytes." % (
        len(docs), len(os.listdir(dir_arquivo)) - 1, os.path.getsize(estado)))
    print("=== DOCS OK — as camadas estão de pé e as referências resolvem ===")
    return 0


if __name__ == "__main__":
    sys.exit(main())
