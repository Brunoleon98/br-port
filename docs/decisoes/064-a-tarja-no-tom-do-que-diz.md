# 064 — A tarja no tom do que diz

**25/09/2026 · quinta passagem da frente 3 do A5**, depois de o Bruno pedir
«continue» sobre a quarta (`063`). **Candidata: o aceite visual é dele.**

## O que se decidiu

A tarja de cada painel veste o tom do que ela diz, com as cores que o jogo já
usa na faixa de mensagem para bom e ruim:

| Tom | Onde |
|---|---|
| **verde** (`TextoFaixaBom`, 5,19:1 no creme) | «Lucro», «Depois de pagar», «Parcela quitada», «Negócio fechado», «Você quitou…» |
| **vermelho** (`TextoFaixaRuim`, 5,38:1) | «Prejuízo», «Faltam», «Parcela não paga», «Negócio perdido», os três motivos de derrota |
| **âmbar** (o de antes) | «Valor original» e o resultado zero |

A borda e o número principal mudam juntos (`TarjaNarrativaBoa`/`Ruim`,
`RotuloTotalBom`/`Ruim`); a linha de apoio e a barra não. O porquê: nas
referências da `063` o resultado lê-se antes dos números — a caixa do lucro do
*Two Point Hospital*, o fim de dia do *Papers, Please* —, e o jogo já tinha o
vocabulário, medido no mesmo creme (`faixa_msg` e `tarja_narrativa` têm o mesmo
`bg_color`). Nenhuma cor nova.

**O tom é redundante com a palavra, e é de propósito**: vermelho contra verde
não se lê sem distinguir as duas, e a palavra continua a carregar o sentido.
Não pinta nenhuma OPÇÃO — a `062` recusou cor para «seguro»/«aposta» por
enviesar a escolha —, só estados e resultados: a tarja da negociação aberta
fica âmbar.

## A guarda

O F14 do `teste_fumaca` confere, em cada tarja que abre (cobrança antes e
depois nos dois casos, negociação aberta, fechada e perdida, boletim, balanço
dos dois lados), que o tom veste a PALAVRA — a tabela é do que o jogador lê, e
uma frase que ela não conhece reprova. O tom sai do código do painel e a
palavra da `Narrativa`, dos textos dos painéis e do `_check_end()`: duas
escritas. O balanço abre com o `won` e o `end_reason` que o jogo deixou.

Seis defeitos injetados, seis reprovações pela guarda certa: o tom do boletim
invertido, a resposta de quem não pagou em verde, a variação do número
esquecida, a despedida do Arlindo invertida, a cobrança neutra e o balanço
invertido.

## O que se aprendeu

**O tema partiu-se e a fumaça passou verde.** O comentário novo no
`tema_brport.tres` tinha o `;` só na primeira linha; o parse do tema inteiro
falhou, as cenas abriram sem ele (o Godot troca o recurso por null e segue), e
a fumaça — que confere que o ARQUIVO de cada dependência existe — deu verde.
Quem reprovou foram o teste de design (alvos de toque) e a bateria (erro
impresso). O F1 passou a CARREGAR todo `.tres` do projeto, e o comentário
partido de volta reprova-o.

## Medido

Mudaram **9 das 36 fotos** da quarta para a quinta: as que têm tarja com tom.
As duas rodadas da contra-oferta, neutras, saíram idênticas. Seis suítes,
`ESCOPO UI OK`, `GUARDAS OK`, `COBERTURA OK`, sentinela intacta; contraste 369
textos em 25 estados, nenhum abaixo do AA.
