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


def cenas_fotografadas(pasta, falhas):
    """O que as ferramentas de captura disseram ter na tela, log a log."""
    logs = sorted(f for f in os.listdir(pasta) if f.endswith(".log"))
    if not logs:
        falhas.append(
            "não há log nenhum em %s — sem os logs da bateria não há o que "
            "medir, e 'nada em falta' seria um verde de graça." % pasta)
        return set(), 0

    vistas = set()
    com_linha = 0
    for nome in logs:
        with open(os.path.join(pasta, nome), encoding="utf-8") as fh:
            for linha in fh:
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
    return vistas, com_linha


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
    vistas, _ = cenas_fotografadas(pasta, falhas)

    for cena in sorted(abertas - vistas):
        falhas.append("o jogo abre %s e fotografia nenhuma o mostra." % cena)

    if falhas:
        print("COBERTURA FALHOU — %d problema(s):" % len(falhas))
        for f in falhas:
            print("  · %s" % f)
        return 1

    print("%d painel(eis) que o jogo abre, todos fotografados." % len(abertas))
    print("COBERTURA OK")
    return 0


if __name__ == "__main__":
    sys.exit(main())
