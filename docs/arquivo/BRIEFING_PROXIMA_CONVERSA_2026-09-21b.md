# BR Port — prompt para a próxima conversa (R9)

**Como usar:** abra uma conversa nova no repositório `Brunoleon98/br-port` e
cole este texto. Não é preciso anexar o histórico da conversa anterior.

**Modelo:** o R9 abre em **F1** e pede **Opus**, e desta vez pelo motivo mais
forte da tabela: a entrega é **decidir o que se pode afirmar sem ouvir**, e a
ficha avisa que sem limiar perceptual validado não há veredito — só descritor.
Escolher as métricas, os limiares e o que fica por dizer é a entrega inteira.
A execução (rodar a análise, escrever a tabela) desce para Sonnet depois.

**Situação da entrega anterior:** o **R7 e o R8 fecharam** em 21/09 —
`docs/decisoes/036` e `037`. A branch foi empurrada; **o PR só se abre a pedido
do Bruno**.

⚠️ **Confira o estado da branch antes de reapontar.** Se o PR já foi fundido, a
receita é `git checkout -B <nome> origin/main`, e **antes disso**
`git log --oneline origin/main..HEAD` para saber o que ficaria de fora.

---

## 1. Comece pelo estado real

- Confira repositório, branch, `git status`, HEAD e o local contra o remoto
  **antes** de sincronizar. Preserve trabalho não publicado.
- Leia `CLAUDE.md` (carrega sozinho), `docs/ESTADO_DO_PROJETO.md` e a **§7.1**
  de `docs/design/BR_Port_Plano_v3_Claude_Code.md`. Para o R9, a origem é
  `docs/REVISAO_GERAL_2026-09-17.md` **§3**, e o plano do áudio está em
  `docs/design/BR_Port_Plano_Audio.md`.
- ⚠️ **O `ESTADO_DO_PROJETO.md` está a 28.917 de 29.000** — **83 bytes** de
  folga, que é o mais apertado que ele já esteve. O teto **não subiu** em 21/09:
  o R7 e o R8 couberam comprimindo os blocos do R5 e do R6, que já têm decisão
  própria. Se a sua entrega não couber, siga a ordem que a própria mensagem de
  erro da ferramenta imprime — subir o teto é o último passo dela.
- Rode `python3 tools/conferir_docs.py`, `python3 tools/conferir_guardas_ci.py`
  e `python3 tools/conferir_escopo_ui.py` antes de se surpreender no CI.

---

## 2. As duas decisões de PALAVRA continuam com o Bruno

Saíram da leitura em voz alta de 19/09. Nem o R6, nem o R7, nem o R8 lhes
tocaram — texto é gate dele. **Pergunte antes de mexer, e são uma linha cada:**

1. **O rótulo `"Caixa: R$…"`** do painel da parcela
   (`DebtPaymentPanel.gd:68`). "Caixa" é o jargão que ele mandou tirar das
   falas. A COR mudou em 20/09 e o ESCOPO em 21/09; a PALAVRA não.
2. **`"Semana nova. Barcos na fila e dinheiro no caixa. Aproveita."`**
   (`semana_nova_fila_folgado`), que é a fala na captura `porto.png`.

E uma terceira, que o R8 levantou e **não** tocou:

3. **`"Vence no dia 12 — 0 dias daqui."`** (`PainelParcela.gd`). A concordância
   está certa e soa a máquina; "hoje" seria melhor português e pior promessa,
   porque promete calendário. É escolha de palavra, e encosta na §2.5.

---

## 3. A entrega: R9 da §7.1

O que a §7.1 promete, na íntegra:

> **R9 — medir sem ouvir.** Duração, sample peak, RMS, bordas, DC e saturação
> já foram medidos: o ganho novo é true peak, descontinuidade interna, espectro
> e eventual mistura representativa. LUFS de 90 ms depende de janela/padding e
> não define alvo por SFX. A referência histórica Sony para portátil é da mix,
> não obrigação Android nem normalização de cada ativo. FFmpeg só como análise,
> se viável; sem dependência pesada ou alteração de WAVs. Soma offline não é
> mix real sem comprovar buses/ganhos/efeitos. Mutantes em cópias: pico entre
> amostras que o sample peak não pega, salto no meio com bordas zeradas e banda
> rotulada errada. Sem limiar perceptual validado, emitir descritor/alerta.
> Bruno ouve no telefone-alvo, volume fixo, isolado e em contexto; registrar
> reconhecimento, dominância e fadiga. Continua proibido dizer que "ficou bom".

### O que já existe, e que o R9 herda

⚠️ **Isto é medição, não previsão** — medida no commit do R8. Reconfira no seu
HEAD antes de agir; o R7 e o R8 fecharam os dois porque um número herdado não
batia com o contado.

- **Os 14 WAV são GERADOS** por `tools/gerar_sons.py`, só com a biblioteca
  padrão, e o CI **compara byte a byte**. A ficha diz "sem alteração de WAVs" —
  e a regra do `CLAUDE.md` diz mais: não mexa num gerador que o CI compara assim
  para calar uma falha.
- **`tests/teste_audio.gd` já cobre o que se prova sem ouvir** e espera
  `AUDIO OK`. Leia-o antes de escrever régua nova: a pergunta que ele já faz não
  se escreve duas vezes.
- **Este contêiner NÃO tem placa de som**, e é a razão de todo o item existir.
  Nunca escrever "o som ficou bom" — escrever "toca no evento X, dura Y ms,
  roteado no bus Z".

### Armadilhas que este projeto já mediu e que mordem aqui

- ⚠️ **Régua muda dá um NÚMERO, e o número vira a conclusão da sessão.** Antes
  de acreditar em qualquer medição de áudio: o mesmo arquivo dos dois lados tem
  de dar **zero exato**, e um par que se sabe diferente tem de dar **muito**.
  Sem os dois, "0,00% de diferença" e "a régua está a comparar o arquivo
  consigo mesmo" são indistinguíveis.
- ⚠️ **Quando uma régua nova devolve zero em TUDO, a primeira pergunta é se ela
  consegue devolver outra coisa.**
- ⚠️ **Não se aperta o teto de uma guarda até ela apanhar um segundo defeito.**
  A ficha já o diz à maneira dela: sem limiar perceptual validado, o que se
  emite é descritor, não veredito.
- ⚠️ **A saída das ferramentas deste projeto é um CONTRATO.** Antes de imprimir
  texto novo, procure que strings alguém procura na saída dela — `AUDIO OK` é
  uma delas.
- ⚠️ **Guarda que passa de primeira é para desconfiar**, e o defeito injetado
  nunca desce de modelo. A ficha já nomeia os três mutantes, e eles são **em
  cópias** dos WAV, nunca nos originais.
- ⚠️ **E confira QUAL guarda reprovou, e que a outra ficou verde.** Foi assim
  que o R8 provou que o T9 e o F9 não são redundantes.

### Restrições

- Nada de `# TUNING:`, política de perfis, sementes, projeção, enquadramento,
  viewport ou `SAVE_VERSION`.
- **Sem dependência pesada.** FFmpeg só se já estiver disponível; `bpy` não
  entra nisto.
- **Não alterar os WAV**, nem o gerador, para fazer um número passar.
- Código, comentários, nomes e documentos em pt-BR; commits e PR em inglês.
- Achou algo de outro item? Registre com a evidência e siga.

---

## 4. O que o R7 e o R8 deixaram por fazer, e que NÃO é do R9

Dito para não ser reaberto por engano, e porque é trabalho real com caminho
escrito:

- **27 cores de interface continuam declaradas como exceção**, em
  `tools/excecoes_cor_ui.json`, com classe (ESTADO ou BASE) e justificativa.
  A migração é **por leva e por FUNDO**, nunca linha a linha: nenhum tom ganha
  dois fundos, e o âmbar do `_workers_title` (5,53:1 na barra escura) não é o
  `RotuloAlerta` (o mesmo âmbar escurecido para o cartão branco).
- ⚠️ **CINCO PAINÉIS NÃO TÊM FOTO NENHUMA** — Construir, Calendário, Docas,
  Reputação e Caixa. O percurso do D33 mede-os; a bateria do
  `capturar_evidencia.sh` não os fotografa. É item próprio e vale uma sessão
  curta.
- ⚠️ **E O `PainelCaixa` NEM É CAPTURÁVEL HOJE**, em silêncio: o `setup()` dele
  exige um `Dictionary`, que a linha de comando não sabe passar. Medido em
  21/09 — o `capturar_cena.gd` chama `setup()` com zero argumentos, o painel não
  monta, e a ferramenta **imprime "Tela salva em" e sai com código 0** com uma
  foto PRETA. O erro está na saída (`Method expected 1 argument(s), but called
  with 0`) e ninguém o lê. É a mesma família do `setup()` saltado de 12/09.
- ⚠️ **E o percurso dos 19 estados não monta três dos estados que pintam cor à
  mão** — dia já vivido do calendário, estrutura já construída, doca sob oferta
  do rival. **O estado vem primeiro, a cor depois.**

---

## 5. O que entregar ao encerrar

Branch e commit; arquivos alterados; o antes e o depois medidos; os comandos e
os marcadores; **quais mutantes reprovaram e por quê**; o que ficou pendente do
Bruno; o que ficou de fora e por quê. Atualize a §7.1 só até a fase comprovada,
e o `ESTADO_DO_PROJETO.md` dentro do teto.

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
