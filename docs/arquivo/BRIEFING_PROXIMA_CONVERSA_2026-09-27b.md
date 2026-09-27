# BR Port — prompt para a próxima conversa (depois da frente 6)

**Como usar:** abra uma conversa nova no repositório `Brunoleon98/br-port` e
cole este texto. Não é preciso anexar o histórico da conversa anterior.

**Modelo: Opus** — a conversa abre com o veredito do Bruno sobre a frente 6
e, a seguir, com a escolha entre a 4 e a 5 (F1). O que vier depois de
decidido desce para **Sonnet** (`CLAUDE.md`, «Qual MODELO faz o quê»).

**Situação:** substitui o `27`. A sessão de 27/09 trabalhou na branch
`claude/fervent-rubin-fs6hnn`, a partir da `main` com o PR #92 fundido, na
**frente 6 do A5** — a escolha do Bruno depois da frente 3, com o escopo
respondido: **a prancha por prop (A/B)** e **a página de escala** (`068`).

1. **`brport_vs/tools/prancha_prop.gd`** — um prop por folha, a versão do
   jogo (A, lida do arquivo) contra a candidata (B) na mesma janela: a foto
   do jogo congelado com a textura trocada, 1:1 sobre o chão com a diferença
   a magenta, a ampliação sem filtro, a silhueta e o valor, a escala entre o
   trabalhador e o camião, e os números. Sem candidata, B = A e ela exige
   Δ zero. Corrida nos 59: todos verdes, 48 vistos, 10 no lugar de um irmão
   do mesmo eixo ou classe, e o órfão.
2. **`brport_vs/tools/escala_props.gd`** — os 59 a 1:1, com o pé na mesma
   linha e o trabalhador de régua.
3. O catálogo e o chão saíram da folha para `catalogo_props.gd`, e as três
   páginas da folha de contato ficaram iguais ao byte.
4. A bateria tem **45 fotos** (`escala` e `prancha`, novas), e o
   `tools/trilha_de_arte.py` ganhou as doze legendas que a frente 3 deixou
   por pôr — sem elas a página do veredito não se montava.

**O veredito está por dar**, e o trabalho está no PR #93, por fundir.

---

## 1. Comece pelo estado real

- Confira no GitHub se o PR #93 (`claude/fervent-rubin-fs6hnn`) foi
  fundido. **Se não foi, o trabalho só existe nele**: a branch da conversa
  seguinte parte dela (`git fetch origin claude/fervent-rubin-fs6hnn`, um ref
  de cada vez), e nunca de uma `main` sem ela.
- Um ref de cada vez no `git fetch`, com o código de saída lido sem cano
  (`CLAUDE.md`, «O que cabe numa sessão»).
- Veja os PRs abertos do Codex antes de mexer num arquivo de alto conflito
  (`AGENTS.md`).
- O CI só corre em PR e na `main` (`CLAUDE.md`, «Como rodar, aqui dentro»).

## 2. O veredito da frente 6

Mostre ao Bruno a `escala.png` e uma prancha A/B de verdade — a da bateria
é B = A, o controle. Uma candidata real sai do Blender
(`python3 tools/gerar_props_iso.py /tmp/cand <prop>`, com o `bpy` instalado;
`/arte`, «Olhe — e olhe AMPLIADO»). Pergunte com opções: aceita, ou o que
muda (as seis linhas da prancha, a ordem da escala, os números).

## 3. O que vem — a escolha é do Bruno

- **4 — Mapa, frota e animação** (Blender, grande): a prancha é a ferramenta
  dela — cada casco, camião e prédio itera-se contra a versão do jogo.
- **5 — O rumo além do VS** (várias sessões): `GameState`, balanceamento e
  `SAVE_VERSION`, pela `/balancear`.
- Pendente de antes: o **galpão V3** que ele aprovou só existe no `art_lab`
  (`art/f01-galpao`) — recuperar ou refazer (`docs/ESTADO_DO_PROJETO.md`, A5).

## 4. O que está com o Bruno

- **A foto do porto antigo** (`art_lab/diario/BRIEFING.md`) e **o fundo e o
  logotipo da tela inicial** (`art_lab/tela_inicial/BRIEFING.md`).
- **A leitura dos textos novos** (A4) e **ouvir os sons** (A6,
  `docs/PROTOCOLO_DE_ESCUTA.md`).

## 5. Lições desta sessão — onde vivem

- ⚠️ Trocar o que está entre dois marcadores apaga o que mora entre eles —
  confira a ordem dos dois e conte as `func` depois (`CLAUDE.md`, «Estilo de
  código»; `068`).
- ⚠️ O irmão que empresta o lugar a um prop partilha o PAPEL dele (o eixo do
  camião, a classe do casco), não só o tamanho: pelo tamanho, um camião
  saiu atravessado na rua (`brport_vs/tools/catalogo_props.gd`, `papeis()`;
  `068`).
- ⚠️ Visível na árvore não é visto: a terceira foto, sem o prop, prova que
  ele chegou à foto do jogo (`brport_vs/tools/prancha_prop.gd`; `068`).
- ⚠️ A escala alinha pelo pé do desenho: o trabalhador é desenhado à altura
  do tabuado do píer (`brport_vs/tools/escala_props.gd`).
- ⚠️ Tiro novo na bateria leva a legenda no mesmo commit, e nada no CI o
  confere (`tools/trilha_de_arte.py`; `068`).
