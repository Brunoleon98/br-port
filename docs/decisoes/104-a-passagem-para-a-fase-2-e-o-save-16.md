# 104 — A passagem para a Fase 2 e o save 16: a etapa 1 da `103`

**12/10/2026.** Base `db03860` (o PR #127, a `103`, fundido); 104 livre
conferida na main pelo GitHub, sem PR aberto do Codex. As falas do A4 (três
do Toninho, duas do Sr. Ribeiro) continuam por ler: não havia notas a aplicar
primeiro. Esta sessão faz a etapa 1 da `103` — a passagem e o save — e mais
nenhuma: a treliça, a meta e a medição são as etapas 2 a 4.

## O que ficou no jogo

As três quitações deixaram de ser fim de jogo. Pagar a terceira (ou virar o
dia 84 com ela quitada antes) põe a partida na **Fase 2 no dia 85**, no mesmo
save, sem dívida e sem prazo; a página do diário da Fase 1 abre por cima do
jogo, com o balanço, e sai por «Seguir para a Fase 2». Perde-se só pelo
caixa. A Fase 2 joga-se livre: o píer 3 e o escritório abrem desde o
primeiro dia dela, o calendário continua (a semana 13 é a primeira), o
boletim fecha toda semana e o rodapé diz que não há dívida.

## As escolhas desta sessão

A `103` desenhou a etapa; estas são as decisões de implementação que ela
deixou abertas, tomadas aqui.

- **A passagem é imediata, e não um estado do turno.** O `_check_end()` passa
  à fase seguinte e o `Main` abre a página por cima, ao ouvir
  `fase_concluida` — a regra «tela nova é overlay, nunca fase do
  `GameState`» (`interface.md`): o simulador e as suítes não abrem painel, e
  um estado à espera de um toque travá-los-ia. O preço: quem fechar o jogo
  com a página aberta volta já na Fase 2, sem ela.
- **O sinal sai ANTES de a fase mudar.** Quem o ouve lê o estado da fase que
  fecha: o simulador a reputação final da Fase 1, o balanço a mesma, e o
  gravador a linha de desfecho. Emitido depois, os três leriam a da Fase 2,
  sem erro nenhum.
- **A fase sem prazo é `semanas: null`.** O `int(null)` rebenta, e um zero
  ler-se-ia como «acabou ontem» (`gerais.md`). Quem pede a duração pergunta
  antes pelo `fase_tem_prazo()`; quem lê a parcela corrente, pelo
  `tem_cobranca()`. As funções de fase ganharam o `n` explícito, porque a
  página da Fase 1 abre já na 2 e o save confere-se contra a fase dele.
- **O calendário é o da partida inteira** (`inicio_da_fase()`); a semana de
  uma parcela ou de um reparo conta-se do início da fase dele.
- **A Fase 2 reabre os três reparos da Fase 1.** A `103` pedia o píer 3 e o
  escritório; sem os outros três, quem chegasse ao dia 85 sem o armazém
  ficava sem ele para sempre. Os dias de obra dos dois novos (3 e 2) e a
  reputação de partida (65, a da Fase 1) são provisórios até à etapa 4.
- **O `nivel_maximo` da Fase 2 é 1, e não o 2 da `103`.** O 2 é o que a
  treliça alcança, e ela é a etapa 2: hoje nenhuma compra da Fase 2 tira o
  guindaste da madeira, e o F20 confere o declarado contra o alcançado,
  igual. Quem trouxer a treliça sobe os dois juntos.
- **Recomeça o que é de cada fase:** a cobrança (índice, recibo e quitadas —
  o que a Fase 1 pagou fica no `total_pago_parcelas`), a segunda chance (uma
  por fase, `102`) e a reputação, que volta à escala da Fase 2 (D4). Achado
  pelo caminho: a Dona Cida ia anunciar esse recomeço como «Andaram recusando
  contrato, chefia» no dia em que as três foram pagas. A narradora passou a
  ouvir a passagem, e o F23 prova-o com o controlo de uma queda de verdade.

## O save 16 e o M9

O `numero_da_fase` entra no save, e o `_save_aceite()` lê-o antes de tudo e
recusa contra ele a obra, a cobrança e o dia: o resumo dos espaços lê os três
com uma partida viva, e o mesmo arquivo não pode depender da fase do vizinho.
O degrau 15→16 escreve a Fase 1 — e **a partida ganha da 15 sobe já na Fase 2
do dia 85**, com os recomeços da passagem: na 16 é isso que ela é, e deixá-la
no fim de jogo prendê-la-ia numa página que diz «segue». O estado do turno
passou a ser recusado fora dos quatro conhecidos.

O exemplo `v16.json` foi jogado **bem** até à Fase 2 (dia 87, píer 3 em
obra): o primeiro mês mal jogado da 15 não chega à segunda cobrança (medido:
sem caixa no dia 57), e a dívida que ele trazia a passagem zera na mesma. O
`v15.json` ficou intacto, e o T20 prova o degrau contra ele.

O **M9** foi na mesma subida (D1b): os estados do turno são as constantes
`ESTADO_*` no código do jogo, e saíram o `upgrade_purchased` e o
`buy_upgrade()`.

## O que mais a passagem tocou

- **A interface sem prazo:** o dia do HUD, o cartão da parcela, o
  calendário (a semana de hoje e as três seguintes, sem a legenda do
  vencimento), o celular, a pausa, a linha do espaço e o boletim. Olhados em
  foto a partir do `v16.json`. Os textos novos são informação do jogo, não
  fala; a página e a missão da Fase 2 ficam para a etapa 3 e para o A4.
- **O gravador sobe à versão 4**, com a linha `fase` no lugar do `fim` de
  quem pagou; o leitor conta-a como a Fase 1 ganha, e o `fim` de uma Fase 2
  perdida depois não a desdiz.
- **O simulador mede a Fase 1 e pára na passagem** (`FASE_MEDIDA`).

## A paridade com a main

A prova pedida pela `103`: as mesmas 600 partidas por perfil, semente
20260825, na base `db03860` e nesta branch. O JSON da medição deu **zero
diferenças em 704 valores**, comparado campo a campo por uma régua que deu
zero exato com o mesmo arquivo dos dois lados e uma diferença com um valor
mexido; o texto saiu igual linha a linha, menos o caminho do despejo e um
aviso de encerramento do motor (`ObjectDB instances leaked`), o ruído que
`testes-e-guardas.md` já diz variar entre corridas. A passagem acontece no
fim de cada partida que paga a terceira, e o simulador semeia cada partida
à parte: o sorteio a mais que ela gasta não chega à seguinte.

## As guardas novas e os defeitos injetados

O **T20** do `run_tests` (a passagem, a Fase 2 jogável, o save pela fase do
arquivo e o degrau 15→16) e o **F23** do `teste_fumaca` (o M9 trancado e a
Fase 2 na tela), e o F20, o F14, o T14 e o R2 estendidos. Cada defeito abaixo
foi injetado sozinho, com a base restaurada por `cp` entre eles:

| Defeito injetado | Quem reprova |
|---|---|
| o sinal da passagem depois da mudança | T20, o sinal com a Fase 1 em jogo |
| a passagem sem zerar as quitadas | T20, a cobrança recomeça vazia |
| a obra do save lida pela fase viva | T20, a Fase 1 viva lê o espaço da 2 |
| o dia do save lido pela fase viva | T20, a Fase 2 viva lê o espaço da 1 |
| o degrau sem a partida ganha | T20, a ganha da 15 chega à Fase 2 |
| o fim de fase sem perguntar o prazo | T20, nove semanas sem fim |
| o `caixa_curto()` sem `tem_cobranca()` | **só o `SCRIPT ERROR`** — ver abaixo |
| o ramo da fase sem cobrança apagado | T20, o save bom da Fase 2 passa |
| a parcela aceite na Fase 2 | T20, recusa uma parcela na Fase 2 |
| a narradora sem ouvir a passagem | F23, a Dona Cida não anuncia a queda |
| um `"playing"` de volta no `Main` | F23, nenhum estado por extenso |
| o celular com o prazo da Fase 1 | F23, o celular sem prazo |
| o gravador sem a linha da passagem | R2, a última é o desfecho |
| o nível 2 declarado sem a treliça | F20, o nível da Fase 2 |
| o balanço da passagem com «Jogar de novo» | F14, a saída do balanço |
| a legenda do vencimento na Fase 2 | F23, a legenda do calendário |

Dois não caíram à primeira. O da Dona Cida passou porque a narradora nunca
tinha visto a barra antes da passagem, e o recomeço era a primeira que via
— o defeito era do teste, que passou a preparar a barra pelo sinal, e então
reprovou. O do `caixa_curto()` não cai em asserção nenhuma, por construção:
o erro nasce numa função tipada, que devolve o zero do tipo, e a cadeia
segue até um `false` que é a resposta certa. Quem o apanha é o passo do CI
que reprova `SCRIPT ERROR`. E antes deles o T20 nasceu com um contador de
cobranças que dava zero de graça: o lambda captura a variável por valor. As
duas lições de GDScript estão em `gdscript.md`.

## O que fica para as etapas seguintes

- **2.** A treliça (e o `nivel_maximo` 2 com ela), o porto de nível 2, o
  cargueiro de dois dias.
- **3.** A meta das três barras, o piso da reputação, a página que fecha a
  Fase 2 e o aviso de dinheiro dela — o `caixa_curto()` responde «não» sem
  cobrança, e as falas dele falam todas da parcela.
- **4.** O simulador a medir a Fase 2, e os preços e patamares dela.
- **Achado, anterior a esta sessão:** a faixa abre com «O porto é seu. Um
  píer de pé e o resto por levantar.» em todo `Main` com a faixa vazia —
  também numa partida retomada com dois píeres, e na Fase 2. É fala que afirma
  um estado que já não é verdade (`narrativa.md`); fica para o A4 ou para a
  sessão que a reabrir.
- **O aviso da obra que só acaba no fecho do dia 84** (`090`) continua: ela
  não serve à Fase 1, e quem paga a terceira usa-a no dia 85. A resposta
  «por enquanto» do D8 tem agora onde acabar, e fica para quando a Fase 2
  for medida.
