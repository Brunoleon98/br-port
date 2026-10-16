#!/usr/bin/env python3
"""Renumera uma decisão desta branch — e só as linhas que esta branch escreveu.

DOIS AGENTES NUMERAM DECISÕES EM PARALELO, e o número repete-se. O `AGENTS.md`
já o dizia, o `conferir_docs.py` reprova o repetido desde 09/10 — e em 16/10
aconteceu outra vez: esta ferramenta nasceu porque a `111` do catálogo de
mutantes, escrita numa branch, chegou atrás da `111` do cancelamento, que o
Codex fundiu primeiro (`docs/decisoes/119`). A regra manda renumerar a mais
nova; o que faltava era renumerá-la sem estragar nada.

⚠️ O PERIGO É O `sed` PELA ÁRVORE. Depois de juntar a `main`, os mesmos
arquivos citam as DUAS decisões com o mesmo número — o `CLAUDE.md`, o
`ESTADO_DO_PROJETO.md`, a regra de testes —, e trocar «`111`» em todo o lado
apaga as citações do outro agente. Daí a regra desta ferramenta: troca-se
apenas nas linhas que o `git diff base...HEAD` dá como ACRESCENTADAS por esta
branch. O que veio da `main` não se toca.

O que se troca, nessas linhas: «`111`», `docs/decisoes/111`, o nome do arquivo
da decisão, `"111"` entre aspas (o `de =` do catálogo de mutantes) e o título
`# 111 —`. Um `111` solto que sobrar é LISTADO e não trocado: pode ser um
número que não é decisão (R$111.975 é a margem do Ótimo), e quem decide é quem
lê.

Uso:
  python3 tools/renumerar_decisao.py 111 117              # mostra, não escreve
  python3 tools/renumerar_decisao.py 111 117 --aplicar    # escreve e faz git mv
  (--base origin/main por omissão; junte a `main` ANTES, senão a base mente)

Espera `RENUMERACAO OK`. Recusa-se com a árvore suja, com uma decisão que esta
branch não criou, e com um número novo que já exista na base ou aqui.
"""

from __future__ import annotations

import argparse
import os
import re
import subprocess
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parents[1]
DECISOES = "docs/decisoes"


def git(*args: str) -> str:
    return subprocess.run(["git", *args], cwd=RAIZ, check=True,
                          capture_output=True, text=True).stdout


def linhas_acrescentadas(base: str, caminho: str) -> set[int]:
    """Os números de linha, no HEAD, que esta branch acrescentou ao arquivo."""
    saida = git("diff", "-U0", "--no-color", f"{base}...HEAD", "--", caminho)
    novas: set[int] = set()
    for m in re.finditer(r"^@@ -\S+ \+(\d+)(?:,(\d+))? @@", saida, re.M):
        inicio, n = int(m.group(1)), int(m.group(2) or "1")
        novas.update(range(inicio, inicio + n))
    return novas


def padroes(antigo: str, novo: str, slug: str) -> list[tuple[re.Pattern, str]]:
    a = re.escape(antigo)
    return [
        (re.compile(rf"`{a}`"), f"`{novo}`"),
        (re.compile(rf"docs/decisoes/{a}(?!\d)"), f"docs/decisoes/{novo}"),
        (re.compile(rf"(?<![\w.]){a}-{re.escape(slug)}"), f"{novo}-{slug}"),
        (re.compile(rf'(?<![\d.,])"{a}"'), f'"{novo}"'),
        (re.compile(rf"^# {a} —"), f"# {novo} —"),
    ]


def trocar_arquivo(p: Path, conteudo: str) -> None:
    # Temporário, modo copiado e `os.replace` — as duas regras do `gerais.md`
    # sobre editar um arquivo do projeto por script.
    tmp = p.with_name(p.name + ".renumerar-tmp")
    tmp.write_text(conteudo, encoding="utf-8")
    os.chmod(tmp, p.stat().st_mode)
    os.replace(tmp, p)


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("antigo")
    ap.add_argument("novo")
    ap.add_argument("--base", default="origin/main")
    ap.add_argument("--aplicar", action="store_true")
    args = ap.parse_args()
    antigo, novo = args.antigo, args.novo
    if not (re.fullmatch(r"\d{3}", antigo) and re.fullmatch(r"\d{3}", novo)):
        raise SystemExit("os números são de três dígitos, como os da pasta.")

    if git("status", "--porcelain", "--untracked-files=no").strip():
        raise SystemExit("a árvore tem mudanças por commitar: os números de linha "
                         "vêm do HEAD, e com a árvore suja apontariam para outro "
                         "texto. Commite ou guarde antes.")

    mudados = git("diff", "--name-status", f"{args.base}...HEAD").splitlines()
    criadas = [l.split("\t")[-1] for l in mudados
               if l.startswith("A") and re.match(rf"{DECISOES}/{antigo}-", l.split("\t")[-1])]
    if len(criadas) != 1:
        raise SystemExit(f"esta branch não criou UMA decisão {antigo} em relação a "
                         f"{args.base} (achei {len(criadas)}). Renumera-se só a "
                         "decisão que é nossa.")
    origem = criadas[0]
    slug = re.match(rf"{DECISOES}/{antigo}-(.+)\.md$", origem).group(1)

    na_base = git("ls-tree", "--name-only", args.base, f"{DECISOES}/").splitlines()
    aqui = [f"{DECISOES}/{f}" for f in os.listdir(RAIZ / DECISOES)]
    ocupado = [f for f in na_base + aqui if re.match(rf"{DECISOES}/{novo}-", f)]
    if ocupado:
        raise SystemExit(f"o {novo} já existe: {sorted(set(ocupado))}. Rode "
                         "tools/conferir_colaboracao.py para o próximo livre.")

    trocas, soltos, arquivos = [], [], {}
    for linha in mudados:
        partes = linha.split("\t")
        if partes[0].startswith("D"):
            continue
        caminho = partes[-1]
        p = RAIZ / caminho
        try:
            texto = p.read_text(encoding="utf-8")
        except (UnicodeDecodeError, FileNotFoundError):
            continue
        novas = linhas_acrescentadas(args.base, caminho)
        linhas = texto.split("\n")
        mudou = False
        for i, l in enumerate(linhas, start=1):
            if i not in novas or antigo not in l:
                continue
            nova = l
            for padrao, troca in padroes(antigo, novo, slug):
                nova = padrao.sub(troca, nova)
            if nova != l:
                trocas.append((caminho, i, l.strip(), nova.strip()))
                linhas[i - 1] = nova
                mudou = True
            if re.search(rf"(?<![\d.,]){antigo}(?![\d.,])", nova):
                soltos.append((caminho, i, nova.strip()))
        if mudou:
            arquivos[p] = "\n".join(linhas)

    for caminho, i, antes, depois in trocas:
        print(f"  {caminho}:{i}\n      - {antes[:110]}\n      + {depois[:110]}")
    print(f"\n{len(trocas)} linha(s) a trocar em {len(arquivos)} arquivo(s); "
          f"{origem} → {DECISOES}/{novo}-{slug}.md")
    if soltos:
        print("\n⚠️ «%s» solto que NÃO foi trocado (leia e decida):" % antigo)
        for caminho, i, l in soltos:
            print(f"  {caminho}:{i}: {l[:120]}")

    if not args.aplicar:
        print("\nNada escrito — rode com --aplicar.")
        return 0
    for p, conteudo in arquivos.items():
        trocar_arquivo(p, conteudo)
    git("mv", origem, f"{DECISOES}/{novo}-{slug}.md")
    print(f"\nRENUMERACAO OK — {antigo} → {novo}; confira com "
          "`git diff` e rode tools/conferir_docs.py.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
