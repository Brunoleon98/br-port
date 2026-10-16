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

**Pendente do Bruno**: o aceite na foto do jogo (as fotos foram mandadas na
conversa; a bateria do CI as tira de novo no PR); abrir o PR quando quiser;
o recuperado V3, se ainda o quiser, pede a branch `art/f01-galpao` do ChatGPT
publicada ou uma sessão de arte que o refaça pela `036` dele.

Prompt para colar:

```text
Continuando o BR Port. Leia CLAUDE.md, ESTADO_DO_PROJETO.md, a §7 do plano v3
e a decisão 121 (a obra no mapa). Confira a main remota, os PRs abertos e o
CI do último merge, e rode python3 tools/conferir_colaboracao.py.

A branch ccr-a129b41c-mt9dfm traz a obra no mapa como CANDIDATA: píer 2,
armazém e pátio com um quadro por dia de obra, o asfalto do pátio recortado
do mapa pavimentado, o cartão da doca com o prazo, o D45 e sete mutantes
obra-*. Pergunte ao Bruno o veredito das fotos do jogo antes de mexer na
arte; se ele pedir ajustes, refaça pelo gerador (tools/gerar_props_iso.py,
python3.11 com bpy 4.5.0) e fotografe o JOGO, não a prancha. Com o aceite,
escreva-o na 121 e no estado, e abra o PR se ele pedir.

Não comece outra funcionalidade por conta própria. Ao encerrar, aplique
/fechar-sessao e entregue o prompt completo da próxima conversa em bloco
copiável.
```
