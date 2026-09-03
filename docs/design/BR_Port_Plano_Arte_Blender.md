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
| **Contorno de silhueta** | sim, suave | não (Freestyle testado e rejeitado) | Blender, com outra técnica |
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
5. **Contorno de silhueta.** O Freestyle foi testado e **rejeitado com razão**
   (fecha o vazado da treliça, engorda peça pequena). A saída não é insistir
   nele: é fazer o contorno **no compositor**, a partir dos buffers de
   profundidade e normal, onde a espessura pode depender da distância e o
   vazado não fecha. Isto é conhecimento novo — ver §5.
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

### Etapa 3 — Contorno pelo compositor
- Passe de normal + profundidade, detecção de borda no compositor, espessura
  proporcional à profundidade, composição por cima do beauty.
- **Mede-se por:** o guindaste. Se a treliça continuar vazada, funcionou.

### Etapa 4 — Materiais dirigidos
- Família de padrões: ripa, corrugado, fiada de telha, ferrugem que escorre
  de cima para baixo, cal descascada nas quinas.
- **Mede-se por:** o galpão a 100% e a 25% — padrão que só funciona de perto
  não serve.

### Etapa 5 — Personagem com rosto
- Folha de rostos por gerador de imagem, aplicada num plano da cabeça.
- **Mede-se por:** o trabalhador no tabuado, a 22px, no jogo rodando.

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
