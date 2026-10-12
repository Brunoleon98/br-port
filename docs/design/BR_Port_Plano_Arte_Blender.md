# Bloco 7 — Plano para levar a arte ao nível da referência

> Escrito em 30/08/2026, depois de olhar as cinco imagens de referência
> (`docs/design/referencias/`) e de rodar o Blender e o Godot dentro da sessão
> para medir, em vez de estimar.
>
> **A pergunta que este documento responde:** o que falta para o jogo parecer
> aquilo, quanto disso o Blender por script alcança, e o que é preciso
> aprender ou registrar para lá chegar.
>
> **Enxuto em 10/10/2026** (`docs/decisoes/092`): as etapas e as passagens que
> fecharam desceram, título a título, para
> `docs/arquivo/PLANO_ARTE_FECHADOS.md`. Aqui fica o que está aberto — a
> Etapa 7 e as práticas da §7 — e o que não envelhece: o alvo, a distância, o
> que o script alcança e o que não fazer.

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

A contagem de peças por prop **quando esta etapa foi escrita** — e ela
envelheceu, de propósito deixada como está: metade destes nomes já não existe
(`conteiner` e `caixote` saíram em 31/08, `barco_grande` e `barco_pequeno`
viraram seis cascos por serviço) e o `coqueiro_tronco` passou de 2 peças para 7
ao arquear em 16/09 (`docs/decisoes/028`). Quem quiser a contagem de hoje
pergunta ao `tools/gerar_props_iso.py`, que é quem a sabe; o que este bloco
continua a dizer, e que não envelheceu, é **onde estava a cauda**:

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

**E em 23/09 esta lista foi posta à prova contra a prática de fora.** A §7 tem
a pesquisa de boas práticas de Blender para arte estilizada, cruzada com o que
este projeto mediu — e o que dependia de "roda aqui?" foi rodado. Ela achou
duas coisas que esta secção não sabia: o pipeline renderiza pelo **AgX** sem o
declarar, e o rosto redondo **alcança-se por script** (metaball, curva, casco
invertido), com o custo medido.

---

## 4. Ordem de execução

Ordenada por **ganho visível ÷ custo**, e não por gosto. Cada etapa é
verificável — o teste de design e a folha de contato dizem se ficou.

**As etapas 1 a 6 fecharam, e as passagens fora delas também.** A paleta e o
enquadramento (05/09), a cauda dos props (02/09), o contorno pelo compositor
(feito e rejeitado em 05/09, com os números que a §2 e a §3 citam), os
materiais dirigidos (05/09, com a baixa da cal), o rosto (03/09) e a interface
(02/09, com a primeira família da frente 3); e, fora das etapas, a ruína e o
armazém acabado, os três níveis do píer, da lança e do casco, a Zona de
Espera, as duas frotas, a rua de mão dupla, a escala do pátio, o caminhão no
eixo da rua, a vegetação com a areia e a fauna, e os três degraus da animação
com a virada do dia — estes com o que fica «para quem animar a seguir». O texto
de cada uma desceu inteiro para `docs/arquivo/PLANO_ARTE_FECHADOS.md` (`092`).

---

### 🆕 Etapa 7 — A resolução dos assets, e o desenho que ela paga (proposta 14/09)

**Pedida pelo Bruno, e a ORDEM é dele.** A §7 do plano v3 tem o item inteiro,
com as três alavancas, os custos e o portão. Aqui fica só a metade de ARTE: o
que se desenha com o orçamento novo, porque **resolução sozinha compra nitidez
e não detalhe** — um mapa a 1,5× é o mesmo desenho com menos serrilhado.

**O orçamento novo, em número.** A 1,5× cada peça ganha 50% de largura e 125%
de área. O que isso muda é a fronteira que este documento e o `CLAUDE.md` já
mediram dezenas de vezes: **abaixo de ~3 px uma peça não sobrevive ao
antisserrilhado, e abaixo de ~2,5 px ela vira lixa.** A 1,5×, uma peça de 2 px
passa a 3 e uma de 2,5 passa a 3,75 — ou seja, **a faixa que hoje se recusa por
ser pequena demais é exactamente a faixa que passa a caber.**

#### O que se desenha, por família, e de onde sai o número

| Peça | O que falta hoje, e o número que a recusou | O que cabe a 1,5× |
|---|---|---|
| **a vila** | "comércios variados" ficou de fora na `022`: lote de 51 px, parede de 12–15, toldo de 20, vitrine de 4 | lote de **77**, parede de 18–22 — toldo, vitrine, tabuleta e portada passam a distinguir-se de uma casa |
| **o caixote** | as ripas e a marca estampada foram TENTADAS na Etapa 2 e retiradas: 11 px de corpo, três tons viram listras | 16 px de corpo — a ripa volta à pergunta, e desta vez com medição em vez de tentativa |
| **o contêiner do convés** | 14 peças numa face de 31 px dariam 2,5 px cada, então o corrugado virou diferença de VALOR | face de **46 px** — o vinco volta a poder ser relevo, e não só tom |
| **os oito caminhões** | 35–49 px de diagonal, abaixo do portão do filete da `024` | **52–73 px** — entram no portão, e a cabine pode arredondar |
| **os prédios** | a `024` mediu que armazém e escritório são caixas DE VERDADE e ficam quadrados | continuam quadrados — o que ganham é **peça de função**: calha, telha corrida, fita de vidro, degrau de portão |
| **a frota** | a ferrugem só entrou nos cargueiros (97 px) e o pesqueiro (67) ficou de fora por tamanho | o pesqueiro passa a 100 px — a pergunta da ferrugem reabre, com a `014` a dizer que o eixo é o PORTE |

⚠️ **E O QUE NÃO SE DESENHA, MEDIDO** — para a etapa não prometer o que não
paga. As estacas do píer (9×32 → 13×48) continuam esbeltas, e a `024` mediu que
é a esbelteza que as faz medir quadrado, não a secção. A fauna quase não chega:
a gaivota vai de 15 para 22,5 px contra um corte de 24. E o tosado do casco
passa de 1,2 para 1,8 px de tela, ainda abaixo dos 3 em que a régua vê uma curva.

#### ✅ A metade de CONFIGURAÇÃO está feita (14/09), e a de DESENHO continua aqui

`docs/decisoes/025`. O mapa importa a 1,5× desde 14/09: o pico de cada fronteira
subiu **+52,6%** e 5,12% da janela mudou acima do piso de Weber. **Isso é
nitidez, e esta etapa é sobre o que ela PAGA** — a tabela acima continua toda por
desenhar, e cada linha dela é uma sessão própria.

⚠️ **E O ORÇAMENTO NOVO NÃO É O MESMO EM TODO O MAPA.** O campo de cor da água é
um raster de 720×720 embutido no SVG (43% da janela): ali a peça continua a ser
desenhada na escala de ontem até alguém subir o `SAIDA` do gerador, que é sessão
própria. O que ganhou orçamento foi o **vetor** — vila, rua, praia, cais,
telhados, pedras.

#### ✅ E A METADE DE CONFIGURAÇÃO DA **B** TAMBÉM FECHOU (16/09)

`docs/decisoes/029`. Os props passaram a **768 px** dentro do mesmo quadro de
512 coordenadas, e o orçamento de desenho desta etapa está de pé: **as seis
linhas da tabela acima continuam por desenhar**, e cada uma é uma sessão
própria. O que se ganhou já foi medido — pico do gradiente **+31,5%** nos props,
a 1080×1920.

⚠️ **E A ARMADILHA ABAIXO NÃO ERA REAL PARA A B, AO CONTRÁRIO DO QUE ESTE
DOCUMENTO PREVIA.** Ela pressupõe que o gerador escreve nas unidades da SAÍDA;
medido, ele escreve em unidades de MUNDO — o `chanfrar()` usa 0,020, o `TABUA`
0,30 —, e os *"31 px na tela"* dos comentários são observações do que esses
valores produzem. Com o `ortho_scale` preso à escala de TELA, o mesmo desenho é
só amostrado mais fino: 51 dos 61 props medem 0,0059 pelo `comparar_props.py`.

**Ela continua real para o resto desta etapa**, que é onde peça nova se desenha
em pixels do render — e aí a pergunta é a mesma: o que mudou foi o DESENHO ou a
amostragem dele?

⚠️ **E SUBIR A RESOLUÇÃO REVELA GEOMETRIA DEGENERADA.** A gravata do Sr.
Ribeiro era coplanar com a camisa desde 01/09; a 512 os 64 samples misturavam
as duas num vermelho plausível, e a 768 ela saiu partida ao meio. Quem desenhar
peça nova com o orçamento novo deve contar com isto: **o que o antisserrilhado
escondia deixa de esconder.**

#### A armadilha desta etapa — e ela vale para a B, não para a A

⚠️ **A ALAVANCA A JÁ PASSOU E NÃO A ENCONTROU, POR UMA RAZÃO QUE VALE SABER.**
Ela não toca no gerador: o SVG é o mesmo arquivo, e um `stroke-width` escrito nas
unidades do `viewBox` de 1080 mede os MESMOS pixels físicos no telefone antes e
depois. Subir o `svg/scale` remove uma redução; não amplia um desenho. A
armadilha abaixo é real para a alavanca **B** e para tudo o que se redesenhe nas
unidades da SAÍDA — que é o resto desta etapa.

⚠️ **TODO NÚMERO EM PIXEL DESTE PROJETO FOI ESCOLHIDO OLHANDO O RENDER A 720.**
A largura de cada traço do mapa, o passo do tabuado, as fiadas do telhado, a
escala do ruído, a espessura da junta — todos foram calibrados contra o
antisserrilhado da escala de hoje. A 1,5×, um traço de 1 px passa a 1,5 e **um
vinco calibrado para quase desaparecer pode reaparecer**; um ruído escolhido
para ler como textura pode virar sujeira visível.

É a mesma família do *"constante em PIXEL é constante que envelhece quando o
`ZOOM` muda, e ela não dá erro"*, que em 05/09 custou cinco números — dois
reprovavam o que estava certo e **um deixou de reprovar seja o que for**. A
diferença é que ali foi a câmera e aqui é a rasterização, e que agora há muito
mais número em pixel escrito do que havia então.

**Logo esta etapa não é "subir o número e regerar".** Ela é: subir o número,
tirar a bateria, **ampliar e OLHAR peça a peça**, e varrer o gerador à procura
de toda constante medida em pixel para perguntar de que escala ela é. O portão
é o do bote da `024` — se a diferença não se vir no telefone, pára e regista.

**Mede-se por:** a bateria antes/depois com semente e `--fixed-fps` fixos; as
duas folhas de contato ampliadas; e o tamanho do `.ctex`, do APK e da VRAM, que
é o único eixo desta etapa que pode reprovar por motivo que não é visual.

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

---

**A vila ganhou três lotes que não são casa** (13/09, item 12, `022`) — a
passagem desceu para `docs/arquivo/PLANO_ARTE_FECHADOS.md`. Os comércios, que
ficaram de fora por tamanho, estão na tabela da Etapa 7.

---

## 7. Boas práticas de Blender, pesquisadas e MEDIDAS aqui (23/09)

> Pedida pelo Bruno depois de rejeitar os retratos vetoriais (§A5 do plano v3,
> «A FRENTE 2 ABRIU E VOLTOU AO BLENDER»). **Nada disto é asset.** São as
> práticas de quem faz arte estilizada em Blender, cada uma cruzada com o que
> este projeto já mediu — e as que dependiam de "roda aqui?" foram RODADAS, com
> `bpy` 4.5 neste contêiner, na câmera e no rig de `preparar_cena()`, a 768 px e
> 64 amostras. As provas são um manequim cinzento e duas comparações do retrato
> de hoje, fora de `brport_vs/` e fora do repositório. **O que experimentar
> primeiro é escolha dele** (a lição de 23/09 no `CLAUDE.md`, secção Arte).
>
> ⚠️ O manual do Blender (`docs.blender.org`) e o Blender Studio estão
> bloqueados pelo proxy deste contêiner. Onde a afirmação é técnica, a fonte é o
> próprio `bpy` 4.5 — a descrição RNA de cada nó e propriedade —, e as práticas
> vêm da pesquisa, com o link ao lado.

### 7.1 O que a medição achou antes de qualquer prática

**⚠️ O PIPELINE RENDERIZA PELO AgX, E NENHUM ARQUIVO O DIZ.** O
`preparar_cena()` não toca na transformada de vista, e o Blender 4.x dá AgX a
toda cena nova (conferido: `bpy.data.scenes.new(...).view_settings` sai
`AgX`). O AgX foi feito para comprimir altas luzes de fotografia, e a prática
de arte estilizada de cor chapada é renderizar em **Standard** [3][4]. Medido
aqui:

| | AgX (hoje) | Standard |
|---|---|---|
| `#eef2f5` (parede, cabine, esclera, dentes) num plano de EMISSÃO | **191–194** | 238–245 |
| luminância das 48 cores da paleta, emissão, média | **−9,4** | referência |
| amarelos e cremes: `amarelo` · `capacete` · `luz_poste` | −12 · −16 · **−43** | referência |
| p99 de luminância: Cida séria · Ribeiro cordial · caminhão de pescado | **188,8 · 189,8 · 190,3** | 231,5 · 234,5 · 236,4 |
| pixels estourados (≥ 254) nesses três | 0% | **0%** |

**Nenhum prop do jogo passa de ~190 no 1% mais claro**, e o rig não precisa
do AgX para não estourar. A reprodução confere: o AgX desta sonda dá o PNG do
repositório com diferença média de 0,002 a 0,005/255, que é o ruído do
denoiser. Três consequências:

1. **Todo contraste medido em jogo até hoje foi medido ATRAVÉS do AgX** — os
   0,26 de Weber do zinco contra o asfalto, o pau-de-carga na areia, a lança.
   Não estão errados; estão condicionados a uma escolha que ninguém fez.
2. **O comentário do `concreto` promete o tom do `cais_topo` do mapa, e o mapa
   é SVG — não passa pelo AgX.** Em emissão o concreto do prop sai 20 pontos
   abaixo do hex. É «a paleta mente» com uma camada que ninguém tinha contado.
3. **A troca é UMA linha e muda TODOS os PNGs** — os 61 props de mapa e os dez
   retratos, o atlas (dois `--import`), as réguas que leem pixel de prop e os
   números de contraste acima. É decisão do Bruno.

Mesmo mantendo o AgX, vale ESCREVÊ-LO: `view_settings.view_transform = "AgX"`
não muda um pixel e impede que um Blender futuro troque o visual calado — foi o
que a 4.0 fez ao Filmic.

**⚠️ ARREDONDAR O KIT NÃO É UM MODIFICADOR.** A tentação óbvia —
`Subdivision` + `shade smooth` nos doze prismas do retrato — medida na Dona
Cida séria:

- **DEPOIS do chanfro** (a ordem natural: o `chanfrar()` corre no fim de
  `montar()`), muda **1,4%** dos pixels opacos e a cara continua quadrada. O
  chanfro de 0,020 com dois segmentos põe um laço estreito em cada aresta — e
  laço estreito junto da aresta é exactamente o que, em modelação por
  subdivisão, SEGURA a quina [1];
- **ANTES do chanfro**, o busto perde **28,6%** dos pixels opacos, o coque
  descola da cabeça e as placas da cara ficam a flutuar à frente de uma
  superfície que recuou.

A forma redonda tem de NASCER redonda, e as feições têm de ser postas SOBRE a
superfície nova — nunca em coordenadas de uma caixa que deixou de existir.

**O EEVEE não arranca sem tela, e arranca com uma.** Sem `libEGL` o `bpy`
aborta ao renderizar (código 134); sob `xvfb-run` renderiza por Mesa em
software, 40 s no primeiro quadro, quase tudo compilação de shader. Decide as
práticas que só existem nele (o Shader to RGB, P7).

### 7.2 Personagens — os retratos da frente 2

**P1. Cabeça e busto de malha-base REDONDA — metaball convertido em malha,
`Subdivision` e `shade smooth`.** A prática padrão do personagem estilizado é
uma malha-base de formas simples suavizada por subdivisão [1][2]; por script, o
caminho mais curto até ela é o **metaball**, que funde elipsoides numa forma
orgânica e se converte em malha [5]. Medido: converte sem interface, 1.196
vértices na cabeça de prova, **5–6 s de render** a 768 (o retrato de hoje leva
~13 s).
⚠️ **E a superfície sai MENOR do que os raios que se escrevem**: elementos de
raio 0,95 deram uma caixa de ±0,54. A primeira tentativa pôs a boca em
coordenadas supostas e o raio **não acertou na cabeça**; o que funcionou foi
posicionar cada feição por FRAÇÃO da caixa MEDIDA e colá-la por `ray_cast`.
Cruza com a queixa registada, *«faltam detalhes e está muito quadrado»* (o
`_contorno_oitavado` era a única curva do kit), e com o chanfro invisível de
0,4 px: aqui a curva é da escala da peça, 0,3 de mundo. Arrasta o `_K` e o
`_MEIO` (medidos no PNG, remedem-se) e os nove PNGs.

**P2. Forma POR PERSONAGEM, e não chapéu por personagem.** Os três partilham
hoje o `_corpo()` — o mesmo octógono de cabeça e de ombro — e distinguem-se por
cabelo, chapéu e cor; o próprio `brp_porto.py` avisa que *«três chapéus seriam
três etiquetas»*. A linguagem de forma dá o eixo que falta: redondo lê
acolhedor, quadrado lê sólido e fiável, triângulo lê ameaça [6]. Uma leitura
possível do GDD — e a escolha é dele: a Dona Cida redonda, o Sr. Ribeiro
retangular e alto, o Arlindo de ângulos. Com metaballs isto é parâmetro dos
elipsoides, não peça nova: custo zero sobre a P1.
✅ **Feita em 24/09 no kit de CAIXAS, e não em metaballs** (`056`): cada um
tem a sua `Rosto` em `brp_retratos.py` — o Ribeiro retangular e alto, o
Arlindo de ângulos — e o `_corpo()` partilhado saiu.
✅ **E o quarto, o Toninho (`100`, 12/10), trouxe a primeira CÚPULA do kit**:
a cabeça do trabalhador sem capacete, com o tampo do crânio e o cabelo numa
`_cupula` (planta em superelipse, alçado em quarto de elipse) e o grão do
cabelo no material. Seis voltas, todas sobre o cabelo e a camisa
(`art_lab/retratos/toninho/`); a lição que fica para qualquer cabelo curto:
o que lê como capacete é a BORDA DURA, não a falta de relevo.

**P3. Olhos em ESFERA — o olhar vira rotação, a pálpebra vira casca.** Hoje o
olho é esclera e pupila em placas, e o olhar desloca a pupila três pixels. Em
esfera, olhar é girar o olho, e o `cerrado` é uma casca de meia esfera a descer
— contínua, em vez de dois estados. O tamanho do olho é alavanca de carácter:
grande lê aberto, estreito lê desconfiado [7]. Medido: esferas coladas por
`ray_cast`, sem incidente.

**P4. Sobrancelha e boca em CURVA Bézier com espessura.** O `_boca()` diz
*«curva não existe neste kit»* — e existe: uma curva com `bevel_depth` é um
tubo, renderiza no Cycles como qualquer malha, e a expressão passa a ser mover
três pontos de controlo numa tabela como a `_CARAS`.
⚠️ **O `Shrinkwrap` numa curva Bézier desloca só os pontos de controlo**: a
boca de prova saiu como dois riscos verticais pela cara abaixo. Colar cada
ponto por `ray_cast` na superfície AVALIADA (`obj.ray_cast(..., depsgraph=dg)`,
não no objeto avaliado) funcionou.

**P5. Contorno por CASCO INVERTIDO — só nos retratos.** ⚠️ **Reabre uma porta
que o `CLAUDE.md` fecha, e diz-se por quê.** O contorno está fechado por duas
técnicas medidas e por duas razões: (1) na peça fina o traço apaga a cor; (2)
um filtro de borda acha as fronteiras de VALOR com que este estilo desenha o
detalhe e desenha-as outra vez. O casco invertido é um terceiro mecanismo — uma
cópia inflada da malha, de faces viradas, que só aparece onde a silhueta a
deixa ver [8] —, e **não lê valor nenhum**: a razão (2) não se aplica por
construção, e a (1) é de peças de 2 px, não de um busto de 168. Medido na
cabeça de prova: **5–6 px de contorno a 768 (≈1,5 px na caixa de 228), e o
centro da cara intacto** (165 com e sem casco).
⚠️ **E a receita dos tutoriais falhou nos dois sentidos**: `Solidify` com
«Flip Normals» pintou a cara INTEIRA de escuro (19, 22, 29); sem o flip, não
desenhou contorno nenhum — nos dois casos o `Solidify` gera a superfície
original junto com a casca. O que funcionou:

```python
h = cab.copy(); h.data = cab.data.copy(); cena.collection.objects.link(h)
bm = bmesh.new(); bm.from_mesh(h.data)
bmesh.ops.reverse_faces(bm, faces=bm.faces); bm.to_mesh(h.data); bm.free()
d = h.modifiers.new("infla", "DISPLACE")
d.direction, d.mid_level, d.strength = "NORMAL", 0.0, -0.035  # normal p/ DENTRO
# material: Geometry.Backfacing → Mix(emissão escura, Transparent)
h.visible_shadow = h.visible_diffuse = h.visible_glossy = False
```

Contra o cartão claro do painel, quem separa a cara do fundo é o contorno — o
contraluz é branco sobre branco. Decisão dele, por ser porta fechada.

**P6. Standard SÓ nos retratos.** Eles não pousam no mapa, pousam num cartão:
a coerência com os props não os prende. O branco dos olhos e da gola é o que
mais ganha, e a prova lado a lado mostra-o. Uma linha no estúdio dos retratos,
se ele não quiser a troca global.
✅ **Escolhido pelo Bruno em 24/09**, na `quadrada_v3` — e ⚠️ **com a
exposição a −0,35 EV**: a 0 EV a gola e o branco do olho estouravam (54% dos
pixels claros a 255). A troca GLOBAL, nos props, continua por decidir.

**P7. Toon BSDF, ou EEVEE com Shader to RGB — só se ele quiser cel-shading.**
O Shader to RGB é só do EEVEE (*«only supported in EEVEE»*, diz o nó no
`bpy`); no Cycles o equivalente é o Toon BSDF [9][10]. Medido: o Toon BSDF
funciona, mas com o rig de três pontos a cara ganha TRÊS terminadores e sai
manchada. O cel-shading de ofício ilumina com UMA chave e governa a sombra da
cara transferindo as normais de uma forma simples, uma esfera, pelo
`Data Transfer` [11]. É um ESTILO, não um conserto: fica atrás das outras.

**P8. Shape keys para bochecha e maxilar.** Depois da P1: o sorriso que sobe a
bochecha, a boca que abre. Faz-se por script, mas numa malha de metaball sem
topologia pensada a seleção é por distância, com decaimento. Médio; fica para
quando as P1–P4 tiverem sido vistas.

**Não recomendadas agora:**

- **Troca de TEXTURA das feições** — a técnica de Animal Crossing e Wind Waker
  [12]. Existe para trocar a expressão em TEMPO REAL numa malha só; aqui cada
  expressão já é um PNG, e o que sobraria é desenhar as feições em 2D e
  projetá-las — a vizinhança do que foi rejeitado a 23/09. A P4 dá a curva em
  3D.
- **Escultura e textura pintada**: mão, não script — a §3 já o diz.
- **Grease Pencil**: desenho 2D sobre o 3D, com contexto gráfico que não se
  mediu aqui, e outra vez desenho vetorial.

### 7.3 Props e cenário

**C1. Declarar a transformada, e decidir AgX × Standard** — a 7.1. Global.
✅ **Declarada em 24/09** (`COR_PADRAO` no estúdio, AgX); a escolha nos props
continua do Bruno. Nos retratos é Standard a −0,35 EV (`055`).

**C2. Gradiente VERTICAL por coordenada — o pé do prop mais escuro.** Escurecer
a base e clarear o topo agarra a peça ao chão e é marca da arte estilizada de
jogo [13]. Aqui não pede pintura de vértice: `Texture Coordinate > Object` → Z
→ `ColorRamp` a multiplicar a cor. Só cinco props têm sombra de contato
(`SOMBRA`); esta é a que os outros não têm. **Não medido**: mede-se como a água
mediu — amplitude de luminância antes e depois, e Weber contra o chão de cada
um na folha C.

**C3. Desgaste de QUINA pelo nó Ambient Occlusion com `inside`.** A cal
descascada morreu no `Pointiness`, que é atributo de VÉRTICE (Etapa 4). O nó AO
do Cycles com `inside` traça raios para DENTRO da peça (*«Trace rays towards the
inside of the object»*), por AMOSTRA de render. Medido numa parede do tamanho
da do galpão, chanfrada como o kit: **a face fica a 255 e a faixa da quina
desce a 174, com 5,7% dos pixels abaixo de mediana − 40** — a distribuição
bimodal que o `Pointiness` não dava (na mesma caixa, 198–201, plano). A Etapa 4
deixou escrito *«se voltar, vem de uma coordenada»*; esta é uma terceira via.
Serve a ruína, que a frente 4 pede com *«mais desgaste»*. ✅ **Usado na
ruína** (`074`, `material_alvenaria_velha()`): com 8 amostras o render do
prop não se mexeu além do ruído (5,5 → 5,1 s no galpão). ⚠️ Somar ruído à
oclusão contorna TODAS as arestas; a lasca é o produto das duas máscaras.

**C4. Metaball para o que é orgânico** — copa, pedra, fauna. As razões da P1,
nas peças que hoje são cone e caixa; a régua de silhueta (`024`, `028`) diz se
passaram a ler redondo. Médio.

**C5. Nó Bevel** (*«only supported in Cycles»*) arredonda a quina no
SOMBREADO, sem geometria. ⚠️ Não muda a silhueta — não mexe no que a `024`
mede — e o fio de luz na quina já é trabalho do contraluz. Ganho pequeno; não
medido.

**Não se aplicam aqui, e pela mesma razão — o jogo não mostra MALHAS, mostra
PNGs:**

- **Weighted Normals / Harden Normals** [14] sombreiam o bisel de uma malha de
  jogo em tempo real; aqui o bisel tem 0,4 px e o Cycles sombreia a geometria
  que há.
- **Trim sheets** [15] poupam memória e chamadas de desenho num kit modular em
  tempo real, e o detalhe delas é PINTADO. A VRAM daqui é o atlas dos PNGs
  (`049`), e o equivalente procedural já existe — `material_ripado`,
  `chapa_vinco`.
- **AO cozido em cor de vértice** [13] é o AO barato de quem não pode traçar
  raios em jogo; o Cycles traça-os em cada render.

### 7.4 Por onde começar — a proposta, por ganho ÷ custo

| # | O quê | Ganho | Custo | Arrasta |
|---|---|---|---|---|
| 1 | Escrever a transformada; o Bruno escolhe AgX ou Standard | global | uma linha | com Standard: todos os PNGs, o atlas, os contrastes medidos |
| 2 | **Um retrato só** — P1 + P2 + P3 + P4, na pose e na tabela de hoje, julgado na caixa de 168×228 ao lado do atual | o maior da frente 2 | uma sessão | `_K`, `_MEIO`, um PNG |
| 3 | P5 (contorno) e P6 (Standard nos retratos) sobre esse mesmo retrato, um de cada vez | médio | baixo | nada fora dele |
| 4 | Os outros oito retratos | — | médio | os nove PNGs |
| 5 | C3 na ruína, C2 num prop | médio | baixo a médio | cada PNG tocado |
| 6 | P7, P8, C4 | depende do estilo | médio | — |

### 7.5 O retrato: refinamento, com outros jogos por referência (23/09, segunda leva)

> Pedido do Bruno depois da primeira leva: *«o retrato pode ter um refinamento
> melhor — busque possíveis melhorias e depois pesquise como podem ser
> aplicadas; pode usar modelos de outros jogos como inspiração»*. Continua a ser
> pesquisa: as provas são o MESMO manequim neutro da 7.2, uma prática de cada
> vez, medidas **na escala do jogo** — o PNG de 768 inteiro reduzido a 228/768 e
> recortado a 168×228, que é o que o `TextureRect` em `COVERED` faz num telefone
> de 1080. Nenhum retrato do jogo mudou.

**A régua da escala, medida primeiro.** Hoje o olho do Sr. Ribeiro ocupa
**~19 × 12 px** nessa caixa, e o busto 149 dos 168 de largura. É esse o
orçamento: uma peça de 2 px vê-se, uma de 1 px perde-se no antisserrilhado.

#### O que os outros jogos fazem, e o que cada um ensina aqui

| Jogo | O retrato | O que se tira dele |
|---|---|---|
| **Stardew Valley** | várias expressões por personagem, trocadas pela fala; os mods de retrato mais expressivos mexem OMBROS e CABEÇA, não só a cara [16] | é a lição da pose do `CLAUDE.md`, com uma alavanca que o kit ainda não tem: **o ombro** (encolher, avançar o peito) |
| **Animal Crossing** | cabeça grande, olhos grandes, tudo redondo e simples — a simplicidade deixa o jogador completar o resto [17] | a P1 (forma redonda) e o **contrário da densidade**: poucas feições, todas legíveis |
| **Two Point Hospital / Campus** | 3D com ar de plasticina; o boneco do jogo é simples por ser pequeno, e o de arte-chave é o mesmo polido [18][19] | é exactamente a divisão daqui — o `trabalhador` de 22 px e o retrato de 168. A plasticina lê-se por forma MACIA; o acabamento dela (brilho curto sobre mate) é leitura minha, não medida |
| **Anno 1800** | retratos 3D feitos por estúdio (modelados e animados) para as personagens de diálogo [20][21] | retrato de diálogo é peça de ESTÚDIO, com luz própria; uma **placa de cor por personagem** atrás do busto é a ideia que daqui se tira — e é interface (frente 3), não Blender |
| **Hades** | silhueta forte, contraste de cor forte, traço de tinta [22] | a P5 (contorno) e a **cor de identidade** por personagem |
| **Pixar / cinema** | o olho tem córnea, íris e BRILHO; olho sem brilho lê-se sem vida — ou como vilão, que é por isso que o cinema o apaga nos antagonistas [23][24] | o **brilho no olho**, e a decisão de quem o tem (o Arlindo pode não o ter) |

#### As práticas, medidas no manequim (ganho em pixels da caixa do telefone)

| Prática | Como, por script | Medido | Leitura |
|---|---|---|---|
| **Brilho no olho** | esfera de EMISSÃO de 0,24 do raio do olho, em cima e do lado da chave — fixa, não depende de a luz calhar num reflexo | ponto branco de **2–3 px** por olho; lum. **211** com força 1 pelo AgX, **250** com força 4, **255** em Standard com força 1 | o de maior ganho por custo; **funciona também no kit de hoje** (uma placa de emissão na pupila) |
| **Forma por personagem** (P2) | `Lattice` de 2×2×4 aplicada ANTES das feições: alarga o maxilar ou afina o queixo | maxilar **94 → 108 px** (quadrado) e **94 → 78** (triângulo); **12–14%** da caixa muda | a maior mudança de silhueta depois do cabelo |
| **Mechas de cabelo** | curvas Bézier com `bevel_depth` e raio por ponto (afilam), pousadas por raio de CIMA | **21%** da caixa muda | o cabelo é metade da silhueta; poucas mechas gordas (grande-médio-pequeno [25]) |
| **Pálpebra como casca** | meia esfera 12% maior que o olho, girada para a frente, na cor da pele | esclera visível **143 → 60 px (−58%)** | substitui o `cerrado` de dois estados por uma alavanca contínua |
| **Rubor** | cor por coordenada de OBJETO: distância a dois pontos da bochecha, sem pintar textura | 1,2% da caixa, Δ médio 18/255 | subtil e visível; calor sem desenho |
| **Sorriso por shape key** | bochechas sobem com decaimento (numpy sobre os vértices) + a curva da boca | 0,6% da caixa | quem faz o sorriso é a CURVA; a bochecha soma pouco a este tamanho — a pose continua mais forte |

⚠️ **E DUAS PRÁTICAS DA PESQUISA NÃO SE APLICAM, MEDIDO.**

- **Subsurface para a «sombra quente»**: a sombra da pele JÁ É quente neste
  rig — no manequim o matiz da sombra é igual ao da luz (26,4° contra 26,6°) e
  mais saturado (0,58 contra 0,48); na Dona Cida e no Sr. Ribeiro de hoje ela é
  até mais vermelha (23° contra 26–28°). O subsurface não a aquece (26,5° →
  26,7°): **achata** — a amplitude de luminância cai de 74 para 60 — e custa
  **+86%** de render (10,3 → 18,6–19,3 s, corridas emparelhadas).
- **Enchimento quente**: trocar a cor da luz de enchimento mexe **no máximo
  13/255** e em nenhuma sombra da cara — ela quase não chega ao rosto. A
  primeira medição deu números IGUAIS à base até à décima, e só a diferença
  pixel a pixel (24.104 pixels, Δ máx 13) provou que a régua não estava muda.

**⚠️ E O AgX LAVA A PELE CLARA NA LUZ.** No Sr. Ribeiro (`pele_clara`) a
saturação da pele iluminada é **0,34** pelo AgX e **0,44** em Standard; na Dona
Cida (`pele_escura`) quase não muda (0,62 contra 0,59). É o «cinzento» da cara
dele, e soma-se à razão da P6.

**⚠️ NESTA CÂMERA, O QUE AVANÇA DA CARA DESCE NA IMAGEM — o nariz tapa a
boca.** A câmera olha de cima, e profundidade vale meia altura na tela (a regra
da gola, no `CLAUDE.md`). No manequim, um nariz de raio 0,22 escondeu a boca
inteira, e a primeira folha saiu com a boca no queixo; com 0,15 ela aparece. É
provável que seja por isso que o kit de hoje desenha o nariz como PLACA de
sombra: nariz saliente pede boca mais afastada, ou nariz pequeno.

**⚠️ E A SUPERFÍCIE DO METABALL ENGANA OUTRA VEZ.** As mechas falharam duas
vezes antes de pousar: o raio vindo de cima passava ao lado da testa, que é
mais estreita do que a caixa. O remédio é o da P1 — frações da caixa MEDIDA —,
e recuar para o meio quando o raio falha.

#### O que isto muda na proposta da 7.4

Passa a haver um **degrau zero**, que não precisa de cabeça nova: **brilho no
olho + Standard nos retratos**, aplicados aos nove retratos DE HOJE. São
duas mudanças pequenas no estúdio, e mudam só a caixa do retrato (medido em
23/09: as seis fotos com cara mudam apenas nos 112×152 dela). O retrato redondo
da 7.4 continua a ser o passo seguinte, agora com a lista inteira: P1 + P2 +
P3 + P4 + brilho + pálpebra + mechas, e o ombro por medir.

#### ✅ O Bruno escolheu o retrato redondo (B), e a candidata existe

**`art_lab/retratos/cida_seria/v1/`** — a Dona Cida séria, pelo MESMO
estúdio (câmera, rig, paleta e AgX de hoje), com tudo da lista acima menos o
ombro. Seis tentativas até ela, e cada uma deixou uma lição no script: a cabeça
saiu em PERA, as mechas penduraram-se na testa, a gola saiu uma boia, a cabeça
flutuou sem pescoço, a boca leu-se como bigode e a sombra dos óculos desenhou
um segundo aro. Na foto do jogo, numa cópia, muda **1 foto em 31** — o
`boletim` — e só na caixa do retrato. O aceite é dele, e a pergunta que ele
arrasta também: o Sr. Ribeiro, o Arlindo e o trabalhador do rodapé continuam
de caixas.

#### ✗ A v1 foi rejeitada, e a v2 refá-la (23/09)

O Bruno marcou os quatro defeitos que a leitura da v1 apontava — **nariz e
boca** (ainda um bigode a 168 px), **tronco** (um balão com calombos),
**gola** (dois discos) e **cabelo e lápis** (um capacete com espetos; o lápis
a flutuar) — e pediu para **melhorar o modelo como um todo**. A pergunta da
oficina ficou para depois da v2. A candidata é
**`art_lab/retratos/cida_seria/v2/`**, pelo mesmo estúdio e o mesmo AgX; na
foto do jogo muda outra vez só a caixa do retrato do `boletim` (1 em 31).
O que ela ensinou e vale para os próximos retratos:

- **Peça que avança e sombreia outra sai da malha e deixa de projetar
  sombra.** O nariz como elipsoide da cabeça deitava a sombra da chave (1,6°)
  em cima da boca; à parte, com `visible_shadow = False`, continua sombreado
  e não suja nada. É o mesmo remédio dos aros dos óculos.
- **Uma casca que se corta apagando vértices sai SERRILHADA.** A linha do
  cabelo mostrava a escada dos triângulos na testa. A casca tirada da própria
  cabeça passa a ENTRAR na pele numa faixa estreita (afastamento de negativo
  a positivo), e a borda é a interseção de duas superfícies lisas.
- **Cabelo preso é casca colada ao crânio, não bola**: a bola cortada por um
  plano lia como capacete. E sulco que se pousa por poucos pontos levanta-se
  entre eles — os espetos da v1; os sulcos da v2 são deslocamento da própria
  casca, meridianos à volta do eixo do coque.
- **Tronco com ombro sai de ANÉIS de superelipse**, não de elipsoides
  fundidos: cada elipsoide deixava a sua bossa, e o expoente do anel decide
  a quina do ombro (2 é elipse, ~3 já tem ombro).
- **Retalho pousado por raio estica-se onde a superfície fica a pique** — a
  gola que subia pelo pescoço saiu em listras; o pé da gola é uma fita à
  parte.
- **Pousar pela tangente só serve num casco convexo**: o lápis atravessou a
  orelha, que é uma bossa. E **posição de feição mede-se na IMAGEM**: a
  sobrancelha «reta» na tabela saiu zangada, e a boca a 0,42 do caminho
  nariz→queixo saiu a dois terços dele — o que avança desce, o queixo recua.
- **O enquadramento mede a cabeça COM o coque**: coque no alto encolhe a cara
  na caixa. E o ruído de desgaste do kit, num tecido, lê como mancha.

#### E a quadrada melhorada, para ele escolher o modelo (23/09)

Com a v2 à frente, o Bruno pediu *«uma versão melhorada da Dona Cida quadrada,
para ver qual modelo escolho para melhorar»*. É
**`art_lab/retratos/cida_seria/quadrada_v1/`**: a oficina de CAIXAS (prismas
oitavados, placas, sombreado chapado, o `chanfrar()` do kit), com tudo o que
não é forma partilhado com a v2 — o estúdio, o enquadramento, os materiais sem
ruído, o brilho no olho, a gola de pontas. Contra o retrato de hoje: a cabeça
deixa de ser um moai (156 × 158 em vez de 174 × 148), o olho de robô ganha
íris, brilho e pálpebra, o cabelo-vaso passa a calote com mechas até ao coque,
e o pedestal passa a tronco com ombro. No jogo muda outra vez só a caixa do
retrato do `boletim`. O que ela ensinou:

- **O olho do kit ganha vida com placas**: íris colorida, pupila, brilho de
  emissão e pálpebra — o §7.5 já dizia que o brilho «funciona também no kit de
  hoje».
- **Uma malha por anéis FACETADA (sem subdivisão) é o `prisma` com mais
  andares**: dá o ombro sem sair da gramática de caixas.
- **Quando uma correção não muda NADA na imagem, a peça está errada, não o
  número.** Uma pala clara na linha do cabelo resistiu a três mudanças na
  calote; escondidas peça a peça, as três prévias mostraram-na igual — era a
  quina do crânio de tampo chato a furar o cabelo em rampa.

#### ✅ O Bruno escolheu a QUADRADA, e a v2 dela tem os ajustes (24/09)

Entre as duas, ele escolheu a quadrada para melhorar e pediu mudanças nos
quatro pontos da leitura — cabelo, óculos, tronco e rosto. A candidata é
**`art_lab/retratos/cida_seria/quadrada_v2/`**: mechas que convergem para o
coque e nascem da calote, têmporas com cabelo, coque numa bola só, óculos
oitavados finos, tronco de 12 lados com ombro, carcela e bolso, cabeça mais
baixa com olho maior e aberto e queixo com volume. No jogo muda outra vez só
a caixa do retrato do `boletim`. O que ela ensinou:

- **Com o enquadramento medido pela cabeça, mexer na altura dela mexe no
  tamanho de TUDO o resto**: encurtá-la 12 ampliou o busto 11%.
- **Um ombro não é uma curva contínua**: anéis a alargar por igual deram um
  sino (o balão da redonda, com facetas). Trapézio, prateleira e deltoide.
- **Uma faixa que acaba numa aresta viva acende-se**, e cinco em fila leem
  como uma borda. Afinada até zero, ela nasce da superfície.

#### E a quadrada v3, com as cores escolhidas (24/09)

Sobre a v2 ele pediu mais ajustes nos mesmos quatro pontos e escolheu
**Standard nos retratos** (P6). A candidata é
**`art_lab/retratos/cida_seria/quadrada_v3/`**: cabelo repartido ao meio com
a calote no tom de sombra por baixo das mechas, sobrancelhas em arco
castanhas, nariz em cunha, lábio de cor, tronco 12% mais estreito. No jogo
muda outra vez só a caixa do `boletim`. O que ela ensinou:

- **O Standard pede a exposição**: a 0 EV, 54% dos pixels claros estouravam;
  a −0,35 EV, zero, com o p99 a 239 e a saturação da pele igual.
- **O cabelo precisa do degrau abaixo, como a pele**: com a calote no tom das
  mechas as frestas acendiam-se como elas, e a rampa lia como uma placa.
- **No kit, `inclina` positivo à esquerda baixa a ponta de DENTRO** (é o
  «franzida»): um arco de sobrancelha pede o sinal contrário.

#### ✅ Aceita e no jogo (24/09) — a `055`

O Bruno aceitou a `quadrada_v3` na foto do jogo. O código foi para o estúdio
(`blender/brp_retratos.py`, que o `retratos_de_fala` chama para a Dona Cida)
e as três expressões dela estão em `brport_vs/`, em Standard a −0,35 EV. A
decisão é a **`055`**. Na passagem apareceu mais uma armadilha: **com o
enquadramento MEDIDO, a pose entra depois dele** — com a cabeça já inclinada
na medida, o busto inteiro mudava de sítio de uma expressão para a outra. O
passo seguinte é o Sr. Ribeiro e o Arlindo no mesmo kit, e o trabalhador.

#### ✅ Os três no kit afinado (24/09) — a `056`

A contente da Dona Cida lia como ESPANTO (boca aberta, sobrancelha erguida) e
passou a sorrir de boca fechada e com os olhos. O Sr. Ribeiro (quatro voltas)
e o Arlindo (seis) estão no mesmo kit, cada um com a sua `Rosto` e o
enquadramento medido pela SUA cabeça — à escala da Dona Cida a cara dele saía
pequena. O caminho, volta a volta, está em `art_lab/retratos/ribeiro/` e
`arlindo/`. O que as voltas ensinaram e vale para o próximo retrato:

- **Numa câmera de cima, o cabelo de um careca só se vê se passar acima do
  crânio NA IMAGEM**: o que está atrás sobe. A ferradura do Ribeiro sobe da
  têmpora à nuca e espreita só atrás.
- **Dois sulcos do nariz à boca desenham parênteses**: a boca lia como a de
  um boneco de ventríloquo. E o lábio largo e escuro é uma prateleira.
- **Um tom contrário a alternar lê como pente ou lâminas**: o fio do cabelo e
  do bigode desenha-se pela sombra entre placas do mesmo tom.
- **A pala maior desce sobre as sobrancelhas** (avançar é descer), e o boné
  puxado para trás resolve isso e o tampo grande de uma vez.
- **Haste e cepo sozinhos são uma cruz**: a âncora é o U dos braços.
- **Quando tirar a peça suspeita não tira a queixa, a peça é outra**: o
  «colar azul» do Arlindo era o tampo do tronco, não o pé de gola.
- **As caras saem da FALA que acompanham**: a pressão do Arlindo é um meio
  sorriso frio, a grave do Ribeiro é triste.

E o **trabalhador do rodapé** (`058`), em busto, seis voltas — as lições que
valem além dele:

- **Roupa que passa o ombro é UMA superfície**: painel, alça e faixa como
  placas empilhadas leem como «vários pedaços colados», e encostadas deixam
  camisa no meio. O `_envolver` lança os raios em leque de um eixo, das
  costas por cima do ombro até à frente.
- **Um quadrado claro com miolo escuro num capacete é uma LANTERNA**: o
  adesivo é um decalque oval e chato, com uma faixa em vez de um miolo.
- **Elipse justa não cobre as quinas de uma cabeça quase quadrada**: com o
  casco à medida, as quinas do crânio furavam a aba. O crânio arredonda onde
  o capacete o tapa.
- **Cabelo no valor da pele em meia-sombra lê como sombra**: debaixo de uma
  aba, o cabelo curto vai ao degrau mais escuro e sai da cabeça.
- **Busto de quem se identifica pela roupa é mais aberto**: a cabeça a 56% do
  quadro, não 60%, e o tronco sobe — senão a faixa de baixo sai cortada.

E as **30 variações dele** (`059`), três voltas em
`art_lab/retratos/trabalhador_variacoes/` — as lições que valem além delas:

- **O que diz «mulher» a 70 px é o cabelo que EMOLDURA a cara**, não as
  feições: com maxilar, sobrancelha e lábio ela lia como ele. Debaixo de um
  capacete, o cabelo que se vê é o que cai dos lados.
- **Uma peça estreita e paralela às faixas lê como mais uma faixa**: o rabo
  de cavalo era uma alça do colete até engrossar onde nasce, curvar e ganhar
  um prendedor.
- **Pelo facial é forma, não mancha**: uma placa escura sobre a boca é sombra;
  uma barba só nas quinas e no queixo é uma faixa (grisalha na pele preta lia
  como a jugular do capacete) — a frente da bochecha vai junto.
- **Uma casca contínua desde a aba é um capuz**, por mais que ondule; o crespo
  lê pela silhueta recortada dos cachos, e atrás do plano da cara.
- **Na pele funda o `vao` quase não separa**: medido, a boca deu 0,42–0,59 de
  Weber contra 0,75–0,91 nas outras; as feições vão ao preto do cabelo.

### 7.6 Fontes

1. Blender Studio, *Stylized Character Workflow — Base Meshes*: <https://studio.blender.org/training/stylized-character-workflow/base-meshes/>
2. CG Cookie, *BASEMESH: Create Stylized Characters Quickly with Blender*: <https://www.cgcookie.com/courses/basemesh-create-stylized-characters-quickly-with-blender>
3. CG Cookie, *The Secret to Rendering Vibrant Colors with AgX*: <https://blog.cgcookie.com/posts/the-secret-to-rendering-vibrant-colors-with-agx-in-blender-is-the-raw-workflow/>
4. StraySpark, *How to Get an Anime / Toon Look in Blender* (Standard para cor chapada): <https://www.strayspark.studio/blog/how-to-get-anime-toon-look-blender>
5. MakeUseOf, *What Are Metaballs in Blender?*: <https://www.makeuseof.com/metaballs-in-blender-what-how/>
6. RocketBrush, *Shape Language in Game Character Design*: <https://rocketbrush.com/blog/shape-language-in-game-character-design-how-to-make-characters-readable-and-consistent>
7. Wikipedia, *Manga iconography* (tamanho do olho e carácter): <https://en.wikipedia.org/wiki/Manga_iconography>
8. Blender Secrets, *Inverted Hull outline in Cycles*: <https://www.3dsecrets.com/secrets/inverted-hull-cycles>
9. Manual do Blender, *Toon BSDF*: <https://docs.blender.org/manual/en/latest/render/shader_nodes/shader/toon.html>
10. Manual do Blender, *EEVEE — Supported Nodes*: <https://docs.blender.org/manual/en/latest/render/eevee/limitations/nodes_support.html>
11. aVersion of Reality, *A Custom Normals Workflow for Clean, Stylized Toon Shading*: <http://www.aversionofreality.com/blog/2022/4/21/custom-normals-workflow>
12. Blender Artists, *How to emulate Animal Crossing's facial expressions?*: <https://blenderartists.org/t/how-to-emulate-animal-crossings-facial-expressions-texture-swapping-the-mouth-eyes/1192051>
13. StraySpark, *Vertex Colors in Blender for game engine workflows*: <https://www.strayspark.studio/blog/blender-vertex-colors-game-engine-workflows>
14. Manual do Blender, *Weighted Normal Modifier*: <https://docs.blender.org/manual/en/latest/modeling/modifiers/normals/weighted_normal.html>
15. Propgon, *Trim Sheets in Blender*: <https://propgon.com/en/trim-sheets-3d-optimization-game-art-guide/>
16. Nexus Mods, *Portraits with more Personality* (Stardew Valley, expressão com ombros e cabeça): <https://www.nexusmods.com/stardewvalley/mods/5716?tab=posts>
17. GC Art Column, *How the Art Style of Animal Crossing Helped Make it a Successful Franchise*: <https://gcartcolumn.com/2021/10/09/how-the-art-style-of-nintendos-animal-crossing-series-helped-make-it-a-successful-franchise/>
18. Wikipedia, *Two Point Hospital*: <https://en.wikipedia.org/wiki/Two_Point_Hospital>
19. Alex Franks, *Two Point Hospital — Back of Box Characters* (ArtStation): <https://www.artstation.com/artwork/rR5dZ6>
20. GFactory, *Anno 1800 — Portraits* (ArtStation): <https://gfactory.artstation.com/projects/aGOrg8>
21. ArtStation, *Anno 1800 — Advisors*: <https://www.artstation.com/artwork/3dKOLo>
22. Point'n Think, *The Art of Hades*: <https://www.pointnthink.fr/en/the-art-of-hades-en/>
23. Wikibooks, *Creating Pixar-looking eyes in Blender*: <https://en.wikibooks.org/wiki/Blender_3D:_Noob_to_Pro/Creating_Pixar-looking_eyes_in_Blender>
24. Wikipedia, *Catch light*: <https://en.wikipedia.org/wiki/Catch_light>
25. CG Cookie, *How to Model Hair in Blender* (grande-médio-pequeno): <https://blog.cgcookie.com/posts/how-to-model-hair-in-blender/>
