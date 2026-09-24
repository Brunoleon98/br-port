# 059 — Os trinta rostos do trabalhador

**24/09/2026 · escolha do Bruno**, em quatro perguntas: o escopo (`058`), o
aceite das 30 na v3, como cada trabalhador escolhe o seu retrato, e o aceite
na foto do jogo com o custo à frente — **sem perda**.

## O que se decidiu

**O cartão do rodapé tem 30 retratos**: 2 sexos × 3 idades (jovem, adulto,
veterano) × as 5 cores do IBGE (branca, parda, preta, amarela, indígena), sem
caricatura — a cor muda o tom de pele e o cabelo que o capacete deixa ver, e
nunca o desenho do rosto. Saem do mesmo `trabalhador()` de
`blender/brp_retratos.py`, com um `perfil` (sexo, idade, cor, pelos no rosto e
penteado dela); a tabela é o `TRABALHADOR_PERFIS` de `blender/brp_porto.py`. O
padrão — homem, adulto, pardo — continua a ser o `trabalhador_retrato.png`, e
sai igual (provado a 0 pixels nos dois estados estáveis do ruído do render).

**Cada trabalhador nasce com um ROSTO**, o índice do retrato dele, guardado no
save (`SAVE_VERSION` 8). Sai de `GameState.novo_trabalhador()`, a porta única
por onde um trabalhador nasce, e nunca repete na mesma fileira. O sorteio é
**próprio**: um gerador semeado pelo ESTADO do `_rng` da partida, que ler não
avança. Cada partida mostra caras diferentes, a mesma semente dá a mesma cara
(as fotos da bateria comparam-se), e o balanceamento medido fica intocado por
construção — 100,0% / 80,2% / 37,3% nas 600 partidas, os números de antes.

O jogo lê os retratos de `Retratos.TRABALHADORES`, o espelho da tabela do
estúdio, **sob pedido** (`load()`, não `preload`): o porto nunca mostra mais de
três.

## Por que

A `058` dizia que a variação sairia do `id` do trabalhador, sem campo novo no
save. Medido antes de ligar: o porto tem no máximo **3** trabalhadores
(`WORKERS_BASE` 1, mais um por doca, até às 3 do mapa), com os ids 1, 2 e 3 —
pelo `id`, toda partida mostraria os mesmos três, e 27 retratos ficariam
gerados sem ninguém os ver (o `barco_medio`). O save não guarda nada que mude
de partida para partida além do nome do porto. Postas as três saídas (campo no
trabalhador, nome do porto + id, só o id), o Bruno escolheu o campo — que é
também o que o sistema de RH vai usar.

## O caminho da arte (`art_lab/retratos/trabalhador_variacoes/`)

- **v1** — as cinco peles com o degrau abaixo de cada uma, os cabelos, a
  mulher de rabo de cavalo, o veterano com rugas, bigode e cavanhaque. Na pele
  preta a boca em `vao` media 0,42–0,59 de Weber contra 0,75–0,91 nas outras,
  e a boca, a pupila e a sobrancelha foram ao preto do cabelo. Veredito: pele
  preta escura demais; a mulher lia como homem e o rabo como uma alça; lábio,
  rugas, bigode e cavanhaque a sumir ou a virar mancha; mais penteados e mais
  barbas.
- **v2** — a pele preta um degrau acima; cinco penteados dela, três dos quais
  EMOLDURAM a cara (solto, curto, crespo); cílios, lábio mais cheio e
  saturado; rugas em leque; bigode em tufos, cavanhaque ligado ao bigode e
  barba cheia. Veredito: só o crespo — cobria o olho e lia como capuz.
- **v3** — o crespo em cachos, atrás do plano da cara. **Aceite.**

## O custo, medido

- **`.pck` +7,33 MB (+127,5% do `.pck`, +22% do APK de 32,9 MB da última
  `main`).** ~250 KB por retrato, sem perda. O delta do `.pck` é o do APK
  (`029`). Posto à frente com a opção de medir uma compressão com perda, o
  Bruno escolheu **ficar sem perda**: os retratos saem como os aprovou.
- **VRAM com o jogo aberto +1,99 MB** (65,42 → 67,41), medida emparelhada numa
  cópia da árvore: é o retrato do trabalhador inicial. Antes do `Main`, igual.
- **Na bateria mudam 14 das 31 fotos, todas só na faixa dos cartões** (y
  860–929); as outras 17 saem iguais, e a folha nova é a 32.ª.
- **As 15 mulheres ficam FORA do atlas**: o cabelo passa a região aparada dos
  512 px, o empacotador arredonda a 1024 × 764, e isso custa mais do que o
  quadro de 768 — o validador reprova, como a regra manda. Os 14 homens novos
  entram no atlas.

## As guardas

- **F12** do `teste_fumaca`: o registo contra o disco nos dois sentidos, 30
  trabalhadores dão 30 rostos, o `_rng.state` não se mexe, as 30 caras saem de
  partidas novas, a mesma semente dá a mesma cara, o save recusa rosto ausente,
  fora da faixa, repetido, em texto e partido sem tocar em nada, e o cartão
  mostra o arquivo do rosto. Dez mutantes, cada um reprovado pela guarda dele.
- **`folha_trabalhadores.gd`** na bateria: os 30 em cartões de verdade, com o
  tema, e reprova o cartão que mostre outro arquivo ou que não chegue à foto
  (o defeito dá 0 px; o menor retrato muda 2.407).

## O que fica para depois

- **O sistema de RH** põe cada rosto no currículo e na negociação de salário.
- **O emblema do jogador** no adesivo do capacete (`058`).
