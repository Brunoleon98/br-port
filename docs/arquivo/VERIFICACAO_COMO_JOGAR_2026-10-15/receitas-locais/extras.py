from pathlib import Path
import json
import os
import struct
import subprocess
import sys

raiz = Path.cwd()
pasta = raiz/'.evidencias/implementar-como-jogar'
saida = pasta/'extras'
saida.mkdir(exist_ok=True)
ambiente = dict(os.environ, APPDATA=str(pasta/'perfil-final'), LOCALAPPDATA=str(pasta/'perfil-final'), PYTHONUTF8='1')
casos = [
    ('inicio-artigo-9x20', '720x1600', False, False, 'Devolver ou cancelar', 'artigo'),
    ('pausa-glossario-fim-9x20', '720x1600', True, True, 'Glossário', 'glossario'),
    ('inicio-indice-10x16', '720x1152', False, False, '', 'indice'),
    ('inicio-glossario-fim-10x16', '720x1152', True, False, 'Glossário', 'glossario'),
]
resultados = {}
for nome, tamanho, fim, pausa, artigo, tempo in casos:
    env = dict(ambiente, BRPORT_CAPTURA_TAMANHO=tamanho, BRPORT_CAPTURA_FIM='1' if fim else '0')
    imagem = saida/(nome+'.png')
    script = 'capturar_tela' if pausa else 'capturar_cena'
    args = ['8', str(imagem), 'completo', 'pausa', 'limpo'] if pausa else ['res://scenes/TelaInicial.tscn', str(imagem)]
    args += ['--tocar=Como jogar']
    if artigo:
        args += ['--tocar='+artigo]
    args += ['--tempo='+tempo]
    comando = [r'C:\Users\bruno\Downloads\Godot_v4.6.3-stable_win64.exe\Godot_v4.6.3-stable_win64_console.exe', '--path', 'brport_vs', '--resolution', '720x1280', '--rendering-driver', 'opengl3', '--audio-driver', 'Dummy', '--fixed-fps', '60', '--script', str(pasta/'quadros.gd'), '--', str(imagem), tamanho, '1' if fim else '0', '1' if pausa else '0', artigo]
    with (saida/(nome+'.log')).open('w', encoding='utf-8') as log:
        processo = subprocess.run(comando, env=env, stdout=log, stderr=subprocess.STDOUT, timeout=180)
    texto = (saida/(nome+'.log')).read_text(encoding='utf-8')
    assert processo.returncode == 0 and 'Tela salva em' in texto, texto
    assert not any(x in texto for x in ('SCRIPT ERROR', 'GDScript backtrace')), texto
    dimensoes = struct.unpack('>II', imagem.read_bytes()[16:24])
    assert dimensoes == tuple(map(int, tamanho.split('x'))), (nome, dimensoes)
    assert not fim or 'Rolagem da ajuda:' in texto, texto
    resultados[nome] = {'ok': True, 'tamanho': dimensoes, 'fim': fim, 'pausa': pausa}
    (pasta/'extras.json').write_text(json.dumps(resultados, indent=2), encoding='utf-8')
    print(nome, dimensoes, 'OK', flush=True)
