# BR Port — prompt para a próxima conversa (depois do pau-de-carga)

**Como usar:** serve ao **Codex** e a uma sessão nova do **Claude Code**.
Abra uma tarefa nova no repositório `Brunoleon98/br-port`, cole este texto e
escreva por baixo a tarefa que entrega. Não é preciso anexar o histórico da
conversa anterior.

**Situação:** substitui o de 02/10 da manhã. A sessão de 02/10, no Claude
Code, trabalhou na branch `ccr-fb0b3607-sx2bmt`, a partir da `main` com o PR
#98 fundido. Abriu a **família animação**, a última da frente 4, e fechou o
**degrau 1** em duas passagens (`075`, `076`):

1. **O pau-de-carga do píer de nível 1 descarrega.** Gira do porão do
   pesqueiro até uma pilha no tabuado, com caixas de peixe numa cinta, e volta
   vazio. O trabalhador opera o guincho ao pé do mastro, com uma figura por
   sexo, lida do rosto. São dezoito quadros do Blender para o pau e dois por
   sexo para a alavanca.
2. **O andar da manhã saiu do jogo.** Com a caixa ao ombro, o Bruno pediu o
   que um porto faz: *«é ele [o guindaste] que sempre fará isso»*.
3. **A família sobe por degrau do porto.**
   - No 2, o guindaste tira a carga e ele desengata.
   - No 3 vêm os pallets e a empilhadeira.
   - A **ida ao camião**, nos serviços de mais de um turno, vem com o 2 e o 3:
     só os cargueiros duram mais de um turno, e só atracam nesses níveis.
4. **No jogo:**
   - as seis suítes estão verdes, e o **D39** reprovou os doze defeitos
     injetados;
   - a bateria dá `COBERTURA OK`;
   - o `.pck` cresceu 168.264 bytes contra a `main` (+1,24% do `.pck`).

O Bruno não pediu PR: o trabalho só existe na branch.

---

Você contribui no BR Port com a tarefa que o Bruno escreveu abaixo deste
texto.

## 1. Antes de tudo

- O Codex lê `AGENTS.md` e, por ele, o `CLAUDE.md` inteiro; o Claude Code já
  tem o `CLAUDE.md` carregado. As regras são as mesmas para os dois.
- Para saber onde o jogo está: `docs/ESTADO_DO_PROJETO.md`. Para o rumo: a §7
  de `docs/design/BR_Port_Plano_v3_Claude_Code.md`.
- **Confira no GitHub se a `ccr-fb0b3607-sx2bmt` virou PR e se foi
  fundida.** Se não foi, a `main` ainda não tem o pau-de-carga que
  descarrega. Arquivos tocados:
  - `tools/gerar_props_iso.py` (alto conflito);
  - `brport_vs/scripts/Dock.gd` e `brport_vs/scenes/dock/Dock.tscn`;
  - o D39 do `teste_design.gd`;
  - `brport_vs/tools/escala_props.gd` e `catalogo_props.gd`.

  Se a tarefa tocar neles, diga-o ao Bruno antes de editar.
- Veja os PRs abertos. A próxima decisão livre é a `077`; confira a pasta na
  `main` antes de a usar.

## 2. A tarefa

É a que o Bruno escrever por baixo. **Se ele não escrever nenhuma, pergunte
qual, e não escolha.** Em aberto, para ele escolher:

- **O degrau 2 da animação:** o guindaste do nível 2 tira a carga do barco e
  o trabalhador leva-a. A ida ao camião vem junto. O papelão e o saco de
  ráfia já estão desenhados e aprovados no gerador, fora da regeração
  completa (`PROXIMO_NIVEL`). As pilhas deles ainda pousam no fim do caminho
  do andar antigo.
- **O degrau 3:** pallets e empilhadeira. A empilhadeira do pátio está fora
  da régua da pessoa (47 px de altura, contra 37 do camião).
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

- ⚠️ Numa animação, o escopo pergunta primeiro quem faz o ofício no porto,
  naquele nível. A caixa ao ombro passou o escopo e o GIF e caiu no mesmo
  dia (`/arte`, §8; `076`).
- ⚠️ Arte presa a um predicado pode nunca tocar. Com `progress > 0`, a
  animação do nível 1 ficava muda: foram 0 instantes em 449 (`CLAUDE.md`,
  «Arte»; `075`).
- ⚠️ A geometria de uma animação sai das peças que existem. Com o alcance
  antigo, o gancho descia na água; apontado ao costado, descia na proa
  (`tools/gerar_props_iso.py`, no `R_N1`; `076`).
- ⚠️ A banda da pilha foi medida com o defeito regerado de verdade, pilhas de
  2 e 4 andares, e o corte ficou no meio (`brport_vs/tests/teste_design.gd`,
  `D39_PILHA_DY_MIN`; `076`).
- ⚠️ Arte distinta não prova que o nó a usa. A alavanca parada só reprovou
  numa guarda nova da doca montada (`brport_vs/tests/teste_design.gd`, D39;
  `076`).
- ⚠️ A tira de passos de uma prévia sai dos PNGs, não do GIF: o GIF otimizado
  funde quadros iguais, 59 viraram 26 (plano de arte, «o pau-de-carga que
  descarrega», em `docs/design/BR_Port_Plano_Arte_Blender.md`).
- ⚠️ A página de escala conta cada animação pelo quadro de repouso. Os dezoito
  quadros do pau faziam-na transbordar (`brport_vs/tools/escala_props.gd`;
  `076`).
- ⚠️ A ferramenta e a suíte partilham `user://ferramentas/`: não corra a
  bateria de capturas em paralelo com as suítes (`CLAUDE.md`, «Como rodar,
  aqui dentro»).
