#!/usr/bin/env python3
"""Sela a identidade da árvore que será exportada, nunca a do próximo merge.

O arquivo é recurso do Godot (entra nos dois exports), gerado e ignorado pelo
Git. O editor não o apresenta como identidade da execução local: pode ser a
sobra de outro export. Execute novamente imediatamente antes de exportar.
"""
from __future__ import annotations

import argparse
import os
import subprocess
import tempfile
from pathlib import Path

RAIZ = Path(__file__).resolve().parents[1]
DESTINO = Path("brport_vs/dados/identificacao_build.tres")


def identidade(raiz: Path) -> str:
    def git(*args: str) -> str:
        return subprocess.check_output(
            ["git", "-C", str(raiz), *args], text=True, encoding="utf-8").strip()

    commit = git("rev-parse", "HEAD")
    modificado = bool(git("status", "--porcelain", "--untracked-files=normal"))
    return ('[gd_resource type="Resource" format=3]\n\n[resource]\n'
            'metadata/formato = 1\n'
            f'metadata/commit = "{commit}"\n'
            f'metadata/modificado = {str(modificado).lower()}\n')


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--raiz", type=Path, default=RAIZ)
    ap.add_argument("--saida", type=Path)
    args = ap.parse_args()
    texto = identidade(args.raiz)
    destino = args.saida or args.raiz / DESTINO
    destino.parent.mkdir(parents=True, exist_ok=True)
    # Só abre o temporário depois de o Git ter respondido; falhar não trunca
    # o recurso anterior. O temporário some também se o replace falhar.
    nome = None
    try:
        with tempfile.NamedTemporaryFile(mode="w", encoding="utf-8", newline="\n",
                                         dir=destino.parent, delete=False) as f:
            nome = f.name
            f.write(texto)
        os.replace(nome, destino)
    finally:
        if nome and os.path.exists(nome):
            os.unlink(nome)
    print("IDENTIFICACAO GERADA — " + texto.split('metadata/commit = "')[1][:40])
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
