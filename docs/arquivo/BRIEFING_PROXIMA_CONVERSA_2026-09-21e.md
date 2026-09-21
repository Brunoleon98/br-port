# BR Port — prompt para a próxima conversa (a §7.1 acabou)

**Como usar:** abra uma conversa nova no repositório `Brunoleon98/br-port` e
cole este texto. Não é preciso anexar o histórico da conversa anterior.

**Modelo:** depende do que o Bruno escolher abaixo — a fila ordenada acabou, e
com ela o "próximo item" automático. Cada uma das opções da §2 diz o modelo com
que abre.

**Situação:** o **R9 fechou** em 21/09 (`docs/decisoes/040`), e com ele a
**§7.1 inteira: R1 a R9, todos feitos.** É a primeira vez desde 17/09 que não
há fila ordenada a dizer o que vem a seguir.

⚠️ **Confira o estado da branch antes de reapontar.** Se o PR já foi fundido, a
receita é `git checkout -B <nome> origin/main`, e **antes disso**
`git log --oneline origin/main..HEAD` para saber o que ficaria de fora.
⚠️ **E o `origin/main` do contêiner pode estar VELHO.** Em 21/09 ele apontava
para o PR #51 enquanto o GitHub já estava no #62 — 40 commits de diferença, e
um `checkout -B origin/main` teria apagado a entrega inteira. Confirme o HEAD
real com o GitHub antes de reapontar seja o que for.

---

## 1. Comece pelo estado real

- Confira repositório, branch, `git status`, HEAD e o local contra o remoto
  **antes** de sincronizar. Preserve trabalho não publicado.
- Leia `CLAUDE.md` (carrega sozinho) e `docs/ESTADO_DO_PROJETO.md`.
- ⚠️ **O `ESTADO_DO_PROJETO.md` está a 28.749 de 30.000** — ~1.250 de folga,
  que é confortável porque 21/09 comprimiu a tabela dos R fechados ao encerrar
  (os nove itens viraram quatro linhas, e o arquivo ENCOLHEU 243 bytes mesmo
  com o R9 a entrar). A regra continua: comprimir antes de precisar.
- Rode `python3 tools/conferir_docs.py`, `conferir_guardas_ci.py` e
  `conferir_escopo_ui.py` antes de se surpreender no CI.
- **São sete verdes neste contêiner agora**, e não seis: as seis suítes mais
  `python3 tools/medir_audio.py`, que espera `SINAL OK`.

---

## 2. O que sobra, e nenhum deles tem ordem

A fila acabou; estas são as opções, com o que cada uma custa. **A escolha é do
Bruno** — este documento não a faz.

### (a) Os gates humanos, que nenhuma sessão passa

| Gate | O que falta | O que já está pronto para ele |
|---|---|---|
| **A6 — ouvir** | tudo | ⚠️ **novo:** `docs/PROTOCOLO_DE_ESCUTA.md`. Telefone-alvo, volume fixo anotado, duas passagens (isolado e em contexto), três perguntas acionáveis. **Comece pela §4** |
| **A5 — olhar** | o olho dele | as 24 fotos da bateria, do Construir ao fim de Fase 1 |
| **A4 — três decisões de PALAVRA** | uma linha cada | o rótulo `"Caixa: R$…"` (`DebtPaymentPanel.gd:68`), o `"dinheiro no caixa"` da fala da semana nova, e o `"0 dias daqui"` do painel da parcela |

⚠️ **O A6 tem agora uma pergunta CONCRETA para abrir**, e ela saiu da medição:
**seis dos catorze sons têm a maior parte da energia abaixo de 500 Hz**, que é
onde o alto-falante de um telefone começa a perder. O aviso (`sfx_ui_warn`) são
duas notas de triângulo a **392 e 330 Hz** — 99% abaixo de 500. É o som que
diz ao jogador que a ação não deu. **Isto é descritor e não veredito**: ninguém
aqui mediu alto-falante nenhum, e o ouvido reconstrói fundamental a partir de
harmónica. Só o ouvido dele responde, e o conserto — se for preciso — é subir
uma harmónica no gerador, **nunca o volume**.

### (b) As duas coisas medidas, paradas, cada uma sessão própria

- **A rua parada em 1,8.** Alargá-la empurra o `RUA_RECUO` e o enquadramento
  (`docs/decisoes/012`). Abre em **F1/Opus**: mexe em contrato entre arquivos.
- **O quadro dos props, 89,6% moldura vazia.** Cortá-lo mexe em "o centro do
  quadro é a origem do mundo" (`029`). Também **F1/Opus**, pela mesma razão.

### (c) A migração das 27 cores declaradas

Em `tools/excecoes_cor_ui.json`, com classe e justificativa. ⚠️ **Por LEVA e
por FUNDO, nunca linha a linha:** nenhum tom ganha dois fundos, e o âmbar do
`_workers_title` (5,53:1 na barra escura) não é o `RotuloAlerta`, que é o mesmo
âmbar escurecido para o cartão branco. Abre em **F1/Opus** para escolher a leva;
o resto desce.

### (d) Os 11 órfãos de arte

`art/brp/` inteira, dois SVG de píer, `doca_concreto`, `art/sprites/`. É
relatório e não portão de propósito (`tools/arte_orfa.py`): **o destino de cada
um é decisão do Bruno**, não de uma sessão.

---

## 3. Armadilhas que 21/09 mediu e que mordem a seguir

- ⚠️ **A saída das ferramentas é CONTRATO, e o marcador novo quase colidiu.**
  `SINAL OK` chama-se assim porque "MEDIDA DE AUDIO OK" contém `AUDIO OK` como
  substring, e o passo do `teste_audio.gd` procura exatamente essa string.
  Antes de imprimir texto novo, procure que strings alguém procura na saída:
  hoje são `Tela salva em`, `Overlay:`, `Paineis:`, `COBERTURA OK`, `SINAL OK`
  e os marcadores das seis suítes.
- ⚠️ **Régua nova calibra-se ANTES de medir, e recusa-se a medir se falhar.**
  O `--autoteste` do `medir_audio.py` apanhou DOIS defeitos na própria régua no
  dia em que ela foi escrita — e nenhum deles teria aparecido nos 14 arquivos,
  porque nenhum chega perto de 0 dBFS.
- ⚠️ **Defeito injetado que muda o arquivo sem tocar na grandeza sob teste
  lê-se como "a guarda não pega".** O mutante X1 foi escrito com `0,95/√2` onde
  era `0,95·√2`: o espectro mexeu-se (prova de que o arquivo foi escrito) e o
  pico ficou parado. Quem o denunciou foi uma coluna ter mudado e a outra não.
- ⚠️ **Não altere os WAV nem o gerador para um número passar.** O CI compara-os
  byte a byte; e se a escuta pedir mudança, muda-se o GERADOR e regeram-se os
  arquivos, nunca o contrário.
- ⚠️ **Guarda que passa de primeira é para desconfiar**, e o defeito injetado
  nunca desce de modelo.

---

## 4. Restrições

- Nada de `# TUNING:`, política de perfis, sementes do jogo, projeção,
  enquadramento, viewport ou `SAVE_VERSION` — salvo se a opção (b) for a
  escolhida, e aí é o assunto dela, com decisão registada.
- Não mexa em gerador cuja saída o CI compara byte a byte.
- **Não reabra o R1–R9 nem as duas entregas de 21/09.**
- Código, comentários, nomes e documentos em pt-BR; commits e PR em inglês.
- Achou algo de outro item? Registre com a evidência e siga.

---

## 5. O que entregar ao encerrar

Branch e commit; arquivos alterados; o antes e o depois medidos; os comandos e
os marcadores; **quais mutantes reprovaram e por quê**; o que ficou pendente do
Bruno; o que ficou de fora e por quê.

⚠️ **E O BRIEFING DA CONVERSA SEGUINTE ENTRA NO MESMO COMMIT DE FECHO**, em
`docs/arquivo/`, datado, com a linha dele no índice de `docs/arquivo/README.md`
— nunca depois do merge.

**E entrega-se ao Bruno em BLOCO COPIÁVEL na conversa, antes de ele fundir.**

⚠️ **E O CI NÃO RODA AO EMPURRAR A BRANCH.** `testes.yml` e `captura.yml`
disparam em `push` só na `main` e em `pull_request`. Até o PR abrir, "verde"
quer dizer apenas "verde neste contêiner". O PR só se abre a pedido.
