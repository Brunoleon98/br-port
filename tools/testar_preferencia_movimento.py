#!/usr/bin/env python3
"""Prova persistência entre processos e separação do jogador (`129`)."""
import argparse
import os
from pathlib import Path
import subprocess
import sys
import tempfile

from sentinela_do_jogador import plantar, conferir, pasta_do_usuario


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--godot", required=True)
    args = parser.parse_args()
    raiz = Path(__file__).resolve().parents[1]
    with tempfile.TemporaryDirectory(prefix="brport-rb6-") as temporario:
        env = os.environ.copy()
        # Também protege este ensaio se um defeito atingir ArmazemLocal.
        env.update(XDG_DATA_HOME=temporario, APPDATA=temporario,
                   LOCALAPPDATA=temporario, XDG_CACHE_HOME=temporario)
        anterior = os.environ.copy()
        try:
            os.environ.update(env)
            jogador = pasta_do_usuario(str(raiz / "brport_vs"))
            plantar(jogador)
        finally:
            os.environ.clear()
            os.environ.update(anterior)
        def processo(acao, valor):
            esperado = f"PREFERENCIA CONFERIDA {acao} {valor}"
            cmd = [args.godot, "--headless", "--path", str(raiz / "brport_vs"),
                   "--script", "res://tools/sondar_preferencia_movimento.gd",
                   "--", acao, valor]
            r = subprocess.run(cmd, env=env, text=True, capture_output=True, timeout=45)
            saida = r.stdout + r.stderr
            assert r.returncode == 0 and esperado in saida, saida
            assert "SCRIPT ERROR" not in saida and "at: push_error (" not in saida, saida
            print(esperado)
        processo("ler", "false")
        processo("escrever", "true")
        processo("ler", "true")
        processo("escrever", "false")
        processo("ler", "false")
        cfg = Path(jogador) / "ferramentas" / "apresentacao.cfg"
        cfg.write_text('[apresentacao]\nreduzir_movimento="true"\n', encoding="utf-8")
        processo("ler", "false")
        cfg.unlink()
        processo("ler", "false")
        assert not cfg.exists(), "ler preferência ausente criou arquivo"
        assert conferir(jogador) == 0
        # Sem --script, como o jogo real: prova também a escolha do caminho
        # do jogador e o singleton que a UI usa, além do leitor das ferramentas.
        projeto = Path(temporario) / "aplicacao"
        projeto.mkdir()
        for nome in ("ArmazemLocal.gd", "PreferenciasDeApresentacao.gd"):
            (projeto / nome).write_bytes((raiz / "brport_vs/scripts" / nome).read_bytes())
        (projeto / "project.godot").write_text(
            'config_version=5\n[application]\nconfig/name="RB6 prova de reinicio"\n'
            'run/main_scene="res://Main.tscn"\n[rendering]\n'
            'renderer/rendering_method="gl_compatibility"\n', encoding="utf-8")
        (projeto / "Main.tscn").write_text(
            '[gd_scene load_steps=2 format=3]\n'
            '[ext_resource type="Script" path="res://Main.gd" id="1"]\n'
            '[node name="Main" type="Node"]\nscript = ExtResource("1")\n', encoding="utf-8")
        (projeto / "Main.gd").write_text('''extends Node
func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	var pref := PreferenciasDeApresentacao.atual()
	var esperado := args[1] == "true"
	var ok := not ArmazemLocal.sob_ferramenta()
	ok = ok and pref.caminho == ArmazemLocal.RAIZ_DO_JOGADOR + PreferenciasDeApresentacao.ARQUIVO
	if args[0] == "escrever":
		ok = ok and pref.definir_reduzir_movimento(esperado) == OK
	ok = ok and pref.reduzir_movimento == esperado
	if ok:
		print("PREFERENCIA APP CONFERIDA ", args[0], " ", args[1])
	get_tree().quit(0 if ok else 1)
''', encoding="utf-8")
        env["XDG_CONFIG_HOME"] = temporario
        r = subprocess.run([sys.executable, str(raiz / "tools/importar_para_ci.py"),
                            str(projeto), args.godot], env=env,
                           text=True, capture_output=True, timeout=60)
        assert r.returncode == 0 and "SCRIPT ERROR" not in r.stdout + r.stderr, r.stdout + r.stderr
        for acao, valor in (("ler", "false"), ("escrever", "true"), ("ler", "true"),
                            ("escrever", "false"), ("ler", "false")):
            r = subprocess.run([args.godot, "--headless", "--path", str(projeto),
                                "--", acao, valor], env=env, text=True,
                               capture_output=True, timeout=45)
            saida = r.stdout + r.stderr
            esperado = f"PREFERENCIA APP CONFERIDA {acao} {valor}"
            assert r.returncode == 0 and esperado in saida and "SCRIPT ERROR" not in saida, saida
            print(esperado)
    print("REINICIO DE PREFERENCIA CONFERIDO")


if __name__ == "__main__":
    main()
