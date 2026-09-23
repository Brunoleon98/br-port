# BR Port — prompt para a próxima conversa (a troca da seleção lê-se pela cor)

**Como usar:** abra uma conversa nova no repositório `Brunoleon98/br-port` e
cole este texto. Não é preciso anexar o histórico da conversa anterior.

**Modelo:** depende do que o Bruno escolher na §2. Cada conversa começa por uma
escolha dele.

**Situação:** em 23/09, numa quarta sessão, fechou a opção (b) do briefing
`23f` — **o âmbar da seleção** (`050`). A troca «livre → escolhido» do cartão
do trabalhador passou a ler-se pela COR: o rótulo "Escolhido" ganhou um SELO
em âmbar escuro (o valor do `RotuloAlerta`) com texto branco. A borda âmbar de
marca e o fundo menta ficaram como estavam.

⚠️ **O briefing anterior dizia que "subir a cor esbarra na `035`"; o obstáculo
era aritmética.** A borda fica entre o verde que substitui (0,145) e o fundo
claro (0,933), a 5,05:1, e um tom só passa 3:1 contra dois vizinhos a 9:1 — o
âmbar já estava no ótimo, 2,25. ⚠️ **E a troca que o jogador vê é PARADO →
escolhido**, porque só se aloca com barco à espera: ali a borda mudava 1,33:1,
não os 2,26 da `045`. O cartão inteiro escuro engolia o retrato (luminância
0,149, a mesma do âmbar escuro), por isso a massa foi para o rótulo.

---

## ⚠️ LEIA ISTO ANTES DE ESCREVER EM QUALQUER DOCUMENTO

O `ESTADO_DO_PROJETO.md` tem **~430 bytes de folga** (teto no `TETO_ESTADO` de
`tools/conferir_docs.py`). **Comprima ANTES de escrever** — a ordem da skill
`/fechar-sessao` §6: descer histórico para `docs/arquivo/HISTORICO.md` primeiro
—, e rode o conferidor antes de escrever o commit.

---

## 1. Comece pelo estado real

- ⚠️ **A sessão fechou na branch `claude/clever-hamilton-uq739u`, à frente da
  `main` (`ceb5006`, o PR #70 fundido), SEM PR aberto** — o PR só se abre a
  pedido. Antes de qualquer checkout, confira no GitHub se ela já foi fundida;
  se não foi, este trabalho só existe na branch, e reiniciá-la da `main`
  apaga-o.
- **Um ref de cada vez no `git fetch`**, código de saída lido **sem cano**,
  HEAD confirmado com o GitHub, e `git log --oneline origin/main..HEAD` antes de
  reapontar seja o que for.
- **O CI não correu sobre este trabalho** — só corre na `main` e em
  `pull_request`. Quando o PR abrir, o `brport-captura` vai dizer que **1 foto
  mudou**: a `escolhido.png`, que passou ao turno 2 (doca com barco à espera)
  e mostra o selo. As outras 26 saíram idênticas pixel a pixel, e o controle
  positivo mexe 12 — o zero vale.
- **São DEZ verdes neste contêiner**: as seis suítes e quatro conferidores
  (`DOCS OK`, `GUARDAS OK`, `ESCOPO UI OK`, `SINAL OK`). A bateria continua com
  **27 tiros** e fecha com `COBERTURA OK`. O D33 percorre **25 estados e 353
  textos**, zero reprovações.

---

## 2. O que sobra, e nenhum deles tem ordem

### (a) Os gates humanos, que só o Bruno passa

| Gate | O que falta |
|---|---|
| **A6 — ouvir** | `docs/PROTOCOLO_DE_ESCUTA.md`, começando pela §4: o `sfx_ui_warn` tem 99% da energia abaixo de 500 Hz; o conserto é subir uma harmónica, **nunca o volume** |
| **A5 — olhar** | as **27** fotos — e a `escolhido.png` é NOVA: o selo, no estado útil. `camioes.png`, `props3.png` e `escolhido.png` antiga foram enviadas em 23/09 sem registo de olhar |
| **A4 — ler em voz alta** | as falas reescritas em 23/09 (`048`): entrada, resposta e despedida do Sr. Ribeiro, os seis tons do boletim, a derrota para o Arlindo e a vitória dele |

### (c) Os nove órfãos que FICARAM

Presos à `001`; reabra só se a `001` for reaberta.

### (d) O retorno a entrar nos berços — desenho de cruzamento

Os camiões que sobem são só de passagem (`047`). Entrar obrigaria a virar à
esquerda por cima da faixa da ida: pede regra de cedência, trava de berço
ocupado (hoje o camião `i` serve a doca `i`) e guardas novas. Uma sessão
inteira, e o pedido original avisava contra trânsito e bugs.

### (e) A resposta do Sr. Ribeiro não tem foto

O tiro `ribeiro` fotografa a ENTRADA; a resposta (pagou / não pagou) e a
despedida só foram fotografadas à mão. O T13 guarda o texto; nada guarda que ele
caiba no cartão. Pequeno: um tiro a mais, e pede que a cobertura por painel
distinga TEMPOS do mesmo painel, que hoje não distingue.

### (f) O que o atlas deixou de fora

Os 8 de `art/brp` (são a opção c), os retratos inteiros (cortá-los reabre a
`049`) e a VRAM medida só no monitor do motor, aqui — nenhum telefone.

---

## 3. Armadilhas que 23/09 (quarta sessão) mediu

- ⚠️ **Um tom entre dois vizinhos só passa 3:1 contra os dois se eles
  estiverem a 9:1**; abaixo disso o teto é a raiz da razão. Faça a conta antes
  de varrer cores.
- ⚠️ **«Que estado a troca substitui?» tem duas respostas**: a do recurso (o
  fundo que a variação veste) e a da mecânica (o que o jogador vê antes de
  tocar). A `045` respondeu a primeira; a troca pedia a segunda.
- ⚠️ **Fundo escolhe-se também contra a ARTE que mora nele.** O D33 mede texto;
  o retrato, com a luminância do âmbar escuro, sumia num cartão inteiro dessa
  cor, e nenhuma guarda o veria.
- ⚠️ **Quem prova que um nó larga um estado prova-o no mesmo nó.** O
  `_refresh_workers()` RECRIA os cartões na alocação; a guarda do reset do selo
  que olhava o alocado passou com o reset apagado.
- ⚠️ **A régua do contraste não lia o fundo de um `Label`** — só de `Button`,
  `LineEdit` e painéis. Hoje lê o `StyleBoxFlat`; o `Empty` fica de fora.

---

## 4. Restrições

- Nada de `# TUNING:`, política de perfis, sementes do jogo, projeção,
  enquadramento, viewport ou `SAVE_VERSION`.
- Não mexa em gerador cuja saída o CI compara byte a byte.
- **Não reabra o R1–R9, as CINCO levas de cor, a triagem dos órfãos, a largura
  da rua (`047`), o corte do quadro (`049`) nem o selo da seleção (`050`).**
- Código, comentários, nomes e documentos em pt-BR; commits e PR em inglês.

---

## 5. O que entregar ao encerrar

Branch e commit; arquivos alterados; o antes e o depois medidos; os comandos e
os marcadores; **quais mutantes reprovaram e por quê**; o que ficou pendente do
Bruno; o que ficou de fora e por quê. **O briefing seguinte entra no mesmo
commit de fecho**, com a linha no índice de `docs/arquivo/README.md`.

⚠️ **O CI NÃO RODA AO EMPURRAR A BRANCH** — só na `main` e em `pull_request`.
O PR só se abre a pedido.
