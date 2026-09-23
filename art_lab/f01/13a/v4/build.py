#!/usr/bin/env python3
"""Constrói a candidata V4 em laboratório, sem escrever no repositório."""
from pathlib import Path
import hashlib
import re
import shutil
import subprocess
import sys

HERE = Path(__file__).resolve().parent
EXPECTED_SHA = "e4c3d35e86f9f37e444a7f08ae51e7e64ebe09385a19bd9f9d126949df66e499"


def patch(source: Path) -> Path:
    data = source.read_bytes()
    if hashlib.sha256(data).hexdigest() != EXPECTED_SHA:
        raise SystemExit("Gerador de destino divergiu da base auditada: adaptar e testar novamente.")
    text = data.decode()
    replacement = (HERE / "arbusto_v4.py.txt").read_text().rstrip() + "\n\n\n"
    text, n = re.subn(r"def arbusto_baixo_f1\(.*?(?=def vegetacao_do_solo\()", replacement.replace("\\", "\\\\"), text, flags=re.S)
    if n != 1:
        raise SystemExit("Não encontrei a função V3 única")
    old = '''    posicoes = {1: (2.5, 5.0, 6.6), 2: (10.2, 12.0)}
    ar = random.Random(SEMENTE_CHAO + 1300 + indice)
    for my in posicoes.get(indice, ()):
        mx = mx1 - 0.48 - ar.uniform(0.0, 0.26)
        if no_quadro(mx, my):
            s += arbusto_baixo_f1(mx, my, ar)
'''
    new = '''    posicoes = {1: (2.5, 5.0, 6.6), 2: (10.2, 12.0)}
    for numero, my in enumerate(posicoes.get(indice, ())):
        identidade = "f01_13a_%d_%d" % (indice, numero)
        rp = random.Random(_semente_13a(identidade, "posicao"))
        rf = random.Random(_semente_13a(identidade, "forma"))
        mx = mx1 - 0.48 - rp.uniform(0.0, 0.26)
        if no_quadro(mx, my):
            s += arbusto_baixo_f1(mx, my, rf)
'''
    if text.count(old) != 1:
        raise SystemExit("Não encontrei o bloco de posições V3 único")
    text = text.replace(old, new)
    text = text.replace("import base64\n", "import base64\nimport hashlib\n", 1)
    seed = '''def _semente_13a(identidade: str, canal: str) -> int:
    chave = "BRP-13A-V4|%s|%s" % (identidade, canal)
    return int.from_bytes(hashlib.sha256(chave.encode("utf-8")).digest()[:16], "big")


'''
    text = text.replace("def arbusto_baixo_f1(", seed + "def arbusto_baixo_f1(", 1)
    dest = HERE / "gerar_mapa_iso_13a_v4.py"
    dest.write_text(text)
    return dest


def main() -> None:
    repo = Path(sys.argv[1]).resolve()
    scene_copy = HERE.parent / "brport_vs/scenes/Main.tscn"
    scene_copy.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(repo / "brport_vs/scenes/Main.tscn", scene_copy)
    generator = patch(repo / "tools/gerar_mapa_iso.py")
    for name, flags in (("porto_mapa_iso_v4.svg", ["--sem-pavimento", "--sem-predios", "--sem-pieres"]),
                        ("porto_mapa_iso_patio_v4.svg", ["--sem-predios", "--sem-pieres"])):
        subprocess.run([sys.executable, str(generator), str(HERE / name), *flags], check=True, stdout=subprocess.DEVNULL)
    print("V4 construída em", HERE)


if __name__ == "__main__":
    main()
