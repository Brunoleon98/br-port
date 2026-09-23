#!/usr/bin/env python3
"""Substitui só o desenho V4 no laboratório; conserva as posições e o RNG."""
from pathlib import Path
import hashlib
import re
import subprocess
import sys

HERE=Path(__file__).resolve().parent
V4=HERE.parent/'v4'
EXPECTED='6aa6d3e8a03ab2bd367f3ac3f9450ecf6ba65917fb4ed4bd5b7985165f6ba610'

def main():
    prior=V4/'gerar_mapa_iso_13a_v4.py'
    raw=prior.read_bytes()
    if hashlib.sha256(raw).hexdigest()!=EXPECTED:
        raise SystemExit('Base V4 alterada; revisar a diferença antes de continuar')
    replacement=(HERE/'arbusto_v5.py.txt').read_text().rstrip()+'\n\n\n'
    data,n=re.subn(r'def arbusto_baixo_f1\(.*?(?=def vegetacao_do_solo\()',
                   lambda _:replacement,raw.decode(),flags=re.S)
    if n!=1:raise SystemExit('Definição de 13A não encontrada uma única vez')
    script=HERE/'gerar_mapa_iso_13a_v5.py';script.write_text(data)
    # O gerador lê o snapshot da cena já fornecido no pacote V4.
    for name,flags in (('porto_mapa_iso_v5.svg',['--sem-pavimento','--sem-predios','--sem-pieres']),
                       ('porto_mapa_iso_patio_v5.svg',['--sem-predios','--sem-pieres'])):
        subprocess.run([sys.executable,str(script),str(HERE/name),*flags],
                       stdout=subprocess.DEVNULL,check=True)
    print('V5 gerada em laboratório, âncoras V4 preservadas')

if __name__=='__main__':main()
