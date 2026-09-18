# 033 — A fala é VISTA, e o predicado lê-se onde ela se escreve

**18/09/2026 · R4 da §7.1 do plano v3 · achado pela revisão externa de 17/09 (§2.2 e §2.3)**

## O defeito

Oito falas da Dona Cida, três problemas, e um deles a esconder o outro.

A revisão apontou que `upgrade_pronto` — *"Zezão terminou. Demorou o dobro do
previsto"* — é disparada por `estrutura_comprada`, que o `GameState` emite
**uma linha antes** do `message.emit("… — pronto")` da mesma chamada. Os dois
escrevem no mesmo `Label`, e o segundo tapa o primeiro. E a frase é falsa neste
mundo de qualquer maneira: `comprar_estrutura()` emite "pronto" na mesma
chamada, logo nada demorou.

Medido antes de mexer, cinco sementes, partidas inteiras, com uma sonda ligada
aos mesmos sinais que o `Main` e depois dele:

| fala | escrita | vista |
|---|---|---|
| `arlindo_indireto` | 42 | 42 |
| `perdeu_para_arlindo` | 27 | 27 |
| `semana_nova` | 20 | 15 |
| `bom_contrato` | 54 | 36 |
| `reputacao_subiu` | 11 | 4 |
| **`caixa_baixo`** | 11 | **0** |
| **`reputacao_caiu`** | 12 | **0** |
| **`upgrade_pronto`** | 35 | **0** |

**A revisão contou quatro pares e são cinco.** Ela achou os três de
`cash_changed`; faltavam `_fechar_negocio` e `_perder_para_rival`, que chamam
`_change_reputation()` e emitem `message` logo a seguir — é por isso que
`reputacao_caiu` também dava zero. É a lição "ao corrigir um, VARRA OS IRMÃOS"
com um SINAL no lugar do prop.

**E a evidência da §2.3 tinha envelhecido, mas o defeito não.** A revisão dizia
que a `porto.png` mostrava *"caixa no limite"* com R$981.779 no HUD; no HEAD de
hoje aquela foto mostra R$1.285.532 e uma mensagem do sistema, porque o R2
mexeu no avanço de turno e a foto andou. A frase continuava sem condição
nenhuma — o que mudou é que ela **deixou de chegar à tela**. Consertar a ordem
torna a frase falsa visível: **(c) estava mascarado por (a)**, e os dois não se
separam.

**O mesmo vale para um irmão que ninguém tinha visto.** `caixa_baixo` afirma
*"A parcela não vai esperar"*, e `pagar_parcela_adiantado()` existe desde o
playtest. Medido com um perfil que quita assim que pode, em 8 partidas: **12
travessias para caixa curto com a parcela já paga, e ZERO com ela por pagar** —
para esse jogador a frase era falsa em todas as ocorrências. Hoje estava
escondida pela mesma mensagem que a engolia.

## A decisão

**A ordem, num lugar só.** O `_cida()` passou a escrever por `call_deferred`,
de modo que a fala entra no fim do frame, depois de toda mensagem do sistema
daquele evento. Conserta os cinco pares de uma vez e não deixa o sexto por
nascer — reordenar cinco sítios do `GameState` espalharia uma questão de
interface pelo modelo e o par seguinte voltaria a quebrar.

O preço é o inverso: agora é a mensagem do sistema que fica por baixo. Mostrar
**as duas** é a fila do R5, e é item próprio. O comentário do `Main` afirmava
desde sempre que a fala "NÃO tapa a mensagem do sistema, porque quem chama isto
chama-o depois do evento" — verdade só para os dois gatilhos que o `Main` chama
à mão, e foi por isso que ninguém foi ver.

**Os predicados saem do `GameState`, e nenhum limiar novo entra.** A fala da
semana nova precisava de duas perguntas que já existiam: `caixa_curto()` (meia
parcela, o critério que o aviso de caixa curto usa desde que existe) e
`docas_esperando()` (extraído de dentro do `trabalho_parado()`, que devolve
zero quando não há trabalhador livre — e "há barco na fila?" continua a ser
sim). Duas cópias da mesma linha seriam duas a divergir.

**E o predicado lê-se ONDE A LINHA É ESCRITA.** Este é o achado que mudou o
desenho a meio. `turn_advanced` sai **antes** de `_check_end() → _spawn_boats()`,
e o laço de serviço já esvaziou toda doca sem trabalhador:

| `docas_esperando()` | amostras | com barco à espera |
|---|---|---|
| no instante do `turn_advanced` | 315 | **0** |
| depois de `advance_turn()` voltar | 310 | **148** (48%) |

Uma variante que dissesse *"Barcos na fila"* no instante do sinal seria uma
frase que ninguém jamais leria — o `barco_medio` outra vez, agora na narrativa,
e desta vez a caminho de ser eu a escrevê-lo. O `_cida_semana` passou a adiar a
ESCOLHA, não só a escrita, e o estado que ela lê é o que o jogador tem à frente.

**As falas.** `upgrade_pronto` perdeu a duração e ficou com o ceticismo;
`semana_nova` virou quatro variantes sobre o par (barco à espera × caixa
curto); `caixa_baixo` ganhou a variante para a parcela já paga; e
`arlindo_indireto` ganhou a variante da PRIMEIRA oferta, que chega antes de
existir recusa nenhuma (`metrics["rival_refused"]`, que já existia). Escolha do
Bruno; o A4 — a leitura em voz alta — continua a ser o gate, porque um
predicado verde não aprova uma frase.

## A guarda

Bloco **F8** do `teste_fumaca.gd`. O F4 pergunta *"toda fala DISPARA?"* e ela
dispara; o F8 pergunta o que sobrou no `Label` depois de todos os emits.

⚠️ **Ele tem de esperar DOIS frames, e foi medido.** `await process_frame`
retoma no INÍCIO do frame seguinte, e a fila de `call_deferred` daquele frame
ainda não correu: com um só, o `Label` devolvia a mensagem do sistema e as
asserções reprovavam o código certo. A régua de medição caiu no mesmo buraco
antes — a primeira corrida depois da correção deu **zero em todas as falas**, e
zero ali lê-se como "não há fala", que é o verde de graça de sempre.

⚠️ **E o `_process` da suíte passou a devolver `false`.** Devolver `true` mata a
árvore no fim do frame, e o `await` nunca voltava: a suíte imprimiria o
marcador com o bloco inteiro por correr. Quem encerra continua a ser o `quit()`
explícito.

Seis mutantes, cada um sozinho e com controle positivo verde entre eles:

| # | Defeito injetado | Reprovou em |
|---|---|---|
| M1 | a fala volta a escrever no instante do sinal | F8a, F8e |
| M2 | a frase falsa reintroduzida | F8b |
| M3 | condição retirada da semana nova | F8c |
| M4 | comparação antes de existir semana anterior | F8d |
| M5 | predicado lido no sinal, e não na escrita | F8c2 |
| M6 | a parcela já paga deixa de escolher a outra fala | F8e |

O F8a confere primeiro que a compra **emite mesmo** uma mensagem do sistema
naquele frame: sem o perigo montado, a asserção seguinte passaria por um
caminho que não é o que ela defende. E o F8c chama `_semana_nova()` direto com
o estado montado à mão, em vez de recalcular o esperado dos mesmos predicados
que a fala usa — isso seria o espelho, e um predicado posto a zero
desapareceria dos dois lados ao mesmo tempo.

**O que o F8 NÃO defende:** que a frase seja verdadeira. Ele prova que a
condição escolhe a variante certa e que a linha chega à tela. Se a frase
descreve mesmo este mundo é o A4 — foi assim que se apanhou *"porto que fecha
no azul abre segunda-feira"*, que nenhuma asserção podia ver.

## O que ficou de fora

**Três falas continuam invisíveis, e agora por outra razão.** `caixa_baixo`,
`caixa_baixo_quitado` e `reputacao_caiu` perdem para uma fala da Dona Cida
escrita **depois** delas na mesma ação do jogador — não para a mensagem do
sistema. Decidir qual das duas o jogador vê é prioridade entre falas, e mostrar
as duas é a fila: **R5**, item próprio. Fica medido aqui para lá não ter de o
redescobrir.

## O que se mediu e não virou asserção

`bom_contrato` sobrevive em 36 de 54; `reputacao_subiu` em 4 de 11. São o mesmo
caso das três acima, em grau menor, e nenhum teto foi apertado para os apanhar.
