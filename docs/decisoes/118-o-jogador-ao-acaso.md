# 118 — O jogador ao acaso: invariantes a cada passo, e a suíte que não pendura

**16/10/2026.** Branch `claude/gracious-mendel-oiww62`, com a main `f03302d`
juntada (PR #133, o cancelamento e o save 18) e o PR #134 do Codex aberto
(113–116); 118 livre contando os dois, pelo `tools/conferir_colaboracao.py`
(`119`). Pedido do Bruno: *pesquisar o que pode ser melhorado nos testes,
também na internet e sobretudo do lado dos jogos, e implementar.* Asserção
nova com defeito injetado (F6).

## A pesquisa

Feita pela busca, que é o que o proxy deixa (`063`); as páginas não foram
lidas, e o que segue é pista de padrão, não citação:

- **robôs que jogam ao acaso com semente**, presos a ações LEGAIS (a «máscara»
  que evita gastar o orçamento em ações que o estado não admite), com
  invariantes conferidos a cada passo — [bugnet.io, *property based tests for
  game logic*](https://bugnet.io/blog/how-to-write-property-based-tests-for-game-logic),
  [arXiv 2402.04938](https://arxiv.org/pdf/2402.04938), e o caso da PhET,
  que prefere sortear só o que se marca como sorteável
  ([phetsims/axon#383](https://github.com/phetsims/axon/issues/383));
- **reduzir a falha à trilha mínima** — tirar uma ação de cada vez e ficar
  sem ela se a MESMA falha voltar, porque a redução que muda de assinatura
  entrega um caso que falha pela razão errada
  ([ReadySet](https://readyset.io/blog/stateful-property-testing-in-rust),
  [Lockstep](https://hexdocs.pm/lockstep/Lockstep.Shrink.html));
- **gravar e repetir** só serve com o jogo determinístico, e a ida e volta não
  pode partilhar código com o que confere
  ([bugnet.io, replay QA](https://bugnet.io/blog/qa-testing-for-replay-recording-and-playback));
- **mutação só onde o diff mexeu**, com os sobreviventes mostrados na revisão
  — a prática da Google em escala
  ([Petrović et al., TSE 2021](https://research.google/pubs/practical-mutation-testing-at-scale-a-view-from-google/)).
  É a evolução natural do catálogo da `117` quando ele pesar no CI.

## O que mudou

**O T26 — `tests/jogador_ao_acaso.gd`**, num arquivo próprio, como o T24 do
Codex (`119`). Joga 24 partidas com semente, até ao dia 140 ou 700 ações,
escolhendo entre tudo o que o jogador faz — atracar, devolver, cancelar,
construir, pagar adiantado ou no vencimento, pedir a segunda chance, negociar,
recusar, avançar — e o que o jogo tem de RECUSAR (índice fora, estrutura que
não existe, o orçamento de outro valor). A cada passo confere doze
propriedades que valem sempre: estado do turno, oferta e fila coerentes,
barco e trabalhador juntos na doca, porto do tamanho que as obras dizem,
rostos únicos, reputação entre 0 e 100, obras sem repetição, recibo das
cobranças, caixa inteiro, o dia que não volta atrás, **o save que o jogo
grava o próprio jogo aceita**, e **a recusa não mexe no estado**. A ação
«carregar» grava e lê de volta a meio da partida, e exige o mesmo estado.

**A lista do que a ida e volta preserva está no teste, e não no
`save_game()`** — um campo esquecido no save sumiria dos dois lados.

**Três perfis, pelo resto da semente**, porque o acaso puro não chega a tudo,
e foi medido passo a passo: ao acaso, nenhuma de 24 partidas chegou à Fase 2
e o cancelamento nunca existiu; pagar adiantado levou quatro lá, e nenhuma
comprou a treliça; construir o que se pode levou nove, que compraram a
treliça e mesmo assim nunca viram cargueiro — **a reputação caía abaixo do
piso de 40 e o jogo suspendia-os (`106`)**, a regra a funcionar. Atracar
primeiro o urgente levou dezassete à Fase 2 e 179 cancelamentos, e o
vencimento sumiu, porque o prudente pagava sempre antes. Hoje: o *prudente*
(as três inclinações), o *poupador* (só atraca o urgente, nunca adianta) e
o *ao acaso*. **Um controle exige que cada ação tenha sido aceite pelo menos
uma vez** — foi ele que mostrou cada um destes buracos.

**A redução**: uma falha imprime a semente e a trilha reduzida (até 120
repetições), pronta para virar caso de teste e mutante.

**O vigia da suíte que não acaba**, no `run_tests` e no `teste_fumaca` —
as duas que devolvem `false` no `_process` para poderem esperar frames. Um
erro de execução direto no `_run()` abortava-o antes do `quit()`, e a árvore
girava para sempre: o mutante «devolver deixa o trabalhador» fez o T4d
rebentar e a suíte só parou pelo teto de 86 s do executor de mutantes. Dois
mil frames sem chegar ao fim (as esperas legítimas são umas vinte) reprovam
com nome.

## A prova

O T26 passa no código de hoje: nenhum invariante quebrou em mais de 7.600
ações aceites (e as recusadas por cima).
Oito defeitos no catálogo (`118` no `de`), cada um reprovado pela guarda
declarada:

| Defeito | Quem mais o via |
|---|---|
| carregar a meio da oferta devolve as tentativas do Arlindo | **ninguém** — o `teste_fumaca` passou verde |
| o save recusa o fundeadouro cheio | o F16 e os blocos de save |
| devolver deixa o trabalhador na doca | o T4d — e pendurava a suíte |
| a obra recusada cobra um real | o T15 e o T21 |
| o cancelamento aceita outro orçamento | o T24 |
| a reputação sem teto | o T24 |
| o barco sem paciência fica na fila | o T4d e o F8g |
| o cancelamento nunca disponível | o T24 — e no T26, só o controle |

O primeiro é o que a peça existe para apanhar: o jogo de hoje grava e lê a
paciência do cliente, mas se deixasse de a ler de volta nenhuma outra guarda
o diria — nenhum bloco montava o estado «carregar a meio de uma
negociação». O último prova o controle: com ele, todo invariante continua de
pé e só a contagem das ações denuncia que o verbo sumiu.

**Custo**: o `run_tests` passou de ~13 s para ~21 s neste contêiner, e o
catálogo inteiro (45 defeitos, quase todos no `run_tests`) de 769 s para 954 s.

## O que fica de fora

- **Repetir as partidas do playtest** (`playtest/*.jsonl`): o `Registro.gd`
  não grava a semente (conferido), e sem ela a partida não se repete; a pasta
  ainda não tem nenhuma. Gravar a semente muda a forma do registro —
  decisão do Bruno, e pede o A7 primeiro.
- **Mutação pelo diff, à Google**: o catálogo inteiro ainda cabe no job; o
  passo seguinte, quando não couber, está na `117`.
- **Mais perfis, mais partidas**: os números são os que exerceram todas as
  ações com folga; subir custa tempo de cada mutante do `run_tests`.
