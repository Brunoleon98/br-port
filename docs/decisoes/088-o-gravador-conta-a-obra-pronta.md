# 088 — O gravador conta a obra pronta e as semanas do cabeçalho

**10/10/2026.** Main `3a62fb4` (PR #111 fundido, nenhum PR aberto do Codex);
088 livre conferida na main antes de escrever. É o **M1** da fila de
`docs/REVISAO_GERAL_2026-10-09.md` (§6), achados O2 e O3 da revisão do PR #110.

## O que estava errado, medido

Cinco partidas do `gravar_partidas.gd` (semente 20260902), lidas pelo leitor de
antes:
- «O porto que se levanta» publicava o dia do **pagamento** — `pier_2` no dia
  1, `patio` no 34 — e contava como feita a obra a meio. Desde a `087` a obra
  leva dias, e o gravador só ouvia o `estrutura_comprada`: a sonda presa a um
  ponto de passagem que deixou de passar tudo (`CLAUDE.md`, regra 7).
- A primeira e a última semana saíam de `t <= 8` e `t > 24` — semanas de 8
  dias numa fase de 4. Com 12 de 7 (`085`), a «semana 4» ia da 4 à 12.

## O que mudou

- **`Registro.gd`, versão 2.** Ouve o `obra_concluida` e grava
  `{"e": "obra_pronta", "id", "t"}`, com o `t` do dia NOVO — o «pronto no dia
  N» que a compra prometeu, porque o `advance_turn()` soma o dia antes de
  concluir. O cabeçalho grava `turnos_por_semana`. A linha da compra continua
  a chamar-se `obra`, para os registros da versão 1 continuarem legíveis.
- **A versão, e não a falta da linha, diz se o dia pronto se sabe.** Numa
  partida da versão 1 a conclusão nunca foi gravada (antes da `087` a compra
  era a obra pronta; depois, não): o leitor diz «não sei». Na 2, a linha que
  falta quer dizer «ficou por acabar até ao fim do registro». Registro velho
  não se descarta — a regra do cabeçalho do `Registro.gd`.
- **`tools/ler_registros.py`.** Por estrutura, o dia pago e o dia pronto; as
  semanas pelo calendário do cabeçalho de CADA partida, sem valor de omissão —
  quem não traz o campo fica a «não sei», que é a regra do `.get(chave,
  omissão)`.
- **O tempo de uma linha `turno` é do dia ANTERIOR ao `t` dela.** A linha sai
  quando o dia vira, com o `t` do dia novo, e o `ms` é do dia que fechou. Lida
  pelo `t`, a semana 1 de 7 ficava com seis dias. Achado ao escrever a prova; o
  relatório passou a dizer «dia N» em vez de «tN».

## A prova, com os mutantes

- **`teste_registro`, bloco R7.** Compra o píer 2, avança até o jogo o dar por
  pronto e exige UMA linha `obra_pronta` no dia em que o `tem_estrutura()`
  virou verdadeiro — o esperado sai do jogo, não da conta do prazo —, nenhuma
  no dia do pagamento, e o calendário no cabeçalho. Reprovaram os quatro
  mutantes: sem o ouvinte (0 linhas), ouvinte preso ao pagamento (dia 1 contra
  3), `t` um dia atrás (2 contra 3) e cabeçalho sem o campo.
- **O autoteste do leitor corre antes de toda leitura**, e sem ele não há
  `LEITURA OK` (o `--autoteste` do `medir_audio.py`). Uma partida fabricada de
  84 dias e 7 por semana, com o tempo de cada dia igual ao número da semana em
  segundos: a resposta certa é uma LISTA exata. ⚠️ **A mediana escondia o
  mutante do 8 cravado**: a semana 1 com o dia 8 dá `[1000 ×7, 2000]`, cuja
  mediana continua 1000. Reprovaram os nove: o `t` sem o −1, o 8 cravado nas
  duas pontas, o `t <= 8` e o `t > 24` antigos, o 7 por omissão, o pronto igual
  ao pago (nas duas formas), a versão ignorada e a «semana 4» no texto.
- As seis suítes verdes; o fluxo do CI (gravar 5 → ler) publica píer 1 → 3,
  armazém 18 → 20 e pátio 34 → 37 em mediana — os prazos da `087` — e os
  registros de antes leem-se com «não sei».

## O que fica de fora

O `gravar_partidas` e o leitor são a metade de máquina do A7; nenhum jogador
real foi lido. O `GameState.gd` não mudou, e o save também não.
