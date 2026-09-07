# 015 — O pau de carga do n1 é UM PAU SÓ, e o pivô passou a exigir desenho

**09/09/2026.** O fecho do item **6** da segunda jogada — *"o design do
guindaste de madeira pode ser melhorado"* —, escolhido pelo Bruno como arte
pequena e independente.

Nada aqui encosta na economia: o `GameState.gd` não mudou e nenhuma constante
`# TUNING:` foi tocada. O balanceamento continua **100% / 80,2% / 37,3%**, com
a parcela em R$530.000. Mudaram dois PNGs — `pier_n1` e `lanca_n1` — e um bloco
do teste de design.

---

## 1. O que estava errado, e não era o que a queixa dizia

A queixa é de uma linha e não diz o que corrigir. Posto o porto em ruínas ao
lado do completo, o que se vê é **a mesma máquina três vezes**: as três lanças
eram treliças, e a do n1 era a do n2 mais pequena e castanha.

Isso é exactamente a queixa que a TORRE já tinha levado em 06/09 — *"parecem ser
o mesmo, sendo que o porto inicial possui o mesmo guindaste do porto mais
avançado"* — e que se resolveu dando torre própria a cada nível. **A lança ficou
por resolver, e o comentário ao lado dela dizia que não.** Ele prometia, desde
essa sessão, *"um poste de MADEIRA com dois estais e nada mais. Sem treliça, sem
cabine"*: o mastro cumpria a promessa e a lança era uma `trelica()` de 22 peças.
Um comentário que descreve o que não está lá é a forma mais barata desta
armadilha, e este projeto já a tinha registada noutro sítio (o `PREDIOS_DO_PATIO`
que dizia "lido de `Main.tscn`" e era copiado).

**No jogo era pior do que na bancada, e foi a captura nova que o mostrou.** O
porto em ruínas tem UMA doca, e ela é a que encosta à PRAIA: o vazado da treliça
deixava passar a areia clara por trás e as quatro travessas liam-se como os
degraus de uma **passadiça de madeira descendo para o areal**. A `pesca`, a nona
captura, entrou em 08/09 precisamente porque nenhuma das oito mostrava este
estado — e a primeira coisa que ela fez foi denunciar isto.

E havia um defeito solto: o `l1_tirante` era uma barra cinzenta que saía do topo
e **acabava no ar**, sem tocar em nada. É a irmã exacta do estai que em 06/09
caía meia unidade para lá da beira do convés, com a lição já escrita ao lado —
*"um cabo que não chega a lado nenhum passa em todas as asserções que este
projeto tem"*. Corrigiu-se no mastro e não se varreram os irmãos.

## 2. A gramática certa é o triângulo, e ela custa MENOS peça

O que substitui a treliça é o aparelho de verdade: **um pau só**, preso ao
mastro por um gooseneck, e um **amantilho** do topo do mastro à ponta do pau. O
triângulo mastro/pau/amantilho é o que diz "pau de carga" — não a quantidade de
peça, que aqui **desceu de 25 para 8**.

Descer é o certo, e é a regra que este projeto já paga com o galpão em ruína: **a
ruína não é o prédio pintado de velho, é MENOS prédio.** O n2 e o n3 continuam a
ter treliça, contralança e contrapeso; o n1 tem um pau amarrado a um mastro, que
é o que um pontão provisório tem.

**A peça que faltava estava ABAIXO da lança, não dentro dela.** O mastro acabava
em `TOPO + 0,05` — rente ao ponto onde a lança se prende — e de lá não havia de
onde pendurar um amantilho: qualquer linha saída dali nasceria paralela ao pau e
não desenharia triângulo nenhum. Ele passou a `TOPO + 0,80`, em duas seções que
afilam. A 4 px de largura um mastro não tem textura que se veja; o que se vê é a
silhueta a estreitar.

## 3. Três números escolhidos NA IMAGEM, e um deles ao contrário do previsto

**O ângulo do pau.** A câmera come 0,82 de subida no mundo só para uma peça sair
horizontal na tela. A treliça de antes era perfeitamente horizontal no Blender e
**caía 26,6° no ecrã**, com ar de coisa a ceder — que é a mesma armadilha que o
pau-de-carga do arrasteiro pagou em 07/09, e que o `CLAUDE.md` já regista.
Com `SOBE_N1 = 0,42` o pau cai 13,7°, que continua a apontar para o barco — ele
atraca em `-y`, abaixo e à esquerda — sem ler como rampa.

**A cor do pau, e aqui a previsão estava errada.** A primeira versão usou
`tronco` para separar o pau do mastro: 0,45 de Weber no dicionário, o que
parecia de sobra. Medido na captura de jogo, o pau tinha **0,21–0,25** contra a
areia e desaparecia — porque a face que a câmera vê dele é a ILUMINADA, que sai
a ~103 e não aos 97,5 da paleta, contra areia a ~159. Com `madeira_esc` sobe
para 0,33–0,34, e a média do prop contra o fundo vai de 0,35 para 0,44.

⚠️ **A conta que importa nunca é peça contra peça — é peça contra o FUNDO por
onde ela passa, no render.** Foi este o erro desta sessão, e ele está escrito
no `CLAUDE.md` desde 05/09 ("a paleta mente sobre o que se vai separar no
render"). Escrito e cometido na mesma.

**O gancho foi claro e voltou a escuro, pela mesma medição.** Ele era
indistinguível dos olhais dos estais — quatro blocos cinzentos do mesmo tamanho
no mesmo `metal`, e o olho não tinha como saber qual levanta carga. A primeira
correção pô-lo em `metal_claro`, que sobre água FUNDA mede 0,75; só que o que
está debaixo do gancho na doca 1 é o **baixio**, quase tão claro quanto a areia,
e ali o claro deu **0,01**. Quem encontra o gancho não é o tom: é ele ser a
única ferragem GRANDE do prop, depois de os olhais encolherem de 0,11 para
0,075.

## 4. O D17 prometia o desenho e media a caixa

Ao construir o gooseneck apareceu um buraco no teste, e ele é do tipo que este
projeto já apanhou duas vezes com outra cara.

O bloco **D17** exige que o pivô da lança — o `pivot_offset` do `Dock.tscn`, um
só para as três — caia dentro dela, e o comentário dele diz por escrito *"que o
pivô caia dentro do DESENHO de cada uma das três"*. O que ele media era
`used_rect.has_point()`, que é a **moldura**.

Numa lança isso quase não custa nada: o amantilho e o cabo de carga são linhas
finas que **esticam a caixa muito além da peça**, e uma lança inteira construída
a partir de outro topo de torre continua a ter o pivô dentro da moldura enquanto
uma corda qualquer passar por cima dele. É a mesma forma do D7 — *conferir o
QUADRO de um prop não é conferir o PROP* — e da regra dos quatro cantos contra
a faixa.

A pergunta certa é **quanto desenho há à volta do centro de rotação**. Medido:
n1 100%, n2 62%, n3 54% num raio de 2 px. As duas treliças ficam abaixo de 100%
porque o pixel exato do pivô calha num vazado, e isso é legítimo — o piso ficou
em 35%, generoso de propósito: ele existe para pegar uma lança desenhada FORA do
próprio eixo, não para congelar os números de hoje.

**O defeito injetado confirma qual guarda trabalha.** Deslocada a lança 0,45
para fora em `y` — o modo de falha que o próprio comentário do D17 nomeia —, a
asserção VELHA **passa** (a moldura continua a conter o pivô, esticada pelo
amantilho) e só a nova reprova, com 0%. Uma falha, e o código de saída lido do
teste e não de um cano.

## 5. O que NÃO se fez, e porquê

- **Não se mexeu no n2 nem no n3.** Eles têm alfa 0,09 e 0,19 no pixel exato do
  pivô, o que parecia defeito e não é: medido em raio 2, têm 62% e 54% de
  desenho: a treliça está lá, o pixel é que calha num vazado. Um item por
  sessão, e esse não é um.
- **Não se mudou para onde a lança aponta.** Ela varre para `-y` porque é aí
  que o barco atraca, e essa conta saiu do gerador do mapa numa sessão
  anterior. O item 6 é de desenho.
- **Não se pôs carga no gancho.** O n2 tem um moitão carregado e o n3 um
  spreader; o n1 ficar com o gancho vazio é a progressão, e a esta escala mais
  uma peça na ponta fundia com o moitão.

## 6. O que provar na imagem

O antes/depois está em `brport-captura`, e as duas fotos que mudam são
**`inicio`** e **`pesca`** — as únicas dos nove tiros que montam o porto de
nível 1. `icones` e `frota` têm de sair IGUAIS: se mudaram, a alteração vazou
para onde não devia.

Ao tamanho de jogo, o que se pede a quem olhar é uma pergunta só: **o da
esquerda lê como uma passadiça de madeira e o da direita lê como um guindaste?**
