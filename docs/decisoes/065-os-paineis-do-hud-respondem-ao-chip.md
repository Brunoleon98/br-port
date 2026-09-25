# 065 — Os painéis do HUD respondem ao chip: a segunda família da frente 3

**25/09/2026 · primeira passagem da segunda família da frente 3 do A5**:
dinheiro do dia, docas, reputação, calendário e parcela, os painéis que se
abrem por um toque no HUD. O Bruno escolheu esta família entre as três que
restavam (as outras eram as telas de texto e o sistema: pausa e menu) e
respondeu três perguntas antes do desenho. Fica à espera do veredito dele.

## O que o Bruno escolheu

- **Recordes da PARTIDA**, os quatro: melhor dia, mais barcos num dia, maior
  negócio e melhor semana. Zeram a cada partida e entram no save, então o
  **`SAVE_VERSION` sobe de 8 para 9**, e o save que ele tem no desktop é
  descartado uma vez. Recordes pessoais entre partidas ficaram de fora.
- **Reputação em três eixos**, como no GDD: a de hoje passa a chamar-se
  **Comercial** (é ela que mexe nos clientes e na negociação do Arlindo), e a
  Comunitária e a Imprensa aparecem trancadas, «abre na Fase 2», como os
  quadrados do menu-celular. O chip do HUD não muda.

## O que se decidiu

O vocabulário é o da primeira família (`062`–`064`): cabeçalho com selo, tarja
com linha de apoio e tom, quadros de número, a barra do HUD. Em cada painel:

| Painel | Tarja | E mais |
|---|---|---|
| Dinheiro do dia | o lucro ou prejuízo de ONTEM, no tom dele, com os barcos na linha de apoio | as contas como no boletim (o total na linha do bloco, as parcelas por baixo); o dia projetado fecha numa linha de total, SEM tarja, porque é previsão; os quatro recordes em quadros |
| Docas | «A receber: R$…», só das docas com trabalhador; a perda da doca parada na linha de apoio | três quadros (trabalhando, sem trabalhador, vazias) e um quadro por doca: o TIPO DE TRABALHO (o motivo), a classe do navio, quando paga, quem trabalha e, se houver, o bónus do armazém ou do pátio |
| Reputação | — | a Comercial num quadro com a barra de 0 a 100 e quanto falta para o degrau seguinte; os dois eixos trancados; «o que mexe» em coluna, com o tamanho alinhado à direita |
| Calendário | «Dia N de 32», com a semana e o vencimento na linha de apoio | a grelha não muda |
| Parcela | «Quitar hoje: R$…», com o valor cheio e o abatimento na linha de apoio | a barra do HUD contra o valor de hoje; quitada, a tarja verde |

- **A renda da doca inclui o bónus**, porque é o que entra no dinheiro, e sai
  do `GameState.receita_da_doca()`, que passa pelo MESMO `_lancar_receita()`
  do `advance_turn()`. O cartão do rodapé mostra o valor do BARCO; a linha
  «R$… do barco + R$… do armazém» diz de onde vem a diferença.
- **A doca sem trabalhador não soma no «a receber»**: o barco dela sai na
  virada sem pagar. Vai para a linha de apoio como perda, que é o que o
  jogador ainda pode evitar.
- **O dia entra no recorde uma virada depois.** O `pay_debt()` escreve a
  parcela no `dia_anterior` DEPOIS de o dia ter virado, e gravar na virada
  punha o dia 32 como um dia bom com R$530.000 ainda por sair dele. O
  `_recordes` guarda os dias anteriores ao `dia_anterior`, e quem lê é o
  `recordes()`, que soma o `dia_anterior` vivo. O maior negócio grava-se no
  pagamento, porque o valor de um barco não muda depois de ele sair. A melhor
  semana sai do `historico_semanas`, que já existia.
- **O bloco de contas e o quadro passaram para o andaime**
  (`PainelNarrativo.bloco_de_contas()`, `grade_de_quadros()`, `quadro()`),
  copiados sem mudança do boletim e do balanço. As fotos dos dois saíram
  idênticas em byte, o que prova a mudança. O andaime pega o `GameState` pela
  árvore: é um `class_name`, e o autoload não resolve pelo nome lá dentro.

## A guarda: F15 do `teste_fumaca`

Irmã do F14: cada número lê-se na TELA e confere-se contra uma fonte que o
painel não usa, em seis caminhos com bandeira própria.

- **Docas**: com o armazém e o pátio construídos (sem eles o bónus é zero, e a
  conta certa e a que o esquece dão o mesmo número), um barco de cada vez, e o
  que o quadro promete contra o dinheiro que entra na virada: armazenagem,
  contêiner, pescado e preço fechado com o rival. A perda da doca parada contra
  o que o MESMO barco paga com gente, e **uma doca com gente ao lado de outra
  sem**, que é o único estado em que somar a parada ao «a receber» diverge.
- **Recordes**: um observador joga 25 dias e mede cada dia pela variação do
  dinheiro, os barcos pelas `metrics` e cada semana pela soma dos seus dias.
  Os recordes atravessam o save iguais.
- **O dia 32**, com um barco de R$4.000.000: o melhor dia com a parcela ou sem
  ela, e só o valor separa as duas.
- **Reputação**: o «faltam X para Y» contra o `reputation_label()` a X de
  distância e um pouco antes. **Parcela**: o «Quitar hoje» contra o que o
  botão tira. **Calendário**: o dia e a semana do jogo.
- A tabela de tom do F14 ganhou as tarjas novas, todas neutras (previsões e
  estados, não resultados), e a parcela quitada, verde.

**Oito defeitos injetados, oito reprovações pela guarda certa**, com o
original guardado por `cp` e a base verde entre cada um: a renda sem o bónus
(9 falhas), o dia gravado na virada (1, só o caminho do dia 32), o maior
negócio pelo bruto (1), a melhor semana sempre a primeira (1), o degrau
seguinte sempre o do topo (1, só a 20,95), a parcela a mostrar o valor cheio
(3), a tarja das docas em verde (4) e a doca parada somada ao «a receber» (1,
só o caso misto).

**E um erro da fixture apanhado pelo caminho**: o barco de teste levava a
classe «cargueiro», que não é chave (é `medio`). O painel rebentou no acesso
direto, como deve, e o F15 passou na mesma, porque os números já estavam
escritos antes da linha que rebentou. Quem o denunciou foi o `SCRIPT ERROR` no
log, que o CI varre nas suítes (`031`).

## Medido

- Mudaram **5 das 72 fotos**: exatamente as cinco dos painéis do HUD.
  Boletim e balanço saíram idênticos.
- Seis suítes verdes, `ESCOPO UI OK`, `GUARDAS OK`, `COBERTURA OK`, `TABELA
  OK` (o `SAVE_VERSION` é uma `const` do `GameState`); contraste: **406 textos
  em 25 estados**, nenhum abaixo do AA. O rótulo do quadro sai a 5,03:1, a
  linha de apoio da tarja a 5,27:1, o número grande a 11,59:1.
- O simulador com 600 partidas dá os mesmos **100% / 80,2% / 37,3%**, com a
  mediana do Mediano em R$716.179: os recordes não sorteiam nada e não mexem
  no dinheiro.

## O que ficou de fora

- O chip da reputação continua sem o nome do eixo: cabe só uma, e é esta.
- A grelha do calendário e a legenda não mudaram; o pedido do Bruno para ele
  foi o da frente 1 (a legenda, que o D36 tranca).
- A régua de contraste monta as docas no estado «nenhuma doca trabalhando»;
  os outros estados das docas medem-se por semelhança (as mesmas variações
  sobre o mesmo fundo), não por percurso.
