# BR Port — prompt para a próxima conversa (R8)

**Como usar:** abra uma conversa nova no repositório `Brunoleon98/br-port` e
cole este texto. Não é preciso anexar o histórico da conversa anterior.

**Modelo:** o R8 abre em **F1** e pede **Opus** por pouco tempo — a decisão é
qual é a frase certa em cada caso de plural e quais são os casos literais do
teste, e isso é escolha. Assim que a tabela de casos estiver escrita, a
execução desce para Sonnet. É a menor entrega da fila e a ficha diz porquê:
*"curta, pode acompanhar revisão textual"*.

**Situação da entrega anterior:** o **R7 fechou** em 21/09 —
`docs/decisoes/036`. A branch foi empurrada; **o PR só se abre a pedido do
Bruno**.

⚠️ **Confira o estado da branch antes de reapontar.** Se o PR do R7 já foi
fundido, a receita é `git checkout -B <nome> origin/main`, e **antes disso**
`git log --oneline origin/main..HEAD` para saber o que ficaria de fora.

---

## 1. Comece pelo estado real

- Confira repositório, branch, `git status`, HEAD e o local contra o remoto
  **antes** de sincronizar. Preserve trabalho não publicado.
- Leia `CLAUDE.md` (carrega sozinho), `docs/ESTADO_DO_PROJETO.md` e a **§7.1**
  de `docs/design/BR_Port_Plano_v3_Claude_Code.md`. Para o R8, a origem é
  `docs/REVISAO_GERAL_2026-09-17.md` **§3**.
- ⚠️ **O `ESTADO_DO_PROJETO.md` está a 28.577 de 29.000** — 423 de folga. O
  teto subiu em 20/09 e **não subiu em 21/09**: o R7 coube comprimindo o bloco
  do R6, que já tem decisão própria. Se a sua entrega não couber, a ordem está
  escrita na própria mensagem de erro da ferramenta, e subir o teto é o último
  passo dela, não o primeiro.
- Rode `python3 tools/conferir_docs.py`, `python3 tools/conferir_guardas_ci.py`
  e `python3 tools/conferir_escopo_ui.py` antes de se surpreender no CI.

---

## 2. As duas decisões de PALAVRA continuam com o Bruno

Saíram da leitura em voz alta de 19/09. Nem o R6 nem o R7 lhes tocaram — texto
é gate dele. **Pergunte antes de mexer, e são uma linha cada:**

1. **O rótulo `"Caixa: R$…"`** do painel da parcela
   (`DebtPaymentPanel.gd:68`). "Caixa" é o jargão que ele mandou tirar das
   falas. ⚠️ A COR dele mudou em 20/09 e o ESCOPO em 21/09; a PALAVRA não.
   Trocá-la mexe na largura que o **D18** e o **D19** medem.
2. **`"Semana nova. Barcos na fila e dinheiro no caixa. Aproveita."`**
   (`semana_nova_fila_folgado`), que é a fala na captura `porto.png`.

---

## 3. A entrega: R8 da §7.1

O que a §7.1 promete, na íntegra:

> **R8 — frase inteira.** Cobrir "dia(s) restante(s)", "dia(s) daqui" e
> "tentativa(s)", identificados pela revisão. Helpers pequenos de mensagem ou
> plural do catálogo se este já existir; não criar pipeline de tradução só por
> três ocorrências. Zero, um, dois e 32 têm expectativas literais, incluindo
> adjetivos. Preservar `por_extenso()` na narração. Mutantes: zero singular,
> adjetivo singular com dois e retorno de "(s)" em string da UI. Não misturar
> esta correção com a decisão sobre se o dia atual conta na parcela (§2.5).

### O que já existe, e que o R8 herda

⚠️ **Isto é medição, não previsão** — medida no commit do R7. Reconfira no seu
HEAD antes de agir; o R7 fechou precisamente porque um briefing entregou uma
contagem que era subtração de cabeça.

- **Já há um `_plural()`**, em `scripts/Main.gd`, com comentário próprio: ele
  existe porque *"escrever '1 docas' numa faixa de alerta desfaz o alerta"*.
  Veja o que ele cobre antes de escrever helper novo — a ficha manda reusar o
  catálogo se ele existir.
- **`por_extenso()` está na narração e é trancado pelo F4**, que reprova
  dígito na narração de fim de fase. Não o desfaça: o par "derive da constante
  E escreva por extenso" é decisão registada (`018`), e a guarda que provava a
  ligação pelo DÍGITO já reprovou o texto certo uma vez.
- **O `"dia(s) restante(s)"` está na tela**, medido: a linha do HUD sai hoje
  como *"Parcela do Sr. Ribeiro — 32 dia(s) restante(s)"*, e é uma das 214
  linhas que o `medir_contraste_ui.gd` imprime. É o caso mais visível dos três.

### Armadilhas que este projeto já mediu e que mordem aqui

- ⚠️ **Zero é o caso que se esquece, e é o que a ficha põe primeiro.** "0
  dia restante" e "0 dias restantes" — decida e escreva o porquê.
- ⚠️ **Asserção que monta o esperado da MESMA fonte do defeito não testa
  nada.** Se o teste construir a frase esperada chamando o mesmo helper, ele é
  um espelho. O esperado dos casos 0, 1, 2 e 32 escreve-se **literal**, que é
  exatamente o que a ficha pede.
- ⚠️ **A frase pode ser verdadeira em português e falsa neste mundo**, e
  nenhuma suíte apanha isso — só uma pessoa a ler. Se a correção mudar uma
  palavra de máquina por uma palavra do mundo, pergunte o que a nova palavra
  PROMETE: foi assim que *"32 turnos"* virou *"trinta e dois dias"* e passou a
  contradizer *"quatro semanas"*, que dão 28.
- ⚠️ **Fala escrita não é fala vista.** Se acrescentar variante de fala, o F8
  e o F4 são quem tranca que ela chegue à tela.
- ⚠️ **Guarda que passa de primeira é para desconfiar**, e o defeito injetado
  nunca desce de modelo. O R7 precisou de conferir QUAL guarda reprovava em
  cada um dos oito mutantes, e de um par no MESMO arquivo (M7/M8) para provar
  que um verde era o comentário e não cegueira.

### Restrições

- Nada de `# TUNING:`, política de perfis, sementes, projeção, enquadramento,
  viewport ou `SAVE_VERSION`.
- **Não misture com a §2.5** — se o dia atual conta na parcela é outra decisão,
  e a ficha separa-as de propósito.
- Não mexa em gerador cuja saída o CI compara byte a byte para calar uma falha.
- Código, comentários, nomes e documentos em pt-BR; commits e PR em inglês.
- Achou algo de outro item? Registre com a evidência e siga.

---

## 4. O que o R7 deixou por fazer, e que NÃO é do R8

Dito para não ser reaberto por engano, e porque é trabalho real com um caminho
escrito:

- **27 cores de interface continuam declaradas como exceção**, em
  `tools/excecoes_cor_ui.json`, cada uma com classe (ESTADO ou BASE) e
  justificativa. A ficha do R7 permite isto com todas as letras: *"bloquear
  novas exceções pode anteceder a migração toda"*.
- **A migração delas é por LEVA e por FUNDO, nunca linha a linha** — nenhum tom
  ganha dois fundos, e o âmbar do `_workers_title` (5,53:1 na barra escura) não
  é o `RotuloAlerta` (o mesmo âmbar escurecido para o cartão branco). Uma
  migração cega quebra o que está medido.
- ⚠️ **E o percurso dos 19 estados não monta três dos estados que pintam cor à
  mão** — dia já vivido do calendário, estrutura já construída, doca sob oferta
  do rival. **O estado vem primeiro, a cor depois:** migrar uma cor que o D33
  não alcança troca uma dívida visível por uma invisível.

---

## 5. O que entregar ao encerrar

Branch e commit; arquivos alterados; o antes e o depois medidos; os comandos e
os marcadores; **quais mutantes reprovaram e por quê**; o que ficou pendente do
Bruno; o que ficou de fora e por quê. Atualize a §7.1 só até a fase comprovada,
e o `ESTADO_DO_PROJETO.md` dentro do teto.

⚠️ **E O BRIEFING DA CONVERSA SEGUINTE ENTRA NO MESMO COMMIT DE FECHO**, em
`docs/arquivo/`, datado, com a linha dele no índice de `docs/arquivo/README.md`
— nunca depois do merge. Uma sessão nova arranca da `main`, então um briefing
escrito a seguir fica órfão numa branch que ninguém volta a abrir.

**E entrega-se ao Bruno em BLOCO COPIÁVEL na conversa, antes de ele fundir** —
não como arquivo anexado.

⚠️ **E O CI NÃO RODA AO EMPURRAR A BRANCH.** `testes.yml` e `captura.yml`
disparam em `push` só na `main` e em `pull_request`. Até o PR abrir, "verde"
quer dizer apenas "verde neste contêiner" — e o export do APK, que este
contêiner não consegue medir, só corre a partir daí. O PR só se abre a pedido.
