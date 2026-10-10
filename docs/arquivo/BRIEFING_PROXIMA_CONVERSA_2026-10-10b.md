# BR Port — briefing para a próxima conversa (10/10/2026, b)

```text
Continuando o BR Port. Leia docs/ESTADO_DO_PROJETO.md, a §7 do plano v3 e a
§6 de docs/REVISAO_GERAL_2026-10-09.md — a fila de melhorias da mais crítica
à mais tranquila, que é a prioridade em vigor por escolha do Bruno (10/10),
antes de voltar aos gráficos e ao jogo.

Confira na main pelo GitHub se o PR do M1 foi fundido (branch
claude/bold-gates-abot5o: o gravador na versão 2 com a obra pronta e o
calendário no cabeçalho, o leitor com dia pago → pronto e o autoteste, a
decisão 088) e se há PR aberto do Codex antes de editar. A última decisão é
a 088; confira o próximo número livre na main antes de usar.

Faça o PRIMEIRO item aberto da fila, e só ele. Hoje é o M2: a regra de
abertura num lugar só. Uma função diz em que dia cada reparo abre (armazém em
TURNS_PER_WEEK + 1; pátio em PARCELA_DUE_TURN + 1, com uma cobrança
quitada), e o _save_aceite() e o desbloqueio_da_estrutura() leem dela; na
mesma passada a obra lida do save sai com inteiros. A prova está escrita no
M2 (relacional, andando o calendário; mutante com o armazém na semana 3 só no
desbloqueio). Não muda a forma do save: o SAVE_VERSION não sobe.

Item com [decisão] na fila só começa depois da resposta do Bruno à pergunta
da §6.0 que o destrava.
```

⚠️ O M2 mexe no `GameState.gd`: em qualquer linha, a tabela dos números
regera-se, porque cita a linha de cada constante (`CLAUDE.md`, «Antes de
fechar», item 3).

⚠️ Mutante numa regra que existe em dois sítios não reprova enquanto a cópia
existir — é o defeito que o M2 vem acabar (`CLAUDE.md`, regra 7 do fecho).

⚠️ Asserção sobre a mediana não vê um valor a mais: a fixture do M1 responde
com uma LISTA exata, e foi isso que apanhou o 8 cravado (`088`).

⚠️ Capturas e suítes partilham `user://ferramentas/`; não rode as duas juntas
(`CLAUDE.md`, «Como rodar»).

A frente 5 tem o seu briefing (`BRIEFING_PROXIMA_CONVERSA_2026-10-09b.md`) e
volta depois da fila, salvo pedido do Bruno.
