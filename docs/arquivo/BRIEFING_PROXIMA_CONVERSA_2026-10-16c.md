# BR Port — a obra no mapa, candidata à espera do aceite

**16/10/2026.** Branch `ccr-a129b41c-mt9dfm`, a partir da main `beb1690`
(PR #135). Nenhum PR aberto do Codex nem ramo dele mais novo do que o fecho do
#134. A conversa retomou a melhoria gráfica da Fase 1 que o Codex começara no
telefone: **nada dela chegou ao GitHub**, e o que ele fez no armazém perdeu-se
com a sessão dele.

**Decisão `121` — a obra no mapa.** O Bruno escolheu ver as obras da `087`
no mapa, contra o armazém recuperado V3 (que só existe no checkout do
ChatGPT): andaime e material, um quadro por dia, sem pessoas, e o cartão da
doca com o prazo.

- **Píer 2** (2 dias): estacas novas com a estrutura e o tabuado empilhado;
  depois o tabuado a meio.
- **Armazém** (2 dias): a ruína limpa com andaime amarelo e chapas novas; depois
  o galpão pronto sem portão e com um terço do telhado por pôr.
- **Pátio** (3 dias): brita e rolo compactador; depois o asfalto a chegar do
  cais (55%, 80%), recortado do mapa pavimentado (`ObraNoMapa.gd`).
- Guarda: o **D45** do teste de design (`tests/casos_obra_no_mapa.gd`) e sete
  defeitos no catálogo (`obra-*`).

⚠️ O estado do meio partilha peças de propósito, nos dois sentidos; a regra do
par continua entre a ruína e o pronto (`.claude/rules/arte.md`).

⚠️ A cópia do pátio e da projeção no `ObraNoMapa.gd` existe porque o JSON das
âncoras não vai no pacote; o D45 confere-a contra a tabela (`121`).

O pátio levou uma segunda passagem a pedido do Bruno: rolo compactador de um
tambor (5,8 m, pela régua da pessoa) e asfalto a 55% e 80%. O **PR foi aberto
a pedido dele antes do aceite**.

**A fila que ele deu, por esta ordem** (plano v3, §7): (1) o design do
maquinário de obra; (2) as estruturas da cidade; (3) o mapa — a sombra
QUADRADA nos píeres e o mar com áreas claras ao fundo, «como se fosse mais
raso». Pistas por medir, não conclusões: as manchas de corrente do mar são
gradientes radiais, e o `mrasa` usa a cor do BAIXIO; e no dicionário `C` a
`agua_funda` (`#0f5a7d`) é mais clara do que a `agua` (`#0d4d6b`) — ver
`gerar()` em `tools/gerar_mapa_iso.py`.

**Pendente do Bruno**: o aceite na foto do jogo e o merge do PR; o
recuperado V3, se ainda o quiser, pede a branch `art/f01-galpao` do ChatGPT
publicada ou uma sessão de arte que o refaça pela `036` dele.

Prompt para colar:

```text
Continuando o BR Port. Leia CLAUDE.md, ESTADO_DO_PROJETO.md, a §7 do plano v3
e a decisão 121 (a obra no mapa). Confira a main remota, os PRs abertos e o
CI do último merge, e rode python3 tools/conferir_colaboracao.py.

A obra no mapa (121) está no PR da branch ccr-a129b41c-mt9dfm, aberto a
pedido do Bruno antes do aceite. Veja se foi fundido e o CI dele; se não,
pergunte o veredito das fotos e conduza o PR até verde.

Depois, a fila que o Bruno deu (§7 do plano), um item por conversa e por
esta ordem: (1) melhorar o design do maquinário de obra (o rolo compactador
do pátio, em tools/gerar_props_iso.py); (2) as estruturas da cidade; (3) o
mapa — as melhorias que achar e as que ele viu: a sombra quadrada nos
píeres e o mar que clareia ao fundo «como se fosse mais raso» (as pistas
estão no briefing 2026-10-16c; meça antes de mexer). Use /arte: pergunte o
escopo e a composição antes do render, e fotografe o JOGO, não a prancha
(Blender: python3.11 com bpy 4.5.0).

Não comece outra funcionalidade por conta própria. Ao encerrar, aplique
/fechar-sessao e entregue o prompt completo da próxima conversa em bloco
copiável.
```
