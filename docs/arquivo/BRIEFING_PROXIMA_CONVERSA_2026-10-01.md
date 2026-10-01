# BR Port — prompt para o Codex (depois da ruína)

**Como usar:** é para o **Codex**. Abra uma tarefa nova no repositório
`Brunoleon98/br-port`, cole este texto e escreva por baixo a tarefa que lhe
entrega. Não é preciso anexar o histórico da conversa anterior.

**Situação:** substitui o de 28/09 (`28b`). A sessão de 28/09 a 01/10, no
Claude Code, trabalhou na branch `claude/determined-wright-ft66hv`, a partir
da `main` com o PR #97 fundido, e **fechou a família ruína da frente 4**
(`074`):

1. **O galpão em ruína** é o mesmo galpão do porto pronto, velho. Tem doca
   partida, chapa e zinco com ferrugem, lona azul presa por pneus, portão de
   enrolar caído e o esqueleto de aço à vista no lado do cais. É a leitura V3
   que o Bruno aprovou com o ChatGPT, refeita daqui.
2. **O escritório em ruína** é o canto de alvenaria de antes, com reboco
   caído, quina lascada e umidade. Tem o toldo azul rasgado, a placa amarela
   caída, telha laranja no chão e uma árvore a crescer lá dentro.
3. **Os dois estão no jogo** (`art/props` e o atlas). As seis suítes estão
   verdes, a bateria de capturas dá `COBERTURA OK` e o `.pck` cresceu 9.264
   bytes.

O trabalho está no **PR #98**, por fundir.

---

Você é o Codex, a contribuir no BR Port com a tarefa que o Bruno escreveu
abaixo deste texto.

## 1. Antes de tudo

- Leia `AGENTS.md` e, por ele, o `CLAUDE.md` inteiro: as regras do projeto
  são as mesmas para os dois agentes. Onde parecerem divergir, vale o
  `CLAUDE.md`.
- Para saber onde o jogo está: `docs/ESTADO_DO_PROJETO.md`. Para o rumo: a §7
  de `docs/design/BR_Port_Plano_v3_Claude_Code.md`.
- **Confira no GitHub se o PR #98 (`claude/determined-wright-ft66hv`) foi
  fundido.** Se não foi, a `main` ainda tem a ruína antiga, e o
  `tools/gerar_props_iso.py` (alto conflito) tem 500 linhas novas nessa
  branch. Se a sua tarefa tocar nele, nos props ou na `Main.tscn`, diga-o ao
  Bruno antes de editar.
- Veja os PRs abertos, e trabalhe numa branch `codex/<tema>` a partir da
  `main`, com entrega por PR. A próxima decisão livre é a `075`; confira a
  pasta na `main` antes de a usar.

## 2. A tarefa

É a que o Bruno escrever por baixo. **Se ele não escrever nenhuma, pergunte
qual, e não escolha** (`AGENTS.md`, §2). O que está em aberto, para ele
escolher:

- **A família animação**, a última da frente 4 (plano v3, §7, item 4): o
  trabalhador animado (andar, pallets, empilhadeira) e uma transição suave
  entre turnos. É sistema novo e pede mais de uma sessão. Família nova de arte
  começa por perguntar o ESCOPO, com opções e a recomendação primeiro
  (`/arte`, §8).
- **A frente 5**, o rumo além do VS (plano v3, §7): mexe no `GameState`, no
  balanceamento e no `SAVE_VERSION`, e é decisão de rumo.
- **As obras** (um estado «em obra» de um prédio comprado) ficaram fora da
  ruína por pedirem mecânica; pertencem à frente 5 (`074`).

## 3. O que está com o Bruno

A foto do porto antigo e o fundo e o logotipo da tela inicial
(`art_lab/diario/BRIEFING.md`, `art_lab/tela_inicial/BRIEFING.md`), a leitura
dos textos novos (A4) e ouvir os sons (A6, `docs/PROTOCOLO_DE_ESCUTA.md`).

## 4. Lições desta sessão — onde vivem

- ⚠️ A COMPOSIÇÃO de uma família inteira pergunta-se antes do render, com uma
  prévia em ASCII das duas faces que a câmara vê. Ele escolheu as
  recomendadas, e a primeira candidata mostrada foi aceite (`/arte`, §8;
  `074`).
- ⚠️ O envio da prancha tende a ser o fim do turno: duas de duas vezes a
  pergunta seguinte não chegou. Escreva na legenda a pergunta e as opções, e
  leia a resposta em texto («Ficou bom») como veredito (`/arte`, §8).
- ⚠️ Somar ruído à oclusão contorna TODAS as arestas. A quina lascada é o
  produto de duas máscaras (`material_alvenaria_velha()` em
  `tools/gerar_props_iso.py`; plano de arte, C3, em
  `docs/design/BR_Port_Plano_Arte_Blender.md`).
- ⚠️ Um nome num laço do `montar()` sombreia a função do módulo com o mesmo
  nome: o `z` voltou a cair, e a `copa`. O laço usa `zt`, e o aviso está ao
  lado (`tools/gerar_props_iso.py`; `074`).
- ⚠️ A ferramenta e a suíte partilham `user://ferramentas/`: não corra a
  bateria de capturas em paralelo com as suítes (`CLAUDE.md`, «Como rodar,
  aqui dentro»).
