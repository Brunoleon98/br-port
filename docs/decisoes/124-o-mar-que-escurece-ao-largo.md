# 124 — O mar que escurece ao largo: a rampa, a sombra do muro e as marolas

**17/10/2026 · item 3 da fila que o Bruno deu na `121`** — «o mapa: as
melhorias que a sessão achar e as que ele viu: uma sombra bem QUADRADA nos
píeres, e o mar que, em vez de escurecer ao largo, tem áreas ao fundo mais
claras, como se fosse mais raso». **Aceite na foto do jogo à terceira
passagem.** Só o desenho do mapa mudou (`tools/gerar_mapa_iso.py`); nenhuma
linha de jogo, e a tabela de âncoras só ganhou o `alcance_costeiro`.

## A medição de antes

A mediana da luminância da água, por distância ao cais, no mapa rasterizado:
187 no baixio, 90 a 8 unidades, **73 a 12–15 u, e de volta a 86 a 20–22 u**.
O mar escurecia até meio caminho e voltava a clarear. Três causas, todas no
gerador:

- o degradê do largo ia de `agua` (`#0d4d6b`, 65,6) a `agua_funda`
  (`#0f5a7d`, 76,6) — o tom com nome de FUNDO era o mais claro dos dois;
- cinco das dezoito manchas de corrente eram da cor do BAIXIO, sorteadas até
  26 u da costa — duas caíam visíveis a 17 e a 25 u, bancos de areia no mar
  aberto;
- as manchas «fundas» eram `agua_funda` a 0,30, e portanto clareavam a água
  onde caíam.

A «sombra quadrada» era a faixa chapada de `sombra_agua` a 0,30 ao pé do
muro: aresta reta do lado do mar e, nas quinas dos degraus ao lado das docas
2 e 3, um paralelogramo com ponta em esquadria. E pintava **1.105 px por cima
do terreiro** do degrau seguinte — a faixa do espelho do degrau fica atrás do
muro na tela, e era desenhada depois dele.

## O que o Bruno escolheu

| Pergunta | Resposta |
|---|---|
| O mar ao largo | **Escurecer até o largo**, a recomendada: o degradê invertido, sem manchas claras no mar aberto, as de corrente a escurecer |
| A sombra do muro | **Esvair a partir do muro**, a recomendada |
| O que mais | no «Outro»: *«pode retirar o risco; se conseguir, coloque algo melhor no lugar que futuramente possa ser animado como ondas»* |

## As três passagens

1. **A rampa, a sombra e as marolas.** `agua` e `agua_funda` trocaram de
   valor; a mancha rasa só se desenha dentro do `ALCANCE_COSTEIRO`; a funda
   passou ao tom da sombra do muro. A sombra virou RASTER, no mesmo laço do
   campo de cor da água: smoothstep invertido a partir do muro, só onde a água
   está À VISTA (`_agua_a_vista`). Os «~» deram lugar a MAROLAS: crista clara
   afinada nas pontas com um cavado escuro do lado do mar, desenhada no plano
   da água. «Ajustar» em tudo, e no «Outro»: *«veja detalhes que podem
   melhorar e deixar a água mais realista»*.
2. **Séries e correntes.** Marolas mais longas e finas, em séries de duas ou
   três, mais densas perto da costa; correntes escuras alongadas ao largo;
   sombra do muro a 0,40, e um texel atrás da face (`SOMBRA_MURO_PE`), que
   tirou um fio claro de 1,5 px colado ao cais; um brilho de sol esparso.
   «Ajustar»: correntes pouco visíveis, brilhos que pareciam sujeira, e no
   «Outro» *«pesquise meios de aplicar técnicas para deixar o mar mais bonito
   e realista»*.
3. **A pesquisa.** A busca (os resumos; as páginas não abrem por este proxy,
   `063`) repetiu três técnicas: cor pela profundidade, que a rampa já faz;
   linhas de espuma que CONTORNAM a margem; cáusticas no raso. As duas
   últimas entraram na praia — `arrebentacao()`, faixas afinadas a 1,35 e
   2,3 u da água, e `causticas()`, uma rede de luz no raso de areia —, pela
   família de curvas do `ponto_costeiro`. Correntes mais fortes, brilhos fora,
   e a sombra a apagar-se em 1,6 u nas pontas do cais (a 0,6 a quina lia
   como um raio de luz). **«Aceito».**

## A medição de depois

A mediana desce sem voltar atrás: 187 → 90 a 8 u → 67 a 12 u → 64 ao largo.
Fontes da busca, citadas como pista de padrão: [Godot Asset Store — stylized
water shader](https://store.godotengine.org/asset/emace-art/stylized-water-shader/),
[80.lv — stylized water for Nimue](https://80.lv/articles/how-to-build-stylized-water-shader-design-implementation-for-nimue/),
[Tuts+ — toon water](https://code.tutsplus.com/creating-toon-water-for-the-web-part-2--cms-30485t).

## O que ficou, e porquê

- **As marolas ficam no mapa, e cada uma é uma peça com centro.** Animá-las é
  escrevê-las numa camada própria, como a espuma (`--espuma=N`), em duas
  sementes que o `Main.gd` lave em contrafase; cada camada a 1080 sem
  compressão custa ~4,7 MB de VRAM. Não se fez: o pedido foi «futuramente».
- **Cada desenho novo tem o seu `Random`** (`+500` a `+540`), e a mancha rasa
  que deixa de se desenhar continua a fazer os seus sorteios, para as fundas
  não mudarem de sítio (`mapa.md`).
- **O fio diagonal na ponta norte do cais é anterior** — está no mapa da
  `main` — e ficou por olhar.

## As provas

**D46**, num arquivo próprio (`casos_mar_ao_largo.gd`): nove raios em +mx a
partir dos berços, a começar no `alcance_costeiro` que o gerador publica;
cada amostra é a MEDIANA de uma janela. Duas perguntas, dois defeitos no
catálogo, e uma não apanha o outro: a inclinação média (o mapa dá −0,92; o
degradê invertido, −0,17; corte −0,55) e a pior subida sobre o mais escuro
já atravessado (o mapa 7,3; uma mancha rasa a 18 u, 16,4; corte 12). Os
cortes foram re-medidos a cada passagem: as correntes mais fortes mexeram nos
dois números (`testes-e-guardas.md`).

## Custo e estado

Os quatro mapas regerados e iguais ao byte entre o Python 3.11 e o 3.13; a
espuma não mudou. O gerador passou de ~10,5 s a ~11,6 s por mapa.
