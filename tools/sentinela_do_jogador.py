#!/usr/bin/env python3
"""A sentinela do jogador — prova que nenhuma ferramenta tocou no que é dele.

    python3 tools/sentinela_do_jogador.py plantar  brport_vs
    ... as suítes, a bateria de captura, o simulador ...
    python3 tools/sentinela_do_jogador.py conferir brport_vs      # SENTINELA INTACTA
    python3 tools/sentinela_do_jogador.py remover  brport_vs

Planta um arquivo conhecido em cada lugar onde o JOGO guarda o que é do
jogador — `savegame.json`, `audio.cfg` e a pasta `registros/` do `user://` do
projeto — e depois exige-os byte a byte, sem arquivo novo na pasta.
`docs/decisoes/061`.

Porquê: em 25/09 uma captura apagou a partida real do Bruno no Windows, e as
suítes limpavam a pasta de registros e gravavam o volume a zero no mesmo
sítio. O `ArmazemLocal.gd` isola agora todo processo com `--script`, e o F13
do `teste_fumaca` prova de onde vem cada caminho; esta é a prova do OUTRO
lado, a do arquivo: se o isolamento regredir, a sentinela some ou muda.

⚠️ ELA NÃO CORRE NUM PERFIL COM PARTIDA. Plantar é ESCREVER no lugar do
jogador — exactamente o que se quer impedir. Por isso `plantar` recusa-se se
lá houver qualquer coisa que não seja uma sentinela anterior, e o sítio certo
para isto é um contêiner ou o CI, onde não há jogador nenhum.

⚠️ E DEPOIS DE CONFERIDA ELA SAI DO DISCO, antes de correr código que não a
conhece. O `captura.yml` fotografa a BASE do PR a seguir, e uma base anterior
ao `ArmazemLocal` lê o `savegame.json` da sentinela — que não é JSON, de
propósito —, imprime o erro de parse com backtrace e a varredura de erros da
bateria reprova a base. Mordeu no PR #88. `remover` só apaga o que for
sentinela byte a byte; um arquivo do jogador recusa-se, como no `plantar`.

O caminho do `user://` segue o do Godot para um projeto sem pasta própria:
`<dados>/godot/app_userdata/<config/name>`, com `<dados>` = `$XDG_DATA_HOME`
ou `~/.local/share` no Linux, `%APPDATA%` no Windows e
`~/Library/Application Support` no macOS.
"""

import os
import re
import sys

# O conteúdo diz o que é, para quem o encontrar sem contexto. Não é JSON de
# propósito: se o isolamento falhar, o `load_game()` recusa-o e APAGA-O, e é
# essa a reprovação mais barata que há.
CONTEUDO = (
    b"SENTINELA DO JOGADOR - tools/sentinela_do_jogador.py\n"
    b"Nenhuma ferramenta pode reescrever, apagar ou renomear este arquivo.\n"
)

# O que o jogo guarda, relativo ao `user://`. Os nomes são os que o
# `ArmazemLocal.caminho()` recebe no `GameState`, no `Audio` e no `Registro`.
ARQUIVOS = ("savegame.json", "audio.cfg")
PASTA_REGISTROS = "registros"
REGISTRO_SENTINELA = "partida_sentinela.jsonl"


def nome_do_projeto(projeto):
    texto = open(os.path.join(projeto, "project.godot"), encoding="utf-8").read()
    achado = re.search(r'^config/name="([^"]*)"', texto, re.M)
    if not achado:
        sys.exit("FALHOU — `config/name` não está em %s/project.godot" % projeto)
    if re.search(r"^config/use_custom_user_dir=true", texto, re.M):
        # Com pasta própria o caminho é outro, e adivinhá-lo seria conferir a
        # pasta errada e publicar um verde de graça.
        sys.exit("FALHOU — o projeto usa `custom_user_dir`; este script não o sabe ler")
    return achado.group(1)


def pasta_do_usuario(projeto):
    if sys.platform.startswith("win"):
        dados = os.environ["APPDATA"]
    elif sys.platform == "darwin":
        dados = os.path.expanduser("~/Library/Application Support")
    else:
        dados = os.environ.get("XDG_DATA_HOME") or os.path.expanduser("~/.local/share")
    return os.path.join(dados, "godot", "app_userdata", nome_do_projeto(projeto))


def alvos(raiz):
    fora = [os.path.join(raiz, n) for n in ARQUIVOS]
    fora.append(os.path.join(raiz, PASTA_REGISTROS, REGISTRO_SENTINELA))
    return fora


def ler(caminho):
    with open(caminho, "rb") as f:
        return f.read()


def plantar(raiz):
    registros = os.path.join(raiz, PASTA_REGISTROS)
    # PRIMEIRO confere tudo, DEPOIS escreve — a regra do `load_game()`: a
    # recusa não pode deixar metade plantada.
    for caminho in alvos(raiz):
        if os.path.exists(caminho) and ler(caminho) != CONTEUDO:
            sys.exit("RECUSADO — %s já existe e não é uma sentinela: "
                     "há um jogador aqui, e plantar apagaria o que é dele" % caminho)
    if os.path.isdir(registros):
        alheios = [n for n in os.listdir(registros) if n != REGISTRO_SENTINELA]
        if alheios:
            sys.exit("RECUSADO — %s tem %d gravação(ões) de partida: "
                     "há um jogador aqui" % (registros, len(alheios)))
    os.makedirs(registros, exist_ok=True)
    for caminho in alvos(raiz):
        with open(caminho, "wb") as f:
            f.write(CONTEUDO)
    print("Sentinela plantada em %s (%d arquivos)" % (raiz, len(alvos(raiz))))


def conferir(raiz):
    problemas = []
    for caminho in alvos(raiz):
        if not os.path.exists(caminho):
            problemas.append("%s foi APAGADO" % caminho)
        elif ler(caminho) != CONTEUDO:
            problemas.append("%s foi REESCRITO (%d bytes)" % (caminho, len(ler(caminho))))
    registros = os.path.join(raiz, PASTA_REGISTROS)
    if os.path.isdir(registros):
        novos = sorted(n for n in os.listdir(registros) if n != REGISTRO_SENTINELA)
        if novos:
            problemas.append("%d gravação(ões) nova(s) na pasta do jogador: %s"
                             % (len(novos), ", ".join(novos[:5])))
    # O que as ferramentas escreveram, para quem ler o log saber que o
    # isolamento TRABALHOU e não só que nada correu: pasta vazia aqui com a
    # sentinela intacta seria o verde de uma corrida que não gravou nada.
    ferramentas = os.path.join(raiz, "ferramentas")
    contagem = sum(len(fs) for _, _, fs in os.walk(ferramentas)) if os.path.isdir(ferramentas) else 0
    print("Arquivos em user://ferramentas/: %d" % contagem)
    if problemas:
        for p in problemas:
            print("  FALHA %s" % p)
        print("SENTINELA VIOLADA — %d problema(s)" % len(problemas))
        return 1
    print("SENTINELA INTACTA — %d arquivos do jogador, byte a byte" % len(alvos(raiz)))
    return 0


def remover(raiz):
    for caminho in alvos(raiz):
        if os.path.exists(caminho) and ler(caminho) != CONTEUDO:
            sys.exit("RECUSADO — %s não é uma sentinela: não apago o que é do jogador" % caminho)
    removidos = 0
    for caminho in alvos(raiz):
        if os.path.exists(caminho):
            os.remove(caminho)
            removidos += 1
    registros = os.path.join(raiz, PASTA_REGISTROS)
    if os.path.isdir(registros) and not os.listdir(registros):
        os.rmdir(registros)
    print("Sentinela removida de %s (%d arquivos)" % (raiz, removidos))


def main():
    if len(sys.argv) != 3 or sys.argv[1] not in ("plantar", "conferir", "remover"):
        sys.exit(__doc__)
    raiz = pasta_do_usuario(sys.argv[2])
    if sys.argv[1] == "plantar":
        plantar(raiz)
        return 0
    if sys.argv[1] == "remover":
        remover(raiz)
        return 0
    return conferir(raiz)


if __name__ == "__main__":
    sys.exit(main())
