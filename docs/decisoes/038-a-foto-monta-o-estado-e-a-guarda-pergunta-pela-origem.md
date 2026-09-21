# 038 — A foto monta o ESTADO, e a guarda pergunta pela ORIGEM do erro

**21/09/2026 · item FORA da §7.1, descoberto pelo R7 e pelo R8 · origem:
`docs/decisoes/036` e `037`, os dois achados que elas registaram sem corrigir**

## O que fez esta sessão existir

O R7 mexeu na cor do Construir e do Calendário, e o R8 na contagem que o
Docas e o Caixa escrevem. **Nenhum dos quatro tinha foto nenhuma** — as duas
sessões olharam à mão, fora da bateria, o que não deixa antes/depois no PR e
não se repete sozinho. A regra 5 do `CLAUDE.md` manda tirar uma captura e
olhar quando se mexe no visual; esta sessão é essa captura.

## ⚠️ E ERAM SETE PAINÉIS, NÃO CINCO

O briefing contou **treze telas** — oito com tiro e cinco sem. Contado no
disco são **quinze**, e as duas que faltavam à conta não faltam por descuido:

| Painel | Por que escapou a todo inventário |
|---|---|
| `TelaNomes` | o `capturar_tela.gd` chama `definir_nomes()` **de propósito** para a dispensar: ela ficaria por cima de tudo o que se queria fotografar. Quem procurasse a primeira tela do jogo nas fotos de jogo nunca a acharia, e a razão está escrita no código que a esconde |
| `EndGame` | **não vive em `scenes/panels/`** — está em `scenes/EndGame.tscn`. Todo inventário que olhe a pasta perde-o, e foi o que aconteceu |

É a regra do `CLAUDE.md` outra vez: *antes de herdar o buraco que um briefing
anuncia, pergunte a que fonte ele o perguntou, e pergunte à outra.* O briefing
mandava conferir a `TelaNomes` — e ninguém, em sessão nenhuma, tinha contado o
`EndGame`, que é o painel com mais história por fotografar deste projeto (deu
430 px a um texto que pede 847, e o D22 tranca-o desde 11/09).

Hoje são **24 tiros** e os quinze painéis têm foto.

## A decisão 1 — os cinco vão pelo JOGO, e não pela cena solta

Os outros painéis da bateria são fotografados por `capturar_cena.gd`, que
instancia a cena sozinha. Para estes cinco isso não serve, e a razão é o
ESTADO: uma cena solta nasce numa partida **recém-criada**, e é exactamente aí
que estes painéis não dizem nada.

| Painel | O que a partida nova dá | O que o painel tem de dizer |
|---|---|---|
| Construir | porto em ruínas: nenhum cartão verde | os TRÊS estados de cartão |
| Calendário | dia 1: nenhum dia passado | a cor dos dias já vividos |
| Docas | uma doca: contagem nunca passa de 1 | plural, que a 1 não se vê |
| Caixa | `dia_anterior` vazio | "o primeiro dia ainda não fechou" |
| Reputação | 65,0, o patamar de partida | que o "▸" ANDA |

⚠️ **E ESCREVER O ESTADO À MÃO SERIA FINGI-LO.** O `capturar_cena.gd` sabe
escrever campos (`turn=9`), e com isso dava para pôr o calendário no dia 10 —
com o caixa, a reputação e o `dia_anterior` parados no dia 1. A foto seria
verdadeira no rótulo e falsa no resto. **Uma partida JOGADA deriva os cinco de
uma vez**, que é a regra desta bateria desde que os R$100.000 cravados saíram
do `capturar_tela.gd`.

Daí a opção nova `--painel=<nome>`, com a tabela `PAINEIS`: cada painel abre
**pela porta do jogador** — a mesma pílula do HUD que ele toca, com o
`_e_toque_de_soltar` do `Main` pelo meio —, como o histórico da faixa já fazia.

E há uma terceira razão, que é de guarda: os tiros de `capturar_cena.gd`
passam `- -` porque aquela ferramenta não imprime a linha `Overlay:`. Por aqui
cada um dos cinco **declara quantos painéis aceita e em que turno pára**, como
os tiros de mapa.

## A decisão 2 — o `Dictionary` do `PainelCaixa` não se escreve: o jogo passa-o

O `setup()` dele exige um `Dictionary`, e a linha de comando não sabe escrever
um: o `capturar_cena.gd` chamava-o com zero argumentos, o painel não montava, e
a ferramenta **imprimia "Tela salva em" e saía com código 0** com uma foto
PRETA (`037`).

Havia duas saídas — inventar uma sintaxe de dicionário para a linha de comando,
ou dar-lhe um tiro próprio. A primeira é fingir o estado; a segunda resolve-o
por construção, porque quem chama o `setup()` passa a ser o
`_on_caixa_pilula_input` do jogo, com `GameState.resumo_do_dia()`. **A porta do
jogador entrega o argumento que a linha de comando não sabia escrever.**

## A decisão 3 — a guarda pergunta pela ORIGEM, e quem a escreve é o Godot

O `tirar()` varria por `SCRIPT ERROR|at: push_error \(`, e esse par conhece
duas formas de erro de três. A do `PainelCaixa` é a terceira:

```
ERROR: Error calling method from 'callv': ... Method expected 1 argument(s), but called with 0.
   at: callv (core/object/object.cpp:888)
   GDScript backtrace (most recent call first):
       [0] _chamar_setup (res://tools/capturar_cena.gd:134)
```

`ERROR:` sem `SCRIPT`, e `at:` a apontar para C++ — porque quem se queixa é o
MOTOR sobre uma chamada que o NOSSO script fez. **Nenhum dos dois padrões
casava**, e a foto preta seria anexada ao PR com a bateria verde.

O `CLAUDE.md` avisa dos dois lados: um `grep ERROR` cru reprovaria suítes
verdes, e o escopo da guarda é o escopo do defeito. Medido, uma sonda por
forma, nesta versão do Godot (4.6.3):

| Origem | Prefixo | `GDScript backtrace`? |
|---|---|---|
| `push_error()` | `ERROR:` | **sim** |
| erro de execução (chamada em `null`) | `SCRIPT ERROR:` | **sim** |
| erro de COMPILAÇÃO (parse) | `SCRIPT ERROR:` | não — `at: GDScript::reload` |
| chamada falhada (`callv`) | `ERROR:` | **sim** |
| recurso que não carrega | `ERROR:` | **sim** |
| ruído de encerramento (`resources still in use`) | `ERROR:` | não — `at:` em C++ |

O par novo é **`SCRIPT ERROR|GDScript backtrace`**: o primeiro apanha o que não
chega a correr, o segundo apanha tudo o que correu e se queixou. O
`at: push_error \(` saiu por ser **subconjunto** do segundo — medido na sonda,
não suposto —, e a regra deste projeto é apagar a cópia.

⚠️ **E A BASE MEDIDA É QUE O AUTORIZA:** nas 17 corridas saudáveis de antes
desta sessão, os logs da bateria **não têm uma linha `ERROR` sequer**. Isto não
é a suíte, onde cinco das seis encerram com `resources still in use at exit`.

⚠️ **E O ALARGAMENTO PÁRA NA BATERIA.** O `testes.yml` e o `balanceamento.yml`
ficam com o par antigo, e é MEDIDO: o `teste_fumaca` imprime um erro de JSON de
propósito — o save inválido que ele injeta para provar que o jogo o recusa — e
esse erro **traz backtrace**. Contado no log dele: o padrão novo casa 1 linha e
o antigo casa 0. Levar o alargamento para lá punha uma suíte verde a vermelho.

## ⚠️ A quarta forma de falhar, que não estava prevista: NÃO ACABAR

A construir um mutante, a bateria **ficou pendurada** — sem log, sem foto e sem
uma palavra. A causa: uma chamada com o número errado de argumentos dentro do
`_process` de um `SceneTree` ABORTA a função, e um `--script` que aborta antes
do `quit()` repete o `_process` a cada frame e nunca encerra. É a irmã da regra
que o `capturar_tela.gd` já regista para o laço de turnos (*"uma sonda escreveu
11 MB de log em dois minutos"*), um andar acima: ali o teto é de voltas, aqui
não havia teto nenhum.

No CI isso não seria vermelho — seria o job inteiro a morrer de timeout, sem
dizer qual tiro foi. Cada tiro passou a ter `timeout 180`, que é sessenta vezes
o tiro típico (24 tiros em ~72 s) e folgado para o mais lento.

## Os mutantes

Sete, cada um sozinho, com a base exigida VERDE entre eles, a cópia guardada
com `cp` e não com `git`, e o código de saída lido **sem cano**.

| # | Defeito | Resultado |
|---|---|---|
| M1 | o `PainelCaixa` na bateria **pelo caminho velho** — `capturar_cena.gd` com `setup()` de zero argumentos | **reprovou o TIRO**, pela varredura de erro |
| M1b | o MESMO defeito, com o par ANTIGO de volta | o `tirar()` **passou**; quem reprovou, 23 tiros depois, foi a guarda do TAMANHO (6.347 bytes) |
| M2 | erro do motor pedido pelo nosso script (recurso que não carrega), numa foto de **513.539 bytes**, com `Overlay: 0` e turno 1 — os valores declarados | **reprovou**; nenhuma outra guarda podia |
| M2b | o MESMO defeito, com o par ANTIGO | bateria **VERDE**, 24 fotos entregues, com o erro escrito no log |
| M3 | `--painel=` com um nome que a tabela não tem | reprovou, e escreveu os nomes válidos |
| M4 | a porta do `Main` renomeada na tabela `PAINEIS` | reprovou, nomeando o método que mudou de sítio |
| M5 | o tiro que declara 1 painel e não abre nenhum | reprovou pela contagem: 1 contra 0 |
| M6 | a chamada que ABORTA o `_process` e pendura a ferramenta | reprovou em **180 s**, código 124, nomeando o tiro — sem o teto, pendurava para sempre |

⚠️ **O M1 E O M1b SÃO O PAR, e é o M1b que prova o alargamento.** A única
diferença entre os dois é o padrão do `grep`, e o defeito é o mesmo: com o par
novo reprova o TIRO, pela origem do erro; com o par antigo o `tirar()` passa
contente e quem reprova, vinte e três tiros depois, é a guarda do TAMANHO — e
só porque aquela foto calhou sair chapada. É a armadilha do *"confira QUAL
guarda está a segurar a asserção"*, com duas guardas a defenderem coisas
diferentes.

⚠️ **E O M2 EXISTE PORQUE O M1 SOZINHO NÃO CHEGA.** Ele injeta um erro do
motor numa foto de **513.539 bytes**, com a contagem de painéis e o turno
exactamente nos valores declarados: nem o tamanho, nem a contagem, nem o turno
podem apanhá-lo. Só a varredura de erro pode — e com o par antigo a bateria
sai **verde com o erro escrito no log**.

## O que fica de fora, dito

- **NENHUMA GUARDA PERGUNTA O QUE O PAINEL DIZ.** Um tiro com o estado errado —
  o Docas num turno em que a contagem é 1, o Calendário no dia 1 — não reprova
  coisa nenhuma: a foto sai, o turno bate, e o defeito é que ela não mostra o
  que se queria. O que separa uma foto boa de uma inútil continua a ser quem
  olha, e é por isso que o estado de cada tiro está escrito ao lado dele.
- **A secção "A PRÓXIMA DOCA" do `PainelDocas`** só existe com UMA ou DUAS
  docas, e aí a contagem volta a não passar de 1. As duas metades do painel não
  cabem no mesmo estado; escolheu-se a que o R8 mexeu.
- **O segundo tempo do `EndGame`** — o balanço — lê `GameState.metrics`, que
  numa cena solta é uma partida recém-criada: a foto diria "Barcos atendidos:
  0", e **zero lê-se como medida**. Fotografá-lo pede uma partida jogada até ao
  turno 32.
- **O impedimento por DINHEIRO do Construir** ("Faltam R$…") não aparece: o
  modo `meio` soma ao caixa o custo de todas as estruturas antes de comprar
  duas. O cartão bloqueado desta foto é-o pelo `requer`, e é o mesmo desenho.
- **NADA PERGUNTA SE UM PAINEL NOVO TEM FOTO**, e é o que fez esta sessão
  existir. Hoje os quinze estão cobertos, o que torna possível um portão sem
  exceção nenhuma — mas ele tem de reconhecer TRÊS formas de cobertura (o
  caminho da cena, o `--painel=`, e as bandeiras `pausa`/`mensagens`, a que se
  junta o Boletim, que não é chamada nenhuma: abre-se sozinho na virada da
  semana). É item próprio, e está desenhado no briefing seguinte.
