# BR Port — prompt para a próxima conversa (a 2ª leva de cor saiu)

**Como usar:** abra uma conversa nova no repositório `Brunoleon98/br-port` e
cole este texto. Não é preciso anexar o histórico da conversa anterior.

**Modelo:** depende do que o Bruno escolher na §2. Desde que a §7.1 acabou,
cada conversa começa por uma escolha dele.

**Situação:** a **segunda leva das cores declaradas** fechou em 22/09
(`docs/decisoes/042`) — a faixa de mensagem inteira foi para o tema. Restam
**11 chamadas em 8 locais**, em três levas.

⚠️ **E ELA NÃO FOI UMA MIGRAÇÃO DE VALORES, ao contrário da 1ª.** O registro
afirmava que os quatro estados do rótulo da faixa já eram medidos pelo D33;
eram **três linhas, todas do mesmo estado NEUTRO**. A régua nunca drenava a
fila, logo media sempre a mensagem de abertura. Alcançados os outros três, o
âmbar de marca media **3,07:1** sobre o creme contra um corte de 4,5 — no
`kind` mais emitido do jogo. Ele escureceu para o valor do `RotuloAlerta`
(4,87:1). **O texto de aviso da faixa mudou de cor, e isso vê-se.**

⚠️ **`git fetch origin main <branch>` NÃO ATUALIZA A `main` SE A `<branch>` JÁ
NÃO EXISTIR.** Aborta com `fatal: couldn't find remote ref` e código 128, e
NENHUM dos dois refs se mexe. **Peça um ref de cada vez**, leia o código de
saída **sem cano** (num `| tail` o `$?` é do `tail`) e confirme o HEAD com o
GitHub.

---

## 1. Comece pelo estado real

- Confira repositório, branch, `git status`, HEAD e o local contra o remoto
  **antes** de sincronizar. Preserve trabalho não publicado.
- Leia `CLAUDE.md` (carrega sozinho) e `docs/ESTADO_DO_PROJETO.md`.
- ⚠️ **O `ESTADO_DO_PROJETO.md` está a 29.622 de 30.000** — **378 de folga**,
  menos do que os 555 de ontem. 22/09 fundiu as duas tabelas de "Fechado" e
  comprimiu cinco linhas para caber a leva nova. **Quem escrever ali a seguir
  comprime ANTES, não depois** — e desta vez sobra pouco de onde tirar.
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
| **A5 — olhar** | o olho dele | as 24 fotos da bateria. ⚠️ **E o âmbar novo da faixa NÃO está em nenhuma delas** — medido, não suposto: ver a §3 |
| **A4 — três decisões de PALAVRA** | uma linha cada | `"Caixa:"` (`DebtPaymentPanel.gd:68`), o `"dinheiro no caixa"` da fala da semana nova (`Narrativa.gd:159`), e o `"0 dias daqui"` do painel da parcela (`PainelParcela.gd:46`) |

### (b) As duas coisas medidas, cada uma sessão própria, ambas F1/Opus

- **A rua parada em 1,8.** Alargá-la empurra o `RUA_RECUO` e o enquadramento
  (`012`). O ganho é de LEITURA, não de jogo.
- **O quadro dos props, 89,6% moldura vazia.** Cortá-lo derruba ~10x a VRAM e
  mexe em *"o centro do quadro é a origem do mundo"* (`029`).

### (c) As levas de cor que faltam — 11 chamadas em 8 locais

| Leva | Estado |
|---|---|
| **cartão da doca** (5 entradas / 8 chamadas) | a maior, e a mais difícil: QUATRO styleboxes por estado e alfa 0,96 sobre o MAPA — composição que NÃO FECHA, logo a resposta honesta são duas (pior sobre preto, pior sobre branco). E o estado âmbar não é medido: o percurso não monta doca sob oferta |
| **verde do `UpgradePanel`** (2 / 2) | **percurso primeiro, cor depois**, e agora há um mecanismo a mais para lho dar — ver abaixo |
| **borda do `Worker.gd`** (1 / 1) | é BORDA e não texto, fora do portão de contraste. Pede uma variação `TrabSelecionado`, e uma prova que não seja de contraste |

⚠️ **E O `acao_vista` MUDA O QUE É ALCANÇÁVEL.** Ele corre métodos sobre a
cena JÁ MONTADA e drena a fila da faixa depois de cada um. O verde do
`UpgradePanel` pede estrutura construída, que é um método (`comprar_estrutura`)
e não um campo — exactamente o que este mecanismo destrava. **A ordem que o
registro manda continua a ser percurso primeiro.**

### (d) Os 11 órfãos de arte

`art/brp/` inteira (8), `pier_construido.svg` e `pier_vazio.svg` na raiz, e
`doca_concreto.png`. É relatório e não portão de propósito
(`tools/arte_orfa.py`): **o destino de cada um é decisão do Bruno.**
(`art/sprites/` é item à parte — referido só por `scenes/proto/`, que o export
exclui.)

---

## 3. Armadilhas que 22/09 mediu e que mordem a seguir

- ⚠️ **«JÁ É MEDIDO PELO D33» É AFIRMAÇÃO A CONFERIR, NUNCA A HERDAR.** O
  registro dizia-o dos quatro estados da faixa; eram três linhas do mesmo. A
  afirmação perigosa é a POSITIVA — a negativa a régua confirma-a ao não
  publicar a linha. Confere-se CONTANDO as linhas na tabela.
- ⚠️ **FALA DISPARADA NÃO É FALA VISTA, e vale para a RÉGUA.** O `acao` corre
  antes de a cena existir (o `message` sai para ninguém) e o texto entra numa
  FILA com tempo mínimo. **E drenar só no fim não chega** — a fila ordena por
  prioridade (`bad > warn > good`), então duas ações seguidas entregam a de
  MENOR prioridade. Drena-se depois de CADA ação.
- ⚠️ **«AS FOTOS NÃO MUDARAM» PEDE UM CONTROLE POSITIVO.** A calibração prova
  que a bateria não tem ruído próprio; não prova que ela veria a mudança.
  Medido: o âmbar mudado moveu **0 das 24**, e o neutro da MESMA faixa pintado
  de vermelho moveu **12** — logo a bateria vê a faixa em metade das fotos, e
  as doze mostram-na sempre NEUTRA.
- ⚠️ **A FORMA DO CÓDIGO ESCOLHE-SE PELO QUE A RÉGUA ALCANÇA.** Um dicionário
  de variações com `.get()` é mais arrumado e **invisível** ao
  `conferir_escopo_ui.py`, que procura `theme_type_variation = "<nome>"`.
  Mutante X6: nome com erro de digitação por `StringName(...)` — **nenhuma das
  duas réguas o apanhou.** São literais `&"..."`.
- ⚠️ **Guarda que passa de primeira é para desconfiar**, e o defeito injetado
  nunca desce de modelo.

---

## 4. Restrições

- Nada de `# TUNING:`, política de perfis, sementes do jogo, projeção,
  enquadramento, viewport ou `SAVE_VERSION` — salvo se a (b) for a escolhida.
- Não mexa em gerador cuja saída o CI compara byte a byte.
- **Não reabra o R1–R9 nem as duas levas já saídas.**
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
