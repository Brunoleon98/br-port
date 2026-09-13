# 019 — O desconto por antecipação é proporcional ao tempo, não fixo

**12/09/2026 · item 24 do segundo playtest · decidido pelo Bruno**

## O pedido

> *"Quitar a dívida antes pode diminuir o valor a ser pago nela, não precisa
> ser um desconto muito grande, mas é legal se tiver um desconto já que teria
> menos juros."*

Até aqui `pagar_parcela_adiantado()` cobrava o principal cheio, e o comentário
dela afirmava que um desconto *"mexeria na economia medida"*. **Medido, não
mexe** — e essa afirmação era suposição, escrita antes de existir instrumento
para a testar.

## O que se mediu antes de decidir

O instrumento é o quarto perfil do simulador, **Antecipado** (clone exato do
Mediano mais a antecipação), construído em 11/09 para o vão ser atribuível. As
600 partidas, semente 20260825, EXIT=0 em todas:

| `JUROS_POR_TURNO` | Ótimo | Mediano | Descuidado | Antecipado | antecipou | turno (mediana) |
|---:|---:|---:|---:|---:|---:|---:|
| — (sem desconto) | 100,0% | 80,2% | 37,3% | 80,2% (481) | 399 | 30 |
| 0,10%/turno | 100,0% | 80,2% | 37,3% | 80,2% (481) | 399 | 30 |
| **0,25%/turno** | **100,0%** | **80,2%** | **37,3%** | **80,2% (481)** | **399** | **30** |
| 0,35%/turno | 100,0% | 80,2% | 37,3% | 80,2% (481) | 399 | 30 |
| 0,50%/turno | 100,0% | 80,2% | 37,3% | **80,7% (484)** | **403** | **29** |

**Os três perfis antigos ficam idênticos AO DÍGITO em todas as taxas**, e isso
não é sorte: eles nunca resolvem senão a fase `debt_payment`, logo nunca passam
por esta porta. É a prova de isolamento que o instrumento existe para dar.

## A leitura

**A fronteira está entre 0,35% e 0,50%, e o mecanismo é uma realimentação.** O
desconto baixa o limiar de `pode_pagar_parcela_adiantado()`; o jogador cruza-o
mais cedo; antecipar mais cedo desconta mais. A 0,50% isso chega para adiantar
a mediana um turno inteiro (30 → 29) e render 3 vitórias. Abaixo disso o efeito
não tem força para mover o turno, e sem mover o turno não há o que realimentar.

**E o desconto VALE mais do que a mediana sugere.** A margem em regime do
Antecipado sobe de R$154.537 para **R$160.823** — +R$6.286, contra os R$2.650
que dois turnos de antecipação valem. A diferença é a cauda: a mediana antecipa
no turno 30, mas há partidas que antecipam muito antes, e são elas que recebem
o abatimento a sério.

## A decisão

**`JUROS_POR_TURNO = 0.0025`** — 0,25% do principal por turno antecipado.

**Proporcional, e não fixo.** A forma sai do próprio pedido (*"já que teria
menos juros"*): o abatimento é o juro que o banco deixa de correr, logo depende
do TEMPO. Um desconto fixo foi rejeitado pela distribuição, que é a mesma razão
da `008`: o Ótimo fecha com R$1.309.646 em caixa e levaria o abatimento de
graça, enquanto o Mediano só cruza a parcela no fim e quase nunca o veria —
botão que só move quem não precisa dele.

**Por que 0,25% e não 0,35%, se as duas medem igual.** Pelo TETO, que é o que
distingue as duas: ao longo do prazo inteiro (31 turnos) elas valem 7,75% e
10,85% do principal. 7,75% lê-se como juro de banco pequeno; acima disso
entra-se na faixa que este projeto já rejeitou por escrito ao recusar chamar
EMPRÉSTIMO ao caixa inicial — aquilo poria "o banco a cobrar 32,5% em quatro
semanas", e a `018` guardou isso como razão. E o teto **cresce com o prazo**:
uma Fase 2 que estique a partida empurra esta conta sozinha para cima, e os
0,25% deixam a folga para isso acontecer sem atravessar a fronteira medida.

## A conta é genérica, e isso é pedido

O Bruno pediu que ela sirva também ao empréstimo bancário mais adiante. Por
isso `desconto_por_antecipacao(principal, turnos)` recebe os dois em vez de os
ir buscar às constantes da parcela: uma versão que lesse `PARCELA_AMOUNT` por
dentro teria de ser copiada para lá, que é como duas contas da mesma coisa
começam a divergir neste arquivo. **A asserção 7c existe só para isso** — nada
mais no projeto lhe passa um principal diferente, então sem ela a função podia
ser "simplificada" de volta sem que nenhuma suíte soubesse.

## Duas armadilhas que a sessão pagou

**A guarda duplicada.** O piso em zero nasceu em dois sítios — na conta do
desconto e na dos turnos. Com a cópia de pé, tirar qualquer uma não reprovava
nada, que é a armadilha escrita no `CLAUDE.md`. Ficou num lugar só, e é a
asserção 7a que a exerce.

**O defeito que não pode existir.** Passar o valor descontado à porta do
vencimento — o engano óbvio, e o primeiro que se injetou — **não muda um
centavo**: em `debt_payment` o turno é sempre `DUE + 1`, e o piso zera o
desconto. As duas versões são a mesma conta naquele estado. O defeito não
reprovou, e não por falha do teste; a asserção 7d passou a guardar o que É
possível, que é a porta do vencimento cobrar um valor diferente do principal.

## O que ela envelheceu

O `JUROS_POR_TURNO` é a **primeira constante pequena do projeto**, e ao entrar
na tabela dos números saiu como `0.` — o formatador fixava `"%.2f"` e depois
fazia `rstrip("0")`, comendo os zeros que ERAM o número. Defeito anterior a
esta sessão, que nunca mordera por falta de um valor abaixo de 0,005. As casas
passaram a sair do valor, e entrou a guarda que o teria apanhado: **valor que
não relê como era depois de formatado reprova**, em vez de ir mudo para o
markdown.

## E ela destapou dois buracos na bateria de evidência

A regra 5 do `CLAUDE.md` obriga a OLHAR o que mudou de visual, e tentar olhar
este painel mostrou que ele era **incapturável**, em silêncio:

1. **O `capturar_cena.gd` só chamava `setup()` quando havia argumentos extra.**
   Os quatro painéis de `setup()` sem argumento obrigatório — Calendário,
   Docas, Parcela, Reputação — saíam como um escurecer vazio que imprimia
   "Tela salva em" e passava por bom. O Diário escapou por montar no
   `_ready()`, que é porque ninguém tinha reparado.
2. **E a cena herdava o autosave da foto anterior.** O `GameState._ready()`
   tenta `load_game()` antes de `new_game()`, e a bateria tira as fotos de jogo
   primeiro — que gravam. O painel dizia "R$498.200 são menos de uma das
   estruturas que faltam" com as sete já construídas pelo save alheio. Hoje a
   ferramenta parte de `clear_save()` + semente + `new_game()`, como o
   `capturar_tela.gd` já fazia, e **duas corridas da bateria devolvem os mesmos
   bytes nas onze imagens** — que é a prova, e não a intenção.

A captura entrou na bateria do CI com o estado montado de propósito
(`turn=8 cash=900000`): um `GameState` novo está no FIM do prazo, onde o
desconto é zero por construção, e a foto sairia verdadeira e sobre outra coisa.
