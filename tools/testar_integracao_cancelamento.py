"""Prova o T24 com defeitos semânticos na ação real e restauração entre eles."""
from pathlib import Path
import argparse
import os
from medir_cancelamento import executar


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--godot", type=Path, required=True)
    ap.add_argument("--saida", type=Path, required=True)
    args = ap.parse_args()
    raiz = Path(__file__).resolve().parents[1]
    fonte = raiz / "brport_vs/autoload/GameState.gd"
    original = fonte.read_bytes()
    texto = original.decode("utf-8")
    pasta = args.saida.resolve()
    pasta.mkdir(parents=True, exist_ok=True)
    ambiente = dict(os.environ, APPDATA=str(pasta / "perfil"), PYTHONUTF8="1")
    argumentos = ["--script", "res://tools/testar_cancelamento_producao.gd"]
    mutantes = {
        "multa-ausente": ('cash -= int(evento["multa"])', 'cash -= 0'),
        "reputacao-ausente": ('_change_reputation(-CANCELAMENTO_REPUTACAO)', '_change_reputation(0.0)'),
        "trabalhador-preso": ('trabalhador["busy_turns"] = 0', 'trabalhador["busy_turns"] = 1'),
        "conta-semanal-ausente": ('semana_atual["cancelamento"] += int(evento["multa"])', 'semana_atual["cancelamento"] += 0'),
        "migracao-inventa-multa": ('dados[chave]["cancelamento"] = 0', 'dados[chave]["cancelamento"] = 1'),
        "identidade-ignorada": ('if barco == null or int(barco["id"]) != id:', 'if barco == null:'),
        "orcamento-ignorado": ('if evento.is_empty() or evento != confirmado:', 'if evento.is_empty():'),
        "registro-ausente": ('servico_cancelado.emit(evento.duplicate(true))', 'pass # mutante: não emite o evento'),
    }
    def escrever(conteudo):
        temporario = fonte.with_suffix('.gd.mutante')
        temporario.write_bytes(conteudo)
        os.chmod(temporario, fonte.stat().st_mode)
        os.replace(temporario, fonte)
    executar(args.godot, raiz/'brport_vs', pasta, 'base', argumentos, 'CANCELAMENTO INTEGRADO OK', ambiente)
    try:
        for nome, (antes, depois) in mutantes.items():
            assert fonte.read_bytes() == original, "base não restaurada"
            assert texto.count(antes) == 1, (nome, texto.count(antes))
            escrever(texto.replace(antes, depois).encode('utf-8'))
            try:
                executar(args.godot, raiz/'brport_vs', pasta, nome, argumentos, 'CANCELAMENTO INTEGRADO OK', ambiente)
            except RuntimeError:
                log = (pasta / f'{nome}.log').read_text(encoding='utf-8')
                assert 'FAIL T24:' in log and 'SCRIPT ERROR' not in log and 'GDScript backtrace' not in log and 'at: push_error (' not in log, nome
            else:
                raise AssertionError(f'{nome} passou com defeito')
            finally:
                escrever(original)
            executar(args.godot, raiz/'brport_vs', pasta, nome+'-restaurado', argumentos, 'CANCELAMENTO INTEGRADO OK', ambiente)
            print('RECUSADO E RESTAURADO: '+nome, flush=True)
    finally:
        escrever(original)
    assert fonte.read_bytes() == original
    # Marcador próprio, sem conter o verde da suíte que este controlador roda.
    print('INJECOES DO CANCELAMENTO CONFERIDAS', flush=True)


if __name__ == '__main__':
    main()
