# BR Port — prompt para a próxima conversa (a 1ª leva de cor saiu)

**Como usar:** abra uma conversa nova no repositório `Brunoleon98/br-port` e
cole este texto. Não é preciso anexar o histórico da conversa anterior.

**Modelo:** depende do que o Bruno escolher na §2. A fila ordenada acabou com a
§7.1; desde então cada conversa começa por uma escolha dele.

**Situação:** a **primeira leva das 27 cores declaradas** fechou em 21/09
(`docs/decisoes/041`) — a barra escura do `Main.tscn` inteira foi para o tema.
Restam **17 chamadas em 11 locais**, em quatro levas, cada uma com a razão
escrita de por que ainda não saiu.

⚠️ **`git fetch origin main <branch>` NÃO ATUALIZA A `main` SE A `<branch>` JÁ
NÃO EXISTIR.** Ele aborta com `fatal: couldn't find remote ref` e código 128, e
NENHUM dos dois refs se mexe. Como a branch designada costuma ser apagada
quando o PR funde, perguntar pelas duas na mesma linha é o caminho natural para
o erro — e um `git checkout -B <nome> origin/main` sobre uma `main` velha apaga
a entrega. **Peça um ref de cada vez**, leia o código de saída **sem cano** (num
`| tail` o `$?` é do `tail`, e dá 0), e confirme o HEAD com o GitHub.

---

## 1. Comece pelo estado real

- Confira repositório, branch, `git status`, HEAD e o local contra o remoto
  **antes** de sincronizar. Preserve trabalho não publicado.
- Leia `CLAUDE.md` (carrega sozinho) e `docs/ESTADO_DO_PROJETO.md`.
- ⚠️ **O `ESTADO_DO_PROJETO.md` está a 29.445 de 30.000** — **555 de folga**, o
  que é pouco. 21/09 comprimiu as linhas de R1–R9 para caber a leva nova. Quem
  escrever ali a seguir comprime ANTES, não depois.
- **São DEZ verdes neste contêiner**: as seis suítes do Godot (`TODOS OS TESTES
  PASSARAM`, `DESIGN OK`, `AUDIO OK`, `FUMACA OK`, `REGISTRO OK`, `ASSET OK`) e
  quatro conferidores em Python (`DOCS OK`, `GUARDAS OK`, `ESCOPO UI OK`,
  `SINAL OK`). A bateria de captura é a décima primeira, e faz falta sempre que
  o visual PUDER ter mudado — inclusive para provar que ele NÃO mudou.

---

## 2. O que sobra, e nenhum deles tem ordem

### (a) Os gates humanos, que nenhuma sessão passa

| Gate | O que falta | O que já está pronto |
|---|---|---|
| **A6 — ouvir** | tudo | `docs/PROTOCOLO_DE_ESCUTA.md`. ⚠️ **Comece pela §4**: o aviso (`sfx_ui_warn`) tem 99% da energia abaixo de 500 Hz, e o conserto — se for preciso — é subir uma harmónica no gerador, **nunca o volume** |
| **A5 — olhar** | o olho dele | as 24 fotos da bateria |
| **A4 — três decisões de PALAVRA** | uma linha cada | o rótulo `"Caixa:"` (`DebtPaymentPanel.gd:68`), o `"dinheiro no caixa"` da fala da semana nova, e o `"0 dias daqui"` do painel da parcela |

### (b) As duas coisas medidas, cada uma sessão própria, ambas F1/Opus

- **A rua parada em 1,8.** Alargá-la empurra o `RUA_RECUO` e o enquadramento
  (`012`). O ganho é de LEITURA, não de jogo.
- **O quadro dos props, 89,6% moldura vazia.** Cortá-lo derruba ~10x a VRAM e
  mexe em *"o centro do quadro é a origem do mundo"* (`029`).

### (c) As levas de cor que faltam — 17 chamadas em 11 locais

A ordem está escrita nas justificativas de `tools/excecoes_cor_ui.json`, e a
`041` diz qual sai a seguir e por quê:

| Leva | Estado |
|---|---|
| **faixa de mensagem** (3 entradas / 6 chamadas) | **pronta a sair.** Fundo creme próprio, e os quatro estados do `_message_label` já são medidos pelo D33 |
| **cartão da doca** (5 / 8) | mais difícil: QUATRO styleboxes por estado e alfa 0,96 sobre o MAPA. E o estado âmbar não é medido — o percurso não monta doca sob oferta |
| **verde do `UpgradePanel`** (2 / 2) | **bloqueada**: o percurso abre o painel com o porto em ruínas, logo a cor nunca entra nos textos medidos. **Percurso primeiro, cor depois** |
| **borda do `Worker.gd`** (1 / 1) | é BORDA e não texto, fora do portão de contraste. Pede uma variação `TrabSelecionado` |

⚠️ **A RECEITA DA `041`, que é o que torna isto barato e seguro:** a leva
escolhe-se pelo que a RÉGUA ALCANÇA, os valores NÃO mudam, e a prova é dupla —
as linhas do D33 com razão e texto idênticos (só a coluna ORIGEM muda, e só nas
linhas da leva) mais as **24 fotos byte a byte**, com a bateria calibrada
primeiro por duas corridas da MESMA árvore.

### (d) Os 11 órfãos de arte

`art/brp/` inteira, dois SVG de píer, `doca_concreto`, `art/sprites/`. É
relatório e não portão de propósito (`tools/arte_orfa.py`): **o destino de cada
um é decisão do Bruno.**

---

## 3. Armadilhas que 21/09 mediu e que mordem a seguir

- ⚠️ **O REGISTRO DE EXCEÇÕES DIZ ONDE A COR É DECLARADA, NUNCA QUEM CONSOME A
  PEÇA.** O stylebox `pilula` tinha duas cores declaradas e CINCO consumidores —
  o botão Pausar vestia-o por `styles/normal` —, e movê-lo pelo inventário das
  CORES deixou o `Main.tscn` sem carregar. Antes de mover uma peça de estilo,
  procure todo `SubResource("<id>")`. E um `Button` não veste variação de
  `PanelContainer`.
- ⚠️ **CENA QUE NÃO CARREGA ERA INVISÍVEL**, e já não é: `ResourceLoader.exists()`
  só diz que o arquivo está lá. Com um `SubResource` órfão o `load()` devolve
  `null`, o `.instantiate()` aborta a função, e quem chama faz `continue`. A
  régua encerrava com `CONTRASTE MEDIDO` e 46 textos a menos.
- ⚠️ **O FUNDO VERIFICA-SE PELA FRENTE.** Guarda nenhuma mede a cor de um fundo;
  mede-se o texto contra ele. Pintar o stylebox de outra cor moveu 12 razões de
  uma vez — 4 números × 3 estados —, e é assim que se prova que uma variação de
  stylebox chegou mesmo aos nós.
- ⚠️ **ESTADO QUE É RESULTADO DE UMA REGRA NÃO SE ALCANÇA POR `set()`.** O
  percurso do D33 aceita agora `"acao"`, e o estado novo entra pela PORTA DO
  JOGADOR (`assign_all_free_workers`, o que o botão "Alocar todos" chama).
- ⚠️ **Guarda que passa de primeira é para desconfiar**, e o defeito injetado
  nunca desce de modelo.

---

## 4. Restrições

- Nada de `# TUNING:`, política de perfis, sementes do jogo, projeção,
  enquadramento, viewport ou `SAVE_VERSION` — salvo se a (b) for a escolhida.
- Não mexa em gerador cuja saída o CI compara byte a byte.
- **Não reabra o R1–R9 nem a leva da barra escura.**
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
