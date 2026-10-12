# BR Port — briefing para a próxima conversa (12/10/2026, c)

```text
Continuando o BR Port. Leia docs/ESTADO_DO_PROJETO.md e a §7 do plano v3.

Confira na main pelo GitHub se o PR #126, da segunda chance do Sr. Ribeiro,
foi fundido (branch claude/zealous-volta-57u6cg: o aceitar_segunda_chance(), o
save 15 com o primeiro degrau, o tempo do meio da cena da parcela, o T18/T19,
a decisão 102) e se há PR aberto do Codex antes de editar. A última decisão
é a 102; confira o próximo número livre na main.

A frente 5 continua. Pergunte ao Bruno o próximo recorte — a progressão para
a Fase 2, o cancelamento de trabalho, mais trabalhadores por píer ou a linha
voluntária de crédito —, com as opções e a recomendada primeiro, lendo o GDD
antes (docs/gdd/sistemas/phases.md, conceitos/construcao.md, funcionarios.md,
contratacao.md), e registe a resposta numa decisão. A leitura da 102 pesa na
recomendação: na Fase 1 todo serviço acaba no dia e quem trava a obra é o
calendário, logo os três últimos só ganham uso com a Fase 2. Se ele já tiver
lido em voz alta as falas do A4 (as três do Toninho e as duas novas do Sr.
Ribeiro), aplique as notas dele primeiro. Um item só.
```

A segunda chance está no jogo (`102`): no vencimento das duas primeiras
cobranças, a quem falta o boleto, o Sr. Ribeiro empresta o que falta mais uma
semana de custos, devolvido com +12% fixo junto da cobrança seguinte, uma vez
por fase. Save 15, o primeiro acima do piso, com o degrau 14→15. As duas falas
dele (`oferta`, `aceitou`) são rascunho para o A4.

⚠️ O boleto de hoje é o `principal_da_parcela()`, que soma a dívida da
segunda chance; um laço de vencimento que lesse a tabela
(`valor_da_parcela(i)`) prendia a partida no `pay_debt()` que recusa calado —
o `gravar_partidas.gd` fazia isso (`102`, comentário no `gravar_partidas.gd`).

⚠️ Crédito não é lucro: o empréstimo fica fora da receita e do resultado da
semana, e o simulador desconta-o da margem (`.claude/rules/economia.md`).

⚠️ O exemplo de save de uma versão nova joga até ter os campos dela cheios —
o `v15.json` joga mal o primeiro mês para trazer a dívida
(`.claude/rules/save.md`).

⚠️ Mutante que muda a linha e deixa a antiga de pé é equivalente, e laço de
suíte que joga até um estado leva teto de voltas — os dois apareceram na F6
desta sessão (`.claude/rules/testes-e-guardas.md`).

O banco de aperto (caixa inicial baixado, com e sem a chance) mostrou que
ela salva quem falha por pouco e não toca nas duas portas que ficaram de
fora por escolha: a última cobrança e «o dinheiro acabou» entre vencimentos
(`102`). Se o playtest mostrar gente a morrer nelas, a pergunta é do Bruno.

Os tempos `pagou` e `nao_pagou` da cena do Sr. Ribeiro têm o nome das falas,
e o F7 procura o id entre aspas no painel: um tempo homónimo satisfá-lo-ia
sozinho. Lido, não medido; anotado na `102`.
