# BR Port — as marolas que rolam e a quina norte (`142`) aceites; o item seguinte é do Bruno

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

**Pendente:** o commit dos tempos do #154 (acima), que precisa de um PR
para chegar à `main`. As fatias lentas dos mutantes: no #153 a 1/3 (~18:30
em dois runners), no #154 a 1 e a 3 (~19:20) com a 2 a 14:10; os nove
mutantes que mudaram de fatia levam o tempo normal, e a causa está por achar
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
142 está na main (PR #154); os tempos das fatias do #154 ficaram num commit
só de documento na branch claude/br-port-continuacao-72yq7v. Se esse commit
ainda não estiver na main, pergunte ao Bruno se abre o PR dele; se ele
disser que sim, conduza-o até verde antes de começar.

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
