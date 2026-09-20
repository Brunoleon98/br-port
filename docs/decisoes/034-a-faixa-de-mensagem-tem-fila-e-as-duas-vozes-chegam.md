# 034 — A faixa de mensagem tem fila, e as duas vozes chegam

**19–20/09/2026 · R5 da §7.1 do plano v3 · origem: revisão externa de 17/09 (§2.2), e a conta que o `033` deixou aberta**

## O defeito

A faixa é um `Label` só, e duas fontes escrevem nele: a mensagem do sistema
(`GameState.message`) e a voz da Dona Cida. Quem escreve por último apaga quem
escreveu antes, no mesmo frame, sem deixar rasto.

O `033` já tinha mexido nisto uma vez e **só trocou o vencedor**: a fala passou
a entrar no fim do frame por `call_deferred` e ficou por cima, de modo que a
mensagem tapada passou a ser sobretudo a do SISTEMA. Ele próprio registou a
dívida — *"mostrar as duas é a fila do R5"*.

Medido com `tools/medir_fila_mensagens.gd`, 15 partidas em cinco sementes e
três formas de jogar, 973 ações do jogador:

| | antes | depois |
|---|---|---|
| escritas na faixa | 861 | 861 |
| apresentadas | 597 | **812** |
| **nunca apresentadas** | **264 — 30,7%** | **49 — 5,7%** |

As 49 que restam são fusões por duplicata semântica, que é o desenho. E as
falas que o `033` deixou invisíveis estão pagas: `caixa_baixo` passou de **10
escritas / 0 vistas** para 10/10, e `reputacao_caiu` de 28/3 para 28/28.

A maior rajada de uma ação são **4** mensagens; comprar uma estrutura escreve
2,29 em média e **nunca** coube numa faixa de uma linha.

## A decisão

**`FilaDeMensagens` — FIFO, com tempo mínimo na tela.** Prioridade pelo `kind`
que o jogo já usa para colorir a faixa, e ela decide a PRÓXIMA apresentação,
nunca interrompe a atual. Interromper seria copiar do `Audio.gd` o descarte do
perdedor — que ali está certo, porque dois sons no mesmo frame são ruído — e
aqui apagaria a frase a meio da leitura.

**Coalescência só por duplicata semântica**, que aqui quer dizer o mesmo TEXTO.
Duas mensagens diferentes da mesma compra não se fundem. Onde isto morde de
verdade é na obra a partir da terceira: duas compras no mesmo turno escrevem a
MESMA linha da Dona Cida — e as duas mensagens do sistema são diferentes. Foi o
Bruno quem levantou o caso, ao ler a fala nova do Zezão.

**Não é autoload, e é decisão.** Um autoload carrega também em `--script`, logo
estaria de pé nas seis suítes e nas 600 partidas por perfil do simulador — a
armadilha que o `Registro.gd` já documenta. É um objeto do `Main`.

**E não fala com o `GameState`.** É um `class_name`, e o autoload não resolve
pelo nome dentro de um. Mais importante: ela guarda TEXTO já resolvido, nunca
um id. Uma fila que resolvesse o id na hora de mostrar diria *"Barcos na fila"*
sobre um cais que entretanto esvaziou — exatamente o defeito que o `033`
acabou de fechar, a voltar pela porta do lado.

**O tempo mínimo é `1,2 s + 0,022 s por caractere`.** Não sai de velocidade de
leitura publicada, e a §7.1 diz porquê: *"velocidade de leitura focada não
prova leitura incidental mobile"*. Sai da reta que dá ~2,4 s na frase mediana
do jogo (54 caracteres) e ~3,3 s na mais longa (95). O que se pode medir aqui é
a CONSEQUÊNCIA: a faixa fica ocupada 2,4 s na ação mediana e 9,9 s na pior, com
162 de 556 ações a pedirem mais de 5 s. **O desenho é feito para o número não
ser crítico** — nada se descarta e o histórico está a um toque —, de modo que
errá-lo custa espera, nunca informação perdida. Quem o afina com uma pessoa a
jogar é o gate A5/A7.

**A recuperação é a própria faixa.** Tocar nela (692×52 px, muito acima do
mínimo de 44) abre o histórico da sessão, do mais recente para o mais antigo,
em memória — `SAVE_VERSION` intocado, como a §7.1 pede. Um contador `+N` torna
a fila visível, porque texto que ninguém sabe que existe é recuperável e
continua perdido.

## O que a construção ensinou

⚠️ **A RÉGUA DEU UM NÚMERO NEGATIVO, e foi o sinal que a denunciou.** Depois da
fila ela relatou *zero* falas da Dona Cida e **−194** nunca apresentadas. A
sonda pendurava-se no `_on_message`, que era o funil único das duas fontes até
ao R5 — e a fila fez o `_cida_agora` enfileirar direto. O impossível é mais
barato de ver do que o zero, e é a mesma família: **quando uma régua devolve um
valor que não pode existir, a pergunta é o que ela deixou de ver.**

⚠️ **E `has()` NÃO CONTA DUPLICATAS, no relatório cujo assunto É a duplicata.**
Corrigida a sonda, a contagem ainda discordava dela própria — 49 pela subtração
contra 42 pelo `has()`. Um texto escrito duas vezes e apresentado uma contava
por duas vistas. Onde o caso interessante é a repetição, a conta é de
multiconjunto.

⚠️ **E A FOTO SAIU ADIANTADA, que é pior do que errada.** O tiro novo abria o
histórico na mesma volta em que o laço de turnos acabava: a lista saía com
CINCO enquanto a faixa por trás já anunciava "+7", porque três falas daquele
turno ainda estavam em `call_deferred`. Parecia um defeito da fila que se
acabara de construir. Hoje ele abre depois de assentar, e as 17 capturas saem
byte a byte iguais em duas corridas.

⚠️ **E `PISO` ERA BASE E PISO AO MESMO TEMPO, o que fazia um `clamp` que nunca
apertava.** Quem o apanhou foi a asserção que exigia que uma frase curta
medisse exatamente o piso — e não media, porque `PISO + n × POR_CARACTERE`
nunca cai abaixo de `PISO`. A constante passou a chamar-se `BASE` e o limite de
baixo saiu.

## As guardas

**T8**, no `run_tests.gd`, cobre a fila como aritmética pura — e é ali e não no
fumaça de propósito, pela mesma razão que tirou a Leitura do simulador de
dentro do `SceneTree` (`030`): ela não fala com o `GameState` nem toca em nó
nenhum, e o tempo passa-se à mão em vez de se esperar.

**F8 mudou de SIGNIFICADO.** Até aqui "vista" queria dizer *"sobrou no `Label`
depois de todos os emits"*, porque a última escrita apagava as outras. Com a
fila nada é apagado, e a pergunta certa passou a ser *"foi APRESENTADA?"* — ler
o `Label` agora responderia pela última da fila e chamaria "não vista" a uma
frase que esteve na tela os seus dois segundos. O F8a ganhou a asserção que é o
R5 inteiro: **as duas mensagens da mesma compra chegam à tela.**

**D32** mede o contador contra o fundo REAL da faixa — o creme do `StyleBox`, e
não o branco de um cartão de painel: **5,27:1**, onde o neutro do jogo daria
**2,82:1**. Seria a quarta vez que aquela cor mordia. O bloco inclui a prova de
que a régua sabe reprovar, senão um `_contraste` avariado daria verde com
qualquer cor.

Três mutantes, cada um sozinho e com controle positivo verde entre eles:

| # | Defeito injetado | Reprovou em |
|---|---|---|
| R5-M1 | perder a segunda entrada | T8 (4 asserções) e F8a |
| R5-M2 | interromper a atual antes do mínimo | **só o T8** |
| R5-M3 | agrupar textos diferentes | T8 e três blocos do F8 |

⚠️ **E O M2 SÓ CAI NUMA DAS DUAS SUÍTES, por construção.** O F8 drena a fila
com passos de 99 s — ele pergunta o que chega à tela, não quando —, e por isso
é cego ao tempo. Guardas de níveis diferentes veem defeitos diferentes: um
teste de aritmética pura apanha o que um de integração não tem como ver.

## O que ficou de fora

- **A ordem entre as duas fontes é o `kind`, e não um eixo novo de
  importância.** Inventar um seria uma segunda verdade a divergir da cor que a
  faixa já usa.
- **O histórico não diz QUEM falou.** Um rótulo de orador seria texto novo, e
  texto novo passa pela leitura em voz alta do Bruno (gate A4), não pela mão de
  quem escreve o painel.
- **O retrato do rodapé continua pendente do Bruno**, como a §7.1 manda.
