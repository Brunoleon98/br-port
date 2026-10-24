#!/usr/bin/env python3
"""As seis suítes ao mesmo tempo, cada uma com o seu `user://` (`139`).

  python3 tools/correr_suites.py --godot "$G"                 # espera SUITES OK
  python3 tools/correr_suites.py --godot "$G" --so run_tests teste_audio
  python3 tools/correr_suites.py --autoteste                  # espera ATALHO PROVADO

É o atalho dos agentes para os passos 1 e 2 do fecho: em série são ~2 min,
e quatro núcleos a correr as seis ao mesmo tempo atrasam-se pouco uns aos
outros (medido na `137`: 118 → 56 s). O CI continua em série, um passo por
suíte, e é ele quem manda.

O QUE NÃO MUDA, e é o que torna isto seguro:

- **A lista e o marcador de cada suíte são os do executor de mutantes**
  (`tools/conferir_mutantes.py`, `SUITES` e `MOTOR`), que os confere contra o
  `testes.yml` antes de qualquer coisa — a lista viva é a do workflow (`032`).
- **O julgamento é o do CI**: o código de saída, o marcador na saída, e
  nenhum `SCRIPT ERROR` nem `at: push_error (`. O Godot encerra com 0 depois
  de um erro de compilação, e por isso o código não chega (`CLAUDE.md`).
- **Cada suíte tem o seu `user://`**, numa pasta que começa vazia. Elas
  partilham `user://ferramentas/` quando correm na mesma máquina, e foi assim
  que um tiro leu o save inválido que o `teste_fumaca` planta de propósito
  (`069`). É também a condição do executor de mutantes, que dá um perfil a
  cada suíte; no CI elas correm em série e partilham a pasta, e uma
  dependência de ordem entre suítes continua a ser dele apanhar.
"""

from __future__ import annotations

import argparse
import os
import shutil
import subprocess
import sys
import tempfile
import time
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import conferir_mutantes as cm  # noqa: E402

MARCADOR = "SUITES OK"
TETO = 600.0


def perfil_de(saida: Path, nome: str) -> Path:
    return saida / f"perfil-{nome}"


def julgar(codigo: int | None, texto: str, marcador: str) -> str:
    """"" quando a suíte passou; senão, a razão."""
    if codigo is None:
        return f"não acabou em {TETO:.0f} s"
    if codigo != 0:
        return f"saiu com {codigo}"
    if marcador not in texto:
        return f"não imprimiu «{marcador}»"
    if cm.ERRO_DE_BASE.search(texto):
        return "imprimiu SCRIPT ERROR ou push_error"
    return ""


def principal(godot: str, nomes: list[str], saida: Path, projeto: Path = cm.PROJETO,
              conferir_ci: bool = True) -> int:
    if conferir_ci:
        queixas = cm.suites_batem_com_o_ci()
        if queixas:
            for q in queixas:
                print(f"::error::{q}")
            return 1
    saida.mkdir(parents=True, exist_ok=True)
    corridas = {}
    inicio = time.monotonic()
    for nome in nomes:
        script, _ = cm.SUITES[nome]
        perfil = perfil_de(saida, nome)
        shutil.rmtree(perfil, ignore_errors=True)
        perfil.mkdir(parents=True)
        ambiente = dict(os.environ, XDG_DATA_HOME=str(perfil), APPDATA=str(perfil))
        log = open(saida / f"{nome}.txt", "wb")
        proc = subprocess.Popen([godot, *cm.MOTOR, "--path", str(projeto), "--script", script],
                                stdout=log, stderr=subprocess.STDOUT, env=ambiente)
        corridas[nome] = (proc, log, time.monotonic())
    # O FIM DE CADA UMA, e não a vez de ser esperada: a primeira versão media
    # até ao `wait()` em ordem, e o `teste_audio` de meio segundo saía com os
    # 50 s do `teste_design` que vinha antes dele.
    fins: dict[str, tuple[int | None, float]] = {}
    while len(fins) < len(corridas):
        for nome, (proc, _, t0) in corridas.items():
            if nome in fins:
                continue
            if proc.poll() is not None:
                fins[nome] = (proc.returncode, time.monotonic() - t0)
            elif time.monotonic() - t0 > TETO:
                proc.kill()
                proc.wait()
                fins[nome] = (None, time.monotonic() - t0)
        time.sleep(0.05)
    vermelhas = 0
    for nome, (proc, log, t0) in corridas.items():
        codigo, segundos = fins[nome]
        log.close()
        texto = (saida / f"{nome}.txt").read_text(encoding="utf-8", errors="replace")
        razao = julgar(codigo, texto, cm.SUITES[nome][1])
        if razao:
            vermelhas += 1
            print(f"  VERMELHA  {nome} ({segundos:.0f} s) — {razao}; saída em {saida / (nome + '.txt')}")
            for rotulo in cm.LINHA_REPROVADA.findall(texto)[:5]:
                print(f"              {rotulo}")
        else:
            print(f"  verde     {nome} ({segundos:.0f} s)")
    total = time.monotonic() - inicio
    if vermelhas:
        print(f"\n{vermelhas} SUÍTE(S) VERMELHA(S) em {len(nomes)}.")
        return 1
    print(f"\n{MARCADOR} — {len(nomes)} suíte(s) ao mesmo tempo, cada uma com o seu "
          f"user://, em {total:.0f} s.")
    return 0


# ── O AUTOTESTE ─────────────────────────────────────────────────────────────
# Um motor falso, em Python, faz de Godot: lê o `--script`, escreve no
# `user://` que lhe deram e imprime o que o caso pedir. Cada defeito que este
# atalho podia ter é reinjetado por troca de função, e o caso que o vê tem de
# reprovar — um atalho que nunca reprovou nada dava um verde de graça
# (`CLAUDE.md`, item 7).

MOTOR_FALSO = r'''#!/usr/bin/env python3
import os, sys, time, json
script = sys.argv[sys.argv.index("--script") + 1]
nome = script.rsplit("/", 1)[-1][:-3]
casos = json.loads(os.environ.get("CASOS", "{}"))
caso = casos.get(nome, "verde")
pasta = os.path.join(os.environ["XDG_DATA_HOME"], "godot", "app_userdata", "BR Port", "ferramentas")
os.makedirs(pasta, exist_ok=True)
open(os.path.join(pasta, nome), "w").write("x")
time.sleep(0.4)
outros = [n for n in os.listdir(pasta) if n != nome]
marcadores = json.loads(os.environ["MARCADORES"])
if outros:
    print("partilhou o user:// com", outros)
    sys.exit(0)
if caso == "sem_marcador":
    sys.exit(0)
print("=== %s ===" % marcadores[nome])
if caso == "erro":
    print("SCRIPT ERROR: Invalid call")
if caso == "codigo":
    sys.exit(1)
sys.exit(0)
'''


def autoteste() -> int:
    import contextlib
    import io
    import json

    raiz = Path(tempfile.mkdtemp(prefix="atalho-"))
    motor = raiz / "godot"
    motor.write_text(MOTOR_FALSO, encoding="utf-8")
    motor.chmod(0o755)
    os.environ["MARCADORES"] = json.dumps({n: m for n, (_, m) in cm.SUITES.items()})
    nomes = list(cm.SUITES)
    falhas = []

    def correr(casos: dict) -> tuple[int, str]:
        os.environ["CASOS"] = json.dumps(casos)
        saida = raiz / f"saida-{len(os.listdir(raiz))}"
        buf = io.StringIO()
        with contextlib.redirect_stdout(buf):
            codigo = principal(str(motor), nomes, saida, projeto=raiz, conferir_ci=False)
        return codigo, buf.getvalue()

    def verde(texto: str) -> bool:
        return any(l.startswith(MARCADOR) for l in texto.splitlines())

    casos = {
        "as seis verdes dão SUITES OK": ({}, True),
        "suíte sem o marcador reprova": ({"teste_design": "sem_marcador"}, False),
        "suíte que sai com 1 reprova": ({"run_tests": "codigo"}, False),
        "suíte com SCRIPT ERROR reprova": ({"teste_fumaca": "erro"}, False),
    }
    for nome, (pedido, esperado) in casos.items():
        codigo, texto = correr(pedido)
        certo = (codigo == 0 and verde(texto)) == esperado
        print(("  PASS  " if certo else "  FALHA ") + nome)
        if not certo:
            falhas.append(f"{nome}: saiu {codigo}")

    # Os defeitos, um de cada vez, com o caso que tem de os ver: com o
    # defeito posto, o caso dá o contrário do que espera. Os três primeiros
    # fariam o atalho dar verde a uma suíte vermelha; o último, vermelho a
    # seis verdes que se pisam umas às outras.
    original_julgar, original_perfil = julgar, perfil_de
    defeitos = {
        "o código de saída ignorado": (
            lambda c, t, m: original_julgar(0 if c is not None else None, t, m),
            original_perfil, "suíte que sai com 1 reprova"),
        "o marcador não conferido": (
            lambda c, t, m: original_julgar(c, t + m, m), original_perfil,
            "suíte sem o marcador reprova"),
        "o SCRIPT ERROR não conferido": (
            lambda c, t, m: original_julgar(c, t.replace("SCRIPT ERROR", ""), m),
            original_perfil, "suíte com SCRIPT ERROR reprova"),
        "o user:// partilhado entre suítes": (
            original_julgar, lambda s, n: s / "perfil", "as seis verdes dão SUITES OK"),
    }
    g = globals()
    for nome, (j, p, caso) in defeitos.items():
        pedido, esperado = casos[caso]
        g["julgar"], g["perfil_de"] = j, p
        try:
            codigo, texto = correr(pedido)
        finally:
            g["julgar"], g["perfil_de"] = original_julgar, original_perfil
        viu = (codigo == 0 and verde(texto)) != esperado
        print(("  PASS  " if viu else "  FALHA ") + f"«{caso}» vê o defeito «{nome}»")
        if not viu:
            falhas.append(f"o defeito «{nome}» passou pelo caso «{caso}»")

    shutil.rmtree(raiz, ignore_errors=True)
    if falhas:
        print(f"\n{len(falhas)} FALHA(S) NO ATALHO: " + "; ".join(falhas))
        return 1
    print("\nATALHO PROVADO — quatro casos e quatro defeitos, cada um visto.")
    return 0


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    ap.add_argument("--godot", help="o binário do Godot (o $G da sessão)")
    ap.add_argument("--so", nargs="+", choices=list(cm.SUITES), metavar="SUÍTE",
                    help="só estas suítes")
    ap.add_argument("--saida", type=Path, default=Path(tempfile.gettempdir()) / "suites")
    ap.add_argument("--autoteste", action="store_true")
    args = ap.parse_args()
    if args.autoteste:
        return autoteste()
    if not args.godot:
        ap.error("--godot é obrigatório (o $G da sessão)")
    return principal(args.godot, args.so or list(cm.SUITES), args.saida)


if __name__ == "__main__":
    sys.exit(main())
