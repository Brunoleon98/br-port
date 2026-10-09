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
não é exagero: uma rodada curta tem margem de dezenas de pontos, e já
foi lida como regressão de balanceamento uma vez.

## TUNING: economia (fonte: GDD 7 — Sistemas > economia, Fase 1)

| Constante | Valor | Fonte | Por quê | Onde |
|---|---:|---|---|---|
| `ESCALA_MONETARIA_GDD` | 1.0 | TUNING | ESCALA REALISTA E JOGO TRANQUILO (02/09) — os dois de uma vez, e a ordem em que foram feitos importa para quem vier reler isto. … | `GameState.gd:124` |
| `START_CASH` | 400.000 | TUNING | ESCALA REALISTA E JOGO TRANQUILO (02/09) — os dois de uma vez, e a ordem em que foram feitos importa para quem vier reler isto. … | `GameState.gd:125` |
| `SALARY_PER_WORKER` | 6.000 | TUNING (GDD) | TUNING sobre a linha "Margem operacional base" do GDD, reescalada | `GameState.gd:126` |
| `MAINTENANCE_WEEKLY` | 40.000 | TUNING (GDD) | TUNING sobre a mesma linha do GDD — o custo fixo que separa os perfis | `GameState.gd:127` |
| `DOCKS_BASE` | 1 | GDD 7 | O porto ABRE PARADO. … | `GameState.gd:131` |
| `WORKERS_BASE` | 1 | GDD 7 | O porto ABRE PARADO. … | `GameState.gd:132` |
| `UPGRADE_EXTRA_DOCKS` | 1 | GDD 7 | O porto ABRE PARADO. … | `GameState.gd:133` |
| `UPGRADE_EXTRA_WORKERS` | 1 | GDD 7 | O porto ABRE PARADO. … | `GameState.gd:134` |
| `BERCOS_NO_MAPA` | 3 | regra | Quantos berços o mapa desenha. … | `GameState.gd:142` |

## ESTRUTURAS

| Constante | Valor | Fonte | Por quê | Onde |
|---|---:|---|---|---|
| `GUINDASTE_CORTA_TURNOS` | 1 | TUNING | TUNING | `GameState.gd:222` |
| `ARMAZEM_BONUS` | 0.5 | TUNING | TUNING | `GameState.gd:230` |
| `PATIO_BONUS_CARGA` | 0.3 | TUNING | TUNING | `GameState.gd:234` |
| `PATIO_BONUS_PIER` | 1.0 | TUNING | TUNING | `GameState.gd:235` |
| `ESCRITORIO_DESCONTO_SALARIO` | 0.5 | TUNING | TUNING | `GameState.gd:239` |

## MOTIVO DA ESCALA

| Constante | Valor | Fonte | Por quê | Onde |
|---|---:|---|---|---|
| `PIER_SLOTS` | 6 | GDD 7 | GDD "Margem operacional base": 6 vagas de píer | `GameState.gd:288` |
| `PIER_RATE_PER_SLOT` | 5.000 | GDD 7 | GDD "Margem operacional base", reescalado: renda fixa semanal | `GameState.gd:289` |

## A FILA NO FUNDEADOURO (`docs/decisoes/083`)

| Constante | Valor | Fonte | Por quê | Onde |
|---|---:|---|---|---|
| `FILA_LUGARES` | 3 | GDD 7 | O barco já não nasce na doca: … | `GameState.gd:361` |
| `PACIENCIA_FILA` | 2 | TUNING | TUNING | `GameState.gd:365` |
| `BOAT_ARRIVAL_CHANCE` | 0.75 | TUNING | TUNING | `GameState.gd:369` |

## Contra-oferta do Arlindo (GDD: "Limiar de paciência do cliente")

| Constante | Valor | Fonte | Por quê | Onde |
|---|---:|---|---|---|
| `RIVAL_TRIGGER_CHANCE` | 0.3 | TUNING (GDD) | Protótipo validado (Arlindo — dumping) | `GameState.gd:377` |
| `RIVAL_DISCOUNT` | 0.15 | TUNING (GDD) | "Igualar rival −15%" (GDD) | `GameState.gd:378` |
| `RIVAL_HALF_DISCOUNT` | 0.07 | TUNING (GDD) | "Cortar metade −7%" (GDD) | `GameState.gd:379` |
| `RIVAL_HALF_CHANCE` | 0.7 | TUNING (GDD) | TUNING: chance de o cliente aceitar o meio-termo | `GameState.gd:380` |
| `RIVAL_KEEP_CHANCE` | 0.45 | TUNING (GDD) | TUNING: chance de o cliente aceitar pagar cheio | `GameState.gd:381` |
| `RIVAL_DISCOUNT_AFTER_FAIL` | 0.28 | TUNING | TUNING | `GameState.gd:384` |
| `RIVAL_PATIENCE` | 2 | GDD 7 | GDD: máx. 2 tentativas antes de o cliente encerrar | `GameState.gd:385` |
| `REPUTACAO_EFEITO_NEGOCIACAO` | 0.5 | TUNING | TUNING — o quanto a reputação pesa na aposta da contra-oferta (item A3). … | `GameState.gd:390` |

## REPUTAÇÃO COMERCIAL

| Constante | Valor | Fonte | Por quê | Onde |
|---|---:|---|---|---|
| `REPUTATION_START` | 65.0 | TUNING | TUNING — a reputação MEXE na negociação (ver `_chance_com_reputacao`), e por isso estes números deixaram de ser cosméticos. … | `GameState.gd:406` |
| `REPUTATION_GAIN_SERVED` | 0.8 | TUNING | TUNING — a reputação MEXE na negociação (ver `_chance_com_reputacao`), e por isso estes números deixaram de ser cosméticos. … | `GameState.gd:407` |
| `REPUTATION_LOSS_LOST` | 2.5 | TUNING | TUNING — a reputação MEXE na negociação (ver `_chance_com_reputacao`), e por isso estes números deixaram de ser cosméticos. … | `GameState.gd:408` |
| `REPUTATION_GAIN_RIVAL_MATCHED` | 1.0 | TUNING | TUNING — a reputação MEXE na negociação (ver `_chance_com_reputacao`), e por isso estes números deixaram de ser cosméticos. … | `GameState.gd:409` |
| `REPUTATION_LOSS_RIVAL_REFUSED` | 8.0 | TUNING | TUNING — a reputação MEXE na negociação (ver `_chance_com_reputacao`), e por isso estes números deixaram de ser cosméticos. … | `GameState.gd:410` |

## CADÊNCIA E PARCELA

| Constante | Valor | Fonte | Por quê | Onde |
|---|---:|---|---|---|
| `TURNS_PER_WEEK` | 7 | TUNING | TUNING (`085`) — calendário aprovado: … | `GameState.gd:416` |
| `WEEKS_TOTAL` | 12 | TUNING | TUNING (`085`) — calendário aprovado: … | `GameState.gd:417` |
| `TURNS_TOTAL` | 84 | TUNING | TUNING (`085`) — calendário aprovado: … | `GameState.gd:418` |
| `PARCELA_AMOUNT` | 140.000 | TUNING | TUNING (`085`): capital mais juros | `GameState.gd:422` |
| `PARCELA_DUE_TURN` | 28 | regra | vence ao fim da semana 4 | `GameState.gd:423` |
| `PARCELAS_NA_FASE` | 3 | GDD 7 | A Fase 1 agora joga o arco inteiro das três cobranças (`085`). … | `GameState.gd:428` |
| `PARCELA_2_AMOUNT` | 140.000 | TUNING | TUNING (`085`): … | `GameState.gd:432` |
| `PARCELA_3_AMOUNT` | 140.000 | TUNING | TUNING (`085`): … | `GameState.gd:433` |
| `JUROS_PARCELA_1` | 9.919 | regra | Amortização aproximada de parcelas iguais (~2,48% por período de 28 dias). … | `GameState.gd:437` |
| `JUROS_PARCELA_2` | 6.693 | regra | Amortização aproximada de parcelas iguais (~2,48% por período de 28 dias). … | `GameState.gd:438` |
| `JUROS_PARCELA_3` | 3.388 | regra | Amortização aproximada de parcelas iguais (~2,48% por período de 28 dias). … | `GameState.gd:439` |
| `JUROS_POR_TURNO` | 0.0025 | TUNING | TUNING: fração do principal abatida por turno de antecipação | `GameState.gd:455` |

## SAVE

| Constante | Valor | Fonte | Por quê | Onde |
|---|---:|---|---|---|
| `SAVE_ARQUIVO` | `savegame.json` | regra | O NOME é constante; o CAMINHO decide-o o `ArmazemLocal`, por processo: … | `GameState.gd:463` |
| `SAVE_VERSION` | 12 | regra | VERSÃO DO SAVE — subir quando a forma ou a interpretação do estado mudar. … | `GameState.gd:514` |

## OS ESPAÇOS DE SAVE (`docs/decisoes/066`)

| Constante | Valor | Fonte | Por quê | Onde |
|---|---:|---|---|---|
| `ESPACOS` | 3 | regra | Três partidas lado a lado, «que nem é feito em outros jogos» — o pedido do Bruno no lugar do «Novo jogo (apaga progresso)» que vivia na pausa. … | `GameState.gd:537` |

## OS DOIS NOMES

| Constante | Valor | Fonte | Por quê | Onde |
|---|---:|---|---|---|
| `NOME_PORTO_PADRAO` | `Cais Mirim` | GDD 7 | O jogador escolhe-os na abertura, e a escolha é irrevogável (GDD 7). … | `GameState.gd:653` |
| `NOME_JOGADOR_PADRAO` | `` | regra | Para o nome do jogador NÃO há padrão, e é de propósito: … | `GameState.gd:660` |
| `NOME_MAX_CARACTERES` | 24 | regra | Limite de tamanho dos dois campos. … | `GameState.gd:665` |

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
| Reforçar o cais | R$ 150.000 | o navio de longo curso passa a atracar | guindaste |

## Classes de navio — o que o porto consegue receber

O `nivel` é o do PORTO, e é o MENOR entre o do píer e o do guindaste:
não adianta ter onde encostar sem ter com que descarregar. Um porto em
ruínas é nível 1 e só recebe pesqueiro; o nível 3 exige o cais reforçado,
que já exige o pórtico pela cadeia de `requer`.

Os `turnos` são a operação SEM pórtico — ele corta um. Os 3 do longo
curso nunca chegam a jogar-se, porque a classe só existe no nível 3 e o
nível 3 exige o pórtico.

| Classe | Nível | Valor | Peso | Turnos | Motivos |
|---|---:|---|---:|---:|---|
| Navio de longo curso | 3 | R$ 18.000–28.000 | 20 | 3 | armazenagem 25, conteiner 45, granel 30 |
| Cargueiro | 2 | R$ 7.000–16.000 | 40 | 2 | armazenagem 40, conteiner 40, granel 20 |
| Pesqueiro | 1 | R$ 4.000–9.000 | 40 | 1 | armazenagem 45, pescado 55 |

## Motivos de escala — por que o navio veio

O efeito é sempre o da ESTRUTURA a que o motivo está preso, nunca do
motivo sozinho: um motivo que pagasse mais por si seria só outro sorteio
de valor com um nome por cima.
Os pesos de sorteio de cada motivo estão na tabela das CLASSES, logo
acima: a pergunta que o jogo faz é "que carga traz este navio".

| Motivo | Estrutura | Bónus | Turno extra |
|---|---|---:|---:|
| Armazenagem | armazem | +50% | — |
| Contêiner | patio | +30% | — |
| Granel | guindaste | — | +1 |
| Pescado | — | — | — |

---

*BR Port · gerado de `brport_vs/autoload/GameState.gd` por
`tools/gerar_tabela_numeros.py` · item A2 do Plano v3.*
