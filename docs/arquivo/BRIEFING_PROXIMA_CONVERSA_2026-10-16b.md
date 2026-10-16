# BR Port — testes que guardam o que aprenderam, e o pré-PR entre agentes

**16/10/2026.** Branch `claude/gracious-mendel-oiww62`, com a main `7a8ec41`
juntada (PRs #133 e #134 do Codex: cancelamento com save 18, e a ajuda «Como
jogar» com o bloco T25). Nenhum PR aberto do Codex nem ramo dele mais novo no
momento do PR. O PR desta branch foi aberto a pedido do Bruno, que é quem
funde. Sessão LATERAL — o rumo do jogo continua o dos briefings do Codex.

Quatro decisões nesta branch:

- **`117`** — o catálogo de defeitos já provados (`tools/mutantes.toml`) e o
  executor (`tools/conferir_mutantes.py`), que o job «Defeitos já provados»
  reinjeta a cada PR.
- **`118`** — o T26, o jogador ao acaso: 24 partidas com semente e
  invariantes a cada passo, com a falha reduzida à trilha mínima; e o vigia
  que impede o `run_tests` e o `teste_fumaca` de pendurar.
- **`119`** — a colaboração: `tools/conferir_colaboracao.py` (o pré-PR contra
  a base e os PRs abertos) e `tools/renumerar_decisao.py` (decisão e bloco).
- **`120`** — as provas do Codex no catálogo: sete mutantes do cancelamento e
  os seis da ajuda. O catálogo tem 58.

O que a junção com o trabalho do Codex mudou: a decisão desta branch passou
de 111 a 117; o jogador ao acaso passou de T25 a T26; o pré-PR ganhou as
conferências de bloco repetido; e as provas dele entraram no catálogo.

⚠️ Os espaços partilhados entre agentes — número de decisão, nome de
briefing, número de bloco de teste, documentos de fecho — colidem; o livre
conta-se em todos os ramos (`.claude/rules/gerais.md`; `AGENTS.md`, §2).

⚠️ Robô ao acaso sem controle de exercício passa verde sem ter jogado; leia a
linha `-> fase 2 em N de 24` do T26 (`.claude/rules/testes-e-guardas.md`, «O
jogador ao acaso»).

⚠️ Defeito descrito em prosa reconstrói-se mais fraco do que o provado: a
prova vive como troca exata no catálogo (`120`; `AGENTS.md`, §3).

**Pendente do Bruno**: rever e fundir o PR; ativar «Require branches to be up
to date before merging» na `main` (ou a merge queue); pedir ao Codex que
empurre cedo e que as provas dele entrem no catálogo (`119`, `120`).

Prompt para colar:

```text
Continuando o BR Port. Leia CLAUDE.md, ESTADO_DO_PROJETO.md, a §7 do plano v3
e as decisões 117 a 120. Confira a main remota, os PRs abertos e o CI do
último merge.

Se o PR da branch claude/gracious-mendel-oiww62 já foi fundido, confira se o
job «Defeitos já provados» passou na main e quanto tempo levou. Se não foi,
veja o que o Codex fundiu depois dele e rode python3 tools/conferir_colaboracao.py
antes de qualquer coisa.

Toda guarda nova ou bug corrigido desta conversa entra em tools/mutantes.toml,
com a guarda declarada medida pelo --explorar.

Ao encerrar, aplique /fechar-sessao e entregue o prompt completo da
próxima conversa em bloco copiável.
```
