#!/usr/bin/env python3
"""Importa com um único trabalhador; devolve o project.godot antes de jogar.

Godot 4.6.3 pode abortar ao importar fontes em paralelo (godotengine/godot#111039).
A chave vai no project.godot só durante o --import: o override.cfg, que se usou
até 18/10, é lido por quem corre um script e NÃO pelo --import, e o import do
CI continuava paralelo (docs/decisoes/106). Nunca substitui uma chave já escrita.
Uso: python3 tools/importar_para_ci.py CAMINHO_DO_PROJETO EXECUTAVEL_GODOT
"""

import argparse
import os
import subprocess
from pathlib import Path

CHAVE = "import/use_multiple_threads"
SECAO = "[editor]"


def _gravar(caminho: Path, dados: bytes) -> None:
    # Temporário e os.replace: um open("w") trunca antes de escrever, e um erro
    # a meio deixaria o projeto sem project.godot (.claude/rules/gerais.md).
    tmp = caminho.with_name(caminho.name + ".importar_para_ci")
    tmp.write_bytes(dados)
    os.chmod(tmp, os.stat(caminho).st_mode)
    os.replace(tmp, caminho)


def com_um_trabalhador(original: str) -> str:
    if CHAVE in original:
        raise ValueError(f"project.godot já escreve {CHAVE}; não o substituo")
    linhas = original.splitlines(keepends=True)
    for i, linha in enumerate(linhas):
        if linha.strip() == SECAO:
            linhas.insert(i + 1, f"{CHAVE}=false\n")
            return "".join(linhas)
    fim = "" if original.endswith("\n") else "\n"
    return f"{original}{fim}\n{SECAO}\n\n{CHAVE}=false\n"


def importar(projeto: Path, godot: str) -> int:
    projeto = projeto.resolve()
    config = projeto / "project.godot"
    if not config.is_file():
        raise FileNotFoundError(f"Projeto Godot ausente: {projeto}")
    original = config.read_bytes()
    alterado = com_um_trabalhador(original.decode("utf-8")).encode("utf-8")
    _gravar(config, alterado)
    try:
        return subprocess.run(
            [godot, "--headless", "--path", str(projeto), "--import"], check=False
        ).returncode
    finally:
        _gravar(config, original)
        if config.read_bytes() != original:
            raise RuntimeError("project.godot não voltou ao que era")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("projeto", type=Path)
    parser.add_argument("godot")
    args = parser.parse_args()
    raise SystemExit(importar(args.projeto, args.godot))
