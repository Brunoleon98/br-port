# BR Port — briefing para a próxima conversa (11/10/2026, d)

```text
Continuando o BR Port. Leia docs/ESTADO_DO_PROJETO.md, a §7 do plano v3 e a
§6 de docs/REVISAO_GERAL_2026-10-09.md — a fila de melhorias da mais crítica
à mais tranquila, que é a prioridade em vigor por escolha do Bruno (10/10).

Confira na main pelo GitHub se os PRs do segundo e do terceiro cortes do M8
foram fundidos (branch claude/youthful-hawking-h4xzuc: a NarradoraDaCida.gd e
a decisão 096; a VezDasTelas.gd, o F11d e a decisão 097) e se há PR aberto
do Codex antes de editar. A última decisão é a 097; confira o próximo número
livre na main antes de usar.

O M8 fechou, e os itens seguintes da fila esperam decisões do Bruno: o M9 só
anda junto da próxima subida de save (D1b), o M10 pede o D5 (a política de
save do primeiro build público), o M11 pede o D6 (publicar o Web no Pages) e
o FPS no telefone, e o M12 vem depois do A8. Comece por lhe perguntar o D5 e
o D6, com as opções e a recomendada primeiro; se ele não quiser decidir
agora, a próxima frente são os gráficos e o jogo — a frente 5 tem o seu
briefing (docs/arquivo/BRIEFING_PROXIMA_CONVERSA_2026-10-09b.md). Faça um
item só.
```

O M8 fechou em três PRs (`095`–`097`): o trânsito dos camiões, a narradora da
Dona Cida e a vez das telas saíram do `Main.gd`, que foi de 2.742 linhas e
113 funções para 1.100 e 49. Cada corte saiu com as 66 fotos iguais ao byte e
um controle positivo no script novo.

⚠️ A linha que uma extração muda de forma pede o seu mutante: a guarda de
saída da vez das telas não tinha quem a visse, antes ou depois, e quem a vê
hoje é o F11d (`testes-e-guardas.md`, `097`).

⚠️ Um lambda ligado a um sinal segura vivo o `RefCounted` onde nasceu; objeto
do `Main` liga-se ao autoload por método (`gdscript.md`, `096`).

O terceiro corte só subiu para a branch depois de o PR do segundo ser
fundido, para ficar um PR por extração.
