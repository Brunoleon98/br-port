"""Prova que a chave de um trabalhador chega ao --import e que o projeto volta igual.

O motor é falso: um script que guarda o project.godot que viu e sai com o código
pedido. Até 18/10 a prova do helper LIA a chave num --script, que lê o
override.cfg, e o --import, que não o lê, continuou paralelo (docs/decisoes/106).
Que o Godot importa em série com a chave no project.godot está medido na 106;
aqui prova-se que ela está LÁ quando o motor importa.
"""
import importlib.util
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

HELPER = Path(__file__).with_name("importar_para_ci.py")
CHAVE = "import/use_multiple_threads=false"

MOTOR_FALSO = """#!/usr/bin/env python3
import shutil, sys
from pathlib import Path
args = sys.argv[1:]
assert args[0] == "--headless" and args[1] == "--path" and args[3] == "--import", args
projeto = Path(args[2])
shutil.copy(projeto / "project.godot", projeto.parent / "visto.godot")
sys.exit(int((projeto.parent / "codigo").read_text()))
"""


class ImportarParaCI(unittest.TestCase):
    def setUp(self):
        pasta = tempfile.TemporaryDirectory()
        self.addCleanup(pasta.cleanup)
        self.raiz = Path(pasta.name)
        self.projeto = self.raiz / "projeto"
        self.projeto.mkdir()
        self.config = self.projeto / "project.godot"
        self.motor = self.raiz / "godot"
        self.motor.write_text(MOTOR_FALSO, encoding="utf-8")
        self.motor.chmod(0o755)
        (self.raiz / "codigo").write_text("0", encoding="utf-8")

    def escrever(self, texto: str) -> bytes:
        self.config.write_bytes(texto.encode("utf-8"))
        self.config.chmod(0o640)
        return self.config.read_bytes()

    def importar(self, motor=None):
        return subprocess.run([sys.executable, str(HELPER), str(self.projeto),
                               str(motor or self.motor)], capture_output=True, text=True)

    def visto(self) -> str:
        return (self.raiz / "visto.godot").read_text(encoding="utf-8")

    def conferir_devolvido(self, original: bytes):
        self.assertEqual(self.config.read_bytes(), original)
        self.assertEqual(self.config.stat().st_mode & 0o777, 0o640)
        self.assertEqual(sorted(p.name for p in self.projeto.iterdir()), ["project.godot"])

    def test_chave_chega_ao_import_e_o_projeto_volta(self):
        original = self.escrever('config_version=5\n\n[application]\n\nconfig/name="X"\n')
        (self.raiz / "codigo").write_text("17", encoding="utf-8")
        r = self.importar()
        self.assertEqual(r.returncode, 17, r.stderr)
        visto = self.visto()
        self.assertIn("\n[editor]\n", visto)
        self.assertIn(CHAVE, visto.split("[editor]", 1)[1])
        self.assertTrue(visto.startswith(original.decode("utf-8")))
        self.conferir_devolvido(original)

    def test_secao_editor_existente_recebe_a_chave_sem_duplicar(self):
        original = self.escrever('config_version=5\n\n[editor]\n\nmovie_writer/fps=30\n\n'
                                 '[rendering]\n\nx=1\n')
        self.assertEqual(self.importar().returncode, 0)
        visto = self.visto()
        self.assertEqual(visto.count("[editor]"), 1)
        self.assertIn(CHAVE, visto.split("[editor]", 1)[1].split("[rendering]", 1)[0])
        self.conferir_devolvido(original)

    def test_chave_ja_escrita_e_recusada_sem_tocar_nem_importar(self):
        original = self.escrever(f"config_version=5\n\n[editor]\n\n{CHAVE}\n")
        r = self.importar()
        self.assertNotEqual(r.returncode, 0)
        self.assertIn("não o substituo", r.stderr)
        self.assertFalse((self.raiz / "visto.godot").exists())
        self.conferir_devolvido(original)

    def test_motor_ausente_devolve_o_projeto(self):
        original = self.escrever("config_version=5\n")
        r = self.importar(self.raiz / "nao-existe")
        self.assertNotEqual(r.returncode, 0)
        self.assertIn("FileNotFoundError", r.stderr)
        self.conferir_devolvido(original)

    def test_secao_nova_tem_a_forma_do_editor(self):
        # A forma: seção, linha em branco, chave — a mesma que o editor grava.
        spec = importlib.util.spec_from_file_location("importar_para_ci", HELPER)
        modulo = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(modulo)
        self.assertEqual(modulo.com_um_trabalhador("a=1"), f"a=1\n\n[editor]\n\n{CHAVE}\n")


if __name__ == "__main__":
    unittest.main()
