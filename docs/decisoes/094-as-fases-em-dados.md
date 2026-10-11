# 094 — As fases em dados: a Fase 2 é uma linha, e a Fase 1 não mudou

**11/10/2026.** Main `ae1e4fe` (PR #117, o M6, fundido; nenhum PR aberto do
Codex); 094 livre conferida na main antes de escrever. É o **M7** da fila de
`docs/REVISAO_GERAL_2026-10-09.md` (§6), que esperava duas decisões do Bruno.
Ele respondeu às duas no arranque desta sessão, com a recomendação:

- **D3 — vagas curadas por fase, em dados**, no lugar da grade livre do GDD
  (8×6 a 24×14 com encaixe). O mapa de cada fase desenha os seus berços e os
  seus lotes; a tabela diz quantos são e o que abre.
- **D4 — reputação 0–100 em cada fase**, no lugar da escala contínua 0–3000
  do GDD, que fica como narrativa do crescimento. A barra que o jogador já lê
  e que a A3 calibrou na contra-oferta (`003`) não muda; cada fase diz onde
  ela começa.

## O que mudou

**A tabela `FASES` do `GameState`**, uma linha por fase (hoje só a 1), com
seis campos, todos obrigatórios:

| Campo | O que diz | Era |
|---|---|---|
| `semanas` | quanto a fase dura | `WEEKS_TOTAL`, e os dias `TURNS_TOTAL` |
| `parcelas` | cada cobrança: `semana` em que vence, `valor` (o boleto) e `juros` | `PARCELA_AMOUNT`, `PARCELA_2_AMOUNT`, `PARCELA_3_AMOUNT`, `JUROS_PARCELA_1..3`, `PARCELA_DUE_TURN`, `PARCELAS_NA_FASE` |
| `reparos` | o que se constrói: `semana` em que abre, `quitadas` que pede, `dias_de_obra` | `DIAS_DAS_OBRAS` e o `match` do `abertura_do_reparo()` |
| `nivel_maximo` | o nível do porto que as compras da fase alcançam | não existia: era emergente (a madeira da `086`) |
| `bercos` | quantos berços o mapa da fase desenha | `BERCOS_NO_MAPA` |
| `reputacao_inicial` | onde a barra começa | `REPUTATION_START` |

**As treze constantes SAÍRAM**, e o jogo lê a fase por funções:
`dados_da_fase()`, `semanas_da_fase()`, `turnos_da_fase()`,
`parcelas_na_fase()`, `valor_da_parcela(i)`, `juros_da_parcela(i)`,
`dia_da_parcela(i)`, `total_das_parcelas()`, `reparos_da_fase()`,
`bercos_no_mapa()`, `reputacao_inicial()`; o `dias_da_obra()` e o
`abertura_do_reparo()` passaram a ler a tabela. Os leitores fora do
`GameState` — cenas, ferramentas, suítes, a bateria — foram migrados: 157
trocas mecânicas em 19 arquivos e uma dúzia que pedia conta (os
`PARCELA_DUE_TURN * n`, que viram `dia_da_parcela(n - 1)`).

- **O número da fase não está no save.** `dados_da_fase()` devolve sempre a
  primeira linha; o save fica na versão **14**. Pô-lo lá é subir a versão, e
  isso é de quem trouxer a Fase 2 — quando houver uma segunda linha por onde
  escolher.
- **A janela do abatimento** (`valor_da_parcela_hoje()`) vai do vencimento
  anterior ao da parcela, e não os `PARCELA_DUE_TURN` dias de todas; com as
  três janelas de quatro semanas dá o mesmo número.
- **O calendário** marca os vencimentos da tabela, e não os múltiplos do
  primeiro.
- **O `@` da captura** (`capturar_cena.gd`) passou a chamar funções
  (`@valor_da_parcela:1`), como a régua do contraste já fazia; a bateria e o
  D33 usam-no no lugar de `@PARCELA_AMOUNT`.
- **A tabela dos números** ganhou a seção das fases (duração, parcelas com o
  capital, reparos), lida do despejo do Godot; o `projetar_parcelas.py` lê a
  primeira parcela da `FASES`.
- **O bloco F20 do `teste_fumaca`** (abaixo).

## Porquê assim

**As constantes saíram em vez de ficarem como apelido.** Um
`const PARCELA_AMOUNT = FASES[0]...` teria poupado cento e cinquenta trocas,
e continuaria a dizer o valor da Fase 1 quando a 2 existisse — nas cenas que
mostram «Dia X de 84», nas suítes, na bateria — sem erro nenhum. É a regra do
índice contra a identidade (`030`): o apelido é uma posição.

**`TURNS_PER_WEEK` e `START_CASH` ficaram globais.** A semana de sete dias é
a do calendário inteiro (`085`); o que muda de fase é quantas semanas. O
caixa é o da partida nova; o F20 confere que o capital das parcelas da Fase
1 é ele, que é o crédito da `085`.

**O pátio diz «semana 5» e não «o dia seguinte à primeira cobrança».** O
`abertura_do_reparo()` tirava-o do `PARCELA_DUE_TURN + 1`; a tabela escreve
as duas coisas, a semana e a quitada. Com a cobrança na semana 4 dão o mesmo
dia; quem mudar uma escreve a outra.

**O nível máximo é uma AFIRMAÇÃO, não uma trava.** As bancadas e as suítes
montam o porto de nível 3 dentro da Fase 1 (a folha da frota, o D41, os T de
nível), e um teto na lógica mudava-lhes as fotos. Fica como dado, e o F20
prova-o contra o jogo.

**A reputação traz o início, não o patamar.** O D4 fixa a escala; o patamar
para avançar entra com a regra da Fase 2 que o leia. A Fase 1 fecha-se pelas
três quitações (`085`), e um campo que nada lê seria declaração morta — a
mesma que o F19 recusa (`093`). O GDD pede ainda «mantido por três dias»,
que é desenho da Fase 2.

**As vagas do D3 são os berços e os reparos.** Quantos berços o mapa desenha
e que lotes a fase abre estão na tabela; ONDE ficam continua no mapa gerado
e nas âncoras, que é o que «curadas» quer dizer.

## A prova de refatoração pura

Medido numa cópia limpa da `main` (o ANTES) e na branch (o DEPOIS), em
sequência — as ferramentas partilham o `user://ferramentas/`.

- **O despejo do Godot:** 57 constantes antes, 45 depois; as 44 que ficam
  com o mesmo valor, e as treze que saíram reaparecem na `FASES` com o mesmo
  valor (os vencimentos e as aberturas conferidos dia a dia). O comparador
  reprovou os dois pares que se sabiam diferentes (o pátio na semana 6, o
  `ARMAZEM_BONUS` a 0,51).
- **A tabela dos números:** das 50 linhas de constante, 38 ficam com o mesmo
  valor, fonte e nota (só a nota da `TURNS_PER_WEEK` muda, com o comentário
  dela); as 12 que saíram estão na seção das fases; a tabela das estruturas é
  igual linha a linha. `TABELA OK`.
- **O simulador, 600 partidas por perfil, semente 20260825:** o JSON
  igual ao byte (o mesmo md5), e a saída de texto também.
- **A bateria de capturas:** 65 das 66 fotos iguais ao byte; a que muda é a
  `trabalhadores.png`, que muda também entre duas corridas da MESMA árvore —
  é a calibração, abaixo. O controle positivo: com o pátio na semana 6 a
  bateria mudou a `construir_semana5.png` e a `balanco.png`, logo ela vê a
  tabela.
- **O gravador, o leitor, a régua do boletim e o projetor das Parcelas:** a
  mesma saída dos dois lados, tirando a hora das gravações e o ruído de
  encerramento do motor (que também varia de uma corrida para a outra na
  base).
- **As seis suítes**, `DOCS OK`, `GUARDAS OK` e `ESCOPO UI OK`.

## O F20, e os treze mutantes

Três perguntas que as constantes não pediam, porque o compilador respondia:

1. **Os campos, e só eles**, em cada fase, parcela e reparo. O que falta
   rebenta longe da tabela (o M13 abaixo: 71 `SCRIPT ERROR`); o que sobra não
   rebenta em lado nenhum.
2. **As escalas que o jogo conhece:** parcelas por ordem e dentro da fase,
   juros parte do valor, reparos do catálogo que abrem dentro da fase e levam
   pelo menos um dia, reputação em 0–100, e no máximo UMA quitada por reparo —
   o `desbloqueio_da_estrutura()` diz «primeira».
3. **As afirmações que nenhuma regra lê:** o nível máximo contra o que os
   reparos alcançam (todo subconjunto que a cadeia de `requer` deixa
   construir, num porto acabado de abrir); os berços contra as docas e os
   cartões do `Main.tscn`; o capital da Fase 1 contra o `START_CASH`.

As duas primeiras correm em todas as linhas da tabela; a terceira só na fase
em jogo, até haver como pôr outra em jogo.

| # | Defeito | Reprova o F20 | Mais alguém? |
|---|---|---|---|
| M1 | um `berco` ao lado de `bercos` | os campos da fase | **ninguém** |
| M2 | `nivel_maximo` 2 | o nível alcançado (declara 2, alcança 1) | **ninguém** |
| M3 | o guindaste nos reparos da Fase 1 | o nível alcançado (declara 1, alcança 2) | o F18 |
| M4 | um juro de 9.920 | o capital (R$399.999) | **ninguém** |
| M5 | o pátio pede duas quitadas | no máximo uma | o F8g |
| M6 | parcelas fora de ordem | a ordem das parcelas | F8g, F10 |
| M7 | `piar_2` | o catálogo | F8a |
| M8 | reputação 650 | a escala 0–100 | **ninguém** |
| M9 | quatro berços | os berços do mapa | F12, F15 |
| M10 | o armazém na semana 13 | abre dentro da fase | F8g, F18 |
| M11 | obra de zero dias | pelo menos um dia | F8g, F18 |
| M12 | uma Fase 2 com juro igual ao valor | os juros da parcela 1 da Fase 2 | **ninguém** |
| M13 | o armazém sem `dias_de_obra` | os campos do reparo | F18, e 71 `SCRIPT ERROR` |

O original guardado por cópia e conferido por md5 depois de cada um, e a
suíte verde exigida entre todos. O M12 é o que prova que as perguntas 1 e 2
correm em toda linha, e não só na primeira.

## Achado de passagem

**A folha dos trabalhadores não tem semente.** Duas corridas da bateria na
MESMA árvore (a calibração) deram 65 de 66 fotos iguais ao byte; a
`trabalhadores.png` mudou 24.896 pixels: os rostos são os mesmos, o valor e o
motivo dos barcos nos cartões são sorteados a cada corrida. O CI já o
mostrava sem que se lesse: o antes/depois do PR #117, que só mexia em suítes,
marcou a `trabalhadores.png` «MUDOU» com as outras 65 iguais. Ficou fora deste
PR — mexer-lhe mudaria uma foto num item que tem de as deixar iguais —, e vai
no briefing.

## Para a Fase 2

- Uma segunda linha na `FASES`, e o F20 pergunta-lhe os campos na mesma
  corrida.
- O número da fase entra no save, a versão sobe, e o `dados_da_fase()` passa
  a lê-lo; o nível alcançado, os berços e o capital do F20 passam a correr
  por fase.
- O patamar de reputação entra com a regra de avanço que o leia.
- Quem puser o guindaste da treliça nos reparos sobe o `nivel_maximo` — o F20
  reprova antes (é o M3).
