"""Prova o executor de mutantes em paralelo e em fatias, com os defeitos dele.

O motor é falso: um script no lugar do Godot que imprime o marcador da suíte
pedida, a menos que o projeto traga um `MUTADO:<guarda>` — aí reprova com
«FALHA <guarda>», como as suítes de verdade. O repositório também é falso, e
pequeno: o executor, um catálogo de seis defeitos e um `testes.yml` com as
seis chamadas. Corre em segundos e sem Godot (`docs/decisoes/137`).

Cada caso é um defeito que a camada nova tem de apanhar, e que ninguém veria
de outro modo: um trabalhador furado entre verdes a passar o job por verde
(o `grep` do CI casava com o marcador dele), uma fatia que não correu, uma
que correu os mutantes de outra, um mutante sem prova ao juntar, o
`testes.yml` com outro relógio, e a cópia diferente da árvore.

    python3 tools/testar_conferir_mutantes.py      # espera EXECUTOR PROVADO
"""
import argparse
import importlib.util
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from unittest import mock

EXECUTOR = Path(__file__).with_name("conferir_mutantes.py")

MOTOR_FALSO = r"""#!/usr/bin/env python3
import re, sys
from pathlib import Path
args = sys.argv[1:]
projeto = Path(args[args.index("--path") + 1])
if "--import" in args:
    sys.exit(0)
assert args[:3] == ["--headless", "--fixed-fps", "60"], args
script = args[args.index("--script") + 1]
marcadores = {"run_tests": "TODOS OS TESTES PASSARAM", "teste_design": "DESIGN OK",
              "teste_audio": "AUDIO OK", "teste_fumaca": "FUMACA OK",
              "teste_registro": "REGISTRO OK", "asset_validator": "ASSET OK"}
suite = Path(script).stem
mutados = []
for p in sorted(projeto.rglob("*.gd")):
    mutados += re.findall(r"MUTADO:(\w+)", p.read_text())
for g in mutados:
    print("  FALHA guarda %s" % g)
if not mutados:
    print(marcadores[suite])
"""

SUITES = {
    "run_tests": "res://tests/run_tests.gd", "teste_design": "res://tests/teste_design.gd",
    "teste_audio": "res://tests/teste_audio.gd", "teste_fumaca": "res://tests/teste_fumaca.gd",
    "teste_registro": "res://tests/teste_registro.gd",
    "asset_validator": "res://scripts/validation/asset_validator.gd",
}
MARCADORES = {
    "run_tests": "TODOS OS TESTES PASSARAM", "teste_design": "DESIGN OK",
    "teste_audio": "AUDIO OK", "teste_fumaca": "FUMACA OK", "teste_registro": "REGISTRO OK",
    "asset_validator": "ASSET OK",
}


def workflow(relogio: str = "--fixed-fps 60 ") -> str:
    passos = []
    for nome, script in SUITES.items():
        passos.append(f'      - run: |\n          $G \\\n            --headless {relogio}'
                      f'--path brport_vs --script {script} | tee x\n'
                      f'          grep -q "{MARCADORES[nome]}" x\n')
    return "jobs:\n  t:\n    steps:\n" + "".join(passos)


def catalogo(sobrevive: str | None = None) -> str:
    # Seis defeitos, um por suíte da lista, em seis arquivos: as fatias e os
    # trabalhadores têm de repartir mais do que um de cada.
    linhas = []
    for i, suite in enumerate(["run_tests", "run_tests", "teste_design",
                               "teste_design", "teste_fumaca", "teste_audio"]):
        mid = f"m{i}"
        depois = f"var x = 2  # sem marca" if mid == sobrevive else f"var x = 1  # MUTADO:{mid}"
        linhas.append(f'[[mutante]]\nid = "{mid}"\nde = "137"\no_que = "x"\n'
                      f'alvo = "brport_vs/scripts/A{i}.gd"\nantes = "var x = 1"\n'
                      f'depois = "{depois}"\nreprova = {{ {suite} = "guarda {mid}" }}\n')
    return "\n".join(linhas)


class Executor(unittest.TestCase):
    def setUp(self):
        pasta = tempfile.TemporaryDirectory()
        self.addCleanup(pasta.cleanup)
        self.tmp = Path(pasta.name)
        self.raiz = self.tmp / "repo"
        (self.raiz / "tools").mkdir(parents=True)
        shutil.copy(EXECUTOR, self.raiz / "tools" / "conferir_mutantes.py")
        (self.raiz / ".github" / "workflows").mkdir(parents=True)
        (self.raiz / ".github" / "workflows" / "testes.yml").write_text(workflow())
        proj = self.raiz / "brport_vs"
        (proj / ".godot").mkdir(parents=True)
        (proj / "scripts").mkdir()
        for i in range(6):
            (proj / "scripts" / f"A{i}.gd").write_text(f"extends Node\nvar x = 1\n# {i}\n")
        (self.raiz / "tools" / "mutantes.toml").write_text(catalogo())
        self.motor = self.tmp / "godot"
        self.motor.write_text(MOTOR_FALSO)
        self.motor.chmod(0o755)

    def correr(self, *args, saida="saida", env=None):
        r = subprocess.run([sys.executable, str(self.raiz / "tools" / "conferir_mutantes.py"),
                            "--godot", str(self.motor), "--saida", str(self.tmp / saida), *args],
                           capture_output=True, text=True, timeout=120,
                           env=dict(os.environ, **(env or {})))
        return r.returncode, r.stdout + r.stderr

    def originais(self):
        return {p.name: p.read_bytes() for p in (self.raiz / "brport_vs" / "scripts").iterdir()}

    def test_em_serie_e_em_paralelo_dao_o_mesmo_verde(self):
        antes = self.originais()
        rc, out = self.correr()
        self.assertEqual(rc, 0, out)
        self.assertRegex(out, r"(?m)^MUTANTES OK — 6 defeito")
        rc, out = self.correr("--trabalhadores", "3", saida="par")
        self.assertEqual(rc, 0, out)
        self.assertEqual(len(re.findall(r"(?m)^MUTANTES OK", out)), 1, out)
        self.assertIn("[t1] trabalhador verde", out)
        rel = json.loads((self.tmp / "par" / "relatorio.json").read_text())
        self.assertEqual(set(rel), {f"m{i}" for i in range(6)})
        self.assertFalse((self.tmp / "par" / "copias").exists(), "as cópias ficaram no disco")
        self.assertEqual(self.originais(), antes, "o paralelo tocou no original")

    def test_um_trabalhador_furado_nao_passa_o_job_por_verde(self):
        # O defeito que o `grep -q "MUTANTES OK"` sem âncora deixava passar:
        # dois trabalhadores verdes imprimem o marcador deles, e um furado.
        (self.raiz / "tools" / "mutantes.toml").write_text(catalogo(sobrevive="m2"))
        rc, out = self.correr("--trabalhadores", "3")
        self.assertEqual(rc, 1, out)
        self.assertNotRegex(out, r"(?m)^MUTANTES OK", out)
        self.assertIn("SOBREVIVEU", out)
        self.assertRegex(out, r"(?m)^::error::t\d saiu com 1")

    def remendar_trabalhador(self, ancora, linha):
        # Só o ramo em SÉRIE muda — é o que cada trabalhador corre na cópia;
        # o pai entra no ramo paralelo antes de chegar lá.
        p = self.raiz / "tools" / "conferir_mutantes.py"
        texto = p.read_text()
        self.assertEqual(texto.count(ancora), 1, ancora)
        p.write_text(texto.replace(ancora, ancora + "\n" + linha, 1))

    def test_o_trabalhador_que_sai_com_zero_sem_prova_reprova(self):
        # Cada cerca do pai tem o seu estado: sair com zero CALADO (o
        # marcador), e sair com o marcador mas sem o relatório inteiro.
        ancora = "    exploradas = args.suites or list(SUITES)"
        self.remendar_trabalhador(ancora, "    if os.environ.get('CALADO'): return 0")
        rc, out = self.correr("--trabalhadores", "2", env={"CALADO": "1"})
        self.assertEqual(rc, 1, out)
        self.assertIn("não imprimiu «MUTANTES OK — 3 defeito(s)»", out)
        self.assertNotRegex(out, r"(?m)^MUTANTES OK")

    def test_o_trabalhador_com_relatorio_curto_reprova(self):
        # O relatório da SÉRIE é o que vem logo antes do `if args.explorar`.
        p = self.raiz / "tools" / "conferir_mutantes.py"
        texto = p.read_text()
        ancora = 'encoding="utf-8")\n    if args.explorar:'
        self.assertEqual(texto.count(ancora), 1)
        p.write_text(texto.replace(ancora, 'encoding="utf-8")\n'
                     "    if os.environ.get('CURTO'): (saida / 'relatorio.json').write_text("
                     "json.dumps(dict(list(resultado.items())[1:])))\n"
                     "    if args.explorar:", 1))
        rc, out = self.correr("--trabalhadores", "2", env={"CURTO": "1"})
        self.assertEqual(rc, 1, out)
        self.assertRegex(out, r"o relatório traz 2 mutante\(s\), e couberam-lhe 3")
        self.assertNotRegex(out, r"(?m)^MUTANTES OK")

    def test_a_copia_recusada_nao_deixa_trabalhador_vivo(self):
        # Medido no dia em que o paralelo nasceu: a t3 recusada, e a t1 e a t2
        # já a correr, órfãs, por baixo da corrida seguinte. Aqui a t2 sai
        # diferente da árvore, e nenhum trabalhador pode ter arrancado.
        spec = importlib.util.spec_from_file_location(
            "cm_falso", self.raiz / "tools" / "conferir_mutantes.py")
        cm = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(cm)
        verdadeiro = cm.digerir

        def digerir(raiz, ignorar):
            d = verdadeiro(raiz, ignorar)
            if Path(raiz).name == "t2":
                d["intruso.gd"] = "outro"
            return d

        lancados = []
        args = argparse.Namespace(saida=self.tmp / "recusa", trabalhadores=3,
                                  godot=str(self.motor),
                                  catalogo=self.raiz / "tools" / "mutantes.toml")
        with mock.patch.object(cm, "digerir", digerir), \
                mock.patch.object(cm.subprocess, "Popen",
                                  lambda *a, **k: lancados.append(a)):
            rc = cm.em_paralelo(args, cm.carregar_catalogo(args.catalogo))
        self.assertEqual(rc, 1)
        self.assertEqual(lancados, [], "um trabalhador arrancou antes de a cópia dele ser recusada")
        self.assertFalse((self.tmp / "recusa" / "copias").exists())

    def test_o_relogio_do_ci_tem_de_ser_o_do_executor(self):
        (self.raiz / ".github" / "workflows" / "testes.yml").write_text(workflow(relogio=""))
        rc, out = self.correr("--trabalhadores", "2")
        self.assertEqual(rc, 1, out)
        self.assertEqual(out.count("mesmo relógio"), 6, out)
        self.assertIn("nada foi injetado", out)

    def test_as_fatias_somam_o_catalogo(self):
        for i in (1, 2, 3):
            rc, out = self.correr("--fatia", f"{i}/3", "--trabalhadores", "2", saida=f"f{i}")
            self.assertEqual(rc, 0, out)
        pastas = [str(self.tmp / f"f{i}") for i in (1, 2, 3)]
        juntar = lambda *ps: self.correr("--juntar", *ps)
        rc, out = juntar(*pastas)
        self.assertEqual(rc, 0, out)
        self.assertRegex(out, r"(?m)^MUTANTES OK — 6 defeito\(s\) do catálogo em 3 fatia")
        # Uma fatia que não correu.
        rc, out = juntar(pastas[0], pastas[2])
        self.assertEqual(rc, 1, out)
        self.assertIn("faltou a fatia 2/3", out)
        self.assertNotRegex(out, r"(?m)^MUTANTES OK")
        # A mesma fatia duas vezes no lugar de outra.
        rc, out = juntar(pastas[0], pastas[0], pastas[2])
        self.assertEqual(rc, 1, out)
        self.assertIn("aparece duas vezes", out)
        # Uma fatia que correu os mutantes de outra.
        f2 = self.tmp / "f2" / "fatia.json"
        dado = json.loads(f2.read_text())
        f2.write_text(json.dumps({"fatia": dado["fatia"],
                                  "ids": json.loads((self.tmp / "f1" / "fatia.json").read_text())["ids"]}))
        rc, out = juntar(*pastas)
        self.assertEqual(rc, 1, out)
        self.assertIn("não correu os mutantes que lhe cabem", out)
        f2.write_text(json.dumps(dado))
        # Um mutante sem prova no relatório.
        r3 = self.tmp / "f3" / "relatorio.json"
        rel = json.loads(r3.read_text())
        mid = sorted(rel)[0]
        for suite in rel[mid]:
            rel[mid][suite]["aprovado"] = False
        r3.write_text(json.dumps(rel))
        rc, out = juntar(*pastas)
        self.assertEqual(rc, 1, out)
        self.assertIn(f"{mid} não foi aprovado", out)
        # Nenhuma pasta legível.
        rc, out = juntar(str(self.tmp / "nada"))
        self.assertEqual(rc, 1, out)

    def test_a_fatia_vermelha_nao_escreve_a_sua_prova(self):
        (self.raiz / "tools" / "mutantes.toml").write_text(catalogo(sobrevive="m0"))
        # Em série e em paralelo: quem não acaba verde não deixa `fatia.json`
        # para o `--juntar` contar.
        for extra, saida in (([], "s"), (["--trabalhadores", "2"], "p")):
            fatias = []
            for i in (1, 2):
                rc, _ = self.correr("--fatia", f"{i}/2", *extra, saida=f"{saida}{i}")
                fatias.append(rc)
                if rc:
                    self.assertFalse((self.tmp / f"{saida}{i}" / "fatia.json").exists())
            self.assertIn(1, fatias)


class Contrato(unittest.TestCase):
    def test_o_ci_pede_o_marcador_no_inicio_da_linha(self):
        # O executor repassa as linhas dos trabalhadores com «[tN]» à frente;
        # isso só protege o job se quem procura o marcador o procurar no
        # INÍCIO da linha — nas fatias e no job que as junta.
        wf = (EXECUTOR.parents[1] / ".github" / "workflows" / "testes.yml").read_text()
        self.assertEqual(len(re.findall(r'grep -q "\^MUTANTES OK"', wf)), 2, wf.count("MUTANTES OK"))
        self.assertEqual(re.findall(r'grep -q "MUTANTES OK"', wf), [])
        self.assertIn("--trabalhadores 4", wf)
        # O K da fatia e a lista da matriz dizem o mesmo número, que vive em
        # dois sítios do arquivo: crescer um sem o outro deixa fatias sem job.
        k = re.findall(r"--fatia \$\{\{ matrix\.fatia \}\}/(\d+)", wf)
        lista = re.findall(r"fatia: \[([\d, ]+)\]", wf)
        self.assertEqual(len(k), 1, k)
        self.assertEqual(len(lista), 1, lista)
        self.assertEqual([int(x) for x in lista[0].split(",")], list(range(1, int(k[0]) + 1)))

    def test_o_testes_yml_de_verdade_corre_as_suites_com_o_relogio_do_executor(self):
        # O executor confere-o antes de injetar, mas só no job das fatias;
        # aqui a resposta chega em segundos, no início da suíte.
        spec = importlib.util.spec_from_file_location("cm", EXECUTOR)
        cm = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(cm)
        self.assertEqual(cm.suites_batem_com_o_ci(), [])

    def test_a_copia_diferente_da_arvore_reprova(self):
        spec = importlib.util.spec_from_file_location("cm", EXECUTOR)
        cm = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(cm)
        with tempfile.TemporaryDirectory() as t:
            a = Path(t, "a")
            (a / "x").mkdir(parents=True)
            (a / "x" / "f.gd").write_text("var x = 1\n")
            (a / ".git").mkdir()
            (a / ".git" / "HEAD").write_text("ref")
            ign = cm._fora_da_copia(a, Path(t, "saida"))
            shutil.copytree(a, Path(t, "b"), ignore=ign)
            b = Path(t, "b")
            self.assertFalse((b / ".git").exists())
            self.assertEqual(cm.digerir(a, ign), cm.digerir(b, cm._fora_da_copia(b, Path(t, "saida"))))
            (b / "x" / "f.gd").write_text("var x = 2\n")
            self.assertNotEqual(cm.digerir(a, ign), cm.digerir(b, ign))

    def test_a_partilha_e_estavel_e_iguala_as_suites(self):
        spec = importlib.util.spec_from_file_location("cm", EXECUTOR)
        cm = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(cm)
        cat = cm.carregar_catalogo(EXECUTOR.with_name("mutantes.toml"))
        for k in (2, 3, 4):
            partes = cm.repartir(cat, k)
            self.assertEqual(sorted(m["id"] for p in partes for m in p),
                             sorted(m["id"] for m in cat))
            self.assertEqual([[m["id"] for m in p] for p in partes],
                             [[m["id"] for m in p] for p in cm.repartir(list(reversed(cat)), k)])
            for suite in cm.SUITES:
                n = [sum(1 for m in p if suite in m["reprova"]) for p in partes]
                self.assertLessEqual(max(n) - min(n), 1, (k, suite, n))


if __name__ == "__main__":
    r = unittest.main(exit=False, verbosity=1).result
    if r.wasSuccessful() and r.testsRun:
        print("EXECUTOR PROVADO — %d caso(s)" % r.testsRun)
    sys.exit(0 if r.wasSuccessful() else 1)
