# 051 — Um painel não é uma tela: a cobertura desce ao TEMPO

**23/09/2026 · opção (e) do briefing `23g`, escolha do Bruno:** a resposta do
Sr. Ribeiro não tinha foto. O tiro `ribeiro` fotografava a ENTRADA; a resposta
(pagou / não pagou) e a despedida só tinham sido vistas à mão, o T13 guardava o
texto e nada guardava que ele coubesse no cartão.

## O que se decidiu

1. **Um painel com mais de uma tela declara o TEMPO em que está**:
   `var tempo: StringName`, atribuído sempre por LITERAL (`tempo = &"pagou"`).
   São três painéis e sete tempos — Sr. Ribeiro `entrada` / `pagou` /
   `nao_pagou`, Arlindo `rodada` / `despedida`, fim de fase `narracao` /
   `balanco`.
2. **As duas ferramentas de captura imprimem `Tempo: <cena> <id>`**, e o
   `conferir_cobertura_paineis.py` exige foto de cada tempo, pelas duas
   fontes de sempre: o catálogo sai do script da cena, a foto sai dos logs.
   Atribuição que não seja literal reprova; tempo que a foto mostra e o
   código não declara também.
3. **O `capturar_cena.gd` ganhou `--tocar=<início do rótulo>` e
   `--tempo=<id>`**: o segundo tempo alcança-se pelo BOTÃO — um só, e ligado —,
   e o tiro diz onde pára, conferido contra o painel antes da foto.
4. **E `parcela=vencida`**, uma montagem como o `barco=N`: joga a partida pelo
   `advance_turn()` até à fase `debt_payment`. `@CONST` passou a valer também
   nos valores de estado (`cash=@PARCELA_AMOUNT`).
5. **A bateria passou de 27 a 30 tiros**: `ribeiro_pagou`,
   `ribeiro_nao_pagou` e `contraoferta_fim`.
6. **O balanço do fim de fase fica SEM FOTO, e declarado**: lê
   `GameState.metrics`, e numa cena solta a foto diria «Barcos atendidos: 0»,
   que se lê como medida. A lacuna vive em `TEMPOS_SEM_FOTO`, com o porquê, e
   o conferidor reprova-a no dia em que ela envelhecer.
7. **O F10 do `teste_fumaca`** mede, em cada tempo alcançado pelo botão, que o
   cartão cabe na tela e que todo o texto cai dentro dele.
8. **Dois consertos que as fotos e o F10 pediram**: a linha do humor do
   cliente sai na despedida do Arlindo, e os dois balões de fala quebram por
   `AUTOWRAP_WORD_SMART`.

## ⚠️ O que as fotos novas mostraram

### A despedida do Arlindo mentia, e só o segundo tempo o mostrava

Depois de a negociação fechar, o cartão continuava a dizer **«Cliente ouvindo
a proposta. (2 tentativas)»** — e, na despedida de quem venceu, **«Cliente
impaciente — se esta não colar, ele vai embora. (1 tentativa)»**. Viveu assim
desde que o segundo tempo existe (13/09), porque a bateria só fotografava o
primeiro. Hoje a linha sai com a negociação.

### O nome de quem joga transbordava o cartão

A tela de nomes aceita `NOME_MAX_CARACTERES` (24) letras sem espaço, e o
`AUTOWRAP_WORD` só quebra em fronteira de palavra. Com 24 "W", «Boa tarde,
WWWW…» e a abertura do Arlindo desenhavam a palavra inteira numa linha e
passavam **por fora do cartão**. O `_SMART` só parte a palavra que não cabe:
num rótulo de 250 px a linha foi de **344,6 a 241,2 px**, e num texto sem
palavra longa as linhas saem as mesmas, ao pixel (medido, e nenhuma das 26
fotos antigas mudou).

### O botão «Pagar» fora da fase não paga

`pay_debt()` sai CALADO fora de `debt_payment`. Numa partida nova, o toque
mostrava a resposta de quem pagou sem o dinheiro ter mudado de mãos — o texto
é o mesmo, e o estado não existe a jogar. Medido: uma partida nova avançada
dia a dia sem fazer nada chega ao vencimento no **turno 33 com R$336.000**, e
é isso que a entrada passou a mostrar em vez dos R$400.000 do turno 1.

## A medição

| | antes | depois |
|---|---:|---:|
| tiros | 27 | **30** |
| tempos no catálogo | — (a cobertura era por cena) | **7**, 6 com foto e 1 declarado |
| fotos antigas contra a `main` | — | **26 idênticas** pixel a pixel; `ribeiro.png` muda **165 px** (a linha do dinheiro) |
| F10 | — | **11 medições** em 3 painéis, 53 asserções |

⚠️ **E o zero tem controle positivo:** esconder a linha do humor já na RODADA
mexe **86.179 px** da `contraoferta.png`; a mudança real mexeu zero.

## A régua mede o que o rótulo DESENHA

Uma palavra que transborda deixa o `size` do rótulo intacto — o retângulo
cabia, o texto não. O F10 pergunta a `get_character_bounds()` onde cai cada
caractere, e recorta pelo que recorta: uma área rolável ESCONDE o que não cabe
nela. Zero peças medidas reprova, porque não mediu nada.

## Os mutantes

Cada um sozinho, originais por `cp`, base verde entre cada, código de saída
lido sem cano.

**O conferidor da cobertura**, contra os logs da bateria:

| # | defeito | o que reprovou |
|---|---|---|
| C1 | o tiro do «pagou» não existe | «tem o tempo «pagou» e fotografia nenhuma o mostra». **O conferidor antigo passa** (`COBERTURA OK`) |
| C2 | `tempo = StringName("pagou")` | «forma que esta ferramenta não sabe ler» |
| C3 | um log diz «pagouX» | «a foto mostra um tempo que o script não declara» |
| C4 | o balanço ganha foto | «a lacuna declarada já tem foto — saia da lista» |
| C5 | as ferramentas deixam de imprimir `Tempo:` | os seis tempos sem foto |
| C6 | a atribuição muda de nome nos três painéis | a conferência da LACUNA, e não a do catálogo vazio — ver abaixo |
| C7 | linha `Tempo:` sem o id | «linha que não se lê» |
| C9 | o `tempo = &"balanco"` sai do script | «lacuna de um tempo que o script já não tem» |

⚠️ **A guarda do catálogo vazio não é a que segura enquanto houver lacuna
declarada**: um catálogo vazio não tem o tempo da lacuna, e ela queixa-se
primeiro. Com `TEMPOS_SEM_FOTO` vazia (C6b), só ela reprova. Fica pela causa
que nomeia e por esse dia, e o comentário ao lado diz isto.

**A ferramenta de captura:** um `--tocar=Pagar` sem dinheiro reprova «botão
desligado», e **sem essa recusa o tiro passa**, a fotografar um pagamento
impossível; um `--tempo=pagou` num toque que leva ao «não pagou» reprova.

**O F10:**

| # | defeito | o que reprovou |
|---|---|---|
| M1 | `fala()` volta a `AUTOWRAP_WORD` | **só** a entrada do Ribeiro |
| M2 | o balão do Arlindo volta a `WORD` | a rodada e a despedida de quem venceu |
| M3 | a linha do humor fica na despedida | **só** as duas «nada diz que a negociação continua» |
| M4 | sai o `tempo = &"pagou"` | **só** «o painel está no tempo «pagou»» |
| M5 | a despedida ×8 | «o cartão cabe na tela» (1.671 px de cartão) |
| M6 | a área rolável do balanço a 60 px | os dois balanços, pelo recorte |
| M7 | *controle:* a régua pela CAIXA do rótulo, com o M1 posto | **VERDE** — quem segura é o `get_character_bounds()` |
| M8 | o «Pagar» sem dinheiro | «há um botão «Pagar…» ligado» |
| M9 | o «Pagar» fora da fase | ««Pagar» quitou mesmo a parcela» |
| M10 | a descida não desce | «(0 peças)» em todos os casos |

## O que fica de fora

- **O balanço do fim de fase**, pela regra do zero — declarado, e à espera de
  um tiro que jogue até ao turno 32 e pague pelo botão.
- **A despedida de quem venceu o Arlindo não tem foto**: pede duas apostas
  recusadas, e na bateria isso seria sorteio. É o mesmo tempo que a de quem
  perdeu, com outra frase, e o F10 mede-a a caber — com a semente DERIVADA da
  chance que o jogo aplica.
- **O nome longo foi medido só nos três painéis de mais de um tempo.** O
  `fala()` conserta todos os balões do `PainelNarrativo`; parágrafos, HUD e
  diário não foram medidos com ele.
- **Um tempo novo que não atribua `tempo` escapa ao conferidor.** A regra está
  escrita ao lado da variável nos três painéis; nenhuma guarda a obriga.
- **O balanço tem meio cartão em branco** (altura fixa com área rolável, de
  propósito): visto na foto de medição, não mexido.
- **Nenhum telefone foi olhado.** As três fotos novas e a `ribeiro.png` vão ao
  A5.
