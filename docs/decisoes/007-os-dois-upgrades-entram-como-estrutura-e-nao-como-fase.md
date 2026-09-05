# 007 — Os dois upgrades entram como ESTRUTURA, e não como fase

**05/09/2026.** O GDD 7 decidiu que *"estruturas principais (grua, cais,
armazém) têm upgrade in-place de até 3 níveis"*, e a ARTE dos três níveis
existia desde 05/09 — `pier_n1..n3` e `lanca_n1..n3`, escolhidas por uma
leitura derivada da contagem de estruturas. Faltava a mecânica. O pedido foi:
*"níveis de guindaste e píer, com upgrade para chegar em níveis maiores, sendo
que alguns upgrades serão bloqueados por fase"*.

---

## A decisão

**Dois upgrades compráveis no painel Construir, e nenhuma fase nova.**

| id | nome | efeito | custo | requer |
|---|---|---|---|---|
| `guindaste` | Guindaste de pórtico | navio grande descarrega em 1 turno em vez de 2 | R$120.000 | `pier_2` |
| `cais` | Reforçar o cais | +60% de chance de navio grande atracar | R$150.000 | `guindaste` |

**Por que não uma fase.** O `advance_turn()` retorna calado fora de
`"playing"` e o `simular_balanceamento.gd` só sabe resolver duas fases: uma
fase nova apareceria como partida que não termina, e já custou 24 de 30
partidas travadas uma vez. A regra está no `CLAUDE.md` — *"tela nova é
overlay, nunca fase do `GameState`"* — e vale igual para mecânica nova.

**Como se faz o bloqueio, então.** Pelo `requer`, que já existia. O VS só tem
a Fase 1 construída, então trancar por Fase seria trancar contra uma coisa que
o resto do jogo não conhece. A cadeia `pier_2 → guindaste → cais` põe os dois
no fim da progressão, que é o efeito que se queria. Quando as Fases existirem,
o campo `requer` é o sítio onde a condição de Fase se acrescenta.

**E são DUAS leituras de nível, não uma.** `nivel_porto()` saiu; entraram
`nivel_pier()` e `nivel_guindaste()`, cada uma presa ao seu upgrade. Com uma
leitura só, comprar o guindaste engrossava a laje do píer — o jogador via
mudar o que não comprou.

---

## As tentativas, medidas

600 partidas por perfil, semente 20260825, em todas as linhas.

| guindaste / cais | requer | Ótimo | Mediano | Descuidado | barcos Ó/M/D |
|---|---|---:|---:|---:|---|
| *sem upgrades* | — | 100,0% | 79,5% | **35,7%** | 46,3 / 35,5 / 12,5 |
| 240k / 320k | pier_2 / pier_3 | 91,3% | **30,7%** | 35,7% | 53,1 / 36,1 / 12,5 |
| 140k / 170k | pier_2 / guindaste | 99,8% | 65,2% | 32,8% | 54,9 / 39,8 / 12,6 |
| **120k / 150k** | **pier_2 / guindaste** | **100,0%** | **79,5%** | **31,0%** | **56,2 / 41,1 / 12,6** |
| 100k / 130k | pier_2 / guindaste | 100,0% | 88,3% | 30,3% | 57,4 / 42,6 / 12,6 |
| 120k / 150k | **pier_3** / guindaste | 100,0% | **55,2%** | 35,7% | 54,5 / 38,3 / 12,5 |
| 120k / 260k | pier_2 / guindaste | 99,8% | 54,3% | 31,2% | 57,9 / 42,2 / 12,6 |
| 120k / 200k | pier_2 / guindaste | 100,0% | 64,3% | 31,2% | 55,7 / 40,2 / 12,6 |

**⚠️ A primeira tentativa deixou o jogo MAIS DIFÍCIL, e isso não era erro de
conta.** A 240k/320k o Mediano caiu de 79,5% para 30,7% com os barcos
atendidos a SUBIR — a vazão melhorou e o caixa não: R$560.000 de upgrade
amarrados às vésperas de uma parcela de R$550.000. É a irmã da armadilha que a
skill `/balancear` já regista sobre o `START_CASH` — lá o cauteloso nunca
constrói, aqui o diligente constrói tarde demais.

**O Mediano é aresta de faca neste eixo:** 65,2% → 79,5% → 88,3% entre 140k,
120k e 100k. A mediana dele fica perto da parcela, e o preço do upgrade
desloca-a de lado a lado.

**Trancar mais fundo não serve.** Com `guindaste` a exigir `pier_3`, o
Descuidado volta aos 35,7% (nunca lá chega) e o Mediano desaba para 55,2% —
ele passa a comprar depois dos R$260.000 do terceiro píer, rente ao prazo.

---

## O que fica fora do alvo, e é decisão do Bruno

**O Descuidado passa de 35,7% para 31,0%**, e nenhum ponto do varrimento o traz
de volta sem custar o Mediano. A causa é real e não é ajustável por preço: dar
mais coisa para comprar dá mais corda a quem compra mal, e o Descuidado compra
tarde. Os 31,0% continuam a satisfazer a descrição da decisão 005 — *"perde a
maioria, sem ser garantido"* — mas o número registado lá era ~35%.

**O que MELHOROU é o que a decisão 005 diz que deve discriminar.** O vão em
barcos atendidos abriu de 46,3 × 12,5 para **56,2 × 12,6**: o Ótimo ganha 21%
de porto e o Descuidado 1%. É exatamente *"quem separa os jogadores é o porto
que conseguem levantar"*.

Se o alvo dos ~35% for para manter à letra, isso é mexer noutra constante
(`PARCELA_AMOUNT` é o botão) e é outra medição.

---

## Duas coisas que a passagem apanhou, e nenhuma dava erro

**⚠️ `ORDEM_DE_COMPRA` no simulador é uma lista CRAVADA.** Ela não percorre
`ESTRUTURAS`. Uma estrutura nova que não entre lá nunca é comprada por perfil
nenhum, e as 600 partidas saem idênticas às de antes — o que se lê como "o
upgrade não mexeu no balanceamento" quando o que aconteceu foi ninguém o ter
comprado.

**⚠️ O projetor das Parcelas reprovou, e reprovou pela razão certa.** O
`valor_medio()` do `projetar_parcelas.py` calcula o barco médio a partir do
`BOAT_LARGE_CHANCE`, e o cais reforçado multiplica essa chance: o barco médio
passou a valer mais sem nenhuma constante de VALOR ter mudado. Medido, o
Descuidado (que quase não compra o cais) passava a 7,1% e o Mediano e o Ótimo
saíam **21,1% e 22,2% ABAIXO** do medido. Ensinar o modelo a fração de `cais`
levou os dois para 0,5% e 0,7%. **Um perfil fora é métrica; os que compram fora
e o que não compra dentro é o modelo a ignorar a compra.**
