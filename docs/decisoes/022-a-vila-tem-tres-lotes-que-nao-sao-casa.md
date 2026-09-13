# 022 — A vila tem três lotes que não são casa, e a obra mostra o nível seguinte

**13/09/2026.** O item **12** do segundo playtest, na letra do Bruno:

> *"Pode criar modelos de prédio em reforma e construção, assim como edifícios
> mais avançados, como casas de dois andares, comércios variados, pracinha,
> igreja e etc, para irem aparecendo à medida que o porto cresce e se expande.
> Podemos ver indicadores que farão a cidade só redor ir crescendo junto do
> porto."*

**Nada aqui encosta na economia nem em prop nenhum.** O `GameState.gd` não foi
tocado, a tabela de âncoras não mudou de forma, e das catorze imagens da bateria
só as sete que mostram o mapa se mexeram — `icones`, `frota` e os cinco painéis
saíram byte a byte iguais. A mudança é toda dentro da vila, que é ASSADA no SVG.

---

## 1. O âmbito diz não a metade do pedido, e cada não tem um número

A triagem já avisava que *"fazer o 12 começa por decidir o âmbito"*. Medido:

**"Casas de dois andares" já existem.** É o `--nivel-vila=2`, desde 04/09: a
vila tem três níveis, e o 2 é o sobrado. Não havia nada a construir.

**"Prédio em reforma" NÃO pode ser um terceiro estado do armazém nem do
escritório.** O `comprar_estrutura()` é **instantâneo** — desconta o caixa e
acrescenta à lista, sem duração nenhuma. Um estado "em obra" só existe se a
obra DURAR, e fazer a obra durar é mexer na vazão, que é a economia medida e
está fora dos limites sem `/balancear`. Construir só o desenho daria um estado
que nenhuma partida monta — o `barco_medio` outra vez.

**Na VILA, ao contrário, a obra não custa mecânica nenhuma**, e é lá que ela
entrou.

**"À medida que o porto cresce" reabre decisão registada.** A vila é assada no
SVG de propósito, com a razão escrita ao lado desde 04/09: *"prop é para o que
troca de estado DENTRO de uma partida. A vila troca entre Fases, que é fronteira
de conteúdo e não de turno — e assar poupa vinte nós permanentemente visíveis
que nunca seriam tocados."* Amarrá-la ao porto obrigaria a tirá-la do SVG.

⚠️ **Mas o "indicador" que o pedido quer entrou, por outro caminho:** a obra de
um nível é desenhada **com a altura do nível SEGUINTE**. A vila deixa de mostrar
só o que é e passa a mostrar o que vem — o que está em obra no nível 1 tem o
tamanho do que estará pronto no 2. No último nível não há seguinte e ela sobe um
terço: a cidade não para de crescer porque a Fase 5 acabou.

---

## 2. A ESCALA decidiu o desenho, e ela exclui o "comércio variado"

Medido antes de desenhar seja o que for:

| | |
|---|---:|
| lotes que a vila gera | **34** (18 na frente, 16 no fundo) |
| lotes **visíveis** no quadro de 720 | **24** |
| largura de um lote na tela | **51 px** |
| parede de uma casa, nível 1 → 3 | **12–15 px → 32–43 px** |

A 51 px de largura e 13 px de parede **não há detalhe nenhum que distinga um
comércio de uma casa**: um toldo tem 20 px e uma vitrine 4. O que distingue é a
SILHUETA — a mesma lição do arrasteiro, que só tinha lugar para uma peça
memorável, e a dos retratos, onde a pose venceu a cara.

Daí os três que entraram serem exatamente os três que mudam a FORMA do lote:

- **a obra** — um lote **sem telhado**, numa fileira de telhas;
- **a igreja** — um lote com uma **vertical**, numa fileira de horizontais;
- **a praça** — um lote **sem casa**, numa frente de rua contínua.

O comércio ficou de fora, e fica registado que ficou: ele pede uma escala que
esta vila não tem. Quando a Fase subir a vila para o nível 3 (parede de 43 px),
a pergunta pode ser refeita.

---

## 3. As cores saíram todas de medição, e duas contrariam o óbvio

⚠️ **O esqueleto de obra NÃO é cinzento.** Concreto pede um cinzento, e todo
cinzento desta paleta cai na banda de um dos dois quintais — o mapa pavimentado
desenha `terra_clara` (lum 141) e o outro `terra_escura` (lum 104):

| | sobre `terra_clara` | sobre `terra_escura` |
|---|---:|---:|
| `pedra_clara` | **0,05** (some) | 0,29 |
| `pedra_media` | 0,18 | 0,12 |
| **`casa_a`** (creme) | **0,64** | **1,24** |
| `tronco` (o andaime) | 0,48 | 0,30 |

É a regra do gancho do pau-de-carga: um prop atravessa dois fundos e nenhum tom
do meio ganha os dois. E laje de concreto novo é mesmo clara.

⚠️ **E o piso da praça não é terra.** `solo_claro` é a cor certa para um terreno
e a errada para se VER: mede **0,07** contra o quintal onde a praça pousa.
`calcada` mede 0,30 / 0,76 / 0,52 contra os três fundos — e não é cor nova
nenhuma, é o mesmo material do passeio.

⚠️ **O que obrigou ao meio-fio.** Sendo a mesma calçada do passeio, a praça e o
passeio saíam na captura como um bloco claro contínuo: o que devia ler como um
vão lia como um alargamento da rua. A guia separa-as, e é a mesma `meiofio` da
rua — o mesmo material a fazer o mesmo trabalho.

---

## 4. Duas correções que só a CAPTURA apanhou

**A torre lia como chaminé.** A primeira versão punha-a dentro da pegada da
nave, e o telhado da nave (que tem beiral) comia-lhe a base: o que assomava era
um toco grosso. É a regra do `-x` e a da peça pequena encostada à grande, as
duas ao mesmo tempo. Hoje ela avança para a fachada, sobe **três** vezes a
parede em vez de duas — a 2,0 assomava 14 px acima do beiral, que à escala desta
vila é a altura de um telhado — e o remate **escalona** em vez de ser uma tampa:
um telhado chato de 4 px sobre uma caixa é exatamente o desenho de uma chaminé.

**A obra lia lindamente a 4× e sumia a 1×.** Ela é creme e ganha do fundo, mas
não se separa das CASAS, que são do mesmo creme. É a regra do armazém — a esta
escala quem separa não é o tom, é a linha escura —, e três travessas finas numa
só das duas faces visíveis são meia linha. Hoje são grossas e nas duas.

---

## 5. As guardas, e onde cada uma vive

**No GERADOR, porque é geometria e corre a cada geração:** a torre é a peça mais
alta da vila e **cresce com o nível** — sobe três vezes a parede, que vai de 20
a 64 px. O que cabe no quadro hoje sai dele na Fase em que a vila subir, e sair
do quadro não dá erro: dá uma torre decapitada que ninguém vê, porque ninguém
gera o nível 3 para olhar. A guarda percorre os três níveis e **reprova antes de
escrever**.

**No TESTE DE DESIGN (D24), porque é desenho:** a vila não é prop nenhum, então
o `asset_validator` não a vê. É a terceira vez que este projeto lê a COR do mapa
— o D20 pergunta-a à rua, o D21 à água.

⚠️ **E a pergunta é ao RASTER, não à tabela.** Recalcular no teste onde a torre
devia estar seria reconstruir a decisão que se quer conferir. O gerador publica
um **ponto de prova** por lote especial ("no pixel (x, y) tem de estar o remate
da igreja") e o teste pergunta ao PNG o que lá ficou pintado.

---

## 6. O que a sessão descobriu, e quase tudo custou uma correção de guarda

### 6.1 A prova por PIXEL ÚNICO é frágil, e mentiu três vezes seguidas

Reprovou peças que estavam lá, por três razões diferentes:

1. **mirava o meio de um volume** — que em isométrico cai na FACE lateral, não
   no topo: o teste lia `67737d` (a telha sombreada) onde a tabela prometia
   `7f8c98`;
2. **caía debaixo do telhado do coreto** — que está a 9 px do chão e se projeta
   para cima e para TRÁS, tapando todo ponto de `mx + my` menor;
3. **caía dentro de uma copa** — com quatro árvores num lote de 51 px, o piso da
   praça aparecia em manchas.

Hoje conta-se o DESENHO numa janela, que é a lição que o D17 já tinha pago.

### 6.2 ⚠️ E A JANELA TEM DE SER DA ESCALA DA PEÇA — dois defeitos não pegaram

Com um raio único de 12 px, **dois defeitos injetados passaram inteiros**:

- **tirar o campanário da igreja** passava, porque a janela ainda apanhava o
  remate 7 px abaixo;
- **dar um telhado à obra** passava, porque à volta dela há creme por todo o
  lado.

Cada prova traz agora o seu raio e o seu mínimo: uma peça de 18 px pede uma
janela de 9×9, uma laje de 50 pede 21×21.

### 6.3 ⚠️ A GUARDA QUE SE SATISFAZ COM O VIZINHO

É o que estava por trás dos dois casos acima, e apareceu uma terceira vez: a
prova do piso da praça contava os pixels da **calçada da rua**, que passa a
poucos pixels dali — teria passado com a praça inteira apagada. Hoje ela mede o
**coreto**, que é a única peça que só a praça tem.

E a obra ganhou uma prova **negativa**, porque o que a define é uma ausência:
ter laje creme não a distingue das casas; **não ter telha por cima**, sim.

### 6.4 ⚠️ Número absoluto dentro de peça com tamanho próprio

A cruz ia de `cx0 - 0,14` a `cx0 + 0,22` — **0,36 unidades num campanário de
0,30**, uma cruz mais larga do que a torre que a sustenta, cobrindo o topo
inteiro em planta. Não deu erro nenhum, e quem a apanhou foi a prova do D24 a
ler `tronco` onde a tabela prometia telha. É a irmã de *"encolher um prop
escala-se no GRUPO, nunca reescrevendo as literais"*, do outro lado.

### 6.5 ⚠️ E o `json.dump` truncou a tabela de âncoras antes de falhar

O `main()` do gerador tem um comentário a explicar que o SVG se gera ANTES de
abrir o arquivo, *"que trunca de imediato, e um erro deixaria o mapa vazio"*. A
tabela de âncoras não tinha a mesma proteção: um `NameError` dentro de
`tabela_ancoras()` deixou o `.json` com **zero bytes**, com o `open(..., "w")` já
feito. Ficou registado aqui porque a lição é do arquivo e não do erro.

---

## 7. Como se provou

**As cinco suítes verdes** e `DOCS OK`. **A bateria correu duas vezes e as 14
imagens batem byte a byte**; contra o antes, mudaram as sete que mostram o mapa
e mais nenhuma. **A tabela de âncoras não mudou de geometria** — os lotes são os
mesmos, só o que se desenha em cima deles é que mudou.

**Cinco defeitos injetados, cada um a reprovar pela guarda certa:**

| defeito | quem reprovou |
|---|---|
| a torre sobe 9× a parede | a guarda do gerador — sai 163 px do quadro no nível 3 |
| a obra ganha telhado | D24, prova negativa — 176 px de telha onde devia haver laje |
| a praça perde o coreto | D24 — 0 px de `telha_d` |
| a igreja perde o campanário | D24 — 1 px de `telha_c`, e o mínimo é 6 |
| a vila deixa de ter igreja | D24 — "a vila tem igreja", com os tipos publicados |

Os dois do meio **não pegavam** na primeira versão do D24, e é dessa falha que
saem as lições 6.2 e 6.3.
