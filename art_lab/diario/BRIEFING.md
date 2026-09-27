# Diário — briefing da foto do porto de antigamente

**Peça:** uma, a **foto colada na folha de rosto do diário** — a tela que
abre logo depois de «Nova partida», onde o jogador escreve o nome do cais e o
dele (`docs/decisoes/067`). O pedido do Bruno na trilha de 23/09 foi «pode ter
imagens do porto antigamente», e o diário é o do avô: a foto é o porto no
tempo dele.

**Técnica:** gerador de imagem, escolha do Bruno (26/09). É arte de PAINEL e
não prop no mapa, que é a linha que o `CLAUDE.md` traça para o gerador.
**Quem produz:** o Bruno, com o ChatGPT. **Quem integra:** o Claude Code, pela
§3 do `art_lab/README.md`.
**Base:** a `main` com o PR da `067` fundido.

---

## O que a imagem é

**Uma fotografia de papel, antiga, do Cais Mirim no tempo do Seu Maneco.** Um
porto PEQUENO de pesca e de carga leve: um píer de madeira sobre estacas, dois
ou três barcos de pesca de madeira pintados (casco colorido, casaria branca),
um galpão de telhado de barro na beira do cais, algumas caixas e redes. Atrás,
a mesma costa do jogo: morros verdes de mata atlântica, coqueiros, a vila de
casas claras com telhado de telha. Dia claro. Tirada da água ou de um morro
ao lado — é uma foto de família, não uma vista aérea.

**É o «antes» do jogo, e não o porto em ruínas.** O jogador abre a partida
com o píer podre e o galpão caído; a foto mostra o mesmo sítio quando estava
de pé e a trabalhar. Por isso **não tem** guindaste de pórtico, contêineres
nem camiões — isso é o que o jogador vai construir.

**O aspeto de foto antiga** é da imagem, e não do jogo: cores desbotadas de
filme (quentes, um pouco amareladas) ou sépia, grão leve, cantos um pouco
escurecidos. O jogo põe à volta a borda branca de papel, as cantoneiras e o
giro de foto colada à mão — **a imagem não traz borda nem moldura**.

O mundo do jogo, que ela não pode contradizer:

- litoral **brasileiro** (Porto Mirim é a cidade, Cais Mirim o nome-padrão do
  porto); areia clara, água verde-azulada perto da costa;
- telhados de **telha de barro**, paredes claras;
- o píer do começo do jogo é de **madeira** (`pier_1`), e os barcos do porto
  pequeno são **pesqueiros** — é a frota que o jogo recebe no nível 1.

## As medidas, e de onde saem

A foto ocupa **500 × 354** das coordenadas do jogo (720 × 1280), medida na
folha de rosto montada (`nomes.png` da bateria, desde a `067`), e o jogo
desenha na resolução do aparelho — 1,5 pixel por unidade num telefone de 1080.
Logo:

- **Entrega: 1200 × 850 px (horizontal, ~1,41:1), PNG, sem transparência.**
  Maior serve, desde que a proporção seja a mesma.
- O jogo **cobre e corta** (`STRETCH_KEEP_ASPECT_COVERED`): uma proporção um
  pouco diferente perde uma faixa nas bordas, e o assunto tem de estar longe
  delas.
- Os **quatro cantos** ficam debaixo das cantoneiras escuras (26 unidades de
  lado, ~40 px na entrega): nada importante neles.

## O que NÃO pôr

- **Texto nenhum** — nem data escrita, nem placa, nem nome de barco legível.
  Gerador de imagem erra letra, e o nome do cais é o que o JOGADOR escreve.
- **Pessoas em destaque**: o jogo tem retratos próprios, feitos no Blender, e
  uma cara pintada aqui seria outra linguagem de personagem. Gente pequena e
  de costas, a trabalhar no cais, pode.
- Borda branca, moldura, cantoneiras, mesa por trás — o jogo põe a moldura.

## O pedido, pronto para colar

> Fotografia antiga de papel, horizontal (1200 × 850 px), de um pequeno porto
> de pesca no litoral brasileiro há uns trinta anos: um píer de madeira sobre
> estacas, dois ou três barcos de pesca de madeira pintados em cores vivas, um
> galpão de telhado de barro na beira do cais, caixas e redes. Atrás, morros
> verdes de mata atlântica, coqueiros e uma vila de casas claras com telhado
> de telha. Dia claro, tirada da água. Cores desbotadas de filme antigo, um
> pouco amareladas, grão leve e cantos levemente escurecidos. Sem guindastes,
> sem contêineres, sem texto, sem letreiros, sem pessoas em destaque, sem
> borda ou moldura.

## Como entregar, e o que acontece depois

1. Pôr o PNG (e a conversa ou o prompt que o produziu, se der) numa pasta
   `art_lab/diario/v1/` — pelo GitHub web numa branch, ou num zip que o Claude
   Code põe lá, com um `README.md` a dizer de onde veio.
2. O Claude Code troca o `const FOTO` em `brport_vs/scripts/TelaNomes.gd`,
   importa, e fotografa a folha de rosto (`tools/capturar_evidencia.sh`), com
   a de hoje ao lado.
3. O Bruno aceita **na foto do jogo**, não na imagem solta.

Até lá o jogo mostra `brport_vs/art/diario/foto_provisoria.svg`: céu,
horizonte e mar em sépia, sem porto nenhum — uma foto que não finge ser a
arte, como o fundo provisório da tela inicial.

Quando o diário ganhar páginas a meio da partida (o app Diário do celular),
cada entrada pode ter a sua foto; a mesma receita serve, com o assunto de cada
uma.
