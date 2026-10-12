# 103 — A progressão para a Fase 2: o recorte seguinte da frente 5

**12/10/2026.** Base `9c9bdac` (o PR #126, a segunda chance, fundido); 103
livre conferida na main pelo GitHub, sem PR aberto do Codex. Recorte da
frente 5 escolhido pelo Bruno nesta conversa, entre a progressão, o
cancelamento de trabalho, mais trabalhadores por píer e a linha voluntária
de crédito. As falas do A4 (três do Toninho, duas do Sr. Ribeiro) ainda não
foram lidas em voz alta. Esta decisão só desenha: nenhuma linha de jogo
mudou.

## O que se leu antes de perguntar

O GDD (`gdd/sistemas/phases.md`) sobe de fase por **três barras em
paralelo** — reputação mantida três dias, infraestrutura erguida, missão
narrativa —, **sem prazo** («pressão narrativa, sem timer»), e a fase
conquistada é permanente: se a reputação cair abaixo do mínimo, «contratos
e clientes somem até ela se recuperar». A Fase 2 é o «Cais com Oficina»,
com «guindastes novos» (`gdd/conceitos/construcao.md`: posto, câmara fria,
segundo píer comercial, escritório; Kinha e Carol contratáveis). O teto de
pessoal sobe de 3 para 6 (`gdd/conceitos/contratacao.md`). E a dívida
herdada são três parcelas em doze semanas (`gdd/conceitos/dividas.md`) —
**a Fase 1 do jogo já as cobra todas**: depois do dia 84 não há dívida no
GDD, só as linhas voluntárias
(`gdd/conceitos/banco_investimentos.md`: a Linha Crescimento, fases 2–3).

No código: a `FASES` tem uma linha, e a `094` fê-la para receber a
segunda; o catálogo já tem o píer 3, o escritório, o pórtico e o cais, com
arte; a treliça (nível 2 do guindaste) existe só nas bancadas (`086`); o
cargueiro é a classe de nível 2, de dois dias (`009`); o trabalhador vem
com o píer. E a leitura da `102` decidiu a ordem: na Fase 1 todo serviço
acaba no dia e quem trava a obra é o calendário, logo o cancelamento, o
segundo trabalhador e a linha voluntária só ganham uso com barco de dois
dias e mais o que construir — o que só a Fase 2 traz.

## As respostas do Bruno

| Pergunta | Resposta |
|---|---|
| O recorte | **A progressão para a Fase 2** (a recomendada) |
| O A4 | Ainda não lido |
| O que abre a Fase 2 | **As três quitações**, como hoje: a página do diário da Fase 1 passa a seguir para a Fase 2, e a partida continua no dia 85, no mesmo save (a recomendada) |
| O que faz pressão | **Sem dívida, uma meta de avanço** — fiel ao GDD. A recomendada era um crédito novo em parcelas, que reaproveitaria a cobrança, a segunda chance e o simulador |
| O que se constrói | **Píer 3, escritório e treliça**, só o que já tem arte; o pórtico e o cais ficam para a Fase 3 (a recomendada) |
| A meta | **Reputação + infra + missão**: a reputação acima de um patamar três dias seguidos, o píer 3 e a treliça de pé, e o primeiro cargueiro atendido (a recomendada) |
| Cumprida a meta | **Uma página do diário fecha a Fase 2 e o jogo segue livre**, até a Fase 3 existir (a recomendada) |
| O que pode correr mal | **O caixa e a regressão do GDD**: perde-se o porto com o caixa negativo num fecho, como hoje; e a reputação abaixo do piso faz os cargueiros deixarem de vir até ela voltar (a recomendada) |
| O save | **16, com o degrau 15→16 e o M9** junto (a recomendada) |

## O desenho

- **A passagem.** A terceira quitação deixa de ser `game_over`: a página do
  diário da Fase 1 (`082`) fecha a fase e segue para a Fase 2 no dia 85. O
  calendário é o da partida inteira (`TURNS_PER_WEEK`): a semana 13 abre a
  Fase 2, e o boletim continua.
- **A segunda linha da `FASES`.** Sem `parcelas` (não há cobrança), sem
  prazo, `nivel_maximo` 2, os mesmos três berços (o píer 3 é o terceiro, que
  hoje está em ruína) e os três reparos abertos desde o primeiro dia dela,
  uma obra de cada vez como na `087`. Os preços, os dias de obra, a
  reputação inicial e os dois patamares são `# TUNING:` e saem da
  `/balancear` — a `094` já deixou o início da reputação para a fase, e a
  escala 0–100 por fase é a do D4.
- **A treliça é uma compra nova da Fase 2**, o nível 2 do guindaste, que
  hoje só a bancada monta (`086`). Com ela e o píer no nível 2, o porto
  passa a nível 2 (`nivel_do_porto()`, o menor dos dois) e o cargueiro de
  dois dias atraca — e o adicional de contêiner do pátio ganha cliente.
- **A meta tem três barras e dois números de reputação.** A pergunta não os
  separou, mas as duas respostas pedem-nos: a **meta**, que conta três dias
  seguidos para o avanço, e o **piso**, abaixo do qual os cargueiros deixam
  de vir. O piso fica abaixo do início e a meta acima dele, senão o jogador
  entra na Fase 2 já sem os clientes dela. A missão é o primeiro cargueiro
  atendido — o «primeiro navio grande aportando» que o GDD dá de exemplo —,
  e as três barras mostram-se num painel, como o GDD pede («painel claro»).
- **Cumprida a meta, o jogo não acaba.** Uma página do diário fecha a Fase
  2, e a partida segue sem meta até a Fase 3 existir. Perde-se só pelo caixa.
- **A segunda chance não aparece na Fase 2**, porque não há cobrança: é a
  regra da `102` («só onde há cobrança seguinte»), não uma exceção nova.

## O que a escolha sem dívida muda

A recomendação era o crédito em parcelas porque o jogo de hoje se mede pela
cobrança: o simulador conta quem paga, o projetor das Parcelas e a segunda
chance vivem dela. Sem ela, a Fase 2 mede-se por outra pergunta — **em
quantos dias cada perfil cumpre a meta, e quantos quebram antes** —, e o
simulador tem de a aprender. Sem prazo e sem dívida, nada impede o jogo de
ser fácil: o único dreno é o custo semanal. Se a medição mostrar que todo
perfil cumpre a meta sem risco, a pergunta da pressão volta ao Bruno com o
número na mão — e o que o GDD põe nesse lugar (o Sr. Abutre a apertar) não
existe no jogo.

## O save 16 e o M9

O número da fase entra no save (`.claude/rules/save.md`: o
`dados_da_fase()` passa a lê-lo) e o degrau 15→16 escreve `1` nos saves de
antes, com o `v16.json` de exemplo jogado até à Fase 2 e o `v15.json`
intacto. O **M9** vai na
mesma subida — é a resposta da D1b, «só junto da próxima subida que outro
recorte precise»: saem o `upgrade_purchased` e o `buy_upgrade()`, e os
estados de turno (`"playing"`, `"game_over"`…) viram constantes. Com a
progressão isto deixa de ser só limpeza: o `phase` do turno e a «fase» da
campanha passam a conviver no mesmo arquivo, e a revisão de 09/10 já
anotava que os dois nomes se confundem.

## As etapas, uma por sessão

1. **A passagem e o save.** A segunda linha da `FASES`, a fase no save
   (16, com o degrau e o M9), a página da Fase 1 a seguir para a Fase 2, e
   a Fase 2 jogável sem meta. ⚠️ **A fase sem prazo é o grosso dela:** a
   duração é lida em 74 sítios de 15 arquivos (`turnos_da_fase()` e
   `semanas_da_fase()`, contados nesta sessão) — calendário, boletim,
   menu, registro, simulador, suítes —, e o F20 exige o campo. O simulador
   continua a medir a Fase 1 e pára na passagem: a prova é a paridade com a
   main, campo a campo.
2. **A treliça e o cargueiro.** A compra da treliça, o porto de nível 2, o
   cargueiro de dois dias no jogo, com a arte das bancadas e a captura.
3. **A meta, a regressão e o fim.** O painel das três barras, os três dias,
   a missão, o piso, a página do diário da Fase 2 e o jogo livre a seguir.
4. **A medição.** O simulador aprende a Fase 2 (dias até a meta, quebras
   por perfil) e a `/balancear` fecha os preços e os patamares.

Depois delas, os três recortes que esperavam a Fase 2 — o cancelamento, os
trabalhadores extras (até 6, pelo GDD) e a linha voluntária — passam a ter
onde agir, e voltam a ser perguntados ao Bruno.

## O que fica de fora

- **As estruturas novas do GDD** (oficina, posto, câmara fria) e a Kinha e
  a Carol: pedem arte e motivos novos.
- **O pórtico e o cais**: Fase 3.
- **O Sr. Abutre e o rival mais agressivo**: a pressão da Fase 2 é o caixa
  e a regressão, e volta ao Bruno se a medição a der por fraca.
- **As falas**: a passagem, a missão e a página da Fase 2 precisam de texto
  novo, e ele vai para a leitura do A4 com os outros rascunhos.
