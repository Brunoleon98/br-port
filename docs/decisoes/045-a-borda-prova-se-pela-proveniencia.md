# 045 — A borda prova-se pela proveniência, e o tiro que faltava

**22/09/2026 · a QUINTA e última leva das cores declaradas em
`tools/excecoes_cor_ui.json` · opção (c) do briefing de 23/09, escolhida pelo
Bruno**

## O que saiu

A **borda âmbar do trabalhador selecionado** — `Worker._aplicar_estilo()`
duplicava o stylebox do tema e pintava-lhe a borda à mão. **1 chamada, 1
entrada, e a lista fica VAZIA.**

| | antes | depois |
|---|---:|---:|
| cores de tema pintadas à mão | 1 em 1 local | **0 em 0** |
| exceções declaradas | 1 | **0** |
| blocos de contraste/escopo | D33 | D33 + **D34** |
| tiros da bateria | 24 | **25** |

Uma variação nova, `TrabSelecionado` — o `trab_livre` com a borda âmbar e o
dobro da largura. A função que duplicava passou a ter **uma linha**.

**As cinco levas juntas: 27 chamadas em 19 locais → 0 em 0.**

## ⚠️ Por que esta leva precisou de régua NOVA

As quatro anteriores provaram-se por duas coisas, e **nenhuma alcança uma
borda**:

- **o D33 mede TEXTO.** Uma borda não tem `font_color`. Cego por construção.
- **a bateria de 24 fotos não selecionava trabalhador nenhum.** A seleção é um
  TOQUE, e nada nos 24 tiros tocava. Logo o controle positivo — pintar a cor
  de outra e ver quantas fotos mexem — mexeria **ZERO**, e a identidade byte a
  byte não provaria coisa nenhuma. É a armadilha que a `042` deixou escrita, e
  desta vez ela estava armada.

Daí a leva entregar **duas peças** e não uma: a régua (D34) e o tiro novo.

## A régua escolhida: PROVENIÊNCIA, lida no nó montado

Perguntar *"a borda é âmbar?"* comparando com a cor do tema seria um
**espelho** — o esperado sairia da mesma fonte onde o defeito moraria, que é
a armadilha do sorteio de motivos da `006`.

O que não é espelho é perguntar **de onde veio o OBJETO**. Até 22/09 o nó
carregava um `estilo.duplicate()`; hoje carrega o **próprio recurso** que o
tema publica, e a asserção é a identidade:

```gdscript
escolhido == tema.get_stylebox("panel", "TrabSelecionado")
```

Um duplicado com a cor certa mede igual em tudo e **reprova aqui**. É a
pergunta que nenhuma varredura de texto sabe fazer — a lição da `043` com um
stylebox no lugar da `theme_type_variation`.

## ⚠️ O achado: a guarda estava a ser segurada pela variação ERRADA

A segunda asserção pergunta se a seleção muda a borda **em relação ao cartão
que ela substitui**. A primeira versão comparou-a com o **repouso observado** —
o stylebox que o cartão tinha antes do toque — e o mutante **Z4 PASSOU**.

O HUD abre com trabalho parado, logo esse repouso é o `TrabParado`, de borda
**laranja**. Pintar a seleção do verde do `TrabLivre` continua a diferir do
laranja, e a guarda passava contente com o canal da cor morto.

Quem a seleção substitui é o cartão **LIVRE** — é o fundo dele que ela veste,
derivado nesta sessão. Contra o `TrabLivre`, o Z4 reprova. É *"confira QUAL
guarda está a segurar a asserção"* com duas variações no lugar de duas
guardas: **relacional não basta, tem de ser relacional contra o estado
CERTO.**

## ⚠️ E a seleção fala por DOIS canais — a medição disse qual trabalha

⚠️ **UMA BORDA TEM DUAS ADJACÊNCIAS, e medir só uma engana.** A primeira
leitura desta sessão publicou **2,24:1** como se fosse *a* medida; é o lado de
DENTRO. Amostrado no pixel da captura (`escolhido.png`, x=14..17):

| | contra a barra escura (fora) | contra o fundo do cartão (dentro) |
|---|---:|---:|
| **selecionado** (4px âmbar) | **7,37:1** | 2,24:1 |
| repouso livre (2px verde) | 3,27:1 | 5,05:1 |

**A fronteira do cartão vê-se de sobra** — 7,37:1 contra um corte de 3,0 na
WCAG 1.4.11. O que fica abaixo é distinguir os dois ESTADOS pela cor: **âmbar
contra verde mede 2,26:1**. Quem separa «escolhido» de «livre» é a **LARGURA**,
2px → 4px.

Daí o D34 exigir os dois canais, e o mutante Z3 (largura 4→2) reprovar sozinho.
O número fica **registado e não vira asserção**: trocar o âmbar é decisão do
Bruno, e uma guarda de 3:1 sobre a troca de cor reprovaria o que esta migração
preservou de propósito (`029` — nem tudo o que se mede precisa de guarda).

## A amarra que torna UMA variação suficiente

`_aplicar_estilo()` deixou de compor a borda por cima de qualquer cartão. Isso
só está certo enquanto o jogo não conseguir selecionar quem não está livre — e
**foi derivado, não lido**: alocar o trabalhador pela porta do jogador põe o
`_selecionado` do `Main` em **−1** e o cartão volta a `TrabAlocado`.

O D34 tranca-o. Se alguém tornar esse par alcançável, descobre-se aqui, e não
no dia em que o âmbar sumir de um cartão.

## A prova, por TRÊS caminhos

1. **A migração mexeu em 0 das 24 fotos** comuns ao antes e ao depois.
2. **A bateria não tem ruído próprio**: duas corridas da mesma árvore, **0 de
   25**.
3. **O controle positivo mexe 1 de 25** — a `escolhido.png`, o tiro novo.
   ⚠️ **E é isso que dá sentido ao zero:** antes desta sessão o mesmo controle
   teria mexido **0 de 24**, e o zero da prova 1 não valeria nada.

| leva | fotos mexidas pela entrega | pelo controle positivo |
|---|---:|---:|
| 2ª (`042`, faixa) | 0 | 12 — e nenhuma mostra o estado mudado |
| 3ª (`043`, cartão) | 0 | 13 |
| 4ª (`044`, verde) | 0 | 1 |
| **5ª (esta, borda)** | **0** | **1 — e sem o tiro novo seria 0** |

## Os mutantes

Cada um sozinho, originais por `cp` (nunca `git`), controle positivo entre
cada, código de saída lido **sem cano**.

| # | Defeito | Resultado |
|---|---|---|
| Z0 | base limpa | verde nas dez |
| Z1 | a migração desfeita — `duplicate()` + cor à mão | **as DUAS reprovam**: o D34 pela proveniência, o escopo pela cor fora do registro |
| Z2 | `TrabSelecionado` sumiu do tema | **só o D34** — o escopo sai VERDE, porque o nome vai a `get_theme_stylebox()` e ele nem procura lá |
| Z3 | canal da LARGURA morto (4→2) | **reprova sozinha** a asserção da largura |
| Z4 | canal da COR morto (âmbar → o verde do livre) | com o repouso OBSERVADO: **passa**. Contra o `TrabLivre`: **reprova** |
| Z5 | a amarra quebrada — seleção sobrevive à alocação | reprova: *"o Main ainda tem o trabalhador 1 escolhido depois de ele ir para a doca"* |
| Z6 | o toque não seleciona | reprova por quatro |
| **Z6b** | **o MESMO, com a guarda da derivação RETIRADA** | **reprova na mesma, por três** |

⚠️ **O Z2 É O INVERSO DO X2 DA `043`, e as duas réguas continuam a não se
cobrir.** Lá o escopo apanhava o nome errado num literal de cena; aqui o nome
vai por `get_theme_stylebox(prop, TIPO)`, que a regex não procura — e só a
pergunta em runtime segura.

⚠️ **E O Z6b DESMENTIU UM COMENTÁRIO QUE EU JÁ TINHA ESCRITO.** Ele dizia que
sem a guarda da derivação as outras passariam contentes; medido, elas reprovam
na mesma, porque um cartão que não foi selecionado nunca veste o recurso do
`TrabSelecionado`. A guarda é **diagnóstica e não sustentadora** — fica porque
nomeia a CAUSA onde as outras nomeiam o sintoma, e o comentário passou a dizer
isso. Não é o X1b da `043`: **nem toda guarda nova precisa de ser
sustentadora; o que precisa é que a afirmação ao lado dela seja verdadeira.**

## O que fica de fora, dito

- **O âmbar em si.** 2,26:1 na troca de estado é o número, e mexer nele é F4 —
  decisão do Bruno. Esta migração preservou o valor.
- **As duas formas dinâmicas da `043`** — o `PainelNarrativo.montar()`, que
  recebe a variação por parâmetro, e o `_aplicar_estilo()` aqui, que continua a
  passar o nome a `get_theme_stylebox()`. **Nenhuma entrega cor**, e agora os
  cinco chamadores passam literais `&"..."`. Ficam registadas.
- **Nada aqui mudou um pixel do jogo.** O cartão do trabalhador está
  exactamente como estava — o que mudou foi de onde a borda dele vem, e que
  passou a haver quem a veja.

## Adenda (23/09) — o âmbar, e a troca que se comparou

O Bruno pediu a troca pela cor, e a `050` achou duas coisas que esta decisão
não viu. **Nenhuma cor de borda a dava:** a borda fica entre o verde (0,145) e
o fundo claro (0,933), a 5,05:1, e só um par a 9:1 deixa um tom passar 3:1
contra os dois — o âmbar já estava no ótimo, 2,25. **E a troca que o jogador
vê é PARADO → ESCOLHIDO**, porque só se aloca com barco à espera: ali a borda
mudava 1,33:1, não os 2,26 daqui. A cor da troca passou a um SELO no rótulo
"Escolhido"; a borda, a proveniência e a amarra desta decisão ficam de pé.
