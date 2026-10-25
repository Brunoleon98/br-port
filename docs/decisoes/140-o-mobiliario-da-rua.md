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
| 7 | Escolheu o tamanho das placas entre quatro, lado a lado no jogo: 0,150 (B). Depois, Ajustar: *«melhore essa placa vermelha que fica no porto»*; das três candidatas do PARE escolheu a C, de frente com o letreiro, *«mas melhore o que está no centro dela, ao invés de deixar só um risco»* |
| 8 | **Aceitar** |

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
novas pelo trecho, com a chapa de raio 0,150 (o PARE 18% maior). O PARE olha
para a câmara, com o fio branco largo, um contorno escuro contra o asfalto e
as quatro letras no centro: de esguelha, liso, lia como um pirulito. A câmara só vê as faces viradas para `+mx` e `+my`, logo
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
- **O tamanho da placa não se acerta pelo número dos vereditos.** A 0,17
  eram *«pequenas demais»*, a 0,204 *«muito grandes»*, a 0,187 *«ainda
  grandes»* — e ficou 0,150, abaixo do primeiro recusado, que vivia num
  cano 30% mais alto e noutra calçada. A chapa do PARE mede 13 px de largura
  a 1080 (eram 17); a de pedestres, 9. A 0,135 a figura dela some. Quando
  dois vereditos cercam um número e o terceiro sai do cerco, as candidatas
  vão lado a lado no jogo, e ele escolhe.
- **O octógono do PARE nunca girou no próprio eixo.** A chapa olhava para
  `+x` com o Euler `(22.5, 90, 0)`, e com `Y = 90` o `X` e o `Z` rodam os
  dois em torno do `z` do mundo: os 22,5° guinavam a chapa em vez de girar
  o octógono. Ninguém o via enquanto a chapa era lisa; as letras, retas,
  saíram enterradas de um lado. Ela nasce a olhar para `-y`, gira pelo `Y`
  e roda depois o grupo inteiro (`PARE_GIRO`).
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
- Os 21 mutantes da secção `140` do catálogo (212 ao todo), cada um a
  reprovar o D45 na asserção do lugar dele; os da TABELA reprovam também a
  cópia do jogo. O `--explorar` correu-os em série contra o `teste_design`,
  ~1 min cada; o catálogo inteiro deu *«MUTANTES OK — 212»* em quatro
  cópias, e as seis suítes *«SUITES OK»*. O fecho apanhou o F9 a reprovar um
  `float(s)` do laço da fiação (`narrativa.md`).
- **A bateria de capturas**, que as passagens não correram (`arte.md`, o
  PNG novo entra na folha dos props): a folha pedia 14 páginas, e a
  lâmpada de sódio, um bulbo de 9 a 18 px, ficava abaixo dos 19 px de
  desenho que as duas folhas exigem. A dos props desceu o corte para 4,
  metade da menor, e reprova a lâmpada invisível com 0 px; a da escala
  conta-a pelo poste, como os quadros de animação.
- **No CI do PR #152** (`e78e0ef`, corrida 40155987551, tudo verde), o
  passo dos mutantes levou **10:00, 10:12 e 10:35** nas três fatias (71 +
  71 + 70 defeitos, quatro cópias cada), contra 8:33, 13:41 e 9:37 com 191
  no #151; o `--juntar` deu *«MUTANTES OK — 212 defeito(s) do catálogo em
  3 fatia(s)»* aos **11:17** da corrida, contra 14:32. +11% de catálogo e o
  job mais curto outra vez: a fatia 2, a lenta das duas corridas
  anteriores, igualou as outras, e o tempo do job é o da mais lenta. O
  «Godot headless» levou 7:00, a «Evidência visual» 12:10 e o export 1:53.
- O PARE e o tamanho das placas não têm guarda: é arte que só a foto julga,
  e o defeito do Euler vive no Blender, que as suítes não correm.

## O veredito

**Aceito na oitava passagem**, 25/10. O PARE e o tamanho das placas foram as
duas últimas; a rede, a subestação e a obra da rua vinham da sexta.
