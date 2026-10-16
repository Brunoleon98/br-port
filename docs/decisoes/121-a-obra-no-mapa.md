# 121 — A obra no mapa: o que se está a construir, dia a dia

**16/10/2026 · frente 4 do A5, as «obras» que a `074` deixou de fora** — a
continuação da melhoria gráfica da Fase 1 que o Codex começou no telefone e
não chegou ao GitHub (nenhum ramo `codex/*` depois do fecho do #134). **Em
produção: candidata, sem aceite.**

## Porque agora

A `074` refez a ruína e deixou as obras fora porque obra que leva turnos era
mecânica nova. A `087` trouxe essa mecânica: píer 2 e armazém levam dois dias
jogados, o pátio três, uma obra por vez e paga ao iniciar. Mas o mapa não
soube dela: do dia da compra ao dia em que fica pronto, o porto mostra a
mesma ruína, as mesmas estacas e a mesma terra batida, e a obra só existe no
texto do botão Construir («obra em andamento»). O jogador paga R$ e não vê
nada mudar durante dois ou três dias — o mesmo defeito que o
`_refresh_estruturas()` diz combater: «comprar uma estrutura é só um número
que baixa».

A `036` do ChatGPT dizia «não existe imagem `construction`: a compra do
armazém continua instantânea». Deixou de ser verdade com a `087`, e por isso
um estado de obra deixou de ser estado sem mecânica.

## O que o Bruno escolheu

| Pergunta | Resposta |
|---|---|
| O item gráfico pendente da Fase 1 | **O estado «em obra» no mapa**, contra o armazém recuperado V3 (que ele lembra de ter aprovado: foi no checkout do ChatGPT, e o jogo ainda usa o galpão de 05/09) |
| A composição | **Andaime + material**, a recomendada: cada obra mostra o que está a ser feito, contra o tapume que fecha tudo e a só sinalização |
| A progressão | **Avança por dia**, contra um estado só: dois estágios no píer e no armazém, três no pátio |
| Pessoas na obra | **Sem pessoas**, a recomendada: a obra é contratada e não tira trabalhadores (`087`) |
| O cartão da doca durante a obra do píer | **«píer em obra · pronto no dia N»**, a recomendada, com o prazo do `prazo_da_obra()` |

## O quadro de cada dia

O quadro sai do `obra_em_andamento`: o dia JOGADO da obra (`turn − inicio`),
que é 0 no dia da compra e chega a `dias − 1` no último dia antes de ficar
pronta. A obra comprada no dia 1 com dois dias mostra o quadro 0 no dia 1, o
1 no dia 2, e o prédio pronto no dia 3. O cartão diz «píer em obra» na linha
de cima e «pronto no dia N» na de baixo.

| Obra | Dias | Quadro 0 | Quadro 1 | Quadro 2 |
|---|---|---|---|---|
| **Píer 2** (vaga 2) | 2 | estacas NOVAS, travessas e longarinas, o tabuado empilhado na raiz | o tabuado posto da raiz até pouco além do meio, o resto da pilha na frente | — |
| **Armazém** | 2 | a ruína LIMPA (sem mato, entulho, lona nem portão caído), o andaime e as chapas novas no deck | o galpão pronto sem portão, sem calha e com um terço do telhado por pôr, o mesmo andaime | — |
| **Pátio** | 3 | a terra, dois montes de brita e o rolo junto do avental | 55% do pátio asfaltado a partir do cais, o rolo na frente | 80%, o rolo já do lado da rua, a brita gasta |

Cada quadro parte do estado de ONTEM: o primeiro dia do armazém é a ruína
limpa, o segundo é o pronto a que faltam peças, e o píer usa as estacas e as
ripas do n1. Partilhar é aqui o que faz o prédio não saltar de forma de um
dia para o outro; a regra do par (o ANTES não partilha o DEPOIS) continua a
valer entre a ruína e o pronto.

**O acento da obra é UM, o amarelo de máquina**: o andaime e o rolo. A
primeira candidata pôs o andaime em `metal_claro`, e diante do esqueleto de
aço da ruína os dois cinzentos fundiram-se; com dois vãos ele lia como uma
escada encostada, e com três lê como andaime.

## Como chega ao jogo

- **`tools/gerar_props_iso.py`** ganhou o `andaime()` do kit e sete grupos:
  `pier_obra_0/1`, `galpao_obra_0/1` (com sombra e a escala dos prédios) e
  `patio_obra_0/1/2` (o rolo compactador de um tambor em metros reais, à
  régua da pessoa, e a brita). Os sete PNG entram pelo importador de atlas.
- **O pátio não é prop: é o MAPA.** O asfalto a avançar é o mapa
  PAVIMENTADO recortado por cima do de terra (`AsfaltoDaObra`, um
  `Polygon2D` com a textura dele e a UV na razão 1080/720), do avental até à
  fração do dia. A mancha, a junta e o acesso que o pátio pronto tem chegam
  com ele, e no dia em que fica pronto a troca do mapa inteiro não muda um
  pixel do que já estava asfaltado. O canteiro é um nó só no pátio da doca
  3, e a barreira e o cone, que já eram «de obra», aparecem com ele.
- **`GameState.quadro_da_obra(id, quadros)`** responde aos três leitores; com
  menos quadros do que dias, os dias repartem-se (o píer 3 da Fase 2 leva três
  dias num nó de dois). `prazo_curto_da_obra()` dá o prazo ao cartão sem o
  aviso, que não cabe em 200 px; `prazo_da_obra()` passou a montá-lo a partir
  dele.
- **O mapa redesenha no dia da compra**: até aqui nada o fazia, porque a obra
  só mudava alguma coisa ao ficar pronta.
- **A tabela de âncoras publica o `patio`**, das mesmas expressões que o
  pintam; os dois mapas saíram iguais ao byte.

## A guarda

O **D45** do teste de design (`tests/casos_obra_no_mapa.gd`) compra o píer
de verdade e confere o quadro 0 NO DIA DA COMPRA, vira cada dia das três
obras pelo `advance_turn()` e lê a textura de cada nó, o cartão e o recorte do
asfalto — este contra os cantos que a TABELA publica, e não contra a função
que o desenha. Confere também a cópia do pátio e da projeção contra a tabela,
um quadro por dia, e a obra de três dias em dois quadros. Os sete defeitos que
o provam estão em `tools/mutantes.toml`, de `obra-nao-redesenha-na-compra` a
`obra-patio-sem-sinalizacao`.

## O que a bateria pediu

A página de escala (`escala_props.gd`) reprovou com os sete PNG novos: pedia
1430 px numa tela de 1280. Os quadros da obra passaram a contar como os de
animação — o armazém e o píer pelo prédio pronto, o canteiro pelo primeiro
dia, porque o rolo e a brita são a peça nova —, e mesmo assim faltavam 3 px;
o espaço entre filas passou de 8 para 7. **A página está no limite**: o prop
seguinte pede segunda página ou legenda mais curta.

## Custo e estado

Os sete atlas novos somam 140 KB (os PNG fonte, 482 KB); o `.pck` do CI dá o
número do pacote. Seis suítes verdes neste contêiner, `MUTANTES OK` nos sete,
bateria de 86 fotos com `COBERTURA OK`. **Sem aceite**: o Bruno julga na foto
do jogo, e só então a candidata deixa de o ser.

## A segunda passagem do pátio

Vistas as fotos, o Bruno pediu o pátio reforçado: **rolo maior e mais
asfalto no dia 2**. O rolo maior é uma MÁQUINA maior, e não o tandem
esticado: o compactador de um tambor (5,8 m, tambor de 1,5 m), que é também o
que compacta a base de brita, pela mesma régua da pessoa (`069`). O asfalto
passou de 40% e 75% para **55% e 80%**: aos 40% o dia 2 era uma faixa rente
ao avental que se confundia com ele, e o dia 3 subiu junto para a passada não
encurtar. No dia 3 a brita acabou — com o rolo maior, o resto do monte já não
tinha onde ficar fora dele.
