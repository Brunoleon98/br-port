# BR Port — prompt para a próxima conversa (as cores acabaram)

**Como usar:** abra uma conversa nova no repositório `Brunoleon98/br-port` e
cole este texto. Não é preciso anexar o histórico da conversa anterior.

**Modelo:** depende do que o Bruno escolher na §2. Desde que a §7.1 acabou,
cada conversa começa por uma escolha dele.

**Situação:** a **quinta e última leva das cores declaradas** fechou em 22/09
(`docs/decisoes/045`) — a borda âmbar do trabalhador selecionado foi para o
tema. **`tools/excecoes_cor_ui.json` está VAZIO: 27 chamadas em 19 locais →
ZERO.** Nada no jogo mudou de cor.

⚠️ **ELA PRECISOU DE RÉGUA NOVA, e é por isso que foi deixada para o fim.** As
quatro anteriores provaram-se pelo D33 e pelas 24 fotos, e **nenhum dos dois
alcança uma borda**: borda não é texto, e nenhum dos 24 tiros selecionava um
trabalhador. A leva entregou duas peças — o **D34**, que pergunta de ONDE vem
o stylebox (identidade do recurso, não a cor), e o **25º tiro** da bateria.

⚠️ **SEM O TIRO NOVO O CONTROLE POSITIVO MEXERIA ZERO.** Com ele mexe 1 de 25.
É a `042` outra vez: a identidade byte a byte só quer dizer alguma coisa
depois de se saber que a régua veria a diferença.

⚠️ **E UMA BORDA TEM DUAS ADJACÊNCIAS.** A primeira leitura da sessão publicou
**2,24:1** (o lado de dentro) como se fosse «a» medida e quase concluiu que a
seleção não se via. Pelo pixel da captura, o lado de FORA dá **7,37:1** contra
a barra escura, e passa o corte de 3,0 da WCAG 1.4.11 com folga. O que fica
abaixo é outra pergunta — distinguir os ESTADOS pela cor, 2,26:1 entre o âmbar
e o verde de repouso —, e quem a responde é a LARGURA (2px → 4px).

⚠️ **O ÂMBAR EM SI É DECISÃO DO BRUNO (F4), e não se tomou.** A migração
preservou o valor.

---

## 1. Comece pelo estado real

- Confira repositório, branch, `git status`, HEAD e o local contra o remoto
  **antes** de sincronizar. **Um ref de cada vez no `git fetch`**, código de
  saída lido **sem cano**, e confirme o HEAD com o GitHub.
- Leia `CLAUDE.md` (carrega sozinho) e `docs/ESTADO_DO_PROJETO.md`.
- ⚠️ **O `ESTADO_DO_PROJETO.md` está com ~250 bytes de folga** — e o teto NÃO
  se copia daqui: ele vive no `TETO_ESTADO` de `tools/conferir_docs.py`, que é
  quem o CI lê. **Quem escrever ali a seguir comprime ANTES, não depois**, e
  confere rodando o conferidor.
- **São DEZ verdes neste contêiner**: as seis suítes do Godot (`TODOS OS
  TESTES PASSARAM`, `DESIGN OK`, `AUDIO OK`, `FUMACA OK`, `REGISTRO OK`,
  `ASSET OK`) e quatro conferidores em Python (`DOCS OK`, `GUARDAS OK`,
  `ESCOPO UI OK`, `SINAL OK`). A bateria de captura é a décima primeira — hoje
  **25 tiros, ~70 s** — e o `conferir_cobertura_paineis.py` corre contra a
  pasta dela (`COBERTURA OK`).

---

## 2. O que sobra, e nenhum deles tem ordem

### (a) Os gates humanos, que nenhuma sessão passa

| Gate | O que falta | O que já está pronto |
|---|---|---|
| **A6 — ouvir** | tudo | `docs/PROTOCOLO_DE_ESCUTA.md`. ⚠️ **Comece pela §4**: o aviso (`sfx_ui_warn`) tem 99% da energia abaixo de 500 Hz, e o conserto — se for preciso — é subir uma harmónica no gerador, **nunca o volume** |
| **A5 — olhar** | o olho dele | as **25** fotos da bateria. ⚠️ **A `escolhido.png` é NOVA e nunca foi olhada** — é o cartão do trabalhador selecionado, um estado que não tinha foto nenhuma. O âmbar da faixa (`042`) continua fora de todas |
| **A4 — três decisões de PALAVRA** | uma linha cada | `"Caixa:"` (`DebtPaymentPanel.gd:68`), o `"dinheiro no caixa"` da fala da semana nova (`Narrativa.gd:159`), e o `"0 dias daqui"` do painel da parcela (`PainelParcela.gd:46`) |

### (b) As duas coisas medidas, cada uma sessão própria, ambas F1/Opus

- **A rua parada em 1,8.** Alargá-la empurra o `RUA_RECUO` e o enquadramento
  (`012`). Medido: 1,9 cabe com 0,09 de folga, 2,0 falha por 7 milésimos. O
  ganho é de LEITURA, não de jogo.
- **O quadro dos props, 89,6% moldura vazia.** Cortá-lo derruba ~10x a VRAM e
  mexe em *"o centro do quadro é a origem do mundo"* (`029`). Precisa de `bpy`
  (~1 GB) e regera 61 props.

### (c) O âmbar da seleção — F4, uma decisão de cor

A troca de estado mede **2,26:1** pela cor, e quem a carrega é a largura.
Passa a 3:1 escurecendo o âmbar ou trocando o matiz — e aí vale a regra da
`035`: **nenhum tom ganha dois fundos**, e este vive sobre a barra escura E
sobre o cartão claro. Medir antes de escolher.

### (d) Os 11 órfãos de arte

`art/brp/` inteira (8), `pier_construido.svg` e `pier_vazio.svg` na raiz, e
`doca_concreto.png`. ⚠️ **São 687 KB** (686.789 bytes, medidos) — o briefing
anterior dizia 696 KB. É relatório e não portão de propósito
(`tools/arte_orfa.py`): **o destino de cada um é decisão do Bruno.**
(`art/sprites/` é item à parte — referido só por `scenes/proto/`, que o export
exclui.)

---

## 3. Armadilhas que 22/09 mediu e que mordem a seguir

- ⚠️ **ASSERÇÃO RELACIONAL PEDE O ESTADO CERTO DO OUTRO LADO.** «Relacional»
  não é, sozinho, o contrário de «espelho». O D34 comparava a seleção com o
  repouso OBSERVADO (que no HUD é o `TrabParado`, laranja) em vez do estado
  que ela substitui (o `TrabLivre`, verde), e o mutante que matava o canal da
  cor **passou**.
- ⚠️ **NEM TODA GUARDA NOVA É SUSTENTADORA, e o comentário ao lado dela
  mede-se.** O mutante com a guarda da derivação retirada reprovou na mesma
  por outras três — o comentário que dizia «sem esta linha as outras passariam
  contentes» era falso e foi corrigido.
- ⚠️ **O PORTÃO DO ESCOPO DENUNCIA EXCEÇÃO MORTA** — *"registro que envelhece
  mente igual"*. Foi ele que confirmou que a chamada tinha mesmo saído.
- ⚠️ **AS DUAS RÉGUAS CONTINUAM A NÃO SE COBRIR.** No mutante que tira a
  variação do tema, **só o D34** segura: o nome vai por
  `get_theme_stylebox(prop, TIPO)`, que a regex do escopo nem procura. É o
  inverso do X2 da `043`.
- ⚠️ **AFIRMAÇÃO DE BRIEFING CONFERE-SE.** O de 23/09 previu bem o mecanismo
  desta leva (uma variação basta) — e isso confirmou-se **por derivação**, não
  por leitura: alocar pela porta do jogador põe o `_selecionado` em −1.
- ⚠️ **Guarda que passa de primeira é para desconfiar**, e o defeito injetado
  nunca desce de modelo.

---

## 4. Restrições

- Nada de `# TUNING:`, política de perfis, sementes do jogo, projeção,
  enquadramento, viewport ou `SAVE_VERSION` — salvo se a (b) for a escolhida.
- Não mexa em gerador cuja saída o CI compara byte a byte.
- **Não reabra o R1–R9 nem as CINCO levas de cor, que acabaram.**
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
