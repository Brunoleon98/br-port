# 028 — O tronco do coqueiro arqueia, e a régua da forma não responde por ele

**16/09/2026.** A `024` fechou o item 8 com uma pergunta em aberto, e uma só:
*"o tronco do coqueiro (índice 0,491, 16×61, três na tela) — a secção não
ajuda, mas **curvar o EIXO dele curvaria a silhueta**, e isso não foi medido."*
Esta é a sessão que o mediu. O tronco arqueia **30°**, e o número saiu da
imagem — mas o que sustenta a decisão **não é o índice da silhueta**, porque ele
não sabe responder a esta pergunta. É esse o achado.

---

## 1. A régua, e onde ela deixa de valer

O índice de `tools/medir_silhueta_props.py` normaliza entre duas formas ideais
da **mesma caixa envolvente**: 0 é a elipse, 1 é a caixa isométrica. Medida a
banda a 16×61, a primeira surpresa já contraria a premissa do item:

| a 16×61 | f_eixo |
|---|---:|
| elipse (o piso) | 0,401 |
| **cilindro ideal** | **0,741** |
| caixa isométrica (o teto) | 0,768 |
| **o tronco de hoje** | **0,590** |

O cilindro cai a **92% do caminho** entre a elipse e a caixa — porque um
cilindro esbelto tem dois lados VERTICAIS, e a vertical é uma das três direções
que esta câmera dá a uma caixa. E o tronco, com o seu afunilamento e o caimento
de 4°, já mede **abaixo do cilindro**: 0,491 de índice contra 0,92 dele.

⚠️ **Logo o tronco nunca leu quadrado.** Os 0,491 que o item herdou da `024`
liam-se como "a meio caminho da caixa", e o que eles dizem é outra coisa: a
peça já é mais redonda do que o objeto redondo com que se compara.

## 2. E ao curvar, o índice vira artefacto

Varrido, com um render por ponto:

| curva | índice | caixa | flecha contra a corda | topo anda |
|---|---:|---:|---:|---:|
| 0° (hoje) | 0,491 | 16×61 | 1,73 px | — |
| +15° | −0,465 | 18×57 | 2,53 px | 4,6 px |
| +30° | −0,439 | 24×53 | 3,66 px | 8,8 px |
| +45° | −0,355 | 29×47 | 4,54 px | 13,9 px |

O índice desaba para negativo aos 15° e depois **volta a subir** — não é
monótono, e não é a peça a ficar redonda. É a regra que a `024` já tinha escrita
a morder do outro lado: **referência de forma tem de ter a caixa envolvente da
peça**. Um tronco arqueado deixa de ENCHER a caixa dele — a largura cresce de 16
para 29 px sem que o desenho engorde —, e comparar uma fita curva com a caixa e
a elipse CHEIAS daquele retângulo mede o vazio à volta dela, não a forma.

**Antes de ler um índice normalizado, pergunte se a peça ainda enche a caixa que
o normaliza.** Onde não enche, o número existe e não quer dizer nada.

## 3. Quem respondeu foi outra régua, e ela tem ruído próprio

A flecha do EIXO: o centro de massa de cada linha da silhueta, contra a corda
entre as pontas. ⚠️ **Ela não dá zero no tronco reto — dá 1,73 px.** É o ruído
da própria régua (16 px de largura, seis faces, antisserrilhado), e sem o medir
os 2,53 px dos 15° passariam por "curva". Régua de FORMA não tem zero exato como
a que compara dois arquivos; o piso mede-se antes de os números valerem.

## 4. Os 30°, e por que não 45

A escolha é da IMAGEM, como manda a regra do pau-de-carga — graus de mundo não
são graus de tela nesta câmera. ⚠️ **E a conta previa o dobro:** pela sagita de
um arco, 45° dariam ~6 px de flecha; medidos, deram **3,0** (ou 4,54 contra a
corda). A câmera comprime a direção em que o tronco cai.

Aos **30°** a flecha é 2,1× o ruído da régua e o topo anda 8,8 px — mais de meia
largura do próprio tronco. Aos 45° o tronco **perde 23% da altura na tela** (61
→ 47 px) e lê como cajado, não como palmeira; aos 15° são 1,5× o ruído, e é a
opção tímida. O corte não fica colado a nenhuma ponta da banda.

**O portão foi o do bote da `024`** — *se a diferença não se vir, pare e
registe*. Ela vê-se: nas três palmeiras da captura de jogo, a 3× de ampliação,
o que era um poste passou a ler como coqueiro.

## 5. A copa anda com o topo, e isso é derivado

Os segmentos do tronco **sobrepõem-se** (`FOLGA_TRONCO`): encostados topo a
topo, cada junta seria um par de faces coplanares e sairia o losango preto que
já mordeu duas vezes neste kit, multiplicado pelo número de juntas.

A copa é outro PNG, no MESMO `offset` da cena, e tem de pousar no topo NOVO. O
deslocamento sai da geometria (`topo_tronco`), não de um número escrito. ⚠️ **O
`+0,14` em `y` que já lá estava fica onde está** e não é isso: ele é anterior ao
arco e desloca a copa contra a PROJEÇÃO, não contra o caimento.

## 6. A guarda nova — D30, e a primeira métrica reprovou o que estava certo

Nada perguntava se as duas metades de um prop co-ancorado se encontram: o
`asset_validator` valida cada asset sozinho e o D2 mede pegada contra a rua. Uma
copa a pairar ao lado de um tronco não dá erro nenhum — é a gola que saiu a
flutuar dez pixels abaixo do pescoço em 13/09, à escala do mapa.

**O par sai da CENA** (os nós do cenário que partilham a mesma posição), e foi a
derivação que achou o SEGUNDO par, que eu não sabia que existia: `poste` +
`poste_luz`.

⚠️ **E ele reprovou a primeira métrica, que estava errada.** Ela pedia que a
peça de cima COBRISSE o topo da de baixo — a fração de desenho numa janela, a
régua do D17 — e a luminária deu 0,11: ela não cobre a ponta do braço, **ela
continua a partir dela**. Duas metades de um prop não se sobrepõem, encaixam. O
que vale para as duas é onde está a MASSA da de cima: em cima da ponta da de
baixo. Uma guarda que reprova o que está certo gasta-se numa vez.

A distância normaliza-se pela ALTURA DESENHADA da peça de baixo — um corte em
pixel envelheceria quando o `ZOOM` mudasse, e as duas medidas encolhem juntas.
⚠️ **E o denominador mede-se com a MESMA régua de alfa dos pontos:** a primeira
versão usava o `get_used_rect()`, que conta a sombra de contacto, e então mexer
na sombra mexeria no número sem ninguém tocar no encaixe.

Banda medida **pelo próprio código**: encaixado dá 0,075 (poste) e 0,110
(coqueiro); o defeito injetado — a copa velha por cima do tronco curvo, que é
exactamente "a copa não seguiu" — dá **0,400**. O corte vai ao meio, em 0,26,
com 2,4x de folga de um lado e 1,5x do outro.

⚠️ **E ela defende o que defende:** o defeito medido é uma copa parada enquanto
o tronco arqueia 30°. Um descolamento de um ou dois pixels passa por baixo, e
isso escreve-se em vez de o teto ser apertado até caber.

## 7. O que NÃO foi feito

A **secção** do tronco continua hexagonal, e é decisão da `024`: a 16×61 o
cilindro ideal mede 0,741 contra 0,768 da caixa, e arredondar não paga. O que
mudou foi o EIXO, que é a outra pergunta.
