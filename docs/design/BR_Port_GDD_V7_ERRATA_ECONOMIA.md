# GDD 7 — Errata da economia da Fase 1

> **Data:** 26/08/2026
> **Origem:** revisão pedida após o primeiro playtest humano do Vertical Slice.
> **Status:** Parcela 1 corrigida e revalidada por medição. Parcelas 2 e 3
> continuam **não verificadas**.

O GDD 7 está congelado como fonte da verdade. Esta errata existe porque um
erro de aritmética dentro dele foi encontrado durante a produção — e corrigir
em silêncio um documento congelado é pior do que registrar a correção.

Dois cards do GDD foram editados. O que segue é o porquê.

---

## O erro

O card **"Margem operacional base"** dizia, no mesmo card, duas coisas
incompatíveis:

- No resumo: **"~R$ 130/sem"**
- No detalhe: receita R$ 600 − custos R$ 230 = **"Margem: R$ 370/sem"**

R$ 600 − R$ 230 = R$ 370, então o resumo estava simplesmente errado. Mas o
resumo era o menor dos problemas. O detalhe seguia:

> "Em 4 semanas = R$ 1.480"

E a **Parcela 1 vence na semana 4, valendo R$ 8.000.**

| | Valor |
|---|---|
| Acumulado em 4 semanas pelo modelo do GDD | R$ 1.480 |
| Parcela 1 (semana 4) | R$ 8.000 |
| **Diferença** | **falta 5,4×** |

O modelo não pagava nem a primeira parcela. E o card **"Parcelas validadas"**
declarava o conjunto das três como *"VALIDADO por modelo de balanceamento
(v1.0)"*, apoiado no mesmo cenário base de 2 barcos/semana.

Somando as três parcelas (R$ 48.000 em 12 semanas) contra o que o modelo
acumula no mesmo período — cerca de R$ 4.400, ou ~R$ 7.400 contando o armazém
— a falta chega a **6,5×**.

---

## Onde estava o erro (e onde NÃO estava)

O instinto natural é culpar o valor do contrato. **Não é ele.**

O GDD define, em "Valor de contratos", Fase 1 = **R$ 80–300**. Essa faixa está
correta e é coerente com a progressão das fases seguintes (R$ 300–800,
R$ 800–2.000…). Mexer nela quebraria a curva inteira do jogo.

O erro está na **vazão**: o cenário base assume **2 barcos por semana**. Com
contratos de R$ 180 médios, 2 barcos por semana rendem R$ 360 — e nenhuma
combinação de píer e corte de custo tira R$ 8.000 disso em 4 semanas.

> **O gargalo nunca foi quanto vale o barco. É quantos barcos passam.**

Foi exatamente esse o erro que a implementação vinha compensando pelo lado
errado: os valores de barco tinham sido inflados para R$ 240–760 (3× acima do
GDD) para a parcela caber em 12 turnos. Isso fazia a parcela fechar, mas
quebrava a faixa do GDD e deixava o jogo no fio da navalha — quem jogava
perfeito vencia 58% das vezes, decidido pelo sorteio dos barcos.

---

## O modelo corrigido (Parcela 1)

A correção mantém os valores do GDD e aumenta a vazão, via número de turnos
por semana:

| Item | Modelo antigo | Modelo corrigido |
|---|---|---|
| Valor de contrato | R$ 80–300 *(mantido)* | R$ 80–300 |
| Turnos por semana | 3 | **8** |
| Contratos por semana | 2 | **~13,6** |
| Receita de contratos | R$ 360/sem | ~R$ 2.500/sem |
| Píer (6 vagas × R$ 40) | R$ 240/sem | R$ 240/sem |
| Custos (salários + manutenção) | R$ 230/sem | R$ 230–330/sem |
| **Margem** | **R$ 370/sem** | **~R$ 2.400/sem** |
| **Acumulado em 4 semanas** | **R$ 1.480** | **~R$ 9.600** |
| Parcela 1 | R$ 8.000 | R$ 8.000 |
| Resultado | não fecha (falta 5,4×) | **fecha com ~20% de folga** |

### Como isso foi verificado

Não por planilha: por **medição**, com o simulador do projeto
(`brport_vs/tools/simular_balanceamento.gd`), 2.000 partidas por perfil de
jogador, semente fixa:

| Perfil | Vitórias | Caixa no vencimento (mediana) |
|---|---|---|
| Joga perfeito | 99,7% | R$ 9.631 |
| Joga mediano | 63,8% | R$ 8.279 |
| Joga mal | 0,7% | R$ 6.111 |

É uma curva sadia: quem joga certo é recompensado, quem joga mediano sente
tensão real, quem joga mal perde. Antes da correção era 58% / 7% / 0,1% — ou
seja, nem jogar bem garantia nada.

---

## O que continua em aberto

**As Parcelas 2 e 3 não foram verificadas.** A marca "VALIDADO" foi retirada
do card porque o cenário que a sustentava não se sustenta, mas isso **não**
significa que R$ 16.000 e R$ 24.000 estejam errados — significa que ninguém
sabe. Elas dependem de:

- a vazão de contratos das Fases 2 e 3 (não modelada);
- os valores de contrato dessas fases (R$ 300–800 e R$ 800–2.000);
- o armazém como terceira fonte de renda, que o próprio GDD já apontava como
  obrigatório (card "Risco crítico da Parcela 3").

Verificar isso exige estender o simulador para 12 semanas com progressão de
fase — trabalho que **não faz parte do Vertical Slice** e não deve ser feito
antes de ele estar publicado.

**Recomendação:** rodar essa verificação antes de codar a economia da Fase 2,
e não depois. O custo de descobrir o erro agora foi uma tarde; descobri-lo
depois de três fases construídas em cima seria outra ordem de grandeza.

---

## Cards do GDD alterados

1. **"Margem operacional base"** — resumo corrigido de "~R$ 130/sem" para
   "~R$ 2.400/sem"; detalhe reescrito com o modelo medido e a explicação do
   erro.
2. **"Parcelas validadas"** — retirada a marca "VALIDADO por modelo de
   balanceamento (v1.0)"; registrado que apenas a Parcela 1 foi revalidada.

Nenhum outro conteúdo do GDD foi tocado.

---

*BR Port · Errata do GDD 7 · economia da Fase 1*
