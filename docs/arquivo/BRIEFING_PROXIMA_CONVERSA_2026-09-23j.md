# BR Port — prompt para a próxima conversa (depois do balanço, do nome e do chanfro)

**Como usar:** abra uma conversa nova no repositório `Brunoleon98/br-port` e
cole este texto. Não é preciso anexar o histórico da conversa anterior.

**Modelo:** depende do que o Bruno escolher na §2. Cada conversa começa por uma
escolha dele.

**Situação:** em 23/09, numa sétima sessão, o Bruno escolheu as três opções do
briefing `23i` que uma sessão fazia sozinha, e as três fecharam, cada uma no seu
commit. **(g)** o balanço do fim de fase tem foto de uma partida jogada e paga
pelo botão, e a lacuna declarada saiu; **(h)** o F10 mede o diário com o nome de
24 letras e reprova frase com nome que ninguém mediu; **(i)** o chanfro dos
cotovelos passou de 0,9 a 0,60, derivado da curva e do maior camião (`053`) —
a carroçaria saía 0,207 do asfalto, hoje fica 0,005 dentro.

---

## ⚠️ LEIA ISTO ANTES DE ESCREVER EM QUALQUER DOCUMENTO

O `ESTADO_DO_PROJETO.md` tem **~800 bytes de folga** (teto no `TETO_ESTADO` de
`tools/conferir_docs.py`). **Comprima ANTES de escrever** — a ordem da skill
`/fechar-sessao` §6 —, e rode o conferidor antes de escrever o commit.

---

## 1. Comece pelo estado real

- ⚠️ **A sessão fechou na branch `claude/peaceful-goodall-xohqiz`, à frente da
  `main` (`8fda31e`, o PR #73 fundido), com o PR #74 aberto.** Antes de
  qualquer checkout, confira no GitHub se o #74 foi fundido; se não foi, este
  trabalho só existe na branch, e reiniciá-la da `main` apaga-o.
- **Um ref de cada vez no `git fetch`**, código de saída lido **sem cano**,
  HEAD confirmado com o GitHub, e `git log --oneline origin/main..HEAD` antes de
  reapontar seja o que for.
- **O CI do #74 arrancou no fecho e não tinha resultado** — confira-o primeiro,
  e em especial o passo que regera os mapas e os compara byte a byte: o chanfro
  mudou os dois mapas de rua, e o runner corre outro Python. Medido aqui contra
  uma bateria da `main` num worktree, o `brport-captura` deve dizer **14 fotos
  mudadas** (as de jogo com o mapa à vista: as dez quinas, 1,3 a 2,4 mil pixels
  cada), **16 iguais** e **uma nova**, `balanco.png`.
- **São DEZ verdes neste contêiner**: as seis suítes e quatro conferidores
  (`DOCS OK`, `GUARDAS OK`, `ESCOPO UI OK`, `SINAL OK`). A bateria fecha com
  `COBERTURA OK`, e já não tem lacuna declarada.

---

## 2. O que sobra, e nenhum deles tem ordem

### (a) Os gates humanos, que só o Bruno passa

| Gate | O que falta |
|---|---|
| **A6 — ouvir** | `docs/PROTOCOLO_DE_ESCUTA.md`, começando pela §4: o `sfx_ui_warn` tem 99% da energia abaixo de 500 Hz; o conserto é subir uma harmónica, **nunca o volume** |
| **A5 — olhar** | as **31** fotos, e agora também **as quinas novas** (o chanfro a 0,60 recua menos do que o de 0,9) e o trânsito a andar |
| **A4 — ler em voz alta** | as falas reescritas em 23/09 (`048`) |

### (b) A ordem dos painéis depois do «Pagar» — pergunta para o Bruno

A foto `balanco.png` é o estado verdadeiro, e mostra-o: o «Pagar» fecha a
semana 4 e acaba a partida **na mesma chamada** (`pay_debt()` →
`_fechar_resumo_da_semana()` → `_check_end()`), e o `Main` abre o boletim e o
fim de fase logo ali, **por cima da resposta do Sr. Ribeiro**. A jogar, a
resposta dele (reescrita na `048`) e o boletim da semana 4 só se veem depois
de fechar o balanço. O mesmo vale para «Não consigo pagar». A ordem natural
seria resposta → boletim → fim de fase, e isso é uma decisão de fluxo:
nenhuma sessão a tomou.

### (c) Os nove órfãos que FICARAM

Presos à `001`; reabra só se a `001` for reaberta.

### (f) O que o atlas deixou de fora

Os retratos inteiros (cortá-los reabre a `049`) e a VRAM medida só aqui — nenhum
telefone.

---

## 3. Armadilhas que 23/09 (sétima sessão) mediu

- ⚠️ **O `get_script_constant_map()` não vê texto LOCAL** de uma função: a
  narração do fim de fase escapa-lhe. Catálogo de fala lê o arquivo.
- ⚠️ **A previsão de QUAL guarda reprova num estado futuro mede-se no dia em
  que ele chega.** O conferidor das capturas afirmava-o da linha do catálogo
  vazio, e com a lista vazia quem reprova é a outra metade, sete vezes.
- ⚠️ **A licença de fechar painéis de rotina acaba onde o jogador já não os
  alcança**: o tiro `balanco` não fecha o boletim que abriu debaixo do fim de
  fase, e a contagem de 3 painéis tranca-o.
- ⚠️ **O chanfro saía do mapa e a curva dele; hoje é ao contrário.** Quem mexer
  no `corte_da_curva()` do `Main.gd` regera os mapas — o D13 §7i reprova se não.

---

## 4. Restrições

- Nada de `# TUNING:`, política de perfis, sementes do jogo, projeção,
  enquadramento, viewport ou `SAVE_VERSION`.
- Não mexa em gerador cuja saída o CI compara byte a byte sem decisão do Bruno.
- **Não reabra o R1–R9, as CINCO levas de cor, a triagem dos órfãos, a largura
  da rua (`047`), o corte do quadro (`049`), o selo da seleção (`050`), a
  cobertura por tempo (`051`), a mão direita e as quatro regras do cruzamento
  (`052`) nem o chanfro derivado (`053`).**
- Código, comentários, nomes e documentos em pt-BR; commits e PR em inglês.

---

## 5. O que entregar ao encerrar

Branch e commit; arquivos alterados; o antes e o depois medidos; os comandos e
os marcadores; **quais mutantes reprovaram e por quê**; o que ficou pendente do
Bruno; o que ficou de fora e por quê. **O briefing seguinte entra no mesmo
commit de fecho**, com a linha no índice de `docs/arquivo/README.md`.

⚠️ **O CI NÃO RODA AO EMPURRAR A BRANCH** — só na `main` e em `pull_request`.
O PR só se abre a pedido.
