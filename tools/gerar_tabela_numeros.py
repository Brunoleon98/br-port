#!/usr/bin/env python3
"""Gera a tabela versionada dos números da Fase 1 a partir do GameState.gd.

Item A2 da fila do Plano v3. Os números do jogo viviam em dois lugares — o GDD
e as constantes `# TUNING:` — e JÁ DIVERGIRAM uma vez, com registro:
`BR_Port_GDD_V7_ERRATA_ECONOMIA.md` documenta um erro de aritmética no próprio
GDD, cujo modelo da Fase 1 acumulava R$1.480 contra uma parcela de R$8.000.

O remédio é o mesmo que o projeto já usa para os sons ("os WAV versionados
batem com o gerador") e para as âncoras do mapa: a tabela é GERADA, e o CI
falha se a versionada não bater com o que sai daqui. Mexer num `# TUNING:` sem
regerar quebra o CI.

    python3 tools/gerar_tabela_numeros.py                     # escreve a tabela
    python3 tools/gerar_tabela_numeros.py --conferir           # só confere, não escreve
    python3 tools/gerar_tabela_numeros.py --contra-godot d.json # cruza com o Godot

POR QUE HÁ UMA CONFERÊNCIA CONTRA O GODOT. Este script lê o TEXTO do
GameState.gd, porque metade do valor da tabela está nos comentários: é o
comentário que diz se o número saiu do GDD ou é TUNING, e comentário nenhum
sobrevive a `get_script_constant_map()`. Só que ler texto é exatamente como
nasce um gerador silencioso — basta uma constante mudar de forma para ela sumir
da tabela sem ninguém notar, e a partir daí a tabela envelhece PARECENDO em
dia, que é o pior estado possível para o artefato que existe justamente para
não envelhecer.

Por isso `brport_vs/tools/despejar_constantes.gd` despeja as constantes
avaliadas pelo próprio Godot, e `--contra-godot` cruza as duas leituras nome a
nome, valor a valor. Uma constante que este parser não entender não some: ela
reprova o CI.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
FONTE = RAIZ / "brport_vs" / "autoload" / "GameState.gd"
SAIDA = RAIZ / "docs" / "design" / "BR_Port_Numeros_Fase_1.md"

# `const NOME := valor` e `const NOME: Tipo = valor`, com o comentário de fim
# de linha capturado à parte — é dele que sai a coluna "Fonte".
RE_CONST = re.compile(
    r"^const\s+(?P<nome>[A-Z_][A-Z0-9_]*)\s*(?::\s*[A-Za-z0-9_\[\]]+\s*)?:?=\s*"
    r"(?P<valor>.*?)(?:\s+#\s*(?P<comentario>.*))?$"
)
RE_SECAO = re.compile(r"^#\s*──+\s*(?P<titulo>.*?)\s*──+\s*$")


class ErroDeLeitura(Exception):
    """O parser não entendeu alguma coisa. Nunca é para ser engolido em silêncio."""


def _limpar_secao(titulo: str) -> str:
    return titulo.strip().rstrip("─").strip()


def ler_constantes(fonte: Path) -> list[dict]:
    """Devolve as constantes na ORDEM DO ARQUIVO, com seção e comentários.

    A ordem do arquivo é preservada de propósito: é ela que agrupa o que se lê
    junto (os quatro valores de barco, as cinco de reputação). Uma tabela em
    ordem alfabética espalharia isso e obrigaria quem lê a remontar de cabeça o
    que o autor já tinha agrupado.
    """
    linhas = fonte.read_text(encoding="utf-8").splitlines()
    constantes: list[dict] = []
    secao = "Geral"
    bloco: list[str] = []          # comentários imediatamente acima da constante
    herdado = False                # o bloco já foi usado por uma constante antes?
    i = 0
    while i < len(linhas):
        linha = linhas[i]

        m_secao = RE_SECAO.match(linha)
        if m_secao:
            secao = _limpar_secao(m_secao.group("titulo"))
            bloco = []
            herdado = False
            i += 1
            continue

        if linha.startswith("#"):
            if herdado:            # comentário novo: o grupo anterior acabou
                bloco = []
                herdado = False
            bloco.append(linha.lstrip("#").strip())
            i += 1
            continue

        if not linha.strip():
            bloco = []
            herdado = False
            i += 1
            continue

        m = RE_CONST.match(linha)
        if m:
            valor_txt = m.group("valor").strip()
            # Literal de várias linhas (ESTRUTURAS): consome até fechar.
            if valor_txt.endswith(("{", "[")):
                abre, fecha = ("{", "}") if valor_txt.endswith("{") else ("[", "]")
                profundidade = 1
                corpo = [valor_txt]
                while profundidade > 0:
                    i += 1
                    if i >= len(linhas):
                        raise ErroDeLeitura(
                            "%s: literal de %s aberto e nunca fechado"
                            % (m.group("nome"), abre)
                        )
                    corpo.append(linhas[i])
                    sem_comentario = linhas[i].split("#")[0]
                    profundidade += sem_comentario.count(abre)
                    profundidade -= sem_comentario.count(fecha)
                valor_txt = "\n".join(corpo)

            constantes.append(
                {
                    "nome": m.group("nome"),
                    "valor_txt": valor_txt,
                    "comentario": (m.group("comentario") or "").strip(),
                    "bloco": list(bloco),
                    "bloco_herdado": herdado,
                    "secao": secao,
                    "linha": i + 1,
                }
            )
            # O bloco NÃO é limpo aqui: uma corrida de constantes sem linha em
            # branco no meio é um grupo, e o comentário acima dela governa o
            # grupo inteiro. Era o que fazia BOAT_VALUE_SMALL_MAX aparecer como
            # "regra" enquanto o comentário logo acima dizia GDD.
            herdado = True
            i += 1
            continue

        # Linha de código comum: corta o bloco de comentário acumulado.
        bloco = []
        herdado = False
        i += 1

    if not constantes:
        raise ErroDeLeitura("nenhuma constante encontrada em %s" % fonte)
    return constantes


def avaliar(valor_txt: str, ja_lidas: dict) -> object:
    """Avalia o literal GDScript. Só o que a fonte realmente usa.

    Deliberadamente estreito: inteiro, real, texto, e produto de constantes já
    lidas (TURNS_PER_WEEK * WEEKS_TOTAL). Qualquer outra coisa levanta
    ErroDeLeitura em vez de devolver um palpite — um valor errado na tabela é
    pior do que uma falha barulhenta, porque ninguém o confere depois.
    """
    t = valor_txt.strip()
    if t.startswith(("{", "[")):
        return None                                   # literal composto: não vai na tabela
    if re.fullmatch(r'"[^"]*"', t):
        return t[1:-1]
    if re.fullmatch(r"-?\d+", t):
        return int(t)
    if re.fullmatch(r"-?\d+\.\d+", t):
        return float(t)
    if t in ("true", "false"):
        return t == "true"

    expr = re.fullmatch(r"[A-Z_0-9\s*+\-]+", t)
    if expr:
        termos = re.findall(r"[A-Z_][A-Z0-9_]*|\d+|[*+\-]", t)
        seguro = []
        for termo in termos:
            if termo in ("*", "+", "-") or termo.isdigit():
                seguro.append(termo)
            elif termo in ja_lidas and isinstance(ja_lidas[termo], (int, float)):
                seguro.append(str(ja_lidas[termo]))
            else:
                raise ErroDeLeitura("não sei avaliar %r (termo %r)" % (t, termo))
        return eval(" ".join(seguro))                 # só dígitos e + - *, montado acima

    raise ErroDeLeitura("não sei avaliar o valor %r" % t)


def classificar(c: dict) -> str:
    """De onde vem o número: do GDD, de medição, ou é regra do jogo.

    Só o comentário DA CONSTANTE conta — nunca o cabeçalho da seção. O
    cabeçalho "Contra-oferta do Arlindo (GDD: ...)" vale até o fim do arquivo
    e chegava a carimbar SAVE_PATH como número do GDD.
    """
    texto = " ".join([c["comentario"]] + c["bloco"])
    tem_tuning = "TUNING" in texto
    tem_gdd = "GDD" in texto
    if tem_tuning and tem_gdd:
        return "TUNING (GDD)"
    if tem_tuning:
        return "TUNING"
    if tem_gdd:
        return "GDD 7"
    if "Protótipo" in texto:
        return "Protótipo"
    return "regra"


def formatar(valor: object) -> str:
    if isinstance(valor, bool):
        return "sim" if valor else "não"
    if isinstance(valor, int):
        return "{:,}".format(valor).replace(",", ".")
    if isinstance(valor, float):
        # Sempre com uma casa, no mínimo: PATIO_BONUS_PIER é 1.00 (dobra a
        # renda) e imprimir "1" faz um multiplicador parecer uma contagem.
        return ("%.2f" % valor).rstrip("0") + ("0" if float(valor).is_integer() else "")
    if valor is None:
        return "—"
    return "`%s`" % valor


def nota(c: dict) -> str:
    """A justificativa curta, em uma frase.

    O comentário de fim de linha ganha do bloco: foi escrito para aquela
    constante, e o bloco costuma valer para o grupo. Do bloco sai a primeira
    FRASE inteira — cortar na primeira linha deixava a nota no meio de uma
    ("TUNING — medido, não estimado. 600 partidas por perfil em"), o que é pior
    do que não ter nota, porque parece completa.
    """
    if c["comentario"]:
        return c["comentario"]
    corpo = " ".join(l for l in c["bloco"] if l).strip()
    if not corpo:
        return ""
    frase = re.split(r"(?<=[.:])\s", corpo, maxsplit=1)
    texto = frase[0].strip()
    if len(frase) > 1 and frase[1].strip():
        texto += " …"
    return texto


def montar_markdown(constantes: list[dict], valores: dict) -> str:
    linhas = [
        "# BR Port — os números da Fase 1",
        "",
        "> **ARQUIVO GERADO. Não edite à mão.**",
        "> Sai de `brport_vs/autoload/GameState.gd` por",
        "> `python3 tools/gerar_tabela_numeros.py`, e o CI reprova o push se a",
        "> versão daqui não bater com a que o gerador produz.",
        "",
        "Esta tabela existe porque os números do jogo viviam em dois lugares — o",
        "GDD e as constantes `# TUNING:` — e **já divergiram uma vez**. O modelo",
        "da Fase 1 no GDD acumulava R$1.480 contra uma parcela de R$8.000, e o",
        "erro só apareceu depois do primeiro playtest humano",
        "(`BR_Port_GDD_V7_ERRATA_ECONOMIA.md`). Aqui há uma fonte só: o código.",
        "",
        "A coluna **Fonte** diz de onde o número vem:",
        "",
        "| Fonte | O que significa |",
        "|---|---|",
        "| `GDD 7` | Está escrito no GDD. Mudar aqui é divergir do documento congelado |",
        "| `TUNING` | Escolha de balanceamento, medida em `simular_balanceamento.gd` |",
        "| `TUNING (GDD)` | Cadência não fechada no GDD, calibrada por medição |",
        "| `Protótipo` | Veio do protótipo HTML já validado (Playtest V3) |",
        "| `regra` | Regra do jogo, não número de balanceamento |",
        "",
        "**Mexeu num `TUNING`? Meça.** `simular_balanceamento.gd -- 600` — e 600",
        "não é exagero: as 30 partidas que o CI roda têm margem de ±18 pontos e",
        "já foram lidas como regressão de balanceamento uma vez.",
        "",
    ]

    por_secao: dict[str, list[dict]] = {}
    ordem_secoes: list[str] = []
    for c in constantes:
        if valores.get(c["nome"]) is None:
            continue                                  # ESTRUTURAS tem tabela própria
        if c["secao"] not in por_secao:
            por_secao[c["secao"]] = []
            ordem_secoes.append(c["secao"])
        por_secao[c["secao"]].append(c)

    for secao in ordem_secoes:
        linhas += ["## %s" % secao, "",
                   "| Constante | Valor | Fonte | Por quê | Onde |",
                   "|---|---:|---|---|---|"]
        for c in por_secao[secao]:
            linhas.append("| `%s` | %s | %s | %s | `GameState.gd:%d` |" % (
                c["nome"], formatar(valores[c["nome"]]), classificar(c),
                nota(c), c["linha"]))
        linhas.append("")

    est = next((c for c in constantes if c["nome"] == "ESTRUTURAS"), None)
    if est is not None:
        linhas += [
            "## Estruturas — o que o jogador compra",
            "",
            "Preços são `TUNING`, medidos e não estimados. A regra que os governa é",
            "**proporção, não escala**: a infraestrutura custa DEZENAS de barcos. Um",
            "píer a R$400 contra um barco de R$80–300 fazia UM barco comprar um píer,",
            "e decidir onde gastar não valia nada.",
            "",
            "| Estrutura | Custo | Efeito | Exige |",
            "|---|---:|---|---|",
        ]
        for _id, dados in sorted(ESTRUTURAS_LIDAS.items(), key=lambda kv: kv[1]["ordem"]):
            linhas.append("| %s | R$ %s | %s | %s |" % (
                dados["nome"], formatar(dados["custo"]), dados["desc"],
                dados["requer"] or "—"))
        linhas.append("")

    cls = next((c for c in constantes if c["nome"] == "CLASSES_DE_NAVIO"), None)
    if cls is not None:
        linhas += [
            "## Classes de navio — o que o porto consegue receber",
            "",
            "O `nivel` é o do PORTO, e é o MENOR entre o do píer e o do guindaste:",
            "não adianta ter onde encostar sem ter com que descarregar. Um porto em",
            "ruínas é nível 1 e só recebe pesqueiro; o nível 3 exige o cais reforçado,",
            "que já exige o pórtico pela cadeia de `requer`.",
            "",
            "Os `turnos` são a operação SEM pórtico — ele corta um. Os 3 do longo",
            "curso nunca chegam a jogar-se, porque a classe só existe no nível 3 e o",
            "nível 3 exige o pórtico.",
            "",
            "| Classe | Nível | Valor | Peso | Turnos | Motivos |",
            "|---|---:|---|---:|---:|---|",
        ]
        for _id, dados in CLASSES_LIDAS.items():
            motivos = ", ".join(
                "%s %d" % (nome, int(peso))
                for nome, peso in dados["motivos"].items())
            linhas.append("| %s | %d | R$ %s–%s | %d | %d | %s |" % (
                dados["nome"], int(dados["nivel"]),
                formatar(int(dados["valor_min"])), formatar(int(dados["valor_max"])),
                int(dados["peso"]), int(dados["turnos"]), motivos))
        linhas.append("")

    mot = next((c for c in constantes if c["nome"] == "MOTIVOS"), None)
    if mot is not None:
        linhas += [
            "## Motivos de escala — por que o navio veio",
            "",
            "O efeito é sempre o da ESTRUTURA a que o motivo está preso, nunca do",
            "motivo sozinho: um motivo que pagasse mais por si seria só outro sorteio",
            "de valor com um nome por cima.",
            "Os pesos de sorteio de cada motivo estão na tabela das CLASSES, logo",
            "acima: a pergunta que o jogo faz é \"que carga traz este navio\".",
            "",
            "| Motivo | Estrutura | Bónus | Turno extra |",
            "|---|---|---:|---:|",
        ]
        for _id, dados in MOTIVOS_LIDOS.items():
            bonus = float(dados["bonus"])
            linhas.append("| %s | %s | %s | %s |" % (
                dados["nome"], dados["estrutura"] or "—",
                ("+%d%%" % round(bonus * 100)) if bonus > 0 else "—",
                ("+%d" % int(dados["turnos_extra"])) if int(dados["turnos_extra"]) else "—"))
        linhas.append("")

    linhas += [
        "---",
        "",
        "*BR Port · gerado de `brport_vs/autoload/GameState.gd` por",
        "`tools/gerar_tabela_numeros.py` · item A2 do Plano v3.*",
        "",
    ]
    return "\n".join(linhas)


ESTRUTURAS_LIDAS: dict = {}
MOTIVOS_LIDOS: dict = {}
CLASSES_LIDAS: dict = {}


def ler_estruturas(dump: dict) -> None:
    """As ESTRUTURAS e os MOTIVOS saem do despejo do Godot, não do parser: são
    literais aninhados, e reimplementar aqui um leitor de dicionário GDScript
    seria um segundo parser para manter — exatamente a fonte dupla que este
    script existe para eliminar.

    ⚠️ E TÊM DE TER TABELA PRÓPRIA, senão somem. `avaliar()` devolve None para
    literal composto e `montar_markdown()` salta o que é None — um dicionário
    novo entraria no GameState, passaria a conferência contra o Godot (que
    ignora os None) e nunca apareceria na tabela. É o gerador silencioso que o
    cabeçalho deste arquivo descreve, só que pelo outro lado.
    """
    ESTRUTURAS_LIDAS.clear()
    ESTRUTURAS_LIDAS.update(dump.get("ESTRUTURAS", {}))
    MOTIVOS_LIDOS.clear()
    MOTIVOS_LIDOS.update(dump.get("MOTIVOS", {}))
    CLASSES_LIDAS.clear()
    CLASSES_LIDAS.update(dump.get("CLASSES_DE_NAVIO", {}))


def conferir_contra_godot(valores: dict, dump: dict) -> list[str]:
    """Cruza a leitura de texto com as constantes avaliadas pelo Godot."""
    queixas: list[str] = []
    for nome, esperado in dump.items():
        if nome not in valores:
            queixas.append(
                "o Godot tem `%s` e o parser não a viu — ela sumiria da tabela "
                "em silêncio" % nome)
            continue
        lido = valores[nome]
        if lido is None:
            continue                                  # composto, conferido à parte
        if isinstance(esperado, float) or isinstance(lido, float):
            if abs(float(esperado) - float(lido)) > 1e-9:
                queixas.append("`%s`: o parser leu %r, o Godot avalia %r"
                               % (nome, lido, esperado))
        elif esperado != lido:
            queixas.append("`%s`: o parser leu %r, o Godot avalia %r"
                           % (nome, lido, esperado))
    for nome in valores:
        if nome not in dump:
            queixas.append("`%s` está na tabela e não existe no Godot" % nome)
    return queixas


def main() -> int:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--conferir", action="store_true",
                   help="não escreve: reprova se a tabela versionada estiver velha")
    p.add_argument("--contra-godot", metavar="JSON",
                   help="despejo de brport_vs/tools/despejar_constantes.gd")
    p.add_argument("--saida", default=str(SAIDA))
    args = p.parse_args()

    try:
        constantes = ler_constantes(FONTE)
    except ErroDeLeitura as e:
        print("ERRO ao ler %s: %s" % (FONTE, e), file=sys.stderr)
        return 2

    valores: dict = {}
    for c in constantes:
        try:
            valores[c["nome"]] = avaliar(c["valor_txt"], valores)
        except ErroDeLeitura as e:
            print("ERRO em %s (linha %d): %s" % (c["nome"], c["linha"], e),
                  file=sys.stderr)
            return 2

    if args.contra_godot:
        dump = json.loads(Path(args.contra_godot).read_text(encoding="utf-8"))
        ler_estruturas(dump)
        queixas = conferir_contra_godot(valores, dump)
        if queixas:
            print("A leitura de texto NÃO bate com o que o Godot avalia:",
                  file=sys.stderr)
            for q in queixas:
                print("  · %s" % q, file=sys.stderr)
            return 3
    elif not ESTRUTURAS_LIDAS:
        print("ERRO: --contra-godot é obrigatório — sem o despejo do Godot não há "
              "como conferir a leitura nem montar a tabela de estruturas.",
              file=sys.stderr)
        return 2

    texto = montar_markdown(constantes, valores)
    destino = Path(args.saida)

    if args.conferir:
        atual = destino.read_text(encoding="utf-8") if destino.exists() else ""
        if atual != texto:
            print("A tabela versionada está velha: %s" % destino, file=sys.stderr)
            print("Regere com: python3 tools/gerar_tabela_numeros.py", file=sys.stderr)
            return 1
        print("TABELA OK — %s está em dia (%d constantes)" % (destino.name, len(valores)))
        return 0

    destino.parent.mkdir(parents=True, exist_ok=True)
    destino.write_text(texto, encoding="utf-8")
    print("TABELA OK — %s escrito (%d constantes)" % (destino.name, len(valores)))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
