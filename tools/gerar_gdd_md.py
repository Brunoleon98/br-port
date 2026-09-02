#!/usr/bin/env python3
"""Gera `docs/gdd/*.md` a partir do GDD 7 — item B6 do plano v3.

O GDD 7 são **5.658 linhas de JSX** numa aplicação React. Para citar uma regra
é preciso varrer o arquivo; para o carregar inteiro gasta-se o contexto que
faz falta para o trabalho. Foi assim que um erro de aritmética na economia da
Fase 1 sobreviveu até ao Bloco 3 — ninguém lê 5.658 linhas de JSX à procura de
uma soma.

**O `.jsx` continua a ser a fonte e a apresentação; o markdown é a leitura.**
Nada de conteúdo muda aqui: o GDD está congelado, e este programa só o
transcreve. Mesmo padrão dos sons, dos mapas e da tabela dos números — o CI
regenera e reprova se o versionado envelhecer.

Uso:
    python3 tools/gerar_gdd_md.py            # escreve docs/gdd/
    python3 tools/gerar_gdd_md.py --listar   # só diz o que sairia

O QUE ELE NÃO FAZ, DE PROPÓSITO: adivinhar. Toda estrutura de dados do GDD
tem a sua forma declarada em FORMAS, e uma chave que não esteja lá **reprova**
em vez de sumir do markdown. É a lição do A2 aplicada a outro documento: um
gerador que ignora o que não entende produz uma leitura incompleta que parece
completa, e ninguém descobre até precisar da parte que falta.
"""
import io
import json
import os
import subprocess
import sys
import tempfile

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
JSX = os.path.join(RAIZ, "docs/design/BR_Port_GDD_V7.jsx")
SAIDA = os.path.join(RAIZ, "docs/gdd")

# As formas que este gerador sabe desenhar. Chave = nome do campo no JSX,
# valor = as chaves de cada item. Uma forma nova reprova até alguém a
# ensinar aqui, que é o ponto.
FORMAS = {
    "fields":   ("label", "value"),
    "rows":     ("label", "value"),
    "items":    ("desc", "name"),
    "pillars":  ("desc", "icon", "name"),
    "npcs":     ("humor", "name", "personality", "role"),
    "phases":   ("city", "infra", "name", "num", "rep", "unlock", "visual"),
    "questions": ("decision", "q", "why"),
    "decisao":  ("detail", "icon", "summary", "title"),
}

CABECALHO = """<!-- GERADO por tools/gerar_gdd_md.py — NÃO EDITAR À MÃO.
     A fonte é docs/design/BR_Port_GDD_V7.jsx, e o CI reprova se este
     arquivo divergir dela. Para mudar o texto, mude o GDD. -->

"""

# O RODAPÉ VAI EM TODA PÁGINA, e não só nas de economia. O GDD está congelado
# na versão de antes da reescala de 02/09: `sistemas/economia.md` fala em
# parcelas de R$8.000/16.000/24.000 e traz um card "RISCO CRÍTICO" que a errata
# já matou, enquanto o jogo roda com R$550.000. Sem esta linha, este item teria
# criado um segundo endereço onde dois números do jogo convivem lidos como
# atuais — que é exatamente o defeito que o B5 acabou de tirar do ESTADO.
#
# Uniforme de propósito: um aviso posto só onde alguém achou que fazia falta é
# um aviso que falta na página seguinte.
RODAPE = """

---

*Página gerada de `docs/design/BR_Port_GDD_V7.jsx`, que está **congelado**.
Os números que o jogo usa HOJE estão em `docs/design/BR_Port_Numeros_Fase_1.md`,
gerados do `GameState.gd`; onde os dois divergirem, quem manda é o código, e
`docs/design/BR_Port_GDD_V7_ERRATA_ECONOMIA.md` explica por quê.*
"""


# ── Ler o JSX ──────────────────────────────────────────────────────────────

def literal(texto, nome, ocorrencia=0, abre="["):
    """O literal JS de `const <nome> = [` ou `{`, por casamento de
    delimitadores.

    Regex não serve e `str.index` do fecho também não: o conteúdo tem
    colchetes e chavetas dentro de string. O scanner salta string (com escape)
    E COMENTÁRIO — dentro destes blocos existem separadores `// ── ... ──`, e
    bastaria um apóstrofo num deles para o contador de aspas se desalinhar e
    o bloco fechar no sítio errado. Silenciosamente.
    """
    alvo = "const %s = %s" % (nome, abre)
    i = -1
    for n in range(ocorrencia + 1):
        # `index` cru daria `ValueError: substring not found`, que num log de
        # CI é um traceback sem endereço: quem o lê não sabe que o problema é
        # o GDD ter mudado de forma, nem qual literal sumiu.
        i = texto.find(alvo, i + 1)
        if i < 0:
            raise SystemExit(
                "GDD: não achei `%s` (ocorrência %d) em %s.\n"
                "     O .jsx mudou de forma — este gerador lê quatro literais: "
                "os dois `const sections`, `const questionGroups` e "
                "`const DECISIONS`." % (alvo, n + 1, os.path.relpath(JSX, RAIZ)))
    ini = i + len(alvo) - 1

    prof = 0
    j = ini
    dentro = esc = False
    aspas = ""
    while j < len(texto):
        c = texto[j]
        prox = texto[j + 1] if j + 1 < len(texto) else ""
        if dentro:
            if esc:
                esc = False
            elif c == "\\":
                esc = True
            elif c == aspas:
                dentro = False
        elif c == "/" and prox == "/":
            j = texto.find("\n", j)
            if j < 0:
                break
            continue
        elif c == "/" and prox == "*":
            j = texto.find("*/", j) + 1
            if j < 1:
                break
        elif c in "\"'`":
            dentro, aspas = True, c
        elif c in "[{":
            prof += 1
        elif c in "]}":
            prof -= 1
            if prof == 0:
                return texto[ini:j + 1]
        j += 1
    raise SystemExit("GDD: o literal `%s` não fecha — o JSX mudou de forma." % nome)


def ler_gdd():
    texto = io.open(JSX, encoding="utf-8").read()
    blocos = {
        "conceitos": literal(texto, "sections", 0),
        "sistemas":  literal(texto, "sections", 1),
        "perguntas": literal(texto, "questionGroups", 0),
        "decisoes":  literal(texto, "DECISIONS", 0, "{"),
    }
    # O Node avalia o literal. `json.loads` não serve — o JSX tem chave sem
    # aspas, aspas simples e vírgula sobrando, que são JS válido e JSON não.
    #
    # Por ARQUIVO, e não por `node -e`: os quatro literais somam ~180 KB e o
    # `execve` recusa-os com "Argument list too long", que é um erro de
    # sistema e não do programa — quem o visse ia depurar o lugar errado.
    js = "const d = {%s};\nprocess.stdout.write(JSON.stringify(d));" % ",".join(
        "%s: %s" % (k, v) for k, v in blocos.items())
    tmp = tempfile.NamedTemporaryFile("w", suffix=".mjs", delete=False,
                                      encoding="utf-8")
    try:
        tmp.write(js)
        tmp.close()
        r = subprocess.run([_node(), tmp.name], capture_output=True, text=True)
    finally:
        os.unlink(tmp.name)
    if r.returncode != 0:
        raise SystemExit("GDD: o Node recusou os literais do JSX:\n" + r.stderr)
    return json.loads(r.stdout)


def _node():
    for c in ("node", "nodejs"):
        try:
            subprocess.run([c, "--version"], capture_output=True, check=True)
            return c
        except (OSError, subprocess.CalledProcessError):
            pass
    raise SystemExit("GDD: preciso do Node para avaliar os literais do JSX.")


# ── Desenhar o markdown ────────────────────────────────────────────────────

def conferir_forma(campo, itens, onde):
    esperado = FORMAS[campo]
    for item in itens:
        visto = tuple(sorted(item.keys()))
        if visto != esperado:
            raise SystemExit(
                "GDD: em %s, `%s` traz %s e este gerador sabe desenhar %s.\n"
                "     Ensine a forma nova em FORMAS (tools/gerar_gdd_md.py) — "
                "ignorá-la faria o markdown perder conteúdo em silêncio."
                % (onde, campo, list(visto), list(esperado)))


def lista(campo, itens, onde):
    conferir_forma(campo, itens, onde)
    L = []
    if campo in ("fields", "rows"):
        L += ["| | |", "|---|---|"]
        L += ["| **%s** | %s |" % (i["label"], i["value"]) for i in itens]
    elif campo == "items":
        for i in itens:
            L += ["**%s** — %s" % (i["name"], i["desc"]), ""]
        L.pop()
    elif campo == "pillars":
        for i in itens:
            L += ["**%s %s** — %s" % (i["icon"], i["name"], i["desc"]), ""]
        L.pop()
    elif campo == "npcs":
        for i in itens:
            L += ["### %s — %s" % (i["name"], i["role"]), "",
                  i["personality"], "", "> %s" % i["humor"], ""]
        L.pop()
    elif campo == "phases":
        L += ["| Fase | Nome | Destrava | Reputação | Infra | Cidade | Visual |",
              "|---|---|---|---|---|---|---|"]
        L += ["| %s | %s | %s | %s | %s | %s | %s |" % (
            i["num"], i["name"], i["unlock"], i["rep"], i["infra"], i["city"],
            i["visual"]) for i in itens]
    return L


def desenhar_conceito(s):
    c = s["content"]
    onde = "conceitos/%s" % s["id"]
    L = ["# %s %s" % (s["icon"], c["title"]), "", "> %s" % c["subtitle"], "",
         "*%s*" % c["tagline"].strip('"'), ""]
    for campo in ("fields", "npcs", "pillars"):
        if campo in c:
            L += lista(campo, c[campo], onde) + [""]
    extras = set(c) - {"title", "subtitle", "tagline", "fields", "npcs", "pillars"}
    if extras:
        raise SystemExit("GDD: %s traz o campo desconhecido %s." % (onde, sorted(extras)))
    return "\n".join(L).rstrip() + "\n"


def desenhar_sistema(s, decisoes):
    onde = "sistemas/%s" % s["id"]
    L = ["# %s %s" % (s["icon"], s["title"]), "", s["intro"], ""]
    for sub in s["subsections"]:
        L += ["## %s" % sub["heading"], ""]
        if "decisions" in sub:
            chave = sub["decisions"]
            if chave not in decisoes:
                raise SystemExit("GDD: %s aponta para as decisões `%s`, que não "
                                 "existem." % (onde, chave))
            conferir_forma("decisao", decisoes[chave], onde)
            for d in decisoes[chave]:
                L += ["**%s %s** · %s" % (d["icon"], d["title"], d["summary"]), "",
                      d["detail"], ""]
        for campo in ("items", "rows", "npcs", "phases"):
            if campo in sub:
                L += lista(campo, sub[campo], onde) + [""]
        extras = set(sub) - {"heading", "decisions", "items", "rows", "npcs", "phases"}
        if extras:
            raise SystemExit("GDD: %s traz o campo desconhecido %s." % (onde, sorted(extras)))
    return "\n".join(L).rstrip() + "\n"


def desenhar_perguntas(grupos):
    L = ["# As perguntas de design, e o que se respondeu", "",
         "As perguntas que o GDD abriu e fechou, com o **porquê** de cada uma "
         "importar. É a camada que o resto do GDD pressupõe: as seções dizem "
         "*o que é*, isto diz *por que não é outra coisa*.", ""]
    for g in grupos:
        conferir_forma("questions", g["questions"], "perguntas/%s" % g["label"])
        L += ["## %s %s" % (g["icon"], g["label"]), ""]
        for q in g["questions"]:
            L += ["**%s**" % q["q"], "",
                  "*Por que importa:* %s" % q["why"], "",
                  "**Decidido:** %s" % q["decision"], ""]
    return "\n".join(L).rstrip() + "\n"


def desenhar_indice(conceitos, sistemas):
    L = ["# GDD 7 — a leitura por partes", "",
         "O GDD 7 é a fonte da verdade do design e **está congelado**. Ele vive "
         "em `docs/design/BR_Port_GDD_V7.jsx`, que é uma aplicação React de "
         "5.658 linhas: boa para apresentar, péssima para citar.", "",
         "Estas páginas são **geradas** dele por `tools/gerar_gdd_md.py`, uma "
         "seção por arquivo. Não as edite — o CI regenera e reprova a "
         "divergência. Para mudar o texto, mude o `.jsx`.", "",
         "⚠️ **O GDD descreve o jogo INTEIRO, das Fases 1 a 5.** O que está "
         "implementado é o Vertical Slice da Fase 1 — para isso, "
         "`docs/ESTADO_DO_PROJETO.md`. E a economia das Fases 2 e 3 tem uma "
         "errata que corrige o GDD: "
         "`docs/design/BR_Port_GDD_V7_ERRATA_ECONOMIA.md`.", "",
         "---", "",
         "## Sistemas — como o jogo funciona", "",
         "Inclui as decisões de design fechadas, resolvidas em cada seção.", ""]
    for s in sistemas:
        L.append("- [%s %s](sistemas/%s.md) — %s" % (s["icon"], s["title"], s["id"], s["label"]))
    L += ["", "## Conceitos — mundo, gente e economia", ""]
    for s in conceitos:
        L.append("- [%s %s](conceitos/%s.md) — %s" % (
            s["icon"], s["content"]["title"], s["id"], s["content"]["subtitle"]))
    L += ["", "## As perguntas", "",
          "- [As perguntas de design, e o que se respondeu](perguntas.md)", ""]
    return "\n".join(L).rstrip() + "\n"


def main():
    d = ler_gdd()
    paginas = {"README.md": desenhar_indice(d["conceitos"], d["sistemas"]),
               "perguntas.md": desenhar_perguntas(d["perguntas"])}
    for s in d["conceitos"]:
        paginas["conceitos/%s.md" % s["id"]] = desenhar_conceito(s)
    for s in d["sistemas"]:
        paginas["sistemas/%s.md" % s["id"]] = desenhar_sistema(s, d["decisoes"])

    if "--listar" in sys.argv:
        for nome in sorted(paginas):
            print("%-42s %6d bytes" % (nome, len(paginas[nome])))
        print("\n%d páginas" % len(paginas))
        return 0

    # Apaga o que sobrou de uma geração anterior: uma seção que saia do GDD
    # deixaria o arquivo dela para trás, e ninguém repararia.
    if os.path.isdir(SAIDA):
        for dp, _, fn in os.walk(SAIDA):
            for f in fn:
                if f.endswith(".md"):
                    os.remove(os.path.join(dp, f))
    for nome, texto in paginas.items():
        caminho = os.path.join(SAIDA, nome)
        os.makedirs(os.path.dirname(caminho), exist_ok=True)
        io.open(caminho, "w", encoding="utf-8").write(CABECALHO + texto + RODAPE)
    print("%d páginas em docs/gdd/ (%d conceitos, %d sistemas)." % (
        len(paginas), len(d["conceitos"]), len(d["sistemas"])))
    print("=== GDD OK — a leitura foi regerada do .jsx ===")
    return 0


if __name__ == "__main__":
    sys.exit(main())
