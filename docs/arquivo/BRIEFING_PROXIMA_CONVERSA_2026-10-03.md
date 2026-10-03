# BR Port — prompt para a próxima conversa (depois do guindaste do nível 2)

**Como usar:** serve ao **Codex** e a uma sessão nova do **Claude Code**.
Abra uma tarefa nova no repositório `Brunoleon98/br-port`, cole este texto e
escreva por baixo a tarefa que entrega. Não é preciso anexar o histórico da
conversa anterior.

**Situação:** substitui o de 02/10 `b`. A sessão de 02–03/10, no Claude Code,
trabalhou na branch `claude/elegant-edison-783iy6`, a partir da `main` com o
PR #99 fundido. Fechou o **degrau 2** da família animação (`077`):

1. **O guindaste do píer de nível 2 descarrega**, no primeiro turno do
   serviço. Gira do porão a uma pilha no tabuado com a carga do serviço:
   peixe, caixas de papelão, sacos de ráfia ou um contêiner em quatro cintas.
   O trabalhador desengata-a ao lado da pilha, com uma figura por sexo.
2. **Nos turnos seguintes ele leva a carga ao camião**, ao ombro, se o camião
   do serviço estiver no berço; sem ele, espera ao pé da pilha. O contêiner
   fica na pilha: sai pelo pátio no nível 3.
3. **O camião passou a encostar de ré**, nas duas rotas, e ele entrega pelas
   portas de trás. Foi pedido do Bruno: *«como se estivesse colocando a carga
   lá»*.
4. **A segunda vista apanhou o trabalhador por cima do armazém na doca 2.** As
   docas desenham-se depois do cenário, e nenhuma guarda o via. Hoje o
   **D40 §6** pergunta-o.
5. **No jogo:**
   - as seis suítes estão verdes, e o **D40** e o D13 reprovaram os
     dezassete defeitos injetados;
   - a bateria dá `COBERTURA OK`, com a folha de props em nove páginas e um
     tiro novo, o `guindaste2`; o `docas` passou a 1000 frames, porque a 400
     nenhum camião estava encostado (já na `main`);
   - o `.pck` cresceu 404.260 bytes contra a `main` (+2,95% do `.pck`).

O PR é o #100 (`Brunoleon98/br-port`), aberto pelo Bruno no fim da sessão.

---

Você contribui no BR Port com a tarefa que o Bruno escreveu abaixo deste
texto.

## 1. Antes de tudo

- O Codex lê `AGENTS.md` e, por ele, o `CLAUDE.md` inteiro; o Claude Code já
  tem o `CLAUDE.md` carregado. As regras são as mesmas para os dois.
- Para saber onde o jogo está: `docs/ESTADO_DO_PROJETO.md`. Para o rumo: a §7
  de `docs/design/BR_Port_Plano_v3_Claude_Code.md`.
- **Confira no GitHub se o PR #100 (`claude/elegant-edison-783iy6`) foi
  fundido.** Se não foi, a `main` ainda não tem o guindaste do nível 2.
  Arquivos tocados:
  - `tools/gerar_props_iso.py` (alto conflito);
  - `brport_vs/scripts/Dock.gd`, `brport_vs/scenes/dock/Dock.tscn` e
    `brport_vs/scripts/Main.gd` (a manobra de ré e as portas do camião);
  - o D13, o D39 e o D40 do `teste_design.gd`;
  - `brport_vs/tools/escala_props.gd`, `catalogo_props.gd`,
    `tools/capturar_evidencia.sh` e `tools/trilha_de_arte.py`.

  Se a tarefa tocar neles, diga-o ao Bruno antes de editar.
- Veja os PRs abertos. A próxima decisão livre é a `078`; confira a pasta na
  `main` antes de a usar.

## 2. A tarefa

É a que o Bruno escrever por baixo. **Se ele não escrever nenhuma, pergunte
qual, e não escolha.** Em aberto, para ele escolher:

- **O degrau 3:** pallets e empilhadeira no nível 3. A empilhadeira do pátio
  está fora da régua da pessoa (47 px de altura, contra 37 do camião). O
  contêiner do nível 2 fica na pilha à espera dele.
- **A transição suave entre turnos**, a outra metade do item 4.
- **A frente 5**, o rumo além do VS: as obras e mais de um trabalhador por
  píer. Mexe no `GameState`, no balanceamento e no `SAVE_VERSION`, e é
  decisão de rumo.

Família nova de arte começa por perguntar o ESCOPO, com opções e a
recomendação primeiro (`/arte`, §8).

## 3. O que está com o Bruno

- a foto do porto antigo (`art_lab/diario/BRIEFING.md`);
- o fundo e o logotipo da tela inicial (`art_lab/tela_inicial/BRIEFING.md`);
- a leitura dos textos novos (A4);
- ouvir os sons (A6, `docs/PROTOCOLO_DE_ESCUTA.md`).

## 4. Lições desta sessão — onde vivem

- ⚠️ As docas desenham-se depois do cenário, e a ordem de nó só é
  profundidade entre irmãos. A entrega no flanco punha o trabalhador 117 px
  por cima do armazém na doca 2 (`CLAUDE.md`, «Projeção isométrica»; `077`).
- ⚠️ O GIF seguido da pergunta, no mesmo turno, voltou 4 de 4; uma pergunta
  dele no «Outro» era um defeito (`/arte`, §8; `077`).
- ⚠️ A carga pendurada vive num nó seu quando a peça que a leva é grande:
  36 lingadas pequenas em vez de 36 lanças grandes (plano de arte, «o
  guindaste do nível 2 e a ida ao camião»; `077`).
- ⚠️ O ponto de entrega lê-se do desenho do camião que parou; a traseira vai
  de 0,60 a 0,76 da âncora (`brport_vs/scripts/Main.gd`,
  `portas_do_camiao()`; `077`).
- ⚠️ A lingada mede-se dentro do casco pelo ponto de BAIXO; no centro as
  cintas puxam-no para cima (`brport_vs/tests/teste_design.gd`, D40; `077`).
- ⚠️ Rodar um boneco no gerador é pela `matrix_basis`; a `matrix_world` só
  se atualiza no passo seguinte do grafo (`tools/gerar_props_iso.py`,
  `_girar()`).
- ⚠️ Na bateria, a ida ao camião não tem foto: com a semente do
  `guindaste2` nenhum camião encostou em 3.000 frames. E o `docas` prometia
  dois camiões encostados e não mostrava nenhum (`tools/capturar_evidencia.sh`,
  nos dois tiros; `077`).
- ⚠️ A ferramenta e a suíte partilham `user://ferramentas/`: não corra a
  bateria de capturas em paralelo com as suítes (`CLAUDE.md`, «Como rodar,
  aqui dentro»).
