# BR Port — briefing para a próxima conversa (10/10/2026, g)

```text
Continuando o BR Port. Leia docs/ESTADO_DO_PROJETO.md, a §7 do plano v3 e a
§6 de docs/REVISAO_GERAL_2026-10-09.md — a fila de melhorias da mais crítica
à mais tranquila, que é a prioridade em vigor por escolha do Bruno (10/10),
antes de voltar aos gráficos e ao jogo.

Confira na main pelo GitHub se o PR do M6 foi fundido (branch
claude/awesome-archimedes-ou0rnf: o bloco F19 do teste_fumaca, a declaração
brport_vs/tests/nomes_lidos_por_string.json e a decisão 093) e se há PR
aberto do Codex antes de editar. A última decisão é a 093; confira o próximo
número livre na main antes de usar.

O primeiro item aberto é o M7, preparar a Fase 2 sem mudar a Fase 1, e ele
espera duas decisões do Bruno (§6.0): D3, a expansão do mapa por vagas
curadas por fase ou pela grade livre do GDD; e D4, a escala da reputação
entre fases. Se ele já as respondeu, faça o M7 (Opus). Se não, pergunte-lhe
as duas no arranque, com a recomendação da §6.0 primeiro; sem resposta, o
primeiro item sem decisão pendente é o M8 — partir o Main.gd, um PR por
extração, começando pelo tráfego dos camiões. Faça um item só.
```

O M6 pôs de pé o F19: cada membro privado que as suítes e as ferramentas
pedem por string ao `Main`, ao `Dock` ou a um painel tem de existir no script
da raiz da cena, com o tipo que a leitura pede. São 52 nomes, 38 do `Main`.
A forma, os números e os catorze mutantes estão na `093`.

⚠️ `get`, `set`, `in` e `has_method` de um nome que não existe são calados;
só o `call` grita. Um teste novo que leia um privado por string declara o
receptor no JSON, ou o F19 reprova (`gdscript.md`, `093`).

⚠️ Partir o `Main` (M8) vai reprovar o F19 com a lista das leituras que
mudaram de dono. O caminho é a suíte ler o membro no script novo — um alvo
novo na declaração —, e nunca afrouxar o F19 para «o `Main` ou qualquer um»
(`093`, «Para o M8»).

⚠️ Uma guarda que varre a pasta onde mora lê os próprios fixtures como dado;
a primeira corrida do F19 reprovou a lista dos nomes esperados
(`testes-e-guardas.md`).

A frente 5 tem o seu briefing (`BRIEFING_PROXIMA_CONVERSA_2026-10-09b.md`) e
volta depois da fila, salvo pedido do Bruno.
