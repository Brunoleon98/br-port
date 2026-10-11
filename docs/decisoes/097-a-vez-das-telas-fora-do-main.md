# 097 — A vez das telas sai do `Main`, e o M8 fecha

**11/10/2026.** Base `38e5c10` (o segundo corte, `096`, no PR #120, ainda por
fundir — este corte só sobe para a branch depois dele, para ser um PR por
extração); 097 livre conferida. É o **terceiro e último PR do M8** da fila de
`docs/REVISAO_GERAL_2026-10-09.md` (§6). Refatoração pura, provada pela
bateria de capturas byte a byte.

## O que mudou

**`scripts/VezDasTelas.gd`** — a fila das telas que abrem sozinhas (o Sr.
Ribeiro, o boletim, o fim de fase, e o Arlindo quando chega ao pagar): quem
tem a vez, os que esperam, e as três funções que a dão e a passam, com o
comentário longo que conta porquê (`054`, `087`). O `Main.gd` foi de 1.163
linhas e 52 funções para 1.100 e 49. O que mudou no texto movido, conferido
por `diff`:

- o `_na_vez()` e o `_painel_da_vez` perderam o sublinhado: o `Main` chama
  um nos quatro sítios que abrem telas sozinhas e lê o outro antes de pôr o
  Arlindo na fila, e o T16 do `run_tests` fecha quem tem a vez;
- o `is_inside_tree()` do `_passar_a_vez()` passou a ser perguntado ao
  `Main`, que o objeto recebe ao nascer — é a única coisa dele que guarda.

**No `Main`:** o `preload` e o membro público `vez`, montado como `@onready`
com o próprio `Main`. **Nos leitores:** o `run_tests` (`main.vez.painel_da_vez`)
e os comentários do `teste_fumaca` e da `capturar_tela`. A `interface.md`
carrega ao abrir o script novo, e a regra da vez diz onde ela vive.

## Porquê assim

A forma das duas extrações anteriores (`095`, `096`): um `RefCounted` do
`Main`, sem `class_name`, por `preload`, e a árvore da cena igual. Este não lê
o `GameState`, mas a forma é uma só. Não liga lambda nenhum a um sinal de vida
longa (`096`): a única ligação é ao `tree_exited` do painel, por método.

**Quem abre continua a ser o `Main`.** O objeto recebe a função que abre cada
tela — ela sabe a cena e o `setup()` — e só decide QUANDO a chamar. Pôr a
abertura dentro dele obrigaria-o a conhecer as cenas, que é o que o `Main` já
conhece.

## A prova de refatoração pura

ANTES é `38e5c10`, numa worktree; DEPOIS é a branch. Em sequência.

- **A bateria:** **66 de 66 fotos iguais ao byte** — e a base deu as mesmas
  66 que a corrida do corte 2, logo a calibração continua de pé. O controle
  positivo — a fila desligada no `na_vez()`, cada tela a abrir por cima da
  anterior — fez a bateria reprovar no tiro `balanco`: «depois de pagar devia
  estar só o Sr. Ribeiro na tela, e estão 2».
- **As seis suítes** verdes, com as mesmas asserções do corte 2 mais as seis
  do F11d (abaixo) e a contagem do F19.
- **O simulador** (600 por perfil, semente 20260825) e **a régua da faixa**:
  iguais.

## Os mutantes, e o ponto cego que um deles mostrou

| # | Defeito no script novo | Reprova |
|---|---|---|
| Y1 | a fila desligada (o controle positivo) | T16 do `run_tests`; os três caminhos do F11; a bateria |
| Y2 | a vez presa ao `fechou` em vez do `tree_exited` | só a bateria — o primeiro tiro é o `boletim_otimo`, que pede o boletim da semana 2 e acha a tela vazia |
| Y3 | sem a guarda `is_inside_tree()` do `_passar_a_vez()` | **nada**, antes do F11d — nem as seis suítes nem a bateria, na main e na branch |

O Y2 confirma o que o comentário do `na_vez()` já dizia — as suítes não o
veem —, com um tiro diferente do que o F11 nomeava, e o comentário do F11 foi
corrigido. O Y3 era o caso sério: a guarda que ele tira é a única linha de
comportamento que esta extração mudou de forma, e não a protegia nada.

**O F11d.** O caminho «pagou» do F11 até depois do «Pagar» — o Sr. Ribeiro
com a vez, o boletim e o fim de fase à espera — e então o `Main` solto. Duas
asserções: há telas à espera (2), senão soltar não tem vez a passar e a
seguinte passa de graça; e o motor não conta nós órfãos novos
(`OBJECT_ORPHAN_NODE_COUNT`). Com o Y3, reprova ele e só ele: **41 nós
órfãos** e o «Parent node is busy setting up children» que o comentário do
`_passar_a_vez()` media com 36 numa montagem que não ficou escrita. Limpo, 0.

## O M8 fecha

Os três cortes saíram com a bateria igual ao byte: o trânsito (`095`), a Dona
Cida (`096`) e a vez das telas. O `Main.gd` tinha 2.742 linhas e 113 funções
antes do M8; tem 1.100 e 49. Os itens seguintes da fila esperam o Bruno: o M9
só com a próxima subida de save (D1b), o M10 pelo D5, o M11 pelo D6 e pelo
telefone, o M12 depois do A8.
