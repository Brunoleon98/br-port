# BR Port — briefing para a próxima conversa (11/10/2026, b)

```text
Continuando o BR Port. Leia docs/ESTADO_DO_PROJETO.md, a §7 do plano v3 e a
§6 de docs/REVISAO_GERAL_2026-10-09.md — a fila de melhorias da mais crítica
à mais tranquila, que é a prioridade em vigor por escolha do Bruno (10/10),
antes de voltar aos gráficos e ao jogo.

Confira na main pelo GitHub se o PR do primeiro corte do M8 foi fundido
(branch claude/laughing-ptolemy-03nxns: a folha dos trabalhadores semeada, o
scripts/TrafegoDeCamioes.gd, o alvo Trafego do F19 e a decisão 095) e se há
PR aberto do Codex antes de editar. A última decisão é a 095; confira o
próximo número livre na main antes de usar.

O item aberto continua a ser o M8 — partir o Main.gd, um PR por extração.
O segundo corte é a narradora da Dona Cida (os _cida_* e as memórias de
travessia e de semana), Sonnet com as guardas em Opus. A bateria já está
calibrada (66 de 66 iguais em duas corridas): corra-a no commit de base,
extraia, corra-a outra vez e exija os mesmos hashes, com um controle positivo
no script novo. Faça um item só.
```

O primeiro corte do M8 fechou (`095`). Antes de extrair, a folha dos
trabalhadores foi semeada num commit à parte, e duas corridas da bateria
deram 66 de 66 hashes iguais. O tráfego dos camiões — 1.378 linhas, 51
funções — mudou-se para `scripts/TrafegoDeCamioes.gd`, um `RefCounted` do
`Main` (sem `class_name`, por `preload`), e o `Main.gd` ficou com 1.373
linhas. As 66 fotos saíram iguais ao byte, o simulador e o `medir_transito`
também, e as seis suítes com as mesmas asserções.

⚠️ A semente sozinha não segurava a folha: a classe do barco vinha do save
da foto anterior, e foi preciso o `new_game()` (`captura.md`, `095`).

⚠️ Quem lê os privados do trânsito declara o receptor `trafego` (ou
`_trafego`) em `tests/nomes_lidos_por_string.json`; um alvo do F19 pode ser
um `.gd` desde a `095` (`testes-e-guardas.md`, `093`).

⚠️ Mutante de nome renomeia o nome em todo o arquivo, não só a declaração —
senão o script não compila e a guarda reprova pelo motivo errado
(`testes-e-guardas.md`).

⚠️ As duas árvores de uma comparação (worktree e branch) partilham o
`user://ferramentas/`, porque o projeto tem o mesmo nome: corra-as em
sequência, nunca em paralelo (`CLAUDE.md`, `095`).

A frente 5 tem o seu briefing (`BRIEFING_PROXIMA_CONVERSA_2026-10-09b.md`) e
volta depois da fila, salvo pedido do Bruno.
