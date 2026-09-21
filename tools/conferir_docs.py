#!/usr/bin/env python3
"""Confere a documentação em camadas do BR Port — item B5 do plano v3.

POR QUE ISTO EXISTE. Em 02/09 as camadas foram arrumadas, e a arrumação
sozinha não vale nada: o estado anterior também tinha nascido arrumado. O que
aconteceu depois foi silencioso e é o que este programa procura.

O `ESTADO_DO_PROJETO.md` tinha 20 KB quando o plano descreveu a dor e tinha
**42.707 bytes** quando se foi mexer nele — dobrou sem ninguém decidir dobrar.
E dentro dele conviviam TRÊS respostas para "por onde começo" (o cabeçalho
mandava a um briefing de 29/08, a tabela a outro de 28/08, e o rodapé dizia
para apontar o próprio arquivo) e DUAS parcelas do Sr. Ribeiro, R$8.000 e
R$550.000, ambas lidas como atuais.

Nenhum teste via nada disso, porque documento não compila.

Uso:
    python3 tools/conferir_docs.py

Espera `DOCS OK` na última linha. É a linha que o CI procura — o código de
saída sozinho não chega, pela mesma razão que vale para a suíte do Godot.
"""
import os
import re
import sys

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# As quatro camadas, e mais nenhuma. Quem quiser uma quinta muda esta lista de
# propósito, que é o ponto: passa a ser decisão em vez de acidente.
CAMADAS = [
    ("Regras",   "CLAUDE.md"),
    ("Estado",   "docs/ESTADO_DO_PROJETO.md"),
    ("Rumo",     "docs/design/BR_Port_Plano_v3_Claude_Code.md"),
    ("Decisões", "docs/decisoes"),
]

ARQUIVO = "docs/arquivo"

# TETO DO ESTADO — alarme de fumaça, não regra de estilo. Ele existe porque o
# modo de falhar medido foi o crescimento CALADO, não o tamanho em si. Subir
# este número é perfeitamente legítimo; o que não é legítimo é o documento
# dobrar sem ninguém reparar. Em 02/09 o arquivo ficou com ~18 KB.
#
# ⚠️ SUBIU DE 26.000 EM 18/09, por decisão do Bruno e ao terceiro toque. A
# ordem escrita no ritual de fecho é descer o histórico, comprimir o que
# duplica outro documento e SÓ ENTÃO subir o teto — e os dois primeiros passos
# tinham sido dados duas vezes no mesmo dia, deixando 45 bytes de folga. Ao
# terceiro, comprimir passa a apagar registo útil em vez de duplicação, que é
# o contrário do que este alarme existe para proteger. O detalhe dos itens já
# fechados desceu para a decisão de cada um; o que ficou é o AGORA.
#
# ⚠️ E SUBIU DE 28.000 EM 20/09, pela MESMA ordem e pela mesma razão. O R6
# entrou com o estado a 199 bytes do teto; antes de o subir desceram as duas
# jogadas de 02–06/09 para o `HISTORICO.md`, e o R1 a R5 e os números de `024`,
# `025` e `029` viraram ponteiros para a decisão de cada um — 129 bytes ganhos,
# contra ~900 que a entrega pedia. O que ficou é o AGORA, e comprimi-lo mais
# começaria a apagar registo.
#
# ⚠️ E ELE MEDE O CRESCIMENTO, NÃO O TAMANHO. Se um dia duas entregas seguidas
# o subirem sem que nada desça, o que está errado não é o número: é o documento
# a voltar a crescer calado, que é o defeito de 02/09 outra vez.
#
# ⚠️ E SUBIU DE 29.000 EM 21/09, a pedido do Bruno e com o estado ABAIXO do
# teto (28.992 de 29.000, oito bytes). É a primeira vez que a subida não vem de
# uma entrega bloqueada: veio de o dia ter fechado DOIS itens e a compressão já
# ter sido feita TRÊS vezes — o R1 a R5 num parágrafo só, o R6/R7/R8 e as duas
# entregas do dia numa TABELA, e uma linha que duplicava o parágrafo de baixo
# apagada. As duas entregas somaram ~1.200 bytes de conteúdo e o arquivo subiu
# **75**: a condição do aviso acima (*"sem que nada desça"*) não se cumpriu, e
# é por isso que esta subida é legítima.
#
# ⚠️ E O NÚMERO SAI DA TAXA MEDIDA, não de um palpite. Do dia em que o teto
# subiu para 28.000 (18/09, arquivo a 26.863) até hoje foram **seis itens
# fechados** e +2.129 bytes — **~355 bytes por item, líquidos de compressão**.
# Mil bytes compram portanto ~3 itens, que é a cadência com que este alarme tem
# tocado desde 18/09 e a mesma com que a compressão dele tem produzido
# melhoria de verdade (a tabela dos R lê-se melhor do que os cinco parágrafos
# que ela substituiu).
#
# ⚠️ E A CADÊNCIA É O QUE HÁ PARA VIGIAR DAQUI PARA A FRENTE, mais do que o
# número. Este projeto já escreveu que *"validador que reprova o que está certo
# gasta-se depressa — na vez seguinte alguém sobe o limite em vez de olhar"*.
# Se o alarme voltar a tocar dentro de DOIS itens, o que ele está a apanhar já
# não é crescimento calado e sim o documento a acompanhar um projeto que tem 39
# decisões: aí a subida seguinte é maior, e não mais uma de mil.
TETO_ESTADO = 30000

# `00_INDICE.md` é citado na decisão 001 como um arquivo que NÃO veio no pacote
# de arte — é prosa sobre uma ausência, não uma referência a resolver. É a
# única exceção, e fica escrita aqui em vez de o conferidor ficar esperto.
AUSENTES_DE_PROPOSITO = {"00_INDICE.md"}

REF = re.compile(r'(?:\[[^\]]*\]\(([^)\s]+\.md)\)|`([^`\n]+?\.md)`)')

IGNORAR_PASTAS = {".git", ".godot", "node_modules", ".venv"}


def documentos():
    for dp, dn, fn in os.walk(RAIZ):
        dn[:] = [d for d in dn if d not in IGNORAR_PASTAS]
        for f in fn:
            if f.endswith(".md"):
                yield os.path.join(dp, f)


def tamanho_com_lf(caminho):
    """Mede o conteúdo versionado, não o EOL escolhido pelo checkout."""
    with open(caminho, "rb") as arquivo:
        return len(arquivo.read().replace(b"\r\n", b"\n"))


# ── A FONTE OPERACIONAL, e o que ela tranca (R3, `docs/decisoes/032`) ──────
#
# As quatro perguntas abaixo não são sobre DOCUMENTOS: são sobre AFIRMAÇÕES que
# documentos fazem a respeito do que a máquina realmente corre. Em 17/09 a
# revisão achou seis documentos a anunciar uma bateria de CINCO suítes — o
# `teste_registro` entrara no CI em 02/09 —, três ferramentas a publicar taxas
# de balanceamento que tinham deixado de ser medidas, e o ritual de fecho a
# mandar regerar DOIS dos quatro mapas. Nada disso é referência partida, que é
# o que este conferidor já sabia ver; é texto verdadeiro no dia em que foi
# escrito e falso hoje.
#
# A regra que sai daqui: **a lista vive no workflow, e o texto responde por ela.**
WORKFLOW = ".github/workflows/testes.yml"

# O triplo do balanceamento tem UM endereço vivo. Não é preciosismo: ele esteve
# em cinco, três divergiram, e um deles era o resumo que o CI publica toda
# segunda-feira. As pastas abaixo guardam HISTÓRIA — uma decisão registada e o
# arquivo das sessões descrevem o que se mediu NAQUELE dia, e reescrevê-las
# seria apagar o registo.
ENDERECO_DO_TRIPLO = "CLAUDE.md"
HISTORIA = ("docs/arquivo", "docs/decisoes", "docs/REVISAO_GERAL")
TRIPLO = re.compile(
    r"\b100(?:,0)?\s*%\s*[/·]\s*\d{1,3},\d\s*%\s*[/·]\s*\d{1,3},\d\s*%")


def _normal(s):
    """`100%` e `100,0%` são o mesmo número — e uma vírgula a mais abria um
    segundo endereço sem a guarda ver. Medido: o plano v3 tinha as duas
    grafias, e só uma reprovava."""
    return re.sub(r"\s+", "", s).replace("100,0%", "100%")

# ⚠️ O QUE ESTA GUARDA NÃO COBRE, escrito ao lado dela. Ela compara contra o
# triplo ATUAL, lido do `CLAUDE.md`, e não contra o padrão: uma medição ANTIGA
# em prosa datada — os `100% / 47,8% / 0%` de 01/09 que o plano v3 narra duas
# vezes, com a data e o aviso de que a economia foi reescalada — não é um
# segundo endereço, é o registo de um dia. Foi medido: a versão que reprovava
# pelo PADRÃO apanhava esses dois e teria mandado reescrever história para
# ficar verde, que é o contrário do que este repositório faz.
#
# Em código (`.yml`, `.gd`, `.py`) a régua é mais apertada, e de propósito:
# ali um triplo ou é o de hoje ou não devia estar escrito. Foi exatamente
# assim que o resumo semanal do CI publicou 79,5% / 35,7% durante duas
# semanas depois de esses números deixarem de ser medidos.
CODIGO_QUE_AFIRMA = (".github/workflows", "tools", "brport_vs/tools",
                     "brport_vs/tests", "brport_vs/autoload")


def _triplo_atual(regras):
    m = TRIPLO.search(regras)
    return m.group(0) if m else None


def _sem_continuacoes(texto):
    """Junta as linhas partidas por `\` — sem isto um comando de workflow é
    lido como três linhas soltas, e um `grep` por ele não casa nada. Custou um
    verde de graça no próprio dia em que esta função foi escrita."""
    return re.sub(r"\\\n\s*", " ", texto)


def conferir_fonte_operacional(docs):
    falhas = []
    caminho_wf = os.path.join(RAIZ, WORKFLOW)
    if not os.path.exists(caminho_wf):
        return ["falta %s — sem ele não há fonte operacional a conferir." % WORKFLOW]
    wf = _sem_continuacoes(open(caminho_wf, encoding="utf-8").read())

    # ── 1. As SUÍTES que o CI roda têm de estar nomeadas no CLAUDE.md ──────
    suites = sorted(set(re.findall(
        r"--script\s+res://((?:tests|scripts/validation)/[a-z_]+)\.gd", wf)))
    if not suites:
        falhas.append("não achei suíte nenhuma em %s — ou elas sumiram, ou "
                      "este conferidor deixou de as entender." % WORKFLOW)
    regras = open(os.path.join(RAIZ, "CLAUDE.md"), encoding="utf-8").read()
    for s in suites:
        nome = s.split("/")[-1]
        if nome not in regras:
            falhas.append(
                "o CI roda `%s.gd` e o CLAUDE.md não o nomeia. Suíte omitida é "
                "suíte que ninguém roda à mão — foi assim que o teste_registro "
                "passou duas semanas fora de seis documentos." % s)

    # ── 2. Os MAPAS que o CI regera são os que o ritual manda regerar ──────
    do_ci = set(re.findall(r"gerar_mapa_iso\.py[^\n]*?(brport_vs/art/[a-z_0-9]+\.svg)", wf))
    ritual = os.path.join(RAIZ, ".claude/skills/fechar-sessao/SKILL.md")
    if do_ci and os.path.exists(ritual):
        texto = _sem_continuacoes(open(ritual, encoding="utf-8").read())
        da_skill = set(re.findall(
            r"gerar_mapa_iso\.py[^\n]*?(brport_vs/art/[a-z_0-9]+\.svg)", texto))
        if da_skill != do_ci:
            falhas.append(
                "o CI regera %d mapa(s) e o /fechar-sessao regera %d: %s. "
                "Quem seguir o ritual deixa a diferença por regerar e descobre "
                "no CI vermelho." % (
                    len(do_ci), len(da_skill),
                    ", ".join(sorted(x.split("/")[-1] for x in do_ci ^ da_skill))))

    # ── 3. O texto não pode dizer um número de partidas que o CI não roda ──
    m = re.search(r"simular_balanceamento\.gd\s+--\s+(\d+)", wf)
    if m:
        n = m.group(1)
        frase = re.compile(r"(?:as\s+)?(\d+)\s+partidas\s+(?:que\s+)?(?:o\s+)?(?:que o\s+)?CI"
                           r"|(\d+)\s+partidas\s+do\s+CI")
        for doc in docs:
            rel = os.path.relpath(doc, RAIZ)
            if rel.startswith(HISTORIA):
                continue
            for achado in frase.finditer(open(doc, encoding="utf-8").read()):
                dito = achado.group(1) or achado.group(2)
                if dito != n:
                    falhas.append(
                        "%s diz «%s partidas … CI» e o comando roda %s."
                        % (rel, dito, n))

    # ── 4. O triplo do balanceamento vive num sítio só ─────────────────────
    atual = _triplo_atual(regras)
    if atual is None:
        falhas.append(
            "o %s não publica as taxas medidas do balanceamento. Elas têm de "
            "viver em algum sítio, e o endereço é esse." % ENDERECO_DO_TRIPLO)
    else:
        for doc in docs:
            rel = os.path.relpath(doc, RAIZ)
            if rel.startswith(HISTORIA) or rel == ENDERECO_DO_TRIPLO:
                continue
            if any(_normal(m.group(0)) == _normal(atual)
                   for m in TRIPLO.finditer(open(doc, encoding="utf-8").read())):
                falhas.append(
                    "%s repete as taxas de hoje (%s). Elas vivem só no %s: "
                    "estiveram em cinco sítios, três divergiram, e um deles "
                    "era o resumo que o CI publica toda segunda-feira."
                    % (rel, atual, ENDERECO_DO_TRIPLO))

    # ── 4b. Em CÓDIGO, um triplo ou é o de hoje ou não devia estar lá ──────
    for base in CODIGO_QUE_AFIRMA:
        raiz_cod = os.path.join(RAIZ, base)
        if not os.path.isdir(raiz_cod):
            continue
        for dp, dn, fn in os.walk(raiz_cod):
            dn[:] = [d for d in dn if d not in IGNORAR_PASTAS]
            for f in fn:
                if not f.endswith((".yml", ".yaml", ".gd", ".py")):
                    continue
                caminho = os.path.join(dp, f)
                rel = os.path.relpath(caminho, RAIZ)
                for achado in TRIPLO.finditer(open(caminho, encoding="utf-8").read()):
                    if atual is None or _normal(achado.group(0)) != _normal(atual):
                        falhas.append(
                            "%s afirma «%s», que não é a medição de hoje. Em "
                            "código o triplo ou é o atual ou não se escreve: "
                            "aponte para o %s."
                            % (rel, achado.group(0), ENDERECO_DO_TRIPLO))
    return falhas


def main():
    falhas = []
    docs = sorted(documentos())

    # Índice de nomes-base: o repositório cita documentos pelo nome nu com
    # muita frequência (`ESTADO_DO_PROJETO.md`), e isso é convenção daqui, não
    # descuido. O que se exige é que o documento EXISTA — não que a citação
    # traga o caminho todo.
    por_nome = {}
    for d in docs:
        por_nome.setdefault(os.path.basename(d), []).append(d)

    # ── 1. As camadas existem ──────────────────────────────────────────────
    for papel, caminho in CAMADAS:
        if not os.path.exists(os.path.join(RAIZ, caminho)):
            falhas.append("camada %s: falta %s" % (papel, caminho))

    # ── 2. Toda referência de documento tem destino ────────────────────────
    for doc in docs:
        rel = os.path.relpath(doc, RAIZ)
        texto = open(doc, encoding="utf-8").read()
        for m in REF.finditer(texto):
            alvo = (m.group(1) or m.group(2)).strip()
            if alvo.startswith(("http", "#")) or "*" in alvo or "NNN" in alvo:
                continue
            if os.path.basename(alvo) in AUSENTES_DE_PROPOSITO:
                continue
            raizes = [os.path.dirname(doc), RAIZ,
                      os.path.join(RAIZ, "docs"), os.path.join(RAIZ, "brport_vs")]
            if any(os.path.exists(os.path.join(r, alvo)) for r in raizes):
                continue
            if os.path.basename(alvo) in por_nome and "/" not in alvo:
                continue
            falhas.append("%s aponta para %s, que não existe" % (rel, alvo))

    # ── 3. Registro de sessão vive no arquivo, e em nenhum outro lugar ─────
    # A regra é por FUNÇÃO, não por nome — mas o prefixo `BLOCO` é o sintoma
    # que se consegue conferir, e foi ele que encheu a raiz de `docs/` com 12
    # documentos, três deles chamados "briefing para continuar".
    for doc in docs:
        rel = os.path.relpath(doc, RAIZ).replace(os.sep, "/")
        if os.path.basename(rel).startswith("BLOCO") and not rel.startswith(ARQUIVO + "/"):
            falhas.append("%s é registro de sessão e devia estar em %s/" % (rel, ARQUIVO))

    # ── 4. O índice do arquivo cobre o que está lá ─────────────────────────
    # É o que torna "nada se apaga" verificável em vez de promessa: um
    # documento que entra no arquivo sem entrar no índice está enterrado.
    dir_arquivo = os.path.join(RAIZ, ARQUIVO)
    if os.path.isdir(dir_arquivo):
        indice = open(os.path.join(dir_arquivo, "README.md"), encoding="utf-8").read()
        for f in sorted(os.listdir(dir_arquivo)):
            if f == "README.md" or f.startswith("."):
                continue
            if f not in indice:
                falhas.append("%s/%s não está no índice do arquivo (README.md)" % (ARQUIVO, f))
    else:
        falhas.append("falta a pasta %s/" % ARQUIVO)

    # ── 5. O texto responde pela fonte que a máquina corre ─────────────────
    falhas += conferir_fonte_operacional(docs)

    # ── 5. O estado não voltou a inchar sem ninguém decidir ────────────────
    estado = os.path.join(RAIZ, "docs/ESTADO_DO_PROJETO.md")
    if os.path.exists(estado):
        # `core.autocrlf=true` acrescenta um byte por linha no Windows. Medir o
        # arquivo cru fazia o mesmo blob passar no CI Linux e reprovar num
        # checkout Windows limpo (25.925 contra 26.274 bytes em 12/09/2026).
        tam = tamanho_com_lf(estado)
        if tam > TETO_ESTADO:
            falhas.append(
                "docs/ESTADO_DO_PROJETO.md tem %d bytes, acima do teto de %d. "
                "A ordem é: (1) o que virou histórico desce para "
                "docs/arquivo/HISTORICO.md; (2) o que duplica outro documento "
                "vira um ponteiro para ele; (3) só então o teto sobe, de "
                "propósito e com a razão no commit — subi-lo É legítimo. "
                "E nunca partir o estado em duas partes: ele lê-se inteiro."
                % (tam, TETO_ESTADO))

    if falhas:
        print("DOCS FALHOU — %d problema(s):" % len(falhas))
        for f in falhas:
            print("  · %s" % f)
        return 1

    print("%d documentos, %d no arquivo, estado com %d bytes." % (
        len(docs), len(os.listdir(dir_arquivo)) - 1, tam))
    print("=== DOCS OK — as camadas estão de pé, as referências resolvem e o texto bate com o que o CI corre ===")
    return 0


if __name__ == "__main__":
    sys.exit(main())
