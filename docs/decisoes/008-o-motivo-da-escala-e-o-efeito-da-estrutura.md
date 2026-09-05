# 008 — O motivo da escala, e o efeito é da ESTRUTURA

**06/09/2026.** A nota estava na §7 do plano desde 05/09, fora da fila, com as
palavras do Bruno: *"uma nova mecânica onde os navios irão para o porto por
causa de diversos motivos, podendo ser reabastecimento, carga ou descarga de
materiais, reparos, e por aí vai"*.

Até aqui um barco tinha VALOR e TAMANHO e mais nada. `_make_boat()` sorteava
`large` e um valor na faixa, e servir era sempre a mesma operação: dois barcos
de R$45.000 pediam exatamente a mesma coisa ao jogador.

---

## A decisão

**Quatro motivos de CARGA E DESCARGA, cada um preso a uma estrutura que já
existe. Nenhuma estrutura nova, e nenhuma fase nova.**

| motivo | estrutura | efeito | peso pequeno | peso grande |
|---|---|---|---:|---:|
| Pescado | — | nenhum (é a base) | 55 | 0 |
| Armazenagem | `armazem` | +50% no valor | 45 | 35 |
| Contêiner | `patio` | +30% no valor | 0 | 40 |
| Granel | `guindaste` | **+1 turno** sem ele | 0 | 25 |

O motivo nasce com o barco, é gravado no save (`SAVE_VERSION` 6) e lê-se na
linha do progresso do cartão da doca.

---

## Por que reparo e reabastecimento ficaram de fora

**Porque são a Fase 2, e o GDD di-lo com todas as letras.** A fase 02 chama-se
*"Cais com Oficina — Reparo de barcos"* e exige *"oficina naval + 2 docas"*; o
combustível marítimo, na lista de cargas, *"exige posto de abastecimento —
primeiro upgrade de infraestrutura"*. Nenhuma das duas existe no VS.

Inventá-las aqui seria codar a economia da Fase 2 **antes** de responder a
pergunta que a `BR_Port_GDD_V7_ERRATA_ECONOMIA.md` deixou explicitamente em
aberto e que o Bruno adiou de propósito em 03/09. A regra que ele deu ao abrir
esta sessão era essa: *"se a mecânica encostar na economia da Fase 2, PARE e me
pergunte antes"*. Perguntou-se, e a resposta foi ficar na carga e na descarga.

**O que fica escrito para quando a Fase 2 abrir:** a oficina e o posto entram
como estrutura, e o motivo delas entra nesta mesma tabela — a máquina já está
de pé, e o que falta é a estrutura, não o motivo.

## Por que o efeito é da ESTRUTURA e nunca do motivo sozinho

Um motivo que pagasse mais **por si** seria outro sorteio de valor com um nome
bonito por cima: o jogador veria a etiqueta mudar e não teria nada que decidir.
Preso à estrutura, o motivo diz **onde gastar o próximo dinheiro** — e o cais
reforçado, que empurra a mistura para o navio grande, passa a decidir também
QUAIS motivos aparecem. A cadeia inteira é essa, e ela mede-se:

| perfil | Pescado | Armazenagem | Contêiner | Granel |
|---|---:|---:|---:|---:|
| Ótimo | 23,4% | 39,4% | 22,8% | 14,5% |
| Mediano | 25,3% | 39,5% | 21,7% | 13,5% |
| Descuidado | 32,8% | 41,2% | 16,2% | 9,9% |

Nenhum peso muda entre os três. O que muda é o **cais**: quem o compra vê um
terço mais contêiner e metade mais granel. O porto que o jogador levanta decide
que porto ele vê.

**E o armazém deixou de ser +20% em tudo.** Ele valorizava também o peixe que
sai do cais direto para o mercado, o que um armazém não faz. Hoje paga +50% no
barco que vem deixar carga — a mesma quantidade de dinheiro dita de um jeito
que se lê no cartão e na linha própria do Boletim.

**E o granel paga em TURNO, não em dinheiro.** Quatro motivos que fossem quatro
multiplicadores seriam o mesmo motivo quatro vezes. O granel ocupa o berço um
turno a mais, e é esse o custo que o pórtico existe para pagar — o guindaste
ganhou um segundo trabalho, visível na tela, sem nenhuma constante nova.

---

## O balanceamento, medido

600 partidas por perfil, semente 20260825, em todas as linhas.

| configuração | Ótimo | Mediano | Descuidado | barcos Ó/M/D |
|---|---:|---:|---:|---|
| *antes — sem motivos, parcela 550k* | 100,0% | 79,5% | 31,0% | 56,2 / 41,1 / 12,6 |
| motivos, parcela 550k | 99,7% | 78,0% | 27,5% | 50,5 / 38,1 / 12,1 |
| motivos, granel 15, parcela 550k | 99,7% | 86,2% | 27,3% | 53,0 / 39,8 / 12,4 |
| motivos, bónus 0,65/0,40, parcela 550k | 99,8% | 84,3% | 26,7% | 50,9 / 38,5 / 12,1 |
| motivos, parcela 540k | 99,7% | 79,2% | 30,5% | 50,5 / 38,1 / 12,1 |
| **motivos, parcela 530k** | **99,8%** | **80,5%** | **35,2%** | **50,5 / 38,1 / 12,1** |
| motivos, parcela 525k | 99,8% | 81,0% | 36,8% | 50,5 / 38,1 / 12,1 |
| motivos, parcela 520k | 99,8% | 81,5% | 39,3% | 50,5 / 38,1 / 12,1 |
| motivos, granel 20, parcela 530k | 99,8% | 84,0% | 36,7% | 51,7 / 39,0 / 12,2 |

**⚠️ O MEDIANO E O DESCUIDADO NÃO ESTÃO NA MESMA PARTE DA DISTRIBUIÇÃO, e é
isso que faz a parcela funcionar como botão.** Cada R$10.000 valem ~3 pontos ao
Descuidado e ~0,5 ao Mediano — a mediana do Mediano fecha em R$745.875, muito
acima da parcela, e a do Descuidado em R$499.392, logo abaixo dela. Mexer na
parcela move quem está em cima da linha, e o Mediano não está.

**O peso do granel é o outro botão, e é o do Mediano.** De 25 para 15 ele salta
de 78,0% para 86,2% sem o Descuidado se mexer: reduzir o granel devolve vazão a
quem tem porto para a usar.

---

## O que fica FORA do alvo, e é honesto dizê-lo

**A vazão desceu, e é o preço do granel.** O Ótimo passou de 56,2 barcos
atendidos para 50,5, e o vão contra o Descuidado encolheu de 43,6 para 38,4 —
que é o eixo em que a decisão 005 diz que o jogo se mede. A causa é estrutural
e não se afina por preço: um motivo que custa um turno tira berço-turno do
porto inteiro, e quem tem mais berço perde mais. Trocar isso por um quinto
multiplicador devolveria os 56,2 e devolveria também um jogo em que servir é
sempre a mesma operação, que é o que esta decisão existe para acabar.

**E o jogo perfeito deixou de ganhar 100%.** Uma partida em 600.

> ✅ **VOLTOU AOS 100% em 06/09**, com a trava do nível (`docs/decisoes/009`):
> o porto que constrói tudo passou a receber navio melhor, e a obra paga-se.
> A exceção medida abaixo continua a ser o que se mediu neste estado do jogo.
 Foi
diagnosticada e não é ruído nem defeito: naquela partida o Ótimo levantou **as
sete estruturas** (R$1.055.000 de obra), serviu 32 barcos contra os 50,5 de
média, não perdeu nenhum, e chegou ao Sr. Ribeiro com R$210.616. É a armadilha
que a decisão 007 já tinha registado do outro lado — *"o diligente constrói
tarde demais"* —, agora com um sorteio mau em vez de um preço mau. A afirmação
da decisão 005 de que *"o teto está garantido"* passa a ter uma exceção medida,
e ela é jogável: construir tudo num porto que não rende continua a poder custar
a partida.

**E os ~35% do Descuidado voltaram, pelo botão que a 007 não tinha varrido.**
Ela percorreu preços de upgrade e concluiu, corretamente, que nenhum o
recuperava sem custar o Mediano. A parcela não estava no varrimento — e é ela
que separa os dois perfis, porque só um deles está em cima da linha.
