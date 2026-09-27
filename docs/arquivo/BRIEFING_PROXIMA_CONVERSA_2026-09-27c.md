# BR Port — prompt para a próxima conversa (os 32 camiões no jogo)

**Como usar:** abra uma conversa nova no repositório `Brunoleon98/br-port` e
cole este texto. Não é preciso anexar o histórico da conversa anterior.

**Modelo: Opus no começo, Sonnet depois** — a conversa abre por desenhar a
chave que escolhe a transportadora e as guardas novas (F1/F6); gerar os 32,
reimportar, fotografar e fechar desce para **Sonnet** (`CLAUDE.md`, «Qual
MODELO faz o quê»).

**Situação:** substitui o `27b`. A sessão de 27/09 trabalhou na branch
`claude/happy-maxwell-iajyvi`, a partir da `main` com o PR #93 fundido. O
Bruno aceitou a frente 6 («Aceito como está») e abriu a **frente 4** pela
família **escala e camiões** (`069`):

1. **A régua da pessoa a 1,5× o real** (`REGUA_DA_PESSOA` 0,48 em
   `tools/gerar_props_iso.py`), medida no contêiner e na cabine do camião; o
   trabalhador está no jogo assim. **A fauna ficou como estava**, escolha
   dele, e o D25 passou a «nenhum bicho abaixo da pessoa nem chega ao barco».
2. **O carro e o pedestre** de referência em `brport_vs/tools/referencia/`,
   só na página de escala.
3. **As duas transportadoras por serviço** (`EMPRESAS` em
   `blender/brp_porto.py`), com o bicudo nos três médios e todos os detalhes,
   **aceites na quarta candidata**. Os PNGs de camião do jogo ainda são os de
   antes.

O Bruno não pediu PR: o trabalho só existe na branch.

---

## 1. Comece pelo estado real

- Confira no GitHub se a `claude/happy-maxwell-iajyvi` virou PR e se foi
  fundida. Se não foi, a branch da conversa seguinte parte dela
  (`git fetch origin claude/happy-maxwell-iajyvi`, um ref de cada vez).
- Veja os PRs abertos do Codex antes de mexer no `Main.gd` ou no
  `teste_design.gd` (`AGENTS.md`).
- Precisa do `bpy` (`CLAUDE.md`, «Como rodar»: `pip download` primeiro).

## 2. A passagem: os 32 camiões no jogo

A lista vem da `069`, «O que fica para a passagem seguinte»:

- `_registrar_caminhoes()` regista as duas empresas (a 1 com `_b` no nome,
  como na candidata: `caminhao_<serviço>_b<sufixo>`), e o `gerar_brp.py porto`
  gera as 32 para `art/props`. A empresa 0 também muda, porque os detalhes
  valem para as duas; os `.import` dos 16 novos passam a `texture_atlas`, e o
  `--import` corre duas vezes.
- A tabela `CAMINHOES` do `Main.gd` por empresa, e a chave que escolhe a
  empresa em cada viagem **sem consumir o `_rng` do `GameState`**.
- A guarda de alcançabilidade: as 32 aparecem.
- O **D35** com o chassi por empresa, porque o bicudo é mais comprido (o
  maior fica com os 1,96 da carreta).
- A folha dos camiões, o manifest, a bateria e o `.pck` medido.

## 3. Depois — a escolha é do Bruno

As outras famílias da 4 (frota, ruína e obras, animação), a 5 (o rumo além
do VS) e o galpão V3 que só existe no `art_lab` (`docs/ESTADO_DO_PROJETO.md`,
A5).

## 4. O que está com o Bruno

A foto do porto antigo e o fundo e o logotipo da tela inicial
(`art_lab/diario/BRIEFING.md`, `art_lab/tela_inicial/BRIEFING.md`); a leitura
dos textos novos (A4) e ouvir os sons (A6, `docs/PROTOCOLO_DE_ESCUTA.md`).

## 5. Lições desta sessão — onde vivem

- ⚠️ Medida de prop lê-se no PNG, ou depois de toda escala que o gerador
  aplica — a cabine lida antes do `ESCALA_CAMINHAO` fez aprovar a régua
  errada (`CLAUDE.md`, «Arte»; `069`).
- ⚠️ As ferramentas partilham `user://ferramentas/`: a bateria não corre em
  paralelo com as suítes (`CLAUDE.md`, «Como rodar, aqui dentro»).
- ⚠️ A fauna não acompanha a pessoa, e o D25 é um piso sem folga
  (`brport_vs/tests/teste_design.gd`, D25; `069`).
- ⚠️ Os 16 PNGs de camião no disco são anteriores ao desenho aceite: regerar
  um sozinho põe-no no jogo sem a tabela que o escolhe (`blender/brp_porto.py`,
  o bloco das `EMPRESAS`).
- ⚠️ Um lameiro é uma chapa vista de canto por esta câmera, e o vidro de casa
  lê como casa num camião (`blender/brp_porto.py`, `_pecas_do_caminhao` e
  `_vidro`).
- ⚠️ No veredito, a pergunta sozinha é a que volta; e quando a peça já vai
  no rumo certo, ofereça «Sugira você o que falta» (`/arte`, §8).
