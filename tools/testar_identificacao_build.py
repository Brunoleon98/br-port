"""Exercita o gerador contra commits e alterações reais num Git descartável."""
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

GERADOR = Path(__file__).with_name("gerar_identificacao_build.py")


class IdentificacaoBuild(unittest.TestCase):
    def setUp(self):
        self.pasta = tempfile.TemporaryDirectory()
        self.addCleanup(self.pasta.cleanup)
        self.raiz = Path(self.pasta.name)
        self.git("init", "-q")
        (self.raiz / ".gitignore").write_text("brport_vs/dados/\n", encoding="utf-8")
        (self.raiz / "fonte.txt").write_text("original\n", encoding="utf-8")
        self.git("add", ".")
        self.git("-c", "user.name=Teste", "-c", "user.email=teste@local",
                 "commit", "-qm", "Fixture")

    def git(self, *args):
        return subprocess.check_output(["git", "-C", str(self.raiz), *args], text=True).strip()

    def gerar(self):
        subprocess.run([sys.executable, str(GERADOR), "--raiz", str(self.raiz)],
                       check=True, capture_output=True, text=True)
        return (self.raiz / "brport_vs/dados/identificacao_build.tres").read_text(encoding="utf-8")

    def test_commit_exato_e_geracao_repetida_nao_suja(self):
        esperado = self.git("rev-parse", "HEAD")
        primeiro = self.gerar()
        self.assertIn(f'metadata/commit = "{esperado}"', primeiro)
        self.assertIn("metadata/modificado = false", primeiro)
        self.assertEqual(primeiro, self.gerar())

    def test_alteracao_e_arquivo_novo_sao_modificados(self):
        for nome in ("fonte.txt", "novo.txt"):
            with self.subTest(nome=nome):
                p = self.raiz / nome
                p.write_text("alterado\n", encoding="utf-8")
                self.assertIn("metadata/modificado = true", self.gerar())
                if nome == "fonte.txt":
                    self.git("restore", nome)

    def test_commit_seguinte_substitui_identificacao_antiga(self):
        anterior = self.gerar()
        self.git("-c", "user.name=Teste", "-c", "user.email=teste@local",
                 "commit", "--allow-empty", "-qm", "Next fixture")
        novo = self.gerar()
        self.assertNotEqual(anterior, novo)
        self.assertIn(self.git("rev-parse", "HEAD"), novo)

    def test_falha_do_git_preserva_destino(self):
        destino = self.raiz / "anterior.tres"
        destino.write_text("preservar", encoding="utf-8")
        sem_git = self.raiz / "sem-git"
        sem_git.mkdir()
        # Fora de qualquer repositório pai, sem depender do Git do workspace.
        with tempfile.TemporaryDirectory() as externo:
            r = subprocess.run([sys.executable, str(GERADOR), "--raiz", externo,
                                "--saida", str(destino)], capture_output=True)
        self.assertNotEqual(r.returncode, 0)
        self.assertEqual(destino.read_text(encoding="utf-8"), "preservar")


if __name__ == "__main__":
    unittest.main()
