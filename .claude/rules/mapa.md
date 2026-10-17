---
paths:
  - "tools/gerar_mapa_iso.py"
  - "brport_vs/art/porto_mapa*"
  - "tools/medir_enquadramento.py"
  - "brport_vs/tools/medir_enquadramento.gd"
  - "brport_vs/tools/medir_resolucao_mapa.gd"
  - "brport_vs/scripts/TrafegoDeCamioes.gd"
---

# Regras — o desenho do mapa

> Carrega quando a sessão lê ou edita um arquivo do `paths:` acima. Veio do
> `CLAUDE.md` em 10/10, palavra por palavra (`docs/decisoes/091`); o índice
> de todas as regras está no núcleo. Lição nova deste tema entra aqui.

## O mapa sai byte a byte (de «Como rodar»)

⚠️ **O CI regera e compara BYTE A BYTE, e o `sum()` de floats mudou na Python
3.12.** Ela passou a somar por compensação de Neumaier; o runner é
`ubuntu-latest` e subiu de versão sozinho. Medido em 05/09, o mesmo arquivo:
`CX = 508.49999999999994` na 3.10/3.11 contra `508.50000000000006` na 3.12/3.13
— 1e-14 que o `%.1f` do gerador arredonda para o outro lado e vira **190 linhas
de diferença** nos dois mapas, com o PR vermelho e nenhuma coordenada do mundo
mudada. Num gerador cuja saída o CI compara assim: `math.fsum` em vez de `sum`,
e **arredonde o que alimenta tudo o resto** — número que sai de divisão e entra
em toda coordenada tem de ser exato, senão a máquina decide o desenho.

⚠️ **PODA QUE REORDENA UM `argmin` MUDA O RESULTADO, e aqui isso é o PNG.** O
campo de cor da água mede, para cada um de 518 mil pixels, a distância ao
segmento de costa mais perto — e usa o `my` do VENCEDOR. Com a costa das pontas
desenhada foram 10 segmentos para ~500, e a força bruta passou de 5 s para 182 s
por mapa; o índice espacial que a substituiu só é legítimo porque (a) descarta
apenas segmentos que **não podem** ganhar, por um piso de distância, e (b) mantém
a ORDEM original, que é quem desempata. Trocar a ordem teria mudado a cor de
pixels que ninguém pediu para mudar, sem erro nenhum. Otimização num gerador que
o CI compara byte a byte prova-se assim: **corra a versão lenta e a rápida e
exija os mesmos bytes**, na entrada velha E na nova.

⚠️ **`zlib.Z_FIXED` NÃO torna um PNG byte-estável entre zlib e zlib-ng.** A
árvore de Huffman fica fixa, mas cada implementação ainda pode escolher
casamentos LZ diferentes. Medido no PR 45: os pixels RGBA eram idênticos e só
a linha base64 mudava nos dois mapas entre Python 3.14/zlib-ng no Windows e o
runner Linux. O raster costeiro usa `_zlib_fixo()`, com procura LZ e DEFLATE
próprios; não o troque por `compressobj()` enquanto o CI comparar o SVG byte a
byte.

### Tudo o que vive em terra é medido A PARTIR DA BEIRA DO CAIS

O cais avança 4 unidades por degrau. O que não avança com ele sai do
enquadramento: a rua e as casas ficariam a 4 unidades da água no primeiro
degrau e a 16 no último. `APRON`, `RUA_RECUO`, `VILA_RECUO` são recuos, não
`mx` absoluto.

## O desenho do mapa (da seção «Arte»)

- **Trocar cor olhando só o MATIZ achata a imagem.** Em 02/09 a água passou de
  mar frio a turquesa tropical com valores amostrados da referência, e ficou
  bonita e chapada: pôr as duas pontas amostradas nas duas pontas da rampa
  comprimiu a separação de luminância entre água funda e baixio em 25%, e a
  espuma — traço claro que contrastava sobre água escura — perdeu um quinto do
  contraste de Weber sobre água clara. **Ao trocar uma paleta, meça a
  amplitude de luminância antes e depois**, e lembre que o contraste que o olho
  vê é razão e não diferença. Na captura inteira nada disso aparecia; a 3× de
  ampliação era evidente.
- **⚠️ O NOME DE UMA COR NÃO É O VALOR DELA.** O degradê do largo ia de
  `agua` a `agua_funda`, e a `agua_funda` era a MAIS CLARA das duas: o mar
  escurecia até ~12 unidades da costa e voltava a clarear ao fundo da tela,
  e as manchas «fundas», nessa cor, clareavam onde caíam. Nenhuma guarda o
  via, porque o D21 separa a água em DOIS pontos e a paleta lia-se pelos
  nomes. Uma rampa prova-se pela FORMA no mapa rasterizado — o D46 percorre-a
  em raios —, e o tom de uma mancha mede-se contra a água DEBAIXO dela (`124`).
- **⚠️ O QUE SE PINTA NA ÁGUA DEPOIS DA TERRA PERGUNTA SE A ÁGUA ESTÁ À
  VISTA.** A faixa da sombra do muro saía depois do cais, a h = 0, e a parte
  dela ao longo do espelho de um degrau fica, na tela, ATRÁS do muro: pintou
  1.105 px do terreiro do degrau seguinte durante semanas. Quem desenha na
  água depois da terra pergunta se o ponto, subindo até `ALT_CAIS`, atravessa
  concreto (`_agua_a_vista`). E raster por baixo de vetor tem a mesma
  pergunta à escala do texel: o primeiro texel ao pé do muro tinha o centro
  em terra, ficou sem sombra, e mostrou um fio claro de 1,5 px (`124`).
- **⚠️ O COMENTÁRIO QUE DIZ QUAL CONTA APERTA PODE APONTAR PARA A ERRADA.** O
  `RUA_LARG` tinha ao lado a conta do pátio (`RUA_RECUO - RUA_LARG - CALCADA -
  APRON`) e a afirmação de que o armazém cabe — e cabe, em `mx`. Ao alargar a
  rua em 07/09, quem fechou primeiro foi a janela em **`my`** entre o acesso ao
  berço e o cotovelo, que nem estava escrita: ela vale `3,98 - RUA_LARG` e o
  armazém precisa de 1,987, o que põe o teto em 1,99 e não em 2,2. **Antes de
  confiar na restrição que o comentário nomeia, procure as outras** — e depois
  varra o valor, que é como se acha a que aperta.
- **⚠️ E DERIVAÇÃO E TESTE COM LIMIARES IGUAIS TÊM ZERO DE MARGEM.** O
  `vaos_da_vila()` abre o vão a `0,6` da meia-largura do sprite e o D14 mede a
  `0,30` da largura — o MESMO número. Só que um mede do canto do lote e o outro
  do centro da casa, e essa diferença chega a 0,315 unidades: uma casa cujo
  centro cai dentro do limiar do teste e cujo canto cai fora do da derivação
  escapa ao vão e sai fatiada pelo prédio. Passou despercebido enquanto nenhuma
  casa calhou naquela fatia de 6 px, e apareceu no dia em que os prédios se
  mexeram. **Dois números iguais medidos de sítios diferentes não são a mesma
  guarda** — o que gera tem de ser mais folgado do que o que confere.
- **⚠️ NADA PERGUNTAVA SE DOIS DESENHOS DO MAPA SE SOBREPÕEM.** Toda a
  maquinaria de cerco deste projeto mede PEGADA DE PROP contra faixa publicada
  — e um desenho do gerador não é prop. Os dois lotes reservados do pátio
  nasceram a olho em 07/09 e caíram em cima dos ACESSOS AOS BERÇOS, que o
  `vias()` desenha e que nenhuma faixa declarava; ficaram assim uma sessão
  inteira, invisíveis, porque o camião passava reto pela rua. Viram-se no
  primeiro frame em que ele entrou na doca e foi encostar em cima da
  demarcação. Ao acrescentar desenho ao mapa, publique-o na tabela de âncoras e
  confira-o contra o que já lá está — **interseção de intervalos nos dois
  eixos**, que é a mesma regra dos quatro cantos.
- **⚠️ E NADA PERGUNTAVA COM QUE COR O MAPA PINTA UM PONTO.** A irmã da regra
  acima, do outro lado: ali dois desenhos ocupavam o mesmo sítio, aqui a
  GEOMETRIA ESTÁ TODA CERTA e quem erra é a ordem. A calçada do cotovelo saía
  depois do asfalto da faixa reta e é 0,22 mais funda do que ele: sobrava uma
  fita da cor do passeio ATRAVESSADA NA PISTA, da largura da rua, na entrada de
  cada um dos cinco cotovelos, e viveu assim uma sessão inteira. Todo cerco
  deste projeto pergunta POSIÇÃO — pegada contra faixa, lote contra acesso,
  casa contra vão — e nenhum perguntava COR. Hoje o **D20** rasteriza os dois
  mapas com o ThorVG e percorre a `ROTA_ESTRADA` a exigir que nenhum ponto dela
  caia em calçada; a rota serve porque é escrita à mão no
  `TrafegoDeCamioes.gd` (no `Main.gd` até à `095`) e o mapa sai do gerador —
  duas fontes, e não um espelho. E a pergunta é **«não é calçada»,
  não «é asfalto»**: a rodagem leva pintura, e exigir o cinzento reprovaria uma
  zebra bem desenhada (`docs/decisoes/013`).
- **⚠️ E CASAR HEXADECIMAL EXATO SÓ SERVE EM TINTA CHAPADA.** A regra acima
  abriu a porta de perguntar COR ao mapa; esta diz onde ela não passa. A rua é
  chapada e compara-se exata com a folga do antisserrilhado; a ÁGUA leva coisa
  por cima — manchas de corrente em gradiente radial e duas camadas de espuma,
  todas semitransparentes. O pixel do berço da doca 3 sai `#3aacc7` onde a
  paleta diz `#3fb6cf`: fora dos 4/255, e o primeiro D21 reprovou um berço que
  estava certo. Onde o alvo leva camadas por cima, separe por LUMINÂNCIA com o
  limiar DERIVADO das cores publicadas — a meio entre a família escura e a
  clara —, nunca por igualdade de tom. Aqui isso dá 92,6 com 16 pontos de folga
  de cada lado, e mancha nenhuma atravessa.
- **⚠️ E A FRONTEIRA ENTRE DUAS TINTAS CHAPADAS NÃO É CHAPADA.** A regra acima
  diz onde o hexadecimal exato passa — em tinta chapada — e esta diz que a
  exceção mora DENTRO dela. O D20 reprovou o mapa CERTO em 14/09: a rota do
  camião atravessa a fronteira entre o pavimento do pátio (`#ced4d7`) e o
  asfalto (`#49535b`), e o pixel de antisserrilhado dessa fronteira sai a
  `#b1b8bc` — a **3/255** da calçada (`#aeb8bf`), dentro da folga de 4 que o
  `_mesma_cor` dá ao próprio antisserrilhado. **O valor por que uma rampa passa
  pode calhar na banda de uma TERCEIRA cor da paleta**, e nenhuma das duas tintas
  tem culpa. O remédio é o que o D17 e o D24 já sabiam e o D20 era o último a não
  saber: pergunte **quanto desenho há à volta do ponto**, nunca de que cor é o
  ponto (`docs/decisoes/025`).
- **⚠️ E A JANELA DE UMA PROVA ESCALA COM O FATOR, MAS O MÍNIMO ESCALA COM O
  QUADRADO DELE.** O raio é uma DISTÂNCIA, a contagem de pixels dentro dele é
  uma ÁREA. Escalar só o raio pede os mesmos 40 px numa janela 2,25x maior, e a
  prova passa de graça — a versão em área de "não se aperta o teto de uma guarda
  até ela apanhar um segundo defeito", com o sinal trocado.
- **⚠️ E DISTÂNCIA EM UNIDADES NÃO SOBREVIVE A UM DEGRAU DA COSTA.** A conta
  óbvia — `mx` do prop menos a borda do cais da banda de `my` dele — deu **6,85**
  para uma peça que o mapa pinta de `agua_media`, cuja banda acaba aos 6,0.
  Não há erro na conta: perto de um degrau o ponto de costa mais próximo não é a
  borda da própria banda, é a face do degrau ao lado, e as faixas de
  profundidade seguem o CONTORNO. Toda medida "a que distância da costa" neste
  mapa pergunta-se ao desenho, não à aritmética — e pela mesma razão uma
  varredura dessa distância **não é monótona**: entre 2,0 e 3,0 o número de
  props no largo sobe, desce e sobe, e parar no primeiro valor que serve é
  assentar em cima de uma fronteira que se mexe.
- **Prédio que não cabe no pátio não dá erro — dá prédio em cima do asfalto.**
  O armazém ocupa 3,76 unidades em `mx` e o pátio tinha 1,68: 0,70 dele ficavam
  na rua e 0,08 pendurados sobre a água. O teste de design passava porque
  conferia a ÂNCORA, que é um ponto, e o ponto estava no lugar certo. **Prop
  grande responde pela PEGADA**, e a largura do pátio sai de uma conta —
  `RUA_RECUO - RUA_LARG - CALCADA - APRON` — que hoje está escrita no gerador.
- **Conferir os quatro cantos de um retângulo contra uma faixa não é conferir
  o retângulo.** Foi assim que a primeira versão daquele teste deixou passar o
  defeito que ela existia para pegar: os cantos caíam a 2,82 e a 5,58, a rua
  ocupava 2,98..4,52, e a pegada atravessava o asfalto inteiro sem pousar nele
  com canto nenhum. Retângulo contra faixa é **interseção de intervalos**.
- **⚠️ NÚMERO ABSOLUTO DENTRO DE PEÇA COM TAMANHO PRÓPRIO NÃO SOBREVIVE.** A
  cruz da igreja ia de `cx0 - 0,14` a `cx0 + 0,22` — **0,36 unidades num
  campanário de 0,30**, mais larga do que a torre que a sustenta, a cobrir o
  topo inteiro em planta. Não deu erro nenhum; quem a apanhou foi a prova a ler
  `tronco` onde a tabela prometia telha. É a irmã de "encolher um prop escala-se
  no GRUPO, nunca reescrevendo as literais": ali o risco é deixar uma literal
  por escalar, aqui é escrevê-la em unidades de mundo dentro de uma peça cuja
  medida é uma fração de outra.
- **A rua tem COTOVELOS, e faixa reta nenhuma os declara.** Irmã da regra
  acima, e o que estava mesmo por trás daquela queixa. Depois de encolher os
  dois prédios o teste passava, e a estrada continuava com o armazém em cima
  dela: entre um degrau e o seguinte a rua VIRA, e o `vias()` desenha esse
  cotovelo em `mx` por cinco unidades e meia, atravessando o pátio de lado a
  lado. As quatro faixas `rua` que o gerador publicava não o cobriam — e
  nenhuma delas mentia, porque a rua RETA estava mesmo livre. Cinco props
  estavam dentro dos cotovelos, dois deles com meia unidade de pegada. Hoje o
  gerador publica `cotovelos` e o D2 confere-os; a lição é anterior ao teste:
  **conferir o retângulo contra PARTE da rua não é conferi-lo contra a rua**,
  como conferir os quatro cantos não era conferir o retângulo.
- **Antes de gerar MAIS, veja onde o que já se gera está a cair.** A queixa
  "a vegetação é bem pobre" tinha 136 copas de mata geradas e **7** dentro do
  quadro: o viés da densidade (`random ** 2.2`) empurrava-as contra
  `FUNDO_TERRA`, que é, pelo próprio nome, a parte do mundo fora do ecrã. O
  comentário da função dizia a intenção com todas as letras — "a densidade
  cresce para o fundo". Medido por degrau, a fração da faixa de mata visível
  era 11% / 50% / 10% / **0%**. Toda faixa deste mapa medida a partir do cais
  tem uma janela visível estreita, e o orçamento de desenho é de peças
  DESENHADAS, nunca de sorteios — `no_quadro()` existe para isso.
- **⚠️ E VARIEDADE NUM QUADRO ESTREITO PEDE UM SACO, NÃO UM PESO.** A irmã da
  regra acima, do lado da forma: a vila sorteava a forma de cada casa por peso,
  e a casa em L — a mais larga, a que o fim do degrau e os vãos do pátio mais
  recusam — ficou de fora da tela duas vezes seguidas, cada vez com outra
  forma a sobrar. O saco embaralhado tem cada forma o número de vezes da
  tabela, serve só os lotes que se veem, e a forma de um lote recusado volta
  para ele (`_tirar_do_saco`, `123`).
- **⚠️ E O SORTEIO NOVO VEM DE UM `Random` NOVO.** É a regra da caminhada
  sorteada, do lado do que se acrescenta: a cor, a caixa-d'água, a telha, o
  acento e o jardim de cada casa saem cada um do seu `Random`, pela ordem dos
  lotes — um sorteio a mais no da implantação mexia a vila inteira, e no das
  árvores mexia todas as copas (`123`).
- **⚠️ O QUE POUSA NOUTRA PEÇA PERGUNTA-LHE A ALTURA NAQUELE PONTO.** A
  caixa-d'água ia a uma altura escolhida à mão por forma de casa, e o pé dela
  afundava na água ou pairava. Cada telhado diz a altura em qualquer ponto
  (`z_quatro_aguas`, `z_duas_aguas`, `z_meia_agua`), e a caixa pousa num
  murete cujos quatro cantos de baixo seguem essa altura. E pousa na
  CUMEEIRA: no pano de trás, a cumeeira fica entre a câmera e o pé, e o
  murete, desenhado depois, pintava-se por cima dela (`123`).
- **⚠️ NUMA PEÇA QUASE QUADRADA, AS QUINAS DE CIMA E DE BAIXO ESTÃO NA COLUNA
  DO MEIO.** Quem decide a coluna da tela é `mx − my`, e o poste da quina da
  frente da praça atravessava a entrada do coreto, centrado nela. E dentro de
  um lote a ordem também é profundidade: a árvore atrás do coreto, desenhada
  depois dele, pintava-se por cima do telhado; a moita atrás do muro sai antes
  dele, e o muro tapa-lhe o pé (`123`).
- **⚠️ E CLASSIFICAR FACES PELO SINAL PEDE FOLGA.** No octógono do coreto,
  duas águas ficam de perfil à câmera e `cos + sin` delas dá ±1e-16 em vez de
  zero: decidir frente e trás por `> 0` punha-as de um lado ao sabor do
  arredondamento, a prova do D24 escolhia uma delas, e a plataforma ganhava
  um polígono sem área. A folga é `1e-6` (`123`).
- **Fileira dupla só lê se a separação passar de UM elemento.** Em isométrico
  duas fileiras separadas por `Δmx` ficam a `Δmx × MEIA_LARG` px na tela. A
  segunda fileira da vila nasceu com 57px de separação para telhados de 78: a
  casa de trás saía 73% tapada e as duas fileiras liam como um borrão de
  telha. É a irmã da regra "duas faces no MESMO plano dão um buraco preto" —
  sobreposição que o olho não consegue desfazer não é profundidade, é sujeira.
- **Peça pequena sem aresta lê como mancha, e a receita já existe.** A copa de
  árvore eram duas elipses concêntricas deslocadas 8-14px numa copa de 40 — a
  MESMA forma que o enrocamento tinha tentado e descartado em 03/09. `com_saia()`
  em `gerar_mapa_iso.py` é essa receita com nome: polígono irregular de topo e
  uma saia por aresta virada para baixo. Antes de desenhar volume pequeno,
  procure-a — e antes de corrigir um defeito de leitura, procure se a função
  IRMÃ já o corrigiu (o capim tinha a correção escrita num dos dois sítios e
  não no outro; a mancha de desgaste do cais estava a ser pintada no relvado
  enquanto a junta, dez linhas abaixo, sabia exatamente onde parar).
- **Comentário que explica como a constante ao lado apodrece é um pedido para
  ela ser derivada.** O `VILA_VAZIOS` — onde os prédios do pátio tapam a vila
  — eram dois intervalos escritos à mão com vinte linhas a avisar que
  envelheciam calados, e envelheceram. Hoje saem de `vaos_da_vila()`, e a
  derivação achou o que a versão à mão escondia: a coluna da tela não chega,
  porque um prédio tapa para CIMA e só até à altura do sprite dele.
  ⚠️ **E ACONTECEU OUTRA VEZ NO ANDAR DE BAIXO, com o mesmo par de prédios.**
  O `PREDIOS_DO_PATIO` dizia no comentário "lido de `Main.tscn`" e NÃO era
  lido: era copiado, e o `my` estava 1,10 e 1,05 unidades adiantado — meia
  casa de vão fora do sítio, com o D14 a passar porque lê a mesma constante
  onde o defeito mora. Um comentário que diga "lido de X" e não leia X é a
  forma mais barata desta armadilha: **se está escrito que sai de algum lado,
  faça-o sair de lá.**
- **Recuar um contorno para DENTRO não é `costa_deslocada` com o sinal
  trocado.** Aquele empurra cada vértice na diagonal (+d em mx, −d em my), o
  que serve para uma faixa de água; ao longo de um MURO isso desloca também o
  `my`, e a linha recuada sai adiantada da original. Ao fazer a praia de 04/09
  a crista ficou 1,3 unidade à frente da linha de água e abriu-se um triângulo
  de **água funda dentro da terra**, no fim do cais. Recuo é pela normal de
  cada segmento, e cada quina leva o remate que pede: chanfro onde a terra
  abraça a quina, cruzamento das duas linhas onde ela é uma ponta.
- **⚠️ REAMOSTRAR UMA CAMINHADA COM SORTEIO MOVE TUDO O QUE ELA ESPALHA.** O
  `andar_costa` percorre a costa a passos irregulares tirados de um `Random`, e
  dele saem o enrocamento do cais, a espuma, as pedras da praia, o capim e as
  árvores da restinga. Ao desenhar as pontas em 14/09, densificar a linha teria
  mudado o número de sorteios ANTES do cais e trocado de sítio as ~300 pedras do
  enrocamento — meia sessão de diferença visual no porto por causa de uma
  correção na praia. A caminhada continua a medir-se na ESCADA, com os mesmos
  comprimentos de segmento e a mesma sequência de sorteios; o que mudou foi só
  o ponto onde cada coisa cai. **Quem mexe na geometria de uma varredura
  sorteada pergunta primeiro o que mais bebe daquele mesmo `Random`.**
- **⚠️ E FAMÍLIA DE CURVAS CONCÊNTRICA É O QUE IMPEDE COSTURA.** Tudo o que
  acompanha a costa — linha de água, baixio, espuma, pedras, as três linhas da
  rampa e o campo de cor da água — sai de `ponto_costeiro()`, uma função só, com
  o fileto de cada quina em volta de um centro FIXO e o raio a crescer com a
  distância à terra. Duas curvas assim nunca se cruzam, e quando o raio chega a
  zero a curva volta a ser a quina de sempre — que é como o cais fica byte a
  byte igual sem uma linha de exceção. **Uma costura é duas contas a discordar;
  a saída não é afiná-las, é haver uma só.**
- **Faixa que acompanha a costa desenha-se pelo CONTORNO, nunca degrau a
  degrau.** A regra já estava escrita no `costa_deslocada` — "a versão anterior
  tratava cada degrau como uma faixa solta" — e mordeu outra vez um andar
  acima: a praia feita por degrau saiu como duas rampas soltas com um degrau
  de terra a pique entre elas, no sítio onde a costa vira.
- **Fronteira paralela à costa precisa de meandro LONGO.** Sacudir cada
  amostra dá ruído de 11 px de período, que na tela não é nada: três tons de
  areia com as fronteiras assim sacudidas saíram como três FITAS de largura
  constante. Duas senóides de períodos diferentes resolvem — e três faixas
  eram uma a mais, porque a referência pede "uma faixa clara" e não um
  arco-íris.
- **Areia vista pela água não é a cor da areia misturada com a água.** Pintar
  `#d8cb9c` a 0,40 sobre o turquesa dá `#8bc8c2`, que mede **0,06** de Weber
  contra o baixio — some —, e a faixa lavada pelo mesmo caminho dá um
  azeitona que lê como lama. Baixio de areia é água CLARA e pouco saturada:
  escolhe-se pelo VALOR (209 contra os 176 do baixio) em vez de sair de uma
  mistura. É a irmã da regra do matiz, do outro lado.
- **O que CRESCE no chão pertence à camada do chão.** O capim da restinga
  nasceu junto com a areia, que é desenhada no fim com o enrocamento — depois
  da rua e depois da vila —, e apareceu por cima dos telhados e do passeio. O
  mundo estava certo (ele para 0,15 antes da calçada); a ORDEM é que não,
  porque uma casa levanta-se 20 px e o que vem depois cai-lhe em cima.
- **O importador de SVG do Godot é o ThorVG e não desenha `<text>`.** Texto no
  mapa é polígono de estêncil (ver `DIGITOS`).
  ⚠️ **E SÓ DESENHA O `<use>` COM `xlink:href`**, e com o `xmlns:xlink` na
  raiz: o `href` do SVG 2 sai em branco, sem erro (`127`, as árvores
  embutidas).
- **⚠️ UM PROP POR CIMA DO MAPA SÓ ERRA SOBRE O QUE ESTÁ À FRENTE E É MAIS
  ALTO.** O prop pinta-se por cima de tudo: uma árvore que balança atrás de
  uma casa sai com a copa no telhado, e por isso a mata do morro respeita o
  contorno da vila e a da cidade vai EMBUTIDA no SVG (`127`). Mas chão plano
  à frente nunca tapa um prop — o pixel acima do pé está à frente do chão que
  cobre, e a sombra abaixo dele é sombra no chão. A restinga nasceu a exigir
  a planta inteira acima da crista e encostou tudo à rua.
  ⚠️ **E O QUE SE MEDE DA COSTA NÃO SABE DA RUA.** Junto do salto de um
  degrau a costa corre em `my` e a rua vira no cotovelo: plantas postas a
  «tantas unidades da crista» caíram no asfalto. Quem pousa a partir da costa
  confere a rua do degrau DELE e os cotovelos.
  ⚠️ **E RASTER NOVO TAPA O QUE SE DESENHOU ANTES DELE NO MESMO SÍTIO.** Com
  o chão da restinga no `campo_do_chao`, o capim que saía no `praia_chao`
  sumiu por baixo — e continua a ter de sair antes da rua e da vila.
