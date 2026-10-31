#!/usr/bin/env python3
"""Confere que o APK exportado declara as permissões pedidas (`149`).

O preset Android pede a permissão de vibrar (`permissions/vibrate=true`), e o
F5 do `teste_fumaca` lê-a lá. Isto confere a outra ponta: que ela chegou ao
manifesto do APK. Sem ela o `Input.vibrate_handheld()` não faz nada no
telefone e não se queixa — o defeito que só o Bruno, com o aparelho na mão,
veria.

O `AndroidManifest.xml` de um APK é XML BINÁRIO: as strings vivem num
pool, em UTF-16LE ou em UTF-8 conforme uma bandeira do próprio pool. Em vez
de interpretar o formato, procura-se o nome da permissão nas duas
codificações — e, para não dar um verde de graça a um manifesto que não se
conseguiu ler, exige-se também o nome do elemento `uses-permission` na mesma
codificação em que a permissão foi achada.

  python3 tools/conferir_permissoes_apk.py build/android/brport.apk android.permission.VIBRATE
  python3 tools/conferir_permissoes_apk.py --provar    # os controles, sem APK

Espera `PERMISSOES OK`.
"""
import argparse
import sys
import tempfile
import zipfile
from pathlib import Path

MANIFESTO = "AndroidManifest.xml"
CODIFICACOES = ("utf-16-le", "utf-8")


def permissoes_achadas(apk: Path, pedidas: list[str]) -> tuple[list[str], list[str]]:
    """Devolve (achadas, em falta) — achada é a que está no pool de strings
    numa codificação em que também está o `uses-permission`."""
    with zipfile.ZipFile(apk) as z:
        manifesto = z.read(MANIFESTO)
    achadas, falta = [], []
    for nome in pedidas:
        ok = any(nome.encode(c) in manifesto and "uses-permission".encode(c) in manifesto
                 for c in CODIFICACOES)
        (achadas if ok else falta).append(nome)
    return achadas, falta


def _apk_falso(destino: Path, strings: list[str], codificacao: str) -> Path:
    corpo = b"\x03\x00\x08\x00" + b"\x00".join(t.encode(codificacao) for t in strings)
    with zipfile.ZipFile(destino, "w") as z:
        z.writestr(MANIFESTO, corpo)
        z.writestr("classes.dex", b"dex\n")
    return destino


def provar() -> int:
    """Os controles: a régua acha nas duas codificações, e reprova sem a
    permissão e sem o elemento — antes de se acreditar no verde dela."""
    pedida = "android.permission.VIBRATE"
    casos = [
        ("UTF-16 com a permissão", ["uses-permission", pedida], "utf-16-le", True),
        ("UTF-8 com a permissão", ["uses-permission", pedida], "utf-8", True),
        ("sem a permissão", ["uses-permission", "android.permission.INTERNET"], "utf-16-le", False),
        ("a permissão sem o elemento", [pedida], "utf-16-le", False),
    ]
    erros = 0
    with tempfile.TemporaryDirectory(prefix="brport-apk-") as pasta:
        for i, (nome, strings, cod, esperado) in enumerate(casos):
            apk = _apk_falso(Path(pasta) / f"{i}.apk", strings, cod)
            achadas, _ = permissoes_achadas(apk, [pedida])
            certo = (achadas == [pedida]) == esperado
            print(f"  {'PASS' if certo else 'FALHA'}  controle: {nome} → {'achada' if achadas else 'em falta'}")
            erros += 0 if certo else 1
    if erros:
        print(f"=== {erros} controle(s) da régua do manifesto reprovaram ===")
        return 1
    print("=== PERMISSOES OK — a régua do manifesto acha e reprova ===")
    return 0


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    ap.add_argument("apk", nargs="?", type=Path)
    ap.add_argument("permissoes", nargs="*")
    ap.add_argument("--provar", action="store_true", help="corre os controles e sai")
    a = ap.parse_args()
    if a.provar:
        return provar()
    if a.apk is None or not a.permissoes:
        ap.error("diga o APK e as permissões")
    achadas, falta = permissoes_achadas(a.apk, a.permissoes)
    for nome in achadas:
        print(f"  PASS  {nome} está no manifesto")
    for nome in falta:
        print(f"  FALHA {nome} NÃO está no manifesto de {a.apk}")
    if falta:
        print(f"=== {len(falta)} permissão(ões) em falta no APK ===")
        return 1
    print(f"=== PERMISSOES OK — {len(achadas)} permissão(ões) no manifesto ===")
    return 0


if __name__ == "__main__":
    sys.exit(main())
