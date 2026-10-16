from pathlib import Path
import hashlib
import json
import os
import subprocess
import sys

raiz = Path.cwd().resolve()
pasta = raiz / '.evidencias/implementar-como-jogar'
ambiente = dict(os.environ, APPDATA=str(pasta / 'perfil'), LOCALAPPDATA=str(pasta / 'perfil'), PYTHONUTF8='1')
godot = r'C:\Users\bruno\Downloads\Godot_v4.6.3-stable_win64.exe\Godot_v4.6.3-stable_win64_console.exe'
painel = raiz / 'brport_vs/scripts/PainelComoJogar.gd'
main = raiz / 'brport_vs/scripts/Main.gd'
conteudo = raiz / 'brport_vs/scripts/ConteudoComoJogar.gd'
originais = {p: p.read_bytes() for p in (painel, main, conteudo)}
resultados = {}

def escrever(p, dados):
    temporario = p.with_suffix(p.suffix + '.controle-tmp')
    temporario.write_bytes(dados)
    os.chmod(temporario, p.stat().st_mode)
    os.replace(temporario, p)

def rodar(nome, saudavel):
    log = pasta / (nome + '.log')
    with log.open('w', encoding='utf-8') as saida:
        processo = subprocess.run([godot, '--headless', '--path', 'brport_vs', '--script', str(pasta/'t25.gd')], env=ambiente, stdout=saida, stderr=subprocess.STDOUT, timeout=150)
    texto = log.read_text(encoding='utf-8')
    erros = any(x in texto for x in ('SCRIPT ERROR', 'at: push_error (', 'Parse Error', 'Compile Error'))
    ok = (processo.returncode == 0 and 'T25 OK' in texto and 'FAIL T25:' not in texto) if saudavel else (processo.returncode != 0 and 'FAIL T25:' in texto and 'T25 OK' not in texto)
    ok = ok and not erros
    resultados[nome] = {'codigo': processo.returncode, 'ok': ok, 'erros_de_script': erros, 'falhas': [x for x in texto.splitlines() if x.startswith('FAIL T25:')]}
    (pasta/'controles.json').write_text(json.dumps(resultados, ensure_ascii=False, indent=2), encoding='utf-8')
    print(nome, resultados[nome]['codigo'], 'OK' if ok else 'FALHOU', flush=True)
    if not ok:
        raise RuntimeError(texto[-4500:])

ancora = '\tartigos = Conteudo.artigos(get_tree().root.get_node("GameState"))\n'
casos = [
    ('voltar-fecha-artigo', painel, '\tif assunto_atual != "":\n\t\t_mostrar("")\n\telse:\n\t\tsuper._fechar()', '\tsuper._fechar()'),
    ('consulta-sorteia', painel, ancora, ancora + '\tget_tree().root.get_node("GameState")._rng.randf()\n'),
    ('consulta-grava', painel, ancora, ancora + '\tGameState.save_game()\n'),
    ('multa-divergente', conteudo, 'float(gs.CANCELAMENTO_MULTA) * 100.0', 'float(gs.CANCELAMENTO_MULTA) * 200.0'),
    ('ajuda-duplicada', main, 'if filho.scene_file_path == ComoJogarScene.resource_path and not filho.is_queued_for_deletion():', 'if false:'),
    ('toque-atravessado', painel, '\tmontar(LARGURA, ALTURA)\n', '\tmontar(LARGURA, ALTURA)\n\tmouse_filter = Control.MOUSE_FILTER_IGNORE\n\tget_child(0).mouse_filter = Control.MOUSE_FILTER_IGNORE\n'),
]
try:
    rodar('controle-base', True)
    for nome, caminho, de, para in casos:
        texto = originais[caminho].decode('utf-8')
        assert texto.count(de) == 1, nome
        escrever(caminho, texto.replace(de, para).encode('utf-8'))
        try:
            rodar('mutante-' + nome, False)
        finally:
            escrever(caminho, originais[caminho])
        assert all(p.read_bytes() == dados for p, dados in originais.items())
        rodar('restaurado-' + nome, True)
finally:
    for p, dados in originais.items():
        if p.read_bytes() != dados:
            escrever(p, dados)
    (pasta/'fontes-restauradas.json').write_text(json.dumps({str(p.relative_to(raiz)): hashlib.sha256(p.read_bytes()).hexdigest() for p in originais}, indent=2), encoding='utf-8')
