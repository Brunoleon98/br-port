#!/usr/bin/env python3
"""Reinjeta, a cada corrida, os defeitos que já provaram uma guarda.

O ITEM 7 DO FECHO PEDE UM DEFEITO INJETADO POR GUARDA NOVA, e o projeto
cumpre-o: em 15/10 eram 166 menções em 64 das 109 decisões. Só que cada um
corria UMA vez, à mão (`cp`, editar, rodar, restaurar), e ficava escrito em
prosa — «o `retirar` esquecido (M2)». Nada voltava a perguntar se a guarda
ainda o apanhava, e as regras contam as maneiras de ela deixar de apanhar sem
ninguém ver: a sonda presa a um funil que deixou de ser único, a regra que
passou a existir em dois sítios, o bloco que um refactor esvaziou. Cada uma foi
descoberta por acaso, sessões depois (`docs/decisoes/117`).

Este é o lugar onde o defeito fica. `tools/mutantes.toml` guarda cada um como
uma troca EXATA de texto num arquivo do jogo, com a suíte e a guarda que o têm
de reprovar; esta ferramenta aplica-os um de cada vez e exige, de cada um:

  1. que o texto a trocar exista UMA vez no alvo — senão o código mudou e o
     defeito deixou de existir com ele (mutante ÓRFÃO). Reprova, e quem mexeu
     no código reescreve o defeito contra a forma nova: a lição viaja com o
     refactor em vez de morrer nele;
  2. que a suíte NÃO imprima o marcador de sucesso (o defeito SOBREVIVEU);
  3. que o mutante compile — um erro de compilação derruba a suíte inteira e
     reprova tudo, que é verde de graça com cara de vermelho
     (`testes-e-guardas.md`, «renomear só a declaração parte o script»);
  4. que acabe dentro do teto — a quarta forma de falhar é não acabar;
  5. que entre as linhas reprovadas esteja a GUARDA declarada, e não uma
     vizinha («confira que quem reprovou foi a guarda que se estava a testar»).

E entre um defeito e o seguinte, o arquivo volta ao original BYTE A BYTE, da
cópia em memória e nunca do `git`, que não sabe o que ainda não foi commitado.
A base corre antes (tem de passar, senão não há o que medir) e no fim.

⚠️ O `user://` DESTAS CORRIDAS NÃO É O DO JOGADOR, NEM O DAS FERRAMENTAS. Um
mutante no `ArmazemLocal.gd` mandaria as suítes gravar no save real — foi o
incidente de 25/09 (`061`). Todo Godot que esta ferramenta abre tem o
`XDG_DATA_HOME` e o `APPDATA` apontados para a pasta de saída, como a bancada
do cancelamento já fazia (`testar_bancada_cancelamento.py`).

Uso:
  python3 tools/conferir_mutantes.py --godot "$G"            # o catálogo todo
  python3 tools/conferir_mutantes.py --godot "$G" --so ID    # um ou mais
  python3 tools/conferir_mutantes.py --godot "$G" --explorar --so ID
      # roda o defeito contra AS SEIS suítes e diz quem reprovou — é assim que
      # se escreve o `reprova` de um mutante novo, medido e não suposto
  python3 tools/conferir_mutantes.py --listar
  python3 tools/conferir_mutantes.py --godot "$G" --trabalhadores 4
      # o catálogo em quatro CÓPIAS do repositório ao mesmo tempo
  python3 tools/conferir_mutantes.py --godot "$G" --fatia 2/3 --trabalhadores 4
      # só a segunda de três fatias — é o que cada job da matriz do CI corre
  python3 tools/conferir_mutantes.py --juntar DIR1 DIR2 DIR3
      # confere que as fatias somam o catálogo inteiro, sem falta nem repetição

Espera `MUTANTES OK`, no início da linha. Em série, não corra em paralelo com
outra suíte: o defeito vive no arquivo do projeto enquanto a suíte dele corre.

⚠️ EM PARALELO, CADA TRABALHADOR É ESTE MESMO EXECUTOR, NUMA CÓPIA. Medido em
24/10 (`docs/decisoes/137`): o catálogo de 158 levou 120 min de Godot somados
e 30,8 min de parede em quatro cópias — 98% dos quatro núcleos —, com os 158
reprovados pela guarda declarada. O pai copia a árvore (sem o `.git`), exige
cada cópia igual à original byte a byte, reparte os mutantes em roda por
suíte e corre em cada cópia o executor DELA, sem `--trabalhadores`: a lógica
que julga um mutante é a de sempre, e o original nunca é tocado. Cada
trabalhador tem o seu `user://` (`<saída>/tN/perfil`), como a série já tinha.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import shutil
import signal
import subprocess
import sys
import threading
import time
import tomllib
from pathlib import Path

RAIZ = Path(__file__).resolve().parents[1]
PROJETO = RAIZ / "brport_vs"
CATALOGO = RAIZ / "tools" / "mutantes.toml"
WORKFLOW = RAIZ / ".github" / "workflows" / "testes.yml"

# As seis suítes e o marcador de cada uma. Conferido contra o `testes.yml` em
# `suites_batem_com_o_ci()`: a lista viva é a do workflow (`032`), e esta só
# pode repeti-la.
SUITES = {
    "run_tests": ("res://tests/run_tests.gd", "TODOS OS TESTES PASSARAM"),
    "teste_design": ("res://tests/teste_design.gd", "DESIGN OK"),
    "teste_audio": ("res://tests/teste_audio.gd", "AUDIO OK"),
    "teste_fumaca": ("res://tests/teste_fumaca.gd", "FUMACA OK"),
    "teste_registro": ("res://tests/teste_registro.gd", "REGISTRO OK"),
    "asset_validator": ("res://scripts/validation/asset_validator.gd", "ASSET OK"),
}

# ⚠️ O RELÓGIO DAS SUÍTES É O DO CI, e confere-se contra ele. Com o passo
# fixo, cada frame vale 1/60 s de jogo e o motor não dorme entre frames: as
# seis suítes passaram de 118,1 s para 96,6 s, e os 158 mutantes do catálogo
# reprovaram pela MESMA guarda declarada (`137`). Sem ele, em `--headless` o
# laço dorme até 6,9 ms por frame e o delta é o do relógio de parede — e o
# zero do sono sozinho já reprovou o F10, que conta frames. Um mutante provado
# com um relógio e uma suíte corrida com outro seriam duas perguntas.
MOTOR = ["--headless", "--fixed-fps", "60"]

# As formas de uma asserção reprovada, uma por família de suíte:
# `  FAIL  rótulo` (run_tests), `  FALHA rótulo` (design, fumaça, registro,
# áudio), `  FALHOU  rótulo` (assets) — e `FAIL T24: rótulo`, SEM recuo, que é
# a forma do bloco do cancelamento que o Codex escreveu num arquivo à parte
# (`tests/casos_cancelamento.gd`). Com `^\s+` as falhas dele não tinham nome
# para esta ferramenta: só a linha agregada do `run_tests` as via (`119`).
# O espaço DEPOIS da palavra continua obrigatório: `FALHA: x nao existe`
# (o cabeçalho de uma suíte que não arrancou) não é asserção.
LINHA_REPROVADA = re.compile(r"^\s*(?:FAIL|FALHA|FALHOU)\s+(.+?)\s*$", re.M)

# O erro de COMPILAÇÃO, que não é o de execução: este traz `SCRIPT ERROR` sem
# backtrace e com a origem no `GDScript::reload` (medido em 21/09,
# `testes-e-guardas.md`). Um erro de EXECUÇÃO dentro de um bloco é outra
# coisa — é uma reprovação legítima no CI pelo passo que varre `SCRIPT ERROR`,
# mas não nomeia guarda nenhuma, e por isso o item 5 acima não o aceita.
ERRO_DE_COMPILACAO = re.compile(
    r"Parse Error|Compile Error|GDScript::reload|Failed to load script")

ERRO_DE_BASE = re.compile(r"SCRIPT ERROR|at: push_error \(")


class Interrompido(Exception):
    pass


def _ao_sinal(_sig, _frame):
    raise Interrompido()


def carregar_catalogo(caminho: Path) -> list[dict]:
    """Lê e valida o catálogo inteiro ANTES de tocar em qualquer arquivo."""
    dados = tomllib.loads(caminho.read_text(encoding="utf-8"))
    mutantes = dados.get("mutante", [])
    if not mutantes:
        # Amostra vazia é reprovação: um catálogo que o parser deixou de ler
        # imprimiria `MUTANTES OK` sem ter injetado nada.
        raise SystemExit(f"{caminho}: nenhum [[mutante]] lido — nada a provar.")
    vistos: set[str] = set()
    for m in mutantes:
        falta = [k for k in ("id", "de", "o_que", "alvo", "antes", "depois")
                 if k not in m]
        if falta:
            raise SystemExit(f"mutante {m.get('id', '?')}: faltam {falta}.")
        if m["id"] in vistos:
            raise SystemExit(f"mutante {m['id']}: id repetido.")
        vistos.add(m["id"])
        if m["antes"] == m["depois"]:
            raise SystemExit(f"mutante {m['id']}: `antes` igual a `depois` não "
                             "injeta defeito nenhum.")
        reprova = m.get("reprova", {})
        if not isinstance(reprova, dict):
            raise SystemExit(f"mutante {m['id']}: `reprova` é uma tabela "
                             "suíte = \"guarda\".")
        for suite, guarda in reprova.items():
            if suite not in SUITES:
                raise SystemExit(f"mutante {m['id']}: suíte desconhecida {suite!r}.")
            if not isinstance(guarda, str) or not guarda.strip():
                raise SystemExit(f"mutante {m['id']}: a guarda de {suite} tem de "
                                 "ser um trecho do rótulo que reprova.")
    return mutantes


def suites_batem_com_o_ci() -> list[str]:
    texto = WORKFLOW.read_text(encoding="utf-8")
    # As continuações `\` partem a chamada em linhas (o `asset_validator` está
    # assim): junta-se antes de procurar, senão a busca não casa nada e diz
    # «falta» de um passo que existe (`gerais.md`, receita derivada).
    corrido = re.sub(r"\s+", " ", re.sub(r"\\\n", " ", texto))
    queixas = []
    for nome, (script, marcador) in SUITES.items():
        if script not in texto:
            queixas.append(f"{nome}: {script} não está no testes.yml.")
        if f'grep -q "{marcador}"' not in texto:
            queixas.append(f"{nome}: o testes.yml não exige «{marcador}».")
        chamada = " ".join(MOTOR + ["--path", "brport_vs", "--script", script])
        if chamada not in corrido:
            queixas.append(f"{nome}: o testes.yml não corre «{chamada}» — a suíte do "
                           "CI e a do executor têm de ter o mesmo relógio.")
    return queixas


def ocorrencias(m: dict) -> int:
    return (RAIZ / m["alvo"]).read_bytes().count(m["antes"].encode("utf-8"))


def orfaos(mutantes: list[dict]) -> list[str]:
    queixas = []
    for m in mutantes:
        alvo = RAIZ / m["alvo"]
        if not alvo.is_file():
            queixas.append(f"{m['id']}: o alvo {m['alvo']} não existe.")
            continue
        n = ocorrencias(m)
        if m.get("todas", False):
            if n == 0:
                queixas.append(f"{m['id']}: «{m['antes'].strip()}» não aparece em "
                               f"{m['alvo']} — o nome mudou; reescreva o defeito.")
        elif n != 1:
            queixas.append(
                f"{m['id']}: o trecho a trocar aparece {n} vez(es) em {m['alvo']}, "
                "e tem de aparecer UMA. " + (
                    "O código mudou e o defeito deixou de existir com ele: "
                    "reescreva-o contra a forma nova, rode --explorar e confira "
                    "que a guarda ainda reprova." if n == 0 else
                    "Alargue o trecho até ele ser único."))
    return queixas


def trocar(alvo: Path, conteudo: bytes, modo: int) -> None:
    # Temporário + `os.replace`, e o modo copiado: `open(..., "w")` trunca
    # antes de o conteúdo existir, e o `os.replace` sozinho perde o modo
    # (`gerais.md`, as duas regras do `os.replace`).
    tmp = alvo.with_name(alvo.name + ".mutante-tmp")
    tmp.write_bytes(conteudo)
    os.chmod(tmp, modo)
    os.replace(tmp, alvo)


def reimportar_se_arte(godot: str, alvo: Path, perfil: Path) -> None:
    """Reimporta o projeto quando o alvo é arte que o Godot importa.

    ⚠️ AS SUÍTES LEEM A TEXTURA PELO CACHE DO IMPORTADOR, de propósito — o
    `_mapa_lido` do `teste_design` explica porquê —, e um defeito trocado só
    no SVG nunca lá chegaria: o primeiro mutante de mapa (`123`) SOBREVIVEU
    assim, com a guarda certa e a suíte a ler a textura de antes do defeito.
    É o «confira que o defeito chegou a quem o havia de ver» (`gerais.md`).
    O `.import` ao lado do alvo é o que diz que ele passa pelo importador.
    """
    if not alvo.with_name(alvo.name + ".import").exists():
        return
    ambiente = dict(os.environ, XDG_DATA_HOME=str(perfil), APPDATA=str(perfil))
    r = subprocess.run([godot, "--headless", "--path", str(PROJETO), "--import"],
                       stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                       env=ambiente, timeout=600)
    if r.returncode != 0:
        raise RuntimeError(f"o --import depois de trocar {alvo.name} saiu com "
                           f"{r.returncode}")


def rodar_suite(godot: str, suite: str, log: Path, teto: float, perfil: Path) -> dict:
    script, marcador = SUITES[suite]
    ambiente = dict(os.environ, XDG_DATA_HOME=str(perfil), APPDATA=str(perfil))
    inicio = time.monotonic()
    try:
        r = subprocess.run(
            [godot, *MOTOR, "--path", str(PROJETO), "--script", script],
            stdout=subprocess.PIPE, stderr=subprocess.STDOUT, env=ambiente,
            timeout=teto)
        saida = r.stdout.decode("utf-8", "replace")
        esgotou = False
    except subprocess.TimeoutExpired as e:
        saida = (e.stdout or b"").decode("utf-8", "replace")
        esgotou = True
    log.write_text(saida, encoding="utf-8")
    return {
        "segundos": time.monotonic() - inicio,
        "esgotou": esgotou,
        "passou": marcador in saida,
        "compilou": not ERRO_DE_COMPILACAO.search(saida),
        "erro": bool(ERRO_DE_BASE.search(saida)),
        "reprovadas": LINHA_REPROVADA.findall(saida),
    }


def julgar(r: dict, guarda: str | None, teto: float) -> tuple[bool, str]:
    """(aprovado, frase). `guarda` None é o modo --explorar: só descreve."""
    # A COMPILAÇÃO ANTES DO TETO: um autoload que não compila deixa a suíte
    # pendurada (medido no autoteste, `117`), e o diagnóstico tem de dizer a
    # causa, não o sintoma. A saída parcial da corrida cortada já a traz.
    if not r["compilou"]:
        return False, ("o mutante não compila: a suíte caiu inteira, e isso não "
                       "prova guarda nenhuma — mude o comportamento, não a sintaxe")
    if r["esgotou"]:
        return False, (f"não acabou em {teto:.0f} s — a guarda tem de reprovar com "
                       "nome, e um laço sem teto no CI é um job a morrer de timeout")
    if r["passou"]:
        return False, "SOBREVIVEU — a suíte passou com o defeito posto"
    reprovadas = r["reprovadas"]
    if not reprovadas:
        return False, ("a suíte não chegou ao marcador e não nomeou asserção "
                       "nenhuma" + (" (imprimiu SCRIPT ERROR)" if r["erro"] else ""))
    if guarda is None:
        return True, f"{len(reprovadas)} reprovada(s)"
    if any(guarda in rotulo for rotulo in reprovadas):
        outras = len(reprovadas) - 1
        return True, f"«{guarda}»" + (f" (+{outras})" if outras else "")
    return False, ("reprovou, mas não pela guarda declarada «%s». Reprovaram: %s"
                   % (guarda, " | ".join(reprovadas[:6])))


def repartir(mutantes: list[dict], n: int) -> list[list[dict]]:
    """N partes, em roda, com a lista ordenada por suíte e por id.

    Sem tempo medido nem peso escrito à mão: cada parte leva o mesmo número
    de corridas de cada suíte (±1), e é isso que as iguala — um mutante custa
    a suíte que o reprova (medido em 24/10: 34 s cada no CI, o tempo dela).
    E é DETERMINÍSTICO: as fatias da matriz do CI calculam-se cada uma no seu
    job, e o `--juntar` volta a calculá-las para conferir que cada job correu
    a sua, e não outra.
    """
    ordem = sorted(mutantes, key=lambda m: (sorted(m.get("reprova", {})), m["id"]))
    partes: list[list[dict]] = [[] for _ in range(n)]
    for i, m in enumerate(ordem):
        partes[i % n].append(m)
    return partes


def ler_fatia(texto: str) -> tuple[int, int]:
    m = re.fullmatch(r"(\d+)/(\d+)", texto)
    if not m or not 1 <= int(m.group(1)) <= int(m.group(2)):
        raise SystemExit(f"--fatia {texto!r}: escreva I/K, com 1 ≤ I ≤ K.")
    return int(m.group(1)), int(m.group(2))


def _fora_da_copia(raiz: Path, saida: Path):
    # O `.git` não é preciso (o executor lê arquivos, não o histórico), e a
    # pasta de saída, se morar dentro da árvore, copiar-se-ia a si mesma.
    def ignorar(pasta, nomes):
        fora = {"__pycache__"}
        if Path(pasta) == raiz:
            fora.add(".git")
        return [n for n in nomes if n in fora or Path(pasta, n) == saida]
    return ignorar


def digerir(raiz: Path, ignorar) -> dict[str, str]:
    """O sha256 de cada arquivo da árvore, pelo caminho relativo."""
    out = {}
    for pasta, subpastas, nomes in os.walk(raiz):
        tirar = set(ignorar(pasta, subpastas + nomes))
        subpastas[:] = [s for s in subpastas if s not in tirar]
        for n in nomes:
            if n in tirar:
                continue
            p = Path(pasta, n)
            if p.is_symlink():
                out[str(p.relative_to(raiz))] = "->" + os.readlink(p)
            elif p.is_file():
                out[str(p.relative_to(raiz))] = hashlib.sha256(p.read_bytes()).hexdigest()
    return out


# A linha que faria um trabalhador verde passar por TODOS verdes. O CI pede
# o marcador no início da linha, e as linhas repassadas começam por «[tN]»;
# mesmo assim ele não é repassado, que um `grep` sem âncora num passo novo
# casaria com ele (`gerais.md`, «um marcador novo pode conter um velho»).
MARCADOR = "MUTANTES OK"


def em_paralelo(args, mutantes: list[dict]) -> int:
    saida = args.saida.resolve()
    partes = [p for p in repartir(mutantes, args.trabalhadores) if p]
    copias = saida / "copias"
    shutil.rmtree(copias, ignore_errors=True)
    ignorar = _fora_da_copia(RAIZ, saida)
    original = digerir(RAIZ, ignorar)
    print(f"Em paralelo: {len(mutantes)} mutante(s) em {len(partes)} cópia(s) "
          f"de {len(original)} arquivo(s).")
    trabalhos = []
    for k, parte in enumerate(partes, 1):
        destino = copias / f"t{k}"
        shutil.copytree(RAIZ, destino, symlinks=True, ignore=ignorar)
        # ⚠️ A CÓPIA TEM DE SER A ÁRVORE QUE SE QUER PROVAR, byte a byte —
        # inclusive o que ainda não foi commitado, que é o que um agente
        # corre antes do commit. Uma cópia velha provaria outra coisa, verde.
        diferentes = sorted(set(original.items()) ^ set(digerir(destino, ignorar).items()))
        if diferentes:
            print(f"::error::a cópia t{k} não é igual à árvore: {diferentes[:3]}")
            return 1
        cmd = [sys.executable, str(destino / "tools" / "conferir_mutantes.py"),
               "--godot", args.godot, "--catalogo", str(args.catalogo.resolve()),
               "--saida", str(saida / f"t{k}"), "--so", *[m["id"] for m in parte]]
        trabalhos.append((k, parte, subprocess.Popen(
            cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)))

    saidas: dict[int, list[str]] = {k: [] for k, _, _ in trabalhos}

    def repassar(k, proc):
        for bruta in proc.stdout:
            linha = bruta.decode("utf-8", "replace").rstrip("\n")
            saidas[k].append(linha)
            if linha.startswith(MARCADOR):
                linha = linha.replace(MARCADOR, "trabalhador verde", 1)
            if linha.startswith("::error::"):
                # A anotação do GitHub só se lê no início da linha.
                print(f"::error::[t{k}] {linha[len('::error::'):]}")
            else:
                print(f"[t{k}] {linha}")

    leitores = [threading.Thread(target=repassar, args=(k, p)) for k, _, p in trabalhos]
    for t in leitores:
        t.start()
    try:
        for _, _, p in trabalhos:
            p.wait()
    except Interrompido:
        # Cada trabalhador restaura a SUA cópia ao receber o sinal; o
        # original nunca foi tocado.
        print("\ninterrompido — a parar os trabalhadores.")
        for _, _, p in trabalhos:
            p.terminate()
        for _, _, p in trabalhos:
            p.wait()
        return 130
    for t in leitores:
        t.join()

    # O PAI SÓ DÁ VERDE COM AS TRÊS PROVAS DE CADA TRABALHADOR: o código de
    # saída, o marcador DELE com a contagem certa, e o relatório com
    # exactamente os mutantes que lhe couberam, cada um aprovado. Um
    # trabalhador que morresse calado, ou que corresse menos do que recebeu,
    # falharia uma delas.
    falhas = []
    resultado: dict[str, dict] = {}
    for k, parte, p in trabalhos:
        ids = {m["id"] for m in parte}
        esperado = f"{MARCADOR} — {len(parte)} defeito(s)"
        if p.returncode != 0:
            falhas.append(f"t{k} saiu com {p.returncode}")
            continue
        if not any(l.startswith(esperado) for l in saidas[k]):
            falhas.append(f"t{k} não imprimiu «{esperado}»")
            continue
        try:
            rel = json.loads((saida / f"t{k}" / "relatorio.json").read_text(encoding="utf-8"))
        except (OSError, ValueError) as e:
            falhas.append(f"t{k} sem relatório legível ({e})")
            continue
        if set(rel) != ids:
            falhas.append(f"t{k}: o relatório traz {len(rel)} mutante(s), "
                          f"e couberam-lhe {len(ids)}")
            continue
        if not all(r["aprovado"] for v in rel.values() for r in v.values()):
            falhas.append(f"t{k}: há mutante não aprovado no relatório")
            continue
        resultado.update(rel)
    if set(resultado) != {m["id"] for m in mutantes} and not falhas:
        falhas.append("a soma dos trabalhadores não é a seleção")
    if falhas:
        for f in falhas:
            print(f"::error::{f}")
        print(f"\n{len(falhas)} trabalhador(es) sem prova — veja a saída de cada um acima.")
        return 1
    (saida / "relatorio.json").write_text(
        json.dumps(resultado, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    # As cópias são do tamanho do repositório; os logs ficam em `tN/`.
    shutil.rmtree(copias, ignore_errors=True)
    return 0


def escrever_fatia(saida: Path, fatia: tuple[int, int], mutantes: list[dict]) -> None:
    (saida / "fatia.json").write_text(json.dumps(
        {"fatia": list(fatia), "ids": sorted(m["id"] for m in mutantes)},
        ensure_ascii=False, indent=1) + "\n", encoding="utf-8")


def juntar(pastas: list[Path], catalogo: list[dict]) -> int:
    """Confere que as fatias da matriz somam o catálogo, sem falta nem repetição.

    Cada job da matriz só responde pela SUA fatia; nenhum deles sabe se as
    outras correram. É a regra de quem dá o total (`gerais.md`): uma fatia que
    não chegasse a correr — job cancelado, matriz encolhida, artefato perdido
    — deixava os outros verdes e um terço do catálogo sem prova nenhuma.
    """
    vistas: dict[int, set] = {}
    total = None
    aprovados: dict[str, dict] = {}
    queixas = []
    for pasta in pastas:
        try:
            f = json.loads((pasta / "fatia.json").read_text(encoding="utf-8"))
            rel = json.loads((pasta / "relatorio.json").read_text(encoding="utf-8"))
        except (OSError, ValueError) as e:
            queixas.append(f"{pasta}: sem fatia.json/relatorio.json legíveis ({e}) — "
                           "a fatia não acabou verde")
            continue
        i, k = f["fatia"]
        if total is None:
            total = k
        if k != total:
            queixas.append(f"{pasta}: fatia {i}/{k}, e as outras dizem /{total}")
        if i in vistas:
            queixas.append(f"a fatia {i}/{k} aparece duas vezes")
        vistas[i] = set(f["ids"])
        if set(rel) != set(f["ids"]):
            queixas.append(f"fatia {i}/{k}: o relatório não traz os mesmos mutantes")
        for mid, v in rel.items():
            if not all(r["aprovado"] for r in v.values()):
                queixas.append(f"fatia {i}/{k}: {mid} não foi aprovado")
            aprovados[mid] = v
    if total is None:
        queixas.append("nenhuma fatia lida — nada a juntar")
    else:
        for i in range(1, total + 1):
            if i not in vistas:
                queixas.append(f"faltou a fatia {i}/{total}")
        # Cada job tem de ter corrido A SUA fatia: recalcula-se a partilha.
        esperadas = repartir(catalogo, total)
        for i, ids in vistas.items():
            if 1 <= i <= total and ids != {m["id"] for m in esperadas[i - 1]}:
                queixas.append(f"a fatia {i}/{total} não correu os mutantes que lhe cabem")
        faltam = {m["id"] for m in catalogo} - set(aprovados)
        if faltam:
            queixas.append(f"{len(faltam)} mutante(s) do catálogo sem prova: "
                           f"{sorted(faltam)[:5]}")
        for m in catalogo:
            if m["id"] in aprovados and set(aprovados[m["id"]]) != set(m["reprova"]):
                queixas.append(f"{m['id']}: o relatório não traz as suítes declaradas")
    if queixas:
        for q in queixas:
            print(f"::error::{q}")
        print(f"\n{len(queixas)} queixa(s) ao juntar as fatias.")
        return 1
    print(f"{MARCADOR} — {len(catalogo)} defeito(s) do catálogo em {total} fatia(s), "
          "cada um reprovado pela guarda declarada.")
    return 0


def main() -> int:
    # Linha a linha, e não em bloco: num cano para `tee` o Python guarda a
    # saída até ao fim, e um catálogo de minutos parecia parado.
    sys.stdout.reconfigure(line_buffering=True)
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--godot", help="o binário do Godot (o $G da sessão)")
    ap.add_argument("--catalogo", type=Path, default=CATALOGO)
    ap.add_argument("--saida", type=Path, default=Path("/tmp/mutantes"))
    ap.add_argument("--so", nargs="+", metavar="ID", help="só estes mutantes")
    ap.add_argument("--explorar", action="store_true",
                    help="roda cada mutante contra as seis suítes e descreve")
    ap.add_argument("--suites", nargs="+", choices=list(SUITES),
                    help="com --explorar, só estas suítes")
    ap.add_argument("--listar", action="store_true")
    ap.add_argument("--trabalhadores", type=int, default=1, metavar="N",
                    help="N cópias do repositório ao mesmo tempo (1 = em série)")
    ap.add_argument("--fatia", metavar="I/K",
                    help="só a I-ésima de K fatias do catálogo (a matriz do CI)")
    ap.add_argument("--juntar", nargs="+", type=Path, metavar="DIR",
                    help="confere que as pastas de saída das K fatias somam o catálogo")
    args = ap.parse_args()

    mutantes = carregar_catalogo(args.catalogo)
    if args.juntar:
        return juntar(args.juntar, mutantes)
    if args.listar:
        for m in mutantes:
            suites = ", ".join(f"{s}: «{g}»" for s, g in m.get("reprova", {}).items())
            print(f"  {m['id']:<34} {m['de']:<6} {suites}")
        print(f"\n{len(mutantes)} mutante(s) no catálogo.")
        return 0

    if args.so:
        desconhecidos = set(args.so) - {m["id"] for m in mutantes}
        if desconhecidos:
            raise SystemExit(f"não há no catálogo: {sorted(desconhecidos)}")
        mutantes = [m for m in mutantes if m["id"] in args.so]
    fatia = ler_fatia(args.fatia) if args.fatia else None
    if fatia:
        mutantes = repartir(mutantes, fatia[1])[fatia[0] - 1]
    if args.trabalhadores < 1:
        raise SystemExit("--trabalhadores é pelo menos 1.")
    if args.explorar and args.trabalhadores > 1:
        raise SystemExit("--explorar corre em série: ele é para escrever UM mutante.")

    queixas = suites_batem_com_o_ci()
    if not args.explorar:
        queixas += [f"{m['id']}: sem `reprova` — rode --explorar e escreva quem "
                    "o tem de reprovar." for m in mutantes if not m.get("reprova")]
    queixas += orfaos(mutantes)
    if queixas:
        for q in queixas:
            print(f"::error::{q}")
        print(f"\n{len(queixas)} queixa(s) antes de injetar — nada foi injetado.")
        return 1

    if not args.godot:
        raise SystemExit("falta --godot (o binário que o hook de arranque pôs em $G).")
    if not (PROJETO / ".godot").is_dir():
        raise SystemExit("brport_vs/.godot não existe: rode `$G --headless --path "
                         "brport_vs --import` uma vez (CLAUDE.md, «Como rodar»).")

    saida = args.saida.resolve()
    saida.mkdir(parents=True, exist_ok=True)
    perfil = saida / "perfil"
    perfil.mkdir(exist_ok=True)
    signal.signal(signal.SIGTERM, _ao_sinal)

    if args.trabalhadores > 1:
        rc = em_paralelo(args, mutantes)
        if rc:
            return rc
        if fatia:
            escrever_fatia(saida, fatia, mutantes)
        n = len([p for p in repartir(mutantes, args.trabalhadores) if p])
        print(f"\n{MARCADOR} — {len(mutantes)} defeito(s) reinjetado(s) em {n} cópia(s)"
              + (f", fatia {fatia[0]}/{fatia[1]}" if fatia else "")
              + ", cada um reprovado pela guarda declarada.")
        return 0

    exploradas = args.suites or list(SUITES)
    plano = {m["id"]: (exploradas if args.explorar else list(m["reprova"]))
             for m in mutantes}
    precisas = [s for s in SUITES if any(s in v for v in plano.values())]

    # A BASE PRIMEIRO, e tem de passar inteira: um vermelho herdado faria cada
    # mutante «reprovar» sem nunca ter visto o defeito (`gerais.md`, «confira
    # que a base está LIMPA antes de injetar o defeito seguinte»).
    print("Base:")
    tetos: dict[str, float] = {}
    for suite in precisas:
        r = rodar_suite(args.godot, suite, saida / f"base-{suite}.log", 900, perfil)
        ok = r["passou"] and r["compilou"] and not r["erro"] and not r["esgotou"]
        print(f"  {'verde' if ok else 'VERMELHA':<9} {suite} ({r['segundos']:.0f} s)")
        if not ok:
            print(f"::error::A base de {suite} não está verde (veja "
                  f"{saida / f'base-{suite}.log'}); sem base limpa não há o que medir.")
            return 1
        # O teto de cada mutante sai da base MEDIDA nesta máquina, com folga
        # para a deriva de ~20% que o contêiner já mostrou (`gerais.md`).
        tetos[suite] = max(60.0, 4 * r["segundos"])

    print(f"\n{len(mutantes)} mutante(s):")
    resultado: dict[str, dict] = {}
    falhas = 0
    for m in mutantes:
        alvo = RAIZ / m["alvo"]
        original = alvo.read_bytes()
        modo = alvo.stat().st_mode
        antes, depois = m["antes"].encode("utf-8"), m["depois"].encode("utf-8")
        mutado = (original.replace(antes, depois) if m.get("todas", False)
                  else original.replace(antes, depois, 1))
        assert mutado != original
        por_suite = {}
        try:
            trocar(alvo, mutado, modo)
            reimportar_se_arte(args.godot, alvo, perfil)
            for suite in plano[m["id"]]:
                r = rodar_suite(args.godot, suite,
                                saida / f"{m['id']}-{suite}.log", tetos[suite], perfil)
                guarda = None if args.explorar else m["reprova"][suite]
                ok, frase = julgar(r, guarda, tetos[suite])
                por_suite[suite] = {"aprovado": ok, "frase": frase,
                                    "reprovadas": r["reprovadas"]}
        except Interrompido:
            print("\ninterrompido — a restaurar o alvo.")
            return 130
        finally:
            trocar(alvo, original, modo)
            if alvo.read_bytes() != original:
                print(f"::error::{m['alvo']} NÃO voltou ao original — confira à mão.")
                return 2
            # E o cache volta com ele; a base do fim é que o prova.
            reimportar_se_arte(args.godot, alvo, perfil)
        resultado[m["id"]] = por_suite
        if args.explorar:
            print(f"  {m['id']}  ({m['de']})")
            for suite, r in por_suite.items():
                rot = r["reprovadas"]
                print(f"      {suite:<16} {r['frase']}"
                      + (": " + " | ".join(rot[:4]) if rot else ""))
            continue
        ok = all(r["aprovado"] for r in por_suite.values())
        falhas += 0 if ok else 1
        print(f"  {'reprovado' if ok else 'FURADO':<10} {m['id']}  ({m['de']})")
        for suite, r in por_suite.items():
            print(f"      {suite:<16} {r['frase']}")

    # E A BASE OUTRA VEZ NO FIM: os bytes já foram conferidos a cada troca, e
    # esta corrida prova o resto — que nenhum mutante deixou no `user://` das
    # corridas um estado que mude a resposta da suíte seguinte.
    print("\nBase no fim:")
    for suite in precisas:
        r = rodar_suite(args.godot, suite, saida / f"fim-{suite}.log", 900, perfil)
        ok = r["passou"] and r["compilou"] and not r["erro"] and not r["esgotou"]
        print(f"  {'verde' if ok else 'VERMELHA':<9} {suite}")
        if not ok:
            print(f"::error::A base de {suite} ficou vermelha depois dos mutantes.")
            return 1

    (saida / "relatorio.json").write_text(
        json.dumps(resultado, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    if args.explorar:
        print(f"\nExplorado — relatório em {saida / 'relatorio.json'}.")
        return 0
    if falhas:
        print(f"\n{falhas} de {len(mutantes)} mutante(s) furado(s): a guarda que os "
              "provou deixou de os apanhar, ou a descrição envelheceu.")
        return 1
    if fatia:
        escrever_fatia(saida, fatia, mutantes)
    print(f"\n{MARCADOR} — {len(mutantes)} defeito(s) reinjetado(s), cada um "
          "reprovado pela guarda declarada.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
