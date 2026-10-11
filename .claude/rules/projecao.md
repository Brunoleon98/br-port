---
paths:
  - "tools/gerar_mapa_iso.py"
  - "tools/gerar_props_iso.py"
  - "blender/**"
  - "docs/BRP_SPATIAL_CONTRACT.md"
  - "brport_vs/scenes/Main.tscn"
  - "brport_vs/scenes/dock/Dock.tscn"
  - "brport_vs/scripts/PropIso.gd"
  - "brport_vs/scripts/TrafegoDeCamioes.gd"
  - "brport_vs/art/porto_mapa_ancoras.json"
  - "tools/medir_enquadramento.py"
  - "brport_vs/tools/medir_enquadramento.gd"
---

# Regras — a projeção isométrica

> Carrega quando a sessão lê ou edita um arquivo do `paths:` acima. Veio do
> `CLAUDE.md` em 10/10, palavra por palavra (`docs/decisoes/091`); o índice
> de todas as regras está no núcleo. Lição nova deste tema entra aqui.

### Projeção isométrica — é um contrato entre três arquivos

`tools/gerar_mapa_iso.py`, `tools/gerar_props_iso.py` e `brport_vs/scenes/Main.tscn`
têm de concordar. As constantes: `MEIA_LARG=30`, `MEIA_ALT=15` (razão 2:1),
`ZOOM=2/3`, câmera do Blender a `ROT_X=60°`, `ROT_Z=45°`, `ESCALA_ORTO`
derivada delas.

- **São DOIS espaços desde 05/09, e a fronteira é `tela()`.** O mapa DESENHA a
  30 num quadro de 1080 e o `viewBox` do SVG entrega 720 — a câmera é o `ZOOM`,
  e o `MEIA_LARG` efetivo é 20. Quem desenha fala DESENHO; a tabela de âncoras,
  o `Main.tscn`, o `Main.gd`, o trânsito dos camiões (`TrafegoDeCamioes.gd`,
  `095`), o manifest BRP e o teste de design falam TELA.
  ⚠️ **E A TEXTURA JÁ NÃO TEM O TAMANHO DO ESPAÇO TELA.** Os quatro SVG de mapa
  declaram `width="720"` sobre `viewBox` de 1080, e o importador rasteriza pelo
  `width`: até 14/09, com `svg/scale=1.0`, o desenho existia a 1080 e chegava à
  textura a 720, que o `canvas_items` voltava a ampliar 1,5× no aparelho — uma
  redução seguida de uma ampliação. Hoje eles importam a **1,5** e os três nós
  de mapa têm `expand_mode = 1`, de modo que o rect continua com 720 de
  COORDENADAS e a textura carrega 1080 PIXELS (`docs/decisoes/025`). Logo, o
  espaço TELA continua a ser 720 e é isso que a tabela de âncoras publica; quem
  amostra a textura por coordenada de tela tem de escalar, e quem o faz num
  lugar só é o `_mapa_lido` do teste de design.
  ⚠️ **E SUBIR O `svg/scale` REMOVE UMA REDUÇÃO — NÃO AMPLIA UM DESENHO.** Desde
  14/09 os quatro mapas importam a **1,5** e a textura sai com os 1080 que o
  arquivo já tinha (`docs/decisoes/025`). A armadilha que o plano previa — *"a
  1,5x um traço de 1 px passa a 1,5 e um vinco calibrado para quase sumir
  reaparece"* — **não vale aqui**, e a conta diz porquê: um `stroke-width` está
  em unidades do `viewBox` de 1080, e num telefone de 1080 ele media 1,6 px
  físicos antes (rasterizado a 1,067 e ampliado pelo `canvas_items`) e mede os
  mesmos 1,6 px depois, agora nítidos. Ela vale para a alavanca **B**, que
  redesenha props nas unidades da SAÍDA. Antes de varrer constantes em pixel por
  causa de uma mudança de escala, pergunte se o que mudou foi o DESENHO ou só a
  amostragem dele — e confirme na medição: se o desenho tivesse sido ampliado, a
  rampa de cada fronteira ocuparia 1,5x mais pixels; ela ficou 14,3% mais
  estreita.
  ⚠️ **E O MAPA TEM DUAS CAMADAS COM ESCALAS DIFERENTES.** O campo de cor da
  água é um PNG de **720x720 embutido** no SVG, esticado sobre o `viewBox` de
  1080: são **43% da janela** onde a precisão que falta não está no arquivo, e
  nenhum `svg/scale` lha dá. Ele melhora na mesma, por outra razão — deixa de
  fazer três reamostragens e passa a fazer uma —, e não se denuncia porque
  desenha campo CONTÍNUO. Medir o quadro todo de uma vez misturaria o ganho do
  vetor com o zero do raster; a máscara sai de rasterizar o SVG uma segunda vez
  sem a `<image>`.
  ⚠️ **E ELE FICA A 720 — construído a 1080, medido e REJEITADO** (`026`).
  **Resolução só se paga onde há FRONTEIRA para afiar**, e este raster não tem
  nenhuma: é uma rampa contínua da distância à costa, e tudo o que tem traço
  naquela água — pedras, espuma, riscos de onda, linha de areia — é VETOR, e já
  ganhou na alavanca A. A 1080 o pico da fronteira não se mexe (29,73 → 29,71) e
  o maior Δ de canal na janela é **4/255**, com ZERO pixels a chegarem ao piso
  de Weber — por 1,8x o tempo de geração dos dois mapas grandes. **"43% da
  janela" e "2,25x de pixels" são verdade e não querem dizer nada:** a pergunta
  nunca é quantos pixels a camada tem, é que fronteira há dentro dela.
  ⚠️ **E A BATERIA DE 720 NÃO RESPONDE À PERGUNTA DA RESOLUÇÃO.** Ela é travada
  a 720x1280, e a 720 a textura de 1080 é reduzida pela GPU de volta a quase o
  que era. O antes/depois honesto é a **1080x1920** — 1,5x exato nos dois eixos.
  E o aparelho pequeno foi medido e **melhora**: o downscale de 1,5:1 age como
  supersampling parcial, com os pontos soltos a caírem de 3,10% para 2,90% das
  fronteiras.

  **A razão de não escrever 20 na constante:** altura, naquele arquivo, é
  PIXEL — o `ALT_CAIS`, as paredes da vila, a largura de cada traço —, e baixar
  só o `MEIA_LARG` encolheria a PLANTA deixando as ALTURAS paradas, com o porto
  esticado 1,5× para cima e nenhuma das cinco suítes a lê-lo. Escala-se no
  GRUPO, que é a mesma regra dos props.
- **O prop não tem `viewBox`: quem o encolhe é o `ortho_scale`, e só ele.** O
  `z()` continua na escala de DESENHO de propósito — o fator de altura e o
  `ortho_scale` cancelam-se, e mexer nele levantaria cada prop 1,5×. Afastar
  uma câmera não estica o que ela filma.
  ⚠️ **E O PROP TEM DUAS MEDIDAS DESDE 16/09: 512 de COORDENADA e 768 de
  PIXEL** (`docs/decisoes/029`, a alavanca B). O `ESCALA_ORTO` sai do
  `RESOLUCAO_TELA` e NÃO do `RESOLUCAO` — presos um ao outro, a câmera
  afasta-se na mesma proporção em que o quadro cresce e a alavanca entrega
  256 px de moldura vazia em vez de um pixel de desenho. Quem desfaz a
  diferença é `expand_mode = 1` nos 31 nós de prop (a mesma linha dos três nós
  de mapa), a `scale` que o `Fauna.gd` escreve nos seis `Sprite2D`, e o
  `PropIso` para toda régua que leia `get_used_rect()`. O **D31** tranca-o.
  ⚠️ **E A ALAVANCA B NÃO REDESENHA NADA, ao contrário do que o item previa.**
  A previsão era que "os props são desenhados nas unidades da SAÍDA", logo todo
  número em pixel do gerador teria de ser varrido. Medido: a geometria dele
  está em unidades de MUNDO (`chanfrar()` 0,020; `TABUA` 0,30; o ruído), e os
  "31px na tela" dos comentários são OBSERVAÇÕES do que esses valores produzem,
  não entradas. Com o `ortho_scale` parado, o mesmo mundo é amostrado mais
  fino: pelo `comparar_props.py`, que reduz os dois a 16×16 e é cego à
  resolução, **51 dos 61 props medem no máximo 0,0059** — contra 0,022 de um
  pixel de deslocamento e 0,42 de um prop trocado por outro. É a mesma razão
  estrutural pela qual a A também não a encontrou: **antes de varrer constantes
  por causa de uma mudança de escala, pergunte se o que mudou foi o DESENHO ou
  só a amostragem dele.**
  ⚠️ **E OS QUATRO QUE MUDARAM NÃO DESMENTEM ISSO — DENUNCIAM OUTRA COISA.**
  Três retratos do Sr. Ribeiro mediram 0,08 porque a GRAVATA e a CAMISA
  estavam coplanares, e a resolução mais fina passou a desenhar o empate: a
  gravata saía partida ao meio, escura em cima e rosa lavado em baixo. O
  defeito era de 01/09 e o que o revelou foi a alavanca. **Subir a resolução
  não cria geometria degenerada: tira-lhe o disfarce** — e quem o apanhou foi
  a régua que compara levas, não suíte nenhuma.
  O que a alavanca envelheceu foi o outro lado: os números em pixel de quem
  MEDE o PNG — `MEIO_QUADRO`, o pivô da lança, a régua da pessoa de 15 px, o
  `D29_LARG_MIN`, o `ZOOM` das duas folhas de contato.
  ⚠️ **E RESOLUÇÃO PAGA-SE NO QUADRO INTEIRO E ENTREGA NO DESENHO.** É a irmã
  da regra da `026` — *"só se paga onde há FRONTEIRA para afiar"* — do lado do
  CUSTO em vez do ganho. Medido nos 61 props: **o desenho ocupa 10,4% do
  quadro, e 89,6% é moldura vazia** (o poste 0,04%, o píer 7,4%; só os dez
  retratos passam de metade). Daí a B custar **+80 MB de VRAM e +42,3% de
  `.pck`** para mudar 1,56% da janela, contra os +9,89 MB e 5,12% da A — **15 a
  27 vezes o preço por pixel visível**, e nenhuma das duas medidas mente.
  Antes de subir a resolução de um asset, meça que fração dele é desenho: o que
  torna esta alavanca barata é CORTAR o quadro.
  ⚠️ **E CORTOU-SE SEM MEXER NO QUADRO** (`049`): o importador `texture_atlas`
  apara a moldura e a MARGEM do `AtlasTexture` repõe os 768, logo nenhum nó,
  âncora ou manifest mudou — a VRAM de textura em jogo foi de 235,68 a 64,04
  MB e o `.pck` perdeu 17,4%. O briefing previa `bpy` e os 69 regerados porque
  lia o quadro como ARQUIVO; a pergunta era o quadro na VRAM. **Antes de pagar
  um contrato novo, pergunte se o motor já separa o que o arquivo junta.**
  ⚠️ **E O EMPACOTADOR ARREDONDA A LARGURA A POTÊNCIA DE DOIS:** um retrato de
  510 px sai num atlas de 1024, 26% pior do que o quadro. Os retratos ficam
  fora, e quem o decide é o validador (atlas mais caro do que o quadro
  reprova), não uma lista.
  ⚠️ **E PROP NOVO ENTRA PELO IMPORTADOR POR OMISSÃO**, que o validador
  reprova. A receita: o `.import` dele passa a `texture_atlas` (a forma está em
  qualquer vizinho — conserve o `uid` do próprio arquivo), o `--import` corre
  **DUAS vezes** (a primeira escreve o atlas em `art/props/_atlas/`, a segunda
  importa-o) e o atlas e o `.import` dele vão no commit. Sem eles, o import
  único do CI deixa o `preload` a apontar para um atlas por importar.
  ⚠️ **E A FORMA É A INTEIRA**, com `path`, `group_file`, `valid` e
  `dest_files` (o hash é o md5 do caminho `res://`): em 27/09 um `.import` só
  com o importador e os `[params]` não escreveu atlas nenhum, e o `--import`
  seguinte ficou em laço, sem erro e sem sair (`070`).
- **Constante em PIXEL é constante que envelhece quando o `ZOOM` muda, e ela
  não dá erro.** Foram cinco em 05/09: a silhueta do caminhão e o corte que
  exige pegada no teste de design, a largura de telhado da vila, os sprites do
  pátio e o avanço da espuma. Duas reprovavam o que estava certo; **uma deixou
  de reprovar seja o que for** — o corte de 130px passou a ficar acima de todos
  os props, e a asserção que exige pegada nunca mais teria exigido nenhuma.
  Ao mexer na câmera, procure todo número medido em pixel e pergunte de que
  escala ele é.

- **Altura é em PIXELS DO MAPA**, não em unidades do Blender. A conversão está
  em `z()` num lugar só. Ignorar isso põe um píer 2,4× mais alto que o cais
  desenhado ao lado.
- **`pos()` inverte o sinal de Y.** No Blender a direita da tela é (+X, +Y);
  no mapa o `+my` puxa para a ESQUERDA. Um prop simétrico não denuncia a
  diferença — o primeiro assimétrico saiu 40px fora.
- **⚠️ E A PROJEÇÃO ESPELHA O CHÃO: DIREITA E ESQUERDA PERGUNTAM-SE À TELA.**
  Com `mx` e `my` lidos como o `x` e o `y` de um caderno, quem desce em `+my`
  tem a água à direita; na tela tem a VILA. Dezasseis dias de camiões na mão
  inglesa com o comentário a jurar a brasileira, e as retas e os cotovelos
  escritos com a regra de sinais opostos — daí as duas rotas se cruzarem em
  dez pontos (`052`). Mão, sentido de volta e "à direita de" escrevem-se como
  CONTA — o vetor projetado contra a direita do sentido projetado, `(-hy, hx)`
  com o `y` para baixo —, e é assim que o D13 §7g a pergunta.
- **O quadro de todo prop tem 512 de COORDENADA e o centro dele é a origem do
  mundo.** Posicionar um prop na cena é subtrair meio quadro, não acertar no
  olho — e desde 16/09 meio quadro são **256 na cena e 384 no PNG**, que até
  aquele dia eram o mesmo número (`029`). Toda régua que leia a textura e
  responda em coordenada passa pelo `PropIso`.
  ⚠️ **E O `get_image()` DE UM PROP DE MAPA JÁ NÃO É O QUADRO** (`049`): num
  `AtlasTexture` ele devolve a REGIÃO, com o canto em (0, 0), e uma régua que
  lesse o `get_used_rect()` dela apontaria 300 px ao lado. Pixel de prop lê-se
  por `PropIso.imagem()`. E **um `AtlasTexture` por cima de outro não
  compõe**: o `get_image()` do conjunto dá o desenho e o `draw` desenha a
  margem vazia — recorte-se do atlas de BAIXO (`PropIso.recorte()`).
- **E desprojetar um prop de volta ao mundo pede a ALTURA em que ele pousa.**
  Quem está em terra pousa a `ALT_CAIS`; quem está na água, a 0 — é o que o
  `_origem`/`_mundo` do teste de design faz. Desprojetar tudo a 0 desloca cada
  prop de terra em **+0,87 em mx E em my**, o que é pouco para se notar e
  suficiente para mudar a que DEGRAU ele pertence. Custou uma tabela inteira
  de posições errada em 04/09, e ela parecia plausível.
- **Mas REESCALAR a projeção é uma semelhança, e aí a altura cancela-se.**
  Desprojetar num espaço e reprojetar noutro dá `novo = P + (velho − Q) × ZOOM`
  — a altura entra e sai, desde que o `alt_cais` encolha junto com a câmera.
  A regra acima continua a valer para ler o MUNDO de um prop; para mover 37
  props de uma escala para outra ela não muda nada, e saber isso é a diferença
  entre uma migração de uma linha e uma tabela feita à mão. O que prova que
  correu bem é a âncora: as três docas têm de cair a 0,00 px do que a tabela
  publica.
- **⚠️ DUAS PEÇAS À MESMA ALTURA NO MUNDO NÃO ESTÃO À MESMA ALTURA NA IMAGEM,
  se estiverem a FUNDOS diferentes.** Nesta câmera cada unidade de
  profundidade vale meia unidade de altura na tela, então uma placa na face da
  frente (`y = -fundo/2`) desce meia profundidade em relação a uma peça no
  meio (`y = 0`). Medido nos retratos de 13/09: a gola pousada na face do peito
  saiu a FLUTUAR dez pixels abaixo do pescoço, com um buraco de blusa pelo
  meio, e a conta do mundo dizia que estavam encostadas. Peça que tem de
  ENCOSTAR noutra partilha o fundo dela — a gola virou uma caixa à volta do
  pescoço. É a irmã da regra do chanfro a 45°: ali a folga esticava-se na
  diagonal, aqui a altura desloca-se com a profundidade.
- **E NUMA PEÇA QUE ENVOLVE OUTRA, É O FUNDO QUE DECIDE QUEM SE VÊ.** A gola
  dos três retratos tinha 50 de fundo e o degrau do ombro 68: a face da frente
  do degrau fica nove pixels à FRENTE da dela, e o colarinho claro das três
  personagens simplesmente não aparecia no render — sem erro nenhum, só um
  pescoço sem gola. Quem tem de ser visto é mais fundo do que o que o rodeia.
- **E pela mesma conta a profundidade projeta-se para CIMA: cortar fundo não
  achata, tira TELHADO.** O primeiro busto tinha 96 de fundo na cabeça e 104 no
  cabelo, e saiu um capote a comer o quadro com a cara lá em baixo. Encolher o
  fundo devolveu o espaço à face — e não emagreceu nada, porque o que se via
  daquele fundo era a face de cima.
- **Só as faces `+x` e `-y` são visíveis** por esta câmera. Detalhar as outras
  é render que ninguém vê.
- **E o `-x` É O FUNDO DA IMAGEM, o que é outra pergunta.** A regra acima diz
  que FACE se vê; esta diz que PONTA do prop fica à frente. Peça alta em `-x`
  projeta-se para cima e para trás, e o que estiver baixo atrás dela desaparece:
  o arrasteiro nasceu com a casa do leme a meia-nau e o arrasto todo a `-x`, e o
  tambor de rede saiu invisível com o pórtico a ler como parede ao fundo. Ao
  compor um prop com um lado que trabalha e um lado que não, o que se quer VER
  avança para `+x` — e vale a pena perguntar se a coisa de verdade também é
  assim, porque muitas vezes é (um arrasteiro tem mesmo a ponte à frente).
- **Ordem de nó É profundidade.** Quem tem `mx+my` maior está mais perto da
  câmera e tapa quem tem menor. Vale em `Dock.tscn` e em `MapaWrap/Cenario`.
  O teste de design confere isto.
  ⚠️ **E SÓ ENTRE IRMÃOS: `MapaWrap/Docas` desenha-se DEPOIS do `Cenario`,
  inteiro.** O que anda numa doca e sai do píer pinta-se por cima de todo
  prop do cenário, mesmo do que lhe está à frente. Na ida ao camião do n2 a
  entrega no flanco punha o trabalhador 117 px por cima do armazém na doca 2.
  Toda guarda de profundidade estava verde, porque compara irmãos; quem o
  viu foi o Bruno, no GIF. O D40 §6 prova-o contra o cenário (`077`).
- **⚠️ CHANFRO A 45° INFLADO PELA FOLGA AFASTA-SE `√2` VEZES MAIS.** Vale para
  toda peça que exista em versões concêntricas — asfalto, meio-fio, calçada. A
  esquina inflada de `folga` em `mx` E em `my` põe a reta a 45° a `folga · √2`
  da original, não a `folga`: medida no render, a faixa de passeio saltava de
  **3,9 px** nas retas para **8,8 px** em cima do bisel, e lia-se como um muro.
  Recuar o corte de `folga · (2 − √2)` acerta. Sobra 1,58×, e essa parte não se
  corrige: em isométrico a direção (1,1) comprime-se e a (1,−1) estica-se, logo
  **faixa de largura constante NO MUNDO não tem largura constante NA TELA** — e
  igualá-la seria escrever pixel dentro de geometria de mundo, que é a fronteira
  que o `tela()` existe para não deixar atravessar.
- Mexer na projeção **obriga** a regerar props e mapas e a rodar o teste de
  design — que existe exatamente para pegar essa divergência.
