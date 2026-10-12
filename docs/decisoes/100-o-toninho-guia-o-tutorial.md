# 100 — O Toninho guia o tutorial curto, e o rosto dele vem antes das falas

**11–12/10/2026.** Base `fbd2b64` (o PR #123, o M11, fundido); 100 livre
conferida na main pelo GitHub, sem PR aberto do Codex. O job «Publicar no
Pages» da corrida da main saiu **verde**: a fonte do Pages já está em «GitHub
Actions», e o Web da main está no ar. A fila de melhorias parou na `099` (o
M9 espera o D1b e o M12 o A8), e volta a frente 5 pelo **tutorial curto** que
o Bruno escolheu em 11/10 (`098`).

## As três respostas do Bruno

**1. Quem guia: o Toninho, com rosto novo.** As opções, com a recomendada
primeiro: a Dona Cida (zero arte — rosto, balão e faixa já existem, e o GDD já
lhe dá o fecho do tutorial); o Toninho com rosto novo (o que o GDD pede, e
são dois itens: o rosto primeiro, o tutorial depois); o Toninho como o
trabalhador do píer 1 (o rosto existe, mas o trabalhador passaria a
personagem); e sem guia. Ele escolheu a segunda. Esta sessão fez o rosto; a
seguinte faz o tutorial.

**2. O recorte do tutorial: atracar + avançar** (a recomendada). Só no dia 1
de uma partida nova; por cima do jogo (overlay, sem fase no `GameState` — o
simulador fica intocado por construção); sem campo novo no save; e cada passo
some se o jogador o fizer sozinho antes. Ficou de fora reparar o píer 2 (o
botão já diz «1 disponível») e o avançar sozinho (o coach mark do GDD, sem o
verbo que custa reputação a quem não o descobre).

**3. O escopo do rosto** (as quatro recomendadas): pele **preta**; **cabelo
branco rente e bigodão branco**; **camisa de botão mostarda gasta aberta no
peito e um pano ao ombro**; e **três expressões, uma por fala** — calmo,
irônico e sério.

## O rosto: seis voltas, aceite na v6 (12/10)

O construtor é o `toninho()` de `blender/brp_retratos.py`: a cabeça do
trabalhador (a mesma oficina, `058`) sem o capacete, com o crânio e o cabelo em
cúpula. As voltas, os vereditos e o que cada uma ensinou estão em
`art_lab/retratos/toninho/README.md`; o essencial:

- o cabelo levou quatro técnicas — cachos esparsos, cachos densos, cachos por
  raio («capacete com bolinhas brancas»), e por fim **uma calote colada ao
  crânio com o grão no material** (Voronoi), contorno irregular por Displace,
  a linha do cabelo como a última linha da malha (sem escada), a borda a
  afinar até ao crânio e a cor a rarear até à pele. O que fazia o capacete
  era a BORDA DURA, não a falta de relevo;
- a camisa seguiu a receita aceite no Arlindo (`056`): V de pele baixo, gola e
  carcela da cor da camisa e salientes, botões redondos (de coco), bolso de
  pala;
- o bigode é uma massa de contorno desenhado com o grão do cabelo — em tufos
  lia como pente.

**Peças novas do kit**, para quem vier depois: `_cupula` (planta em
superelipse, alçado em quarto de elipse, borda por coluna, `colar` para
afinar até uma cúpula de dentro), `_alisar` (suave com as arestas vivas
marcadas à mão — o `set_sharp_from_angle` não existe no `bpy` 4.5),
`_material_crespo` (grão Voronoi, degradê de altura e o atributo `borda`) e
`_rugas(..., leque=0|2|3)`. A paleta ganhou o `cabelo_branco` (`#dde1e0`).

**Medido**: os três PNG a 768, sem um pixel a 255 e com o p99 a 238 (a Dona
Cida, 239). Saíram do pipeline (`gerar_brp.py porto … retrato_toninho_*`)
**iguais à candidata aceite** — 0 pixels diferentes, e 0,0000 no
`comparar_props.py` — e entraram no manifest (o `asset_validator` confere
100 assets, eram 97); os `.import` são os da Dona Cida fora o uid.

## O que entra no jogo agora, e o que espera

**Agora**: os três PNG em `brport_vs/art/props/` (com os `.import`), o
manifest, e as caras em `_CARAS` e `RETRATOS` de `blender/brp_porto.py`.

**Espera pela sessão do tutorial, no mesmo commit das falas:** o registro em
`Retratos.gd` (`POR_EXPRESSAO`) e em `Narrativa.EXPRESSOES`, porque o F7 do
`teste_fumaca` reprova cara registada que nenhuma fala pede — e, no mesmo
commit, a saída dos três da `INTERFACE_SEM_REGISTO` do `catalogo_props.gd`;
e o **tom do
balão** — proposto `#f5daa9` (balão) e `#e1c797` (placa), o matiz da camisa
em OKLCH a L 0,90 e 0,84, a ΔE ≥ 27 dos três de hoje (o par mais próximo está
a 19,9) —, que o D38 confere contra o matiz da roupa lido NO PNG.

**E a folha dos props tomou-os por props.** O catálogo dela sai do disco,
menos o que o `Retratos.gd` regista, e o tiro `props1` do CI do PR #124
reprovou os três como props sem âncora: esta sessão não correu a bateria,
porque nenhuma tela mudava. A `SEM_ANCORA` não servia — desenharia um retrato
de 768 px como prop, e a célula da folha inteira cresceria até ele. Entrou a
`INTERFACE_SEM_REGISTO`, conferida dos dois lados pela folha: os três a
retirar e o PNG em falta reprovaram, injetados, e a base voltou a passar.

## O recorte do tutorial, para a sessão seguinte

- **Quem**: um objeto do `Main` (como a `NarradoraDaCida`, `096`, e a
  `VezDasTelas`, `097`), ligado por método aos sinais que já existem
  (`atracou`, `turn_advanced`) — nunca um lambda (`gdscript.md`).
- **Quando**: dia 1 de partida nova, depois do caderno (`TelaNomes` →
  `PainelDiario`) e de qualquer painel que a recuperação de fase abra.
- **Passo 1 — atracar** (calmo): o Toninho na faixa, e os cartões «Ao largo»
  a pulsar até ao primeiro `atracou`.
- **Passo 2 — avançar** (irônico): depois do primeiro barco atracado, e o
  «AVANÇAR DIA» a pulsar até ao `turn_advanced`. Não se repete.
- **Se o dia virar antes do passo 1**, o tutorial acaba — e é aí que a cara
  **séria** tem fala: o que acontece ao barco que espera demais. Sem essa
  terceira fala, o sério fica registado e mudo, e o F7 reprova.
- **Sem save**: o estado deriva-se (dia 1 e nada atracado); recarregar no dia
  1 repete-o, e isso é aceitável.
- **As falas** vivem na `Narrativa.gd` com o gatilho no mesmo commit, saem
  pelo `GameState.texto()`, e vão à leitura em voz alta do A4. O GDD dá o tom
  («conciso, observador, irônico sem amargura», «chefia», «Seu Maneco»), não
  o texto.
