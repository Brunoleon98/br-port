# BR Port — briefing para a próxima conversa (12/10/2026)

```text
Continuando o BR Port. Leia docs/ESTADO_DO_PROJETO.md e a §7 do plano v3.

Confira na main pelo GitHub se o PR do rosto do Toninho foi fundido (branch
claude/relaxed-babbage-l6ope6: os três retratos em art/props, a _cupula e o
_material_crespo no estúdio, a decisão 100) e se há PR aberto do Codex antes
de editar. A última decisão é a 100; confira o próximo número livre na main.

Faça o TUTORIAL CURTO, no recorte desenhado na 100: o Toninho guia, só no
dia 1 de partida nova, por cima do jogo (objeto do Main, sem fase no
GameState e sem campo no save) — atracar (calmo), avançar (irônico) e, se o
dia virar antes de atracar, o aviso sério. No mesmo commit: as falas na
Narrativa.gd com o gatilho, o registro do rosto (Retratos.gd e
Narrativa.EXPRESSOES) e o tom do balão com a quarta voz do D38. As falas são
rascunho para a leitura do A4. Um item só.
```

O rosto do Toninho foi aceite pelo Bruno na foto do jogo, na v6, ao fim de
seis voltas (`100`, `art_lab/retratos/toninho/README.md`). Os três PNG estão
em `brport_vs/art/props/` e no manifest, mas **sem registro** no `Retratos.gd`:
o F7 do `teste_fumaca` reprova cara registada que nenhuma fala pede, logo o
registro entra com as falas.

O job «Publicar no Pages» da main saiu verde em 11/10: a fonte já está em
«GitHub Actions» e o Web da main está no ar. Falta do A7 o que é do Bruno.

⚠️ As três caras têm de ter fala cada uma — o sério só tem a do dia que vira
antes de atracar; sem ela fica muda e o F7 reprova (`100`, «O recorte do
tutorial»).

⚠️ O tom do balão lê-se do PNG, não do hex da paleta: o D38 confere o matiz da
roupa pela mediana do tronco, e a camisa do Toninho divide o tronco com o
pano branco (`art_lab/retratos/toninho/README.md`, «O tom do balão»).

⚠️ O objeto do tutorial liga-se ao `GameState` por método, nunca por lambda
(`.claude/rules/gdscript.md`), e é overlay, nunca fase
(`.claude/rules/interface.md`).
