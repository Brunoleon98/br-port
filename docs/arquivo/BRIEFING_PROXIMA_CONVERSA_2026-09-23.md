# BR Port — prompt para a próxima conversa (a 3ª leva de cor saiu)

**Como usar:** abra uma conversa nova no repositório `Brunoleon98/br-port` e
cole este texto. Não é preciso anexar o histórico da conversa anterior.

**Modelo:** depende do que o Bruno escolher na §2. Desde que a §7.1 acabou,
cada conversa começa por uma escolha dele.

**Situação:** a **terceira leva das cores declaradas** fechou em 22/09
(`docs/decisoes/043`) — o cartão da doca inteiro foi para o tema. Restam
**3 chamadas em 3 locais**, em duas levas pequenas.

⚠️ **E ELA FOI MIGRAÇÃO DE VALORES, como a 1ª.** As 277 linhas dos 22 estados
antigos saíram com razão, corte, px e texto idênticos; 50 mudaram só a coluna
ORIGEM. **Nada no jogo mudou de cor.**

⚠️ **MAS ELA ACHOU UMA CHAVE MORTA.** O percurso do D33 montava a doca sob
oferta do rival escrevendo `docks[d]["rival_offer"]` — uma chave que NINGUÉM
no projeto lê. O cartão lê `boat["rival"]`. Resultado: o caso montava, media, e
publicava linhas verdadeiras sobre o estado ERRADO, sem uma queixa. **Estado
que não monta publica linhas plausíveis**, e é a irmã de *"fala disparada não é
fala vista"*.

⚠️ **E O X6 DA `042` ESTAVA VIVO EM PRODUÇÃO.** O `DocaCartao._estilo()` punha
a variação por `theme_type_variation = StringName(variacao)`: com o nome
trocado à mão, o portão do escopo sai **verde**. A função dissolveu-se em
quatro literais — e a guarda nova apanha-o, porque lê o NÓ em vez do TEXTO.

⚠️ **`git fetch origin main <branch>` NÃO ATUALIZA A `main` SE A `<branch>` JÁ
NÃO EXISTIR.** Aborta com código 128 e NENHUM dos dois refs se mexe. **Peça um
ref de cada vez**, leia o código de saída **sem cano**, e confirme o HEAD com o
GitHub.

---

## 1. Comece pelo estado real

- Confira repositório, branch, `git status`, HEAD e o local contra o remoto
  **antes** de sincronizar. Preserve trabalho não publicado.
- Leia `CLAUDE.md` (carrega sozinho) e `docs/ESTADO_DO_PROJETO.md`.
- ⚠️ **O `ESTADO_DO_PROJETO.md` está a 29.354 de 30.000** — **646 de folga**,
  mais do que os 378 de ontem porque 22/09 fundiu as três linhas das levas de
  cor numa só. **Quem escrever ali a seguir comprime ANTES, não depois.**
- **São DEZ verdes neste contêiner**: as seis suítes do Godot (`TODOS OS
  TESTES PASSARAM`, `DESIGN OK`, `AUDIO OK`, `FUMACA OK`, `REGISTRO OK`,
  `ASSET OK`) e quatro conferidores em Python (`DOCS OK`, `GUARDAS OK`,
  `ESCOPO UI OK`, `SINAL OK`). A bateria de captura é a décima primeira, e o
  `conferir_cobertura_paineis.py` corre CONTRA a pasta dela (`COBERTURA OK`).

---

## 2. O que sobra, e nenhum deles tem ordem

### (a) Os gates humanos, que nenhuma sessão passa

| Gate | O que falta | O que já está pronto |
|---|---|---|
| **A6 — ouvir** | tudo | `docs/PROTOCOLO_DE_ESCUTA.md`. ⚠️ **Comece pela §4**: o aviso (`sfx_ui_warn`) tem 99% da energia abaixo de 500 Hz, e o conserto — se for preciso — é subir uma harmónica no gerador, **nunca o volume** |
| **A5 — olhar** | o olho dele | as 24 fotos da bateria. ⚠️ **O âmbar da faixa (`042`) não está em nenhuma delas**; o cartão da doca (`043`) está em **13 das 24**, medido por controle positivo |
| **A4 — três decisões de PALAVRA** | uma linha cada | `"Caixa:"` (`DebtPaymentPanel.gd:68`), o `"dinheiro no caixa"` da fala da semana nova (`Narrativa.gd:159`), e o `"0 dias daqui"` do painel da parcela (`PainelParcela.gd:46`) |

### (b) As duas coisas medidas, cada uma sessão própria, ambas F1/Opus

- **A rua parada em 1,8.** Alargá-la empurra o `RUA_RECUO` e o enquadramento
  (`012`). Medido: 1,9 cabe com 0,09 de folga, 2,0 falha por 7 milésimos. O
  ganho é de LEITURA, não de jogo.
- **O quadro dos props, 89,6% moldura vazia.** Cortá-lo derruba ~10x a VRAM e
  mexe em *"o centro do quadro é a origem do mundo"* (`029`).

### (c) As duas levas de cor que faltam — 3 chamadas em 3 locais

| Leva | Estado |
|---|---|
| **verde do `UpgradePanel`** (2 / 2) | **percurso primeiro, cor depois**, e o mecanismo existe: o `acao_vista` da `042` corre métodos sobre a cena montada, e `comprar_estrutura` é um método. ⚠️ **E agora há uma segunda peça** — o `_barco_chegou` da `043` é o molde de como um caso PROVA que obteve o estado que pediu; o estado do verde pede a mesma guarda |
| **borda do `Worker.gd`** (1 / 1) | é BORDA e não texto, fora do portão de contraste. Pede uma variação `TrabSelecionado`, e uma prova que não seja de contraste. ⚠️ **E ele carrega a segunda forma dinâmica do projeto**: `_aplicar_estilo()` passa o nome a `get_theme_stylebox(prop, TIPO)`, que o portão nem procura |

⚠️ **RESTAM DUAS FORMAS DINÂMICAS, e nenhuma é cor.** A do `Worker.gd` acima,
e o `PainelNarrativo.montar()`, que recebe a variação por PARÂMETRO — é API, e
os chamadores passam literais. Ficaram **registadas e não corrigidas** na
`043`: fechá-las é mexer numa API e num mecanismo diferente.

### (d) Os 11 órfãos de arte

`art/brp/` inteira (8), `pier_construido.svg` e `pier_vazio.svg` na raiz, e
`doca_concreto.png` — **696 KB ao todo**, 11 de 109 arquivos. É relatório e
não portão de propósito (`tools/arte_orfa.py`): **o destino de cada um é
decisão do Bruno.** (`art/sprites/` é item à parte — referido só por
`scenes/proto/`, que o export exclui.)

---

## 3. Armadilhas que 22/09 mediu e que mordem a seguir

- ⚠️ **ESTADO QUE NÃO MONTA PUBLICA LINHAS PLAUSÍVEIS.** Um caso do percurso
  que pede um estado e não o obtém não se queixa. Mordeu duas vezes no mesmo
  dia, e a primeira foi numa SONDA de investigação: ela não pegou, e só não se
  concluiu "o estado é inalcançável" por se ter a régua do defeito injetado na
  cabeça. **Caso que declara um estado prova que o obteve**, por DERIVAÇÃO.
- ⚠️ **ONDE A VARREDURA DE TEXTO NÃO ALCANÇA, QUEM ALCANÇA É RUNTIME.** A
  regex do `conferir_escopo_ui.py` lê a intenção e uma expressão dinâmica
  escapa-lhe sempre; uma guarda que lê o nó montado lê o resultado, e esse não
  se contorna. No X3, **só o D33** segurou; no X5 da `042`, **só o escopo**.
  Nenhuma das duas cobre a outra.
- ⚠️ **AFIRMAÇÃO DE BRIEFING CONFERE-SE, E DUAS NÃO SE SUSTENTARAM.** Este
  arquivo dizia que a leva do cartão era "a maior e a mais difícil" por causa
  da composição que não fecha — que já estava construída desde a `035` — e do
  estado âmbar não medido, que era verdade mas por outra razão. Dez minutos de
  medição mudaram a estimativa da sessão inteira.
- ⚠️ **«AS FOTOS NÃO MUDARAM» PEDE UM CONTROLE POSITIVO, e ele pode responder
  para os dois lados.** Na `042` o âmbar mudado não estava em foto nenhuma; na
  `043` o cartão está em **13 das 24**, e a migração mexeu em zero. A
  identidade byte a byte só quer dizer alguma coisa depois de se saber que a
  régua veria a diferença.
- ⚠️ **PISO FROUXO DEIXA UM ESTADO SUMIR SEM QUEIXA.** O `D33_ESTADOS_MIN`
  estava em 20 com o comentário ao lado a dizer 22. Hoje está em 23, que é o
  número real.
- ⚠️ **Guarda que passa de primeira é para desconfiar**, e o defeito injetado
  nunca desce de modelo.

---

## 4. Restrições

- Nada de `# TUNING:`, política de perfis, sementes do jogo, projeção,
  enquadramento, viewport ou `SAVE_VERSION` — salvo se a (b) for a escolhida.
- Não mexa em gerador cuja saída o CI compara byte a byte.
- **Não reabra o R1–R9 nem as três levas já saídas.**
- Código, comentários, nomes e documentos em pt-BR; commits e PR em inglês.
- Achou algo de outro item? Registre com a evidência e siga.

---

## 5. O que entregar ao encerrar

Branch e commit; arquivos alterados; o antes e o depois medidos; os comandos e
os marcadores; **quais mutantes reprovaram e por quê**; o que ficou pendente do
Bruno; o que ficou de fora e por quê.

⚠️ **E O BRIEFING DA CONVERSA SEGUINTE ENTRA NO MESMO COMMIT DE FECHO**, em
`docs/arquivo/`, datado, com a linha dele no índice de `docs/arquivo/README.md`.

**E entrega-se ao Bruno em BLOCO COPIÁVEL na conversa, antes de ele fundir.**

⚠️ **E O CI NÃO RODA AO EMPURRAR A BRANCH.** `testes.yml` e `captura.yml`
disparam em `push` só na `main` e em `pull_request`. Até o PR abrir, "verde"
quer dizer apenas "verde neste contêiner". O PR só se abre a pedido.
