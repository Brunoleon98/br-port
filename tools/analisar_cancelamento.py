"""Confere todos os cenários e compara partidas com o mesmo índice/semente."""
from pathlib import Path
import argparse
import copy
import json
from conferir_cancelamento import conferir, quantis, resumo_extra
from medir_cancelamento import CENARIOS


def analisar(pasta):
    cenarios = {nome: json.loads((pasta / f"{nome}.json").read_text(encoding="utf-8"))
                for nome, *_ in CENARIOS}
    for nome, politica, reputacao, multa in CENARIOS:
        dados = cenarios[nome]
        assert (dados["politica"], dados["perda_reputacao"], dados["multa_fracao"]) == (politica, reputacao, multa)
        conferir(dados)
    controle = cenarios["controle"]
    original = json.loads((pasta / "base-main.json").read_text(encoding="utf-8"))
    comparados = 0
    for base, experimental in zip(original["resultados"], controle["resultados"], strict=True):
        assert base["perfil"] == experimental["perfil"]
        assert base["resumo"] == experimental["resumo"]
        for a, b in zip(base["partidas"], experimental["partidas"], strict=True):
            for chave in a:
                assert a[chave] == b[chave], (base["perfil"], a["partida"], chave)
                comparados += 1
    resultado = {"n": controle["n"], "semente": controle["semente"], "janela": controle["janela"],
                 "paridade_main_campos": comparados, "cenarios": {}}
    for nome, dados in cenarios.items():
        resumo = resumo_extra(dados)
        for base, candidato in zip(controle["resultados"], dados["resultados"], strict=True):
            pares = list(zip(base["partidas"], candidato["partidas"], strict=True))
            assert all(a["partida"] == b["partida"] and a["caixa_entrada"] == b["caixa_entrada"] for a, b in pares)
            pares = [(a, b) for a, b in pares if a["entrada"] is not None and b["entrada"] is not None]
            metas = [(a, b) for a, b in pares if a["dias_ate_meta"] is not None and b["dias_ate_meta"] is not None]
            r = resumo[candidato["perfil"]]
            r["delta_caixa_final_pareado"] = quantis([b["caixa_final"]-a["caixa_final"] for a, b in pares])
            r["delta_dias_entre_duas_metas"] = quantis([b["dias_ate_meta"]-a["dias_ate_meta"] for a, b in metas])
            r["mais_caixa_que_controle"] = sum(b["caixa_final"] > a["caixa_final"] for a, b in pares)
            r["so_controle_conquistou"] = sum(a["dias_ate_meta"] is not None and b["dias_ate_meta"] is None for a, b in pares)
            r["so_candidato_conquistou"] = sum(a["dias_ate_meta"] is None and b["dias_ate_meta"] is not None for a, b in pares)
        resultado["cenarios"][nome] = {"politica": dados["politica"], "perda_reputacao": dados["perda_reputacao"],
                                         "multa_fracao": dados["multa_fracao"], "perfis": resumo}
    # O conferidor tem de acusar os defeitos que justificam confiar nele.
    mutantes = {}
    candidato = cenarios["candidato-taxa"]
    for nome in ("multa", "populacao", "nota", "quantil"):
        d = copy.deepcopy(candidato)
        if nome == "populacao":
            d["resultados"][0]["resumo"]["censuradas"] += 1
        elif nome == "quantil":
            d["resultados"][0]["resumo"]["caixa_final"]["p50"] += 1
        else:
            evento = next(e for g in d["resultados"] for p in g["partidas"] for e in p["cancelamentos"])
            if nome == "multa":
                evento["multa"] += 1
            else:
                evento["alternativa"]["nota"] += 1
        try:
            conferir(d)
        except AssertionError:
            mutantes[nome] = "recusado"
        else:
            raise AssertionError(f"Conferidor aceitou {nome}")
        conferir(candidato)
    resultado["controles_do_conferidor"] = mutantes
    return resultado


if __name__ == "__main__":
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("pasta", type=Path)
    args = ap.parse_args()
    resumo = analisar(args.pasta)
    texto = json.dumps(resumo, ensure_ascii=False, indent=2)
    (args.pasta / "resumo.json").write_text(texto+"\n", encoding="utf-8")
    for nome, c in resumo["cenarios"].items():
        for perfil, r in c["perfis"].items():
            print(nome, perfil, "cancel=", r["total_cancelamentos"], "metas=", r["metas"],
                  "dias=", r["dias_ate_meta"]["p50"], "delta_caixa=", r["delta_caixa_final_pareado"]["p50"])
    print("CANCELAMENTO ANALISADO")
