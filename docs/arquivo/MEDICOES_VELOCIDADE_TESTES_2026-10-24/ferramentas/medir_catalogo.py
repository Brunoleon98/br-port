#!/usr/bin/env python3
"""Medição (não é ferramenta do projeto): corre o executor de mutantes de UMA
cópia do repositório, sem o alterar, trocando só o `rodar_suite` por uma versão
que carimba cada linha e anota quando a guarda declarada reprovou.

Uso: medir_catalogo.py COPIA SAIDA [--fixed-fps N] --so ID...
"""
import importlib.util, json, os, subprocess, sys, time, threading
copia = sys.argv[1]; saida = sys.argv[2]; resto = sys.argv[3:]
ffps = None
if resto[:1] == ["--fixed-fps"]:
    ffps = resto[1]; resto = resto[2:]
spec = importlib.util.spec_from_file_location(
    "cm", os.path.join(copia, "tools", "conferir_mutantes.py"))
cm = importlib.util.module_from_spec(spec); spec.loader.exec_module(cm)
assert str(cm.RAIZ) == os.path.realpath(copia), (cm.RAIZ, copia)

catalogo = {m["id"]: m for m in cm.carregar_catalogo(cm.CATALOGO)}
tempos = []
atual = {"id": None}
original_trocar = cm.trocar
def trocar(alvo, conteudo, modo):
    # Descobre qual mutante está aplicado pelo conteúdo trocado.
    original_trocar(alvo, conteudo, modo)
cm.trocar = trocar

def rodar_suite(godot, suite, log, teto, perfil):
    script, marcador = cm.SUITES[suite]
    amb = dict(os.environ, XDG_DATA_HOME=str(perfil), APPDATA=str(perfil))
    cmd = [godot, "--headless"] + (["--fixed-fps", ffps] if ffps else []) + \
          ["--path", str(cm.PROJETO), "--script", script]
    t0 = time.monotonic()
    p = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, env=amb)
    linhas = []
    def ler():
        for l in p.stdout:
            linhas.append((time.monotonic() - t0, l.decode("utf-8", "replace")))
    th = threading.Thread(target=ler); th.start()
    try:
        p.wait(timeout=teto); esgotou = False
    except subprocess.TimeoutExpired:
        p.kill(); p.wait(); esgotou = True
    th.join()
    seg = time.monotonic() - t0
    texto = "".join(l for _, l in linhas)
    log.write_text("".join("%8.3f %s" % (t, l) for t, l in linhas), encoding="utf-8")
    nome = log.name[:-4]
    mid = nome[:-(len(suite) + 1)] if nome.endswith("-" + suite) else nome
    guarda = catalogo[mid]["reprova"].get(suite) if mid in catalogo else None
    t_guarda = t_falha = None
    for t, l in linhas:
        mm = cm.LINHA_REPROVADA.match(l.rstrip("\n"))
        if mm:
            if t_falha is None: t_falha = t
            if guarda and guarda in mm.group(1) and t_guarda is None: t_guarda = t
    tempos.append({"log": nome, "suite": suite, "segundos": seg,
                   "t_guarda": t_guarda, "t_primeira_falha": t_falha})
    return {"segundos": seg, "esgotou": esgotou, "passou": marcador in texto,
            "compilou": not cm.ERRO_DE_COMPILACAO.search(texto),
            "erro": bool(cm.ERRO_DE_BASE.search(texto)),
            "reprovadas": cm.LINHA_REPROVADA.findall(texto)}
cm.rodar_suite = rodar_suite

orig_reimp = cm.reimportar_se_arte
def reimp(godot, alvo, perfil):
    t0 = time.monotonic(); orig_reimp(godot, alvo, perfil)
    d = time.monotonic() - t0
    if d > 0.5: tempos.append({"log": "reimport-" + alvo.name, "suite": "--import", "segundos": d})
cm.reimportar_se_arte = reimp

sys.argv = ["conferir_mutantes.py", "--godot", os.environ["G"], "--saida", saida] + resto
t0 = time.monotonic()
try:
    rc = cm.main()
finally:
    os.makedirs(saida, exist_ok=True)
    with open(os.path.join(saida, "tempos.json"), "w") as f:
        json.dump({"rc_parcial": None, "parede": time.monotonic() - t0, "corridas": tempos}, f, indent=1)
print("rc", rc, "parede %.0f s" % (time.monotonic() - t0))
sys.exit(rc)
