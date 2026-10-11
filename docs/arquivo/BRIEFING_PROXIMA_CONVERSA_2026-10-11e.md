# BR Port — briefing para a próxima conversa (11/10/2026, e)

```text
Continuando o BR Port. Leia docs/ESTADO_DO_PROJETO.md, a §7 do plano v3 e a
§6 de docs/REVISAO_GERAL_2026-10-09.md — a fila de melhorias da mais crítica
à mais tranquila, que é a prioridade em vigor por escolha do Bruno (10/10).

Confira na main pelo GitHub se o PR do M10 foi fundido (branch
claude/lucid-maxwell-ihi34a: a migração encadeada do save, o F21 e a decisão
098) e se há PR aberto do Codex antes de editar. A última decisão é a 098;
confira o próximo número livre na main antes de usar.

O item seguinte é o M11. O D6 foi respondido em 11/10: sim, o CI publica o
brport-web da main no GitHub Pages, no lugar do protótipo HTML da raiz. A
fonte do Pages tem de passar a «GitHub Actions» nas configurações do
repositório, e isso só o Bruno faz — peça-lho no início. O resto do M11 está
na §6 da revisão; o FPS no telefone é medido por ele. Faça um item só.
```

O M10 fechou (`098`): o save sobe por degraus, com a 14 de piso. Não há
degrau ainda; o que existe é a cadeia, o exemplo `tests/saves/v14.json`
gravado pelo jogo, a ferramenta que o grava e o F21, que exige um exemplo por
versão e a ida e volta exata do corrente.

⚠️ Subir a versão do save pede, no mesmo commit, o degrau, o exemplo da
versão nova e o da anterior intacto — e continua a pedir o sim do Bruno
(`save.md`, `098`).

⚠️ A ida e volta do save só morde com os campos cheios: com o exemplo do dia
1, o `load_game()` podia esquecer a obra e o F21 passava (`testes-e-guardas.md`,
`098`).

Quando a fila parar, o recorte da frente 5 que o Bruno escolheu em 11/10 é o
tutorial curto, com a pergunta de quem guia (a revisão, «Depois da fila»).
