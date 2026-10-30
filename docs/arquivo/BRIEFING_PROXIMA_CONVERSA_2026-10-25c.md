# BR Port — as marolas que rolam e a quina norte (`142`) aceites; a seguir, a pesquisa de melhorias

**25–26/10/2026.** A `141` (#153) e a `142` (#154) estão na `main`
(`d310922`). Os tempos das fatias do #154 ficaram num commit só de
documento na branch `claude/br-port-continuacao-72yq7v`, recomeçada da
`main` depois do merge, por fundir.

**Decisão `142` — o que a `124` deixou por olhar**, escolhido pelo Bruno
entre os itens da §7 (a recomendada). **Aceite à segunda passagem.** O que
ficou:

- as marolas saíram do mapa para duas camadas (`--marolas=N`) que rolam
  0,8 u para o cais (~27 px num telefone de 1080), em contrafase: cada uma
  acende num sexto do ciclo de 7 s, fica acesa sozinha e apaga-se noutro
  sexto; com o movimento reduzido, fica o mar de antes, parado;
- a espuma da praia passou a lavar — nunca tinha lavado, com uma das duas
  camadas parada desde que nasceu — e lava mais calma, a pedido;
- o «fio diagonal» era uma fresta de 2 px na quina norte do pátio, e
  fechou.

**A prova:** o D51 do `teste_design` (a cópia do caminho, a marola só em
água nas duas pontas do caminho, a cena, um ciclo lido no nó e o repouso), a
janela da quina no D49 §3, e os 9 mutantes da secção `142` do catálogo,
dois deles bugs que existiram.

⚠️ `set_parallel(true)` antes de cada passo junta os passos todos num só
(`.claude/rules/gdscript.md`); animação nova prova-se com uma sonda que lê o
nó ao longo dos frames.

⚠️ O que sai do mapa para uma camada por cima perde o que o tapava e o que o
escurecia, e fresta de várias peças procura-se onde elas se juntam todas
(`.claude/rules/mapa.md`).

⚠️ O `teste_design` não tem vigia de frames, e um arquivo de casos que não
compila pendura-o até ao teto (`.claude/rules/testes-e-guardas.md`).

⚠️ O GIF não animou no app; o vídeo em MP4, em `attach`, sim (`/arte`, o
veredito na conversa).

⚠️ O artefato do CI não se baixa daqui; lê-se o log (`.claude/rules/plataforma.md`).

**Pendente:** os commits só de documento da branch
`claude/br-port-continuacao-72yq7v` — os tempos das fatias do #154 na `142`
e o registo do bloco seguinte na §7 e no estado —, que precisam de um PR
para chegar à `main`. As fatias lentas dos mutantes: no #153 a 1/3 (~18:30
em dois runners), no #154 a 1 e a 3 (~19:20) com a 2 a 14:10; os nove
mutantes que mudaram de fatia levam o tempo normal, e a causa está por achar
(`142`). O commit `1687ce5` (os tempos do #151 na `138`) ficou na branch
`claude/upbeat-meitner-fkfkne` e nunca chegou à `main`.

**A próxima conversa:** o Bruno já escolheu o bloco seguinte (29/10, §7),
em três tempos — pesquisar, aprofundar cada tema numa conversa própria, e só
então implementar. Ela faz só a pesquisa: mede o jogo de hoje em cada tema,
pesquisa, escreve o documento e pergunta-lhe que temas aprofundar.

Prompt para colar:

```text
Continuando o BR Port. Leia CLAUDE.md, ESTADO_DO_PROJETO.md, a §7 do plano v3
e a decisão 142. Confira a main remota, os PRs abertos e o CI do último
merge, e rode python3 tools/conferir_colaboracao.py com o trabalho commitado
(ele lê o HEAD). A branch claude/br-port-continuacao-72yq7v tem commits só
de documento por fundir (os tempos das fatias do #154 na 142 e o registo do
bloco seguinte na §7): se ainda não estiverem na main, pergunte ao Bruno se
abre o PR; se ele disser que sim, conduza-o até verde antes de começar.

Esta conversa abre o bloco que o Bruno escolheu em 29/10 (§7), em três
tempos: pesquisar, aprofundar cada tema numa conversa própria, e só então
implementar. Aqui é só a PESQUISA — nenhuma linha de jogo muda.

1. Meça o jogo de hoje antes de pesquisar, tema a tema: a foto do jogo a
   1080 (dia 1 e porto completo); a iluminação (o que existe hoje — a luz do
   estúdio Blender nos props, o mapa em SVG, a hora do dia — e o que não
   existe); as animações (os tweens do Main.gd e dos objetos, o que mexe e o
   que está parado, lido com uma sonda ao longo dos frames, gdscript.md); e
   os sons (os efeitos de rascunho de tools/gerar_sons.py, a regra audio.md
   e o protocolo do A6, que só o Bruno ouve).
2. Pesquise técnicas para melhorar a iluminação, as animações e os sons de
   um jogo mobile 2D isométrico de gestão em Godot 4 — e, além delas, os
   outros aspetos que podem melhorar o jogo (por exemplo, a resposta ao
   toque, a clareza do que fazer, o ritmo e a progressão, a interface, o
   desempenho no telefone, a acessibilidade). A busca passa pela ferramenta
   de busca, e as páginas muitas vezes não abrem por este proxy: cite cada
   fonte como pista de padrão, dizendo que a página não foi lida (gerais.md,
   Ambiente).
3. Escreva tudo num documento em docs/, como o
   PESQUISA_RECURSOS_BASICOS_2026-10-15.md: por tema, o estado medido, as
   técnicas achadas com a fonte, o que cada uma custaria aqui (o que já
   existe e ela usa, e o que mexe — mapa, props do Blender, shader, áudio,
   save, desempenho) e o que ganharia. Registe a decisão; o número livre sai
   do conferir_colaboracao.
4. Pergunte ao Bruno que temas aprofundar e por que ordem, com opções e a
   recomendada primeiro, e não escolha por ele. Para cada tema escolhido,
   abra uma conversa nova (create_session, se a ferramenta existir; senão,
   entregue o prompt dela em bloco copiável) que leia o documento, aprofunde
   aquele tema e desenhe a implementação, e que só implemente depois de ele
   aprovar. A implementação vem depois, um item por conversa; arte passa
   pela /arte e som pelo protocolo do A6.

Não implemente nada nesta conversa. Ao encerrar, aplique /fechar-sessao e
entregue o prompt completo da próxima conversa em bloco copiável.
```
