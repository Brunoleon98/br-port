# BR Port — pesquisa de melhorias: luz, animação, som e o resto

**29/10/2026 — pesquisa, decisão `143`.** É o primeiro dos três tempos do
bloco que o Bruno escolheu nesse dia (§7 do plano): pesquisar, aprofundar
cada tema numa conversa própria, e só então implementar, um item por
conversa. **Nenhuma linha de jogo mudou para escrever isto.** Os temas a
aprofundar e a ordem são dele; a ordem do fim é uma recomendação.

## Método, e o que ele não prova

**O jogo de hoje foi medido antes de pesquisar**, na `main` `d310922` (PR
#154) com os dois commits só de documento da branch
`claude/br-port-continuacao-72yq7v`, neste contêiner:

- **duas fotos a 1080×1920**, pelo `capturar_tela.gd` com `--fixed-fps 60`:
  o dia 1 (`-- 0 limpo atracar`) e o porto completo no dia 11 (`-- 10
  completo limpo atracar`, oito estruturas);
- **o inventário de luz e de som pelo código**: nós de luz, shaders, o rig do
  Blender, o mapa em SVG, a tabela de sons e os gatilhos;
- **uma sonda de animação** (fora do repositório, como a da `142`): monta o
  `Main` como o `capturar_tela.gd` (semente 12345, nomes, `completo`), espera
  30 frames, lê cada `CanvasItem` a cada 6 frames durante 1.200 (20 s a 60
  fps fixos) — posição e rotação globais, escala, alfa, cor, visível, textura
  e texto — e depois toca no «Avançar dia» duas vezes, lendo a cada 3 frames;
- **as duas réguas que já existem**: `medir_desempenho.gd` (`DESEMPENHO
  MEDIDO`) e `tools/medir_audio.py` (`SINAL OK`).

**A pesquisa passou pela ferramenta de busca, e nenhuma página foi lida.** O
proxy destas sessões bloqueia boa parte delas (`gerais.md`, Ambiente); cada
fonte abaixo é **pista de padrão**, citada pelo resumo que a busca devolveu.
Números de terceiros (limites de luz, faixas de frequência, durações) não
foram conferidos e estão marcados como tal. O custo de cada técnica é
**julgamento relativo** a partir do código, sem prazo medido; o ganho é
hipótese até à foto, à escuta ou ao telefone, que são os gates de sempre
(A5, A6, A7).

## O resumo, por tema

| Tema | O que o jogo tem hoje (medido) | A técnica mais barata que muda isso | Gate |
|---|---|---|---|
| **Iluminação** | Meio-dia permanente: zero nós de luz, nenhuma hora do dia; a luz está cozida no Blender e no SVG; a única «luz» viva são 16 lâmpadas a pulsar de dia | Tingir só o mapa pela hora, na virada do dia (L1), e acender janelas e postes numa camada aditiva (L3) | Olhar (A5); reabre o aceite visual do mapa |
| **Animação** | Em 20 s parado, ~40% dos nós visíveis mexem: mata, coqueiros, água, barcos, camiões, fauna, a máquina do píer. Parados: vila, estruturas, carros, carga, o rolar do casco | Juice no toque (atracar, avançar, obra pronta) e o barco que desliza do largo ao berço, que a `083` deixou para depois (A1, A3) | Olhar |
| **Som** | 14 efeitos de rascunho, ninguém os ouviu; sem música, sem variação, sem posição; 6 de 14 vivem abaixo de 500 Hz | Variantes com o `AudioStreamRandomizer` (S1) e a mix para o alto-falante do telefone (S4) | **Ouvir (A6), só o Bruno** |
| **Toque** | Sem háptica nenhuma | `Input.vibrate_handheld` em três momentos, com opção nos Ajustes (T1) | O telefone |
| **Clareza e ritmo** | Tutorial do dia 1, Como jogar, Meu porto agora; zero partidas humanas gravadas em `playtest/` | Ajuda contextual na primeira vez de cada sistema (o RB7 da `112`) | A4 (ler) e A7 (jogar) |
| **Interface** | O «Pausar» no canto superior direito; o berço que um toque enche só se distingue pela cor | Mover o «Pausar» para a zona do polegar; um segundo canal além da cor (I1, X1) | Olhar e o telefone |
| **Desempenho** | 406 chamadas de desenho no dia 1 (eram 273 em 11/10) e 99 tweens vivos (eram 20) | Medir o lote: as máscaras por instância quebram o batching? (D1) | O FPS no telefone (A7) |

---

## 1. Iluminação

### O que existe (medido)

- **Nenhum nó de luz.** Nem `PointLight2D`, `DirectionalLight2D`,
  `CanvasModulate`, `LightOccluder2D` nem `WorldEnvironment`, em cena ou
  script. Nada no jogo fala de noite, entardecer ou amanhecer: **é meio-dia
  sempre**, e o dia que vira é um turno, sem relógio.
- **A luz está cozida em dois sítios, e os dois concordam de propósito.**
  - **Os props**: o rig de três pontos do `gerar_props_iso.py` — chave `SUN`
    de 3,4 a 48°/28°, cor quente (1,0; 0,93; 0,82); enchimento de área frio
    (0,62; 0,75; 1,0) a 150, que tira o preto da sombra; contraluz de área a
    420, que faz o trabalho de um contorno; mundo (0,60; 0,68; 0,80) a 0,42.
    A sombra de contato é outro passe (`render_sombra`), com azimute próprio
    (250°) para cair à frente da peça — uma inconsistência assumida no
    comentário: *«a sombra aqui não existe para dizer de onde vem o sol»*.
  - **O mapa**: o SVG pinta as faces à mão (a +mx mais escura que a +my),
    as sombras de volume (`SOMBRA_OPACIDADE` 0,26), a do muro do cais, o
    `SOL_DO_MORRO` e os gradientes radiais do mar da `124`.
- **A única luz animada é de dia.** `_animar_luzes()` faz as lâmpadas de
  sódio dos postes velhos baterem (alfa 1,0 → 0,82, ciclo de 4,5 s): a sonda
  leu 16 (1 no `Cenario`, 15 na `RedeDaRua`). Não iluminam nada à volta.
- **Seis shaders, nenhum de luz**: `papel`, `tinta`, `couro`,
  `folha_virando`, `circulo` (interface) e `vila_a_frente` (máscara).
- **O renderer é o `gl_compatibility`**, no telefone e no Web.
- ⚠️ **O HUD e o mapa são irmãos no mesmo canvas** (`Main` é um `Control`,
  `MapaWrap` e `BarraDocas` filhos dele). Um `CanvasModulate` tingiria a
  interface; quem tinge só o mundo é o `modulate` do `MapaWrap`, que desce
  aos filhos — **e um deles é o `Ganhos`, o «+R$»**, cujo contraste passaria
  a depender da hora.

### Técnicas achadas

**L1 — Tinta de hora do dia por gradiente.** O padrão é amostrar um
`Gradient` pela hora e escrever a cor num `CanvasModulate` (ou, aqui, no
`modulate` do `MapaWrap`); no Godot 4 a amostra é `gradiente.gradient.sample()`
quando o recurso é um `GradientTexture1D`, e um `CanvasModulate` escurece
também as luzes 2D, salvo `light_mode` «Replace». Pistas:
[gist de bitbrain](https://gist.github.com/bitbrain/605b77bcbf15e2d2ddb61dfd6c2d851c),
[fórum Godot, gradiente](https://forum.godotengine.org/t/not-sure-how-to-use-gradients-in-texturerect/105682),
[addon 2D de thowsenmedia](https://thowsenmedia.itch.io/godot-day-night-2d-system),
[GameDev Academy](https://gamedevacademy.org/godot-day-night-cycle/),
[bugnet, CanvasModulate e Light2D](https://bugnet.io/blog/fix-godot-canvas-modulate-affects-light2d-energy).

**L2 — Gradação por LUT, duas a misturar pela hora.** Em vez de multiplicar
por uma cor, remapeia-se a paleta: a noite vira azul em vez de escura, e o
entardecer aquece os claros sem queimar os escuros. Pistas:
[fórum Godot, color grade](https://forum.godotengine.org/t/how-to-color-grade-in-godot-3/9886),
[godot-color-lut-shader](https://github.imc.re/thiagoamendola/godot-color-lut-shader),
[ReShade, Adaptive Color Grading](https://reshade.me/forum/shader-presentation/2890-adaptive-color-grading).

**L3 — Luz falsa: sprites de brilho em blend aditivo.** Janelas acesas,
halos de poste e luzes de navegação desenhadas como sprites aditivos por cima
de uma tinta escura; o aditivo não emporcalha onde dois halos se sobrepõem.
Os avisos: um mapa de sombra aditivo inverteu cores nas zonas escuras do
Disco Elysium, e brilho recolorido por `modulate` lê mal. Pistas:
[resposta do Game Dev SE](https://backiee.wasmer.app/http_gamedev_stackexchange_com/a/6896),
[Innkeep](https://www.moddb.com/games/innkeep/features/innkeep-making-basic-lighting-in-a-2d-game),
[Mayhem in Single Valley](https://gamedeveloper.com/design/the-darkside-and-the-light-the-anatomy-of-a-room-in-mayhem-in-single-valley),
[Disco Elysium](https://discoelysium.com/devblog/2016/02/02/shedding-light),
[fórum Construct](https://construct.net/en/forum/game-development/game-development-design-ideas-25/faked-lighting-87307).

**L4 — Luz 2D de verdade, com normal map.** `PointLight2D` sobre
`CanvasTexture` com mapa de normais; o Godot espera X+, Y+, Z+. Os limites
que a busca devolveu são de fórum e de issue, não de documentação: 16 luzes
por chamada de desenho, 64 por viewport no telefone; e numa GPU de
telefone por tiles cada luz obriga a redesenhar os tiles que toca. Tirar o
mapa de normais do Blender não é receita pronta, e em prédio isométrico ele
sai com um gradiente que arredonda a face. Pistas:
[doc do CanvasTexture](https://docs.godotengine.org/en/4.4/classes/class_canvastexture.html),
[issue 90905](https://www.github.com/godotengine/godot/issues/90905),
[otimização mobile](https://slicker.me/godot/mobile-optimization.html),
[OpenGameArt](https://opengameart.org/node/35487),
[fórum LÖVE](https://www.love2d.org/forums/viewtopic.php?p=178719),
[Laigter](https://laigter.readthedocs.io/en/latest/Introduction/intro.html).

**L5 — Sombra de nuvem.** Uma camada multiplicativa animada, como as de
Mayhem in Single Valley, a passar devagar sobre o mapa. É inferência a partir
dessa pista, não técnica que a busca tenha descrito para nuvens.

### O que custaria aqui, e o que ganharia

| | Usa o que existe | Mexe em | Custo | Ganho |
|---|---|---|---|---|
| **L1** | O `MapaWrap` como raiz do mundo; a virada do dia (`078`) como o instante natural; o `MovimentoDeFundo` do RB6 | `Main.gd` (um tween de cor); nada no mapa, nos props ou no save — a hora sai do turno | **Baixo** | O turno ganha um marco visual que hoje não tem |
| **L2** | O mesmo | Um shader novo por cima do mapa (leitura de tela ou material do `MapaWrap`) e duas texturas de LUT | Médio; a leitura de tela no Web e no telefone é a medir | Noite e fim de tarde com cor, e não só mais escuros |
| **L3** | As lâmpadas de sódio e a cor `sodio` (#f2a54a) do mobiliário; as camadas de SVG que a `142` criou para as marolas | Uma camada nova do `gerar_mapa_iso.py` (as janelas da vila são SVG), o raster que o CI compara byte a byte (`mapa.md`), uma textura a 1080 a mais (`medir_vram.gd`), `CanvasItemMaterial` aditivo sem shader | Médio | É o que faz a noite valer a pena: o porto aceso |
| **L4** | O estúdio do Blender | Um passe de normais em cada um dos props, o dobro de textura por prop, o mapa SVG sem normais (ficaria chapado ao lado), os limites do Compatibility | **Alto** | Luz que se mexe; não compensa antes do resto |
| **L5** | O `MovimentoDeFundo` | Uma textura e um tween; um quad do tamanho do mapa por cima de tudo (sobredesenho a medir) | Baixo | Vida sobre o que está parado |

**As perguntas que a conversa do tema tem de levar ao Bruno, porque são
dele:** o que é a «hora» num jogo de turnos sem relógio — (a) a virada passa
pelo anoitecer e pelo amanhecer no 1,2 s que já dura; (b) um ciclo lento em
tempo real, decorativo; (c) uma hora fixa por fase ou por semana —; e se a
noite pode existir de todo, porque **toda a arte aceite (A5) foi aceite ao
meio-dia**, e uma tinta reabre esse aceite. Com o movimento reduzido (RB6) o
ciclo pára; e o `+R$` mede-se contra o mapa tingido.

---

## 2. Animação

### O que existe (medido pela sonda)

| Estado | Nós visíveis | Mexem em 20 s |
|---|---|---|
| Dia 1, sem atracar | 314 | 136 |
| Porto completo, sem atracar | 318 | 123 |
| Porto completo, com os barcos atracados | 310 | 124 |

(Os nove alvos de toque da fauna andam com ela e contam na soma.)

**O que mexe parado:** as 62 árvores da mata (posição e rotação,
`MataNoMapa`), as copas dos 3 coqueiros (rotação), as 16 lâmpadas (alfa), as
2 camadas de espuma e as 2 de marolas (posição e alfa, `142`), os 2 barcos ao
largo e as 2 boias da ancoragem (sobem e descem), os 5 camiões (posição e a
troca de textura na curva), a lança de cada guindaste (rotação, ou troca de
quadro quando opera), **o barco atracado (5 px em 1,7 s, `Dock.gd`)**, a
empilhadeira, o garfo e a carga quando há trabalhador, o píer que acende e os
cartões da fila (cor), e a fauna nos nove pontos (aparecer, andar, sair).

**O que está parado:** as casas, a igreja e a praça, as oito estruturas, os
carros da viela (`141`), os contentores e a carga do pátio, o trabalhador
quando não opera, o mar fora das duas camadas (o campo de cor é SVG), e
ninguém anda na vila. Nenhum fumo, nenhuma partícula, nenhum
`AnimationPlayer` ou `AnimatedSprite2D`: **tudo o que mexe é tween** (9
sítios no `Main.gd`, 8 no `Dock.gd`, 2 no `TrafegoDeCamioes.gd`, 1 em cinco
outros) ou o `_process` da `Fauna`.

**Na virada do dia** (dois toques no «Avançar dia»): o barco servido sai
(posição, alfa, textura), o «+R$» sobe e desfaz-se, o caixa conta durante
1,2 s, os barcos ao largo trocam, e o HUD e os cartões reescrevem-se de uma
vez. É a escolha do Bruno na `078`.

**O que custa hoje** (`medir_desempenho.gd`, 29/10): 99 tweens vivos no dia
1 e 102 a meio, contra 20 em 11/10 (`099`); a mata cria um por árvore, e
são 62. O script continua barato (0,036 ms por quadro no dia 1); **o que
cresceu foi o desenho** (ver §4.5).

### Técnicas achadas

**A1 — Juice: o retorno por cima da mecânica.** Tween com easing em vez de
saltar, «pop» com overshoot no toque, squash and stretch onde o objeto é
mole. O contraponto vale aqui: pedra e construção não abanam. Pistas:
[resumo do «Juice it or Lose it»](https://rpgplayground.com/research-making-a-juicy-game/),
[GameAnalytics](https://www.gameanalytics.com/blog/squeezing-more-juice-out-of-your-game-design),
[as lições do talk](https://gamejuice.pages.dev/articles/juice-it-or-lose-it-lessons),
[Wayline](https://www.wayline.io/learn/game-feel/1).

**A2 — O balanço das árvores num shader de vértice.** Deslocar o topo do
sprite por um seno de `TIME` pesado pela altura (o pé fica onde está), com a
fase tirada da posição no mundo para todas partilharem um material. Um dos
shaders da busca usa `REGION_RECT` para não sangrar num atlas, e diz que ele
só existe desde a 4.5. Pistas:
[2D wind sway](https://godotshaders.com/shader/2d-wind-sway/),
[pixel perfect wind & sway](https://godotshaders.com/shader/2d-pixel-perfect-wind-sway-effect/),
[Kodeco](https://www.kodeco.com/43354079-introduction-to-shaders-in-godot-4?page=3).

**A3 — O barco que boia.** Sobe e desce por senos sobrepostos, com um rolar
pequeno tirado da mesma onda, para o inclinar acompanhar o subir; amplitude e
frequência modestas, senão parece agitado. Pistas:
[Maya, objetos a flutuar](https://download.autodesk.com/us/maya/2011help/files/Creating_an_ocean_effect_Floating_objects.htm),
[Unity, movimento de navio](https://discussions.unity.com/t/realistic-ship-floating-motion/674925),
[Roblox, inclinar o barco](https://devforum.roblox.com/t/how-would-i-go-about-making-this-boat-tilt-in-the-water/1239625).

**A4 — Partículas leves: fumo, poeira, borrifo.** A documentação recomenda
`GPUParticles2D`; blogs dizem que no Compatibility e no Web o seguro é
`CPUParticles2D` — não confirmado contra a documentação da 4.6. Um emissor de
fumo é de contagem baixa, e o CPU chega. Pistas:
[doc de partículas 2D](https://docs.godotengine.org/fr/4.5/tutorials/2d/particle_systems_2d.html),
[bugnet, partículas no celular](https://bugnet.io/blog/fix-godot-gpu-particles-not-rendering-mobile).

**A5 — Gente e coisas miúdas na vila.** A escala miniatura lê-se pelos
carros, pessoas e bancas pequenas; animar gente em isométrico pede as oito
direções, e as diagonais são as caras. Pistas:
[devlog de um pacote isométrico](https://supernovafiles.itch.io/isometric-asset-pack/devlog/852892/idle-animation-updated),
[Omicrocity 2](https://www.vgdb.co/games/omicrocity-2).

### O que custaria aqui, e o que ganharia

| | Usa o que existe | Mexe em | Custo | Ganho |
|---|---|---|---|---|
| **A1** | Os tweens do `Main.gd` e do `Dock.gd`; o `MovimentoDeFundo`; a virada da `078` | O toque no barco ao largo, o «Avançar dia», a obra que acaba (`obra_concluida`); nada no save nem na economia | **Baixo** | O toque responde: é onde o jogador está a olhar (✅ `148`: a peça assenta de 94% e a obra esvai-se; o botão e o cartão afundam — por estilo, não por escala, que o contentor a desfaz) |
| **A1′** — o barco que desliza do largo ao berço | A fila no fundeadouro (`083`) e a troca de barco do `Dock.gd` | O rumo (a `078` registou que um rumo antigo atravessava o píer), a ordem do nó (`projecao.md`), a foto de um instante do deslize | Médio | O barco vai de onde foi tocado até ao berço; hoje entra pelo lado do mar (`RUMO_DO_MAR`, `078`), longe do toque (⚠️ medido na `144`: aparecia no berço no quadro do toque, e a chegada da `078` morria no mesmo `refresh()`) |
| **A2** | A mata da `127`/`130`; o atlas da `049` | Um shader novo (um tiro na bateria que o desenhe, `interface.md`), os 62 tweens a sair (a `MataNoMapa` cria um por árvore), e uma sonda como a do D51, que lê o movimento com `custom_step` | Médio | Menos tweens e a copa a dobrar em vez de rodar inteira |
| **A3** | O balanço de 5 px do `Dock.gd` | Um rolar pequeno no casco; a carga do convés e o «+R$», que nascem dele; o camião que encosta de ré | Baixo | O porto atracado, que é o assunto, deixa de ser rígido |
| **A4** | Nada (seria o primeiro sistema de partículas) | `CPUParticles2D` com semente fixa, senão a bateria deixa de ser byte a byte (`captura.md`); o RB6 tem de as parar | Médio | Fumo dos cargueiros e poeira da obra contam que há motor |
| **A5** | O trabalhador a 1,5× (`069`), as rotas do `TrafegoDeCamioes`, a máscara `vila_a_frente` | Props novos no Blender em várias direções, rotas na calçada, ordem de nó na vila | **Alto** | A cidade atrás do porto vive; é o maior ganho e o maior custo |

---

## 3. Som

### O que existe (medido)

- **14 efeitos de rascunho, gerados por `tools/gerar_sons.py`** só com a
  biblioteca padrão, e **ninguém os ouviu** (A6 aberto; protocolo em
  `docs/PROTOCOLO_DE_ESCUTA.md`). O `medir_audio.py` dá `SINAL OK`: duram de
  90 ms (clique) a 3.600 ms (mar); **seis vivem sobretudo abaixo de 500 Hz**
  — obra 92%, navio 100%, aviso 99%, erro 88%, derrota 80%, mergulho 72%; e
  três no pior alinhamento somam +7,68 dBTP, que é o teto aritmético e não
  a mix.
- **O encanamento é bom e pequeno**: `Audio.tocar(id)` com prioridade e
  espera mínima por som; dois buses (`Musica`, `SFX`) com sliders. Os
  gatilhos: `message`, a chegada de barcos (navio), o caixa (moeda), a compra
  (obra), a oferta do rival e a cobrança (alerta), o fim (vitória/derrota);
  um clique em **todo** botão, ligado pelo `node_added`; o mar a cada ≥5,5 s
  e a fauna.
- **O que não existe:** música (o bus `Musica` está vazio), variação (cada
  som é um arquivo só, sem altura nem volume sorteados), posição (nada é
  `AudioStreamPlayer2D`), ambiente por zona (cidade, maquinaria, obra), e um
  som próprio da virada do dia.

### Técnicas achadas

**S1 — Variação contra a fadiga.** O `AudioStreamRandomizer` sorteia entre
variantes sem repetir a anterior e varia altura e volume; com uma variante
só, repete sempre. Pistas:
[doc do AudioStreamRandomizer, 4.6](https://docs.godotengine.org/en/4.6/classes/class_audiostreamrandomizer.html),
[GameDev Academy](https://gamedevacademy.org/audiostreamrandomizer-in-godot-complete-guide/).

**S2 — Ambiente em camadas.** Um leito em laço e, por cima, sons curtos
espalhados com tempo, altura e volume aleatórios; camadas que entram e saem
por condição, e o mesmo material misturado de dia e de noite. O que é próprio
de um porto (cordame, buzina, água no casco, guindaste) a busca não deu: é
juízo de design. Pistas:
[Splice](https://splice.com/blog/audio-soundscape-for-video-games),
[tutorial do Roblox](https://devforum.roblox.com/t/ambientsorcery%E2%80%99s-tutorial-1-creating-compelling-environmental-audio/3507022),
[CreatorSounds Pro](https://creatorsoundspro.com/building-immersive-rpg-worlds-layering-ambient-loops-for-maximum-realism).

**S3 — Som posicional.** `AudioStreamPlayer2D` com o ouvinte no centro da
tela, atenuação e pan: com a câmera fixa, diria ONDE (a gaivota no norte, o
camião que sobe). Pista:
[doc do AudioStreamPlayer2D](https://docs.godotengine.org/en/4.4/classes/class_audiostreamplayer2d.html).

**S4 — A mix para o alto-falante do telefone.** O essencial entre ~400 Hz e
6 kHz; saturação e harmónicos para sugerir o grave que o alto-falante não dá;
compatível em mono; e testar no aparelho. A busca deu cortes diferentes
(«muitos caem por volta de 800 Hz», «4–5 kHz salientes») e nenhum medido
aqui. É exatamente a pergunta do §4 do protocolo de escuta: o aviso tem 99%
da energia abaixo de 500 Hz. Pistas:
[Waves, mixes para alto-falante pequeno](https://www.waves.com/tips-for-great-mixes-on-small-speakers),
[Game Developer, áudio para mobile](https://www.gamedeveloper.com/audio/making-good-sounding-audio-for-mobile-games),
[Audiokinetic, resposta de celulares](https://www.audiokinetic.com/fr/blog/loudness-and-frequency-response-on-popular-smart-phones),
[Mighty Bear](https://medium.com/mighty-bear-games/quick-tips-for-mobile-game-audio-success-eac6b5f38bd9).

**S5 — Música adaptativa.** Camadas verticais (instrumentos que entram com o
porto) e resequenciamento horizontal para mudanças de estado (a cobrança, o
fim de fase). A 4.3 acrescentou ao motor streams interativos e sincronizados
— de memória, por confirmar na documentação da 4.6. Pistas:
[IRPR, camadas verticais](https://sounddesign.irpr.agency/glossary/vertical-layering/),
[IRPR, resequenciamento](https://sounddesign.irpr.agency/glossary/horizontal-resequencing/),
[Audiokinetic, música interativa](https://www.audiokinetic.com/en/blog/how-to-use-interactive-music-to-score-gameplay/),
[godot-nsound](https://github.com/nyxkn/godot-nsound).

**S6 — Earcons: poucos, curtos e distintos, e o silêncio como escolha.** O
som decorativo usa-se pouco; o que toca mais tem de aguentar a repetição.
Pistas:
[Material, som na interface](https://m2.material.io/design/sound/applying-sound-to-ui.html),
[Glasgow, guia de earcons](https://www.dcs.gla.ac.uk/~stephen/earcon_guidelines.shtml),
[Google, earcons](https://developers.google.cn/assistant/conversation-design/earcons).
Aqui toca na decisão de dar clique a todo botão.

### O que custaria aqui, e o que ganharia

| | Usa o que existe | Mexe em | Custo | Ganho |
|---|---|---|---|---|
| **S1** | `gerar_sons.py` (as variantes saem por semente); `Audio.tocar()` | O stream de cada id, o `teste_audio` (o encanamento) e o `medir_audio` (cada variante) | **Baixo** | O clique e a moeda deixam de cansar |
| **S2** | O `AmbienteCosteiro` e a espera por som | Leitos novos gerados (água no casco, motor de camião, guindaste, sino da igreja?), um gestor de camadas por estado do porto | Médio | O porto soa a porto, e cresce com ele |
| **S3** | A projeção sabe onde está cada coisa | Os ids de mundo passam a nós no mapa; a prioridade por frame continua a valer | Médio | Pouco no alto-falante mono; bom com fone de ouvido |
| **S4** | O `medir_audio.py` já mede a fração abaixo de 500 Hz | A síntese de seis sons, com harmónicos acima do fundamental | Baixo a médio | Os sons que hoje talvez não se ouçam passam a ouvir-se |
| **S5** | O bus `Musica` e o slider | Música não se gera com a biblioteca padrão: compositor ou faixas com licença (créditos do RB8) | **Alto** | Ritmo e humor; é o «para depois» do estado |
| **S6** | — | Perguntar que botões merecem clique | Baixo | Menos ruído |

⚠️ **Nada disto se aceita sem o A6.** Este contêiner não tem placa de som:
a conversa do tema pode desenhar e medir, e a escuta é do Bruno, pelo
protocolo — e é por isso que o som pode correr em paralelo com o resto
enquanto espera por ele.

---

## 4. Os outros aspetos

### 4.1 A resposta ao toque — háptica

**Medido:** nenhuma chamada de vibração no jogo. **Técnica (T1):** pouca e
clara — a háptica cansa a mão, e vale nos momentos que importam; o
`Input.vibrate_handheld(ms, amplitude)` existe no Android, iOS 13+ e Web, e
no Android pede a permissão `VIBRATE` no preset de exportação. Pistas:
[Android, princípios de háptica](https://developer.android.com/develop/ui/views/haptics/haptics-principles),
[fórum Godot, vibração na 4.4](https://forum.godotengine.org/t/how-to-enable-vibration-in-godot-4-4/107740),
[Waterloo, háptica «juicy»](https://uwspace.uwaterloo.ca/handle/10012/16894).
**Custo aqui:** baixo — um ponto único como o `Audio.gd`, a permissão no
`export_presets.cfg` (`plataforma.md`), uma opção nos Ajustes, nas
preferências de apresentação e fora do save da partida. Nenhuma suíte a
sente: o gate é o telefone. **Ganho:** atracar, a obra pronta e a parcela
paga sentem-se. Casa com o A1.

### 4.2 A clareza do que fazer

**Medido:** o tutorial do Toninho (dia 1), o Como jogar (RB1) e o Meu porto
agora (RB2) estão no jogo; a ajuda contextual (RB7 da `112`) não. **Técnica
(C1):** uma ideia de cada vez, ensinada quando o sistema fica relevante — o
armazém na semana 2, o pátio na 5, a treliça na Fase 2. Pistas fracas, de
blogs de produto:
[guia de onboarding](https://mwm.ai/guides/app-onboarding-best-practices),
[definir o objetivo do onboarding](https://help.customerhub.com/en/articles/12997290-define-your-onboarding-goal).
**Custo aqui:** médio — falas novas no `Narrativa.gd` com o gatilho no mesmo
commit (`narrativa.md`), e a leitura do A4. **Ganho:** é o que o playtest de
setembro pedia, mas o A7 de hoje não tem uma partida humana gravada
(`playtest/` só tem o README): medir antes de escrever.

### 4.3 O ritmo e a progressão

**Medido:** o laço do dia é um toque (atracar) e um «Avançar dia»; a Fase 1
dura 84 dias. **Técnica (R1):** laços em escalas de tempo — retorno a cada
30–90 s e uma meta de vários dias —, a sessão a acabar num momento bom, e a
causa à vista entre investir e ganhar. Pistas de guias, sem medição:
[GTSTU, progressão](https://gtstu.com/game-progression-system-design-keep-players-hooked/),
[modelo de tycoon](https://summerengine.com/templates/simulation/tycoon/tycoon).
**Custo aqui:** é economia (`/balancear`, `005`, `108`) e precisa do ritmo
HUMANO, que é do A7. **Não se mexe antes de duas pessoas jogarem.**

### 4.4 A interface

**Medido na foto:** o «AVANÇAR DIA» está no terço de baixo, onde o polegar
chega; o **«Pausar» está no canto superior direito**, a zona que um polegar
só alcança mudando a mão; os alvos já têm 44 px (`interface.md`). **Técnica
(I1):** a ação frequente no terço de baixo, as esquinas de cima para o que
se usa pouco, a ação destrutiva fora da zona fácil. Pistas:
[artigo da CMS Conferences](https://openaccess-api.cms-conferences.org/articles/download/978-1-964867-13-7_13),
[Parachute Design](https://parachutedesign.ca/blog/thumb-zone-ux/).
**Custo aqui:** baixo a médio — o «Pausar» abre o menu de pausa, por onde
saem a ajuda e a gravação; o D43 mede a hierarquia do rodapé. **Ganho:**
pequeno e certo.

### 4.5 O desempenho no telefone

**Medido hoje** (`medir_desempenho.gd`, 29/10, `xvfb-run`):

| | Abertura (dia 1) | Meio (exemplo v18, dia 99) |
|---|---|---|
| Chamadas de desenho por quadro | **405,7** (403–409) | **604,0** (601–607) |
| Objetos · primitivas | 760,8 · 8.692,7 | 1.003,3 · 10.042,2 |
| Nós · tweens vivos | 386 · 99 | 386 · 102 |
| Script por quadro | 0,036 ms | 0,019 ms |

A abertura compara-se com a de 11/10 (`099`): **273 → 406 chamadas, 225 →
386 nós, 20 → 99 tweens**, com a mata, o mobiliário, os carros e as marolas
pelo meio. O «meio» de então era o exemplo v14 no dia 30, outro estado, e
não se compara. **Técnica (D1):** o Compatibility junta itens em lote, e um
lote parte-se quando muda a textura ou o material. Pistas:
[doc de otimização de GPU, 4.2](https://docs.godotengine.org/en/4.2/tutorials/performance/gpu_optimization.html),
[batching na 3.5](https://docs.godotengine.org/en/3.5/tutorials/performance/batching.html).
**Hipótese a medir:** os carros e os postes mascarados (`vila_a_frente`)
recebem cada um um `ShaderMaterial` próprio (`_mascara(i, origem)` no
`CarrosDaViela.gd` e no `ObraNoMapa.gd`), e cada um pode partir um lote.
**Custo aqui:** medir é barato (a régua existe); o número que decide é o FPS
num telefone real, que ninguém tirou ainda (A7). Toda técnica das secções
1–3 passa por esta régua antes e depois.

### 4.6 A acessibilidade

**Medido:** o RB5 (texto) e o RB6 (movimento) estão no jogo. **Técnica
(X1):** a cor nunca sozinha — forma, ícone, padrão ou posição ao lado; e
cada som com um equivalente visual. Pistas:
[XAG 103](https://learn.microsoft.com/en-gb/gaming/accessibility/xbox-accessibility-guidelines/103),
[Can I Play That](https://caniplaythat.com/?p=8897),
[bugnet, daltonismo](https://bugnet.io/blog/colorblind-friendly-game-design).
**Onde a cor está sozinha hoje** (pela sonda): o píer que acende quando um
toque o vai encher e o cartão da fila que realça mudam só de COR. **Custo
aqui:** baixo a médio. E cruza com a luz: uma noite baixa o contraste do
mapa inteiro, e a `interface.md` mede texto, não arte.

---

## 5. Como os temas se cruzam

- **O RB6 é o portão comum**: toda animação nova, a hora do dia, as
  partículas e o balanço por shader passam pelo `MovimentoDeFundo`, ou o
  movimento reduzido deixa de reduzir.
- **A bateria de capturas é byte a byte** (`captura.md`): hora do dia,
  partículas e sorteios novos precisam de semente e de passo fixos, e a hora
  fotografada tem de ser a de hoje, senão as fotos mudam todas de uma vez e o
  antes/depois do CI deixa de dizer o que mudou.
- **Luz e animação partilham o instante da virada** (`078`): o anoitecer, o
  barco que sai e o «+R$» acontecem no mesmo 1,2 s, e quem os desenha
  desenha-os juntos.
- **Som e háptica são o mesmo retorno por canais diferentes** (S6, T1, X1).
- **Os três gates humanos não se trocam**: a arte vê-se (A5, pela `/arte`),
  o som ouve-se (A6, pelo protocolo), o ritmo joga-se (A7).

## 6. A recomendação de ordem (julgamento; a escolha é do Bruno)

1. **Animação, com o toque** (A1, A1′, A3 e a háptica T1). É onde a medição
   mostra o buraco maior pelo menor custo: o barco do verbo do dia (atracar)
   entra pelo lado do mar e não pelo lugar onde se tocou (⚠️ medido na
   `144`: aparecia no berço no quadro do toque), e o porto, que é o
   assunto, só sobe e desce. Usa a infraestrutura
   que existe e não mexe em save nem em economia.
2. **Iluminação** (L1 e L3). A maior mudança de imagem, mas reabre o aceite
   do mapa e precisa da resposta sobre o que é a «hora» — por isso depois de
   a virada ter sido desenhada outra vez, que é onde a hora passaria.
3. **Som** (S1, S4, depois S2). Pode desenhar-se em paralelo, porque a
   aceitação espera o A6: vale começar quando o Bruno tiver um momento para
   ouvir.
4. **Clareza, interface, desempenho e acessibilidade** (C1, I1, D1, X1):
   itens pequenos e independentes; o D1 (medir o lote) pode ir à frente de
   qualquer um, porque é medição sem mudança.

**O que fica fora deste bloco:** a luz 2D com normal map (L4) e a gente na
vila (A5), pelo custo; a música (S5), pela licença e pelo compositor; o
ritmo (R1), até ao A7.

**A escolha do Bruno (29/10, `143`):** aprofundar a **animação e o toque**,
na ordem animação → luz → som → resto. A luz, o som e o resto abrem-se
quando ele os pedir.
