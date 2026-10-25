---
paths:
  - "brport_vs/autoload/GameState.gd"
  - "brport_vs/scripts/ArmazemLocal.gd"
  - "brport_vs/scripts/PainelEspacos.gd"
  - "brport_vs/tests/teste_fumaca.gd"
  - "brport_vs/tests/saves/*.json"
  - "brport_vs/tools/gravar_save_de_exemplo.gd"
  - "tools/sentinela_do_jogador.py"
---

# Regras — o save

> Carrega quando a sessão lê ou edita um arquivo do `paths:` acima. Veio do
> `CLAUDE.md` em 10/10, palavra por palavra (`docs/decisoes/091`); o índice
> de todas as regras está no núcleo. Lição nova deste tema entra aqui.

### Save

`SAVE_VERSION` sobe **sempre** que a forma ou a interpretação do estado muda.
A fila ocupou a versão 10 (`083`); a reescala monetária subiu para 11 (`084`).
As três cobranças, o calendário e os recibos subiram para 12 (`085`):
o booleano antigo só representava a primeira quitação. A madeira durante toda
a Fase 1 subiu para **13** (`086`), com autorização explícita do Bruno:
a 12 podia guardar cargueiros após dois reparos, incompatíveis com essa máquina.
A obra em andamento ocupa a **14** (`087`), autorizada explicitamente pelo
Bruno junto dos prazos. A segunda chance do Sr. Ribeiro ocupa a **15**
(`102`), a primeira acima do piso, autorizada COM o degrau: o 14→15 escreve
«sem dívida, chance por usar» e a linha `emprestimo` da semana, e o T19
prova-o contra o `v14.json`. O exemplo `v15.json` joga mal o primeiro mês de
propósito, para trazer a dívida — um exemplo que nunca a pediu grava-a a zero.
O número da fase ocupa a **16** (`104`), com o M9; o T20 prova o 15→16 contra
o `v15.json`.
Os marcos da meta ocupam a **17** (`106`), autorizada pelo Bruno com
migração: o degrau 16→17 mantém a partida e começa dias, missão e conquista
a zero, pois a 16 não registrava esse passado. O T22 prova-o; o exemplo 17
chega à conquista com obra viva, e os exemplos 14–16 ficam intactos.
A **18** (`111`), aceite com migração, guarda despesas e acumuladores do
cancelamento. O degrau 17→18 põe os campos novos a zero e conserva a partida;
o T24 prova a retomada com multa já paga e saldo negativo antes do fecho.
O exemplo 18 joga um cancelamento real; os exemplos anteriores ficam intactos.
A **19** (`140`), autorizada pelo Bruno nesta entrega, guarda compras e cenas
lidas em `vida_do_porto` e a despesa `lojas` nas contas do dia/semana. O degrau
18→19 começa esses campos vazios e preserva o porto; o T32 prova migração,
retomada e isolamento dos espaços. O exemplo 19 compra os dois itens e conclui
conversas reais; os exemplos 14–18 ficam intactos.
Saves 13 e anteriores são recusados sem migração: partidas antigas recomeçam.
Consulta preserva o arquivo; carregamento descarta o incompatível antes de
aplicar campos, inclusive a obra viva. Até a 14, save de outra versão era
descartado, não adaptado. Já custou um porto com 4 docas num mapa que desenha 3.

**Desde a `098` a 14 é o PISO, e o save sobe por DEGRAUS** — a resposta do
Bruno ao D5. Cada versão nova traz, em `_migrar_um_passo()`, o degrau de N
para N+1; a cadeia corre numa cópia DENTRO do `_save_aceite()`, antes de
todas as recusas, e o que ela entrega passa por elas como se a corrente o
tivesse gravado. O que nenhum degrau lê continua recusado — o piso não se
confere à parte, quem recusa é a cadeia. **Subir a versão pede, no mesmo
commit:** o degrau; o exemplo da versão nova
(`brport_vs/tools/gravar_save_de_exemplo.gd` grava `tests/saves/vNN.json`
jogando uma partida semeada até ao save ter tudo); e o exemplo da anterior
INTACTO, que é quem prova o degrau. O F21 do `teste_fumaca` exige um exemplo
por versão, do piso à corrente, todos a carregar, e a ida e volta exata do
corrente. Exemplo de versão que já chegou à main não se regrava: é o registo
do que ela gravava. O que o degrau faz a cada campo prova-se num teste dele.
⚠️ **E O PEDIDO EXPLÍCITO DO BRUNO CONTINUA** (`AGENTS.md`): a migração muda
o preço de subir — a partida do jogador já não recomeça —, não quem decide.

**E recusar é recusar sem ter tocado em nada.** O `load_game()` escrevia os
campos um a um e só conferia a sanidade do roster no fim: um save recusado
deixava o `turn` e o `cash` do arquivo no estado vivo, com zero docas. Passava
despercebido porque o `new_game()` que vem a seguir por acaso reescreve todos
os campos — uma segurança que dependia de duas funções distantes continuarem a
concordar sobre a lista de campos, e que um campo novo teria quebrado calada.
**Tudo o que recusa vem antes de tudo o que escreve**, e o `teste_fumaca.gd`
tranca isso.

**São três espaços, e o 1 é o arquivo de sempre** (`docs/decisoes/066`): o
`savegame.json` que o jogador já tinha aparece no espaço 1 sem migração, e o
`SAVE_VERSION` não subiu. **Ler um espaço não é carregá-lo**: o
`resumo_do_espaco()` usa as MESMAS recusas do `load_game()` (`_save_aceite`)
e não apaga nada; quem apaga é a partida nova que o ocupa. O «jogado por
último» é a hora do ARQUIVO — um carimbo no JSON mudaria a forma. O F16 tranca
as três coisas.

**O número da fase está no save desde a 16** (`104`), como a `094` previu:
`numero_da_fase`, lido pelo `dados_da_fase()`. O degrau 15→16 escreve `1`, e
a partida GANHA da 15 — as três pagas, fim de jogo vencido — sobe já na
Fase 2 do dia 85, com os recomeços da passagem: é o que a 16 diz que ela é,
e não adivinhar. O `_save_aceite()` lê a fase do ARQUIVO antes de tudo e
recusa contra ela a obra, a cobrança e o dia — o resumo dos espaços lê os
três com uma partida viva, e o mesmo arquivo não pode ser aceite ou recusado
conforme a fase do vizinho (o T20 prova os dois sentidos). O exemplo
`v16.json` é jogado BEM até à Fase 2: a dívida da segunda chance e a parcela
quitada são zero lá por regra, e a lista do que ele traz troca-as pelo
recibo da Fase 1 no `total_pago_parcelas`. A 16 levou também o M9: o
`upgrade_purchased` saiu, e o estado do turno passou a ser recusado fora dos
quatro `ESTADOS_DO_TURNO`.
