"""Recalcula a evidência de cancelamento sem usar a leitura do Godot."""
from pathlib import Path
from decimal import Decimal, ROUND_CEILING
import json
import sys

AMOSTRAS = ("dias_ate_meta", "caixa_entrada", "caixa_meta", "menor_caixa", "caixa_final",
            "margem_operacional", "dias_abaixo_piso", "suspensoes", "recuperacoes")


def quantis(valores):
    v = sorted(valores)
    return {"n": len(v), "p10": v[len(v)//10], "p50": v[len(v)//2],
            "p90": v[len(v)*9//10]} if v else {"n": 0, "p10": None, "p50": None, "p90": None}


def conferir(dados):
    assert [g["perfil"] for g in dados["resultados"]] == ["Ótimo", "Mediano", "Descuidado", "Antecipado"]
    for grupo in dados["resultados"]:
        partidas, resumo = grupo["partidas"], grupo["resumo"]
        assert len(partidas) == dados["n"]
        assert [p["partida"] for p in partidas] == list(range(dados["n"]))
        assert not any(p["travou"] for p in partidas)
        entradas = [p for p in partidas if p["entrada"] is not None]
        assert resumo["partidas"] == len(partidas)
        assert resumo["entraram"] == len(entradas)
        assert resumo["perdas_fase_1"] == len(partidas)-len(entradas)
        assert resumo["metas"] == sum(p["dias_ate_meta"] is not None for p in entradas)
        assert resumo["quebras_antes_meta"] == sum(p["quebrou"] and p["dias_ate_meta"] is None for p in entradas)
        assert resumo["quebras_apos_meta"] == sum(p["quebrou"] and p["dias_ate_meta"] is not None for p in entradas)
        assert resumo["censuradas"] == sum(not p["quebrou"] and p["dias_ate_meta"] is None for p in entradas)
        for chave in AMOSTRAS:
            assert resumo[chave] == quantis([p[chave] for p in entradas if p[chave] is not None]), chave
        for p in partidas:
            eventos = p["cancelamentos"]
            assert p["multas"] == sum(e["multa"] for e in eventos)
            assert p["receita_abandonada"] == sum(e["receita_abandonada"] for e in eventos)
            assert len({(e["dia"], e["uid"]) for e in eventos}) == len(eventos)
            assert len({e["dia"] for e in eventos}) == len(eventos), "mais de uma troca/dia"
            if dados["politica"] == "nenhuma":
                assert not eventos
            if dados["politica"] == "uma":
                assert len(eventos) <= 1
            for e in eventos:
                assert 0 < e["operados"] < e["total"]
                assert p["entrada"] <= e["dia"] < p["dia_final"]
                multa = int((Decimal(str(dados["multa_fracao"]))*e["valor_acordado"]).to_integral_value(rounding=ROUND_CEILING))
                assert e["multa"] == multa
                assert e["caixa_depois"] == e["caixa_antes"] - multa
                assert abs(e["rep_depois"] - max(0, e["rep_antes"]-dados["perda_reputacao"])) < 1e-8
                assert e["receita_abandonada"] >= e["valor_acordado"]
                assert p["menor_caixa"] <= e["caixa_depois"]
                a = e["alternativa"]
                assert a["restantes"] == e["total"]-e["operados"]
                nota = ((a["receita_nova"]-multa)/a["dias_novos"]
                        - e["receita_abandonada"]/a["restantes"])
                if dados["politica"] == "valor":
                    nota = a["receita_nova"]-multa-e["receita_abandonada"]
                assert abs(nota-a["nota"]) < 1e-6, "nota da alternativa"
                if dados["politica"] in ("taxa", "valor"):
                    assert e["alternativa"]["nota"] > 0
            if p["entrada"] is None:
                assert not eventos
                continue
            assert p["entrada"] == 85
            assert p["dia_final"]-85 == p["fechos_observados"] <= dados["janela"]
            assert p["quebrou"] or p["fechos_observados"] == dados["janela"]
            assert p["margem_operacional"] == p["caixa_final"]-p["caixa_entrada"]+p["investimento"]
            assert p["perdidos_fase_2"] >= len(eventos)
            assert p["pares_elegiveis"] >= p["dias_com_opcao"] >= len(eventos)
            if p["dias_ate_meta"] is not None:
                assert 1 <= p["dias_ate_meta"] <= p["fechos_observados"]
                assert p["dia_meta"] == 85+p["dias_ate_meta"]


def resumo_extra(dados):
    resultado = {}
    for grupo in dados["resultados"]:
        entradas = [p for p in grupo["partidas"] if p["entrada"] is not None]
        resultado[grupo["perfil"]] = dict(grupo["resumo"])
        r = resultado[grupo["perfil"]]
        r["partidas_com_cancelamento"] = sum(bool(p["cancelamentos"]) for p in entradas)
        r["total_cancelamentos"] = sum(len(p["cancelamentos"]) for p in entradas)
        for chave in ("dias_com_opcao", "multas", "receita_abandonada", "receita_fase_2", "servidos_fase_2", "perdidos_fase_2"):
            r[chave] = quantis([p[chave] for p in entradas])
        r["cancelamentos"] = quantis([len(p["cancelamentos"]) for p in entradas])
    return resultado


if __name__ == "__main__":
    for nome in sys.argv[1:]:
        conferir(json.loads(Path(nome).read_text(encoding="utf-8")))
    print("CANCELAMENTO CONFERIDO")
