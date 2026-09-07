# 013 — A esquina chanfrada, e a cor que ninguém media

**08/09/2026.** O fecho do item **4b** da segunda jogada — *"a falta de conexão
das estradas"* —, que ficou a um terço em 07/09 e estava medido em
`docs/decisoes/012` §5.

Nada aqui encosta na economia: o `GameState.gd` não mudou e nenhuma constante
`# TUNING:` foi tocada. O balanceamento continua **100% / 80,2% / 37,3%**, com
a parcela em R$530.000.

---

## 1. O que faltava era a PONTA, e são duas por cotovelo

O 4b nunca foi um buraco na rede — isso ficou medido em 07/09, tingindo cada
peça do `vias()` e lendo o render: a rua sai ligada de ponta a ponta. O que o
Bruno circulou a vermelho é o que sobra quando um RETÂNGULO vira 4 unidades de
uma vez: de cada lado da curva fica uma quina de 90° a apontar para fora, e
ponta de asfalto no meio do relvado lê-se como estrada que acabou.

**São duas pontas por cotovelo, e não uma.** A face virada para a vila tem 4,00
unidades e acaba na quina de fora da curva; a virada para o avental tem as
mesmas 4,00 e acaba na quina de dentro da seguinte, que fica a **1,0 unidade da
beira do cais** — a rua a espetar-se no avental. As outras duas quinas de cada
cotovelo são REENTRANTES: é por ali que a rua continua, e "arredondá-las" seria
acrescentar asfalto fora do retângulo que a tabela de âncoras publica, que é
exatamente o defeito que os lotes reservados pagaram em 07/09.

Logo: chanfram-se as duas salientes, e só essas.

## 2. O corte sai da largura da rua, e é meia

`CHANFRO_COTOVELO = RUA_LARG / 2` — 0,90 hoje. Não é gosto disfarçado de
número: meia rua é o raio de giro que se lê a esta escala, e o corte tem de
caber na PROFUNDIDADE do cotovelo, que é a própria largura da rua. Deriva-se
dela porque **a rua já mudou de largura uma vez** (1,10 → 1,80, em 07/09): um
chanfro cravado teria ficado com o tamanho da rua velha sem erro nenhum a
apontá-lo.

Medido no render, a ponta recua 18 px na tela em cada uma das duas quinas.

**A viela continua ligada, e com folga.** Ela abre a 0,82 da quina e vai até
2,18; o chanfro come 0,08 do começo dela — 1,6 px, invisível — e deixa 1,28 de
boca encostada à face reta.

## 3. E o chanfro cresce com a folga, senão a calçada sai o dobro

A calçada e o meio-fio são o MESMO polígono inflado, e a primeira versão usou
o mesmo corte nos três. Errado: afastar a esquina de `folga` em `mx` **e** em
`my` afasta a reta a 45° de `folga · √2`, não de `folga`. Medido no render, a
faixa de passeio saltava de **3,9 px** nas retas para **8,8 px** em cima do
bisel, e lia-se como um muro. Recuar o corte de `folga · (2 − √2)` põe as duas
retas paralelas à distância certa: **6,2 px**.

Sobra 1,58×, e isso não é defeito — é a projeção. Em isométrico a direção
(1,1) comprime-se e a (1,−1) estica-se, e uma faixa de largura constante NO
MUNDO não tem largura constante NA TELA. Corrigir o resto seria escrever pixel
dentro de geometria de mundo, que é a fronteira que o `tela()` existe para não
deixar atravessar.

## 4. O achado: uma fita de passeio atravessada na pista

Ao medir o cotovelo para o chanfrar, apareceu um defeito que vivia desde 07/09
e que ninguém podia ver: **a calçada do cotovelo era desenhada DEPOIS do
asfalto da faixa reta**, e é 0,22 mais funda do que ele nos quatro lados. O que
sobrava era uma fita da cor do passeio ATRAVESSADA NA PISTA, da largura da rua
inteira, na entrada de cada um dos cinco cotovelos.

Medida no render, em (139, 260): `#aeb8bf`, que é a calçada, onde tinha de
estar o `#49535b` do asfalto.

A geometria estava toda certa — todos os retângulos no sítio. Era ORDEM DE
DESENHO. E é por isso que nenhuma das cinco suítes o via: **toda a maquinaria
de cerco deste projeto pergunta POSIÇÃO.** O D2 mede pegada de prop contra
faixa publicada, o D13 §8 mede lote reservado contra acesso, o D14 mede casa
contra vão da vila. Nenhuma delas pergunta com que COR o mapa pinta um ponto.

Junto com o chanfro, a faixa reta passou a acabar onde o cotovelo começa: ela
ia até ao `my1` e, com a esquina cortada, encheria de volta o triângulo do
chanfro — a esquina sairia quadrada com o polígono a dizer que não era.

## 5. O bloco D20, que é o primeiro a olhar para a cor

Rasteriza os dois mapas com o ThorVG — o mesmo importador do jogo, a mesma
escolha do `medir_enquadramento` — e percorre a `ROTA_ESTRADA` exigindo que
nenhum ponto dela caia em calçada.

**Por que a rota, e não pontos escolhidos:** ela é uma constante escrita À MÃO
no `Main.gd` e o mapa sai do gerador, logo as duas pontas da asserção têm
fontes independentes. O D13 já a percorre contra os RETÂNGULOS publicados;
aqui ela é percorrida contra o DESENHO, que é a pergunta que os retângulos não
sabem responder.

**Por que «não é calçada» e não «é asfalto»:** a rodagem leva pintura — linha
central, passadeira —, e exigir o cinzento do asfalto reprovaria uma zebra bem
desenhada. O que nunca pode aparecer no meio da pista é o PASSEIO.

**Dois defeitos injetados, e os dois reprovaram só pela guarda certa:**

| Defeito injetado | Onde reprovou | Quem mais reprovou |
|---|---|---|
| a ordem de desenho antiga, de volta | `(0,55, 6,15)`, a entrada do cotovelo 1 | ninguém |
| o asfalto da faixa reta 0,6 mais estreito | `(0,55, −5,75)`, um trecho reto | ninguém |

O segundo prova que o bloco cobre a rua inteira, e não só os cotovelos. E que
**o D13 passou nos dois** é o ponto: os retângulos publicados continuavam a
dizer que ali havia rua.

## 6. O que NÃO ganhou asserção, e por quê

**O chanfro.** A análise de 07/09 já o dizia — *"não há asserção a escrever,
porque geometricamente não falta nada: é defeito de LEITURA"* —, e ao tentar
escrever uma confirmou-se: qualquer guarda sobre o chanfro só dispararia acima
de `RUA_LARG`, e acima de `RUA_LARG` o polígono do cotovelo já se auto-cruza.
Uma guarda que só reprova fora do domínio válido é confiança de graça, que é o
que o `CLAUDE.md` chama de "a guarda que duas outras já implicam".

Conferido com os números, para quem vier depois: nas duas quinas a rota do
camião passa com **0,90 de folga** — exatamente o tamanho do chanfro —, e a
folga escala com `RUA_LARG` porque tudo naquela conta sai dela.

**O retângulo publicado dos cotovelos ficou como estava**, e é maior do que o
asfalto desenhado. É assim que tem de ser: ele é o cerco contra o qual o D2
mede pegada de prop, e um cerco que erra tem de errar para o lado seguro. O
`chanfro` e o asfalto cru saem à parte na tabela, para quem precise da forma
DESENHADA.

---

## O que este trabalho descobriu de caminho

1. **Um comentário do gerador apontava para um bloco de teste que não existe.**
   Dizia que os lotes reservados eram publicados "para o D20 os poder conferir"
   — e o D20 nunca foi escrito: a asserção vive dentro do D13, §8. Referência
   corrigida. É a irmã de "se está escrito que sai de algum lado, faça-o sair
   de lá", um andar acima: um número que aponta para um teste inexistente
   parece cobertura e não é.

2. **O camião anda exatamente na aresta de uma barra da passadeira.** Um
   defeito injetado que pintava a zebra com a cor da calçada NÃO reprovou, e
   não foi por falha do D20: com `RUA_LARG/8` de passo, a barra n.º 6 acaba em
   `dentro + 1,35`, que é ao milésimo a faixa de rodagem. O defeito nunca
   chegou à linha amostrada.
