# BR Port — prompt para a próxima conversa (o portão que faltava)

**Como usar:** abra uma conversa nova no repositório `Brunoleon98/br-port` e
cole este texto. Não é preciso anexar o histórico da conversa anterior.

**Modelo:** abre em **F1** e pede **Opus** por pouco tempo — a decisão é *como
se DERIVA a cobertura*, e há três formas de um painel ser fotografado, uma das
quais não é chamada nenhuma. Escrito o desenho, a execução desce para Sonnet.

**Situação:** a sessão das capturas fechou em 21/09 — `docs/decisoes/038`. Os
quinze painéis do jogo têm foto, a bateria tem **24 tiros**, a varredura de
erro dela pergunta pela ORIGEM e cada tiro tem teto de tempo.

⚠️ **Confira o estado da branch antes de reapontar.** Se o PR já foi fundido, a
receita é `git checkout -B <nome> origin/main`, e **antes disso**
`git log --oneline origin/main..HEAD` para saber o que ficaria de fora.

⚠️ **A FILA DA §7.1 CONTINUA NO R9**, cujo prompt está em
`docs/arquivo/BRIEFING_PROXIMA_CONVERSA_2026-09-21b.md` — áudio medido mais
protocolo de escuta. Ele acaba num gate que só o Bruno passa. O item abaixo é o
que se faz sem ele, como foi o das capturas.

---

## 1. Comece pelo estado real

- Confira repositório, branch, `git status`, HEAD e o local contra o remoto
  **antes** de sincronizar. Preserve trabalho não publicado.
- Leia `CLAUDE.md` (carrega sozinho) e `docs/ESTADO_DO_PROJETO.md`.
- ⚠️ **O `ESTADO_DO_PROJETO.md` está a 28.911 de 29.000** — 89 bytes. O teto
  **não subiu** nas três últimas entregas, e a de 21/09 coube comprimindo: os
  resumos que duplicavam uma decisão viraram ponteiro para ela. Se a sua não
  couber, siga a ordem que a mensagem de erro da ferramenta imprime.
- Rode `python3 tools/conferir_docs.py`, `conferir_guardas_ci.py` e
  `conferir_escopo_ui.py` antes de se surpreender no CI.

---

## 2. A entrega: o portão que pergunta se um painel tem foto

### O que está medido (21/09 — reconfira no seu HEAD)

**Nada pergunta se um painel novo tem fotografia**, e é o que fez a sessão das
capturas existir. O buraco custou o seguinte, medido:

- o R7 e o R8 mexeram em **quatro** telas sem foto nenhuma, e olharam à mão;
- **três sessões contaram os painéis e as três disseram treze**; são **quinze**;
- as duas que faltavam escapam por razões diferentes e nenhuma é descuido: o
  `EndGame.tscn` **não vive em `scenes/panels/`** (está em `scenes/`), e a
  `TelaNomes` é dispensada DE PROPÓSITO pelo `capturar_tela.gd`, que chama
  `definir_nomes()` para ela não tapar o que se ia fotografar.

Hoje os quinze estão cobertos, e é isso que torna possível um portão **sem
exceção nenhuma** — que é muito mais forte do que um portão que nasce com
buracos declarados.

### O que a sessão tem de decidir (F1)

1. **De onde sai a lista de painéis.** A fonte forte é o que o jogo ABRE —
   `_abrir_painel(X)` no `Main.gd`, resolvido pelos `preload` no topo — e não a
   pasta, que foi exactamente o que perdeu o `EndGame`. Um painel que o jogo
   nunca abre não é buraco de foto: é arte órfã, e quem pergunta isso já existe
   (`tools/arte_orfa.py`).
2. **Como se prova a COBERTURA, que chega por TRÊS caminhos.** É aqui que está
   a decisão, e a terceira forma é a que estraga a solução óbvia:
   - o **caminho da cena**, literal na linha de comando (`diario`, `parcela`,
     `ribeiro`, `contraoferta`, `menu`, `nomes`, `fimfase`);
   - o **`--painel=<nome>`**, que resolve por uma cadeia de dois saltos —
     tabela `PAINEIS` do `capturar_tela.gd` → método do `Main` →
     `_abrir_painel(Cena)`. Esta é VERIFICÁVEL de ponta a ponta;
   - as **bandeiras** `pausa` e `mensagens`, que chamam um método do `Main`
     pela mesma cadeia… e o **Boletim**, que não é chamada nenhuma: ele abre
     sozinho na virada da semana, e o tiro só declara que o espera.
   Uma declaração à mão resolve o último caso e é a armadilha conhecida: ela
   pode MENTIR. O que a torna aceitável é o que a `036` já fez com as cores —
   declarar com chave, contagem e justificativa, e reprovar a declaração que
   envelhece (o painel que já não existe, o nome que já não abre nada).
3. **Onde o portão corre.** O `conferir_escopo_ui.py` e o
   `conferir_guardas_ci.py` são Python e correm ANTES do Godot, porque
   respondem a perguntas sobre ARQUIVOS e porque em Python uma exceção sai com
   código ≠ 0. Este é da mesma família. Alternativa a pesar: fazer a prova sair
   da própria FOTO — o `capturar_tela.gd` já imprime a linha `Overlay:`, e
   ensiná-la a dizer QUAL painel estava aberto tornaria a cobertura uma coisa
   medida em vez de declarada. Custa mais e mente menos.

---

## 3. Armadilhas que este projeto já mediu e que mordem aqui

- ⚠️ **A convenção de pasta é uma suposição sobre o conteúdo** — é o que perdeu
  o `EndGame` três vezes.
- ⚠️ **Guarda que passa de primeira é para desconfiar.** Os mutantes óbvios:
  um painel novo no `Main` sem tiro (tem de reprovar); uma declaração para um
  painel que já não existe (tem de reprovar); e o par do `#` — a mesma
  declaração dentro de um COMENTÁRIO passa, sem o `#` reprova —, que é o que
  separa "o comentário foi ignorado" de "o scanner nunca olhou este arquivo"
  (`036`, M7/M8).
- ⚠️ **Corte os comentários antes de varrer.** Este repositório CITA nos
  comentários tudo o que as guardas procuram, palavra por palavra — e o corte é
  pelo INÍCIO da linha, nunca pelo `#` onde quer que esteja.
- ⚠️ **Leia o arquivo INTEIRO, nunca linha a linha.** O código e a prosa daqui
  quebram aos ~79 caracteres; o F9 achou 6 de 11 chamadas por causa disto
  (`037`), e a asserção que o apanhou foi **contar por dois caminhos**.
- ⚠️ **Nenhuma guarda pergunta o que o painel DIZ**, e esta também não vai
  perguntar: um tiro com o estado errado — o Docas num turno em que a contagem
  é 1 — não reprova nada. O que separa foto boa de foto inútil é quem olha.

---

## 4. Restrições

- Nada de `# TUNING:`, política de perfis, sementes do jogo, projeção,
  enquadramento, viewport ou `SAVE_VERSION`.
- Não mexa em gerador cuja saída o CI compara byte a byte.
- **Não reabra o R7, o R8 nem a sessão das capturas.** Os estados de cada tiro
  estão escritos ao lado dele, com o que fica de fora e porquê.
- ⚠️ **Não leve a varredura `GDScript backtrace` para o `testes.yml`.** É
  medido: o `teste_fumaca` imprime um erro de JSON de propósito e ele TRAZ
  backtrace — o padrão novo casa 1 linha lá e poria uma suíte verde a vermelho
  (`038`).
- Código, comentários, nomes e documentos em pt-BR; commits e PR em inglês.
- Achou algo de outro item? Registre com a evidência e siga.

---

## 5. O que continua pendente do Bruno, e não é desta sessão

- **Três decisões de PALAVRA**: o rótulo `"Caixa: R$…"`
  (`DebtPaymentPanel.gd:68`), o `"dinheiro no caixa"` da fala da semana nova, e
  o `"0 dias daqui"` do painel da parcela.
- **A6 — ouvir.** Este contêiner não tem placa de som.
- **A5 — olhar.** ⚠️ **E ele destravou:** há agora foto dos quinze painéis, do
  Construir ao fim de Fase 1. O que falta é o olho dele.

---

## 6. O que entregar ao encerrar

Branch e commit; arquivos alterados; o antes e o depois medidos; os comandos e
os marcadores; **quais mutantes reprovaram e por quê**; o que ficou pendente do
Bruno; o que ficou de fora e por quê.

⚠️ **E O BRIEFING DA CONVERSA SEGUINTE ENTRA NO MESMO COMMIT DE FECHO**, em
`docs/arquivo/`, datado, com a linha dele no índice de `docs/arquivo/README.md`
— nunca depois do merge. Uma sessão nova arranca da `main`, então um briefing
escrito a seguir fica órfão numa branch que ninguém volta a abrir.

**E entrega-se ao Bruno em BLOCO COPIÁVEL na conversa, antes de ele fundir.**

⚠️ **E O CI NÃO RODA AO EMPURRAR A BRANCH.** `testes.yml` e `captura.yml`
disparam em `push` só na `main` e em `pull_request`. Até o PR abrir, "verde"
quer dizer apenas "verde neste contêiner". O PR só se abre a pedido.
