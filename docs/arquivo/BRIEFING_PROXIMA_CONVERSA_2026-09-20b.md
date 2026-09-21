# BR Port — prompt para a próxima conversa (R7)

**Como usar:** abra uma conversa nova no repositório `Brunoleon98/br-port` e
cole este texto. Não é preciso anexar o histórico da conversa anterior.

**Modelo:** o R7 abre em **F1** e pede **Opus** — ele tem de DECIDIR o que é
exceção legítima e o que migra, e essa classificação é a entrega inteira. A
execução (rodar o scanner, aplicar migrações já escolhidas, medir) desce para
Sonnet assim que a lista estiver escrita.

**Situação da entrega anterior:** o **R6 fechou** em 20/09 —
`docs/decisoes/035`. Zero textos abaixo do AA em 214 medidos, 19 estados.

⚠️ **A branch `claude/vibrant-cannon-l3rzne` foi empurrada mas o PR só se abre
a pedido do Bruno.** Confira o estado dela antes de reapontar: se o PR foi
fundido entretanto, a receita é `git checkout -B <nome> origin/main`, e antes
disso `git log --oneline origin/main..HEAD` para saber o que fica de fora.

---

## 1. Comece pelo estado real

- Confira repositório, branch, `git status`, HEAD e o local contra o remoto
  **antes** de sincronizar. Preserve trabalho não publicado.
- Leia `CLAUDE.md` (carrega sozinho), `docs/ESTADO_DO_PROJETO.md` e a **§7.1**
  de `docs/design/BR_Port_Plano_v3_Claude_Code.md`. Para o R7, a origem é
  `docs/REVISAO_GERAL_2026-09-17.md` **§2.4**, segunda metade.
- ⚠️ **O teto do `ESTADO_DO_PROJETO.md` subiu para 29.000 em 20/09** e ele está
  a **27.937** — 1.063 de folga, que é a primeira vez em três entregas que ele
  tem espaço. A razão está no comentário de `tools/conferir_docs.py`, e ela
  inclui um aviso: **se duas entregas seguidas voltarem a subir o teto sem que
  nada desça, o defeito é o documento a crescer calado outra vez.**
- Rode `python3 tools/conferir_docs.py` e `python3 tools/conferir_guardas_ci.py`
  antes de se surpreender no CI.

---

## 2. As duas decisões de PALAVRA continuam com o Bruno

Saíram da leitura em voz alta de 19/09 e o R6 **não** lhes tocou — texto é gate
dele. **Pergunte antes de mexer, e são uma linha cada:**

1. **O rótulo `"Caixa: R$…"`** do painel da parcela
   (`DebtPaymentPanel.gd:68`). "Caixa" é o jargão que ele mandou tirar das
   falas. ⚠️ **A COR dele mudou em 20/09** (`RotuloSecao`, 2,93:1 → 5,46:1) e a
   PALAVRA não — trocar a palavra mexe na largura que o **D18** e o **D19**
   medem, e não na cor.
2. **`"Semana nova. Barcos na fila e dinheiro no caixa. Aproveita."`**
   (`semana_nova_fila_folgado`), que é a fala na captura `porto.png`.

---

## 3. A entrega: R7 da §7.1

O que a §7.1 promete, na íntegra:

> **R7 — escopo da UI.** Classificar overrides antes de removê-los, usando tema
> e variações por papel. Exceção exata por propriedade/local, com justificativa;
> não liberar arquivo inteiro. Scanner de `.gd`, `.tscn` e recursos relevantes
> não deve acusar cores de mapas/arte procedural. Considerar multiline,
> comentários e construção dinâmica; complementar com runtime em R6. Mutantes:
> override em cena, nova chamada no arquivo que já tinha outra exceção e
> variação inexistente. Bloquear novas exceções pode anteceder a migração toda.

### O que o R6 já entregou, e que o R7 herda

⚠️ **Isto é medição, não previsão** — medida no commit do R6. Reconfira no seu
HEAD antes de agir.

- **Ficaram 18 `add_theme_color_override`** em cinco scripts (eram 21; o R6
  migrou três para a variação `RotuloAlerta`). ⚠️ **Todos passam o portão
  medido** — o D33 percorre 19 estados e nenhum texto reprova. Logo o R7
  **não é uma caça a defeitos de contraste**: é governança. Quem o tratar como
  caça vai achar zero e concluir que não há trabalho.
- **O motor já responde "de onde veio esta cor".** O
  `scripts/validation/contraste_ui.gd` tem `origem_da_cor()`, que devolve
  `override`, o nome da variação, ou `tema` — e a tabela do
  `tools/medir_contraste_ui.gd` já imprime essa coluna em cada linha. É o
  inventário em RUNTIME que a ficha pede como complemento, e ele existe: rode-o
  antes de escrever scanner nenhum.
- **O D33 é o gate de contraste e não sai.** O R7 acrescenta o gate de
  ESCOPO — cor pintada à mão fora da exceção declarada —, que é outra pergunta.

### O que é F1 nesta sessão, e não se decide sozinho

- **O que é exceção legítima.** Há casos medidos em que o override é o certo:
  o `COR_AVISO` do `Main.gd` continua a servir os rótulos da barra ESCURA, onde
  ele mede 5,53:1 e foi calibrado; os `COR_CALMA`/`COR_ESPERANDO` do
  `DocaCartao` variam com o ESTADO da doca. Uma migração cega quebra-os.
- **A granularidade da exceção.** A ficha proíbe liberar arquivo inteiro. Por
  propriedade? Por linha? Por par (arquivo, constante)?
- **Onde o scanner NÃO entra.** `gerar_mapa_iso.py` e `gerar_props_iso.py` são
  cheios de cor e não são UI. A fronteira é decisão.

### Uma coisa achada pelo R6, e que é do R7

⚠️ **`PainelCalendario.COR_PASSADO` é `0,35/0,42/0,52` e a variação do tema é
`0,35/0,42/0,50`** — duas grafias quase iguais da mesma cor, medindo 5,42:1 e
5,46:1. Nenhuma reprova nada. É exatamente o tipo de divergência calada que o
R7 existe para acabar, e serve de caso de teste para a classificação.

### Armadilhas que este projeto já mediu e que mordem aqui

- ⚠️ **`contains()` num arquivo de configuração quase nunca é a pergunta que se
  quer fazer** — e um scanner de `.gd`/`.tscn` é isso em ponto grande. Linha
  dentro de COMENTÁRIO satisfaz uma busca no arquivo inteiro, e o `CLAUDE.md`
  regista que o comentário que EXPLICA a armadilha já satisfez a busca que a
  caçava. Corte as linhas de comentário antes de varrer.
- ⚠️ **Número partido por uma quebra de linha escapa a todo `grep` de linha.**
  A prosa deste repositório quebra aos ~79 caracteres.
- ⚠️ **Guarda que passa de primeira é para desconfiar**, e o defeito injetado
  nunca desce de modelo. O R6 precisou de DUAS tentativas no primeiro mutante:
  a primeira ACRESCENTAVA um parágrafo ao painel e quem reprovou foi outra
  guarda — a de contraste nunca chegou a ser exercida (`035`).
- ⚠️ **Antes de dar um teste por redundante, pergunte que defeito ele vê que o
  outro não vê.** O R6 manteve o D19, o D23 e o D32 ao lado do D33 por isso.

### Restrições

- Nada de `# TUNING:`, política de perfis, sementes, projeção, enquadramento,
  viewport ou `SAVE_VERSION`.
- Não mexa em gerador cuja saída o CI compara byte a byte para calar uma falha.
- A entrega do R7 é a CLASSIFICAÇÃO e o gate de escopo. Bloquear exceções novas
  pode vir antes da migração toda — a própria ficha o diz.
- Código, comentários, nomes e documentos em pt-BR; commits e PR em inglês.
- Achou algo de outro item? Registre com a evidência e siga.

---

## 4. O que entregar ao encerrar

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
