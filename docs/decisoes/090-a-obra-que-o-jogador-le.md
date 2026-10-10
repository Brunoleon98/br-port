# 090 — A obra que o jogador lê

**10/10/2026.** Main `46e06da` (PR #113, o M2, fundido; nenhum PR aberto do
Codex); 090 livre conferida na main antes de escrever. É o **M3** da fila de
`docs/REVISAO_GERAL_2026-10-09.md` (§6), com o achado O5 da revisão do PR #110
e a resposta do Bruno ao **D8**.

## A resposta do Bruno ao D8

A pergunta: a obra começada no dia 83 (o pátio no 82) é aceita pela `087`,
cobrada inteira, e só fica pronta no fecho do dia 84 — a mensagem dizia
«pronto no dia 85» numa fase de 84 dias, e o jogador pagava por um porto que
não usava. Avisar ou recusar?

**«Por enquanto avisar, mas no futuro o jogo deve ter anos de 365 dias, então
apenas passará para o próximo dia.»**

Logo a regra da `087` fica, e o aviso é provisório por natureza: quando o
calendário deixar de acabar no dia 84, a obra assim conclui no dia seguinte
como qualquer outra, e o `obra_sem_uso_na_fase()` perde a razão de existir. O
comentário dele diz isso, para ninguém lhe acrescentar casos.

## O que mudou

- **`prazo_da_obra(conclusao)`** no `GameState` é o prazo como o jogador o lê,
  num lugar só: «pronto no dia N», ou, quando `conclusao > TURNS_TOTAL`,
  «pronto só no fim do dia 84, e não será usado nesta fase». O 84 sai da
  constante. Três leitores: a mensagem da compra e os dois estados do
  Construir.
- **No Construir, antes de comprar**, o cartão ganha a linha «Fica pronto só
  no fim do dia 84, e não será usado nesta fase.», em `RotuloAlerta` — o âmbar
  escurecido do tema, 5,06:1 no cartão. Com a obra a andar a mesma frase vai no
  tom de apoio: aí já é informação, e o âmbar fica onde muda uma decisão.
- **A mensagem** usa o mesmo texto e passa a `warn`: a faixa fica âmbar e toca
  o aviso, em vez do verde de quem comprou bem.
- **Os «%d dias» passam pelo `Narrativa.concordar`** (`037`). A busca pela
  FORMA — `%d` seguido de palavra no plural — achou, além dos dois sítios que a
  revisão nomeou, mais quatro: o «parte em %d dias» do cartão da fila, o «%d
  de %d quitadas» do HUD, o recibo do fim e o «%d DE %d BERÇOS» do painel das
  docas. Todos certos hoje só porque o número nunca era 1 ali. Mais um ternário
  que escolhia a palavra inteira — `"disponível" if n == 1 else "disponíveis"`,
  no rodapé do Construir —, que o F9 dizia caçar e não caçava. Todas as
  conversões dão o mesmo texto que antes.

## A prova

**F9, alargado.** Reprova `%d` seguido de palavra no plural, em minúsculas
(o painel das docas escrevia em caixa alta), fora o partitivo («%d das») e
fora quem fala com quem desenvolve (`scripts/validation/` e o `.jsonl` do
`Registro`). E reprova o ternário de palavra inteira. As duas expressões
provam-se antes de varrer, com um caso que casa e um que não.

**F18, novo, relacional.** O último dia de compra de cada reparo sai do
`impedimento_estrutura()`, andando o calendário de trás para a frente — nunca
um 83 escrito. Pela porta do jogador (o botão do cartão) e dos dois lados da
fronteira:
- no último dia, o Construir avisa em âmbar, a mensagem avisa em `warn`, o
  cartão da obra a andar continua a avisar, nenhum diz «dia 85» — e o aviso é
  VERDADE: no dia 84 a estrutura não está de pé, e fica no fecho dele;
- na véspera, nada avisa, e o «pronto no dia N» da mensagem é o mesmo do
  cartão e o dia em que a estrutura fica de pé, lido no jogo.

**A régua do contraste** ganhou o caso «Construir (obra sem uso na fase)»,
com a prova do texto no nó: o percurso abre no dia 1 e nunca chegaria ao âmbar.

Dezassete mutantes, todos a reprovar menos o que prova que a guarda nova faz
falta:

| Mutante | Quem reprova |
|---|---|
| Construir de volta a «%d dias de obra» | F9 (plural fixo) |
| mensagem de volta a «%d dias» | F9 (plural fixo) |
| prazo de 1 dia com a forma antiga | F9 (plural fixo) |
| expressão do plural partida | F9 (a prova da expressão) |
| varredura sem minúsculas | F9 (a prova da expressão) |
| painel das docas de volta a «%d BERÇOS» | F9 (plural fixo) |
| sem a exceção do partitivo | F9 (a prova e o Parcela) |
| prazo sempre o dia cru | F18: 15 asserções |
| aviso um dia cedo (`>=`) | F18: só a véspera |
| Construir sem o aviso | F18: antes de comprar |
| mensagem sempre `good` | F18: o tom |
| obra a andar com o dia cru | F18: o cartão a andar |
| **dia prometido um antes, nos dois leitores** | **só o F18 «de pé no dia N»** |
| aviso em tom de apoio | F18: o âmbar |
| rodapé de volta ao ternário | F9 (ternário) |
| expressão do ternário partida | F9 (a prova da expressão) |
| ternário com a guarda velha | **passa** — a guarda antiga não o via |

O do dia prometido um antes é o que sustenta a prova relacional: a mensagem e
o cartão concordavam um com o outro, e só o jogo os desmentia. E o controle
positivo: com o prazo do píer a 1 dia e o código novo, o cartão diz «1 dia de
obra», a mensagem «1 dia; pronto no dia 2», e o F18 desloca sozinho a
fronteira para o dia 84 e passa.

## O O7, no mesmo PR

O rodapé do Construir dizia «3 disponíveis» nos dias 83 e 84, com o painel a
responder «Não termina nesta fase.» ao pátio (e no 84 aos três): contava o que
o `desbloqueio_da_estrutura()` abre, não o que se compra hoje. Achado nesta
sessão, levado ao Bruno como O7; ele pediu-o feito no PR sem dizer a regra, e
a escolhida foi a recomendação, que ele pode vetar antes de fundir:

- **«Disponível» é o que o CALENDÁRIO deixa comprar hoje** — aberto e ainda a
  terminar nesta fase. O `obra_termina_na_fase()` é essa condição num lugar
  só, lida pelo `impedimento_estrutura()` e pelo rodapé.
- **O dinheiro não conta.** Quem não pode pagar lê «Faltam R$…» no cartão; um
  rodapé que descesse a zero por falta de caixa esconderia que há reparo à
  espera.

**A prova** é um caminho do F18: dos dias da véspera do primeiro último dia ao
fim da fase, o número do rodapé tem de ser o número de botões «Construir ·»
que o PAINEL monta, com dinheiro de sobra — a segunda fonte é o painel, e não
a função que o rodapé lê. A contagem tem de mudar lá dentro (3, 3, 2, 0); e
com o caixa a zero o rodapé não desce. Três mutantes:

| Mutante | Quem reprova |
|---|---|
| rodapé só pelo calendário (o defeito) | F18 rodapé, dias 83 e 84, e «a contagem muda» |
| rodapé a contar o dinheiro | F18 rodapé, só a conferência sem caixa |
| «termina na fase» um dia mais cedo | o F18 da obra sem uso (12 asserções) — é a regra «recusar» do D8 |

**Como se mediu depressa:** um script de bancada que estende o
`teste_fumaca.gd` e troca o `_rodar()` por só os blocos em causa corre em
menos de um segundo, contra minutos da suíte inteira. Os mutantes corriam
sobre os originais guardados com `cp`, restaurados e conferidos byte a byte
entre um e outro, e a suíte inteira correu outra vez no fim.

## O que fica de fora

- O aviso não fala de dinheiro: a obra do dia 83 sai do caixa na véspera da
  terceira cobrança. É verdade de toda compra antes de um vencimento, e a
  barra da parcela já o mostra.
- O calendário de 365 dias é rumo, não recorte desta fila.
