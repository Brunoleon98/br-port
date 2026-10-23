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

Prompt para colar:

```text
Continuando o BR Port. Leia CLAUDE.md, ESTADO_DO_PROJETO.md, a §7 do plano v3
e as decisões 126 (a fila) e 134 (as estradas aceites). Confira a main remota,
os PRs abertos e o CI do último merge, e rode
python3 tools/conferir_colaboracao.py — com o trabalho commitado, que ele lê
o HEAD.

As estradas (134) foram ACEITES e vivem na branch ccr-cce8964c-k07qy0, sem
PR, já junta à main de 23/10 (PR #147). Se ela ainda não estiver na main,
pergunte ao Bruno se abre o PR dela e conduza-o até verde antes de começar;
os detalhes partem da main com ela.

O item desta conversa é o 3 e último da fila da 126: os SPRITES DE
DETALHES. Use /arte: fotografe o JOGO (dia 1, um dia da obra do pátio e o
porto completo, e ampliados a rua, as calçadas, o pátio, os acessos aos
berços e a vila), mostre o estado e pergunte ao Bruno o escopo, com opções e
a recomendada primeiro — junte à pergunta, como opções, o que a 134 anotou
nas fotos (postes e placas na calçada nova, carros estacionados, lixeiras,
um ponto de ônibus, cavaletes de obra ao lado dos cones; estão no briefing
2026-10-23) e o que você mesmo encontrar a olhar ampliado. Pergunte também
ONDE cada família vai antes do render (a /arte, §8). Medir antes de mexer;
passagens com prancha antes/depois contra a main e veredito no fim, com a
lista de defeitos que você vê.

Mantenha o que ele já aceitou: as estradas da 134 (a rua gasta e a obra que
a recapeia por trechos, com os cones), a vegetação da 130, a vila da 123, o
mar da 124, e os camiões de mão dupla que encostam de ré nos berços (a
ROTA_ESTRADA, o D20 e o D13 §7j guardam a pista). Prop novo no Cenario
responde às guardas de todos os props.

Fora desta fila, para depois: animar as marolas como a espuma e o fio
diagonal na ponta norte do cais (124), os gates do Bruno (A4 leitura, A7
playtest pelo Pages), o recuperado V3, o que a 130 deixou registado (o ipê
amarelo da borda 63% tapado, as palmeiras jovens pequenas) e o que a 134
deixou (o camião encosta 2 px na linha central na curva de fora; a calçada
da quina de dentro 0,095 fora do cerco). O texto global e o telefone são da
frente do Codex (131 a 133): não mexa neles.

Não comece outra funcionalidade por conta própria. Ao encerrar, aplique
/fechar-sessao e entregue o prompt completo da próxima conversa em bloco
copiável. Se ele aceitar os detalhes, a fila da 126 acaba: pergunte-lhe a
seguinte em vez de a escolher; senão, mais uma volta neles.
```
