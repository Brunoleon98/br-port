# 005 — O jogo é tranquilo, e a dívida não é o motor

**Data:** 02/09/2026 · **Decisão de:** Bruno · **Estado:** fechada

> Fecha a pergunta que a errata da economia deixou explicitamente em aberto
> desde 01/09, e que bloqueava codar a economia da Fase 2.

---

## A pergunta

A projeção das Parcelas 2 e 3 mostrou que **a receita cresce mais depressa do
que a dívida**, nas duas passagens de fase:

| | Fase 1 | Fase 2 | Fase 3 |
|---|---:|---:|---:|
| Valor médio de contrato | R$184 | R$536 (×2,9) | R$1.367 (×2,5) |
| Parcela | R$8.000 | R$16.000 (×2,0) | R$24.000 (×1,5) |

As Parcelas 2 e 3 fecham com 2,2× e 4,5× de folga no cenário conservador. A
Fase 1 mede 47% de vitória para o jogador mediano — é apertada de propósito — e
**a partir da semana 5 a parcela deixa de pressionar**.

A errata listou três saídas: subir as parcelas, deixar assim de propósito, ou
trocar o que pressiona.

## A decisão

**Deixar assim, de propósito — e trocar o que pressiona.**

Nas palavras do Bruno: *"o jogo deve ser mais tranquilo do que desafiador,
tendo mais desafios de expansão e manutenção do que sobreviver a uma dívida."*

## O que isto quer dizer, em concreto

**A dívida é o motor da Fase 1 e mais nada.** Ela existe para dar ao começo uma
razão para correr — o porto está em ruínas e há um prazo. Cumprida a Parcela 1,
o jogo deixa de ser sobre sobreviver.

**O motor das fases seguintes é a EXPANSÃO e a MANUTENÇÃO.** A pergunta deixa
de ser *"consigo pagar?"* e passa a ser *"o que construo primeiro, e como o
mantenho de pé?"* — que é a fantasia que o GDD descreve desde o início:
levantar um porto, não administrar uma falência.

**Não é o mesmo que tirar a dificuldade.** Um jogo tranquilo não é um jogo sem
decisão: é um jogo em que a decisão errada custa TEMPO e OPORTUNIDADE, não a
partida. O jogador não perde o porto por escolher mal — ele chega ao fim da
fase com menos porto do que podia ter.

## As consequências, que não são pequenas

1. **A Parcela 3 não sobe.** O card do GDD que mandava escolher entre pôr o
   armazém a render desde a semana 2 ou baixar a Parcela 3 para R$18.000 já
   tinha perdido o motivo; agora perde-o duas vezes.

2. **A Fase 1 deixa de ser o alvo de 47%.** Aquele número foi calibrado para
   uma fantasia de sobrevivência que esta decisão substitui. O alvo novo tem de
   ser medido e escrito — enquanto não estiver, o `CLAUDE.md` continua a
   afirmar 100% / 47% / 0%, que passou a ser história e não meta.

3. **Custo de estrutura e de manutenção passam a ser onde o jogo morde.** Se a
   dívida não pressiona, são eles que têm de fazer o jogador escolher. Uma
   estrutura tem de custar o suficiente para não se comprarem todas.

4. **Perder tem de continuar possível.** Caixa negativo ainda encerra a
   partida. Tranquilo não é impossível de perder — é difícil de perder por
   azar, e possível de perder por desatenção continuada.

## O alvo novo, medido no mesmo dia

600 partidas por perfil, semente 20260825:

| Perfil | Vitórias | Mediana no vencimento | Barcos atendidos | Em regime |
|---|---:|---:|---:|---:|
| Ótimo | **100%** | R$1.054.343 | 46,3 | 13,8/sem |
| Mediano | **79,5%** | R$685.271 | 35,5 | 11,4/sem |
| Descuidado | **35,7%** | R$519.720 | 12,5 | 3,3/sem |

> ⚠️ **Esta tabela é de 02/09 e continua a ser o que se mediu então.** Em
> 05/09 os dois upgrades de guindaste e cais entraram (`docs/decisoes/007`) e
> o Descuidado passou a **31,0%**; os outros dois perfis ficaram onde estavam,
> e o vão em barcos atendidos abriu de 46,3 × 12,5 para 56,2 × 12,6.
>
> ⚠️ **E em 06/09 o motivo da escala entrou** (`docs/decisoes/008`), com a
> parcela a descer para **R$530.000** para devolver ao Descuidado os ~35% que
> esta decisão registou. O que está em vigor é **99,8% · 80,5% · 35,2%**, com
> 50,5 / 38,1 / 12,1 barcos atendidos. Duas afirmações desta página passaram a
> ter exceção medida, e estão na 008: o teto de 100% do jogo perfeito (uma
> partida em 600 constrói tudo num porto que não rende e chega curta) e o vão
> em barcos, que encolheu de 43,6 para 38,4 — é o preço do turno extra do
> granel.
>
> ⚠️ **E em 06/09 a trava do nível de navio entrou** (`docs/decisoes/009`). O
> que está em vigor é **100% · 80,2% · 37,3%**, com o teto de 100% de volta.
> **A frase mais importante desta página mudou de métrica:** "quem separa os
> jogadores é o porto que conseguem levantar" mede-se agora pela MARGEM em
> regime (R$674.019 contra R$103.290), e não pela contagem de barcos — o porto
> pobre só recebe pesqueiro, descarrega num turno e chega a atender MAIS barcos
> do que o rico.

Contra uma Parcela 1 de R$550.000 — que é o número desta medição de 02/09. É a forma que a decisão pede: o mediano
ganha quatro em cada cinco — tranquilo —, e o descuidado perde duas em cada
três, sem que perder seja garantido.

**A parcela é o botão que move isto**, e foi medido nos três valores:

| Parcela | Ótimo | Mediano | Descuidado |
|---|---:|---:|---:|
| R$600.000 | 100% | 69,5% | 11,7% |
| **R$550.000** | **100%** | **79,5%** | **35,7%** |
| R$500.000 | 100% | 88,2% | 60,7% |

> Esta tabela é do porto de 02/09, sem upgrades e sem motivos. **O botão
> continuou a ser o mesmo nas duas vezes em que se mexeu no jogo desde então**,
> e em 06/09 mediu-se por que ele funciona: o Mediano e o Descuidado não estão
> na mesma parte da distribuição, e a parcela só move quem está em cima da
> linha (`docs/decisoes/008`).

## E o que a decisão mudou na forma de ler o balanceamento

**A taxa de vitória deixou de ser o número que interessa.** Se a dívida não é o
motor, quase toda a gente a paga — e a diferença entre jogar bem e jogar mal
deixa de aparecer ali. Ela aparece no PORTO: 46,3 barcos atendidos contra 12,5,
e 13,8 por semana em regime contra 3,3. É esse o eixo em que o jogo passa a ser
medido, e quem olhar só a taxa de vitória vai concluir que o jogo não tem
dificuldade nenhuma.
