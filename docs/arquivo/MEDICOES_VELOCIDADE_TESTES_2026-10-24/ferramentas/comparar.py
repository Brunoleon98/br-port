#!/usr/bin/env python3
"""Medição (não é ferramenta do projeto): a mesma amostra antes e depois.

comparar.py ANTES.json DIR [DIR ...] SAIDA.json

ANTES é o `amostra_mutacao.json` da `137`; cada DIR é uma pasta de saída do
`amostra.py rodar` (com o seu `resultados.json`). Conta os válidos como a
`137` contou — fora as três mutações numa cena de teste e a que não compila
—, e diz, por id, quem passou a ser apanhado e por que suíte.
"""
import json, sys
from collections import Counter
from pathlib import Path


def valido(m):
    return m["compila"] and "/scenes/tests/" not in m["alvo"]


antes = {m["id"]: m for m in json.load(open(sys.argv[1]))}
depois = {}
for pasta in sys.argv[2:-1]:
    for r in json.load(open(Path(pasta) / "resultados.json")):
        assert r["id"] not in depois, r["id"]
        depois[r["id"]] = r
faltam = sorted(set(antes) - set(depois))
assert not faltam, f"faltam {len(faltam)} da amostra: {faltam[:5]}"

validos = [i for i in antes if valido(antes[i])]
assert all(depois[i]["compila"] for i in validos), "um válido deixou de compilar"
ok_antes = [i for i in validos if antes[i]["morto_por"] is not None]
ok_depois = [i for i in validos if depois[i]["morto_por"] is not None]
perdidos = sorted(set(ok_antes) - set(ok_depois))
novos = sorted(set(ok_depois) - set(ok_antes))
equiv_antes = {i for i in validos if antes[i].get("classe") == "equivalente"}
equiv_depois = equiv_antes | {"GameState:1305:bool"}   # lido como equivalente na 138

linhas = {
    "validos": len(validos),
    "apanhados_antes": len(ok_antes),
    "apanhados_depois": len(ok_depois),
    "equivalentes_antes": len(equiv_antes),
    "equivalentes_depois": len(equiv_depois),
    "perdidos": perdidos,
    "novos": [{"id": i, "por": depois[i]["morto_por"], "gravidade": antes[i].get("gravidade"),
               "o_que": antes[i].get("o_que")} for i in novos],
    "sobrevivem": [{"id": i, "gravidade": antes[i].get("gravidade"), "classe": antes[i].get("classe")}
                   for i in validos if depois[i]["morto_por"] is None],
}
json.dump(linhas, open(sys.argv[-1], "w"), ensure_ascii=False, indent=1)
n = len(validos); ea = len(equiv_antes); ed = len(equiv_depois)
print(f"válidos {n}; apanhados {len(ok_antes)} → {len(ok_depois)} "
      f"({100 * len(ok_antes) / n:.0f}% → {100 * len(ok_depois) / n:.0f}%; "
      f"sem os equivalentes ({ea} → {ed}), {100 * len(ok_antes) / (n - ea):.0f}% → "
      f"{100 * len(ok_depois) / (n - ed):.0f}%)")
print(f"perdidos {len(perdidos)}: {perdidos}")
print(f"novos {len(novos)}, por gravidade: {dict(Counter(antes[i].get('gravidade') for i in novos))}")
print("sobrevivem por gravidade:", dict(Counter(antes[i].get("gravidade") for i in validos
                                                 if depois[i]["morto_por"] is None)))
