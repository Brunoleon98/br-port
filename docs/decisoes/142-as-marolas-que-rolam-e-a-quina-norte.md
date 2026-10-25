# 142 — As marolas que rolam para a costa, a espuma que lava e a quina norte

**25/10/2026 · o que a `124` deixou por olhar**, escolhido pelo Bruno entre os
itens que a §7 do plano nomeava (a recomendada). Main `3de1526` (PR #152, a
`140`); o PR #153, da `141`, já estava aberto, e esta conversa levou-o a
verde no runner antes de começar, com os tempos das fatias registados lá
(`3e37784`). A branch arranca da cabeça dele (`66cb96c`), porque as duas
mexem no `gerar_mapa_iso.py`. 142 livre pelo `tools/conferir_colaboracao.py`.
A conversa abriu com a foto do jogo a 1080 e a pergunta do escopo pela
`/arte`.

## O escopo

| Pergunta | O que ele escolheu |
|---|---|
| O item seguinte | as marolas e o fio da `124` (a recomendada) |
| Como as marolas se mexem | **rolam para a costa**, em duas camadas novas (a recomendada) |
| A quina norte | **fechar** (a recomendada) |

| Passagem | Veredito, e o que marcou |
|---|---|
| 1 | O GIF não animou no app («me mande novamente»); em vídeo: Ajustar — andar mais, troca mais curta, espuma mais calma |
| 2 | **Aceito** |

## O que se achou antes de mexer

- **O «fio diagonal» eram 2 a 3 px de água** na quina onde o pátio, o
  relvado e o cais se encontram, nos dois mapas: um pixel a +84 de azul no
  raster a 1080. É o resto do fio azul que a `136` tirou da borda norte do
  pátio — o chão da praia passou a fechar por baixo do porto, mas só até à
  crista, que o meandro levanta a 1,09 do cais; a rampa acaba no
  `PONTA_NORTE` exato, e na quina nenhuma das três peças cobria o fundo. O
  D49 §3 percorria a borda até 0,4 antes do cais, e não o via.
- **As marolas, no mapa, ficavam por baixo da terra.** Rasterizadas com o
  ThorVG do jogo, 614 px (Δ > 8) delas estavam tapados pela praia sul e pelo
  espelho dos degraus; numa camada por cima, passariam a pintá-los. E a
  sombra do muro, desenhada no fim, escurecia-as até ~18%.
- **A espuma da praia nunca tinha lavado.** O laço dela fazia
  `set_parallel(true)` antes de cada passo, e no Godot 4 isso junta o passo
  seguinte ao corrente: numa sonda de 640 frames a `Espuma0` não saiu de 0,45
  nem do sítio, e a `Espuma1` oscilava aos solavancos. O mesmo defeito
  apareceu na primeira escrita das marolas, e foi a sonda que o mostrou (as
  fotos saíam iguais). Corrigido nos dois (`gdscript.md`).

## O que ficou

**As marolas são duas camadas** (`--marolas=N`, `porto_mapa_marolas0/1.svg`),
e o mapa deixou de as desenhar. A camada 0 é a semente de sempre e a 1 é
outra. Uma marola só entra se cada ponto dela, nas duas pontas do caminho,
for água à vista: do lado da água da linha costeira, a 2,6 da linha de água
nas praias (a arrebentação vai até 2,3) e fora do espelho dos degraus
(`_agua_a_vista`). A opacidade leva a sombra do muro que a cobria, e a
camada parada fica a ≤ 13 níveis do mar aceite na `124` (85 px acima de 8,
em duas marolas junto às quinas dos degraus). Das 207 do mapa ficam 183 na
camada 0; a camada 1 tem 156.

**O `Main.gd` fá-las rolar** `MAROLA_ROLA` = 0,8 u para o cais (~27 px num
telefone de 1080), num ciclo de 7 s: cada camada acende num sexto do ciclo,
fica acesa sozinha e apaga-se noutro sexto, volta invisível ao largo e
espera; as duas em contrafase. O andar é linear e o brilho é seno. A meio do
tempo à vista a camada está onde o gerador a desenhou. Com o movimento
reduzido, a 0 fica acesa no sítio e a 1 apagada: o mar de antes, parado.

**A espuma lava, mais calma**: metade do avanço (0,067 u) e metade da
variação do brilho (0,725 a 1).

**A quina fecha**: o chão da praia norte fecha à altura do cais até à beira
do degrau; a rampa e a laje tapam o resto. Mudaram 5 px no mapa inteiro, e
a janela da quina dá +10,5 na terra e +17,0 no pavimentado.

## O que se mediu

- A textura com o jogo aberto: 105,08 MB antes. Cada camada nova são 4,67 MB
  reais a 1080, sem compressão (o monitor do motor conta 4/3 disso, `049`).
- A fração do ciclo com as duas camadas a meio do brilho: 23% (a conta
  dava 24%); com o seno do ciclo inteiro, da primeira passagem, ~71%.
- A tabela de âncoras ganhou só `marolas.rola`; o resto saiu idêntico, e as
  espumas também.

## As provas

- **D51** (`casos_marolas.gd`, no `teste_design`): §1 a cópia do caminho no
  `Main.gd` contra a tabela; §2 debaixo de cada pixel de marola, nas duas
  pontas e no meio do caminho da TABELA, os dois mapas são água (pior +57,
  defeito +6, corte +32); §3 as duas camadas na cena, entre o mapa e o
  cenário; §4 um ciclo lido no nó com `custom_step` — acende e apaga, só no
  caminho provado e para a costa, contrafase, troca curta (≤ 48%), e as duas
  espumas a variar; §5 o repouso.
- **D49 §3** mede também a janela da quina (+84,5 com a fresta; corte 54).
- Os nove mutantes da secção `142` do catálogo, dois deles bugs que
  existiram: a espuma em `set_parallel` e a quina com fresta. O
  `--explorar` deu a cada um a asserção dele, e o `--so` em quatro cópias
  *«MUTANTES OK — 9»* em 356 s.
- **E o mutante `praia-norte-acaba-no-porto`, da `136`, ficou órfão**: o
  `antes` dele era o polígono do chão do norte, que a quina mudou num
  vértice. Reescrito contra a forma nova, ainda reprova a borda (+90,5) e
  agora também a quina.
- As seis suítes, *«SUITES OK»* em 61 s (o `teste_design`, o mais lento, com
  o D51); a bateria de capturas, sem erro, em 5:29, com a comparação
  temporal a 69.613 px de mapa a mudar em 2 s e 0 com o movimento reduzido.
- O catálogo inteiro, em quatro cópias neste contêiner: *«MUTANTES OK — 230
  defeito(s)»* em 48:28.

## Fora deste item

- **O `teste_design` não tem o vigia de frames** do `run_tests` e do
  `teste_fumaca`: um arquivo de casos que não compila pendura-o até ao teto
  (medido aqui, 10 min). Fica registado em `testes-e-guardas.md`.
- **A fatia 1/3 dos mutantes é a lenta, e não é a máquina**: no CI do #153
  levou 18:29 e depois 18:27, em runners diferentes, contra 11–13 min das
  outras; a leitura da `141` («aponta para o runner») caiu, e está corrigida
  lá. Que mutantes a fazem lenta não se apurou: o relatório da fatia está num
  artefacto que o proxy desta sessão não deixa baixar.
- **O commit `1687ce5`** (os tempos do #151 na `138`) ficou na branch
  `claude/upbeat-meitner-fkfkne` e nunca chegou à `main`.

## O veredito

**Aceito na segunda passagem**, 25/10.
