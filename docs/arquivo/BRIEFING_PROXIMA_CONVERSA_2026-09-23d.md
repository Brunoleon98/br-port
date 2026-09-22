# BR Port — prompt para a próxima conversa (a rua fechou, a mão dupla também)

**Como usar:** abra uma conversa nova no repositório `Brunoleon98/br-port` e
cole este texto. Não é preciso anexar o histórico da conversa anterior.

**Modelo:** depende do que o Bruno escolher na §2. Cada conversa começa por uma
escolha dele.

**Situação:** em 23/09 fechou a opção (b) do briefing anterior — **a rua fica em
1,8** (`047`) — e, a pedido do Bruno, **a mão dupla que faltava**: dois camiões
sobem a rua pela faixa de dentro, de costas, com oito silhuetas `_retorno`.

⚠️ **O briefing anterior errou o MECANISMO da rua.** Dizia que alargá-la
"empurra o `RUA_RECUO` e o enquadramento"; medido, a janela que aperta é em
`my` e o `RUA_RECUO` move a rua em `mx`. Dez minutos de varredura desfizeram a
estimativa — a mesma lição de 22/09. **Não herde mecanismo: meça.**

⚠️ **E A RÉGUA DA ASSINATURA ESTAVA ERRADA** (D13/D17): `Image.resize` não faz
a média que o comentário prometia. Hoje faz, e o corte desceu a 0,01.

---

## ⚠️ LEIA ISTO ANTES DE ESCREVER EM QUALQUER DOCUMENTO

O `ESTADO_DO_PROJETO.md` tem **~250 bytes de folga**. O teto vive no
`TETO_ESTADO` de `tools/conferir_docs.py`. **Comprima ANTES de escrever**, e
confira rodando o conferidor antes de escrever o commit.

---

## 1. Comece pelo estado real

- **Um ref de cada vez no `git fetch`**, código de saída lido **sem cano**,
  HEAD confirmado com o GitHub, e `git log --oneline origin/main..HEAD` antes de
  reapontar seja o que for.
- **São DEZ verdes neste contêiner**: as seis suítes (`TODOS OS TESTES
  PASSARAM`, `DESIGN OK`, `AUDIO OK`, `FUMACA OK`, `REGISTRO OK`, `ASSET OK`) e
  quatro conferidores (`DOCS OK`, `GUARDAS OK`, `ESCOPO UI OK`, `SINAL OK`). A
  bateria de captura tem agora **27 tiros** (~70 s) e fecha com `COBERTURA OK`.
- O `bpy` não vem no arranque; `pip install "bpy==4.5.0"` levou ~3 min aqui.

---

## 2. O que sobra, e nenhum deles tem ordem

### (a) Os gates humanos, que só o Bruno passa

| Gate | O que falta |
|---|---|
| **A6 — ouvir** | `docs/PROTOCOLO_DE_ESCUTA.md`, começando pela §4: o `sfx_ui_warn` tem 99% da energia abaixo de 500 Hz; o conserto é subir uma harmónica no gerador, **nunca o volume** |
| **A5 — olhar** | as **27** fotos. **Novas e nunca olhadas:** `camioes.png` (os 16 camiões, ida e retorno) e `props3.png`; e a `escolhido.png` de 22/09 continua por olhar |
| **A4 — três palavras** | `"Caixa:"` (`DebtPaymentPanel.gd:68`), `"dinheiro no caixa"` (`Narrativa.gd:159`), `"0 dias daqui"` (`PainelParcela.gd:46`) |

### (b) O quadro dos props — F1/Opus, sessão própria

89,6% de moldura vazia; cortá-lo derruba ~10x a VRAM e mexe em *"o centro do
quadro é a origem do mundo"* (`029`). Precisa de `bpy` e regera **69** props
agora (61 + os 8 do retorno).

### (c) O âmbar da seleção — F4

A troca de estado mede 2,26:1 pela cor, e quem a carrega é a largura (2 → 4 px).
Subir a cor esbarra na `035`: nenhum tom ganha dois fundos.

### (d) Os nove órfãos que FICARAM

Presos à `001`; o Bruno disse que ficam. Reabra só se a `001` for reaberta.

### (e) NOVO — o que a mão dupla deixou de fora, por escrito na `047`

- **Os camiões do retorno não entram nos berços.** Entrar obrigaria a virar à
  esquerda por cima da faixa da ida. Se o Bruno o quiser, é desenho de
  cruzamento, não de arte.
- **Nenhuma guarda anima a saída do berço de ré.** Tirar o `true` do
  `re_no_primeiro` põe o camião a virar 180° no fundo da baía, e passa.

---

## 3. Armadilhas que 23/09 mediu

- ⚠️ **Duas réguas com a mesma promessa conferem-se uma contra a outra.** O
  `comparar_props.py` fazia a média; a `_assinatura()` do teste de design não
  fazia, com o mesmo comentário.
- ⚠️ **A célula de uma folha de contato sai do que ela CARREGA** — desenho e
  nome. O rótulo `caminhao_armazenagem_retorno_mx` pedia 200 px numa célula
  de 159.
- ⚠️ **Guarda de sentido e guarda de faixa são duas perguntas.** Com a lista
  do retorno ao contrário, a faixa continua certa; só o sentido reprova.

---

## 4. Restrições

- Nada de `# TUNING:`, política de perfis, sementes do jogo, projeção,
  enquadramento, viewport ou `SAVE_VERSION` — salvo se a (b) for a escolhida.
- Não mexa em gerador cuja saída o CI compara byte a byte.
- **Não reabra o R1–R9, as CINCO levas de cor, a triagem dos órfãos, nem a
  largura da rua (`047`).**
- Código, comentários, nomes e documentos em pt-BR; commits e PR em inglês.

---

## 5. O que entregar ao encerrar

Branch e commit; arquivos alterados; o antes e o depois medidos; os comandos e
os marcadores; **quais mutantes reprovaram e por quê**; o que ficou pendente do
Bruno; o que ficou de fora e por quê. **O briefing seguinte entra no mesmo
commit de fecho**, com a linha no índice de `docs/arquivo/README.md`.

⚠️ **O CI NÃO RODA AO EMPURRAR A BRANCH** — só na `main` e em `pull_request`.
O PR só se abre a pedido.
