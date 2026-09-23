# BR Port — prompt para a próxima conversa (a saída de ré tem guarda, e o A4 fechou as palavras)

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

**E na mesma sessão o Bruno passou o A4 das palavras** (`048`): "dinheiro" em vez
de "caixa", lucro/prejuízo, o vencimento em hoje/amanhã/daqui a N, falas que não
narram a tela, e o **boletim medido** — `tools/medir_boletim.gd` achou **2.005
afirmações falsas em 4.000 boletins** (uma delas falsa todas as vezes que saía);
hoje zero, e a régua está no CI. O Sr. Ribeiro deixou de perdoar quem acaba de
perder o porto.

---

## ⚠️ LEIA ISTO ANTES DE ESCREVER EM QUALQUER DOCUMENTO

O `ESTADO_DO_PROJETO.md` tem **~250 bytes de folga**. O teto vive no
`TETO_ESTADO` de `tools/conferir_docs.py`. **Comprima ANTES de escrever**, e
confira rodando o conferidor antes de escrever o commit.

---

## 1. Comece pelo estado real

- ⚠️ **A sessão de 23/09 fechou na branch `claude/eloquent-hopper-goxy6q`,
  à frente da `main` (`0bf6b42`) desde o `8569b57`, com o PR
  [#69](https://github.com/Brunoleon98/br-port/pull/69) aberto.** Antes de
  qualquer checkout, confira no GitHub se ele já fundiu e se o CI dele ficou
  verde; se não fundiu, esse trabalho só existe na branch, e reiniciá-la da
  `main` apaga-o.
- **Um ref de cada vez no `git fetch`**, código de saída lido **sem cano**,
  HEAD confirmado com o GitHub, e `git log --oneline origin/main..HEAD` antes de
  reapontar seja o que for.
- **São DEZ verdes neste contêiner**: as seis suítes (`TODOS OS TESTES
  PASSARAM`, `DESIGN OK`, `AUDIO OK`, `FUMACA OK`, `REGISTRO OK`, `ASSET OK`) e
  quatro conferidores (`DOCS OK`, `GUARDAS OK`, `ESCOPO UI OK`, `SINAL OK`). A
  bateria tem **27 tiros** e fecha com `COBERTURA OK` — o conferidor recebe a
  PASTA das fotos, e um `--help` responde `COBERTURA FALHOU`.
- **E a régua do boletim entrou no CI:** `tools/medir_boletim.gd -- 200`,
  ~11 s, `BOLETIM OK` (`048`). Ela herda o simulador; quem mexer nele ou numa
  fala do boletim corre-a.
- O `bpy` não vem no arranque; `pip install "bpy==4.5.0"` levou ~3 min.

---

## 2. O que sobra, e nenhum deles tem ordem

### (a) Os gates humanos, que só o Bruno passa

| Gate | O que falta |
|---|---|
| **A6 — ouvir** | `docs/PROTOCOLO_DE_ESCUTA.md`, começando pela §4: o `sfx_ui_warn` tem 99% da energia abaixo de 500 Hz; o conserto é subir uma harmónica, **nunca o volume** |
| **A5 — olhar** | as **27** fotos. `camioes.png`, `props3.png` e `escolhido.png` foram-lhe enviadas em 23/09 e **não há registo de que as tenha olhado** |
| **A4 — fechado nas palavras** | Aplicado em 23/09 (`048`, T10–T13). Resta a leitura em voz alta das falas reescritas: entrada, resposta e despedida do Sr. Ribeiro, os seis tons do boletim, a derrota para o Arlindo e a vitória dele. A família "semana nova" ficou como ele a aprovou. E ele perguntou se tinha mudado a semana: **não** — `TURNS_PER_WEEK` é 8; a 7 foi medida e não aplicada |

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

### (f) NOVO — a resposta do Sr. Ribeiro não tem foto

O tiro `ribeiro` fotografa a ENTRADA; a resposta (pagou / não pagou) e a
despedida — as falas mais mexidas em 23/09 — só foram fotografadas à mão, com
um script descartável que herda o `capturar_cena.gd` e chama
`_mostrar_resposta()`. O T13 guarda o texto; nada guarda que ele caiba no
cartão. Pequeno: um tiro a mais na bateria, e pede que a cobertura por painel
passe a distinguir TEMPOS do mesmo painel, que hoje não distingue.

---

## 3. Armadilhas que 23/09 (segunda sessão) mediu

- ⚠️ **Função com guarda não é ramo com guarda.** Pergunte que ARGUMENTOS as
  asserções passam; o opcional é o que ninguém passa.
- ⚠️ **Animação prova-se sem esperar frame.** `get_processed_tweens()` antes e
  depois da ação, `custom_step()` a passo menor do que o trecho mais curto, e a
  ação sem tween REPROVA — senão a lista vazia passa (o M5 mediu-o).
- ⚠️ **Fixture que alarga `GS.docks` repõe-no no fim**, e o bloco mata os
  tweens que criou: os blocos seguintes usam o mesmo `Main`.
- ⚠️ **Afirmação que É a condição do tom é espelho.** A régua do boletim deu
  verde com o ramo da parcela arrancado; só reprovou depois de listar uma
  afirmação que lê um campo que a escolha não lê (`048`).
- ⚠️ **Frase que vai ao gate fotografa-se no estado em que aparece.** O A4
  carregou *"0 dias daqui"* quatro dias, e ele nunca chegava à tela; o defeito
  real era *"1 dia daqui"* no próprio dia 32. **O mesmo número serve a uma
  palavra e mente noutra** — "N dias restantes" conta hoje, "daqui" não.
- ⚠️ **Fala que vem do rascunho do GDD pode prometer uma regra da Fase 1.** O
  *"uma vez eu deixo passar"* era das três parcelas; no VS não pagar encerra.

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
