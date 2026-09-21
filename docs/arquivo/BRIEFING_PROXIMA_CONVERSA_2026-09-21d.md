# BR Port — prompt para a próxima conversa (a fila volta ao R9)

**Como usar:** abra uma conversa nova no repositório `Brunoleon98/br-port` e
cole este texto. Não é preciso anexar o histórico da conversa anterior.

**Modelo:** o R9 abre em **F1** e pede **Opus** para desenhar a medição do
áudio; o resto desce para Sonnet. O prompt dele está em
`docs/arquivo/BRIEFING_PROXIMA_CONVERSA_2026-09-21b.md` — **leia-o a seguir a
este**, que só diz o que mudou por baixo dele.

**Situação:** 21/09 fechou DOIS itens fora da fila, um a seguir ao outro:
`docs/decisoes/038` (as capturas que não existiam) e `039` (o portão que
pergunta se um painel tem foto). Os quinze painéis do jogo têm fotografia, a
bateria tem **24 tiros** e acaba em `COBERTURA OK`.

⚠️ **Confira o estado da branch antes de reapontar.** Se o PR já foi fundido, a
receita é `git checkout -B <nome> origin/main`, e **antes disso**
`git log --oneline origin/main..HEAD` para saber o que ficaria de fora.

## 1. Comece pelo estado real

- Confira repositório, branch, `git status`, HEAD e o local contra o remoto
  **antes** de sincronizar. Preserve trabalho não publicado.
- Leia `CLAUDE.md` (carrega sozinho) e `docs/ESTADO_DO_PROJETO.md`.
- ⚠️ **O `ESTADO_DO_PROJETO.md` ESTÁ A 8 BYTES DO TETO** — 28.992 de 29.000, e
  isto já não é folga nenhuma. Ele coube porque 21/09 comprimiu TRÊS vezes: o
  R1–R5 virou um parágrafo só, o R6/R7/R8 e as duas entregas do dia viraram uma
  TABELA, e uma linha duplicada saiu. A compressão fácil acabou. **Subir o teto
  é o passo 3 da ordem que a ferramenta imprime, e é legítimo** — não foi feito
  em 21/09 por ser decisão, e não por ser errado. Decida, e ponha a razão no
  commit.
- Rode `python3 tools/conferir_docs.py`, `conferir_guardas_ci.py` e
  `conferir_escopo_ui.py` antes de se surpreender no CI.

---

## 2. A entrega: o R9, e o que mudou por baixo dele

**A fila da §7.1 continua no R9** — áudio medido (true peak, espectro) mais o
protocolo de escuta. O prompt está em
`docs/arquivo/BRIEFING_PROXIMA_CONVERSA_2026-09-21b.md` e não se repete aqui.
⚠️ Ele acaba num **gate de escuta que só o Bruno passa**: este contêiner não
tem placa de som, e nunca escreva "o som ficou bom" — escreva "toca no evento
X, dura Y ms, roteado no bus Z".

### O que 21/09 mudou por baixo dele, e que o R9 herda

| Mudou | O que isso quer dizer para quem vier |
|---|---|
| a bateria tem **24 tiros** e acaba em `COBERTURA OK` | um painel novo **sem foto fica VERMELHO**, e um tiro que fotografe o painel errado também. A cobertura é medida nos logs, não declarada (`039`) |
| a varredura de erro da bateria é `SCRIPT ERROR\|GDScript backtrace` | ⚠️ **NÃO a leve para o `testes.yml`**: o `teste_fumaca` imprime um erro de JSON de propósito e ele TRAZ backtrace — medido, o padrão novo casa 1 linha lá (`038`) |
| cada tiro tem `timeout 180` | um `--script` que aborte no `_process` nunca chega ao `quit()`: sem teto, a bateria pendurava sem log, sem foto e sem uma palavra |
| as ferramentas imprimem `Paineis: res://...` | é contrato: mexer no rótulo reprova o portão, que diz exactamente isso em vez de acusar quinze painéis perdidos |

### E há trabalho de ARTE destravado, se o R9 encostar no gate

O **A5 é olhar**, e até 21/09 havia painel que o Bruno não tinha como ver. Já
não há: as 24 fotos da bateria cobrem do Construir ao fim de Fase 1. Se o R9
parar à espera dele, o que está pronto para ser olhado é isso — e as duas
coisas medidas que continuam por fazer, cada uma sessão própria, são **a rua
parada em 1,8** (alargá-la empurra o `RUA_RECUO` e o enquadramento, `012`) e **o
quadro dos props, 89,6% moldura vazia** (cortá-lo mexe na origem do mundo,
`029`).

## 3. Armadilhas que este projeto já mediu e que mordem aqui

- ⚠️ **Este contêiner não tem placa de som.** Nada do que o R9 produzir pode
  ser descrito como "bom" — só como medido.
- ⚠️ **Tela nova é OVERLAY, nunca fase do `GameState`.** Uma fase a mais fez
  24 de 30 partidas não terminarem, e o CI passava.
- ⚠️ **Autoload novo nasce DESLIGADO**, e quem o liga é o jogo: tudo o que ele
  faça por omissão acontece também nas 600 partidas do simulador e nas seis
  suítes.
- ⚠️ **Guarda que passa de primeira é para desconfiar**, e o defeito injetado
  nunca desce de modelo. Em 21/09 foram treze mutantes em dois itens, e dois
  deles (M2b e N6) existem só para provar que a guarda ANTIGA deixava passar.
- ⚠️ **A saída das ferramentas deste projeto é CONTRATO.** Antes de imprimir
  texto novo, procure que strings alguém procura na saída dela — hoje são
  `Tela salva em`, `Overlay:`, `Paineis:` e os marcadores de cada suíte.

## 4. Restrições

- Nada de `# TUNING:`, política de perfis, sementes do jogo, projeção,
  enquadramento, viewport ou `SAVE_VERSION`.
- Não mexa em gerador cuja saída o CI compara byte a byte.
- **Não reabra o R7, o R8 nem as duas entregas de 21/09.** Os estados de cada
  tiro estão escritos ao lado dele, com o que fica de fora e porquê.
- ⚠️ **Não leve a varredura `GDScript backtrace` para o `testes.yml`.** É
  medido: o `teste_fumaca` imprime um erro de JSON de propósito e ele TRAZ
  backtrace — o padrão novo casa 1 linha lá e poria uma suíte verde a vermelho
  (`038`).
- Código, comentários, nomes e documentos em pt-BR; commits e PR em inglês.
- Achou algo de outro item? Registre com a evidência e siga.

---

## 5. O que continua pendente do Bruno, e não é desta sessão

- **Três decisões de PALAVRA**: o rótulo `"Caixa: R$…"`
  (`DebtPaymentPanel.gd:68`), o `"dinheiro no caixa"` da fala da semana nova, e
  o `"0 dias daqui"` do painel da parcela.
- **A6 — ouvir.** Este contêiner não tem placa de som.
- **A5 — olhar.** ⚠️ **E ele destravou:** há agora foto dos quinze painéis, do
  Construir ao fim de Fase 1. O que falta é o olho dele.

---

## 6. O que entregar ao encerrar

Branch e commit; arquivos alterados; o antes e o depois medidos; os comandos e
os marcadores; **quais mutantes reprovaram e por quê**; o que ficou pendente do
Bruno; o que ficou de fora e por quê.

⚠️ **E O BRIEFING DA CONVERSA SEGUINTE ENTRA NO MESMO COMMIT DE FECHO**, em
`docs/arquivo/`, datado, com a linha dele no índice de `docs/arquivo/README.md`
— nunca depois do merge. Uma sessão nova arranca da `main`, então um briefing
escrito a seguir fica órfão numa branch que ninguém volta a abrir.

**E entrega-se ao Bruno em BLOCO COPIÁVEL na conversa, antes de ele fundir.**

⚠️ **E O CI NÃO RODA AO EMPURRAR A BRANCH.** `testes.yml` e `captura.yml`
disparam em `push` só na `main` e em `pull_request`. Até o PR abrir, "verde"
quer dizer apenas "verde neste contêiner". O PR só se abre a pedido.
