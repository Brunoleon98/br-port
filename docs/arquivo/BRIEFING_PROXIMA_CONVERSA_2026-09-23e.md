# BR Port — prompt para a próxima conversa (a saída de ré tem guarda)

**Como usar:** abra uma conversa nova no repositório `Brunoleon98/br-port` e
cole este texto. Não é preciso anexar o histórico da conversa anterior.

**Modelo:** depende do que o Bruno escolher na §2. Cada conversa começa por uma
escolha dele.

**Situação:** em 23/09, numa segunda sessão, fechou a opção (e2) do briefing
`23d` — **a saída de ré do berço ganhou guarda** (`_d13_saida_de_re`, adenda da
`047`). O D13 passou a ANIMAR a saída: chega ao berço pelo caminho do jogo, sai
pelo `_docas_mudaram()` e anda o tween à mão, lendo a textura do nó. Cinco
mutantes, cada um pela guarda certa.

⚠️ **E o M3 achou um segundo buraco:** o ramo `de_re` da `silhueta_do_trecho()`
também não tinha guarda — o §4 e o §f perguntam trecho a trecho e nenhum passa
esse argumento. **Função com guarda não é ramo com guarda** (`CLAUDE.md`).

---

## ⚠️ LEIA ISTO ANTES DE ESCREVER EM QUALQUER DOCUMENTO

O `ESTADO_DO_PROJETO.md` tem **~400 bytes de folga**. O teto vive no
`TETO_ESTADO` de `tools/conferir_docs.py`. **Comprima ANTES de escrever**, e
confira rodando o conferidor antes de escrever o commit.

---

## 1. Comece pelo estado real

- **Um ref de cada vez no `git fetch`**, código de saída lido **sem cano**,
  HEAD confirmado com o GitHub, e `git log --oneline origin/main..HEAD` antes de
  reapontar seja o que for.
- **São DEZ verdes neste contêiner**: as seis suítes (`TODOS OS TESTES
  PASSARAM`, `DESIGN OK`, `AUDIO OK`, `FUMACA OK`, `REGISTRO OK`, `ASSET OK`) e
  quatro conferidores (`DOCS OK`, `GUARDAS OK`, `ESCOPO UI OK`, `SINAL OK`). A
  bateria tem **27 tiros** e fecha com `COBERTURA OK` — o conferidor recebe a
  PASTA das fotos, e um `--help` responde `COBERTURA FALHOU`.
- O `bpy` não vem no arranque; `pip install "bpy==4.5.0"` levou ~3 min.

---

## 2. O que sobra, e nenhum deles tem ordem

### (a) Os gates humanos, que só o Bruno passa

| Gate | O que falta |
|---|---|
| **A6 — ouvir** | `docs/PROTOCOLO_DE_ESCUTA.md`, começando pela §4: o `sfx_ui_warn` tem 99% da energia abaixo de 500 Hz; o conserto é subir uma harmónica, **nunca o volume** |
| **A5 — olhar** | as **27** fotos. `camioes.png`, `props3.png` e `escolhido.png` foram-lhe enviadas em 23/09 e **não há registo de que as tenha olhado** |
| **A4 — duas coisas** | **Aplicado em 23/09, por decisão dele:** "caixa" → "dinheiro" em todo texto de tela (eram 8 sítios, não 3), resultado → **lucro/prejuízo** (`Narrativa.lucro_ou_prejuizo`, T10) e a fala da semana nova diz "barcos esperando". E também: o vencimento diz **"Vence hoje / amanhã / daqui a N dias"** — a conta antiga estava um dia adiantada e o "0 dias daqui" nunca chegava à tela (T11) —, o boletim diz **ENTROU / SAIU**, o fim de fase "Ganho com barcos" e a fala *"fecha a semana"*. **Por ler:** o Sr. Ribeiro diz *"é o primeiro mês"*, e o boletim ótimo fala da *"parcela da próxima semana"*, que é falsa se sair na semana 2 (a parcela é na 4) ou na 4 (já paga) — derivado do `tom_do_boletim()`, não medido. E ele perguntou se tinha mudado a semana: **não** — `TURNS_PER_WEEK` é 8 desde sempre; a 7 foi medida e não aplicada |

### (b) O quadro dos props — F1/Opus, sessão própria (duas, a sério)

89,6% de moldura vazia; ~129 dos 144 MB de VRAM são transparência (`029`).
Cortá-lo troca *"o centro do quadro é a origem do mundo"* por âncora publicada
por prop: `PropIso`, os 31 nós com `expand_mode`, a `scale` do `Fauna.gd`, o
`asset_validator` e o manifest, as réguas do teste de design que leem o PNG e
as folhas de contato. Precisa de `bpy` e regera **69** props. O ganho no `.pck`
**não está medido**.

### (c) O âmbar da seleção — F4

Passa a 1.4.11 pela largura (7,37:1 contra a barra); a troca de estado pela cor
mede 2,26:1. Subir a cor esbarra na `035`. Não há defeito; só vale se o Bruno
quiser que a troca também se leia pela cor.

### (d) Os nove órfãos que FICARAM

Presos à `001`; reabra só se a `001` for reaberta.

### (e) O retorno a entrar nos berços — desenho de cruzamento

Os camiões que sobem são só de passagem (`047`). Entrar obrigaria a virar à
esquerda por cima da faixa da ida: pede regra de cedência, trava de berço
ocupado (hoje o camião `i` serve a doca `i`) e guardas novas. As silhuetas
existem. Uma sessão inteira, e o pedido original avisava contra trânsito e bugs.

---

## 3. Armadilhas que 23/09 (segunda sessão) mediu

- ⚠️ **Função com guarda não é ramo com guarda.** Pergunte que ARGUMENTOS as
  asserções passam; o opcional é o que ninguém passa.
- ⚠️ **Animação prova-se sem esperar frame.** `get_processed_tweens()` antes e
  depois da ação, `custom_step()` a passo menor do que o trecho mais curto, e a
  ação sem tween REPROVA — senão a lista vazia passa (o M5 mediu-o).
- ⚠️ **Fixture que alarga `GS.docks` repõe-no no fim**, e o bloco mata os
  tweens que criou: os blocos seguintes usam o mesmo `Main`.

---

## 4. Restrições

- Nada de `# TUNING:`, política de perfis, sementes do jogo, projeção,
  enquadramento, viewport ou `SAVE_VERSION` — salvo se a (b) for a escolhida.
- Não mexa em gerador cuja saída o CI compara byte a byte.
- **Não reabra o R1–R9, as CINCO levas de cor, a triagem dos órfãos, nem a
  largura da rua (`047`).**
- Código, comentários, nomes e documentos em pt-BR; commits e PR em inglês.

---

## 5. O que entregar ao encerrar

Branch e commit; arquivos alterados; o antes e o depois medidos; os comandos e
os marcadores; **quais mutantes reprovaram e por quê**; o que ficou pendente do
Bruno; o que ficou de fora e por quê. **O briefing seguinte entra no mesmo
commit de fecho**, com a linha no índice de `docs/arquivo/README.md`.

⚠️ **O CI NÃO RODA AO EMPURRAR A BRANCH** — só na `main` e em `pull_request`.
O PR só se abre a pedido.
