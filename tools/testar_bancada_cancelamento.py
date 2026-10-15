"""Controles da bancada e mutantes semânticos; execute sem outro Godot ativo."""
from pathlib import Path
import argparse
import json
import os
from medir_cancelamento import executar


def trocar_atomico(alvo, texto):
    temporario = alvo.with_suffix(".temporario")
    temporario.write_bytes(texto)
    os.chmod(temporario, alvo.stat().st_mode)
    os.replace(temporario, alvo)


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--godot", type=Path, required=True)
    ap.add_argument("--saida", type=Path, required=True)
    args = ap.parse_args()
    raiz = Path(__file__).resolve().parents[1]
    pasta = args.saida.resolve()
    pasta.mkdir(parents=True, exist_ok=True)
    alvo = raiz / "brport_vs/tools/estado_cancelamento_experimental.gd"
    original = alvo.read_bytes()
    ambiente = dict(os.environ, APPDATA=str(pasta / "perfil"), PYTHONUTF8="1")
    comando = ["--script", "res://tools/testar_cancelamento_experimental.gd"]

    def aprovar(nome):
        executar(args.godot, raiz / "brport_vs", pasta, nome, comando, "BANCADA CANCELAMENTO OK", ambiente)

    aprovar("base")
    mutantes = [
        ("multa-ausente", b"cash -= multa", b"cash -= 0"),
        ("reputacao-ausente", b"_change_reputation(-perda_reputacao)", b"_change_reputation(0)"),
        ("trabalhador-preso", b'trabalhador["busy_turns"] = 0', b'trabalhador["busy_turns"] = 1'),
        ("perda-duplicada", b'metrics["boats_lost"] += 1', b'metrics["boats_lost"] += 2'),
    ]
    resultado = {}
    try:
        for nome, antes, depois in mutantes:
            assert alvo.read_bytes() == original
            assert original.count(antes) == 1
            trocar_atomico(alvo, original.replace(antes, depois))
            try:
                aprovar(nome)
            except RuntimeError:
                log = (pasta / f"{nome}.log").read_text(encoding="utf-8")
                assert "FALHOU " in log and "BANCADA CANCELAMENTO OK" not in log
                assert "SCRIPT ERROR" not in log and "at: push_error (" not in log
                resultado[nome] = "recusado pelas asserções"
            else:
                raise AssertionError(f"Mutante aceito: {nome}")
            finally:
                trocar_atomico(alvo, original)
            aprovar(f"restaurado-{nome}")
    finally:
        trocar_atomico(alvo, original)
    assert alvo.read_bytes() == original
    (pasta / "mutantes.json").write_text(json.dumps(resultado, ensure_ascii=False, indent=2)+"\n", encoding="utf-8")
    print("CONTROLES CANCELAMENTO OK")


if __name__ == "__main__":
    main()
