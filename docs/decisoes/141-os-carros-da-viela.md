# 141 — Os carros da viela: estacionados na terra, mais a cada fase e obra

**25/10/2026 · o item que a `140` deixou de fora** (*«na rua, junto ao
meio-fio»*), escolhido pelo Bruno entre os que a §7 do plano nomeava. Main
`3de1526` (PR #152, a `140`, com o CI do merge verde e o Web publicado no
Pages); nenhum PR aberto; 141 livre pelo `tools/conferir_colaboracao.py`. A
conversa abriu com a foto do jogo a 1080 (dia 1 e porto completo) e a
pergunta do escopo pela `/arte`.

## O escopo, e a medida que o mudou

**Na rua do porto um carro não cabe.** A rua tem 1,8 em duas faixas de 0,9; o
camião, com 0,55 de largura, anda no meio da dele, e entre ele e o meio-fio
sobram 0,18 (~0,9 m na régua dos veículos). Um carro popular a 1:1 tem ~0,32.
Alargar a rua não dá — a 2,0 o armazém já não cabe entre o acesso e o
cotovelo (`gerar_mapa_iso.py`, `RUA_LARG`) —, nem abrir baia na calçada da
vila, que tem 0,13 até ao lote. A primeira pergunta levou isto medido, com
duas saídas: o camião desvia, ou o carro sobe duas rodas na calçada.

| Pergunta | O que ele respondeu |
|---|---|
| Lado | da vila |
| Como cabem | *«pode ficar com duas rodas no meio-fio, alguns podem ficar nas ruas laterais também, na verdade é até melhor, daí trata a rua principal como rodovia»* |
| Mudam? | *«mudam, mas com a mudança de fase e principalmente o crescimento do porto e da cidade»* |
| Que carros | hatch popular, fusca e kombi, picape pequena e moto |

A resposta tinha duas leituras, e a segunda pergunta separou-as, com o mapa
medido numa prancha: a única rua além da principal é a **viela de terra**
entre as duas fileiras de casas; travessas entre quarteirões não existem (a
fileira da frente é contínua em cada degrau) e abri-las mexeria na vila da
`123`. Escolheu **a viela**, **nenhum carro na rua principal** e o número a
crescer com **a fase e as obras do porto**.

| Passagem | Veredito, e o que marcou |
|---|---|
| 1 | Ajustar, as quatro da lista: pequenos demais, a moto some (13 px), a picape lê como conversível, velhos e novos parecidos |
| 2 | Ajustar: *«poderia ter motos como antes, dessa vez melhore os detalhes delas»* |
| 3 | Ajustar: mais motos; o baú preto some no banco |
| 4 | **Aceito** |

## O que ficou

**Catorze veículos na viela** (`CARROS_DA_VIELA` no gerador, `CarrosDaViela.gd`
no jogo): seis carros velhos — dois fuscas, a kombi verde e creme, a picape
mostarda com sacos de ráfia e dois hatch quadrados, um com a porta da frente
no primário —, quatro novos — três hatch redondos e a picape branca com
santo-antônio — e quatro motos: duas velhas (o isopor do pescador, o caixote
de feira) e duas novas (o baú cinza-claro, a de grade vazia).

**Quem aparece**: no dia 1, os dois fuscas, a kombi e a moto do isopor; cada
reparo da Fase 1 traz os seus; a Fase 2 traz os novos **sem contar os reparos
da Fase 1**, que continuam a abrir nela; e cada reparo dela traz mais. Com
tudo pronto na Fase 2 estão os catorze. A troca acontece no refresh das
estruturas, na virada em que a obra acaba. A vila ainda não cresce no jogo
(`--nivel-vila` só no gerador); quando crescer, a tabela ganha a chave dela.

**A forma**: a régua dos camiões (5,6 m/u no chão, 5,4 px/m na altura), mais
25% (`ESCALA_CARRO`, segunda passagem): um carro mede ~26 px na tela de 1080,
uma moto ~21. Velho e novo separam-se pelo **acabamento e pela forma**, não
só pela cor: o velho tem para-choque cromado e o da frente torto, ferrugem por
cima das rodas, farol creme e o vidro escuro dos camiões, e o hatch velho é
quadrado; o novo tem o para-choque da cor dele, jante clara e larga, farol
branco e vidro claro, e o hatch novo afina para cima, de vidros deitados.
Nenhum é castanho nem bege, que some na terra.

## O que se mediu

- **A viela está quase toda atrás da fileira da frente.** Varrida a cada 0,1
  em `my`, dos dois lados, a fração de um carro que se vê contra o contorno
  dos lotes à frente e o topo do mapa: a do degrau 1 vê-se de −3,2 a 6,6 do
  lado das casas de trás (o vão do escritório tirou a fileira da frente); a
  do 2 só de 8,6 a 9,1 e de 12,8 a 14,7; a do 3 de 16,6 a 19,4; a do 4 quase
  nada. Os catorze sítios estão todos acima de 90%, medidos com a caixa do
  carro maior (as motos são menores); doze estão acima de 98%.
- **A máscara do hatch verde saiu um pixel ao lado**, e foi o D50 que o viu:
  o pé dele cai em 168,5 px, o `round()` do Python leva-o ao par (168) e o
  `roundi()` do Godot a 169. O gerador arredonda o meio para cima desde a
  `141` (`_mascara_do_pe`); o mobiliário da `140` não tinha nenhum pé num
  meio, e a tabela dele saiu igual (`projecao.md`).
- **A moto a 13 px lia como um ponto.** Saiu na segunda passagem e voltou na
  terceira a 21 px, com o que só ela tem e se vê de cima e de lado: duas
  rodas grandes com o cubo claro, o motor escuro entre elas, o escapamento
  cromado do lado `+x`, o garfo, os retrovisores e a carga no bagageiro.
- **No hatch redondo os faróis ficaram à frente do nariz**, que afina para
  cima e tem as quinas cortadas: no render eram duas pontas soltas na ponta
  de cá. Recuam com a lataria (`_ponta(recuo=…)`).
- **A caçamba da picape lia como capota baixada** com o fundo cinzento e
  paredes de 1,8 px; com o fundo quase preto, paredes de 2,8 e o rebordo
  claro, lê como carroceria aberta.
- Render: os dez carros da primeira leva em 5:20, três motos em ~3 min. A
  folha dos props passou a 308 peças e 15 páginas.

## As provas

- **D50** (`casos_carros_da_viela.gd`, no `teste_design`): §1 a cópia dos
  carros e da máscara contra a tabela, e o PNG de cada um; §2 cada carro na
  viela do degrau dele, entre as faixas `vila_fundo` e `vila` da tabela com
  folga de meio carro, e dois da mesma margem sem se tocarem; §3 cada carro
  à vista (≥75% dos pixels opacos acima dos lotes à frente, refeitos dos
  `pecas_da_vila`, e dentro do `MapaWrap`) e a máscara onde um lote o tapa;
  §4 quem aparece, lido na cena estado a estado, pela tabela.
- **D15** isenta os carros pelo nome (`CarroDaViela`): o `my` da ponta norte
  atravessa a vila, e a areia fica a seis unidades.
- Os 9 mutantes da secção `141` do catálogo, cada um a reprovar o D50 na
  asserção do lugar dele; um deles é o bug do arredondamento.

## O veredito

**Aceito na quarta passagem**, 25/10. Fora deste item: a vila a crescer de
nível, os carros a chegar e a partir (estão parados), e as travessas.
