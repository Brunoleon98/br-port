# BR Port — briefing para a próxima conversa (11/10/2026)

```text
Continuando o BR Port. Leia docs/ESTADO_DO_PROJETO.md, a §7 do plano v3 e a
§6 de docs/REVISAO_GERAL_2026-10-09.md — a fila de melhorias da mais crítica
à mais tranquila, que é a prioridade em vigor por escolha do Bruno (10/10),
antes de voltar aos gráficos e ao jogo.

Confira na main pelo GitHub se o PR do M7 foi fundido (branch
claude/practical-rubin-enfpol: a tabela FASES do GameState, o bloco F20 do
teste_fumaca e a decisão 094) e se há PR aberto do Codex antes de editar. A
última decisão é a 094; confira o próximo número livre na main antes de usar.

O primeiro item aberto é o M8 — partir o Main.gd, um PR por extração,
começando pelo tráfego dos camiões (Sonnet, com as guardas em Opus). A prova
dele é a bateria de capturas byte a byte, e uma das 66 fotos não é estável:
a folha dos trabalhadores sorteia sem semente (captura.md, 094). Antes de
extrair, semeie essa folha num commit à parte e confirme a calibração — duas
corridas da mesma árvore com os 66 hashes iguais. Faça um item só.
```

O M7 fechou (`094`): o Bruno respondeu ao D3 (vagas curadas por fase) e ao
D4 (reputação 0–100 por fase) no arranque. O que é de uma fase vive na
tabela `FASES` do `GameState` — duração, parcelas, reparos, nível máximo,
berços e reputação inicial —, e as treze constantes da Fase 1 saíram. O
despejo do Godot, a tabela dos números e o JSON do simulador saíram iguais
aos de antes; a bateria, igual nas 65 fotos estáveis.

⚠️ A calibração da bateria corre-se, não se supõe: a `trabalhadores.png`
muda entre duas corridas da mesma árvore, e o antes/depois do CI já a marcava
«MUDOU» no #117 (`captura.md`, `094`).

⚠️ Quem compara a saída de dois lados tira o ruído de encerramento do motor
antes de atribuir a diferença à mudança — ele varia de uma corrida para a
outra na mesma árvore (`testes-e-guardas.md`).

⚠️ O número da fase não está no save; a primeira fase jogada depois de
outra sobe a versão (`save.md`, `094`).

⚠️ Mexer no valor de uma parcela da Fase 1 mexe nos juros com ela: o F20
exige que o capital feche o `START_CASH` (`economia.md`, `/balancear`).

A frente 5 tem o seu briefing (`BRIEFING_PROXIMA_CONVERSA_2026-10-09b.md`) e
volta depois da fila, salvo pedido do Bruno.
