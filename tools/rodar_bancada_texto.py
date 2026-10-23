#!/usr/bin/env python3
"""Mede os candidatos do RB5 em processos/perfil isolados; captura é opcional.

Não instala o recurso no jogo. Cada cenário usa a mesma semente, estado e
passo fixo. A saída conserva medidas inclusive quando o texto não cabe:
esses casos são resultado da bancada, não algo a esconder para ficar verde.
"""

from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

RAIZ = Path(__file__).resolve().parents[1]
CENARIOS = ["ajustes-inicio", "ajustes-pausa", "artigo", "hud", "doca", "calibracao"]


def rodar(cmd: list[str], env: dict, log: Path, teto: int = 180) -> str:
    with log.open("w", encoding="utf-8") as arquivo:
        r = subprocess.run(cmd, cwd=RAIZ, env=env, stdout=arquivo,
                           stderr=subprocess.STDOUT, timeout=teto)
    texto = log.read_text(encoding="utf-8")
    if r.returncode or re.search(r"SCRIPT ERROR|at: push_error \(|GDScript backtrace", texto):
        raise SystemExit(f"Falha na execução: {log} (código {r.returncode})")
    return texto


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--godot", default=shutil.which("godot"))
    ap.add_argument("--saida", type=Path, required=True)
    ap.add_argument("--capturar", action="store_true")
    ap.add_argument("--cenarios", nargs="+", choices=CENARIOS, default=CENARIOS)
    ap.add_argument("--fatores", nargs="+", choices=["1", "1.25", "1.5"], default=["1", "1.25", "1.5"])
    args = ap.parse_args()
    saida = args.saida.resolve()
    saida.mkdir(parents=True, exist_ok=True)
    perfil = Path(tempfile.mkdtemp(prefix="perfil-", dir=saida))
    env = os.environ.copy()
    env["XDG_DATA_HOME"] = str(perfil)
    env["APPDATA"] = str(perfil)
    env["XDG_CACHE_HOME"] = str(perfil / "cache")
    sentinel = ["python3", "tools/sentinela_do_jogador.py"]
    rodar(sentinel + ["plantar", "brport_vs"], env, saida / "sentinela-antes.log")
    resultados = []
    for cenario in args.cenarios:
        for fator in args.fatores:
            base = saida / f"{cenario}-{fator}"
            cmd = [args.godot, "--path", "brport_vs", "--resolution", "720x1280",
                   "--audio-driver", "Dummy", "--fixed-fps", "60"]
            cmd += ["--rendering-driver", "opengl3"] if args.capturar else ["--headless"]
            cmd += ["--script", "res://tools/bancada_texto.gd", "--", cenario, fator, str(base)]
            if args.capturar:
                cmd += ["capturar"]
            log = Path(str(base) + ".log")
            texto = rodar(cmd, env, log)
            if "BANCADA TEXTO MEDIDA " not in texto:
                raise SystemExit(f"Sem marcador da medição: {base}")
            manifesto = Path(str(base) + ".json")
            dados = json.loads(manifesto.read_text())
            if not dados["mesmo_estado_apos_ampliar"]:
                raise SystemExit(f"A bancada alterou estado/arquivos/registro: {base}")
            if dados["fontes"] != dados["fontes_reaplicadas"]:
                raise SystemExit(f"Reaplicar acumulou escala: {base}")
            for fonte, restaurada in zip(dados["fontes"], dados["fontes_restauradas"], strict=True):
                if fonte["base"] != restaurada["aplicado"]:
                    raise SystemExit(f"O padrão não foi restaurado: {base}")
            if args.capturar:
                for caminho in [Path(str(base) + ".png")] + ([Path(str(base) + "_fim.png")] if cenario == "artigo" else []):
                    if not caminho.is_file() or caminho.stat().st_size == 0:
                        raise SystemExit(f"Captura ausente: {caminho}")
                    if caminho.stem.endswith("_fim"):
                        shutil.copyfile(log, caminho.with_suffix(".log"))
            textos = dados["medicao"]["textos"]
            resultados.append({"cenario": cenario, "fator": float(fator),
                               "quantidade_textos": len(textos),
                               "excesso_local": [t for t in textos if t["excesso_local"] > 1.0],
                               "excesso_janela_fora_rolagem": [t for t in textos if t["excesso_janela"] > 1.0 and not t["em_rolagem"]],
                               "manifesto": manifesto.name})
            print(f"Medido: {cenario} × {fator}; {len(textos)} textos", flush=True)
    texto = rodar(sentinel + ["conferir", "brport_vs"], env, saida / "sentinela-depois.log")
    if "SENTINELA INTACTA" not in texto:
        raise SystemExit("A sentinela não confirmou os arquivos do jogador")
    (saida / "resumo.json").write_text(json.dumps(resultados, ensure_ascii=False, indent=2) + "\n")
    print(f"BANCADA TEXTO CONFERIDA — {len(resultados)} execuções, estado preservado e sentinela intacta.")


if __name__ == "__main__":
    main()
