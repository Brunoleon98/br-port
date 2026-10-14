#!/usr/bin/env python3
"""Importa com um único trabalhador; remove a configuração antes de jogar.

Godot 4.6.3 pode abortar ao importar fontes em paralelo (godotengine/godot#111039).
O override é temporário e exclusivo: nunca substitui uma configuração existente.
Uso: python3 tools/importar_para_ci.py CAMINHO_DO_PROJETO EXECUTAVEL_GODOT
"""

import argparse
import subprocess
from pathlib import Path


def importar(projeto: Path, godot: str) -> int:
    projeto = projeto.resolve()
    if not (projeto / "project.godot").is_file():
        raise FileNotFoundError(f"Projeto Godot ausente: {projeto}")
    override = projeto / "override.cfg"
    # Abrir com 'x' recusa qualquer override preexistente, inclusive na base do PR.
    arquivo = override.open("x", encoding="utf-8")
    try:
        with arquivo:
            arquivo.write("[editor]\nimport/use_multiple_threads=false\n")
        return subprocess.run(
            [godot, "--headless", "--path", str(projeto), "--import"], check=False
        ).returncode
    finally:
        override.unlink()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("projeto", type=Path)
    parser.add_argument("godot")
    args = parser.parse_args()
    raise SystemExit(importar(args.projeto, args.godot))
