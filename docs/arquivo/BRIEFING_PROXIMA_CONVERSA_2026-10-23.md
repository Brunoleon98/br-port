# BR Port — as estradas aceites; a próxima conversa é a dos sprites de detalhes

**23/10/2026.** Branch `ccr-cce8964c-k07qy0`, da main `fc05203` (PR #144, a
vegetação da `130`) e junta outra vez à main `ed2c770` (PR #147, o fundo da
inicial do Codex) no fecho. **Sem PR aberto desta branch** — o Bruno não o
pediu nesta conversa. Na junção, o número e o bloco desta branch tinham sido
tomados pelo Codex (a `131` da bancada de texto e o D48 do fundo da inicial):
esta é a **`134`** e o bloco é o **D49**, renumerados pela
`tools/renumerar_decisao.py`.

**Decisão `134` — as estradas: a rua gasta, a recapeada por partes e as
curvas redondas**, o item 2 da fila da `126`. Três passagens, duas
«Ajustar», **aceite** à terceira. A rua do porto em ruínas é gasta
(remendos, fissuras, buracos, óleo, tinta apagada), e a obra do pátio
recapeia-a um trecho por dia, do norte para o sul, com três cones no
trecho seguinte; a linha central é amarela, os acessos são de terra com
sulco e chegam asfaltados com a obra; as quinas de fora do cotovelo são
arcos de 1,38 e as de dentro arredondam a 0,45. O «aparece do nada» do
Bruno eram 26.901 px a trocar fora da obra: hoje são 5. Provas: o **D49**
(novo), o D45 §6 e o D13 §7j contra o arco; oito mutantes.

⚠️ Peça que só encosta não fecha: a de baixo passa por baixo pela
`COSTURA`, e a borda que fecha um polígono fecha à altura do vizinho
(`.claude/rules/mapa.md`, «As estradas»).

⚠️ O que muda entre os dois mapas tem de mudar dentro da obra — o D49 §1
conta os pixels (`.claude/rules/mapa.md`).

⚠️ O contorno das vias é o que a mata lê: detalhe dentro da rua vive em
`vias_detalhes()`, e mudar a forma da rua confere a `mata` da tabela
(`.claude/rules/mapa.md`).

⚠️ O sprite do camião não roda: a curva em arco não lhe serve, e o que o
afasta da quina é o `corte_da_curva()` (`.claude/rules/mapa.md`).

⚠️ O «Outro» do escopo trouxe os dois requisitos que deram forma à
conversa, e a correção escrita numa opção foi medida e não servia
(`.claude/skills/arte/SKILL.md`, §8).

⚠️ O `conferir_colaboracao.py` lê o HEAD: com a `131` e o D48 por commitar
deu «nenhuma decisão nova», e o Codex já tinha fundido os dois números.
Commite antes de o correr (o cabeçalho de `tools/conferir_colaboracao.py`).

**O que fica, registado na `134`:** na curva de fora o camião passa a 0,2
da linha central e encosta nela por dois pixels; a calçada da quina de
dentro avança 0,095 fora do cerco retangular publicado (nenhum prop pousa
lá).

**Para os sprites de detalhes** (vistos nas fotos desta, não
investigados): postes e placas na calçada nova, carros estacionados,
lixeiras, um ponto de ônibus, e cavaletes de obra ao lado dos cones.

**Pendente do Bruno**: pedir o PR desta branch quando quiser — o CI só corre
no PR (`CLAUDE.md`, «Como rodar»).
