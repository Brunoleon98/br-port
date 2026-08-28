# BR Port — Prompts para o visual chapado (mapa implementado)

> Escrito em 28/08/2026, depois de o mapa do porto virar a tela do jogo de
> verdade (`Main.tscn`). Substitui a parte de estilo do
> `BLOCO4_GUIA_GERACAO_ASSETS.md`, que assumia 3/4 ilustrado.
>
> Ler antes: §0 daquele guia (a regra do fundo magenta) continua valendo
> integralmente.

---

## 0. A decisão de estilo mudou — e agora está resolvida

O guia anterior travava tudo em **3/4 ilustrado**, para casar com os 5 sprites
raster. Ao colocar aqueles sprites sobre o mapa topo-down, o problema que a
§6b do style guide previu apareceu na tela: **barco em 3/4 boiando por cima de
um mapa visto de cima não é escolha de estilo, é erro de perspectiva.**

O jogo agora usa **vetor chapado, topo-down** no mapa. Isso volta a bater com
o GDD ("Flat Design 2D — estética tropical brasileira"). Onde cada coisa fica:

| Camada | Estilo | Onde |
|---|---|---|
| Mapa, píeres, barcos, estruturas | **Vetor chapado topo-down** | Sobre o mapa |
| Ícones de HUD | Vetor chapado | Barra de topo |
| Retratos (Arlindo, Sr. Ribeiro) | 3/4 ilustrado | Painéis, nunca no mapa |
| Trabalhador no cartão | 3/4 ilustrado (cartão é UI) | Fileira de arrasto |

Os 5 PNGs ilustrados **continuam no repositório** e continuam úteis — só não
vão para o mapa.

---

## 1. Bloco de estilo — vetor chapado topo-down

Cole literalmente em cada geração. É o que impede cada peça de sair com um
contorno, uma luz ou uma saturação diferente.

```
STYLE: flat vector game asset, top-down view seen from directly above,
solid flat colors with NO gradients and NO photorealistic shading, at most one
darker tone per object used as a simple offset shadow, clean geometric shapes,
crisp edges, saturated tropical Brazilian coastal palette, mobile game map
asset, single centered object.
PALETTE: water #2b6f8c, shallow water #3d87a4, concrete #b9c2c8, asphalt
#6f7b85, sand #edd9b0, wood #9a6438, dark wood #6b4322, roof orange #c85420,
foliage #2d7a3a, navy #1c3454, amber #e09a10, red #c23030.
BACKGROUND: solid flat magenta #FF00FF, uniform, no gradient, no shadow cast
on the background.
NEGATIVE: no transparency checkerboard, no isometric view, no 3/4 view, no
perspective, no text, no letters, no numbers, no watermark, no UI frame, no
photorealism, no painterly rendering.
OUTPUT: square 1:1, 1024x1024.
```

> **`no isometric view, no 3/4 view, no perspective` é o negativo mais
> importante da lista.** Gerador de imagem puxa para 3/4 por padrão, porque é
> o que domina o dataset de "game asset". Sem esse negativo você recebe de
> volta o problema que acabou de ser consertado.

---

## 2. Sprites da Fase 1 — o que falta

O que **já existe** em vetor chapado e está no jogo: mapa base, píer vazio,
píer construído, barco pequeno, barco grande.

O que falta, em ordem de valor:

### A — Variações de barco (GDD: "3 variações visuais, mesma mecânica")

O plano de produção pede três variações. Hoje há duas (pequeno/grande). Faltam:

```
A1  Small wooden fishing boat seen from directly above, blue and white hull,
    open deck with stacked fish crates and coiled net, tiny wheelhouse near
    the stern, bow pointing right.

A2  Medium coastal cargo boat seen from directly above, green hull, wooden
    deck with three canvas-covered cargo bundles lashed down, small crane arm
    on the deck, bow pointing right.

A3  Small tanker barge seen from directly above, dark grey hull, two round
    fuel tanks on the deck with pipework between them, bow pointing right.
[+ BLOCO DE ESTILO]
```

> **Bico sempre para a DIREITA.** O jogo atraca os barcos ao sul do píer, que
> corre leste-oeste. Barco gerado apontando para cima entra torto e não tem
> conserto sem rotacionar, o que quebra a leitura da sombra.

### B — Trabalhador visto de cima (para ficar no cais, não só no cartão)

```
B1  Port worker seen from directly above, yellow hard hat filling most of the
    silhouette, orange safety vest with reflective stripes, shoulders and
    boots visible below the hat, standing still, arms slightly out.
[+ BLOCO DE ESTILO]
```

### C — Estruturas de Fase 1 (GDD §Progressão de Construção)

O GDD descreve a Fase 1 como *"píer de madeira com 6 vagas para pescadores,
galpão velho, área de docagem básica"*. O galpão velho é peça narrativa: é o
que Toninho manda inspecionar no tutorial e o que custa R$400 para limpar.

```
C1  Old run-down warehouse shed seen from directly above, rusted corrugated
    metal roof in faded orange with visible holes and patches, small yard of
    cracked concrete around it, abandoned look.

C2  Same warehouse after repair, clean corrugated roof in solid orange,
    intact panels, tidy concrete yard, small stack of crates by the door.

C3  Fishermen's wooden jetty seen from directly above, narrow weathered plank
    walkway with six small mooring spots along its side, thinner and older
    than a commercial pier, a few tyres used as fenders.
[+ BLOCO DE ESTILO]
```

C1 e C2 são o mesmo par de estados do píer: **mesmo contorno, mesmo tamanho,
mesma posição** — um troca pelo outro quando o jogador conserta.

---

## 3. Animação — o que o gerador NÃO faz

Aqui tem um mal-entendido caro para evitar.

**Você não pede animação ao gerador de imagem.** Ele devolve uma imagem
parada. Movimento de barco, vento em coqueiro e ondulação de água são feitos
em Godot, com `Tween`, `AnimationPlayer` ou shader.

O que o gerador precisa entregar é **arte preparada para ser animada**, e isso
muda o pedido: em vez de um sprite inteiro, peça **as partes separadas pelo
eixo que se move**.

### O que NÃO precisa de arte nenhuma

Estes saem de graça, animando o sprite que já existe:

| Efeito | Como se faz | Arte extra |
|---|---|---|
| Barco balançando atracado | `Tween` em `rotation` (±1,5°) e `position.y` (±3px), loop 2–3 s, dessincronizado por barco | nenhuma |
| Barco chegando / partindo | `Tween` em `position` da zona de espera até o píer | nenhuma |
| Barco novo aparecendo | `Tween` em `modulate:a` + leve `scale` | nenhuma |
| Doca pulsando quando pode receber trabalhador | `Tween` em `modulate` do píer | nenhuma |
| Píer aparecendo ao construir | `Tween` em `scale` + `modulate` na troca vazio→pronto | nenhuma |

> **Regra que evita o efeito "tudo pulsando junto":** dê a cada barco um
> `offset` aleatório no início do loop. Sem isso o porto inteiro balança em
> uníssono e parece um erro, não vida.

### O que PRECISA de arte separada

Aqui sim o pedido ao gerador muda. Peça **cada parte num arquivo**, todas no
mesmo enquadramento e tamanho, para empilharem alinhadas:

```
D1  Coconut palm crown seen from directly above, ONLY the ring of fronds,
    no trunk, centered, radiating leaves.

D2  Coconut palm trunk base seen from directly above, ONLY the short trunk
    stump and the small circle of ground shadow, no leaves, centered.
[+ BLOCO DE ESTILO nos dois]
```

Com as duas peças, o vento é a copa (D1) girando ±3° em loop lento sobre a
base (D2) parada. Se vier tudo num sprite só, a palmeira inteira gira em
volta do próprio tronco e fica errada.

Mesma lógica para:

| Efeito | Peças separadas a pedir |
|---|---|
| Vento no coqueiro | copa · tronco+sombra |
| Guindaste operando | base+torre · lança (gira) · gancho (sobe/desce) |
| Bandeira no mastro | mastro · pano |
| Fumaça da chaminé | barco sem fumaça · baforada solta (repetida com fade) |

### Água

Água ondulando **não é sprite, é shader**. Não peça ao gerador. Peça só o
tile de água chapado (§3/A1 do guia anterior); a ondulação é um shader de
deslocamento de UV aplicado no `TextureRect` do mapa. Uma alternativa sem
shader: duas ou três camadas de "ondulações" transparentes deslizando em
velocidades diferentes — aí sim são arquivos, e o pedido é:

```
D3  Seamless tileable layer of stylized white water ripple lines only,
    sparse, on a solid magenta background, nothing else in the image.
[+ BLOCO DE ESTILO]
```

---

## 4. Evolução do mapa por Fase (GDD §Progressão de Construção)

O GDD é explícito e é uma boa notícia para a arte:

> *"O jogador não vê uma interface de árvore. Vê o cais se transformando,
> estrutura por estrutura."*

São **5 Fases de construção**, que não são os 3 Atos narrativos — um jogador
no Ato 3 pode estar na Fase 3 ou 4.

### O que cada Fase acrescenta ao mapa

| Fase | Estruturas novas (GDD) |
|---|---|
| **1 — O que o avô deixou** | Píer de madeira (6 vagas de pescador), galpão velho, docagem básica |
| **2 — Porto com identidade** | Posto de abastecimento, câmara frigorífica, 2º píer comercial, área coberta de carga, escritório administrativo |
| **3 — Igual ao Porto Farol** | Terminal de passageiros, armazém climatizado, torre de comunicação, área de manutenção naval, Memorial do avô |
| **4 — Porto nacional** | Terminal de contêineres, aduana, plataforma de granel, ampliação da torre, alojamento de tripulações |
| **5 — Grande porto costeiro** | Estaleiro completo, dragagem profunda, área industrial, terminais especializados |

### A decisão de arquitetura que isso força

**O mapa não pode ser uma imagem por Fase.** Cinco mapas inteiros é caro de
gerar, impossível de manter consistente, e não deixa o jogador ver *a sua*
combinação de escolhas — que é justamente o que o GDD promete.

O caminho é o que o píer já inaugurou: **mapa base + estruturas como peças em
lotes reservados**. Cada estrutura é um nó no lote dela, com dois estados
(vazio/construído), exatamente como `pier_vazio` / `pier_construido`.

Isso significa que **o mapa base precisa ser desenhado já com os lotes vazios
das 5 Fases** — terreno reservado, ainda sem construção. Redesenhar o mapa
depois para abrir espaço quebra todas as posições já calibradas.

> ⚠️ **Isto é trabalho de Fase 2+, não do VS.** O Vertical Slice é uma Fase 1
> reduzida (2 docas, 3 com upgrade — o GDD prevê 4 na Fase 1 cheia). Registrar
> agora serve para o mapa base já nascer com espaço, não para construir tudo.

### Prompt de cada estrutura (mesmo par de estados)

Para qualquer estrutura da tabela acima, o pedido é sempre em par:

```
E1  <estrutura> seen from directly above, foundations and bare graded ground
    only, construction plot not yet built, marker stakes at the corners.

E2  <estrutura> seen from directly above, finished and in use.
[+ BLOCO DE ESTILO nos dois, MESMO tamanho e MESMO enquadramento]
```

Exemplo pronto, para a primeira estrutura da Fase 2:

```
Fuel station for boats seen from directly above, two fuel pumps under a
small flat canopy, a short jetty spur for boats to pull alongside, safety
bollards, hose reel.
[+ BLOCO DE ESTILO]
```

---

## 5. Ordem sugerida

1. **A1–A3** — variações de barco. É o que o jogador olha o tempo todo.
2. **D1–D2** — copa e tronco do coqueiro. Vento é o efeito de maior retorno
   por esforço: duas peças e um `Tween`.
3. **C1–C2** — galpão velho e consertado. Tem gancho narrativo pronto.
4. **B1** — trabalhador topo-down, quando os trabalhadores forem para o cais.
5. Estruturas de Fase 2+ — só depois de o VS fechar.

---

*BR Port · Prompts do visual chapado · Fase 4, Bloco 4*
