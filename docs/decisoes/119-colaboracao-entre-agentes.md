# 119 — Colaboração entre agentes: o pré-PR que olha para os outros ramos

**16/10/2026.** Mesma branch e base da `118`. Pedido do Bruno: *antes de criar
o PR, ver o que o Codex fez; e como esta situação vai ser comum, com outras
IAs no projeto, melhorar a colaboração para evitar erros e problemas.*

## O que aconteceu numa manhã

Entre o fecho de 15/10 e a manhã de 16/10, o Codex fundiu o PR #133 (o
cancelamento, save 18) e abriu o #134, e esta branch esperava sem PR. Ao
juntar a `main`:

- **a decisão `111` repetiu-se** — a desta branch (o catálogo de mutantes) e
  a do Codex (o cancelamento), e o #134 já ia na 116;
- **o briefing `2026-10-15b` foi criado pelos dois**, com o mesmo nome;
- **o `ESTADO_DO_PROJETO.md` e o índice do arquivo conflitaram**, como
  conflitam sempre que duas sessões fecham;
- e uma quarta, mais calada: **o T24 do Codex imprime `FAIL T24:` sem recuo**,
  e o executor de mutantes da `117` só lia falhas recuadas — um defeito
  apanhado pelo T24 aparecia só pela linha agregada.

Nenhuma destas é descuido de ninguém: são **espaços partilhados** (números,
nomes, documentos de fecho, formatos de saída) que cada agente escolhe sem ver
o que o outro está a escolher. O `conferir_docs.py` já reprova o número
repetido — mas no CI, e só contra o que já foi fundido.

## A pesquisa

Pela busca, páginas não lidas (`063`): os guias de prática apontam os mesmos
pontos — **arquivos-registo partilhados são o ponto quente**, conflitos de
texto resolvidos à pressa escondem erros de lógica, e duas mudanças que passam
cada uma sozinha podem quebrar juntas
([Augment](https://www.augmentcode.com/guides/how-to-run-a-multi-agent-coding-workspace),
[C# Corner](https://www.c-sharpcorner.com/article/what-happens-when-multiple-ai-coding-agents-work-on-the-same-repository));
**coordenar antes de escrever** e não só na junção
([claim plane](https://codex.danielvaughan.com/2026/07/28/claim-plane-pre-write-admission-control-parallel-coding-agents-codex-cli-changeintent-scope-promotion/));
e, do lado do GitHub, **o CI verde de um PR envelhece quando outro funde
antes** — é o que a *merge queue* e o «exigir a branch em dia» resolvem
([GitHub, merge queue](https://docs.github.com/en/enterprise-server@3.17/repositories/configuring-branches-and-merges-in-your-repository/configuring-pull-request-merges/managing-a-merge-queue)).

## O que mudou

- **`tools/conferir_colaboracao.py`**, o pré-PR. Usa o `git merge-tree`, sem
  tocar na árvore. Contra a BASE bloqueia: conflito de texto, decisão nova com
  número já usado, mutante do catálogo que a junção deixa órfão, e
  `SAVE_VERSION` mudada dos dois lados. Contra os OUTROS ramos (as cabeças dos
  PRs abertos, ou os ramos com commit nos últimos dias) avisa as mesmas
  coisas e os arquivos que os dois mexem — os de alto conflito lidos do
  `AGENTS.md`. E dá **o próximo número de decisão e o próximo nome de
  briefing livres contando todos os ramos**. Espera `COLABORACAO OK`.
- **`tools/renumerar_decisao.py`**: renumera a decisão DESTA branch e troca as
  citações **só nas linhas que ela acrescentou** — depois de juntar a `main`,
  os mesmos arquivos citam as duas `111`, e um `sed` pela árvore apagaria as
  do outro. Foi ela que fez a `111` desta branch passar a `117`. Espera
  `RENUMERACAO OK`.
- **O executor de mutantes lê `FAIL T24:`** sem recuo.
- **O padrão do Codex fica regra**: bloco de teste novo vive num arquivo
  próprio (`tests/casos_cancelamento.gd`, `tests/jogador_ao_acaso.gd`) e a
  suíte só o chama — dois agentes a acrescentar blocos deixam de editar o
  mesmo `run_tests.gd` de 3.000 linhas.
- **O protocolo**, no `AGENTS.md` (§2 e §3) e no `/fechar-sessao`: antes do
  PR, juntar a `main`, rodar o pré-PR com as cabeças dos PRs abertos, e
  renumerar pela ferramenta o que colidir.

## A prova

Num worktree descartável, com referências sintéticas:

| Cenário | O que a ferramenta disse |
|---|---|
| base com a mesma decisão, a mesma linha do `CLAUDE.md` mexida e a `SAVE_VERSION` subida dos dois lados | `BLOQUEADO`, os três |
| base que reescreve a linha de um mutante | `BLOQUEADO`, o mutante órfão |
| outro ramo com a mesma decisão, o mesmo briefing e uma linha de mutante mexida | `COLABORACAO OK` com os três avisos |

⚠️ **A primeira versão saltava a conferência dos mutantes sempre que a junção
tinha um conflito qualquer**, e o terceiro cenário mostrou o custo: o briefing
repetido calou o órfão no `GameState.gd`. Hoje só salta o alvo que está ele
próprio em conflito.

A renumeração provou-se igual: uma linha «da main» e outra «da branch» a
citar `111`; só a segunda mudou, e com o filtro de linhas tirado as duas
mudaram.

Contra o PR #134 real, depois do commit do T25 desta branch: decisões
113–116 sem colisão, nenhum mutante órfão, e **um conflito no `run_tests.gd`
que era outra colisão de nome** — o Codex criou também um T25 (a ajuda «Como
jogar», `tests/casos_como_jogar.gd`) na mesma linha. O número do bloco de
teste é o terceiro espaço partilhado, e a ferramenta passou a conferi-lo: os
rótulos novos entre aspas (`"T25: …"`) de cada ramo, contra os da sua base.
Disse T25 e só T25, entre as dezenas de blocos que os dois lados já têm.
Quem fundir em segundo renumera o seu.

## O que é do Bruno, e não de código

- **Proteger a `main` com «Require branches to be up to date before
  merging»** (Settings → Branches), ou a *merge queue*. Hoje o CI de um PR
  corre contra a `main` do momento em que correu; se outro agente fundir
  depois, o verde envelhece, e a decisão repetida só reprovaria no push da
  `main`, já fundida. Com a regra, o segundo PR tem de se pôr em dia e correr
  outra vez. (A *merge queue* pede ainda o gatilho `merge_group` nos
  workflows.)
- **Pedir ao agente que empurre cedo**: um ramo só local é invisível a
  qualquer ferramenta — foi o caso da `107`, reservada numa branch que nunca
  subiu. Um PR em rascunho aberto no início reserva o número à vista.

## O que fica de fora

- Um serviço de «reservas» ao vivo (os *leases* do Shepherd): pesado para dois
  agentes; o número livre contando os ramos empurrados resolve o mesmo, desde
  que se empurre.
- Mudar o nome dos briefings para levar o agente (um sufixo `_claude`): evitaria a
  colisão por construção, mas mexe na regra do `conferir_docs.py` sobre o
  briefing mais recente — item próprio, se o Bruno quiser.
