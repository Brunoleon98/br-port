#!/usr/bin/env python3
"""Exemplos de regressão do preparador; não avaliam o gosto das falas."""
import hashlib
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

import preparar_revisao_mensagens as revisor


class ContextoDaRevisao(unittest.TestCase):
    def setUp(self):
        self.pasta = tempfile.TemporaryDirectory()
        self.addCleanup(self.pasta.cleanup)
        self.raiz = Path(self.pasta.name)
        for nome in revisor.INTEIROS:
            p = self.raiz / nome
            p.parent.mkdir(parents=True, exist_ok=True)
            p.write_text("# referência\n", encoding="utf-8")

    def test_texto_local_e_constante_ficam_inteiros(self):
        texto = ('const CENA = "Lembrança"\nstatic func fim():\n'
                 '\tvar modelo = """Uma página\nque não é constante."""\n'
                 '\treturn modelo\n')
        (self.raiz / revisor.CATALOGO).write_text(texto, encoding="utf-8")
        manifesto, pacote = revisor.preparar(self.raiz)
        fonte = next(f for f in manifesto["fontes"] if f["arquivo"] == revisor.CATALOGO)
        self.assertEqual(fonte["sha256"], hashlib.sha256(texto.encode()).hexdigest())
        esperado = ('1: const CENA = "Lembrança"\n2: static func fim():\n'
                    '3: \tvar modelo = """Uma página\n'
                    '4: que não é constante."""\n5: \treturn modelo')
        self.assertIn(esperado, pacote)

    def test_chamada_conserva_condicao_e_corpo(self):
        p = self.raiz / "brport_vs/autoload/Exemplo.gd"
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text('func antes():\n\tpass\n\nfunc mostrar():\n'
                     '\tif parcela_paga:\n\t\tmessage.emit(Narrativa.cida("quitado"))\n'
                     '\nfunc depois():\n\tpass\n', encoding="utf-8")
        manifesto, pacote = revisor.preparar(self.raiz)
        self.assertIn("5: \tif parcela_paga:", pacote)
        self.assertIn('6: \t\tmessage.emit(Narrativa.cida("quitado"))', pacote)
        self.assertNotIn("1: func antes():", pacote)
        fonte = next(f for f in manifesto["fontes"] if f["arquivo"].endswith("Exemplo.gd"))
        self.assertEqual(fonte["trechos"], [(4, 7)])

    def test_fonte_obrigatoria_ausente_nao_vira_pacote_vazio(self):
        (self.raiz / revisor.CATALOGO).unlink()
        with self.assertRaises(FileNotFoundError):
            revisor.preparar(self.raiz)

    def test_mesma_arvore_tem_mesmo_contexto_e_edicao_muda_hash(self):
        antes = revisor.preparar(self.raiz)
        self.assertEqual(antes, revisor.preparar(self.raiz))
        p = self.raiz / revisor.CATALOGO
        p.write_text('const FALA = "Senta aqui, chefia."\n', encoding="utf-8")
        self.assertNotEqual(antes, revisor.preparar(self.raiz))

    def test_gravacao_preserva_modo_e_conteudo(self):
        p = self.raiz / "pacote.md"
        p.write_text("versão anterior", encoding="utf-8")
        p.chmod(0o640)
        revisor.gravar_atomico(p, "nova versão\n")
        self.assertEqual(p.read_text(), "nova versão\n")
        self.assertEqual(p.stat().st_mode & 0o777, 0o640)

    def test_falha_ao_substituir_preserva_anterior_e_limpa_temporario(self):
        pasta = self.raiz / "saida"
        pasta.mkdir()
        p = pasta / "pacote.md"
        p.write_text("versão anterior", encoding="utf-8")
        with patch.object(revisor.os, "replace", side_effect=OSError("sem acesso")):
            with self.assertRaises(OSError):
                revisor.gravar_atomico(p, "nova versão")
        self.assertEqual(p.read_text(), "versão anterior")
        self.assertEqual(list(pasta.iterdir()), [p])


if __name__ == "__main__":
    unittest.main()
