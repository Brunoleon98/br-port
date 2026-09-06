# 012 — A rua de mão dupla, e a viela que a vila não tinha

**07/09/2026.** O bloco da estrada da segunda jogada: itens **2** (via de mão
dupla), **4a** (detalhe da rua), **11** (caminhos de terra) e **4b** (as
estradas que acabam no nada). Feitos os três primeiros; o 4b ficou a um terço,
e está medido.

Nada aqui encosta na economia: nenhuma constante `# TUNING:` foi tocada.

---

## 1. A rua tem 1,8, e o número é medido

O pedido era largura para duas faixas. O comentário que já estava no
`gerar_mapa_iso.py` apontava para a conta do pátio —
`RUA_RECUO - RUA_LARG - CALCADA - APRON` — e dizia que o armazém cabe até 2,2
de rua. **Cabe, em `mx`. E não é essa a conta que aperta.**

Quem fecha primeiro é a janela em **`my`** entre o ACESSO AO BERÇO e o
COTOVELO, que é onde os dois prédios do pátio vivem. Ela vale
`3,98 - RUA_LARG`:

| rua | janela | armazém precisa de 1,987 |
|---|---|---|
| 1,8 | 2,18 | cabe, 0,19 de folga |
| 1,9 | 2,08 | cabe, 0,09 |
| 2,0 | 1,98 | **não cabe, por 7 milésimos** |

A outra saída era empurrar o `RUA_RECUO` para trás. Entre a calçada e a frente
da vila há 1,48 de folga, e a vila é medida do cais como tudo o mais: isso mexe
no enquadramento inteiro, e ficou por fazer.

**E o camião deixou de andar no meio da rua.** Numa via de mão dupla, o meio é
a linha — e a linha é o que a faz ler como de mão dupla. Ele anda agora na
faixa de FORA, a do lado da água: quem segue em `+my` tem o mar à direita, e daí
sai que virar para a doca é virar à direita.

## 2. Alargar a rua deslocou sete props, e o D2 apanhou os sete

Os dois prédios do pátio (o cotovelo mais largo passou a alcançá-los em `my`),
a barreira, o poste, o poste de luz e o cone (que ficaram sobre o asfalto novo),
e a pilha de caixotes e o palete (dentro do terceiro cotovelo). O armazém foi
recentrado no pátio novo; os outros andaram com o meio-fio.

**Isto é o custo real do item 2**, e é maior do que a estimativa que foi dada
antes de o medir.

## 3. As passadeiras saem do `my` dos prédios

Não de um número escrito à mão — eles andaram nesta mesma passagem, e uma zebra
cravada ficaria a marcar a travessia de um prédio que já não está ali. As
barras correm no sentido do tráfego, que aqui é `my`: numa zebra o que se
repete ao longo da via é o vão, e cada barra acompanha quem passa por cima dela.

## 4. A viela responde a duas queixas com uma medida

O item 11 pedia *"caminhos de terra para as casas"*. Medido: entre a calçada e a
frente da casa da frente há **0,13 unidades**, quatro pixels. Não cabe caminho
nenhum — e é a mesma medida que, em 04/09, já tinha mandado as árvores da vila
para o quintal.

O espaço que existe é o de **1,60 entre as duas fileiras**. E a fileira de trás
**não tinha acesso nenhum**: uma fileira de casas sem rua, que é a queixa do 4b
vista do outro lado. A viela sai da face do cotovelo — a que ele circulou a
vermelho — e serve essa fileira, acabando na última casa do quarteirão, porque
viela que passa da última casa é viela que acaba no nada.

## 5. O 4b está a um terço, e o número é este

A face que "acaba no nada" tem **4,00 unidades** de largura em cada um dos
quatro cotovelos. A boca da viela cobre **1,36 — 34%**, igual nos quatro. Sai
da rua uma estrada agora, que era a metade que faltava; a aresta de meio-fio
que sobra continua lá. Achatá-la é chanfrar a esquina, e isso é desenho para
outra passagem.

---

## Os dois defeitos latentes que este trabalho descobriu

Ambos no `vaos_da_vila()`, ambos calados até os prédios se mexerem.

1. **Ele só abria vão quando a coluna EXATA do prédio caía dentro do degrau.**
   A silhueta do armazém tem 124 px e alcança casas a 37 px da coluna dele —
   que num degrau ao lado ficam a menos de meia unidade de `my`, mas cujo
   centro exato cai fora da faixa. Nenhum vão se abria, e a casa saía fatiada.
   Hoje é interseção de intervalos, como em toda a outra parte deste projeto.

2. **O limiar dele é EXATAMENTE o do D14, e os dois medem de sítios
   diferentes.** `0,6` da meia-largura dá o mesmo número que `0,30` da largura —
   zero de folga —, mas o gerador mede do canto do lote e o teste do centro da
   casa. Com o `dmy` sorteado entre 0,72 e 1,28, essa diferença chega a 0,315
   unidades: uma casa cujo centro cai dentro do limiar do teste e cujo canto cai
   fora do do gerador escapa ao vão. Hoje o vão leva essa margem.

A lição vale para além do mapa e está no `CLAUDE.md`: **dois números iguais
medidos de sítios diferentes não são a mesma guarda** — o que gera tem de ser
mais folgado do que o que confere.
