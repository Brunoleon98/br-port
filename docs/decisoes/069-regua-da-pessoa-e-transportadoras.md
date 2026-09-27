# 069 — A frente 4, primeira família: a régua da pessoa e as transportadoras

**27/09/2026 · frente 4 do A5** (mapa, frota e animação), escolhida pelo
Bruno depois do veredito da 6 (`068`, «Aceito como está»). A frente é grande
e partiu-se em famílias, como a 3 — escala e camiões, frota, ruína e obras,
animação —, e ele escolheu começar pela escala e pelos camiões. As notas que
ela responde são de 23/09: *«novas variações devem ser criadas como se
tivessem mais de uma empresa prestando o mesmo serviço»* e *«tome cuidado com
a proporção em relação ao mapa e seus itens, pois no futuro carros e pessoas
devem ser adicionadas»*.

## O que o Bruno escolheu

| Pergunta | Resposta |
|---|---|
| A frente 6 (prancha e escala) | **Aceito como está** |
| A frente seguinte | **4 — mapa, frota e animação**, pela família **escala e camiões** |
| A régua das pessoas | **1,5× o real**, que é **0,48** do trabalhador de 13/09 (ver «A conta que se corrigiu») |
| A fauna, com a pessoa menor | **Fica do tamanho de hoje** |
| Transportadoras | **Duas por serviço** |
| O que as distingue | **A cor da cabine, a faixa na carroçaria e o modelo da cabine** |
| Carros e pessoas | **Só na régua**, a página de escala; pô-los no mapa é da família da animação |
| A primeira candidata dos camiões | **Ajustar**: as três cabines vermelhas, o vermelho que some no asfalto, a faixa da caçamba, o capô — e *«adicione mais detalhes nos camiões deixando mais realista»* |
| Os detalhes | **Os quatro grupos**: retrovisores e para-sol; para-choque e faróis; tanque e para-lamas; defletor no teto |
| O capô | **Mais comprido** |
| As cores da empresa B | **Uma por serviço** |
| A segunda candidata | **Ajustar**: janelas de casa («tire a divisão»), lameiros invisíveis, defletor em degraus, as cores do granel e do pescado |
| A terceira | *«Ficou melhor»* — e pediu mais detalhe: marcou **as oito** propostas (cabine e capô em bisel, escape, carreta articulada; cubos, borda e reforços da caçamba, porta e degrau, lanternas do teto) |
| A quarta | **Aceito** — o desenho fecha; os 32 no jogo são a passagem seguinte |

## A régua do mundo

Medida no que o kit já desenha com tamanho real conhecido — o contêiner do
pátio e a cabine do camião, lidos depois de todas as escalas do gerador:

| Peça | Chão | Altura |
|---|---|---|
| Contêiner do pátio (2,44 × 2,59 m) | 0,50 u → 4,9 m/u | 15 px → 5,8 px/m |
| Cabine do camião (2,5 m, ~3,2 m) | 0,45 u → 5,6 m/u | 17,3 px → 5,4 px/m |
| **A régua** (`METROS_POR_U`, `PX_POR_METRO`) | **5,2 m/u** | **5,6 px/m** |

As duas peças concordam entre si e discordam de um eixo para o outro: o kit
desenha as alturas mais achatadas do que o chão. Pessoas e carros comparam-se
pela ALTURA — é o que o olho alinha e o que a página de escala põe lado a
lado —, logo a régua deles é a de altura.

O trabalhador de 13/09 media 30,4 px de altura: **5,4 m**, mais alto do que a
cabine do camião a que ia encostar. No real (9,8 px) o capacete e o colete
perdiam-se; a 1,5× (14,7 px) leem-se, e o camião passa a ser maior do que
ele. `REGUA_DA_PESSOA = 0,48` escala o boneco inteiro em volta dos pés, e ele
continua no mesmo sítio do tabuado.

## A conta que se corrigiu

A primeira versão desta régua deu **0,65**, e o Bruno aprovou-a na prancha
como «1,5× o real». Ela lia a cabine do camião nas literais do construtor
(24 px de altura, 0,62 de largura), ANTES do `ESCALA_CAMINHAO` (0,72) que o
`brp_porto` aplica no fim — e assim o contêiner e o camião pareciam concordar
em 4,9 m/u. Relida no PNG, a cabine tem 17,3 px, e a 0,65 a pessoa media
19,8: **2× o real**, mais alta do que a cabine e do que o contêiner.

A correção foi mostrada na prancha com as duas lado a lado, e ele escolheu a
0,48. A lição foi para o `CLAUDE.md` (Arte): **medida de prop lê-se no PNG,
ou depois de toda escala que o gerador aplica.**

## A fauna não acompanha a pessoa

O D25 exigia que a ave e os bichos pequenos não passassem da largura da
pessoa, e a primeira aplicação da régua encolheu a fauna pelo mesmo fator.
A 0,48 ela ficava com 6 a 8 px: o cachorro com 9 pixels opacos, e a
gaivota, a tartaruga e o cachorro todos com 7 — as duas asserções de ordem do
D25 reprovaram. Mostradas as duas na prancha, o Bruno escolheu a fauna de
hoje, e é o real que a regra antiga não era: a envergadura de uma gaivota é
~3× os ombros de uma pessoa.

O D25 passou de «nenhum bicho passa da pessoa» a **«nenhum bicho fica abaixo
da pessoa nem chega ao barco de 44 px»**, com as larguras de cada bicho
pregadas como antes. Mutante: a pessoa 6 px mais larga (13) — a régua
reprova, e o piso reprova a maria-farinha (12). Com a fauna encolhida pelo
mesmo 0,48 (medida: 7 / 7 / 6 / 7 / 7 / 8 contra uma pessoa de 7), o piso só
apanha a maria-farinha; os outros cinco caem nas larguras pregadas.

## O carro e o pedestre

Os dois vivem em `brport_vs/tools/referencia/` e não em `art/props`: o jogo
não os mostra, o export não leva `tools/*` e o `arte_orfa` não os varre.
Saem de `gerar_props_iso.py` só pelo nome (`REFERENCIAS`), e uma regeração
de tudo não os põe em `art/props`.

- **O pedestre** é o corpo do trabalhador, com camisa e cabelo no lugar do
  colete e do capacete — a régua de uma pessoa é uma só.
- **O carro** é um hatch em tamanho real (3,9 × 1,7 × 1,5 m), desenhado com
  `METROS_POR_U` e `PX_POR_METRO`: a primeira peça do kit feita a partir de
  medidas reais. A folga de 1,5× é só das pessoas.

A `escala_props.gd` põe os três — trabalhador, pedestre, carro — no começo de
cada fila, e prova os dois novos na primeira («esconder muda a foto?»).

## Os camiões das duas empresas — aceites na quarta candidata, ainda fora do jogo

`EMPRESAS` no `brp_porto.py`: duas por serviço. O serviço continua a ler-se
pela carroçaria; a empresa lê-se pelo que está à frente dela.

- **O bicudo só nos três médios** (baú, basculante, frigorífico), e é o real
  das estradas brasileiras; a carreta de contêiner é puxada por cavalo
  cara-chata nas duas. O capô (`CAPO`, 0,40 antes da escala, ~1,5 m)
  acrescenta-se À FRENTE do camião de sempre, que não encolhe, e o maior
  bicudo fica exatamente com o comprimento do porta-contêiner (1,96) — é nele
  que o recuo da paragem e a janela da curva estão medidos.
- **As cores da B escolhem-se contra o asfalto pelo valor**: verde e
  azul-claro novos (`cab_verde`, `cab_azul_claro`), amarelo e laranja do kit.
  A primeira candidata tinha três vermelhas, lia como uma transportadora só e
  separava-se do chão só pelo matiz (0,06 de Weber no granel).
- **O controle**: antes dos detalhes, as 16 da empresa A renderizadas pelo
  construtor novo deram **Δ zero** contra as do jogo (`comparar_props.py`,
  16 iguais) — a refatoração não mexeu no camião de hoje.
- **Os detalhes valem para as duas empresas**, e chegaram em três voltas:
  retrovisores, para-sol, para-choque claro, faróis e tanque; o **vidro de
  camião** (`vidro_cab`, escuro e inteiro — a `janela()` do kit é a de casa);
  os **para-lamas** pretos por cima da roda da frente (os lameiros da segunda
  candidata eram chapas vistas de canto, que esta câmera nunca mostra); o
  **defletor em rampa**, um prisma; a **cabine e o capô em bisel**, uma caixa
  com um prisma por cima; o **escape**; a **carreta articulada**, com o vão e
  a quinta roda; os **cubos** claros das rodas; a **borda e os reforços** da
  caçamba; a **porta, o degrau** e as **lanternas do teto** da cara-chata.
- **As cores da B, na terceira volta**: verde na carreta, cabine branca com
  faixa coral no basculante, amarelo no baú, coral no frigorífico.

## O que fica para a passagem seguinte

Os 32 (4 serviços × 2 empresas × 4 silhuetas) no jogo:

- a tabela `CAMINHOES` do `Main.gd` por empresa, e o sorteio da empresa em
  cada viagem **sem consumir o `_rng` do `GameState`** — um sorteio a mais ali
  mudaria o balanceamento medido e todas as capturas;
- a guarda de alcançabilidade: as 32 aparecem (a lição da `059`);
- o **D35** com o chassi por empresa, porque o bicudo é mais comprido;
- a folha dos camiões, os `.import` de atlas (o `--import` duas vezes) e o
  manifest.
