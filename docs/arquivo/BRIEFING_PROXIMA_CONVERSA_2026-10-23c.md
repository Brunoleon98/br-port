# BR Port — as estradas aceites (PR #149); a próxima conversa acelera os testes

**23/10/2026.** Branch `ccr-cce8964c-k07qy0`, da main `fc05203` (PR #144, a
vegetação da `130`) e junta outra vez à main `ed2c770` (PR #147, o fundo da
inicial do Codex) no fecho, e à `bf2eafe` (o #148) em 24/10, quando o Bruno
pediu o **PR #149**. Na junção, o número e o bloco desta branch tinham sido
tomados pelo Codex (a `131` da bancada de texto e o D48 do fundo da inicial),
e o PR #148 dele, aberto antes do push, traz a `134` e a `135`: esta é a
**`136`** e o bloco é o **D49**, renumerados pela
`tools/renumerar_decisao.py`.

**Decisão `136` — as estradas: a rua gasta, a recapeada por partes e as
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

**O que fica, registado na `136`:** na curva de fora o camião passa a 0,2
da linha central e encosta nela por dois pixels; a calçada da quina de
dentro avança 0,095 fora do cerco retangular publicado (nenhum prop pousa
lá).

**Para os sprites de detalhes** (vistos nas fotos desta, não
investigados): postes e placas na calçada nova, carros estacionados,
lixeiras, um ponto de ônibus, e cavaletes de obra ao lado dos cones.

⚠️ O fim do catálogo de mutantes é onde os dois agentes colidem: o bloco
das estradas foi para uma secção própria (`.claude/rules/testes-e-guardas.md`).

**Pendente**: o CI do #149. O job dos mutantes tem 166 entradas, e a ~35 s
cada no CI do #148 isso dá uns 100 dos 120 min do teto.

**A próxima conversa, pedida pelo Bruno em 24/10, não é de arte**: pesquisar
e analisar como acelerar os testes das IAs e do GitHub. A melhoria gráfica
(os sprites de detalhes) volta a seguir.

Prompt para colar:

```text
Continuando o BR Port. Leia CLAUDE.md, ESTADO_DO_PROJETO.md, a §7 do plano v3
e a decisão 117 (o catálogo de mutantes). Confira a main remota, os PRs
abertos e o CI do último merge, e rode python3 tools/conferir_colaboracao.py
com o trabalho commitado (ele lê o HEAD). Se o PR #149 (as estradas, 136)
ainda não estiver na main, pergunte ao Bruno por ele e conduza-o até verde
antes de começar.

O item desta conversa, pedido pelo Bruno, NÃO é de arte: pesquisar e
analisar meios de ACELERAR OS TESTES — os que as IAs (Claude e Codex) correm
no contêiner e os que o GitHub corre no CI —, que hoje demoram bastante. É
uma conversa de medir e decidir (F1 a F4): meça antes de propor.

O que já se sabe, medido (confira antes de herdar):
- No contêiner, em 23/10: run_tests ~26 s, teste_design ~32 s, teste_fumaca
  ~13 s, teste_audio e teste_registro ~0 s; o catálogo inteiro de mutantes
  (140) levou 63 min, em série — cada mutante corre de novo a suíte inteira
  que o deve reprovar, num Godot novo, e os de arte reimportam o projeto.
- No CI do PR #148, o job «Defeitos já provados» chegou aos 90 min com 155
  de 158 mutantes (~35 s cada) e o teto passou a 120
  (docs/arquivo/VERIFICACAO_RB5_2026-10-23/CI_TIMEOUT.md). Hoje são 166.
- As ferramentas partilham user://ferramentas/, e é por isso que nada corre
  em paralelo (CLAUDE.md, «Como rodar»; decisões 061 e 069).

Desenhe a medição: o tempo de cada job do testes.yml e do captura.yml nas
últimas corridas do GitHub Actions, o de cada suíte e de cada mutante aqui,
e onde ele vai (arranque do Godot, --import, corpo da suíte). Depois
pesquise as saídas — paralelismo com uma pasta de dados por processo, o
catálogo partido em vários jobs (matriz), no PR só os mutantes cujo alvo o
diff toca e o catálogo inteiro na main ou à noite, cache do .godot/
importado, um Godot vivo reaproveitado entre mutantes, e o que mais a busca
trouxer —, com o custo, o ganho medido ou estimado e o risco de cada uma
para as guardas. Leve ao Bruno as opções com a recomendada primeiro, e
implemente só o que ele escolher.

Nunca acelerar tirando prova: nenhum mutante, suíte ou guarda sai para
ganhar tempo. Uma mudança no executor ou no workflow prova-se com defeitos
injetados que continuem a reprovar, e com o mesmo MUTANTES OK antes e
depois.

Depois desta conversa a melhoria gráfica volta: o item 3 da fila da 126,
os sprites de detalhes (o que a 136 anotou nas fotos está no briefing
2026-10-23c). Não comece outra funcionalidade por conta própria. Ao
encerrar, aplique /fechar-sessao e entregue o prompt completo da próxima
conversa em bloco copiável — a dos sprites de detalhes.
```
