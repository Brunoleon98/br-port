# BR Port — Briefing para continuar o Bloco 4

> Documento de entrada para a próxima conversa. Escrito em 28/08/2026, ao fim
> da sessão que abriu o Bloco 4. **Atualizado em 29/08/2026**: o caminho B da
> §3 (camada de ícones) foi executado e está fechado.
>
> **Leia este arquivo primeiro, depois `docs/ESTADO_DO_PROJETO.md`.**
> Existe para não repetir perguntas já respondidas nem refazer decisões já
> tomadas — em especial a de direção de arte, que oscilou três vezes e agora
> está fechada.

---

## 1. Onde o jogo está

**O mapa do porto é a tela do jogo.** `Main.tscn` roda com:

- Barra de HUD em pílulas: caixa, dia, reputação, docas construídas
- Mapa visto de cima ocupando a maior parte da tela
- **Três vagas fixas** sobre os píeres, alimentadas por `GameState.docks`
- Fileira de trabalhadores para arrastar até uma doca
- Painel de mensagem e barra da parcela do Sr. Ribeiro

A terceira vaga mostra **estacas velhas sob contorno tracejado** até o jogador
comprar "Ampliar píer" — o upgrade acontece no mapa, não numa lista.

**A economia não mudou**: 2 docas iniciais + 1 upgrade, como o Bloco 3 mediu.
33 asserções passando. PR: https://github.com/Brunoleon98/br-port/pull/5

---

## 2. A decisão de arte — fechada, não reabrir

Ela oscilou três vezes nesta sessão. O histórico importa para não voltar:

| Rodada | Decisão | Por que caiu |
|---|---|---|
| 1 | 3/4 ilustrado, para casar com os 5 PNGs recebidos | Sobre um mapa topo-down virou erro de perspetiva |
| 2 | Vetor chapado topo-down (volta ao GDD) | O Bruno escolheu o ângulo dos mockups |
| 3 | **Isométrico** ✅ | — |

**Decisão vigente: isométrico.** Divergindo do GDD, que congela "Flat Design
2D". A justificativa é que o Bruno escolheu explicitamente esse ângulo depois
de ver os dois protótipos lado a lado.

### E o jogo JÁ É isométrico (29/08)

`Main.tscn` roda sobre `porto_mapa_iso.svg` com os props de
`tools/gerar_props_iso.py`. As 33 asserções continuam passando.

O que destravou: os sprites antigos foram gerados deitados, e num plano
isométrico **nenhum eixo é horizontal** (ambos saem a 26,57°) — por isso
ficavam atravessados em cima do píer. Gerar por script em vez de por prompt
tira o ângulo das mãos de quem desenha.

Três coisas que a migração exigiu e que ficam registradas:

1. **O mapa passou a sair sem os píeres** (`--sem-pieres`). O que muda de
   estado em jogo não pode estar assado no fundo.
2. **A altura precisou de conversão.** O mapa trata altura como PIXELS livres
   (`ALT_PIER=15`, `ALT_CAIS=26`); o Blender projeta de verdade, onde uma
   unidade vale 36,74px. Sem o `z()` de `gerar_props_iso.py` o píer sai 2,4x
   mais alto que o cais ao lado.
3. **O passo vertical entre docas é 180px** e o píer ocupa ~155. Píer e chip
   empilhados não cabem — por isso a chip foi para cima do convés, menor. Quem
   for mexer no layout esbarra nisso de novo.

---

## 3. O que fazer a seguir — dois caminhos abertos (B está fechado)

### A) Gerar os assets isométricos (o caminho da direção escolhida)

**Isto mudou em 29/08.** O gerador de imagem já perdeu duas levas pelo mesmo
motivo — ele não erra o desenho, erra o ÂNGULO — e agora existe um caminho que
não pode errar: `tools/gerar_props_iso.py` monta os props em Blender por script,
com a câmera ortográfica no 2:1 do mapa. Os 17 props saem em ~60s e o próprio
script CONFERE a projeção no fim, medindo a largura do tabuado contra a conta
de `gerar_mapa_iso.py`.

Sobrou para o gerador de imagem só o que não se escreve em coordenadas:
**Arlindo (3 expressões) e o Sr. Ribeiro** — e lá a perspectiva não importa,
porque eles vivem em painel. Foi por isso que a leva de retratos que o Bruno
gerou ficou boa e a de barcos não.

`docs/BLOCO4_PROMPTS_ISOMETRICO.md` continua valendo para esses dois. A §0
trata de **orientação**, que é o erro que derrubou os sprites de cenário.

Ordem sugerida no próprio documento: 3 barcos → píer nos dois estados →
Arlindo (3 expressões) → coqueiro → galpão.

**Os ícones saíram dessa lista.** Eles já existem, em vetor chapado, e é assim
que devem ficar: ícone de HUD é interface, tem de se ler a 19px, e o estilo
isométrico não entrega isso nesse tamanho (§5, armadilha 4). A migração para
isométrico é do CENÁRIO — não encoste em `art/icones/`.

Depois de gerar: `python3 tools/preparar_sprites.py <pasta> brport_vs/art/sprites`
e conferir que a coluna `fundo` diz **`sólido`**.

### B) Fechar a interface sem esperar arte nova ✅ FEITO (29/08)

**Nenhuma tela do jogo usa emoji.** São 20 SVGs em `brport_vs/art/icones/`,
com o registro em `brport_vs/scripts/Icones.gd` — os 8 que já estavam
desenhados no canvas
(https://claude.ai/code/artifact/922a5018-28ff-432f-9d6d-011c7a93fe1f)
mais 12 novos, no mesmo grid 24×24 e na mesma paleta.

O que isto ensinou, e vale para qualquer ícone futuro:

1. **Cor de ícone depende do fundo, e a paleta não tem uma cor que sirva aos
   dois.** A interface tem três fundos — pílula/chip escura, cartão branco,
   botão navy. As variantes "pílula" do canvas eram creme chapado e sumiam em
   cartão branco. Cada ícone foi colorido para onde ele cai de verdade;
   `doca` (traço creme) e `parcela` (navy cheio) só servem no fundo delas.
   O jeito de um ícone servir aos dois é ter contraste próprio: disco de fundo
   (como `feito`, `pausar`, `acordo`) ou âmbar/vermelho puro.
2. **Metáfora que não sobrevive a 19px não serve, por melhor que seja.**
   O aperto de mão de "Igualar" virou mancha em três desenhos diferentes; virou
   sinal de igual. O braço flexionado de "Manter preço" virou escudo. Desenhe
   para o tamanho de uso, não para o catálogo.
3. **A parte escura do desenho some no fundo escuro.** O capacete do
   trabalhador tinha a aba em âmbar escuro e virava um triângulo na chip da
   doca. A informação tem que estar na parte CLARA do ícone.
4. **`tools/folha_icones.gd` é o teste.** Desenha os 20 nos três fundos, a 19px
   e ampliado. Rodar a cada leva nova — foi ele que reprovou 4 ícones que
   pareciam bons no código.

Os emoji que ficaram nas mensagens do `GameState` também saíram: só 7 dos 15
`message.emit` tinham um, nunca foi um sistema, e a barra já codifica o tom por
cor. Se um dia a barra de mensagem ganhar um slot de ícone, é decisão nova —
o `GameState` é lógica e hoje não nomeia ícone nenhum.

### C) Resolver o píer de 1 a 3 (mexe na economia)

Ideia do Bruno, adiada de propósito: começar com **1 doca** e construir até 3,
em vez de 2 + upgrade único.

O que exige em código:
- `upgrade_purchased` vira contador; limite passa a ser `docks.size() < 3`
- O mapa já tem as 3 vagas desenhadas — não precisa de arte nova
- O botão some ao chegar em 3

**O aviso:** começar com 1 doca corta a vazão inicial pela metade, contra uma
renda de píer que é fixa (R$240/semana). Os números do Bloco 3 (99,7% / 63,8%
/ 0,7%) **deixam de valer**. E há uma pergunta de design junto: com 1 doca, os
2 trabalhadores iniciais custam R$200/semana e só um trabalha.

Antes de codar, decidir: custo por píer e quantos trabalhadores iniciais.
Depois medir com `tools/simular_balanceamento.gd` — ele é determinístico por
semente, então dá para comparar antes/depois sem ruído.

---

## 4. Ferramentas que já existem (não refazer)

| Ferramenta | O que faz |
|---|---|
| `tools/preparar_sprites.py` | Conserta o alpha dos PNGs gerados por IA e redimensiona. Detecta sozinho fundo quadriculado ou magenta chapado. **Rodar a cada leva nova.** |
| `tools/gerar_mapa_iso.py` | Gera o mapa isométrico a partir de coordenadas de mundo. Mudar o ângulo = mudar duas constantes e regerar. |
| `brport_vs/tools/simular_balanceamento.gd` | Roda N partidas com 3 perfis e mede a dificuldade. Determinístico por semente. |
| `brport_vs/tools/capturar_tela.gd` | Salva um PNG do jogo rodando, sem abrir o editor. **Usar a cada mudança visual** — teste verde não prova que ficou bonito. |
| `brport_vs/tools/folha_icones.gd` | Folha de contato dos ícones nos 3 fundos da interface, a 19px e ampliado. **Rodar a cada ícone novo.** |
| `tools/gerar_props_iso.py` | **Props isométricos em Blender por script** — píer nos 3 estados, 3 barcos, guindaste em peças, coqueiro copa+tronco, galpão, contêiner, caixote, boia, marcador. Confere a própria projeção. Não faz retrato de personagem. |

Para rodar o Godot nesta sessão foi usado o binário 4.6.3 em `~/godot-bin/`,
com `xvfb-run` para as capturas.

---

## 5. Armadilhas descobertas (medidas, não supostas)

1. **PNG gerado por IA não tem alpha.** Pedir "fundo transparente" faz o modelo
   *desenhar* um quadriculado cinza. Peça **magenta chapado `#FF00FF`**.

2. **A caixa de um plano isométrico é sempre 2:1.** Vale para qualquer formato
   de terreno. Em 720 de largura, o chão nunca passa de 360 de altura — por isso
   todo mockup isométrico de porto é quadrado. A saída é gerar o mundo maior que
   o ecrã e cortar.

3. **Costa reta empurra as docas para o lado.** Como `tela_x` depende de
   `(mx - my)`, docas espaçadas ao longo de uma costa reta saem do ecrã retrato.
   A costa precisa ser em degraus, com `Δmx > Δmy / 3`.

4. **Ícone de HUD não é isométrico.** É interface: silhueta chapada, legível a
   19px. Colar o bloco de estilo isométrico num prompt de ícone devolve borrão.

5. **A escala do render tem um número, não um chute.** Para o PNG cair no mapa
   em 1:1, `ortho_scale = resolução / (MEIA_LARG / cos 45°)` = resolução/42,4264.
   E a rotação da câmera é **(60°, 0, 45°)** — o 54,736° que aparece em todo
   tutorial é isométrico VERDADEIRO (1,732:1) e aqui daria o ângulo errado.

6. **`cam.matrix_world` mente logo depois de mexer na rotação.** A matriz só é
   recalculada no depsgraph seguinte, então ler a direção de vista dali põe a
   câmera longe do alvo e o render sai VAZIO, sem erro nenhum. Faça a conta na
   mão.

7. **A tela do projeto é retrato com aspecto travado** (`stretch/aspect="keep"`,
   720×1280). Pedir `--resolution` numa proporção diferente não dá erro: devolve
   a imagem espremida. Ferramenta de captura tem de respeitar 720:1280.

8. **Animação não se pede ao gerador.** Barco balançando, chegando, doca
   pulsando — tudo é `Tween` sobre sprite existente, zero arte nova. O que
   precisa de arte é **anatomia separada pelo eixo que se move** (copa e tronco
   do coqueiro em arquivos distintos, por exemplo).

---

## 6. Pendências herdadas (não são do Bloco 4)

- **Parcelas 2 e 3 (R$16.000 e R$24.000) nunca foram verificadas.** Ver
  `docs/design/BR_Port_GDD_V7_ERRATA_ECONOMIA.md`. Checar antes de codar a
  economia da Fase 2.
- **A reputação não afeta nada** mecanicamente, só o rótulo na HUD.
- **A derrota por caixa negativo é código morto** — o píer sozinho paga os
  custos, então a única forma de perder é a parcela.
- **Zona de Espera é só visual.** Os barcos ancorados são decorativos. Torná-la
  mecânica muda o balanceamento medido.

---

## 7. Como abrir a conversa nova

Cole isto:

> Continuando o BR Port. Leia `docs/BLOCO4_BRIEFING_CONTINUACAO.md` e depois
> `docs/ESTADO_DO_PROJETO.md`. A direção de arte já está decidida (isométrico)
> e não precisa reabrir.

E diga qual caminho da §3 quer seguir — sobraram **A** (gerar os assets
isométricos, que depende de você rodar o gerador) e **C** (píer de 1 a 3, que
precisa antes de duas decisões suas: custo por píer e quantos trabalhadores
iniciais). O B está fechado.

---

*BR Port · Briefing de continuação do Bloco 4 · Fase 4*
