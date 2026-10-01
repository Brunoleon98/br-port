# 074 — A ruína com desgaste: o galpão e o escritório que vão ser reconstruídos

**28/09–01/10/2026 · frente 4 do A5, família ruína** — a terceira família da
frente, depois da escala e dos camiões (`069`, `070`) e da frota (`071`–`073`).
A nota que ela responde é a de 23/09: *«a ruína com mais desgaste»* (plano v3,
§7, item 4). A segunda candidata foi **aceite** («Ficou bom»), e os dois
prédios estão no jogo.

## O que o Bruno escolheu

| Pergunta | Resposta |
|---|---|
| A família seguinte da frente 4 | **Ruína e obras**, a recomendada, contra a animação |
| Que peças | **Galpão e escritório**, a recomendada. O píer vazio, o chão do porto e o píer 1 ficaram fora |
| Que desgaste | **Os quatro**: menos prédio; quinas e umidade; ferrugem, remendos e lona; mato e entulho |
| O galpão V3 aprovado com o ChatGPT, que nunca chegou ao GitHub | **Refazer daqui pela leitura aprovada** (`art_lab/plano/decisoes_da_frente/036`) |
| As «obras» do nome da família | **Ficam fora**: obra que leva turnos é mecânica nova, do item 5 do plano |
| A composição do galpão (perguntada ANTES do render, com prévia em ASCII) | **Esqueleto no lado do cais**, a recomendada, contra o telhado caído ao meio |
| A composição do escritório (idem) | **Canto de pé com árvore**, a recomendada, contra um resto de telhado |
| A 2.ª candidata | **«Ficou bom»** |

## Porque a ruína tinha de mudar de vocabulário

A ruína de 05/09 já não partilhava as peças do prédio pronto, mas fora
desenhada com o repertório da CASA: alvenaria lisa, telhado de duas águas de
madeira, janela com tábua. Ao lado do galpão pronto, com doca, chapa, zinco e
portão de enrolar, ela lia como a ruína de outro prédio: quem comprava o
armazém via nascer uma coisa que não estava lá. O mesmo valia para o
escritório. Era um canto de alvenaria limpo e não tinha nada do toldo azul nem
da placa amarela do pronto.

A ruína passou a ser **o mesmo prédio, com menos prédio**:

- **o galpão** mantém a doca (com a quina partida e a laje do deck caída), a
  chapa (velha, com ferrugem a escorrer) e o zinco (com a **lona azul presa
  por dois pneus**). A baia está aberta e o portão de enrolar, desbotado, caiu
  e ficou encostado à frente dela. O terço do lado do cais perdeu chapa e
  telhado e mostra o esqueleto de aço: pilares, viga, tesoura na empena e
  contravento em X, com uma diagonal partida. Há ainda mureta de alvenaria
  com tijolo à vista, calha partida, trepadeira, capim e um arbusto dentro do
  esqueleto. Cabe na pegada do pronto;
- **o escritório** é o canto em L de antes. Tem reboco caído e quinas
  lascadas, umidade a subir da base, o **toldo azul rasgado** pendurado sobre a
  porta e a **placa amarela** caída e encostada à parede. No chão há **telha
  laranja** partida, a do telhado que vai voltar, e uma **árvore** cresce lá
  dentro. A copa fica abaixo da cumeeira do pronto: o nó é o mesmo nos dois
  estados, e a vila sabe onde o prédio a tapa pelo sprite.

## O que mudou no gerador

- **`material_alvenaria_velha()`**: reboco caído, quina lascada e umidade num
  material só, em coordenada de MUNDO. É a primeira vez que o nó Ambient
  Occlusion com `inside` (plano de arte, §7.3, **C3**) entra num prop.
  ⚠️ A primeira candidata somava o ruído à oclusão, e o escritório saiu com
  uma moldura laranja à volta de cada parede. A lasca é perto da quina **E**
  num troço sorteado, e isso é um produto (a armadilha está no comentário da
  função).
- **`material_escorrido(mundo=True)`**: a ferrugem da chapa e do zinco do
  galpão. As peças são `caixa()` esticadas, e a coordenada de objeto lê a
  malha antes do `scale` (`071`).
- **`tufo()` e `copa_bolas()`**: o capim e as copas do mato.
- Paleta nova: `tijolo`, `lona`, `chapa_velha`, `zinco_velho`,
  `laranja_velho`, `toldo_velho`, `placa_velha`, `capim`.
- A parede de −y do escritório sai 0,005 para fora do piso. As duas faces
  eram coplanares na faixa de 0,09 a 0,18 de altura.

## Como se mediu

- **Prancha** (`prancha_prop.gd`), no jogo, no dia 1 e sobre a terra do pátio:

  | | tamanho a 1:1 | Weber contra o chão | Δ16 A↔B |
  |---|---|---|---|
  | galpão | 109×105 → 118×112 px | 0,06 → **0,22** | 0,1998 |
  | escritório | 85×74 → 85×83 px | 0,08 → **0,04** | 0,0896 |

  O escritório ficou mais perto do chão em mediana: o tijolo e a umidade
  baixaram o valor. Quem o separa da terra é a sombra e o topo claro das
  paredes, e assim foi aceite.
- **Render** com a oclusão: galpão 5,5 → 5,1 s e escritório 4,3 → 4,8 s, em
  corridas soltas e dentro do ruído delas. O C3 deixava este custo por medir,
  e ele não pesa.
- `.pck` **+9.264 bytes** (13.508.344 → 13.517.608, +0,07% do `.pck`).
- As seis suítes verdes. Bateria de capturas com `COBERTURA OK`, e as seis
  fotos do porto em ruínas olhadas.

## O que ficou de fora

- **As obras** (estado «em obra» de um prédio comprado): pedem mecânica, a
  compra é instantânea. É do item 5 do plano.
- **O píer vazio, o chão do porto e o píer 1**: escolha do Bruno no escopo.
- **Guarda nova nenhuma.** O D2 confere a pegada DECLARADA e não a geometria,
  e isso continua escrito ao lado do gerador. O capim e o portão ficaram
  dentro da pegada por conta, e não por asserção.
- ⚠️ **O `z` do módulo voltou a ser sombreado** por um laço do `montar()`,
  como na `073`. Desta vez falhou alto (`UnboundLocalError`) na primeira
  corrida, e o nome do laço é `zt`, com o aviso ao lado.
