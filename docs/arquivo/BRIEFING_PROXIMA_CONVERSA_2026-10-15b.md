# BR Port — o defeito injetado fica: catálogo de mutantes no CI

**15/10/2026.** Branch `claude/gracious-mendel-oiww62`, a partir da main
`b142b80` (PR #132 fundido; nenhum PR aberto). Sessão LATERAL, pedida pelo
Bruno enquanto o Codex trabalha no jogo: **não substitui o rumo do jogo**,
que continua o do `BRIEFING_PROXIMA_CONVERSA_2026-10-15.md` (o cancelamento
da `109`/`110`, à espera do aceite dele).

A pergunta era se os testes aprendem com os bugs e os guardam como defeitos
injetados. Aprendiam uma vez: 166 menções em 64 decisões, cada defeito
corrido à mão e escrito em prosa, nenhum reinjetado depois. A `111` dá-lhes
um lugar — `tools/mutantes.toml`, 37 defeitos de catorze decisões — e um
executor, `tools/conferir_mutantes.py`, que o CI corre a cada PR num job
próprio («Defeitos já provados»). Espera `MUTANTES OK`.

A medição: 35 defeitos reconstruídos contra o código de hoje, 28 reprovados
pela guarda declarada, 6 pela guarda verdadeira com outro rótulo, e **um
sobrevivente** — o A4 do `teste_audio` não via a espera mínima. Corrigido,
com o controle que faltava.

⚠️ A guarda declarada de um mutante sai do `--explorar`, não do palpite
(`.claude/rules/testes-e-guardas.md`, «O defeito injetado fica no catálogo»).

⚠️ Marca de tempo só prova com o relógio a andar; o autoload que não compila
pendura a suíte em vez de a reprovar (as duas na mesma seção da
`testes-e-guardas.md`, e o porquê na `111`).

⚠️ Bug corrigido entra no catálogo como o mutante dele, e o mutante órfão
reescreve-se contra a forma nova em vez de se apagar (`CLAUDE.md`, item 7;
`AGENTS.md`, §3; `/fechar-sessao`, §3).

**Pendente:** o PR desta branch, se o Bruno o pedir — o CI do job novo só
corre lá. A primeira corrida dele dá o tempo real do catálogo no runner;
aqui foram 769 s. Se o Codex numerar uma decisão `111` em
paralelo, o `conferir_docs.py` reprova a junção, e renumera-se a mais nova.

Prompt para colar:

```text
Continuando o BR Port. Leia CLAUDE.md, ESTADO_DO_PROJETO.md e a §7 do
plano v3. Confira a main remota, os PRs abertos e o próximo número livre.

O rumo do jogo é o do docs/arquivo/BRIEFING_PROXIMA_CONVERSA_2026-10-15.md
(o cancelamento das decisões 109 e 110, à espera do meu aceite) — leia-o.

Ao lado, a branch claude/gracious-mendel-oiww62 trouxe a decisão 111: o
catálogo de defeitos já provados (tools/mutantes.toml) e o executor
(tools/conferir_mutantes.py), que o CI reinjeta a cada PR. Confira se ela
já foi fundida e se o job «Defeitos já provados» passou, e quanto tempo
levou. Toda guarda nova ou bug corrigido desta conversa entra no catálogo,
com a guarda declarada medida pelo --explorar.

Ao encerrar, aplique /fechar-sessao e entregue o prompt completo da
próxima conversa em bloco copiável.
```
