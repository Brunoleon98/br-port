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

## Geral

| Constante | Valor | Fonte | Por quê | Onde |
|---|---:|---|---|---|
| `CANCELAMENTO_REPUTACAO` | 5.0 | TUNING | TUNING: custo medido na 110 e aceite na 111 | `GameState.gd:99` |
| `CANCELAMENTO_MULTA` | 0.1 | TUNING | TUNING: fração do acordo, sem bônus, medida na 110 | `GameState.gd:100` |

## TUNING: economia (fonte: GDD 7 — Sistemas > economia, Fase 1)

| Constante | Valor | Fonte | Por quê | Onde |
|---|---:|---|---|---|
| `ESCALA_MONETARIA_GDD` | 1.0 | TUNING | ESCALA REALISTA E JOGO TRANQUILO (02/09) — os dois de uma vez, e a ordem em que foram feitos importa para quem vier reler isto. … | `GameState.gd:143` |
| `START_CASH` | 400.000 | TUNING | ESCALA REALISTA E JOGO TRANQUILO (02/09) — os dois de uma vez, e a ordem em que foram feitos importa para quem vier reler isto. … | `GameState.gd:144` |
| `SALARY_PER_WORKER` | 6.000 | TUNING (GDD) | TUNING sobre a linha "Margem operacional base" do GDD, reescalada | `GameState.gd:145` |
| `MAINTENANCE_WEEKLY` | 40.000 | TUNING (GDD) | TUNING sobre a mesma linha do GDD — o custo fixo que separa os perfis | `GameState.gd:146` |
| `DOCKS_BASE` | 1 | GDD 7 | O porto ABRE PARADO. … | `GameState.gd:150` |
| `WORKERS_BASE` | 1 | GDD 7 | O porto ABRE PARADO. … | `GameState.gd:151` |
| `UPGRADE_EXTRA_DOCKS` | 1 | regra | O que cada píer reconstruído traz. … | `GameState.gd:155` |
| `UPGRADE_EXTRA_WORKERS` | 1 | regra | O que cada píer reconstruído traz. … | `GameState.gd:156` |

## ESTRUTURAS

| Constante | Valor | Fonte | Por quê | Onde |
|---|---:|---|---|---|
| `GUINDASTE_CORTA_TURNOS` | 1 | TUNING | TUNING | `GameState.gd:245` |
| `ARMAZEM_BONUS` | 0.5 | TUNING | TUNING | `GameState.gd:253` |
| `PATIO_BONUS_CARGA` | 0.3 | TUNING | TUNING | `GameState.gd:257` |
| `PATIO_BONUS_PIER` | 1.0 | TUNING | TUNING | `GameState.gd:258` |
| `ESCRITORIO_DESCONTO_SALARIO` | 0.5 | TUNING | TUNING | `GameState.gd:262` |

## MOTIVO DA ESCALA

| Constante | Valor | Fonte | Por quê | Onde |
|---|---:|---|---|---|
| `PIER_SLOTS` | 6 | GDD 7 | GDD "Margem operacional base": 6 vagas de píer | `GameState.gd:311` |
| `PIER_RATE_PER_SLOT` | 5.000 | GDD 7 | GDD "Margem operacional base", reescalado: renda fixa semanal | `GameState.gd:312` |

## A FILA NO FUNDEADOURO (`docs/decisoes/083`)

| Constante | Valor | Fonte | Por quê | Onde |
|---|---:|---|---|---|
| `FILA_LUGARES` | 3 | GDD 7 | O barco já não nasce na doca: … | `GameState.gd:384` |
| `PACIENCIA_FILA` | 2 | TUNING | TUNING | `GameState.gd:388` |
| `BOAT_ARRIVAL_CHANCE` | 0.75 | TUNING | TUNING | `GameState.gd:392` |

## Contra-oferta do Arlindo (GDD: "Limiar de paciência do cliente")

| Constante | Valor | Fonte | Por quê | Onde |
|---|---:|---|---|---|
| `RIVAL_TRIGGER_CHANCE` | 0.3 | TUNING (GDD) | Protótipo validado (Arlindo — dumping) | `GameState.gd:400` |
| `RIVAL_DISCOUNT` | 0.15 | TUNING (GDD) | "Igualar rival −15%" (GDD) | `GameState.gd:401` |
| `RIVAL_HALF_DISCOUNT` | 0.07 | TUNING (GDD) | "Cortar metade −7%" (GDD) | `GameState.gd:402` |
| `RIVAL_HALF_CHANCE` | 0.7 | TUNING (GDD) | TUNING: chance de o cliente aceitar o meio-termo | `GameState.gd:403` |
| `RIVAL_KEEP_CHANCE` | 0.45 | TUNING (GDD) | TUNING: chance de o cliente aceitar pagar cheio | `GameState.gd:404` |
| `RIVAL_DISCOUNT_AFTER_FAIL` | 0.28 | TUNING | TUNING | `GameState.gd:407` |
| `RIVAL_PATIENCE` | 2 | GDD 7 | GDD: máx. 2 tentativas antes de o cliente encerrar | `GameState.gd:408` |
| `REPUTACAO_EFEITO_NEGOCIACAO` | 0.5 | TUNING | TUNING — o quanto a reputação pesa na aposta da contra-oferta (item A3). … | `GameState.gd:413` |

## REPUTAÇÃO COMERCIAL

| Constante | Valor | Fonte | Por quê | Onde |
|---|---:|---|---|---|
| `REPUTATION_GAIN_SERVED` | 0.8 | TUNING | TUNING — a reputação MEXE na negociação (ver `_chance_com_reputacao`), e por isso estes números deixaram de ser cosméticos. … | `GameState.gd:430` |
| `REPUTATION_LOSS_LOST` | 2.5 | TUNING | TUNING — a reputação MEXE na negociação (ver `_chance_com_reputacao`), e por isso estes números deixaram de ser cosméticos. … | `GameState.gd:431` |
| `REPUTATION_GAIN_RIVAL_MATCHED` | 1.0 | TUNING | TUNING — a reputação MEXE na negociação (ver `_chance_com_reputacao`), e por isso estes números deixaram de ser cosméticos. … | `GameState.gd:432` |
| `REPUTATION_LOSS_RIVAL_REFUSED` | 8.0 | TUNING | TUNING — a reputação MEXE na negociação (ver `_chance_com_reputacao`), e por isso estes números deixaram de ser cosméticos. … | `GameState.gd:433` |

## CADÊNCIA

| Constante | Valor | Fonte | Por quê | Onde |
|---|---:|---|---|---|
| `TURNS_PER_WEEK` | 7 | TUNING | TUNING (`085`) — a semana tem sete dias, e é a do calendário inteiro, não a de uma fase: … | `GameState.gd:439` |

## ANTECIPAÇÃO

| Constante | Valor | Fonte | Por quê | Onde |
|---|---:|---|---|---|
| `JUROS_POR_TURNO` | 0.0025 | TUNING | TUNING: fração do principal abatida por turno de antecipação | `GameState.gd:569` |

## A SEGUNDA CHANCE DO SR. RIBEIRO (`docs/decisoes/102`)

| Constante | Valor | Fonte | Por quê | Onde |
|---|---:|---|---|---|
| `SEGUNDA_CHANCE_ACRESCIMO` | 0.12 | TUNING | TUNING: o que o empréstimo da segunda chance custa, sobre o emprestado | `GameState.gd:590` |

## SAVE

| Constante | Valor | Fonte | Por quê | Onde |
|---|---:|---|---|---|
| `SAVE_ARQUIVO` | `savegame.json` | regra | O NOME é constante; o CAMINHO decide-o o `ArmazemLocal`, por processo: … | `GameState.gd:598` |
| `SAVE_VERSION` | 19 | regra | VERSÃO DO SAVE — subir quando a forma ou a interpretação do estado mudar. … | `GameState.gd:668` |
| `SAVE_VERSAO_MINIMA` | 14 | regra | O PISO DA MIGRAÇÃO (`098`). … | `GameState.gd:686` |

## OS ESPAÇOS DE SAVE (`docs/decisoes/066`)

| Constante | Valor | Fonte | Por quê | Onde |
|---|---:|---|---|---|
| `ESPACOS` | 3 | regra | Três partidas lado a lado, «que nem é feito em outros jogos» — o pedido do Bruno no lugar do «Novo jogo (apaga progresso)» que vivia na pausa. … | `GameState.gd:709` |

## OS DOIS NOMES

| Constante | Valor | Fonte | Por quê | Onde |
|---|---:|---|---|---|
| `NOME_PORTO_PADRAO` | `Cais Mirim` | GDD 7 | O jogador escolhe-os na abertura, e a escolha é irrevogável (GDD 7). … | `GameState.gd:841` |
| `NOME_JOGADOR_PADRAO` | `` | regra | Para o nome do jogador NÃO há padrão, e é de propósito: … | `GameState.gd:848` |
| `NOME_MAX_CARACTERES` | 24 | regra | Limite de tamanho dos dois campos. … | `GameState.gd:853` |

## OS ESTADOS DO TURNO (M9, `104`)

| Constante | Valor | Fonte | Por quê | Onde |
|---|---:|---|---|---|
| `ESTADO_JOGANDO` | `playing` | regra | O que o turno espera: … | `GameState.gd:867` |
| `ESTADO_OFERTA` | `rival_offer` | regra | O que o turno espera: … | `GameState.gd:868` |
| `ESTADO_COBRANCA` | `debt_payment` | regra | O que o turno espera: … | `GameState.gd:869` |
| `ESTADO_FIM` | `game_over` | regra | O que o turno espera: … | `GameState.gd:870` |

## A FASE EM JOGO (`094`, `104`)

| Constante | Valor | Fonte | Por quê | Onde |
|---|---:|---|---|---|
| `CALENDARIO_SEM_PRAZO_SEMANAS` | 4 | regra | Quantas semanas o calendário mostra numa fase sem prazo: … | `GameState.gd:1388` |

## TURN ADVANCE

| Constante | Valor | Fonte | Por quê | Onde |
|---|---:|---|---|---|
| `MOTIVO_DA_FASE_1` | `Você quitou as três parcelas e manteve o porto no azul!` | regra | A frase do balanço de quem fecha a Fase 1. … | `GameState.gd:2167` |

## As fases — o que muda de uma para a outra

Desde a `094` o que é de uma fase vive na tabela `FASES` do `GameState`,
e não em constantes soltas: a duração, as parcelas, os reparos, o nível
que eles alcançam, os berços do mapa e a reputação de partida. O jogo
lê-a por funções (`turnos_da_fase()`, `valor_da_parcela()`…). A Fase 2
abre no dia a seguir ao último da 1, no mesmo save, e não tem prazo nem
cobrança (`103`, `104`). O nível máximo é uma afirmação, e o F20 do
`teste_fumaca` confere-a contra os reparos.

| Fase | Abre no dia | Semanas | Dias | Parcelas | Nível máximo | Berços | Reputação inicial |
|---:|---:|---:|---:|---:|---:|---:|---:|
| 1 | 1 | 12 | 84 | 3 | 1 | 3 | 65.0 |
| 2 | 85 | sem prazo | — | 0 | 2 | 3 | 65.0 |

### Fase 1 — as parcelas do Sr. Ribeiro

O valor é o boleto, capital mais juros; quitar antes abate só os
juros da janela, que vai do vencimento anterior ao dela.

| Parcela | Vence na semana da fase | Dia | Valor | Juros | Capital |
|---:|---:|---:|---:|---:|---:|
| 1 | 4 | 28 | R$ 140.000 | R$ 9.919 | R$ 130.081 |
| 2 | 8 | 56 | R$ 140.000 | R$ 6.693 | R$ 133.307 |
| 3 | 12 | 84 | R$ 140.000 | R$ 3.388 | R$ 136.612 |

### Fase 1 — os reparos que ela abre

| Reparo | Abre na semana da fase | Cobranças quitadas | Dias de obra |
|---|---:|---:|---:|
| Reconstruir o Píer 2 | 1 | 0 | 2 |
| Consertar o armazém | 2 | 0 | 2 |
| Pavimentar o pátio | 5 | 1 | 3 |

### Fase 2 — as parcelas do Sr. Ribeiro

Sem cobranças nesta fase.


### Fase 2 — os reparos que ela abre

| Reparo | Abre na semana da fase | Cobranças quitadas | Dias de obra |
|---|---:|---:|---:|
| Reconstruir o Píer 2 | 1 | 0 | 2 |
| Reconstruir o Píer 3 | 1 | 0 | 3 |
| Consertar o armazém | 1 | 0 | 2 |
| Pavimentar o pátio | 1 | 0 | 3 |
| Reformar o escritório | 1 | 0 | 2 |
| Guindaste de treliça | 1 | 0 | 2 |

### Fase 2 — meta e regressão

Patamares provisórios (`106`), até à etapa 4 da `103`.

| Reputação da meta | Fechos seguidos | Piso dos cargueiros |
|---:|---:|---:|
| 80.0 | 3 | 40.0 |

Infraestrutura pronta: Reconstruir o Píer 3, Guindaste de treliça. Missão: primeiro cargueiro atendido.
A conquista mantém a fase em jogo livre; o piso só suspende novas chegadas.

## Estruturas — o que o jogador compra

Preços são `TUNING`, medidos e não estimados. A regra que os governa é
**proporção, não escala**: a infraestrutura custa DEZENAS de barcos. Um
píer a R$400 contra um barco de R$80–300 fazia UM barco comprar um píer,
e decidir onde gastar não valia nada.

| Estrutura | Custo | Dias de obra | Efeito | Exige |
|---|---:|---:|---|---|
| Reconstruir o Píer 2 | R$ 150.000 | 2 | +1 doca e +1 trabalhador | — |
| Reconstruir o Píer 3 | R$ 260.000 | — | +1 doca e +1 trabalhador | pier_2 |
| Consertar o armazém | R$ 180.000 | 2 | +50% no barco que vem deixar carga | — |
| Pavimentar o pátio | R$ 115.000 | 3 | dobra a renda do píer e +30% no contêiner | — |
| Reformar o escritório | R$ 80.000 | — | -50% nos salários da semana | — |
| Guindaste de treliça | R$ 80.000 | — | o cargueiro passa a atracar | pier_2 |
| Guindaste de pórtico | R$ 120.000 | — | corta um turno de cada operação | pier_2 |
| Reforçar o cais | R$ 150.000 | — | o navio de longo curso passa a atracar | guindaste |

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
