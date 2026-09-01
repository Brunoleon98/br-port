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
| `START_CASH` | 3.250 | TUNING | TUNING — medido, não estimado. … | `GameState.gd:42` |
| `SALARY_PER_WORKER` | 100 | TUNING (GDD) | GDD "Margem operacional base": 2 trab. x R$100 = R$200/sem | `GameState.gd:43` |
| `MAINTENANCE_WEEKLY` | 30 | TUNING (GDD) | GDD "Margem operacional base": manutenção R$30/sem | `GameState.gd:44` |
| `DOCKS_BASE` | 1 | GDD 7 | O porto ABRE PARADO. … | `GameState.gd:48` |
| `WORKERS_BASE` | 1 | GDD 7 | O porto ABRE PARADO. … | `GameState.gd:49` |
| `UPGRADE_EXTRA_DOCKS` | 1 | GDD 7 | O porto ABRE PARADO. … | `GameState.gd:50` |
| `UPGRADE_EXTRA_WORKERS` | 1 | GDD 7 | O porto ABRE PARADO. … | `GameState.gd:51` |
| `BERCOS_NO_MAPA` | 3 | regra | Quantos berços o mapa desenha. … | `GameState.gd:59` |

## ESTRUTURAS

| Constante | Valor | Fonte | Por quê | Onde |
|---|---:|---|---|---|
| `ARMAZEM_BONUS` | 0.2 | TUNING | TUNING | `GameState.gd:100` |
| `PATIO_BONUS_PIER` | 1.0 | TUNING | TUNING | `GameState.gd:101` |
| `ESCRITORIO_DESCONTO_SALARIO` | 0.5 | TUNING | TUNING | `GameState.gd:105` |
| `PIER_SLOTS` | 6 | GDD 7 | GDD "Margem operacional base": 6 vagas de píer | `GameState.gd:107` |
| `PIER_RATE_PER_SLOT` | 40 | GDD 7 | GDD "Margem operacional base": R$40/vaga -> R$240/sem | `GameState.gd:108` |
| `BOAT_VALUE_SMALL_MIN` | 80 | GDD 7 | GDD "Valor de contratos": … | `GameState.gd:113` |
| `BOAT_VALUE_SMALL_MAX` | 200 | GDD 7 | GDD "Valor de contratos": … | `GameState.gd:114` |
| `BOAT_VALUE_LARGE_MIN` | 200 | GDD 7 | GDD "Valor de contratos": … | `GameState.gd:115` |
| `BOAT_VALUE_LARGE_MAX` | 300 | GDD 7 | GDD "Valor de contratos": … | `GameState.gd:116` |
| `BOAT_LARGE_CHANCE` | 0.4 | TUNING (GDD) | TUNING | `GameState.gd:117` |
| `BOAT_ARRIVAL_CHANCE` | 0.75 | TUNING (GDD) | TUNING: chance POR doca vazia de chegar barco no turno | `GameState.gd:118` |

## Contra-oferta do Arlindo (GDD: "Limiar de paciência do cliente")

| Constante | Valor | Fonte | Por quê | Onde |
|---|---:|---|---|---|
| `RIVAL_TRIGGER_CHANCE` | 0.3 | TUNING (GDD) | Protótipo validado (Arlindo — dumping) | `GameState.gd:126` |
| `RIVAL_DISCOUNT` | 0.15 | TUNING (GDD) | "Igualar rival −15%" (GDD) | `GameState.gd:127` |
| `RIVAL_HALF_DISCOUNT` | 0.07 | TUNING (GDD) | "Cortar metade −7%" (GDD) | `GameState.gd:128` |
| `RIVAL_HALF_CHANCE` | 0.7 | TUNING (GDD) | TUNING: chance de o cliente aceitar o meio-termo | `GameState.gd:129` |
| `RIVAL_KEEP_CHANCE` | 0.45 | TUNING (GDD) | TUNING: chance de o cliente aceitar pagar cheio | `GameState.gd:130` |
| `RIVAL_DISCOUNT_AFTER_FAIL` | 0.28 | TUNING | TUNING | `GameState.gd:133` |
| `RIVAL_PATIENCE` | 2 | GDD 7 | GDD: máx. 2 tentativas antes de o cliente encerrar | `GameState.gd:134` |

## REPUTAÇÃO COMERCIAL

| Constante | Valor | Fonte | Por quê | Onde |
|---|---:|---|---|---|
| `REPUTATION_START` | 65.0 | regra | Hoje a reputação é RÓTULO na HUD e mais nada: … | `GameState.gd:140` |
| `REPUTATION_GAIN_SERVED` | 4.0 | regra | Hoje a reputação é RÓTULO na HUD e mais nada: … | `GameState.gd:141` |
| `REPUTATION_LOSS_LOST` | 5.0 | regra | Hoje a reputação é RÓTULO na HUD e mais nada: … | `GameState.gd:142` |
| `REPUTATION_GAIN_RIVAL_MATCHED` | 5.0 | regra | Hoje a reputação é RÓTULO na HUD e mais nada: … | `GameState.gd:143` |
| `REPUTATION_LOSS_RIVAL_REFUSED` | 15.0 | regra | Hoje a reputação é RÓTULO na HUD e mais nada: … | `GameState.gd:144` |

## CADÊNCIA E PARCELA

| Constante | Valor | Fonte | Por quê | Onde |
|---|---:|---|---|---|
| `TURNS_PER_WEEK` | 8 | TUNING (GDD) | TUNING — esta é a constante que faz a economia da Fase 1 fechar. … | `GameState.gd:153` |
| `WEEKS_TOTAL` | 4 | TUNING (GDD) | TUNING — esta é a constante que faz a economia da Fase 1 fechar. … | `GameState.gd:154` |
| `TURNS_TOTAL` | 32 | TUNING (GDD) | TUNING — esta é a constante que faz a economia da Fase 1 fechar. … | `GameState.gd:155` |
| `PARCELA_AMOUNT` | 8.000 | GDD 7 | GDD "Parcelas validadas" / Protótipo VS — parcela única | `GameState.gd:157` |
| `PARCELA_DUE_TURN` | 32 | regra | vence ao fim da semana 4 | `GameState.gd:158` |

## SAVE

| Constante | Valor | Fonte | Por quê | Onde |
|---|---:|---|---|---|
| `SAVE_PATH` | `user://savegame.json` | regra |  | `GameState.gd:161` |
| `SAVE_VERSION` | 2 | regra | VERSÃO DO SAVE — subir SEMPRE que a forma do estado mudar. … | `GameState.gd:171` |

## Estruturas — o que o jogador compra

Preços são `TUNING`, medidos e não estimados. A regra que os governa é
**proporção, não escala**: a infraestrutura custa DEZENAS de barcos. Um
píer a R$400 contra um barco de R$80–300 fazia UM barco comprar um píer,
e decidir onde gastar não valia nada.

| Estrutura | Custo | Efeito | Exige |
|---|---:|---|---|
| Reconstruir o Píer 2 | R$ 900 | +1 doca e +1 trabalhador | — |
| Reconstruir o Píer 3 | R$ 1.600 | +1 doca e +1 trabalhador | pier_2 |
| Consertar o armazém | R$ 1.100 | +20% no valor de cada barco atendido | — |
| Pavimentar o pátio | R$ 700 | dobra a renda semanal do píer | — |
| Reformar o escritório | R$ 500 | -50% nos salários da semana | — |

---

*BR Port · gerado de `brport_vs/autoload/GameState.gd` por
`tools/gerar_tabela_numeros.py` · item A2 do Plano v3.*
