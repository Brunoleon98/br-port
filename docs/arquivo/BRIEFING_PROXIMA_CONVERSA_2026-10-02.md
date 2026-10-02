# BR Port — prompt para a próxima conversa (depois do degrau 1 da animação)

**Como usar:** serve ao **Codex** e a uma sessão nova do **Claude Code**.
Abra uma tarefa nova no repositório `Brunoleon98/br-port`, cole este texto e
escreva por baixo a tarefa que entrega. Não é preciso anexar o histórico da
conversa anterior.

**Situação:** substitui o de 01/10. A sessão de 02/10, no Claude Code,
trabalhou na branch `ccr-fb0b3607-sx2bmt`, a partir da `main` com o PR #98
fundido. Abriu a **família animação**, a última da frente 4, e fez o **degrau
1** (`075`):

1. **O trabalhador anda no píer de nível 1.** Vai ao barco de frente e
   vazio, e volta de costas com a caixa de peixe ao ombro até uma pilha no
   meio do tabuado. Tem uma figura por sexo, lida do rosto dele. Os quadros
   são do Blender, e quem anda é o nó.
2. **A família sobe por degrau do porto**, escolha do Bruno depois de ver o
   GIF. No 2, o guindaste tira a carga do barco e ele desengata. No 3 vêm os
   pallets e a empilhadeira. Até lá, nos níveis 2 e 3 ele fica de pé.
3. **No jogo:** as seis suítes estão verdes, o **D39** reprovou os dez
   defeitos injetados, a bateria dá `COBERTURA OK` (a folha de props tem 5
   páginas) e o `.pck` cresceu 33.012 bytes (+0,24%).

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
  fundida.** Se não foi, a `main` ainda não tem o trabalhador que anda.
  Arquivos tocados:
  - `tools/gerar_props_iso.py` (alto conflito);
  - `brport_vs/scripts/Dock.gd` e `brport_vs/scenes/dock/Dock.tscn`;
  - o D39 do `teste_design.gd`;
  - a quinta página da folha no `capturar_evidencia.sh`.

  Se a tarefa tocar neles, diga-o ao Bruno antes de editar.
- Veja os PRs abertos. A próxima decisão livre é a `076`; confira a pasta na
  `main` antes de a usar.

## 2. A tarefa

É a que o Bruno escrever por baixo. **Se ele não escrever nenhuma, pergunte
qual, e não escolha.** Em aberto, para ele escolher:

- **O degrau 2 da animação:** o guindaste tira a carga do barco e o
  trabalhador desengata e leva-a à pilha. O papelão e o saco de ráfia já
  estão desenhados e aprovados, no gerador, fora da regeração completa
  (`PROXIMO_NIVEL`).
- **O degrau 3:** pallets e empilhadeira. A empilhadeira do pátio está fora
  da régua da pessoa (47 px de altura, contra 37 do camião).
- **A transição suave entre turnos**, a outra metade do item 4.
- **A frente 5**, o rumo além do VS. Inclui as obras e, desde 02/10, mais de
  um trabalhador por píer. Mexe no `GameState`, no balanceamento e no
  `SAVE_VERSION`, e é decisão de rumo.

Família nova de arte começa por perguntar o ESCOPO, com opções e a
recomendação primeiro (`/arte`, §8).

## 3. O que está com o Bruno

A foto do porto antigo e o fundo e o logotipo da tela inicial
(`art_lab/diario/BRIEFING.md`, `art_lab/tela_inicial/BRIEFING.md`), a leitura
dos textos novos (A4) e ouvir os sons (A6, `docs/PROTOCOLO_DE_ESCUTA.md`).

## 4. Lições desta sessão — onde vivem

- ⚠️ Arte presa a um predicado pode nunca tocar. Com `progress > 0`, a
  animação do nível 1 ficava muda: o pesqueiro parte no avanço em que o
  `progress` chega a 1, e foram 0 instantes em 449. Meça o predicado no
  estado em que a arte aparece (`CLAUDE.md`, «Arte»; `075`).
- ⚠️ Quem anda é o nó, e todo quadro nasce no mesmo ponto do mundo. A pose
  sai de uma função pura, que o teste pergunta sem esperar frames (plano de
  arte, «o trabalhador que ANDA», em
  `docs/design/BR_Port_Plano_Arte_Blender.md`; `pose_no_ciclo()` no
  `Dock.gd`).
- ⚠️ O `refresh()` de cada turno recomeçava o tween e devolvia-o ao barco a
  meio do caminho. Uma assinatura do estado impede-o (`_animar_trabalho()` em
  `brport_vs/scripts/Dock.gd`; `075`).
- ⚠️ A pergunta de veredito foi dispensada duas vezes, e a resposta veio em
  texto, a abrir o escopo. A pergunta seguinte é de escopo, e não o veredito
  outra vez (`/arte`, §8).
- ⚠️ A ferramenta e a suíte partilham `user://ferramentas/`: não corra a
  bateria de capturas em paralelo com as suítes (`CLAUDE.md`, «Como rodar,
  aqui dentro»).
