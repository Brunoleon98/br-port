# BR Port — o barco que vai do largo ao berço (`144`); a próxima conversa é o A1

**30/10/2026.** Branch `ccr-83914c2f-kuj4zq`, da main `0a2e16f` (o PR #155
da `143` fundiu a meio da conversa, e a branch avançou por fast-forward).
Nenhum PR aberto: não foi pedido nesta conversa.

**Decisão `144` — o segundo tempo do bloco de 29/10, tema animação e toque.**
Medido: atracar não tinha gesto (o barco aparecia no berço no quadro do
toque), e o lugar ao largo que sumia não era o tocado. O Bruno desenhou os
quatro itens (A1′, A1, T1, A3) e escolheu a ordem **A1′ → A1 → T1 → A3**. O
**A1′ fechou, aceite à quarta passagem em vídeo**: o barco navega de proa do
lugar dele até perto da boca do berço, vira em passos de 90° a deslizar pela
faixa e entra de ré, em ~2,6 s; os 9 cascos ganharam a arte virada para o
cais (o grupo do Blender espelhado em `x`), as boias foram para o lado do
mar, e o D52 prova o caminho passo a passo, com 13 defeitos no catálogo.

⚠️ A animação pendurada no verbo morre com ele, com a guarda verde
(`.claude/rules/testes-e-guardas.md`, a seguir a «TROCAR O VERBO DO JOGO»).

⚠️ O prop virado ao contrário espelha-se em `x`, e quantas direções uma
animação pede mede-se nos caminhos antes de as propor (`.claude/rules/arte.md`,
a seguir a «Rodar um prop 90°»).

⚠️ O `PropIso.desenho()` é relativo ao CENTRO do quadro, e a régua que o soma
ao canto dá zero em tudo (`.claude/rules/projecao.md`).

⚠️ A correção escrita numa opção de veredito mede-se antes de a escrever
(a skill `/arte`, §8, a `144`).

**Aceite por agora, à espera de conversa própria:** 3 dos 9 caminhos passam
por cima do barco parado no lugar 1, e o do lugar 2 para o berço 1 anda a
~56° da proa — o fundeadouro (a `144`, «O que fica de fora»). Também a
esteira e a fumaça dos navios a navegar, a pedido dele. A ordem entre os
três pergunta-se depois do A3.

**Pendente:** o PR desta branch (pergunte ao Bruno se o abre), e com ele o CI
— a captura vai dizer que as fotos com o largo mudaram (as boias saíram do
corredor) e que a folha dos props ganhou os 9 cascos `_ao_cais`.

**A próxima conversa, escolha do Bruno em 29/10:** o A1 — a peça nova
assenta e o «Avançar dia» afunda —, com o desenho na `144`.

Prompt para colar:

```text
Continuando o BR Port. Leia CLAUDE.md, ESTADO_DO_PROJETO.md, a §7 do plano v3
e a decisão 144 (o barco que desliza do largo ao berço, e o desenho dos
quatro itens do tema animação e toque). Confira a main remota, os PRs
abertos e o CI do último merge, e rode python3 tools/conferir_colaboracao.py
com o trabalho commitado (ele lê o HEAD). Se o trabalho da 144 (branch
ccr-83914c2f-kuj4zq) ainda não estiver na main, pergunte ao Bruno se abre o
PR dele e conduza-o até verde antes de começar: o CI vai mostrar as fotos
com o largo mudadas (as boias saíram do corredor) e a folha dos props com os
9 cascos virados para o cais.

O item desta conversa, na ordem que o Bruno escolheu (A1′ → A1 → T1 → A3):
o A1, o retorno ao toque. Na virada que conclui uma obra (obra_concluida), a
peça nova assenta de 97% a 100% em 0,3 s, a travar, com o pivô no chão (a
origem do mundo no quadro de 512), sem passar de 100%; e o «Avançar dia»
afunda 4% ao premir e volta ao soltar. O desenho, a prova e os mutantes de
cada parte estão na 144. Atenção: o botão vive num HBoxContainer, e um
contentor reescreve a scale do filho (interface.md) — meça qual das duas
saídas da 144 não mexe no D43 antes de escolher.

1. Meça antes: a sonda do toque da 144 (a virada que acaba a obra troca a
   textura num quadro) e o medir_desempenho.gd.
2. Implemente com a guarda nova (uma sonda ao longo dos frames, gdscript.md;
   o defeito injetado de cada pergunta, no catálogo de mutantes, secção da
   144), passe pelo MovimentoDeFundo / reduzir movimento (RB6) e leve-o ao
   fim no _concluir_virada para a bateria ficar igual fora do tiro virada.
3. Mostre ao Bruno em VÍDEO (MP4, o GIF não anima no app, 142), com a
   pergunta do veredito sozinha logo a seguir e a lista de defeitos vistos,
   cada um com a correção escrita (a skill /arte, §8).

A háptica (T1) e o casco que rola (A3) ficam para as conversas seguintes,
uma cada, e depois a esteira, a fumaça e o fundeadouro (a ordem entre estes
três pergunta-se). A luz, o som e o resto abrem-se quando ele os pedir
(143). Ao encerrar, aplique /fechar-sessao e entregue o prompt completo da
próxima conversa em bloco copiável.
```
