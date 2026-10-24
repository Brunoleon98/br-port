#!/usr/bin/env python3
"""Medição (não é ferramenta do projeto): mutação AMOSTRADA nas funções que
as suítes executam, para achar onde um defeito plausível passa verde.

gerar RAIZ VISTOS MAPA SAIDA.json [--por-arquivo K] [--semente S]
    sorteia até K mutantes por arquivo de jogo, só em funções que alguma
    suíte executou (VISTOS/MAPA vêm do cobertura.py)
rodar COPIA ARQ.json IDS... --saida DIR
    aplica cada um na cópia, corre as seis suítes da mais rápida para a
    mais lenta e pára na primeira que não passa; restaura por bytes
"""
import json, os, random, re, subprocess, sys, time, shutil
from pathlib import Path

SUITES = [  # da mais rápida para a mais lenta (medido em 24/10)
    ("teste_audio", "res://tests/teste_audio.gd", "AUDIO OK", 0.5),
    ("teste_registro", "res://tests/teste_registro.gd", "REGISTRO OK", 0.7),
    ("asset_validator", "res://scripts/validation/asset_validator.gd", "ASSET OK", 11),
    ("teste_fumaca", "res://tests/teste_fumaca.gd", "FUMACA OK", 15),
    ("run_tests", "res://tests/run_tests.gd", "TODOS OS TESTES PASSARAM", 33),
    ("teste_design", "res://tests/teste_design.gd", "DESIGN OK", 56),
]
COMPILA = re.compile(r"Parse Error|Compile Error|GDScript::reload|Failed to load script")
REPROVA = re.compile(r"^\s*(?:FAIL|FALHA|FALHOU)\s+(.+?)\s*$", re.M)
ERRO = re.compile(r"SCRIPT ERROR")

TROCAS_REL = [(" <= ", " < "), (" >= ", " > "), (" < ", " <= "), (" > ", " >= "),
              (" == ", " != "), (" != ", " == ")]


def _codigo(linha):
    """A parte de código da linha (sem comentário), e se tem string."""
    q = None
    for i, c in enumerate(linha):
        if q:
            if c == q: q = None
        elif c in "\"'": q = c
        elif c == "#": return linha[:i]
    return linha


def candidatos(linha):
    """As mutações possíveis numa linha de corpo de função."""
    cod = _codigo(linha); s = cod.strip(); ind = cod[:len(cod) - len(cod.lstrip())]
    out = []
    if not s or s.startswith(("func ", "static func", "@", "class ", "signal ", "enum ")):
        return out
    # Strings: não mexer dentro delas — só trocas cujo trecho não esteja em aspas.
    def fora_de_aspas(trecho):
        i = cod.find(trecho)
        return i >= 0 and cod[:i].count('"') % 2 == 0 and cod[:i].count("'") % 2 == 0
    for a, b in TROCAS_REL:
        if a in cod and fora_de_aspas(a) and "->" not in cod.split(a)[0][-3:]:
            out.append(("rel", cod.replace(a, b, 1)))
    for a, b in ((" and ", " or "), (" or ", " and ")):
        if a in cod and fora_de_aspas(a):
            out.append(("logico", cod.replace(a, b, 1)))
    m = re.match(r"^(\s*(?:if|elif|while)\s+)not\s+", cod)
    if m:
        out.append(("not", cod.replace(m.group(0), m.group(1), 1)))
    for a, b in (("+=", "-="), ("-=", "+=")):
        if a in cod and fora_de_aspas(a):
            out.append(("aritm", cod.replace(a, b, 1)))
    for a, b in (("return true", "return false"), ("return false", "return true"),
                 ("= true", "= false"), ("= false", "= true")):
        if a in cod and fora_de_aspas(a):
            out.append(("bool", cod.replace(a, b, 1)))
    mnum = re.search(r"(?<![\w.\"])(\d+)(?![\w.])", cod)
    if mnum and fora_de_aspas(mnum.group(1)) and not s.startswith("const "):
        n = int(mnum.group(1))
        out.append(("const", cod[:mnum.start()] + str(n + 1) + cod[mnum.end():]))
    # Apagar a instrução: só as simples (atribuição, chamada, +=), nunca a
    # que declara (`var`) nem a que abre bloco (termina em ':').
    if (not s.startswith(("var ", "const ", "return", "if ", "elif ", "else", "for ",
                          "while ", "match ", "pass", "break", "continue", "await "))
            and not s.endswith((":", "(", "[", "{", ",", "\\")) and s.count("(") == s.count(")")
            and s.count("[") == s.count("]") and s.count("{") == s.count("}")):
        out.append(("apagar", ind + "pass"))
    return [(t, d) for t, d in out if d != cod]


def gerar(raiz, vistos, mapa, saida, k, semente):
    vistos = json.load(open(vistos)); mapa = json.load(open(mapa))
    rng = random.Random(semente)
    # Função -> intervalo de linhas (do mapa: linha da def; até à próxima def).
    por_arq = {}
    for cid, f in mapa.items():
        por_arq.setdefault(f["arquivo"], []).append((f["linha"], cid, f["funcao"]))
    muts = []
    for arq, defs in sorted(por_arq.items()):
        defs.sort()
        caminho = os.path.join(raiz, "brport_vs", arq)
        texto = open(caminho, encoding="utf-8").read(); linhas = texto.split("\n")
        sitios = []
        for i, (l0, cid, nome) in enumerate(defs):
            if cid not in vistos:
                continue
            l1 = defs[i + 1][0] - 1 if i + 1 < len(defs) else len(linhas)
            for ln in range(l0, l1):            # l0 é 1-based da def -> corpo a seguir
                for tipo, depois in candidatos(linhas[ln]):
                    sitios.append((ln, nome, tipo, depois))
        rng.shuffle(sitios)
        escolhidos = 0; linhas_usadas = set()
        for ln, nome, tipo, depois in sitios:
            if escolhidos >= k: break
            if ln in linhas_usadas: continue
            antes = linhas[ln]
            # Contexto até ser único no arquivo.
            a0 = ln
            while texto.count("\n".join(linhas[a0:ln + 1])) != 1 and a0 > 0 and ln - a0 < 4:
                a0 -= 1
            bloco = "\n".join(linhas[a0:ln + 1])
            if texto.count(bloco) != 1: continue
            novo = "\n".join(linhas[a0:ln] + [depois + linhas[ln][len(_codigo(linhas[ln])):]])
            muts.append({"id": "%s:%d:%s" % (os.path.basename(arq)[:-3], ln + 1, tipo),
                         "alvo": "brport_vs/" + arq, "funcao": nome, "tipo": tipo,
                         "antes": bloco, "depois": novo})
            linhas_usadas.add(ln); escolhidos += 1
    json.dump(muts, open(saida, "w"), ensure_ascii=False, indent=1)
    print("%d mutantes sorteados em %d arquivos" % (len(muts), len({m['alvo'] for m in muts})))


def rodar(copia, arq_json, ids, saida, godot):
    todos = {m["id"]: m for m in json.load(open(arq_json))}
    saida = Path(saida); saida.mkdir(parents=True, exist_ok=True)
    resultados = []
    for mid in ids:
        m = todos[mid]; alvo = Path(copia) / m["alvo"]
        original = alvo.read_bytes(); modo = alvo.stat().st_mode
        a, d = m["antes"].encode(), m["depois"].encode()
        assert original.count(a) == 1, mid
        tmp = alvo.with_name(alvo.name + ".tmp"); tmp.write_bytes(original.replace(a, d, 1))
        os.chmod(tmp, modo); os.replace(tmp, alvo)
        r = {"id": mid, "morto_por": None, "rotulos": [], "compila": True, "segundos": 0.0}
        t0 = time.monotonic()
        try:
            for nome, script, marcador, base in SUITES:
                perfil = saida / ("perfil-" + mid.replace(":", "_") + "-" + nome)
                perfil.mkdir(parents=True, exist_ok=True)
                amb = dict(os.environ, XDG_DATA_HOME=str(perfil), APPDATA=str(perfil))
                try:
                    p = subprocess.run([godot, "--headless", "--path", str(Path(copia) / "brport_vs"),
                                        "--script", script], stdout=subprocess.PIPE,
                                       stderr=subprocess.STDOUT, env=amb, timeout=max(60, 4 * base))
                    txt = p.stdout.decode("utf-8", "replace"); esgotou = False
                except subprocess.TimeoutExpired as e:
                    txt = (e.stdout or b"").decode("utf-8", "replace"); esgotou = True
                shutil.rmtree(perfil, ignore_errors=True)
                if COMPILA.search(txt):
                    r["compila"] = False; r["morto_por"] = nome
                    (saida / (mid.replace(":", "_") + ".log")).write_text(txt); break
                if esgotou or marcador not in txt or ERRO.search(txt):
                    r["morto_por"] = nome + (" (teto)" if esgotou else "")
                    r["rotulos"] = REPROVA.findall(txt)[:5]
                    if ERRO.search(txt) and marcador in txt:
                        r["morto_por"] = nome + " (só SCRIPT ERROR)"
                    (saida / (mid.replace(":", "_") + ".log")).write_text(txt); break
        finally:
            tmp = alvo.with_name(alvo.name + ".tmp"); tmp.write_bytes(original)
            os.chmod(tmp, modo); os.replace(tmp, alvo)
            assert alvo.read_bytes() == original
        r["segundos"] = time.monotonic() - t0
        resultados.append(r)
        print("%-9s %s  %s" % ("SOBREVIVE" if r["morto_por"] is None else "morto", mid,
                               r["morto_por"] or ""), flush=True)
        json.dump(resultados, open(saida / "resultados.json", "w"), ensure_ascii=False, indent=1)


if __name__ == "__main__":
    if sys.argv[1] == "gerar":
        k = int(sys.argv[sys.argv.index("--por-arquivo") + 1]) if "--por-arquivo" in sys.argv else 3
        s = int(sys.argv[sys.argv.index("--semente") + 1]) if "--semente" in sys.argv else 20261024
        gerar(sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5], k, s)
    else:
        i = sys.argv.index("--saida")
        rodar(sys.argv[2], sys.argv[3], sys.argv[4:i], sys.argv[i + 1], os.environ["G"])
