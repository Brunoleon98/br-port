"""Bancada da 110: cenários em série, sem modificar o GameState do jogo."""
from pathlib import Path
import argparse
import json
import os
import subprocess

CENARIOS = [
    ("controle", "nenhuma", 5, .10),
    ("candidato-taxa", "taxa", 5, .10),
    ("candidato-valor", "valor", 5, .10),
    ("candidato-uma", "uma", 5, .10),
    ("candidato-impulsivo", "impulsivo", 5, .10),
    ("rep-zero", "taxa", 0, .10),
    ("rep-2-5", "taxa", 2.5, .10),
    ("rep-8", "taxa", 8, .10),
    ("multa-zero", "taxa", 5, 0),
    ("multa-5", "taxa", 5, .05),
    ("multa-20", "taxa", 5, .20),
    ("sem-custos", "taxa", 0, 0),
]


def executar(godot, projeto, saida, nome, argumentos, marcador, ambiente):
    log = saida / f"{nome}.log"
    with log.open("w", encoding="utf-8") as arquivo:
        processo = subprocess.run(
            [str(godot), "--headless", "--path", str(projeto), *argumentos],
            stdout=arquivo, stderr=subprocess.STDOUT, env=ambiente, check=False,
        )
    texto = log.read_text(encoding="utf-8")
    if processo.returncode or marcador not in texto or "SCRIPT ERROR" in texto or "at: push_error (" in texto:
        raise RuntimeError(f"{nome} reprovou; ver {log}")
    print(f"OK {nome}", flush=True)


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--godot", type=Path, required=True)
    ap.add_argument("--saida", type=Path, required=True)
    ap.add_argument("--partidas", type=int, default=600)
    ap.add_argument("--janela", type=int, default=365)
    ap.add_argument("--semente", type=int, default=20260825)
    ap.add_argument("--cenario", choices=[x[0] for x in CENARIOS])
    ap.add_argument("--com-save", action="store_true")
    args = ap.parse_args()
    raiz = Path(__file__).resolve().parents[1]
    projeto = raiz / "brport_vs"
    saida = args.saida.resolve()
    saida.mkdir(parents=True, exist_ok=True)
    ambiente = dict(os.environ, APPDATA=str(saida / "perfil"), PYTHONUTF8="1")
    parametros = [str(args.partidas), str(args.semente)]
    if args.cenario is None:
        executar(args.godot, projeto, saida, "base-main", [
            "--script", "res://tools/medir_fase_2.gd", "--", *parametros,
            str(saida / "base-main.json"), str(args.janela), "--sem-save",
        ], "FASE 2 MEDIDA", ambiente)
    for nome, politica, reputacao, multa in CENARIOS:
        if args.cenario and nome != args.cenario:
            continue
        argumentos = ["--script", "res://tools/medir_cancelamento.gd", "--", *parametros,
                      str(saida / f"{nome}.json"), str(args.janela), politica, str(reputacao), str(multa)]
        if args.com_save:
            argumentos.append("--com-save")
        executar(args.godot, projeto, saida, nome, argumentos, "CANCELAMENTO MEDIDO", ambiente)
        dados = json.loads((saida / f"{nome}.json").read_text(encoding="utf-8"))
        print(json.dumps({g["perfil"]: {
            "metas": g["resumo"]["metas"], "dias": g["resumo"]["dias_ate_meta"]["p50"],
            "cancelamentos": sum(len(p["cancelamentos"]) for p in g["partidas"]),
        } for g in dados["resultados"]}, ensure_ascii=False), flush=True)


if __name__ == "__main__":
    main()
