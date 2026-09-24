#!/usr/bin/env python3
"""Confere que todo painel que o jogo ABRE aparece em alguma fotografia.

Nada perguntava isto, e o buraco custou o seguinte, medido em 21/09: o R7 e o
R8 mexeram em QUATRO telas que imagem nenhuma mostrava, e três sessões
seguidas contaram os painéis deste jogo — as três disseram treze. São QUINZE.
As duas que faltavam escapam por razões diferentes, e nenhuma é descuido:

  · o `EndGame.tscn` NÃO vive em `scenes/panels/` — está em `scenes/`, e por
    isso escapa a todo inventário que olhe a pasta;
  · a `TelaNomes` o `capturar_tela.gd` dispensa DE PROPÓSITO, com
    `definir_nomes()`, para ela não tapar o que se ia fotografar.

⚠️ A COBERTURA É MEDIDA, E NÃO DECLARADA. A saída fácil era o tiro dizer ao
lado dele que painel cobre — e uma declaração à mão MENTE: escreve-se "cobre o
Caixa" num tiro que fotografa o Calendário e ninguém vê. Aqui as duas
ferramentas de captura IMPRIMEM a cena de cada painel que estava na tela
(`Paineis: res://...`), e esta ferramenta lê os logs da bateria. O que prova a
cobertura é a fotografia, não quem a escreveu.

São, portanto, duas fontes que nada obriga a concordar — que é a receita deste
projeto desde o D20:

  · o que o jogo ABRE  ← `_abrir_painel(...)` no `scripts/Main.gd`
  · o que foi À TELA   ← os logs que a bateria deixou

⚠️ E UM PAINEL NÃO É UMA TELA. A cena do Sr. Ribeiro são TRÊS — a entrada,
a de quem pagou e a de quem não pôde —, a do Arlindo são duas e o fim de fase
também. Até 23/09 a pergunta era por CENA, e a bateria fotografava só o
primeiro tempo de cada uma: a despedida do Arlindo viveu com "Cliente ouvindo
a proposta. (2 tentativas)" por baixo de um negócio já fechado, e nenhuma foto
o mostrava (`docs/decisoes/051`). Hoje o catálogo desce ao TEMPO, pelas mesmas
duas fontes:

  · os tempos que o painel TEM  ← cada `tempo = &"..."` no script da cena
  · os tempos que foram À TELA   ← as linhas `Tempo:` dos mesmos logs

⚠️ E UMA TELA NÃO É UMA CARA. O boletim é um painel de um tempo só, e a Dona
Cida tem nele três caras — a do tom da semana. Até 24/09 a bateria mostrava a
séria e nunca a preocupada nem a contente, e a pergunta por tempo ficava verde
(`docs/decisoes/060`). O catálogo desce mais um andar, pelas mesmas duas
fontes:

  · as caras que o jogo TEM     ← o `POR_EXPRESSAO` do `scripts/Retratos.gd`
  · as caras que foram À TELA   ← as linhas `Retratos:` dos mesmos logs, que
                                   as ferramentas só escrevem depois de provar
                                   que a cara mudou a foto (`caras_na_foto.gd`)

Uso:
  python3 tools/conferir_cobertura_paineis.py <pasta-de-fotos>

Espera `COBERTURA OK`.
"""

import os
import re
import sys

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MAIN = os.path.join(RAIZ, "brport_vs/scripts/Main.gd")
MENU = os.path.join(RAIZ, "brport_vs/scripts/PainelMenu.gd")
RETRATOS = os.path.join(RAIZ, "brport_vs/scripts/Retratos.gd")

# OS TEMPOS QUE FICAM SEM FOTO, e por quê — a lacuna DECLARADA, nunca a
# cobertura. A afirmação perigosa é a positiva (`docs/decisoes/042`): "este
# tiro cobre X" mente sem ninguém ver, "X não tem foto, por isto" só pode
# envelhecer para o lado seguro, e esta ferramenta reprova a entrada que
# envelhecer — o tempo deixou de existir, ou passou a ter foto.
#
# Está VAZIA desde 23/09: o balanço do fim de fase, que foi a primeira entrada,
# ganhou o tiro `balanco`, que joga a partida até ao vencimento e paga pelo
# botão. Com ela vazia, uma expressão partida continua a reprovar — ver a nota
# do catálogo vazio, no `main()`, que diz por onde.
TEMPOS_SEM_FOTO = {}


def sem_comentarios(texto):
    """Tira as linhas de comentário do GDScript.

    ⚠️ E O CORTE É PELO INÍCIO DA LINHA, nunca pelo `#` onde quer que esteja:
    este repositório escreve `var texto := "#%d" % ...`, e um corte por
    ocorrência partiria a linha ao meio. É a mesma regra do
    `conferir_escopo_ui.py`.

    ⚠️ E ELE FAZ FALTA: os comentários deste projeto CITAM `_abrir_painel(`
    palavra por palavra — este próprio arquivo o faz. Sem o corte, um painel
    que ninguém abre passaria a ser exigido por causa de uma frase.
    """
    return "\n".join(
        l for l in texto.splitlines() if not l.lstrip().startswith("#"))


def argumentos_de(texto, funcao):
    """Os argumentos de cada CHAMADA a `funcao`, com parênteses equilibrados.

    ⚠️ DUAS ARMADILHAS, E AS DUAS MORDERAM NA ESTREIA desta ferramenta:

    1. `[^)]*` PARA NO PRIMEIRO PARÊNTESE, e o `Main` tem uma abertura cuja
       chamada traz outra dentro — `_abrir_painel(load(cena) as PackedScene)`.
       A expressão ingénua lia `load(cena` e acusava uma forma desconhecida que
       ela própria tinha partido ao meio. É a mesma lição do F9 (`037`), onde o
       argumento com parênteses E aspas fez a expressão achar 9 de 11.
    2. A DEFINIÇÃO NÃO É UMA CHAMADA. `func _abrir_painel(cena: PackedScene)`
       casa tão bem quanto uma chamada de verdade, e a ferramenta exigia foto
       de um painel chamado `cena: PackedScene`.

    Ler o arquivo INTEIRO também faz falta: as chamadas deste repositório
    quebram aos ~79 caracteres, e uma varredura linha a linha perde as que
    estiverem a cavalo de duas.
    """
    argumentos = []
    for m in re.finditer(r'(?<!func )\b%s\(' % re.escape(funcao), texto):
        nivel = 1
        i = m.end()
        while i < len(texto) and nivel > 0:
            if texto[i] == "(":
                nivel += 1
            elif texto[i] == ")":
                nivel -= 1
            i += 1
        if nivel != 0:
            continue
        argumentos.append(texto[m.end():i - 1].strip())
    return argumentos


def cenas_que_o_jogo_abre(falhas):
    """As `.tscn` que o `Main` entrega a `_abrir_painel()`.

    A fonte é o que o jogo ABRE e não a pasta `scenes/panels/` — foi a pasta
    que perdeu o `EndGame` três vezes. Um painel que o jogo nunca abre não é
    buraco de foto: é arte órfã, e quem pergunta isso é o `arte_orfa.py`.
    """
    texto = sem_comentarios(open(MAIN, encoding="utf-8").read())
    consts = dict(re.findall(
        r'const\s+(\w+)\s*:=\s*preload\(\s*"(res://[^"]+\.tscn)"\s*\)', texto))

    cenas = set()
    for arg in argumentos_de(texto, "_abrir_painel"):
        if arg in consts:
            cenas.add(consts[arg])
            continue
        # ⚠️ ABERTURA QUE NÃO SE RESOLVE REPROVA, em vez de ser saltada. O
        # `Main` tem UMA dinâmica — `_abrir_painel(load(cena) as PackedScene)`,
        # o app do menu-celular —, e ela resolve-se pela tabela `APPS` do
        # `PainelMenu.gd`, que é quem sabe o que cada app abre. Uma forma nova
        # que esta ferramenta não saiba ler tem de ficar VERMELHA: saltá-la em
        # silêncio devolvia o buraco que o portão veio tapar.
        if re.fullmatch(r'load\(\s*cena\s*\)(\s+as\s+PackedScene)?', arg):
            cenas |= cenas_do_menu()
            continue
        falhas.append(
            "Main.gd abre um painel que esta ferramenta não sabe resolver: "
            "`_abrir_painel(%s)`. Ou ele vira um `const ... := preload(...)`, "
            "ou esta ferramenta aprende a forma nova — nunca se salta." % arg)
    return cenas


def cenas_do_menu():
    """As cenas que os apps do menu-celular abrem (`cena` vazia = porta fechada)."""
    texto = sem_comentarios(open(MENU, encoding="utf-8").read())
    return {c for c in re.findall(r'"cena"\s*:\s*"(res://[^"]*\.tscn)"', texto)}


def script_da_cena(cena, falhas):
    """O script do nó RAIZ de uma `.tscn`, ou None se ela não tiver nenhum."""
    arquivo = os.path.join(RAIZ, "brport_vs", cena[len("res://"):])
    if not os.path.isfile(arquivo):
        falhas.append("o jogo abre %s e o arquivo não existe." % cena)
        return None
    texto = open(arquivo, encoding="utf-8").read()
    scripts = dict((i, c) for c, i in re.findall(
        r'\[ext_resource[^\]]*type="Script"[^\]]*path="([^"]+)"[^\]]*id="([^"]+)"',
        texto))
    # O nó raiz é o primeiro `[node ...]`, e o bloco dele vai até ao seguinte.
    blocos = re.split(r'^\[', texto, flags=re.M)
    raiz = next((b for b in blocos if b.startswith("node ")), "")
    m = re.search(r'^script\s*=\s*ExtResource\(\s*"([^"]+)"\s*\)', raiz, re.M)
    if not m:
        return None
    if m.group(1) not in scripts:
        falhas.append(
            "%s aponta o script da raiz para ExtResource(\"%s\"), que não é "
            "um Script declarado no arquivo." % (cena, m.group(1)))
        return None
    return scripts[m.group(1)]


def tempos_do_painel(cena, falhas):
    """Os tempos que o script da cena declara, por `tempo = &"<id>"`.

    ⚠️ TODA ATRIBUIÇÃO É LIDA, E A QUE NÃO FOR LITERAL REPROVA. É a regra do
    `_abrir_painel` acima com outra roupa: `tempo = id` é um tempo cujo nome
    esta ferramenta não sabe, e saltá-lo em silêncio devolvia o buraco inteiro
    — o painel ficava com um tempo que nenhuma foto é obrigada a mostrar. A
    comparação (`==`) e a declaração (`var tempo: StringName`) não casam, e
    por isso não contam.

    ⚠️ E SÓ O SCRIPT DA CENA. Um `tempo = ...` escrito numa classe-mãe (o
    `PainelNarrativo`) não seria visto; hoje nenhuma o escreve.
    """
    script = script_da_cena(cena, falhas)
    if script is None:
        return set()
    arquivo = os.path.join(RAIZ, "brport_vs", script[len("res://"):])
    texto = sem_comentarios(open(arquivo, encoding="utf-8").read())
    tempos = set()
    for m in re.finditer(r'(?<!\w)tempo\s*=(?!=)\s*([^\n]*)', texto):
        lido = re.fullmatch(r'&"(\w+)"\s*', m.group(1))
        if lido:
            tempos.add(lido.group(1))
            continue
        falhas.append(
            "%s atribui o tempo por uma forma que esta ferramenta não sabe "
            "ler: `tempo = %s`. Escreva o literal (`&\"<id>\"`) — nunca se "
            "salta." % (script, m.group(1).strip()))
    return tempos


def bloco_equilibrado(texto, inicio):
    """O texto entre a chaveta aberta em `inicio` e a que a fecha."""
    nivel = 0
    for i in range(inicio, len(texto)):
        if texto[i] == "{":
            nivel += 1
        elif texto[i] == "}":
            nivel -= 1
            if nivel == 0:
                return texto[inicio + 1:i]
    return None


def caras_que_o_jogo_tem(falhas):
    """As caras do `Retratos.POR_EXPRESSAO`: arquivo -> «personagem/expressão».

    ⚠️ LÊ-SE O ARQUIVO INTEIRO e a tabela por chavetas equilibradas, e TODO
    valor tem de ser uma constante `preload` do mesmo arquivo — um valor que
    esta ferramenta não sabe ler REPROVA, pela regra do `_abrir_painel`: saltá-
    lo tirava a cara do catálogo, e o catálogo encolhido passa sempre.

    ⚠️ E UMA CARA SEM ARQUIVO RESOLVIDO É FALHA, não omissão: dois nomes para o
    mesmo arquivo também reprovam, porque a pergunta passaria a ser por
    arquivo e uma das caras ficaria coberta pela foto da outra.
    """
    texto = sem_comentarios(open(RETRATOS, encoding="utf-8").read())
    consts = dict(re.findall(
        r'const\s+(\w+)\s*:=\s*preload\(\s*"(res://[^"]+)"\s*\)', texto))
    m = re.search(r'const\s+POR_EXPRESSAO\s*:=\s*\{', texto)
    tabela = bloco_equilibrado(texto, m.end() - 1) if m else None
    if tabela is None:
        falhas.append("não achei a tabela `POR_EXPRESSAO` no Retratos.gd — "
                      "sem ela não há catálogo de caras.")
        return {}
    caras = {}
    for pm in re.finditer(r'"(\w+)"\s*:\s*\{', tabela):
        personagem = pm.group(1)
        corpo = bloco_equilibrado(tabela, pm.end() - 1) or ""
        for linha in [l.strip().rstrip(",") for l in corpo.split("\n")]:
            if not linha:
                continue
            em = re.fullmatch(r'"(\w+)"\s*:\s*(\w+)', linha)
            if not em or em.group(2) not in consts:
                falhas.append(
                    "o POR_EXPRESSAO de «%s» tem uma entrada que esta "
                    "ferramenta não sabe ler: `%s`. Cada cara é "
                    "`\"<expressão>\": <CONSTANTE>`, com a constante num "
                    "`preload` do mesmo arquivo — nunca se salta."
                    % (personagem, linha))
                continue
            arquivo = consts[em.group(2)]
            nome = "%s/%s" % (personagem, em.group(1))
            if arquivo in caras:
                falhas.append("«%s» e «%s» apontam para o mesmo %s."
                              % (caras[arquivo], nome, arquivo))
                continue
            caras[arquivo] = nome
    return caras


def cenas_fotografadas(pasta, falhas):
    """O que as ferramentas de captura disseram ter na tela, log a log."""
    logs = sorted(f for f in os.listdir(pasta) if f.endswith(".log"))
    if not logs:
        falhas.append(
            "não há log nenhum em %s — sem os logs da bateria não há o que "
            "medir, e 'nada em falta' seria um verde de graça." % pasta)
        return set(), set(), set()

    vistas = set()
    tempos = set()
    caras = set()
    com_linha = 0
    for nome in logs:
        with open(os.path.join(pasta, nome), encoding="utf-8") as fh:
            for linha in fh:
                if linha.startswith("Tempo:"):
                    partes = linha.split()
                    if len(partes) != 3:
                        falhas.append("%s: linha `Tempo:` que não se lê: %s"
                                      % (nome, linha.strip()))
                        continue
                    tempos.add((partes[1], partes[2]))
                    continue
                if linha.startswith("Retratos:"):
                    partes = linha.split()
                    if len(partes) < 2 or not partes[1].startswith("res://"):
                        falhas.append("%s: linha `Retratos:` que não se lê: %s"
                                      % (nome, linha.strip()))
                        continue
                    caras.add(partes[1])
                    continue
                if not linha.startswith("Paineis:"):
                    continue
                com_linha += 1
                for cena in linha.split(":", 1)[1].split():
                    if cena.startswith("res://"):
                        vistas.add(cena)
    # ⚠️ NENHUM LOG COM A LINHA É OUTRO DEFEITO, e não "nada fotografado". Se o
    # rótulo mudar de nome nas duas ferramentas, tudo desaparece de uma vez e a
    # lista de faltas fica do tamanho do catálogo — sem esta pergunta, quem
    # lesse o vermelho procuraria quinze painéis perdidos em vez de um `print`.
    if com_linha == 0:
        falhas.append(
            "nenhum dos %d logs traz a linha `Paineis:` — o rótulo mudou nas "
            "ferramentas de captura, ou elas não correram." % len(logs))
    return vistas, tempos, caras


def main():
    if len(sys.argv) != 2:
        print("uso: %s <pasta-de-fotos>" % sys.argv[0])
        return 2
    pasta = sys.argv[1]
    if not os.path.isdir(pasta):
        print("COBERTURA FALHOU — %s não é uma pasta." % pasta)
        return 1

    falhas = []
    abertas = cenas_que_o_jogo_abre(falhas)
    if not abertas and not falhas:
        falhas.append(
            "o Main.gd não declarou painel nenhum — a expressão deixou de "
            "casar, e um catálogo vazio faria tudo passar.")
    vistas, tempos_vistos, caras_vistas = cenas_fotografadas(pasta, falhas)

    for cena in sorted(abertas - vistas):
        falhas.append("o jogo abre %s e fotografia nenhuma o mostra." % cena)

    catalogo = {}
    for cena in sorted(abertas):
        tempos = tempos_do_painel(cena, falhas)
        if tempos:
            catalogo[cena] = tempos
    for (cena, tempo), porque in sorted(TEMPOS_SEM_FOTO.items()):
        if tempo not in catalogo.get(cena, set()):
            falhas.append("a lacuna declarada «%s» de %s é de um tempo que o "
                          "script já não tem — saia da lista." % (tempo, cena))
        elif (cena, tempo) in tempos_vistos:
            falhas.append("a lacuna declarada «%s» de %s já tem foto — saia "
                          "da lista." % (tempo, cena))
    for cena, tempos in catalogo.items():
        for tempo in sorted(tempos):
            if (cena, tempo) in TEMPOS_SEM_FOTO:
                continue
            if (cena, tempo) not in tempos_vistos:
                falhas.append("%s tem o tempo «%s» e fotografia nenhuma o "
                              "mostra." % (cena, tempo))
    # ⚠️ E O QUE A FOTO MOSTRA E O CÓDIGO NÃO DECLARA TAMBÉM REPROVA — é a
    # outra metade das duas fontes. Um tempo que só a captura conhece é uma
    # atribuição que esta ferramenta não viu, e a pergunta de cima ficaria
    # verde sobre um catálogo incompleto.
    for cena, tempo in sorted(tempos_vistos):
        if tempo not in catalogo.get(cena, set()):
            falhas.append("uma foto mostra o tempo «%s» de %s, que o script "
                          "da cena não declara." % (tempo, cena))
    # ⚠️ QUEM REPROVA UMA EXPRESSÃO PARTIDA É, QUASE SEMPRE, OUTRA LINHA. Com
    # lacuna declarada era a conferência dela, acima (o catálogo vazio não tem
    # o tempo da lacuna). Sem lacuna — desde 23/09 — é a outra metade das duas
    # fontes: medido nesse dia, a expressão partida com a lista vazia reprovou
    # SETE vezes por «uma foto mostra o tempo … que o script da cena não
    # declara», e esta linha calou-se, porque só fala sem falha nenhuma — o
    # comentário que aqui estava dizia o contrário. Ela reprova sozinha quando,
    # além disso, nenhuma foto traz `Tempo:` (medido, tirando as linhas dos
    # logs): fica pela causa que nomeia.
    if not catalogo and not falhas:
        falhas.append(
            "nenhum painel declara tempos — a expressão deixou de casar, e um "
            "catálogo vazio faria os segundos tempos passarem sem foto.")

    # AS CARAS, um andar abaixo do tempo (`docs/decisoes/060`). O catálogo é o
    # registo dos retratos; a foto é o que as ferramentas PROVARAM que mudou
    # os pixels — uma cara que o painel pede e a tela não mostra não chega
    # aqui.
    caras = caras_que_o_jogo_tem(falhas)
    if not caras and not falhas:
        falhas.append(
            "o POR_EXPRESSAO não tem cara nenhuma — a expressão deixou de "
            "casar, e um catálogo vazio faria toda cara passar sem foto.")
    # ⚠️ NENHUMA CARA EM LOG NENHUM É OUTRO DEFEITO, pela razão da linha
    # `Paineis:`: se o rótulo mudar, somem todas de uma vez, e quem lesse nove
    # caras sem foto procuraria nove tiros em vez de um `print`.
    if caras and not caras_vistas:
        falhas.append(
            "nenhum log traz a linha `Retratos:` — o rótulo mudou no "
            "`caras_na_foto.gd`, ou a prova das caras não correu.")
    for arquivo, nome in sorted(caras.items(), key=lambda par: par[1]):
        if arquivo not in caras_vistas:
            falhas.append("a cara «%s» (%s) não aparece em fotografia "
                          "nenhuma." % (nome, arquivo))
    # ⚠️ E A CARA QUE A FOTO MOSTRA E O REGISTO NÃO TEM TAMBÉM REPROVA: é um
    # painel a carregar retrato por fora do `Retratos.gd`, que é o ponto único
    # das caras — e a pergunta de cima ficaria verde sobre um catálogo que não
    # sabe dele.
    for arquivo in sorted(caras_vistas - set(caras)):
        falhas.append("uma foto mostra %s, que o POR_EXPRESSAO do "
                      "Retratos.gd não registra." % arquivo)

    if falhas:
        print("COBERTURA FALHOU — %d problema(s):" % len(falhas))
        for f in falhas:
            print("  · %s" % f)
        return 1

    print("%d painel(eis) que o jogo abre, todos fotografados." % len(abertas))
    print("%d tempo(s) em %d painel(eis) de mais de uma tela; %d "
          "fotografado(s) e %d sem foto, declarado(s)%s" % (
              sum(len(t) for t in catalogo.values()), len(catalogo),
              sum(len(t) for t in catalogo.values()) - len(TEMPOS_SEM_FOTO),
              len(TEMPOS_SEM_FOTO), ":" if TEMPOS_SEM_FOTO else "."))
    for (cena, tempo), porque in sorted(TEMPOS_SEM_FOTO.items()):
        print("  · %s «%s» — %s" % (cena, tempo, porque))
    print("%d cara(s) de %d personagem(ns), todas fotografadas." % (
        len(caras), len({n.split("/")[0] for n in caras.values()})))
    print("COBERTURA OK")
    return 0


if __name__ == "__main__":
    sys.exit(main())
