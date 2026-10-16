from pathlib import Path
import os
import subprocess
import sys

raiz = Path.cwd()
pasta = raiz / '.evidencias/implementar-como-jogar/wrappers'
pasta.mkdir(exist_ok=True)
args = sys.argv[1:]
for nome in ['capturar_tela', 'capturar_cena', 'folha_icones', 'folha_frota', 'folha_props', 'folha_trabalhadores', 'escala_props', 'prancha_prop']:
    original = f'res://tools/{nome}.gd'
    if original not in args:
        continue
    largura, altura = map(int, os.environ.get('BRPORT_CAPTURA_TAMANHO', '720x1280').split('x'))
    rolar = os.environ.get('BRPORT_CAPTURA_FIM') == '1'
    pronto = '_frames >= FRAMES_ATE_ASSENTAR + _frames_extra - 1' if nome == 'capturar_tela' else '_frames >= FRAMES_ATE_ASSENTAR - 1'
    passo_rolagem = f'''    if not rolou_extra_115 and {pronto} and _toques.is_empty():
        var leitura: ScrollContainer = root.find_child("Leitura", true, false)
        if leitura != null:
            rolou_extra_115 = true
            leitura.scroll_vertical = 100000
            print("Rolagem da ajuda: %d / %.0f" % [leitura.scroll_vertical, leitura.get_v_scroll_bar().max_value - leitura.get_v_scroll_bar().page])
            _frames = 0
            return false
''' if rolar and nome in ('capturar_tela', 'capturar_cena') else ''
    roteiro = pasta / (nome + '.gd')
    roteiro.write_text(f'''extends "{original}"
var preparou := 0
var rolou_extra_115 := false
func _process(delta: float) -> bool:
    if preparou < 3:
        if preparou == 0:
            root.size = Vector2i({largura}, {altura})
            root.position = Vector2i.ZERO
        preparou += 1
        return false
{passo_rolagem}    return super._process(delta)
''', encoding='utf-8', newline='\n')
    args[args.index(original)] = str(roteiro.resolve())
resultado = subprocess.run([r'C:\Users\bruno\Downloads\Godot_v4.6.3-stable_win64.exe\Godot_v4.6.3-stable_win64_console.exe', *args])
sys.exit(resultado.returncode)
