# BR Port — briefing para a próxima conversa (09/10/2026)

```text
Continuando o BR Port. Leia docs/ESTADO_DO_PROJETO.md, a §7 do plano v3 e
docs/REVISAO_GERAL_2026-10-09.md — a revisão geral de 09/10, com os vereditos
revistos, o que ficou feito e o plano de execução em etapas (§6).

Entregue nesta revisão (branch ccr-3ac04f71-52brr7): o teste_design deriva o
estado e o D14 confere a vila contra a ruína E o porto completo (1218 linhas
iguais em qualquer disco); .gitattributes com LF; o conferir_docs.py reprova
número de decisão repetido. Confira se foi fundido e se o PR #109 do Codex
(save 13, guindastes) já entrou antes de partir da main.

Comece pela §6.0 da revisão: as decisões D1–D7 são do Bruno, com a opção
recomendada ao lado. Pergunte UMA por vez, a que destrava a etapa que ele
quiser fazer, e só então entre na etapa. Uma etapa por sessão.
```

⚠️ Mexer em `SAVE_VERSION`, `# TUNING:` ou na projeção sem pedido explícito é
proibido, e a etapa 2 depende da autorização do save 13 (`AGENTS.md`, §4).

⚠️ Antes de partir o `Main.gd`, a guarda dos 38 membros privados lidos por
string vem primeiro: `get()` de propriedade inexistente devolve `null` calado
(`REVISAO_GERAL_2026-10-09.md`, §6.5).

⚠️ Medir custo por quadro aqui: sob `xvfb` o `TIME_PROCESS` inclui o desenho
por software, e em `--headless` o laço dorme 6,9 ms com ou sem o jogo
(`REVISAO_GERAL_2026-10-09.md`, N9).

⚠️ Capturas e suítes partilham `user://ferramentas/`; não rode as duas juntas
(`CLAUDE.md`, «Como rodar»).

O PR #109 e esta branch mexem nos mesmos documentos (o estado, o plano e o
`CLAUDE.md`) em linhas diferentes; quem fundir em segundo resolve a junção.
