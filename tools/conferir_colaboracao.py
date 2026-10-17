#!/usr/bin/env python3
"""Antes do PR: o que acontece quando esta branch se juntar à base e aos outros.

ESTE REPOSITÓRIO TEM MAIS DE UM AGENTE, e o Bruno disse que terá mais. Cada um
trabalha numa branch a partir da `main`, e o que um não vê é o que o outro está
a escrever. Em 16/10 isso mordeu três vezes na mesma manhã, e nenhuma por
descuido: a decisão `111` desta branch chegou atrás da `111` que o Codex fundiu;
o briefing `2026-10-15b` foi criado pelos dois com o mesmo nome; e o
`ESTADO_DO_PROJETO.md` e o índice do arquivo conflitaram, como conflitam
sempre que duas sessões fecham (`docs/decisoes/119`).

O `conferir_docs.py` já apanha o número repetido — mas só no CI do PR, e só
contra o que já foi fundido. Esta ferramenta faz a pergunta antes, e também
contra o que AINDA não foi fundido: as branches dos outros agentes.

CONTRA A BASE (bloqueia o PR, código 1):
  - conflito de texto ao juntar (`git merge-tree`, sem tocar na árvore);
  - decisão nova desta branch com um número que a base já usa;
  - mutante do catálogo que a junção deixa órfão (o `antes` sumiu ou
    duplicou) — o job «Defeitos já provados» reprovaria o PR;
  - `SAVE_VERSION` mudada dos dois lados — duas migrações para o mesmo número.

CONTRA OS OUTROS (avisa, não bloqueia — quem fundir em segundo resolve, mas
sabê-lo agora custa um minuto): os mesmos quatro, mais os arquivos que os dois
mexem, com os de alto conflito marcados. A lista desses vive no `AGENTS.md` e
é lida de lá.

E no fim, os próximos nomes livres contando com TODOS: o número de decisão e
o sufixo do briefing de hoje.

Quem são «os outros»: `--outros REF...`, ou por omissão as branches remotas
com commit nos últimos `--dias` dias que a base ainda não contém. ⚠️ «Não
contido na base» sozinho não serve: em 16/10 eram 66 branches assim, quase
todas fundidas por squash há semanas. Um agente que trabalhe sem empurrar fica
invisível a qualquer ferramenta — o PR aberto é a fonte certa, e quem o lê
(pelo GitHub) passa a cabeça dele em `--outros`.

Uso:
  python3 tools/conferir_colaboracao.py
  python3 tools/conferir_colaboracao.py --outros origin/codex/tema
  python3 tools/conferir_colaboracao.py --sem-fetch --base origin/main

Espera `COLABORACAO OK`.
"""

from __future__ import annotations

import argparse
import datetime as dt
import re
import subprocess
import sys
import tomllib
from pathlib import Path

RAIZ = Path(__file__).resolve().parents[1]
DECISOES = "docs/decisoes"
ARQUIVO = "docs/arquivo"
CATALOGO = "tools/mutantes.toml"
GAMESTATE = "brport_vs/autoload/GameState.gd"

# Os documentos que TODA sessão fecha a escrever — o conflito neles é certo e
# barato: fica o texto do outro e reaplicam-se as próprias linhas.
PARTILHADOS = {"docs/ESTADO_DO_PROJETO.md", f"{ARQUIVO}/README.md"}


def git(*args: str, ok=(0,)) -> tuple[int, str]:
    r = subprocess.run(["git", *args], cwd=RAIZ, capture_output=True, text=True)
    if r.returncode not in ok:
        raise SystemExit(f"git {' '.join(args)} saiu com {r.returncode}:\n{r.stderr}")
    return r.returncode, r.stdout


def alto_conflito() -> list[str]:
    """Os arquivos de alto conflito, lidos do `AGENTS.md` — a lista vive lá."""
    texto = (RAIZ / "AGENTS.md").read_text(encoding="utf-8")
    m = re.search(r"São de alto conflito:(.*?)\.\n", texto, re.S)
    nomes = re.findall(r"`([^`]+)`", m.group(1)) if m else []
    if not nomes:
        # Amostra vazia é reprovação: sem a lista, nenhum arquivo seria de alto
        # conflito, e o relatório leria mais calmo do que é.
        raise SystemExit("não achei a lista «São de alto conflito:» no AGENTS.md.")
    # «e os mapas SVG» não é um caminho, e diz-se assim no texto de propósito.
    return nomes + ["brport_vs/art/*.svg"]


def casa(caminho: str, padroes: list[str]) -> bool:
    return any(Path(caminho).match(p) or caminho == p for p in padroes)


def merge_base(a: str, b: str) -> str:
    return git("merge-base", a, b)[1].strip()


def mudados(de: str, ate: str) -> set[str]:
    return set(git("diff", "--name-only", de, ate)[1].split())


def juntar(a: str, b: str) -> tuple[str, list[str]]:
    """(árvore da junção, arquivos em conflito). Não toca na árvore de trabalho."""
    rc, saida = git("merge-tree", "--write-tree", "--name-only", a, b, ok=(0, 1))
    linhas = saida.split("\n")
    arvore = linhas[0].strip()
    conflitos = []
    if rc == 1:
        for l in linhas[1:]:
            if not l.strip():
                break
            conflitos.append(l.strip())
    return arvore, conflitos


def ler(arvore: str, caminho: str) -> str | None:
    rc, saida = git("show", f"{arvore}:{caminho}", ok=(0, 128))
    return saida if rc == 0 else None


def decisoes(ref: str) -> dict[str, list[str]]:
    _, saida = git("ls-tree", "--name-only", ref, f"{DECISOES}/")
    por_numero: dict[str, list[str]] = {}
    for f in saida.split():
        m = re.match(rf"{DECISOES}/(\d{{3}})-", f)
        if m:
            por_numero.setdefault(m.group(1), []).append(f)
    return por_numero


def decisoes_novas(ref: str, base: str) -> dict[str, list[str]]:
    antes = {f for fs in decisoes(merge_base(ref, base)).values() for f in fs}
    return {n: [f for f in fs if f not in antes]
            for n, fs in decisoes(ref).items() if any(f not in antes for f in fs)}


def briefings(ref: str) -> set[str]:
    _, saida = git("ls-tree", "--name-only", ref, f"{ARQUIVO}/")
    return {Path(f).name for f in saida.split() if "BRIEFING_PROXIMA_CONVERSA_" in f}


# O NÚMERO DO BLOCO DE TESTE É O TERCEIRO ESPAÇO PARTILHADO (`119`). Em 16/10
# o PR #134 do Codex e esta branch criaram cada um o seu «T25», no mesmo sítio
# do `run_tests.gd`; o conflito de texto aparecia, a colisão do nome não. O que
# se lê são os rótulos entre aspas (`"T25: …"`, `"=== F12: …"`), que é o nome
# por que o bloco é citado nas decisões e no catálogo de mutantes.
BLOCO = re.compile(r'"[^"\n]*?\b([TFDRA]\d{1,3})[a-z]?[:.]')


def blocos(ref: str) -> set[str]:
    _, saida = git("ls-tree", "-r", "--name-only", ref, "brport_vs/tests/")
    achados: set[str] = set()
    for f in saida.split():
        if f.endswith(".gd"):
            achados |= set(BLOCO.findall(ler(ref, f) or ""))
    return achados


def save_version(ref: str) -> int | None:
    texto = ler(ref, GAMESTATE)
    m = re.search(r"^const SAVE_VERSION := (\d+)", texto or "", re.M)
    return int(m.group(1)) if m else None


def orfaos(arvore: str, catalogo_de: str, em_conflito: list[str]) -> list[str]:
    """Mutantes cujo `antes` não existe UMA vez na árvore dada.

    ⚠️ CORRE MESMO COM CONFLITO NOUTRO SÍTIO. A primeira versão saltava esta
    conferência sempre que a junção conflitava, e o defeito injetado mostrou o
    custo: um briefing com o mesmo nome nos dois ramos calou o mutante órfão no
    `GameState.gd` (`119`). A árvore do `merge-tree` traz o texto juntado de
    todo arquivo sem conflito; só o alvo que está ELE próprio em conflito fica
    para depois de resolvido.
    """
    texto = ler(catalogo_de, CATALOGO)
    if texto is None:
        return []
    queixas = []
    for m in tomllib.loads(texto).get("mutante", []):
        if m["alvo"] in em_conflito:
            continue
        alvo = ler(arvore, m["alvo"])
        n = 0 if alvo is None else alvo.count(m["antes"])
        if (n == 0) if m.get("todas", False) else (n != 1):
            queixas.append(f"{m['id']} ({m['alvo']}: o trecho aparece {n} vez(es))")
    return queixas


def outros_por_omissao(base: str, dias: int, excluir: set[str]) -> list[str]:
    _, saida = git("for-each-ref", "--format=%(refname:short) %(committerdate:unix)",
                   "refs/remotes/origin")
    limite = dt.datetime.now().timestamp() - dias * 86400
    achados = []
    for linha in saida.splitlines():
        ref, quando = linha.rsplit(" ", 1)
        if ref in excluir or ref.endswith("/HEAD") or float(quando) < limite:
            continue
        if git("merge-base", "--is-ancestor", ref, base, ok=(0, 1))[0] == 0:
            continue
        achados.append(ref)
    return sorted(achados)


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--base", default="origin/main")
    ap.add_argument("--outros", nargs="*", help="as cabeças dos PRs abertos dos outros")
    ap.add_argument("--dias", type=int, default=3)
    ap.add_argument("--sem-fetch", action="store_true")
    args = ap.parse_args()
    sys.stdout.reconfigure(line_buffering=True)

    if not args.sem_fetch:
        # UM refspec com curinga, e não uma lista de refs: `git fetch origin A B`
        # não atualiza o A quando o B não existe, e sai com 128 (`gerais.md`).
        git("fetch", "--prune", "origin", "+refs/heads/*:refs/remotes/origin/*")

    head = git("rev-parse", "--abbrev-ref", "HEAD")[1].strip()
    atras = int(git("rev-list", "--count", f"HEAD..{args.base}")[1])
    frente = int(git("rev-list", "--count", f"{args.base}..HEAD")[1])
    print(f"Base {args.base} ({git('rev-parse', '--short', args.base)[1].strip()}); "
          f"esta branch {head}: {frente} à frente, {atras} atrás.")

    bloqueios: list[str] = []
    avisos: list[str] = []
    altos = alto_conflito()

    # ── CONTRA A BASE ─────────────────────────────────────────────────────
    print("\nContra a base:")
    if atras:
        avisos.append(f"a branch está {atras} commit(s) atrás da base")
        print(f"  ⚠ {atras} commit(s) da base ainda não estão aqui: junte-a "
              f"(`git merge {args.base}`) e rode as suítes antes do PR")
    arvore, conflitos = juntar(args.base, "HEAD")
    if conflitos:
        bloqueios.append("conflito ao juntar com a base")
        print(f"  ✖ a junção com a base conflita em: {', '.join(conflitos)}")
    else:
        print("  ✔ a junção com a base não conflita")

    nossas = decisoes_novas("HEAD", args.base)
    da_base = decisoes(args.base)
    repetidas = [n for n in nossas if any(f not in nossas[n] for f in da_base.get(n, []))]
    if repetidas:
        bloqueios.append("número de decisão repetido")
        for n in repetidas:
            print(f"  ✖ a decisão {n} desta branch repete a da base "
                  f"({', '.join(da_base[n])}) — `tools/renumerar_decisao.py {n} <livre>`")
    else:
        print(f"  ✔ decisões novas desta branch: {', '.join(sorted(nossas)) or 'nenhuma'}"
              " — nenhuma repete a base")

    catalogo_de = arvore if ler(arvore, CATALOGO) is not None else "HEAD"
    perdidos = orfaos(arvore, catalogo_de, conflitos)
    if perdidos:
        bloqueios.append("mutante órfão na junção")
        print("  ✖ na junção ficam órfãos: " + "; ".join(perdidos))
    elif ler(catalogo_de, CATALOGO) is not None:
        print("  ✔ o catálogo de mutantes casa com o código da junção"
              + (" (menos os alvos em conflito)" if conflitos else ""))

    # O bloco de teste repetido contra a BASE — a primeira versão só o
    # conferia contra os outros ramos, e em 16/10 o T25 do Codex chegou à
    # `main` (PR #134) com o T25 desta branch ainda por fundir: o conflito de
    # texto aparecia, o nome repetido não.
    mb = merge_base("HEAD", args.base)
    blocos_repetidos = sorted((blocos("HEAD") - blocos(mb)) & (blocos(args.base) - blocos(mb)))
    if blocos_repetidos:
        bloqueios.append("bloco de teste repetido")
        print(f"  ✖ a base e esta branch criam o bloco {', '.join(blocos_repetidos)} — "
              "renumere o desta (rótulos, cabeçalho e documentos)")

    sv_mb, sv_base, sv_nos = (save_version(merge_base("HEAD", args.base)),
                              save_version(args.base), save_version("HEAD"))
    if sv_mb != sv_base and sv_mb != sv_nos and sv_base is not None:
        bloqueios.append("SAVE_VERSION mudada dos dois lados")
        print(f"  ✖ SAVE_VERSION mudou na base ({sv_mb}→{sv_base}) e aqui ({sv_mb}→{sv_nos})")

    # ── CONTRA OS OUTROS ──────────────────────────────────────────────────
    outros = (args.outros if args.outros is not None else
              outros_por_omissao(args.base, args.dias,
                                 {args.base, f"origin/{head}", head}))
    nossos_arquivos = mudados(merge_base("HEAD", args.base), "HEAD")
    todas_decisoes = set(da_base) | set(decisoes("HEAD"))
    todos_briefings = briefings(args.base) | briefings("HEAD")
    print(f"\nContra os outros ({len(outros)} ramo(s)"
          + ("" if args.outros is not None else f" com commit nos últimos {args.dias} dias")
          + "):")
    if not outros:
        print("  · nenhum — se há um PR aberto de outro agente, passe-o em --outros")
    for ref in outros:
        quando = git("log", "-1", "--format=%cs", ref)[1].strip()
        n = int(git("rev-list", "--count", f"{args.base}..{ref}")[1])
        print(f"  {ref} ({quando}, {n} commit(s) à frente da base)")
        todas_decisoes |= set(decisoes(ref))
        todos_briefings |= briefings(ref)

        dele = mudados(merge_base(ref, args.base), ref)
        comuns = sorted(nossos_arquivos & dele)
        _, conf = juntar("HEAD", ref)
        if conf:
            avisos.append(f"conflito com {ref}")
            certos = [c for c in conf if c in PARTILHADOS]
            outros_conf = [c for c in conf if c not in PARTILHADOS]
            if outros_conf:
                print(f"    ⚠ conflito ao juntar: {', '.join(outros_conf)}")
            if certos:
                print(f"    ⚠ conflito nos documentos de fecho (fica o texto de quem "
                      f"fundiu, e reaplicam-se as próprias linhas): {', '.join(certos)}")
        else:
            print("    ✔ junta sem conflito com esta branch")
        altos_comuns = [c for c in comuns if casa(c, altos)]
        if altos_comuns:
            avisos.append(f"alto conflito com {ref}")
            print(f"    ⚠ os dois mexem em arquivos de alto conflito: {', '.join(altos_comuns)}")
        if comuns:
            print(f"    · {len(comuns)} arquivo(s) mexido(s) pelos dois: "
                  + ", ".join(comuns[:8]) + (" …" if len(comuns) > 8 else ""))

        deles = decisoes_novas(ref, args.base)
        colidem = sorted(set(nossas) & set(deles))
        if colidem:
            avisos.append(f"decisão repetida com {ref}")
            print(f"    ⚠ as duas branches criam a decisão {', '.join(colidem)} — "
                  "quem fundir em segundo renumera (`tools/renumerar_decisao.py`)")
        elif deles:
            print(f"    ✔ decisões dele ({', '.join(sorted(deles))}) não repetem as desta")
        nossos_blocos = blocos("HEAD") - blocos(merge_base("HEAD", args.base))
        deles_blocos = blocos(ref) - blocos(merge_base(ref, args.base))
        if nossos_blocos & deles_blocos:
            avisos.append(f"bloco de teste repetido com {ref}")
            print("    ⚠ as duas branches criam o bloco de teste "
                  f"{', '.join(sorted(nossos_blocos & deles_blocos))} — quem fundir em "
                  "segundo renumera o seu (rótulos, cabeçalho e documentos)")
        nossos_b = briefings("HEAD") - briefings(args.base)
        deles_b = briefings(ref) - briefings(args.base)
        if nossos_b & deles_b:
            avisos.append(f"briefing repetido com {ref}")
            print(f"    ⚠ o mesmo briefing nos dois: {', '.join(sorted(nossos_b & deles_b))}")

        sv_ref = save_version(ref)
        sv_mb_ref = save_version(merge_base(ref, args.base))
        if sv_ref != sv_mb_ref and sv_nos != sv_mb:
            avisos.append(f"SAVE_VERSION com {ref}")
            print(f"    ⚠ os dois sobem a SAVE_VERSION ({sv_mb_ref}→{sv_ref} lá, "
                  f"{sv_mb}→{sv_nos} aqui)")

        arvore_dois, _ = juntar("HEAD", ref)
        # ⚠️ E O PRÓPRIO CATÁLOGO PODE ESTAR EM CONFLITO — os dois agentes
        # acrescentam mutantes no fim dele —, e então o texto juntado traz as
        # marcas de conflito e não se lê: a ferramenta rebentava a meio, sem
        # veredito (`127`, com o PR #140). Confere-se cada um dos dois
        # catálogos contra a árvore juntada.
        if CATALOGO in conf:
            perdidos = orfaos(arvore_dois, "HEAD", conf) + orfaos(arvore_dois, ref, conf)
        else:
            catalogo_dois = arvore_dois if ler(arvore_dois, CATALOGO) is not None \
                else "HEAD"
            perdidos = orfaos(arvore_dois, catalogo_dois, conf)
        if perdidos:
            avisos.append(f"mutante órfão com {ref}")
            print("    ⚠ quando os dois se juntarem ficam órfãos: " + "; ".join(perdidos))

    # ── OS PRÓXIMOS NOMES LIVRES ─────────────────────────────────────────
    livre = max(int(n) for n in todas_decisoes) + 1
    hoje = dt.date.today().isoformat()
    sufixos = [""] + [chr(c) for c in range(ord("b"), ord("z") + 1)]
    briefing = next(f"BRIEFING_PROXIMA_CONVERSA_{hoje}{s}.md" for s in sufixos
                    if f"BRIEFING_PROXIMA_CONVERSA_{hoje}{s}.md" not in todos_briefings)
    print(f"\nPróxima decisão livre, contando a base, esta branch e os outros: {livre:03d}")
    print(f"Próximo briefing livre para hoje: {ARQUIVO}/{briefing}")

    if bloqueios:
        print(f"\nBLOQUEADO — {len(bloqueios)} problema(s) contra a base: "
              + "; ".join(bloqueios) + ".")
        return 1
    print(f"\nCOLABORACAO OK — nada bloqueia o PR contra a base; "
          f"{len(avisos)} aviso(s) sobre os outros ramos.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
