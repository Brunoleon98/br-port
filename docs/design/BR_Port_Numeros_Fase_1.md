# BR Port — os números da Fase 1

> **ARQUIVO GERADO. Não edite à mão.**
> Sai de `brport_vs/autoload/GameState.gd` por
> `python3 tools/gerar_tabela_numeros.py`, e o CI reprova o push se a
> versão daqui não bater com a que o gerador produz.

Esta tabela existe porque os números do jogo viviam em dois lugares — o
GDD e as constantes `# TUNING:` — e **já divergiram uma vez**. O modelo
da Fase 1 no GDD acumulava R$1.480 contra uma parcela de R$8.000, e o
erro só apareceu depois do primeiro playtest humano
(`BR_Port_GDD_V7_ERRATA_ECONOMIA.md`). Aqui há uma fonte só: o código.

A coluna **Fonte** diz de onde o número vem:

| Fonte | O que significa |
|---|---|
| `GDD 7` | Está escrito no GDD. Mudar aqui é divergir do documento congelado |
| `TUNING` | Escolha de balanceamento, medida em `simular_balanceamento.gd` |
| `TUNING (GDD)` | Cadência não fechada no GDD, calibrada por medição |
| `Protótipo` | Veio do protótipo HTML já validado (Playtest V3) |
| `regra` | Regra do jogo, não número de balanceamento |

**Mexeu num `TUNING`? Meça.** `simular_balanceamento.gd -- 600` — e 600
não é exagero: as 30 partidas que o CI roda têm margem de ±18 pontos e
já foram lidas como regressão de balanceamento uma vez.

## TUNING: economia (fonte: GDD 7 — Sistemas > economia, Fase 1)

| Constante | Valor | Fonte | Por quê | Onde |
|---|---:|---|---|---|
| `START_CASH` | 400.000 | TUNING | ESCALA REALISTA E JOGO TRANQUILO (02/09) — os dois de uma vez, e a ordem em que foram feitos importa para quem vier reler isto. … | `GameState.gd:86` |
| `SALARY_PER_WORKER` | 6.000 | TUNING (GDD) | TUNING sobre a linha "Margem operacional base" do GDD, reescalada | `GameState.gd:87` |
| `MAINTENANCE_WEEKLY` | 40.000 | TUNING (GDD) | TUNING sobre a mesma linha do GDD — o custo fixo que separa os perfis | `GameState.gd:88` |
| `DOCKS_BASE` | 1 | GDD 7 | O porto ABRE PARADO. … | `GameState.gd:92` |
| `WORKERS_BASE` | 1 | GDD 7 | O porto ABRE PARADO. … | `GameState.gd:93` |
| `UPGRADE_EXTRA_DOCKS` | 1 | GDD 7 | O porto ABRE PARADO. … | `GameState.gd:94` |
| `UPGRADE_EXTRA_WORKERS` | 1 | GDD 7 | O porto ABRE PARADO. … | `GameState.gd:95` |
| `BERCOS_NO_MAPA` | 3 | regra | Quantos berços o mapa desenha. … | `GameState.gd:103` |

## ESTRUTURAS

| Constante | Valor | Fonte | Por quê | Onde |
|---|---:|---|---|---|
| `GUINDASTE_CORTA_TURNOS` | 1 | TUNING | TUNING | `GameState.gd:178` |
| `CAIS_CHANCE_GRANDE` | 1.6 | TUNING | TUNING | `GameState.gd:182` |
| `ARMAZEM_BONUS` | 0.5 | TUNING | TUNING | `GameState.gd:190` |
| `PATIO_BONUS_CARGA` | 0.3 | TUNING | TUNING | `GameState.gd:194` |
| `PATIO_BONUS_PIER` | 1.0 | TUNING | TUNING | `GameState.gd:195` |
| `ESCRITORIO_DESCONTO_SALARIO` | 0.5 | TUNING | TUNING | `GameState.gd:199` |

## MOTIVO DA ESCALA

| Constante | Valor | Fonte | Por quê | Onde |
|---|---:|---|---|---|
| `PIER_SLOTS` | 6 | GDD 7 | GDD "Margem operacional base": 6 vagas de píer | `GameState.gd:247` |
| `PIER_RATE_PER_SLOT` | 5.000 | GDD 7 | GDD "Margem operacional base", reescalado: renda fixa semanal | `GameState.gd:248` |
| `BOAT_VALUE_SMALL_MIN` | 8.000 | GDD 7 | GDD "Valor de contratos". … | `GameState.gd:255` |
| `BOAT_VALUE_SMALL_MAX` | 20.000 | GDD 7 | GDD "Valor de contratos". … | `GameState.gd:256` |
| `BOAT_VALUE_LARGE_MIN` | 20.000 | GDD 7 | GDD "Valor de contratos". … | `GameState.gd:257` |
| `BOAT_VALUE_LARGE_MAX` | 70.000 | GDD 7 | GDD "Valor de contratos". … | `GameState.gd:258` |
| `BOAT_LARGE_CHANCE` | 0.4 | TUNING (GDD) | TUNING | `GameState.gd:259` |
| `BOAT_ARRIVAL_CHANCE` | 0.75 | TUNING (GDD) | TUNING: chance POR doca vazia de chegar barco no turno | `GameState.gd:260` |

## Contra-oferta do Arlindo (GDD: "Limiar de paciência do cliente")

| Constante | Valor | Fonte | Por quê | Onde |
|---|---:|---|---|---|
| `RIVAL_TRIGGER_CHANCE` | 0.3 | TUNING (GDD) | Protótipo validado (Arlindo — dumping) | `GameState.gd:268` |
| `RIVAL_DISCOUNT` | 0.15 | TUNING (GDD) | "Igualar rival −15%" (GDD) | `GameState.gd:269` |
| `RIVAL_HALF_DISCOUNT` | 0.07 | TUNING (GDD) | "Cortar metade −7%" (GDD) | `GameState.gd:270` |
| `RIVAL_HALF_CHANCE` | 0.7 | TUNING (GDD) | TUNING: chance de o cliente aceitar o meio-termo | `GameState.gd:271` |
| `RIVAL_KEEP_CHANCE` | 0.45 | TUNING (GDD) | TUNING: chance de o cliente aceitar pagar cheio | `GameState.gd:272` |
| `RIVAL_DISCOUNT_AFTER_FAIL` | 0.28 | TUNING | TUNING | `GameState.gd:275` |
| `RIVAL_PATIENCE` | 2 | GDD 7 | GDD: máx. 2 tentativas antes de o cliente encerrar | `GameState.gd:276` |
| `REPUTACAO_EFEITO_NEGOCIACAO` | 0.5 | TUNING | TUNING — o quanto a reputação pesa na aposta da contra-oferta (item A3). … | `GameState.gd:281` |

## REPUTAÇÃO COMERCIAL

| Constante | Valor | Fonte | Por quê | Onde |
|---|---:|---|---|---|
| `REPUTATION_START` | 65.0 | TUNING | TUNING — a reputação MEXE na negociação (ver `_chance_com_reputacao`), e por isso estes números deixaram de ser cosméticos. … | `GameState.gd:297` |
| `REPUTATION_GAIN_SERVED` | 0.8 | TUNING | TUNING — a reputação MEXE na negociação (ver `_chance_com_reputacao`), e por isso estes números deixaram de ser cosméticos. … | `GameState.gd:298` |
| `REPUTATION_LOSS_LOST` | 2.5 | TUNING | TUNING — a reputação MEXE na negociação (ver `_chance_com_reputacao`), e por isso estes números deixaram de ser cosméticos. … | `GameState.gd:299` |
| `REPUTATION_GAIN_RIVAL_MATCHED` | 1.0 | TUNING | TUNING — a reputação MEXE na negociação (ver `_chance_com_reputacao`), e por isso estes números deixaram de ser cosméticos. … | `GameState.gd:300` |
| `REPUTATION_LOSS_RIVAL_REFUSED` | 8.0 | TUNING | TUNING — a reputação MEXE na negociação (ver `_chance_com_reputacao`), e por isso estes números deixaram de ser cosméticos. … | `GameState.gd:301` |

## CADÊNCIA E PARCELA

| Constante | Valor | Fonte | Por quê | Onde |
|---|---:|---|---|---|
| `TURNS_PER_WEEK` | 8 | TUNING (GDD) | TUNING — esta é a constante que faz a economia da Fase 1 fechar. … | `GameState.gd:310` |
| `WEEKS_TOTAL` | 4 | TUNING (GDD) | TUNING — esta é a constante que faz a economia da Fase 1 fechar. … | `GameState.gd:311` |
| `TURNS_TOTAL` | 32 | TUNING (GDD) | TUNING — esta é a constante que faz a economia da Fase 1 fechar. … | `GameState.gd:312` |
| `PARCELA_AMOUNT` | 530.000 | GDD 7 | GDD "Parcelas validadas" / Protótipo VS — parcela única | `GameState.gd:321` |
| `PARCELA_DUE_TURN` | 32 | regra | vence ao fim da semana 4 | `GameState.gd:322` |

## SAVE

| Constante | Valor | Fonte | Por quê | Onde |
|---|---:|---|---|---|
| `SAVE_PATH` | `user://savegame.json` | regra |  | `GameState.gd:325` |
| `SAVE_VERSION` | 6 | regra | VERSÃO DO SAVE — subir SEMPRE que a forma do estado mudar. … | `GameState.gd:350` |

## OS DOIS NOMES

| Constante | Valor | Fonte | Por quê | Onde |
|---|---:|---|---|---|
| `NOME_PORTO_PADRAO` | `Cais Mirim` | GDD 7 | O jogador escolhe-os na abertura, e a escolha é irrevogável (GDD 7). … | `GameState.gd:359` |
| `NOME_JOGADOR_PADRAO` | `` | regra | Para o nome do jogador NÃO há padrão, e é de propósito: … | `GameState.gd:366` |
| `NOME_MAX_CARACTERES` | 24 | regra | Limite de tamanho dos dois campos. … | `GameState.gd:371` |

## Estruturas — o que o jogador compra

Preços são `TUNING`, medidos e não estimados. A regra que os governa é
**proporção, não escala**: a infraestrutura custa DEZENAS de barcos. Um
píer a R$400 contra um barco de R$80–300 fazia UM barco comprar um píer,
e decidir onde gastar não valia nada.

| Estrutura | Custo | Efeito | Exige |
|---|---:|---|---|
| Reconstruir o Píer 2 | R$ 150.000 | +1 doca e +1 trabalhador | — |
| Reconstruir o Píer 3 | R$ 260.000 | +1 doca e +1 trabalhador | pier_2 |
| Consertar o armazém | R$ 180.000 | +50% no barco que vem deixar carga | — |
| Pavimentar o pátio | R$ 115.000 | dobra a renda do píer e +30% no contêiner | — |
| Reformar o escritório | R$ 80.000 | -50% nos salários da semana | — |
| Guindaste de pórtico | R$ 120.000 | corta um turno de cada operação | pier_2 |
| Reforçar o cais | R$ 150.000 | +60% de chance de navio grande atracar | guindaste |

## Motivos de escala — por que o navio veio

O efeito é sempre o da ESTRUTURA a que o motivo está preso, nunca do
motivo sozinho: um motivo que pagasse mais por si seria só outro sorteio
de valor com um nome por cima. Os pesos são por TAMANHO de barco e somam
100 em cada coluna — o pesqueiro não traz contêiner, e o graneleiro não
é pesqueiro.

| Motivo | Estrutura | Bónus | Turno extra | Peso pequeno | Peso grande |
|---|---|---:|---:|---:|---:|
| Armazenagem | armazem | +50% | — | 45 | 35 |
| Contêiner | patio | +30% | — | 0 | 40 |
| Granel | guindaste | — | +1 | 0 | 25 |
| Pescado | — | — | — | 55 | 0 |

---

*BR Port · gerado de `brport_vs/autoload/GameState.gd` por
`tools/gerar_tabela_numeros.py` · item A2 do Plano v3.*
