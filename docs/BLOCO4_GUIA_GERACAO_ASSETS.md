# BR Port — Guia para gerar os assets que faltam (Fase 1 / VS)

> Prompts prontos para a IA geradora de imagem, cobrindo o que falta para a
> Fase 1 do Vertical Slice: **mapa componível, indicadores e sprites**.
>
> Escrito em 28/08/2026, depois da primeira leva de sprites entrar no jogo.
> Complementa `docs/BLOCO4_PACOTE_SPRITES.md` (o que já veio) e
> `docs/design/BR_Port_Style_Guide_Flat_Design.md` (paleta e proporções).

---

## 0. A regra que evita o erro da primeira leva

**Nunca peça "fundo transparente" ou "PNG transparente".**

A primeira leva veio com o quadriculado cinza *desenhado* nos pixels — o
gerador aprendeu que "transparente" tem essa cara e pintou o xadrez. Os cinco
PNGs saíram `RGB`, sem canal alpha nenhum.

**Peça sempre:**

```
solid flat magenta background, exact color #FF00FF, uniform, no gradient
```

Magenta não aparece em nada portuário, então o recorte sai exato. Depois é só
rodar:

```
python3 tools/preparar_sprites.py <pasta_gerada> brport_vs/art/sprites
```

O script detecta o fundo sozinho (magenta chapado ou quadriculado herdado),
recorta, redimensiona e grava com alpha de verdade.

> **Antes de gerar 20 assets, gere 1 e rode o script.** Se o modo sair
> `sólido` e a silhueta ficar limpa, o bloco de estilo está funcionando e você
> pode disparar o resto. Eu não consigo rodar gerador de imagem daqui, então
> os prompts abaixo são bem fundamentados mas **não testados na prática** —
> essa validação de um asset só é o que evita retrabalho em cima de vinte.

---

## 1. Perspectiva: 3/4 isométrico, decidido

Os 5 sprites que já estão no jogo são **ilustrados em vista 3/4** (cargueiro,
trabalhador, guindaste). O mapa que desenhei à mão é **topo-down chapado**.
As duas coisas não convivem soltas na mesma tela — vira erro de perspectiva,
não escolha de estilo. (Ver §6b do style guide.)

**Decisão que este guia assume: tudo em 3/4 isométrico**, casando com os
sprites que já existem e com os mockups dos níveis 1–5.

Isso **diverge do GDD**, que congelou "Flat Design 2D". A justificativa é
econômica: já existem 5 assets bons nesse estilo, e refazê-los em flat
topo-down joga fora trabalho pronto. Se você preferir o contrário — manter o
GDD e regerar os 5 —, me avise: os prompts mudam, mas a estrutura do guia não.

---

## 1b. Quem produz o quê — Claude Design ou gerador de imagem

O Claude Design **não é um gerador de imagem**. É uma prancheta de HTML/CSS/SVG:
eu desenho os assets em vetor, você vê tudo numa tela só e ajusta na mão. Isso
muda o que faz sentido pedir a cada um.

| | Claude Design (vetor) | Gerador de imagem (raster) |
|---|---|---|
| Ícones de HUD | ✅ **melhor opção** | ❌ ruim: silhueta imprecisa, inconsistente no conjunto, insiste em pôr texto |
| Píer vazio / construído | ✅ ótimo (as duas peças alinham exatas) | ⚠️ difícil casar as duas |
| Peças chapadas do mapa | ✅ bom | ⚠️ ok |
| Sprites ilustrados 3/4 | ❌ **não faz** | ✅ é para isso que serve |
| Retratos do Arlindo / Ribeiro | ❌ sai duro | ✅ melhor opção |

**A regra prática:** interface em vetor, mundo em raster. Ícone chapado ao lado
de sprite ilustrado não é incoerência — é convenção normal de jogo mobile,
porque HUD e mundo são camadas diferentes. Ninguém espera o ícone de dinheiro
pintado como o cargueiro.

### O detalhe que decide o pipeline

O Claude Design exporta **PNG por prancheta, um de cada vez, por caixa de
diálogo** — e a prancheta pinta um fundo. Ou seja, **transparência não é a
saída natural dele**, e transparência é exatamente o que sprite de jogo precisa.

Por isso o caminho bom não é exportar do Claude Design: é **eu gravar os
arquivos `.svg` direto no repositório**. Já está provado nesta sessão que o
Godot importa SVG nativamente (o mapa e os barcos do protótipo são SVG). Isso
dá alpha perfeito, escala sem borrar, arquivo minúsculo e versionado como
texto — sem passo manual de exportação.

**O Claude Design entra como superfície de revisão**, não como fábrica: você
olha, mexe, me diz o que mudar, e eu gravo o `.svg` final.

### Como pedir (não é prompt de colar em caixa)

Aqui o "prompt" é um pedido em português para mim. O que vale dizer:

```
Faz os ícones de HUD no Claude Design, na paleta do tema_brport.tres,
mostrando cada um em tamanho grande e a 19px dentro da barra escura.
```

```
Ajusta o ícone de reputação: a estrela some no fundo navy, deixa
o disco mais claro.
```

```
Aprovado. Grava os 8 como .svg em brport_vs/art/icones/ e troca
os emoji do HUD por eles.
```

O canvas dos 8 ícones + píer nos dois estados já está feito — foi assim que
essa comparação foi decidida, e não no papel.

---

## 2. Bloco de estilo (cole em TODO prompt, sem alterar)

A consistência entre assets vem de repetir isto **literalmente** em cada
geração. É o que impede cada peça de sair com um contorno, uma luz ou uma
saturação diferente.

```
STYLE: 2D game asset, semi-realistic cartoon illustration, thick dark outline,
smooth cel shading with soft volume, saturated tropical palette, 3/4 top-down
isometric view, Brazilian coastal port setting, clean crisp edges, mobile game
art, single centered object, light source from upper left.
BACKGROUND: solid flat magenta #FF00FF, uniform, no gradient, no shadow cast
on the background.
NEGATIVE: no transparency checkerboard, no text, no letters, no numbers, no
watermark, no UI frame, no multiple views, no photorealism, no photo.
OUTPUT: square 1:1, 1024x1024.
```

Três hábitos que ajudam mais que qualquer prompt:

1. **Gere tudo na mesma sessão.** Modelo troca de humor entre sessões.
2. **Use referência de estilo** se a ferramenta tiver (`--sref` no Midjourney,
   "style reference" no Leonardo/Scenario). Aponte para `cargueiro.png` —
   é o asset mais característico da leva que já entrou.
3. **Um objeto por imagem.** Folha com vários é um inferno pra recortar.

---

## 3. GRUPO A — Mapa, em peças (prioridade 1)

> **Por que em peças e não um mapa inteiro:** você quer píer construível. Se
> o píer estiver pintado dentro de uma imagem de fundo, ele não pode aparecer
> ao clicar em "ampliar". O mapa precisa ser montado no Godot a partir de
> peças, com os píeres como nós separados que ligam e desligam.

### A1 — Água (tile sem emenda)

```
Seamless tileable ocean water texture, tropical turquoise blue, gentle stylized
wave ripples, top-down view, repeating pattern with no visible seams.
[+ BLOCO DE ESTILO, trocando OUTPUT por: square 1:1, 1024x1024, seamless]
```

### A2 — Cais de concreto (trecho reto)

```
Concrete harbor quay edge section, straight horizontal piece, weathered pale
grey concrete, black rubber tire fenders hanging on the sea side, yellow safety
line painted on top.
[+ BLOCO DE ESTILO]
```

### A3 — Pátio de asfalto

```
Port yard ground piece, dark grey asphalt with faded white parking lines,
scattered small cracks, flat surface seen from above.
[+ BLOCO DE ESTILO]
```

### A4 — Escritório do porto

```
Small two-story port administration office building, white and pale blue walls,
terracotta roof, blue window frames, small entrance canopy, a couple of palm
trees at the base, modest and slightly worn, Brazilian coastal town.
[+ BLOCO DE ESTILO]
```

### A5 — Vaga de píer VAZIA (estado "por construir")

```
Empty unfinished pier foundation in shallow water, only a row of old wooden
pilings sticking out of the sea, no deck planks, no railing, abandoned and
weathered, clearly incomplete construction site.
[+ BLOCO DE ESTILO]
```

### A6 — Píer CONSTRUÍDO

```
Finished wooden pier dock, horizontal walkway of warm brown timber planks,
sturdy pilings, mooring bollards at the end, small rope coil, clean and in good
repair, extending from left to right.
[+ BLOCO DE ESTILO]
```

> A5 e A6 precisam ter **o mesmo comprimento, ângulo e posição das estacas**,
> porque um substitui o outro no mesmo lugar. Gere os dois em sequência e, se a
> ferramenta permitir, use A5 como imagem de referência ao gerar A6.

### A7 — Boia de amarração

```
Red harbor mooring buoy floating in water, white top stripe, small metal ring
on top, gentle water ripple around the base.
[+ BLOCO DE ESTILO]
```

### A8 — Marcador de fundeadouro

```
Anchorage marker for a waiting zone, a white dashed circle outline on water
with a simple white anchor symbol in the center, flat marker graphic overlaid
on the sea.
[+ BLOCO DE ESTILO]
```

---

## 4. GRUPO B — Indicadores do HUD (prioridade 2)

> **Este grupo NÃO vai para o gerador de imagem — vai para o Claude Design**
> (ver §1b). Já está desenhado: os oito abaixo existem em vetor, na paleta do
> jogo, e podem virar `.svg` no repositório quando você aprovar.
>
> A tabela abaixo fica registrada como a especificação do conjunto: é o que
> cada ícone representa e onde o jogo o lê. Os prompts de gerador ficam só
> como plano B, caso você prefira o caminho raster.

São os oito que o jogo **realmente lê** hoje. Um por imagem.

Acrescente ao bloco de estilo: `game UI icon, bold silhouette, readable at
48 pixels, centered, no text`.

| # | Ícone | Prompt do objeto | Onde aparece |
|---|---|---|---|
| B1 | Caixa | `bag of money with a Brazilian real R$ symbol, golden coins spilling` | HUD topo |
| B2 | Dia / turno | `desk calendar page with a folded corner, sun rising behind it` | HUD topo |
| B3 | Reputação | `two hands shaking, warm and friendly, golden star above` | Cartão de reputação |
| B4 | Trabalhador | `yellow construction hard hat, front view, slight tilt` | Contador de trabalhadores |
| B5 | Doca | `black iron mooring bollard with a rope loop around it` | Contador de docas |
| B6 | Barco | `small cargo ship silhouette seen from the side, simple and bold` | Contador de barcos |
| B7 | Parcela | `old bank building with columns, small red overdue stamp on the corner` | Barra da parcela do Sr. Ribeiro |
| B8 | Ampliar píer | `crossed hammer and wrench over a wooden plank, construction icon` | Botão "Ampliar píer" |

> B7 é o único com carga emocional: é o indicador da dívida com o Sr. Ribeiro,
> a única forma de perder o jogo. Vale ele ser um pouco mais pesado que os
> outros.

---

## 5. GRUPO C — Personagens (prioridade 3)

**Só dois personagens têm tela na Fase 1.** Confirmei no código: `Arlindo` e
`Ribeiro` aparecem em `GameState.gd`, `CounterOfferPanel.gd` e
`DebtPaymentPanel.gd`. **Dona Cida não existe no VS** — o plano de produção
manda começar por ela, mas isso vale para o jogo completo. Gerar Dona Cida
agora é arte sem tela onde aparecer.

### C1 — Arlindo, o rival (3 expressões)

Esta é a de maior valor: a mood face de 3 estados está **especificada no GDD e
implementada na mecânica** (`RIVAL_PATIENCE = 2`). Hoje o jogo desenha isso com
emoji (🙂 / 😟).

Gere **as três com a mesma pose, enquadramento e roupa** — só a expressão muda.
Retrato da cabeça aos ombros.

```
C1a  NEUTRO
Portrait bust of a middle-aged Brazilian businessman, shrewd competitor,
slicked dark hair, thin moustache, open collar shirt with a gold chain,
neutral attentive expression, listening, arms not visible.
[+ BLOCO DE ESTILO, trocando 3/4 top-down isometric view por: 3/4 portrait view]

C1b  IMPACIENTE   (mesma pose, mesma roupa, só a cara muda)
...frowning slightly, impatient, one eyebrow raised, losing patience.

C1c  INDO EMBORA  (mesma pose, mesma roupa, só a cara muda)
...turning away with a dismissive look, done negotiating, walking off.
```

### C2 — Sr. Ribeiro, o banco

```
Portrait bust of an elderly Brazilian bank manager, grey hair, round glasses,
formal suit and tie, calm but unyielding expression, holding a folded document.
[+ BLOCO DE ESTILO, trocando a vista por: 3/4 portrait view]
```

---

## 6. GRUPO D — Cenário (opcional, enriquece o mapa)

```
D1  Coconut palm tree seen from a high 3/4 angle, lush green fronds, curved trunk, tropical.
D2  Stack of shipping containers, red blue and green, weathered metal, stacked two high.
D3  Wooden cargo crates, a few stacked, rope and stencil marks, no readable text.
[+ BLOCO DE ESTILO em todos]
```

---

## 7. Depois de gerar

1. Jogue todos os PNGs numa pasta só.
2. Rode:
   ```
   python3 tools/preparar_sprites.py <pasta_gerada> brport_vs/art/sprites
   ```
3. Confira a coluna `fundo` na saída. Tem que dizer **`sólido`**. Se disser
   `quadriculado`, o gerador ignorou o pedido de magenta — refaça o prompt.
4. Me mande, que eu integro nas cenas.

Tamanhos: o script usa 512px de maior lado por padrão. Ícones de HUD podem ir
menores (`--lado=128`).

---

## 8. O píer construível — o que muda no jogo

Sua ideia: **começar com 1 píer e construir até 3**. Hoje o código faz outra
coisa:

| Hoje (`GameState.gd`) | Sua proposta |
|---|---|
| `DOCKS_BASE = 2` | começa com **1** |
| Upgrade único (`upgrade_purchased` é bool) | upgrade **repetível**, até 3 |
| `UPGRADE_COST = 400`, +1 doca +1 trabalhador | provavelmente custo crescente |

O que isso exige em código, quando você mandar:

- `upgrade_purchased` vira contador, e o limite passa a ser `docks.size() < 3`
- O mapa ganha **3 vagas fixas**: cada uma mostra A5 (vazia) ou A6 (construída)
- O botão "Ampliar píer" some quando chegar em 3
- O autosave já grava `docks` como lista, então ele acompanha sozinho

### O aviso que você já previu

Você disse "depois vemos como equilibrar a economia com isso" — está certo, mas
vale dimensionar o estrago antes:

- **Começar com 1 doca em vez de 2 corta a vazão inicial pela metade.** Barco é
  a única fonte de receita variável; o píer (`PIER_SLOTS × PIER_RATE` =
  R$240/semana) é fixo e não muda com isso.
- **A medição do Bloco 3 deixa de valer.** Aqueles 99,7% / 63,8% / 0,7% foram
  medidos com 2 docas e um upgrade único. Com 1 doca inicial, o perfil mediano
  provavelmente cai bem abaixo dos 63,8%.
- **Tem uma pergunta de design junto:** com 1 doca, os 2 trabalhadores iniciais
  custam R$200/semana e só um trabalha. Ou começa com 1 trabalhador, ou o
  segundo vira peso morto até o primeiro upgrade.

Nada disso é impeditivo — é só trabalho de recalibragem, e a ferramenta para
fazer isso já existe:

```
Godot --headless --path brport_vs --script res://tools/simular_balanceamento.gd -- 800
```

Ele é determinístico por semente, então dá para mudar as constantes e comparar
com a mesma semente, sem ruído de sorteio. **Quando você decidir os números
(custo por píer, trabalhadores iniciais), eu implemento e meço antes e depois.**

---

*BR Port · Guia de geração de assets · Fase 4, Bloco 4*
