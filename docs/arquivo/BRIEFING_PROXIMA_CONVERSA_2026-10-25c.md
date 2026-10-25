# BR Port — as marolas que rolam e a quina norte (`142`) aceites; o item seguinte é do Bruno

**25/10/2026.** Branch `claude/br-port-continuacao-72yq7v`, a partir da
cabeça do PR #153 (`66cb96c`, a `141`, verde no runner e por fundir), porque
as duas mexem no `gerar_mapa_iso.py`. Esta branch não tem PR: ele não o
pediu. Quando o #153 fundir, o PR desta mostra só a `142`.

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

**Pendente:** o #153 (a `141`) por fundir, e depois o PR desta branch, que é
decisão do Bruno — com ele o catálogo passa a 230 mutantes. A fatia 1/3 dos
mutantes levou ~18:30 nas duas corridas do #153, em runners diferentes,
contra 11–13 min das outras: é o que ela leva, e não se apurou que mutantes
(`142`). O commit `1687ce5` (os tempos do #151 na `138`) ficou na branch
`claude/upbeat-meitner-fkfkne` e nunca chegou à `main`. Fora deste item: o
vigia de frames do `teste_design`.

**A próxima conversa:** o item seguinte é do Bruno. Ela abre a
perguntar-lho, com opções e a recomendada primeiro, sem escolher por ele.

Prompt para colar:

```text
Continuando o BR Port. Leia CLAUDE.md, ESTADO_DO_PROJETO.md, a §7 do plano v3
e a decisão 142 (as marolas que rolam e a quina norte, aceite). Confira a
main remota, os PRs abertos e o CI do último merge, e rode python3
tools/conferir_colaboracao.py com o trabalho commitado (ele lê o HEAD). A
branch da 142 (claude/br-port-continuacao-72yq7v) arranca da cabeça do PR
#153 (a 141). Se a 142 ainda não estiver na main, pergunte ao Bruno se abre
o PR dela (depois de o #153 fundir, para ele mostrar só a 142); se ele disser
que sim, conduza-o até verde antes de começar: o catálogo passou de 221 para
230 mutantes e o teste_design ganhou o D51 — leia o tempo de cada fatia de
mutantes, registe-o na 142, e diga se a fatia 1/3 continua a ser a lenta.

O item seguinte é do Bruno. Abra a conversa com a pergunta do que vem a
seguir, com opções e a recomendada primeiro, e não escolha por ele. O que
está nomeado e por fazer: as quinze lacunas médias que a 138 deixou de fora
(treze visuais, uma de texto, uma fora do headless); o galpão recuperado V3;
trabalhadores e crédito; o vigia de frames do teste_design (142); e os gates
A4 e A7, que são dele. Se ele escolher arte, use /arte e comece pela foto do
jogo e pela pergunta do escopo.

Não comece outra funcionalidade por conta própria. Ao encerrar, aplique
/fechar-sessao e entregue o prompt completo da próxima conversa em bloco
copiável.
```
