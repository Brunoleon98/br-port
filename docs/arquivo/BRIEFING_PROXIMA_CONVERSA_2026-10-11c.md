# BR Port — briefing para a próxima conversa (11/10/2026, c)

```text
Continuando o BR Port. Leia docs/ESTADO_DO_PROJETO.md, a §7 do plano v3 e a
§6 de docs/REVISAO_GERAL_2026-10-09.md — a fila de melhorias da mais crítica
à mais tranquila, que é a prioridade em vigor por escolha do Bruno (10/10),
antes de voltar aos gráficos e ao jogo.

Confira na main pelo GitHub se o PR do segundo corte do M8 foi fundido
(branch claude/youthful-hawking-h4xzuc: o scripts/NarradoraDaCida.gd, o alvo
Narradora do F19, o F8h, a régua da faixa que recusa uma fonte a zero e a
decisão 096) e se há PR aberto do Codex antes de editar. A última decisão é
a 096; confira o próximo número livre na main antes de usar.

O item aberto continua a ser o M8 — partir o Main.gd, um PR por extração.
O terceiro e último corte é a fila de painéis (_na_vez,
_dar_a_vez_ao_proximo, _passar_a_vez), Sonnet com as guardas em Opus.
Corra a bateria no commit de base, extraia, corra-a outra vez e exija os
mesmos 66 hashes, com um controle positivo no script novo. Faça um item só.
```

O segundo corte do M8 fechou (`096`). A narradora da Dona Cida — as sete
ligações aos sinais do `GameState`, os gatilhos, as variantes e as memórias —
mudou-se para `scripts/NarradoraDaCida.gd`, um `RefCounted` do `Main` que se
liga no mesmo ponto e pela mesma ordem; o `Main.gd` ficou com 1.163 linhas e
52 funções. As 66 fotos saíram iguais ao byte (o controle, a Dona Cida calada,
mudou 17), o simulador e a régua da faixa também, e as seis suítes com as
mesmas asserções mais o F8h.

⚠️ Um lambda ligado a um sinal segura vivo o `RefCounted` onde nasceu:
objeto do `Main` liga-se ao autoload por método (`gdscript.md`, `096`).

⚠️ Quem SOBRESCREVE um nome numa subclasse é o terceiro cliente, e o F19 não
o vê: ao mudar um método de dono, procure também quem faz `extends` do
arquivo de onde ele sai (`testes-e-guardas.md`, `096`).

⚠️ Esperar com `pgrep -f` casa o próprio laço de espera e nunca acaba — esta
sessão caiu nisso a meio da bateria; espere pelo aviso de fim (`CLAUDE.md`).

O `ESTADO_DO_PROJETO.md` ficou a cinco bytes do teto: o próximo fecho desce
história para o `HISTORICO.md` antes de acrescentar.

A frente 5 tem o seu briefing (`BRIEFING_PROXIMA_CONVERSA_2026-10-09b.md`) e
volta depois da fila, salvo pedido do Bruno.
