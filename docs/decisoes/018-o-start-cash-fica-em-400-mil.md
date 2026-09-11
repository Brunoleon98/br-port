# 018 — O `START_CASH` fica em 400.000, e a inversão prevista não existe

**11/09/2026.** O fecho do item **5a** da segunda jogada — *"caixa inicial
menor"* —, medido em sete pontos e 4.200 partidas. A resposta é **não mexer**,
e o que segue é por quê.

Nada aqui encosta na economia: o `GameState.gd` não mudou, e o `START_CASH`
está hoje exactamente onde estava. O balanceamento continua **100% / 80,2% /
37,3%**, com a parcela em R$530.000.

**O item 5 eram dois pedidos e este era o de economia.** O outro — **5b**,
chamar EMPRÉSTIMO aos 400.000 — não mexe em número nenhum, e é ele que responde
de frente à queixa que gerou os dois (*"é estranho o porto ter dívida mas o
jogador começar com 400.000"*, playtest 1, nº 1), que era sobre ESTRANHEZA e
não sobre dificuldade. Continua por fazer.

---

## 1. A medição

`START_CASH` ∈ {400, 360, 320, 300, 250, 200, 150} mil, 600 partidas por perfil,
**semente 20260825** nas sete, tudo o resto fixo. A tabela crua está na §7 do
plano. Contra os quatro critérios que a F1 escreveu:

| `START_CASH` | 1 · ordem | 2 · Ótimo ≥ 99% | 3 · banda de `005` (~80% / ~35%) |
|---:|:---:|:---:|:---|
| **400.000** | ✅ | ✅ 100,0% | ✅ **80,2% / 37,3%** |
| 360.000 | ✅ | ✅ 99,7% | ❌ 63,5% / 17,2% |
| 320.000 | ✅ | ✅ 99,3% | ❌ 46,8% / 6,8% |
| 300.000 | ✅ | ✅ 99,2% | ❌ 37,8% / 3,5% |
| 250.000 | ✅ | ❌ 95,8% | ❌ 2,0% / 0,7% |
| 200.000 | ✅ | ❌ 86,5% | ❌ 0,5% / 0,2% |
| 150.000 | ✅ | ❌ 58,7% | ❌ 0,0% / 0,0% |

**O único ponto que cumpre os critérios é a linha de base.** A pergunta da F1
era *"quanto pode o `START_CASH` cair antes de a banda partir?"*, e a resposta
medida é **nada**: ela parte no primeiro passo. R$40.000 a menos — 10% — custam
**16,7 pontos** ao Mediano e **20,1** ao Descuidado, com margem de erro de ±3,2
e ±3,9. Não é sorteio.

Para comparar: a parcela, que é o botão registado em `008`, vale ~3 pontos ao
Descuidado e ~0,5 ao Mediano por R$10.000. O `START_CASH` vale **4,2 e 5,0**, e
move os dois. Não é um botão fino — é a distribuição inteira a deslizar.

## 2. Por que a taxa de vitória se comporta assim

A taxa é **a fração da distribuição do caixa que fica acima dos R$530.000 da
parcela**, e a mediana diz onde está o centro dela. Vale a conta:

| perfil · ponto | mediana | folga sobre a parcela | taxa |
|---|---:|---:|---:|
| Mediano · 400.000 | 716.179 | +186.179 | 80,2% |
| Mediano · 360.000 | 599.031 | +69.031 | 63,5% |
| **Mediano · 320.000** | **517.652** | **−12.348** | **46,8%** |
| Mediano · 300.000 | 494.336 | −35.664 | 37,8% |
| Descuidado · 400.000 | 503.039 | −26.961 | 37,3% |

A 320.000 a mediana do Mediano assenta EM CIMA da parcela e a taxa dá 46,8% —
metade, como tem de dar. É a mesma leitura de `008` para o Descuidado, que já
lá estava: a mediana dele fecha logo abaixo da parcela, e é isso que produz os
35% do alvo de `005`.

## 3. A inversão prevista não veio, e sabe-se porquê

A F1 previu, com todas as letras, que abaixo do penhasco *"a dificuldade
INVERTE (Descuidado 51,7% contra Mediano 13,8%)"*. **A varredura atravessou o
penhasco em cinco pontos e a ordem nunca inverteu** — nem na taxa, nem na
margem, nem num único par.

A previsão saiu da `/balancear`, que regista a inversão a sério. Só que ela foi
medida **noutro eixo**: encarecendo as ESTRUTURAS com o caixa inicial parado.
São duas coisas diferentes, e é a diferença inteira:

| | encarecer a estrutura | baixar o `START_CASH` |
|---|---|---|
| razão `caixa / custo` | piora | piora |
| caixa absoluto contra a parcela | **não mexe** | **desaba** |

A inversão precisa de um acumulador que TENHA o que acumular: o cauteloso não
constrói, guarda os 400.000 e chega aos 530.000. Baixando o caixa inicial ele
continua a não construir — e chega ao vencimento com 304.000. Não há inversão
porque não há acumulação. O segundo eixo domina o primeiro.

## 4. E o penhasco também não estava onde a tabela dizia

A F1 pôs o penhasco em 320.000, pela conta `caixa >= custo × folga` com o
escritório a R$80.000 e a folga 4× do Descuidado. Medido, a fração de partidas
em que ele levanta o escritório é:

`100% · 100% · 100% · 100% · 100% · 98% · 86%`

Suave, sem degrau nenhum, dos 400.000 aos 150.000. **A conta responde pelo
TURNO 1 e o jogo tem 32**: o perfil acumula receita e compra no turno 9 em vez
de no 1. Um limiar de compra só vira penhasco quando a partida acaba antes de
o perfil poupar a diferença.

O penhasco real existe, mas é **do Mediano e fica entre 300.000 e 250.000** —
e é o porto que desaba, não a carteira:

| | 300.000 | 250.000 |
|---|---:|---:|
| cais | 100% | 88% |
| armazém | 100% | 45% |
| píer 3 | 65% | **1%** |
| chegou ao nível 3 | 100% | 88% |
| docas médias | 2,65 | 2,01 |

## 5. E não há ganho no eixo que a `009` privilegia

`009` diz que quem discrimina os perfis é a **margem em regime**, não a
contagem de barcos nem a taxa. Então a pergunta honesta é se baixar o
`START_CASH` melhora ali. Não melhora:

| | 400.000 | 150.000 |
|---|---:|---:|
| margem Ótimo | 674.019 | 599.970 |
| margem Descuidado | 103.290 | 60.013 |
| **vão, em reais** | **570.729** | **539.957** |
| vão, em razão | 6,5× | 10,0× |

A razão sobe só porque o denominador encolhe; o **vão em reais, que é o número
que `005` e `009` citam, PIORA 5%**. E o caixa final, que é o outro eixo,
comprime-se muito: de 807.000 de vão entre Ótimo e Descuidado para 285.000.

O motivo é bonito e vale ficar escrito: **o `START_CASH` pune mais quem
constrói mais**. Por cada real tirado do início, perdem-se no fim

`Ótimo 2,88 · Mediano 1,83 · Descuidado 0,80`

O dinheiro inicial compra TEMPO com o porto pronto, e quem levanta as sete
estruturas perde mais turnos de porto pronto. O Descuidado fica **abaixo de 1**
porque o que ele deixa de receber é em parte compensado pelo pátio que deixa de
comprar. Baixar o caixa inicial aperta o bom jogador mais do que o mau.

## 6. O critério 4 está mal formado, e é de propósito que não se usou

A F1 escreveu como quarto critério *"nenhum perfil em aresta de faca (a taxa
mexe muito e a mediana quase nada)"*. O único perfil que o viola é o
**Descuidado na linha de base** — a taxa dele cai 54% em relativo entre 400.000
e 360.000 enquanto a mediana cai 8,7%.

Mas isso não é defeito: é o alvo. Um perfil cuja taxa-alvo não é 0% nem 100%
**tem** de ter a mediana perto da linha de corte, senão a taxa satura. O
critério, como está escrito, reprovaria o estado que `005` decidiu. Não se
aplicou por isso, e fica registado para não voltar a aparecer numa F1.

## 7. O que NÃO se fez

- **Não se mexeu na parcela para acomodar um caixa menor.** Mover as duas ao
  mesmo tempo é reabrir `005`, que o próprio plano lista como decisão a
  reabrir e não como item de fila.
- **Não se mexeu em custo de estrutura.** É o outro eixo desta medição, e
  varrê-lo é outra sessão com outro desenho.
- **Não se tocou no `GameState.gd`.** As seis corridas alteradas correram sobre
  uma cópia restaurada no fim, e o `git diff` saiu vazio antes do commit.
