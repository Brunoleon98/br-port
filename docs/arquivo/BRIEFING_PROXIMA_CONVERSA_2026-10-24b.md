# BR Port — as lacunas fechadas (`138`) e as suítes em paralelo (`139`); a próxima conversa são os sprites de detalhes

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

**A prova:** as seis suítes verdes, nenhuma mais lenta do que o ruído; o
catálogo inteiro, *«MUTANTES OK — 191 defeito(s)»* em 31 min com quatro
cópias; e a mesma amostra da `137` na árvore final: **106 → 131 apanhados dos
205 (52% → 64%)**, nenhum perdido e nenhum grave a sobreviver.

**Decisão `139` — as seis suítes em paralelo para os agentes**, a pedido do
Bruno no fim: `python3 tools/correr_suites.py --godot "$G"`, que espera
`SUITES OK`, cada suíte com o seu `user://`; 99–103 s em série contra
50–53 s, emparelhado. O CI corre o autoteste dele (`ATALHO PROVADO`).

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

⚠️ O tempo de cada processo em paralelo é o do fim DELE, não a vez de ser
esperado (o comentário de `fins` em `tools/correr_suites.py`).

**Pendente:** o PR desta branch, que é decisão do Bruno. As quinze médias
que ficaram de fora (treze visuais, uma de texto, uma fora do headless)
estão nomeadas na `138`.

**A próxima conversa:** o item 3 da fila da `126`, os sprites de detalhes. O
que a `136` anotou nas fotos, sem investigar (briefing 2026-10-23c): postes e
placas na calçada nova, carros estacionados, lixeiras, um ponto de ônibus e
cavaletes de obra ao lado dos cones.

Prompt para colar:

```text
Continuando o BR Port. Leia CLAUDE.md, ESTADO_DO_PROJETO.md, a §7 do plano v3,
a decisão 136 (as estradas) e a 138 (as lacunas fechadas). Confira a main
remota, os PRs abertos e o CI do último merge, e rode python3
tools/conferir_colaboracao.py com o trabalho commitado (ele lê o HEAD). Se o
trabalho da 138 (branch claude/upbeat-meitner-fkfkne) ainda não estiver na
main, pergunte ao Bruno pelo PR dele e conduza-o até verde antes de começar:
o catálogo passou de 166 para 191 mutantes, e o job das três fatias cresce
com ele — leia o tempo de cada fatia e registe-o na 138.

O item desta conversa é a melhoria gráfica que volta: o item 3 da fila da
126, os SPRITES DE DETALHES. É arte: use /arte, abra
.claude/rules/arte.md, mapa.md e projecao.md, e comece pela foto do jogo
(dia 1 e porto completo, ampliados) e pela pergunta do escopo ao Bruno, com
as opções e a recomendada primeiro — não escolha por ele. O que a 136
anotou nas fotos, sem investigar (briefing 2026-10-23c): postes e placas na
calçada nova, carros estacionados, lixeiras, um ponto de ônibus e cavaletes
de obra ao lado dos cones. Pergunte quais, onde (a rua do porto, a vila, o
pátio) e se mudam com a obra do pátio, como a rua recapeada da 136.

Prop novo no Cenario responde às guardas de todos os props, e prop que
pousa na rua ou na calçada confere a tabela de âncoras e o contorno das vias
(.claude/rules/testes-e-guardas.md, mapa.md). Cada passagem leva a prancha
contra a main e o veredito do Bruno, e o que se medir vai para a decisão.
Os props saem do Blender (bpy ~1 GB, sob demanda).

As quinze lacunas médias que ficaram de fora (as visuais, uma de texto, uma
fora do headless) estão nomeadas na 138; não as comece sem ele. Não comece
outra funcionalidade por conta própria. Ao encerrar, aplique /fechar-sessao
e entregue o prompt completo da próxima conversa em bloco copiável.
```
