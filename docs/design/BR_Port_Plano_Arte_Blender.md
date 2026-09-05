# Bloco 7 — Plano para levar a arte ao nível da referência

> Escrito em 30/08/2026, depois de olhar as cinco imagens de referência
> (`docs/design/referencias/`) e de rodar o Blender e o Godot dentro da sessão
> para medir, em vez de estimar.
>
> **A pergunta que este documento responde:** o que falta para o jogo parecer
> aquilo, quanto disso o Blender por script alcança, e o que é preciso
> aprender ou registrar para lá chegar.

---

## 1. A primeira coisa a dizer: o que a referência é

As cinco imagens são **concept art**, quase certamente saídas de um gerador de
imagem. Isso não as desqualifica — pelo contrário, elas fazem muito bem o
trabalho de concept art, que é **fechar uma direção**. Mas muda o que se pode
esperar delas:

- **O que elas decidem, e vale seguir:** o arco de crescimento (vila → cidade
  → porto industrial), a paleta tropical quente, a densidade de objeto, o
  enquadramento afastado, o peso da interface.
- **O que elas NÃO são:** um alvo de produção reproduzível peça a peça. Uma
  imagem gerada não tem folha de sprite por trás, não tem estados (ruína ×
  consertado), não registra em cima do mapa, e não repete o mesmo prédio duas
  vezes igual. É por isso que este projeto já perdeu **duas levas de sprite**
  (`docs/arquivo/BLOCO4_PACOTE_SPRITES.md`) e acabou gerando por script.

O alvo realista, portanto, não é "reproduzir a imagem". É: **chegar ao ponto
em que alguém que viu a referência reconhece o jogo como sendo aquilo**. A
§3 diz o quanto disso é alcançável e por onde.

---

## 2. A distância, medida

Foi medida com o Blender e o Godot rodando, não no olho.

| Frente | Referência | Jogo hoje | Quem resolve |
|---|---|---|---|
| **Objetos por recorte de 200×200px** | 6–12 | 1–3 | Blender + gerador de mapa |
| **Peças por prop** | dezenas, com ferragem e abertura | 2 a 42 (mediana 19) | Blender |
| **Enquadramento** | um distrito | três berços | gerador de mapa (`MEIA_LARG`) |
| **Contorno de silhueta** | sim, suave | **feito pelo contraluz do rig**, e não por traço — as duas técnicas de traço foram testadas e rejeitadas (Etapa 3) | resolvido |
| **Oclusão de ambiente** | em toda fresta | só a sombra de contato | Blender |
| **Água/areia** | tropical quente, com praia | mar frio, sem areia | gerador de mapa (constantes) |
| **Rosto de personagem** | sim | não | textura — **não é geometria** |
| **Chrome da interface** | gradiente, sombra, cor por botão | chapado navy/creme | tema do Godot — **não é Blender** |

A contagem de peças por prop, hoje (`tools/gerar_props_iso.py`):

```
pier_ampliado 112 · guindaste_lanca 59 · pier_construido 53 · escritorio 42
galpao 39 · galpao_velho 38 · barco_grande 33 · barco_medio 29
barco_pequeno 24 · coqueiro_copa 19 · pier_vazio 8 · trabalhador 5
escritorio_ruina 5 · coqueiro_tronco 2 · conteiner 2 · caixote 2
boia 2 · marcador 2
```

**A cauda é o problema, não a cabeça.** O píer e o guindaste já estão densos;
contêiner, caixote, boia e marcador têm duas peças cada e ocupam boa parte da
tela num pátio cheio. É lá que está o ganho barato.

---

## 3. O que o Blender por script alcança — e o que não alcança

### Alcança, e é só trabalho

1. **Densidade.** É um laço. Foi o ganho desta rodada: o kit de detalhe
   (`na_face`, `moldura`, `janela`, `porta`, `telhado_duas_aguas`,
   `corrimao`, `escotilhas`) levou o galpão de 4 para 39 peças e o cargueiro
   de 12 para 33, e o custo por prop novo cai a cada peça de kit que entra.
2. **Ferragem e abertura.** Corrimão, escada, vigia, calha, moldura, trilho,
   corrente, defensa. Tudo primitiva composta.
3. **Material com textura procedural.** Ripa de madeira, corrugado de
   contêiner, fiada de telha, ferrugem escorrida, cal descascada — nós de
   ruído/onda/voronoi. O projeto já usa `material_gasto`; falta a família de
   padrões dirigidos.
4. **Oclusão de ambiente e luz quente.** O Cycles já está lá; é ajuste de
   parâmetro e um passe de AO.
5. ~~**Contorno de silhueta.**~~ **Resolvido, e não como se supunha.** O
   Freestyle foi rejeitado com razão (fecha o vazado da treliça, engorda peça
   pequena) e o compositor — a saída que este item propunha — foi construído,
   medido e rejeitado também, por outra razão: num estilo que desenha o
   detalhe com fronteiras de valor, um filtro de borda redesenha o desenho.
   Quem faz o trabalho é o contraluz do rig de três pontos. Os números estão
   na Etapa 3.
6. **Props que faltam.** Caminhão, empilhadeira, poste, cabeço avulso, pilha
   de caixotes, silo, pórtico, vagão, toldo de comércio. Cada um é meia hora
   de kit.

### Não alcança por script, e é honesto dizer

1. **Rosto.** Um trabalhador com cara a 40px é textura pintada num plano, não
   geometria. Caminho: gerar uma folha de rostos por gerador de imagem (onde
   perspectiva não importa, como já se faz com os retratos) e aplicá-la como
   material num plano da cabeça.
2. **A pincelada.** A referência tem variação de mão — telha que não repete,
   parede com mancha que conta uma história. Ruído procedural chega perto e
   não chega lá. Já registrado em `docs/arquivo/BLOCO5_PROMPTS_BLENDER_RICO.md`: *"o
   volume, a luz, o desgaste e a densidade de peça, sim; a pincelada, não."*
3. **Composição.** A referência tem um pátio ARRUMADO por alguém — fileiras
   que fazem sentido, circulação, um caminhão parado onde faria falta. Isso é
   decisão de layout, e continua sendo trabalho de quem desenha o mapa.

**Teto realista:** ~80% da leitura da referência, com o resto vindo de
textura pintada por cima da geometria do Blender. É o mesmo caminho que os
jogos com essa cara usam de verdade.

---

## 4. Ordem de execução

Ordenada por **ganho visível ÷ custo**, e não por gosto. Cada etapa é
verificável — o teste de design e a folha de contato dizem se ficou.

### Etapa 1 — Paleta e enquadramento (barato, muda tudo)
- Água e areia tropicais no dicionário `C` de `gerar_mapa_iso.py`; acrescentar
  faixa de praia entre a água rasa e o cais.
- Reavaliar `MEIA_LARG`/`MEIA_ALT`: a referência mostra um distrito. Baixar a
  escala mostra mais porto pela mesma tela, e **muda a projeção**, portanto
  exige regerar props E rodar o teste de design (que é justamente o que
  garante que os dois voltam a bater).
- **Mede-se por:** captura antes/depois lado a lado.

#### ✅ A PALETA está feita (02/09). O enquadramento e a areia, não.

**Feito:** água, parede, vegetação e casas da vila, com os valores amostrados
da tabela de paleta do `docs/design/referencias/README.md`. O mapa era de mar
frio (`#4a96b4` rasa, `#1d4f68` funda) num jogo cujo cenário é o litoral
brasileiro. Nenhuma coordenada mudou, então **a tabela de âncoras saiu idêntica**
— era esse o compromisso de não tocar na projeção.

⚠️ **E trocar só o MATIZ achatou a água, o que só se viu ampliando a captura.**
Pôr os dois valores amostrados nas duas pontas da rampa comprimiu a separação
de luminância entre água funda e baixio de **89,7 para 67,3** — 25% a menos — e
o mar virou uma chapa turquesa bonita e sem profundidade. A espuma foi junto:
traço claro sobre água ESCURA contrasta, sobre água CLARA não, e o contraste de
Weber caiu de **0,57 para 0,46** embora a diferença absoluta quase não mudasse.
Na captura inteira isso passava; ampliado a 3×, era evidente.

A correção manteve a amostragem **onde ela vale** — a referência enquadra a
água rasa junto ao cais — e estendeu a rampa para baixo na água funda, no mesmo
matiz ciano. Fim: amplitude **99,4** (mais do que os 89,7 do mar frio) e Weber
**0,56**. Tropical no matiz e com mais profundidade do que antes, em vez de
menos.

**A faixa de areia NÃO foi feita, e não por esquecimento.** A costa deste mapa é
cais de pedra com enrocamento de ponta a ponta — não existe margem natural onde
uma praia caiba. Pôr areia exige decidir ONDE: fundo de areia visto através da
água rasa, ou um trecho de costa que deixa de ser cais? É decisão de desenho, e
**as cinco imagens de referência ainda não estão no repositório** (ver o aviso
no topo de `docs/design/referencias/README.md`), então não há como consultá-las.
Fica para quando elas entrarem pelo Git.

**O `MEIA_LARG` também não.** É a metade arriscada da etapa: muda a projeção,
obriga a regerar todos os props em Blender (~1 GB de `bpy`) e a reconciliar o
teste de design. Merece a sua própria passagem.

#### ⚠️ E MEDIDO EM 03/09: baixar o `MEIA_LARG` não mostra mais porto

Gerou-se o mapa base em 30 (o de hoje), 24 e 20, com o MESMO ponto do mundo no
centro — o `CX`/`CY` é recalculado, senão a comparação media o deslocamento da
origem em vez do enquadramento. O resultado desmente a premissa da etapa:

| `MEIA_LARG` | terra visível | canto sup-esq | azul escuro na tela |
|---:|---:|---|---:|
| **30** (hoje) | 20,1% | terra no pixel 0 | 6,9% |
| 24 | 23,8% | **vazio por 51 px** | 14,6% |
| 20 | **23,6%** | **vazio por 100 px** | 27,4% |

**A terra visível SATURA em ~24% e depois cai.** De 24 para 20 não entra mais
porto nenhum — entra mais vazio, e o azul escuro quase dobra. A razão é que o
mundo é FINITO: os `DEGRAUS` acabam em `my = 34` e o `FUNDO_TERRA` está em
`mx = -8`, então afastar a câmera não descobre mais mapa, descobre a borda
dele. Em 20 há uma cunha de 100 px no canto superior esquerdo onde a terra
simplesmente termina numa diagonal reta contra água funda.

**O que isto muda no custo da etapa:** ela deixa de ser "mexer numa constante e
regerar os props" e passa a ser "estender o mundo primeiro" — mais degraus de
costa, mais vila, mais água — e só depois mexer na projeção. A parte cara não
é o `bpy`; é o mapa que ainda não existe.

**A ESCOLHA DO BRUNO É `MEIA_LARG = 20`** (03/09), feita olhando as três lado
a lado. O bloqueio de composição saiu: a leitura das cinco referências está
agora escrita em `docs/design/referencias/README.md`, e responde também onde
vai a areia — nas duas pontas da costa, para além do primeiro e do último
berço, e **não** entre a água e o cais.

Fica a ordem do trabalho, que é o que esta medição estabelece:

1. **Estender o mundo** — mais degraus de costa para além de `my = 34`, terra
   para trás de `mx = -8`, e os dois remates de praia nas pontas. Sem isto,
   baixar o `MEIA_LARG` mostra a borda do mapa.
2. **Só depois** baixar o `MEIA_LARG` para 20, regerar os props em Blender e
   reconciliar `Main.tscn` com o teste de design.

Os arquivos das imagens continuam FORA do repositório — anexo de conversa não
vira arquivo no disco —, mas a decisão que eles travavam já não está travada.

**O passo 1 andou meio degrau em 03/09, e por outro motivo.** O alargamento do
pátio (`RUA_RECUO` 4,3 → 6,8, `VILA_RECUO` 6,0 → 8,5) empurrou rua e vila 2,5
unidades para dentro, o que preenche parte da terra vazia que havia entre a
fileira de casas e o `FUNDO_TERRA = -8`. Não dispensa o passo 1 — a costa
continua a acabar em `my = 34` e o mundo continua a acabar dentro do quadro a
`MEIA_LARG = 20` —, mas o lado de TERRA precisa de menos do que precisava.
O custo medido do recuo foi dois lotes da vila a sair do quadro, de 11 para 9.
Baixar o `MEIA_LARG` deve trazê-los de volta, mas isso **não está medido** — o
`CX`/`CY` do mapa está afinado para 30/15 e refazer a conta é o passo 2.

> ⚠️ **Esta contagem é de 03/09 e a vila mudou em 04/09**, com uma segunda
> fileira e quarteirões: são 26 lotes gerados e 12 com a âncora no quadro. A
> "terra vazia entre a fileira de casas e o `FUNDO_TERRA`" de que fala o
> parágrafo acima está agora ocupada — pela fileira de trás e pela mata, que
> deixou de ser desenhada fora do ecrã. **O que isto muda para o passo 1:** o
> lado de TERRA precisa de ainda menos do que precisava, e o argumento a favor
> de baixar o `MEIA_LARG` deixou de ser "há terra vazia" e passou a ser só o
> enquadramento. A costa continua a acabar em `my = 34`.

#### ✅ O ENQUADRAMENTO FICOU EM 05/09 — a Etapa 1 está fechada

**A ferramenta é `tools/medir_enquadramento.py` + `medir_enquadramento.gd`.**
A medição de 03/09 foi feita à mão e não ficou no repositório, o que obrigava a
sessão seguinte a acreditar nela. Agora ela repete-se num comando, e rasteriza
com o ThorVG — o MESMO importador de SVG do jogo, e o único rasterizador que
existe neste contêiner.

**Ela achou o que a de 03/09 não tinha como achar: são TRÊS fronteiras, não
uma.** Aquela contava a distância do canto superior esquerdo à terra; esta mede
quantos pixels da FRONTEIRA DO MUNDO caem dentro da janela, e o mundo acaba por
três lados diferentes. Com o mundo de 04/09, a `MEIA_LARG = 20`:

| fronteira | onde sai | dentro do quadro |
|---|---|---:|
| `mx = FUNDO_TERRA` | canto superior esquerdo | **313 px** |
| `my = DEGRAUS[0][0]` (o começo da costa) | canto superior **direito** | **200 px** |
| `my = DEGRAUS[-1][1]` (o fim dela) | canto inferior esquerdo | **113 px** |

O passo 1 desta seção falava em "mais degraus para além de `my = 34`, terra
para trás de `mx = -8`" — e não mencionava a ponta NORTE, que é a segunda
maior das três. Ela existia desde sempre e nunca aparecera porque a `30` o
mundo transborda dos quatro lados sozinho.

**O que se fez, e é o mínimo medido:** um degrau em cada ponta
(`my` de −14 a 42, contra os −6 a 34) e `FUNDO_TERRA` de −8 para −16 (o mínimo
é −15). Os três vão a **zero**; dois degraus por ponta não trazem nada que se
veja.

#### E a LARGURA é só metade do enquadramento — a outra é o CENTRO

Estendido o mundo e baixada a câmera, a primeira captura saiu com o porto
encostado à direita e um bloco de mata e telhado a ocupar a esquerda inteira:
**61% do quadro em terra**. A leitura das referências é explícita nas duas
pontas — *"a água ocupa perto de metade do quadro, e a maior parte dela é água
aberta sem nada; vazio de propósito, é o que dá escala ao porto"* e *"a cidade
é uma FAIXA atrás do cais, nunca um bloco"* — e nenhuma das duas estava a ser
respeitada.

A causa é que o `CX`/`CY` continuava a manter no centro o ponto do mundo que lá
estava a 30. Ele passou a ser DERIVADO: o **centroide dos três berços**
(`_centro_do_porto()`), o que centra a câmera no porto de que ela é. Se um
berço mudar de sítio, a câmera vai atrás dele.

| | terra | terra natural | azul aberto | fronteira no quadro |
|---|---:|---:|---:|---:|
| **30** (o de sempre) | 67,8% | 26,3% | 5,5% | 0 px |
| 20, mundo de 04/09, centro antigo | 54,7% | 24,3% | 25,1% | **626 px** |
| 20, mundo estendido, centro antigo | 61,0% | 31,9% | 16,3% | 0 px |
| **20, mundo estendido, centrado no porto** | **47,3%** | **22,3%** | 25,8% | **0 px** |

⚠️ **E o "azul vazio" deixou de ser a medida que interessa** — repare que a
linha final tem quase o mesmo valor da segunda, que era a ruim. Na segunda ele
era o mundo a ACABAR; na última é mar aberto, que é o que a referência pede.
Quem responde por isso é a coluna da direita, e é para isso que ela existe.

**E isto desmente a medição de 03/09 no ponto em que ela desmentia a etapa.**
"A terra visível SATURA em ~24% e depois cai" era verdade do MUNDO, não da
projeção. Centrado no porto e com o mundo estendido, a fração de porto no
quadro fica PARADA em ~47,5% nas três larguras, e o que cresce é o distrito à
volta dele: terra natural **14,4% → 18,4% → 22,3%** de 30 para 20. É
exatamente o que a etapa prometia — *"a referência mostra um distrito"* — e não
se via porque o mundo acabava antes.

**O custo real, medido antes de prometer** (o documento supunha "~1 GB de
`bpy`, e merece a sua própria passagem"): `pip install bpy` leva **17 s** (373
MB), `gerar_props_iso.py` regera os 15 props em **68 s** e `gerar_brp.py todos`
os outros 24 em **2 min 40**. Quatro minutos de máquina ao todo. O que custou
mesmo foi o que ninguém tinha medido: **altura, no gerador do mapa, é PIXEL** —
ver §1.1 de `docs/BRP_SPATIAL_CONTRACT.md` e a regra no `CLAUDE.md`.

### Fora das etapas — os dois prédios em RUÍNA, e os letreiros (05/09)

Correção de leitura, pedida depois de olhar o enquadramento novo: *"as
construções atuais parecem avançadas para um porto inicial"*.

**Os letreiros do mapa saíram.** As três placas — ESCRITÓRIO, ARMAZÉM, ZONA DE
ESPERA — foram removidas a pedido, com o `Letreiro.gd`, a variação `Letreiro`
do tema e o bloco D7 do teste de design. O argumento contra tirá-las era que os
dois prédios do porto passariam a ler-se como casas da vila; o que se fez em
vez de as manter foi resolver isso pelos PRÉDIOS, que é onde o Bruno pediu que
o investimento fosse.

**O `galpao_velho` não era uma ruína, e a causa estava escrita.** Ele reusava a
lista `paredes` do `galpao` — plinto, caixa de `parede` BRANCA, portão fechado,
calha e três janelas de vidro azul — e trocava só a cor do telhado. Medido: os
dois estados diferiam em pouco mais do que o matiz do telhado. O comentário do
escritório, dez linhas abaixo no mesmo arquivo, já dizia a regra que ele não
seguia: *"a ruína não é o prédio pintado de velho: é MENOS prédio"*.

Hoje ele tem paredes próprias em `parede_suja`, um terço delas desabado em
pedaços irregulares, vão nenhum com vidro, o portão fora do trilho com a folha
atravessada, metade do telhado no chão e a armação à vista — barrotes, terça e
cumeeira.

**E a ruína do escritório falhava pelo lado oposto.** Ela seguia a regra e
mesmo assim não lia: duas caixas cinzentas e um pau, que ampliadas saíam como
uma PILHA DE LAJES DE CONCRETO. *Menos prédio não é menos arquitetura* — o que
faz o olho ler "ruína" e não "entulho" é reconhecer o que falta, e para isso
alguma coisa tem de ficar de pé com um vão dentro. Hoje é um CANTO: as duas
paredes que a câmera vê, cada uma com o seu vão, e o resto a desfazer-se.

**Três armadilhas apanhadas ampliando, e nenhuma delas dava erro:**

| O que se via a 5× | O que era |
|---|---|
| uma escada de três degraus | a parede caída descia por passos IGUAIS — regularidade denuncia geometria gerada, a mesma lição da vila que lia como cerca |
| uma barra preta de pé na quina | as duas paredes do canto chegavam ao mesmo `x` e as faces exteriores ficavam coplanares |
| ripas a pairar sobre o ar | os barrotes corriam até 1,58 e a parede acaba em 0,65; sem terça nem apoio, lêem como gravetos |

As três estão registadas no `CLAUDE.md`, e as duas primeiras são corolários de
regras que ele já tinha.

### Fora das etapas — o ARMAZÉM ACABADO, o outro lado do par (05/09)

A ruína do armazém foi consertada mais acima nesta página, e o conserto
deixou o par desequilibrado: o estado ANTES ganhou vocabulário próprio e o
estado DEPOIS continuou a ser o que sempre tinha sido — uma casa grande. O
Bruno disse-o assim: *"o galpão ainda lê como casinha e não como armazém —
portão chato, sem plataforma de carga, sem corrugado"*.

**E a causa era a mesma de sempre, com o sinal trocado.** Lá, o estado antes
partilhava as peças do depois; aqui, o estado depois nunca teve vocabulário
nenhum. As quatro peças que o desenhavam eram todas do repertório doméstico:
parede lisa, telhado de TELHA com fiada horizontal, três `janela()` com
moldura e travessa, e a `porta()` do kit esticada — a mesma função que faz a
porta do escritório. Posto ao lado das casas da vila, que têm parede clara e
telhado de telha, ele lia-se como o que era: **a maior casa do bairro**.

**As quatro trocas, por ordem do que cada uma vale na tela:**

| O que mudou | Porquê |
|---|---|
| **Telhado de zinco**, com a nervura no sentido da água | É a maior superfície do prop. A fiada corre em X e sai como um feixe descendo para a direita — o desenho de um telhado de telha. A nervura corre em Y e sai a subir para a direita: o mesmo custo de geometria, a leitura trocada (`telhado_duas_aguas(..., nervuras=N)`) |
| **Plataforma de carga** | O plinto de 0,18 virou uma doca de 0,44 — altura de estrado de caminhão — com deck saliente na face `+x`, defensas de borracha, dois degraus e a soleira do portão assente NELA |
| **Chapa corrugada** nas duas faces visíveis | Pela receita do contêiner: painéis de valor diferente, não vincos de relevo |
| **Portão de enrolar**, laranja, com tambor e guias | No lugar do retângulo castanho chapado. 26px de largura numa face de 49 — é uma FORMA, não um detalhe |

Mais a **fita de vidro corrida** rente ao beiral, que substituiu as três
janelas de moldura: janela com moldura, travessa e peitoril é janela de casa,
e três em fila numa parede clara são a assinatura de uma.

#### Isto adianta metade da Etapa 4, e vale dizer qual metade

A Etapa 4 pede *"ripa, corrugado, fiada de telha, ferrugem que escorre, cal
descascada"* e **mede-se pelo galpão**. O corrugado ficou feito — e ficou
feito na peça pela qual a etapa se mede, nas duas escalas que ela exige (o
prop a 5x e o mapa a 1x). **Ripa, ferrugem e cal continuam por fazer**, e são
para todos os props, não só para este. A etapa não fecha aqui.

#### Cinco coisas que a passagem mediu, e três desmentiram o desenho

**1. A altura não cresceu um pixel, e isso foi decisão.** A cumeeira continua
em 2,32 — a doca COME parte da parede (0,44 + 1,26 + 0,62) em vez de se
empilhar debaixo dela. Empilhar teria devolvido metade do defeito que o
`ESCALA_PREDIO` de 03/09 existe para corrigir: os dois prédios do pátio a
levantarem-se ~4x a altura de uma casa e a derramarem a silhueta pela estrada.

**2. ⚠️ COPIAR O VALOR DE UMA COR QUE NÃO VIVIA DELE NÃO COPIA NADA.** O
telhado de zinco foi escolhido pela regra do §3 da skill `/arte` lida ao
contrário — trocar o matiz sem tocar no valor —, e a conta fechava: `#5f6e7a`
mede 108 de luminância contra os 105 do `telhado` de telha. Medido no jogo
rodando, ele ficou a **0,12 de Weber** contra o asfalto do pátio... que é
exatamente o que a telha já dava (**0,13**). A telha **nunca se separou do
chão pelo valor — separou-se pelo MATIZ**, terracota contra cinza-azulado; e
o zinco, sendo cinza-azulado como o asfalto, ficou sem separação nenhuma.
Descer para `#4e5b66` dá **0,26**. É a irmã da armadilha da água de 02/09, do
outro lado: lá trocou-se o matiz e esqueceu-se o valor; aqui copiou-se o valor
certo de uma cor que não vivia dele.

**3. O custo dessa descida, medido:** 15 pontos de luminância média AO PROP
(122,7 → 107,5) e **zero ao mapa** — a captura inteira fica em 116,3 de média
e 151 de amplitude, contra 116,5 e 151 antes. Um prédio não move a composição;
move a própria leitura.

**4. ⚠️ O DECK SAIU PELA FACE `+x` POR CAUSA DA PEGADA, e a régua decidiu
antes da história.** As duas faces são visíveis, mas o espaço à volta delas
não é o mesmo: medido em `porto_mapa_ancoras.json`, o armazém tem **0,236**
unidades de folga em `+my` (até o cotovelo da rua, em 14,68) contra **0,746**
em `+mx` (até o avental, em 8,70). Em `-y` cabem 0,25 de avanço e nem um a
mais; em `+x` cabem 0,45 e ainda sobra meia unidade de cada lado. **Conferido
com defeito injetado:** pôr a pegada em `my` nos 3,46 que este mesmo deck
exigiria do lado `-y` faz o bloco D2 reprovar com *"a pegada entra no cotovelo
da rua"* e sair com código 1. A história só confirmou: em `+x` a plataforma dá
para o avental, que é por onde a carga do navio chega.

**5. ⚠️ A DOCA NÃO SE SEPARAVA DA PAREDE PELO TOM, E A PALETA DIZIA QUE SIM.**
Na paleta a doca (`concreto_borda`, 152) fica muito abaixo da parede (241). No
render, com a luz da cena, a doca sai a ~150 e os VINCOS da chapa saem a ~135:
a faixa da base e a textura da parede caem na **mesma banda de valor**, e o
degrau que devia dizer "plataforma" lia-se como mais uma sombra do corrugado.
Quem separou foram três pixels de `metal` no topo da doca — a mesma lição das
cantoneiras do contêiner: **a esta escala quem separa não é o tom, é a LINHA
escura**.

E duas armadilhas velhas apanhadas outra vez, as duas nessa linha de 1px: ela
tinha a largura da doca e as pontas saíam da quina como farpas no vazio, e o
topo dela ficava coplanar com o tampo da doca. Param antes das duas agora.

**O que NÃO se fez, e porquê:** o lanternim de cumeeira (a clarabóia elevada
que todo galpão tem) ficou de fora — são 0,29 de altura, +11,6% na silhueta, e
desfaria um terço do que o `ESCALA_PREDIO` comprou. E a ruína não foi tocada:
o `telhado_velho` castanho já lê como zinco enferrujado ao lado do zinco novo,
e ela acabou de ser refeita.

### Fora das etapas — os três níveis do píer, da lança e do casco (05/09)

Pedido: *"variações de píer, guindastes e navios, para marcar a transição e
evolução do porto"*. O GDD 7 já tinha decidido a forma disto —
*"estruturas principais (grua, cais, armazém) têm upgrade in-place de até 3
níveis"* (`docs/gdd/perguntas.md`) —, então o que se fez foi a ARTE dos três
níveis, não a mecânica.

**A mecânica é da Fase 2 e continua por fazer, de propósito.** Quem escolhe o
nível é `GameState.nivel_porto()`, que só LÊ quantas estruturas já estão de pé:
0–1 → n1, 2–3 → n2, 4–5 → n3. Não guarda estado, não decide nada e não
acrescenta constante nenhuma — os 99,8% / 80,5% / 35,2% medidos ficam intocados
**por construção**, e não por cuidado. É o mesmo padrão da vila, que cresce por
`--nivel-vila=N` "sem o jogo precisar saber disso".

| | píer | lança |
|---|---|---|
| **n1** | estacas e ripas de madeira crua com fresta, dois cabeços, sem carga | pau-de-carga curto: um braço só, sem contralança nem contrapeso |
| **n2** | o de sempre — tabuado inteiro, contêiner e caixotes | a de sempre |
| **n3** | laje de concreto sobre estacas de aço, meio-fio, cinco defensas de pneu, quatro cabeços e contêiner empilhado | lança longa, contrapeso maior e **spreader** em vez de moitão |

E os **navios** passaram a ser três em doca, escolhidos pelo VALOR do contrato
— pesqueiro, cargueiro e cargueiro grande. O `barco_medio` já existia,
renderizado e validado, e **nunca entrava numa doca**: o jogo escolhia entre
dois cascos por um booleano. O contrato já vale de R$8.000 a R$70.000 e não
custava nada dizê-lo com a silhueta.

⚠️ **A TORRE ERA A MESMA NOS TRÊS, E ISSO ERA O DEFEITO — não a restrição.**

Esta página afirmou durante uma sessão que a torre partilhada era uma
imposição do `pivot_offset`. É meia verdade, e a metade que falta é a que
importa: o pivô é UM PONTO — `TOPO`, `GX`, `GY` —, não a coluna inteira. Tudo
o que fica abaixo dele sempre foi livre.

E o preço de não ver isso apareceu no telefone. A lança é o braço fino lá em
cima; a torre é a coluna que ocupa a silhueta. Com a mesma torre nos três, o
porto inicial e o completo liam como **o mesmo guindaste** — foi a queixa
exata: *"parecem ser o mesmo, sendo que o porto inicial possui o mesmo
guindaste do porto mais avançado"*.

Hoje cada nível tem torre própria, e o topo é que não se mexe:

| | torre |
|---|---|
| **n1** | pau-de-carga: poste de MADEIRA, duas cintas, dois estais em olhal. Sem treliça e sem cabine — é a única grua do jogo que não é laranja, porque o laranja é a cor do maquinário e um pontão provisório não tem maquinário |
| **n2** | a treliça laranja de sempre, meia-largura 0,19, cabine pequena junto ao topo |
| **n3** | pórtico: treliça a 0,27 (+42% de largura), casa de máquinas no convés, cabine maior a meia altura e escada |

**⚠️ O n3 não pode crescer para CIMA, então cresce para os LADOS e para
BAIXO.** A altura do topo é o único número que este prop não pode tocar; a
leitura de "maior" vem da ÁREA da coluna e das peças ao pé dela.

O bloco **D17** trancava só metade disto — as três asserções olhavam para a
LANÇA e exigiam que ela cobrisse o pivô, e nenhuma perguntava se a TORRE
chegava lá. Enquanto a torre era uma só isso não podia falhar, e por isso a
falta não se notava; com três torres passaram a existir três maneiras de a
lança girar em torno do vazio, nenhuma delas com erro. Hoje o D17 confere os
dois lados, e **o defeito foi injetado para o provar**: encurtar o poste do n1
em 0,90 faz reprovar com *"o alfa no pivô é 0.00"* e sair com código 1.

⚠️ **E empilhar não é passar uma altura maior.** O contêiner de cima do n3
nasceu com `altura_px` dobrada, que o `_no_conves` lê como caixa MAIS ALTA
assente no convés: o segundo engoliu o primeiro e o render saiu com um cubo
azul do tamanho da cabine do guindaste.

### Fora das etapas — a escala dos dois prédios do pátio (03/09)

Não é etapa do plano: é correção de playtest, e entra aqui porque mexeu em
geometria de prop e no `bpy`.

O Bruno leu "o armazém e o escritório estão muito grandes, além disso estão em
cima da estrada" DEPOIS de o pátio já ter sido alargado e de o teste já provar
que a pegada dos dois não toca o asfalto. As duas coisas eram verdade ao mesmo
tempo, e a lição vale para o resto do plano:

| | antes | depois |
|---|---:|---:|
| Armazém — largura do pátio ocupada | 90% | **65%** |
| Armazém — sprite | 258px | **185px** |
| Armazém — contra o maior navio (146px) | 1,8× | **1,27×** |
| Escritório — sprite | 213px | **154px** |
| Altura contra uma casa da vila | ~4× | ~3× |
| Lotes da vila no quadro | 9 | **11** |

**Base legal e silhueta a derramar são coisas diferentes.** Em isométrico a
altura projeta para cima E para trás; um prédio 4× mais alto que os vizinhos
cobre o que está atrás dele mesmo com a pegada certinha. O teste de design
media a pegada — e continuou a passar o tempo todo, porque ele nunca esteve
errado sobre a pegada.

**Encolheu-se o GRUPO (`ESCALA_PREDIO = 0,72`), não as literais.** Porta contra
parede, janela contra porta, beiral contra telhado: trinta números e trinta
chances de um ficar por escalar. E cada objeto uma vez só — `galpao` e
`galpao_velho` partilham as paredes, e escalar grupo a grupo daria `k²` nelas.

### Fora das etapas — o caminhão virado para o eixo da estrada (03/09)

Mesma origem. O prop nascera deitado em `mx` (cabine para o mar) e o playtest
pediu que ele percorresse a ESTRADA, que corre em `my`.

**E não se resolveu rodando o grupo 90°.** Só as faces `+x` e `-y` são
visíveis por esta câmera: rodar punha o para-brisa a olhar certo e mandava a
janela lateral para `-x`, que ninguém vê. O corpo foi RECONSTRUÍDO com o
comprimento em `y` e cada detalhe reposto na face visível — inclusive o eixo
das rodas, que num veículo deitado em `my` aponta em `x` (o `_roda()` ganhou
um parâmetro para isso).

### Fora das etapas — vegetação e distribuição das casas (04/09)

O último item de arte que a análise do playtest deixou aberto: *"a vegetação é
bem pobre, e as casas poderiam ser melhor distribuídas, para isso pode
consultar mapas de cidades portuárias de diversos tamanhos"*. Nada disto é
Blender — é `tools/gerar_mapa_iso.py` inteiro.

**O que a medição achou, e não era o que se supunha.** A queixa lia-se como
"há pouca vegetação", e a resposta óbvia seria gerar mais. Era o contrário:

| Medido em 04/09 | Antes | Depois |
|---|---:|---:|
| Copas de mata **desenhadas** no quadro | **7** (de 136 sorteadas) | **108** (36 por degrau, e o degrau 3 fica a zero porque está fora) |
| Objetos legíveis na faixa de terra | 15 | 55 |
| Casas geradas · com a âncora dentro do quadro | 16 · **8** | 26 · **12** |
| Vão mais repetido entre casas | 1,95 — **11 de 15 (73%)** | 6,14 — **1 de 24 (4%)** |
| Amplitude de luminância DENTRO da copa | 20,3 (`mangue`→`mato`) | **92,3** (saia→realce) |
| Contraste da copa contra o relvado (Weber) | 0,21 | **0,45** |
| Manchas de concreto pintadas no verde | 2.324 px | **0** |
| Verde na faixa de terra | 48,6% | 42,0% |

A última linha é o preço, e está aqui de propósito: a vila cresceu e comeu
6,6 pontos de verde. O verde continua a ser a cor dominante da terra, e agora
é verde ESTRUTURADO — árvore com sombra e volume — em vez de relvado chapado.

**Quatro causas, e três delas eram código a apontar para fora do ecrã:**

1. **O viés da mata apontava para o fundo do mundo.** `vies = random ** 2.2`
   esmagava as copas contra `mx0`, que é o `FUNDO_TERRA` — e o nome da
   constante já diz o que ela é, "o quanto a terra recua para trás (fora do
   ecrã)". Medido por degrau, a fração da faixa de mata dentro do PNG: **11%,
   50%, 10% e 0%**. O comentário da função descrevia a intenção com todas as
   letras — "a densidade cresce para o fundo" — e o fundo é o que ninguém vê.
   Hoje o viés aponta para a frente, `no_quadro()` corta o que sai do PNG, e o
   orçamento é de árvores DESENHADAS e não de sorteios.
2. **A copa eram duas elipses concêntricas** — deslocadas 8 a 14 px numa copa
   de 40, 70% de sobreposição. É a forma que o enrocamento já tinha tentado e
   descartado em 03/09 ("elipse com cópia menor por cima lê como elipse
   chapada com sombra"). A receita das pedras saiu de lá com nome próprio,
   `com_saia()`, e a copa passou a ser sombra projetada + tronco + dois ou
   três lobos com saia. O par de tons é o AMOSTRADO da referência
   (`#3e8f3a` corpo, `#6fbf4e` realce), que não existia como cor no mapa.
3. **O capim eram três riscos retos** — exatamente o defeito que o
   `manchas_chao` já tinha registado por escrito ("leram como SETAS verdes,
   não como planta") e corrigido, sem que ninguém visitasse a função irmã. As
   duas passaram a chamar `tufo_de_capim()`.
4. **O desgaste do CAIS estava a ser pintado no relvado.** O centro de cada
   mancha de concreto saía de `uniform(FUNDO_TERRA, borda)` — o bloco de terra
   inteiro — em vez da faixa de concreto. Onze manchas cinza-azuladas de 19 a
   37 px de raio caíam na mata e na vila. A junta de dilatação, dez linhas
   abaixo, sempre esteve certa, e o comentário dela dizia porquê.

**E as casas: de pente a quarteirão.** 73% dos vãos mediam exatamente 1,95, o
`VILA_PASSO`, batido como metrónomo. As plantas de cidade portuária que a
leitura das referências manda consultar dizem duas coisas — quarteirões curtos
cortados por travessas, e casas encostadas na frente de rua (em Paraty e em
São Sebastião a frente é feita de geminadas, sem recuo). Então o passo tem
agora dois regimes: dentro do quarteirão 3 a 5 lotes quase colados, com um par
em cada três geminado; entre quarteirões, uma travessa de 1,5 a 1,9. O
alinhamento à rua é por QUARTEIRÃO e não por casa — sortear o recuo casa a
casa desmancha a frente de rua, que é o que se lê como cidade de longe.

**A segunda fileira, e a suposição que ela desmentiu.** O código dizia, em
comentário: *"uma fileira só, e não duas: a segunda cairia fora da esquerda do
ecrã a partir do terceiro degrau"*. A frase estava certa e a conclusão errada
— medido, a segunda fileira tem **11,7 unidades no quadro contra 17,3 da
primeira, 67%**. Ela some no degrau 3, como o comentário dizia; só que o
degrau 3 já estava fora inteiro.

**E ela obrigou a uma régua nova, também medida:** um telhado desta vila tem
~78 px na tela, e a separação entre fileiras é `Δmx × MEIA_LARG`. Com a
travessa de trás de 0,55 isso dava **57 px** — a casa de trás ficava 73%
tapada e a captura mostrava três telhados fundidos num borrão de telha. Com
1,60 dá 88 px e o telhado de trás sai inteiro. O preço: a segunda fileira
encolhe de 11,6 para 8,5 unidades visíveis.
A fileira de trás é também mais rarefeita (quarteirões de 2 a 3, travessas de
2,2 a 3,4) e planta-se mais nela — 0,85 contra 0,55 de probabilidade por lote.
Uma vila que acaba numa parede de telhados é tão errada quanto uma que acaba
numa fileira só: o que a orla de uma cidade pequena faz é DESFIAR-SE.

**Duas coisas que NÃO se fizeram, e por quê:**

- **Árvore de rua no passeio, que é o que a referência pede.** Entre a calçada
  e a frente do lote há **0,13 unidades — 4 px**: não cabe tronco. E plantar
  NA calçada punha a copa a pender sobre o asfalto, onde o caminhão, que é
  PROP desenhado por cima do mapa, passaria por cima dela. As árvores foram
  para o quintal, dentro do lote: na projeção a copa sobe e recua na tela, ou
  seja, para longe da rua.
- ~~**A faixa de areia nas pontas da costa**~~ — **feita em 04/09**, e tem
  seção própria logo abaixo desta.

**O que guarda isto:** o bloco **D14** do `teste_design.gd`, que não existia.
Ele confere que nenhuma casa se come com a vizinha, que nenhuma cai debaixo da
silhueta de um prédio do pátio, e que as duas fileiras se separam por mais de
um telhado. Os `lotes` eram publicados na tabela de âncoras desde sempre e
NENHUM teste os lia. Quatro defeitos foram injetados e os quatro reprovaram.

#### ✅ A AREIA DAS DUAS PONTAS ficou em 04/09

A leitura de composição (`docs/design/referencias/README.md`) diz onde ela vai:
**onde o porto não está** — nas duas pontas da costa, para além do primeiro e
do último berço —, e nunca entre a água e o cais. Logo o que se fez não foi
pintar uma faixa: foi **o porto PARAR** nos dois trechos. Ali não há avental,
asfalto, junta, mancha de desgaste nem enrocamento; há terra que desce numa
rampa de areia até a água, com restinga atrás e pedras avulsas em cima.

**Onde parar foi medido, e as duas pontas não são simétricas** porque o que
está lá hoje não é simétrico. Costa VISÍVEL na janela do jogo (720×660):

| corte norte | costa | | corte sul | costa | ocupado hoje |
|---:|---:|---|---:|---:|---|
| 0,4 | 112 px | | 21,0 | 283 px | coqueiro, pilha, palete, empilhadeira, carga |
| 0,8 | 125 px | | 22,0 | 250 px | empilhadeira, carga |
| **1,2** | **139 px** | | **22,5** | **233 px** | empilhadeira, carga |
| 1,6 | 152 px | | 23,0 | 216 px | empilhadeira, carga |
| | | | 24,0 | **49 px** | carga |

O norte para em 1,2 porque 1,6 comeria a carga do pátio e só traz 13 px. O sul
para em 22,5 porque é onde a conta vira: 22,0 traz 17 px a mais e custa mais
três props, e **24,0 — o degrau seguinte, que parecia o corte natural —
derruba a costa visível de 233 para 49 px**, porque é ali que ela sai do
quadro pelo canto de baixo. Teria sido repetir a mata de 04/09: desenhar no
sítio que ninguém vê.

**Resultado medido:** a praia é **27% da costa visível** (139 px ao norte, 233
ao sul, contra 982 de cais) e ocupa **2,9% da tela em areia** mais **8,2% em
restinga** — que antes eram asfalto de pátio e avental de concreto.

**A paleta sai da tabela de referência, mas só o tom seco.** `areia`
(`#e8d9a8`) é o valor AMOSTRADO; o pé da rampa (`#bda06a`) sai dele pela razão
de valor que o concreto do cais já usa (0,75 contra os 0,67 do `cais_dir`).
Amplitude da rampa **54,4** de luminância, contra 64,5 do cais que ela
substitui — mais rasa de propósito, porque areia é difusa e concreto tem face.

**E a espuma continua a ler-se, que era o risco desta etapa.** Traço claro
sobre fundo claro foi o que achatou a água em 02/09, e aqui a espuma passou a
cair sobre areia em vez de sobre água: medido, Weber **0,52** sobre o pé da
rampa contra **0,40** sobre o baixio. Melhorou.

**Três coisas que só a captura mostrou**, e as três estão no `CLAUDE.md`:

1. **Recuar um contorno não é `costa_deslocada` com o sinal trocado.** Aquele
   empurra cada vértice na diagonal, e ao longo do muro isso desloca também o
   `my`: a crista saía 1,3 unidade adiantada da linha de água e abriu-se um
   **triângulo de água funda dentro da terra**, no fim do cais.
2. **A praia por degrau parte-se em duas.** A primeira versão desenhava uma
   praia por degrau e a ponta sul saía como duas rampas soltas com um degrau
   verde a pique entre elas. A praia acompanha o CONTORNO, e é isso que a faz
   virar a esquina — a mesma lição que o `costa_deslocada` já traz escrita.
3. **Três tons na rampa eram um a mais**, e o baixio de areia não é areia
   misturada com água: pintar `#d8cb9c` a 0,40 sobre a água dá um azeitona
   que mede 0,06 de Weber contra o baixio e lê como lama.

**O que guarda isto:** o bloco **D15** do `teste_design.gd`. Ele confere que
nenhum prop pisa a areia, que só coqueiro fica no `my` de uma praia, e que
cada ponta tem **mais de 100 px** de costa dentro da janela — a lição da mata
posta como asserção. Quatro defeitos foram injetados e os quatro reprovaram,
incluindo o `PONTA_SUL = 24` da tabela acima, que reprovou com os 49 px.

**O que NÃO ficou:** um **coqueiro na ponta norte**. A referência pede "pedras
e coqueiros" e a ponta sul tem o dela, movido para a restinga; a norte não
cabe, e isso é geometria e não gosto — o coqueiro é prop e tem a copa 110 px
acima da âncora, e a restinga norte inteira cai a menos de 92 px do topo do
quadro, então ele sairia decapitado pela barra do HUD. Ela leva árvores baixas
da mata em vez disso, e o próprio gerador as recusa pelo mesmo teste: **3 na
ponta sul, 0 na norte**.

### Etapa 2 — A cauda dos props (barato, muda muito)
- Contêiner: corrugado, cantoneiras, portas, marcação. 2 → ~14 peças.
- Caixote: ripas, cinta, marca estampada. 2 → ~10.
- Boia e marcador: corrente, argola, faixa refletiva. 2 → ~6.
- Props novos: caminhão, empilhadeira, poste (o `poste_de_luz` do kit já
  existe e ainda não é usado), cabeço avulso, pilha de caixotes.
- **Mede-se por:** `folha_de_contato` dos props, e contagem de peças.

#### ✅ FEITA em 02/09 — em duas metades, e a segunda desmentiu os números acima

**A primeira metade já estava feita e este documento não o dizia.** Os cinco
"props novos" existem desde 31/08, em `blender/brp_porto.py`, cujo cabeçalho
diz por escrito que serve esta etapa: caminhão (24 peças), empilhadeira (16),
pilha de caixotes (9), cabeço (3) e poste (3), mais oito que a lista nem
pedia — pallet, pneus, cone, barreira, bote, guincho, poste de luz e doca de
concreto. Quem abrir esta etapa outra vez começa pela metade que falta.

**A segunda metade ficou agora, e os números do plano NÃO SE APLICAM a ela.**
O "~14 peças" foi escrito para o prop `conteiner` AVULSO, de 2,4 unidades, que
saiu do projeto em 31/08 (a razão está no comentário do `grupos` em
`gerar_props_iso.py`). O que restou é a carga do convés do píer, e ela é
pequena. Medido antes de desenhar:

| | peças antes | tamanho na tela | peças agora |
|---|---:|---|---:|
| contêiner do convés | 2 | **46 × 38 px** (face comprida: 31 px) | **13** |
| caixote (os dois) | 1 cada | 25 × 24 e 23 × 21 px | **3** cada |
| boia | 2 | 20 × 22 px | **4** |
| marcador | 2 | 16 × 40 px | **5** |

Catorze peças numa face de 31 px dão 2,5 px cada, que é a regra da lixa do
`DESGASTE` com outra roupa. O que entrou foi pouca peça com VALOR diferente:
quatro chapas de laranja escuro no lugar de doze vincos, cantoneiras de metal
nos cantos (o canto escuro é a assinatura de um contêiner, e escuro lê-se a
3 px onde uma linha não se lê) e a porta em azul — o azul estava numa faixa de
1,6 px debaixo da caixa, onde ninguém o via.

**Três armadilhas, todas achadas OLHANDO e nenhuma pela suíte** (estão no
`CLAUDE.md`): faces coplanares dão um buraco preto; peça dentro de outra conta
no contador e não aparece no render; e prop da cor do chão onde pousa
desaparece — o caixote era `madeira` num tabuado de `madeira` e, ao ganhar
tampo e cinta, saiu parecendo um banquinho.

**O que NÃO ficou:** as "ripas" e a "marca estampada" do caixote. A peça tem
25 px de largura e 11 px de corpo; três tons empilhados nesses 11 px viram
listras, e foi o que a primeira tentativa produziu. O que funciona a esta
escala é o idioma que o `pilha_caixotes` já mediu — silhueta múltipla com tons
diferentes —, então o caixote passou a ser duas caixas tortas em madeiras
distintas, e não uma caixa listrada. **O contêiner é o ganho claro desta
metade; o caixote melhorou e continua a ser a peça mais difícil do convés.**

### Etapa 3 — Contorno pelo compositor  ❌ FEITA E REJEITADA em 05/09
- Passe de normal + profundidade, detecção de borda no compositor, espessura
  proporcional à profundidade, composição por cima do beauty.
- **Media-se por:** o guindaste. Se a treliça continuar vazada, funcionou.

#### Foi construída, foi medida, e a treliça não era a medida certa

O contorno pelo compositor está escrito e funciona
(`ligar_contorno_compositor`, atrás de `--contorno`). Sobel na normal para os
vincos, Sobel no Z mapeado para a silhueta, o máximo dos dois, rampa de
limiar, e — a peça-chave — multiplicado pelo alfa do próprio render, senão o
prop ganha um halo escuro em pixel transparente. **Ele fica no repositório
como a PROVA**, que se refaz em vinte segundos; o que não fica é ligado.

**O que se mediu, nas duas peças pelas quais este plano manda medir:**

| | treliça da lança | parede do galpão |
|---|---|---|
| sem contorno | saturação **117,9** | saturação 53,0 · desvio **29,7** |
| traço rente à silhueta | **93,3 (−21%)** | 47,0 · 24,9 |
| traço recuado 2px | 112,1 (−5%) | 46,9 · **25,6 (−14%)** |

**1. Na peça FINA o traço apaga a COR, não a forma — e o critério escrito
media a metade errada.** A silhueta não mudou um pixel: 1133 opacos com e sem
contorno, os vazados todos abertos. Pelo critério da etapa, *funcionou*. E a
lança saiu de LARANJA a castanho: os montantes têm 2px, o Sobel dá 1px de
traço de cada lado, e a peça inteira virou traço. O Freestyle fechava o
vazado; este descolore. Recuar o traço 2px para dentro da silhueta salva a cor
(−5%) — e, salvando-a, deixa a lança exatamente como estava. **Na peça fina o
contorno ou estraga ou não existe.**

**2. Na peça GRANDE o traço redesenha o que o desenho já dizia — e é aqui que
a etapa morre, por uma razão que não é de técnica nenhuma.** Este projeto
desenha o detalhe COM fronteiras de valor: o corrugado do contêiner, o do
armazém, as fiadas do telhado, as cantoneiras. É decisão registada e é por uma
razão medida — a essa escala o relevo não sobrevive ao antisserrilhado. Um
filtro de borda procura exatamente fronteiras de valor. Ele encontra o desenho
e desenha-o outra vez por cima: a chapa corrugada, que é uma superfície com
nervura, passa a ler-se como um gradeado, e **o desvio local da parede — que é
a textura dela — CAI 14% em vez de subir**.

**3. E o trabalho já estava feito por outra peça.** O rig de três pontos do
`preparar_cena()` tem um contraluz cujo comentário, escrito na Etapa 2, diz o
que ele é para fazer: *"põe um fio de luz na quina de cima, e é esse fio que
separa a peça do fundo — faz o trabalho de um contorno desenhado sem ter de
desenhar contorno nenhum"*. Ele separa a silhueta **sem tocar nas fronteiras
de valor de dentro do prop**, que é precisamente o que o contorno não
consegue. A linha da §2 que dizia "contorno de silhueta: não" estava a
comparar o jogo com a referência olhando a técnica em vez do efeito.

**O Freestyle foi apagado nesta passagem.** Ele estava atrás da mesma flag,
rejeitado desde 30/08 e sem chamador; manter duas implementações rejeitadas
por trás de um argumento só é convite a alguém ligar a errada.

### Etapa 4 — Materiais dirigidos  ✅ FECHADA em 05/09, com uma baixa
- Família de padrões: ripa, corrugado, fiada de telha, ferrugem que escorre
  de cima para baixo, cal descascada nas quinas.
- **Mede-se por:** o galpão a 100% e a 25% — padrão que só funciona de perto
  não serve.

#### Os cinco padrões, e onde cada um foi parar

| Padrão | Onde ficou | Como |
|---|---|---|
| **corrugado** | parede e telhado do armazém (05/09) | **peça**, não material — `chapa_vinco` em `na_face` |
| **ripa** | convés do píer n2 e laje do n3 | `material_ripado`, junta + tom por tábua |
| **ferrugem que escorre** | casco dos dois cargueiros | `material_escorrido`, ruído esticado em Z |
| **fiada de telha** | já era geometria desde 30/08 | `telhado_duas_aguas` |
| **cal descascada nas quinas** | ❌ **não se faz nesta geometria** | ver abaixo |

**A diferença entre `material_gasto` e um padrão dirigido é uma só, e é a que
dá nome à etapa:** a mancha dele é isotrópica e não sabe onde é em cima.
Ferrugem sabe — ela nasce numa solda e a chuva puxa-a para baixo. Tábua sabe —
ela corre num sentido. Quem faz a anisotropia é o `Mapping`, esticando a
coordenada antes do ruído: a escala do `Noise` é um número só e não sabe
fazê-la sozinha.

**⚠️ E ELES NÃO ENTRAM NA PALETA, ENTRAM PEÇA A PEÇA.** `madeira` veste o
tabuado de 4,5×2,4 e também o caixote de 25px: ripar a entrada da paleta poria
oito tábuas dentro de um caixote. É a regra do `DESGASTE` outra vez, aplicada a
um padrão em vez de a um ruído — e é por isso que o pesqueiro (67px) não
enferruja e os cargueiros (97px) enferrujam.

#### O que a ripa achou: o píer MELHOR parecia menos construído que o pior

Medido antes de desenhar: o convés do n2 é a **maior superfície do jogo** —
4,5 × 2,4, cerca de 138px de silhueta, e aparece três vezes na tela. Ele era
uma chapa lisa de `madeira`, e lia-se como uma folha de compensado. O n1, que é
o pontão provisório, gasta geometria em nove ripas com fresta. Ou seja: o
jogador comprava a melhoria e o convés ficava mais liso.

A laje de concreto do n3 tinha o mesmo defeito, e leva o mesmo padrão com os
números do MATERIAL: painel de 0,90 (18px) em vez de tábua de 0,30 (6px), junta
fina, quase nenhuma variação de tom — concreto lançado em fôrma varia pouco,
tábua serrada varia muito, e é essa diferença que impede os dois píeres de se
parecerem. As juntas correm atravessadas, que é como uma junta de dilatação
corre e evita repetir a direção do tabuado.

**⚠️ Duas coisas que a ripa ensinou, e a segunda custou uma captura:**

1. **O tom por tábua é o que separa isto de um pente.** Riscar linhas escuras a
   passo constante é o que a vila já ensinou a não fazer — *"73% dos vãos
   mediam o VILA_PASSO, e aquilo lia como cerca"*. A junta diz onde uma tábua
   acaba; o TOM diz que são peças diferentes. Ele sai de um `White Noise` 1D
   alimentado pelo ÍNDICE da tábua (`floor`), não pela posição — assim a tábua
   inteira tem um valor só, em vez de um degradê ao longo dela.
2. **Uma rampa de dois pontos não faz junta que sobreviva à escala.** Linear de
   0 a `junta`, ela só chega ao escuro total no último pixel: num passo de 6px
   o que se via no jogo rodando eram bandas de tom, não tábuas. O terceiro
   ponto dá à sombra um PATAMAR — escura de verdade em metade da largura dela.
   É a mesma lição das fiadas do telhado: o que o olho lê a esta escala é a
   sombra ENTRE as peças, e sombra precisa de corpo.

#### ❌ A cal descascada não se faz, e a causa é a geometria de caixa

O caminho óbvio é o nó `Geometry > Pointiness`, que mede convexidade e devia
valer ~0,5 no pano e mais na quina. Só que **ele é um atributo de VÉRTICE**, e
uma caixa chanfrada não tem vértice nenhum no meio da face: estão todos na
aresta. O valor no pano não é medido, é INTERPOLADO dos cantos — não existe
campo plano contra o qual comparar.

**Medido**, a saída crua do `Pointiness` no galpão em ruína: varia de **29 a
181** (0..255), mediana **146**, e **31% da parede acima de mediana+10**. Uma
distribuição larga e contínua, quando o efeito precisa de uma bimodal.
Aplicado, ele pintou a parede INTEIRA de reboco e a ruína — que tinha acabado
de ser refeita — virou um barracão castanho.

Subdividir resolveria em teoria e não na prática: para uma orla de 2px seriam
precisos vértices a cada ~0,1 unidade, e com a densidade que este kit usa o
efeito sai como um vinhetamento de 12px. **Cal descascada, se voltar, vem de
uma coordenada — distância à aresta da própria caixa —, nunca da curvatura da
malha.** A função foi apagada; fica a lição.

### Etapa 5 — Personagem com rosto  ✅ FEITA em 03/09
- Folha de rostos por gerador de imagem, aplicada num plano da cabeça.
- **Mede-se por:** o trabalhador no tabuado, a 22px, no jogo rodando.

#### O que se fez, e por que não foi o que estava escrito

O gerador de imagem **não entrou**, e o motivo é o mesmo que já custou duas
levas de arte: gerador não erra o desenho, erra o ÂNGULO — e uma folha de
rostos colada num plano teria de concordar com uma câmera que o gerador não
conhece. O trabalhador do cartão saiu do MESMO estúdio de tudo o resto
(`blender/brp_porto.py`, `trabalhador_retrato`), o que era exatamente o pedido
do playtest: *"o sprite do trabalhador pode ser refeito para ficar mais de
acordo com o design do jogo"*.

**São dois bonecos, e continuam a ser.** O `trabalhador` do píer tem 22px na
tela e são cinco caixas de propósito; a esta escala mais peça vira ruído. O
`trabalhador_retrato` tem 32×70 no cartão do rodapé, e a 70px cinco caixas leem
como um boneco de LEGO. Mesmo personagem, dois orçamentos de pixel.

**Ele é o único prop que olha para a frente.** Todo o resto do catálogo vive no
mapa e obedece ao 3/4 da câmera; um retrato de 3/4 num cartão de 108px mostra
sobretudo o capacete. A volta foi rodar o boneco 45° em Z — a câmera não muda,
o contrato não muda, e a cara passa a apontar para quem olha.

**Quatro tentativas, e o que cada uma ensinou** (está tudo em comentário na
função, para não se repetir):

1. medidas misturadas — largura em unidades de mundo, altura em pixels — deram
   um PALITO de 429×27, cortado no topo do quadro. Depois da rotação de 45° a
   largura anda 42,4px por unidade, a altura 36,7 e a profundidade 21,2: três
   fatores, e escrever tudo em pixels tira-os da frente;
2. as duas faixas refletivas tinham 70px de largura num colete de 68 e taparam
   o laranja inteiro — o tronco saiu BRANCO. A 32px cada peça tem de ganhar o
   seu espaço contra as vizinhas, não apenas caber;
3. o colete e o tronco tinham a mesma face da frente — duas faces coplanares, o
   z-buffer a escolher ao acaso, e o laranja simplesmente não apareceu;
4. `cone()` pede RAIO e o conversor devolve LARGURA: a aba do capacete saiu com
   116px de diâmetro numa cabeça de 50, e no cartão o boneco aparecia de
   CHAPÉU DE PALHA.

E duas coisas que só a captura no jogo disse, com todas as asserções verdes: o
boneco **enche o quadro** (um `TextureRect` em `KEEP_ASPECT_CENTERED` escala o
PNG inteiro, transparência incluída — com 251px de boneco num quadro de 512 ele
saía com 34px no cartão), e **centra-se pela quina da bota** e não pela altura,
porque em isométrico a quina da frente desce meia profundidade abaixo do pé.

### Etapa 6 — Interface encorpada (NÃO é Blender)
- Gradiente e sombra nos `StyleBoxFlat` do tema, cor por botão na barra
  inferior, contador vermelho nos botões do trilho esquerdo.
- **Mede-se por:** o teste de design (que já cobre alvo de toque e
  sobreposição) mais uma captura.

#### ✅ FEITA em 02/09, e ela corrigiu três coisas desta lista

**1. `StyleBoxFlat` NÃO FAZ GRADIENTE.** Sondado no motor: 31 propriedades,
nenhuma com "gradient" — há `bg_color` (chapado), `shadow_color`, `shadow_size`
e `shadow_offset`. Gradiente exigiria `StyleBoxTexture` com um
`GradientTexture2D`, que perde o `corner_radius` (o nine-patch não tem raio) e
obrigaria a uma textura por raio. Isso desfaz a propriedade que o cabeçalho do
tema declara — *"o ponto único de estilo: mudar cor, canto ou fonte aqui muda a
interface inteira"*. **Não foi feito, e a troca não vale o preço.**

**2. O trilho esquerdo e a barra de SEIS botões não existem neste jogo.** São da
interface da referência, que serve um jogo com mais sistemas. Esta tem DOIS
botões de ação, e com dois a distinção útil não é seis cores: é **primário
contra secundário**. "Avançar dia" ganhou a variação `BotaoPrimario` em âmbar;
"Alocar todos" ficou navy. O `referencias/README.md` avisa que peça que não
responde a uma linha de crescimento fica sem uso — já aconteceu duas vezes.

⚠️ **E o rótulo do primário é NAVY, não branco, porque foi medido.** Branco
sobre o âmbar `#e09a10` dá **2,39:1** de contraste — reprova até o corte de
texto grande da WCAG (3,0). Navy dá **5,27:1** e passa o AA normal. Botão âmbar
com texto branco é o que sai quando se escolhe pelo aspecto.

**3. Dar corpo à interface não é mexer NUM StyleBox — são oito.** Medido pixel a
pixel por faixa da tela, a mudança caiu em dois lugares: os botões de ação (50%
da faixa) e o cartão da parcela (15%). Ficaram intocados o HUD, os cartões de
doca (×4 estilos próprios), os de trabalhador (×3) e a mensagem. O `cartao`
genérico serve muito menos coisa do que o nome sugere.

⚠️ **E os cartões escuros NÃO ganham profundidade por sombra — é física, não
preguiça.** O fundo da barra inferior é `#0d1a26`, luminância **24,1**; a sombra
do tema é navy `#1c3454`, luminância **49,2**. A sombra é MAIS CLARA que o
fundo: aplicá-la ali desenharia um halo. É a mesma lição da água da Etapa 1 —
o contraste depende do fundo, não da tinta. Cartão escuro sobre fundo escuro
ganha corpo por BORDA, e os cartões de doca já a têm. Deixados como estão, de
propósito.

---

## 5. A pergunta do conhecimento de Blender

**Sim, precisa — mas não do jeito que a pergunta sugere.** O que falta não é
"o Claude saber mais Blender em geral". O Blender genérico ele sabe. O que se
perde entre uma conversa e a seguinte é o **conhecimento ESPECÍFICO DESTE
PROJETO**, que é caro de redescobrir e já foi redescoberto mais de uma vez:

- a projeção (60°/45°, `ortho_scale`, altura em pixels do mapa e não em
  unidades do Blender);
- a inversão de sinal em `pos()`, que já pôs um prop 40px fora do lugar;
- a regra de a escala de ruído ser relativa ao tamanho da peça;
- o azimute próprio da sombra de contato (250°, e não o do mapa);
- que o Freestyle foi testado e rejeitado, e por quê;
- que só as faces `+x` e `-y` são visíveis;
- que `--import` é obrigatório num clone novo;
- que o Blender roda aqui via `pip install bpy` e o Godot via download direto.

Isso hoje está espalhado por comentários de código e por três documentos de
briefing. Um comentário só é lido por quem abre aquele arquivo.

**A providência concreta é `CLAUDE.md` na raiz do repositório** — que o Claude
Code carrega sozinho em toda sessão, sem ninguém pedir. Ele foi criado nesta
rodada com exatamente essas regras e com os comandos que funcionam. É a
diferença entre "leia estes três documentos primeiro" e não precisar dizer
nada.

O passo seguinte, quando o pipeline de props crescer mais, é uma **skill** em
`.claude/skills/` para o fluxo de arte (gerar → folha de contato → conferir
projeção → pôr no jogo → capturar). Ainda não vale: uma skill compensa quando
o fluxo repete muitas vezes na mesma sessão, e hoje o `CLAUDE.md` chega.

---

## 6. O que NÃO fazer

Registrado porque cada um destes já custou tempo neste projeto:

1. **Encomendar sprite a gerador de imagem para o cenário.** Duas levas
   perdidas. O gerador não erra o desenho, erra o ÂNGULO, e ângulo errado não
   se conserta rodando no Godot. Retrato em painel, sim; prop no mapa, não.
2. **Mexer na projeção sem rodar o teste de design.** `MEIA_LARG`,
   `ROT_X`/`ROT_Z` e `ESCALA_ORTO` são um contrato entre três arquivos.
3. **Perseguir a pincelada com nó de ruído.** Tem teto, e o teto já foi
   medido em `docs/arquivo/BLOCO5_PROMPTS_BLENDER_RICO.md`.
4. **Densificar sem olhar o resultado no jogo.** Prop bonito na folha de
   contato e ilegível a 25% é trabalho jogado fora — foi o que aconteceu com
   a primeira tentativa de desgaste, que virou lixa.
