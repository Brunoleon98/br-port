# As variações do trabalhador do rodapé — v1 a v3

**Estado: ✅ v3 ACEITA pelo Bruno (24/09), e já no jogo.** A decisão é a
`059`: a tabela dos 30 é o `TRABALHADOR_PERFIS` de `blender/brp_porto.py`, os
29 novos estão em `brport_vs/art/props/` (o padrão continua a ser o
`trabalhador_retrato.png`), e cada trabalhador nasce com o seu `rosto`. Os 29
do estúdio saíram iguais às candidatas da v3 pelo `comparar_props.py`
(0,0000 nos 29).

**Base:** `main` em `194ebd9` (o PR #82 fundido).

## O que se pediu

O escopo é do Bruno, escolhido numa volta (`058`, «O que fica para depois»):
**30 retratos** — 2 sexos × 3 idades (jovem, adulto, veterano) × as 5 cores do
IBGE (branca, parda, preta, amarela, indígena). **Sem caricatura**: a cor muda
o tom de pele e o cabelo que aparece debaixo do capacete, nunca o desenho do
rosto; a amarela e a indígena distinguem-se pelo cabelo liso preto de franja
reta e pelo tom. As marcas: a mulher de rabo de cavalo, maxilar mais suave,
sobrancelha mais fina e lábio de cor; o veterano grisalho e com rugas; o jovem
de cara lisa; bigode ou cavanhaque em alguns homens.

## Como se faz

O construtor é o `trabalhador(M, cara, perfil)` de `blender/brp_retratos.py`,
com as tabelas ao lado dele (`PERFIL_PADRAO`, `_CORES`, `_QUEIXOS`, `_CASCAS`).
O `perfil` é `sexo`, `idade`, `cor`, `pelos` (bigode, cavanhaque, barba) e
`cabelo` (o penteado dela). Sem perfil sai o trabalhador de hoje: **provado a
0 pixels** contra uma segunda corrida do código de antes da mudança (e os dois
a 933 px, Δ máx 7, do PNG de `brport_vs/`, que é o ruído entre máquinas — o
`comparar_props.py` dá 0,0000).

As peles novas estão na `PALETA` de `tools/gerar_props_iso.py`, cada uma com o
degrau abaixo (é a sombra que desenha o nariz); a branca é a `pele_clara` e a
parda a `pele`, que já existiam.

## As duas voltas

| | o que mudou | o veredito do Bruno |
|---|---|---|
| **v1** | as cinco peles e os cabelos (castanho, preto curto, liso preto de franja reta, grisalho); a mulher com o maxilar mais estreito, a sobrancelha fina, o lábio de cor e um rabo de cavalo por cima do ombro; o veterano com pés-de-galinha e vinco na testa; bigode e cavanhaque em 5 dos 15 homens; na pele preta a boca, a pupila e a sobrancelha no preto do cabelo (a boca em `vao` media 0,42–0,59 de Weber contra 0,75–0,91 nas outras) | ajustar: pele preta escura demais; a mulher ainda lê como homem, o rabo de cavalo lê como ALÇA, o lábio quase some, e «mais variações de cabelo para mulher mesmo de chapéu»; as rugas não se veem, bigode e cavanhaque viram MANCHA, e «mais variações de barba» |
| **v2** | a pele preta um degrau acima (`#74492f`); cinco penteados dela, cada um três vezes — rabo e trança por cima do ombro, com prendedor vermelho e brinco; solto, curto e crespo em CASCA à volta da cabeça, a emoldurar a cara; cílios com ponta, lábio maior e mais saturado; três rugas em leque por olho, olheira e dois vincos na testa, 22% abaixo do degrau da pele; bigode em tufos com as pontas a descer, cavanhaque ligado ao bigode pelos cantos da boca, e a barba cheia — 7 dos 15 homens | ajustar só o crespo: «cobrindo o olho» e «lê como capuz»; homens, pele e cabelo «está bom» |
| **v3** ✅ | o crespo em CACHOS — esferas facetadas em quatro fiadas à volta da cabeça, todas atrás do plano da cara; os outros 27 são os da v2 | «as que têm cabelo crespo vão aparecer cortadas?» — não: o corte era da janela da folha ampliada, escrita à mão na cabeça de hoje, e ela passou a sair das 30. **Aceite** |

## O que cada volta ensinou

- **Um rabo de cavalo paralelo às faixas lê como mais uma faixa.** Estreito, de
  largura constante e ao lado da refletiva, era uma alça. Grosso onde nasce, a
  afinar, a curvar do ombro para dentro e com um prendedor, é cabelo.
- **O que diz «mulher» a 70 px é o cabelo que EMOLDURA a cara**, e não as
  feições: com o maxilar, a sobrancelha e o lábio da v1 ela lia como ele.
  Debaixo de um capacete, o cabelo que se vê é o que cai dos lados.
- **Uma barba só nas quinas e no queixo é uma faixa, e grisalha na pele preta
  lê como a jugular do capacete.** A frente da bochecha tem de ir junto.
- **Uma placa escura por cima da boca é sombra, não bigode**: o que o faz pelo
  é a forma (cheio ao meio, afinado para fora, pontas a descer) e os tufos.
- **Uma casca contínua desde a aba é um capuz, por mais que ondule.** O que
  lê como crespo é a silhueta recortada — cachos redondos a sair da aba —, e a
  frente dela tem de ficar atrás do plano da cara, senão cobre o olho.
- **A janela de uma folha de contato sai do conjunto, não do padrão**: escrita
  à mão na cabeça de hoje, ela cortava 14 px do crespo, e a folha fazia
  parecer cortado um retrato que no cartão sai inteiro.
- **A casca de cabelo não entra na medida do enquadramento**: começa por
  `penteado_`, porque a cabeça mede-se pelas peças `cabeca`, `cabelo` e
  `capacete`, e uma casca até ao ombro encolheria o busto de um penteado para
  o outro.

## Arquivos

| Pasta | O que há |
|---|---|
| `v1/`, `v2/`, `v3/` | `gerar_variacoes.py` (a tabela dos 30 perfis e o render), `montar_folhas.py` (as duas folhas de contato), `medir_feicoes.py` (o contraste da boca e da sobrancelha contra a pele) e as folhas. ⚠️ O script corre contra o estúdio de HOJE: o da v1 já não refaz a v1. Os 30 PNG não entram no Git (16 MB por volta); refazem-se com o script |
| `v*/folha_cartao.png` | os 30 no tamanho do cartão (o `Retrato` do `Worker.tscn`, 70 de altura em `KEEP_ASPECT_CENTERED`, sobre o fundo do `TrabLivre`), a 70 px e a 105 px |
| `v*/folha_ampliada.png` | a cabeça e os ombros de cada um, a 2× do cartão de 1080, sem suavizar |
