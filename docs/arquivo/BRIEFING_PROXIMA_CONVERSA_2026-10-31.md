# BR Port — a peça que assenta e o botão que afunda (`145`); a próxima conversa é a T1

**31/10/2026.** Branch `claude/sharp-lamport-kf55gf`, da main `53b923b` (o
PR #156 da `144` fundiu a meio da conversa, com o conserto da partilha dos
mutantes por cima, e a branch avançou por fast-forward). Nenhum PR aberto
desta branch: não foi pedido nesta conversa.

**Decisão `145` — o A1, o segundo item do tema animação e toque.** Medido
antes: a virada que conclui cada uma das oito obras trocava a textura num
quadro e nada mais. **Aceite à quarta passagem em vídeo**: a peça nova
assenta de 94% a 100% em 0,3 s com o pivô no chão (a lança com o píer, à
volta do mesmo chão), a obra velha esvai-se por baixo dela em 0,25 s (no
pátio, o canteiro e os cones em 0,1 s, e o chão de terra por cima do
pavimentado), e o «Avançar dia» e o cartão «Ao largo» afundam ao premir —
pelo estilo, não pela escala. Só o botão arma o assentar; com o movimento
reduzido não há. O D53 prova-o, com 30 defeitos no catálogo.

⚠️ O premido desenha-se no estilo, não na escala, e quem encolhe a borda
move o conteúdo com ela (`.claude/rules/interface.md`, a seguir a «UM
`Container` DESFAZ O GIRO DO FILHO»).

⚠️ No telefone o «passar por cima» fica depois do toque; só o rodapé o trata
(`.claude/rules/interface.md`, logo a seguir).

⚠️ Num teste que não deixa passar quadros, o toque pede o contentor arrumado
à mão e o `push_input(…, true)` (`.claude/rules/testes-e-guardas.md`, a
seguir a «E O BOTÃO ESCOLHE-SE PELO QUE ELE DIZ»).

⚠️ O `--explorar` corre em série; um bloco num arquivo próprio explora-se
sozinho, e renomear a asserção deixa o rótulo declarado para trás
(`.claude/rules/testes-e-guardas.md`, «Guarda nova»).

⚠️ A suíte disse `DESIGN OK` com o sub-bloco de contraste do D43 rebentado
(`.claude/rules/testes-e-guardas.md`, «um sub-bloco leva a sua BANDEIRA»);
ficou sugerida uma tarefa à parte para lhe dar a bandeira.

⚠️ Tween que compensa a posição não volta ao número exato
(`.claude/rules/gdscript.md`).

⚠️ O veredito em quatro passagens, e o «procure mais melhorias» respondido
com uma terceira pergunta medida (a skill `/arte`, §8, a `145`).

**Ficou por pedir:** o «Dia N» a marcar a virada e os postes do pátio a
esvaírem-se (a `145`, «O que fica de fora»). O fundeadouro, a esteira e a
fumaça continuam depois do A3 (a `144`).

**Pendente:** o PR desta branch (pergunte ao Bruno se o abre), e com ele o
CI — o catálogo com os 30 defeitos novos, e a captura igual à da main (o
assentar só existe nos 0,3 s depois de uma obra acabar pelo botão).

**A próxima conversa, pela ordem do Bruno:** a T1, a háptica, com o desenho
na `144`. A guarda nova e os defeitos dela são F6 (Opus); o resto é receita.

Prompt para colar:

```text
Continuando o BR Port. Leia CLAUDE.md, ESTADO_DO_PROJETO.md, a §7 do plano v3
e as decisões 144 (o desenho dos quatro itens do tema animação e toque) e
145 (o A1: a peça que assenta e o botão que afunda). Confira a main remota,
os PRs abertos e o CI do último merge, e rode python3
tools/conferir_colaboracao.py com o trabalho commitado (ele lê o HEAD). Se o
trabalho da 145 (branch claude/sharp-lamport-kf55gf) ainda não estiver na
main, pergunte ao Bruno se abre o PR dele e conduza-o até verde antes de
começar: o CI deve mostrar a captura igual à da main (o assentar só existe
nos 0,3 s depois de uma obra acabar pelo botão) e o catálogo com 30 defeitos
novos na secção da 145.

O item desta conversa, na ordem que o Bruno escolheu (A1′ → A1 → T1 → A3):
a T1, a háptica. Um ponto único, como o Audio.gd, que recebe o MOMENTO
(atracar ~20 ms; obra pronta e parcela paga ~40 ms) e chama
Input.vibrate_handheld(); «Vibração» nos Ajustes, na
PreferenciasDeApresentacao (fora do save), ligada por omissão; a permissão
VIBRATE no preset Android (plataforma.md). A virada simples não vibra. O
desenho, a prova e os mutantes estão na 144 («T1 — a háptica»). Atenção: a
obra pronta sai do obra_concluida, que também dispara nas bancadas e nas
suítes — veja na 145 como o assentar só arma pelo botão (_virada_armada), e
decida se a vibração segue a mesma porta.

1. Meça antes: nenhuma chamada de vibração no jogo e nenhuma permissão
   VIBRATE (144); confira-o no código e no export_presets.cfg.
2. Implemente com a guarda nova (o ponto único conta os pedidos por momento:
   um por atracar, por obra e por parcela, zero por virada simples, zero com
   a preferência desligada; o teste_fumaca lê a permissão no preset), o
   defeito injetado de cada pergunta no catálogo (secção nova, ao lado da
   145), e a linha nova dos Ajustes no D33 e no RB5.
3. O gate é o telefone, que só o Bruno tem: mostre a linha dos Ajustes
   (captura) e diga-lhe o que sentir em cada momento; o APK sai do CI do PR.
   Pergunte o veredito sozinho, logo a seguir (a skill /arte, §8).

Depois vem o casco que rola (A3), uma conversa, e a esteira, a fumaça e o
fundeadouro (a ordem entre estes três pergunta-se). As duas melhorias que a
145 encontrou e o Bruno não pediu estão escritas lá. A luz, o som e o resto
abrem-se quando ele os pedir (143). Ao encerrar, aplique /fechar-sessao e
entregue o prompt completo da próxima conversa em bloco copiável.
```
