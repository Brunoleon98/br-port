# BR Port — prompt para a próxima conversa (R6)

**Como usar:** abra uma conversa nova no repositório `Brunoleon98/br-port` e
cole este texto. Não é preciso anexar o histórico da conversa anterior.

**Modelo:** o R6 abre em F1 e pede **Opus** — ele tem de DECIDIR o que conta
por "composição não resolvida" e onde parar a auditoria. A execução (percorrer
painéis, medir pares, aplicar a variação já escolhida) desce para Sonnet assim
que a decisão estiver escrita.

**Situação da entrega anterior:** o **R5 fechou** em 20/09 — a faixa de
mensagem tem fila, e as duas vozes chegam. `docs/decisoes/034`. O gate **A4**
correu no mesmo dia e as quatro notas do Bruno estão aplicadas.

⚠️ **A branch `claude/confident-ramanujan-77lpzf` foi empurrada mas NÃO havia
PR aberto** quando esta conversa fechou — o PR só se abre a pedido do Bruno.
Confira o estado dela antes de reapontar: se o PR foi fundido entretanto, a
receita é `git checkout -B <nome> origin/main`, e antes disso
`git log --oneline origin/main..HEAD` para saber o que fica de fora.

---

## 1. Comece pelo estado real

- Confira repositório, branch, `git status`, HEAD e o local contra o remoto
  **antes** de sincronizar. Preserve trabalho não publicado.
- Leia `CLAUDE.md` (carrega sozinho), `docs/ESTADO_DO_PROJETO.md` e a **§7.1**
  de `docs/design/BR_Port_Plano_v3_Claude_Code.md`. Para o R6, a origem é
  `docs/REVISAO_GERAL_2026-09-17.md` **§2.4**.
- ⚠️ **O `ESTADO_DO_PROJETO.md` está a 27.801 bytes com teto de 28.000** — 199
  de folga. Ele NÃO cabe mais uma entrega sem descer história primeiro. A ordem
  escrita no `/fechar-sessao` continua a valer: histórico desce para
  `docs/arquivo/HISTORICO.md`, duplicação vira ponteiro, e **só então** se sobe
  o teto, de propósito e com a razão no commit.
- Rode `python3 tools/conferir_docs.py` e `python3 tools/conferir_guardas_ci.py`
  antes de se surpreender no CI.

---

## 2. Duas decisões de PALAVRA que ficaram com o Bruno

Saíram da leitura em voz alta de 19/09 e não foram aplicadas porque texto é
gate dele. **Pergunte antes de mexer, e são uma linha cada:**

1. **O rótulo `"Caixa: R$…"`** do painel da parcela
   (`DebtPaymentPanel.gd:68`). "Caixa" é o jargão que ele mandou tirar das
   falas — este é o mesmo termo num rótulo que o jogador lê no momento mais
   tenso do jogo. ⚠️ Trocar mexe na largura que o **D19** mede.
2. **`"Semana nova. Barcos na fila e dinheiro no caixa. Aproveita."`**
   (`semana_nova_fila_folgado`). Ele aprovou esta fala sem comentário, e ela é
   a que aparece na captura `porto.png`. "dinheiro" vem antes e carrega o
   sentido — pode passar, mas é a mesma palavra na foto que mais se olha.

---

## 3. A entrega: R6 da §7.1

O que a §7.1 promete, na íntegra:

> **R6 — resultado visual, não só tema.** Reutilizar a variação candidata de
> 5,46:1 e medir a cor final em todos os painéis/estados relevantes: herança,
> override, modulação e fundo real. 4,5:1 é o gate proposto para texto pequeno;
> não arredondar para aprovar. 7:1 é referência ampliada opcional, não garantia
> sob sol; APCA não substitui o gate estável. Texto inativo tem exceção WCAG,
> mas o motivo do bloqueio precisa ser lido. Composição não resolvida é
> pendência, não verde automático. Mutantes: par abaixo do limite no painel
> não coberto antes; override ruim com tema correto; estado excluído do
> percurso. Controle positivo/negativo calibra a régua antes da auditoria.

### O que já existe, e que o R6 herda

⚠️ **Isto é medição, não previsão** — mas foi medida no commit do R5.
Reconfira no seu HEAD antes de agir.

- **Três blocos já medem contraste**, e cada um por uma pergunta diferente:
  **D19** (os rótulos do painel Construir sobre o branco), **D23** (as
  variações do tema na primeira tela de fundo ESCURO) e **D32**, novo do R5 (o
  contador `+N` contra o creme REAL da faixa de mensagem). O helper
  `_contraste()` do `teste_design.gd` é o mesmo nos três.
- **A cor que morde chama-se 0,51/0,6/0,706**, o neutro do jogo. Ela mede
  2,93:1 sobre branco e **2,82:1 sobre o creme da faixa** — quatro tropeços
  registados. A variação que passa sobre claro é **0,35/0,42/0,50 (5,46:1
  no branco, 5,27:1 no creme)**.
- **O D32 traz o molde da régua com defeito embutido:** ele exige que o
  `_contraste()` REPROVE o neutro do jogo no mesmo fundo. Sem isso, uma conta
  avariada daria verde com qualquer cor — é o "controle positivo/negativo
  calibra a régua" que a ficha do R6 pede, já escrito.

### O que é F1 nesta sessão, e não se decide sozinho

- **O que conta por "composição não resolvida".** A ficha diz que ela é
  pendência e não verde automático — mas não diz onde está a fronteira.
  `modulate`, `theme_type_variation` herdada, um `ColorRect` de escurecer por
  cima: alguns compõem-se, outros não.
- **Quais estados entram no percurso.** Painel desabilitado, painel por cima de
  outro, o escurecer do `PainelNarrativo`. Texto inativo tem exceção WCAG, e a
  ficha exige que o MOTIVO do bloqueio se leia.
- **Onde a auditoria para.** São doze painéis; medir tudo em todos os estados
  pode ser a sessão inteira. O critério de corte é decisão.

### Armadilhas que este projeto já mediu e que mordem aqui

- ⚠️ **Cor calibrada para um fundo não atravessa para outro.** É a regra que o
  `CLAUDE.md` repete e que o D32 acabou de confirmar: a mesma variação mede
  5,46:1 no branco e 5,27:1 no creme. **Meça contra o fundo REAL**, que pode
  ser o `bg_color` de um `StyleBoxFlat` e não a cor do cartão.
- ⚠️ **Não arredonde para aprovar.** 2,93:1 reprovou o corte de texto GRANDE
  (3,0) por sete centésimos, e foi um defeito verdadeiro em três painéis.
- ⚠️ **Guarda que passa de primeira é para desconfiar** — e a régua precisa do
  mesmo defeito injetado que o validador. O D32 mostra como.
- ⚠️ **`size` de um painel acabado de instanciar é o MÍNIMO**, e o
  `custom_minimum_size` menor do que o conteúdo é ignorado. Duas armadilhas de
  medição de `Control` que já deram folga que não existia (`CLAUDE.md`,
  Interface).

### Restrições

- Nada de `# TUNING:`, política de perfis, sementes, projeção, enquadramento,
  viewport ou `SAVE_VERSION`.
- Não mexa em gerador cuja saída o CI compara byte a byte para calar uma falha.
- O R7 (escopo da UI, o lint de overrides) é item PRÓPRIO — a §7.1 sugere
  combinar o trabalho comum, mas a entrega do R6 é a medição e a correção
  pontual, não a migração toda.
- Código, comentários, nomes e documentos em pt-BR; commits e PR em inglês.
- Achou algo de outro item? Registre com a evidência e siga.

---

## 4. O que entregar ao encerrar

Branch e commit; arquivos alterados; o antes e o depois medidos; os comandos e
os marcadores; **quais mutantes reprovaram e por quê**; o que ficou pendente do
Bruno; o que ficou de fora e por quê. Atualize a §7.1 só até a fase comprovada,
e o `ESTADO_DO_PROJETO.md` dentro do teto — **lembrando que ele já está a 199
bytes dele.**

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
