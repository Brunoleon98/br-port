# GDD 7 — Errata da economia da Fase 1

> **Data:** 26/08/2026
> **Origem:** revisão pedida após o primeiro playtest humano do Vertical Slice.
> **Status:** Parcela 1 corrigida e revalidada por medição. Parcelas 2 e 3
> **projetadas em 01/09/2026** — fecham, e fecham com muita folga. O que
> sobra delas não é aritmética, é uma pergunta de design em aberto (ver o fim
> deste documento).

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

## As Parcelas 2 e 3 — projetadas em 01/09/2026

Ficou escrito acima que ninguém sabia se R$ 16.000 e R$ 24.000 fechavam. Agora
sabe-se, com uma ressalva que importa: **isto é projeção, não medição.** Medir
exigiria as Fases 2 e 3 implementadas, e este documento continua a dizer que
construí-las antes de o Vertical Slice sair é a ordem errada.

O que torna a projeção defensável — e não mais uma planilha como a que falhou —
são duas amarras, ambas dentro de `tools/projetar_parcelas.py`:

1. **Os números da Fase 1 não são digitados.** Vêm de
   `simular_balanceamento.gd` (a economia da semana em REGIME, medida em 600
   partidas por perfil no jogo que existe) e de `despejar_constantes.gd` (as
   constantes que o jogo usa de verdade). As faixas de contrato e os valores
   das parcelas são lidos do GDD no disco, não copiados para o script.
2. **O modelo tem de reconstruir a Fase 1 antes de falar das outras duas.** Se
   erra a semana que dá para conferir, o programa recusa-se a projetar. Erros
   medidos: Ótimo 0,6%, Mediano 0,3%, Descuidado 1,1%.

A segunda amarra pagou-se logo na primeira corrida: o modelo errava a margem do
perfil Descuidado em 98%. Não era o modelo — era a MEDIÇÃO. O delta de caixa da
semana 4 desse perfil inclui a compra do armazém, que ele faz tarde, e um delta
com uma obra dentro não é margem de regime. Daí o simulador passou a separar as
duas coisas.

### O que dá

Cenário conservador (o porto fica como acaba a Fase 1: 3 docas, nada de novo,
só o valor do contrato sobe como o GDD manda), perfil Ótimo, entrando na semana
5 com **caixa zero** — acabou de pagar a Parcela 1:

| Fase | Contrato | Margem/sem | 4 semanas | Parcela | Sobra |
|---|---|---:|---:|---:|---|
| 2 (sem. 5–8) | R$ 300–800 | R$ 8.918 | R$ 35.671 | R$ 16.000 | **+R$ 19.671 (2,2×)** |
| 3 (sem. 9–12) | R$ 800–2.000 | R$ 22.268 | R$ 89.072 | R$ 24.000 | **+R$ 84.743 (4,5×)** |

Para o jogador **mediano** — o que ganha 47% na Fase 1 — dá 2,0× e 4,0×. No
cenário em que o porto continua a crescer (+1 doca por fase, armazém alugado a
R$ 300/sem), sobe para 3,0× e 7,6×.

### A leitura, que é o contrário do que o GDD temia

O card **"Risco crítico da Parcela 3"** dizia que sem uma terceira fonte de
renda a Parcela 3 não fecharia, e mandava escolher entre pôr o armazém a render
desde a semana 2 ou baixar a Parcela 3 para R$ 18.000 — *"uma das duas mudanças
é obrigatória antes de codar a economia"*. **Essa decisão perdeu o motivo.** Ela
nasceu do mesmo cenário de 2 barcos/semana que esta errata já derrubou; com a
vazão medida, nenhuma das duas mudanças é necessária.

O que sobra é o problema oposto, e a causa é uma só:

| | Fase 1 | Fase 2 | Fase 3 |
|---|---:|---:|---:|
| Valor médio de contrato | R$ 184 | R$ 536 (×2,9) | R$ 1.367 (×2,5) |
| Parcela | R$ 8.000 | R$ 16.000 (×2,0) | R$ 24.000 (×1,5) |

**A receita cresce mais depressa do que a dívida, nas duas passagens de fase.**
A Fase 1 mede 47% de vitória para o jogador mediano — é apertada de propósito, e
o playtest confirmou que a tensão se sente. Nas Fases 2 e 3, com estes números,
a parcela deixa de ser pressão a partir da semana 5.

### ✅ FECHADA em 02/09/2026 — ver `docs/decisoes/005`

**O Bruno escolheu a segunda saída: deixar assim, de propósito.** O jogo é
tranquilo; a dívida é o motor da Fase 1 e mais nada, e o que pressiona daí em
diante é a EXPANSÃO e a MANUTENÇÃO. A decisão, com as consequências, está em
`docs/decisoes/005-o-jogo-e-tranquilo-a-divida-nao-e-o-motor.md`.

Na mesma passagem a economia inteira foi **reescalada para valores realistas** —
contratos de R$8.000 a R$70.000 na Fase 1, manutenção de R$40.000/semana,
estruturas de R$80.000 a R$260.000, Parcela 1 de R$550.000. A escala uniforme
foi medida e é cosmética; o que mudou o jogo foram os RATIOS. Medido em 600
partidas por perfil, com a parcela em R$530.000 desde 06/09: **100% / 80,2% /
37,3%** (era 100% / 79,5% / 31,0% em 05/09, e o Descuidado 35,7% antes dos
upgrades de guindaste e cais — `docs/decisoes/007`).

⚠️ **E a faixa de contrato da Fase 1 mudou em 06/09**: o navio passou a ter
CLASSE, travada pelo nível do porto, e as três faixas somadas vão de R$12.000 a
R$88.000 (`docs/decisoes/009`). O card do GDD continua a dizer R$8.000–70.000,
que é o número congelado; o `projetar_parcelas.py` passou a ler a Fase 1 do
CÓDIGO por causa disso — quando as duas divergem, o portão de calibração reprova
os três perfis de uma vez, e foi o que aconteceu.

O registro do que estava em aberto fica abaixo, porque é o raciocínio que levou
à decisão.

### O que estava em aberto (histórico)

A aritmética fechou; o desenho não. As saídas possíveis são, pelo menos:

- **subir as parcelas** para acompanharem a curva do contrato (uma Parcela 3 na
  casa dos R$ 90.000 devolveria a tensão da Fase 1);
- **deixar assim de propósito**, se a intenção é que a Fase 1 seja o aperto e as
  seguintes sejam o alívio de quem levantou o porto;
- **trocar o que pressiona** nas fases seguintes — se a dívida deixa de morder,
  outra coisa tem de morder, ou o jogo perde o motor.

Não se decide aqui. Fica registrado que **a Parcela 3 de R$ 24.000 não é mais
um risco de não fechar — é um número que não pressiona**, e que codar a economia
da Fase 2 sem resolver isto é construir em cima de uma pergunta.

**Como refazer a conta:**

```sh
$G --headless --path brport_vs --script res://tools/simular_balanceamento.gd \
   -- 600 20260825 /tmp/medicao.json
$G --headless --path brport_vs --script res://tools/despejar_constantes.gd \
   -- /tmp/constantes.json
python3 tools/projetar_parcelas.py --medicao /tmp/medicao.json \
   --constantes /tmp/constantes.json [--perfil Mediano]
```

O CI roda a mesma coisa com a amostra de fumaça e reprova se o modelo deixar de
reproduzir a Fase 1.

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
