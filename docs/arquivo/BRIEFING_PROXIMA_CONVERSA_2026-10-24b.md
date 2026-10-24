# BR Port — as treze lacunas graves fechadas (`138`); a próxima conversa são os sprites de detalhes

**24/10/2026.** Branch `claude/upbeat-meitner-fkfkne`, avançada para a da
`137` (`claude/zealous-heisenberg-dtqner`, **PR #150**), que esta conversa
levou a verde no runner e cujos tempos registou lá — o job dos mutantes acaba
aos 15:37 da corrida, contra 100 min no #149 —, e que o Bruno fundiu
(`10b9d7c`). Esta branch não tem PR: ele não o pediu nesta conversa.

**Decisão `138` — as treze lacunas graves, fechadas pelo texto e pela
ação.** Os treze defeitos da amostra da `137` voltaram a passar verdes antes
de qualquer guarda; hoje cada um reprova pela guarda nova e só na suíte
dela: o T31 novo (`tests/casos_mostra_e_faz.gd`) para a reputação ao servir,
o arranque, o caixa, a parcela, a meta, o cartão da doca e os cascos da
fila; o T24 para o botão de cancelar e a recusa esquecida; o RB5 para os
botões de tamanho e o arrasto com o dedo; o A6 e o A7 do áudio para o volume
no arquivo e os relógios do mar e da gaivota. Os treze estão numa secção
própria do catálogo, com o id da amostra ao lado.

**E treze das 28 médias, a pedido do Bruno** (lógica, telemetria, painéis e
preferências; as visuais ficaram de fora): doze com guarda e defeito no
catálogo, numa secção própria, e o calendário registado como equivalente.

PROVA-BRIEFING

⚠️ Botão de painel escolhe-se pelo que ele diz, e o toque do telefone prova-se
com `ScreenTouch`/`ScreenDrag` no `push_input`
(`.claude/rules/testes-e-guardas.md`, «O que as suítes executam e não
conferem»).

⚠️ A gravidade de uma amostra lida à mão é hipótese: dois dos treze não
chegavam ao jogador (`.claude/rules/testes-e-guardas.md`, mesma secção, e a
`138`).

⚠️ O arranque do jogo prova-se com um `GameState` novo posto na árvore (o
comentário de `arranque_carrega_o_save` em `brport_vs/tests/casos_mostra_e_faz.gd`).

⚠️ Erro do motor pergunta-se dentro da suíte com um `Logger` posto por
`OS.add_logger()` (`.claude/rules/gdscript.md`, o zero do tipo).

⚠️ Onde um defeito de leiaute se vê, di-lo uma sonda corrida com e sem ele
(`.claude/rules/testes-e-guardas.md`, «O que as suítes executam e não
conferem»).

⚠️ A captura em paralelo ganha 1,4× no runner, contra ~3× aqui (`137`, «A
prova»).

**Pendente:** o PR desta branch, que é decisão do Bruno. As quinze médias
que ficaram de fora (treze visuais, uma de texto, uma fora do headless)
estão nomeadas na `138`.

**A próxima conversa:** o item 3 da fila da `126`, os sprites de detalhes. O
que a `136` anotou nas fotos, sem investigar (briefing 2026-10-23c): postes e
placas na calçada nova, carros estacionados, lixeiras, um ponto de ônibus e
cavaletes de obra ao lado dos cones.

Prompt para colar:

```text
PROMPT
```
