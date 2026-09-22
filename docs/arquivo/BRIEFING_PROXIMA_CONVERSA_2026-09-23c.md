# BR Port — prompt para a próxima conversa (as cores acabaram, os órfãos triados)

**Como usar:** abra uma conversa nova no repositório `Brunoleon98/br-port` e
cole este texto. Não é preciso anexar o histórico da conversa anterior.

**Modelo:** depende do que o Bruno escolher na §2. Desde que a §7.1 acabou,
cada conversa começa por uma escolha dele.

**Situação:** em 22/09 fecharam duas coisas. A **quinta e última leva de cor**
(`045`) — a borda do trabalhador foi para o tema, e
`tools/excecoes_cor_ui.json` está **VAZIO**: 27 chamadas em 19 locais → ZERO.
E a **triagem dos órfãos de arte** (`046`) — saíram os 2 SVG de píer, ficaram
os 9 que têm propósito escrito. O relatório diz **9 de 107**.

⚠️ **NADA NO JOGO MUDOU DE PIXEL nas duas.** A leva preservou os valores; a
triagem tirou arte que nenhuma cena referia.

---

## ⚠️ LEIA ISTO ANTES DE ESCREVER EM QUALQUER DOCUMENTO

**O `ESTADO_DO_PROJETO.md` está com ~150 bytes de folga.** É o mais apertado
que já esteve. O teto NÃO se copia daqui — vive no `TETO_ESTADO` de
`tools/conferir_docs.py`, que é quem o CI lê. **Comprima ANTES de escrever, e
confira rodando o conferidor**, senão o fecho reprova depois de o commit estar
escrito, que é o momento em que menos apetece parar.

---

## 1. Comece pelo estado real

- Confira repositório, branch, `git status`, HEAD e o local contra o remoto
  **antes** de sincronizar. **Um ref de cada vez no `git fetch`**, código de
  saída lido **sem cano**, e confirme o HEAD com o GitHub.
- Leia `CLAUDE.md` (carrega sozinho) e `docs/ESTADO_DO_PROJETO.md`.
- **São DEZ verdes neste contêiner**: as seis suítes do Godot (`TODOS OS
  TESTES PASSARAM`, `DESIGN OK`, `AUDIO OK`, `FUMACA OK`, `REGISTRO OK`,
  `ASSET OK`) e quatro conferidores em Python (`DOCS OK`, `GUARDAS OK`,
  `ESCOPO UI OK`, `SINAL OK`). A bateria de captura é a décima primeira —
  **25 tiros, ~70 s** — e o `conferir_cobertura_paineis.py` corre contra a
  pasta dela (`COBERTURA OK`).

---

## 2. O que sobra, e nenhum deles tem ordem

### (a) Os gates humanos, que nenhuma sessão passa

| Gate | O que falta | O que já está pronto |
|---|---|---|
| **A6 — ouvir** | tudo | `docs/PROTOCOLO_DE_ESCUTA.md`. ⚠️ **Comece pela §4**: o aviso (`sfx_ui_warn`) tem 99% da energia abaixo de 500 Hz, e o conserto — se for preciso — é subir uma harmónica no gerador, **nunca o volume** |
| **A5 — olhar** | o olho dele | as **25** fotos. ⚠️ **A `escolhido.png` é NOVA e nunca foi olhada** — o cartão do trabalhador selecionado, um estado que não tinha foto nenhuma. O âmbar da faixa (`042`) continua fora de todas |
| **A4 — três decisões de PALAVRA** | uma linha cada | `"Caixa:"` (`DebtPaymentPanel.gd:68`), o `"dinheiro no caixa"` da fala da semana nova (`Narrativa.gd:159`), e o `"0 dias daqui"` do painel da parcela (`PainelParcela.gd:46`) |

### (b) As duas coisas medidas, cada uma sessão própria, ambas F1/Opus

- **A rua parada em 1,8.** Alargá-la empurra o `RUA_RECUO` e o enquadramento
  (`012`). Medido: 1,9 cabe com 0,09 de folga, 2,0 falha por 7 milésimos. O
  ganho é de LEITURA, não de jogo.
- **O quadro dos props, 89,6% moldura vazia.** Cortá-lo derruba ~10x a VRAM e
  mexe em *"o centro do quadro é a origem do mundo"* (`029`). Precisa de `bpy`
  (~1 GB) e regera 61 props.

### (c) O âmbar da seleção — F4, uma decisão de cor

A troca de estado mede **2,26:1** pela cor, e quem a carrega é a largura
(2px → 4px). A borda em si vê-se bem: **7,37:1** contra a barra escura por
fora. Passar a 3:1 na COR pede escurecer o âmbar ou trocar o matiz — e aí vale
a `035`: **nenhum tom ganha dois fundos**, e este vive sobre a barra escura E
sobre o cartão claro. Medir antes de escolher.

### (d) Os nove órfãos que FICARAM — e a decisão que os prende

Os oito de `art/brp/` e o `doca_concreto` servem a
`scenes/tests/AssetPlacementTest.tscn`, e o `art/brp/README.md` nomeia a
condição de regresso: **reabrir a `docs/decisoes/001`**. Valem **279 KB no
`.pck`** (4,43%), que é o tamanho todo do lote original.

⚠️ **Apagá-los é uma cadeia, não uma lista**: as 9 entradas do
`BRP_EXPORT_MANIFEST.json` (senão o `asset_validator` reprova com nove
problemas), a bancada que deixa de carregar, e o estúdio `cidade` do
`gerar_brp.py`, que os recria na próxima sessão de arte. É decisão de design,
e o Bruno já disse que ficam — reabra só se a `001` for reaberta.

---

## 3. Armadilhas que 22/09 mediu e que mordem a seguir

- ⚠️ **«ÓRFÃO» E «APAGÁVEL» SÃO DUAS PERGUNTAS.** O `arte_orfa.py` responde a
  primeira e exclui `scenes/tests/` de propósito; quem ler o relatório e
  contar apagáveis conta a mais. Hoje o cabeçalho dele já diz isto.
- ⚠️ **DISCO NÃO É PACOTE, e o export não faz tree-shaking.** Os onze mediam
  687 KB em disco e 282 KB no `.pck`. E embarcam mesmo sem serem referidos:
  `export_filter="all_resources"`, e o `exclude_filter` tira a CENA de teste,
  não a ARTE que ela usa. Meça exportando as duas maneiras.
- ⚠️ **ASSERÇÃO RELACIONAL PEDE O ESTADO CERTO DO OUTRO LADO.** «Relacional»
  não é, sozinho, o contrário de «espelho». O D34 comparava a seleção com o
  repouso OBSERVADO (`TrabParado`, laranja) em vez do que ela substitui
  (`TrabLivre`, verde), e o mutante do canal da cor **passou**.
- ⚠️ **NEM TODA GUARDA NOVA É SUSTENTADORA, e o comentário ao lado mede-se.**
  O mutante com a guarda da derivação retirada reprovou na mesma por outras
  três; o comentário que dizia o contrário era falso e foi corrigido.
- ⚠️ **AS DUAS RÉGUAS DE COR NÃO SE COBREM.** No mutante que tira a variação
  do tema, **só o D34** segura: o nome vai por `get_theme_stylebox(prop, TIPO)`,
  que a regex do escopo nem procura.
- ⚠️ **Guarda que passa de primeira é para desconfiar**, e o defeito injetado
  nunca desce de modelo.

---

## 4. Restrições

- Nada de `# TUNING:`, política de perfis, sementes do jogo, projeção,
  enquadramento, viewport ou `SAVE_VERSION` — salvo se a (b) for a escolhida.
- Não mexa em gerador cuja saída o CI compara byte a byte.
- **Não reabra o R1–R9, as CINCO levas de cor, nem a triagem dos órfãos.**
- Código, comentários, nomes e documentos em pt-BR; commits e PR em inglês.
- Achou algo de outro item? Registre com a evidência e siga.

---

## 5. O que entregar ao encerrar

Branch e commit; arquivos alterados; o antes e o depois medidos; os comandos e
os marcadores; **quais mutantes reprovaram e por quê**; o que ficou pendente do
Bruno; o que ficou de fora e por quê.

⚠️ **E O BRIEFING DA CONVERSA SEGUINTE ENTRA NO MESMO COMMIT DE FECHO**, em
`docs/arquivo/`, datado, com a linha dele no índice de `docs/arquivo/README.md`.

**E entrega-se ao Bruno em BLOCO COPIÁVEL na conversa, antes de ele fundir.**

⚠️ **E O CI NÃO RODA AO EMPURRAR A BRANCH.** `testes.yml` e `captura.yml`
disparam em `push` só na `main` e em `pull_request`. Até o PR abrir, "verde"
quer dizer apenas "verde neste contêiner". O PR só se abre a pedido.
