# 101 — O tutorial curto do Toninho: atracar e avançar, no dia 1, por cima do jogo

**12/10/2026.** Base `efc50d7` (o PR #124, o rosto do Toninho, fundido); 101
livre conferida na main pelo GitHub, sem PR aberto do Codex. É o segundo dos
dois itens da `100`: o rosto fechou ali, e isto é o tutorial no recorte que o
Bruno escolheu em 11/10 — atracar e avançar, só no dia 1 de uma partida nova,
overlay e sem save.

## O que entrou

**`scripts/TutorialDoToninho.gd`**, objeto do `Main` (como a narradora, `096`,
e a vez das telas, `097`), ligado por MÉTODO ao `phase_changed`, ao `atracou` e
ao `turn_advanced`, e desligado quando acaba. Começa no fim da abertura —
`_depois_da_abertura()`, o caminho único do diário fechado e do `_ready()` sem
caderno —, e fala no fim do frame, onde lê o predicado (`narrativa.md`):

- **Passo 1, atracar (calmo)** — com berço livre e barco pronto ao largo
  (`atracagem_pendente()`). Os cartões «Ao largo» já pulsam sozinhos nesse
  estado, até ao primeiro `atracou` (`BarcoFila._pulsar`, `083`): o recorte da
  `100` pedia-os a pulsar, e eles já o faziam — um segundo pulso no mesmo
  cartão seria dois relógios.
- **Passo 2, avançar (irónico)** — depois do primeiro barco atracado; o
  «AVANÇAR DIA» pulsa, com o pulso e a cor dos cartões (`BarcoFila.PULSO_COR`,
  extraída para isso), até ao `turn_advanced`. Não se repete, nem desfazendo
  o toque e atracando outra vez no mesmo dia.
- **O dia vira antes de atracar (sério)** — com barco ao largo que se podia
  chamar; o tutorial acaba, sem passo 2.

**Sem fase e sem save**: o dia de tutorial deriva-se — dia 1 e nenhum barco no
píer —, e recarregar no dia 1 repete-o, como a `100` aceitou. O simulador não
monta o `Main`: o balanceamento fica intocado por construção.

## Quatro casos que o desenho da `100` não dizia

1. **A contra-oferta do dia 1** (30% das partidas novas): o passo 1 espera a
   fase voltar a `playing` e só fala se ficou barco para chamar. Mandar tocar
   no barco que está nas mãos do Arlindo seria mandar tocar no que não se
   pode.
2. **O fundeadouro vazio no dia 1** (0,25³ ≈ 1,6% das partidas): o dia passa
   calado. O passo 1 mandaria tocar num barco que não existe, e a fala séria
   falaria de um barco que não esperou. É o preço do recorte «só no dia 1»;
   fechá-lo é estender o tutorial ao primeiro dia com barco, e é escolha do
   Bruno.
3. **O passo feito antes de lido**: a fala entra na FILA da faixa (`034`) e
   espera atrás de outra — no mínimo da mensagem de abertura, que segura a
   faixa 2,3 s; no dia 1 com contra-oferta, também do «barco fechado» —, e
   quem atraca nesses segundos leria «toca nele» com o barco já no píer. A
   `100` dizia «cada passo some se o jogador o fizer sozinho antes»; o que o
   faz sumir é `FilaDeMensagens.retirar()`, novo: tira a que ESPERA a vez, e do
   histórico com ela (nunca foi dita), e não toca na que está na tela — a fila
   nunca interrompe a leitura.
4. **O dia que vira antes de o passo 1 ser pedido.** O passo 1 espera o fim do
   frame; quem vira o dia no MESMO frame em que o `Main` monta — a bateria de
   capturas joga assim — apanhava o tutorial à espera, e ele calava-se: a fala
   séria dependia do frame e não do barco. Hoje decide o barco, lido no sinal
   (antes do sorteio do dia 2, quando os barcos ao largo são só os que
   esperaram o dia 1). Foi a foto do dia 2, vazia de Toninho, que o mostrou.

## As falas — rascunho para a leitura do A4

Na `Narrativa.TONINHO_FALAS`, com a cara na `EXPRESSOES` e o gatilho no
mesmo commit. O GDD dá o tom (conciso, «chefia», o «Olha, chefia...» do que
é importante), não o texto, e cada uma traz o que a tela não diz:

| Id | Cara | Fala |
|---|---|---|
| `atracar` | calmo | «Tem barco esperando ali fora, chefia. Toca nele que eu trago pro píer.» |
| `avancar` | irónico | «Aqui o relógio é você, chefia. Enquanto o dia não vira, barco não sai e dinheiro não entra.» |
| `dia_virou` | sério | «Olha, chefia... barco que espera demais desiste e vai pro Porto Farol. E isso a cidade comenta.» |

O sistema já diz «Avance o dia para operar» ao atracar, e por isso o passo 2
não manda avançar: diz o porquê. O sério sai no dia 2, quando o cartão do
barco do dia 1 diz «vai embora hoje»; o que ele acrescenta é para onde vai e
o que custa. Para a leitura, duas perguntas que a foto levanta: «toca nele»
com dois barcos ao largo; e a faixa não diz QUEM fala — a cara só aparece no
celular, como a da Dona Cida (a faixa com retrato está medida e à espera de
layout, no estado).

## O rosto e a voz

O registro entrou com as falas: `Retratos.POR_EXPRESSAO["toninho"]` e
`Narrativa.EXPRESSOES["toninho"]`, e os três saíram da `INTERFACE_SEM_REGISTO`
do `catalogo_props.gd`, que fica vazia (a porta continua). O `arte_orfa.py`
desce de 12 para **9 de 334**.

**O balão** é o proposto na `100`, `#f5daa9` (`BalaoToninho` e
`BalaoToninhoSeguido`): a régua do D38 leu a roupa do Toninho NA camisa —
mediana `#ac873f`, 40°, e não o pano ao ombro que o README temia —, e o balão
a 39° é o mais perto dela; ΔE 27,3 da Dona Cida, 32,0 do Sr. Ribeiro e 47,5
do Arlindo, e o texto navy a 9,3:1 sobre ele (conta à mão; o D33 mede-o).
**A placa (`#e1c797`) não entrou**: ele não fala em cartão nenhum, e uma
variação sem quem a vista seria arte órfã do tema. O celular ganhou-o no
cabeçalho do grupo (quarta cara) e na `CARA_DE_OMISSAO`.

## As guardas, e os defeitos que as provam

- **F7** (fumaça): as três falas dele têm cara, PNG e quem as peça. A busca
  pelo id entre aspas, que serve aos painéis, daria verde de graça aqui —
  «atracar» e «avancar» são também nomes de PASSO —, e por isso procura o
  argumento do `_dizer(...)`, por dois caminhos (chamadas contra lidas).
- **F22** (fumaça, novo): o tutorial jogado pelo `Main`, em quatro caminhos
  com bandeira própria — atracar antes de ler; o dia vira antes de atracar
  (também no frame da montagem); a abertura (caderno e contra-oferta); e os
  dias sem tutorial (dia 2, barco já no píer, fundeadouro vazio).
- **T8** (lógica): o `retirar()` tira a que espera e a apaga do histórico, e
  não toca na que está na tela.
- **D38** (design): a quarta voz, com o número de vozes derivado da
  `CARA_DE_OMISSAO`; a amostra do histórico (`contraste_ui.gd`) traz as duas
  falas dele, e o D33 mede-as (621 textos, eram 618).
- **A régua da faixa** ouve-o como terceira fonte (`sonda_mensagens.gd`): 10
  falas em 15 partidas, e o sistema e a Dona Cida iguais aos da `main`
  medida na mesma hora (538 e 1024 escritas, 107 fundidas).
- **O F8** passou a ignorar as falas dele: monta o `Main` no dia 1, e o
  `_f8_drenar()` devolvia-o como «a última mostrada» por cima da variante da
  Dona Cida que o F8c2 pergunta.

**Dezasseis defeitos injetados, todos reprovados**, cada um com a base
restaurada por `cp` e verde antes do seguinte: o tutorial a começar no
`_ready()` (M1), o `retirar` esquecido (M2), o pulso que não para (M3) ou só
volta ao branco (M3b), o aviso que não sai (M4), todo dia é dia (M5), caras
trocadas (M6), a guarda do passo no `_ao_atracar` (M7), o passo 1 sem
perguntar pelo barco (M8), o `retirar` que tira a da tela (M9) ou esquece o
histórico (M10), o id composto (M12), o balão de outra voz (M13, «um tom só»;
M13b, nos dois balões, o matiz), e o ramo do dia que vira antes do passo 1
(M14, calado; M15, sem perguntar pelo barco).

⚠️ **O M7 passou à primeira**: a pergunta «não se repete» estava no dia 2, e
ali quem cala o tutorial é o desligar dos sinais — a guarda do passo era a
cópia que não apertava. O estado em que ela aperta é desatracar e atracar
outra vez no DIA 1, e foi lá que a asserção passou a viver.

**A bateria** ganhou três tiros (`tutorial_atracar`, `tutorial_avancar`,
`tutorial_aviso`): as caras irónica e séria só existem em partida jogada, e
o portão da cobertura reprovou-as sem foto.

## O que fica de fora

O empurrão de 10 s do GDD, o reparo do píer 2 e o coach mark do avançar
sozinho (fora do recorte, `100`); a fala do Toninho no Registro do playtest
(o A7 saberia se o tutorial apareceu — item próprio, se o Bruno o quiser); e a
placa, até ele falar num cartão.
