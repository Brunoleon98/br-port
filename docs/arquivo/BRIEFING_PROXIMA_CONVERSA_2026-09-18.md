# BR Port — prompt para a próxima conversa (R4)

**Como usar:** abra uma conversa nova no repositório `Brunoleon98/br-port`, no
modelo de decisão (Opus, porque a sessão abre em F1), e anexe este arquivo.
Não é preciso anexar o histórico da conversa anterior.

**Situação da entrega anterior:** o **R2 e o R3 fecharam juntos**, no PR #57
(`claude/sharp-tesla-345pi6`, commits `927255c` e `5223cd6`), com os três
checks verdes no head e `mergeable_state: clean`. O Bruno funde o PR.

⚠️ **PR FUNDIDO NÃO QUER DIZER BRANCH FUNDIDA**, e a branch designada
reaproveita o nome. Antes de a reapontar da `main`, pergunte o que fica de fora
— `git log --oneline origin/main..HEAD` — e recupere pelo remoto
(`git reset --hard origin/<nome>`) em vez de assumir que a `main` tem tudo.
Em 11/09 isso apanhou um commit empurrado DEPOIS do merge.

---

## Prompt — copie daqui ou peça para executar este arquivo

Continuando o BR Port. Quero trabalhar no **R4 da §7.1: as regras pequenas da
narrativa**. O R2 e o R3 fecharam; não os reabra, não execute outras frentes da
fila, e não abra uma revisão nova.

### 1. Comece pelo estado real

- Confira repositório, branch designada, `git status`, HEAD e o que há de
  local contra o remoto **antes** de sincronizar. Preserve trabalho não
  publicado; nada de reset destrutivo.
- Leia `CLAUDE.md` (carrega sozinho), `docs/ESTADO_DO_PROJETO.md` e a **§7.1**
  de `docs/design/BR_Port_Plano_v3_Claude_Code.md`, que é a fila em vigor.
  A origem do item é `docs/REVISAO_GERAL_2026-09-17.md`, **§2.2 e §2.3**.
- As duas sessões anteriores deixaram `docs/decisoes/031` e `032`, e seis
  regras novas no `CLAUDE.md`. Três delas mordem neste item:
  *"fala DISPARADA não é fala VISTA"*, *"a frase pode ser verdadeira em
  português e falsa neste mundo"* e *"ao corrigir um, VARRA OS IRMÃOS"*.
- ⚠️ **O `ESTADO_DO_PROJETO.md` está a 25.955 bytes de um teto de 26.000.**
  São **45 bytes** de folga, e ele foi comprimido DUAS vezes em 18/09. A ordem
  escrita continua a valer (histórico desce, duplicação vira ponteiro), mas o
  terceiro passo — **subir o teto, de propósito e com a razão no commit** — é
  legítimo e está por decidir. Pergunte ao Bruno em vez de comprimir uma
  terceira vez.
- ⚠️ **E o `tools/conferir_docs.py` ganhou quatro perguntas novas em 18/09.**
  Uma edição de documento pode agora reprovar por repetir as taxas do
  balanceamento, por nomear um número de partidas que o comando não roda, ou
  por deixar uma suíte de fora. Rode-o antes de se surpreender no CI.

### 2. Objetivo desta sessão: R4

O que a §7.1 promete, na íntegra:

> **R4 — regras pequenas.** Oito falas não justificam motor fuzzy ou DSL nova.
> Usar IDs/textos e predicados explícitos sobre o snapshot do evento, com
> expectativas textuais revisadas. Não inventar limiar financeiro: usar
> critério existente ou remover "caixa no limite". A obra instantânea não
> "demorou". Alternativas não podem introduzir fatos sem condição;
> repetição/cooldown são decisões editoriais a medir. Mutantes: condição
> retirada, frase falsa reintroduzida, comparação antes de existir semana
> anterior. A aprovação do predicado não substitui a releitura A4.

São **três defeitos**, e a §7.1 autoriza parti-los se for preciso:

**(a) A fala que ninguém vê.** `upgrade_pronto` está ligada a
`estrutura_comprada`, e o `GameState` emite o sinal **uma linha antes** de uma
`message.emit` que escreve no MESMO `Label`. A Dona Cida fala e é tapada no
mesmo frame. Há três outros pares da mesma família, ligados a `cash_changed`.

**(b) A fala que é falsa neste mundo.** *"Zezão terminou. Demorou o dobro do
previsto"* — a obra é INSTANTÂNEA: `comprar_estrutura()` emite "pronto" na
mesma chamada. Nada demorou.

**(c) A fala que afirma um estado sem o olhar.** *"Semana nova. Barcos na fila,
caixa no limite"* dispara em toda semana ≥ 2 sem olhar o caixa. A captura
`porto.png` mostra-a com **R$981.779** no HUD.

⚠️ **DUAS METADES DESTE ITEM SÃO DO BRUNO, e não se decidem sozinhas:** que
frase o Zezão passa a dizer, e que frase a Dona Cida diz quando o caixa está
folgado. A revisão diz isso com todas as letras nos dois sítios. Construa a
máquina e a guarda, proponha o texto, e **pare** — a releitura em voz alta é
gate do A4.

### 3. Trabalhe pelas fases, e anuncie o número

F1/F3/F4/F6 decidem e pedem Opus; F2/F5/F7 executam e descem para Sonnet.
Nenhum modelo troca o próprio modelo — anuncie qual o próximo bloco pede e
pare quando for para cima. Não delegue a subagente sem pedido.

- **F1** — conte você mesmo quantos pares `sinal → message.emit` existem e
  quais falas afirmam estado. Desenhe a medição e os mutantes antes de
  escrever código.
- **F2** — reproduza os três com evidência, não com leitura de código: um
  `--script` descartável que instancie o `Main.tscn`, dispare o evento e LEIA
  o `Label` no frame seguinte.
- **F3** — diga o que a medição quer dizer, e se contraria este briefing.
- **F4** — escolha a correção mínima. Não construa fila de mensagens: isso é
  o **R5**, e é item próprio.
- **F5** — aplique e repita a MESMA medição.
- **F6** — a guarda "fala VISTA" e o defeito injetado. **Nunca desce.**
- **F7** — `/fechar-sessao`.

### 4. Prova mínima

⚠️ **A pergunta que pega não é a que o F4 já faz.** O bloco F4 do
`teste_fumaca.gd` pergunta *"toda fala DISPARA?"* — e ela dispara. A pergunta
nova é do OUTRO lado do frame: **o que sobrou no `Label` depois de todos os
emits daquele evento.** É a quarta cara do `barco_medio`, e as três primeiras
já estão escritas no `CLAUDE.md`.

Os mutantes que a §7.1 nomeia, cada um separado e com controle positivo verde
entre eles: **condição retirada**; **frase falsa reintroduzida**; **comparação
antes de existir semana anterior**.

⚠️ E duas lições que as sessões de 18/09 mediram, porque mordem aqui:

- **Receita derivada que não casa nada dá um verde de graça.** Um `grep` que
  casou zero comandos deixou o `git diff` vazio, e isso leu-se como sucesso.
  Conte o que a derivação achou antes de acreditar no silêncio dela (`032`).
- **Contar o que está aberto no FIM não diz o que estava aberto DURANTE.** A
  guarda de painéis via um painel e ficava contente enquanto a ferramenta
  atravessava três turnos por baixo dele (`031`). Aqui é o mesmo: contar que a
  fala foi emitida não diz que ela foi lida.

### 5. Restrições

- Nada de `# TUNING:`, política de perfis, sementes, projeção, enquadramento,
  viewport ou `SAVE_VERSION`. **E nenhum limiar financeiro inventado** — use
  um critério que já exista ou remova a afirmação.
- Não construa a fila de mensagens nem a consulta ao histórico: é o **R5**.
- Não mexa em gerador cuja saída o CI compara byte a byte para calar uma
  falha, nem atualize baseline com esse fim.
- Código, comentários, nomes e documentos em pt-BR; commits e PR em inglês.
- **A escrita é do Bruno.** A4, A5 e A6 continuam gates dele; um predicado
  verde não aprova uma frase.
- Achou algo de outro item? Registre com a evidência e siga.

### 6. O que entregar ao encerrar

Branch e commit; arquivos alterados; o antes e o depois de cada defeito que
tocou; os comandos e os marcadores; **quais mutantes reprovaram e por quê**; o
texto PROPOSTO para o Bruno aprovar; o que ficou de fora e por quê. Atualize o
R4 na §7.1 só até a fase comprovada.

---

## Apêndice — o que as sessões do R2 e do R3 mediram

⚠️ **Isto é medição, não previsão — mas foi medida no commit `5223cd6`.**
Reconfira no seu HEAD antes de agir.

### ⚠️ OS NÚMEROS DE LINHA DA REVISÃO ESTÃO ERRADOS, e fui eu que os movi

A `REVISAO_GERAL` de 17/09 cita `GameState.gd:1427→1428` para o par que causa
(a). O R3 acrescentou **quatro linhas de comentário** ao topo daquele arquivo,
e hoje esse par está em **`:1431→1432`**. Todo número de linha do `GameState.gd`
naquela revisão está **+4**; o `Main.gd:1253` dela é hoje `:1252`.

**Localize por CONTEÚDO, não por linha** — e esta é a razão de a regra existir.
Conferido no head de hoje:

| O que | Onde, hoje |
|---|---|
| `estrutura_comprada.emit(id)` → `message.emit("%s — pronto…")` | `GameState.gd:1431→1432` |
| `cash_changed.emit(cash)`, quatro sítios | `GameState.gd:1042, 1098, 1327, 1429` |
| `semana_fechada.emit(resumo)` | `GameState.gd:1123` |
| o gatilho da fala do upgrade | `Main.gd:1022` |
| `_cida_semana` | `Main.gd:1347` |
| quem escreve no `Label` | `Main.gd:1252` (`_on_message`) |
| *"caixa no limite"* | `Narrativa.gd:142` |

### O que o R2 e o R3 deixaram de pé, para não voltar como suspeita

- **Seis suítes verdes** com marcador, `GUARDAS OK`, `DOCS OK`, `GDD OK`,
  `TABELA OK`, os quatro mapas byte a byte, e as 16 capturas reprodutíveis.
- **Onze passos de CI rodam `--script` e os onze têm guarda de erro.** O padrão
  é `SCRIPT ERROR|at: push_error \(` e **nunca `ERROR`**: medido no runner do
  GitHub, uma corrida VERDE imprime seis linhas `ERROR:` benignas — cinco do
  encerramento do motor e uma que o `teste_fumaca` injeta de propósito.
- **A captura avança por TURNO EFETIVO** e pára diante de modal. Cada tiro
  declara o turno em que pára; `-- N` entrega o que promete.
- **As taxas do balanceamento têm UM endereço vivo**, o `CLAUDE.md`
  (100% / 80,2% / 37,3%, medido em 600 partidas com a semente 20260825). Um
  segundo endereço reprova no `conferir_docs.py`.
- O jogo não mudou em nenhuma das duas: nenhum `# TUNING:`, nenhuma semente,
  nenhum pixel de arte.

### ⚠️ O CI NÃO RODA AO EMPURRAR A BRANCH

`testes.yml` e `captura.yml` disparam em `push` **só na `main`** e em
`pull_request`; `balanceamento.yml` é manual/semanal. Até o PR abrir, "verde"
quer dizer apenas "verde neste contêiner" — e o export do APK, a única coisa
que o contêiner **não** consegue medir (`dl.google.com` responde 403), só corre
a partir daí. Se quiser o CI a correr, é PR — e o PR só se abre a pedido.

### Registrado e deliberadamente NÃO corrigido

- **§2.9** — o `arte_orfa.py` conta `scenes/proto/` como consumidor, e os cinco
  sprites de `art/sprites/` são referidos só por cenas que o export exclui. É
  uma linha na ferramenta; o destino dos arquivos é **do Bruno**.
- **§2.10** — o slider de "Música" controla um bus vazio. Esconder até ao A6 é
  uma linha; **decisão do Bruno**.
- **§2.5** — o painel da parcela conta os dias de um jeito e o desconto de
  outro. Não misture com o R8.
