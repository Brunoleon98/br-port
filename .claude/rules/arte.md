---
paths:
  - "blender/**"
  - "art_lab/**"
  - "brport_vs/art/**"
  - "tools/gerar_props_iso.py"
  - "tools/conferir_lote_de_arte.py"
  - "tools/conferir_casco.py"
  - "tools/comparar_props.py"
  - "tools/medir_silhueta_props.py"
  - "tools/arte_orfa.py"
  - "tools/preparar_sprites.py"
  - "brport_vs/tools/prancha_prop.gd"
  - "brport_vs/tools/escala_props.gd"
  - "brport_vs/tools/catalogo_props.gd"
  - "brport_vs/scripts/Retratos.gd"
  - "brport_vs/scripts/Fauna.gd"
  - "docs/design/BR_Port_Plano_Arte_Blender.md"
  - "docs/design/BR_Port_Style_Guide_Flat_Design.md"
---

# Regras — arte: props, Blender e retratos

> Carrega quando a sessão lê ou edita um arquivo do `paths:` acima. Veio do
> `CLAUDE.md` em 10/10, palavra por palavra (`docs/decisoes/091`); o índice
> de todas as regras está no núcleo. Lição nova deste tema entra aqui.

## Os avisos do `bpy` (do bloco de «Como rodar»)

Anotam o `pip install "bpy==4.5.0"` da receita do núcleo.

```sh
# ⚠️ o wheel tem 373 MB e o download já se cortou a meio (o pip diz que o
# HASH não bate, não que a rede caiu): `pip download` primeiro, instala do arquivo
# ⚠️ redirecionado para arquivo, o `gerar_brp.py` não escreve UMA linha até
# acabar (o stdout do Python vai em bloco): `python3 -u`, ou conte os PNGs
# novos. Os 32 camiões levaram 20 min com o log vazio (`070`)
# ⚠️ e o tempo ia quase todo no `view_layer.update()` que o `bpy.ops` faz a
# cada `primitive_*_add`, quadrático no número de objetos: o catálogo passou
# dos 30 min. Desde a `080` o kit monta sem ele (`primitiva()`), com a cena
# igual byte a byte pelo `--despejar`; `BRP_CAMINHO_LENTO=1` volta ao lento.
# ⚠️ E com ele a `dimensions` e a `matrix_world` de uma peça ficam VELHAS
# depois de criada a seguinte: quem mede outra peça pede o `update()` antes
# As pranchas, os recortes e os conferidores de arte correm no Python do
# SISTEMA, que não traz o pillow: `pip install numpy pillow` (~8 s)
```

### Arte

- **Arte que chega de fora passa por `tools/conferir_lote_de_arte.py` antes de
  entrar.** Ele mede alfa e o ângulo da base contra os 26,57°. Dois lotes já
  vieram com o xadrez de transparência pintado nos pixels, e o de 31/08 vinha
  ainda com metade das peças noutra projeção.
  ⚠️ **E trabalho de fora chega com uma BASE: confira-a no GitHub antes de ler
  um número dele.** O pacote do ChatGPT de 23/09 foi feito sobre o PR #58 num
  checkout cujo HEAD o GitHub não conhece, com decisões `034`–`036` que colidem
  em número com as daqui e um galpão «aprovado» que só existe lá. O remendo
  aplicou limpo na `main` e o teste de design passou — sem nenhuma guarda a
  perguntar pela peça nova. Hoje o material dele vive em `art_lab/`, e a
  porta de entrada diz a base, a pasta e a prova de cada entrega.
- **Asset novo sai de `blender/gerar_brp.py`**, que partilha a câmera e o kit
  com `gerar_props_iso.py`. Nada de um segundo estúdio ao lado.
- **Prop no cenário nunca sai de gerador de imagem.** Duas levas perdidas: o
  gerador não erra o desenho, erra o ÂNGULO, e ângulo errado não se conserta
  rodando no Godot. Retrato em painel, sim; prop no mapa, não.
- **⚠️ A TÉCNICA DE UM ASSET É ESCOLHA DO BRUNO — o que a regra PERMITE não
  é o que ele escolheu.** Em 23/09, na frente dos retratos, a sessão julgou que
  o kit de caixas do Blender não chegava e desenhou nove retratos em VETOR,
  fotografados no jogo: *«não deveriam ter sido criados»*. Ele queria o
  Blender melhor. Protótipo não é neutro: gasta a sessão e empurra a escolha.
  Achou que a técnica em uso não alcança o pedido? **Pergunte qual, antes de
  produzir** — é a regra de paragem, com arte no lugar do `# TUNING:`.
- **⚠️ MEDIDA DE PROP LÊ-SE NO PNG, OU DEPOIS DE TODA ESCALA QUE O GERADOR
  APLICA.** Em 27/09 a régua da pessoa saiu de duas peças que pareciam
  concordar em 1 u = 4,9 m — e uma delas, a cabine do camião, foi lida nas
  literais do construtor, antes do `ESCALA_CAMINHAO` (0,72) que o `brp_porto`
  aplica no fim. O Bruno aprovou 0,65 como «1,5× o real», e era 2×: a pessoa
  saía mais alta do que a cabine a que ia encostar. E o kit não é isótropo — o
  chão dá ~5,2 m/u e a altura ~5,6 px/m —, logo cada coisa mede-se pela régua
  do eixo em que o olho a compara (`069`).
- **O que troca de estado numa partida não pode estar assado no fundo.** Píer,
  armazém, escritório e pátio são props ou mapas alternativos. A vila é a
  exceção, e de propósito: ela troca entre FASES, não entre turnos.
- **E o estado ANTES não pode partilhar as peças do estado DEPOIS.** O
  `galpao_velho` reusava a lista de paredes do `galpao` — plinto, caixa branca
  limpa, portão fechado, calha e três janelas de vidro — e trocava só a cor do
  telhado. O porto abria "em ruínas" com um galpão de paredes novas, e a
  queixa que isso gerou foi "as construções parecem avançadas para um porto
  inicial". A regra certa já estava escrita ao lado, no comentário do
  escritório: **a ruína não é o prédio pintado de velho, é MENOS prédio** —
  parede caída, vidro nenhum, meio telhado. Partilhar peças entre dois estados
  poupa render e custa a leitura, que é o que o estado existe para dar.
- **E o estado DEPOIS precisa de vocabulário próprio, não só o ANTES.** É a
  mesma regra com o sinal trocado, e foi o que sobrou depois de a ruína ser
  consertada em 05/09: o armazém ACABADO continuou a ser desenhado só com o
  repertório doméstico — parede lisa, telha, `janela()` com moldura, a
  `porta()` do kit esticada — e lia-se como a maior casa da vila. Prédio que
  tem função no jogo precisa das peças DA FUNÇÃO: um armazém quer plataforma
  de carga, portão de enrolar, chapa corrugada e fita de vidro corrida.
- **⚠️ E REDUZIR UMA JANELA A UMA COR PEDE A MEDIANA, NUNCA A MÉDIA.** A regra
  acima diz que cor misturada não casa com tom publicado; esta diz como não a
  fabricar sem querer. A média de uma janela INVENTA um valor que não está no
  desenho — e que pode calhar na banda de uma terceira cor da paleta, como o
  pixel de antisserrilhado que reprovou o D20. O pixel MEDIANO por luminância é
  um pixel de verdade, e não se deixa mover por uma pedra, um risco de junta ou
  um tufo de capim dentro da janela (`docs/decisoes/027`).
- **⚠️ COPIAR O VALOR DE UMA COR QUE NÃO VIVIA DELE NÃO COPIA NADA.** Irmã da
  regra do matiz, logo abaixo, e do outro lado dela. O telhado de zinco do
  armazém foi escolhido para ter a luminância do telhado de telha (108 contra
  105), e medido no jogo ficou a **0,12 de Weber** contra o asfalto do pátio —
  que é o que a telha já dava (0,13). A telha nunca se separou do chão pelo
  VALOR; separou-se pelo MATIZ, e copiar a luminância copiou a metade que não
  fazia o trabalho. **Antes de preservar um número, descubra se era ele que
  segurava a leitura** — e a resposta mede-se contra o FUNDO, não na paleta.
- **A paleta mente sobre o que se vai separar no render.** No dicionário a doca
  do armazém (152) fica noventa pontos abaixo da parede (241); com a luz da
  cena, a doca sai a ~150 e os vincos da chapa a ~135 — a faixa da base e a
  textura da parede na MESMA banda. Quem separou foram três pixels de `metal`
  no topo da doca. A esta escala quem separa não é o tom, é a LINHA escura, e
  isso confere-se no render e não na tabela de cores.
  ⚠️ **E ENTRE O HEX E O PNG HÁ UMA CAMADA QUE NINGUÉM ESCOLHEU: o AgX.** O
  Blender 4.x dá AgX a toda cena nova, e até 24/09 nenhum arquivo o dizia;
  hoje o estúdio escreve-o (`COR_PADRAO`). Medido em 23/09: o `#eef2f5` sai a
  191 num plano de emissão, e **nenhum prop passa de ~190 no p99**. O mapa é
  SVG e não passa por ele. Todo contraste de prop medido em jogo foi medido
  através do AgX; a troca nos props é decisão do Bruno (plano de arte, §7).
  **Nos retratos de fala ele escolheu Standard a −0,35 EV** (`055`) — ⚠️ a
  0 EV a gola estourava: 54% dos pixels claros a 255. Troca de transformada
  mede-se pelo ESTOURO, não só pelo p99.
- **Peça que avança o CHÃO de um prop avança a PEGADA, e as faces não têm a
  mesma folga.** Antes de escolher em que face sai um deck, uma escada ou um
  toldo que pousa, meça a folga de cada uma em `porto_mapa_ancoras.json` — o
  armazém tem 0,236 unidades em `+my` (até o cotovelo da rua) e 0,746 em `+mx`
  (até o avental), e a plataforma de carga foi para `+x` por causa disso e não
  por gosto. A história do prop confirma ou não a régua; nunca a substitui.
- **⚠️ CORTE DE QUINA E ESTREITAMENTO FORTES, NO MESMO PRISMA, DÃO GEOMETRIA
  DEGENERADA.** O chanfro corre por cima de tudo no fim, e numa quina já
  cortada a 46px que ainda encolhe 22% em `x` ele dobra-se sobre si mesmo: os
  três bustos de 13/09 saíram com uma BARRA PRETA de ponta a ponta no topo do
  ombro. A 38 de corte e 0,86 de estreitamento desaparece — as duas coisas são
  boas sozinhas, é somá-las que sai caro, e o sintoma não se parece nada com a
  causa.
- **Duas faces no MESMO plano dão um buraco preto, e não dão erro.** Um tampo
  que acaba à altura exata do topo do corpo põe duas faces coplanares, o
  z-buffer escolhe ao acaso e o prop sai com um losango preto que se lê como
  caixa aberta. Mordeu duas vezes em 02/09 — no tampo do caixote e numa chapa
  de metal sobre o contêiner. Peça que pousa noutra afunda uma fração ou sobe
  uma fração; nunca encosta.
  **E DUAS PAREDES QUE SE CRUZAM NUMA QUINA são o mesmo caso** (05/09): se as
  duas chegam ao mesmo `x`, as duas faces exteriores ficam coplanares por toda
  a altura e sai uma BARRA PRETA de pé na quina, que se lê como uma coluna que
  não existe. Elas encaixam em L — uma leva a quina inteira, a outra começa
  onde ela acaba — e nunca se cruzam.
- **Vão recuado perto de uma quina atravessa a parede vizinha.** Irmã da
  anterior: um `vao_cego` é uma placa RECUADA, e a menos de meia largura da
  quina ela sai do outro lado. Meia largura de folga, e mais um pouco.
- **Asset GERADO não é asset EM CENA, e nada perguntava a diferença.** O
  `barco_medio` era renderizado a cada leva, entrava no manifest, passava o
  `asset_validator` e as cinco suítes — e o jogo nunca o punha numa doca:
  escolhia entre dois cascos por um booleano, e o terceiro só existia como
  enfeite na Zona de Espera. Toda a maquinaria de validação deste projeto
  pergunta se o que está na CENA existe no disco; nenhuma perguntava o
  contrário — até 16/09, quando `tools/arte_orfa.py` passou a fazê-la. Ele
  encontrou **11 de 109 arquivos** sem uma referência: a pasta `art/brp`
  INTEIRA (que o mapa em SVG substituiu), dois SVG de píer na raiz e o
  `doca_concreto`. É relatório e não portão, porque o destino de cada um é
  decisão do Bruno. Ao acrescentar um prop, acrescente também quem o mostra — e
  a asserção de que ele chega à tela.
  ⚠️ **E A CHAVE QUE ESCOLHE A ARTE SÓ ALCANÇA TANTAS PEÇAS QUANTOS VALORES
  ELA TOMA.** A `058` mandava escolher o retrato do trabalhador pelo `id`, e o
  porto tem no máximo três: 27 dos 30 retratos ficariam gerados, validados e
  sem ninguém os ver, com tudo verde. Antes de ligar arte a uma chave, conte
  os valores que ela toma numa partida; a guarda pergunta a alcançabilidade
  (o F12 percorre 400 sementes) (`059`).
  ⚠️ **E DUAS CHAVES QUE CONTAM PELO MESMO RELÓGIO CASAM.** A empresa do
  camião a `(j + voltas) % 2` e a carga do retorno a `(j + voltas) % motivos`:
  com dois motivos, o pescado saía sempre da mesma transportadora. Quem o
  apanhou pergunta no estado em que a chave está SOZINHA — a agenda de visitas
  trocava a carga de quem encostava e desfazia o par (`070`).
  ⚠️ **E «ÓRFÃO» E «APAGÁVEL» SÃO DUAS PERGUNTAS — o relatório só faz a
  primeira.** Triados em 22/09, os onze eram TRÊS grupos e não uma pilha:
  **nove tinham propósito ESCRITO** (os oito de `art/brp` e o `doca_concreto`
  servem a `scenes/tests/AssetPlacementTest.tscn`, que a ferramenta exclui de
  propósito, e o `art/brp/README.md` nomeia a condição de regresso — reabrir a
  `001`), e só DOIS não eram referidos por nada. Saíram esses dois. Quem ler o
  relatório e contar apagáveis conta a mais (`docs/decisoes/046`).
  ⚠️ **E DISCO NÃO É PACOTE: os onze mediam 687 KB em disco e 282 KB no
  `.pck`**, porque o que embarca é o `.ctex` comprimido. ⚠️ **E eles embarcam
  MESMO SEM SEREM REFERIDOS** — o preset é `export_filter="all_resources"` e o
  Godot não faz tree-shaking: o `exclude_filter` tira a CENA de teste e não
  tira a ARTE que ela usa. Antes de estimar o que apagar arte poupa, exporte o
  `.pck` das duas maneiras; e apagar um dos nove reprova o `asset_validator`
  («no manifest e não no disco»), logo a entrada do manifest sai junto ou não
  sai nenhum dos dois.
- **Peça invisível conta como peça, e é por isso que contar não chega.** A
  boia levou uma corrente que ficou DENTRO do cone do corpo: o contador dizia
  cinco, o render mostrava quatro. Contagem de peças só vale depois de olhar
  o render — o contador não sabe o que está tapado.
- **Prop da cor do chão onde pousa desaparece.** É a irmã da regra do
  `pilha_caixotes` ("faces vizinhas do mesmo tom fundem-se"), mas entre peça e
  CENÁRIO: o caixote era `madeira` num tabuado de `madeira`, e enquanto foi
  caixa lisa isso passou. Ao ganhar tampo e cinta, o corpo continuou fundido
  com o convés e só as peças novas ficaram visíveis — o caixote saiu da
  renderização parecendo um banquinho, com tampo e pernas. A suíte passou.
- **E conferir o QUADRO de um prop não é conferir o PROP.** Irmã da regra
  acima, e ela passou despercebida por duas sessões: o D7 exigia que o pé do
  mastro de um letreiro caísse dentro do quadro do prédio — que tem 512px,
  para um prédio DESENHADO de 103. Sobravam duzentos pixels de folga de cada
  lado, e a placa do armazém pairava 12px acima do telhado com o teste a dizer
  "apoiado". Toda asserção de encaixe mede-se contra `get_used_rect()`, nunca
  contra o quadro — o quadro é o mesmo em todos os props e não sabe nada sobre
  nenhum deles.
  ⚠️ **E PEÇA DE BARCO MEDE-SE CONTRA O CASCO, e não a olho.** O Bruno viu
  «partes do navio fora do casco» três vezes seguidas, e cada correção à vista
  deixava outra — a carga da proa passava da borda desde 07/09 e a amarra por
  0,075, que só a medição achou. `tools/conferir_casco.py` (com `bpy`) mede
  cada vértice contra a meia-boca da amurada (`072`).
- **⚠️ E A CAIXA DESENHADA NÃO É O DESENHO.** Irmã da regra acima, do outro
  lado: ali o quadro de 512 não sabia nada do prop, aqui o `get_used_rect()`
  sabe demasiado pouco. Ele funcionou enquanto os três cascos eram de portes
  diferentes; assim que eles passaram a partilhar o costado e a mudar só o
  CONVÉS, o porta-contêineres e o graneleiro médios deram a MESMA caixa — 97 ×
  83 no mesmo sítio — e a asserção reprovou dois desenhos bem distintos. E os
  bytes também não servem, pela regra do denoiser mais abaixo. O que responde é
  reduzir os dois a 16×16 e comparar: cada célula é a média de ~1.000 pixels, o
  que apaga o ruído de ±2/255 por construção.
  ⚠️ **E ELA CONTA A SOMBRA E O CHÃO PROJETADO.** Régua de TAMANHO lê as
  linhas com alfa acima de 0,5: com a sombra de contacto, a empilhadeira certa
  do pátio media 2,6x a pessoa; sem ela, a antiga tinha a altura do camião
  (`079`).
- **⚠️ E NUMA PEÇA COM CABOS A CAIXA MENTE QUASE DE GRAÇA.** A terceira cara
  das duas regras acima, e a mais barata de cair: um cabo, um estai ou um
  amantilho tem dois pixels de largura e ESTICA o `get_used_rect()` para o
  outro lado do prop. Logo `used_rect.has_point(p)` custa quase nada de
  satisfazer — o D17 exigia que a lança cobrisse o próprio centro de rotação e
  media a moldura, e uma lança inteira desenhada FORA do eixo continuava a
  passar, porque uma corda qualquer atravessava o ponto. Pergunte quanto
  DESENHO há à volta do ponto (a fração de pixels opacos num raio pequeno), e
  nunca se o ponto cai na caixa.
- **⚠️ CONTAR `caixa()` DESCREVE A CONSTRUÇÃO, E NÃO A LEITURA.** O kit tem 178
  chamadas a `caixa()` contra 42 a `cone()`, e daí não sai qual prop lê
  quadrado: quem responde é a SILHUETA, que nesta câmera só sabe três direções
  quando a peça é uma caixa alinhada aos eixos (±26,57° e a vertical). É o que
  `tools/medir_silhueta_props.py` mede, e a resposta contrariou o palpite —
  renderizado sozinho, o CASCO do cargueiro mediu 0,620 contra 0,563 do galpão,
  e o contêiner por cima não fazia o navio ler quadrado: **tapava** o casco
  (`docs/decisoes/024`).
- **⚠️ E O CHANFRO QUE O KIT INTEIRO APLICA É INVISÍVEL POR CONSTRUÇÃO.**
  Varrido: um filete só entra na imagem a partir de **3 px** de raio e só LÊ a
  partir de **6**. O `chanfrar()` usa 0,020 unidades, e uma unidade vale 20 px
  de tela — **0,4 px**. Curva que se decide num prop mede-se em 0,15 e 0,30 de
  mundo, nunca em 0,02. E daí sai um portão de TAMANHO: a 40 px de largura um
  filete de 6 px já leva a caixa para baixo da linha do cilindro — deixou de
  ser quina arredondada e passou a ser outra forma.
- **⚠️ REFERÊNCIA DE FORMA TEM DE TER A CAIXA ENVOLVENTE DA PEÇA, senão mede o
  TAMANHO e a ESBELTEZ.** Um contorno fechado dá 360° de curva no total, então
  o preço das quinas é fixo em pixels e pesa tanto mais quanto menor for a
  peça. Duas consequências medidas: **abaixo de ~24 px de diagonal a caixa
  ideal e a forma redonda medem o mesmo** (a pergunta não tem resposta, e a
  ferramenta recusa-se a dar número em vez de dar um plausível); e **numa peça
  ESBELTA a caixa e o cilindro medem quase o mesmo** — 0,640 contra 0,635 a
  10×35. Peça comprida não se conserta arredondando a secção: a estaca do píer
  media 1,065, o valor mais alto do kit, e uma estaca cilíndrica tem os mesmos
  dois lados verticais. O ganho não paga, e registou-se em vez de se arredondar.
- **⚠️ E ÍNDICE NORMALIZADO SÓ VALE ENQUANTO A PEÇA ENCHE A CAIXA QUE O
  NORMALIZA.** A regra acima diz que a referência tem de ter a caixa envolvente
  da peça; esta diz quando isso deixa de bastar. Ao arquear o tronco do
  coqueiro, o índice desabou de 0,491 para −0,47 aos 15° e **voltou a subir**
  aos 30 e aos 45 — não monótono, e nada disso é a peça a ficar redonda: um
  tronco curvo deixa de ENCHER a caixa dele (a largura vai de 16 para 29 px sem
  o desenho engordar), e comparar uma fita curva com a caixa e a elipse CHEIAS
  daquele retângulo mede o vazio à volta. E o mesmo prop já media 0,491 contra
  0,741 do CILINDRO ideal — ou seja, nunca leu quadrado, e o número que o item
  herdou dizia o contrário (`docs/decisoes/028`).
- **⚠️ E RÉGUA DE FORMA TEM RUÍDO PRÓPRIO, que não é zero.** A irmã da regra do
  validador injetado, para números em vez de verdes: ali o mesmo arquivo dos
  dois lados tem de dar zero EXATO; aqui a peça CERTA dá 1,73 px de flecha, que
  é a largura de 16 px, as seis faces e o antisserrilhado. Sem medir esse piso,
  os 2,53 px de uma curva de 15° passariam por curva. **Meça o piso antes de os
  números valerem.**
- **⚠️ ESCALAR UM CONTORNO CURVO ACHATA A CURVA DELE.** O fundo do casco era a
  amurada escalada por `(0,88, 0,42)`: a curva chegava lá 58% menor e o que
  sobrava desviava-se menos de 1 px ao longo de 60 px — a régua lia uma reta, e
  era ela que continuava a fazer o casco medir quadrado depois de o convés já
  curvar. Anel de baixo de um prisma leva contorno PRÓPRIO, não um fator.
- **⚠️ E CURVAR UMA LINHA SEM CURVAR O QUE ASSENTAVA NELA DEIXA-O ATRAVESSADO.**
  Enquanto o bordo do casco era reto, o guarda-corpo reto coincidia com ele por
  acidente; com o bordo curvo ficou a cortar o convés em diagonal, com as
  pontas a morrer no meio da chapa. É "ao corrigir um, VARRA OS IRMÃOS" com a
  geometria no lugar do prop: quem muda uma linha muda tudo o que a seguia.
- **⚠️ E MUDAR A FORMA DE UM PROP NÃO PODE MUDAR A CAIXA ENVOLVENTE DELE.** Os
  extremos do casco — proa, popa e boca máxima — ficaram no mesmo pixel de
  propósito: o barco cai em `Dock.tscn` num `offset` fixo, e um casco meio
  pixel mais gordo mexeria nele sem dar erro nenhum.
- **PARTILHA TOTAL OU NENHUMA, numa tabela de arte.** O pesqueiro usa o mesmo
  casco nos dois motivos dele de propósito — pescado e armazenagem são o mesmo
  peixe indo para sítios diferentes, e o barco não muda com o destino da carga.
  Um cargueiro que apontasse dois serviços para o mesmo PNG seria copiar-colar,
  e numa tabela as duas coisas leem-se IGUAL. Exigir 1 ou N separa-as: partilhar
  é uma afirmação sobre a classe inteira, nunca sobre um par de chaves.
- **⚠️ CONTRASTE GASTO ENTRE DUAS PEÇAS DO PROP PODE DEIXAR O PROP INVISÍVEL.**
  As regras acima dizem que a paleta mente e que o contraste é contra o FUNDO;
  esta diz de que maneira se esquece isso. Ao desenhar o pau de carga do n1
  escolheu-se `tronco` para o pau SEPARAR DO MASTRO — 0,45 de Weber entre os
  dois, de sobra — e mediu-se aí. No jogo o pau passa por cima da AREIA e deu
  0,21: some. **Duas peças que se separam bem uma da outra podem estar as duas
  na banda do fundo.** A conta que decide a cor é sempre peça contra fundo; a
  separação entre peças é a segunda pergunta, nunca a primeira.
- **⚠️ E UM PROP SÓ ATRAVESSA DOIS FUNDOS: nenhum tom ganha os dois.** No mesmo
  prop, o gancho pende sobre o BAIXIO (claro, ~106) e o pau corre sobre a AREIA
  (~159), com água funda (~67) à volta. `metal_claro` mede 0,75 sobre a água
  funda e **0,01** sobre o baixio. Quando um tom não vence os dois fundos, quem
  resolve não é a cor — é a MASSA: o gancho voltou ao metal escuro e passou a
  ser encontrado por ser a única ferragem grande, depois de os olhais dos
  estais encolherem de 0,11 para 0,075.
- **"Está em cima da estrada" pode ser problema de ESCALA, não de posição.**
  Em 03/09 o pátio foi alargado, o teste passou a provar que a pegada dos dois
  prédios não toca o asfalto — e o jogador continuou a ver o escritório em
  cima da rua. Estava certo: a base era legal, mas os prédios levantavam-se
  ~4× a altura de uma casa da vila, e em isométrico é a ALTURA que projeta a
  silhueta para cima e para trás, por cima do que está atrás. Antes de mover
  um prop que "invade" algo, meça a altura dele contra os vizinhos.
- **Limite de GOSTO disfarçado de limite geométrico reprova o que está certo.**
  O validador do Blender recusou o retrato do trabalhador dizendo que ele "vai
  sair cortado do quadro de 512px" — e o render tinha 18px de folga em cima e
  16 em baixo. O número (8 unidades) era uma regra de gosto para prop do mapa,
  com a mensagem de uma regra geométrica; a geometria nunca chegou a ser
  medida. Hoje são duas perguntas separadas, e a geométrica projeta mesmo os
  cantos. **Validador que reprova o que está certo gasta-se depressa** — na
  vez seguinte alguém sobe o limite em vez de olhar.
- **⚠️ DUAS METADES DE UM PROP ENCAIXAM — NÃO SE SOBREPÕEM.** É a "validador
  que reprova o que está certo" com a métrica no lugar do limite. A guarda nova
  do D30 pedia que a peça de cima COBRISSE o topo da de baixo (a fração de
  desenho numa janela, a régua do D17), e o `poste_luz` deu 0,11: a luminária
  não cobre a ponta do braço, **ela continua a partir dela**. O que vale para as
  duas metades é onde está a MASSA da de cima — em cima da ponta da de baixo, e
  não a meio dela nem ao lado. E quem achou o par que denunciou isso foi a
  DERIVAÇÃO (nós do cenário que partilham a posição): uma lista escrita à mão
  teria guardado só o coqueiro, e a métrica errada teria passado.
- **E caixa alinhada aos eixos de um GRUPO tem quinas que não existem.** Ao
  medir a projeção peça a peça a resposta bateu com o render; medindo pela
  caixa do grupo, ela juntava o `x` de um braço com o `y` de uma bota e o `z`
  do capacete e errava por 17px. Caixa de grupo serve para saber se algo cabe
  num sítio; não serve para dizer o que a câmera vê.
  ⚠️ **E A CAIXA DE UMA PEÇA SÓ também tem, se ela for redonda.** O validador
  do Blender passou a medir peça a peça e ficou nos oito cantos da caixa de
  cada uma: em 24/09 o coque da Dona Cida «saía do quadro» a −1 px com o cabelo
  a começar a 15 no PNG. Hoje projeta os vértices da malha avaliada (`055`).
- **⚠️ NUM ROSTO PEQUENO, A POSE VALE MAIS DO QUE A CARA.** Os nove retratos
  de 13/09 tinham três bocas, três sobrancelhas e três olhos diferentes — e a
  queixa foi que eram pouco expressivos, com razão: numa cara de 56px o que
  muda entre duas expressões são seis pixels de boca e quatro de sobrancelha,
  enquanto INCLINAR A CABEÇA muda a silhueta inteira, que é o que o olho lê
  primeiro. Cabeça de lado lê como interesse antes de se chegar à boca; queixo
  em baixo lê como peso. A pose roda sobre um pivô no MEIO do pescoço (sobre a
  base do crânio abre-se uma fresta), em ângulos pequenos, e vem ANTES do giro
  para a câmera — somar 45° ao Z é pré-multiplicar por Rz, porque o Z é o fator
  de fora da Euler XYZ.
- **⚠️ E PEÇA PEQUENA ENCOSTADA A PEÇA GRANDE DESAPARECE SEM ERRO NENHUM.** O
  lápis atrás da orelha levou duas tentativas: no `x` da orelha ficou DENTRO
  dela, e mais para dentro ficou dentro da cúpula do cabelo, que é um cone de
  raio 76. A régua para pôr um acessório é o raio da peça VIZINHA e não a
  largura da cabeça — e quem conta peças conta cinco na mesma, que é a regra da
  boia com a corrente dentro do cone, à escala de uma cara.
- **⚠️ E O QUE A PEÇA TEM DE MOSTRAR DECIDE O ENQUADRAMENTO DELA.** Irmã da
  regra abaixo, um passo antes: ali o tamanho do widget decide a escala, aqui a
  FUNÇÃO decide o corte. O `trabalhador_retrato` identifica uma unidade, e o
  que identifica é o capacete e o colete — silhueta, que sobrevive a qualquer
  tamanho: foi de corpo inteiro até 24/09, e em busto (escolha do Bruno) o
  quadro abriu para a cabeça valer 56% e o colete caber (`058`). Os três
  retratos de fala de 13/09 são BUSTOS porque carregam EXPRESSÃO, e expressão
  vive em meia dúzia de pixels de cara: medido, de corpo inteiro a cara tem
  16px e o olho 2 no cartão de 96px, e as nove imagens seriam a mesma imagem.
  Cortado no peito, com a cabeça a valer 61% da altura, a cara fica com 44px e
  o olho com 5. **Antes de
  desenhar arte de interface, pergunte que informação ela tem de entregar e a
  que tamanho** — a resposta muda o desenho, não só a escala.
- **Peça de INTERFACE mede-se no tamanho do widget, não no do quadro.** Um prop
  do mapa fica pequeno no PNG de 512 e é o Godot que o põe no sítio; um retrato
  num `TextureRect` com `KEEP_ASPECT_CENTERED` escala o PNG INTEIRO, a
  transparência incluída — 251px de boneco num quadro de 512 saem com 34px num
  cartão de 70. Ele passava em todas as asserções. Arte para interface enche o
  quadro; arte para o mapa, não.
- **E letreiro é interface: desenha-se por cima do mapa, e o teste de design
  não sabe onde ele cai.** O caminhão nasceu num ponto que passava em todas as
  asserções e saía na captura com metade dele debaixo do letreiro do
  ESCRITÓRIO. Prop que se põe para ser VISTO confere-se na foto, não na régua.
  ⚠️ **E OS LETREIROS JÁ NÃO EXISTEM** — foram removidos a pedido, com o
  `Letreiro.gd` e a variação de tema (ver `BR_Port_Plano_Arte_Blender.md`). A
  lição fica porque não era sobre placas: antes de morrerem eles carregavam
  offsets cravados que punham uma placa mais larga do que o prédio que nomeia e
  outra a pairar 12px acima do telhado, com o teste a dizer "apoiado". É o que
  este arquivo repete sobre altura e sobre cor — **número em pixel escrito à
  mão envelhece calado quando o que ele descreve muda de tamanho**.
- **Encolher um prop escala-se no GRUPO, nunca reescrevendo as literais.**
  Porta contra parede, janela contra porta, beiral contra telhado: são trinta
  números e trinta chances de um ficar por escalar. E cada objeto UMA vez —
  `galpao` e `galpao_velho` partilham as paredes de propósito, então escalar
  grupo a grupo passaria duas vezes nas peças comuns e elas sairiam a `k²`,
  sem erro nenhum a apontá-lo.
- **⚠️ "A PEÇA É PARTILHADA POR RESTRIÇÃO" merece ser medida antes de aceite.**
  A torre do guindaste era a mesma nos três níveis, e o comentário dizia que o
  `pivot_offset` único da lança obrigava a isso. Obriga UM PONTO — o topo —,
  não a coluna inteira; e como a torre é a coluna que ocupa a silhueta e a
  lança é o braço fino lá em cima, o porto inicial e o completo liam como o
  mesmo guindaste. Quando um comentário justifica uma partilha, pergunte de que
  TAMANHO é a amarra: quase sempre é menor do que a peça que ela está a
  segurar.
- **⚠️ ÂNGULO DE PEÇA INCLINADA MEDE-SE NA IMAGEM, NUNCA NO MUNDO.** É a irmã
  da regra do chanfro a 45°, aplicada a uma peça em vez de a uma faixa: a
  câmera comprime a direção (1,1) e estica a (1,−1), então graus de mundo não
  são graus de tela. O pau-de-carga do arrasteiro desce 26° no Blender e saiu
  HORIZONTAL no render — no mesmo ângulo de tela da travessa do pórtico e do
  tambor, e as três peças cinzentas fundiram-se num andaime só. A 42° ele
  desce. Escolha o número olhando o PNG, e escreva no comentário que foi
  medido lá.
- **⚠️ E UM PROP DESTA ESCALA TEM LUGAR PARA UMA SILHUETA MEMORÁVEL, NÃO PARA
  CINCO.** O arrasteiro nasceu com pórtico de popa, dois tangones, tambor,
  mastro e pau — cinco peças de metal a 82px, e o que se lia era um borrão de
  andaime com o mastro perdido lá dentro. Cortar quatro fez a quinta aparecer.
  O mesmo vale para a COR DE ACENTO: ela só acentua enquanto for UMA. Com o
  pórtico e o pau ambos laranja o laranja deixou de apontar para coisa nenhuma;
  o pau voltou ao cinzento e o arco passou a ser o barco.
- **Rodar um prop 90° manda metade dos detalhes para a face que a câmera não
  vê.** Só `+x` e `-y` são visíveis. Rodar o caminhão para o eixo da estrada
  punha o para-brisa a olhar certo e a janela lateral para `-x` — invisível, e
  ninguém notaria no render, só na silhueta chapada. Prop que muda de eixo
  RECONSTRÓI-SE com os detalhes repostos nas faces visíveis.
- A prova visual do prop — o que a captura não vê, o sorteio, o estado
  que nenhuma foto monta, a folha de contato — está em `captura.md`.
- **⚠️ CAMPO PREENCHIDO A 100% PODE ESTAR PREENCHIDO PARA OUTRA PERGUNTA.** O
  manifest tem `habitat` nas 44 entradas, e em 14/09 propus agrupar a folha de
  contato por ele. Medido antes de codar: dos 51 props de MAPA só 26 estão no
  manifest, e **20 desses 26 são `terra`** — os outros seis são habitats de uma
  peça cada (`vila`, `ar`, `areia`...). O campo foi desenhado para a FAUNA, onde
  cada bicho tem o seu. Cobertura não é distribuição: antes de agrupar por um
  campo, conte quantos valores DISTINTOS ele tem no conjunto que interessa — um
  campo quase constante não agrupa, e o resto sairia de uma lista à mão.
- **Escala de ruído é relativa ao tamanho da peça.** Numa longarina de 0,045
  o número 14 dá uma marca; numa parede de 3 unidades dá setenta, e a parede
  vira lixa.
  ⚠️ **E A COORDENADA `Object` LÊ A MALHA ANTES DO `scale`.** A `caixa()` e a
  `bola()` do kit nascem com tamanho 1 e esticam-se pelo `scale`: um padrão
  numa esfera esticada a 0,16 sai seis vezes mais fino do que o pedido, e o
  saco do arrasteiro saiu granulado sem um erro (`071`). Padrão medido em
  unidades de mundo pede a escala aplicada na malha (`transform_apply`).
- **Padrão dirigido não entra na PALETA, entra peça a peça.** É a regra acima
  aplicada a padrão em vez de a ruído: `madeira` veste o tabuado de 4,5×2,4 e
  também o caixote de 25px, então ripar a entrada da paleta poria oito tábuas
  dentro de um caixote. Pela mesma conta o pesqueiro (67px) não enferruja e os
  cargueiros (97px) enferrujam.
- **A MELHORIA não pode ser mais lisa do que aquilo que ela substitui.** O
  convés do píer n2 era uma chapa de `madeira` — a maior superfície do jogo,
  138px, três vezes na tela — e o n1, que é o pontão provisório, gasta
  geometria em nove ripas com fresta. O jogador comprava o upgrade e o convés
  ficava LISO. Ao construir dois estados de uma peça, confira que o melhor tem
  mais desenho, não menos.
- **Sombra entre peças precisa de PATAMAR, não de rampa.** Uma rampa linear de
  dois pontos só chega ao escuro total no último pixel: num tabuado de passo
  6px o que se via no jogo eram bandas de tom, não tábuas. Três pontos — escuro,
  escuro, claro — dão à sombra metade da largura dela em valor cheio. Vale para
  toda junta, fiada ou vinco desenhado por material.
- **⚠️ `Pointiness` NÃO SEPARA QUINA DE PANO NUMA CAIXA, e não dá erro.** Ele é
  atributo de VÉRTICE, e uma caixa chanfrada não tem vértice nenhum no meio da
  face — o valor no pano é interpolado dos cantos, e não existe campo plano
  contra o qual comparar. Medido no galpão em ruína: varia de 29 a 181 com
  mediana 146 e 31% da parede acima de mediana+10, quando o efeito precisa de
  uma distribuição bimodal. Aplicado, pintou a parede inteira. Efeito que
  depende de aresta, neste kit, sai de uma COORDENADA (distância à aresta da
  caixa), nunca da curvatura da malha.
- **⚠️ CONTORNO DE TRAÇO ESTÁ FECHADO: as DUAS técnicas foram testadas e
  rejeitadas.** O Freestyle fecha o vazado da treliça e engorda peça pequena
  (30/08). O contorno pelo compositor — a saída que o plano propunha — foi
  construído e medido em 05/09, e falha por outra razão, mais funda: **este
  estilo desenha o detalhe COM fronteiras de valor** (o corrugado, as fiadas,
  as cantoneiras, porque a esta escala relevo não sobrevive ao
  antisserrilhado), e um filtro de borda procura exatamente fronteiras de
  valor — ele acha o desenho e desenha-o outra vez. Medido: a parede do galpão
  PERDE 14% de desvio local, e a treliça perde 21% de saturação com o traço
  rente à silhueta. **Quem faz o trabalho do contorno é o contraluz do rig de
  três pontos**, que separa a silhueta sem tocar no que está dentro do prop. A
  prova refaz-se com `gerar_props_iso.py --contorno`; não a ligue.
- **E na peça FINA o contorno apaga a COR, não a forma.** Vale para qualquer
  efeito de borda que venha a seguir: a silhueta da lança não mudou UM pixel
  (1133 opacos com e sem, vazados abertos) e ela saiu de laranja a castanho.
  Contar pixel de silhueta não mede o dano; medir saturação mede.
- **Prop NÃO é artefato byte-reprodutível, e o resto dos gerados é.** Os dois
  mapas, os sons e a tabela dos números têm de sair idênticos, e o CI compara.
  Um PNG de prop não: o denoiser do Cycles varia ±2/255 em algumas dezenas de
  pixels entre corridas, e os props que não estão em `SOMBRA` ainda levam um
  carimbo de data do Blender no PNG (os de `SOMBRA` escapam porque o
  `compor_sombra` os reescreve com o gravador do projeto). `cmp` num prop não
  responde "a imagem mudou" — para isso, compare os PIXELS.
  ⚠️ **E A MALHA TAMBÉM NÃO É ESTÁVEL NA ORDEM.** A `primitive_uv_sphere_add`
  devolve as faces noutra ordem a cada chamada, e o chanfro avaliado mexe 1
  ULP nas UVs e 1e-9 nas coordenadas. Quem compara duas cenas compara a malha
  ORIGINAL e cego à ordem das faces — como o `--despejar` (`080`).
- **E quem responde "este prop mudou?" é `tools/comparar_props.py`**, que reduz
  os dois a 16×16 — a mesma régua do bloco dos cascos distintos. Calibrado: duas
  corridas do mesmo código dão 0,000 e os PNGs diferem nos bytes (carimbo de
  data), um pixel de deslocamento dá 0,022, e um prop trocado por outro dá 0,42.
  ⚠️ **E A RÉGUA IRMÃ, NO TESTE DE DESIGN, NÃO FAZIA A MESMA CONTA** — com o
  mesmo comentário. O `comparar_props.py` faz a média (`reshape().mean`); a
  `_assinatura()` do D13/D17 fazia `Image.resize(16, 16, INTERPOLATE_BILINEAR)`,
  que numa redução de 48x **não faz média**, e o `TRILINEAR` mediu igual. Ela
  deu 0,0039 a dois camiões com 1.106 pixels diferentes (0,062 pela média).
  **Duas réguas com a mesma promessa conferem-se uma contra a outra no mesmo
  par** — e redução que tem de ser média escreve-se como média (`047`).
  ⚠️ **E «0 PIXELS ENTRE DUAS CORRIDAS» ACONTECE, MAS NÃO SE GARANTE — nem na
  mesma máquina.** Medido em 24/09: o mesmo código deu duas Donas Cidas
  estáveis a 787 pixels uma da outra (Δ máx 45, num pixel), e uma delas bate a
  0 com a PNG de OUTRA sessão. O palpite «ruído entre máquinas» foi para um
  commit e estava errado. Quem prova «não mudou» é o `comparar_props.py`
  (0,0000 nos dois casos), e uma diferença de render não se explica antes de a
  medir contra uma segunda corrida do mesmo código (`056`).
- A sombra de contato tem **azimute próprio (250°)**, diferente do azimute do
  mapa: no azimute do mapa ela cai atrás do prop e não se vê.
