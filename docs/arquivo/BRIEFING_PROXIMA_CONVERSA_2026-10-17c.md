# BR Port — o mar que escurece ao largo, aceite; a fila do Bruno acabou

**17/10/2026.** Branch `ccr-67a83145-8bw9um`, a partir da main `7fde0e6`
(PR #138, a vila humilde da `123`, fundido pelo Bruno). Nenhum PR aberto do
Codex nem de outro agente. **Sem PR aberto desta branch.**

**Decisão `124` — o mar que escurece ao largo**, o item 3 (o último) da fila
que o Bruno deu na `121`. Três passagens, «Aceito» na terceira: o degradê do
largo desce até ao fundo da tela (o tom chamado `agua_funda` era o mais
claro), sem manchas cor de baixio no mar aberto e com correntes escuras; a
sombra do muro é raster, esvai a partir dele e já não pinta o terreiro do
degrau; no lugar dos riscos «~», marolas em séries; nas praias, arrebentação
e cáusticas, da pesquisa que ele pediu. A guarda nova é o **D46**
(`casos_mar_ao_largo.gd`), com os dois defeitos no catálogo.

⚠️ O nome de uma cor não é o valor dela; a rampa prova-se pela forma no mapa
(`.claude/rules/mapa.md`).

⚠️ O que se pinta na água depois da terra pergunta se a água está à vista
(`.claude/rules/mapa.md`, `_agua_a_vista` no gerador).

⚠️ O corte medido vale para o desenho medido: a cada passagem de arte, o par
certo/defeito re-mede-se (`.claude/rules/testes-e-guardas.md`).

⚠️ Pedido de pesquisa no «Outro»: a busca devolve resumo, que se cita como
pista, e a técnica entra numa passagem nomeada (`/arte`, §8).

**O que ficou por olhar** (na `124`): animar as marolas — a receita é a da
espuma, numa camada própria em contrafase, ~4,7 MB de VRAM por camada a
1080 —, e o fio diagonal na ponta norte do cais, que já estava na `main`.

**Pendente do Bruno**: abrir o PR desta branch e fundi-lo; escolher o que vem
a seguir, porque a fila que ele deu acabou; o recuperado V3 continua só no
checkout do ChatGPT.

Prompt para colar:

```text
Continuando o BR Port. Leia CLAUDE.md, ESTADO_DO_PROJETO.md, a §7 do plano v3
e a decisão 124 (o mar que escurece ao largo). Confira a main remota, os PRs
abertos e o CI do último merge, e rode python3 tools/conferir_colaboracao.py.

O mar (124) está na branch ccr-67a83145-8bw9um, aceite na foto do jogo. Se o
PR ainda não estiver aberto ou fundido, pergunte ao Bruno se quer o PR
aberto; se ele pedir, abra-o e conduza-o até verde.

A fila que o Bruno deu na 121 acabou (maquinário, cidade, mapa). Pergunte-lhe
o que vem a seguir, com opções e a recomendada primeiro — entre elas o que a
124 deixou por olhar (animar as marolas como a espuma; o fio diagonal na
ponta norte do cais), os gates dele (A4 leitura, A7 playtest pelo Pages) e o
recuperado V3 — e faça um item por conversa. Se for arte, use /arte:
pergunte o escopo antes de mexer e fotografe o JOGO.

Não comece outra funcionalidade por conta própria. Ao encerrar, aplique
/fechar-sessao e entregue o prompt completo da próxima conversa em bloco
copiável.
```
