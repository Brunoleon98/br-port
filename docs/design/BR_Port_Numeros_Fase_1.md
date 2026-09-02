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
| `ARMAZEM_BONUS` | 0.2 | TUNING | TUNING | `GameState.gd:144` |
| `PATIO_BONUS_PIER` | 1.0 | TUNING | TUNING | `GameState.gd:145` |
| `ESCRITORIO_DESCONTO_SALARIO` | 0.5 | TUNING | TUNING | `GameState.gd:149` |
| `PIER_SLOTS` | 6 | GDD 7 | GDD "Margem operacional base": 6 vagas de píer | `GameState.gd:151` |
| `PIER_RATE_PER_SLOT` | 5.000 | GDD 7 | GDD "Margem operacional base", reescalado: renda fixa semanal | `GameState.gd:152` |
| `BOAT_VALUE_SMALL_MIN` | 8.000 | GDD 7 | GDD "Valor de contratos". … | `GameState.gd:159` |
| `BOAT_VALUE_SMALL_MAX` | 20.000 | GDD 7 | GDD "Valor de contratos". … | `GameState.gd:160` |
| `BOAT_VALUE_LARGE_MIN` | 20.000 | GDD 7 | GDD "Valor de contratos". … | `GameState.gd:161` |
| `BOAT_VALUE_LARGE_MAX` | 70.000 | GDD 7 | GDD "Valor de contratos". … | `GameState.gd:162` |
| `BOAT_LARGE_CHANCE` | 0.4 | TUNING (GDD) | TUNING | `GameState.gd:163` |
| `BOAT_ARRIVAL_CHANCE` | 0.75 | TUNING (GDD) | TUNING: chance POR doca vazia de chegar barco no turno | `GameState.gd:164` |

## Contra-oferta do Arlindo (GDD: "Limiar de paciência do cliente")

| Constante | Valor | Fonte | Por quê | Onde |
|---|---:|---|---|---|
| `RIVAL_TRIGGER_CHANCE` | 0.3 | TUNING (GDD) | Protótipo validado (Arlindo — dumping) | `GameState.gd:172` |
| `RIVAL_DISCOUNT` | 0.15 | TUNING (GDD) | "Igualar rival −15%" (GDD) | `GameState.gd:173` |
| `RIVAL_HALF_DISCOUNT` | 0.07 | TUNING (GDD) | "Cortar metade −7%" (GDD) | `GameState.gd:174` |
| `RIVAL_HALF_CHANCE` | 0.7 | TUNING (GDD) | TUNING: chance de o cliente aceitar o meio-termo | `GameState.gd:175` |
| `RIVAL_KEEP_CHANCE` | 0.45 | TUNING (GDD) | TUNING: chance de o cliente aceitar pagar cheio | `GameState.gd:176` |
| `RIVAL_DISCOUNT_AFTER_FAIL` | 0.28 | TUNING | TUNING | `GameState.gd:179` |
| `RIVAL_PATIENCE` | 2 | GDD 7 | GDD: máx. 2 tentativas antes de o cliente encerrar | `GameState.gd:180` |
| `REPUTACAO_EFEITO_NEGOCIACAO` | 0.5 | TUNING | TUNING — o quanto a reputação pesa na aposta da contra-oferta (item A3). … | `GameState.gd:185` |

## REPUTAÇÃO COMERCIAL

| Constante | Valor | Fonte | Por quê | Onde |
|---|---:|---|---|---|
| `REPUTATION_START` | 65.0 | TUNING | TUNING — a reputação MEXE na negociação (ver `_chance_com_reputacao`), e por isso estes números deixaram de ser cosméticos. … | `GameState.gd:201` |
| `REPUTATION_GAIN_SERVED` | 0.8 | TUNING | TUNING — a reputação MEXE na negociação (ver `_chance_com_reputacao`), e por isso estes números deixaram de ser cosméticos. … | `GameState.gd:202` |
| `REPUTATION_LOSS_LOST` | 2.5 | TUNING | TUNING — a reputação MEXE na negociação (ver `_chance_com_reputacao`), e por isso estes números deixaram de ser cosméticos. … | `GameState.gd:203` |
| `REPUTATION_GAIN_RIVAL_MATCHED` | 1.0 | TUNING | TUNING — a reputação MEXE na negociação (ver `_chance_com_reputacao`), e por isso estes números deixaram de ser cosméticos. … | `GameState.gd:204` |
| `REPUTATION_LOSS_RIVAL_REFUSED` | 8.0 | TUNING | TUNING — a reputação MEXE na negociação (ver `_chance_com_reputacao`), e por isso estes números deixaram de ser cosméticos. … | `GameState.gd:205` |

## CADÊNCIA E PARCELA

| Constante | Valor | Fonte | Por quê | Onde |
|---|---:|---|---|---|
| `TURNS_PER_WEEK` | 8 | TUNING (GDD) | TUNING — esta é a constante que faz a economia da Fase 1 fechar. … | `GameState.gd:214` |
| `WEEKS_TOTAL` | 4 | TUNING (GDD) | TUNING — esta é a constante que faz a economia da Fase 1 fechar. … | `GameState.gd:215` |
| `TURNS_TOTAL` | 32 | TUNING (GDD) | TUNING — esta é a constante que faz a economia da Fase 1 fechar. … | `GameState.gd:216` |
| `PARCELA_AMOUNT` | 550.000 | GDD 7 | GDD "Parcelas validadas" / Protótipo VS — parcela única | `GameState.gd:218` |
| `PARCELA_DUE_TURN` | 32 | regra | vence ao fim da semana 4 | `GameState.gd:219` |

## SAVE

| Constante | Valor | Fonte | Por quê | Onde |
|---|---:|---|---|---|
| `SAVE_PATH` | `user://savegame.json` | regra |  | `GameState.gd:222` |
| `SAVE_VERSION` | 4 | regra | VERSÃO DO SAVE — subir SEMPRE que a forma do estado mudar. … | `GameState.gd:241` |

## OS DOIS NOMES

| Constante | Valor | Fonte | Por quê | Onde |
|---|---:|---|---|---|
| `NOME_PORTO_PADRAO` | `Cais Mirim` | GDD 7 | O jogador escolhe-os na abertura, e a escolha é irrevogável (GDD 7). … | `GameState.gd:250` |
| `NOME_JOGADOR_PADRAO` | `` | regra | Para o nome do jogador NÃO há padrão, e é de propósito: … | `GameState.gd:257` |
| `NOME_MAX_CARACTERES` | 24 | regra | Limite de tamanho dos dois campos. … | `GameState.gd:262` |

## Estruturas — o que o jogador compra

Preços são `TUNING`, medidos e não estimados. A regra que os governa é
**proporção, não escala**: a infraestrutura custa DEZENAS de barcos. Um
píer a R$400 contra um barco de R$80–300 fazia UM barco comprar um píer,
e decidir onde gastar não valia nada.

| Estrutura | Custo | Efeito | Exige |
|---|---:|---|---|
| Reconstruir o Píer 2 | R$ 150.000 | +1 doca e +1 trabalhador | — |
| Reconstruir o Píer 3 | R$ 260.000 | +1 doca e +1 trabalhador | pier_2 |
| Consertar o armazém | R$ 180.000 | +20% no valor de cada barco atendido | — |
| Pavimentar o pátio | R$ 115.000 | dobra a renda semanal do píer | — |
| Reformar o escritório | R$ 80.000 | -50% nos salários da semana | — |

---

*BR Port · gerado de `brport_vs/autoload/GameState.gd` por
`tools/gerar_tabela_numeros.py` · item A2 do Plano v3.*
