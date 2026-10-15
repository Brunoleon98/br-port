"""Compara todos os campos do percurso experimental com a ação integrada."""
from pathlib import Path
import argparse
import json
import os
import zipfile
from medir_cancelamento import executar, CENARIOS


def diferenca(a, b, caminho="raiz"):
    if isinstance(a, bool) != isinstance(b, bool):
        return f"{caminho}: booleano trocado por outro tipo"
    if isinstance(a, dict) and isinstance(b, dict):
        if a.keys() != b.keys():
            return f"{caminho}: chaves diferentes"
        for k in a:
            erro = diferenca(a[k], b[k], f"{caminho}.{k}")
            if erro:
                return erro
    elif isinstance(a, list) and isinstance(b, list):
        if len(a) != len(b):
            return f"{caminho}: tamanhos {len(a)} != {len(b)}"
        for i, (x, y) in enumerate(zip(a, b)):
            erro = diferenca(x, y, f"{caminho}[{i}]")
            if erro:
                return erro
    elif a != b:
        return f"{caminho}: {a!r} != {b!r}"
    return ""


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--godot", type=Path, required=True)
    ap.add_argument("--saida", type=Path, required=True)
    ap.add_argument("--partidas", type=int, default=3)
    ap.add_argument("--janela", type=int, default=56)
    args = ap.parse_args()
    raiz = Path(__file__).resolve().parents[1]
    saida = args.saida.resolve()
    saida.mkdir(parents=True, exist_ok=True)
    ambiente = dict(os.environ, APPDATA=str(saida / "perfil"), PYTHONUTF8="1")
    totais = []
    arquivo = raiz / "docs/arquivo/MEDICOES_CANCELAMENTO_2026-10-15/partidas.zip"
    for nome, politica, rep, multa in CENARIOS[:5]:
        dados = []
        for modo in ["experimental", "producao"]:
            destino = saida / f"{nome}-{modo}.json"
            argumentos = ["--script", "res://tools/medir_cancelamento.gd", "--",
                          str(args.partidas), "20260825", str(destino), str(args.janela),
                          politica, str(rep), str(multa)]
            if modo == "producao":
                argumentos.append("--producao")
            executar(args.godot, raiz / "brport_vs", saida, f"{nome}-{modo}",
                     argumentos, "CANCELAMENTO MEDIDO", ambiente)
            dados.append(json.loads(destino.read_text(encoding="utf-8")))
        erro = diferenca(*dados)
        if erro:
            raise RuntimeError(f"{nome}: {erro}")
        comparou_arquivo = args.partidas == 600 and args.janela == 365
        if comparou_arquivo:
            with zipfile.ZipFile(arquivo) as pacote:
                referencia = json.loads(pacote.read(f"principal/{nome}.json"))
            erro = diferenca(referencia, dados[1])
            if erro:
                raise RuntimeError(f"{nome} contra arquivo 110: {erro}")
        jogos = sum(len(g["partidas"]) for g in dados[1]["resultados"])
        eventos = sum(len(p["cancelamentos"]) for g in dados[1]["resultados"] for p in g["partidas"])
        totais.append(dict(cenario=nome, partidas=jogos, cancelamentos=eventos,
                           paridade_integral=True, arquivo_110=comparou_arquivo))
        print(f"PARIDADE {nome}: {jogos} partidas, {eventos} cancelamentos", flush=True)
    # A persistência usa o save 18 real, além da prova de retomada no T24.
    extras = ["2", "20260825", str(saida / "persistencia.json"), "60", "taxa", "5", "0.10", "--producao"]
    for modo in ["sem-save", "com-save"]:
        destino = saida / f"persistencia-{modo}.json"
        extras[2] = str(destino)
        executar(args.godot, raiz / "brport_vs", saida, f"persistencia-{modo}",
                 ["--script", "res://tools/medir_cancelamento.gd", "--", *extras,
                  *(["--com-save"] if modo == "com-save" else [])], "CANCELAMENTO MEDIDO", ambiente)
    sem = json.loads((saida / "persistencia-sem-save.json").read_text(encoding="utf-8"))
    com = json.loads((saida / "persistencia-com-save.json").read_text(encoding="utf-8"))
    erro = diferenca(sem, com)
    if erro:
        raise RuntimeError(f"persistência: {erro}")
    resumo = dict(cenarios=totais, autosave_integral=True, n_autosave=8,
                  eventos_autosave=sum(len(p["cancelamentos"]) for g in com["resultados"] for p in g["partidas"]))
    (saida / "paridade.json").write_text(json.dumps(resumo, ensure_ascii=False, indent=2), encoding="utf-8")
    print("PARIDADE CANCELAMENTO OK", flush=True)


if __name__ == "__main__":
    main()
