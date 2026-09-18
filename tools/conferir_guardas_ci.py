#!/usr/bin/env python3
"""Confere que todo passo de CI que roda `--script` preserva a saída E a varre.

O Godot ENCERRA COM 0 depois de um erro — é a lição de 07/09, e está no
`CLAUDE.md` desde então. Por isso cada passo que roda um `--script` tem de
fazer três coisas, e não duas:

  1. preservar a saída (`2>&1 | tee arquivo`), senão não há o que inspecionar;
  2. exigir o MARCADOR de sucesso do que correu (`TODOS OS TESTES PASSARAM`,
     `DESIGN OK`, `=== Leitura ===`…), porque o código de saída mente;
  3. exigir a AUSÊNCIA DE ERRO no mesmo arquivo, porque o marcador também
     mente: ele diz que a ferramenta chegou ao fim, não que ela não se queixou
     pelo caminho.

O ponto 3 existia em seis passos e faltava em cinco, medido em 18/09: "Gravar
partidas", "Conferir que a tabela de números está em dia" e "Conferir o
simulador de balanceamento" no `testes.yml`, mais os dois do
`balanceamento.yml`. Nenhum deles é menos `--script` do que os outros. Esta
ferramenta existe para que o passo SEGUINTE — o que ainda não foi escrito —
não nasça sem a pergunta.

⚠️ O PADRÃO DA GUARDA DE ERRO É ESTREITO DE PROPÓSITO, e não `ERROR`. Medido
no mesmo dia, em corridas VERDES: cinco das seis suítes encerram com
`ERROR: 1 resources still in use at exit`, o simulador de 600 partidas também,
e o `teste_fumaca` imprime ainda um erro de JSON DE PROPÓSITO — é o save
inválido que ele injeta para provar que o jogo o recusa. Uma guarda por
`ERROR` deixaria o CI vermelho em cinco passos verdes. E o prefixo não separa
as classes: numa sonda do mesmo dia, `push_error()` sai como `ERROR:` e não
como `USER ERROR:`. Quem separa é a ORIGEM, escrita na linha `at:` — só quem
chamou `push_error` a traz. É esse par de padrões que esta ferramenta exige.

⚠️ E A VARREDURA CORTA OS COMENTÁRIOS ANTES DE PROCURAR. Os comentários que
explicam a guarda CITAM o padrão dela, palavra por palavra: sem este corte,
um passo sem guarda nenhuma passaria por guardado só por ter o comentário
colado de um vizinho. É a armadilha que o `CLAUDE.md` já regista para a
varredura de falas — o comentário que explica a armadilha satisfaz a busca.

Uso:
  python3 tools/conferir_guardas_ci.py

Espera `GUARDAS OK`.
"""

import re
import sys
from pathlib import Path

WORKFLOWS = Path(".github/workflows")

# A marca que distingue a queixa do PROJETO do barulho do MOTOR. Não inclui o
# parêntese de propósito: o que se confere aqui é que o passo PERGUNTA pela
# origem, não como ele escreveu a expressão regular.
MARCA_ERRO = "at: push_error"
MARCA_SCRIPT = "SCRIPT ERROR"


def sem_comentarios(texto: str) -> str:
    """Tira as linhas de comentário — de YAML e de shell, que aqui são iguais."""
    return "\n".join(
        linha for linha in texto.splitlines() if not linha.lstrip().startswith("#")
    )


def passos_do_arquivo(caminho: Path) -> list[tuple[str, str, str]]:
    """Devolve (job, nome do passo, corpo) para cada passo do workflow.

    Parser de LINHAS, sem dependência nenhuma: o `pyyaml` está neste contêiner
    e não se pode provar que está no runner, e um portão que não arranca é um
    vermelho pela razão errada. A indentação destes três arquivos é fixa —
    job a duas colunas, passo a seis — e a ferramenta RECUSA-SE a passar se
    deixar de a entender, em vez de devolver uma lista vazia contente.
    """
    job_re = re.compile(r"^  ([A-Za-z_][\w-]*):\s*$")
    passo_re = re.compile(r"^      - name: (.*)$")

    passos: list[tuple[str, str, str]] = []
    job = ""
    nome = ""
    corpo: list[str] = []

    def fechar() -> None:
        if nome:
            passos.append((job, nome, "\n".join(corpo)))

    for linha in caminho.read_text(encoding="utf-8").splitlines():
        m_job = job_re.match(linha)
        if m_job:
            fechar()
            nome, corpo = "", []
            job = m_job.group(1)
            continue
        m_passo = passo_re.match(linha)
        if m_passo:
            fechar()
            nome, corpo = m_passo.group(1).strip(), []
            continue
        if nome:
            corpo.append(linha)
    fechar()
    return passos


def conferir(caminho: Path) -> list[str]:
    passos = passos_do_arquivo(caminho)
    if not passos:
        return [
            f"{caminho.name}: não consegui ler passo nenhum — o parser deixou de "
            "entender este arquivo, e uma lista vazia não é uma aprovação."
        ]

    queixas: list[str] = []
    # Por JOB, e não por passo: a guarda pode viver no passo seguinte, e vive —
    # "Rodar os testes" é varrido pelo passo "Nenhuma suíte pode imprimir
    # SCRIPT ERROR", logo abaixo dele. O que interessa é o ARQUIVO de saída
    # ser inspecionado em algum sítio do mesmo job.
    for job in dict.fromkeys(j for j, _, _ in passos):
        do_job = [(n, c) for j, n, c in passos if j == job]
        texto_limpo = sem_comentarios("\n".join(c for _, c in do_job))
        linhas = texto_limpo.splitlines()

        for nome, corpo in do_job:
            limpo = sem_comentarios(corpo)
            if "--script" not in limpo:
                continue
            # ⚠️ O `tee` TEM DE SER O DO PRÓPRIO `--script`, e não um qualquer
            # do passo. A primeira versão desta ferramenta pedia guarda de erro
            # para TODO arquivo tee'ado num passo que rodasse `--script`, e
            # reprovou o passo "Gravar partidas" por causa de `/tmp/leitura.txt`
            # — que é a saída do leitor em PYTHON, onde uma exceção sai com
            # código != 0 e o `set -e` apanha. Sair com zero depois de um erro
            # é problema do Godot e só dele; exigir a guarda noutra linguagem
            # seria um validador a reprovar o que está certo, que se gasta
            # depressa. Juntar as continuações com `\` põe cada cano numa linha
            # lógica, e aí `--script` e `| tee` ou estão no mesmo comando ou
            # não têm nada a ver um com o outro.
            colapsado = re.sub(r"\\\n\s*", " ", limpo)
            arquivos = [
                alvo
                for cano in colapsado.splitlines()
                if "--script" in cano
                for alvo in re.findall(r"\|\s*tee\s+(\S+)", cano)
            ]
            if not arquivos:
                queixas.append(
                    f"{caminho.name} · {job} · «{nome}»: roda --script e não "
                    "preserva a saída (falta `2>&1 | tee arquivo`)."
                )
                continue
            for arquivo in arquivos:
                relevantes = [l for l in linhas if "grep" in l and arquivo in l]
                tem_erro = any(MARCA_ERRO in l for l in relevantes)
                tem_marcador = any(
                    "grep -q" in l and MARCA_ERRO not in l for l in relevantes
                )
                if not tem_marcador:
                    queixas.append(
                        f"{caminho.name} · {job} · «{nome}»: nada exige um "
                        f"marcador de sucesso em {arquivo} — o código de saída "
                        "do Godot não serve."
                    )
                if not tem_erro:
                    queixas.append(
                        f"{caminho.name} · {job} · «{nome}»: nada varre "
                        f"{arquivo} à procura de erro. A ferramenta pode ter "
                        "imprimido o marcador depois de falhar."
                    )
    return queixas


def main() -> int:
    if not WORKFLOWS.is_dir():
        print(f"não achei {WORKFLOWS} — rode da raiz do repositório.", file=sys.stderr)
        return 1

    arquivos = sorted(WORKFLOWS.glob("*.yml"))
    if not arquivos:
        print(f"não há workflow nenhum em {WORKFLOWS}.", file=sys.stderr)
        return 1

    queixas: list[str] = []
    total_script = 0
    for caminho in arquivos:
        queixas += conferir(caminho)
        passos = passos_do_arquivo(caminho)
        n = sum(1 for _, _, c in passos if "--script" in sem_comentarios(c))
        total_script += n
        print(f"  {caminho.name}: {len(passos)} passo(s), {n} com --script")

    if queixas:
        print()
        for q in queixas:
            print(f"::error::{q}")
        print(f"\n{len(queixas)} queixa(s) — veja as linhas acima.", file=sys.stderr)
        return 1

    # AMOSTRA VAZIA É REPROVAÇÃO, e vem DEPOIS das queixas de propósito: quando
    # o parser deixa de entender os arquivos, são elas que dizem qual deles.
    # Se um dia a indentação mudar e `--script` não aparecer em lado nenhum,
    # esta ferramenta imprimiria `GUARDAS OK` sem ter conferido coisa nenhuma —
    # que é o pior resultado possível num portão, porque some sem deixar rasto.
    if total_script == 0:
        print(
            "não achei passo nenhum com --script nos workflows. Ou eles "
            "deixaram de existir, ou esta ferramenta deixou de os entender; "
            "nos dois casos ela não tem o que aprovar.",
            file=sys.stderr,
        )
        return 1

    print(f"\nGUARDAS OK — {total_script} passo(s) com --script, todos "
          "preservados, com marcador e varridos.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
