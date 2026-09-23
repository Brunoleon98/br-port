# BR Port — prompt para a próxima conversa (um painel não é uma tela)

**Como usar:** abra uma conversa nova no repositório `Brunoleon98/br-port` e
cole este texto. Não é preciso anexar o histórico da conversa anterior.

**Modelo:** depende do que o Bruno escolher na §2. Cada conversa começa por uma
escolha dele.

**Situação:** em 23/09, numa quinta sessão, fechou a opção (e) do briefing
`23g` — **a resposta do Sr. Ribeiro ganhou foto** (`051`), e com ela a cobertura
das capturas passou a perguntar pelo TEMPO de cada painel, e não pela cena.
Três painéis têm mais de uma tela (Sr. Ribeiro, Arlindo, fim de fase): sete
tempos, seis com foto e o balanço DECLARADO como lacuna. A bateria tem **30
tiros**.

⚠️ **As fotos novas acharam dois defeitos que viviam desde 13/09:** a despedida
do Arlindo dizia «Cliente ouvindo a proposta. (2 tentativas)» com o negócio já
fechado, e um nome de 24 letras sem espaço (o máximo da tela de nomes)
saía do balão e passava por fora do cartão. Os dois estão consertados, e o F10
do `teste_fumaca` tranca o segundo com `get_character_bounds()`.

---

## ⚠️ LEIA ISTO ANTES DE ESCREVER EM QUALQUER DOCUMENTO

O `ESTADO_DO_PROJETO.md` tem **~740 bytes de folga** (teto no `TETO_ESTADO` de
`tools/conferir_docs.py`). **Comprima ANTES de escrever** — a ordem da skill
`/fechar-sessao` §6 —, e rode o conferidor antes de escrever o commit.

---

## 1. Comece pelo estado real

- ⚠️ **A sessão fechou na branch `claude/amazing-carson-4ob084`, à frente da
  `main` (`762c8f0`, o PR #71 fundido), com o PR #72 ABERTO** e o CI a correr
  quando a conversa acabou. Antes de qualquer checkout, confira no GitHub se o
  #72 foi fundido e se o CI dele ficou verde; se não foi, este trabalho só
  existe na branch, e reiniciá-la da `main` apaga-o.
- **Um ref de cada vez no `git fetch`**, código de saída lido **sem cano**,
  HEAD confirmado com o GitHub, e `git log --oneline origin/main..HEAD` antes de
  reapontar seja o que for.
- **O CI do #72 é a primeira verificação fora deste contêiner.** O
  `brport-captura` deve dizer que **1 foto mudou** (a
  `ribeiro.png`, 165 px: a linha do dinheiro, R$400.000 → R$336.000, porque o
  Sr. Ribeiro agora é fotografado no vencimento) e que há **3 novas**
  (`ribeiro_pagou`, `ribeiro_nao_pagou`, `contraoferta_fim`). As outras 26
  saíram idênticas pixel a pixel às da `main` neste contêiner.
- **São DEZ verdes neste contêiner**: as seis suítes e quatro conferidores
  (`DOCS OK`, `GUARDAS OK`, `ESCOPO UI OK`, `SINAL OK`). A bateria fecha com
  `COBERTURA OK` e imprime a lacuna declarada.

---

## 2. O que sobra, e nenhum deles tem ordem

### (a) Os gates humanos, que só o Bruno passa

| Gate | O que falta |
|---|---|
| **A6 — ouvir** | `docs/PROTOCOLO_DE_ESCUTA.md`, começando pela §4: o `sfx_ui_warn` tem 99% da energia abaixo de 500 Hz; o conserto é subir uma harmónica, **nunca o volume** |
| **A5 — olhar** | as **30** fotos — quatro são novas ou mudaram em 23/09: `ribeiro.png`, `ribeiro_pagou.png`, `ribeiro_nao_pagou.png`, `contraoferta_fim.png`; e a `escolhido.png` do selo (`050`) |
| **A4 — ler em voz alta** | as falas reescritas em 23/09 (`048`) |

### (c) Os nove órfãos que FICARAM

Presos à `001`; reabra só se a `001` for reaberta.

### (d) O retorno a entrar nos berços — desenho de cruzamento

Pede regra de cedência, trava de berço ocupado e guardas novas (`047`). Uma
sessão inteira.

### (f) O que o atlas deixou de fora

Os retratos inteiros (cortá-los reabre a `049`) e a VRAM medida só aqui — nenhum
telefone.

### (g) O balanço do fim de fase, a lacuna declarada

Fica sem foto pela regra do zero: numa cena solta as métricas são de partida
nova. Fotografá-lo pede um tiro de `capturar_tela.gd` que JOGUE até ao turno
32, pague a parcela pelo botão e carregue em «Ver o balanço» — e a entrada em
`TEMPOS_SEM_FOTO` sai no mesmo commit, senão o conferidor reprova. De bónus, o
Sr. Ribeiro passaria a ter foto numa partida jogada, com dinheiro de verdade.

### (h) O nome longo fora dos três painéis

O F10 mediu o nome de 24 letras só no Sr. Ribeiro, no Arlindo e no fim de fase.
O `fala()` conserta todos os balões do `PainelNarrativo`; parágrafos, o HUD e o
diário ficaram por medir. Pequeno, com a mesma régua.

---

## 3. Armadilhas que 23/09 (quinta sessão) mediu

- ⚠️ **Um painel não é uma tela.** Cobertura por cena deixa passar o segundo
  tempo inteiro, e foi lá que a linha falsa viveu dez dias.
- ⚠️ **A porta do jogador também tem fase.** `pay_debt()` sai calado fora de
  `debt_payment`; tocar no botão certo na fase errada fotografa um estado que
  não existe a jogar.
- ⚠️ **O `size` do rótulo não é o que ele desenha.** A medida é
  `get_character_bounds()`; pela caixa, o transbordo fica VERDE (mutante M7).
- ⚠️ **Com lacuna declarada, a guarda do catálogo vazio não é a que segura** —
  a conferência da lacuna queixa-se primeiro. Mede-se com a lista vazia.
- ⚠️ **Mutador que casa a mesma linha três vezes não pode escolher.** Dois
  mutantes do F10 não aplicaram à primeira; o script recusou em vez de mudar a
  cópia errada, e com âncora única pegaram.

---

## 4. Restrições

- Nada de `# TUNING:`, política de perfis, sementes do jogo, projeção,
  enquadramento, viewport ou `SAVE_VERSION`.
- Não mexa em gerador cuja saída o CI compara byte a byte.
- **Não reabra o R1–R9, as CINCO levas de cor, a triagem dos órfãos, a largura
  da rua (`047`), o corte do quadro (`049`), o selo da seleção (`050`) nem a
  cobertura por tempo (`051`).**
- Código, comentários, nomes e documentos em pt-BR; commits e PR em inglês.

---

## 5. O que entregar ao encerrar

Branch e commit; arquivos alterados; o antes e o depois medidos; os comandos e
os marcadores; **quais mutantes reprovaram e por quê**; o que ficou pendente do
Bruno; o que ficou de fora e por quê. **O briefing seguinte entra no mesmo
commit de fecho**, com a linha no índice de `docs/arquivo/README.md`.

⚠️ **O CI NÃO RODA AO EMPURRAR A BRANCH** — só na `main` e em `pull_request`.
O PR só se abre a pedido.
