#!/usr/bin/env python3
"""Reinjeta, a cada corrida, os defeitos que já provaram uma guarda.

O ITEM 7 DO FECHO PEDE UM DEFEITO INJETADO POR GUARDA NOVA, e o projeto
cumpre-o: em 15/10 eram 166 menções em 64 das 109 decisões. Só que cada um
corria UMA vez, à mão (`cp`, editar, rodar, restaurar), e ficava escrito em
prosa — «o `retirar` esquecido (M2)». Nada voltava a perguntar se a guarda
ainda o apanhava, e as regras contam as maneiras de ela deixar de apanhar sem
ninguém ver: a sonda presa a um funil que deixou de ser único, a regra que
passou a existir em dois sítios, o bloco que um refactor esvaziou. Cada uma foi
descoberta por acaso, sessões depois (`docs/decisoes/117`).

Este é o lugar onde o defeito fica. `tools/mutantes.toml` guarda cada um como
uma troca EXATA de texto num arquivo do jogo, com a suíte e a guarda que o têm
de reprovar; esta ferramenta aplica-os um de cada vez e exige, de cada um:

  1. que o texto a trocar exista UMA vez no alvo — senão o código mudou e o
     defeito deixou de existir com ele (mutante ÓRFÃO). Reprova, e quem mexeu
     no código reescreve o defeito contra a forma nova: a lição viaja com o
     refactor em vez de morrer nele;
  2. que a suíte NÃO imprima o marcador de sucesso (o defeito SOBREVIVEU);
  3. que o mutante compile — um erro de compilação derruba a suíte inteira e
     reprova tudo, que é verde de graça com cara de vermelho
     (`testes-e-guardas.md`, «renomear só a declaração parte o script»);
  4. que acabe dentro do teto — a quarta forma de falhar é não acabar;
  5. que entre as linhas reprovadas esteja a GUARDA declarada, e não uma
     vizinha («confira que quem reprovou foi a guarda que se estava a testar»).

E entre um defeito e o seguinte, o arquivo volta ao original BYTE A BYTE, da
cópia em memória e nunca do `git`, que não sabe o que ainda não foi commitado.
A base corre antes (tem de passar, senão não há o que medir) e no fim.

⚠️ O `user://` DESTAS CORRIDAS NÃO É O DO JOGADOR, NEM O DAS FERRAMENTAS. Um
mutante no `ArmazemLocal.gd` mandaria as suítes gravar no save real — foi o
incidente de 25/09 (`061`). Todo Godot que esta ferramenta abre tem o
`XDG_DATA_HOME` e o `APPDATA` apontados para a pasta de saída, como a bancada
do cancelamento já fazia (`testar_bancada_cancelamento.py`).

Uso:
  python3 tools/conferir_mutantes.py --godot "$G"            # o catálogo todo
  python3 tools/conferir_mutantes.py --godot "$G" --so ID    # um ou mais
  python3 tools/conferir_mutantes.py --godot "$G" --explorar --so ID
      # roda o defeito contra AS SEIS suítes e diz quem reprovou — é assim que
      # se escreve o `reprova` de um mutante novo, medido e não suposto
  python3 tools/conferir_mutantes.py --listar

Espera `MUTANTES OK`. Não corra em paralelo com outra suíte: o defeito vive no
arquivo do projeto enquanto a suíte dele corre.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import signal
import subprocess
import sys
import time
import tomllib
from pathlib import Path

RAIZ = Path(__file__).resolve().parents[1]
PROJETO = RAIZ / "brport_vs"
CATALOGO = RAIZ / "tools" / "mutantes.toml"
WORKFLOW = RAIZ / ".github" / "workflows" / "testes.yml"

# As seis suítes e o marcador de cada uma. Conferido contra o `testes.yml` em
# `suites_batem_com_o_ci()`: a lista viva é a do workflow (`032`), e esta só
# pode repeti-la.
SUITES = {
    "run_tests": ("res://tests/run_tests.gd", "TODOS OS TESTES PASSARAM"),
    "teste_design": ("res://tests/teste_design.gd", "DESIGN OK"),
    "teste_audio": ("res://tests/teste_audio.gd", "AUDIO OK"),
    "teste_fumaca": ("res://tests/teste_fumaca.gd", "FUMACA OK"),
    "teste_registro": ("res://tests/teste_registro.gd", "REGISTRO OK"),
    "asset_validator": ("res://scripts/validation/asset_validator.gd", "ASSET OK"),
}

# As três formas de uma asserção reprovada, uma por família de suíte:
# `  FAIL  rótulo` (run_tests), `  FALHA rótulo` (design, fumaça, registro,
# áudio) e `  FALHOU  rótulo` (assets).
LINHA_REPROVADA = re.compile(r"^\s+(?:FAIL|FALHA|FALHOU)\s+(.+?)\s*$", re.M)

# O erro de COMPILAÇÃO, que não é o de execução: este traz `SCRIPT ERROR` sem
# backtrace e com a origem no `GDScript::reload` (medido em 21/09,
# `testes-e-guardas.md`). Um erro de EXECUÇÃO dentro de um bloco é outra
# coisa — é uma reprovação legítima no CI pelo passo que varre `SCRIPT ERROR`,
# mas não nomeia guarda nenhuma, e por isso o item 5 acima não o aceita.
ERRO_DE_COMPILACAO = re.compile(
    r"Parse Error|Compile Error|GDScript::reload|Failed to load script")

ERRO_DE_BASE = re.compile(r"SCRIPT ERROR|at: push_error \(")


class Interrompido(Exception):
    pass


def _ao_sinal(_sig, _frame):
    raise Interrompido()


def carregar_catalogo(caminho: Path) -> list[dict]:
    """Lê e valida o catálogo inteiro ANTES de tocar em qualquer arquivo."""
    dados = tomllib.loads(caminho.read_text(encoding="utf-8"))
    mutantes = dados.get("mutante", [])
    if not mutantes:
        # Amostra vazia é reprovação: um catálogo que o parser deixou de ler
        # imprimiria `MUTANTES OK` sem ter injetado nada.
        raise SystemExit(f"{caminho}: nenhum [[mutante]] lido — nada a provar.")
    vistos: set[str] = set()
    for m in mutantes:
        falta = [k for k in ("id", "de", "o_que", "alvo", "antes", "depois")
                 if k not in m]
        if falta:
            raise SystemExit(f"mutante {m.get('id', '?')}: faltam {falta}.")
        if m["id"] in vistos:
            raise SystemExit(f"mutante {m['id']}: id repetido.")
        vistos.add(m["id"])
        if m["antes"] == m["depois"]:
            raise SystemExit(f"mutante {m['id']}: `antes` igual a `depois` não "
                             "injeta defeito nenhum.")
        reprova = m.get("reprova", {})
        if not isinstance(reprova, dict):
            raise SystemExit(f"mutante {m['id']}: `reprova` é uma tabela "
                             "suíte = \"guarda\".")
        for suite, guarda in reprova.items():
            if suite not in SUITES:
                raise SystemExit(f"mutante {m['id']}: suíte desconhecida {suite!r}.")
            if not isinstance(guarda, str) or not guarda.strip():
                raise SystemExit(f"mutante {m['id']}: a guarda de {suite} tem de "
                                 "ser um trecho do rótulo que reprova.")
    return mutantes


def suites_batem_com_o_ci() -> list[str]:
    texto = WORKFLOW.read_text(encoding="utf-8")
    queixas = []
    for nome, (script, marcador) in SUITES.items():
        if script not in texto:
            queixas.append(f"{nome}: {script} não está no testes.yml.")
        if f'grep -q "{marcador}"' not in texto:
            queixas.append(f"{nome}: o testes.yml não exige «{marcador}».")
    return queixas


def ocorrencias(m: dict) -> int:
    return (RAIZ / m["alvo"]).read_bytes().count(m["antes"].encode("utf-8"))


def orfaos(mutantes: list[dict]) -> list[str]:
    queixas = []
    for m in mutantes:
        alvo = RAIZ / m["alvo"]
        if not alvo.is_file():
            queixas.append(f"{m['id']}: o alvo {m['alvo']} não existe.")
            continue
        n = ocorrencias(m)
        if m.get("todas", False):
            if n == 0:
                queixas.append(f"{m['id']}: «{m['antes'].strip()}» não aparece em "
                               f"{m['alvo']} — o nome mudou; reescreva o defeito.")
        elif n != 1:
            queixas.append(
                f"{m['id']}: o trecho a trocar aparece {n} vez(es) em {m['alvo']}, "
                "e tem de aparecer UMA. " + (
                    "O código mudou e o defeito deixou de existir com ele: "
                    "reescreva-o contra a forma nova, rode --explorar e confira "
                    "que a guarda ainda reprova." if n == 0 else
                    "Alargue o trecho até ele ser único."))
    return queixas


def trocar(alvo: Path, conteudo: bytes, modo: int) -> None:
    # Temporário + `os.replace`, e o modo copiado: `open(..., "w")` trunca
    # antes de o conteúdo existir, e o `os.replace` sozinho perde o modo
    # (`gerais.md`, as duas regras do `os.replace`).
    tmp = alvo.with_name(alvo.name + ".mutante-tmp")
    tmp.write_bytes(conteudo)
    os.chmod(tmp, modo)
    os.replace(tmp, alvo)


def rodar_suite(godot: str, suite: str, log: Path, teto: float, perfil: Path) -> dict:
    script, marcador = SUITES[suite]
    ambiente = dict(os.environ, XDG_DATA_HOME=str(perfil), APPDATA=str(perfil))
    inicio = time.monotonic()
    try:
        r = subprocess.run(
            [godot, "--headless", "--path", str(PROJETO), "--script", script],
            stdout=subprocess.PIPE, stderr=subprocess.STDOUT, env=ambiente,
            timeout=teto)
        saida = r.stdout.decode("utf-8", "replace")
        esgotou = False
    except subprocess.TimeoutExpired as e:
        saida = (e.stdout or b"").decode("utf-8", "replace")
        esgotou = True
    log.write_text(saida, encoding="utf-8")
    return {
        "segundos": time.monotonic() - inicio,
        "esgotou": esgotou,
        "passou": marcador in saida,
        "compilou": not ERRO_DE_COMPILACAO.search(saida),
        "erro": bool(ERRO_DE_BASE.search(saida)),
        "reprovadas": LINHA_REPROVADA.findall(saida),
    }


def julgar(r: dict, guarda: str | None, teto: float) -> tuple[bool, str]:
    """(aprovado, frase). `guarda` None é o modo --explorar: só descreve."""
    # A COMPILAÇÃO ANTES DO TETO: um autoload que não compila deixa a suíte
    # pendurada (medido no autoteste, `117`), e o diagnóstico tem de dizer a
    # causa, não o sintoma. A saída parcial da corrida cortada já a traz.
    if not r["compilou"]:
        return False, ("o mutante não compila: a suíte caiu inteira, e isso não "
                       "prova guarda nenhuma — mude o comportamento, não a sintaxe")
    if r["esgotou"]:
        return False, (f"não acabou em {teto:.0f} s — a guarda tem de reprovar com "
                       "nome, e um laço sem teto no CI é um job a morrer de timeout")
    if r["passou"]:
        return False, "SOBREVIVEU — a suíte passou com o defeito posto"
    reprovadas = r["reprovadas"]
    if not reprovadas:
        return False, ("a suíte não chegou ao marcador e não nomeou asserção "
                       "nenhuma" + (" (imprimiu SCRIPT ERROR)" if r["erro"] else ""))
    if guarda is None:
        return True, f"{len(reprovadas)} reprovada(s)"
    if any(guarda in rotulo for rotulo in reprovadas):
        outras = len(reprovadas) - 1
        return True, f"«{guarda}»" + (f" (+{outras})" if outras else "")
    return False, ("reprovou, mas não pela guarda declarada «%s». Reprovaram: %s"
                   % (guarda, " | ".join(reprovadas[:6])))


def main() -> int:
    # Linha a linha, e não em bloco: num cano para `tee` o Python guarda a
    # saída até ao fim, e um catálogo de minutos parecia parado.
    sys.stdout.reconfigure(line_buffering=True)
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--godot", help="o binário do Godot (o $G da sessão)")
    ap.add_argument("--catalogo", type=Path, default=CATALOGO)
    ap.add_argument("--saida", type=Path, default=Path("/tmp/mutantes"))
    ap.add_argument("--so", nargs="+", metavar="ID", help="só estes mutantes")
    ap.add_argument("--explorar", action="store_true",
                    help="roda cada mutante contra as seis suítes e descreve")
    ap.add_argument("--suites", nargs="+", choices=list(SUITES),
                    help="com --explorar, só estas suítes")
    ap.add_argument("--listar", action="store_true")
    args = ap.parse_args()

    mutantes = carregar_catalogo(args.catalogo)
    if args.listar:
        for m in mutantes:
            suites = ", ".join(f"{s}: «{g}»" for s, g in m.get("reprova", {}).items())
            print(f"  {m['id']:<34} {m['de']:<6} {suites}")
        print(f"\n{len(mutantes)} mutante(s) no catálogo.")
        return 0

    if args.so:
        desconhecidos = set(args.so) - {m["id"] for m in mutantes}
        if desconhecidos:
            raise SystemExit(f"não há no catálogo: {sorted(desconhecidos)}")
        mutantes = [m for m in mutantes if m["id"] in args.so]

    queixas = suites_batem_com_o_ci()
    if not args.explorar:
        queixas += [f"{m['id']}: sem `reprova` — rode --explorar e escreva quem "
                    "o tem de reprovar." for m in mutantes if not m.get("reprova")]
    queixas += orfaos(mutantes)
    if queixas:
        for q in queixas:
            print(f"::error::{q}")
        print(f"\n{len(queixas)} queixa(s) antes de injetar — nada foi injetado.")
        return 1

    if not args.godot:
        raise SystemExit("falta --godot (o binário que o hook de arranque pôs em $G).")
    if not (PROJETO / ".godot").is_dir():
        raise SystemExit("brport_vs/.godot não existe: rode `$G --headless --path "
                         "brport_vs --import` uma vez (CLAUDE.md, «Como rodar»).")

    saida = args.saida.resolve()
    saida.mkdir(parents=True, exist_ok=True)
    perfil = saida / "perfil"
    perfil.mkdir(exist_ok=True)
    signal.signal(signal.SIGTERM, _ao_sinal)

    exploradas = args.suites or list(SUITES)
    plano = {m["id"]: (exploradas if args.explorar else list(m["reprova"]))
             for m in mutantes}
    precisas = [s for s in SUITES if any(s in v for v in plano.values())]

    # A BASE PRIMEIRO, e tem de passar inteira: um vermelho herdado faria cada
    # mutante «reprovar» sem nunca ter visto o defeito (`gerais.md`, «confira
    # que a base está LIMPA antes de injetar o defeito seguinte»).
    print("Base:")
    tetos: dict[str, float] = {}
    for suite in precisas:
        r = rodar_suite(args.godot, suite, saida / f"base-{suite}.log", 900, perfil)
        ok = r["passou"] and r["compilou"] and not r["erro"] and not r["esgotou"]
        print(f"  {'verde' if ok else 'VERMELHA':<9} {suite} ({r['segundos']:.0f} s)")
        if not ok:
            print(f"::error::A base de {suite} não está verde (veja "
                  f"{saida / f'base-{suite}.log'}); sem base limpa não há o que medir.")
            return 1
        # O teto de cada mutante sai da base MEDIDA nesta máquina, com folga
        # para a deriva de ~20% que o contêiner já mostrou (`gerais.md`).
        tetos[suite] = max(60.0, 4 * r["segundos"])

    print(f"\n{len(mutantes)} mutante(s):")
    resultado: dict[str, dict] = {}
    falhas = 0
    for m in mutantes:
        alvo = RAIZ / m["alvo"]
        original = alvo.read_bytes()
        modo = alvo.stat().st_mode
        antes, depois = m["antes"].encode("utf-8"), m["depois"].encode("utf-8")
        mutado = (original.replace(antes, depois) if m.get("todas", False)
                  else original.replace(antes, depois, 1))
        assert mutado != original
        por_suite = {}
        try:
            trocar(alvo, mutado, modo)
            for suite in plano[m["id"]]:
                r = rodar_suite(args.godot, suite,
                                saida / f"{m['id']}-{suite}.log", tetos[suite], perfil)
                guarda = None if args.explorar else m["reprova"][suite]
                ok, frase = julgar(r, guarda, tetos[suite])
                por_suite[suite] = {"aprovado": ok, "frase": frase,
                                    "reprovadas": r["reprovadas"]}
        except Interrompido:
            print("\ninterrompido — a restaurar o alvo.")
            return 130
        finally:
            trocar(alvo, original, modo)
            if alvo.read_bytes() != original:
                print(f"::error::{m['alvo']} NÃO voltou ao original — confira à mão.")
                return 2
        resultado[m["id"]] = por_suite
        if args.explorar:
            print(f"  {m['id']}  ({m['de']})")
            for suite, r in por_suite.items():
                rot = r["reprovadas"]
                print(f"      {suite:<16} {r['frase']}"
                      + (": " + " | ".join(rot[:4]) if rot else ""))
            continue
        ok = all(r["aprovado"] for r in por_suite.values())
        falhas += 0 if ok else 1
        print(f"  {'reprovado' if ok else 'FURADO':<10} {m['id']}  ({m['de']})")
        for suite, r in por_suite.items():
            print(f"      {suite:<16} {r['frase']}")

    # E A BASE OUTRA VEZ NO FIM: os bytes já foram conferidos a cada troca, e
    # esta corrida prova o resto — que nenhum mutante deixou no `user://` das
    # corridas um estado que mude a resposta da suíte seguinte.
    print("\nBase no fim:")
    for suite in precisas:
        r = rodar_suite(args.godot, suite, saida / f"fim-{suite}.log", 900, perfil)
        ok = r["passou"] and r["compilou"] and not r["erro"] and not r["esgotou"]
        print(f"  {'verde' if ok else 'VERMELHA':<9} {suite}")
        if not ok:
            print(f"::error::A base de {suite} ficou vermelha depois dos mutantes.")
            return 1

    (saida / "relatorio.json").write_text(
        json.dumps(resultado, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    if args.explorar:
        print(f"\nExplorado — relatório em {saida / 'relatorio.json'}.")
        return 0
    if falhas:
        print(f"\n{falhas} de {len(mutantes)} mutante(s) furado(s): a guarda que os "
              "provou deixou de os apanhar, ou a descrição envelheceu.")
        return 1
    print(f"\nMUTANTES OK — {len(mutantes)} defeito(s) reinjetado(s), cada um "
          "reprovado pela guarda declarada.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
