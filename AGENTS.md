# BR Port — instruções para o Codex

Jogo mobile de gestão de porto em Godot 4 + GDScript, em português do Brasil.
**Este repositório tem dois agentes a trabalhar nele**: o Claude Code, por onde
o Bruno conduz o projeto no dia a dia, e o Codex, que contribui com tarefas
que o Bruno lhe entrega. As regras são as mesmas para os dois.

## 1. As regras vivem no `CLAUDE.md` — leia-o inteiro antes de mudar qualquer coisa

O nome é do outro agente, mas o conteúdo é do projeto: como correr o Godot, as
seis suítes e a linha final que cada uma tem de imprimir, a projeção
isométrica, o save, a arte, a narrativa, a interface e o estilo de código.
**Onde este arquivo e o `CLAUDE.md` parecerem divergir, vale o `CLAUDE.md`.**

Para saber onde o jogo está e o que vem a seguir, são dois documentos:
`docs/ESTADO_DO_PROJETO.md` (o agora) e a §7 de
`docs/design/BR_Port_Plano_v3_Claude_Code.md` (o rumo). O porquê de cada escolha
está em `docs/decisoes/NNN-*.md`, uma por arquivo — não reabra uma decisão
registada sem o Bruno pedir.

## 2. Como os dois agentes não se atropelam

- **Faça só a tarefa que o Bruno entregou.** A ordem das frentes é dele.
- **Branch `codex/<tema>`**, a partir da `main` do GitHub, e entrega por PR.
  Nunca empurre para uma branch `claude/*`, nem para a `main`.
- **Antes de começar, veja os PRs abertos.** Se um PR do Claude Code já mexe
  num arquivo de que a tarefa precisa, diga-o ao Bruno em vez de o editar em
  paralelo. São de alto conflito: `brport_vs/scenes/Main.tscn`,
  `brport_vs/scripts/Main.gd`, `brport_vs/autoload/GameState.gd`,
  `tools/gerar_mapa_iso.py`, `tools/gerar_props_iso.py` e os mapas SVG.
- **Uma tarefa por PR**, com o que mudou e porquê; se algo foi medido, o
  número.
- **Decisão nova** entra em `docs/decisoes/` com o próximo número livre —
  confira a pasta na `main` antes de escolher, que dois agentes a numerar em
  paralelo já deram números repetidos.

## 3. Antes de abrir o PR

- As seis suítes do Godot, com a versão de `.godot-version`, e a linha final
  de cada uma — o código de saída sozinho não prova nada (o `CLAUDE.md` diz
  porquê). A lista viva está em `.github/workflows/testes.yml`.
- `python3 tools/conferir_docs.py`, que espera `DOCS OK`, se mexeu em
  documento.
- Se mexeu no visual: uma captura do jogo, olhada (`tools/capturar_evidencia.sh`).
- Mudou o jogo? Atualize o `docs/ESTADO_DO_PROJETO.md` (tem teto de tamanho;
  o conferidor avisa). O ritual completo de fecho está em
  `.claude/skills/fechar-sessao/SKILL.md`, e vale ler mesmo não sendo o Claude.

## 4. Convenções

- Código, comentários, nomes de nó e documentos em **português**; mensagens de
  commit e PR em **inglês**.
- Comentário explica **por que**, e conta o que se tentou antes — siga o
  estilo do arquivo que estiver a editar.
- **Arte:** prop do mapa nunca sai de gerador de imagem, e todo material de
  arte de fora passa por `art_lab/` — a porta é `art_lab/README.md`, com o
  caminho de uma peça até ao jogo.
- Não mexa sem pedido explícito em: constantes `# TUNING:`, `SAVE_VERSION`,
  projeção, enquadramento, viewport ou sementes do jogo.
