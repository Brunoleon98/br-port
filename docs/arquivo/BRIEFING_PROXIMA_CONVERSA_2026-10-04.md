# BR Port — prompt para a próxima conversa (depois do arnês)

**Como usar:** serve ao **Codex** e a uma sessão nova do **Claude Code**.
Abra uma tarefa nova no repositório `Brunoleon98/br-port`, cole este texto e
escreva por baixo a tarefa que entrega. Não é preciso anexar o histórico da
conversa anterior.

**Situação:** substitui o de 03/10 `c`. A sessão de 03–04/10, no Claude Code,
trabalhou na branch `claude/sleepy-cray-dp9dlo`, a partir da `main` com o PR
#102 fundido, e abriu o **PR #103**. Adotou o **arnês do gerador** (`080`):

1. **`primitiva()`** em `tools/gerar_props_iso.py` cria as primitivas do kit e
   dos retratos sem o `view_layer.update()` que o `bpy.ops` faz antes e
   depois de cada operador. O estúdio do porto (3.791 objetos) monta em
   ~110 s.
2. **`--despejar=<arquivo>`** nos dois geradores monta a cena, escreve-a em
   texto e sai sem render; **`BRP_CAMINHO_LENTO=1`** volta ao caminho de
   sempre. A prova é que os dois despejos saem iguais byte a byte.
3. **A prova**: a régua não tem ruído próprio (o mesmo caminho duas vezes dá os
   mesmos bytes); vê o defeito que o arnês pode causar (um mutante que lê a
   medida velha de uma peça); terreno, cidade e fauna saem iguais nos dois
   caminhos. O porto e o base estavam a correr pelo caminho lento no fecho: o
   resultado e os tempos estão na tabela «A prova» da `080`.
4. **No jogo nada muda.** As seis suítes passaram, e o `.pck` não mexe.

**Prioridade do Bruno: a melhoria de design** (plano v3, §7).

---

Você contribui no BR Port com a tarefa que o Bruno escreveu abaixo deste
texto.

## 1. Antes de tudo

- O Codex lê `AGENTS.md` e, por ele, o `CLAUDE.md` inteiro; o Claude Code já
  tem o `CLAUDE.md` carregado. As regras são as mesmas para os dois.
- Para saber onde o jogo está: `docs/ESTADO_DO_PROJETO.md`. Para o rumo: a §7
  de `docs/design/BR_Port_Plano_v3_Claude_Code.md`.
- **Confira no GitHub se o PR #103 foi fundido.** Se não foi, a `main` ainda
  não tem o arnês. Arquivos tocados: `tools/gerar_props_iso.py`,
  `blender/brp_retratos.py`, `blender/gerar_brp.py`, o `CLAUDE.md`, os dois
  planos, o estado e a `080`. Se a tarefa tocar neles, diga-o ao Bruno antes
  de editar.
- Veja os PRs abertos. A próxima decisão livre é a `081`; confira a pasta na
  `main` antes de a usar.

## 2. A tarefa

É a que o Bruno escrever por baixo. **Se ele não escrever nenhuma, a tarefa é
a melhoria de design**, que é a prioridade dele — e o pedido não diz o que
corrigir. Abra com a pergunta do ESCOPO, com opções e a recomendada primeiro,
dizendo porquê (`/arte`, §8): o mapa e os props, a interface do HUD e dos
painéis, as telas narrativas, ou o design de jogo. Não escolha por ele.

Ficam em aberto, atrás dela:

- **A máquina do contêiner**, no nível 3: hoje ele pousa no cais, como no n2.
- **A frente 5**, o rumo além do VS: as obras e mais de um trabalhador por
  píer. Mexe no `GameState`, no balanceamento e no `SAVE_VERSION`.

## 3. O que está com o Bruno

- a foto do porto antigo (`art_lab/diario/BRIEFING.md`);
- o fundo e o logotipo da tela inicial (`art_lab/tela_inicial/BRIEFING.md`);
- a leitura dos textos novos (A4);
- ouvir os sons (A6, `docs/PROTOCOLO_DE_ESCUTA.md`).

## 4. Lições desta sessão — onde vivem

- ⚠️ Com o arnês, a `dimensions` e a `matrix_world` de uma peça ficam velhas
  depois de criada a seguinte: quem posiciona uma peça pela medida de outra
  pede o `update()` antes (`CLAUDE.md`, «Como rodar»; `080`).
- ⚠️ A malha do Blender não é estável na ordem: a esfera primitiva troca a
  ordem das faces a cada chamada, e o chanfro avaliado mexe 1 ULP nas UVs.
  Quem compara duas cenas compara a malha original, cego à ordem
  (`CLAUDE.md`, «Arte»; `080`).
- ⚠️ A régua mentiu duas vezes antes de valer: o mesmo caminho, corrido duas
  vezes, tem de dar os mesmos bytes antes de se compararem os dois caminhos
  (`CLAUDE.md`, regra 7; `080`).
