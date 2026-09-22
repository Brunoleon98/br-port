# 047 — A rua fica em 1,8, e a mão dupla era de código, não de largura

**23/09/2026 · opção (b) do briefing de 23/09c, "a rua parada em 1,8",
escolhida pelo Bruno — e, a pedido dele, a mão dupla que faltava**

## O que se decidiu

**A rua FICA em 1,8.** O item fecha sem mexer no `RUA_LARG`, no `RUA_RECUO`
nem no enquadramento.

**E os camiões passaram a cruzar-se.** Dois camiões novos sobem a rua pela
faixa de DENTRO, de costas para a câmera, com oito silhuetas novas. Os três
da ida continuam na faixa de fora, a entrar nos berços.

## Por que 1,8 — medido, e o briefing estava errado no mecanismo

O item vinha com a mesma frase desde 14/09: *"alargá-la empurra o
`RUA_RECUO` e o enquadramento"*. Medido nesta sessão, regerando os quatro
mapas e correndo o teste de design a cada largura:

| rua | faixa | o que reprova hoje | ganho na tela (720) |
|---|---|---|---|
| **1,8** | 0,90 | nada | — |
| 1,9 | 0,95 | **armazém no cotovelo, por 0,004** (cabe se for recentrado) | +1,8 px |
| 2,0 | 1,00 | armazém (por 0,007, sem remédio) **e** a barreira | +3,6 px |

⚠️ **O `RUA_RECUO` não mexe nesta conta.** A janela que aperta é em `my`,
entre o ACESSO AO BERÇO e o COTOVELO (`3,98 - RUA_LARG`), e o `RUA_RECUO`
desloca a rua em `mx`: o cotovelo tem a largura da rua em `my` esteja ela onde
estiver. Acima de 1,9 quem teria de ceder é o acesso (1,2 em `my`) ou o
armazém; o pátio em `mx` (`5,28 - RUA_LARG` contra 3,11 de pegada) só aperta
aos 2,17. E os *"1,48 de folga até à vila"* do comentário do gerador eram até
ao FUNDO do lote — da calçada à frente da casa há 0,13.

⚠️ **E o ganho não se vê.** Uma unidade de `mx` vale 17,9 px de largura de rua
na tela (400 / √500): a 2,0 a rua ganha 3,6 px, e o recorte lado a lado das
três larguras mostrou-o. A 1,8 dois camiões de 0,45, cada um no meio da sua
faixa, deixam entre si 0,45 — **o tamanho de um camião**. Mais largo, o camião
encolhe contra a rua e ela passa a ler como avenida.

**O que faltava para os camiões se cruzarem não era largura: era haver quem
subisse.** Todo camião descia em `+my`, e a faixa de dentro nunca tinha tido
tráfego. O pedido da segunda jogada (item 2: *"aparecendo na parte de baixo e
sumindo na parte de cima"*) estava feito pela metade desde 07/09.

## A mão dupla

- **`ROTA_RETORNO`** no `Main.gd`: a escada no outro sentido, pelo meio da
  faixa de dentro (`borda - RUA_RECUO + RUA_LARG / 4`) e, nos cotovelos, pela
  meia faixa de `my` baixo. Quem sobe tem a vila à direita; as duas rotas nunca
  se sobrepõem, nem na reta nem na curva.
- **Dois camiões, `CaminhaoRetorno0/1`, SÓ DE PASSAGEM.** Entrar num berço
  obrigaria a virar à esquerda por cima da faixa da ida, e o pedido avisava
  contra trânsito e contra bugs. A carga roda pelos motivos que o porto recebe,
  sem sorteio — o `RandomNumberGenerator` do jogo é o que o simulador mede.
- **Oito silhuetas `_retorno`**, do mesmo construtor (`blender/brp_porto.py`),
  exportadas sozinhas — os 8 PNGs da ida não foram tocados. No retorno a ponta
  que a câmera vê é a TRASEIRA, que nunca tinha sido desenhada: lanternas,
  para-choque, a junta da porta (e as barras de fecho no contêiner, a tampa no
  basculante). O para-brisa fica na face escondida e não se desenha.
- **`silhueta_do_trecho()`** escolhe pelo eixo E pelo sentido. O camião que
  larga o berço continua a sair de ré (`re_no_primeiro`): com a silhueta nova
  ele viraria 180° de um frame para o outro no fundo da baía.

**Custo:** +46.860 bytes no `.pck` (6.286.848 → 6.333.708, **+0,75% do
`.pck`**), medido por export contra a `main` num worktree.

## ⚠️ A régua da assinatura não fazia a média que o comentário dizia

O D13 reprovou o frigorífico de ida contra o de retorno: *"desenham a mesma
coisa (diferença máxima 0,0039)"*. Eram 1.106 pixels diferentes, com a cabine
numa ponta e na outra, e pela média de verdade diferem **0,062**.

O comentário da `_assinatura()` prometia *"cada célula é a média de ~1.000
pixels"*, e a linha fazia `Image.resize(16, 16, INTERPOLATE_BILINEAR)`, que numa
redução de 48x não faz essa média. ⚠️ **E `INTERPOLATE_TRILINEAR` deu o mesmo
0,0039**, medido — trocar o modo não chegava. Hoje ela faz a média à mão:
`shrink_x2()` (média exata 2x2) enquanto couber, e blocos daí até 16.

**E o corte desceu de 0,02 para 0,01.** Os 0,02 eram para a régua sem média.
Com a média, o ruído do denoiser vale ~0,0002 e o par DISTINTO mais perto
entre os 25 desenhos que ela compara (camiões e cascos) mede **0,0327**: a 0,02
sobrava 1,6x desse lado, a 0,01 sobram 50x do ruído e 3,3x do par.

## As guardas novas, e os mutantes que as provaram

O **§7 do D13** (`_d13_retorno`) pergunta o que o §1–§4 não viam com duas
faixas. A faixa sai do **asfalto publicado** (`asfalto` de cada degrau,
`asfalto_my` de cada cotovelo), e confere as DUAS rotas: a relação é entre
elas, e derivar o retorno da ida seria o teste a concordar consigo próprio.
O **D20** passou a ler as duas rotas (290 → 562 amostras). O **§4** ganhou a
condição que faltava: a ida não pode usar silhueta `_retorno` — o teste do
eixo não o via, porque `_retorno_mx.png` também acaba em `_mx.png`.

| mutante | o que reprovou |
|---|---|
| M1 retorno na faixa da ida | a guarda da faixa; e o D20, na esquina `(16.55, 32.65)` — prova que ele lê o retorno |
| M2 a lista ao contrário | a guarda do sentido (a da faixa não o vê, e não é para ver) |
| M3 silhueta sem sentido | a guarda da silhueta do retorno |
| M4 silhuetas trocadas | a condição nova do §4 — sem ela a ida passava |
| M5 a mesma textura duas vezes | a assinatura, a 0,0000, com o corte velho e com o novo |

Base verde conferida entre cada um; original guardado por `cp`.

⚠️ **O que fica sem guarda:** que o `_sair_do_berco()` passe `true` ao
`re_no_primeiro`. Tirá-lo põe o camião a virar 180° no berço, e nenhum teste
anima a saída. Está escrito aqui em vez de apertado.

## As duas folhas de contato cresceram, e as duas reprovaram como deviam

- **`folha_frota`** pedia 1.305 px numa tela de 1.280. Passou a ser DUAS
  folhas por seção (`frota.png` cascos, `camioes.png` os 16 camiões), e as
  chaves saem da tabela em vez de `["my", "mx"]` escrito à mão.
- **`folha_props`** reprovou três vezes, cada uma pela guarda certa: os PNGs
  novos sem nó na cena (ligados ao `CaminhaoRetorno0`), 59 props em 2 páginas
  (a bateria passou a 3), e o rótulo `caminhao_armazenagem_retorno_mx` a pedir
  200 px numa célula de 159. ⚠️ **A célula passou a sair também do rótulo**, e
  não só do desenho: encurtar o nome do arquivo seria esconder o que o rótulo
  mostra. Medido, uma fonte maior deixa de reprovar pelo rótulo e reprova pela
  conta das páginas.

A bateria tem **27 tiros** (eram 25) e fecha com `COBERTURA OK`.
