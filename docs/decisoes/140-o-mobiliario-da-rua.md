# 140 — O mobiliário da rua: postes, placas, cavaletes e a rede elétrica

**24/10/2026 · item 3 da fila da `126`, os sprites de detalhes.** Main
`06a1b63` (PR #151, a `138`, que esta conversa levou a verde no runner antes
de começar, com os tempos das três fatias de mutantes registados lá);
nenhum PR do Codex aberto; 140 livre pelo `tools/conferir_colaboracao.py`.
A conversa abriu com a foto do jogo (dia 1 e porto completo, ampliados a
1080) e a pergunta do escopo pela `/arte`; cada passagem levou a prancha
contra a `main` e o veredito do Bruno.

## O escopo que ele escolheu

| Pergunta | O que marcou |
|---|---|
| Que detalhes | postes e placas na calçada; cavaletes de obra junto dos cones |
| Onde | só a rua do porto (a vila da `123` e o pátio intocados) |
| Mudam com a obra do pátio? | sim, trecho a trecho, como o asfalto da `136` |
| Postes | só do lado da vila |
| Placas | PARE na boca de cada acesso, pedestres antes de cada zebra, uma de 40 |
| Cavaletes | entre os cones, no eixo |
| Carros estacionados | ficaram de fora; quando entrarem, *«na rua, junto ao meio-fio»* |

| Passagem | Veredito, e o que marcou |
|---|---|
| 1 | Ajustar: sombras riscam a rua, postes finos e pálidos, velho e novo parecidos, pedestres em cima da zebra; *«veja mais detalhes que podem ser melhorados e melhore»* |
| 2 | Ajustar: fios escuros demais, a rede acaba no cotovelo, placas pequenas demais, cavaletes misturados aos cones |
| 3 | Ajustar: fio corta o cotovelo, fio por cima das casas, placa de pedestres sobre a zebra; *«pode afastar o espaço entre os cones e cavaletes, e tem fio passando por cima de construções, como a igreja»*; escolheu cone, cavalete, cone |
| 4 | Ajustar: fios na frente da igreja, poste junto ao cavalete, placa de pedestres no pátio, quina de dentro sem luz; *«as placas de trânsito ficaram muito grandes, e pode colocar postes até um dos limites do mapa para mostrar que a energia vem de algum lugar, pode até fazer uma subestação»*. Escolheu: subestação no campo ao norte do pátio; a rede *«vai até casas do sul do mapa»*; cavalete na calçada; pedestres na calçada da vila, antes da zebra |
| 5 | Ajustar: a subestação *«fora da areia, no relvado»*; o ramal reto sobre a rua, a linha visível até a borda e de alta tensão; *«veja as sombras dos postes, pois parecem estar sobrepondo edifícios, como a igreja»* |
| 6 | Ajustar: *«a placa ainda está grande»* |
| 7 | (veredito por vir) |

## O que ficou

**Os postes** saem do Blender (`brp_porto.poste_rua`), velho e novo. O velho
é outro poste e não o novo pintado (`arte.md`): concreto escuro de chuva,
seis graus de tombo para a rua, cruzeta de madeira, braço curto com cúpula
e a lâmpada de sódio à parte, para piscar como a do poste do pátio. O novo
é claro, direito, com o braço longo da LED. A sombra vai a 20° do zénite
(`ZENITE_DO_MOBILIARIO`): a 62°, a do poste riscava a rua na diagonal.

**A rede** vem da **subestação** no relvado do campo ao norte do pátio,
fora da areia, no sítio da aroeira da restinga — que passou para junto da
torre DEPOIS do sorteio das plantas, para nenhuma outra se mexer. A linha
de alta tensão chega-lhe da borda de cima do mapa numa torre treliçada e
pousa num pórtico; o poste de saída, dentro da cerca, leva a energia reta
por cima da rua ao primeiro poste da vila (o `ramal`, rodado −45°), e daí
ela desce pela calçada da vila até sair do quadro pelas casas do sul. São dois fios por vão, pousados nos isoladores das
pontas da cruzeta, com a barriga mais solta na rede velha. Nas curvas, dois
postes no arco de fora (a 1/4 e a 3/4 dele) e um na quina de dentro, cada um
com a cruzeta de través à rua: a corda de 45° afasta-se 0,113 do meio da
calçada, que tem 0,11 de meia largura.

**As placas** — PARE, pedestres e 40 — ficam velhas (desbotadas, tortas) ou
novas pelo trecho. A câmara só vê as faces viradas para `+mx` e `+my`, logo
servem quem SOBE a rua: uma para quem desce mostraria o verso. A de
pedestres vive na calçada da vila, 1,0 depois da zebra no sentido de quem
desce — antes dela para quem sobe, à esquerda dele —, e na tela a chapa
sobe sobre o lote de trás, ao lado das barras.

**A obra da rua** põe dois cones no eixo do cotovelo que vem a seguir e o
cavalete na calçada do pátio do mesmo cotovelo, ao longo dela.

## O que se mediu

- **Uma placa perto da zebra, na calçada do porto, não tem sítio.** A cada
  0,1 ao longo dela, a chapa sobe na tela sobre as barras, ou o escritório e
  o armazém tapam-na. Na calçada do pátio do cotovelo seguinte cabia, e o
  Bruno recusou-a; na da vila, a 9 px das barras.
- **O troço do eixo em que um cone não é atropelado vai de 1,0 a 3,2**: o
  camião corta as duas curvas pela diagonal. Os cones ficam nos extremos
  (1,15 e 3,05).
- **O poste da quina de dentro cai, na tela, na coluna do eixo a 1,88** — no
  meio desse troço —, porque a calçada da vila do cotovelo é o lado de CÁ da
  rua. Todo poste a menos de ~1,4 da quina cai nas colunas do grupo da obra,
  e sem poste ali o fio volta a cortar o lote da esquina. O braço da luz, a
  59-87% da altura, é a faixa do cavalete: tapava-o. Daí o cavalete ir para
  a calçada do pátio, e os dois cones ficarem com o poste no vão entre eles.
- **Só dois vãos passam atrás de um lote da vila**: o fio da curva do
  segundo cotovelo, atrás da torre da igreja, e o do terceiro. A vila é o
  mapa, um fundo chapado, e o fio desenhava-se por cima; o jogo esconde-o
  onde o lote à frente o tapa, pelo contorno de cada lote que a mata do
  morro já lê (`pecas_da_vila`, `130`), com uma cor por vértice num
  `Gradient` do `Line2D` e os vértices a 1 px. Os fios da reta da igreja
  passam À FRENTE da fachada, porque a calçada fica à frente dela, e
  continuam a vê-la.
- **A sombra do poste sobre a igreja era a mesma conta, no PNG.** Os
  postes da curva do segundo cotovelo pousam atrás da torre, e o sprite —
  com a sombra de contacto — pintava-se por cima dela. Um shader
  (`vila_a_frente.gdshader`) apaga o que da peça cai abaixo do topo do
  lote da frente, coluna a coluna, pelo mesmo contorno. ⚠️ O `COLOR` do
  fragment já traz a textura: multiplicá-la outra vez escureceu os postes
  mascarados na foto da quinta passagem.
- **A lâmpada vive na `RedeDaRua`, e não no `Cenario` ao lado do poste**: lá
  o D30 lê todo par no mesmo quadro como duas metades empilhadas.
- **A ponta do fio acha o isolador a 1 px** no PNG; sem o tombo do poste
  velho, duas das três pontas só o tocam a 3 px e a terceira cai no
  isolador vizinho. O raio da guarda vai a 2.

## As provas

- **D45 §7** (`casos_obra_no_mapa.gd`): a cópia do mobiliário, dos
  cavaletes e do que a vila tapa contra a tabela; cada peça no pedaço de
  calçada do tipo dela, reconstruído da tabela, e a subestação e a linha no
  campo, longe das plantas; o dia do trecho pelo asfalto ao lado; a planta
  da fiação a no máximo 0,22 do meio da calçada da vila (o certo dá 0,113, a
  rede da terceira passagem 0,349 na curva e 0,891 no lote da esquina); e,
  dia a dia, a arte, a lâmpada de sódio só no velho, os cones e o cavalete,
  cada fio num isolador lido no PNG, e cada vértice escondido onde um lote
  da vila lhe fica à frente, e só aí.
- **D2 e D15** isentam o mobiliário pelo nome, e a subestação no D15.
- Os mutantes da secção `140` do catálogo.

## O veredito

(por vir)
