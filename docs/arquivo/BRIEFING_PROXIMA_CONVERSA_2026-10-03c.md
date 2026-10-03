# BR Port — prompt para a próxima conversa (depois do degrau 3)

**Como usar:** serve ao **Codex** e a uma sessão nova do **Claude Code**.
Abra uma tarefa nova no repositório `Brunoleon98/br-port`, cole este texto e
escreva por baixo a tarefa que entrega. Não é preciso anexar o histórico da
conversa anterior.

**Situação:** substitui o de 03/10 `b`. A sessão de 03/10 (noite), no Claude
Code, trabalhou na branch `claude/gallant-darwin-qnp6n6`, a partir da `main`
com o PR #101 fundido. Fechou **o degrau 3 da animação** (`079`):

1. **No nível 3, o pórtico descarrega**: gira do porão para terra com o
   carro a recolher, e pousa a carga num pallet a meio do cais.
2. **O trabalhador leva o pallet de empilhadeira** pelo comprimento do píer
   até à pilha da raiz, ou às portas de trás do camião encostado. Os dois
   trabalham o serviço inteiro; o contêiner pousa no cais, como no n2.
3. **A empilhadeira e o pallet ficaram na régua da pessoa**, no cais e no
   pátio: a do pátio tinha a altura de um camião.
4. **No jogo:**
   - as seis suítes estão verdes, e o **D42** reprovou os catorze defeitos
     injetados;
   - a bateria dá `COBERTURA OK`: mudaram as 19 fotos do porto completo, da
     escala e da folha de props (agora 12 páginas), e as outras saíram iguais;
   - o `.pck` cresceu 454.012 bytes contra a `main` (+3,22% do `.pck`).

Teve um GIF, com veredito «Aceito». O Bruno não pediu PR: o trabalho só
existe na branch.

---

Você contribui no BR Port com a tarefa que o Bruno escreveu abaixo deste
texto.

## 1. Antes de tudo

- O Codex lê `AGENTS.md` e, por ele, o `CLAUDE.md` inteiro; o Claude Code já
  tem o `CLAUDE.md` carregado. As regras são as mesmas para os dois.
- Para saber onde o jogo está: `docs/ESTADO_DO_PROJETO.md`. Para o rumo: a §7
  de `docs/design/BR_Port_Plano_v3_Claude_Code.md`.
- **Confira no GitHub se a `claude/gallant-darwin-qnp6n6` virou PR e se foi
  fundida.** Se não foi, a `main` ainda não tem o degrau 3. Arquivos tocados:
  - `tools/gerar_props_iso.py` e `blender/brp_porto.py` (o pórtico, a
    empilhadeira e o pallet) e os 65 PNGs novos em `brport_vs/art/props`,
    com os atlas;
  - `brport_vs/scripts/Dock.gd` e `brport_vs/scenes/dock/Dock.tscn` (os nós
    `Garfo` e `Empilhadeira`);
  - o D39 e o D42 do `teste_design.gd`;
  - `brport_vs/tools/catalogo_props.gd`, `escala_props.gd`,
    `tools/capturar_evidencia.sh` e `tools/trilha_de_arte.py`.

  Se a tarefa tocar neles, diga-o ao Bruno antes de editar.
- Veja os PRs abertos. A próxima decisão livre é a `080`; confira a pasta na
  `main` antes de a usar.

## 2. A tarefa

É a que o Bruno escrever por baixo. **Se ele não escrever nenhuma, pergunte
qual, e não escolha.** Em aberto, para ele escolher:

- **A máquina do contêiner**, no nível 3: uma empilhadeira de contêiner que o
  leva do cais ao pátio, ou o pórtico a pousá-lo no camião. Hoje ele pousa no
  cais, como no n2.
- **A frente 5**, o rumo além do VS: as obras e mais de um trabalhador por
  píer. Mexe no `GameState`, no balanceamento e no `SAVE_VERSION`, e é
  decisão de rumo.
- **Adotar o arnês do gerador**: sem o `view_layer.update()` a cada peça o
  catálogo monta em 3 min em vez de 30+, com os mesmos pixels (plano de arte,
  `079`). É ferramenta, e é decisão dele.

Família nova de arte começa por perguntar o ESCOPO, com opções e a
recomendação primeiro (`/arte`, §8).

## 3. O que está com o Bruno

- a foto do porto antigo (`art_lab/diario/BRIEFING.md`);
- o fundo e o logotipo da tela inicial (`art_lab/tela_inicial/BRIEFING.md`);
- a leitura dos textos novos (A4);
- ouvir os sons (A6, `docs/PROTOCOLO_DE_ESCUTA.md`).

## 4. Lições desta sessão — onde vivem

- ⚠️ O gerador gasta o tempo no `view_layer.update()` de cada peça, e o
  catálogo passou dos 30 min; desligado só nos `primitive_*_add`, 3 min com
  0 px de diferença (`CLAUDE.md`, «Como rodar, aqui dentro»; plano de arte,
  `079`).
- ⚠️ Uma régua de tamanho lê-se sem a sombra de contacto: com ela a
  empilhadeira certa media 2,6x a pessoa (`CLAUDE.md`, «Arte»; D42; `079`).
- ⚠️ Guarda com isenção mede-se com o defeito que mora na isenção: o
  mutante do pallet parado no pouso passou verde, porque a guarda isentava o
  pouso (`CLAUDE.md`, regra 7; D42; `079`).
- ⚠️ Movimento de máquina pergunta-se ao desenho dos cascos antes de se
  escolher: a linha do carro sem giro caía na proa de todos (plano de arte,
  `079`).
- ⚠️ A guarda que refaz a conta do código é espelho: o «não salta» do ciclo
  passou a ser perguntado também ao nó (D42; `CLAUDE.md`, regra 7).
- ⚠️ A pergunta de escopo levou quatro decisões de uma vez, com as
  recomendadas primeiro, e voltou com as quatro; a do sítio, com prévia em
  ASCII, também à primeira (`/arte`, §8).
