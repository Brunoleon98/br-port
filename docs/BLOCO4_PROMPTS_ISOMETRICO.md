# BR Port — Prompts para o visual isométrico

> Escrito em 28/08/2026. **Substitui `BLOCO4_PROMPTS_VISUAL_CHAPADO.md`**, que
> travava tudo em topo-down chapado e trazia `no isometric view` no bloco de
> negativos — exatamente o oposto do que este documento pede.
>
> A regra do fundo magenta (§0 de `BLOCO4_GUIA_GERACAO_ASSETS.md`) continua
> valendo integralmente e é a primeira coisa a ler.

---

## 0. A seção mais importante: ORIENTAÇÃO

Em isométrico, **o objeto tem que nascer virado para o lado certo**. Não é
ajuste fino: é a diferença entre o barco atracar no píer e o barco atravessar
o píer.

O motivo é que num plano isométrico **nenhuma direção é horizontal**. Os dois
eixos do chão saem a **26,6°** da horizontal — um para baixo-direita, outro
para baixo-esquerda. Um barco desenhado deitado (proa apontando para a direita,
como vêm quase todos os sprites gerados) fica torto em cima de qualquer píer.

> **Foi exatamente isso que aconteceu com os 5 sprites que já temos.** Eles
> foram gerados na horizontal. No protótipo eles só ficaram certos depois de
> rodados 26,6° em Godot — e rodar sprite ilustrado é paliativo, porque a
> perspetiva está assada dentro da imagem: a luz e as faces continuam
> apontando para onde não deviam.

### Como dizer isso ao gerador

Acrescente ao prompt de **todo** objeto que assenta no chão:

```
ORIENTATION: aligned to the isometric grid, its long axis running along the
south-east axis — from the upper-left toward the lower-right of the image at a
2:1 slope (26.6 degrees below horizontal). NOT horizontal, NOT vertical,
NOT front-facing.
```

### Quantas orientações pedir

Uma por direção em que o objeto aparece no jogo. Na Fase 1 os **três píeres são
paralelos**, então cada tipo de barco precisa de **uma orientação só** — o caso
barato. Isso deixa de valer no dia em que um píer apontar para o outro lado:
aí o mesmo barco precisa ser gerado de novo virado, não espelhado (espelhar
inverte a luz e entrega o objeto iluminado pelo lado errado).

---

## 1. Bloco de estilo isométrico

Cole literalmente em cada geração.

```
STYLE: isometric 2D game asset, true 2:1 isometric projection, semi-realistic
cartoon illustration, thick dark outline, smooth cel shading with clear volume,
saturated tropical Brazilian coastal palette, mobile port management game,
single centered object, crisp edges.
LIGHTING: single light source from the upper left — the faces pointing
lower-left are the lit ones, the faces pointing lower-right are in shadow.
PALETTE: water #2b6f8c, concrete #b9c2c8, asphalt #6f7b85, wood #9a6438,
roof orange #c85420, foliage #2d7a3a, navy #1c3454, amber #e09a10, red #c23030.
BACKGROUND: solid flat magenta #FF00FF, uniform, no gradient, no shadow cast
on the background.
NEGATIVE: no transparency checkerboard, no top-down view, no front view, no
side elevation, no vanishing-point perspective, no text, no letters, no
numbers, no watermark, no UI frame, no photorealism.
OUTPUT: square 1:1, 1024x1024.
```

Três coisas que decidem a consistência mais que o prompt:

1. **Gere tudo na mesma sessão.**
2. **Use referência de estilo** (`--sref` no Midjourney, style reference no
   Leonardo/Scenario). Aponte para `cargueiro.png` — é o asset mais
   característico do que já existe.
3. **A luz é a que mais denuncia.** Um asset iluminado pela direita no meio de
   vinte iluminados pela esquerda salta aos olhos mais que um erro de cor.

---

## 2. Os 5 sprites que já existem

| Sprite | Situação |
|---|---|
| `cargueiro.png` | Ângulo certo, **orientação errada** (horizontal). Regerar com a orientação declarada. |
| `barco_pesca.png` | Idem. |
| `guindaste.png` | Aproveitável quase como está — estrutura vertical sofre menos com orientação. |
| `caminhao.png` | Idem, mas idealmente regerar alinhado à rua. |
| `trabalhador.png` | Aproveitável — figura de pé não tem eixo longo. |

Ou seja: **os dois barcos são o que precisa voltar para a fila**, e são
justamente os que o jogador mais olha.

---

## 3. Assets da Fase 1

### A — Barcos (GDD pede 3 variações, mesma mecânica)

Todos com o bloco `ORIENTATION` da §0.

```
A1  Small wooden fishing boat, blue and white hull, open deck with stacked fish
    crates and a coiled net, small wheelhouse near the stern.

A2  Coastal cargo ship, red hull with a white superstructure at the stern, a
    short black funnel, four shipping containers lashed on the deck.

A3  Small tanker barge, dark grey hull, two round fuel tanks on the deck with
    pipework between them, safety railing.
[+ BLOCO DE ESTILO + ORIENTATION]
```

### B — Píer nos dois estados (o construível)

Precisam ter **exatamente o mesmo comprimento, ângulo e posição de estacas**,
porque um substitui o outro no lugar quando o jogador amplia.

```
B1  Empty pier foundation: a row of old wooden pilings rising out of shallow
    water, no deck planks, no railing, weathered and clearly unfinished.

B2  Finished wooden pier: warm brown timber deck planks over the same pilings,
    black mooring bollards at both ends, a coil of rope.
[+ BLOCO DE ESTILO + ORIENTATION]
```

### C — Estruturas do pátio (GDD, Fase 1)

O GDD descreve a Fase 1 como *"píer de madeira com 6 vagas para pescadores,
galpão velho, área de docagem básica"*. O galpão velho é peça narrativa: é o
que Toninho manda inspecionar no tutorial, e custa R$400 para limpar.

```
C1  Old run-down warehouse shed, rusted corrugated metal roof in faded orange
    with holes and patches, cracked concrete apron around it, abandoned.

C2  The same warehouse repaired: clean solid orange corrugated roof, intact
    panels, tidy apron, a few crates stacked by the door.

C3  Small two-storey port office building, white and pale blue walls,
    terracotta roof, blue window frames, small entrance canopy.
[+ BLOCO DE ESTILO + ORIENTATION]
```

```
C4  Empty construction plot: bare graded ground with corner marker stakes and
    a length of string between them, nothing built yet.
[+ BLOCO DE ESTILO + FOOTPRINT do lote]
```

C1 e C2 são o mesmo par de estados de B1/B2 — mesmo enquadramento, um troca
pelo outro. **C4 é o par de C3**: toda estrutura precisa do estado "lote vazio",
senão o sistema de Fases (§5) não tem o que mostrar antes de construir.

### C5 — Trabalhador isométrico

O `trabalhador.png` atual serve no cartão de arrasto (cartão é interface). Se
os trabalhadores forem para o cais, precisa de versão isométrica:

```
C5  Port worker standing, yellow hard hat, orange safety vest with reflective
    stripes, dark work trousers and boots, arms slightly out, seen in the same
    isometric projection as the ground — looking down at him from the same
    height and angle as the buildings.
[+ BLOCO DE ESTILO; sem ORIENTATION — figura de pé não tem eixo longo]
```

### D — Cenário

```
D1  Coconut palm tree, curved trunk, lush green fronds.
D2  Stack of shipping containers, two high, red blue and green, weathered metal.
D3  Wooden cargo crates, a few stacked, rope and stencil marks, no readable text.
D4  Red harbor mooring buoy floating in water, white top stripe.
[+ BLOCO DE ESTILO; ORIENTATION só em D2 e D3]
```

### E — Peças que a animação exige (ver §4)

```
E1  Gantry crane BASE only — the tower and its rails, no jib, no hook.
E2  Gantry crane JIB only — the horizontal boom arm, same scale as E1.
E3  Crane HOOK block only — a small dark pulley block, tiny.
[+ BLOCO DE ESTILO + ORIENTATION em E1 e E2]
```

### F — Marcadores da zona de espera

```
F1  Anchorage marker: a dashed white circle drawn flat on the water with a
    simple white anchor symbol at its centre, seen in the same isometric
    projection so the circle reads as an ellipse, not a circle.
[+ BLOCO DE ESTILO]
```

---

## 3b. Ícones de interface — e estes NÃO são isométricos

**Não cole o bloco de estilo isométrico num ícone de HUD.** Ícone de barra
superior é interface, não objeto de mundo: precisa de silhueta chapada e
legível a 19px. Money bag em perspetiva isométrica dentro de uma pílula escura
vira borrão.

Bloco próprio para os ícones:

```
STYLE: flat 2D game UI icon, front-facing, bold simple silhouette, solid flat
colors, thick clean shapes, readable at 19 pixels, centered, no perspective.
PALETTE: navy #1c3454, amber #e09a10, cream #f0f6ff, green #1a7a40,
red #c23030, grey #8299b4.
BACKGROUND: solid flat magenta #FF00FF.
NEGATIVE: no isometric view, no 3D, no text, no letters, no numbers,
no watermark, no gradient.
OUTPUT: square 1:1, 512x512.
```

> ## ✅ ESTE GRUPO ESTÁ FEITO (29/08) — NÃO GERAR
>
> Os ícones foram desenhados à mão em SVG e estão em `brport_vs/art/icones/`,
> registrados em `brport_vs/scripts/Icones.gd`. **Nenhuma tela do jogo usa
> emoji.** São 20, não 17: a tabela abaixo não contava a cara do cliente (2
> estados) nem o barco.
>
> O prompt acima e a tabela ficam como registro do que era o plano. Se um dia
> um ícone novo for preciso, desenhe no mesmo grid 24×24 e rode
> `tools/folha_icones.gd` — foi ele que reprovou 4 desenhos que pareciam bons.

A tabela original, com o emoji que cada um substituiu:

| # | Ícone | Onde o jogo usa (emoji atual) |
|---|---|---|
| G1 | Saco de dinheiro com moedas | HUD, caixa (💰) |
| G2 | Folha de calendário | HUD, dia/turno (📅) |
| G3 | Estrela em disco | HUD, reputação (⭐) |
| G4 | Âncora | HUD, contador de docas (⚓) |
| G5 | Prédio de banco com selo vermelho | Barra da parcela (🏦) |
| G6 | Guindaste/martelo de construção | Botão "Ampliar píer" (🏗) |
| G7 | Duas barras de pausa | Botão pausar (⏸) |
| G8 | Triângulo de play | Botão "Avançar dia" (▶) |
| G9 | Setas circulares | Botão recomeçar (🔄) |
| G10 | Capacete de obra | Trabalhador na doca (👷) |
| G11 | Espadas cruzadas | Oferta do rival (⚔) |
| G12 | Aperto de mãos | Contra-oferta "Igualar" (🤝) |
| G13 | Tesoura | Contra-oferta "Cortar metade" (✂) |
| G14 | Braço flexionado | Contra-oferta "Manter preço" (💪) |
| G15 | Troféu | Fim de jogo, vitória (🏆) |
| G16 | Nota voando | Fim de jogo, derrota (💸) |
| G17 | Marca de confirmado | Estado concluído (✅/✓) |

> A seta `→` que aparece em "arraste →" é tipografia, não ícone — fica como está.

> **Foi o que se fez, e confirmou a suspeita:** vetor chapado à mão saiu melhor
> e mais rápido que gerador para este grupo. Três das metáforas da tabela não
> sobreviveram a 19px e foram trocadas — aperto de mão virou sinal de igual,
> braço flexionado virou escudo, nota voando virou cédula com seta de queda.

---

## 3c. Personagens — 3/4, nunca isométricos

Os retratos aparecem em **painéis de interface**, não no mapa. Levam o bloco de
estilo do `BLOCO4_GUIA_GERACAO_ASSETS.md` §5, não o daqui.

Só dois personagens têm tela na Fase 1 — confirmado no código (`GameState.gd`,
`CounterOfferPanel.gd`, `DebtPaymentPanel.gd`):

| Quem | O que gerar | Por que importa |
|---|---|---|
| **Arlindo** | 3 expressões: neutro · impaciente · indo embora | A paciência dele (`RIVAL_PATIENCE = 2`) já está implementada e hoje é desenhada com 🙂/😟. É o asset de maior retorno da lista inteira. |
| **Sr. Ribeiro** | 1 pose | Painel da parcela — a única forma de perder o jogo. |

**Dona Cida fica de fora**, mesmo o plano de produção mandando começar por ela:
é para o jogo completo, e o VS não tem tela onde ela apareça.

---

## 4. Animação — o gerador não faz, e não é para pedir

Gerador devolve imagem parada. Balanço de barco, chegada, vento em coqueiro e
ondulação de água são feitos em Godot, com `Tween`, `AnimationPlayer` ou shader.

### Não precisa de arte nenhuma

| Efeito | Como se faz |
|---|---|
| Barco balançando atracado | `Tween` em `rotation` (±1,5°) e `position.y` (±3px), loop 2–3s |
| Barco chegando / partindo | `Tween` em `position`, da zona de espera até o píer |
| Barco novo aparecendo | `Tween` em `modulate:a` + leve `scale` |
| Doca podendo receber trabalhador | `Tween` em `modulate` do píer |
| Píer aparecendo ao construir | `Tween` em `scale` + `modulate` na troca vazio→pronto |

> Dê a cada barco um `offset` aleatório no início do loop. Sem isso o porto
> inteiro balança em uníssono e parece defeito, não vida.

**Em isométrico tem uma regra a mais:** o movimento tem que seguir os eixos do
grid. Barco que se desloca na horizontal da tela atravessa o chão em diagonal
no mundo e parece deslizar. Mover sempre ao longo de `(±30, ±15)` por unidade.

### Precisa de arte separada

Peça **cada parte num arquivo**, mesmo enquadramento e tamanho, para
empilharem alinhadas:

```
D1a  Coconut palm CROWN only — the ring of fronds, no trunk, centered.
D1b  Coconut palm TRUNK only — trunk and the small ground shadow, no leaves.
[+ BLOCO DE ESTILO]
```

O vento é a copa girando ±3° sobre a base parada. Num sprite só, a palmeira
inteira gira em volta do próprio tronco e fica errada.

| Efeito | Peças a pedir |
|---|---|
| Vento no coqueiro | copa · tronco+sombra |
| Guindaste operando | base+torre · lança (gira) · gancho (sobe/desce) |
| Bandeira no mastro | mastro · pano |
| Fumaça da chaminé | barco sem fumaça · baforada solta (repetida com fade) |

### Água

Não peça ao gerador — é **shader** de deslocamento de UV. Alternativa sem
shader: camadas de ondulação deslizando em velocidades diferentes.

```
D5  Seamless tileable layer of stylized white water ripple lines only, sparse,
    on solid magenta, nothing else in the image.
```

---

## 5. Evolução do mapa por Fase

O GDD é explícito, e é boa notícia para a arte:

> *"O jogador não vê uma interface de árvore. Vê o cais se transformando,
> estrutura por estrutura."*

São **5 Fases de construção**, que não são os 3 Atos narrativos — um jogador no
Ato 3 pode estar na Fase 3 ou 4.

| Fase | Estruturas novas (GDD) |
|---|---|
| **1 — O que o avô deixou** | Píer de madeira (6 vagas de pescador), galpão velho, docagem básica |
| **2 — Porto com identidade** | Posto de abastecimento, câmara frigorífica, 2º píer comercial, área coberta de carga, escritório administrativo |
| **3 — Igual ao Porto Farol** | Terminal de passageiros, armazém climatizado, torre de comunicação, área de manutenção naval, Memorial do avô |
| **4 — Porto nacional** | Terminal de contêineres, aduana, plataforma de granel, ampliação da torre, alojamento de tripulações |
| **5 — Grande porto costeiro** | Estaleiro completo, dragagem profunda, área industrial, terminais especializados |

### O que isso força na arquitetura

**Não pode ser uma imagem por Fase.** Cinco mapas inteiros é caro de gerar,
impossível de manter consistente, e esconde a combinação de escolhas do
jogador — que é justamente o que o GDD promete mostrar.

O caminho é o que o píer já inaugurou: **mapa base + estruturas como peças de
dois estados em lotes reservados**. Cada estrutura é um nó no lote dela, com
`vazio` / `construído`, igual a `pier_vazio` / `pier_construido`.

Em isométrico isso ganha um requisito extra: **cada lote tem um tamanho em
células do grid**, e a arte precisa nascer nesse tamanho. Um armazém de 4x3
células mede 4·30+3·30 = 210px de largura e 4·15+3·15 = 105px de altura na
projeção atual. Pedir "um armazém" sem dizer o tamanho traz peça que não
encaixa no lote.

Acrescente ao prompt de estrutura:

```
FOOTPRINT: occupies a 4 by 3 isometric grid footprint (the base is a rhombus,
not a rectangle).
```

> ⚠️ **Trabalho de Fase 2+, não do VS.** O Vertical Slice é uma Fase 1 reduzida
> (2 docas, 3 com upgrade; o GDD prevê 4 na Fase 1 cheia). Registrar agora serve
> para o mapa base já nascer com os lotes vazios reservados — redesenhar depois
> quebra todas as posições calibradas.

---

## 6. As duas armadilhas do isométrico em retrato

Descobertas medindo, não no papel — estão em `tools/gerar_mapa_iso.py`.

1. **A caixa de um plano isométrico é sempre 2:1.** Vale para qualquer formato
   de terreno. Em 720 de largura o chão nunca passa de 360 de altura. A saída
   é gerar o mundo **maior que o ecrã e cortar**: o mapa transborda dos quatro
   lados e o jogador vê uma janela.

2. **Costa reta empurra as docas para o lado, não para baixo.** Como
   `tela_x` depende de `(mx - my)`, docas espaçadas só ao longo da costa
   marcham para a esquerda e saem do ecrã. Por isso a costa é em **degraus**:
   cada doca avança também para dentro da terra. A regra é `Δmx > Δmy / 3`.

---

## 6b. Checklist — tudo que a Fase 1 consome

Serve para responder "os prompts cobrem tudo?" sem depender de memória. Cada
linha é um asset que o jogo carrega ou um emoji que ainda está no lugar de um.

| Asset | Prompt | Estado |
|---|---|---|
| Mapa base isométrico | — | ✅ gerado por `tools/gerar_mapa_iso.py` |
| Píer vazio / construído | B1 · B2 | ⬜ a gerar |
| Barco pequeno (pesca) | A1 | ⬜ a gerar (o atual está horizontal) |
| Barco grande (cargueiro) | A2 | ⬜ a gerar (o atual está horizontal) |
| 3º barco (GDD pede 3 variações) | A3 | ⬜ a gerar |
| Galpão velho / consertado | C1 · C2 | ⬜ a gerar |
| Escritório + lote vazio | C3 · C4 | ⬜ a gerar |
| Trabalhador isométrico | C5 | ⬜ só se forem para o cais |
| Guindaste em peças | E1 · E2 · E3 | ⬜ só quando for animar |
| Marcador de fundeadouro | F1 | ⬜ a gerar |
| Coqueiro (copa + tronco) | D1a · D1b | ⬜ a gerar |
| Contêineres, caixotes, boia | D2 · D3 · D4 | ⬜ a gerar |
| Ondulação da água | D5 | ⬜ ou shader, sem arte |
| **Ícones de HUD e botões** | G1–G17 | ✅ **FEITO — 20 SVGs em `art/icones/`, vetor chapado** |
| Arlindo, 3 expressões | §3c | ⬜ maior retorno da lista |
| Sr. Ribeiro | §3c | ⬜ a gerar |

**Emoji ainda na interface:** nenhum. A camada foi fechada em 29/08.

Para reconferir depois de qualquer mudança no jogo:

```
grep -rhoP '[\x{1F300}-\x{1FAFF}\x{2600}-\x{27BF}]' \
  brport_vs/scenes brport_vs/scripts | sort -u
```

---

## 7. Ordem sugerida

1. **A1–A3** — os três barcos, já na orientação certa. É o que o jogador olha
   o tempo todo, e os dois atuais estão tortos.
2. **B1–B2** — píer nos dois estados, o par que o botão "Ampliar píer" troca.
3. **§3c, Arlindo** — as 3 expressões. A mecânica da paciência já existe e hoje
   é desenhada com emoji; é o maior salto de qualidade por asset gerado.
4. **G1–G17** — os ícones. São muitos, mas é a camada que faz a interface
   parar de parecer protótipo. Considere o caminho do Claude Design (§3b).
5. **D1a–D1b** — copa e tronco do coqueiro. Vento é duas peças e um `Tween`.
6. **C1–C2** — galpão velho e consertado, com gancho narrativo pronto.
7. Estruturas de Fase 2+ — só depois de o VS fechar.

---

*BR Port · Prompts do visual isométrico · Fase 4, Bloco 4*
