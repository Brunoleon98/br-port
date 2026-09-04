# Referências visuais — o alvo de arte do BR Port

Esta pasta guarda as imagens que definem **para onde a arte do jogo vai**.
Elas não são especificação de produção: são concept art. A diferença importa e
está registrada em `docs/design/BR_Port_Plano_Arte_Blender.md`.

---

## ⚠️ Os arquivos ainda não estão aqui

As cinco imagens chegaram por anexo numa conversa. **Anexo de chat não vira
arquivo no disco do contêiner** — o assistente vê a imagem, mas não tem um
caminho para copiar. Elas precisam entrar pelo Git, e o lugar é esta pasta.

Para pôr as imagens no projeto, arraste os arquivos para cá com estes nomes e
faça commit:

| Arquivo | O que a imagem mostra |
|---|---|
| `alvo_01_fase1_uma_doca.png` | Dia 18, 1 doca. Vila pequena, escritório, guindaste único, pesqueiro + cargueiro |
| `alvo_02_fase1_duas_docas.png` | Dia 19, 2 docas. Cidade com comércio (PADARIA, MERCADO), empilhadeiras, mais carga |
| `alvo_03_fase2_tres_docas.png` | Dia 18, 3 docas. Pórtico "PORTO MIRIM · BEM-VINDO!", pátio de contêineres, iate |
| `alvo_04_fase3_quatro_docas.png` | Dia 48, 4 docas. Silos, pórticos de contêiner azuis, ARMAZÉM ESPECIAL, navio de cruzeiro |
| `alvo_05_fase4_cinco_docas.png` | Dia 105, 5 docas. ADMINISTRAÇÃO com heliponto, ESTALEIRO com dique seco, OFICINAS, vagões |

Enquanto elas não chegam, a leitura abaixo é o que o projeto tem — e ela foi
escrita olhando as cinco, não de memória de estilo.

---

## O que as cinco imagens dizem juntas

**Elas são um ARCO DE CRESCIMENTO, não cinco variações.** Vila → cidade →
porto industrial → complexo portuário. É exatamente a progressão por Fase que
o GDD descreve, e valida a decisão de `--nivel-vila=N` no gerador do mapa —
só que num alcance muito maior do que o implementado.

O que cresce, na ordem em que cresce:

1. **Docas**, de 1 a 5, e o rótulo de tamanho junto (`2x1 CÉLULAS` → `3x2`).
2. **A cidade atrás**, de casa térrea a sobrado com comércio a prédio.
3. **A densidade do pátio**: carga solta → contêineres empilhados → pátio
   organizado em fileiras com empilhadeiras e caminhões circulando.
4. **O tipo de navio**: pesqueiro → cargueiro → porta-contêineres → cruzeiro.
5. **Os equipamentos**: guindaste de lança → pórtico → pórtico de contêiner
   sobre trilhos.
6. **Os prédios de apoio**, que só aparecem tarde: oficina, estaleiro,
   administração com heliponto, silos.

---

## Leitura de COMPOSIÇÃO — escrita em 03/09, e é a que faltava

As seções abaixo cobriam paleta, estilo e personagem. **Composição não estava
coberta**, e era exatamente ela que travava as duas metades por fazer da
Etapa 1 do plano de arte: onde cabe a areia, e qual o enquadramento. Ficam
respondidas aqui.

### O enquadramento: `MEIA_LARG = 20`

**Escolha do Bruno em 03/09**, feita olhando o mapa gerado em 30 (o de hoje),
24 e 20 lado a lado, com o mesmo ponto do mundo no centro das três.

E ela vem com um custo que foi MEDIDO antes de a etapa abrir (a tabela está no
`BR_Port_Plano_Arte_Blender.md`): **em 20 o mundo acaba dentro do quadro.** A
terra visível satura em ~24% da tela e para de crescer, enquanto o azul vazio
quase dobra — há uma cunha de 100 px no canto superior esquerdo onde a terra
termina numa diagonal reta contra água funda. Os `DEGRAUS` acabam em `my = 34`
e o `FUNDO_TERRA` está em `mx = -8`: afastar a câmera não descobre mais mapa,
descobre a borda dele.

**Logo, a ordem do trabalho é: estender o mundo primeiro, mexer na projeção
depois.** E as referências dizem para onde estendê-lo — elas enchem o quadro
inteiro nesta escala, sem uma única borda à vista.

### Onde vai a AREIA — e não é onde se supôs

A pergunta em aberto era: *a costa deste mapa é cais de pedra de ponta a
ponta; onde é que uma praia cabe?* A resposta das cinco imagens é clara e
nenhuma delas põe areia entre a água e o cais:

> **A areia fica onde o PORTO NÃO ESTÁ** — nas duas pontas da costa, para
> além do primeiro e do último berço, emoldurando o porto.

Nas cinco, o cais é pedra ou concreto descendo direto à água; a praia aparece
como uma faixa clara com pedras e coqueiros **no canto de cima**, acima da
doca mais ao norte, e **no canto de baixo**, onde a costa se curva e sai do
quadro. Em duas delas há mangue e vegetação de água na margem oposta, do outro
lado do canal.

Isso torna a areia um item BARATO e não uma reforma da costa: são dois
remates nas pontas do que já existe, e não uma faixa ao longo de todo o cais.
Ela também resolve metade do problema de cima — as pontas da costa são
justamente onde hoje o mundo acaba em diagonal reta.

### O resto da composição

- **A água ocupa perto de metade do quadro**, e a maior parte dela é água
  aberta sem nada: a Zona de Espera (retângulo tracejado, que este projeto já
  tem) flutua nela com dois ou três rebocadores e uma boia. Vazio de propósito
  — é o que dá escala ao porto.
- **A cidade é uma FAIXA atrás do cais**, paralela a ele, nunca um bloco. Ela
  engorda para trás com as Fases (térrea → sobrado com comércio → prédio), e é
  o que este projeto já faz com `--nivel-vila=N`.
  ✅ **E ela passou a ser faixa em 04/09, com duas fileiras.** Era uma fileira
  só — o gerador dizia em comentário que a segunda "cairia fora da esquerda do
  ecrã", e medido isso é falso: a segunda fileira tem 11,7 unidades no quadro
  contra 17,3 da primeira. Uma faixa de uma casa de espessura não é faixa, é
  cerca. Régua nova e medida: **a travessa entre fileiras tem de valer mais de
  um telhado** (~78 px aqui) ou as duas leem como um borrão de telha.
- **Entre a cidade e o cais há sempre uma avenida**, com faixa amarela e
  passeio dos dois lados. O projeto já tem a rua; a referência mostra que ela
  é mais LARGA do que a nossa e carrega trânsito.
  **Em 03/09 a avenida recuou** — não por composição, mas porque o pátio entre
  ela e a água tinha 1,68 unidades e o armazém ocupa 3,76, então os dois
  prédios do porto estavam em cima do asfalto. `RUA_RECUO` foi de 4,3 para 6,8
  e a vila recuou junto. O efeito de composição veio de lambuja e é o que a
  referência pedia: a faixa da cidade, a avenida e o pátio do porto passaram a
  ler-se como três bandas, em vez de se atropelarem.
- **As docas encostam umas nas outras ao longo da diagonal.** Não há água
  entre berços vizinhos como há no nosso mapa — o cais é contínuo e os
  píeres saem dele.
- **Rótulo de doca sobre água vazia**, com uma pílula escura por baixo dizendo
  o tamanho em células. Nunca sobre o barco.

⚠️ **E o aviso do fim desta página vale aqui mais do que em qualquer outro
lado:** as cinco mostram um jogo com contratos, missões, pesquisa, loja,
estaleiro e cruzeiros. O Vertical Slice tem 3 docas e cinco estruturas.
Compor o mapa para caber o porto da imagem do Dia 105 é desenhar cenário para
um jogo que não existe.

---

## Leitura de estilo

### Cenário

- **Projeção isométrica** com a mesma leitura 2:1 que o projeto já usa. A
  câmera é mais **AFASTADA** que a nossa: vê-se um distrito inteiro, não três
  berços. Isto é uma decisão de enquadramento tão importante quanto qualquer
  outra — ver §4 do plano.
- **Contorno escuro suave** na silhueta de cada volume. O projeto testou
  Freestyle e rejeitou (fechava o vazado da treliça); a referência mostra que
  a ideia estava certa e a implementação é que não servia.
- **Oclusão de ambiente em toda fresta** — sob beirais, entre contêineres,
  na junta do píer com a água. É o que dá o ar "assentado".
- **Luz quente de sol baixo** com sombra longa e azulada, e um fio de luz
  quente na quina superior de cada volume.
- **Densidade**: em qualquer recorte de 200×200px há 6 a 12 objetos. No nosso
  mapa há 1 a 3. É a diferença mais visível de todas.
  ✅ **Atacada em 04/09, e a causa não era a contagem.** Os objetos legíveis na
  faixa de terra passaram de 15 para 55, e o que os multiplicou foi descobrir
  que **95% da mata era desenhada fora do ecrã**: o viés da densidade apontava
  para `FUNDO_TERRA`, que é, pelo nome, a parte do mundo que ninguém vê. Antes
  de gerar mais, veja onde o que já se gera está a cair.

### Paleta (amostrada das imagens)

| Elemento | Referência | O projeto hoje |
|---|---|---|
| Água rasa | turquesa `#3fb6cf`–`#57c6dc` | `#4a96b4` — mais cinza |
| Água funda | `#1b7fa8` | `#1d4f68` — bem mais escuro |
| Areia | `#e8d9a8` | não existe faixa de areia |
| Telha | `#c2502e` a `#e07a3c` | `#c85420` — está certo |
| Parede | creme `#f2e6cf`, e cada casa de uma cor | `#eef2f5` — frio e uniforme |
| Vegetação | `#3e8f3a` com `#6fbf4e` no realce | `#2d7a3a` — sem realce |
| ↳ *copa de árvore* | *idem* | ✅ **em uso desde 04/09** — `copa` e `copa_luz` |
| Asfalto | `#6b6f76` com faixa amarela viva | `#6f7b85` — está certo |

**O ajuste mais barato e mais visível é a água e a areia.** A referência é
tropical e quente; o nosso mapa é de mar frio. São constantes no dicionário
`C` de `tools/gerar_mapa_iso.py`.

> ✅ **A ÁGUA, A PAREDE, A VEGETAÇÃO E AS CASAS foram trocadas em 02/09**
> (Etapa 1 do plano de arte). A tabela acima continua a ser o alvo; a coluna
> "o projeto hoje" descreve o mapa ANTES dessa passagem.
>
> Uma ressalva que a tabela não podia prever: os dois valores de água,
> aplicados literalmente nas duas pontas da rampa de profundidade, **achatam o
> mar** — a referência enquadra a água rasa junto ao cais, e o nosso mapa tem
> muito mais água funda do que ela mostra. A amostragem vale onde ela foi
> feita, e a rampa foi estendida para baixo no mesmo matiz. O plano de arte
> traz os números.
>
> ✅ **A AREIA deixou de estar bloqueada em 03/09** — a leitura de composição
> no topo desta página diz onde ela vai: nas duas pontas da costa, para além
> do primeiro e do último berço, e não entre a água e o cais. Falta fazê-la.

### Personagens

Trabalhadores em proporção **chibi** (≈3 cabeças), com **rosto desenhado**,
colete laranja, capacete, e braços separados do corpo. O nosso é um empilhado
de cinco caixas sem rosto. Rosto a esta escala é textura, não geometria — ver
o plano.

### Interface

A UI da referência é **muito mais encorpada** que a nossa, e nada disso é
Blender — é tema do Godot e ícone:

- Painéis com **gradiente vertical** sutil, borda clara de 2px, e **sombra
  projetada** por baixo.
- **Trilho esquerdo** de botões-pílula com ícone colorido e **contador
  vermelho** no canto.
- **Barra inferior** de 6 botões, cada um com **cor própria** (laranja, azul,
  laranja, verde, âmbar, roxo), gradiente e rótulo em caixa alta.
- **HUD superior** com pílulas de recurso, cada uma com ícone próprio, e o
  relógio/dia à direita.
- Rótulos de doca em **branco com contorno grosso**, com uma pílula escura
  por baixo dizendo o tamanho — curiosamente, é o que este projeto acabou de
  tirar do mapa. A diferença: lá o rótulo tem uma pílula de dado por baixo e
  fica sobre água vazia; aqui ficava sobre o barco.

> ✅ **A Etapa 6 usou desta lista o que se aplica** (02/09): sombra deslocada e
> borda de 2px nos cartões claros, e cor própria no botão que move o jogo.
>
> **O trilho esquerdo e a barra de seis botões NÃO foram feitos, e não por
> falta de tempo:** esta interface tem dois botões de ação, e a referência
> descreve um jogo com mais sistemas. Copiá-los seria desenhar interface para
> funcionalidade que não existe — o erro que esta pasta avisa duas linhas abaixo.
> O gradiente também não: `StyleBoxFlat` não faz gradiente, e o plano de arte
> explica o que custaria.

---

## Como usar esta pasta

Referência serve para **decidir**, não para copiar. Antes de encomendar ou
gerar qualquer arte nova, a pergunta é: *qual das seis linhas de crescimento
acima esta peça serve, e em que Fase?* Peça que não responde a isso é peça
que vai ficar sem uso — já aconteceu duas vezes neste projeto
(`docs/arquivo/BLOCO4_PACOTE_SPRITES.md`).
