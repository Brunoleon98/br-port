#!/usr/bin/env python3
"""Confere que toda cor de INTERFACE vem do tema — ou está declarada como exceção.

O `CLAUDE.md` diz, na seção Interface: *"O tema (`ui/tema_brport.tres`) é o
ponto único de estilo. Script não pinta cor na mão."* Até 21/09 nada perguntava
isso, e a regra vivia só na prosa. Esta ferramenta é a pergunta.

⚠️ O QUE FEZ ESTE PORTÃO EXISTIR NÃO FOI UM DEFEITO DE CONTRASTE. Em 20/09 o
R6 mediu 19 estados e 214 textos e levou as reprovações a zero — e no MESMO
commit em que migrou três overrides para o tema, ACRESCENTOU um quarto
(`UpgradePanel.gd`, o motivo do bloqueio que saiu de dentro do botão
desligado). Ninguém viu: o briefing seguinte anunciou "ficaram 18", que é
21 − 3 feito de cabeça, e o número medido no HEAD era 19. Um portão de
CONTRASTE não podia apanhar isso, porque a cor nova passa o AA com folga. São
duas perguntas diferentes, e esta é a segunda: *de onde veio esta cor?*

⚠️ E O INVENTÁRIO EM RUNTIME TAMBÉM NÃO PODIA. O `medir_contraste_ui.gd` sabe
responder "override, variação ou tema" por texto, e é ele que prova o
contraste — mas só vê o que o percurso ALCANÇA. Medido em 21/09, dos sítios
que pintam cor à mão o percurso de 19 estados não chega ao dia passado do
calendário (abre no dia 1), nem à estrutura já construída, nem à doca sob
oferta do rival. O `COR_PASSADO` que o briefing entregou como caso de teste
nunca esteve nos 214 textos. Percurso responde pelo que se VÊ; arquivo responde
pelo que EXISTE, e é preciso ter os dois.

────────────────────────────────────────────────────────────────────────────
A GRANULARIDADE DA EXCEÇÃO, e por que não é por arquivo nem por linha

A ficha da §7.1 manda: *"Exceção exata por propriedade/local, com
justificativa; não liberar arquivo inteiro."*

  • Por ARQUIVO não, e a ficha já o proíbe — foi assim que a chamada nova do
    `UpgradePanel.gd` entrou sem ninguém ver: o arquivo já tinha outras.
  • Por LINHA não. Número de linha envelhece calado a cada edição acima dele,
    e este projeto tem a regra escrita para o caso irmão: *"número em pixel
    escrito à mão envelhece calado quando o que ele descreve muda de tamanho"*.
  • A chave é o TRIO **(arquivo, receptor, propriedade)**, e o valor traz as
    CORES permitidas e a CONTAGEM de chamadas.

⚠️ A CONTAGEM ENTRA NA CHAVE PORQUE O MUTANTE É "nova chamada no arquivo que
já tinha outra exceção". Sem ela, a segunda chamada com a mesma forma — mesmo
nó, mesma propriedade, mesma cor — passaria por declarada. É a mesma regra da
folha de contato que reprova ao transbordar, e a do percurso do D33 que declara
quantos estados tem.

⚠️ E A COR RESOLVIDA ENTRA JUNTO COM O NOME. Declarar `COR_AVISO` e mais nada
deixaria o VALOR dela livre: alguém trocaria o `Color(...)` da `const` e o
portão diria verde. Onde a `const` está no mesmo arquivo, o registro guarda
`NOME = Color(r, g, b)`, e mexer no valor reprova.

────────────────────────────────────────────────────────────────────────────
ONDE ESTE PORTÃO NÃO ENTRA, e como a fronteira se decide

Duas fronteiras, e nenhuma das duas é uma lista de arquivos escrita à mão.

1. **O ESCOPO SAI DO `export_presets.cfg`.** O que o jogo não exporta não é
   interface do jogo: `tools/*` (as folhas de contato e as réguas),
   `tests/*`, `scripts/validation/*`, `scenes/proto/*` e `scenes/tests/*` já
   estão no `exclude_filter`, e é de lá que a lista sai. Escrevê-la aqui seria
   a armadilha que o `CLAUDE.md` regista: *"se está escrito que sai de algum
   lado, faça-o sair de lá"*. Os dois presets têm de CONCORDAR, senão reprova —
   um filtro que divergisse entre Android e Web daria escopos diferentes ao
   mesmo portão.

2. **A COR TEM DE ENTRAR NO SISTEMA DE TEMA.** A ficha manda o scanner *"não
   acusar cores de mapas/arte procedural"*, e quem separa não é o arquivo: é a
   PROPRIEDADE, que o Godot define. `modulate`, `self_modulate`, `ColorRect.color`
   e os `draw_*` são pintura — o piscar da fauna, o realce do píer, o escurecer
   por trás de um modal. Nenhum deles passa pelo tema, e nenhum deles é
   chrome de interface. O que passa pelo tema são três formas, e só elas:
   `add_theme_color_override`, `theme_override_colors/*` numa cena, e uma
   propriedade de cor de `StyleBox` (`bg_color`, `border_color`, `shadow_color`
   — a lista é do Godot, não deste projeto).

   Medido em 21/09: no escopo exportado há 23 literais `Color(` em `.gd`. Esta
   regra deixa 12 de fora sem citar arquivo nenhum — os oito da `Fauna.gd`, o
   realce do `Dock.gd` e os três escurecimentos de modal — e não precisa de
   saber que eles existem.

────────────────────────────────────────────────────────────────────────────
E A VARIAÇÃO QUE NÃO EXISTE FALHA CALADA

`theme_type_variation = "RotuloApio"` não dá erro nenhum no Godot: a variação
não é encontrada, o nó cai no tipo base e o texto sai com a cor errada. É a
irmã da regra do `project.godot` — *"valor de Godot 3 numa chave de Godot 4
não dá erro, dá outra coisa"*. Por isso toda variação usada, em código ou em
cena, tem de estar declarada no tema.

Uso:
  python3 tools/conferir_escopo_ui.py

Espera `ESCOPO UI OK`. Reprova com código 1 e a lista do que não bate.
"""

import json
import re
import sys
from pathlib import Path

JOGO = Path("brport_vs")
PRESETS = JOGO / "export_presets.cfg"
TEMA = JOGO / "ui" / "tema_brport.tres"
REGISTRO = Path("tools") / "excecoes_cor_ui.json"

# As propriedades de cor de um StyleBoxFlat. A lista é do Godot; o que este
# projeto escolhe é PERGUNTAR por elas, não quais são.
PROPS_STYLEBOX = ("bg_color", "border_color", "shadow_color")

# As duas fugas que dariam a volta a um scanner que só procurasse a chamada
# direta. O Godot aceita as duas, e nenhuma delas aparece hoje no projeto —
# a guarda existe para a que ainda não foi escrita.
FUGAS = (
    re.compile(r"""\.set\s*\(\s*["']theme_override_"""),
    re.compile(r"""\.call(?:v|_deferred)?\s*\(\s*["']add_theme_\w*color"""),
)


class Reprova(Exception):
    pass


def sem_comentarios_gd(texto: str) -> list:
    """Devolve (nº da linha, linha) das linhas que NÃO são comentário.

    ⚠️ E O CORTE É PELO INÍCIO DA LINHA, nunca pelo `#` onde quer que esteja:
    o `DocaCartao.gd` escreve `var texto := "#%d" % ...`, e um corte por
    ocorrência partiria a linha ao meio. Comentário aqui é linha que COMEÇA
    por `#` depois da indentação — é o mesmo corte do `conferir_guardas_ci.py`,
    e ele existe pela mesma razão: os comentários deste repositório CITAM o
    que a guarda procura, palavra por palavra. Sem o corte, o comentário que
    explica a armadilha satisfaz a busca que a caça.
    """
    return [
        (i, l)
        for i, l in enumerate(texto.splitlines(), 1)
        if not l.lstrip().startswith("#")
    ]


def escopo_excluido() -> list:
    """Os padrões de exclusão, LIDOS do export_presets.cfg — e não escritos aqui."""
    if not PRESETS.is_file():
        raise Reprova(f"{PRESETS} não existe — o escopo sai de lá")
    filtros = re.findall(
        r'^exclude_filter\s*=\s*"([^"]*)"', PRESETS.read_text(encoding="utf-8"), re.M
    )
    if not filtros:
        raise Reprova(f"{PRESETS} não declara `exclude_filter` — sem ele não há escopo")
    normal = {tuple(sorted(p.strip() for p in f.split(",") if p.strip())) for f in filtros}
    if len(normal) != 1:
        raise Reprova(
            "os presets de export discordam no `exclude_filter` — o portão teria "
            "escopos diferentes conforme a plataforma:\n    "
            + "\n    ".join(repr(sorted(n)) for n in normal)
        )
    return list(next(iter(normal)))


def no_escopo(rel: str, excluidos: list) -> bool:
    for padrao in excluidos:
        alvo = padrao[:-1] if padrao.endswith("*") else padrao
        if rel.startswith(alvo):
            return False
    return not rel.startswith(".godot/")


def arquivos(excluidos: list) -> list:
    saida = []
    for ext in ("*.gd", "*.tscn"):
        for p in sorted(JOGO.rglob(ext)):
            rel = p.relative_to(JOGO).as_posix()
            if no_escopo(rel, excluidos):
                saida.append((rel, p))
    return saida


def consts_do_arquivo(linhas: list) -> dict:
    """`const NOME := Color(...)` do próprio arquivo, para resolver o valor."""
    achado = {}
    for _, l in linhas:
        m = re.match(r"\s*const\s+(\w+)\s*:?=\s*(Color8?\([^)]*\))", l)
        if m:
            achado[m.group(1)] = re.sub(r"\s+", " ", m.group(2))
    return achado


def _argumentos(texto: str, inicio: int):
    """Lê a chamada a partir do `(`, equilibrando parênteses.

    ⚠️ É ASSIM QUE O MULTILINHA ENTRA, e a ficha pede-o com todas as letras.
    Um `grep` de linha não vê `add_theme_color_override("font_color",` com a
    cor na linha seguinte — e este projeto já escreve uma assim
    (`tools/folha_props.gd`, fora do escopo, mas a forma é a mesma).
    """
    nivel, i, aspas = 0, inicio, ""
    while i < len(texto):
        c = texto[i]
        if aspas:
            if c == aspas:
                aspas = ""
        elif c in "\"'":
            aspas = c
        elif c == "(":
            nivel += 1
        elif c == ")":
            nivel -= 1
            if nivel == 0:
                return texto[inicio + 1 : i], i
        i += 1
    raise Reprova("chamada a `add_theme_color_override` sem fechar parêntese")


def _partir_args(bruto: str) -> list:
    partes, nivel, atual, aspas = [], 0, "", ""
    for c in bruto:
        if aspas:
            atual += c
            if c == aspas:
                aspas = ""
            continue
        if c in "\"'":
            aspas = c
        elif c in "([{":
            nivel += 1
        elif c in ")]}":
            nivel -= 1
        elif c == "," and nivel == 0:
            partes.append(atual.strip())
            atual = ""
            continue
        atual += c
    if atual.strip():
        partes.append(atual.strip())
    return partes


def achados_gd(rel: str, texto: str) -> tuple:
    linhas = sem_comentarios_gd(texto)
    consts = consts_do_arquivo(linhas)
    limpo = "\n".join(l for _, l in linhas)
    achados, fugas = [], []

    for fuga in FUGAS:
        for m in fuga.finditer(limpo):
            fugas.append(f"{rel}: cor de tema por caminho dinâmico — {m.group(0).strip()}")

    for m in re.finditer(r"add_theme_color_override\s*\(", limpo):
        abre = limpo.index("(", m.start())
        bruto, _ = _argumentos(limpo, abre)
        args = _partir_args(bruto)
        if len(args) < 2:
            raise Reprova(f"{rel}: `add_theme_color_override` com menos de dois argumentos")
        prop = args[0].strip("\"'&")
        cor = re.sub(r"\s+", " ", args[1])
        if cor in consts:
            cor = f"{cor} = {consts[cor]}"
        # O receptor é tudo o que vem antes do ponto da chamada, na mesma
        # instrução: `porto`, ou `pronto.get_node("Texto")`. É um LOCAL e não
        # um número de linha — sobrevive a toda edição acima dele.
        antes = limpo[: m.start()].rsplit("\n", 1)[-1]
        recep = antes.rstrip().rstrip(".").strip() or "(self)"
        achados.append((rel, recep, prop, cor))

    for _, l in linhas:
        for prop in PROPS_STYLEBOX:
            m = re.search(rf"([\w\.]*)\b{prop}\s*=\s*(Color8?\([^)]*\))", l)
            if m:
                recep = m.group(1).rstrip(".") or "(local)"
                achados.append((rel, recep, prop, re.sub(r"\s+", " ", m.group(2))))
    return achados, fugas


def achados_tscn(rel: str, texto: str) -> list:
    achados, no_atual, sub_atual = [], None, None
    for l in texto.splitlines():
        m = re.match(r'\[node name="([^"]+)"(?:.*?parent="([^"]*)")?', l)
        if m:
            nome, pai = m.group(1), m.group(2)
            no_atual = nome if pai in (None, ".", "") else f"{pai}/{nome}"
            sub_atual = None
            continue
        m = re.match(r'\[sub_resource type="([^"]+)" id="([^"]+)"\]', l)
        if m:
            sub_atual = (m.group(1), m.group(2))
            no_atual = None
            continue
        if l.startswith("["):
            no_atual = sub_atual = None
            continue

        m = re.match(r"theme_override_colors/(\w+)\s*=\s*(Color8?\([^)]*\))", l)
        if m and no_atual:
            achados.append((rel, no_atual, m.group(1), re.sub(r"\s+", " ", m.group(2))))
            continue
        if sub_atual and sub_atual[0].startswith("StyleBox"):
            for prop in PROPS_STYLEBOX:
                m = re.match(rf"{prop}\s*=\s*(Color8?\([^)]*\))", l)
                if m:
                    achados.append(
                        (rel, f"sub_resource:{sub_atual[1]}", prop,
                         re.sub(r"\s+", " ", m.group(1)))
                    )
    return achados


def variacoes_do_tema() -> set:
    if not TEMA.is_file():
        raise Reprova(f"{TEMA} não existe")
    return set(re.findall(r"^(\w+)/", TEMA.read_text(encoding="utf-8"), re.M))


def variacoes_usadas(escopo: list) -> list:
    usadas = []
    for rel, p in escopo:
        texto = p.read_text(encoding="utf-8")
        linhas = (
            [l for _, l in sem_comentarios_gd(texto)]
            if rel.endswith(".gd")
            else texto.splitlines()
        )
        for i, l in enumerate(linhas, 1):
            for m in re.finditer(r'theme_type_variation\s*=\s*&?"([^"]*)"', l):
                if m.group(1):
                    usadas.append((rel, i, m.group(1)))
    return usadas


def main() -> int:
    try:
        excluidos = escopo_excluido()
        escopo = arquivos(excluidos)

        achados, fugas = [], []
        for rel, p in escopo:
            texto = p.read_text(encoding="utf-8")
            if rel.endswith(".gd"):
                a, f = achados_gd(rel, texto)
                achados += a
                fugas += f
            else:
                achados += achados_tscn(rel, texto)

        if not REGISTRO.is_file():
            raise Reprova(f"{REGISTRO} não existe — sem registro não há exceção declarada")
        dados = json.loads(REGISTRO.read_text(encoding="utf-8"))

        # ── medido contra declarado ──────────────────────────────────────────
        medido = {}
        for rel, recep, prop, cor in achados:
            medido.setdefault((rel, recep, prop), []).append(cor)

        declarado = {}
        for e in dados["excecoes"]:
            chave = (e["arquivo"], e["receptor"], e["propriedade"])
            if chave in declarado:
                raise Reprova(f"registro com entrada repetida: {chave}")
            if not str(e.get("justificativa", "")).strip():
                raise Reprova(f"exceção sem justificativa: {chave}")
            declarado[chave] = e

        erros = list(fugas)
        for chave, cores in sorted(medido.items()):
            e = declarado.get(chave)
            if e is None:
                erros.append(
                    f"{chave[0]}: cor pintada à mão fora do registro — "
                    f"`{chave[1]}` / `{chave[2]}` ({len(cores)}x): {sorted(set(cores))}"
                )
                continue
            if len(cores) != e["chamadas"]:
                erros.append(
                    f"{chave[0]}: `{chave[1]}` / `{chave[2]}` tem {len(cores)} "
                    f"chamada(s); o registro declara {e['chamadas']}"
                )
            if sorted(set(cores)) != sorted(set(e["cores"])):
                erros.append(
                    f"{chave[0]}: `{chave[1]}` / `{chave[2]}` pinta {sorted(set(cores))}; "
                    f"o registro declara {sorted(set(e['cores']))}"
                )
        for chave in sorted(declarado):
            if chave not in medido:
                erros.append(
                    f"{chave[0]}: exceção declarada que já não existe no código — "
                    f"`{chave[1]}` / `{chave[2]}`. Registro que envelhece mente igual."
                )

        # ── variação que não existe falha calada ─────────────────────────────
        do_tema = variacoes_do_tema()
        for rel, i, nome in variacoes_usadas(escopo):
            if nome not in do_tema:
                erros.append(
                    f"{rel}:{i}: `theme_type_variation = \"{nome}\"` não existe no tema — "
                    "o Godot não reclama, cai no tipo base e sai com a cor errada"
                )

        print(f"  escopo: {len(escopo)} arquivo(s), do `exclude_filter` do export")
        print(f"  cores de tema pintadas à mão: {len(achados)} em {len(medido)} local(is)")
        print(f"  exceções declaradas: {len(declarado)}")
        if erros:
            print()
            for e in erros:
                print(f"  ✗ {e}")
            print(f"\nESCOPO UI REPROVA — {len(erros)} problema(s)")
            return 1
        print("\nESCOPO UI OK")
        return 0
    except Reprova as e:
        print(f"  ✗ {e}")
        print("\nESCOPO UI REPROVA")
        return 1


if __name__ == "__main__":
    sys.exit(main())
