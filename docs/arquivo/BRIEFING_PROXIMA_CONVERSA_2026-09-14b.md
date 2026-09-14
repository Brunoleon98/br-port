# BR Port — briefing da próxima conversa

> Fechado em 14/09/2026, depois da **alavanca A** da resolução dos assets. É o
> segundo fecho deste dia — o primeiro (`BRIEFING_PROXIMA_CONVERSA_2026-09-14.md`)
> traz as duas fatias do item 8. Ponto de entrada curto; o estado canónico
> continua em `docs/ESTADO_DO_PROJETO.md` e a ordem, na §7 do plano v3.

## O que acabou de ficar pronto

`docs/decisoes/025`. Os quatro SVG de mapa declaram `width="720"` sobre um
`viewBox` de 1080 e o importador entregava 720, que o `canvas_items` voltava a
ampliar 1,5× no aparelho — **uma redução seguida de uma ampliação**. O
`svg/scale` passou a 1,5 e os três nós de mapa ganharam `expand_mode = 1`, de
modo que o rect continua com 720 de coordenadas e a textura carrega os 1080 que
o arquivo já tinha.

| | medido |
|---|---|
| pico de cada fronteira (o que "nitidez" quer dizer) | 17,29 → **26,38 (+52,6%)**, o 1,5× teórico ao ponto |
| px da janela que o jogador vê mudar acima do piso de Weber | **5,12%** (6,76% na região vetorial) |
| `.pck` — o que o APK e o `brport-web` carregam | 4.003.064 → **4.415.304 B (+10,30%)** |
| VRAM (RGBA8, sem mipmaps) | 7,91 → 17,80 MB |
| a 720 (aparelho pequeno) | **melhora**: pontos soltos de 3,10% para 2,90% das fronteiras |
| **APK e `brport-web`** | ⚠️ **em aberto** — ver abaixo |

**O portão passou**, e a prova é a captura a **1080×1920** ampliada 3×: as
fiadas do telhado deixam de ser um borrão e viram linhas, as barras da
passadeira ganham quinas, as pedras da praia passam de mancha a sólido.

**Três coisas saíram diferentes do que o item previa, e ficam escritas:**

1. **A varredura de constantes em pixel não era precisa.** A alavanca A não toca
   no gerador, e um `stroke-width` do `viewBox` de 1080 mede os MESMOS px
   físicos no telefone antes e depois. Subir o `svg/scale` **remove uma
   redução**; não amplia um desenho. A armadilha vale para a alavanca **B**.
2. **O mapa tem duas camadas.** O campo de cor da água é um raster de 720×720
   **embutido no SVG** — 43% da janela, e nenhum `svg/scale` lhe dá informação.
   Melhora na mesma (deixa de fazer três reamostragens) e não pixeliza porque
   desenha campo contínuo.
3. **A bateria de 720 não podia responder** — é travada a 720×1280, onde a
   textura de 1080 volta a ser reduzida.

## O que a mudança destapou, e já está consertado

O teste de design reprovou em **18 pontos**, e a guarda que o fez estava certa.
Seis blocos raster (D20, D21, D24, D27, D28 e a Zona de Espera) amostravam o
mapa em coordenadas de TELA assumindo calados que a textura tinha 720. Passaram
por um leitor único — `_mapa_lido` — que devolve a imagem com o fator já
conferido, e a guarda exige um **múltiplo inteiro e igual nos dois eixos** em
vez de cravar 720.

Sobrou uma falha, e **era o D20 a reprovar o mapa CERTO**: a rota atravessa a
fronteira entre o pavimento do pátio e o asfalto, e o pixel de antisserrilhado
dela cai a 3/255 da calçada. Era o último bloco raster a provar por pixel único;
agora conta desenho numa janela de 7×7 de tela. Dois defeitos injetados, com a
base a passar entre eles: a fita da `013` dá **42** contra um piso de 20 (mapa
certo: 5) e a duna sobre a rua dá **66** (mapa certo: 0).

## O que sobrou desta sessão, e é pequeno

0. ⚠️ **A TABELA DE CUSTO TEM DUAS LINHAS POR FECHAR, e é a primeira coisa a
   fazer — leva minutos e não precisa de sessão própria.** O **APK** não se
   constrói neste contêiner (o `dl.google.com` responde 403 por política da
   organização) e o **`brport-web`** precisa de ~1,2 GB de templates que só o CI
   cacheia. Os dois saem em Artifacts a cada push, na corrida de
   [Brunoleon98/br-port#51](https://github.com/Brunoleon98/br-port/pull/51) —
   que é o PR desta alavanca. O `.pck` medido (+412.240 B, +10,30%) é o limite
   INFERIOR dos dois, porque é o que ambos empacotam; nenhum deles é só o
   `.pck`, e escrever o número do `.pck` na linha do APK seria inventar uma
   medição. Ler os dois tamanhos e fechar a tabela do §5 da `025`.

   **E confira de caminho o `brport-captura` da mesma corrida:** ele diz quais
   imagens mudaram contra a base, e a resposta esperada é **as sete que mostram
   mapa** — as sete de painel e as duas folhas de contato saíram byte a byte
   iguais aqui. Se o runner discordar, é achado e não ruído. Duas coisas que
   NÃO são falha: o workflow fotografa também a base do PR, e o
   `medir_resolucao_mapa.gd` é ferramenta nova — aparece como "novo" em vez de
   antes/depois na primeira corrida.

1. **O raster da água a 1080** (o `SAIDA` do `gerar_mapa_iso.py`). É 43% da
   janela e a única parte do mapa cuja precisão não está no arquivo. ⚠️ Subi-lo
   muda os bytes dos quatro SVG que o CI compara **e** multiplica por 2,25 os
   518 mil pixels que o campo de distância mede em cada um dos quatro mapas — o
   custo de CI mede-se ANTES, não depois. Sessão própria, e pequena.
2. **Mipmaps ficaram de fora, medidos** — não há aliasing que os pague, e
   custariam +33% de VRAM.

## As alavancas B e C, e o que elas valem

- **B — os props a 768.** É uma sessão inteira só para a mecânica: releva de 25
  props, o manifest, o pivô da lança (que sai em pixels do PNG), o
  `asset_validator` e a releva do `brp_*`. ⚠️ **É aqui que a armadilha da
  constante em pixel vale de verdade**, ao contrário da A — os props são
  desenhados nas unidades da saída.
- **C — o viewport.** Medido: **não dá um pixel**. Não se mexe.
- **O detalhe que a resolução PAGA** — a tabela da Etapa 7 do plano de arte,
  inteira: comércios na vila, o corrugado do contêiner, a cabine dos camiões, a
  ferrugem do pesqueiro. **Resolução sozinha compra nitidez, não detalhe**, e
  esta sessão comprou nitidez. São cinco ou seis sessões, e **a ordem é do Bruno**.

## O que espera o Bruno, e nenhuma sessão destrava

- **A5** — olhar o antes/depois de toda a trilha de arte, agora também com o
  mapa a 1,5×. É o gate mais atrasado;
- **A4** — reler em voz alta o texto que mudou desde 13/09;
- **A6** — ouvir os 14 efeitos. Este contêiner não tem placa de som;
- **A1/A7** — jogar outra vez, e a ORDEM do resto da fila.

## Os outros itens abertos

1. **O tronco do coqueiro** — índice 0,491, três na tela. A secção não ajuda
   (é esbelto), mas **curvar o EIXO** curvaria a silhueta, e isso não foi
   medido. É a única pergunta do item 8 ainda em aberto.
2. **`doca_concreto` não está no jogo** — referido só por
   `scenes/tests/AssetPlacementTest.gd`, que não é exportado. Ou entra no mapa,
   ou sai do catálogo: **é decisão do Bruno**.
3. **A rua parou em 1,8** — alargá-la empurra o `RUA_RECUO` e o enquadramento
   inteiro (`012`). Sessão própria.

## Prompt pronto para colar

```text
Continuando o BR Port. Leia primeiro CLAUDE.md, docs/ESTADO_DO_PROJETO.md,
docs/decisoes/025 e docs/arquivo/BRIEFING_PROXIMA_CONVERSA_2026-09-14b.md.

A alavanca A da resolução está FECHADA e medida (PR Brunoleon98/br-port#51) —
NÃO a refaça. Em particular: não mexa no viewport (alavanca C, medida, não dá um
pixel) e não varra o gerador do mapa à procura de constante em pixel por causa
dela — a 025 §4 mostra, com a conta, que a largura física de todo traço é a
mesma antes e depois.

COMECE POR FECHAR A TABELA DE CUSTO DA 025, que tem duas linhas em aberto e
leva minutos. O APK não se constrói neste contêiner (dl.google.com responde 403)
e o brport-web precisa de 1,2 GB de templates que só o CI cacheia: os dois saem
em Artifacts na corrida do PR #51. Leia os dois tamanhos, contra a corrida da
base, e escreva-os no §5 da 025 — o .pck que eu medi (+412.240 B, +10,30%) é o
limite INFERIOR deles e não substitui a medição. Confira de caminho o
brport-captura da mesma corrida: a resposta esperada é que mudaram as SETE
imagens que mostram mapa e mais nenhuma. Não é falha o workflow fotografar
também a base, nem o medir_resolucao_mapa.gd aparecer como "novo".

Depois disso, o item da sessão é UMA coisa pequena: SUBIR O RASTER DA ÁGUA.
O campo de cor da água é um PNG de 720x720 embutido no SVG (`SAIDA` no
gerar_mapa_iso.py), esticado sobre o viewBox de 1080 — são 43% da janela, e a
única parte do mapa cuja precisão não está no arquivo.

Comece pela F1 e meça o CUSTO antes de mexer, porque ele é o que pode reprovar:
(a) o tempo de geração de cada um dos quatro mapas, que o CI regera a cada push
— o campo de distância mede hoje 518 mil pixels contra ~500 segmentos de costa,
e a 1080 são 2,25x disso; (b) o tamanho do SVG, que o CI compara BYTE A BYTE, e
o do .pck; (c) a VRAM. Se o CI passar a demorar mais do que vale, pare e
registe a medição em vez de a deixar entrar — é o portão do bote da 024.

Depois meça o GANHO com a régua que já existe: brport_vs/tools/
medir_resolucao_mapa.gd separa a região do raster da do vetor e compara o que o
jogador VÊ (720 ampliado contra 1080 nativo). Hoje a água mede +67,6% de pico
sem ganhar informação nenhuma — o número a bater é quanto ela ganha de verdade.

⚠️ E o raster é byte-reprodutível: `_zlib_fixo` e `math.fsum` existem por isso
(CLAUDE.md). Qualquer poda ou otimização prova-se correndo a versão lenta e a
rápida e exigindo os mesmos bytes.

Feche com as seis suítes, o asset_validator, os quatro mapas regerados e
conferidos byte a byte contra o gerador, a captura antes/depois AMPLIADA a
1080x1920 (a de 720 não responde a esta pergunta) e o fechar-sessao.
```
