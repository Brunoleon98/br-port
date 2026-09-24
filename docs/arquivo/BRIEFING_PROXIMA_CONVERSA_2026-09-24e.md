# BR Port — prompt para a próxima conversa (as variações do trabalhador)

**Como usar:** abra uma conversa nova no repositório `Brunoleon98/br-port` e
cole este texto. Não é preciso anexar o histórico da conversa anterior.

**Modelo: Opus** para desenhar a gramática das variações (tons de pele, cabelo,
marcas de idade e sexo), ler cada veredito e escolher o que muda; os renders em
lote, as folhas de contato, a prova no jogo e o rasto de prosa descem para
**Sonnet** (`CLAUDE.md`, «Qual MODELO faz o quê»).

**Situação:** o trabalhador do rodapé está no jogo em BUSTO, no kit afinado dos
retratos e em Standard, aceite pelo Bruno na v6 — decisão **`058`**. O
construtor é o `trabalhador()` de `blender/brp_retratos.py`; a cara e a fração
do quadro (56%, mais aberta do que os 60% dos que falam) são a
`TRABALHADOR_CARA` e a `TRABALHADOR_CABECA` de `blender/brp_porto.py`. O
caminho das seis voltas está em `art_lab/retratos/trabalhador/`. E o
`/fechar-sessao` mudou (`057`): o briefing é saída da varredura, e o
`tools/conferir_docs.py` reprova o aviso deste arquivo que não nomear onde a
lição vive.

---

## 1. Comece pelo estado real

- A sessão fechou na branch `claude/gifted-hamilton-t5v7kz`, à frente da `main`
  (`1cfd339`, o #81 fundido), com o **PR #82** aberto. Antes de qualquer
  checkout, confira no GitHub se ele foi fundido; se não foi, a `057`, a `058`
  e o retrato novo só existem nela.
- Um ref de cada vez no `git fetch`, o código de saída lido sem cano, e
  `git log --oneline origin/main..HEAD` antes de reapontar seja o que for
  (`CLAUDE.md`, «O que cabe numa sessão»).
- Veja os PRs abertos do Codex (`codex/*`) antes de mexer num arquivo que eles
  toquem.
- O `docs/ESTADO_DO_PROJETO.md` tem **26 bytes de folga** no teto: desça o
  histórico ANTES de escrever nele (a ordem está no `/fechar-sessao` §6).

## 2. O que esta conversa faz — pedido do Bruno

**As variações do trabalhador**, com o escopo que ele já escolheu:

- **30 retratos**: 2 sexos × 3 idades (jovem, adulto, veterano) × as **5 cores
  do IBGE** (branca, parda, preta, amarela, indígena).
- **Sem caricatura**: muda o tom de pele e o cabelo que aparece por baixo do
  capacete, não o desenho do rosto — amarela e indígena distinguem-se pelo
  cabelo (liso preto, franja reta) e pelo tom, sem mudar o formato dos olhos.
- **As marcas**: mulher de **rabo de cavalo** (maxilar mais suave, sobrancelha
  mais fina, lábio com cor); veterano **grisalho e com rugas** no canto dos
  olhos; jovem de **cara lisa**; **bigode ou cavanhaque** em alguns homens.
- **O perfil de hoje é homem, adulto, pardo** — o aceite. Parametrize o
  `trabalhador()` por um `perfil` com esse padrão, e prove que ele continua a
  sair igual antes de gerar os outros 29.
- **Como entram no jogo, depois do aceite**: hoje todo trabalhador nasce com o
  píer (`{"id", "busy_turns"}` no `GameState.gd`) e usa o mesmo retrato. A
  variação é escolhida pelo `id` no cartão, sem campo novo no save e sem
  sorteio no `GameState` (`058`). O **sistema de RH** futuro é que a põe no
  currículo e na negociação de salário — fora desta conversa.

O caminho, pela `/arte`: F1 desenhar o perfil e medir os tons contra as
feições (sobrancelha e boca em `vao` sobre a pele mais escura); render das 30
em `art_lab/retratos/trabalhador_variacoes/`; uma **folha de contato** ao
tamanho do cartão e outra ampliada; o veredito com a pergunta no mesmo turno.

**E o item que ficou da conversa anterior**: os tiros das caras sem foto na
bateria — a preocupada e a contente da Dona Cida, a formal do Sr. Ribeiro e a
pressão do Arlindo —, com o catálogo de capturas ao nível do TEMPO (`051`).

## 3. O que ficou pendente do Bruno

- **O emblema do jogador** no adesivo do capacete (peça e material próprios
  desde a v6, `058`).
- **O sistema de RH** (currículo e negociação de salário) — só desenhado nas
  palavras dele; não há item na fila.
- **AgX ou Standard nos PROPS** (plano de arte §7.1) e o contorno por casco
  invertido (P5).
- **As frentes 3–6** do A5; **o galpão F1 V3** (só no checkout do ChatGPT);
  **se a vegetação entra na fila**.

## 4. Armadilhas que servem a este passo

- ⚠️ **Roupa que passa o ombro é UMA superfície**: painéis e alças empilhados
  leem como «pedaços colados» — o colete é o `_envolver` de
  `blender/brp_retratos.py`, e as lições das seis voltas estão no fim do §7.5
  de `docs/design/BR_Port_Plano_Arte_Blender.md`.
- ⚠️ **Numa câmera de cima, o que está atrás SOBE e some**: um rabo de
  cavalo atrás da nuca não se vê de frente; para ler a 70 px ele tem de vir
  por cima do ombro (`docs/design/BR_Port_Plano_Arte_Blender.md`, §7.5).
- ⚠️ **«0 pixels» entre duas corridas não se garante**: a prova de que o
  padrão não mudou é o `tools/comparar_props.py` (0,0000), e só depois a conta
  de pixels (`CLAUDE.md`, Arte).
- ⚠️ **Sorteio novo no `GameState` muda a partida medida**: a variação sai do
  `id`, sem gastar o gerador que o simulador usa (`058`); e campo novo no
  trabalhador pede `SAVE_VERSION` (`CLAUDE.md`, Save).
- ⚠️ **Um autoload faz `preload` dos retratos**: trinta retratos carregados
  de uma vez pesam na VRAM — meça com o `brport_vs/tools/medir_vram.gd` e
  carregue sob pedido (`049`).
- ⚠️ **O delta do `.pck` é o delta do APK**, e mede-se aqui sem template
  (`029`, `CLAUDE.md`).
- ⚠️ **Arte que varia com o estado não aparece nas fotos da partida**: as
  variações provam-se numa folha de contato que percorre a tabela
  (`CLAUDE.md`, Arte).
- ⚠️ **Prop em atlas pede o `--import` DUAS vezes** — na prova numa cópia
  por `git archive` e no commit (`CLAUDE.md`, Projeção).
- ⚠️ **A prancha e a pergunta vão no mesmo turno**, e a segunda pergunta pode
  voltar vaga: a terceira amplia e lista o que se vê (`/arte`).
- ⚠️ **O `bpy` baixa-se com `pip download` primeiro** — o wheel tem 373 MB e
  já se cortou a meio (`CLAUDE.md`, «Como rodar»). As pranchas pedem `pillow`
  no Python do sistema.

## 5. Restrições

- Nenhum asset em `brport_vs/` sem o aceite do Bruno na foto do jogo; nenhum
  prop do mapa de gerador de imagem; a técnica de cada asset é escolha dele.
- Nada de `# TUNING:`, política de perfis, sementes, projeção, enquadramento
  do MAPA, viewport ou `SAVE_VERSION` sem decisão escrita.
- Não reabra as decisões `047` a `058`, o R1–R9 nem as levas de cor. A próxima
  livre é a **`059`**.
- Código, comentários, nomes e documentos em pt-BR; commits e PR em inglês.

## 6. Ao encerrar

O veredito do Bruno e o que se fez com ele, pelo `/fechar-sessao`: a varredura
primeiro, depois o briefing a partir dela. **O briefing seguinte entra no
mesmo commit de fecho**, com a linha no índice de `docs/arquivo/README.md`, **e
vai também na resposta, inteiro, num bloco de código copiável.** O CI não
corre ao empurrar a branch; o PR só se abre a pedido.
