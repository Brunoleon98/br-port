# BR Port — testes que guardam o que aprenderam, e o pré-PR entre agentes

**16/10/2026.** Branch `claude/gracious-mendel-oiww62`, com a main `f03302d`
juntada (PR #133 do Codex: cancelamento e save 18). PR #134 do Codex aberto
(`codex/implementar-como-jogar`, decisões 113–116, briefings até `2026-10-16`).
Esta branch ainda **não tem PR**: o Bruno vai pedi-lo quando parar o Codex.
Sessão LATERAL — o rumo do jogo continua o dos briefings do Codex.

Três decisões nesta branch:

- **`117`** — o catálogo de defeitos já provados (`tools/mutantes.toml`) e o
  executor (`tools/conferir_mutantes.py`), que o job «Defeitos já provados»
  reinjeta a cada PR. Escrita como 111; passou a 117 quando a 111 do Codex
  chegou à main.
- **`118`** — o T25, o jogador ao acaso: 24 partidas com semente e invariantes
  a cada passo, com a falha reduzida à trilha mínima; e o vigia que impede o
  `run_tests` e o `teste_fumaca` de pendurar.
- **`119`** — a colaboração: `tools/conferir_colaboracao.py` (o pré-PR contra
  a base e os PRs abertos) e `tools/renumerar_decisao.py`.

O catálogo tem 45 defeitos; um deles só o T25 apanha (carregar a meio da
oferta). O `run_tests` passou de ~13 s para ~21 s.

⚠️ Os espaços partilhados entre agentes — número de decisão, nome de
briefing, documentos de fecho — colidem; o livre conta-se em todos os ramos
(`.claude/rules/gerais.md`, git e briefing; `AGENTS.md`, §2).

⚠️ Robô ao acaso sem controle de exercício passa verde sem ter jogado; leia a
linha `-> fase 2 em N de 24` do T25 (`.claude/rules/testes-e-guardas.md`, «O
jogador ao acaso»).

⚠️ A guarda declarada de um mutante sai do `--explorar`, não do palpite
(`.claude/rules/testes-e-guardas.md`, «O defeito injetado fica no catálogo»).

**Quando o Bruno pedir o PR** (`119`, e `AGENTS.md` §3): `git fetch`; ver os
PRs abertos e os ramos `codex/*` recentes; `git merge origin/main`;
`python3 tools/conferir_colaboracao.py --outros <cabeças dos PRs abertos>`;
renumerar o que colidir com `tools/renumerar_decisao.py`; as seis suítes, o
catálogo inteiro e o `conferir_docs.py`; só então o PR. **Já se sabe uma
colisão**: o #134 também cria um T25 (a ajuda «Como jogar»); se ele fundir
primeiro, o jogador ao acaso desta branch passa a T26 — rótulos do
`tests/jogador_ao_acaso.gd`, o cabeçalho no `run_tests.gd`, a `118`, o
`ESTADO` e a regra de testes.

**Pendente do Bruno**: ativar «Require branches to be up to date before
merging» na `main` (ou a merge queue), e pedir ao Codex que empurre cedo —
as duas na `119`.

Prompt para colar:

```text
Continuando o BR Port. Leia CLAUDE.md, ESTADO_DO_PROJETO.md, a §7 do plano v3
e as decisões 117, 118 e 119. Confira a main remota e os PRs abertos.

A branch claude/gracious-mendel-oiww62 tem o catálogo de defeitos (117), o
jogador ao acaso T25 (118) e o pré-PR entre agentes (119), sem PR aberto.
Parei o Codex: crie o PR agora, seguindo o AGENTS.md §3 — junte a main, rode
python3 tools/conferir_colaboracao.py com as cabeças dos PRs abertos dele,
renumere com tools/renumerar_decisao.py o que colidir, rode as seis suítes,
python3 tools/conferir_mutantes.py --godot "$G" e o conferir_docs.py, e diga
o que o trabalho do Codex mudou no PR antes de o abrir.

Ao encerrar, aplique /fechar-sessao e entregue o prompt completo da
próxima conversa em bloco copiável.
```
