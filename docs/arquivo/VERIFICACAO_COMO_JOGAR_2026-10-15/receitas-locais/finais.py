from pathlib import Path
import json
import os
import re
import subprocess
import sys

raiz = Path.cwd()
pasta = raiz / '.evidencias/implementar-como-jogar'
perfil = pasta / 'perfil-final'
perfil.mkdir(exist_ok=True)
ambiente = dict(os.environ, APPDATA=str(perfil), LOCALAPPDATA=str(perfil), PYTHONUTF8='1')
godot = r'C:\Users\bruno\Downloads\Godot_v4.6.3-stable_win64.exe\Godot_v4.6.3-stable_win64_console.exe'
esperados = {
    'tests/run_tests.gd': 'TODOS OS TESTES PASSARAM',
    'tests/teste_design.gd': 'DESIGN OK',
    'tests/teste_audio.gd': 'AUDIO OK',
    'tests/teste_fumaca.gd': 'FUMACA OK',
    'tests/teste_registro.gd': 'REGISTRO OK',
    'scripts/validation/asset_validator.gd': 'ASSET OK',
}
workflow = (raiz / '.github/workflows/testes.yml').read_text(encoding='utf-8')
assert set(re.findall(r'res://((?:tests|scripts/validation)/[a-z_]+\.gd)', workflow)) == set(esperados)
assert subprocess.check_output([godot, '--version'], text=True).strip().startswith((raiz/'.godot-version').read_text().strip())
resultados = json.loads((pasta/'finais.json').read_text()) if '--retomar' in sys.argv else {}

def rodar(nome, comando, marcador):
    log = pasta / (nome + '.log')
    if resultados.get(nome, {}).get('ok'):
        print(nome, 'já verificado', flush=True)
        return
    with log.open('w', encoding='utf-8') as saida:
        processo = subprocess.run(comando, stdout=saida, stderr=subprocess.STDOUT, env=ambiente, timeout=900)
    texto = log.read_text(encoding='utf-8')
    erros = [x for x in ('SCRIPT ERROR', 'at: push_error (') if x in texto]
    ok = processo.returncode == 0 and marcador in texto and not erros
    resultados[nome] = dict(codigo=processo.returncode, marcador=marcador in texto, erros=erros, ok=ok)
    (pasta/'finais.json').write_text(json.dumps(resultados, indent=2), encoding='utf-8')
    print(nome, resultados[nome], flush=True)
    if not ok:
        print(texto[-7000:])
        sys.exit(1)

rodar('sentinela-plantar', [sys.executable, 'tools/sentinela_do_jogador.py', 'plantar', 'brport_vs'], 'Sentinela plantada')
rodar('import-final', [godot, '--headless', '--editor', '--path', 'brport_vs', '--import'], '[ DONE ]')
rodar('contraste-final', [godot, '--headless', '--path', 'brport_vs', '--script', 'res://tools/medir_contraste_ui.gd', '--', '--so-falhas'], 'CONTRASTE MEDIDO')
contraste = (pasta/'contraste-final.log').read_text(encoding='utf-8')
assert '0 reprovam o AA, 0 pendentes' in contraste, contraste
rodar('t25-final', [godot, '--headless', '--path', 'brport_vs', '--script', str(pasta/'t25.gd')], 'T25 OK')
for script, marcador in esperados.items():
    rodar('final-' + Path(script).stem, [godot, '--headless', '--path', 'brport_vs', '--script', 'res://' + script], marcador)
for nome, marcador in [('conferir_escopo_ui','ESCOPO UI OK'), ('conferir_guardas_ci','GUARDAS OK'), ('conferir_docs','DOCS OK')]:
    rodar(nome, [sys.executable, 'tools/' + nome + '.py'], marcador)
rodar('sentinela-final', [sys.executable, 'tools/sentinela_do_jogador.py', 'conferir', 'brport_vs'], 'SENTINELA INTACTA')
