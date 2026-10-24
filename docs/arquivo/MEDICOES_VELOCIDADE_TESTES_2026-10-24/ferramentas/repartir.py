#!/usr/bin/env python3
"""Reparte o catálogo em N fatias pelo tempo estimado (maior primeiro)."""
import sys, tomllib, json
N = int(sys.argv[2]); cat = tomllib.load(open(sys.argv[1], "rb"))["mutante"]
est = {"run_tests": 32, "teste_design": 58, "teste_fumaca": 15, "teste_audio": 0.5,
       "teste_registro": 0.7, "asset_validator": 11}
custo = lambda m: sum(est[s] for s in m["reprova"]) + (30 if m["alvo"].endswith(".svg") else 0)
fat = [[0, []] for _ in range(N)]
for m in sorted(cat, key=custo, reverse=True):
    f = min(fat, key=lambda x: x[0]); f[0] += custo(m); f[1].append(m["id"])
print(json.dumps([f[1] for f in fat]))
for f in fat: print("%d mutantes, %.0f s" % (len(f[1]), f[0]), file=sys.stderr)
