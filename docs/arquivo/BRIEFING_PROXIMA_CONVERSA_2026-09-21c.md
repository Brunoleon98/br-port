# BR Port — prompt para a próxima conversa (as capturas que faltam)

**Como usar:** abra uma conversa nova no repositório `Brunoleon98/br-port` e
cole este texto. Não é preciso anexar o histórico da conversa anterior.

**Modelo:** abre em **F1** e pede **Opus** por pouco tempo — a decisão é *que
ESTADO cada foto tem de montar*, e neste projeto essa escolha já se errou
várias vezes (foto de um painel vazio, foto de um estado que o jogo não faz,
foto adiantada de um frame). Assim que a lista de estados estiver escrita, a
execução desce para Sonnet: escrever os tiros, rodar a bateria, olhar.

**Situação:** o **R7 e o R8 fecharam** em 21/09 — `docs/decisoes/036` e `037`.
O Bruno ia abrir o PR deles.

⚠️ **Confira o estado da branch antes de reapontar.** Se o PR já foi fundido, a
receita é `git checkout -B <nome> origin/main`, e **antes disso**
`git log --oneline origin/main..HEAD` para saber o que ficaria de fora.

⚠️ **E ISTO NÃO É UM ITEM DA §7.1.** A fila das correções da revisão externa
continua no **R9**, cujo prompt está em
`docs/arquivo/BRIEFING_PROXIMA_CONVERSA_2026-09-21b.md`. Esta sessão é um item
próprio, que o R7 e o R8 descobriram e registaram sem corrigir — e é o que se
pode fazer **sem o Bruno**, porque o R9 encosta num gate de escuta que só ele
tem.

---

## 1. Comece pelo estado real

- Confira repositório, branch, `git status`, HEAD e o local contra o remoto
  **antes** de sincronizar. Preserve trabalho não publicado.
- Leia `CLAUDE.md` (carrega sozinho) e `docs/ESTADO_DO_PROJETO.md`.
- ⚠️ **O `ESTADO_DO_PROJETO.md` está a 28.917 de 29.000** — **83 bytes** de
  folga, o mais apertado que já esteve, e o teto **não subiu** nas duas últimas
  entregas. Se a sua não couber, siga a ordem que a própria mensagem de erro da
  ferramenta imprime; subir o teto é o último passo dela, não o primeiro.
- Rode `python3 tools/conferir_docs.py`, `conferir_guardas_ci.py` e
  `conferir_escopo_ui.py` antes de se surpreender no CI.

---

## 2. A entrega: as fotos que não existem, e a guarda que não as cobriria

### O que está medido (21/09 — reconfira no seu HEAD)

**Cinco painéis do jogo não aparecem em foto nenhuma:**

| Painel | Onde ele vive |
|---|---|
| `UpgradePanel` (Construir) | o painel que o R6 encurtou em 60 px e o R7 remexeu |
| `PainelCalendario` | o R7 trocou-lhe a cor dos dias passados |
| `PainelDocas` | o R8 trocou-lhe duas frases de contagem |
| `PainelReputacao` | — |
| `PainelCaixa` | o R8 trocou-lhe duas frases de contagem |

Os outros oito têm tiro na bateria (`boletim`, `pausa`, `mensagens`, `diario`,
`parcela`, `ribeiro`, `contraoferta`, `menu`). ⚠️ **O `TelaNomes` não foi
medido** — o `inicio` é o jogo no turno 0 e o `capturar_tela.gd` faz
`new_game()` direto, então confirme antes de o contar de um lado ou do outro.

⚠️ **Os três últimos foram MEXIDOS pelo R7 e pelo R8 sem que houvesse foto**, e
isso não é detalhe: a regra 5 do `CLAUDE.md` manda tirar uma captura e olhar
quando se mexe no visual. As duas sessões olharam à mão, fora da bateria — o
que não deixa antes/depois no PR e não se repete sozinho.

### E o `PainelCaixa` não é capturável de todo

O `setup()` dele exige um **`Dictionary`**, que a linha de comando não sabe
passar. Medido: o `capturar_cena.gd` chama `setup()` com zero argumentos, o
painel não monta, e a ferramenta **imprime "Tela salva em" e sai com código 0**
com uma foto PRETA.

⚠️ **E A GUARDA DA BATERIA NÃO APANHARIA ISSO** — medido, e é o achado que
justifica a sessão. O `tirar()` do `capturar_evidencia.sh` varre o log por
`SCRIPT ERROR|at: push_error \(`, e o erro real é:

```
ERROR: Error calling method from 'callv': 'Control(PainelCaixa.gd)::setup':
       Method expected 1 argument(s), but called with 0.
       [0] _chamar_setup (res://tools/capturar_cena.gd:134)
```

Nenhum dos dois padrões casa. Logo, **se o `PainelCaixa` fosse acrescentado à
bateria hoje, a foto preta seria anexada ao PR como evidência e a bateria diria
verde.** É a lição da `031` — *"a linha de sucesso não diz que não houve
erro"* — com um terceiro prefixo que o par em vigor não cobre.

### O que a sessão tem de decidir (F1)

1. **Que ESTADO cada foto monta.** Um painel fotografado no estado vazio prova
   que a cena abre e mais nada — e este projeto já registou três maneiras de
   isso sair mal (o `setup()` saltado, o save herdado do disco, a foto
   adiantada de um frame). Para o Construir, o Calendário e o Caixa o estado
   **importa**: com o porto em ruínas não há estrutura construída, no dia 1 não
   há dia passado, e com uma doca só a contagem nunca passa de 1 — que é
   exatamente onde o singular e o plural dão o mesmo texto.
2. **Como se passa um `Dictionary` ao `setup()`.** Derivar do `GameState`
   (`resumo_do_dia()`) é o caminho que a regra deste projeto pede — *"ferramenta
   que finge um estado tem de o DERIVAR do estado"* —, e a pergunta é onde isso
   vive: num argumento novo do `capturar_cena.gd`, ou num tiro próprio.
3. **Se a guarda do `tirar()` passa a cobrir o `callv`.** É alargar um par de
   padrões medido, e o `CLAUDE.md` avisa dos dois lados: um `grep ERROR` cru
   reprovaria cinco suítes verdes, e o escopo da guarda é o escopo do defeito.
   Meça o que a corrida saudável imprime antes de escolher o padrão.

---

## 3. Armadilhas que este projeto já mediu e que mordem aqui

- ⚠️ **Condição de atalho numa ferramenta de evidência é uma foto que ninguém
  tirou.** Já mordeu em 12/09, no mesmo arquivo.
- ⚠️ **O autoload não nasce vazio** — ele tenta `load_game()` antes de
  `new_game()`, então toda foto de cena solta herda o autosave da foto
  anterior. O que prova o conserto é **rodar a bateria DUAS vezes e exigir os
  mesmos bytes**.
- ⚠️ **A semente do jogo não é a semente global** (`GS._rng.seed`), e sem
  `--fixed-fps 60` a foto serve para olhar, não para comparar.
- ⚠️ **Contagem só se testa acima de um.** Com o porto de uma doca, `servidos`
  nunca passa de 1 — e a 1 a frase certa e a errada são a mesma. Foi assim que
  o R8 teve de levantar o porto inteiro para ver "3 barcos atendidos".
- ⚠️ **Foto adiantada é pior do que foto errada**: quem fotografa depois de
  agir espera o que a ação deixou pendente, e aqui isso mede-se em frames.
- ⚠️ **Guarda que passa de primeira é para desconfiar**, e o defeito injetado
  nunca desce de modelo. Aqui o mutante óbvio é **o próprio caso medido**: pôr
  o `PainelCaixa` na bateria com o `setup()` a falhar e exigir que ela REPROVE.

---

## 4. Restrições

- Nada de `# TUNING:`, política de perfis, sementes do jogo, projeção,
  enquadramento, viewport ou `SAVE_VERSION`.
- Não mexa em gerador cuja saída o CI compara byte a byte.
- **Não reabra o R7 nem o R8.** Os 27 overrides declarados e a redação das
  falas são de outras sessões e do Bruno.
- Código, comentários, nomes e documentos em pt-BR; commits e PR em inglês.
- Achou algo de outro item? Registre com a evidência e siga.

---

## 5. O que continua pendente do Bruno, e não é desta sessão

- **Três decisões de PALAVRA**: o rótulo `"Caixa: R$…"`
  (`DebtPaymentPanel.gd:68`), o `"dinheiro no caixa"` da fala da semana nova, e
  o `"0 dias daqui"` do painel da parcela (que o R8 levantou e não tocou).
- **A6 — ouvir.** Este contêiner não tem placa de som.
- **A5 — olhar.** Que é precisamente o que esta sessão desbloqueia: hoje há
  painel que ele não tem como ver.

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
