# BR Port — prompt para a próxima conversa (a mão direita e o cruzamento)

**Como usar:** abra uma conversa nova no repositório `Brunoleon98/br-port` e
cole este texto. Não é preciso anexar o histórico da conversa anterior.

**Modelo:** depende do que o Bruno escolher na §2. Cada conversa começa por uma
escolha dele.

**Situação:** em 23/09, numa sexta sessão, fechou a opção (d) do briefing
`23h` — **o retorno encosta nos berços**, e a pergunta levou a outra: os
camiões andavam pela ESQUERDA na tela (a projeção espelha o chão) e as duas
rotas cruzavam-se em dez pontos, com 27 a 72 sobreposições à vista por meia
hora. A pedido do Bruno a mão é a **direita** (`052`), com quatro regras de
cruzamento e ninguém parado na rua. Zero sobreposições medidas; o **D35** do
teste de design tranca-o: dezassete mutantes, e o único que passa (o retorno
a entrar sem ceder, 0,028 durante um instante) está escrito na `052`.

---

## ⚠️ LEIA ISTO ANTES DE ESCREVER EM QUALQUER DOCUMENTO

O `ESTADO_DO_PROJETO.md` tem **~800 bytes de folga** (teto no `TETO_ESTADO` de
`tools/conferir_docs.py`). **Comprima ANTES de escrever** — a ordem da skill
`/fechar-sessao` §6 —, e rode o conferidor antes de escrever o commit.

---

## 1. Comece pelo estado real

- ⚠️ **A sessão fechou na branch `claude/elegant-lovelace-vwwpy7`, à frente da
  `main` (`d13f6fb`, o PR #72 fundido), SEM PR aberto** — o PR só se abre a
  pedido. Antes de qualquer checkout, confira no GitHub se um PR desta branch
  foi aberto e fundido; se não foi, este trabalho só existe na branch, e
  reiniciá-la da `main` apaga-o.
- **Um ref de cada vez no `git fetch`**, código de saída lido **sem cano**,
  HEAD confirmado com o GitHub, e `git log --oneline origin/main..HEAD` antes de
  reapontar seja o que for.
- **O CI deste trabalho ainda não correu** — só corre em `pull_request` e na
  `main`. Quando correr, o `brport-captura` deve dizer que **14 fotos mudaram**
  (todas as de jogo com o mapa à vista: os camiões trocaram de faixa) e **16
  não** (as folhas de contato e os painéis sem mapa), medido aqui contra uma
  bateria da `main` num worktree.
- **São DEZ verdes neste contêiner**: as seis suítes e quatro conferidores
  (`DOCS OK`, `GUARDAS OK`, `ESCOPO UI OK`, `SINAL OK`). A bateria fecha com
  `COBERTURA OK`. O `teste_design` passou de 3 s a 9 s (o D35).

---

## 2. O que sobra, e nenhum deles tem ordem

### (a) Os gates humanos, que só o Bruno passa

| Gate | O que falta |
|---|---|
| **A6 — ouvir** | `docs/PROTOCOLO_DE_ESCUTA.md`, começando pela §4: o `sfx_ui_warn` tem 99% da energia abaixo de 500 Hz; o conserto é subir uma harmónica, **nunca o volume** |
| **A5 — olhar** | as **30** fotos; e agora **o trânsito a andar** — a régua é um retângulo por camião, e diz se as pegadas se tocam, não o que o olho lê numa curva. A foto `docas` tem os dois sentidos a cruzarem-se no cotovelo 1 |
| **A4 — ler em voz alta** | as falas reescritas em 23/09 (`048`) |

### (c) Os nove órfãos que FICARAM

Presos à `001`; reabra só se a `001` for reaberta.

### (f) O que o atlas deixou de fora

Os retratos inteiros (cortá-los reabre a `049`) e a VRAM medida só aqui — nenhum
telefone.

### (g) O balanço do fim de fase, a lacuna declarada

Fica sem foto pela regra do zero: numa cena solta as métricas são de partida
nova. Fotografá-lo pede um tiro de `capturar_tela.gd` que JOGUE até ao turno
32, pague a parcela pelo botão e carregue em «Ver o balanço» — e a entrada em
`TEMPOS_SEM_FOTO` sai no mesmo commit, senão o conferidor reprova.

### (h) O nome longo fora dos três painéis

O F10 mediu o nome de 24 letras só no Sr. Ribeiro, no Arlindo e no fim de fase.
Parágrafos, o HUD e o diário ficaram por medir. Pequeno, com a mesma régua.

### (i) O chanfro dos cotovelos, se o Bruno o quiser revisitar

A curva aberta corta a quina saliente por uma diagonal porque o vértice dela
cai em cima da linha do chanfro (`052`). A carroçaria ainda invade 0,21 do
passeio ali (como qualquer curva, 0,25, desde 07/09). O remédio de verdade é o
chanfro do gerador acompanhar a faixa — e isso MUDA o mapa, que o CI compara
byte a byte. Só com decisão dele.

---

## 3. Armadilhas que 23/09 (sexta sessão) mediu

- ⚠️ **A projeção espelha o chão.** Mão, "à direita de" e sentido de volta
  escrevem-se como CONTA contra a tela — é o D13 §7g —, nunca pela intuição do
  `x`/`y` do caderno.
- ⚠️ **Decisão que pergunta num passo e age no seguinte tem uma corrida.** Dois
  arranques no mesmo passo saíam juntos; quem o expôs foi um mutante de OUTRA
  regra.
- ⚠️ **A suíte nunca deixa passar um frame, logo os tweens nunca saem da
  lista** (983 no D35): `Dictionary`, nunca `Array.has()`.
- ⚠️ **Fixture que escreve o estado prova a leitura, não a escrita** (o M11).
- ⚠️ **O `getbbox()` do Pillow num RGBA só olha o alfa** — "zero fotos
  mudaram" com os camiões todos noutra faixa.
- ⚠️ **Sub-bloco leva bandeira própria**: um erro lá dentro deixou o D35 verde.

---

## 4. Restrições

- Nada de `# TUNING:`, política de perfis, sementes do jogo, projeção,
  enquadramento, viewport ou `SAVE_VERSION`.
- Não mexa em gerador cuja saída o CI compara byte a byte.
- **Não reabra o R1–R9, as CINCO levas de cor, a triagem dos órfãos, a largura
  da rua (`047`), o corte do quadro (`049`), o selo da seleção (`050`), a
  cobertura por tempo (`051`) nem a mão direita e as quatro regras do
  cruzamento (`052`).**
- Código, comentários, nomes e documentos em pt-BR; commits e PR em inglês.

---

## 5. O que entregar ao encerrar

Branch e commit; arquivos alterados; o antes e o depois medidos; os comandos e
os marcadores; **quais mutantes reprovaram e por quê**; o que ficou pendente do
Bruno; o que ficou de fora e por quê. **O briefing seguinte entra no mesmo
commit de fecho**, com a linha no índice de `docs/arquivo/README.md`.

⚠️ **O CI NÃO RODA AO EMPURRAR A BRANCH** — só na `main` e em `pull_request`.
O PR só se abre a pedido.
