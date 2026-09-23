# BR Port — prompt para a próxima conversa (Blender: boas práticas para um visual melhor)

**Como usar:** abra uma conversa nova no repositório `Brunoleon98/br-port` e
cole este texto. Não é preciso anexar o histórico da conversa anterior.

**Modelo: Opus.** É pesquisa e recomendação — ler fontes, cruzá-las com o que
este projeto já mediu e dizer o que vale a pena. Nada disto é receita
(`CLAUDE.md`, «Qual MODELO faz o quê»).

**Situação:** em 23/09 o Bruno escolheu a **frente 2** do A5 (os retratos de
fala da Dona Cida, do Sr. Ribeiro e do Arlindo, que ele julgou «bem ruins» e
quer «mais bonitos e expressivos»). A sessão desenhou, sem perguntar, nove
retratos em VETOR (SVG por script) e fotografou-os numa cópia do jogo; a
resposta foi **«não deveriam ter sido criados»**. Nada entrou no repositório.
**A arte continua no Blender**, e esta conversa existe para responder a uma
pergunta antes de se modelar o que for: *que dicas e boas práticas de Blender
levam estes personagens — e os outros assets do jogo — a um visual melhor e
mais bonito?* (§A5 do plano, «A FRENTE 2 ABRIU E VOLTOU AO BLENDER»; a lição
está no `CLAUDE.md`, secção Arte.)

---

## 1. Comece pelo estado real

- A sessão de 23/09 fechou na branch `claude/zen-fermat-ha7oyb`, só com
  documentos, à frente da `main` (`2b4a100`, o #77 fundido), e o PR dela é o
  **#78**. Antes de qualquer checkout, confira no GitHub se ele foi fundido; se
  não foi, o registo desta rejeição só existe na branch.
- **Um ref de cada vez no `git fetch`**, código de saída lido **sem cano**, e
  `git log --oneline origin/main..HEAD` antes de reapontar seja o que for.
- Veja os PRs abertos do Codex (`codex/*`) antes de mexer num arquivo que eles
  toquem.

## 2. O que esta conversa faz

**Pesquisa, com fontes, e entrega uma recomendação ao Bruno — não modela.**
Nenhum asset novo, nenhum render que substitua um PNG do jogo, até ele escolher
o que experimentar (é a lição de 23/09). Um render de teste para PROVAR que uma
técnica funciona por script pode fazer parte da recomendação, dito como tal e
fora de `brport_vs/`.

1. **Leia primeiro o que o projeto já sabe**, para não pesquisar o que já está
   medido:
   - `docs/design/BR_Port_Plano_Arte_Blender.md` — §3 («O que o Blender por
     script alcança — e o que não alcança»), as Etapas 2–5 e o que cada uma
     desmentiu;
   - `CLAUDE.md`, secções «Projeção isométrica» e «Arte» — o contorno FECHADO
     pelas duas técnicas, o chanfro de 0,020 que é invisível (0,4 px), o
     `Pointiness` que não separa quina de pano numa caixa, faces coplanares, a
     régua de silhueta (`024`, `028`), o quadro de 768 (`029`, `049`);
   - `docs/decisoes/020` (os três rostos, busto e não corpo inteiro, e por quê);
   - o código: `blender/brp_studio.py` (câmera, rig de luz, render),
     `blender/brp_porto.py` (`retratos_de_fala`, `trabalhador_retrato`) e o kit
     de `tools/gerar_props_iso.py`.
2. **Pesquise na web** (WebSearch/WebFetch) as práticas de quem faz arte de jogo
   estilizada em Blender, separando o que se faz **por script, sem interface**
   (`bpy` 4.5 como biblioteca, Cycles/EEVEE em contêiner sem GPU) do que pede
   mão. Para PERSONAGENS: malha base redonda com Subdivision Surface e sombra
   suave em vez de caixas; olhos, sobrancelhas e boca como peças ou decais que
   mudam por shape key/pose; cel shading e rim light; proporções chibi/estilizadas
   que leem a ~100 px; textura pintada. Para PROPS e cenário: bevel e weighted
   normals, trim sheets, vertex color e gradientes, AO e cavidade, gestão de cor
   (AgX/Filmic), o rig de três pontos, e o que os jogos isométricos de gestão
   com boa cara fazem. Guarde o link de cada fonte.
3. **Cruze cada prática com uma regra ou medição daqui.** Várias já foram
   tentadas e medidas (o contorno duas vezes, o chanfro, a cal descascada); o
   que a pesquisa diz em contrário tem de dizer porque a medição daqui não vale.
   Para cada uma: ganho esperado, custo, se alcança por script, e o que o jogo
   arrasta (o `.pck`, a VRAM, o `asset_validator`, as folhas de contato).
4. **Entregue:** uma secção nova no `BR_Port_Plano_Arte_Blender.md` (é lá que
   o §3 já vive — não um documento novo), ordenada por ganho/custo, com as
   fontes; e na resposta, um resumo curto para o Bruno escolher **o que
   experimentar primeiro** e em quê (os retratos da frente 2, ou um prop).

## 3. O que ficou pendente do Bruno

- **As frentes 3–6** do A5 — a ordem é dele.
- **O galpão F1 V3** que ele aprovou no ChatGPT só existe no checkout de lá
  (`art/f01-galpao`, HEAD `cc36166`): recuperar ou refazer.
- **Se a vegetação entra na fila** (`art_lab/README.md` §7).

## 4. Armadilhas que esta sessão mediu

- ⚠️ **O que a regra PERMITE não é o que o Bruno escolheu.** O `CLAUDE.md`
  permite gerador de imagem em retrato de painel, e ele quer o Blender. Ao
  achar que uma técnica não alcança o pedido, pergunte qual antes de produzir.
- **A caixa do retrato é 112×152** no espaço de 720 (168×228 num telefone de
  1080), em `COVERED` com `clip_contents`: é a esse tamanho que a expressão tem
  de ler, e é lá que se julga — não na folha a 768.
- **Trocar os nove retratos mexe numa caixa só por tela:** medido em 23/09, as
  seis fotos com cara mudaram apenas nos 112×152 do retrato, o resto byte a
  byte. É a medida da contenção de quem vier a trocá-los.
- **Blender aqui é `pip install "bpy==4.5.0"`** em Python 3.11 (~1 GB, minutos);
  o hook de arranque não o instala.

## 5. Restrições

- Nada de `# TUNING:`, política de perfis, sementes, projeção, enquadramento,
  viewport ou `SAVE_VERSION` sem decisão escrita.
- Nenhum asset de fora entra em `brport_vs/` sem o Bruno escolher; nenhum prop
  do mapa vem de gerador de imagem.
- Não reabra as decisões `047` a `054`, o R1–R9 nem as levas de cor.
- Código, comentários, nomes e documentos em pt-BR; commits e PR em inglês.

## 6. Ao encerrar

O que a pesquisa recomenda e o que o Bruno escolheu experimentar. **O briefing
seguinte entra no mesmo commit de fecho**, com a linha no índice de
`docs/arquivo/README.md`, **e vai também na resposta, inteiro, num bloco de
código copiável.** O CI não roda ao empurrar a branch; o PR só se abre a
pedido.
