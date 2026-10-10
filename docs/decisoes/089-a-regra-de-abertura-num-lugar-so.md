# 089 — A regra de abertura num lugar só

**10/10/2026.** Main `ed096cb` (PR #112, o M1, fundido; nenhum PR aberto do
Codex); 089 livre conferida na main antes de escrever. É o **M2** da fila de
`docs/REVISAO_GERAL_2026-10-09.md` (§6), achados O1 e O6 da revisão do PR #110.

## O que estava errado, medido

O dia em que cada reparo abre vivia em dois sítios. O botão
(`desbloqueio_da_estrutura()`) tirava-o da semana (`current_week() < 2`) e do
vencimento (`turn <= PARCELA_DUE_TURN`); o `_save_aceite()` escrevia
`8 if armazem else 29 if patio else 1` e, à parte, «pátio exige uma quitada».
Coincidiam. Medido no código de antes:
- **o save sozinho, com o armazém no dia 9, passou as seis suítes** — nenhum
  bloco carregava uma obra começada no dia em que o reparo abre. Era este o
  buraco: um `TURNS_PER_WEEK` ou um prazo de cobrança mudados recusariam saves
  válidos sem uma palavra;
- ⚠️ **o mutante que a revisão previa** — «o armazém na semana 3, só no
  desbloqueio; hoje passaria» — **reprovou seis asserções**: o T5b, o T14 e o
  T15 compram o armazém no primeiro dia da semana 2 pelo BOTÃO. A ponta
  desguardada era a outra. É «a previsão de quem reprova mede-se nesse dia» (`CLAUDE.md`,
  regra 7), e foi medida antes de escrever código.

E a obra lida do save ficava com os `float` do JSON (O6): funcionava porque
toda leitura passa por `int()`.

## O que mudou

- **`abertura_do_reparo(id)`** devolve `{"dia", "quitadas"}` — píer 2 no dia 1;
  armazém em `TURNS_PER_WEEK + 1`; pátio em `PARCELA_DUE_TURN + 1`, com uma
  quitada — e `{}` para o que não se compra nesta fase.
- O **botão** e o **save** leem dela. O texto «Abre na semana N» passa a sair
  do `week_of()` do dia de abertura; o do pátio continua a dizer «primeira»,
  com o aviso ao lado de que essa palavra é a quitada que a função pede.
- A regra é a MESMA: `current_week() < 2` é `turn < 8`, e `turn <= 28` é
  `turn < 29`. A tabela dos números saiu idêntica (as constantes ficam acima
  das linhas mexidas), o `SAVE_VERSION` não sobe e a forma do save não muda.
- O `load_game()` escreve a obra com `int` (O6).

## A prova: o T17, relacional

O dia esperado sai de **andar o calendário** — uma partida inteira, a quitar
antecipado no dia 1 — e perguntar ao botão; nunca de ler a função nem de
escrever 8 e 29. Para cada reparo: a obra começada na véspera é recusada e a
do próprio dia aceita; com o mínimo de quitadas que o BOTÃO pede o save aceita,
com uma a menos recusa; a obra carregada sai com inteiros. E conta o que a
derivação achou: o botão abre na fase toda obra que tem prazo, e só essas.

Duas armadilhas desenhadas para fora:
- **quem aperta na véspera do pátio tem de ser o DIA.** A véspera é o dia da
  cobrança, e um porto que ainda não pagou seria recusado pela cobrança com o
  dia certo ou errado. A partida quita no dia 1, e o bloco confere que o
  recibo não aperta ali;
- **a metade da cobrança vive num estado que o jogo não faz:** do dia 29 em
  diante todo porto vivo já pagou, e com o recibo real as duas versões da
  regra dão o mesmo. A fixture tira o recibo de propósito, de forma coerente
  (índice e pago), para que quem recuse seja a abertura e não o recibo.

Nove mutantes, cada um num sítio só:

| Mutante | Quem reprova |
|---|---|
| botão: armazém na semana 3 | T17 (véspera 14 aceita) e os valores do T5b/T14/T15 |
| botão: pátio no dia 30 | T17 (véspera 29 aceita) e os valores do T5b/T14/T15 |
| save: armazém no dia 9 | **só o T17** |
| save: armazém no dia 7 | **só o T17** |
| botão sem a cobrança | **só o T17** |
| save sem a cobrança | **só o T17** |
| obra lida com `float` | **só o T17** |
| save conhece o píer 3 | **só o T17** (a contagem) |
| a função: armazém na semana 3 | o T17 **passa** — as duas pontas andam juntas —, e o T5b/T14/T15 reprovam pelo valor |

O último é o que mostra a regra num lugar só: mudar a abertura é mudar uma
linha, e quem a crava são os blocos de valor (T5b, T14, T15), que é onde o
calendário aprovado (`085`) se afirma.

## O que fica de fora

- O `capturar_tela.gd` ainda lista à mão os três reparos que o balanço
  compra; pergunta ao `impedimento_estrutura()`, logo respeita a regra. A
  tabela de fases é o M7.
- O save confere as quitadas de HOJE, e não as do dia em que a obra começou.
  Elas só sobem, e o botão é quem escreve a obra.
- A obra que só fica pronta no fecho do dia 84 é o D8, e o M3 espera a
  resposta do Bruno.
