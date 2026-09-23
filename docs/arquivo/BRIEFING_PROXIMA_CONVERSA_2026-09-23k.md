# BR Port — prompt para a próxima conversa (depois das telas do fim em fila)

**Como usar:** abra uma conversa nova no repositório `Brunoleon98/br-port` e
cole este texto. Não é preciso anexar o histórico da conversa anterior.

**Modelo:** depende do que o Bruno escolher na §2. Cada conversa começa por uma
escolha dele.

**Situação:** em 23/09, numa oitava sessão, o Bruno respondeu à pergunta (b)
do briefing `23j` — a ordem dos painéis depois do «Pagar» — com **«em fila»**,
e ela fechou (`054`). O `Main` põe em fila as três telas que abrem sozinhas (o
Sr. Ribeiro, o boletim e o fim de fase): resposta → boletim da semana 4 → fim
de fase, uma de cada vez, e o mesmo no «Não consigo pagar» e em quem quitou
antes. O `GameState` não mudou uma linha. O **F11** do `teste_fumaca` percorre
os três caminhos pelos botões, e o tiro `balanco` passou de 3 painéis a 1.

---

## ⚠️ LEIA ISTO ANTES DE ESCREVER EM QUALQUER DOCUMENTO

O `ESTADO_DO_PROJETO.md` tem **~650 bytes de folga** (teto no `TETO_ESTADO` de
`tools/conferir_docs.py`). **Comprima ANTES de escrever** — a ordem da skill
`/fechar-sessao` §6 —, e rode o conferidor antes de escrever o commit.

---

## 1. Comece pelo estado real

- ⚠️ **A sessão fechou na branch `claude/gracious-brown-2gnyni`, um commit à
  frente da `main` (`993bb1a`, o PR #74 fundido), SEM PR aberto** — o PR só se
  abre a pedido. Antes de qualquer checkout, confira no GitHub se alguém o abriu
  e fundiu; se não, este trabalho só existe na branch, e reiniciá-la da `main`
  apaga-o.
- **Um ref de cada vez no `git fetch`**, código de saída lido **sem cano**,
  HEAD confirmado com o GitHub, e `git log --oneline origin/main..HEAD` antes de
  reapontar seja o que for.
- **O CI não correu nesta branch** (só corre na `main` e em `pull_request`).
  Quando correr, o `brport-captura` deve dizer **uma foto mudada** — o
  `balanco.png`, que passou de 94.579 a ~207 mil bytes porque o mapa por trás
  fica sob um escurecer em vez de três — e **30 iguais**. Medido aqui: as 30
  com o mesmo tamanho da tabela que o CI publicou para a `main`.
- **São DEZ verdes neste contêiner**: as seis suítes e quatro conferidores
  (`DOCS OK`, `GUARDAS OK`, `ESCOPO UI OK`, `SINAL OK`). A bateria fecha com
  `COBERTURA OK`.

---

## 2. O que sobra, e nenhum deles tem ordem

### (a) Os gates humanos, que só o Bruno passa

| Gate | O que falta |
|---|---|
| **A6 — ouvir** | `docs/PROTOCOLO_DE_ESCUTA.md`, começando pela §4: o `sfx_ui_warn` tem 99% da energia abaixo de 500 Hz; o conserto é subir uma harmónica, **nunca o volume** |
| **A5 — olhar** | as **31** fotos, as quinas do chanfro a 0,60 e o trânsito a andar — e agora o `balanco.png` com o mapa à vista por trás |
| **A4 — ler em voz alta** | as falas reescritas em 23/09 (`048`) — e a resposta do Sr. Ribeiro depois do «Pagar», que pela primeira vez se lê a jogar |

### (c) Os nove órfãos que FICARAM

Presos à `001`; reabra só se a `001` for reaberta.

### (f) O que o atlas deixou de fora

Os retratos inteiros (cortá-los reabre a `049`) e a VRAM medida só aqui — nenhum
telefone.

---

## 3. Armadilhas que 23/09 (oitava sessão) mediu

- ⚠️ **A fila das telas passa a vez pelo `tree_exited`, e é medido.** Ligada ao
  `fechou`, as seis suítes passam — a jogar, toda tela da vez sai pelo
  `_fechar()` — e o tiro `balanco` chega ao vencimento em `debt_payment` sem
  painel nenhum: o `remove_child()` com que a ferramenta dispensa o boletim não
  emite `fechou`.
- ⚠️ **Um caminho de teste que reprova cedo esconde os outros.** O F11 nasceu
  com os três caminhos num bloco só, e a primeira leva de mutantes deu uma
  reprovação a cada um. Separados, cada um com a sua bandeira.
- ⚠️ **Mutante largo demais não isola nada.** Adiar TODO fecho de semana
  estragou a montagem dos três caminhos; o estreito (só a última semana, só no
  `advance_turn()`) reprovou **só** o terceiro — é o que ele vê de único.
- ⚠️ **Tela nova que abra sozinha passa pelo `_na_vez()`** — regra no
  `CLAUDE.md`, Interface.

---

## 4. Restrições

- Nada de `# TUNING:`, política de perfis, sementes do jogo, projeção,
  enquadramento, viewport ou `SAVE_VERSION`.
- Não mexa em gerador cuja saída o CI compara byte a byte sem decisão do Bruno.
- **Não reabra o R1–R9, as CINCO levas de cor, a triagem dos órfãos, a largura
  da rua (`047`), o corte do quadro (`049`), o selo da seleção (`050`), a
  cobertura por tempo (`051`), a mão direita e as quatro regras do cruzamento
  (`052`), o chanfro derivado (`053`) nem a fila das telas do fim (`054`).**
- Código, comentários, nomes e documentos em pt-BR; commits e PR em inglês.

---

## 5. O que entregar ao encerrar

Branch e commit; arquivos alterados; o antes e o depois medidos; os comandos e
os marcadores; **quais mutantes reprovaram e por quê**; o que ficou pendente do
Bruno; o que ficou de fora e por quê. **O briefing seguinte entra no mesmo
commit de fecho**, com a linha no índice de `docs/arquivo/README.md`.

⚠️ **O CI NÃO RODA AO EMPURRAR A BRANCH** — só na `main` e em `pull_request`.
O PR só se abre a pedido.
